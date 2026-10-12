// T2.5 Integration test: progress sync + offline.
//
// Pins the offline reading flow end-to-end with a real Isar database:
//   1. Reading pages while offline persists progress locally (Isar).
//   2. Progress is queued as a SyncRecord for replay on reconnect.
//   3. Rapid page turns coalesce to a single record holding the max page.
//   4. Reaching the last page marks the chapter read.
//   5. Regressions (going back) are rejected without touching the store.
//
// Run: fvm flutter test test/reader/progress_sync_offline_test.dart
@Tags(['native'])
library;

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
import 'package:sunfire/src/core/metron/metron_service.dart';
import 'package:sunfire/src/core/services/settings_service.dart';
import 'package:sunfire/src/core/sync/offline_monitor.dart';
import 'package:sunfire/src/core/sync/sync_engine.dart';
import 'package:sunfire/src/features/reader/controller/position_manager.dart';

String? _findIsarNative() {
  // Same lookup as incognito_enforcement_test.dart: prefer
  // isar_community_flutter_libs, fall back to legacy isar_flutter_libs.
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

/// A server-backed chapter: positive serverId, so progress sync would
/// normally reach the network / replay queue.
Chapter _serverChapter({int serverId = 9101, bool isRead = false, int lastPageRead = 0}) =>
    Chapter()
      ..serverId = serverId
      ..mangaId = 11
      ..name = 'Offline Server Chapter'
      ..url = 'https://srv/ch/$serverId'
      ..isRead = isRead
      ..lastPageRead = lastPageRead
      ..pageCount = 20;

PositionManager _manager() => PositionManager(
      settings: SettingsService.instance,
      isarService: IsarService.instance,
      syncEngine: SyncEngine.instance,
      metronService: MetronService.instance,
    );

Future<List<SyncRecord>> _pendingRecords() =>
    IsarService.instance.getPendingSyncRecords();

/// Polls until [condition] holds or [timeout] elapses (for the unawaited
/// sync dispatch inside PositionManager.updateProgress).
Future<void> _eventually(
  Future<bool> Function() condition, {
  Duration timeout = const Duration(seconds: 10),
  String reason = 'condition not met in time',
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    if (await condition()) return;
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
  expect(await condition(), isTrue, reason: reason);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('sunfire_progress_offline');
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
    SettingsService.instance.incognitoMode = false;
    OfflineMonitor.instance.debugReset();
    await IsarService.instance.isar.writeTxn(() async {
      await IsarService.instance.isar.clear();
    });
  });

  tearDown(() => OfflineMonitor.instance.debugReset());

  group('progress persists locally while offline', () {
    test('page turn writes lastPageRead to Isar', () async {
      final ch = _serverChapter();
      await IsarService.instance.saveChapter(ch);

      final wrote = await _manager().updateProgress(
        chapterSnapshot: ch,
        totalPages: 20,
        page: 7,
      );

      expect(wrote, isTrue);
      final stored = await IsarService.instance.getChapterByServerId(ch.serverId);
      expect(stored, isNotNull);
      expect(stored!.lastPageRead, equals(7));
      expect(stored.pageCount, equals(20));
      expect(stored.isRead, isFalse);
    });

    test('reaching the last page marks the chapter read', () async {
      final ch = _serverChapter()..lastPageRead = 19;
      await IsarService.instance.saveChapter(ch);

      final wrote = await _manager().updateProgress(
        chapterSnapshot: ch,
        totalPages: 20,
        page: 20,
      );

      expect(wrote, isTrue);
      final stored = await IsarService.instance.getChapterByServerId(ch.serverId);
      expect(stored, isNotNull);
      expect(stored!.lastPageRead, equals(20));
      expect(stored.isRead, isTrue);
    });

    test('going back does not regress stored progress', () async {
      final ch = _serverChapter()..lastPageRead = 12;
      await IsarService.instance.saveChapter(ch);

      final wrote = await _manager().updateProgress(
        chapterSnapshot: ch,
        totalPages: 20,
        page: 4,
      );

      expect(wrote, isFalse);
      final stored = await IsarService.instance.getChapterByServerId(ch.serverId);
      expect(stored, isNotNull);
      expect(stored!.lastPageRead, equals(12));
    });

    test('page beyond the end clamps instead of overflowing', () async {
      final ch = _serverChapter();
      await IsarService.instance.saveChapter(ch);

      final wrote = await _manager().updateProgress(
        chapterSnapshot: ch,
        totalPages: 20,
        page: 99,
      );

      expect(wrote, isTrue);
      final stored = await IsarService.instance.getChapterByServerId(ch.serverId);
      expect(stored, isNotNull);
      expect(stored!.lastPageRead, equals(20));
      expect(stored.isRead, isTrue);
    });
  });

  group('progress is queued for replay while offline', () {
    test('offline page turn leaves a pending SyncRecord', () async {
      final ch = _serverChapter(serverId: 9201);
      await IsarService.instance.saveChapter(ch);

      await _manager().updateProgress(
        chapterSnapshot: ch,
        totalPages: 20,
        page: 5,
      );

      // The sync dispatch is unawaited: poll until the record lands.
      await _eventually(
        () async => (await _pendingRecords()).isNotEmpty,
        reason: 'offline progress must be queued for replay, otherwise it is lost',
      );

      final records = await _pendingRecords();
      expect(records, isNotEmpty);
      final payload = records.first.payloadJson;
      expect(payload, contains('9201'));
      expect(payload, contains('lastPageRead'));
    });

    test('rapid page turns coalesce to one record holding the max page', () async {
      final ch = _serverChapter(serverId: 9202);
      await IsarService.instance.saveChapter(ch);
      final manager = _manager();

      await manager.updateProgress(chapterSnapshot: ch, totalPages: 20, page: 3);
      await manager.updateProgress(chapterSnapshot: ch, totalPages: 20, page: 9);
      await manager.updateProgress(chapterSnapshot: ch, totalPages: 20, page: 6);

      await _eventually(
        () async => (await _pendingRecords()).isNotEmpty,
        reason: 'offline progress must be queued for replay',
      );
      // Give the coalescing writes a beat to settle.
      await Future<void>.delayed(const Duration(milliseconds: 300));

      final records = await _pendingRecords();
      final progressRecords =
          records.where((r) => r.payloadJson.contains('9202')).toList();
      expect(
        progressRecords.length,
        equals(1),
        reason: 'one record per chapter: only the final page matters on replay',
      );
      expect(progressRecords.first.payloadJson, contains('"lastPageRead":9'));
    });
  });

  group('offline state gates background work', () {
    test('three consecutive transport failures declare offline', () {
      final monitor = OfflineMonitor.instance;
      expect(monitor.isOffline, isFalse);
      monitor.reportTransportFailure();
      monitor.reportTransportFailure();
      expect(monitor.isOffline, isFalse);
      monitor.reportTransportFailure();
      expect(monitor.isOffline, isTrue);
    });

    test('a single success recovers immediately (fast return)', () {
      final monitor = OfflineMonitor.instance;
      monitor.reportTransportFailure();
      monitor.reportTransportFailure();
      monitor.reportTransportFailure();
      expect(monitor.isOffline, isTrue);
      monitor.reportTransportSuccess();
      expect(monitor.isOnline, isTrue);
      expect(monitor.consecutiveFailures, equals(0));
    });
  });
}
