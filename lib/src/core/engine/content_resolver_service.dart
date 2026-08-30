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
      } catch (_) {}
    }

    // If chapter URL is still missing, scrape the manga details locally to hydrate chapters with real URLs!
    if ((effectiveChapterUrl == null || effectiveChapterUrl.isEmpty) && effectiveSourceName != null) {
      try {
        final ch = await IsarService.instance.getChapterByServerId(chapterServerId);
        if (ch != null) {
          final m = await IsarService.instance.getMangaByServerId(ch.mangaId);
          if (m != null) {
            final mangaLookup = m.url.isNotEmpty ? m.url : m.title;
            final localData = await QuickJsService.instance.fetchMangaDetailsLocal(effectiveSourceName, mangaLookup);
            if (localData.isNotEmpty) {
              if (m.url.isEmpty && localData['url'] != null) {
                m.url = localData['url'].toString();
                await IsarService.instance.saveManga(m);
              }
              final chList = (localData['chapters'] ?? localData['chapterList'] ?? localData['epList'] ?? localData['episodes']) as List<dynamic>?;
              if (chList != null && chList.isNotEmpty) {
                // Pre-extract chapter numbers from scraped list
                final parsedScraped = <Map<String, dynamic>>[];
                for (final c in chList) {
                  final cMap = Map<String, dynamic>.from(c as Map);
                  final cName = cMap['name']?.toString() ?? '';
                  final cUrl = (cMap['url'] ?? cMap['link'])?.toString() ?? '';
                  double parsedNum = -1.0;
                  if (cMap['chapterNumber'] != null) {
                    parsedNum = (cMap['chapterNumber'] as num).toDouble();
                  } else {
                    final numMatch = RegExp(r'(?:ch(?:apter)?\.?|episode|#)?\s*(\d+(?:\.\d+)?)', caseSensitive: false).firstMatch(cName);
                    if (numMatch != null) {
                      parsedNum = double.tryParse(numMatch.group(1)!) ?? -1.0;
                    }
                  }
                  parsedScraped.add({
                    'name': cName,
                    'url': cUrl,
                    'num': parsedNum,
                  });
                }

                // 1. Exact name match or chapter number match
                for (final p in parsedScraped) {
                  final cName = p['name'] as String;
                  final cUrl = p['url'] as String;
                  final pNum = p['num'] as double;

                  final numMatches = ch.chapterNumber > 0 && pNum > 0 && (pNum - ch.chapterNumber).abs() < 0.001;
                  final nameMatches = cName.trim().toLowerCase() == ch.name.trim().toLowerCase();

                  if (numMatches || nameMatches) {
                    effectiveChapterUrl = cUrl;
                    ch.url = cUrl;
                    ch.realUrl = cUrl;
                    await IsarService.instance.saveChapter(ch);
                    break;
                  }
                }

                if ((effectiveChapterUrl == null || effectiveChapterUrl.isEmpty) && parsedScraped.isNotEmpty) {
                  effectiveChapterUrl = parsedScraped.first['url'] as String?;
                  if (effectiveChapterUrl != null) {
                    ch.url = effectiveChapterUrl;
                    ch.realUrl = effectiveChapterUrl;
                    await IsarService.instance.saveChapter(ch);
                  }
                }
              }
            }
          }
        }
      } catch (_) {}
    }

    // ── PRIORITY 2: LOCAL EXTENSION SCRAPER (Mangayomi / QuickJS) ─────────
    if (effectiveSourceName != null && effectiveChapterUrl != null && effectiveChapterUrl.isNotEmpty) {
      try {
        var cleanChapterUrl = effectiveChapterUrl;
        String? sourceBaseUrl; // Track base URL for pre-warming

        if (cleanChapterUrl.startsWith('/')) {
          final jsCode = QuickJsService.instance.getExtensionCode(effectiveSourceName);
          if (jsCode != null && jsCode.isNotEmpty) {
            final metaUrl = QuickJsService.instance.extractBaseUrl(jsCode);
            if (metaUrl != null && metaUrl.isNotEmpty) {
              sourceBaseUrl = metaUrl.endsWith('/') ? metaUrl.substring(0, metaUrl.length - 1) : metaUrl;
              cleanChapterUrl = '$sourceBaseUrl$cleanChapterUrl';
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

        // Fallback: If 0 pages were returned (e.g. invalid stub URL or manga URL saved on chapter), re-hydrate from manga details
        if (localPages.isEmpty && chapterServerId > 0) {
          final ch = await IsarService.instance.getChapterByServerId(chapterServerId);
          if (ch != null) {
            final m = await IsarService.instance.getMangaByServerId(ch.mangaId);
            if (m != null && m.url.isNotEmpty) {
              final localData = await QuickJsService.instance.fetchMangaDetailsLocal(effectiveSourceName, m.url);
              final chList = (localData['chapters'] ?? localData['chapterList'] ?? localData['epList'] ?? localData['episodes']) as List<dynamic>?;
              if (chList != null && chList.isNotEmpty) {
                for (final c in chList) {
                  final cMap = Map<String, dynamic>.from(c as Map);
                  final cName = cMap['name']?.toString() ?? '';
                  final cUrl = (cMap['url'] ?? cMap['link'])?.toString() ?? '';
                  final double rawNum = (cMap['chapterNumber'] as num?)?.toDouble() ?? -1.0;
                  final numMatches = ch.chapterNumber > 0 && rawNum > 0 && (rawNum - ch.chapterNumber).abs() < 0.001;
                  final nameMatches = cName.trim().toLowerCase() == ch.name.trim().toLowerCase();
                  if ((numMatches || nameMatches) && cUrl.isNotEmpty && cUrl != cleanChapterUrl) {
                    ch.url = cUrl;
                    ch.realUrl = cUrl;
                    await IsarService.instance.saveChapter(ch);
                    final retryPages = await QuickJsService.instance.fetchChapterPagesLocal(effectiveSourceName, cUrl);
                    if (retryPages.isNotEmpty) {
                      await LoggerService.instance.logInfo('Re-hydrated and resolved ${retryPages.length} pages via Local Extension ($effectiveSourceName)', 'ContentResolver');
                      return ChapterPagesResult(
                        pageUrls: retryPages,
                        source: ContentSourceType.localExtension,
                        effectiveSourceName: effectiveSourceName,
                        isLocalFiles: false,
                      );
                    }
                  }
                }
              }
            }
          }
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
