// lib/src/core/sync/sync_manager.dart
//
// SyncManager — thin orchestrator over SyncEngine (scheduling/UI progress).
// Does NOT implement a second sync engine. Production GraphQL work stays in
// SyncEngine; this layer owns progress streams, cancel flags, and conflict
// hand-off to the UI.

import 'dart:async';

import 'package:flutter/foundation.dart' show debugPrint, visibleForTesting;

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
  ///
  /// ISS-051: a call while a sync is running (here or in [SyncEngine]) is not
  /// dropped. Every busy caller joins ONE queued follow-up per kind
  /// (arguments merged), run once the current sync ends.
  Future<SyncResult> syncDelta({
    DateTime? since,
    Set<int>? mangaIds,
    Set<int>? categoryIds,
  }) {
    if (_busy) {
      final q = _queued['delta'];
      final resolved = since ?? _lastSyncTimestamp ?? DateTime.fromMillisecondsSinceEpoch(0);
      if (q == null) {
        return _enqueue('delta', _QueuedSync(since: resolved, mangaIds: mangaIds, categoryIds: categoryIds));
      }
      q.since = q.since!.isBefore(resolved) ? q.since : resolved;
      q.mangaIds = _mergeIds(q.mangaIds, mangaIds);
      q.categoryIds = _mergeIds(q.categoryIds, categoryIds);
      return q.done.future;
    }
    return _runDelta(since: since, mangaIds: mangaIds, categoryIds: categoryIds);
  }

  Future<SyncResult> _runDelta({
    DateTime? since,
    Set<int>? mangaIds,
    Set<int>? categoryIds,
  }) async {

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

      // A delta needs a starting point; fetchDelta refuses epoch 0. With no
      // previous sync (or an explicit full sync) run the full sync cycle.
      if (effectiveSince.millisecondsSinceEpoch <= 0) {
        _emitProgress(const SyncProgress(phase: SyncPhase.fetchingManga, current: 15, total: 100));
        await syncEngine.triggerSync();
        _lastSyncTimestamp = DateTime.now();
        await isarService.saveLastSyncTimestamp(_lastSyncTimestamp!);
        _emitProgress(const SyncProgress(
          phase: SyncPhase.completed,
          current: 100,
          total: 100,
          currentManga: 'Full library sync complete',
        ));
        return _finish(SyncResult(success: true, lastSyncTimestamp: _lastSyncTimestamp));
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

      final deltaManga = deltaResult.mangaUpdated;
      final deltaChapters = deltaResult.chaptersUpdated;
      _emitProgress(SyncProgress(
        phase: SyncPhase.applyingChanges,
        current: 55,
        total: 100,
        currentManga: deltaManga + deltaChapters > 0
            ? 'Applying $deltaManga manga · $deltaChapters chapters'
            : null,
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

      // S1.5: surface per-run manga/chapter counts on the progress dialog.
      _emitProgress(SyncProgress(
        phase: SyncPhase.completed,
        current: 100,
        total: 100,
        currentManga:
            '${result.mangaUpdated} manga · ${result.chaptersUpdated} chapters updated',
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
      _scheduleDrain(); // ISS-051
    }
  }

  /// Full library sync: the regular SyncEngine cycle (see [_runDelta]).
  Future<SyncResult> syncFull() async {
    return syncDelta(since: DateTime.fromMillisecondsSinceEpoch(0));
  }

  /// Selective manga sync via SyncEngine (`serverId` ints).
  /// ISS-051: queued (ids merged) instead of dropped while busy.
  Future<SyncResult> syncManga(Set<int> mangaIds) {
    if (_busy) {
      final q = _queued['manga'];
      if (q == null) return _enqueue('manga', _QueuedSync(mangaIds: {...mangaIds}));
      q.mangaIds = {...?q.mangaIds, ...mangaIds};
      return q.done.future;
    }
    return _runManga(mangaIds);
  }

  Future<SyncResult> _runManga(Set<int> mangaIds) async {

    _isSyncing = true;
    _cancelRequested = false;
    final idList = mangaIds.toList();
    final labels = <String>[];
    for (final id in idList) {
      final manga = await isarService.getMangaByServerId(id);
      labels.add(manga?.title.trim().isNotEmpty == true
          ? manga!.title
          : 'Manga $id');
    }
    final preview = labels.isEmpty
        ? null
        : (labels.length <= 2
            ? labels.join(', ')
            : '${labels.first} (+${labels.length - 1} more)');
    // S1.5: item-scale progress (not opaque 10→100%) for selective sync.
    _emitProgress(SyncProgress(
      phase: SyncPhase.fetchingManga,
      current: 0,
      total: idList.isEmpty ? 1 : idList.length,
      currentManga: preview,
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
        current: idList.isEmpty ? 1 : idList.length,
        total: idList.isEmpty ? 1 : idList.length,
        currentManga: result.success
            ? '${result.mangaUpdated} manga · ${result.chaptersUpdated} chapters'
            : preview,
      ));
      return _finish(result.copyWith(lastSyncTimestamp: _lastSyncTimestamp));
    } catch (e, stack) {
      debugPrint('[SyncManager] syncManga failed: $e\n$stack');
      return _finish(SyncResult(success: false, errors: ['$e']));
    } finally {
      _isSyncing = false;
      _scheduleDrain(); // ISS-051
    }
  }

  /// Selective category sync via SyncEngine.
  /// ISS-051: queued (ids merged) instead of dropped while busy.
  Future<SyncResult> syncCategories(Set<int> categoryIds) {
    if (_busy) {
      final q = _queued['categories'];
      if (q == null) return _enqueue('categories', _QueuedSync(categoryIds: {...categoryIds}));
      q.categoryIds = {...?q.categoryIds, ...categoryIds};
      return q.done.future;
    }
    return _runCategories(categoryIds);
  }

  Future<SyncResult> _runCategories(Set<int> categoryIds) async {

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
      _scheduleDrain(); // ISS-051
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
    if (!_progressController.isClosed) {
      unawaited(_progressController.close());
    }
    if (!_resultController.isClosed) {
      unawaited(_resultController.close());
    }
    _initialized = false;
  }

  // ── ISS-051: one-deep follow-up queue ─────────────────────────────────
  // Waits on SyncEngine.onSyncCycleComplete when the engine (not this
  // manager) is busy, instead of calling triggerSync — so a queued manager
  // run never adds a second pass to the engine's SyncCycleGate.
  final Map<String, _QueuedSync> _queued = {};
  StreamSubscription<void>? _engineWait;
  bool _drainScheduled = false;

  bool get _busy => _isSyncing || syncEngine.isSyncing;

  /// Pending follow-up kinds ('delta' / 'manga' / 'categories'), for tests.
  @visibleForTesting
  Set<String> get queuedFollowUps => _queued.keys.toSet();

  static Set<int>? _mergeIds(Set<int>? a, Set<int>? b) =>
      (a == null || b == null) ? null : {...a, ...b};

  Future<SyncResult> _enqueue(String kind, _QueuedSync q) {
    _queued[kind] = q;
    if (!_isSyncing) _waitForEngine();
    return q.done.future;
  }

  void _waitForEngine() {
    _engineWait ??= syncEngine.onSyncCycleComplete.listen((_) => _scheduleDrain());
  }

  void _scheduleDrain() {
    if (_queued.isEmpty || _drainScheduled) return;
    _drainScheduled = true;
    scheduleMicrotask(() {
      _drainScheduled = false;
      _drain();
    });
  }

  void _drain() {
    if (_queued.isEmpty) {
      unawaited(_engineWait?.cancel());
      _engineWait = null;
      return;
    }
    if (_busy) {
      if (!_isSyncing) _waitForEngine();
      return; // drained again from the running sync's finally / engine event
    }
    unawaited(_engineWait?.cancel());
    _engineWait = null;
    final kind = _queued.keys.first;
    final q = _queued.remove(kind)!;
    unawaited(() async {
      try {
        final r = await switch (kind) {
          'delta' => _runDelta(since: q.since, mangaIds: q.mangaIds, categoryIds: q.categoryIds),
          'manga' => _runManga(q.mangaIds ?? const {}),
          _ => _runCategories(q.categoryIds ?? const {}),
        };
        q.done.complete(r);
      } catch (e) {
        q.done.complete(SyncResult(success: false, errors: ['$e']));
      }
    }());
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

/// ISS-051: one queued follow-up (merged arguments) and its shared result.
class _QueuedSync {
  _QueuedSync({this.since, this.mangaIds, this.categoryIds});
  DateTime? since;
  Set<int>? mangaIds;
  Set<int>? categoryIds;
  final Completer<SyncResult> done = Completer<SyncResult>();
}
