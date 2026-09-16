import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/metron/metron_service.dart';

void main() {
  group('MetronService Issue Matching Tests', () {
    final issueMap = {
      '1': 101,
      '2': 102,
      '2.5': 103,
      '10': 110,
      '100': 200,
    };

    test('matches exact integer chapter number', () {
      final key = MetronService.matchIssueNumber('Chapter 1', 1.0, issueMap);
      expect(key, '1');
      expect(issueMap[key], 101);
    });

    test('matches decimal chapter number', () {
      final key = MetronService.matchIssueNumber('Issue #2.5 Extra', 2.5, issueMap);
      expect(key, '2.5');
      expect(issueMap[key], 103);
    });

    test('extracts issue number from complex title string', () {
      final key1 = MetronService.matchIssueNumber('Spider-Man #10 (Variant Cover)', 0.0, issueMap);
      expect(key1, '10');

      final key2 = MetronService.matchIssueNumber('Batman Chapter 100 - Endgame', 0.0, issueMap);
      expect(key2, '100');

      final key3 = MetronService.matchIssueNumber('#1', 0.0, issueMap);
      expect(key3, '1');

      final key4 = MetronService.matchIssueNumber('#10', 0.0, issueMap);
      expect(key4, '10');
    });

    test('returns null when no match found', () {
      final key = MetronService.matchIssueNumber('Unknown Special', 999.0, issueMap);
      expect(key, isNull);
    });
  });
}
