// UIS-14 + UIS-23 (revised): the shell, nav chrome and cover placeholder
// follow the ColorScheme so Light mode renders a light UI (no dark slabs).
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/services/image_cache_helper.dart';
import 'package:sunfire/src/main_shell.dart';
import 'package:sunfire/src/ui/design_system/sunfire_theme.dart';

/// Hard-coded dark hexes removed by UIS-14.
const _oldDarkHexes = <int>[
  0xFF0E0E14, // shell scaffold
  0xFF15151E, // iPad content card
  0xD0111119, // iPad glass sidebar tint
  0xCC181820, // iOS glass bottom pill
  0xFF26262B, // cover placeholder
];

bool _isOldDark(Color? c) =>
    c != null && _oldDarkHexes.contains(c.toARGB32());

Color? _decorationColor(Decoration? d) =>
    d is BoxDecoration ? d.color : null;

void _expectNoOldDark(WidgetTester tester) {
  for (final s in tester.widgetList<Scaffold>(find.byType(Scaffold))) {
    expect(_isOldDark(s.backgroundColor), isFalse,
        reason: 'Scaffold uses ${s.backgroundColor}');
  }
  for (final c in tester.widgetList<Container>(find.byType(Container))) {
    expect(_isOldDark(c.color) || _isOldDark(_decorationColor(c.decoration)),
        isFalse,
        reason: 'Container uses old dark colour');
  }
  for (final c in tester
      .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))) {
    expect(_isOldDark(_decorationColor(c.decoration)), isFalse,
        reason: 'AnimatedContainer uses old dark colour');
  }
  for (final d in tester.widgetList<DecoratedBox>(find.byType(DecoratedBox))) {
    expect(_isOldDark(_decorationColor(d.decoration)), isFalse,
        reason: 'DecoratedBox uses old dark colour');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/path_provider'),
    (MethodCall call) async => '/tmp/sunfire_test',
  );

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  Widget lightApp(Widget home) => MaterialApp(
        theme: SunfireTheme.buildLightTheme(),
        darkTheme: SunfireTheme.buildDarkTheme(),
        themeMode: ThemeMode.light,
        home: home,
      );

  Future<void> pump(WidgetTester tester, Size size, Widget home) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(lightApp(home));
    await tester.pumpAndSettle();
  }

  const shell = MainShell(child: SizedBox.shrink());

  final cases = <String, (TargetPlatform, Size)>{
    'iPad glass sidebar 1024x768': (TargetPlatform.iOS, const Size(1024, 768)),
    'iPhone glass pill 390x844': (TargetPlatform.iOS, const Size(390, 844)),
    'Android rail 1024x768': (TargetPlatform.android, const Size(1024, 768)),
    'Android phone bar 390x844': (TargetPlatform.android, const Size(390, 844)),
  };

  cases.forEach((name, c) {
    testWidgets('Light: $name has no hard-coded dark slabs', (tester) async {
      debugDefaultTargetPlatformOverride = c.$1;
      await pump(tester, c.$2, shell);
      expect(tester.takeException(), isNull);
      _expectNoOldDark(tester);
      final scheme = Theme.of(tester.element(find.byType(MainShell))).colorScheme;
      expect(scheme.brightness, Brightness.light);
      debugDefaultTargetPlatformOverride = null;
    });
  });

  testWidgets('Light: iPad sidebar + content card use scheme surfaces',
      (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    await pump(tester, const Size(1024, 768), shell);
    final cs = Theme.of(tester.element(find.byType(MainShell))).colorScheme;
    final colors = tester
        .widgetList<Container>(find.byType(Container))
        .map((c) => _decorationColor(c.decoration))
        .whereType<Color>()
        .toList();
    expect(colors, contains(cs.surfaceContainerLow));
    expect(colors, contains(cs.surfaceContainer.withValues(alpha: 0.8)));
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
    expect(scaffold.backgroundColor, cs.surface);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('Fullscreen (reader) shell stays black in Light', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    await pump(tester, const Size(1024, 768),
        const MainShell(isFullscreen: true, child: SizedBox.shrink()));
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
    expect(scaffold.backgroundColor, Colors.black);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('Light: cover placeholder uses surfaceContainerHighest',
      (tester) async {
    await pump(tester, const Size(390, 844),
        const Scaffold(
            body: MangaCoverImage(mangaServerId: 0, width: 100, height: 150)));
    final cs = Theme.of(tester.element(find.byType(MangaCoverImage))).colorScheme;
    _expectNoOldDark(tester);
    final colors = tester
        .widgetList<Container>(find.descendant(
            of: find.byType(MangaCoverImage), matching: find.byType(Container)))
        .map((c) => c.color)
        .toList();
    expect(colors, contains(cs.surfaceContainerHighest));
    final icon = tester.widget<Icon>(find.byIcon(Icons.book_rounded));
    expect(icon.color, cs.onSurfaceVariant);
  });
}
