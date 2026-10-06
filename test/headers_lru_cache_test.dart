// UIX-16: QuickJS headers cache is a real LRU with a throttled TTL sweep.
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/engine/headers_lru_cache.dart';

void main() {
  late DateTime now;
  HeadersLruCache make({int max = 3, Duration ttl = const Duration(hours: 1)}) =>
      HeadersLruCache(maxEntries: max, ttl: ttl, clock: () => now);

  setUp(() => now = DateTime(2026, 10, 6, 12));

  test('re-setting an existing key at capacity evicts nothing', () {
    final c = make();
    c.set('a', {'h': '1'});
    c.set('b', {'h': '2'});
    c.set('c', {'h': '3'});
    c.set('b', {'h': '2b'});
    expect(c.length, 3);
    expect(c.keys.toSet(), {'a', 'b', 'c'});
    expect(c.get('b'), {'h': '2b'});
  });

  test('a read refreshes the entry so it survives eviction (LRU, not FIFO)', () {
    final c = make();
    c.set('a', {'h': '1'});
    c.set('b', {'h': '2'});
    c.set('c', {'h': '3'});
    expect(c.get('a'), isNotNull); // a is now most recent
    c.set('d', {'h': '4'}); // evicts b (least recently used)
    expect(c.containsKey('a'), isTrue);
    expect(c.containsKey('b'), isFalse);
    expect(c.length, 3);
  });

  test('an expired entry returns null and is removed', () {
    final c = make();
    c.set('a', {'h': '1'});
    now = now.add(const Duration(hours: 1, seconds: 1));
    expect(c.get('a'), isNull);
    expect(c.containsKey('a'), isFalse);
  });

  test('reads slide the TTL', () {
    final c = make();
    c.set('a', {'h': '1'});
    now = now.add(const Duration(minutes: 50));
    expect(c.get('a'), isNotNull);
    now = now.add(const Duration(minutes: 50));
    expect(c.get('a'), isNotNull, reason: '100 min after insert but 50 min after last use');
  });

  test('sweep runs at most once a minute and drops expired entries', () {
    final c = make(max: 10);
    c.set('old', {'h': '1'});
    expect(c.maybeSweep(), isTrue);
    now = now.add(const Duration(seconds: 30));
    expect(c.maybeSweep(), isFalse);
    now = now.add(const Duration(hours: 2));
    c.set('fresh', {'h': '2'});
    expect(c.maybeSweep(), isTrue);
    expect(c.keys.toList(), ['fresh']);
    expect(c.maybeSweep(), isFalse);
  });
}
