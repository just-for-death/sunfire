import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../routes/router_config.dart';
import '../../../../utils/extensions/custom_extensions.dart';
import '../../../../utils/platform/platform_ui.dart';
import '../../../../widgets/server_image.dart';
import '../../domain/history_item.dart';
import '../../domain/history_menu_action.dart';
import '../history_reader_navigation.dart';

class HistoryItemTile extends ConsumerWidget {
  const HistoryItemTile({
    super.key,
    required this.item,
    required this.onRemove,
  });

  final HistoryItemDto item;
  final VoidCallback onRemove;

  bool get _isCompleted => historyItemIsCompleted(item);

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = context.theme.colorScheme;
    final progress = historyItemReadProgress(item);

    final tile = InkWell(
      onTap: () => _navigateToReader(context, ref),
      onLongPress: () => _showMenu(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Manga cover thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 52,
                height: 74,
                child: ServerImage(
                  imageUrl: item.manga.thumbnailUrl ?? '',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.manga.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      if (item.pageCount > 0) ...[
                        Text(
                          _isCompleted
                              ? context.l10n.completed
                              : 'Page ${item.lastPageRead + 1}/${item.pageCount}',
                          style: context.theme.textTheme.labelSmall?.copyWith(
                            color: _isCompleted ? cs.primary : cs.outline,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (item.readAt != null)
                        Text(
                          _formatTime(item.readAt!),
                          style: context.theme.textTheme.labelSmall?.copyWith(
                            color: cs.outline,
                          ),
                        ),
                    ],
                  ),
                  if (progress > 0 && !_isCompleted) ...[
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 3,
                        backgroundColor: cs.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Play / Resume Button
            IconButton(
              onPressed: () => _navigateToReader(context, ref),
              icon: Icon(
                isCupertinoPlatform
                    ? CupertinoIcons.play_circle_fill
                    : Icons.play_circle_fill_rounded,
                color: cs.primary,
                size: 32,
              ),
              tooltip: context.l10n.historyContinueReading,
            ),
            // Delete Action
            IconButton(
              onPressed: () async {
                final ok = await context.showAdaptiveConfirm(
                  title: context.l10n.removeFromHistory,
                  content: context.l10n.removeFromHistoryConfirmation,
                  confirmLabel: context.l10n.remove,
                  cancelLabel: context.l10n.cancel,
                  isDestructive: true,
                );
                if (ok) onRemove();
              },
              icon: Icon(
                isCupertinoPlatform
                    ? CupertinoIcons.trash
                    : Icons.delete_outline_rounded,
                color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                size: 20,
              ),
              tooltip: context.l10n.remove,
            ),
          ],
        ),
      ),
    );

    if (isCupertinoPlatform) return tile;

    return Dismissible(
      key: ValueKey('history-${item.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: cs.errorContainer,
        child: Icon(Icons.delete_outline_rounded, color: cs.onErrorContainer),
      ),
      confirmDismiss: (_) => context.showAdaptiveConfirm(
        title: context.l10n.removeFromHistory,
        content: context.l10n.removeFromHistoryConfirmation,
        confirmLabel: context.l10n.remove,
        cancelLabel: context.l10n.cancel,
        isDestructive: true,
      ),
      onDismissed: (_) => onRemove(),
      child: tile,
    );
  }

  void _showMenu(BuildContext context) {
    showAdaptiveBottomSheet(
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
                        unawaited(context.showAdaptiveConfirm(
                          title: context.l10n.removeFromHistory,
                          content: context.l10n.removeFromHistoryConfirmation,
                          confirmLabel: context.l10n.remove,
                          cancelLabel: context.l10n.cancel,
                          isDestructive: true,
                        ).then((confirmed) {
                          if (confirmed) onRemove();
                        }));
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

  void _navigateToReader(BuildContext context, WidgetRef ref) {
    openReaderFromHistoryItem(context, ref, item);
  }

  void _navigateToManga(BuildContext context) =>
      MangaRoute(mangaId: item.mangaId).push(context);
}
