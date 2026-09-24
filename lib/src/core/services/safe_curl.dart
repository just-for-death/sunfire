/// Helpers for the desktop `curl` shell-out fallbacks.
///
/// URLs come from scrapers/extensions and are therefore untrusted. Passing one
/// as the last argument lets a value starting with `-` be parsed as a curl
/// option (e.g. `-o/path`), so every call must use `--` before the URL, be
/// restricted to http(s), and never carry CR/LF into header values.

/// Executables tried in order. `curl` and `/usr/bin/curl` are the same binary
/// on nearly every system, so only one plain-curl entry is kept.
const List<String> kCurlCandidates = <String>[
  '/usr/bin/curl-impersonate',
  'curl-impersonate',
  'curl-impersonate-chrome',
  'curl',
];

bool isSafeHttpUrl(String url) {
  final u = Uri.tryParse(url);
  if (u == null) return false;
  if (u.scheme != 'http' && u.scheme != 'https') return false;
  if (u.host.isEmpty) return false;
  return !url.contains('\r') && !url.contains('\n');
}

/// Builds a curl argument list, or returns null when [url] is not a safe
/// http(s) URL. Header entries containing line breaks are dropped, as are any
/// names listed in [skipHeaders] (compared case-insensitively).
List<String>? buildCurlArgs({
  required String url,
  required int maxTimeSeconds,
  Map<String, String> headers = const {},
  Set<String> skipHeaders = const {},
}) {
  if (!isSafeHttpUrl(url)) return null;
  final skip = skipHeaders.map((e) => e.toLowerCase()).toSet();
  final args = <String>[
    '-s',
    '-L',
    '--proto',
    '=http,https',
    '--proto-redir',
    '=http,https',
    '--max-time',
    '$maxTimeSeconds',
  ];
  headers.forEach((k, v) {
    if (skip.contains(k.toLowerCase())) return;
    if (k.contains(RegExp(r'[\r\n:]')) || v.contains(RegExp(r'[\r\n]'))) return;
    args.addAll(['-H', '$k: $v']);
  });
  args
    ..add('--')
    ..add(url);
  return args;
}
