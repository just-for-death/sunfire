// lib/src/features/reader/controller/position_manager.dart debouncing unit tests

import 'dart:ui' show Size;

import 'package:flutter_test/flutter_test.dart';

import 'package:sunfire/src/features/reader/reader_scroll_utils.dart';
import 'package:sunfire/src/features/reader/reading_mode.dart';

void main() {
  group('PositionManager pure functions', () {
    group('shouldPersistProgressPage', () {
      test('returns true for first page read (previousSaved = 0)', () {
        expect(shouldPersistProgressPage(page: 1, previousSaved: 0), isTrue);
        expect(shouldPersistProgressPage(page: 5, previousSaved: 0), isTrue);
      });

      test('returns true when progressing forward', () {
        expect(shouldPersistProgressPage(page: 5, previousSaved: 3), isTrue);
        expect(shouldPersistProgressPage(page: 10, previousSaved: 5), isTrue);
        expect(shouldPersistProgressPage(page: 100, previousSaved: 99), isTrue);
      });

      test('returns false when regressing', () {
        expect(shouldPersistProgressPage(page: 2, previousSaved: 5), isFalse);
        expect(shouldPersistProgressPage(page: 5, previousSaved: 10), isFalse);
        expect(shouldPersistProgressPage(page: 1, previousSaved: 100), isFalse);
      });

      test('returns false for page 0 or negative', () {
        expect(shouldPersistProgressPage(page: 0, previousSaved: 0), isFalse);
        expect(shouldPersistProgressPage(page: 0, previousSaved: 5), isFalse);
        expect(shouldPersistProgressPage(page: -1, previousSaved: 0), isFalse);
        expect(shouldPersistProgressPage(page: -1, previousSaved: 10), isFalse);
      });

      test('returns true when page equals previous (no regression)', () {
        expect(shouldPersistProgressPage(page: 5, previousSaved: 5), isTrue);
        expect(shouldPersistProgressPage(page: 1, previousSaved: 1), isTrue);
        expect(shouldPersistProgressPage(page: 100, previousSaved: 100), isTrue);
      });

      test('handles large page numbers', () {
        expect(shouldPersistProgressPage(page: 1000, previousSaved: 500), isTrue);
        expect(shouldPersistProgressPage(page: 500, previousSaved: 1000), isFalse);
      });
    });

    group('resumeOffsetForPage', () {
      test('returns 0 for page 1', () {
        final offset = resumeOffsetForPage(
          targetPage: 1,
          pageCount: 10,
          heightForIndex: (i) => 100.0,
          gapAfterIndex: (i) => 10.0,
        );
        expect(offset, equals(0.0));
      });

      test('returns 0 for page 0 or negative', () {
        expect(
          resumeOffsetForPage(
            targetPage: 0,
            pageCount: 10,
            heightForIndex: (i) => 100.0,
            gapAfterIndex: (i) => 10.0,
          ),
          equals(0.0),
        );
        expect(
          resumeOffsetForPage(
            targetPage: -1,
            pageCount: 10,
            heightForIndex: (i) => 100.0,
            gapAfterIndex: (i) => 10.0,
          ),
          equals(0.0),
        );
      });

      test('calculates correct offset for page 2', () {
        final offset = resumeOffsetForPage(
          targetPage: 2,
          pageCount: 10,
          heightForIndex: (i) => 100.0,
          gapAfterIndex: (i) => 10.0,
        );
        expect(offset, equals(110.0));
      });

      test('calculates correct offset for page 3', () {
        final offset = resumeOffsetForPage(
          targetPage: 3,
          pageCount: 10,
          heightForIndex: (i) => 100.0,
          gapAfterIndex: (i) => 10.0,
        );
        expect(offset, equals(220.0));
      });

      test('handles variable heights', () {
        final offset = resumeOffsetForPage(
          targetPage: 3,
          pageCount: 10,
          heightForIndex: (i) => i == 0 ? 150.0 : 100.0,
          gapAfterIndex: (i) => 10.0,
        );
        expect(offset, equals(270.0));
      });

      test('handles variable gaps', () {
        final offset = resumeOffsetForPage(
          targetPage: 3,
          pageCount: 10,
          heightForIndex: (i) => 100.0,
          gapAfterIndex: (i) => i == 0 ? 20.0 : 10.0,
        );
        expect(offset, equals(230.0));
      });

      test('clamps targetPage to pageCount', () {
        final offset = resumeOffsetForPage(
          targetPage: 15,
          pageCount: 10,
          heightForIndex: (i) => 100.0,
          gapAfterIndex: (i) => 10.0,
        );
        expect(offset, equals(1100.0));
      });

      test('handles empty pageCount', () {
        final offset = resumeOffsetForPage(
          targetPage: 1,
          pageCount: 0,
          heightForIndex: (i) => 100.0,
          gapAfterIndex: (i) => 10.0,
        );
        expect(offset, equals(0.0));
      });
    });

    group('fittedHeightForWidth', () {
      test('returns estimated height for zero intrinsic width', () {
        final result = fittedHeightForWidth(
          Size(0, 100),
          200.0,
        );
        expect(result, equals(300.0));
      });

      test('returns estimated height for negative intrinsic width', () {
        final result = fittedHeightForWidth(
          Size(-10, 100),
          200.0,
        );
        expect(result, equals(300.0));
      });

      test('calculates proportional height', () {
        final result = fittedHeightForWidth(
          Size(100, 200),
          200.0,
        );
        expect(result, equals(400.0));
      });

      test('handles landscape images', () {
        final result = fittedHeightForWidth(
          Size(200, 100),
          200.0,
        );
        expect(result, equals(100.0));
      });

      test('handles zero target width', () {
        final result = fittedHeightForWidth(
          Size(100, 100),
          0.0,
        );
        // When width <= 0, returns estimateWebtoonPlaceholderHeight(0) = 1.0
        expect(result, equals(1.0));
      });
    });

    group('estimateWebtoonPlaceholderHeight', () {
      test('returns cached height when available', () {
        final result = estimateWebtoonPlaceholderHeight(200.0, cachedHeight: 500.0);
        expect(result, equals(500.0));
      });

      test('uses 1.5x contentWidth when no cache', () {
        final result = estimateWebtoonPlaceholderHeight(200.0);
        expect(result, equals(300.0));
      });

      test('minimum height is 1.0', () {
        final result = estimateWebtoonPlaceholderHeight(0.1);
        expect(result, equals(1.0));
      });

      test('ignores zero cached height', () {
        final result = estimateWebtoonPlaceholderHeight(200.0, cachedHeight: 0.0);
        expect(result, equals(300.0));
      });

      test('ignores negative cached height', () {
        final result = estimateWebtoonPlaceholderHeight(200.0, cachedHeight: -10.0);
        expect(result, equals(300.0));
      });
    });

    group('webtoonPageGap', () {
      test('returns 12.0 for longStripGaps', () {
        expect(webtoonPageGap(ReadingMode.longStripGaps), equals(12.0));
      });

      test('returns 0.0 for longStrip', () {
        expect(webtoonPageGap(ReadingMode.longStrip), equals(0.0));
      });

      test('returns 0.0 for paged modes', () {
        expect(webtoonPageGap(ReadingMode.pagedLtr), equals(0.0));
        expect(webtoonPageGap(ReadingMode.pagedRtl), equals(0.0));
      });
    });

    group('webtoonShouldOverlapPrevious', () {
      test('returns true for longStrip with index > 0', () {
        expect(webtoonShouldOverlapPrevious(ReadingMode.longStrip, 1), isTrue);
        expect(webtoonShouldOverlapPrevious(ReadingMode.longStrip, 5), isTrue);
      });

      test('returns false for longStrip with index 0', () {
        expect(webtoonShouldOverlapPrevious(ReadingMode.longStrip, 0), isFalse);
      });

      test('returns false for longStripGaps', () {
        expect(webtoonShouldOverlapPrevious(ReadingMode.longStripGaps, 1), isFalse);
        expect(webtoonShouldOverlapPrevious(ReadingMode.longStripGaps, 0), isFalse);
      });

      test('returns false for paged modes', () {
        expect(webtoonShouldOverlapPrevious(ReadingMode.pagedLtr, 1), isFalse);
        expect(webtoonShouldOverlapPrevious(ReadingMode.pagedRtl, 1), isFalse);
      });
    });

    group('detectBestVisiblePage', () {
      test('returns null for empty list', () {
        final result = detectBestVisiblePage(
          viewportHeight: 1000,
          pages: [],
        );
        expect(result, isNull);
      });

      test('returns page closest to viewport center', () {
        final pages = [
          (page: 1, top: 0.0, bottom: 300.0),
          (page: 2, top: 300.0, bottom: 600.0),
          (page: 3, top: 600.0, bottom: 900.0),
        ];

        final result = detectBestVisiblePage(
          viewportHeight: 1000,
          pages: pages,
        );

        expect(result, equals(2));
      });

      test('ignores pages not visible', () {
        final pages = [
          (page: 1, top: -500.0, bottom: -200.0),
          (page: 2, top: 100.0, bottom: 400.0),
          (page: 3, top: 1500.0, bottom: 1800.0),
        ];

        final result = detectBestVisiblePage(
          viewportHeight: 1000,
          pages: pages,
        );

        expect(result, equals(2));
      });

      test('handles partial visibility', () {
        final pages = [
          (page: 1, top: 0.0, bottom: 200.0),
          (page: 2, top: 200.0, bottom: 800.0),
          (page: 3, top: 800.0, bottom: 1000.0),
        ];

        final result = detectBestVisiblePage(
          viewportHeight: 1000,
          pages: pages,
        );

        expect(result, equals(2));
      });
    });
  });
}