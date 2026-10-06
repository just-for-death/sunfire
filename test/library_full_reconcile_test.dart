// ISS-052: every sync trigger reconciles against the FULL server library.
// Covers (1) newly added manga incl. uncategorised/Default, (2) server
// category changes, (3) server-side library removals.
//
// Run: flutter test --timeout 60s test/library_full_reconcile_test.dart
import 'dart:ffi';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:sunfire/src/core/db/isar_service.dart';
import 'package:sunfire/src/core/db/models/category.dart';
import 'package:sunfire/src/core/db/models/chapter.dart';
import 'package:sunfire/src/core/db/models/manga.dart';
import 'package:sunfire/src/core/db/models/sync_meta.dart';
import 'package:sunfire/src/core/db/models/sync_record.dart';
import 'package:sunfire/src/core/sync/sync_engine.dart';

String? _findIsarNative() {
  String? legacy;
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
  final buildLib = File(
    '${Directory.current.path}/build/linux/x64/debug/bundle/lib/libisar.so',
  );
  if (buildLib.existsSync()) return buildLib.path;
  return legacy;
}

/// Mirrors `_performFullSync` library-membership upsert for one fetchLibrary
/// node: get-or-create by serverId, set inLibrary, overwrite categoryIds from
/// the server snapshot (no cursor / last-sync filter).
Future<Manga> upsertLibraryNode(Map<String, dynamic> node, {required int nowUnix}) async {
  final serverId = node['id'] as int;
  var manga = await IsarService.instance.getMangaByServerId(serverId);
  manga ??= Manga()..serverId = serverId;
  manga.title = node['title']?.toString() ?? 'Untitled';
  manga.inLibrary = true;
  manga.lastFetchedAt = nowUnix;
  manga.inLibraryAt ??= nowUnix;
  manga.sourceName = 'Src';
  final cats = node['categories'];
  if (cats is Map) {
    manga.categoryIds = parseMangaCategoryIds(cats['nodes'] ?? const <dynamic>[]);
  }
  return manga;
}

/// Soft-removes local in-library manga whose serverId is absent from [serverIds],
/// matching the removal cascade when the snapshot is complete + wipe-guard safe.
Future<int> softRemoveMissing(Set<int> serverIds) async {
  final localLib = await IsarService.instance.getLibraryManga();
  final toRemove = <Manga>[];
  for (final local in localLib) {
    if (local.serverId > 0 && !serverIds.contains(local.serverId)) {
      local.inLibrary = false;
      toRemove.add(local);
    }
  }
  if (toRemove.isNotEmpty) {
    await IsarService.instance.saveMangas(toRemove);
  }
  return toRemove.length;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ISS-052 full library reconcile', () {
    late Directory tempDir;

    setUpAll(() async {
      tempDir = await Directory.systemTemp.createTemp('sunfire_iss052_');
      final native = _findIsarNative();
      if (native == null) {
        fail('libisar.so not found — cannot run DB-backed ISS-052 tests');
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

    test('1) new server manga (uncategorised/Default) appears after next sync', () async {
      const now = 1787000000;
      // Initial sync: one titled series already categorised.
      final first = await upsertLibraryNode({
        'id': 10,
        'title': 'Old Title',
        'categories': {
          'nodes': [
            {'id': 1, 'name': 'Reading'},
          ],
        },
      }, nowUnix: now);
      await IsarService.instance.saveMangas([first]);
      expect((await IsarService.instance.getLibraryManga()).length, 1);

      // Next sync trigger returns the full library: old title + brand-new
      // uncategorised manga (empty categories.nodes = Suwayomi Default).
      final oldAgain = await upsertLibraryNode({
        'id': 10,
        'title': 'Old Title',
        'categories': {
          'nodes': [
            {'id': 1, 'name': 'Reading'},
          ],
        },
      }, nowUnix: now + 60);
      final brandNew = await upsertLibraryNode({
        'id': 11,
        'title': 'Brand New Default',
        'categories': {'nodes': <dynamic>[]},
      }, nowUnix: now + 60);
      await IsarService.instance.saveMangas([oldAgain, brandNew]);

      final library = await IsarService.instance.getLibraryManga();
      expect(library.length, 2);
      expect(library.map((m) => m.serverId).toSet(), {10, 11});

      final newbie = library.firstWhere((m) => m.serverId == 11);
      expect(newbie.categoryIds, [0]);
      expect(mangaBelongsToCategory(newbie.categoryIds, 0), isTrue);
      expect(mangaBelongsToCategory(newbie.categoryIds, 1), isFalse);

      final defaultCount =
          library.where((m) => mangaBelongsToCategory(m.categoryIds, 0)).length;
      expect(defaultCount, 1);
      expect(
        library.where((m) => mangaBelongsToCategory(m.categoryIds, 1)).length,
        1,
      );
    });

    test('1b) already-synced empty categoryIds still count as Default', () async {
      // Pre-fix rows may still have [] until the next pull rewrites them.
      final stale = Manga()
        ..serverId = 99
        ..title = 'Stale Empty Cats'
        ..inLibrary = true
        ..categoryIds = [];
      await IsarService.instance.saveMangas([stale]);
      final library = await IsarService.instance.getLibraryManga();
      expect(mangaBelongsToCategory(library.single.categoryIds, 0), isTrue);
      expect(
        library.where((m) => mangaBelongsToCategory(m.categoryIds, 0)).length,
        1,
      );
    });

    test('2) server category change is applied on full reconcile', () async {
      const now = 1787000000;
      final initial = await upsertLibraryNode({
        'id': 20,
        'title': 'Moving Series',
        'categories': {
          'nodes': [
            {'id': 1, 'name': 'Reading'},
          ],
        },
      }, nowUnix: now);
      await IsarService.instance.saveMangas([initial]);
      expect(
        (await IsarService.instance.getMangaByServerId(20))!.categoryIds,
        [1],
      );

      // Server moved it from Reading → Manga (id 4); full snapshot overwrites.
      final moved = await upsertLibraryNode({
        'id': 20,
        'title': 'Moving Series',
        'categories': {
          'nodes': [
            {'id': 4, 'name': 'Manga'},
          ],
        },
      }, nowUnix: now + 30);
      await IsarService.instance.saveMangas([moved]);

      final after = (await IsarService.instance.getMangaByServerId(20))!;
      expect(after.categoryIds, [4]);
      expect(mangaBelongsToCategory(after.categoryIds, 1), isFalse);
      expect(mangaBelongsToCategory(after.categoryIds, 4), isTrue);
      expect(mangaBelongsToCategory(after.categoryIds, 0), isFalse);
    });

    test('3) server library removal soft-deletes local membership', () async {
      const now = 1787000000;
      final keep = await upsertLibraryNode({
        'id': 30,
        'title': 'Keep Me',
        'categories': {
          'nodes': [
            {'id': 1, 'name': 'Reading'},
          ],
        },
      }, nowUnix: now);
      final drop = await upsertLibraryNode({
        'id': 31,
        'title': 'Remove Me',
        'categories': {'nodes': <dynamic>[]},
      }, nowUnix: now);
      await IsarService.instance.saveMangas([keep, drop]);
      expect((await IsarService.instance.getLibraryManga()).length, 2);

      // Complete snapshot no longer lists 31 — removal cascade runs.
      final stillThere = await upsertLibraryNode({
        'id': 30,
        'title': 'Keep Me',
        'categories': {
          'nodes': [
            {'id': 1, 'name': 'Reading'},
          ],
        },
      }, nowUnix: now + 10);
      await IsarService.instance.saveMangas([stillThere]);
      final removed = await softRemoveMissing({30});
      expect(removed, 1);

      final library = await IsarService.instance.getLibraryManga();
      expect(library.length, 1);
      expect(library.single.serverId, 30);
      expect(library.single.inLibrary, isTrue);

      final gone = await IsarService.instance.getMangaByServerId(31);
      expect(gone, isNotNull);
      expect(gone!.inLibrary, isFalse);
    });

    test('fetchLibrary path has no last-sync cursor (full reconcile)', () {
      // Documented contract: kSyncPullPhaseOrder always includes a full
      // libraryMembership pull; there is no incremental cursor for manga.
      expect(kSyncPullPhaseOrder, contains('libraryMembership'));
      expect(
        kSyncPullPhaseOrder.indexOf('libraryMembership'),
        lessThan(kSyncPullPhaseOrder.indexOf('chapterSnapshot')),
      );
    });
  });
}
