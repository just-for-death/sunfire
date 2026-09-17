import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunfire/src/core/db/models/sync_record.dart';
import 'package:sunfire/src/core/engine/content_resolver_service.dart';
import 'package:sunfire/src/core/services/download_manager_service.dart';
import 'package:sunfire/src/core/services/settings_service.dart';
import 'package:sunfire/src/core/sync/sync_engine.dart';

/// Regression tests for the v1.5 deep-audit hardening pass:
/// relative-URL resolution, offline category→assign remap, the Date Format
/// setting actually formatting dates, and explicit download-pause persistence.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ContentResolverService.resolveRelativeUrl', () {
    test('base with trailing slash + path with leading slash → single slash', () {
      expect(
        ContentResolverService.resolveRelativeUrl('https://host/', '/api/v1/page/1'),
        'https://host/api/v1/page/1',
      );
    });

    test('base without trailing slash + leading-slash path', () {
      expect(
        ContentResolverService.resolveRelativeUrl('https://host', '/chapter/5/page/2'),
        'https://host/chapter/5/page/2',
      );
    });

    test('bare relative path resolves against base path', () {
      expect(
        ContentResolverService.resolveRelativeUrl('https://host/manga/1', 'pages/2.jpg'),
        'https://host/manga/pages/2.jpg',
      );
    });

    test('absolhttp(s) URLs pass through untouched', () {
      expect(
        ContentResolverService.resolveRelativeUrl('https://host/', 'https://cdn.example/x.jpg'),
        'https://cdn.example/x.jpg',
      );
    });

    test('data:/asset: schemes (scheme:path) pass through', () {
      expect(
        ContentResolverService.resolveRelativeUrl('https://host/', 'data:image/png;base64,AAAA'),
        'data:image/png;base64,AAAA',
      );
    });

    test('empty base returns the path unchanged', () {
      expect(ContentResolverService.resolveRelativeUrl('', '/api/x'), '/api/x');
    });

    test('malformed base falls back to naive concat instead of crashing', () {
      expect(ContentResolverService.resolveRelativeUrl('not a url', '/api/x'), 'not a url/api/x');
    });
  });

  group('SyncEngine.remapOfflineAssignRecords', () {
    SyncRecord assignRecord(int mangaId, List<int> categoryIds) {
      return SyncRecord()
        ..entityType = SyncEntityType.category
        ..action = SyncAction.update
        ..payloadJson = jsonEncode({
          'op': 'assign',
          'mangaId': mangaId,
          'categoryIds': categoryIds,
        });
    }

    test('assign payload referencing the temp id is rewritten to the remote id', () {
      final rec = assignRecord(7, [1, 42]);
      final changed = SyncEngine.remapOfflineAssignRecords(
        records: [rec],
        localServerId: 42,
        remoteId: 500,
      );
      expect(changed, hasLength(1));
      final payload = jsonDecode(rec.payloadJson) as Map<String, dynamic>;
      expect(payload['categoryIds'], [1, 500]);
    });

    test('assign payload without the temp id is left untouched', () {
      final rec = assignRecord(7, [1, 2]);
      final changed = SyncEngine.remapOfflineAssignRecords(
        records: [rec],
        localServerId: 42,
        remoteId: 500,
      );
      expect(changed, isEmpty);
      expect(jsonDecode(rec.payloadJson) as Map<String, dynamic>, containsPair('categoryIds', [1, 2]));
    });

    test('create/rename records and non-category records are never rewritten', () {
      final create = SyncRecord()
        ..entityType = SyncEntityType.category
        ..action = SyncAction.create
        ..payloadJson = jsonEncode({'op': 'create', 'name': 'Reading', 'localServerId': 42});
      final rename = SyncRecord()
        ..entityType = SyncEntityType.category
        ..action = SyncAction.update
        ..payloadJson = jsonEncode({'op': 'rename', 'categoryId': 42, 'name': 'New'});
      final chapter = SyncRecord()
        ..entityType = SyncEntityType.chapter
        ..action = SyncAction.update
        ..payloadJson = jsonEncode({'chapterId': 9, 'isRead': true});
      final changed = SyncEngine.remapOfflineAssignRecords(
        records: [create, rename, chapter],
        localServerId: 42,
        remoteId: 500,
      );
      expect(changed, isEmpty);
      expect((jsonDecode(create.payloadJson) as Map<String, dynamic>)['localServerId'], 42);
      expect((jsonDecode(rename.payloadJson) as Map<String, dynamic>)['categoryId'], 42);
    });

    test('single create→assign chain where assign is created after the create', () {
      // The exact scenario from the audit: a category created and then
      // assigned offline. Both flush in the same run; the assign must survive
      // the create's temp-id remap.
      final create = SyncRecord()
        ..entityType = SyncEntityType.category
        ..action = SyncAction.create
        ..timestamp = 1000
        ..payloadJson = jsonEncode({'op': 'create', 'name': 'Reading', 'localServerId': 42});
      final assign = assignRecord(7, [42]);
      final changed = SyncEngine.remapOfflineAssignRecords(
        records: [
          create,
          assign,
        ],
        localServerId: 42,
        remoteId: 500,
      );
      expect(changed, hasLength(1));
      expect((jsonDecode(assign.payloadJson) as Map<String, dynamic>)['categoryIds'], [500]);
    });
  });

  group('SettingsService.dateFormat wiring', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await SettingsService.instance.initialize();
    });

    test('default format is YYYY-MM-DD', () {
      expect(SettingsService.instance.formatDate(DateTime(2026, 9, 17)), '2026-09-17');
    });

    test('DD/MM/YYYY option is honoured', () {
      SettingsService.instance.dateFormat = 'DD/MM/YYYY';
      expect(SettingsService.instance.formatDate(DateTime(2026, 9, 17)), '17/09/2026');
    });

    test('MM/DD/YYYY option is honoured', () {
      SettingsService.instance.dateFormat = 'MM/DD/YYYY';
      expect(SettingsService.instance.formatDate(DateTime(2026, 9, 17)), '09/17/2026');
    });

    test('DD.MM.YYYY option is honoured', () {
      SettingsService.instance.dateFormat = 'DD.MM.YYYY';
      expect(SettingsService.instance.formatDate(DateTime(2026, 9, 17)), '17.09.2026');
    });
  });

  group('DownloadManagerService queue pause persistence', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final mgr = DownloadManagerService.instance;
      await mgr.resumeLocalQueue();
    });

    test('explicit pause is persisted and survives foreground events', () async {
      final mgr = DownloadManagerService.instance;
      expect(mgr.isQueuePaused, isFalse);

      await mgr.pauseLocalQueue();
      expect(mgr.isQueuePaused, isTrue);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('sunfire_download_queue_v1_paused'), isTrue);

      // Foreground auto-resume must NOT override an explicit pause.
      mgr.resumeLocalQueueAfterForeground();
      expect(mgr.isQueuePaused, isTrue);
      expect(prefs.getBool('sunfire_download_queue_v1_paused'), isTrue);
    });

    test('explicit user resume clears the persisted pause', () async {
      final mgr = DownloadManagerService.instance;
      await mgr.pauseLocalQueue();
      await mgr.resumeLocalQueue();
      expect(mgr.isQueuePaused, isFalse);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('sunfire_download_queue_v1_paused'), isFalse);
    });
  });
}