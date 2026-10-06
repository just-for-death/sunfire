// UIS-15: unrelated setting changes must not rebuild the app themes.
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunfire/src/app.dart';
import 'package:sunfire/src/core/services/settings_service.dart';

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

  testWidgets('toggling incognito does not rebuild themes; accent does',
      (tester) async {
    final s = SettingsService.instance;
    final originalAccent = s.accentColorName;
    final originalIncognito = s.incognitoMode;
    addTearDown(() {
      s.accentColorName = originalAccent;
      s.incognitoMode = originalIncognito;
    });

    await tester.pumpWidget(const SunfireApp());
    await tester.pump(const Duration(milliseconds: 100));
    final afterBoot = debugThemeBuildCount;
    expect(afterBoot, greaterThan(0));

    s.incognitoMode = !originalIncognito;
    await tester.pump();
    s.incognitoMode = originalIncognito;
    await tester.pump();
    expect(debugThemeBuildCount, afterBoot,
        reason: 'unrelated toggles must reuse cached themes');

    s.accentColorName =
        originalAccent == 'Sunfire Orange' ? 'Emerald Green' : 'Sunfire Orange';
    await tester.pump();
    expect(debugThemeBuildCount, afterBoot + 1);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });
}
