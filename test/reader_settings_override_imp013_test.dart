// IMP-013 (UIX model): ReaderSettingsOverride.
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunfire/src/core/services/settings_service.dart';
import 'package:sunfire/src/features/reader/reader_settings_scope.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const global = ReaderSettingsValues(
    readingMode: 'Long Strip', scaleType: 'Fit Width', pageTransition: 'slide',
    rotateWidePages: false, cropBorders: false, doublePageDisplayMode: 'Single',
    doublePageOffset: false, invertTapZones: false,
  );

  test('empty override resolves to global', () {
    final r = ReaderSettingsOverride.empty.resolve(global);
    expect(ReaderSettingsOverride.empty.isEmpty, isTrue);
    expect(r.readingMode, 'Long Strip');
    expect(r.pageTransition, 'slide');
  });

  test('set fields win, null / blank fall back, withValue(null) clears', () {
    final o = const ReaderSettingsOverride(pageTransition: 'fade', scaleType: '  ', cropBorders: true);
    final r = o.resolve(global);
    expect(r.pageTransition, 'fade');
    expect(r.scaleType, 'Fit Width');
    expect(r.cropBorders, isTrue);
    expect(o.withValue('cropBorders', null).withValue('pageTransition', null).isEmpty, isTrue);
  });

  test('json round-trip ignores bad types and unknown keys', () {
    final o = ReaderSettingsOverride.fromJson({'rotateWidePages': true, 'pageTransition': 3, 'zzz': 'x'});
    expect(o.toJson(), {'rotateWidePages': true});
    expect(ReaderSettingsOverride.fromJson(o.toJson()).rotateWidePages, isTrue);
  });

  test('persists per manga, folds Isar reading mode, empty deletes', () async {
    SharedPreferences.setMockInitialValues({});
    final s = SettingsService.instance;
    await s.initialize();
    await saveReaderSettingsOverride(s, 7, const ReaderSettingsOverride(pageTransition: 'none'));
    final o = loadReaderSettingsOverride(s, 7, readingModeOverride: 'Paged LTR');
    expect(o.pageTransition, 'none');
    expect(o.readingMode, 'Paged LTR');
    expect(loadReaderSettingsOverride(s, 8).isEmpty, isTrue);
    await saveReaderSettingsOverride(s, 7, ReaderSettingsOverride.empty);
    expect(s.readerOverrideJson(7), isNull);
  });
}
