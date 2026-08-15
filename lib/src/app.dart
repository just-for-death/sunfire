import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/services/settings_service.dart';
import 'core/theme/app_theme.dart';
import 'features/downloads/download_queue_screen.dart';
import 'features/manga_detail/manga_detail_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/reader/reader_screen.dart';
import 'features/stats/stats_screen.dart';
import 'main_shell.dart';

class SunfireApp extends StatelessWidget {
  const SunfireApp({super.key});

  static final GoRouter _router = GoRouter(
    initialLocation: SettingsService.instance.onboardingCompleted ? '/library' : '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/library',
        builder: (context, state) => const MainShell(),
      ),
      GoRoute(
        path: '/downloads',
        builder: (context, state) => const DownloadQueueScreen(),
      ),
      GoRoute(
        path: '/stats',
        builder: (context, state) => const StatsScreen(),
      ),
      GoRoute(
        path: '/manga/:id',
        builder: (context, state) {
          final idStr = state.pathParameters['id'] ?? '0';
          final id = int.tryParse(idStr) ?? 0;
          return MangaDetailScreen(mangaServerId: id);
        },
      ),
      GoRoute(
        path: '/reader/:id',
        builder: (context, state) {
          final idStr = state.pathParameters['id'] ?? '0';
          final id = int.tryParse(idStr) ?? 0;
          return ReaderScreen(chapterServerId: id);
        },
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SettingsService.instance,
      builder: (context, child) {
        return DynamicColorBuilder(
          builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
            final useMaterialYou = SettingsService.instance.materialYouEnabled;
            final isOled = SettingsService.instance.themeMode == 'OLED Black';

            final effectiveDarkTheme = AppTheme.darkTheme(useMaterialYou ? darkDynamic : null);

            final themeData = isOled
                ? effectiveDarkTheme.copyWith(
                    scaffoldBackgroundColor: Colors.black,
                    canvasColor: Colors.black,
                  )
                : effectiveDarkTheme;

            return MaterialApp.router(
              title: 'Sunfire',
              debugShowCheckedModeBanner: false,
              themeMode: ThemeMode.dark,
              darkTheme: themeData,
              routerConfig: _router,
            );
          },
        );
      },
    );
  }
}
