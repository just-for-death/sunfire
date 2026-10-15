import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../../constants/app_constants.dart';
import '../logging/logger_service.dart';
import '../utils/app_identity.dart';
import 'chapter_url_attribution.dart';
import 'headers_lru_cache.dart';
import 'javascript/js_extension_service.dart';
import 'javascript/m_client.dart';
import 'local_source.dart' show LocalSource;
import 'repo_manager.dart';
import 'runtime_pool.dart';
import 'source_icon_helper.dart';
import 'source_preferences.dart';

class _AsyncLock {
  Future<void>? _last;

  /// Serializes [block] so callers of one source never overlap their native
  /// QuickJS evals (flutter_qjs `evaluateAsync` is a synchronous FFI call
  /// under the hood, so two in-flight calls on one runtime re-enter native
  /// QuickJS — undefined behavior / crash). Waits for the previously queued
  /// holder, but never longer than [maxWait]: without this cap a single hung
  /// JS call (stuck scrape, dead FlareSolverr session) blocks every later call
  /// queued behind it indefinitely — the reader's own 30s timeout only stops
  /// IT from waiting, it doesn't free the lock. When the wait overruns, the
  /// previous holder may STILL be executing on the shared runtime, so
  /// [onOverrun] lets the caller switch to a fresh runtime instead of
  /// re-entering the busy one; the overrun holder's future is re-chained so
  /// later callers keep waiting for it too.
  Future<T> synchronized<T>(
    Future<T> Function() block, {
    Duration maxWait = const Duration(seconds: 35),
    void Function()? onOverrun,
  }) async {
    final prev = _last;
    final completer = Completer<void>();
    _last = completer.future;

    var overran = false;
    if (prev != null) {
      try {
        await prev.timeout(maxWait, onTimeout: () {
          overran = true;
        });
      } catch (ignoredError) { if (kDebugMode) debugPrint('[quickjs_service] ignored error: $ignoredError'); }
    }
    if (overran) onOverrun?.call();

    try {
      return await block();
    } finally {
      if (!completer.isCompleted) completer.complete();
      // Re-chain: if the previous holder overran, it may still be running on
      // the shared runtime; subsequent callers must wait for it as well, not
      // just for this caller, or they could re-enter the busy runtime.
      _last = (prev == null || !overran)
          ? completer.future
          : Future.wait([prev, completer.future]);
    }
  }
}

class QuickJsService {
  static QuickJsService? _instance;

  final Map<String, String> _installedJsSources = {};
  final Map<String, String> _canonicalDisplayNames = {};
  final Map<String, String> _installedVersions = {};
  final Map<String, String> _installedIcons = {};
  /// Language variant each install runs as. Variants of one extension share a
  /// script and an install slot, so this is the only place the choice lives.
  final Map<String, String> _installedLangs = {};

  // JS runtime pool — reuse live JsExtensionService instances (LRU, max 5)
  // IMP-029: per-source runtimes; busy ones are never evicted or disposed.
  static const int _poolMaxSize = 5;
  final RuntimePool<JsExtensionService> _runtimePool = RuntimePool<JsExtensionService>(
    maxSize: _poolMaxSize,
    dispose: (r) => r.dispose(),
    isDisposed: (r) => r.isDisposed,
  );

  @visibleForTesting
  RuntimePool<JsExtensionService> get debugRuntimePool => _runtimePool;

  final Map<String, _AsyncLock> _sourceLocks = {};

  bool _initialized = false;
  String? _initError;

  /// Whether any extensions have been installed (either from remote repos or local disk).
  bool get hasInstalledExtensions => _installedJsSources.isNotEmpty;

  /// Whether [initialize] completed without a top-level failure. Individual
  /// extension loads are best-effort; check [installedSourceCount] for how much
  /// actually loaded.
  bool get isInitialized => _initialized;

  /// Set when [initialize] fails at the top level (e.g. neither the on-disk
  /// sources nor the remote-repo auto-install could run). Null when all good.
  String? get initializationError => _initError;

  /// Number of JS extension sources currently registered from the on-disk
  /// install directory (populated by auto-install on first run).
  int get installedSourceCount => _installedJsSources.length;

  QuickJsService._();

  static QuickJsService get instance {
    _instance ??= QuickJsService._();
    return _instance!;
  }

  /// Check whether QuickJS C-FFI bindings are functional on the current host.
  bool get isSupported => !kIsWeb;

  /// Whether QuickJS native library is available and working.
  /// On Android, this can fail if the flutter_qjs plugin doesn't bundle native libraries.
  bool get isAvailable {
    if (!isSupported) return false;
    if (!_initialized) return false;
    if (_initError != null) return false;
    return true;
  }

  /// User-friendly error message when QuickJS is not available.
  String? get availabilityError {
    if (!isSupported) return 'QuickJS is not supported on this platform (web).';
    if (!_initialized) {
      if (!_initInFlight && _initError != null) return 'QuickJS failed to initialize: $_initError';
      return _initInFlight ? 'Extensions are still loading…' : 'QuickJS has not been initialized yet.';
    }
    if (_initError != null) return 'QuickJS failed to initialize: $_initError';
    return null;
  }

  _AsyncLock _getLockFor(String sourceName) {
    return _sourceLocks.putIfAbsent(sourceName, () => _AsyncLock());
  }

  /// Execute an action on a pooled [JsExtensionService] runtime with serialization lock.
  ///
  /// When a call has to wait longer than the lock's cap because a previous
  /// holder is still executing on the shared pooled runtime (rare: hung scrape
  /// / dead proxy session), it must NOT re-enter that busy native runtime.
  /// It instead runs on a temporary fresh runtime that is disposed afterwards.
  Future<T> withRuntime<T>(
    String sourceName,
    String jsCode,
    Future<T> Function(JsExtensionService service) action,
  ) {
    final lockKey = _canonicalizeKey(sourceName);
    var overran = false;
    return _getLockFor(lockKey).synchronized(() async {
      final service = overran
          ? _createEphemeralRuntime(sourceName, jsCode)
          : _runtimePool.acquire(lockKey, jsCode.hashCode, () => _createEphemeralRuntime(sourceName, jsCode));
      try {
        return await action(service);
      } finally {
        if (overran) {
          service.dispose();
        } else {
          _runtimePool.release(lockKey, service);
        }
      }
    }, onOverrun: () {
      overran = true;
    });
  }

  /// A throwaway runtime used only when the shared pooled runtime is still
  /// busy from a previous holder. Never pooled, always disposed by its caller.
  JsExtensionService _createEphemeralRuntime(String sourceName, String jsCode) {
    return JsExtensionService(
      sourceMeta: _sourceMetaFor(jsCode, sourceName),
      sourceCode: jsCode,
    );
  }

  Map<String, dynamic> _sourceMetaFor(String jsCode, [String? sourceName]) {
    final key = sourceName == null ? null : _resolveInstallKey(sourceName);
    final meta = extractSourceMetadata(jsCode, lang: key == null ? null : _installedLangs[key]);
    final name = (sourceName != null && sourceName.isNotEmpty)
        ? sourceName
        : (meta['name']?.toString() ?? '');
    return SourcePreferences.applyToSourceMeta(name, meta);
  }

  /// Invalidate a pooled runtime (e.g. when JS code is updated).
  void _invalidateRuntime(String sourceName) {
    _runtimePool.invalidate(_canonicalizeKey(sourceName));
  }

  /// Public invalidate when source preferences (mirror URL) change.
  void invalidateSourceRuntime(String sourceName) => _invalidateRuntime(sourceName);


  /// Test-only override for the extensions scan. When set,
  /// [_loadInstalledExtensionsFromDisk] reads exactly these directories and
  /// never the real HOME locations — otherwise a developer's installed
  /// extensions leak into mocked-path_provider tests. Always reset to null
  /// in tearDown.
  static List<String>? testOnlyExtensionDirs;

  /// IMP-025: startup no longer awaits [initialize]; local-source calls
  /// await this so they never run against a half-loaded extension set.
  /// Never throws: a failed start leaves [availabilityError] set instead.
  Future<void> get whenReady =>
      _initFuture?.catchError((Object _) {}) ?? Future<void>.value();

  /// Test-only: replaces the on-disk extension scan inside [initialize]
  /// (e.g. to simulate a startup failure). Reset to null in tearDown.
  @visibleForTesting
  static Future<void> Function()? debugInitLoadOverride;
  Future<void>? _initFuture;

  /// True while [initialize] is still loading extensions.
  bool get isStarting => _initInFlight;
  bool _initInFlight = false;

  Future<void> initialize() {
    final f = _initialize();
    _initFuture = f;
    return f;
  }

  Future<void> _initialize() async {
    _initInFlight = true;
    try {
      final loadOverride = debugInitLoadOverride;
      await (loadOverride != null ? loadOverride() : _loadInstalledExtensionsFromDisk());
      _initialized = true;
      _initError = null;
    } catch (e, stack) {
      _initialized = false;
      _initError = e.toString();
      await LoggerService.instance.logError('Failed to initialize QuickJS: $e', exception: e, stackTrace: stack, category: 'QuickJS');
    } finally {
      _initInFlight = false;
    }
  }

  /// Bulk-installs en/all scrapers from [repoUrls] if nothing is installed yet.
  /// Only the user's own repos are ever used; an empty list installs nothing.
  /// Safe to call repeatedly: no-ops when extensions already exist.
  Future<void> ensureAutoInstalled({required List<String> repoUrls}) async {
    await _loadInstalledExtensionsFromDisk();
    if (_installedJsSources.isNotEmpty || repoUrls.isEmpty) return;
    try {
      await RepoManager.instance.downloadAndInstallAllRepoExtensions(userRepoUrls: repoUrls);
    } catch (e) {
      await LoggerService.instance.logWarning('Auto-install from remote repos failed: $e', 'QuickJS');
    }
  }

  Future<void> _loadInstalledExtensionsFromDisk() async {
    // Test isolation: the loader also scans real HOME dirs on Linux, so a
    // developer's installed extensions leak into any test that mocks
    // path_provider (v2_extension_update_key_test saw a real MangaDex
    // overwrite the fixture version). Tests set this to scope the scan.
    if (testOnlyExtensionDirs != null) {
      for (final dirPath in testOnlyExtensionDirs!) {
        try {
          final extDir = Directory(dirPath);
          if (await extDir.exists()) {
            await _loadExtensionsFromDir(extDir);
          }
        } catch (ignoredError) { if (kDebugMode) debugPrint('[quickjs_service] ignored error: $ignoredError'); }
      }
      return;
    }
    final candidateDirs = <String>[];
    try {
      final appDir = await getApplicationDocumentsDirectory();
      candidateDirs.add('${appDir.path}/extensions');
    } catch (ignoredError) { if (kDebugMode) debugPrint('[quickjs_service] ignored error: $ignoredError'); }

    try {
      final appSupportDir = await getApplicationSupportDirectory();
      candidateDirs.add('${appSupportDir.path}/extensions');
    } catch (ignoredError) { if (kDebugMode) debugPrint('[quickjs_service] ignored error: $ignoredError'); }

    if (!kIsWeb && Platform.isLinux) {
      final home = Platform.environment['HOME'];
      if (home != null) {
        candidateDirs.add('$home/.local/share/$kLinuxApplicationId/extensions');
        candidateDirs.add('$home/Documents/extensions');
      }
    }

    for (final dirPath in candidateDirs) {
      try {
        final extDir = Directory(dirPath);
        if (await extDir.exists()) {
          await _loadExtensionsFromDir(extDir);
        }
      } catch (ignoredError) { if (kDebugMode) debugPrint('[quickjs_service] ignored error: $ignoredError'); }
    }
  }

  /// Loads every `.js` scraper from one extensions directory.
  Future<void> _loadExtensionsFromDir(Directory extDir) async {
    final dirPath = extDir.path;
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
              final lang = metaJson['lang']?.toString().trim().toLowerCase() ?? '';
              if (lang.isNotEmpty) _installedLangs[cleanKey] = lang;
            }
          } catch (ignoredError) { if (kDebugMode) debugPrint('[quickjs_service] ignored error: $ignoredError'); }
        }
      }
    }
  }

  Future<bool> saveLocalExtension(
    String sourceName,
    String jsCode, {
    String? version,
    String? iconUrl,
    String? lang,
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
      final staleLang = _installedLangs.remove(k);
      if (staleLang != null) _installedLangs.putIfAbsent(cleanName, () => staleLang);
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
    final normalizedLang = lang?.trim().toLowerCase() ?? '';
    if (normalizedLang.isNotEmpty) _installedLangs[cleanName] = normalizedLang;

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
      // Write to a temp file and rename.
      //
      // `writeAsString` truncates in place, so a process kill (low-memory
      // kill, background-task eviction, battery pull) mid-write left a
      // PARTIAL `.js` in the extensions directory. On next launch the loader
      // accepted it — its only rejection is a check for Dart bytecode, not for
      // JS validity — leaving the extension permanently installed-but-broken:
      // every call re-allocated a runtime, threw, and returned an empty list,
      // and `getInstalledVersion` still reported a version so the updater saw
      // nothing to do. The only recovery was a manual reinstall.
      //
      // `rename` is atomic on POSIX and NTFS within a filesystem, so the
      // extension directory only ever contains a complete file.
      final tmpFile = File('${extDir.path}/$cleanName.js.tmp');
      await tmpFile.writeAsString(jsCode);
      await tmpFile.rename(file.path);

      final metaFile = File('${extDir.path}/$cleanName.json');
      final metaTmp = File('${extDir.path}/$cleanName.json.tmp');
      await metaTmp.writeAsString(jsonEncode({
        'name': displayName,
        'version': version ?? _installedVersions[cleanName] ?? '1.0.0',
        'iconUrl': iconUrl ?? _installedIcons[cleanName] ?? '',
        if (_installedLangs[cleanName] != null) 'lang': _installedLangs[cleanName],
      }));
      await metaTmp.rename(metaFile.path);

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
        } catch (ignoredError) { if (kDebugMode) debugPrint('[quickjs_service] ignored error: $ignoredError'); }
      }
      return true;
    } catch (e) {
      await LoggerService.instance.logError('Failed to persist extension $sourceName: $e', exception: e, stackTrace: StackTrace.current, category: 'QuickJS');
      return false;
    }
  }

  static String _canonicalizeKey(String raw) {
    return raw
        .replaceAll('local_js_', '')
        .replaceAll('localjs', '')
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
        .replaceAll('local_js_', '')
        .replaceAll('localjs_', '')
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

  bool isSourceInstalledLocally(String sourceName) => _resolveInstallKey(sourceName) != null;

  bool isLocalExtensionInstalled(String sourceName) => isSourceInstalledLocally(sourceName);

  /// Whether repo entry [name] is installed as its [lang] variant. Language
  /// variants share one install slot, so installing another variant switches it.
  bool isVariantInstalled(String name, String lang) {
    String? key;
    for (final k in _installedJsSources.keys) {
      if (_sameExtensionIdentity(k, name)) {
        key = k;
        break;
      }
    }
    if (key == null) return false;
    return langsCompatible(getInstalledLang(key), lang);
  }

  /// Same language variant. Unknown matches anything, and en/all are treated
  /// as one because indexes label the same single-language script either way.
  static bool langsCompatible(String a, String b) {
    final x = a.trim().toLowerCase();
    final y = b.trim().toLowerCase();
    if (x.isEmpty || y.isEmpty || x == y) return true;
    const enLike = {'en', 'all'};
    return enLike.contains(x) && enLike.contains(y);
  }

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
      _installedLangs.remove(k);
      _invalidateRuntime(k);
    }
    try {
      final candidateDirs = <Directory>[];
      final appDir = await getApplicationDocumentsDirectory();
      candidateDirs.add(Directory('${appDir.path}/extensions'));
      try {
        final appSupportDir = await getApplicationSupportDirectory();
        candidateDirs.add(Directory('${appSupportDir.path}/extensions'));
      } catch (ignoredError) { if (kDebugMode) debugPrint('[quickjs_service] ignored error: $ignoredError'); }

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

  /// Lowercase language the install runs as ('' when not installed). Legacy
  /// installs without a recorded choice resolve from the script header.
  String getInstalledLang(String sourceName) {
    final key = _resolveInstallKey(sourceName);
    if (key == null) return '';
    final recorded = _installedLangs[key];
    if (recorded != null && recorded.isNotEmpty) return recorded;
    try {
      return (extractSourceMetadata(_installedJsSources[key]!)['lang']?.toString() ?? '').trim().toLowerCase();
    } catch (_) {
      return '';
    }
  }

  String getSourceLang(String sourceName) {
    final lang = getInstalledLang(sourceName);
    return lang.isEmpty ? 'EN' : lang.toUpperCase();
  }

  static const int _maxHeadersCacheEntries = 500;
  static const Duration _headersCacheTtl = Duration(hours: 1);
  // UIX-16: real LRU + sliding TTL + sweep throttled to once a minute.
  static final HeadersLruCache _headersCache = HeadersLruCache(
    maxEntries: _maxHeadersCacheEntries,
    ttl: _headersCacheTtl,
  );

  static void _setCacheEntry(String key, Map<String, String> value) => _headersCache.set(key, value);

  static void _cleanExpiredCacheEntries() => _headersCache.maybeSweep();

  static void cacheImageHeaders(String url, Map<String, String> headers) {
    if (url.isNotEmpty && headers.isNotEmpty) {
      _setCacheEntry(url, headers);
    }
  }

  static void clearHeadersCache() {
    _headersCache.clear();
  }

  static Map<String, String> getImageHeaders(String sourceOrUrl, [String? imageUrl]) {
    _cleanExpiredCacheEntries();
    final targetUrl = (imageUrl != null && imageUrl.isNotEmpty) ? imageUrl : sourceOrUrl;
    final headers = <String, String>{
      'User-Agent': MClient.userAgent,
    };

    final cacheKey = '$sourceOrUrl|$targetUrl';
    final cachedPair = _headersCache.get(cacheKey);
    if (cachedPair != null) {
      headers.addAll(cachedPair);
      if (targetUrl.isNotEmpty) {
        headers.addAll(MClient.getCookiesPref(targetUrl));
      }
      return headers;
    }
    final cachedUrl = _headersCache.get(targetUrl);
    if (cachedUrl != null) {
      headers.addAll(cachedUrl);
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
      } catch (ignoredError) { if (kDebugMode) debugPrint('[quickjs_service] ignored error: $ignoredError'); }
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
    _cleanExpiredCacheEntries();
    final cacheKey = '${jsCode.hashCode}_${targetUrl ?? ''}';
    final cached = _headersCache.get(cacheKey);
    if (cached != null) return cached;
    final service = JsExtensionService(
      sourceMeta: _sourceMetaFor(jsCode),
      sourceCode: jsCode,
    );
    try {
      final h = service.getHeaders(targetUrl);
      _setCacheEntry(cacheKey, h);
      return h;
    } catch (e, stack) {
      unawaited(LoggerService.instance.logError('Failed to fetch headers: $e', exception: e, stackTrace: stack, category: 'QuickJS'));
      return {};
    } finally {
      service.dispose();
    }
  }

  String? getExtensionCode(String sourceName) {
    final key = _resolveInstallKey(sourceName);
    return key == null ? null : _installedJsSources[key];
  }

  /// Install key serving [sourceName]. Exact and alphanumeric matches are
  /// tried across every install before any prefix match, so a prefix hit on
  /// one install can never shadow an exact install of the requested source.
  String? _resolveInstallKey(String sourceName) {
    if (sourceName.isEmpty) return null;
    // IMP-002: the on-device Local source is never a JS extension (and must
    // not fuzzy-match one, which would scrape `localfs:` paths over the net).
    if (sourceName == LocalSource.sourceName) return null;
    final stripped = sourceName.replaceAll('local_js_', '').replaceAll('localjs_', '');
    final cleanName = stripped
        .replaceAll(RegExp(r'\s*\([a-zA-Z0-9_]+\)$'), '')
        .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_')
        .toLowerCase();
    final alphaOnly = cleanName.replaceAll('_', '');

    if (_installedJsSources.containsKey(cleanName)) return cleanName;
    if (_installedJsSources.containsKey(sourceName)) return sourceName;

    String keyAlphaOf(String key) => key
        .replaceAll('local_js_', '')
        .replaceAll('localjs_', '')
        .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')
        .toLowerCase();

    final canonQuery = _canonicalizeKey(sourceName);
    for (final key in _installedJsSources.keys) {
      final keyClean = key.replaceAll('local_js_', '').replaceAll('localjs_', '');
      if (cleanName == keyClean || alphaOnly == keyAlphaOf(key) || canonQuery == _canonicalizeKey(key)) return key;
    }
    if (alphaOnly.length >= 5) {
      for (final key in _installedJsSources.keys) {
        final keyAlpha = keyAlphaOf(key);
        if (keyAlpha.length >= 5 && (alphaOnly.startsWith(keyAlpha) || keyAlpha.startsWith(alphaOnly))) {
          return key;
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
    } catch (ignoredError) { if (kDebugMode) debugPrint('[quickjs_service] ignored error: $ignoredError'); }
    return null;
  }

  /// Parses the `mangayomiSources` header. Multi-language scripts declare
  /// `langs: [...]` and `ids: {lang: id}`; [lang] picks the variant to run
  /// (the script reads `this.source.lang`), defaulting to en, else the first.
  Map<String, dynamic> extractSourceMetadata(String jsCode, {String? lang}) {
    String name = '';
    String baseUrl = '';
    String apiUrl = '';
    String iconUrl = '';
    String version = '1.0.0';
    String resolvedLang = 'en';
    var langs = <String>[];
    dynamic id = 0;
    var headerParsed = false;

    // 1. Try standard JSON decode of mangayomiSources array
    try {
      // The header may use a JS trailing comma after the last property
      // (",\n  },") which is invalid JSON. `,?` lets the capture end at
      // the header instead of bleeding into the class body below it.
      final match = RegExp(r'''(?:const|var|let)\s+mangayomiSources\s*=\s*(\[\s*\{[\s\S]*?\}\s*,?\s*\]);?''').firstMatch(jsCode);
      if (match != null) {
        var jsonStr = match.group(1)!;
        // Use replaceAllMapped to avoid replacement string parsing issues with $1
        jsonStr = jsonStr.replaceAllMapped(RegExp(r',\s*([\]\}])'), (match) => match.group(1)!);
        final decoded = jsonDecode(jsonStr);
        if (decoded is List && decoded.isNotEmpty) {
          final map = Map<String, dynamic>.from(decoded[0] as Map);
          name = map['name']?.toString() ?? '';
          baseUrl = map['baseUrl']?.toString() ?? '';
          apiUrl = map['apiUrl']?.toString() ?? '';
          iconUrl = map['iconUrl']?.toString() ?? '';
          version = map['version']?.toString() ?? '1.0.0';
          final rawLangs = map['langs'];
          if (rawLangs is List) {
            langs = rawLangs.map((e) => e.toString().trim().toLowerCase()).where((e) => e.isNotEmpty).toList();
          }
          final wanted = lang?.trim().toLowerCase() ?? '';
          final single = map['lang']?.toString().trim() ?? '';
          if (langs.isNotEmpty) {
            resolvedLang = langs.contains(wanted) ? wanted : (langs.contains('en') ? 'en' : langs.first);
          } else if (single.isNotEmpty) {
            resolvedLang = single;
          }
          final ids = map['ids'];
          id = ids is Map ? (ids[resolvedLang] ?? 0) : (map['id'] ?? 0);
          headerParsed = true;
        }
      }
    } catch (ignoredError) { if (kDebugMode) debugPrint('[quickjs_service] ignored error: $ignoredError'); }

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
    if (!headerParsed) {
      final langMatch = RegExp(r'''(?:['"]?(?:lang|langs)['"]?)\s*:\s*['"]([^'"]+)['"]''').firstMatch(jsCode);
      if (langMatch != null) resolvedLang = langMatch.group(1)!.trim();
    }
    if (id == 0 && !headerParsed) {
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
      'lang': resolvedLang,
      'langs': langs,
      'id': id,
    };
  }

  /// ── FETCH SOURCE MANGA CATALOG VIA MANGAYOMI RUNTIME ─────────
  /// Test-only fake for [fetchSourceMangaLocal] (UIX-21). Replaces the old
  /// debug-build mock fallback that fabricated results from the extension
  /// source. Never set in production code.
  @visibleForTesting
  static Future<List<Map<String, dynamic>>> Function(String sourceName, String jsCode)? debugScrapeOverride;

  /// Test-only fake for [fetchChapterPagesLocal] (UIX-21), for unit tests on
  /// hosts without the QuickJS native library. Never set in production code.
  @visibleForTesting
  static Future<List<String>> Function(String sourceName, String jsCode, String chapterUrl)? debugPageListOverride;

  /// Test isolation (ISS-140): clears every process-global test seam.
  @visibleForTesting
  static void debugResetTestOverrides() {
    debugInitLoadOverride = null;
    debugScrapeOverride = null;
    debugPageListOverride = null;
  }

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
    await whenReady; // IMP-025
    final jsCode = getExtensionCode(sourceName);
    if (jsCode == null || jsCode.isEmpty) {
      return [];
    }
    final scrapeOverride = debugScrapeOverride;
    if (scrapeOverride != null) return scrapeOverride(sourceName, jsCode);

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
          // Belt-and-braces with the in-runtime character cap: this bounds the
          // Dart-side materialisation, which is what actually holds the objects
          // in memory. A browse page is at most a few hundred entries; anything
          // beyond this is a broken or hostile source, not a result.
          if (list.length > kMaxScraperPageEntries) {
            await LoggerService.instance.logWarning(
              'Extension returned ${list.length} entries, above the '
              '$kMaxScraperPageEntries limit; truncating',
              'QuickJS',
            );
            return list
                .take(kMaxScraperPageEntries)
                .map((item) => Map<String, dynamic>.from(item as Map))
                .toList();
          }
          return list.map((item) => Map<String, dynamic>.from(item as Map)).toList();
        }
        return [];
      });
    } catch (e) {
      // UIX-21: no debug-only mock fallback here any more. It fabricated
      // manga from regexes over the extension source, so debug builds showed
      // phantom series in Browse whenever a scrape failed.
      await LoggerService.instance.logError('Local scraping failed for $sourceName: $e', exception: e, stackTrace: StackTrace.current, category: 'QuickJS');
      return [];
    }
  }

  /// ── RESOLVE EXTENSION DIRECT COVER URL IF SUPPORTED ──
  ///
  /// Runs through the per-source serialization lock like every other runtime
  /// call: getCoverUrl is a synchronous FFI eval, and two overlapping evals on
  /// one pooled runtime is undefined behavior (see [withRuntime]).
  Future<String?> getExtensionCoverUrl(String sourceName, String mangaUrl) async {
    final jsCode = getExtensionCode(sourceName);
    if (jsCode == null || jsCode.isEmpty || mangaUrl.isEmpty) {
      return null;
    }
    try {
      return await withRuntime<String?>(sourceName, jsCode, (service) async {
        return service.getCoverUrl(mangaUrl);
      });
    } catch (_) {
      return null;
    }
  }

  /// ── SCRAPE MANGA DETAILS & CHAPTER LIST VIA MANGAYOMI RUNTIME ──
  Future<Map<String, dynamic>> fetchMangaDetailsLocal(String sourceName, String mangaUrl) async {
    await whenReady; // IMP-025
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
      } catch (ignoredError) { if (kDebugMode) debugPrint('[quickjs_service] ignored error: $ignoredError'); }
    }

    try {
      final detail = await withRuntime<Map<String, dynamic>>(sourceName, jsCode, (service) async {
        return await service.getDetail(targetUrl);
      });
      // Drop chapters that belong to a different series page (related-comic
      // links picked up by over-broad selectors). See
      // chapterUrlBelongsToMangaPage: conservative, only rejects provable
      // same-host mismatches.
      final rawChapters = detail['chapters'];
      if (rawChapters is List && rawChapters.isNotEmpty) {
        final before = rawChapters.length;
        rawChapters.removeWhere((c) {
          final url = (c is Map ? (c['url'] ?? c['link']) : null)?.toString() ?? '';
          return !chapterUrlBelongsToMangaPage(targetUrl, url);
        });
        final dropped = before - rawChapters.length;
        if (dropped > 0 && kDebugMode) {
          debugPrint('[quickjs_service] dropped $dropped foreign chapters for $sourceName ($targetUrl)');
        }
      }
      return detail;
    } catch (e) {
      await LoggerService.instance.logError('Local getDetail failed for $sourceName ($targetUrl): $e', exception: e, stackTrace: StackTrace.current, category: 'QuickJS');
      return {};
    }
  }

  Future<List<String>> fetchChapterPagesLocal(String sourceName, String chapterUrl) async {
    await whenReady; // IMP-025
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

    final pagesOverride = debugPageListOverride;
    if (pagesOverride != null) return pagesOverride(sourceName, jsCode, targetUrl);

    // 1. Try with pooled runtime with mutex serialization
    try {
      final pages = await withRuntime<List<String>>(sourceName, jsCode, (service) async {
        return await service.getPageList(targetUrl);
      });
      if (pages.isNotEmpty) return pages;
    } catch (_) {
      _invalidateRuntime(sourceName);
      // UIX-21: the debug-only shim that served image-looking URL literals
      // from the extension source as "pages" when the native engine failed
      // to load is gone. An engine failure is now reported, never masked.
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
    await whenReady; // IMP-025
    final jsCode = getExtensionCode(sourceName);
    if (jsCode == null || jsCode.isEmpty) return [];

    try {
      return await withRuntime<List<dynamic>>(sourceName, jsCode, (service) async {
        return await service.extensionCallAsync<List<dynamic>>('getFilterList()');
      });
    } catch (e, stack) {
      unawaited(LoggerService.instance.logError('Failed to fetch source filters for $sourceName: $e', exception: e, stackTrace: stack, category: 'QuickJS'));
      return [];
    }
  }

  void dispose() {
    // Drain pool and release all JS runtimes
    _runtimePool.disposeAll();
    _sourceLocks.clear();
  }
}
