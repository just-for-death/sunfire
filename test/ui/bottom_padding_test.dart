// UIS-02: one breakpoint source; scroll bottom padding from the real bar.
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

const _itemCount = 40;

/// Library/Updates-like tab content: nested Scaffold (no bottom bar of its
/// own) with a ListView padded by [SunfireBreakpoints.scrollBottomPadding].
class _TabContent extends StatelessWidget {
  const _TabContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tab')),
      body: ListView.builder(
        key: const Key('list'),
        padding: EdgeInsets.only(
          bottom: SunfireBreakpoints.scrollBottomPadding(context),
        ),
        itemCount: _itemCount,
        itemBuilder: (_, i) => SizedBox(
          key: Key('item$i'),
          height: 56,
          child: Text('Item $i'),
        ),
      ),
    );
  }
}

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

  test('hasBottomNav/hasBottomBar/usesSideRail share one rule', () {
    for (final s in const [
      Size(390, 844),
      Size(850, 390),
      Size(600, 900),
      Size(700, 1000),
    ]) {
      expect(SunfireBreakpoints.usesSideRailForSize(s), isFalse, reason: '$s');
    }
    for (final s in const [Size(834, 1194), Size(1194, 834)]) {
      expect(SunfireBreakpoints.usesSideRailForSize(s), isTrue, reason: '$s');
    }
  });

  Future<double> pumpAndScrollToEnd(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const MaterialApp(home: MainShell(child: _TabContent())),
    );
    await tester.pumpAndSettle();
    final list = find.byKey(const Key('list'));
    final position = tester
        .state<ScrollableState>(
            find.descendant(of: list, matching: find.byType(Scrollable)))
        .position;
    // Jump (not drag) so iOS bouncing physics can't leave it short.
    for (var i = 0; i < 3; i++) {
      position.jumpTo(position.maxScrollExtent);
      await tester.pumpAndSettle();
    }
    final last = find.byKey(const Key('item${_itemCount - 1}'));
    expect(last, findsOneWidget);
    return tester.getRect(last).bottom;
  }

  for (final size in const [Size(850, 390), Size(390, 844), Size(700, 1000)]) {
    testWidgets('Android ${size.width.toInt()}x${size.height.toInt()}: '
        'last item ends above the bottom bar', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final lastBottom = await pumpAndScrollToEnd(tester, size);
      final bar = find.byType(AndroidPhoneNavBar);
      expect(bar, findsOneWidget);
      expect(lastBottom, lessThanOrEqualTo(tester.getRect(bar).top));
      debugDefaultTargetPlatformOverride = null;
    });
  }

  testWidgets('iOS 850x390: last item ends above the glass tab bar',
      (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final lastBottom = await pumpAndScrollToEnd(tester, const Size(850, 390));
    final bar = find.byType(IOSGlassTabBar);
    expect(bar, findsOneWidget);
    expect(lastBottom, lessThanOrEqualTo(tester.getRect(bar).top));
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('Android tablet 1194x834: rail, no extra empty space',
      (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    final lastBottom = await pumpAndScrollToEnd(tester, const Size(1194, 834));
    expect(find.byType(AndroidPhoneNavBar), findsNothing);
    // Only the 16 px breathing room under the last item.
    expect(lastBottom, closeTo(834 - 16, 0.5));
    debugDefaultTargetPlatformOverride = null;
  });
}
