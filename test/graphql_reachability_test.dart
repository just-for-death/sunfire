// Reachability-vs-credentials separation in GraphQLClientService.
//
// ROOT CAUSE (the bug this file pins down):
//
// `checkServerReachable` treated a 401/403 as "server unreachable":
//
//     if (res.statusCode == 401 || res.statusCode == 403) {
//       // Server is up but rejects our credentials ...
//       _lastReachableStatus = false;
//       notifyAuthError();
//     }
//
// The comment states the contradiction outright — the server is *up* — and it
// contradicts `isKnownUnreachable`'s own documented contract, which promises to
// "tell 'the network dropped' apart from 'the server understood and rejected the
// request' (GraphQL/4xx errors leave the status reachable)". A 401 is a 4xx from
// a server that answered, so it must leave the status reachable.
//
// Two concrete costs of the conflation:
//
//   1. A 15-second request blackout that could not self-heal. `query()` has a
//      fast-fail on `!_lastReachableStatus`, and `clearAuthError()` sits *past*
//      that branch. So a 401 probe latched "unreachable" and every subsequent
//      request returned null WITHOUT being sent — including the one that would
//      have proven the new credentials work. Only `initialize()` could clear it.
//
//   2. `isKnownUnreachable` became unusable as a discriminator, forcing a
//      defensive `&& !hasAuthError` band-aid into sync_engine's dispatch
//      failure classification. With the conflation fixed that band-aid turns
//      into a live misclassification: a real network drop arriving while a stale
//      auth error is latched gets read as permanent and burns the record's
//      retry budget on something that would have succeeded next attempt.
//
// The fix keeps the two questions separate: reachability is transport-only, and
// the private `_isServerUsable` (reachable AND credentials accepted) is what the
// sync gates consult.
//
// WHAT IS PINNED HERE, against a real local HTTP server:
//   1. A 401 leaves the server REACHABLE.                     (fails pre-fix)
//   2. A 401 still reports the server as not usable to sync. (unchanged)
//   3. A 401 does not blackhole the next 15s of requests.    (fails pre-fix)
//   4. A 403 behaves identically to a 401.                   (fails pre-fix)
//   5. A dead port is still unreachable, and still not usable. (unchanged)
//   6. A healthy 200 is still both reachable and usable.      (unchanged)
//
// Run: fvm flutter test test/graphql_reachability_test.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/sync/graphql_client_service.dart';

/// Restores genuine socket IO.
///
/// `AutomatedTestWidgetsFlutterBinding` installs an `HttpOverrides` whose
/// `createHttpClient` returns a mock, which would make every request here fail
/// for reasons unrelated to what is under test.
class _RealHttpOverrides extends HttpOverrides {}

/// A local server whose response to the probe is scriptable.
class _StubGraphQLServer {
  _StubGraphQLServer._(this._server);

  final HttpServer _server;

  /// Status returned for every request while this is set.
  int status = 200;

  /// Status returned for the reachability probe only.
  ///
  /// Lets a test produce a 401 from the probe and a 200 from a subsequent
  /// query, which is exactly the "credentials were fixed" recovery.
  int? probeStatusOverride;

  /// Every request path the client asked for, in order. Proves whether a
  /// request was actually SENT or swallowed by the fast-fail.
  final List<String> requests = [];

  static Future<_StubGraphQLServer> start() async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final fake = _StubGraphQLServer._(server);
    unawaited(fake._serve());
    return fake;
  }

  String get url => 'http://127.0.0.1:${_server.port}';

  Future<void> _serve() async {
    await for (final request in _server) {
      requests.add(request.uri.path);
      final isProbe = request.uri.path == '/api/graphql' && _isProbeBody(request);
      final code = isProbe ? (probeStatusOverride ?? status) : status;

      final body = code == 401 || code == 403
          ? jsonEncode({'errors': [{'message': 'Invalid credentials'}]})
          : jsonEncode({'data': {'aboutServer': {'version': '1.0.0'}}});

      request.response
        ..statusCode = code
        ..headers.contentType = ContentType.json
        ..write(body);
      await request.response.close();
    }
  }

  /// The probe is the only request the client sends as raw JSON with
  /// `aboutServer` in the body.
  bool _isProbeBody(HttpRequest request) {
    // The body has already been consumed by Dio on a real socket in some
    // cases; fall back to matching on the JSON `query` string via headers is
    // unreliable, so treat the FIRST request as the probe. Every test here
    // issues at most one probe before a query.
    return requests.length == 1;
  }

  Future<void> close() async {
    await _server.close(force: true);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _StubGraphQLServer server;
  late GraphQLClientService gql;

  setUp(() async {
    HttpOverrides.global = _RealHttpOverrides();
    server = await _StubGraphQLServer.start();
    gql = GraphQLClientService.instance;
  });

  tearDown(() async {
    HttpOverrides.global = null;
    await server.close();
  });

  group('a server that answers 401/403 is REACHABLE, just not usable', () {
    for (final code in [401, 403]) {
      test('$code does not mark the server unreachable', () async {
        // THE BUG. Pre-fix this was true, making `isKnownUnreachable` unable to
        // do the one job its contract promises: distinguish a dropped connection
        // from a server that understood us and refused.
        gql.initialize(server.url);
        server.status = code;

        final usable = await gql.checkServerReachable(force: true);

        // Asserted FIRST on purpose. Pre-fix `notifyAuthError()` sat in a branch
        // that could never execute -- Dio throws badResponse for any non-2xx, so
        // the status check never saw a 401 and the bare `catch (_)` swallowed it
        // as if it were connection-refused. Measured on the vulnerable base:
        //   usable=false  hasAuthError=false  isKnownUnreachable=true
        // i.e. the probe reported "server down" and stayed completely silent
        // about the actual problem, so the "Server rejected your login" prompt
        // never appeared until some unrelated request happened to 401. On a
        // cold start with a dead token the app gave the user nothing to act on.
        expect(gql.hasAuthError, isTrue,
            reason: 'a credential rejection must raise the reconnect prompt, '
                'even when it is the reachability probe that hit it');
        expect(gql.isKnownUnreachable, isFalse,
            reason: 'the server answered HTTP $code. Nothing about the transport '
                'path failed, so this must not be recorded as unreachable.');
        expect(usable, isFalse,
            reason: 'and the sync gates must still decline to fire doomed work');
      });

      test('$code does not blackhole the following 15s of requests', () async {
        // The self-heal deadlock. Pre-fix, `query()` returned null from its
        // fast-fail without sending anything, so the one request that could
        // have proven the new credentials work never left the device.
        gql.initialize(server.url);
        server.probeStatusOverride = code;

        await gql.checkServerReachable(force: true);
        final requestsAfterProbe = server.requests.length;

        // Credentials are now valid again; the very next request must go out.
        server.probeStatusOverride = null;
        server.status = 200;

        final data = await gql.query('{ aboutServer { version } }', label: 'recovery');

        expect(data, isNotNull,
            reason: 'a successful re-auth must be able to clear the auth error '
                'through an ordinary request');
        expect(gql.hasAuthError, isFalse,
            reason: 'a successful response means the credentials are good again');
        expect(server.requests.length, greaterThan(requestsAfterProbe),
            reason: 'the recovery request must actually be SENT, not swallowed '
                'by the reachability fast-fail');
      });
    }

    test('a 401 reports not-usable, so sync gates do not fire doomed work', () async {
      // Behaviour preservation: the split must not make sync start hammering a
      // server that will reject everything.
      gql.initialize(server.url);
      server.status = 401;

      expect(await gql.checkServerReachable(force: true), isFalse);

      // And the 8s probe cache must not "recover" on its own either.
      expect(await gql.checkServerReachable(), isFalse,
          reason: 'the cached answer must keep reporting unusable while auth is dead');
    });
  });

  group('genuine transport failures are still unreachable', () {
    test('a dead port is unreachable and not usable', () async {
      // Intentionally dead port (not 4567, which may be a live Suwayomi).
      gql.initialize('http://127.0.0.1:45999');

      final usable = await gql
          .checkServerReachable(force: true)
          .timeout(const Duration(seconds: 5), onTimeout: () => false);

      expect(usable, isFalse);
      expect(gql.isKnownUnreachable, isTrue,
          reason: 'a connection that never completed is exactly what this flag '
              'is for');
      expect(gql.hasAuthError, isFalse,
          reason: 'no server answered, so there is no credential signal to report');
    });

    test('a 5xx is a transport failure, not a credentials problem', () async {
      gql.initialize(server.url);
      server.status = 503;

      expect(await gql.checkServerReachable(force: true), isFalse);
      expect(gql.isKnownUnreachable, isTrue);
    });
  });

  group('a healthy server is unchanged', () {
    test('a 200 probe is both reachable and usable', () async {
      gql.initialize(server.url);
      server.status = 200;

      expect(await gql.checkServerReachable(force: true), isTrue);
      expect(gql.isKnownUnreachable, isFalse);
      expect(gql.hasAuthError, isFalse);
    });

    test('a 200 probe then a real query both go out', () async {
      gql.initialize(server.url);
      server.status = 200;

      expect(await gql.checkServerReachable(force: true), isTrue);
      final data = await gql.query('{ aboutServer { version } }', label: 'ok');

      expect(data, isNotNull);
      expect(server.requests, hasLength(2),
          reason: 'probe plus query, both actually sent');
    });
  });
}
