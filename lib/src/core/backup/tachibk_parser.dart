import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
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

/// Parses a `.tachibk` backup. Tachiyomi, Mihon and their forks write
/// gzip-compressed protobuf (the `Backup` message); some third-party exporters
/// write a zip holding `Tachiyomi/backup.json`. Both are accepted.
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
    if (bytes.length >= 2 && bytes[0] == 0x50 && bytes[1] == 0x4B) {
      return _parseZipJson(bytes);
    }
    final proto = bytes.length >= 2 && bytes[0] == 0x1F && bytes[1] == 0x8B
        ? _gunzipCapped(bytes)
        : bytes;
    try {
      return _parseProtobuf(proto);
    } on TachiBkParseException {
      rethrow;
    } catch (_) {
      throw const TachiBkParseException(
          'Not a valid .tachibk backup. Make sure you picked a backup created by Tachiyomi, Mihon or a fork.');
    }
  }

  static Uint8List _gunzipCapped(Uint8List bytes) {
    final out = BytesBuilder(copy: false);
    final input = gzip.decoder.startChunkedConversion(_CappedSink(out, kMaxUncompressedBytes));
    try {
      const chunk = 64 * 1024;
      for (var i = 0; i < bytes.length; i += chunk) {
        input.add(Uint8List.sublistView(bytes, i, math.min(i + chunk, bytes.length)));
      }
      input.close();
    } on TachiBkParseException {
      rethrow;
    } catch (e) {
      throw TachiBkParseException('Could not decompress the backup: $e');
    }
    return out.takeBytes();
  }

  // Field numbers from Mihon's `Backup`, `BackupManga`, `BackupCategory` and
  // `BackupSource` (`@ProtoNumber`). Manga reference categories by their
  // `order`, not by name or id.
  static TachiBkBackup _parseProtobuf(Uint8List bytes) {
    final root = _ProtoMessage.decode(bytes);

    final categoryByOrder = <int, String>{};
    final orderedCategories = <({int order, String name})>[];
    for (final raw in root.messages(2)) {
      final name = raw.string(1).trim();
      if (name.isEmpty) continue;
      final order = raw.integer(2);
      categoryByOrder[order] = name;
      orderedCategories.add((order: order, name: name));
    }
    orderedCategories.sort((a, b) => a.order.compareTo(b.order));

    final sources = <TachiBkSource>[
      for (final raw in root.messages(101))
        TachiBkSource(id: raw.integer(2), name: raw.string(1).trim(), lang: ''),
    ];

    final manga = <TachiBkManga>[
      for (final raw in root.messages(1))
        TachiBkManga(
          sourceId: raw.integer(1),
          url: raw.string(2).trim(),
          title: raw.string(3).trim().isEmpty ? 'Unknown' : raw.string(3).trim(),
          lang: '',
          favorite: raw.has(100) ? raw.integer(100) != 0 : true,
          categories: [
            for (final order in raw.integers(17))
              if (categoryByOrder[order] case final name?) name,
          ],
        ),
    ];

    if (manga.isEmpty && orderedCategories.isEmpty && sources.isEmpty) {
      throw const TachiBkParseException('The backup contains no manga, categories or sources.');
    }
    return TachiBkBackup(
      sources: sources,
      manga: manga,
      categories: [for (final c in orderedCategories) c.name],
    );
  }

  static TachiBkBackup _parseZipJson(Uint8List bytes) {
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

class _CappedSink implements Sink<List<int>> {
  _CappedSink(this._out, this._limit);

  final BytesBuilder _out;
  final int _limit;

  @override
  void add(List<int> data) {
    if (_out.length + data.length > _limit) {
      throw TachiBkParseException(
        'Backup uncompressed size exceeds ${_limit ~/ (1024 * 1024)} MB limit.',
      );
    }
    _out.add(data);
  }

  @override
  void close() {}
}

/// Minimal protobuf wire-format reader: fields are kept as varints (int) or
/// length-delimited views (Uint8List) and interpreted by the caller, which
/// knows the schema. Fixed-width fields are skipped; nothing here needs them.
class _ProtoMessage {
  _ProtoMessage._(this._fields);

  final Map<int, List<Object>> _fields;

  static _ProtoMessage decode(Uint8List bytes) {
    final fields = <int, List<Object>>{};
    var pos = 0;

    int varint() {
      var result = 0;
      for (var shift = 0; shift < 70; shift += 7) {
        if (pos >= bytes.length) throw const FormatException('truncated varint');
        final b = bytes[pos++];
        if (shift < 64) result |= (b & 0x7F) << shift;
        if (b & 0x80 == 0) return result;
      }
      throw const FormatException('varint too long');
    }

    void advance(int n) {
      if (n < 0 || pos + n > bytes.length) throw const FormatException('truncated field');
      pos += n;
    }

    while (pos < bytes.length) {
      final tag = varint();
      final field = tag >>> 3;
      if (field == 0) throw const FormatException('field number 0');
      switch (tag & 7) {
        case 0:
          (fields[field] ??= []).add(varint());
        case 1:
          advance(8);
        case 2:
          final len = varint();
          final start = pos;
          advance(len);
          (fields[field] ??= []).add(Uint8List.sublistView(bytes, start, start + len));
        case 5:
          advance(4);
        default:
          throw FormatException('unsupported wire type ${tag & 7}');
      }
    }
    return _ProtoMessage._(fields);
  }

  bool has(int field) => _fields.containsKey(field);

  int integer(int field) {
    final v = _fields[field];
    if (v == null) return 0;
    final last = v.last;
    return last is int ? last : 0;
  }

  String string(int field) {
    final v = _fields[field];
    if (v == null) return '';
    final last = v.last;
    return last is Uint8List ? utf8.decode(last, allowMalformed: true) : '';
  }

  Iterable<_ProtoMessage> messages(int field) sync* {
    for (final v in _fields[field] ?? const <Object>[]) {
      if (v is Uint8List) yield decode(v);
    }
  }

  /// Repeated integers, packed or not.
  List<int> integers(int field) {
    final out = <int>[];
    for (final v in _fields[field] ?? const <Object>[]) {
      if (v is int) {
        out.add(v);
      } else if (v is Uint8List) {
        var pos = 0;
        while (pos < v.length) {
          var result = 0;
          var shift = 0;
          while (true) {
            if (pos >= v.length) throw const FormatException('truncated packed varint');
            final b = v[pos++];
            if (shift < 64) result |= (b & 0x7F) << shift;
            if (b & 0x80 == 0) break;
            shift += 7;
            if (shift >= 70) throw const FormatException('varint too long');
          }
          out.add(result);
        }
      }
    }
    return out;
  }
}
