// Copyright (c) 2022 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../constants/navigation_bar_data.dart';
import 'nav_overflow_menu.dart';

class SmallScreenNavigationBar extends StatelessWidget {
  const SmallScreenNavigationBar({
    super.key,
    required this.selectedBranchIndex,
    required this.onBranchSelected,
    required this.compact,
    this.shell,
  });

  /// Stateful shell branch index (0–5).
  final int selectedBranchIndex;

  final void Function(int branchIndex) onBranchSelected;

  /// When true, shows five tabs; tab four opens [showCompactNavOverflowMenu].
  final bool compact;

  /// Required when [compact] is true.
  final StatefulNavigationShell? shell;

  NavigationDestination _destination(
    BuildContext context,
    NavigationBarData data,
  ) {
    return NavigationDestination(
      icon: Icon(data.icon),
      label: data.label(context),
      selectedIcon: Icon(data.activeIcon),
      tooltip: data.label(context),
    );
  }

  int get _displaySelectedIndex {
    if (!compact) return selectedBranchIndex;
    if (selectedBranchIndex <= 3) return selectedBranchIndex;
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    final navList = compact
        ? NavigationBarData.getCompactPhoneNavList(context)
        : NavigationBarData.getNavList(context);

    return NavigationBarTheme(
      data: NavigationBarThemeData(
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(overflow: TextOverflow.ellipsis),
        ),
      ),
      child: NavigationBar(
        selectedIndex: _displaySelectedIndex,
        onDestinationSelected: (displayIndex) {
          if (compact) {
            if (displayIndex == 4) {
              if (shell != null) {
                showCompactNavOverflowMenu(context, shell!);
              }
              return;
            }
            onBranchSelected(displayIndex);
            return;
          }
          onBranchSelected(displayIndex);
        },
        destinations: navList
            .map((e) => _destination(context, e))
            .toList(),
      ),
    );
  }
}
