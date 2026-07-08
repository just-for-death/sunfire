import 'package:flutter/material.dart';

import '../../utils/platform/platform_ui.dart';

/// Applies bottom padding so scroll content clears the tab bar / FAB.
class ShellBottomInset extends StatelessWidget {
  const ShellBottomInset({
    super.key,
    required this.child,
    this.hasFab = false,
    this.extraBottom = 0,
  });

  final Widget child;
  final bool hasFab;
  final double extraBottom;

  @override
  Widget build(BuildContext context) {
    final bottom = scrollBottomInset(hasFab: hasFab) + extraBottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: child,
    );
  }
}
