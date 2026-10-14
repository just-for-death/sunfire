// ISS-134: the live-server guard refuses Jane's real server and anything
// that is not a local throwaway.
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/sync/graphql_client_service.dart';

import 'flutter_test_config.dart' show forbidRealServer;
import 'support/live_server_guard.dart';

void main() {
  final throwsUnsafe = throwsA(isA<UnsafeTestServerError>());

  group('assertSafeTestServerUrl', () {
    test('rejects 100.71.46.98 (any port)', () {
      expect(() => assertSafeTestServerUrl('http://100.71.46.98:4567'), throwsUnsafe);
      expect(() => assertSafeTestServerUrl('http://100.71.46.98:4590'), throwsUnsafe);
    });
    test('rejects 127.0.0.1:4567 and localhost:4567', () {
      expect(() => assertSafeTestServerUrl('http://127.0.0.1:4567'), throwsUnsafe);
      expect(() => assertSafeTestServerUrl('http://localhost:4567/'), throwsUnsafe);
    });
    test('rejects any Tailscale 100.64.0.0/10 address (100.100.1.1)', () {
      expect(() => assertSafeTestServerUrl('http://100.100.1.1:4590'), throwsUnsafe);
      expect(() => assertSafeTestServerUrl('http://100.64.0.1:8080'), throwsUnsafe);
      expect(() => assertSafeTestServerUrl('http://100.127.255.254:9'), throwsUnsafe);
    });
    test('rejects non-loopback hosts', () {
      expect(() => assertSafeTestServerUrl('http://192.168.1.9:4590'), throwsUnsafe);
      expect(() => assertSafeTestServerUrl('https://example.com'), throwsUnsafe);
    });
    test('allows the local throwaway port', () {
      assertSafeTestServerUrl('http://127.0.0.1:4590');
      assertSafeTestServerUrl('http://localhost:4590');
      assertSafeTestServerUrl('http://127.0.0.1:45999');
    });
  });

  group('requireThrowawayServer', () {
    test('unset → null (caller skips)', () async {
      expect(await requireThrowawayServer(null), isNull);
      expect(await requireThrowawayServer('  '), isNull);
    });
    test('unsafe URL throws before any request', () async {
      await expectLater(requireThrowawayServer('http://100.71.46.98:4567'), throwsUnsafe);
      await expectLater(requireThrowawayServer('http://127.0.0.1:4567'), throwsUnsafe);
      await expectLater(requireThrowawayServer('http://100.100.1.1:4590'), throwsUnsafe);
    });
    test('safe URL without the Docker marker fails loudly (nothing listening)', () async {
      await expectLater(requireThrowawayServer('http://127.0.0.1:45999'), throwsUnsafe);
    });
  });

  group('global deny hook (flutter_test_config.dart)', () {
    test('is installed and blocks GraphQLClientService on the real host / :4567', () {
      expect(GraphQLClientService.debugHostGuard, isNotNull);
      final c = GraphQLClientService.instance;
      expect(() => c.initialize('http://100.71.46.98:4567'), throwsUnsafe);
      expect(() => c.initialize('http://127.0.0.1:4567'), throwsUnsafe);
      expect(() => c.initialize('http://100.100.1.1'), throwsUnsafe);
      c.initialize('http://mock.invalid'); // mock hosts stay allowed
      c.initialize('');
      expect(() => forbidRealServer('http://localhost:4567'), throwsUnsafe);
    });
  });
}
