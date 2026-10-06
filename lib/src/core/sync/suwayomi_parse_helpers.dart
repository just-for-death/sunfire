// Pure Suwayomi GraphQL parse helpers (ISS-070 / ISS-072).

/// Normalize `contentWarning` enum strings (SAFE / MIXED / NSFW).
String? parseContentWarning(dynamic raw) {
  if (raw == null) return null;
  final s = raw.toString().trim().toUpperCase();
  if (s == 'SAFE' || s == 'MIXED' || s == 'NSFW') return s;
  return null;
}

/// NSFW decision for a source/extension node (ISS-070).
///
/// Prefers `contentWarning` (NSFW/MIXED → true, SAFE → false). Falls back to
/// `isNsfw` / `nsfw` boolean. **No name heuristic** — browse UI may still
/// apply its own label heuristics separately.
bool isNsfwFromSourceNode(Map<dynamic, dynamic> map) {
  final cw = parseContentWarning(map['contentWarning']);
  if (cw == 'NSFW' || cw == 'MIXED') return true;
  if (cw == 'SAFE') return false;
  final v = map['isNsfw'] ?? map['nsfw'];
  return v == true || v == 1 || v == 'true' || v == '1';
}

/// Copy `manga.user {…}` fields onto the top-level map under existing keys
/// so callers keep reading `inLibrary` / `unreadCount` / etc. (ISS-072).
///
/// User values win when present; top-level is left untouched when user omits
/// a key (older partial payloads).
Map<String, dynamic> flattenMangaUserFields(Map<String, dynamic> manga) {
  final user = manga['user'];
  if (user is! Map) return manga;
  final out = Map<String, dynamic>.from(manga);
  const keys = <String>[
    'inLibrary',
    'inLibraryAt',
    'unreadCount',
    'bookmarkCount',
    'downloadCount',
  ];
  for (final k in keys) {
    if (user.containsKey(k) && user[k] != null) {
      out[k] = user[k];
    }
  }
  // Nested chapter pointers: expose under stable aliases when useful.
  for (final k in ['firstUnreadChapter', 'lastReadChapter', 'latestReadChapter']) {
    if (user.containsKey(k)) out[k] = user[k];
  }
  return out;
}

/// Copy `chapter.user {…}` onto top-level read/bookmark/download keys (ISS-072).
Map<String, dynamic> flattenChapterUserFields(Map<String, dynamic> chapter) {
  final user = chapter['user'];
  if (user is! Map) return chapter;
  final out = Map<String, dynamic>.from(chapter);
  const keys = <String>[
    'isRead',
    'isBookmarked',
    'isDownloaded',
    'lastPageRead',
    'lastReadAt',
  ];
  for (final k in keys) {
    if (user.containsKey(k) && user[k] != null) {
      out[k] = user[k];
    }
  }
  return out;
}

/// Normalize IncludeOrExclude enum to a stable uppercase token.
String parseIncludeOrExclude(dynamic raw, {String fallback = 'UNSET'}) {
  if (raw == null) return fallback;
  final s = raw.toString().trim().toUpperCase();
  if (s == 'INCLUDE' || s == 'EXCLUDE' || s == 'UNSET') return s;
  return fallback;
}
