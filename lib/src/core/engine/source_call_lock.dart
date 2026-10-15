import 'dart:async';

import 'package:flutter/foundation.dart';

class SourceCallLock {
  Future<void>? _last;

  /// Serializes [block] so callers of one source never overlap their native
  /// QuickJS evals (flutter_qjs `evaluateAsync` is a synchronous FFI call
  /// under the hood, so two in-flight calls on one runtime re-enter native
  /// QuickJS — undefined behavior / crash). Waits for the previously queued
  /// holder, but never longer than [maxWait]: without this cap a single hung
  /// JS call (stuck scrape, dead FlareSolverr session) blocks every later call
  /// queued behind it indefinitely — the reader's own 30s timeout only stops
  /// IT from waiting, it doesn't free the lock. When the wait overruns, the
  /// previous holder may STILL be executing on the shared runtime, so
  /// [onOverrun] lets the caller switch to a fresh runtime instead of
  /// re-entering the busy one; the overrun holder's future is re-chained so
  /// later callers keep waiting for it too.
  Future<T> synchronized<T>(
    Future<T> Function() block, {
    Duration maxWait = const Duration(seconds: 35),
    void Function()? onOverrun,
  }) async {
    final prev = _last;
    final completer = Completer<void>();
    _last = completer.future;

    var overran = false;
    if (prev != null) {
      try {
        await prev.timeout(maxWait, onTimeout: () {
          overran = true;
        });
      } catch (ignoredError) { if (kDebugMode) debugPrint('[quickjs_service] ignored error: $ignoredError'); }
    }
    if (overran) onOverrun?.call();

    try {
      return await block();
    } finally {
      // `_last` is never reassigned here: a later caller may already be
      // chained behind this completer, and rewriting the tail would let the
      // next arrival skip it and overlap on the shared runtime. When the
      // previous holder overran it may still be executing, so this caller
      // only reports done once that holder has finished too.
      if (overran && prev != null) {
        unawaited(prev.whenComplete(() {
          if (!completer.isCompleted) completer.complete();
        }));
      } else if (!completer.isCompleted) {
        completer.complete();
      }
    }
  }
}
