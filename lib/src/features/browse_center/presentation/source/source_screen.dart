// Copyright (c) 2022 Contributors to the Catalyst project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../constants/language_list.dart';
import '../../../../global_providers/tablet_selection_providers.dart';
import '../../../../utils/extensions/custom_extensions.dart';
import '../../../../utils/misc/toast/toast.dart';
import '../../../../widgets/emoticons.dart';
import '../../../../widgets/layout/tablet_split_layout.dart';
import '../../domain/source/source_model.dart';
import '../source_manga_list/source_manga_list_screen.dart';
import 'controller/source_controller.dart';
import 'widgets/source_list_tile.dart';

class SourceScreen extends HookConsumerWidget {
  const SourceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sourceMapData = ref.watch(sourceMapFilteredProvider);
    final tabletSelection = ref.watch(tabletBrowseSourceSelectionProvider);

    final sourceMap = {...?sourceMapData.valueOrNull};
    final localSource = sourceMap.remove("localsourcelang");
    final lastUsed = sourceMap.remove("lastUsed");
    final allSource = sourceMap.remove("all");

    useEffect(() {
      if (!TabletSplitLayout.shouldUse(context) || tabletSelection == null) {
        return null;
      }
      final ids = <String>{};
      if (lastUsed != null) ids.addAll(lastUsed.map((s) => s.id));
      if (allSource != null) ids.addAll(allSource.map((s) => s.id));
      if (localSource != null) ids.addAll(localSource.map((s) => s.id));
      for (final list in sourceMap.values) {
        ids.addAll(list.map((s) => s.id));
      }
      if (!ids.contains(tabletSelection.sourceId)) {
        Future.microtask(() {
          ref.read(tabletBrowseSourceSelectionProvider.notifier).state = null;
        });
      }
      return null;
    }, [sourceMapData.valueOrNull, tabletSelection?.sourceId]);

    refresh() => ref.refresh(sourceListProvider.future);
    useEffect(() {
      if (sourceMapData.isNotLoading) refresh();
      return;
    }, []);

    useEffect(() {
      sourceMapData.showToastOnError(
        ref.read(toastProvider),
        withMicrotask: true,
      );
      return;
    }, [sourceMapData.valueOrNull]);

    return sourceMapData.showUiWhenData(
      context,
      (data) {
        if ((sourceMap.isEmpty && localSource.isBlank && lastUsed.isBlank)) {
          return Emoticons(
            title: context.l10n.noSourcesFound,
            button: TextButton(
              onPressed: refresh,
              child: Text(context.l10n.refresh),
            ),
          );
        }
        final sourceList = RefreshIndicator(
          onRefresh: refresh,
          child: CustomScrollView(
            slivers: _sourceSlivers(
              context,
              lastUsed: lastUsed,
              allSource: allSource,
              sourceMap: sourceMap,
              localSource: localSource,
            ),
          ),
        );

        if (TabletSplitLayout.shouldUse(context)) {
          final selection = tabletSelection;
          return TabletSplitLayout(
            master: sourceList,
            detail: selection != null
                ? SourceMangaListScreen(
                    key: ValueKey(
                      '${selection.sourceId}-${selection.sourceType}-${selection.query ?? ''}',
                    ),
                    sourceId: selection.sourceId,
                    sourceType: selection.sourceType,
                    initialQuery: selection.query,
                  )
                : Center(
                    child: Text(
                      context.l10n.selectSource,
                      style: context.theme.textTheme.titleMedium?.copyWith(
                        color: context.theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
            showDetail: selection != null,
          );
        }

        return sourceList;
      },
      refresh: refresh,
    );
  }

  static List<Widget> _sourceSlivers(
    BuildContext context, {
    required List<SourceDto>? lastUsed,
    required List<SourceDto>? allSource,
    required Map<String, List<SourceDto>> sourceMap,
    required List<SourceDto>? localSource,
  }) {
    return [
              if (lastUsed.isNotBlank) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      languageMap["lastUsed"]?.displayName ?? "",
                      style: context.theme.textTheme.titleSmall?.copyWith(
                        color: context.theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                    child: SourceListTile(source: lastUsed!.first))
              ],
              if (allSource.isNotBlank) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      languageMap["all"]?.displayName ?? "",
                      style: context.theme.textTheme.titleSmall?.copyWith(
                        color: context.theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 450,
                    mainAxisExtent: 80,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => SourceListTile(
                      source: allSource![index],
                    ),
                    childCount: allSource?.length,
                  ),
                )
              ],
              for (final k in sourceMap.keys) ...[
                if (sourceMap[k].isNotBlank) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        languageMap[k]?.displayName ?? k,
                        style: context.theme.textTheme.titleSmall?.copyWith(
                          color: context.theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SliverGrid(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 450,
                      mainAxisExtent: 80,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => SourceListTile(
                        source: sourceMap[k]![index],
                      ),
                      childCount: sourceMap[k]?.length,
                    ),
                  )
                ]
              ],
              if (localSource.isNotBlank) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      languageMap["localsourcelang"]?.displayName ?? "",
                      style: context.theme.textTheme.titleSmall?.copyWith(
                        color: context.theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SourceListTile(source: localSource!.first),
                )
              ],
    ];
  }
}
