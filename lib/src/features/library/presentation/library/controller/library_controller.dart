// Copyright (c) 2022 Contributors to the Catalyst project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../constants/db_keys.dart';
import '../../../../../constants/enum.dart';
import '../../../../../utils/extensions/custom_extensions.dart';
import '../../../../../utils/mixin/shared_preferences_client_mixin.dart';
import '../../../../../utils/mixin/state_provider_mixin.dart';
import '../../../../manga_book/data/local_downloads/local_downloads_service.dart';
import '../../../../manga_book/domain/manga/manga_model.dart';
import '../../../data/category_repository.dart';
import '../../../domain/category/category_model.dart';
import 'library_filter_utils.dart';

part 'library_controller.g.dart';

@riverpod
Future<List<MangaDto>?> categoryMangaList(Ref ref, int categoryId) async {
  final service = ref.watch(localDownloadsServiceProvider);

  if (categoryId == kOfflineLibraryCategoryId) {
    return service.listOfflineManga();
  }

  try {
    return await ref
        .watch(categoryRepositoryProvider)
        .getMangasFromCategory(categoryId: categoryId);
  } catch (_) {
    final offline = await service.listOfflineManga();
    return offline.isEmpty ? null : offline;
  }
}

@riverpod
class LibraryDisplayCategory extends _$LibraryDisplayCategory
    with StateProviderMixin<CategoryDto?> {
  @override
  CategoryDto? build() => null;
}

@riverpod
class CategoryMangaListWithQueryAndFilter
    extends _$CategoryMangaListWithQueryAndFilter {
  @override
  AsyncValue<List<MangaDto>?> build({required int categoryId}) {
    final mangaList = ref.watch(categoryMangaListProvider(categoryId));
    final query = ref.watch(libraryQueryProvider);
    final mangaFilterUnread = ref.watch(libraryMangaFilterUnreadProvider);
    final mangaFilterDownloaded =
        ref.watch(libraryMangaFilterDownloadedProvider);
    final mangaFilterCompleted = ref.watch(libraryMangaFilterCompletedProvider);
    final MangaSort sortedBy =
        ref.watch(libraryMangaSortProvider) ?? DBKeys.mangaSort.initial;
    final sortedDirection =
        ref.watch(libraryMangaSortDirectionProvider).ifNull(true);
    final offlineMangaIds =
        ref.watch(localDownloadedMangaIdsProvider).valueOrNull ?? const {};

    bool applyMangaFilter(MangaDto manga) => libraryMangaPassesFilter(
          manga,
          filterUnread: mangaFilterUnread,
          filterDownloaded: mangaFilterDownloaded,
          filterCompleted: mangaFilterCompleted,
          query: query,
          offlineMangaIds: offlineMangaIds,
        );

    int applyMangaSort(MangaDto m1, MangaDto m2) => compareLibraryManga(
          m1,
          m2,
          sortedBy: sortedBy,
          ascending: sortedDirection,
        );

    return mangaList.map<AsyncValue<List<MangaDto>?>>(
      data: (e) => AsyncData(e.valueOrNull?.where(applyMangaFilter).toList()
        ?..sort(applyMangaSort)),
      error: (e) => e,
      loading: (e) => e,
    );
  }

  void invalidate() => ref.invalidate(categoryMangaListProvider(categoryId));
}

@riverpod
class LibraryQuery extends _$LibraryQuery with StateProviderMixin<String?> {
  @override
  String? build() => null;
}

@riverpod
class LibraryMangaFilterDownloaded extends _$LibraryMangaFilterDownloaded
    with SharedPreferenceClientMixin<bool> {
  @override
  // Tri-state, like the chapter filters: null = off, true = only downloaded,
  // false = only not downloaded.
  bool? build() => initialize(DBKeys.mangaFilterDownloaded);
}

@riverpod
class LibraryMangaFilterUnread extends _$LibraryMangaFilterUnread
    with SharedPreferenceClientMixin<bool> {
  @override
  bool? build() => initialize(DBKeys.mangaFilterUnread);
}

@riverpod
class LibraryMangaFilterCompleted extends _$LibraryMangaFilterCompleted
    with SharedPreferenceClientMixin<bool> {
  @override
  bool? build() => initialize(DBKeys.mangaFilterCompleted);
}

@riverpod
class LibraryMangaSort extends _$LibraryMangaSort
    with SharedPreferenceEnumClientMixin<MangaSort> {
  @override
  MangaSort? build() => initialize(
        DBKeys.mangaSort,
        enumList: MangaSort.values,
      );
}

@riverpod
class LibraryMangaSortDirection extends _$LibraryMangaSortDirection
    with SharedPreferenceClientMixin<bool> {
  @override
  bool? build() => initialize(DBKeys.mangaSortDirection);
}

@riverpod
class LibraryDisplayMode extends _$LibraryDisplayMode
    with SharedPreferenceEnumClientMixin<DisplayMode> {
  @override
  DisplayMode? build() => initialize(
        DBKeys.libraryDisplayMode,
        enumList: DisplayMode.values,
      );
}
