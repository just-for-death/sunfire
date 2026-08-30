import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../logging/logger_service.dart';

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
    final cleanUrl = httpUrl.endsWith('/') ? httpUrl.substring(0, httpUrl.length - 1) : httpUrl;
    final wsScheme = cleanUrl.startsWith('https') ? 'wss' : 'ws';
    final hostAndPort = cleanUrl.replaceAll(RegExp(r'https?://'), '');
    final newWsUrl = '$wsScheme://$hostAndPort/api/graphql';
    
    if (_wsUrl != newWsUrl || authToken != _authToken) {
      if (_channel != null) {
        _channel!.sink.close();
        _channel = null;
      }
      _isConnected = false;
    }
    
    _wsUrl = newWsUrl;
    _authToken = authToken;
    connect();
  }

  void connect() {
    if (_wsUrl == null || _isConnected) return;

    try {
      _channel = WebSocketChannel.connect(
        Uri.parse(_wsUrl!),
        protocols: ['graphql-transport-ws'],
      );

      final payload = <String, dynamic>{};
      if (_authToken != null && _authToken!.isNotEmpty) {
        payload['Authorization'] = _authToken!.startsWith('Bearer ') ? _authToken : 'Bearer $_authToken';
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

  void _handleMessage(dynamic rawMessage) {
    try {
      final data = jsonDecode(rawMessage.toString()) as Map<String, dynamic>;
      final type = data['type'];

      if (type == 'connection_ack') {
        _isConnected = true;
        _reconnectDelaySeconds = 5;
        _handshakeTimer?.cancel();
        LoggerService.instance.logInfo('WebSocket connection_ack received', 'WebSocket');
        _subscribeEvents();
      } else if (type == 'next' || type == 'data') {
        final payload = data['payload'] as Map<String, dynamic>?;
        if (payload != null && payload.containsKey('data')) {
          final innerData = payload['data'] as Map<String, dynamic>?;
          if (innerData != null) {
            if (innerData.containsKey('updateStatusChanged')) {
              _updateStatusController.add(innerData['updateStatusChanged']);
            } else if (innerData.containsKey('downloadStatusChanged')) {
              _downloadStatusController.add(innerData['downloadStatusChanged']);
            }
          }
        }
      }
    } catch (e) {
      LoggerService.instance.logWarning('WebSocket message parse error: $e', 'WebSocket');
    }
  }

  void _subscribeEvents() {
    // 1. Subscribe updateStatusChanged (NO input args)
    _channel?.sink.add(jsonEncode({
      'id': '1',
      'type': 'subscribe',
      'payload': {
        'query': 'subscription { updateStatusChanged { isRunning completeJobs pendingJobs } }'
      }
    }));

    // 2. Subscribe downloadStatusChanged (Requires maxUpdates input arg)
    _channel?.sink.add(jsonEncode({
      'id': '2',
      'type': 'subscribe',
      'payload': {
        'query': 'subscription { downloadStatusChanged(input: { maxUpdates: 10 }) { state omittedUpdates } }'
      }
    }));
  }

  void _handleDisconnect(String reason) {
    _isConnected = false;
    _subscription?.cancel();
    _channel?.sink.close();
    LoggerService.instance.logWarning('$reason. Reconnecting in ${_reconnectDelaySeconds}s...', 'WebSocket');

    _reconnectTimer?.cancel();
    _handshakeTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: _reconnectDelaySeconds), () {
      _reconnectDelaySeconds = (_reconnectDelaySeconds * 2).clamp(5, 300);
      connect();
    });
  }

  void dispose() {
    _reconnectTimer?.cancel();
    _handshakeTimer?.cancel();
    _subscription?.cancel();
    _channel?.sink.close();
    _updateStatusController.close();
    _downloadStatusController.close();
  }
}
