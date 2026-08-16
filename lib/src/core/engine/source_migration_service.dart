import 'package:shared_preferences/shared_preferences.dart';

import '../db/models/manga.dart';
import '../logging/logger_service.dart';

class MigrationResult {
  final Map<String, String> matchedSources; // serverSourceName -> localJsExtensionName
  final List<String> serverOnlySources;
  final int totalServerSources;
  final int remappedMangaCount;

  MigrationResult({
    required this.matchedSources,
    required this.serverOnlySources,
    required this.totalServerSources,
    required this.remappedMangaCount,
  });

  bool get hasLocalMatches => matchedSources.isNotEmpty;
  double get localMatchRatio => totalServerSources > 0 ? (matchedSources.length / totalServerSources) : 0.0;
}

class SourceMigrationService {
  static const String keyOnboardingCompleted = 'sunfire_onboarding_completed';
  static const String keyServerUrl = 'sunfire_server_url';
  static const String keyServerAuth = 'sunfire_server_auth';
  static const String keySelectedRepos = 'sunfire_selected_repos';

  static final SourceMigrationService _instance = SourceMigrationService._internal();
  static SourceMigrationService get instance => _instance;
  SourceMigrationService._internal();

  /// Built-in known alias mapping for common community source names
  static const Map<String, String> _knownAliases = {
    'weeb central': 'weeb_central',
    'weebcentral': 'weeb_central',
    'mangadex': 'mangadex',
    'mangakatana': 'mangakatana',
    'manga katana': 'mangakatana',
    'asura': 'asura_scans',
    'asurascans': 'asura_scans',
    'asura scans': 'asura_scans',
    'flamescans': 'flame_scans',
    'flame scans': 'flame_scans',
    'flamecomics': 'flame_scans',
    'flame comics': 'flame_scans',
    'reaper scans': 'reaper_scans',
    'reaperscans': 'reaper_scans',
  };

  /// Normalizes a source name for resilient fuzzy matching.
  /// Example: "MangaDex (EN) [v1.4]" -> "mangadex"
  String normalizeSourceName(String name) {
    var clean = name.toLowerCase();
    // Strip language suffixes like (EN), (ALL), [EN], etc.
    clean = clean.replaceAll(RegExp(r'[\(\[\{].*?[\)\]\}]'), '');
    // Strip non-alphanumeric characters except spaces
    clean = clean.replaceAll(RegExp(r'[^a-z0-9\s]'), '');
    // Collapse multiple whitespace to single space
    clean = clean.replaceAll(RegExp(r'\s+'), ' ');
    clean = clean.trim();
    return clean;
  }

  /// Matches a Suwayomi server source name against available Mangayomi JS extension names.
  /// Returns the matching JS extension filename/identifier, or null if no match found.
  String? matchServerSourceToLocalJs(String serverSourceName, List<String> availableJsExtensions) {
    final normalized = normalizeSourceName(serverSourceName);
    final alphanumericOnly = normalized.replaceAll(RegExp(r'\s+'), '');

    // 1. Direct alias lookup
    if (_knownAliases.containsKey(normalized)) {
      final aliasTarget = _knownAliases[normalized]!;
      for (final ext in availableJsExtensions) {
        final extNormalized = ext.replaceAll('.js', '').replaceAll('local_js_', '').toLowerCase();
        if (extNormalized == aliasTarget || extNormalized.replaceAll('_', '') == aliasTarget.replaceAll('_', '')) {
          return ext;
        }
      }
    }

    // 2. Exact match against extension names (without .js / local_js_ prefix)
    for (final ext in availableJsExtensions) {
      final extClean = ext.replaceAll('.js', '').replaceAll('local_js_', '').toLowerCase();
      final extAlpha = extClean.replaceAll(RegExp(r'[^a-z0-9]'), '');
      
      if (extClean == normalized || extAlpha == alphanumericOnly) {
        return ext;
      }
    }

    // 3. Substring containment match (e.g. "mangadex" in "mangadex_org")
    for (final ext in availableJsExtensions) {
      final extClean = ext.replaceAll('.js', '').replaceAll('local_js_', '').toLowerCase();
      if (extClean.contains(alphanumericOnly) || (alphanumericOnly.length >= 4 && alphanumericOnly.contains(extClean))) {
        return ext;
      }
    }

    return null;
  }

  /// Executes migration matching across all server sources and available JS extensions.
  MigrationResult migrateServerSources({
    required List<String> serverSourceNames,
    required List<String> availableJsExtensions,
    List<Manga>? libraryManga,
  }) {
    final matched = <String, String>{};
    final serverOnly = <String>[];

    for (final serverSource in serverSourceNames) {
      final matchedJs = matchServerSourceToLocalJs(serverSource, availableJsExtensions);
      if (matchedJs != null) {
        matched[serverSource] = matchedJs;
      } else {
        serverOnly.add(serverSource);
      }
    }

    var remappedCount = 0;
    if (libraryManga != null && libraryManga.isNotEmpty) {
      for (final manga in libraryManga) {
        final matchedJs = matchServerSourceToLocalJs(manga.sourceName, availableJsExtensions);
        if (matchedJs != null) {
          remappedCount++;
        }
      }
    }

    LoggerService.instance.logInfo(
      'Server-to-Local Source Migration: ${matched.length}/${serverSourceNames.length} sources matched to on-device JS scrapers ($remappedCount library items remapped)',
      'SourceMigration',
    );

    return MigrationResult(
      matchedSources: matched,
      serverOnlySources: serverOnly,
      totalServerSources: serverSourceNames.length,
      remappedMangaCount: remappedCount,
    );
  }

  /// Checks if one-time onboarding setup has been completed.
  Future<bool> isOnboardingCompleted([SharedPreferences? prefs]) async {
    final sp = prefs ?? await SharedPreferences.getInstance();
    return sp.getBool(keyOnboardingCompleted) ?? false;
  }

  /// Marks onboarding setup as completed and persists settings.
  Future<void> markOnboardingCompleted({
    required String serverUrl,
    String? authHeader,
    List<String>? selectedRepos,
    SharedPreferences? prefs,
  }) async {
    final sp = prefs ?? await SharedPreferences.getInstance();
    await sp.setString(keyServerUrl, serverUrl);
    if (authHeader != null && authHeader.isNotEmpty) {
      await sp.setString(keyServerAuth, authHeader);
    }
    if (selectedRepos != null && selectedRepos.isNotEmpty) {
      await sp.setStringList(keySelectedRepos, selectedRepos);
    }
    await sp.setBool(keyOnboardingCompleted, true);
    await LoggerService.instance.logInfo('Onboarding marked complete. Server: $serverUrl', 'Onboarding');
  }

  /// Resets onboarding state (useful for settings / switching server).
  Future<void> resetOnboarding([SharedPreferences? prefs]) async {
    final sp = prefs ?? await SharedPreferences.getInstance();
    await sp.remove(keyOnboardingCompleted);
    await LoggerService.instance.logInfo('Onboarding state reset', 'Onboarding');
  }
}
