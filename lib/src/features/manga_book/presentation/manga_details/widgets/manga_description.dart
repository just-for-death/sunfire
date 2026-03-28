import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../constants/enum.dart';
import '../../../../../routes/router_config.dart';
import '../../../../../utils/extensions/custom_extensions.dart';
import '../../../../../utils/launch_url_in_web.dart';
import '../../../../../utils/misc/toast/toast.dart';
import '../../../../../widgets/server_image.dart';
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
    final tt = context.theme.textTheme;

    final status = MangaStatus.fromJson(manga.status.name);
    final unread = manga.unreadCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Hero: cover + title + author
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ServerImage(
                  imageUrl: manga.thumbnailUrl ?? '',
                  size: const Size(110, 155),
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 14),
              // Title + author + action buttons
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () =>
                          GlobalSearchRoute(query: manga.title).push(context),
                      child: Text(
                        manga.title,
                        style: tt.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (manga.author.isNotBlank) ...[
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () => GlobalSearchRoute(query: manga.author)
                            .push(context),
                        child: Text(
                          manga.author ?? '',
                          style: tt.bodyMedium
                              ?.copyWith(color: cs.onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    // Favourite / WebView / Tracking buttons
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
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
                            onTap: () => launchUrlInWeb(context,
                                manga.realUrl ?? '', ref.read(toastProvider)),
                          ),
                        _ActionChip(
                          icon: Icons.track_changes_rounded,
                          label: 'Tracking',
                          onTap: () => showMangaTrackerSheet(
                              context, mangaId, manga.title),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Info card (Futon style)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Material(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
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

        // ── Description
        if (manga.description.isNotBlank) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                          cs.surface.withOpacity(0),
                          cs.surface.withOpacity(0.9),
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
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
          borderRadius: BorderRadius.circular(20),
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
