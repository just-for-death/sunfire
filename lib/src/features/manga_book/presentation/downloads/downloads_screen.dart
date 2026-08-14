import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../utils/extensions/custom_extensions.dart';
import '../../../../utils/misc/toast/toast.dart';
import '../../../../utils/platform/platform_ui.dart';
import '../../../../widgets/emoticons.dart';
import '../../../../widgets/shell/ios/glass_app_bar.dart';
import '../../data/downloads/downloads_repository.dart';
import '../../data/local_downloads/local_downloads_service.dart';
import '../../domain/downloads/downloads_model.dart';
import '../manga_details/controller/manga_details_controller.dart';
import '../reader/controller/reader_controller.dart';
import 'controller/downloads_controller.dart';
import 'widgets/download_progress_list_tile.dart';
import 'widgets/downloads_fab.dart';
import 'widgets/local_downloads_list.dart';

class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toast = ref.watch(toastProvider);
    final downloadsChapterIds = ref.watch(downloadsChapterIdsProvider);
    final downloadsGlobalStatus = ref.watch(downloaderStateProvider);
    final showDownloadsFAB = ref.watch(showDownloadsFABProvider);
    final localDownloadedIds = ref.watch(localDownloadedChapterIdsProvider);
    final cs = context.theme.colorScheme;

    return Scaffold(
      backgroundColor: isCupertinoPlatform
          ? context.theme.scaffoldBackgroundColor
          : null,
      extendBodyBehindAppBar: false,
      appBar: adaptiveGlassAppBar(
        context: context,
        title: Text(
          context.l10n.downloads,
          style: context.theme.textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(localDownloadedChapterIdsProvider),
            icon: const Icon(Icons.refresh_rounded),
            tooltip: context.l10n.retry,
          ),
          if (downloadsChapterIds.isNotBlank)
            IconButton(
              onPressed: () async =>
                  (await AsyncValue.guard(
                    ref.read(downloadsRepositoryProvider).clearDownloads,
                  ))
                      .showToastOnError(ref.read(toastProvider)),
              icon: const Icon(Icons.delete_sweep_rounded),
              tooltip: context.l10n.remove,
            ),
          localDownloadedIds.maybeWhen(
            data: (ids) => ids.isNotEmpty
                ? IconButton(
                    onPressed: () async {
                      final ok = await context.showAdaptiveConfirm(
                            title: context.l10n.deleteOfflineDownloadsTitle,
                            content: context.l10n
                                .deleteOfflineDownloadsBody(ids.length),
                            confirmLabel: context.l10n.remove,
                            cancelLabel: context.l10n.cancel,
                            isDestructive: true,
                          );
                      if (!ok || !context.mounted) return;
                      // Deleting is a long await chain; leaving the screen
                      // part-way would make `ref` throw, so go through the
                      // container captured while mounted.
                      final container =
                          ProviderScope.containerOf(context, listen: false);
                      final service = ref.read(localDownloadsServiceProvider);
                      final mangaIds = <int>{};
                      for (final id in ids) {
                        final manifest = await service.getOfflineManifest(id);
                        if (manifest != null) mangaIds.add(manifest.mangaId);
                        await service.deleteChapter(id);
                        container.invalidate(chapterPagesProvider(chapterId: id));
                      }
                      for (final mangaId in mangaIds) {
                        container
                            .invalidate(mangaChapterListProvider(mangaId: mangaId));
                        container.invalidate(mangaWithIdProvider(mangaId: mangaId));
                      }
                      container.invalidate(localDownloadedChapterIdsProvider);
                      container.invalidate(localDownloadedMangaIdsProvider);
                      container.invalidate(offlineStorageSizeProvider);
                    },
                    icon: const Icon(Icons.delete_outline_rounded),
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      floatingActionButton: showDownloadsFAB
          ? DownloadsFab(
              status:
                  downloadsGlobalStatus.valueOrNull ?? DownloaderState.STARTED)
          : null,
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              tabs: [
                Tab(
                  icon: const Icon(Icons.cloud_download_rounded),
                  text: context.l10n.downloadsTabServer,
                ),
                Tab(
                  icon: const Icon(Icons.download_done_rounded),
                  text: context.l10n.downloadsTabOffline,
                ),
              ],
              indicator: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
            ),
            const SizedBox(height: 4),
            Expanded(
              child: TabBarView(
                children: [
                  // Server downloads tab — Futon grouped card style
                  downloadsGlobalStatus.showUiWhenData(
                    context,
                    (data) {
                      if (data == null) {
                        return Emoticons(
                            title: context.l10n.errorSomethingWentWrong);
                      } else if (downloadsChapterIds.isBlank) {
                        return Emoticons(title: context.l10n.noDownloads);
                      }
                      final inProgress = downloadsChapterIds
                          .where((id) =>
                              ref.watch(downloadsFromIdProvider(id))?.state ==
                              DownloadState.DOWNLOADING)
                          .toList();
                      final queued = downloadsChapterIds
                          .where((id) =>
                              ref.watch(downloadsFromIdProvider(id))?.state !=
                              DownloadState.DOWNLOADING)
                          .toList();

                      final rows = <_DownloadListRow>[
                        if (inProgress.isNotEmpty) ...[
                          _DownloadListRow.header(
                            context.l10n.downloadsInProgress,
                            Icons.downloading_rounded,
                          ),
                          // Positions are absolute in the queue: the headers
                          // only group the list visually, while reorder sends
                          // the index straight to the server.
                          ...inProgress.map(
                            (id) => _DownloadListRow.tile(
                              chapterId: id,
                              index: downloadsChapterIds.indexOf(id),
                              listLength: downloadsChapterIds.length,
                            ),
                          ),
                        ],
                        if (queued.isNotEmpty) ...[
                          _DownloadListRow.header(
                            context.l10n.downloadsQueued,
                            Icons.queue_rounded,
                          ),
                          ...queued.map(
                            (id) => _DownloadListRow.tile(
                              chapterId: id,
                              index: downloadsChapterIds.indexOf(id),
                              listLength: downloadsChapterIds.length,
                            ),
                          ),
                        ],
                      ];

                      return RefreshIndicator(
                        onRefresh: () =>
                            ref.refresh(downloadStatusProvider.future),
                        child: ListView.builder(
                          padding: EdgeInsets.fromLTRB(
                            0,
                            8,
                            0,
                            scrollBottomInset(
                              hasFab: showDownloadsFAB,
                              context: context,
                            ),
                          ),
                          itemCount: rows.length,
                          itemBuilder: (context, i) {
                            final row = rows[i];
                            if (row.isHeader) {
                              return _SectionHeader(
                                label: row.label!,
                                icon: row.icon!,
                              );
                            }
                            return DownloadProgressListTile(
                              key: ValueKey(row.chapterId),
                              index: row.index!,
                              downloadsCount: row.listLength!,
                              chapterId: row.chapterId!,
                              toast: toast,
                            );
                          },
                        ),
                      );
                    },
                    showGenericError: true,
                  ),
                  // Offline tab
                  _OfflineTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DownloadListRow {
  const _DownloadListRow.header(this.label, this.icon)
      : chapterId = null,
        index = null,
        listLength = null;

  const _DownloadListRow.tile({
    required this.chapterId,
    required this.index,
    required this.listLength,
  })  : label = null,
        icon = null;

  final String? label;
  final IconData? icon;
  final int? chapterId;
  final int? index;
  final int? listLength;

  bool get isHeader => label != null;
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
        child: Row(
          children: [
            Icon(icon, size: 16, color: context.theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: context.theme.textTheme.labelLarge?.copyWith(
                color: context.theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      );
}

class _OfflineTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storageSizeAsync = ref.watch(offlineStorageSizeProvider);
    return Column(
      children: [
        storageSizeAsync.maybeWhen(
          data: (bytes) {
            if (bytes == 0) return const SizedBox.shrink();
            final mb = bytes / (1024 * 1024);
            final label = mb >= 1
                ? context.l10n.offlineStorageUsedMb(mb.toStringAsFixed(1))
                : context.l10n.offlineStorageUsedKb(
                    (bytes / 1024).toStringAsFixed(0),
                  );
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: context.theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.6),
              child: Row(
                children: [
                  Icon(Icons.storage_rounded,
                      size: 16,
                      color: context.theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text(label,
                      style: context.theme.textTheme.labelMedium?.copyWith(
                          color: context.theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            );
          },
          orElse: () => const SizedBox.shrink(),
        ),
        const Expanded(child: LocalDownloadsList()),
      ],
    );
  }
}
