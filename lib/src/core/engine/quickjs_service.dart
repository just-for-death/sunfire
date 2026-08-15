import 'dart:convert';
import 'dart:io';
import 'package:flutter_qjs/flutter_qjs.dart';
import 'package:path_provider/path_provider.dart';

import '../logging/logger_service.dart';

class QuickJsService {
  static QuickJsService? _instance;
  FlutterQjs? _engine;

  final Map<String, String> _installedJsSources = {};

  QuickJsService._();

  static QuickJsService get instance {
    _instance ??= QuickJsService._();
    return _instance!;
  }

  Future<void> initialize() async {
    try {
      _engine = FlutterQjs(
        stackSize: 1024 * 1024 * 2, // 2MB stack
      );
      _engine!.dispatch();
      await _loadInstalledExtensionsFromDisk();
    } catch (e, stack) {
      await LoggerService.instance.logError('Failed to initialize QuickJS: $e', exception: e, stackTrace: stack, category: 'QuickJS');
    }
  }

  Future<void> _loadInstalledExtensionsFromDisk() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final extDir = Directory('${appDir.path}/extensions');
      if (await extDir.exists()) {
        final files = await extDir.list().toList();
        for (final f in files) {
          if (f is File && f.path.endsWith('.js')) {
            final fileName = f.uri.pathSegments.last.replaceAll('.js', '');
            final code = await f.readAsString();
            _installedJsSources[fileName.toLowerCase()] = code;
          }
        }
      }
    } catch (_) {}
  }

  Future<bool> saveLocalExtension(String sourceName, String jsCode) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final extDir = Directory('${appDir.path}/extensions');
      if (!await extDir.exists()) {
        await extDir.create(recursive: true);
      }
      final cleanName = sourceName.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_').toLowerCase();
      final file = File('${extDir.path}/$cleanName.js');
      await file.writeAsString(jsCode);
      _installedJsSources[cleanName] = jsCode;
      _installedJsSources[sourceName.toLowerCase()] = jsCode;
      return true;
    } catch (e) {
      await LoggerService.instance.logError('Failed to save local JS extension $sourceName: $e', category: 'QuickJS');
      return false;
    }
  }

  bool isLocalExtensionInstalled(String sourceName) {
    final clean = sourceName.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_').toLowerCase();
    return _installedJsSources.containsKey(clean) || _installedJsSources.containsKey(sourceName.toLowerCase());
  }

  String? getExtensionCode(String sourceName) {
    final clean = sourceName.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_').toLowerCase();
    return _installedJsSources[clean] ?? _installedJsSources[sourceName.toLowerCase()];
  }

  /// ── SCRAPE SOURCE MANGA DIRECTLY ON DEVICE ───────────────────
  Future<List<Map<String, dynamic>>> fetchSourceMangaLocal(
    String sourceName, {
    bool isLatest = false,
    int page = 1,
    String? searchQuery,
  }) async {
    final jsCode = getExtensionCode(sourceName);
    if (jsCode == null || jsCode.isEmpty) {
      return [];
    }

    try {
      final functionName = searchQuery != null && searchQuery.isNotEmpty
          ? 'searchManga'
          : (isLatest ? 'getLatestUpdates' : 'getPopularManga');

      final result = await evaluateExtensionScript(
        jsCode,
        functionName,
        searchQuery != null && searchQuery.isNotEmpty ? [searchQuery, page] : [page],
      );

      if (result.containsKey('list') && result['list'] is List) {
        final list = result['list'] as List<dynamic>;
        return list.map((item) => Map<String, dynamic>.from(item as Map)).toList();
      }
    } catch (e) {
      await LoggerService.instance.logWarning('Local scraping failed for $sourceName: $e', 'QuickJS');
    }
    return [];
  }

  /// ── SCRAPE CHAPTER PAGES DIRECTLY ON DEVICE ──────────────────
  Future<List<String>> fetchChapterPagesLocal(String sourceName, String chapterUrl) async {
    final jsCode = getExtensionCode(sourceName);
    if (jsCode == null || jsCode.isEmpty) {
      return [];
    }

    try {
      final result = await evaluateExtensionScript(
        jsCode,
        'getPageList',
        [chapterUrl],
      );

      if (result.containsKey('pages') && result['pages'] is List) {
        final pages = result['pages'] as List<dynamic>;
        return pages.map((p) => p.toString()).toList();
      }
    } catch (e) {
      await LoggerService.instance.logWarning('Local chapter page scraping failed for $sourceName: $e', 'QuickJS');
    }
    return [];
  }

  Future<Map<String, dynamic>> evaluateExtensionScript(String jsCode, String functionName, List<dynamic> args) async {
    if (_engine == null) {
      initialize();
    }

    try {
      final script = '''
        (function() {
          $jsCode
          if (typeof $functionName === 'function') {
            return JSON.stringify($functionName(${args.map((a) => jsonEncode(a)).join(', ')}));
          }
          return JSON.stringify({ error: 'Function $functionName not found' });
        })();
      ''';

      final rawResult = await _engine!.evaluate(script);
      final jsonStr = rawResult.toString();
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (e, stack) {
      await LoggerService.instance.logError('QuickJS Evaluation error in $functionName: $e', exception: e, stackTrace: stack, category: 'QuickJS');
      return {'error': e.toString()};
    }
  }

  void dispose() {
    _engine?.close();
    _engine = null;
  }
}
