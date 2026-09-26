import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/metron/metron_api_client.dart';

/// Minimal [HttpClientAdapter] that answers every request immediately and
/// records the wall-clock time it was reached, so request spacing can be
/// observed without touching the network.
class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter({this.statusCode = 200, this.body = '{}'});

  final int statusCode;
  final String body;
  final List<DateTime> hits = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    hits.add(DateTime.now());
    return ResponseBody.fromString(
      body,
      statusCode,
      headers: {
        'content-type': [Headers.jsonContentType],
        // Report a healthy burst budget so the proactive guard stays idle and
        // the assertions isolate *spacing* behaviour only.
        'x-ratelimit-burst-remaining': ['20'],
        'x-ratelimit-burst-limit': ['20'],
        'x-ratelimit-burst-reset': ['60'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('MetronApiClient outbound request spacing', () {
    test('concurrent requests all complete and are spaced apart', () async {
      final adapter = _RecordingAdapter(body: '{"results":[]}');
      final dio = Dio(BaseOptions(baseUrl: MetronApiClient.defaultBaseUrl));
      dio.httpClientAdapter = adapter;

      final client = MetronApiClient(dio: dio);
      final stopwatch = Stopwatch()..start();

      // Fire concurrently: the interceptor must queue them behind the
      // _lastRequestCompleter gate rather than deadlocking or firing together.
      final results = await Future.wait([
        client.dio.get<Map<String, dynamic>>('/search', queryParameters: {'query': 'x'}),
        client.dio.get<Map<String, dynamic>>('/search', queryParameters: {'query': 'y'}),
        client.dio.get<Map<String, dynamic>>('/search', queryParameters: {'query': 'z'}),
      ]).timeout(const Duration(seconds: 10));

      stopwatch.stop();

      expect(results, hasLength(3));
      for (final r in results) {
        expect(r.statusCode, 200);
      }
      expect(adapter.hits, hasLength(3));

      // Responses are scheduled 350ms apart, so three of them span at least
      // two spacing windows (~700ms). Well under the 10s timeout.
      expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(600));

      // And the hits are strictly ordered and non-simultaneous.
      for (var i = 1; i < adapter.hits.length; i++) {
        final gap = adapter.hits[i].difference(adapter.hits[i - 1]).inMilliseconds;
        expect(gap, greaterThanOrEqualTo(250), reason: 'hit $i arrived too soon after $i-1');
      }
    });

    test('a later request waits on the previous spacing window', () async {
      final adapter = _RecordingAdapter();
      final dio = Dio(BaseOptions(baseUrl: MetronApiClient.defaultBaseUrl));
      dio.httpClientAdapter = adapter;

      final client = MetronApiClient(dio: dio);

      await client.dio.get<Map<String, dynamic>>('/first');
      expect(adapter.hits, hasLength(1));

      // Issued immediately after the first response: must be held back until
      // the 350ms spacing timer completes.
      final stopwatch = Stopwatch()..start();
      await client.dio.get<Map<String, dynamic>>('/second');
      stopwatch.stop();

      expect(adapter.hits, hasLength(2));
      expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(250));
    });

    test('401 responses schedule spacing too and surface as errors', () async {
      final adapter = _RecordingAdapter(statusCode: 401, body: '{"error":"bad token"}');
      final dio = Dio(BaseOptions(baseUrl: MetronApiClient.defaultBaseUrl));
      dio.httpClientAdapter = adapter;

      final client = MetronApiClient(dio: dio);
      client.setToken('token-123');

      await expectLater(
        client.dio.get<Map<String, dynamic>>('/search'),
        throwsA(isA<DioException>()),
      );
      expect(adapter.hits, hasLength(1));

      // The onError path calls _scheduleNextSpacing, so a follow-up request
      // must still observe the throttle rather than firing immediately.
      final stopwatch = Stopwatch()..start();
      await expectLater(
        client.dio.get<Map<String, dynamic>>('/search'),
        throwsA(isA<DioException>()),
      );
      stopwatch.stop();
      expect(adapter.hits, hasLength(2));
      expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(250));
    });

    test('bearer token is attached to outbound requests', () async {
      final adapter = _RecordingAdapter();
      final dio = Dio(BaseOptions(baseUrl: MetronApiClient.defaultBaseUrl));
      dio.httpClientAdapter = adapter;

      final client = MetronApiClient(dio: dio);
      client.setToken('raw-token');

      await client.dio.get<Map<String, dynamic>>('/search');

      expect(dio.options.headers['Authorization'], 'Bearer raw-token');
      // An already-prefixed token must not be double-prefixed.
      client.setToken('Bearer prefixed');
      expect(dio.options.headers['Authorization'], 'Bearer prefixed');

      // Clearing the token removes the header rather than leaving it stale.
      client.setToken(null);
      expect(dio.options.headers.containsKey('Authorization'), isFalse);
    });
  });
}
