import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../logging/logger_service.dart';
import '../services/server_tls_trust.dart';

class WebSocketService {
  static WebSocketService? _instance;
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  String? _wsUrl;
  String? _authToken;
  Timer? _handshakeTimer;
  bool _isConnected = false;
  int _reconnectDelaySeconds = 5;
  Timer? _reconnectTimer;
  Timer? _pingTimer;
  Timer? _pongWatchdogTimer;
  DateTime? _lastPongAt;
  bool _isConnecting = false;
  bool _isDisposed = false;

  /// Close codes `graphql-transport-ws` uses for a rejected auth.
  static const int _closeUnauthorized = 4401;
  static const int _closeForbidden = 4403;

  /// Invoked when the server closes the socket because the token was rejected
  /// (4401/4403) or because `connection_init` was never acknowledged.
  ///
  /// Should re-authenticate and return the new token, or return null / throw
  /// to signal the credentials are genuinely dead. Without it, a stale token
  /// made the reconnect loop retry forever with exponential backoff, never
  /// succeeding and never surfacing why — the socket just silently spun.
  Future<String?> Function()? onAuthExpired;

  final _updateStatusController = StreamController<Map<String, dynamic>>.broadcast();
  final _downloadStatusController = StreamController<Map<String, dynamic>>.broadcast();

  WebSocketService._();

  static WebSocketService get instance {
    _instance ??= WebSocketService._();
    return _instance!;
  }

  Stream<Map<String, dynamic>> get onUpdateStatus => _updateStatusController.stream;
  Stream<Map<String, dynamic>> get onDownloadStatus => _downloadStatusController.stream;
  bool get isConnected => _isConnected;

  void initialize(String httpUrl, {String? authToken}) {
    final trimmed = httpUrl.trim();
    if (trimmed.isEmpty) {
      _isDisposed = true;
      _pingTimer?.cancel();
      _pongWatchdogTimer?.cancel();
      _lastPongAt = null;
      _reconnectTimer?.cancel();
      _handshakeTimer?.cancel();
      _subscription?.cancel();
      if (_channel != null) {
        _channel!.sink.close();
        _channel = null;
      }
      _wsUrl = null;
      _authToken = null;
      _isConnected = false;
      _isConnecting = false;
      return;
    }
    _isDisposed = false;
    final cleanUrl = trimmed.endsWith('/') ? trimmed.substring(0, trimmed.length - 1) : trimmed;
    final wsScheme = cleanUrl.startsWith('https') ? 'wss' : 'ws';
    final hostAndPort = cleanUrl.replaceAll(RegExp(r'https?://'), '');
    final newWsUrl = '$wsScheme://$hostAndPort/api/graphql';
    
    if (_wsUrl != newWsUrl || authToken != _authToken) {
      _subscription?.cancel();
      if (_channel != null) {
        _channel!.sink.close();
        _channel = null;
      }
      _isConnected = false;
      _isConnecting = false;
    }
    
    _wsUrl = newWsUrl;
    _authToken = authToken;
    connect();
  }

  void connect() {
    if (_wsUrl == null || _isConnected || _isConnecting || _isDisposed) return;
    _isConnecting = true;

    try {
      // IOWebSocketChannel (not WebSocketChannel.connect) so the same
      // configured-server-only self-signed trust as the HTTP client applies.
      _channel = IOWebSocketChannel.connect(
        Uri.parse(_wsUrl!),
        protocols: ['graphql-transport-ws'],
        customClient: createServerTrustingHttpClient(() => _wsUrl),
      );
      _channel!.ready.catchError((e) {
        _handleDisconnect('WebSocket connect error: $e');
      });

      final payload = <String, dynamic>{};
      if (_authToken != null && _authToken!.isNotEmpty) {
        final token = _authToken!.trim();
        payload['Authorization'] = (token.startsWith('Basic ') || token.startsWith('Bearer '))
            ? token
            : 'Bearer $token';
      }

      _channel!.sink.add(jsonEncode({'type': 'connection_init', 'payload': payload}));

      _subscription = _channel!.stream.listen(
        (message) => _handleMessage(message),
        onError: (e) => _handleDisconnect('WebSocket error: $e'),
        onDone: () => _handleDisconnect('WebSocket closed by server'),
      );

      _handshakeTimer?.cancel();
      _handshakeTimer = Timer(const Duration(seconds: 10), () {
        if (!_isConnected) {
          _handleDisconnect('WebSocket handshake timeout');
        }
      });
      LoggerService.instance.logInfo('WebSocket connecting to $_wsUrl...', 'WebSocket');
    } catch (e) {
      _handleDisconnect('WebSocket connection failed: $e');
    }
  }

  void _startPingTimer() {
    _pingTimer?.cancel();
    _lastPongAt = DateTime.now();
    _pingTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      if (_isConnected && _channel != null) {
        try {
          _channel?.sink.add(jsonEncode({'type': 'ping'}));
        } catch (ignoredError) { if (kDebugMode) debugPrint('[websocket_service] ignored error: $ignoredError'); }
      }
    });

    // A server that stops answering pings — or a TCP connection whose socket
    // half-closed silently (killed server, network drop without FIN) — never
    // fires onError/onDone, so _isConnected would stick true forever with no
    // reconnect. Watchdog: if we've pinged and seen no pong for 75s, force a
    // disconnect so the reconnect loop re-establishes the channel.
    _pongWatchdogTimer?.cancel();
    _pongWatchdogTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (!_isConnected) return;
      final last = _lastPongAt;
      if (last == null) return;
      if (DateTime.now().difference(last) > const Duration(seconds: 75)) {
        LoggerService.instance.logWarning(
          'WebSocket pong watchdog: no pong for 75s — forcing reconnect.',
          'WebSocket',
        );
        _handleDisconnect('WebSocket heartbeat timeout (no pong)');
      }
    });
  }

  void _handleMessage(dynamic rawMessage) {
    try {
      final data = jsonDecode(rawMessage.toString()) as Map<String, dynamic>;
      final type = data['type'];

      if (type == 'connection_ack') {
        _isConnected = true;
        _isConnecting = false;
        _reconnectDelaySeconds = 5;
        _handshakeTimer?.cancel();
        _startPingTimer();
        LoggerService.instance.logInfo('WebSocket connection_ack received', 'WebSocket');
        _subscribeEvents();
      } else if (type == 'ping') {
        _channel?.sink.add(jsonEncode({'type': 'pong'}));
      } else if (type == 'pong') {
        // Heartbeat pong received from server — clears the watchdog.
        _lastPongAt = DateTime.now();
      } else if (type == 'next' || type == 'data') {
        final payload = data['payload'] as Map<String, dynamic>?;
        if (payload != null && payload.containsKey('data')) {
          final innerData = payload['data'] as Map<String, dynamic>?;
          if (innerData != null) {
            if (innerData.containsKey('libraryUpdateStatusChanged') && innerData['libraryUpdateStatusChanged'] is Map<String, dynamic>) {
              _updateStatusController.add(innerData['libraryUpdateStatusChanged'] as Map<String, dynamic>);
            } else if (innerData.containsKey('updateStatusChanged') && innerData['updateStatusChanged'] is Map<String, dynamic>) {
              // Older Suwayomi builds still emit the deprecated field name.
              _updateStatusController.add(innerData['updateStatusChanged'] as Map<String, dynamic>);
            } else if (innerData.containsKey('downloadStatusChanged') && innerData['downloadStatusChanged'] is Map<String, dynamic>) {
              _downloadStatusController.add(innerData['downloadStatusChanged'] as Map<String, dynamic>);
            }
          }
        }
      }
    } catch (e) {
      LoggerService.instance.logWarning('WebSocket message parse error: $e', 'WebSocket');
    }
  }

  void _subscribeEvents() {
    // A `connection_ack` can race a close (server drops us the instant it
    // acks, network blips). `sink.add` on a closed sink throws, and that used
    // to be swallowed by _handleMessage's catch-all and logged as a *parse*
    // error — leaving _isConnected == true with no subscriptions at all, i.e.
    // a silently dead channel that looks healthy. Send defensively instead.
    //
    // `sink` is a borrowed reference: _handleDisconnect owns teardown of the
    // real channel, so closing it here would race the reconnect. That makes
    // close_sinks a false positive for this local.
    // ignore: close_sinks
    final sink = _channel?.sink;
    if (sink == null) {
      _handleDisconnect('WebSocket closed before subscriptions could be sent');
      return;
    }

    try {
      // 1. Subscribe libraryUpdateStatusChanged — the modern field name (the old
      //    `updateStatusChanged` is deprecated on current Suwayomi builds).
      sink.add(jsonEncode({
        'id': '1',
        'type': 'subscribe',
        'payload': {
          'query': 'subscription { libraryUpdateStatusChanged(input: { maxUpdates: 10 }) { jobsInfo { isRunning } } }'
        }
      }));

      // 2. Subscribe downloadStatusChanged (Requires maxUpdates input arg)
      sink.add(jsonEncode({
        'id': '2',
        'type': 'subscribe',
        'payload': {
          'query': 'subscription { downloadStatusChanged(input: { maxUpdates: 10 }) { state omittedUpdates } }'
        }
      }));
    } catch (e) {
      _handleDisconnect('WebSocket subscription failed: $e');
    }
  }

  void _handleDisconnect(String reason) {
    final closeCode = _channel?.closeCode;
    _isConnected = false;
    _isConnecting = false;
    _pingTimer?.cancel();
    _pongWatchdogTimer?.cancel();
    _subscription?.cancel();
    try {
      _channel?.sink.close();
    } catch (ignoredError) { if (kDebugMode) debugPrint('[websocket_service] ignored error: $ignoredError'); }

    if (_isDisposed) return;

    final authRejected = closeCode == _closeUnauthorized || closeCode == _closeForbidden;
    if (authRejected) {
      _handleAuthRejected(closeCode);
      return;
    }

    LoggerService.instance.logWarning('$reason. Reconnecting in ${_reconnectDelaySeconds}s...', 'WebSocket');

    _reconnectTimer?.cancel();
    _handshakeTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: _reconnectDelaySeconds), () {
      _reconnectDelaySeconds = (_reconnectDelaySeconds * 2).clamp(5, 300);
      connect();
    });
  }

  /// The server rejected our credentials. Re-authenticate once and retry
  /// immediately; if that fails, stop spinning and fall back to the normal
  /// backoff so a genuinely dead login does not hammer the server forever.
  Future<void> _handleAuthRejected(int? closeCode) async {
    _reconnectTimer?.cancel();
    _handshakeTimer?.cancel();

    final refresher = onAuthExpired;
    if (refresher != null) {
      LoggerService.instance.logWarning(
        'WebSocket rejected credentials (close $closeCode) — refreshing token.',
        'WebSocket',
      );
      try {
        final fresh = await refresher();
        if (_isDisposed || _wsUrl == null) return;
        if (fresh != null && fresh.trim().isNotEmpty) {
          _authToken = fresh.trim();
          // A new token deserves a clean retry, not a backed-off one.
          _reconnectDelaySeconds = 5;
          connect();
          return;
        }
        LoggerService.instance.logWarning(
          'WebSocket token refresh returned no token — backing off.',
          'WebSocket',
        );
      } catch (e) {
        LoggerService.instance.logWarning(
          'WebSocket token refresh failed: $e — backing off.',
          'WebSocket',
        );
      }
    } else {
      LoggerService.instance.logWarning(
        'WebSocket rejected credentials (close $closeCode) and no refresher is registered.',
        'WebSocket',
      );
    }

    // Credentials are still bad. Reconnect on the backoff schedule so a
    // transient server-side auth outage can recover, but without the runaway
    // doubling from an immediate retry.
    _reconnectDelaySeconds = (_reconnectDelaySeconds * 2).clamp(5, 300);
    _reconnectTimer = Timer(Duration(seconds: _reconnectDelaySeconds), connect);
  }

  void dispose() {
    _isDisposed = true;
    // Drop the callback so a disposed service cannot re-enter app auth code.
    onAuthExpired = null;
    _pingTimer?.cancel();
    _pongWatchdogTimer?.cancel();
    _reconnectTimer?.cancel();
    _handshakeTimer?.cancel();
    _subscription?.cancel();
    try {
      _channel?.sink.close();
    } catch (ignoredError) { if (kDebugMode) debugPrint('[websocket_service] ignored error: $ignoredError'); }
  }
}
