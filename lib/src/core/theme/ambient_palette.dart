import 'package:flutter/material.dart';

class AmbientPalette {
  static Future<Color> extractDominantColor(ImageProvider imageProvider, {Color fallback = const Color(0xFF1F1F24)}) async {
    try {
      final scheme = await ColorScheme.fromImageProvider(
        provider: imageProvider,
        brightness: Brightness.dark,
      );
      return scheme.primary;
    } catch (_) {
      return fallback;
    }
  }
}
