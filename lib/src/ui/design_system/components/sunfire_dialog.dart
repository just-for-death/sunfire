// sunfire_dialog.dart
//
// C5.4: Dialogs - alert / bottom-sheet / fullscreen helpers.

library;

import 'package:flutter/material.dart';

import '../tokens/sunfire_motion.dart';
import '../tokens/sunfire_spacing.dart';

/// Show a Sunfire-styled alert dialog.
Future<bool?> showSunfireConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool destructive = false,
}) {
  final cs = Theme.of(context).colorScheme;
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: destructive
              ? FilledButton.styleFrom(backgroundColor: cs.error)
              : null,
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
}

/// Sunfire alert dialog widget (inline alternative to the helper).
class SunfireAlertDialog extends StatelessWidget {
  const SunfireAlertDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.destructive = false,
    this.onConfirm,
    this.onCancel,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool destructive;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: onCancel ?? () => Navigator.pop(context, false),
          child: Text(cancelLabel),
        ),
        FilledButton(
          onPressed: onConfirm ?? () => Navigator.pop(context, true),
          style: destructive
              ? FilledButton.styleFrom(backgroundColor: cs.error)
              : null,
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}

/// Sunfire fullscreen dialog scaffold with standard header + animation.
class SunfireFullscreenDialog extends StatelessWidget {
  const SunfireFullscreenDialog({
    super.key,
    required this.title,
    this.subtitle,
    required this.body,
    this.actions,
    this.onClose,
  });

  final String title;
  final String? subtitle;
  final Widget body;
  final List<Widget>? actions;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: AnimatedContainer(
        duration: SunfireDuration.medium,
        curve: Curves.easeOutCubic,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(SunfireSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700)),
                        if (subtitle != null) ...[
                          const SizedBox(height: SunfireSpacing.xs),
                          Text(subtitle!,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant)),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed:
                        onClose ?? () => Navigator.of(context).pop(),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),
            Expanded(child: body),
            if (actions != null)
              Padding(
                padding: const EdgeInsets.all(SunfireSpacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions!,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
