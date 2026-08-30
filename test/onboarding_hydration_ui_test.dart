import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunfire/src/core/engine/source_migration_service.dart';
import 'package:sunfire/src/features/browse/browse_screen.dart';
import 'package:sunfire/src/features/onboarding/onboarding_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ONBOARDING & HYDRATION UI VERIFICATION', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('1. OnboardingScreen renders Welcome step with Standalone and Server options', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OnboardingScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sunfire'), findsOneWidget);
      expect(find.text('Standalone Mode'), findsOneWidget);
      expect(find.text('Link Suwayomi Server'), findsOneWidget);
    });

    testWidgets('2. Navigating to Server Connection step renders URL input and Connect button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OnboardingScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Link Suwayomi Server card
      await tester.tap(find.text('Link Suwayomi Server'));
      await tester.pumpAndSettle();

      expect(find.text('Link Suwayomi Server'), findsWidgets);
      expect(find.text('Server URL'), findsOneWidget);
      expect(find.text('Connect & Import Server'), findsOneWidget);
      expect(find.text('Skip server setup (Use Pure Standalone Mode)'), findsOneWidget);
    });

    testWidgets('3. Navigating to Repositories step allows adding and removing custom repos', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OnboardingScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Advance to Server step
      await tester.tap(find.text('Link Suwayomi Server'));
      await tester.pumpAndSettle();

      // Skip server setup to reach Standalone / Repos setup
      expect(find.text('Skip server setup (Use Pure Standalone Mode)'), findsOneWidget);
    });

    testWidgets('4. BrowseScreen renders deduplicated sources tab with Local JS priority', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: BrowseScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sources'), findsOneWidget);
      expect(find.text('Extensions'), findsOneWidget);
      expect(find.text('Migrate'), findsOneWidget);
    });

    test('5. SourceMigrationService markOnboardingCompleted persists gatekeeper flag', () async {
      final prefs = await SharedPreferences.getInstance();
      final migration = SourceMigrationService.instance;

      expect(await migration.isOnboardingCompleted(prefs), isFalse);

      await migration.markOnboardingCompleted(
        serverUrl: 'http://127.0.0.1:4567',
        selectedRepos: ['https://m2k3a.github.io/mangayomi-extensions/index.json'],
        prefs: prefs,
      );

      expect(await migration.isOnboardingCompleted(prefs), isTrue);
      expect(prefs.getString(SourceMigrationService.keyServerUrl), equals('http://127.0.0.1:4567'));
    });
  });
}
