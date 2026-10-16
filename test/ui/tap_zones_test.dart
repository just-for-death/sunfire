// UIS-P2-E: tap-zone presets + modifiers (unit, no reader engine).
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/features/reader/tap_zones.dart';

void main() {
  group('parseTapZonePreset', () {
    test('labels round-trip', () {
      for (final p in TapZonePreset.values) {
        expect(parseTapZonePreset(tapZonePresetSettingsValue(p)), p);
      }
    });
    test('aliases', () {
      expect(parseTapZonePreset('disabled'), TapZonePreset.off);
      expect(parseTapZonePreset('kindle'), TapZonePreset.kindle);
      expect(parseTapZonePreset('L-shaped'), TapZonePreset.lShaped);
    });
  });

  group('resolveTapZoneAction', () {
    test('default thirds', () {
      expect(
        resolveTapZoneAction(preset: TapZonePreset.defaultZones, dx: 10, dy: 50, width: 300, height: 100),
        TapZoneAction.previous,
      );
      expect(
        resolveTapZoneAction(preset: TapZonePreset.defaultZones, dx: 150, dy: 50, width: 300, height: 100),
        TapZoneAction.menu,
      );
      expect(
        resolveTapZoneAction(preset: TapZonePreset.defaultZones, dx: 290, dy: 50, width: 300, height: 100),
        TapZoneAction.next,
      );
    });

    test('l-shaped bottom band is next', () {
      expect(
        resolveTapZoneAction(preset: TapZonePreset.lShaped, dx: 150, dy: 90, width: 300, height: 100),
        TapZoneAction.next,
      );
      expect(
        resolveTapZoneAction(preset: TapZonePreset.lShaped, dx: 150, dy: 20, width: 300, height: 100),
        TapZoneAction.menu,
      );
    });

    test('kindle left majority next', () {
      expect(
        resolveTapZoneAction(preset: TapZonePreset.kindle, dx: 100, dy: 50, width: 300, height: 100),
        TapZoneAction.next,
      );
      expect(
        resolveTapZoneAction(preset: TapZonePreset.kindle, dx: 250, dy: 50, width: 300, height: 100),
        TapZoneAction.previous,
      );
    });

    test('edge only outer 12%', () {
      expect(
        resolveTapZoneAction(preset: TapZonePreset.edge, dx: 20, dy: 50, width: 300, height: 100),
        TapZoneAction.previous,
      );
      expect(
        resolveTapZoneAction(preset: TapZonePreset.edge, dx: 150, dy: 50, width: 300, height: 100),
        TapZoneAction.menu,
      );
    });

    test('left-right halves + thin menu', () {
      expect(
        resolveTapZoneAction(preset: TapZonePreset.leftRight, dx: 50, dy: 50, width: 200, height: 100),
        TapZoneAction.previous,
      );
      expect(
        resolveTapZoneAction(preset: TapZonePreset.leftRight, dx: 100, dy: 50, width: 200, height: 100),
        TapZoneAction.menu,
      );
      expect(
        resolveTapZoneAction(preset: TapZonePreset.leftRight, dx: 160, dy: 50, width: 200, height: 100),
        TapZoneAction.next,
      );
    });

    test('off always menu', () {
      expect(
        resolveTapZoneAction(preset: TapZonePreset.off, dx: 10, dy: 10, width: 100, height: 100),
        TapZoneAction.menu,
      );
    });
  });

  group('applyTapZoneModifiers', () {
    test('invert swaps prev/next, keeps menu', () {
      expect(
        applyTapZoneModifiers(TapZoneAction.next, invert: true, rtlPaged: false),
        TapZoneAction.previous,
      );
      expect(
        applyTapZoneModifiers(TapZoneAction.menu, invert: true, rtlPaged: false),
        TapZoneAction.menu,
      );
    });

    test('rtl swaps like manga convention', () {
      expect(
        applyTapZoneModifiers(TapZoneAction.previous, invert: false, rtlPaged: true),
        TapZoneAction.next,
      );
    });

    test('invert + rtl cancel', () {
      expect(
        applyTapZoneModifiers(TapZoneAction.next, invert: true, rtlPaged: true),
        TapZoneAction.next,
      );
    });
  });

  test('regions cover presets without empty list', () {
    for (final p in TapZonePreset.values) {
      expect(tapZoneRegions(p), isNotEmpty);
    }
  });

  test('out-of-bounds taps resolve to menu, never a page turn', () {
    for (final p in TapZonePreset.values) {
      expect(resolveTapZoneAction(preset: p, dx: -5, dy: 300, width: 300, height: 600), TapZoneAction.menu);
      expect(resolveTapZoneAction(preset: p, dx: 305, dy: 300, width: 300, height: 600), TapZoneAction.menu);
      expect(resolveTapZoneAction(preset: p, dx: 150, dy: -5, width: 300, height: 600), TapZoneAction.menu);
    }
  });

  test('lShaped bottom-left agrees between resolver and regions', () {
    // Bottom-left belongs to the full-height previous rect; the resolver
    // must say previous too (no overlay/action disagreement).
    expect(
      resolveTapZoneAction(preset: TapZonePreset.lShaped, dx: 50, dy: 500, width: 300, height: 600),
      TapZoneAction.previous,
    );
    final prev = tapZoneRegions(TapZonePreset.lShaped).where((r) => r.$1 == TapZoneAction.previous);
    expect(prev.any((r) => 50 / 300 >= r.$2 && 50 / 300 < r.$4 && 500 / 600 >= r.$3 && 500 / 600 < r.$5), isTrue);
  });
}
