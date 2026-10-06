// UIX-P3-5: WS reconnect backoff resets when server URL or auth token changes,
// and is left alone when initialize is called with the same pair.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/sync/websocket_service.dart';

/// See websocket_auth_refresh_test.dart — binding's mock HttpClient breaks
/// real WebSocket upgrades with "Unsupported operation: Mocked response".
class _RealHttpOverrides extends HttpOverrides {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late WebSocketService ws;
  late Duration savedBase;
  late Duration savedMax;

  setUp(() {
    HttpOverrides.global = _RealHttpOverrides();
    savedBase = WebSocketService.reconnectBaseDelay;
    savedMax = WebSocketService.reconnectMaxDelay;
    WebSocketService.reconnectBaseDelay = const Duration(seconds: 2);
    WebSocketService.reconnectMaxDelay = const Duration(seconds: 60);
    ws = WebSocketService.instance;
    ws.onAuthExpired = null;
    ws.dispose();
  });

  tearDown(() {
    ws.dispose();
    HttpOverrides.global = null;
    WebSocketService.reconnectBaseDelay = savedBase;
    WebSocketService.reconnectMaxDelay = savedMax;
  });

  test('initialize with a new URL resets an escalated backoff', () {
    ws.debugReconnectDelaySeconds = 40;
    ws.initialize('http://127.0.0.1:9', authToken: 'tok-a');
    expect(ws.debugReconnectDelaySeconds, WebSocketService.reconnectBaseDelay.inSeconds);
  });

  test('initialize with a new token resets an escalated backoff', () {
    ws.initialize('http://127.0.0.1:9', authToken: 'tok-a');
    ws.debugReconnectDelaySeconds = 40;
    ws.initialize('http://127.0.0.1:9', authToken: 'tok-b');
    expect(ws.debugReconnectDelaySeconds, WebSocketService.reconnectBaseDelay.inSeconds);
  });

  test('initialize with the same URL and token does not reset backoff', () {
    ws.initialize('http://127.0.0.1:9', authToken: 'tok-a');
    ws.debugReconnectDelaySeconds = 40;
    ws.initialize('http://127.0.0.1:9', authToken: 'tok-a');
    expect(ws.debugReconnectDelaySeconds, 40);
  });
}
