/// Helpers for the desktop `curl` shell-out fallbacks.
///
/// URLs come from scrapers/extensions and are therefore untrusted. Passing one
/// as the last argument lets a value starting with `-` be parsed as a curl
/// option (e.g. `-o/path`), so every call must use `--` before the URL, be
/// restricted to http(s), and never carry CR/LF into header values.
library;

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show debugPrint;

import '../engine/image_validation.dart';

/// Executables tried in order. `curl` and `/usr/bin/curl` are the same binary
/// on nearly every system, so only one plain-curl entry is kept.
const List<String> kCurlCandidates = <String>[
  '/usr/bin/curl-impersonate',
  'curl-impersonate',
  'curl-impersonate-chrome',
  'curl',
];

/// Semaphore to limit concurrent curl processes (prevents resource exhaustion
/// when many images fail simultaneously and all fall back to curl).
final _curlSemaphore = _Semaphore(2);

class _Semaphore {
  _Semaphore(this._count);
  int _count;
  final List<Completer<void>> _waiters = [];

  Future<void> acquire() async {
    if (_count > 0) {
      _count--;
      return;
    }
    final completer = Completer<void>();
    _waiters.add(completer);
    return completer.future;
  }

  void release() {
    if (_waiters.isNotEmpty) {
      _waiters.removeAt(0).complete();
    } else {
      _count++;
    }
  }
}

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

/// Runs curl with semaphore-limited concurrency.
/// Returns the stdout bytes on success, null on failure or timeout.
Future<Uint8List?> runCurlWithSemaphore({
  required String url,
  required int maxTimeSeconds,
  Map<String, String> headers = const {},
  Set<String> skipHeaders = const {},
  Duration timeout = const Duration(seconds: 30),
}) async {
  final args = buildCurlArgs(
    url: url,
    maxTimeSeconds: maxTimeSeconds,
    headers: headers,
    skipHeaders: skipHeaders,
  );
  if (args == null) return null;

  await _curlSemaphore.acquire();
  try {
    for (final exe in kCurlCandidates) {
      try {
        final processRes = await Process.run(exe, args, stdoutEncoding: null).timeout(timeout);
        if (processRes.exitCode == 0) {
          final bytes = processRes.stdout as List<int>;
          if (bytes.length > 200 && _isMagicImage(bytes)) {
            return Uint8List.fromList(bytes);
          }
        }
      } catch (e) {
        debugPrint('[safe_curl] Curl fallback error for $exe: $e');
      }
    }
    return null;
  } finally {
    _curlSemaphore.release();
  }
}

/// Delegates to the shared validator.
///
/// This was a private copy that accepted a bare `GIF` prefix and required only
/// two bytes for JPEG, while the downloader's copy required `GIF8` and checked
/// more formats. Three different answers to "is this an image" for the same
/// bytes meant a payload one layer accepted could be rejected by another.
bool _isMagicImage(List<int> bytes) => looksLikeImageHeader(bytes);
