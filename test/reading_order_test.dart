import 'package:catalyst/src/features/manga_book/domain/chapter/chapter_model.dart';
import 'package:catalyst/src/features/manga_book/domain/chapter/graphql/__generated__/fragment.graphql.dart';
import 'package:catalyst/src/features/manga_book/presentation/manga_details/chapter_navigation_utils.dart';
import 'package:flutter_test/flutter_test.dart';

/// [sourceOrder] is the story order; `index` reads through to it.
ChapterDto _ch(int sourceOrder, {bool isRead = false}) => Fragment$ChapterDto(
      chapterNumber: sourceOrder.toDouble(),
      fetchedAt: '0',
      id: 1000 + sourceOrder,
      isBookmarked: false,
      isDownloaded: false,
      isRead: isRead,
      lastPageRead: 0,
      lastReadAt: '0',
      mangaId: 1,
      name: 'Ch $sourceOrder',
      pageCount: 10,
      sourceOrder: sourceOrder,
      uploadDate: '0',
      url: '',
      meta: const [],
    );

void main() {
  group('firstUnreadInReadingOrder', () {
    // The list handed to this helper is sorted for *display*, and the app
    // defaults to descending — the case that used to resume at the wrong place.
    test('descending list resumes at the earliest unread chapter', () {
      final displayed = [
        _ch(5),
        _ch(4),
        _ch(3),
        _ch(2, isRead: true),
        _ch(1, isRead: true),
      ];

      expect(firstUnreadInReadingOrder(displayed)?.index, 3);
    });

    test('ascending list resumes at the same chapter', () {
      final displayed = [
        _ch(1, isRead: true),
        _ch(2, isRead: true),
        _ch(3),
        _ch(4),
        _ch(5),
      ];

      expect(firstUnreadInReadingOrder(displayed)?.index, 3);
    });

    test('a gap in read chapters resumes at the earliest unread, not the last',
        () {
      final displayed = [
        _ch(4, isRead: true),
        _ch(3),
        _ch(2, isRead: true),
        _ch(1, isRead: true),
      ];

      expect(firstUnreadInReadingOrder(displayed)?.index, 3);
    });

    test('returns null when everything is read', () {
      final displayed = [_ch(2, isRead: true), _ch(1, isRead: true)];

      expect(firstUnreadInReadingOrder(displayed), isNull);
    });

    test('returns null for an empty list', () {
      expect(firstUnreadInReadingOrder(const []), isNull);
    });

    test('a fresh manga starts at the first chapter', () {
      final displayed = [_ch(3), _ch(2), _ch(1)];

      expect(firstUnreadInReadingOrder(displayed)?.index, 1);
    });
  });

  group('chaptersBeforeInReadingOrder', () {
    test('descending list returns the earlier chapters, not the newer ones',
        () {
      final displayed = [_ch(5), _ch(4), _ch(3), _ch(2), _ch(1)];

      final before = chaptersBeforeInReadingOrder(displayed, _ch(3));

      expect(before.map((c) => c.index), unorderedEquals([1, 2]));
    });

    test('ascending list returns the same chapters', () {
      final displayed = [_ch(1), _ch(2), _ch(3), _ch(4), _ch(5)];

      final before = chaptersBeforeInReadingOrder(displayed, _ch(3));

      expect(before.map((c) => c.index), unorderedEquals([1, 2]));
    });

    test('the first chapter has nothing before it', () {
      final displayed = [_ch(3), _ch(2), _ch(1)];

      expect(chaptersBeforeInReadingOrder(displayed, _ch(1)), isEmpty);
    });

    test('the selected chapter is never included', () {
      final displayed = [_ch(3), _ch(2), _ch(1)];

      final before = chaptersBeforeInReadingOrder(displayed, _ch(3));

      expect(before.map((c) => c.index), isNot(contains(3)));
    });

    test('only considers chapters present in the filtered list', () {
      // Chapter 2 is hidden by a filter, so it must not be marked read.
      final filtered = [_ch(4), _ch(3), _ch(1)];

      final before = chaptersBeforeInReadingOrder(filtered, _ch(4));

      expect(before.map((c) => c.index), unorderedEquals([1, 3]));
    });
  });
}
