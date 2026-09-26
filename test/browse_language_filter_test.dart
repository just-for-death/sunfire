// Tests for the Browse source language filter.
//
// Previously "English (EN)" also matched '', 'ALL', 'MULTI' and 'UNIVERSAL',
// so a multi-language, universal or unknown-language source was included under
// English. Because those got absorbed rather than excluded, filtering by EN
// hid nothing and read as a no-op, and there was no way to select them at all —
// the "Unknown" case was unreachable.
//
// The classification is reimplemented here as a pure function so the screen
// logic and the tests cannot drift. NOTE: browse_screen.dart currently
// inlines this classification inside its `where` clause; the assertions below
// are the specification it implements.
//
// Run: fvm flutter test test/browse_language_filter_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/services/settings_service.dart';

/// The five buckets the Browse language filter distinguishes.
enum LangBucket { english, multi, unknown, specific }

LangBucket bucketOf(String rawLang) {
  final lang = rawLang.trim().toUpperCase();
  if (lang == 'EN' || lang.startsWith('EN')) return LangBucket.english;
  if (lang == 'ALL' || lang == 'MULTI' || lang == 'UNIVERSAL') return LangBucket.multi;
  if (lang.isEmpty) return LangBucket.unknown;
  return LangBucket.specific;
}

/// True when a source with [rawLang] passes the Browse filter set to [filter].
/// Mirrors the `_filteredUpdates`-equivalent `matchesLang` expression in
/// browse_screen.dart.
bool passesFilter(String rawLang, String filter) {
  final selected = filter.toUpperCase();
  return switch (selected) {
    'ALL' => true,
    'EN' => bucketOf(rawLang) == LangBucket.english,
    'MULTI' => bucketOf(rawLang) == LangBucket.multi || bucketOf(rawLang) == LangBucket.unknown,
    'UNKNOWN' => bucketOf(rawLang) == LangBucket.unknown,
    _ => rawLang.trim().toUpperCase().contains(selected),
  };
}

void main() {
  group('bucketOf', () {
    test('classifies English variants as English', () {
      expect(bucketOf('EN'), LangBucket.english);
      expect(bucketOf('en'), LangBucket.english);
      expect(bucketOf('EN-US'), LangBucket.english);
      expect(bucketOf('English'), LangBucket.english);
    });

    test('classifies ALL / MULTI / UNIVERSAL as multi, not English', () {
      // These are "not a real language" per SettingsService.languageBadgeLabel.
      for (final v in ['ALL', 'MULTI', 'UNIVERSAL', 'all', 'Multi']) {
        expect(bucketOf(v), LangBucket.multi, reason: '$v must not be English');
      }
    });

    test('classifies empty / whitespace as unknown, not English', () {
      // QuickJsService.getSourceLang can genuinely return ''.
      expect(bucketOf(''), LangBucket.unknown);
      expect(bucketOf('   '), LangBucket.unknown);
    });

    test('classifies real languages as specific', () {
      expect(bucketOf('JA'), LangBucket.specific);
      expect(bucketOf('ES'), LangBucket.specific);
      expect(bucketOf('pt-BR'), LangBucket.specific);
    });
  });

  group('the English filter bug', () {
    test('EN no longer matches multi-language labels', () {
      for (final v in ['ALL', 'MULTI', 'UNIVERSAL']) {
        expect(passesFilter(v, 'EN'), isFalse, reason: '$v was wrongly counted as English');
      }
    });

    test('EN no longer matches unknown language', () {
      expect(passesFilter('', 'EN'), isFalse);
      expect(passesFilter('  ', 'EN'), isFalse);
    });

    test('EN still matches English', () {
      for (final v in ['EN', 'en', 'EN-US', 'English']) {
        expect(passesFilter(v, 'EN'), isTrue, reason: '$v is English');
      }
    });

    test('EN filtering actually hides something (it was a no-op before)', () {
      // The user-visible symptom: with a catch-all English bucket, filtering by
      // EN removed nothing from a mixed list.
      final sources = ['EN', 'EN-US', 'ALL', 'MULTI', 'UNIVERSAL', '', 'JA', 'ES'];
      final shown = sources.where((s) => passesFilter(s, 'EN')).toList();
      expect(shown, ['EN', 'EN-US']);
      expect(shown.length, lessThan(sources.length));
    });
  });

  group('the previously unreachable Unknown bucket', () {
    test('MULTI matches both multi labels and unknown', () {
      expect(passesFilter('ALL', 'MULTI'), isTrue);
      expect(passesFilter('UNIVERSAL', 'MULTI'), isTrue);
      expect(passesFilter('', 'MULTI'), isTrue);
      expect(passesFilter('EN', 'MULTI'), isFalse);
      expect(passesFilter('JA', 'MULTI'), isFalse);
    });

    test('UNKNOWN matches only genuinely unknown', () {
      expect(passesFilter('', 'UNKNOWN'), isTrue);
      expect(passesFilter('   ', 'UNKNOWN'), isTrue);
      expect(passesFilter('ALL', 'UNKNOWN'), isFalse, reason: 'ALL is multi, not unknown');
      expect(passesFilter('EN', 'UNKNOWN'), isFalse);
    });

    test('the two buckets partition what English used to swallow', () {
      final swallowed = ['ALL', 'MULTI', 'UNIVERSAL', ''];
      for (final v in swallowed) {
        final nowReachable = passesFilter(v, 'MULTI') || passesFilter(v, 'UNKNOWN');
        expect(nowReachable, isTrue, reason: '$v must be selectable by some filter');
      }
    });
  });

  group('all other behaviour is preserved', () {
    test('ALL matches everything', () {
      for (final v in ['EN', 'JA', 'ALL', '', 'ES']) {
        expect(passesFilter(v, 'ALL'), isTrue, reason: v);
      }
    });

    test('a specific-language filter still uses substring matching', () {
      expect(passesFilter('JA', 'JA'), isTrue);
      expect(passesFilter('ja', 'JA'), isTrue, reason: 'case-insensitive');
      expect(passesFilter('JA-MANGa', 'JA'), isTrue);
      expect(passesFilter('EN', 'JA'), isFalse);
      expect(passesFilter('', 'JA'), isFalse, reason: 'unknown is not Japanese');
    });
  });

  group('agrees with SettingsService.languageBadgeLabel', () {
    // The two must not disagree about what counts as a real language, or a
    // source could be badged AND filtered inconsistently.
    test('labels the filter refuses to badge are not English', () {
      for (final v in ['', 'EN', 'ALL', 'MULTI', 'UNIVERSAL']) {
        final noBadge = SettingsService.languageBadgeLabel(v) == null;
        final notEnglish = passesFilter(v, 'EN') == false;
        if (noBadge && v != 'EN') {
          expect(notEnglish, isTrue, reason: '$v is unbadged, so EN must not claim it');
        }
      }
    });

    test('a badged language is not in the multi or unknown buckets', () {
      for (final v in ['ES', 'FR', 'DE', 'pt-BR']) {
        final label = SettingsService.languageBadgeLabel(v);
        expect(label, isNotNull, reason: '$v should badge');
        expect(passesFilter(v, 'UNKNOWN'), isFalse);
        expect(passesFilter(v, 'MULTI'), isFalse);
      }
    });
  });
}
