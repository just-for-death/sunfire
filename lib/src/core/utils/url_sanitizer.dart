/// URL sanitization utilities for safe logging.
/// Strips credentials, query parameters, and other sensitive data from URLs
/// before they are written to logs.
library;

/// Sanitizes a URL for safe logging.
/// - Removes user:pass credentials
/// - Removes query parameters and fragment (may contain tokens)
/// - Truncates very long URLs
///
/// Rebuilt from scheme/host/port/path only. `uri.replace(query: '',
/// fragment: '')` (the old approach) left a dangling `?#` on the output
/// (UIX-17).
String sanitizeUrlForLog(String url, {int maxLength = 200}) {
  if (url.isEmpty) return url;

  try {
    final uri = Uri.parse(url);

    final sanitized = Uri(
      scheme: uri.scheme.isEmpty ? null : uri.scheme,
      host: uri.hasAuthority ? uri.host : null,
      port: uri.hasPort ? uri.port : null,
      path: uri.path,
    ).toString();

    if (sanitized.length > maxLength) {
      return '${sanitized.substring(0, maxLength)}...';
    }
    return sanitized;
  } catch (_) {
    // If parsing fails, do basic truncation
    if (url.length > maxLength) {
      return '${url.substring(0, maxLength)}...';
    }
    return url;
  }
}
