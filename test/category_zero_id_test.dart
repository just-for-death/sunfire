// Regression test: Suwayomi's built-in "Default" category is id 0.
// A `> 0` guard in the library pull dropped it, so every manga in Default
// ended up with no category assignment and the Library's Default tab read 0
// even though the server listed manga under DEFAULT.
//
// Run: flutter test test/category_zero_id_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/sync/sync_engine.dart';

void main() {
  group('parseMangaCategoryIds (category id 0 is the Default category)', () {
    test('keeps id 0 alongside other ids', () {
      final ids = parseMangaCategoryIds([
        {'id': 0, 'name': 'Default'},
        {'id': 3, 'name': 'Download '},
        {'id': 6, 'name': 'Comics '},
      ]);
      expect(ids, [0, 3, 6]);
    });

    test('keeps a lone id 0', () {
      expect(
        parseMangaCategoryIds([
          {'id': 0, 'name': 'Default'},
        ]),
        [0],
      );
    });

    test('drops malformed nodes instead of mapping them to Default', () {
      // parseIntSafe reports missing/non-numeric ids as its fallback; the
      // -1 sentinel keeps such nodes out of the Default (0) bucket.
      final ids = parseMangaCategoryIds([
        {'name': 'NoId'},
        {'id': 'abc', 'name': 'BadId'},
        {'id': null, 'name': 'NullId'},
        {'id': 0, 'name': 'Default'},
      ]);
      expect(ids, [0]);
    });

    test('drops negative synthetic ids', () {
      expect(
        parseMangaCategoryIds([
          {'id': -123, 'name': 'LocalOnly'},
          {'id': 1, 'name': 'Reading'},
        ]),
        [1],
      );
    });

    test('accepts string-encoded ids, including "0"', () {
      expect(
        parseMangaCategoryIds([
          {'id': '0', 'name': 'Default'},
          {'id': '2', 'name': 'Later'},
        ]),
        [0, 2],
      );
    });

    test('returns empty for non-list input', () {
      expect(parseMangaCategoryIds(null), isEmpty);
      expect(parseMangaCategoryIds('nope'), isEmpty);
      expect(parseMangaCategoryIds({'id': 0}), isEmpty);
    });

    test('empty list is implicit Default (id 0)', () {
      // Suwayomi web UI: in-library manga with no category nodes live in
      // Default. Leaving this as [] made Default permanently read (0).
      expect(parseMangaCategoryIds(<dynamic>[]), [0]);
    });
  });

  group('mangaBelongsToCategory (Default = id 0 or uncategorised)', () {
    test('Default matches empty ids and explicit 0', () {
      expect(mangaBelongsToCategory(const [], 0), isTrue);
      expect(mangaBelongsToCategory(const [0], 0), isTrue);
      expect(mangaBelongsToCategory(const [0, 4], 0), isTrue);
      expect(mangaBelongsToCategory(const [1], 0), isFalse);
      expect(mangaBelongsToCategory(const [4, 5], 0), isFalse);
    });

    test('non-Default is a straight membership check', () {
      expect(mangaBelongsToCategory(const [1, 4], 4), isTrue);
      expect(mangaBelongsToCategory(const [1, 4], 2), isFalse);
      expect(mangaBelongsToCategory(const [], 4), isFalse);
      expect(mangaBelongsToCategory(const [0], 4), isFalse);
    });
  });

  group('isCategoryPullAcceptable (id-0 baseline)', () {
    test('counts the Default category in the existing shelf', () {
      // Shelf of 8 server-linked categories including Default (id 0):
      // a pull returning all 8 must be acceptable.
      expect(
        isCategoryPullAcceptable(
          snapshotComplete: true,
          incoming: 8,
          existingServerLinked: 8,
        ),
        isTrue,
      );
    });
  });

  group('parseCategoryNodes (UIX-14: malformed ids skipped, Default preserved)', () {
    test('[{id:0,name:Default},{name:broken}] → only [0]', () {
      final cats = parseCategoryNodes(<dynamic>[
        <String, dynamic>{'id': 0, 'name': 'Default', 'order': 0, 'default': true},
        <String, dynamic>{'name': 'broken'},
      ]);
      expect(cats.map((c) => c.serverId), [0]);
      expect(cats.single.name, 'Default');
      expect(cats.single.isDefault, isTrue);
    });

    test('non-numeric, negative and non-map nodes are skipped; string ids parse', () {
      final cats = parseCategoryNodes(<dynamic>[
        <String, dynamic>{'id': 'abc', 'name': 'x'},
        <String, dynamic>{'id': -3, 'name': 'neg'},
        'garbage',
        <String, dynamic>{'id': '7', 'name': '  Reading  ', 'order': 2},
      ]);
      expect(cats.map((c) => c.serverId), [7]);
      expect(cats.single.name, 'Reading');
      expect(cats.single.order, 2);
    });

    test('fallback name is used when name is missing', () {
      expect(parseCategoryNodes(<dynamic>[<String, dynamic>{'id': 4}], fallbackName: 'Category').single.name, 'Category');
    });
  });
}
