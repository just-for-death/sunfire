import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import '../db/isar_service.dart';
import '../db/models/chapter.dart';
import '../engine/quickjs_service.dart';
import '../logging/logger_service.dart';
import '../sync/graphql_client_service.dart';
import '../sync/sync_engine.dart';
import 'battery_state_service.dart';
import 'notification_service.dart';
import 'settings_service.dart';

class LibraryUpdateService extends ChangeNotifier {
  LibraryUpdateService._();
  static final LibraryUpdateService instance = LibraryUpdateService._();

  bool _isUpdating = false;
  double _progress = 0.0;
  String _statusMessage = '';
  int _lastFoundCount = 0;

  bool get isUpdating => _isUpdating;
  double get progress => _progress;
  String get statusMessage => _statusMessage;
  int get lastFoundCount => _lastFoundCount;

  /// Checks whether connection satisfies user's Wi-Fi / wired network constraint.
  Future<bool> _satisfiesNetworkConstraint() async {
    if (!SettingsService.instance.libraryUpdateOnlyOnWifi) {
      return true;
    }
    try {
      final results = await Connectivity().checkConnectivity();
      return results.contains(ConnectivityResult.wifi) ||
          results.contains(ConnectivityResult.ethernet) ||
          results.contains(ConnectivityResult.vpn);
    } catch (_) {
      return true;
    }
  }

  /// Charge-only gate for automated updates (`libraryUpdateOnlyCharging`).
  Future<bool> _satisfiesChargingConstraint() async {
    if (!SettingsService.instance.libraryUpdateOnlyCharging) return true;
    return BatteryStateService.instance.isCharging();
  }

  /// Unified library update: handles both live Suwayomi server jobs and local QuickJS scraping.
  /// Detects genuinely newly fetched chapters and triggers native notifications.
  Future<int> checkForNewChapters({
    bool isManual = false,
    bool triggerServer = true,
  }) async {
    if (_isUpdating) {
      debugPrint('[LibraryUpdateService] Update already in progress, skipping.');
      return 0;
    }
    _isUpdating = true;

    // Constraint enforcement for background or automated triggers.
    // The single-flight flag is already set, so any throw here MUST release it
    // or every later update is skipped until the app restarts.
    if (!isManual) {
      try {
        final freqHours = SettingsService.instance.libraryUpdateFrequencyHours;
        if (freqHours <= 0) {
          debugPrint('[LibraryUpdateService] Automated updates disabled in settings.');
          _isUpdating = false;
          return 0;
        }

        final lastTime = SettingsService.instance.lastLibraryUpdateTimestamp;
        final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        if (nowSec - lastTime < freqHours * 3600) {
          debugPrint('[LibraryUpdateService] Update frequency interval ($freqHours h) has not elapsed yet.');
          _isUpdating = false;
          return 0;
        }

        final satisfiesNetwork = await _satisfiesNetworkConstraint();
        if (!satisfiesNetwork) {
          debugPrint('[LibraryUpdateService] Skipping update: not connected to Wi-Fi / Ethernet.');
          _isUpdating = false;
          return 0;
        }

        final satisfiesCharging = await _satisfiesChargingConstraint();
        if (!satisfiesCharging) {
          debugPrint('[LibraryUpdateService] Skipping update: charge-only mode and device is not charging.');
          _isUpdating = false;
          return 0;
        }
      } catch (_) {
        _isUpdating = false;
        rethrow;
      }
    }

    _progress = 0.05;
    _statusMessage = 'Taking library snapshot...';
    _lastFoundCount = 0;
    notifyListeners();

    try {
      await LoggerService.instance.logInfo(
        'Starting library update (isManual: $isManual, triggerServer: $triggerServer)...',
        'LibraryUpdateService',
      );

      // ── STEP 1: Snapshot existing chapters to compute exact delta ────────
      final beforeChapters = await IsarService.instance.getAllChapters();
      final Set<String> knownKeys = <String>{};
      for (final ch in beforeChapters) {
        if (ch.serverId > 0) {
          knownKeys.add('srv_${ch.serverId}');
        }
        if (ch.url.isNotEmpty) {
          knownKeys.add('url_${ch.url}');
        }
        if (ch.mangaId > 0 && ch.chapterNumber > 0) {
          knownKeys.add('mid_${ch.mangaId}_num_${ch.chapterNumber}');
        }
      }

      // ── STEP 2: Update Server or Local Extensions ─────────────────────────
      final libraryMangas = await IsarService.instance.getLibraryManga();
      if (libraryMangas.isEmpty) {
        debugPrint('[LibraryUpdateService] Library is empty, nothing to update.');
        return 0;
      }

      final serverAvailable = GraphQLClientService.instance.isConfigured &&
          await GraphQLClientService.instance.checkServerReachable();

      if (serverAvailable && triggerServer) {
        _statusMessage = 'Triggering server library update...';
        _progress = 0.15;
        notifyListeners();

        await GraphQLClientService.instance.triggerServerLibraryUpdate();

        // Poll libraryUpdateStatus until server jobs finish (configurable timeout)
        final maxPolls = (SettingsService.instance.serverUpdatePollTimeoutSeconds / 1.5).ceil().clamp(5, 120);
        for (int i = 0; i < maxPolls; i++) {
          await Future.delayed(const Duration(milliseconds: 1500));
          final status = await GraphQLClientService.instance.fetchServerUpdateStatus();
          final jobsInfo = (status?['libraryUpdateStatus'] as Map<String, dynamic>?)?['jobsInfo'] as Map<String, dynamic>?;

          int extractCount(dynamic jobObj) {
            if (jobObj is int) return jobObj;
            if (jobObj is num) return jobObj.toInt();
            if (jobObj is Map) {
              final mangas = jobObj['mangas'];
              if (mangas is Map) {
                final nodes = mangas['nodes'];
                if (nodes is List) return nodes.length;
              }
              if (jobObj['nodes'] is List) return (jobObj['nodes'] as List).length;
            }
            if (jobObj is List) return jobObj.length;
            return 0;
          }

          final isRunning = jobsInfo?['isRunning'] == true;
          final totalJobs = extractCount(jobsInfo?['totalJobs']);
          final finishedJobs = extractCount(jobsInfo?['finishedJobs']);
          final activeJobs = isRunning ? (totalJobs - finishedJobs).clamp(0, totalJobs) : 0;

          _progress = 0.15 + (i / 30.0) * 0.45;
          _statusMessage = activeJobs > 0
              ? 'Server updating ($activeJobs job${activeJobs == 1 ? '' : 's'} in progress)...'
              : 'Server finished update jobs...';
          notifyListeners();

          if (activeJobs == 0) break;
        }

        _statusMessage = 'Syncing chapters from server...';
        _progress = 0.65;
        notifyListeners();

        // Pull updated chapters and manga down to Isar
        await SyncEngine.instance.triggerSync();
      }

      // Standalone or local mode, plus any local/migrated manga even when server is active
      final libraryManga = await IsarService.instance.getLibraryManga();
      final localManga = libraryManga.where((m) =>
          !GraphQLClientService.instance.isConfigured ||
          m.sourceName.startsWith('local_js_') ||
          m.serverId <= 0 ||
          QuickJsService.instance.hasExtension(m.sourceName)
      ).toList();
      final int totalManga = localManga.length;

      if (totalManga > 0) {
        final existingChaptersByManga = await IsarService.instance.getChaptersForMangas(
          localManga.map((m) => m.serverId != 0 ? m.serverId : m.id).toList(),
        );

        for (int i = 0; i < totalManga; i++) {
          final manga = localManga[i];
          _progress = 0.10 + ((i + 1) / (totalManga > 0 ? totalManga : 1)) * 0.65;
          _statusMessage = 'Updating ${manga.title} (${i + 1}/$totalManga)...';
          notifyListeners();

          if (manga.sourceName.isEmpty) continue;

          try {
            final targetUrl = manga.url.isNotEmpty ? manga.url : manga.title;
            final detail = await QuickJsService.instance.fetchMangaDetailsLocal(
              manga.sourceName,
              targetUrl,
            );

            if (detail.containsKey('chapters')) {
              final rawChapters = detail['chapters'] as List<dynamic>?;
              if (rawChapters != null && rawChapters.isNotEmpty) {
                final mId = manga.serverId != 0 ? manga.serverId : manga.id;
                final existing = existingChaptersByManga[mId] ?? const <Chapter>[];
                final existingUrls = existing.map((c) => c.url).toSet();
                final existingServerIds = existing.map((c) => c.serverId).toSet();
                final newChaptersToSave = <Chapter>[];

                for (int cIdx = 0; cIdx < rawChapters.length; cIdx++) {
                  final chMap = rawChapters[cIdx] as Map<String, dynamic>;
                  final chUrl = (chMap['url'] ?? chMap['link'] ?? '').toString();
                  if (chUrl.isNotEmpty && !existingUrls.contains(chUrl)) {
                    // Synthetic ids must be NEGATIVE: positive ids share the
                    // unique serverId index with real Suwayomi chapters and can
                    // overwrite/alias them (and get progress pushed to the wrong
                    // server chapter via the serverId > 0 sync guard).
                    int chServerId = -(mId.abs() * 100000 + cIdx + 1);
                    while (existingServerIds.contains(chServerId)) {
                      chServerId++;
                    }
                    existingServerIds.add(chServerId);
                    final ch = Chapter()
                      ..serverId = chServerId
                      ..mangaId = mId
                      ..name = chMap['name']?.toString() ?? 'Chapter ${cIdx + 1}'
                      ..chapterNumber = (chMap['chapterNumber'] as num?)?.toDouble() ?? (cIdx + 1).toDouble()
                      ..url = chUrl
                      ..realUrl = chUrl
                      ..mangaTitle = manga.title
                      ..mangaThumbnailUrl = manga.thumbnailUrl
                      ..fetchedAt = DateTime.now().millisecondsSinceEpoch ~/ 1000
                      ..isRead = false
                      ..lastPageRead = 0;
                    newChaptersToSave.add(ch);
                  }
                }

                if (newChaptersToSave.isNotEmpty) {
                  await IsarService.instance.saveChapters(newChaptersToSave);
                  final freshManga = manga.serverId != 0
                      ? (await IsarService.instance.getMangaByServerId(manga.serverId) ?? manga)
                      : (await IsarService.instance.getManga(manga.id) ?? manga);
                  freshManga.unreadCount = (freshManga.unreadCount ?? 0) + newChaptersToSave.length;
                  await IsarService.instance.saveManga(freshManga);
                }
              }
            }
          } catch (e) {
            debugPrint('[LibraryUpdateService] Local scrape error for ${manga.title}: $e');
          }
        }
      }

      // ── STEP 3: Identify Newly Added Chapters (Diff against snapshot) ──────
      _statusMessage = 'Detecting newly added chapters...';
      _progress = 0.85;
      notifyListeners();

      final afterChapters = await IsarService.instance.getAllChapters();
      final libraryMangaList = await IsarService.instance.getLibraryManga();
      final Map<int, String> mangaTitleMap = {
        for (final m in libraryMangaList)
          (m.serverId > 0 ? m.serverId : m.id): m.title,
      };
      final Set<int> libraryMangaIds = {
        for (final m in libraryMangaList) ...[
          if (m.serverId > 0) m.serverId,
          m.id,
        ],
      };

      final List<Chapter> newChapters = [];
      for (final ch in afterChapters) {
        // Only consider unread chapters belonging to manga currently in library
        if (ch.isRead) continue;
        if (ch.mangaId > 0 && !libraryMangaIds.contains(ch.mangaId)) continue;

        bool isKnown = false;
        if (ch.serverId > 0 && knownKeys.contains('srv_${ch.serverId}')) {
          isKnown = true;
        } else if (ch.url.isNotEmpty && knownKeys.contains('url_${ch.url}')) {
          isKnown = true;
        } else if (ch.mangaId > 0 && ch.chapterNumber > 0 && knownKeys.contains('mid_${ch.mangaId}_num_${ch.chapterNumber}')) {
          isKnown = true;
        }

        if (!isKnown) {
          if ((ch.mangaTitle.isEmpty) && mangaTitleMap.containsKey(ch.mangaId)) {
            ch.mangaTitle = mangaTitleMap[ch.mangaId]!;
          }
          newChapters.add(ch);
        }
      }

      _lastFoundCount = newChapters.length;
      await LoggerService.instance.logInfo(
        'Library update finished. Detected $_lastFoundCount newly discovered chapters.',
        'LibraryUpdateService',
      );

      // ── STEP 4: Trigger OS Notifications ─────────────────────────────────
      if (newChapters.isNotEmpty && SettingsService.instance.newChapterNotificationsEnabled) {
        await NotificationService.instance.showNewChaptersNotification(newChapters);
      }

      // Update timestamp
      SettingsService.instance.lastLibraryUpdateTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      _progress = 1.0;
      _statusMessage = _lastFoundCount > 0
          ? 'Found $_lastFoundCount new chapters!'
          : 'Library is up to date';
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 600));
      return _lastFoundCount;
    } catch (e, st) {
      await LoggerService.instance.logError(
        'LibraryUpdateService failed: $e',
        exception: e,
        stackTrace: st,
        category: 'LibraryUpdateService',
      );
      _statusMessage = 'Update failed: $e';
      return 0;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }
}
