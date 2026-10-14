// IMP-029: bounded LRU pool of per-source QuickJS runtimes.
//
// Fixes over the old inline map in QuickJsService:
// * LRU eviction never disposes a runtime that is still executing (it is
//   retired and disposed on its last release), so a busy scrape on source A
//   can't be killed by a burst on sources B-F.
// * Each entry remembers a fingerprint of the JS it was built from; updated
//   extension code gets a fresh runtime instead of the stale one.
// * Invalidation of a busy runtime is deferred the same way.
// Generic over the runtime type so the policy is unit-testable without FFI.

class _PoolEntry<R> {
  _PoolEntry(this.runtime, this.fingerprint);
  final R runtime;
  final int fingerprint;
  int inUse = 0;
  bool retired = false;
}

class RuntimePool<R> {
  RuntimePool({required this.maxSize, required this.dispose, required this.isDisposed})
      : assert(maxSize > 0);

  final int maxSize;
  final void Function(R runtime) dispose;
  final bool Function(R runtime) isDisposed;

  /// Live entries in LRU order (first = least recently used).
  final Map<String, _PoolEntry<R>> _runtimes = <String, _PoolEntry<R>>{};

  /// Retired entries still in use; disposed on their last release.
  final List<_PoolEntry<R>> _retiredBusy = <_PoolEntry<R>>[];

  int get length => _runtimes.length;
  Iterable<String> get keys => _runtimes.keys;
  int get retiredBusyCount => _retiredBusy.length;

  /// Returns the pooled runtime for [key] (creating it with [create]) and
  /// marks it in use. Every acquire must be paired with [release].
  R acquire(String key, int fingerprint, R Function() create) {
    final hit = _runtimes.remove(key);
    if (hit != null) {
      if (hit.fingerprint == fingerprint && !isDisposed(hit.runtime)) {
        _runtimes[key] = hit; // move to MRU
        hit.inUse++;
        return hit.runtime;
      }
      _retire(hit);
    }
    _evictIdleOverflow(reserve: 1);
    final entry = _PoolEntry<R>(create(), fingerprint)..inUse = 1;
    _runtimes[key] = entry;
    return entry.runtime;
  }

  /// Ends one use of [runtime] that was acquired under [key].
  void release(String key, R runtime) {
    final live = _runtimes[key];
    if (live != null && identical(live.runtime, runtime)) {
      if (live.inUse > 0) live.inUse--;
      _evictIdleOverflow();
      return;
    }
    for (var i = 0; i < _retiredBusy.length; i++) {
      final e = _retiredBusy[i];
      if (identical(e.runtime, runtime)) {
        if (e.inUse > 0) e.inUse--;
        if (e.inUse == 0) {
          _retiredBusy.removeAt(i);
          _safeDispose(e.runtime);
        }
        return;
      }
    }
  }

  /// Drops [key]'s runtime (disposed now if idle, else on last release).
  void invalidate(String key) {
    final e = _runtimes.remove(key);
    if (e != null) _retire(e);
  }

  /// Disposes everything, including retired runtimes still marked busy
  /// (app shutdown / tests).
  void disposeAll() {
    for (final e in _runtimes.values) {
      _safeDispose(e.runtime);
    }
    for (final e in _retiredBusy) {
      _safeDispose(e.runtime);
    }
    _runtimes.clear();
    _retiredBusy.clear();
  }

  void _retire(_PoolEntry<R> e) {
    if (e.retired) return;
    e.retired = true;
    if (e.inUse > 0) {
      _retiredBusy.add(e);
    } else {
      _safeDispose(e.runtime);
    }
  }

  /// Evicts least-recently-used IDLE entries until there is room for
  /// [reserve] more. Busy entries are skipped; the pool may briefly exceed
  /// [maxSize] and shrinks back as they are released.
  void _evictIdleOverflow({int reserve = 0}) {
    while (_runtimes.length + reserve > maxSize) {
      String? victim;
      for (final entry in _runtimes.entries) {
        if (entry.value.inUse == 0) {
          victim = entry.key;
          break;
        }
      }
      if (victim == null) return;
      _retire(_runtimes.remove(victim)!);
    }
  }

  void _safeDispose(R r) {
    try {
      if (!isDisposed(r)) dispose(r);
    } catch (_) {}
  }
}
