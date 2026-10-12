// L10.1: pure matcher tests for mangaMatchesSmartRule (no Isar).

import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/db/models/manga.dart';
import 'package:sunfire/src/core/library/smart_collection_service.dart';

Manga _manga({
  String title = 'One Piece',
  List<String> genres = const ['Action', 'Adventure'],
  String? status = 'ONGOING',
  String sourceName = 'MangaDex',
  String? author = 'Oda',
  String lang = 'en',
  int? unreadCount = 3,
}) {
  return Manga()
    ..title = title
    ..genres = List<String>.from(genres)
    ..status = status
    ..sourceName = sourceName
    ..author = author
    ..lang = lang
    ..unreadCount = unreadCount
    ..inLibrary = true
    ..serverId = -1;
}

SmartCollectionRule _rule({
  SmartMatchField field = SmartMatchField.genre,
  SmartMatchOp op = SmartMatchOp.contains,
  String matchValue = 'action',
  bool enabled = true,
}) {
  return SmartCollectionRule(
    id: 'r1',
    name: 'test',
    tagName: 'Auto',
    field: field,
    op: op,
    matchValue: matchValue,
    enabled: enabled,
  );
}

void main() {
  group('mangaMatchesSmartRule', () {
    test('disabled rule never matches', () {
      final manga = _manga();
      expect(
        mangaMatchesSmartRule(manga, _rule(enabled: false)),
        isFalse,
      );
    });

    test('genre contains is case-insensitive', () {
      final manga = _manga();
      expect(
        mangaMatchesSmartRule(
          manga,
          _rule(field: SmartMatchField.genre, matchValue: 'ACTION'),
        ),
        isTrue,
      );
      expect(
        mangaMatchesSmartRule(
          manga,
          _rule(field: SmartMatchField.genre, matchValue: 'Romance'),
        ),
        isFalse,
      );
    });

    test('status equals', () {
      final manga = _manga(status: 'Completed');
      expect(
        mangaMatchesSmartRule(
          manga,
          _rule(
            field: SmartMatchField.status,
            op: SmartMatchOp.equals,
            matchValue: 'completed',
          ),
        ),
        isTrue,
      );
      expect(
        mangaMatchesSmartRule(
          manga,
          _rule(
            field: SmartMatchField.status,
            op: SmartMatchOp.equals,
            matchValue: 'ongoing',
          ),
        ),
        isFalse,
      );
    });

    test('sourceName startsWith', () {
      final manga = _manga(sourceName: 'MangaDex EN');
      expect(
        mangaMatchesSmartRule(
          manga,
          _rule(
            field: SmartMatchField.sourceName,
            op: SmartMatchOp.startsWith,
            matchValue: 'mangadex',
          ),
        ),
        isTrue,
      );
    });

    test('title contains', () {
      final manga = _manga(title: 'One Piece');
      expect(
        mangaMatchesSmartRule(
          manga,
          _rule(
            field: SmartMatchField.title,
            op: SmartMatchOp.contains,
            matchValue: 'piece',
          ),
        ),
        isTrue,
      );
    });

    test('author equals', () {
      final manga = _manga(author: 'Eiichiro Oda');
      expect(
        mangaMatchesSmartRule(
          manga,
          _rule(
            field: SmartMatchField.author,
            op: SmartMatchOp.equals,
            matchValue: 'eiichiro oda',
          ),
        ),
        isTrue,
      );
    });

    test('language equals', () {
      final manga = _manga(lang: 'ja');
      expect(
        mangaMatchesSmartRule(
          manga,
          _rule(
            field: SmartMatchField.language,
            op: SmartMatchOp.equals,
            matchValue: 'ja',
          ),
        ),
        isTrue,
      );
    });

    test('unread isTrue when unreadCount > 0', () {
      expect(
        mangaMatchesSmartRule(
          _manga(unreadCount: 2),
          _rule(field: SmartMatchField.unread, op: SmartMatchOp.isTrue),
        ),
        isTrue,
      );
      expect(
        mangaMatchesSmartRule(
          _manga(unreadCount: 0),
          _rule(field: SmartMatchField.unread, op: SmartMatchOp.isTrue),
        ),
        isFalse,
      );
    });

    test('unread false needle matches fully-read', () {
      expect(
        mangaMatchesSmartRule(
          _manga(unreadCount: 0),
          _rule(
            field: SmartMatchField.unread,
            op: SmartMatchOp.equals,
            matchValue: 'false',
          ),
        ),
        isTrue,
      );
    });

    test('empty contains needle does not match', () {
      expect(
        mangaMatchesSmartRule(
          _manga(),
          _rule(
            field: SmartMatchField.genre,
            op: SmartMatchOp.contains,
            matchValue: '',
          ),
        ),
        isFalse,
      );
    });
  });
}
