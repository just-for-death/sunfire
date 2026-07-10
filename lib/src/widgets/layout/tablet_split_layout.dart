import 'package:flutter/material.dart';

import '../../constants/app_breakpoints.dart';

/// Master–detail split for tablet-width layouts.
class TabletSplitLayout extends StatelessWidget {
  const TabletSplitLayout({
    super.key,
    required this.master,
    required this.detail,
    this.masterWidth = 300,
    this.showDetail = true,
  });

  final Widget master;
  final Widget detail;
  final double masterWidth;
  final bool showDetail;

  static bool shouldUse(BuildContext context) =>
      AppBreakpoints.isTabletLayout(context);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        SizedBox(
          width: masterWidth,
          child: Material(
            color: cs.surfaceContainerLow,
            child: master,
          ),
        ),
        VerticalDivider(
          width: 1,
          thickness: 1,
          color: cs.outlineVariant.withValues(alpha: 0.5),
        ),
        Expanded(
          child: showDetail
              ? detail
              : ColoredBox(
                  color: cs.surface,
                  child: Center(
                    child: Icon(
                      Icons.touch_app_outlined,
                      size: 48,
                      color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
