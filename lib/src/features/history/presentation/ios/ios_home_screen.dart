import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../global_providers/tablet_selection_providers.dart';
import '../../../../routes/router_config.dart';
import '../../../../utils/extensions/custom_extensions.dart';
import '../../../../utils/platform/platform_ui.dart';
import '../../../../widgets/layout/tablet_split_layout.dart';
import '../../../../widgets/server_image.dart';
import '../../../../widgets/shell/ios/glass_app_bar.dart';
import '../../domain/history_group.dart';
import '../../domain/history_item.dart';
import '../history_controller.dart';
import '../history_reader_navigation.dart';
import '../history_settings_sheet.dart';
import '../widgets/continue_reading_carousel.dart';
import '../widgets/history_detail_pane.dart';

class IOSHomeScreen extends HookConsumerWidget {
  const IOSHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyGroups = ref.watch(filteredHistoryGroupsProvider);
    final historyState = ref.watch(readingHistoryProvider);
    final historyEnabled = ref.watch(historyEnabledProvider) ?? true;
    final hasMore = ref.watch(historyHasMoreProvider);
    final searchQuery = ref.watch(historySearchQueryProvider);
    final searchController = useTextEditingController(text: searchQuery);
    final isLoadingMore = useState(false);
    final isDark = context.isDarkMode;
    final cs = context.theme.colorScheme;
    final bottomPadding = scrollBottomPadding(context).bottom;
    final isTabletSplit = TabletSplitLayout.shouldUse(context);
    final selectedItem = ref.watch(tabletHistorySelectionProvider);

    final selectableItems = useMemoized(
      () => historyGroups.expand((g) => g.items).toList(),
      [historyGroups],
    );
    final selectedId = selectedItem?.id;
    final liveSelectedItem = useMemoized(
      () {
        if (selectedId == null) return null;
        for (final item in selectableItems) {
          if (item.id == selectedId) return item;
        }
        return null;
      },
      [selectableItems, selectedId],
    );

    useEffect(() {
      if (searchController.text != searchQuery) {
        searchController.text = searchQuery;
      }
      return null;
    }, [searchQuery]);

    useEffect(() {
      if (!isTabletSplit) return null;
      if (selectableItems.isEmpty) {
        if (selectedItem != null) {
          Future.microtask(() {
            ref.read(tabletHistorySelectionProvider.notifier).state = null;
          });
        }
        return null;
      }
      if (liveSelectedItem == null) {
        Future.microtask(() {
          ref.read(tabletHistorySelectionProvider.notifier).state =
              selectableItems.first;
        });
      }
      return null;
    }, [isTabletSplit, selectableItems, liveSelectedItem]);

    Future<void> tryLoadMore() async {
      if (!hasMore ||
          isLoadingMore.value ||
          ref.read(readingHistoryProvider.notifier).isLoadingMore) {
        return;
      }
      isLoadingMore.value = true;
      try {
        await ref.read(readingHistoryProvider.notifier).loadMore();
      } finally {
        isLoadingMore.value = false;
      }
    }

    useEffect(() {
      if (searchQuery.isBlank) return null;
      if (historyGroups.isNotEmpty) return null;
      if (!hasMore || isLoadingMore.value) return null;
      Future.microtask(() => tryLoadMore());
      return null;
    }, [searchQuery, historyGroups, hasMore]);

    void onHistoryItemTap(HistoryItemDto item) {
      ref.read(tabletHistorySelectionProvider.notifier).state = item;
    }

    final listEntries = useMemoized(
      () => _buildGroupedEntries(historyGroups),
      [historyGroups],
    );

    final scrollBody = historyState.when(
      loading: () => const Center(child: CupertinoActivityIndicator()),
      error: (_, __) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.exclamationmark_triangle,
              size: 48,
              color: cs.error.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.errorSomethingWentWrong,
              style: TextStyle(
                color: (isDark ? Colors.white : Colors.black)
                    .withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            CupertinoButton.filled(
              onPressed: () =>
                  ref.read(readingHistoryProvider.notifier).refresh(),
              child: Text(context.l10n.retry),
            ),
          ],
        ),
      ),
      data: (_) => NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.extentAfter < 240) {
            unawaited(tryLoadMore());
          }
          return false;
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            GlassSliverAppBar(
              title: context.l10n.navHome,
              actions: [
                IconButton(
                  icon: Icon(
                    CupertinoIcons.search,
                    color: cs.primary,
                  ),
                  tooltip: context.l10n.search,
                  onPressed: () => const GlobalSearchRoute().push(context),
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.refresh),
                  tooltip: context.l10n.retry,
                  onPressed: () =>
                      ref.read(readingHistoryProvider.notifier).refresh(),
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.settings),
                  tooltip: context.l10n.settings,
                  onPressed: () => showHistorySettingsSheet(context, ref),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: CupertinoSearchTextField(
                  controller: searchController,
                  placeholder: context.l10n.searchHistory,
                  onChanged: (value) => ref
                      .read(historySearchQueryProvider.notifier)
                      .updateQuery(value),
                  onSuffixTap: searchQuery.isBlank
                      ? null
                      : () {
                          searchController.clear();
                          ref
                              .read(historySearchQueryProvider.notifier)
                              .updateQuery('');
                        },
                ),
              ),
            ),
            if (!historyEnabled)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.time,
                        size: 56,
                        color: (isDark ? Colors.white : Colors.black)
                            .withValues(alpha: 0.2),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        context.l10n.historyEnabledLabel,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: (isDark ? Colors.white : Colors.black)
                              .withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          context.l10n.historyEnabledDescription,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: (isDark ? Colors.white : Colors.black)
                                .withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (historyGroups.isNotEmpty) ...[
              ContinueReadingCarousel(
                groups: historyGroups,
                useCupertinoStyle: true,
                onItemTap: isTabletSplit ? onHistoryItemTap : null,
                selectedItemId: isTabletSplit ? liveSelectedItem?.id : null,
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, bottomPadding),
                sliver: SliverList.builder(
                  itemCount: listEntries.length + (hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == listEntries.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: isLoadingMore.value
                              ? const CupertinoActivityIndicator()
                              : Text(
                                  context.l10n.historyLoadMore,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: (isDark ? Colors.white : Colors.black)
                                        .withValues(alpha: 0.4),
                                  ),
                                ),
                        ),
                      );
                    }
                    final entry = listEntries[index];
                    if (entry.isHeader) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                        child: Text(
                          entry.group!.getLocalizedTitle(context),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: cs.primary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      );
                    }
                    final item = entry.item!;
                    final selected =
                        isTabletSplit && liveSelectedItem?.id == item.id;
                    return Dismissible(
                      key: ValueKey('ios_history_${item.id}'),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (_) => showAdaptiveConfirmDialog(
                        context: context,
                        title: context.l10n.removeFromHistory,
                        content: context.l10n.removeFromHistoryConfirmation,
                        confirmLabel: context.l10n.remove,
                        cancelLabel: context.l10n.cancel,
                        isDestructive: true,
                      ),
                      onDismissed: (_) => ref
                          .read(readingHistoryProvider.notifier)
                          .removeFromHistory(item.id),
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        color: cs.error.withValues(alpha: 0.85),
                        child: Icon(
                          CupertinoIcons.delete,
                          color: cs.onError,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: _IOSHistoryTile(
                          item: item,
                          isDark: isDark,
                          cs: cs,
                          isSelected: selected,
                          onTap: isTabletSplit
                              ? () => onHistoryItemTap(item)
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ] else if (searchQuery.isNotBlank && hasMore)
              const SliverFillRemaining(
                child: Center(child: CupertinoActivityIndicator()),
              )
            else
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.book,
                        size: 56,
                        color: (isDark ? Colors.white : Colors.black)
                            .withValues(alpha: 0.2),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        searchQuery.isNotBlank
                            ? context.l10n.noSearchResults
                            : context.l10n.noHistoryFound,
                        style: TextStyle(
                          fontSize: 17,
                          color: (isDark ? Colors.white : Colors.black)
                              .withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      body: isTabletSplit
          ? TabletSplitLayout(
              master: scrollBody,
              detail: liveSelectedItem != null
                  ? HistoryDetailPane(
                      key: ValueKey(liveSelectedItem.id),
                      item: liveSelectedItem,
                    )
                  : const SizedBox.shrink(),
              showDetail: liveSelectedItem != null,
            )
          : scrollBody,
    );
  }

  static List<_IOSHistoryListEntry> _buildGroupedEntries(
    List<HistoryGroup> groups,
  ) {
    final listGroups = historyGroupsExcludingCarousel(groups);
    final entries = <_IOSHistoryListEntry>[];
    for (final group in listGroups) {
      if (group.isEmpty) continue;
      entries.add(_IOSHistoryListEntry.header(group));
      for (final item in group.items) {
        entries.add(_IOSHistoryListEntry.item(item));
      }
    }
    return entries;
  }
}

class _IOSHistoryListEntry {
  const _IOSHistoryListEntry._({this.group, this.item});

  factory _IOSHistoryListEntry.header(HistoryGroup group) =>
      _IOSHistoryListEntry._(group: group);

  factory _IOSHistoryListEntry.item(HistoryItemDto item) =>
      _IOSHistoryListEntry._(item: item);

  final HistoryGroup? group;
  final HistoryItemDto? item;

  bool get isHeader => group != null;
}

class _IOSHistoryTile extends ConsumerWidget {
  const _IOSHistoryTile({
    required this.item,
    required this.isDark,
    required this.cs,
    this.onTap,
    this.isSelected = false,
  });
  final HistoryItemDto item;
  final bool isDark;
  final ColorScheme cs;
  final VoidCallback? onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: isSelected
            ? Border.all(color: cs.primary, width: 2)
            : Border.all(color: Colors.transparent, width: 2),
      ),
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Semantics(
              label: item.manga.title,
              button: true,
              child: GestureDetector(
                onTap: onTap ??
                    () => MangaRoute(mangaId: item.mangaId).push(context),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ServerImage(
                    imageUrl: item.manga.thumbnailUrl ?? '',
                    size: const Size(48, 68),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onTap ??
                    () => MangaRoute(mangaId: item.mangaId).push(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.manga.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 13,
                        color: (isDark ? Colors.white : Colors.black)
                            .withValues(alpha: 0.5),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            Semantics(
              label: context.l10n.historyContinueReading,
              button: true,
              child: GestureDetector(
                onTap: () => openReaderFromHistoryItem(context, ref, item),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    CupertinoIcons.play_fill,
                    size: 14,
                    color: cs.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
