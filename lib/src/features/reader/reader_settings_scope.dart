// Manga vs Global reader settings scope (Paperback / Mihon style).

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
