// ISS-050 / ISS-051: onboarding → first pull must import every server manga,
// and a follow-up sync must pick up newly added library items. Updates feed
// stamps must survive the chapter snapshot (UIX-05 fetchedAt=0 for backlog).
//
// Run: flutter test --timeout 60s test/onboarding_initial_sync_test.dart
@Tags(['native'])
library;

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

/// Mirrors the library-membership write `_performFullSync` does for each
/// `fetchLibrary` node (inLibrary=true + serverId), without GraphQL.
Manga mangaFromLibraryNode(Map<String, dynamic> node, {required int nowUnix}) {
  final serverId = node['id'] as int;
  final manga = Manga()
    ..serverId = serverId
    ..title = node['title']?.toString() ?? 'Untitled'
    ..inLibrary = true
    ..unreadCount = (node['unreadCount'] as num?)?.toInt() ?? 0
    ..lastFetchedAt = nowUnix
    ..inLibraryAt = nowUnix
    ..sourceName = (node['source'] is Map)
        ? ((node['source'] as Map)['name']?.toString() ?? 'Unknown')
        : 'Unknown'
    ..url = node['url']?.toString() ?? '';
  return manga;
}


void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('kSyncPullPhaseOrder (ISS-050/051)', () {
    test('library membership and updates land before chapter snapshot + source replication', () {
      expect(kSyncPullPhaseOrder.first, 'categories');
      expect(
        kSyncPullPhaseOrder.indexOf('libraryMembership'),
        lessThan(kSyncPullPhaseOrder.indexOf('sourceReplication')),
      );
      expect(
        kSyncPullPhaseOrder.indexOf('recentUpdates'),
        lessThan(kSyncPullPhaseOrder.indexOf('chapterSnapshot')),
      );
      expect(
        kSyncPullPhaseOrder.indexOf('libraryMembership'),
        lessThan(kSyncPullPhaseOrder.indexOf('recentUpdates')),
      );
    });
  });

  group('SyncCycleGate (dropped follow-up syncs)', () {
    test('a call while busy queues exactly one follow-up pass', () {
      final gate = SyncCycleGate();
      expect(gate.tryBegin(), isTrue);
      expect(gate.tryBegin(), isFalse);
      expect(gate.queued, isTrue);
      // Further calls while busy stay one-deep (still queued, not a counter).
      expect(gate.tryBegin(), isFalse);
      expect(gate.queued, isTrue);

      gate.beginPass();
      expect(gate.queued, isFalse);
      // A caller during the pass re-queues.
      expect(gate.tryBegin(), isFalse);
      expect(gate.needsAnotherPass(), isTrue);

      gate.beginPass();
      expect(gate.needsAnotherPass(), isFalse);
      gate.end();
      expect(gate.isSyncing, isFalse);
      expect(gate.tryBegin(), isTrue);
    });
  });

  group('Updates stamp survives snapshot (ISS-051 / UIX-05)', () {
    test('server fetchedAt applied before snapshot is kept on re-merge', () {
      final manga = Manga()
        ..serverId = 42
        ..title = 'Series';

      // Updates path creates the chapter first with a real server fetchedAt.
      final ch = Chapter()..serverId = 9001;
      expect(ch.id, Isar.autoIncrement);
      applyServerFetchedAt(ch, 1786805000000); // millis from server
      expect(ch.fetchedAt, 1786805000);

      // Simulate Isar assign after save (no longer autoIncrement).
      ch.id = 55;

      // Later chapter snapshot must NOT wipe the Updates stamp.
      mergeSnapshotChapterNode(
        ch,
        {
          'id': 9001,
          'name': 'Chapter 1',
          'chapterNumber': 1.0,
          'isRead': false,
          'lastPageRead': 0,
          'pageCount': 20,
        },
        manga: manga,
        hasPendingMutation: false,
      );
      expect(ch.fetchedAt, 1786805000);
    });

    test('brand-new snapshot-only chapter stays out of Updates feed', () {
      final manga = Manga()
        ..serverId = 42
        ..title = 'Series';
      final ch = Chapter()..serverId = 9002;
      mergeSnapshotChapterNode(
        ch,
        {
          'id': 9002,
          'name': 'Chapter 2',
          'chapterNumber': 2.0,
          'isRead': false,
          'lastPageRead': 0,
          'pageCount': 20,
        },
        manga: manga,
        hasPendingMutation: false,
      );
      expect(ch.fetchedAt, 0);
    });
  });

  group('Onboarding initial library import (Isar)', () {
    late Directory tempDir;

    setUpAll(() async {
      tempDir = await Directory.systemTemp.createTemp('sunfire_iss050_');
      final native = _findIsarNative();
      if (native == null) {
        fail('libisar.so not found — cannot run DB-backed ISS-050 tests');
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

    test('initial pull imports every server library manga into Isar', () async {
      const now = 1786900000;
      final serverNodes = [
        {'id': 1, 'title': 'One Piece', 'unreadCount': 3, 'url': '/op', 'source': {'name': 'Src'}},
        {'id': 2, 'title': 'Naruto', 'unreadCount': 0, 'url': '/naruto', 'source': {'name': 'Src'}},
        {'id': 3, 'title': 'Bleach', 'unreadCount': 1, 'url': '/bleach', 'source': {'name': 'Src'}},
      ];

      final mangas = [
        for (final n in serverNodes) mangaFromLibraryNode(n, nowUnix: now),
      ];
      await IsarService.instance.saveMangas(mangas);

      final library = await IsarService.instance.getLibraryManga();
      expect(library.length, 3);
      expect(library.map((m) => m.serverId).toSet(), {1, 2, 3});
      expect(library.every((m) => m.inLibrary), isTrue);
      expect(library.map((m) => m.title).toSet(), {'One Piece', 'Naruto', 'Bleach'});
    });

    test('incremental sync picks up newly added server manga', () async {
      const now = 1786900000;
      await IsarService.instance.saveMangas([
        mangaFromLibraryNode(
          {'id': 10, 'title': 'Old Title', 'unreadCount': 0, 'url': '/old', 'source': {'name': 'Src'}},
          nowUnix: now,
        ),
      ]);
      expect((await IsarService.instance.getLibraryManga()).length, 1);

      // Second pull (queued follow-up / later triggerSync) returns the old
      // title plus a newly added one — same upsert path as _performFullSync.
      await IsarService.instance.saveMangas([
        mangaFromLibraryNode(
          {'id': 10, 'title': 'Old Title', 'unreadCount': 0, 'url': '/old', 'source': {'name': 'Src'}},
          nowUnix: now + 60,
        ),
        mangaFromLibraryNode(
          {'id': 11, 'title': 'Brand New', 'unreadCount': 2, 'url': '/new', 'source': {'name': 'Src'}},
          nowUnix: now + 60,
        ),
      ]);

      final library = await IsarService.instance.getLibraryManga();
      expect(library.length, 2);
      expect(library.map((m) => m.serverId).toSet(), {10, 11});
      expect(library.map((m) => m.title).toSet(), {'Old Title', 'Brand New'});
    });

    test('recent-update chapters with fetchedAt>0 appear in getRecentChapters', () async {
      const now = 1786900000;
      await IsarService.instance.saveMangas([
        mangaFromLibraryNode(
          {'id': 42, 'title': 'Feed Series', 'unreadCount': 1, 'url': '/feed', 'source': {'name': 'Src'}},
          nowUnix: now,
        ),
      ]);

      final stamped = Chapter()
        ..serverId = 5001
        ..mangaId = 42
        ..name = 'New Chapter'
        ..chapterNumber = 10
        ..mangaTitle = 'Feed Series';
      // fetchedAt well after inLibraryAt so ISS-054 import filter does not drop it.
      applyServerFetchedAt(stamped, now + 3600);
      expect(stamped.fetchedAt, now + 3600);
      await IsarService.instance.saveChapters([stamped]);

      final backlog = Chapter()
        ..serverId = 5000
        ..mangaId = 42
        ..name = 'Old Chapter'
        ..chapterNumber = 1
        ..mangaTitle = 'Feed Series'
        ..fetchedAt = 0;
      await IsarService.instance.saveChapters([backlog]);

      final recent = await IsarService.instance.getRecentChapters(limit: 50);
      expect(recent.map((c) => c.serverId), contains(5001));
      expect(recent.map((c) => c.serverId), isNot(contains(5000)));
    });
  });
}
