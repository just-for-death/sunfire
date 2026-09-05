import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../db/isar_service.dart';
import '../db/models/manga.dart';
import '../engine/quickjs_service.dart';
import '../sync/graphql_client_service.dart';

class ImageCacheHelper {
  static final List<String> _candidateCoverPaths = [];
  static final LinkedHashMap<String, Uint8List> _memoryCache = LinkedHashMap<String, Uint8List>();
  static final Map<String, Future<Uint8List?>> _inFlightFetches = {};
  static final Map<int, String> _resolvedPaths = {};

  static Future<void> initialize() async {
    try {
      PaintingBinding.instance.imageCache.maximumSize = 1000;
      PaintingBinding.instance.imageCache.maximumSizeBytes = 128 * 1024 * 1024; // 128MB

      final paths = <String>[];
      try {
        final appSupportDir = await getApplicationSupportDirectory();
        paths.add('${appSupportDir.path}/covers');
      } catch (_) {}
      try {
        final appDir = await getApplicationDocumentsDirectory();
        paths.add('${appDir.path}/covers');
      } catch (_) {}

      // Common Linux user paths
      if (!kIsWeb && Platform.isLinux) {
        final home = Platform.environment['HOME'];
        if (home != null) {
          paths.add('$home/Documents/covers');
          paths.add('$home/.local/share/com.sunfire.sunfire/covers');
          paths.add('$home/.local/share/sunfire/covers');
        }
      }

      for (final p in paths) {
        if (!_candidateCoverPaths.contains(p)) {
          _candidateCoverPaths.add(p);
          try {
            final dir = Directory(p);
            if (!await dir.exists()) {
              await dir.create(recursive: true);
            }
          } catch (_) {}
        }
      }
    } catch (_) {}
  }

  static String? getLocalCoverPath(int mangaServerId) {
    if (mangaServerId <= 0) return null;
    for (final basePath in _candidateCoverPaths) {
      final f = File('$basePath/$mangaServerId.jpg');
      if (f.existsSync() && f.lengthSync() > 100) {
        return f.path;
      }
    }
    return null;
  }

  static String? getLocalCoverPathForUrl(String url) {
    if (url.isEmpty) return null;
    final hash = url.hashCode.abs().toString();
    for (final basePath in _candidateCoverPaths) {
      final f = File('$basePath/url_$hash.jpg');
      if (f.existsSync() && f.lengthSync() > 100) {
        return f.path;
      }
    }
    return null;
  }

  static Uint8List? getMemoryCover(String url) {
    return _memoryCache[url];
  }

  static Future<void> clearCache() async {
    _memoryCache.clear();
    for (final basePath in _candidateCoverPaths) {
      try {
        final dir = Directory(basePath);
        if (await dir.exists()) {
          final files = await dir.list().toList();
          for (final f in files) {
            await f.delete();
          }
        }
      } catch (_) {}
    }
  }

  static Future<Uint8List?> fetchImageBytes(
    String url, {
    String sourceName = '',
    int mangaServerId = 0,
  }) async {
    var effectiveUrl = url;
    if (effectiveUrl.isEmpty && mangaServerId > 0 && GraphQLClientService.instance.isConfigured) {
      effectiveUrl = '${GraphQLClientService.instance.baseUrl}/api/v1/manga/$mangaServerId/thumbnail';
    }
    if (effectiveUrl.isEmpty) return null;
    if (_memoryCache.containsKey(effectiveUrl)) return _memoryCache[effectiveUrl];

    // Check disk cache first across all candidate directories (by ID or URL hash)
    final localPath = getLocalCoverPath(mangaServerId) ?? getLocalCoverPathForUrl(effectiveUrl);
    if (localPath != null) {
      try {
        final bytes = await File(localPath).readAsBytes();
        _memoryCache[effectiveUrl] = bytes;
        if (_memoryCache.length > 200) _memoryCache.remove(_memoryCache.keys.first);
        return bytes;
      } catch (_) {}
    }

    if (_inFlightFetches.containsKey(effectiveUrl)) return _inFlightFetches[effectiveUrl];
    
    final completer = _inFlightFetches[effectiveUrl] = _doFetch(effectiveUrl, sourceName, mangaServerId);
    try {
      final res = await completer;
      return res;
    } finally {
      _inFlightFetches.remove(effectiveUrl);
    }
  }

  static bool _isValidImageBytes(List<int> b) {
    if (b.length < 12) return false;
    // JPEG: FF D8
    if (b[0] == 0xFF && b[1] == 0xD8) return true;
    // PNG: 89 50 4E 47
    if (b[0] == 0x89 && b[1] == 0x50 && b[2] == 0x4E && b[3] == 0x47) return true;
    // WebP: RIFF ... WEBP
    if (b[0] == 0x52 && b[1] == 0x49 && b[2] == 0x46 && b[3] == 0x46 &&
        b[8] == 0x57 && b[9] == 0x45 && b[10] == 0x42 && b[11] == 0x50) {
      return true;
    }
    // GIF: GIF87a / GIF89a
    if (b[0] == 0x47 && b[1] == 0x49 && b[2] == 0x46) return true;
    // BMP: 42 4D
    if (b[0] == 0x42 && b[1] == 0x4D) return true;
    // Reject HTML/XML/JSON error responses (<, {, [)
    if (b[0] == 60 || b[0] == 123 || b[0] == 91) return false;
    return b.length > 500;
  }

  static Future<Uint8List?> _attemptHttpFetch(String url, Map<String, String> headers) async {
    HttpClient? client;
    try {
      final uri = Uri.tryParse(url) ?? Uri.tryParse(Uri.encodeFull(url));
      if (uri == null) return null;

      client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);
      client.badCertificateCallback = (_, __, ___) => true;
      final req = await client.getUrl(uri);
      
      final reqHeaders = Map<String, String>.from(headers);
      if (GraphQLClientService.instance.isConfigured &&
          GraphQLClientService.instance.baseUrl != null &&
          url.startsWith(GraphQLClientService.instance.baseUrl!)) {
        reqHeaders.addAll(GraphQLClientService.instance.authHeaders);
      }

      reqHeaders.forEach((k, v) => req.headers.set(k, v));
      final resp = await req.close();
      if (resp.statusCode == 200) {
        final b = await resp.fold<List<int>>([], (p, c) => p..addAll(c));
        if (_isValidImageBytes(b)) {
          return Uint8List.fromList(b);
        }
      }
    } catch (_) {
    } finally {
      client?.close(force: true);
    }
    return null;
  }

  static Future<Uint8List?> _doFetch(String url, String sourceName, int mangaServerId) async {
    try {
      Uint8List? bytes;

      // PASS 0: Proactive Extension Direct Cover Resolution
      // If URL is empty or points to the Suwayomi server proxy (/api/v1/manga/),
      // immediately query the local JS extension for the direct CDN URL.
      // This prevents hitting the server proxy (which returns HTTP 500 when Cloudflare-blocked upstream).
      if ((url.isEmpty || url.contains('/api/v1/manga/')) && mangaServerId > 0 && IsarService.instance.isInitialized) {
        try {
          final isar = IsarService.instance.isar;
          final m = isar.mangas.filter().serverIdEqualTo(mangaServerId).findFirstSync();
          final effectiveSource = (m != null && m.sourceName.isNotEmpty) ? m.sourceName : sourceName;
          if (m != null && effectiveSource.isNotEmpty && QuickJsService.instance.hasExtension(effectiveSource)) {
            String? directCover;
            if (m.url.isNotEmpty) {
              directCover = QuickJsService.instance.getExtensionCoverUrl(effectiveSource, m.url);
            }
            if (directCover == null || directCover.isEmpty) {
              final targetQuery = m.url.isNotEmpty ? m.url : m.title;
              final details = await QuickJsService.instance.fetchMangaDetailsLocal(effectiveSource, targetQuery);
              directCover = details['imageUrl'] as String?;
            }
            if (directCover != null && directCover.isNotEmpty && directCover.startsWith('http')) {
              final extHeaders = QuickJsService.getImageHeaders(effectiveSource, directCover);
              bytes = await _attemptHttpFetch(directCover, extHeaders);
              if (bytes == null && extHeaders.containsKey('Referer')) {
                final noRef = Map<String, String>.from(extHeaders)..remove('Referer');
                bytes = await _attemptHttpFetch(directCover, noRef);
              }
              if (bytes != null && bytes.length > 200) {
                try {
                  await isar.writeTxn(() async {
                    m.thumbnailUrl = directCover;
                    await isar.mangas.put(m);
                  });
                } catch (_) {}
                url = directCover;
              }
            }
          }
        } catch (_) {}
      }

      // PASS 1: Standard fetch with configured headers
      final headers = QuickJsService.getImageHeaders(sourceName, url);
      bytes ??= await _attemptHttpFetch(url, headers);

      // PASS 2 (Self-Healing Anti-Hotlink): If failed and Referer was present, retry with NO Referer!
      // Fixes any CDN enforcing strict anti-hotlink protection
      if (bytes == null && headers.containsKey('Referer')) {
        final noRefererHeaders = Map<String, String>.from(headers)..remove('Referer');
        bytes = await _attemptHttpFetch(url, noRefererHeaders);
      }

      // PASS 3 (Self-Healing Origin Referer): If failed and had no Referer, retry with Origin Referer!
      // Fixes CDNs requiring same-origin domain Referer
      if (bytes == null) {
        try {
          final uri = Uri.parse(url);
          final originReferer = '${uri.origin}/';
          if (headers['Referer'] != originReferer) {
            final originHeaders = Map<String, String>.from(headers)..['Referer'] = originReferer;
            bytes = await _attemptHttpFetch(url, originHeaders);
          }
        } catch (_) {}
      }

      // PASS 4 (Self-Healing Clean Browser): Retry with standard Chrome Desktop UA and Image Accept headers
      if (bytes == null) {
        final browserHeaders = Map<String, String>.from(headers)
          ..['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36'
          ..['Accept'] = 'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8';
        bytes = await _attemptHttpFetch(url, browserHeaders);
      }

      // PASS 5: Fallback on desktop with curl-impersonate / curl binaries to bypass TLS fingerprint blocks
      if (bytes == null && !kIsWeb && (Platform.isLinux || Platform.isMacOS || Platform.isWindows)) {
        final candidates = ['/usr/bin/curl-impersonate', 'curl-impersonate', 'curl-impersonate-chrome', '/usr/bin/curl', 'curl'];
        for (final exe in candidates) {
          try {
            final args = <String>['-s', '-L', '--max-time', '15'];
            headers.forEach((k, v) => args.addAll(['-H', '$k: $v']));
            args.add(url);
            final res = await Process.run(exe, args, stdoutEncoding: null);
            if (res.exitCode == 0) {
              final b = res.stdout as List<int>;
              if (_isValidImageBytes(b)) {
                bytes = Uint8List.fromList(b);
                break;
              }
            }
          } catch (_) {}
        }
      }

      // PASS 6: Suwayomi server proxy fallback (for server-synced manga whose remote CDN is blocked or 403)
      if (bytes == null && mangaServerId > 0 && GraphQLClientService.instance.isConfigured) {
        final serverUrl = GraphQLClientService.instance.baseUrl;
        if (serverUrl != null && serverUrl.isNotEmpty && !url.startsWith(serverUrl)) {
          final serverThumbUrl = '$serverUrl/api/v1/manga/$mangaServerId/thumbnail';
          final serverHeaders = Map<String, String>.from(GraphQLClientService.instance.authHeaders);
          bytes = await _attemptHttpFetch(serverThumbUrl, serverHeaders);
        }
      }

      // PASS 7: Extension-Driven Cover Resolution
      // When server proxy returns empty/500 (e.g. Suwayomi blocked upstream by Cloudflare)
      // or remote URL fails, query the local extension for this source to resolve the authentic direct CDN cover URL.
      if (bytes == null && mangaServerId > 0 && IsarService.instance.isInitialized) {
        try {
          final isar = IsarService.instance.isar;
          final m = isar.mangas.filter().serverIdEqualTo(mangaServerId).findFirstSync();
          final effectiveSource = (m != null && m.sourceName.isNotEmpty) ? m.sourceName : sourceName;
          if (m != null && effectiveSource.isNotEmpty && QuickJsService.instance.hasExtension(effectiveSource)) {
            String? realCoverUrl;
            if (m.url.isNotEmpty) {
              realCoverUrl = QuickJsService.instance.getExtensionCoverUrl(effectiveSource, m.url);
            }
            if (realCoverUrl == null || realCoverUrl.isEmpty) {
              final targetQuery = m.url.isNotEmpty ? m.url : m.title;
              final details = await QuickJsService.instance.fetchMangaDetailsLocal(effectiveSource, targetQuery);
              realCoverUrl = details['imageUrl'] as String?;
            }
            if (realCoverUrl != null && realCoverUrl.isNotEmpty && realCoverUrl.startsWith('http')) {
              final extHeaders = QuickJsService.getImageHeaders(effectiveSource, realCoverUrl);
              bytes = await _attemptHttpFetch(realCoverUrl, extHeaders);
              if (bytes == null && extHeaders.containsKey('Referer')) {
                final noRef = Map<String, String>.from(extHeaders)..remove('Referer');
                bytes = await _attemptHttpFetch(realCoverUrl, noRef);
              }
              if (bytes != null && bytes.length > 200) {
                try {
                  await isar.writeTxn(() async {
                    m.thumbnailUrl = realCoverUrl;
                    await isar.mangas.put(m);
                  });
                } catch (_) {}
                _memoryCache[realCoverUrl] = bytes;
              }
            }
          }
        } catch (_) {}
      }

      if (bytes != null && bytes.length > 200) {
        _memoryCache[url] = bytes;
        if (_memoryCache.length > 200) _memoryCache.remove(_memoryCache.keys.first);
        if (_candidateCoverPaths.isNotEmpty) {
          final basePath = _candidateCoverPaths.first;
          try {
            if (mangaServerId > 0) {
              final file = File('$basePath/$mangaServerId.jpg');
              await file.writeAsBytes(bytes);
              _resolvedPaths[mangaServerId] = file.path;
            }
            final urlFile = File('$basePath/url_${url.hashCode.abs()}.jpg');
            await urlFile.writeAsBytes(bytes);
          } catch (_) {}
        }
        return bytes;
      }
    } catch (_) {}
    return null;
  }

  static Future<void> cacheThumbnail(int mangaServerId, String url, {String sourceName = ''}) async {
    await fetchImageBytes(url, sourceName: sourceName, mangaServerId: mangaServerId);
  }
}

class MangaCoverImage extends StatefulWidget {
  final int mangaServerId;
  final String? thumbnailUrl;
  final String? sourceName;
  final double? width;
  final double? height;
  final BoxFit fit;

  const MangaCoverImage({
    super.key,
    required this.mangaServerId,
    this.thumbnailUrl,
    this.sourceName,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  State<MangaCoverImage> createState() => _MangaCoverImageState();
}

class _MangaCoverImageState extends State<MangaCoverImage> {
  Uint8List? _recoveredBytes;

  @override
  void initState() {
    super.initState();
    _checkAndFetch();
  }

  @override
  void didUpdateWidget(covariant MangaCoverImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.thumbnailUrl != widget.thumbnailUrl || oldWidget.mangaServerId != widget.mangaServerId) {
      _recoveredBytes = null;
      _checkAndFetch();
    }
  }

  void _checkAndFetch() {
    var url = widget.thumbnailUrl;
    if (widget.mangaServerId > 0 && IsarService.instance.isInitialized) {
      try {
        final m = IsarService.instance.isar.mangas.filter().serverIdEqualTo(widget.mangaServerId).findFirstSync();
        if (m != null) {
          if (m.thumbnailUrl != null && m.thumbnailUrl!.isNotEmpty && !m.thumbnailUrl!.contains('/api/v1/manga/')) {
            url = m.thumbnailUrl;
          } else if (m.sourceName.isNotEmpty && m.url.isNotEmpty) {
            final extCover = QuickJsService.instance.getExtensionCoverUrl(m.sourceName, m.url);
            if (extCover != null && extCover.isNotEmpty) {
              url = extCover;
              IsarService.instance.isar.writeTxn(() async {
                m.thumbnailUrl = extCover;
                await IsarService.instance.isar.mangas.put(m);
              });
            }
          }
        }
      } catch (_) {}
    }
    if ((url == null || url.isEmpty) && widget.mangaServerId > 0 && GraphQLClientService.instance.isConfigured) {
      url = '${GraphQLClientService.instance.baseUrl}/api/v1/manga/${widget.mangaServerId}/thumbnail';
    }
    if (url == null || url.isEmpty) return;

    final mem = ImageCacheHelper.getMemoryCover(url);
    if (mem != null) {
      _recoveredBytes = mem;
      return;
    }

    final localPath = ImageCacheHelper.getLocalCoverPath(widget.mangaServerId) ??
        ImageCacheHelper.getLocalCoverPathForUrl(url);
    if (localPath != null) return;

    // Start background fetch to disk/memory
    ImageCacheHelper.fetchImageBytes(
      url,
      sourceName: widget.sourceName ?? '',
      mangaServerId: widget.mangaServerId,
    ).then((bytes) {
      if (bytes != null && mounted) {
        setState(() => _recoveredBytes = bytes);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var url = widget.thumbnailUrl;
    if (widget.mangaServerId > 0 && IsarService.instance.isInitialized) {
      try {
        final m = IsarService.instance.isar.mangas.filter().serverIdEqualTo(widget.mangaServerId).findFirstSync();
        if (m != null) {
          if (m.thumbnailUrl != null && m.thumbnailUrl!.isNotEmpty && !m.thumbnailUrl!.contains('/api/v1/manga/')) {
            url = m.thumbnailUrl;
          } else if (m.sourceName.isNotEmpty && m.url.isNotEmpty) {
            final extCover = QuickJsService.instance.getExtensionCoverUrl(m.sourceName, m.url);
            if (extCover != null && extCover.isNotEmpty) {
              url = extCover;
            }
          }
        }
      } catch (_) {}
    }
    if ((url == null || url.isEmpty) && widget.mangaServerId > 0 && GraphQLClientService.instance.isConfigured) {
      url = '${GraphQLClientService.instance.baseUrl}/api/v1/manga/${widget.mangaServerId}/thumbnail';
    }

    final dpr = MediaQuery.of(context).devicePixelRatio;
    final int targetCacheWidth = widget.width != null && widget.width!.isFinite ? (widget.width! * dpr).clamp(100.0, 600.0).round() : 360;
    final int targetCacheHeight = widget.height != null && widget.height!.isFinite ? (widget.height! * dpr).clamp(150.0, 900.0).round() : 520;

    // 1. Render from memory if recovered
    if (_recoveredBytes != null) {
      return Image.memory(
        _recoveredBytes!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        cacheWidth: targetCacheWidth,
        cacheHeight: targetCacheHeight,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }

    // 2. Render from local file if cached (by ID or URL hash)
    final localPath = ImageCacheHelper.getLocalCoverPath(widget.mangaServerId) ??
        (url != null ? ImageCacheHelper.getLocalCoverPathForUrl(url) : null);
    if (localPath != null) {
      return Image.file(
        File(localPath),
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        cacheWidth: targetCacheWidth,
        cacheHeight: targetCacheHeight,
        gaplessPlayback: true,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            child: child,
          );
        },
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }

    // 3. Render from Network with headers
    if (url != null && url.isNotEmpty) {
      final effectiveSource = widget.sourceName ?? '';
      final headers = QuickJsService.getImageHeaders(effectiveSource, url);
      final effectiveHeaders = Map<String, String>.from(headers);
      if (GraphQLClientService.instance.isConfigured &&
          GraphQLClientService.instance.baseUrl != null &&
          url.startsWith(GraphQLClientService.instance.baseUrl!)) {
        effectiveHeaders.addAll(GraphQLClientService.instance.authHeaders);
      }

      return Image.network(
        url,
        headers: effectiveHeaders,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        cacheWidth: targetCacheWidth,
        cacheHeight: targetCacheHeight,
        gaplessPlayback: true,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            child: child,
          );
        },
        errorBuilder: (context, error, stackTrace) {
          // On network error (e.g. 403 CDN), trigger robust fallback fetch
          ImageCacheHelper.fetchImageBytes(
            url!,
            sourceName: effectiveSource,
            mangaServerId: widget.mangaServerId,
          ).then((bytes) {
            if (bytes != null && mounted) {
              setState(() => _recoveredBytes = bytes);
            }
          });
          return _fallback();
        },
      );
    }

    return _fallback();
  }

  Widget _fallback() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: const Color(0xFF26262B),
      child: const Center(
        child: Icon(Icons.book_rounded, color: Colors.grey, size: 28),
      ),
    );
  }
}
