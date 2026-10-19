// Golden tests for browse UI components.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sunfire/src/ui/design_system/components/sunfire_chip.dart';
import 'package:sunfire/src/ui/design_system/tokens/sunfire_colors.dart';

void main() {
  group('Browse UI golden tests', () {
    testWidgets('Source filter chips render correctly', (tester) async {
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
                  SunfireChip(label: 'All', variant: SunfireChipVariant.choice, selected: true),
                  SunfireChip(label: 'Server', variant: SunfireChipVariant.choice),
                  SunfireChip(label: 'Local', variant: SunfireChipVariant.choice),
                  SunfireChip(label: 'Webtoons', variant: SunfireChipVariant.choice),
                  SunfireChip(label: 'MangaHere', variant: SunfireChipVariant.choice),
                ],
              ),
            ),
          ),
        ),
      );
      await expectLater(find.byType(Scaffold), matchesGoldenFile('goldens/browse_filters.png'));
    });

    testWidgets('Extension card renders correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: ListTile(
                  leading: const Icon(Icons.extension),
                  title: const Text('MangaHere', maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: const Text('v1.2.4 • EN', maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: const Icon(Icons.chevron_right),
                ),
              ),
            ),
          ),
        ),
      );
      await expectLater(find.byType(Scaffold), matchesGoldenFile('goldens/extension_card.png'));
    });
  });
}