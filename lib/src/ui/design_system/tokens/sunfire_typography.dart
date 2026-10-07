/// Sunfire-specific typography built on the Material 3 type scale.
/// Adds manga-specific styles for the reader, library, and manga details.
library;

import 'package:flutter/material.dart';

/// Extended typography for Sunfire manga reader.
class SunfireTypography {
  SunfireTypography._();

  // ── Base Material 3 Type Scale ─────────────────────────────
  static const TextStyle displayLarge = TextStyle(
    fontSize: 57, height: 64 / 57, fontWeight: FontWeight.w400, letterSpacing: -0.25,
  );
  static const TextStyle displayMedium = TextStyle(
    fontSize: 45, height: 52 / 45, fontWeight: FontWeight.w400, letterSpacing: 0,
  );
  static const TextStyle displaySmall = TextStyle(
    fontSize: 36, height: 44 / 36, fontWeight: FontWeight.w400, letterSpacing: 0,
  );
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32, height: 40 / 32, fontWeight: FontWeight.w400, letterSpacing: 0,
  );
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28, height: 36 / 28, fontWeight: FontWeight.w400, letterSpacing: 0,
  );
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24, height: 32 / 24, fontWeight: FontWeight.w400, letterSpacing: 0,
  );
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22, height: 28 / 22, fontWeight: FontWeight.w400, letterSpacing: 0,
  );
  static const TextStyle titleMedium = TextStyle(
    fontSize: 16, height: 24 / 16, fontWeight: FontWeight.w500, letterSpacing: 0.15,
  );
  static const TextStyle titleSmall = TextStyle(
    fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w500, letterSpacing: 0.1,
  );
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16, height: 24 / 16, fontWeight: FontWeight.w400, letterSpacing: 0.5,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w400, letterSpacing: 0.25,
  );
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w400, letterSpacing: 0.4,
  );
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w500, letterSpacing: 0.1,
  );
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w500, letterSpacing: 0.5,
  );
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11, height: 16 / 11, fontWeight: FontWeight.w500, letterSpacing: 0.5,
  );

  // ── Manga-Specific Styles ──────────────────────────────────────────────────
  
  /// Manga title in library grid cards (2 lines max)
  static const TextStyle mangaTitle = TextStyle(
    fontSize: 13, height: 14 / 12, fontWeight: FontWeight.w600, letterSpacing: 0.1,
  );

  /// Chapter name in lists
  static const TextStyle chapterName = TextStyle(
    fontSize: 12, height: 13 / 12, fontWeight: FontWeight.w500, letterSpacing: 0.1,
  );

  /// Chapter subtitle (progress, scanlator, etc.)
  static const TextStyle chapterSubtitle = TextStyle(
    fontSize: 11, height: 13 / 11, fontWeight: FontWeight.w400, letterSpacing: 0.2,
  );

  /// Source name badges
  static const TextStyle sourceBadge = TextStyle(
    fontSize: 10, height: 14 / 10, fontWeight: FontWeight.w600, letterSpacing: 0.5,
  );

  /// Language badges
  static const TextStyle languageBadge = TextStyle(
    fontSize: 10, height: 14 / 10, fontWeight: FontWeight.w600, letterSpacing: 0.5,
  );

  /// Metadata (author, status, date)
  static const TextStyle metadata = TextStyle(
    fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w400, letterSpacing: 0.2,
  );

  /// Settings section headers
  static const TextStyle sectionHeader = TextStyle(
    fontSize: 11, height: 14 / 11, fontWeight: FontWeight.w700, letterSpacing: 1.0,
  );

  // ── Reader-Specific Styles ──────────────────────────────────────────────────
  
  /// Chapter title in reader header
  static const TextStyle readerChapterTitle = TextStyle(
    fontSize: 18, height: 24 / 18, fontWeight: FontWeight.w700, letterSpacing: -0.1,
  );

  /// Manga title in reader header
  static const TextStyle readerMangaTitle = TextStyle(
    fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w500, letterSpacing: 0.1,
  );

  /// Page number in reader
  static const TextStyle readerPageNumber = TextStyle(
    fontSize: 13, height: 18 / 13, fontWeight: FontWeight.w500, letterSpacing: 0.2,
  );

  // ── Helpers ─────────────────────────────────────────────────────────────────

  static TextStyle withColor(TextStyle base, Color color) => base.copyWith(color: color);
  static TextStyle withWeight(TextStyle base, FontWeight weight) => base.copyWith(fontWeight: weight);
  static TextStyle withSize(TextStyle base, double size) => base.copyWith(fontSize: size, height: base.height ?? 1.0);
}