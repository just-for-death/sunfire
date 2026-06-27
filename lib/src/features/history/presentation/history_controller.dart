// Copyright (c) 2022 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../constants/db_keys.dart';
import '../../../utils/extensions/custom_extensions.dart';
import '../../../utils/mixin/shared_preferences_client_mixin.dart';
import '../data/history_repository.dart';
import '../domain/history_group.dart';
import '../domain/history_item.dart';

part 'history_controller.g.dart';

final historyHasMoreProvider = StateProvider<bool>((ref) => true);

@riverpod
class ReadingHistory extends _$ReadingHistory {
  static const _pageSize = 50;

  int _rawOffset = 0;
  final Set<int> _loadedMangaIds = {};
  bool _loadingMore = false;

  void _resetPagination() {
    _rawOffset = 0;
    _loadedMangaIds.clear();
    ref.read(historyHasMoreProvider.notifier).state = true;
  }

  DateTime? _retentionFromDate() {
    final days = ref.read(historyRetentionDaysProvider);
    if (days == null || days <= 0) return null;
    return DateTime.now().subtract(Duration(days: days));
  }

  String? _activeSearchQuery() {
    final query = ref.read(historySearchQueryProvider);
    return query.isBlank ? null : query;
  }

  Future<List<HistoryItemDto>?> _fetchFirstPage() async {
    _resetPagination();
    final hidden = ref.read(historyHiddenChapterIdsProvider) ?? const [];
    final page = await ref.read(historyRepositoryProvider).fetchReadingHistoryPage(
          targetCount: _pageSize,
          searchQuery: _activeSearchQuery(),
          fromDate: _retentionFromDate(),
        );
    _rawOffset = page.nextRawOffset;
    for (final item in page.items) {
      if (hidden.contains(item.id)) continue;
      _loadedMangaIds.add(item.mangaId);
    }
    ref.read(historyHasMoreProvider.notifier).state = page.hasMore;
    return page.items.where((item) => !hidden.contains(item.id)).toList();
  }

  @override
  Future<List<HistoryItemDto>?> build() async {
    final enabled = ref.watch(historyEnabledProvider) ?? true;
    if (!enabled) {
      ref.keepAlive();
      return const [];
    }

    // Refetch when search, retention, or hidden set changes.
    ref.watch(historySearchQueryProvider);
    ref.watch(historyRetentionDaysProvider);
    ref.watch(historyHiddenChapterIdsProvider);

    final nodes = await _fetchFirstPage();
    ref.keepAlive();
    return nodes;
  }

  bool get isLoadingMore => _loadingMore;

  Future<void> refresh() async {
    state = const AsyncLoading();

    final result = await AsyncValue.guard(_fetchFirstPage);

    ref.keepAlive();
    state = result.when(
      data: (nodes) => AsyncData(nodes),
      error: (error, stackTrace) => AsyncError(error, stackTrace),
      loading: () => const AsyncLoading(),
    );
  }

  Future<void> loadMore() async {
    if (_loadingMore || !ref.read(historyHasMoreProvider)) return;
    final currentItems = state.valueOrNull;
    if (currentItems == null) return;

    _loadingMore = true;
    try {
      final hidden = ref.read(historyHiddenChapterIdsProvider) ?? const [];
      final page = await ref.read(historyRepositoryProvider).fetchReadingHistoryPage(
            rawOffset: _rawOffset,
            excludeMangaIds: _loadedMangaIds,
            targetCount: _pageSize,
            searchQuery: _activeSearchQuery(),
            fromDate: _retentionFromDate(),
          );

      if (page.items.isEmpty) {
        ref.read(historyHasMoreProvider.notifier).state = false;
        return;
      }

      _rawOffset = page.nextRawOffset;
      for (final item in page.items) {
        if (hidden.contains(item.id)) continue;
        _loadedMangaIds.add(item.mangaId);
      }
      ref.read(historyHasMoreProvider.notifier).state = page.hasMore;

      final existingIds = currentItems.map((e) => e.id).toSet();
      final merged = [
        ...currentItems,
        ...page.items.where(
          (e) => !existingIds.contains(e.id) && !hidden.contains(e.id),
        ),
      ];
      state = AsyncData(merged);
    } finally {
      _loadingMore = false;
    }
  }

  /// Remove a chapter from reading history
  Future<void> removeFromHistory(int chapterId) async {
    state = await AsyncValue.guard(() async {
      final currentItems = state.valueOrNull ?? [];
      HistoryItemDto? chapterToRemove;

      try {
        chapterToRemove =
            currentItems.firstWhere((item) => item.id == chapterId);
      } catch (e) {
        // Chapter not found in current list, continue anyway
      }

      // Server has no history-removal API; resetting progress would wipe
      // read state and refresh lastReadAt. Hide client-side instead.
      ref.read(historyHiddenChapterIdsProvider.notifier).hideChapter(chapterId);

      // Optimistically remove from local list; full refresh resets pagination.
      final filtered =
          currentItems.where((item) => item.id != chapterId).toList();
      if (chapterToRemove != null) {
        _loadedMangaIds.remove(chapterToRemove.mangaId);
      }
      return filtered;
    });
  }
}

@riverpod
class MangaReadingHistory extends _$MangaReadingHistory {
  @override
  Future<List<HistoryItemDto>?> build({required int mangaId}) async {
    return ref
        .watch(historyRepositoryProvider)
        .getMangaReadingHistory(mangaId: mangaId);
  }

  Future<void> refresh() async {
    final result = await AsyncValue.guard(
      () => ref
          .read(historyRepositoryProvider)
          .getMangaReadingHistory(mangaId: mangaId),
    );

    state = result;
  }
}

@riverpod
List<HistoryGroup> historyGroupedByDate(Ref ref) {
  var historyItems = ref.watch(readingHistoryProvider).valueOrNull ?? [];
  final historyEnabled = ref.watch(historyEnabledProvider) ?? true;
  if (!historyEnabled) return [];

  final retentionDays = ref.watch(historyRetentionDaysProvider);
  if (retentionDays != null && retentionDays > 0) {
    final cutoff = DateTime.now().subtract(Duration(days: retentionDays));
    historyItems = historyItems.where((item) {
      final readAt = item.readAt;
      if (readAt == null) return true;
      return !readAt.isBefore(cutoff);
    }).toList();
  }

  if (historyItems.isEmpty) return [];

  final Map<String, List<HistoryItemDto>> groupedItems = {};

  for (final item in historyItems) {
    final groupKey = item.readDateGroupKey;
    groupedItems.putIfAbsent(groupKey, () => []).add(item);
  }

  final groups = groupedItems.entries.map((entry) {
    return HistoryGroup(
      title: entry.key,
      items: entry.value,
    );
  }).toList();

  groups.sort((a, b) {
    final aDate = a.mostRecentReadDate;
    final bDate = b.mostRecentReadDate;

    if (aDate == null && bDate == null) return 0;
    if (aDate == null) return 1;
    if (bDate == null) return -1;

    return bDate.compareTo(aDate);
  });

  return groups;
}

@riverpod
List<HistoryGroup> filteredHistoryGroups(Ref ref) {
  final groups = ref.watch(historyGroupedByDateProvider);
  final searchQuery = ref.watch(historySearchQueryProvider);

  if (searchQuery.isBlank) return groups;

  final filteredGroups = groups
      .map((group) => group.filterByQuery(searchQuery))
      .where((group) => group.isNotEmpty)
      .toList();

  return filteredGroups;
}

@riverpod
class HistorySearchQuery extends _$HistorySearchQuery {
  @override
  String build() => '';

  void updateQuery(String query) {
    state = query;
  }

  void clearQuery() {
    state = '';
  }
}

@riverpod
class HistoryRetentionDays extends _$HistoryRetentionDays
    with SharedPreferenceClientMixin<int> {
  @override
  int? build() => initialize(DBKeys.historyRetentionDays);

  void updateRetentionDays(int days) {
    update(days);
    ref.invalidate(readingHistoryProvider);
  }
}

@riverpod
class HistoryEnabled extends _$HistoryEnabled
    with SharedPreferenceClientMixin<bool> {
  @override
  bool? build() => initialize(DBKeys.historyEnabled);

  void toggleHistory() {
    update(!(state ?? true));
    ref.invalidate(readingHistoryProvider);
  }

  void setEnabled(bool enabled) {
    update(enabled);
    ref.invalidate(readingHistoryProvider);
  }
}

@riverpod
class HistoryHiddenChapterIds extends _$HistoryHiddenChapterIds
    with SharedPreferenceClientMixin<List<int>> {
  @override
  List<int>? build() => initialize(
        DBKeys.historyHiddenChapterIds,
        initial: const <int>[],
        toJson: (value) => value,
        fromJson: (value) =>
            value == null ? const <int>[] : (value as List).cast<int>(),
      );

  void hideChapter(int chapterId) {
    final current = state ?? const [];
    if (current.contains(chapterId)) return;
    update([...current, chapterId]);
  }

  void unhideChapter(int chapterId) {
    final current = state ?? const [];
    if (!current.contains(chapterId)) return;
    update(current.where((id) => id != chapterId).toList());
  }
}
