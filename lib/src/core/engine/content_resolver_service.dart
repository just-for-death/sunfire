import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:path_provider/path_provider.dart';

import '../db/isar_service.dart';
import '../logging/logger_service.dart';
import '../sync/graphql_client_service.dart';
import 'javascript/m_client.dart';
import 'quickjs_service.dart';
import 'source_migration_service.dart';

enum ContentSourceType { localExtension, localDownload, suwayomiServer, fallback }

/// Marker file written at the root of `downloads/<chapterId>/` once every page
/// has been verified on disk. Its presence is the ONLY thing that makes a
/// download folder eligible to be resolved as "this chapter is downloaded" —
/// a folder without it is either mid-download or was left behind by a
/// failed/cancelled/paused attempt and must not be treated as complete.
/// Content is the expected page count as plain text, so readers/resolvers
/// can sanity-check the file listing against it.
const String kDownloadCompleteMarkerName = '.download_complete';

Future<bool> isDownloadFolderComplete(Directory chapterDir, {int? expectedPageCount}) async {
  final marker = File('${chapterDir.path}/$kDownloadCompleteMarkerName');
  if (!await marker.exists()) return false;
  if (expectedPageCount == null) return true;
  final raw = (await marker.readAsString()).trim();
  final markedCount = int.tryParse(raw);
  return markedCount != null && markedCount == expectedPageCount;
}

/// Natural numeric sort for downloaded page files (e.g. ch10_p2.jpg before ch10_p10.jpg).
int compareDownloadedPagePaths(String a, String b) {
  final fileNameA = a.split(RegExp(r'[/\\]')).last;
  final fileNameB = b.split(RegExp(r'[/\\]')).last;
  final matchA = RegExp(r'(\d+)(?=\.[^.]+$)').firstMatch(fileNameA) ?? RegExp(r'(\d+)').firstMatch(fileNameA);
  final matchB = RegExp(r'(\d+)(?=\.[^.]+$)').firstMatch(fileNameB) ?? RegExp(r'(\d+)').firstMatch(fileNameB);
  if (matchA != null && matchB != null) {
    final numA = int.tryParse(matchA.group(1)!);
    final numB = int.tryParse(matchB.group(1)!);
    if (numA != null && numB != null && numA != numB) {
      return numA.compareTo(numB);
    }
  }
  return a.compareTo(b);
}

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
  static final ContentResolverService instance = ContentResolverService._();
  ContentResolverService._();

  /// Joins a relative page/thumbnail [path] against [base] using proper URI
  /// resolution instead of naive string concatenation. Naive concat produces
  /// broken URLs when the base already ends with `/` and the path starts with
  /// `/` (`https://host//api/…`), or collapses when the base carries a path.
  /// Absolute http(s) and non-http schemes (data:, asset:) pass through.
  static String resolveRelativeUrl(String base, String path) {
    if (base.isEmpty) return path;
    if (path.startsWith('http://') || path.startsWith('https://') ||
        (path.length >= 2 && path[1] == ':')) {
      return path;
    }
    final uri = Uri.tryParse(base);
    if (uri == null || uri.host.isEmpty) return '$base$path';
    return uri.resolve(path).toString();
  }

  /// ── CHAPTER PAGES RESOLVER (1. Local Download -> 2. Local Extension -> 3. Server) ──
  Future<ChapterPagesResult> resolveChapterPages({
    required int chapterServerId,
    String? chapterUrl,
    String? sourceName,
    // The downloader calls this to get a fresh page list to download INTO
    // downloads/<id>/. It must never resolve against that same (possibly
    // partial) folder, or a retried/resumed download sees its own
    // incomplete output, treats every already-saved file as "the full
    // chapter", and reports itself complete without fetching the rest.
    bool allowLocalDownload = true,
  }) async {
    var effectiveSourceName = sourceName;
    var effectiveChapterUrl = chapterUrl;

    // ── PRIORITY 1: LOCAL DOWNLOADS (Instant Offline Storage) ─────────────
    if (allowLocalDownload && chapterServerId > 0) {
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final chapterDir = Directory('${appDir.path}/downloads/$chapterServerId');
        // Only trust this folder if the download that wrote it finished and
        // verified every page (see kDownloadCompleteMarkerName). Otherwise
        // it's a partial/corrupt leftover from a failed, cancelled, or
        // paused attempt and must fall through to extension/server so the
        // remaining pages actually get fetched.
        if (await chapterDir.exists() && await isDownloadFolderComplete(chapterDir)) {
          final files = await chapterDir.list().toList();
          final localImages = files
              .whereType<File>()
              .where((f) {
                final name = f.path.toLowerCase();
                return name.endsWith('.jpg') ||
                    name.endsWith('.jpeg') ||
                    name.endsWith('.png') ||
                    name.endsWith('.webp') ||
                    name.endsWith('.gif') ||
                    name.endsWith('.bmp');
              })
              .toList();
          localImages.sort((a, b) => compareDownloadedPagePaths(a.path, b.path));
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
        final ch = await IsarService.instance.getChapterByServerId(chapterServerId);
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
      } catch (ignoredError) { if (kDebugMode) debugPrint('[content_resolver_service] ignored error: $ignoredError'); }
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
            } catch (ignoredError) { if (kDebugMode) debugPrint('[content_resolver_service] ignored error: $ignoredError'); }
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
              cleanChapterUrl = resolveRelativeUrl(sourceBaseUrl, path);
            }
          }
        } else if (cleanChapterUrl.startsWith('http')) {
          // Extract base URL from full chapter URL
          try {
            final uri = Uri.parse(cleanChapterUrl);
            sourceBaseUrl = '${uri.scheme}://${uri.host}';
          } catch (ignoredError) { if (kDebugMode) debugPrint('[content_resolver_service] ignored error: $ignoredError'); }
        }

        // Fire FlareSolverr pre-warm in parallel — don't await, let scraping start immediately.
        // By the time images start loading, the session cookie will be ready.
        if (sourceBaseUrl != null) {
          unawaited(MClient.prewarmSession(sourceBaseUrl));
        }

        final localPages = await Future.any([
          QuickJsService.instance.fetchChapterPagesLocal(effectiveSourceName, cleanChapterUrl),
          Future.delayed(const Duration(seconds: 20)).then((_) {
            throw TimeoutException('Local extension scrape timed out after 20s');
          }),
        ]);
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

    // ── PRIORITY 3: SUWAYOMI SERVER PROXY ─────────────────────────────────
    if (GraphQLClientService.instance.isConfigured && chapterServerId > 0 && chapterServerId < 2147483647) {
      try {
        final data = await GraphQLClientService.instance.fetchChapterPages(chapterServerId);
        if (data != null && data.containsKey('fetchChapterPages') && data['fetchChapterPages'] != null) {
          final fetchMap = data['fetchChapterPages'] as Map<String, dynamic>?;
          final rawPages = fetchMap?['pages'] as List<dynamic>?;
          if (rawPages != null && rawPages.isNotEmpty) {
            final serverUrl = GraphQLClientService.instance.baseUrl ?? '';
            final urls = rawPages.map((p) {
              final str = p.toString();
              return resolveRelativeUrl(serverUrl, str);
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
                    ? (rawThumb.startsWith('http') ? rawThumb : resolveRelativeUrl(serverUrl, rawThumb))
                    : null;
                return {
                  'id': map['id'],
                  'title': map['title'] ?? 'Untitled',
                  'thumbnailUrl': thumb,
                  'author': map['author'],
                  'artist': map['artist'],
                  'origin': 'server',
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
