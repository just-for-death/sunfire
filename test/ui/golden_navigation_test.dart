// Golden tests for navigation UI components.
// Run with: flutter test --update-goldens test/ui/golden_navigation_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sunfire/src/ui/design_system/components/sunfire_chip.dart';

void main() {
  group('Navigation UI golden tests', () {
    testWidgets('SunfireChip in navigation context renders correctly', (tester) async {
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
                  SunfireChip(label: 'Library', variant: SunfireChipVariant.choice, selected: true),
                  SunfireChip(label: 'Updates', variant: SunfireChipVariant.choice, selected: false),
                  SunfireChip(label: 'Browse', variant: SunfireChipVariant.choice, selected: false),
                  SunfireChip(label: 'Settings', variant: SunfireChipVariant.choice, selected: false),
                  SunfireChip(label: 'History', variant: SunfireChipVariant.choice, selected: false),
                ],
              ),
            ),
          ),
        ),
      );
      await expectLater(find.byType(Scaffold), matchesGoldenFile('goldens/sunfire_nav_chips.png'));
    });

    testWidgets('Overflow text renders correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: SizedBox(
              width: 120,
              child: Column(
                children: [
                  Text(
                    'This is a very long title that should be truncated',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Short text',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await expectLater(find.byType(Scaffold), matchesGoldenFile('goldens/overflow_text.png'));
    });
  });
}