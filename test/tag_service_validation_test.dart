// L10.2: pure validation for TagService (no Isar).

import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/services/tag_service.dart';

void main() {
  group('TagService.normalizeTagName', () {
    test('trims whitespace', () {
      expect(TagService.normalizeTagName('  Seinen  '), 'Seinen');
    });

    test('rejects blank / whitespace-only', () {
      expect(TagService.normalizeTagName(''), isNull);
      expect(TagService.normalizeTagName('   '), isNull);
      expect(TagService.normalizeTagName('\t\n'), isNull);
    });
  });

  group('TagService.isValidTagColor', () {
    test('accepts #RRGGBB', () {
      expect(TagService.isValidTagColor('#FF5722'), isTrue);
      expect(TagService.isValidTagColor('#00ffaa'), isTrue);
    });

    test('rejects shorthand, missing hash, alpha, garbage', () {
      expect(TagService.isValidTagColor('#FFF'), isFalse);
      expect(TagService.isValidTagColor('FF5722'), isFalse);
      expect(TagService.isValidTagColor('#FF5722AA'), isFalse);
      expect(TagService.isValidTagColor('red'), isFalse);
      expect(TagService.isValidTagColor(''), isFalse);
    });
  });
}
