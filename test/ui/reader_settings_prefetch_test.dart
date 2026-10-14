import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunfire/src/core/services/settings_service.dart';
import 'package:sunfire/src/features/settings/reader_settings_screen.dart';

Future<void> _pick(WidgetTester tester, String tile, String option) async {
  await tester.scrollUntilVisible(find.text(tile), 200, scrollable: find.byType(Scrollable).first);
  await tester.tap(find.text(tile));
  await tester.pumpAndSettle();
  await tester.tap(find.text(option).last);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SettingsService.instance.initialize();
  });

  testWidgets('IMP-016 Prefetch picker saves Wi-Fi only', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ReaderSettingsScreen()));
    await tester.pumpAndSettle();
    await _pick(tester, 'Prefetch next chapter', 'Wi-Fi only');
    expect(SettingsService.instance.prefetchNextChapter, SettingsService.prefetchWifiOnly);
  });

  testWidgets('IMP-014 Page transition picker saves Fade', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ReaderSettingsScreen()));
    await tester.pumpAndSettle();
    await _pick(tester, 'Page transition', 'Fade');
    expect(SettingsService.instance.pageTransition, 'fade');
  });
}
