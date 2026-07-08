import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../routes/router_config.dart';
import '../manga_book/presentation/manga_details/controller/manga_details_controller.dart';

/// Routes notification taps to the correct shell tab / screen.
abstract final class NotificationNavigation {
  static const int chapterUpdateSummaryId = 1001;
  static const int extensionUpdateId = 1002;
  static const int mangaUpdateIdOffset = 2000;

  static int? _pendingNotificationId;
  static String? _pendingPayload;
  static int _pendingAttempts = 0;
  static const int _maxPendingAttempts = 600;
  static int _delayedRetries = 0;
  static const int _maxDelayedRetries = 5;

  /// Call after [NotificationService.init] when the app was launched from a notification.
  static void scheduleTap(int? notificationId, {String? payload}) {
    if (notificationId == null) return;
    _pendingNotificationId = notificationId;
    _pendingPayload = payload;
    _pendingAttempts = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) => processPending());
  }

  static void handleTap(int? notificationId, {String? payload}) {
    if (notificationId == null) return;
    final BuildContext? context = rootNavigatorKey.currentContext;
    if (context == null) {
      scheduleTap(notificationId, payload: payload);
      return;
    }
    _navigate(context, notificationId, payload: payload);
  }

  /// Retries navigation until the root navigator context is available.
  static void processPending() {
    final id = _pendingNotificationId;
    if (id == null) return;

    if (_pendingAttempts >= _maxPendingAttempts) {
      if (_delayedRetries < _maxDelayedRetries) {
        _delayedRetries++;
        _pendingAttempts = 0;
        Future.delayed(const Duration(seconds: 1), processPending);
        return;
      }
      _pendingNotificationId = null;
      _pendingPayload = null;
      _pendingAttempts = 0;
      _delayedRetries = 0;
      return;
    }
    _pendingAttempts++;

    final BuildContext? context = rootNavigatorKey.currentContext;
    if (context == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => processPending());
      return;
    }

    final payload = _pendingPayload;
    _pendingNotificationId = null;
    _pendingPayload = null;
    _pendingAttempts = 0;
    _delayedRetries = 0;
    _navigate(context, id, payload: payload);
  }

  static void _navigate(
    BuildContext context,
    int notificationId, {
    String? payload,
  }) {
    if (!context.mounted) return;
    if (notificationId == extensionUpdateId) {
      context.go(const BrowseExtensionRoute().location);
      return;
    }
    if (notificationId == chapterUpdateSummaryId) {
      context.go(const UpdatesRoute().location);
      return;
    }
    if (notificationId >= mangaUpdateIdOffset) {
      final mangaId = _mangaIdFromPayload(payload) ??
          notificationId - mangaUpdateIdOffset;
      _openMangaOrReader(context, mangaId);
    }
  }

  static int? _mangaIdFromPayload(String? payload) {
    if (payload == null || !payload.startsWith('manga:')) return null;
    return int.tryParse(payload.substring(6));
  }

  static Future<void> _openMangaOrReader(
    BuildContext context,
    int mangaId,
  ) async {
    if (!context.mounted) return;
    try {
      final container = ProviderScope.containerOf(context);
      final chapters =
          await container.read(mangaChapterListProvider(mangaId: mangaId).future);
      if (!context.mounted) return;

      final unread = chapters?.where((c) => c.isRead != true).firstOrNull;
      final target = unread ?? chapters?.firstOrNull;
      if (target != null) {
        await ReaderRoute(mangaId: mangaId, chapterId: target.id)
            .push(context);
        return;
      }
    } catch (_) {
      // Fall back to manga details.
    }
    if (context.mounted) {
      context.go(MangaRoute(mangaId: mangaId).location);
    }
  }
}
