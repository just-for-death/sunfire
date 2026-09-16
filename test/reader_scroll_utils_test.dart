
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
}
