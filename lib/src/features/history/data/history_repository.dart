// Copyright (c) 2022 Contributors to the Catalyst project
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
  const HistoryRepository(this.client);
  final GraphQLClient client;

  /// Fetch one page of deduplicated reading history (one entry per manga).
  ///
  /// [rawOffset] is the GraphQL offset into the raw chapter list.
  /// [excludeMangaIds] skips mangas already loaded in prior pages.
  Future<ReadingHistoryPage> fetchReadingHistoryPage({
    int rawOffset = 0,
    Set<int> excludeMangaIds = const {},
    int targetCount = 50,
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
        fromDate: fromDate,
        toDate: toDate,
      );

      if (batch.isEmpty) {
        lastBatchFull = false;
        break;
      }

      // Track how far into the batch we actually got: stopping at [targetCount]
      // mid-batch and then skipping the whole batch would drop every remaining
      // chapter in it from the next page.
      var consumed = 0;
      for (final chapter in batch) {
        consumed++;
        if (!chapter.isRead && chapter.lastPageRead <= 0) continue;
        final mangaId = chapter.mangaId;
        if (seenMangaIds.contains(mangaId)) continue;
        seenMangaIds.add(mangaId);
        collected.add(chapter);
        if (collected.length >= targetCount) break;
      }

      offset += consumed;
      lastBatchFull = consumed < batch.length || batch.length >= rawBatchSize;
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
              greaterThanOrEqualTo:
                  (fromDate.millisecondsSinceEpoch ~/ 1000).toString(),
            ),
          ),
        if (toDate != null)
          Input$ChapterFilterInput(
            lastReadAt: Input$LongFilterInput(
              lessThanOrEqualTo:
                  (toDate.millisecondsSinceEpoch ~/ 1000).toString(),
            ),
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

    // Returned unfiltered on purpose: [rawOffset] indexes the server's result
    // set, so dropping rows here would desync the offset and cut paging short.
    return result?.nodes ?? const [];
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

}

@riverpod
HistoryRepository historyRepository(Ref ref) =>
    HistoryRepository(ref.watch(graphQlClientProvider));
