// Copyright (c) 2026 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../constants/app_sizes.dart';
import '../../../utils/extensions/custom_extensions.dart';
import '../../../widgets/custom_circular_progress_indicator.dart';
import '../presentation/downloads/controller/local_downloads_controller.dart';

/// A standalone button shown next to each chapter row in the manga detail
/// screen. Tapping it downloads (or removes) the chapter to local device
/// storage — no popup menu required.
///
/// States:
///   idle, not downloaded  → outlined phone-download icon (tap → download)
///   downloading           → circular arc + "X/Y" page counter (tap = cancel intent shown as nothing, download continues)
///   downloaded            → filled green check-phone icon (tap → delete confirmation)
///   error                 → red error icon (tap → retry)
class LocalDownloadButton extends HookConsumerWidget {
  const LocalDownloadButton({
    super.key,
    required this.chapterId,
  });

  final int chapterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localState =
        ref.watch(localChapterDownloadProvider(chapterId: chapterId));
    final localNotifier =
        ref.read(localChapterDownloadProvider(chapterId: chapterId).notifier);

    // Re-check disk only when state changes (not on every frame).
    final isDownloadedFuture = useMemoized(
      () => localNotifier.isDownloaded(),
      [chapterId, localState],
    );
    final isDownloadedSnapshot = useFuture(isDownloadedFuture);
    final isDownloadedLocal = isDownloadedSnapshot.data ?? false;

    // ── Downloading — show arc progress + page counter ────────────────────
    if (localState == LocalDownloadState.downloading) {
      final progress =
          ref.watch(localDownloadProgressProvider(chapterId));
      final hasProgress = progress.total > 0;
      final fraction =
          hasProgress ? progress.current / progress.total : null;

      return SizedBox(
        width: 40,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MiniCircularProgressIndicator(
              color: context.theme.colorScheme.primary,
              value: fraction,
            ),
            if (hasProgress)
              Text(
                '${progress.current}/${progress.total}',
                style: TextStyle(
                  fontSize: 7,
                  color: context.theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
          ],
        ),
      );
    }

    // ── Error — red icon, tap to retry ───────────────────────────────────
    if (localState == LocalDownloadState.error) {
      return IconButton(
        tooltip: 'Retry offline download',
        icon: const Icon(Icons.error_outline_rounded, color: Colors.red),
        iconSize: 20,
        padding: KEdgeInsets.h4.size,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        onPressed: () => localNotifier.download(),
      );
    }

    // ── Already downloaded locally — green icon, tap to remove ───────────
    if (isDownloadedLocal) {
      return IconButton(
        tooltip: 'Remove offline download',
        icon: Icon(
          Icons.phone_android,
          color: context.theme.colorScheme.primary,
          size: 20,
        ),
        padding: KEdgeInsets.h4.size,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        onPressed: () => _confirmDelete(context, localNotifier),
      );
    }

    // ── Not downloaded — outlined icon, tap to download ──────────────────
    return IconButton(
      tooltip: 'Download offline (device)',
      icon: Icon(
        Icons.phone_android,
        color: context.theme.colorScheme.onSurfaceVariant,
        size: 20,
      ),
      padding: KEdgeInsets.h4.size,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      onPressed: () => localNotifier.download(),
    );
  }

  /// Shows a small confirmation before deleting (to avoid accidental taps).
  Future<void> _confirmDelete(
    BuildContext context,
    LocalChapterDownload notifier,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove offline download?'),
        content: const Text(
            'This chapter will be removed from your device. You can download it again anytime.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await notifier.delete();
    }
  }
}
