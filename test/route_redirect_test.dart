import 'package:catalyst/src/routes/route_redirect.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('redirectPathForUri rejects non-numeric manga id', () {
    expect(
      redirectPathForUri(Uri.parse('/manga/foo/chapter/12')),
      '/manga/0/chapter/0',
    );
  });

  test('redirectPathForUri rejects non-numeric chapter id', () {
    expect(
      redirectPathForUri(Uri.parse('/manga/5/chapter/bar')),
      '/manga/0/chapter/0',
    );
  });

  test('redirectPathForUri allows valid reader path', () {
    expect(
      redirectPathForUri(Uri.parse('/manga/5/chapter/12')),
      isNull,
    );
  });

  test('redirectPathForUri rejects invalid library category', () {
    expect(
      redirectPathForUri(Uri.parse('/library/abc')),
      '/library/0',
    );
  });

  test('deepLinkPathFromUri maps catalyst scheme to app path', () {
    expect(
      deepLinkPathFromUri(Uri.parse('catalyst://manga/5/chapter/12')),
      '/manga/5/chapter/12',
    );
  });

  test('deepLinkPathFromUri maps library deep link', () {
    expect(
      deepLinkPathFromUri(Uri.parse('catalyst://library/3')),
      '/library/3',
    );
  });
}
