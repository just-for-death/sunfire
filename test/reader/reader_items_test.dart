// IMP-011 / IMP-012 regression tests: vertical paged mode and the
// multi-chapter webtoon item model with per-chapter progress mapping.
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/db/models/chapter.dart';
import 'package:sunfire/src/features/reader/controller/navigation_controller.dart';
import 'package:sunfire/src/features/reader/controller/position_manager.dart';
import 'package:sunfire/src/features/reader/reading_mode.dart';

Chapter _ch(int id) => Chapter()
  ..id = id
  ..name = 'Ch $id';

void main() {
  group('IMP-011 pagedVertical', () {
    test('is paged, vertical, parses and round-trips its settings value', () {
      expect(isPagedReadingMode(ReadingMode.pagedVertical), isTrue);
      expect(isWebtoonReadingMode(ReadingMode.pagedVertical), isFalse);
      expect(isVerticalPagedReadingMode(ReadingMode.pagedVertical), isTrue);
      expect(isVerticalPagedReadingMode(ReadingMode.pagedLtr), isFalse);
      for (final m in ReadingMode.values) {
        expect(parseReadingMode(readingModeSettingsValue(m)), m, reason: '$m');
      }
      expect(parseReadingMode('Vertical'), ReadingMode.pagedVertical);
      expect(readingModeHudLabel(ReadingMode.pagedVertical), 'VERT');
      expect(webtoonPageGap(ReadingMode.pagedVertical), 0.0);
    });
  });

  group('IMP-012 ReaderItem / chapterBoundary', () {
    final c1 = _ch(1), c2 = _ch(2), c3 = _ch(3);

    test('flattens chapters with boundaries between and after them', () {
      final items = buildReaderItems([
        ReaderChapterPages(c1, const ['a', 'b']),
        ReaderChapterPages(_ch(9), const []), // empty chapter skipped
        ReaderChapterPages(c2, const ['c']),
      ], trailingNext: c3);
      expect(items.length, 5);
      expect((items[1] as ReaderPageItem).pageIndex, 1);
      final b1 = items[2] as ReaderChapterBoundary;
      expect(b1.previous, same(c1));
      expect(b1.next, same(c2));
      final b2 = items[4] as ReaderChapterBoundary;
      expect(b2.previous, same(c2));
      expect(b2.next, same(c3));
      expect(nextChapterStartIndex(items, 0), 3);
      expect(nextChapterStartIndex(items, 3), -1);
    });

    test('progress goes to the chapter that owns the item, not the opened one', () {
      final items = buildReaderItems([
        ReaderChapterPages(c1, const ['a', 'b', 'c']),
        ReaderChapterPages(c2, const ['d', 'e']),
      ]);
      final p = PositionManager.progressTargetForItem(items, 5)!; // 'e'
      expect(p.chapter, same(c2));
      expect(p.page, 2);
      expect(p.totalPages, 2);
      final atBoundary = PositionManager.progressTargetForItem(items, 3)!;
      expect(atBoundary.chapter, same(c1));
      expect(atBoundary.page, 3);
      expect(atBoundary.totalPages, 3);
      expect(PositionManager.progressTargetForItem(items, -1), isNull);
      expect(PositionManager.progressTargetForItem(items, 99), isNull);
    });
  });
}
