// IMP-037: download concurrency setting + per-source throttle.
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunfire/src/core/services/download_throttle.dart';
import 'package:sunfire/src/core/services/settings_service.dart';

void main() {
  test('setting defaults to 5, clamps to 1-8; per-source default 2', () async {
    SharedPreferences.setMockInitialValues({});
    final s = SettingsService.instance;
    await s.initialize();
    expect(s.downloadConcurrency, 5);
    expect(s.downloadPerSourceLimit, 2);
    s.downloadConcurrency = 20;
    expect(s.downloadConcurrency, 8);
    s.downloadConcurrency = 0;
    expect(s.downloadConcurrency, 1);
  });

  test('pool keeps at most N jobs in flight and runs every job once', () async {
    var inFlight = 0, peak = 0;
    final done = <int>[];
    await runBoundedPool(
      count: 20,
      concurrency: 3,
      job: (i) async {
        inFlight++;
        peak = inFlight > peak ? inFlight : peak;
        await Future<void>.delayed(Duration(milliseconds: 1 + i % 3));
        inFlight--;
        done.add(i);
      },
    );
    expect(peak, 3);
    expect(done..sort(), List.generate(20, (i) => i));
  });

  test('pool stops starting jobs once shouldStop is true', () async {
    var started = 0;
    await runBoundedPool(
      count: 50,
      concurrency: 2,
      shouldStop: () => started >= 4,
      job: (i) async {
        started++;
        await Future<void>.delayed(Duration.zero);
      },
    );
    expect(started, lessThanOrEqualTo(5));
  });

  test('per-source throttle caps one source but not another', () async {
    final t = SourceThrottle(limit: () => 2);
    var peakA = 0;
    final gate = Completer<void>();
    final futures = <Future<void>>[
      for (var i = 0; i < 6; i++)
        t.run('A', () async {
          peakA = t.activeFor('A') > peakA ? t.activeFor('A') : peakA;
          await gate.future;
        }),
      t.run('B', () async {}),
    ];
    await Future<void>.delayed(Duration.zero);
    expect(t.activeFor('A'), 2);
    gate.complete();
    await Future.wait(futures);
    expect(peakA, 2);
    expect(t.activeFor('A'), 0);
  });
}
