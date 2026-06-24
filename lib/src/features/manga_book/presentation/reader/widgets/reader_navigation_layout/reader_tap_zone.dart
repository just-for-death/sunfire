import 'package:flutter/material.dart';

/// Tap target that meets minimum touch size guidelines (44×44 logical pixels).
class ReaderTapZone extends StatelessWidget {
  const ReaderTapZone({
    super.key,
    required this.onTap,
    this.color,
    this.semanticsLabel,
    this.child = const SizedBox.expand(),
  });

  final VoidCallback? onTap;
  final Color? color;
  final String? semanticsLabel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: semanticsLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          child: ColoredBox(
            color: color ?? Colors.transparent,
            child: child,
          ),
        ),
      ),
    );
  }
}
