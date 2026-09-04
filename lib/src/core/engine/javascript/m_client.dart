import 'dart:convert';
import 'dart:io';
import 'package:cronet_http/cronet_http.dart';
import 'package:cupertino_http/cupertino_http.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_interceptor/http_interceptor.dart';
import '../../logging/logger_service.dart';

CronetEngine? _sharedCronetEngine;

http.Client _createNativeEngineClient() {
  if (!kIsWeb && Platform.isAndroid) {
    try {
      _sharedCronetEngine ??= CronetEngine.build(
        cacheMode: CacheMode.memory,
        cacheMaxSize: 32 * 1024 * 1024,
        enableHttp2: true,
        enableQuic: true,
        enableBrotli: true,
      );
      return CronetClient.fromCronetEngine(_sharedCronetEngine!);
    } catch (_) {}
  } else if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) {
    try {
      return CupertinoClient.defaultSessionConfiguration();
    } catch (_) {}
  }
  return http.Client();
}

class MClient {
  static final Map<String, String> _cookies = {};
  static String _userAgent = 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.6832.64 Mobile Safari/537.36';
  static String cfProxyUrl = '';

  // Deduplication map — one in-flight Future per domain root
  static final Map<String, Future<void>> _activeSolves = {};

  // FlareSolverr session per root domain. Reusing a named session (rather
  // than a fresh sessionless request every time) lets the same solved
  // browser context/cookies persist across calls, so repeat requests to an
  // already-visited domain skip re-running the Cloudflare challenge
  // entirely. Measured ~15x faster (13s cold vs 0.8s warm) on a real
  // Cloudflare-protected site. FlareSolverr auto-creates a named session on
  // first use, so no separate sessions.create round trip is needed.
  static final Set<String> _flareSolverrSessions = {};

  static String _sessionNameFor(String root) {
    final safe = root.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    return 'sunfire_$safe';
  }

  static String get userAgent => _userAgent;

  static InterceptedClient init({
    Map<String, dynamic>? reqcopyWith,
    bool showCloudFlareError = true,
  }) {
    return InterceptedClient.build(
      client: _createNativeEngineClient(),
      interceptors: [
        MCookieManager(reqcopyWith),
        LoggerInterceptor(showCloudFlareError),
      ],
      retryPolicy: ResolveCloudFlareChallenge(showCloudFlareError),
    );
  }

  static String _extractRootDomain(String host) {
    final parts = host.split('.');
    if (parts.length > 2) {
      return parts.sublist(parts.length - 2).join('.');
    }
    return host;
  }

  static bool hasCookieFor(String url) {
    try {
      final host = Uri.parse(url).host;
      final root = _extractRootDomain(host);
      if (_cookies.containsKey(host) || _cookies.containsKey(root)) return true;
      for (final key in _cookies.keys) {
        if (host.endsWith(key) || key.endsWith(root)) return true;
      }
    } catch (_) {}
    return false;
  }

  /// Pre-warm a FlareSolverr session for [url]'s domain.
  /// Concurrent calls for the same root domain share one solve (deduplication).
  static Future<void> prewarmSession(String url, {bool forceRenew = false}) async {
    if (cfProxyUrl.isEmpty) return;
    try {
      final host = Uri.parse(url).host;
      final root = _extractRootDomain(host);
      // Already have a valid cookie — no need to re-solve (unless forced)
      if (!forceRenew && hasCookieFor(url)) return;
      // Deduplicate: return the existing in-flight solve if one is running
      if (_activeSolves.containsKey(root)) {
        return await _activeSolves[root]!;
      }
      // Use the actual URL for CDN subdomains so FlareSolverr visits that domain
      final future = _doPrewarm(url, root);
      _activeSolves[root] = future;
      try {
        await future;
      } finally {
        _activeSolves.remove(root);
      }
    } catch (_) {}
  }

  static Future<void> _doPrewarm(String url, String root) async {
    debugPrint('[MClient] Pre-warming session for $root');
    // Visit the actual URL (not just origin root) so subdomains like cdn.* get solved
    final uri = Uri.parse(url);
    final origin = '${uri.scheme}://${uri.host}';
    await solveAndFetchWithProxy(origin);
  }


  static Map<String, String> getCookiesPref(String url) {
    try {
      final host = Uri.parse(url).host;
      final rootHost = _extractRootDomain(host);

      String? cookie = _cookies[host] ?? _cookies[rootHost];
      if (cookie == null) {
        for (final entry in _cookies.entries) {
          if (host.endsWith(entry.key) || entry.key.endsWith(rootHost)) {
            cookie = entry.value;
            break;
          }
        }
      }

      if (cookie != null && cookie.isNotEmpty) {
        return {HttpHeaders.cookieHeader: cookie};
      }
    } catch (_) {}
    return {};
  }

  static Future<void> setCookie(String url, String ua, {String? cookie}) async {
    try {
      final host = Uri.parse(url).host;
      final rootHost = _extractRootDomain(host);
      if (cookie != null && cookie.isNotEmpty) {
        _cookies[host] = cookie;
        _cookies[rootHost] = cookie;
        _cookies['cdn.$rootHost'] = cookie;
      }
      if (ua.isNotEmpty) {
        _userAgent = ua;
      }
    } catch (_) {}
  }

  /// Directly sends a request.get to FlareSolverr / Byparr and returns the solved response.
  static Future<Map<String, dynamic>?> solveAndFetchWithProxy(String targetUrl) async {
    if (!targetUrl.startsWith('http://') && !targetUrl.startsWith('https://')) {
      return null;
    }
    final proxyUrl = normalizeProxyUrl(cfProxyUrl.trim());
    if (proxyUrl.isEmpty) return null;
    try {
      final root = _extractRootDomain(Uri.parse(targetUrl).host);
      final session = _sessionNameFor(root);
      _flareSolverrSessions.add(session);
      debugPrint('[MClient] Solving challenge via FlareSolverr for $targetUrl (session=$session)');
      final res = await http.post(
        Uri.parse(proxyUrl),
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
        body: jsonEncode({
          'cmd': 'request.get',
          'url': targetUrl,
          'session': session,
          'maxTimeout': 60000,
        }),
      ).timeout(const Duration(seconds: 25));

      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (data['status'] != 'ok') return null;

      final solution = data['solution'] as Map<String, dynamic>?;
      if (solution == null) return null;

      final cookieList = (solution['cookies'] as List?) ?? [];
      final cookie = cookieList
          .whereType<Map>()
          .map((c) => "${c['name']}=${c['value']}")
          .join('; ');

      final ua = (solution['userAgent'] as String?) ?? '';
      if (cookie.isNotEmpty || ua.isNotEmpty) {
        await setCookie(targetUrl, ua, cookie: cookie);
      }

      debugPrint('[MClient] ✅ FlareSolverr successfully returned full solved page (${(solution['response'] as String?)?.length ?? 0} chars)');
      return {
        'body': solution['response'] ?? '',
        'statusCode': solution['status'] ?? 200,
        'headers': solution['headers'] ?? {},
        'request': {'url': solution['url'] ?? targetUrl},
      };
    } catch (e) {
      debugPrint('[MClient] ❌ FlareSolverr solve failed: $e');
      return null;
    }
  }

  static String normalizeProxyUrl(String url) {
    if (url.isEmpty) return url;
    final clean = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    if (RegExp(r'/v\d+$').hasMatch(clean)) return clean;
    return '$clean/v1';
  }
}

class MCookieManager extends InterceptorContract {
  final Map<String, dynamic>? reqcopyWith;
  MCookieManager(this.reqcopyWith);

  @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {
    final cookie = MClient.getCookiesPref(request.url.toString());
    if (cookie.isNotEmpty) {
      if (request.headers[HttpHeaders.cookieHeader] == null) {
        request.headers.addAll(cookie);
      }
    }
    if (request.headers[HttpHeaders.userAgentHeader] == null) {
      request.headers[HttpHeaders.userAgentHeader] = MClient._userAgent;
    }
    return request;
  }

  @override
  Future<BaseResponse> interceptResponse({required BaseResponse response}) async {
    return response;
  }
}

class LoggerInterceptor extends InterceptorContract {
  final bool showCloudFlareError;
  LoggerInterceptor(this.showCloudFlareError);

  @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {
    try {
      final method = request.method;
      final url = request.url.toString();
      LoggerService.instance.logNetwork('-> HTTP $method $url', 'MClient');
    } catch (_) {}
    return request;
  }

  @override
  Future<BaseResponse> interceptResponse({required BaseResponse response}) async {
    try {
      final method = response.request?.method ?? 'GET';
      final url = response.request?.url.toString() ?? 'Unknown URL';
      final status = response.statusCode;
      // A Cloudflare-flagged status with a proxy configured is an expected,
      // self-healing condition (a bypass fetch follows right after) rather
      // than a true failure, so logging it as ERROR here is misleading and
      // pollutes diagnostics/Sentry with false alarms for requests that end
      // up succeeding a moment later via the FlareSolverr fallback.
      final willSelfHeal = isCloudflare(response) && MClient.cfProxyUrl.trim().isNotEmpty;
      if (status >= 400 && !willSelfHeal) {
        LoggerService.instance.logError('<- HTTP $status $method $url', category: 'MClient');
      } else if (status >= 400) {
        LoggerService.instance.logNetwork('<- HTTP $status $method $url (Cloudflare, bypass pending)', 'MClient');
      } else {
        LoggerService.instance.logNetwork('<- HTTP $status $method $url', 'MClient');
      }
    } catch (_) {}
    return response;
  }
}

bool isCloudflare(BaseResponse response) {
  final isBlockedStatus = [403, 503, 429, 520, 521, 522].contains(response.statusCode);
  return isBlockedStatus;
}

class ResolveCloudFlareChallenge extends RetryPolicy {
  final bool showCloudFlareError;
  ResolveCloudFlareChallenge(this.showCloudFlareError);

  // A single retry attempt is sufficient: the retry re-solves the challenge
  // and stores a fresh cookie, but a second identical attempt would just
  // repeat the exact same (slow, ~5-30s) FlareSolverr round trip for the
  // same URL with no new information, so it can never change the outcome.
  // The definitive fallback (fetching the fully-rendered body directly from
  // FlareSolverr) lives in http.dart's _toHttpResponse and only fires once.
  @override
  int get maxRetryAttempts => 1;

  @override
  Future<bool> shouldAttemptRetryOnResponse(BaseResponse response) async {
    if (!showCloudFlareError) return false;
    if (!isCloudflare(response)) return false;
    final url = response.request!.url.toString();
    debugPrint('[MClient] Cloudflare detected for $url — attempting bypass');

    final proxyUrl = MClient.normalizeProxyUrl(MClient.cfProxyUrl.trim());
    if (proxyUrl.isNotEmpty) {
      debugPrint('[MClient] Using CF proxy: $proxyUrl');
      final headers = response.request?.headers;
      return _solveWithCfProxy(proxyUrl, url, headers);
    }
    debugPrint('[MClient] Cloudflare challenge detected for $url — no FlareSolverr proxy configured. Set up in Settings.');
    LoggerService.instance.logWarning(
      'Cloudflare challenge blocked $url. Configure FlareSolverr in Settings to bypass.',
      'MClient',
    );
    return false;
  }
}

Future<bool> _solveWithCfProxy(String proxyUrl, String targetUrl, [Map<String, String>? headers]) async {
  try {
    final root = MClient._extractRootDomain(Uri.parse(targetUrl).host);
    final session = MClient._sessionNameFor(root);
    MClient._flareSolverrSessions.add(session);
    debugPrint('[MClient] POSTing to $proxyUrl for $targetUrl (session=$session)');
    final payload = <String, dynamic>{
      'cmd': 'request.get',
      'url': targetUrl,
      'session': session,
      'maxTimeout': 60000,
    };
    if (headers != null && headers.isNotEmpty) {
      payload['headers'] = headers;
    }
    final res = await http.post(
      Uri.parse(proxyUrl),
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: jsonEncode(payload),
    ).timeout(const Duration(seconds: 25));

    debugPrint('[MClient] CF proxy response: ${res.statusCode}');
    if (res.statusCode != 200) return false;
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    debugPrint('[MClient] CF proxy status: ${data['status']}');
    if (data['status'] != 'ok') return false;

    final solution = data['solution'] as Map<String, dynamic>?;
    if (solution == null) return false;

    final cookieList = (solution['cookies'] as List?) ?? [];
    final cookie = cookieList
        .whereType<Map>()
        .map((c) => "${c['name']}=${c['value']}")
        .join('; ');
    debugPrint('[MClient] CF cookie obtained: ${cookie.isNotEmpty} (${cookie.length} chars)');
    if (cookie.isEmpty) return false;

    final ua = (solution['userAgent'] as String?) ?? '';
    await MClient.setCookie(targetUrl, ua, cookie: cookie);
    debugPrint('[MClient] ✅ CF bypass success — cookie stored, retry will proceed');
    return true;
  } catch (e) {
    debugPrint('[MClient] ❌ CF proxy solve failed: $e');
    return false;
  }
}
