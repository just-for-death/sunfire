// lib/src/core/sync/live_activities_service.dart
//
// LiveActivitiesService - Dart side of iOS Live Activities (I8.3).
//
// Tracks the active reading session and mirrors progress to the lock
// screen / Dynamic Island via the sunfire/live_activities channel.
// No-ops on non-iOS platforms (channel absent -> caught).

import 'dart:async';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart';

/// Live Activities bridge for reading sessions (I8.3).
class LiveActivitiesService {
  LiveActivitiesService._();
  static final LiveActivitiesService instance = LiveActivitiesService._();

  static const MethodChannel _channel =
      MethodChannel('sunfire/live_activities');

  String? _activeMangaTitle;
  String? _activeChapterName;

  bool get hasActiveSession => _activeMangaTitle != null;

  /// Start a Live Activity for the given reading session.
  Future<void> startReading({
    required String mangaTitle,
    required String chapterName,
  }) async {
    _activeMangaTitle = mangaTitle;
    _activeChapterName = chapterName;
    try {
      await _channel.invokeMethod('startReading', {
        'mangaTitle': mangaTitle,
        'chapterName': chapterName,
      });
    } catch (_) {
      debugPrint('[LiveActivities] startReading unavailable (non-iOS?)');
    }
  }

  /// Update progress (0.0-1.0) of the active session.
  Future<void> updateProgress(double progress) async {
    if (!hasActiveSession) return;
    try {
      await _channel.invokeMethod('updateReading', {
        'mangaTitle': _activeMangaTitle,
        'chapterName': _activeChapterName,
        'progress': progress.clamp(0.0, 1.0),
      });
    } catch (_) {
      debugPrint('[LiveActivities] updateReading unavailable (non-iOS?)');
    }
  }

  /// End the active session.
  Future<void> endReading() async {
    if (!hasActiveSession) return;
    _activeMangaTitle = null;
    _activeChapterName = null;
    try {
      await _channel.invokeMethod('endReading');
    } catch (_) {
      debugPrint('[LiveActivities] endReading unavailable (non-iOS?)');
    }
  }
}

/// Siri Shortcuts bridge: donates "Continue Reading" (I8.4).
class SiriShortcutsService {
  SiriShortcutsService._();
  static final SiriShortcutsService instance = SiriShortcutsService._();

  static const MethodChannel _channel =
      MethodChannel('sunfire/siri_shortcuts');

  /// Donate a continue-reading activity for Siri suggestions.
  Future<void> donateContinueReading({
    required String mangaTitle,
    required String chapterName,
    required int mangaId,
  }) async {
    try {
      await _channel.invokeMethod('donateContinueReading', {
        'mangaTitle': mangaTitle,
        'chapterName': chapterName,
        'mangaId': mangaId,
      });
    } catch (_) {
      debugPrint('[SiriShortcuts] donate unavailable (non-iOS?)');
    }
  }
}
