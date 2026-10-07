import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Platform-adaptive navigation chrome for Sunfire.
///
/// Sunfire's 5 tabs and extras:
///
/// - iOS/iPhone: frosted-glass floating pill tab bar (Sunfire's signature),
///   with text-scaler clamping and Semantics.
/// - Android phone: Material 3 [NavigationBar].
/// - Android tablet / desktop / wide: Material 3 [NavigationRail].
/// - Narrow windows: compact mode — first 4 tabs + a "More" overflow sheet
///   (Settings, Downloads, Stats).
///
/// Haptics follow the platform: light impact on iOS, selection click
/// elsewhere — matching what `MainShell` already did.

/// A single tab destination.
class SunfireNavDestination {
  const SunfireNavDestination({
    required this.label,
    required this.icon,
    required this.activeIcon,
    this.badgeCount,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final int? badgeCount;
}

/// Sunfire's five tabs, in route order.
List<SunfireNavDestination> sunfireNavDestinations({int? updatesBadge}) => [
      const SunfireNavDestination(
        label: 'Library',
        icon: Icons.auto_stories_outlined,
        activeIcon: Icons.auto_stories_rounded,
      ),
      SunfireNavDestination(
        label: 'Updates',
        icon: Icons.notifications_outlined,
        activeIcon: Icons.notifications_rounded,
        badgeCount: updatesBadge,
      ),
      const SunfireNavDestination(
        label: 'History',
        icon: Icons.history_outlined,
        activeIcon: Icons.history_rounded,
      ),
      const SunfireNavDestination(
        label: 'Browse',
        icon: Icons.explore_outlined,
        activeIcon: Icons.explore_rounded,
      ),
      const SunfireNavDestination(
        label: 'Settings',
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings_rounded,
      ),
    ];

void sunfireNavHaptic(BuildContext context) {
  if (Theme.of(context).platform == TargetPlatform.iOS) {
    unawaited(HapticFeedback.lightImpact());
  } else {
    unawaited(HapticFeedback.selectionClick());
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// iOS — frosted-glass floating pill (Sunfire's signature phone chrome)
// ─────────────────────────────────────────────────────────────────────────────

/// iPhone-style frosted-glass floating pill tab bar.
///
/// Extracted from `MainShell`'s phone chrome so Android can diverge to
/// Material 3 while iOS keeps the glass identity. Adds what the inline
/// version lacked: text-scaler clamping (so large accessibility text cannot
/// overflow the 5-up row), [Semantics] selected state per tab, and compact
/// overflow mode (first 4 tabs + More sheet) for narrow windows.
class IOSGlassTabBar extends StatelessWidget {
  const IOSGlassTabBar({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelect,
    this.compact = false,
    this.onMore,
    this.maxWidth = 460,
  });

  final List<SunfireNavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  /// Compact mode: show the first 4 destinations plus a "More" button that
  /// calls [onMore] (overflow sheet). Required when [compact] is true.
  final bool compact;
  final VoidCallback? onMore;
  final double maxWidth;

  int get _displaySelectedIndex {
    if (!compact) return selectedIndex;
    if (selectedIndex <= 3) return selectedIndex;
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textScaler = MediaQuery.textScalerOf(context)
        .clamp(minScaleFactor: 0.85, maxScaleFactor: 2.0);
    final items = compact ? destinations.take(4).toList() : destinations;
    final reduceEffects = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    return SafeArea(
      // heightFactor 1: size to the pill, not the whole screen, so the
      // shell's extendBody padding (UIS-02 scrollBottomPadding) is the real
      // bar height.
      child: Align(
        alignment: Alignment.bottomCenter,
        heightFactor: 1.0,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: cs.shadow.withValues(
                      alpha: cs.brightness == Brightness.dark ? 0.55 : 0.15),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            // UIS-17: isolate the bar's layer and keep the blur cheap. A 15σ
            // blur (was 30σ) halves the kernel cost on every scroll frame;
            // with reduce-motion / disableAnimations the blur is skipped and
            // a near-opaque static tint is used instead.
            child: RepaintBoundary(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: maybeBlur(
                  reduceEffects: reduceEffects,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainer
                          .withValues(alpha: reduceEffects ? 0.96 : 0.8),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                          color: cs.outlineVariant.withValues(alpha: 0.3),
                          width: 0.8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (var i = 0; i < items.length; i++)
                          _GlassTabItem(
                            destination: items[i],
                            selected: i == _displaySelectedIndex,
                            textScaler: textScaler,
                            accent: cs.primary,
                            onTap: () {
                              sunfireNavHaptic(context);
                              onSelect(i);
                            },
                          ),
                        if (compact)
                          _GlassMoreItem(
                            selected: _displaySelectedIndex == 4,
                            textScaler: textScaler,
                            onTap: () {
                              sunfireNavHaptic(context);
                              onMore?.call();
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Blur sigma for the glass tab bar (UIS-17).
  static const double glassBlurSigma = 15;

  /// Backdrop blur, or just [child] (caller paints a near-opaque static
  /// tint) when [reduceEffects] is on. Shared with the iPad sidebar.
  static Widget maybeBlur(
      {required bool reduceEffects,
      double sigma = glassBlurSigma,
      required Widget child}) {
    if (reduceEffects) return child;
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
      child: child,
    );
  }
}

class _GlassTabItem extends StatelessWidget {
  const _GlassTabItem({
    required this.destination,
    required this.selected,
    required this.textScaler,
    required this.accent,
    required this.onTap,
  });

  final SunfireNavDestination destination;
  final bool selected;
  final TextScaler textScaler;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final iconSize = textScaler.scale(22.0).clamp(20.0, 30.0);
    final labelSize = textScaler.scale(12.0).clamp(9.0, 14.0);
    final badge = destination.badgeCount ?? 0;

    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: destination.label,
        child: Tooltip(
          message: destination.label,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.symmetric(
                    horizontal: selected ? 10 : 6, vertical: 8),
                decoration: selected
                    ? BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withAlpha(80),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      )
                    : null,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Badge.count(
                      count: badge,
                      isLabelVisible: badge > 0,
                      child: Icon(
                        selected ? destination.activeIcon : destination.icon,
                        color: selected ? cs.onPrimary : cs.onSurfaceVariant,
                        size: iconSize,
                      ),
                    ),
                    if (selected) ...[
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          destination.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: cs.onPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: labelSize,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassMoreItem extends StatelessWidget {
  const _GlassMoreItem({
    required this.selected,
    required this.textScaler,
    required this.onTap,
  });

  final bool selected;
  final TextScaler textScaler;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final iconSize = textScaler.scale(22.0).clamp(20.0, 30.0);
    final labelSize = textScaler.scale(12.0).clamp(9.0, 14.0);

    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: 'More',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.more_horiz_rounded,
                    color: selected ? cs.primary : cs.onSurfaceVariant,
                    size: iconSize,
                  ),
                  Text(
                    'More',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: selected ? cs.primary : cs.onSurfaceVariant,
                      fontWeight:
                          selected ? FontWeight.bold : FontWeight.normal,
                      fontSize: labelSize,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Android — Material 3 bottom bar + rail
// ─────────────────────────────────────────────────────────────────────────────

/// Android phone chrome: standard Material 3 [NavigationBar].
class AndroidPhoneNavBar extends StatelessWidget {
  const AndroidPhoneNavBar({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelect,
    this.compact = false,
    this.onMore,
  });

  final List<SunfireNavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final bool compact;
  final VoidCallback? onMore;

  int get _displaySelectedIndex {
    if (!compact) return selectedIndex;
    if (selectedIndex <= 3) return selectedIndex;
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    final items = compact ? destinations.take(4).toList() : destinations;

    void onTap(int displayIndex) {
      sunfireNavHaptic(context);
      if (compact && displayIndex == 4) {
        onMore?.call();
        return;
      }
      onSelect(displayIndex);
    }

    return NavigationBar(
      selectedIndex: _displaySelectedIndex,
      onDestinationSelected: onTap,
      destinations: [
        for (var i = 0; i < items.length; i++)
          NavigationDestination(
            icon: Badge.count(
              count: items[i].badgeCount ?? 0,
              isLabelVisible: (items[i].badgeCount ?? 0) > 0,
              child: Icon(items[i].icon),
            ),
            selectedIcon: Badge.count(
              count: items[i].badgeCount ?? 0,
              isLabelVisible: (items[i].badgeCount ?? 0) > 0,
              child: Icon(items[i].activeIcon),
            ),
            label: items[i].label,
            tooltip: items[i].label,
          ),
        if (compact)
          const NavigationDestination(
            icon: Icon(Icons.more_horiz_rounded),
            selectedIcon: Icon(Icons.more_horiz_rounded),
            label: 'More',
            tooltip: 'More',
          ),
      ],
    );
  }
}

/// Android tablet / desktop chrome: Material 3 [NavigationRail].
class AndroidTabletRail extends StatelessWidget {
  const AndroidTabletRail({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelect,
    this.extended = false,
    this.leading,
    this.trailing,
  });

  final List<SunfireNavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final bool extended;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: (i) {
        sunfireNavHaptic(context);
        onSelect(i);
      },
      extended: extended,
      minExtendedWidth: 200,
      labelType:
          extended ? NavigationRailLabelType.none : NavigationRailLabelType.all,
      leading: leading,
      destinations: [
        for (final d in destinations)
          NavigationRailDestination(
            icon: Badge.count(
              count: d.badgeCount ?? 0,
              isLabelVisible: (d.badgeCount ?? 0) > 0,
              child: Icon(d.icon),
            ),
            selectedIcon: Badge.count(
              count: d.badgeCount ?? 0,
              isLabelVisible: (d.badgeCount ?? 0) > 0,
              child: Icon(d.activeIcon),
            ),
            label: Text(d.label),
          ),
      ],
      trailing: trailing,
      // UIS-P2-B: header (Continue reading) pinned top, Downloads/Stats
      // pinned bottom, destinations scroll on short windows (landscape
      // phones) instead of overflowing.
      leadingAtTop: true,
      trailingAtBottom: true,
      scrollable: true,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Compact overflow sheet
// ─────────────────────────────────────────────────────────────────────────────

/// Overflow sheet for compact mode: the destinations that did not fit in
/// the bar, plus Sunfire's extra places (Downloads, Stats).
class NavOverflowSheet extends StatelessWidget {
  const NavOverflowSheet({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelect,
    required this.extraActions,
  });

  final List<SunfireNavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final List<NavOverflowAction> extraActions;

  /// Shows the sheet. Returns the selected tab index, or null if dismissed.
  /// Extra actions navigate themselves and return null.
  static Future<int?> show(
    BuildContext context, {
    required List<SunfireNavDestination> destinations,
    required int selectedIndex,
    required List<NavOverflowAction> extraActions,
  }) {
    return showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => NavOverflowSheet(
        destinations: destinations,
        selectedIndex: selectedIndex,
        onSelect: (i) => Navigator.pop(ctx, i),
        extraActions: extraActions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('More', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            for (var i = 0; i < destinations.length; i++)
              ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                selected: i == selectedIndex,
                selectedTileColor: cs.primaryContainer.withValues(alpha: 0.4),
                leading: Icon(i == selectedIndex
                    ? destinations[i].activeIcon
                    : destinations[i].icon),
                title: Text(destinations[i].label),
                trailing: (destinations[i].badgeCount ?? 0) > 0
                    ? Badge.count(count: destinations[i].badgeCount ?? 0)
                    : null,
                onTap: () => onSelect(i),
              ),
            if (extraActions.isNotEmpty) ...[
              const Divider(height: 24),
              for (final a in extraActions)
                ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  leading: Icon(a.icon),
                  title: Text(a.label),
                  trailing: a.badgeCount != null && a.badgeCount! > 0
                      ? Badge.count(count: a.badgeCount!)
                      : const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.pop(context);
                    a.onTap();
                  },
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class NavOverflowAction {
  const NavOverflowAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.badgeCount,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final int? badgeCount;
}

/// Whether [context] is on an Apple-mobile platform (iOS).
bool isAppleMobile(BuildContext context) {
  if (kIsWeb) return false;
  return Theme.of(context).platform == TargetPlatform.iOS;
}
