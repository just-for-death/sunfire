import 'package:catalyst/src/constants/enum.dart';
import 'package:catalyst/src/features/manga_book/domain/chapter_page/chapter_page_model.dart';
import 'package:catalyst/src/features/manga_book/domain/chapter_page/graphql/__generated__/fragment.graphql.dart';
import 'package:catalyst/src/features/manga_book/presentation/reader/utils/last_page_swipe_utils.dart';
import 'package:flutter_test/flutter_test.dart';

ChapterPagesDto _pages({required int count}) {
  return Fragment$ChapterPagesDto(
    chapter: Fragment$ChapterPagesDto$chapter(
      id: 1,
      pageCount: count,
    ),
    pages: List.generate(count, (i) => 'page_$i'),
  );
}

void main() {
  group('LastPageSwipeUtils', () {
    test('isAtLastPage uses loaded pages length', () {
      final chapterPages = _pages(count: 5);
      expect(
        LastPageSwipeUtils.isAtLastPage(
          currentIndex: 4,
          chapterPages: chapterPages,
        ),
        isTrue,
      );
      expect(
        LastPageSwipeUtils.isAtLastPage(
          currentIndex: 3,
          chapterPages: chapterPages,
        ),
        isFalse,
      );
    });

    test('isAtLastPageReliable prefers loaded pages over metadata', () {
      final chapterPages = Fragment$ChapterPagesDto(
        chapter: const Fragment$ChapterPagesDto$chapter(
          id: 1,
          pageCount: 10,
        ),
        pages: List.generate(3, (i) => 'page_$i'),
      );

      expect(
        LastPageSwipeUtils.isAtLastPageReliable(
          currentIndex: 2,
          chapterPages: chapterPages,
        ),
        isTrue,
      );
      expect(
        LastPageSwipeUtils.isAtLastPageReliable(
          currentIndex: 5,
          chapterPages: chapterPages,
        ),
        isFalse,
      );
    });

    test('resolveActualReaderMode falls back to settings default', () {
      expect(
        LastPageSwipeUtils.resolveActualReaderMode(
          mangaReaderMode: ReaderMode.defaultReader,
          defaultReaderMode: ReaderMode.singleHorizontalLTR,
        ),
        ReaderMode.singleHorizontalLTR,
      );
      expect(
        LastPageSwipeUtils.resolveActualReaderMode(
          mangaReaderMode: null,
          defaultReaderMode: null,
        ),
        ReaderMode.webtoon,
      );
    });

    test('detectPagePosition identifies boundaries', () {
      final single = _pages(count: 1);
      expect(
        LastPageSwipeUtils.detectPagePosition(
          currentIndex: 0,
          chapterPages: single,
        ),
        PagePosition.singlePage,
      );

      final multi = _pages(count: 4);
      expect(
        LastPageSwipeUtils.detectPagePosition(
          currentIndex: 0,
          chapterPages: multi,
        ),
        PagePosition.firstPage,
      );
      expect(
        LastPageSwipeUtils.detectPagePosition(
          currentIndex: 3,
          chapterPages: multi,
        ),
        PagePosition.lastPage,
      );
    });
  });
}
