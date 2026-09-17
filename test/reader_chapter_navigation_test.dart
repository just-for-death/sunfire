import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/db/models/chapter.dart';
import 'package:sunfire/src/features/reader/reader_chapter_navigation.dart';
import 'package:sunfire/src/features/reader/reader_scroll_utils.dart';

Chapter chapter({
  int id = 0,
  int serverId = 0,
  int mangaId = 1,
  String name = '',
  double chapterNumber = 0,
  String url = '',
  bool isRead = false,
  bool isDownloadedLocally = false,
  int uploadDate = 0,
}) {
  return Chapter()
    ..id = id
    ..serverId = serverId
    ..mangaId = mangaId
    ..name = name
    ..chapterNumber = chapterNumber
    ..url = url
    ..isRead = isRead
    ..isDownloadedLocally = isDownloadedLocally
    ..uploadDate = uploadDate;
}

void main() {
  group('chapterSortNumber (what the "next chapter" order is based on)', () {
    test('uses the explicit chapterNumber when set', () {
      expect(chapterSortNumber(chapter(chapterNumber: 12)), 12);
      expect(chapterSortNumber(chapter(chapterNumber: 4.5)), 4.5);
    });

    test('parses common source name formats', () {
      expect(chapterSortNumber(chapter(name: 'Chapter 12')), 12);
      expect(chapterSortNumber(chapter(name: 'Ch. 4.5')), 4.5);
      expect(chapterSortNumber(chapter(name: 'Episode 7')), 7);
      expect(chapterSortNumber(chapter(name: 'Ep. 100')), 100);
      expect(chapterSortNumber(chapter(name: '#3')), 3);
      expect(chapterSortNumber(chapter(name: 'One Piece 1021')), 1021);
    });

    test('falls back to 0 for unparseable names', () {
      expect(chapterSortNumber(chapter(name: 'Special Bonus')), 0);
      expect(chapterSortNumber(chapter(name: '')), 0);
    });
  });

  group('sortSiblingChapters (mimics reader next/prev resolution)', () {
    test('reverses the source newest-first order into reading order', () {
      // Real sites list newest at the top: 5, 4, 3, 2, 1.
      final newestFirst = [
        chapter(id: 5, name: 'Chapter 5', chapterNumber: 5),
        chapter(id: 4, name: 'Chapter 4', chapterNumber: 4),
        chapter(id: 3, name: 'Chapter 3', chapterNumber: 3),
        chapter(id: 2, name: 'Chapter 2', chapterNumber: 2),
        chapter(id: 1, name: 'Chapter 1', chapterNumber: 1),
      ];
      final sorted = sortSiblingChapters(newestFirst);
      expect(sorted.first.id, 1);
      expect(sorted.last.id, 5);
    });

    test('mixes explicit numbers and name-parsed numbers in one list', () {
      final list = [
        chapter(id: 2, name: 'Chapter 2', chapterNumber: 2),
        chapter(id: 99, name: 'Chapter 99'), // no explicit number → parsed from name
        chapter(id: 1, name: 'Chapter 1', chapterNumber: 1),
        chapter(id: 50, name: 'Chapter 50', chapterNumber: 50),
      ];
      final sorted = sortSiblingChapters(list);
      // Sort order follows the resolved reading number: 1, 2, 50, 99
      // (the name-parsed "Chapter 99" lands between 50 and any >99 chapter).
      expect(sorted.map((c) => c.id).toList(), [1, 2, 50, 99]);
    });

    test('equal numbers break ties by name so order is deterministic', () {
      final list = [
        chapter(id: 2, name: 'Chapter 1 (Redraw)', chapterNumber: 1),
        chapter(id: 1, name: 'Chapter 1', chapterNumber: 1),
      ];
      final sorted = sortSiblingChapters(list);
      expect(sorted.map((c) => c.id).toList(), [1, 2]);
    });

    test('does not mutate the caller list', () {
      final list = [
        chapter(id: 2, chapterNumber: 2),
        chapter(id: 1, chapterNumber: 1),
      ];
      sortSiblingChapters(list);
      expect(list.map((c) => c.id).toList(), [2, 1]);
    });
  });

  group('findSiblingChapterIndex (identifies the chapter being read)', () {
    final sorted = [
      chapter(id: 1, serverId: 100, name: 'Chapter 1', url: '/ch1', chapterNumber: 1),
      chapter(id: 2, serverId: 101, name: 'Chapter 2', url: '/ch2', chapterNumber: 2),
      chapter(id: 3, serverId: 102, name: 'Chapter 3', url: '/ch3', chapterNumber: 3),
    ];

    test('matches by serverId (server-sourced chapters)', () {
      expect(findSiblingChapterIndex(sorted, chapter(serverId: 101, chapterNumber: 2)), 1);
    });

    test('matches by id (locally-imported chapters)', () {
      expect(findSiblingChapterIndex(sorted, chapter(id: 3, chapterNumber: 3)), 2);
    });

    test('matches by url when ids are unknown', () {
      expect(findSiblingChapterIndex(sorted, chapter(url: '/ch1', chapterNumber: 1)), 0);
    });

    test('matches by trimmed name as a last resort', () {
      expect(findSiblingChapterIndex(sorted, chapter(name: '  Chapter 2  ', chapterNumber: 2)), 1);
    });

    test('returns -1 when the chapter is not in the list (no reliable next/prev)', () {
      expect(findSiblingChapterIndex(sorted, chapter(id: 99, name: 'Unknown')), -1);
    });
  });

  group('siblingChapterAt (next/previous selection)', () {
    final sorted = [
      chapter(id: 1, chapterNumber: 1),
      chapter(id: 2, chapterNumber: 2),
      chapter(id: 3, chapterNumber: 3),
    ];

    test('offset +1 is the next chapter', () {
      expect(siblingChapterAt(sorted, 0, 1)?.id, 2);
      expect(siblingChapterAt(sorted, 1, 1)?.id, 3);
    });

    test('offset -1 is the previous chapter', () {
      expect(siblingChapterAt(sorted, 2, -1)?.id, 2);
      expect(siblingChapterAt(sorted, 1, -1)?.id, 1);
    });

    test('out-of-range yields null (first/last chapter)', () {
      expect(siblingChapterAt(sorted, 2, 1), isNull);
      expect(siblingChapterAt(sorted, 0, -1), isNull);
      expect(siblingChapterAt(sorted, -1, 1), isNull);
    });
  });

  group('shouldShowEndOfChapterDialog (Mihon-style popup gating)', () {
    test('shows once per chapter when enabled', () {
      expect(
        shouldShowEndOfChapterDialog(
          enabled: true,
          hasPages: true,
          lastDialogChapterId: null,
          chapterId: 5,
        ),
        isTrue,
      );
      expect(
        shouldShowEndOfChapterDialog(
          enabled: true,
          hasPages: true,
          lastDialogChapterId: 5, // already shown for this chapter
          chapterId: 5,
        ),
        isFalse,
      );
      expect(
        shouldShowEndOfChapterDialog(
          enabled: true,
          hasPages: true,
          lastDialogChapterId: 4, // different chapter → can show again
          chapterId: 5,
        ),
        isTrue,
      );
    });

    test('blocked when the user disables it or the chapter has no pages', () {
      expect(
        shouldShowEndOfChapterDialog(enabled: false, hasPages: true, lastDialogChapterId: null, chapterId: 1),
        isFalse,
      );
      expect(
        shouldShowEndOfChapterDialog(enabled: true, hasPages: false, lastDialogChapterId: null, chapterId: 1),
        isFalse,
      );
    });
  });

  group('reader scroll utilities (end-of-chapter progress semantics)', () {
    test('progress never regresses once a later page is saved', () {
      expect(shouldPersistProgressPage(page: 3, previousSaved: 10), isFalse);
      expect(shouldPersistProgressPage(page: 10, previousSaved: 10), isTrue);
      expect(shouldPersistProgressPage(page: 12, previousSaved: 10), isTrue);
    });

    test('invalid page values are rejected', () {
      expect(shouldPersistProgressPage(page: 0, previousSaved: 0), isFalse);
    });

    test('resume offset accumulates page heights and gaps in order', () {
      final offset = resumeOffsetForPage(
        targetPage: 4,
        pageCount: 10,
        heightForIndex: (i) => 100 * (i + 1),
        gapAfterIndex: (i) => 5,
      );
      // pages 0..2 heights 100+200+300 = 600, gaps 5*3 = 15
      expect(offset, 615);
    });

    test('resume offset for first page or empty list is zero', () {
      expect(
        resumeOffsetForPage(targetPage: 1, pageCount: 5, heightForIndex: (_) => 100, gapAfterIndex: (_) => 0),
        0,
      );
      expect(
        resumeOffsetForPage(targetPage: 2, pageCount: 0, heightForIndex: (_) => 100, gapAfterIndex: (_) => 0),
        0,
      );
    });
  });
}