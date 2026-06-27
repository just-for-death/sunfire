// Copyright (c) 2022 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:graphql/client.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../global_providers/global_providers.dart';
import '../../../graphql/__generated__/schema.graphql.dart';
import '../../../utils/extensions/custom_extensions.dart';
import '../../manga_book/data/manga_book/manga_book_repository.dart';
import '../../manga_book/domain/chapter_batch/chapter_batch_model.dart';
import '../domain/history_item.dart';
import 'graphql/__generated__/query.graphql.dart';

part 'history_repository.g.dart';

/// Result of a paginated history fetch using raw chapter offsets.
class ReadingHistoryPage {
  const ReadingHistoryPage({
    required this.items,
    required this.nextRawOffset,
    required this.hasMore,
  });

  final List<HistoryItemDto> items;
  final int nextRawOffset;
  final bool hasMore;
}

class HistoryRepository {
  const HistoryRepository(this.client, this.mangaBookRepository);
  final GraphQLClient client;
  final MangaBookRepository mangaBookRepository;

  /// Fetch one page of deduplicated reading history (one entry per manga).
  ///
  /// [rawOffset] is the GraphQL offset into the raw chapter list.
  /// [excludeMangaIds] skips mangas already loaded in prior pages.
  Future<ReadingHistoryPage> fetchReadingHistoryPage({
    int rawOffset = 0,
    Set<int> excludeMangaIds = const {},
    int targetCount = 50,
    String? searchQuery,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    const rawBatchSize = 200;
    final collected = <HistoryItemDto>[];
    final seenMangaIds = {...excludeMangaIds};
    var offset = rawOffset;
    var lastBatchFull = true;

    while (collected.length < targetCount && lastBatchFull) {
      final batch = await _fetchRawHistoryChapters(
        rawOffset: offset,
        rawBatchSize: rawBatchSize,
        searchQuery: searchQuery,
        fromDate: fromDate,
        toDate: toDate,
      );

      if (batch.isEmpty) {
        lastBatchFull = false;
        break;
      }

      for (final chapter in batch) {
        final mangaId = chapter.mangaId;
        if (seenMangaIds.contains(mangaId)) continue;
        seenMangaIds.add(mangaId);
        collected.add(chapter);
        if (collected.length >= targetCount) break;
      }

      offset += batch.length;
      lastBatchFull = batch.length >= rawBatchSize;
    }

    return ReadingHistoryPage(
      items: collected,
      nextRawOffset: offset,
      hasMore: lastBatchFull,
    );
  }

  Future<List<HistoryItemDto>> _fetchRawHistoryChapters({
    required int rawOffset,
    required int rawBatchSize,
    String? searchQuery,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    // Build filter for chapters with actual reading progress
    final filter = Input$ChapterFilterInput(
      // Only get chapters from library manga
      inLibrary: Input$BooleanFilterInput(equalTo: true),
      // Only get chapters that have been read (lastReadAt is not null/empty)
      lastReadAt: Input$LongFilterInput(
        isNull: false,
        greaterThan:
            "0", // Ensure lastReadAt is actually set to a real timestamp
      ),
      // Only show chapters that have actual reading progress:
      // Either fully read OR have made progress beyond the first page
      or: [
        // Fully completed chapters
        Input$ChapterFilterInput(
          isRead: Input$BooleanFilterInput(equalTo: true),
        ),
        // Chapters with meaningful reading progress (at least 1 page read)
        Input$ChapterFilterInput(
          lastPageRead: Input$IntFilterInput(greaterThan: 0),
        ),
      ],
      // Additional filters
      and: [
        // Add date range filtering if provided
        if (fromDate != null)
          Input$ChapterFilterInput(
            lastReadAt: Input$LongFilterInput(
              greaterThanOrEqualTo: fromDate.millisecondsSinceEpoch.toString(),
            ),
          ),
        if (toDate != null)
          Input$ChapterFilterInput(
            lastReadAt: Input$LongFilterInput(
              lessThanOrEqualTo: toDate.millisecondsSinceEpoch.toString(),
            ),
          ),
        // Add search filtering if provided
        if (searchQuery.isNotBlank)
          Input$ChapterFilterInput(
            or: [
              // Search in chapter name
              Input$ChapterFilterInput(
                name: Input$StringFilterInput(
                  includesInsensitive: searchQuery,
                ),
              ),
              // Note: We can't search manga title directly in chapter filter
              // This will be handled in the UI layer
            ],
          ),
      ],
    );

    // Order by lastReadAt descending (most recent first)
    final order = [
      Input$ChapterOrderInput(
        by: Enum$ChapterOrderBy.LAST_READ_AT,
        byType: Enum$SortOrder.DESC,
      ),
      // Secondary sort by source order for consistency
      Input$ChapterOrderInput(
        by: Enum$ChapterOrderBy.SOURCE_ORDER,
        byType: Enum$SortOrder.DESC,
      ),
    ];

    final result = await client
        .query$GetReadingHistory(
          Options$Query$GetReadingHistory(
            variables: Variables$Query$GetReadingHistory(
              first: rawBatchSize,
              offset: rawOffset,
              filter: filter,
              order: order,
            ),
          ),
        )
        .getData((data) => data.chapters);

    if (result?.nodes == null) return const [];

    return result!.nodes.where((chapter) {
      final isFullyRead = chapter.isRead;
      final hasProgress = chapter.lastPageRead > 0;
      return isFullyRead || hasProgress;
    }).toList();
  }

  /// Get reading history for a specific manga
  Future<List<HistoryItemDto>?> getMangaReadingHistory({
    required int mangaId,
    int limit = 20,
  }) async {
    final filter = Input$ChapterFilterInput(
      mangaId: Input$IntFilterInput(equalTo: mangaId),
      lastReadAt: Input$LongFilterInput(isNull: false),
    );

    final order = [
      Input$ChapterOrderInput(
        by: Enum$ChapterOrderBy.LAST_READ_AT,
        byType: Enum$SortOrder.DESC,
      ),
    ];

    return client
        .query$GetReadingHistory(
          Options$Query$GetReadingHistory(
            variables: Variables$Query$GetReadingHistory(
              first: limit,
              filter: filter,
              order: order,
            ),
          ),
        )
        .getData((data) => data.chapters.nodes);
  }

  /// Clear reading history for a specific chapter
  Future<void> removeChapterFromHistory(int chapterId) async {
    // Mark the chapter as unread and reset progress
    // This should remove it from history queries since our filter requires:
    // either isRead: true OR lastPageRead > 0
    await mangaBookRepository.putChapter(
      chapterId: chapterId,
      patch: ChapterChange(
        isRead: false, // Set to false (not fully read)
        lastPageRead: 0, // Reset to 0 (no progress)
        // Note: lastReadAt cannot be cleared via this API
        // Some chapters may still appear until server is restarted
      ),
    );
  }
}

@riverpod
HistoryRepository historyRepository(Ref ref) => HistoryRepository(
    ref.watch(graphQlClientProvider), ref.watch(mangaBookRepositoryProvider));
