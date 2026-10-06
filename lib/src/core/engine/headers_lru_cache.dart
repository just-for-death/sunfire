import 'dart:collection';

/// Bounded LRU cache with a sliding TTL and a throttled sweep (UIX-16).
///
/// Replaces the old pair of maps in `QuickJsService`, which picked the oldest
/// *insert* by an O(n) scan (not LRU), evicted even when overwriting an
/// existing key, and swept up to every entry on each `getImageHeaders` call
/// (that runs inside every cover `build()`).
///
/// * [get] refreshes the entry (moves it to the most-recent end and restarts
///   its TTL), so headers in active use during a long reading session survive.
/// * [set] on an existing key replaces it without evicting anything else.
/// * [maybeSweep] drops expired entries at most once per [sweepInterval].
class HeadersLruCache {
  HeadersLruCache({
    required this.maxEntries,
    required this.ttl,
    this.sweepInterval = const Duration(minutes: 1),
    DateTime Function()? clock,
  }) : _now = clock ?? DateTime.now;

  final int maxEntries;
  final Duration ttl;
  final Duration sweepInterval;
  final DateTime Function() _now;

  final LinkedHashMap<String, ({Map<String, String> v, DateTime at})> _entries = LinkedHashMap();
  DateTime _lastSweep = DateTime.fromMillisecondsSinceEpoch(0);

  int get length => _entries.length;
  Iterable<String> get keys => _entries.keys;
  bool containsKey(String k) => _entries.containsKey(k);

  Map<String, String>? get(String k) {
    final e = _entries.remove(k);
    if (e == null) return null;
    final now = _now();
    if (now.difference(e.at) > ttl) return null; // expired: stays removed
    _entries[k] = (v: e.v, at: now);
    return e.v;
  }

  void set(String k, Map<String, String> v) {
    final existed = _entries.remove(k) != null;
    if (!existed) {
      while (_entries.isNotEmpty && _entries.length >= maxEntries) {
        _entries.remove(_entries.keys.first);
      }
    }
    _entries[k] = (v: v, at: _now());
  }

  /// Removes expired entries, at most once per [sweepInterval]. Returns true
  /// if a sweep ran.
  bool maybeSweep() {
    final now = _now();
    if (now.difference(_lastSweep) < sweepInterval) return false;
    _lastSweep = now;
    _entries.removeWhere((_, e) => now.difference(e.at) > ttl);
    return true;
  }

  void clear() => _entries.clear();
}
