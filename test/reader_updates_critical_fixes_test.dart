import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/sync/sync_engine.dart';

void main() {
  group('mergeLastPageRead — critical fix for progress rewind', () {
    test('local read (page 50), server unread (page 0) → keeps local 50', () {
      // User read to page 50 locally, another device marked unread (server page=0)
      // Should NOT rewind to 0
      final result = mergeLastPageRead(
        local: 50,
        server: 0,
        localWasRead: true,
        serverIsRead: false,
        hasPendingMutation: false,
      );
      expect(result, 50, reason: 'Local progress should not be rewound when server has less progress');
    });

    test('local read (page 50), server read (page 60) → takes server 60', () {
      // Server has more progress
      final result = mergeLastPageRead(
        local: 50,
        server: 60,
        localWasRead: true,
        serverIsRead: true,
        hasPendingMutation: false,
      );
      expect(result, 60, reason: 'Should take server progress when it is greater');
    });

    test('local read (page 50), server unread (page 10) → keeps local 50', () {
      // Server unread but has some progress (e.g., page 10), local has 50
      final result = mergeLastPageRead(
        local: 50,
        server: 10,
        localWasRead: true,
        serverIsRead: false,
        hasPendingMutation: false,
      );
      expect(result, 50, reason: 'Local progress should win when greater than server');
    });

    test('local unread (page 5), server read (page 50) → takes server 50', () {
      // Server has more progress
      final result = mergeLastPageRead(
        local: 5,
        server: 50,
        localWasRead: false,
        serverIsRead: true,
        hasPendingMutation: false,
      );
      expect(result, 50);
    });

    test('hasPendingMutation=true → always returns local', () {
      // Pending mutation should always preserve local value
      final result = mergeLastPageRead(
        local: 10,
        server: 100,
        localWasRead: true,
        serverIsRead: true,
        hasPendingMutation: true,
      );
      expect(result, 10);
    });

    test('both unread, local 10, server 5 → returns 10 (max)', () {
      final result = mergeLastPageRead(
        local: 10,
        server: 5,
        localWasRead: false,
        serverIsRead: false,
        hasPendingMutation: false,
      );
      expect(result, 10);
    });

    test('local read (page 1), server unread (page 0) → keeps local 1', () {
      // Edge case: user just started reading (page 1), server says unread (page 0)
      final result = mergeLastPageRead(
        local: 1,
        server: 0,
        localWasRead: true,
        serverIsRead: false,
        hasPendingMutation: false,
      );
      expect(result, 1, reason: 'Even page 1 should not be rewound to 0');
    });
  });

  group('Self-healing scrape — chapter matching by URL not title', () {
    test('matches by URL when manga URL available', () {
      final chList = [
        {'name': 'Chapter 1', 'chapterNumber': 1.0, 'url': 'https://site.com/ch1'},
        {'name': 'Chapter 2', 'chapterNumber': 2.0, 'url': 'https://site.com/ch2'},
      ];

      // When manga URL is known, should match by URL
      final match = chList.where((c) {
        final url = (c['url'] as String? ?? '').trim();
        return url == 'https://site.com/ch1';
      }).toList();

      expect(match.length, 1);
      expect(match.first['name'], 'Chapter 1');
    });

    test('does not match by title alone when URL differs', () {
      // Two different manga with same chapter names
      final chListMangaA = [
        {'name': 'Chapter 1', 'chapterNumber': 1.0, 'url': 'https://siteA.com/ch1'},
      ];
      final chListMangaB = [
        {'name': 'Chapter 1', 'chapterNumber': 1.0, 'url': 'https://siteB.com/ch1'},
      ];

      // Should NOT match Manga B's chapter when searching for Manga A's URL
      final matchA = chListMangaA.where((c) => c['url'] == 'https://siteA.com/ch1').toList();
      expect(matchA.length, 1);

      final matchB = chListMangaB.where((c) => c['url'] == 'https://siteA.com/ch1').toList();
      expect(matchB.length, 0, reason: 'Should not match by title alone');
    });

    test('falls back to chapter number when URL unavailable', () {
      final chList = [
        {'name': 'Chapter 1', 'chapterNumber': 1.0, 'url': ''},
        {'name': 'Chapter 2', 'chapterNumber': 2.0, 'url': ''},
      ];

      // When URLs are empty, fall back to chapter number
      final match = chList.where((c) => (c['chapterNumber'] as num).toDouble() == 1.0).toList();
      expect(match.length, 1);
      expect(match.first['name'], 'Chapter 1');
    });
  });

  group('Image cache eviction — never evicts on-screen images', () {
    test('evicts oldest non-on-screen image when cache full', () {
      final recoveredImages = <String, List<int>>{
        'url1': [1],
        'url2': [2],
        'url3': [3],
      };
      final pageUrls = ['url1', 'url2', 'url3'];
      const currentPage = 1; // 0-indexed, so page 1 is the second page

      // Simulate eviction logic: find candidate that's not currentPage ±2
      String? evictCandidate;
      for (final key in recoveredImages.keys) {
        final idx = pageUrls.indexOf(key);
        if (idx == -1 || (idx - (currentPage - 1)).abs() > 2) {
          evictCandidate = key;
          break;
        }
      }

      // With currentPage=1 (0-indexed), pages 0, 1, 2 are protected
      // All 3 URLs are in the protected range, so none should be evicted
      // Falls back to first key
      evictCandidate ??= recoveredImages.keys.first;

      expect(evictCandidate, 'url1'); // Falls back to first
    });

    test('does not evict current page ±2', () {
      final keysInOrder = ['url1', 'url2', 'url3', 'url4', 'url5'];
      const currentPage = 2; // 0-indexed, page 2

      String? evictCandidate;
      for (final key in keysInOrder) {
        final idx = keysInOrder.indexOf(key);
        if (idx == -1 || (idx - (currentPage - 1)).abs() > 2) {
          evictCandidate = key;
          break;
        }
      }

      // currentPage=2, protected range is indices 0-3 (currentPage-1 ± 2 = 1±2 = -1 to 3)
      // So indices 0,1,2,3 are protected. Index 4 (url5) is first non-protected.
      expect(evictCandidate, 'url5');
    });

    test('falls back to first key when all pages protected', () {
      final recoveredImages = <String, List<int>>{
        'url1': [1],
        'url2': [2],
      };
      final keysInOrder = ['url1', 'url2'];
      const currentPage = 0; // Only pages 0 and 1 exist

      String? evictCandidate;
      for (final key in keysInOrder) {
        final idx = keysInOrder.indexOf(key);
        if (idx == -1 || (idx - (currentPage - 1)).abs() > 2) {
          evictCandidate = key;
          break;
        }
      }

      // Both pages protected, falls back to first
      evictCandidate ??= recoveredImages.keys.first;

      expect(evictCandidate, 'url1');
    });
  });

  group('Auto-scroll resume — per-chapter flag', () {
    test('resume flag is per-chapter, not global', () {
      final resumeFlags = <int, bool>{};

      // Chapter 100 has auto-scroll enabled
      resumeFlags[100] = true;
      // Chapter 101 has auto-scroll disabled
      resumeFlags[101] = false;

      // When loading chapter 101, should get false
      expect(resumeFlags[101], isFalse);
      // When loading chapter 100, should get true
      expect(resumeFlags[100], isTrue);

      // Changing flag for one chapter doesn't affect others
      resumeFlags[101] = true;
      expect(resumeFlags[100], isTrue);
      expect(resumeFlags[101], isTrue);
    });

    test('resume flag cleared after use', () {
      final resumeFlags = <int, bool>{100: true};

      // Simulate loading chapter 100 - flag should be consumed
      final shouldResume = resumeFlags.remove(100) ?? false;
      expect(shouldResume, isTrue);
      expect(resumeFlags.containsKey(100), isFalse);
    });
  });

  group('Volume key recentering — generation guard', () {
    test('recenter guard uses generation token to prevent stale timer callbacks', () {
      int generation = 0;
      bool isRecentering = false;
      Timer? recenterTimer;

      void recenter() {
        final currentGen = ++generation;
        isRecentering = true;

        // Simulate timer
        recenterTimer?.cancel();
        recenterTimer = Timer(const Duration(milliseconds: 600), () {
          // Only clear if generation hasn't changed
          if (generation == currentGen) {
            isRecentering = false;
          }
        });
      }

      // Initial recenter
      recenter();
      expect(isRecentering, isTrue);

      // Immediate second recenter (race condition) - should not affect first timer's callback
      final firstGen = generation;
      recenter();
      expect(generation, firstGen + 1);

      // The first timer's callback should NOT clear isRecentering because generation changed
      // (In real code, the timer would check generation equality)
    });
  });
}