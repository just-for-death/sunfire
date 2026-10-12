// lib/src/core/sync/sync_manager.dart
//
// SyncManager - orchestrates delta sync, conflict resolution, and background scheduling
// Part of Phase 1.5: Sync Engine Overhaul

import 'dart:async';

import 'package:flutter/foundation.dart' show debugPrint;

import '../db/isar_service.dart';
import '../db/models/manga.dart';
import '../db/models/chapter.dart';
import '../db/models/category.dart';
import 'sync_engine.dart'
    show
        SyncEngine,
        SyncResult,
        SyncProgress,
        SyncPhase,
        SyncConflict,
        ConflictResolution,
        SyncConfig,
        ConflictResolutionStrategy;
import 'server_session_service.dart';
import 'server_auth_helper.dart';

/// SyncManager - orchestrates delta sync, conflict resolution, and background scheduling
/// Part of Phase 1.5: Sync Engine Overhaul
class SyncManager {
  SyncManager({
    required this.isarService,
    required this.syncEngine,
    required this.serverSessionService,
    required this.serverAuthHelper,
    required this.config,
  });

  final IsarService isarService;
  final SyncEngine syncEngine;
  final ServerSessionService serverSessionService;
  final ServerAuthHelper serverAuthHelper;
  final SyncConfig config;

  // State
  bool _isSyncing = false;
  final StreamController<SyncProgress> _progressController = StreamController<SyncProgress>.broadcast();
  final StreamController<SyncResult> _resultController = StreamController<SyncResult>.broadcast();
  Timer? _autoSyncTimer;
  DateTime? _lastSyncTimestamp;

  // Getters
  bool get isSyncing => _isSyncing;
  Stream<SyncProgress> get progressStream => _progressController.stream;
  Stream<SyncResult> get resultStream => _resultController.stream;
  DateTime? get lastSyncTimestamp => _lastSyncTimestamp;

  /// Initialize the sync manager
  Future<void> initialize() async {
    _lastSyncTimestamp = await _getLastSyncTimestamp();
    
    if (config.autoSyncInterval > Duration.zero) {
      _scheduleAutoSync();
    }
  }

  /// Perform a delta sync since last sync timestamp
  Future<SyncResult> syncDelta({
    required DateTime since,
    Set<int>? mangaIds,
    Set<int>? categoryIds,
  }) async {
    if (_isSyncing) {
      return SyncResult(
        success: false,
        errors: ['Sync already in progress'],
      );
    }

    _isSyncing = true;
    _emitProgress(SyncProgress(
      phase: SyncPhase.initializing,
      current: 0,
      total: 100,
    ));

    try {
      // Verify authentication
      final authValid = await ServerAuthHelper.validateAndRefreshAuth();
      if (!authValid) {
        return SyncResult(
          success: false,
          errors: ['Authentication failed'],
        );
      }

      // Fetch delta from server
      _emitProgress(SyncProgress(
        phase: SyncPhase.fetchingDelta,
        current: 10,
        total: 100,
      ));

      final deltaResult = await _fetchDelta(since, mangaIds, categoryIds);
      
      if (!deltaResult.success) {
        return deltaResult;
      }

      // Apply changes locally
      _emitProgress(SyncProgress(
        phase: SyncPhase.applyingChanges,
        current: 50,
        total: 100,
      ));

      final applyResult = await _applyDeltaChanges(deltaResult);
      
      if (!applyResult.success) {
        return applyResult;
      }

      // Update last sync timestamp
      _lastSyncTimestamp = DateTime.now();
      await _saveLastSyncTimestamp(_lastSyncTimestamp!);

      _emitProgress(SyncProgress(
        phase: SyncPhase.completed,
        current: 100,
        total: 100,
      ));

      return SyncResult(
        success: true,
        lastSyncTimestamp: _lastSyncTimestamp,
      );
    } catch (e, stack) {
      debugPrint('[SyncManager] Delta sync failed: $e\n$stack');
      return SyncResult(
        success: false,
        errors: ['Sync failed: $e'],
      );
    } finally {
      _isSyncing = false;
    }
  }

  /// Perform a full sync (all data)
  Future<SyncResult> syncFull() async {
    return syncDelta(
      since: DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  /// Sync specific manga
  Future<SyncResult> syncManga(Set<int> mangaIds) async {
    return syncDelta(
      since: DateTime.fromMillisecondsSinceEpoch(0),
      mangaIds: mangaIds,
    );
  }

  /// Sync specific categories
  Future<SyncResult> syncCategories(Set<int> categoryIds) async {
    return syncDelta(
      since: DateTime.fromMillisecondsSinceEpoch(0),
      categoryIds: categoryIds,
    );
  }

  /// Cancel all ongoing sync operations
  void cancelAll() {
    _isSyncing = false;
    _autoSyncTimer?.cancel();
  }

  /// Dispose resources
  void dispose() {
    cancelAll();
    _progressController.close();
    _resultController.close();
  }

  // ─── Private Methods ─────────────────────────────────────────────

  Future<SyncResult> _fetchDelta(
    DateTime since,
    Set<int>? mangaIds,
    Set<int>? categoryIds,
  ) async {
    // Delegate to SyncEngine for actual GraphQL operations
    return syncEngine.fetchDelta(
      since: since,
      mangaIds: mangaIds,
      categoryIds: categoryIds,
    );
  }

  Future<SyncResult> _applyDeltaChanges(SyncResult deltaResult) async {
    // Delegate to SyncEngine for applying changes
    return syncEngine.applyDeltaChanges(deltaResult);
  }

  Future<DateTime?> _getLastSyncTimestamp() async {
    // Read from Isar or preferences
    return await isarService.getLastSyncTimestamp();
  }

  Future<void> _saveLastSyncTimestamp(DateTime timestamp) async {
    await isarService.saveLastSyncTimestamp(timestamp);
  }

  void _scheduleAutoSync() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = Timer.periodic(config.autoSyncInterval, (_) async {
      if (!_isSyncing) {
        await syncDelta(since: _lastSyncTimestamp ?? DateTime.now());
      }
    });
  }

  void _emitProgress(SyncProgress progress) {
    _progressController.add(progress);
  }
}