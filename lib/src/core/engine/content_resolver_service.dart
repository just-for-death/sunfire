import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../db/isar_service.dart';
import '../logging/logger_service.dart';
import '../sync/graphql_client_service.dart';
import 'javascript/m_client.dart';
import 'quickjs_service.dart';
import 'source_migration_service.dart';

enum ContentSourceType { localExtension, localDownload, suwayomiServer, fallback }

class ChapterPagesResult {
  final List<String> pageUrls;
  final ContentSourceType source;
  final bool isLocalFiles;
  final String? effectiveSourceName;

  ChapterPagesResult({
    required this.pageUrls,
    required this.source,
    this.isLocalFiles = false,
    this.effectiveSourceName,
  });
}

class ContentResolverService {
  static ContentResolverService? _instance;
  ContentResolverService._();

  static ContentResolverService get instance {
    _instance ??= ContentResolverService._();
    return _instance!;
  }

  /// ── CHAPTER PAGES RESOLVER (1. Local Download -> 2. Local Extension -> 3. Server) ──
  Future<ChapterPagesResult> resolveChapterPages({
    required int chapterServerId,
    String? chapterUrl,
    String? sourceName,
  }) async {
    var effectiveSourceName = sourceName;
    var effectiveChapterUrl = chapterUrl;

    // ── PRIORITY 1: LOCAL DOWNLOADS (Instant Offline Storage) ─────────────
    if (chapterServerId > 0) {
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final chapterDir = Directory('${appDir.path}/downloads/$chapterServerId');
        if (await chapterDir.exists()) {
          final files = await chapterDir.list().toList();
          final localImages = files.whereType<File>().toList();
          localImages.sort((a, b) => a.path.compareTo(b.path));
          if (localImages.isNotEmpty) {
            final paths = localImages.map((f) => f.path).toList();
            await LoggerService.instance.logInfo('Resolved ${paths.length} pages from Local Storage (Offline Download)', 'ContentResolver');
            return ChapterPagesResult(
              pageUrls: paths,
              source: ContentSourceType.localDownload,
              effectiveSourceName: effectiveSourceName,
              isLocalFiles: true,
            );
          }
        }
      } catch (e) {
        await LoggerService.instance.logWarning('Local download check failed: $e', 'ContentResolver');
      }
    }

    // Map effectiveSourceName to installed local extension name immediately
    if (effectiveSourceName != null) {
      final installedNames = QuickJsService.instance.getInstalledExtensionNames();
      final matchedName = SourceMigrationService.instance.matchServerSourceToLocalJs(effectiveSourceName, installedNames);
      if (matchedName != null) {
        effectiveSourceName = matchedName;
      }
    }

    // Retrieve from local DB if missing
    if (effectiveChapterUrl == null || effectiveChapterUrl.isEmpty || effectiveSourceName == null) {
      try {
        final ch = await IsarService.instance.getChapterByServerId(chapterServerId) ??
            (await IsarService.instance.getAllChapters()).where((c) => c.serverId == chapterServerId || c.id == chapterServerId).firstOrNull;
        if (ch != null) {
          if (effectiveChapterUrl == null || effectiveChapterUrl.isEmpty) {
            effectiveChapterUrl = ch.url.isNotEmpty ? ch.url : ch.realUrl;
          }
          if (effectiveSourceName == null) {
            final m = await IsarService.instance.getMangaByServerId(ch.mangaId);
            effectiveSourceName = m?.sourceName;
            if (effectiveSourceName != null) {
              final installedNames = QuickJsService.instance.getInstalledExtensionNames();
              final matchedName = SourceMigrationService.instance.matchServerSourceToLocalJs(effectiveSourceName, installedNames);
              if (matchedName != null) {
                effectiveSourceName = matchedName;
              }
            }
          }
        }
      } catch (_) {}
    }

    // Auto-detect source name from URL domain if still missing
    if ((effectiveSourceName == null || effectiveSourceName.isEmpty) && effectiveChapterUrl != null && effectiveChapterUrl.isNotEmpty) {
      final installedNames = QuickJsService.instance.getInstalledExtensionNames();
      final urlLower = effectiveChapterUrl.toLowerCase();
      for (final name in installedNames) {
        final code = QuickJsService.instance.getExtensionCode(name);
        if (code != null) {
          final baseUrl = QuickJsService.instance.extractBaseUrl(code);
          if (baseUrl != null && baseUrl.isNotEmpty) {
            try {
              final host = Uri.parse(baseUrl).host.replaceAll('www.', '').toLowerCase();
              if (host.isNotEmpty && urlLower.contains(host)) {
                effectiveSourceName = name;
                break;
              }
            } catch (_) {}
          }
        }
      }
    }

    // ── PRIORITY 2: LOCAL EXTENSION SCRAPER (Mangayomi / QuickJS) ─────────
    if (effectiveSourceName != null && effectiveChapterUrl != null && effectiveChapterUrl.isNotEmpty) {
      try {
        var cleanChapterUrl = effectiveChapterUrl;
        String? sourceBaseUrl; // Track base URL for pre-warming

        if (!cleanChapterUrl.startsWith('http://') && !cleanChapterUrl.startsWith('https://')) {
          final jsCode = QuickJsService.instance.getExtensionCode(effectiveSourceName);
          if (jsCode != null && jsCode.isNotEmpty) {
            final metaUrl = QuickJsService.instance.extractBaseUrl(jsCode);
            if (metaUrl != null && metaUrl.isNotEmpty) {
              sourceBaseUrl = metaUrl.endsWith('/') ? metaUrl.substring(0, metaUrl.length - 1) : metaUrl;
              final path = cleanChapterUrl.startsWith('/') ? cleanChapterUrl : '/$cleanChapterUrl';
              cleanChapterUrl = '$sourceBaseUrl$path';
            }
          }
        } else if (cleanChapterUrl.startsWith('http')) {
          // Extract base URL from full chapter URL
          try {
            final uri = Uri.parse(cleanChapterUrl);
            sourceBaseUrl = '${uri.scheme}://${uri.host}';
          } catch (_) {}
        }

        // Fire FlareSolverr pre-warm in parallel — don't await, let scraping start immediately.
        // By the time images start loading, the session cookie will be ready.
        if (sourceBaseUrl != null) {
          unawaited(MClient.prewarmSession(sourceBaseUrl));
        }

        final localPages = await QuickJsService.instance.fetchChapterPagesLocal(effectiveSourceName, cleanChapterUrl);
        if (localPages.isNotEmpty) {
          await LoggerService.instance.logInfo('Resolved ${localPages.length} pages via Local Extension ($effectiveSourceName)', 'ContentResolver');
          return ChapterPagesResult(
            pageUrls: localPages,
            source: ContentSourceType.localExtension,
            effectiveSourceName: effectiveSourceName,
            isLocalFiles: false,
          );
        }
      } catch (e) {
        await LoggerService.instance.logWarning('Local extension resolution failed for $effectiveSourceName: $e', 'ContentResolver');
      }
    }

    // ── PRIORITY 2: SUWAYOMI SERVER PROXY ─────────────────────────────────
    if (GraphQLClientService.instance.isConfigured && chapterServerId > 0 && chapterServerId < 2147483647) {
      try {
        final data = await GraphQLClientService.instance.fetchChapterPages(chapterServerId);
        if (data != null && data.containsKey('fetchChapterPages')) {
          final rawPages = data['fetchChapterPages']['pages'] as List<dynamic>?;
          if (rawPages != null && rawPages.isNotEmpty) {
            final serverUrl = GraphQLClientService.instance.baseUrl ?? 'http://localhost:4567';
            final urls = rawPages.map((p) {
              final str = p.toString();
              return str.startsWith('http') ? str : '$serverUrl$str';
            }).toList();
            await LoggerService.instance.logInfo('Resolved ${urls.length} pages via Suwayomi Server', 'ContentResolver');
            return ChapterPagesResult(
              pageUrls: urls,
              source: ContentSourceType.suwayomiServer,
              effectiveSourceName: effectiveSourceName,
              isLocalFiles: false,
            );
          }
        }
      } catch (e) {
        await LoggerService.instance.logWarning('Server chapter page fetch failed: $e', 'ContentResolver');
      }
    }

    // ── FALLBACK ──────────────────────────────────────────────────────────
    return ChapterPagesResult(
      pageUrls: [],
      source: ContentSourceType.fallback,
      effectiveSourceName: effectiveSourceName,
      isLocalFiles: false,
    );
  }


  Future<List<Map<String, dynamic>>> resolveSourceManga({
    required String sourceId,
    required String sourceName,
    bool isLatest = false,
    int page = 1,
    String? searchQuery,
    String? selectedSort,
    String? selectedStatus,
    String? selectedType,
    List<dynamic>? dynamicFilters,
  }) async {
    // ── PRIORITY 1: LOCAL EXTENSION ───────────────────────────────────────
    try {
      final localResults = await QuickJsService.instance.fetchSourceMangaLocal(
        sourceName,
        isLatest: isLatest,
        page: page,
        searchQuery: searchQuery,
        selectedSort: selectedSort,
        selectedStatus: selectedStatus,
        selectedType: selectedType,
        dynamicFilters: dynamicFilters,
      );
      if (localResults.isNotEmpty) {
        await LoggerService.instance.logInfo('Fetched ${localResults.length} titles via Local Extension ($sourceName)', 'ContentResolver');
        return localResults;
      }
    } catch (e) {
      await LoggerService.instance.logWarning('Local extension manga listing failed for $sourceName: $e', 'ContentResolver');
    }

    // ── PRIORITY 2: SUWAYOMI SERVER ───────────────────────────────────────
    if (GraphQLClientService.instance.isConfigured) {
      try {
        var queryServerId = sourceId;
        if (int.tryParse(queryServerId) == null) {
          final sourcesData = await GraphQLClientService.instance.fetchSources();
          if (sourcesData != null && sourcesData.containsKey('sources')) {
            final nodes = sourcesData['sources']['nodes'] as List<dynamic>?;
            if (nodes != null) {
              final targetClean = SourceMigrationService.instance.normalizeSourceName(sourceName);
              for (final n in nodes) {
                final map = n as Map<String, dynamic>;
                final nameClean = SourceMigrationService.instance.normalizeSourceName(map['name'] as String? ?? '');
                final dispClean = SourceMigrationService.instance.normalizeSourceName(map['displayName'] as String? ?? '');
                if (nameClean == targetClean ||
                    dispClean == targetClean ||
                    nameClean.contains(targetClean) ||
                    targetClean.contains(nameClean)) {
                  queryServerId = map['id'].toString();
                  break;
                }
              }
            }
          }
        }

        if (int.tryParse(queryServerId) != null) {
          final data = await GraphQLClientService.instance.fetchSourceManga(
            queryServerId,
            isLatest: isLatest,
            page: page,
            searchQuery: searchQuery,
          );
          if (data != null && data.containsKey('fetchSourceManga')) {
            final payload = data['fetchSourceManga'] as Map<String, dynamic>;
            final nodes = payload['mangas'] as List<dynamic>?;
            if (nodes != null) {
              final serverUrl = GraphQLClientService.instance.baseUrl ?? '';
              return nodes.map((n) {
                final map = n as Map<String, dynamic>;
                final rawThumb = map['thumbnailUrl'] as String?;
                final thumb = (rawThumb != null && rawThumb.isNotEmpty)
                    ? (rawThumb.startsWith('http') ? rawThumb : '$serverUrl$rawThumb')
                    : null;
                return {
                  'id': map['id'],
                  'title': map['title'] ?? 'Untitled',
                  'thumbnailUrl': thumb,
                  'author': map['author'],
                  'artist': map['artist'],
                };
              }).toList();
            }
          }
        }
      } catch (e) {
        await LoggerService.instance.logWarning('Server manga listing failed for $sourceId: $e', 'ContentResolver');
      }
    }

    return [];
  }
}
