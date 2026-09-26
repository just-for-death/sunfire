import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'core/services/batch_mode_service.dart';
import 'core/services/download_manager_service.dart';
import 'core/services/library_update_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/settings_service.dart';
import 'core/sync/graphql_client_service.dart';
import 'core/sync/sync_engine.dart';
import 'core/sync/websocket_service.dart';

/// Phone vs iPad/iPad-mini split. Widths at or above this use the sidebar rail.
const double sunfireTabletMinWidth = 720.0;

/// Manga detail two-pane (cover + chapter list). Wider than the shell rail breakpoint.
const double sunfireDetailTwoPaneMinWidth = 840.0;

/// Inner sidebar width at which labels/header Row are shown. Below this, compact
/// icons are used so expand/collapse animation cannot overflow (~36px Row).
const double sunfireSidebarExpandedLayoutMinWidth = 180.0;

bool usesTabletShell(double width) => width >= sunfireTabletMinWidth;

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  static final ValueNotifier<int> selectedTabNotifier = ValueNotifier<int>(0);

  static void switchToTab(int index) {
    selectedTabNotifier.value = index;
  }

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with WidgetsBindingObserver {
  int _currentIndex = 0;
  late bool _isSidebarExpanded;
  bool _isSyncing = false;

  static const List<String> _tabPaths = [
    '/library',
    '/updates',
    '/history',
    '/browse',
    '/settings',
  ];

  @override
  void initState() {
    super.initState();
    // The route pageBuilder (app.dart) calls MainShell.switchToTab(index)
    // BEFORE this widget is mounted, so selectedTabNotifier already holds the
    // tab the deep link / notification asked for. Honor it instead of
    // clobbering it with the startScreen preference — previously
    // _router.go('/updates') from a notification would land on the Library tab
    // (or whatever startScreen says) with the URL desynced.
    _currentIndex = MainShell.selectedTabNotifier.value;
    if (_currentIndex == 0) {
      // Notifier untouched (still the default) — apply the user's
      // startScreen preference for a cold launch on /library.
      final startScreen = SettingsService.instance.startScreen.toLowerCase();
      switch (startScreen) {
        case 'updates':
          _currentIndex = 1;
          break;
        case 'history':
          _currentIndex = 2;
          break;
        case 'browse':
          _currentIndex = 3;
          break;
        default:
          _currentIndex = 0;
      }
    }
    MainShell.selectedTabNotifier.value = _currentIndex;
    _isSidebarExpanded = SettingsService.instance.tabletSidebarExpanded;
    MainShell.selectedTabNotifier.addListener(_onExternalTabChange);
    WidgetsBinding.instance.addObserver(this);
    GraphQLClientService.instance.authErrorNotifier.addListener(_onAuthErrorChanged);
  }

  bool _authBannerShown = false;

  /// Surfaces 401/403 responses from the server as a one-shot "Reconnect to
  /// server" prompt instead of silent sync/library failures.
  void _onAuthErrorChanged() {
    if (!GraphQLClientService.instance.authErrorNotifier.value) {
      _authBannerShown = false;
      return;
    }
    if (_authBannerShown || !mounted) return;
    _authBannerShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: const Text('Server rejected your login (401/403). Reconnect to keep syncing.'),
          action: SnackBarAction(
            label: 'Reconnect',
            onPressed: () => context.push('/settings/server'),
          ),
        ),
      );
    });
  }

  void _onExternalTabChange() {
    final target = MainShell.selectedTabNotifier.value;
    if (_currentIndex != target && mounted) {
      setState(() => _currentIndex = target);
      // Navigate via GoRouter to keep URL in sync
      if (target >= 0 && target < _tabPaths.length) {
        context.go(_tabPaths[target]);
      }
    }
  }

  @override
  void dispose() {
    MainShell.selectedTabNotifier.removeListener(_onExternalTabChange);
    WidgetsBinding.instance.removeObserver(this);
    GraphQLClientService.instance.authErrorNotifier.removeListener(_onAuthErrorChanged);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // iOS/macOS suspend active transfers when the app backgrounds; unless we
      // reset the marker here the user would never learn the queue was
      // interrupted. Android (FGS) and desktop keep going in background.
      final wasInterrupted = DownloadManagerService.instance.consumeBackgroundInterrupted();
      if (wasInterrupted) {
        final pending = DownloadManagerService.instance.localTasks
            .where((t) =>
                t.status == LocalDownloadStatus.queued ||
                t.status == LocalDownloadStatus.downloading ||
                t.status == LocalDownloadStatus.paused)
            .length;
        NotificationService.instance.showDownloadsResumedNotification(queuedCount: pending);
      }
      // Resume the queue on foreground, but never override an explicit user
      // "Pause" (persisted across restarts).
      DownloadManagerService.instance.resumeLocalQueueAfterForeground();
      WebSocketService.instance.connect();
      if (GraphQLClientService.instance.isConfigured && !_isSyncing) {
        SyncEngine.instance.triggerSync();
      }
      if (!LibraryUpdateService.instance.isUpdating) {
        LibraryUpdateService.instance.checkForNewChapters(isManual: false);
      }
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      DownloadManagerService.instance.noteAppBackgrounded();
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
      MainShell.selectedTabNotifier.value = index;
      // Navigate via GoRouter to keep URL in sync
      if (index >= 0 && index < _tabPaths.length) {
        context.go(_tabPaths[index]);
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
    final isTablet = usesTabletShell(screenWidth);
    final primaryColor = Theme.of(context).colorScheme.primary;

    final scaffold = isTablet
        ? Scaffold(
            backgroundColor: const Color(0xFF0E0E14),
            body: Row(
              children: [
                _buildTabletSidebar(context, primaryColor),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 8.0, left: 4.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF15151E),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.40),
                            blurRadius: 24,
                            offset: const Offset(-3, 0),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: widget.child,
                    ),
                  ),
                ),
              ],
            ),
          )
        : Scaffold(
            extendBody: true,
            body: widget.child,
            bottomNavigationBar: ValueListenableBuilder<bool>(
              valueListenable: BatchModeService.instance.isBatchMode,
              builder: (context, isBatch, child) {
                if (isBatch) return const SizedBox.shrink();
                return child!;
              },
              child: SafeArea(
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
            ),
          );

    return PopScope(
      canPop: !SettingsService.instance.confirmExit && _currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (_currentIndex != 0) {
          _handleTabSelect(0);
          return;
        }
        if (SettingsService.instance.confirmExit) {
          final shouldExit = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: const Color(0xFF1F1F26),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.exit_to_app_rounded, color: Colors.amberAccent),
                  SizedBox(width: 8),
                  Text('Exit Sunfire', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              content: const Text('Are you sure you want to exit the application?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5722),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('Exit'),
                ),
              ],
            ),
          );
          if (shouldExit == true) {
            SystemNavigator.pop();
          }
        }
      },
      child: scaffold,
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // ── IPADOS FLOATING FROSTED GLASS SIDEBAR ───────────────────────────────────
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildTabletSidebar(BuildContext context, Color primaryColor) {
    final sidebarWidth = _isSidebarExpanded ? 242.0 : 72.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOutCubic,
      width: sidebarWidth,
      child: Padding(
        padding: EdgeInsets.only(top: 8, bottom: 8, left: 8, right: _isSidebarExpanded ? 0 : 4),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isExpanded = constraints.maxWidth >= sunfireSidebarExpandedLayoutMinWidth;
            return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xD0111119),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.50),
                    blurRadius: 30,
                    offset: const Offset(6, 0),
                  ),
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.05),
                    blurRadius: 40,
                  ),
                ],
              ),
              child: SafeArea(
                right: false,
                child: ClipRect(
                  child: Column(
                    crossAxisAlignment: isExpanded
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      _buildSidebarHeader(primaryColor, isExpanded),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.symmetric(
                            horizontal: isExpanded ? 10.0 : 6.0,
                          ),
                          children: [
                            if (isExpanded) ...[
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0, bottom: 6.0, top: 2.0),
                                child: Text(
                                  'MENU',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white.withValues(alpha: 0.28),
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                            ],
                            _buildSidebarItem(0, Icons.auto_stories_rounded, Icons.auto_stories_outlined, 'Library', isExpanded, primaryColor),
                            const SizedBox(height: 2),
                            _buildSidebarItem(1, Icons.notifications_rounded, Icons.notifications_outlined, 'Updates', isExpanded, primaryColor),
                            const SizedBox(height: 2),
                            _buildSidebarItem(2, Icons.history_rounded, Icons.history_outlined, 'History', isExpanded, primaryColor),
                            const SizedBox(height: 2),
                            _buildSidebarItem(3, Icons.explore_rounded, Icons.explore_outlined, 'Browse', isExpanded, primaryColor),
                            const SizedBox(height: 2),
                            _buildSidebarItem(4, Icons.settings_rounded, Icons.settings_outlined, 'Settings', isExpanded, primaryColor),
                            if (isExpanded) ...[
                              const SizedBox(height: 16),
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0, bottom: 6.0),
                                child: Text(
                                  'ACTIVITY',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white.withValues(alpha: 0.28),
                                    letterSpacing: 1.5,
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
                            ] else ...[
                              const SizedBox(height: 10),
                              ListenableBuilder(
                                listenable: DownloadManagerService.instance,
                                builder: (context, _) {
                                  final activeCount = DownloadManagerService.instance.localTasks
                                      .where((t) => t.status == LocalDownloadStatus.downloading || t.status == LocalDownloadStatus.queued)
                                      .length;
                                  return _buildCompactActionIcon(
                                    icon: Icons.download_rounded,
                                    label: 'Downloads Queue',
                                    badgeCount: activeCount > 0 ? activeCount : null,
                                    onTap: () => context.push('/downloads'),
                                  );
                                },
                              ),
                              _buildCompactActionIcon(
                                icon: Icons.insights_rounded,
                                label: 'Reading Stats',
                                onTap: () => context.push('/stats'),
                              ),
                            ],
                          ],
                        ),
                      ),
                      _buildBottomServerCard(primaryColor, isExpanded),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
          },
        ),
      ),
    );
  }

  Widget _buildSidebarHeader(Color primaryColor, bool isExpanded) {
    if (isExpanded) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0),
        child: ClipRect(
          child: Row(
            children: [
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
                        Flexible(
                          child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: primaryColor.withValues(alpha: 0.4), width: 0.6),
                          ),
                          child: Text(
                            'v3.0.0',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.view_sidebar_rounded, color: Colors.white60, size: 20),
                tooltip: 'Collapse sidebar',
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(width: 36, height: 36),
                onPressed: _toggleSidebar,
              ),
            ],
          ),
        ),
      );
    } else {
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
                    gradient: LinearGradient(
                      colors: [
                        primaryColor.withValues(alpha: 0.22),
                        primaryColor.withValues(alpha: 0.07),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border(
                      left: BorderSide(color: primaryColor, width: 2.5),
                    ),
                  )
                : const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
            child: Row(
              children: [
                Icon(
                  isSelected ? selectedIcon : unselectedIcon,
                  color: isSelected ? primaryColor : Colors.white.withValues(alpha: 0.55),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.65),
                      fontSize: 13.5,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0),
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
                  width: 40,
                  height: 40,
                  decoration: isSelected
                      ? BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              primaryColor.withValues(alpha: 0.30),
                              primaryColor.withValues(alpha: 0.12),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: primaryColor.withValues(alpha: 0.50), width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.18),
                              blurRadius: 12,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        )
                      : null,
                  child: Center(
                    child: Icon(
                      isSelected ? selectedIcon : unselectedIcon,
                      color: isSelected ? primaryColor : Colors.white.withValues(alpha: 0.55),
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

  Widget _buildCompactActionIcon({
    required IconData icon,
    required String label,
    int? badgeCount,
    required VoidCallback onTap,
  }) {
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
              onTap: onTap,
              child: SizedBox(
                width: 40,
                height: 40,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(icon, color: Colors.white60, size: 21),
                    if (badgeCount != null && badgeCount > 0)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.all(3.5),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                          child: Center(
                            child: Text(
                              '$badgeCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                height: 1,
                              ),
                            ),
                          ),
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
  }

  Widget _buildBottomServerCard(Color primaryColor, bool isExpanded) {
    final isConfigured = GraphQLClientService.instance.isConfigured;
    final serverUrl = SettingsService.instance.serverUrl;
    final statusColor = isConfigured ? const Color(0xFF4ADE80) : Colors.tealAccent;

    if (isExpanded) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => context.push('/settings/server'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                  decoration: BoxDecoration(
                    color: const Color(0x18FFFFFF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0x16FFFFFF), width: 0.8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: statusColor.withValues(alpha: 0.65), blurRadius: 8),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isConfigured ? 'Suwayomi Server' : 'Standalone Mode',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              isConfigured
                                  ? (Uri.tryParse(serverUrl)?.host ?? 'Connected')
                                  : 'On-Device QuickJS',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.45),
                                fontSize: 10.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: _handleQuickSync,
                        child: Tooltip(
                          message: 'Sync library',
                          child: AnimatedRotation(
                            turns: _isSyncing ? 1.0 : 0.0,
                            duration: const Duration(seconds: 1),
                            child: Icon(
                              Icons.sync_rounded,
                              color: _isSyncing ? primaryColor : Colors.white.withValues(alpha: 0.55),
                              size: 19,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14.0),
        child: Column(
          children: [
            Tooltip(
              message: 'Sync library',
              child: GestureDetector(
                onTap: _handleQuickSync,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _isSyncing
                        ? primaryColor.withValues(alpha: 0.18)
                        : const Color(0x12FFFFFF),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: _isSyncing
                          ? primaryColor.withValues(alpha: 0.4)
                          : const Color(0x14FFFFFF),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: AnimatedRotation(
                      turns: _isSyncing ? 1.0 : 0.0,
                      duration: const Duration(seconds: 1),
                      child: Icon(
                        Icons.sync_rounded,
                        color: _isSyncing ? primaryColor : Colors.white.withValues(alpha: 0.55),
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: statusColor.withValues(alpha: 0.65), blurRadius: 8),
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

    return Expanded(
      child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _handleTabSelect(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(horizontal: isSelected ? 10 : 6, vertical: 8),
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
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? selectedIcon : unselectedIcon,
                color: isSelected ? Colors.white : Colors.grey.shade400,
                size: 22,
              ),
              if (isSelected) ...[
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
    );
  }
}
