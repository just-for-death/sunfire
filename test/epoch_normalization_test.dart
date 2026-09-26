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
}
