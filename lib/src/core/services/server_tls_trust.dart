import 'dart:io';

/// Whether a TLS certificate that fails normal validation (self-signed, private
/// CA) should be accepted for [host].
///
/// Same rule the image loader and download manager already apply: only the
/// user-configured server's host, plus loopback for local dev instances. There
/// is deliberately NO blanket acceptance for private/LAN address ranges — that
/// would permit MITM against arbitrary LAN hosts. Sharing one rule keeps the
/// GraphQL client and WebSocket consistent with images/downloads, which
/// previously accepted a self-signed server cert while sync did not.
///
/// Pure so tests can check it without any network.
bool shouldTrustCertificateForHost(String host, String? serverUrl) {
  if (serverUrl != null && serverUrl.isNotEmpty) {
    final serverHost = Uri.tryParse(serverUrl)?.host;
    if (serverHost != null && serverHost.isNotEmpty && serverHost == host) return true;
  }
  return host == 'localhost' || host == '127.0.0.1' || host == '::1';
}

// Certificate pinning was removed for this release (UIX-06, decision A): the
// previous check only ran inside badCertificateCallback (i.e. for certs that
// already FAILED CA validation) and compared whole-DER hashes against SPKI-style
// pins, so it never protected anything. Real pre-send leaf pinning
// (HttpClient.connectionFactory) is tracked as UIX-06 option B.

/// An [HttpClient] that applies [shouldTrustCertificateForHost] against the
/// server URL returned by [serverUrl] at handshake time (so it follows the
/// server being reconfigured without rebuilding the client).
HttpClient createServerTrustingHttpClient(String? Function() serverUrl) {
  final client = HttpClient();
  client.badCertificateCallback =
      (cert, host, port) => shouldTrustCertificateForHost(host, serverUrl());
  return client;
}
