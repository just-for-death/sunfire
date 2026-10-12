// sunfire_motion.dart
//
// D4.5: Motion tokens - durations and curves. Single source of truth for
// animation timing so motion feels consistent across screens.

library;

import 'package:flutter/material.dart';

/// Duration tokens (Material 3 motion scale, adapted).
class SunfireDuration {
  SunfireDuration._();

  /// Instant state flips (opacity toggles, selection).
  static const Duration instant = Duration(milliseconds: 80);

  /// Micro-interactions (ripples, chip toggles, icon flips).
  static const Duration fast = Duration(milliseconds: 150);

  /// Default for most UI transitions (dialogs, sheets, fades).
  static const Duration medium = Duration(milliseconds: 300);

  /// Large transitions (screen pushes, hero flights, drawers).
  static const Duration slow = Duration(milliseconds: 500);

  /// Ambient / looping motion (pulse, shimmer).
  static const Duration ambient = Duration(milliseconds: 1500);

  /// Reader page-turn animation (matches ReaderController default).
  static const Duration pageTurn = Duration(milliseconds: 200);

  /// Library grid staggered entrance step per item.
  static const Duration staggerStep = Duration(milliseconds: 30);
}

/// Curve tokens.
class SunfireCurves {
  SunfireCurves._();

  /// Default for incoming UI (dialogs, sheets rising).
  static const Curve emphasized = Curves.easeOutCubic;

  /// Default for outgoing UI (dismissals).
  static const Curve emphasizedOut = Curves.easeInCubic;

  /// Micro-interactions and fades.
  static const Curve standard = Curves.easeInOut;

  /// Playful overshoot (FAB expand, badge pop).
  static const Curve bounce = Curves.elasticOut;

  /// Linear for progress / shimmer loops.
  static const Curve linear = Curves.linear;
}
