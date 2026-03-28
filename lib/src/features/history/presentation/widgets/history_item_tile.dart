import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../routes/router_config.dart';
import '../../../../utils/extensions/custom_extensions.dart';
import '../../../../widgets/server_image.dart';
import '../../../manga_book/presentation/manga_details/controller/manga_details_controller.dart';
import '../../domain/history_item.dart';
import '../../domain/history_menu_action.dart';

class HistoryItemTile extends ConsumerWidget {
  const HistoryItemTile({
    super.key,
    required this.item,
    required this.onRemove,
    this.onTap,
  });

  final HistoryItemDto item;
  final VoidCallback onRemove;
  final VoidCallback? onTap;

  bool get _isCompleted =>
      item.isRead == true ||
      (item.pageCount > 0 && item.lastPageRead >= item.pageCount - 1);

  double get _readPercent =>
      item.pageCount > 0 ? (item.lastPageRead / item.pageCount).clamp(0, 1) : 0;

  int get _readPercentInt => (_readPercent * 100).round();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = context.theme.colorScheme;
    return GestureDetector(
      onTap: onTap ?? () => _navigateToReader(context, ref),
      onLongPress: () => _showMenu(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Cover image
            ServerImage(
              imageUrl: item.manga.thumbnailUrl ?? '',
              fit: BoxFit.cover,
            ),
            // Gradient overlay at bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(6, 24, 6, 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.85),
                    ],
                  ),
                ),
                child: Text(
                  item.manga.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            // Read % badge (top-right) — Futon style
            if (item.pageCount > 0)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: _isCompleted
                        ? cs.secondary.withValues(alpha: 0.9)
                        : cs.primary.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _isCompleted ? '✓' : '$_readPercentInt%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.book_outlined),
              title: Text(item.manga.title,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(item.name),
            ),
            const Divider(height: 1),
            ...HistoryMenuAction.values.map((action) => ListTile(
                  leading: Icon(action.icon),
                  title: Text(action.toLocale(ctx)),
                  onTap: () {
                    Navigator.pop(ctx);
                    switch (action) {
                      case HistoryMenuAction.removeFromHistory:
                        _showRemoveDialog(context);
                      case HistoryMenuAction.viewManga:
                        _navigateToManga(context);
                    }
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _showRemoveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.removeFromHistory),
        content: Text(context.l10n.removeFromHistoryConfirmation),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(context.l10n.cancel)),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              onRemove();
            },
            child: Text(context.l10n.remove),
          ),
        ],
      ),
    );
  }

  void _ensurePrefs(WidgetRef ref) {
    ref.read(mangaChapterSortProvider);
    ref.read(mangaChapterSortDirectionProvider);
    ref.read(mangaChapterFilterUnreadProvider);
    ref.read(mangaChapterFilterDownloadedProvider);
    ref.read(mangaChapterFilterBookmarkedProvider);
    ref.read(mangaChapterFilterScanlatorProvider(mangaId: item.mangaId));
  }

  void _navigateToReader(BuildContext context, WidgetRef ref) {
    if (_isCompleted) {
      _navigateToNextChapter(context, ref);
    } else {
      ReaderRoute(mangaId: item.mangaId, chapterId: item.id).push(context);
    }
  }

  Future<void> _navigateToNextChapter(
      BuildContext context, WidgetRef ref) async {
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
          final pair = ref.read(getNextAndPreviousChaptersProvider(
              mangaId: item.mangaId, chapterId: item.id));
          go(pair?.first?.id ?? item.id);
        } else if (next is AsyncError) {
          go(item.id);
        }
      },
    );

    _ensurePrefs(ref);
    await ref
        .read(mangaChapterListProvider(mangaId: item.mangaId).notifier)
        .refresh();

    Future.any([
      completer.future,
      Future.delayed(const Duration(seconds: 10)).then((_) {
        if (!completer.isCompleted) go(item.id);
      }),
    ]);
  }

  void _navigateToManga(BuildContext context) =>
      MangaRoute(mangaId: item.mangaId).push(context);
}
