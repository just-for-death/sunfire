// UIX-18: correlation ids are Zone-scoped and only printed when set.
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/logging/logger_service.dart';

void main() {
  final log = LoggerService.instance;

  List<LogEntry> entriesWith(String marker) =>
      log.inMemoryLogs.where((e) => e.message.contains(marker)).toList();

  test('outside any scope: no id, no corr= in the output', () async {
    expect(LoggerService.currentCorrelationId, isNull);
    await log.logInfo('uix18-outside');
    final e = entriesWith('uix18-outside').single;
    expect(e.correlationId, isNull);
    expect(e.format().contains('corr='), isFalse);
  });

  test('two concurrent flows keep their own ids across awaits', () async {
    final gateA = Completer<void>();
    final gateB = Completer<void>();
    final flowA = LoggerService.withCorrelationAsync(() async {
      await log.logInfo('uix18-A1');
      await gateA.future; // B runs and logs while A is suspended
      await log.logInfo('uix18-A2');
      return LoggerService.currentCorrelationId;
    }, correlationId: 'aaaa1111');
    final flowB = LoggerService.withCorrelationAsync(() async {
      await log.logInfo('uix18-B1');
      gateA.complete();
      await gateB.future;
      await log.logInfo('uix18-B2');
      return LoggerService.currentCorrelationId;
    }, correlationId: 'bbbb2222');
    await Future<void>.delayed(Duration.zero);
    gateB.complete();
    expect(await flowA, 'aaaa1111');
    expect(await flowB, 'bbbb2222');
    for (final m in ['uix18-A1', 'uix18-A2']) {
      expect(entriesWith(m).single.correlationId, 'aaaa1111', reason: m);
    }
    for (final m in ['uix18-B1', 'uix18-B2']) {
      expect(entriesWith(m).single.correlationId, 'bbbb2222', reason: m);
    }
    expect(entriesWith('uix18-A2').single.format(), contains('[corr=aaaa1111]'));
    expect(LoggerService.currentCorrelationId, isNull, reason: 'scope does not leak');
  });

  test('generated ids are stable within a scope and differ between scopes', () async {
    final a = await LoggerService.withCorrelationAsync(() async {
      final first = LoggerService.currentCorrelationId;
      await Future<void>.delayed(Duration.zero);
      expect(LoggerService.currentCorrelationId, first);
      return first;
    });
    final b = LoggerService.withCorrelation(() => LoggerService.currentCorrelationId);
    expect(a, isNotNull);
    expect(b, isNotNull);
    expect(a, isNot(b));
  });
}
