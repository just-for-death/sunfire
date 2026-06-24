import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../features/notifications/notification_service.dart';

/// Requests notification permission on Android 13+ and iOS.
abstract final class MobilePermissions {
  static bool _requested = false;

  static FlutterLocalNotificationsPlugin get _plugin =>
      NotificationService.instance.notificationsPlugin;

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
      if (await isNotificationGranted()) return true;
      final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
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

  /// Whether notifications are currently allowed (no prompt).
  static Future<bool> isNotificationGranted() async {
    if (kIsWeb) return true;
    if (!Platform.isAndroid && !Platform.isIOS) return true;

    if (Platform.isAndroid) {
      return (await Permission.notification.status).isGranted;
    }

    if (Platform.isIOS) {
      final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final settings = await iosPlugin?.checkPermissions();
      return settings?.isEnabled ?? false;
    }

    return true;
  }

  /// True when the user must open system settings to enable notifications.
  static Future<bool> needsNotificationSettings() async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return false;

    if (await isNotificationGranted()) return false;

    if (Platform.isAndroid) {
      return (await Permission.notification.status).isPermanentlyDenied;
    }

    // iOS does not re-prompt after denial.
    return true;
  }

  /// Opens system settings when notification permission was permanently denied.
  static Future<void> openNotificationSettings() => openAppSettings();

  /// Call once after app start; idempotent per session.
  static Future<void> requestNotificationsOnStartup() async {
    if (_requested) return;
    _requested = true;
    await ensureNotificationPermission();
  }
}
