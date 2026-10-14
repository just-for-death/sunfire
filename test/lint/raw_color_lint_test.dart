// ISS-111: CI guard against raw colours in lib/ outside the theme files.
//
// Counts occurrences of `Color(0x…)` and `Colors.<name>` per file (comment
// lines ignored). Files under the theme/design-system directories are exempt.
// Existing offenders are frozen in raw_color_allowlist.txt as `path count`:
// a file may go DOWN (please lower its entry) but never up, and a file not in
// the allowlist must have zero. Regenerate only with a reviewed reason.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _exemptPrefixes = [
  'lib/src/ui/design_system/', // tokens + sunfire_theme.dart
];
final _pattern = RegExp(r'Color\(0x[0-9A-Fa-f]+\)|\bColors\.[a-zA-Z]\w*');

Map<String, int> scanRawColors(Directory root) {
  final out = <String, int>{};
  for (final e in root.listSync(recursive: true)) {
    if (e is! File || !e.path.endsWith('.dart')) continue;
    final rel = e.path.replaceAll('\\', '/').substring(e.path.indexOf('lib/'));
    if (_exemptPrefixes.any(rel.startsWith)) continue;
    if (rel.endsWith('.g.dart') || rel.endsWith('.freezed.dart')) continue;
    var n = 0;
    for (final line in e.readAsLinesSync()) {
      final t = line.trimLeft();
      if (t.startsWith('//')) continue;
      n += _pattern.allMatches(line).length;
    }
    if (n > 0) out[rel] = n;
  }
  return out;
}

Map<String, int> loadAllowlist(File f) => {
      for (final l in f.readAsLinesSync())
        if (l.trim().isNotEmpty && !l.startsWith('#'))
          l.trim().split(RegExp(r'\s+'))[0]: int.parse(l.trim().split(RegExp(r'\s+'))[1]),
    };

List<String> rawColorViolations(Map<String, int> found, Map<String, int> allow) => [
      for (final e in found.entries)
        if (e.value > (allow[e.key] ?? 0))
          '${e.key}: ${e.value} raw colour(s), allowlist ${allow[e.key] ?? 0} — use Theme/ColorScheme or design-system tokens',
    ];

void main() {
  test('ISS-111: no new raw Color(0x…)/Colors.* in lib/ outside theme files', () {
    final found = scanRawColors(Directory('lib'));
    final allow = loadAllowlist(File('test/lint/raw_color_allowlist.txt'));
    final v = rawColorViolations(found, allow);
    expect(v, isEmpty, reason: v.join('\n'));
  });

  test('ISS-111: checker flags new files and increases, tolerates decreases', () {
    expect(rawColorViolations({'lib/a.dart': 1}, {}), hasLength(1));
    expect(rawColorViolations({'lib/a.dart': 3}, {'lib/a.dart': 2}), hasLength(1));
    expect(rawColorViolations({'lib/a.dart': 1}, {'lib/a.dart': 2}), isEmpty);
    expect(_pattern.allMatches('Color(0xFF112233) Colors.grey Colors.white70 colors.x').length, 3);
  });
}
