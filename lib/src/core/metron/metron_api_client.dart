import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../logging/logger_service.dart';
import 'metron_models.dart';

/// Client exception thrown on Metron API failures.
class MetronApiException implements Exception {
  final int statusCode;
  final String message;
  final bool isRateLimit;

  MetronApiException({
    required this.statusCode,
    required this.message,
    this.isRateLimit = false,
  });

  @override
  String toString() => 'MetronApiException($statusCode): $message (rateLimit=$isRateLimit)';
}

/// Dedicated network client for Metron.cloud with token auth, proactive rate limiting,
/// outbound request queuing, and automatic 429 retry.
class MetronApiClient {
  static const String defaultBaseUrl = 'https://metron.cloud/api/';
  final Dio _dio;

  String? _apiToken;
  MetronRateLimitState _rateLimitState = MetronRateLimitState(lastUpdated: DateTime.now());

  // Outbound queue to throttle requests and avoid burst violations (20 req/min = 1 req per 3s safe average)
  Completer<void>? _lastRequestCompleter;
  static const Duration _minRequestSpacing = Duration(milliseconds: 350);

  @visibleForTesting
  Dio get dio => _dio;

  MetronApiClient({Dio? dio, String? baseUrl})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl ?? defaultBaseUrl,
                connectTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(seconds: 30),
                headers: {
                  'Accept': 'application/json',
                  'User-Agent': 'Sunfire-ComicReader/1.0.0',
                },
              ),
            ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // 1. Inject Authentication (Metron API requires Bearer <token>)
          if (_apiToken != null && _apiToken!.trim().isNotEmpty) {
            final token = _apiToken!.trim();
            options.headers['Authorization'] = token.startsWith('Bearer ') || token.startsWith('Basic ')
                ? token
                : 'Bearer $token';
          }

          // 2. Throttle outbound requests.
          //
          // The gate is installed HERE, at request time, and the gate we wait
          // on is the one that was current when we arrived. Previously the
          // gate was only installed on response, so a burst of concurrent
          // calls (search + detail fired together) all observed a null gate
          // and went out simultaneously — spacing only applied to requests
          // that arrived after a response, letting a burst through and
          // risking the 20 req/min limit. Installing first and waiting
          // second serialises the whole burst.
          final previousGate = _lastRequestCompleter;
          final ownGate = Completer<void>();
          _lastRequestCompleter = ownGate;
          options.extra['metronSpacingGate'] = ownGate;

          if (previousGate != null && !previousGate.isCompleted) {
            await previousGate.future;
          }

          // 3. Proactive Rate-Limit Guard: If burst remaining is 0 or 1, delay until reset
          if (_rateLimitState.burstRemaining <= 1 && _rateLimitState.burstResetSeconds > 0) {
            final waitSeconds = _rateLimitState.burstResetSeconds.clamp(1, 60);
            LoggerService.instance.logWarning(
              'Metron burst rate-limit near exhaustion (${_rateLimitState.burstRemaining} remaining). Waiting ${waitSeconds}s...',
              'Metron',
            );
            await Future.delayed(Duration(seconds: waitSeconds));
          }

          handler.next(options);
        },
        onResponse: (response, handler) {
          // Parse all 6 X-RateLimit-* headers
          final headersMap = <String, List<String>>{};
          response.headers.forEach((key, values) {
            headersMap[key.toLowerCase()] = values;
          });
          _rateLimitState = MetronRateLimitState.fromHeaders(headersMap);

          _scheduleNextSpacing(
            response.requestOptions.extra['metronSpacingGate'] as Completer<void>?,
          );
          handler.next(response);
        },
        onError: (DioException err, handler) async {
          _scheduleNextSpacing(
            err.requestOptions.extra['metronSpacingGate'] as Completer<void>?,
          );

          // Handle HTTP 429 Too Many Requests. The retry re-enters this same
          // interceptor (via _dio.fetch), so a server that keeps answering 429
          // must not loop forever — cap consecutive retries and surface the
          // rate-limit error to the caller once exhausted.
          if (err.response?.statusCode == 429) {
            final attempts = ((err.requestOptions.extra['_metron429Retries'] as num?) ?? 0) + 1;
            if (attempts > 3) {
              LoggerService.instance.logWarning(
                'Metron HTTP 429 retried $attempts times without success — giving up on this request.',
                'Metron',
              );
              return handler.next(err);
            }
            err.requestOptions.extra['_metron429Retries'] = attempts;
            final retryAfterRaw = err.response?.headers.value('retry-after');
            final retrySeconds = int.tryParse(retryAfterRaw ?? '') ??
                (_rateLimitState.burstResetSeconds > 0 ? _rateLimitState.burstResetSeconds : 5);

            LoggerService.instance.logWarning(
              'Metron HTTP 429 received. Backing off for ${retrySeconds}s before retry (attempt $attempts/3).',
              'Metron',
            );

            await Future.delayed(Duration(seconds: retrySeconds));
            try {
              final retryResponse = await _dio.fetch(err.requestOptions);
              return handler.resolve(retryResponse);
            } catch (retryErr) {
              return handler.next(err);
            }
          }

          handler.next(err);
        },
      ),
    );
  }

  void _scheduleNextSpacing(Completer<void>? ownGate) {
    // Complete the gate that belongs to *this* request, taken from the request
    // options rather than from `_lastRequestCompleter` (which a newer, still
    // queued request has already replaced).
    //
    // Completing the current field instead would let a concurrent burst
    // release itself early — request 2 would observe request 3's gate already
    // scheduled and go out immediately, collapsing the spacing. Completing
    // the captured gate keeps each queued request waiting its own turn.
    final gate = ownGate;
    if (gate == null) {
      // Defensive: a response with no gate (e.g. a synthetic retry) still has
      // to unblock whoever is queued behind it.
      final current = _lastRequestCompleter;
      if (current == null) return;
      Future.delayed(_minRequestSpacing, () {
        if (!current.isCompleted) current.complete();
      });
      return;
    }
    Future.delayed(_minRequestSpacing, () {
      if (!gate.isCompleted) gate.complete();
    });
  }

  void setToken(String? token) {
    _apiToken = token?.trim();
    if (_apiToken != null && _apiToken!.isNotEmpty) {
      final headerVal = _apiToken!.startsWith('Bearer ') || _apiToken!.startsWith('Basic ')
          ? _apiToken!
          : 'Bearer $_apiToken';
      _dio.options.headers['Authorization'] = headerVal;
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }

  String? get apiToken => _apiToken;
  MetronRateLimitState get rateLimitState => _rateLimitState;

  /// Perform a GET request.
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(path, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode ?? 500;
      final message = e.response?.data?.toString() ?? e.message ?? 'Unknown Metron network error';
      throw MetronApiException(
        statusCode: statusCode,
        message: message,
        isRateLimit: statusCode == 429,
      );
    }
  }

  /// Perform a POST request.
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(path, data: data, options: options);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode ?? 500;
      final message = e.response?.data?.toString() ?? e.message ?? 'Unknown Metron network error';
      throw MetronApiException(
        statusCode: statusCode,
        message: message,
        isRateLimit: statusCode == 429,
      );
    }
  }
}
