import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../routes/router_config.dart';
import '../../../../utils/extensions/custom_extensions.dart';
import '../../../../widgets/server_image.dart';
import '../../domain/history_item.dart';
import '../history_reader_navigation.dart';

/// Detail pane for tablet master–detail history layout.
class HistoryDetailPane extends ConsumerWidget {
  const HistoryDetailPane({super.key, required this.item});

  final HistoryItemDto item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = context.theme.colorScheme;
    final progress = historyItemReadProgress(item);

    return ColoredBox(
      color: cs.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ServerImage(
                    imageUrl: item.manga.thumbnailUrl ?? '',
                    size: const Size(160, 230),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                item.manga.title,
                style: context.theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                item.name,
                style: context.theme.textTheme.titleMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: progress,
                borderRadius: BorderRadius.circular(4),
                minHeight: 6,
              ),
              const SizedBox(height: 8),
              Text(
                historyItemIsCompleted(item)
                    ? context.l10n.completed
                    : '${(progress * 100).round()}%',
                style: context.theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () =>
                    openReaderFromHistoryItem(context, ref, item),
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(context.l10n.historyContinueReading),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () =>
                    MangaRoute(mangaId: item.mangaId).push(context),
                icon: const Icon(Icons.info_outline_rounded),
                label: Text(context.l10n.manga),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
