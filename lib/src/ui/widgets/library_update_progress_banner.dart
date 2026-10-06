import 'package:flutter/material.dart';

import '../../core/services/library_update_service.dart';

/// Human-readable skipped line for the library-update banner (ISS-086 / Q4).
///
/// Returns null when both counts are zero so the UI can omit the row.
String? libraryUpdateSkippedLabel({
  required int skippedCategoriesCount,
  required int skippedMangasCount,
}) {
  if (skippedCategoriesCount <= 0 && skippedMangasCount <= 0) return null;
  final parts = <String>[];
  if (skippedCategoriesCount > 0) {
    parts.add(
      skippedCategoriesCount == 1
          ? '1 category skipped'
          : '$skippedCategoriesCount categories skipped',
    );
  }
  if (skippedMangasCount > 0) {
    parts.add(
      skippedMangasCount == 1
          ? '1 manga skipped'
          : '$skippedMangasCount manga skipped',
    );
  }
  return parts.join(' · ');
}

/// Non-blocking library refresh progress (Komikku / Aidoku style).
///
/// Listens to [LibraryUpdateService] and hides itself when idle.
class LibraryUpdateProgressBanner extends StatelessWidget {
  const LibraryUpdateProgressBanner({
    super.key,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.asSliver = false,
  });

  final EdgeInsetsGeometry margin;
  final bool asSliver;

  @override
  Widget build(BuildContext context) {
    final body = ListenableBuilder(
      listenable: LibraryUpdateService.instance,
      builder: (context, _) {
        final updater = LibraryUpdateService.instance;
        if (!updater.isUpdating) return const SizedBox.shrink();
        final cs = Theme.of(context).colorScheme;
        final primary = cs.primary;
        final skipped = libraryUpdateSkippedLabel(
          skippedCategoriesCount: updater.skippedCategoriesCount,
          skippedMangasCount: updater.skippedMangasCount,
        );
        return Container(
          key: const Key('library_update_progress_banner'),
          margin: margin,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: primary.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(primary),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      updater.statusMessage,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: cs.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (skipped != null) ...[
                const SizedBox(height: 6),
                Text(
                  skipped,
                  key: const Key('library_update_skipped_label'),
                  style: TextStyle(
                    fontSize: 11.5,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: updater.progress > 0 ? updater.progress : null,
                  minHeight: 4,
                  backgroundColor: cs.onSurface.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(primary),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (asSliver) return SliverToBoxAdapter(child: body);
    return body;
  }
}
