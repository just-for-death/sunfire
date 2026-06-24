import 'package:catalyst/src/constants/enum.dart';
import 'package:catalyst/src/features/manga_book/presentation/reader/utils/spread_page_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SpreadPageUtils', () {
    test('spreadCount pairs after solo cover', () {
      expect(SpreadPageUtils.spreadCount(1), 1);
      expect(SpreadPageUtils.spreadCount(2), 2);
      expect(SpreadPageUtils.spreadCount(3), 2);
      expect(SpreadPageUtils.spreadCount(4), 3);
      expect(SpreadPageUtils.spreadCount(5), 3);
    });

    test('spreadIndexForPage maps logical pages', () {
      expect(SpreadPageUtils.spreadIndexForPage(0), 0);
      expect(SpreadPageUtils.spreadIndexForPage(1), 1);
      expect(SpreadPageUtils.spreadIndexForPage(2), 1);
      expect(SpreadPageUtils.spreadIndexForPage(3), 2);
      expect(SpreadPageUtils.spreadIndexForPage(4), 2);
    });

    test('pagesInSpread returns cover alone then pairs', () {
      expect(SpreadPageUtils.pagesInSpread(0, 5), [0]);
      expect(SpreadPageUtils.pagesInSpread(1, 5), [1, 2]);
      expect(SpreadPageUtils.pagesInSpread(2, 5), [3, 4]);
      expect(SpreadPageUtils.pagesInSpread(2, 4), [3]);
    });

    test('shouldEnable respects mode and setting', () {
      expect(
        SpreadPageUtils.shouldEnable(
          setting: ReaderDoublePageSpread.auto,
          mode: ReaderMode.singleHorizontalLTR,
          isTablet: true,
          isLandscape: true,
        ),
        isTrue,
      );
      expect(
        SpreadPageUtils.shouldEnable(
          setting: ReaderDoublePageSpread.auto,
          mode: ReaderMode.webtoon,
          isTablet: true,
          isLandscape: true,
        ),
        isFalse,
      );
      expect(
        SpreadPageUtils.shouldEnable(
          setting: ReaderDoublePageSpread.never,
          mode: ReaderMode.singleHorizontalLTR,
          isTablet: true,
          isLandscape: true,
        ),
        isFalse,
      );
    });
    test('logicalPageForSpread uses trailing page in pair', () {
      expect(SpreadPageUtils.logicalPageForSpread(1, 5), 2);
      expect(SpreadPageUtils.logicalPageForSpread(2, 5), 4);
      expect(SpreadPageUtils.logicalPageForSpread(0, 5), 0);
    });

    test('pagesInSpread ignores negative spread index', () {
      expect(SpreadPageUtils.pagesInSpread(-1, 5), isEmpty);
    });
  });
}
