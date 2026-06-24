import 'package:flutter/material.dart';

/// Applies bottom safe padding when content sits above a fixed navigation bar.
class ShellBottomInset extends StatelessWidget {
  const ShellBottomInset({
    super.key,
    required this.child,
    this.extraBottom = 0,
  });

  final Widget child;
  final double extraBottom;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom + extraBottom;
    if (bottom <= 0) return child;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: child,
    );
  }
}
