// UIS-09: phones get 5 tabs by default; "More" only for narrow windows or
// large accessibility text. Covers iOS (glass pill) and Android (M3 bar).
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

  Future<void> pumpShell(WidgetTester tester, Size size, double textScale) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(const MaterialApp(home: MainShell(child: SizedBox.shrink())));
    await tester.pumpAndSettle();
  }

  // The iOS glass pill only renders the selected tab's label; every tab
  // carries a Tooltip, so match on tooltip or visible text.
  bool hasDest(String label) =>
      find.byTooltip(label).evaluate().isNotEmpty ||
      find.text(label).evaluate().isNotEmpty;

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    final name = platform.name;

    testWidgets('$name 390x844 @1.0x shows 5 tabs (Settings, no More)', (tester) async {
      debugDefaultTargetPlatformOverride = platform;
      await pumpShell(tester, const Size(390, 844), 1.0);
      expect(hasDest('Settings'), isTrue);
      expect(hasDest('More'), isFalse);
      expect(tester.takeException(), isNull);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('$name 390x844 @1.5x text shows 4 tabs + More', (tester) async {
      debugDefaultTargetPlatformOverride = platform;
      await pumpShell(tester, const Size(390, 844), 1.5);
      expect(hasDest('More'), isTrue);
      expect(hasDest('Settings'), isFalse);
      expect(tester.takeException(), isNull);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('$name 340px wide shows 4 tabs + More', (tester) async {
      debugDefaultTargetPlatformOverride = platform;
      await pumpShell(tester, const Size(340, 740), 1.0);
      expect(hasDest('More'), isTrue);
      expect(hasDest('Settings'), isFalse);
      expect(tester.takeException(), isNull);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('$name 390x844 @2.0x text: compact, no overflow', (tester) async {
      debugDefaultTargetPlatformOverride = platform;
      await pumpShell(tester, const Size(390, 844), 2.0);
      expect(hasDest('More'), isTrue);
      expect(tester.takeException(), isNull);
      debugDefaultTargetPlatformOverride = null;
    });
  }
}
