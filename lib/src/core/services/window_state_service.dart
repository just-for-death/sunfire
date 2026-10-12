// lib/src/core/services/window_state_service.dart
//
// WindowStateService - desktop window bounds persistence (D9.3).
//
// Saves/restores window size, position, maximized and fullscreen state via
// window_manager + SharedPreferences. No-ops on mobile (window_manager
// throws on unsupported platforms -> caught).

import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/widgets.dart' show Offset, Size;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

/// Persists desktop window state across launches (D9.3).
class WindowStateService {
  WindowStateService._();
  static final WindowStateService instance = WindowStateService._();

  static const String _kWidth = 'window_width';
  static const String _kHeight = 'window_height';
  static const String _kX = 'window_x';
  static const String _kY = 'window_y';
  static const String _kMaximized = 'window_maximized';

  static const double _defaultWidth = 1280;
  static const double _defaultHeight = 800;

  bool get isDesktop {
    try {
      return Platform.isLinux || Platform.isMacOS || Platform.isWindows;
    } catch (_) {
      return false;
    }
  }

  /// Restore saved bounds. Call after window_manager init in main().
  Future<void> restore() async {
    if (!isDesktop) return;
    try {
      await windowManager.ensureInitialized();
      final prefs = await SharedPreferences.getInstance();
      final width = prefs.getDouble(_kWidth) ?? _defaultWidth;
      final height = prefs.getDouble(_kHeight) ?? _defaultHeight;
      final x = prefs.getDouble(_kX);
      final y = prefs.getDouble(_kY);
      final maximized = prefs.getBool(_kMaximized) ?? false;

      await windowManager.setSize(Size(width, height));
      if (x != null && y != null) {
        await windowManager.setPosition(Offset(x, y));
      } else {
        await windowManager.center();
      }
      if (maximized) {
        await windowManager.maximize();
      }
    } catch (e) {
      debugPrint('[WindowState] restore failed: $e');
    }
  }

  /// Save current bounds. Call on window close / periodically.
  Future<void> save() async {
    if (!isDesktop) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final maximized = await windowManager.isMaximized();
      await prefs.setBool(_kMaximized, maximized);
      if (!maximized) {
        final bounds = await windowManager.getBounds();
        await prefs.setDouble(_kWidth, bounds.width);
        await prefs.setDouble(_kHeight, bounds.height);
        await prefs.setDouble(_kX, bounds.left);
        await prefs.setDouble(_kY, bounds.top);
      }
    } catch (e) {
      debugPrint('[WindowState] save failed: $e');
    }
  }
}
