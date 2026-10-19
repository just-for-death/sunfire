// UIS-12: real narrow-width + large-text overflow guards.
//
// Pumps self-contained screens at the narrowest supported widths and at large
// accessibility text scales, then scrolls the whole content so every child is
// laid out. Flutter reports a RenderFlex/Text overflow as a FlutterError during
// layout, which `tester.takeException()` surfaces — so a non-null value here is
// a real, visible overflow bug.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sunfire/src/core/services/settings_service.dart';
import 'package:sunfire/src/features/settings/appearance_settings_screen.dart';
import 'package:sunfire/src/features/settings/downloads_settings_screen.dart';
import 'package:sunfire/src/features/settings/extension_repos_screen.dart';
import 'package:sunfire/src/features/settings/library_settings_screen.dart';
import 'package:sunfire/src/features/settings/reader_settings_screen.dart';
import 'package:sunfire/src/features/settings/sync_health_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/path_provider'),
    (call) async => '/tmp/sunfire_test',
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  Future<void> pumpAt(
    WidgetTester tester,
    Widget screen,
    Size size,
    double textScale,
  ) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await SettingsService.instance.initialize();
    await tester.pumpWidget(MaterialApp(home: screen));
    await tester.pump();
  }

  // Scroll every scrollable to the bottom so lazily-built children lay out.
  Future<void> drainScrollables(WidgetTester tester) async {
    for (var pass = 0; pass < 12; pass++) {
      final scrollables = find.byType(Scrollable);
      if (scrollables.evaluate().isEmpty) break;
      await tester.drag(scrollables.first, const Offset(0, -600));
      await tester.pump();
    }
    await tester.pump();
  }

  void expectNoOverflow(WidgetTester tester, String context) {
    final ex = tester.takeException();
    expect(
      ex,
      isNull,
      reason: 'Layout exception on "$context": $ex',
    );
  }

  final screens = <String, Widget>{
    'AppearanceSettingsScreen': const AppearanceSettingsScreen(),
    'DownloadsSettingsScreen': const DownloadsSettingsScreen(),
    'LibrarySettingsScreen': const LibrarySettingsScreen(),
    'ExtensionReposScreen': const ExtensionReposScreen(),
    'ReaderSettingsScreen': const ReaderSettingsScreen(),
    'SyncHealthScreen': const SyncHealthScreen(),
  };

  const sizes = <String, Size>{
    'narrow phone 320x640': Size(320, 640),
    'small phone 360x640': Size(360, 640),
  };
  const scales = <String, double>{'1.0x': 1.0, '1.3x': 1.3, '1.5x': 1.5};

  for (final entry in screens.entries) {
    for (final s in sizes.entries) {
      for (final sc in scales.entries) {
        testWidgets(
          '${entry.key} @ ${s.key} ${sc.key} has no overflow',
          (tester) async {
            await pumpAt(tester, entry.value, s.value, sc.value);
            expectNoOverflow(tester, '${entry.key} initial');
            await drainScrollables(tester);
            expectNoOverflow(tester, '${entry.key} scrolled');
          },
        );
      }
    }
  }
}
