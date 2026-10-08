import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/sync/offline_monitor.dart';

void main() {
  group('OfflineMonitor policy', () {
    late OfflineMonitor monitor;

    setUp(() {
      // Fresh instance: the singleton carries state across tests in one run.
      monitor = OfflineMonitor.instance;
      monitor.debugReset();
    });

    tearDown(() => monitor.debugReset());

    test('stays online below the failure threshold', () {
      expect(OfflineMonitor.shouldDeclareOffline(0), isFalse);
      expect(OfflineMonitor.shouldDeclareOffline(1), isFalse);
      expect(OfflineMonitor.shouldDeclareOffline(2), isFalse);
      expect(
        OfflineMonitor.shouldDeclareOffline(
            OfflineMonitor.offlineAfterFailures),
        isTrue,
      );
    });

    test('declares offline after consecutive failures', () {
      monitor.reportTransportFailure();
      monitor.reportTransportFailure();
      expect(monitor.isOffline, isFalse);
      monitor.reportTransportFailure();
      expect(monitor.isOffline, isTrue);
      expect(monitor.offlineSince, isNotNull);
      expect(monitor.consecutiveFailures, 3);
    });

    test('a single success recovers immediately and resets the count', () {
      monitor.reportTransportFailure();
      monitor.reportTransportFailure();
      monitor.reportTransportFailure();
      expect(monitor.isOffline, isTrue);
      monitor.reportTransportSuccess();
      expect(monitor.isOffline, isFalse);
      expect(monitor.isOnline, isTrue);
      expect(monitor.consecutiveFailures, 0);
      expect(monitor.offlineSince, isNull);
      expect(monitor.lastOnlineAt, isNotNull);
    });

    test('reportProbe routes by reachability', () {
      monitor.reportProbe(reachable: true);
      expect(monitor.isOffline, isFalse);
      for (var i = 0; i < OfflineMonitor.offlineAfterFailures; i++) {
        monitor.reportProbe(reachable: false);
      }
      expect(monitor.isOffline, isTrue);
    });

    test('notifies only on transitions', () {
      var notifications = 0;
      monitor.addListener(() => notifications++);
      monitor.reportTransportSuccess(); // no-op while healthy
      expect(notifications, 0);
      monitor.reportTransportFailure();
      monitor.reportTransportFailure();
      expect(notifications, 0);
      monitor.reportTransportFailure(); // flip to offline
      expect(notifications, 1);
      monitor.reportTransportFailure(); // already offline: silent
      expect(notifications, 1);
      monitor.reportTransportSuccess(); // flip back
      expect(notifications, 2);
    });
  });
}
