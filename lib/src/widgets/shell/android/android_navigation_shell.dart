import 'dart:ui';

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

/// Android navigation shell — frosted glass bottom nav on phone,
/// glass rail + detail on tablet.
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
    if (AppBreakpoints.isTabletLayout(context)) {
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
      bottomNavigationBar: _AndroidGlassBottomBar(
        selectedBranchIndex: child.currentIndex,
        navList: navList,
        shell: child,
        compact: compact,
        onBranchSelected: onDestinationSelected,
      ),
    );
  }
}

class _AndroidGlassBottomBar extends ConsumerWidget {
  const _AndroidGlassBottomBar({
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
    final cs = context.theme.colorScheme;
    final isDark = context.isDarkMode;
    final textScaler = MediaQuery.textScalerOf(context)
        .clamp(minScaleFactor: 0.85, maxScaleFactor: 2.0);
    final barHeight = textScaler.scale(64.0).clamp(60.0, 80.0);
    final iconSize = textScaler.scale(24.0).clamp(22.0, 30.0);
    final labelFontSize = textScaler.scale(12.0).clamp(10.0, 14.0);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: cs.surface.withValues(alpha: isDark ? 0.82 : 0.88),
            border: Border(
              top: BorderSide(
                color: cs.outlineVariant.withValues(alpha: 0.4),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: barHeight,
              child: Row(
                children: List.generate(navList.length, (i) {
                  final item = navList[i];
                  final selected = i == _displaySelectedIndex;
                  final label = item.label(context);
                  Widget icon = Icon(
                    selected ? item.navActiveIcon(context) : item.navIcon(context),
                    size: iconSize,
                    color: selected
                        ? cs.primary
                        : cs.onSurfaceVariant,
                  );
                  if (item.badgeType == NavBadgeType.updates &&
                      updateCount > 0) {
                    icon = Badge.count(count: updateCount, child: icon);
                  }
                  return Expanded(
                    child: Semantics(
                      button: true,
                      selected: selected,
                      label: label,
                      child: InkWell(
                        onTap: () => _onTap(context, i),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            icon,
                            const SizedBox(height: 2),
                            Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: labelFontSize,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: selected
                                    ? cs.primary
                                    : cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
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
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: ColoredBox(
                color: context.theme.colorScheme.surfaceContainerLow
                    .withValues(alpha: 0.92),
                child: BigScreenNavigationBar(
                  selectedIndex: child.currentIndex,
                  onDestinationSelected: onDestinationSelected,
                ),
              ),
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
