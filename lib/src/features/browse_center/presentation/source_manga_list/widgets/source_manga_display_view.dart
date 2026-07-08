// Copyright (c) 2022 Contributors to the Catalyst project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../../../constants/db_keys.dart';
import '../../../../../constants/enum.dart';
import '../../../../../utils/extensions/custom_extensions.dart';
import '../../../../manga_book/data/manga_book/manga_book_repository.dart';
import '../../../../manga_book/domain/manga/manga_model.dart';
import '../../../domain/source/source_model.dart';
import '../controller/source_manga_controller.dart';
import 'source_manga_grid_view.dart';
import 'source_manga_list_view.dart';

class SourceMangaDisplayView extends ConsumerWidget {
  const SourceMangaDisplayView({
    super.key,
    required this.controller,
    required this.sourceId,
    required this.sourceType,
    this.source,
  });

  final PagingController<int, MangaDto> controller;
  final SourceDto? source;
  final String sourceId;
  final SourceType sourceType;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DisplayMode displayMode = ref.watch(sourceDisplayModeProvider) ??
        DBKeys.sourceDisplayMode.initial;
    toggleFavorite(MangaDto item) async {
      if (item.inLibrary.ifNull()) {
        final removeManga = await context.showAdaptiveConfirm(
          title: item.title.isNotBlank ? item.title : context.l10n.remove,
          content: context.l10n.removeFromLibrary,
          confirmLabel: context.l10n.remove,
          cancelLabel: context.l10n.cancel,
          isDestructive: true,
        );
        return removeManga
            ? await AsyncValue.guard(() => ref
                .read(mangaBookRepositoryProvider)
                .removeMangaFromLibrary(item.id))
            : null;
      } else {
        return AsyncValue.guard(() =>
            ref.read(mangaBookRepositoryProvider).addMangaToLibrary(item.id));
      }
    }

    return switch (displayMode) {
      DisplayMode.grid => SourceMangaGridView(
          sourceId: sourceId,
          sourceType: sourceType,
          controller: controller,
          source: source,
          toggleFavorite: toggleFavorite,
        ),
      DisplayMode.list || DisplayMode.descriptiveList => SourceMangaListView(
          controller: controller,
          source: source,
          toggleFavorite: toggleFavorite,
        )
    };
  }
}
