import 'package:flutter/material.dart';

import '../utils/extensions/custom_extensions.dart';

class NavigationBarData {
  final String Function(BuildContext context) label;
  final IconData icon;
  final IconData activeIcon;

  // Catalyst tab order: History · Library · Explore · Feed · Downloads · More
  static final phoneNavList = [
    NavigationBarData(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: (context) => context.l10n.navHome,
    ),
    NavigationBarData(
      icon: Icons.favorite_border_rounded,
      activeIcon: Icons.favorite_rounded,
      label: (context) => context.l10n.library,
    ),
    NavigationBarData(
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore_rounded,
      label: (context) => context.l10n.browse,
    ),
    NavigationBarData(
      icon: Icons.rss_feed_outlined,
      activeIcon: Icons.rss_feed_rounded,
      label: (context) => context.l10n.updates,
    ),
    NavigationBarData(
      icon: Icons.download_outlined,
      activeIcon: Icons.download_rounded,
      label: (context) => context.l10n.downloads,
    ),
    NavigationBarData(
      icon: Icons.more_horiz_outlined,
      activeIcon: Icons.more_horiz_rounded,
      label: (context) => context.l10n.more,
    ),
  ];

  static final tabletNavList = phoneNavList;

  /// Full six destinations (tablet, desktop rail, wide phone).
  static List<NavigationBarData> getNavList(BuildContext context) =>
      phoneNavList;

  /// Five destinations for narrow phones; last item opens Downloads / More sheet.
  static List<NavigationBarData> getCompactPhoneNavList(BuildContext context) =>
      [
        phoneNavList[0],
        phoneNavList[1],
        phoneNavList[2],
        phoneNavList[3],
        NavigationBarData(
          icon: Icons.menu_rounded,
          activeIcon: Icons.menu_open_rounded,
          label: (c) => c.l10n.navMenu,
        ),
      ];

  static final navList = phoneNavList;

  NavigationBarData({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}
