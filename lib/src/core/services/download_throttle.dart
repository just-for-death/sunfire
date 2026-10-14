// IMP-037: configurable download concurrency + per-source throttle.
import 'dart:async';
import 'dart:collection';

/// Allowed range for the user-facing download concurrency setting.
const int kMinDownloadConcurrency = 1;
const int kMaxDownloadConcurrency = 8;
const int kDefaultDownloadConcurrency = 5;

/// Default simultaneous page fetches against one source (hotlink protection).
const int kDefaultPerSourceDownloadLimit = 2;

int clampDownloadConcurrency(int v) =>
    v.clamp(kMinDownloadConcurrency, kMaxDownloadConcurrency);

/// Counting semaphore per source name. Shared process-wide so parallel
/// chapter downloads from the same source also respect the limit.
class SourceThrottle {
  SourceThrottle({required int Function() limit}) : _limit = limit; // ignore: prefer_initializing_formals

  final int Function() _limit;
  final Map<String, int> _active = {};
  final Map<String, Queue<Completer<void>>> _waiters = {};

  int activeFor(String source) => _active[source] ?? 0;

  Future<T> run<T>(String source, Future<T> Function() task) async {
    await _acquire(source);
    try {
      return await task();
    } finally {
      _release(source);
    }
  }

  Future<void> _acquire(String source) {
    final limit = clampDownloadConcurrency(_limit());
    final active = _active[source] ?? 0;
    if (active < limit) {
      _active[source] = active + 1;
      return Future<void>.value();
    }
    final c = Completer<void>();
    (_waiters[source] ??= Queue<Completer<void>>()).add(c);
    return c.future;
  }

  void _release(String source) {
    final q = _waiters[source];
    if (q != null && q.isNotEmpty) {
      q.removeFirst().complete(); // hand the slot over; active count unchanged
      return;
    }
    final active = (_active[source] ?? 1) - 1;
    if (active <= 0) {
      _active.remove(source);
    } else {
      _active[source] = active;
    }
  }
}

/// Runs [count] jobs with at most [concurrency] in flight (a sliding worker
/// pool, not fixed batches: one slow page no longer stalls the whole batch).
/// [shouldStop] is checked before each job starts.
Future<void> runBoundedPool({
  required int count,
  required int concurrency,
  required Future<void> Function(int index) job,
  bool Function()? shouldStop,
}) async {
  var next = 0;
  Future<void> worker() async {
    while (true) {
      if (shouldStop?.call() == true) return;
      if (next >= count) return;
      final i = next++;
      await job(i);
    }
  }

  final n = clampDownloadConcurrency(concurrency);
  await Future.wait([for (var w = 0; w < n && w < count; w++) worker()]);
}
