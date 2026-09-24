// DB-backed tests for the offline-category temp-id namespace and the server
// pull / delete flows that must not clobber (or leak) local-only categories.
//
// Run: fvm flutter test test/category_offline_sync_test.dart
import 'dart:convert';
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
  // 1) pub-cache hosted layout: .pub-cache/hosted/pub.dev/isar_flutter_libs-*/linux/libisar.so
  final hosted = Directory('${Platform.environment['HOME']}/.pub-cache/hosted/pub.dev');
  if (hosted.existsSync()) {
    for (final d in hosted.listSync().whereType<Directory>()) {
      if (d.path.contains('isar_flutter_libs')) {
        final f = File('${d.path}/linux/libisar.so');
        if (f.existsSync()) return f.path;
      }
    }
  }
  // 2) legacy flat pub-cache layout.
  final rootDir = Directory('${Platform.environment['HOME']}/.pub-cache');
  if (rootDir.existsSync()) {
    for (final d in rootDir.listSync().whereType<Directory>()) {
      if (d.path.contains('isar_flutter_libs')) {
        final f = File('${d.path}/linux/libisar.so');
        if (f.existsSync()) return f.path;
      }
    }
  }
  // 3) flutter test build output.
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
    tempDir = await Directory.systemTemp.createTemp('sunfire_category_test');
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
    // Blank slate per test (categories + sync queue).
    await IsarService.instance.isar.writeTxn(() async {
      await IsarService.instance.isar.categorys.clear();
      await IsarService.instance.isar.syncRecords.clear();
    });
  });

  Future<void> seedCategory(int serverId, String name) async {
    final cat = Category()
      ..serverId = serverId
      ..name = name;
    await IsarService.instance.saveCategory(cat);
  }

  Future<void> seedPendingCreate(int tempServerId, String name) async {
    final rec = SyncRecord()
      ..recordId = 'test-create-$tempServerId-${DateTime.now().microsecondsSinceEpoch}'
      ..entityType = SyncEntityType.category
      ..entityId = tempServerId.toString()
      ..action = SyncAction.create
      ..payloadJson = jsonEncode({'op': 'create', 'name': name, 'localServerId': tempServerId})
      ..timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000
      ..deviceId = 'test-device'
      ..state = SyncRecordState.pending;
    await IsarService.instance.saveSyncRecord(rec);
  }

  Future<void> seedPendingAssign(int mangaServerId, List<int> categoryIds) async {
    final rec = SyncRecord()
      ..recordId = 'test-assign-$mangaServerId-${DateTime.now().microsecondsSinceEpoch}'
      ..entityType = SyncEntityType.category
      ..entityId = 'manga_$mangaServerId'
      ..action = SyncAction.update
      ..payloadJson = jsonEncode({'op': 'assign', 'mangaId': mangaServerId, 'categoryIds': categoryIds})
      ..timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000
      ..deviceId = 'test-device'
      ..state = SyncRecordState.pending;
    await IsarService.instance.saveSyncRecord(rec);
  }

  group('synthetic category temp ids', () {
    test('are negative, classified, and unique', () {
      final a = IsarService.generateSyntheticServerId();
      final b = IsarService.generateSyntheticServerId();
      expect(IsarService.isSyntheticServerId(a), isTrue);
      expect(a, lessThan(0));
      expect(IsarService.isSyntheticServerId(42), isFalse);
      expect(b, isNot(a));
    });

    test('persist in the DB and never collide with real server ids', () async {
      await seedCategory(-12345, 'Offline Draft');
      await seedCategory(7, 'Server Category');
      final cats = await IsarService.instance.getCategories();
      final ids = cats.map((c) => c.serverId).toSet();
      expect(ids, containsAll([-12345, 7]));
    });
  });

  group('saveCategories replaceAll pull safety', () {
    test('preserves an offline synthetic-temp category that has a pending create', () async {
      final tempId = IsarService.generateSyntheticServerId();
      await seedCategory(tempId, 'Offline Draft');
      await seedPendingCreate(tempId, 'Offline Draft');

      // Simulate a server pull returning only real categories.
      await IsarService.instance.saveCategories([
        Category()..serverId = 100..name = 'Server Cat',
      ]);

      final cats = await IsarService.instance.getCategories();
      final ids = cats.map((c) => c.serverId).toSet();
      expect(ids, containsAll([tempId, 100]),
          reason: 'offline category with a queued create must survive a server pull');
    });

    test('preserves a legacy positive-epoch temp id that still has a pending create', () async {
      // Pre-namespace builds wrote DateTime.now().millisecondsSinceEpoch as the
      // temp id (positive). The pending-create protection must cover those too.
      final legacyTempId = DateTime.now().millisecondsSinceEpoch;
      await seedCategory(legacyTempId, 'Legacy Offline');
      await seedPendingCreate(legacyTempId, 'Legacy Offline');

      await IsarService.instance.saveCategories([
        Category()..serverId = 200..name = 'Server Cat',
      ]);

      final cats = await IsarService.instance.getCategories();
      final ids = cats.map((c) => c.serverId).toSet();
      expect(ids, contains(legacyTempId));
    });

    test('deletes a stale real category that is no longer on the server', () async {
      await seedCategory(300, 'Removed Server-Side');
      await seedCategory(400, 'Still On Server');

      await IsarService.instance.saveCategories([
        Category()..serverId = 400..name = 'Still On Server',
      ]);

      final cats = await IsarService.instance.getCategories();
      final ids = cats.map((c) => c.serverId).toSet();
      expect(ids, contains(400));
      expect(ids, isNot(contains(300)));
    });

    test('upserts server categories by serverId (rename reflected, no duplicate)', () async {
      await seedCategory(500, 'Old Name');

      await IsarService.instance.saveCategories([
        Category()..serverId = 500..name = 'New Name',
      ]);

      final cats = await IsarService.instance.getCategories();
      expect(cats.where((c) => c.serverId == 500).length, 1);
      expect(cats.firstWhere((c) => c.serverId == 500).name, 'New Name');
    });
  });

  group('syncCategoryDelete', () {
    test('cancels queued create + assign for a synthetic temp category (no server op)', () async {
      final tempId = IsarService.generateSyntheticServerId();
      await seedCategory(tempId, 'Draft');
      await seedPendingCreate(tempId, 'Draft');
      await seedPendingAssign(9001, [tempId, 5]);

      await SyncEngine.instance.syncCategoryDelete(tempId);

      final remaining = await IsarService.instance.getPendingCategoryRecords();
      expect(remaining, isEmpty,
          reason: 'deleting an offline category must cancel its queued create and assigns');
    });

    test('cancels a legacy pending create for a positive-epoch temp id', () async {
      final legacyTempId = DateTime.now().millisecondsSinceEpoch;
      await seedCategory(legacyTempId, 'Legacy Draft');
      await seedPendingCreate(legacyTempId, 'Legacy Draft');

      await SyncEngine.instance.syncCategoryDelete(legacyTempId);

      final remaining = await IsarService.instance.getPendingCategoryRecords();
      expect(remaining, isEmpty);
    });

    test('queues a server delete for a real category when offline', () async {
      await seedCategory(600, 'Real Category');

      await SyncEngine.instance.syncCategoryDelete(600);

      final remaining = await IsarService.instance.getPendingCategoryRecords();
      expect(remaining, hasLength(1));
      final rec = remaining.single;
      expect(rec.action, SyncAction.delete);
      expect(rec.entityId, '600');
    });
  });
}