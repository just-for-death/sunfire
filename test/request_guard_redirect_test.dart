import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sunfire/src/core/engine/javascript/request_guard.dart';

void main() {
  group('sendWithGuardedRedirects', () {
    test('refuses a public URL that redirects into loopback or the LAN', () async {
      for (final target in ['http://127.0.0.1:8191/', 'http://192.168.1.1/admin', 'http://169.254.169.254/latest']) {
        final hits = <String>[];
        final client = MockClient((req) async {
          hits.add(req.url.toString());
          if (req.url.host == 'attacker.com') return http.Response('', 302, headers: {'location': target});
          return http.Response('SECRET', 200);
        });
        final result = await sendWithGuardedRedirects(client, 'GET', Uri.parse('https://attacker.com/r'), {}, null);
        expect(result.response, isNull, reason: target);
        expect(result.blocked, contains('redirect to'), reason: target);
        expect(hits, ['https://attacker.com/r'], reason: 'the private hop must never be requested');
      }
    });

    test('follows public redirects, resolving relative locations', () async {
      final client = MockClient((req) async {
        if (req.url.path == '/a') return http.Response('', 301, headers: {'location': '/b'});
        return http.Response('ok:${req.url}', 200);
      });
      final result = await sendWithGuardedRedirects(client, 'GET', Uri.parse('https://site.com/a'), {}, null);
      expect(result.blocked, isNull);
      expect(result.response!.body, 'ok:https://site.com/b');
    });

    test('303 turns POST into a body-less GET; cross-host hops drop credentials', () async {
      final seen = <http.BaseRequest>[];
      final client = MockClient((req) async {
        seen.add(req);
        if (req.url.host == 'site.com') return http.Response('', 303, headers: {'location': 'https://cdn.other.com/x'});
        return http.Response('done', 200);
      });
      final result = await sendWithGuardedRedirects(
        client,
        'POST',
        Uri.parse('https://site.com/login'),
        {'Authorization': 'Bearer t', 'Cookie': 'a=b', 'X-Keep': '1'},
        {'q': 'v'},
      );
      expect(result.response!.body, 'done');
      expect(seen.last.method, 'GET');
      expect((seen.last as http.Request).body, isEmpty);
      expect(seen.last.headers.keys.map((k) => k.toLowerCase()), isNot(contains('authorization')));
      expect(seen.last.headers.keys.map((k) => k.toLowerCase()), isNot(contains('cookie')));
      expect(seen.last.headers['X-Keep'], '1');
    });
  });
}
