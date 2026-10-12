// test/quick_action_handler_test.dart
//
// A7.5: Quick Settings tile channel contract.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/sync/quick_action_handler.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('sunfire/quick_actions');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('consumePending returns false when channel is absent', () async {
    // No mock handler: invokeMethod throws -> caught -> false.
    // (On non-Android devices the platform side never registers.)
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      throw PlatformException(code: 'no_channel');
    });
    expect(await QuickActionHandler.instance.consumePending(), isFalse);
  });

  test('consumePending returns false when platform reports nothing', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'consumePendingSync');
      return false;
    });
    expect(await QuickActionHandler.instance.consumePending(), isFalse);
  });

  test('start is idempotent and safe without platform', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async => false);
    await QuickActionHandler.instance.start();
    await QuickActionHandler.instance.start();
  });
}
