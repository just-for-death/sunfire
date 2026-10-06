// ISS-078: WebSocketService picks up login-session credentials — override
// token on initialize, immediate reconnect on updateAuth, session refresh on a
// 4401 close, and the SIMPLE_LOGIN cookie on the upgrade request.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/sync/server_auth_refresher.dart';
import 'package:sunfire/src/core/sync/websocket_service.dart';

class _Server {
  _Server._(this._server);
  final HttpServer _server;
  final List<String?> auth = [];
  final List<String?> cookies = [];
  bool reject = false;
  final _accepted = StreamController<void>.broadcast();

  static Future<_Server> start() async {
    final s = _Server._(await HttpServer.bind(InternetAddress.loopbackIPv4, 0));
    unawaited(s._serve());
    return s;
  }

  Future<void> _serve() async {
    await for (final req in _server) {
      final cookie = req.headers.value('cookie');
      // ignore: close_sinks
      final socket = await WebSocketTransformer.upgrade(req, protocolSelector: (p) => p.first);
      socket.listen((raw) {
        final m = jsonDecode(raw as String) as Map<String, dynamic>;
        if (m['type'] == 'connection_init') {
          auth.add((m['payload'] as Map?)?['Authorization'] as String?);
          cookies.add(cookie);
          _accepted.add(null);
          if (reject) {
            unawaited(socket.close(4401, 'Unauthorized'));
          } else {
            socket.add(jsonEncode({'type': 'connection_ack'}));
          }
        }
      }, onError: (_) {}, cancelOnError: true);
    }
  }

  Future<void> waitFor(int n) async {
    while (auth.length < n) {
      await _accepted.stream.first.timeout(const Duration(seconds: 5));
    }
  }

  String get url => 'http://127.0.0.1:${_server.port}';
  Future<void> close() => _server.close(force: true);
}

class _FakeSession implements ServerAuthRefresher {
  String token = 'Bearer A1';
  Map<String, String> headers = const {};
  int refreshes = 0;
  @override
  String? authHeaderOverride(String baseUrl) => token;
  @override
  Map<String, String> extraHeaders(String baseUrl) => headers;
  @override
  Future<void> beforeRequest() async {}
  @override
  Future<bool> onUnauthorized() async {
    refreshes++;
    token = 'Bearer A2';
    return true;
  }
}

void main() {
  final ws = WebSocketService.instance;
  late _Server server;

  setUp(() async {
    server = await _Server.start();
    WebSocketService.reconnectBaseDelay = const Duration(milliseconds: 50);
  });

  tearDown(() async {
    ws.authRefresher = null;
    ws.dispose();
    WebSocketService.reconnectBaseDelay = const Duration(seconds: 5);
    await server.close();
  });

  test('session token outranks stored header; updateAuth reconnects now', () async {
    final session = _FakeSession();
    ws.authRefresher = session;
    ws.initialize(server.url, authToken: 'Basic stored');
    await server.waitFor(1);
    expect(server.auth.first, 'Bearer A1');
    ws.updateAuth('Bearer B9');
    await server.waitFor(2);
    expect(server.auth[1], 'Bearer B9');
    // Same credentials → no reconnect.
    ws.updateAuth('Bearer B9');
    await Future<void>.delayed(const Duration(milliseconds: 200));
    expect(server.auth.length, 2);
  });

  test('4401 → session refresh → reconnect with refreshed token', () async {
    final session = _FakeSession();
    ws.authRefresher = session;
    server.reject = true;
    ws.initialize(server.url, authToken: null);
    await server.waitFor(1);
    server.reject = false;
    await server.waitFor(2);
    expect(session.refreshes, greaterThanOrEqualTo(1));
    expect(server.auth[1], 'Bearer A2');
  });

  test('SIMPLE_LOGIN cookie is sent on the upgrade request', () async {
    final session = _FakeSession()
      ..token = 'Basic keep'
      ..headers = {'Cookie': 'JSESSIONID=abc'};
    ws.authRefresher = session;
    ws.initialize(server.url, authToken: 'Basic keep');
    await server.waitFor(1);
    expect(server.cookies.first, 'JSESSIONID=abc');
    expect(ws.debugExtraHeaders, {'Cookie': 'JSESSIONID=abc'});
  });
}
