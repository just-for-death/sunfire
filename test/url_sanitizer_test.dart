// UIX-17: sanitizeUrlForLog strips credentials/query/fragment with no `?#` junk.
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/utils/url_sanitizer.dart';

void main() {
  test('credentials, query and fragment are removed cleanly', () {
    expect(sanitizeUrlForLog('https://u:p@h.com:8443/a/b?t=1#f'), 'https://h.com:8443/a/b');
  });

  test('no dangling ?# for plain URLs', () {
    expect(sanitizeUrlForLog('https://host/a/b'), 'https://host/a/b');
    expect(sanitizeUrlForLog('https://host/a/b?'), 'https://host/a/b');
    expect(sanitizeUrlForLog('http://host:8080/x#frag'), 'http://host:8080/x');
  });

  test('relative input keeps its path and loses the query', () {
    expect(sanitizeUrlForLog('/api/graphql?token=abc'), '/api/graphql');
  });

  test('invalid input falls back to plain truncation', () {
    const bad = 'http://[::1';
    expect(sanitizeUrlForLog(bad), bad);
    final longBad = 'http://[${'x' * 300}';
    expect(sanitizeUrlForLog(longBad, maxLength: 20), '${longBad.substring(0, 20)}...');
  });

  test('length cap applies to the sanitized URL', () {
    final out = sanitizeUrlForLog('https://h.com/${'a' * 500}?secret=1', maxLength: 50);
    expect(out.length, 53);
    expect(out.endsWith('...'), isTrue);
    expect(out.contains('secret'), isFalse);
  });

  test('empty stays empty', () => expect(sanitizeUrlForLog(''), ''));
}
