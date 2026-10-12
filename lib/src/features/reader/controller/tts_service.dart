// lib/src/features/reader/controller/tts_service.dart
//
// R9.4: Text-to-speech with word-boundary highlights.
//
// Speaks OCR'd page text (R9.3) and emits the active word range via a
// broadcast stream so the transcript UI can highlight it. No-ops cleanly
// where TTS is unavailable. Speech rate is persisted.

library;

import 'dart:async';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Word-boundary progress event for highlight UI.
class TtsProgress {
  const TtsProgress({
    required this.text,
    required this.start,
    required this.end,
    required this.word,
  });

  final String text;
  final int start;
  final int end;
  final String word;
}

/// Playback state.
enum TtsState { stopped, playing }

/// Text-to-speech service with highlight callbacks (R9.4).
class TtsService {
  TtsService._();
  static final TtsService instance = TtsService._();

  static const String _kRatePref = 'tts_rate';

  final FlutterTts _tts = FlutterTts();
  final _progressController = StreamController<TtsProgress>.broadcast();
  final _stateController = StreamController<TtsState>.broadcast();

  bool _wired = false;
  TtsState _state = TtsState.stopped;

  /// Word-boundary progress (Android; other platforms emit completion only).
  Stream<TtsProgress> get onProgress => _progressController.stream;

  /// Playback state changes.
  Stream<TtsState> get onStateChanged => _stateController.stream;

  TtsState get state => _state;

  void _setState(TtsState next) {
    if (_state == next) return;
    _state = next;
    _stateController.add(next);
  }

  Future<void> _ensureWired() async {
    if (_wired) return;
    _wired = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final rate = prefs.getDouble(_kRatePref) ?? 0.5;
      await _tts.setSpeechRate(rate);
      await _tts.awaitSpeakCompletion(true);
      _tts.setStartHandler(() => _setState(TtsState.playing));
      _tts.setCompletionHandler(() => _setState(TtsState.stopped));
      _tts.setCancelHandler(() => _setState(TtsState.stopped));
      _tts.setErrorHandler((_) => _setState(TtsState.stopped));
      _tts.setProgressHandler(
          (String text, int start, int end, String word) {
        _progressController.add(
            TtsProgress(text: text, start: start, end: end, word: word));
      });
    } catch (e) {
      debugPrint('[TtsService] wire-up failed: $e');
    }
  }

  /// Persisted speech rate (0.0-1.0, default 0.5).
  Future<double> getRate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getDouble(_kRatePref) ?? 0.5;
    } catch (_) {
      return 0.5;
    }
  }

  Future<void> setRate(double rate) async {
    final clamped = rate.clamp(0.1, 1.0);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_kRatePref, clamped);
      await _tts.setSpeechRate(clamped);
    } catch (e) {
      debugPrint('[TtsService] setRate failed: $e');
    }
  }

  /// Speak [text] in [language] (BCP-47, e.g. 'ja-JP'). Stops any current
  /// utterance first. Empty text is a no-op.
  Future<void> speak(String text, {String? language}) async {
    if (text.trim().isEmpty) return;
    await _ensureWired();
    try {
      await _tts.stop();
      if (language != null && language.isNotEmpty) {
        await _tts.setLanguage(language);
      }
      await _tts.speak(text);
    } catch (e) {
      debugPrint('[TtsService] speak failed: $e');
      _setState(TtsState.stopped);
    }
  }

  /// Speak [blocks] sequentially, calling [onBlock] with the 0-based index
  /// before each block starts (for highlight UI). Returns the number of
  /// blocks spoken. Stops early when [cancelled] returns true. Each block
  /// awaited via awaitSpeakCompletion, so this resolves when done.
  Future<int> speakBlocks(
    List<String> blocks, {
    String? language,
    void Function(int index)? onBlock,
    bool Function()? cancelled,
  }) async {
    var spoken = 0;
    await _ensureWired();
    try {
      await _tts.stop();
      if (language != null && language.isNotEmpty) {
        await _tts.setLanguage(language);
      }
      for (var i = 0; i < blocks.length; i++) {
        if (cancelled != null && cancelled()) break;
        final text = blocks[i].trim();
        if (text.isEmpty) continue;
        onBlock?.call(i);
        await _tts.speak(text);
        spoken++;
      }
    } catch (e) {
      debugPrint('[TtsService] speakBlocks failed: $e');
    } finally {
      _setState(TtsState.stopped);
    }
    return spoken;
  }

  /// Stop playback.
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {
    } finally {
      _setState(TtsState.stopped);
    }
  }

  /// Language tag for an OCR script (best-effort BCP-47 defaults).
  static String languageForScript(String scriptName) {
    switch (scriptName) {
      case 'japanese':
        return 'ja-JP';
      case 'korean':
        return 'ko-KR';
      case 'chinese':
        return 'zh-CN';
      case 'devanagiri':
        return 'hi-IN';
      case 'latin':
      default:
        return 'en-US';
    }
  }
}
