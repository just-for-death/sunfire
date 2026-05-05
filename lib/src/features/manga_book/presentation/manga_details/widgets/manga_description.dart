import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../constants/enum.dart';
import '../../../../../routes/router_config.dart';
import '../../../../../theme/komikku_ui_tokens.dart';
import '../../../../../utils/extensions/custom_extensions.dart';
import '../../../../../utils/launch_url_in_web.dart';
import '../../../../../utils/misc/toast/toast.dart';
import '../../../../tracking/presentation/manga_tracker_sheet.dart';
import '../../../domain/manga/manga_model.dart';

class MangaDescription extends HookConsumerWidget {
  const MangaDescription({
    super.key,
    required this.manga,
    required this.mangaId,
    required this.removeMangaFromLibrary,
    required this.addMangaToLibrary,
    required this.refresh,
  });
  final MangaDto manga;
  final int mangaId;
  final AsyncCallback refresh;
  final AsyncCallback removeMangaFromLibrary;
  final AsyncCallback addMangaToLibrary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpanded = useState(context.isTablet);
    final cs = context.theme.colorScheme;

    final status = MangaStatus.fromJson(manga.status.name);
    final unread = manga.unreadCount;
    final downloaded = manga.downloadCount;
    final inLibrary = manga.inLibrary.ifNull();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Hero: cover + title + author
        // ── Action Buttons
        Padding(
          padding: const EdgeInsets.fromLTRB(
            KomikkuUiTokens.space16,
            KomikkuUiTokens.space16,
            KomikkuUiTokens.space16,
            0,
          ),
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.start,
            children: [
              _ActionChip(
                icon: manga.inLibrary.ifNull()
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_outlined,
                label: manga.inLibrary.ifNull()
                    ? context.l10n.inLibrary
                    : context.l10n.addToLibrary,
                filled: manga.inLibrary.ifNull(),
                onTap: () async {
                  final val = await AsyncValue.guard(() async {
                    if (manga.inLibrary.ifNull()) {
                      await removeMangaFromLibrary();
                    } else {
                      await addMangaToLibrary();
                    }
                    await refresh();
                  });
                  if (context.mounted) {
                    val.showToastOnError(ref.read(toastProvider));
                  }
                },
              ),
              if (manga.realUrl.isNotBlank)
                _ActionChip(
                  icon: Icons.public_rounded,
                  label: context.l10n.webView,
                  onTap: () => launchUrlInWeb(
                      context, manga.realUrl ?? '', ref.read(toastProvider)),
                ),
              _ActionChip(
                icon: Icons.track_changes_rounded,
                label: 'Tracking',
                onTap: () =>
                    showMangaTrackerSheet(context, mangaId, manga.title),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Info card (Futon style)
        Padding(
          padding: KomikkuUiTokens.screenPadding,
          child: Material(
            color: cs.surfaceContainerHigh,
            borderRadius: KomikkuUiTokens.cardRadius,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  if (manga.source?.name.isNotBlank == true)
                    _InfoRow(
                      label: 'Source',
                      value: manga.source!.name,
                      valueColor: cs.primary,
                    ),
                  _InfoRow(
                    label: 'Status',
                    value: status.toLocale(context),
                    icon: status.icon,
                  ),
                  if (manga.author.isNotBlank)
                    _InfoRow(label: 'Author', value: manga.author!),
                  if (manga.artist.isNotBlank && manga.artist != manga.author)
                    _InfoRow(label: 'Artist', value: manga.artist!),
                  _InfoRow(
                    label: 'Unread',
                    value: '$unread chapter${unread == 1 ? '' : 's'}',
                  ),
                  // Progress bar hidden until chapter list known
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: KomikkuUiTokens.screenPadding,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatChip(
                icon: Icons.menu_book_rounded,
                label: context.l10n.unread,
                value: '$unread',
              ),
              _StatChip(
                icon: Icons.download_done_rounded,
                label: context.l10n.downloaded,
                value: '$downloaded',
              ),
              _StatChip(
                icon: inLibrary
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                label: context.l10n.library,
                value: inLibrary ? context.l10n.yes : context.l10n.no,
              ),
            ],
          ),
        ),

        // ── Description
        if (manga.description.isNotBlank) ...[
          const SizedBox(height: 12),
          Padding(
            padding: KomikkuUiTokens.screenPadding,
            child: Stack(
              alignment: AlignmentDirectional.bottomStart,
              children: [
                Text(
                  '${manga.description}\n',
                  maxLines: isExpanded.value ? null : 3,
                ),
                if (!isExpanded.value)
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          cs.surface.withValues(alpha: 0),
                          cs.surface.withValues(alpha: 0.9),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: const SizedBox(height: 32, width: double.infinity),
                  ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: GestureDetector(
                    onTap: () => isExpanded.value = !isExpanded.value,
                    child: Container(
                      color: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      child: Icon(
                        isExpanded.value
                            ? Icons.expand_less_rounded
                            : Icons.expand_more_rounded,
                        color: cs.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // ── Genre chips
        if (isExpanded.value && manga.genre.isNotBlank) ...[
          const SizedBox(height: 10),
          Padding(
            padding: KomikkuUiTokens.screenPadding,
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: manga.genre
                  .map((g) => ActionChip(
                        label: Text(g),
                        onPressed: () =>
                            GlobalSearchRoute(query: g).push(context),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ))
                  .toList(),
            ),
          ),
        ],
        if (isExpanded.value) ...[
          const SizedBox(height: 10),
          Padding(
            padding: KomikkuUiTokens.screenPadding,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () =>
                      GlobalSearchRoute(query: manga.title).push(context),
                  icon:
                      const Icon(Icons.collections_bookmark_rounded, size: 16),
                  label: const Text('Related'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    if (manga.author.isNotBlank) {
                      GlobalSearchRoute(query: manga.author!).push(context);
                    }
                  },
                  icon: const Icon(Icons.thumb_up_alt_outlined, size: 16),
                  label: const Text('Recommendations'),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 8),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.icon,
    this.valueColor,
  });
  final String label;
  final String value;
  final IconData? icon;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
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
            Icon(icon, size: 14, color: valueColor ?? cs.onSurface),
            const SizedBox(width: 4),
          ],
          Expanded(
            child: Text(
              value,
              style: context.theme.textTheme.bodySmall?.copyWith(
                color: valueColor ?? cs.onSurface,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: filled ? cs.primaryContainer : cs.surfaceContainerHigh,
          borderRadius: KomikkuUiTokens.chipRadius,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 14,
                color: filled ? cs.onPrimaryContainer : cs.onSurfaceVariant),
            const SizedBox(width: 5),
            Text(
              label,
              style: context.theme.textTheme.labelSmall?.copyWith(
                color: filled ? cs.onPrimaryContainer : cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: KomikkuUiTokens.chipRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: cs.primary),
          const SizedBox(width: 6),
          Text(
            '$label: $value',
            style: context.theme.textTheme.labelMedium?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
