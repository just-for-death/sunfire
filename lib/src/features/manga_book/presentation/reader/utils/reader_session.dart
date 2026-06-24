import 'dart:io';

import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../../../../../constants/enum.dart';
import 'reader_system_ui.dart';

/// Tracks nested reader screens so system UI and orientation are only restored
/// when the last reader route is removed (e.g. chapter pushReplacement).
abstract final class ReaderSession {
  static int _depth = 0;

  static void enter() => _depth++;

  static void leave() {
    if (_depth <= 0) return;
    _depth--;
    if (_depth == 0) {
      WakelockPlusBridge.disable();
      SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (_depth == 0) {
          ReaderSystemUi.exitReader();
        }
      });
    }
  }

  static void applyOrientationLock(ReaderOrientationLock? lock) {
    final orientations = switch (lock ?? ReaderOrientationLock.auto) {
      ReaderOrientationLock.portrait => [
          DeviceOrientation.portraitUp,
          if (!Platform.isIOS) DeviceOrientation.portraitDown,
        ],
      ReaderOrientationLock.landscape => [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
      ReaderOrientationLock.auto => DeviceOrientation.values,
    };
    SystemChrome.setPreferredOrientations(orientations);
  }

  static void onEnterReader({required bool chromeVisible}) {
    WakelockPlusBridge.enable();
    ReaderSystemUi.enterReader(chromeVisible: chromeVisible);
  }

  static void onChromeVisibilityChanged(bool visible) {
    if (_depth > 0) {
      ReaderSystemUi.enterReader(chromeVisible: visible);
    }
  }
}

/// Thin bridge so [ReaderSession] does not depend on wakelock_plus directly.
abstract final class WakelockPlusBridge {
  static void Function()? _enable;
  static void Function()? _disable;

  static void register({
    required void Function() enable,
    required void Function() disable,
  }) {
    _enable = enable;
    _disable = disable;
  }

  static void enable() => _enable?.call();
  static void disable() => _disable?.call();
}
