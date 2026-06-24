import 'package:flutter/widgets.dart';

/// Shared layout breakpoints for iOS, Android, and desktop shells.
abstract final class AppBreakpoints {
  static const double tabletMinWidth = 600;
  static const double compactNavMaxShortestSide = 600;
  static const double narrowIPadMaxWidth = 700;

  static bool isTabletLayout(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tabletMinWidth;

  static bool isCompactNav(BuildContext context) =>
      MediaQuery.sizeOf(context).shortestSide < compactNavMaxShortestSide;

  /// iPad in Stage Manager or split view — use phone shell instead of sidebar.
  static bool useCompactShellOnIPad(BuildContext context) =>
      MediaQuery.sizeOf(context).width < narrowIPadMaxWidth;
}
