import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../routes/router_config.dart';

/// Routes notification taps to the correct shell tab / screen.
abstract final class NotificationNavigation {
  static const int chapterUpdateSummaryId = 1001;
  static const int extensionUpdateId = 1002;
  static const int mangaUpdateIdOffset = 2000;

  static int? _pendingNotificationId;
  static int _pendingAttempts = 0;
  static const int _maxPendingAttempts = 120;

  /// Call after [NotificationService.init] when the app was launched from a notification.
  static void scheduleTap(int? notificationId) {
    if (notificationId == null) return;
    _pendingNotificationId = notificationId;
    _pendingAttempts = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) => processPending());
  }

  static void handleTap(int? notificationId) {
    if (notificationId == null) return;
    final BuildContext? context = rootNavigatorKey.currentContext;
    if (context == null) {
      scheduleTap(notificationId);
      return;
    }
    _navigate(context, notificationId);
  }

  /// Retries navigation until the root navigator context is available.
  static void processPending() {
    final id = _pendingNotificationId;
    if (id == null) return;

    if (_pendingAttempts >= _maxPendingAttempts) {
      _pendingNotificationId = null;
      _pendingAttempts = 0;
      return;
    }
    _pendingAttempts++;

    final BuildContext? context = rootNavigatorKey.currentContext;
    if (context == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => processPending());
      return;
    }

    _pendingNotificationId = null;
    _pendingAttempts = 0;
    _navigate(context, id);
  }

  static void _navigate(BuildContext context, int notificationId) {
    if (notificationId == extensionUpdateId) {
      context.go(const BrowseExtensionRoute().location);
      return;
    }
    if (notificationId == chapterUpdateSummaryId) {
      context.go(const UpdatesRoute().location);
      return;
    }
    if (notificationId >= mangaUpdateIdOffset) {
      final mangaId = notificationId - mangaUpdateIdOffset;
      context.go(MangaRoute(mangaId: mangaId).location);
    }
  }
}
