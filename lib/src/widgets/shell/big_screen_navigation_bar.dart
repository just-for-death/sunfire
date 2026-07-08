// Copyright (c) 2022 Contributors to the Catalyst project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../constants/gen/assets.gen.dart';
import '../../constants/navigation_bar_data.dart';
import '../../global_providers/global_providers.dart';
import '../../routes/router_config.dart';
import '../../utils/extensions/custom_extensions.dart';
import 'nav_badge_providers.dart';

class BigScreenNavigationBar extends ConsumerStatefulWidget {
  const BigScreenNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  ConsumerState<BigScreenNavigationBar> createState() =>
      _BigScreenNavigationBarState();
}

class _BigScreenNavigationBarState extends ConsumerState<BigScreenNavigationBar> {
  static const _railPrefKey = 'android_rail_expanded';
  bool _railExpanded = true;

  @override
  void initState() {
    super.initState();
    _railExpanded =
        ref.read(sharedPreferencesProvider).getBool(_railPrefKey) ?? true;
  }

  void _toggleRail() {
    setState(() => _railExpanded = !_railExpanded);
    ref.read(sharedPreferencesProvider).setBool(_railPrefKey, _railExpanded);
  }

  NavigationRailDestination getNavigationRailDestination(
    BuildContext context,
    NavigationBarData data,
    int updateCount,
  ) {
    Widget icon = Icon(data.navIcon(context));
    Widget selectedIcon = Icon(data.navActiveIcon(context));
    if (data.badgeType == NavBadgeType.updates && updateCount > 0) {
      icon = Badge.count(count: updateCount, child: Icon(data.navIcon(context)));
      selectedIcon =
          Badge.count(count: updateCount, child: Icon(data.navActiveIcon(context)));
    }
    return NavigationRailDestination(
      icon: icon,
      label: Text(data.label(context)),
      selectedIcon: selectedIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final updateCount = ref.watch(navUpdatesBadgeCountProvider);
    final showExtended = context.isDesktop || _railExpanded;

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
      leadingIcon = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () => const AboutRoute().go(context),
            icon: ImageIcon(
              AssetImage(Assets.icons.darkIcon.path),
              size: 48,
            ),
          ),
          IconButton(
            onPressed: _toggleRail,
            tooltip: _railExpanded
                ? context.l10n.collapseSidebar
                : context.l10n.expandSidebar,
            icon: Icon(
              _railExpanded
                  ? Icons.chevron_left_rounded
                  : Icons.chevron_right_rounded,
            ),
          ),
        ],
      );
    }

    return NavigationRail(
      useIndicator: true,
      elevation: 5,
      groupAlignment: 0.0,
      extended: showExtended,
      labelType: showExtended
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
      selectedIndex: widget.selectedIndex,
      onDestinationSelected: widget.onDestinationSelected,
    );
  }
}
