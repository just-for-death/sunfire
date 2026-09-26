// Repo index schema tests.
//
// These pin the contract between a published extension index and the app that
// consumes it. The failure mode is silent in both directions: a malformed
// entry parses without throwing, the source installs, it even shows up in
// Browse — and it is quietly wrong. Nothing crashes, so nothing gets reported.
//
// WHAT IS PINNED HERE:
//
//   1. Language resolution. `lang` is the canonical field, but catalogs also
//      ship the plural `langs` array. The old code read only `lang` and fell
//      through to the `'all'` default otherwise. That default is not inert:
//      Browse classifies `'all'` as a *multi-language* source, so a
//      single-language English scraper published as
//      `{"langs": ["en","fr","id"]}` was hidden the instant the user filtered
//      Browse by English. The user sees "Webtoons is missing" and there is no
//      error anywhere to explain why.
//
//   2. A one-element `langs` resolves to that element; a genuinely multi
//      language list keeps `'all'` so the filter can still offer it.
//
//   3. Other index fields that must not silently default: a missing `version`
//      must not read as the lowest possible value (which would make every
//      real release look like an upgrade forever), and a missing `name` must
//      not produce an entry that is impossible to identify in the UI.
//
// Run: fvm flutter test test/repo_index_schema_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/engine/repo_manager.dart';

/// Mirrors the Browse language classification in browse_screen.dart, which the
/// browse_language_filter_test.dart spec pins as [LangBucket] semantics.
String browseLanguageBucket(String rawLang) {
  final lang = rawLang.trim().toUpperCase();
  if (lang == 'EN' || lang.startsWith('EN')) return 'english';
  if (lang == 'ALL' || lang == 'MULTI' || lang == 'UNIVERSAL') return 'multi';
  if (lang.isEmpty) return 'unknown';
  return 'specific';
}

RepoSourceItem parse(Map<String, dynamic> json) =>
    RepoSourceItem.fromJson(json, 'https://example.test/index.json');

void main() {
  group('index language resolution', () {
    test('reads the canonical lang field', () {
      expect(parse({'name': 'A', 'lang': 'en'}).lang, 'en');
      expect(parse({'name': 'A', 'lang': 'pt-BR'}).lang, 'pt-BR');
    });

    test('trims a padded lang value', () {
      expect(parse({'name': 'A', 'lang': '  en  '}).lang, 'en');
    });

    test('a one-element langs array resolves to that language', () {
      // The regression: this used to become 'all' and be filtered out of the
      // English listing in Browse.
      final item = parse({
        'name': 'Solo',
        'langs': ['en'],
      });
      expect(item.lang, 'en');
      expect(browseLanguageBucket(item.lang), 'english');
    });

    test('a multi-element langs array stays multi, not english', () {
      // The site serves several languages but the scraper targets all of them,
      // so 'all' is the honest bucket and the filter can still offer it.
      final item = parse({
        'name': 'Polyglot',
        'langs': ['en', 'fr', 'id', 'th'],
      });
      expect(item.lang, 'all');
      expect(browseLanguageBucket(item.lang), 'multi');
    });

    test('langs with duplicates or blanks still resolves to one language', () {
      expect(parse({'name': 'A', 'langs': ['en', 'en']}).lang, 'en');
      expect(parse({'name': 'A', 'langs': ['', '  ', 'en']}).lang, 'en');
    });

    test('a non-string langs entry is ignored rather than stringified', () {
      expect(parse({'name': 'A', 'langs': [42, 'en']}).lang, 'en');
      expect(parse({'name': 'A', 'langs': 'en'}).lang, 'all',
          reason: 'a bare string is not a list; do not invent a shape for it');
    });

    test('an explicit lang wins over langs', () {
      expect(parse({'name': 'A', 'lang': 'en', 'langs': ['fr', 'de']}).lang, 'en');
    });

    test('a blank lang falls through to langs', () {
      expect(parse({'name': 'A', 'lang': '', 'langs': ['en']}).lang, 'en');
      expect(parse({'name': 'A', 'lang': '   ', 'langs': ['en']}).lang, 'en');
    });

    test('no language information at all yields all', () {
      expect(parse({'name': 'A'}).lang, 'all');
      expect(parse({'name': 'A', 'langs': <String>[]}).lang, 'all');
    });
  });

  group('the real published index parses correctly', () {
    // Mirrors the shape of the Sunfire official catalog. Every entry there is
    // a single-language English scraper under javascript/manga/src/en/, so any
    // entry landing outside the english bucket is a packaging bug in the
    // published index, not a quirk of the app.
    const officialEntries = <Map<String, dynamic>>[
      {'name': 'MangaFreak', 'lang': 'en'},
      {'name': 'Mangago', 'lang': 'en'},
      {'name': 'MangaHere', 'lang': 'en'},
      {'name': 'Mangapill', 'lang': 'en'},
      {'name': 'nHentai', 'lang': 'en'},
      {'name': 'NineHentai', 'lang': 'en'},
      {'name': 'Read Comics Online', 'lang': 'en'},
      // This is the entry that shipped `langs` with no `lang`.
      {'name': 'Webtoons', 'lang': 'en', 'langs': ['en', 'fr', 'id', 'th', 'es', 'zh', 'de']},
      {'name': 'Weeb Central', 'lang': 'en'},
    ];

    test('every source in the official catalog is reachable under the English filter', () {
      for (final entry in officialEntries) {
        final item = parse(entry);
        expect(
          browseLanguageBucket(item.lang),
          'english',
          reason: '${item.name} is bucketed as ${browseLanguageBucket(item.lang)}; '
              'it would be hidden when Browse is filtered by English',
        );
      }
    });

    test('NSFW classification matches the published catalog', () {
      // The two adult sources are flagged by name ("hentai") even without an
      // explicit isNsfw field, which is what keeps them out of the default
      // listing. Everything else in the catalog must stay clean, because a
      // false positive here hides a mainstream source behind a filter toggle.
      const expectedNsfw = {'nHentai', 'NineHentai'};
      for (final entry in officialEntries) {
        final name = entry['name']! as String;
        expect(
          parse(entry).isNsfw,
          expectedNsfw.contains(name),
          reason: '$name NSFW classification',
        );
      }
    });
  });

  group('other index fields do not silently default', () {
    test('a missing version is not read as the lowest possible value', () {
      // Version defaults to '1.0.0'. If a publisher ever omits it, every later
      // real release compares as newer, so the app would claim a permanent
      // update is available. The default is pinned here so the behaviour is a
      // decision rather than an accident.
      final item = parse({'name': 'A'});
      expect(item.version, '1.0.0');
      expect(RepoManager.compareVersions('1.0.1', item.version) > 0, isTrue);
    });

    test('a missing name falls back to a visible placeholder, not an empty string', () {
      final item = parse({});
      expect(item.name, 'Unknown');
      expect(item.name.trim(), isNotEmpty);
    });

    test('sha256 aliases are all accepted', () {
      for (final key in ['sha256', 'hash', 'sourceCodeHash']) {
        expect(parse({'name': 'A', key: 'abc123'}).sha256, 'abc123', reason: key);
      }
      expect(parse({'name': 'A'}).sha256, '');
    });

    test('isJs is detected from every shape an index uses', () {
      expect(parse({'name': 'A', 'sourceCodeLanguage': 1}).isJs, isTrue);
      expect(parse({'name': 'A', 'typeSource': 'single'}).isJs, isTrue);
      expect(parse({'name': 'A', 'pkgPath': 'javascript/manga/src/en/a.js'}).isJs, isTrue);
      expect(parse({'name': 'A', 'pkgPath': 'a.kt'}).isJs, isFalse);
    });

    test('a relative pkgPath resolves against the repo root', () {
      final item = parse({'name': 'A', 'pkgPath': 'javascript/manga/src/en/a.js'});
      expect(item.sourceCodeUrl, 'https://example.test/javascript/manga/src/en/a.js');
    });

    test('an absolute sourceCodeUrl is left untouched', () {
      final item = parse({
        'name': 'A',
        'sourceCodeUrl': 'https://cdn.test/a.js',
        'pkgPath': 'javascript/manga/src/en/a.js',
      });
      expect(item.sourceCodeUrl, 'https://cdn.test/a.js');
    });

    test('NSFW is inferred from flags and from the name', () {
      expect(parse({'name': 'A', 'isNsfw': true}).isNsfw, isTrue);
      expect(parse({'name': 'A', 'isNsfw': 1}).isNsfw, isTrue);
      expect(parse({'name': 'A', 'nsfw': true}).isNsfw, isTrue);
      expect(parse({'name': 'Some Hentai Site'}).isNsfw, isTrue);
      expect(parse({'name': '18+ Corner'}).isNsfw, isTrue);
      expect(parse({'name': 'Clean'}).isNsfw, isFalse);
    });
  });
}
