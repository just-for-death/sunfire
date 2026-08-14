import 'package:catalyst/src/constants/enum.dart';
import 'package:catalyst/src/features/library/presentation/library/controller/library_filter_utils.dart';
import 'package:catalyst/src/features/manga_book/domain/chapter/graphql/__generated__/fragment.graphql.dart';
import 'package:catalyst/src/features/manga_book/domain/manga/graphql/__generated__/fragment.graphql.dart';
import 'package:catalyst/src/features/manga_book/domain/manga/manga_model.dart';
import 'package:catalyst/src/graphql/__generated__/schema.graphql.dart';
import 'package:flutter_test/flutter_test.dart';

MangaDto _manga({
  int id = 1,
  String title = 'Manga',
  int unreadCount = 0,
  int downloadCount = 0,
  Enum$MangaStatus status = Enum$MangaStatus.ONGOING,
  int inLibraryAt = 0,
  String? latestFetchedAt,
}) =>
    Fragment$MangaDto(
      downloadCount: downloadCount,
      genre: const [],
      id: id,
      inLibrary: true,
      inLibraryAt: inLibraryAt.toString(),
      initialized: true,
      meta: const [],
      sourceId: '1',
      status: status,
      title: title,
      unreadCount: unreadCount,
      updateStrategy: Enum$UpdateStrategy.ALWAYS_UPDATE,
      url: '',
      latestFetchedChapter: latestFetchedAt == null
          ? null
          : Fragment$ChapterDto(
              chapterNumber: 1,
              fetchedAt: latestFetchedAt,
              id: 1,
              isBookmarked: false,
              isDownloaded: false,
              isRead: false,
              lastPageRead: 0,
              lastReadAt: '0',
              mangaId: id,
              name: 'Ch 1',
              pageCount: 1,
              sourceOrder: 1,
              uploadDate: '0',
              url: '',
              meta: const [],
            ),
    );

bool _passes(
  MangaDto manga, {
  bool? unread,
  bool? downloaded,
  bool? completed,
  String? query,
  Set<int> offlineIds = const {},
}) =>
    libraryMangaPassesFilter(
      manga,
      filterUnread: unread,
      filterDownloaded: downloaded,
      filterCompleted: completed,
      query: query,
      offlineMangaIds: offlineIds,
    );

void main() {
  group('library filters are tri-state', () {
    final withUnread = _manga(unreadCount: 3);
    final allRead = _manga(unreadCount: 0);

    test('null shows everything', () {
      expect(_passes(withUnread), isTrue);
      expect(_passes(allRead), isTrue);
    });

    test('true keeps only unread', () {
      expect(_passes(withUnread, unread: true), isTrue);
      expect(_passes(allRead, unread: true), isFalse);
    });

    test('false excludes unread, keeping fully read titles', () {
      expect(_passes(withUnread, unread: false), isFalse);
      expect(_passes(allRead, unread: false), isTrue);
    });
  });

  group('downloaded filter', () {
    final serverDownloads = _manga(id: 1, downloadCount: 2);
    final noDownloads = _manga(id: 2);

    test('true keeps titles with server downloads', () {
      expect(_passes(serverDownloads, downloaded: true), isTrue);
      expect(_passes(noDownloads, downloaded: true), isFalse);
    });

    test('offline downloads count as downloaded', () {
      expect(
        _passes(noDownloads, downloaded: true, offlineIds: {2}),
        isTrue,
      );
    });

    test('false keeps only titles with nothing downloaded', () {
      expect(_passes(serverDownloads, downloaded: false), isFalse);
      expect(_passes(noDownloads, downloaded: false), isTrue);
      expect(
        _passes(noDownloads, downloaded: false, offlineIds: {2}),
        isFalse,
      );
    });
  });

  group('completed filter', () {
    final done = _manga(status: Enum$MangaStatus.COMPLETED);
    final ongoing = _manga(status: Enum$MangaStatus.ONGOING);

    test('true keeps only completed', () {
      expect(_passes(done, completed: true), isTrue);
      expect(_passes(ongoing, completed: true), isFalse);
    });

    test('false excludes completed', () {
      expect(_passes(done, completed: false), isFalse);
      expect(_passes(ongoing, completed: false), isTrue);
    });
  });

  test('filters combine', () {
    final manga = _manga(unreadCount: 2, downloadCount: 1);

    expect(_passes(manga, unread: true, downloaded: true), isTrue);
    expect(_passes(manga, unread: true, downloaded: false), isFalse);
  });

  test('search query applies alongside filters', () {
    final manga = _manga(title: 'Berserk', unreadCount: 1);

    expect(_passes(manga, query: 'ber'), isTrue);
    expect(_passes(manga, query: 'naruto'), isFalse);
    expect(_passes(manga, query: 'ber', unread: false), isFalse);
  });

  group('library sorting', () {
    List<String> sortedTitles(
      List<MangaDto> list, {
      MangaSort by = MangaSort.alphabetical,
      bool ascending = true,
    }) {
      final copy = [...list]..sort(
          (a, b) => compareLibraryManga(a, b, sortedBy: by, ascending: ascending),
        );
      return copy.map((m) => m.title).toList();
    }

    test('alphabetical ignores case', () {
      // Code-unit ordering would put every capitalised title first.
      final list = [
        _manga(id: 1, title: 'banana'),
        _manga(id: 2, title: 'Apple'),
        _manga(id: 3, title: 'cherry'),
        _manga(id: 4, title: 'Date'),
      ];

      expect(sortedTitles(list), ['Apple', 'banana', 'cherry', 'Date']);
    });

    test('descending reverses the order', () {
      final list = [
        _manga(id: 1, title: 'banana'),
        _manga(id: 2, title: 'Apple'),
      ];

      expect(sortedTitles(list, ascending: false), ['banana', 'Apple']);
    });

    test('sorts by unread count', () {
      final list = [
        _manga(id: 1, title: 'few', unreadCount: 1),
        _manga(id: 2, title: 'many', unreadCount: 9),
      ];

      expect(sortedTitles(list, by: MangaSort.unread), ['few', 'many']);
    });

    test('last updated treats fetchedAt as seconds', () {
      final list = [
        _manga(id: 1, title: 'older', latestFetchedAt: '1000'),
        _manga(id: 2, title: 'newer', latestFetchedAt: '2000'),
      ];

      expect(sortedTitles(list, by: MangaSort.lastUpdated), ['older', 'newer']);
    });

    test('missing fetchedAt sorts as oldest rather than throwing', () {
      final list = [
        _manga(id: 1, title: 'known', latestFetchedAt: '1000'),
        _manga(id: 2, title: 'unknown'),
      ];

      expect(sortedTitles(list, by: MangaSort.lastUpdated), ['unknown', 'known']);
    });
  });

  group('parseFetchedAt', () {
    test('converts a unix seconds timestamp to milliseconds', () {
      expect(parseFetchedAt('1710500000'), 1710500000 * 1000);
    });

    test('accepts an ISO-8601 date', () {
      expect(
        parseFetchedAt('2024-03-15T10:30:00'),
        DateTime.parse('2024-03-15T10:30:00').millisecondsSinceEpoch,
      );
    });

    test('falls back to 0 for null, empty or malformed input', () {
      expect(parseFetchedAt(null), 0);
      expect(parseFetchedAt(''), 0);
      expect(parseFetchedAt('not-a-date'), 0);
    });
  });
}
