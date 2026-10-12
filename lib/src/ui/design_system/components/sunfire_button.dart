// sunfire_button.dart
//
// C5.1: Buttons - primary / secondary / tertiary / ghost.
// Thin wrappers over Material 3 buttons enforcing Sunfire tokens.

library;

import 'package:flutter/material.dart';

import '../tokens/sunfire_motion.dart';

/// Button variants.
enum SunfireButtonVariant { primary, secondary, tertiary, ghost }

/// Sunfire button: variant-driven wrapper over Material 3 buttons.
class SunfireButton extends StatelessWidget {
  const SunfireButton({
    super.key,
    required this.label,
    this.icon,
    this.variant = SunfireButtonVariant.primary,
    this.onPressed,
    this.expanded = false,
  });

  /// Primary action constructor.
  const SunfireButton.primary({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.expanded = false,
  }) : variant = SunfireButtonVariant.primary;

  /// Secondary action constructor.
  const SunfireButton.secondary({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.expanded = false,
  }) : variant = SunfireButtonVariant.secondary;

  /// Tertiary (text) action constructor.
  const SunfireButton.tertiary({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.expanded = false,
  }) : variant = SunfireButtonVariant.tertiary;

  /// Ghost (borderless, low-emphasis) constructor.
  const SunfireButton.ghost({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.expanded = false,
  }) : variant = SunfireButtonVariant.ghost;

  final String label;
  final IconData? icon;
  final SunfireButtonVariant variant;
  final VoidCallback? onPressed;
  final bool expanded;

  static ButtonStyle _style(BuildContext context) {
    return FilledButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      animationDuration: SunfireDuration.fast,
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = _style(context);
    Widget button;
    switch (variant) {
      case SunfireButtonVariant.primary:
        button = icon == null
            ? FilledButton(
                onPressed: onPressed, style: style, child: Text(label))
            : FilledButton.icon(
                onPressed: onPressed,
                style: style,
                icon: Icon(icon, size: 18),
                label: Text(label));
        break;
      case SunfireButtonVariant.secondary:
        button = icon == null
            ? OutlinedButton(
                onPressed: onPressed, style: style, child: Text(label))
            : OutlinedButton.icon(
                onPressed: onPressed,
                style: style,
                icon: Icon(icon, size: 18),
                label: Text(label));
        break;
      case SunfireButtonVariant.tertiary:
        button = icon == null
            ? TextButton(
                onPressed: onPressed, style: style, child: Text(label))
            : TextButton.icon(
                onPressed: onPressed,
                style: style,
                icon: Icon(icon, size: 18),
                label: Text(label));
        break;
      case SunfireButtonVariant.ghost:
        button = icon == null
            ? TextButton(
                onPressed: onPressed,
                style: style.copyWith(
                  foregroundColor: WidgetStatePropertyAll(
                      Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                child: Text(label))
            : TextButton.icon(
                onPressed: onPressed,
                style: style.copyWith(
                  foregroundColor: WidgetStatePropertyAll(
                      Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                icon: Icon(icon, size: 18),
                label: Text(label));
        break;
    }
    if (expanded) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}
