import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../constants/navigation_bar_data.dart';
import '../../../utils/extensions/custom_extensions.dart';

/// iOS/iPad navigation shell — glass tab bar on iPhone,
/// sidebar + detail split on iPad.
class IOSNavigationShell extends StatelessWidget {
  const IOSNavigationShell({
    super.key,
    required this.child,
    required this.onDestinationSelected,
  });

  final StatefulNavigationShell child;
  final void Function(int) onDestinationSelected;

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
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// iPhone — glass frosted tab bar
// ─────────────────────────────────────────────────────────────────────────────
class _IPhoneGlassShell extends StatelessWidget {
  const _IPhoneGlassShell({
    required this.child,
    required this.onDestinationSelected,
  });

  final StatefulNavigationShell child;
  final void Function(int) onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final navList = NavigationBarData.getNavList(context);
    final cs = context.theme.colorScheme;
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true, // content flows under the tab bar
      body: child,
      bottomNavigationBar: _GlassTabBar(
        selectedIndex: child.currentIndex,
        navList: navList,
        onTap: onDestinationSelected,
        isDark: isDark,
        cs: cs,
      ),
    );
  }
}

class _GlassTabBar extends StatelessWidget {
  const _GlassTabBar({
    required this.selectedIndex,
    required this.navList,
    required this.onTap,
    required this.isDark,
    required this.cs,
  });

  final int selectedIndex;
  final List<NavigationBarData> navList;
  final void Function(int) onTap;
  final bool isDark;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.black.withOpacity(0.55)
                : Colors.white.withOpacity(0.72),
            border: Border(
              top: BorderSide(
                color: isDark
                    ? Colors.white.withOpacity(0.12)
                    : Colors.black.withOpacity(0.08),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 54,
              child: Row(
                children: List.generate(navList.length, (i) {
                  final item = navList[i];
                  final selected = i == selectedIndex;
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onTap(i),
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
                                size: 22,
                                color: selected
                                    ? cs.primary
                                    : (isDark
                                        ? Colors.white.withOpacity(0.5)
                                        : Colors.black.withOpacity(0.4)),
                              ),
                            ),
                            const SizedBox(height: 3),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: selected
                                    ? cs.primary
                                    : (isDark
                                        ? Colors.white.withOpacity(0.5)
                                        : Colors.black.withOpacity(0.4)),
                              ),
                              child: Text(item.label(context)),
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

// ─────────────────────────────────────────────────────────────────────────────
// iPad — sidebar + detail split
// ─────────────────────────────────────────────────────────────────────────────
class _IPadSplitShell extends StatelessWidget {
  const _IPadSplitShell({
    required this.child,
    required this.onDestinationSelected,
  });

  final StatefulNavigationShell child;
  final void Function(int) onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final navList = NavigationBarData.getNavList(context);
    final cs = context.theme.colorScheme;
    final isDark = context.isDarkMode;

    return Scaffold(
      body: Row(
        children: [
          // Glass sidebar
          _GlassSidebar(
            navList: navList,
            selectedIndex: child.currentIndex,
            onTap: onDestinationSelected,
            isDark: isDark,
            cs: cs,
          ),
          // Thin divider
          Container(
            width: 0.5,
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.08),
          ),
          // Main content
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
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: 220,
          color: isDark
              ? Colors.black.withOpacity(0.5)
              : Colors.white.withOpacity(0.7),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App name header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Text(
                    'Catalyst',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Nav items
                ...List.generate(navList.length, (i) {
                  final item = navList[i];
                  final selected = i == selectedIndex;
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    child: GestureDetector(
                      onTap: () => onTap(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: selected
                              ? cs.primary.withOpacity(isDark ? 0.25 : 0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              selected ? item.activeIcon : item.icon,
                              size: 20,
                              color: selected
                                  ? cs.primary
                                  : (isDark
                                      ? Colors.white.withOpacity(0.6)
                                      : Colors.black.withOpacity(0.5)),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              item.label(context),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: selected
                                    ? cs.primary
                                    : (isDark
                                        ? Colors.white.withOpacity(0.8)
                                        : Colors.black.withOpacity(0.7)),
                              ),
                            ),
                          ],
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
