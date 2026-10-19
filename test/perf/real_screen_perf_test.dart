// UIS-14: real-screen performance budgets.
//
// The earlier benchmarks only measured synthetic chip grids. These pump the
// actual settings screens and measure initial build plus repeated scrolling —
// a practical proxy for jank on mid-range devices. Budgets are deliberately
// generous so the tests catch pathological regressions (10x) rather than
// machine-to-machine noise.
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

  final screens = <String, Widget>{
    'AppearanceSettingsScreen': const AppearanceSettingsScreen(),
    'DownloadsSettingsScreen': const DownloadsSettingsScreen(),
    'LibrarySettingsScreen': const LibrarySettingsScreen(),
    'ExtensionReposScreen': const ExtensionReposScreen(),
    'ReaderSettingsScreen': const ReaderSettingsScreen(),
    'SyncHealthScreen': const SyncHealthScreen(),
  };

  for (final entry in screens.entries) {
    testWidgets('${entry.key} builds and scrolls within budget', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await SettingsService.instance.initialize();

      final build = Stopwatch()..start();
      await tester.pumpWidget(MaterialApp(home: entry.value));
      await tester.pump();
      build.stop();
      expect(
        build.elapsedMilliseconds,
        lessThan(2000),
        reason: '${entry.key} initial build took ${build.elapsedMilliseconds}ms',
      );

      final scroll = Stopwatch()..start();
      for (var i = 0; i < 10; i++) {
        final s = find.byType(Scrollable);
        if (s.evaluate().isEmpty) break;
        await tester.drag(s.first, const Offset(0, -400));
        await tester.pump();
      }
      scroll.stop();
      expect(
        scroll.elapsedMilliseconds,
        lessThan(4000),
        reason: '${entry.key} 10 scrolls took ${scroll.elapsedMilliseconds}ms',
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('500 long-label chips build within budget', (tester) async {
    final sw = Stopwatch()..start();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView.builder(
            itemCount: 500,
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Chapter ${i + 1}: a deliberately long chapter title that must ellipsize',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${i + 1}'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    sw.stop();
    expect(sw.elapsedMilliseconds, lessThan(2000));
    expect(tester.takeException(), isNull);
  });
}
