// lib/src/ui/widgets/conflict_resolution_dialog.dart
//
// ConflictResolutionDialog — UI for resolving sync conflicts with visual diffs.
// Allows users to pick winners per field for Manga, Chapter, and Category entities.
//
// Features:
// - List of pending conflicts
// - Side-by-side visual diff for each field
// - Per-field winner selection (Local / Remote / Merge)
// - Support for Manga, Chapter, Category entities
// - Batch resolution (resolve all with same strategy)
// - Real-time updates as conflicts are resolved

import 'package:flutter/material.dart';

import '../../core/sync/conflict_resolver.dart' show ConflictResolutionStrategy;
import '../../core/sync/sync_engine.dart' show SyncConflict, ConflictResolution;
import '../design_system/tokens/sunfire_colors.dart';
import '../design_system/tokens/sunfire_spacing.dart';

/// ConflictResolutionDialog — UI for resolving sync conflicts with visual diffs.
///
/// Features:
/// - List of pending conflicts
/// - Side-by-side visual diff for each field
/// - Per-field winner selection (Local / Remote / Merge)
/// - Support for Manga, Chapter, Category entities
/// - Batch resolution (resolve all with same strategy)
/// - Real-time updates as conflicts are resolved
class ConflictResolutionDialog extends StatefulWidget {
  const ConflictResolutionDialog({
    super.key,
    required this.conflicts,
    required this.onResolve,
    required this.onResolveAll,
  });

  final List<SyncConflict> conflicts;
  final void Function(SyncConflict conflict, Map<String, ConflictResolution> resolutions) onResolve;
  final void Function(ConflictResolutionStrategy strategy) onResolveAll;

  @override
  State<ConflictResolutionDialog> createState() => _ConflictResolutionDialogState();
}

class _ConflictResolutionDialogState extends State<ConflictResolutionDialog> {
  int _currentIndex = 0;
  final Map<String, ConflictResolution> _fieldResolutions = {};
  ConflictResolutionStrategy _batchStrategy = ConflictResolutionStrategy.lastWriteWins;

  @override
  Widget build(BuildContext context) {
    if (widget.conflicts.isEmpty) {
      return _buildEmptyState();
    }

    final conflict = widget.conflicts[_currentIndex];
    final entityType = conflict.entityType;
    final entityId = conflict.entityId;

    return Dialog.fullscreen(
      backgroundColor: SunfireColors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(SunfireRadius.dialog),
        ),
        child: Column(
          children: [
            _buildHeader(entityType, entityId),
            Flexible(child: _buildConflictDetail(conflict)),
            _buildActions(conflict),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Dialog.fullscreen(
      backgroundColor: SunfireColors.transparent,
      child: Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(SunfireRadius.dialog),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_rounded,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: SunfireSpacing.xl),
              Text(
                'All Conflicts Resolved',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: SunfireSpacing.sm),
              Text(
                'No pending conflicts to resolve.',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String entityType, int entityId) {
    final total = widget.conflicts.length;
    final current = _currentIndex + 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(SunfireRadius.sheet)),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resolve Conflicts',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: SunfireSpacing.xs),
                Text(
                  '$entityType #$entityId  •  Conflict $current of $total',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (total > 1) ...[
            IconButton(
              icon: const Icon(Icons.navigate_before_rounded),
              onPressed: _currentIndex > 0 ? () => setState(() => _currentIndex--) : null,
              tooltip: 'Previous Conflict',
            ),
            IconButton(
              icon: const Icon(Icons.navigate_next_rounded),
              onPressed: _currentIndex < total - 1 ? () => setState(() => _currentIndex++) : null,
              tooltip: 'Next Conflict',
            ),
          ],
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Close',
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConflictDetail(SyncConflict conflict) {
    final fields = _extractFields(conflict);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEntityTypeBadge(conflict.entityType),
          const SizedBox(height: SunfireSpacing.lg),
          if (fields.isEmpty) ...[
            _buildSingleFieldConflict(conflict),
          ] else ...[
            ...fields.map((field) => _buildFieldDiff(conflict, field)),
          ],
          const SizedBox(height: SunfireSpacing.lg),
          _buildBatchActions(),
        ],
      ),
    );
  }

  Widget _buildEntityTypeBadge(String entityType) {
    Color color;
    IconData icon;
    switch (entityType) {
      case 'manga':
        color = SunfireColors.info;
        icon = Icons.menu_book_rounded;
        break;
      case 'chapter':
        color = SunfireColors.trackerBlue;
        icon = Icons.article_rounded;
        break;
      case 'category':
        color = SunfireColors.success;
        icon = Icons.category_rounded;
        break;
      default:
        color = SunfireColors.contentTertiary;
        icon = Icons.help_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(SunfireRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: SunfireIconSize.sm, color: color),
          const SizedBox(width: 6),
          Text(
            entityType.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  List<String> _extractFields(SyncConflict conflict) {
    // For single-field conflicts, return empty to use _buildSingleFieldConflict
    if (conflict.field.isNotEmpty) return [];
    
    // For multi-field conflicts, extract all field names from localData/remoteData
    if (conflict.localData is Map && conflict.remoteData is Map) {
      final localMap = conflict.localData as Map;
      final remoteMap = conflict.remoteData as Map;
      final allKeys = <String>{...localMap.keys.cast<String>(), ...remoteMap.keys.cast<String>()};
      return allKeys.toList()..sort();
    }
    return [];
  }

  Widget _buildSingleFieldConflict(SyncConflict conflict) {
    return _buildFieldRow(
      field: conflict.field,
      localValue: _formatValue(conflict.localData),
      remoteValue: _formatValue(conflict.remoteData),
      localTimestamp: conflict.localTimestamp,
      remoteTimestamp: conflict.remoteTimestamp,
      resolution: _fieldResolutions[conflict.field] ?? ConflictResolution.userChoice,
      onChanged: (resolution) {
        setState(() => _fieldResolutions[conflict.field] = resolution);
      },
    );
  }

  Widget _buildFieldDiff(SyncConflict conflict, String field) {
    final localMap = conflict.localData as Map?;
    final remoteMap = conflict.remoteData as Map?;
    
    final localValue = localMap?[field];
    final remoteValue = remoteMap?[field];
    
    // Skip if both are null/empty
    if ((localValue == null || localValue.toString().isEmpty) &&
        (remoteValue == null || remoteValue.toString().isEmpty)) {
      return const SizedBox.shrink();
    }

    return _buildFieldRow(
      field: field,
      localValue: _formatValue(localValue),
      remoteValue: _formatValue(remoteValue),
      localTimestamp: conflict.localTimestamp,
      remoteTimestamp: conflict.remoteTimestamp,
      resolution: _fieldResolutions[field] ?? ConflictResolution.userChoice,
      onChanged: (resolution) {
        setState(() => _fieldResolutions[field] = resolution);
      },
    );
  }

  Widget _buildFieldRow({
    required String field,
    required String localValue,
    required String remoteValue,
    required DateTime? localTimestamp,
    required DateTime? remoteTimestamp,
    required ConflictResolution resolution,
    required ValueChanged<ConflictResolution> onChanged,
  }) {
    final isDifferent = localValue != remoteValue;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDifferent
              ? Theme.of(context).colorScheme.outlineVariant
              : SunfireColors.transparent,
          width: isDifferent ? 1 : 0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _formatFieldName(field),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              if (isDifferent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'CONFLICT',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: SunfireSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Local column
              Expanded(
                child: _buildValueColumn(
                  label: 'Local',
                  value: localValue,
                  timestamp: localTimestamp,
                  isSelected: resolution == ConflictResolution.localWins,
                  color: Theme.of(context).colorScheme.primary,
                  onTap: () => onChanged(ConflictResolution.localWins),
                ),
              ),
              const SizedBox(width: SunfireSpacing.md),
              // Arrow indicator
              if (isDifferent) ...[
                Icon(
                  Icons.swap_horiz_rounded,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 24,
                ),
                const SizedBox(width: SunfireSpacing.md),
              ],
              // Remote column
              Expanded(
                child: _buildValueColumn(
                  label: 'Remote',
                  value: remoteValue,
                  timestamp: remoteTimestamp,
                  isSelected: resolution == ConflictResolution.remoteWins,
                  color: Theme.of(context).colorScheme.secondary,
                  onTap: () => onChanged(ConflictResolution.remoteWins),
                ),
              ),
            ],
          ),
          if (isDifferent) ...[
            const SizedBox(height: SunfireSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.merge_type_rounded, size: SunfireIconSize.sm),
                    label: const Text('Merge'),
                    onPressed: () => onChanged(ConflictResolution.merge),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.tertiary,
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildValueColumn({
    required String label,
    required String value,
    required DateTime? timestamp,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Theme.of(context).colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
                  size: 18,
                  color: isSelected ? color : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? color : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: SunfireSpacing.sm),
            Text(
              value.isEmpty ? '(empty)' : value,
              style: TextStyle(
                fontSize: 13,
                color: value.isEmpty
                    ? Theme.of(context).colorScheme.onSurfaceVariant
                    : Theme.of(context).colorScheme.onSurface,
                fontStyle: value.isEmpty ? FontStyle.italic : FontStyle.normal,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (timestamp != null) ...[
              const SizedBox(height: SunfireSpacing.xs),
              Text(
                'Updated ${_formatTimestamp(timestamp)}',
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBatchActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Batch Resolve Remaining',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: SunfireSpacing.md),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildStrategyChip(
                label: 'Last Write Wins',
                strategy: ConflictResolutionStrategy.lastWriteWins,
                icon: Icons.access_time_rounded,
              ),
              _buildStrategyChip(
                label: 'Local Wins',
                strategy: ConflictResolutionStrategy.localWins,
                icon: Icons.phone_android_rounded,
              ),
              _buildStrategyChip(
                label: 'Remote Wins',
                strategy: ConflictResolutionStrategy.serverWins,
                icon: Icons.cloud_rounded,
              ),
              _buildStrategyChip(
                label: 'CRDT Merge',
                strategy: ConflictResolutionStrategy.crdt,
                icon: Icons.merge_type_rounded,
              ),
            ],
          ),
          const SizedBox(height: SunfireSpacing.md),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.tonalIcon(
              icon: const Icon(Icons.done_all_rounded, size: SunfireIconSize.std),
              label: const Text('Apply strategy to all'),
              onPressed: () => widget.onResolveAll(_batchStrategy),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrategyChip({
    required String label,
    required ConflictResolutionStrategy strategy,
    required IconData icon,
  }) {
    final isSelected = _batchStrategy == strategy;
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: SunfireIconSize.sm),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _batchStrategy = strategy);
        }
      },
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: isSelected
            ? Theme.of(context).colorScheme.onPrimaryContainer
            : Theme.of(context).colorScheme.onSurface,
      ),
      avatar: isSelected
          ? Icon(Icons.check_rounded, size: SunfireIconSize.sm, color: Theme.of(context).colorScheme.onPrimaryContainer)
          : null,
    );
  }

  Widget _buildActions(SyncConflict conflict) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Skip'),
          ),
          const SizedBox(width: SunfireSpacing.md),
          FilledButton.icon(
            icon: const Icon(Icons.check_rounded, size: SunfireIconSize.std),
            label: const Text('Apply Resolutions'),
            onPressed: () {
              widget.onResolve(conflict, Map.from(_fieldResolutions));
              _fieldResolutions.clear();
            },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatFieldName(String field) {
    // Convert camelCase/snake_case to Title Case
    return field
        .replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m.group(1)!}')
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }

  String _formatValue(dynamic value) {
    if (value == null) return '';
    if (value is bool) return value ? 'Yes' : 'No';
    if (value is List) return value.join(', ');
    if (value is Set) return value.join(', ');
    if (value is Map) return '{...}';
    if (value is num) return value.toString();
    return value.toString();
  }

  String _formatTimestamp(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}