// lib/src/core/services/multi_window_service.dart
//
// MultiWindowService - desktop multi-window support (D9.4).
//
// Opens manga/reader in a second window via desktop_multi_window. Sub-window
// engines run the same main(): the window arguments select the initial
// route, and background services are skipped there (see main()).

import 'dart:io' show Platform;

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/foundation.dart' show debugPrint;

/// Desktop multi-window support (D9.4).
class MultiWindowService {
  MultiWindowService._();
  static final MultiWindowService instance = MultiWindowService._();

  bool get isDesktop {
    try {
      return Platform.isLinux || Platform.isMacOS || Platform.isWindows;
    } catch (_) {
      return false;
    }
  }

  /// Initial route for THIS engine when launched as a sub-window, or null
  /// for the main window. Format: `manga:<id>` / `reader:<chapterId>`.
  Future<String?> subWindowRoute() async {
    if (!isDesktop) return null;
    try {
      final controller = await WindowController.fromCurrentEngine();
      final args = controller.arguments.trim();
      if (args.isEmpty) return null;
      final parts = args.split(':');
      if (parts.length != 2) return null;
      final id = int.tryParse(parts[1]);
      if (id == null || id == 0) return null;
      switch (parts[0]) {
        case 'manga':
          return '/manga/$id';
        case 'reader':
          return '/reader/$id';
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Open a manga detail page in a new window. Returns false when
  /// multi-window is unavailable (mobile, plugin missing).
  Future<bool> openMangaWindow(int mangaId) async {
    if (!isDesktop || mangaId == 0) return false;
    try {
      final window = await WindowController.create(
        WindowConfiguration(arguments: 'manga:$mangaId'),
      );
      await window.show();
      return true;
    } catch (e) {
      debugPrint('[MultiWindow] openMangaWindow failed: $e');
      return false;
    }
  }

  /// Open a chapter in the reader in a new window.
  Future<bool> openReaderWindow(int chapterId) async {
    if (!isDesktop || chapterId == 0) return false;
    try {
      final window = await WindowController.create(
        WindowConfiguration(arguments: 'reader:$chapterId'),
      );
      await window.show();
      return true;
    } catch (e) {
      debugPrint('[MultiWindow] openReaderWindow failed: $e');
      return false;
    }
  }
}
