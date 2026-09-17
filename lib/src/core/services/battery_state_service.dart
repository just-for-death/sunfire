import 'package:battery_plus/battery_plus.dart';

import '../logging/logger_service.dart';

/// Thin wrapper over `battery_plus` for charge-gated background work.
///
/// Fail-open: when the platform channel is unavailable (headless tests, web,
/// unsupported hosts) `isCharging` reports `true` so queues are never blocked
/// by an unknown battery state — matching [DownloadManagerService]'s fail-open
/// network handling.
class BatteryStateService {
  BatteryStateService._();
  static final BatteryStateService instance = BatteryStateService._();

  final Battery _battery = Battery();

  /// Whether the device is currently charging (or fully charged while plugged in).
  Future<bool> isCharging() async {
    try {
      final state = await _battery.batteryState;
      return state == BatteryState.charging || state == BatteryState.full;
    } catch (e) {
      await LoggerService.instance.logWarning(
        'Battery state unavailable, treating as charging: $e',
        'BatteryStateService',
      );
      return true;
    }
  }

  /// Stream of battery-state changes (unplugged / plugged-in transitions).
  Stream<BatteryState> get onBatteryStateChanged => _battery.onBatteryStateChanged;

  /// Pure gating rule: pause work when the user opted into charge-only mode and
  /// the device is not charging.
  static bool shouldPauseForCharging({
    required bool chargeOnlyEnabled,
    required bool isCharging,
  }) =>
      chargeOnlyEnabled && !isCharging;
}