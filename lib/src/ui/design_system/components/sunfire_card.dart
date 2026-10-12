// sunfire_card.dart
//
// C5.2: Cards - elevated / outlined / filled.

library;

import 'package:flutter/material.dart';

import '../tokens/sunfire_elevation.dart';
import '../tokens/sunfire_spacing.dart';

/// Card variants.
enum SunfireCardVariant { elevated, outlined, filled }

/// Sunfire card: variant-driven wrapper enforcing radius + elevation tokens.
class SunfireCard extends StatelessWidget {
  const SunfireCard({
    super.key,
    required this.child,
    this.variant = SunfireCardVariant.filled,
    this.onTap,
    this.padding,
  });

  final Widget child;
  final SunfireCardVariant variant;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(SunfireRadius.card),
    );
    final content = Padding(
      padding: padding ?? const EdgeInsets.all(SunfireSpacing.lg),
      child: child,
    );

    Widget card;
    switch (variant) {
      case SunfireCardVariant.elevated:
        card = Card(
          elevation: SunfireElevation.level1,
          shape: shape,
          child: content,
        );
        break;
      case SunfireCardVariant.outlined:
        card = Card.outlined(
          shape: shape,
          child: content,
        );
        break;
      case SunfireCardVariant.filled:
        card = Card.filled(
          shape: shape,
          child: content,
        );
        break;
    }

    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SunfireRadius.card),
      child: card,
    );
  }
}
