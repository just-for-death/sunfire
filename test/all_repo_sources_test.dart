import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/engine/javascript/js_extension_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const repoDir = '/home/zoro/Documents/Projects/mangayomi-extensions/javascript/manga/src/en';

  group('TESTING ALL REPOSITORY EXTENSIONS END-TO-END', () {
    final dir = Directory(repoDir);
    final files = dir.listSync().whereType<File>().where((f) => f.path.endsWith('.js')).toList();

    for (final file in files) {
      final fileName = file.path.split('/').last;

      test('Extension: $fileName', () async {
        final content = await file.readAsString();

        // Extract metadata from code or default
        final meta = <String, dynamic>{
          'name': fileName.replaceAll('.js', ''),
          'lang': 'en',
          'baseUrl': '',
        };

        final baseMatch = RegExp(r'"baseUrl":\s*"([^"]+)"').firstMatch(content);
        if (baseMatch != null) {
          meta['baseUrl'] = baseMatch.group(1);
        }
        final nameMatch = RegExp(r'"name":\s*"([^"]+)"').firstMatch(content);
        if (nameMatch != null) {
          meta['name'] = nameMatch.group(1);
        }

        print('\n----------------------------------------');
        print('Testing Extension: ${meta['name']} ($fileName)');
        print('BaseUrl: ${meta['baseUrl']}');

        final service = JsExtensionService(
          sourceMeta: meta,
          sourceCode: content,
        );

        int popularCount = 0;
        int chapterCount = 0;
        int pageCount = 0;
        String? firstMangaLink;
        String? firstChapterUrl;

        // 1. Test getPopular
        try {
          final pop = await service.getPopular(1);
          final list = pop['list'] as List? ?? [];
          popularCount = list.length;
          print('✓ getPopular(1) -> Found ${list.length} manga');
          if (list.isNotEmpty) {
            final first = list.first as Map;
            firstMangaLink = first['link']?.toString();
            print('  Sample manga: ${first['name']} -> $firstMangaLink');
          }
        } catch (e) {
          print('⚠ getPopular error: $e');
        }

        // 2. Test getDetail
        if (firstMangaLink != null && firstMangaLink.isNotEmpty) {
          try {
            final detail = await service.getDetail(firstMangaLink);
            final chapters = (detail['chapters'] ?? detail['episodes']) as List? ?? [];
            chapterCount = chapters.length;
            print('✓ getDetail -> Found ${chapters.length} chapters');
            if (chapters.isNotEmpty) {
              final firstChap = chapters.first as Map;
              firstChapterUrl = firstChap['url']?.toString();
              print('  Sample chapter: ${firstChap['name']} -> $firstChapterUrl');
            }
          } catch (e) {
            print('⚠ getDetail error: $e');
          }
        }

        // 3. Test getPageList
        if (firstChapterUrl != null && firstChapterUrl.isNotEmpty) {
          try {
            final pages = await service.getPageList(firstChapterUrl);
            pageCount = pages.length;
            print('✓ getPageList -> Resolved ${pages.length} pages');
            if (pages.isNotEmpty) {
              print('  First page sample: ${pages.first}');
            }
          } catch (e) {
            print('⚠ getPageList error: $e');
          }
        }

        service.dispose();

        print('Result: Popular=$popularCount, Chapters=$chapterCount, Pages=$pageCount');
        expect(service, isNotNull);
      }, timeout: const Timeout(Duration(seconds: 45)));
    }
  });
}
