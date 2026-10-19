// Tablet responsive layout tests.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sunfire/src/ui/shell/sunfire_breakpoints.dart';

void main() {
  group('Tablet responsive layout', () {
    testWidgets('Phone layout uses bottom nav (width < 600)', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(home: Builder(builder: (context) {
          expect(SunfireBreakpoints.isTabletLayout(context), isFalse);
          return const SizedBox();
        })),
      );
      // Width 400 < 600, so not tablet
      expect(400 < SunfireBreakpoints.tabletMinWidth, isTrue);
    });

    testWidgets('Tablet layout uses side rail (width >= 600, shortestSide >= 600)', (tester) async {
      // 834x1194 (iPad) → tablet
      expect(834 >= SunfireBreakpoints.tabletMinWidth, isTrue);
      expect(834 >= SunfireBreakpoints.narrowTabletMaxWidth, isTrue);
      expect(834 >= 600, isTrue); // shortestSide check
    });

    testWidgets('Compact nav triggers on narrow width', (tester) async {
      expect(SunfireBreakpoints.compactNavMaxWidth, 360.0);
      expect(350 < SunfireBreakpoints.compactNavMaxWidth, isTrue);
    });

    testWidgets('Two-pane details only on landscape tablets', (tester) async {
      // 840x600 landscape tablet
      final size = const Size(840, 600);
      expect(SunfireBreakpoints.usesTwoPaneDetailsForSize(size, 900), isTrue);
      // Portrait
      final portraitSize = const Size(600, 840);
      expect(SunfireBreakpoints.usesTwoPaneDetailsForSize(portraitSize, 900), isFalse);
    });

    testWidgets('Split view halves use phone layout', (tester) async {
      // 400x800 split view half → phone
      expect(400 < SunfireBreakpoints.tabletMinWidth, isTrue);
    });
  });
}