// UIS-P2-B: tablet rail extras — Downloads/Stats trailing + badge,
// Expanded Sidebar → NavigationRail.extended on Android, Continue reading.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunfire/src/core/services/settings_service.dart';
import 'package:sunfire/src/main_shell.dart';
import 'package:sunfire/src/ui/shell/rail_extras.dart';
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
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  Future<void> pumpShell(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const MaterialApp(home: MainShell(child: SizedBox.shrink())),
    );
    await tester.pumpAndSettle();
  }

  Widget host(Widget child) => MaterialApp(
        home: Scaffold(
          body: Row(children: [
            SizedBox(width: 220, child: Column(children: [child])),
          ]),
        ),
      );

  group('SunfireRailTrailing', () {
    testWidgets('collapsed: icon buttons, badge shows active count',
        (tester) async {
      var downloads = 0, stats = 0;
      await tester.pumpWidget(host(SunfireRailTrailing(
        extended: false,
        activeDownloads: 3,
        onDownloads: () => downloads++,
        onStats: () => stats++,
      )));
      expect(find.byTooltip('Downloads'), findsOneWidget);
      expect(find.byTooltip('Reading Stats'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('Downloads'), findsNothing);
      await tester.tap(find.byTooltip('Downloads'));
      await tester.tap(find.byTooltip('Reading Stats'));
      expect(downloads, 1);
      expect(stats, 1);
    });

    testWidgets('extended: labels visible, badge hidden at zero',
        (tester) async {
      await tester.pumpWidget(host(SunfireRailTrailing(
        extended: true,
        activeDownloads: 0,
        onDownloads: () {},
        onStats: () {},
      )));
      expect(find.text('Downloads'), findsOneWidget);
      expect(find.text('Reading Stats'), findsOneWidget);
      final badge = tester.widget<Badge>(find.byType(Badge));
      expect(badge.isLabelVisible, isFalse);
    });
  });

  group('SunfireContinueReadingButton', () {
    testWidgets('opens resolved route', (tester) async {
      String? opened;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SunfireContinueReadingButton(
            extended: true,
            resolveRoute: () async => '/reader/42',
            onOpen: (r) => opened = r,
          ),
        ),
      ));
      expect(find.text('Continue reading'), findsOneWidget);
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(opened, '/reader/42');
    });

    testWidgets('shows snackbar when nothing to resume', (tester) async {
      String? opened;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SunfireContinueReadingButton(
            extended: false,
            resolveRoute: () async => null,
            onOpen: (r) => opened = r,
          ),
        ),
      ));
      expect(find.byTooltip('Continue reading'), findsOneWidget);
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      expect(opened, isNull);
      expect(find.text(SunfireContinueReadingButton.emptyMessage),
          findsOneWidget);
    });
  });

  group('MainShell Android rail', () {
    testWidgets(
        'header has Continue reading; trailing has Downloads/Stats labels',
        (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      SettingsService.instance.tabletSidebarExpanded = true;
      await pumpShell(tester, const Size(1280, 800));

      final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(rail.extended, isTrue);
      expect(rail.leading, isNotNull);
      expect(rail.trailing, isNotNull);
      expect(find.byType(SunfireContinueReadingButton), findsOneWidget);
      expect(find.text('Continue reading'), findsOneWidget);
      expect(find.byType(SunfireRailTrailing), findsOneWidget);
      expect(find.text('Downloads'), findsOneWidget);
      expect(find.text('Reading Stats'), findsOneWidget);
      expect(tester.takeException(), isNull);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('Expanded Sidebar extends rail on Android at 860 wide',
        (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      SettingsService.instance.tabletSidebarExpanded = true;
      await pumpShell(tester, const Size(860, 700));
      expect(
        tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
        isTrue,
      );
      SettingsService.instance.tabletSidebarExpanded = false;
      await tester.pumpAndSettle();
      expect(
        tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
        isFalse,
      );
      // Collapsed: icon-only FAB + icon trailing items, still reachable.
      expect(find.byTooltip('Continue reading'), findsOneWidget);
      expect(find.byTooltip('Downloads'), findsOneWidget);
      expect(find.text('Continue reading'), findsNothing);
      expect(tester.takeException(), isNull);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('short landscape window (850x390): rail scrolls, no overflow',
        (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      SettingsService.instance.tabletSidebarExpanded = true;
      // Tablet UI "Always" → rail on a landscape phone.
      await TabletUiPrefs.setMode('Always');
      addTearDown(() => TabletUiPrefs.setMode('Auto'));
      await pumpShell(tester, const Size(850, 390));
      final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(rail.scrollable, isTrue);
      expect(rail.trailingAtBottom, isTrue);
      expect(find.byType(SunfireContinueReadingButton), findsOneWidget);
      expect(find.byTooltip('Downloads'), findsOneWidget);
      expect(tester.takeException(), isNull);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('Continue reading with no history shows snackbar',
        (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      SettingsService.instance.tabletSidebarExpanded = false;
      await pumpShell(tester, const Size(1024, 768));
      await tester.tap(find.byTooltip('Continue reading'));
      await tester.pump();
      await tester.pump();
      expect(find.text(SunfireContinueReadingButton.emptyMessage),
          findsOneWidget);
      debugDefaultTargetPlatformOverride = null;
    });
  });

  testWidgets('iPad glass sidebar header has Continue reading',
      (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    SettingsService.instance.tabletSidebarExpanded = true;
    await pumpShell(tester, const Size(1024, 768));
    expect(find.byType(SunfireContinueReadingButton), findsOneWidget);
    expect(tester.takeException(), isNull);
    debugDefaultTargetPlatformOverride = null;
  });
}
