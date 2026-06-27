import 'dart:async';

import 'package:http/http.dart' as http;

/// An [http.BaseClient] that applies a timeout to every request.
///
/// Uses a dedicated [http.Client] per request so timed-out connections can be
/// closed instead of leaving a response stream that completes after the caller
/// has already given up (which triggers gql "Future already completed").
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

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // MultipartRequest bodies are single-use streams and cannot be cloned.
    if (request is http.MultipartRequest) {
      return _sendWithTimeout(request);
    }

    int attempt = 0;
    final template = _cloneRequest(request);
    http.BaseRequest current = request;

    while (true) {
      try {
        return await _sendWithTimeout(current);
      } on TimeoutException {
        if (attempt >= retries) rethrow;
        attempt++;
        await Future.delayed(retryDelay);
        current = _cloneRequest(template);
      }
    }
  }

  Future<http.StreamedResponse> _sendWithTimeout(http.BaseRequest request) async {
    final client = http.Client();
    var clientClosed = false;

    void closeClient() {
      if (!clientClosed) {
        clientClosed = true;
        client.close();
      }
    }

    try {
      final streamedResponse = await client.send(request).timeout(
        timeout,
        onTimeout: () {
          closeClient();
          throw TimeoutException(
            'Request timed out after $timeout',
            timeout,
          );
        },
      );

      final controller = StreamController<List<int>>();
      StreamSubscription<List<int>>? subscription;
      Timer? idleTimer;

      void cancelIdleTimer() {
        idleTimer?.cancel();
        idleTimer = null;
      }

      void onIdleTimeout() {
        cancelIdleTimer();
        subscription?.cancel();
        closeClient();
        if (!controller.isClosed) {
          controller.addError(TimeoutException('No stream event', timeout));
        }
      }

      void armIdleTimer() {
        cancelIdleTimer();
        idleTimer = Timer(timeout, onIdleTimeout);
      }

      subscription = streamedResponse.stream.listen(
        (chunk) {
          armIdleTimer();
          controller.add(chunk);
        },
        onError: (Object error, StackTrace stackTrace) {
          cancelIdleTimer();
          closeClient();
          if (!controller.isClosed) {
            controller.addError(error, stackTrace);
          }
        },
        onDone: () {
          cancelIdleTimer();
          closeClient();
          if (!controller.isClosed) {
            controller.close();
          }
        },
        cancelOnError: true,
      );

      armIdleTimer();

      controller.onCancel = () {
        cancelIdleTimer();
        subscription?.cancel();
        closeClient();
      };

      return http.StreamedResponse(
        controller.stream,
        streamedResponse.statusCode,
        contentLength: streamedResponse.contentLength,
        request: streamedResponse.request,
        headers: streamedResponse.headers,
        isRedirect: streamedResponse.isRedirect,
        persistentConnection: false,
        reasonPhrase: streamedResponse.reasonPhrase,
      );
    } catch (error) {
      closeClient();
      rethrow;
    }
  }

  // Creates a fresh copy of an [http.Request] to reuse across retries.
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
    return original;
  }
}
