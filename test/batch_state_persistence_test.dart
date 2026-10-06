// UIX-24: _saveBatchState / _loadBatchState round-trip via SharedPreferences mock.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunfire/src/core/services/download_manager_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DownloadManagerService mgr;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    mgr = DownloadManagerService.instance;
    // Reset in-memory counters so tests don't leak across cases (singleton).
    mgr.debugSetBatchCounters(total: 0, completed: 0, failed: 0, counted: false);
    await mgr.debugClearBatchState();
  });

  tearDown(() async {
    mgr.debugSetBatchCounters(total: 0, completed: 0, failed: 0, counted: false);
    await mgr.debugClearBatchState();
  });

  test('save then load restores total/completed/failed/counted', () async {
    mgr.debugSetBatchCounters(total: 5, completed: 2, failed: 1, counted: true);
    await mgr.debugSaveBatchState();

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(DownloadManagerService.debugBatchStatePrefKey);
    expect(raw, isNotNull);
    final decoded = jsonDecode(raw!) as Map<String, dynamic>;
    expect(decoded['total'], 5);
    expect(decoded['completed'], 2);
    expect(decoded['failed'], 1);
    expect(decoded['counted'], isTrue);

    // Wipe memory, then reload from prefs.
    mgr.debugSetBatchCounters(total: 0, completed: 0, failed: 0, counted: false);
    expect(mgr.debugBatchCounters.total, 0);

    await mgr.debugLoadBatchState();
    final c = mgr.debugBatchCounters;
    expect(c.total, 5);
    expect(c.completed, 2);
    expect(c.failed, 1);
    expect(c.counted, isTrue);
  });

  test('load with empty prefs leaves counters unchanged (zeros)', () async {
    mgr.debugSetBatchCounters(total: 0, completed: 0, failed: 0, counted: false);
    await mgr.debugLoadBatchState();
    final c = mgr.debugBatchCounters;
    expect(c.total, 0);
    expect(c.completed, 0);
    expect(c.failed, 0);
    expect(c.counted, isFalse);
  });

  test('load recovers from a pre-seeded prefs JSON blob', () async {
    SharedPreferences.setMockInitialValues({
      DownloadManagerService.debugBatchStatePrefKey: jsonEncode({
        'total': 7,
        'completed': 3,
        'failed': 0,
        'counted': true,
      }),
    });
    // New getInstance() after setMockInitialValues resets the mock store.
    mgr.debugSetBatchCounters(total: 99, completed: 99, failed: 99, counted: false);
    await mgr.debugLoadBatchState();
    final c = mgr.debugBatchCounters;
    expect(c.total, 7);
    expect(c.completed, 3);
    expect(c.failed, 0);
    expect(c.counted, isTrue);
  });

  test('clear removes the prefs key', () async {
    mgr.debugSetBatchCounters(total: 2, completed: 1, failed: 0, counted: true);
    await mgr.debugSaveBatchState();
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey(DownloadManagerService.debugBatchStatePrefKey), isTrue);

    await mgr.debugClearBatchState();
    expect(prefs.containsKey(DownloadManagerService.debugBatchStatePrefKey), isFalse);
  });

  test('corrupt JSON does not throw and leaves counters alone', () async {
    SharedPreferences.setMockInitialValues({
      DownloadManagerService.debugBatchStatePrefKey: '{bad',
    });
    mgr.debugSetBatchCounters(total: 4, completed: 1, failed: 0, counted: true);
    await mgr.debugLoadBatchState(); // must not throw
    final c = mgr.debugBatchCounters;
    expect(c.total, 4);
    expect(c.completed, 1);
    expect(c.failed, 0);
    expect(c.counted, isTrue);
  });
}
