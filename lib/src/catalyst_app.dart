import 'package:dynamic_color/dynamic_color.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'features/notifications/notification_providers.dart';
import 'features/settings/presentation/appearance/widgets/app_theme_selector/app_theme_selector.dart';
import 'features/settings/presentation/appearance/widgets/app_theme_selector/custom_scheme_provider.dart';
import 'features/settings/presentation/appearance/widgets/is_true_black/is_true_black_tile.dart';
import 'features/settings/presentation/appearance/widgets/use_dynamic_color/use_dynamic_color_tile.dart';
import 'features/settings/widgets/app_theme_mode_tile/app_theme_mode_tile.dart';
import 'global_providers/global_providers.dart';
import 'l10n/generated/app_localizations.dart';
import 'routes/router_config.dart';
import 'theme/catalyst_custom_schemes.dart';
import 'theme/catalyst_ui_tokens.dart';
import 'utils/extensions/custom_extensions.dart';
import 'utils/platform/deep_link_listener.dart';
import 'utils/platform/system_ui_style.dart';

class CatalystApp extends ConsumerWidget {
  const CatalystApp({super.key});

  ThemeData _applyDynamicColor({
    required ThemeData base,
    required ColorScheme? dynamic,
    required bool isDark,
    required bool isTrueBlack,
  }) {
    if (dynamic == null) return base;

    final scheme = dynamic;

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor:
          isTrueBlack && isDark ? Colors.black : scheme.surface,
      cardColor: scheme.surfaceContainerLow,
      canvasColor: scheme.surface,
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: scheme.secondaryContainer,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: scheme.onSecondaryContainer);
          }
          return IconThemeData(color: scheme.onSurfaceVariant);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: scheme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            );
          }
          return TextStyle(color: scheme.onSurfaceVariant, fontSize: 12);
        }),
        backgroundColor: scheme.surfaceContainer,
        elevation: 0,
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      ),
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: scheme.surfaceTint,
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        selectedColor: scheme.secondaryContainer,
        checkmarkColor: scheme.onSecondaryContainer,
        shape: RoundedRectangleBorder(borderRadius: CatalystUiTokens.chipRadius),
        side: BorderSide.none,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: scheme.primary,
        unselectedLabelColor: scheme.onSurfaceVariant,
        indicatorColor: scheme.primary,
        tabAlignment: TabAlignment.center,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primaryContainer,
        foregroundColor: scheme.onPrimaryContainer,
      ),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(borderRadius: CatalystUiTokens.cardRadius),
        elevation: 0,
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

    // Eagerly warm up notification providers so they start listening immediately.
    ref.watch(chapterUpdateNotifierProvider);
    ref.watch(extensionUpdateNotifierProvider);

    final customSchemeName = ref.watch(customFlexSchemeProvider);
    final baseLight = customSchemeName != null && CatalystCustomSchemes.lightSchemes.containsKey(customSchemeName)
        ? FlexThemeData.light(
            colors: CatalystCustomSchemes.lightSchemes[customSchemeName]!,
            useMaterial3: true,
            useMaterial3ErrorColors: true,
          )
        : FlexThemeData.light(
            scheme: appScheme,
            useMaterial3: true,
            useMaterial3ErrorColors: true,
          ).copyWith(
            tabBarTheme: const TabBarThemeData(tabAlignment: TabAlignment.center),
          );

    final baseDark = customSchemeName != null && CatalystCustomSchemes.darkSchemes.containsKey(customSchemeName)
        ? FlexThemeData.dark(
            colors: CatalystCustomSchemes.darkSchemes[customSchemeName]!,
            useMaterial3: true,
            useMaterial3ErrorColors: true,
            darkIsTrueBlack: isTrueBlack,
          )
        : FlexThemeData.dark(
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
            builder: (context, child) {
              final brightness = Theme.of(context).brightness;
              return DeepLinkListener(
                child: AnnotatedRegion<SystemUiOverlayStyle>(
                  value: SystemUiStyle.forBrightness(brightness),
                  child: FToastBuilder()(context, child),
                ),
              );
            },
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
