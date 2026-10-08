// Batch accounting invariant: succeeded + failed == total at finish.
// Drives the real cancel/dismiss/delete/clear paths (no native downloads)
// against debug-seeded state and asserts the invariant after every step.
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunfire/src/core/services/download_manager_service.dart';

LocalDownloadTask _task(int id,
        {LocalDownloadStatus status = LocalDownloadStatus.queued}) =>
    LocalDownloadTask(
      chapterId: id,
      mangaId: 1,
      chapterName: 'Ch $id',
      mangaTitle: 'M',
      status: status,
    );

void _checkInvariant(DownloadManagerService mgr) {
  // Mid-run: every member is either counted or still pending.
  // At finish (no pending): succeeded + failed == total.
  final c = mgr.debugBatchCounters;
  final pending =
      c.members.where((id) => !c.accounted.contains(id)).length;
  expect(c.completed + c.failed + pending, c.total,
      reason:
          'completed(${c.completed}) + failed(${c.failed}) + pending($pending) != total(${c.total})');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DownloadManagerService mgr;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async => '/tmp/sunfire_batch_test',
    );
    mgr = DownloadManagerService.instance;
    mgr.debugSetBatchCounters(
        total: 0, completed: 0, failed: 0, counted: false,
        members: {}, accounted: {});
    mgr.debugSetTasksForTest([]);
    await mgr.debugClearBatchState();
  });

  tearDown(() async {
    mgr.debugSetBatchCounters(
        total: 0, completed: 0, failed: 0, counted: false,
        members: {}, accounted: {});
    mgr.debugSetTasksForTest([]);
    await mgr.debugClearBatchState();
  });

  test('cancel/dismiss/delete/clear keep succeeded + failed == total', () async {
    // Batch of 5, all members.
    mgr.debugSetTasksForTest([_task(1), _task(2), _task(3), _task(4), _task(5)]);
    mgr.debugSetBatchCounters(
        total: 5, completed: 0, failed: 0, counted: true,
        members: {1, 2, 3, 4, 5}, accounted: {});
    _checkInvariant(mgr);

    // Cancel one: exactly one failure, total untouched.
    mgr.cancelLocalDownload(1);
    var c = mgr.debugBatchCounters;
    expect(c.failed, 1);
    expect(c.total, 5);
    _checkInvariant(mgr);

    // Cancel twice: still exactly one failure.
    mgr.cancelLocalDownload(1);
    expect(mgr.debugBatchCounters.failed, 1);
    _checkInvariant(mgr);

    // Dismiss the cancelled task: outcome forgotten, denominator shrinks.
    await mgr.dismissLocalTask(1);
    c = mgr.debugBatchCounters;
    expect(c.failed, 0);
    expect(c.total, 4);
    _checkInvariant(mgr);

    // Dismiss a stale pre-batch failure (never a member): untouched.
    mgr.debugSetTasksForTest([
      _task(2),
      _task(3),
      _task(4),
      _task(5),
      _task(99, status: LocalDownloadStatus.failed),
    ]);
    await mgr.dismissLocalTask(99);
    c = mgr.debugBatchCounters;
    expect(c.total, 4);
    expect(c.failed, 0);
    _checkInvariant(mgr);

    // Delete a queued member: denominator shrinks, no outcome invented.
    await mgr.deleteLocalDownload(2);
    c = mgr.debugBatchCounters;
    expect(c.total, 3);
    expect(c.failed, 0);
    _checkInvariant(mgr);
  });

  test('persisted counters round-trip with membership sets', () async {
    mgr.debugSetBatchCounters(
        total: 4, completed: 2, failed: 1, counted: true,
        members: {1, 2, 3, 4}, accounted: {1, 2, 3});
    await mgr.debugSaveBatchState();
    mgr.debugSetBatchCounters(
        total: 0, completed: 0, failed: 0, counted: false,
        members: {}, accounted: {});
    await mgr.debugLoadBatchState();
    final c = mgr.debugBatchCounters;
    expect(c.total, 4);
    expect(c.completed, 2);
    expect(c.failed, 1);
    expect(c.counted, isTrue);
    expect(c.members, {1, 2, 3, 4});
    expect(c.accounted, {1, 2, 3});
  });
}
