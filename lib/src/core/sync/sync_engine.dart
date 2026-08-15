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

    // 1. Pull full library manga from Suwayomi server
    try {
      final libData = await GraphQLClientService.instance.fetchLibrary();
      if (libData != null && libData.containsKey('mangas')) {
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
          manga.sourceName = sourceMap?['name'] as String? ?? sourceMap?['displayName'] as String? ?? nodeMap['sourceId']?.toString() ?? 'Read Comics Online';
          manga.lang = 'en';
          manga.url = '';

          serverMangas.add(manga);
        }
        await IsarService.instance.saveMangas(serverMangas);

        final serverIds = serverMangas.map((m) => m.serverId).toSet();
        final localLib = await IsarService.instance.getLibraryManga();
        for (final local in localLib) {
          if (!serverIds.contains(local.serverId)) {
            local.inLibrary = false;
            await IsarService.instance.saveManga(local);
          }
        }
      }
    } catch (e) {
      await LoggerService.instance.logError('Library sync error: $e', category: 'SyncEngine');
    }

    // 2. Pull ALL reading history chapters (past, present, future) from Suwayomi server
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
          chapter.name = chMap['name'] ?? 'Chapter ${chMap['chapterNumber']}';
          chapter.chapterNumber = (chMap['chapterNumber'] as num? ?? 0).toDouble();
          chapter.pageCount = chMap['pageCount'] as int? ?? 0;

          chapter.isRead = chapter.isRead || serverIsRead;
          chapter.lastPageRead = chapter.lastPageRead > serverLastPageRead ? chapter.lastPageRead : serverLastPageRead;
          if (serverLastReadAt != null) {
            chapter.lastReadAt = serverLastReadAt;
          }

          fetchedChapters.add(chapter);

          // If manga info is included, populate parent manga in Isar DB
          if (chMap.containsKey('manga') && chMap['manga'] != null) {
            final mangaMap = chMap['manga'] as Map<String, dynamic>;
            final mServerId = mangaMap['id'] as int;
            var parentManga = await IsarService.instance.getMangaByServerId(mServerId);
            parentManga ??= Manga()..serverId = mServerId;
            parentManga.title = mangaMap['title'] as String? ?? 'Manga';
            final mThumb = mangaMap['thumbnailUrl'] as String?;
            if (mThumb != null && mThumb.isNotEmpty) {
              parentManga.thumbnailUrl = mThumb.startsWith('http') ? mThumb : '$serverUrl$mThumb';
            }
            await IsarService.instance.saveManga(parentManga);
          }
        }

        await IsarService.instance.saveChapters(fetchedChapters);
      }
    } catch (e) {
      await LoggerService.instance.logError('History sync error: $e', category: 'SyncEngine');
    }

    await IsarService.instance.setMeta('last_sync_unix', nowUnix.toString());
    try {
      await GraphQLClientService.instance.setGlobalMeta('lastSync_$_deviceId', nowUnix.toString());
    } catch (_) {}
  }
}
