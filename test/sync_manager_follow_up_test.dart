// ISS-051: SyncManager queues ONE follow-up per kind instead of returning
// "Sync already in progress", and never double-counts on the engine gate.
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sunfire/src/core/sync/sync_engine.dart';
import 'package:sunfire/src/core/sync/sync_manager.dart';

import 'reader_controller_test.mocks.dart';

void main() {
  late MockSyncEngine engine;
  late MockIsarService isar;
  late StreamController<void> cycles;
  late bool engineBusy;
  late List<Set<int>> calls;
  late List<Completer<SyncResult>> gates;

  setUp(() {
    engine = MockSyncEngine();
    isar = MockIsarService();
    cycles = StreamController<void>.broadcast();
    engineBusy = false;
    calls = [];
    gates = [];
    when(engine.isSyncing).thenAnswer((_) => engineBusy);
    when(engine.onSyncCycleComplete).thenAnswer((_) => cycles.stream);
    when(engine.syncCategoriesByIds(any)).thenAnswer((inv) {
      calls.add(Set<int>.of(inv.positionalArguments.first as Set<int>));
      final g = Completer<SyncResult>();
      gates.add(g);
      return g.future;
    });
  });

  tearDown(() => cycles.close());

  Future<void> settle() async {
    for (var i = 0; i < 10; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  test('busy manager: callers join one merged follow-up, run once after', () async {
    final m = SyncManager.forTest(syncEngine: engine, isarService: isar);
    final first = m.syncCategories({1});
    await settle();
    expect(m.isSyncing, isTrue);
    final a = m.syncCategories({2});
    final b = m.syncCategories({3});
    expect(m.queuedFollowUps, {'categories'});
    expect(calls, [{1}], reason: 'nothing dropped, nothing run yet');

    gates[0].complete(const SyncResult(success: true));
    expect((await first).success, isTrue);
    await settle();
    expect(calls, [{1}, {2, 3}], reason: 'exactly one rerun with merged ids');
    gates[1].complete(const SyncResult(success: true, categoriesUpdated: 2));
    final ra = await a;
    final rb = await b;
    expect(ra.success, isTrue);
    expect(identical(ra, rb), isTrue, reason: 'both callers share the follow-up result');
    expect(ra.errors, isNot(contains('Sync already in progress')));
    expect(m.queuedFollowUps, isEmpty);
  });

  test('busy engine: waits for onSyncCycleComplete, never calls triggerSync', () async {
    engineBusy = true;
    final m = SyncManager.forTest(syncEngine: engine, isarService: isar);
    final r = m.syncCategories({5});
    await settle();
    expect(calls, isEmpty);
    engineBusy = false;
    cycles.add(null);
    await settle();
    expect(calls, [{5}]);
    gates[0].complete(const SyncResult(success: true));
    expect((await r).success, isTrue);
    verifyNever(engine.triggerSync());
  });
}
