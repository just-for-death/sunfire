import 'dart:async';

/// Gate that makes database writes honest about the startup window (UIX-09).
///
/// * Before `initialize()` has ever been called (tests that never open the
///   database, or misuse) a write is **dropped** and reported via [onDrop];
///   it never hangs and never queues.
/// * While initialisation is in flight, writers **await** it and then run.
///   Writers waiting on the same future resume in FIFO order, and the
///   database serialises its own transactions, so call order is preserved.
/// * If initialisation fails, waiting writes are dropped (reported) and the
///   cached future is cleared so a later [initialize] call retries.
///
/// [run] therefore only completes after the body has run (committed) or after
/// a reported drop; there is no unbounded pending queue.
class WriteGate {
  WriteGate({required this.isOpen, required this.onDrop});

  final bool Function() isOpen;
  final void Function(String operation) onDrop;
  Future<void>? _initFuture;

  /// True once an initialisation is in flight or has completed successfully.
  bool get initStarted => _initFuture != null;

  /// Runs [doInit] once. Concurrent callers share the in-flight future. A
  /// failed init is not cached, so the next call retries.
  Future<void> initialize(FutureOr<void> Function() doInit) {
    final existing = _initFuture;
    if (existing != null) return existing;
    final f = Future<void>.sync(doInit);
    _initFuture = f;
    // Clear the cache on failure (callbacks run async, so `_initFuture` is
    // already assigned even if doInit threw synchronously). The error itself
    // still reaches whoever awaits `f`.
    unawaited(f.then<void>((_) {}, onError: (Object _) {
      if (identical(_initFuture, f)) _initFuture = null;
    }));
    return f;
  }

  /// Runs [body] once the database is open. Returns `true` if it ran, `false`
  /// if it was dropped (reported through `onDrop`).
  Future<bool> run(String operation, Future<void> Function() body) async {
    if (!isOpen()) {
      final pending = _initFuture;
      if (pending == null) {
        onDrop(operation);
        return false;
      }
      try {
        await pending;
      } catch (_) {
        onDrop(operation);
        return false;
      }
      if (!isOpen()) {
        onDrop(operation);
        return false;
      }
    }
    await body();
    return true;
  }
}
