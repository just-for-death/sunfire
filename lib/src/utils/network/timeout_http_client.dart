import 'dart:async';

import 'package:http/http.dart' as http;

/// An [http.BaseClient] that applies a timeout to every request.
class TimeoutHttpClient extends http.BaseClient {
  TimeoutHttpClient(
    this.timeout, {
    this.retries = 0,
    this.retryDelay = const Duration(seconds: 1),
  });

  /// The timeout duration for each request.
  final Duration timeout;
  final int retries;
  final Duration retryDelay;

  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // MultipartRequest bodies are single-use streams and cannot be cloned.
    // Skip retry logic entirely for multipart requests — just apply timeout.
    if (request is http.MultipartRequest) {
      return _inner.send(request).timeout(timeout);
    }

    int attempt = 0;

    // Keep an immutable template to clone for each retry
    final template = _cloneRequest(request);
    http.BaseRequest current = request;

    while (true) {
      try {
        return await _inner.send(current).timeout(timeout);
      } on TimeoutException {
        if (attempt >= retries) rethrow;
        attempt++;
        await Future.delayed(retryDelay);
        current = _cloneRequest(template);
      }
    }
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }

  // Creates a fresh copy of an [http.BaseRequest] to reuse across retries.
  // Only [http.Request] is cloneable; [http.MultipartRequest] is handled
  // in [send] before this method is ever called.
  http.BaseRequest _cloneRequest(http.BaseRequest original) {
    if (original is http.Request) {
      final clone = http.Request(original.method, original.url)
        ..headers.addAll(original.headers)
        ..followRedirects = original.followRedirects
        ..persistentConnection = original.persistentConnection;

      if (original.bodyBytes.isNotEmpty) {
        clone.bodyBytes = original.bodyBytes;
      }
      return clone;
    }
    // Fallback: return as-is and let the caller handle the response.
    // This path should not be reached in normal operation.
    return original;
  }
}
