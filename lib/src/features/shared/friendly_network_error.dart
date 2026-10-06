import 'dart:async';
import 'dart:io';

import '../../core/logging/logger_service.dart';

/// Maps raw network/exceptions to short user-facing messages (UIS-08).
/// Logs the original error via [LoggerService].
String friendlyNetworkError(Object e, {String tag = 'Network'}) {
  unawaited(LoggerService.instance.logWarning('Network error:$e', tag));
  if (e is TimeoutException) return 'Timed out';
  if (e is SocketException) {
    final msg = e.message.toLowerCase();
    if (msg.contains('failed host lookup') ||
        msg.contains('name or service not known') ||
        msg.contains('nodename nor servname')) {
      return 'Host not found';
    }
    if (msg.contains('connection refused') || e.osError?.errorCode == 111) {
      return 'Connection refused';
    }
    return 'Connection failed';
  }
  if (e is HandshakeException || e is TlsException || e is CertificateException) {
    return 'TLS/certificate error';
  }
  if (e is HttpException) return 'HTTP error';
  final s = e.toString().toLowerCase();
  if (s.contains('timed out') || s.contains('timeout')) return 'Timed out';
  if (s.contains('certificate') || s.contains('handshake') || s.contains('tls')) {
    return 'TLS/certificate error';
  }
  if (s.contains('connection refused')) return 'Connection refused';
  if (s.contains('failed host lookup') || s.contains('host not found')) {
    return 'Host not found';
  }
  return 'Unexpected error';
}
