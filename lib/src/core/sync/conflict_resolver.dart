// lib/src/core/sync/conflict_resolver.dart
//
// ConflictResolver - handles merge conflicts using CRDT or LWW strategies
// Part of Phase 1.5: Sync Engine Overhaul

import '../db/models/category.dart';
import '../db/models/chapter.dart';
import '../db/models/manga.dart';
import 'read_state_merge.dart' show mergeChapterReadState;

/// Conflict resolver using various strategies
class ConflictResolver {
  ConflictResolver({
    this.strategy = ConflictResolutionStrategy.lastWriteWins,
    this.customResolver,
  });

  final ConflictResolutionStrategy strategy;
  final ConflictResolverFunction? customResolver;

  /// Resolve a conflict between local and remote data.
  dynamic resolve({
    required String entityType,
    required int entityId,
    required String field,
    required dynamic localValue,
    required dynamic remoteValue,
    required DateTime localTimestamp,
    required DateTime remoteTimestamp,
  }) {
    // Try custom resolver first
    if (customResolver != null) {
      final result = customResolver!(
        entityType: entityType,
        entityId: entityId,
        field: field,
        localValue: localValue,
        remoteValue: remoteValue,
        localTimestamp: localTimestamp,
        remoteTimestamp: remoteTimestamp,
      );
      if (result != null) return result;
    }

    // IMP-032: field-wise merge. Monotonic progress fields never regress under
    // the automatic strategies (LWW / CRDT); explicit server/local/user
    // choices still apply as asked.
    if (strategy == ConflictResolutionStrategy.lastWriteWins || strategy == ConflictResolutionStrategy.crdt) {
      final merged = mergeProgress(field, localValue, remoteValue);
      if (merged != null) return merged;
    }

    // Apply strategy
    switch (strategy) {
      case ConflictResolutionStrategy.lastWriteWins:
        return _resolveLastWriteWins(localValue, remoteValue, localTimestamp, remoteTimestamp);
      
      case ConflictResolutionStrategy.serverWins:
        return remoteValue;
      
      case ConflictResolutionStrategy.localWins:
        return localValue;
      
      case ConflictResolutionStrategy.crdt:
        return _resolveCRDT(entityType, field, localValue, remoteValue);
      
      case ConflictResolutionStrategy.userChoice:
        // Return special marker for user to decide
        return const UserChoiceMarker();
    }
  }

  /// Fields that only move forward (reading progress / timestamps).
  static const Set<String> kMonotonicProgressFields = {
    'lastPageRead', 'progress', 'readCount', 'lastReadAt', 'inLibraryAt', 'lastChapterRead',
  };

  /// IMP-032: per-field merge for [kMonotonicProgressFields] (the higher value
  /// wins, so a stale device can't roll progress back). Null for any other
  /// field, or when neither side is numeric, so the caller's strategy decides.
  static Object? mergeProgress(String field, Object? local, Object? remote) {
    if (!kMonotonicProgressFields.contains(field)) return null;
    if (local is! num && remote is! num) return null;
    return maxProgress(local is num ? local : null, remote is num ? remote : null);
  }

  /// Larger of two progress values; null-tolerant.
  static num? maxProgress(num? a, num? b) {
    if (a == null) return b;
    if (b == null) return a;
    return a >= b ? a : b;
  }

  /// Resolve using last-write-wins (LWW) timestamp comparison
  dynamic _resolveLastWriteWins(
    dynamic localValue,
    dynamic remoteValue,
    DateTime localTimestamp,
    DateTime remoteTimestamp,
  ) {
    if (remoteTimestamp.isAfter(localTimestamp)) {
      return remoteValue;
    }
    return localValue;
  }

  /// Resolve using CRDT (Conflict-free Replicated Data Type) logic
  dynamic _resolveCRDT(String entityType, String field, dynamic localValue, dynamic remoteValue) {
    // For counters (read count, progress): use max
    if (field == 'readCount' || field == 'progress' || field == 'lastPageRead') {
      final local = localValue is num ? localValue : 0;
      final remote = remoteValue is num ? remoteValue : 0;
      return local > remote ? localValue : remoteValue;
    }
    
    // For sets (tags, categories): use union
    if (localValue is Set && remoteValue is Set) {
      return {...localValue, ...remoteValue};
    }
    
    // For lists (tags, custom orders): merge unique
    if (localValue is List && remoteValue is List) {
      final merged = <dynamic>{...localValue, ...remoteValue};
      return merged.toList();
    }
    
    // For booleans: true wins (monotonic)
    if (localValue is bool && remoteValue is bool) {
      return localValue || remoteValue;
    }
    
    // Default to LWW for other types
    return remoteValue; // Would need timestamps for proper CRDT
  }

  /// Resolve Manga entity conflicts
  Manga resolveManga({
    required Manga local,
    required Manga remote,
  }) {
    return Manga()
      ..id = local.id
      ..serverId = remote.serverId > 0 ? remote.serverId : local.serverId
      ..title = _resolveString(local.title, remote.title)
      ..author = _resolveStringNullable(local.author, remote.author)
      ..artist = _resolveStringNullable(local.artist, remote.artist)
      ..description = _resolveStringNullable(local.description, remote.description)
      ..status = _resolveStringNullable(local.status, remote.status)
      ..sourceName = _resolveString(local.sourceName, remote.sourceName)
      ..url = _resolveString(local.url, remote.url)
      ..thumbnailUrl = _resolveStringNullable(local.thumbnailUrl, remote.thumbnailUrl)
      ..readingModeOverride = _resolveStringNullable(local.readingModeOverride, remote.readingModeOverride)
      ..inLibraryAt = _maxDateInt(local.inLibraryAt, remote.inLibraryAt)
      ..categoryIds = _resolveListInt(local.categoryIds, remote.categoryIds);
  }

  List<int> _resolveListInt(List<int> local, List<int> remote) {
    return {...local, ...remote}.toList();
  }

  /// Resolve Chapter entity conflicts
  Chapter resolveChapter({
    required Chapter local,
    required Chapter remote,
  }) {
    final readState = mergeChapterReadState(local, remote);
    return Chapter()
      ..id = local.id
      ..serverId = remote.serverId > 0 ? remote.serverId : local.serverId
      ..mangaId = remote.mangaId > 0 ? remote.mangaId : local.mangaId
      ..name = _resolveString(local.name, remote.name)
      ..chapterNumber = _resolveDouble(local.chapterNumber, remote.chapterNumber)
      ..url = _resolveString(local.url, remote.url)
      ..realUrl = _resolveString(local.realUrl, remote.realUrl)
      ..pageCount = _resolveInt(local.pageCount, remote.pageCount)
      // ISS-141: newest explicit action wins outright; otherwise automatic
      // progress (read OR, furthest page).
      ..isRead = readState.isRead
      ..lastPageRead = readState.lastPageRead
      ..readStateActionAt = readState.actionAt
      ..lastReadAt = _maxDateInt(local.lastReadAt, remote.lastReadAt)
      ..isDownloadedLocally = local.isDownloadedLocally || remote.isDownloadedLocally
      ..isDownloadedOnServer = local.isDownloadedOnServer || remote.isDownloadedOnServer
      ..uploadDate = _maxDateInt(local.uploadDate, remote.uploadDate)
      ..fetchedAt = _maxDateInt(local.fetchedAt, remote.fetchedAt);
  }

  /// Resolve Category entity conflicts
  Category resolveCategory({
    required Category local,
    required Category remote,
  }) {
    return Category()
      ..id = local.id
      ..serverId = remote.serverId > 0 ? remote.serverId : local.serverId
      ..name = _resolveString(local.name, remote.name)
      ..order = _resolveInt(local.order, remote.order)
      ..isDefault = _resolveBool(local.isDefault, remote.isDefault)
      ..isDefaultCategory = _resolveBool(local.isDefaultCategory, remote.isDefaultCategory)
      ..includeInUpdate = _resolveString(local.includeInUpdate, remote.includeInUpdate)
      ..includeInDownload = _resolveString(local.includeInDownload, remote.includeInDownload);
  }

  // ─── Helper Methods ──────────────────────────────────────────────

  String _resolveString(String local, String remote) {
    return remote.isNotEmpty ? remote : local;
  }

  String? _resolveStringNullable(String? local, String? remote) {
    if (remote == null) return local;
    if (local == null) return remote;
    return _resolveString(local, remote);
  }

  int _resolveInt(int local, int remote) {
    return remote;
  }

  double _resolveDouble(double local, double remote) {
    return remote;
  }

  bool _resolveBool(bool local, bool remote) {
    return remote;
  }

  int _maxDateInt(int? a, int? b) {
    if (a == null) return b ?? 0;
    if (b == null) return a;
    return a > b ? a : b;
  }

}

/// Custom conflict resolver function type
typedef ConflictResolverFunction = dynamic Function({
  required String entityType,
  required int entityId,
  required String field,
  required dynamic localValue,
  required dynamic remoteValue,
  required DateTime localTimestamp,
  required DateTime remoteTimestamp,
});

/// Marker for user-choice conflicts (visible for testing)
class UserChoiceMarker {
  const UserChoiceMarker();
}

/// Conflict resolution strategy
enum ConflictResolutionStrategy {
  lastWriteWins,
  serverWins,
  localWins,
  crdt,
  userChoice,
}