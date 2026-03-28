import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';

import '../../../../routes/router_config.dart';
import '../../../../utils/extensions/custom_extensions.dart';
import '../../../../utils/hooks/paging_controller_hook.dart';
import '../../../../widgets/custom_circular_progress_indicator.dart';
import '../../../../widgets/emoticons.dart';
import '../../../../widgets/server_image.dart';
import '../../data/updates/updates_repository.dart';
import '../../domain/chapter/chapter_model.dart';
import '../../domain/chapter/graphql/__generated__/fragment.graphql.dart';
import '../../widgets/chapter_actions/multi_chapters_actions_bottom_app_bar.dart';
import '../../widgets/download_status_icon.dart';
import '../../widgets/update_status_fab.dart';
import '../../widgets/update_status_popup_menu.dart';
import '../reader/controller/reader_controller.dart';

class UpdatesScreen extends HookConsumerWidget {
  const UpdatesScreen({super.key});

  Future<void> _fetchPage(
    UpdatesRepository repository,
    PagingController<int, ChapterWithMangaDto> controller,
    int pageKey,
  ) async {
    await AsyncValue.guard(
      () => repository.getRecentChaptersPage(pageNo: pageKey),
    ).then(
      (value) => value.whenOrNull(
        data: (page) {
          if (page != null) {
            if (page.pageInfo.hasNextPage) {
              controller.appendPage([...page.nodes], pageKey + 1);
            } else {
              controller.appendLastPage([...page.nodes]);
            }
          }
        },
        error: (e, _) => controller.error = e,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller =
        usePagingController<int, ChapterWithMangaDto>(firstPageKey: 0);
    final updatesRepository = ref.watch(updatesRepositoryProvider);
    final isChecking = ref
        .watch(updatesSocketProvider.select((v) => v.valueOrNull?.isRunning))
        .ifNull();
    final selectedChapters = useState<Map<int, ChapterDto>>({});

    useEffect(() {
      controller.addPageRequestListener(
          (key) => _fetchPage(updatesRepository, controller, key));
      return;
    }, []);

    useEffect(() {
      if (!isChecking) {
        selectedChapters.value = {};
        controller.refresh();
      }
      return null;
    }, [isChecking]);

    return Scaffold(
      floatingActionButton:
          selectedChapters.value.isEmpty ? const UpdateStatusFab() : null,
      appBar: selectedChapters.value.isNotEmpty
          ? AppBar(
              leading: IconButton(
                onPressed: () => selectedChapters.value = {},
                icon: const Icon(Icons.close_rounded),
              ),
              title:
                  Text(context.l10n.numSelected(selectedChapters.value.length)),
            )
          : AppBar(
              titleSpacing: 16,
              title: Text(
                context.l10n.updates,
                style: context.theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              actions: const [UpdateStatusPopupMenu()],
            ),
      bottomSheet: selectedChapters.value.isNotEmpty
          ? MultiChaptersActionsBottomAppBar(
              selectedChapters: selectedChapters,
              afterOptionSelected: () async => controller.refresh(),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () async {
          selectedChapters.value = {};
          controller.refresh();
        },
        child: PagedListView(
          pagingController: controller,
          builderDelegate: PagedChildBuilderDelegate<ChapterWithMangaDto>(
            firstPageProgressIndicatorBuilder: (_) =>
                const CenterCatalystShimmerIndicator(),
            firstPageErrorIndicatorBuilder: (_) => Emoticons(
              title: controller.error.toString(),
              button: TextButton(
                onPressed: () => controller.refresh(),
                child: Text(context.l10n.retry),
              ),
            ),
            noItemsFoundIndicatorBuilder: (_) => Emoticons(
              title: context.l10n.noUpdatesFound,
              button: TextButton(
                onPressed: () => controller.refresh(),
                child: Text(context.l10n.refresh),
              ),
            ),
            itemBuilder: (context, item, index) {
              int? previousDate;
              try {
                previousDate = int.tryParse(
                    controller.itemList?[index - 1].fetchedAt ?? '');
              } catch (_) {}

              final showHeader =
                  !(int.tryParse(item.fetchedAt)).isSameDayAs(previousDate);

              final tile = _FeedTile(
                item: item,
                isSelected: selectedChapters.value.containsKey(item.id),
                canTapSelect: selectedChapters.value.isNotEmpty,
                toggleSelect: (val) {
                  selectedChapters.value =
                      selectedChapters.value.toggleKey(val.id, val);
                },
                updatePair: () async {
                  final chapter = await ref
                      .refresh(chapterProvider(chapterId: item.id).future);
                  try {
                    controller.itemList = [...?controller.itemList]
                      ..replaceRange(index, index + 1, [
                        item.copyWith(
                          isDownloaded: chapter?.isDownloaded,
                          lastPageRead: chapter?.lastPageRead,
                        ),
                      ]);
                  } catch (_) {}
                },
              );

              if (!showHeader) return tile;

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
                    child: Text(
                      int.tryParse(item.fetchedAt)
                          .toDaysAgoFromSeconds(context),
                      style: context.theme.textTheme.labelLarge?.copyWith(
                        color: context.theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  tile,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FeedTile extends ConsumerWidget {
  const _FeedTile({
    required this.item,
    required this.isSelected,
    required this.canTapSelect,
    required this.toggleSelect,
    required this.updatePair,
  });

  final ChapterWithMangaDto item;
  final bool isSelected;
  final bool canTapSelect;
  final ValueChanged<ChapterDto> toggleSelect;
  final AsyncCallback updatePair;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = context.theme.colorScheme;
    final isRead = item.isRead.ifNull();
    final textColor = isRead ? cs.onSurface.withValues(alpha: 0.45) : null;

    return Material(
      color: isSelected
          ? cs.primaryContainer.withValues(alpha: 0.5)
          : Colors.transparent,
      child: InkWell(
        onTap: () {
          if (canTapSelect) {
            toggleSelect(item);
          } else {
            ReaderRoute(
              mangaId: item.manga.id,
              chapterId: item.id,
              showReaderLayoutAnimation: true,
            ).push(context);
          }
        },
        onLongPress: () => toggleSelect(item),
        onSecondaryTap: () => toggleSelect(item),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              // Cover thumbnail
              GestureDetector(
                onTap: () => MangaRoute(mangaId: item.manga.id).push(context),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ServerImage(
                    imageUrl: item.manga.thumbnailUrl ?? '',
                    size: const Size(48, 68),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Text info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.manga.title,
                      style: context.theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.name,
                      style: context.theme.textTheme.bodySmall?.copyWith(
                        color: textColor ?? cs.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.fetchedAt.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        _formatTime(item.fetchedAt),
                        style: context.theme.textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Download icon
              DownloadStatusIcon(
                isDownloaded: item.isDownloaded.ifNull(),
                mangaId: item.manga.id,
                chapter: item,
                updateData: updatePair,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(String fetchedAt) {
    final ms = int.tryParse(fetchedAt);
    if (ms == null) return '';
    final dt = DateTime.fromMillisecondsSinceEpoch(ms * 1000);
    return DateFormat.Hm().format(dt);
  }
}
