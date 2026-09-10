import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/engine/source_icon_helper.dart';

void main() {
  group('SourceIconHelper FOSS icons (v11)', () {
    test('rejects Google favicon CDN URLs', () {
      expect(
        SourceIconHelper.isUnusableIconUrl(
          'https://www.google.com/s2/favicons?domain=example.com&sz=128',
        ),
        isTrue,
      );
      expect(
        SourceIconHelper.sanitizeIconUrl(
          'https://www.google.com/s2/favicons?domain=example.com&sz=128',
        ),
        isEmpty,
      );
    });

    test('keeps normal https icons', () {
      expect(
        SourceIconHelper.sanitizeIconUrl('https://cdn.example/icon.png'),
        'https://cdn.example/icon.png',
      );
    });

    test('resolves bundled asset URIs for shipped sources', () {
      expect(
        SourceIconHelper.bundledAssetUriForName('Weeb Central'),
        'asset:assets/icons/sources/weeb_central.png',
      );
      expect(
        SourceIconHelper.bundledAssetUriForName('Read Comics Online'),
        'asset:assets/icons/sources/read_comics_online.png',
      );
      expect(
        SourceIconHelper.resolveIcon(iconUrl: '', sourceName: 'Mangapill'),
        'asset:assets/icons/sources/mangapill.png',
      );
      expect(SourceIconHelper.isAssetIcon('asset:assets/icons/sources/mangago.png'), isTrue);
      expect(
        SourceIconHelper.assetPathFromUri('asset:assets/icons/sources/mangago.png'),
        'assets/icons/sources/mangago.png',
      );
    });

    test('sanitize prefers explicit asset over empty network', () {
      expect(
        SourceIconHelper.sanitizeIconUrl(
          'asset:assets/icons/sources/webtoons.png',
          sourceName: 'Webtoons',
        ),
        'asset:assets/icons/sources/webtoons.png',
      );
    });

    test('letterAvatar uses first rune', () {
      expect(SourceIconHelper.letterAvatar('manga'), 'M');
      expect(SourceIconHelper.letterAvatar(''), '#');
    });
  });
}
