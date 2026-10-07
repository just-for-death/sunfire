/// Cached Suwayomi server capability probe (ISS-066 / SERVER_COMPAT Q7).
///
/// Populated once at connect via [GraphQLClientService.probeServerCapabilities].
/// Callers gate newer schema fields / mutations on these flags instead of
/// try-and-fail round trips.
class ServerCapabilities {
  const ServerCapabilities({
    this.version,
    this.buildType,
    this.buildTime,
    this.hasUserField = false,
    this.hasUserSettings = false,
    this.hasExtensionStores = false,
    this.hasAddManga = false,
    this.hasChapterFetchMarkers = false,
    this.hasCategoryIsDefaultCategory = false,
    this.authModes = const ['NONE', 'BASIC_AUTH', 'SIMPLE_LOGIN', 'UI_LOGIN'],
    this.probed = false,
  });

  static const empty = ServerCapabilities();

  final String? version;
  final String? buildType;
  final String? buildTime;

  /// `MangaType.user` / `ChapterType.user` exist (per-user fields).
  final bool hasUserField;

  /// `userSettings` query + `setUserSettings` mutation exist.
  final bool hasUserSettings;

  /// `extensionStores` query exists (replaces deprecated extensionRepos).
  final bool hasExtensionStores;

  /// Legacy `addManga` mutation still present.
  final bool hasAddManga;

  /// `MangaType.chaptersLastFetchedAt` + `latestFetchedChapter` exist
  /// (ISS-076 targeted chapter refresh).
  final bool hasChapterFetchMarkers;

  /// `CategoryType.isDefaultCategory` exists (server v2.4.2366+).
  final bool hasCategoryIsDefaultCategory;

  /// Known AuthMode enum values from introspection (fallback list if probe fails).
  final List<String> authModes;

  /// True after a successful probe attempt (even if some flags are false).
  final bool probed;

  ServerCapabilities copyWith({
    String? version,
    String? buildType,
    String? buildTime,
    bool? hasUserField,
    bool? hasUserSettings,
    bool? hasExtensionStores,
    bool? hasAddManga,
    bool? hasChapterFetchMarkers,
    bool? hasCategoryIsDefaultCategory,
    List<String>? authModes,
    bool? probed,
  }) {
    return ServerCapabilities(
      version: version ?? this.version,
      buildType: buildType ?? this.buildType,
      buildTime: buildTime ?? this.buildTime,
      hasUserField: hasUserField ?? this.hasUserField,
      hasUserSettings: hasUserSettings ?? this.hasUserSettings,
      hasExtensionStores: hasExtensionStores ?? this.hasExtensionStores,
      hasAddManga: hasAddManga ?? this.hasAddManga,
      hasChapterFetchMarkers: hasChapterFetchMarkers ?? this.hasChapterFetchMarkers,
      hasCategoryIsDefaultCategory:
          hasCategoryIsDefaultCategory ?? this.hasCategoryIsDefaultCategory,
      authModes: authModes ?? this.authModes,
      probed: probed ?? this.probed,
    );
  }

  Map<String, dynamic> toJson() => {
        'version': version,
        'buildType': buildType,
        'buildTime': buildTime,
        'hasUserField': hasUserField,
        'hasUserSettings': hasUserSettings,
        'hasExtensionStores': hasExtensionStores,
        'hasAddManga': hasAddManga,
        'hasChapterFetchMarkers': hasChapterFetchMarkers,
        'hasCategoryIsDefaultCategory': hasCategoryIsDefaultCategory,
        'authModes': authModes,
        'probed': probed,
      };
}
