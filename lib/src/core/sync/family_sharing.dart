// lib/src/core/sync/family_sharing.dart
//
// FamilySharingService - read-only library sharing between family devices.
// Part of S4.4: Family sharing - read-only library sharing.
//
// Design constraints (deliberate):
// - Export contains NO credentials, tokens, cookies, or server URLs with
//   auth. Only public metadata (title/author/source/url) + read state.
// - Import is READ-ONLY: it produces an in-memory shared shelf. It never
//   writes to Isar, never mutates the local library, and never syncs back.
// - No Isar schema changes (avoids codegen); shelf lives as a JSON file.

import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;

import '../db/isar_service.dart';

/// Share format version. Bump when the schema changes.
const int kFamilyShareVersion = 1;

/// One shared manga entry (public metadata + aggregate read state only).
class SharedMangaEntry {
  const SharedMangaEntry({
    required this.title,
    this.author,
    this.artist,
    this.description,
    this.status,
    this.sourceName = '',
    this.url = '',
    this.thumbnailUrl,
    this.totalChapters = 0,
    this.readChapters = 0,
    this.categories = const [],
  });

  factory SharedMangaEntry.fromJson(Map<String, dynamic> json) {
    final title = json['title']?.toString() ?? '';
    if (title.isEmpty) {
      throw const FormatException('SharedMangaEntry missing title');
    }
    return SharedMangaEntry(
      title: title,
      author: json['author']?.toString(),
      artist: json['artist']?.toString(),
      description: json['description']?.toString(),
      status: json['status']?.toString(),
      sourceName: json['sourceName']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      thumbnailUrl: json['thumbnailUrl']?.toString(),
      totalChapters: (json['totalChapters'] as num?)?.toInt() ?? 0,
      readChapters: (json['readChapters'] as num?)?.toInt() ?? 0,
      categories: (json['categories'] as List?)
              ?.map((c) => c.toString())
              .toList() ??
          const [],
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
  final int totalChapters;
  final int readChapters;
  final List<String> categories;

  double get progress =>
      totalChapters > 0 ? (readChapters / totalChapters).clamp(0.0, 1.0) : 0.0;

  Map<String, dynamic> toJson() => {
        'title': title,
        if (author != null) 'author': author,
        if (artist != null) 'artist': artist,
        if (description != null) 'description': description,
        if (status != null) 'status': status,
        'sourceName': sourceName,
        'url': url,
        if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
        'totalChapters': totalChapters,
        'readChapters': readChapters,
        'categories': categories,
      };
}

/// A complete read-only share payload.
class FamilySharePayload {
  const FamilySharePayload({
    required this.version,
    required this.exportedAt,
    required this.appVersion,
    required this.entries,
  });

  factory FamilySharePayload.fromJson(Map<String, dynamic> json) {
    final version = (json['version'] as num?)?.toInt() ?? 0;
    if (version != kFamilyShareVersion) {
      throw FormatException(
          'Unsupported share version $version (expected $kFamilyShareVersion)');
    }
    final rawEntries = json['entries'];
    if (rawEntries is! List) {
      throw const FormatException('Share payload missing entries list');
    }
    return FamilySharePayload(
      version: version,
      exportedAt: DateTime.fromMillisecondsSinceEpoch(
          (json['exportedAt'] as num?)?.toInt() ?? 0),
      appVersion: json['appVersion']?.toString() ?? 'unknown',
      entries: rawEntries
          .whereType<Map<String, dynamic>>()
          .map((e) => SharedMangaEntry.fromJson(e))
          .toList(),
    );
  }

  final int version;
  final DateTime exportedAt;
  final String appVersion;
  final List<SharedMangaEntry> entries;

  Map<String, dynamic> toJson() => {
        'version': version,
        'exportedAt': exportedAt.millisecondsSinceEpoch,
        'appVersion': appVersion,
        'entryCount': entries.length,
        'entries': entries.map((e) => e.toJson()).toList(),
      };

  /// Encode to a shareable string.
  String encode() => jsonEncode(toJson());

  /// Decode and validate a share string. Throws [FormatException] on any
  /// malformed or version-mismatched input.
  static FamilySharePayload decode(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw const FormatException('Share payload must be a JSON object');
    }
    final payload =
        FamilySharePayload.fromJson(Map<String, dynamic>.from(decoded));
    _assertNoSecrets(raw);
    return payload;
  }

  /// Defense-in-depth: reject payloads containing credential-like keys even
  /// though our own encoder never emits them.
  static void _assertNoSecrets(String raw) {
    const banned = [
      'authToken',
      'authorization',
      'cookie',
      'password',
      'apiKey',
      'api_key',
      'bearer',
      'basic ',
      'session',
      'jwt',
    ];
    final lower = raw.toLowerCase();
    for (final key in banned) {
      if (lower.contains(key.toLowerCase())) {
        throw FormatException(
            'Share payload contains disallowed key material ($key)');
      }
    }
  }
}

/// Service building share payloads from the local library.
class FamilySharingService {
  FamilySharingService._();
  static final FamilySharingService instance = FamilySharingService._();

  /// Export the current library as a shareable JSON string.
  ///
  /// Set [includeReadState] to false to share titles only.
  Future<String> exportLibrary({bool includeReadState = true}) async {
    try {
      final library = await IsarService.instance.getLibraryManga();
      final chaptersByManga =
          await IsarService.instance.getChaptersForMangas(
        library.map((m) => m.canonicalKey).toList(),
      );

      final entries = <SharedMangaEntry>[];
      for (final manga in library) {
        final chapters = chaptersByManga[manga.canonicalKey] ?? const [];
        entries.add(SharedMangaEntry(
          title: manga.title,
          author: manga.author,
          artist: manga.artist,
          description: manga.description,
          status: manga.status,
          sourceName: manga.sourceName,
          url: manga.url,
          thumbnailUrl: manga.thumbnailUrl,
          totalChapters: includeReadState ? chapters.length : 0,
          readChapters: includeReadState
              ? chapters.where((c) => c.isRead).length
              : 0,
          categories: const [],
        ));
      }

      return FamilySharePayload(
        version: kFamilyShareVersion,
        exportedAt: DateTime.now(),
        appVersion: 'sunfire-6',
        entries: entries,
      ).encode();
    } catch (e) {
      debugPrint('[FamilySharing] export failed: $e');
      rethrow;
    }
  }

  /// Import a share string into a validated read-only payload.
  ///
  /// Never writes to Isar. Callers display [FamilySharePayload.entries] as a
  /// read-only shelf.
  FamilySharePayload importShare(String raw) {
    return FamilySharePayload.decode(raw);
  }
}
