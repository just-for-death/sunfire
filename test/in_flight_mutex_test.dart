// In-flight de-duplication for concurrent fetches.
//
// WHY THIS EXISTS
//
// Cover images are fetched by `MangaCoverImage` in `initState`, so a grid of
// 200 covers fires 200 fetches on the first frame — and a scroll or a rebuild
// re-requests the same URLs while the first attempts are still open. The mutex
// collapses those into one fetch per URL.
//
// It used to be a memo table as well, and it was broken three ways at once. All
// three are invisible to any test that only checks the happy path, which is why
// they survived: a 740-test suite was green throughout.
//
//   1. It called the computation closure TWICE per miss — once to start the
//      tracked future, once to await it. So every cache-missing cover ran the
//      full 7-pass HTTP cascade, the desktop curl fallback and both Isar writes
//      twice, concurrently. Double bandwidth, double CDN requests — which is
//      exactly the anti-hotlink heuristic the later passes work around — and two
//      concurrent write transactions on the same row.
//   2. It completed one `Completer` from two paths, so the second to finish threw
//      `StateError: Future already completed`; the catch then called
//      `completeError` on the already-completed completer, throwing again and
//      escaping. The entry's error was poisoned, so one hit broke that key for
//      the life of the process.
//   3. It notified waiters only on success, so a caller that lost the race waited
//      forever. Both production call sites are fire-and-forget, so the tile just
//      sat on its fallback with nothing logged anywhere.
//
// The memoisation it was reaching for is unnecessary and was itself a leak: a
// second uncapped reference to every result pinned ~80 MB of cover bytes on a
// 1000-title library, outside the caller's 200-entry LRU. `release()` existed to
// clear it and was never called from anywhere.
//
// Run: fvm flutter test test/in_flight_mutex_test.dart
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/services/in_flight_mutex.dart';

Uint8List _bytes(int n) => Uint8List(n);

void main() {
  group('de-duplication', () {
    test('concurrent callers share ONE computation', () async {
      // The core defect. The old implementation invoked the closure twice for a
      // single miss, so the counter here went to 2 and the caller awaited a
      // different future than the one the mutex was tracking.
      final mutex = InFlightMutex<Uint8List?>();
      var calls = 0;
      final gate = Completer<void>();

      Future<Uint8List?> body() async {
        calls++;
        await gate.future;
        return _bytes(10);
      }

      final a = mutex.run('u', body);
      final b = mutex.run('u', body);
      final c = mutex.run('u', body);
      expect(calls, 1, reason: 'three callers, one computation');

      gate.complete();
      final results = await Future.wait([a, b, c]);
      expect(results.map((r) => r!.length).toList(), [10, 10, 10]);
      expect(calls, 1);
    });

    test('the same future instance is handed to every joiner', () async {
      // Not just an equal value — the identical future. That is what makes a
      // joiner observe the leader's error rather than starting a second attempt.
      final mutex = InFlightMutex<Uint8List?>();
      final gate = Completer<void>();
      Future<Uint8List?> body() async {
        await gate.future;
        return _bytes(1);
      }

      final a = mutex.run('u', body);
      final b = mutex.run('u', body);
      expect(identical(a, b), isTrue);
      gate.complete();
      await Future.wait([a, b]);
    });

    test('different keys do not block each other', () async {
      // A serialising lock would deadlock or serialise unrelated covers.
      final mutex = InFlightMutex<Uint8List?>();
      var running = 0;
      var maxConcurrent = 0;
      Future<Uint8List?> body() async {
        running++;
        maxConcurrent = maxConcurrent > running ? maxConcurrent : running;
        await Future<void>.delayed(const Duration(milliseconds: 5));
        running--;
        return _bytes(1);
      }

      await Future.wait([
        for (var i = 0; i < 8; i++) mutex.run('k$i', body),
      ]);
      expect(maxConcurrent, greaterThan(1), reason: 'distinct keys must run in parallel');
    });
  });

  group('the entry does not outlive its computation', () {
    test('a settled entry is dropped, so the map cannot grow unbounded', () async {
      // The old version kept every completed entry forever, holding its result
      // and short-circuiting all later calls. A miss after a hit re-runs.
      final mutex = InFlightMutex<Uint8List?>();
      var calls = 0;
      Future<Uint8List?> body() async {
        calls++;
        return _bytes(1);
      }

      for (var i = 0; i < 50; i++) {
        await mutex.run('url_$i', body);
      }
      expect(mutex.inFlightCount, 0, reason: 'nothing should be retained after settling');

      await mutex.run('url_0', body);
      expect(calls, 51, reason: 'a settled entry must not short-circuit a later call');
      expect(mutex.inFlightCount, 0);
    });

    test('concurrent distinct keys all drain to zero', () async {
      final mutex = InFlightMutex<Uint8List?>();
      Future<Uint8List?> body() async {
        await Future<void>.delayed(const Duration(milliseconds: 2));
        return _bytes(1);
      }
      await Future.wait([for (var i = 0; i < 30; i++) mutex.run('k$i', body)]);
      expect(mutex.inFlightCount, 0);
    });
  });

  group('failures', () {
    test('a failure propagates to the leader AND every joiner', () async {
      // The old version poisoned its stored error with a StateError from
      // double-completing the completer, so a single hit broke the key forever.
      final mutex = InFlightMutex<Uint8List?>();
      final gate = Completer<void>();
      Future<Uint8List?> body() async {
        await gate.future;
        throw StateError('network down');
      }

      final a = mutex.run('u', body);
      final b = mutex.run('u', body);
      final c = mutex.run('u', body);
      gate.complete();

      for (final f in [a, b, c]) {
        await expectLater(f, throwsA(isA<StateError>()));
      }
      expect(mutex.inFlightCount, 0, reason: 'a failure must still drop the entry');
    });

    test('a key that failed can be retried immediately', () async {
      // Not poisoned. The old entry cached its error and rethrew it forever.
      final mutex = InFlightMutex<Uint8List?>();
      var calls = 0;
      Future<Uint8List?> body() async {
        calls++;
        if (calls == 1) throw StateError('first attempt fails');
        return _bytes(7);
      }

      await expectLater(mutex.run('u', body), throwsA(isA<StateError>()));
      final second = await mutex.run('u', body);
      expect(second!.length, 7, reason: 'a retry after a failure must actually run');
      expect(calls, 2);
    });

    test('a synchronous throw inside the closure does not wedge the key', () async {
      // If the entry were recorded before the closure was invoked, a synchronous
      // throw would leave a future nobody awaits while every later caller joined
      // it — hanging forever.
      final mutex = InFlightMutex<Uint8List?>();
      var calls = 0;
      Future<Uint8List?> body() {
        calls++;
        if (calls == 1) throw StateError('threw before returning a future');
        return Future<Uint8List?>.value(_bytes(3));
      }

      await expectLater(mutex.run('u', body), throwsA(isA<StateError>()));
      expect(mutex.inFlightCount, 0);

      final ok = await mutex.run('u', body);
      expect(ok!.length, 3, reason: 'the key must not be wedged by a sync throw');
    });

    test('one key failing does not disturb another', () async {
      final mutex = InFlightMutex<Uint8List?>();
      final good = mutex.run('good', () async => _bytes(1));
      final bad = mutex.run('bad', () async => throw StateError('x'));
      await expectLater(bad, throwsA(isA<StateError>()));
      expect((await good)!.length, 1);
      expect(mutex.inFlightCount, 0);
    });
  });

  group('a null result is a value, not a failure', () {
    test('null is shared with joiners and the entry still drains', () async {
      // Every fetch pass can legitimately come back empty, so null is an
      // ordinary outcome. The mutex must not treat it as an error, and must not
      // keep the entry alive to "remember" it.
      final mutex = InFlightMutex<Uint8List?>();
      final gate = Completer<void>();
      var calls = 0;
      Future<Uint8List?> body() async {
        calls++;
        await gate.future;
        return null;
      }

      final a = mutex.run('u', body);
      final b = mutex.run('u', body);
      gate.complete();

      expect(await a, isNull);
      expect(await b, isNull);
      expect(calls, 1);
      expect(mutex.inFlightCount, 0);
    });
  });
}
