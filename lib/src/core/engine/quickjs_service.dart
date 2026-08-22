import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../logging/logger_service.dart';
import 'javascript/js_extension_service.dart';

class QuickJsService {
  static QuickJsService? _instance;

  final Map<String, String> _installedJsSources = {};
  final Map<String, String> _canonicalDisplayNames = {};

  QuickJsService._();

  static QuickJsService get instance {
    _instance ??= QuickJsService._();
    return _instance!;
  }


  Future<void> initialize() async {
    try {
      await _loadBundledExtensions();
      await _loadInstalledExtensionsFromDisk();
    } catch (e, stack) {
      await LoggerService.instance.logError('Failed to initialize QuickJS: $e', exception: e, stackTrace: stack, category: 'QuickJS');
    }
  }

  Future<void> _loadBundledExtensions() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final assetPaths = manifest.listAssets().where((p) => p.startsWith('assets/extensions/') && p.endsWith('.js')).toList();
      for (final path in assetPaths) {
        try {
          final code = await rootBundle.loadString(path);
          final filename = path.split('/').last;
          final cleanKey = filename.replaceAll('.js', '').replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_').toLowerCase();
          final displayName = filename.replaceAll('.js', '').replaceAll('_', ' ').trim();
          _installedJsSources[cleanKey] = code;
          _canonicalDisplayNames[cleanKey] = displayName;
        } catch (_) {}
      }
    } catch (_) {}
  }

  Future<void> _loadInstalledExtensionsFromDisk() async {
    final candidateDirs = <String>[];
    try {
      final appDir = await getApplicationDocumentsDirectory();
      candidateDirs.add('${appDir.path}/extensions');
    } catch (_) {}

    candidateDirs.add('/home/zoro/Documents/extensions');
    candidateDirs.add('/home/zoro/Documents/Projects/sunfire/assets/extensions');
    candidateDirs.add('/home/zoro/.local/share/com.sunfire.sunfire/extensions');

    for (final dirPath in candidateDirs) {
      try {
        final extDir = Directory(dirPath);
        if (await extDir.exists()) {
          final files = await extDir.list().toList();
          for (final f in files) {
            if (f is File && f.path.endsWith('.js')) {
              final fileName = f.uri.pathSegments.last.replaceAll('.js', '');
              final code = await f.readAsString();
              if (code.contains('package:mangayomi') || code.contains('import \'package:')) {
                // Ignore Dart bytecode or old Dart extensions that were mistakenly named .js
                continue;
              }
              final cleanKey = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_').toLowerCase();
              final displayName = fileName.replaceAll('_', ' ').trim();
              _installedJsSources[cleanKey] = code;
              _canonicalDisplayNames[cleanKey] = displayName;
            }
          }
        }
      } catch (_) {}
    }
  }

  Future<bool> saveLocalExtension(String sourceName, String jsCode) async {
    final cleanName = sourceName
        .replaceAll(RegExp(r'\s*\([a-zA-Z0-9_]+\)$'), '')
        .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_')
        .toLowerCase();
    final displayName = sourceName.replaceAll(RegExp(r'\s*\([a-zA-Z0-9_]+\)$'), '').trim();

    _installedJsSources[cleanName] = jsCode;
    _canonicalDisplayNames[cleanName] = displayName;

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final extDir = Directory('${appDir.path}/extensions');
      if (!await extDir.exists()) {
        await extDir.create(recursive: true);
      }
      final file = File('${extDir.path}/$cleanName.js');
      await file.writeAsString(jsCode);
      return true;
    } catch (e) {
      await LoggerService.instance.logWarning('Failed to persist extension $sourceName: $e', 'QuickJS');
      return false;
    }
  }

  bool isSourceInstalledLocally(String sourceName) {
    if (sourceName.isEmpty) return false;
    final cleanName = sourceName
        .replaceAll(RegExp(r'\s*\([a-zA-Z0-9_]+\)$'), '')
        .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_')
        .toLowerCase();

    if (_installedJsSources.containsKey(cleanName)) return true;

    for (final key in _installedJsSources.keys) {
      if (cleanName.contains(key) || key.contains(cleanName)) return true;
    }
    return false;
  }

  bool isLocalExtensionInstalled(String sourceName) => isSourceInstalledLocally(sourceName);

  Future<bool> deleteLocalExtension(String sourceName) async {
    final cleanName = sourceName
        .replaceAll(RegExp(r'\s*\([a-zA-Z0-9_]+\)$'), '')
        .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_')
        .toLowerCase();
    _installedJsSources.remove(cleanName);
    _canonicalDisplayNames.remove(cleanName);
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/extensions/$cleanName.js');
      if (await file.exists()) {
        await file.delete();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  List<String> getInstalledExtensionNames() {
    return _canonicalDisplayNames.values.toList();
  }

  static Map<String, String> getImageHeaders(String sourceOrUrl, [String? imageUrl]) {
    if (sourceOrUrl.isEmpty && (imageUrl == null || imageUrl.isEmpty)) return {};

    try {
      final jsCode = instance.getExtensionCode(sourceOrUrl);
      if (jsCode != null && jsCode.isNotEmpty) {
        final headers = instance.getSourceHeaders(jsCode);
        if (headers.isNotEmpty) return headers;
      }
    } catch (_) {}

    String referer = '';
    final targetUrl = (imageUrl != null && imageUrl.isNotEmpty) ? imageUrl : sourceOrUrl;
    if (targetUrl.startsWith('http://') || targetUrl.startsWith('https://')) {
      try {
        final uri = Uri.parse(targetUrl);
        referer = '${uri.scheme}://${uri.host}/';
      } catch (_) {}
    }

    return {
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      if (referer.isNotEmpty) 'Referer': referer,
    };
  }

  Map<String, String> getSourceHeaders(String jsCode) {
    final service = JsExtensionService(
      sourceMeta: extractSourceMetadata(jsCode),
      sourceCode: jsCode,
    );
    try {
      return service.getHeaders();
    } catch (_) {
      return {};
    } finally {
      service.dispose();
    }
  }

  String? getExtensionCode(String sourceName) {
    if (sourceName.isEmpty) return null;
    final cleanName = sourceName
        .replaceAll(RegExp(r'\s*\([a-zA-Z0-9_]+\)$'), '')
        .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_')
        .toLowerCase();

    if (_installedJsSources.containsKey(cleanName)) {
      return _installedJsSources[cleanName];
    }
    for (final entry in _installedJsSources.entries) {
      if (cleanName.contains(entry.key) || entry.key.contains(cleanName)) {
        return entry.value;
      }
    }
    return null;
  }

  Map<String, String> getInstalledSources() {
    final result = <String, String>{};
    for (final entry in _installedJsSources.entries) {
      final displayName = _canonicalDisplayNames[entry.key] ?? entry.key;
      result[displayName] = entry.key;
    }
    return result;
  }

  String? extractBaseUrl(String jsCode) {
    try {
      final match = RegExp(r'''"baseUrl"\s*:\s*"([^"]+)''').firstMatch(jsCode);
      if (match != null) return match.group(1);

      final singleMatch = RegExp(r''''baseUrl'\s*:\s*'([^']+)''').firstMatch(jsCode);
      if (singleMatch != null) return singleMatch.group(1);
    } catch (_) {}
    return null;
  }

  Map<String, dynamic> extractSourceMetadata(String jsCode) {
    try {
      final match = RegExp(r'''const\s+mangayomiSources\s*=\s*(\[\s*\{[\s\S]*?\}\s*\]);''').firstMatch(jsCode);
      if (match != null) {
        final jsonStr = match.group(1)!;
        final decoded = jsonDecode(jsonStr);
        if (decoded is List && decoded.isNotEmpty) {
          return Map<String, dynamic>.from(decoded[0] as Map);
        }
      }
    } catch (_) {}

    final baseUrl = extractBaseUrl(jsCode) ?? '';
    return {
      'name': '',
      'baseUrl': baseUrl,
      'apiUrl': '',
      'lang': 'en',
      'id': 0,
    };
  }

  /// ── FETCH SOURCE MANGA CATALOG VIA MANGAYOMI RUNTIME ─────────
  Future<List<Map<String, dynamic>>> fetchSourceMangaLocal(
    String sourceName, {
    bool isLatest = false,
    int page = 1,
    String? searchQuery,
    String? selectedSort,
    String? selectedStatus,
    String? selectedType,
  }) async {
    final jsCode = getExtensionCode(sourceName);
    if (jsCode == null || jsCode.isEmpty) {
      return [];
    }

    final service = JsExtensionService(
      sourceMeta: extractSourceMetadata(jsCode),
      sourceCode: jsCode,
    );

    try {
      final hasFilters = (selectedSort != null && selectedSort != 'Popularity') ||
          (selectedStatus != null && selectedStatus != 'All') ||
          (selectedType != null && selectedType != 'All');

      Map<String, dynamic> result;
      if (searchQuery != null && searchQuery.isNotEmpty) {
        result = await service.search(searchQuery, page);
      } else if (hasFilters) {
        // Build a structured filter list so JS extensions can use the correct filtered URL
        // instead of doing an empty search which returns nothing.
        final filterList = <Map<String, dynamic>>[];
        if (selectedSort != null) filterList.add({'name': 'SortBy', 'value': selectedSort});
        if (selectedStatus != null) filterList.add({'name': 'Status', 'value': selectedStatus});
        if (selectedType != null) filterList.add({'name': 'Type', 'value': selectedType});
        result = await service.search('', page, filterList);
      } else if (isLatest) {
        result = await service.getLatestUpdates(page);
      } else {
        result = await service.getPopular(page);
      }

      if (result.containsKey('list') && result['list'] is List) {
        final list = result['list'] as List<dynamic>;
        final parsed = list.map((item) => Map<String, dynamic>.from(item as Map)).toList();
        if (parsed.isNotEmpty) return parsed;
      }
    } catch (e) {
      await LoggerService.instance.logWarning('Local scraping failed for $sourceName: $e', 'QuickJS');
    } finally {
      service.dispose();
    }
    return [];
  }

  /// ── SCRAPE MANGA DETAILS & CHAPTER LIST VIA MANGAYOMI RUNTIME ──
  Future<Map<String, dynamic>> fetchMangaDetailsLocal(String sourceName, String mangaUrl) async {
    final jsCode = getExtensionCode(sourceName);
    if (jsCode == null || jsCode.isEmpty || mangaUrl.isEmpty) {
      return {};
    }

    final service = JsExtensionService(
      sourceMeta: extractSourceMetadata(jsCode),
      sourceCode: jsCode,
    );

    try {
      final result = await service.getDetail(mangaUrl);
      return result;
    } catch (e) {
      await LoggerService.instance.logWarning('Local getDetail failed for $sourceName ($mangaUrl): $e', 'QuickJS');
    } finally {
      service.dispose();
    }
    return {};
  }

  /// ── SCRAPE CHAPTER PAGES VIA MANGAYOMI RUNTIME ────────────────
  Future<List<String>> fetchChapterPagesLocal(String sourceName, String chapterUrl) async {
    final jsCode = getExtensionCode(sourceName);
    if (jsCode == null || jsCode.isEmpty) {
      return [];
    }

    final service = JsExtensionService(
      sourceMeta: extractSourceMetadata(jsCode),
      sourceCode: jsCode,
    );

    try {
      final pages = await service.getPageList(chapterUrl);
      if (pages.isNotEmpty) return pages;
    } catch (e) {
      await LoggerService.instance.logWarning('Local chapter page scraping failed for $sourceName: $e', 'QuickJS');
    } finally {
      service.dispose();
    }
    return [];
  }

  /// ── RETRIEVE SOURCE DYNAMIC FILTERS ───────────────────────────
  Future<List<dynamic>> fetchSourceFiltersLocal(String sourceName) async {
    final jsCode = getExtensionCode(sourceName);
    if (jsCode == null || jsCode.isEmpty) return [];

    final service = JsExtensionService(
      sourceMeta: extractSourceMetadata(jsCode),
      sourceCode: jsCode,
    );

    try {
      return await service.extensionCallAsync<List<dynamic>>('getFilterList()');
    } catch (_) {
      return [];
    } finally {
      service.dispose();
    }
  }

  void dispose() {}
}
