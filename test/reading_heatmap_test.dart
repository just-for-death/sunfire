// test/reading_heatmap_test.dart
//
// R9.5: heatmap data builder.

import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/features/stats/reading_heatmap.dart';

void main() {
  // Wednesday 2026-10-07.
  final wed = DateTime(2026, 10, 7);

  group('intensityBucket', () {
    test('buckets 0 / 1-2 / 3-5 / 6+', () {
      expect(intensityBucket(0), 0);
      expect(intensityBucket(-3), 0);
      expect(intensityBucket(1), 1);
      expect(intensityBucket(2), 1);
      expect(intensityBucket(3), 2);
      expect(intensityBucket(5), 2);
      expect(intensityBucket(6), 3);
      expect(intensityBucket(100), 3);
    });
  });

  group('buildHeatmapWeeks', () {
    test('produces N Monday-first columns of 7', () {
      final weeks = buildHeatmapWeeks({}, weeks: 16, today: wed);
      expect(weeks.length, 16);
      for (final w in weeks) {
        expect(w.length, 7);
      }
    });

    test('marks future days -1 (Thu-Sun of current week)', () {
      final weeks = buildHeatmapWeeks({}, weeks: 2, today: wed);
      // Last column = current week Mon..Sun; Wed index 2.
      final current = weeks.last;
      expect(current.sublist(0, 3), [0, 0, 0]);
      expect(current.sublist(3), [-1, -1, -1, -1]);
    });

    test('counts map to buckets on correct weekdays', () {
      final monday = DateTime(2026, 10, 5);
      final weeks = buildHeatmapWeeks(
        {monday: 4, wed: 1},
        weeks: 1,
        today: wed,
      );
      expect(weeks.length, 1);
      // Monday idx 0 -> bucket 2; Wednesday idx 2 -> bucket 1.
      expect(weeks.first[0], 2);
      expect(weeks.first[2], 1);
    });

    test('time-of-day is ignored when bucketing', () {
      final weeks = buildHeatmapWeeks(
        {DateTime(2026, 10, 5, 23, 59): 7},
        weeks: 1,
        today: wed,
      );
      expect(weeks.first[0], 3);
    });
  });
}
