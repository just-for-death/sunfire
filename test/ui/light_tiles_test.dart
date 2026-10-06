// ISS-018: residual Light-mode polish guard. Non-dialog tiles in Browse,
// Library and Updates must use ColorScheme roles, not dark-only literals
// (white-on-white in Light). Cover overlays (text on images/gradients) and
// text on red/primary buttons may still use Colors.white.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const files = [
    'lib/src/features/browse/browse_screen.dart',
    'lib/src/features/library/library_screen.dart',
    'lib/src/features/updates/updates_screen.dart',
  ];
  const banned = [
    'Colors.white70',
    'Colors.white60',
    'Colors.white38',
    'Colors.white30',
    'Colors.white24',
    'Color(0x1F2A2A32)',
    'Color(0x26FFFFFF)',
    'Color(0x33FFFFFF)',
    'Color(0x2BFFFFFF)',
    'Color(0xCC181820)',
    'Color(0xFF23232A)',
  ];

  for (final f in files) {
    test('$f has no dark-only text/tile literals', () {
      final src = File(f).readAsStringSync();
      final hits = [
        for (final b in banned)
          if (src.contains(b)) b,
      ];
      expect(hits, isEmpty, reason: 'Use Theme.of(context).colorScheme roles');
    });
  }
}
