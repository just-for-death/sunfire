import 'package:flutter/widgets.dart';

/// IMP-014: how paged readers move between pages.
enum PageTransitionMode { slide, fade, none }

/// Settings value -> mode (unknown values fall back to [PageTransitionMode.slide],
/// the previous behaviour).
PageTransitionMode parsePageTransition(String? value) => PageTransitionMode.values.firstWhere(
      (m) => m.name == value,
      orElse: () => PageTransitionMode.slide,
    );

/// Slide duration (unchanged from the pre-IMP-014 220 ms).
const Duration kPageSlideDuration = Duration(milliseconds: 220);

/// Turns one page. Slide animates as before; none and fade jump instantly
/// (fade's cross-fade is drawn by the view around the page, keyed on the page).
void turnPage(PageController controller, {required bool forward, required PageTransitionMode mode}) {
  if (!controller.hasClients) return;
  if (mode == PageTransitionMode.slide) {
    if (forward) {
      controller.nextPage(duration: kPageSlideDuration, curve: Curves.easeOutCubic);
    } else {
      controller.previousPage(duration: kPageSlideDuration, curve: Curves.easeOutCubic);
    }
    return;
  }
  final target = (controller.page ?? controller.initialPage.toDouble()).round() + (forward ? 1 : -1);
  if (target < 0) return;
  controller.jumpToPage(target);
}
