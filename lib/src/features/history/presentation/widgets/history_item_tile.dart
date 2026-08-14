import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../routes/router_config.dart';
import '../../../../theme/catalyst_ui_tokens.dart';
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

  int get _readPercentInt => (historyItemReadProgress(item) * 100).round();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = context.theme.colorScheme;
    const radius = CatalystUiTokens.coverRadius;
    final tile = Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: radius,
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
        // Hover / ripple / focus affordance for pointer devices.
        Positioned.fill(
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: radius,
              onTap: () => _navigateToReader(context, ref),
              onLongPress: () => _showMenu(context),
            ),
          ),
        ),
      ],
    );

    if (isCupertinoPlatform) return tile;

    return Dismissible(
      key: ValueKey('history-${item.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: cs.errorContainer,
          borderRadius: CatalystUiTokens.coverRadius,
        ),
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
