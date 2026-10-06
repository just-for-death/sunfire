// UIS-P3-2: pass updatesBadge to sunfireNavDestinations; extension-repos
// opens via GoRouter (not MaterialPageRoute).
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/main_shell.dart';
import 'package:sunfire/src/ui/shell/nav_chrome.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/path_provider'),
    (MethodCall call) async => '/tmp/sunfire_test',
  );

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    MainShell.updatesBadgeNotifier.value = 0;
    MainShell.selectedTabNotifier.value = 0;
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    MainShell.updatesBadgeNotifier.value = 0;
  });

  test('sunfireNavDestinations wires updatesBadge onto Updates tab', () {
    final none = sunfireNavDestinations();
    expect(none[1].label, 'Updates');
    expect(none[1].badgeCount, isNull);

    final withBadge = sunfireNavDestinations(updatesBadge: 7);
    expect(withBadge[1].badgeCount, 7);
    expect(withBadge[0].badgeCount, isNull);
  });

  test('MainShell.setUpdatesBadge ignores no-ops and clamps negatives', () {
    MainShell.setUpdatesBadge(3);
    expect(MainShell.updatesBadgeNotifier.value, 3);
    MainShell.setUpdatesBadge(3); // no-op
    expect(MainShell.updatesBadgeNotifier.value, 3);
    MainShell.setUpdatesBadge(-2);
    expect(MainShell.updatesBadgeNotifier.value, 0);
  });

  testWidgets('phone nav shows Updates Badge.count when notifier > 0',
      (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    MainShell.setUpdatesBadge(4);
    await tester.pumpWidget(
      const MaterialApp(home: MainShell(child: SizedBox.shrink())),
    );
    await tester.pumpAndSettle();

    final badges = tester.widgetList<Badge>(find.byType(Badge)).toList();
    expect(
      badges.any((b) => b.isLabelVisible && b.label is Text &&
          (b.label as Text).data == '4'),
      isTrue,
      reason: 'Updates tab should show Badge.count(4)',
    );
    expect(tester.takeException(), isNull);
    debugDefaultTargetPlatformOverride = null;
  });

  test('extension-repos must use GoRouter, not MaterialPageRoute', () {
    final lib = Directory('lib');
    expect(lib.existsSync(), isTrue, reason: 'run from package root');
    final offenders = <String>[];
    for (final f in lib.listSync(recursive: true).whereType<File>()) {
      if (!f.path.endsWith('.dart')) continue;
      final src = f.readAsStringSync();
      // MaterialPageRoute builder that constructs ExtensionReposScreen.
      if (src.contains('MaterialPageRoute') &&
          src.contains('ExtensionReposScreen')) {
        // settings_screen still has destination: builder (fallback) AND
        // route: '/settings/extension-repos' — only flag actual push sites.
        final lines = src.split('\n');
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i];
          if (line.contains('MaterialPageRoute') &&
              (line.contains('ExtensionReposScreen') ||
                  (i + 1 < lines.length &&
                      lines[i + 1].contains('ExtensionReposScreen')) ||
                  (i + 2 < lines.length &&
                      lines[i + 2].contains('ExtensionReposScreen')))) {
            offenders.add('${f.path}:${i + 1}');
          }
        }
      }
    }
    expect(offenders, isEmpty,
        reason: 'Push ExtensionRepos via context.push(/settings/extension-repos)');

    final app = File('lib/src/app.dart').readAsStringSync();
    expect(app.contains("path: '/settings/extension-repos'"), isTrue);

    final browse = File('lib/src/features/settings/browse_settings_screen.dart')
        .readAsStringSync();
    expect(browse.contains("context.push('/settings/extension-repos')"), isTrue);

    final settings =
        File('lib/src/features/settings/settings_screen.dart').readAsStringSync();
    expect(settings.contains("route: '/settings/extension-repos'"), isTrue);
  });
}
