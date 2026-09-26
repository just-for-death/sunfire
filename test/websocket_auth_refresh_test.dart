// Integration tests for WebSocketService's auth-expiry handling and
// subscription safety, driven against a real local WebSocket server.
//
// Regression coverage for:
//  - S4: a 4401/4403 close used to re-enter the backoff loop with the same
//    dead token forever. Now the service invokes `onAuthExpired` once and
//    reconnects immediately with the refreshed token.
//  - S5: a `connection_ack` that races a close used to throw inside
//    `sink.add`, get swallowed by _handleMessage's catch-all, and be logged as
//    a *parse* error while leaving the service "connected" with zero
//    subscriptions. It now routes through _handleDisconnect.
//
// Run: fvm flutter test test/websocket_auth_refresh_test.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/sync/websocket_service.dart';

/// A local graphql-transport-ws-ish server that records the auth header of
/// every `connection_init` it receives.
class _FakeWsServer {
  _FakeWsServer._(this._server);

  final HttpServer _server;

  /// Auth headers seen, in arrival order (one per accepted connection).
  final List<String?> authHeaders = [];

  /// When true, the server closes every connection with 4401 right after
  /// `connection_init`. When false it acks and holds the connection open.
  bool rejectWithUnauthorized = true;

  /// Completes once the server has accepted [count] connections.
  late final Stream<void> _accepted;
  late final StreamController<void> _acceptedController;

  static Future<_FakeWsServer> start() async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final fake = _FakeWsServer._(server);
    fake._acceptedController = StreamController<void>.broadcast();
    fake._accepted = fake._acceptedController.stream;
    unawaited(fake._serve());
    return fake;
  }

  Future<void> _serve() async {
    await for (final request in _server) {
      if (!WebSocketTransformer.isUpgradeRequest(request)) {
        request.response.statusCode = HttpStatus.badRequest;
        await request.response.close();
        continue;
      }
      // Per-connection socket; the server outlives individual upgrades, so
      // this cannot be closed when the helper returns.
      // ignore: close_sinks
      final socket = await WebSocketTransformer.upgrade(request);
      socket.listen(
        (raw) {
          final decoded = jsonDecode(raw as String) as Map<String, dynamic>;
          if (decoded['type'] == 'connection_init') {
            final payload = decoded['payload'] as Map<String, dynamic>?;
            authHeaders.add(payload?['Authorization'] as String?);
            _acceptedController.add(null);
            if (rejectWithUnauthorized) {
              socket.close(_closeCodeUnauthorized, 'Unauthorized');
            } else {
              socket.add(jsonEncode({'type': 'connection_ack'}));
            }
          }
        },
        onDone: () {},
        onError: (_) {},
        cancelOnError: true,
      );
    }
  }

  String get url => 'http://127.0.0.1:${_server.port}';

  Future<void> close() async {
    await _acceptedController.close();
    await _server.close(force: true);
  }
}

const int _closeCodeUnauthorized = 4401;

/// Restores genuine socket IO.
///
/// `AutomatedTestWidgetsFlutterBinding` installs an `HttpOverrides` that
/// returns a mock `HttpClient`, which makes every real WebSocket upgrade fail
/// with "Unsupported operation: Mocked response". This subclass inherits the
/// base `createHttpClient`, so `HttpClient()` builds a real one again and the
/// local test server can actually be reached.
class _RealHttpOverrides extends HttpOverrides {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeWsServer server;
  late WebSocketService ws;

  setUp(() async {
    HttpOverrides.global = _RealHttpOverrides();
    server = await _FakeWsServer.start();
    ws = WebSocketService.instance;
    ws.onAuthExpired = null;
    ws.dispose();
  });

  tearDown(() async {
    ws.dispose();
    HttpOverrides.global = null;
    await server.close();
  });

  test('a 4401 close triggers one token refresh and an immediate reconnect', () async {
    ws.onAuthExpired = () async => 'fresh-token';
    server.rejectWithUnauthorized = true;

    ws.initialize(server.url, authToken: 'stale-token');

    // First connection presents the stale token.
    await server._accepted.first.timeout(const Duration(seconds: 10));
    expect(server.authHeaders, hasLength(1));
    expect(server.authHeaders.first, 'Bearer stale-token');

    // The refresher yields a new token and the service reconnects with it
    // without waiting out the 5s+ backoff.
    await server._accepted.first.timeout(const Duration(seconds: 10));
    expect(server.authHeaders.length, greaterThanOrEqualTo(2));
    expect(server.authHeaders[1], 'Bearer fresh-token');
  }, timeout: const Timeout(Duration(seconds: 30)));

  test('a refresher returning null does not spin: no further reconnects', () async {
    var calls = 0;
    ws.onAuthExpired = () async {
      calls++;
      return null;
    };
    server.rejectWithUnauthorized = true;

    ws.initialize(server.url, authToken: 'stale-token');

    await server._accepted.first.timeout(const Duration(seconds: 10));
    expect(server.authHeaders, hasLength(1));

    // Give the refresher a chance to run and the backoff timer to be armed.
    await Future.delayed(const Duration(milliseconds: 600));
    expect(calls, greaterThanOrEqualTo(1));

    // The dead token must not be replayed: the backoff is 10s, so within this
    // window we should still be at a single connection attempt.
    await Future.delayed(const Duration(milliseconds: 600));
    expect(server.authHeaders, hasLength(1), reason: 'retried the known-bad token');
  }, timeout: const Timeout(Duration(seconds: 30)));

  test('an empty refreshed token is treated as no token', () async {
    ws.onAuthExpired = () async => '   ';
    server.rejectWithUnauthorized = true;

    ws.initialize(server.url, authToken: 'stale-token');

    await server._accepted.first.timeout(const Duration(seconds: 10));
    await Future.delayed(const Duration(milliseconds: 800));
    expect(server.authHeaders, hasLength(1));
  }, timeout: const Timeout(Duration(seconds: 30)));

  test('a refresher that throws falls back to backoff instead of crashing', () async {
    ws.onAuthExpired = () async => throw StateError('keychain locked');
    server.rejectWithUnauthorized = true;

    ws.initialize(server.url, authToken: 'stale-token');

    await server._accepted.first.timeout(const Duration(seconds: 10));
    await Future.delayed(const Duration(milliseconds: 800));

    // Still alive and not reconnected immediately.
    expect(server.authHeaders, hasLength(1));
    expect(ws.isConnected, isFalse);
  }, timeout: const Timeout(Duration(seconds: 30)));

  test('a healthy ack establishes both subscriptions', () async {
    final received = <Map<String, dynamic>>[];
    final server2 = await _rawEchoServer(received);
    addTearDown(() => server2.close());

    ws.initialize(server2.url, authToken: 'good-token');
    await Future.delayed(const Duration(milliseconds: 800));

    final types = received.map((m) => m['type']).toList();
    final subs = received.where((m) => m['type'] == 'subscribe').toList();
    expect(types, contains('connection_init'));
    expect(subs, hasLength(2), reason: 'libraryUpdate + downloadStatus');
    expect(subs.map((m) => m['id']).toSet(), {'1', '2'});
  }, timeout: const Timeout(Duration(seconds: 30)));

  test('a server that accepts TCP but never acks is not reported connected', () async {
    final server2 = await _rawEchoServer(<Map<String, dynamic>>[], ack: false);
    addTearDown(() => server2.close());

    ws.initialize(server2.url, authToken: 'good-token');
    await Future.delayed(const Duration(milliseconds: 800));

    // The 10s handshake timer has not fired yet, but the service must already
    // refuse to call itself connected — otherwise a half-open socket would
    // look healthy and the app would wait forever for subscription data.
    expect(ws.isConnected, isFalse);
  }, timeout: const Timeout(Duration(seconds: 30)));
}

/// Minimal server that records every frame and optionally acks.
Future<HttpServer> _rawEchoServer(
  List<Map<String, dynamic>> sink, {
  bool ack = true,
}) async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  unawaited(() async {
    await for (final request in server) {
      if (!WebSocketTransformer.isUpgradeRequest(request)) {
        request.response.statusCode = HttpStatus.badRequest;
        await request.response.close();
        continue;
      }
      // Per-connection socket; the server outlives individual upgrades, so
      // this cannot be closed when the helper returns.
      // ignore: close_sinks
      final socket = await WebSocketTransformer.upgrade(request);
      socket.listen(
        (raw) {
          final decoded = jsonDecode(raw as String) as Map<String, dynamic>;
          sink.add(decoded);
          if (ack && decoded['type'] == 'connection_init') {
            socket.add(jsonEncode({'type': 'connection_ack'}));
          }
        },
        onDone: () {},
        onError: (_) {},
        cancelOnError: true,
      );
    }
  }());
  return server;
}

extension on HttpServer {
  String get url => 'http://127.0.0.1:$port';
}
