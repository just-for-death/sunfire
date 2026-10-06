// UIS-01: shell chrome follows the theme platform, not dart:io.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/main_shell.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/path_provider'),
    (MethodCall call) async => '/tmp/sunfire_test',
  );

  setUp(() {
    // UIX-01 (secure-storage guard) may not be merged yet.
    FlutterSecureStorage.setMockInitialValues({});
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  Future<void> pumpShell(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: MainShell(child: SizedBox.shrink())));
    await tester.pumpAndSettle();
  }

  testWidgets('iOS theme platform at 1024x768 shows the glass sidebar', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    await pumpShell(tester);
    expect(find.byTooltip('Collapse sidebar'), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('Android theme platform at 1024x768 shows NavigationRail', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    await pumpShell(tester);
    expect(find.byType(NavigationRail), findsOneWidget);
    // UIS-03: Android rail gained a leading expand/collapse toggle (same tooltip as iPad).
    expect(find.byTooltip('Collapse sidebar'), findsOneWidget);
    expect(find.byTooltip('Downloads'), findsOneWidget);
    debugDefaultTargetPlatformOverride = null;
  });
}
