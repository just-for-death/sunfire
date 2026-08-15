import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/app.dart';
import 'package:sunfire/src/features/onboarding/onboarding_screen.dart';
import 'package:sunfire/src/features/updates/updates_screen.dart';

void main() {
  group('Sunfire Widget Tests', () {
    testWidgets('OnboardingScreen renders initial Welcome step', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OnboardingScreen(),
        ),
      );

      expect(find.text('Sunfire'), findsOneWidget);
      expect(find.text('Local-first manga reader powered by QuickJS and Suwayomi sync.'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
    });

    testWidgets('UpdatesScreen renders initial state', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UpdatesScreen(),
        ),
      );

      expect(find.text('Updates'), findsOneWidget);
    });

    testWidgets('SunfireApp boots cleanly without throwing', (WidgetTester tester) async {
      await tester.pumpWidget(const SunfireApp());
      expect(find.text('Sunfire'), findsOneWidget);
    });
  });
}
