// Regression test for silent chapter data loss on locally-scraped (QuickJS)
// series when a source prepends a new chapter.
//
// The synthetic server id for a scraped chapter was derived from its *array
// index*: -(mangaId * 100000 + index + 1). That is not stable. When a source
// prepends a chapter, every later chapter shifts down one slot, so the id the
// newcomer takes is the one already held by the chapter that used to sit
// there. Chapter.serverId is `@Index(unique: true, replace: true)` and
// saveChapters uses putAll, so the write silently REPLACED that row — the
// user kept the chapter but lost its read state, bookmark and local download,
// with no error anywhere.
//
// Run: fvm flutter test test/local_chapter_id_collision_test.dart
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

/// Reproduces the exact index->id formula both call sites used before the fix,
/// so the test can show what it produced and how the guard changes it.
int legacySyntheticId(int mangaId, int index) => -(mangaId.abs() * 100000 + index + 1);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('sunfire_chapter_ids');
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

  const mangaId = 42;

  Future<Chapter> storedChapterByUrl(String url) async {
    final all = await IsarService.instance.getChaptersForManga(mangaId);
    return all.firstWhere((c) => c.url == url);
  }

  group('mintLocalChapterServerId', () {
    test('assigns the documented base id when nothing is taken', () {
      final taken = <int>{};
      expect(
        mintLocalChapterServerId(mangaId: mangaId, index: 0, takenServerIds: taken),
        legacySyntheticId(mangaId, 0),
      );
    });

    test('is always negative, so it can never alias a real server chapter', () {
      final taken = <int>{};
      for (var i = 0; i < 50; i++) {
        expect(
          mintLocalChapterServerId(mangaId: mangaId, index: i, takenServerIds: taken),
          lessThan(0),
        );
      }
    });

    test('never hands out the same id twice', () {
      final taken = <int>{};
      final seen = <int>{};
      for (var i = 0; i < 200; i++) {
        final id = mintLocalChapterServerId(mangaId: mangaId, index: i, takenServerIds: taken);
        expect(seen.add(id), isTrue, reason: 'id $id was handed out twice');
      }
    });

    test('records each id into takenServerIds so the next call can avoid it', () {
      final taken = <int>{};
      final id = mintLocalChapterServerId(mangaId: mangaId, index: 0, takenServerIds: taken);
      expect(taken, contains(id));
    });

    test('probes around a pre-taken id instead of colliding', () {
      final base = legacySyntheticId(mangaId, 0);
      final taken = <int>{base};
      final id = mintLocalChapterServerId(mangaId: mangaId, index: 0, takenServerIds: taken);
      expect(id, isNot(base), reason: 'must not reuse the id already in use');
      expect(taken, containsAll(<int>[base, id]), reason: 'both ids stay reserved');
    });

    test('handles negative manga ids via abs()', () {
      final taken = <int>{};
      final a = mintLocalChapterServerId(mangaId: -7, index: 0, takenServerIds: taken);
      final b = mintLocalChapterServerId(mangaId: 7, index: 1, takenServerIds: taken);
      expect(a, isNot(b));
      expect(a, lessThan(0));
      expect(b, lessThan(0));
    });
  });

  group('the collision it prevents (real DB write)', () {
    // Seed: source previously returned [A, B]. Both are read, bookmarked and
    // downloaded, because that is the state a user has accumulated.
    Future<void> seedTwoChapters() async {
      for (var i = 0; i < 2; i++) {
        final ch = Chapter()
          ..serverId = legacySyntheticId(mangaId, i)
          ..mangaId = mangaId
          ..name = 'Chapter ${i + 1}'
          ..url = 'https://src/chapter-${i + 1}'
          ..isRead = true
          ..lastPageRead = 18
          ..isBookmarked = true
          ..isDownloadedLocally = true;
        await IsarService.instance.saveChapter(ch);
      }
    }

    test('the legacy index-derived id collides after a prepend', () {
      seedTwoChapters();
      // Source now returns [NEW, A, B] — NEW is at index 0, which is exactly
      // the id chapter A already holds.
      final newIndexInSource = 0;
      expect(
        legacySyntheticId(mangaId, newIndexInSource),
        legacySyntheticId(mangaId, 0),
        reason: 'precondition: the newcomer wants the slot chapter A already owns',
      );
    });

    test('writing the legacy id DESTROYS the existing chapter row', () async {
      await seedTwoChapters();

      // Confirm the seeded state.
      final aBefore = await storedChapterByUrl('https://src/chapter-1');
      expect(aBefore.isRead, isTrue);
      expect(aBefore.isBookmarked, isTrue);
      expect(aBefore.isDownloadedLocally, isTrue);

      // The buggy write: a new chapter that happens to land on A's id.
      final clobbering = Chapter()
        ..serverId = legacySyntheticId(mangaId, 0)
        ..mangaId = mangaId
        ..name = 'Chapter 0 (new)'
        ..url = 'https://src/chapter-0'
        ..isRead = false
        ..lastPageRead = 0
        ..isBookmarked = false
        ..isDownloadedLocally = false;
      await IsarService.instance.saveChapters([clobbering]);

      // Chapter A is GONE — replaced, with no error raised anywhere.
      final remaining = await IsarService.instance.getChaptersForManga(mangaId);
      expect(
        remaining.map((c) => c.url),
        isNot(contains('https://src/chapter-1')),
        reason: 'the old chapter was silently replaced',
      );
      expect(remaining, hasLength(2), reason: 'only B and the newcomer remain');
    });

    test('the guarded id leaves the existing chapter completely intact', () async {
      await seedTwoChapters();

      final taken = (await IsarService.instance.getChaptersForManga(mangaId))
          .map((c) => c.serverId)
          .toSet();

      // A source prepends a new chapter at index 0.
      final newcomerId =
          mintLocalChapterServerId(mangaId: mangaId, index: 0, takenServerIds: taken);
      final newcomer = Chapter()
        ..serverId = newcomerId
        ..mangaId = mangaId
        ..name = 'Chapter 0 (new)'
        ..url = 'https://src/chapter-0'
        ..isRead = false
        ..lastPageRead = 0;
      await IsarService.instance.saveChapters([newcomer]);

      // Both pre-existing chapters survive with all their state.
      final remaining = await IsarService.instance.getChaptersForManga(mangaId);
      expect(remaining, hasLength(3), reason: 'nothing was lost');

      final aAfter = await storedChapterByUrl('https://src/chapter-1');
      expect(aAfter.isRead, isTrue);
      expect(aAfter.lastPageRead, 18);
      expect(aAfter.isBookmarked, isTrue);
      expect(aAfter.isDownloadedLocally, isTrue);

      final bAfter = await storedChapterByUrl('https://src/chapter-2');
      expect(bAfter.isRead, isTrue);
      expect(bAfter.isBookmarked, isTrue);
      expect(bAfter.isDownloadedLocally, isTrue);
    });

    test('repeated prepends keep accumulating instead of overwriting', () async {
      await seedTwoChapters();

      // Five appends at the front over the life of the series, each time
      // minting from the source's current index 0.
      for (var round = 0; round < 5; round++) {
        final taken = (await IsarService.instance.getChaptersForManga(mangaId))
            .map((c) => c.serverId)
            .toSet();
        final id = mintLocalChapterServerId(mangaId: mangaId, index: 0, takenServerIds: taken);
        final ch = Chapter()
          ..serverId = id
          ..mangaId = mangaId
          ..name = 'New $round'
          ..url = 'https://src/new-$round'
          ..isRead = false
          ..lastPageRead = 0
          ..isBookmarked = true
          ..isDownloadedLocally = true;
        await IsarService.instance.saveChapters([ch]);
      }

      final remaining = await IsarService.instance.getChaptersForManga(mangaId);
      expect(remaining, hasLength(7), reason: '2 original + 5 prepended, none lost');
      // Every bookmark/download survived.
      expect(remaining.where((c) => c.isBookmarked), hasLength(7));
      expect(remaining.where((c) => c.isDownloadedLocally), hasLength(7));
    });
  });
}
