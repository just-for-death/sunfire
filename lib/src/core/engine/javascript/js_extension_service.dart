import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_qjs/flutter_qjs.dart';

import '../../../constants/app_constants.dart';
import '../quickjs_service.dart';
import 'dom_selector.dart';
import 'http.dart';
import 'js_utils.dart';
import 'preferences.dart';

class JsExtensionService {
  late JavascriptRuntime runtime;
  final Map<String, dynamic> sourceMeta;
  final String sourceCode;
  bool _isInitialized = false;
  JsDomSelector? _jsDomSelector;
  JsHttpClient? _httpClient;

  JsExtensionService({
    required this.sourceMeta,
    required this.sourceCode,
  });

  void _init() {
    if (_isInitialized || _isDisposed) return;
    // The extension source is REMOTE, downloaded code that runs unsandboxed on
    // the UI isolate. Two limits are not optional here:
    //
    // `timeout` installs QuickJS's interrupt handler (it is passed straight to
    // jsNewRuntime, and 0 means "no handler"). Without it, a single
    // `while(true){}` in a scraper — or in its top level, getHeaders, or
    // getPageList — blocks the FFI call forever. The Dart-side timeouts
    // elsewhere in this codebase (20s in the content resolver, 35s on the
    // source lock, 180s on handlePromise) are all scheduled on the same isolate,
    // so none of them can fire: the process wedges and the user has to
    // force-kill, losing unsaved reader state. `stackSize` alone does not help
    // — it bounds recursion, and a tight loop consumes no stack.
    //
    // `memoryLimit` caps the JS heap. Without it a scraper can grow an array
    // until the OS kills the app, which surfaces as a random crash on a
    // low-memory device rather than as a scraper fault.
    runtime = QuickJsRuntime2(
      stackSize: 1024 * 1024 * 4,
      timeout: kJsExecutionTimeoutMs,
      memoryLimit: kJsMemoryLimitBytes,
    );
    runtime.enableHandlePromises();

    final baseUrl = (sourceMeta['baseUrl'] ?? sourceMeta['apiUrl'] ?? '').toString();
    _httpClient = JsHttpClient(runtime, baseUrl)..init();
    _jsDomSelector = JsDomSelector(runtime)..init();
    JsUtils(runtime).init();
    JsPreferences(runtime).init();

    final sourceJson = jsonEncode(sourceMeta);

    runtime.evaluate('''
class MProvider {
    get source() {
        return $sourceJson;
    }
    get supportsLatest() {
        return true;
    }
    getHeaders(url) {
        return {
            "User-Agent": "$kBrowserUserAgent",
            "Referer": this.source.baseUrl || ""
        };
    }
    async getPopular(page) {
        throw new Error("getPopular not implemented");
    }
    async getLatestUpdates(page) {
        throw new Error("getLatestUpdates not implemented");
    }
    async search(query, page, filters) {
        throw new Error("search not implemented");
    }
    async getDetail(url) {
        throw new Error("getDetail not implemented");
    }
    async getPageList(url) {
        throw new Error("getPageList not implemented");
    }
    getFilterList() {
        return [];
    }
    getSourcePreferences() {
        return [];
    }
}
async function jsonStringify(fn) {
    try {
        const res = await fn();
        const encoded = JSON.stringify(res !== undefined ? res : null);
        // Cap inside the runtime.
        //
        // This string is built inside QuickJS and then jsonDecode'd into
        // unbounded Dart collections, so a scraper returning millions of page
        // entries OOMs the process before any UI is shown. Truncating here
        // bounds the peak on both sides, and the Dart side enforces the real
        // limit; this is the cheap first line of defence.
        const limit = $kMaxScraperPayloadChars;
        if (encoded != null && encoded.length > limit) {
            return JSON.stringify({
                "__error__": "Extension returned " + encoded.length +
                    " characters, above the " + limit + " character limit. " +
                    "The source is returning far more data than a chapter page list."
            });
        }
        return encoded;
    } catch (err) {
        return JSON.stringify({ "__error__": err ? (err.stack || err.message || err.toString()) : "Unknown error" });
    }
}
function jsonStringifySync(fn) {
    try {
        const res = fn();
        return JSON.stringify(res !== undefined ? res : null);
    } catch (err) {
        return JSON.stringify({ "__error__": err ? (err.stack || err.message || err.toString()) : "Unknown error" });
    }
}
''');

    final res = runtime.evaluate('''
$sourceCode
if (typeof extention === "undefined") {
    if (typeof DefaultExtension !== "undefined") {
        var extention = new DefaultExtension();
    } else if (typeof extension !== "undefined") {
        var extention = extension;
    } else if (typeof source !== "undefined") {
        var extention = source;
    }
}
''');
    if (res.isError) {
      debugPrint('[JsExtensionService] ❌ Failed to instantiate extension: ${res.stringResult}');
    }
    _isInitialized = true;
  }

  int _activeRequests = 0;
  bool _isDisposed = false;
  bool get isDisposed => _isDisposed;

  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    if (_activeRequests > 0) {
      // Defer native C-FFI runtime disposal until active requests complete
      return;
    }
    _performDispose();
  }

  void _performDispose() {
    if (!_isInitialized) return;
    _isDisposed = true;
    _httpClient?.dispose();
    if ((_httpClient?.activeHttpRequests ?? 0) > 0) {
      _httpClient?.onAllRequestsFinished = () {
        _performDispose();
      };
      return;
    }
    try {
      _jsDomSelector?.dispose();
      runZoned(
        () {
          runtime.dispose();
        },
        zoneSpecification: ZoneSpecification(
          print: (self, parent, zone, line) {
            if (line.contains('reference leak:') || line.contains('_JSFunction') || line.contains('JSError')) {
              // Suppress flutter_qjs internal bridge teardown diagnostic
              return;
            }
            parent.print(zone, line);
          },
        ),
      );
    } catch (ignoredError) { if (kDebugMode) debugPrint('[js_extension_service] ignored error: $ignoredError'); }
    _isInitialized = false;
  }

  Map<String, String> getHeaders([String? url]) {
    if (_isDisposed) return {};
    final targetUrl = (url != null && url.isNotEmpty) ? url : (sourceMeta['baseUrl'] ?? '');
    _init();
    try {
      final res = runtime.evaluate('''
(function() {
  try {
    if (typeof extention !== "undefined" && typeof extention.getHeaders === "function") {
      return JSON.stringify(extention.getHeaders(${jsonEncode(targetUrl)}) || {});
    }
    if (typeof extention !== "undefined" && extention.headers) {
      return JSON.stringify(extention.headers);
    }
    return JSON.stringify({});
  } catch(e) {
    return JSON.stringify({});
  }
})()
''');
      if (res.isError) return {};
      final decoded = jsonDecode(res.stringResult);
      if (decoded is Map) {
        return decoded.map((k, v) => MapEntry(k.toString(), v.toString()));
      }
    } catch (ignoredError) { if (kDebugMode) debugPrint('[js_extension_service] ignored error: $ignoredError'); }
    return {};
  }

  String? getCoverUrl(String url) {
    if (!_isInitialized) _init();
    try {
      final res = runtime.evaluate('typeof extention.getCoverUrl === "function" ? extention.getCoverUrl(${jsonEncode(url)}) : ""');
      if (!res.isError && res.stringResult.isNotEmpty) {
        return res.stringResult;
      }
    } catch (ignoredError) { if (kDebugMode) debugPrint('[js_extension_service] ignored error: $ignoredError'); }
    return null;
  }

  Future<Map<String, dynamic>> getPopular(int page) async {
    return await extensionCallAsync<Map<String, dynamic>>('getPopular($page)');
  }

  Future<Map<String, dynamic>> getLatestUpdates(int page) async {
    return await extensionCallAsync<Map<String, dynamic>>('getLatestUpdates($page)');
  }

  Future<Map<String, dynamic>> search(String query, int page, [List<dynamic>? filters]) async {
    final filtersJson = filters != null ? jsonEncode(filters) : 'typeof extention.getFilterList === "function" ? extention.getFilterList() : []';
    return await extensionCallAsync<Map<String, dynamic>>(
      'search(${jsonEncode(query)}, $page, $filtersJson)',
    );
  }

  Future<Map<String, dynamic>> getDetail(String url) async {
    return await extensionCallAsync<Map<String, dynamic>>('getDetail(${jsonEncode(url)})');
  }

  Future<List<String>> getPageList(String url) async {
    final res = await extensionCallAsync<dynamic>('getPageList(${jsonEncode(url)})');
    List<dynamic>? rawList;
    if (res is List) {
      rawList = res;
    } else if (res is Map && res['pages'] is List) {
      rawList = res['pages'] as List;
    } else if (res is Map && res['list'] is List) {
      rawList = res['list'] as List;
    }

    if (rawList != null) {
      final baseUrl = (sourceMeta['baseUrl'] ?? '').toString();
      final cleanBase = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;

      final results = <String>[];
      for (final e in rawList) {
        String raw = '';
        Map<String, String>? headers;

        if (e is Map) {
          raw = (e['url'] ?? e['image'] ?? e['link'] ?? e['src'] ?? e['img'] ?? '').toString().trim();
          if (e['headers'] is Map) {
            headers = <String, String>{};
            (e['headers'] as Map).forEach((k, v) {
              if (k != null && v != null) headers![k.toString()] = v.toString();
            });
          }
        } else {
          raw = e.toString().trim();
        }

        if (raw.isEmpty) continue;

        String finalUrl = raw;
        if (finalUrl.startsWith('//')) {
          finalUrl = 'https:$finalUrl';
        } else if (!finalUrl.startsWith('http://') &&
            !finalUrl.startsWith('https://') &&
            !finalUrl.startsWith('data:') &&
            !finalUrl.startsWith('blob:') &&
            cleanBase.isNotEmpty) {
          final cleanPath = finalUrl.startsWith('/') ? finalUrl : '/$finalUrl';
          finalUrl = '$cleanBase$cleanPath';
        }

        if (headers != null && headers.isNotEmpty) {
          QuickJsService.cacheImageHeaders(finalUrl, headers);
        }

        results.add(finalUrl);
      }
      return results;
    }
    return [];
  }


  Future<T> extensionCallAsync<T>(String call, {Duration? timeout}) async {
    if (_isDisposed) {
      throw StateError('Extension runtime has been disposed');
    }
    _activeRequests++;
    _init();
    try {
      final effectiveTimeout = timeout ?? const Duration(seconds: 180);
      final promised = await runtime.handlePromise(
        await runtime.evaluateAsync('jsonStringify(() => extention.$call)'),
        timeout: effectiveTimeout,
      );
      final rawStr = promised.stringResult;
      final decoded = jsonDecode(rawStr);
      if (decoded is Map && decoded.containsKey('__error__')) {
        throw Exception(decoded['__error__']);
      }
      if (decoded is T) return decoded;
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded) as T;
      }
      return decoded as T;
    } catch (e) {
      rethrow;
    } finally {
      _activeRequests--;
      if (_activeRequests <= 0) {
        _jsDomSelector?.clearElements();
        if (_isDisposed) {
          _performDispose();
        }
      }
    }
  }
}
