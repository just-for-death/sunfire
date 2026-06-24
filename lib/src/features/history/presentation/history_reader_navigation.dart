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

  void finish() {
    if (!completer.isCompleted) {
      sub?.close();
      completer.complete();
    }
  }

  void openChapter(int chapterId) {
    if (!context.mounted) {
      finish();
      return;
    }
    ReaderRoute(mangaId: item.mangaId, chapterId: chapterId).push(context);
    finish();
  }

  void openMangaDetails() {
    if (!context.mounted) {
      finish();
      return;
    }
    MangaRoute(mangaId: item.mangaId).push(context);
    finish();
  }

  void resolveAndOpen() {
    final pair = ref.read(
      getNextAndPreviousChaptersProvider(
        mangaId: item.mangaId,
        chapterId: item.id,
      ),
    );
    final nextId = pair?.first?.id;
    if (nextId != null && nextId != item.id) {
      openChapter(nextId);
    } else {
      openMangaDetails();
    }
  }

  sub = ref.listenManual(
    mangaChapterListProvider(mangaId: item.mangaId),
    (_, next) {
      if (next is AsyncData) {
        resolveAndOpen();
      } else if (next is AsyncError) {
        openChapter(item.id);
      }
    },
  );

  ref.read(mangaChapterSortProvider);
  ref.read(mangaChapterSortDirectionProvider);

  final existing = ref.read(mangaChapterListProvider(mangaId: item.mangaId));
  if (existing is AsyncData) {
    resolveAndOpen();
    return;
  }

  unawaited(
    ref.read(mangaChapterListProvider(mangaId: item.mangaId).notifier).refresh(),
  );

  try {
    await completer.future.timeout(const Duration(seconds: 10));
  } on TimeoutException {
    openChapter(item.id);
  } finally {
    finish();
  }
}
