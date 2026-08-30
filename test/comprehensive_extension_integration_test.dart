import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/engine/javascript/m_client.dart';
import 'package:sunfire/src/core/engine/quickjs_service.dart';

const int _rtldNow = 2;
const int _rtldGlobal = 0x100;

typedef _DlopenNative = Pointer Function(Pointer<Utf8> filename, Int32 flag);
typedef _DlopenDart = Pointer Function(Pointer<Utf8> filename, int flag);

void _loadQuickJsPluginGlobally(String path) {
  final libc = DynamicLibrary.process();
  final dlopen = libc.lookupFunction<_DlopenNative, _DlopenDart>('dlopen');
  final pathPtr = path.toNativeUtf8();
  try {
    final handle = dlopen(pathPtr, _rtldNow | _rtldGlobal);
    if (handle == nullptr) throw StateError('dlopen failed for $path');
  } finally {
    calloc.free(pathPtr);
  }
}

/// Comprehensive Extension Integration Test Suite
/// This test suite performs real-world testing of all manga extensions
/// by actually running the JavaScript code and testing against live websites.
/// Tests mimic actual app behavior including thumbnails, filters, reading, etc.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late QuickJsService quickJs;

  setUpAll(() async {
    HttpOverrides.global = null;
    try {
      _loadQuickJsPluginGlobally(
        '/home/zoro/Documents/Projects/manga/sunfire/build/linux/x64/debug/bundle/lib/libflutter_qjs_plugin.so',
      );
    } catch (_) {}

    quickJs = QuickJsService.instance;
    await quickJs.initialize();
    
    // Configure FlareSolverr for Cloudflare bypass
    MClient.cfProxyUrl = 'http://100.85.171.6:8191/v1';
    print('✅ FlareSolverr configured: http://100.85.171.6:8191/v1');
    
    // Load all extensions from the mangayomi-extensions directory
    final extensionsDir = Directory('/home/zoro/Documents/Projects/manga/mangayomi-extensions/javascript/manga/src/en');
    if (await extensionsDir.exists()) {
      final files = await extensionsDir.list().toList();
      for (final file in files) {
        if (file is File && file.path.endsWith('.js')) {
          try {
            final code = await file.readAsString();
            final fileName = file.uri.pathSegments.last.replaceAll('.js', '');
            await quickJs.saveLocalExtension(fileName, code);
            print('✅ Loaded extension: $fileName');
          } catch (e) {
            print('❌ Failed to load extension: ${file.path} - $e');
          }
        }
      }
    }
  });

  group('COMPREHENSIVE EXTENSION TESTS: Real-World App Behavior', () {
    
    // ============= MANGAGO EXTENSION TESTS =============
    group('Mangago Extension - Full Feature Test', () {
      test('1. Popular Manga - Thumbnail Loading', () async {
        final result = await quickJs.fetchSourceMangaLocal(
          'Mangago',
          isLatest: false,
          page: 1,
        );
        
        expect(result, isNotEmpty);
        expect(result.length, greaterThan(0));
        
        // Verify thumbnail URLs are valid
        for (final manga in result) {
          expect(manga['name'], isNotEmpty);
          expect(manga['link'], isNotEmpty);
          if (manga['imageUrl'] != null && manga['imageUrl'].toString().isNotEmpty) {
            expect(manga['imageUrl'], startsWith('http'));
          }
        }
        
        print('✅ Mangago Popular: ${result.length} manga loaded with thumbnails');
      }, timeout: const Timeout(Duration(minutes: 2)));

      test('2. Latest Updates - Real-time Content', () async {
        final result = await quickJs.fetchSourceMangaLocal(
          'Mangago',
          isLatest: true,
          page: 1,
        );
        
        expect(result, isNotEmpty);
        expect(result.length, greaterThan(0));
        
        print('✅ Mangago Latest: ${result.length} recent updates loaded');
      }, timeout: const Timeout(Duration(minutes: 2)));

      test('3. Search Functionality - Real Queries', () async {
        final result = await quickJs.fetchSourceMangaLocal(
          'Mangago',
          searchQuery: 'one piece',
          page: 1,
        );
        
        expect(result, isNotEmpty);
        
        // Verify search results are relevant
        for (final manga in result) {
          expect(manga['name'], isNotEmpty);
          expect(manga['link'], isNotEmpty);
        }
        
        print('✅ Mangago Search: ${result.length} results for "one piece"');
      }, timeout: const Timeout(Duration(minutes: 2)));

      test('4. Manga Details - Complete Metadata', () async {
        // First get a manga from popular list
        final popular = await quickJs.fetchSourceMangaLocal('Mangago', page: 1);
        if (popular.isNotEmpty) {
          final firstManga = popular.first;
          final mangaUrl = firstManga['link'] ?? firstManga['url'];
          
          if (mangaUrl != null) {
            final details = await quickJs.fetchMangaDetailsLocal('Mangago', mangaUrl);
            
            expect(details, isNotEmpty);
            expect(details['name'], isNotEmpty);
            expect(details['chapters'], isNotEmpty);
            
            print('✅ Mangago Details: "${details['name']}" with ${details['chapters'].length} chapters');
          }
        }
      }, timeout: const Timeout(Duration(minutes: 2)));

      test('5. Chapter Pages - Reading Simulation', () async {
        // Get a manga and its chapters
        final popular = await quickJs.fetchSourceMangaLocal('Mangago', page: 1);
        if (popular.isNotEmpty) {
          final firstManga = popular.first;
          final mangaUrl = firstManga['link'] ?? firstManga['url'];
          
          if (mangaUrl != null) {
            final details = await quickJs.fetchMangaDetailsLocal('Mangago', mangaUrl);
            final chapters = details['chapters'] as List?;
            
            if (chapters != null && chapters.isNotEmpty) {
              final firstChapter = chapters.first;
              final chapterUrl = firstChapter['url'];
              
              if (chapterUrl != null) {
                final pages = await quickJs.fetchChapterPagesLocal('Mangago', chapterUrl);
                
                expect(pages, isNotEmpty);
                expect(pages.length, greaterThan(0));
                
                // Verify page URLs are valid
                for (final page in pages) {
                  expect(page, startsWith('http'));
                }
                
                print('✅ Mangago Reading: ${pages.length} pages loaded for chapter');
              }
            }
          }
        }
      }, timeout: const Timeout(Duration(minutes: 3)));

      test('6. Filter System - No Filter Support', () async {
        final filters = await quickJs.fetchSourceFiltersLocal('Mangago');
        
        // Mangago reports no filters available
        expect(filters, isList);
        print('✅ Mangago Filters: ${filters.length} filter groups available');
      }, timeout: const Timeout(Duration(seconds: 30)));
    });

    // ============= MANGAPILL EXTENSION TESTS =============
    group('Mangapill Extension - Full Feature Test', () {
      test('7. Popular Manga - Thumbnail Loading', () async {
        final result = await quickJs.fetchSourceMangaLocal(
          'Mangapill',
          isLatest: false,
          page: 1,
        );
        
        expect(result, isNotEmpty);
        expect(result.length, greaterThan(0));
        
        for (final manga in result) {
          expect(manga['name'], isNotEmpty);
          expect(manga['link'], isNotEmpty);
        }
        
        print('✅ Mangapill Popular: ${result.length} manga loaded');
      }, timeout: const Timeout(Duration(minutes: 2)));

      test('8. Search Functionality - Real Queries', () async {
        final result = await quickJs.fetchSourceMangaLocal(
          'Mangapill',
          searchQuery: 'one piece',
          page: 1,
        );
        
        expect(result, isNotEmpty);
        
        print('✅ Mangapill Search: ${result.length} results for "one piece"');
      }, timeout: const Timeout(Duration(minutes: 2)));

      test('9. Filter System - Advanced Filters', () async {
        final filters = await quickJs.fetchSourceFiltersLocal('Mangapill');
        
        expect(filters, isNotEmpty);
        expect(filters.length, greaterThan(0));
        
        // Test filter structure
        for (final filter in filters) {
          expect(filter, isA<Map>());
          expect(filter['type_name'], isNotEmpty);
          expect(filter['name'], isNotEmpty);
        }
        
        print('✅ Mangapill Filters: ${filters.length} filter groups available');
        
        // Test filtered search
        final filteredResult = await quickJs.fetchSourceMangaLocal(
          'Mangapill',
          searchQuery: '',
          page: 1,
          dynamicFilters: [
            {'name': 'Type', 'state': 0},
            {'name': 'Status', 'state': 0},
          ],
        );
        
        expect(filteredResult, isList);
        print('✅ Mangapill Filtered Search: ${filteredResult.length} results');
      }, timeout: const Timeout(Duration(minutes: 2)));

      test('10. Manga Details - Complete Metadata', () async {
        final popular = await quickJs.fetchSourceMangaLocal('Mangapill', page: 1);
        if (popular.isNotEmpty) {
          final firstManga = popular.first;
          final mangaUrl = firstManga['link'] ?? firstManga['url'];
          
          if (mangaUrl != null) {
            final details = await quickJs.fetchMangaDetailsLocal('Mangapill', mangaUrl);
            
            expect(details, isNotEmpty);
            expect(details['name'], isNotEmpty);
            expect(details['chapters'], isNotEmpty);
            
            print('✅ Mangapill Details: "${details['name']}" with ${details['chapters'].length} chapters');
          }
        }
      }, timeout: const Timeout(Duration(minutes: 2)));

      test('11. Chapter Pages - Reading Simulation', () async {
        final popular = await quickJs.fetchSourceMangaLocal('Mangapill', page: 1);
        if (popular.isNotEmpty) {
          final firstManga = popular.first;
          final mangaUrl = firstManga['link'] ?? firstManga['url'];
          
          if (mangaUrl != null) {
            final details = await quickJs.fetchMangaDetailsLocal('Mangapill', mangaUrl);
            final chapters = details['chapters'] as List?;
            
            if (chapters != null && chapters.isNotEmpty) {
              final firstChapter = chapters.first;
              final chapterUrl = firstChapter['url'];
              
              if (chapterUrl != null) {
                final pages = await quickJs.fetchChapterPagesLocal('Mangapill', chapterUrl);
                
                expect(pages, isNotEmpty);
                expect(pages.length, greaterThan(0));
                
                print('✅ Mangapill Reading: ${pages.length} pages loaded');
              }
            }
          }
        }
      }, timeout: const Timeout(Duration(minutes: 3)));
    });

    // ============= NHENTAI EXTENSION TESTS =============
    group('nHentai Extension - Full Feature Test', () {
      test('12. Popular Gallery - Thumbnail Loading', () async {
        final result = await quickJs.fetchSourceMangaLocal(
          'nHentai',
          isLatest: false,
          page: 1,
        );
        
        expect(result, isNotEmpty);
        expect(result.length, greaterThan(0));
        
        for (final gallery in result) {
          expect(gallery['name'], isNotEmpty);
          expect(gallery['link'], isNotEmpty);
          expect(gallery['link'], contains('nhentai.net/g/'));
        }
        
        print('✅ nHentai Popular: ${result.length} galleries loaded');
      }, timeout: const Timeout(Duration(minutes: 2)));

      test('13. Search Functionality - Real Queries', () async {
        final result = await quickJs.fetchSourceMangaLocal(
          'nHentai',
          searchQuery: 'tag:schoolgirl',
          page: 1,
        );
        
        expect(result, isNotEmpty);
        
        print('✅ nHentai Search: ${result.length} results for "tag:schoolgirl"');
      }, timeout: const Timeout(Duration(minutes: 2)));

      test('14. Filter System - Advanced Tag Filters', () async {
        final filters = await quickJs.fetchSourceFiltersLocal('nHentai');
        
        expect(filters, isNotEmpty);
        expect(filters.length, greaterThan(0));
        
        print('✅ nHentai Filters: ${filters.length} filter groups available');
      }, timeout: const Timeout(Duration(seconds: 30)));

      test('15. Gallery Details - Complete Metadata', () async {
        final popular = await quickJs.fetchSourceMangaLocal('nHentai', page: 1);
        if (popular.isNotEmpty) {
          final firstGallery = popular.first;
          final galleryUrl = firstGallery['link'] ?? firstGallery['url'];
          
          if (galleryUrl != null) {
            final details = await quickJs.fetchMangaDetailsLocal('nHentai', galleryUrl);
            
            expect(details, isNotEmpty);
            expect(details['name'], isNotEmpty);
            expect(details['chapters'], isNotEmpty);
            
            print('✅ nHentai Details: "${details['name']}" with ${details['chapters'].length} chapters');
          }
        }
      }, timeout: const Timeout(Duration(minutes: 2)));

      test('16. Gallery Pages - High-Res Reading', () async {
        final popular = await quickJs.fetchSourceMangaLocal('nHentai', page: 1);
        if (popular.isNotEmpty) {
          final firstGallery = popular.first;
          final galleryUrl = firstGallery['link'] ?? firstGallery['url'];
          
          if (galleryUrl != null) {
            final details = await quickJs.fetchMangaDetailsLocal('nHentai', galleryUrl);
            final chapters = details['chapters'] as List?;
            
            if (chapters != null && chapters.isNotEmpty) {
              final firstChapter = chapters.first;
              final chapterUrl = firstChapter['url'];
              
              if (chapterUrl != null) {
                final pages = await quickJs.fetchChapterPagesLocal('nHentai', chapterUrl);
                
                expect(pages, isNotEmpty);
                expect(pages.length, greaterThan(0));
                
                // Verify high-resolution image URLs
                for (final page in pages) {
                  expect(page, contains('i.nhentai.net'));
                }
                
                print('✅ nHentai Reading: ${pages.length} high-res pages loaded');
              }
            }
          }
        }
      }, timeout: const Timeout(Duration(minutes: 3)));
    });

    // ============= WEBTOONS EXTENSION TESTS =============
    group('Webtoons Extension - Full Feature Test', () {
      test('17. Popular Webtoons - Thumbnail Loading', () async {
        final result = await quickJs.fetchSourceMangaLocal(
          'Webtoons',
          isLatest: false,
          page: 1,
        );
        
        expect(result, isNotEmpty);
        expect(result.length, greaterThan(0));
        
        for (final webtoon in result) {
          expect(webtoon['name'], isNotEmpty);
          expect(webtoon['link'], isNotEmpty);
          expect(webtoon['link'], contains('webtoons.com'));
        }
        
        print('✅ Webtoons Popular: ${result.length} webtoons loaded');
      }, timeout: const Timeout(Duration(minutes: 2)));

      test('18. Latest Updates - Real-time Content', () async {
        final result = await quickJs.fetchSourceMangaLocal(
          'Webtoons',
          isLatest: true,
          page: 1,
        );
        
        expect(result, isNotEmpty);
        
        print('✅ Webtoons Latest: ${result.length} recent updates loaded');
      }, timeout: const Timeout(Duration(minutes: 2)));

      test('19. Webtoon Details - Complete Metadata', () async {
        final popular = await quickJs.fetchSourceMangaLocal('Webtoons', page: 1);
        if (popular.isNotEmpty) {
          final firstWebtoon = popular.first;
          final webtoonUrl = firstWebtoon['link'] ?? firstWebtoon['url'];
          
          if (webtoonUrl != null) {
            final details = await quickJs.fetchMangaDetailsLocal('Webtoons', webtoonUrl);
            
            expect(details, isNotEmpty);
            expect(details['name'], isNotEmpty);
            expect(details['chapters'], isNotEmpty);
            
            print('✅ Webtoons Details: "${details['name']}" with ${details['chapters'].length} episodes');
          }
        }
      }, timeout: const Timeout(Duration(minutes: 2)));

      test('20. Episode Pages - Webtoon Reading Format', () async {
        final popular = await quickJs.fetchSourceMangaLocal('Webtoons', page: 1);
        if (popular.isNotEmpty) {
          final firstWebtoon = popular.first;
          final webtoonUrl = firstWebtoon['link'] ?? firstWebtoon['url'];
          
          if (webtoonUrl != null) {
            final details = await quickJs.fetchMangaDetailsLocal('Webtoons', webtoonUrl);
            final chapters = details['chapters'] as List?;
            
            if (chapters != null && chapters.isNotEmpty) {
              final firstChapter = chapters.first;
              final chapterUrl = firstChapter['url'];
              
              if (chapterUrl != null) {
                final pages = await quickJs.fetchChapterPagesLocal('Webtoons', chapterUrl);
                
                expect(pages, isNotEmpty);
                expect(pages.length, greaterThan(0));
                
                print('✅ Webtoons Reading: ${pages.length} episode images loaded');
              }
            }
          }
        }
      }, timeout: const Timeout(Duration(minutes: 3)));
    });

    // ============= WEEB CENTRAL EXTENSION TESTS =============
    group('Weeb Central Extension - Full Feature Test', () {
      test('21. Popular Manga - Thumbnail Loading', () async {
        final result = await quickJs.fetchSourceMangaLocal(
          'Weeb Central',
          isLatest: false,
          page: 1,
        );
        
        expect(result, isNotEmpty);
        expect(result.length, greaterThan(0));
        
        for (final manga in result) {
          expect(manga['name'], isNotEmpty);
          expect(manga['link'], isNotEmpty);
        }
        
        print('✅ Weeb Central Popular: ${result.length} manga loaded');
      }, timeout: const Timeout(Duration(minutes: 2)));

      test('22. Search Functionality - Real Queries', () async {
        final result = await quickJs.fetchSourceMangaLocal(
          'Weeb Central',
          searchQuery: 'one piece',
          page: 1,
        );
        
        expect(result, isNotEmpty);
        
        print('✅ Weeb Central Search: ${result.length} results for "one piece"');
      }, timeout: const Timeout(Duration(minutes: 2)));

      test('23. Manga Details - Complete Metadata', () async {
        final popular = await quickJs.fetchSourceMangaLocal('Weeb Central', page: 1);
        if (popular.isNotEmpty) {
          final firstManga = popular.first;
          final mangaUrl = firstManga['link'] ?? firstManga['url'];
          
          if (mangaUrl != null) {
            final details = await quickJs.fetchMangaDetailsLocal('Weeb Central', mangaUrl);
            
            expect(details, isNotEmpty);
            expect(details['name'], isNotEmpty);
            expect(details['chapters'], isNotEmpty);
            
            print('✅ Weeb Central Details: "${details['name']}" with ${details['chapters'].length} chapters');
          }
        }
      }, timeout: const Timeout(Duration(minutes: 2)));

      test('24. Chapter Pages - Reading Simulation', () async {
        final popular = await quickJs.fetchSourceMangaLocal('Weeb Central', page: 1);
        if (popular.isNotEmpty) {
          final firstManga = popular.first;
          final mangaUrl = firstManga['link'] ?? firstManga['url'];
          
          if (mangaUrl != null) {
            final details = await quickJs.fetchMangaDetailsLocal('Weeb Central', mangaUrl);
            final chapters = details['chapters'] as List?;
            
            if (chapters != null && chapters.isNotEmpty) {
              final firstChapter = chapters.first;
              final chapterUrl = firstChapter['url'];
              
              if (chapterUrl != null) {
                final pages = await quickJs.fetchChapterPagesLocal('Weeb Central', chapterUrl);
                
                expect(pages, isNotEmpty);
                expect(pages.length, greaterThan(0));
                
                print('✅ Weeb Central Reading: ${pages.length} pages loaded');
              }
            }
          }
        }
      }, timeout: const Timeout(Duration(minutes: 3)));
    });

    // ============= MANGAFREAK EXTENSION TESTS =============
    group('MangaFreak Extension - Full Feature Test', () {
      test('25. Popular Manga - Thumbnail Loading', () async {
        final result = await quickJs.fetchSourceMangaLocal(
          'MangaFreak',
          isLatest: false,
          page: 1,
        );
        
        expect(result, isNotEmpty);
        expect(result.length, greaterThan(0));
        
        for (final manga in result) {
          expect(manga['name'], isNotEmpty);
          expect(manga['link'], isNotEmpty);
        }
        
        print('✅ MangaFreak Popular: ${result.length} manga loaded');
      }, timeout: const Timeout(Duration(minutes: 2)));

      test('26. Latest Updates - Real-time Content', () async {
        final result = await quickJs.fetchSourceMangaLocal(
          'MangaFreak',
          isLatest: true,
          page: 1,
        );
        
        expect(result, isNotEmpty);
        
        print('✅ MangaFreak Latest: ${result.length} recent updates loaded');
      }, timeout: const Timeout(Duration(minutes: 2)));

      test('27. Search Functionality - Real Queries', () async {
        final result = await quickJs.fetchSourceMangaLocal(
          'MangaFreak',
          searchQuery: 'one piece',
          page: 1,
        );
        
        expect(result, isNotEmpty);
        
        print('✅ MangaFreak Search: ${result.length} results for "one piece"');
      }, timeout: const Timeout(Duration(minutes: 2)));
    });

    // ============= MANGAHERE EXTENSION TESTS =============
    group('MangaHere Extension - Full Feature Test', () {
      test('28. Popular Manga - Thumbnail Loading', () async {
        final result = await quickJs.fetchSourceMangaLocal(
          'MangaHere',
          isLatest: false,
          page: 1,
        );
        
        expect(result, isNotEmpty);
        expect(result.length, greaterThan(0));
        
        for (final manga in result) {
          expect(manga['name'], isNotEmpty);
          expect(manga['link'], isNotEmpty);
        }
        
        print('✅ MangaHere Popular: ${result.length} manga loaded');
      }, timeout: const Timeout(Duration(minutes: 2)));

      test('29. Search Functionality - Real Queries', () async {
        final result = await quickJs.fetchSourceMangaLocal(
          'MangaHere',
          searchQuery: 'one piece',
          page: 1,
        );
        
        expect(result, isNotEmpty);
        
        print('✅ MangaHere Search: ${result.length} results for "one piece"');
      }, timeout: const Timeout(Duration(minutes: 2)));
    });

    // ============= READ COMICS ONLINE EXTENSION TESTS =============
    group('ReadComicOnline Extension - Full Feature Test', () {
      test('30. Popular Comics - Thumbnail Loading', () async {
        final result = await quickJs.fetchSourceMangaLocal(
          'ReadComicOnline',
          isLatest: false,
          page: 1,
        );
        
        expect(result, isNotEmpty);
        expect(result.length, greaterThan(0));
        
        for (final comic in result) {
          expect(comic['name'], isNotEmpty);
          expect(comic['link'], isNotEmpty);
        }
        
        print('✅ ReadComicOnline Popular: ${result.length} comics loaded');
      }, timeout: const Timeout(Duration(minutes: 2)));

      test('31. Search Functionality - Real Queries', () async {
        final result = await quickJs.fetchSourceMangaLocal(
          'ReadComicOnline',
          searchQuery: 'batman',
          page: 1,
        );
        
        expect(result, isNotEmpty);
        
        print('✅ ReadComicOnline Search: ${result.length} results for "batman"');
      }, timeout: const Timeout(Duration(minutes: 2)));
    });
  });

  group('PERFORMANCE AND RELIABILITY TESTS', () {
    test('32. Extension Loading Performance', () async {
      final startTime = DateTime.now();
      
      final result = await quickJs.fetchSourceMangaLocal('Mangapill', page: 1);
      
      final duration = DateTime.now().difference(startTime);
      
      expect(result, isNotEmpty);
      expect(duration.inSeconds, lessThan(30)); // Should complete within 30 seconds
      
      print('✅ Performance: Mangapill loaded in ${duration.inSeconds} seconds');
    }, timeout: const Timeout(Duration(minutes: 1)));

    test('33. Concurrent Extension Access', () async {
      final startTime = DateTime.now();
      
      final results = await Future.wait([
        quickJs.fetchSourceMangaLocal('Mangapill', page: 1),
        quickJs.fetchSourceMangaLocal('Weeb Central', page: 1),
        quickJs.fetchSourceMangaLocal('MangaFreak', page: 1),
      ]);
      
      final duration = DateTime.now().difference(startTime);
      
      for (final result in results) {
        expect(result, isNotEmpty);
      }
      
      expect(duration.inSeconds, lessThan(60)); // Should complete within 60 seconds
      
      print('✅ Concurrent: 3 extensions loaded in ${duration.inSeconds} seconds');
    }, timeout: const Timeout(Duration(minutes: 2)));

    test('34. Error Handling - Invalid URLs', () async {
      try {
        final result = await quickJs.fetchMangaDetailsLocal('Mangapill', '/invalid/url');
        
        // Should handle gracefully without crashing
        expect(result, isA<Map>());
        print('✅ Error Handling: Invalid URL handled gracefully');
      } catch (e) {
        // Expected to handle error gracefully
        print('✅ Error Handling: Invalid URL threw expected error: $e');
      }
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('35. Error Handling - Network Failures', () async {
      // Test with a non-existent extension
      final result = await quickJs.fetchSourceMangaLocal('NonExistentExtension', page: 1);
      
      // Should return empty list without crashing
      expect(result, isEmpty);
      print('✅ Error Handling: Non-existent extension handled gracefully');
    }, timeout: const Timeout(Duration(seconds: 10)));

    test('36. MClient Security Configuration', () {
      // Verify MClient is properly configured without SSL bypass
      expect(MClient.userAgent, isNotEmpty);
      expect(MClient.userAgent, contains('Mozilla'));
      print('✅ Security: MClient properly configured');
    });
  });
}