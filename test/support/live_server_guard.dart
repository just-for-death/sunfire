// ISS-134: code-enforced guard so no test can ever reach Jane's REAL Suwayomi
// (localhost:4567 on Zoro == Tailscale 100.71.46.98).
//
// Live tests may only talk to a throwaway Docker server started by
// tool/start_throwaway_suwayomi.sh, which listens on 127.0.0.1:4590 and writes
// the global-meta marker below. Anything else either throws (unsafe URL /
// missing marker) or returns null (env unset → the caller skips).
import 'dart:convert';
import 'dart:io';

const String kThrowawayMarkerKey = 'sunfire_throwaway_marker';
const String kThrowawayMarkerValue = 'sunfire-throwaway-docker-v1';
const String kThrowawayDefaultUrl = 'http://127.0.0.1:4590';

class UnsafeTestServerError extends Error {
  UnsafeTestServerError(this.message);
  final String message;
  @override
  String toString() => 'UnsafeTestServerError: $message';
}

bool _isTailscaleCgnat(InternetAddress a) {
  if (a.type != InternetAddressType.IPv4) return false;
  final b = a.rawAddress;
  return b[0] == 100 && (b[1] & 0xC0) == 64; // 100.64.0.0/10
}

/// Static (offline) checks. Throws [UnsafeTestServerError] for:
/// 100.71.46.98, any 100.64.0.0/10 address, port 4567 on any host, and any
/// host that is not loopback.
void assertSafeTestServerUrl(String url) {
  final uri = Uri.tryParse(url.trim());
  if (uri == null || uri.host.isEmpty) throw UnsafeTestServerError('unparseable test server url "$url"');
  final host = uri.host.toLowerCase();
  final port = uri.hasPort ? uri.port : (uri.scheme == 'https' ? 443 : 80);
  if (host == '100.71.46.98') throw UnsafeTestServerError('$url is Jane\'s REAL Suwayomi server');
  final ip = InternetAddress.tryParse(host);
  if (ip != null && _isTailscaleCgnat(ip)) throw UnsafeTestServerError('$url is a Tailscale (100.64.0.0/10) address');
  if (port == 4567) throw UnsafeTestServerError('$url uses port 4567 (the real server\'s port on Zoro)');
  final loopback = host == 'localhost' || (ip != null && ip.isLoopback);
  if (!loopback) throw UnsafeTestServerError('$url is not a loopback host; live tests run only against local Docker');
}

/// Returns the throwaway server URL to use, or null when SUNFIRE_LIVE_URL is
/// unset (caller skips). Throws when the URL is unsafe or the server lacks the
/// Docker marker — never silently falls through to another server.
Future<String?> requireThrowawayServer(String? url) async {
  if (url == null || url.trim().isEmpty) return null;
  assertSafeTestServerUrl(url);
  final base = url.trim().replaceAll(RegExp(r'/+$'), '');
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 5);
  try {
    final req = await client.postUrl(Uri.parse('$base/api/graphql'));
    req.headers.contentType = ContentType.json;
    req.write(jsonEncode({'query': '{ meta(key: "$kThrowawayMarkerKey") { value } }'}));
    final res = await req.close().timeout(const Duration(seconds: 10));
    final body = await res.transform(utf8.decoder).join();
    final value = ((jsonDecode(body) as Map)['data'] as Map?)?['meta']?['value'];
    if (value != kThrowawayMarkerValue) {
      throw UnsafeTestServerError('$base has no throwaway marker ($kThrowawayMarkerKey); '
          'start it with tool/start_throwaway_suwayomi.sh');
    }
    return base;
  } on UnsafeTestServerError {
    rethrow;
  } catch (e) {
    throw UnsafeTestServerError('throwaway marker probe failed for $base: $e');
  } finally {
    client.close(force: true);
  }
}
