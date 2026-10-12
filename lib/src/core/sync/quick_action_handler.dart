// lib/src/core/sync/quick_action_handler.dart
//
// QuickActionHandler - Dart side of Android Quick Settings tile (A7.5) and
// launcher shortcuts that need a sync trigger.
//
// The tile fires ACTION_SYNC -> MainActivity sets a pending flag -> Dart
// consumes it here after startup and runs a manual library update.

import 'dart:async';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart';

import '../services/library_update_service.dart';

/// Handles quick-action requests from platform code (QS tile, shortcuts).
class QuickActionHandler {
  QuickActionHandler._();
  static final QuickActionHandler instance = QuickActionHandler._();

  static const MethodChannel _channel =
      MethodChannel('sunfire/quick_actions');

  bool _started = false;

  /// Start listening. Safe to call multiple times; subsequent calls no-op.
  /// Only meaningful on Android (channel absent elsewhere -> catch below).
  /// No artificial delay: the channel round-trip is async already, and a
  /// pending Timer breaks widget-test teardown invariants.
  Future<void> start() async {
    if (_started) return;
    _started = true;
    await consumePending();
  }

  /// Ask platform code whether a sync was requested (QS tile tap).
  /// Returns true when a manual update was started.
  Future<bool> consumePending() async {
    try {
      final pending =
          await _channel.invokeMethod<bool>('consumePendingSync');
      if (pending == true) {
        debugPrint('[QuickActionHandler] QS tile sync requested');
        unawaited(LibraryUpdateService.instance
            .checkForNewChapters(isManual: true));
        return true;
      }
    } catch (_) {
      // Channel absent (non-Android / unit tests): nothing to consume.
    }
    return false;
  }
}
