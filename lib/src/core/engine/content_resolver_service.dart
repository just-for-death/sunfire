import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../logging/logger_service.dart';
import '../sync/graphql_client_service.dart';
import 'quickjs_service.dart';

enum ContentSourceType { localExtension, localDownload, suwayomiServer, fallback }

class ChapterPagesResult {
  final List<String> pageUrls;
  final ContentSourceType source;
  final bool isLocalFiles;

  ChapterPagesResult({
    required this.pageUrls,
    required this.source,
    this.isLocalFiles = false,
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
    // ── PRIORITY 1: LOCAL EXTENSION SCRAPER (Mangayomi / QuickJS) ─────────
    if (sourceName != null && chapterUrl != null && chapterUrl.isNotEmpty) {
      try {
        final localPages = await QuickJsService.instance.fetchChapterPagesLocal(sourceName, chapterUrl);
        if (localPages.isNotEmpty) {
          await LoggerService.instance.logInfo('Resolved ${localPages.length} pages via Local Extension ($sourceName)', 'ContentResolver');
          return ChapterPagesResult(
            pageUrls: localPages,
            source: ContentSourceType.localExtension,
            isLocalFiles: false,
          );
        }
      } catch (e) {
        await LoggerService.instance.logWarning('Local extension resolution failed for $sourceName: $e', 'ContentResolver');
      }
    }

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
            isLocalFiles: true,
          );
        }
      }
    } catch (e) {
      await LoggerService.instance.logWarning('Local download check failed: $e', 'ContentResolver');
    }

    // ── PRIORITY 3: SUWAYOMI SERVER PROXY ─────────────────────────────────
    if (GraphQLClientService.instance.isConfigured && chapterServerId > 0) {
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
      isLocalFiles: false,
    );
  }

  /// ── SOURCE MANGA LIST RESOLVER (1. Local Extension -> 2. Suwayomi Server) ──
  Future<List<Map<String, dynamic>>> resolveSourceManga({
    required String sourceId,
    required String sourceName,
    bool isLatest = false,
    int page = 1,
    String? searchQuery,
  }) async {
    // ── PRIORITY 1: LOCAL EXTENSION ───────────────────────────────────────
    try {
      final localResults = await QuickJsService.instance.fetchSourceMangaLocal(
        sourceName,
        isLatest: isLatest,
        page: page,
        searchQuery: searchQuery,
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
        final data = await GraphQLClientService.instance.fetchSourceManga(
          sourceId,
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
      } catch (e) {
        await LoggerService.instance.logWarning('Server manga listing failed for $sourceId: $e', 'ContentResolver');
      }
    }

    return [];
  }
}
