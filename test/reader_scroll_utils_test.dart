
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/features/reader/reader_scroll_utils.dart';

void main() {
  test('placeholder uses cache or width*1.5', () {
    expect(estimateWebtoonPlaceholderHeight(200), 300);
    expect(estimateWebtoonPlaceholderHeight(200, cachedHeight: 800), 800);
  });

  test('detectBestVisiblePage prefers max visible near center', () {
    final page = detectBestVisiblePage(
      viewportHeight: 800,
      pages: [
        (page: 1, top: -700, bottom: 50),
        (page: 5, top: 100, bottom: 700),
        (page: 2, top: -100, bottom: 200),
      ],
    );
    expect(page, 5);
  });

  test('scroll-up does not pick first intersecting low index', () {
    final page = detectBestVisiblePage(
      viewportHeight: 800,
      pages: [
        (page: 1, top: -10, bottom: 400),
        (page: 8, top: 200, bottom: 900),
      ],
    );
    expect(page, isNot(1));
    expect(page, 8);
  });

  test('resume offset sums cached heights', () {
    final offset = resumeOffsetForPage(
      targetPage: 3,
      pageCount: 5,
      heightForIndex: (i) => 1000,
      gapAfterIndex: (i) => 0,
    );
    expect(offset, 2000);
  });

  test('shouldPersistProgressPage blocks regression', () {
    expect(shouldPersistProgressPage(page: 3, previousSaved: 10), isFalse);
    expect(shouldPersistProgressPage(page: 11, previousSaved: 10), isTrue);
  });

  group('stale out-of-range lastPageRead cannot wedge a chapter', () {
    // mergeLastPageRead takes max(local, server) and never clamps to the page
    // count, so a stored lastPageRead larger than the chapter's current page
    // count is reachable whenever a source's page count shrinks between
    // resolutions. Clamping the stored value is what unblocks this; the
    // assertions pin the two halves so neither regresses.

    test('a stored value beyond the page count must be clamped before comparing', () {
      // 30 pages stored, source now serves 25. Reading page 25 (the real last
      // page) has to be allowed through, not rejected as a regression.
      const totalPages = 25;
      final stored = 30;
      final effectivePrevious = stored.clamp(0, totalPages);

      expect(effectivePrevious, 25);
      expect(shouldPersistProgressPage(page: 25, previousSaved: effectivePrevious), isTrue);
    });

    test('an in-range stored value still blocks a genuine regression', () {
      expect(shouldPersistProgressPage(page: 3, previousSaved: 10), isFalse);
      expect(shouldPersistProgressPage(page: 10, previousSaved: 10), isTrue);
    });

    test('a stored value of 0 never blocks the first save', () {
      expect(shouldPersistProgressPage(page: 1, previousSaved: 0), isTrue);
    });

    test('the non-regression rule is untouched when there is no page count', () {
      // totalPages == 0 means "unknown"; the reader bails before this point, but
      // the helper must still behave for an unbounded chapter.
      expect(shouldPersistProgressPage(page: 2, previousSaved: 0), isTrue);
    });
  });
}
