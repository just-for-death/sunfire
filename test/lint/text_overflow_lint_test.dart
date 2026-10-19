// UIS-11: CI guard against width-unsafe `Text` inside a `Row`.
//
// A `Text` that is a direct child of a `Row` and is not wrapped in
// `Expanded`/`Flexible` (or given an explicit `overflow`) will throw a
// RenderFlex overflow once its content exceeds the available width — which is
// exactly what happens on narrow phones, split-view and large text scales.
//
// This scanner counts those occurrences per file. Existing offenders are frozen
// in text_overflow_allowlist.txt as `path count`: a file may go DOWN (please
// lower its entry) but never up, and a file absent from the allowlist must have
// zero. The remaining frozen entries are static, short, min-sized labels in
// horizontally scrolling chip rows that cannot realistically overflow; they are
// listed so that any *new* width-unsafe Text fails CI.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

final _rowPattern = RegExp(r'(?<![A-Za-z0-9_.])Row\(');
final _textPattern = RegExp(r'^Text\(');

/// Index of the `)` matching the `(` at [open], or [s].length if unbalanced.
int _matchParen(String s, int open) {
  var depth = 0;
  for (var i = open; i < s.length; i++) {
    final c = s[i];
    if (c == '(') {
      depth++;
    } else if (c == ')') {
      depth--;
      if (depth == 0) return i;
    }
  }
  return s.length;
}

/// Split on top-level commas, respecting nested brackets and string literals.
List<String> _splitTopCommas(String body) {
  final parts = <String>[];
  final buf = StringBuffer();
  var depth = 0;
  String? quote;
  for (var i = 0; i < body.length; i++) {
    final c = body[i];
    if (quote != null) {
      buf.write(c);
      if (c == r'\' && i + 1 < body.length) {
        buf.write(body[i + 1]);
        i++;
      } else if (c == quote) {
        quote = null;
      }
      continue;
    }
    if (c == "'" || c == '"') {
      quote = c;
      buf.write(c);
      continue;
    }
    if (c == '(' || c == '[' || c == '{') depth++;
    if (c == ')' || c == ']' || c == '}') depth--;
    if (c == ',' && depth == 0) {
      parts.add(buf.toString());
      buf.clear();
    } else {
      buf.write(c);
    }
  }
  if (buf.isNotEmpty) parts.add(buf.toString());
  return parts;
}

/// Count width-unsafe `Text` children of `Row` widgets in [src].
int countUnsafeRowText(String src) {
  var count = 0;
  for (final m in _rowPattern.allMatches(src)) {
    final open = m.end - 1;
    final close = _matchParen(src, open);
    final body = src.substring(open + 1, close);

    final childrenPart = _splitTopCommas(body).firstWhere(
      (p) => p.trimLeft().startsWith('children:') || p.trimLeft().startsWith('children :'),
      orElse: () => '',
    );
    if (childrenPart.isEmpty) continue;
    final lb = childrenPart.indexOf('[');
    if (lb < 0) continue;
    final inner = childrenPart.substring(lb + 1);
    for (final kid in _splitTopCommas(inner)) {
      final k = kid.trim();
      if (k.isEmpty) continue;
      if (_textPattern.hasMatch(k) && !k.contains('overflow')) {
        count++;
      }
    }
  }
  return count;
}

Map<String, int> scanUnsafeRowText(Directory root) {
  final out = <String, int>{};
  for (final e in root.listSync(recursive: true)) {
    if (e is! File || !e.path.endsWith('.dart')) continue;
    final rel = e.path.replaceAll('\\', '/').substring(e.path.indexOf('lib/'));
    if (rel.endsWith('.g.dart') || rel.endsWith('.freezed.dart')) continue;
    final n = countUnsafeRowText(e.readAsStringSync());
    if (n > 0) out[rel] = n;
  }
  return out;
}

Map<String, int> loadAllowlist(File f) => {
      for (final l in f.readAsLinesSync())
        if (l.trim().isNotEmpty && !l.trimLeft().startsWith('#'))
          l.trim().split(RegExp(r'\s+'))[0]:
              int.parse(l.trim().split(RegExp(r'\s+'))[1]),
    };

List<String> overflowViolations(Map<String, int> found, Map<String, int> allow) => [
      for (final e in found.entries)
        if (e.value > (allow[e.key] ?? 0))
          '${e.key}: ${e.value} width-unsafe Text child(ren) of Row, allowlist ${allow[e.key] ?? 0} — wrap in Expanded/Flexible with maxLines/overflow',
    ];

void main() {
  test('UIS-11: no new width-unsafe Text inside a Row in lib/', () {
    final found = scanUnsafeRowText(Directory('lib'));
    final allow = loadAllowlist(File('test/lint/text_overflow_allowlist.txt'));
    final v = overflowViolations(found, allow);
    expect(v, isEmpty, reason: v.join('\n'));
  });

  test('UIS-11: scanner flags new files/increases, tolerates decreases', () {
    expect(overflowViolations({'lib/a.dart': 1}, {}), hasLength(1));
    expect(overflowViolations({'lib/a.dart': 3}, {'lib/a.dart': 2}), hasLength(1));
    expect(overflowViolations({'lib/a.dart': 1}, {'lib/a.dart': 2}), isEmpty);
  });

  test('UIS-11: scanner detects a bare Text and ignores fixed cases', () {
    expect(countUnsafeRowText('Row(children: [Text("hi")])'), 1);
    expect(countUnsafeRowText('Row(children: [Expanded(child: Text("hi"))])'), 0);
    expect(countUnsafeRowText('Row(children: [Text("hi", overflow: TextOverflow.ellipsis)])'), 0);
    // A `Text(` inside a string or after a dot is not a widget construction.
    expect(countUnsafeRowText('Row(children: [RichText(text: x)])'), 0);
  });
}
