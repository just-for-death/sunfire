// UIS-P2-E: double-page spread pairing / isolation / orientation.
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/features/reader/double_page_layout.dart';

void main() {
  group('parse + shouldUseDoublePages', () {
    test('round-trip labels', () {
      for (final m in DoublePageDisplayMode.values) {
        expect(parseDoublePageDisplayMode(doublePageDisplayModeSettingsValue(m)), m);
      }
    });

    test('automatic follows orientation', () {
      expect(
        shouldUseDoublePages(mode: DoublePageDisplayMode.automatic, isLandscape: true),
        isTrue,
      );
      expect(
        shouldUseDoublePages(mode: DoublePageDisplayMode.automatic, isLandscape: false),
        isFalse,
      );
      expect(
        shouldUseDoublePages(mode: DoublePageDisplayMode.single, isLandscape: true),
        isFalse,
      );
      expect(
        shouldUseDoublePages(mode: DoublePageDisplayMode.doublePages, isLandscape: false),
        isTrue,
      );
    });
  });

  group('buildSpreadSlots', () {
    test('plain pairs', () {
      final slots = buildSpreadSlots(pageCount: 5);
      expect(slots.length, 3);
      expect(slots[0].pageIndices, [0, 1]);
      expect(slots[1].pageIndices, [2, 3]);
      expect(slots[2].pageIndices, [4]);
    });

    test('page offset isolates first', () {
      final slots = buildSpreadSlots(pageCount: 5, pageOffset: true);
      expect(slots.first.pageIndices, [0]);
      expect(slots[1].pageIndices, [1, 2]);
      expect(slots[2].pageIndices, [3, 4]);
    });

    test('wide page isolation breaks pairing', () {
      final slots = buildSpreadSlots(
        pageCount: 5,
        wideFlags: [false, true, false, false, false],
      );
      expect(slots[0].pageIndices, [0]); // unpaired before wide
      expect(slots[1].isWideIsolated, isTrue);
      expect(slots[1].pageIndices, [1]);
      expect(slots[2].pageIndices, [2, 3]);
      expect(slots[3].pageIndices, [4]);
    });

    test('empty chapter', () {
      expect(buildSpreadSlots(pageCount: 0), isEmpty);
    });
  });

  group('lookups + visual order', () {
    test('spreadIndexForPage + pageNumberForSpread', () {
      final slots = buildSpreadSlots(pageCount: 4);
      expect(spreadIndexForPage(slots, 3), 1);
      expect(pageNumberForSpread(slots, 1, pageCount: 4), 3);
    });

    test('invertDoublePages swaps visual sides', () {
      const slot = SpreadSlot(primaryIndex: 2, secondaryIndex: 3);
      expect(slot.visualOrder(invertDoublePages: false), (2, 3));
      expect(slot.visualOrder(invertDoublePages: true), (3, 2));
    });
  });

  test('isWidePage threshold', () {
    expect(isWidePage(null), isFalse);
    expect(isWidePage(0.7), isFalse);
    expect(isWidePage(1.0), isTrue);
    expect(isWidePage(1.4), isTrue);
  });
}
