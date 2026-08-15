import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/settings_service.dart';

class AppTheme {
  static const Color oledBackground = Color(0xFF0A0A0C);
  static const Color glassSurface = Color(0x1F2A2A32);
  static const Color glassBorder = Color(0x2BFFFFFF);

  static ThemeData darkTheme([ColorScheme? dynamicColorScheme]) {
    final seedColor = SettingsService.instance.accentColor;

    final baseColorScheme = dynamicColorScheme ?? ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
      surface: oledBackground,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: baseColorScheme.primary,
      colorScheme: baseColorScheme.copyWith(
        surface: oledBackground,
        primary: baseColorScheme.primary,
      ),
      scaffoldBackgroundColor: oledBackground,
      textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme),
      cardTheme: CardThemeData(
        color: glassSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: glassBorder, width: 0.8),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
    );
  }
}
