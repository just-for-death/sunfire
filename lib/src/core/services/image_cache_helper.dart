import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../engine/quickjs_service.dart';

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
      if (Platform.isLinux) {
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
    if (url.isEmpty) return null;
    if (_memoryCache.containsKey(url)) return _memoryCache[url];

    // Check disk cache first across all candidate directories
    final localPath = getLocalCoverPath(mangaServerId);
    if (localPath != null) {
      try {
        final bytes = await File(localPath).readAsBytes();
        _memoryCache[url] = bytes;
        if (_memoryCache.length > 200) _memoryCache.remove(_memoryCache.keys.first);
        return bytes;
      } catch (_) {}
    }

    if (_inFlightFetches.containsKey(url)) return _inFlightFetches[url];
    
    final completer = _inFlightFetches[url] = _doFetch(url, sourceName, mangaServerId);
    try {
      final res = await completer;
      return res;
    } finally {
      _inFlightFetches.remove(url);
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

  static Future<Uint8List?> _doFetch(String url, String sourceName, int mangaServerId) async {
    try {
      final headers = QuickJsService.getImageHeaders(sourceName, url);
      Uint8List? bytes;

      // 1. Try standard HttpClient
      try {
        final client = HttpClient();
        
        client.connectionTimeout = const Duration(seconds: 8);
        final req = await client.getUrl(Uri.parse(url));
        headers.forEach((k, v) => req.headers.set(k, v));
        final resp = await req.close();
        if (resp.statusCode == 200) {
          final b = await resp.fold<List<int>>([], (p, c) => p..addAll(c));
          if (_isValidImageBytes(b)) { bytes = Uint8List.fromList(b); }
        }
      } catch (_) {}

      // 2. Fallback on desktop: use curl process to bypass TLS fingerprint blocking from Cloudflare CDNs
      if (bytes == null && (Platform.isLinux || Platform.isMacOS || Platform.isWindows)) {
        try {
          final args = <String>['-s', '-L', '--max-time', '12'];
          headers.forEach((k, v) {
            args.addAll(['-H', '$k: $v']);
          });
          args.add(url);
          final res = await Process.run('curl', args, stdoutEncoding: null);
          if (res.exitCode == 0) {
            final b = res.stdout as List<int>;
            if (_isValidImageBytes(b)) { bytes = Uint8List.fromList(b); }
          }
        } catch (_) {}
      }

      if (bytes != null && bytes.length > 200) {
        _memoryCache[url] = bytes;
        if (_memoryCache.length > 200) _memoryCache.remove(_memoryCache.keys.first);
        if (mangaServerId > 0 && _candidateCoverPaths.isNotEmpty) {
          try {
            final file = File('${_candidateCoverPaths.first}/$mangaServerId.jpg');
            await file.writeAsBytes(bytes);
            _resolvedPaths[mangaServerId] = file.path;
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
    final url = widget.thumbnailUrl;
    if (url == null || url.isEmpty) return;

    final mem = ImageCacheHelper.getMemoryCover(url);
    if (mem != null) {
      _recoveredBytes = mem;
      return;
    }

    final localPath = ImageCacheHelper.getLocalCoverPath(widget.mangaServerId);
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

    // 2. Render from local file if cached
    final localPath = ImageCacheHelper.getLocalCoverPath(widget.mangaServerId);
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
    final url = widget.thumbnailUrl;
    if (url != null && url.isNotEmpty) {
      final effectiveSource = widget.sourceName ?? '';
      final headers = QuickJsService.getImageHeaders(effectiveSource, url);

      return Image.network(
        url,
        headers: headers,
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
            url,
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
