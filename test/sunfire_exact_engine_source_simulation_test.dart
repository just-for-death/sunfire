import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/engine/javascript/js_extension_service.dart';
import 'package:sunfire/src/core/engine/javascript/m_client.dart';
import 'package:sunfire/src/core/engine/quickjs_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = null;

  const extensionsDir = '/home/zoro/Documents/Projects/mangayomi-extensions/javascript/manga/src/en';

  final sourcesToTest = [
    {'name': 'Weeb Central', 'file': 'weeb_central.js', 'search': 'solo'},
    {'name': 'Webtoons', 'file': 'webtoons.js', 'search': 'tower'},
    {'name': 'MangaPill', 'file': 'mangapill.js', 'search': 'one piece'},
    {'name': 'MangaFreak', 'file': 'mangafreak.js', 'search': 'solo'},
    {'name': 'Mangago', 'file': 'mangago.js', 'search': 'solo'},
    {'name': 'MangaHere', 'file': 'mangahere.js', 'search': 'naruto'},
    {'name': 'ReadComicOnline', 'file': 'read_comics_online.js', 'search': 'batman'},
    {'name': 'nHentai.com (unoriginal)', 'file': 'nhentai.js', 'search': 'naruto'},
  ];

  bool isValidImageMagic(Uint8List bytes) {
    if (bytes.length < 4) return false;
    final hex = bytes.take(4).map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    // JPEG: ffd8, PNG: 89504e47, WebP: 52494646 (RIFF), GIF: 47494638
    return hex.startsWith('ffd8') || hex.startsWith('89504e47') || hex.startsWith('52494646') || hex.startsWith('47494638');
  }

  String getImageType(Uint8List bytes) {
    if (bytes.length < 4) return 'UNKNOWN';
    final hex = bytes.take(4).map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    if (hex.startsWith('ffd8')) return 'JPEG';
    if (hex.startsWith('89504e47')) return 'PNG';
    if (hex.startsWith('52494646')) return 'WebP (RIFF)';
    if (hex.startsWith('47494638')) return 'GIF';
    return 'UNKNOWN ($hex)';
  }

  group('SUNFIRE EXACT ENGINE LIFECYCLE SIMULATION TESTS', () {
    for (final s in sourcesToTest) {
      final sourceName = s['name']!;
      final fileName = s['file']!;
      final searchQuery = s['search']!;

      test('SOURCE TEST: $sourceName ($fileName)', () async {
        print('\n' + '=' * 70);
        print('STARTING END-TO-END ENGINE TEST: $sourceName');
        print('=' * 70);

        final jsFile = File('$extensionsDir/$fileName');
        expect(jsFile.existsSync(), isTrue, reason: 'File $fileName must exist');
        final jsCode = await jsFile.readAsString();

        // 1. EXTRACT METADATA
        final meta = QuickJsService.instance.extractSourceMetadata(jsCode);
        print('1. [METADATA] Name: ${meta['name']}, BaseUrl: ${meta['baseUrl']}, Lang: ${meta['lang']}');

        // 2. INITIALIZE ENGINE RUNTIME
        final service = JsExtensionService(
          sourceMeta: meta,
          sourceCode: jsCode,
        );

        try {
          // 3. TEST POPULAR / CATALOG
          print('2. [POPULAR] Calling getPopular(1)...');
          Map<String, dynamic> popularResult = {};
          try {
            popularResult = await service.getPopular(1);
          } catch (e) {
            print('   ❌ getPopular threw error: $e');
          }

          final popularList = (popularResult['list'] ?? popularResult['manga'] ?? []) as List<dynamic>;
          print('   ✓ getPopular returned ${popularList.length} items');
          if (popularList.isNotEmpty) {
            final first = Map<String, dynamic>.from(popularList.first as Map);
            print('   - Sample Popular item: "${first['name']}" -> link: ${first['link']}');
          }

          // 4. TEST SEARCH
          print('3. [SEARCH] Calling search("$searchQuery", 1, [])...');
          Map<String, dynamic> searchResult = {};
          try {
            searchResult = await service.extensionCallAsync<Map<String, dynamic>>(
              'search(${jsonEncode(searchQuery)}, 1, [])',
            );
          } catch (e) {
            print('   ❌ search threw error: $e');
          }

          final searchList = (searchResult['list'] ?? searchResult['manga'] ?? []) as List<dynamic>;
          print('   ✓ search returned ${searchList.length} items');
          String testMangaLink = '';
          if (searchList.isNotEmpty) {
            final firstSearch = Map<String, dynamic>.from(searchList.first as Map);
            testMangaLink = (firstSearch['link'] ?? firstSearch['url'] ?? '').toString();
            print('   - Selected search item: "${firstSearch['name']}" -> link: $testMangaLink');
          } else if (popularList.isNotEmpty) {
            final firstPop = Map<String, dynamic>.from(popularList.first as Map);
            testMangaLink = (firstPop['link'] ?? firstPop['url'] ?? '').toString();
            print('   - Fallback to popular item link: $testMangaLink');
          }

          expect(testMangaLink, isNotEmpty, reason: 'Must have at least one manga link to test details');

          // 5. TEST DETAILS & CHAPTER LIST
          print('4. [DETAILS] Calling getDetail("$testMangaLink")...');
          Map<String, dynamic> detailResult = {};
          try {
            detailResult = await service.getDetail(testMangaLink);
          } catch (e) {
            print('   ❌ getDetail threw error: $e');
          }

          final chapters = (detailResult['chapters'] ?? detailResult['episodes'] ?? detailResult['chapterList'] ?? []) as List<dynamic>;
          print('   ✓ getDetail returned ${chapters.length} chapters');
          String testChapterUrl = '';
          if (chapters.isNotEmpty) {
            final firstCh = Map<String, dynamic>.from(chapters.first as Map);
            testChapterUrl = (firstCh['url'] ?? firstCh['link'] ?? '').toString();
            print('   - Selected chapter: "${firstCh['name']}" -> url: $testChapterUrl');
          }

          expect(testChapterUrl, isNotEmpty, reason: 'Must have at least one chapter URL to test pages');

          // 6. TEST GET PAGE LIST
          print('5. [PAGES] Calling getPageList("$testChapterUrl")...');
          List<String> pages = [];
          try {
            pages = await service.getPageList(testChapterUrl);
          } catch (e) {
            print('   ❌ getPageList threw error: $e');
          }

          print('   ✓ getPageList returned ${pages.length} page URLs');
          if (pages.isNotEmpty) {
            print('   - First 3 page URLs:');
            for (final p in pages.take(3)) {
              print('     * $p');
            }
          }

          expect(pages, isNotEmpty, reason: 'getPageList must return at least 1 image URL');

          // 7. TEST BINARY IMAGE DOWNLOAD USING SUNFIRE HTTP ENGINE
          final sampleImageUrl = pages.first;
          print('6. [IMAGE DOWNLOAD] Testing binary download of: $sampleImageUrl');

          final headers = QuickJsService.getImageHeaders(sourceName, sampleImageUrl);
          print('   - Computed Request Headers: $headers');

          final client = MClient.init();
          final response = await client.get(Uri.parse(sampleImageUrl), headers: headers);
          print('   - HTTP Status: ${response.statusCode}');
          print('   - Body Bytes Length: ${response.bodyBytes.length} bytes');

          final bytes = response.bodyBytes;
          final isMagicValid = isValidImageMagic(bytes);
          final imageType = getImageType(bytes);
          print('   - Detected Format: $imageType (Magic Valid: $isMagicValid)');

          expect(response.statusCode, equals(200), reason: 'Image download must return HTTP 200');
          expect(bytes.length, greaterThan(15000), reason: 'Image size must be greater than 15 KB (got ${bytes.length} bytes)');
          expect(isMagicValid, isTrue, reason: 'Image must have valid binary image magic header (got $imageType)');

          print('✅ [SUCCESS] Source $sourceName passed complete end-to-end engine simulation!\n');
        } finally {
          service.dispose();
        }
      });
    }
  });
}
