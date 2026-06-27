import 'package:catalyst/src/features/manga_book/domain/chapter/chapter_model.dart';
import 'package:catalyst/src/features/manga_book/domain/chapter/graphql/__generated__/fragment.graphql.dart';
import 'package:catalyst/src/features/manga_book/presentation/manga_details/chapter_navigation_utils.dart';
import 'package:flutter_test/flutter_test.dart';

ChapterDto _ch(int id, {double number = 0}) => Fragment$ChapterDto(
      chapterNumber: number == 0 ? id.toDouble() : number,
      fetchedAt: '0',
      id: id,
      isBookmarked: false,
      isDownloaded: false,
      isRead: false,
      lastPageRead: 0,
      lastReadAt: '0',
      mangaId: 1,
      name: 'Ch $id',
      pageCount: 10,
      sourceOrder: id,
      uploadDate: '0',
      url: '',
      meta: const [],
    );

void main() {
  group('chapter navigation reading order', () {
    test('ascending list: forward is next index', () {
      final list = [_ch(1), _ch(2), _ch(3)];
      expect(
        chapterForwardInReadingOrder(list, 1, listAscending: true)?.id,
        3,
      );
      expect(
        chapterBackwardInReadingOrder(list, 1, listAscending: true)?.id,
        1,
      );
    });

    test('descending list: forward is toward higher chapter numbers', () {
      final list = [_ch(3), _ch(2), _ch(1)];
      expect(
        chapterForwardInReadingOrder(list, 1, listAscending: false)?.id,
        3,
      );
      expect(
        chapterBackwardInReadingOrder(list, 1, listAscending: false)?.id,
        1,
      );
    });

    test('filtered navigation skips hidden chapters', () {
      final list = [_ch(1), _ch(2), _ch(3), _ch(4)];
      bool unreadOnly(ChapterDto c) => c.id.isOdd;

      expect(
        chapterForwardInReadingOrderFiltered(
          list,
          1,
          listAscending: true,
          passesFilter: unreadOnly,
        )?.id,
        3,
      );
      expect(
        chapterBackwardInReadingOrderFiltered(
          list,
          2,
          listAscending: true,
          passesFilter: unreadOnly,
        )?.id,
        1,
      );
    });

    test('filtered navigation returns null when no match ahead', () {
      final list = [_ch(1), _ch(2)];
      expect(
        chapterForwardInReadingOrderFiltered(
          list,
          1,
          listAscending: true,
          passesFilter: (_) => false,
        ),
        isNull,
      );
    });
  });
}
