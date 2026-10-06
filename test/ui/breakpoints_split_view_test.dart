// UIS-P2-A: one breakpoint source, Tablet UI modes, Split View size changes.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunfire/src/core/services/settings_service.dart';
import 'package:sunfire/src/main_shell.dart';
import 'package:sunfire/src/ui/shell/nav_chrome.dart';
import 'package:sunfire/src/ui/shell/sunfire_breakpoints.dart';
import 'package:sunfire/src/ui/shell/tablet_ui_prefs.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/path_provider'),
    (MethodCall call) async => '/tmp/sunfire_test',
  );

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
    await SettingsService.instance.initialize();
    SunfireBreakpoints.tabletUiMode = 'Auto';
    TabletUiPrefs.listenable.value = 'Auto';
  });

  tearDown(() async {
    debugDefaultTargetPlatformOverride = null;
    await TabletUiPrefs.setMode('Auto');
  });

  test('hasBottomBar is an alias of hasBottomNav rule via usesSideRailForSize',
      () {
    expect(
      SunfireBreakpoints.usesSideRailForSize(const Size(390, 844)),
      isFalse,
    );
    expect(
      SunfireBreakpoints.usesSideRailForSize(const Size(1194, 834)),
      isTrue,
    );
  });

  test('Tablet UI mode Always/Landscape/Never override Auto', () {
    const phoneLand = Size(850, 390);
    // Auto: landscape phone stays on bottom bar (shortest side < 600).
    expect(
      SunfireBreakpoints.usesSideRailForSize(phoneLand, mode: 'Auto'),
      isFalse,
    );
    expect(
      SunfireBreakpoints.usesSideRailForSize(phoneLand, mode: 'Always'),
      isTrue,
    );
    expect(
      SunfireBreakpoints.usesSideRailForSize(phoneLand, mode: 'Landscape'),
      isTrue,
    );
    expect(
      SunfireBreakpoints.usesSideRailForSize(phoneLand, mode: 'Never'),
      isFalse,
    );

    const ipadPortrait = Size(834, 1194);
    expect(
      SunfireBreakpoints.usesSideRailForSize(ipadPortrait, mode: 'Auto'),
      isTrue,
    );
    expect(
      SunfireBreakpoints.usesSideRailForSize(ipadPortrait, mode: 'Landscape'),
      isFalse,
    );
    expect(
      SunfireBreakpoints.usesSideRailForSize(ipadPortrait, mode: 'Never'),
      isFalse,
    );
  });

  Future<void> pumpShell(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const MaterialApp(
        home: MainShell(
          child: Scaffold(body: Center(child: Text('content'))),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
      'Split View: shrinking a tablet window swaps NavigationRail for bottom bar',
      (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    await pumpShell(tester, const Size(1194, 834));
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(AndroidPhoneNavBar), findsNothing);

    // Stage Manager / Split View: same device, smaller window.
    tester.view.physicalSize = const Size(390, 834);
    await tester.pumpAndSettle();
    expect(find.byType(NavigationRail), findsNothing);
    expect(find.byType(AndroidPhoneNavBar), findsOneWidget);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets(
      'Tablet UI Always: landscape phone gets a rail; resizing still follows size',
      (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    // Persist so MainShell's TabletUiPrefs.load() does not reset to Auto.
    await TabletUiPrefs.setMode('Always');

    await pumpShell(tester, const Size(850, 390));
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(AndroidPhoneNavBar), findsNothing);

    // Narrower than tabletMinWidth → bottom bar even in Always.
    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpAndSettle();
    expect(find.byType(NavigationRail), findsNothing);
    expect(find.byType(AndroidPhoneNavBar), findsOneWidget);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('hasBottomBar/hasBottomNav agree inside a phone shell',
      (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    late bool bottomNav;
    late bool bottomBar;
    late bool sideRail;
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            bottomNav = SunfireBreakpoints.hasBottomNav(context);
            bottomBar = SunfireBreakpoints.hasBottomBar(context);
            sideRail = SunfireBreakpoints.usesSideRail(context);
            return const SizedBox();
          },
        ),
      ),
    );
    await tester.pump();
    expect(sideRail, isFalse);
    expect(bottomNav, isTrue);
    expect(bottomBar, isTrue);
    expect(bottomBar, bottomNav);
    debugDefaultTargetPlatformOverride = null;
  });
}
