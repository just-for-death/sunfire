import 'dart:convert';
import 'package:flutter_qjs/flutter_qjs.dart';
import 'package:http/http.dart' as http;
import 'package:http_interceptor/http_interceptor.dart';
import 'm_client.dart';

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

  void init() {
    runtime.onMessage('http_head', (dynamic args) async {
      return await _toHttpResponse(_getClient(args[1]), "HEAD", args);
    });
    runtime.onMessage('http_get', (dynamic args) async {
      return await _toHttpResponse(_getClient(args[1]), "GET", args);
    });
    runtime.onMessage('http_post', (dynamic args) async {
      return await _toHttpResponse(_getClient(args[1]), "POST", args);
    });
    runtime.onMessage('http_put', (dynamic args) async {
      return await _toHttpResponse(_getClient(args[1]), "PUT", args);
    });
    runtime.onMessage('http_delete', (dynamic args) async {
      return await _toHttpResponse(_getClient(args[1]), "DELETE", args);
    });
    runtime.onMessage('http_patch', (dynamic args) async {
      return await _toHttpResponse(_getClient(args[1]), "PATCH", args);
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
    try {
      final List<dynamic> params = args is String ? jsonDecode(args) : args;
      urlStr = params[2].toString().trim();
      final Map<String, dynamic> rawHeaders = params[3] is Map ? Map<String, dynamic>.from(params[3]) : {};
      final dynamic body = params.length > 4 ? params[4] : null;

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
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.9',
      };

      rawHeaders.forEach((k, v) {
        if (v != null) headers[k.toString()] = v.toString();
      });

      final uri = Uri.parse(urlStr);
      http.Response response;

      const requestTimeout = Duration(seconds: 25);
      switch (method.toUpperCase()) {
        case 'GET':
          response = await client.get(uri, headers: headers).timeout(requestTimeout);
          break;
        case 'POST':
          response = await client.post(
            uri,
            headers: headers,
            body: body is Map ? jsonEncode(body) : body,
          ).timeout(requestTimeout);
          break;
        case 'HEAD':
          response = await client.head(uri, headers: headers).timeout(requestTimeout);
          break;
        case 'PUT':
          response = await client.put(uri, headers: headers, body: body).timeout(requestTimeout);
          break;
        case 'DELETE':
          response = await client.delete(uri, headers: headers, body: body).timeout(requestTimeout);
          break;
        case 'PATCH':
          response = await client.patch(uri, headers: headers, body: body).timeout(requestTimeout);
          break;
        default:
          response = await client.get(uri, headers: headers).timeout(requestTimeout);
      }

      // If Cloudflare block was received (403/503 with Cloudflare headers), attempt direct FlareSolverr fetch
      if (isCloudflare(response) && urlStr.startsWith('http')) {
        if (MClient.cfProxyUrl.isNotEmpty) {
          final solved = await MClient.solveAndFetchWithProxy(urlStr);
          if (solved != null) {
            return jsonEncode(solved);
          }
        }
      }

      return jsonEncode({
        'body': response.body,
        'statusCode': response.statusCode,
        'headers': response.headers,
        'request': {'url': response.request?.url.toString() ?? urlStr}
      });
    } catch (e) {
      if (urlStr.startsWith('http') && MClient.cfProxyUrl.isNotEmpty) {
        final solved = await MClient.solveAndFetchWithProxy(urlStr);
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
    for (final client in _clientCache.values) {
      client.close();
    }
    _clientCache.clear();
  }
}
