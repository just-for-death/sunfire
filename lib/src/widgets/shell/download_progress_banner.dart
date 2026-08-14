import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/manga_book/domain/downloads/downloads_model.dart';
import '../../features/manga_book/presentation/downloads/controller/downloads_controller.dart';
import '../../routes/router_config.dart';
import '../../utils/extensions/custom_extensions.dart';
import '../../utils/platform/platform_ui.dart';

/// Active background download status banner shown in the navigation shell.
class DownloadProgressBanner extends HookConsumerWidget {
  const DownloadProgressBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadsGlobalStatus = ref.watch(downloaderStateProvider);
    final downloadsChapterIds = ref.watch(downloadsChapterIdsProvider);

    final isStarted = downloadsGlobalStatus.valueOrNull == DownloaderState.STARTED;
    if (!isStarted || downloadsChapterIds.isBlank) {
      return const SizedBox.shrink();
    }

    final cs = context.theme.colorScheme;
    final totalCount = downloadsChapterIds.length;

    return Material(
      color: cs.primaryContainer,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                Icon(
                  isCupertinoPlatform
                      ? CupertinoIcons.arrow_down_circle_fill
                      : Icons.downloading_rounded,
                  size: 20,
                  color: cs.onPrimaryContainer,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    context.l10n.noOfChapters(totalCount),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.theme.textTheme.labelMedium?.copyWith(
                      color: cs.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => const DownloadsRoute().go(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    context.l10n.downloads,
                    style: TextStyle(
                      color: cs.primary,
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
