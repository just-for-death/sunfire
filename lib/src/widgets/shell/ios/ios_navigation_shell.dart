import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../constants/navigation_bar_data.dart';
import '../../../utils/extensions/custom_extensions.dart';
import '../nav_overflow_menu.dart';

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
    if (context.isTablet) {
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
      extendBody: true,
      body: child,
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

class _GlassTabBar extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
                  return Expanded(
                    child: Semantics(
                      button: true,
                      selected: selected,
                      label: label,
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
                                  child: Icon(
                                    selected ? item.activeIcon : item.icon,
                                    size: iconSize,
                                    color: selected
                                        ? cs.primary
                                        : (isDark
                                            ? Colors.white
                                                .withValues(alpha: 0.5)
                                            : Colors.black
                                                .withValues(alpha: 0.4)),
                                  ),
                                ),
                                SizedBox(height: textScaler.scale(3).clamp(2.0, 6.0)),
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
// iPad — sidebar + detail split
// ─────────────────────────────────────────────────────────────────────────────
class _IPadSplitShell extends StatelessWidget {
  const _IPadSplitShell({
    required this.onDestinationSelected,
    required this.child,
  });

  final void Function(int) onDestinationSelected;
  final StatefulNavigationShell child;

  @override
  Widget build(BuildContext context) {
    final navList = NavigationBarData.getNavList(context);
    final cs = context.theme.colorScheme;
    final isDark = context.isDarkMode;

    return Scaffold(
      body: Row(
        children: [
          _GlassSidebar(
            navList: navList,
            selectedIndex: child.currentIndex,
            onTap: onDestinationSelected,
            isDark: isDark,
            cs: cs,
          ),
          Container(
            width: 0.5,
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.08),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _GlassSidebar extends StatelessWidget {
  const _GlassSidebar({
    required this.navList,
    required this.selectedIndex,
    required this.onTap,
    required this.isDark,
    required this.cs,
  });

  final List<NavigationBarData> navList;
  final int selectedIndex;
  final void Function(int) onTap;
  final bool isDark;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context)
        .clamp(minScaleFactor: 0.85, maxScaleFactor: 2.0);
    final titleSize = textScaler.scale(22.0).clamp(18.0, 28.0);
    final rowLabelSize = textScaler.scale(15.0).clamp(13.0, 20.0);
    final rowIconSize = textScaler.scale(20.0).clamp(18.0, 26.0);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: textScaler.scale(220.0).clamp(200.0, 260.0),
          color: isDark
              ? Colors.black.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.7),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Text(
                    context.l10n.appTitle,
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                ...List.generate(navList.length, (i) {
                  final item = navList[i];
                  final selected = i == selectedIndex;
                  final label = item.label(context);
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    child: Semantics(
                      button: true,
                      selected: selected,
                      label: label,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () => onTap(i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOutCubic,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? cs.primary
                                      .withValues(alpha: isDark ? 0.25 : 0.12)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  selected ? item.activeIcon : item.icon,
                                  size: rowIconSize,
                                  color: selected
                                      ? cs.primary
                                      : (isDark
                                          ? Colors.white
                                              .withValues(alpha: 0.6)
                                          : Colors.black
                                              .withValues(alpha: 0.5)),
                                ),
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
                                                  .withValues(alpha: 0.8)
                                              : Colors.black
                                                  .withValues(alpha: 0.7)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
