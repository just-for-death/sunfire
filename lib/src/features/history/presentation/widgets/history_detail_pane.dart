import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../constants/enum.dart';
import '../../../../routes/router_config.dart';
import '../../../../theme/catalyst_ui_tokens.dart';
import '../../../../utils/extensions/custom_extensions.dart';
import '../../../../widgets/server_image.dart';
import '../../domain/history_item.dart';
import '../history_reader_navigation.dart';

/// Detail pane for tablet master–detail history layout.
class HistoryDetailPane extends HookConsumerWidget {
  const HistoryDetailPane({super.key, required this.item});

  final HistoryItemDto item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = context.theme.colorScheme;
    final progress = historyItemReadProgress(item);
    final completed = historyItemIsCompleted(item);
    final manga = item.manga;

    final detailsExpanded = useState(true);

    return ColoredBox(
      color: cs.surface,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(CatalystUiTokens.space24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: CatalystUiTokens.coverRadius,
                      child: ServerImage(
                        imageUrl: manga.thumbnailUrl ?? '',
                        size: const Size(160, 230),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: CatalystUiTokens.space16),
                  Text(
                    manga.title,
                    style: context.theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: CatalystUiTokens.space8),
                  Text(
                    item.name,
                    style: context.theme.textTheme.titleMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: CatalystUiTokens.space16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                      CatalystUiTokens.radiusExtraSmall,
                    ),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      color: completed ? cs.secondary : cs.primary,
                    ),
                  ),
                  const SizedBox(height: CatalystUiTokens.space8),
                  Text(
                    completed
                        ? context.l10n.completed
                        : '${(progress * 100).round()}%'
                            '${item.pageCount > 0 ? ' · ${item.lastPageRead + 1}/${item.pageCount}' : ''}',
                    style: context.theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: CatalystUiTokens.space24),
                  FilledButton.icon(
                    onPressed: () =>
                        openReaderFromHistoryItem(context, ref, item),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(context.l10n.historyContinueReading),
                  ),
                  const SizedBox(height: CatalystUiTokens.space8),
                  OutlinedButton.icon(
                    onPressed: () =>
                        MangaRoute(mangaId: item.mangaId).push(context),
                    icon: const Icon(Icons.info_outline_rounded),
                    label: Text(context.l10n.manga),
                  ),
                  const SizedBox(height: CatalystUiTokens.space16),
                  _CollapsibleSection(
                    title: context.l10n.details,
                    expanded: detailsExpanded.value,
                    onToggle: () =>
                        detailsExpanded.value = !detailsExpanded.value,
                    child: _HistoryDetails(item: item),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Header bar that expands and collapses its [child].
class _CollapsibleSection extends StatelessWidget {
  const _CollapsibleSection({
    required this.title,
    required this.expanded,
    required this.onToggle,
    required this.child,
  });

  final String title;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    return Material(
      color: cs.surfaceContainerLow,
      borderRadius: CatalystUiTokens.cardRadius,
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: CatalystUiTokens.space12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: context.theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: CatalystUiTokens.durationShort,
                    curve: CatalystUiTokens.curveStandard,
                    child: Icon(
                      Icons.expand_more_rounded,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: CatalystUiTokens.durationShort,
            curve: CatalystUiTokens.curveStandard,
            alignment: Alignment.topCenter,
            child: expanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                    child: child,
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _HistoryDetails extends StatelessWidget {
  const _HistoryDetails({required this.item});

  final HistoryItemDto item;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final manga = item.manga;
    final status = MangaStatus.fromJson(manga.status.name);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoRow(
          label: context.l10n.trackingStatus,
          value: status.toLocale(context),
          icon: status.icon,
        ),
        if (manga.author.isNotBlank)
          _InfoRow(label: context.l10n.author, value: manga.author!),
        if (manga.artist.isNotBlank && manga.artist != manga.author)
          _InfoRow(label: context.l10n.artist, value: manga.artist!),
        if (item.scanlator.isNotBlank)
          _InfoRow(label: context.l10n.scanlator, value: item.scanlator!),
        _InfoRow(
          label: context.l10n.unread,
          value: '${manga.unreadCount}',
        ),
        if (manga.genre.isNotEmpty) ...[
          const SizedBox(height: CatalystUiTokens.space12),
          Text(
            context.l10n.genres,
            style: context.theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: CatalystUiTokens.space8),
          Wrap(
            spacing: CatalystUiTokens.space6,
            runSpacing: CatalystUiTokens.space6,
            children: manga.genre
                .map(
                  (g) => ActionChip(
                    label: Text(g),
                    onPressed: () => GlobalSearchRoute(query: g).push(context),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                )
                .toList(),
          ),
        ],
        if (manga.description.isNotBlank) ...[
          const SizedBox(height: CatalystUiTokens.space12),
          Text(
            manga.description!,
            style: context.theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ],
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.icon});

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: context.theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (icon != null) ...[
            Icon(icon, size: 14, color: cs.onSurface),
            const SizedBox(width: CatalystUiTokens.space4),
          ],
          Expanded(
            child: Text(
              value,
              style: context.theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
