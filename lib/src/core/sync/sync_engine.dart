import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, visibleForTesting;
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import '../services/wakelock_coordinator.dart';
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

  /// Reset failed/abandoned sync records back to pending so a manual retry can
  /// flush them again (Advanced Settings → "Retry failed sync").
  Future<int> retryFailedSyncRecords() async {
    final records = await IsarService.instance.getFailedSyncRecords();
    if (records.isEmpty) return 0;
    for (final record in records) {
      record.retryCount = 0;
      record.state = SyncRecordState.pending;
      await IsarService.instance.saveSyncRecord(record);
    }
    await LoggerService.instance.logInfo(
      'Reset ${records.length} failed/abandoned sync record(s) to pending for retry',
      'SyncEngine',
    );
    // Kick an immediate flush so the retry is not only queued for the next cycle.
    unawaited(triggerSync());
    return records.length;
  }

  /// Bypass wipe-guard and apply server library removals (Settings → Advanced).
  Future<void> forceReconcileWithServer() async {
    if (_isSyncing) return;
    if (!GraphQLClientService.instance.isConfigured) return;
    _isSyncing = true;
    try {
      final online = await GraphQLClientService.instance.checkServerReachable(force: true);
      if (!online) return;
      await _flushPendingMutations();
      await _syncCategories();
      await _syncSourcesAndReplicate();
      await _performFullSync(forceLibraryRemovals: true);
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> triggerSync() async {
    if (_isSyncing) return;
    if (!GraphQLClientService.instance.isConfigured) {
      return;
    }

    _isSyncing = true;
    try {
      final isServerOnline = await GraphQLClientService.instance.checkServerReachable();
      if (!isServerOnline) {
        // Server is offline — silently keep local authoritative state without firing network queries
        return;
      }
      try {
        if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
          await WakelockCoordinator.instance.acquire('sync');
        }
      } catch (_) {}
      await LoggerService.instance.logInfo('Starting sync cycle with server...', 'SyncEngine');
      await _flushPendingMutations();
      await _pullServerState();
      await LoggerService.instance.logInfo('Sync cycle completed successfully', 'SyncEngine');
    } catch (e, stack) {
      await LoggerService.instance.logError('Sync cycle error: $e', exception: e, stackTrace: stack, category: 'SyncEngine');
    } finally {
      try {
        if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
          await WakelockCoordinator.instance.release('sync');
        }
      } catch (_) {}
      _isSyncing = false;
    }
  }

  Future<void> syncChapterProgress(
    int chapterServerId, {
    required bool isRead,
    required int lastPageRead,
  }) async {
    if (chapterServerId <= 0) return;

    if (GraphQLClientService.instance.isConfigured) {
      final isOnline = await GraphQLClientService.instance.checkServerReachable();
      if (isOnline) {
        try {
          final res = await GraphQLClientService.instance.updateChapterReadStatus(
            chapterServerId,
            isRead,
            lastPageRead,
          );
          if (res != null) return;
        } catch (e) {
          await LoggerService.instance.logWarning('Direct chapter read status sync failed ($chapterServerId): $e, queuing for replay', 'SyncEngine');
        }
      }
    }

    // Queue offline SyncRecord for replay when online
    final record = SyncRecord()
      ..recordId = const Uuid().v4()
      ..entityType = SyncEntityType.chapter
      ..entityId = chapterServerId.toString()
      ..action = SyncAction.update
      ..payloadJson = jsonEncode({
        'chapterId': chapterServerId,
        'isRead': isRead,
        'lastPageRead': lastPageRead,
      })
      ..timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000
      ..deviceId = _deviceId ?? 'default_device'
      ..state = SyncRecordState.pending;
    await IsarService.instance.saveSyncRecord(record);
  }

  Future<void> syncChapterBookmark(int chapterServerId, bool isBookmarked) async {
    if (chapterServerId <= 0) return;

    if (GraphQLClientService.instance.isConfigured) {
      final isOnline = await GraphQLClientService.instance.checkServerReachable();
      if (isOnline) {
        try {
          final res = await GraphQLClientService.instance.updateChapterBookmark(chapterServerId, isBookmarked);
          if (res != null) return;
        } catch (e) {
          await LoggerService.instance.logWarning('Direct bookmark sync failed ($chapterServerId): $e, queuing for replay', 'SyncEngine');
        }
      }
    }

    final record = SyncRecord()
      ..recordId = const Uuid().v4()
      ..entityType = SyncEntityType.chapter
      ..entityId = chapterServerId.toString()
      ..action = SyncAction.update
      ..payloadJson = jsonEncode({
        'chapterId': chapterServerId,
        'isBookmarked': isBookmarked,
      })
      ..timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000
      ..deviceId = _deviceId ?? 'default_device'
      ..state = SyncRecordState.pending;
    await IsarService.instance.saveSyncRecord(record);
  }

  Future<void> syncMangaLibraryState(int mangaServerId, bool inLibrary) async {
    if (mangaServerId <= 0) return;

    if (GraphQLClientService.instance.isConfigured) {
      final isOnline = await GraphQLClientService.instance.checkServerReachable();
      if (isOnline) {
        try {
          final res = await GraphQLClientService.instance.updateMangaLibraryState(mangaServerId, inLibrary);
          if (res != null) return;
        } catch (e) {
          await LoggerService.instance.logWarning('Direct manga library state sync failed ($mangaServerId): $e, queuing for replay', 'SyncEngine');
        }
      }
    }

    final record = SyncRecord()
      ..recordId = const Uuid().v4()
      ..entityType = SyncEntityType.manga
      ..entityId = mangaServerId.toString()
      ..action = inLibrary ? SyncAction.update : SyncAction.delete
      ..payloadJson = jsonEncode({
        'mangaId': mangaServerId,
        'inLibrary': inLibrary,
      })
      ..timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000
      ..deviceId = _deviceId ?? 'default_device'
      ..state = SyncRecordState.pending;
    await IsarService.instance.saveSyncRecord(record);
  }

  Future<void> syncCategoryCreate({required String name, required int localServerId, int order = 0}) async {
    if (name.trim().isEmpty) return;

    if (GraphQLClientService.instance.isConfigured) {
      final isOnline = await GraphQLClientService.instance.checkServerReachable();
      if (isOnline) {
        try {
          final res = await GraphQLClientService.instance.createCategory(name);
          final created = res?['createCategory']?['category'];
          if (created is Map) {
            final remoteId = parseIntSafe(created['id']);
            if (remoteId > 0 && remoteId != localServerId) {
              final cats = await IsarService.instance.getCategories();
              final match = cats.where((c) => c.serverId == localServerId).toList();
              if (match.isNotEmpty) {
                final cat = match.first;
                await IsarService.instance.deleteCategory(localServerId);
                cat.serverId = remoteId;
                cat.name = created['name']?.toString() ?? name;
                cat.order = parseIntSafe(created['order'], order);
                await IsarService.instance.saveCategory(cat);
              }
            }
            return;
          }
        } catch (e) {
          await LoggerService.instance.logWarning('Direct category create failed ($name): $e, queuing', 'SyncEngine');
        }
      }
    }

    final record = SyncRecord()
      ..recordId = const Uuid().v4()
      ..entityType = SyncEntityType.category
      ..entityId = localServerId.toString()
      ..action = SyncAction.create
      ..payloadJson = jsonEncode({
        'op': 'create',
        'name': name,
        'localServerId': localServerId,
        'order': order,
      })
      ..timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000
      ..deviceId = _deviceId ?? 'default_device'
      ..state = SyncRecordState.pending;
    await IsarService.instance.saveSyncRecord(record);
  }

  Future<void> syncCategoryDelete(int categoryServerId) async {
    if (categoryServerId <= 0) return;

    if (GraphQLClientService.instance.isConfigured) {
      final isOnline = await GraphQLClientService.instance.checkServerReachable();
      if (isOnline) {
        try {
          final res = await GraphQLClientService.instance.deleteCategory(categoryServerId);
          if (res != null) return;
        } catch (e) {
          await LoggerService.instance.logWarning('Direct category delete failed ($categoryServerId): $e, queuing', 'SyncEngine');
        }
      }
    }

    final record = SyncRecord()
      ..recordId = const Uuid().v4()
      ..entityType = SyncEntityType.category
      ..entityId = categoryServerId.toString()
      ..action = SyncAction.delete
      ..payloadJson = jsonEncode({
        'op': 'delete',
        'categoryId': categoryServerId,
      })
      ..timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000
      ..deviceId = _deviceId ?? 'default_device'
      ..state = SyncRecordState.pending;
    await IsarService.instance.saveSyncRecord(record);
  }

  Future<void> syncMangaCategories(int mangaServerId, List<int> categoryIds) async {
    if (mangaServerId <= 0) return;

    if (GraphQLClientService.instance.isConfigured) {
      final isOnline = await GraphQLClientService.instance.checkServerReachable();
      if (isOnline) {
        try {
          final res = await GraphQLClientService.instance.setMangaCategories(mangaServerId, categoryIds);
          if (res != null) return;
        } catch (e) {
          await LoggerService.instance.logWarning('Direct manga categories sync failed ($mangaServerId): $e, queuing', 'SyncEngine');
        }
      }
    }

    final record = SyncRecord()
      ..recordId = const Uuid().v4()
      ..entityType = SyncEntityType.category
      ..entityId = 'manga_$mangaServerId'
      ..action = SyncAction.update
      ..payloadJson = jsonEncode({
        'op': 'assign',
        'mangaId': mangaServerId,
        'categoryIds': categoryIds,
      })
      ..timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000
      ..deviceId = _deviceId ?? 'default_device'
      ..state = SyncRecordState.pending;
    await IsarService.instance.saveSyncRecord(record);
  }

  Future<void> syncCategoryRename(int categoryServerId, String newName) async {
    if (categoryServerId < 0 || newName.trim().isEmpty) return;
    final trimmed = newName.trim();

    if (GraphQLClientService.instance.isConfigured) {
      final isOnline = await GraphQLClientService.instance.checkServerReachable();
      if (isOnline) {
        try {
          final res = await GraphQLClientService.instance.updateCategoryName(categoryServerId, trimmed);
          if (res != null) return;
        } catch (e) {
          await LoggerService.instance.logWarning('Direct category rename failed ($categoryServerId): $e, queuing', 'SyncEngine');
        }
      }
    }

    final record = SyncRecord()
      ..recordId = const Uuid().v4()
      ..entityType = SyncEntityType.category
      ..entityId = categoryServerId.toString()
      ..action = SyncAction.update
      ..payloadJson = jsonEncode({
        'op': 'rename',
        'categoryId': categoryServerId,
        'name': trimmed,
      })
      ..timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000
      ..deviceId = _deviceId ?? 'default_device'
      ..state = SyncRecordState.pending;
    await IsarService.instance.saveSyncRecord(record);
  }

  /// Queue tracker progress for all bound trackers of [mangaServerId].
  /// Online: fetch track records and push immediately. Offline: queue a
  /// manga-level progress record replayed on the next flush.
  Future<void> syncMangaTrackerProgress(int mangaServerId, double chapterNumber) async {
    if (mangaServerId <= 0 || chapterNumber < 0) return;

    if (GraphQLClientService.instance.isConfigured) {
      final isOnline = await GraphQLClientService.instance.checkServerReachable();
      if (isOnline) {
        try {
          final pushed = await _pushTrackerProgressForManga(mangaServerId);
          if (pushed) return;
        } catch (e) {
          await LoggerService.instance.logWarning(
            'Direct tracker progress sync failed ($mangaServerId): $e, queuing',
            'SyncEngine',
          );
        }
      }
    }

    final record = SyncRecord()
      ..recordId = const Uuid().v4()
      ..entityType = SyncEntityType.tracker
      ..entityId = 'manga_$mangaServerId'
      ..action = SyncAction.update
      ..payloadJson = jsonEncode({
        'op': 'mangaProgress',
        'mangaId': mangaServerId,
        'chapterNumber': chapterNumber,
      })
      ..timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000
      ..deviceId = _deviceId ?? 'default_device'
      ..state = SyncRecordState.pending;
    await IsarService.instance.saveSyncRecord(record);
  }

  /// Pushes MAL/AniList progress via `trackProgress(mangaId)` after chapter
  /// read has been applied on the server. Does not send trackerId.
  Future<bool> _pushTrackerProgressForManga(int mangaServerId) async {
    final data = await GraphQLClientService.instance.fetchTrackRecords(mangaServerId);
    final nodes = data?['trackRecords']?['nodes'];
    if (nodes is! List || nodes.isEmpty) return true; // nothing bound — treat as success
    final res = await GraphQLClientService.instance.trackProgress(mangaServerId);
    return res != null;
  }

  /// Rewrites pending offline 'assign' records that still reference the local
  /// temporary category id so they replay against the real server id once the
  /// category-create mutation has been flushed. Returns only the records whose
  /// payload actually changed (callers persist those).
  ///
  /// Pure so tests can verify the remap without a live queue or DB.
  @visibleForTesting
  static List<SyncRecord> remapOfflineAssignRecords({
    required List<SyncRecord> records,
    required int localServerId,
    required int remoteId,
  }) {
    final changed = <SyncRecord>[];
    for (final rec in records) {
      if (rec.entityType != SyncEntityType.category) continue;
      try {
        final payload = jsonDecode(rec.payloadJson) as Map<String, dynamic>;
        if (payload['op'] != 'assign' || payload['categoryIds'] is! List) continue;
        final ids = (payload['categoryIds'] as List).map((e) => parseIntSafe(e)).toList();
        final replaced = ids.map((id) => id == localServerId ? remoteId : id).toList();
        if (ids.join(',') != replaced.join(',')) {
          payload['categoryIds'] = replaced;
          rec.payloadJson = jsonEncode(payload);
          changed.add(rec);
        }
      } catch (_) {}
    }
    return changed;
  }

  Future<void> _flushPendingMutations() async {
    final pendingRecords = await IsarService.instance.getPendingSyncRecords();
    if (pendingRecords.isEmpty) return;

    // Replay mutations strictly in chronological order. Records created within
    // the same second (common in bursts) replay in insertion order via the
    // auto-increment id — Dart/Isar sorts aren't stable, so a bare timestamp
    // comparison alone would be nondeterministic.
    final executionList = List<SyncRecord>.from(pendingRecords)
      ..sort((a, b) {
        final byTs = a.timestamp.compareTo(b.timestamp);
        return byTs != 0 ? byTs : a.id.compareTo(b.id);
      });

    for (final record in executionList) {
      try {
        final payload = jsonDecode(record.payloadJson) as Map<String, dynamic>;
        bool success = false;

        switch (record.entityType) {
          case SyncEntityType.chapter:
            if (record.action == SyncAction.update) {
              final chapterId = parseIntSafe(payload['chapterId']);
              if (chapterId > 0) {
                var allOk = true;
                var attempted = false;
                if (chapterMutationNeedsBookmark(payload)) {
                  attempted = true;
                  final isBookmarked = parseBoolSafe(payload['isBookmarked']);
                  final res = await GraphQLClientService.instance.updateChapterBookmark(chapterId, isBookmarked);
                  allOk = allOk && res != null;
                }
                if (chapterMutationNeedsReadProgress(payload)) {
                  attempted = true;
                  final isRead = parseBoolSafe(payload['isRead']);
                  final lastPageRead = parseIntSafe(payload['lastPageRead']);
                  final res = await GraphQLClientService.instance.updateChapterReadStatus(chapterId, isRead, lastPageRead);
                  allOk = allOk && res != null;
                }
                success = attempted && allOk;
              } else {
                success = true;
              }
            }
            break;
          case SyncEntityType.tracker:
            if (record.action == SyncAction.update) {
              final op = payload['op']?.toString() ?? '';
              if (op == 'mangaProgress') {
                final mangaId = parseIntSafe(payload['mangaId']);
                success = await _pushTrackerProgressForManga(mangaId);
              } else {
                final mangaId = parseIntSafe(payload['mangaId']);
                final res = await GraphQLClientService.instance.trackProgress(mangaId);
                success = res != null;
              }
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
            final op = payload['op']?.toString() ?? '';
            if (op == 'create' || record.action == SyncAction.create) {
              final name = payload['name']?.toString() ?? '';
              final localServerId = parseIntSafe(payload['localServerId']);
              final res = await GraphQLClientService.instance.createCategory(name);
              final created = res?['createCategory']?['category'];
              if (created is Map) {
                final remoteId = parseIntSafe(created['id']);
                if (remoteId > 0 && localServerId > 0 && remoteId != localServerId) {
                  final cats = await IsarService.instance.getCategories();
                  final match = cats.where((c) => c.serverId == localServerId).toList();
                  if (match.isNotEmpty) {
                    final cat = match.first;
                    await IsarService.instance.deleteCategory(localServerId);
                    cat.serverId = remoteId;
                    cat.name = created['name']?.toString() ?? name;
                    await IsarService.instance.saveCategory(cat);
                    // Mangas assigned to the temporary id while offline were
                    // queued with the temp id baked into their 'assign'
                    // payload. Rewrite them to the real server id, or the
                    // assign replay would send an unknown category and the
                    // server would silently drop the assignment.
                    final pendingAssigns = await IsarService.instance.getPendingSyncRecords();
                    final remapped = remapOfflineAssignRecords(
                      records: pendingAssigns,
                      localServerId: localServerId,
                      remoteId: remoteId,
                    );
                    for (final rec in remapped) {
                      await IsarService.instance.saveSyncRecord(rec);
                    }
                  }
                }
                success = true;
              }
            } else if (op == 'delete' || record.action == SyncAction.delete) {
              final categoryId = parseIntSafe(payload['categoryId'] ?? record.entityId);
              final res = await GraphQLClientService.instance.deleteCategory(categoryId);
              success = res != null;
            } else if (op == 'assign') {
              final mangaId = parseIntSafe(payload['mangaId']);
              final ids = (payload['categoryIds'] as List?)?.map((e) => parseIntSafe(e)).toList() ?? <int>[];
              final res = await GraphQLClientService.instance.setMangaCategories(mangaId, ids);
              success = res != null;
            } else if (op == 'rename') {
              final categoryId = parseIntSafe(payload['categoryId'] ?? record.entityId);
              final name = payload['name']?.toString() ?? '';
              final res = await GraphQLClientService.instance.updateCategoryName(categoryId, name);
              success = res != null;
            }
            break;
          case SyncEntityType.source:
            break;
        }

        if (success) {
          await IsarService.instance.deleteSyncRecord(record.id);
        } else {
          record.retryCount += 1;
          record.state = record.retryCount >= 5 ? SyncRecordState.abandoned : SyncRecordState.failed;
          await IsarService.instance.saveSyncRecord(record);
        }
      } catch (e, stack) {
        record.retryCount += 1;
        record.state = record.retryCount >= 5 ? SyncRecordState.abandoned : SyncRecordState.failed;
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

          final report = await SourceMigrationService.instance.syncAndReplicateServerSources(
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

  Future<void> _performFullSync({bool forceLibraryRemovals = false}) async {
    final nowUnix = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final serverUrl = GraphQLClientService.instance.baseUrl ?? '';

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
          // Only overwrite author/description from server if user has NOT locked metadata via Metron enrichment
          if (!manga.isMetadataLocked) {
            manga.author = nodeMap['author'] as String?;
            manga.description = nodeMap['description'] as String?;
          }
          manga.inLibrary = true;
          manga.inLibraryAt = nodeMap['inLibraryAt'] != null ? int.tryParse(nodeMap['inLibraryAt'].toString()) : null;
          manga.unreadCount = parseIntSafe(nodeMap['unreadCount']);
          manga.lastFetchedAt = nowUnix;

          if (nodeMap.containsKey('categories') && nodeMap['categories'] != null) {
            final catNodes = nodeMap['categories']['nodes'] as List<dynamic>?;
            if (catNodes != null) {
              manga.categoryIds = catNodes.map((c) => parseIntSafe((c as Map<String, dynamic>)['id'])).toList();
            }
          }

          final sourceMap = nodeMap['source'] as Map<String, dynamic>?;
          manga.sourceName = sourceMap?['name'] as String? ?? sourceMap?['displayName'] as String? ?? nodeMap['sourceId']?.toString() ?? 'Unknown Source';
          final sourceLang = sourceMap?['lang']?.toString();
          if (sourceLang != null && sourceLang.trim().isNotEmpty) {
            manga.lang = sourceLang.trim();
          } else if (manga.lang.isEmpty) {
            manga.lang = 'en';
          }

          // Save the manga's URL on the source website — used by local QuickJS extensions
          // to scrape chapters directly when the server is offline.
          if (nodeMap['url'] != null && (nodeMap['url'] as String).isNotEmpty) {
            manga.url = nodeMap['url'] as String;
          }

          final rawThumb = nodeMap['thumbnailUrl'] as String?;
          final isServerProxy = rawThumb == null || rawThumb.isEmpty || rawThumb.contains('/api/v1/manga/');
          final currentThumb = manga.thumbnailUrl;
          final hasDirectThumb = currentThumb != null &&
              currentThumb.isNotEmpty &&
              !currentThumb.contains('/api/v1/manga/') &&
              currentThumb.startsWith('http');

          if (!hasDirectThumb) {
            // Check if local extension can resolve direct CDN cover URL (zero network, instantaneous)
            String? extCover;
            if (manga.sourceName.isNotEmpty && manga.url.isNotEmpty) {
              extCover = QuickJsService.instance.getExtensionCoverUrl(manga.sourceName, manga.url);
            }
            if (extCover != null && extCover.isNotEmpty) {
              manga.thumbnailUrl = extCover;
            } else if (!isServerProxy) {
              manga.thumbnailUrl = rawThumb.startsWith('http') ? rawThumb : '$serverUrl$rawThumb';
            } else if (serverUrl.isNotEmpty && serverId > 0 && (manga.thumbnailUrl == null || manga.thumbnailUrl!.isEmpty)) {
              manga.thumbnailUrl = '$serverUrl/api/v1/manga/$serverId/thumbnail';
            }
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
        final removalSafe = forceLibraryRemovals ||
            localCountBefore == 0 ||
            (serverCount > 0 && serverCount >= localCountBefore * 0.3); // server has at least 30% of what we had

        if (removalSafe && serverCount > 0) {
          // Only soft-delete local entries that the server genuinely removed
          final serverIds = serverMangas.map((m) => m.serverId).toSet();
          final localLib = await IsarService.instance.getLibraryManga();
          final toRemove = <Manga>[];
          for (final local in localLib) {
            // Only soft-delete server-linked manga that the server genuinely removed.
            // Local standalone/extension manga (serverId <= 0) must never be removed by server sync.
            if (local.serverId > 0 && !serverIds.contains(local.serverId)) {
              local.inLibrary = false;
              toRemove.add(local);
            }
          }
          if (toRemove.isNotEmpty) {
            await IsarService.instance.saveMangas(toRemove);
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
      final allLibrary = await IsarService.instance.getLibraryManga();
      final library = allLibrary.where((m) => m.serverId > 0).toList();
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

          // Update manga fields from detail response (respect metadata lock from Metron)
          if (!manga.isMetadataLocked) {
            manga.description = mangaData['description'] as String? ?? manga.description;
            manga.status = mangaData['status'] as String? ?? manga.status;
            final genresList = mangaData['genre'] as List<dynamic>?;
            if (genresList != null) {
              manga.genres = genresList.map((g) => g.toString()).toList();
            }
          } else {
            // Still update status from server even when locked — status is operational data, not editorial
            manga.status = mangaData['status'] as String? ?? manga.status;
          }
          final rawMangaUrl = (mangaData['url'] ?? mangaData['realUrl']) as String?;
          if (rawMangaUrl != null && rawMangaUrl.isNotEmpty) {
            manga.url = rawMangaUrl;
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

              final rawServerLastReadAt = chMap['lastReadAt'] != null
                  ? int.tryParse(chMap['lastReadAt'].toString())
                  : null;
              if (rawServerLastReadAt != null) {
                final serverLastReadAt = rawServerLastReadAt > 100000000000 ? rawServerLastReadAt ~/ 1000 : rawServerLastReadAt;
                if (serverLastReadAt > (chapter.lastReadAt ?? 0)) {
                  chapter.lastReadAt = serverLastReadAt;
                }
              }

              final rawUpload = chMap['uploadDate'] ?? chMap['dateUpload'];
              if (rawUpload != null) {
                final rawStr = rawUpload.toString().trim();
                if (rawStr.isNotEmpty && rawStr != '0' && rawStr != 'null') {
                  chapter.dateUpload = rawStr;
                }
                final upVal = int.tryParse(rawStr);
                if (upVal != null && upVal > 0) {
                  chapter.uploadDate = upVal > 1000000000000 ? upVal ~/ 1000 : upVal;
                }
              }

              // Do not stamp full historical chapter backlog as updates during snapshot
              if (chapter.id == Isar.autoIncrement) {
                chapter.fetchedAt = 0;
              }

              final rawScanlator = chMap['scanlator'] as String?;
              if (rawScanlator != null && rawScanlator.isNotEmpty) {
                chapter.scanlator = rawScanlator;
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
        final parentMangasToSave = <int, Manga>{};

        for (final c in chNodes) {
          final chMap = c as Map<String, dynamic>;
          final chServerId = parseIntSafe(chMap['id']);
          final mangaServerId = parseIntSafe(chMap['mangaId']);
          final serverIsRead = parseBoolSafe(chMap['isRead']);
          final serverLastPageRead = parseIntSafe(chMap['lastPageRead']);
          final rawServerLastReadAt = chMap['lastReadAt'] != null ? int.tryParse(chMap['lastReadAt'].toString()) : null;
          final serverLastReadAt = rawServerLastReadAt != null
              ? (rawServerLastReadAt > 100000000000 ? rawServerLastReadAt ~/ 1000 : rawServerLastReadAt)
              : null;

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
            var parentManga = parentMangasToSave[mServerId] ?? await IsarService.instance.getMangaByServerId(mServerId);
            parentManga ??= Manga()..serverId = mServerId;
            if (parentManga.title.isEmpty || parentManga.title == 'Untitled') {
              parentManga.title = mangaMap['title'] as String? ?? 'Manga';
            }
            final mThumbFull = mangaMap['thumbnailUrl'] as String?;
            final isProxy = mThumbFull == null || mThumbFull.isEmpty || mThumbFull.contains('/api/v1/manga/');
            final hasDirect = parentManga.thumbnailUrl != null &&
                parentManga.thumbnailUrl!.isNotEmpty &&
                !parentManga.thumbnailUrl!.contains('/api/v1/manga/') &&
                parentManga.thumbnailUrl!.startsWith('http');
            if (!hasDirect) {
              String? extCover;
              if (parentManga.sourceName.isNotEmpty && parentManga.url.isNotEmpty) {
                extCover = QuickJsService.instance.getExtensionCoverUrl(parentManga.sourceName, parentManga.url);
              }
              if (extCover != null && extCover.isNotEmpty) {
                parentManga.thumbnailUrl = extCover;
              } else if (mThumbFull != null && mThumbFull.isNotEmpty && !isProxy) {
                parentManga.thumbnailUrl = mThumbFull.startsWith('http') ? mThumbFull : '$serverUrl$mThumbFull';
              }
            }
            parentMangasToSave[mServerId] = parentManga;
          }

          fetchedChapters.add(chapter);
        }

        if (parentMangasToSave.isNotEmpty) {
          await IsarService.instance.saveMangas(parentMangasToSave.values.toList());
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

        final rawUpload = map['uploadDate'] ?? map['dateUpload'];
        if (rawUpload != null) {
          final rawStr = rawUpload.toString().trim();
          if (rawStr.isNotEmpty && rawStr != '0' && rawStr != 'null') {
            chapter.dateUpload = rawStr;
          }
          final upVal = int.tryParse(rawStr);
          if (upVal != null && upVal > 0) {
            chapter.uploadDate = upVal > 1000000000000 ? upVal ~/ 1000 : upVal;
          }
        }

        final rawFetchedAt = map['fetchedAt'];
        if (rawFetchedAt != null) {
          final ftVal = int.tryParse(rawFetchedAt.toString());
          if (ftVal != null && ftVal > 0) {
            chapter.fetchedAt = ftVal > 1000000000000 ? ftVal ~/ 1000 : ftVal;
          }
        }

        final rawScanlator = map['scanlator'] as String?;
        if (rawScanlator != null && rawScanlator.isNotEmpty) {
          chapter.scanlator = rawScanlator;
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
