import 'package:flutter/services.dart';

/// Centralizes system UI mode transitions between the app shell and reader.
abstract final class ReaderSystemUi {
  static void enterReader({required bool chromeVisible}) {
    if (chromeVisible) {
      showChrome();
    } else {
      hideChrome();
    }
  }

  static void hideChrome() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  static void showChrome() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  /// Restores the global edge-to-edge mode used by [main].
  static void exitReader() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
}
