// lib/src/core/library/duplicate_detection_service.dart
//
// L10.4: Duplicate Detection & Merge Service
//
// Detects and merges duplicate manga entries in the local library.
// Uses multi-signal matching: URL identity, normalized-title equality,
// source-name fuzzy match, and chapter-count overlap.
// Provides a UI for reviewing and confirming merges.

import 'dart:async';
import 'dart:math' show min, max;

import 'package:flutter/foundation.dart' show debugPrint;

import '../db/isar_service.dart';
import '../db/models/manga.dart';
import '../engine/source_migration_service.dart'
    show SourceMigrationService;

/// Result of duplicate detection scan.
class DuplicateScanResult {
  const DuplicateScanResult({
    required this.groups,
    required this.totalMangaScanned,
    required this.scanDuration,
  });

  /// Each group contains manga that are considered duplicates.
  /// First entry is the "canonical" (kept) manga.
  final List<DuplicateGroup> groups;

  /// Total number of manga entries scanned.
  final int totalMangaScanned;

  /// Duration of the scan.
  final Duration scanDuration;

  int get duplicateCount => groups.fold(0, (sum, g) => sum + g.duplicates.length);
  int get groupCount => groups.length;

  @override
  String toString() =>
      'DuplicateScanResult(groups: $groupCount, duplicates: $duplicateCount, scanned: $totalMangaScanned, ${scanDuration.inMilliseconds}ms)';
}

/// A group of duplicate manga.
class DuplicateGroup {
  const DuplicateGroup({
    required this.canonical,
    required this.duplicates,
    required this.reason,
  });

  /// The manga to keep (first by library-addition time).
  final Manga canonical;

  /// Manga to merge into canonical.
  final List<Manga> duplicates;

  /// Human-readable reason for grouping.
  final String reason;

  int get totalCount => 1 + duplicates.length;

  @override
  String toString() =>
      'DuplicateGroup(canonical: ${canonical.title}, dupes: ${duplicates.length}, reason: $reason)';
}

/// Service for detecting and merging duplicate manga.
class DuplicateDetectionService {
  DuplicateDetectionService._();
  static final DuplicateDetectionService instance = DuplicateDetectionService._();

  final SourceMigrationService _sourceMigration = SourceMigrationService.instance;

  static const double _titleSimilarityThreshold = 0.85;

  /// Scan the library for duplicate manga.
  ///
  /// Returns groups of duplicates, each with a canonical (kept) manga.
  /// Uses multiple matching strategies in priority order:
  /// 1. Exact URL match (after normalization)
  /// 2. URL containment (one URL contains the other)
  /// 3. Normalized-title equality (when URLs missing)
  /// 4. Source-name fuzzy match + chapter-count overlap
  Future<DuplicateScanResult> scanForDuplicates({
    bool includeExactUrl = true,
    bool includeUrlContainment = true,
    bool includeTitleMatch = true,
    bool includeSourceFuzzy = true,
  }) async {
    final stopwatch = Stopwatch()..start();

    final library = await IsarService.instance.getLibraryManga();
    if (library.isEmpty) {
      return DuplicateScanResult(
        groups: const [],
        totalMangaScanned: 0,
        scanDuration: stopwatch.elapsed,
      );
    }

    // Group by source for efficiency
    final bySource = <String, List<Manga>>{};
    for (final m in library) {
      final src = _sourceMigration.normalizeSourceName(m.sourceName);
      bySource.putIfAbsent(src, () => []).add(m);
    }

    final groups = <DuplicateGroup>[];
    final seen = <int>{};

    for (final entry in bySource.entries) {
      final sourceManga = entry.value;
      if (sourceManga.length < 2) continue;

      // Sort by library-addition time (oldest first = canonical)
      sourceManga.sort((a, b) => (a.inLibraryAt ?? 0).compareTo(b.inLibraryAt ?? 0));

      for (int i = 0; i < sourceManga.length; i++) {
        if (seen.contains(sourceManga[i].id)) continue;

        final canonical = sourceManga[i];
        final dupes = <Manga>[];
        final reasons = <String>{};

        for (int j = i + 1; j < sourceManga.length; j++) {
          if (seen.contains(sourceManga[j].id)) continue;

          final match = _areDuplicates(
            canonical,
            sourceManga[j],
            includeExactUrl: includeExactUrl,
            includeUrlContainment: includeUrlContainment,
            includeTitleMatch: includeTitleMatch,
            includeSourceFuzzy: includeSourceFuzzy,
          );

          if (match) {
            dupes.add(sourceManga[j]);
            seen.add(sourceManga[j].id);
            reasons.add(_matchReason(canonical, sourceManga[j]));
          }
        }

        if (dupes.isNotEmpty) {
          seen.add(canonical.id);
          groups.add(DuplicateGroup(
            canonical: canonical,
            duplicates: dupes,
            reason: reasons.join('; '),
          ));
        }
      }
    }

    return DuplicateScanResult(
      groups: groups,
      totalMangaScanned: library.length,
      scanDuration: stopwatch.elapsed,
    );
  }

  bool _areDuplicates(
    Manga a,
    Manga b, {
    required bool includeExactUrl,
    required bool includeUrlContainment,
    required bool includeTitleMatch,
    required bool includeSourceFuzzy,
  }) {
    // 1. Exact URL match
    if (includeExactUrl) {
      final urlA = _sourceMigration.normalizeUrlForMatch(a.url);
      final urlB = _sourceMigration.normalizeUrlForMatch(b.url);
      if (urlA.isNotEmpty && urlB.isNotEmpty && urlA == urlB) return true;
    }

    // 2. URL containment
    if (includeUrlContainment) {
      final urlA = _sourceMigration.normalizeUrlForMatch(a.url);
      final urlB = _sourceMigration.normalizeUrlForMatch(b.url);
      if (urlA.isNotEmpty && urlB.isNotEmpty &&
          (urlA.contains(urlB) || urlB.contains(urlA))) return true;
    }

    // 3. Normalized title equality (when URLs missing/different)
    if (includeTitleMatch) {
      final titleA = _normalizeTitle(a.title);
      final titleB = _normalizeTitle(b.title);
      if (titleA.isNotEmpty && titleB.isNotEmpty && titleA == titleB) return true;

      // Fuzzy title similarity
      if (_titleSimilarity(titleA, titleB) >= _titleSimilarityThreshold) return true;
    }

    // 4. Source fuzzy + chapter count overlap
    if (includeSourceFuzzy) {
      final chaptersA = a.chapterCount;
      final chaptersB = b.chapterCount;
      if (chaptersA > 0 && chaptersB > 0) {
        final overlap = min(chaptersA, chaptersB) / max(chaptersA, chaptersB);
        if (overlap > 0.7 && _normalizeTitle(a.title) == _normalizeTitle(b.title)) return true;
      }
    }

    return false;
  }

  String _matchReason(Manga a, Manga b) {
    final urlA = _sourceMigration.normalizeUrlForMatch(a.url);
    final urlB = _sourceMigration.normalizeUrlForMatch(b.url);
    if (urlA.isNotEmpty && urlB.isNotEmpty && urlA == urlB) return 'Exact URL match';
    if (urlA.isNotEmpty && urlB.isNotEmpty &&
        (urlA.contains(urlB) || urlB.contains(urlA))) return 'URL containment';

    final titleA = _normalizeTitle(a.title);
    final titleB = _normalizeTitle(b.title);
    if (titleA == titleB) return 'Exact title match';
    if (_titleSimilarity(titleA, titleB) >= _titleSimilarityThreshold) return 'Fuzzy title match';

    return 'Source fuzzy + chapter overlap';
  }

  String _normalizeTitle(String title) =>
      title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '').trim();

  double _titleSimilarity(String a, String b) {
    if (a.isEmpty || b.isEmpty) return 0.0;
    // Jaccard similarity on bigrams
    final setA = <String>{};
    final setB = <String>{};
    for (var i = 0; i < a.length - 1; i++) setA.add(a.substring(i, i + 2));
    for (var i = 0; i < b.length - 1; i++) setB.add(b.substring(i, i + 2));
    final intersection = setA.intersection(setB).length;
    final union = setA.union(setB).length;
    return union == 0 ? 0.0 : intersection / union;
  }

  /// Merge a duplicate group: move all chapters/bookmarks/read-progress
  /// from duplicates into the canonical manga, then delete the duplicates.
  ///
  /// Returns the number of chapters merged.
  Future<int> mergeGroup(DuplicateGroup group) async {
    int merged = 0;

    for (final dupe in group.duplicates) {
      // Merge chapters
      final dupeChapters = await IsarService.instance.getChaptersForManga(dupe.canonicalKey);
      for (final ch in dupeChapters) {
        ch.mangaId = group.canonical.canonicalKey;
        await IsarService.instance.saveChapter(ch);
        merged++;
      }

      // Update canonical manga stats
      final canon = group.canonical;
      canon.chapterCount = canon.chapterCount + dupe.chapterCount;
      canon.unreadCount = (canon.unreadCount ?? 0) + (dupe.unreadCount ?? 0);
      await IsarService.instance.saveManga(canon);

      // Delete duplicate
      await IsarService.instance.deleteManga(dupe.id);
    }

    debugPrint('[DuplicateDetection] Merged ${group.duplicates.length} into ${group.canonical.title} ($merged chapters)');
    return merged;
  }

  /// Merge all detected duplicate groups.
  Future<int> mergeAll(DuplicateScanResult result) async {
    int total = 0;
    for (final g in result.groups) {
      total += await mergeGroup(g);
    }
    return total;
  }
}