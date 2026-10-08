import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import '../db/isar_service.dart';
import '../db/models/chapter.dart';
import '../engine/quickjs_service.dart';
import '../logging/logger_service.dart';
import '../sync/download_status_merge.dart';
import '../sync/graphql_client_service.dart';
import '../sync/offline_monitor.dart';
import '../sync/sync_engine.dart';
import '../sync/websocket_service.dart';
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
  int _skippedCategoriesCount = 0;
  int _skippedMangasCount = 0;

  bool get isUpdating => _isUpdating;
  double get progress => _progress;
  String get statusMessage => _statusMessage;
  int get lastFoundCount => _lastFoundCount;

  /// Categories skipped by the server updater (includeInUpdate=EXCLUDE / empty).
  int get skippedCategoriesCount => _skippedCategoriesCount;

  /// Manga skipped by the server updater (per-category / strategy filters).
  int get skippedMangasCount => _skippedMangasCount;

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
  /// Library update task. Its log lines share one correlation id (UIX-18).
  Future<int> checkForNewChapters({
    bool isManual = false,
    bool triggerServer = true,
  }) =>
      LoggerService.withCorrelationAsync(
        () => _checkForNewChaptersImpl(isManual: isManual, triggerServer: triggerServer),
      );

  Future<int> _checkForNewChaptersImpl({
    required bool isManual,
    required bool triggerServer,
  }) async {
    if (_isUpdating) {
      debugPrint('[LibraryUpdateService] Update already in progress, skipping.');
      return 0;
    }
    _isUpdating = true;

    // NOTE: every early return below relies on the `finally` at the bottom of
    // the try to release the single-flight flag. The constraint gates used to
    // sit *outside* the try and reset `_isUpdating` by hand at five separate
    // sites — any future early return added there would wedge the service
    // forever ("Update already in progress"), and the outer catch could
    // rethrow with the flag still set. They are inside the try now, so the
    // flag has exactly one release path.
    try {
      // Constraint enforcement for background or automated triggers.
      if (!isManual) {
        final freqHours = SettingsService.instance.libraryUpdateFrequencyHours;
        if (freqHours <= 0) {
          debugPrint('[LibraryUpdateService] Automated updates disabled in settings.');
          return 0;
        }

        final lastTime = SettingsService.instance.lastLibraryUpdateTimestamp;
        final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        if (nowSec - lastTime < freqHours * 3600) {
          debugPrint('[LibraryUpdateService] Update frequency interval ($freqHours h) has not elapsed yet.');
          return 0;
        }

        final satisfiesNetwork = await _satisfiesNetworkConstraint();
        if (!satisfiesNetwork) {
          debugPrint('[LibraryUpdateService] Skipping update: not connected to Wi-Fi / Ethernet.');
          return 0;
        }

        final satisfiesCharging = await _satisfiesChargingConstraint();
        if (!satisfiesCharging) {
          debugPrint('[LibraryUpdateService] Skipping update: charge-only mode and device is not charging.');
          return 0;
        }
      }

      _progress = 0.05;
      _statusMessage = 'Taking library snapshot...';
      _lastFoundCount = 0;
      _skippedCategoriesCount = 0;
      _skippedMangasCount = 0;
      notifyListeners();

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

      // Offline-aware availability: a known-dead connection skips the live
      // probe entirely (no doomed 3s timeouts per cycle) and drops straight
      // to the local-scrape path below with an honest status line.
      final offlineKnown = OfflineMonitor.instance.isOffline;
      final serverAvailable = GraphQLClientService.instance.isConfigured &&
          !offlineKnown &&
          await GraphQLClientService.instance.checkServerReachable();
      if (offlineKnown) {
        _statusMessage = 'Offline — checking local sources only...';
        notifyListeners();
      }

      // Avoid stacking updateLibrary on top of an in-flight SyncEngine cycle
      // (resume used to fire both and amplify the sync storm — ISS-058).
      final syncBusy = SyncEngine.instance.isSyncing;
      if (serverAvailable && triggerServer && syncBusy) {
        await LoggerService.instance.logInfo(
          'Skipping server updateLibrary — SyncEngine cycle already running',
          'LibraryUpdateService',
        );
      } else if (serverAvailable && triggerServer) {
        _statusMessage = 'Triggering server library update...';
        _progress = 0.15;
        notifyListeners();

        await GraphQLClientService.instance.triggerServerLibraryUpdate();

        // ISS-068: prefer libraryUpdateStatusChanged WS progress; poll as fallback.
        final timeoutSec = SettingsService.instance.serverUpdatePollTimeoutSeconds;
        final deadline = DateTime.now().add(Duration(seconds: timeoutSec));
        final completedMangaIds = <int>{};
        var sawWsEvent = false;
        var lastIsRunning = true;

        void applyJobs({
          required bool isRunning,
          required int finishedJobs,
          required int totalJobs,
          int skippedCategoriesCount = 0,
          int skippedMangasCount = 0,
        }) {
          lastIsRunning = isRunning;
          _skippedCategoriesCount = skippedCategoriesCount;
          _skippedMangasCount = skippedMangasCount;
          final activeJobs =
              isRunning ? (totalJobs - finishedJobs).clamp(0, totalJobs > 0 ? totalJobs : 0) : 0;
          final ratio = totalJobs > 0 ? (finishedJobs / totalJobs).clamp(0.0, 1.0) : 0.0;
          _progress = 0.15 + ratio * 0.45;
          _statusMessage = activeJobs > 0
              ? 'Server updating ($finishedJobs/$totalJobs)...'
              : 'Server finished update jobs...';
          notifyListeners();
        }

        final wsSub = WebSocketService.instance.onUpdateStatus.listen((event) {
          sawWsEvent = true;
          final parsed = parseLibraryUpdateEvent(event);
          completedMangaIds.addAll(parsed.completedMangaIds);
          applyJobs(
            isRunning: parsed.isRunning,
            finishedJobs: parsed.finishedJobs,
            totalJobs: parsed.totalJobs,
            skippedCategoriesCount: parsed.skippedCategoriesCount,
            skippedMangasCount: parsed.skippedMangasCount,
          );
        });

        try {
          while (DateTime.now().isBefore(deadline)) {
            if (sawWsEvent && !lastIsRunning) break;

            // Fallback / supplement: poll every 1.5s when WS is quiet.
            await Future<void>.delayed(const Duration(milliseconds: 1500));
            if (sawWsEvent && !lastIsRunning) break;

            final status = await GraphQLClientService.instance.fetchServerUpdateStatus();
            final jobsInfo = (status?['libraryUpdateStatus'] as Map<String, dynamic>?)?['jobsInfo']
                as Map<String, dynamic>?;
            int extractCount(dynamic jobObj) {
              if (jobObj is int) return jobObj;
              if (jobObj is num) return jobObj.toInt();
              return 0;
            }
            final isRunning = jobsInfo?['isRunning'] == true;
            final totalJobs = extractCount(jobsInfo?['totalJobs']);
            final finishedJobs = extractCount(jobsInfo?['finishedJobs']);
            final skippedCategories = extractCount(jobsInfo?['skippedCategoriesCount']);
            final skippedMangas = extractCount(jobsInfo?['skippedMangasCount']);
            if (!sawWsEvent) {
              applyJobs(
                isRunning: isRunning,
                finishedJobs: finishedJobs,
                totalJobs: totalJobs,
                skippedCategoriesCount: skippedCategories,
                skippedMangasCount: skippedMangas,
              );
            }
            if (!isRunning && finishedJobs >= totalJobs) break;
          }
        } finally {
          await wsSub.cancel();
        }

        _statusMessage = 'Syncing chapters from server...';
        _progress = 0.65;
        notifyListeners();

        // Targeted refresh for manga that completed on the server (ISS-068),
        // then a normal sync to pull results into Isar.
        for (final mangaId in completedMangaIds) {
          try {
            await GraphQLClientService.instance.fetchMangaAndChapters(mangaId);
          } catch (_) {}
        }
        await SyncEngine.instance.triggerSync();
      }

      // Standalone/local titles only when a server is configured. Scraping
      // server-linked manga locally (just because a JS ext exists) caused
      // Cloudflare 403 storms and phantom chapters (ISS-058).
      final libraryManga = await IsarService.instance.getLibraryManga();
      final localManga = libraryManga.where((m) {
        if (!GraphQLClientService.instance.isConfigured) return true;
        return m.sourceName.startsWith('local_js_') || m.serverId <= 0;
      }).toList();
      final int totalManga = localManga.length;

      if (totalManga > 0) {
        final existingChaptersByManga = await IsarService.instance.getChaptersForMangas(
          localManga.map((m) => m.canonicalKey).toList(),
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
                final mId = manga.canonicalKey;
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
                    // server chapter via the serverId > 0 sync guard). The base
                    // is index-derived, so it also needs the collision probe —
                    // see mintLocalChapterServerId.
                    final chServerId = mintLocalChapterServerId(
                      mangaId: mId,
                      index: cIdx,
                      takenServerIds: existingServerIds,
                    );
                    final ch = Chapter()
                      ..serverId = chServerId
                      ..mangaId = mId
                      ..name = chMap['name']?.toString() ?? 'Chapter ${cIdx + 1}'
                      ..chapterNumber = (chMap['chapterNumber'] as num?)?.toDouble() ?? (cIdx + 1).toDouble()
                      ..url = chUrl
                      ..realUrl = chUrl
                      ..mangaTitle = manga.title
                      ..mangaThumbnailUrl = manga.thumbnailUrl
                      ..isRead = false
                      ..lastPageRead = 0;
                    newChaptersToSave.add(ch);
                  }
                }

                if (newChaptersToSave.isNotEmpty) {
                  // Shared flood gate, identical to the library-screen path.
                  // This used to stamp fetchedAt unconditionally, so a bulk
                  // first import of a long series flooded the Updates feed
                  // while the display-layer cap showed only 3 — and the
                  // Library unread tile plus the notification then contradicted
                  // the feed about the same batch. See
                  // applyFloodCapToNewChapters.
                  applyFloodCapToNewChapters(
                    newChaptersToSave,
                    isFirstImport: existing.isEmpty,
                  );
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
          m.canonicalKey: m.title,
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

      await Future<void>.delayed(const Duration(milliseconds: 600));
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