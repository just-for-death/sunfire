// Sunfire color tokens for the manga reader.
// Uses FlexColorScheme compatible seeds with OLED/True Black support.

import 'package:flutter/material.dart';

import '../../../core/services/settings_service.dart';

/// Semantic color tokens for Sunfire manga reader.
/// FlexColorScheme-based system tuned for manga reading.
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

  // ── Tracker / Sync Colors (AniList blue, MAL blue, Metron teal) ───────────
  /// Primary interactive accent for trackers — indigo-blue.
  static const Color trackerBlue = Color(0xFF448AFF);        // blueAccent
  static const Color trackerBlueContainer = Color(0x1A448AFF);
  static const Color trackerBlueSubtle = Color(0x0D448AFF);

  /// Positive confirmation: tracker linked, synced, auth OK.
  static const Color trackerGreen = Color(0xFF69F0AE);       // greenAccent
  static const Color trackerGreenContainer = Color(0x1A69F0AE);

  /// Warning / pending: e.g. Metron partial match, queue pending.
  static const Color trackerAmber = Color(0xFFFFD740);       // amberAccent
  static const Color trackerAmberContainer = Color(0x1AFFD740);
  static const Color onTrackerAmber = Color(0xFF000000);     // dark text on amber

  // ── Browse / Extension Source Colors ─────────────────────────────────────
  /// Local JS extension badge – teal.
  static const Color sourceLocalJs = Color(0xFF64FFDA);      // tealAccent
  static const Color sourceLocalJsContainer = Color(0x1A64FFDA);
  static const Color sourceLocalJsSelected = Color(0xFF00695C); // teal.shade800

  /// Server (Suwayomi APK) extension badge – light blue.
  static const Color sourceServer = Color(0xFF80D8FF);        // lightBlueAccent
  static const Color sourceServerContainer = Color(0x1A80D8FF);
  static const Color sourceServerSelected = Color(0xFF0D47A1); // blue.shade800

  /// Pinned source badge – amber.
  static const Color sourcePinned = Color(0xFFFFD740);        // amberAccent
  static const Color sourcePinnedSelected = Color(0xFFFF6F00); // amber.shade900

  // ── Destructive / Cancel ─────────────────────────────────────────────────
  static const Color destructive = Color(0xFFFF5252);         // redAccent
  static const Color destructiveContainer = Color(0x1AFF5252);

  // ── HUD and Reader Overlay Scrims ──────────────────────────────────────────
  static const Color transparent = Color(0x00000000);
  static const Color overlayScrim = Color(0xCC000000);     // 80% black gradient
  static const Color overlaySurface = Color(0xCC141419);   // HUD capsule background
  static const Color overlayButton = Color(0x14FFFFFF);    // 8% white button fill
  static const Color overlayTrack = Color(0xFF424242);     // Inactive slider track
  static const Color overlayHighlight = Color(0xFFFFD54F); // Amber accent (bookmark/auto-scroll)
  static const Color shadowDefault = Color(0x55000000);    // Default shadow

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