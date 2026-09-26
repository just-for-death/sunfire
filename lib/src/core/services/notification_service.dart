import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui' show IsolateNameServer;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../db/models/chapter.dart';
import 'settings_service.dart';

/// Port name used to forward taps that arrive in the plugin's background
/// isolate (app killed / not running) back to the main isolate.
const String _notificationTapPortName = 'sunfire_notification_tap_port';

/// Top-level callback for notification responses in background or foreground.
/// Runs inside the plugin-spawned isolate, so it can only forward the payload
/// over an isolate port — the real navigation happens on the main isolate
/// ([NotificationService.initialize] registers the port and forwards to
/// [onNotificationTapped]).
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  debugPrint('[NotificationService] Notification tapped with payload: ${response.payload}');
  final port = IsolateNameServer.lookupPortByName(_notificationTapPortName);
  if (port != null) {
    port.send(response.payload ?? '/updates');
  }
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// Whether the OS will actually display a notification.
  ///
  /// Null until the Android permission request has been answered. Assumed true
  /// elsewhere, because iOS and desktop have no equivalent gate here and because
  /// an unknown answer should not suppress notification logic.
  bool? _notificationsAllowed;

  ReceivePort? _notificationTapPort;

  /// Whether notifications can be shown, as far as this service can tell.
  ///
  /// False only after an explicit denial. Callers can surface this so a user
  /// whose notifications are silently not appearing has a way to find out.
  bool get notificationsAllowed => _notificationsAllowed ?? true;

  /// Lets the UI ask the OS again.
  ///
  /// A no-op where the platform has no explicit gate, so callers do not need to
  /// branch on platform.
  Future<bool> requestNotificationPermission() async {
    if (kIsWeb || !Platform.isAndroid) {
      _notificationsAllowed = true;
      return true;
    }
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) {
      _notificationsAllowed = true;
      return true;
    }
    _notificationsAllowed = await androidPlugin.requestNotificationsPermission() ?? true;
    return _notificationsAllowed!;
  }

  /// New-chapter notification ids currently on screen, oldest first.
  ///
  /// Android requires a unique id per notification (`Notification.Builder`
  /// conflicts otherwise), so a single shared id meant a second notification
  /// silently replaced the first.
  ///
  /// The bookkeeping behind those ids was also wrong: a monotonically
  /// increasing id from 1001 to 3999 with nothing ever
  /// cancelling the previous notification. On a channel created with sound,
  /// vibration and a badge, the shade therefore accumulated up to ~2999 separate,
  /// individually swipeable "New Chapters" cards — and the counter only stopped
  /// because it wrapped, at which point it began silently replacing live ones.
  ///
  /// A bounded stack is the right shape for a stream of "N new chapters"
  /// alerts: the newest is what matters, and a handful of recent ones give the
  /// user something to look back at without the shade becoming a log. The
  /// Downloaded app caps its own lists the same way. Bounded well below the
  /// reserved download id range (4001+).
  final List<int> _newChapterNotificationIds = [];
  int _nextNewChapterNotificationId = 1001;
  static const int _kMaxNewChapterNotifications = 5;

  /// Wraps well below the reserved 4001+ download range, and far enough above
  /// [1001] that an id is never reused while it is still on screen: at a cap of
  /// [_kMaxNewChapterNotifications] the previous holder of any given id was
  /// cancelled thousands of notifications ago.
  static const int _kNewChapterNotificationIdCeiling = 3000;

  static const String channelId = 'sunfire_new_chapters';
  static const String channelName = 'New Chapters';
  static const String channelDescription = 'Alerts when new chapters are available for your library';

  // ── Downloads channel & notification ids ─────────────────────────────
  static const String downloadsChannelId = 'sunfire_downloads';
  static const String downloadsChannelName = 'Downloads';
  static const String downloadsChannelDescription = 'Progress and completion of chapter downloads';

  static const int downloadProgressNotificationId = 4001;
  // These two used to share 4002. Android keys notifications by (id, tag), so
  // whichever posted last silently replaced the other: the foreground
  // "Downloads resumed" toast ate the batch-completion summary — the only
  // confirmation the user gets that an overnight download worked — and
  // conversely a resume notice replaced the last summary. Neither was ever
  // cancelled, so they also outlived the event that raised them.
  static const int downloadsResumedNotificationId = 4002;
  static const int downloadSummaryNotificationId = 4003;

  /// Stream of notification payloads tapped by user (e.g. '/updates')
  final StreamController<String?> _selectNotificationStream = StreamController<String?>.broadcast();
  Stream<String?> get onNotificationTapped => _selectNotificationStream.stream;

  String? _initialPayload;
  String? consumeInitialPayload() {
    final payload = _initialPayload;
    _initialPayload = null;
    return payload;
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const linuxSettings = LinuxInitializationSettings(
      defaultActionName: 'Open Sunfire',
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
      linux: linuxSettings,
    );

    try {
      await _plugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('[NotificationService] Notification tapped: ${response.payload}');
          _selectNotificationStream.add(response.payload ?? '/updates');
        },
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );

      // Make background-isolate taps (app killed) reach the main isolate.
      //
      // The previous port is closed first. `_isInitialized` is set only after
      // this try block, so anything thrown above left the service uninitialised
      // and every later notification re-ran this — creating a fresh
      // `ReceivePort` each time and orphaning the last one, never closed, its
      // subscription never cancelled. Four lazy-init call sites plus the
      // WorkManager isolate made that a per-notification leak.
      IsolateNameServer.removePortNameMapping(_notificationTapPortName);
      _notificationTapPort?.close();
      final port = ReceivePort();
      _notificationTapPort = port;
      port.listen((payload) {
        if (payload is String) {
          debugPrint('[NotificationService] Background tap forwarded: $payload');
          _selectNotificationStream.add(payload);
        }
      });
      IsolateNameServer.registerPortWithName(port.sendPort, _notificationTapPortName);

      final launchDetails = await _plugin.getNotificationAppLaunchDetails();
      if (launchDetails != null && launchDetails.didNotificationLaunchApp) {
        _initialPayload = launchDetails.notificationResponse?.payload ?? '/updates';
        debugPrint('[NotificationService] App launched from notification: $_initialPayload');
      }

      // Create high-priority notification channel for Android
      if (!kIsWeb && Platform.isAndroid) {
        final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        if (androidPlugin != null) {
          await androidPlugin.createNotificationChannel(
            const AndroidNotificationChannel(
              channelId,
              channelName,
              description: channelDescription,
              importance: Importance.high,
              playSound: true,
              enableVibration: true,
              showBadge: true,
            ),
          );

          // Low-priority, silent channel for download progress/completion.
          await androidPlugin.createNotificationChannel(
            const AndroidNotificationChannel(
              downloadsChannelId,
              downloadsChannelName,
              description: downloadsChannelDescription,
              importance: Importance.low,
              playSound: false,
              enableVibration: false,
              showBadge: false,
            ),
          );

          // Request notification permission for Android 13+.
          //
          // The result was discarded, never stored, and never re-checked. If the
          // user denied — or chose "don't ask again", after which the system
          // stops showing the dialog entirely — every `showXxx` still ran and
          // then failed inside the plugin, where the catch only debugPrints. The
          // app therefore showed zero notifications with no indication why and
          // no in-app path to fix it.
          _notificationsAllowed = await androidPlugin.requestNotificationsPermission() ?? true;
        }
      }

      _isInitialized = true;
      debugPrint('[NotificationService] Initialized successfully');
    } catch (e) {
      debugPrint('[NotificationService] Initialization error: $e');
    }
  }

  /// Show a system notification summarizing newly discovered chapters
  Future<void> showNewChaptersNotification(List<Chapter> newChapters) async {
    if (newChapters.isEmpty) return;
    if (!SettingsService.instance.newChapterNotificationsEnabled) return;

    if (!_isInitialized) {
      await initialize();
    }

    final int totalCount = newChapters.length;
    final Set<String> uniqueTitles = {};
    for (final ch in newChapters) {
      if (ch.mangaTitle.isNotEmpty) {
        uniqueTitles.add(ch.mangaTitle);
      }
    }

    String title;
    String body;

    if (uniqueTitles.length <= 1) {
      final mangaTitle = uniqueTitles.isNotEmpty ? uniqueTitles.first : 'Library Manga';
      if (totalCount == 1) {
        final ch = newChapters.first;
        title = 'New Chapter: $mangaTitle';
        body = ch.name.isNotEmpty ? ch.name : 'Chapter ${ch.chapterNumber} is now available';
      } else {
        title = mangaTitle;
        body = '$totalCount new chapters are now available';
      }
    } else {
      title = '$totalCount New Chapters Available';
      final names = uniqueTitles.toList();
      if (names.length == 2) {
        body = '${names[0]} and ${names[1]} have new chapters';
      } else {
        body = '${names[0]}, ${names[1]} and ${names.length - 2} more have updated';
      }
    }

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(body, contentTitle: title),
      category: AndroidNotificationCategory.recommendation,
      icon: '@mipmap/launcher_icon',
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const linuxDetails = LinuxNotificationDetails();

    final details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
      linux: linuxDetails,
    );

    try {
      // A fresh id per batch, so successive notifications do not overwrite each
      // other on Android, and the stack is trimmed to a bounded window so the
      // shade does not accumulate thousands of stale cards.
      final notificationId = _nextNewChapterNotificationId++;
      if (_nextNewChapterNotificationId >= _kNewChapterNotificationIdCeiling) {
        _nextNewChapterNotificationId = 1001;
      }
      _newChapterNotificationIds.add(notificationId);
      while (_newChapterNotificationIds.length > _kMaxNewChapterNotifications) {
        final oldest = _newChapterNotificationIds.removeAt(0);
        try {
          await _plugin.cancel(id: oldest);
        } catch (e) {
          // A notification the OS has already dropped is not a failure worth
          // surfacing; the post below is what matters.
          debugPrint('[NotificationService] Could not clear an old new-chapters notification: $e');
        }
      }
      await _plugin.show(
        id: notificationId,
        title: title,
        body: body,
        notificationDetails: details,
        payload: '/updates',
      );
      debugPrint('[NotificationService] Dispatched new chapter notification: "$title" - "$body"');
    } catch (e) {
      debugPrint('[NotificationService] Failed to dispatch notification: $e');
    }
  }

  // ── DOWNLOAD NOTIFICATIONS ──────────────────────────────────────────

  /// Shows/updates an ongoing progress notification for active downloads.
  /// Used on non-Android platforms (Android uses the foreground-service
  /// notification via `DownloadForegroundTask` instead so users don't see two).
  Future<void> showDownloadProgress({
    required String title,
    required String body,
    double? progress,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final androidDetails = AndroidNotificationDetails(
      downloadsChannelId,
      downloadsChannelName,
      channelDescription: downloadsChannelDescription,
      importance: Importance.low,
      priority: Priority.low,
      onlyAlertOnce: true,
      ongoing: true,
      autoCancel: false,
      showProgress: true,
      progress: progress == null ? 0 : (progress.clamp(0.0, 1.0) * 100).round(),
      maxProgress: 100,
      indeterminate: progress == null,
      category: AndroidNotificationCategory.progress,
      icon: '@mipmap/launcher_icon',
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: false,
      presentBadge: false,
      presentSound: false,
    );

    const linuxDetails = LinuxNotificationDetails();

    final details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
      linux: linuxDetails,
    );

    try {
      await _plugin.show(
        id: downloadProgressNotificationId,
        title: title,
        body: body,
        notificationDetails: details,
        payload: '/downloads',
      );
    } catch (e) {
      debugPrint('[NotificationService] Failed to update download progress notification: $e');
    }
  }

  /// Hides the ongoing download-progress notification.
  Future<void> cancelDownloadProgressNotification() async {
    try {
      if (!_isInitialized) return;
      await _plugin.cancel(id: downloadProgressNotificationId);
    } catch (e) {
      debugPrint('[NotificationService] Failed to cancel download progress notification: $e');
    }
  }

  /// Pure text builder for the batch-completion summary. Extracted so tests
  /// can assert the exact user-facing strings without a plugin instance.
  static ({String title, String body}) downloadsCompletionSummary({
    required int succeeded,
    required int failed,
    required int total,
  }) {
    String title;
    String body;
    if (failed > 0) {
      title = failed == total ? '$failed Downloads Failed' : '$total Chapters Downloaded';
      body = failed == total
          ? 'All $total downloads failed. Check the Downloads queue for details.'
          : '$succeeded succeeded, $failed failed. Check the Downloads queue for details.';
    } else {
      title = 'Downloads Completed';
      body = total == 1 ? '1 chapter downloaded' : '$total chapters downloaded';
    }
    return (title: title, body: body);
  }

  /// Pure text builder for the background-resume notification. Extracted so
  /// tests can assert the exact user-facing strings without a plugin instance.
  static ({String title, String body}) downloadsResumedSummary({required int queuedCount}) {
    final title = 'Downloads resumed';
    final body = queuedCount == 1
        ? '1 download was paused in the background and has resumed now that the app is open.'
        : '$queuedCount downloads were paused in the background and have resumed now that the app is open.';
    return (title: title, body: body);
  }

  /// Posts a completion/failure summary for a finished download batch.
  Future<void> showDownloadsCompleted({
    required int succeeded,
    required int failed,
    required int total,
  }) async {
    if (total <= 0 || !SettingsService.instance.downloadNotificationsEnabled) return;
    if (!_isInitialized) {
      await initialize();
    }

    final summary = downloadsCompletionSummary(succeeded: succeeded, failed: failed, total: total);
    final title = summary.title;
    final body = summary.body;

    final androidDetails = AndroidNotificationDetails(
      downloadsChannelId,
      downloadsChannelName,
      channelDescription: downloadsChannelDescription,
      importance: Importance.low,
      priority: Priority.low,
      onlyAlertOnce: true,
      category: AndroidNotificationCategory.status,
      styleInformation: BigTextStyleInformation(body, contentTitle: title),
      icon: '@mipmap/launcher_icon',
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const linuxDetails = LinuxNotificationDetails();

    final details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
      linux: linuxDetails,
    );

    try {
      await _plugin.cancel(id: downloadProgressNotificationId);
      await _plugin.show(
        id: downloadSummaryNotificationId,
        title: title,
        body: body,
        notificationDetails: details,
        payload: '/downloads',
      );
      debugPrint('[NotificationService] Downloads finished notification: "$title" - "$body"');
    } catch (e) {
      debugPrint('[NotificationService] Failed to dispatch downloads finished notification: $e');
    }
  }

  /// Informs the user that active downloads were interrupted while the app was
  /// in the background and have been resumed on foreground. iOS/macOS suspend
  /// transfers (no `UIBackgroundModes`), so this makes the pause explicit
  /// instead of silent. No-op when download notifications are disabled.
  Future<void> showDownloadsResumedNotification({required int queuedCount}) async {
    if (queuedCount <= 0 || !SettingsService.instance.downloadNotificationsEnabled) return;
    if (!_isInitialized) {
      await initialize();
    }

    final summary = downloadsResumedSummary(queuedCount: queuedCount);
    final title = summary.title;
    final body = summary.body;

    final androidDetails = AndroidNotificationDetails(
      downloadsChannelId,
      downloadsChannelName,
      channelDescription: downloadsChannelDescription,
      importance: Importance.low,
      priority: Priority.low,
      onlyAlertOnce: true,
      category: AndroidNotificationCategory.status,
      styleInformation: BigTextStyleInformation(body, contentTitle: title),
      icon: '@mipmap/launcher_icon',
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: false,
      presentBadge: true,
      presentSound: false,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
      linux: const LinuxNotificationDetails(),
    );

    try {
      await _plugin.show(
        id: downloadsResumedNotificationId,
        title: title,
        body: body,
        notificationDetails: details,
        payload: '/downloads',
      );
      debugPrint('[NotificationService] Downloads resumed notification posted');
    } catch (e) {
      debugPrint('[NotificationService] Failed to dispatch downloads resumed notification: $e');
    }
  }

  void dispose() {
    _selectNotificationStream.close();
  }
}
