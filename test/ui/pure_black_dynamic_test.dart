// UIS-P2-C: true Dynamic (Material You) theme, separate Pure black toggle
// (Mihon #1011: no tinted bars), and Light still works.
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunfire/src/core/services/settings_service.dart';
import 'package:sunfire/src/features/settings/appearance_settings_screen.dart';
import 'package:sunfire/src/ui/design_system/sunfire_theme.dart';
import 'package:sunfire/src/ui/shell/nav_chrome.dart';

const _black = Color(0xFF000000);

bool _neutral(Color c) {
  final v = c.toARGB32();
  final r = (v >> 16) & 0xFF, g = (v >> 8) & 0xFF, b = v & 0xFF;
  return r == g && g == b;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final dynLight =
      ColorScheme.fromSeed(seedColor: Colors.teal, brightness: Brightness.light);
  final dynDark =
      ColorScheme.fromSeed(seedColor: Colors.teal, brightness: Brightness.dark);

  setUpAll(() async {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
    await SettingsService.instance.initialize();
  });

  group('Dynamic (Material You)', () {
    test('keeps dynamic primary and tonal surfaces (light + dark)', () {
      for (final (scheme, theme) in [
        (dynLight, SunfireTheme.buildLightTheme(dynamicScheme: dynLight)),
        (dynDark, SunfireTheme.buildDarkTheme(dynamicScheme: dynDark)),
      ]) {
        final cs = theme.colorScheme;
        expect(cs.primary, scheme.primary);
        expect(cs.surface, scheme.surface);
        expect(cs.surfaceContainer, scheme.surfaceContainer);
        expect(cs.surfaceContainerHighest, scheme.surfaceContainerHighest);
        expect(theme.scaffoldBackgroundColor, scheme.surface);
        expect(theme.navigationBarTheme.backgroundColor, scheme.surfaceContainer);
      }
    });

    test('non-dynamic keeps Sunfire brand surfaces', () {
      final dark = SunfireTheme.buildDarkTheme();
      expect(dark.scaffoldBackgroundColor, isNot(_black));
      expect(dark.colorScheme.primary, SettingsService.instance.accentColor);
    });
  });

  group('Pure black', () {
    test('blacks background, surface and surface containers; no tint', () {
      for (final dyn in [null, dynDark]) {
        final t = SunfireTheme.buildDarkTheme(dynamicScheme: dyn, isOled: true);
        final cs = t.colorScheme;
        expect(t.scaffoldBackgroundColor, _black);
        expect(t.canvasColor, _black);
        expect(cs.surface, _black);
        expect(cs.surfaceContainerLowest, _black);
        expect(cs.surfaceContainerLow, _black);
        expect(cs.surfaceContainer, _black);
        expect(cs.surfaceTint, Colors.transparent);
        expect(t.navigationBarTheme.backgroundColor, _black);
        expect(t.navigationRailTheme.backgroundColor, _black);
        expect(t.cardTheme.color, _black);
        expect(t.appBarTheme.surfaceTintColor, Colors.transparent);
        // Highest containers: neutral near-black (never primary-tinted).
        for (final c in [cs.surfaceContainerHigh, cs.surfaceContainerHighest]) {
          expect(_neutral(c), isTrue);
          expect(c.computeLuminance(), lessThan(0.02));
        }
        // Primary (accent / dynamic) is untouched.
        expect(cs.primary,
            dyn?.primary ?? SettingsService.instance.accentColor);
      }
    });

    testWidgets('NavigationBar renders black under pure black', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: SunfireTheme.buildLightTheme(),
        darkTheme: SunfireTheme.buildDarkTheme(dynamicScheme: dynDark, isOled: true),
        themeMode: ThemeMode.dark,
        home: Scaffold(
          appBar: AppBar(title: const Text('x')),
          bottomNavigationBar: NavigationBar(destinations: const [
            NavigationDestination(icon: Icon(Icons.book), label: 'Library'),
            NavigationDestination(icon: Icon(Icons.update), label: 'Updates'),
          ]),
        ),
      ));
      final mats = tester.widgetList<Material>(find.descendant(
          of: find.byType(NavigationBar), matching: find.byType(Material)));
      expect(mats.first.color, _black);
      expect(mats.first.surfaceTintColor, anyOf(isNull, Colors.transparent));
      final scaffoldMat = tester.widget<Material>(find
          .descendant(of: find.byType(Scaffold), matching: find.byType(Material))
          .first);
      expect(scaffoldMat.color, _black);
    });

    test('setting: separate toggle, legacy OLED Black migrates', () {
      final s = SettingsService.instance;
      s.themeMode = 'OLED Black';
      expect(s.pureBlackEnabled, isTrue); // legacy default
      expect(SunfireTheme.themeModeLabel(s.themeMode), 'Dark Theme');
      s.pureBlackEnabled = false;
      expect(SunfireTheme.isOledMode, isFalse);
      s.themeMode = 'System Default';
      s.pureBlackEnabled = true;
      expect(SunfireTheme.isOledMode, isTrue);
      expect(SunfireTheme.effectiveThemeMode, ThemeMode.system);
      expect(SunfireTheme.themeModeOptions, isNot(contains('OLED Black')));
      s.themeMode = 'Dark Theme';
    });
  });

  group('Light still works', () {
    test('light theme is light with or without dynamic colour', () {
      for (final t in [
        SunfireTheme.buildLightTheme(),
        SunfireTheme.buildLightTheme(dynamicScheme: dynLight),
      ]) {
        expect(t.brightness, Brightness.light);
        expect(t.scaffoldBackgroundColor.computeLuminance(), greaterThan(0.5));
        expect(t.navigationBarTheme.backgroundColor!.computeLuminance(),
            greaterThan(0.5));
        final snack = t.snackBarTheme;
        expect(snack.backgroundColor!.computeLuminance(), lessThan(0.3));
        expect(snack.contentTextStyle!.color!.computeLuminance(),
            greaterThan(0.5));
      }
    });
  });

  group('Appearance settings UI', () {
    tearDown(() => AppearanceSettingsScreen.debugShowDynamicOption = null);

    testWidgets('Pure black + Dynamic toggles, picker without OLED Black',
        (tester) async {
      AppearanceSettingsScreen.debugShowDynamicOption = true;
      final s = SettingsService.instance;
      s.pureBlackEnabled = false;
      s.materialYouEnabled = true;
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(MaterialApp(
        theme: SunfireTheme.buildLightTheme(),
        home: const AppearanceSettingsScreen(),
      ));
      await tester.pump();

      expect(find.text('Pure black (AMOLED)'), findsOneWidget);
      expect(find.text('Dynamic colour (Material You)'), findsOneWidget);

      await tester.tap(find.descendant(
          of: find.byKey(const ValueKey('pure_black_toggle')),
          matching: find.byType(Switch)));
      await tester.pump();
      expect(s.pureBlackEnabled, isTrue);

      await tester.tap(find.descendant(
          of: find.byKey(const ValueKey('dynamic_color_toggle')),
          matching: find.byType(Switch)));
      await tester.pump();
      expect(s.materialYouEnabled, isFalse);

      await tester.tap(find.text('Theme Mode'));
      await tester.pumpAndSettle();
      expect(find.text('OLED Black'), findsNothing);
      expect(find.text('Light'), findsOneWidget);
      await tester.tap(find.text('Light'));
      await tester.pumpAndSettle();
      expect(s.themeMode, 'Light');
      s.themeMode = 'Dark Theme';
      s.pureBlackEnabled = false;
      s.materialYouEnabled = true;
    });

    testWidgets('Dynamic option hidden off Android', (tester) async {
      AppearanceSettingsScreen.debugShowDynamicOption = false;
      await tester.pumpWidget(MaterialApp(
        theme: SunfireTheme.buildDarkTheme(isOled: true),
        home: const AppearanceSettingsScreen(),
      ));
      await tester.pump();
      expect(find.text('Dynamic colour (Material You)'), findsNothing);
      expect(find.text('Pure black (AMOLED)'), findsOneWidget);
    });
  });

  testWidgets('iPad sidebar/glass static tint: no blur when reducing effects',
      (tester) async {
    for (final reduce in [false, true]) {
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: IOSGlassTabBar.maybeBlur(
            reduceEffects: reduce, sigma: 28, child: const SizedBox()),
      ));
      expect(find.byType(BackdropFilter), reduce ? findsNothing : findsOneWidget);
    }
  });
}
