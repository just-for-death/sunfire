// Golden tests for settings UI components.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sunfire/src/ui/design_system/components/sunfire_chip.dart';

void main() {
  group('Settings UI golden tests', () {
    testWidgets('Settings chips render correctly', (tester) async {
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
                  SunfireChip(label: 'Updates', variant: SunfireChipVariant.choice),
                  SunfireChip(label: 'History', variant: SunfireChipVariant.choice),
                  SunfireChip(label: 'Browse', variant: SunfireChipVariant.choice),
                  SunfireChip(label: 'Settings', variant: SunfireChipVariant.choice),
                ],
              ),
            ),
          ),
        ),
      );
      await expectLater(find.byType(Scaffold), matchesGoldenFile('goldens/settings_chips.png'));
    });

    testWidgets('Overflow text in narrow container renders correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: SizedBox(
              width: 150,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This is a very long setting label that should be truncated',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Short label',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Another extremely long setting description that needs proper overflow handling to prevent UI breakage',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await expectLater(find.byType(Scaffold), matchesGoldenFile('goldens/overflow_settings.png'));
    });
  });
}