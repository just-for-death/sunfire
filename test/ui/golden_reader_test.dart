// Golden tests for reader UI components.
// Run with: flutter test --update-goldens test/ui/golden_reader_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sunfire/src/core/widgets/sunfire_badge.dart';
import 'package:sunfire/src/ui/design_system/components/sunfire_chip.dart';

void main() {
  group('Reader UI golden tests', () {
    testWidgets('SunfireChip variants render correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  SunfireChip(label: 'Filter Chip', variant: SunfireChipVariant.filter, selected: true),
                  SunfireChip(label: 'Choice Chip', variant: SunfireChipVariant.choice, selected: false),
                  SunfireChip(label: 'Input Chip', variant: SunfireChipVariant.input, onDeleted: null),
                  SunfireChip(label: 'A very long chip label that should be truncated', variant: SunfireChipVariant.filter),
                ],
              ),
            ),
          ),
        ),
      );
      await expectLater(find.byType(Scaffold), matchesGoldenFile('goldens/sunfire_chips.png'));
    });

    testWidgets('SunfireBadge variants render correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  SunfireBadge(label: 'SERVER'),
                  SunfireBadge(label: 'LOCAL'),
                  SunfireBadge(label: 'PROXY'),
                  SunfireBadge(label: 'A very long badge label', variant: SunfireBadgeVariant.chip),
                ],
              ),
            ),
          ),
        ),
      );
      await expectLater(find.byType(Scaffold), matchesGoldenFile('goldens/sunfire_badges.png'));
    });
  });
}
