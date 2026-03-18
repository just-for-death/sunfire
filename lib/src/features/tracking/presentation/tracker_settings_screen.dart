// Copyright (c) 2022 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../utils/extensions/custom_extensions.dart';
import '../../../utils/misc/toast/toast.dart';
import '../domain/tracker_model.dart';
import 'controller/tracker_controller.dart';
import 'widgets/tracker_login_dialog.dart';

class TrackerSettingsScreen extends ConsumerWidget {
  const TrackerSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackersAsync = ref.watch(trackersProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Trackers')),
      body: trackersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48),
              const SizedBox(height: 12),
              Text(e.toString(), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => ref.invalidate(trackersProvider),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(context.l10n.retry),
              ),
            ],
          ),
        ),
        data: (trackers) => trackers.isEmpty
            ? Center(child: Text(context.l10n.noResultFound))
            : ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: trackers.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) =>
                    _TrackerTile(tracker: trackers[i]),
              ),
      ),
    );
  }
}

class _TrackerTile extends ConsumerWidget {
  const _TrackerTile({required this.tracker});
  final TrackerDto tracker;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: CachedNetworkImage(
          imageUrl: tracker.icon,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context.theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.track_changes_rounded),
          ),
        ),
      ),
      title: Text(
        tracker.name,
        style: context.textTheme.titleMedium
            ?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Row(
        children: [
          Icon(
            tracker.isLoggedIn
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            size: 14,
            color: tracker.isLoggedIn
                ? Colors.green
                : context.theme.colorScheme.outline,
          ),
          const SizedBox(width: 4),
          Text(
            tracker.isLoggedIn
                ? 'Logged in'
                : 'Not logged in',
            style: context.textTheme.bodySmall?.copyWith(
              color: tracker.isLoggedIn
                  ? Colors.green
                  : context.theme.colorScheme.outline,
            ),
          ),
          if (tracker.isTokenExpired == true) ...[
            const SizedBox(width: 6),
            Text(
              '(token expired)',
              style: context.textTheme.bodySmall
                  ?.copyWith(color: context.theme.colorScheme.error),
            ),
          ],
        ],
      ),
      trailing: tracker.isLoggedIn
          ? OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: context.theme.colorScheme.error,
                side:
                    BorderSide(color: context.theme.colorScheme.error),
              ),
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: Text('Log Out'),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text('Log Out'),
                    content: Text(
                        'Log out from ${tracker.name}?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(context.l10n.cancel),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text('Log Out'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && context.mounted) {
                  await ref
                      .read(trackerAuthNotifierProvider.notifier)
                      .logout(tracker.id);
                  final state = ref.read(trackerAuthNotifierProvider);
                  if (context.mounted && state.hasError) {
                    ref
                        .read(toastProvider)
                        ?.showError(state.error.toString());
                  }
                }
              },
            )
          : FilledButton.icon(
              icon: const Icon(Icons.login_rounded, size: 18),
              label: Text('Log In'),
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (_) => TrackerLoginDialog(tracker: tracker),
                );
              },
            ),
    );
  }
}
