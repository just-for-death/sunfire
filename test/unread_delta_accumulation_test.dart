// Unread-badge delta accumulation.
//
// WHY THIS EXISTS
//
// Marking a chapter read in the Updates feed adjusts the parent series' unread
// badge. The original code was a bare read-modify-write with no serialisation,
// and its callers are fire-and-forget (a per-row IconButton), so double-tapping
// two chapters of one series had both invocations read the same `unreadCount`,
// both compute n-1, and one write was lost — a silent, permanent, one-way drift
// of the most-visible number in the app.
//
// The fix accumulated deltas and drained them under a per-manga lock. That fix
// was then itself broken, in the most embarrassing possible way: the drain read
// the accumulator AFTER clearing it, with no `await` in between, so the value
// was structurally guaranteed to be 0, the loop broke on its first iteration,
// and `saveManga` was unreachable. Every badge update was discarded — strictly
// worse than the race it replaced — and 700 tests were green throughout.
//
// The lesson is that "snapshot then clear" is not a detail you can inline and
// eyeball. It is now a named function with a test, because the failure mode is
// invisible to every other kind of test: the code compiles, the types are right,
// and the wrong value flows silently into a correct-looking write.
//
// Run: fvm flutter test test/unread_delta_accumulation_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/features/updates/updates_screen.dart';

void main() {
  group('takePendingUnreadDelta', () {
    test('returns the accumulated value and resets to zero', () {
      final pending = <int, int>{7: 3};
      expect(takePendingUnreadDelta(pending, 7), 3);
      expect(pending[7], 0, reason: 'the accumulator must be left clean');
    });

    test('returns 0 for a manga with nothing pending', () {
      final pending = <int, int>{};
      expect(takePendingUnreadDelta(pending, 7), 0);
    });

    test('READS BEFORE CLEARING — the invariant the last bug inverted', () {
      // The whole reason this is a tested function. Written inline as
      // "clear, then read", there is no await between the two statements, so
      // the read returns 0 and every delta is discarded.
      final pending = <int, int>{};
      pending[7] = (pending[7] ?? 0) + 2;
      pending[7] = pending[7]! + 3; // total 5

      // Correct order: the value comes back.
      expect(takePendingUnreadDelta(pending, 7), 5);

      // And the inverted order — the bug — returns 0. Asserted explicitly so
      // the contrast is on the record rather than only in a comment.
      final inverted = <int, int>{7: 5};
      inverted[7] = 0;
      expect(takePendingUnreadDelta(inverted, 7), 0);
    });

    test('repeated takes drain to exactly zero, never negative', () {
      final pending = <int, int>{7: 4};
      var total = 0;
      for (var i = 0; i < 10; i++) {
        total += takePendingUnreadDelta(pending, 7);
      }
      expect(total, 4, reason: 'a drain loop must consume the batch exactly once');
    });

    test('deltas arriving between takes are not lost and not double-counted', () {
      // Models the real race: a second tap lands while the first drain is
      // awaiting Isar. It must start a fresh batch and be applied next round.
      final pending = <int, int>{};

      pending[7] = (pending[7] ?? 0) + 1; // first tap
      final batch1 = takePendingUnreadDelta(pending, 7);
      expect(batch1, 1);

      pending[7] = (pending[7] ?? 0) + 1; // second tap, during the first write
      final batch2 = takePendingUnreadDelta(pending, 7);
      expect(batch2, 1);

      expect(batch1 + batch2, 2, reason: 'two taps must total two');
      expect(pending[7], 0, reason: 'nothing left stranded');
    });
  });

  group('drain sequencing invariants', () {
    // These assert the arithmetic the drain loop relies on, without needing a
    // live Isar: that a sequence of taps coalesces correctly and that the
    // accumulator is always empty once the loop exits.
    test('a burst of taps coalesces to their sum', () {
      final pending = <int, int>{42: 0};
      const taps = [-1, -1, -1, 1];
      for (final d in taps) {
        pending[42] = (pending[42] ?? 0) + d;
      }
      expect(takePendingUnreadDelta(pending, 42), -2);
      expect(takePendingUnreadDelta(pending, 42), 0);
    });

    test('different manga are isolated', () {
      // The lock is per-manga, so one series' drain must never consume another's
      // batch — that would silently credit a decrement to the wrong series.
      final pending = <int, int>{1: 2, 2: 5};
      expect(takePendingUnreadDelta(pending, 1), 2);
      expect(pending[2], 5, reason: 'draining series 1 must not touch series 2');
      expect(takePendingUnreadDelta(pending, 2), 5);
    });

    test('the accumulator ends at zero for every touched manga', () {
      // The stranded-delta guard in the drain's `finally` depends on this: it
      // takes the residual and re-enters if non-zero, so a non-zero residual is
      // what triggers a follow-up pass. If a take ever left a non-zero value
      // behind, that guard would spin.
      final pending = <int, int>{};
      for (final id in [1, 2, 3]) {
        pending[id] = id * 2;
      }
      for (final id in [1, 2, 3]) {
        takePendingUnreadDelta(pending, id);
      }
      for (final entry in pending.entries) {
        expect(entry.value, 0, reason: 'manga ${entry.key} left a residual');
      }
    });
  });
}
