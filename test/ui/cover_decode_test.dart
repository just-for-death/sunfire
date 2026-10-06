// UIS-07: cover decode uses cacheWidth only (no forced cacheHeight stretch).
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/services/image_cache_helper.dart';

Future<Uint8List> _pngBytes(int w, int h) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  const cell = 20;
  for (var y = 0; y < h; y += cell) {
    for (var x = 0; x < w; x += cell) {
      final dark = ((x ~/ cell) + (y ~/ cell)).isEven;
      canvas.drawRect(
        Rect.fromLTWH(x.toDouble(), y.toDouble(), cell.toDouble(), cell.toDouble()),
        Paint()..color = dark ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
      );
    }
  }
  final picture = recorder.endRecording();
  final image = await picture.toImage(w, h);
  final bd = await image.toByteData(format: ui.ImageByteFormat.png);
  return bd!.buffer.asUint8List();
}

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('sunfire_cover_decode_');
    ImageCacheHelper.debugSetCandidateCoverPaths([tempDir.path]);
  });

  tearDown(() async {
    ImageCacheHelper.debugClearLocalPathCache();
    ImageCacheHelper.debugSetCandidateCoverPaths([]);
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  testWidgets('MangaCoverImage local file decode uses cacheWidth only',
      (tester) async {
    const mangaId = 99;
    // PNG encode + disk I/O must leave fake-async (ISS-015).
    await tester.runAsync(() async {
      final bytes = await _pngBytes(400, 400);
      final file = File('${tempDir.path}/$mangaId.jpg');
      await file.writeAsBytes(bytes);
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 120,
            height: 174,
            child: MangaCoverImage(
              mangaServerId: mangaId,
              width: 120,
              height: 174,
            ),
          ),
        ),
      ),
    );

    // Local path resolve is real async I/O — flush outside fake-async.
    ImageProvider? provider;
    for (var i = 0; i < 50; i++) {
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      });
      await tester.pump();
      final images = tester.widgetList<Image>(find.byType(Image)).toList();
      if (images.isEmpty) continue;
      provider = images.first.image;
      if (provider is ResizeImage) break;
      // Image.file(cacheWidth:) may expose ResizeImage; also accept FileImage
      // only if we can read width via ResizeImage unwrap.
    }

    expect(provider, isNotNull, reason: 'expected an Image after local resolve');
    expect(provider, isA<ResizeImage>(),
        reason: 'Image.file/memory with cacheWidth wraps ResizeImage');
    final resize = provider! as ResizeImage;
    expect(resize.width, isNotNull);
    expect(resize.height, isNull,
        reason: 'UIS-07: cacheHeight must not be set (preserves aspect)');
  });
}
