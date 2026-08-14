import 'package:catalyst/src/features/history/domain/history_group.dart';
import 'package:catalyst/src/features/history/domain/history_item.dart';
import 'package:catalyst/src/features/history/presentation/history_reader_navigation.dart';
import 'package:catalyst/src/features/manga_book/domain/chapter/graphql/__generated__/fragment.graphql.dart';
import 'package:catalyst/src/features/manga_book/domain/manga/graphql/__generated__/fragment.graphql.dart';
import 'package:catalyst/src/graphql/__generated__/schema.graphql.dart';
import 'package:flutter_test/flutter_test.dart';

Fragment$MangaBaseDto _manga(int id, String title) => Fragment$MangaBaseDto(
      genre: const [],
      id: id,
      inLibrary: true,
      inLibraryAt: '0',
      initialized: true,
      meta: const [],
      sourceId: '1',
      status: Enum$MangaStatus.ONGOING,
      title: title,
      unreadCount: 0,
      updateStrategy: Enum$UpdateStrategy.ALWAYS_UPDATE,
      url: '',
    );


HistoryItemDto _item({
  required int id,
  required int mangaId,
  required String title,
  required int lastPageRead,
  required int pageCount,
  required bool isRead,
}) =>
    Fragment$ChapterWithMangaDto(
      id: id,
      mangaId: mangaId,
      manga: _manga(mangaId, title),
      name: 'Ch $id',
      chapterNumber: id.toDouble(),
      lastPageRead: lastPageRead,
      pageCount: pageCount,
      isRead: isRead,
      fetchedAt: '0',
      isBookmarked: false,
      isDownloaded: false,
      lastReadAt: '0',
      sourceOrder: id,
      uploadDate: '0',
      url: '',
      meta: const [],
    );

void main() {
  group('historyItemIsCompleted', () {
    test('returns true when isRead flag is set', () {
      final item = _item(
        id: 1,
        mangaId: 10,
        title: 'Test',
        lastPageRead: 0,
        pageCount: 20,
        isRead: true,
      );
      expect(historyItemIsCompleted(item), isTrue);
    });

    test('returns true when lastPageRead reaches the last page', () {
      final item = _item(
        id: 1,
        mangaId: 10,
        title: 'Test',
        lastPageRead: 19,
        pageCount: 20,
        isRead: false,
      );
      expect(historyItemIsCompleted(item), isTrue);
    });

    test('returns false when chapter is partially read', () {
      final item = _item(
        id: 1,
        mangaId: 10,
        title: 'Test',
        lastPageRead: 5,
        pageCount: 20,
        isRead: false,
      );
      expect(historyItemIsCompleted(item), isFalse);
    });

    test('returns false when pageCount is zero and isRead is false', () {
      final item = _item(
        id: 1,
        mangaId: 10,
        title: 'Test',
        lastPageRead: 0,
        pageCount: 0,
        isRead: false,
      );
      expect(historyItemIsCompleted(item), isFalse);
    });
  });

  group('historyItemReadProgress', () {
    test('returns 1.0 for completed item', () {
      final item = _item(
        id: 1,
        mangaId: 10,
        title: 'Test',
        lastPageRead: 5,
        pageCount: 20,
        isRead: true,
      );
      expect(historyItemReadProgress(item), 1.0);
    });

    test('returns 0.0 when pageCount is 0 or negative', () {
      final item = _item(
        id: 1,
        mangaId: 10,
        title: 'Test',
        lastPageRead: 0,
        pageCount: 0,
        isRead: false,
      );
      expect(historyItemReadProgress(item), 0.0);
    });

    test('calculates correct fraction for in-progress chapter', () {
      final item = _item(
        id: 1,
        mangaId: 10,
        title: 'Test',
        lastPageRead: 5,
        pageCount: 20,
        isRead: false,
      );
      expect(historyItemReadProgress(item), 0.25);
    });

    test('clamps progress value between 0.0 and 1.0', () {
      final itemNegative = _item(
        id: 1,
        mangaId: 10,
        title: 'Test',
        lastPageRead: -5,
        pageCount: 20,
        isRead: false,
      );
      expect(historyItemReadProgress(itemNegative), 0.0);
    });
  });

  group('inProgressHistoryItems', () {
    test('returns empty when all items are completed', () {
      final groups = [
        HistoryGroup(
          title: 'Today',
          items: [
            _item(
              id: 1,
              mangaId: 10,
              title: 'Test',
              lastPageRead: 10,
              pageCount: 10,
              isRead: true,
            ),
          ],
        ),
      ];
      expect(inProgressHistoryItems(groups), isEmpty);
    });

    test('filters and limits in-progress items to 10', () {
      final items = List.generate(
        15,
        (i) => _item(
          id: i,
          mangaId: 10,
          title: 'Test',
          lastPageRead: 2,
          pageCount: 20,
          isRead: false,
        ),
      );
      final groups = [HistoryGroup(title: 'Today', items: items)];
      final inProgress = inProgressHistoryItems(groups);
      expect(inProgress.length, 10);
      expect(inProgress.first.id, 0);
      expect(inProgress.last.id, 9);
    });
  });

  group('historyGroupsExcludingCarousel', () {
    test('returns empty for empty input', () {
      expect(historyGroupsExcludingCarousel(const []), isEmpty);
    });

    test('removes in-progress carousel items and drops empty groups', () {
      final inProgressItem = _item(
        id: 1,
        mangaId: 10,
        title: 'Test 1',
        lastPageRead: 2,
        pageCount: 20,
        isRead: false,
      );
      final completedItem = _item(
        id: 2,
        mangaId: 10,
        title: 'Test 2',
        lastPageRead: 20,
        pageCount: 20,
        isRead: true,
      );

      final groups = [
        HistoryGroup(title: 'Group 1', items: [inProgressItem]),
        HistoryGroup(title: 'Group 2', items: [completedItem]),
      ];

      final filtered = historyGroupsExcludingCarousel(groups);
      expect(filtered.length, 1);
      expect(filtered.first.title, 'Group 2');
      expect(filtered.first.items.single.id, 2);
    });
  });
}


