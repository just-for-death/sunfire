import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/features/settings/library_settings_screen.dart';
import 'package:sunfire/src/ui/widgets/library_update_progress_banner.dart';

void main() {
  group('categoryNeverUpdatedWarning', () {
    test('null when zero', () {
      expect(categoryNeverUpdatedWarning(0), isNull);
    });

    test('singular and plural', () {
      expect(
        categoryNeverUpdatedWarning(1),
        '1 manga is never updated (in excluded categories).',
      );
      expect(
        categoryNeverUpdatedWarning(76),
        '76 manga are never updated (in excluded categories).',
      );
    });
  });

  group('libraryUpdateSkippedLabel still ok', () {
    test('combined', () {
      expect(
        libraryUpdateSkippedLabel(skippedCategoriesCount: 1, skippedMangasCount: 2),
        '1 category skipped · 2 manga skipped',
      );
    });
  });
}
