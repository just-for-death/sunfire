// lib/src/core/library/library_import_export_service.dart
//
// L10.3: Library metadata import/export (JSON / CSV). Tachiyomi .tachibk
// remains on ImportTachibkScreen; this covers portable metadata + tags.

import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;

import '../db/isar_service.dart';
import '../db/models/manga.dart';
import '../services/tag_service.dart';
import '../sync/sync_engine.dart';

const int kLibraryExportVersion = 1;

/// One portable library row (metadata + tags + progress summary).
class LibraryExportEntry {
  const LibraryExportEntry({
    required this.title,
    this.author,
    this.artist,
    this.description,
    this.status,
    this.sourceName = '',
    this.url = '',
    this.thumbnailUrl,
    this.lang = '',
    this.genres = const [],
    this.tags = const [],
    this.categoryIds = const [],
    this.unreadCount,
    this.chapterCount = 0,
    this.serverId,
  });

  factory LibraryExportEntry.fromManga(
    Manga manga, {
    List<String> tagNames = const [],
  }) {
    return LibraryExportEntry(
      title: manga.title,
      author: manga.author,
      artist: manga.artist,
      description: manga.description,
      status: manga.status,
      sourceName: manga.sourceName,
      url: manga.url,
      thumbnailUrl: manga.thumbnailUrl,
      lang: manga.lang,
      genres: List<String>.from(manga.genres),
      tags: tagNames,
      categoryIds: List<int>.from(manga.categoryIds),
      unreadCount: manga.unreadCount,
      chapterCount: manga.chapterCount,
      serverId: manga.serverId == 0 ? null : manga.serverId,
    );
  }

  factory LibraryExportEntry.fromJson(Map<String, dynamic> json) {
    return LibraryExportEntry(
      title: json['title']?.toString() ?? '',
      author: json['author']?.toString(),
      artist: json['artist']?.toString(),
      description: json['description']?.toString(),
      status: json['status']?.toString(),
      sourceName: json['sourceName']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      thumbnailUrl: json['thumbnailUrl']?.toString(),
      lang: json['lang']?.toString() ?? '',
      genres: (json['genres'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      tags:
          (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      categoryIds: (json['categoryIds'] as List?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      unreadCount: (json['unreadCount'] as num?)?.toInt(),
      chapterCount: (json['chapterCount'] as num?)?.toInt() ?? 0,
      serverId: (json['serverId'] as num?)?.toInt(),
    );
  }

  final String title;
  final String? author;
  final String? artist;
  final String? description;
  final String? status;
  final String sourceName;
  final String url;
  final String? thumbnailUrl;
  final String lang;
  final List<String> genres;
  final List<String> tags;
  final List<int> categoryIds;
  final int? unreadCount;
  final int chapterCount;
  final int? serverId;

  Map<String, dynamic> toJson() => {
        'title': title,
        if (author != null) 'author': author,
        if (artist != null) 'artist': artist,
        if (description != null) 'description': description,
        if (status != null) 'status': status,
        'sourceName': sourceName,
        'url': url,
        if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
        'lang': lang,
        'genres': genres,
        'tags': tags,
        'categoryIds': categoryIds,
        if (unreadCount != null) 'unreadCount': unreadCount,
        'chapterCount': chapterCount,
        if (serverId != null) 'serverId': serverId,
      };
}

class LibraryExportPayload {
  const LibraryExportPayload({
    required this.version,
    required this.exportedAt,
    required this.entries,
  });

  factory LibraryExportPayload.fromJson(Map<String, dynamic> json) {
    final raw = json['entries'] as List? ?? const [];
    return LibraryExportPayload(
      version: (json['version'] as num?)?.toInt() ?? 0,
      exportedAt: DateTime.tryParse(json['exportedAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      entries: raw
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => LibraryExportEntry.fromJson(Map<String, dynamic>.from(e)))
          .where((e) => e.title.trim().isNotEmpty)
          .toList(),
    );
  }

  final int version;
  final DateTime exportedAt;
  final List<LibraryExportEntry> entries;

  Map<String, dynamic> toJson() => {
        'version': version,
        'exportedAt': exportedAt.toIso8601String(),
        'entries': entries.map((e) => e.toJson()).toList(),
      };

  String encodeJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  static LibraryExportPayload decodeJson(String raw) {
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return LibraryExportPayload.fromJson(map);
  }
}

/// Escape one CSV cell.
String csvEscape(String value) {
  if (value.contains(',') ||
      value.contains('"') ||
      value.contains('\n') ||
      value.contains('\r')) {
    return '"${value.replaceAll('"', '""')}"';
  }
  return value;
}

/// Build CSV from entries (header + rows).
String libraryEntriesToCsv(List<LibraryExportEntry> entries) {
  final buf = StringBuffer();
  buf.writeln(
    'title,author,sourceName,url,status,lang,genres,tags,chapterCount,unreadCount',
  );
  for (final e in entries) {
    buf.writeln([
      csvEscape(e.title),
      csvEscape(e.author ?? ''),
      csvEscape(e.sourceName),
      csvEscape(e.url),
      csvEscape(e.status ?? ''),
      csvEscape(e.lang),
      csvEscape(e.genres.join(';')),
      csvEscape(e.tags.join(';')),
      e.chapterCount.toString(),
      (e.unreadCount ?? '').toString(),
    ].join(','));
  }
  return buf.toString();
}

/// Parse a simple CSV produced by [libraryEntriesToCsv] (or compatible).
List<LibraryExportEntry> libraryEntriesFromCsv(String raw) {
  final rows = parseCsvRows(raw);
  if (rows.isEmpty) return [];
  final header = rows.first.map((h) => h.trim().toLowerCase()).toList();
  final titleIdx = header.indexOf('title');
  if (titleIdx < 0) {
    throw const FormatException('CSV missing title column');
  }
  int col(String name) => header.indexOf(name);

  final out = <LibraryExportEntry>[];
  for (var i = 1; i < rows.length; i++) {
    final cells = rows[i];
    String at(int idx) =>
        (idx >= 0 && idx < cells.length) ? cells[idx] : '';
    final title = at(titleIdx).trim();
    if (title.isEmpty) continue;
    out.add(LibraryExportEntry(
      title: title,
      author: at(col('author')).isEmpty ? null : at(col('author')),
      sourceName: at(col('sourcename')),
      url: at(col('url')),
      status: at(col('status')).isEmpty ? null : at(col('status')),
      lang: at(col('lang')),
      genres: at(col('genres'))
          .split(';')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
      tags: at(col('tags'))
          .split(';')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
      chapterCount: int.tryParse(at(col('chaptercount')).trim()) ?? 0,
      unreadCount: int.tryParse(at(col('unreadcount')).trim()),
    ));
  }
  return out;
}

/// Splits CSV text into rows of cells. Quoted cells may contain commas,
/// doubled quotes and line breaks ([csvEscape] quotes descriptions with
/// newlines), so records can't be found by splitting on newlines first.
/// Blank records are dropped.
List<List<String>> parseCsvRows(String raw) {
  final rows = <List<String>>[];
  var row = <String>[];
  final buf = StringBuffer();
  var inQuotes = false;

  void endRow() {
    row.add(buf.toString());
    buf.clear();
    if (row.length > 1 || row.first.trim().isNotEmpty) rows.add(row);
    row = <String>[];
  }

  for (var i = 0; i < raw.length; i++) {
    final c = raw[i];
    if (inQuotes) {
      if (c == '"') {
        if (i + 1 < raw.length && raw[i + 1] == '"') {
          buf.write('"');
          i++;
        } else {
          inQuotes = false;
        }
      } else {
        buf.write(c);
      }
    } else if (c == '"') {
      inQuotes = true;
    } else if (c == ',') {
      row.add(buf.toString());
      buf.clear();
    } else if (c == '\n' || c == '\r') {
      if (c == '\r' && i + 1 < raw.length && raw[i + 1] == '\n') i++;
      endRow();
    } else {
      buf.write(c);
    }
  }
  if (buf.isNotEmpty || row.isNotEmpty) endRow();
  return rows;
}

bool _sameSeries(Manga manga, LibraryExportEntry entry) {
  if (entry.url.isNotEmpty && manga.url.isNotEmpty) {
    return manga.url == entry.url;
  }
  return manga.title.toLowerCase() == entry.title.toLowerCase();
}

class LibraryImportResult {
  const LibraryImportResult({
    required this.created,
    required this.updated,
    required this.tagsAssigned,
    required this.skipped,
  });

  final int created;
  final int updated;
  final int tagsAssigned;
  final int skipped;
}

/// L10.3 import/export service.
class LibraryImportExportService {
  LibraryImportExportService._();
  static final LibraryImportExportService instance =
      LibraryImportExportService._();

  Future<LibraryExportPayload> buildExport() async {
    final library = await IsarService.instance.getLibraryManga();
    final entries = <LibraryExportEntry>[];
    for (final manga in library) {
      final tags =
          await TagService.instance.getTagsForManga(manga.canonicalKey);
      entries.add(LibraryExportEntry.fromManga(
        manga,
        tagNames: tags.map((t) => t.name).toList(),
      ));
    }
    return LibraryExportPayload(
      version: kLibraryExportVersion,
      exportedAt: DateTime.now(),
      entries: entries,
    );
  }

  Future<String> exportJson() async => (await buildExport()).encodeJson();

  Future<String> exportCsv() async {
    final payload = await buildExport();
    return libraryEntriesToCsv(payload.entries);
  }

  /// Import entries: match by url+source or title+source; create local rows
  /// when missing; assign tags by name.
  Future<LibraryImportResult> importEntries(
    List<LibraryExportEntry> entries,
  ) async {
    var created = 0;
    var updated = 0;
    var tagsAssigned = 0;
    var skipped = 0;

    for (final entry in entries) {
      if (entry.title.trim().isEmpty) {
        skipped++;
        continue;
      }
      try {
        final library = await IsarService.instance.getLibraryManga();
        Manga? manga;
        // An exported serverId only identifies this row if it still points
        // at the same title: ids from another server or install name other
        // series.
        var matchedByServerId = false;
        final exportedId = entry.serverId;
        if (exportedId != null && exportedId != 0) {
          final byId = await IsarService.instance.getMangaByServerId(exportedId);
          if (byId != null && _sameSeries(byId, entry)) {
            manga = byId;
            matchedByServerId = true;
          }
        }
        if (manga == null && entry.url.isNotEmpty) {
          for (final m in library) {
            if (m.url == entry.url &&
                (entry.sourceName.isEmpty ||
                    m.sourceName == entry.sourceName)) {
              manga = m;
              break;
            }
          }
        }
        if (manga == null) {
          final titleLower = entry.title.toLowerCase();
          for (final m in library) {
            if (m.title.toLowerCase() == titleLower &&
                (entry.sourceName.isEmpty ||
                    m.sourceName == entry.sourceName)) {
              manga = m;
              break;
            }
          }
        }

        final localId = stableLocalMangaServerId(
          sourceName: entry.sourceName.isEmpty ? 'import' : entry.sourceName,
          url: entry.url,
          title: entry.title,
        );
        // The minted id may already belong to a stored row that is not in the
        // library (a removed or browsed series); saving a fresh object would
        // replace that row.
        manga ??= await IsarService.instance.getMangaByServerId(localId);

        if (manga == null) {
          manga = Manga()
            ..serverId = localId
            ..title = entry.title
            ..author = entry.author
            ..artist = entry.artist
            ..description = entry.description
            ..status = entry.status
            ..sourceName = entry.sourceName
            ..url = entry.url
            ..thumbnailUrl = entry.thumbnailUrl
            ..lang = entry.lang
            ..genres = List<String>.from(entry.genres)
            ..inLibrary = true
            ..inLibraryAt = DateTime.now().millisecondsSinceEpoch
            ..chapterCount = entry.chapterCount
            ..unreadCount = entry.unreadCount;
          await IsarService.instance.saveManga(manga);
          created++;
        } else {
          manga
            ..author = entry.author ?? manga.author
            ..artist = entry.artist ?? manga.artist
            ..description = entry.description ?? manga.description
            ..status = entry.status ?? manga.status
            ..thumbnailUrl = entry.thumbnailUrl ?? manga.thumbnailUrl;
          if (!manga.inLibrary) {
            manga
              ..inLibrary = true
              ..inLibraryAt = DateTime.now().millisecondsSinceEpoch;
          }
          if (entry.genres.isNotEmpty) {
            manga.genres = List<String>.from(entry.genres);
          }
          List<int>? priorCategories;
          if (matchedByServerId && entry.categoryIds.isNotEmpty) {
            final known = (await IsarService.instance.getCategories())
                .map((c) => c.serverId)
                .toSet();
            final merged = {
              ...manga.categoryIds,
              ...entry.categoryIds.where(known.contains),
            }.toList();
            if (merged.length != manga.categoryIds.length) {
              priorCategories = List<int>.from(manga.categoryIds);
              manga.categoryIds = merged;
            }
          }
          await IsarService.instance.saveManga(manga);
          if (priorCategories != null && manga.serverId > 0) {
            await SyncEngine.instance.syncMangaCategories(
              manga.serverId,
              manga.categoryIds,
              existingCategoryIds: priorCategories,
            );
          }
          updated++;
        }

        for (final tagName in entry.tags) {
          final tag = await TagService.instance.getOrCreateTag(tagName);
          if (tag.id <= 0) continue;
          final ok = await TagService.instance
              .assignTag(manga.canonicalKey, tag.id);
          if (ok) tagsAssigned++;
        }
      } catch (e) {
        debugPrint('[LibraryImportExport] import row failed: $e');
        skipped++;
      }
    }

    return LibraryImportResult(
      created: created,
      updated: updated,
      tagsAssigned: tagsAssigned,
      skipped: skipped,
    );
  }

  Future<LibraryImportResult> importJson(String raw) async {
    final payload = LibraryExportPayload.decodeJson(raw);
    return importEntries(payload.entries);
  }

  Future<LibraryImportResult> importCsv(String raw) async {
    return importEntries(libraryEntriesFromCsv(raw));
  }
}
