import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'sunfire_breakpoints.dart';

/// Persists Mihon-style Tablet UI mode without touching [SettingsService]
/// (UIS-P2-A; settings_service is owned by UIX-25 lints right now).
abstract final class TabletUiPrefs {
  static const _key = 'sunfire_tablet_ui_mode';

  /// Notifies shell chrome when the mode changes.
  static final ValueNotifier<String> listenable =
      ValueNotifier<String>('Auto');

  static String get mode => listenable.value;

  static Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key) ?? 'Auto';
      final next = SunfireBreakpoints.tabletUiModeOptions.contains(raw)
          ? raw
          : 'Auto';
      SunfireBreakpoints.tabletUiMode = next;
      if (listenable.value != next) {
        listenable.value = next;
      }
    } catch (_) {
      // Prefer Auto if prefs unavailable (tests / locked storage).
      SunfireBreakpoints.tabletUiMode = 'Auto';
    }
  }

  static Future<void> setMode(String value) async {
    final next = SunfireBreakpoints.tabletUiModeOptions.contains(value)
        ? value
        : 'Auto';
    SunfireBreakpoints.tabletUiMode = next;
    listenable.value = next;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, next);
    } catch (_) {
      // In-memory mode still applies for this session.
    }
  }
}
