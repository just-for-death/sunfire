import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../routes/router_config.dart';

/// Routes notification taps to the correct shell tab / screen.
abstract final class NotificationNavigation {
  static const int chapterUpdateSummaryId = 1001;
  static const int extensionUpdateId = 1002;
  static const int mangaUpdateIdOffset = 2000;

  static void handleTap(int? notificationId) {
    if (notificationId == null) return;
    final BuildContext? context = rootNavigatorKey.currentContext;
    if (context == null) return;

    if (notificationId == extensionUpdateId) {
      context.go(const BrowseExtensionRoute().location);
      return;
    }
    if (notificationId == chapterUpdateSummaryId ||
        notificationId >= mangaUpdateIdOffset) {
      context.go(const UpdatesRoute().location);
    }
  }
}
