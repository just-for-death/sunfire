import 'dart:convert';
import 'package:flutter_qjs/flutter_qjs.dart';
import 'dom_selector.dart';
import 'http.dart';
import 'js_utils.dart';
import 'preferences.dart';

class JsExtensionService {
  late JavascriptRuntime runtime;
  final Map<String, dynamic> sourceMeta;
  final String sourceCode;
  bool _isInitialized = false;
  late JsDomSelector _jsDomSelector;
  late JsHttpClient _httpClient;

  JsExtensionService({
    required this.sourceMeta,
    required this.sourceCode,
  });

  void _init() {
    if (_isInitialized) return;
    runtime = QuickJsRuntime2(stackSize: 1024 * 1024 * 4);
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
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
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
    return JSON.stringify(await fn());
}
''');

    runtime.evaluate('''
$sourceCode
var extention = new DefaultExtension();
''');
    _isInitialized = true;
  }

  void dispose() {
    if (!_isInitialized) return;
    try {
      _jsDomSelector.dispose();
      _httpClient.dispose();
    } catch (_) {}
    _isInitialized = false;
  }

  Map<String, String> getHeaders() {
    return _extensionCall<Map>(
      'getHeaders(${jsonEncode(sourceMeta['baseUrl'] ?? '')})',
      {},
    ).map((k, v) => MapEntry(k.toString(), v.toString()));
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

      return rawList
          .map((e) {
            if (e is Map) {
              final raw = (e['url'] ?? e['image'] ?? e['link'] ?? e['src'] ?? e['img'] ?? '').toString().trim();
              return raw;
            }
            return e.toString().trim();
          })
          .where((u) => u.isNotEmpty)
          .map((u) {
            if (u.startsWith('//')) return 'https:$u';
            if (!u.startsWith('http://') && !u.startsWith('https://') && cleanBase.isNotEmpty) {
              final cleanPath = u.startsWith('/') ? u : '/$u';
              return '$cleanBase$cleanPath';
            }
            return u;
          })
          .toList();
    }
    return [];
  }

  T _extensionCall<T>(String call, T def) {
    _init();
    try {
      final res = runtime.evaluate('JSON.stringify(extention.$call)');
      return jsonDecode(res.stringResult) as T;
    } catch (_) {
      return def;
    }
  }

  Future<T> extensionCallAsync<T>(String call) async {
    _init();
    try {
      final promised = await runtime.handlePromise(
        await runtime.evaluateAsync('jsonStringify(() => extention.$call)'),
      );
      final rawStr = promised.stringResult;
      if (rawStr.startsWith('SyntaxError:') || rawStr.startsWith('Error:') || rawStr.startsWith('TypeError:')) {
        throw Exception(rawStr);
      }
      final decoded = jsonDecode(rawStr);
      if (decoded is T) return decoded;
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded) as T;
      }
      return decoded as T;
    } catch (e) {
      rethrow;
    }
  }
}
