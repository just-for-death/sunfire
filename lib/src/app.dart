import 'dart:async';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/logging/logger_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/settings_service.dart';
import 'features/browse/browse_screen.dart';
import 'features/downloads/download_queue_screen.dart';
import 'features/history/history_screen.dart';
import 'features/library/library_screen.dart';
import 'features/manga_detail/manga_detail_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/reader/reader_screen.dart';
import 'features/settings/about_screen.dart';
import 'features/settings/advanced_settings_screen.dart';
import 'features/settings/appearance_settings_screen.dart';
import 'features/settings/backup_settings_screen.dart';
import 'features/settings/browse_settings_screen.dart';
import 'features/settings/downloads_settings_screen.dart';
import 'features/settings/extension_repos_screen.dart';
import 'features/settings/general_settings_screen.dart';
import 'features/settings/import_tachibk_screen.dart';
import 'features/settings/library_settings_screen.dart';
import 'features/settings/reader_settings_screen.dart';
import 'features/settings/server_settings_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/stats/stats_screen.dart';
import 'features/updates/updates_screen.dart';
import 'main_shell.dart';
import 'ui/design_system/sunfire_theme.dart';
import 'ui/shell/sunfire_breakpoints.dart';

/// Number of times [SunfireApp] has (re)built its light/dark themes. Tests use
/// it to check unrelated setting changes don't rebuild themes (UIS-15).
@visibleForTesting
int debugThemeBuildCount = 0;

double effectiveTopSafeInset({
  required double rawTop,
  required bool isApple,
  required bool isTablet,
}) {
  if (rawTop > 0.5) return rawTop;
  return isApple ? (isTablet ? 24.0 : 47.0) : 0.0;
}

/// Builds the widget shown for a shell tab.
///
/// Production passes nothing and gets the real feature screens. Tests inject
/// lightweight placeholders so routing, tab synchronisation and responsive
/// layout can be exercised without booting every screen's service init.
typedef SunfireTabPageBuilder = Widget Function(int tabIndex);

Widget _defaultTabPage(int tabIndex) {
  switch (tabIndex) {
    case 0:
      return const LibraryScreen();
    case 1:
      return const UpdatesScreen();
    case 2:
      return const HistoryScreen();
    case 3:
      return const BrowseScreen();
    default:
      return const SettingsScreen();
  }
}

CustomTransitionPage<void> sunfireTransitionPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 260),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curveAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curveAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.04, 0.0),
            end: Offset.zero,
          ).animate(curveAnimation),
          child: child,
        ),
      );
    },
  );
}

/// Shell tab path -> [MainShell] tab index.
///
/// `/more` and `/settings` are aliases for the same tab; both are kept so
/// legacy deep links and the mobile "More" affordance keep working.
const List<MapEntry<String, int>> sunfireTabRoutes = [
  MapEntry('/library', 0),
  MapEntry('/updates', 1),
  MapEntry('/history', 2),
  MapEntry('/browse', 3),
  MapEntry('/more', 4),
  MapEntry('/settings', 4),
];

/// Single source of truth for app routing.
///
/// Extracted from `initState` so tests can drive the real route table
/// (including [MainShell] tab synchronisation and the [ShellRoute] shell)
/// rather than re-declaring an approximation of it that can drift.
///
/// [tabBuilder] replaces the five shell tab pages with stubs, and
/// [initialLocation] overrides the onboarding-derived landing route, so tests
/// can assert routing and responsive chrome without booting every screen.
GoRouter buildAppRouter({
  SunfireTabPageBuilder? tabBuilder,
  String? initialLocation,
}) {
  final tabPage = tabBuilder ?? _defaultTabPage;
  return GoRouter(
    initialLocation: initialLocation ??
        (SettingsService.instance.onboardingCompleted ? '/library' : '/onboarding'),
    observers: [_NavigationLogger()],
    routes: [
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => sunfireTransitionPage(
          state: state,
          child: const OnboardingScreen(),
        ),
      ),
      ShellRoute(
        pageBuilder: (context, state, child) {
          // Single MainShell instance; the router owns which tab is active.
          // The reader is fullscreen: same shell (lifecycle observers keep
          // running) but without the sidebar rail / bottom bar chrome.
          final path = state.uri.path;
          final fullscreen = path == '/reader' || path.startsWith('/reader/');
          return NoTransitionPage(
            child: MainShell(isFullscreen: fullscreen, child: child),
          );
        },
        routes: [
          for (final tab in sunfireTabRoutes)
            GoRoute(
              path: tab.key,
              pageBuilder: (context, state) {
                // Runs before MainShell mounts, so selectedTabNotifier is
                // already set when the shell reads it in initState.
                MainShell.switchToTab(tab.value);
                return NoTransitionPage(child: tabPage(tab.value));
              },
            ),
          GoRoute(
            path: '/settings/server',
            pageBuilder: (context, state) => sunfireTransitionPage(
              state: state,
              child: const ServerSettingsScreen(),
            ),
          ),
          GoRoute(
            path: '/settings/library',
            pageBuilder: (context, state) => sunfireTransitionPage(
              state: state,
              child: const LibrarySettingsScreen(),
            ),
          ),
          GoRoute(
            path: '/settings/downloads',
            pageBuilder: (context, state) => sunfireTransitionPage(
              state: state,
              child: const DownloadsSettingsScreen(),
            ),
          ),
          GoRoute(
            path: '/settings/browse',
            pageBuilder: (context, state) => sunfireTransitionPage(
              state: state,
              child: const BrowseSettingsScreen(),
            ),
          ),
          GoRoute(
            path: '/settings/backup',
            pageBuilder: (context, state) => sunfireTransitionPage(
              state: state,
              child: const BackupSettingsScreen(),
            ),
          ),
          GoRoute(
            path: '/settings/import-backup',
            pageBuilder: (context, state) => sunfireTransitionPage(
              state: state,
              child: const ImportTachibkScreen(),
            ),
          ),
          GoRoute(
            path: '/settings/reader',
            pageBuilder: (context, state) => sunfireTransitionPage(
              state: state,
              child: const ReaderSettingsScreen(),
            ),
          ),
          GoRoute(
            path: '/settings/appearance',
            pageBuilder: (context, state) => sunfireTransitionPage(
              state: state,
              child: const AppearanceSettingsScreen(),
            ),
          ),
          GoRoute(
            path: '/settings/general',
            pageBuilder: (context, state) => sunfireTransitionPage(
              state: state,
              child: const GeneralSettingsScreen(),
            ),
          ),
          GoRoute(
            path: '/settings/advanced',
            pageBuilder: (context, state) => sunfireTransitionPage(
              state: state,
              child: const AdvancedSettingsScreen(),
            ),
          ),
          GoRoute(
            path: '/settings/about',
            pageBuilder: (context, state) => sunfireTransitionPage(
              state: state,
              child: const AboutScreen(),
            ),
          ),
          GoRoute(
            path: '/settings/extension-repos',
            pageBuilder: (context, state) => sunfireTransitionPage(
              state: state,
              child: const ExtensionReposScreen(),
            ),
          ),
          GoRoute(
            path: '/downloads',
            pageBuilder: (context, state) => sunfireTransitionPage(
              state: state,
              child: const DownloadQueueScreen(),
            ),
          ),
          GoRoute(
            path: '/stats',
            pageBuilder: (context, state) => sunfireTransitionPage(
              state: state,
              child: const StatsScreen(),
            ),
          ),
          GoRoute(
            path: '/manga/:id',
            pageBuilder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
              return sunfireTransitionPage(
                state: state,
                child: MangaDetailScreen(mangaServerId: id),
              );
            },
          ),
          GoRoute(
            path: '/reader/:id',
            pageBuilder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
              return sunfireTransitionPage(
                state: state,
                child: ReaderScreen(chapterServerId: id),
              );
            },
          ),
        ],
      ),
    ],
  );
}


class SunfireApp extends StatefulWidget {
  const SunfireApp({super.key});

  @override
  State<SunfireApp> createState() => _SunfireAppState();
}

class _SunfireAppState extends State<SunfireApp> {
  late final GoRouter _router;
  AppLinks? _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  StreamSubscription<String?>? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    _router = buildAppRouter();
    _initIncomingLinks();
  }

  void _initIncomingLinks() {
    // Check cold-start notification tap
    final initialPayload = NotificationService.instance.consumeInitialPayload();
    if (initialPayload != null && initialPayload.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (initialPayload == '/updates') {
          _router.go('/updates');
        } else {
          unawaited(_router.push(initialPayload));
        }
      });
    }

    _notificationSubscription = NotificationService.instance.onNotificationTapped.listen((route) {
      if (route != null && route.isNotEmpty) {
        if (route == '/updates') {
          _router.go('/updates');
        } else {
          unawaited(_router.push(route));
        }
      }
    });

    try {
      _appLinks = AppLinks();
      _linkSubscription = _appLinks!.uriLinkStream.listen(_handleUri);
      unawaited(_appLinks!.getInitialLink().then((uri) {
        if (uri != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _handleUri(uri));
        }
      }).catchError((Object e) {
        debugPrint('[app] Failed to get initial link: $e');
      }));
    } catch (ignoredError) { if (kDebugMode) debugPrint('[app] ignored error: $ignoredError'); }
  }

  void _handleUri(Uri uri) {
    if (uri.scheme == 'sunfire') {
      if (uri.host == 'manga' && uri.pathSegments.isNotEmpty) {
        final idStr = uri.pathSegments.first;
        final id = int.tryParse(idStr);
        if (id != null && id > 0) {
          unawaited(_router.push('/manga/$id'));
        }
      } else if (uri.host == 'reader' && uri.pathSegments.isNotEmpty) {
        final idStr = uri.pathSegments.first;
        final id = int.tryParse(idStr);
        if (id != null && id != 0) {
          unawaited(_router.push('/reader/$id'));
        }
      } else if (uri.host == 'library') {
        _router.go('/library');
      } else if (uri.host == 'updates') {
        _router.go('/updates');
      } else if (uri.host == 'history') {
        _router.go('/history');
      } else if (uri.host == 'browse') {
        _router.go('/browse');
      } else if (uri.host == 'more' || uri.host == 'settings') {
        _router.go('/settings');
      } else if (uri.host == 'downloads') {
        unawaited(_router.push('/downloads'));
      } else if (uri.host == 'stats') {
        unawaited(_router.push('/stats'));
      }
    }
  }

  ({
    String accent,
    bool oled,
    bool materialYou,
    ColorScheme? lightDynamic,
    ColorScheme? darkDynamic,
  })? _themeKey;
  ThemeData? _lightTheme;
  ThemeData? _darkTheme;

  @override
  void dispose() {
    unawaited(_linkSubscription?.cancel());
    unawaited(_notificationSubscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SettingsService.instance,
      builder: (context, child) {
        return DynamicColorBuilder(
          builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
            final useMaterialYou = (!kIsWeb && Platform.isAndroid) && SettingsService.instance.materialYouEnabled;
            final isOled = SunfireTheme.isOledMode;

            // UIS-15: SettingsService notifies on every toggle; only rebuild
            // the (ColorScheme.fromSeed-heavy) themes when a theme input changes.
            final themeKey = (
              accent: SettingsService.instance.accentColorName,
              oled: isOled,
              materialYou: useMaterialYou,
              lightDynamic: useMaterialYou ? lightDynamic : null,
              darkDynamic: useMaterialYou ? darkDynamic : null,
            );
            if (themeKey != _themeKey || _lightTheme == null || _darkTheme == null) {
              _themeKey = themeKey;
              _lightTheme = SunfireTheme.buildLightTheme(
                dynamicScheme: themeKey.lightDynamic,
              );
              _darkTheme = SunfireTheme.buildDarkTheme(
                dynamicScheme: themeKey.darkDynamic,
                isOled: isOled,
              );
              debugThemeBuildCount++;
            }
            final lightTheme = _lightTheme!;
            final darkTheme = _darkTheme!;

            return MaterialApp.router(
              title: 'Sunfire',
              debugShowCheckedModeBanner: false,
              locale: (SettingsService.instance.appLocale == 'system' || SettingsService.instance.appLocale.isEmpty)
                  ? null
                  : Locale(SettingsService.instance.appLocale),
              themeMode: SunfireTheme.effectiveThemeMode,
              theme: lightTheme,
              darkTheme: darkTheme,
              routerConfig: _router,
              builder: (context, child) {
                final mediaQuery = MediaQuery.of(context);
                final isTablet = mediaQuery.size.width >= SunfireBreakpoints.narrowTabletMaxWidth;
                final isApple = Theme.of(context).platform == TargetPlatform.iOS ||
                    Theme.of(context).platform == TargetPlatform.macOS;

                // Only invent a top inset when the platform reports none (sideload /
                // LiveContainer). Never raise a real iPad/iPhone inset — that draws a
                // second status-bar strip over the UI.
                final rawTop = mediaQuery.padding.top;
                final rawViewTop = mediaQuery.viewPadding.top;
                final fallbackTop = effectiveTopSafeInset(
                  rawTop: rawTop,
                  isApple: isApple,
                  isTablet: isTablet,
                );
                final effectiveTopPadding = rawTop > 0.5 ? rawTop : fallbackTop;
                final effectiveTopViewPadding = rawViewTop > 0.5 ? rawViewTop : fallbackTop;

                return MediaQuery(
                  data: mediaQuery.copyWith(
                    padding: mediaQuery.padding.copyWith(top: effectiveTopPadding),
                    viewPadding: mediaQuery.viewPadding.copyWith(top: effectiveTopViewPadding),
                  ),
                  child: child ?? const SizedBox.shrink(),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _NavigationLogger extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    unawaited(LoggerService.instance.logInfo('Navigated to ${route.settings.name ?? route.runtimeType}', 'Navigation'));
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    unawaited(LoggerService.instance.logInfo('Popped from ${route.settings.name ?? route.runtimeType}', 'Navigation'));
  }
}
