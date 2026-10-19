// sunfire_nav.dart
//
// C5.6: Navigation - tabs / rail / bottom-nav (live Android chrome adapters).

library;

import 'package:flutter/material.dart';

/// A tab destination shared by tab bar, rail, and bottom nav.
///
/// Matches live [nav_chrome] fields so shell + design-system share one model.
class SunfireNavDestination {
  const SunfireNavDestination({
    required this.label,
    required this.icon,
    IconData? activeIcon,
    IconData? selectedIcon,
    this.badgeCount,
    this.badge,
  }) : activeIcon = activeIcon ?? selectedIcon ?? icon;

  final String label;
  final IconData icon;
  /// Preferred selected-state icon (nav_chrome name).
  final IconData activeIcon;
  final int? badgeCount;
  /// Optional string badge (design-system tests); ignored when [badgeCount] set.
  final String? badge;

  /// Alias for [activeIcon] (older design-system API).
  IconData get selectedIcon => activeIcon;
}

/// Sunfire tab bar (top, scrollable optional).
class SunfireTabBar extends StatelessWidget implements PreferredSizeWidget {
  const SunfireTabBar({
    super.key,
    required this.destinations,
    this.controller,
    this.isScrollable = false,
  });

  final List<SunfireNavDestination> destinations;
  final TabController? controller;
  final bool isScrollable;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight - 8);

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      isScrollable: isScrollable,
      tabs: [
        for (final d in destinations)
          Tab(text: d.label, icon: Icon(d.icon)),
      ],
    );
  }
}

Widget _badgeIcon(SunfireNavDestination d, {required bool selected}) {
  final icon = Icon(selected ? d.activeIcon : d.icon);
  final count = d.badgeCount;
  if (count != null && count > 0) {
    return Badge.count(count: count, child: icon);
  }
  if (d.badge != null && d.badge!.isNotEmpty) {
    return Badge(label: Text(d.badge!), child: icon);
  }
  return icon;
}

/// Sunfire navigation rail (tablet / desktop) — used by live Android tablet chrome.
class SunfireNavRail extends StatelessWidget {
  const SunfireNavRail({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.extended = false,
    this.leading,
    this.trailing,
    this.scrollable = false,
    this.minExtendedWidth = 200,
  });

  final List<SunfireNavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final bool extended;
  final Widget? leading;
  final Widget? trailing;
  final bool scrollable;
  final double minExtendedWidth;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      extended: extended,
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      minExtendedWidth: minExtendedWidth,
      labelType:
          extended ? NavigationRailLabelType.none : NavigationRailLabelType.all,
      leading: leading,
      trailing: trailing,
      leadingAtTop: true,
      trailingAtBottom: true,
      scrollable: scrollable,
      destinations: [
        for (final d in destinations)
          NavigationRailDestination(
            icon: _badgeIcon(d, selected: false),
            selectedIcon: _badgeIcon(d, selected: true),
            label: Text(d.label),
          ),
      ],
    );
  }
}

/// Sunfire bottom navigation bar (phones) — used by live Android phone chrome.
class SunfireBottomNav extends StatelessWidget {
  const SunfireBottomNav({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.compact = false,
    this.onMore,
  });

  final List<SunfireNavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  /// Compact: first 4 destinations + More (calls [onMore]).
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
      if (compact && displayIndex == 4) {
        onMore?.call();
        return;
      }
      onDestinationSelected(displayIndex);
    }

    return NavigationBar(
      height: 64,
      selectedIndex: _displaySelectedIndex,
      onDestinationSelected: onTap,
      destinations: [
        for (final d in items)
          NavigationDestination(
            icon: _badgeIcon(d, selected: false),
            selectedIcon: _badgeIcon(d, selected: true),
            label: d.label,
            tooltip: d.label,
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
