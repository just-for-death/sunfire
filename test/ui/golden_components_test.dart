// Golden tests for the design-system primitives that were uncovered.
//
// Renders at a fixed surface size under the deterministic test font so the
// baselines are stable across machines.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sunfire/src/ui/design_system/components/sunfire_button.dart';
import 'package:sunfire/src/ui/design_system/components/sunfire_card.dart';
import 'package:sunfire/src/ui/design_system/components/sunfire_skeleton.dart';

Widget _surface(Widget child) => MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        body: Center(
          child: SizedBox(width: 320, child: child),
        ),
      ),
    );

void main() {
  testWidgets('button variants golden', (tester) async {
    await tester.pumpWidget(
      _surface(
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SunfireButton.primary(label: 'Primary', icon: Icons.check_rounded, onPressed: () {}),
            const SizedBox(height: 12),
            SunfireButton.secondary(label: 'Secondary', icon: Icons.tune_rounded, onPressed: () {}),
            const SizedBox(height: 12),
            SunfireButton.tertiary(label: 'Tertiary', onPressed: () {}),
            const SizedBox(height: 12),
            SunfireButton.ghost(label: 'Ghost', onPressed: () {}),
          ],
        ),
      ),
    );
    await expectLater(find.byType(Scaffold), matchesGoldenFile('goldens/button_variants.png'));
  });

  testWidgets('card variants golden', (tester) async {
    await tester.pumpWidget(
      _surface(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SunfireCard(
              variant: SunfireCardVariant.elevated,
              child: const Text('Elevated card'),
            ),
            const SizedBox(height: 12),
            SunfireCard(
              variant: SunfireCardVariant.outlined,
              child: const Text('Outlined card'),
            ),
            const SizedBox(height: 12),
            SunfireCard(
              variant: SunfireCardVariant.filled,
              child: const Text('Filled card'),
            ),
          ],
        ),
      ),
    );
    await expectLater(find.byType(Scaffold), matchesGoldenFile('goldens/card_variants.png'));
  });

  testWidgets('list row skeleton golden', (tester) async {
    await tester.pumpWidget(
      _surface(const SunfireListRowSkeleton()),
    );
    await expectLater(find.byType(Scaffold), matchesGoldenFile('goldens/list_row_skeleton.png'));
  });
}
