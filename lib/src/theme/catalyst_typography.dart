import 'package:flutter/material.dart';

/// Material 3 type scale.
///
/// Declared explicitly so every theme path (Flex palettes, custom palettes and
/// Android dynamic color) renders identical text metrics.
class CatalystTypography {
  CatalystTypography._();

  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 57,
      height: 64 / 57,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25,
    ),
    displayMedium: TextStyle(
      fontSize: 45,
      height: 52 / 45,
      fontWeight: FontWeight.w400,
    ),
    displaySmall: TextStyle(
      fontSize: 36,
      height: 44 / 36,
      fontWeight: FontWeight.w400,
    ),
    headlineLarge: TextStyle(
      fontSize: 32,
      height: 40 / 32,
      fontWeight: FontWeight.w400,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      height: 36 / 28,
      fontWeight: FontWeight.w400,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      height: 32 / 24,
      fontWeight: FontWeight.w400,
    ),
    titleLarge: TextStyle(
      fontSize: 22,
      height: 28 / 22,
      fontWeight: FontWeight.w400,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      height: 24 / 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      height: 20 / 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      height: 24 / 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      height: 20 / 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      height: 16 / 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      height: 20 / 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      height: 16 / 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      height: 16 / 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
  );

  /// Cover captions sit in a fixed two-line box, so they run tighter than
  /// [TextTheme.titleSmall].
  static const TextStyle coverTitle = TextStyle(
    fontSize: 12,
    height: 14 / 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.00714286,
  );
}
