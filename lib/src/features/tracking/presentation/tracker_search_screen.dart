// Copyright (c) 2022 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../utils/extensions/custom_extensions.dart';
import '../../../utils/misc/toast/toast.dart';
import '../data/tracker_repository.dart';
import '../domain/tracker_model.dart';
import 'controller/tracker_controller.dart';

class TrackerSearchScreen extends HookConsumerWidget {
  const TrackerSearchScreen({
    super.key,
    required this.mangaId,
    required this.tracker,
    required this.mangaTitle,
  });

  final int mangaId;
  final TrackerDto tracker;
  final String mangaTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queryController = useTextEditingController(text: mangaTitle);
    final submittedQuery = useState(mangaTitle);
    final debounce = useRef<Timer?>(null);

    // Debounced search — fires 600ms after user stops typing
    void onQueryChanged(String v) {
      debounce.value?.cancel();
      debounce.value = Timer(const Duration(milliseconds: 600), () {
        final trimmed = v.trim();
        if (trimmed.isNotEmpty) submittedQuery.value = trimmed;
      });
    }

    useEffect(() => () => debounce.value?.cancel(), []);

    final results = ref.watch(trackerSearchProvider((
      trackerId: tracker.id,
      query: submittedQuery.value,
    )));

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Tracking — ${tracker.name}'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: TextField(
              controller: queryController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search on ${tracker.name}...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: queryController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          queryController.clear();
                          submittedQuery.value = '';
                          debounce.value?.cancel();
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: onQueryChanged,
              // Also allow explicit submit (Enter key)
              onSubmitted: (v) {
                debounce.value?.cancel();
                final trimmed = v.trim();
                if (trimmed.isNotEmpty) submittedQuery.value = trimmed;
              },
              textInputAction: TextInputAction.search,
            ),
          ),
        ),
      ),
      body: submittedQuery.value.isEmpty
          ? Center(
              child: Icon(Icons.search_rounded,
                  size: 56,
                  color: Theme.of(context).colorScheme.outline),
            )
          : results.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        _friendlyError(e.toString()),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: () => ref.invalidate(
                          trackerSearchProvider((
                            trackerId: tracker.id,
                            query: submittedQuery.value,
                          )),
                        ),
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text(context.l10n.retry),
                      ),
                    ],
                  ),
                ),
              ),
              data: (items) => items.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off_rounded, size: 48),
                          SizedBox(height: 12),
                          Text('No results found'),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) => _TrackerSearchResultTile(
                        result: items[i],
                        mangaId: mangaId,
                        trackerId: tracker.id,
                        trackerName: tracker.name,
                      ),
                    ),
            ),
    );
  }

  /// Convert server/network errors to user-friendly messages.
  String _friendlyError(String raw) {
    if (raw.contains('Collection is empty')) {
      return 'Could not bind — make sure you are logged in to ${tracker.name} in Settings → Trackers.';
    }
    if (raw.contains('TimeoutException') || raw.contains('No stream event')) {
      return 'Search timed out. ${tracker.name} may be slow — please retry.';
    }
    if (raw.contains('SocketException') || raw.contains('Failed host lookup')) {
      return 'No internet connection.';
    }
    return raw;
  }
}

// ── Tile ─────────────────────────────────────────────────────────────────────

class _TrackerSearchResultTile extends ConsumerWidget {
  const _TrackerSearchResultTile({
    required this.result,
    required this.mangaId,
    required this.trackerId,
    required this.trackerName,
  });

  final TrackerSearchResultDto result;
  final int mangaId;
  final int trackerId;
  final String trackerName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      onTap: () => _bind(context, ref),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: result.coverUrl != null
            ? CachedNetworkImage(
                imageUrl: result.coverUrl!,
                width: 44,
                height: 62,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  width: 44,
                  height: 62,
                  color:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                errorWidget: (_, __, ___) => Container(
                  width: 44,
                  height: 62,
                  color:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.image_not_supported_outlined),
                ),
              )
            : Container(
                width: 44,
                height: 62,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.image_not_supported_outlined),
              ),
      ),
      title: Text(
        result.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (result.publishingType != null)
            Text(result.publishingType!,
                style: Theme.of(context).textTheme.bodySmall),
          if (result.startDate != null)
            Text(result.startDate!,
                style: Theme.of(context).textTheme.bodySmall),
          if (result.totalChapters != null && result.totalChapters! > 0)
            Text('${result.totalChapters} chapters',
                style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
      isThreeLine: true,
    );
  }

  Future<void> _bind(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Tracking'),
        content: Text('Track "${result.title}" on $trackerName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Add Tracking'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;
    try {
      await ref
          .read(trackerRepositoryProvider)
          .bindTrack(mangaId, trackerId, result.remoteId);
      ref.invalidate(mangaTrackRecordsProvider(mangaId));
      if (context.mounted) Navigator.pop(context, true);
    } catch (e) {
      if (context.mounted) {
        final msg = e.toString().contains('Collection is empty')
            ? 'Not logged in to $trackerName. Go to Settings → Trackers.'
            : e.toString();
        ref.read(toastProvider)?.showError(msg);
      }
    }
  }
}
