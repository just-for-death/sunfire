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

class _BigScreenNavigationBarState
    extends ConsumerState<BigScreenNavigationBar> {
  static const _railPrefKey = 'android_rail_expanded';
  bool _railExpanded = false;

  @override
  void initState() {
    super.initState();
    _railExpanded =
        ref.read(sharedPreferencesProvider).getBool(_railPrefKey) ?? false;
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
    final label = data.label(context);
    Widget icon = Icon(data.navIcon(context));
    Widget selectedIcon = Icon(data.navActiveIcon(context));
    if (data.badgeType == NavBadgeType.updates && updateCount > 0) {
      icon = Badge.count(count: updateCount, child: icon);
      selectedIcon = Badge.count(count: updateCount, child: selectedIcon);
    }
    if (!_railExpanded) {
      // Labels are hidden when collapsed, so surface them on hover/long-press.
      icon = Tooltip(message: label, child: icon);
      selectedIcon = Tooltip(message: label, child: selectedIcon);
    }
    return NavigationRailDestination(
      icon: icon,
      label: Text(label),
      selectedIcon: selectedIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final updateCount = ref.watch(navUpdatesBadgeCountProvider);

    final appButton = IconButton(
      onPressed: () => const AboutRoute().go(context),
      tooltip: context.l10n.appTitle,
      icon: ImageIcon(AssetImage(Assets.icons.darkIcon.path), size: 32),
    );
    final toggleButton = IconButton(
      onPressed: _toggleRail,
      tooltip: _railExpanded
          ? context.l10n.collapseSidebar
          : context.l10n.expandSidebar,
      icon: Icon(
        _railExpanded
            ? Icons.chevron_left_rounded
            : Icons.chevron_right_rounded,
      ),
    );

    return NavigationRail(
      useIndicator: true,
      groupAlignment: 0.0,
      extended: _railExpanded,
      labelType: NavigationRailLabelType.none,
      leading: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: _railExpanded
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  appButton,
                  Flexible(
                    child: Text(
                      context.l10n.appTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleMedium,
                    ),
                  ),
                  toggleButton,
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [appButton, toggleButton],
              ),
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
