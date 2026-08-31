import 'dart:convert';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../db/isar_service.dart';
import '../db/models/category.dart';
import '../db/models/chapter.dart';
import '../db/models/manga.dart';
import '../db/models/sync_record.dart';
import '../engine/quickjs_service.dart';
import '../engine/repo_manager.dart';
import '../engine/source_migration_service.dart';
import '../logging/logger_service.dart';
import '../services/image_cache_helper.dart';
import '../services/settings_service.dart';
import 'graphql_client_service.dart';

class SyncEngine {
  static SyncEngine? _instance;
  bool _isSyncing = false;
  String? _deviceId;

  SyncEngine._();

  static SyncEngine get instance {
    _instance ??= SyncEngine._();
    return _instance!;
  }

  Future<void> initialize({String? deviceId}) async {
    _deviceId = deviceId ?? 'default_device';
    await LoggerService.instance.logInfo('SyncEngine initialized for deviceId: $_deviceId', 'SyncEngine');
    await triggerSync();
  }

  Future<void> triggerSync() async {
    if (_isSyncing) return;
    if (!GraphQLClientService.instance.isConfigured) {
      return;
    }

    final isServerOnline = await GraphQLClientService.instance.checkServerReachable();
    if (!isServerOnline) {
      // Server is offline — silently keep local authoritative state without firing network queries
      return;
    }

    _isSyncing = true;
    try {
      try {
        await WakelockPlus.enable();
      } catch (e, stack) {
        await LoggerService.instance.logError('Failed to enable wakelock: $e', exception: e, stackTrace: stack, category: 'SyncEngine');
      }
      await LoggerService.instance.logInfo('Starting sync cycle with server...', 'SyncEngine');
      await _flushPendingMutations();
      await _pullServerState();
      await LoggerService.instance.logInfo('Sync cycle completed successfully', 'SyncEngine');
    } catch (e, stack) {
      await LoggerService.instance.logError('Sync cycle error: $e', exception: e, stackTrace: stack, category: 'SyncEngine');
    } finally {
      try {
        await WakelockPlus.disable();
      } catch (e, stack) {
        await LoggerService.instance.logError('Failed to disable wakelock: $e', exception: e, stackTrace: stack, category: 'SyncEngine');
      }
      _isSyncing = false;
    }
  }

  Future<void> _flushPendingMutations() async {
    final pendingRecords = await IsarService.instance.getPendingSyncRecords();
    if (pendingRecords.isEmpty) return;

    // Prioritize Deletion Tombstones first
    final deleteRecords = pendingRecords.where((r) => r.action == SyncAction.delete).toList();
    final otherRecords = pendingRecords.where((r) => r.action != SyncAction.delete).toList();

    final executionList = [...deleteRecords, ...otherRecords];

    for (final record in executionList) {
      try {
        final payload = jsonDecode(record.payloadJson) as Map<String, dynamic>;
        bool success = false;

        switch (record.entityType) {
          case SyncEntityType.chapter:
            if (record.action == SyncAction.update) {
              final chapterId = parseIntSafe(payload['chapterId']);
              final isRead = parseBoolSafe(payload['isRead']);
              final lastPageRead = parseIntSafe(payload['lastPageRead']);
              final res = await GraphQLClientService.instance.updateChapterReadStatus(chapterId, isRead, lastPageRead);
              success = res != null;
            }
            break;
          case SyncEntityType.tracker:
            if (record.action == SyncAction.update) {
              final trackerId = parseIntSafe(payload['trackerId']);
              final mangaId = parseIntSafe(payload['mangaId']);
              final chapterNumber = parseDoubleSafe(payload['chapterNumber']);
              final res = await GraphQLClientService.instance.trackProgress(mangaId, trackerId, chapterNumber);
              success = res != null;
            }
            break;
          case SyncEntityType.manga:
            if (record.action == SyncAction.update || record.action == SyncAction.delete) {
              final mangaId = parseIntSafe(payload['mangaId']);
              final inLibrary = parseBoolSafe(payload['inLibrary']);
              final res = await GraphQLClientService.instance.updateMangaLibraryState(mangaId, inLibrary);
              success = res != null;
            }
            break;
          case SyncEntityType.category:
          case SyncEntityType.source:
            break;
        }

        if (success) {
          await IsarService.instance.deleteSyncRecord(record.id);
        } else {
          record.retryCount += 1;
          record.state = SyncRecordState.failed;
          await IsarService.instance.saveSyncRecord(record);
        }
      } catch (e, stack) {
        record.retryCount += 1;
        record.state = SyncRecordState.failed;
        await IsarService.instance.saveSyncRecord(record);
        await LoggerService.instance.logError('Failed to dispatch SyncRecord #${record.id}: $e', exception: e, stackTrace: stack, category: 'SyncEngine');
      }
    }
  }

  Future<void> _pullServerState() async {
    await _syncCategories();
    await _syncSourcesAndReplicate();
    await _performFullSync();
  }

  Future<void> _syncSourcesAndReplicate() async {
    try {
      final sourcesData = await GraphQLClientService.instance.fetchSources();
      if (sourcesData != null && sourcesData.containsKey('sources')) {
        final nodes = sourcesData['sources']['nodes'] as List<dynamic>?;
        if (nodes != null) {
          final serverSources = nodes.map((n) {
            final m = n as Map<String, dynamic>;
            return ServerSourceItem(
              id: m['id'].toString(),
              name: m['name'] as String? ?? '',
              lang: m['lang'] as String? ?? 'en',
            );
          }).toList();

          final userRepos = SettingsService.instance.customRepos;

          // Auto-download and install matching JS scrapers from user repos
          await RepoManager.instance.downloadAndInstallMatchingSources(
            serverSourceNames: serverSources.map((s) => s.name).toList(),
            userRepoUrls: userRepos,
          );

          final installedLocalJs = QuickJsService.instance.getInstalledExtensionNames();
          final libraryManga = await IsarService.instance.getLibraryManga();

          final allRepoSources = await RepoManager.instance.fetchCombinedRepoSources(userRepos);
          final availableRepoNames = allRepoSources.map((r) => r.name).toList();

          final report = SourceMigrationService.instance.syncAndReplicateServerSources(
            currentServerInstalledSources: serverSources,
            currentlyInstalledLocalJs: installedLocalJs,
            availableMangayomiRepoExtensions: availableRepoNames,
            currentLibraryManga: libraryManga,
          );

          if (report.totalReplicatedManga > 0) {
            await IsarService.instance.saveMangas(libraryManga);
          }
        }
      }
    } catch (e, stack) {
      await LoggerService.instance.logError('Failed to sync sources: $e', exception: e, stackTrace: stack, category: 'SyncEngine');
    }
  }

  Future<void> _syncCategories() async {
    try {
      final data = await GraphQLClientService.instance.fetchCategories();
      if (data != null && data.containsKey('categories')) {
        final nodes = data['categories']['nodes'] as List<dynamic>;
        final categories = <Category>[];
        for (final n in nodes) {
          final map = n as Map<String, dynamic>;
          final cat = Category()
            ..serverId = parseIntSafe(map['id'])
            ..name = map['name'] as String? ?? 'Default'
            ..order = parseIntSafe(map['order'])
            ..isDefault = parseBoolSafe(map['default']);
          categories.add(cat);
        }
        await IsarService.instance.saveCategories(categories);
      }
    } catch (e, stack) {
      await LoggerService.instance.logError('Failed to pull categories: $e', exception: e, stackTrace: stack, category: 'SyncEngine');
    }
  }

  Future<void> _performFullSync() async {
    final nowUnix = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final serverUrl = GraphQLClientService.instance.baseUrl ?? 'http://localhost:4567';

    // ── STEP 1: Read current local count BEFORE touching anything ────────
    final localCountBefore = await IsarService.instance.getMangaCount();

    // ── STEP 2: Pull full library from Suwayomi ───────────────────────────
    bool serverReachable = false;
    try {
      final libData = await GraphQLClientService.instance
          .fetchLibrary()
          .timeout(const Duration(seconds: 8));
      if (libData != null && libData.containsKey('mangas')) {
        serverReachable = true;
        final nodes = libData['mangas']['nodes'] as List<dynamic>;
        final serverMangas = <Manga>[];

        for (final n in nodes) {
          final nodeMap = n as Map<String, dynamic>;
          final serverId = parseIntSafe(nodeMap['id']);
          var manga = await IsarService.instance.getMangaByServerId(serverId);
          manga ??= Manga()..serverId = serverId;

          manga.title = nodeMap['title'] as String? ?? 'Untitled';
          manga.author = nodeMap['author'] as String?;
          manga.description = nodeMap['description'] as String?;
          manga.inLibrary = true;
          manga.inLibraryAt = nodeMap['inLibraryAt'] != null ? int.tryParse(nodeMap['inLibraryAt'].toString()) : null;
          manga.unreadCount = parseIntSafe(nodeMap['unreadCount']);
          manga.lastFetchedAt = nowUnix;

          final rawThumb = nodeMap['thumbnailUrl'] as String?;
          if (rawThumb != null && rawThumb.isNotEmpty) {
            manga.thumbnailUrl = rawThumb.startsWith('http') ? rawThumb : '$serverUrl$rawThumb';
          }

          if (nodeMap.containsKey('categories') && nodeMap['categories'] != null) {
            final catNodes = nodeMap['categories']['nodes'] as List<dynamic>?;
            if (catNodes != null) {
              manga.categoryIds = catNodes.map((c) => parseIntSafe((c as Map<String, dynamic>)['id'])).toList();
            }
          }

          final sourceMap = nodeMap['source'] as Map<String, dynamic>?;
          manga.sourceName = sourceMap?['name'] as String? ?? sourceMap?['displayName'] as String? ?? nodeMap['sourceId']?.toString() ?? 'Unknown Source';
          manga.lang = 'en';

          // Save the manga's URL on the source website — used by local QuickJS extensions
          // to scrape chapters directly when the server is offline.
          if (nodeMap['url'] != null && (nodeMap['url'] as String).isNotEmpty) {
            manga.url = nodeMap['url'] as String;
          }

          serverMangas.add(manga);
        }
        await IsarService.instance.saveMangas(serverMangas);

        // Pre-cache cover images to local disk for offline resilience
        for (final m in serverMangas) {
          if (m.thumbnailUrl != null && m.thumbnailUrl!.isNotEmpty) {
            ImageCacheHelper.cacheThumbnail(m.serverId, m.thumbnailUrl!, sourceName: m.sourceName);
          }
        }

        // ── WIPE GUARD: Never cascade a server wipe to local Isar ─────────
        // If server returned far fewer manga than Isar has, something is wrong
        // (server was wiped/reset). Skip marking local entries as removed.
        final serverCount = serverMangas.length;
        final removalSafe = localCountBefore == 0 ||
            (serverCount > 0 && serverCount >= localCountBefore * 0.3); // server has at least 30% of what we had

        if (removalSafe && serverCount > 0) {
          // Only soft-delete local entries that the server genuinely removed
          final serverIds = serverMangas.map((m) => m.serverId).toSet();
          final localLib = await IsarService.instance.getLibraryManga();
          for (final local in localLib) {
            if (!serverIds.contains(local.serverId)) {
              local.inLibrary = false;
              await IsarService.instance.saveManga(local);
            }
          }
        } else if (serverCount == 0 && localCountBefore > 0) {
          await LoggerService.instance.logWarning(
            'WIPE GUARD TRIGGERED: server returned 0 manga but Isar had $localCountBefore. Keeping local data safe.',
            'SyncEngine'
          );
        } else if (!removalSafe) {
          await LoggerService.instance.logWarning(
            'WIPE GUARD TRIGGERED: server returned $serverCount manga but Isar had $localCountBefore. '
            'Skipping removal cascade — local data preserved. Pull-to-refresh to re-sync manually.',
            'SyncEngine',
          );
        }
      }
    } catch (e) {
      await LoggerService.instance.logInfo('Server unreachable for library sync, skipping server pull ($e)', 'SyncEngine');
      return; // Server is offline — immediately return to keep local data untouched and fast!
    }

    if (!serverReachable) return;

    // ── STEP 3: Pull ALL chapters for the full library (full snapshot) ────
    // This is the core of local-first: every chapter, page count, URL, and
    // fetch timestamp is stored in Isar so the app never needs the server
    // to know what chapters exist or to navigate reading history.
    await _syncAllChaptersForLibrary(serverUrl: serverUrl);

    // ── STEP 4: Pull reading history chapters (isRead=true) ──────────────
    await _syncHistoryChapters(serverUrl: serverUrl);

    // ── STEP 5: Pull recent update chapters (new fetched chapters) ────────
    await _syncRecentUpdateChapters(serverUrl: serverUrl);

    await IsarService.instance.setMeta('last_sync_unix', nowUnix.toString());
    try {
      await GraphQLClientService.instance.setGlobalMeta('lastSync_$_deviceId', nowUnix.toString());
    } catch (e) {
      await LoggerService.instance.logWarning('Failed to set global meta lastSync: $e', 'SyncEngine');
    }
  }

  // ── FULL CHAPTER SNAPSHOT FOR EVERY LIBRARY MANGA ──────────────────────
  // Fetches all chapters for every manga in the library and saves to Isar.
  // After this, chapters exist locally and are accessible without any server.
  Future<void> _syncAllChaptersForLibrary({required String serverUrl}) async {
    try {
      final library = await IsarService.instance.getLibraryManga();
      if (library.isEmpty) return;

      await LoggerService.instance.logInfo('Full chapter snapshot: syncing ${library.length} manga', 'SyncEngine');

      // Chunk fetch for concurrency
      for (var i = 0; i < library.length; i += 5) {
        final chunk = library.skip(i).take(5).toList();
        await Future.wait(chunk.map((manga) async {
          try {
            final data = await GraphQLClientService.instance.fetchMangaDetails(manga.serverId);
            if (data == null || !data.containsKey('manga')) return;

          final mangaData = data['manga'] as Map<String, dynamic>;

          // Update manga fields from detail response
          manga.description = mangaData['description'] as String? ?? manga.description;
          manga.status = mangaData['status'] as String? ?? manga.status;
          final rawMangaUrl = (mangaData['url'] ?? mangaData['realUrl']) as String?;
          if (rawMangaUrl != null && rawMangaUrl.isNotEmpty) {
            manga.url = rawMangaUrl;
          }
          final genresList = mangaData['genre'] as List<dynamic>?;
          if (genresList != null) {
            manga.genres = genresList.map((g) => g.toString()).toList();
          }
          manga.lastFetchedAt = DateTime.now().millisecondsSinceEpoch ~/ 1000;

          final chaptersData = mangaData['chapters'] as Map<String, dynamic>?;
          final chapterNodes = chaptersData?['nodes'] as List<dynamic>?;

          if (chapterNodes != null) {
            manga.chapterCount = chapterNodes.length;
            final chaptersToSave = <Chapter>[];

            for (final c in chapterNodes) {
              final chMap = c as Map<String, dynamic>;
              final chServerId = parseIntSafe(chMap['id']);

              var chapter = await IsarService.instance.getChapterByServerId(chServerId);
              chapter ??= Chapter()..serverId = chServerId;

              chapter.mangaId = manga.serverId;
              chapter.name = chMap['name'] as String? ?? 'Chapter ${chMap['chapterNumber'] ?? ""}';
              chapter.chapterNumber = parseDoubleSafe(chMap['chapterNumber']);
              chapter.pageCount = parseIntSafe(chMap['pageCount'], chapter.pageCount);

              // Monotonic read merge — read state can only go true, never false
              final serverIsRead = parseBoolSafe(chMap['isRead']);
              chapter.isRead = chapter.isRead || serverIsRead;

              // Monotonic lastPageRead merge — highest wins
              final serverLastPageRead = parseIntSafe(chMap['lastPageRead']);
              chapter.lastPageRead = chapter.lastPageRead > serverLastPageRead
                  ? chapter.lastPageRead
                  : serverLastPageRead;

              final serverLastReadAt = chMap['lastReadAt'] != null
                  ? int.tryParse(chMap['lastReadAt'].toString())
                  : null;
              if (serverLastReadAt != null && serverLastReadAt > (chapter.lastReadAt ?? 0)) {
                chapter.lastReadAt = serverLastReadAt;
              }

              final rawFetchedAt = chMap['fetchedAt'];
              if (rawFetchedAt != null) {
                chapter.fetchedAt = int.tryParse(rawFetchedAt.toString());
              }

              // Save remote chapter URLs for on-device QuickJS scraping
              if (chMap['url'] != null && (chMap['url'] as String).isNotEmpty) {
                chapter.url = chMap['url'] as String;
              }
              if (chMap['realUrl'] != null && (chMap['realUrl'] as String).isNotEmpty) {
                chapter.realUrl = chMap['realUrl'] as String;
              }

              // Denormalize manga info into the chapter for offline display
              chapter.mangaTitle = manga.title;
              chapter.mangaThumbnailUrl = manga.thumbnailUrl;

              chaptersToSave.add(chapter);
            }

            await IsarService.instance.saveChapters(chaptersToSave);
          }

          await IsarService.instance.saveManga(manga);
        } catch (e) {
          // Individual manga chapter sync failure is non-fatal — continue with others
          await LoggerService.instance.logWarning('Chapter snapshot failed for manga ${manga.serverId}: $e', 'SyncEngine');
        }
        }));
      }

      await LoggerService.instance.logInfo('Full chapter snapshot complete', 'SyncEngine');
    } catch (e, stack) {
      await LoggerService.instance.logError('Full chapter snapshot error: $e', exception: e, stackTrace: stack, category: 'SyncEngine');
    }
  }

  // ── HISTORY SYNC (isRead = true chapters) ────────────────────────────────
  Future<void> _syncHistoryChapters({required String serverUrl}) async {
    try {
      final historyData = await GraphQLClientService.instance.fetchHistoryChapters(0);
      if (historyData != null && historyData.containsKey('chapters')) {
        final chNodes = historyData['chapters']['nodes'] as List<dynamic>;
        final fetchedChapters = <Chapter>[];

        for (final c in chNodes) {
          final chMap = c as Map<String, dynamic>;
          final chServerId = parseIntSafe(chMap['id']);
          final mangaServerId = parseIntSafe(chMap['mangaId']);
          final serverIsRead = parseBoolSafe(chMap['isRead']);
          final serverLastPageRead = parseIntSafe(chMap['lastPageRead']);
          final serverLastReadAt = chMap['lastReadAt'] != null ? int.tryParse(chMap['lastReadAt'].toString()) : null;

          var chapter = await IsarService.instance.getChapterByServerId(chServerId);
          chapter ??= Chapter()..serverId = chServerId;

          chapter.mangaId = mangaServerId;
          chapter.name = chMap['name'] as String? ?? 'Chapter ${chMap['chapterNumber'] ?? ""}';
          chapter.chapterNumber = parseDoubleSafe(chMap['chapterNumber']);
          chapter.pageCount = parseIntSafe(chMap['pageCount'], chapter.pageCount);

          // Monotonic merge
          chapter.isRead = chapter.isRead || serverIsRead;
          chapter.lastPageRead = chapter.lastPageRead > serverLastPageRead ? chapter.lastPageRead : serverLastPageRead;
          if (serverLastReadAt != null && serverLastReadAt > (chapter.lastReadAt ?? 0)) {
            chapter.lastReadAt = serverLastReadAt;
          }

          // Populate denormalized manga info for offline History display
          if (chMap.containsKey('manga') && chMap['manga'] != null) {
            final mangaMap = chMap['manga'] as Map<String, dynamic>;
            chapter.mangaTitle = mangaMap['title'] as String? ?? chapter.mangaTitle;
            final mThumb = mangaMap['thumbnailUrl'] as String?;
            if (mThumb != null && mThumb.isNotEmpty) {
              chapter.mangaThumbnailUrl = mThumb.startsWith('http') ? mThumb : '$serverUrl$mThumb';
            }

            // Also upsert parent manga into Isar if not already there
            final mServerId = parseIntSafe(mangaMap['id'], mangaServerId);
            var parentManga = await IsarService.instance.getMangaByServerId(mServerId);
            parentManga ??= Manga()..serverId = mServerId;
            if (parentManga.title.isEmpty || parentManga.title == 'Untitled') {
              parentManga.title = mangaMap['title'] as String? ?? 'Manga';
            }
            final mThumbFull = mangaMap['thumbnailUrl'] as String?;
            if (mThumbFull != null && mThumbFull.isNotEmpty && parentManga.thumbnailUrl == null) {
              parentManga.thumbnailUrl = mThumbFull.startsWith('http') ? mThumbFull : '$serverUrl$mThumbFull';
            }
            await IsarService.instance.saveManga(parentManga);
          }

          fetchedChapters.add(chapter);
        }

        await IsarService.instance.saveChapters(fetchedChapters);
      }
    } catch (e) {
      await LoggerService.instance.logError('History sync error: $e', category: 'SyncEngine');
    }
  }

  // ── RECENT UPDATES SYNC (new chapters feed) ───────────────────────────────
  // Populates the Updates tab's offline cache by saving recent chapters with
  // their fetchedAt timestamp and denormalized manga metadata.
  Future<void> _syncRecentUpdateChapters({required String serverUrl}) async {
    try {
      final data = await GraphQLClientService.instance.fetchUpdatesChapters(first: 150);
      if (data == null || !data.containsKey('chapters')) return;

      final nodes = data['chapters']['nodes'] as List<dynamic>?;
      if (nodes == null) return;

      final chaptersToSave = <Chapter>[];

      for (final n in nodes) {
        final map = n as Map<String, dynamic>;
        final chServerId = parseIntSafe(map['id']);

        var chapter = await IsarService.instance.getChapterByServerId(chServerId);
        chapter ??= Chapter()..serverId = chServerId;

        chapter.mangaId = parseIntSafe(map['mangaId'], chapter.mangaId);
        chapter.name = map['name'] as String? ?? chapter.name;
        chapter.chapterNumber = parseDoubleSafe(map['chapterNumber'], chapter.chapterNumber);
        chapter.isRead = parseBoolSafe(map['isRead']) || chapter.isRead;
        chapter.lastPageRead = parseIntSafe(map['lastPageRead'], chapter.lastPageRead);
        chapter.isDownloadedOnServer = parseBoolSafe(map['isDownloaded']) || chapter.isDownloadedOnServer;

        final rawFetchedAt = map['fetchedAt'];
        if (rawFetchedAt != null) {
          final parsed = int.tryParse(rawFetchedAt.toString());
          if (parsed != null) chapter.fetchedAt = parsed;
        }

        // Denormalize manga metadata so Updates tab renders offline
        final mangaMap = map['manga'] as Map<String, dynamic>?;
        if (mangaMap != null) {
          chapter.mangaTitle = mangaMap['title'] as String? ?? chapter.mangaTitle;
          final rawThumb = mangaMap['thumbnailUrl'] as String?;
          if (rawThumb != null && rawThumb.isNotEmpty) {
            chapter.mangaThumbnailUrl = rawThumb.startsWith('http') ? rawThumb : '$serverUrl$rawThumb';
          }
        }

        chaptersToSave.add(chapter);
      }

      await IsarService.instance.saveChapters(chaptersToSave);
      await LoggerService.instance.logInfo('Cached ${chaptersToSave.length} recent update chapters to Isar', 'SyncEngine');
    } catch (e) {
      await LoggerService.instance.logError('Recent updates sync error: $e', category: 'SyncEngine');
    }
  }
}
