// UIS-03: Android tablet rail parity + live Expanded Sidebar.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunfire/src/core/services/settings_service.dart';
import 'package:sunfire/src/main_shell.dart';

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
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  Future<void> pumpTabletShell(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const MaterialApp(home: MainShell(child: SizedBox.shrink())),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Android 1280x800 rail shows Downloads and Reading Stats',
      (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    SettingsService.instance.tabletSidebarExpanded = true;
    await pumpTabletShell(tester);

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byTooltip('Downloads'), findsOneWidget);
    expect(find.byTooltip('Reading Stats'), findsOneWidget);
    expect(find.byTooltip('Collapse sidebar'), findsOneWidget);

    final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
    expect(rail.extended, isTrue);

    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('Expanded Sidebar setting updates NavigationRail.extended live',
      (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    SettingsService.instance.tabletSidebarExpanded = true;
    await pumpTabletShell(tester);

    expect(
      tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
      isTrue,
    );

    // Toggle via settings (Appearance screen path) — shell listens.
    SettingsService.instance.tabletSidebarExpanded = false;
    await tester.pumpAndSettle();

    expect(
      tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
      isFalse,
    );
    expect(find.byTooltip('Expand sidebar'), findsOneWidget);

    debugDefaultTargetPlatformOverride = null;
  });
}
