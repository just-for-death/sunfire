import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/sync/sync_engine.dart';
import 'features/browse/browse_screen.dart';
import 'features/history/history_screen.dart';
import 'features/library/library_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/updates/updates_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  static final ValueNotifier<int> selectedTabNotifier = ValueNotifier<int>(0);

  static void switchToTab(int index) {
    selectedTabNotifier.value = index;
  }

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with WidgetsBindingObserver {
  int _currentIndex = 0;
  late final PageController _pageController;
  bool _isSyncing = false;

  final List<Widget> _screens = const [
    LibraryScreen(),
    UpdatesScreen(),
    HistoryScreen(),
    BrowseScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    MainShell.selectedTabNotifier.addListener(_onExternalTabChange);
    WidgetsBinding.instance.addObserver(this);
  }

  void _onExternalTabChange() {
    final target = MainShell.selectedTabNotifier.value;
    if (_currentIndex != target && mounted) {
      setState(() => _currentIndex = target);
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          target,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  @override
  void dispose() {
    MainShell.selectedTabNotifier.removeListener(_onExternalTabChange);
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      SyncEngine.instance.triggerSync();
    }
  }

  void _handleTabSelect(int index) {
    if (_currentIndex != index) {
      HapticFeedback.selectionClick();
      setState(() => _currentIndex = index);
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  Future<void> _handleQuickSync() async {
    if (_isSyncing) return;
    HapticFeedback.mediumImpact();
    setState(() => _isSyncing = true);
    try {
      await SyncEngine.instance.triggerSync();
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 720;
    final primaryColor = Theme.of(context).colorScheme.primary;

    if (isTablet) {
      return Scaffold(
        body: Row(
          children: [
            // ── IPAD / TABLET GLASSMORPHIC NAVIGATION SIDEBAR ─────────────
            ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                child: Container(
                  width: 104,
                  decoration: const BoxDecoration(
                    color: Color(0xF2121218),
                    border: Border(
                      right: BorderSide(color: Color(0x22FFFFFF), width: 0.8),
                    ),
                  ),
                  child: SafeArea(
                    right: false,
                    child: Column(
                      children: [
                        const SizedBox(height: 18),
                        // App Brand Logo
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [primaryColor, primaryColor.withValues(alpha: 0.7)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withValues(alpha: 0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 28),
                        ),
                        const SizedBox(height: 32),
                        // Navigation Items
                        Expanded(
                          child: Column(
                            children: [
                              _buildTabletNavItem(0, Icons.auto_stories_rounded, Icons.auto_stories_outlined, 'Library'),
                              const SizedBox(height: 14),
                              _buildTabletNavItem(1, Icons.notifications_rounded, Icons.notifications_outlined, 'Updates'),
                              const SizedBox(height: 14),
                              _buildTabletNavItem(2, Icons.history_rounded, Icons.history_outlined, 'History'),
                              const SizedBox(height: 14),
                              _buildTabletNavItem(3, Icons.explore_rounded, Icons.explore_outlined, 'Browse'),
                              const SizedBox(height: 14),
                              _buildTabletNavItem(4, Icons.settings_rounded, Icons.settings_outlined, 'Settings'),
                            ],
                          ),
                        ),
                        // Bottom Quick Sync & Server Indicator on iPad
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            children: [
                              IconButton(
                                icon: AnimatedRotation(
                                  turns: _isSyncing ? 1.0 : 0.0,
                                  duration: const Duration(seconds: 1),
                                  child: Icon(
                                    Icons.sync_rounded,
                                    color: _isSyncing ? primaryColor : Colors.white54,
                                    size: 22,
                                  ),
                                ),
                                tooltip: 'Sync Library & Server',
                                onPressed: _handleQuickSync,
                              ),
                              const SizedBox(height: 6),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.greenAccent,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.greenAccent.withValues(alpha: 0.6),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // ── TABLET CONTENT SCREEN (Smooth PageView) ───────────────────
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  if (_currentIndex != index) {
                    setState(() => _currentIndex = index);
                  }
                },
                children: _screens,
              ),
            ),
          ],
        ),
      );
    }

    // ── MOBILE PHONE LAYOUT WITH SMOOTH SWIPE PAGEVIEW & FLOATING BAR ─────
    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (index) {
          if (_currentIndex != index) {
            setState(() => _currentIndex = index);
          }
        },
        children: _screens,
      ),
      bottomNavigationBar: SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xE614141A),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: const Color(0x33FFFFFF), width: 0.8),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x66000000),
                          blurRadius: 24,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildNavItem(0, Icons.auto_stories_rounded, Icons.auto_stories_outlined, 'Library'),
                        _buildNavItem(1, Icons.notifications_rounded, Icons.notifications_outlined, 'Updates'),
                        _buildNavItem(2, Icons.history_rounded, Icons.history_outlined, 'History'),
                        _buildNavItem(3, Icons.explore_rounded, Icons.explore_outlined, 'Browse'),
                        _buildNavItem(4, Icons.settings_rounded, Icons.settings_outlined, 'Settings'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabletNavItem(int index, IconData selectedIcon, IconData unselectedIcon, String label) {
    final isSelected = _currentIndex == index;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _handleTabSelect(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: 80,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: isSelected
              ? BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor.withValues(alpha: 0.24), primaryColor.withValues(alpha: 0.08)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: primaryColor.withValues(alpha: 0.6), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                )
              : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? selectedIcon : unselectedIcon,
                color: isSelected ? primaryColor : Colors.white60,
                size: 26,
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white60,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  letterSpacing: isSelected ? 0.2 : 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData selectedIcon, IconData unselectedIcon, String label) {
    final isSelected = _currentIndex == index;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _handleTabSelect(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: isSelected
              ? BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withAlpha(80),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                )
              : null,
          child: Row(
            children: [
              Icon(
                isSelected ? selectedIcon : unselectedIcon,
                color: isSelected ? Colors.white : Colors.grey.shade400,
                size: 22,
              ),
              if (isSelected) ...[
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
