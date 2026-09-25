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

  LocalDownloadTask({
    required this.chapterId,
    required this.mangaId,
    required this.chapterName,
    required this.mangaTitle,
    this.chapterNumber = 0,
    this.progress = 0.0,
    this.status = LocalDownloadStatus.queued,
    this.error,
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
  };

  factory LocalDownloadTask.fromJson(Map<String, dynamic> map) {
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
  StreamSubscription? _connectivitySubscription;

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
          _processLocalQueue();
        }
      });
    } catch (e) {
      debugPrint('[DownloadManager] Connectivity listener error: $e');
    }
  }

  StreamSubscription? _batterySubscription;

  void _initBatteryListener() {
    try {
      _batterySubscription = BatteryStateService.instance.onBatteryStateChanged.listen((state) {
        final charging = state == BatteryState.charging || state == BatteryState.full;
        // Only resume from a charge-gate — an explicit user pause is never overridden.
        if (charging && !_isQueuePaused && !_isProcessingLocalQueue &&
            _localTasks.any((t) => t.status == LocalDownloadStatus.queued)) {
          _processLocalQueue();
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
            () => createServerTrustingHttpClient(() => SettingsService.instance.serverUrl);
      }
    } catch (ignoredError) { if (kDebugMode) debugPrint('[download_manager_service] ignored error: $ignoredError'); }
  }

  static const String _queuePrefKey = 'sunfire_download_queue_v1';

  /// Persisted so an explicit "Pause" survives app restarts. Without this the
  /// startup/foreground auto-resume would silently re-start a queue the user
  /// stopped on purpose (e.g. to save mobile data), making Pause meaningless.
  static const String _queuePausedPrefKey = 'sunfire_download_queue_v1_paused';

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

  Future<void> _saveQueueState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _localTasks.map((t) => t.toJson()).toList();
      await prefs.setString(_queuePrefKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('[DownloadManager] Error saving queue state: $e');
    }
  }

  Future<void> _loadQueueState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_queuePrefKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as List<dynamic>;
        _localTasks.clear();
        for (final item in decoded) {
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

  Future<void> _loadQueuePausedFlag() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isQueuePaused = prefs.getBool(_queuePausedPrefKey) ?? false;
    } catch (e) {
      debugPrint('[DownloadManager] Error loading pause flag: $e');
    }
  }

  Future<void> _persistQueuePausedFlag() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_queuePausedPrefKey, _isQueuePaused);
    } catch (e) {
      debugPrint('[DownloadManager] Error persisting pause flag: $e');
    }
  }

  bool _isQueuePaused = false;
  bool get isQueuePaused => _isQueuePaused;

  // ── Batch tracking for background/notification reporting ────────────
  int _batchTotal = 0;
  int _completedInBatch = 0;
  int _failedInBatch = 0;
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
    _batchTotal = countRetryableTasks(_localTasks);
    _completedInBatch = 0;
    _failedInBatch = 0;
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
      DownloadForegroundTask.instance.stop();
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
    await _persistQueuePausedFlag();
    await _stopActiveNotifier();
    notifyListeners();
  }

  Future<void> resumeLocalQueue() async {
    _isQueuePaused = false;
    for (final task in _localTasks) {
      if (task.status == LocalDownloadStatus.downloading || task.status == LocalDownloadStatus.paused) {
        task.status = LocalDownloadStatus.queued;
      }
    }
    await _saveQueueState();
    await _persistQueuePausedFlag();
    if (!_isProcessingLocalQueue && _localTasks.any((t) => t.status == LocalDownloadStatus.queued)) {
      _processLocalQueue();
    }
    notifyListeners();
  }

  /// Called when the app returns to the foreground. Unlike [resumeLocalQueue]
  /// (the explicit user/UI entry point), this never overrides an intentional
  /// pause: an explicitly paused queue stays paused until the user resumes it.
  void resumeLocalQueueAfterForeground() {
    if (_isQueuePaused) return;
    resumeLocalQueue();
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
    await _migrateLegacyDownloadFolders();
    await _scanDownloadedLocalChapters();
    await _loadQueuePausedFlag();
    // Auto-resume only when the user didn't explicitly pause the queue. A
    // paused queue must survive app restarts — otherwise Pause would only
    // last until the next launch.
    if (!_isQueuePaused) {
      await resumeLocalQueue();
    }
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
          var images = 0;
          await for (final f in entity.list()) {
            if (f is! File) continue;
            final n = f.path.toLowerCase();
            if (n.endsWith('.jpg') || n.endsWith('.jpeg') || n.endsWith('.png') ||
                n.endsWith('.webp') || n.endsWith('.gif') || n.endsWith('.bmp')) {
              images++;
            }
          }
          if (images > 0) {
            await File('${entity.path}/$kDownloadCompleteMarkerName').writeAsString('$images');
          }
        }
      }
      await prefs.setBool(doneKey, true);
    } catch (e) {
      LoggerService.instance.logError('Legacy download marker migration failed: $e', category: 'DownloadManager');
    }
  }

  Future<void> _scanDownloadedLocalChapters() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory('${appDir.path}/downloads');
      if (await downloadsDir.exists()) {
        final entities = await downloadsDir.list().toList();
        for (final entity in entities) {
          if (entity is Directory) {
            final segments = entity.uri.pathSegments.where((s) => s.isNotEmpty).toList();
            if (segments.isNotEmpty) {
              final id = int.tryParse(segments.last);
              // Only count this folder as a real downloaded chapter if it
              // finished — see kDownloadCompleteMarkerName. A folder left
              // behind by a failed/killed/cancelled download has no marker
              // and must not be reported as "downloaded" to the UI or reader.
              if (id != null && await isDownloadFolderComplete(entity)) {
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
            }
          }
        }
      }
      notifyListeners();
    } catch (e) {
      LoggerService.instance.logError('_scanDownloadedLocalChapters error: $e', category: 'DownloadManager');
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
    // Keep the reported batch total accurate: enqueuing a brand-new item
    // during a run grows the total, but retrying a failed one merely replaces
    // its slot (and undoes the failure it already logged) instead of
    // inflating both counters.
    if (_batchCounted) {
      if (wasFailed) {
        if (_failedInBatch > 0) _failedInBatch--;
      } else {
        _batchTotal++;
      }
    }
    await _saveQueueState();
    notifyListeners();

    _processLocalQueue();
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

  Future<void> _processLocalQueue() async {
    if (_isProcessingLocalQueue || _isQueuePaused) return;
    _isProcessingLocalQueue = true;
    _beginBatch();

    // Keep the FGS snapshot fresh during long per-chapter downloads so the
    // background isolate's staleness guard doesn't kill a healthy service.
    _notifierHeartbeat?.cancel();
    _notifierHeartbeat = Timer.periodic(DownloadForegroundTask.heartbeatInterval, (_) {
      _refreshActiveNotifier();
    });

    var stoppedForNetwork = false;
    try {
      while (!_isQueuePaused) {
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
        final queued = sortQueuedTasks(_localTasks);
        if (queued.isEmpty) break;
        final task = queued.first;
        final epochAtStart = _pauseEpoch;

        task.status = LocalDownloadStatus.downloading;
        task.error = null;
        await _saveQueueState();
        notifyListeners();
        await _refreshActiveNotifier();

        try {
          await _downloadChapterLocally(task);
          if (task.status == LocalDownloadStatus.paused || task.status == LocalDownloadStatus.failed) {
            // Task was paused or cancelled during execution; preserve its state
          } else {
            task.status = LocalDownloadStatus.completed;
            task.progress = 1.0;
            _completedInBatch++;
            _downloadedLocalChapterIds.add(task.chapterId);
            _downloadedLocalMangaIds.add(task.mangaId);
            final m = await IsarService.instance.getMangaByServerId(task.mangaId);
            if (m != null) {
              if (m.serverId > 0) _downloadedLocalMangaIds.add(m.serverId);
              _downloadedLocalMangaIds.add(m.id);
            }

            // Update Isar DB
            final ch = await IsarService.instance.getChapterByServerId(task.chapterId);
            if (ch != null) {
              ch.isDownloaded = true;
              await IsarService.instance.saveChapter(ch);
            }
          }
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
            _failedInBatch++;
            await LoggerService.instance.logError('Failed to download chapter ${task.chapterId}: $e', exception: e, stackTrace: stack, category: 'DownloadManager');
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
        await _stopActiveNotifier();
      } else if (pendingQueued) {
        // New items were enqueued while the loop was draining (rare race).
        // Re-enter so they are processed instead of left stranded.
        _waitingForCharger = false;
        _processLocalQueue();
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

    final rawPages = resolved.pageUrls;
    if (rawPages.isEmpty) {
      throw Exception('No pages found for chapter ${task.chapterName}');
    }

    final appDir = await getApplicationDocumentsDirectory();
    final chapterDir = Directory('${appDir.path}/downloads/${task.chapterId}');
    if (!await chapterDir.exists()) {
      await chapterDir.create(recursive: true);
    }

    final cancelToken = CancelToken();
    _cancelTokens[task.chapterId] = cancelToken;

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
      final existingFiles = chapterDir
          .listSync()
          .whereType<File>()
          .where((f) {
            final name = f.path.toLowerCase();
            return name.endsWith('.jpg') ||
                name.endsWith('.jpeg') ||
                name.endsWith('.png') ||
                name.endsWith('.webp') ||
                name.endsWith('.gif') ||
                name.endsWith('.bmp');
          })
          .toList();
      if (existingFiles.length < totalPages) {
        throw Exception('Incomplete download: only ${existingFiles.length}/$totalPages pages saved');
      }
      // Only now — with every page verified present — write the completion
      // marker. This is what the resolver/reader/startup scan check before
      // trusting this folder as "downloaded"; without it a partial folder
      // from this same failed/cancelled attempt would otherwise look
      // identical to a finished one on the next retry.
      await File('${chapterDir.path}/$kDownloadCompleteMarkerName').writeAsString('$totalPages');
    } finally {
      _cancelTokens.remove(task.chapterId);
    }
  }

  static bool _isValidImageBytes(List<int>? b) {
    if (b == null || b.length < 12) return false;
    // JPEG: FF D8
    if (b[0] == 0xFF && b[1] == 0xD8) return true;
    // PNG: 89 50 4E 47
    if (b[0] == 0x89 && b[1] == 0x50 && b[2] == 0x4E && b[3] == 0x47) return true;
    // WebP: RIFF ... WEBP
    if (b[0] == 0x52 && b[1] == 0x49 && b[2] == 0x46 && b[3] == 0x46 &&
        b[8] == 0x57 && b[9] == 0x45 && b[10] == 0x42 && b[11] == 0x50) {
      return true;
    }
    // GIF: GIF87a / GIF89a
    if (b[0] == 0x47 && b[1] == 0x49 && b[2] == 0x46 && b[3] == 0x38) return true;
    // BMP: 42 4D
    if (b[0] == 0x42 && b[1] == 0x4D) return true;
    // AVIF / HEIC: ISO-BMFF box, "ftyp" at offset 4
    if (b[4] == 0x66 && b[5] == 0x74 && b[6] == 0x79 && b[7] == 0x70) return true;
    // JPEG XL: bare codestream (FF 0A) or container signature box
    if (b[0] == 0xFF && b[1] == 0x0A) return true;
    if (b[0] == 0x00 && b[1] == 0x00 && b[2] == 0x00 && b[3] == 0x0C && b[4] == 0x4A && b[5] == 0x58 && b[6] == 0x4C && b[7] == 0x20) {
      return true;
    }
    // Anything else (HTML/JSON/Cloudflare challenge pages, truncated junk)
    // is NOT an image. The previous "any non-HTML blob over 500 bytes" fallback
    // let error bodies be saved as pages and the chapter marked downloaded.
    return false;
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
    if (await file.exists() && await file.length() > 500) {
      return;
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
        LoggerService.instance.logWarning('Download pass 1 returned invalid bytes for $pageUrl', 'Download');
      }
    } catch (e) {
      LoggerService.instance.logWarning('Download pass 1 (standard) failed for $pageUrl: $e', 'Download');
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
          LoggerService.instance.logWarning('Download pass 2 returned invalid bytes for $pageUrl', 'Download');
        }
      } catch (e) {
        LoggerService.instance.logWarning('Download pass 2 (no Referer) failed for $pageUrl: $e', 'Download');
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
          LoggerService.instance.logWarning('Download pass 3 returned invalid bytes for $pageUrl', 'Download');
        }
      } catch (e) {
        LoggerService.instance.logWarning('Download pass 3 (origin Referer) failed for $pageUrl: $e', 'Download');
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
          LoggerService.instance.logWarning('Download pass 4 returned invalid bytes for $pageUrl', 'Download');
        }
      } catch (e) {
        LoggerService.instance.logWarning('Download pass 4 (browser UA) failed for $pageUrl: $e', 'Download');
      }
    }

    if (cancelToken?.isCancelled == true) return;

    // Desktop fallback: if Dio was blocked by Cloudflare TLS fingerprint, fetch via curl-impersonate
    if ((pageBytes == null || pageBytes.isEmpty) && !kIsWeb && (Platform.isLinux || Platform.isMacOS || Platform.isWindows)) {
      final curlArgs = buildCurlArgs(
        url: pageUrl,
        maxTimeSeconds: 25,
        headers: headers.map((k, v) => MapEntry(k, v.toString())),
      );
      for (final exe in (curlArgs == null ? const <String>[] : kCurlCandidates)) {
        if (cancelToken?.isCancelled == true) return;
        try {
          final args = curlArgs!;
          final res = await Process.run(exe, args, stdoutEncoding: null);
          if (res.exitCode == 0) {
            final b = res.stdout as List<int>;
            if (_isValidImageBytes(b)) {
              pageBytes = b;
              break;
            }
          }
        } catch (e) {
          LoggerService.instance.logWarning('curl fallback ($exe) failed for $pageUrl: $e', 'Download');
        }
      }
    }

    if (cancelToken?.isCancelled == true) return;

    if (pageBytes != null && pageBytes.isNotEmpty && _isValidImageBytes(pageBytes)) {
      await file.writeAsBytes(pageBytes);
    }
  }

  Future<void> deleteLocalDownload(int chapterId) async {
    try {
      _cancelTokens.remove(chapterId)?.cancel('Cancelled');
      final task = _localTasks.where((t) => t.chapterId == chapterId).firstOrNull;
      if (task != null) {
        final wasCompleted = task.status == LocalDownloadStatus.completed;
        task.status = LocalDownloadStatus.failed;
        task.error = 'Cancelled';
        // A removed in-flight/queued task no longer counts toward the batch
        // total reported in the completion notification.
        if (_batchCounted && !wasCompleted && _batchTotal > 0) {
          _batchTotal--;
        }
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
      if (mId != null && mId > 0) {
        final remaining = await IsarService.instance.getChaptersForManga(mId);
        final hasOther = remaining.any((c) => _downloadedLocalChapterIds.contains(c.serverId > 0 ? c.serverId : c.id));
        if (!hasOther) {
          _downloadedLocalMangaIds.remove(mId);
          final m = await IsarService.instance.getMangaByServerId(mId);
          if (m != null) {
            _downloadedLocalMangaIds.remove(m.serverId);
            _downloadedLocalMangaIds.remove(m.id);
          }
        }
      }
      notifyListeners();
    } catch (e) {
      LoggerService.instance.logError('deleteLocalDownload error: $e', category: 'DownloadManager');
    }
  }

  void cancelLocalDownload(int chapterId) {
    _cancelTokens.remove(chapterId)?.cancel('Cancelled');
    final task = _localTasks.where((t) => t.chapterId == chapterId).firstOrNull;
    if (task != null) {
      final wasCompleted = task.status == LocalDownloadStatus.completed;
      task.status = LocalDownloadStatus.failed;
      task.error = 'Cancelled';
      if (!wasCompleted && _batchCounted) {
        // User-cancelled tasks count as failures in the batch summary.
        _failedInBatch++;
      }
      _saveQueueState();
      notifyListeners();
      _cleanupIncompleteDownload(chapterId);
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
      // Mark the task cancelled BEFORE the in-flight download throws, so the
      // queue loop recognises a deliberate dismiss instead of logging a
      // failure — while still removing it from the reported batch total.
      final wasCompleted = task.status == LocalDownloadStatus.completed;
      task.status = LocalDownloadStatus.failed;
      task.error = 'Cancelled';
      if (!wasCompleted && _batchCounted && _batchTotal > 0) {
        _batchTotal--;
      }
    }
    if (token != null) {
      try {
        token.cancel('Task dismissed');
      } catch (ignoredError) { if (kDebugMode) debugPrint('[download_manager_service] ignored error: $ignoredError'); }
    }
    _localTasks.removeWhere((t) => t.chapterId == chapterId);
    await _saveQueueState();
    notifyListeners();
  }

  void clearCompletedDownloads() {
    _localTasks.removeWhere((t) => t.status == LocalDownloadStatus.completed);
    _saveQueueState();
    notifyListeners();
  }

  // ── SERVER DOWNLOAD PROXY ──────────────────────────────────
  Future<void> enqueueServerDownload(int chapterId) async {
    if (GraphQLClientService.instance.isConfigured) {
      final res = await GraphQLClientService.instance.enqueueChapterDownload(chapterId);
      if (res != null) {
        _downloadedServerChapterIds.add(chapterId);
        await _rebuildServerMangaIds();
        notifyListeners();
      }
    }
  }

  Future<void> enqueueServerDownloads(List<int> chapterIds) async {
    if (GraphQLClientService.instance.isConfigured) {
      final res = await GraphQLClientService.instance.enqueueChapterDownloads(chapterIds);
      if (res != null) {
        _downloadedServerChapterIds.addAll(chapterIds);
        await _rebuildServerMangaIds();
        notifyListeners();
      }
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

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _batterySubscription?.cancel();
    _notifierHeartbeat?.cancel();
    _notifierHeartbeat = null;
    for (final token in _cancelTokens.values) {
      try {
        token.cancel('Service disposed');
      } catch (ignoredError) { if (kDebugMode) debugPrint('[download_manager_service] ignored error: $ignoredError'); }
    }
    _cancelTokens.clear();
    _stopActiveNotifier();
    super.dispose();
  }
}
