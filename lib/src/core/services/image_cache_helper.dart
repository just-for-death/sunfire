import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../engine/quickjs_service.dart';

class ImageCacheHelper {
  static String? _basePath;

  static Future<void> initialize() async {
    try {
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
    // Direct Linux documents check fallback
    final direct = File('/home/zoro/Documents/covers/$mangaServerId.jpg');
    if (direct.existsSync() && direct.lengthSync() > 100) {
      return direct.path;
    }
    return null;
  }

  static Future<void> cacheThumbnail(int mangaServerId, String url) async {
    if (_basePath == null) await initialize();
    final localPath = getLocalCoverPath(mangaServerId);
    if (localPath != null) return;

    try {
      final client = HttpClient();
      final req = await client.getUrl(Uri.parse(url));
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
  final double? width;
  final double? height;
  final BoxFit fit;

  const MangaCoverImage({
    super.key,
    required this.mangaServerId,
    this.thumbnailUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final localPath = ImageCacheHelper.getLocalCoverPath(mangaServerId);
    if (localPath != null) {
      return Image.file(
        File(localPath),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }

    if (thumbnailUrl != null && thumbnailUrl!.isNotEmpty) {
      final headers = QuickJsService.getImageHeaders(thumbnailUrl!);

      return Image.network(
        thumbnailUrl!,
        headers: headers,
        width: width,
        height: height,
        fit: fit,
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
