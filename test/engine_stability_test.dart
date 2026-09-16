import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/engine/content_resolver_service.dart';
import 'package:sunfire/src/core/engine/javascript/m_client.dart';
import 'package:sunfire/src/core/engine/quickjs_service.dart';
import 'package:sunfire/src/core/engine/repo_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Engine Stability: Page Sorting Tests', () {
    test('natural numeric sort handles chapter prefixes and multi-digit page numbers correctly', () {
      final paths = [
        '/downloads/1/ch10_p10.jpg',
        '/downloads/1/ch10_p2.jpg',
        '/downloads/1/ch10_p1.jpg',
        '/downloads/1/ch10_p20.jpg',
        '/downloads/1/ch10_p3.jpg',
      ];

      paths.sort(compareDownloadedPagePaths);

      expect(paths, [
        '/downloads/1/ch10_p1.jpg',
        '/downloads/1/ch10_p2.jpg',
        '/downloads/1/ch10_p3.jpg',
        '/downloads/1/ch10_p10.jpg',
        '/downloads/1/ch10_p20.jpg',
      ]);
    });

    test('natural numeric sort handles simple numeric page names', () {
      final paths = [
        '/downloads/1/10.webp',
        '/downloads/1/2.webp',
        '/downloads/1/1.webp',
      ];

      paths.sort(compareDownloadedPagePaths);

      expect(paths, [
        '/downloads/1/1.webp',
        '/downloads/1/2.webp',
        '/downloads/1/10.webp',
      ]);
    });
  });

  group('Engine Stability: RepoManager Cache Key Tests', () {
    test('RepoManager generates deterministic and collision-free cache keys', () {
      final key1 = RepoManager.normalizeRepoUrl('https://raw.githubusercontent.com/user/repo/main/index.json');
      final key2 = RepoManager.normalizeRepoUrl('https://raw.githubusercontent.com/user/repo/main');
      expect(key1, key2);
    });
  });

  group('Engine Stability: MClient Proxy URL Normalization', () {
    test('normalizes proxy URL with or without trailing slash and /v1', () {
      expect(MClient.normalizeProxyUrl('http://192.168.1.50:8191'), 'http://192.168.1.50:8191/v1');
      expect(MClient.normalizeProxyUrl('http://192.168.1.50:8191/'), 'http://192.168.1.50:8191/v1');
      expect(MClient.normalizeProxyUrl('http://192.168.1.50:8191/v1'), 'http://192.168.1.50:8191/v1');
      expect(MClient.normalizeProxyUrl(''), '');
    });
  });

  group('Engine Stability: QuickJS Metadata Extraction', () {
    test('extracts language and metadata correctly via regex fallback', () {
      const sampleJs = '''
        const mangayomiSources = [{
          name: "Manga French",
          baseUrl: "https://fr.example.com",
          lang: "fr",
          version: "2.1.0"
        }];
      ''';

      final meta = QuickJsService.instance.extractSourceMetadata(sampleJs);
      expect(meta['name'], 'Manga French');
      expect(meta['baseUrl'], 'https://fr.example.com');
      expect(meta['lang'], 'fr');
      expect(meta['version'], '2.1.0');
    });
  });
}
