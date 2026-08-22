import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../db/isar_service.dart';
import '../logging/logger_service.dart';
import '../sync/graphql_client_service.dart';
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

  /// ── CHAPTER PAGES RESOLVER (1. Local Extension -> 2. Local Download -> 3. Server) ──
  Future<ChapterPagesResult> resolveChapterPages({
    required int chapterServerId,
    String? chapterUrl,
    String? sourceName,
  }) async {
    var effectiveSourceName = sourceName;
    var effectiveChapterUrl = chapterUrl;

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
            if (m.url.isEmpty) {
              final searchResults = await QuickJsService.instance.fetchSourceMangaLocal(
                effectiveSourceName,
                searchQuery: m.title,
              );
              if (searchResults.isNotEmpty) {
                final found = searchResults.first;
                final link = (found['link'] ?? found['url'] ?? '').toString();
                if (link.isNotEmpty) {
                  m.url = link;
                  await IsarService.instance.saveManga(m);
                }
              }
            }

            if (m.url.isNotEmpty) {
              final localData = await QuickJsService.instance.fetchMangaDetailsLocal(effectiveSourceName, m.url);
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

    // ── PRIORITY 1: LOCAL EXTENSION SCRAPER (Mangayomi / QuickJS) ─────────
    if (effectiveSourceName != null && effectiveChapterUrl != null && effectiveChapterUrl.isNotEmpty) {
      try {
        final localPages = await QuickJsService.instance.fetchChapterPagesLocal(effectiveSourceName, effectiveChapterUrl);
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

    // ── PRIORITY 1.5: AUTO-RECOVERY ACROSS OTHER INSTALLED LOCAL EXTENSIONS ──
    try {
      final ch = await IsarService.instance.getChapterByServerId(chapterServerId);
      if (ch != null) {
        final m = await IsarService.instance.getMangaByServerId(ch.mangaId);
        if (m != null && m.title.isNotEmpty) {
          // Dynamically query whatever extensions are actually installed on the device
          final installedExtensions = QuickJsService.instance.getInstalledExtensionNames();
          for (final altSource in installedExtensions) {
            if (altSource.toLowerCase() == (effectiveSourceName ?? '').toLowerCase()) continue;
            try {
              final searchResults = await QuickJsService.instance.fetchSourceMangaLocal(
                altSource,
                searchQuery: m.title,
              );
              if (searchResults.isNotEmpty) {
                final found = searchResults.first;
                final link = (found['link'] ?? found['url'] ?? '').toString();
                if (link.isNotEmpty) {
                  final altData = await QuickJsService.instance.fetchMangaDetailsLocal(altSource, link);
                  final chList = (altData['chapters'] ?? altData['chapterList'] ?? altData['epList'] ?? altData['episodes']) as List<dynamic>?;
                  if (chList != null && chList.isNotEmpty) {
                    for (final c in chList) {
                      final cMap = c as Map<String, dynamic>;
                      final cName = cMap['name']?.toString() ?? '';
                      final cUrl = (cMap['url'] ?? cMap['link'])?.toString() ?? '';
                      final cNum = (cMap['chapterNumber'] as num?)?.toDouble() ?? 0.0;
                      final matchFound = cName == ch.name ||
                          (ch.chapterNumber > 0 && cNum == ch.chapterNumber) ||
                          (ch.chapterNumber > 0 && cName.contains('${ch.chapterNumber.toInt()}'));
                      if (matchFound && cUrl.isNotEmpty) {
                        final altPages = await QuickJsService.instance.fetchChapterPagesLocal(altSource, cUrl);
                        if (altPages.isNotEmpty) {
                          ch.url = cUrl;
                          ch.realUrl = cUrl;
                          await IsarService.instance.saveChapter(ch);
                          m.sourceName = altSource;
                          m.url = link;
                          await IsarService.instance.saveManga(m);
                          await LoggerService.instance.logInfo('Auto-recovered ${altPages.length} pages via $altSource for ${m.title}', 'ContentResolver');
                          return ChapterPagesResult(
                            pageUrls: altPages,
                            source: ContentSourceType.localExtension,
                            effectiveSourceName: altSource,
                            isLocalFiles: false,
                          );
                        }
                      }
                    }
                  }
                }
              }
            } catch (_) {}
          }
        }
      }
    } catch (_) {}

    // ── PRIORITY 2: LOCAL DOWNLOADS (Offline Storage) ─────────────────────
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

    // ── PRIORITY 3: SUWAYOMI SERVER PROXY ─────────────────────────────────
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
