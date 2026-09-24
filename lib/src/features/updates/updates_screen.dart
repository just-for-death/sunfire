import 'dart:async';

import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/db/isar_service.dart';
import '../../core/db/models/chapter.dart';
import '../../core/services/download_manager_service.dart';
import '../../core/services/image_cache_helper.dart';
import '../../core/services/library_update_service.dart';
import '../../core/services/settings_service.dart';
import '../../core/sync/graphql_client_service.dart';
import '../../core/sync/sync_engine.dart';
import '../../core/sync/websocket_service.dart';
import '../../main_shell.dart';

class UpdatesScreen extends StatefulWidget {
  const UpdatesScreen({super.key});

  @override
  State<UpdatesScreen> createState() => _UpdatesScreenState();
}

class _UpdatesScreenState extends State<UpdatesScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<Map<String, dynamic>> _updatesList = [];
  final Map<int, String> _langByMangaId = {};
  bool _isLoading = true;
  bool _isCheckingServer = false;
  bool _isOffline = false;
  String? _lastUpdateText;
  bool _unreadOnly = false;
  String _searchQuery = '';
  bool _isSearching = false;
  String? _liveUpdateStatus;
  StreamSubscription? _wsUpdateSub;
  StreamSubscription? _wsDownloadSub;

  @override
  void initState() {
    super.initState();
    _loadUpdates();
    MainShell.selectedTabNotifier.addListener(_onTabChanged);
    _wsUpdateSub = WebSocketService.instance.onUpdateStatus.listen((event) {
      if (!mounted) return;
      final status = event['status']?.toString() ?? event.toString();
      setState(() => _liveUpdateStatus = status);
      _loadUpdatesFromIsarCache();
    });
    _wsDownloadSub = WebSocketService.instance.onDownloadStatus.listen((event) {
      if (!mounted) return;
      setState(() {});
    });
  }

  void _onTabChanged() {
    if (MainShell.selectedTabNotifier.value == 1 && mounted) {
      _loadUpdatesFromIsarCache();
    }
  }

  List<Map<String, dynamic>> get _filteredUpdates {
    var list = List<Map<String, dynamic>>.from(_updatesList);
    if (_unreadOnly) {
      list = list.where((it) => !(it['chapter'] as Chapter).isRead).toList();
    }
    // Honor the reader's selected languages (Mihon parity): 'all' shows everything.
    final selectedLangs = SettingsService.instance.selectedLanguages;
    if (selectedLangs.isNotEmpty && !selectedLangs.contains('all')) {
      list = list.where((it) {
        final lang = (it['lang'] as String? ?? '').trim().toLowerCase();
        return SettingsService.languageMatchesFilter(lang, selectedLangs);
      }).toList();
    }
    final q = _searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((it) {
        final ch = it['chapter'] as Chapter;
        final title = (it['mangaTitle'] ?? ch.mangaTitle).toString().toLowerCase();
        return title.contains(q) || ch.name.toLowerCase().contains(q);
      }).toList();
    }
    return list;
  }

  @override
  void dispose() {
    MainShell.selectedTabNotifier.removeListener(_onTabChanged);
    _wsUpdateSub?.cancel();
    _wsDownloadSub?.cancel();
    super.dispose();
  }

  String _formatDateHeader(int? fetchedAt) {
    if (fetchedAt == null || fetchedAt <= 0) return 'Recent';
    final int millis = fetchedAt > 100000000000 ? fetchedAt : fetchedAt * 1000;
    final date = DateTime.fromMillisecondsSinceEpoch(millis);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final itemDate = DateTime(date.year, date.month, date.day);

    final diffDays = today.difference(itemDate).inDays;
    if (diffDays <= 0) {
      return 'Today';
    } else if (diffDays == 1) {
      return 'Yesterday';
    } else if (diffDays < 7) {
      return DateFormat('EEEE').format(date); // e.g. "Wednesday"
    } else {
      return DateFormat('MMMM d, yyyy').format(date);
    }
  }

  Future<void> _loadUpdates() async {
    // 1. Show local cache immediately (0ms instant render)
    await _loadUpdatesFromIsarCache();

    // 2. Background server fetch (only if configured, never blocks initial render)
    if (GraphQLClientService.instance.isConfigured) {
      _fetchServerUpdatesInBackground();
    }
  }

  /// Builds mangaId → language cache from the local library so update feed items
  /// can be language-badged and filtered (`showLanguageBadges` / `selectedLanguages`).
  Future<void> _loadLangMap() async {
    try {
      if (_langByMangaId.isNotEmpty) return;
      final mangas = await IsarService.instance.getLibraryManga();
      for (final m in mangas) {
        if (m.serverId > 0) _langByMangaId[m.serverId] = m.lang;
        if (m.id > 0) _langByMangaId[m.id] = m.lang;
      }
    } catch (ignoredError) { if (kDebugMode) debugPrint('[updates_screen] ignored error: $ignoredError'); }
  }

  /// Short uppercase language code for badges, or null when the entry is
  /// default English / universal and doesn't warrant a badge.
  String? _languageBadgeLabel(String lang) {
    if (!SettingsService.instance.showLanguageBadges) return null;
    return SettingsService.languageBadgeLabel(lang);
  }

  Future<void> _fetchServerUpdatesInBackground() async {
    try {
      final serverUrl = GraphQLClientService.instance.baseUrl ?? '';
      final items = <Map<String, dynamic>>[];
      final chaptersToSave = <Chapter>[];

      // Fetch last update timestamp
      final tsStr = await GraphQLClientService.instance
          .fetchLastUpdateTimestamp()
          .timeout(const Duration(seconds: 4), onTimeout: () => null);
      if (!mounted) return;
      if (tsStr != null) {
        final ts = int.tryParse(tsStr);
        if (ts != null) {
          final dt = DateTime.fromMillisecondsSinceEpoch(ts > 100000000000 ? ts : ts * 1000);
          setState(() {
            _lastUpdateText = 'Last update: ${DateFormat('MM/dd/yyyy, hh:mm a').format(dt)}';
          });
        }
      }

      if (!mounted) return;
      final data = await GraphQLClientService.instance
          .fetchUpdatesChapters(first: 100)
          .timeout(const Duration(seconds: 8), onTimeout: () => null);

      if (!mounted) return;
      if (data != null && data.containsKey('chapters')) {
        final nodes = data['chapters']['nodes'] as List<dynamic>?;
        if (nodes != null) {
          // Count chapters per manga in this incoming batch to detect bulk imports/refreshes
          final mangaCounts = <int, int>{};
          for (final n in nodes) {
            final map = n as Map<String, dynamic>;
            final mId = parseIntSafe(map['mangaId']);
            mangaCounts[mId] = (mangaCounts[mId] ?? 0) + 1;
          }

          final mangaAddedCount = <int, int>{};
          for (final n in nodes) {
            final map = n as Map<String, dynamic>;
            final mangaMap = map['manga'] as Map<String, dynamic>?;
            final chServerId = parseIntSafe(map['id']);
            final mId = parseIntSafe(map['mangaId']);

            // If a manga was bulk imported or bulk refreshed on server (> 4 chapters in this batch),
            // show at most the 3 latest chapters in the updates feed to prevent flooding
            final totalForManga = mangaCounts[mId] ?? 0;
            final isFlooded = totalForManga > 4;
            final added = mangaAddedCount[mId] ?? 0;
            final shouldAddToFeed = !isFlooded || (added < 3);
            if (shouldAddToFeed) {
              mangaAddedCount[mId] = added + 1;
            }

            final isDownloaded = parseBoolSafe(map['isDownloaded']);
            final rawFetchedAt = map['fetchedAt'] != null ? int.tryParse(map['fetchedAt'].toString()) : null;
            final fetchedAt = rawFetchedAt != null && rawFetchedAt > 100000000000 ? (rawFetchedAt ~/ 1000) : rawFetchedAt;

            String title = 'Manga';
            String thumb = '';
            int resolvedMId = mId;
            String sourceName = '';

            if (mangaMap != null) {
              title = mangaMap['title'] as String? ?? 'Manga';
              resolvedMId = parseIntSafe(mangaMap['id'], resolvedMId);
              final rawThumb = mangaMap['thumbnailUrl'] as String?;
              if (rawThumb != null && rawThumb.isNotEmpty) {
                thumb = rawThumb.startsWith('http') ? rawThumb : '$serverUrl$rawThumb';
              }
              final srcMap = mangaMap['source'] as Map<String, dynamic>?;
              sourceName = srcMap?['displayName'] as String? ?? '';
            }

            final ch = Chapter()
              ..serverId = chServerId
              ..mangaId = resolvedMId
              ..name = map['name'] as String? ?? 'Chapter'
              ..chapterNumber = parseDoubleSafe(map['chapterNumber'])
              ..isRead = parseBoolSafe(map['isRead'])
              ..lastPageRead = parseIntSafe(map['lastPageRead'])
              ..mangaTitle = title
              ..mangaThumbnailUrl = thumb
              ..fetchedAt = fetchedAt
              ..isDownloadedOnServer = isDownloaded;

            chaptersToSave.add(ch);

            if (shouldAddToFeed) {
              items.add({
                'chapter': ch,
                'mangaId': resolvedMId,
                'title': title,
                'thumbnailUrl': thumb,
                'sourceName': sourceName,
                'lang': _langByMangaId[resolvedMId] ?? '',
                'isDownloaded': isDownloaded,
                'fetchedAt': fetchedAt,
                'dateHeader': _formatDateHeader(fetchedAt),
              });
            }
          }
        }
      }

      // Persist fetched chapters into Isar so cache stays synchronized with server
      if (chaptersToSave.isNotEmpty) {
        for (final ch in chaptersToSave) {
          final existing = await IsarService.instance.getChapterByServerId(ch.serverId);
          if (existing != null) {
            ch.id = existing.id;
            ch.isRead = ch.isRead || existing.isRead;
            ch.lastPageRead = ch.lastPageRead > existing.lastPageRead ? ch.lastPageRead : existing.lastPageRead;
            if (existing.url.isNotEmpty && ch.url.isEmpty) ch.url = existing.url;
            if (existing.isBookmarked) ch.isBookmarked = true;
            if (existing.isDownloaded) ch.isDownloaded = true;
          }
        }
        await IsarService.instance.saveChapters(chaptersToSave);
      }

      if (items.isNotEmpty && mounted) {
        items.sort((a, b) {
          final fa = a['fetchedAt'] as int? ?? 0;
          final fb = b['fetchedAt'] as int? ?? 0;
          return fb.compareTo(fa);
        });

        setState(() {
          _updatesList = items;
          _isLoading = false;
          _isOffline = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isOffline = true);
    }
  }

  Future<void> _loadUpdatesFromIsarCache() async {
    try {
      await _loadLangMap();
      final chapters = await IsarService.instance.getRecentChapters(limit: 100);
      if (chapters.isEmpty && _updatesList.isNotEmpty) {
        // Retain current in-memory feed if cache temporarily returns empty
        return;
      }

      // Count chapters per manga to detect bulk imports/refreshes (same logic as server feed)
      final mangaCounts = <int, int>{};
      for (final ch in chapters) {
        mangaCounts[ch.mangaId] = (mangaCounts[ch.mangaId] ?? 0) + 1;
      }

      final items = <Map<String, dynamic>>[];
      final mangaAddedCount = <int, int>{};

      for (final ch in chapters) {
        // If a manga was bulk imported or refreshed (> 4 chapters in feed),
        // show at most the 3 latest chapters to prevent flooding
        final totalForManga = mangaCounts[ch.mangaId] ?? 0;
        final isFlooded = totalForManga > 4;
        final added = mangaAddedCount[ch.mangaId] ?? 0;
        if (isFlooded && added >= 3) continue;
        mangaAddedCount[ch.mangaId] = added + 1;

        String title = ch.mangaTitle.isNotEmpty ? ch.mangaTitle : 'Manga #${ch.mangaId}';
        String thumb = ch.mangaThumbnailUrl ?? '';

        if (title == 'Manga #${ch.mangaId}' || thumb.isEmpty) {
          final manga = await IsarService.instance.getMangaByServerId(ch.mangaId);
          if (manga != null) {
            if (title == 'Manga #${ch.mangaId}') title = manga.title;
            if (thumb.isEmpty) thumb = manga.thumbnailUrl ?? '';
          }
        }

        items.add({
          'chapter': ch,
          'mangaId': ch.mangaId,
          'title': title,
          'thumbnailUrl': thumb,
          'sourceName': '',
          'lang': _langByMangaId[ch.mangaId] ?? '',
          'isDownloaded': ch.isDownloaded || ch.isDownloadedOnServer,
          'fetchedAt': ch.fetchedAt,
          'dateHeader': _formatDateHeader(ch.fetchedAt),
        });
      }

      items.sort((a, b) {
        final fa = a['fetchedAt'] as int? ?? 0;
        final fb = b['fetchedAt'] as int? ?? 0;
        return fb.compareTo(fa);
      });

      if (mounted) {
        setState(() {
          _updatesList = items;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _checkServerForUpdates() async {
    setState(() => _isCheckingServer = true);
    final primaryColor = Theme.of(context).colorScheme.primary;

    try {
      final newFound = await LibraryUpdateService.instance.checkForNewChapters(isManual: true);
      // Reload directly from cache — the sync above already wrote to Isar.
      // Do NOT call _loadUpdates() here; that would re-trigger server fetch and old cleanup.
      await _loadUpdatesFromIsarCache();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newFound > 0 ? 'Found $newFound new chapters!' : 'Library is up to date',
            ),
            backgroundColor: primaryColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Update check failed: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCheckingServer = false);
      }
    }
  }

  Future<void> _toggleChapterRead(Map<String, dynamic> item) async {
    final ch = item['chapter'] as Chapter;
    final newState = !ch.isRead;
    setState(() => ch.applyReadState(newState));

    await IsarService.instance.saveChapter(ch);

    if (ch.serverId > 0) {
      SyncEngine.instance.syncChapterProgress(ch.serverId, isRead: newState, lastPageRead: ch.lastPageRead);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newState ? 'Marked "${ch.name}" as read' : 'Marked "${ch.name}" as unread'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _markAllAsRead() async {
    if (_updatesList.isEmpty) return;

    final unreadItems = _updatesList.where((it) => !(it['chapter'] as Chapter).isRead).toList();
    if (unreadItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All update chapters are already marked as read'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1F1F26),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Mark All as Read', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Mark all ${unreadItems.length} update chapters as read?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Mark as Read'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final chaptersToUpdate = <Chapter>[];
    setState(() {
      for (final it in unreadItems) {
        final ch = it['chapter'] as Chapter;
        ch.applyReadState(true);
        chaptersToUpdate.add(ch);
      }
    });

    await IsarService.instance.saveChapters(chaptersToUpdate);

    for (final ch in chaptersToUpdate) {
      if (ch.serverId > 0) {
        SyncEngine.instance.syncChapterProgress(ch.serverId, isRead: true, lastPageRead: ch.lastPageRead);
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Marked ${chaptersToUpdate.length} chapters as read'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _clearUpdatesHistory() async {
    if (_updatesList.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1F1F26),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear Updates Feed', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Remove current chapters from the Updates feed? This will not delete any chapters or reading history.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final chaptersToReset = <Chapter>[];
    for (final it in _updatesList) {
      final ch = it['chapter'] as Chapter;
      ch.fetchedAt = 0;
      chaptersToReset.add(ch);
    }

    await IsarService.instance.saveChapters(chaptersToReset);

    setState(() {
      _updatesList.clear();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Updates feed cleared'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showDownloadOptions(Map<String, dynamic> item) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final messenger = ScaffoldMessenger.of(context);
    final ch = item['chapter'] as Chapter;
    final isDownloaded = item['isDownloaded'] as bool? ?? false;
    final chId = ch.serverId != 0 ? ch.serverId : ch.id;
    final isLocalDownloaded = DownloadManagerService.instance.isChapterDownloadedLocally(chId);
    final resolvedMangaTitle = (item['title'] as String?) ?? 'Manga';

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F1F24),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ch.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.cloud_download_rounded, color: primaryColor),
                title: const Text('Download to Suwayomi Server', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Download and cache on your central server storage'),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  if (GraphQLClientService.instance.isConfigured) {
                    await GraphQLClientService.instance.enqueueChapterDownload(ch.serverId);
                  }
                  messenger.showSnackBar(
                    SnackBar(content: Text('Enqueued ${ch.name} on server')),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.phone_android_rounded, color: primaryColor),
                title: const Text('Download to Local Device (Offline)', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Save chapter pages locally for offline reading'),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await DownloadManagerService.instance.enqueueLocalDownload(
                    chapterId: chId,
                    mangaId: ch.mangaId,
                    chapterName: ch.name,
                    mangaTitle: resolvedMangaTitle,
                    chapterNumber: ch.chapterNumber,
                  );
                  messenger.showSnackBar(
                    SnackBar(content: Text('Downloading ${ch.name} to local device...')),
                  );
                },
              ),
              if (isDownloaded)
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                  title: const Text('Delete Download from Server', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    if (GraphQLClientService.instance.isConfigured) {
                      await GraphQLClientService.instance.deleteDownloadedChapter(ch.serverId);
                    }
                    if (mounted) {
                      await _loadUpdatesFromIsarCache();
                    }
                  },
                ),
              if (isLocalDownloaded)
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                  title: const Text('Delete Download from Local Device', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Free up offline storage space on this device'),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await DownloadManagerService.instance.deleteLocalDownload(chId);
                    if (mounted) _loadUpdatesFromIsarCache();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUpdateCard(BuildContext context, Map<String, dynamic> item, {required bool isTablet}) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final ch = item['chapter'] as Chapter;
    final mangaId = item['mangaId'] as int;
    final title = item['title'] as String;
    final thumb = item['thumbnailUrl'] as String;
    final chId = ch.serverId != 0 ? ch.serverId : ch.id;

    final isLocalDownloaded = DownloadManagerService.instance.isChapterDownloadedLocally(chId);
    final isDownloading = DownloadManagerService.instance.localTasks
        .any((t) => t.chapterId == chId && (t.status == LocalDownloadStatus.downloading || t.status == LocalDownloadStatus.queued));
    final isDownloaded = (item['isDownloaded'] as bool? ?? false) || isLocalDownloaded || ch.isDownloaded || ch.isDownloadedOnServer;
    final isRead = ch.isRead;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 0.0 : 16.0,
        vertical: 4.0,
      ),
      child: Material(
        color: const Color(0x1F22222E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isRead ? const Color(0x15FFFFFF) : const Color(0x28FFFFFF),
            width: 0.8,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push('/manga/$mangaId'),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: isTablet ? 10 : 8),
            child: Row(
              children: [
                // Manga cover thumbnail
                Hero(
                  tag: 'update_cover_${chId}_$mangaId',
                  child: Container(
                    width: isTablet ? 50 : 44,
                    height: isTablet ? 72 : 62,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey[900],
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: MangaCoverImage(
                        mangaServerId: mangaId,
                        thumbnailUrl: thumb,
                        sourceName: item['sourceName'] as String?,
                        width: isTablet ? 50 : 44,
                        height: isTablet ? 72 : 62,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Manga title and chapter info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isTablet ? 14.5 : 13.5,
                          color: isRead ? Colors.white60 : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          if (!isRead)
                            Container(
                              width: 7,
                              height: 7,
                              margin: const EdgeInsets.only(right: 6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: primaryColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withValues(alpha: 0.6),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          Expanded(
                            child: Text(
                              ch.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: isTablet ? 12.5 : 12,
                                color: isRead ? Colors.white38 : primaryColor,
                                fontWeight: isRead ? FontWeight.normal : FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (isTablet && (item['sourceName'] as String? ?? '').isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          item['sourceName'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white38,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      if (_languageBadgeLabel(item['lang'] as String? ?? '') != null) ...[
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: const Color(0x26FFFFFF),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0x26FFFFFF)),
                            ),
                            child: Text(
                              _languageBadgeLabel(item['lang'] as String? ?? '')!,
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white70,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                // Quick Actions Row
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Mark as read/unread button
                    IconButton(
                      icon: Icon(
                        isRead ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded,
                        color: isRead ? primaryColor : Colors.white38,
                        size: isTablet ? 22 : 20,
                      ),
                      tooltip: isRead ? 'Mark as unread' : 'Mark as read',
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _toggleChapterRead(item),
                    ),
                    // Download button
                    IconButton(
                      icon: isDownloading
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: primaryColor,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(
                              isLocalDownloaded
                                  ? Icons.download_done_rounded
                                  : (ch.isDownloadedOnServer || (item['isDownloaded'] as bool? ?? false)
                                      ? Icons.cloud_done_rounded
                                      : Icons.download_rounded),
                              color: isDownloaded ? Colors.greenAccent : Colors.grey,
                              size: isTablet ? 22 : 20,
                            ),
                      tooltip: isLocalDownloaded
                          ? 'Downloaded on device'
                          : (ch.isDownloadedOnServer ? 'Downloaded on server' : 'Download options'),
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _showDownloadOptions(item),
                    ),
                    // Read chapter button
                    IconButton(
                      icon: Icon(
                        Icons.play_circle_fill_rounded,
                        color: primaryColor,
                        size: isTablet ? 28 : 24,
                      ),
                      tooltip: 'Read chapter',
                      visualDensity: VisualDensity.compact,
                      onPressed: () async {
                        await context.push('/reader/${ch.serverId != 0 ? ch.serverId : ch.id}');
                        if (mounted) _loadUpdatesFromIsarCache();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final primaryColor = Theme.of(context).colorScheme.primary;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 720;

    // Group updates by dateHeader
    final visibleUpdates = _filteredUpdates;
    final Map<String, List<Map<String, dynamic>>> groupedUpdates = {};
    for (final item in visibleUpdates) {
      final header = item['dateHeader'] as String? ?? 'Recent';
      groupedUpdates.putIfAbsent(header, () => []).add(item);
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        title: _isSearching
            ? TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search updates...',
                  border: InputBorder.none,
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Updates', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
            if (_liveUpdateStatus != null && _liveUpdateStatus!.isNotEmpty)
              Text(
                _liveUpdateStatus!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, color: primaryColor, fontWeight: FontWeight.w600),
              )
            else if (!GraphQLClientService.instance.isConfigured)
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.tealAccent.withValues(alpha: 0.4), width: 0.6),
                ),
                child: const Text(
                  'STANDALONE MODE',
                  style: TextStyle(fontSize: 9.5, color: Colors.tealAccent, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              )
            else if (_isOffline)
              const Text(
                'Offline — Cached updates',
                style: TextStyle(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.w600),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close_rounded : Icons.search_rounded),
            tooltip: 'Search',
            onPressed: () => setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) _searchQuery = '';
            }),
          ),
          IconButton(
            icon: Icon(
              _unreadOnly ? Icons.filter_alt_rounded : Icons.filter_alt_outlined,
              color: _unreadOnly ? primaryColor : null,
            ),
            tooltip: _unreadOnly ? 'Show all updates' : 'Unread only',
            onPressed: () => setState(() => _unreadOnly = !_unreadOnly),
          ),
          ListenableBuilder(
            listenable: LibraryUpdateService.instance,
            builder: (context, _) {
              final isBusy = LibraryUpdateService.instance.isUpdating || _isCheckingServer;
              return IconButton(
                icon: isBusy
                    ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: primaryColor, strokeWidth: 2.2))
                    : Icon(Icons.refresh_rounded, color: primaryColor),
                tooltip: GraphQLClientService.instance.isConfigured ? 'Check Server Updates' : 'Check for Updates',
                onPressed: isBusy ? null : _checkServerForUpdates,
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            tooltip: 'More options',
            color: const Color(0xFF22222C),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            onSelected: (val) {
              if (val == 'mark_all_read') {
                _markAllAsRead();
              } else if (val == 'clear_feed') {
                _clearUpdatesHistory();
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'mark_all_read',
                child: Row(
                  children: [
                    Icon(Icons.done_all_rounded, size: 20, color: Colors.white70),
                    SizedBox(width: 10),
                    Text('Mark all as read'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_feed',
                child: Row(
                  children: [
                    Icon(Icons.clear_all_rounded, size: 20, color: Colors.redAccent),
                    SizedBox(width: 10),
                    Text('Clear feed', style: TextStyle(color: Colors.redAccent)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: RefreshIndicator(
            color: primaryColor,
            onRefresh: _checkServerForUpdates,
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: primaryColor))
                : ListenableBuilder(
                    listenable: DownloadManagerService.instance,
                    builder: (context, _) {
                      return CustomScrollView(
                        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                        scrollCacheExtent: ScrollCacheExtent.pixels(800),
                        slivers: [
                          ListenableBuilder(
                            listenable: LibraryUpdateService.instance,
                            builder: (context, _) {
                              final updater = LibraryUpdateService.instance;
                              if (!updater.isUpdating) return const SliverToBoxAdapter(child: SizedBox.shrink());
                              return SliverToBoxAdapter(
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                    horizontal: isTablet ? 24 : 16,
                                    vertical: 8,
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E1E26),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 14,
                                            height: 14,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              updater.statusMessage,
                                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: updater.progress > 0 ? updater.progress : null,
                                          minHeight: 4,
                                          backgroundColor: const Color(0x22FFFFFF),
                                          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          if (_lastUpdateText != null)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isTablet ? 24.0 : 20.0,
                                  vertical: 6.0,
                                ),
                                child: Text(
                                  _lastUpdateText!,
                                  style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                          if (_updatesList.isEmpty)
                            SliverToBoxAdapter(
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.only(top: 80.0, left: 24.0, right: 24.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.notifications_none_rounded, size: 64, color: primaryColor.withAlpha(120)),
                                    const SizedBox(height: 16),
                                    const Text('No Recent Updates', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Pull down to check for updates or\nadd more manga to your library.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.grey, fontSize: 13),
                                    ),
                                    const SizedBox(height: 20),
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColor,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                      ),
                                      icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                                      label: const Text('Check Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                      onPressed: _checkServerForUpdates,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else ...[
                            for (final entry in groupedUpdates.entries) ...[
                              // Date Section Header
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    top: 18.0,
                                    bottom: 8.0,
                                    left: isTablet ? 20.0 : 20.0,
                                    right: 20.0,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        entry.key,
                                        style: TextStyle(
                                          fontSize: isTablet ? 18.5 : 16.5,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.08),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          '${entry.value.length}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Section Content: Grid on Tablet, List on Phone
                              if (isTablet)
                                SliverPadding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  sliver: SliverGrid(
                                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: 480,
                                      mainAxisExtent: 96,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 10,
                                    ),
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) => _buildUpdateCard(
                                        context,
                                        entry.value[index],
                                        isTablet: true,
                                      ),
                                      childCount: entry.value.length,
                                    ),
                                  ),
                                )
                              else
                                SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) => _buildUpdateCard(
                                      context,
                                      entry.value[index],
                                      isTablet: false,
                                    ),
                                    childCount: entry.value.length,
                                  ),
                                ),
                            ],
                            SliverToBoxAdapter(
                              child: SizedBox(height: isTablet ? 40 : 120),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}
