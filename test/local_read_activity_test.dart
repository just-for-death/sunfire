// DB-backed tests for local read-activity stamping.
//
// Regression guard for S6: marking a chapter read from Library / Updates /
// Manga Detail (anywhere except the Reader) previously pushed only the read
// flag to the server and left the local `Chapter.lastReadAt` and
// `Manga.lastReadAt` stale. That made the action invisible to History's
// "Last Read" grouping, to the `lastReadAt > 0` in-progress query, and to
// Library "Last Read" sorting.
//
// Run: fvm flutter test test/local_read_activity_test.dart
import 'dart:ffi';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:sunfire/src/core/db/isar_service.dart';
import 'package:sunfire/src/core/db/models/category.dart';
import 'package:sunfire/src/core/db/models/chapter.dart';
import 'package:sunfire/src/core/db/models/manga.dart';
import 'package:sunfire/src/core/db/models/sync_meta.dart';
import 'package:sunfire/src/core/db/models/sync_record.dart';
import 'package:sunfire/src/core/sync/sync_engine.dart';

String? _findIsarNative() {
  final hosted = Directory('${Platform.environment['HOME']}/.pub-cache/hosted/pub.dev');
  if (hosted.existsSync()) {
    for (final d in hosted.listSync().whereType<Directory>()) {
      if (d.path.contains('isar_flutter_libs')) {
        final f = File('${d.path}/linux/libisar.so');
        if (f.existsSync()) return f.path;
      }
    }
  }
  final rootDir = Directory('${Platform.environment['HOME']}/.pub-cache');
  if (rootDir.existsSync()) {
    for (final d in rootDir.listSync().whereType<Directory>()) {
      if (d.path.contains('isar_flutter_libs')) {
        final f = File('${d.path}/linux/libisar.so');
        if (f.existsSync()) return f.path;
      }
    }
  }
  final buildLib = File(
    '${Directory.current.path}/build/linux/x64/debug/bundle/lib/libisar.so',
  );
  if (buildLib.existsSync()) return buildLib.path;
  return null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('sunfire_read_activity');
    final native = _findIsarNative();
    if (native == null) {
      fail('libisar.so not found (pub cache or build output) — cannot run DB-backed tests');
    }
    await Isar.initializeIsarCore(libraries: {Abi.linuxX64: native});
    await Isar.open(
      [MangaSchema, ChapterSchema, CategorySchema, SyncRecordSchema, SyncMetaSchema],
      directory: tempDir.path,
      inspector: false,
    );
    await IsarService.instance.initialize();
  });

  tearDownAll(() async {
    await IsarService.instance.isar.close();
    try {
      await tempDir.delete(recursive: true);
    } catch (_) {}
  });

  setUp(() async {
    await IsarService.instance.isar.writeTxn(() async {
      await IsarService.instance.isar.clear();
    });
  });

  Future<Manga> seedManga(int serverId) async {
    final manga = Manga()
      ..serverId = serverId
      ..title = 'Series $serverId'
      ..sourceName = 'test_source'
      ..inLibrary = true
      ..unreadCount = 3;
    await IsarService.instance.saveManga(manga);
    return manga;
  }

  group('SyncEngine.stampLocalReadActivity', () {
    test('stamps a chapter that has no prior read activity', () async {
      await seedManga(500);
      final chapter = Chapter()
        ..serverId = 9001
        ..mangaId = 500
        ..name = 'Ch 1'
        ..isRead = true
        ..lastPageRead = 20;
      await IsarService.instance.saveChapter(chapter);

      expect(chapter.lastReadAt, isNull);

      await SyncEngine.instance.stampLocalReadActivity(chapter);

      expect(chapter.lastReadAt, isNotNull);
      expect(chapter.lastReadAt, greaterThan(0));
    });

    test('stamp is persisted, so History and the in-progress query see it', () async {
      final manga = await seedManga(501);
      final chapter = Chapter()
        ..serverId = 9002
        ..mangaId = 501
        ..name = 'Ch 1'
        ..isRead = true;
      await IsarService.instance.saveChapter(chapter);

      // Before stamping, the chapter is invisible to both consumers — they
      // filter on `lastReadAt > 0`.
      expect(
        (await IsarService.instance.getReadingHistory()).any((c) => c.serverId == 9002),
        isFalse,
      );

      await SyncEngine.instance.stampLocalReadActivity(chapter);

      // Re-read from the DB rather than trusting the in-memory object.
      final reloaded = await IsarService.instance.getChapterByServerId(9002);
      expect(reloaded, isNotNull);
      expect(reloaded!.lastReadAt, isNotNull);
      expect(reloaded.lastReadAt, greaterThan(0));

      // History now returns it.
      expect(
        (await IsarService.instance.getReadingHistory()).any((c) => c.serverId == 9002),
        isTrue,
        reason: 'History filters on lastReadAt > 0',
      );
      expect(manga.serverId, 501);
    });

    test('a freshly-read chapter sorts to the top of Continue Reading', () async {
      await seedManga(506);
      // An older, already-stamped in-progress chapter.
      final older = Chapter()
        ..serverId = 9010
        ..mangaId = 506
        ..name = 'Ch 1'
        ..isRead = false
        ..lastPageRead = 7
        ..lastReadAt = DateTime.now().millisecondsSinceEpoch ~/ 1000 - 86400;
      await IsarService.instance.saveChapter(older);

      // The chapter the user just picked up: correct page position, but no
      // read stamp because it was marked from the library, not the Reader.
      final fresh = Chapter()
        ..serverId = 9009
        ..mangaId = 506
        ..name = 'Ch 2'
        ..isRead = false
        ..lastPageRead = 3
        ..lastReadAt = null;
      await IsarService.instance.saveChapter(fresh);

      // getInProgressChapters sorts by lastReadAt DESC, so an unstamped
      // (NULL) chapter sinks below the stale one even though it is the most
      // recent activity.
      final before = await IsarService.instance.getInProgressChapters();
      expect(before.map((c) => c.serverId), containsAll(<int>[9009, 9010]));
      expect(before.first.serverId, 9010, reason: 'unstamped chapter sorts last');

      await SyncEngine.instance.stampLocalReadActivity(fresh);

      final after = await IsarService.instance.getInProgressChapters();
      expect(after.first.serverId, 9009, reason: 'freshly-read chapter must lead');
    });

    test('series-level stamp is advanced for Library "Last Read" sorting', () async {
      final manga = await seedManga(502);
      expect(manga.lastReadAt, isNull);

      final chapter = Chapter()
        ..serverId = 9003
        ..mangaId = 502
        ..name = 'Ch 1'
        ..isRead = true;
      await IsarService.instance.saveChapter(chapter);

      await SyncEngine.instance.stampLocalReadActivity(chapter);

      final reloadedManga = await IsarService.instance.getMangaByServerId(502);
      expect(reloadedManga, isNotNull);
      expect(reloadedManga!.lastReadAt, isNotNull);
      expect(reloadedManga.lastReadAt, greaterThan(0));
    });

    test('an existing newer stamp is never rolled backwards', () async {
      await seedManga(503);
      final futureStamp = DateTime.now().millisecondsSinceEpoch ~/ 1000 + 10000;
      final chapter = Chapter()
        ..serverId = 9004
        ..mangaId = 503
        ..name = 'Ch 1'
        ..isRead = true
        ..lastReadAt = futureStamp;
      await IsarService.instance.saveChapter(chapter);

      await SyncEngine.instance.stampLocalReadActivity(chapter);

      expect(chapter.lastReadAt, futureStamp);
    });

    test('a series stamp newer than the chapter stamp is also preserved', () async {
      final manga = await seedManga(504);
      final seriesStamp = DateTime.now().millisecondsSinceEpoch ~/ 1000 + 10000;
      manga.lastReadAt = seriesStamp;
      await IsarService.instance.saveManga(manga);

      final chapter = Chapter()
        ..serverId = 9005
        ..mangaId = 504
        ..name = 'Ch 1'
        ..isRead = true;
      await IsarService.instance.saveChapter(chapter);

      await SyncEngine.instance.stampLocalReadActivity(chapter);

      final reloadedManga = await IsarService.instance.getMangaByServerId(504);
      expect(reloadedManga!.lastReadAt, seriesStamp);
    });

    test('a chapter with no parent series does not throw', () async {
      final orphan = Chapter()
        ..serverId = 9006
        ..mangaId = 0
        ..name = 'Orphan'
        ..isRead = true;
      await IsarService.instance.saveChapter(orphan);

      await expectLater(
        SyncEngine.instance.stampLocalReadActivity(orphan),
        completes,
      );
      expect(orphan.lastReadAt, isNotNull);
    });

    test('a chapter pointing at a missing series does not throw', () async {
      final dangling = Chapter()
        ..serverId = 9007
        ..mangaId = 424242
        ..name = 'Dangling'
        ..isRead = true;
      await IsarService.instance.saveChapter(dangling);

      await expectLater(
        SyncEngine.instance.stampLocalReadActivity(dangling),
        completes,
      );
      expect(dangling.lastReadAt, isNotNull);
    });

    test('stamps use epoch seconds, not milliseconds', () async {
      await seedManga(505);
      final chapter = Chapter()
        ..serverId = 9008
        ..mangaId = 505
        ..name = 'Ch 1'
        ..isRead = true;
      await IsarService.instance.saveChapter(chapter);

      await SyncEngine.instance.stampLocalReadActivity(chapter);

      final millis = DateTime.now().millisecondsSinceEpoch;
      // A seconds stamp is ~1000x smaller than a millis stamp; assert it is
      // in the seconds range so it sorts correctly against server values.
      expect(chapter.lastReadAt, lessThan(millis ~/ 100));
      expect(chapter.lastReadAt, greaterThan(millis ~/ 1000 - 60));
    });
  });
}
