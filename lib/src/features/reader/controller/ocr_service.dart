// lib/src/features/reader/controller/ocr_service.dart
//
// R9.3: On-device text extraction (OCR) for manga pages.
//
// Uses ML Kit text recognition with a persisted script selection (manga is
// most often Japanese, manhwa Korean). Results are cached in memory (LRU)
// and on disk (JSON) keyed by image path + script, so re-reads never
// re-run the recognizer. Only plain block models leak out - ML Kit types
// stay inside this file, keeping callers (and tests) plugin-free.

library;

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart'
    show debugPrint, visibleForTesting;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Supported OCR scripts (mirrors ML Kit's TextRecognitionScript).
enum OcrScript { latin, chinese, devanagiri, japanese, korean }

/// One recognized text block with its bounding box (image coordinates).
class OcrTextBlock {
  const OcrTextBlock({
    required this.text,
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  factory OcrTextBlock.fromJson(Map<String, dynamic> json) => OcrTextBlock(
        text: json['text']?.toString() ?? '',
        left: (json['left'] as num?)?.toDouble() ?? 0,
        top: (json['top'] as num?)?.toDouble() ?? 0,
        right: (json['right'] as num?)?.toDouble() ?? 0,
        bottom: (json['bottom'] as num?)?.toDouble() ?? 0,
      );

  final String text;
  final double left;
  final double top;
  final double right;
  final double bottom;

  Map<String, dynamic> toJson() => {
        'text': text,
        'left': left,
        'top': top,
        'right': right,
        'bottom': bottom,
      };
}

/// OCR result for one page image.
class OcrPageResult {
  const OcrPageResult({
    required this.blocks,
    required this.script,
  });

  factory OcrPageResult.fromJson(Map<String, dynamic> json) {
    final rawBlocks = json['blocks'];
    return OcrPageResult(
      blocks: rawBlocks is List
          ? rawBlocks
              .whereType<Map<String, dynamic>>()
              .map(OcrTextBlock.fromJson)
              .where((b) => b.text.trim().isNotEmpty)
              .toList()
          : const [],
      script: OcrScript.values.byName(
          json['script']?.toString() ?? OcrScript.japanese.name),
    );
  }

  factory OcrPageResult.empty(OcrScript script) =>
      OcrPageResult(blocks: const [], script: script);

  final List<OcrTextBlock> blocks;
  final OcrScript script;

  /// Full page text (blocks joined), for TTS (R9.4).
  String get fullText => blocks.map((b) => b.text).join('\n');

  bool get isEmpty => blocks.isEmpty;

  Map<String, dynamic> toJson() => {
        'script': script.name,
        'blocks': blocks.map((b) => b.toJson()).toList(),
      };
}

/// On-device OCR service (R9.3).
class OcrService {
  OcrService._();
  static final OcrService instance = OcrService._();

  static const String _kScriptPref = 'ocr_script';
  static const int _maxMemoryEntries = 50;

  final LinkedHashMap<String, OcrPageResult> _memoryCache =
      LinkedHashMap<String, OcrPageResult>();
  final Map<OcrScript, TextRecognizer> _recognizers = {};
  int _inFlight = 0;

  /// Whether an OCR pass is currently running (for UI spinners).
  bool get isBusy => _inFlight > 0;

  /// Persisted recognizer script (default: Japanese for manga).
  Future<OcrScript> getScript() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString(_kScriptPref);
      if (name != null) return OcrScript.values.byName(name);
    } catch (e) { debugPrint('[ocr_service] ignored: $e'); }
    return OcrScript.japanese;
  }

  Future<void> setScript(OcrScript script) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kScriptPref, script.name);
    } catch (e) { debugPrint('[ocr_service] ignored: $e'); }
    // Script change invalidates cached results.
    _memoryCache.clear();
  }

  /// Cache key (visible for testing).
  @visibleForTesting
  static String cacheKey(String imagePath, OcrScript script) =>
      '${script.name}|$imagePath';

  /// Recognize text in the page image at [imagePath].
  ///
  /// Returns cached results when available. Empty (not null) on any
  /// failure: OCR is best-effort and must never break reading.
  Future<OcrPageResult> recognizePage(String imagePath) async {
    if (imagePath.isEmpty) return OcrPageResult.empty(await getScript());
    final script = await getScript();
    final key = cacheKey(imagePath, script);

    final mem = _memoryCache[key];
    if (mem != null) return mem;

    final disk = await _readDiskCache(key);
    if (disk != null) {
      _putMemory(key, disk);
      return disk;
    }

    _inFlight++;
    try {
      final bytes = await File(imagePath).readAsBytes();
      return await _recognizeBytes(bytes, key, script);
    } catch (e) {
      debugPrint('[OcrService] recognize failed: $e');
      return OcrPageResult.empty(script);
    } finally {
      _inFlight--;
    }
  }

  /// Recognize text from in-memory image [bytes], cached under [cacheId]
  /// (typically the page URL). Writes a temp file for ML Kit, then deletes
  /// it. Empty on any failure.
  Future<OcrPageResult> recognizeBytes(
    List<int> bytes, {
    required String cacheId,
  }) async {
    final script = await getScript();
    final key = cacheKey(cacheId, script);

    final mem = _memoryCache[key];
    if (mem != null) return mem;

    final disk = await _readDiskCache(key);
    if (disk != null) {
      _putMemory(key, disk);
      return disk;
    }

    _inFlight++;
    try {
      return await _recognizeBytes(bytes, key, script);
    } catch (e) {
      debugPrint('[OcrService] recognize failed: $e');
      return OcrPageResult.empty(script);
    } finally {
      _inFlight--;
    }
  }

  /// Download [url] (with [headers]) then recognize. Used by the reader
  /// Listen flow where pages aren't local files. Empty on any failure.
  Future<OcrPageResult> recognizeUrl(
    String url, {
    Map<String, String>? headers,
  }) async {
    if (url.isEmpty) return OcrPageResult.empty(await getScript());
    final script = await getScript();
    final key = cacheKey(url, script);

    final mem = _memoryCache[key];
    if (mem != null) return mem;

    final disk = await _readDiskCache(key);
    if (disk != null) {
      _putMemory(key, disk);
      return disk;
    }

    _inFlight++;
    try {
      final res = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 15));
      if (res.statusCode != 200 || res.bodyBytes.length < 200) {
        return OcrPageResult.empty(script);
      }
      return await _recognizeBytes(res.bodyBytes, key, script);
    } catch (e) {
      debugPrint('[OcrService] recognizeUrl failed: $e');
      return OcrPageResult.empty(script);
    } finally {
      _inFlight--;
    }
  }

  Future<OcrPageResult> _recognizeBytes(
      List<int> bytes, String key, OcrScript script) async {
    final recognizer = _recognizers.putIfAbsent(
      script,
      () => TextRecognizer(script: _toMlKit(script)),
    );
    final tmpDir = await Directory.systemTemp.createTemp('sunfire_ocr');
    final tmp = File('${tmpDir.path}/page.img');
    try {
      await tmp.writeAsBytes(bytes, flush: true);
      final input = InputImage.fromFilePath(tmp.path);
      final recognized = await recognizer.processImage(input);
      final result = OcrPageResult(
        blocks: [
          for (final b in recognized.blocks)
            if (b.text.trim().isNotEmpty)
              OcrTextBlock(
                text: b.text,
                left: b.boundingBox.left.toDouble(),
                top: b.boundingBox.top.toDouble(),
                right: b.boundingBox.right.toDouble(),
                bottom: b.boundingBox.bottom.toDouble(),
              ),
        ],
        script: script,
      );
      _putMemory(key, result);
      unawaited(_writeDiskCache(key, result));
      return result;
    } finally {
      try {
        await tmpDir.delete(recursive: true);
      } catch (e) { debugPrint('[ocr_service] ignored: $e'); }
    }
  }

  /// Drop all cached results (e.g. on storage pressure).
  Future<void> clearCache() async {
    _memoryCache.clear();
    try {
      final dir = await _cacheDir();
      if (await dir.exists()) {
        await for (final e in dir.list()) {
          if (e is File) await e.delete();
        }
      }
    } catch (e) { debugPrint('[ocr_service] ignored: $e'); }
  }

  void _putMemory(String key, OcrPageResult result) {
    _memoryCache[key] = result;
    while (_memoryCache.length > _maxMemoryEntries) {
      _memoryCache.remove(_memoryCache.keys.first);
    }
  }

  Future<Directory> _cacheDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/ocr_cache');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  String _diskName(String key) =>
      key.hashCode.toUnsigned(20).toRadixString(16);

  Future<OcrPageResult?> _readDiskCache(String key) async {
    try {
      final dir = await _cacheDir();
      final file = File('${dir.path}/${_diskName(key)}.json');
      if (!await file.exists()) return null;
      final json =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      return OcrPageResult.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeDiskCache(String key, OcrPageResult result) async {
    try {
      final dir = await _cacheDir();
      final file = File('${dir.path}/${_diskName(key)}.json');
      await file.writeAsString(jsonEncode(result.toJson()));
    } catch (e) { debugPrint('[ocr_service] ignored: $e'); }
  }

  TextRecognitionScript _toMlKit(OcrScript script) {
    switch (script) {
      case OcrScript.latin:
        return TextRecognitionScript.latin;
      case OcrScript.chinese:
        return TextRecognitionScript.chinese;
      case OcrScript.devanagiri:
        return TextRecognitionScript.devanagiri;
      case OcrScript.japanese:
        return TextRecognitionScript.japanese;
      case OcrScript.korean:
        return TextRecognitionScript.korean;
    }
  }

  /// Close recognizers (app shutdown / tests).
  Future<void> dispose() async {
    for (final r in _recognizers.values) {
      try {
        await r.close();
      } catch (e) { debugPrint('[ocr_service] ignored: $e'); }
    }
    _recognizers.clear();
    _memoryCache.clear();
  }
}
