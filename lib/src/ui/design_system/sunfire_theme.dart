/// Central theme management for Sunfire.
/// Uses standard Material 3 ThemeData (no Flex dependency required).
library;

import 'package:flutter/material.dart';

import '../../core/services/settings_service.dart';
import 'tokens/sunfire_colors.dart';
import 'tokens/sunfire_typography.dart';

/// Central theme management for Sunfire.
class SunfireTheme {
  SunfireTheme._();

  /// Accent color from settings
  static Color get accentColor => SettingsService.instance.accentColor;

  /// Whether Pure black (AMOLED) is on. A separate toggle from the theme
  /// mode since UIS-P2-C; only the dark theme is affected.
  static bool get isOledMode => SettingsService.instance.pureBlackEnabled;

  /// Theme-mode picker options (UIS-P2-C). Pure black is its own switch, so
  /// the legacy 'OLED Black' mode is no longer offered (still read as dark).
  static const List<String> themeModeOptions = [
    'Dark Theme',
    'Light',
    'System Default',
  ];

  /// Display label for a stored theme mode ('OLED Black' → 'Dark Theme').
  static String themeModeLabel(String stored) =>
      stored == 'OLED Black' ? 'Dark Theme' : stored;

  // ── Glass tokens (UIS-P3-1: merged in from the removed AppTheme) ─────────
  // SunfireTheme is the single app theme. The dark-only glass constants that
  // used to live in the old core/theme AppTheme class are kept here; screens should
  // call the brightness-aware helpers below instead of the raw constants.

  /// Dark glass tile/chip fill (formerly AppTheme glassSurface).
  static const Color glassSurface = Color(0x1F2A2A32);

  /// Dark glass tile/chip border (formerly AppTheme glassBorder).
  static const Color glassBorder = Color(0x2BFFFFFF);

  /// Dark hairline divider / resting tile outline.
  static const Color glassHairline = Color(0x1AFFFFFF);

  /// Dark translucent overlay fill (secondary buttons, progress tracks).
  static const Color glassOverlay = Color(0x33FFFFFF);

  static bool _isLight(BuildContext context) =>
      Theme.of(context).colorScheme.brightness == Brightness.light;

  /// Translucent glass tile/chip fill. Dark keeps the original 0x1F2A2A32;
  /// Light uses a scheme surface so tiles stay visible (ISS-018).
  static Color tileSurface(BuildContext context) => _isLight(context)
      ? Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.7)
      : glassSurface;

  /// Hairline border for glass tiles/chips. Dark keeps 0x2BFFFFFF.
  static Color tileBorder(BuildContext context) => _isLight(context)
      ? Theme.of(context).colorScheme.outlineVariant
      : glassBorder;

  /// Divider / resting outline. Dark keeps 0x1AFFFFFF; Light uses
  /// `outlineVariant` (ISS-047).
  static Color hairline(BuildContext context) => _isLight(context)
      ? Theme.of(context).colorScheme.outlineVariant
      : glassHairline;

  /// Translucent overlay fill. Dark keeps 0x33FFFFFF (white 20%); Light uses
  /// `onSurface` at 8% so it reads as a tint, not invisible white (ISS-047).
  static Color overlayFill(BuildContext context) => _isLight(context)
      ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08)
      : glassOverlay;

  static ThemeMode get effectiveThemeMode =>
      themeModeFor(SettingsService.instance.themeMode);

  /// Maps the stored theme setting to a [ThemeMode] (UIS-23 revised, Jane
  /// 2026-10-06: Light is supported). 'Light' → light, 'System Default' →
  /// follow the device, everything else ('Dark Theme', 'OLED Black', legacy
  /// values) → dark. OLED is applied separately via [isOledMode].
  static ThemeMode themeModeFor(String mode) {
    switch (mode) {
      case 'Light':
        return ThemeMode.light;
      case 'System Default':
        return ThemeMode.system;
      default:
        return ThemeMode.dark;
    }
  }

  /// Builds the light theme
  static ThemeData buildLightTheme({ColorScheme? dynamicScheme}) {
    final scheme = _resolveScheme(dynamicScheme, Brightness.light);
    return _applySunfireCustomizations(
      ThemeData(useMaterial3: true, colorScheme: scheme),
      isDark: false,
      isDynamic: dynamicScheme != null,
      accent: scheme.primary,
    );
  }

  /// Builds the dark theme
  static ThemeData buildDarkTheme({ColorScheme? dynamicScheme, bool isOled = false}) {
    final scheme = _resolveScheme(dynamicScheme, Brightness.dark);
    var theme = _applySunfireCustomizations(
      ThemeData(useMaterial3: true, colorScheme: scheme),
      isDark: true,
      isDynamic: dynamicScheme != null,
      accent: scheme.primary,
    );
    if (isOled) theme = applyPureBlack(theme);
    return theme;
  }

  /// Pure black / AMOLED (UIS-P2-C, Mihon #1011). Background, surface and
  /// the surface containers behind app bars, nav bars, rails and cards are
  /// #000 with no surface tint, so nothing reads as a tinted grey bar. The
  /// two highest containers (menus, dialogs, fields) use neutral near-black
  /// so they stay distinguishable. `primary` (accent or Material You) is
  /// never touched.
  static ThemeData applyPureBlack(ThemeData theme) {
    const black = SunfireColors.oledBlack;
    final cs = theme.colorScheme.copyWith(
      surface: black,
      surfaceDim: black,
      surfaceContainerLowest: black,
      surfaceContainerLow: black,
      surfaceContainer: black,
      surfaceContainerHigh: SunfireColors.oledSurface2,
      surfaceContainerHighest: SunfireColors.oledSurface3,
      surfaceTint: Colors.transparent,
    );
    return theme.copyWith(
      colorScheme: cs,
      scaffoldBackgroundColor: black,
      canvasColor: black,
      cardTheme: theme.cardTheme.copyWith(color: black),
      navigationBarTheme:
          theme.navigationBarTheme.copyWith(backgroundColor: black),
      navigationRailTheme:
          theme.navigationRailTheme.copyWith(backgroundColor: black),
      appBarTheme: theme.appBarTheme.copyWith(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent),
    );
  }

  /// Material You on (dynamicScheme != null): keep the wallpaper scheme
  /// untouched, including `primary`. Material You off: seed from the brand
  /// accent and use the exact accent as `primary`, with an `onPrimary`
  /// picked for contrast (black or white, whichever is higher; always
  /// ≥ 4.5:1).
  static ColorScheme _resolveScheme(
      ColorScheme? dynamicScheme, Brightness brightness) {
    if (dynamicScheme != null) return dynamicScheme;
    final accent = accentColor;
    return ColorScheme.fromSeed(seedColor: accent, brightness: brightness)
        .copyWith(primary: accent, onPrimary: onColorFor(accent));
  }

  /// Black or white, whichever has the higher WCAG contrast against [color].
  static Color onColorFor(Color color) {
    final l = color.computeLuminance();
    final vsWhite = 1.05 / (l + 0.05);
    final vsBlack = (l + 0.05) / 0.05;
    return vsWhite >= vsBlack ? Colors.white : Colors.black;
  }

  /// Applies Sunfire-specific customizations on top of base theme.
  /// [accent] is the resolved `colorScheme.primary`; it is never written
  /// back over the scheme's primary. With [isDynamic] (Material You) the
  /// wallpaper scheme's own tonal surfaces are kept instead of the Sunfire
  /// brand surface ladder (UIS-P2-C), and all chrome reads scheme roles.
  static ThemeData _applySunfireCustomizations(ThemeData base,
      {required bool isDark, required Color accent, bool isDynamic = false}) {
    final scheme = isDynamic
        ? base.colorScheme
        : base.colorScheme.copyWith(
            surface: isDark ? SunfireColors.surface1 : Colors.white,
            surfaceContainerLow:
                isDark ? const Color(0xFF1A1A1F) : const Color(0xFFF5F5F5),
            surfaceContainerHigh:
                isDark ? SunfireColors.surface3 : const Color(0xFFE8E8E8),
            surfaceContainerHighest:
                isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE8E8E8),
          );
    final background = isDynamic
        ? scheme.surface
        : (isDark ? SunfireColors.surface0 : Colors.white);

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      canvasColor: scheme.surface,
      cardTheme: CardThemeData(
        color: isDynamic ? scheme.surfaceContainerLow : scheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark
                ? SunfireColors.borderSubtle
                : const Color(0x1F000000),
            width: 0.8,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        centerTitle: false,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? glassSurface : const Color(0x0D000000),
        disabledColor: isDark
            ? glassSurface.withValues(alpha: 0.5)
            : const Color(0x0D000000).withValues(alpha: 0.5),
        selectedColor: accent.withValues(alpha: isDark ? 0.25 : 0.15),
        secondarySelectedColor: accent,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isDark
                ? SunfireColors.borderSubtle
                : const Color(0x1F000000),
            width: 0.8,
          ),
        ),
        labelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : Colors.black87),
        secondaryLabelStyle: TextStyle(
            fontSize: 12, fontWeight: FontWeight.bold, color: accent),
        brightness: isDark ? Brightness.dark : Brightness.light,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: accent,
        unselectedLabelColor: Colors.grey,
        indicatorColor: accent,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        labelStyle: SunfireTypography.labelLarge,
        unselectedLabelStyle:
            SunfireTypography.labelLarge.copyWith(color: Colors.grey),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDynamic
            ? scheme.surfaceContainer
            : (isDark ? SunfireColors.surface2 : scheme.surface),
        indicatorColor: accent.withValues(alpha: 0.12),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 80,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: scheme.onPrimary,
        elevation: 2,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor:
            isDark ? scheme.surfaceContainerHighest : scheme.inverseSurface,
        contentTextStyle: TextStyle(
            color: isDark ? scheme.onSurface : scheme.onInverseSurface),
        actionTextColor: accent,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        showDragHandle: true,
      ),
      dialogTheme: const DialogThemeData(
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(28)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: isDark
            ? const Color(0x1FFFFFFF)
            : const Color(0x1F000000),
        thickness: 0.8,
      ),
    );
  }
}
