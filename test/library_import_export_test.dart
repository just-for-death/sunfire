// L10.3: pure JSON/CSV serialize-parse roundtrip (no Isar).

import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/library/library_import_export_service.dart';

void main() {
  group('LibraryExportPayload JSON', () {
    test('encode/decode roundtrip preserves entries', () {
      final original = LibraryExportPayload(
        version: kLibraryExportVersion,
        exportedAt: DateTime.utc(2026, 10, 12, 15, 30),
        entries: const [
          LibraryExportEntry(
            title: 'One Piece',
            author: 'Oda',
            sourceName: 'MangaDex',
            url: 'https://example.com/op',
            status: 'ONGOING',
            lang: 'en',
            genres: ['Action', 'Adventure'],
            tags: ['Favorites'],
            categoryIds: [1, 2],
            unreadCount: 5,
            chapterCount: 1100,
            serverId: 42,
          ),
          LibraryExportEntry(
            title: 'Commas, "quotes"',
            sourceName: 'Local',
            url: '',
            tags: ['A', 'B'],
            chapterCount: 3,
          ),
        ],
      );

      final encoded = original.encodeJson();
      final decoded = LibraryExportPayload.decodeJson(encoded);

      expect(decoded.version, kLibraryExportVersion);
      expect(decoded.entries.length, 2);
      expect(decoded.entries[0].title, 'One Piece');
      expect(decoded.entries[0].author, 'Oda');
      expect(decoded.entries[0].sourceName, 'MangaDex');
      expect(decoded.entries[0].url, 'https://example.com/op');
      expect(decoded.entries[0].genres, ['Action', 'Adventure']);
      expect(decoded.entries[0].tags, ['Favorites']);
      expect(decoded.entries[0].categoryIds, [1, 2]);
      expect(decoded.entries[0].unreadCount, 5);
      expect(decoded.entries[0].chapterCount, 1100);
      expect(decoded.entries[0].serverId, 42);
      expect(decoded.entries[1].title, 'Commas, "quotes"');
      expect(decoded.entries[1].tags, ['A', 'B']);
    });

    test('skips blank-title entries on decode', () {
      const raw = '''
{
  "version": 1,
  "exportedAt": "2026-10-12T00:00:00.000Z",
  "entries": [
    {"title": "", "url": "x"},
    {"title": "Keep Me", "sourceName": "S", "url": "u"}
  ]
}
''';
      final decoded = LibraryExportPayload.decodeJson(raw);
      expect(decoded.entries.length, 1);
      expect(decoded.entries.single.title, 'Keep Me');
    });
  });

  group('libraryEntries CSV', () {
    test('toCsv/fromCsv roundtrip', () {
      const entries = [
        LibraryExportEntry(
          title: 'Series A',
          author: 'Author',
          sourceName: 'Src',
          url: 'https://a.example/manga',
          status: 'Completed',
          lang: 'en',
          genres: ['Drama', 'Slice of Life'],
          tags: ['Done', 'Favorites'],
          chapterCount: 12,
          unreadCount: 0,
        ),
        LibraryExportEntry(
          title: 'Need, quotes',
          sourceName: 'X',
          url: '',
          genres: ['Action'],
          tags: [],
          chapterCount: 1,
          unreadCount: 1,
        ),
      ];

      final csv = libraryEntriesToCsv(entries);
      final parsed = libraryEntriesFromCsv(csv);

      expect(parsed.length, 2);
      expect(parsed[0].title, 'Series A');
      expect(parsed[0].author, 'Author');
      expect(parsed[0].sourceName, 'Src');
      expect(parsed[0].url, 'https://a.example/manga');
      expect(parsed[0].status, 'Completed');
      expect(parsed[0].lang, 'en');
      expect(parsed[0].genres, ['Drama', 'Slice of Life']);
      expect(parsed[0].tags, ['Done', 'Favorites']);
      expect(parsed[0].chapterCount, 12);
      expect(parsed[0].unreadCount, 0);
      expect(parsed[1].title, 'Need, quotes');
      expect(parsed[1].genres, ['Action']);
      expect(parsed[1].unreadCount, 1);
    });

    test('csvEscape quotes commas and quotes', () {
      expect(csvEscape('plain'), 'plain');
      expect(csvEscape('a,b'), '"a,b"');
      expect(csvEscape('say "hi"'), '"say ""hi"""');
    });

    test('fromCsv throws when title column missing', () {
      expect(
        () => libraryEntriesFromCsv('name,url\nA,http://x'),
        throwsFormatException,
      );
    });
  });
}
