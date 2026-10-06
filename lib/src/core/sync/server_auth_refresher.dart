// Hook interface between the transport layers (GraphQL HTTP + WebSocket) and
// the login/JWT session (ISS-078 B2). Kept in its own Flutter-free file so the
// transports do not import the session service (and vice versa) directly.

/// Supplies session credentials to the transports and refreshes them.
///
/// Implemented by `ServerSessionService`. When no session is active every
/// method is a no-op, so the stored Basic / Bearer header keeps working.
abstract class ServerAuthRefresher {
  /// Authorization header that must replace the stored (Basic/Bearer) one for
  /// [baseUrl], or null to keep the stored header.
  String? authHeaderOverride(String baseUrl);

  /// Extra headers for [baseUrl] (e.g. the SIMPLE_LOGIN session `Cookie`).
  Map<String, String> extraHeaders(String baseUrl);

  /// Called before every request; refreshes proactively near expiry.
  /// Must never throw.
  Future<void> beforeRequest();

  /// Called after a 401/403 or a GraphQL auth error. Returns true when fresh
  /// credentials were applied (the caller then retries the request once).
  /// Must never throw.
  Future<bool> onUnauthorized();
}
