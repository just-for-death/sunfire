// Manga vs Global reader settings scope (Paperback / Mihon style).

import 'dart:async';

import 'package:flutter/foundation.dart' show debugPrint;

import '../../core/db/isar_service.dart';
import '../../core/services/settings_service.dart';
import '../../core/sync/graphql_client_service.dart';
import '../../core/sync/sync_engine.dart' show syncReaderSettingsMeta;

enum ReaderSettingsScope { manga, global }

/// Initial scope from whether this series already has a reading-mode override.
ReaderSettingsScope initialReaderSettingsScope(String? readingModeOverride) {
  final o = readingModeOverride?.trim();
  if (o != null && o.isNotEmpty) return ReaderSettingsScope.manga;
  return ReaderSettingsScope.global;
}

/// Result of applying a reading-mode change under a scope.
class ReadingModePersistPlan {
  const ReadingModePersistPlan({
    required this.globalValue,
    required this.mangaOverride,
    required this.clearMangaOverride,
  });

  /// New global settings value, or null if global must not change.
  final String? globalValue;

  /// New manga override value, or null if override must not be written.
  final String? mangaOverride;

  /// When true, clear the manga override (Global applied while an override existed).
  final bool clearMangaOverride;
}

/// Plan how to persist [modeValue] under [scope].
ReadingModePersistPlan planReadingModePersist({
  required ReaderSettingsScope scope,
  required String modeValue,
  required bool hasManga,
}) {
  if (scope == ReaderSettingsScope.manga && hasManga) {
    return ReadingModePersistPlan(
      globalValue: null,
      mangaOverride: modeValue,
      clearMangaOverride: false,
    );
  }
  return ReadingModePersistPlan(
    globalValue: modeValue,
    mangaOverride: null,
    clearMangaOverride: hasManga,
  );
}

// ── IMP-013: per-series overrides for every reader setting ──────────────────

/// The global reader values an override is resolved against.
class ReaderSettingsValues {
  const ReaderSettingsValues({
    required this.readingMode,
    required this.scaleType,
    required this.pageTransition,
    required this.rotateWidePages,
    required this.cropBorders,
    required this.doublePageDisplayMode,
    required this.doublePageOffset,
    required this.invertTapZones,
  });

  factory ReaderSettingsValues.fromSettings(SettingsService s) => ReaderSettingsValues(
        readingMode: s.readingMode,
        scaleType: s.scaleType,
        pageTransition: s.pageTransition,
        rotateWidePages: s.rotateWidePages,
        cropBorders: s.cropBorders,
        doublePageDisplayMode: s.doublePageDisplayMode,
        doublePageOffset: s.doublePageOffset,
        invertTapZones: s.invertTapZones,
      );

  final String readingMode;
  final String scaleType;
  final String pageTransition;
  final bool rotateWidePages;
  final bool cropBorders;
  final String doublePageDisplayMode;
  final bool doublePageOffset;
  final bool invertTapZones;
}

/// Per-series reader settings. A null field means "use the global value".
/// The reading mode still lives on `Manga.readingModeOverride` (Isar); pass
/// it in through [readingMode] when resolving.
class ReaderSettingsOverride {
  const ReaderSettingsOverride({
    this.readingMode,
    this.scaleType,
    this.pageTransition,
    this.rotateWidePages,
    this.cropBorders,
    this.doublePageDisplayMode,
    this.doublePageOffset,
    this.invertTapZones,
  });

  static const empty = ReaderSettingsOverride();

  final String? readingMode;
  final String? scaleType;
  final String? pageTransition;
  final bool? rotateWidePages;
  final bool? cropBorders;
  final String? doublePageDisplayMode;
  final bool? doublePageOffset;
  final bool? invertTapZones;

  bool get isEmpty => toJson().isEmpty;

  /// Effective values: override where set, [global] otherwise.
  ReaderSettingsValues resolve(ReaderSettingsValues global) => ReaderSettingsValues(
        readingMode: _s(readingMode) ?? global.readingMode,
        scaleType: _s(scaleType) ?? global.scaleType,
        pageTransition: _s(pageTransition) ?? global.pageTransition,
        rotateWidePages: rotateWidePages ?? global.rotateWidePages,
        cropBorders: cropBorders ?? global.cropBorders,
        doublePageDisplayMode: _s(doublePageDisplayMode) ?? global.doublePageDisplayMode,
        doublePageOffset: doublePageOffset ?? global.doublePageOffset,
        invertTapZones: invertTapZones ?? global.invertTapZones,
      );

  /// Sets one key (null clears it back to global). Keys match [toJson].
  ReaderSettingsOverride withValue(String key, Object? value) {
    final m = toJson();
    if (value == null) {
      m.remove(key);
    } else {
      m[key] = value;
    }
    return ReaderSettingsOverride.fromJson(m);
  }

  Map<String, Object> toJson() => {
        if (_s(readingMode) != null) 'readingMode': readingMode!,
        if (_s(scaleType) != null) 'scaleType': scaleType!,
        if (_s(pageTransition) != null) 'pageTransition': pageTransition!,
        if (rotateWidePages != null) 'rotateWidePages': rotateWidePages!,
        if (cropBorders != null) 'cropBorders': cropBorders!,
        if (_s(doublePageDisplayMode) != null) 'doublePageDisplayMode': doublePageDisplayMode!,
        if (doublePageOffset != null) 'doublePageOffset': doublePageOffset!,
        if (invertTapZones != null) 'invertTapZones': invertTapZones!,
      };

  /// Tolerant: unknown keys and wrongly typed values are ignored.
  factory ReaderSettingsOverride.fromJson(Map<String, dynamic>? j) {
    if (j == null) return empty;
    String? s(String k) => j[k] is String ? j[k] as String : null;
    bool? b(String k) => j[k] is bool ? j[k] as bool : null;
    return ReaderSettingsOverride(
      readingMode: s('readingMode'),
      scaleType: s('scaleType'),
      pageTransition: s('pageTransition'),
      rotateWidePages: b('rotateWidePages'),
      cropBorders: b('cropBorders'),
      doublePageDisplayMode: s('doublePageDisplayMode'),
      doublePageOffset: b('doublePageOffset'),
      invertTapZones: b('invertTapZones'),
    );
  }

  static String? _s(String? v) {
    final t = v?.trim();
    return (t == null || t.isEmpty) ? null : t;
  }
}

/// Loads the stored override for [mangaId]. [readingModeOverride] is the
/// Isar `Manga.readingModeOverride`, folded in when the JSON has no mode.
ReaderSettingsOverride loadReaderSettingsOverride(
  SettingsService settings,
  int mangaId, {
  String? readingModeOverride,
}) {
  final o = ReaderSettingsOverride.fromJson(settings.readerOverrideJson(mangaId));
  if (o.readingMode == null && ReaderSettingsOverride._s(readingModeOverride) != null) {
    return o.withValue('readingMode', readingModeOverride!.trim());
  }
  return o;
}

/// Persists [o] for [mangaId] (an empty override deletes the key).
Future<void> saveReaderSettingsOverride(SettingsService settings, int mangaId, ReaderSettingsOverride o) async {
  await settings.setReaderOverrideJson(mangaId, o.isEmpty ? null : o.toJson());
  // IMP-005: roam right away (best-effort; the next chapter open retries).
  unawaited(_pushReaderSettingsAfterSave(settings, mangaId));
}

Future<void> _pushReaderSettingsAfterSave(SettingsService settings, int mangaId) async {
  try {
    if (settings.incognitoMode || !GraphQLClientService.instance.isConfigured) return;
    final manga = await IsarService.instance.getManga(mangaId);
    if (manga == null) return;
    await syncReaderSettingsMeta(manga: manga, settings: settings);
  } catch (e) {
    debugPrint('[ReaderSettings] meta push skipped: $e');
  }
}
