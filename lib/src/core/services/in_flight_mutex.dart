import 'package:flutter/foundation.dart' show visibleForTesting;

/// De-duplicates concurrent computations of the same key.
///
/// A pure in-flight mutex: one computation per key at a time, and the entry is
/// dropped the moment it settles. It is deliberately NOT a memo table — the
/// caller owns caching, with its own eviction policy.
///
/// It used to be a memo table as well, and it was broken in three ways at once:
///
///  * It invoked the computation closure TWICE per miss — once to start the
///    tracked future and again to await it. The cover helper therefore ran the
///    full 7-pass HTTP cascade, the desktop curl fallback and both Isar writes
///    twice per cache miss, concurrently and uncoordinated. Double bandwidth,
///    double CDN requests — which is exactly the anti-hotlink heuristic the later
///    passes exist to work around — plus two concurrent `writeTxn` calls on the
///    same row.
///  * It completed the same `Completer` from two paths, so whichever finished
///    second threw `StateError: Future already completed`; the catch then called
///    `completeError` on the already-completed completer, throwing a second
///    `StateError` that escaped. The entry's error was poisoned with it, so one
///    hit permanently broke that key for the life of the process.
///  * It notified waiters only on success, so a concurrent caller that lost the
///    race waited on a future that could never complete. Both production call
///    sites are fire-and-forget, so the tile just sat on its fallback forever.
///
/// The memoisation it was reaching for is not needed and was actively harmful:
/// holding a second, uncapped reference to every result for the life of the
/// process pinned ~80 MB of cover bytes on a 1000-title library, entirely
/// outside the caller's cache accounting. The `release()` that would have cleared
/// it existed and was never called from anywhere.
///
/// Dropping the entry on settle also keeps the map from growing once per distinct
/// key ever computed.
class InFlightMutex<T> {
  final Map<String, Future<T>> _inFlight = {};

  /// Number of keys with a computation in flight. Exposed so a leak is
  /// observable in a test rather than inferred.
  @visibleForTesting
  int get inFlightCount => _inFlight.length;

  /// Runs [computation] for [key], or joins the run already in progress.
  ///
  /// The value is shared with the joiners but not retained: once the future
  /// settles the entry is dropped, so a later call re-runs the computation and
  /// the caller's own cache decides whether that reaches the network.
  Future<T> run(String key, Future<T> Function() computation) {
    final existing = _inFlight[key];
    if (existing != null) return existing;

    // The entry is recorded only after `computation()` has returned its future.
    // A synchronous throw inside the closure must not leave a future nobody is
    // awaiting while every later caller joins it forever — which is exactly what
    // recording it first would do.
    final Future<T> tracked;
    try {
      tracked = computation();
    } catch (e, st) {
      return Future<T>.error(e, st);
    }
    _inFlight[key] = tracked;

    // `then(..., onError:)` rather than `whenComplete`: `whenComplete` returns a
    // NEW future carrying the same error, and nobody awaits that one, so a single
    // failed fetch would surface as an unhandled async error in the zone. Here
    // the handler returns normally, so the derived future completes successfully
    // and the error reaches only the callers that actually await `tracked`.
    void drop() {
      // Guard against a later run having replaced the entry, so a fast second
      // request is not evicted by the first one's cleanup.
      if (identical(_inFlight[key], tracked)) _inFlight.remove(key);
    }

    tracked.then<void>((_) => drop(), onError: (Object _, StackTrace __) => drop());
    return tracked;
  }
}
