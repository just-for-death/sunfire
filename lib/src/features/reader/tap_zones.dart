/// Tap-zone presets for the manga reader (Mihon / Tachimanga-style).
///
/// Geometry is in visual screen space (origin top-left). Callers map the
/// returned [TapZoneAction] for RTL / invert after resolving the region.
library;

enum TapZonePreset {
  /// Left third = previous, right third = next, center = menu.
  defaultZones,

  /// Left strip = previous; right strip OR bottom band = next; rest = menu.
  lShaped,

  /// Kindle-ish: left ~2/3 = next, right ~1/3 = previous (no dedicated menu).
  kindle,

  /// Only outer edges (~12%) turn pages; large center = menu.
  edge,

  /// Left half previous, right half next (thin center menu).
  leftRight,

  /// Zones off — every tap is menu / toggle controls.
  off,
}

enum TapZoneAction { previous, next, menu }

extension TapZonePresetLabel on TapZonePreset {
  String get settingsLabel {
    switch (this) {
      case TapZonePreset.defaultZones:
        return 'Default';
      case TapZonePreset.lShaped:
        return 'L-shaped';
      case TapZonePreset.kindle:
        return 'Kindle-ish';
      case TapZonePreset.edge:
        return 'Edge';
      case TapZonePreset.leftRight:
        return 'Left-Right';
      case TapZonePreset.off:
        return 'Off';
    }
  }
}

TapZonePreset parseTapZonePreset(String? raw) {
  switch ((raw ?? '').trim().toLowerCase()) {
    case 'l-shaped':
    case 'lshaped':
    case 'l_shaped':
      return TapZonePreset.lShaped;
    case 'kindle-ish':
    case 'kindle':
      return TapZonePreset.kindle;
    case 'edge':
      return TapZonePreset.edge;
    case 'left-right':
    case 'left_right':
    case 'leftright':
      return TapZonePreset.leftRight;
    case 'off':
    case 'disabled':
    case 'none':
      return TapZonePreset.off;
    case 'default':
    default:
      return TapZonePreset.defaultZones;
  }
}

String tapZonePresetSettingsValue(TapZonePreset preset) => preset.settingsLabel;

/// Resolves which region a tap lands in for [preset] (before invert/RTL).
TapZoneAction resolveTapZoneAction({
  required TapZonePreset preset,
  required double dx,
  required double dy,
  required double width,
  required double height,
}) {
  if (width <= 0 || height <= 0) return TapZoneAction.menu;
  final x = (dx / width).clamp(0.0, 1.0);
  final y = (dy / height).clamp(0.0, 1.0);

  switch (preset) {
    case TapZonePreset.off:
      return TapZoneAction.menu;
    case TapZonePreset.defaultZones:
      if (x < 1 / 3) return TapZoneAction.previous;
      if (x > 2 / 3) return TapZoneAction.next;
      return TapZoneAction.menu;
    case TapZonePreset.lShaped:
      if (x < 1 / 3) return TapZoneAction.previous;
      if (x > 2 / 3 || y > 2 / 3) return TapZoneAction.next;
      return TapZoneAction.menu;
    case TapZonePreset.kindle:
      // Kindle convention: majority of the screen advances.
      if (x < 2 / 3) return TapZoneAction.next;
      return TapZoneAction.previous;
    case TapZonePreset.edge:
      if (x < 0.12) return TapZoneAction.previous;
      if (x > 0.88) return TapZoneAction.next;
      return TapZoneAction.menu;
    case TapZonePreset.leftRight:
      if (x < 0.45) return TapZoneAction.previous;
      if (x > 0.55) return TapZoneAction.next;
      return TapZoneAction.menu;
  }
}

/// Applies invert (swap prev/next) then optional RTL reading-direction swap.
TapZoneAction applyTapZoneModifiers(
  TapZoneAction action, {
  required bool invert,
  required bool rtlPaged,
}) {
  var result = action;
  if (invert && result != TapZoneAction.menu) {
    result = result == TapZoneAction.next ? TapZoneAction.previous : TapZoneAction.next;
  }
  // Manga RTL: visual left advances, visual right goes back.
  if (rtlPaged && result != TapZoneAction.menu) {
    result = result == TapZoneAction.next ? TapZoneAction.previous : TapZoneAction.next;
  }
  return result;
}

/// Region rectangles (normalized 0–1) for overlay painting / tests.
/// Each entry is (action, left, top, right, bottom).
List<(TapZoneAction, double, double, double, double)> tapZoneRegions(TapZonePreset preset) {
  switch (preset) {
    case TapZonePreset.off:
      return const [(TapZoneAction.menu, 0, 0, 1, 1)];
    case TapZonePreset.defaultZones:
      return const [
        (TapZoneAction.previous, 0, 0, 1 / 3, 1),
        (TapZoneAction.menu, 1 / 3, 0, 2 / 3, 1),
        (TapZoneAction.next, 2 / 3, 0, 1, 1),
      ];
    case TapZonePreset.lShaped:
      return const [
        (TapZoneAction.previous, 0, 0, 1 / 3, 1),
        (TapZoneAction.menu, 1 / 3, 0, 2 / 3, 2 / 3),
        (TapZoneAction.next, 2 / 3, 0, 1, 2 / 3),
        (TapZoneAction.next, 1 / 3, 2 / 3, 1, 1),
      ];
    case TapZonePreset.kindle:
      return const [
        (TapZoneAction.next, 0, 0, 2 / 3, 1),
        (TapZoneAction.previous, 2 / 3, 0, 1, 1),
      ];
    case TapZonePreset.edge:
      return const [
        (TapZoneAction.previous, 0, 0, 0.12, 1),
        (TapZoneAction.menu, 0.12, 0, 0.88, 1),
        (TapZoneAction.next, 0.88, 0, 1, 1),
      ];
    case TapZonePreset.leftRight:
      return const [
        (TapZoneAction.previous, 0, 0, 0.45, 1),
        (TapZoneAction.menu, 0.45, 0, 0.55, 1),
        (TapZoneAction.next, 0.55, 0, 1, 1),
      ];
  }
}
