import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../engine/quickjs_service.dart';

class ImageCacheHelper {
  static String? _basePath;

  static Future<void> initialize() async {
    try {
      PaintingBinding.instance.imageCache.maximumSize = 1000;
      PaintingBinding.instance.imageCache.maximumSizeBytes = 128 * 1024 * 1024; // 128MB
      final appDir = await getApplicationDocumentsDirectory();
      final dir = Directory('${appDir.path}/covers');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      _basePath = dir.path;
    } catch (_) {}
  }

  static String? getLocalCoverPath(int mangaServerId) {
    if (_basePath != null) {
      final f = File('$_basePath/$mangaServerId.jpg');
      if (f.existsSync() && f.lengthSync() > 100) {
        return f.path;
      }
    }
    return null;
  }

  static Future<void> clearCache() async {
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

  static Future<void> cacheThumbnail(int mangaServerId, String url, {String sourceName = ''}) async {
    if (_basePath == null) await initialize();
    final localPath = getLocalCoverPath(mangaServerId);
    if (localPath != null) return;

    try {
      final headers = QuickJsService.getImageHeaders(sourceName, url);
      final client = HttpClient();
      final req = await client.getUrl(Uri.parse(url));
      headers.forEach((k, v) => req.headers.set(k, v));
      final resp = await req.close();
      if (resp.statusCode == 200) {
        final bytes = await resp.fold<List<int>>([], (p, c) => p..addAll(c));
        if (bytes.length > 200 && _basePath != null) {
          final file = File('$_basePath/$mangaServerId.jpg');
          await file.writeAsBytes(bytes);
        }
      }
    } catch (_) {}
  }
}

class MangaCoverImage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final int targetCacheWidth = width != null ? (width! * dpr).clamp(100.0, 600.0).round() : 360;
    final int targetCacheHeight = height != null ? (height! * dpr).clamp(150.0, 900.0).round() : 520;

    final localPath = ImageCacheHelper.getLocalCoverPath(mangaServerId);
    if (localPath != null) {
      return Image.file(
        File(localPath),
        width: width,
        height: height,
        fit: fit,
        cacheWidth: targetCacheWidth,
        cacheHeight: targetCacheHeight,
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

    if (thumbnailUrl != null && thumbnailUrl!.isNotEmpty) {
      final effectiveSource = sourceName ?? '';
      final headers = QuickJsService.getImageHeaders(effectiveSource, thumbnailUrl!);

      // Proactively cache to local storage in background
      if (mangaServerId > 0) {
        ImageCacheHelper.cacheThumbnail(mangaServerId, thumbnailUrl!, sourceName: effectiveSource);
      }

      return Image.network(
        thumbnailUrl!,
        headers: headers,
        width: width,
        height: height,
        fit: fit,
        cacheWidth: targetCacheWidth,
        cacheHeight: targetCacheHeight,
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

    return _fallback();
  }

  Widget _fallback() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFF26262B),
      child: const Center(
        child: Icon(Icons.book_rounded, color: Colors.grey, size: 28),
      ),
    );
  }
}
