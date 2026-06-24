import 'package:flutter/scheduler.dart';

import 'reader_system_ui.dart';

/// Tracks nested reader screens so system UI is only restored when the last
/// reader route is removed (e.g. chapter pushReplacement keeps depth > 0).
abstract final class ReaderSession {
  static int _depth = 0;

  static void enter() => _depth++;

  static void leave() {
    if (_depth <= 0) return;
    _depth--;
    if (_depth == 0) {
      // Defer so a pushReplacement chapter transition can call enter() first.
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (_depth == 0) {
          ReaderSystemUi.exitReader();
        }
      });
    }
  }
}
