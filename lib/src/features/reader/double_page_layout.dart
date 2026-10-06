/// Double-page / spread layout helpers for the paged reader.
///
/// Pure functions — no Flutter engine / DB — so unit tests stay light.
library;

enum DoublePageDisplayMode {
  /// Always one page per viewport.
  single,

  /// Always attempt two-page spreads (subject to wide isolation / offset).
  doublePages,

  /// Landscape → double, portrait → single.
  automatic,
}

extension DoublePageDisplayModeLabel on DoublePageDisplayMode {
  String get settingsLabel {
    switch (this) {
      case DoublePageDisplayMode.single:
        return 'Single';
      case DoublePageDisplayMode.doublePages:
        return 'Double';
      case DoublePageDisplayMode.automatic:
        return 'Automatic';
    }
  }
}

DoublePageDisplayMode parseDoublePageDisplayMode(String? raw) {
  switch ((raw ?? '').trim().toLowerCase()) {
    case 'double':
    case 'double pages':
    case 'double_pages':
      return DoublePageDisplayMode.doublePages;
    case 'automatic':
    case 'auto':
    case 'automatic by orientation':
      return DoublePageDisplayMode.automatic;
    case 'single':
    default:
      return DoublePageDisplayMode.single;
  }
}

String doublePageDisplayModeSettingsValue(DoublePageDisplayMode mode) => mode.settingsLabel;

/// One viewport slot in paged double-page mode (0-based page indices).
class SpreadSlot {
  const SpreadSlot({
    required this.primaryIndex,
    this.secondaryIndex,
    this.isWideIsolated = false,
  });

  /// Left page in LTR (or right page in RTL after invert). Always set.
  final int primaryIndex;

  /// Paired page when this slot is a two-page spread; null for singles.
  final int? secondaryIndex;

  /// True when a wide page forced isolation (shown alone in double mode).
  final bool isWideIsolated;

  bool get isSpread => secondaryIndex != null;

  List<int> get pageIndices =>
      secondaryIndex == null ? [primaryIndex] : [primaryIndex, secondaryIndex!];

  /// Visual left/right for a Row, honouring [invertDoublePages] (RTL pairing).
  (int left, int? right) visualOrder({required bool invertDoublePages}) {
    if (secondaryIndex == null) return (primaryIndex, null);
    if (invertDoublePages) return (secondaryIndex!, primaryIndex);
    return (primaryIndex, secondaryIndex);
  }
}

/// Whether double-page layout should be active for the current orientation.
bool shouldUseDoublePages({
  required DoublePageDisplayMode mode,
  required bool isLandscape,
}) {
  switch (mode) {
    case DoublePageDisplayMode.single:
      return false;
    case DoublePageDisplayMode.doublePages:
      return true;
    case DoublePageDisplayMode.automatic:
      return isLandscape;
  }
}

/// Wide when width/height >= [threshold] (default 1.0 = landscape-ish page).
bool isWidePage(double? aspectRatio, {double threshold = 1.0}) {
  if (aspectRatio == null || aspectRatio <= 0) return false;
  return aspectRatio >= threshold;
}

/// Builds spread slots for [pageCount] pages (0-based indices 0..pageCount-1).
///
/// [pageOffset]: when true, page 0 stands alone, then pair 1-2, 3-4, …
/// [wideFlags]: optional per-index wide markers; wide pages are isolated and
/// do not pair with a neighbour.
List<SpreadSlot> buildSpreadSlots({
  required int pageCount,
  bool pageOffset = false,
  List<bool>? wideFlags,
}) {
  if (pageCount <= 0) return const [];

  final wide = wideFlags == null
      ? List<bool>.filled(pageCount, false)
      : List<bool>.generate(pageCount, (i) => i < wideFlags.length && wideFlags[i]);

  final slots = <SpreadSlot>[];
  var i = 0;

  // Optional cover / first-page offset: force page 0 alone when not wide.
  if (pageOffset && pageCount > 0) {
    slots.add(SpreadSlot(primaryIndex: 0, isWideIsolated: wide[0]));
    i = 1;
  }

  while (i < pageCount) {
    if (wide[i]) {
      slots.add(SpreadSlot(primaryIndex: i, isWideIsolated: true));
      i += 1;
      continue;
    }
    final next = i + 1;
    if (next < pageCount && !wide[next]) {
      slots.add(SpreadSlot(primaryIndex: i, secondaryIndex: next));
      i += 2;
    } else {
      slots.add(SpreadSlot(primaryIndex: i));
      i += 1;
    }
  }
  return slots;
}

/// Finds the spread index that contains 0-based [pageIndex], or 0 if missing.
int spreadIndexForPage(List<SpreadSlot> slots, int pageIndex) {
  for (var s = 0; s < slots.length; s++) {
    if (slots[s].pageIndices.contains(pageIndex)) return s;
  }
  return 0;
}

/// First page (1-based) shown for [spreadIndex], clamped.
int pageNumberForSpread(List<SpreadSlot> slots, int spreadIndex, {required int pageCount}) {
  if (pageCount <= 0 || slots.isEmpty) return 1;
  final i = spreadIndex.clamp(0, slots.length - 1);
  return (slots[i].primaryIndex + 1).clamp(1, pageCount);
}
