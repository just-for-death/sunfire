// UIS-10: SettingsService.dateFormat drives Updates + History date headers,
// and the Date Format tile lives in General settings only.
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunfire/src/core/services/settings_service.dart';
import 'package:sunfire/src/features/history/history_screen.dart';
import 'package:sunfire/src/features/settings/appearance_settings_screen.dart';
import 'package:sunfire/src/features/settings/general_settings_screen.dart';
import 'package:sunfire/src/features/updates/updates_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
    await SettingsService.instance.initialize();
  });

  final now = DateTime(2026, 10, 6, 12);
  final old = DateTime(2026, 1, 5, 9, 30);

  group('History headers', () {
    test('DD/MM/YYYY applies to older dates', () {
      SettingsService.instance.dateFormat = 'DD/MM/YYYY';
      expect(historyDateHeader(old, now), '05/01/2026');
    });
    test('MM/DD/YYYY and default', () {
      SettingsService.instance.dateFormat = 'MM/DD/YYYY';
      expect(historyDateHeader(old, now), '01/05/2026');
      SettingsService.instance.dateFormat = 'YYYY-MM-DD';
      expect(historyDateHeader(old, now), '2026-01-05');
    });
    test('relative labels kept', () {
      SettingsService.instance.dateFormat = 'DD/MM/YYYY';
      expect(historyDateHeader(DateTime(2026, 10, 6, 1), now), 'Today');
      expect(historyDateHeader(DateTime(2026, 10, 5, 23), now), 'Yesterday');
      expect(historyDateHeader(DateTime(2026, 10, 2), now), 'Past Week');
    });
  });

  group('Updates headers', () {
    test('DD.MM.YYYY applies to older dates', () {
      SettingsService.instance.dateFormat = 'DD.MM.YYYY';
      expect(updatesDateHeader(old, now), '05.01.2026');
    });
    test('Today / Yesterday / weekday kept', () {
      SettingsService.instance.dateFormat = 'DD/MM/YYYY';
      expect(updatesDateHeader(DateTime(2026, 10, 6, 1), now), 'Today');
      expect(updatesDateHeader(DateTime(2026, 10, 5), now), 'Yesterday');
      expect(updatesDateHeader(DateTime(2026, 10, 2), now), 'Friday');
    });
  });

  group('Single settings entry', () {
    Future<void> pump(WidgetTester tester, Widget screen) async {
      await tester.binding.setSurfaceSize(const Size(400, 3000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(MaterialApp(home: screen));
      await tester.pump(const Duration(milliseconds: 100));
    }

    testWidgets('General shows Date Format', (tester) async {
      await pump(tester, const GeneralSettingsScreen());
      expect(find.text('Date Format'), findsOneWidget);
    });

    testWidgets('Appearance no longer shows Date Format', (tester) async {
      await pump(tester, const AppearanceSettingsScreen());
      expect(find.text('Date Format'), findsNothing);
      expect(find.text('Date & Time Formatting'), findsNothing);
    });
  });
}
