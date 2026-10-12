// lib/src/features/reader/controller/reader_theme.dart
//
// Theme and color filter logic extracted from reader_screen.dart.
// Pure Dart — no Flutter engine, no BuildContext, no state.

import 'package:flutter/material.dart';

/// Reader theme modes (background styles).
enum ReaderThemeMode { black, darkGray, white }

/// Color filter effects applied to page images.
enum ReaderColorFilter { none, invert, grayscale, nightAmber, sepia }

/// Image scaling behavior.
enum ImageScaleType { fitWidth, fitHeight, fitScreen, original }

/// Canvas background color for each theme mode.
///
/// Colors match the live [ReaderScreen] values (dark slate is cooler than
/// Material grey-900 so OLED and "Dark Slate" stay visually distinct).
Color canvasBackgroundColor(ReaderThemeMode mode) {
  switch (mode) {
    case ReaderThemeMode.black:
      return const Color(0xFF000000);
    case ReaderThemeMode.darkGray:
      return const Color(0xFF1A1A20);
    case ReaderThemeMode.white:
      return const Color(0xFFFFFFFF);
  }
}

/// Active color filter for a given mode.
/// Returns null for [ReaderColorFilter.none].
ColorFilter? activeColorFilter(ReaderColorFilter mode) {
  switch (mode) {
    case ReaderColorFilter.none:
      return null;
    case ReaderColorFilter.invert:
      return const ColorFilter.matrix([
        -1, 0, 0, 0, 255,
        0, -1, 0, 0, 255,
        0, 0, -1, 0, 255,
        0, 0, 0, 1, 0,
      ]);
    case ReaderColorFilter.grayscale:
      return const ColorFilter.matrix([
        0.2126, 0.7152, 0.0722, 0, 0,
        0.2126, 0.7152, 0.0722, 0, 0,
        0.2126, 0.7152, 0.0722, 0, 0,
        0, 0, 0, 1, 0,
      ]);
    case ReaderColorFilter.nightAmber:
      // Live reader uses a soft amber burn, not a hard matrix crush.
      return ColorFilter.mode(Colors.amber.withAlpha(50), BlendMode.colorBurn);
    case ReaderColorFilter.sepia:
      return const ColorFilter.matrix([
        0.393, 0.769, 0.189, 0, 0,
        0.349, 0.686, 0.168, 0, 0,
        0.272, 0.534, 0.131, 0, 0,
        0, 0, 0, 1, 0,
      ]);
  }
}

/// BoxFit for [ImageScaleType] (paged/webtoon image widgets).
BoxFit imageBoxFit(ImageScaleType type) {
  switch (type) {
    case ImageScaleType.fitHeight:
      return BoxFit.fitHeight;
    case ImageScaleType.fitScreen:
      return BoxFit.contain;
    case ImageScaleType.original:
      return BoxFit.none;
    case ImageScaleType.fitWidth:
      return BoxFit.fitWidth;
  }
}

/// Settings label for theme mode.
String themeModeLabel(ReaderThemeMode mode) {
  switch (mode) {
    case ReaderThemeMode.black:
      return 'Black';
    case ReaderThemeMode.darkGray:
      return 'Dark Gray';
    case ReaderThemeMode.white:
      return 'White';
  }
}

/// Settings label for color filter.
String colorFilterLabel(ReaderColorFilter filter) {
  switch (filter) {
    case ReaderColorFilter.none:
      return 'None';
    case ReaderColorFilter.invert:
      return 'Invert';
    case ReaderColorFilter.grayscale:
      return 'Grayscale';
    case ReaderColorFilter.nightAmber:
      return 'Night Amber';
    case ReaderColorFilter.sepia:
      return 'Sepia';
  }
}

/// Settings label for scale type.
String scaleTypeLabel(ImageScaleType type) {
  switch (type) {
    case ImageScaleType.fitWidth:
      return 'Fit Width';
    case ImageScaleType.fitHeight:
      return 'Fit Height';
    case ImageScaleType.fitScreen:
      return 'Fit Screen';
    case ImageScaleType.original:
      return 'Original';
  }
}

/// Parse theme mode from settings string.
ReaderThemeMode parseReaderTheme(String str) {
  switch (str.toLowerCase()) {
    case 'dark gray':
    case 'gray':
      return ReaderThemeMode.darkGray;
    case 'white':
      return ReaderThemeMode.white;
    default:
      return ReaderThemeMode.black;
  }
}

/// Parse color filter from settings string.
ReaderColorFilter parseColorFilter(String str) {
  switch (str.toLowerCase()) {
    case 'invert':
    case 'invert colors':
      return ReaderColorFilter.invert;
    case 'grayscale':
      return ReaderColorFilter.grayscale;
    case 'amber tint':
    case 'night amber':
      return ReaderColorFilter.nightAmber;
    case 'sepia':
      return ReaderColorFilter.sepia;
    default:
      return ReaderColorFilter.none;
  }
}

/// Parse scale type from settings string.
ImageScaleType parseScaleType(String str) {
  switch (str.toLowerCase()) {
    case 'fit height':
      return ImageScaleType.fitHeight;
    case 'fit screen':
      return ImageScaleType.fitScreen;
    case 'original':
      return ImageScaleType.original;
    default:
      return ImageScaleType.fitWidth;
  }
}