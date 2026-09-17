import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../db/models/chapter.dart';
import 'settings_service.dart';

/// Top-level callback for notification responses in background or foreground
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  debugPrint('[NotificationService] Notification tapped with payload: ${response.payload}');
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  static const String channelId = 'sunfire_new_chapters';
  static const String channelName = 'New Chapters';
  static const String channelDescription = 'Alerts when new chapters are available for your library';

  // ── Downloads channel & notification ids ─────────────────────────────
  static const String downloadsChannelId = 'sunfire_downloads';
  static const String downloadsChannelName = 'Downloads';
  static const String downloadsChannelDescription = 'Progress and completion of chapter downloads';

  static const int downloadProgressNotificationId = 4001;
  static const int downloadSummaryNotificationId = 4002;

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

          // Request notification permission for Android 13+
          await androidPlugin.requestNotificationsPermission();
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
      await _plugin.show(
        id: 1001,
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
}
