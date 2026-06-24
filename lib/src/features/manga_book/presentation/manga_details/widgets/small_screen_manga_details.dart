// Copyright (c) 2022 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../theme/komikku_ui_tokens.dart';
import '../../../../../utils/extensions/custom_extensions.dart';
import '../../../../../widgets/emoticons.dart';
import '../../../data/manga_book/manga_book_repository.dart';
import '../../../domain/chapter/chapter_model.dart';
import '../../../domain/manga/manga_model.dart';
import 'chapter_list_tile.dart';
import 'manga_description.dart';
import 'panorama_cover.dart';

class SmallScreenMangaDetails extends ConsumerWidget {
  const SmallScreenMangaDetails({
    super.key,
    required this.chapterList,
    required this.manga,
    required this.selectedChapters,
    required this.mangaId,
    required this.onRefresh,
    required this.onDescriptionRefresh,
    required this.onListRefresh,
  });
  final int mangaId;
  final MangaDto manga;
  final AsyncValueSetter<bool> onRefresh;
  final ValueNotifier<Map<int, ChapterDto>> selectedChapters;
  final AsyncValue<List<ChapterDto>?> chapterList;
  final AsyncValueSetter<bool> onListRefresh;
  final AsyncValueSetter<bool> onDescriptionRefresh;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredChapterList = chapterList.valueOrNull;
    return RefreshIndicator(
      onRefresh: () => onRefresh(true),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  PanoramaCover(
                    imageUrl: manga.thumbnailUrl ?? '',
                    title: manga.title,
                    author: manga.author,
                  ),
                  MangaDescription(
                    manga: manga,
                    mangaId: mangaId,
                    refresh: () => onDescriptionRefresh(false),
                    removeMangaFromLibrary: () => ref
                        .read(mangaBookRepositoryProvider)
                        .removeMangaFromLibrary(mangaId),
                    addMangaToLibrary: () => ref
                        .read(mangaBookRepositoryProvider)
                        .addMangaToLibrary(mangaId),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: KomikkuUiTokens.screenPadding,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SizeTransition(
                    sizeFactor: animation,
                    alignment: Alignment.topCenter,
                    child: child,
                  ),
                ),
                child: ListTile(
                  key: ValueKey(filteredChapterList?.length ?? 0),
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    context.l10n.noOfChapters(filteredChapterList?.length ?? 0),
                    style: context.theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
          chapterList.showUiWhenData(
            context,
            (data) {
              if (data.isNotBlank) {
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => ChapterListTile(
                      key: ValueKey("${filteredChapterList[index].id}"),
                      manga: manga,
                      chapter: filteredChapterList[index],
                      updateData: () => onListRefresh(false),
                      isSelected: selectedChapters.value.containsKey(
                        filteredChapterList[index].id,
                      ),
                      canTapSelect: selectedChapters.value.isNotEmpty,
                      toggleSelect: (ChapterDto val) {
                        if ((val.id).isNull) return;
                        selectedChapters.value = selectedChapters.value
                            .toggleKey(val.id, val);
                      },
                    ),
                    childCount: filteredChapterList!.length,
                  ),
                );
              } else {
                return SliverToBoxAdapter(
                  child: Emoticons(
                    title: context.l10n.noChaptersFound,
                    button: TextButton(
                      onPressed: () => onListRefresh(true),
                      child: Text(context.l10n.refresh),
                    ),
                  ),
                );
              }
            },
            refresh: () => onRefresh(false),
            wrapper: (child) => SliverToBoxAdapter(
              child: SizedBox(height: context.height * .5, child: child),
            ),
          ),
          const SliverToBoxAdapter(child: ListTile()),
        ],
      ),
    );
  }
}
