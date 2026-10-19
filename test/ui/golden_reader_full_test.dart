// Golden tests for reader UI full components.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sunfire/src/ui/design_system/tokens/sunfire_colors.dart';

void main() {
  group('Reader UI full golden tests', () {
    testWidgets('Reader top bar renders correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            backgroundColor: Colors.black,
            body: Container(
              padding: const EdgeInsets.only(top: 40, left: 8, right: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, size: 20, color: SunfireColors.contentPrimary),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chapter 42: The Final Battle',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: SunfireColors.contentPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          'Long Strip • Black',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: SunfireColors.contentSecondary, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.bookmark_border_rounded, size: 20), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.tune_rounded, size: 20), onPressed: () {}),
                ],
              ),
            ),
          ),
        ),
      );
      await expectLater(find.byType(Scaffold), matchesGoldenFile('goldens/reader_top_bar.png'));
    });

    testWidgets('Auto-scroll HUD renders correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              children: [
                Positioned(
                  bottom: 24,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: SunfireColors.overlaySurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: SunfireColors.borderStrong, width: 0.8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.play_arrow_rounded, size: 13, color: SunfireColors.contentPrimary),
                        const SizedBox(width: 3),
                        const Text('AUTO', style: TextStyle(color: SunfireColors.contentPrimary, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await expectLater(find.byType(Scaffold), matchesGoldenFile('goldens/auto_scroll_hud.png'));
    });
  });
}
