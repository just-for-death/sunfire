// sunfire_elevation.dart
//
// D4.4: Elevation / shadow tokens. Single source of truth for raised
// surfaces so screens stop inventing their own BoxShadows.

library;

import 'package:flutter/material.dart';

/// Elevation tokens mapped to Material 3 levels plus manga-specific shadows.
class SunfireElevation {
  SunfireElevation._();

  /// Flat - resting cards, list rows.
  static const double level0 = 0;

  /// Slight lift - cards, chips.
  static const double level1 = 1;

  /// Floating - buttons, menus, snackbars.
  static const double level2 = 3;

  /// Temporary surfaces - dialogs, bottom sheets.
  static const double level3 = 6;

  /// Overlays - navigation drawer, reader chrome.
  static const double level4 = 8;

  /// Maximum - drag feedback, tooltips.
  static const double level5 = 12;

  /// Card shadow for light theme (dark theme relies on surface contrast).
  static List<BoxShadow> cardShadow(Brightness brightness) {
    if (brightness == Brightness.dark) return const [];
    return const [
      BoxShadow(
        color: Color(0x14000000),
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ];
  }

  /// Dialog / sheet shadow (both themes).
  static const List<BoxShadow> dialogShadow = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  /// Reader overlay scrim (top/bottom gradient chrome behind controls).
  static const List<BoxShadow> readerChromeShadow = [
    BoxShadow(
      color: Color(0x99000000),
      blurRadius: 16,
      offset: Offset(0, 0),
    ),
  ];
}
