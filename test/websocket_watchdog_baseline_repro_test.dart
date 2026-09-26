// BASELINE REPRODUCTION for the WebSocket liveness-watchdog bug.
//
// The behaviour-specific tests live in test/websocket_liveness_test.dart and
// exercise both halves (healthy-but-quiet servers must survive, genuinely dead
// sockets must be reclaimed). This file is the focused baseline-vs-patched
// proof: it uses only APIs that exist on the PRE-FIX and POST-FIX revisions, so
// a pass here and a fail there is real evidence of remediation rather than of a
// test written to match new code.
//
// Verified result:
//   pre-fix  (c89c639) — FAILS: a server that streams subscription events but
//                       never sends a `pong` is force-disconnected on a loop,
//                       even though the socket is provably alive.
//   post-fix          — PASSES: any inbound frame counts as liveness.
//
// ROOT CAUSE: the watchdog refreshed its liveness timestamp only on a literal
// `pong` frame. (1) graphql-transport-ws defines the direction "server sends
// Ping, client replies Pong"; it never obliges a server to answer a *client*
// ping. (2) No other inbound frame counted either. So a healthy server that
// streams libraryUpdateStatusChanged / downloadStatusChanged but ignores client
// pings was declared dead every 75 seconds, forever — ~1150 needless
// TCP+TLS handshakes and re-subscriptions per day, each one a window in which
// update and download events are dropped.
//
// Run: fvm flutter test test/websocket_watchdog_baseline_repro_test.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/sync/websocket_service.dart';

class _RealHttpOverrides extends HttpOverrides {}

/// A server that acks, ignores client pings, and streams subscription events —
/// i.e. a live, busy Suwayomi that simply does not answer pings.
class _StreamingServer {
  _StreamingServer._(this._server);

  final HttpServer _server;
  final _accepted = StreamController<void>.broadcast();
  int connectionAttempts = 0;

  static Future<_StreamingServer> start() async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final fake = _StreamingServer._(server);
    unawaited(fake._serve());
    return fake;
  }

  String get url => 'http://127.0.0.1:${_server.port}';

  Future<void> get nextConnection =>
      _accepted.stream.first.timeout(const Duration(seconds: 10));

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

      socket.listen(
        (raw) {
          dynamic decoded;
          try {
            decoded = jsonDecode(raw as String);
          } catch (_) {
            return;
          }
          if (decoded is! Map<String, dynamic>) return;
          if (decoded['type'] != 'connection_init') {
            // Client ping: deliberately NOT answered. This is the whole point.
            return;
          }
          connectionAttempts++;
          _accepted.add(null);
          try {
            socket.add(jsonEncode({'type': 'connection_ack'}));
          } catch (_) {
            return;
          }
          // Actively push events forever. Bytes are flowing in both directions;
          // the link is healthy.
          Timer.periodic(const Duration(milliseconds: 150), (_) {
            try {
              socket.add(jsonEncode({
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
            } catch (_) {
              // Client closed the socket; nothing to do.
            }
          });
        },
        onDone: () {},
        onError: (_) {},
        cancelOnError: true,
      );
    }
  }

  Future<void> close() async {
    await _accepted.close();
    await _server.close(force: true);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _StreamingServer server;
  late WebSocketService ws;

  final realPing = WebSocketService.pingInterval;
  final realWatchdog = WebSocketService.watchdogInterval;
  final realSilence = WebSocketService.livenessSilenceTimeout;
  final realBase = WebSocketService.reconnectBaseDelay;
  final realMax = WebSocketService.reconnectMaxDelay;

  setUp(() async {
    HttpOverrides.global = _RealHttpOverrides();
    WebSocketService.pingInterval = const Duration(milliseconds: 200);
    WebSocketService.watchdogInterval = const Duration(milliseconds: 100);
    WebSocketService.livenessSilenceTimeout = const Duration(milliseconds: 1500);
    WebSocketService.reconnectBaseDelay = const Duration(milliseconds: 200);
    WebSocketService.reconnectMaxDelay = const Duration(milliseconds: 800);

    server = await _StreamingServer.start();
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

  // ── The safety assertion. Fails pre-fix, passes post-fix. ──────────────
  test('a live, event-streaming server must not be recycled by the watchdog', () async {
    ws.initialize(server.url, authToken: 'tok');
    await server.nextConnection;

    // Comfortably more than one watchdog window.
    await Future<void>.delayed(const Duration(milliseconds: 2600));

    expect(
      server.connectionAttempts,
      1,
      reason: 'The server is streaming subscription events continuously and '
          'ignoring only our client-initiated pings. Recycling the socket here '
          'costs a fresh TCP+TLS handshake plus both subscriptions again, and '
          'opens a window where update/download events are dropped. graphql-'
          'transport-ws does not require a server to answer a client ping, so '
          'a server may legitimately be silent about pings while perfectly '
          'healthy.',
    );
    expect(ws.isConnected, isTrue,
        reason: 'the service must not report itself healthy on a socket it just tore down');
  }, timeout: const Timeout(Duration(seconds: 30)));
}
