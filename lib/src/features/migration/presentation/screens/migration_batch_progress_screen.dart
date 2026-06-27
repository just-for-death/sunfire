import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../utils/extensions/custom_extensions.dart';
import '../../controller/migration_controller.dart';
import '../../domain/migration_models.dart';

class MigrationBatchProgressScreen extends ConsumerWidget {
  const MigrationBatchProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final progress = ref.watch(migrationExecutionProvider);

    return PopScope(
      canPop: progress?.status == MigrationStatus.completed ||
          progress?.status == MigrationStatus.error ||
          progress?.status == MigrationStatus.cancelled,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && progress != null) {
          if (progress.status == MigrationStatus.migrating ||
              progress.status == MigrationStatus.preparing) {
            await _showCancelConfirmation(context, ref);
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.migrationBatchTitle),
          automaticallyImplyLeading:
              progress?.status == MigrationStatus.completed ||
                  progress?.status == MigrationStatus.error ||
                  progress?.status == MigrationStatus.cancelled,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (progress?.status == MigrationStatus.completed) ...[
                  Icon(Icons.check_circle,
                      size: 80, color: context.theme.colorScheme.primary),
                  const SizedBox(height: 24),
                  Text(
                    l10n.migrationComplete,
                    style: context.theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.migrationSuccessMangaCount(progress!.totalItems),
                    style: context.theme.textTheme.bodyLarge?.copyWith(
                      color: context.theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ] else if (progress?.status == MigrationStatus.error) ...[
                  Icon(Icons.error,
                      size: 80, color: context.theme.colorScheme.error),
                  const SizedBox(height: 24),
                  Text(
                    l10n.migrationFailed,
                    style: context.theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.migrationPartialFailure(
                      progress!.processedItems,
                      progress.totalItems,
                      progress.totalItems - progress.processedItems,
                    ),
                    textAlign: TextAlign.center,
                    style: context.theme.textTheme.bodyLarge?.copyWith(
                      color: context.theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ] else ...[
                  CircularProgressIndicator(
                    value: progress != null && progress.totalItems > 0
                        ? (progress.processedItems / progress.totalItems)
                        : null,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    l10n.migrationInProgress,
                    style: context.theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  if (progress != null && progress.totalItems > 0)
                    Text(
                      l10n.migrationProgressCount(
                        progress.processedItems,
                        progress.totalItems,
                      ),
                      style: context.theme.textTheme.titleMedium?.copyWith(
                        color: context.theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: progress != null && progress.totalItems > 0
                        ? (progress.processedItems / progress.totalItems)
                        : null,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
                const SizedBox(height: 48),
                if (progress?.status == MigrationStatus.migrating ||
                    progress?.status == MigrationStatus.preparing)
                  OutlinedButton.icon(
                    onPressed: () => _showCancelConfirmation(context, ref),
                    icon: const Icon(Icons.cancel),
                    label: Text(l10n.cancel),
                  )
                else if (progress?.status == MigrationStatus.completed ||
                    progress?.status == MigrationStatus.error ||
                    progress?.status == MigrationStatus.cancelled)
                  FilledButton(
                    onPressed: () {
                      ref.read(migrationExecutionProvider.notifier).reset();
                      context.go('/library/0');
                    },
                    child: Text(l10n.done),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showCancelConfirmation(
      BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.cancelMigration),
        content: Text(l10n.cancelMigrationConfirmationInProgress),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.no),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.yes),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(migrationExecutionProvider.notifier).cancelMigration();
    }
  }
}
