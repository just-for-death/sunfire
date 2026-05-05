import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/manga_book/data/updates/updates_repository.dart';
import '../../features/manga_book/domain/update_status/update_status_model.dart';
import '../../utils/extensions/custom_extensions.dart';

class TopStateBanners extends ConsumerWidget {
  const TopStateBanners({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(updatesSocketProvider).valueOrNull;
    if (status == null) return const SizedBox.shrink();
    if (!status.isUpdateChecking && status.completeJobs.mangas.totalCount == 0) {
      return const SizedBox.shrink();
    }

    final cs = context.theme.colorScheme;
    final label = status.isUpdateChecking
        ? '${context.l10n.updates}: ${status.updateChecked}/${status.total}'
        : '${context.l10n.updates}: ${status.completeJobs.mangas.totalCount}';

    return Material(
      color: cs.secondaryContainer,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                if (status.isUpdateChecking)
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: cs.onSecondaryContainer,
                    ),
                  )
                else
                  Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: cs.onSecondaryContainer,
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: context.theme.textTheme.labelMedium?.copyWith(
                      color: cs.onSecondaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
