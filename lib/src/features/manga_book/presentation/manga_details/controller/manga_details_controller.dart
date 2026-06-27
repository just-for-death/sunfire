// Copyright (c) 2022 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../constants/db_keys.dart';
import '../../../../../constants/enum.dart';
import '../../../../../graphql/__generated__/schema.graphql.dart';
import '../../../../../utils/extensions/custom_extensions.dart';
import '../../../../../utils/mixin/shared_preferences_client_mixin.dart';
import '../../../../library/domain/category/category_model.dart';
import '../../../data/local_downloads/local_downloads_service.dart';
import '../../../data/manga_book/manga_book_repository.dart';
import '../../../domain/chapter/chapter_model.dart';
import '../../../domain/chapter/graphql/__generated__/fragment.graphql.dart';
import '../../../domain/manga/manga_model.dart';
import '../chapter_navigation_utils.dart';

part 'manga_details_controller.g.dart';

int _compareChapters(
  ChapterDto m1,
  ChapterDto m2, {
  required ChapterSort sortedBy,
  required bool sortedDirection,
}) {
  final sortDirToggle = sortedDirection ? 1 : -1;
  return (switch (sortedBy) {
        ChapterSort.fetchedDate => (int.tryParse(m1.fetchedAt) ?? 0)
            .compareTo(int.tryParse(m2.fetchedAt) ?? 0),
        ChapterSort.source => m1.index.compareTo(m2.index),
        ChapterSort.uploadDate => (int.tryParse(m1.uploadDate) ?? 0)
            .compareTo(int.tryParse(m2.uploadDate) ?? 0),
      }) *
      sortDirToggle;
}

List<ChapterDto> _sortedChapterList(
  List<ChapterDto> chapters, {
  required ChapterSort sortedBy,
  required bool sortedDirection,
}) {
  return [...chapters]
    ..sort(
      (a, b) => _compareChapters(
        a,
        b,
        sortedBy: sortedBy,
        sortedDirection: sortedDirection,
      ),
    );
}

bool _chapterFiltersActive(
  bool? chapterFilterUnread,
  bool? chapterFilterDownloaded,
  bool? chapterFilterBookmark,
  String chapterFilterScanlator,
) {
  return chapterFilterUnread != null ||
      chapterFilterDownloaded != null ||
      chapterFilterBookmark != null ||
      chapterFilterScanlator != MangaMetaKeys.scanlator.key;
}

bool Function(ChapterDto chapter) _chapterFilterPredicate({
  required bool? chapterFilterUnread,
  required bool? chapterFilterDownloaded,
  required bool? chapterFilterBookmark,
  required String chapterFilterScanlator,
  required Set<int> localDownloadedChapterIds,
}) {
  return (ChapterDto chapter) {
    if (chapterFilterUnread != null &&
        (chapterFilterUnread ^ !(chapter.isRead.ifNull()))) {
      return false;
    }

    if (chapterFilterDownloaded != null) {
      final isDownloaded = chapter.isDownloaded.ifNull() ||
          localDownloadedChapterIds.contains(chapter.id);
      if (chapterFilterDownloaded ^ isDownloaded) return false;
    }

    if (chapterFilterBookmark != null &&
        (chapterFilterBookmark ^ (chapter.isBookmarked.ifNull()))) {
      return false;
    }

    if (chapterFilterScanlator != MangaMetaKeys.scanlator.key &&
        chapter.scanlator != chapterFilterScanlator) {
      return false;
    }
    return true;
  };
}

ChapterDto _mergeOfflineProgress(ChapterDto server, ChapterDto offline) {
  final localAhead = (offline.isRead && !server.isRead) ||
      offline.lastPageRead > server.lastPageRead;
  if (!localAhead) {
    return server.isDownloaded.ifNull() || offline.isDownloaded.ifNull()
        ? server.copyWith(isDownloaded: true)
        : server;
  }
  final isRead = offline.isRead || server.isRead;
  final pageCount =
      server.pageCount > 0 ? server.pageCount : offline.pageCount;
  final lastPageRead = isRead
      ? [
          server.lastPageRead,
          offline.lastPageRead,
          if (pageCount > 0) pageCount - 1 else 0,
        ].reduce((a, b) => a > b ? a : b)
      : offline.lastPageRead > server.lastPageRead
          ? offline.lastPageRead
          : server.lastPageRead;
  return server.copyWith(
    isRead: isRead,
    lastPageRead: lastPageRead,
    isDownloaded: true,
  );
}

List<ChapterDto> _mergeOfflineChapters(
  List<ChapterDto> server,
  List<ChapterDto> offline,
) {
  if (offline.isEmpty) return server;
  final offlineById = {for (final c in offline) c.id: c};
  final merged = server.map((chapter) {
    final local = offlineById[chapter.id];
    if (local == null) return chapter;
    return _mergeOfflineProgress(chapter, local);
  }).toList();
  final serverIds = server.map((c) => c.id).toSet();
  for (final chapter in offline) {
    if (!serverIds.contains(chapter.id)) merged.add(chapter);
  }
  return merged;
}

@riverpod
class MangaWithId extends _$MangaWithId {
  @override
  Future<MangaDto?> build({required int mangaId}) async {
    try {
      final manga =
          await ref.read(mangaBookRepositoryProvider).getManga(mangaId: mangaId);
      if (manga != null) return manga;
    } catch (_) {}

    final offlineTitle = await ref
        .read(localDownloadsServiceProvider)
        .getOfflineMangaTitle(mangaId);
    final hasOffline = offlineTitle != null ||
        await ref.read(localDownloadsServiceProvider).hasOfflineManga(mangaId);
    if (!hasOffline) return null;

    return MangaDto(
      downloadCount: 0,
      genre: const [],
      id: mangaId,
      inLibrary: true,
      inLibraryAt: '0',
      initialized: true,
      meta: const [],
      sourceId: '',
      status: Enum$MangaStatus.UNKNOWN,
      title: offlineTitle ?? '',
      unreadCount: 0,
      updateStrategy: Enum$UpdateStrategy.ONLY_FETCH_ONCE,
      url: '',
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

@riverpod
class MangaChapterList extends _$MangaChapterList {
  @override
  Future<List<ChapterDto>?> build({required int mangaId}) async {
    List<ChapterDto>? server;
    try {
      server =
          await ref.read(mangaBookRepositoryProvider).getChapterList(mangaId);
    } catch (_) {
      server = null;
    }

    final offline = await ref
        .read(localDownloadsServiceProvider)
        .getOfflineChaptersForManga(mangaId);

    if (server != null) {
      return _mergeOfflineChapters(server, offline);
    }
    return offline.isEmpty ? null : offline;
  }

  Future<void> refresh([bool onlineFetch = false]) async {
    final result = await AsyncValue.guard(
        () => ref.read(mangaBookRepositoryProvider).getChapterList(mangaId));
    if (result.hasError) {
      state = result.copyWithPrevious(state);
      return;
    }
    final offline = await ref
        .read(localDownloadsServiceProvider)
        .getOfflineChaptersForManga(mangaId);
    final serverChapters = result.valueOrNull;
    final merged = serverChapters != null
        ? _mergeOfflineChapters(serverChapters, offline)
        : offline.isEmpty
            ? null
            : offline;
    state = AsyncData<List<ChapterDto>?>(merged);
  }

  void updateChapter(int index, ChapterDto chapter) {
    try {
      final newList = [...?state.valueOrNull];
      newList[index] = chapter;
      state = AsyncData<List<ChapterDto>?>(newList).copyWithPrevious(state);
    } catch (e) {
      //
    }
  }
}

@riverpod
Set<String> mangaScanlatorList(Ref ref, {required int mangaId}) {
  final chapterList = ref.watch(mangaChapterListProvider(mangaId: mangaId));
  final scanlatorList = <String>{};
  chapterList.whenData((data) {
    if (data == null) return;
    for (final chapter in data) {
      if (chapter.scanlator.isNotBlank) {
        scanlatorList.add(chapter.scanlator!);
      }
    }
  });
  return scanlatorList;
}

@riverpod
class MangaChapterFilterScanlator extends _$MangaChapterFilterScanlator {
  @override
  String build({required int mangaId}) {
    final manga = ref.watch(mangaWithIdProvider(mangaId: mangaId));
    return manga.valueOrNull?.metaData.scanlator ?? MangaMetaKeys.scanlator.key;
  }

  void update(String? scanlator) async {
    await AsyncValue.guard(
      () => ref.read(mangaBookRepositoryProvider).patchMangaMeta(
            mangaId: mangaId,
            key: MangaMetaKeys.scanlator.key,
            value: scanlator ?? MangaMetaKeys.scanlator.key,
          ),
    );
    ref.invalidate(mangaWithIdProvider(mangaId: mangaId));
    state = scanlator ?? MangaMetaKeys.scanlator.key;
  }
}

@riverpod
AsyncValue<List<ChapterDto>?> mangaChapterListWithFilter(
  Ref ref, {
  required int mangaId,
}) {
  final chapterList = ref.watch(mangaChapterListProvider(mangaId: mangaId));
  final chapterFilterUnread = ref.watch(mangaChapterFilterUnreadProvider);
  final chapterFilterDownloaded =
      ref.watch(mangaChapterFilterDownloadedProvider);
  final chapterFilterBookmark = ref.watch(mangaChapterFilterBookmarkedProvider);
  final ChapterSort sortedBy =
      ref.watch(mangaChapterSortProvider) ?? DBKeys.chapterSort.initial;
  final sortedDirection = ref.watch(mangaChapterSortDirectionProvider) ??
      DBKeys.chapterSortDirection.initial;

  final chapterFilterScanlator =
      ref.watch(mangaChapterFilterScanlatorProvider(mangaId: mangaId));
  final localDownloadedIds =
      ref.watch(localDownloadedChapterIdsProvider).valueOrNull?.toSet() ??
          const <int>{};

  final passesFilter = _chapterFilterPredicate(
    chapterFilterUnread: chapterFilterUnread,
    chapterFilterDownloaded: chapterFilterDownloaded,
    chapterFilterBookmark: chapterFilterBookmark,
    chapterFilterScanlator: chapterFilterScanlator,
    localDownloadedChapterIds: localDownloadedIds,
  );

  bool applyChapterFilter(ChapterDto chapter) => passesFilter(chapter);

  int applyChapterSort(ChapterDto m1, ChapterDto m2) => _compareChapters(
        m1,
        m2,
        sortedBy: sortedBy,
        sortedDirection: sortedDirection,
      );

  return chapterList.copyWithData(
    (data) => [...?data?.where(applyChapterFilter)]..sort(applyChapterSort),
  );
}

@riverpod
ChapterDto? firstUnreadInFilteredChapterList(
  Ref ref, {
  required int mangaId,
}) {
  final filteredList = ref
      .watch(mangaChapterListWithFilterProvider(mangaId: mangaId))
      .valueOrNull;
  if (filteredList == null) {
    return null;
  }
  // Filtered list is already sorted in reading order — first unread is always
  // the first match regardless of ascending/descending display sort.
  return filteredList
      .firstWhereOrNull((element) => !element.isRead.ifNull(false));
}

@riverpod
({ChapterDto? first, ChapterDto? second})? getNextAndPreviousChapters(
  Ref ref, {
  required int mangaId,
  required int chapterId,
  bool shouldAscSort = true,
}) {
  final isAscSorted = ref.watch(mangaChapterSortDirectionProvider) ??
      DBKeys.chapterSortDirection.initial;
  final sortedBy =
      ref.watch(mangaChapterSortProvider) ?? DBKeys.chapterSort.initial;
  final chapterList =
      ref.watch(mangaChapterListProvider(mangaId: mangaId)).valueOrNull;
  if (chapterList == null) {
    return null;
  }

  final chapterFilterUnread = ref.watch(mangaChapterFilterUnreadProvider);
  final chapterFilterDownloaded =
      ref.watch(mangaChapterFilterDownloadedProvider);
  final chapterFilterBookmark = ref.watch(mangaChapterFilterBookmarkedProvider);
  final chapterFilterScanlator =
      ref.watch(mangaChapterFilterScanlatorProvider(mangaId: mangaId));
  final localDownloadedIds =
      ref.watch(localDownloadedChapterIdsProvider).valueOrNull?.toSet() ??
          const <int>{};

  final filtersActive = _chapterFiltersActive(
    chapterFilterUnread,
    chapterFilterDownloaded,
    chapterFilterBookmark,
    chapterFilterScanlator,
  );

  final sortedList = _sortedChapterList(
    chapterList,
    sortedBy: sortedBy,
    sortedDirection: isAscSorted,
  );
  final current = sortedList.indexWhere((element) => element.id == chapterId);
  if (current < 0) {
    return (first: null, second: null);
  }

  final listAscending = isAscSorted;
  final readingForward = shouldAscSort;

  if (filtersActive) {
    final passesFilter = _chapterFilterPredicate(
      chapterFilterUnread: chapterFilterUnread,
      chapterFilterDownloaded: chapterFilterDownloaded,
      chapterFilterBookmark: chapterFilterBookmark,
      chapterFilterScanlator: chapterFilterScanlator,
      localDownloadedChapterIds: localDownloadedIds,
    );
    final forward = chapterForwardInReadingOrderFiltered(
      sortedList,
      current,
      listAscending: listAscending,
      passesFilter: passesFilter,
    );
    final backward = chapterBackwardInReadingOrderFiltered(
      sortedList,
      current,
      listAscending: listAscending,
      passesFilter: passesFilter,
    );
    return (
      first: readingForward ? forward : backward,
      second: readingForward ? backward : forward,
    );
  }

  final forward = chapterForwardInReadingOrder(
    sortedList,
    current,
    listAscending: listAscending,
  );
  final backward = chapterBackwardInReadingOrder(
    sortedList,
    current,
    listAscending: listAscending,
  );
  return (
    first: readingForward ? forward : backward,
    second: readingForward ? backward : forward,
  );
}

@riverpod
class MangaChapterSort extends _$MangaChapterSort
    with SharedPreferenceEnumClientMixin<ChapterSort> {
  @override
  ChapterSort? build() => initialize(
        DBKeys.chapterSort,
        enumList: ChapterSort.values,
      );
}

@riverpod
class MangaChapterSortDirection extends _$MangaChapterSortDirection
    with SharedPreferenceClientMixin<bool> {
  @override
  bool? build() => initialize(DBKeys.chapterSortDirection);
}

@riverpod
class MangaChapterFilterDownloaded extends _$MangaChapterFilterDownloaded
    with SharedPreferenceClientMixin<bool> {
  @override
  bool? build() => initialize(DBKeys.chapterFilterDownloaded);
}

@riverpod
class MangaChapterFilterUnread extends _$MangaChapterFilterUnread
    with SharedPreferenceClientMixin<bool> {
  @override
  bool? build() => initialize(DBKeys.chapterFilterUnread);
}

@riverpod
class MangaChapterFilterBookmarked extends _$MangaChapterFilterBookmarked
    with SharedPreferenceClientMixin<bool> {
  @override
  bool? build() => initialize(DBKeys.chapterFilterBookmarked);
}

@riverpod
class MangaCategoryList extends _$MangaCategoryList {
  @override
  FutureOr<Map<String, CategoryDto>?> build(int mangaId) async {
    final result = await ref
        .watch(mangaBookRepositoryProvider)
        .getMangaCategoryList(mangaId: mangaId);
    return {
      for (CategoryDto i in (result ?? <CategoryDto>[])) "${i.id}": i,
    };
  }

  Future<void> refresh() async {
    final result = await AsyncValue.guard(() => ref
        .read(mangaBookRepositoryProvider)
        .getMangaCategoryList(mangaId: mangaId));
    state = result.copyWithData((data) => {
          for (CategoryDto i in (data ?? <CategoryDto>[])) "${i.id}": i,
        });
  }
}
