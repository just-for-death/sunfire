import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/logging/logger_service.dart';
import 'core/services/settings_service.dart';
import 'core/theme/app_theme.dart';
import 'features/downloads/download_queue_screen.dart';
import 'features/manga_detail/manga_detail_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/reader/reader_screen.dart';
import 'features/stats/stats_screen.dart';
import 'main_shell.dart';

class SunfireApp extends StatefulWidget {
  const SunfireApp({super.key});

  @override
  State<SunfireApp> createState() => _SunfireAppState();
}

class _SunfireAppState extends State<SunfireApp> {
  late final GoRouter _router;

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
          pageBuilder: (context, state) => _buildTransitionPage(
            state: state,
            child: const MainShell(),
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
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SettingsService.instance,
      builder: (context, child) {
        return DynamicColorBuilder(
          builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
            final useMaterialYou = SettingsService.instance.materialYouEnabled;
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
              themeMode: effectiveMode,
              theme: effectiveLightTheme,
              darkTheme: themeData,
              routerConfig: _router,
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
