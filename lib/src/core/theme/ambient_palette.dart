import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

class AmbientPalette {
  static Future<Color> extractDominantColor(ImageProvider imageProvider, {Color fallback = const Color(0xFF1F1F24)}) async {
    try {
      final palette = await PaletteGenerator.fromImageProvider(
        imageProvider,
        maximumColorCount: 8,
      );
      return palette.dominantColor?.color ?? palette.vibrantColor?.color ?? fallback;
    } catch (_) {
      return fallback;
    }
  }
}
