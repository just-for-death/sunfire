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

  /// Stream of notification payloads tapped by user (e.g. '/updates')
  final StreamController<String?> _selectNotificationStream = StreamController<String?>.broadcast();
  Stream<String?> get onNotificationTapped => _selectNotificationStream.stream;

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
}
