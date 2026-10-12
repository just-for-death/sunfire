// lib/src/ui/widgets/sync_ui_actions.dart
//
// Shared entry points: run SyncManager sync with progress + conflict dialogs.

import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/sync/conflict_resolver.dart' show ConflictResolutionStrategy;
import '../../core/sync/sync_engine.dart' show SyncConflict, SyncResult;
import '../../core/sync/sync_manager.dart';
import 'conflict_resolution_dialog.dart';
import 'sync_progress_dialog.dart';

/// Runs [syncFn] while showing [SyncProgressDialog]; opens conflict UI if needed.
Future<SyncResult?> runSyncWithProgressDialog(
  BuildContext context, {
  required Future<SyncResult> Function() syncFn,
  String title = 'Sync Progress',
}) async {
  final manager = SyncManager.instance;
  if (manager.isSyncing) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sync already in progress')),
    );
    return null;
  }

  unawaited(
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => SyncProgressDialog(
        title: title,
        onCancel: () {
          manager.cancelAll();
          Navigator.of(ctx).pop();
        },
      ),
    ),
  );

  SyncResult result;
  try {
    result = await syncFn();
  } finally {
    if (context.mounted) {
      final nav = Navigator.of(context, rootNavigator: true);
      if (nav.canPop()) nav.pop();
    }
  }

  if (!context.mounted) return result;

  if (result.conflicts.isNotEmpty) {
    await showConflictResolutionDialog(context, result.conflicts);
  } else if (!result.success) {
    final msg = result.errors.isNotEmpty
        ? result.errors.first
        : 'Sync failed';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  } else {
    final parts = <String>[];
    if (result.mangaUpdated > 0) parts.add('${result.mangaUpdated} manga');
    if (result.chaptersUpdated > 0) {
      parts.add('${result.chaptersUpdated} chapters');
    }
    if (result.categoriesUpdated > 0) {
      parts.add('${result.categoriesUpdated} categories');
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          parts.isEmpty
              ? 'Sync complete — no changes'
              : 'Sync complete — ${parts.join(', ')}',
        ),
      ),
    );
  }

  return result;
}

/// Mount [ConflictResolutionDialog] and route picks into [SyncManager].
Future<void> showConflictResolutionDialog(
  BuildContext context,
  List<SyncConflict> conflicts,
) async {
  if (conflicts.isEmpty) return;
  final manager = SyncManager.instance;

  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => ConflictResolutionDialog(
      conflicts: conflicts,
      onResolve: (conflict, resolutions) async {
        await manager.applyUserResolutions(conflict, resolutions);
        if (ctx.mounted && manager.pendingConflicts.isEmpty) {
          Navigator.of(ctx).pop();
        }
      },
      onResolveAll: (ConflictResolutionStrategy strategy) async {
        await manager.resolveAllWithStrategy(strategy);
        if (ctx.mounted) Navigator.of(ctx).pop();
      },
    ),
  );
}
