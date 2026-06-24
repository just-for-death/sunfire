import 'package:flutter/services.dart';

abstract final class ReaderHaptics {
  static void pageTurn({bool enabled = true}) {
    if (!enabled) return;
    HapticFeedback.selectionClick();
  }

  static void chapterChange({bool enabled = true}) {
    if (!enabled) return;
    HapticFeedback.lightImpact();
  }
}
