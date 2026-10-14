// IMP-004 (More like this query) + IMP-007 (duplicates, saved filters).
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunfire/src/core/db/models/manga.dart';
import 'package:sunfire/src/core/services/library_matching.dart';
import 'package:sunfire/src/core/services/recommendations.dart';
import 'package:sunfire/src/core/services/settings_service.dart';

Manga _m(int id, String title, {List<String> g = const [], String? author, String src = 's', bool lib = false}) =>
    Manga()
      ..serverId = id
      ..title = title
      ..genres = [...g]
      ..author = author
      ..sourceName = src
      ..inLibrary = lib;

void main() {
  group('IMP-004 rankRecommendations', () {
    final target = _m(1, 'Solo Leveling', g: ['Action', 'Fantasy', 'Adventure'], author: 'Chugong');
    test('ranks by genre overlap + shared author; excludes self and same-title copies', () {
      final r = rankRecommendations(target, [
        target,
        _m(2, 'Solo Leveling (Official)', g: ['Action', 'Fantasy']),
        _m(3, 'Omniscient Reader', g: ['action', 'fantasy', 'adventure']),
        _m(4, 'Romance Story', g: ['Romance']),
        _m(5, 'Other Work', g: ['Drama'], author: 'Chugong, Someone'),
        _m(6, 'Tower', g: ['Action', 'Fantasy'], lib: true),
        _m(7, 'Tower B', g: ['Action', 'Fantasy']),
      ]);
      expect(r.map((e) => e.manga.serverId), [3, 6, 7, 5]);
      expect(r.first.reasons, ['3 shared genres']);
      expect(r.last.reasons, ['Same author']);
    });

    test('no genres and no author → nothing', () {
      expect(rankRecommendations(_m(1, 'X'), [_m(2, 'Y')]), isEmpty);
    });

    test('limit applies', () {
      final many = [for (var i = 2; i < 30; i++) _m(i, 'T$i', g: ['Action'])];
      expect(rankRecommendations(_m(1, 'X', g: ['Action']), many, limit: 5), hasLength(5));
    });
  });

  group('IMP-007 duplicates', () {
    test('normalizeMangaTitle folds case, brackets, accents, articles, punctuation', () {
      expect(normalizeMangaTitle('The Beginning After the End [Webtoon]'), 'beginning after end');
      expect(normalizeMangaTitle('Pokémon: Adventures!'), 'pokemon adventures');
      expect(normalizeMangaTitle('ワンパンマン'), 'ワンパンマン');
    });

    test('groups same series across sources; singletons ignored', () {
      final groups = findPossibleDuplicates([
        _m(1, 'One Piece', src: 'b'),
        _m(2, 'ONE PIECE (Official)', src: 'a'),
        _m(3, 'Naruto'),
        _m(4, '!!!'),
      ]);
      expect(groups, hasLength(1));
      expect(groups.single.map((m) => m.serverId), [2, 1]);
    });
  });

  group('IMP-007 saved filters', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await SettingsService.instance.initialize();
    });

    test('save/replace/delete/load round-trip; garbage tolerated', () async {
      final s = SettingsService.instance;
      expect(loadSavedLibraryFilters(s), isEmpty);
      await saveLibraryFilter(s, const SavedLibraryFilter('Unread', {'unread': true}));
      await saveLibraryFilter(s, const SavedLibraryFilter('Done', {'status': 'completed'}));
      await saveLibraryFilter(s, const SavedLibraryFilter('unread', {'unread': true, 'sort': 'az'}));
      final list = loadSavedLibraryFilters(s);
      expect(list.map((f) => f.name), ['unread', 'Done']);
      expect(list.first.query['sort'], 'az');
      await deleteLibraryFilter(s, 'DONE');
      expect(loadSavedLibraryFilters(s).map((f) => f.name), ['unread']);
      s.savedLibraryFiltersJson = '{bad';
      expect(loadSavedLibraryFilters(s), isEmpty);
      s.savedLibraryFiltersJson = '[{"name":"","query":{}},{"name":"ok","query":{}},3]';
      expect(loadSavedLibraryFilters(s).map((f) => f.name), ['ok']);
    });

    test('capped at kMaxSavedLibraryFilters', () async {
      final s = SettingsService.instance;
      for (var i = 0; i < kMaxSavedLibraryFilters + 5; i++) {
        await saveLibraryFilter(s, SavedLibraryFilter('f$i', const {}));
      }
      expect(loadSavedLibraryFilters(s), hasLength(kMaxSavedLibraryFilters));
      expect(loadSavedLibraryFilters(s).first.name, 'f${kMaxSavedLibraryFilters + 4}');
    });
  });
}
