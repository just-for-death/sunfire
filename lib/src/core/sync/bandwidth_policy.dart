// lib/src/core/sync/bandwidth_policy.dart
//
// BandwidthPolicy - metered-connection awareness and data budgets.
// Part of S4.3: Bandwidth-aware sync - WiFi only, metered data limits.
//
// Pure-Dart decision logic (testable) + thin connectivity_plus bridge.

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Connection class from the bandwidth perspective.
enum ConnectionClass {
  /// WiFi, Ethernet, VPN - unmetered, full speed.
  unmetered,

  /// Cellular - metered, budget applies.
  metered,

  /// No connectivity or unknown.
  offline,
}

/// Decision for a pending transfer.
enum TransferDecision {
  /// Proceed immediately.
  allow,

  /// Defer until unmetered connection.
  deferUntilUnmetered,

  /// Proceed but at reduced quality/size.
  allowDegraded,

  /// Blocked: over budget even for degraded transfer.
  denyOverBudget,
}

/// Pure-Dart bandwidth policy: connection classification + data budgets.
///
/// All decision logic is synchronous and unit-testable; only [currentClass]
/// touches the platform.
class BandwidthPolicy {
  BandwidthPolicy._();
  static final BandwidthPolicy instance = BandwidthPolicy._();

  static const String _prefsBytesKey = 'metered_bytes_used';
  static const String _prefsWindowKey = 'metered_window_start';
  static const String _prefsCapKey = 'metered_data_cap_mb';
  static const String _prefsDegradedKey = 'metered_allow_degraded';

  /// Default cap: 100 MB per 24h window on metered connections.
  static const int defaultCapMb = 100;

  /// Classify a connectivity_plus result set.
  static ConnectionClass classify(List<ConnectivityResult> results) {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return ConnectionClass.offline;
    }
    if (results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.ethernet) ||
        results.contains(ConnectivityResult.vpn) ||
        results.contains(ConnectivityResult.other)) {
      return ConnectionClass.unmetered;
    }
    if (results.contains(ConnectivityResult.mobile)) {
      return ConnectionClass.metered;
    }
    // Bluetooth and future types: treat as metered (conservative).
    return ConnectionClass.metered;
  }

  /// Current connection class (platform query).
  Future<ConnectionClass> currentClass() async {
    try {
      final results = await Connectivity().checkConnectivity();
      return classify(results);
    } catch (_) {
      return ConnectionClass.offline;
    }
  }

  /// Stream of connection-class changes.
  Stream<ConnectionClass> get onClassChanged =>
      Connectivity().onConnectivityChanged.map(classify).distinct();

  /// User-configured metered cap in MB (0 = unlimited).
  Future<int> getCapMb() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_prefsCapKey) ?? defaultCapMb;
  }

  Future<void> setCapMb(int mb) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefsCapKey, mb.clamp(0, 100000));
  }

  /// Whether degraded (low-quality) transfers are allowed on metered links.
  Future<bool> getAllowDegraded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefsDegradedKey) ?? true;
  }

  Future<void> setAllowDegraded(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsDegradedKey, value);
  }

  /// Bytes consumed in the current 24h metered window.
  Future<int> getWindowBytes() async {
    final prefs = await SharedPreferences.getInstance();
    final windowStart = prefs.getInt(_prefsWindowKey) ?? 0;
    final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (nowSec - windowStart > 24 * 3600) {
      await prefs.setInt(_prefsWindowKey, nowSec);
      await prefs.setInt(_prefsBytesKey, 0);
      return 0;
    }
    return prefs.getInt(_prefsBytesKey) ?? 0;
  }

  /// Record metered bytes consumed.
  Future<void> recordBytes(int bytes) async {
    if (bytes <= 0) return;
    final prefs = await SharedPreferences.getInstance();
    final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final windowStart = prefs.getInt(_prefsWindowKey) ?? 0;
    if (nowSec - windowStart > 24 * 3600) {
      await prefs.setInt(_prefsWindowKey, nowSec);
      await prefs.setInt(_prefsBytesKey, bytes);
    } else {
      final used = prefs.getInt(_prefsBytesKey) ?? 0;
      await prefs.setInt(_prefsBytesKey, used + bytes);
    }
  }

  /// Decide whether a transfer of [bytes] may proceed on [conn].
  Future<TransferDecision> decide({
    required ConnectionClass conn,
    required int bytes,
    bool degradable = true,
  }) async {
    if (conn == ConnectionClass.offline) {
      return TransferDecision.deferUntilUnmetered;
    }
    if (conn == ConnectionClass.unmetered) {
      return TransferDecision.allow;
    }
    // Metered path.
    final capMb = await getCapMb();
    if (capMb <= 0) return TransferDecision.allow; // unlimited
    final used = await getWindowBytes();
    final capBytes = capMb * 1024 * 1024;
    if (used + bytes <= capBytes) {
      return TransferDecision.allow;
    }
    if (degradable && await getAllowDegraded()) {
      // Degraded transfer at ~25% size: allow if THAT fits.
      if (used + (bytes ~/ 4) <= capBytes) {
        return TransferDecision.allowDegraded;
      }
    }
    return TransferDecision.denyOverBudget;
  }

  /// Bytes remaining in the current metered window (null = unlimited).
  Future<int?> bytesRemaining() async {
    final capMb = await getCapMb();
    if (capMb <= 0) return null;
    final used = await getWindowBytes();
    final remaining = capMb * 1024 * 1024 - used;
    return remaining < 0 ? 0 : remaining;
  }
}
