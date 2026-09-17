import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

/// Manages the Android foreground service that keeps the chapter download
/// queue running while the app is in the background, and surfaces live
/// progress in a low-priority status-bar notification.
///
/// How the pieces fit together:
///
/// - The main (UI) isolate owns [DownloadManagerService] and drives the actual
///   downloads. On every meaningful queue transition it calls [update], which
///   (a) persists a JSON snapshot of the current queue state via
///   `FlutterForegroundTask.saveData` and (b) refreshes the service
///   notification through `FlutterForegroundTask.updateService`.
/// - The foreground service keeps the OS process alive while downloads are
///   active, so the Dart isolate keeps executing (downloads continue).
/// - [DownloadTaskHandler] runs in the plugin's background isolate. It cannot
///   touch the app singleton, so it re-renders the notification from the
///   shared snapshot every few seconds. If it sees an inactive/empty snapshot
///   it stops the service itself — a safety net if the UI isolate was killed.
///
/// iOS is intentionally skipped: sideloaded environments (LiveContainer,
/// AltStore, TrollStore) crash when background task systems are invoked, and
/// continuous background work is not available there anyway. Downloads pause
/// while suspended and resume when the app returns to the foreground.
class DownloadForegroundTask {
  DownloadForegroundTask._();
  static final DownloadForegroundTask instance = DownloadForegroundTask._();

  static const String _channelId = 'sunfire_downloads_foreground';
  static const String _channelName = 'Chapter Downloads';
  static const String _channelDescription =
      'Shows progress of active chapter downloads';

  /// Shared-preferences key under which the main isolate stores the current
  /// queue snapshot so the background handler (different isolate) can render
  /// the notification and detect an idle queue.
  static const String progressKey = 'sunfire_fgt_download_progress';

  /// Max age of a queue snapshot before the background handler considers the
  /// main isolate dead (e.g. process force-killed) and stops the service.
  /// The main isolate refreshes the snapshot at least every [heartbeatInterval].
  static const Duration staleSnapshotAfter = Duration(seconds: 90);

  /// How often the main isolate refreshes the snapshot while a chapter is
  /// downloading (chapters can take minutes and don't call [update] per page).
  static const Duration heartbeatInterval = Duration(seconds: 30);

  /// True when [raw] is unparseable or its `updatedAt` is older than
  /// [staleSnapshotAfter]. Pure so the background isolate and tests share it.
  static bool isSnapshotStale(String raw, {DateTime? now}) {
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final updatedAt = (decoded['updatedAt'] as num?)?.toInt() ?? 0;
      if (updatedAt <= 0) return true;
      final reference = now ?? DateTime.now();
      return reference.difference(DateTime.fromMillisecondsSinceEpoch(updatedAt)) > staleSnapshotAfter;
    } catch (_) {
      return true;
    }
  }

  /// Serializes the queue snapshot shared with the background isolate.
  static String buildSnapshot({
    required String mangaTitle,
    required String currentChapter,
    required int completed,
    required int total,
    required bool active,
  }) {
    return jsonEncode({
      'mangaTitle': mangaTitle,
      'currentChapter': currentChapter,
      'completed': completed,
      'total': total,
      'active': active,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  static const int _serviceId = 333;

  bool _isInitialized = false;

  static bool get isSupported => !kIsWeb && Platform.isAndroid;

  /// Call once at app startup (no-op outside Android).
  void initialize() {
    if (!isSupported || _isInitialized) return;
    try {
      FlutterForegroundTask.initCommunicationPort();
      FlutterForegroundTask.init(
        androidNotificationOptions: AndroidNotificationOptions(
          channelId: _channelId,
          channelName: _channelName,
          channelDescription: _channelDescription,
          channelImportance: NotificationChannelImportance.LOW,
          priority: NotificationPriority.LOW,
          enableVibration: false,
          playSound: false,
          showWhen: true,
          showBadge: false,
          onlyAlertOnce: true,
          visibility: NotificationVisibility.VISIBILITY_PUBLIC,
        ),
        iosNotificationOptions: const IOSNotificationOptions(
          showNotification: false,
          playSound: false,
        ),
        foregroundTaskOptions: ForegroundTaskOptions(
          eventAction: ForegroundTaskEventAction.repeat(5000),
          autoRunOnBoot: false,
          autoRunOnMyPackageReplaced: false,
          allowWakeLock: true,
          allowWifiLock: true,
        ),
      );
      _isInitialized = true;
    } catch (e) {
      debugPrint('[DownloadForegroundTask] initialize error: $e');
    }
  }

  /// Refresh the foreground service + notification to reflect the current
  /// queue. Starts the service when downloads are active; updates the status
  /// when it is already running; turns it off when `active` is false.
  Future<void> update({
    required String mangaTitle,
    required String currentChapter,
    required int completed,
    required int total,
    required bool active,
  }) async {
    if (!isSupported) return;
    initialize(); // idempotent — ensures the service is configured before use.

    final String snapshot = buildSnapshot(
      mangaTitle: mangaTitle,
      currentChapter: currentChapter,
      completed: completed,
      total: total,
      active: active,
    );

    try {
      await FlutterForegroundTask.saveData(key: progressKey, value: snapshot);

      final title = active ? 'Downloading: $mangaTitle' : 'Downloads Paused';
      final text =
          active ? '$currentChapter • $completed/$total chapters' : 'Tap to manage downloads';

      if (await FlutterForegroundTask.isRunningService) {
        await FlutterForegroundTask.updateService(
          notificationTitle: title,
          notificationText: text,
        );
      } else if (active && await FlutterForegroundTask.isAppOnForeground) {
        await FlutterForegroundTask.startService(
          serviceId: _serviceId,
          notificationTitle: title,
          notificationText: text,
          notificationButtons: [
            const NotificationButton(id: 'btn_stop_all', text: 'Stop'),
          ],
          notificationInitialRoute: '/downloads',
          callback: downloadTaskCallback,
        );
      }
      // else: queue active but the app is backgrounded and no service is
      // running — Android 12+ forbids starting services from the background.
      // The main-isolate resume handler restarts the queue when the app next
      // comes to the foreground, so no download is stranded.
    } catch (e) {
      debugPrint('[DownloadForegroundTask] update error: $e');
    }
  }

  /// Stop the foreground service and clear the shared snapshot.
  Future<void> stop() async {
    if (!isSupported) return;
    initialize(); // idempotent
    try {
      if (await FlutterForegroundTask.isRunningService) {
        await FlutterForegroundTask.stopService();
      }
      await FlutterForegroundTask.removeData(key: progressKey);
    } catch (e) {
      debugPrint('[DownloadForegroundTask] stop error: $e');
    }
  }
}

/// Entry point for the plugin's background isolate. Must stay top-level.
@pragma('vm:entry-point')
void downloadTaskCallback() {
  FlutterForegroundTask.setTaskHandler(DownloadTaskHandler());
}

/// Watches the shared queue snapshot and keeps the service notification (and
/// lifetime) in sync, independently of the UI isolate.
class DownloadTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    await _syncFromSnapshot();
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    _syncFromSnapshot();
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    if (isTimeout) {
      // Android's dataSync budget (e.g. 6h on Android 15) ran out and the OS
      // is force-stopping the service. Ask the main isolate to pause the
      // queue so in-flight chapters stop cleanly instead of being killed
      // mid-burst; it resumes on the next app foreground (the queue itself is
      // persisted, so nothing is lost).
      FlutterForegroundTask.sendDataToMain(const <String, dynamic>{'action': 'pause'});
    }
  }

  @override
  void onNotificationButtonPressed(String id) {
    if (id == 'btn_stop_all') {
      // Tell the main isolate to pause the queue; the paused state stops the
      // service cleanly. Stopping the service alone would just let the OS kill
      // the app and strand downloads.
      FlutterForegroundTask.sendDataToMain(const <String, dynamic>{'action': 'pause'});
      FlutterForegroundTask.stopService();
    }
  }

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp('/downloads');
  }

  @override
  void onNotificationDismissed() {}

  Future<void> _syncFromSnapshot() async {
    try {
      final String? raw =
          await FlutterForegroundTask.getData<String>(key: DownloadForegroundTask.progressKey);
      if (raw == null || raw.isEmpty) {
        // No live queue — the main isolate must have been killed or the queue
        // drained. Stop the service so we never leave a stale notification.
        if (await FlutterForegroundTask.isRunningService) {
          await FlutterForegroundTask.stopService();
        }
        return;
      }

      // Zombie guard: if the snapshot hasn't been refreshed in a while the UI
      // isolate is gone (force-kill / crash while downloads were active) while
      // the OS restarted the service. Kill the service instead of letting a
      // "Downloading: …" notification + wake/wifi locks run forever with no
      // downloads happening.
      if (DownloadForegroundTask.isSnapshotStale(raw)) {
        if (await FlutterForegroundTask.isRunningService) {
          await FlutterForegroundTask.stopService();
        }
        return;
      }

      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final bool active = decoded['active'] == true;
      if (!active) {
        if (await FlutterForegroundTask.isRunningService) {
          await FlutterForegroundTask.stopService();
        }
        return;
      }

      final mangaTitle = decoded['mangaTitle']?.toString() ?? 'Manga';
      final currentChapter = decoded['currentChapter']?.toString() ?? '';
      final completed = (decoded['completed'] as num?)?.toInt() ?? 0;
      final total = (decoded['total'] as num?)?.toInt() ?? 0;

      await FlutterForegroundTask.updateService(
        notificationTitle: 'Downloading: $mangaTitle',
        notificationText: total > 0
            ? '$currentChapter • $completed/$total chapters'
            : currentChapter,
      );
    } catch (e) {
      debugPrint('[DownloadForegroundTask] sync error: $e');
    }
  }
}