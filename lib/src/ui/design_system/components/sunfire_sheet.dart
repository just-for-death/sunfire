// sunfire_sheet.dart
//
// C5.5: Sheets - bottom / modal / draggable helpers.

library;

import 'package:flutter/material.dart';

import '../tokens/sunfire_spacing.dart';

/// Show a Sunfire-styled modal bottom sheet.
Future<T?> showSunfireSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext context) builder,
  bool isScrollControlled = true,
  bool showDragHandle = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    showDragHandle: showDragHandle,
    shape: const RoundedRectangleBorder(
      borderRadius:
          BorderRadius.vertical(top: Radius.circular(SunfireRadius.sheet)),
    ),
    builder: builder,
  );
}

/// Sunfire bottom sheet scaffold with title + handle.
class SunfireBottomSheet extends StatelessWidget {
  const SunfireBottomSheet({
    super.key,
    required this.title,
    this.subtitle,
    required this.body,
    this.actions,
  });

  final String title;
  final String? subtitle;
  final Widget body;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(SunfireSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700)),
            if (subtitle != null) ...[
              const SizedBox(height: SunfireSpacing.xs),
              Text(subtitle!,
                  style: TextStyle(
                      fontSize: 13,
                      color:
                          Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
            const SizedBox(height: SunfireSpacing.md),
            Flexible(child: body),
            if (actions != null) ...[
              const SizedBox(height: SunfireSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Sunfire draggable sheet scaffold.
class SunfireDraggableSheet extends StatelessWidget {
  const SunfireDraggableSheet({
    super.key,
    required this.title,
    required this.body,
    this.initialChildSize = 0.5,
    this.minChildSize = 0.25,
    this.maxChildSize = 0.9,
  });

  final String title;
  final Widget body;
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: initialChildSize,
      minChildSize: minChildSize,
      maxChildSize: maxChildSize,
      builder: (context, scrollController) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(SunfireSpacing.lg),
            child: Text(title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700)),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              child: body,
            ),
          ),
        ],
      ),
    );
  }
}
