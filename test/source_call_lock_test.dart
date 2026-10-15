import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/engine/source_call_lock.dart';

void main() {
  test('three or more queued callers never overlap', () async {
    // The holder used to reset the tail to its own (completed) future on exit,
    // so a third caller arriving while the second ran started immediately.
    final lock = SourceCallLock();
    var running = 0;
    var maxRunning = 0;
    Future<void> job() => lock.synchronized(() async {
          running++;
          maxRunning = running > maxRunning ? running : maxRunning;
          await Future<void>.delayed(const Duration(milliseconds: 20));
          running--;
        });

    final a = job();
    final b = job();
    await Future<void>.delayed(const Duration(milliseconds: 25)); // A done, B running
    final c = job();
    final d = job();
    await Future.wait([a, b, c, d]);
    expect(maxRunning, 1);
  });

  test('after an overrun, later callers still wait for the hung holder', () async {
    final lock = SourceCallLock();
    final hung = Completer<void>();
    var hungRunning = true;
    var overlappedHung = false;
    var overruns = 0;

    unawaited(lock.synchronized(() async {
      await hung.future;
      hungRunning = false;
    }));
    // B overruns (uses its own runtime) and finishes while A is still hung.
    await lock.synchronized(() async {}, maxWait: const Duration(milliseconds: 10), onOverrun: () => overruns++);
    expect(overruns, 1);

    // C must not be handed the shared runtime while A is still executing.
    final c = lock.synchronized(() async {
      if (hungRunning) overlappedHung = true;
    }, maxWait: const Duration(seconds: 5));
    await Future<void>.delayed(const Duration(milliseconds: 30));
    hung.complete();
    await c;
    expect(overlappedHung, isFalse);
  });
}
