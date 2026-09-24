import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/db/models/chapter.dart';
import 'package:sunfire/src/core/engine/javascript/dom_extensions.dart';
import 'package:sunfire/src/core/services/safe_curl.dart';
import 'package:sunfire/src/features/reader/reader_chapter_navigation.dart';

Chapter ch({int id = 0, int serverId = 0, String name = '', String url = ''}) => Chapter()
  ..id = id
  ..serverId = serverId
  ..name = name
  ..url = url;

void main() {
  group('findSiblingChapterIndex with duplicate names', () {
    final sorted = [
      ch(id: 1, serverId: 10, name: 'Chapter 10', url: '/a'),
      ch(id: 2, serverId: 11, name: 'Chapter 10', url: '/b'),
      ch(id: 3, serverId: 12, name: 'Chapter 11', url: '/c'),
    ];

    test('serverId beats an earlier name match', () {
      expect(findSiblingChapterIndex(sorted, ch(serverId: 11, name: 'Chapter 10')), 1);
    });

    test('url beats an earlier name match', () {
      expect(findSiblingChapterIndex(sorted, ch(url: '/b', name: 'Chapter 10')), 1);
    });

    test('ambiguous name-only lookup is not guessed', () {
      expect(findSiblingChapterIndex(sorted, ch(name: 'Chapter 10')), -1);
    });

    test('unique name-only lookup still works', () {
      expect(findSiblingChapterIndex(sorted, ch(name: 'chapter 11')), 2);
    });
  });

  group('splitTopLevelSelectors', () {
    test('splits plain lists', () {
      expect(splitTopLevelSelectors('a.x, div > p ,span'), ['a.x', 'div > p', 'span']);
    });

    test('keeps commas inside parentheses', () {
      expect(splitTopLevelSelectors('li:is(.a, .b), p'), ['li:is(.a, .b)', 'p']);
      expect(splitTopLevelSelectors('div:has(a, img)'), ['div:has(a, img)']);
    });

    test('keeps commas inside attribute values and quotes', () {
      expect(splitTopLevelSelectors('a[title="x, y"], b'), ['a[title="x, y"]', 'b']);
      expect(splitTopLevelSelectors("a[title='x, y']"), ["a[title='x, y']"]);
    });

    test('ignores empty parts', () {
      expect(splitTopLevelSelectors(',a,,b,'), ['a', 'b']);
    });
  });

  group('buildCurlArgs', () {
    test('puts -- before the URL and restricts protocols', () {
      final args = buildCurlArgs(url: 'https://example.com/a.jpg', maxTimeSeconds: 10)!;
      expect(args[args.length - 2], '--');
      expect(args.last, 'https://example.com/a.jpg');
      expect(args, containsAllInOrder(['--proto', '=http,https']));
    });

    test('rejects option-looking, non-http and multi-line URLs', () {
      expect(buildCurlArgs(url: '-o/tmp/x', maxTimeSeconds: 5), isNull);
      expect(buildCurlArgs(url: 'file:///etc/passwd', maxTimeSeconds: 5), isNull);
      expect(buildCurlArgs(url: 'https://a.com/\nx', maxTimeSeconds: 5), isNull);
    });

    test('drops header entries with line breaks and skipped names', () {
      final args = buildCurlArgs(
        url: 'https://a.com/x',
        maxTimeSeconds: 5,
        headers: {'Referer': 'https://a.com', 'X-Bad': 'a\r\nInjected: 1', 'Cookie': 'c=1'},
        skipHeaders: {'cookie'},
      )!;
      final joined = args.join('|');
      expect(joined, contains('Referer: https://a.com'));
      expect(joined, isNot(contains('Injected')));
      expect(joined, isNot(contains('Cookie')));
    });
  });
}
