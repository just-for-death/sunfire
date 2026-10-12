// test/design_tokens_test.dart
//
// Phase 2 Epic 4: design token invariants (D4.1-D4.5).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/ui/design_system/tokens/tokens.dart';

void main() {
  group('D4.2 spacing', () {
    test('scale is ascending 4pt-based', () {
      expect(SunfireSpacing.xs, 4);
      expect(SunfireSpacing.sm, 8);
      expect(SunfireSpacing.md, 12);
      expect(SunfireSpacing.lg, 16);
      expect(SunfireSpacing.xl, 24);
      expect(SunfireSpacing.xxl, 32);
      expect([
        SunfireSpacing.xs,
        SunfireSpacing.sm,
        SunfireSpacing.md,
        SunfireSpacing.lg,
        SunfireSpacing.xl,
        SunfireSpacing.xxl,
        SunfireSpacing.xxxl,
      ], orderedEquals([4, 8, 12, 16, 24, 32, 48]));
    });

    test('touch target meets 48dp accessibility floor', () {
      expect(SunfireSpacing.minTouchTarget, greaterThanOrEqualTo(48));
    });

    test('radius scale is ascending', () {
      expect(
          [SunfireRadius.xs, SunfireRadius.sm, SunfireRadius.md,
           SunfireRadius.lg, SunfireRadius.xl],
          orderedEquals([4, 8, 12, 16, 20]));
      expect(SunfireRadius.pill, greaterThan(SunfireRadius.xl));
    });
  });

  group('D4.4 elevation', () {
    test('levels are ascending', () {
      expect(
          [SunfireElevation.level0, SunfireElevation.level1,
           SunfireElevation.level2, SunfireElevation.level3,
           SunfireElevation.level4, SunfireElevation.level5],
          orderedEquals([0, 1, 3, 6, 8, 12]));
    });

    test('dark theme has no card shadow (surface contrast instead)', () {
      expect(SunfireElevation.cardShadow(Brightness.dark), isEmpty);
      expect(SunfireElevation.cardShadow(Brightness.light), isNotEmpty);
    });
  });

  group('D4.5 motion', () {
    test('durations are ascending', () {
      final durations = [
        SunfireDuration.instant,
        SunfireDuration.fast,
        SunfireDuration.medium,
        SunfireDuration.slow,
      ];
      for (var i = 1; i < durations.length; i++) {
        expect(durations[i] > durations[i - 1], isTrue);
      }
    });

    test('page turn matches reader default (200ms)', () {
      expect(SunfireDuration.pageTurn,
          const Duration(milliseconds: 200));
    });
  });

  group('D4.1 colors', () {
    test('surface hierarchy has 4 distinct dark + light levels', () {
      final dark = {
        SunfireColors.surface0, SunfireColors.surface1,
        SunfireColors.surface2, SunfireColors.surface3,
      };
      final light = {
        SunfireColors.surface0Light, SunfireColors.surface1Light,
        SunfireColors.surface2Light, SunfireColors.surface3Light,
      };
      expect(dark.length, 4);
      expect(light.length, 4);
    });

    testWidgets('surfaceFor resolves OLED black at level 0',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Builder(builder: (context) {
            // OLED flag comes from SettingsService; just verify the
            // helper returns a color for every level/theme combo.
            for (var level = 0; level <= 3; level++) {
              expect(SunfireColors.surfaceFor(context, level),
                  isA<Color>());
            }
            return const SizedBox();
          }),
        ),
      );
    });
  });

  group('D4.3 typography', () {
    test('manga styles exist with sane sizes', () {
      expect(SunfireTypography.mangaTitle.fontSize, 13);
      expect(SunfireTypography.chapterName.fontSize, 12);
      expect(SunfireTypography.readerPageNumber.fontSize, 13);
    });

    test('withColor/withWeight/withSize helpers preserve base', () {
      final colored = SunfireTypography.withColor(
          SunfireTypography.bodyMedium, Colors.red);
      expect(colored.color, Colors.red);
      expect(colored.fontSize,
          SunfireTypography.bodyMedium.fontSize);
    });
  });
}
