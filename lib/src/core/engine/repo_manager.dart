import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../logging/logger_service.dart';
import 'quickjs_service.dart';
import 'source_migration_service.dart';

class RepoSourceItem {
  final String name;
  final String lang;
  final String sourceCodeUrl;
  final String iconUrl;
  final String version;
  final bool isJs;

  const RepoSourceItem({
    required this.name,
    required this.lang,
    required this.sourceCodeUrl,
    required this.iconUrl,
    required this.version,
    required this.isJs,
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

    return RepoSourceItem(
      name: json['name'] as String? ?? 'Unknown',
      lang: json['lang'] as String? ?? 'all',
      sourceCodeUrl: url,
      iconUrl: json['iconUrl'] as String? ?? '',
      version: json['version'] as String? ?? '1.0.0',
      isJs: isJs,
    );
  }
}

class RepoManager {
  static RepoManager? _instance;
  final Dio _dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 15), receiveTimeout: const Duration(seconds: 30)));
  final List<Map<String, String>> _userRepos = [];

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

  /// Returns a cache-friendly key for a given repo URL
  String _cacheKeyFor(String url) =>
      url.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_').substring(0, url.length.clamp(0, 60));

  Future<File> _cacheFileFor(String indexUrl) async {
    final dir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${dir.path}/repo_cache');
    if (!await cacheDir.exists()) await cacheDir.create(recursive: true);
    return File('${cacheDir.path}/${_cacheKeyFor(indexUrl)}.json');
  }

  /// Compares two semver strings (e.g. "0.1.5" vs "0.1.2").
  /// Returns > 0 if v1 is newer than v2, < 0 if v2 is newer, 0 if equal.
  static int compareVersions(String v1, String v2) {
    final p1 = v1.replaceAll(RegExp(r'[^0-9\.]'), '').split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final p2 = v2.replaceAll(RegExp(r'[^0-9\.]'), '').split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final maxLen = p1.length > p2.length ? p1.length : p2.length;
    for (var i = 0; i < maxLen; i++) {
      final n1 = i < p1.length ? p1[i] : 0;
      final n2 = i < p2.length ? p2[i] : 0;
      if (n1 != n2) return n1.compareTo(n2);
    }
    return 0;
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
      await cacheFile.writeAsString(raw);
      final list = jsonDecode(raw) as List;
      return list.map((item) => RepoSourceItem.fromJson(item as Map<String, dynamic>, normalizedUrl)).toList();
    } catch (_) {
      if (await cacheFile.exists()) {
        try {
          final cached = await cacheFile.readAsString();
          final list = jsonDecode(cached) as List;
          return list.map((item) => RepoSourceItem.fromJson(item as Map<String, dynamic>, normalizedUrl)).toList();
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

    for (final url in repoUrls) {
      final items = await fetchRepoSources(url);
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
    return bestVersionMap.values.toList();
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

  /// Finds and downloads JS scrapers ONLY for sources installed on the user's server.
  /// - Strictly prioritizes English ('en' or 'all') variants over non-English.
  /// - Automatically falls back to other repository candidate URLs if one returns 404.
  Future<List<String>> downloadAndInstallMatchingSources({
    required List<String> serverSourceNames,
    required List<String> userRepoUrls,
  }) async {
    // Fetch all raw sources across all user repositories without discarding alternative mirrors
    final allRepoSources = <RepoSourceItem>[];
    final effectiveRepoUrls = List<String>.from(userRepoUrls);
    if (effectiveRepoUrls.isEmpty) {
      effectiveRepoUrls.add('https://raw.githubusercontent.com/just-for-death/mangayomi-extensions/main/index.json');
    }
    for (final url in effectiveRepoUrls) {
      final items = await fetchRepoSources(url);
      allRepoSources.addAll(items);
    }

    final installed = <String>[];
    final installedNormalized = <String>{};

    for (final serverName in serverSourceNames) {
      final cleanServerName = SourceMigrationService.instance.normalizeSourceName(serverName);
      if (cleanServerName.isEmpty || installedNormalized.contains(cleanServerName)) {
        continue;
      }

      // 1. Gather all candidates matching this server source name
      final candidates = <RepoSourceItem>[];
      for (final item in allRepoSources) {
        final cleanRepoName = SourceMigrationService.instance.normalizeSourceName(item.name);
        final cleanPkg = SourceMigrationService.instance.normalizeSourceName(item.sourceCodeUrl.split('/').last.replaceAll('.js', ''));
        final isMatch = cleanRepoName == cleanServerName ||
            cleanRepoName.replaceAll('_', '') == cleanServerName.replaceAll('_', '') ||
            cleanPkg == cleanServerName ||
            cleanPkg.replaceAll('_', '') == cleanServerName.replaceAll('_', '') ||
            (cleanServerName.length > 4 && cleanRepoName.startsWith(cleanServerName)) ||
            (cleanRepoName.length > 4 && cleanServerName.startsWith(cleanRepoName));

        if (isMatch &&
            item.sourceCodeUrl.isNotEmpty &&
            item.sourceCodeUrl.toLowerCase().endsWith('.js')) {
          candidates.add(item);
        }
      }

      if (candidates.isEmpty) continue;

      // 2. Sort candidates:
      //    a. English ('en' or 'all') first
      //    b. Higher version first
      candidates.sort((a, b) {
        final aLang = a.lang.toLowerCase();
        final bLang = b.lang.toLowerCase();
        final aIsEn = aLang == 'en' || aLang == 'all';
        final bIsEn = bLang == 'en' || bLang == 'all';

        if (aIsEn && !bIsEn) return -1;
        if (!aIsEn && bIsEn) return 1;

        return compareVersions(b.version, a.version);
      });

      // 3. Filter out non-English variants if English / default source is expected
      final serverLower = serverName.toLowerCase();
      final expectsNonEnglish = serverLower.contains('(fr)') ||
          serverLower.contains('(es)') ||
          serverLower.contains('(ja)') ||
          serverLower.contains('(ar)') ||
          serverLower.contains('(id)') ||
          serverLower.contains('(ko)') ||
          serverLower.contains('(ru)');

      final filteredCandidates = expectsNonEnglish
          ? candidates
          : candidates.where((c) {
              final lang = c.lang.toLowerCase();
              return lang == 'en' || lang == 'all';
            }).toList();

      final listToTry = filteredCandidates.isNotEmpty ? filteredCandidates : candidates;

      // 4. Try candidates sequentially until one downloads successfully (working mirror)
      for (final item in listToTry) {
        final jsCode = await downloadJsSourceCode(item.sourceCodeUrl);
        if (jsCode != null && jsCode.trim().isNotEmpty) {
          await QuickJsService.instance.saveLocalExtension(
            item.name,
            jsCode,
            version: item.version,
            iconUrl: item.iconUrl,
          );
          installed.add(item.name);
          installedNormalized.add(cleanServerName);
          await LoggerService.instance.logInfo(
            '✓ Auto-installed local JS scraper: ${item.name} (${item.lang}) v${item.version} from ${item.sourceCodeUrl}',
            'RepoManager',
          );
          break;
        }
      }
    }
    return installed;
  }

  /// ── INSTALL ALL AVAILABLE REPO EXTENSIONS (used during onboarding) ───
  /// Downloads and installs EVERY English / universal JS scraper found across
  /// all user-configured repos — not just those matching the server's sources.
  /// This ensures the device has the full extension library from day one.
  Future<int> downloadAndInstallAllRepoExtensions({
    required List<String> userRepoUrls,
  }) async {
    final effectiveRepoUrls = List<String>.from(userRepoUrls);
    if (effectiveRepoUrls.isEmpty) {
      effectiveRepoUrls.add('https://raw.githubusercontent.com/just-for-death/mangayomi-extensions/main/index.json');
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

        final match = availableSources.firstWhere(
          (s) => s.name.trim().toLowerCase() == cleanName && (s.lang.toLowerCase() == 'en' || s.lang.toLowerCase() == 'all'),
          orElse: () => availableSources.firstWhere(
            (s) => s.name.trim().toLowerCase() == cleanName,
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
