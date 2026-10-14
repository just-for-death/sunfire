// IMP-013: the reader controller resolves the per-series override at chapter
// open (series value beats global; "All" = withValue(key, null) restores it).
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunfire/src/core/db/models/manga.dart';
import 'package:sunfire/src/core/services/settings_service.dart';
import 'package:sunfire/src/features/reader/controller/reader_controller.dart';
import 'package:sunfire/src/features/reader/reader_settings_scope.dart';

void main() {
  late SettingsService s;
  final manga = Manga()..id = 42;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    s = SettingsService.instance;
    await s.initialize();
    s.cropBorders = false;
    s.scaleType = 'Fit Width';
  });

  test('a series override beats the global value', () async {
    await saveReaderSettingsOverride(
        s, manga.id, const ReaderSettingsOverride(cropBorders: true, scaleType: 'Fit Height'));
    manga.readingModeOverride = 'Paged Vertical';
    final v = ReaderController.resolveSeriesSettings(s, manga);
    expect(v.cropBorders, isTrue);
    expect(v.scaleType, 'Fit Height');
    expect(v.readingMode, 'Paged Vertical');
    manga.readingModeOverride = null;
  });

  test('choosing All (withValue(key, null)) brings the global value back', () async {
    await saveReaderSettingsOverride(s, manga.id, const ReaderSettingsOverride(cropBorders: true));
    final cur = loadReaderSettingsOverride(s, manga.id);
    await saveReaderSettingsOverride(s, manga.id, cur.withValue('cropBorders', null));
    final v = ReaderController.resolveSeriesSettings(s, manga);
    expect(v.cropBorders, isFalse);
    expect(s.readerOverrideJson(manga.id), isNull);
  });
}
