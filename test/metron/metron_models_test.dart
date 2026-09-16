import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/metron/metron_models.dart';

void main() {
  group('Metron Models Test', () {
    test('MetronPublisher serialization & deserialization', () {
      final json = {
        'id': 1,
        'name': 'Marvel',
      };

      final publisher = MetronPublisher.fromJson(json);
      expect(publisher.id, 1);
      expect(publisher.name, 'Marvel');

      final serialized = publisher.toJson();
      expect(serialized['id'], 1);
      expect(serialized['name'], 'Marvel');
    });

    test('MetronSeries serialization with nested publisher & genres', () {
      final json = {
        'id': 42,
        'name': 'The Amazing Spider-Man',
        'sort_name': 'Amazing Spider-Man, The',
        'volume': 1,
        'year_began': 1963,
        'year_end': 1998,
        'desc': 'Peter Parker web-slinging adventures.',
        'issue_count': 441,
        'image': 'https://metron.cloud/media/series/asm.jpg',
        'publisher': {
          'id': 1,
          'name': 'Marvel',
        },
        'genres': [
          {'id': 10, 'name': 'Superhero'},
          {'id': 12, 'name': 'Action'},
        ],
        'status': 'Ended',
      };

      final series = MetronSeries.fromJson(json);
      expect(series.id, 42);
      expect(series.name, 'The Amazing Spider-Man');
      expect(series.volume, 1);
      expect(series.yearBegan, 1963);
      expect(series.yearEnd, 1998);
      expect(series.description, 'Peter Parker web-slinging adventures.');
      expect(series.issueCount, 441);
      expect(series.publisher?.name, 'Marvel');
      expect(series.genres, ['Superhero', 'Action']);
      expect(series.status, 'Ended');
      expect(series.displayName, 'The Amazing Spider-Man (1963)');
    });

    test('MetronIssueSummary normalization and number handling', () {
      final json = {
        'id': 1001,
        'number': '1.5',
        'issue': 'The Amazing Spider-Man #1.5',
        'cover_date': '1963-03-01',
        'store_date': '1963-02-15',
        'image': 'https://metron.cloud/media/issue/asm_1.jpg',
      };

      final issue = MetronIssueSummary.fromJson(json);
      expect(issue.id, 1001);
      expect(issue.number, '1.5');
      expect(issue.issueName, 'The Amazing Spider-Man #1.5');
      expect(issue.coverDate, '1963-03-01');
      expect(issue.storeDate, '1963-02-15');
      expect(issue.image, 'https://metron.cloud/media/issue/asm_1.jpg');
    });

    test('MetronRateLimitState parses 6 headers properly', () {
      final headers = {
        'x-ratelimit-burst-limit': ['20'],
        'x-ratelimit-burst-remaining': ['18'],
        'x-ratelimit-burst-reset': ['45'],
        'x-ratelimit-sustained-limit': ['5000'],
        'x-ratelimit-sustained-remaining': ['4980'],
        'x-ratelimit-sustained-reset': ['86400'],
      };

      final state = MetronRateLimitState.fromHeaders(headers);
      expect(state.burstLimit, 20);
      expect(state.burstRemaining, 18);
      expect(state.burstResetSeconds, 45);
      expect(state.sustainedLimit, 5000);
      expect(state.sustainedRemaining, 4980);
      expect(state.sustainedResetSeconds, 86400);
    });
  });
}
