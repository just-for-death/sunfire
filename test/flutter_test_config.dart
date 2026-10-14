import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/sync/graphql_client_service.dart';

import 'support/live_server_guard.dart';
import 'support/singleton_resets.dart';

/// Global test bootstrap: give every test an in-memory secure storage so
/// tests don't depend on the platform keychain/keystore plugin.
///
/// ISS-134 deny hook: every test process forbids pointing GraphQLClientService
/// at Jane's real server (100.71.46.98, any Tailscale 100.64/10 address, or
/// port 4567). Pure URL-string tests on other hosts are unaffected.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  FlutterSecureStorage.setMockInitialValues({});
  GraphQLClientService.debugHostGuard = forbidRealServer;
  // ISS-140: every test starts from clean shared singletons.
  tearDown(resetAllSingletonsForTest);
  await testMain();
}

/// Throws for the real host / port; allows everything else (mock hosts too).
void forbidRealServer(String baseUrl) {
  final uri = Uri.tryParse(baseUrl);
  if (uri == null) return;
  try {
    // Reuse the strict checks, but only the "real server" parts: non-loopback
    // mock hosts like http://mock.invalid stay allowed.
    assertSafeTestServerUrl(baseUrl);
  } on UnsafeTestServerError catch (e) {
    if (!e.message.contains('not a loopback host')) rethrow;
  }
}
