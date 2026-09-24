import 'package:flutter/foundation.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Reference-counted wakelock. WakelockPlus is a single global switch, so a
/// background sync calling `disable()` would also turn off the reader's
/// keep-screen-awake. Each owner ("reader", "sync", ...) requests or releases
/// the lock independently; the platform lock is on while ANY owner holds it.
class WakelockCoordinator {
  WakelockCoordinator._();
  static final WakelockCoordinator instance = WakelockCoordinator._();

  final Set<String> _owners = <String>{};

  @visibleForTesting
  Set<String> get owners => Set<String>.unmodifiable(_owners);

  Future<void> acquire(String owner) async {
    final wasEmpty = _owners.isEmpty;
    _owners.add(owner);
    if (wasEmpty) {
      try {
        await WakelockPlus.enable();
      } catch (_) {}
    }
  }

  Future<void> release(String owner) async {
    if (!_owners.remove(owner)) return;
    if (_owners.isEmpty) {
      try {
        await WakelockPlus.disable();
      } catch (_) {}
    }
  }
}
