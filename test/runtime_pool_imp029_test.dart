// IMP-029: RuntimePool policy (pure; no QuickJS FFI).
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/engine/runtime_pool.dart';

class _Rt {
  _Rt(this.name);
  final String name;
  bool disposed = false;
}

void main() {
  late List<String> created;
  late RuntimePool<_Rt> pool;

  setUp(() {
    created = [];
    pool = RuntimePool<_Rt>(maxSize: 2, dispose: (r) => r.disposed = true, isDisposed: (r) => r.disposed);
  });

  _Rt make(String k) {
    created.add(k);
    return _Rt(k);
  }

  test('reuses a runtime per key and code fingerprint', () {
    final a = pool.acquire('a', 1, () => make('a'));
    pool.release('a', a);
    expect(identical(pool.acquire('a', 1, () => make('a')), a), isTrue);
    expect(created, ['a']);
  });

  test('changed extension code gets a fresh runtime; the old one is disposed', () {
    final a1 = pool.acquire('a', 1, () => make('a'));
    pool.release('a', a1);
    final a2 = pool.acquire('a', 2, () => make('a'));
    expect(identical(a1, a2), isFalse);
    expect(a1.disposed, isTrue);
  });

  test('LRU evicts the least recently used IDLE runtime', () {
    final a = pool.acquire('a', 1, () => make('a'));
    pool.release('a', a);
    final b = pool.acquire('b', 1, () => make('b'));
    pool.release('b', b);
    pool.release('a', pool.acquire('a', 1, () => make('a'))); // a is now MRU
    final c = pool.acquire('c', 1, () => make('c'));
    pool.release('c', c);
    expect(b.disposed, isTrue);
    expect(a.disposed, isFalse);
    expect(pool.keys, ['a', 'c']);
  });

  test('a busy runtime is never evicted; the pool shrinks back on release', () {
    final a = pool.acquire('a', 1, () => make('a')); // busy
    final b = pool.acquire('b', 1, () => make('b')); // busy
    final c = pool.acquire('c', 1, () => make('c')); // overflow allowed
    expect([a.disposed, b.disposed, c.disposed], [false, false, false]);
    expect(pool.length, 3);
    pool.release('a', a);
    expect(a.disposed, isTrue, reason: 'idle LRU evicted once over capacity');
    expect(pool.length, 2);
    pool
      ..release('b', b)
      ..release('c', c);
    expect(pool.length, 2);
  });

  test('invalidating a busy runtime defers disposal to its last release', () {
    final a = pool.acquire('a', 1, () => make('a'));
    pool.invalidate('a');
    expect(a.disposed, isFalse);
    expect(pool.retiredBusyCount, 1);
    final fresh = pool.acquire('a', 1, () => make('a'));
    expect(identical(fresh, a), isFalse);
    pool.release('a', a);
    expect(a.disposed, isTrue);
    expect(pool.retiredBusyCount, 0);
    expect(fresh.disposed, isFalse);
  });

  test('an externally disposed runtime is replaced; disposeAll clears everything', () {
    final a = pool.acquire('a', 1, () => make('a'));
    pool.release('a', a);
    a.disposed = true;
    final a2 = pool.acquire('a', 1, () => make('a'));
    expect(identical(a, a2), isFalse);
    final b = pool.acquire('b', 1, () => make('b'));
    pool.invalidate('b');
    pool.disposeAll();
    expect([a2.disposed, b.disposed], [true, true]);
    expect(pool.length, 0);
    expect(pool.retiredBusyCount, 0);
  });
}
