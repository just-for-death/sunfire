import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../constants/app_breakpoints.dart';
import '../../../constants/gen/assets.gen.dart';
import '../../../constants/navigation_bar_data.dart';
import '../../../global_providers/global_providers.dart';
import '../../../routes/router_config.dart';
import '../../../utils/extensions/custom_extensions.dart';
import '../nav_badge_providers.dart';
import '../nav_overflow_menu.dart';
import '../shell_banner_stack.dart';

/// iOS/iPad navigation shell — glass tab bar on iPhone,
/// sidebar + detail split on iPad.
class IOSNavigationShell extends StatelessWidget {
  const IOSNavigationShell({
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
    if (context.isTablet && !AppBreakpoints.useCompactShellOnIPad(context)) {
      return _IPadSplitShell(
        onDestinationSelected: onDestinationSelected,
        child: child,
      );
    }
    return _IPhoneGlassShell(
      onDestinationSelected: onDestinationSelected,
      compact: compactBottomNav,
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// iPhone — glass frosted tab bar
// ─────────────────────────────────────────────────────────────────────────────
class _IPhoneGlassShell extends StatelessWidget {
  const _IPhoneGlassShell({
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
    final cs = context.theme.colorScheme;
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: Colors.transparent,
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
      bottomNavigationBar: _GlassTabBar(
        selectedBranchIndex: child.currentIndex,
        navList: navList,
        shell: child,
        compact: compact,
        onBranchSelected: onDestinationSelected,
        isDark: isDark,
        cs: cs,
      ),
    );
  }
}

class _GlassTabBar extends ConsumerWidget {
  const _GlassTabBar({
    required this.selectedBranchIndex,
    required this.navList,
    required this.shell,
    required this.compact,
    required this.onBranchSelected,
    required this.isDark,
    required this.cs,
  });

  final int selectedBranchIndex;
  final List<NavigationBarData> navList;
  final StatefulNavigationShell shell;
  final bool compact;
  final void Function(int branchIndex) onBranchSelected;
  final bool isDark;
  final ColorScheme cs;

  int get _displaySelectedIndex {
    if (!compact) return selectedBranchIndex;
    if (selectedBranchIndex <= 3) return selectedBranchIndex;
    return 4;
  }

  void _onTap(BuildContext context, int displayIndex) {
    if (compact && displayIndex == 4) {
      showCompactNavOverflowMenu(context, shell);
      return;
    }
    if (compact) {
      onBranchSelected(displayIndex);
      return;
    }
    onBranchSelected(displayIndex);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updateCount = ref.watch(navUpdatesBadgeCountProvider);
    final textScaler =
        MediaQuery.textScalerOf(context).clamp(minScaleFactor: 0.85, maxScaleFactor: 2.0);
    final baseIcon = 22.0;
    final baseLabel = 10.0;
    final barHeight = textScaler.scale(54.0).clamp(52.0, 76.0);
    final iconSize = textScaler.scale(baseIcon).clamp(20.0, 30.0);
    final labelFontSize = textScaler.scale(baseLabel).clamp(9.0, 14.0);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.black.withValues(alpha: 0.55)
                : Colors.white.withValues(alpha: 0.72),
            border: Border(
              top: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.08),
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
                    selected ? item.activeIcon : item.icon,
                    size: iconSize,
                    color: selected
                        ? cs.primary
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.5)
                            : Colors.black.withValues(alpha: 0.4)),
                  );
                  if (item.badgeType == NavBadgeType.updates && updateCount > 0) {
                    icon = Badge.count(count: updateCount, child: icon);
                  }
                  return Expanded(
                    child: Semantics(
                      button: true,
                      selected: selected,
                      label: label,
                      child: Tooltip(
                        message: label,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _onTap(context, i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOutCubic,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AnimatedScale(
                                    scale: selected ? 1.12 : 1.0,
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeOutCubic,
                                    child: icon,
                                  ),
                                  SizedBox(
                                    height: textScaler.scale(3).clamp(2.0, 6.0),
                                  ),
                                  AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 200),
                                  style: TextStyle(
                                    fontSize: labelFontSize,
                                    fontWeight: selected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: selected
                                        ? cs.primary
                                        : (isDark
                                            ? Colors.white
                                                .withValues(alpha: 0.5)
                                            : Colors.black
                                                .withValues(alpha: 0.4)),
                                  ),
                                  child: Text(
                                    label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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

// ─────────────────────────────────────────────────────────────────────────────
// iPad — sidebar + detail split (collapsible sidebar)
// ─────────────────────────────────────────────────────────────────────────────
class _IPadSplitShell extends ConsumerStatefulWidget {
  const _IPadSplitShell({
    required this.onDestinationSelected,
    required this.child,
  });

  final void Function(int) onDestinationSelected;
  final StatefulNavigationShell child;

  @override
  ConsumerState<_IPadSplitShell> createState() => _IPadSplitShellState();
}

class _IPadSplitShellState extends ConsumerState<_IPadSplitShell> {
  static const _sidebarPrefKey = 'ipad_sidebar_expanded';
  bool _sidebarExpanded = true;

  @override
  void initState() {
    super.initState();
    _sidebarExpanded =
        ref.read(sharedPreferencesProvider).getBool(_sidebarPrefKey) ?? true;
  }

  void _toggleSidebar() {
    setState(() => _sidebarExpanded = !_sidebarExpanded);
    ref.read(sharedPreferencesProvider).setBool(_sidebarPrefKey, _sidebarExpanded);
  }

  @override
  Widget build(BuildContext context) {
    final navList = NavigationBarData.getNavList(context);
    final cs = context.theme.colorScheme;
    final isDark = context.isDarkMode;
    final textScaler = MediaQuery.textScalerOf(context)
        .clamp(minScaleFactor: 0.85, maxScaleFactor: 2.0);
    final expandedWidth = textScaler.scale(220.0).clamp(200.0, 260.0);
    const collapsedWidth = 72.0;

    return Scaffold(
      body: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            width: _sidebarExpanded ? expandedWidth : collapsedWidth,
            child: _GlassSidebar(
              navList: navList,
              selectedIndex: widget.child.currentIndex,
              onTap: widget.onDestinationSelected,
              isDark: isDark,
              cs: cs,
              expanded: _sidebarExpanded,
              onToggle: _toggleSidebar,
            ),
          ),
          Container(
            width: 0.5,
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.08),
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
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassSidebar extends ConsumerWidget {
  const _GlassSidebar({
    required this.navList,
    required this.selectedIndex,
    required this.onTap,
    required this.isDark,
    required this.cs,
    required this.expanded,
    required this.onToggle,
  });

  final List<NavigationBarData> navList;
  final int selectedIndex;
  final void Function(int) onTap;
  final bool isDark;
  final ColorScheme cs;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updateCount = ref.watch(navUpdatesBadgeCountProvider);
    final textScaler = MediaQuery.textScalerOf(context)
        .clamp(minScaleFactor: 0.85, maxScaleFactor: 2.0);
    final titleSize = textScaler.scale(22.0).clamp(18.0, 28.0);
    final rowLabelSize = textScaler.scale(15.0).clamp(13.0, 20.0);
    final rowIconSize = textScaler.scale(20.0).clamp(18.0, 26.0);

    Widget navIcon(NavigationBarData item, bool selected) {
      Widget icon = Icon(
        selected ? item.activeIcon : item.icon,
        size: rowIconSize,
        color: selected
            ? cs.primary
            : (isDark
                ? Colors.white.withValues(alpha: 0.6)
                : Colors.black.withValues(alpha: 0.5)),
      );
      if (item.badgeType == NavBadgeType.updates && updateCount > 0) {
        icon = Badge.count(count: updateCount, child: icon);
      }
      return icon;
    }

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          color: isDark
              ? Colors.black.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.7),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    expanded ? 12 : 8,
                    12,
                    expanded ? 8 : 8,
                    8,
                  ),
                  child: Row(
                    children: [
                      if (expanded)
                        Expanded(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () => const AboutRoute().go(context),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Row(
                                  children: [
                                    ImageIcon(
                                      AssetImage(Assets.icons.darkIcon.path),
                                      size: titleSize,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        context.l10n.appTitle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: titleSize,
                                          fontWeight: FontWeight.w700,
                                          color:
                                              isDark ? Colors.white : Colors.black,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        Tooltip(
                          message: context.l10n.about,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () => const AboutRoute().go(context),
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: ImageIcon(
                                  AssetImage(Assets.icons.darkIcon.path),
                                  size: rowIconSize + 4,
                                ),
                              ),
                            ),
                          ),
                        ),
                      IconButton(
                        onPressed: onToggle,
                        tooltip: expanded
                            ? context.l10n.collapseSidebar
                            : context.l10n.expandSidebar,
                        icon: Icon(
                          expanded
                              ? Icons.chevron_left_rounded
                              : Icons.chevron_right_rounded,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.7)
                              : Colors.black.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: List.generate(navList.length, (i) {
                      final item = navList[i];
                      final selected = i == selectedIndex;
                      final label = item.label(context);
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: expanded ? 10 : 8,
                          vertical: 2,
                        ),
                        child: Semantics(
                          button: true,
                          selected: selected,
                          label: label,
                          child: Tooltip(
                            message: expanded ? '' : label,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () => onTap(i),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  curve: Curves.easeOutCubic,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: expanded ? 12 : 0,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? cs.primary.withValues(
                                            alpha: isDark ? 0.25 : 0.12,
                                          )
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: expanded
                                      ? Row(
                                          children: [
                                            navIcon(item, selected),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                label,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: rowLabelSize,
                                                  fontWeight: selected
                                                      ? FontWeight.w600
                                                      : FontWeight.w400,
                                                  color: selected
                                                      ? cs.primary
                                                      : (isDark
                                                          ? Colors.white
                                                              .withValues(
                                                            alpha: 0.8,
                                                          )
                                                          : Colors.black
                                                              .withValues(
                                                            alpha: 0.7,
                                                          )),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Center(
                                          child: navIcon(item, selected),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
