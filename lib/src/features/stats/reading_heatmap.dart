// lib/src/features/stats/reading_heatmap.dart
//
// R9.5: GitHub-style reading activity heatmap (last N weeks).
//
// Pure data builder ([buildHeatmapWeeks], unit-tested) + a CustomPainter
// widget. Intensity buckets: 0, 1-2, 3-5, 6+ chapters per day.

library;

import 'package:flutter/material.dart';

import '../../ui/design_system/tokens/sunfire_colors.dart';
import '../../ui/design_system/tokens/sunfire_spacing.dart';

/// One week column: 7 day intensities, Monday-first. -1 = out of range
/// (future days / before the window start), rendered as empty space.
typedef HeatWeek = List<int>;

/// Intensity bucket for a day's chapter count.
int intensityBucket(int chaptersRead) {
  if (chaptersRead <= 0) return 0;
  if (chaptersRead <= 2) return 1;
  if (chaptersRead <= 5) return 2;
  return 3;
}

/// Build [weeks] Monday-first week columns ending today.
///
/// [dailyCounts] maps calendar days (any time-of-day) to chapters read.
/// Future days in the current week are marked -1.
List<HeatWeek> buildHeatmapWeeks(
  Map<DateTime, int> dailyCounts, {
  int weeks = 16,
  DateTime? today,
}) {
  final now = today ?? DateTime.now();
  final todayDate = DateTime(now.year, now.month, now.day);
  // Monday of the current week.
  final mondayThisWeek =
      todayDate.subtract(Duration(days: todayDate.weekday - 1));
  final startMonday =
      mondayThisWeek.subtract(Duration(days: 7 * (weeks - 1)));

  // Normalize counts to calendar days.
  final counts = <DateTime, int>{};
  dailyCounts.forEach((dt, count) {
    final day = DateTime(dt.year, dt.month, dt.day);
    counts[day] = (counts[day] ?? 0) + count;
  });

  final result = <HeatWeek>[];
  for (var w = 0; w < weeks; w++) {
    final week = <int>[];
    for (var d = 0; d < 7; d++) {
      final day = startMonday.add(Duration(days: w * 7 + d));
      if (day.isAfter(todayDate)) {
        week.add(-1);
      } else {
        week.add(intensityBucket(counts[day] ?? 0));
      }
    }
    result.add(week);
  }
  return result;
}

/// Reading activity heatmap widget.
class ReadingHeatmap extends StatelessWidget {
  const ReadingHeatmap({
    super.key,
    required this.dailyCounts,
    this.weeks = 16,
    this.accent = SunfireColors.unreadDot,
  });

  final Map<DateTime, int> dailyCounts;
  final int weeks;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final data = buildHeatmapWeeks(dailyCounts, weeks: weeks);
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          reverse: true,
          child: CustomPaint(
            size: Size(weeks * 14.0 - 2, 7 * 14.0 - 2),
            painter: _HeatmapPainter(
              data: data,
              base: scheme.surfaceContainerHighest,
              accent: accent,
            ),
          ),
        ),
        const SizedBox(height: SunfireSpacing.sm),
        Row(
          children: [
            Text('Less',
                style: TextStyle(
                    fontSize: 11, color: scheme.onSurfaceVariant)),
            const SizedBox(width: 6),
            for (var i = 0; i <= 3; i++) ...[
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: i == 0
                      ? scheme.surfaceContainerHighest
                      : Color.lerp(
                          scheme.surfaceContainerHighest, accent, 0.25 + 0.25 * i),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: SunfireSpacing.xs),
            ],
            Text('More',
                style: TextStyle(
                    fontSize: 11, color: scheme.onSurfaceVariant)),
          ],
        ),
      ],
    );
  }
}

class _HeatmapPainter extends CustomPainter {
  _HeatmapPainter({
    required this.data,
    required this.base,
    required this.accent,
  });

  final List<HeatWeek> data;
  final Color base;
  final Color accent;

  static const double cell = 12;
  static const double gap = 2;

  @override
  void paint(Canvas canvas, Size size) {
    for (var w = 0; w < data.length; w++) {
      for (var d = 0; d < 7; d++) {
        final intensity = data[w][d];
        if (intensity < 0) continue;
        final paint = Paint()
          ..color = intensity == 0
              ? base
              : Color.lerp(base, accent, 0.25 + 0.25 * intensity)!;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
                w * (cell + gap), d * (cell + gap), cell, cell),
            const Radius.circular(3),
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HeatmapPainter old) =>
      old.data != data || old.base != base || old.accent != accent;
}
