import '../../core/db/models/chapter.dart';

/// Parses a chapter number from a display name.
///
/// Handles common patterns: "Chapter 12", "Ch. 12", "Ep. 7", "Episode 7", "#3",
/// "Vol. 1 Ch. 5", or a bare number. Returns `null` if no number can be extracted.
double? parseChapterNumberFromName(String name) {
  // Prologue/preview special case — treat as chapter 0
  if (RegExp(r'\bprologue\b', caseSensitive: false).hasMatch(name)) {
    return 0.0;
  }

  final match = RegExp(
    r'(?:ch(?:apter)?\.?|ep(?:isode)?\.?|#)\s*(\d+(?:\.\d+)?)',
    caseSensitive: false,
  ).firstMatch(name) ??
      RegExp(r'(\d+(?:\.\d+)?)').firstMatch(name);

  if (match != null) {
    final parsed = double.tryParse(match.group(1)!);
    if (parsed != null && parsed >= 0) return parsed;
  }
  return null;
}

/// Returns a sortable chapter number for [chapter].
///
/// Priority:
/// 1. [Chapter.chapterNumber] if > 0 (explicit from source)
/// 2. Parsed from [Chapter.name] via [parseChapterNumberFromName]
/// 3. Falls back to 0.0
double chapterSortNumber(Chapter chapter) {
  if (chapter.chapterNumber > 0) return chapter.chapterNumber;
  return parseChapterNumberFromName(chapter.name) ?? 0.0;
}

/// Returns a sortable chapter number for a name/number pair.
///
/// Used when [Chapter] object is not available but we have name and optional explicit number.
/// Priority:
/// 1. [explicitNumber] if > 0
/// 2. Parsed from [name] via [parseChapterNumberFromName]
/// 3. Falls back to [fallbackIndex] + 1 (1-based position)
double chapterSortNumberFromParts({
  required String name,
  double explicitNumber = 0.0,
  int fallbackIndex = 0,
}) {
  if (explicitNumber > 0) return explicitNumber;
  return parseChapterNumberFromName(name) ?? (fallbackIndex + 1).toDouble();
}