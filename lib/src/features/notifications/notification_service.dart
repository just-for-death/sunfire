// Copyright (c) 2022 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../manga_book/domain/manga/manga_model.dart';

/// Singleton wrapper around FlutterLocalNotificationsPlugin.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  Map<String, String>? _headers;
  String? _baseUrl;

  /// Update base URL used for relative image paths.
  void updateBaseUrl(String? baseUrl) {
    _baseUrl = baseUrl;
  }

  /// Update headers used for image downloads (e.g. for Basic Auth).
  void updateHeaders(Map<String, String>? headers) {
    _headers = headers;
  }

  static const int _chapterUpdateId = 1001;
  static const int _extensionUpdateId = 1002;

  Future<void> init() async {
    if (_initialized) return;

    const initSettings = InitializationSettings(
      linux: LinuxInitializationSettings(defaultActionName: 'Open'),
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
      macOS: DarwinInitializationSettings(),
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = true;
  }

  void _onNotificationTap(NotificationResponse response) {
    // Could navigate to updates / extensions screen.
    // Navigation from outside widgets is complex — left for future.
    debugPrint('[Notifications] Tapped: ${response.id}');
  }

  /// Show a notification for a specific manga update.
  Future<void> showMangaUpdateNotification({
    required MangaDto manga,
    required int chaptersCount,
  }) async {
    if (!_initialized) await init();
    if (chaptersCount <= 0) return;

    String? iconPath;
    if (manga.thumbnailUrl != null && manga.thumbnailUrl!.isNotEmpty) {
      try {
        final tempDir = await getTemporaryDirectory();
        final fileName = 'notif_manga_${manga.id}.jpg';
        final filePath = p.join(tempDir.path, fileName);
        
        String url = manga.thumbnailUrl!;
        if (url.startsWith('/') && _baseUrl != null) {
          url = '$_baseUrl$url';
        }
        
        final response = await http.get(
          Uri.parse(url),
          headers: _headers,
        );
        if (response.statusCode == 200) {
          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);
          iconPath = filePath;
        }
      } catch (e) {
        debugPrint('[Notifications] Failed to download thumbnail for ${manga.title}: $e');
      }
    }

    await _plugin.show(
      // Use manga ID as the notification ID to allow multiple separate notifications.
      // We offset it to avoid collisions with other static notification IDs.
      2000 + manga.id.toInt(),
      manga.title,
      '$chaptersCount new ${chaptersCount == 1 ? 'chapter' : 'chapters'} available',
      NotificationDetails(
        linux: LinuxNotificationDetails(
          category: LinuxNotificationCategory.transferComplete,
          icon: iconPath != null ? FilePathLinuxIcon(iconPath) : null,
        ),
      ),
    );
  }

  /// Show a generic notification for library updates.
  @Deprecated('Use showMangaUpdateNotification instead for specific manga art')
  Future<void> showChapterUpdateNotification({
    required int newChaptersCount,
  }) async {
    if (!_initialized) await init();
    if (newChaptersCount <= 0) return;

    await _plugin.show(
      _chapterUpdateId,
      'Library Updated',
      '$newChaptersCount new ${newChaptersCount == 1 ? 'chapter' : 'chapters'} available',
      NotificationDetails(
        linux: LinuxNotificationDetails(
          category: LinuxNotificationCategory.transferComplete,
        ),
      ),
    );
  }

  /// Show a notification when extensions have pending updates.
  Future<void> showExtensionUpdateNotification({
    required int updateCount,
  }) async {
    if (!_initialized) await init();
    if (updateCount <= 0) return;

    await _plugin.show(
      _extensionUpdateId,
      'Extension Updates Available',
      '$updateCount ${updateCount == 1 ? 'extension has' : 'extensions have'} updates — check Browse',
      NotificationDetails(
        linux: LinuxNotificationDetails(
          category: LinuxNotificationCategory.transferComplete,
        ),
      ),
    );
  }

  /// Cancel all active notifications.
  Future<void> cancelAll() => _plugin.cancelAll();
}
