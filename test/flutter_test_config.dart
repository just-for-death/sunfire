import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Global test bootstrap: give every test an in-memory secure storage so
/// tests don't depend on the platform keychain/keystore plugin.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  FlutterSecureStorage.setMockInitialValues({});
  await testMain();
}
