import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'core/services/download_manager_service.dart';
import 'core/services/settings_service.dart';
import 'core/sync/graphql_client_service.dart';
import 'core/sync/sync_engine.dart';
import 'features/browse/browse_screen.dart';
import 'features/history/history_screen.dart';
import 'features/library/library_screen.dart';
import 'features/settings/server_settings_screen.dart';
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
  late bool _isSidebarExpanded;

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
    _isSidebarExpanded = SettingsService.instance.tabletSidebarExpanded;
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
      if (GraphQLClientService.instance.isConfigured) {
        SyncEngine.instance.triggerSync();
      }
    }
  }

  void _handleTabSelect(int index) {
    if (_currentIndex != index) {
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        HapticFeedback.lightImpact();
      } else {
        HapticFeedback.selectionClick();
      }
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

  void _toggleSidebar() {
    HapticFeedback.selectionClick();
    setState(() {
      _isSidebarExpanded = !_isSidebarExpanded;
      SettingsService.instance.tabletSidebarExpanded = _isSidebarExpanded;
    });
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

    final scaffold = isTablet
        ? Scaffold(
            body: Row(
              children: [
                // ── IPADOS HYBRID EXPANDABLE GLASSMORPHIC SIDEBAR ────────────
                _buildTabletSidebar(context, primaryColor),

                // ── TABLET CONTENT CANVAS (Smooth PageView) ──────────────────
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
          )
        // ── MOBILE PHONE LAYOUT WITH FLOATING GLASS CAPSULE ──────────────────
        : Scaffold(
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
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.55),
                          blurRadius: 28,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xCC181820),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(color: const Color(0x22FFFFFF), width: 0.8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildMobileNavItem(0, Icons.auto_stories_rounded, Icons.auto_stories_outlined, 'Library'),
                              _buildMobileNavItem(1, Icons.notifications_rounded, Icons.notifications_outlined, 'Updates'),
                              _buildMobileNavItem(2, Icons.history_rounded, Icons.history_outlined, 'History'),
                              _buildMobileNavItem(3, Icons.explore_rounded, Icons.explore_outlined, 'Browse'),
                              _buildMobileNavItem(4, Icons.settings_rounded, Icons.settings_outlined, 'Settings'),
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

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleTabSelect(0);
      },
      child: scaffold,
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // ── IPADOS EXPANDABLE / COLLAPSIBLE SIDEBAR ─────────────────────────────────
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildTabletSidebar(BuildContext context, Color primaryColor) {
    final isExpanded = _isSidebarExpanded;
    final sidebarWidth = isExpanded ? 250.0 : 76.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOutCubic,
      width: sidebarWidth,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xF213131A),
              border: Border(
                right: BorderSide(color: Color(0x1EFFFFFF), width: 0.8),
              ),
            ),
            child: SafeArea(
              right: false,
              child: Column(
                crossAxisAlignment: isExpanded ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 14),

                  // ── 1. SIDEBAR HEADER ──────────────────────────────────────
                  _buildSidebarHeader(primaryColor, isExpanded),
                  const SizedBox(height: 18),

                  // ── 2. NAVIGATION ITEMS ────────────────────────────────────
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: isExpanded ? 12.0 : 8.0),
                      children: [
                        if (isExpanded) ...[
                          Padding(
                            padding: const EdgeInsets.only(left: 12.0, bottom: 8.0, top: 4.0),
                            child: Text(
                              'MENU',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white.withValues(alpha: 0.35),
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ],
                        _buildSidebarItem(0, Icons.auto_stories_rounded, Icons.auto_stories_outlined, 'Library', isExpanded, primaryColor),
                        const SizedBox(height: 4),
                        _buildSidebarItem(1, Icons.notifications_rounded, Icons.notifications_outlined, 'Updates', isExpanded, primaryColor),
                        const SizedBox(height: 4),
                        _buildSidebarItem(2, Icons.history_rounded, Icons.history_outlined, 'History', isExpanded, primaryColor),
                        const SizedBox(height: 4),
                        _buildSidebarItem(3, Icons.explore_rounded, Icons.explore_outlined, 'Browse', isExpanded, primaryColor),
                        const SizedBox(height: 4),
                        _buildSidebarItem(4, Icons.settings_rounded, Icons.settings_outlined, 'Settings', isExpanded, primaryColor),

                        if (isExpanded) ...[
                          const SizedBox(height: 22),
                          Padding(
                            padding: const EdgeInsets.only(left: 12.0, bottom: 8.0),
                            child: Text(
                              'ACTIVITY',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white.withValues(alpha: 0.35),
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          ListenableBuilder(
                            listenable: DownloadManagerService.instance,
                            builder: (context, _) {
                              final activeCount = DownloadManagerService.instance.localTasks
                                  .where((t) => t.status == LocalDownloadStatus.downloading || t.status == LocalDownloadStatus.queued)
                                  .length;
                              return _buildQuickActionRow(
                                icon: Icons.download_rounded,
                                label: 'Downloads Queue',
                                badgeCount: activeCount > 0 ? activeCount : null,
                                onTap: () => context.push('/downloads'),
                              );
                            },
                          ),
                          _buildQuickActionRow(
                            icon: Icons.insights_rounded,
                            label: 'Reading Stats',
                            onTap: () => context.push('/stats'),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // ── 3. BOTTOM LIQUID GLASS SERVER STATUS CARD ──────────────
                  _buildBottomServerCard(primaryColor, isExpanded),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarHeader(Color primaryColor, bool isExpanded) {
    if (isExpanded) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0),
        child: Row(
          children: [
            // App Flame Emblem
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, primaryColor.withValues(alpha: 0.75)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(11),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.32),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 10),
            // Title & Version Badge
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Sunfire',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.4,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: primaryColor.withValues(alpha: 0.4), width: 0.6),
                        ),
                        child: Text(
                          'v3.0 BETA',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Collapse Button
            IconButton(
              icon: const Icon(Icons.view_sidebar_rounded, color: Colors.white60, size: 20),
              tooltip: 'Collapse sidebar',
              visualDensity: VisualDensity.compact,
              onPressed: _toggleSidebar,
            ),
          ],
        ),
      );
    } else {
      // Collapsed Rail Header (Tap to expand)
      return Column(
        children: [
          IconButton(
            icon: const Icon(Icons.view_sidebar_outlined, color: Colors.white70, size: 22),
            tooltip: 'Expand sidebar',
            onPressed: _toggleSidebar,
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _toggleSidebar,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, primaryColor.withValues(alpha: 0.75)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(11),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 22),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildSidebarItem(
    int index,
    IconData selectedIcon,
    IconData unselectedIcon,
    String label,
    bool isExpanded,
    Color primaryColor,
  ) {
    final isSelected = _currentIndex == index;

    if (isExpanded) {
      // Horizontal Apple-style row
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _handleTabSelect(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: isSelected
                ? BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: primaryColor.withValues(alpha: 0.45), width: 1.0),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  )
                : BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
            child: Row(
              children: [
                Icon(
                  isSelected ? selectedIcon : unselectedIcon,
                  color: isSelected ? primaryColor : Colors.white60,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 13.5,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.8),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    } else {
      // Compact Rail Squircle (46x46)
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Tooltip(
            message: label,
            preferBelow: false,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => _handleTabSelect(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  width: 46,
                  height: 46,
                  decoration: isSelected
                      ? BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: primaryColor.withValues(alpha: 0.55), width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        )
                      : null,
                  child: Center(
                    child: Icon(
                      isSelected ? selectedIcon : unselectedIcon,
                      color: isSelected ? primaryColor : Colors.white60,
                      size: 21,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildQuickActionRow({
    required IconData icon,
    required String label,
    int? badgeCount,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            children: [
              Icon(icon, color: Colors.white54, size: 19),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (badgeCount != null && badgeCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                )
              else
                const Icon(Icons.chevron_right_rounded, color: Colors.white30, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomServerCard(Color primaryColor, bool isExpanded) {
    final isConfigured = GraphQLClientService.instance.isConfigured;
    final serverUrl = SettingsService.instance.serverUrl;

    if (isExpanded) {
      return Padding(
        padding: const EdgeInsets.all(12.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: const Color(0x14FFFFFF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0x1AFFFFFF), width: 0.8),
          ),
          child: Row(
            children: [
              // Connection Indicator Dot
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isConfigured ? Colors.greenAccent : Colors.tealAccent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isConfigured ? Colors.greenAccent : Colors.tealAccent).withValues(alpha: 0.6),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Server Details
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ServerSettingsScreen()),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isConfigured ? 'Suwayomi Server' : 'Standalone Mode',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        isConfigured
                            ? (Uri.tryParse(serverUrl)?.host ?? 'Connected')
                            : 'On-Device QuickJS',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Quick Sync Button
              IconButton(
                icon: AnimatedRotation(
                  turns: _isSyncing ? 1.0 : 0.0,
                  duration: const Duration(seconds: 1),
                  child: Icon(
                    Icons.sync_rounded,
                    color: _isSyncing ? primaryColor : Colors.white70,
                    size: 20,
                  ),
                ),
                tooltip: 'Sync library',
                visualDensity: VisualDensity.compact,
                onPressed: _handleQuickSync,
              ),
            ],
          ),
        ),
      );
    } else {
      // Collapsed Rail Bottom Indicator
      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Column(
          children: [
            IconButton(
              icon: AnimatedRotation(
                turns: _isSyncing ? 1.0 : 0.0,
                duration: const Duration(seconds: 1),
                child: Icon(
                  Icons.sync_rounded,
                  color: _isSyncing ? primaryColor : Colors.white60,
                  size: 21,
                ),
              ),
              tooltip: 'Sync library',
              onPressed: _handleQuickSync,
            ),
            const SizedBox(height: 4),
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: isConfigured ? Colors.greenAccent : Colors.tealAccent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (isConfigured ? Colors.greenAccent : Colors.tealAccent).withValues(alpha: 0.6),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // ── MOBILE PHONE NAV ITEM ───────────────────────────────────────────────────
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildMobileNavItem(int index, IconData selectedIcon, IconData unselectedIcon, String label) {
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
