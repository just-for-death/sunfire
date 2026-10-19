// Performance benchmarks for reader UI components.
// These tests measure build times and frame rendering.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sunfire/src/ui/design_system/components/sunfire_chip.dart';

void main() {
  group('Reader UI performance', () {
    testWidgets('SunfireChip builds within budget', (tester) async {
      final stopwatch = Stopwatch()..start();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Wrap(
              children: List.generate(
                50,
                (i) => SunfireChip(
                  label: 'Chip $i with a somewhat long label',
                  selected: i % 3 == 0,
                ),
              ),
            ),
          ),
        ),
      );
      stopwatch.stop();
      // 50 chips should build within reasonable time
      expect(stopwatch.elapsedMilliseconds, lessThan(3000),
          reason: 'catches pathological regressions, not machine noise');
    });

    testWidgets('Text overflow handling does not cause layout errors', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 100,
              child: Column(
                children: [
                  Text(
                    'This is a very long text that should overflow and be truncated',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Another long text that needs to be handled properly',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      // No overflow exceptions
      expect(tester.takeException(), isNull);
    });
  });
}