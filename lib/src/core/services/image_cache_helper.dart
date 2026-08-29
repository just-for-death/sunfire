import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../engine/quickjs_service.dart';

class ImageCacheHelper {
  static String? _basePath;
  static final Map<String, Uint8List> _memoryCache = {};
  static final Set<String> _inFlightFetches = {};

  static Future<void> initialize() async {
    try {
      PaintingBinding.instance.imageCache.maximumSize = 1000;
      PaintingBinding.instance.imageCache.maximumSizeBytes = 128 * 1024 * 1024; // 128MB

      Directory dir;
      try {
        final appSupportDir = await getApplicationSupportDirectory();
        dir = Directory('${appSupportDir.path}/covers');
      } catch (_) {
        final appDir = await getApplicationDocumentsDirectory();
        dir = Directory('${appDir.path}/covers');
      }
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      _basePath = dir.path;
    } catch (_) {}
  }

  static String? getLocalCoverPath(int mangaServerId) {
    if (mangaServerId <= 0) return null;
    if (_basePath != null) {
      final f = File('$_basePath/$mangaServerId.jpg');
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
    try {
      if (_basePath != null) {
        final dir = Directory(_basePath!);
        if (await dir.exists()) {
          final files = await dir.list().toList();
          for (final f in files) {
            await f.delete();
          }
        }
      }
    } catch (_) {}
  }

  static Future<Uint8List?> fetchImageBytes(
    String url, {
    String sourceName = '',
    int mangaServerId = 0,
  }) async {
    if (url.isEmpty) return null;
    if (_memoryCache.containsKey(url)) return _memoryCache[url];

    // Check disk cache first
    if (mangaServerId > 0 && _basePath != null) {
      final f = File('$_basePath/$mangaServerId.jpg');
      if (f.existsSync() && f.lengthSync() > 100) {
        try {
          final bytes = await f.readAsBytes();
          _memoryCache[url] = bytes;
          return bytes;
        } catch (_) {}
      }
    }

    if (_inFlightFetches.contains(url)) return null;
    _inFlightFetches.add(url);

    try {
      final headers = QuickJsService.getImageHeaders(sourceName, url);
      Uint8List? bytes;

      // 1. Try standard HttpClient
      try {
        final client = HttpClient();
        client.badCertificateCallback = (cert, host, port) => true;
        client.connectionTimeout = const Duration(seconds: 8);
        final req = await client.getUrl(Uri.parse(url));
        headers.forEach((k, v) => req.headers.set(k, v));
        final resp = await req.close();
        if (resp.statusCode == 200) {
          final b = await resp.fold<List<int>>([], (p, c) => p..addAll(c));
          if (b.length > 200) {
            bytes = Uint8List.fromList(b);
          }
        }
      } catch (_) {}

      // 2. Fallback on desktop: use curl process to bypass TLS fingerprint blocking from Cloudflare CDNs
      if ((bytes == null || bytes.isEmpty) && (Platform.isLinux || Platform.isMacOS || Platform.isWindows)) {
        try {
          final args = <String>['-s', '-L', '--max-time', '12'];
          headers.forEach((k, v) {
            args.addAll(['-H', '$k: $v']);
          });
          args.add(url);
          final res = await Process.run('curl', args, stdoutEncoding: null);
          if (res.exitCode == 0) {
            final b = res.stdout as List<int>;
            if (b.length > 200) {
              bytes = Uint8List.fromList(b);
            }
          }
        } catch (_) {}
      }

      if (bytes != null && bytes.length > 200) {
        _memoryCache[url] = bytes;
        if (mangaServerId > 0 && _basePath != null) {
          try {
            final file = File('$_basePath/$mangaServerId.jpg');
            await file.writeAsBytes(bytes);
          } catch (_) {}
        }
        return bytes;
      }
    } finally {
      _inFlightFetches.remove(url);
    }
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
