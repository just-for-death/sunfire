// UIS-P3-1: AppTheme merged into SunfireTheme (single theme), and ISS-047:
// manga detail overlays use brightness-aware SunfireTheme / ColorScheme
// colours so Light works while Dark, Pure black and Material You keep their
// look.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunfire/src/core/services/settings_service.dart';
import 'package:sunfire/src/ui/design_system/sunfire_theme.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

class _Probe {
  late ColorScheme cs;
  late Color tile, border, hairline, overlay;
}

Future<_Probe> _pump(WidgetTester tester, ThemeData theme) async {
  final p = _Probe();
  await tester.pumpWidget(MaterialApp(
    theme: theme,
    home: Scaffold(
      body: Builder(builder: (context) {
        p
          ..cs = Theme.of(context).colorScheme
          ..tile = SunfireTheme.tileSurface(context)
          ..border = SunfireTheme.tileBorder(context)
          ..hairline = SunfireTheme.hairline(context)
          ..overlay = SunfireTheme.overlayFill(context);
        return Column(children: [
          Container(
            key: const Key('tile'),
            color: SunfireTheme.tileSurface(context),
            child: Text('Synopsis',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
          Divider(color: SunfireTheme.hairline(context)),
        ]);
      }),
    ),
  ));
  return p;
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

  group('UIS-P3-1 single theme', () {
    test('app_theme.dart is gone and nothing references AppTheme', () {
      expect(File('lib/src/core/theme/app_theme.dart').existsSync(), isFalse);
      final hits = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .where((f) {
        final src = f.readAsStringSync();
        return RegExp(r'\bAppTheme\.|class AppTheme\b|app_theme\.dart')
            .hasMatch(src);
      }).map((f) => f.path).toList();
      expect(hits, isEmpty);
    });

    test('unused SunfireTheme.isDarkMode is removed', () {
      final src =
          File('lib/src/ui/design_system/sunfire_theme.dart').readAsStringSync();
      expect(src.contains('isDarkMode'), isFalse);
    });

    test('former AppTheme glass tokens live on SunfireTheme', () {
      expect(SunfireTheme.glassSurface, const Color(0x1F2A2A32));
      expect(SunfireTheme.glassBorder, const Color(0x2BFFFFFF));
      expect(SunfireTheme.buildDarkTheme().chipTheme.backgroundColor,
          SunfireTheme.glassSurface);
    });
  });

  group('merged theme helpers by mode', () {
    testWidgets('Dark keeps the original glass colours', (tester) async {
      for (final theme in [
        SunfireTheme.buildDarkTheme(),
        SunfireTheme.buildDarkTheme(isOled: true),
        SunfireTheme.buildDarkTheme(dynamicScheme: dynDark),
        SunfireTheme.buildDarkTheme(dynamicScheme: dynDark, isOled: true),
      ]) {
        final p = await _pump(tester, theme);
        expect(p.tile, SunfireTheme.glassSurface);
        expect(p.border, SunfireTheme.glassBorder);
        expect(p.hairline, SunfireTheme.glassHairline);
        expect(p.overlay, SunfireTheme.glassOverlay);
      }
    });

    testWidgets('Light uses scheme roles, never white overlays',
        (tester) async {
      for (final theme in [
        SunfireTheme.buildLightTheme(),
        SunfireTheme.buildLightTheme(dynamicScheme: dynLight),
      ]) {
        final p = await _pump(tester, theme);
        expect(p.cs.brightness, Brightness.light);
        expect(p.border, p.cs.outlineVariant);
        expect(p.hairline, p.cs.outlineVariant);
        expect(p.overlay, p.cs.onSurface.withValues(alpha: 0.08));
        for (final c in [p.tile, p.border, p.hairline, p.overlay]) {
          expect(c, isNot(SunfireTheme.glassSurface));
          expect(c, isNot(SunfireTheme.glassBorder));
          expect(c, isNot(SunfireTheme.glassHairline));
          expect(c, isNot(SunfireTheme.glassOverlay));
        }
        // Secondary text on a glass tile composited over the page is readable.
        final tileOnPage =
            Color.alphaBlend(p.tile, theme.scaffoldBackgroundColor);
        expect(_contrast(p.cs.onSurfaceVariant, tileOnPage),
            greaterThanOrEqualTo(4.5));
        expect(_contrast(p.cs.onSurface, theme.scaffoldBackgroundColor),
            greaterThanOrEqualTo(7));
        final text = tester.widget<Text>(find.text('Synopsis'));
        expect(text.style!.color, p.cs.onSurfaceVariant);
      }
    });
  });

  test('ISS-047: manga detail has no hard-coded white/glass overlays', () {
    final src = File('lib/src/features/manga_detail/manga_detail_screen.dart')
        .readAsStringSync();
    for (final bad in [
      'Colors.white',
      '0x1AFFFFFF',
      '0x2BFFFFFF',
      '0x1F2A2A32',
      '0x33FFFFFF',
    ]) {
      expect(src.contains(bad), isFalse, reason: '$bad still in manga detail');
    }
  });

  test('ISS-044: leftover screens have no banned dark/white hard-codes', () {
    const banned = [
      'Colors.white',
      '0xFF0D0D11',
      '0xFF191924',
      '0xFF14141C',
      '0xFF1B1B22',
      '0xFF17171F',
      '0xFF16161E',
      '0xFF16161F',
      '0xFF141419',
      '0xFF1F1F24',
      '0xFF2A2A32',
      '0xFF131318',
      '0xDD0F0F14',
      '0x1F2A2A32',
      '0x2BFFFFFF',
    ];
    const files = [
      'lib/src/features/onboarding/onboarding_screen.dart',
      'lib/src/features/manga_detail/tracking_bottom_sheet.dart',
      'lib/src/features/browse/source_manga_grid_screen.dart',
      'lib/src/features/browse/global_search_screen.dart',
      'lib/src/core/theme/ambient_palette.dart',
    ];
    for (final path in files) {
      final src = File(path).readAsStringSync();
      for (final bad in banned) {
        // source grid / search only banned the dark placeholder hexes + glass;
        // Colors.white elsewhere on those screens is out of ISS-044 scope.
        if (bad == 'Colors.white' &&
            (path.contains('source_manga_grid') ||
                path.contains('global_search'))) {
          continue;
        }
        expect(src.contains(bad), isFalse,
            reason: '$bad still in $path');
      }
    }
    // Reader live preview must not hard-code the old dark canvas hexes.
    final reader =
        File('lib/src/features/settings/reader_settings_screen.dart')
            .readAsStringSync();
    for (final bad in ['0xFF131318', '0xDD0F0F14', '0xFF1F1F24']) {
      expect(reader.contains(bad), isFalse,
          reason: '$bad still in reader settings preview');
    }
  });
}
