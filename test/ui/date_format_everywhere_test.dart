// UIS-P3-3: the Date Format setting is used everywhere dates are shown
// (tracker start/finish dates, extension chapter dates), not only on
// Updates/History/manga-detail uploadDate.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunfire/src/core/services/settings_service.dart';
import 'package:sunfire/src/features/manga_detail/tracking_bottom_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
    await SettingsService.instance.initialize();
  });

  final date = DateTime(2026, 1, 5, 9, 30);

  test('tracking date label follows each format', () {
    final s = SettingsService.instance;
    s.dateFormat = 'YYYY-MM-DD';
    expect(trackingDateLabel(date), '2026-01-05');
    s.dateFormat = 'DD/MM/YYYY';
    expect(trackingDateLabel(date), '05/01/2026');
    s.dateFormat = 'MM/DD/YYYY';
    expect(trackingDateLabel(date), '01/05/2026');
    s.dateFormat = 'DD.MM.YYYY';
    expect(trackingDateLabel(date), '05.01.2026');
  });

  testWidgets('tracking date chip re-renders when the setting changes',
      (tester) async {
    final s = SettingsService.instance;
    s.dateFormat = 'DD.MM.YYYY';
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ListenableBuilder(
          listenable: s,
          builder: (_, __) => ActionChip(
            label: Text(trackingDateLabel(date)),
            onPressed: () {},
          ),
        ),
      ),
    ));
    expect(find.text('05.01.2026'), findsOneWidget);
    s.dateFormat = 'MM/DD/YYYY';
    await tester.pump();
    expect(find.text('01/05/2026'), findsOneWidget);
    expect(find.text('05.01.2026'), findsNothing);
  });

  test('no hard-coded display date patterns left in features', () {
    final offenders = <String>[];
    final banned = RegExp(
        r"DateFormat\('(MM/dd/yyyy|dd/MM/yyyy|yyyy-MM-dd)'\)\.format|DateFormat\.yMMMd\(\)\.format|DateFormat\.yMd\(\)\.format");
    for (final f in Directory('lib/src/features')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      if (banned.hasMatch(f.readAsStringSync())) offenders.add(f.path);
    }
    expect(offenders, isEmpty);
  });

  test('manga detail extension dates route through formatDate', () {
    final src = File('lib/src/features/manga_detail/manga_detail_screen.dart')
        .readAsStringSync();
    expect(src.contains("return raw.split('T')[0];\n      }"), isFalse);
    expect(RegExp(r'_settings\.formatDate\(').allMatches(src).length,
        greaterThanOrEqualTo(3));
  });
}
