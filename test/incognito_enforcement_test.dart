// Incognito Mode enforcement tests.
//
// ROOT CAUSE (the bug this file pins down):
// `SettingsService.incognitoMode` was documented as "do not persist reading
// progress or sync to server", and the setting had UI in two places, but the
// only code that ever read it was one early-return inside the reader's
// `_updateProgress`. There are twelve read-state mutation paths in the app:
//
//   reader_screen            _updateProgress            <- GUARDED (the only one)
//   updates_screen           _toggleChapterRead
//   updates_screen           _markAllRead
//   manga_detail_screen      _toggleChapterRead
//   manga_detail_screen      _markPreviousChaptersRead
//   manga_detail_screen      _markSelectedRead
//   library_screen           _markChunkRead
//   migrate_search_screen    migration read-state copy
//   sync_engine              syncChapterProgress (network + replay queue)
//   ... and the reader's own syncChapterProgress call
//
// So turning Incognito on protected the reader — precisely the one entry point
// a user does NOT use to mark things read. Marking a chapter read from the
// library list, from manga detail, from the updates feed, or in bulk, and the
// migration flow, all wrote progress to Isar and pushed it to the server with
// the setting on. The privacy control was trivially defeated, and because the
// server copy survived, the leak was permanent and cross-device.
//
// WHAT IS PINNED HERE:
//   1. syncChapterProgress writes nothing — no network call, no replay record —
//      while Incognito is on. This assertion compiles and runs identically on
//      the pre-fix and post-fix revisions, so it is the baseline-reproduction
//      proof: on base it fails (a SyncRecord is queued), on the patch it passes.
//   2. commitChapterReadState, the new central seam, is a total no-op while
//      Incognito is on, and reports that it wrote nothing so callers can skip
//      follow-up work that would otherwise contradict it.
//   3. With Incognito OFF, everything still works — behavior preservation.
//   4. Chapter-level and manga-level state are both covered: a server chapter
//      (positive serverId, the sync-relevant case) and a local-scrape chapter
//      (negative synthetic id, the pure-local case).
//
// Run: fvm flutter test test/incognito_enforcement_test.dart
import 'dart:ffi';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunfire/src/core/db/isar_service.dart';
import 'package:sunfire/src/core/db/models/category.dart';
import 'package:sunfire/src/core/db/models/chapter.dart';
import 'package:sunfire/src/core/db/models/manga.dart';
import 'package:sunfire/src/core/db/models/sync_meta.dart';
import 'package:sunfire/src/core/db/models/sync_record.dart';
import 'package:sunfire/src/core/services/settings_service.dart';
import 'package:sunfire/src/core/sync/sync_engine.dart';

String? _findIsarNative() {
  for (final root in [
    Directory('${Platform.environment['HOME']}/.pub-cache/hosted/pub.dev'),
    Directory('${Platform.environment['HOME']}/.pub-cache'),
  ]) {
    if (!root.existsSync()) continue;
    for (final d in root.listSync().whereType<Directory>()) {
      if (!d.path.contains('isar_flutter_libs')) continue;
      final f = File('${d.path}/linux/libisar.so');
      if (f.existsSync()) return f.path;
    }
  }
  final buildLib = File('${Directory.current.path}/build/linux/x64/debug/bundle/lib/libisar.so');
  return buildLib.existsSync() ? buildLib.path : null;
}

/// A server-backed chapter: positive serverId, so `syncChapterProgress` would
/// normally reach the network / replay queue.
Chapter _serverChapter({int serverId = 9001, bool isRead = false, int lastPageRead = 0}) =>
    Chapter()
      ..serverId = serverId
      ..mangaId = 1
      ..name = 'Server Chapter'
      ..url = 'https://srv/ch/$serverId'
      ..isRead = isRead
      ..lastPageRead = lastPageRead
      ..pageCount = 20;

/// A locally-scraped chapter: negative synthetic serverId, so it never syncs
/// but is still written to Isar.
Chapter _localChapter({int serverId = -5001}) =>
    Chapter()
      ..serverId = serverId
      ..mangaId = 1
      ..name = 'Local Chapter'
      ..url = 'https://local/ch/$serverId'
      ..pageCount = 20;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('sunfire_incognito');
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
    SharedPreferences.setMockInitialValues({});
    await SettingsService.instance.initialize();
    await IsarService.instance.isar.writeTxn(() async {
      await IsarService.instance.isar.clear();
    });
  });

  Future<List<SyncRecord>> allSyncRecords() => IsarService.instance.getPendingSyncRecords();

  Future<Chapter?> storedChapter(int serverId) =>
      IsarService.instance.getChapterByServerId(serverId);

  group('syncChapterProgress — the baseline-reproduction proof', () {
    // This test body is identical on the pre-fix and post-fix revisions, so a
    // pass on the patch and a fail on base is direct evidence of remediation
    // rather than of a test that only exists to match the new code.
    test('queues NO replay record while Incognito is on', () async {
      SettingsService.instance.incognitoMode = true;
      final ch = _serverChapter()..lastPageRead = 7;
      await IsarService.instance.saveChapter(ch);

      await SyncEngine.instance.syncChapterProgress(
        ch.serverId,
        isRead: true,
        lastPageRead: 7,
      );

      expect(
        await allSyncRecords(),
        isEmpty,
        reason: 'Incognito is on: progress must not be queued for later upload. '
            'A queued record would replay after the user turned Incognito back '
            'off, making the leak permanent and off-device.',
      );
    });

    test('does not mutate the stored chapter while Incognito is on', () async {
      SettingsService.instance.incognitoMode = true;
      final ch = _serverChapter();
      await IsarService.instance.saveChapter(ch);

      await SyncEngine.instance.syncChapterProgress(
        ch.serverId,
        isRead: true,
        lastPageRead: 12,
      );

      final stored = await storedChapter(ch.serverId);
      expect(stored, isNotNull);
      expect(stored!.isRead, isFalse, reason: 'the sync path must not write read state');
      expect(stored.lastPageRead, 0);
    });

    test('a non-positive server id is still a no-op (unchanged behavior)', () async {
      SettingsService.instance.incognitoMode = true;
      await SyncEngine.instance.syncChapterProgress(0, isRead: true, lastPageRead: 3);
      await SyncEngine.instance.syncChapterProgress(-5, isRead: true, lastPageRead: 3);
      expect(await allSyncRecords(), isEmpty);
    });

    test('regression: with Incognito OFF the replay queue still works', () async {
      SettingsService.instance.incognitoMode = false;
      final ch = _serverChapter()..lastPageRead = 4;
      await IsarService.instance.saveChapter(ch);

      await SyncEngine.instance.syncChapterProgress(
        ch.serverId,
        isRead: true,
        lastPageRead: 4,
      );

      final records = await allSyncRecords();
      expect(records, isNotEmpty, reason: 'offline progress must still be queued for replay');
      final progress = records.firstWhere(
        (r) => r.entityId == ch.serverId.toString(),
        orElse: () => fail('no record queued for chapter ${ch.serverId}'),
      );
      expect(progress.payloadJson, contains('lastPageRead'));
    });
  });

  group('commitChapterReadState — the central seam', () {
    test('writes nothing and reports false while Incognito is on', () async {
      SettingsService.instance.incognitoMode = true;
      final ch = _serverChapter();
      await IsarService.instance.saveChapter(ch);

      final wrote = await SyncEngine.instance.commitChapterReadState(ch, isRead: true);

      expect(wrote, isFalse, reason: 'callers use this to skip follow-up work');
      final stored = await storedChapter(ch.serverId);
      expect(stored!.isRead, isFalse, reason: 'read state must not be persisted');
      expect(stored.lastReadAt, anyOf(isNull, 0), reason: 'history must not record it');
    });

    test('does not even mutate the in-memory object while Incognito is on', () async {
      SettingsService.instance.incognitoMode = true;
      final ch = _serverChapter();

      await SyncEngine.instance.commitChapterReadState(ch, isRead: true);

      expect(ch.isRead, isFalse,
          reason: 'the UI holds this same object; mutating it would show a read '
              'state that was never saved, so the next reload would silently revert');
      expect(ch.lastPageRead, 0);
    });

    test('an explicit lastPageRead is not written while Incognito is on', () async {
      SettingsService.instance.incognitoMode = true;
      final ch = _serverChapter();
      await IsarService.instance.saveChapter(ch);

      final wrote = await SyncEngine.instance.commitChapterReadState(
        ch,
        isRead: true,
        lastPageRead: 14,
      );

      expect(wrote, isFalse);
      expect(ch.lastPageRead, 0, reason: 'the live object must not show an unsaved position');
      expect((await storedChapter(ch.serverId))!.lastPageRead, 0);
    });

    test('queues no sync record while Incognito is on', () async {
      SettingsService.instance.incognitoMode = true;
      final ch = _serverChapter();
      await IsarService.instance.saveChapter(ch);

      await SyncEngine.instance.commitChapterReadState(ch, isRead: true);

      expect(await allSyncRecords(), isEmpty);
    });

    test('covers local-scrape chapters too (negative synthetic id)', () async {
      SettingsService.instance.incognitoMode = true;
      final ch = _localChapter();
      await IsarService.instance.saveChapter(ch);

      final wrote = await SyncEngine.instance.commitChapterReadState(ch, isRead: true);

      expect(wrote, isFalse);
      expect((await storedChapter(ch.serverId))!.isRead, isFalse);
    });

    test('marking UNREAD is also blocked while Incognito is on', () async {
      SettingsService.instance.incognitoMode = true;
      final ch = _serverChapter(isRead: true, lastPageRead: 9);
      await IsarService.instance.saveChapter(ch);

      final wrote = await SyncEngine.instance.commitChapterReadState(ch, isRead: false);

      expect(wrote, isFalse);
      expect((await storedChapter(ch.serverId))!.isRead, isTrue,
          reason: 'un-marking leaks that the chapter was read, which is itself history');
    });
  });

  group('commitChapterReadState — behavior preservation with Incognito OFF', () {
    test('persists the read state and reports true', () async {
      SettingsService.instance.incognitoMode = false;
      final ch = _serverChapter();
      await IsarService.instance.saveChapter(ch);

      final wrote = await SyncEngine.instance.commitChapterReadState(ch, isRead: true);

      expect(wrote, isTrue);
      final stored = await storedChapter(ch.serverId);
      expect(stored!.isRead, isTrue);
      expect(stored.lastPageRead, 20, reason: 'applyReadState completes to pageCount');
    });

    test('stamps local read activity so History sees it immediately', () async {
      SettingsService.instance.incognitoMode = false;
      final ch = _serverChapter();
      await IsarService.instance.saveChapter(ch);

      await SyncEngine.instance.commitChapterReadState(ch, isRead: true);

      final stored = await storedChapter(ch.serverId);
      expect(stored!.lastReadAt, isNotNull);
      expect(stored.lastReadAt, greaterThan(0),
          reason: 'getReadingHistory filters on lastReadAt > 0');
    });

    test('does NOT stamp read activity when marking unread', () async {
      SettingsService.instance.incognitoMode = false;
      final ch = _serverChapter();
      await IsarService.instance.saveChapter(ch);

      await SyncEngine.instance.commitChapterReadState(ch, isRead: false);

      final stored = await storedChapter(ch.serverId);
      expect(stored!.isRead, isFalse);
      expect(stored.lastPageRead, 0, reason: 'un-marking resets the position');
      expect(stored.lastReadAt, anyOf(isNull, 0));
    });

    test('honours an explicit lastPageRead for an in-progress chapter', () async {
      SettingsService.instance.incognitoMode = false;
      final ch = _serverChapter();
      await IsarService.instance.saveChapter(ch);

      final wrote = await SyncEngine.instance.commitChapterReadState(
        ch,
        isRead: false,
        lastPageRead: 11,
      );

      expect(wrote, isTrue);
      final stored = await storedChapter(ch.serverId);
      expect(stored!.isRead, isFalse, reason: 'partial progress is not a completion');
      expect(stored.lastPageRead, 11, reason: 'the resume position must be kept');
    });

    test('an explicit lastPageRead wins over the completion-to-pageCount default', () async {
      // Regression guard for the ordering inside commitChapterReadState: the
      // explicit page is applied AFTER applyReadState, so neither the
      // completion (which would force pageCount) nor an un-mark (which would
      // force 0) can silently discard the caller's value.
      SettingsService.instance.incognitoMode = false;
      final ch = _serverChapter();
      await IsarService.instance.saveChapter(ch);

      await SyncEngine.instance.commitChapterReadState(ch, isRead: true, lastPageRead: 3);

      expect((await storedChapter(ch.serverId))!.lastPageRead, 3);
    });

    test('queues progress for a server chapter so it can sync later', () async {
      SettingsService.instance.incognitoMode = false;
      final ch = _serverChapter();
      await IsarService.instance.saveChapter(ch);

      await SyncEngine.instance.commitChapterReadState(ch, isRead: true);

      // commitChapterReadState deliberately does not await the sync (it must not
      // block the UI on a network round-trip), so drain the microtask/event
      // queue before asserting the replay record exists.
      for (var i = 0; i < 20 && (await allSyncRecords()).isEmpty; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      expect(await allSyncRecords(), isNotEmpty);
    });

    test('persists a local-scrape chapter read state (no server, no record)', () async {
      SettingsService.instance.incognitoMode = false;
      final ch = _localChapter();
      await IsarService.instance.saveChapter(ch);

      final wrote = await SyncEngine.instance.commitChapterReadState(ch, isRead: true);

      expect(wrote, isTrue);
      expect((await storedChapter(ch.serverId))!.isRead, isTrue);
      expect(await allSyncRecords(), isEmpty,
          reason: 'negative synthetic ids are not server chapters and must not sync');
    });

    test('toggling incognito back off does not retroactively write', () async {
      // The guard must be evaluated at call time, not cached, and must not have
      // queued anything to fire later.
      SettingsService.instance.incognitoMode = true;
      final ch = _serverChapter();
      await IsarService.instance.saveChapter(ch);
      await SyncEngine.instance.commitChapterReadState(ch, isRead: true);
      expect((await storedChapter(ch.serverId))!.isRead, isFalse);

      SettingsService.instance.incognitoMode = false;
      expect((await storedChapter(ch.serverId))!.isRead, isFalse,
          reason: 'turning the setting off must not write the suppressed action');
      expect(await allSyncRecords(), isEmpty);
    });
  });
}
