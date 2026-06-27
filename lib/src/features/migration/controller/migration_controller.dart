// Copyright (c) 2022 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../global_providers/global_providers.dart';
import '../../../utils/extensions/custom_extensions.dart';
import '../../browse_center/data/source_repository/source_repository.dart';
import '../../browse_center/domain/source/source_model.dart';
import '../../browse_center/presentation/source/controller/source_controller.dart';
import '../../history/presentation/history_controller.dart';
import '../../library/presentation/category/controller/edit_category_controller.dart';
import '../../library/presentation/library/controller/library_controller.dart';
import '../../manga_book/data/local_downloads/local_downloads_service.dart';
import '../../manga_book/domain/manga/graphql/__generated__/fragment.graphql.dart';
import '../../manga_book/domain/manga/manga_model.dart';
import '../../manga_book/presentation/manga_details/controller/manga_details_controller.dart';
import '../../tracking/presentation/controller/tracker_controller.dart';
import '../data/migration_messages.dart';
import '../data/migration_repository.dart';
import '../domain/migration_models.dart';

part 'migration_controller.g.dart';

typedef PendingBatchMigration = ({
  Map<MangaDto, MangaDto> pairs,
  MigrationOption options,
});

final pendingBatchMigrationProvider =
    StateProvider<PendingBatchMigration?>((ref) => null);

@riverpod
class MigrationSources extends _$MigrationSources {
  @override
  Future<List<MigrationSource>?> build({required int mangaId}) async {
    return ref.watch(migrationRepositoryProvider).getMigrationSources(mangaId);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

@riverpod
class MigrationSearch extends _$MigrationSearch {
  @override
  Future<List<Fragment$MangaDto>?> build({
    required String sourceId,
    required String query,
  }) async {
    if (query.isEmpty) return [];

    return ref
        .watch(migrationRepositoryProvider)
        .searchMangaInSource(sourceId, query);
  }

  Future<void> search(String sourceId, String query) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      return await ref
          .read(migrationRepositoryProvider)
          .searchMangaInSource(sourceId, query);
    });
  }

  void clearResults() {
    state = const AsyncData([]);
  }
}

// Migration Quick Search Results similar to regular global search
typedef MigrationQuickSearchResults = ({
  SourceDto source,
  AsyncValue<List<MangaDto>> mangaList
});

@riverpod
Future<List<MangaDto>> migrationSourceQuickSearchMangaList(
  Ref ref,
  String sourceId, {
  String? query,
}) async {
  final rateLimiterQueue = ref.watch(rateLimitQueueProvider(query));
  final mangaPage = await rateLimiterQueue
      .add(() => ref.watch(sourceRepositoryProvider).fetchSourceManga(
            page: 1,
            sourceId: sourceId,
            sourceType: SourceType.SEARCH,
            query: query,
          ));
  return [...?(mangaPage?.mangas)];
}

@riverpod
AsyncValue<List<MigrationQuickSearchResults>> migrationGlobalSearchResults(
    Ref ref,
    {String? query}) {
  final trimmed = query?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return const AsyncData([]);
  }

  final sourceMapData = ref.watch(sourceMapFilteredProvider);

  final sourceMap = <String, List<SourceDto>>{...?sourceMapData.valueOrNull}
    ..remove("lastUsed");
  final sourceList = sourceMap.values.fold(
    <SourceDto>[],
    (prev, cur) => [...prev, ...cur],
  );
  final List<MigrationQuickSearchResults> sourceMangaListPairList = [];
  for (SourceDto source in sourceList) {
    if (source.id.isNotBlank) {
      final mangaList = ref.watch(
        migrationSourceQuickSearchMangaListProvider(source.id, query: trimmed),
      );
      sourceMangaListPairList.add((mangaList: mangaList, source: source));
    }
  }

  return sourceMapData.copyWithData((_) => sourceMangaListPairList);
}

@riverpod
class MigrationExecution extends _$MigrationExecution {
  bool _cancelRequested = false;

  @override
  MigrationProgress? build() => null;

  bool get _isCancelled =>
      _cancelRequested || state?.status == MigrationStatus.cancelled;

  void _setCancelledState({bool serverChangesApplied = false}) {
    state = MigrationProgress(
      currentStep: MigrationStep.migrationCancelled,
      status: MigrationStatus.cancelled,
      serverChangesApplied: serverChangesApplied,
      processedItems: state?.processedItems ?? 0,
      totalItems: state?.totalItems ?? 0,
    );
  }

  Future<MigrationResult?> executeMigration({
    required int fromMangaId,
    required int toMangaId,
    required MigrationOption options,
    BuildContext? context,
  }) async {
    final msgs = MigrationMessages.fromContext(context);
    _cancelRequested = false;
    try {
      state = const MigrationProgress(
        currentStep: MigrationStep.preparingMigration,
        percentage: 0.0,
        status: MigrationStatus.preparing,
      );

      if (_isCancelled) {
        _setCancelledState();
        return null;
      }

      state = const MigrationProgress(
        currentStep: MigrationStep.migrationInProgress,
        percentage: 50.0,
        status: MigrationStatus.migrating,
      );

      if (_isCancelled) {
        _setCancelledState();
        return null;
      }

      final result = await ref
          .read(migrationRepositoryProvider)
          .migrateManga(fromMangaId, toMangaId, options, msgs);

      if (_isCancelled) {
        final applied = result?.success == true;
        if (applied) {
          await _invalidateCachesAfterMigration(fromMangaId, toMangaId);
        }
        _setCancelledState(serverChangesApplied: applied);
        return applied ? result : null;
      }

      // Update final progress based on result
      if (result?.success == true) {
        state = MigrationProgress(
          currentStep: MigrationStep.migrationCompleted,
          percentage: 100.0,
          status: MigrationStatus.completed,
          warnings: result?.warnings ?? const [],
        );

        await _invalidateCachesAfterMigration(fromMangaId, toMangaId);
      } else {
        state = MigrationProgress(
          currentStep: MigrationStep.migrationFailed,
          percentage: 0.0,
          status: MigrationStatus.error,
          errorMessage: result?.error,
        );
      }

      return result;
    } catch (e) {
      state = MigrationProgress(
        currentStep: MigrationStep.migrationFailed,
        status: MigrationStatus.error,
        errorMessage: msgs.migrationFailed('$e'),
      );
      return null;
    }
  }

  Future<void> cancelMigration() async {
    _cancelRequested = true;
    try {
      await ref.read(migrationRepositoryProvider).cancelMigration();
    } catch (_) {}
    final current = state;
    if (current != null &&
        (current.status == MigrationStatus.migrating ||
            current.status == MigrationStatus.preparing)) {
      state = current.copyWith(
        status: MigrationStatus.cancelled,
        currentStep: MigrationStep.migrationCancelled,
      );
    }
  }

  Future<void> executeBatchMigration(
    Map<MangaDto, MangaDto> matchedMangas,
    MigrationOption options, {
    BuildContext? context,
  }) async {
    final msgs = MigrationMessages.fromContext(context);
    _cancelRequested = false;
    state = const MigrationProgress(
      currentStep: MigrationStep.preparingMigration,
      percentage: 0.0,
      status: MigrationStatus.preparing,
      processedItems: 0,
      totalItems: 0,
    );

    int count = 0;
    int successCount = 0;
    int failedCount = 0;
    final warnings = <String>[];
    final int total = matchedMangas.length;

    // Guard against empty map to prevent divide-by-zero (NaN percentage).
    if (total == 0) {
      state = const MigrationProgress(
        currentStep: MigrationStep.migrationCompleted,
        percentage: 100.0,
        status: MigrationStatus.completed,
        processedItems: 0,
        totalItems: 0,
      );
      return;
    }

    for (final entry in matchedMangas.entries) {
      if (_isCancelled) {
        _setCancelledState(
          serverChangesApplied: successCount > 0,
        );
        return;
      }

      final fromManga = entry.key;
      final toManga = entry.value;

      state = MigrationProgress(
        currentStep: MigrationStep.migrationInProgress,
        percentage: (count / total) * 100,
        status: MigrationStatus.migrating,
        processedItems: count,
        totalItems: total,
      );

      if (_isCancelled) {
        _setCancelledState(serverChangesApplied: successCount > 0);
        return;
      }

      final result = await ref
          .read(migrationRepositoryProvider)
          .migrateManga(fromManga.id, toManga.id, options, msgs);

      if (result?.success == true) {
        successCount++;
        warnings.addAll(result?.warnings ?? const []);
        await _invalidateCachesAfterMigration(fromManga.id, toManga.id);
      } else {
        failedCount++;
      }

      if (_isCancelled) {
        state = MigrationProgress(
          currentStep: MigrationStep.migrationCancelled,
          status: MigrationStatus.cancelled,
          serverChangesApplied: successCount > 0,
          processedItems: successCount,
          totalItems: total,
        );
        return;
      }

      count++;

      // Update intermediate progress
      state = MigrationProgress(
        currentStep: MigrationStep.migrationInProgress,
        percentage: (count / total) * 100,
        status: MigrationStatus.migrating,
        processedItems: count,
        totalItems: total,
      );
    }

    if (failedCount > 0) {
      state = MigrationProgress(
        currentStep: MigrationStep.migrationFailed,
        percentage: 100.0,
        status: MigrationStatus.error,
        processedItems: successCount,
        totalItems: total,
        warnings: warnings,
        errorMessage: failedCount == total
            ? null
            : '$successCount/$total succeeded',
      );
      return;
    }

    state = MigrationProgress(
      currentStep: MigrationStep.migrationCompleted,
      percentage: 100.0,
      status: MigrationStatus.completed,
      processedItems: successCount,
      totalItems: total,
      warnings: warnings,
    );
  }

  void reset() {
    _cancelRequested = false;
    state = null;
    ref.read(pendingBatchMigrationProvider.notifier).state = null;
  }

  /// Invalidate caches after successful migration to refresh UI data
  Future<void> _invalidateCachesAfterMigration(
      int fromMangaId, int toMangaId) async {
    try {
      // Invalidate manga details for both source and target manga
      ref.invalidate(mangaWithIdProvider(mangaId: fromMangaId));
      ref.invalidate(mangaWithIdProvider(mangaId: toMangaId));

      // Invalidate chapter lists for both manga (needed for unread count refresh)
      ref.invalidate(mangaChapterListProvider(mangaId: fromMangaId));
      ref.invalidate(mangaChapterListProvider(mangaId: toMangaId));
      ref.invalidate(readingHistoryProvider);
      ref.invalidate(localDownloadedChapterIdsProvider);
      ref.invalidate(offlineStorageSizeProvider);
      ref.invalidate(mangaTrackRecordsProvider(fromMangaId));
      ref.invalidate(mangaTrackRecordsProvider(toMangaId));

      // Invalidate all category manga lists to refresh library
      final categories = ref.read(categoryControllerProvider).valueOrNull ?? [];
      for (final category in categories) {
        ref.invalidate(categoryMangaListProvider(category.id));
      }
      // Also invalidate the default "All" category (id: 0)
      ref.invalidate(categoryMangaListProvider(0));

      // Small delay to ensure cache invalidation propagates
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      // Don't throw - cache invalidation errors shouldn't fail the migration
    }
  }
}

@riverpod
class MigrationSearchQuery extends _$MigrationSearchQuery {
  @override
  String build() => '';

  void update(String query) {
    state = query;
  }

  void clear() {
    state = '';
  }
}

@riverpod
class SelectedMigrationSource extends _$SelectedMigrationSource {
  @override
  MigrationSource? build() => null;

  void select(MigrationSource source) {
    state = source;
  }

  void clear() {
    state = null;
  }
}

@riverpod
class SelectedTargetManga extends _$SelectedTargetManga {
  @override
  Fragment$MangaDto? build() => null;

  void select(Fragment$MangaDto manga) {
    state = manga;
  }

  void clear() {
    state = null;
  }
}

@riverpod
class MigrationOptions extends _$MigrationOptions {
  @override
  MigrationOption build() => const MigrationOption();

  void update(MigrationOption options) {
    state = options;
  }

  void updateChapters(bool value) {
    state = state.copyWith(migrateChapters: value);
  }

  void updateCategories(bool value) {
    state = state.copyWith(migrateCategories: value);
  }

  void updateDownloads(bool value) {
    state = state.copyWith(migrateDownloads: value);
  }

  void updateTracking(bool value) {
    state = state.copyWith(migrateTracking: value);
  }

  void updateDeleteSource(bool value) {
    state = state.copyWith(deleteSource: value);
  }

  void reset() {
    state = const MigrationOption();
  }
}
