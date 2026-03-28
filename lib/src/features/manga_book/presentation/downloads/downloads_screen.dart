import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../utils/extensions/custom_extensions.dart';
import '../../../../utils/misc/toast/toast.dart';
import '../../../../widgets/emoticons.dart';
import '../../data/downloads/downloads_repository.dart';
import '../../data/local_downloads/local_downloads_service.dart';
import '../../domain/downloads/downloads_model.dart';
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
      appBar: AppBar(
        titleSpacing: 16,
        title: Text(
          context.l10n.downloads,
          style: context.theme.textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(localDownloadedChapterIdsProvider),
            icon: const Icon(Icons.refresh_rounded),
          ),
          if (downloadsChapterIds.isNotBlank)
            IconButton(
              onPressed: () => AsyncValue.guard(
                ref.read(downloadsRepositoryProvider).clearDownloads,
              ),
              icon: const Icon(Icons.delete_sweep_rounded),
            ),
          localDownloadedIds.maybeWhen(
            data: (ids) => ids.isNotEmpty
                ? IconButton(
                    onPressed: () async {
                      final ok = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete offline downloads?'),
                              content: Text(
                                  'This will remove ${ids.length} offline chapter(s) from this device.'),
                              actions: [
                                TextButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(false),
                                    child: const Text('Cancel')),
                                FilledButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(true),
                                    child: const Text('Delete')),
                              ],
                            ),
                          ) ??
                          false;
                      if (!ok) return;
                      final service = ref.read(localDownloadsServiceProvider);
                      for (final id in ids) {
                        await service.deleteChapter(id);
                      }
                      ref.invalidate(localDownloadedChapterIdsProvider);
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
                  text: 'Server',
                ),
                Tab(
                  icon: const Icon(Icons.download_done_rounded),
                  text: 'Offline',
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
                      return RefreshIndicator(
                        onRefresh: () =>
                            ref.refresh(downloadStatusProvider.future),
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(0, 8, 0, 96),
                          children: [
                            if (inProgress.isNotEmpty) ...[
                              _SectionHeader(
                                  label: 'In progress',
                                  icon: Icons.downloading_rounded),
                              ...inProgress.asMap().entries.map((e) =>
                                  DownloadProgressListTile(
                                    key: ValueKey(e.value),
                                    index: e.key,
                                    downloadsCount: inProgress.length,
                                    chapterId: e.value,
                                    toast: toast,
                                  )),
                            ],
                            if (queued.isNotEmpty) ...[
                              _SectionHeader(
                                  label: 'Queued',
                                  icon: Icons.queue_rounded),
                              ...queued.asMap().entries.map((e) =>
                                  DownloadProgressListTile(
                                    key: ValueKey(e.value),
                                    index: e.key,
                                    downloadsCount: queued.length,
                                    chapterId: e.value,
                                    toast: toast,
                                  )),
                            ],
                            const Gap(104),
                          ],
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
        child: Row(
          children: [
            Icon(icon, size: 16,
                color: context.theme.colorScheme.primary),
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
                ? '${mb.toStringAsFixed(1)} MB used on device'
                : '${(bytes / 1024).toStringAsFixed(0)} KB used on device';
            return Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          color:
                              context.theme.colorScheme.onSurfaceVariant)),
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
