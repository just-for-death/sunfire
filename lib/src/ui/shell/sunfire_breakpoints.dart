import 'package:flutter/widgets.dart';

/// Shared layout breakpoints for Sunfire's platform-adaptive shell.
///
/// Phone, narrow-tablet (Stage Manager / foldables / small landscape tablets)
/// and wide-tablet layouts behave as follows:
///
/// - phone shell below 600dp width
/// - compact (overflow-menu) shell when the window is tablet-class but too
///   narrow for rail + content, or when the shortest side is phone-class
///   (large phones in landscape stay on the phone shell under Auto mode)
/// - side rail beside the content otherwise
///
/// Layout always reacts to [MediaQuery] window size (Split View / Stage
/// Manager), never raw device type alone (UIS-P2-A).
///
/// Optional [tabletUiMode] on [usesSideRailForSize] mirrors Mihon's
/// Auto / Always / Landscape / Never. Wire a Settings preference once
/// settings_service is stable (deferred UIS-P2-A; see ISSUES).
abstract final class SunfireBreakpoints {
  static const double tabletMinWidth = 600;
  static const double compactNavMaxShortestSide = 600;
  static const double narrowTabletMaxWidth = 720;

  /// Mihon-style Tablet UI mode labels (for settings + tests).
  static const List<String> tabletUiModeOptions = [
    'Auto',
    'Always',
    'Landscape',
    'Never',
  ];

  /// Override applied by [usesSideRail] / [hasBottomNav]. Defaults to Auto.
  /// Set from settings when the preference is wired; tests may assign directly.
  static String tabletUiMode = 'Auto';

  /// Phone vs tablet split for the shell chrome.
  ///
  /// 600 matches Material 3's window-size classes. Whether the
  /// shell shows a rail or a bottom bar is [usesSideRail]; size-only density
  /// tweaks in screens read [narrowTabletMaxWidth] (UIS-02).
  static bool isTabletLayout(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tabletMinWidth;

  /// Width below which the phone bar drops to 4 tabs + "More".
  static const double compactNavMaxWidth = 360;

  /// Text scale above which the phone bar drops to 4 tabs + "More".
  static const double compactNavMaxTextScale = 1.3;

  /// Phone bar overflow mode (4 tabs + "More"). Phones get all 5 tabs by
  /// default; "More" is only used when each tab would be too narrow:
  /// narrow windows or large accessibility text (UIS-09, option b).
  static bool isCompactNav(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
    return width < compactNavMaxWidth || scale > compactNavMaxTextScale;
  }

  /// Phone shell instead of sidebar rail when the window is tablet-class but
  /// too narrow for rail + master content.
  static bool useCompactShellOnNarrowTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width < narrowTabletMaxWidth;

  /// True when navigation lives in a side rail beside the content.
  ///
  /// Uses the current window [Size] (Split View / Stage Manager safe) and
  /// [tabletUiMode]. Do not replace with a raw `width >= 720` check.
  static bool usesSideRail(BuildContext context) => usesSideRailForSize(
        MediaQuery.sizeOf(context),
        mode: tabletUiMode,
      );

  /// True when the shell shows a bottom navigation bar (the inverse of
  /// [usesSideRail]). Use this, not a width literal, for chrome/padding.
  static bool hasBottomNav(BuildContext context) => !usesSideRail(context);

  /// Alias for [hasBottomNav] (research / Mihon-style naming).
  static bool hasBottomBar(BuildContext context) => hasBottomNav(context);

  /// Bottom padding for scrollables inside the shell.
  ///
  /// The phone shell uses `extendBody: true`, so the shell Scaffold already
  /// adds the bottom bar's real height to `MediaQuery.padding.bottom` for its
  /// body (nested Scaffolds without their own bottom bar keep it). With a side
  /// rail, or on a route pushed outside the shell, this is just the system
  /// inset. [extra] is breathing room (use ~80 when a batch dock is shown).
  static double scrollBottomPadding(BuildContext context, {double extra = 16}) =>
      MediaQuery.paddingOf(context).bottom + extra;

  /// Minimum content width for two-pane manga details (info left, persistent
  /// chapter list right). Mirrors `sunfireDetailTwoPaneMinWidth` (840).
  static const double detailTwoPaneMinWidth = 840;

  /// UIS-P2-D: two-pane manga details only on landscape tablet-class windows.
  ///
  /// Single wide-width gate: [contentWidth] (what the details screen actually
  /// gets, after any side rail) must be at least [detailTwoPaneMinWidth] (840,
  /// which is above [narrowTabletMaxWidth]). Additionally the [window] must be
  /// landscape and tablet-class (shortest side >= 600), so portrait iPads,
  /// Split View halves and landscape phones keep the single-pane layout.
  static bool usesTwoPaneDetailsForSize(Size window, double contentWidth) =>
      contentWidth >= detailTwoPaneMinWidth &&
      window.width > window.height &&
      window.shortestSide >= compactNavMaxShortestSide;

  /// Context form of [usesTwoPaneDetailsForSize] using the window size.
  static bool usesTwoPaneDetails(BuildContext context, double contentWidth) =>
      usesTwoPaneDetailsForSize(MediaQuery.sizeOf(context), contentWidth);

  /// Pure, size-based form of [usesSideRail] (width, shortest side, and
  /// optional Tablet UI mode override).
  ///
  /// [mode]: Auto / Always / Landscape / Never (case-sensitive).
  @visibleForTesting
  static bool usesSideRailForSize(Size s, {String mode = 'Auto'}) {
    switch (mode) {
      case 'Never':
        return false;
      case 'Always':
        // Large phones / foldables can force a rail whenever the window is
        // at least Material tablet-min width (Mihon "Always").
        return s.width >= tabletMinWidth;
      case 'Landscape':
        // Kotatsu-style w600dp-land: rail only in landscape tablet-min windows.
        return s.width >= tabletMinWidth && s.width > s.height;
      case 'Auto':
      default:
        return s.width >= tabletMinWidth &&
            s.width >= narrowTabletMaxWidth &&
            s.shortestSide >= compactNavMaxShortestSide;
    }
  }
}
