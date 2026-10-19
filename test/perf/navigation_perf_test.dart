// Performance benchmarks for navigation UI components.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sunfire/src/ui/design_system/components/sunfire_chip.dart';

void main() {
  group('Navigation UI performance', () {
    testWidgets('Chip grid builds within budget', (tester) async {
      final stopwatch = Stopwatch()..start();
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 2.5,
              ),
              itemCount: 100,
              itemBuilder: (context, index) => SunfireChip(
                label: 'Item $index',
                variant: SunfireChipVariant.choice,
                selected: index % 5 == 0,
              ),
            ),
          ),
        ),
      );
      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(3000),
          reason: 'catches pathological regressions, not machine noise');
    });

    testWidgets('Text overflow does not cause layout errors in wide text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              child: Column(
                children: List.generate(
                  10,
                  (i) => Text(
                    'Very long text item $i that should be truncated properly without causing any layout errors or overflow exceptions',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('Row with multiple text items does not overflow', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 150,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Long first item',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Long second item',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });
}