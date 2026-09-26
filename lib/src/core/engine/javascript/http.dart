import 'dart:convert';
import 'package:flutter_qjs/flutter_qjs.dart';
import 'package:http/http.dart' as http;
import 'package:http_interceptor/http_interceptor.dart';
import '../../../constants/app_constants.dart';
import '../../logging/logger_service.dart';
import '../../services/settings_service.dart';
import 'm_client.dart';
import 'request_guard.dart';

class JsHttpClient {
  final JavascriptRuntime runtime;
  final String baseUrl;
  final Map<String, InterceptedClient> _clientCache = {};

  JsHttpClient(this.runtime, [this.baseUrl = '']);

  InterceptedClient _getClient(dynamic reqcopyWith) {
    final map = (reqcopyWith as Map?)?.map((k, v) => MapEntry(k.toString(), v));
    return _clientCache.putIfAbsent(
      jsonEncode(map ?? const <String, dynamic>{}),
      () => MClient.init(reqcopyWith: map),
    );
  }

  bool _isDisposed = false;
  bool get isDisposed => _isDisposed;
  int _activeHttpRequests = 0;
  int get activeHttpRequests => _activeHttpRequests;
  void Function()? onAllRequestsFinished;

  Future<String> _safeHandle(Future<String> Function() action) async {
    if (_isDisposed) return jsonEncode({'body': '', 'statusCode': 500, 'headers': {}, 'error': 'disposed'});
    _activeHttpRequests++;
    try {
      final res = await action();
      if (_isDisposed) return jsonEncode({'body': '', 'statusCode': 500, 'headers': {}, 'error': 'disposed'});
      return res;
    } catch (e) {
      if (_isDisposed || e.toString().contains('JSValue released')) {
        return jsonEncode({'body': '', 'statusCode': 500, 'headers': {}, 'error': 'disposed'});
      }
      rethrow;
    } finally {
      _activeHttpRequests--;
      if (_isDisposed && _activeHttpRequests <= 0 && onAllRequestsFinished != null) {
        final cb = onAllRequestsFinished;
        onAllRequestsFinished = null;
        cb?.call();
      }
    }
  }

  void init() {
    runtime.onMessage('http_head', (dynamic args) async {
      return await _safeHandle(() => _toHttpResponse(_getClient(args[1]), "HEAD", args));
    });
    runtime.onMessage('http_get', (dynamic args) async {
      return await _safeHandle(() => _toHttpResponse(_getClient(args[1]), "GET", args));
    });
    runtime.onMessage('http_post', (dynamic args) async {
      return await _safeHandle(() => _toHttpResponse(_getClient(args[1]), "POST", args));
    });
    runtime.onMessage('http_put', (dynamic args) async {
      return await _safeHandle(() => _toHttpResponse(_getClient(args[1]), "PUT", args));
    });
    runtime.onMessage('http_delete', (dynamic args) async {
      return await _safeHandle(() => _toHttpResponse(_getClient(args[1]), "DELETE", args));
    });
    runtime.onMessage('http_patch', (dynamic args) async {
      return await _safeHandle(() => _toHttpResponse(_getClient(args[1]), "PATCH", args));
    });

    runtime.evaluate('''
class Client {
    constructor(reqcopyWith) {
        this.reqcopyWith = reqcopyWith;
    }
    async head(url, headers) {
        const result = await sendMessage(
            "http_head",
            JSON.stringify([null, this.reqcopyWith, url, headers || {}])
        );
        return JSON.parse(result);
    }
    async get(url, headers) {
        const result = await sendMessage(
            "http_get",
            JSON.stringify([null, this.reqcopyWith, url, headers || {}])
        );
        return JSON.parse(result);
    }
    async post(url, headers, body) {
        const result = await sendMessage(
            "http_post",
            JSON.stringify([null, this.reqcopyWith, url, headers || {}, body])
        );
        return JSON.parse(result);
    }
    async put(url, headers, body) {
        const result = await sendMessage(
            "http_put",
            JSON.stringify([null, this.reqcopyWith, url, headers || {}, body])
        );
        return JSON.parse(result);
    }
    async delete(url, headers, body) {
        const result = await sendMessage(
            "http_delete",
            JSON.stringify([null, this.reqcopyWith, url, headers || {}, body])
        );
        return JSON.parse(result);
    }
    async patch(url, headers, body) {
        const result = await sendMessage(
            "http_patch",
            JSON.stringify([null, this.reqcopyWith, url, headers || {}, body])
        );
        return JSON.parse(result);
    }
}
''');
  }

  Future<String> _toHttpResponse(http.Client client, String method, dynamic args) async {
    String urlStr = '';
    dynamic reqBody;
    try {
      final List<dynamic> params = args is String ? jsonDecode(args) : args;
      urlStr = params[2].toString().trim();
      final Map<String, dynamic> rawHeaders = params[3] is Map ? Map<String, dynamic>.from(params[3]) : {};
      reqBody = params.length > 4 ? params[4] : null;
      final dynamic body = reqBody;

      if (urlStr.startsWith('//')) {
        urlStr = 'https:$urlStr';
      } else if (!urlStr.startsWith('http://') && !urlStr.startsWith('https://')) {
        if (baseUrl.isNotEmpty) {
          final cleanBase = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
          final cleanPath = urlStr.startsWith('/') ? urlStr : '/$urlStr';
          urlStr = '$cleanBase$cleanPath';
        }
      }

      // Clean up duplicate domain concatenation if any
      final dupMatch = RegExp(r'^(https?://[^/]+)(https?://.*)$').firstMatch(urlStr);
      if (dupMatch != null) {
        urlStr = dupMatch.group(2)!;
      }

      final headers = <String, String>{
        'User-Agent': kBrowserUserAgent,
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.9',
      };

      rawHeaders.forEach((k, v) {
        if (v != null) headers[k.toString()] = v.toString();
      });

      final contentType = headers.entries.firstWhere(
        (e) => e.key.toLowerCase() == 'content-type',
        orElse: () => const MapEntry('', ''),
      ).value.toLowerCase();

      dynamic effectiveBody = body;
      if (body is Map) {
        if (contentType.contains('json')) {
          effectiveBody = jsonEncode(body);
        } else {
          effectiveBody = body.map((k, v) => MapEntry(k.toString(), v?.toString() ?? ''));
        }
      }

      final uri = Uri.parse(urlStr);

      // Trust boundary. This client is injected as a global into the QuickJS
      // context and the full response body is handed back to the script, so it
      // is a read primitive with an exfiltration channel, granted to code the
      // app auto-installs from a repo index with no user review.
      //
      // A scraper is supposed to talk to the manga site it was written for.
      // Without this check it could equally read the cloud metadata endpoint,
      // loopback, or any host on the user's LAN — a NAS, a router admin panel,
      // a Jellyfin, or the user's own FlareSolverr — and POST the contents
      // somewhere public. Everything below is reachable by anyone who can get
      // an extension published.
      final blocked = blockedRequestReason(uri);
      if (blocked != null) {
        LoggerService.instance.logWarning(
          'Blocked extension HTTP request to $urlStr: $blocked',
          'JsHttpClient',
        );
        return jsonEncode({
          'body': '',
          'statusCode': 0,
          'error': 'blocked: $blocked',
        });
      }

      http.Response response;

      final timeoutSecs = SettingsService.instance.networkTimeoutSeconds;
      final requestTimeout = Duration(seconds: timeoutSecs > 0 ? timeoutSecs : 30);
      final upperMethod = method.toUpperCase();
      switch (upperMethod) {
        case 'GET':
          response = await client.get(uri, headers: headers).timeout(requestTimeout);
          break;
        case 'POST':
          response = await client.post(
            uri,
            headers: headers,
            body: effectiveBody,
          ).timeout(requestTimeout);
          break;
        case 'HEAD':
          response = await client.head(uri, headers: headers).timeout(requestTimeout);
          break;
        case 'PUT':
          response = await client.put(
            uri,
            headers: headers,
            body: effectiveBody,
          ).timeout(requestTimeout);
          break;
        case 'DELETE':
          response = await client.delete(
            uri,
            headers: headers,
            body: effectiveBody,
          ).timeout(requestTimeout);
          break;
        case 'PATCH':
          response = await client.patch(
            uri,
            headers: headers,
            body: effectiveBody,
          ).timeout(requestTimeout);
          break;
        default:
          response = await client.get(uri, headers: headers).timeout(requestTimeout);
      }

      // If Cloudflare block was received (403/503 with Cloudflare headers), attempt direct FlareSolverr fetch for supported methods (GET/POST)
      if (isCloudflare(response) && urlStr.startsWith('http')) {
        if ((upperMethod == 'GET' || upperMethod == 'POST') && MClient.cfProxyUrl.isNotEmpty) {
          final solved = await MClient.solveAndFetchWithProxy(
            urlStr,
            method: upperMethod,
            postData: effectiveBody,
            headers: headers,
          );
          if (solved != null) {
            return jsonEncode(solved);
          }
        }
      }

      String bodyText;
      try {
        bodyText = utf8.decode(response.bodyBytes, allowMalformed: true);
      } catch (_) {
        bodyText = response.body;
      }

      return jsonEncode({
        'body': bodyText,
        'statusCode': response.statusCode,
        'headers': response.headers,
        'request': {'url': response.request?.url.toString() ?? urlStr}
      });
    } catch (e) {
      if (_isDisposed) {
        return jsonEncode({
          'body': '',
          'statusCode': 500,
          'headers': {},
          'error': 'disposed'
        });
      }
      if (urlStr.startsWith('http') && MClient.cfProxyUrl.isNotEmpty) {
        final solved = await MClient.solveAndFetchWithProxy(
          urlStr,
          method: method,
          postData: reqBody,
          headers: {'User-Agent': kBrowserUserAgent},
        );
        if (_isDisposed) {
          return jsonEncode({
            'body': '',
            'statusCode': 500,
            'headers': {},
            'error': 'disposed'
          });
        }
        if (solved != null) {
          return jsonEncode(solved);
        }
      }
      return jsonEncode({
        'body': '',
        'statusCode': 500,
        'headers': {},
        'error': e.toString()
      });
    }
  }

  void dispose() {
    _isDisposed = true;
    for (final client in _clientCache.values) {
      client.close();
    }
    _clientCache.clear();
  }
}
