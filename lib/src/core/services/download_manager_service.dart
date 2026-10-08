import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/app_constants.dart';
import '../db/isar_service.dart';
import '../engine/content_resolver_service.dart';
import '../engine/image_validation.dart';
import '../engine/javascript/m_client.dart';
import '../engine/quickjs_service.dart';
import '../logging/logger_service.dart';
import '../sync/download_foreground_task.dart';
import '../sync/graphql_client_service.dart';
import 'battery_state_service.dart';
import 'notification_service.dart';
import 'safe_curl.dart';
import 'server_tls_trust.dart';
import 'settings_service.dart';

enum LocalDownloadStatus { queued, downloading, completed, failed, paused }

class LocalDownloadTask {
  final int chapterId;
  final int mangaId;
  final String chapterName;
  final String mangaTitle;
  /// Reading-order number (e.g. 1 for chapter 1). Used to decide which queued
  /// chapter downloads next so a batch downloads 1, 2, 3… instead of 100, 99…
  final double chapterNumber;
  double progress; // 0.0 to 1.0
  LocalDownloadStatus status;
  String? error;
  /// The task's status BEFORE it was cancelled. Used by _unaccountRemoval
  /// when a cancelled task is later dismissed, so the correct counter bucket
  /// (completed vs failed) is decremented. Null when not cancelled.
  LocalDownloadStatus? statusBeforeCancel;

  LocalDownloadTask({
    required this.chapterId,
    required this.mangaId,
    required this.chapterName,
    required this.mangaTitle,
    this.chapterNumber = 0,
    this.progress = 0.0,
    this.status = LocalDownloadStatus.queued,
    this.error,
    this.statusBeforeCancel,
  });

  Map<String, dynamic> toJson() => {
    'chapterId': chapterId,
    'mangaId': mangaId,
    'chapterName': chapterName,
    'mangaTitle': mangaTitle,
    'chapterNumber': chapterNumber,
    'progress': progress,
    'status': status.name,
    'error': error,
    'statusBeforeCancel': statusBeforeCancel?.name,
  };

  factory LocalDownloadTask.fromJson(Map<String, dynamic> map) {
    final statusBeforeCancel = map['statusBeforeCancel'] != null
        ? LocalDownloadStatus.values.firstWhere(
            (e) => e.name == map['statusBeforeCancel'],
            orElse: () => LocalDownloadStatus.queued,
          )
        : null;
    return LocalDownloadTask(
      chapterId: map['chapterId'] as int,
      mangaId: map['mangaId'] as int,
      chapterName: map['chapterName'] as String? ?? '',
      mangaTitle: map['mangaTitle'] as String? ?? '',
      chapterNumber: (map['chapterNumber'] as num?)?.toDouble() ?? 0,
      progress: (map['progress'] as num?)?.toDouble() ?? 0.0,
      status: LocalDownloadStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => LocalDownloadStatus.queued,
      ),
      error: map['error'] as String?,
      statusBeforeCancel: statusBeforeCancel,
    );
  }
}

class DownloadManagerService extends ChangeNotifier {
  static final DownloadManagerService instance = DownloadManagerService._();
  DownloadManagerService._() {
    _configureDio();
    _initConnectivityListener();
    _initBatteryListener();
  }

  final List<LocalDownloadTask> _localTasks = [];
  final Set<int> _downloadedLocalChapterIds = {};
  final Set<int> _downloadedServerChapterIds = {};
  final Set<int> _downloadedServerMangaIds = {};
  final Set<int> _downloadedLocalMangaIds = {};
  final Map<int, CancelToken> _cancelTokens = {};
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  bool _isProcessingLocalQueue = false;
  // Bumped every time pauseLocalQueue() runs. Lets the in-flight download's
  // catch block tell "the network/parse genuinely failed" apart from "this
  // exception is just the pause's own token.cancel() unwinding" — even when
  // a quick resume has already reset the task's status back to `queued`
  // before that catch block gets to run (see resumeLocalQueue/pauseLocalQueue).
  int _pauseEpoch = 0;
  bool _waitingForCharger = false;

  /// True while the queue is idle solely because `downloadOnlyWhileCharging` is
  /// set and the device is unplugged. Exposed to the Downloads screen for a banner.
  bool get isWaitingForCharger => _waitingForCharger;
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(minutes: 2),
    followRedirects: true,
    maxRedirects: 5,
  ));

  void _initConnectivityListener() {
    try {
      _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
        final allowed = isNetworkAllowed(results);
        if (allowed && !_isQueuePaused && !_isProcessingLocalQueue && _localTasks.any((t) => t.status == LocalDownloadStatus.queued)) {
          unawaited(_processLocalQueue());
        } else if (!allowed && _localTasks.any((t) => t.status == LocalDownloadStatus.downloading)) {
          // A spontaneous handover (walking out of Wi-Fi range) must stop
          // in-flight work the same way toggling the setting does — otherwise
          // the rest of the chapter keeps downloading over mobile data until
          // the chapter boundary re-checks the gate. applyResourceGates
          // no-ops when the settings still allow the new network.
          unawaited(applyResourceGates());
        }
      });
    } catch (e) {
      debugPrint('[DownloadManager] Connectivity listener error: $e');
    }
  }

  StreamSubscription<BatteryState>? _batterySubscription;

  void _initBatteryListener() {
    try {
      _batterySubscription = BatteryStateService.instance.onBatteryStateChanged.listen((state) {
        final charging = state == BatteryState.charging || state == BatteryState.full;
        // Only resume from a charge-gate — an explicit user pause is never overridden.
        if (charging && !_isQueuePaused && !_isProcessingLocalQueue &&
            _localTasks.any((t) => t.status == LocalDownloadStatus.queued)) {
          unawaited(_processLocalQueue());
        } else if (!charging && _localTasks.any((t) => t.status == LocalDownloadStatus.downloading)) {
          // Unplugged mid-chapter with charge-only on: same treatment as the
          // network handover above (applyResourceGates no-ops if allowed).
          unawaited(applyResourceGates());
        }
      });
    } catch (e) {
      debugPrint('[DownloadManager] Battery listener error: $e');
    }
  }

  /// Test seam: overrides the real platform battery query.
  @visibleForTesting
  Future<bool> Function()? chargingProbe;

  Future<bool> _isCharging() async {
    if (chargingProbe != null) return chargingProbe!();
    return BatteryStateService.instance.isCharging();
  }

  void _configureDio() {
    try {
      if (_dio.httpClientAdapter is IOHttpClientAdapter) {
        // Shared trust rule (configured server host + loopback only; NO
        // blanket acceptance of LAN ranges) — see server_tls_trust.dart.
        (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient =
            () => createServerTrustingHttpClient(
              () => SettingsService.instance.serverUrl,
            );
      }
    } catch (ignoredError) { if (kDebugMode) debugPrint('[download_manager_service] ignored error: $ignoredError'); }
  }

  static const String _queuePrefKey = 'sunfire_download_queue_v1';

  /// Persisted batch state for completion notifications across interruptions.
  /// Contains: total, completed, failed, counted.
  static const String _batchStatePrefKey = 'sunfire_download_queue_v1_batch';

  List<LocalDownloadTask> get localTasks => List.unmodifiable(_localTasks);
  Set<int> get downloadedLocalChapterIds => _downloadedLocalChapterIds;
  Set<int> get downloadedServerChapterIds => _downloadedServerChapterIds;
  Set<int> get downloadedMangaIds => _downloadedLocalMangaIds;

  bool isNetworkAllowed(List<ConnectivityResult> results) {
    final hasConnection = results.any((r) => r != ConnectivityResult.none);
    if (!hasConnection) return false;

    if (SettingsService.instance.downloadOnlyOnWifi) {
      // When restricted to Wi-Fi, allow Wi-Fi, Ethernet, or VPN
      return results.contains(ConnectivityResult.wifi) ||
          results.contains(ConnectivityResult.ethernet) ||
          results.contains(ConnectivityResult.vpn);
    }
    // Full mobile data support: cellular, Wi-Fi, ethernet, and vpn are all allowed
    return true;
  }

  Future<bool> _checkNetworkAllowed() async {
    try {
      final results = await Connectivity().checkConnectivity();
      return isNetworkAllowed(results);
    } catch (e) {
      debugPrint('[DownloadManager] Network check error: $e');
      return true; // Fail-open for safety
    }
  }

  /// Serializes every queue-state write into a single chain.
  ///
  /// Callers run on different async stacks (the queue loop, pause, cancel,
  /// delete, dismiss, clear), and each did its own `getInstance()` +
  /// `setString()`. Two `setString` platform-channel round-trips could be in
  /// flight at once, and the snapshot is captured AFTER its own `await`, so
  /// emission order and capture order can differ. A write carrying
  /// `{status: "downloading"}` could therefore land AFTER one carrying
  /// `{status: "completed"}` — and on next launch the `downloading → queued`
  /// reconcile in `_loadQueueState` silently re-downloaded a chapter the user
  /// had already been told finished.
  ///
  /// Chaining through one future makes the writes strictly ordered, so the last
  /// state observed is the last state written.
  Future<void> _pendingSave = Future<void>.value();

  /// Separate chain for batch state persistence. Queue writes and batch writes
  /// are independent failure domains; coupling them on one chain meant a slow
  /// queue write could delay critical batch counter durability, and a queue
  /// write failure would block batch persistence.
  Future<void> _batchSaveChain = Future<void>.value();

  Future<void> _saveQueueState() {
    _pendingSave = _pendingSave.then((_) => _writeQueueState()).catchError((Object e) {
      debugPrint('[DownloadManager] Error saving queue state: $e');
    });
    return _pendingSave;
  }

  Future<void> _saveBatchState() {
    // Batch increments fire from several async stacks; serialization prevents
    // bare setStrings from landing out of order. Uses its own chain, independent
    // of the queue write chain.
    _batchSaveChain = _batchSaveChain.then((_) => _writeBatchState()).catchError((Object e) {
      debugPrint('[DownloadManager] Error saving batch state: $e');
    });
    return _batchSaveChain;
  }

  Future<void> _writeBatchState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_batchStatePrefKey, jsonEncode({
        'total': _batchTotal,
        'completed': _completedInBatch,
        'failed': _failedInBatch,
        'counted': _batchCounted,
        'members': _batchMembers.toList(),
        'accounted': _batchAccounted.toList(),
      }));
    } catch (e) {
      debugPrint('[DownloadManager] Error saving batch state: $e');
    }
  }

  Future<void> _loadBatchState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_batchStatePrefKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        _batchTotal = decoded['total'] as int? ?? 0;
        _completedInBatch = decoded['completed'] as int? ?? 0;
        _failedInBatch = decoded['failed'] as int? ?? 0;
        _batchCounted = decoded['counted'] as bool? ?? false;
        final membersRaw = decoded['members'];
        final accountedRaw = decoded['accounted'];
        // Validate list element types: reject malformed state rather than
        // silently filtering to empty sets (which would make the batch
        // uncountable with non-zero total).
        if (membersRaw is List && membersRaw.every((e) => e is int) &&
            accountedRaw is List && accountedRaw.every((e) => e is int)) {
          _batchMembers
            ..clear()
            ..addAll(membersRaw.cast<int>());
          _batchAccounted
            ..clear()
            ..addAll(accountedRaw.cast<int>());
        } else {
          debugPrint('[DownloadManager] Batch state has invalid members/accounted — resetting');
          _batchMembers.clear();
          _batchAccounted.clear();
          _batchCounted = false;
          _batchTotal = 0;
          _completedInBatch = 0;
          _failedInBatch = 0;
        }
        // Old persisted format (pre-members/accounted) loads _batchCounted=true
        // with empty member sets. This would permanently disable _beginBatch()
        // (guard: if (_batchCounted) return) and leave the batch uncounted.
        // If members is empty but counted=true, treat it as stale and reset.
        if (_batchCounted && _batchMembers.isEmpty) {
          _batchCounted = false;
          _batchTotal = 0;
          _completedInBatch = 0;
          _failedInBatch = 0;
        }
      }
    } catch (e) {
      debugPrint('[DownloadManager] Error loading batch state: $e');
    }
  }

  Future<void> _clearBatchState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_batchStatePrefKey);
    } catch (e) {
      debugPrint('[DownloadManager] Error clearing batch state: $e');
    }
  }

  /// Pref key used by [_saveBatchState]/[_loadBatchState] (UIX-24 tests).
  @visibleForTesting
  static const String debugBatchStatePrefKey = _batchStatePrefKey;

  /// Test seam: set in-memory batch counters without running the queue.
  @visibleForTesting
  void debugSetBatchCounters({
    required int total,
    required int completed,
    required int failed,
    required bool counted,
    Set<int>? members,
    Set<int>? accounted,
  }) {
    _batchTotal = total;
    _completedInBatch = completed;
    _failedInBatch = failed;
    _batchCounted = counted;
    if (members != null) {
      _batchMembers
        ..clear()
        ..addAll(members);
    }
    if (accounted != null) {
      _batchAccounted
        ..clear()
        ..addAll(accounted);
    }
  }

  /// Test seam: read current in-memory batch counters.
  @visibleForTesting
  ({int total, int completed, int failed, bool counted, Set<int> members, Set<int> accounted}) get debugBatchCounters => (
        total: _batchTotal,
        completed: _completedInBatch,
        failed: _failedInBatch,
        counted: _batchCounted,
        members: Set.of(_batchMembers),
        accounted: Set.of(_batchAccounted),
      );

  /// Test seam: replace the in-memory task list (drives cancel/dismiss/
  /// delete/clear paths without a running queue or native downloads).
  @visibleForTesting
  void debugSetTasksForTest(List<LocalDownloadTask> tasks) {
    _localTasks
      ..clear()
      ..addAll(tasks);
  }

  /// Test seam: persist current counters via [_saveBatchState].
  @visibleForTesting
  Future<void> debugSaveBatchState() => _saveBatchState();

  /// Test seam: restore counters via [_loadBatchState].
  @visibleForTesting
  Future<void> debugLoadBatchState() => _loadBatchState();

  /// Test seam: clear the prefs key via [_clearBatchState].
  @visibleForTesting
  Future<void> debugClearBatchState() => _clearBatchState();

  Future<void> _writeQueueState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _localTasks.map((t) => t.toJson()).toList();
      // The paused flag rides in the SAME atomic write as the tasks. It used
      // to live in a separate pref key written by a separate call, so a kill
      // between the two left tasks `paused` with the flag `false` (or vice
      // versa) and the next launch guessed wrong — resuming a queue the user
      // explicitly paused, or stalling one they resumed. One key = no window.
      // The standalone pref key is still maintained for legacy readers/tests.
      await prefs.setString(
        _queuePrefKey,
        jsonEncode({'v': 1, 'paused': _isQueuePaused, 'tasks': jsonList}),
      );
    } catch (e) {
      debugPrint('[DownloadManager] Error saving queue state: $e');
    }
  }

  Future<void> _loadQueueState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_queuePrefKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        // New shape: map with tasks + paused flag. Legacy shape: bare task
        // list (pre-atomic writes); the separate paused pref still applies.
        final List<dynamic> list;
        if (decoded is Map<String, dynamic>) {
          if (decoded['paused'] is bool) {
            _isQueuePaused = decoded['paused'] as bool;
          }
          final tasks = decoded['tasks'];
          list = tasks is List ? tasks : const [];
        } else if (decoded is List) {
          list = decoded;
        } else {
          return;
        }
        _localTasks.clear();
        for (final item in list) {
          if (item is Map<String, dynamic>) {
            final task = LocalDownloadTask.fromJson(item);
            // Any tasks interrupted mid-flight should reset to queued
            if (task.status == LocalDownloadStatus.downloading) {
              task.status = LocalDownloadStatus.queued;
            }
            _localTasks.add(task);
          }
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[DownloadManager] Error loading queue state: $e');
    }
  }

  bool _isQueuePaused = false;
  bool get isQueuePaused => _isQueuePaused;

  /// Re-evaluates the Wi-Fi and charging gates immediately.
  ///
  /// Both settings screens only acted on the DISABLE direction
  /// (`if (!v) resumeLocalQueue()`); turning a gate ON was a no-op until the
  /// running chapter happened to finish, because the gates are only re-read at
  /// the top of the queue loop. So enabling "Download only on Wi-Fi" while on
  /// cellular let the current chapter — up to ~12 minutes of Dio retry passes
  /// plus curl fallbacks — keep burning mobile data, with no way to stop it
  /// short of Pause.
  ///
  /// Cancels the in-flight token the way `pauseLocalQueue` does, but WITHOUT
  /// setting `_isQueuePaused`: the queue is gated, not user-paused, so it must
  /// still resume by itself when the resource returns.
  Future<void> applyResourceGates() async {
    if (_isQueuePaused) return;

    final networkAllowed = await _checkNetworkAllowed();
    final chargingOk = !BatteryStateService.shouldPauseForCharging(
      chargeOnlyEnabled: SettingsService.instance.downloadOnlyWhileCharging,
      isCharging: await _isCharging(),
    );

    if (networkAllowed && chargingOk) {
      // A gate was just relaxed — re-kick if work is waiting.
      if (!_isProcessingLocalQueue &&
          _localTasks.any((t) => t.status == LocalDownloadStatus.queued)) {
        _waitingForCharger = false;
        unawaited(_processLocalQueue());
      }
      return;
    }

    // A gate was just tightened: stop the in-flight chapter now.
    //
    // Bumping `_pauseEpoch` is essential, not incidental. The queue loop's
    // catch distinguishes "aborted on purpose" from "genuinely failed" purely
    // by comparing the epoch captured before the download. A Dio cancellation
    // surfaces as a `DioException`, so `task.error` is `e.toString()` and never
    // the literal 'Cancelled' — meaning without the bump this fell through to
    // the generic failure branch: the chapter was marked Failed, counted in
    // `_failedInBatch`, and `downloads/<id>/` was recursively DELETED. Toggling
    // a Wi-Fi/charging switch would destroy the chapter the user was midway
    // through, which is the opposite of what the gate is for.
    _pauseEpoch++;
    for (final task in _localTasks) {
      if (task.status == LocalDownloadStatus.downloading) {
        task.status = LocalDownloadStatus.queued;
      }
    }
    // Only set the charger banner when the CHARGER is the ONLY blocker.
    // If network is also disallowed, the banner should not say "waiting for charger".
    _waitingForCharger = !chargingOk && networkAllowed;
    for (final token in List<CancelToken>.from(_cancelTokens.values)) {
      try {
        token.cancel('Resource constraint enabled');
      } catch (e) {
        debugPrint('[DownloadManager] Token cancel error: $e');
      }
    }
    await _saveQueueState();
    notifyListeners();
  }

  // ── Batch tracking for background/notification reporting ────────────
  // Invariant (enforced by every path below): at batch finish,
  // succeeded + failed == total, where total = batch size at begin (+
  // mid-run enqueues, − member removals). Every member reaches exactly one
  // counted outcome: _batchMembers tracks who is in the denominator,
  // _batchAccounted tracks who already contributed to a numerator. Without
  // both sets, cancel/dismiss/delete/retry each adjusted a different subset
  // of counters and the summary reported e.g. "4 succeeded, 1 failed" of 4.
  int _batchTotal = 0;
  int _completedInBatch = 0;
  int _failedInBatch = 0;
  final Set<int> _batchMembers = {};
  final Set<int> _batchAccounted = {};
  bool _batchCounted = false;

  /// Refreshes the snapshot + notifier while the queue is processing so the
  /// background isolate never mistakes a long-running chapter for a dead
  /// main isolate (see [DownloadForegroundTask.isSnapshotStale]).
  Timer? _notifierHeartbeat;

  void _beginBatch() {
    if (_batchCounted) return;
    _batchCounted = true;
    // Count only tasks that will actually be attempted in this run (retryable
    // ones). Failed/cancelled leftovers from earlier runs are excluded.
    _batchMembers
      ..clear()
      ..addAll(_localTasks.where((t) =>
          t.status == LocalDownloadStatus.queued ||
          t.status == LocalDownloadStatus.paused ||
          t.status == LocalDownloadStatus.downloading).map((t) => t.chapterId));
    _batchAccounted.clear();
    _batchTotal = _batchMembers.length;
    _completedInBatch = 0;
    _failedInBatch = 0;
    unawaited(_saveBatchState());
  }

  /// Tasks a queue run will actually attempt (queued + paused + downloading).
  /// Extracted so tests can verify batch totals without a running queue.
  static int countRetryableTasks(List<LocalDownloadTask> tasks) {
    return tasks.where((t) =>
        t.status == LocalDownloadStatus.queued ||
        t.status == LocalDownloadStatus.paused ||
        t.status == LocalDownloadStatus.downloading).length;
  }

  void _purgeBatchCounters() {
    _batchTotal = 0;
    _completedInBatch = 0;
    _failedInBatch = 0;
    _batchCounted = false;
    _batchMembers.clear();
    _batchAccounted.clear();
    unawaited(_clearBatchState());
  }

  /// Counts one terminal outcome toward the batch summary, exactly once per
  /// member. Non-members (stale pre-batch rows) and already-counted members
  /// (cancel-then-dismiss) are ignored, which is what keeps
  /// succeeded + failed == total at finish.
  void _accountOutcome(LocalDownloadTask task, {required bool success}) {
    if (!_batchCounted) return;
    if (!_batchMembers.contains(task.chapterId)) return;
    if (_batchAccounted.add(task.chapterId)) {
      if (success) {
        _completedInBatch++;
      } else {
        _failedInBatch++;
      }
      unawaited(_saveBatchState());
    }
  }

  /// Removes a task from the denominator (dismiss/delete/clear). Undoes its
  /// numerator contribution if it had one. Must run BEFORE any status
  /// overwrite so the pre-removal status picks the right bucket.
  void _unaccountRemoval(LocalDownloadTask task) {
    if (!_batchCounted) return;
    // Not a denominator member (stale pre-batch row): touch nothing, or its
    // removal corrupts a total it was never part of.
    if (!_batchMembers.remove(task.chapterId)) return;
    if (_batchTotal > 0) _batchTotal--;
    if (_batchAccounted.remove(task.chapterId)) {
      // If the task was cancelled and later dismissed, use the status
      // BEFORE cancel to decide which bucket to decrement.
      final effectiveStatus = task.statusBeforeCancel ?? task.status;
      if (effectiveStatus == LocalDownloadStatus.completed) {
        if (_completedInBatch > 0) _completedInBatch--;
      } else {
        if (_failedInBatch > 0) _failedInBatch--;
      }
    }
    unawaited(_saveBatchState());
  }

  /// Reflects the current live queue in the Android foreground-service
  /// notification (and the iOS/desktop progress notification).
  Future<void> _refreshActiveNotifier() async {
    if (_isQueuePaused) {
      await _stopActiveNotifier();
      return;
    }
    final current = _localTasks.where((t) => t.status == LocalDownloadStatus.downloading).firstOrNull ??
        _localTasks.where((t) => t.status == LocalDownloadStatus.queued).firstOrNull;
    if (current == null) {
      await _stopActiveNotifier();
      return;
    }

    final title = current.mangaTitle.isEmpty ? 'Manga' : current.mangaTitle;
    final chapterLabel = current.chapterName.isEmpty ? 'Chapter' : current.chapterName;

    if (DownloadForegroundTask.isSupported && SettingsService.instance.backgroundDownloadsEnabled) {
      await DownloadForegroundTask.instance.update(
        mangaTitle: title,
        currentChapter: chapterLabel,
        completed: _completedInBatch,
        total: _batchTotal > 0 ? _batchTotal : _localTasks.length,
        active: true,
      );
    } else {
      // Non-Android platforms, AND Android when the user disabled background
      // downloads: fall back to the ongoing flutter_local_notifications
      // progress notification so there is always download feedback.
      await NotificationService.instance.showDownloadProgress(
        title: 'Downloading: $title',
        body: '$chapterLabel • $_completedInBatch/${_batchTotal > 0 ? _batchTotal : _localTasks.length} chapters',
        progress: _batchTotal > 0 ? _completedInBatch / _batchTotal : 0,
      );
    }
  }

  /// Stops the active notifier when there is nothing downloading: the Android
  /// foreground service, or — on non-Android AND Android-with-background-
  /// disabled — the fallback flutter_local_notifications progress
  /// notification (which otherwise lingers as a stale "Downloading…" card).
  Future<void> _stopActiveNotifier() async {
    if (DownloadForegroundTask.isSupported && SettingsService.instance.backgroundDownloadsEnabled) {
      await DownloadForegroundTask.instance.stop();
    } else {
      await NotificationService.instance.cancelDownloadProgressNotification();
    }
  }

  /// Public entry point used by the Settings toggle to drop the foreground
  /// service when background downloads are disabled mid-queue.
  void stopBackgroundNotifier() {
    if (DownloadForegroundTask.isSupported) {
      unawaited(DownloadForegroundTask.instance.stop());
    }
  }

  Future<void> pauseLocalQueue() async {
    _isQueuePaused = true;
    _pauseEpoch++;
    for (final token in _cancelTokens.values) {
      try {
        token.cancel('Queue paused');
      } catch (e) {
        debugPrint('[DownloadManager] Token cancel error: $e');
      }
    }
    _cancelTokens.clear();
    for (final task in _localTasks) {
      if (task.status == LocalDownloadStatus.downloading || task.status == LocalDownloadStatus.queued) {
        task.status = LocalDownloadStatus.paused;
      }
    }
    await _saveQueueState();
    await _stopActiveNotifier();
    notifyListeners();
  }

  Future<void> resumeLocalQueue() async {
    _isQueuePaused = false;
    _waitingForCharger = false;
    // Only reset EXPLICITLY paused tasks. A task that was `downloading`
    // when the app backgrounded is either still running (Android FGS) or
    // will fail and be retried by the queue loop. Resetting it to `queued`
    // here causes the Downloads screen to flash "Queued 0%" for a chapter
    // that is actually mid-download.
    for (final task in _localTasks) {
      if (task.status == LocalDownloadStatus.paused) {
        task.status = LocalDownloadStatus.queued;
      }
    }
    await _saveQueueState();
    if (!_isProcessingLocalQueue && _localTasks.any((t) => t.status == LocalDownloadStatus.queued)) {
      unawaited(_processLocalQueue());
    }
    notifyListeners();
  }

  /// Called when the app returns to the foreground. Unlike [resumeLocalQueue]
  /// (the explicit user/UI entry point), this never overrides an intentional
  /// pause: an explicitly paused queue stays paused until the user resumes it.
  void resumeLocalQueueAfterForeground() {
    if (_isQueuePaused) return;
    unawaited(resumeLocalQueue());
  }

  bool _interruptedByBackground = false;

  /// Pure predicate: a background transition only counts as an interruption when
  /// the queue was processing or a task was actively downloading.
  static bool backgroundInterruptsDownloads({
    required bool isProcessing,
    required bool hasActiveDownloads,
  }) => isProcessing || hasActiveDownloads;

  /// Marks the queue as interrupted when the app backgrounds while downloads
  /// are mid-flight. iOS/macOS suspend active transfers, so the foreground
  /// resume surfaces a notification instead of restarting silently.
  void noteAppBackgrounded() {
    _interruptedByBackground = backgroundInterruptsDownloads(
      isProcessing: _isProcessingLocalQueue,
      hasActiveDownloads: _localTasks.any((t) => t.status == LocalDownloadStatus.downloading),
    );
  }

  /// Consumes the background-interrupt marker, returning true when a resume
  /// should tell the user "downloads were paused in background — resumed".
  bool consumeBackgroundInterrupted() {
    final was = _interruptedByBackground;
    _interruptedByBackground = false;
    return was;
  }

  /// Test seam: force the background-interrupt marker without real tasks.
  @visibleForTesting
  void debugSetBackgroundInterrupted(bool value) => _interruptedByBackground = value;

  Future<void> initialize() async {
    await _loadQueueState();
    await _loadBatchState();
    await _migrateLegacyDownloadFolders();
    // NOTE: _loadQueuePausedFlag() is deliberately NOT called here.
    // The paused flag is now loaded atomically with the queue state in
    // _loadQueueState() (new v1 format with embedded `paused` field).
    // Calling the legacy loader afterward would overwrite the correct value
    // with a stale value from the old separate key on upgrade.
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey(_legacyLastFullScanPrefKey)) {
        await prefs.remove(_legacyLastFullScanPrefKey);
      }
    } catch (_) {
      // Best-effort cleanup of an unused key; never block initialization.
    }
    // Reconcile server download cache from local DB so the "Downloaded" filter
    // reflects the server's actual state (from last sync), not optimistic
    // enqueue markers that may have been queued but failed/404'd.
    await rebuildServerDownloadCache();
    // Reconcile a crashed resume: if the queue state says paused but NO tasks
    // are paused (all are queued/downloading), the process died mid-resume.
    // Trust the task states, clear the flag, and auto-resume.
    if (_isQueuePaused && !_localTasks.any((t) => t.status == LocalDownloadStatus.paused)) {
      debugPrint('[DownloadManager] Stale paused flag detected (tasks all queued/active) — reconciling');
      _isQueuePaused = false;
      await _saveQueueState();
    }
    // Auto-resume only when the user didn't explicitly pause the queue. A
    // paused queue must survive app restarts — otherwise Pause would only
    // last until the next launch.
    if (!_isQueuePaused) {
      await resumeLocalQueue();
    }

    // Deliberately LAST, and deliberately not awaited.
    //
    // `main.dart` awaits `initialize()` before `runApp`, so anything here is
    // paid on the UI isolate before the first frame. This scan validates every
    // page header of every downloaded chapter, which is ~8000 open/read/stat
    // round-trips for a 200-chapter library at 40 pages each — on EVERY cold
    // start, just to populate two id sets.
    //
    // It cannot be made cheaper without weakening the check. An earlier attempt
    // trusted the marker whenever the file count matched and no page was newer
    // than the marker, reasoning that the marker is only written after the pages
    // were verified. That reasoning is wrong: a page that was ALREADY invalid
    // when the marker was written — an older install predating the validator, or
    // content replaced externally — satisfies both cheap conditions and was
    // reported complete. `download_folder_validation_test.dart` exists because
    // that attempt passed review and shipped in the same commit that added it.
    //
    // So the check stays strict and the work moves off the critical path.
    //
    // Deferring is safe because the only consumers of the resulting id sets are
    // UI badges — the library's Downloaded filter, the chapter row icons, the
    // auto-download-ahead exclusion. Offline page resolution does NOT use them:
    // `ContentResolverService` validates the folder itself with the same
    // `isDownloadFolderComplete` call before trusting it, so a chapter tapped in
    // the first second still resolves from disk. The only visible effect of the
    // window is a badge that fills in once `notifyListeners()` fires at the end
    // of the scan — strictly better than a multi-second blank launch.
    //
    // Not awaited. `_scanDownloadedLocalChapters` reaches its first `await`
    // immediately, so this hands control straight back and the work interleaves
    // with the opening frames instead of preceding them.
    unawaited(_scanDownloadedLocalChapters());
  }

  /// One-time upgrade step for the completion-marker scheme. Folders written
  /// by earlier versions have no `.download_complete` marker, so without this
  /// every chapter the user already downloaded would suddenly stop being
  /// treated as downloaded (and the reader would go back online for it).
  ///
  /// Grandfather them once: a markerless numeric folder that contains at least
  /// one image and is NOT part of the persisted queue gets a marker holding its
  /// image count. From then on the strict rule applies to every new download.
  /// (A partial folder from before the upgrade is grandfathered too — that is
  /// exactly how it behaved before — and can be re-downloaded or deleted.)
  Future<void> _migrateLegacyDownloadFolders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      const doneKey = 'downloads_completion_marker_migrated_v1';
      if (prefs.getBool(doneKey) == true) return;
      final appDir = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory('${appDir.path}/downloads');
      if (await downloadsDir.exists()) {
        final queuedIds = _localTasks.map((t) => t.chapterId).toSet();
        await for (final entity in downloadsDir.list()) {
          if (entity is! Directory) continue;
          final segments = entity.uri.pathSegments.where((s) => s.isNotEmpty).toList();
          final id = segments.isEmpty ? null : int.tryParse(segments.last);
          if (id == null || queuedIds.contains(id)) continue;
          if (await isDownloadFolderComplete(entity)) continue;
          // Count with the SAME predicate the validator uses.
          //
          // This used to count by extension only, and the migration is behind a
          // one-shot flag, so a bad count was permanent for the install. Two
          // ways it disagreed with `isDownloadFolderComplete`:
          //  - the extension list omitted .avif and .jxl, which
          //    `kImagePageExtensions` accepts, so an AVIF chapter was
          //    undercounted and could never validate;
          //  - the validator also requires >500 bytes and a recognised magic
          //    header, so any truncated or pre-tightening page was counted here
          //    and rejected there.
          // Either way `validCount != markedCount` forever: the chapter silently
          // stopped registering as downloaded, the library "Downloaded" filter
          // dropped it, and the reader always went back online.
          var images = 0;
          await for (final f in entity.list()) {
            if (f is! File) continue;
            if (!isImagePagePath(f.path)) continue;
            if (await looksLikeImageFile(f)) images++;
          }
          if (images > 0) {
            await File('${entity.path}/$kDownloadCompleteMarkerName').writeAsString('$images');
          }
        }
      }
      await prefs.setBool(doneKey, true);
    } catch (e) {
      unawaited(LoggerService.instance.logError('Legacy download marker migration failed: $e', category: 'DownloaManager'));
    }
  }

  /// Pref written by a WIP "incremental" scan that only validated folders
  /// modified in the last 7 days on its periodic full scan, so older downloads
  /// lost their Downloaded badge. The scan is no longer time-windowed; the key
  /// is only removed once in [initialize].
  static const String _legacyLastFullScanPrefKey = 'sunfire_download_last_full_scan';

  /// Ids of every chapter folder directly under [downloadsDir] that passes
  /// [isDownloadFolderComplete], whatever its modification time.
  ///
  /// Only finished folders count — see kDownloadCompleteMarkerName. A folder
  /// left behind by a failed/killed/cancelled download has no marker and must
  /// not be reported as "downloaded" to the UI or reader.
  @visibleForTesting
  static Future<Set<int>> scanCompleteChapterFolders(Directory downloadsDir) async {
    final ids = <int>{};
    if (!await downloadsDir.exists()) return ids;
    await for (final entity in downloadsDir.list(followLinks: false)) {
      if (entity is! Directory) continue;
      final segments = entity.uri.pathSegments.where((s) => s.isNotEmpty).toList();
      final id = segments.isEmpty ? null : int.tryParse(segments.last);
      if (id != null && await isDownloadFolderComplete(entity)) {
        ids.add(id);
      }
    }
    return ids;
  }

  Future<void> _scanDownloadedLocalChapters() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory('${appDir.path}/downloads');
      final ids = await scanCompleteChapterFolders(downloadsDir);
      for (final id in ids) {
        _downloadedLocalChapterIds.add(id);
        final ch = await IsarService.instance.getChapterByServerId(id);
        if (ch != null && ch.mangaId > 0) {
          _downloadedLocalMangaIds.add(ch.mangaId);
          final m = await IsarService.instance.getMangaByServerId(ch.mangaId);
          if (m != null) {
            if (m.serverId > 0) _downloadedLocalMangaIds.add(m.serverId);
            _downloadedLocalMangaIds.add(m.id);
          }
        }
      }
      notifyListeners();
    } catch (e) {
      unawaited(LoggerService.instance.logError('_scanDownloadedLocalChapters error: $e', category: 'DownloaManager'));
    }
  }

  bool isChapterDownloadedLocally(int chapterId) => _downloadedLocalChapterIds.contains(chapterId);
  bool isChapterDownloadedOnServer(int chapterId) => _downloadedServerChapterIds.contains(chapterId);

  /// Manga (matching serverId / local-id conventions) that have at least one
  /// chapter downloaded on the Suwayomi server. Used by the library
  /// "Downloaded" filter — previously it only considered local downloads.
  Set<int> get downloadedServerMangaIds => Set.unmodifiable(_downloadedServerMangaIds);

  /// Rebuild [_downloadedServerMangaIds] from [_downloadedServerChapterIds] via
  /// the chapter → manga mapping. Called after every server-queue mutation so
  /// the derived set stays consistent with the chapter set.
  Future<void> _rebuildServerMangaIds() async {
    final mangaIds = <int>{};
    for (final cid in _downloadedServerChapterIds) {
      final ch = await IsarService.instance.getChapterByServerId(cid);
      if (ch == null) continue;
      mangaIds.add(ch.mangaId);
      final m = await IsarService.instance.getMangaByServerId(ch.mangaId);
      if (m != null) {
        if (m.serverId > 0) mangaIds.add(m.serverId);
        mangaIds.add(m.id);
      }
    }
    _downloadedServerMangaIds
      ..clear()
      ..addAll(mangaIds);
  }

  Future<void> markChapterDownloadedOnServer(int chapterId, bool isDownloaded) async {
    if (isDownloaded) {
      _downloadedServerChapterIds.add(chapterId);
    } else {
      _downloadedServerChapterIds.remove(chapterId);
    }
    // Keep the derived manga set consistent with the chapter set: the library
    // "Downloaded" filter reads downloadedServerMangaIds, so a mutation here
    // must be reflected there too or the filter misses titles.
    await _rebuildServerMangaIds();
    notifyListeners();
  }

  // ── LOCAL DEVICE DOWNLOAD QUEUE ────────────────────────────
  Future<void> enqueueLocalDownload({
    required int chapterId,
    required int mangaId,
    required String chapterName,
    required String mangaTitle,
    double chapterNumber = 0,
  }) async {
    if (_localTasks.any((t) => t.chapterId == chapterId && (t.status == LocalDownloadStatus.downloading || t.status == LocalDownloadStatus.queued))) {
      return;
    }

    final wasFailed =
        _localTasks.any((t) => t.chapterId == chapterId && t.status == LocalDownloadStatus.failed);
    final task = LocalDownloadTask(
      chapterId: chapterId,
      mangaId: mangaId,
      chapterName: chapterName,
      mangaTitle: mangaTitle,
      chapterNumber: chapterNumber,
    );
    _localTasks.removeWhere((t) => t.chapterId == chapterId);
    _localTasks.add(task);
    // Re-entering a failed member frees its slot for a recount (without
    // this, the accounted set would swallow the retry's outcome); a brand-new
    // item joins the denominator. A retry joins the denominator too (it's a
    // new attempt that will produce a counted outcome), so we add to members
    // and total just like a new item.
    if (_batchCounted) {
      if (wasFailed) {
        if (_batchAccounted.remove(chapterId) && _failedInBatch > 0) {
          _failedInBatch--;
        }
        // The retry is a new attempt — it joins the denominator and can
        // produce a new counted outcome.
        _batchMembers.add(chapterId);
        _batchTotal++;
      } else {
        _batchTotal++;
        _batchMembers.add(chapterId);
      }
      unawaited(_saveBatchState());
    }
    await _saveQueueState();
    notifyListeners();
unawaited(
    _processLocalQueue());
  }

  // Download in reading order: ascending chapter number, grouped by manga.
  // Source chapter lists are usually newest-first, so without this a batch of
  // chapters 1..100 would start at 100 and work backwards.
  static List<LocalDownloadTask> sortQueuedTasks(List<LocalDownloadTask> tasks) {
    final sorted = tasks.where((t) => t.status == LocalDownloadStatus.queued).toList();
    sorted.sort((a, b) {
      final byManga = a.mangaId.compareTo(b.mangaId);
      if (byManga != 0) return byManga;
      final byChapter = a.chapterNumber.compareTo(b.chapterNumber);
      // Deterministic tie-breaker (Dart's sort is unstable) so equal chapter
      // numbers (e.g. series with duplicate-numbered releases) still queue in
      // a stable, predictable order.
      if (byChapter != 0) return byChapter;
      return a.chapterId.compareTo(b.chapterId);
    });
    return sorted;
  }

  /// One download-queue run; its log lines share a correlation id (UIX-18).
  Future<void> _processLocalQueue() => LoggerService.withCorrelationAsync(_processLocalQueueImpl);

  Future<void> _processLocalQueueImpl() async {
    if (_isProcessingLocalQueue || _isQueuePaused) return;
    _isProcessingLocalQueue = true;
    _beginBatch();

    // Keep the FGS snapshot fresh during long per-chapter downloads so the
    // background isolate's staleness guard doesn't kill a healthy service.
    _notifierHeartbeat?.cancel();
    _notifierHeartbeat = Timer.periodic(DownloadForegroundTask.heartbeatInterval, (_) {
      unawaited(_refreshActiveNotifier());
    });

    var stoppedForNetwork = false;
    try {
      while (!_isQueuePaused) {
        // Queue emptiness is checked FIRST, before the resource gates.
        //
        // The gates used to run first, so a single dropped connectivity sample
        // arriving just after the last chapter completed set
        // `stoppedForNetwork = true` and broke out — and the `finally` branch
        // for that flag skipped `_finishBatch` (it also purged the batch
        // counters until UIX-15). A 40-chapter batch that fully succeeded reported
        // nothing, so the user re-ran it. Checking for work first means "no
        // work left" can never be misread as "blocked by a gate".
        final queued = sortQueuedTasks(_localTasks);
        if (queued.isEmpty) break;

        // Check network constraints (Wi-Fi only vs Mobile Data support)
        final networkAllowed = await _checkNetworkAllowed();
        if (!networkAllowed) {
          stoppedForNetwork = true;
          debugPrint('[DownloadManager] ⏸️ Pausing queue: Network condition not met (Wi-Fi only: ${SettingsService.instance.downloadOnlyOnWifi})');
          break;
        }

        // Charge-only gate: `downloadOnlyWhileCharging` pauses the queue when the
        // device is unplugged and resumes on plug-in (battery listener above).
        if (BatteryStateService.shouldPauseForCharging(
          chargeOnlyEnabled: SettingsService.instance.downloadOnlyWhileCharging,
          isCharging: await _isCharging(),
        )) {
          stoppedForNetwork = true;
          _waitingForCharger = true;
          debugPrint('[DownloadManager] ⏸️ Pausing queue: Waiting for charger (download while charging enabled)');
          break;
        }
        _waitingForCharger = false;

        // Download chapters in reading order (ascending chapter number) so a
        // batch of 1..100 starts at chapter 1, then 2, 3, … rather than the
        // source's newest-first order. Tasks are grouped by manga.
        final task = queued.first;
        final epochAtStart = _pauseEpoch;

        task.status = LocalDownloadStatus.downloading;
        task.error = null;
        await _saveQueueState();
        notifyListeners();
        await _refreshActiveNotifier();

        // Only the download itself lives inside the failure-handling `try`.
        //
        // The Isar bookkeeping below used to be inside it too, and an Isar
        // write can throw on its own (disk full, corrupt DB, schema error). At
        // that point `task.status` was already `completed`, so none of the
        // pause/cancel guards matched and control fell to the generic failure
        // branch — which incremented `_failedInBatch` (so the batch summary
        // counted one chapter as both succeeded and failed) and recursively
        // deleted `downloads/<id>/`, destroying a fully downloaded, verified,
        // marker-bearing chapter because a metadata write failed.
        //
        // A DB bookkeeping failure is now logged and does not touch the
        // download outcome, the batch counters, or the folder.
        try {
          await _downloadChapterLocally(task);
        } catch (e, stack) {
          if (_pauseEpoch != epochAtStart) {
            // The queue was paused (and possibly already resumed) while this
            // task was mid-flight, so `token.cancel()` unwinding here is
            // expected, not a real failure — even though a fast resume may
            // have already reset task.status to `queued` before we got here.
            // Restore whichever state is actually accurate now instead of
            // trusting the current task.status, so the chapter isn't lost
            // to a false "failed" and silently skipped by future batches.
            task.status = _isQueuePaused ? LocalDownloadStatus.paused : LocalDownloadStatus.queued;
            task.error = null;
          } else if (task.status == LocalDownloadStatus.paused) {
            // Retain paused state; do not overwrite with failed
          } else if (task.status == LocalDownloadStatus.failed && task.error == 'Cancelled') {
            // Retain cancelled state
          } else {
            task.status = LocalDownloadStatus.failed;
            task.error = e.toString();
            _accountOutcome(task, success: false);
            await LoggerService.instance.logError('Failed to download chapter ${task.chapterId}: $e', exception: e, stackTrace: stack, category: 'DownloadManager');
            // Clean up the partial download folder so it doesn't leak disk space.
            await _cleanupIncompleteDownload(task.chapterId);
          }
        }

        if (task.status == LocalDownloadStatus.paused || task.status == LocalDownloadStatus.failed) {
          // Task was paused or cancelled during execution; preserve its state.
        } else {
          task.status = LocalDownloadStatus.completed;
          task.progress = 1.0;
          _accountOutcome(task, success: true);
          _downloadedLocalChapterIds.add(task.chapterId);
          _downloadedLocalMangaIds.add(task.mangaId);
          // Bookkeeping only — never allowed to fail the download.
          try {
            final m = await IsarService.instance.getMangaByServerId(task.mangaId);
            if (m != null) {
              if (m.serverId > 0) _downloadedLocalMangaIds.add(m.serverId);
              _downloadedLocalMangaIds.add(m.id);
            }

            final ch = await IsarService.instance.getChapterByServerId(task.chapterId);
            if (ch != null) {
              ch.isDownloaded = true;
              await IsarService.instance.saveChapter(ch);
            }
          } catch (e, stack) {
            await LoggerService.instance.logError(
              'Chapter ${task.chapterId} downloaded but its Isar bookkeeping failed: $e',
              exception: e,
              stackTrace: stack,
              category: 'DownloadManager',
            );
          }
        }
        await _saveQueueState();
        notifyListeners();
        await _refreshActiveNotifier();
      }
    } finally {
      _isProcessingLocalQueue = false;
      _notifierHeartbeat?.cancel();
      _notifierHeartbeat = null;
      final pendingQueued =
          !_isQueuePaused && _localTasks.any((t) => t.status == LocalDownloadStatus.queued);
      if (_isQueuePaused || stoppedForNetwork) {
        // Interrupted (paused or waiting for connectivity/charger) — keep the
        // queue, drop the notifier, and don't report a finished batch. The
        // connectivity / battery listeners and resume handler restart processing.
        // Batch counters survive BOTH a user pause and a network/charger gate
        // (UIX-15, Jane decision): the queue resumes on its own, so a batch of
        // 5 interrupted after 2 still reports "5 of 5" when it finishes.
        await _stopActiveNotifier();
      } else if (pendingQueued) {
        // New items were enqueued while the loop was draining (rare race).
        // Re-enter so they are processed instead of left stranded.
        _waitingForCharger = false;
        unawaited(_processLocalQueue());
      } else {
        _waitingForCharger = false;
        await _finishBatch();
      }
      notifyListeners();
    }
  }

  Future<void> _finishBatch() async {
    if (!_batchCounted) {
      await _stopActiveNotifier();
      return;
    }
    final succeeded = _completedInBatch;
    final failed = _failedInBatch;
    final total = _batchTotal > 0 ? _batchTotal : (succeeded + failed);
    _purgeBatchCounters();
    await _stopActiveNotifier();
    if (total > 0) {
      await NotificationService.instance.showDownloadsCompleted(
        succeeded: succeeded,
        failed: failed,
        total: total,
      );
    }
  }

  Future<void> _downloadChapterLocally(LocalDownloadTask task) async {
    // Register the CancelToken FIRST, before the page-list resolve.
    //
    // It used to be created after `resolveChapterPages`, which can take ~20s
    // via an extension and up to 90s via GraphQL. For that whole window
    // `_cancelTokens` had no entry, so pauseLocalQueue, cancelLocalDownload,
    // deleteLocalDownload and dismissLocalTask all cancelled nothing. The
    // status guard did stop the download itself, but
    // `deleteLocalDownload` had already removed `downloads/<id>/` and the
    // resolve finished by recreating it — so a chapter the user deleted was
    // written to disk in full anyway. They believed they freed the space.
    final cancelToken = CancelToken();
    _cancelTokens[task.chapterId] = cancelToken;
    if (cancelToken.isCancelled) return;

    try {
      await _downloadChapterLocallyInner(task, cancelToken);
    } finally {
      _cancelTokens.remove(task.chapterId);
    }
  }

  Future<void> _downloadChapterLocallyInner(LocalDownloadTask task, CancelToken cancelToken) async {
    // 1. Resolve chapter pages via 3-Tier ContentResolver (supports local JS scrapers, downloads & server)
    final ch = await IsarService.instance.getChapterByServerId(task.chapterId);
    final manga = ch != null ? await IsarService.instance.getMangaByServerId(ch.mangaId) : null;
    final sourceName = manga?.sourceName;
    final chapterUrl = (ch?.url.isNotEmpty == true) ? ch!.url : ch?.realUrl;

    final resolved = await ContentResolverService.instance.resolveChapterPages(
      chapterServerId: task.chapterId,
      chapterUrl: chapterUrl,
      sourceName: sourceName,
      // Never resolve against our own downloads/<id>/ folder here — a
      // retry/resume must always get the real page list from the
      // extension/server, not whatever partial set of files a previous
      // failed attempt left behind.
      allowLocalDownload: false,
    );

    if (cancelToken.isCancelled) return;

    final rawPages = resolved.pageUrls;
    if (rawPages.isEmpty) {
      throw Exception('No pages found for chapter ${task.chapterName}');
    }

    final appDir = await getApplicationDocumentsDirectory();
    final chapterDir = Directory('${appDir.path}/downloads/${task.chapterId}');
    if (!await chapterDir.exists()) {
      await chapterDir.create(recursive: true);
    }

    try {
      final totalPages = rawPages.length;
      final effectiveSource = resolved.effectiveSourceName ?? sourceName ?? '';

      // Download pages with bounded concurrency instead of one-at-a-time.
      // Each page fetch is dominated by network round-trip latency, not CPU,
      // so running several in parallel cuts total chapter time roughly by the
      // concurrency factor (e.g. a 50-page chapter at ~1s/page sequentially
      // takes ~50s; at 5-way concurrency it takes closer to ~10s).
      const concurrency = 5;
      var completed = 0;
      for (var start = 0; start < totalPages; start += concurrency) {
        final end = (start + concurrency < totalPages) ? start + concurrency : totalPages;
        if (task.status == LocalDownloadStatus.failed || task.status == LocalDownloadStatus.paused || _isQueuePaused || cancelToken.isCancelled) {
          throw Exception('Cancelled or paused');
        }
        await Future.wait(List.generate(end - start, (offset) async {
          if (task.status == LocalDownloadStatus.failed || task.status == LocalDownloadStatus.paused || _isQueuePaused || cancelToken.isCancelled) return;
          final i = start + offset;
          await _downloadSinglePage(chapterDir, effectiveSource, rawPages[i], i, cancelToken: cancelToken);
          if (task.status == LocalDownloadStatus.failed || task.status == LocalDownloadStatus.paused || cancelToken.isCancelled) return;
          completed++;
          task.progress = completed / totalPages;
          notifyListeners();
        }));
      }
      // UIX-11: async listing + header-only probe. Reading every page in full
      // with `readAsBytesSync` on the UI isolate (tens of MB per chapter)
      // janked the UI during background downloads; the check only ever needed
      // the first bytes and the length.
      final existingFiles = await chapterDir
          .list()
          .where((e) => e is File && hasDownloadPageExtension(e.path))
          .cast<File>()
          .toList();
      // Validate each file is a real image, not just a file with the right
      // extension. A torn write or zero-byte placeholder would otherwise pass
      // the extension check and count toward the total.
      var validCount = 0;
      for (final f in existingFiles) {
        if (await looksLikeValidPageFile(f)) validCount++;
      }
      if (validCount < totalPages) {
        throw Exception('Incomplete download: only $validCount/$totalPages valid pages saved');
      }
      // Only now — with every page verified present — write the completion
      // marker. This is what the resolver/reader/startup scan check before
      // trusting this folder as "downloaded"; without it a partial folder
      // from this same failed/cancelled attempt would otherwise look
      // identical to a finished one on the next retry.
      //
      // The marker records what was actually MEASURED on disk, not
      // `totalPages`. The validator re-derives the count by enumerating every
      // image file in the folder, and this run supports resume — so the folder
      // can hold stale `page_0xx` files from a longer earlier download. Writing
      // `totalPages` while the folder holds more meant `validCount != markedCount`
      // forever: a fully downloaded, verified chapter was permanently
      // "not downloaded", dropped out of the library filter, and sent the
      // reader back online. Writing the measured count keeps the two in
      // agreement by construction.
      await File('${chapterDir.path}/$kDownloadCompleteMarkerName').writeAsString('$validCount');
    } finally {
      // `_cancelTokens` is owned and cleaned up by _downloadChapterLocally, so
      // that the entry is registered across the page-list resolve too.
    }
  }

  static bool _isValidImageBytes(List<int>? b) => looksLikeImageHeader(b);

  /// Page-file extensions counted by the completion check.
  @visibleForTesting
  static bool hasDownloadPageExtension(String path) {
    final name = path.toLowerCase();
    return name.endsWith('.jpg') ||
        name.endsWith('.jpeg') ||
        name.endsWith('.png') ||
        name.endsWith('.webp') ||
        name.endsWith('.gif') ||
        name.endsWith('.bmp');
  }

  /// Header-only, async validity probe for a saved page (UIX-11): the file
  /// must be larger than 500 bytes and start with a recognised image header.
  /// Same semantics as the old full read, which was also only a prefix probe
  /// (see `looksLikeImageHeader`), without loading the whole file.
  @visibleForTesting
  static Future<bool> looksLikeValidPageFile(File f) async {
    RandomAccessFile? raf;
    try {
      if (await f.length() <= 500) return false;
      raf = await f.open();
      return _isValidImageBytes(await raf.read(16));
    } catch (_) {
      return false; // Unreadable: don't count.
    } finally {
      try {
        await raf?.close();
      } catch (_) {}
    }
  }

  Future<void> _downloadSinglePage(
    Directory chapterDir,
    String effectiveSource,
    String pageUrl,
    int index, {
    CancelToken? cancelToken,
  }) async {
    if (cancelToken?.isCancelled == true) return;
    final file = File('${chapterDir.path}/page_${(index + 1).toString().padLeft(3, '0')}.jpg');
    // Sweep a partial write left by a kill. It is invisible to the completion
    // check (`.part` is not a page extension) and to the resume guard, so
    // without this it would sit in the folder forever, wasting disk.
    try {
      final stalePartial = File('${file.path}.part');
      if (await stalePartial.exists()) await stalePartial.delete();
    } catch (e) {
      debugPrint('[DownloadManager] Could not clear stale partial page: $e');
    }
    // Resume guard: accept an existing file ONLY if it is a valid, non-trivial
    // image. A truncated JPEG from a killed writeAsBytes would still start
    // with FF D8 and be > 500 bytes, so the old `length() > 500` check would
    // silently accept a half-page. Full validation here prevents that.
    if (await file.exists()) {
      if (await looksLikeValidPageFile(file)) {
        return;
      }
      // Corrupt/truncated — overwrite it.
      await file.delete();
    }
    final baseHeaders = QuickJsService.getImageHeaders(effectiveSource, pageUrl);
    final cookieHeaders = MClient.getCookiesPref(pageUrl);
    final headers = <String, dynamic>{
      ...baseHeaders,
      ...cookieHeaders,
      'User-Agent': MClient.userAgent,
    };
    List<int>? pageBytes;

    // Pass 1: Standard fetch
    try {
      final response = await _dio.get<List<int>>(
        pageUrl,
        cancelToken: cancelToken,
        options: Options(
          headers: headers,
          responseType: ResponseType.bytes,
        ),
      );
      if (_isValidImageBytes(response.data)) {
        pageBytes = response.data;
      } else {
        unawaited(LoggerService.instance.logWarning('Download pass 1 returned invalid bytes for $pageUrl', 'ownload'));
      }
    } catch (e) {
      unawaited(LoggerService.instance.logWarning('Download pass 1 (standard) failed for $pageUrl: $e', 'ownload'));
    }

    // Pass 2: Retry with Referer stripped (anti-hotlink bypass)
    if (pageBytes == null && headers.containsKey('Referer') && cancelToken?.isCancelled != true) {
      try {
        final noRef = Map<String, dynamic>.from(headers)..remove('Referer');
        final r2 = await _dio.get<List<int>>(
          pageUrl,
          cancelToken: cancelToken,
          options: Options(headers: noRef, responseType: ResponseType.bytes),
        );
        if (_isValidImageBytes(r2.data)) {
          pageBytes = r2.data;
        } else {
          unawaited(LoggerService.instance.logWarning('Download pass 2 returned invalid bytes for $pageUrl', 'ownload'));
        }
      } catch (e) {
        unawaited(LoggerService.instance.logWarning('Download pass 2 (no Referer) failed for $pageUrl: $e', 'ownload'));
      }
    }

    // Pass 3: Retry with Origin Referer
    if (pageBytes == null && cancelToken?.isCancelled != true) {
      try {
        final uri = Uri.parse(pageUrl);
        final originRef = Map<String, dynamic>.from(headers)..['Referer'] = '${uri.origin}/';
        final r3 = await _dio.get<List<int>>(
          pageUrl,
          cancelToken: cancelToken,
          options: Options(headers: originRef, responseType: ResponseType.bytes),
        );
        if (_isValidImageBytes(r3.data)) {
          pageBytes = r3.data;
        } else {
          unawaited(LoggerService.instance.logWarning('Download pass 3 returned invalid bytes for $pageUrl', 'ownload'));
        }
      } catch (e) {
        unawaited(LoggerService.instance.logWarning('Download pass 3 (origin Referer) failed for $pageUrl: $e', 'ownload'));
      }
    }

    // Pass 4: Clean Desktop Chrome User-Agent and Image Accept headers
    if (pageBytes == null && cancelToken?.isCancelled != true) {
      try {
        final browserHeaders = Map<String, dynamic>.from(headers)
          ..['User-Agent'] = kBrowserUserAgent
          ..['Accept'] = 'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8';
        final r4 = await _dio.get<List<int>>(
          pageUrl,
          cancelToken: cancelToken,
          options: Options(headers: browserHeaders, responseType: ResponseType.bytes),
        );
        if (_isValidImageBytes(r4.data)) {
          pageBytes = r4.data;
        } else {
          unawaited(LoggerService.instance.logWarning('Download pass 4 returned invalid bytes for $pageUrl', 'ownload'));
        }
      } catch (e) {
        unawaited(LoggerService.instance.logWarning('Download pass 4 (browser UA) failed for $pageUrl: $e', 'ownload'));
      }
    }

    if (cancelToken?.isCancelled == true) return;

    // Desktop fallback: if Dio was blocked by Cloudflare TLS fingerprint, fetch via curl-impersonate
    if ((pageBytes == null || pageBytes.isEmpty) && !kIsWeb && (Platform.isLinux || Platform.isMacOS || Platform.isWindows)) {
      // Route through the shared helper rather than shelling out directly.
      //
      // The raw `Process.run` loop here bypassed `safe_curl`'s semaphore, which
      // exists precisely to stop this: page concurrency is 5 and
      // kCurlCandidates has 4 entries, so a burst of failing pages could spawn
      // 20 concurrent curl processes, and that recurred every 5-page burst. It
      // also had no `.timeout()`, so a wedged child held its slot for as long
      // as curl's own --max-time allowed, and `CancelToken` cannot interrupt a
      // `Process.run` — pausing the queue left them running.
      final fetched = await runCurlWithSemaphore(
        url: pageUrl,
        maxTimeSeconds: 25,
        headers: headers.map((k, v) => MapEntry(k, v.toString())),
        timeout: const Duration(seconds: 35),
      );
      if (cancelToken?.isCancelled == true) return;
      if (fetched != null && fetched.isNotEmpty && _isValidImageBytes(fetched)) {
        pageBytes = fetched;
      }
    }

    if (cancelToken?.isCancelled == true) return;

    if (pageBytes != null && pageBytes.isNotEmpty && _isValidImageBytes(pageBytes)) {
      // Temp file + rename, not a direct write.
      //
      // `writeAsBytes` truncates in place, so a process kill (low-memory kill,
      // background-task eviction, battery pull) mid-write left a PARTIAL page on
      // disk. It was then accepted forever: the resume guard validates with
      // `looksLikeImageHeader`, which is a PREFIX probe and cannot tell a
      // truncated page from a whole one that starts with the same bytes, and the
      // completion marker was already written from a count taken when every page
      // was intact. The user got a permanently half-rendered page with no
      // in-app way to force a re-download, and re-opening the chapter served
      // the same truncated bytes.
      //
      // `rename` is atomic within a filesystem on POSIX and NTFS, so a page
      // either does not exist or is whole. Detection is replaced by prevention,
      // which is the only thing that actually works against a header-only
      // validator.
      final tmp = File('${file.path}.part');
      await tmp.writeAsBytes(pageBytes);
      await tmp.rename(file.path);
    }
  }

  Future<void> deleteLocalDownload(int chapterId) async {
    try {
      _cancelTokens.remove(chapterId)?.cancel('Cancelled');
      final task = _localTasks.where((t) => t.chapterId == chapterId).firstOrNull;
      if (task != null) {
        // Unaccount BEFORE overwriting status (same reason as dismiss): the
        // deleted row leaves the batch, undoing any counted outcome from its
        // own bucket so succeeded + failed == total holds.
        _unaccountRemoval(task);
        task.status = LocalDownloadStatus.failed;
        task.error = 'Cancelled';
      }

      final appDir = await getApplicationDocumentsDirectory();
      final chapterDir = Directory('${appDir.path}/downloads/$chapterId');
      if (await chapterDir.exists()) {
        await chapterDir.delete(recursive: true);
      }
      _downloadedLocalChapterIds.remove(chapterId);
      _localTasks.removeWhere((t) => t.chapterId == chapterId);
      await _saveQueueState();

      final ch = await IsarService.instance.getChapterByServerId(chapterId);
      final mId = ch?.mangaId;
      if (ch != null) {
        // Only the LOCAL copy is being removed; a server-side download of the
        // same chapter (if any) must keep its flag.
        ch.isDownloadedLocally = false;
        await IsarService.instance.saveChapter(ch);
      }
      if (mId != null && mId != 0) {
        final remaining = await IsarService.instance.getChaptersForManga(mId);
        final hasOther = remaining.any((c) => _downloadedLocalChapterIds.contains(c.serverId != 0 ? c.serverId : c.id));
        if (!hasOther) {
          _downloadedLocalMangaIds.remove(mId);
          final m = await IsarService.instance.getMangaByServerId(mId);
          if (m != null) {
            if (m.serverId != 0) _downloadedLocalMangaIds.remove(m.serverId);
            _downloadedLocalMangaIds.remove(m.id);
          }
        }
      }
      notifyListeners();
    } catch (e) {
      unawaited(LoggerService.instance.logError('deleteLocalDownload error: $e', category: 'DownloaManager'));
    }
  }

  void cancelLocalDownload(int chapterId) {
    _cancelTokens.remove(chapterId)?.cancel('Cancelled');
    final task = _localTasks.where((t) => t.chapterId == chapterId).firstOrNull;
    if (task != null) {
      final wasCompleted = task.status == LocalDownloadStatus.completed;
      // Store the status before cancel for proper accounting if later dismissed.
      task.statusBeforeCancel = task.status;
      task.status = LocalDownloadStatus.failed;
      task.error = 'Cancelled';
      if (!wasCompleted) {
        // A cancel is a terminal outcome: counted once via the accounted
        // set (double-taps can't double-count), total untouched.
        _accountOutcome(task, success: false);
      }
      unawaited(_saveQueueState());
      notifyListeners();
      // NOTE: We deliberately do NOT call _cleanupIncompleteDownload here.
      // A cancel keeps the task in the list (for Retry), and the partial
      // files should remain so a subsequent retry can resume from the
      // last valid page. The cleanup is only for Dismiss/Delete where the
      // user explicitly wants the chapter removed.
    }
  }

  Future<void> _cleanupIncompleteDownload(int chapterId) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final chapterDir = Directory('${appDir.path}/downloads/$chapterId');
      if (await chapterDir.exists()) {
        await chapterDir.delete(recursive: true);
      }
    } catch (e) {
      debugPrint('[DownloadManager] Cleanup incomplete download error: $e');
    }
  }

  Future<void> dismissLocalTask(int chapterId) async {
    final task = _localTasks.where((t) => t.chapterId == chapterId).firstOrNull;
    final token = _cancelTokens.remove(chapterId);
    if (task != null) {
      // Unaccount BEFORE overwriting status: a dismissed row leaves the
      // batch entirely (denominator shrinks, and any counted outcome is
      // undone from its own bucket). The status overwrite below is only so
      // the in-flight loop recognises a deliberate dismiss instead of
      // logging a failure.
      _unaccountRemoval(task);
      task.status = LocalDownloadStatus.failed;
      task.error = 'Cancelled';
    }
    if (token != null) {
      try {
        token.cancel('Task dismissed');
      } catch (ignoredError) { if (kDebugMode) debugPrint('[download_manager_service] ignored error: $ignoredError'); }
    }
    _localTasks.removeWhere((t) => t.chapterId == chapterId);
    await _saveQueueState();
    await _cleanupIncompleteDownload(chapterId);
    notifyListeners();
  }

  void clearCompletedDownloads() {
    for (final t in _localTasks.where((t) => t.status == LocalDownloadStatus.completed).toList()) {
      _unaccountRemoval(t);
    }
    _localTasks.removeWhere((t) => t.status == LocalDownloadStatus.completed);
    unawaited(_saveQueueState());
    notifyListeners();
  }

  // ── SERVER DOWNLOAD PROXY ──────────────────────────────────
  /// Enqueues a chapter for download on the Suwayomi server. Does NOT mark
  /// it as downloaded locally — the server enqueue is just a queue request.
  /// The "Downloaded" state is reconciled from the server during the next
  /// sync (which updates `chapter.isDownloadedOnServer`), and the local
  /// cache is rebuilt from the DB on startup.
  Future<void> enqueueServerDownload(int chapterId) async {
    if (GraphQLClientService.instance.isConfigured) {
      await GraphQLClientService.instance.enqueueChapterDownload(chapterId);
    }
  }

  /// Batch enqueue for server downloads. No optimistic local marking.
  Future<void> enqueueServerDownloads(List<int> chapterIds) async {
    if (GraphQLClientService.instance.isConfigured) {
      await GraphQLClientService.instance.enqueueChapterDownloads(chapterIds);
    }
  }

  Future<void> deleteServerDownload(int chapterId) async {
    if (GraphQLClientService.instance.isConfigured) {
      await GraphQLClientService.instance.deleteDownloadedChapter(chapterId);
      _downloadedServerChapterIds.remove(chapterId);
      await _rebuildServerMangaIds();
      notifyListeners();
    }
  }

  /// Rebuilds the server-downloaded chapter/manga sets from the local DB.
  /// Call on startup and after sync to reconcile with the server's truth.
  Future<void> rebuildServerDownloadCache() async {
    _downloadedServerChapterIds.clear();
    _downloadedServerMangaIds.clear();
    final chapters = await IsarService.instance.getAllChapters();
    for (final ch in chapters) {
      if (ch.isDownloadedOnServer) {
        _downloadedServerChapterIds.add(ch.serverId);
      }
    }
    await _rebuildServerMangaIds();
  }

  @override
  void dispose() {
    unawaited(_connectivitySubscription?.cancel());
    unawaited(_batterySubscription?.cancel());
    _notifierHeartbeat?.cancel();
    _notifierHeartbeat = null;
    for (final token in _cancelTokens.values) {
      try {
        token.cancel('Service disposed');
      } catch (ignoredError) { if (kDebugMode) debugPrint('[download_manager_service] ignored error: $ignoredError'); }
    }
    _cancelTokens.clear();
    unawaited(_stopActiveNotifier());
    super.dispose();
  }
}
