import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/db/models/manga.dart';

void main() {
  group('Metron Metadata Lock & Protection Tests', () {
    test('Manga model default values for Metron fields', () {
      final manga = Manga()
        ..title = 'Batman (2016)'
        ..author = 'Tom King';

      expect(manga.metronSeriesId, isNull);
      expect(manga.publisher, isNull);
      expect(manga.isMetadataLocked, isFalse);
      expect(manga.metronIssuesJson, isNull);
    });

    test('Manga metadata lock prevents server overwrite simulation', () {
      final manga = Manga()
        ..title = 'The Amazing Spider-Man'
        ..author = 'Stan Lee, Steve Ditko'
        ..description = 'Enriched Metron description.'
        ..genres = ['Superhero', 'Action']
        ..publisher = 'Marvel'
        ..metronSeriesId = 42
        ..isMetadataLocked = true;

      // Simulated server payload with generic/incomplete data
      final serverNode = {
        'title': 'The Amazing Spider-Man',
        'author': 'Unknown',
        'description': 'Scraped generic synopsis',
        'genre': ['Manga', 'Shounen'],
      };

      // Apply SyncEngine logic
      manga.title = serverNode['title'] as String? ?? 'Untitled';
      if (!manga.isMetadataLocked) {
        manga.author = serverNode['author'] as String?;
        manga.description = serverNode['description'] as String?;
      }

      final serverGenres = serverNode['genre'] as List<dynamic>?;
      if (!manga.isMetadataLocked && serverGenres != null) {
        manga.genres = serverGenres.map((g) => g.toString()).toList();
      }

      // Assert that enriched Metron metadata was preserved intact!
      expect(manga.author, 'Stan Lee, Steve Ditko');
      expect(manga.description, 'Enriched Metron description.');
      expect(manga.genres, ['Superhero', 'Action']);
      expect(manga.publisher, 'Marvel');
      expect(manga.isMetadataLocked, isTrue);
    });
  });
}
