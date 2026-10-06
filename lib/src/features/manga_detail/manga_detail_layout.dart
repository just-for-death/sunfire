import 'package:flutter/widgets.dart';

import '../../ui/shell/sunfire_breakpoints.dart';

/// Chooses between the two-pane (landscape tablet) and single-pane manga
/// details layouts (UIS-P2-D). Gate: [SunfireBreakpoints.usesTwoPaneDetails].
class MangaDetailAdaptiveLayout extends StatelessWidget {
  const MangaDetailAdaptiveLayout({
    super.key,
    required this.twoPaneBuilder,
    required this.singlePaneBuilder,
  });

  final WidgetBuilder twoPaneBuilder;
  final WidgetBuilder singlePaneBuilder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) =>
          SunfireBreakpoints.usesTwoPaneDetails(context, constraints.maxWidth)
              ? KeyedSubtree(
                  key: const ValueKey('mangaDetailTwoPane'),
                  child: twoPaneBuilder(context),
                )
              : KeyedSubtree(
                  key: const ValueKey('mangaDetailSinglePane'),
                  child: singlePaneBuilder(context),
                ),
    );
  }
}
