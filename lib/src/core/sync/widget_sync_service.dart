// lib/src/core/sync/widget_sync_service.dart
//
// WidgetSyncService - Dart side of the Android Continue Reading widget (A7.4).
//
// Persists the current reading session to SharedPreferences (Flutter prefs
// file) and pings the native widget to refresh. The native
// ContinueReadingWidget reads the same prefs file. All failures are
// swallowed: the widget is best-effort and must never break reading.

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Syncs "continue reading" state to the home-screen widget (A7.4).
class WidgetSyncService {
  WidgetSyncService._();
  static final WidgetSyncService instance = WidgetSyncService._();

  static const String keyTitle = 'widget_title';
  static const String keySubtitle = 'widget_subtitle';
  static const String keyMangaId = 'widget_manga_id';
  static const String keyChapterId = 'widget_chapter_id';
  static const String keyUpdatedAt = 'widget_updated_at';

  static const MethodChannel _channel =
      MethodChannel('sunfire/quick_actions');

  /// Record the current reading session for the widget.
  Future<void> updateContinueReading({
    required String mangaTitle,
    required String chapterName,
    required int mangaId,
    required int chapterId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(keyTitle, mangaTitle);
      await prefs.setString(keySubtitle, chapterName);
      await prefs.setInt(keyMangaId, mangaId);
      await prefs.setInt(keyChapterId, chapterId);
      await prefs.setInt(keyUpdatedAt,
          DateTime.now().millisecondsSinceEpoch ~/ 1000);
      // Push a widget refresh (no-op where the channel is absent).
      try {
        await _channel.invokeMethod('refreshWidget');
      } catch (e) { debugPrint('[widget_sync_service] ignored: $e'); }
    } catch (e) {
      debugPrint('[WidgetSync] update failed: $e');
    }
  }

  /// Clear the widget state (e.g. on logout / library clear).
  Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(keyTitle);
      await prefs.remove(keySubtitle);
      await prefs.remove(keyMangaId);
      await prefs.remove(keyChapterId);
      await prefs.remove(keyUpdatedAt);
    } catch (e) {
      debugPrint('[WidgetSync] clear failed: $e');
    }
  }
}
