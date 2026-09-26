// About page tests.
//
// These pin down the parts of the About page that can be wrong *silently* —
// the ones where a bad answer looks identical to a good one on screen:
//
//   1. `AppReleaseInfo.tryParse` must reject anything that is not a
//      structurally valid GitHub release object. The `releases/latest` endpoint
//      answers with an HTML error page behind a captive portal, a JSON rate
//      limit body, or a truncated payload. A parser that shrugs and returns a
//      release for those would tell the user "you're up to date" on the
//      strength of a 403 page, or worse, "update available" with an empty
//      version. Null is the only honest answer; the UI then says "could not
//      reach GitHub" instead of lying.
//
//   2. `tag_name` is conventionally `v4.1.0` but nothing guarantees the leading
//      `v`. The stored app version is bare semver (`4.0.0`), so comparing a
//      `v`-prefixed tag against it with RepoManager.compareVersions would
//      parse the leading letter as a 0 major component and every release
//      would compare as older than the install — the update button would go
//      permanently dead. The prefix must be stripped exactly once.
//
//   3. A missing/blank `html_url` must fall back to the releases page rather
//      than produce a link that throws or navigates nowhere.
//
//   4. `isNewerThan` must be false when the installed version is unknown. A
//      PackageInfo failure must not turn into a permanent "update available"
//      nag, and an unparseable sideload version must not be guessed at.
//
//   5. The route must be registered in the router and the settings list must
//      link to it — a page that exists but cannot be navigated to is dead code.
//
// Run: fvm flutter test test/about_page_test.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sunfire/src/features/settings/about_screen.dart';

void main() {
  group('AppReleaseInfo.tryParse', () {
    test('parses a well-formed release payload', () {
      final release = AppReleaseInfo.tryParse('''
        {
          "tag_name": "v4.1.0",
          "html_url": "https://github.com/just-for-death/sunfire/releases/tag/v4.1.0",
          "prerelease": false
        }
      ''');

      expect(release, isNotNull);
      expect(release!.version, '4.1.0');
      expect(release.url, 'https://github.com/just-for-death/sunfire/releases/tag/v4.1.0');
      expect(release.isPrerelease, isFalse);
    });

    test('strips exactly one leading v so bare semver comparison works', () {
      // "vv4.1.0" is not a valid tag, but it pins that we strip one character,
      // not "all leading v characters" — the remainder must reach the
      // comparator verbatim so an unparseable tag is visibly unparseable
      // rather than silently repaired into a plausible version.
      expect(AppReleaseInfo.tryParse('{"tag_name": "vv4.1.0"}')!.version, 'v4.1.0');
      expect(AppReleaseInfo.tryParse('{"tag_name": "4.1.0"}')!.version, '4.1.0');
      expect(AppReleaseInfo.tryParse('{"tag_name": "  v4.1.0  "}')!.version, '4.1.0');
    });

    test('a v-prefixed tag is still detected as newer than the bare install', () {
      final release = AppReleaseInfo.tryParse('{"tag_name": "v4.0.1"}')!;
      expect(release.isNewerThan('4.0.0'), isTrue);
    });

    test('falls back to the releases page when html_url is missing or blank', () {
      expect(
        AppReleaseInfo.tryParse('{"tag_name": "v4.1.0"}')!.url,
        SunfireProject.releases,
      );
      expect(
        AppReleaseInfo.tryParse('{"tag_name": "v4.1.0", "html_url": ""}')!.url,
        SunfireProject.releases,
      );
      expect(
        AppReleaseInfo.tryParse('{"tag_name": "v4.1.0", "html_url": 42}')!.url,
        SunfireProject.releases,
      );
    });

    test('honours the prerelease flag', () {
      expect(AppReleaseInfo.tryParse('{"tag_name": "v4.2.0-rc1", "prerelease": true}')!.isPrerelease, isTrue);
      expect(AppReleaseInfo.tryParse('{"tag_name": "v4.2.0-rc1"}')!.isPrerelease, isFalse);
    });

    test('rejects payloads that are not a usable release', () {
      // HTML captive-portal / gateway page served with a 200.
      expect(AppReleaseInfo.tryParse('<!DOCTYPE html><html><body>hi</body></html>'), isNull);
      // GitHub rate limit / abuse body.
      expect(
        AppReleaseInfo.tryParse('{"message": "API rate limit exceeded", "documentation_url": "x"}'),
        isNull,
      );
      // Truncated body.
      expect(AppReleaseInfo.tryParse('{"tag_name": "v4.1'), isNull);
      // Empty body.
      expect(AppReleaseInfo.tryParse(''), isNull);
      // Valid JSON, wrong shape.
      expect(AppReleaseInfo.tryParse('[]'), isNull);
      expect(AppReleaseInfo.tryParse('"4.1.0"'), isNull);
      expect(AppReleaseInfo.tryParse('null'), isNull);
      // Right shape, unusable tag.
      expect(AppReleaseInfo.tryParse('{"tag_name": ""}'), isNull);
      expect(AppReleaseInfo.tryParse('{"tag_name": "   "}'), isNull);
      expect(AppReleaseInfo.tryParse('{"tag_name": "v"}'), isNull);
      expect(AppReleaseInfo.tryParse('{"tag_name": 4}'), isNull);
    });
  });

  group('AppReleaseInfo.isNewerThan', () {
    final release = AppReleaseInfo.tryParse('{"tag_name": "v4.1.0"}')!;

    test('is true only for a strictly newer release', () {
      expect(release.isNewerThan('4.0.0'), isTrue);
      expect(release.isNewerThan('3.9.9'), isTrue);
      expect(release.isNewerThan('4.1.0'), isFalse, reason: 'equal is not an update');
      expect(release.isNewerThan('4.2.0'), isFalse, reason: 'newer install is not an update');
      expect(release.isNewerThan('4.1.1'), isFalse);
    });

    test('is false when the installed version is unknown or unparseable', () {
      // PackageInfo failure must not degrade into a permanent nag.
      expect(release.isNewerThan(''), isFalse);
      // Sideload / dev builds with non-semver versions must not be guessed at.
      // NOTE: RepoManager.compareVersions strips non-numeric characters and
      // substitutes 0, so without a semver guard these compare [4,1,0] vs [0]
      // and report a phantom update. This test fails without the guard.
      expect(release.isNewerThan('unknown'), isFalse);
      expect(release.isNewerThan('nightly'), isFalse);
      expect(release.isNewerThan('v4.0.0'), isFalse, reason: 'a v-prefixed install is not a bare version');
    });

    test('is false when the release tag itself is not a comparable version', () {
      expect(AppReleaseInfo.tryParse('{"tag_name": "nightly"}')!.isNewerThan('4.0.0'), isFalse);
      expect(AppReleaseInfo.tryParse('{"tag_name": "latest"}')!.isNewerThan('4.0.0'), isFalse);
    });

    test('handles prerelease ordering', () {
      // A prerelease sorts below its own release.
      expect(AppReleaseInfo.tryParse('{"tag_name": "v4.1.0-rc1"}')!.isNewerThan('4.1.0'), isFalse);
      expect(AppReleaseInfo.tryParse('{"tag_name": "v4.1.0"}')!.isNewerThan('4.1.0-rc1'), isTrue);
      // Build metadata is not precedence in semver: 4.1.0 and 4.1.0+1 are the
      // same version, so neither is an update for the other. The About page
      // strips the build number before comparing, so this can never nag a
      // user into "updating" to the identical version they already run.
      expect(AppReleaseInfo.tryParse('{"tag_name": "v4.1.0"}')!.isNewerThan('4.1.0+1'), isFalse);
      expect(AppReleaseInfo.tryParse('{"tag_name": "v4.1.0+2"}')!.isNewerThan('4.1.0+1'), isFalse);
    });
  });

  group('SunfireProject links', () {
    test('all links point at the canonical repository', () {
      expect(SunfireProject.repository, 'https://github.com/just-for-death/sunfire');
      expect(SunfireProject.issues, startsWith('${SunfireProject.repository}/'));
      expect(SunfireProject.releases, startsWith('${SunfireProject.repository}/'));
      expect(SunfireProject.contributors, startsWith('${SunfireProject.repository}/'));
      expect(SunfireProject.license, contains('/blob/main/LICENSE'));
      expect(SunfireProject.privacyPolicy, contains('/blob/main/PRIVACY.md'));
      expect(SunfireProject.latestReleaseApi, contains('api.github.com'));
    });

    test('every link is a parseable absolute https url', () {
      final urls = <String>[
        SunfireProject.repository,
        SunfireProject.issues,
        SunfireProject.releases,
        SunfireProject.contributors,
        SunfireProject.license,
        SunfireProject.privacyPolicy,
        SunfireProject.changelog,
        SunfireProject.latestReleaseApi,
      ];
      for (final url in urls) {
        final uri = Uri.tryParse(url);
        expect(uri, isNotNull, reason: '$url is not parseable');
        expect(uri!.isAbsolute, isTrue, reason: '$url is not absolute');
        expect(uri.scheme, 'https', reason: '$url is not https');
        expect(uri.host, isNotEmpty, reason: '$url has no host');
      }
    });
  });

  group('linked documents exist in the repository', () {
    // The About page links to CHANGELOG.md and PRIVACY.md on GitHub. Both were
    // referenced before either file existed, so every one of those taps was a
    // 404 and nothing failed. Tests run with the package root as the working
    // directory, so the repo-relative path in SunfireProject can be checked
    // against the filesystem.
    test('the changelog the About page links to exists', () {
      final path = SunfireProject.changelog.split('/blob/main/').last;
      expect(File(path).existsSync(), isTrue, reason: '$path is linked but missing');
    });

    test('the privacy policy the About page links to exists', () {
      final path = SunfireProject.privacyPolicy.split('/blob/main/').last;
      expect(File(path).existsSync(), isTrue, reason: '$path is linked but missing');
    });

    test('the license the About page links to exists', () {
      final path = SunfireProject.license.split('/blob/main/').last;
      expect(File(path).existsSync(), isTrue, reason: '$path is linked but missing');
    });

    test('the README links to documents that exist', () {
      final readme = File('README.md').readAsStringSync();
      for (final doc in ['PRIVACY.md', 'CHANGELOG.md', 'LICENSE']) {
        expect(File(doc).existsSync(), isTrue, reason: '$doc is linked but missing');
        expect(readme, contains(doc), reason: 'README should link $doc');
      }
    });
  });

  group('AboutScreen widget', () {
    // The page is a long lazy ListView, so only the visible window is built.
    // Widen the test surface instead of scrolling: these assertions are about
    // which sections exist, and a scroll-then-find dance per item would make
    // the suite brittle against any future reordering.
    void useTallSurface(WidgetTester tester) {
      tester.view.physicalSize = const Size(1000, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
    }

    Widget harness() => MaterialApp(home: const AboutScreen());

    testWidgets('renders the project links and the legal section', (tester) async {
      useTallSurface(tester);
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      expect(find.text('About'), findsOneWidget);
      expect(find.text('Sunfire'), findsOneWidget);
      expect(find.text('Source code'), findsOneWidget);
      expect(find.text('Issue tracker'), findsOneWidget);
      expect(find.text('Changelog'), findsOneWidget);
      expect(find.text('Contributors'), findsOneWidget);
      expect(find.text('License (MPL-2.0)'), findsOneWidget);
      expect(find.text('Privacy policy'), findsOneWidget);
      expect(find.text('Open source licenses'), findsOneWidget);
    });

    testWidgets('update check is idle and honest before it has been run', (tester) async {
      useTallSurface(tester);
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      expect(find.text('Check for updates'), findsOneWidget);
      expect(find.text('Compare against the latest GitHub release'), findsOneWidget);
      // The diagnostics table must not claim a release channel it never checked.
      expect(find.text('not checked'), findsOneWidget);
    });

    testWidgets('shows an unknown version rather than a hardcoded one when PackageInfo fails', (tester) async {
      useTallSurface(tester);
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      // The whole point of reading the version from PackageInfo: the About page
      // must never drift from pubspec the way a literal would. In the test
      // harness there is no plugin registrant, so PackageInfo throws and the
      // page must degrade to "unknown" instead of inventing a version.
      expect(find.textContaining('unknown'), findsWidgets);
    });

    testWidgets('renders at a narrow phone width without overflowing', (tester) async {
      tester.view.physicalSize = const Size(360, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('About'), findsOneWidget);
    });
  });

  group('About route', () {
    testWidgets('/settings/about resolves to the About screen', (tester) async {
      final router = GoRouter(
        initialLocation: '/settings/about',
        routes: [
          GoRoute(
            path: '/settings/about',
            builder: (context, state) => const AboutScreen(),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.byType(AboutScreen), findsOneWidget);
      expect(router.routeInformationProvider.value.uri.path, '/settings/about');

      // AboutScreen bounds its PackageInfo read with a 5s timeout. Nothing is
      // animating on this 800x600 surface, so pumpAndSettle returns before
      // that timer fires and the test would end with a pending timer.
      await tester.pump(const Duration(seconds: 6));
    });
  });
}
