// Tests for epoch-unit normalisation.
//
// Every timestamp in local storage is EPOCH SECONDS — all local writers use
// `DateTime.now().millisecondsSinceEpoch ~/ 1000`. A JS/Node GraphQL server is
// just as likely to send `Date.now()`, i.e. epoch MILLISECONDS.
//
// Taking such a value verbatim does not throw; it silently stores a timestamp
// ~1000x in the future, which then sorts permanently to one end of any
// date-ordered list and never interleaves with locally-written values. That is
// exactly what happened to `manga.inLibraryAt`, whose five writers split
// four-local-seconds / one-server-verbatim, so any library synced from a
// millis-reporting server had its synced entries sorted away from the entries
// the user added on the device.
//
// Run: fvm flutter test test/epoch_normalization_test.dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/db/models/chapter.dart';
import 'package:sunfire/src/core/sync/sync_engine.dart';

void main() {
  // Plausible real-world values.
  final secondsNow = DateTime.now().millisecondsSinceEpoch ~/ 1000; // ~1.79e9
  final millisNow = DateTime.now().millisecondsSinceEpoch; // ~1.79e12

  group('normalizeEpochToSeconds — the happy paths', () {
    test('passes an int seconds value through unchanged', () {
      expect(normalizeEpochToSeconds(secondsNow), secondsNow);
    });

    test('divides an int millis value by 1000', () {
      expect(normalizeEpochToSeconds(millisNow), secondsNow);
    });

    test('accepts a numeric string', () {
      expect(normalizeEpochToSeconds('$secondsNow'), secondsNow);
      expect(normalizeEpochToSeconds('$millisNow'), secondsNow);
    });

    test('accepts a double from a JSON payload', () {
      expect(normalizeEpochToSeconds(millisNow.toDouble()), secondsNow);
      expect(normalizeEpochToSeconds(secondsNow.toDouble()), secondsNow);
    });

    test('tolerates surrounding whitespace', () {
      expect(normalizeEpochToSeconds('  $millisNow  '), secondsNow);
    });

    test('a millis value and its seconds equivalent converge on one value', () {
      // This is the invariant that matters: the two encodings of the same
      // instant must normalise identically, or the same event sorts differently
      // depending on which side reported it.
      expect(normalizeEpochToSeconds(millisNow), normalizeEpochToSeconds(secondsNow));
    });
  });

  group('normalizeEpochToSeconds — rejected values', () {
    test('null in, null out', () {
      expect(normalizeEpochToSeconds(null), isNull);
    });

    test('an empty string is not a timestamp', () {
      // A GraphQL field present-but-null commonly arrives as the STRING "null".
      expect(normalizeEpochToSeconds(''), isNull);
    });

    test('the string "null" is not a timestamp', () {
      expect(normalizeEpochToSeconds('null'), isNull);
    });

    test('non-numeric garbage is not a timestamp', () {
      expect(normalizeEpochToSeconds('not-a-date'), isNull);
      expect(normalizeEpochToSeconds('2024-01-01'), isNull);
    });

    test('zero is not a timestamp', () {
      // 0 is the codebase's "unset" sentinel for fetchedAt; storing it as a
      // real value would make an unknown date sort as the epoch.
      expect(normalizeEpochToSeconds(0), isNull);
    });

    test('negative values are not timestamps', () {
      expect(normalizeEpochToSeconds(-1), isNull);
      expect(normalizeEpochToSeconds(-millisNow), isNull);
    });

    test('a fractional double is truncated to an int, in whichever unit applies', () {
      // A double below the threshold is a seconds value, so it floors as
      // seconds. JSON parsers hand back doubles for large integers, so this is
      // the shape that actually arrives in practice.
      expect(normalizeEpochToSeconds(1500.7), 1500);
      expect(normalizeEpochToSeconds(millisNow + 0.9), secondsNow);
    });
  });

  group('normalizeEpochToSeconds — the threshold boundary', () {
    test('exactly at the threshold is treated as seconds', () {
      // 1e11 seconds is the year 5138, so this is the largest value that is
      // unambiguously already-seconds.
      expect(normalizeEpochToSeconds(100000000000), 100000000000);
    });

    test('one above the threshold is treated as millis', () {
      expect(normalizeEpochToSeconds(100000000001), 100000000);
    });
  });

  group('mergeLastReadAt uses the same normalisation', () {
    test('a millis lastReadAt is stored in seconds', () {
      final ch = Chapter()..serverId = 1;
      mergeLastReadAt(ch, {'lastReadAt': millisNow});
      expect(ch.lastReadAt, secondsNow);
    });

    test('a seconds lastReadAt is stored as-is', () {
      final ch = Chapter()..serverId = 1;
      mergeLastReadAt(ch, {'lastReadAt': secondsNow});
      expect(ch.lastReadAt, secondsNow);
    });

    test('a millis value can never outrank a genuinely newer local stamp', () {
      // The "never move backwards" guard has to run AFTER normalisation.
      // Before this fix the comparison was done on the raw value, so a server
      // millis timestamp (1.79e12) would beat a local seconds stamp (1.79e9) on
      // the very first pull and then never be corrected.
      final ch = Chapter()..serverId = 1;
      mergeLastReadAt(ch, {'lastReadAt': secondsNow});
      mergeLastReadAt(ch, {'lastReadAt': millisNow});
      expect(ch.lastReadAt, secondsNow);
    });

    test('an older seconds value does not overwrite a newer one', () {
      final ch = Chapter()..serverId = 1;
      mergeLastReadAt(ch, {'lastReadAt': secondsNow});
      mergeLastReadAt(ch, {'lastReadAt': secondsNow - 5000});
      expect(ch.lastReadAt, secondsNow);
    });

    test('a genuinely newer value does overwrite', () {
      final ch = Chapter()..serverId = 1;
      mergeLastReadAt(ch, {'lastReadAt': secondsNow - 5000});
      mergeLastReadAt(ch, {'lastReadAt': secondsNow});
      expect(ch.lastReadAt, secondsNow);
    });

    test('an absent field leaves the stamp untouched', () {
      final ch = Chapter()..serverId = 1;
      mergeLastReadAt(ch, const {});
      expect(ch.lastReadAt, isNull);
    });

    test('a null/zero/garbage field leaves the stamp untouched', () {
      final ch = Chapter()..serverId = 1;
      for (final bad in <Object?>[null, 0, -1, '', 'null', 'junk']) {
        mergeLastReadAt(ch, {'lastReadAt': bad});
        expect(ch.lastReadAt, isNull, reason: 'bad value $bad must not be stored');
      }
    });

    test('is idempotent when the same millis value arrives repeatedly', () {
      final ch = Chapter()..serverId = 1;
      mergeLastReadAt(ch, {'lastReadAt': millisNow});
      for (var i = 0; i < 10; i++) {
        mergeLastReadAt(ch, {'lastReadAt': millisNow});
      }
      expect(ch.lastReadAt, secondsNow);
    });
  });

  group('one threshold, one helper — the 1e12 strays', () {
    // Nine call sites carried a local `> 1000000000000` check while the helper
    // used 1e11. For any value in the gap (1e11, 1e12] the two disagree, and
    // that gap is not exotic: read as MILLIS it spans 1973-04 through 2001-09,
    // which is exactly the range of upload dates for older series. A 1995
    // chapter timestamp was therefore read as SECONDS and rendered as the year
    // 16850, or fell outside the `year >= 1975` sanity check and was discarded
    // so the chapter showed no date at all.
    //
    // A regression test cannot assert the absence of a literal across the whole
    // tree without being brittle about which files legitimately own the helper,
    // so it does two things: pins the helper's behaviour across the gap, and
    // pins that the gap is genuinely ambiguous for a naive threshold.

    test('the helper reads the 1e11-1e12 gap as millis, not seconds', () {
      // 1995-06-15T00:00:00Z, in millis.
      final millis1995 = DateTime.utc(1995, 6, 15).millisecondsSinceEpoch;
      expect(millis1995, inInclusiveRange(100000000000, 1000000000000),
          reason: 'this test only means something while the value is in the gap');

      expect(normalizeEpochToSeconds(millis1995), millis1995 ~/ 1000);
      // And the wrong reading, for contrast: what a 1e12 threshold produced.
      final asSeconds = DateTime.fromMillisecondsSinceEpoch(millis1995 * 1000);
      expect(asSeconds.year, greaterThan(16000),
          reason: 'sanity: the misread really does land ~1000 years out');
    });

    test('the helper agrees with itself at both edges of the gap', () {
      // Monotonic and unit-correct across the whole plausible range.
      for (final millis in <int>[
        100000000001, // just inside the gap, 1973
        500000000000, // 1985
        1000000000000, // 2001-09
        1778025600000, // 2026
        4102444800000, // 2100
      ]) {
        expect(normalizeEpochToSeconds(millis), millis ~/ 1000, reason: 'millis=$millis');
        final asSeconds = DateTime.fromMillisecondsSinceEpoch(normalizeEpochToSeconds(millis)! * 1000);
        expect(asSeconds.year, inInclusiveRange(1973, 2100), reason: 'millis=$millis');
      }
    });

    test('no timestamp in the codebase keeps a local 1e12 threshold', () {
      // Source-level assertion. The helper's own doc comment and the constant
      // definition legitimately mention the number; everything else must route
      // through `normalizeEpochToSeconds` so there is exactly one answer to
      // "is this seconds or millis".
      final offenders = <String>[];
      for (final entry in Directory('lib').listSync(recursive: true)) {
        if (entry is! File || !entry.path.endsWith('.dart')) continue;
        if (entry.path.endsWith('sync_engine.dart')) continue; // owns the helper
        final content = entry.readAsStringSync();
        if (content.contains('1000000000000')) offenders.add(entry.path);
      }
      expect(offenders, isEmpty,
          reason: 'these files still branch on a 1e12 threshold instead of the helper');
    });
  });
}
