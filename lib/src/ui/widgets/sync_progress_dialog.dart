// lib/src/ui/widgets/sync_progress_dialog.dart
//
// SyncProgressDialog — SyncManager progress with cancellation support.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/sync/sync_conflict_helpers.dart';
import '../../core/sync/sync_engine.dart' show SyncPhase, SyncProgress;
import '../../core/sync/sync_manager.dart';
import '../design_system/tokens/sunfire_spacing.dart';

/// Shows live [SyncManager] progress; cancel is best-effort between stages.
class SyncProgressDialog extends StatefulWidget {
  const SyncProgressDialog({
    super.key,
    required this.onCancel,
    this.title = 'Sync Progress',
    this.initialCategories = const [],
    this.showCategories = true,
  });

  final VoidCallback onCancel;
  final String title;
  final List<String> initialCategories;
  final bool showCategories;

  @override
  State<SyncProgressDialog> createState() => _SyncProgressDialogState();
}

class _SyncProgressDialogState extends State<SyncProgressDialog> {
  StreamSubscription<SyncProgress>? _sub;
  SyncProgress _progress = const SyncProgress(
    phase: SyncPhase.initializing,
    current: 0,
    total: 100,
  );

  @override
  void initState() {
    super.initState();
    _sub = SyncManager.instance.progressStream.listen((p) {
      if (mounted) setState(() => _progress = p);
    });
  }

  @override
  void dispose() {
    unawaited(_sub?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final busy = SyncManager.instance.isSyncing &&
        _progress.phase != SyncPhase.completed &&
        _progress.phase != SyncPhase.failed;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): widget.onCancel,
      },
      child: Focus(
        autofocus: true,
        child: Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420, maxHeight: 360),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        tooltip: 'Cancel (Esc)',
                        onPressed: widget.onCancel,
                      ),
                    ],
                  ),
                  const SizedBox(height: SunfireSpacing.sm),
                  Text(
                    syncPhaseLabel(_progress.phase.name),
                    style: TextStyle(
                      fontSize: 14,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  if (_progress.currentManga != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      _progress.currentManga!,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: scheme.primary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: SunfireSpacing.lg),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: _progress.total > 0 ? _progress.progress : null,
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: SunfireSpacing.sm),
                  Text(
                    _progress.total > 0
                        ? '${_progress.current} / ${_progress.total}'
                            '  ·  ${(_progress.progress * 100).clamp(0, 100).toStringAsFixed(0)}%'
                        : '${(_progress.progress * 100).clamp(0, 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: busy ? widget.onCancel : () => Navigator.pop(context),
                      icon: Icon(
                        busy ? Icons.cancel_rounded : Icons.check_rounded,
                        size: 18,
                      ),
                      label: Text(busy ? 'Cancel' : 'Close'),
                      style: busy
                          ? FilledButton.styleFrom(
                              backgroundColor: scheme.errorContainer,
                              foregroundColor: scheme.onErrorContainer,
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
