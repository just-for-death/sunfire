// IMP-007 (UIX half): duplicate finder + saved library filters.
import 'dart:convert';

import '../db/models/manga.dart';
import 'settings_service.dart';

/// Title key used for duplicate matching: lower-case, diacritics-light,
/// punctuation and noise words removed ("The", "(Official)", "[Webtoon]").
String normalizeMangaTitle(String title) {
  // ISS-143: fold full-width ASCII (U+FF01-FF5E) and the ideographic space so
  // 'ＯＮＥ　ＰＩＥＣＥ' / 'ワンピース　' normalise like their half-width forms.
  var t = String.fromCharCodes(title.runes.map((r) => r == 0x3000
          ? 0x20
          : (r >= 0xFF01 && r <= 0xFF5E ? r - 0xFEE0 : r)))
      .toLowerCase();
  t = t.replaceAll(RegExp(r'[\(\[\{][^\)\]\}]*[\)\]\}]'), ' '); // bracketed tags
  const folds = {'á': 'a', 'à': 'a', 'â': 'a', 'ä': 'a', 'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e', 'í': 'i', 'ï': 'i', 'ó': 'o', 'ô': 'o', 'ö': 'o', 'ú': 'u', 'ü': 'u', 'ñ': 'n', 'ç': 'c'};
  folds.forEach((k, v) => t = t.replaceAll(k, v));
  t = t.replaceAll(RegExp(r"[^a-z0-9\u3040-\u30ff\u3400-\u9fff\uac00-\ud7af]+"), ' ');
  final words = t.split(' ').where((w) => w.isNotEmpty && w != 'the' && w != 'a' && w != 'an').toList();
  return words.join(' ');
}

/// Groups of library entries that look like the same series (same normalised
/// title, from any source). Each group has 2+ entries, sorted by title; groups
/// are ordered by title. Entries with an empty key are ignored.
List<List<Manga>> findPossibleDuplicates(Iterable<Manga> library) {
  final byKey = <String, List<Manga>>{};
  for (final m in library) {
    final k = normalizeMangaTitle(m.title);
    if (k.isEmpty) continue;
    byKey.putIfAbsent(k, () => []).add(m);
  }
  final groups = byKey.entries.where((e) => e.value.length > 1).toList()
    ..sort((a, b) => a.key.compareTo(b.key));
  return [
    for (final g in groups)
      g.value..sort((a, b) => a.sourceName.compareTo(b.sourceName)),
  ];
}

/// A named library filter preset. [query] is an opaque map owned by the
/// library screen (sort, filters, category); it is stored as JSON.
class SavedLibraryFilter {
  const SavedLibraryFilter(this.name, this.query);
  final String name;
  final Map<String, Object?> query;

  Map<String, Object?> toJson() => {'name': name, 'query': query};

  static SavedLibraryFilter? fromJson(Object? j) {
    if (j is! Map) return null;
    final name = j['name'];
    final q = j['query'];
    if (name is! String || name.trim().isEmpty || q is! Map) return null;
    return SavedLibraryFilter(name.trim(), Map<String, Object?>.from(q));
  }
}

const int kMaxSavedLibraryFilters = 20;

List<SavedLibraryFilter> loadSavedLibraryFilters(SettingsService s) {
  final raw = s.savedLibraryFiltersJson;
  if (raw.isEmpty) return [];
  try {
    final list = jsonDecode(raw);
    if (list is! List) return [];
    return [for (final j in list) ?SavedLibraryFilter.fromJson(j)];
  } catch (_) {
    return [];
  }
}

/// Adds or replaces (case-insensitive name) a preset, newest first, capped.
Future<List<SavedLibraryFilter>> saveLibraryFilter(SettingsService s, SavedLibraryFilter f) async {
  final list = loadSavedLibraryFilters(s)
    ..removeWhere((e) => e.name.toLowerCase() == f.name.toLowerCase())
    ..insert(0, f);
  final capped = list.take(kMaxSavedLibraryFilters).toList();
  s.savedLibraryFiltersJson = jsonEncode([for (final e in capped) e.toJson()]);
  return capped;
}

Future<List<SavedLibraryFilter>> deleteLibraryFilter(SettingsService s, String name) async {
  final list = loadSavedLibraryFilters(s)..removeWhere((e) => e.name.toLowerCase() == name.toLowerCase());
  s.savedLibraryFiltersJson = jsonEncode([for (final e in list) e.toJson()]);
  return list;
}
