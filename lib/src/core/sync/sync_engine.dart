import 'dart:convert';
import '../db/isar_service.dart';
import '../db/models/category.dart';
import '../db/models/chapter.dart';
import '../db/models/manga.dart';
import '../db/models/sync_record.dart';
import '../logging/logger_service.dart';
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
      await LoggerService.instance.logInfo('SyncEngine: server not configured, skipping sync — local data is authoritative', 'SyncEngine');
      return;
    }
    _isSyncing = true;
    try {
      await LoggerService.instance.logInfo('Starting sync cycle...', 'SyncEngine');
      await _flushPendingMutations();
      await _pullServerState();
      await LoggerService.instance.logInfo('Sync cycle completed successfully', 'SyncEngine');
    } catch (e, stack) {
      await LoggerService.instance.logError('Sync cycle error: $e', exception: e, stackTrace: stack, category: 'SyncEngine');
    } finally {
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
              final chapterId = payload['chapterId'] as int;
              final isRead = payload['isRead'] as bool;
              final lastPageRead = payload['lastPageRead'] as int;
              final res = await GraphQLClientService.instance.updateChapterReadStatus(chapterId, isRead, lastPageRead);
              success = res != null;
            }
            break;
          case SyncEntityType.tracker:
            if (record.action == SyncAction.update) {
              final trackerId = payload['trackerId'] as int;
              final mangaId = payload['mangaId'] as int;
              final chapterNumber = (payload['chapterNumber'] as num).toDouble();
              final res = await GraphQLClientService.instance.trackProgress(mangaId, trackerId, chapterNumber);
              success = res != null;
            }
            break;
          case SyncEntityType.manga:
            if (record.action == SyncAction.update || record.action == SyncAction.delete) {
              final mangaId = payload['mangaId'] as int;
              final inLibrary = payload['inLibrary'] as bool;
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
    await _performFullSync();
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
            ..serverId = map['id'] as int
            ..name = map['name'] as String? ?? 'Default'
            ..order = map['order'] as int? ?? 0
            ..isDefault = map['default'] as bool? ?? false;
          categories.add(cat);
        }
        await IsarService.instance.saveCategories(categories);
      }
    } catch (_) {}
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
          .timeout(const Duration(seconds: 4));
      if (libData != null && libData.containsKey('mangas')) {
        serverReachable = true;
        final nodes = libData['mangas']['nodes'] as List<dynamic>;
        final serverMangas = <Manga>[];

        for (final n in nodes) {
          final nodeMap = n as Map<String, dynamic>;
          final serverId = nodeMap['id'] as int;
          var manga = await IsarService.instance.getMangaByServerId(serverId);
          manga ??= Manga()..serverId = serverId;

          manga.title = nodeMap['title'] as String? ?? 'Untitled';
          manga.author = nodeMap['author'] as String?;
          manga.description = nodeMap['description'] as String?;
          manga.inLibrary = true;
          manga.inLibraryAt = nodeMap['inLibraryAt'] != null ? int.tryParse(nodeMap['inLibraryAt'].toString()) : null;
          manga.unreadCount = nodeMap['unreadCount'] as int?;
          manga.lastFetchedAt = nowUnix;

          final rawThumb = nodeMap['thumbnailUrl'] as String?;
          if (rawThumb != null && rawThumb.isNotEmpty) {
            manga.thumbnailUrl = rawThumb.startsWith('http') ? rawThumb : '$serverUrl$rawThumb';
          }

          if (nodeMap.containsKey('categories') && nodeMap['categories'] != null) {
            final catNodes = nodeMap['categories']['nodes'] as List<dynamic>?;
            if (catNodes != null) {
              manga.categoryIds = catNodes.map((c) => (c as Map<String, dynamic>)['id'] as int).toList();
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

        // ── WIPE GUARD: Never cascade a server wipe to local Isar ─────────
        // If server returned far fewer manga than Isar has, something is wrong
        // (server was wiped/reset). Skip marking local entries as removed.
        final serverCount = serverMangas.length;
        final removalSafe = localCountBefore == 0 ||
            serverCount == 0 ||
            (serverCount >= localCountBefore * 0.3); // server has at least 30% of what we had

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
    } catch (_) {}
  }

  // ── FULL CHAPTER SNAPSHOT FOR EVERY LIBRARY MANGA ──────────────────────
  // Fetches all chapters for every manga in the library and saves to Isar.
  // After this, chapters exist locally and are accessible without any server.
  Future<void> _syncAllChaptersForLibrary({required String serverUrl}) async {
    try {
      final library = await IsarService.instance.getLibraryManga();
      if (library.isEmpty) return;

      await LoggerService.instance.logInfo('Full chapter snapshot: syncing ${library.length} manga', 'SyncEngine');

      for (final manga in library) {
        try {
          final data = await GraphQLClientService.instance.fetchMangaDetails(manga.serverId);
          if (data == null || !data.containsKey('manga')) continue;

          final mangaData = data['manga'] as Map<String, dynamic>;

          // Update manga fields from detail response
          manga.description = mangaData['description'] as String? ?? manga.description;
          manga.status = mangaData['status'] as String? ?? manga.status;
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
              final chServerId = chMap['id'] as int;

              var chapter = await IsarService.instance.getChapterByServerId(chServerId);
              chapter ??= Chapter()..serverId = chServerId;

              chapter.mangaId = manga.serverId;
              chapter.name = chMap['name'] as String? ?? 'Chapter ${chMap['chapterNumber']}';
              chapter.chapterNumber = (chMap['chapterNumber'] as num? ?? 0).toDouble();
              chapter.pageCount = chMap['pageCount'] as int? ?? chapter.pageCount;

              // Monotonic read merge — read state can only go true, never false
              final serverIsRead = chMap['isRead'] as bool? ?? false;
              chapter.isRead = chapter.isRead || serverIsRead;

              // Monotonic lastPageRead merge — highest wins
              final serverLastPageRead = chMap['lastPageRead'] as int? ?? 0;
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
          final chServerId = chMap['id'] as int;
          final mangaServerId = chMap['mangaId'] as int;
          final serverIsRead = chMap['isRead'] as bool? ?? false;
          final serverLastPageRead = chMap['lastPageRead'] as int? ?? 0;
          final serverLastReadAt = chMap['lastReadAt'] != null ? int.tryParse(chMap['lastReadAt'].toString()) : null;

          var chapter = await IsarService.instance.getChapterByServerId(chServerId);
          chapter ??= Chapter()..serverId = chServerId;

          chapter.mangaId = mangaServerId;
          chapter.name = chMap['name'] as String? ?? 'Chapter ${chMap['chapterNumber']}';
          chapter.chapterNumber = (chMap['chapterNumber'] as num? ?? 0).toDouble();
          chapter.pageCount = chMap['pageCount'] as int? ?? chapter.pageCount;

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
            final mServerId = mangaMap['id'] as int? ?? mangaServerId;
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
        final chServerId = map['id'] as int;

        var chapter = await IsarService.instance.getChapterByServerId(chServerId);
        chapter ??= Chapter()..serverId = chServerId;

        chapter.mangaId = map['mangaId'] as int? ?? chapter.mangaId;
        chapter.name = map['name'] as String? ?? chapter.name;
        chapter.chapterNumber = (map['chapterNumber'] as num? ?? chapter.chapterNumber).toDouble();
        chapter.isRead = (map['isRead'] as bool? ?? false) || chapter.isRead;
        chapter.lastPageRead = map['lastPageRead'] as int? ?? chapter.lastPageRead;
        chapter.isDownloadedOnServer = map['isDownloaded'] as bool? ?? chapter.isDownloadedOnServer;

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
