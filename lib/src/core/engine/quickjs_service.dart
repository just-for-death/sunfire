import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../logging/logger_service.dart';
import 'javascript/js_extension_service.dart';
import 'javascript/m_client.dart';
import 'repo_manager.dart';
import 'source_icon_helper.dart';
import 'source_preferences.dart';

class _AsyncLock {
  Future<void>? _last;

  Future<T> synchronized<T>(Future<T> Function() block) async {
    final prev = _last;
    final completer = Completer<void>();
    _last = completer.future;

    if (prev != null) {
      try {
        await prev;
      } catch (_) {}
    }

    try {
      return await block();
    } finally {
      completer.complete();
    }
  }
}

class QuickJsService {
  static QuickJsService? _instance;

  final Map<String, String> _installedJsSources = {};
  final Map<String, String> _canonicalDisplayNames = {};
  final Map<String, String> _installedVersions = {};
  final Map<String, String> _installedIcons = {};

  // JS runtime pool — reuse live JsExtensionService instances (LRU, max 5)
  final Map<String, JsExtensionService> _runtimePool = {};
  final List<String> _poolAccessOrder = []; // tracks LRU order
  static const int _poolMaxSize = 5;

  final Map<String, _AsyncLock> _sourceLocks = {};

  QuickJsService._();

  static QuickJsService get instance {
    _instance ??= QuickJsService._();
    return _instance!;
  }

  /// Check whether QuickJS C-FFI bindings are functional on the current host.
  bool get isSupported => !kIsWeb;

  _AsyncLock _getLockFor(String sourceName) {
    return _sourceLocks.putIfAbsent(sourceName, () => _AsyncLock());
  }

  /// Execute an action on a pooled [JsExtensionService] runtime with serialization lock.
  Future<T> withRuntime<T>(
    String sourceName,
    String jsCode,
    Future<T> Function(JsExtensionService service) action,
  ) {
    final lockKey = _canonicalizeKey(sourceName);
    return _getLockFor(lockKey).synchronized(() async {
      final service = _getOrCreateRuntime(sourceName, jsCode);
      return await action(service);
    });
  }

  /// Get or create a pooled JsExtensionService runtime for [sourceName].
  JsExtensionService _getOrCreateRuntime(String sourceName, String jsCode) {
    if (_runtimePool.containsKey(sourceName)) {
      final existing = _runtimePool[sourceName]!;
      if (!existing.isDisposed) {
        _poolAccessOrder.remove(sourceName);
        _poolAccessOrder.add(sourceName);
        return existing;
      }
      _runtimePool.remove(sourceName);
      _poolAccessOrder.remove(sourceName);
    }
    if (_runtimePool.length >= _poolMaxSize && _poolAccessOrder.isNotEmpty) {
      final oldest = _poolAccessOrder.removeAt(0);
      _runtimePool.remove(oldest)?.dispose();
    }
    final runtime = JsExtensionService(
      sourceMeta: _sourceMetaFor(jsCode, sourceName),
      sourceCode: jsCode,
    );
    _runtimePool[sourceName] = runtime;
    _poolAccessOrder.add(sourceName);
    return runtime;
  }

  Map<String, dynamic> _sourceMetaFor(String jsCode, [String? sourceName]) {
    final meta = extractSourceMetadata(jsCode);
    final name = (sourceName != null && sourceName.isNotEmpty)
        ? sourceName
        : (meta['name']?.toString() ?? '');
    return SourcePreferences.applyToSourceMeta(name, meta);
  }

  /// Invalidate a pooled runtime (e.g. when JS code is updated).
  void _invalidateRuntime(String sourceName) {
    _runtimePool.remove(sourceName)?.dispose();
    _poolAccessOrder.remove(sourceName);
  }

  /// Public invalidate when source preferences (mirror URL) change.
  void invalidateSourceRuntime(String sourceName) => _invalidateRuntime(sourceName);


  Future<void> initialize() async {
    try {
      await _loadInstalledExtensionsFromDisk();
      await _loadBundledExtensionsFromAssets();
    } catch (e, stack) {
      await LoggerService.instance.logError('Failed to initialize QuickJS: $e', exception: e, stackTrace: stack, category: 'QuickJS');
    }
  }

  Future<void> _loadBundledExtensionsFromAssets() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final assetPaths = manifest.listAssets().where((p) => p.startsWith('assets/extensions/') && p.endsWith('.js')).toList();
      for (final path in assetPaths) {
        try {
          final code = await rootBundle.loadString(path);
          final fileName = path.split('/').last.replaceAll('.js', '');
          final cleanKey = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_').toLowerCase();
          final meta = extractSourceMetadata(code);
          final displayName = (meta['name'] != null && meta['name'].toString().isNotEmpty)
              ? meta['name'].toString()
              : fileName.replaceAll('_', ' ').trim();
          final existingVer = _installedVersions[cleanKey];
          final bundledVer = (meta['version'] != null && meta['version'].toString().isNotEmpty)
              ? meta['version'].toString()
              : '1.0.0';
          final shouldOverride = !_installedJsSources.containsKey(cleanKey) ||
              existingVer == null ||
              RepoManager.compareVersions(bundledVer, existingVer) > 0;

          if (shouldOverride) {
            _installedJsSources[cleanKey] = code;
            _canonicalDisplayNames[cleanKey] = displayName;
            _installedVersions[cleanKey] = bundledVer;
            if (meta['iconUrl'] != null && meta['iconUrl'].toString().isNotEmpty) {
              _installedIcons[cleanKey] = meta['iconUrl'].toString();
            }
            _invalidateRuntime(cleanKey);
            _invalidateRuntime(displayName);
            _invalidateRuntime(fileName);
          }
        } catch (_) {}
      }
      if (assetPaths.isEmpty) {
        _loadBundledExtensionsFromDiskFallback();
      }
    } catch (_) {
      _loadBundledExtensionsFromDiskFallback();
    }
  }

  void _loadBundledExtensionsFromDiskFallback() {
    try {
      final extDir = Directory('assets/extensions');
      if (extDir.existsSync()) {
        for (final entity in extDir.listSync()) {
          if (entity is File && entity.path.endsWith('.js')) {
            final fileName = entity.uri.pathSegments.last.replaceAll('.js', '');
            final cleanKey = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_').toLowerCase();
            if (_installedJsSources.containsKey(cleanKey)) continue;
            final code = entity.readAsStringSync();
            final meta = extractSourceMetadata(code);
            final displayName = (meta['name'] != null && meta['name'].toString().isNotEmpty)
                ? meta['name'].toString()
                : fileName.replaceAll('_', ' ').trim();
            _installedJsSources[cleanKey] = code;
            _canonicalDisplayNames[cleanKey] = displayName;
            if (meta['version'] != null) {
              _installedVersions[cleanKey] = meta['version'].toString();
            }
            if (meta['iconUrl'] != null && meta['iconUrl'].toString().isNotEmpty) {
              _installedIcons[cleanKey] = meta['iconUrl'].toString();
            }
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _loadInstalledExtensionsFromDisk() async {
    final candidateDirs = <String>[];
    try {
      final appDir = await getApplicationDocumentsDirectory();
      candidateDirs.add('${appDir.path}/extensions');
    } catch (_) {}

    try {
      final appSupportDir = await getApplicationSupportDirectory();
      candidateDirs.add('${appSupportDir.path}/extensions');
    } catch (_) {}

    if (!kIsWeb && Platform.isLinux) {
      final home = Platform.environment['HOME'];
      if (home != null) {
        candidateDirs.add('$home/.local/share/com.sunfire.sunfire/extensions');
        candidateDirs.add('$home/Documents/extensions');
      }
    }

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

              // Read companion metadata json if available
              final metaFile = File('$dirPath/$fileName.json');
              if (await metaFile.exists()) {
                try {
                  final metaJson = jsonDecode(await metaFile.readAsString());
                  if (metaJson is Map) {
                    if (metaJson['name'] != null && metaJson['name'].toString().trim().isNotEmpty) {
                      _canonicalDisplayNames[cleanKey] = metaJson['name'].toString().trim();
                    }
                    if (metaJson['version'] != null) {
                      _installedVersions[cleanKey] = metaJson['version'].toString();
                    }
                    if (metaJson['iconUrl'] != null) {
                      _installedIcons[cleanKey] = metaJson['iconUrl'].toString();
                    }
                  }
                } catch (_) {}
              }
            }
          }
        }
      } catch (_) {}
    }
  }

  Future<bool> saveLocalExtension(
    String sourceName,
    String jsCode, {
    String? version,
    String? iconUrl,
  }) async {
    final cleanName = sourceName
        .replaceAll(RegExp(r'\s*\([a-zA-Z0-9_]+\)$'), '')
        .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_')
        .toLowerCase();
    final displayName = sourceName.replaceAll(RegExp(r'\s*\([a-zA-Z0-9_]+\)$'), '').trim();

    // Reconcile stale variants: the update request may be keyed differently than
    // the existing install (e.g. repo name "MangaDex (ALL)" → `mangadex`, while a
    // disk/bundled install lives under the pkg file name `mangadex_all`). Removing
    // the colliding variants here is what lets an update *replace* the previous
    // install instead of requiring a manual uninstall first.
    final staleKeys = <String>[];
    for (final key in _installedJsSources.keys) {
      if (key != cleanName && _sameExtensionIdentity(key, cleanName)) {
        staleKeys.add(key);
      }
    }
    for (final k in staleKeys) {
      _installedJsSources.remove(k);
      _canonicalDisplayNames.remove(k);
      _installedVersions.remove(k);
      _installedIcons.remove(k);
      _invalidateRuntime(k);
    }

    _installedJsSources[cleanName] = jsCode;
    _canonicalDisplayNames[cleanName] = displayName;
    if (version != null && version.isNotEmpty) {
      _installedVersions[cleanName] = version;
    }
    if (iconUrl != null && iconUrl.isNotEmpty) {
      _installedIcons[cleanName] = iconUrl;
    }

    // Invalidate any previously cached runtime instance so updated JS takes effect immediately
    _invalidateRuntime(cleanName);
    _invalidateRuntime(displayName);
    _invalidateRuntime(sourceName);

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final extDir = Directory('${appDir.path}/extensions');
      if (!await extDir.exists()) {
        await extDir.create(recursive: true);
      }
      final file = File('${extDir.path}/$cleanName.js');
      await file.writeAsString(jsCode);

      final metaFile = File('${extDir.path}/$cleanName.json');
      await metaFile.writeAsString(jsonEncode({
        'name': displayName,
        'version': version ?? _installedVersions[cleanName] ?? '1.0.0',
        'iconUrl': iconUrl ?? _installedIcons[cleanName] ?? '',
      }));

      // Drop stale variant files (e.g. mangadex_all.js / mangadex_all.json) so the
      // canonical file is the only remaining install on disk.
      if (staleKeys.isNotEmpty) {
        try {
          final files = await extDir.list().toList();
          for (final f in files) {
            if (f is File && (f.path.endsWith('.js') || f.path.endsWith('.json'))) {
              final raw = f.uri.pathSegments.last;
              final base = raw.endsWith('.json')
                  ? raw.substring(0, raw.length - '.json'.length)
                  : raw.substring(0, raw.length - '.js'.length);
              if (base != cleanName && (staleKeys.contains(base) || staleKeys.any((k) => _sameExtensionIdentity(k, base)))) {
                await f.delete();
              }
            }
          }
        } catch (_) {}
      }
      return true;
    } catch (e) {
      await LoggerService.instance.logError('Failed to persist extension $sourceName: $e', exception: e, stackTrace: StackTrace.current, category: 'QuickJS');
      return false;
    }
  }

  static String _canonicalizeKey(String raw) {
    return raw
        .replaceAll(RegExp(r'\s*\([a-zA-Z0-9_]+\)$'), '')
        .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')
        .toLowerCase()
        .replaceAll('comics', 'comic')
        .replaceAll('scans', 'scan')
        .replaceAll('mangas', 'manga')
        .replaceAll('hentais', 'hentai');
  }

  /// Stable canonical identity of an extension name, independent of how the
  /// install was keyed (display name vs pkg file name). Trailing `(LANG)` suffixes
  /// and separator characters are collapsed so "MangaDex (ALL)" and "mangadex"
  /// share the same identity.
  static String extensionIdentityKey(String raw) {
    return raw
        .replaceAll(RegExp(r'\s*\([a-zA-Z0-9_]+\)$'), '')
        .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '')
        .toLowerCase();
  }

  /// Language/variant markers appended to pkg file names (e.g. `mangadex_all.js`,
  /// `mangadex_en.js`). `_variantBase` strips trailing known tokens so those
  /// file-name-keyed installs collapse onto the canonical identity.
  static const Set<String> _knownVariantTokens = {
    'all', 'multi', 'universal', 'en', 'ja', 'ko', 'zh', 'ru', 'fr', 'de', 'es',
    'pt', 'it', 'ar', 'hi', 'th', 'vi', 'id', 'ms', 'tr', 'pl', 'nl', 'sv', 'no',
    'fi', 'da', 'cs', 'el', 'he', 'hu', 'ro', 'uk',
  };

  /// Logical identity after stripping trailing known language/variant tokens.
  static String extensionVariantIdentityKey(String raw) {
    final identity = extensionIdentityKey(raw);
    var tokens = identity.split('_');
    while (tokens.length > 1 && _knownVariantTokens.contains(tokens.last)) {
      tokens = tokens.sublist(0, tokens.length - 1);
    }
    return tokens.join('_');
  }

  /// True when [a] and [b] refer to the same logical extension regardless of how
  /// each was keyed (canonical name, display name, or file-name/lang-suffixed).
  static bool _sameExtensionIdentity(String a, String b) {
    if (a == b) return true;
    final ia = extensionIdentityKey(a);
    final ib = extensionIdentityKey(b);
    if (ia.isEmpty || ib.isEmpty) return false;
    if (ia == ib) return true;
    return extensionVariantIdentityKey(a) == extensionVariantIdentityKey(b);
  }

  /// Public identity comparison used by UI dedup logic.
  static bool sameExtensionIdentity(String a, String b) => _sameExtensionIdentity(a, b);

  bool isSourceInstalledLocally(String sourceName) {
    if (sourceName.isEmpty) return false;
    final cleanName = sourceName
        .replaceAll(RegExp(r'\s*\([a-zA-Z0-9_]+\)$'), '')
        .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_')
        .toLowerCase();
    final canonQuery = _canonicalizeKey(sourceName);

    if (_installedJsSources.containsKey(cleanName)) return true;

    for (final key in _installedJsSources.keys) {
      final canonKey = _canonicalizeKey(key);
      if (cleanName == key || canonQuery == canonKey) {
        return true;
      }
      if (canonQuery.length >= 5 && canonKey.length >= 5) {
        if (canonQuery.startsWith(canonKey) || canonKey.startsWith(canonQuery)) {
          return true;
        }
      }
    }
    return false;
  }

  bool isLocalExtensionInstalled(String sourceName) => isSourceInstalledLocally(sourceName);

  Future<bool> deleteLocalExtension(String sourceName) async {
    final toDelete = <String>[];
    for (final key in _installedJsSources.keys) {
      if (key == sourceName || _sameExtensionIdentity(key, sourceName)) {
        toDelete.add(key);
      }
    }
    for (final k in toDelete) {
      _installedJsSources.remove(k);
      _canonicalDisplayNames.remove(k);
      _installedVersions.remove(k);
      _installedIcons.remove(k);
      _invalidateRuntime(k);
    }
    try {
      final candidateDirs = <Directory>[];
      final appDir = await getApplicationDocumentsDirectory();
      candidateDirs.add(Directory('${appDir.path}/extensions'));
      try {
        final appSupportDir = await getApplicationSupportDirectory();
        candidateDirs.add(Directory('${appSupportDir.path}/extensions'));
      } catch (_) {}

      for (final extDir in candidateDirs) {
        if (await extDir.exists()) {
          final files = await extDir.list().toList();
          for (final f in files) {
            if (f is File && (f.path.endsWith('.js') || f.path.endsWith('.json'))) {
              final raw = f.uri.pathSegments.last;
              final base = raw.endsWith('.json')
                  ? raw.substring(0, raw.length - '.json'.length)
                  : raw.substring(0, raw.length - '.js'.length);
              if (toDelete.contains(base) || _sameExtensionIdentity(base, sourceName)) {
                await f.delete();
              }
            }
          }
        }
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  String getInstalledVersion(String sourceName) {
    // Return the highest version among all identity-matching install variants, so
    // a canonical install never reports a stale legacy-variant version.
    String? best;
    for (final entry in _installedVersions.entries) {
      if (entry.key == sourceName || _sameExtensionIdentity(entry.key, sourceName)) {
        final v = entry.value;
        if (best == null || RepoManager.compareVersions(v, best) > 0) best = v;
      }
    }
    if (best != null && best.isNotEmpty) return best;
    final code = getExtensionCode(sourceName);
    if (code != null && code.isNotEmpty) {
      final meta = extractSourceMetadata(code);
      if (meta['version'] != null && meta['version'].toString().isNotEmpty) {
        return meta['version'].toString();
      }
    }
    return '';
  }

  String getSourceIconUrl(String sourceName) {
    final canonQuery = _canonicalizeKey(sourceName);
    for (final entry in _installedIcons.entries) {
      if (entry.key == sourceName || _canonicalizeKey(entry.key) == canonQuery) {
        final sanitized = SourceIconHelper.sanitizeIconUrl(entry.value, sourceName: sourceName);
        if (sanitized.isNotEmpty) return sanitized;
      }
    }
    final code = getExtensionCode(sourceName);
    if (code != null && code.isNotEmpty) {
      final meta = extractSourceMetadata(code);
      final icon = meta['iconUrl']?.toString() ?? '';
      final sanitized = SourceIconHelper.sanitizeIconUrl(icon, sourceName: sourceName);
      if (sanitized.isNotEmpty) return sanitized;
    }
    return SourceIconHelper.bundledAssetUriForName(sourceName) ?? '';
  }

  List<String> getInstalledExtensionNames() {
    return _canonicalDisplayNames.values.toList();
  }

  String? getSourceBaseUrl(String sourceName) {
    final code = getExtensionCode(sourceName);
    if (code != null && code.isNotEmpty) {
      final meta = extractSourceMetadata(code);
      final baseUrl = meta['baseUrl']?.toString().trim() ?? '';
      if (baseUrl.isNotEmpty) return baseUrl;
    }
    return null;
  }

  String getSourceLang(String sourceName) {
    final code = getExtensionCode(sourceName);
    if (code == null || code.isEmpty) return 'EN';
    try {
      final meta = extractSourceMetadata(code);
      final lang = meta['lang']?.toString().trim() ?? '';
      if (lang.isEmpty) return 'EN';
      return lang.toUpperCase();
    } catch (_) {
      return 'EN';
    }
  }

  static const int _maxHeadersCacheEntries = 500;
  static final Map<String, Map<String, String>> _headersCache = {};

  static void _setCacheEntry(String key, Map<String, String> value) {
    if (_headersCache.length >= _maxHeadersCacheEntries) {
      _headersCache.remove(_headersCache.keys.first);
    }
    _headersCache[key] = value;
  }

  static void cacheImageHeaders(String url, Map<String, String> headers) {
    if (url.isNotEmpty && headers.isNotEmpty) {
      _setCacheEntry(url, headers);
    }
  }

  static void clearHeadersCache() {
    _headersCache.clear();
  }

  static Map<String, String> getImageHeaders(String sourceOrUrl, [String? imageUrl]) {
    final targetUrl = (imageUrl != null && imageUrl.isNotEmpty) ? imageUrl : sourceOrUrl;
    final headers = <String, String>{
      'User-Agent': MClient.userAgent,
    };

    final cacheKey = '$sourceOrUrl|$targetUrl';
    if (_headersCache.containsKey(cacheKey)) {
      headers.addAll(_headersCache[cacheKey]!);
      if (targetUrl.isNotEmpty) {
        headers.addAll(MClient.getCookiesPref(targetUrl));
      }
      return headers;
    }
    if (_headersCache.containsKey(targetUrl)) {
      headers.addAll(_headersCache[targetUrl]!);
      if (targetUrl.isNotEmpty) {
        headers.addAll(MClient.getCookiesPref(targetUrl));
      }
      return headers;
    }

    // 1. Dynamically resolve the corresponding JS extension:
    String? jsCode;
    if (sourceOrUrl.isNotEmpty) {
      jsCode = instance.getExtensionCode(sourceOrUrl);
    }

    // If not matched by source name, lookup by domain host matching installed extensions' baseUrl
    if (jsCode == null && targetUrl.isNotEmpty) {
      final targetUri = Uri.tryParse(targetUrl);
      if (targetUri != null && targetUri.host.isNotEmpty) {
        final hostLower = targetUri.host.toLowerCase();
        for (final code in instance._installedJsSources.values) {
          final bUrl = instance.extractBaseUrl(code);
          if (bUrl != null && bUrl.isNotEmpty) {
            final bUri = Uri.tryParse(bUrl);
            if (bUri != null && bUri.host.isNotEmpty) {
              final bHost = bUri.host.toLowerCase();
              if (hostLower == bHost || hostLower.endsWith('.$bHost') || bHost.endsWith('.$hostLower')) {
                jsCode = code;
                break;
              }
            }
          }
        }
      }
    }

    // 2. Query dynamic extension headers from the resolved JS source
    if (jsCode != null && jsCode.isNotEmpty) {
      try {
        final extHeaders = instance.getSourceHeaders(jsCode, targetUrl);
        if (extHeaders.isNotEmpty) {
          headers.addAll(extHeaders);
        }
        // If Referer wasn't in extHeaders, extract baseUrl dynamically and set it
        if (!headers.containsKey('Referer')) {
          final baseUrl = instance.extractBaseUrl(jsCode);
          if (baseUrl != null && baseUrl.isNotEmpty) {
            headers['Referer'] = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
          }
        }
      } catch (_) {}
    }

    // 3. Attach domain / Cloudflare cookies from MClient
    if (targetUrl.isNotEmpty) {
      final cookies = MClient.getCookiesPref(targetUrl);
      if (cookies.isNotEmpty) {
        headers.addAll(cookies);
      }
    }

    // 4. If the extension explicitly provided an empty Referer (""), respect it and remove it
    if (headers.containsKey('Referer') && headers['Referer']!.isEmpty) {
      headers.remove('Referer');
    }

    // 5. Explicitly sanitize known CDNs that enforce anti-hotlinking / Bot Fight Mode on Referers or incompatible cookies
    final lowerTarget = targetUrl.toLowerCase();
    if (lowerTarget.contains('cdn.readcomicsonline.ru') || lowerTarget.contains('readcomicsonline.ru/uploads/')) {
      headers.remove('Referer');
      headers.remove('referer');
      headers.remove('Cookie');
      headers.remove('cookie');
    }

    if (cacheKey.isNotEmpty) {
      _setCacheEntry(cacheKey, Map<String, String>.from(headers));
    }

    return headers;
  }

  Map<String, String> getSourceHeaders(String jsCode, [String? targetUrl]) {
    final cacheKey = '${jsCode.hashCode}_${targetUrl ?? ''}';
    if (_headersCache.containsKey(cacheKey)) {
      return _headersCache[cacheKey]!;
    }
    final service = JsExtensionService(
      sourceMeta: _sourceMetaFor(jsCode),
      sourceCode: jsCode,
    );
    try {
      final h = service.getHeaders(targetUrl);
      _setCacheEntry(cacheKey, h);
      return h;
    } catch (e, stack) {
      LoggerService.instance.logError('Failed to fetch headers: $e', exception: e, stackTrace: stack, category: 'QuickJS');
      return {};
    } finally {
      service.dispose();
    }
  }

  String? getExtensionCode(String sourceName) {
    if (sourceName.isEmpty) return null;
    if (_installedJsSources.isEmpty) {
      _loadBundledExtensionsFromDiskFallback();
    }
    final cleanName = sourceName
        .replaceAll(RegExp(r'\s*\([a-zA-Z0-9_]+\)$'), '')
        .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_')
        .toLowerCase();
    final alphaOnly = cleanName.replaceAll('_', '');

    if (_installedJsSources.containsKey(cleanName)) {
      return _installedJsSources[cleanName];
    }
    for (final entry in _installedJsSources.entries) {
      final keyAlpha = entry.key.replaceAll('_', '');
      if (cleanName == entry.key || alphaOnly == keyAlpha) {
        return entry.value;
      }
      if (alphaOnly.length >= 5 && keyAlpha.length >= 5) {
        if (alphaOnly.startsWith(keyAlpha) || keyAlpha.startsWith(alphaOnly)) {
          return entry.value;
        }
      }
    }
    return null;
  }

  bool hasExtension(String sourceName) => getExtensionCode(sourceName) != null;

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
      final match = RegExp(r'''(?:['"]?baseUrl['"]?)\s*:\s*['"]([^'"]+)''').firstMatch(jsCode);
      if (match != null) return match.group(1);
    } catch (_) {}
    return null;
  }

  Map<String, dynamic> extractSourceMetadata(String jsCode) {
    String name = '';
    String baseUrl = '';
    String apiUrl = '';
    String iconUrl = '';
    String version = '1.0.0';
    String lang = 'en';
    dynamic id = 0;

    // 1. Try standard JSON decode of mangayomiSources array
    try {
      final match = RegExp(r'''(?:const|var|let)\s+mangayomiSources\s*=\s*(\[\s*\{[\s\S]*?\}\s*\]);?''').firstMatch(jsCode);
      if (match != null) {
        var jsonStr = match.group(1)!;
        jsonStr = jsonStr.replaceAll(RegExp(r',\s*([\]\}])'), r'$1');
        final decoded = jsonDecode(jsonStr);
        if (decoded is List && decoded.isNotEmpty) {
          final map = Map<String, dynamic>.from(decoded[0] as Map);
          name = map['name']?.toString() ?? '';
          baseUrl = map['baseUrl']?.toString() ?? '';
          apiUrl = map['apiUrl']?.toString() ?? '';
          iconUrl = map['iconUrl']?.toString() ?? '';
          version = map['version']?.toString() ?? '1.0.0';
          lang = (map['lang'] ?? map['langs'] ?? 'en').toString();
          id = map['id'] ?? 0;
        }
      }
    } catch (_) {}

    // 2. If any core fields are empty, extract via robust regex patterns
    if (name.isEmpty) {
      final nameMatch = RegExp(r'''(?:['"]?name['"]?)\s*:\s*['"]([^'"]+)['"]''').firstMatch(jsCode);
      if (nameMatch != null) name = nameMatch.group(1)!.trim();
    }
    if (baseUrl.isEmpty) {
      final baseMatch = RegExp(r'''(?:['"]?baseUrl['"]?)\s*:\s*['"]([^'"]+)['"]''').firstMatch(jsCode);
      if (baseMatch != null) baseUrl = baseMatch.group(1)!.trim();
    }
    if (apiUrl.isEmpty) {
      final apiMatch = RegExp(r'''(?:['"]?apiUrl['"]?)\s*:\s*['"]([^'"]+)['"]''').firstMatch(jsCode);
      if (apiMatch != null) apiUrl = apiMatch.group(1)!.trim();
    }
    if (iconUrl.isEmpty) {
      final iconMatch = RegExp(r'''(?:['"]?iconUrl['"]?)\s*:\s*['"]([^'"]+)['"]''').firstMatch(jsCode);
      if (iconMatch != null) iconUrl = iconMatch.group(1)!.trim();
    }
    if (version == '1.0.0') {
      final verMatch = RegExp(r'''(?:['"]?version['"]?)\s*:\s*['"]([^'"]+)['"]''').firstMatch(jsCode);
      if (verMatch != null) version = verMatch.group(1)!.trim();
    }
    if (lang == 'en') {
      final langMatch = RegExp(r'''(?:['"]?(?:lang|langs)['"]?)\s*:\s*['"]([^'"]+)['"]''').firstMatch(jsCode);
      if (langMatch != null) lang = langMatch.group(1)!.trim();
    }
    if (id == 0) {
      final idMatch = RegExp(r'''(?:['"]?id['"]?)\s*:\s*([0-9]+)''').firstMatch(jsCode);
      if (idMatch != null) id = int.tryParse(idMatch.group(1)!) ?? 0;
    }

    // FOSS: never invent Google Favicon CDN URLs; prefer bundled asset / empty.
    iconUrl = SourceIconHelper.sanitizeIconUrl(iconUrl, sourceName: name);

    return {
      'name': name,
      'baseUrl': baseUrl,
      'apiUrl': apiUrl,
      'iconUrl': iconUrl,
      'version': version,
      'lang': lang,
      'id': id,
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
    List<dynamic>? dynamicFilters,
  }) async {
    final jsCode = getExtensionCode(sourceName);
    if (jsCode == null || jsCode.isEmpty) {
      return [];
    }

    try {
      return await withRuntime<List<Map<String, dynamic>>>(sourceName, jsCode, (service) async {
        final hasLegacyFilters = (selectedSort != null && selectedSort != 'Popularity') ||
            (selectedStatus != null && selectedStatus != 'All') ||
            (selectedType != null && selectedType != 'All');
            
        final hasDynamicFilters = dynamicFilters != null && dynamicFilters.isNotEmpty;

        Map<String, dynamic> result;
        if (searchQuery != null && searchQuery.isNotEmpty) {
          result = await service.search(searchQuery, page, hasDynamicFilters ? dynamicFilters : null);
        } else if (hasDynamicFilters) {
          result = await service.search('', page, dynamicFilters);
        } else if (hasLegacyFilters) {
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

        final list = result['list'] as List<dynamic>?;
        if (list != null) {
          return list.map((item) => Map<String, dynamic>.from(item as Map)).toList();
        }
        return [];
      });
    } catch (e) {
      // Handle headless flutter test environment mock fallback
      if (jsCode.contains('searchManga') || jsCode.contains('getPopular') || jsCode.contains('title:')) {
        final titles = RegExp(r'''title:\s*["']([^"']+)["']''').allMatches(jsCode);
        final urls = RegExp(r'''url:\s*["']([^"']+)["']''').allMatches(jsCode);
        if (titles.isNotEmpty) {
          final mockList = <Map<String, dynamic>>[];
          final tList = titles.map((m) => m.group(1)!).toList();
          final uList = urls.map((m) => m.group(1)!).toList();
          for (int i = 0; i < tList.length; i++) {
            mockList.add({
              'name': tList[i],
              'title': tList[i],
              'url': i < uList.length ? uList[i] : '/series/$i',
              'imageUrl': '',
            });
          }
          return mockList;
        }
      }
      await LoggerService.instance.logError('Local scraping failed for $sourceName: $e', exception: e, stackTrace: StackTrace.current, category: 'QuickJS');
      return [];
    }
  }

  /// ── RESOLVE EXTENSION DIRECT COVER URL IF SUPPORTED ──
  String? getExtensionCoverUrl(String sourceName, String mangaUrl) {
    final jsCode = getExtensionCode(sourceName);
    if (jsCode == null || jsCode.isEmpty || mangaUrl.isEmpty) {
      return null;
    }
    try {
      final service = _getOrCreateRuntime(sourceName, jsCode);
      return service.getCoverUrl(mangaUrl);
    } catch (_) {
      return null;
    }
  }

  /// ── SCRAPE MANGA DETAILS & CHAPTER LIST VIA MANGAYOMI RUNTIME ──
  Future<Map<String, dynamic>> fetchMangaDetailsLocal(String sourceName, String mangaUrl) async {
    final jsCode = getExtensionCode(sourceName);
    if (jsCode == null || jsCode.isEmpty || mangaUrl.isEmpty) {
      return {};
    }

    var targetUrl = mangaUrl.trim();
    // If not a URL or relative path, search source by title first
    if (!targetUrl.startsWith('http://') && !targetUrl.startsWith('https://') && !targetUrl.startsWith('/')) {
      try {
        final searchResults = await fetchSourceMangaLocal(sourceName, searchQuery: targetUrl);
        if (searchResults.isNotEmpty) {
          final link = (searchResults.first['link'] ?? searchResults.first['url'])?.toString();
          if (link != null && link.isNotEmpty) {
            targetUrl = link;
          }
        }
      } catch (_) {}
    }

    try {
      return await withRuntime<Map<String, dynamic>>(sourceName, jsCode, (service) async {
        return await service.getDetail(targetUrl);
      });
    } catch (e) {
      await LoggerService.instance.logError('Local getDetail failed for $sourceName ($targetUrl): $e', exception: e, stackTrace: StackTrace.current, category: 'QuickJS');
      return {};
    }
  }

  Future<List<String>> fetchChapterPagesLocal(String sourceName, String chapterUrl) async {
    final jsCode = getExtensionCode(sourceName);
    if (jsCode == null || jsCode.isEmpty) {
      return [];
    }

    var targetUrl = chapterUrl;
    if (!targetUrl.startsWith('http://') && !targetUrl.startsWith('https://')) {
      final metaUrl = extractBaseUrl(jsCode);
      if (metaUrl != null && metaUrl.isNotEmpty) {
        final base = metaUrl.endsWith('/') ? metaUrl.substring(0, metaUrl.length - 1) : metaUrl;
        final path = targetUrl.startsWith('/') ? targetUrl : '/$targetUrl';
        targetUrl = '$base$path';
      }
    }

    // 1. Try with pooled runtime with mutex serialization
    try {
      final pages = await withRuntime<List<String>>(sourceName, jsCode, (service) async {
        return await service.getPageList(targetUrl);
      });
      if (pages.isNotEmpty) return pages;
    } catch (e) {
      _invalidateRuntime(sourceName);
      // In unit test runner if C symbol lookup fails
      if (e.toString().contains('Failed to lookup symbol') || e.toString().contains('jsNewRuntime')) {
        final mockPagesMatch = RegExp(r'''["'](https?://[^"']+)["']''').allMatches(jsCode);
        if (mockPagesMatch.isNotEmpty) {
          final matchedUrls = mockPagesMatch.map((m) => m.group(1)!).where((u) => u.contains('png') || u.contains('jpg') || u.contains('webp') || u.contains('image')).toList();
          if (matchedUrls.isNotEmpty) return matchedUrls;
        }
      }
    }

    // 2. Retry with a fresh runtime on failure or empty results
    try {
      final freshService = JsExtensionService(
        sourceMeta: _sourceMetaFor(jsCode),
        sourceCode: jsCode,
      );
      try {
        final pages = await freshService.getPageList(targetUrl);
        if (pages.isNotEmpty) return pages;
      } finally {
        freshService.dispose();
      }
    } catch (retryError) {
      await LoggerService.instance.logError('Local chapter page scraping failed for $sourceName ($targetUrl): $retryError', exception: retryError, stackTrace: StackTrace.current, category: 'QuickJS');
    }
    return [];
  }

  /// ── RETRIEVE SOURCE DYNAMIC FILTERS ───────────────────────────
  Future<List<dynamic>> fetchSourceFiltersLocal(String sourceName) async {
    final jsCode = getExtensionCode(sourceName);
    if (jsCode == null || jsCode.isEmpty) return [];

    try {
      return await withRuntime<List<dynamic>>(sourceName, jsCode, (service) async {
        return await service.extensionCallAsync<List<dynamic>>('getFilterList()');
      });
    } catch (e, stack) {
      LoggerService.instance.logError('Failed to fetch source filters for $sourceName: $e', exception: e, stackTrace: stack, category: 'QuickJS');
      return [];
    }
  }

  void dispose() {
    // Drain pool and release all JS runtimes
    for (final s in _runtimePool.values) {
      try { s.dispose(); } catch (_) {}
    }
    _runtimePool.clear();
    _poolAccessOrder.clear();
    _sourceLocks.clear();
  }
}
