import 'package:flutter/material.dart';

class AmbientPalette {
  /// Falls back to a Material dark surface (no hard-coded hex) so callers
  /// that omit [fallback] stay theme-neutral (ISS-044).
  static Future<Color> extractDominantColor(
    ImageProvider imageProvider, {
    Color? fallback,
  }) async {
    try {
      final scheme = await ColorScheme.fromImageProvider(
        provider: imageProvider,
        brightness: Brightness.dark,
      );
      return scheme.primary;
    } catch (_) {
      return fallback ??
          ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ).surface;
    }
  }
}
