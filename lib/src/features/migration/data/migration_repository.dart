// Copyright (c) 2022 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:flutter/material.dart';
import 'package:graphql/client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../global_providers/global_providers.dart';
import '../../../graphql/__generated__/schema.graphql.dart';
import '../../../utils/extensions/custom_extensions.dart';
import '../../browse_center/data/source_repository/graphql/__generated__/query.graphql.dart';
import '../../browse_center/domain/source/source_model.dart';
import '../../manga_book/data/local_downloads/local_downloads_service.dart';
import '../../manga_book/data/manga_book/__generated__/query.graphql.dart';
import '../../manga_book/domain/chapter/chapter_model.dart';
import '../../manga_book/domain/manga/graphql/__generated__/fragment.graphql.dart';
import '../../tracking/data/tracker_repository.dart';
import '../domain/migration_models.dart';
import 'migration_messages.dart';
import 'migration_tracking.dart';

part 'migration_repository.g.dart';

abstract class MigrationRepository {
  Future<List<MigrationSource>?> getMigrationSources(int mangaId,
      [BuildContext? context]);
  Future<List<Fragment$MangaDto>?> searchMangaInSource(
      String sourceId, String query,
      [BuildContext? context]);
  Future<MigrationResult?> migrateManga(
      int fromMangaId, int toMangaId, MigrationOption options,
      [MigrationMessages? messages]);
  Future<void> cancelMigration();
}

class MigrationRepositoryImpl implements MigrationRepository {
  MigrationRepositoryImpl(
    this.client, {
    required this.localDownloads,
    required this.trackerRepository,
  });

  final GraphQLClient client;
  final LocalDownloadsService localDownloads;
  final TrackerRepository trackerRepository;
  bool _migrationCancelled = false;

  bool get _isCancelled => _migrationCancelled;

  @override
  Future<List<MigrationSource>?> getMigrationSources(int mangaId,
      [BuildContext? context]) async {
    try {
      final result = await client.query$SourceList();

      if (result.hasException) {
        throw result.exception!;
      }

      final sources = result.parsedData?.sources.nodes;
      if (sources == null) return null;

      // Convert SourceDto to MigrationSource
      return sources
          .map((source) => MigrationSource(
                id: source.id,
                name: source.displayName,
                lang: source.lang,
                isConfigured: true,
                mangaCount: 0,
                displayName: source.displayName,
                supportsLatest: source.supportsLatest,
              ))
          .toList();
    } catch (e) {
      final errorMessage = context?.l10n.errorGettingMigrationSources ??
          'Failed to get migration sources';
      throw Exception('$errorMessage: $e');
    }
  }

  @override
  Future<List<Fragment$MangaDto>?> searchMangaInSource(
      String sourceId, String query,
      [BuildContext? context]) async {
    return searchMangaInSourcePaginated(sourceId, query, context: context);
  }

  /// Searches up to [maxPages] result pages for a title match.
  Future<List<Fragment$MangaDto>?> searchMangaInSourcePaginated(
    String sourceId,
    String query, {
    BuildContext? context,
    int maxPages = 3,
  }) async {
    try {
      final normalizedQuery = query.toLowerCase().trim();
      final collected = <Fragment$MangaDto>[];
      for (var page = 1; page <= maxPages; page++) {
        final result = await client.mutate$FetchSourceManga(
          Options$Mutation$FetchSourceManga(
            variables: Variables$Mutation$FetchSourceManga(
              input: Input$FetchSourceMangaInput(
                source: sourceId,
                query: query,
                page: page,
                type: SourceType.SEARCH,
              ),
            ),
          ),
        );

        if (result.hasException) {
          throw result.exception!;
        }

        final mangas = result.parsedData?.fetchSourceManga?.mangas ?? [];
        if (mangas.isEmpty) break;

        collected.addAll(mangas);
        final hasExact = mangas.any(
          (m) => m.title.toLowerCase().trim() == normalizedQuery,
        );
        if (hasExact) break;
      }

      return collected;
    } catch (e) {
      final errorMessage = context?.l10n.errorSearchingMangaInSource ??
          'Failed to search manga in source';
      throw Exception('$errorMessage: $e');
    }
  }

  @override
  Future<MigrationResult?> migrateManga(
      int fromMangaId, int toMangaId, MigrationOption options,
      [MigrationMessages? messages]) async {
    final msgs = messages ?? MigrationMessages(null);
    _migrationCancelled = false;
    try {
      // Get source manga information
      final sourceMangaResult = await client.query$GetManga(
        Options$Query$GetManga(
          variables: Variables$Query$GetManga(id: fromMangaId),
        ),
      );

      if (sourceMangaResult.hasException) {
        throw Exception(
            '${msgs.errorFetchingSourceManga}: ${sourceMangaResult.exception}');
      }

      final sourceManga = sourceMangaResult.parsedData?.manga;
      if (sourceManga == null) {
        throw Exception(msgs.errorSourceMangaNotFound);
      }

      // Get target manga information
      final targetMangaResult = await client.query$GetManga(
        Options$Query$GetManga(
          variables: Variables$Query$GetManga(id: toMangaId),
        ),
      );

      if (targetMangaResult.hasException) {
        throw Exception(
            '${msgs.errorFetchingTargetManga}: ${targetMangaResult.exception}');
      }

      final targetManga = targetMangaResult.parsedData?.manga;
      if (targetManga == null) {
        throw Exception(msgs.errorTargetMangaNotFound);
      }

      List<String> warnings = [];
      int migratedChapters = 0;
      int migratedCategories = 0;
      int migratedDownloads = 0;
      var criticalFailure = false;
      String? criticalError;
      List<ChapterDto>? cachedTargetChapters;

      void recordCriticalWarning(String warning) {
        criticalFailure = true;
        criticalError ??= warning;
        warnings.add(warning);
      }

      MigrationResult? cancelledResult() {
        if (!_isCancelled) return null;
        return MigrationResult(
          success: false,
          migratedChapters: migratedChapters,
          migratedCategories: migratedCategories,
          migratedDownloads: migratedDownloads,
          warnings: warnings,
          error: msgs.migrationFailedGeneric,
        );
      }

      // Step 1: Add target manga to library if source manga is in library
      if (sourceManga.inLibrary) {
        final updateLibraryResult = await client.mutate$UpdateManga(
          Options$Mutation$UpdateManga(
            variables: Variables$Mutation$UpdateManga(
              input: Input$UpdateMangaInput(
                id: toMangaId,
                patch: Input$UpdateMangaPatchInput(inLibrary: true),
              ),
            ),
          ),
        );

        if (updateLibraryResult.hasException) {
          recordCriticalWarning(msgs.addToLibraryFailed(
              '${updateLibraryResult.exception}'));
        }
      }

      final afterLibrary = cancelledResult();
      if (afterLibrary != null) return afterLibrary;

      // Step 2: Migrate categories if enabled
      if (options.migrateCategories && sourceManga.inLibrary) {
        try {
          // Get source manga categories
          final sourceCategoriesResult = await client.query$GetMangaCategories(
            Options$Query$GetMangaCategories(
              variables: Variables$Query$GetMangaCategories(id: fromMangaId),
            ),
          );

          if (!sourceCategoriesResult.hasException &&
              sourceCategoriesResult.parsedData != null) {
            final categories =
                sourceCategoriesResult.parsedData!.manga.categories.nodes;

            if (categories.isNotEmpty) {
              List<int> categoryIds = categories.map((cat) => cat.id).toList();

              // Apply the same categories to target manga
              final updateCategoriesResult =
                  await client.mutate$UpdateMangaCategories(
                Options$Mutation$UpdateMangaCategories(
                  variables: Variables$Mutation$UpdateMangaCategories(
                    updateCategoryInput: Input$UpdateMangaCategoriesInput(
                      id: toMangaId,
                      patch: Input$UpdateMangaCategoriesPatchInput(
                        addToCategories: categoryIds,
                      ),
                    ),
                  ),
                ),
              );

              if (updateCategoriesResult.hasException) {
                recordCriticalWarning(msgs.categoriesFailed(
                    '${updateCategoriesResult.exception}'));
              } else {
                migratedCategories = categoryIds.length;
              }
            }
          }
        } catch (e) {
          recordCriticalWarning(msgs.categoryMigrationFailed('$e'));
        }
      }

      final afterCategories = cancelledResult();
      if (afterCategories != null) return afterCategories;

      Future<List<ChapterDto>> fetchTargetChapters() async {
        if (cachedTargetChapters != null) return cachedTargetChapters!;
        final result = await client.mutate$GetChaptersByMangaId(
          Options$Mutation$GetChaptersByMangaId(
            variables: Variables$Mutation$GetChaptersByMangaId(
              input: Input$FetchChaptersInput(mangaId: toMangaId),
            ),
          ),
        );
        cachedTargetChapters =
            result.parsedData?.fetchChapters?.chapters ?? const [];
        return cachedTargetChapters!;
      }

      // Step 3: Migrate reading progress if enabled
      if (options.migrateChapters) {
        try {
          // Get source manga chapters using the correct API
          final sourceChaptersResult = await client.mutate$GetChaptersByMangaId(
            Options$Mutation$GetChaptersByMangaId(
              variables: Variables$Mutation$GetChaptersByMangaId(
                input: Input$FetchChaptersInput(mangaId: fromMangaId),
              ),
            ),
          );

          // Get target manga chapters using the correct API
          final targetChaptersResult = await client.mutate$GetChaptersByMangaId(
            Options$Mutation$GetChaptersByMangaId(
              variables: Variables$Mutation$GetChaptersByMangaId(
                input: Input$FetchChaptersInput(mangaId: toMangaId),
              ),
            ),
          );

          if (!sourceChaptersResult.hasException &&
              !targetChaptersResult.hasException &&
              sourceChaptersResult.parsedData?.fetchChapters?.chapters !=
                  null &&
              targetChaptersResult.parsedData?.fetchChapters?.chapters !=
                  null) {
            final sourceChapters =
                sourceChaptersResult.parsedData!.fetchChapters!.chapters;
            final targetChapters =
                targetChaptersResult.parsedData!.fetchChapters!.chapters;
            cachedTargetChapters = targetChapters;

            // Create a list to batch update read chapters
            List<Input$UpdateChapterInput> chapterUpdates = [];

            // Try to match chapters by multiple criteria for better accuracy
            for (final sourceChapter in sourceChapters) {
              final hasProgress =
                  sourceChapter.isRead || sourceChapter.lastPageRead > 0;
              if (!hasProgress) continue;

              ChapterDto? matchingChapter;

              matchingChapter = targetChapters
                  .where(
                    (chapter) =>
                        (chapter.chapterNumber - sourceChapter.chapterNumber)
                            .abs() <
                        0.01,
                  )
                  .firstOrNull;

              if (matchingChapter == null && sourceChapter.name.isNotEmpty) {
                final sourceName = sourceChapter.name.toLowerCase().trim();
                matchingChapter = targetChapters
                    .where(
                      (chapter) =>
                          chapter.name.toLowerCase().trim() == sourceName,
                    )
                    .firstOrNull;
              }

              if (matchingChapter == null) continue;

              // Never downgrade a fully-read target chapter (Suwayomi uses
              // lastPageRead: 0 when isRead is true).
              if (matchingChapter.isRead && !sourceChapter.isRead) continue;

              final shouldUpdate = sourceChapter.isRead != matchingChapter.isRead ||
                  sourceChapter.lastPageRead > matchingChapter.lastPageRead ||
                  (sourceChapter.isBookmarked &&
                      !matchingChapter.isBookmarked);

              if (shouldUpdate) {
                chapterUpdates.add(
                  Input$UpdateChapterInput(
                    id: matchingChapter.id,
                    patch: Input$UpdateChapterPatchInput(
                      isRead: sourceChapter.isRead,
                      lastPageRead: sourceChapter.isRead
                          ? 0
                          : sourceChapter.lastPageRead,
                      isBookmarked: sourceChapter.isBookmarked ||
                          matchingChapter.isBookmarked,
                    ),
                  ),
                );
              }
            }

            // Batch update chapters if we have any to update
            if (chapterUpdates.isNotEmpty) {
              // Update chapters one by one to avoid overwhelming the server
              for (final updateInput in chapterUpdates) {
                if (_isCancelled) break;
                try {
                  final updateResult = await client.mutate$UpdateChapter(
                    Options$Mutation$UpdateChapter(
                        variables: Variables$Mutation$UpdateChapter(
                            input: updateInput)),
                  );

                  if (!updateResult.hasException) {
                    migratedChapters++;
                  } else {
                    warnings.add(msgs.chapterMigrateFailed(
                        updateInput.id, '${updateResult.exception}'));
                  }
                } catch (e) {
                  warnings.add(
                      msgs.chapterMigrateFailed(updateInput.id, '$e'));
                }
              }
            }

            if (migratedChapters == 0 &&
                sourceChapters.any(
                  (ch) => ch.isRead || ch.lastPageRead > 0,
                )) {
              warnings.add(msgs.noMatchingChapters);
            }
          }
        } catch (e) {
          recordCriticalWarning(msgs.chapterMigrationFailed('$e'));
        }
      }

      final afterChapters = cancelledResult();
      if (afterChapters != null) return afterChapters;

      // Step 3b: Migrate offline downloads if enabled
      if (options.migrateDownloads) {
        try {
          final targetChapters = await fetchTargetChapters();
          final downloadResult = await localDownloads.migrateDownloadsToManga(
            fromMangaId: fromMangaId,
            toMangaId: toMangaId,
            targetMangaTitle: targetManga.title,
            targetChapters: targetChapters,
            onChapterSkipped: (id) => msgs.downloadChapterSkipped(id),
          );
          migratedDownloads = downloadResult.migrated;
          warnings.addAll(downloadResult.warnings);
        } catch (e) {
          warnings.add(msgs.downloadsMigrationFailed('$e'));
        }
      }

      // Step 3c: Migrate tracker bindings if enabled
      if (options.migrateTracking) {
        final trackingResult = await migrateTrackingRecords(
          trackerRepository: trackerRepository,
          fromMangaId: fromMangaId,
          toMangaId: toMangaId,
          messages: msgs,
        );
        warnings.addAll(trackingResult.warnings);
      }

      final afterTracking = cancelledResult();
      if (afterTracking != null) return afterTracking;

      // Step 4: Remove source manga from library if deleteSource is enabled
      if (options.deleteSource && sourceManga.inLibrary) {
        try {
          await client.mutate$UpdateMangaCategories(
            Options$Mutation$UpdateMangaCategories(
              variables: Variables$Mutation$UpdateMangaCategories(
                updateCategoryInput: Input$UpdateMangaCategoriesInput(
                  id: fromMangaId,
                  patch: Input$UpdateMangaCategoriesPatchInput(
                    clearCategories: true,
                  ),
                ),
              ),
            ),
          );
        } catch (e) {
          warnings.add(msgs.clearCategoriesFailed('$e'));
        }

        final removeFromLibraryResult = await client.mutate$UpdateManga(
          Options$Mutation$UpdateManga(
            variables: Variables$Mutation$UpdateManga(
              input: Input$UpdateMangaInput(
                id: fromMangaId,
                patch: Input$UpdateMangaPatchInput(inLibrary: false),
              ),
            ),
          ),
        );

        if (removeFromLibraryResult.hasException) {
          warnings.add(msgs.removeSourceFailed(
              '${removeFromLibraryResult.exception}'));
        } else {
          warnings.add(msgs.removedSourceFromLibrary);
        }
      }

      return MigrationResult(
        success: !criticalFailure,
        migratedChapters: migratedChapters,
        migratedCategories: migratedCategories,
        migratedDownloads: migratedDownloads,
        warnings: warnings,
        error: criticalFailure
            ? (criticalError ?? msgs.completedWithErrors)
            : null,
      );
    } catch (e) {
      return MigrationResult(
        success: false,
        error: msgs.migrationFailed('$e'),
      );
    }
  }

  @override
  Future<void> cancelMigration() async {
    _migrationCancelled = true;
  }
}

@riverpod
MigrationRepository migrationRepository(ref) => MigrationRepositoryImpl(
      ref.watch(graphQlClientProvider),
      localDownloads: ref.watch(localDownloadsServiceProvider),
      trackerRepository: ref.watch(trackerRepositoryProvider),
    );
