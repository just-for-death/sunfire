import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../routes/router_config.dart';
import '../../manga_book/data/local_downloads/local_downloads_service.dart';
import '../../manga_book/presentation/manga_details/controller/manga_details_controller.dart';
import '../domain/history_group.dart';
import '../domain/history_item.dart';

bool historyItemIsCompleted(HistoryItemDto item) =>
    item.isRead == true ||
    (item.pageCount > 0 && item.lastPageRead >= item.pageCount - 1);

/// Read progress for history UI (0.0–1.0). Completed chapters show full bar.
double historyItemReadProgress(HistoryItemDto item) {
  if (historyItemIsCompleted(item)) return 1.0;
  if (item.pageCount <= 0) return 0.0;
  return (item.lastPageRead / item.pageCount).clamp(0.0, 1.0);
}

/// In-progress chapters for the continue-reading carousel.
List<HistoryItemDto> inProgressHistoryItems(List<HistoryGroup> groups) =>
    groups
        .expand((g) => g.items)
        .where((item) => !historyItemIsCompleted(item))
        .take(10)
        .toList();

/// Opens the reader for a history item, advancing to the next chapter when finished.
Future<void> openReaderFromHistoryItem(
  BuildContext context,
  WidgetRef ref,
  HistoryItemDto item,
) async {
  if (!historyItemIsCompleted(item)) {
    await ReaderRoute(mangaId: item.mangaId, chapterId: item.id).push(context);
    return;
  }

  try {
    final chapterListState =
        ref.read(mangaChapterListProvider(mangaId: item.mangaId));
    final chapterInList = chapterListState.valueOrNull
            ?.any((chapter) => chapter.id == item.id) ??
        false;

    if (!chapterInList) {
      await ref
          .read(mangaChapterListProvider(mangaId: item.mangaId).notifier)
          .refresh();
    }

    await ref.read(mangaChapterListProvider(mangaId: item.mangaId).future);
    await ref.read(localDownloadedChapterIdsProvider.future);

    if (!context.mounted) return;

    final pair = ref.read(
      getNextAndPreviousChaptersProvider(
        mangaId: item.mangaId,
        chapterId: item.id,
      ),
    );
    final nextId = pair?.first?.id;
    if (nextId != null && nextId != item.id) {
      await ReaderRoute(mangaId: item.mangaId, chapterId: nextId).push(context);
    } else {
      await MangaRoute(mangaId: item.mangaId).push(context);
    }
  } catch (_) {
    if (context.mounted) {
      await MangaRoute(mangaId: item.mangaId).push(context);
    }
  }
}
