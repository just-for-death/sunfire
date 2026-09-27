import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/engine/chapter_url_attribution.dart';

void main() {
  group('chapterUrlBelongsToMangaPage', () {
    test('accepts chapters nested under the manga page', () {
      expect(
        chapterUrlBelongsToMangaPage(
          'https://readcomicsonline.ru/comic/absolute-superman-2024',
          'https://readcomicsonline.ru/comic/absolute-superman-2024/16',
        ),
        isTrue,
      );
    });

    test('rejects chapters of a different series on the same host', () {
      expect(
        chapterUrlBelongsToMangaPage(
          'https://readcomicsonline.ru/comic/absolute-superman-2024',
          'https://readcomicsonline.ru/comic/absolute-batman-2024/annual2025',
        ),
        isFalse,
      );
    });

    test('rejects bare series links (related-comic cards)', () {
      expect(
        chapterUrlBelongsToMangaPage(
          'https://readcomicsonline.ru/comic/absolute-superman-2024',
          'https://readcomicsonline.ru/comic/absolute-batman-2024',
        ),
        isFalse,
      );
    });

    test('is case-insensitive on host and slug', () {
      expect(
        chapterUrlBelongsToMangaPage(
          'https://readcomicsonline.ru/comic/Absolute-Superman-2024/',
          'https://readcomicsonline.ru/comic/absolute-superman-2024/16',
        ),
        isTrue,
      );
    });

    test('passes through when either url is empty or unparseable', () {
      expect(chapterUrlBelongsToMangaPage('', 'https://readcomicsonline.ru/comic/x/1'), isTrue);
      expect(chapterUrlBelongsToMangaPage('https://readcomicsonline.ru/comic/x', ''), isTrue);
      expect(chapterUrlBelongsToMangaPage('not a url', 'also not a url'), isTrue);
    });

    test('passes through cross-host and non-/comic/ shapes (cannot judge)', () {
      // WeebCentral ULID chapter urls carry no series slug — must not filter.
      expect(
        chapterUrlBelongsToMangaPage(
          'https://weebcentral.com/series/01J76XYD4FZAAZ5VQ0R9AHQ2GQ/1000-Yen-Hero',
          'https://weebcentral.com/chapters/01J76XZ5P7NFPNFMGVQMSJG924/images?is_prev=False',
        ),
        isTrue,
      );
      // Mangago manga vs chapter path shapes differ — must not filter.
      expect(
        chapterUrlBelongsToMangaPage(
          'https://www.mangago.me/manga/one-piece',
          'https://www.mangago.me/read-manga/one_piece/uu/br2/chapter-1/',
        ),
        isTrue,
      );
    });
  });
}
