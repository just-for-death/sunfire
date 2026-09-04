import 'package:flutter/material.dart';

enum SunfireBadgeVariant {
  /// Compact tag/counter/status badge (e.g. "ONGOING", "SERVER", "EN", "12 CH")
  compact,

  /// Interactive chip (e.g. genre tags, filter chips)
  chip,
}

class SunfireBadge extends StatelessWidget {
  const SunfireBadge({
    super.key,
    required this.label,
    this.variant = SunfireBadgeVariant.compact,
    this.color,
    this.textColor,
    this.icon,
    this.onTap,
    this.padding,
    this.fontSize,
    this.fontWeight,
    this.borderRadius,
  });

  factory SunfireBadge.server({Key? key}) => SunfireBadge(
        key: key,
        label: 'SERVER',
        color: Colors.tealAccent,
        fontSize: 9.0,
        fontWeight: FontWeight.bold,
      );

  factory SunfireBadge.local({Key? key}) => SunfireBadge(
        key: key,
        label: 'LOCAL',
        color: Colors.purpleAccent,
        fontSize: 9.0,
        fontWeight: FontWeight.bold,
      );

  factory SunfireBadge.proxy({Key? key}) => SunfireBadge(
        key: key,
        label: 'PROXY',
        color: Colors.amberAccent,
        fontSize: 9.0,
        fontWeight: FontWeight.bold,
      );

  final String label;
  final SunfireBadgeVariant variant;
  final Color? color;
  final Color? textColor;
  final Widget? icon;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final double? fontSize;
  final FontWeight? fontWeight;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final effectiveColor = color ?? primary;

    final isCompact = variant == SunfireBadgeVariant.compact;

    final effectivePadding = padding ??
        (isCompact
            ? const EdgeInsets.symmetric(horizontal: 7.0, vertical: 2.5)
            : const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.5));

    final effectiveBorderRadius = borderRadius ??
        (isCompact ? BorderRadius.circular(8) : BorderRadius.circular(12));

    final effectiveFontSize = fontSize ?? (isCompact ? 10.5 : 12.0);
    final effectiveFontWeight = fontWeight ?? (isCompact ? FontWeight.bold : FontWeight.w500);

    final effectiveTextColor = textColor ??
        (isCompact
            ? (color ?? primary)
            : (color ?? Colors.white70));

    Widget badgeContent = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (icon != null) ...[
          icon!,
          const SizedBox(width: 4),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: effectiveTextColor,
              fontSize: effectiveFontSize,
              fontWeight: effectiveFontWeight,
              height: 1.15,
            ),
          ),
        ),
      ],
    );

    final container = Container(
      padding: effectivePadding,
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: isCompact ? 0.15 : 0.12),
        borderRadius: effectiveBorderRadius,
        border: Border.all(
          color: effectiveColor.withValues(alpha: isCompact ? 0.35 : 0.30),
          width: 0.8,
        ),
      ),
      child: badgeContent,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: effectiveBorderRadius,
          onTap: onTap,
          child: container,
        ),
      );
    }

    return container;
  }
}
