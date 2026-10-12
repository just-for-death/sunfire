// lib/src/core/sync/sync_manager.dart
//
// SyncManager — thin orchestrator over SyncEngine (scheduling/UI progress).
// Does NOT implement a second sync engine. Production GraphQL work stays in
// SyncEngine; this layer owns progress streams, cancel flags, and conflict
// hand-off to the UI.

import 'dart:async';

import 'package:flutter/foundation.dart' show debugPrint;

import '../db/isar_service.dart';
import 'conflict_resolver.dart'
    show ConflictResolver, ConflictResolutionStrategy;
import 'cross_device_awareness.dart';
import 'server_auth_helper.dart';
import 'server_session_service.dart';
import 'sync_conflict_helpers.dart';
import 'sync_engine.dart'
    show
        SyncEngine,
        SyncResult,
        SyncProgress,
        SyncPhase,
        SyncConflict,
        ConflictResolution,
        SyncConfig;

/// Thin orchestrator that delegates all GraphQL/DB work to [SyncEngine].
class SyncManager {
  SyncManager._({
    SyncEngine? syncEngine,
    IsarService? isarService,
    ServerSessionService? serverSessionService,
    SyncConfig? config,
  })  : _syncEngineOverride = syncEngine,
        _isarOverride = isarService,
        _sessionOverride = serverSessionService,
        config = config ??
            const SyncConfig(autoSyncInterval: Duration.zero);

  static final SyncManager instance = SyncManager._();

  /// Test seam — does not replace [instance].
  factory SyncManager.forTest({
    required SyncEngine syncEngine,
    required IsarService isarService,
    ServerSessionService? serverSessionService,
    SyncConfig config = const SyncConfig(autoSyncInterval: Duration.zero),
  }) {
    return SyncManager._(
      syncEngine: syncEngine,
      isarService: isarService,
      serverSessionService: serverSessionService,
      config: config,
    );
  }

  final SyncEngine? _syncEngineOverride;
  final IsarService? _isarOverride;
  final ServerSessionService? _sessionOverride;

  SyncEngine get syncEngine => _syncEngineOverride ?? SyncEngine.instance;
  IsarService get isarService => _isarOverride ?? IsarService.instance;
  ServerSessionService get serverSessionService =>
      _sessionOverride ?? ServerSessionService.instance;

  /// Auto-interval stays zero by default so we do not race [BackgroundService].
  SyncConfig config;

  bool _initialized = false;
  bool _isSyncing = false;
  bool _cancelRequested = false;
  final StreamController<SyncProgress> _progressController =
      StreamController<SyncProgress>.broadcast();
  final StreamController<SyncResult> _resultController =
      StreamController<SyncResult>.broadcast();
  Timer? _autoSyncTimer;
  DateTime? _lastSyncTimestamp;
  List<SyncConflict> _pendingConflicts = const [];

  bool get isInitialized => _initialized;
  bool get isSyncing => _isSyncing;
  bool get cancelRequested => _cancelRequested;
  Stream<SyncProgress> get progressStream => _progressController.stream;
  Stream<SyncResult> get resultStream => _resultController.stream;
  DateTime? get lastSyncTimestamp => _lastSyncTimestamp;
  List<SyncConflict> get pendingConflicts =>
      List.unmodifiable(_pendingConflicts);

  /// Initialize once from app startup (after [SyncEngine.initialize]).
  Future<void> initialize() async {
    if (_initialized) return;
    _lastSyncTimestamp = await isarService.getLastSyncTimestamp();
    // Ensure session restore has run (main.dart already awaits restore; this is
    // idempotent if called again).
    try {
      await serverSessionService.restore();
    } catch (e) {
      debugPrint('[SyncManager] session restore: $e');
    }
    CrossDeviceAwarenessService.instance.initialize();
    if (config.autoSyncInterval > Duration.zero) {
      _scheduleAutoSync();
    }
    _initialized = true;
  }

  /// Delta sync since [since] (defaults to last successful timestamp).
  Future<SyncResult> syncDelta({
    DateTime? since,
    Set<int>? mangaIds,
    Set<int>? categoryIds,
  }) async {
    if (_isSyncing || syncEngine.isSyncing) {
      return const SyncResult(
        success: false,
        errors: ['Sync already in progress'],
      );
    }

    _isSyncing = true;
    _cancelRequested = false;
    final effectiveSince =
        since ?? _lastSyncTimestamp ?? DateTime.fromMillisecondsSinceEpoch(0);

    _emitProgress(const SyncProgress(
      phase: SyncPhase.initializing,
      current: 0,
      total: 100,
    ));

    try {
      final authValid = await ServerAuthHelper.validateAndRefreshAuth();
      if (!authValid) {
        return _finish(const SyncResult(
          success: false,
          errors: ['Authentication failed'],
        ));
      }

      if (_cancelRequested) {
        return _finish(const SyncResult(
          success: false,
          errors: ['Sync cancelled'],
        ));
      }

      _emitProgress(const SyncProgress(
        phase: SyncPhase.fetchingDelta,
        current: 15,
        total: 100,
      ));

      final deltaResult = await syncEngine.fetchDelta(
        since: effectiveSince,
        mangaIds: mangaIds,
        categoryIds: categoryIds,
      );

      if (!deltaResult.success) {
        return _finish(deltaResult);
      }

      if (_cancelRequested) {
        return _finish(const SyncResult(
          success: false,
          errors: ['Sync cancelled'],
        ));
      }

      _emitProgress(const SyncProgress(
        phase: SyncPhase.applyingChanges,
        current: 55,
        total: 100,
      ));

      final applyResult = await syncEngine.applyDeltaChanges(deltaResult);

      if (!applyResult.success) {
        return _finish(applyResult);
      }

      if (mangaIds != null && mangaIds.isNotEmpty) {
        for (final id in mangaIds) {
          final other = await CrossDeviceAwarenessService.instance
              .getRecentProcessor('manga', id.toString());
          if (other != null) {
            debugPrint(
              '[SyncManager] manga $id also synced recently by device $other',
            );
          }
        }
      }

      _lastSyncTimestamp = DateTime.now();
      await isarService.saveLastSyncTimestamp(_lastSyncTimestamp!);

      final conflicts = applyResult.conflicts.isNotEmpty
          ? applyResult.conflicts
          : deltaResult.conflicts;
      _pendingConflicts = conflicts;

      final result = applyResult.copyWith(
        lastSyncTimestamp: _lastSyncTimestamp,
        conflicts: conflicts,
      );

      _emitProgress(const SyncProgress(
        phase: SyncPhase.completed,
        current: 100,
        total: 100,
      ));

      return _finish(result);
    } catch (e, stack) {
      debugPrint('[SyncManager] Delta sync failed: $e\n$stack');
      _emitProgress(const SyncProgress(
        phase: SyncPhase.failed,
        current: 0,
        total: 100,
      ));
      return _finish(SyncResult(
        success: false,
        errors: ['Sync failed: $e'],
      ));
    } finally {
      _isSyncing = false;
    }
  }

  /// Full library delta from epoch (still SyncEngine.fetchDelta + apply).
  Future<SyncResult> syncFull() async {
    return syncDelta(since: DateTime.fromMillisecondsSinceEpoch(0));
  }

  /// Selective manga sync via SyncEngine (`serverId` ints).
  Future<SyncResult> syncManga(Set<int> mangaIds) async {
    if (_isSyncing || syncEngine.isSyncing) {
      return const SyncResult(
        success: false,
        errors: ['Sync already in progress'],
      );
    }

    _isSyncing = true;
    _cancelRequested = false;
    _emitProgress(const SyncProgress(
      phase: SyncPhase.fetchingManga,
      current: 10,
      total: 100,
      currentManga: 'Selective manga sync',
    ));

    try {
      final authValid = await ServerAuthHelper.validateAndRefreshAuth();
      if (!authValid) {
        return _finish(const SyncResult(
          success: false,
          errors: ['Authentication failed'],
        ));
      }

      final result = await syncEngine.syncMangaByIds(mangaIds);
      if (result.success) {
        _lastSyncTimestamp = DateTime.now();
        await isarService.saveLastSyncTimestamp(_lastSyncTimestamp!);
      }
      _pendingConflicts = result.conflicts;
      _emitProgress(SyncProgress(
        phase: result.success ? SyncPhase.completed : SyncPhase.failed,
        current: 100,
        total: 100,
      ));
      return _finish(result.copyWith(lastSyncTimestamp: _lastSyncTimestamp));
    } catch (e, stack) {
      debugPrint('[SyncManager] syncManga failed: $e\n$stack');
      return _finish(SyncResult(success: false, errors: ['$e']));
    } finally {
      _isSyncing = false;
    }
  }

  /// Selective category sync via SyncEngine.
  Future<SyncResult> syncCategories(Set<int> categoryIds) async {
    if (_isSyncing || syncEngine.isSyncing) {
      return const SyncResult(
        success: false,
        errors: ['Sync already in progress'],
      );
    }

    _isSyncing = true;
    _cancelRequested = false;
    _emitProgress(const SyncProgress(
      phase: SyncPhase.fetchingCategories,
      current: 10,
      total: 100,
    ));

    try {
      final result = await syncEngine.syncCategoriesByIds(categoryIds);
      _pendingConflicts = result.conflicts;
      _emitProgress(SyncProgress(
        phase: result.success ? SyncPhase.completed : SyncPhase.failed,
        current: 100,
        total: 100,
      ));
      return _finish(result);
    } catch (e, stack) {
      debugPrint('[SyncManager] syncCategories failed: $e\n$stack');
      return _finish(SyncResult(success: false, errors: ['$e']));
    } finally {
      _isSyncing = false;
    }
  }

  /// Apply per-field user picks from [ConflictResolutionDialog].
  Future<SyncResult> applyUserResolutions(
    SyncConflict conflict,
    Map<String, ConflictResolution> resolutions,
  ) async {
    try {
      if (resolutions.isEmpty && conflict.field.isNotEmpty) {
        return const SyncResult(success: true);
      }

      if (conflict.field.isNotEmpty) {
        final resolution =
            resolutions[conflict.field] ?? ConflictResolution.userChoice;
        final value = pickConflictValue(
          resolution: resolution,
          localData: conflict.localData,
          remoteData: conflict.remoteData,
          entityType: conflict.entityType,
          field: conflict.field,
        );
        if (value != null) {
          await syncEngine.applyResolvedConflict(conflict, value);
        }
      } else if (conflict.localData is Map && conflict.remoteData is Map) {
        final localMap = conflict.localData as Map;
        final remoteMap = conflict.remoteData as Map;
        for (final entry in resolutions.entries) {
          final field = entry.key;
          final value = pickConflictValue(
            resolution: entry.value,
            localData: localMap[field],
            remoteData: remoteMap[field],
            entityType: conflict.entityType,
            field: field,
          );
          if (value == null) continue;
          await syncEngine.applyResolvedConflict(
            SyncConflict(
              entityType: conflict.entityType,
              entityId: conflict.entityId,
              field: field,
              localData: localMap[field],
              remoteData: remoteMap[field],
              localTimestamp: conflict.localTimestamp,
              remoteTimestamp: conflict.remoteTimestamp,
            ),
            value,
          );
        }
      }

      _pendingConflicts = _pendingConflicts
          .where((c) =>
              !(c.entityType == conflict.entityType &&
                  c.entityId == conflict.entityId &&
                  c.field == conflict.field))
          .toList();

      return const SyncResult(success: true);
    } catch (e, stack) {
      debugPrint('[SyncManager] applyUserResolutions failed: $e\n$stack');
      return SyncResult(success: false, errors: ['$e']);
    }
  }

  /// Batch-resolve remaining conflicts with a strategy.
  Future<SyncResult> resolveAllWithStrategy(
    ConflictResolutionStrategy strategy,
  ) async {
    if (_pendingConflicts.isEmpty) {
      return const SyncResult(success: true);
    }
    _emitProgress(const SyncProgress(
      phase: SyncPhase.resolvingConflicts,
      current: 0,
      total: 100,
    ));
    final result = await syncEngine.resolveConflicts(
      _pendingConflicts,
      resolver: ConflictResolver(strategy: strategy),
    );
    if (result.success) {
      _pendingConflicts = const [];
    }
    return result;
  }

  /// Request cancellation between SyncEngine stages (best-effort).
  void cancelAll() {
    _cancelRequested = true;
  }

  void dispose() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = null;
    if (!_progressController.isClosed) _progressController.close();
    if (!_resultController.isClosed) _resultController.close();
    _initialized = false;
  }

  SyncResult _finish(SyncResult result) {
    if (!_resultController.isClosed) {
      _resultController.add(result);
    }
    return result;
  }

  void _scheduleAutoSync() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = Timer.periodic(config.autoSyncInterval, (_) async {
      if (!_isSyncing && !syncEngine.isSyncing) {
        await syncDelta();
      }
    });
  }

  void _emitProgress(SyncProgress progress) {
    if (!_progressController.isClosed) {
      _progressController.add(progress);
    }
  }
}
