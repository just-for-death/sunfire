// Copyright (c) 2026 Contributors to the Catalyst project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import '../../../../../constants/enum.dart';
import '../../../../../utils/extensions/custom_extensions.dart';
import '../../../../manga_book/domain/manga/manga_model.dart';

/// Parse a `fetchedAt` string which may be either a Unix timestamp integer
/// (e.g. "1710500000") or an ISO-8601 date string (e.g. "2024-03-15T10:30:00").
/// Returns milliseconds since epoch for comparison, or 0 as a safe fallback.
int parseFetchedAt(String? fetchedAt) {
  if (fetchedAt == null || fetchedAt.isEmpty) return 0;
  // Try Unix timestamp first (seconds since epoch)
  final asInt = int.tryParse(fetchedAt);
  if (asInt != null) return asInt * 1000; // convert seconds → ms
  // Fall back to ISO-8601
  final asDate = DateTime.tryParse(fetchedAt);
  if (asDate != null) return asDate.millisecondsSinceEpoch;
  return 0;
}

/// Whether a manga survives the library filters.
///
/// The three filters are tri-state: `null` is off, `true` keeps only matches,
/// and `false` keeps only non-matches ("exclude").
bool libraryMangaPassesFilter(
  MangaDto manga, {
  required bool? filterUnread,
  required bool? filterDownloaded,
  required bool? filterCompleted,
  required String? query,
  required Set<int> offlineMangaIds,
}) {
  final hasUnread = manga.unreadCount.isGreaterThan(0);
  if (filterUnread == true && !hasUnread) return false;
  if (filterUnread == false && hasUnread) return false;

  if (filterDownloaded != null) {
    final hasDownloads = manga.downloadCount.isGreaterThan(0) ||
        offlineMangaIds.contains(manga.id);
    if (filterDownloaded != hasDownloads) return false;
  }

  final isCompleted = manga.status.name == 'COMPLETED';
  if (filterCompleted == true && !isCompleted) return false;
  if (filterCompleted == false && isCompleted) return false;

  if (!manga.query(query)) return false;

  return true;
}

/// Comparator for the library list. [ascending] false reverses the order.
int compareLibraryManga(
  MangaDto m1,
  MangaDto m2, {
  required MangaSort sortedBy,
  required bool ascending,
}) {
  final direction = ascending ? 1 : -1;
  return (switch (sortedBy) {
        // Case-insensitive: raw compareTo is code-unit order, which puts every
        // uppercase title ahead of every lowercase one.
        MangaSort.alphabetical =>
          m1.title.toLowerCase().compareTo(m2.title.toLowerCase()),
        MangaSort.unread => m1.unreadCount
            .getValueOnNullOrNegative()
            .compareTo(m2.unreadCount.getValueOnNullOrNegative()),
        MangaSort.dateAdded => m1.inLibraryAt
            .getValueOnNullOrNegative()
            .compareTo(m2.inLibraryAt.getValueOnNullOrNegative()),
        MangaSort.lastUpdated =>
          parseFetchedAt(m1.latestFetchedChapter?.fetchedAt)
              .compareTo(parseFetchedAt(m2.latestFetchedChapter?.fetchedAt)),
      }) *
      direction;
}
