// lib/src/core/sync/sync_conflict_helpers.dart
//
// Pure helpers for conflict UI → SyncEngine value selection.

import 'conflict_resolver.dart'
    show ConflictResolver, ConflictResolutionStrategy;
import 'sync_engine.dart' show ConflictResolution;

/// Pick the value that should be written for a user/dialog resolution.
///
/// Returns `null` when the resolution still requires a choice ([userChoice]).
dynamic pickConflictValue({
  required ConflictResolution resolution,
  required dynamic localData,
  required dynamic remoteData,
  required String entityType,
  required String field,
}) {
  switch (resolution) {
    case ConflictResolution.localWins:
      return localData;
    case ConflictResolution.remoteWins:
      return remoteData;
    case ConflictResolution.merge:
      return ConflictResolver(strategy: ConflictResolutionStrategy.crdt).resolve(
        entityType: entityType,
        entityId: 0,
        field: field,
        localValue: localData,
        remoteValue: remoteData,
        localTimestamp: DateTime.fromMillisecondsSinceEpoch(0),
        remoteTimestamp: DateTime.now(),
      );
    case ConflictResolution.userChoice:
      return null;
  }
}

/// Human label for sync phase names (tests + dialog).
String syncPhaseLabel(String phaseName) {
  switch (phaseName) {
    case 'initializing':
      return 'Preparing…';
    case 'fetchingDelta':
      return 'Fetching changes…';
    case 'fetchingManga':
      return 'Fetching manga…';
    case 'fetchingChapters':
      return 'Fetching chapters…';
    case 'fetchingCategories':
      return 'Fetching categories…';
    case 'resolvingConflicts':
      return 'Resolving conflicts…';
    case 'applyingChanges':
      return 'Applying changes…';
    case 'uploadingChanges':
      return 'Uploading…';
    case 'completed':
      return 'Done';
    case 'failed':
      return 'Failed';
    default:
      return phaseName;
  }
}
