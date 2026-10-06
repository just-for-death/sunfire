// UIS-17: glass tab bar blur is isolated (RepaintBoundary), 15σ, and skipped
// when the platform asks to reduce motion (disableAnimations).
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/ui/shell/nav_chrome.dart';

void main() {
  const dests = [
    SunfireNavDestination(label: 'Library', icon: Icons.book_outlined, activeIcon: Icons.book),
    SunfireNavDestination(label: 'Updates', icon: Icons.update, activeIcon: Icons.update),
    SunfireNavDestination(label: 'History', icon: Icons.history, activeIcon: Icons.history),
  ];

  Future<void> pump(WidgetTester tester, {required bool disableAnimations}) async {
    await tester.pumpWidget(MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: const Size(390, 844), disableAnimations: disableAnimations),
        child: Scaffold(
          bottomNavigationBar: IOSGlassTabBar(
            destinations: dests,
            selectedIndex: 0,
            onSelect: (_) {},
          ),
        ),
      ),
    ));
  }

  Finder inBar(Finder f) => find.descendant(of: find.byType(IOSGlassTabBar), matching: f);

  testWidgets('blurs at 15 sigma inside a RepaintBoundary', (tester) async {
    await pump(tester, disableAnimations: false);
    expect(inBar(find.byType(BackdropFilter)), findsOneWidget);
    expect(inBar(find.byType(RepaintBoundary)), findsWidgets);
    final bf = tester.widget<BackdropFilter>(inBar(find.byType(BackdropFilter)));
    expect(bf.filter, ImageFilter.blur(sigmaX: 15, sigmaY: 15));
    expect(IOSGlassTabBar.glassBlurSigma, 15);
  });

  testWidgets('no blur when disableAnimations is on', (tester) async {
    await pump(tester, disableAnimations: true);
    expect(inBar(find.byType(BackdropFilter)), findsNothing);
    expect(find.text('Library'), findsOneWidget);
  });
}
