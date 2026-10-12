// lib/src/core/sync/sync_health_service.dart
//
// SyncHealthService — provides real-time sync health metrics for the dashboard.
// Includes: pending count, error rate, last sync time, device status, retry queue.

import 'dart:async';

import 'package:flutter/foundation.dart' show debugPrint;

import '../db/isar_service.dart';

/// SyncHealthService — provides real-time sync health metrics for the dashboard.
///
/// Metrics:
/// - Last successful sync timestamp
/// - Pending sync count (by entity type)
/// - Failed sync count (by error type)
/// - Error rate (failed / total attempts)
/// - Device online/offline status
/// - Retry queue depth
/// - Next scheduled sync time
/// - Estimated time to clear queue
class SyncHealthService {
  SyncHealthService._();

  static final SyncHealthService instance = SyncHealthService._();

  Timer? _timer;
  final _controller = StreamController<SyncHealth>.broadcast();

  Stream<SyncHealth> get stream => _controller.stream;

  /// Current snapshot of sync health.
  SyncHealth get current => _current;
  SyncHealth _current = SyncHealth();

  /// Start periodic health updates.
  void start() {
    if (_timer != null) return;
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _refresh());
    _refresh();
  }

  /// Stop periodic updates.
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _refresh() async {
    try {
      final health = await _computeHealth();
      _current = health;
      _controller.add(health);
    } catch (e, st) {
      debugPrint('[SyncHealthService] _refresh error: $e\n$st');
    }
  }

  Future<SyncHealth> _computeHealth() async {
    final pending = await IsarService.instance.getPendingSyncRecords();
    final failed = await IsarService.instance.getFailedSyncRecords();

    final pendingByType = <String, int>{};
    final failedByType = <String, int>{};
    final pendingByEntity = <String, int>{};
    final failedByEntity = <String, int>{};

    for (final r in pending) {
      pendingByType[r.entityType.name] = (pendingByType[r.entityType.name] ?? 0) + 1;
      pendingByEntity['${r.entityType.name}:${r.entityId}'] =
          (pendingByEntity['${r.entityType.name}:${r.entityId}'] ?? 0) + 1;
    }

    for (final r in failed) {
      failedByType[r.action.name] = (failedByType[r.action.name] ?? 0) + 1;
      failedByEntity['${r.entityType.name}:${r.entityId}'] =
          (failedByEntity['${r.entityType.name}:${r.entityId}'] ?? 0) + 1;
      // Extract error from payload if available
      try {
        final payload = r.payloadJson;
        if (payload.contains('error')) {
          final error = payload.split('"error":"').last.split('"').first;
          failedByEntity[error] = (failedByEntity[error] ?? 0) + 1;
        }
      } catch (_) {}
    }

    final lastSync = await IsarService.instance.getLastSyncTimestamp();
    final nextSync = lastSync?.add(const Duration(hours: 4));

    return SyncHealth(
      lastSuccessfulSync: lastSync,
      nextScheduledSync: nextSync,
      pendingCount: pending.length,
      failedCount: failed.length,
      errorRate: (failed.length / (pending.length + failed.length).clamp(1, 10000)) * 100,
      pendingByEntity: pendingByEntity,
      failedByEntity: failedByEntity,
      pendingByAction: pendingByType,
      failedByAction: failedByType,
      totalAttempts: pending.length + failed.length,
      estimatedTimeToClear: pending.length > 0
          ? Duration(seconds: (pending.length * 2).toInt())
          : Duration.zero,
      isOnline: true, // Will be overridden by OfflineMonitor
    );
  }
}

/// Sync health snapshot for UI.
class SyncHealth {
  const SyncHealth({
    this.lastSuccessfulSync,
    this.nextScheduledSync,
    this.pendingCount = 0,
    this.failedCount = 0,
    this.errorRate = 0.0,
    this.pendingByEntity = const {},
    this.failedByEntity = const {},
    this.pendingByAction = const {},
    this.failedByAction = const {},
    this.totalAttempts = 0,
    this.estimatedTimeToClear = Duration.zero,
    this.isOnline = true,
  });

  final DateTime? lastSuccessfulSync;
  final DateTime? nextScheduledSync;
  final int pendingCount;
  final int failedCount;
  final double errorRate;
  final Map<String, int> pendingByEntity;
  final Map<String, int> failedByEntity;
  final Map<String, int> pendingByAction;
  final Map<String, int> failedByAction;
  final int totalAttempts;
  final Duration estimatedTimeToClear;
  final bool isOnline;

  SyncHealth copyWith({
    DateTime? lastSuccessfulSync,
    DateTime? nextScheduledSync,
    int? pendingCount,
    int? failedCount,
    Duration? estimatedTimeToClear,
    bool? isOnline,
  }) {
    return SyncHealth(
      lastSuccessfulSync: lastSuccessfulSync ?? this.lastSuccessfulSync,
      nextScheduledSync: nextScheduledSync ?? this.nextScheduledSync,
      pendingCount: pendingCount ?? this.pendingCount,
      failedCount: failedCount ?? this.failedCount,
      estimatedTimeToClear: estimatedTimeToClear ?? this.estimatedTimeToClear,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  @override
  String toString() {
    return 'SyncHealth(pending: $pendingCount, failed: $failedCount, '
        'errorRate: ${errorRate.toStringAsFixed(1)}%, online: $isOnline)';
  }
}