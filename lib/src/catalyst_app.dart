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
import 'theme/catalyst_component_themes.dart';
import 'theme/catalyst_custom_schemes.dart';
import 'utils/extensions/custom_extensions.dart';
import 'utils/platform/deep_link_listener.dart';
import 'utils/platform/system_ui_style.dart';

class CatalystApp extends ConsumerWidget {
  const CatalystApp({super.key});

  ThemeData _buildTheme({
    required ThemeData base,
    required ColorScheme? dynamicScheme,
    required bool isTrueBlack,
  }) {
    return buildCatalystTheme(
      base: base,
      scheme: dynamicScheme ?? base.colorScheme,
      isTrueBlack: isTrueBlack,
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
          final lightTheme = _buildTheme(
            base: baseLight,
            dynamicScheme: useDynamic ? lightDynamic : null,
            isTrueBlack: false,
          );
          final darkTheme = _buildTheme(
            base: baseDark,
            dynamicScheme: useDynamic ? darkDynamic : null,
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
