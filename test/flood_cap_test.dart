// Tests for the unified flood gate.
//
// Before this, the flood cap existed only at DISPLAY time, in two places, with
// a third unrelated threshold (> 3) in cleanupBulkScrapedUpdates, and the two
// local-scrape ingestion paths disagreed about whether to stamp fetchedAt at
// all. So one bulk import could make the Library tile read "~400 unread" and a
// notification announce "400 new chapters are now available" while the Updates
// feed showed 3 — two screens reporting contradictory facts about the same
// batch, only reconciled at the next cold launch.
//
// Run: fvm flutter test test/flood_cap_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/db/models/chapter.dart';

Chapter _ch(int n) =>
    Chapter()
      // Real chapters carry positive ids; 0 is Isar's "not yet persisted"
      // sentinel and would be replaced by saveChapters, so start at 1.
      ..serverId = n + 1
      ..mangaId = 1
      ..name = 'Chapter $n'
      ..url = 'https://src/ch/$n';

List<Chapter> _batch(int n) => [for (var i = 0; i < n; i++) _ch(i)];

bool _isInFeed(Chapter c) => (c.fetchedAt ?? 0) > 0;

void main() {
  group('applyFloodCapToNewChapters — first import', () {
    test('a whole first import stays out of the feed', () {
      final batch = _batch(400);
      applyFloodCapToNewChapters(batch, isFirstImport: true);
      expect(batch.where(_isInFeed), isEmpty);
    });

    test('a first import of a single chapter also stays out', () {
      final batch = _batch(1);
      applyFloodCapToNewChapters(batch, isFirstImport: true);
      expect(batch.single.fetchedAt, 0);
    });

    test('a first import still marks the chapters as real chapters', () {
      // They must remain readable in the series' chapter list and count
      // towards unread — only the feed timestamp is withheld.
      final batch = _batch(5);
      applyFloodCapToNewChapters(batch, isFirstImport: true);
      for (final c in batch) {
        expect(c.url, isNotEmpty);
        expect(c.serverId, isNot(0));
        expect(c.isRead, isFalse);
      }
    });
  });

  group('applyFloodCapToNewChapters — later batches', () {
    test('a small batch is untouched (all enter the feed)', () {
      final batch = _batch(kFloodThresholdChapters);
      applyFloodCapToNewChapters(batch, isFirstImport: false);
      expect(batch.where(_isInFeed), hasLength(kFloodThresholdChapters));
    });

    test('a batch at the threshold is still not capped', () {
      // `> threshold` is the trigger, so exactly-at-threshold passes whole.
      final batch = _batch(kFloodThresholdChapters);
      applyFloodCapToNewChapters(batch, isFirstImport: false);
      expect(batch.every(_isInFeed), isTrue);
    });

    test('a flooded batch keeps only the newest kFloodCapChapters in the feed', () {
      final batch = _batch(400);
      applyFloodCapToNewChapters(batch, isFirstImport: false);
      expect(batch.where(_isInFeed), hasLength(kFloodCapChapters));
    });

    test('the survivors are the newest (the front of the list)', () {
      // Sources return newest-first, so the feed must keep the front.
      final batch = _batch(20);
      applyFloodCapToNewChapters(batch, isFirstImport: false);
      final inFeed = batch.where(_isInFeed).toList();
      expect(inFeed.map((c) => c.name), ['Chapter 0', 'Chapter 1', 'Chapter 2']);
      expect(batch.skip(kFloodCapChapters).every((c) => !_isInFeed(c)), isTrue);
    });

    test('the cap keeps the Library unread count and the feed consistent', () {
      // The whole point: the tile counts every saved chapter, while the feed
      // shows at most kFloodCapChapters. That is still a mismatch, but it is
      // the *documented* one — a bulk import legitimately has many unread
      // chapters, it just must not push all of them into the feed.
      final batch = _batch(400);
      applyFloodCapToNewChapters(batch, isFirstImport: false);
      expect(batch, hasLength(400), reason: 'all chapters still saved');
      expect(batch.where(_isInFeed), hasLength(kFloodCapChapters));
    });
  });

  group('applyFloodCapToNewChapters — display cap agrees with ingestion', () {
    // The two caps exist in updates_screen.dart. They must not drift, or the
    // ingestion gate would hide chapters the display layer would have shown.
    test('the ingestion cap equals the display cap', () {
      // Mirrors: isFlooded = totalForManga > kFloodThresholdChapters;
      //           if (isFlooded && added >= kFloodCapChapters) continue;
      final batch = _batch(400);
      applyFloodCapToNewChapters(batch, isFirstImport: false);

      final mangaCounts = <int, int>{};
      for (final c in batch) {
        mangaCounts[c.mangaId] = (mangaCounts[c.mangaId] ?? 0) + 1;
      }
      final totalForManga = mangaCounts[1] ?? 0;
      final isFlooded = totalForManga > kFloodThresholdChapters;

      var added = 0;
      var shownByDisplayLayer = 0;
      for (final c in batch) {
        if (isFlooded && added >= kFloodCapChapters) {
          // Display layer skips it; ingestion already zeroed its timestamp.
          expect(c.fetchedAt, 0, reason: 'display-skipped chapters must be out of the feed');
          continue;
        }
        added++;
        if (_isInFeed(c)) shownByDisplayLayer++;
      }
      expect(shownByDisplayLayer, kFloodCapChapters);
    });

    test('a non-flooded batch passes through the display cap unchanged', () {
      final batch = _batch(3);
      applyFloodCapToNewChapters(batch, isFirstImport: false);
      final mangaCounts = <int, int>{1: batch.length};
      final isFlooded = (mangaCounts[1] ?? 0) > kFloodThresholdChapters;
      expect(isFlooded, isFalse);
      expect(batch.where(_isInFeed), hasLength(3));
    });
  });

  group('applyFloodCapToNewChapters — edge cases', () {
    test('an empty batch is a no-op', () {
      final batch = <Chapter>[];
      applyFloodCapToNewChapters(batch, isFirstImport: false);
      applyFloodCapToNewChapters(batch, isFirstImport: true);
      expect(batch, isEmpty);
    });

    test('stamps a plausible epoch-seconds timestamp', () {
      final batch = _batch(2);
      applyFloodCapToNewChapters(batch, isFirstImport: false);
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      // Allow a generous window; the point is seconds-not-millis, which the
      // getRecentChapters / cleanupBulkScrapedUpdates filters depend on.
      expect(batch.first.fetchedAt, greaterThan(now - 120));
      expect(batch.first.fetchedAt, lessThan(now + 5));
    });

    test('is idempotent on a non-flooded batch', () {
      final a = _batch(3);
      final b = _batch(3);
      applyFloodCapToNewChapters(a, isFirstImport: false);
      final first = a.map((c) => c.fetchedAt).toList();
      applyFloodCapToNewChapters(a, isFirstImport: false);
      expect(a.map((c) => c.fetchedAt).toList(), first);
      // A second, independent batch gets its own (possibly identical) stamp.
      applyFloodCapToNewChapters(b, isFirstImport: false);
      expect(b.where(_isInFeed), hasLength(3));
    });

    test('a chapter already stamped at 0 stays out of the feed', () {
      // Zeroed chapters must not be resurrected by a later pass over the same
      // list (e.g. if a caller retries with a partially-saved batch).
      final batch = _batch(400);
      applyFloodCapToNewChapters(batch, isFirstImport: false);
      final zeros = batch.where((c) => c.fetchedAt == 0).toList();
      expect(zeros, hasLength(400 - kFloodCapChapters));
    });
  });
}
