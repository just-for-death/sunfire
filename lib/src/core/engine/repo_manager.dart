import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../logging/logger_service.dart';
import 'quickjs_service.dart';
import 'source_icon_helper.dart';
import 'source_migration_service.dart';

class RepoSourceItem {
  final String name;
  final String lang;
  final String sourceCodeUrl;
  final String iconUrl;
  final String version;
  final bool isJs;
  final String baseUrl;
  final bool isNsfw;

  const RepoSourceItem({
    required this.name,
    required this.lang,
    required this.sourceCodeUrl,
    required this.iconUrl,
    required this.version,
    required this.isJs,
    this.baseUrl = '',
    this.isNsfw = false,
  });

  factory RepoSourceItem.fromJson(Map<String, dynamic> json, [String repoIndexUrl = '']) {
    var url = json['sourceCodeUrl'] as String? ?? '';
    final pkgPath = json['pkgPath'] as String? ?? '';

    if (url.isEmpty && pkgPath.isNotEmpty && repoIndexUrl.isNotEmpty) {
      final repoBase = repoIndexUrl.replaceAll(RegExp(r'/index\.json$'), '');
      url = '$repoBase/$pkgPath';
    }

    final isJs = (json['sourceCodeLanguage'] == 1) ||
        (json['typeSource'] != null) ||
        (json['isManga'] == true) ||
        url.endsWith('.js') ||
        url.contains('/javascript/') ||
        pkgPath.endsWith('.js') ||
        pkgPath.contains('javascript');

    var icon = json['iconUrl'] as String? ?? '';
    final baseUrl = json['baseUrl'] as String? ?? '';
    final nameStr = json['name'] as String? ?? 'Unknown';

    // Relative repo icons only — never rewrite FOSS asset: URIs or absolute http(s).
    if (icon.isNotEmpty &&
        !icon.startsWith('asset:') &&
        !icon.startsWith('assets/') &&
        !icon.startsWith('http://') &&
        !icon.startsWith('https://') &&
        repoIndexUrl.isNotEmpty) {
      final repoBase = repoIndexUrl.replaceAll(RegExp(r'/index\.json$'), '');
      final cleanIcon = icon.startsWith('/') ? icon.substring(1) : icon;
      icon = '$repoBase/$cleanIcon';
    }

    // Do not fall back to Google Favicons (FOSS / privacy). Prefer bundled asset when name known.
    icon = SourceIconHelper.sanitizeIconUrl(icon, sourceName: nameStr);

    final isNsfw = json['isNsfw'] == true ||
        json['isNsfw'] == 1 ||
        json['nsfw'] == true ||
        json['nsfw'] == 1 ||
        nameStr.toLowerCase().contains('18+') ||
        nameStr.toLowerCase().contains('hentai');

    return RepoSourceItem(
      name: nameStr,
      lang: json['lang'] as String? ?? 'all',
      sourceCodeUrl: url,
      iconUrl: icon,
      version: json['version'] as String? ?? '1.0.0',
      isJs: isJs,
      baseUrl: baseUrl,
      isNsfw: isNsfw,
    );
  }
}

class _ScoredCandidate {
  final RepoSourceItem item;
  final int score;
  const _ScoredCandidate({required this.item, required this.score});
}

class RepoManager {
  static RepoManager? _instance;
  final Dio _dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 15), receiveTimeout: const Duration(seconds: 30)));
  final List<Map<String, String>> _userRepos = [];

  /// First-party Sunfire companion catalog (same 9 sources bundled in the app).
  static const officialIndexUrl =
      'https://raw.githubusercontent.com/just-for-death/mangayomi-extensions/main/index.json';
  static const officialRepoTitle = 'Sunfire Official';

  /// Large third-party MangaYomi catalog (MangaDex, ComicK, etc.).
  static const communityIndexUrl =
      'https://raw.githubusercontent.com/m2k3a/mangayomi-extensions/main/index.json';
  static const communityRepoTitle = 'MangaYomi Community';

  RepoManager._();

  static RepoManager get instance {
    _instance ??= RepoManager._();
    return _instance!;
  }

  List<Map<String, String>> get userConfiguredRepos => List.unmodifiable(_userRepos);

  /// Automatically normalizes user entered repo URLs into standard index.json URLs.
  static String normalizeRepoUrl(String url) {
    var trimmed = url.trim();
    if (trimmed.endsWith('/index.json')) return trimmed;
    if (trimmed.endsWith('/')) trimmed = trimmed.substring(0, trimmed.length - 1);

    if (trimmed.contains('github.com') && !trimmed.contains('raw.githubusercontent.com')) {
      final uri = Uri.tryParse(trimmed);
      if (uri != null && uri.pathSegments.length >= 2) {
        final user = uri.pathSegments[0];
        final repo = uri.pathSegments[1];
        return 'https://raw.githubusercontent.com/$user/$repo/main/index.json';
      }
    }

    if (trimmed.contains('raw.githubusercontent.com') && !trimmed.endsWith('index.json')) {
      return '$trimmed/index.json';
    }

    if (trimmed.contains('.github.io') && !trimmed.endsWith('index.json')) {
      return '$trimmed/index.json';
    }

    return trimmed;
  }

  /// Automatically derives a clean, human-readable repository title from its URL.
  static String deriveRepoTitle(String url) {
    final normalized = normalizeRepoUrl(url);
    if (normalized == officialIndexUrl) return officialRepoTitle;
    if (normalized == communityIndexUrl) return communityRepoTitle;
    final trimmed = url.trim();
    final uri = Uri.tryParse(trimmed);
    if (uri != null) {
      if (uri.host.contains('github.io')) {
        final user = uri.host.split('.').first;
        if (user.isNotEmpty) return user;
      }
      if (uri.host.contains('githubusercontent.com') || uri.host.contains('github.com')) {
        final segments = uri.pathSegments;
        if (segments.isNotEmpty) {
          final user = segments.first;
          final repo = segments.length > 1 ? segments[1] : '';
          if (repo.isNotEmpty && repo != 'mangayomi-extensions' && repo != 'index.json') {
            return '$user ($repo)';
          }
          return user;
        }
      }
      if (uri.host.isNotEmpty) {
        return uri.host;
      }
    }
    return 'Custom Repository';
  }

  void addUserRepo(String name, String url) {
    final normUrl = normalizeRepoUrl(url);
    _userRepos.removeWhere((r) => r['url'] == normUrl || r['url'] == url);
    final effectiveName = (name.isEmpty || name == 'Custom Repo') ? deriveRepoTitle(normUrl) : name;
    _userRepos.add({'name': effectiveName, 'url': normUrl});
  }

  void removeUserRepo(String url) {
    final normUrl = normalizeRepoUrl(url);
    _userRepos.removeWhere((r) => r['url'] == normUrl || r['url'] == url);
  }

  /// Returns a deterministic, collision-free, filesystem-safe cache key for a given repo URL.
  String _cacheKeyFor(String url) {
    final bytes = utf8.encode(url);
    final b64 = base64Url.encode(bytes).replaceAll('=', '');
    if (b64.length <= 80) return b64;
    final prefix = b64.substring(0, 35);
    final suffix = b64.substring(b64.length - 35);
    return '${prefix}_${bytes.length}_$suffix';
  }

  Future<File> _cacheFileFor(String indexUrl) async {
    final dir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${dir.path}/repo_cache');
    if (!await cacheDir.exists()) await cacheDir.create(recursive: true);
    return File('${cacheDir.path}/${_cacheKeyFor(indexUrl)}.json');
  }

  /// Compares two semver strings (e.g. "0.1.5" vs "0.1.2").
  /// Returns > 0 if v1 is newer than v2, < 0 if v2 is newer, 0 if equal.
  static int compareVersions(String v1, String v2) {
    final base1 = v1.split(RegExp(r'[-+]')).first;
    final base2 = v2.split(RegExp(r'[-+]')).first;
    final p1 = base1.replaceAll(RegExp(r'[^0-9\.]'), '').split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final p2 = base2.replaceAll(RegExp(r'[^0-9\.]'), '').split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final maxLen = p1.length > p2.length ? p1.length : p2.length;
    for (var i = 0; i < maxLen; i++) {
      final n1 = i < p1.length ? p1[i] : 0;
      final n2 = i < p2.length ? p2[i] : 0;
      if (n1 != n2) return n1.compareTo(n2);
    }
    final hasPre1 = v1.contains('-');
    final hasPre2 = v2.contains('-');
    if (hasPre1 && !hasPre2) return -1;
    if (!hasPre1 && hasPre2) return 1;
    return 0;
  }

  /// Compares Sunfire's OWN app-version strings, which do NOT follow strict
  /// semver across the release lineage: the stable line restarted at 1.0.0
  /// AFTER the betas reached 11.0.0-beta in time. Under pure semver,
  /// "11.0.0-beta" compares greater than "1.0.0", so a stable→beta migration
  /// would wrongly look like a downgrade.
  ///
  /// Rule: a STABLE build (no "-" prerelease marker) ALWAYS beats any
  /// prerelease build regardless of numeric core; otherwise delegates to
  /// [compareVersions] (which is untouched and stays pure semver for
  /// extension versions).
  static int compareAppVersions(String v1, String v2) {
    final pre1 = v1.contains('-');
    final pre2 = v2.contains('-');
    if (pre1 != pre2) return pre1 ? -1 : 1;
    return compareVersions(v1, v2);
  }

  Future<List<RepoSourceItem>> fetchRepoSources(String indexUrl) async {
    final normalizedUrl = normalizeRepoUrl(indexUrl);
    final cacheFile = await _cacheFileFor(normalizedUrl);
    try {
      final sep = normalizedUrl.contains('?') ? '&' : '?';
      final freshUrl = '$normalizedUrl${sep}_t=${DateTime.now().millisecondsSinceEpoch}';
      final response = await _dio
          .get(freshUrl)
          .timeout(const Duration(seconds: 10));
      final raw = response.data is String
          ? response.data as String
          : jsonEncode(response.data);
      // A failed cache write must never discard the freshly fetched index —
      // the source of truth is the network response, not the cache.
      try {
        await cacheFile.writeAsString(raw);
      } catch (_) {
        LoggerService.instance.logWarning('Repo index cache write failed for $normalizedUrl', 'RepoManager');
      }
      final decoded = jsonDecode(raw);
      final List<dynamic> list;
      if (decoded is List) {
        list = decoded;
      } else if (decoded is Map && decoded['sources'] is List) {
        list = decoded['sources'] as List;
      } else if (decoded is Map && decoded['data'] is List) {
        list = decoded['data'] as List;
      } else {
        list = [];
      }
      return list.whereType<Map<String, dynamic>>().map((item) => RepoSourceItem.fromJson(item, normalizedUrl)).toList();
    } catch (_) {
      if (await cacheFile.exists()) {
        try {
          final cached = await cacheFile.readAsString();
          final decoded = jsonDecode(cached);
          final List<dynamic> list;
          if (decoded is List) {
            list = decoded;
          } else if (decoded is Map && decoded['sources'] is List) {
            list = decoded['sources'] as List;
          } else if (decoded is Map && decoded['data'] is List) {
            list = decoded['data'] as List;
          } else {
            list = [];
          }
          return list.whereType<Map<String, dynamic>>().map((item) => RepoSourceItem.fromJson(item, normalizedUrl)).toList();
        } catch (_) {}
      }
      return [];
    }
  }

  /// Fetches and aggregates sources across multiple repositories.
  /// When multiple repos contain the same source (same name + lang),
  /// the version with the highest semver number is selected.
  Future<List<RepoSourceItem>> fetchCombinedRepoSources(List<String> repoUrls) async {
    final Map<String, RepoSourceItem> bestVersionMap = {};

    final repoResults = await Future.wait(repoUrls.map(fetchRepoSources));
    for (final items in repoResults) {
      for (final item in items) {
        final key = '${item.name}_${item.lang}'.toLowerCase();
        if (!bestVersionMap.containsKey(key)) {
          bestVersionMap[key] = item;
        } else {
          final existing = bestVersionMap[key]!;
          if (compareVersions(item.version, existing.version) > 0) {
            bestVersionMap[key] = item;
          }
        }
      }
    }
    // Deduplicate extensions by canonical source name and lang to prevent host collisions on multi-tenant sites
    final Map<String, RepoSourceItem> dedupMap = {};
    for (final item in bestVersionMap.values) {
      final normName = SourceMigrationService.instance.normalizeSourceName(item.name);
      final fullKey = '${normName}_${item.lang}'.toLowerCase();
      if (!dedupMap.containsKey(fullKey)) {
        dedupMap[fullKey] = item;
      } else {
        final existing = dedupMap[fullKey]!;
        if (compareVersions(item.version, existing.version) > 0 ||
            (compareVersions(item.version, existing.version) == 0 && item.name.length < existing.name.length)) {
          dedupMap[fullKey] = item;
        }
      }
    }

    return dedupMap.values.toList();
  }

  Future<String?> downloadJsSourceCode(String jsUrl) async {
    try {
      final sep = jsUrl.contains('?') ? '&' : '?';
      final freshUrl = '$jsUrl${sep}_t=${DateTime.now().millisecondsSinceEpoch}';
      final response = await _dio.get<String>(
        freshUrl,
        options: Options(
          responseType: ResponseType.plain,
          validateStatus: (status) => status != null && status >= 200 && status < 300,
        ),
      );
      return response.data;
    } catch (e) {
      await LoggerService.instance.logWarning('Failed to download JS from $jsUrl: $e', 'RepoManager');
      return null;
    }
  }

  /// Finds and downloads JS scrapers for EVERY source installed on the user's server.
  /// Fixes:
  /// 1. Dedup uses raw server name (not normalized) so sources with distinct TLDs both install.
  /// 2. Domain-aware matching: "Source.com" prefers "source_com.js" over "source.js".
  /// 3. Full filename scoring: pkg basename match weighted highest.
  Future<List<String>> downloadAndInstallMatchingSources({
    required List<String> serverSourceNames,
    required List<String> userRepoUrls,
  }) async {
    // Fetch all raw sources across all user repositories
    final effectiveRepoUrls = List<String>.from(userRepoUrls);
    if (effectiveRepoUrls.isEmpty) {
      return <String>[];
    }
    final allRepoSources = <RepoSourceItem>[];
    final repoResults = await Future.wait(effectiveRepoUrls.map(fetchRepoSources));
    for (final items in repoResults) {
      allRepoSources.addAll(items);
    }

    final installed = <String>[];
    // Use raw server name (not normalized) as dedup key so distinct domain variants
    // are treated as distinct install targets.
    final installedServerNames = <String>{};

    // Filter unique server source names to prevent redundant download tasks
    final uniqueServerNames = <String>[];
    final seen = <String>{};
    for (final name in serverSourceNames) {
      if (seen.add(name)) {
        uniqueServerNames.add(name);
      }
    }

    // Process in batches of 4 concurrent downloads to prevent sequential download bottlenecks
    const int concurrency = 4;
    for (int i = 0; i < uniqueServerNames.length; i += concurrency) {
      final batch = uniqueServerNames.sublist(
        i,
        (i + concurrency > uniqueServerNames.length) ? uniqueServerNames.length : i + concurrency,
      );

      final batchResults = await Future.wait(batch.map((serverName) async {
        if (installedServerNames.contains(serverName)) return null;

        final cleanServerName = SourceMigrationService.instance.normalizeSourceName(serverName);
        if (cleanServerName.isEmpty) return null;

        // If already installed (e.g. from bundled assets), preserve patched local version
        if (QuickJsService.instance.isSourceInstalledLocally(serverName)) {
          return (installedName: serverName, serverName: serverName);
        }

        // Build a domain-aware key — preserves ".com", ".net" etc for pkg matching
        // e.g. "Source.com" → domain hint "com" → look for "source_com.js" first
        final serverDomainHint = _extractDomainHint(serverName); // e.g. 'com', 'net', ''

        // 1. Gather all candidates matching this server source name
        final candidates = <_ScoredCandidate>[];
        for (final item in allRepoSources) {
          final cleanRepoName = SourceMigrationService.instance.normalizeSourceName(item.name);
          final pkgBase = item.sourceCodeUrl.split('/').last.replaceAll('.js', '');
          final cleanPkg = pkgBase.replaceAll('_', ' ').toLowerCase().trim();
          final alphaRepo = cleanRepoName.replaceAll(' ', '');
          final alphaServer = cleanServerName.replaceAll(' ', '');
          final alphaPkg = cleanPkg.replaceAll(' ', '');

          if (!item.sourceCodeUrl.toLowerCase().endsWith('.js')) continue;

          int score = 0;

          // Exact name match (highest priority)
          if (cleanRepoName == cleanServerName) {
            score += 100;
          } else if (alphaRepo == alphaServer) {
            score += 90;
          } else if (alphaPkg == alphaServer) {
            // Pkg filename exact match
            score += 85;
          } else if (serverDomainHint.isNotEmpty && pkgBase.endsWith('_$serverDomainHint') && alphaRepo.startsWith(alphaServer.replaceAll(serverDomainHint, ''))) {
            // Domain-aware: if server name ends with ".com" and pkg has "_com"
            score += 80;
          } else {
            // Stemmed match (comics→comic, scans→scan)
            final stemServer = _stemName(alphaServer);
            final stemRepo = _stemName(alphaRepo);
            final stemPkg = _stemName(alphaPkg);
            if (stemRepo == stemServer || stemPkg == stemServer) {
              score += 70;
            } else if (alphaServer.length > 4 && alphaRepo.startsWith(alphaServer)) {
              // Prefix match
              score += 50;
            } else if (alphaRepo.length > 4 && alphaServer.startsWith(alphaRepo)) {
              score += 40;
            } else if (alphaServer.length >= 4 && alphaRepo.contains(alphaServer)) {
              // Contains match
              score += 30;
            } else if (alphaRepo.length >= 4 && alphaServer.contains(alphaRepo)) {
              score += 20;
            }
          }

          if (score <= 0) continue;

          // Language bonus: prefer en/all over non-English
          final lang = item.lang.toLowerCase();
          if (lang == 'en' || lang == 'all') score += 10;

          candidates.add(_ScoredCandidate(item: item, score: score));
        }

        if (candidates.isEmpty) {
          await LoggerService.instance.logWarning(
            '✗ No repo match found for server source: $serverName (normalized: $cleanServerName)',
            'RepoManager',
          );
          return null;
        }

        // 2. Sort by score desc, then by version desc
        candidates.sort((a, b) {
          final scoreDiff = b.score.compareTo(a.score);
          if (scoreDiff != 0) return scoreDiff;
          return compareVersions(b.item.version, a.item.version);
        });

        // 3. Filter out non-English unless server source explicitly targets non-English
        final serverLower = serverName.toLowerCase();
        final expectsNonEnglish = serverLower.contains('(fr)') ||
            serverLower.contains('(es)') ||
            serverLower.contains('(ja)') ||
            serverLower.contains('(ar)') ||
            serverLower.contains('(id)') ||
            serverLower.contains('(ko)') ||
            serverLower.contains('(ru)') ||
            serverLower.contains('(pt)') ||
            serverLower.contains('(zh)');

        final prioritized = expectsNonEnglish
            ? candidates
            : candidates.where((c) {
                final lang = c.item.lang.toLowerCase();
                return lang == 'en' || lang == 'all';
              }).toList();

        final listToTry = prioritized.isNotEmpty ? prioritized : candidates;

        // 4. Try candidates sequentially until one downloads successfully
        for (final scored in listToTry) {
          final item = scored.item;
          final jsCode = await downloadJsSourceCode(item.sourceCodeUrl);
          if (jsCode != null && jsCode.trim().isNotEmpty) {
            await QuickJsService.instance.saveLocalExtension(
              item.name,
              jsCode,
              version: item.version,
              iconUrl: item.iconUrl,
            );
            await LoggerService.instance.logInfo(
              '✓ Installed local JS scraper: ${item.name} (${item.lang}) v${item.version} [score=${scored.score}] for server source "$serverName"',
              'RepoManager',
            );
            return (installedName: item.name, serverName: serverName);
          }
        }

        await LoggerService.instance.logWarning(
          '✗ Download failed for all candidates of: $serverName',
          'RepoManager',
        );
        return null;
      }));

      for (final res in batchResults) {
        if (res != null) {
          installed.add(res.installedName);
          installedServerNames.add(res.serverName);
        }
      }
    }

    await LoggerService.instance.logInfo(
      '✓ downloadAndInstallMatchingSources: ${installed.length}/${serverSourceNames.length} server sources installed locally',
      'RepoManager',
    );
    return installed;
  }

  /// Extracts domain extension hint from a source name.
  /// e.g. "source.com" → "com", "sourcename" → ""
  static String _extractDomainHint(String name) {
    final match = RegExp(r'\.(com|net|org|me|cc|to|ru|io|tv)$', caseSensitive: false).firstMatch(name.trim());
    return match?.group(1)?.toLowerCase() ?? '';
  }

  /// Applies word-stemming to an alphanumeric-only source name string.
  static String _stemName(String s) =>
      s.replaceAll(RegExp(r'comics?'), 'comic')
       .replaceAll(RegExp(r'scans?'), 'scan')
       .replaceAll(RegExp(r'mangas?'), 'manga');

  /// ── INSTALL ALL AVAILABLE REPO EXTENSIONS (used during onboarding) ───
  /// Downloads and installs EVERY English / universal JS scraper found across
  /// all user-configured repos — not just those matching the server's sources.
  /// This ensures the device has the full extension library from day one.
  Future<int> downloadAndInstallAllRepoExtensions({
    required List<String> userRepoUrls,
  }) async {
    final effectiveRepoUrls = List<String>.from(userRepoUrls);
    if (effectiveRepoUrls.isEmpty) {
      return 0;
    }

    // Aggregate all sources across repos, keeping the highest version per name+lang
    final allSources = await fetchCombinedRepoSources(effectiveRepoUrls);

    // Only install English and universal scrapers
    final targets = allSources.where((s) {
      final lang = s.lang.toLowerCase();
      return (lang == 'en' || lang == 'all') &&
          s.isJs &&
          s.sourceCodeUrl.isNotEmpty &&
          s.sourceCodeUrl.toLowerCase().endsWith('.js');
    }).toList();

    int installedCount = 0;
    final alreadyInstalledNames = QuickJsService.instance.getInstalledExtensionNames()
        .map((n) => n.trim().toLowerCase())
        .toSet();

    for (final source in targets) {
      final normalizedName = source.name.trim().toLowerCase();
      // Skip if already installed at same or newer version
      if (alreadyInstalledNames.contains(normalizedName)) {
        final currentVer = QuickJsService.instance.getInstalledVersion(source.name);
        if (currentVer.isNotEmpty && compareVersions(source.version, currentVer) <= 0) {
          continue;
        }
      }

      try {
        final jsCode = await downloadJsSourceCode(source.sourceCodeUrl);
        if (jsCode != null && jsCode.trim().isNotEmpty) {
          await QuickJsService.instance.saveLocalExtension(
            source.name,
            jsCode,
            version: source.version,
            iconUrl: source.iconUrl,
          );
          installedCount++;
          alreadyInstalledNames.add(normalizedName);
          await LoggerService.instance.logInfo(
            '✓ Onboarding installed: ${source.name} (${source.lang}) v${source.version}',
            'RepoManager',
          );
        }
      } catch (e) {
        await LoggerService.instance.logWarning(
          'Skipped ${source.name}: $e',
          'RepoManager',
        );
      }
    }

    await LoggerService.instance.logInfo(
      '✓ Onboarding: installed $installedCount extensions from ${effectiveRepoUrls.length} repo(s) (${targets.length} total available)',
      'RepoManager',
    );
    return installedCount;
  }

  /// ── UPDATE ALL INSTALLED EXTENSIONS ──────────────────────────────
  /// Checks configured repositories for newer versions of installed JS extensions
  /// and updates them if a newer version is available.
  Future<int> updateInstalledExtensions(List<String> repoUrls) async {
    if (repoUrls.isEmpty) return 0;
    int updatedCount = 0;
    try {
      final availableSources = await fetchCombinedRepoSources(repoUrls);
      final installedNames = QuickJsService.instance.getInstalledExtensionNames();

      for (final name in installedNames) {
        final currentVer = QuickJsService.instance.getInstalledVersion(name);
        final cleanName = name.replaceAll(RegExp(r'\s*\([a-zA-Z0-9_]+\)$'), '').trim().toLowerCase();

        final normName = SourceMigrationService.instance.normalizeSourceName(name);

        final match = availableSources.firstWhere(
          (s) => s.name.trim().toLowerCase() == cleanName && (s.lang.toLowerCase() == 'en' || s.lang.toLowerCase() == 'all'),
          orElse: () => availableSources.firstWhere(
            (s) => s.name.trim().toLowerCase() == cleanName || SourceMigrationService.instance.normalizeSourceName(s.name) == normName,
            orElse: () => const RepoSourceItem(name: '', version: '', sourceCodeUrl: '', iconUrl: '', lang: '', isJs: true),
          ),
        );

        if (match.sourceCodeUrl.isNotEmpty && match.version.isNotEmpty && currentVer.isNotEmpty) {
          if (compareVersions(match.version, currentVer) > 0) {
            final jsCode = await downloadJsSourceCode(match.sourceCodeUrl);
            if (jsCode != null && jsCode.trim().isNotEmpty) {
              await QuickJsService.instance.saveLocalExtension(
                name,
                jsCode,
                version: match.version,
                iconUrl: match.iconUrl,
              );
              updatedCount++;
              await LoggerService.instance.logInfo(
                '✓ Updated extension: $name from v$currentVer to v${match.version}',
                'RepoManager',
              );
            }
          }
        }
      }
    } catch (e) {
      await LoggerService.instance.logWarning('Auto-update extensions failed: $e', 'RepoManager');
    }
    return updatedCount;
  }
}
