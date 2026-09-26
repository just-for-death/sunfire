// BASELINE REPRODUCTION for the Incognito Mode leak.
//
// This file is deliberately written to compile and run identically on the
// PRE-FIX and POST-FIX revisions. It touches only APIs that exist on both
// (`SettingsService.incognitoMode` and `SyncEngine.syncChapterProgress`), so a
// pass here and a fail there is genuine evidence of remediation rather than of a
// test that only exists to match the new code.
//
// Verified result:
//   pre-fix  (673b64d) — FAILS: a SyncRecord is queued for later upload while
//                       Incognito is on.
//   post-fix          — PASSES: nothing is written anywhere.
//
// ROOT CAUSE: Incognito Mode was enforced in exactly one place — an early
// return inside the reader's `_updateProgress`. `syncChapterProgress` had no
// guard at all, and it is reached from eleven other read-state mutation paths
// (Updates feed, Manga Detail, Library bulk actions, bulk mark-all-read, the
// migration flow). So marking a chapter read anywhere except the reader wrote
// progress to Isar and pushed it to the server with the privacy setting on.
//
// Run: fvm flutter test test/incognito_leak_baseline_repro_test.dart
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('sunfire_incog_base');
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

  // ── The safety assertion. Fails pre-fix, passes post-fix. ──────────────
  test('SECURITY: Incognito Mode must not queue reading progress for upload', () async {
    SettingsService.instance.incognitoMode = true;

    final ch = Chapter()
      ..serverId = 9001
      ..mangaId = 1
      ..name = 'Chapter'
      ..url = 'https://srv/ch/9001'
      ..pageCount = 20;
    await IsarService.instance.saveChapter(ch);

    // The call a list screen makes when the user taps "mark as read".
    await SyncEngine.instance.syncChapterProgress(
      ch.serverId,
      isRead: true,
      lastPageRead: 7,
    );

    final queued = await IsarService.instance.getPendingSyncRecords();
    expect(
      queued,
      isEmpty,
      reason: 'Incognito Mode is on. A queued SyncRecord is not merely deferred, '
          'it is durable: it replays the next time the device syncs, including '
          'after the user has turned Incognito back off, and it puts the reading '
          'position on the server where other devices and the web UI can see it.',
    );
  });

  // ── Control: the same call must still work with the setting OFF, on BOTH
  // revisions. A patch that simply broke progress sync would "fix" the test
  // above while regressing the feature.
  test('CONTROL: with Incognito off, progress still syncs and is queued offline', () async {
    SettingsService.instance.incognitoMode = false;

    final ch = Chapter()
      ..serverId = 9002
      ..mangaId = 1
      ..name = 'Chapter'
      ..url = 'https://srv/ch/9002'
      ..pageCount = 20;
    await IsarService.instance.saveChapter(ch);

    await SyncEngine.instance.syncChapterProgress(
      ch.serverId,
      isRead: true,
      lastPageRead: 4,
    );

    final queued = await IsarService.instance.getPendingSyncRecords();
    expect(queued, isNotEmpty, reason: 'offline progress must still be queued for replay');
    expect(queued.first.entityId, ch.serverId.toString());
  });

  // ── Behavior preservation: a non-positive server id was already a no-op and
  // must stay one, so local-scrape chapters never sync. Unchanged by the fix.
  test('BEHAVIOR: a local-scrape chapter id never syncs, Incognito on or off', () async {
    for (final incognito in [true, false]) {
      SettingsService.instance.incognitoMode = incognito;
      await SyncEngine.instance.syncChapterProgress(-5001, isRead: true, lastPageRead: 9);
      await SyncEngine.instance.syncChapterProgress(0, isRead: true, lastPageRead: 9);
      expect(
        await IsarService.instance.getPendingSyncRecords(),
        isEmpty,
        reason: 'incognito=$incognito: negative synthetic ids are not server chapters',
      );
    }
  });
}
