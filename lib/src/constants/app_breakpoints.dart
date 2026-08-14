import 'package:flutter/widgets.dart';

/// Shared layout breakpoints for iOS, Android, and desktop shells.
abstract final class AppBreakpoints {
  static const double tabletMinWidth = 600;
  static const double compactNavMaxShortestSide = 600;
  static const double narrowTabletMaxWidth = 700;

  static bool isTabletLayout(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tabletMinWidth;

  static bool isCompactNav(BuildContext context) =>
      MediaQuery.sizeOf(context).shortestSide < compactNavMaxShortestSide;

  /// Phone shell instead of sidebar rail when the window is tablet-class but
  /// too narrow for rail + master–detail (Stage Manager / foldables / small
  /// landscape tablets).
  static bool useCompactShellOnNarrowTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width < narrowTabletMaxWidth;

  @Deprecated('Use useCompactShellOnNarrowTablet')
  static bool useCompactShellOnIPad(BuildContext context) =>
      useCompactShellOnNarrowTablet(context);
}
