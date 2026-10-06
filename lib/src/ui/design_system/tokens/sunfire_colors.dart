/// Sunfire color tokens - adapts Catalyst's color system for Sunfire's manga reader.
/// Uses FlexColorScheme compatible seeds with OLED/True Black support.
library;

import 'package:flutter/material.dart';

import '../../../core/services/settings_service.dart';

/// Semantic color tokens for Sunfire manga reader.
/// Adapts Catalyst's FlexColorScheme-based system for manga reading.
class SunfireColors {
  SunfireColors._();

  // ── Semantic Surface Hierarchy ──────────────────────────────────────────────
  // Dark theme base (light theme inverts)
  static const Color surface0 = Color(0xFF0A0A0C); // OLED background / scaffold
  static const Color surface1 = Color(0xFF16161E); // Cards, bottom sheets, dialogs
  static const Color surface2 = Color(0xFF1F1F24); // Elevated sheets, hovered cards
  static const Color surface3 = Color(0xFF23232A); // Pressed / active states

  // Light theme surfaces
  static const Color surface0Light = Color(0xFFF8F9FA);
  static const Color surface1Light = Color(0xFFFFFFFF);
  static const Color surface2Light = Color(0xFFF0F1F3);
  static const Color surface3Light = Color(0xFFE8EAED);

  // ── Border Hierarchy ──────────────────────────────────────────────────────
  static const Color borderHairline = Color(0x0DFFFFFF);   // 5%
  static const Color borderSubtle = Color(0x1FFFFFFF);     // 12%
  static const Color borderDefault = Color(0x2BFFFFFF);    // 17%
  static const Color borderStrong = Color(0x40FFFFFF);     // 25%

  static const Color borderHairlineLight = Color(0x0D000000);  // 5%
  static const Color borderSubtleLight = Color(0x1F000000);    // 12%
  static const Color borderDefaultLight = Color(0x2B000000);   // 17%
  static const Color borderStrongLight = Color(0x40000000);    // 25%

  // ── Content Hierarchy ──────────────────────────────────────────────────────
  static const Color contentPrimary = Colors.white;
  static const Color contentSecondary = Color(0xB3FFFFFF); // 70%
  static const Color contentTertiary = Color(0x80FFFFFF);  // 50%
  static const Color contentDisabled = Color(0x4DFFFFFF);  // 30%
  static const Color contentInverse = Color(0xFF0F0F13);   // On accent

  static const Color contentPrimaryLight = Colors.black;
  static const Color contentSecondaryLight = Color(0xB3000000); // 70%
  static const Color contentTertiaryLight = Color(0x80000000);  // 50%
  static const Color contentDisabledLight = Color(0x4D000000);  // 30%
  static const Color contentInverseLight = Color(0xFFFFFFFF);   // On accent

  // ── Semantic Colors (fixed, not themed) ────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color successContainer = Color(0x1A10B981);
  static const Color successContent = Color(0xFF10B981);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningContainer = Color(0x1AF59E0B);
  static const Color warningContent = Color(0xFFF59E0B);

  static const Color error = Color(0xFFEF4444);
  static const Color errorContainer = Color(0x1AEF4444);
  static const Color errorContent = Color(0xFFEF4444);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoContainer = Color(0x1A3B82F6);
  static const Color infoContent = Color(0xFF3B82F6);

  // ── Accent (dynamic from SettingsService) ──────────────────────────────────
  static Color accent(BuildContext context) =>
      SettingsService.instance.accentColor;

  static Color accentOf(BuildContext context) =>
      SettingsService.instance.accentColor;

  static Color accentContainer(BuildContext context) =>
      SettingsService.instance.accentColor.withValues(alpha: 0.12);

  static Color accentContent(BuildContext context) =>
      SettingsService.instance.accentColor.computeLuminance() > 0.5
          ? Colors.black
          : Colors.white;

  // ── Status-specific Badges ────────────────────────────────────────────────
  static const Color unreadDot = Color(0xFFFF5722);       // Sunfire Orange
  static const Color downloadedBadge = Color(0xFF10B981); // Emerald
  static const Color bookmarkStar = Color(0xFFF59E0B);    // Amber
  static const Color languageBadge = Color(0xFF7AA2F7);   // Catppuccin Blue

  // ── Source Type Badges ────────────────────────────────────────────────────
  static const Color localJsBadge = Color(0xFF00BFA6);    // Teal
  static const Color serverBadge = Color(0xFF3B82F6);     // Blue
  static const Color pinnedBadge = Color(0xFFF59E0B);     // Amber

  // ── OLED / Pure Black Variant ─────────────────────────────────────────────
  static const Color oledBlack = Color(0xFF000000);
  static const Color oledSurface1 = Color(0xFF0A0A0A);
  static const Color oledSurface2 = Color(0xFF111111);
  static const Color oledSurface3 = Color(0xFF1A1A1A);

  // ── Helper: Resolve surface for current theme mode ────────────────────────
  static Color surfaceFor(BuildContext context, int level) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;
    final isOled =
        SettingsService.instance.pureBlackEnabled && isDark;

    if (isOled) {
      switch (level) {
        case 0: return oledBlack;
        case 1: return oledSurface1;
        case 2: return oledSurface2;
        case 3: return oledSurface3;
      }
    }
    if (isDark) {
      switch (level) {
        case 0: return const Color(0xFF0A0A0C);
        case 1: return const Color(0xFF16161E);
        case 2: return const Color(0xFF1F1F24);
        case 3: return const Color(0xFF23232A);
      }
    }
    // Light theme
    switch (level) {
      case 0: return const Color(0xFFF8F9FA);
      case 1: return Colors.white;
      case 2: return const Color(0xFFF0F1F3);
      case 3: return const Color(0xFFE8EAED);
    }
    return const Color(0xFFF8F9FA);
  }

  static Color borderFor(BuildContext context, {bool strong = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (strong) {
      return isDark ? borderStrong : borderDefaultLight;
    }
    return isDark ? borderSubtle : borderSubtleLight;
  }
}