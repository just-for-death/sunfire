import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/db/models/chapter.dart';
import 'package:sunfire/src/features/updates/updates_feed_grouping.dart';

void main() {
  group('mergeBulkFallback', () {
    test('keeps the primary pass when non-empty', () {
      expect(mergeBulkFallback([1], [2, 3], 10), [1]);
    });

    test('falls back to bulk rows capped at limit when primary is empty', () {
      expect(mergeBulkFallback<int>([], [1, 2, 3, 4], 2), [1, 2]);
    });

    test('empty when both are empty', () {
      expect(mergeBulkFallback<int>([], [], 10), isEmpty);
    });
  });

  group('updateCardKey', () {
    test('distinguishes visual state', () {
      final a = updateCardKey(
          chapterServerId: 5, mangaId: 9, isRead: false, isDownloaded: false);
      expect(
        updateCardKey(
            chapterServerId: 5,
            mangaId: 9,
            isRead: true,
            isDownloaded: false),
        isNot(a),
      );
      expect(
          a,
          updateCardKey(
              chapterServerId: 5,
              mangaId: 9,
              isRead: false,
              isDownloaded: false));
    });
  });

  group('sameFeedItems', () {
    Map<String, dynamic> row(String key) => {'key': key};

    test('identical key sequences match', () {
      expect(
        sameFeedItems([row('a'), row('b')], [row('a'), row('b')]),
        isTrue,
      );
    });

    test('length, order, and value differences mismatch', () {
      expect(sameFeedItems([row('a')], [row('a'), row('b')]), isFalse);
      expect(sameFeedItems([row('a'), row('b')], [row('b'), row('a')]), isFalse);
      expect(sameFeedItems([row('a')], [row('b')]), isFalse);
      expect(sameFeedItems([], []), isTrue);
    });
  });
}
