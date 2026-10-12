// sunfire_nav.dart
//
// C5.6: Navigation - tabs / rail / bottom-nav.

library;

import 'package:flutter/material.dart';

/// A tab destination shared by tab bar, rail, and bottom nav.
class SunfireNavDestination {
  const SunfireNavDestination({
    required this.label,
    required this.icon,
    this.selectedIcon,
    this.badge,
  });

  final String label;
  final IconData icon;
  final IconData? selectedIcon;
  final String? badge;
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

/// Sunfire navigation rail (tablet / desktop).
class SunfireNavRail extends StatelessWidget {
  const SunfireNavRail({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.extended = false,
  });

  final List<SunfireNavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final bool extended;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      extended: extended,
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: [
        for (final d in destinations)
          NavigationRailDestination(
            icon: Badge(
              label: d.badge == null ? null : Text(d.badge!),
              isLabelVisible: d.badge != null,
              child: Icon(d.icon),
            ),
            selectedIcon: d.selectedIcon == null
                ? null
                : Badge(
                    label:
                        d.badge == null ? null : Text(d.badge!),
                    isLabelVisible: d.badge != null,
                    child: Icon(d.selectedIcon),
                  ),
            label: Text(d.label),
          ),
      ],
    );
  }
}

/// Sunfire bottom navigation bar (phones).
class SunfireBottomNav extends StatelessWidget {
  const SunfireBottomNav({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final List<SunfireNavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: [
        for (final d in destinations)
          NavigationDestination(
            icon: Badge(
              label: d.badge == null ? null : Text(d.badge!),
              isLabelVisible: d.badge != null,
              child: Icon(d.icon),
            ),
            selectedIcon: d.selectedIcon == null
                ? null
                : Badge(
                    label:
                        d.badge == null ? null : Text(d.badge!),
                    isLabelVisible: d.badge != null,
                    child: Icon(d.selectedIcon),
                  ),
            label: d.label,
          ),
      ],
    );
  }
}
