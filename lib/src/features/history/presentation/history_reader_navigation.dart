import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../routes/router_config.dart';
import '../../manga_book/presentation/manga_details/controller/manga_details_controller.dart';
import '../domain/history_item.dart';

bool historyItemIsCompleted(HistoryItemDto item) =>
    item.isRead == true ||
    (item.pageCount > 0 && item.lastPageRead >= item.pageCount - 1);

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

  final completer = Completer<void>();
  ProviderSubscription? sub;

  void go(int chapterId) {
    if (completer.isCompleted) return;
    if (context.mounted) {
      ReaderRoute(mangaId: item.mangaId, chapterId: chapterId).push(context);
    }
    sub?.close();
    completer.complete();
  }

  sub = ref.listenManual(
    mangaChapterListWithFilterProvider(mangaId: item.mangaId),
    (_, next) {
      if (next is AsyncData) {
        final pair = ref.read(
          getNextAndPreviousChaptersProvider(
            mangaId: item.mangaId,
            chapterId: item.id,
          ),
        );
        go(pair?.first?.id ?? item.id);
      } else if (next is AsyncError) {
        go(item.id);
      }
    },
  );

  ref.read(mangaChapterSortProvider);
  ref.read(mangaChapterSortDirectionProvider);
  ref.read(mangaChapterFilterUnreadProvider);
  ref.read(mangaChapterFilterDownloadedProvider);
  ref.read(mangaChapterFilterBookmarkedProvider);
  ref.read(mangaChapterFilterScanlatorProvider(mangaId: item.mangaId));

  final existing = ref.read(mangaChapterListProvider(mangaId: item.mangaId));
  if (existing is AsyncData) {
    final pair = ref.read(
      getNextAndPreviousChaptersProvider(
        mangaId: item.mangaId,
        chapterId: item.id,
      ),
    );
    go(pair?.first?.id ?? item.id);
    return;
  }

  unawaited(
    ref.read(mangaChapterListProvider(mangaId: item.mangaId).notifier).refresh(),
  );

  await completer.future.timeout(
    const Duration(seconds: 10),
    onTimeout: () => go(item.id),
  );
}
