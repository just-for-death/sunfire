// Copyright (c) 2022 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../constants/app_sizes.dart';
import '../../../../constants/enum.dart';
import '../../../../routes/router_config.dart';
import '../../../../utils/extensions/custom_extensions.dart';
import '../../../../widgets/emoticons.dart';
import '../../../../widgets/manga_cover/grid/manga_cover_grid_tile.dart';
import '../../../../widgets/manga_cover/list/manga_cover_descriptive_list_tile.dart';
import '../../../../widgets/manga_cover/list/manga_cover_list_tile.dart';
import '../../../manga_book/data/manga_book/manga_book_repository.dart';
import '../../../manga_book/presentation/manga_details/widgets/edit_manga_category_dialog.dart';
import '../../../settings/presentation/appearance/widgets/grid_cover_width_slider/grid_cover_width_slider.dart';
import 'controller/library_controller.dart';

class CategoryMangaList extends HookConsumerWidget {
  const CategoryMangaList({super.key, required this.categoryId});
  final int categoryId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider =
        categoryMangaListWithQueryAndFilterProvider(categoryId: categoryId);
    final mangaList = ref.watch(provider);
    final displayMode = ref.watch(libraryDisplayModeProvider);
    final gridWidth = ref.watch(gridMinWidthProvider);
    refresh() => ref.invalidate(categoryMangaListProvider(categoryId));
    useEffect(() {
      if (mangaList.isNotLoading) refresh();
      return;
    }, []);
    final selectedIds = useState<Set<int>>({});
    final isSelectionMode = selectedIds.value.isNotEmpty;

    void toggleSelection(int id) {
      final newSet = Set<int>.from(selectedIds.value);
      if (newSet.contains(id)) {
        newSet.remove(id);
      } else {
        newSet.add(id);
      }
      selectedIds.value = newSet;
    }

    return mangaList.showUiWhenData(
      context,
      (data) {
        if (data.isBlank) {
          return Emoticons(
            title: context.l10n.noCategoryMangaFound,
            button: TextButton(
              onPressed: refresh,
              child: Text(context.l10n.refresh),
            ),
          );
        }
        final Widget mangaListWidget = switch (displayMode) {
          DisplayMode.list || null => ListView.builder(
              itemExtent: 96,
              itemCount: (data?.length).getValueOnNullOrNegative(),
              itemBuilder: (context, index) => MangaCoverListTile(
                manga: data![index],
                isSelected: selectedIds.value.contains(data[index].id),
                onPressed: () {
                  if (isSelectionMode) {
                    toggleSelection(data[index].id);
                  } else {
                    MangaRoute(
                      mangaId: data[index].id,
                      categoryId: categoryId,
                    ).push(context);
                  }
                },
                onLongPress: () {
                  if (!isSelectionMode) {
                    showDialog(
                      context: context,
                      builder: (context) => EditMangaCategoryDialog(
                        mangaId: data[index].id,
                        title: data[index].title,
                      ),
                    ).then((_) => refresh());
                  } else {
                    toggleSelection(data[index].id);
                  }
                },
                showCountBadges: true,
              ),
            ),
          DisplayMode.grid => GridView.builder(
              gridDelegate: mangaCoverGridDelegate(gridWidth),
              itemCount: (data?.length).getValueOnNullOrNegative(),
              itemBuilder: (context, index) => MangaCoverGridTile(
                manga: data![index],
                isSelected: selectedIds.value.contains(data[index].id),
                onPressed: () {
                  if (isSelectionMode) {
                    toggleSelection(data[index].id);
                  } else {
                    MangaRoute(
                      mangaId: data[index].id,
                      categoryId: categoryId,
                    ).push(context);
                  }
                },
                onLongPress: () {
                  if (!isSelectionMode) {
                    showDialog(
                      context: context,
                      builder: (context) => EditMangaCategoryDialog(
                        mangaId: data[index].id,
                        title: data[index].title,
                      ),
                    ).then((_) => refresh());
                  } else {
                    toggleSelection(data[index].id);
                  }
                },
                showCountBadges: true,
                showDarkOverlay: false,
              ),
            ),
          DisplayMode.descriptiveList => ListView.builder(
              itemExtent: 176,
              itemCount: (data?.length).getValueOnNullOrNegative(),
              itemBuilder: (context, index) => MangaCoverDescriptiveListTile(
                manga: data![index],
                isSelected: selectedIds.value.contains(data[index].id),
                onPressed: () {
                  if (isSelectionMode) {
                    toggleSelection(data[index].id);
                  } else {
                    MangaRoute(
                      mangaId: data[index].id,
                      categoryId: categoryId,
                    ).push(context);
                  }
                },
                onLongPress: () {
                  if (!isSelectionMode) {
                    showDialog(
                      context: context,
                      builder: (context) => EditMangaCategoryDialog(
                        mangaId: data[index].id,
                        title: data[index].title,
                      ),
                    ).then((_) => refresh());
                  } else {
                    toggleSelection(data[index].id);
                  }
                },
                showBadges: true,
              ),
            )
        };

        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async => refresh(),
              child: mangaListWidget,
            ),
            if (isSelectionMode)
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(16),
                  color: context.theme.colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${selectedIds.value.length} selected',
                          style: context.theme.textTheme.titleMedium?.copyWith(
                            color: context.theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.delete_outline_rounded, color: context.theme.colorScheme.error),
                              onPressed: () async {
                                final ids = selectedIds.value.toList();
                                selectedIds.value = {};
                                for (final id in ids) {
                                  await ref.read(mangaBookRepositoryProvider).removeMangaFromLibrary(id);
                                }
                                refresh();
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.clear_all_rounded, color: context.theme.colorScheme.onPrimaryContainer),
                              onPressed: () => selectedIds.value = {},
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
      refresh: refresh,
    );
  }
}
