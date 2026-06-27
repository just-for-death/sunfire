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
import '../../../domain/manga/manga_model.dart';

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
    try {
      final result =
          await ref.read(mangaBookRepositoryProvider).getChapterList(mangaId);
      if (result != null) return result;
    } catch (_) {}

    final offline = await ref
        .read(localDownloadsServiceProvider)
        .getOfflineChaptersForManga(mangaId);
    return offline.isEmpty ? null : offline;
  }

  Future<void> refresh([bool onlineFetch = false]) async {
    final result = await AsyncValue.guard(
        () => ref.read(mangaBookRepositoryProvider).getChapterList(mangaId));
    if (result.hasError) {
      state = result.copyWithPrevious(state);
    } else {
      state = result;
    }
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

  bool applyChapterFilter(ChapterDto chapter) {
    if (chapterFilterUnread != null &&
        (chapterFilterUnread ^ !(chapter.isRead.ifNull()))) {
      return false;
    }

    if (chapterFilterDownloaded != null &&
        (chapterFilterDownloaded ^ (chapter.isDownloaded.ifNull()))) {
      return false;
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
  }

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
  final isAscSorted = ref.watch(mangaChapterSortDirectionProvider) ??
      DBKeys.chapterSortDirection.initial;
  final filteredList = ref
      .watch(mangaChapterListWithFilterProvider(mangaId: mangaId))
      .valueOrNull;
  if (filteredList == null) {
    return null;
  } else {
    if (isAscSorted) {
      return filteredList
          .firstWhereOrNull((element) => !element.isRead.ifNull(true));
    } else {
      return filteredList
          .lastWhereOrNull((element) => !element.isRead.ifNull(true));
    }
  }
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
  final sortedList = _sortedChapterList(
    chapterList,
    sortedBy: sortedBy,
    sortedDirection: isAscSorted,
  );
  final current = sortedList.indexWhere((element) => element.id == chapterId);
  if (current < 0) {
    return (first: null, second: null);
  }
  final prevChapter = current > 0 ? sortedList[current - 1] : null;
  final nextChapter =
      current < (sortedList.length - 1) ? sortedList[current + 1] : null;
  return (
    first: shouldAscSort && isAscSorted ? nextChapter : prevChapter,
    second: shouldAscSort && isAscSorted ? prevChapter : nextChapter,
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
