// lib/src/core/sync/cross_device_awareness.dart
//
// CrossDeviceAwarenessService — tracks other devices syncing to the same server.
// Prevents duplicate work by detecting when another device has already processed
// an entity, and provides real-time device presence information.
//
// Features:
// - Device registry from sync records
// - Last-seen timestamps per device
// - Duplicate work detection (entity already processed by another device)
// - Device presence stream for UI
// - Device naming/management

import 'dart:async';

import 'package:flutter/foundation.dart' show debugPrint;

import '../db/isar_service.dart';
import '../db/models/sync_record.dart';
import '../services/settings_service.dart';

/// CrossDeviceAwarenessService — tracks other devices syncing to the same server.
///
/// Provides:
/// - List of known devices with last-seen times
/// - Current device ID
/// - Duplicate work detection
/// - Real-time device presence updates
class CrossDeviceAwarenessService {
  CrossDeviceAwarenessService._();
  static final CrossDeviceAwarenessService instance = CrossDeviceAwarenessService._();

  final _controller = StreamController<List<DeviceInfo>>.broadcast();
  List<DeviceInfo> _devices = [];
  Timer? _refreshTimer;

  /// Stream of known devices, updated periodically.
  Stream<List<DeviceInfo>> get deviceStream => _controller.stream;

  /// Current list of known devices.
  List<DeviceInfo> get devices => List.unmodifiable(_devices);

  /// Current device's ID.
  String get currentDeviceId => SettingsService.instance.syncDeviceId ?? 'unknown';

  /// Initialize and start periodic refresh.
  void initialize() {
    if (_refreshTimer != null) return;
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) => _refresh());
    _refresh(); // ignore: discarded_futures
  }

  /// Stop periodic refresh timer without closing controller.
  void stopTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  /// Stop periodic refresh.
  void dispose() {
    stopTimer();
    _controller.close(); // ignore: discarded_futures
  }

  /// Force refresh of device list.
  Future<void> _refresh() async {
    try {
      final devices = await _collectDevices();
      if (!_listsEqual(devices, _devices)) {
        _devices = devices;
        _controller.add(_devices);
      }
    } catch (e, st) {
      debugPrint('[CrossDeviceAwareness] _refresh error: $e\n$st');
    }
  }

  bool _listsEqual(List<DeviceInfo> a, List<DeviceInfo> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id || a[i].lastSeen != b[i].lastSeen) return false;
    }
    return true;
  }

  Future<List<DeviceInfo>> _collectDevices() async {
    // Get all sync records to extract device IDs and last activity
    final records = await IsarService.instance.getAllSyncRecords(limit: 5000);
    final deviceMap = <String, DeviceInfo>{};

    for (final record in records) {
      final deviceId = record.deviceId;
      if (deviceId.isEmpty) continue;

      final lastSeen = DateTime.fromMillisecondsSinceEpoch(record.timestamp * 1000);
      final existing = deviceMap[deviceId];

      if (existing == null || lastSeen.isAfter(existing.lastSeen)) {
        deviceMap[deviceId] = DeviceInfo(
          id: deviceId,
          name: _getDeviceName(deviceId),
          lastSeen: lastSeen,
          isCurrentDevice: deviceId == currentDeviceId,
          recordCount: (existing?.recordCount ?? 0) + 1,
        );
      }
    }

    // Add current device if not in records
    if (!deviceMap.containsKey(currentDeviceId)) {
      deviceMap[currentDeviceId] = DeviceInfo(
        id: currentDeviceId,
        name: _getDeviceName(currentDeviceId),
        lastSeen: DateTime.now(),
        isCurrentDevice: true,
        recordCount: 0,
      );
    }

    // Sort: current device first, then by last seen descending
    final devices = deviceMap.values.toList();
    devices.sort((a, b) {
      if (a.isCurrentDevice && !b.isCurrentDevice) return -1;
      if (!a.isCurrentDevice && b.isCurrentDevice) return 1;
      return b.lastSeen.compareTo(a.lastSeen);
    });

    return devices;
  }

  String _getDeviceName(String deviceId) {
    // Try to get a friendly name from settings
    final prefsName = SettingsService.instance.getDeviceName(deviceId);
    if (prefsName != null) return prefsName;

    // Fallback: generate a readable name from the UUID
    if (deviceId.length >= 8) {
      return 'Device ${deviceId.substring(0, 8)}';
    }
    return 'Device $deviceId';
  }

  /// Set a friendly name for a device.
  Future<void> setDeviceName(String deviceId, String name) async {
    await SettingsService.instance.setDeviceName(deviceId, name);
    await _refresh();
  }

  /// Check if another device has already processed this entity recently.
  ///
  /// Returns the device ID that processed it, or null if not processed.
  Future<String?> getRecentProcessor(String entityType, String entityId) async {
    final records = await IsarService.instance.getSyncRecordsForEntity(
      entityType,
      entityId,
      limit: 10,
    );

    for (final record in records) {
      if (record.deviceId != currentDeviceId &&
          record.state == SyncRecordState.synced) {
        final age = DateTime.now().millisecondsSinceEpoch ~/ 1000 - record.timestamp;
        if (age < 3600) { // Within last hour
          return record.deviceId;
        }
      }
    }
    return null;
  }

  /// Check if we should skip processing because another device handled it.
  ///
  /// Returns true if another device recently synced this entity.
  Future<bool> shouldSkipDueToOtherDevice(
    String entityType,
    String entityId, {
    Duration maxAge = const Duration(hours: 1),
  }) async {
    final processor = await getRecentProcessor(entityType, entityId);
    return processor != null;
  }

  /// Get device info for a specific device ID.
  DeviceInfo? getDeviceInfo(String deviceId) {
    try {
      return _devices.firstWhere((d) => d.id == deviceId);
    } catch (_) {
      return null;
    }
  }

  /// Get count of active devices (seen in last 5 minutes).
  int get activeDeviceCount {
    final cutoff = DateTime.now().subtract(const Duration(minutes: 5));
    return _devices.where((d) => d.lastSeen.isAfter(cutoff)).length;
  }

  /// Get count of all known devices.
  int get totalDeviceCount => _devices.length;
}

/// Information about a known device.
class DeviceInfo {
  const DeviceInfo({
    required this.id,
    required this.name,
    required this.lastSeen,
    required this.isCurrentDevice,
    required this.recordCount,
  });

  final String id;
  final String name;
  final DateTime lastSeen;
  final bool isCurrentDevice;
  final int recordCount;

  /// Whether this device was seen recently (within 5 minutes).
  bool get isActive => lastSeen.isAfter(DateTime.now().subtract(const Duration(minutes: 5)));

  /// Human-readable last seen string.
  String get lastSeenLabel {
    if (isCurrentDevice) return 'This device';
    final diff = DateTime.now().difference(lastSeen);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${diff.inDays}d ago';
  }

  @override
  String toString() => 'DeviceInfo(id: $id, name: $name, lastSeen: $lastSeenLabel, '
      'isCurrent: $isCurrentDevice, records: $recordCount)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceInfo && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}