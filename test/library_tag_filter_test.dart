import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/features/library/library_tag_filter.dart';

void main() {
  group('mangaMatchesTagFilter', () {
    test('null/zero selected means no filter', () {
      expect(
        mangaMatchesTagFilter(mangaTagIds: const [1, 2], selectedTagId: null),
        isTrue,
      );
      expect(
        mangaMatchesTagFilter(mangaTagIds: const [], selectedTagId: 0),
        isTrue,
      );
    });

    test('requires membership when a tag is selected', () {
      expect(
        mangaMatchesTagFilter(mangaTagIds: const [3, 7], selectedTagId: 7),
        isTrue,
      );
      expect(
        mangaMatchesTagFilter(mangaTagIds: const [3], selectedTagId: 7),
        isFalse,
      );
    });
  });

  group('countMangaWithTag', () {
    test('counts titles that include the tag', () {
      expect(
        countMangaWithTag([
          [1],
          [1, 2],
          [3],
        ], 1),
        2,
      );
    });
  });
}
