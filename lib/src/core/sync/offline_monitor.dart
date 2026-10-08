import 'package:flutter/foundation.dart';

/// Single authority for "can we reach the server right now".
///
/// Today every subsystem probes independently (sync fast-fail flags, library
/// update probes, ad-hoc query timeouts), so the app has no coherent offline
/// state: background jobs burn battery retrying on dead connections, and the
/// UI can only guess. This monitor centralizes the verdict with a debounced
/// state machine fed by the GraphQL layer's existing transport
/// classification ([reportTransportSuccess]/[reportTransportFailure]):
///
/// * offline is declared after [offlineAfterFailures] CONSECUTIVE transport
///   failures (one dropped packet must not flip the whole UI);
/// * any single success recovers immediately (fast return beats symmetric
///   debounce — a working connection should be used, not waited out);
/// * 401/403s never touch this: the server answered, so only credentials
///   are dead (auth errors flow through `notifyAuthError`, not here).
///
/// In-memory only: a fresh assessment each launch is correct (yesterday's
/// outage says nothing about now).
class OfflineMonitor extends ChangeNotifier {
  static OfflineMonitor? _instance;
  static OfflineMonitor get instance => _instance ??= OfflineMonitor._();
  OfflineMonitor._();

  /// Failures in a row that declare an outage. Tuned so a single timeout
  /// during a sync burst doesn't flip the UI, while a dead server is
  /// recognized within ~3 consecutive attempts.
  static const int offlineAfterFailures = 3;

  bool _offline = false;
  int _consecutiveFailures = 0;
  DateTime? _offlineSince;
  DateTime? _lastOnlineAt;

  bool get isOffline => _offline;

  /// Online and reachable right now (inverse of [isOffline]).
  bool get isOnline => !_offline;
  int get consecutiveFailures => _consecutiveFailures;
  DateTime? get offlineSince => _offlineSince;
  DateTime? get lastOnlineAt => _lastOnlineAt;

  /// A request completed over a working transport. Recovers immediately.
  void reportTransportSuccess() {
    _lastOnlineAt = DateTime.now();
    var changed = false;
    if (_consecutiveFailures != 0) {
      _consecutiveFailures = 0;
      changed = true;
    }
    if (_offline) {
      _offline = false;
      _offlineSince = null;
      changed = true;
    }
    if (changed) notifyListeners();
  }

  /// A request failed at the transport level (timeout, refused, DNS, 5xx).
  /// Counts toward the debounce; flips to offline at the threshold.
  void reportTransportFailure() {
    _consecutiveFailures++;
    if (!_offline && shouldDeclareOffline(_consecutiveFailures)) {
      _offline = true;
      _offlineSince = DateTime.now();
      notifyListeners();
    }
  }

  /// Explicit probe result (e.g. from `checkServerReachable`).
  ///
  /// [reachable] true recovers like any success. False counts exactly like a
  /// transport failure — EXCEPT callers must not report auth rejections here
  /// (a 401 proves the transport works).
  void reportProbe({required bool reachable}) {
    if (reachable) {
      reportTransportSuccess();
    } else {
      reportTransportFailure();
    }
  }

  /// Pure policy: how many consecutive failures declare an outage.
  /// Split out so tests pin the threshold without timers or singletons.
  static bool shouldDeclareOffline(int consecutiveFailures) =>
      consecutiveFailures >= offlineAfterFailures;

  @visibleForTesting
  void debugReset() {
    _offline = false;
    _consecutiveFailures = 0;
    _offlineSince = null;
    _lastOnlineAt = null;
  }
}
