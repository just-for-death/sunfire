// WebSocket liveness-watchdog tests.
//
// ROOT CAUSE (the bug this file pins down):
//
// `WebSocketService` recycled a connection when it had seen no *literal `pong`
// frame* for 75 seconds. That is the wrong liveness signal, twice over:
//
//   1. Nothing in `graphql-transport-ws` obliges a server to answer a
//      client-initiated `ping`. The protocol defines the direction "server
//      sends Ping, client must reply Pong" — it says nothing about a server
//      answering a client's Ping. A server that simply ignores client pings
//      therefore got force-disconnected every 75 seconds, forever: a fresh TCP
//      + TLS handshake and a re-send of both subscriptions roughly 1150 times
//      per day, against a socket that was never actually broken. On a metered
//      or high-latency link that is both battery and data cost, and each
//      recycle is a window where update/download events are missed.
//
//   2. Even against a server that DOES answer pings, no other inbound traffic
//      counted. A server actively streaming `libraryUpdateStatusChanged` and
//      `downloadStatusChanged` — i.e. proving it was very much alive — was
//      still declared dead, because only `pong` refreshed the timestamp.
//
// The fix records liveness on raw byte arrival in the stream listener, before
// decoding, so any frame at all proves the link is up in both directions and
// only total silence is treated as a half-open socket.
//
// WHAT IS PINNED HERE:
//   1. A server that ignores client pings but streams subscription events is
//      NOT recycled. (Fails pre-fix.)
//   2. A server that streams unparseable garbage — still proof of a live
//      socket — is NOT recycled.
//   3. A genuinely silent socket IS still recycled. (The watchdog must not have
//      been defeated by the fix.)
//   4. A server that answers pings the old way is still fine.
//
// Run: fvm flutter test test/websocket_liveness_test.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/sync/websocket_service.dart';

/// Restores genuine socket IO.
///
/// `AutomatedTestWidgetsFlutterBinding` installs an `HttpOverrides` whose
/// `createHttpClient` returns a mock, which makes every real WebSocket upgrade
/// fail with "Unsupported operation: Mocked response".
class _RealHttpOverrides extends HttpOverrides {}

/// A controllable local WebSocket server.
///
/// [behaviour] decides what the server does after acknowledging, which is what
/// distinguishes a healthy-but-quiet server from a half-open one.
enum _Behaviour {
  /// Ack, then ignore client pings forever, sending nothing else.
  silent,

  /// Ack, then ignore client pings but emit a subscription event periodically.
  /// Models a real Suwayomi server actively streaming updates.
  streamingIgnoringPings,

  /// Ack, then answer every client ping with a pong. The well-behaved case.
  answeringPings,

  /// Ack, then send frames that are not valid JSON. Still proves a live socket,
  /// but must not be mistaken for a protocol error that warrants a reconnect.
  sendingGarbage,
}

class _ScriptedServer {
  _ScriptedServer._(this._server);

  final HttpServer _server;
  final _accepted = StreamController<void>.broadcast();
  final List<WebSocket> _sockets = [];
  final List<Timer> _emitters = [];

  /// Number of `connection_init` frames seen, i.e. connection attempts.
  int connectionAttempts = 0;

  /// Every JSON frame the client sent, across all connections. Used to assert
  /// that a recycled socket re-sends its subscriptions.
  final List<Map<String, dynamic>> frames = [];

  _Behaviour behaviour = _Behaviour.silent;

  /// How often [behaviour] emits a frame, for the streaming variants.
  Duration emitEvery = const Duration(milliseconds: 200);

  static Future<_ScriptedServer> start() async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final fake = _ScriptedServer._(server);
    unawaited(fake._serve());
    return fake;
  }

  String get url => 'http://127.0.0.1:${_server.port}';

  /// Completes on the next connection attempt.
  Future<void> get nextConnection =>
      _accepted.stream.first.timeout(const Duration(seconds: 10));

  /// Writes a frame, tolerating an already-closed socket.
  ///
  /// The client tears its socket down during dispose/teardown while periodic
  /// emitters are still live, and an uncaught "StreamSink is closed" from a
  /// server-side timer would surface as a spurious failure in the test that is
  /// asserting on the *client's* behaviour.
  void _emit(WebSocket socket, Object frame) {
    try {
      socket.add(frame);
    } catch (_) {
      // Socket already gone; the client closing it is a normal outcome here.
    }
  }

  Future<void> _serve() async {
    await for (final request in _server) {
      if (!WebSocketTransformer.isUpgradeRequest(request)) {
        request.response.statusCode = HttpStatus.badRequest;
        await request.response.close();
        continue;
      }
      // Per-connection socket; the server outlives individual upgrades, so this
      // cannot be closed when the helper returns.
      // ignore: close_sinks
      final socket = await WebSocketTransformer.upgrade(request);
      _sockets.add(socket);

      socket.listen(
        (raw) {
          dynamic decoded;
          try {
            decoded = jsonDecode(raw as String);
          } catch (_) {
            return; // Not a frame we care about (e.g. our own pong).
          }
          if (decoded is! Map<String, dynamic>) return;
          frames.add(decoded);

          if (decoded['type'] == 'connection_init') {
            connectionAttempts++;
            _accepted.add(null);
            _emit(socket, jsonEncode({'type': 'connection_ack'}));
            _startEmitter(socket);
            return;
          }
          if (decoded['type'] == 'ping' && behaviour == _Behaviour.answeringPings) {
            _emit(socket, jsonEncode({'type': 'pong'}));
          }
        },
        onDone: () {},
        onError: (_) {},
        cancelOnError: true,
      );
    }
  }

  void _startEmitter(WebSocket socket) {
    switch (behaviour) {
      case _Behaviour.silent:
      case _Behaviour.answeringPings:
        return;
      case _Behaviour.streamingIgnoringPings:
        _emitters.add(Timer.periodic(emitEvery, (_) {
          // A real `next` frame carrying a library update event.
          _emit(socket, jsonEncode({
            'type': 'next',
            'id': '1',
            'payload': {
              'data': {
                'libraryUpdateStatusChanged': {
                  'jobsInfo': {'isRunning': true},
                },
              },
            },
          }));
        }));
      case _Behaviour.sendingGarbage:
        _emitters.add(Timer.periodic(emitEvery, (_) {
          // Deliberately not JSON: proves liveness must be recorded before
          // decoding, and must not be defeated by a parse failure.
          _emit(socket, '}}}not json at all {{{');
        }));
    }
  }

  Future<void> close() async {
    for (final t in _emitters) {
      t.cancel();
    }
    _emitters.clear();
    for (final s in _sockets) {
      try {
        await s.close();
      } catch (_) {}
    }
    await _accepted.close();
    await _server.close(force: true);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _ScriptedServer server;
  late WebSocketService ws;

  // Production defaults, restored after every test.
  final realPing = WebSocketService.pingInterval;
  final realWatchdog = WebSocketService.watchdogInterval;
  final realSilence = WebSocketService.livenessSilenceTimeout;
  final realBase = WebSocketService.reconnectBaseDelay;
  final realMax = WebSocketService.reconnectMaxDelay;

  setUp(() async {
    HttpOverrides.global = _RealHttpOverrides();
    // Compress the liveness timings ~50x so a 75s production watchdog is
    // observable in ~1.5s. The ping interval stays well above the watchdog
    // check period so the "server ignores pings" scenarios are genuinely
    // ping-free from the client's point of view.
    WebSocketService.pingInterval = const Duration(milliseconds: 200);
    WebSocketService.watchdogInterval = const Duration(milliseconds: 100);
    WebSocketService.livenessSilenceTimeout = const Duration(milliseconds: 1500);
    // And compress the reconnect backoff so a reclaim is observable quickly
    // too. 1s base doubles to 2s, so a reclaim lands inside the test window.
    WebSocketService.reconnectBaseDelay = const Duration(milliseconds: 200);
    WebSocketService.reconnectMaxDelay = const Duration(milliseconds: 800);

    server = await _ScriptedServer.start();
    ws = WebSocketService.instance;
    ws.onAuthExpired = null;
    ws.dispose();
  });

  tearDown(() async {
    ws.dispose();
    WebSocketService.pingInterval = realPing;
    WebSocketService.watchdogInterval = realWatchdog;
    WebSocketService.livenessSilenceTimeout = realSilence;
    WebSocketService.reconnectBaseDelay = realBase;
    WebSocketService.reconnectMaxDelay = realMax;
    HttpOverrides.global = null;
    await server.close();
  });

  group('a healthy server is NOT recycled', () {
    test('a server that streams updates but ignores pings stays connected', () async {
      // THE BUG. Pre-fix this reconnected every 75s (here: every ~1.5s) even
      // though the server was actively pushing subscription events, because
      // liveness was only credited to a literal `pong`.
      server.behaviour = _Behaviour.streamingIgnoringPings;
      server.emitEvery = const Duration(milliseconds: 150);

      ws.initialize(server.url, authToken: 'tok');
      await server.nextConnection;

      // Well past several watchdog windows.
      await Future<void>.delayed(const Duration(milliseconds: 2600));

      expect(ws.isConnected, isTrue,
          reason: 'the server is streaming events, so the socket is demonstrably alive');
      expect(server.connectionAttempts, 1,
          reason: 'a live, streaming connection must not be torn down and re-handshaked');
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('a server that answers pings stays connected', () async {
      // The pre-fix happy path must keep working after the change.
      server.behaviour = _Behaviour.answeringPings;

      ws.initialize(server.url, authToken: 'tok');
      await server.nextConnection;
      await Future<void>.delayed(const Duration(milliseconds: 2600));

      expect(ws.isConnected, isTrue);
      expect(server.connectionAttempts, 1);
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('a server sending unparseable frames is still not recycled', () async {
      // Bytes arriving prove the link is up; a frame we cannot parse is a
      // protocol nuisance, not a dead socket. Pre-fix, garbage also failed to
      // refresh the timestamp, so the watchdog killed a live connection.
      server.behaviour = _Behaviour.sendingGarbage;
      server.emitEvery = const Duration(milliseconds: 150);

      ws.initialize(server.url, authToken: 'tok');
      await server.nextConnection;
      await Future<void>.delayed(const Duration(milliseconds: 2600));

      expect(ws.isConnected, isTrue);
      expect(server.connectionAttempts, 1);
    }, timeout: const Timeout(Duration(seconds: 30)));
  });

  group('a genuinely dead socket IS still recycled', () {
    test('a server that acks then goes completely silent is reconnected', () async {
      // The watchdog must not have been defeated by the fix. Without this a
      // half-open TCP connection (server killed, network drop without FIN)
      // would never fire onError/onDone and _isConnected would stick true
      // forever with no reconnect.
      server.behaviour = _Behaviour.silent;

      ws.initialize(server.url, authToken: 'tok');
      await server.nextConnection;
      await Future<void>.delayed(const Duration(milliseconds: 500));
      expect(ws.isConnected, isTrue, reason: 'precondition: acked and still flagged connected');

      // The client pings every 200ms; the server ignores them all, so there is
      // genuinely no inbound traffic after the ack.
      await Future<void>.delayed(const Duration(milliseconds: 2600));

      expect(server.connectionAttempts, greaterThan(1),
          reason: 'a silent half-open socket must be reclaimed and reconnected');
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('the reclaimed connection is fully re-established', () async {
      // A recycle must be a real reconnect, not a flag flip: the replacement
      // socket gets its own connection_init AND both subscriptions again, so
      // the app resumes receiving update/download events.
      server.behaviour = _Behaviour.silent;

      ws.initialize(server.url, authToken: 'tok');
      await server.nextConnection;
      await Future<void>.delayed(const Duration(milliseconds: 3200));

      expect(server.connectionAttempts, greaterThanOrEqualTo(2),
          reason: 'the dead socket must have been reclaimed at least once');
      expect(ws.isConnected, isTrue,
          reason: 'the replacement connection was acked, so the service is live again');

      // Subscriptions are per-socket, so the reclaim has to re-send them.
      final subsAfterLastConnect = <String>[];
      for (final frame in server.frames) {
        if (frame['type'] == 'subscribe') subsAfterLastConnect.add(frame['id'].toString());
      }
      expect(subsAfterLastConnect, hasLength(greaterThanOrEqualTo(2)),
          reason: 'a recycled socket must re-subscribe to both event streams, '
              'otherwise the app silently stops receiving updates after a reclaim');
      expect(subsAfterLastConnect.toSet(), {'1', '2'});
    }, timeout: const Timeout(Duration(seconds: 30)));
  });

  group('liveness accounting invariants', () {
    test('the silence timeout comfortably exceeds the ping interval', () {
      // Guards the timing relationship the watchdog depends on. If the timeout
      // were shorter than pingInterval plus a round trip, a healthy but slow
      // link would be recycled on every cycle.
      expect(
        WebSocketService.livenessSilenceTimeout > WebSocketService.pingInterval,
        isTrue,
        reason: 'a fresh link must not trip the watchdog before its first ping '
            'interval has even elapsed',
      );
      expect(
        WebSocketService.pingInterval > WebSocketService.watchdogInterval,
        isTrue,
        reason: 'the watchdog must sample more often than it pings, or it can '
            'miss a window entirely',
      );
    });

    test('production defaults leave real headroom', () {
      // The compressed values used above must not be the shipped ones.
      expect(realPing, const Duration(seconds: 25));
      expect(realWatchdog, const Duration(seconds: 15));
      expect(realSilence, const Duration(seconds: 75));
      expect(realSilence.inSeconds, greaterThan(realPing.inSeconds * 2));
    });
  });
}
