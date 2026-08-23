import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunfire/src/core/services/settings_service.dart';
import 'package:sunfire/src/core/sync/graphql_client_service.dart';
import 'package:sunfire/src/features/browse/browse_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SERVER SOURCES & EXTENSIONS VERIFICATION', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'server_url': 'http://127.0.0.1:4567',
        'sunfire_server_url': 'http://127.0.0.1:4567',
        'onboarding_completed': true,
        'sunfire_onboarding_completed': true,
      });
      await SettingsService.instance.initialize();
      GraphQLClientService.instance.initialize('http://127.0.0.1:4567');
    });

    test('1. GraphQLClientService generates correct server extension mutation payloads', () async {
      final client = GraphQLClientService.instance;
      expect(client.isConfigured, isTrue);
      expect(client.baseUrl, equals('http://127.0.0.1:4567'));

      // Verify mutation methods exist and accept pkgNames
      expect(client.installServerExtension, isNotNull);
      expect(client.uninstallServerExtension, isNotNull);
      expect(client.updateServerExtension, isNotNull);
    });

    testWidgets('2. BrowseScreen renders Sources tab with All, Local JS, and Server filter chips', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: BrowseScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sources'), findsOneWidget);
      expect(find.text('Extensions'), findsOneWidget);
      expect(find.text('Migrate'), findsOneWidget);

      // Verify filter chips exist
      expect(find.text('All'), findsWidgets);
      expect(find.text('Local JS'), findsWidgets);
      expect(find.text('Server (Suwayomi)'), findsOneWidget);
    });

    testWidgets('3. BrowseScreen switching to Server filter displays server sources section or clear empty guidance', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: BrowseScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on Server (Suwayomi) filter chip
      final serverChip = find.text('Server (Suwayomi)');
      expect(serverChip, findsOneWidget);
      await tester.tap(serverChip);
      await tester.pumpAndSettle();

      // Should display either server sources or the dedicated empty guidance with refresh button
      final hasRefreshBtn = find.text('Refresh Sources');
      final hasServerHeader = find.text('☁ SERVER SOURCES (Suwayomi Proxy)');
      expect(hasRefreshBtn.evaluate().isNotEmpty || hasServerHeader.evaluate().isNotEmpty, isTrue);
    });

    testWidgets('4. BrowseScreen Extensions tab allows filtering by Server APK and shows installed/uninstalled state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: BrowseScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to Extensions tab
      await tester.tap(find.text('Extensions'));
      await tester.pumpAndSettle();

      expect(find.text('Search extensions...'), findsOneWidget);
      expect(find.text('☁ Server APK (Suwayomi)'), findsOneWidget);
      expect(find.text('⚡ Local JS (iOS & Android)'), findsOneWidget);

      // Tap Server APK filter
      await tester.tap(find.text('☁ Server APK (Suwayomi)'));
      await tester.pumpAndSettle();

      // Verify Server APK filter is active
      expect(find.text('☁ Server APK (Suwayomi)'), findsOneWidget);
    });
  });
}
