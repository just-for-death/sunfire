import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';

/// Thrown when a `.tachibk` file cannot be parsed as a Tachiyomi/Suwayomi
/// backup archive.
class TachiBkParseException implements Exception {
  final String message;
  const TachiBkParseException(this.message);

  @override
  String toString() => message;
}

/// A source (extension) entry as recorded inside the backup.
class TachiBkSource {
  final int id;
  final String name;
  final String lang;

  const TachiBkSource({required this.id, required this.name, required this.lang});
}

/// One manga entry from `backupManga` in the backup archive.
class TachiBkManga {
  final int sourceId;
  final String url;
  final String title;
  final String lang;
  final bool favorite;
  final List<String> categories;

  const TachiBkManga({
    required this.sourceId,
    required this.url,
    required this.title,
    required this.lang,
    required this.favorite,
    required this.categories,
  });
}

/// Fully parsed `.tachibk` backup.
class TachiBkBackup {
  final List<TachiBkSource> sources;
  final List<TachiBkManga> manga;
  final List<String> categories;

  const TachiBkBackup({
    required this.sources,
    required this.manga,
    required this.categories,
  });
}

/// Parses a `.tachibk` archive (zip containing `Tachiyomi/backup.json`).
class TachiBkParser {
  const TachiBkParser._();

  static Future<TachiBkBackup> parsePath(String path) async {
    final bytes = await File(path).readAsBytes();
    return parseBytes(bytes);
  }

  static TachiBkBackup parseBytes(Uint8List bytes) {
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(bytes);
    } catch (e) {
      throw TachiBkParseException('Not a valid .tachibk archive: $e');
    }

    ArchiveFile? jsonEntry;
    for (final file in archive) {
      if (!file.isFile) continue;
      final name = file.name.replaceAll('\\', '/').toLowerCase();
      if (name.endsWith('backup.json')) {
        // Prefer the canonical Tachiyomi/backup.json path.
        if (name == 'tachiyomi/backup.json' || jsonEntry == null) {
          jsonEntry = file;
        }
      }
    }

    if (jsonEntry == null) {
      throw const TachiBkParseException(
          'The archive has no Tachiyomi/backup.json entry. Make sure you picked a .tachibk backup file.');
    }
    final rawBytes = jsonEntry.readBytes();
    if (!jsonEntry.isFile || rawBytes == null || rawBytes.isEmpty) {
      throw const TachiBkParseException('Tachiyomi/backup.json is empty.');
    }

    final Map<String, dynamic> json;
    try {
      json = jsonDecode(utf8.decode(rawBytes)) as Map<String, dynamic>;
    } catch (e) {
      throw TachiBkParseException('Could not decode backup.json: $e');
    }

    final sources = <TachiBkSource>[
      for (final s in (json['backupSources'] as List? ?? const []))
        if (s is Map<String, dynamic>)
          TachiBkSource(
            id: _toInt(s['id'], fallback: 0),
            name: (s['name'] as String? ?? '').trim(),
            lang: (s['lang'] as String? ?? 'en').trim().toLowerCase(),
          ),
    ];

    final categories = <String>[
      for (final c in (json['backupCategories'] as List? ?? const []))
        if (c is Map<String, dynamic> && (c['name'] as String? ?? '').trim().isNotEmpty)
          (c['name'] as String).trim(),
    ];

    final manga = <TachiBkManga>[
      for (final m in (json['backupManga'] as List? ?? const []))
        if (m is Map<String, dynamic>)
          TachiBkManga(
            sourceId: _toInt(m['source'], fallback: 0),
            url: (m['url'] as String? ?? '').trim(),
            title: (m['title'] as String? ?? 'Unknown').trim(),
            lang: (m['lang'] as String? ?? 'en').trim().toLowerCase(),
            favorite: m['favorite'] == true || _toInt(m['favorite']) == 1,
            categories: [
              for (final c in (m['categories'] as List? ?? const []))
                if (c is String && c.trim().isNotEmpty) c.trim(),
            ],
          ),
    ];

    return TachiBkBackup(sources: sources, manga: manga, categories: categories);
  }

  static int _toInt(dynamic value, {int? fallback}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? (fallback ?? 0);
    return fallback ?? 0;
  }
}