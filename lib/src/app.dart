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
import 'core/theme/app_theme.dart';
import 'features/downloads/download_queue_screen.dart';
import 'features/manga_detail/manga_detail_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/reader/reader_screen.dart';
import 'features/settings/advanced_settings_screen.dart';
import 'features/settings/appearance_settings_screen.dart';
import 'features/settings/backup_settings_screen.dart';
import 'features/settings/browse_settings_screen.dart';
import 'features/settings/downloads_settings_screen.dart';
import 'features/settings/extension_repos_screen.dart';
import 'features/settings/general_settings_screen.dart';
import 'features/settings/library_settings_screen.dart';
import 'features/settings/reader_settings_screen.dart';
import 'features/settings/server_settings_screen.dart';
import 'features/stats/stats_screen.dart';
import 'main_shell.dart';

double effectiveTopSafeInset({
  required double rawTop,
  required bool isApple,
  required bool isTablet,
}) {
  if (rawTop > 0.5) return rawTop;
  return isApple ? (isTablet ? 24.0 : 47.0) : 0.0;
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

  CustomTransitionPage<void> _buildTransitionPage({
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

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      initialLocation: SettingsService.instance.onboardingCompleted ? '/library' : '/onboarding',
      observers: [_NavigationLogger()],
      routes: [
        GoRoute(
          path: '/onboarding',
          pageBuilder: (context, state) => _buildTransitionPage(
            state: state,
            child: const OnboardingScreen(),
          ),
        ),
        GoRoute(
          path: '/library',
          pageBuilder: (context, state) {
            MainShell.switchToTab(0);
            return _buildTransitionPage(
              state: state,
              child: const MainShell(),
            );
          },
        ),
        GoRoute(
          path: '/updates',
          pageBuilder: (context, state) {
            MainShell.switchToTab(1);
            return _buildTransitionPage(
              state: state,
              child: const MainShell(),
            );
          },
        ),
        GoRoute(
          path: '/history',
          pageBuilder: (context, state) {
            MainShell.switchToTab(2);
            return _buildTransitionPage(
              state: state,
              child: const MainShell(),
            );
          },
        ),
        GoRoute(
          path: '/browse',
          pageBuilder: (context, state) {
            MainShell.switchToTab(3);
            return _buildTransitionPage(
              state: state,
              child: const MainShell(),
            );
          },
        ),
        GoRoute(
          path: '/more',
          pageBuilder: (context, state) {
            MainShell.switchToTab(4);
            return _buildTransitionPage(
              state: state,
              child: const MainShell(),
            );
          },
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) {
            MainShell.switchToTab(4);
            return _buildTransitionPage(
              state: state,
              child: const MainShell(),
            );
          },
        ),
        GoRoute(
          path: '/settings/server',
          pageBuilder: (context, state) => _buildTransitionPage(
            state: state,
            child: const ServerSettingsScreen(),
          ),
        ),
        GoRoute(
          path: '/settings/library',
          pageBuilder: (context, state) => _buildTransitionPage(
            state: state,
            child: const LibrarySettingsScreen(),
          ),
        ),
        GoRoute(
          path: '/settings/downloads',
          pageBuilder: (context, state) => _buildTransitionPage(
            state: state,
            child: const DownloadsSettingsScreen(),
          ),
        ),
        GoRoute(
          path: '/settings/browse',
          pageBuilder: (context, state) => _buildTransitionPage(
            state: state,
            child: const BrowseSettingsScreen(),
          ),
        ),
        GoRoute(
          path: '/settings/backup',
          pageBuilder: (context, state) => _buildTransitionPage(
            state: state,
            child: const BackupSettingsScreen(),
          ),
        ),
        GoRoute(
          path: '/settings/reader',
          pageBuilder: (context, state) => _buildTransitionPage(
            state: state,
            child: const ReaderSettingsScreen(),
          ),
        ),
        GoRoute(
          path: '/settings/appearance',
          pageBuilder: (context, state) => _buildTransitionPage(
            state: state,
            child: const AppearanceSettingsScreen(),
          ),
        ),
        GoRoute(
          path: '/settings/general',
          pageBuilder: (context, state) => _buildTransitionPage(
            state: state,
            child: const GeneralSettingsScreen(),
          ),
        ),
        GoRoute(
          path: '/settings/advanced',
          pageBuilder: (context, state) => _buildTransitionPage(
            state: state,
            child: const AdvancedSettingsScreen(),
          ),
        ),
        GoRoute(
          path: '/settings/extension-repos',
          pageBuilder: (context, state) => _buildTransitionPage(
            state: state,
            child: const ExtensionReposScreen(),
          ),
        ),
        GoRoute(
          path: '/downloads',
          pageBuilder: (context, state) => _buildTransitionPage(
            state: state,
            child: const DownloadQueueScreen(),
          ),
        ),
        GoRoute(
          path: '/stats',
          pageBuilder: (context, state) => _buildTransitionPage(
            state: state,
            child: const StatsScreen(),
          ),
        ),
        GoRoute(
          path: '/manga/:id',
          pageBuilder: (context, state) {
            final idStr = state.pathParameters['id'] ?? '0';
            final id = int.tryParse(idStr) ?? 0;
            return _buildTransitionPage(
              state: state,
              child: MangaDetailScreen(mangaServerId: id),
            );
          },
        ),
        GoRoute(
          path: '/reader/:id',
          pageBuilder: (context, state) {
            final idStr = state.pathParameters['id'] ?? '0';
            final id = int.tryParse(idStr) ?? 0;
            return _buildTransitionPage(
              state: state,
              child: ReaderScreen(chapterServerId: id),
            );
          },
        ),
      ],
    );
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
          _router.push(initialPayload);
        }
      });
    }

    _notificationSubscription = NotificationService.instance.onNotificationTapped.listen((route) {
      if (route != null && route.isNotEmpty) {
        if (route == '/updates') {
          _router.go('/updates');
        } else {
          _router.push(route);
        }
      }
    });

    try {
      _appLinks = AppLinks();
      _linkSubscription = _appLinks!.uriLinkStream.listen(_handleUri);
      _appLinks!.getInitialLink().then((uri) {
        if (uri != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _handleUri(uri));
        }
      }).catchError((_) {});
    } catch (_) {}
  }

  void _handleUri(Uri uri) {
    if (uri.scheme == 'sunfire') {
      if (uri.host == 'manga' && uri.pathSegments.isNotEmpty) {
        final idStr = uri.pathSegments.first;
        final id = int.tryParse(idStr);
        if (id != null && id > 0) {
          _router.push('/manga/$id');
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
        _router.push('/downloads');
      } else if (uri.host == 'stats') {
        _router.push('/stats');
      }
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    _notificationSubscription?.cancel();
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
            final modeStr = SettingsService.instance.themeMode;
            final isOled = modeStr == 'OLED Black';

            final effectiveDarkTheme = AppTheme.darkTheme(useMaterialYou ? darkDynamic : null);
            final effectiveLightTheme = AppTheme.lightTheme(useMaterialYou ? lightDynamic : null);

            final themeData = isOled
                ? effectiveDarkTheme.copyWith(
                    scaffoldBackgroundColor: Colors.black,
                    canvasColor: Colors.black,
                  )
                : effectiveDarkTheme;

            ThemeMode effectiveMode;
            if (modeStr == 'System Default') {
              effectiveMode = ThemeMode.system;
            } else if (modeStr == 'Light') {
              effectiveMode = ThemeMode.light;
            } else {
              effectiveMode = ThemeMode.dark;
            }

            return MaterialApp.router(
              title: 'Sunfire',
              debugShowCheckedModeBanner: false,
              locale: (SettingsService.instance.appLocale == 'system' || SettingsService.instance.appLocale.isEmpty)
                  ? null
                  : Locale(SettingsService.instance.appLocale),
              themeMode: effectiveMode,
              theme: effectiveLightTheme,
              darkTheme: themeData,
              routerConfig: _router,
              builder: (context, child) {
                final mediaQuery = MediaQuery.of(context);
                final isTablet = mediaQuery.size.width >= 720;
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
    if (route.settings.name != null || route.settings.name == null) {
      LoggerService.instance.logInfo('Navigated to ${route.settings.name ?? route.runtimeType}', 'Navigation');
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (route.settings.name != null || route.settings.name == null) {
      LoggerService.instance.logInfo('Popped from ${route.settings.name ?? route.runtimeType}', 'Navigation');
    }
  }
}
