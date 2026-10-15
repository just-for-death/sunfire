// DB-backed regressions for two data-loss bugs:
//  - Manga.tagIds was written but never deserialized (final field), so tags
//    never loaded and the next save of the manga wiped them.
//  - Duplicate merge called deleteManga(dupe.id) with the local Isar id where
//    a server id is expected, deleting whatever manga owned that server id.
//  - Reader siblings for Local/standalone series (negative manga ids) were
//    looked up under manga id 0 on first open, so there was no next/prev.
//  - Offline queue: a page turn after an explicit reset coalesced onto the
//    progress queued before the reset; a pull re-added a category whose
//    delete was still queued.
//
// Run: flutter test test/tags_and_dupe_merge_native_test.dart
@Tags(['native'])
library;

import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunfire/src/core/db/isar_service.dart';
import 'package:sunfire/src/core/db/models/category.dart';
import 'package:sunfire/src/core/db/models/chapter.dart';
import 'package:sunfire/src/core/db/models/manga.dart';
import 'package:sunfire/src/core/db/models/sync_meta.dart';
import 'package:sunfire/src/core/db/models/sync_record.dart';
import 'package:sunfire/src/core/db/models/tag.dart';
import 'package:sunfire/src/core/library/duplicate_detection_service.dart';
import 'package:sunfire/src/core/library/library_import_export_service.dart';
import 'package:sunfire/src/core/library/smart_collection_service.dart';
import 'package:sunfire/src/core/services/settings_service.dart';
import 'package:sunfire/src/core/services/tag_service.dart';
import 'package:sunfire/src/core/sync/sync_engine.dart';
import 'package:sunfire/src/features/reader/reader_chapter_resolve.dart';

String? _findIsarNative() {
  // Prefer isar_community_flutter_libs (3.3.2); fall back to legacy isar_flutter_libs.
  String? legacy;
  // 1) pub-cache hosted layout: .pub-cache/hosted/pub.dev/isar_community_flutter_libs-*/linux/libisar.so
  final hosted = Directory('${Platform.environment['HOME']}/.pub-cache/hosted/pub.dev');
  if (hosted.existsSync()) {
    for (final d in hosted.listSync().whereType<Directory>()) {
      final isCommunity = d.path.contains('isar_community_flutter_libs');
      final isLegacy = d.path.contains('isar_flutter_libs') && !isCommunity;
      if (isCommunity || isLegacy) {
        final f = File('${d.path}/linux/libisar.so');
        if (f.existsSync()) {
          if (isCommunity) return f.path;
          legacy ??= f.path;
        }
      }
    }
  }
  // 2) legacy flat pub-cache layout.
  final rootDir = Directory('${Platform.environment['HOME']}/.pub-cache');
  if (rootDir.existsSync()) {
    for (final d in rootDir.listSync().whereType<Directory>()) {
      final isCommunity = d.path.contains('isar_community_flutter_libs');
      final isLegacy = d.path.contains('isar_flutter_libs') && !isCommunity;
      if (isCommunity || isLegacy) {
        final f = File('${d.path}/linux/libisar.so');
        if (f.existsSync()) {
          if (isCommunity) return f.path;
          legacy ??= f.path;
        }
      }
    }
  }
  // 3) flutter test build output (rebuilt via `flutter build linux --debug`).
  final buildLib = File(
    '${Directory.current.path}/build/linux/x64/debug/bundle/lib/libisar.so',
  );
  if (buildLib.existsSync()) return buildLib.path;
  return legacy;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('sunfire_tags_dupes');
    final native = _findIsarNative();
    if (native == null) fail('libisar.so not found (pub cache or build output)');
    await Isar.initializeIsarCore(libraries: {Abi.linuxX64: native});
    await Isar.open(
      [MangaSchema, ChapterSchema, CategorySchema, SyncRecordSchema, SyncMetaSchema, TagSchema],
      directory: tempDir.path,
      inspector: false,
    );
    await IsarService.instance.initialize();
    SharedPreferences.setMockInitialValues({});
    await SettingsService.instance.initialize();
    SettingsService.instance.incognitoMode = false;
  });

  tearDownAll(() async {
    await IsarService.instance.isar.close();
    try {
      await tempDir.delete(recursive: true);
    } catch (_) {}
  });

  setUp(() async {
    await IsarService.instance.isar.writeTxn(() => IsarService.instance.isar.clear());
  });

  Manga manga(int serverId, String title, {String url = '', String source = 'src'}) => Manga()
    ..serverId = serverId
    ..title = title
    ..url = url
    ..sourceName = source
    ..inLibrary = true;

  Chapter chapter(int serverId, int mangaId, double number, {bool read = false, int page = 0}) => Chapter()
    ..serverId = serverId
    ..mangaId = mangaId
    ..chapterNumber = number
    ..name = 'Ch $number'
    ..isRead = read
    ..lastPageRead = page;

  test('tags survive a reload and a later save of the manga', () async {
    await IsarService.instance.saveManga(manga(7, 'Tagged'));
    final a = await TagService.instance.createTag(name: 'favs');
    final b = await TagService.instance.createTag(name: 'reread');
    expect(await TagService.instance.assignTag(7, a!.id), isTrue);
    expect(await TagService.instance.assignTag(7, b!.id), isTrue);

    final reloaded = await IsarService.instance.getMangaByServerId(7);
    expect(reloaded!.tagIds, unorderedEquals([a.id, b.id]));

    reloaded.title = 'Tagged (renamed)';
    await IsarService.instance.saveManga(reloaded);
    final names = (await TagService.instance.getTagsForManga(7)).map((t) => t.name);
    expect(names, unorderedEquals(['favs', 'reread']));

    await TagService.instance.removeTag(7, a.id);
    expect((await IsarService.instance.getMangaByServerId(7))!.tagIds, [b.id]);
  });

  test('merge deletes the duplicate by server id and never an unrelated manga', () async {
    await IsarService.instance.saveManga(manga(500, 'Solo Leveling', url: '/manga/solo'));
    await IsarService.instance.saveManga(manga(600, 'Solo Leveling', url: '/manga/solo'));
    final dupe = (await IsarService.instance.getMangaByServerId(600))!;
    // An unrelated series whose SERVER id equals the duplicate's LOCAL Isar id.
    await IsarService.instance.saveManga(manga(dupe.id, 'Unrelated'));
    await IsarService.instance.saveChapter(chapter(9001, dupe.id, 1));

    await IsarService.instance.saveChapters([
      chapter(1, 500, 1),
      chapter(2, 500, 2),
      chapter(11, 600, 2, read: true, page: 30),
      chapter(13, 600, 3),
    ]);
    final canon = (await IsarService.instance.getMangaByServerId(500))!;
    await DuplicateDetectionService.instance.mergeGroup(
      DuplicateGroup(canonical: canon, duplicates: [dupe], reason: 'test'),
    );

    expect(await IsarService.instance.getMangaByServerId(600), isNull);
    expect(await IsarService.instance.getMangaByServerId(dupe.id), isNotNull, reason: 'unrelated manga must survive');
    expect(await IsarService.instance.getChaptersForManga(dupe.id), hasLength(1));

    final merged = await IsarService.instance.getChaptersForManga(500);
    expect(merged.map((c) => c.chapterNumber).toList()..sort(), [1.0, 2.0, 3.0], reason: 'no doubled chapter 2');
    final ch2 = merged.firstWhere((c) => c.chapterNumber == 2);
    expect(ch2.isRead, isTrue);
    expect(ch2.lastPageRead, 30);
    final saved = (await IsarService.instance.getMangaByServerId(500))!;
    expect(saved.chapterCount, 3);
    expect(saved.unreadCount, 2);
  });

  test('reader finds next/prev for a negative-id (local) series without a parent', () async {
    await IsarService.instance.saveChapters([
      chapter(-1, -42, 1),
      chapter(-2, -42, 2),
      chapter(-3, -42, 3),
    ]);
    final current = (await IsarService.instance.getChapterByServerId(-2))!;
    final nav = await resolveSiblingChapterNav(isar: IsarService.instance, chapter: current);
    expect(nav.siblings, hasLength(3));
    expect(nav.next?.chapterNumber, 3);
    expect(nav.prev?.chapterNumber, 1);
  });

  test('offline reset is not undone by a later page turn coalescing onto older progress', () async {
    const id = 321;
    await SyncEngine.instance.syncChapterProgress(id, isRead: false, lastPageRead: 30);
    await SyncEngine.instance.syncChapterProgress(id, isRead: false, lastPageRead: 0, explicit: true);
    await SyncEngine.instance.syncChapterProgress(id, isRead: false, lastPageRead: 4);

    final payloads = (await IsarService.instance.getPendingChapterRecords('$id'))
        .map((r) => jsonDecode(r.payloadJson) as Map<String, dynamic>)
        .toList();
    expect(payloads.map((p) => p['lastPageRead']), unorderedEquals([0, 4]));
    expect(payloads.firstWhere((p) => p['lastPageRead'] == 0)['explicit'], isTrue);
  });

  test('a category pull does not resurrect a category whose delete is queued', () async {
    Category cat(int serverId, String name) => Category()
      ..serverId = serverId
      ..name = name;
    await IsarService.instance.saveSyncRecord(SyncRecord()
      ..recordId = 'del-9'
      ..entityType = SyncEntityType.category
      ..entityId = '9'
      ..action = SyncAction.delete
      ..payloadJson = '{"op":"delete","categoryId":9}'
      ..timestamp = 1
      ..deviceId = 'test'
      ..state = SyncRecordState.pending);

    await IsarService.instance.saveCategories([cat(8, 'Keep'), cat(9, 'Deleted offline')]);
    final names = (await IsarService.instance.getCategories()).map((c) => c.name);
    expect(names, contains('Keep'));
    expect(names, isNot(contains('Deleted offline')));
  });

  test('flush lease: one holder at a time, expired or released leases are free', () async {
    const key = 'test_lease';
    expect(await IsarService.instance.tryAcquireLease(key, 'fg', const Duration(minutes: 5)), isTrue);
    expect(await IsarService.instance.tryAcquireLease(key, 'bg', const Duration(minutes: 5)), isFalse);
    expect(await IsarService.instance.tryAcquireLease(key, 'fg', const Duration(minutes: 5)), isTrue, reason: 'renewal');
    await IsarService.instance.releaseLease(key, 'bg');
    expect(await IsarService.instance.tryAcquireLease(key, 'bg', const Duration(minutes: 5)), isFalse,
        reason: 'only the holder can release');
    await IsarService.instance.releaseLease(key, 'fg');
    expect(await IsarService.instance.tryAcquireLease(key, 'bg', Duration.zero), isTrue);
    expect(await IsarService.instance.tryAcquireLease(key, 'fg', const Duration(minutes: 5)), isTrue,
        reason: 'a zero-ttl lease is already expired');
  });

  test('a smart tag leaves a series that stops matching; manual tags stay', () async {
    SharedPreferences.setMockInitialValues({});
    await SettingsService.instance.initialize();
    final m = manga(40, 'Ongoing')..status = 'ONGOING';
    await IsarService.instance.saveManga(m);
    final manual = await TagService.instance.createTag(name: 'mine');
    await TagService.instance.assignTag(40, manual!.id);
    await SmartCollectionService.instance.saveRules([
      SmartCollectionRule(
        id: 'r1', name: 'Ongoing', tagName: 'ongoing',
        field: SmartMatchField.status, op: SmartMatchOp.equals, matchValue: 'ONGOING',
      ),
    ]);

    expect(await SmartCollectionService.instance.evaluateAll(), 1);
    expect(await SmartCollectionService.instance.evaluateAll(), 0, reason: 'no-op rerun');
    var names = (await TagService.instance.getTagsForManga(40)).map((t) => t.name).toSet();
    expect(names, {'mine', 'ongoing'});

    final stored = (await IsarService.instance.getMangaByServerId(40))!..status = 'COMPLETED';
    await IsarService.instance.saveManga(stored);
    expect(await SmartCollectionService.instance.evaluateAll(), 1);
    names = (await TagService.instance.getTagsForManga(40)).map((t) => t.name).toSet();
    expect(names, {'mine'});
  });

  test('import reuses a stored non-library row instead of replacing it', () async {
    final id = stableLocalMangaServerId(sourceName: 'src', url: '/s/1', title: 'Kept');
    final stored = manga(id, 'Kept', url: '/s/1')
      ..inLibrary = false
      ..description = 'stored description';
    await IsarService.instance.saveManga(stored);

    final res = await LibraryImportExportService.instance.importEntries([
      const LibraryExportEntry(title: 'Kept', sourceName: 'src', url: '/s/1'),
    ]);
    expect(res.created, 0);
    expect(res.updated, 1);
    final after = (await IsarService.instance.getMangaByServerId(id))!;
    expect(after.inLibrary, isTrue);
    expect(after.description, 'stored description');
  });

  test('import matches an exported serverId only for the same series', () async {
    await IsarService.instance.saveManga(manga(-77, 'Other series', url: '/o')..inLibrary = false);
    await IsarService.instance.saveManga(manga(-78, 'Same', url: '/same')..inLibrary = false);

    await LibraryImportExportService.instance.importEntries([
      const LibraryExportEntry(title: 'Imported', sourceName: 'src', url: '/new', serverId: -77),
      const LibraryExportEntry(title: 'Same', sourceName: 'src', url: '/same', serverId: -78),
    ]);
    expect((await IsarService.instance.getMangaByServerId(-77))!.inLibrary, isFalse);
    expect((await IsarService.instance.getMangaByServerId(-78))!.inLibrary, isTrue);
    final library = await IsarService.instance.getLibraryManga();
    expect(library.map((m) => m.title).toSet(), {'Imported', 'Same'});
  });
}
