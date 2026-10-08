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

  /// Whether the entry was in the library (`favorite: true`) in Tachiyomi.
  /// `null` when the backup omitted the field (older exporters) — treated as
  /// "import" by [TachiBkImportService.planImport].
  final bool? favorite;
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

  /// Refuse anything bigger: real .tachibk files are JSON-only (KBs to low
  /// MBs). Inflating a hostile multi-hundred-MB zip would OOM the device.
  static const int kMaxArchiveBytes = 64 * 1024 * 1024;

  /// Maximum total uncompressed size of all entries (128 MB).
  static const int kMaxUncompressedBytes = 128 * 1024 * 1024;

  /// Maximum number of entries in the archive (prevents zip bombs with many tiny files).
  static const int kMaxEntries = 1000;

  static Future<TachiBkBackup> parsePath(String path) async {
    final bytes = await File(path).readAsBytes();
    return parseBytes(bytes);
  }

  static TachiBkBackup parseBytes(Uint8List bytes) {
    if (bytes.length > kMaxArchiveBytes) {
      throw TachiBkParseException(
        'Backup file is ${bytes.length ~/ (1024 * 1024)} MB; larger than the '
        '${kMaxArchiveBytes ~/ (1024 * 1024)} MB limit. Pick a smaller file.',
      );
    }
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(bytes);
    } catch (e) {
      throw TachiBkParseException('Not a valid .tachibk archive: $e');
    }

    // Zip bomb protection: validate entry count and total uncompressed size
    // BEFORE extracting. ZipDecoder already inflated everything, so we check
    // the inflated sizes now and abort if they exceed limits.
    int totalUncompressed = 0;
    for (final file in archive) {
      if (!file.isFile) continue;
      totalUncompressed += file.size;
      if (totalUncompressed > kMaxUncompressedBytes) {
        throw TachiBkParseException(
          'Archive uncompressed size exceeds ${kMaxUncompressedBytes ~/ (1024 * 1024)} MB limit.',
        );
      }
    }
    if (archive.files.length > kMaxEntries) {
      throw TachiBkParseException(
        'Archive contains ${archive.files.length} entries (max $kMaxEntries).',
      );
    }
    // Detect nested archives (zip bombs often hide nested zips).
    for (final file in archive) {
      if (!file.isFile) continue;
      final name = file.name.toLowerCase();
      if (name.endsWith('.zip') || name.endsWith('.jar') || name.endsWith('.war') ||
          name.endsWith('.ear') || name.endsWith('.apk') || name.endsWith('.tachibk')) {
        throw TachiBkParseException('Nested archives are not allowed in .tachibk files.');
      }
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

    final dynamic decoded;
    try {
      decoded = jsonDecode(utf8.decode(rawBytes));
    } catch (e) {
      throw TachiBkParseException('Could not decode backup.json: $e');
    }
    // A valid-JSON wrong-shape file (top-level list, string, ...) must
    // produce the actionable message, not a bare CastError downstream.
    if (decoded is! Map<String, dynamic>) {
      throw const TachiBkParseException(
        'backup.json has the wrong shape: expected an object with '
        'backupManga/backupCategories/backupSources. Make sure you picked '
        'an unedited Tachiyomi .tachibk file.',
      );
    }
    final Map<String, dynamic> json = decoded;

    final sources = <TachiBkSource>[
      for (final s in (json['backupSources'] as List? ?? const []))
        if (s is Map<String, dynamic>)
          TachiBkSource(
            id: _toInt(s['id'], fallback: null),
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
            sourceId: _toInt(m['source'], fallback: null),
            url: (m['url'] as String? ?? '').trim(),
            title: (m['title'] as String? ?? 'Unknown').trim(),
            lang: (m['lang'] as String? ?? 'en').trim().toLowerCase(),
            favorite: m.containsKey('favorite')
                ? (m['favorite'] == true ||
                    (m['favorite'] is String && m['favorite'].toString().toLowerCase() == 'true') ||
                    _toInt(m['favorite'], fallback: 0) == 1)
                : null,
            categories: [
              for (final c in (m['categories'] as List? ?? const []))
                if (c is String && c.trim().isNotEmpty) c.trim(),
            ],
          ),
    ];

    return TachiBkBackup(sources: sources, manga: manga, categories: categories);
  }

  /// Converts a dynamic value to int, or throws if the value is invalid
  /// and no fallback is provided. For required ID fields, call with
  /// `fallback: null` to reject malformed entries.
  static int _toInt(dynamic value, {int? fallback}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
    }
    if (fallback != null) return fallback;
    throw TachiBkParseException(
      'Required integer field has invalid value: $value (type: ${value.runtimeType})',
    );
  }
}