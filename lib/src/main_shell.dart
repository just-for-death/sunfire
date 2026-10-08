import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'core/services/batch_mode_service.dart';
import 'core/services/download_manager_service.dart';
import 'core/services/library_update_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/settings_service.dart';
import 'core/sync/graphql_client_service.dart';
import 'core/sync/server_session_service.dart';
import 'core/sync/sync_engine.dart';
import 'core/sync/websocket_service.dart';
import 'features/settings/server_login_sheet.dart';
import 'ui/shell/nav_chrome.dart';
import 'ui/shell/rail_extras.dart';
import 'ui/shell/sunfire_breakpoints.dart';
import 'ui/shell/tablet_ui_prefs.dart';
import 'ui/widgets/dialog_title.dart';

/// Manga detail two-pane (cover + chapter list). Wider than the shell rail breakpoint.
const double sunfireDetailTwoPaneMinWidth = 840.0;

/// Inner sidebar width at which labels/header Row are shown. Below this, compact
/// icons are used so expand/collapse animation cannot overflow (~36px Row).
const double sunfireSidebarExpandedLayoutMinWidth = 180.0;

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.child, this.isFullscreen = false});

  final Widget child;

  /// Fullscreen routes (the reader) render without the tablet sidebar rail
  /// or the phone bottom bar. Lifecycle observers, sync triggers and the
  /// exit-confirm gate keep running — only the chrome is suppressed.
  final bool isFullscreen;

  static final ValueNotifier<int> selectedTabNotifier = ValueNotifier<int>(0);

  /// Cheap unread-updates badge for nav chrome (UIS-P3-2).
  /// Updated by [UpdatesScreen] when the feed loads or read-state changes —
  /// no DB work in [MainShell.build].
  static final ValueNotifier<int> updatesBadgeNotifier = ValueNotifier<int>(0);

  static void switchToTab(int index) {
    selectedTabNotifier.value = index;
  }

  /// Publishes the Updates-tab unread count to the nav badge.
  static void setUpdatesBadge(int count) {
    final next = count < 0 ? 0 : count;
    if (updatesBadgeNotifier.value != next) {
      updatesBadgeNotifier.value = next;
    }
  }

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with WidgetsBindingObserver {
  /// UIS-14: shell chrome colours come from the active scheme (Light works).
  ColorScheme get _cs => Theme.of(context).colorScheme;

  int _currentIndex = 0;
  late bool _isSidebarExpanded;
  bool _isSyncing = false;
  /// UIS-20 / ISS-010: from PackageInfo; null while loading (chip hidden).
  String? _appVersionLabel;

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
    MainShell.updatesBadgeNotifier.addListener(_onUpdatesBadgeChanged);
    SettingsService.instance.addListener(_onSettingsChanged);
    TabletUiPrefs.listenable.addListener(_onTabletUiModeChanged);
    unawaited(TabletUiPrefs.load());
    WidgetsBinding.instance.addObserver(this);
    GraphQLClientService.instance.authErrorNotifier.addListener(_onAuthErrorChanged);
    ServerSessionService.instance.needsLoginNotifier.addListener(_onNeedsLoginChanged);
    unawaited(_loadAppVersion());
  }

  Future<void> _loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted || info.version.isEmpty) return;
      setState(() => _appVersionLabel = 'v${info.version}');
    } catch (_) {
      // Leave chip hidden if PackageInfo unavailable (tests / desktop).
    }
  }

  void _onSettingsChanged() {
    if (!mounted) return;
    final expanded = SettingsService.instance.tabletSidebarExpanded;
    // Rebuild on tablet chrome pref changes so bar↔rail updates live (UIS-P2-A).
    setState(() => _isSidebarExpanded = expanded);
  }

  void _onTabletUiModeChanged() {
    if (!mounted) return;
    setState(() {});
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

  bool _loginPromptShown = false;

  /// Session refresh failed — prompt for UI_LOGIN / SIMPLE_LOGIN credentials (B2).
  void _onNeedsLoginChanged() {
    if (!ServerSessionService.instance.needsLoginNotifier.value) {
      _loginPromptShown = false;
      return;
    }
    if (_loginPromptShown || !mounted) return;
    _loginPromptShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final mode = ServerSessionService.instance.mode ??
          loginModeForAuthMode(
            // Fall back to UI login when mode unknown but renew failed.
            'UI_LOGIN',
          );
      await showServerLoginSheet(context, mode: mode ?? ServerLoginMode.uiLogin);
      _loginPromptShown = false;
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

  void _onUpdatesBadgeChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    MainShell.selectedTabNotifier.removeListener(_onExternalTabChange);
    MainShell.updatesBadgeNotifier.removeListener(_onUpdatesBadgeChanged);
    SettingsService.instance.removeListener(_onSettingsChanged);
    TabletUiPrefs.listenable.removeListener(_onTabletUiModeChanged);
    WidgetsBinding.instance.removeObserver(this);
    GraphQLClientService.instance.authErrorNotifier.removeListener(_onAuthErrorChanged);
    ServerSessionService.instance.needsLoginNotifier.removeListener(_onNeedsLoginChanged);
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
        // Only notify if there are pending tasks AND the queue is not explicitly
        // paused. An explicitly paused queue (user hit FGS "Stop") will not
        // resume on foreground, so the "resumed" claim would be false.
        if (pending > 0 && !DownloadManagerService.instance.isQueuePaused) {
          unawaited(NotificationService.instance.showDownloadsResumedNotification(queuedCount: pending));
        }
      }
      // Resume the queue on foreground, but never override an explicit user
      // "Pause" (persisted across restarts).
      DownloadManagerService.instance.resumeLocalQueueAfterForeground();
      WebSocketService.instance.connect();
      if (GraphQLClientService.instance.isConfigured && !_isSyncing) {
        unawaited(SyncEngine.instance.triggerSync());
      }
      if (!LibraryUpdateService.instance.isUpdating) {
        unawaited(LibraryUpdateService.instance.checkForNewChapters(isManual: false));
      }
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        // `detached` is the terminal state on Android engine-detach and on
        // desktop window close, and on some paths is not preceded by `paused`.
        // Without it, a kill while the download queue was mid-flight was never
        // marked interrupted, so the resume notification that tells the user
        // their downloads were cut short never fired.
        state == AppLifecycleState.detached) {
      DownloadManagerService.instance.noteAppBackgrounded();
    }
  }

  void _handleTabSelect(int index) {
    if (_currentIndex != index) {
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        unawaited(HapticFeedback.lightImpact());
      } else {
        unawaited(HapticFeedback.selectionClick());
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
    unawaited(HapticFeedback.selectionClick());
    setState(() {
      _isSidebarExpanded = !_isSidebarExpanded;
      SettingsService.instance.tabletSidebarExpanded = _isSidebarExpanded;
    });
  }

  Future<void> _handleQuickSync() async {
    if (_isSyncing) return;
    unawaited(HapticFeedback.mediumImpact());
    setState(() => _isSyncing = true);
    try {
      await SyncEngine.instance.triggerSync();
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  /// iOS (Apple mobile) keeps Sunfire's glass identity; Android and desktop
  /// use Material 3 chrome, molded to Sunfire's 5 tabs and extras
  /// (fullscreen reader, batch-mode hiding).
  /// Uses the theme platform (not `dart:io`) so tests can select iOS vs
  /// Android via `debugDefaultTargetPlatformOverride`.
  bool _useGlassChrome(BuildContext context) => isAppleMobile(context);

  bool _reduceEffects(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  /// Compact overflow mode: first 4 tabs + a "More" sheet (Settings,
  /// Downloads, Stats). Narrow windows and large accessibility text would
  /// otherwise overflow the 5-up bar.
  bool _useCompactNav(BuildContext context) =>
      SunfireBreakpoints.isCompactNav(context);

  Future<void> _showMoreOverflow() async {
    final activeDownloads = DownloadManagerService.instance.localTasks
        .where((t) =>
            t.status == LocalDownloadStatus.downloading ||
            t.status == LocalDownloadStatus.queued)
        .length;
    final picked = await NavOverflowSheet.show(
      context,
      destinations: const [
        SunfireNavDestination(
          label: 'Settings',
          icon: Icons.settings_outlined,
          activeIcon: Icons.settings_rounded,
        ),
      ],
      selectedIndex: _currentIndex == 4 ? 0 : -1,
      extraActions: [
        NavOverflowAction(
          label: 'Downloads',
          icon: Icons.download_rounded,
          badgeCount: activeDownloads > 0 ? activeDownloads : null,
          onTap: () => context.push('/downloads'),
        ),
        NavOverflowAction(
          label: 'Reading Stats',
          icon: Icons.insights_rounded,
          onTap: () => context.push('/stats'),
        ),
      ],
    );
    if (picked != null && picked == 0 && mounted) {
      _handleTabSelect(4);
    }
  }

  /// Phone / narrow-window bottom chrome, hidden during batch mode and in
  /// fullscreen (reader). iOS gets the glass pill, Android/desktop the
  /// Material 3 bar.
  Widget? _buildPhoneChrome(
    BuildContext context,
    List<SunfireNavDestination> destinations,
    bool compact,
    bool useGlass,
  ) {
    return ValueListenableBuilder<bool>(
      valueListenable: BatchModeService.instance.isBatchMode,
      builder: (context, isBatch, child) {
        if (isBatch) return const SizedBox.shrink();
        return child!;
      },
      child: useGlass
          ? IOSGlassTabBar(
              destinations: destinations,
              selectedIndex: _currentIndex,
              onSelect: _handleTabSelect,
              compact: compact,
              onMore: _showMoreOverflow,
            )
          : AndroidPhoneNavBar(
              destinations: destinations,
              selectedIndex: _currentIndex,
              onSelect: _handleTabSelect,
              compact: compact,
              onMore: _showMoreOverflow,
            ),
    );
  }

  /// Wide tablet / desktop shell with a side rail.
  ///
  /// - iPad → Sunfire's floating frosted-glass sidebar + rounded content
  ///   card (kept as-is; it already matches the glass-sidebar concept).
  /// - Android / desktop → Material 3 [NavigationRail] + plain content
  ///   (Android-tablet pattern).
  Widget _buildWideShell(
    BuildContext context,
    Color primaryColor,
    List<SunfireNavDestination> destinations,
    bool useGlass,
  ) {
    if (useGlass) {
      return _buildIPadGlassShell(context, primaryColor);
    }
    final width = MediaQuery.sizeOf(context).width;
    // UIS-P2-B: "Expanded Sidebar" drives NavigationRail.extended on
    // Android/desktop too, whenever the window has room for labels.
    final extended =
        _isSidebarExpanded && width >= sunfireRailExtendedMinWidth;
    return Scaffold(
      body: Row(
        children: [
          AndroidTabletRail(
            destinations: destinations,
            selectedIndex: _currentIndex,
            onSelect: _handleTabSelect,
            extended: extended,
            leading: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: extended
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    extended
                        ? Icons.view_sidebar_rounded
                        : Icons.view_sidebar_outlined,
                  ),
                  tooltip: extended ? 'Collapse sidebar' : 'Expand sidebar',
                  onPressed: _toggleSidebar,
                ),
                const SizedBox(height: 8),
                // Kotatsu-style rail header FAB.
                SunfireContinueReadingButton(
                  extended: extended,
                  onOpen: (route) => context.push(route),
                ),
                const SizedBox(height: 8),
              ],
            ),
            trailing: ListenableBuilder(
              listenable: DownloadManagerService.instance,
              builder: (c, _) => SunfireRailTrailing(
                extended: extended,
                activeDownloads: DownloadManagerService.instance.localTasks
                    .where((t) =>
                        t.status == LocalDownloadStatus.downloading ||
                        t.status == LocalDownloadStatus.queued)
                    .length,
                onDownloads: () => context.push('/downloads'),
                onStats: () => context.push('/stats'),
              ),
            ),
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(child: widget.child),
        ],
      ),
    );
  }

  /// iPad glass shell: the pre-existing floating frosted sidebar + rounded
  /// content card, extracted unchanged so the iPad identity is preserved.
  Widget _buildIPadGlassShell(
      BuildContext context, Color primaryColor) {
    return Scaffold(
      backgroundColor: _cs.surface,
      body: Row(
        children: [
          _buildTabletSidebar(context, primaryColor),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 8.0, bottom: 8.0, right: 8.0, left: 4.0),
              child: Container(
                decoration: BoxDecoration(
                  color: _cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _cs.shadow.withValues(
                          alpha: _cs.brightness == Brightness.dark ? 0.40 : 0.12),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    // Fullscreen (reader): no sidebar rail, no bottom bar, no content
    // padding — edge-to-edge reading surface on phone and tablet alike.
    // Lifecycle observers and the exit-confirm gate below keep running.
    final fullscreen = widget.isFullscreen;
    final useGlass = _useGlassChrome(context);
    // UIS-P3-2: badge from MainShell.updatesBadgeNotifier (set by UpdatesScreen).
    final badge = MainShell.updatesBadgeNotifier.value;
    final destinations = sunfireNavDestinations(
      updatesBadge: badge > 0 ? badge : null,
    );

    final Widget scaffold;
    if (fullscreen) {
      // Fullscreen (reader): edge-to-edge, no chrome of any kind.
      scaffold = Scaffold(
        backgroundColor: Colors.black,
        body: widget.child,
      );
    } else if (SunfireBreakpoints.usesSideRail(context)) {
      scaffold = _buildWideShell(
          context, primaryColor, destinations, useGlass);
    } else {
      final compact = _useCompactNav(context);
      scaffold = Scaffold(
        extendBody: true,
        body: widget.child,
        bottomNavigationBar: _buildPhoneChrome(
            context, destinations, compact, useGlass),
      );
    }

    return PopScope(
      // Fullscreen routes (reader) pop normally: the tab-reset gate below
      // would otherwise hijack system-back into a jump to Library.
      canPop: widget.isFullscreen || (!SettingsService.instance.confirmExit && _currentIndex == 0),
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (!widget.isFullscreen && _currentIndex != 0) {
          _handleTabSelect(0);
          return;
        }
        if (SettingsService.instance.confirmExit) {
          final shouldExit = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: _cs.surfaceContainerHigh,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const DialogTitle(
                icon: Icons.exit_to_app_rounded,
                iconColor: Colors.amberAccent,
                text: 'Exit Sunfire',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: const Text('Are you sure you want to exit the application?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: Text('Cancel', style: TextStyle(color: _cs.onSurfaceVariant)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _cs.primary,
                    foregroundColor: _cs.onPrimary,
                  ),
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('Exit'),
                ),
              ],
            ),
          );
          if (shouldExit == true) {
            unawaited(SystemNavigator.pop());
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
          // UIS-P2-C: same static-tint fallback as the glass tab bar
          // (UIS-17) when the platform asks to reduce effects.
          child: IOSGlassTabBar.maybeBlur(
            reduceEffects: _reduceEffects(context),
            sigma: 28,
            child: Container(
              decoration: BoxDecoration(
                color: _cs.surfaceContainer
                    .withValues(alpha: _reduceEffects(context) ? 0.96 : 0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: _cs.outlineVariant.withValues(alpha: 0.3), width: 0.8),
                boxShadow: [
                  BoxShadow(
                    color: _cs.shadow.withValues(
                        alpha: _cs.brightness == Brightness.dark ? 0.50 : 0.12),
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
                      const SizedBox(height: 12),
                      // UIS-P2-B: Kotatsu-style "Continue reading" header action.
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: isExpanded ? 12.0 : 0.0),
                        child: SunfireContinueReadingButton(
                          extended: isExpanded,
                          onOpen: (route) => context.push(route),
                        ),
                      ),
                      const SizedBox(height: 12),
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
                                    color: _cs.onSurfaceVariant.withValues(alpha: 0.7),
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
                                    color: _cs.onSurfaceVariant.withValues(alpha: 0.7),
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
                child: Icon(Icons.local_fire_department_rounded, color: _cs.onPrimary, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Sunfire',
                      style: TextStyle(
                        color: _cs.onSurface,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.4,
                      ),
                    ),
                    if (_appVersionLabel != null)
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
                              _appVersionLabel!,
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
                icon: Icon(Icons.view_sidebar_rounded, color: _cs.onSurfaceVariant, size: 20),
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
            icon: Icon(Icons.view_sidebar_outlined, color: _cs.onSurfaceVariant, size: 22),
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
              child: Icon(Icons.local_fire_department_rounded, color: _cs.onPrimary, size: 22),
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
                  color: isSelected ? primaryColor : _cs.onSurfaceVariant,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? _cs.onSurface : _cs.onSurfaceVariant,
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
                      color: isSelected ? primaryColor : _cs.onSurfaceVariant,
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
              Icon(icon, color: _cs.onSurfaceVariant, size: 19),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: _cs.onSurfaceVariant,
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
                    style: TextStyle(color: _cs.onPrimary, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                )
              else
                Icon(Icons.chevron_right_rounded, color: _cs.onSurfaceVariant.withValues(alpha: 0.6), size: 18),
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
                    Icon(icon, color: _cs.onSurfaceVariant, size: 21),
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
                              style: TextStyle(
                                color: _cs.onPrimary,
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
    final statusColor = isConfigured ? _cs.tertiary : _cs.primary;

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
                    color: _cs.surfaceContainerHighest.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: _cs.outlineVariant.withValues(alpha: 0.3), width: 0.8),
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
                              style: TextStyle(
                                color: _cs.onSurface,
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
                                color: _cs.onSurfaceVariant,
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
                              color: _isSyncing ? primaryColor : _cs.onSurfaceVariant,
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
                        : _cs.surfaceContainerHighest.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: _isSyncing
                          ? primaryColor.withValues(alpha: 0.4)
                          : _cs.outlineVariant.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: AnimatedRotation(
                      turns: _isSyncing ? 1.0 : 0.0,
                      duration: const Duration(seconds: 1),
                      child: Icon(
                        Icons.sync_rounded,
                        color: _isSyncing ? primaryColor : _cs.onSurfaceVariant,
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

}
