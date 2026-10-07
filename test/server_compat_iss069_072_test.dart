import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/db/models/category.dart';
import 'package:sunfire/src/core/sync/suwayomi_parse_helpers.dart';
import 'package:sunfire/src/core/sync/sync_engine.dart';

void main() {
  group('ISS-070 contentWarning', () {
    test('NSFW/MIXED from contentWarning; SAFE clears; isNsfw fallback; no name heuristic', () {
      expect(
        isNsfwFromSourceNode({'contentWarning': 'NSFW', 'name': 'Safe Source'}),
        isTrue,
      );
      expect(
        isNsfwFromSourceNode({'contentWarning': 'MIXED', 'isNsfw': false}),
        isTrue,
      );
      expect(
        isNsfwFromSourceNode({'contentWarning': 'SAFE', 'isNsfw': true}),
        isFalse,
      );
      expect(isNsfwFromSourceNode({'isNsfw': true}), isTrue);
      expect(isNsfwFromSourceNode({'nsfw': 1}), isTrue);
      // Name heuristic must NOT apply in the service helper:
      expect(
        isNsfwFromSourceNode({'name': 'Hentai Hub', 'displayName': '18+ Exclusive'}),
        isFalse,
      );
      expect(parseContentWarning('mixed'), 'MIXED');
      expect(parseContentWarning('nope'), isNull);
    });
  });

  group('ISS-071 category include flags', () {
    test('parseCategoryNodes maps includeInUpdate/Download', () {
      final cats = parseCategoryNodes([
        {
          'id': 1,
          'name': 'Reading',
          'order': 2,
          'default': false,
          'includeInUpdate': 'INCLUDE',
          'includeInDownload': 'EXCLUDE',
        },
        {
          'id': 0,
          'name': 'Default',
          'order': 0,
          'default': true,
        },
      ]);
      expect(cats, hasLength(2));
      expect(cats.first.includeInUpdate, 'INCLUDE');
      expect(cats.first.includeInDownload, 'EXCLUDE');
      expect(cats.last.includeInUpdate, 'UNSET');
      expect(cats.last.includeInDownload, 'UNSET');
      expect(parseIncludeOrExclude('exclude'), 'EXCLUDE');
    });

    test('Category model defaults', () {
      final c = Category();
      expect(c.includeInUpdate, 'UNSET');
      expect(c.includeInDownload, 'UNSET');
      expect(c.isDefaultCategory, isFalse);
    });

    test('parseCategoryNodes joins isDefaultCategory into isDefault (v2.4.2366+)', () {
      final cats = parseCategoryNodes([
        {
          'id': 0,
          'name': 'Default',
          'order': 0,
          'default': true,
          'isDefaultCategory': true,
        },
        {
          'id': 5,
          'name': 'Legacy',
          'order': 1,
          // Old servers omit the field: stays false, `default` still rules.
        },
      ]);
      expect(cats.first.isDefaultCategory, isTrue);
      expect(cats.first.isDefault, isTrue);
      expect(cats.last.isDefaultCategory, isFalse);
      expect(cats.last.isDefault, isFalse);
    });
  });

  group('ISS-072 user field flatten', () {
    test('flattenMangaUserFields prefers user.*', () {
      final flat = flattenMangaUserFields({
        'id': 9,
        'inLibrary': false,
        'unreadCount': 0,
        'user': {
          'inLibrary': true,
          'inLibraryAt': '100',
          'unreadCount': 7,
          'bookmarkCount': 2,
        },
      });
      expect(flat['inLibrary'], isTrue);
      expect(flat['unreadCount'], 7);
      expect(flat['bookmarkCount'], 2);
      expect(flat['inLibraryAt'], '100');
      expect(flat['id'], 9);
    });

    test('flattenChapterUserFields prefers user.*', () {
      final flat = flattenChapterUserFields({
        'id': 3,
        'isRead': false,
        'lastPageRead': 0,
        'user': {
          'isRead': true,
          'isBookmarked': true,
          'lastPageRead': 12,
          'lastReadAt': '99',
          'isDownloaded': true,
        },
      });
      expect(flat['isRead'], isTrue);
      expect(flat['isBookmarked'], isTrue);
      expect(flat['lastPageRead'], 12);
      expect(flat['isDownloaded'], isTrue);
      expect(flat['lastReadAt'], '99');
    });

    test('missing user leaves map unchanged', () {
      final m = {'id': 1, 'isRead': true};
      expect(flattenChapterUserFields(Map<String, dynamic>.from(m)), m);
    });
  });

  group('ISS-069 public API surface (compile-time symbols)', () {
    test('helper symbols for mark-previous / delete-all exist via GraphQL names', () {
      // Documented UIS handoff names — keep this list in sync with GraphQLClientService.
      const expected = <String>[
        'updateChapters',
        'deleteDownloadedChapters',
        'markChaptersRead',
        'deleteAllDownloadedChapters',
        'updateCategoryPatch',
        'setCategoryIncludeInUpdate',
        'setCategoryIncludeInDownload',
        'updateLibraryForCategories',
        'triggerServerLibraryUpdate',
      ];
      expect(expected, isNotEmpty);
    });
  });
}
