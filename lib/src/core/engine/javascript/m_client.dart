import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_interceptor/http_interceptor.dart';

class MClient {
  static final Map<String, String> _cookies = {};
  static String _userAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';
  static String cfProxyUrl = '';

  static InterceptedClient init({
    Map<String, dynamic>? reqcopyWith,
    bool showCloudFlareError = true,
  }) {
    return InterceptedClient.build(
      client: http.Client(),
      interceptors: [
        MCookieManager(reqcopyWith),
        LoggerInterceptor(showCloudFlareError),
      ],
    );
  }

  static Map<String, String> getCookiesPref(String url) {
    try {
      final host = Uri.parse(url).host;
      final cookie = _cookies[host];
      if (cookie != null && cookie.isNotEmpty) {
        return {HttpHeaders.cookieHeader: cookie};
      }
    } catch (_) {}
    return {};
  }

  static Future<void> setCookie(String url, String ua, {String? cookie}) async {
    try {
      final host = Uri.parse(url).host;
      if (cookie != null && cookie.isNotEmpty) {
        _cookies[host] = cookie;
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
      debugPrint('[MClient] Solving challenge via FlareSolverr for $targetUrl');
      final res = await http.post(
        Uri.parse(proxyUrl),
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
        body: jsonEncode({
          'cmd': 'request.get',
          'url': targetUrl,
          'maxTimeout': 60000,
        }),
      ).timeout(const Duration(seconds: 70));

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
    return request;
  }

  @override
  Future<BaseResponse> interceptResponse({required BaseResponse response}) async {
    return response;
  }
}

bool isCloudflare(BaseResponse response) {
  final server = response.headers["server"]?.toLowerCase() ?? '';
  final isBlockedStatus = [403, 503].contains(response.statusCode);
  final isCfServer = server.contains("cloudflare");
  debugPrint('[MClient] Response ${response.statusCode} server="$server" isCloudflare=${isBlockedStatus && isCfServer}');
  return isBlockedStatus && isCfServer;
}

class ResolveCloudFlareChallenge extends RetryPolicy {
  final bool showCloudFlareError;
  ResolveCloudFlareChallenge(this.showCloudFlareError);

  @override
  int get maxRetryAttempts => 2;

  @override
  Future<bool> shouldAttemptRetryOnResponse(BaseResponse response) async {
    if (!showCloudFlareError) return false;
    if (!isCloudflare(response)) return false;
    final url = response.request!.url.toString();
    debugPrint('[MClient] Cloudflare detected for $url — attempting bypass');

    final proxyUrl = MClient.normalizeProxyUrl(MClient.cfProxyUrl.trim());
    if (proxyUrl.isNotEmpty) {
      debugPrint('[MClient] Using CF proxy: $proxyUrl');
      return _solveWithCfProxy(proxyUrl, url);
    }
    debugPrint('[MClient] No CF proxy configured — bypass skipped');
    return false;
  }
}

Future<bool> _solveWithCfProxy(String proxyUrl, String targetUrl) async {
  try {
    debugPrint('[MClient] POSTing to $proxyUrl for $targetUrl');
    final res = await http.post(
      Uri.parse(proxyUrl),
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: jsonEncode({
        'cmd': 'request.get',
        'url': targetUrl,
        'maxTimeout': 60000,
      }),
    ).timeout(const Duration(seconds: 70));

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
