import 'package:dynamic_color/dynamic_color.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'features/settings/presentation/appearance/widgets/app_theme_selector/app_theme_selector.dart';
import 'features/settings/presentation/appearance/widgets/is_true_black/is_true_black_tile.dart';
import 'features/settings/presentation/appearance/widgets/use_dynamic_color/use_dynamic_color_tile.dart';
import 'features/settings/widgets/app_theme_mode_tile/app_theme_mode_tile.dart';
import 'global_providers/global_providers.dart';
import 'l10n/generated/app_localizations.dart';
import 'routes/router_config.dart';
import 'utils/extensions/custom_extensions.dart';

class CatalystApp extends ConsumerWidget {
  const CatalystApp({super.key});

  ThemeData _applyDynamicColor({
    required ThemeData base,
    required ColorScheme? dynamic,
    required bool isDark,
    required bool isTrueBlack,
  }) {
    if (dynamic == null) return base;

    final harmonized = ColorScheme.fromSeed(
      seedColor: dynamic.primary,
      brightness: isDark ? Brightness.dark : Brightness.light,
    );

    return base.copyWith(
      colorScheme: harmonized,
      scaffoldBackgroundColor:
          isTrueBlack && isDark ? Colors.black : harmonized.surface,
      cardColor: harmonized.surfaceContainerLow,
      canvasColor: harmonized.surface,
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: harmonized.secondaryContainer,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: harmonized.onSecondaryContainer);
          }
          return IconThemeData(color: harmonized.onSurfaceVariant);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: harmonized.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            );
          }
          return TextStyle(color: harmonized.onSurfaceVariant, fontSize: 12);
        }),
        backgroundColor: harmonized.surfaceContainer,
        elevation: 0,
        height: 80,
      ),
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: harmonized.surface,
        foregroundColor: harmonized.onSurface,
        surfaceTintColor: harmonized.surfaceTint,
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        selectedColor: harmonized.secondaryContainer,
        checkmarkColor: harmonized.onSecondaryContainer,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: harmonized.primary,
        unselectedLabelColor: harmonized.onSurfaceVariant,
        indicatorColor: harmonized.primary,
        tabAlignment: TabAlignment.center,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: harmonized.primaryContainer,
        foregroundColor: harmonized.onPrimaryContainer,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routes = ref.watch(routerConfigProvider);
    final themeMode = ref.watch(appThemeModeProvider);
    final appLocale = ref.watch(l10nProvider);
    final appScheme = ref.watch(appSchemeProvider);
    final isTrueBlack = ref.watch(isTrueBlackProvider).ifNull();
    final useDynamic = ref.watch(useDynamicColorProvider).ifNull(true);
    final client = ref.watch(graphQlClientNotifierProvider);

    final baseLight = FlexThemeData.light(
      scheme: appScheme,
      useMaterial3: true,
      useMaterial3ErrorColors: true,
    ).copyWith(
      tabBarTheme: const TabBarThemeData(tabAlignment: TabAlignment.center),
    );

    final baseDark = FlexThemeData.dark(
      scheme: appScheme,
      useMaterial3: true,
      useMaterial3ErrorColors: true,
      darkIsTrueBlack: isTrueBlack,
    ).copyWith(
      tabBarTheme: const TabBarThemeData(tabAlignment: TabAlignment.center),
    );

    return GraphQLProvider(
      client: client,
      child: DynamicColorBuilder(
        builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
          // When toggle is off, pass null so base flex theme is used unchanged
          final lightTheme = _applyDynamicColor(
            base: baseLight,
            dynamic: useDynamic ? lightDynamic : null,
            isDark: false,
            isTrueBlack: false,
          );
          final darkTheme = _applyDynamicColor(
            base: baseDark,
            dynamic: useDynamic ? darkDynamic : null,
            isDark: true,
            isTrueBlack: isTrueBlack,
          );

          return MaterialApp.router(
            builder: FToastBuilder(),
            onGenerateTitle: (context) => context.l10n.appTitle,
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeMode ?? ThemeMode.system,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: appLocale,
            routerConfig: routes,
          );
        },
      ),
    );
  }
}
