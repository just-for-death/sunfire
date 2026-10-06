import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunfire/src/core/services/settings_service.dart';
import 'package:sunfire/src/main_shell.dart';

/// The reader must be edge-to-edge: no tablet sidebar rail, no phone bottom
/// bar. Tab routes keep their chrome. Pumps [MainShell] directly (not via the
/// router) so the real ReaderScreen — whose service init hangs pumpAndSettle
/// — is never booted.
Future<void> _pumpShell(
  WidgetTester tester, {
  required bool isFullscreen,
  required Size surface,
}) async {
  SharedPreferences.setMockInitialValues({});
  await SettingsService.instance.initialize();
  MainShell.switchToTab(0);
  tester.view.physicalSize = surface;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.pumpWidget(
    MaterialApp(
      home: MainShell(
        isFullscreen: isFullscreen,
        child: const Center(child: Text('page-body')),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Reader fullscreen chrome', () {
    testWidgets('phone: fullscreen hides the bottom bar, tabs keep it', (tester) async {
      const phone = Size(400, 800);
      await _pumpShell(tester, isFullscreen: true, surface: phone);
      expect(find.text('page-body'), findsOneWidget);
      expect(find.text('Library'), findsNothing);
      expect(find.text('Browse'), findsNothing);

      await _pumpShell(tester, isFullscreen: false, surface: phone);
      expect(find.text('Library'), findsOneWidget);
    });

    testWidgets('iPad: fullscreen hides the sidebar rail, tabs keep it', (tester) async {
      const ipad = Size(1024, 768);
      await _pumpShell(tester, isFullscreen: true, surface: ipad);
      expect(find.text('page-body'), findsOneWidget);
      expect(find.byTooltip('Collapse sidebar'), findsNothing);
      expect(find.byTooltip('Expand sidebar'), findsNothing);
      expect(find.text('MENU'), findsNothing);

      await _pumpShell(tester, isFullscreen: false, surface: ipad);
      expect(find.byTooltip('Collapse sidebar'), findsOneWidget);
      // iPad chrome follows Theme.platform (UIS-01); the variant sets and
      // resets debugDefaultTargetPlatformOverride inside the test.
    }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

    testWidgets('Android tablet: fullscreen hides the NavigationRail, tabs keep it', (tester) async {
      const tablet = Size(1024, 768);
      await _pumpShell(tester, isFullscreen: true, surface: tablet);
      expect(find.text('page-body'), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
      expect(find.text('Library'), findsNothing);

      await _pumpShell(tester, isFullscreen: false, surface: tablet);
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.text('Library'), findsWidgets);
    }, variant: TargetPlatformVariant.only(TargetPlatform.android));
  });
}
