// UIX-09: Isar pre-init write gate.
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/db/write_gate.dart';

void main() {
  late bool open;
  late List<String> drops;
  late WriteGate gate;

  setUp(() {
    open = false;
    drops = [];
    gate = WriteGate(isOpen: () => open, onDrop: drops.add);
  });

  test('(a) init never started: returns immediately, op not run, drop reported', () async {
    var ran = false;
    final result = await gate.run('save', () async => ran = true);
    expect(result, isFalse);
    expect(ran, isFalse);
    expect(drops, ['save']);
  });

  test('(b) init in flight: ops wait, then run in call order after init', () async {
    final initDone = Completer<void>();
    final order = <String>[];
    final init = gate.initialize(() async {
      await initDone.future;
      order.add('init');
      open = true;
    });
    final w1 = gate.run('w1', () async => order.add('w1'));
    final w2 = gate.run('w2', () async => order.add('w2'));
    final w3 = gate.run('w3', () async => order.add('w3'));
    await Future<void>.delayed(Duration.zero);
    expect(order, isEmpty, reason: 'writes must not run before init completes');
    initDone.complete();
    await init;
    expect(await Future.wait([w1, w2, w3]), [true, true, true]);
    expect(order, ['init', 'w1', 'w2', 'w3']);
    // A write after init runs directly.
    expect(await gate.run('w4', () async => order.add('w4')), isTrue);
    expect(order.last, 'w4');
    expect(drops, isEmpty);
  });

  test('(c) init throws: waiting op dropped, next initialize() retries', () async {
    var attempts = 0;
    final failing = gate.initialize(() async {
      attempts++;
      throw StateError('open failed');
    });
    var ran = false;
    final w = gate.run('save', () async => ran = true);
    await expectLater(failing, throwsStateError);
    expect(await w, isFalse);
    expect(ran, isFalse);
    expect(drops, ['save']);

    await gate.initialize(() async {
      attempts++;
      open = true;
    });
    expect(attempts, 2, reason: 'failed init must not be cached');
    expect(await gate.run('save2', () async => ran = true), isTrue);
    expect(ran, isTrue);
  });

  test('synchronous throw in init is not cached either', () async {
    await expectLater(gate.initialize(() => throw StateError('sync')), throwsStateError);
    await Future<void>.delayed(Duration.zero);
    expect(gate.initStarted, isFalse);
  });

  test('concurrent initialize() calls share one open', () async {
    var attempts = 0;
    final a = gate.initialize(() async {
      attempts++;
      open = true;
    });
    final b = gate.initialize(() async => attempts++);
    await Future.wait([a, b]);
    expect(attempts, 1);
  });
}
