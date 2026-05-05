import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

/// All Komikku‑inspired custom FlexSchemeColor palettes.
/// Each key in [allSchemes] provides a unique name; the value is a record
/// of (light, dark) FlexSchemeColor objects.
///
/// [lightSchemes] and [darkSchemes] are the flat maps used by the UI picker
/// and by CatalystApp to build the theme.
class KomikkuCustomSchemes {
  KomikkuCustomSchemes._();

  // ─── Catppuccin ──────────────────────────────────────────────────────────
  static const FlexSchemeColor catppuccinLight = FlexSchemeColor(
    primary: Color(0xFF8839EF),
    primaryContainer: Color(0xFFE6CCFD),
    secondary: Color(0xFF04A5E5),
    secondaryContainer: Color(0xFFCDD0DA),
    tertiary: Color(0xFF40A02B),
    tertiaryContainer: Color(0xFFEFF1F5),
  );
  static const FlexSchemeColor catppuccinDark = FlexSchemeColor(
    primary: Color(0xFFCBA6F7),
    primaryContainer: Color(0xFF45475A),
    secondary: Color(0xFF89DCEB),
    secondaryContainer: Color(0xFF313244),
    tertiary: Color(0xFFA6E3A1),
    tertiaryContainer: Color(0xFF1E1E2E),
  );

  // ─── Nord ─────────────────────────────────────────────────────────────────
  static const FlexSchemeColor nordLight = FlexSchemeColor(
    primary: Color(0xFF5E81AC),
    primaryContainer: Color(0xFFD8DEE9),
    secondary: Color(0xFF81A1C1),
    secondaryContainer: Color(0xFFE5E9F0),
    tertiary: Color(0xFF88C0D0),
    tertiaryContainer: Color(0xFFECEFF4),
  );
  static const FlexSchemeColor nordDark = FlexSchemeColor(
    primary: Color(0xFF88C0D0),
    primaryContainer: Color(0xFF3B4252),
    secondary: Color(0xFF81A1C1),
    secondaryContainer: Color(0xFF434C5E),
    tertiary: Color(0xFF5E81AC),
    tertiaryContainer: Color(0xFF2E3440),
  );

  // ─── Cloudflare ──────────────────────────────────────────────────────────
  static const FlexSchemeColor cloudflareLight = FlexSchemeColor(
    primary: Color(0xFFF38020),
    primaryContainer: Color(0xFFF38020),
    secondary: Color(0xFFF38020),
    secondaryContainer: Color(0xFFEFF2F5),
    tertiary: Color(0xFFEFF2F5),
    tertiaryContainer: Color(0xFFEFF2F5),
  );
  static const FlexSchemeColor cloudflareDark = FlexSchemeColor(
    primary: Color(0xFFF38020),
    primaryContainer: Color(0xFF3F3F46),
    secondary: Color(0xFFF38020),
    secondaryContainer: Color(0xFF1B1B22),
    tertiary: Color(0xFF1B1B22),
    tertiaryContainer: Color(0xFF1B1B22),
  );

  // ─── Cottoncandy ─────────────────────────────────────────────────────────
  static const FlexSchemeColor cottoncandyLight = FlexSchemeColor(
    primary: Color(0xFF8F4A4C),
    primaryContainer: Color(0xFFFFDAD9),
    secondary: Color(0xFF00696D),
    secondaryContainer: Color(0xFF9CF1F4),
    tertiary: Color(0xFF7B4E7F),
    tertiaryContainer: Color(0xFFFFD6FE),
  );
  static const FlexSchemeColor cottoncandyDark = FlexSchemeColor(
    primary: Color(0xFFFFB3B4),
    primaryContainer: Color(0xFF733336),
    secondary: Color(0xFF80D4D8),
    secondaryContainer: Color(0xFF004F52),
    tertiary: Color(0xFFEBB5ED),
    tertiaryContainer: Color(0xFF613766),
  );

  // ─── Midnight Dusk ───────────────────────────────────────────────────────
  static const FlexSchemeColor midnightDuskLight = FlexSchemeColor(
    primary: Color(0xFFBB0054),
    primaryContainer: Color(0xFFFFD9E1),
    secondary: Color(0xFFBB0054),
    secondaryContainer: Color(0xFFEFBAD4),
    tertiary: Color(0xFF006638),
    tertiaryContainer: Color(0xFF00894B),
  );
  static const FlexSchemeColor midnightDuskDark = FlexSchemeColor(
    primary: Color(0xFFF02475),
    primaryContainer: Color(0xFFBD1C5C),
    secondary: Color(0xFFF02475),
    secondaryContainer: Color(0xFF66183C),
    tertiary: Color(0xFF55971C),
    tertiaryContainer: Color(0xFF386412),
  );

  // ─── Green Apple ─────────────────────────────────────────────────────────
  static const FlexSchemeColor greenAppleLight = FlexSchemeColor(
    primary: Color(0xFF005927),
    primaryContainer: Color(0xFF188140),
    secondary: Color(0xFF005927),
    secondaryContainer: Color(0xFF97F7A9),
    tertiary: Color(0xFF9D0012),
    tertiaryContainer: Color(0xFFD33131),
  );
  static const FlexSchemeColor greenAppleDark = FlexSchemeColor(
    primary: Color(0xFF7ADB8F),
    primaryContainer: Color(0xFF017737),
    secondary: Color(0xFF7ADB8F),
    secondaryContainer: Color(0xFF017737),
    tertiary: Color(0xFFFFB3AC),
    tertiaryContainer: Color(0xFFC7282A),
  );

  // ─── Strawberry Daiquiri ─────────────────────────────────────────────────
  static const FlexSchemeColor strawberryLight = FlexSchemeColor(
    primary: Color(0xFFA10833),
    primaryContainer: Color(0xFFD53855),
    secondary: Color(0xFFA10833),
    secondaryContainer: Color(0xFFD53855),
    tertiary: Color(0xFF5F441D),
    tertiaryContainer: Color(0xFF87683D),
  );
  static const FlexSchemeColor strawberryDark = FlexSchemeColor(
    primary: Color(0xFFFFB2B8),
    primaryContainer: Color(0xFFD53855),
    secondary: Color(0xFFED4A65),
    secondaryContainer: Color(0xFF91002A),
    tertiary: Color(0xFFE8C08E),
    tertiaryContainer: Color(0xFF775930),
  );

  // ─── Tachiyomi ───────────────────────────────────────────────────────────
  static const FlexSchemeColor tachiyomiLight = FlexSchemeColor(
    primary: Color(0xFF4378D2),
    primaryContainer: Color(0xFFD9E2FF),
    secondary: Color(0xFF1976D2),
    secondaryContainer: Color(0xFFBBDEFB),
    tertiary: Color(0xFF7C4DFF),
    tertiaryContainer: Color(0xFFEDE7F6),
  );
  static const FlexSchemeColor tachiyomiDark = FlexSchemeColor(
    primary: Color(0xFF82AAFF),
    primaryContainer: Color(0xFF1B3362),
    secondary: Color(0xFF64B5F6),
    secondaryContainer: Color(0xFF0D47A1),
    tertiary: Color(0xFFB39DDB),
    tertiaryContainer: Color(0xFF311B92),
  );

  // ─── TealTurquoise ───────────────────────────────────────────────────────
  static const FlexSchemeColor tealTurquoiseLight = FlexSchemeColor(
    primary: Color(0xFF007D72),
    primaryContainer: Color(0xFFA7F3EB),
    secondary: Color(0xFF00867A),
    secondaryContainer: Color(0xFFB2EBE5),
    tertiary: Color(0xFF4A6741),
    tertiaryContainer: Color(0xFFCBEDBD),
  );
  static const FlexSchemeColor tealTurquoiseDark = FlexSchemeColor(
    primary: Color(0xFF4EDDD0),
    primaryContainer: Color(0xFF005048),
    secondary: Color(0xFF4EDDD0),
    secondaryContainer: Color(0xFF00504A),
    tertiary: Color(0xFFB0D0A2),
    tertiaryContainer: Color(0xFF344F2C),
  );

  // ─── Yotsuba ─────────────────────────────────────────────────────────────
  static const FlexSchemeColor yotsubaLight = FlexSchemeColor(
    primary: Color(0xFFD83823),
    primaryContainer: Color(0xFFFFDAD4),
    secondary: Color(0xFFD83823),
    secondaryContainer: Color(0xFFFFDAD4),
    tertiary: Color(0xFF795830),
    tertiaryContainer: Color(0xFFFFDDB5),
  );
  static const FlexSchemeColor yotsubaDark = FlexSchemeColor(
    primary: Color(0xFFFFB4A8),
    primaryContainer: Color(0xFFBF1A07),
    secondary: Color(0xFFFFB4A8),
    secondaryContainer: Color(0xFFBF1A07),
    tertiary: Color(0xFFEEC07A),
    tertiaryContainer: Color(0xFF5E421C),
  );

  // ─── YinYang ─────────────────────────────────────────────────────────────
  static const FlexSchemeColor yinYangLight = FlexSchemeColor(
    primary: Color(0xFF000000),
    primaryContainer: Color(0xFFE0E0E0),
    secondary: Color(0xFF212121),
    secondaryContainer: Color(0xFFEEEEEE),
    tertiary: Color(0xFF424242),
    tertiaryContainer: Color(0xFFF5F5F5),
  );
  static const FlexSchemeColor yinYangDark = FlexSchemeColor(
    primary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFF212121),
    secondary: Color(0xFFE0E0E0),
    secondaryContainer: Color(0xFF303030),
    tertiary: Color(0xFFBDBDBD),
    tertiaryContainer: Color(0xFF121212),
  );

  // ─── Lavender ────────────────────────────────────────────────────────────
  static const FlexSchemeColor lavenderLight = FlexSchemeColor(
    primary: Color(0xFF7C4DFF),
    primaryContainer: Color(0xFFEDE7F6),
    secondary: Color(0xFF9575CD),
    secondaryContainer: Color(0xFFEDE7F6),
    tertiary: Color(0xFF5E35B1),
    tertiaryContainer: Color(0xFFD1C4E9),
  );
  static const FlexSchemeColor lavenderDark = FlexSchemeColor(
    primary: Color(0xFFB39DDB),
    primaryContainer: Color(0xFF4527A0),
    secondary: Color(0xFF9575CD),
    secondaryContainer: Color(0xFF311B92),
    tertiary: Color(0xFFCE93D8),
    tertiaryContainer: Color(0xFF6A1B9A),
  );

  // ─── Monochrome ──────────────────────────────────────────────────────────
  static const FlexSchemeColor monochromeLight = FlexSchemeColor(
    primary: Color(0xFF424242),
    primaryContainer: Color(0xFFBDBDBD),
    secondary: Color(0xFF616161),
    secondaryContainer: Color(0xFFE0E0E0),
    tertiary: Color(0xFF212121),
    tertiaryContainer: Color(0xFFEEEEEE),
  );
  static const FlexSchemeColor monochromeDark = FlexSchemeColor(
    primary: Color(0xFFE0E0E0),
    primaryContainer: Color(0xFF424242),
    secondary: Color(0xFFBDBDBD),
    secondaryContainer: Color(0xFF616161),
    tertiary: Color(0xFF9E9E9E),
    tertiaryContainer: Color(0xFF212121),
  );

  // ─── Maps ────────────────────────────────────────────────────────────────

  /// All light scheme colors keyed by display name.
  static const Map<String, FlexSchemeColor> lightSchemes = {
    'Catppuccin': catppuccinLight,
    'Nord': nordLight,
    'Cloudflare': cloudflareLight,
    'Cottoncandy': cottoncandyLight,
    'Midnight Dusk': midnightDuskLight,
    'Green Apple': greenAppleLight,
    'Strawberry': strawberryLight,
    'Tachiyomi': tachiyomiLight,
    'Teal Turquoise': tealTurquoiseLight,
    'Yotsuba': yotsubaLight,
    'Yin & Yang': yinYangLight,
    'Lavender': lavenderLight,
    'Monochrome': monochromeLight,
  };

  /// All dark scheme colors keyed by display name (same keys as [lightSchemes]).
  static const Map<String, FlexSchemeColor> darkSchemes = {
    'Catppuccin': catppuccinDark,
    'Nord': nordDark,
    'Cloudflare': cloudflareDark,
    'Cottoncandy': cottoncandyDark,
    'Midnight Dusk': midnightDuskDark,
    'Green Apple': greenAppleDark,
    'Strawberry': strawberryDark,
    'Tachiyomi': tachiyomiDark,
    'Teal Turquoise': tealTurquoiseDark,
    'Yotsuba': yotsubaDark,
    'Yin & Yang': yinYangDark,
    'Lavender': lavenderDark,
    'Monochrome': monochromeDark,
  };
}
