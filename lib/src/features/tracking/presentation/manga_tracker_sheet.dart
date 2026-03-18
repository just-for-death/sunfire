// Copyright (c) 2022 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../routes/router_config.dart';
import '../../../utils/extensions/custom_extensions.dart';
import '../../../utils/misc/toast/toast.dart';
import '../data/tracker_repository.dart';
import '../domain/tracker_model.dart';
import 'controller/tracker_controller.dart';
import 'tracker_search_screen.dart';
import 'widgets/tracker_edit_dialog.dart';

/// Shows the tracker sheet as a modal bottom sheet.
Future<void> showMangaTrackerSheet(
  BuildContext context,
  int mangaId,
  String mangaTitle,
) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => MangaTrackerSheet(
      mangaId: mangaId,
      mangaTitle: mangaTitle,
    ),
  );
}

class MangaTrackerSheet extends ConsumerWidget {
  const MangaTrackerSheet({
    super.key,
    required this.mangaId,
    required this.mangaTitle,
  });

  final int mangaId;
  final String mangaTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackersAsync = ref.watch(trackersProvider);
    final recordsAsync = ref.watch(mangaTrackRecordsProvider(mangaId));

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.theme.colorScheme.onSurfaceVariant
                    .withOpacity(.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Title row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                const Icon(Icons.track_changes_rounded),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tracking',
                    style: context.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          Expanded(
            child: recordsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(e.toString())),
              data: (records) => ListView(
                controller: scrollController,
                padding: const EdgeInsets.only(bottom: 16),
                children: [
                  // Existing bound trackers
                  if (records.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.track_changes_rounded,
                              size: 48,
                              color: context.theme.colorScheme.outline,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No tracking entries yet',
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: context.theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...records.map(
                      (r) => _TrackRecordTile(
                        record: r,
                        mangaId: mangaId,
                      ),
                    ),

                  const Divider(),

                  // Add tracking section
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Text(
                      'Add Tracking',
                      style: context.textTheme.labelLarge?.copyWith(
                        color: context.theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  trackersAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (e, _) => ListTile(
                      leading: const Icon(Icons.error_outline_rounded),
                      title: Text(e.toString()),
                    ),
                    data: (trackers) => Column(
                      children: trackers
                          .where((t) => t.isLoggedIn)
                          .where((t) => !records
                              .any((r) => r.trackerId == t.id))
                          .map(
                            (tracker) => ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: CachedNetworkImage(
                                  imageUrl: tracker.icon,
                                  width: 32,
                                  height: 32,
                                  errorWidget: (_, __, ___) => const Icon(
                                      Icons.track_changes_rounded),
                                ),
                              ),
                              title: Text(tracker.name),
                              trailing:
                                  const Icon(Icons.add_circle_outline_rounded),
                              onTap: () async {
                                final added = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => TrackerSearchScreen(
                                      mangaId: mangaId,
                                      tracker: tracker,
                                      mangaTitle: mangaTitle,
                                    ),
                                  ),
                                );
                                if (added == true) {
                                  ref.invalidate(
                                      mangaTrackRecordsProvider(mangaId));
                                }
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  // Prompt to log in if no trackers logged in
                  if (trackersAsync.valueOrNull?.every((t) => !t.isLoggedIn) == true)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.login_rounded),
                        label: const Text('Log In to a tracker in Settings'),
                        onPressed: () {
                          Navigator.pop(context);
                          const TrackerSettingsRoute().push(context);
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackRecordTile extends ConsumerWidget {
  const _TrackRecordTile({required this.record, required this.mangaId});
  final TrackRecordDto record;
  final int mangaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          await showDialog(
            context: context,
            builder: (_) =>
                TrackerEditDialog(record: record, mangaId: mangaId),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 56,
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.track_changes_rounded),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _trackerLabel(record),
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.theme.colorScheme.primary,
                      ),
                    ),
                    if (record.title.isNotEmpty)
                      Text(
                        record.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 2,
                      children: [
                        if (record.status != null)
                          _InfoChip(
                            icon: Icons.bookmark_rounded,
                            label: _statusName(record),
                          ),
                        if (record.lastChapterRead != null)
                          _InfoChip(
                            icon: Icons.menu_book_rounded,
                            label:
                                'Ch. ${record.lastChapterRead!.toStringAsFixed(0)}'
                                '${record.totalChapters != null && record.totalChapters! > 0 ? '/${record.totalChapters}' : ''}',
                          ),
                        if (record.displayScore != null &&
                            record.displayScore!.isNotEmpty &&
                            record.displayScore != '0')
                          _InfoChip(
                            icon: Icons.star_rounded,
                            label: record.displayScore!,
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions column
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.sync_rounded),
                    tooltip: 'Sync now',
                    onPressed: () async {
                      try {
                        await ref
                            .read(trackerRepositoryProvider)
                            .fetchTrack(record.id);
                        ref.invalidate(mangaTrackRecordsProvider(mangaId));
                      } catch (e) {
                        if (context.mounted) {
                          ref
                              .read(toastProvider)
                              ?.showError(e.toString());
                        }
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline_rounded,
                        color: context.theme.colorScheme.error),
                    tooltip: context.l10n.remove,
                    onPressed: () => _confirmUnbind(context, ref),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _statusName(TrackRecordDto r) {
    if (r.status == null) return '—';
    // Use real statuses from tracker if available
    if (r.trackerStatuses != null) {
      final match = r.trackerStatuses!
          .where((s) => s.value == r.status)
          .map((s) => s.name)
          .firstOrNull;
      if (match != null) return match;
    }
    const labels = {
      1: 'Reading', 2: 'Completed', 3: 'On Hold',
      4: 'Dropped', 5: 'Plan to Read', 6: 'Re-reading',
    };
    return labels[r.status] ?? r.status.toString();
  }

  String _trackerLabel(TrackRecordDto r) {
    if (r.trackerName != null) return r.trackerName!;
    const names = {1: 'MyAnimeList', 2: 'AniList', 3: 'Kitsu', 4: 'Bangumi'};
    return names[r.trackerId] ?? 'Tracker #${r.trackerId}';
  }

  Future<void> _confirmUnbind(BuildContext context, WidgetRef ref) async {
    bool deleteRemote = false;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Remove tracking?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('This will remove the tracking entry from Catalyst. The entry on the tracker will not be deleted.'),
              const SizedBox(height: 12),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: deleteRemote,
                title: const Text('Also delete from tracker service'),
                onChanged: (v) => setState(() => deleteRemote = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: context.theme.colorScheme.error,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(context.l10n.remove),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref
          .read(trackerRepositoryProvider)
          .unbindTrack(record.id, deleteRemoteTrack: deleteRemote);
      ref.invalidate(mangaTrackRecordsProvider(mangaId));
    } catch (e) {
      if (context.mounted) {
        ref.read(toastProvider)?.showError(e.toString());
      }
    }
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 2),
        Text(label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                )),
      ],
    );
  }
}
