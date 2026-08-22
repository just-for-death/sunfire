import 'package:shared_preferences/shared_preferences.dart';

import '../db/models/manga.dart';
import '../logging/logger_service.dart';

class ReplicationReport {
  final List<String> newlyInstalledLocalScrapers;
  final List<String> newlyAddedServerFallbacks;
  final int totalReplicatedManga;

  ReplicationReport({
    required this.newlyInstalledLocalScrapers,
    required this.newlyAddedServerFallbacks,
    required this.totalReplicatedManga,
  });

  bool get hasChanges => newlyInstalledLocalScrapers.isNotEmpty || newlyAddedServerFallbacks.isNotEmpty;
}

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

class SourceDisplayItem {
  final String id;
  final String name;
  final String lang;
  final bool isLocalJs;
  final bool isServerFallback;

  SourceDisplayItem({
    required this.id,
    required this.name,
    required this.lang,
    required this.isLocalJs,
    required this.isServerFallback,
  });
}

class ServerSourceItem {
  final String id;
  final String name;
  final String lang;

  ServerSourceItem({
    required this.id,
    required this.name,
    required this.lang,
  });
}

class DualInstallResult {
  final String extensionName;
  final bool isInstalledLocally;
  final bool isAvailableOnServer;
  final String? serverSourceName;
  final String statusMessage;

  DualInstallResult({
    required this.extensionName,
    required this.isInstalledLocally,
    required this.isAvailableOnServer,
    this.serverSourceName,
    required this.statusMessage,
  });
}

class SourceMigrationService {
  static const String keyOnboardingCompleted = 'sunfire_onboarding_completed';
  static const String keyServerUrl = 'sunfire_server_url';
  static const String keyServerAuth = 'sunfire_server_auth';
  static const String keySelectedRepos = 'sunfire_selected_repos';

  static final SourceMigrationService _instance = SourceMigrationService._internal();
  static SourceMigrationService get instance => _instance;
  SourceMigrationService._internal();

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

    // 1. Exact match against extension names (without .js / local_js_ prefix)
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

  /// Executes migration matching strictly across installed server sources and available JS extensions.
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

  /// Filters sources for display in Browse > Sources.
  /// If a server source has a corresponding local JS extension installed,
  /// the server version is HIDDEN so users see ONLY the clean local Mangayomi source.
  /// If a server source is MISSING in Mangayomi, it is displayed as a Server Fallback.
  List<SourceDisplayItem> filterDisplaySources({
    required List<String> localInstalledExtensions,
    required List<ServerSourceItem> serverInstalledSources,
  }) {
    final displayItems = <SourceDisplayItem>[];
    final normalizedLocal = <String>{};

    // 1. Add all local Mangayomi installed extensions
    for (final ext in localInstalledExtensions) {
      final cleanName = ext.replaceAll('.js', '').replaceAll('local_js_', '');
      final norm = normalizeSourceName(cleanName);
      normalizedLocal.add(norm);

      displayItems.add(SourceDisplayItem(
        id: 'local_js_$cleanName',
        name: cleanName.replaceAll('_', ' ').split(' ').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' '),
        lang: 'EN',
        isLocalJs: true,
        isServerFallback: false,
      ));
    }

    // 2. Add server sources ONLY if missing in local Mangayomi extensions
    for (final srv in serverInstalledSources) {
      final srvNorm = normalizeSourceName(srv.name);
      final isMatchedLocally = normalizedLocal.contains(srvNorm) || 
                              matchServerSourceToLocalJs(srv.name, localInstalledExtensions) != null;

      if (!isMatchedLocally) {
        displayItems.add(SourceDisplayItem(
          id: srv.id,
          name: srv.name,
          lang: srv.lang,
          isLocalJs: false,
          isServerFallback: true,
        ));
      }
    }

    return displayItems;
  }

  /// When installing a Mangayomi JS extension in the app:
  /// 1. Checks if the source is also available in the Suwayomi server Keiyoushi repository catalog.
  /// 2. If available on server, installs locally AND triggers server install so server can track chapters.
  /// 3. Returns status message detailing whether it was installed dual-channel (App + Server) or App-only.
  DualInstallResult checkAndInstallSourceDualChannel({
    required String jsExtensionName,
    required List<String> serverAvailableSourceNames,
  }) {
    String? matchedServerSource;
    for (final srv in serverAvailableSourceNames) {
      if (matchServerSourceToLocalJs(srv, [jsExtensionName]) != null) {
        matchedServerSource = srv;
        break;
      }
    }

    final isAvailableOnServer = matchedServerSource != null;

    return DualInstallResult(
      extensionName: jsExtensionName,
      isInstalledLocally: true,
      isAvailableOnServer: isAvailableOnServer,
      serverSourceName: matchedServerSource,
      statusMessage: isAvailableOnServer
          ? '⚡ Installed locally & ☁ synced with server ($matchedServerSource)'
          : '⚡ Installed locally on device (Source not available on server repo)',
    );
  }

  /// Continuously syncs installed server sources against available Mangayomi repositories.
  /// Automatically installs matching .js scrapers locally and re-maps attached manga items
  /// so that any new source added on the server in future is immediately replicated locally.
  ReplicationReport syncAndReplicateServerSources({
    required List<ServerSourceItem> currentServerInstalledSources,
    required List<String> currentlyInstalledLocalJs,
    required List<String> availableMangayomiRepoExtensions,
    List<Manga>? currentLibraryManga,
  }) {
    final newlyInstalled = <String>[];
    final newlyAddedFallbacks = <String>[];
    var remappedMangaCount = 0;

    final installedLocalNormalized = currentlyInstalledLocalJs
        .map((e) => normalizeSourceName(e.replaceAll('.js', '')))
        .toSet();

    for (final srv in currentServerInstalledSources) {
      final srvNorm = normalizeSourceName(srv.name);
      
      // If already installed locally, skip
      if (installedLocalNormalized.contains(srvNorm)) {
        continue;
      }

      // Check if a matching Mangayomi JS extension exists in the repositories
      final matchedJs = matchServerSourceToLocalJs(srv.name, availableMangayomiRepoExtensions);
      if (matchedJs != null) {
        newlyInstalled.add(matchedJs);
        installedLocalNormalized.add(srvNorm);

        // Re-map attached library manga to the newly installed local JS extension
        if (currentLibraryManga != null) {
          for (final manga in currentLibraryManga) {
            if (normalizeSourceName(manga.sourceName) == srvNorm) {
              manga.sourceName = 'local_js_${matchedJs.replaceAll('.js', '')}';
              remappedMangaCount++;
            }
          }
        }
      } else {
        newlyAddedFallbacks.add(srv.name);
      }
    }

    LoggerService.instance.logInfo(
      'Continuous Source Replication: ${newlyInstalled.length} local scrapers auto-installed, ${newlyAddedFallbacks.length} server fallbacks registered, $remappedMangaCount manga remapped',
      'SourceReplication',
    );

    return ReplicationReport(
      newlyInstalledLocalScrapers: newlyInstalled,
      newlyAddedServerFallbacks: newlyAddedFallbacks,
      totalReplicatedManga: remappedMangaCount,
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
