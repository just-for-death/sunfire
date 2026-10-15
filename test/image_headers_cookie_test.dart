import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/engine/javascript/m_client.dart';
import 'package:sunfire/src/core/engine/quickjs_service.dart';

String? _cookie(Map<String, String> h) =>
    h.entries.where((e) => e.key.toLowerCase() == 'cookie').map((e) => e.value).firstOrNull;

void main() {
  setUp(() {
    MClient.debugClearCookies();
    QuickJsService.clearHeadersCache();
  });

  test('cleared cookies are not served back from the headers cache', () async {
    const url = 'https://img.example.com/a/1.jpg';
    await MClient.setCookie(url, '', cookie: 'cf_clearance=old');
    expect(_cookie(QuickJsService.getImageHeaders(url)), 'cf_clearance=old');

    MClient.clearSessionCookies();
    expect(_cookie(QuickJsService.getImageHeaders(url)), isNull);

    await MClient.setCookie(url, '', cookie: 'cf_clearance=new');
    expect(_cookie(QuickJsService.getImageHeaders(url)), 'cf_clearance=new');
  });

  test('the readcomicsonline CDN strip also applies on a cache hit', () async {
    const url = 'https://cdn.readcomicsonline.ru/uploads/x/1.jpg';
    QuickJsService.cacheImageHeaders(url, {'Referer': 'https://readcomicsonline.ru/'});
    await MClient.setCookie(url, '', cookie: 'a=1');
    for (var i = 0; i < 2; i++) {
      final h = QuickJsService.getImageHeaders(url);
      expect(_cookie(h), isNull);
      expect(h.keys.map((k) => k.toLowerCase()), isNot(contains('referer')));
    }
  });

  test('cookie roots stop at shared hosting suffixes', () {
    expect(MClient.debugRootDomain('cdn.site.example.com'), 'example.com');
    expect(MClient.debugRootDomain('cdn.example.co.uk'), 'example.co.uk');
    expect(MClient.debugRootDomain('alice.github.io'), 'alice.github.io');
    expect(MClient.debugRootDomain('img.alice.github.io'), 'alice.github.io');
  });

  test('a cookie solved for one shared-host site is not sent to another', () async {
    await MClient.setCookie('https://alice.github.io/x', '', cookie: 's=alice');
    expect(MClient.getCookiesPref('https://bob.github.io/y'), isEmpty);
    expect(MClient.getCookiesPref('https://alice.github.io/z'), isNotEmpty);
  });
}
