// UIS-04 (respect Material You primary) and UIS-05 (readable light chips).
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunfire/src/core/services/settings_service.dart';
import 'package:sunfire/src/ui/design_system/sunfire_theme.dart';

double contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // UIX-01 (secure-storage guard) may not be merged yet.
    FlutterSecureStorage.setMockInitialValues({});
  });

  group('UIS-04 Material You primary', () {
    final dynamicLight =
        ColorScheme.fromSeed(seedColor: Colors.green, brightness: Brightness.light);
    final dynamicDark =
        ColorScheme.fromSeed(seedColor: Colors.green, brightness: Brightness.dark);

    test('light theme keeps the dynamic primary', () {
      final theme = SunfireTheme.buildLightTheme(dynamicScheme: dynamicLight);
      expect(theme.colorScheme.primary, dynamicLight.primary);
      expect(theme.colorScheme.onPrimary, dynamicLight.onPrimary);
      expect(theme.floatingActionButtonTheme.backgroundColor, dynamicLight.primary);
      expect(theme.floatingActionButtonTheme.foregroundColor, dynamicLight.onPrimary);
    });

    test('dark theme (and OLED) keeps the dynamic primary', () {
      for (final oled in [false, true]) {
        final theme =
            SunfireTheme.buildDarkTheme(dynamicScheme: dynamicDark, isOled: oled);
        expect(theme.colorScheme.primary, dynamicDark.primary);
        expect(theme.tabBarTheme.labelColor, dynamicDark.primary);
      }
    });

    test('without dynamic colour, primary derives from the accent', () {
      final accent = SettingsService.instance.accentColor;
      expect(SunfireTheme.buildLightTheme().colorScheme.primary, accent);
      expect(SunfireTheme.buildDarkTheme().colorScheme.primary, accent);
      final fab = SunfireTheme.buildDarkTheme().floatingActionButtonTheme;
      expect(fab.foregroundColor, SunfireTheme.buildDarkTheme().colorScheme.onPrimary);
    });

    test('onPrimary contrast >= 4.5 for every accent', () {
      for (final entry in SettingsService.accentColors.entries) {
        final on = SunfireTheme.onColorFor(entry.value);
        expect(contrast(on, entry.value), greaterThanOrEqualTo(4.5),
            reason: '${entry.key} onPrimary contrast');
      }
      final light = SunfireTheme.buildLightTheme().colorScheme;
      final dark = SunfireTheme.buildDarkTheme().colorScheme;
      expect(contrast(light.onPrimary, light.primary), greaterThanOrEqualTo(4.5));
      expect(contrast(dark.onPrimary, dark.primary), greaterThanOrEqualTo(4.5));
    });
  });

  group('UIS-05 chips', () {
    test('light chip label is dark and readable on white (>= 4.5)', () {
      final chip = SunfireTheme.buildLightTheme().chipTheme;
      expect(contrast(chip.labelStyle!.color!, Colors.white), greaterThanOrEqualTo(4.5));
      expect(chip.brightness, Brightness.light);
    });

    test('dark chip keeps light label and dark brightness', () {
      final chip = SunfireTheme.buildDarkTheme().chipTheme;
      expect(chip.labelStyle!.color, Colors.white70);
      expect(chip.brightness, Brightness.dark);
    });
  });

  group('UIS-23 (revised) Light + System theme modes', () {
    test('setting resolves to the right ThemeMode', () {
      expect(SunfireTheme.themeModeFor('Light'), ThemeMode.light);
      expect(SunfireTheme.themeModeFor('System Default'), ThemeMode.system);
      expect(SunfireTheme.themeModeFor('Dark Theme'), ThemeMode.dark);
      expect(SunfireTheme.themeModeFor('OLED Black'), ThemeMode.dark);
      expect(SunfireTheme.themeModeFor('something-legacy'), ThemeMode.dark);
    });

    test('effectiveThemeMode follows the stored setting', () async {
      SharedPreferences.setMockInitialValues({});
      final settings = SettingsService.instance;
      await settings.initialize();
      final original = settings.themeMode;
      addTearDown(() => settings.themeMode = original);
      settings.themeMode = 'Light';
      expect(SunfireTheme.effectiveThemeMode, ThemeMode.light);
      settings.themeMode = 'System Default';
      expect(SunfireTheme.effectiveThemeMode, ThemeMode.system);
      settings.themeMode = 'Dark Theme';
      expect(SunfireTheme.effectiveThemeMode, ThemeMode.dark);
      settings.themeMode = 'OLED Black';
      expect(SunfireTheme.effectiveThemeMode, ThemeMode.dark);
      expect(SunfireTheme.isOledMode, isTrue);
    });

    test('light theme is actually light', () {
      final t = SunfireTheme.buildLightTheme();
      expect(t.brightness, Brightness.light);
      expect(t.colorScheme.surface.computeLuminance(), greaterThan(0.5));
    });
  });
}
