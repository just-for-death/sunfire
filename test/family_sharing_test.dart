// test/family_sharing_test.dart
//
// S4.4: Family sharing - read-only codec round-trip + validation.

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/sync/family_sharing.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  FamilySharePayload samplePayload() => FamilySharePayload(
        version: kFamilyShareVersion,
        exportedAt: DateTime.fromMillisecondsSinceEpoch(1700000000000),
        appVersion: 'sunfire-6-test',
        entries: const [
          SharedMangaEntry(
            title: 'Berserk',
            author: 'Miura',
            totalChapters: 10,
            readChapters: 4,
            categories: ['Seinen'],
          ),
          SharedMangaEntry(title: 'One Piece'),
        ],
      );

  group('codec round-trip', () {
    test('encode/decode preserves entries', () {
      final encoded = samplePayload().encode();
      final decoded = FamilySharePayload.decode(encoded);
      expect(decoded.version, kFamilyShareVersion);
      expect(decoded.entries.length, 2);
      expect(decoded.entries.first.title, 'Berserk');
      expect(decoded.entries.first.author, 'Miura');
      expect(decoded.entries.first.totalChapters, 10);
      expect(decoded.entries.first.readChapters, 4);
      expect(decoded.entries.first.progress, 0.4);
      expect(decoded.entries.first.categories, ['Seinen']);
    });

    test('progress clamps to 0..1 and is 0 with no chapters', () {
      expect(samplePayload().entries[1].progress, 0.0);
      const over = SharedMangaEntry(
          title: 'X', totalChapters: 2, readChapters: 5);
      expect(over.progress, 1.0);
    });
  });

  group('validation', () {
    test('rejects non-object JSON', () {
      expect(() => FamilySharePayload.decode('[1,2,3]'),
          throwsA(isA<FormatException>()));
    });

    test('rejects wrong version', () {
      final bad = jsonEncode({'version': 999, 'entries': []});
      expect(() => FamilySharePayload.decode(bad),
          throwsA(isA<FormatException>()));
    });

    test('rejects missing entries', () {
      final bad = jsonEncode({'version': kFamilyShareVersion});
      expect(() => FamilySharePayload.decode(bad),
          throwsA(isA<FormatException>()));
    });

    test('rejects entry without title', () {
      final bad = jsonEncode({
        'version': kFamilyShareVersion,
        'exportedAt': 0,
        'entries': [
          {'author': 'Nobody'}
        ],
      });
      expect(() => FamilySharePayload.decode(bad),
          throwsA(isA<FormatException>()));
    });

    test('rejects credential-like content', () {
      final evil = jsonEncode({
        'version': kFamilyShareVersion,
        'exportedAt': 0,
        'entries': [
          {'title': 'Berserk', 'authToken': 'secret-123'}
        ],
      });
      expect(() => FamilySharePayload.decode(evil),
          throwsA(isA<FormatException>()));
    });

    test('exported payload contains no secret keys', () {
      final encoded = samplePayload().encode().toLowerCase();
      for (final banned in [
        'authtoken',
        'cookie',
        'password',
        'api_key',
        'bearer',
        'jwt',
      ]) {
        expect(encoded.contains(banned), isFalse,
            reason: 'leaked $banned');
      }
    });
  });
}
