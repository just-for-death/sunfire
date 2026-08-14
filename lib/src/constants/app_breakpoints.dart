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

  /// True when navigation lives in a side rail beside a master–detail body.
  ///
  /// The shortest-side check keeps large phones in landscape on the phone shell:
  /// they are wide enough for a rail but far too short for one.
  static bool usesSideRail(BuildContext context) =>
      isTabletLayout(context) &&
      !useCompactShellOnNarrowTablet(context) &&
      !isCompactNav(context);

  @Deprecated('Use useCompactShellOnNarrowTablet')
  static bool useCompactShellOnIPad(BuildContext context) =>
      useCompactShellOnNarrowTablet(context);
}
