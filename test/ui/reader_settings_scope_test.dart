import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/features/reader/reader_settings_scope.dart';

void main() {
  group('initialReaderSettingsScope', () {
    test('manga when override present', () {
      expect(initialReaderSettingsScope('Long Strip'), ReaderSettingsScope.manga);
      expect(initialReaderSettingsScope('  Paged RTL '), ReaderSettingsScope.manga);
    });
    test('global when override missing', () {
      expect(initialReaderSettingsScope(null), ReaderSettingsScope.global);
      expect(initialReaderSettingsScope(''), ReaderSettingsScope.global);
      expect(initialReaderSettingsScope('   '), ReaderSettingsScope.global);
    });
  });

  group('planReadingModePersist', () {
    test('manga scope writes override only', () {
      final plan = planReadingModePersist(
        scope: ReaderSettingsScope.manga,
        modeValue: 'Paged RTL',
        hasManga: true,
      );
      expect(plan.globalValue, isNull);
      expect(plan.mangaOverride, 'Paged RTL');
      expect(plan.clearMangaOverride, isFalse);
    });

    test('manga scope without manga falls back to global', () {
      final plan = planReadingModePersist(
        scope: ReaderSettingsScope.manga,
        modeValue: 'Paged LTR',
        hasManga: false,
      );
      expect(plan.globalValue, 'Paged LTR');
      expect(plan.clearMangaOverride, isFalse);
    });

    test('global scope writes settings and clears override', () {
      final plan = planReadingModePersist(
        scope: ReaderSettingsScope.global,
        modeValue: 'Long Strip',
        hasManga: true,
      );
      expect(plan.globalValue, 'Long Strip');
      expect(plan.mangaOverride, isNull);
      expect(plan.clearMangaOverride, isTrue);
    });
  });
}
