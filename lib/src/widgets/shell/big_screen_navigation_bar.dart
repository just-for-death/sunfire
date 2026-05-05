// Copyright (c) 2022 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../constants/gen/assets.gen.dart';
import '../../constants/navigation_bar_data.dart';
import '../../routes/router_config.dart';
import '../../utils/extensions/custom_extensions.dart';
import 'nav_badge_providers.dart';

class BigScreenNavigationBar extends ConsumerWidget {
  const BigScreenNavigationBar(
      {super.key,
      required this.selectedIndex,
      required this.onDestinationSelected});

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  NavigationRailDestination getNavigationRailDestination(
    BuildContext context,
    NavigationBarData data,
    int updateCount,
  ) {
    Widget icon = Icon(data.icon);
    Widget selectedIcon = Icon(data.activeIcon);
    if (data.badgeType == NavBadgeType.updates && updateCount > 0) {
      icon = Badge.count(count: updateCount, child: Icon(data.icon));
      selectedIcon =
          Badge.count(count: updateCount, child: Icon(data.activeIcon));
    }
    return NavigationRailDestination(
      icon: icon,
      label: Text(data.label(context)),
      selectedIcon: selectedIcon,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updateCount = ref.watch(navUpdatesBadgeCountProvider);
    final Widget leadingIcon;
    if (context.isDesktop) {
      leadingIcon = TextButton.icon(
        onPressed: () => const AboutRoute().go(context),
        icon: ImageIcon(
          AssetImage(Assets.icons.darkIcon.path),
          size: 48,
        ),
        label: Text(context.l10n.appTitle),
        style: TextButton.styleFrom(
          foregroundColor: context.textTheme.bodyLarge?.color,
        ),
      );
    } else {
      leadingIcon = IconButton(
        onPressed: () => const AboutRoute().go(context),
        icon: ImageIcon(
          AssetImage(Assets.icons.darkIcon.path),
          size: 48,
        ),
      );
    }

    return NavigationRail(
      useIndicator: true,
      elevation: 5,
      groupAlignment: 0.0, // Center the navigation items vertically
      extended: context.isDesktop,
      labelType: context.isDesktop
          ? NavigationRailLabelType.none
          : NavigationRailLabelType.selected,
      leading: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: leadingIcon,
      ),
      destinations: NavigationBarData.getNavList(context)
          .map<NavigationRailDestination>(
              (e) => getNavigationRailDestination(context, e, updateCount))
          .toList(),
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
    );
  }
}
