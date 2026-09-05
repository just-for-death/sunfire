import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import '../db/isar_service.dart';
import '../db/models/chapter.dart';
import '../engine/quickjs_service.dart';
import '../logging/logger_service.dart';
import '../sync/graphql_client_service.dart';
import '../sync/sync_engine.dart';
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

    // Constraint enforcement for background or automated triggers
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
    }

    _isUpdating = true;
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
      final isConfigured = GraphQLClientService.instance.isConfigured;
      bool serverAvailable = false;
      if (isConfigured) {
        serverAvailable = await GraphQLClientService.instance.checkServerReachable();
      }

      if (serverAvailable && triggerServer) {
        _statusMessage = 'Triggering server library update...';
        _progress = 0.15;
        notifyListeners();

        await GraphQLClientService.instance.triggerServerLibraryUpdate();

        // Poll updateStatus until server jobs finish (max 45 seconds)
        for (int i = 0; i < 30; i++) {
          await Future.delayed(const Duration(milliseconds: 1500));
          final status = await GraphQLClientService.instance.fetchServerUpdateStatus();
          final running = status?['runningJobs'] as int? ?? 0;
          final pending = status?['pendingJobs'] as int? ?? 0;

          _progress = 0.15 + (i / 30.0) * 0.45;
          _statusMessage = running > 0 || pending > 0
              ? 'Server updating ($running running, $pending pending)...'
              : 'Server finished update jobs...';
          notifyListeners();

          if (running == 0 && pending == 0) break;
        }

        _statusMessage = 'Syncing chapters from server...';
        _progress = 0.65;
        notifyListeners();

        // Pull updated chapters and manga down to Isar
        await SyncEngine.instance.triggerSync();
      } else {
        // Standalone or local mode: scrape library manga via QuickJS
        final libraryManga = await IsarService.instance.getLibraryManga();
        final int totalManga = libraryManga.length;

        for (int i = 0; i < totalManga; i++) {
          final manga = libraryManga[i];
          _progress = 0.10 + ((i + 1) / (totalManga > 0 ? totalManga : 1)) * 0.65;
          _statusMessage = 'Updating ${manga.title} (${i + 1}/$totalManga)...';
          notifyListeners();

          if (manga.sourceName.isEmpty || manga.url.isEmpty) continue;

          try {
            final detail = await QuickJsService.instance.fetchMangaDetailsLocal(
              manga.sourceName,
              manga.url,
            );

            if (detail.containsKey('chapters')) {
              final rawChapters = detail['chapters'] as List<dynamic>?;
              if (rawChapters != null && rawChapters.isNotEmpty) {
                final mId = manga.serverId > 0 ? manga.serverId : manga.id;
                final existing = await IsarService.instance.getChaptersForManga(mId);
                final existingUrls = existing.map((c) => c.url).toSet();
                final newChaptersToSave = <Chapter>[];

                for (int cIdx = 0; cIdx < rawChapters.length; cIdx++) {
                  final chMap = rawChapters[cIdx] as Map<String, dynamic>;
                  final chUrl = chMap['url']?.toString() ?? '';
                  if (chUrl.isNotEmpty && !existingUrls.contains(chUrl)) {
                    final ch = Chapter()
                      ..serverId = manga.serverId > 0 ? (manga.serverId * 10000 + cIdx + 1) : 0
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
                  manga.unreadCount = (manga.unreadCount ?? 0) + newChaptersToSave.length;
                  await IsarService.instance.saveManga(manga);
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
