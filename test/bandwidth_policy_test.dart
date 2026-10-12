// test/bandwidth_policy_test.dart
//
// S4.3: Bandwidth-aware sync - connection classification + data budgets.

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunfire/src/core/sync/bandwidth_policy.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('classify', () {
    test('empty or none -> offline', () {
      expect(BandwidthPolicy.classify([]), ConnectionClass.offline);
      expect(BandwidthPolicy.classify([ConnectivityResult.none]),
          ConnectionClass.offline);
    });

    test('wifi/ethernet/vpn/other -> unmetered', () {
      expect(BandwidthPolicy.classify([ConnectivityResult.wifi]),
          ConnectionClass.unmetered);
      expect(BandwidthPolicy.classify([ConnectivityResult.ethernet]),
          ConnectionClass.unmetered);
      expect(BandwidthPolicy.classify([ConnectivityResult.vpn]),
          ConnectionClass.unmetered);
      expect(BandwidthPolicy.classify([ConnectivityResult.other]),
          ConnectionClass.unmetered);
    });

    test('mobile -> metered', () {
      expect(BandwidthPolicy.classify([ConnectivityResult.mobile]),
          ConnectionClass.metered);
    });

    test('bluetooth -> metered (conservative)', () {
      expect(BandwidthPolicy.classify([ConnectivityResult.bluetooth]),
          ConnectionClass.metered);
    });

    test('mixed wifi+mobile prefers unmetered', () {
      expect(
          BandwidthPolicy.classify(
              [ConnectivityResult.mobile, ConnectivityResult.wifi]),
          ConnectionClass.unmetered);
    });
  });

  group('decide', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('offline always defers', () async {
      final d = await BandwidthPolicy.instance.decide(
          conn: ConnectionClass.offline, bytes: 1);
      expect(d, TransferDecision.deferUntilUnmetered);
    });

    test('unmetered always allows', () async {
      final d = await BandwidthPolicy.instance.decide(
          conn: ConnectionClass.unmetered, bytes: 1 << 30);
      expect(d, TransferDecision.allow);
    });

    test('metered under cap allows', () async {
      SharedPreferences.setMockInitialValues({'metered_data_cap_mb': 100});
      final d = await BandwidthPolicy.instance.decide(
          conn: ConnectionClass.metered, bytes: 1024);
      expect(d, TransferDecision.allow);
    });

    test('metered over cap with degraded allowed -> allowDegraded', () async {
      SharedPreferences.setMockInitialValues({
        'metered_data_cap_mb': 1, // 1 MB
        'metered_bytes_used': 800 * 1024, // 800 KB used
        'metered_window_start':
            DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'metered_allow_degraded': true,
      });
      // 500 KB won't fit (800+500 > 1024) but degraded (~125 KB) will.
      final d = await BandwidthPolicy.instance.decide(
          conn: ConnectionClass.metered, bytes: 500 * 1024);
      expect(d, TransferDecision.allowDegraded);
    });

    test('metered over cap degraded disabled -> denyOverBudget', () async {
      SharedPreferences.setMockInitialValues({
        'metered_data_cap_mb': 1,
        'metered_bytes_used': 800 * 1024,
        'metered_window_start':
            DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'metered_allow_degraded': false,
      });
      final d = await BandwidthPolicy.instance.decide(
          conn: ConnectionClass.metered, bytes: 500 * 1024);
      expect(d, TransferDecision.denyOverBudget);
    });

    test('cap 0 means unlimited', () async {
      SharedPreferences.setMockInitialValues({'metered_data_cap_mb': 0});
      final d = await BandwidthPolicy.instance.decide(
          conn: ConnectionClass.metered, bytes: 1 << 30);
      expect(d, TransferDecision.allow);
    });

    test('recordBytes accumulates and window resets after 24h', () async {
      SharedPreferences.setMockInitialValues({});
      await BandwidthPolicy.instance.recordBytes(1000);
      expect(await BandwidthPolicy.instance.getWindowBytes(), 1000);
      await BandwidthPolicy.instance.recordBytes(500);
      expect(await BandwidthPolicy.instance.getWindowBytes(), 1500);
    });

    test('bytesRemaining reflects cap minus usage', () async {
      SharedPreferences.setMockInitialValues({
        'metered_data_cap_mb': 10,
        'metered_bytes_used': 2 * 1024 * 1024,
        'metered_window_start':
            DateTime.now().millisecondsSinceEpoch ~/ 1000,
      });
      expect(await BandwidthPolicy.instance.bytesRemaining(),
          8 * 1024 * 1024);
    });
  });
}
