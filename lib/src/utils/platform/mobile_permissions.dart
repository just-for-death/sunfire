import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

/// Requests notification permission on Android 13+ and iOS.
abstract final class MobilePermissions {
  static bool _requested = false;

  static Future<bool> ensureNotificationPermission() async {
    if (kIsWeb) return true;
    if (!Platform.isAndroid && !Platform.isIOS) return true;

    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      if (status.isGranted) return true;
      if (status.isPermanentlyDenied) return false;
      final result = await Permission.notification.request();
      return result.isGranted;
    }

    if (Platform.isIOS) {
      final iosPlugin = FlutterLocalNotificationsPlugin()
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      if (iosPlugin == null) return false;
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: false,
      );
      return granted ?? false;
    }

    return true;
  }

  /// Call once after app start; idempotent per session.
  static Future<void> requestNotificationsOnStartup() async {
    if (_requested) return;
    _requested = true;
    await ensureNotificationPermission();
  }
}
