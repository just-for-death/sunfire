import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../constants/app_breakpoints.dart';
import '../../../constants/navigation_bar_data.dart';
import '../../../utils/extensions/custom_extensions.dart';
import '../../../utils/platform/platform_ui.dart';
import '../big_screen_navigation_bar.dart';
import '../nav_badge_providers.dart';
import '../nav_overflow_menu.dart';
import '../shell_banner_stack.dart';

/// Android navigation shell — Material 3 bottom nav on phone,
/// navigation rail + detail on tablet.
class AndroidNavigationShell extends StatelessWidget {
  const AndroidNavigationShell({
    super.key,
    required this.onDestinationSelected,
    required this.compactBottomNav,
    required this.child,
  });

  final void Function(int) onDestinationSelected;
  final bool compactBottomNav;
  final StatefulNavigationShell child;

  @override
  Widget build(BuildContext context) {
    if (AppBreakpoints.isTabletLayout(context) &&
        !AppBreakpoints.useCompactShellOnNarrowTablet(context)) {
      return _AndroidTabletGlassShell(
        onDestinationSelected: onDestinationSelected,
        child: child,
      );
    }
    return _AndroidPhoneGlassShell(
      onDestinationSelected: onDestinationSelected,
      compact: compactBottomNav,
      child: child,
    );
  }
}

class _AndroidPhoneGlassShell extends StatelessWidget {
  const _AndroidPhoneGlassShell({
    required this.onDestinationSelected,
    required this.compact,
    required this.child,
  });

  final void Function(int) onDestinationSelected;
  final bool compact;
  final StatefulNavigationShell child;

  @override
  Widget build(BuildContext context) {
    final navList = compact
        ? NavigationBarData.getCompactPhoneNavList(context)
        : NavigationBarData.getNavList(context);

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      extendBody: true,
      body: Column(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) => SizeTransition(
              sizeFactor: animation,
              alignment: Alignment.topCenter,
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: const ShellBannerStack(),
          ),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: _AndroidBottomNavBar(
        selectedBranchIndex: child.currentIndex,
        navList: navList,
        shell: child,
        compact: compact,
        onBranchSelected: onDestinationSelected,
      ),
    );
  }
}

class _AndroidBottomNavBar extends ConsumerWidget {
  const _AndroidBottomNavBar({
    required this.selectedBranchIndex,
    required this.navList,
    required this.shell,
    required this.compact,
    required this.onBranchSelected,
  });

  final int selectedBranchIndex;
  final List<NavigationBarData> navList;
  final StatefulNavigationShell shell;
  final bool compact;
  final void Function(int branchIndex) onBranchSelected;

  int get _displaySelectedIndex {
    if (!compact) return selectedBranchIndex;
    if (selectedBranchIndex <= 3) return selectedBranchIndex;
    return 4;
  }

  void _onTap(BuildContext context, int displayIndex) {
    adaptiveSelectionHaptic();
    if (compact && displayIndex == 4) {
      showCompactNavOverflowMenu(context, shell);
      return;
    }
    onBranchSelected(displayIndex);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updateCount = ref.watch(navUpdatesBadgeCountProvider);

    return NavigationBar(
      selectedIndex: _displaySelectedIndex,
      onDestinationSelected: (index) => _onTap(context, index),
      destinations: [
        for (final item in navList)
          NavigationDestination(
            icon: _withBadge(item, updateCount, item.navIcon(context)),
            selectedIcon:
                _withBadge(item, updateCount, item.navActiveIcon(context)),
            label: item.label(context),
            tooltip: item.label(context),
          ),
      ],
    );
  }

  Widget _withBadge(NavigationBarData item, int updateCount, IconData icon) {
    final child = Icon(icon);
    if (item.badgeType != NavBadgeType.updates || updateCount <= 0) {
      return child;
    }
    return Badge.count(count: updateCount, child: child);
  }
}

class _AndroidTabletGlassShell extends StatelessWidget {
  const _AndroidTabletGlassShell({
    required this.onDestinationSelected,
    required this.child,
  });

  final void Function(int) onDestinationSelected;
  final StatefulNavigationShell child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          ColoredBox(
            color: context.theme.colorScheme.surfaceContainerLow,
            child: BigScreenNavigationBar(
              selectedIndex: child.currentIndex,
              onDestinationSelected: onDestinationSelected,
            ),
          ),
          Expanded(
            child: Column(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) => SizeTransition(
                    sizeFactor: animation,
                    alignment: Alignment.topCenter,
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                  child: const ShellBannerStack(),
                ),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
