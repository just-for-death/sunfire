/// Sunfire spacing tokens - 4pt base scale.
///
/// D4.2: single source of truth for padding, gaps, and radii so screens stop
/// hard-coding magic numbers.
library;

/// Spacing scale built on a 4pt base unit.
class SunfireSpacing {
  SunfireSpacing._();

  static const double none = 0;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// Standard screen edge padding.
  static const double screenEdge = lg;

  /// Gap between cards in grids/lists.
  static const double cardGap = sm;

  /// Gap between related controls in a row/column.
  static const double controlGap = sm;

  /// Gap between unrelated sections.
  static const double sectionGap = xl;

  /// Touch target minimum (Material accessibility floor).
  static const double minTouchTarget = 48;

  /// Library grid cross-axis spacing.
  static const double gridCross = sm;

  /// Library grid main-axis spacing.
  static const double gridMain = md;
}

/// Corner radius scale.
class SunfireRadius {
  SunfireRadius._();

  static const double none = 0;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double full = 999;

  /// Default card corner radius.
  static const double card = md;

  /// Dialog corner radius (Material 3 default).
  static const double dialog = 28;

  /// Bottom sheet corner radius.
  static const double sheet = lg;

  /// Chip / pill radius.
  static const double pill = full;
}

/// Icon size scale (matches the sizes already dominant in the app).
class SunfireIconSize {
  SunfireIconSize._();

  /// Tiny / badge icons.
  static const double xs = 12;

  /// Small / chip avatar icons.
  static const double sm = 16;

  /// Standard list / button icons (most common).
  static const double std = 18;

  /// Medium / section icons.
  static const double md = 20;

  /// Large / header icons.
  static const double lg = 24;

  /// Hero / empty-state icons.
  static const double xl = 32;
}
