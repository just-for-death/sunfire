import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/metron/metron_api_client.dart';

void main() {
  group('MetronApiClient Unit Tests', () {
    test('Token configuration sets Authorization: Bearer header properly', () {
      final client = MetronApiClient();
      expect(client.apiToken, isNull);

      client.setToken('test-secret-token-123');
      expect(client.apiToken, 'test-secret-token-123');
      expect(client.dio.options.headers['Authorization'], 'Bearer test-secret-token-123');
      expect(client.dio.options.headers['Accept'], 'application/json');

      client.setToken(null);
      expect(client.apiToken, isNull);
      expect(client.dio.options.headers.containsKey('Authorization'), isFalse);
    });

    test('Initial rate limit state has default values', () {
      final client = MetronApiClient();
      expect(client.rateLimitState.burstLimit, 20);
      expect(client.rateLimitState.burstRemaining, 20);
      expect(client.rateLimitState.sustainedLimit, 5000);
    });
  });
}
