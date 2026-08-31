import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/isar_service.dart';
import '../../core/db/models/chapter.dart';
import '../../core/db/models/manga.dart';
import '../../core/engine/quickjs_service.dart';
import '../../core/logging/logger_service.dart';
import '../../core/services/download_manager_service.dart';
import '../../core/services/image_cache_helper.dart';
import '../../core/services/settings_service.dart';
import '../../core/sync/graphql_client_service.dart';
import 'tracking_bottom_sheet.dart';

class MangaDetailScreen extends StatefulWidget {
  final int mangaServerId;

  const MangaDetailScreen({super.key, required this.mangaServerId});

  @override
  State<MangaDetailScreen> createState() => _MangaDetailScreenState();
}

class _MangaDetailScreenState extends State<MangaDetailScreen> {
  final SettingsService _settings = SettingsService.instance;
  Manga? _manga;
  List<Chapter> _chapters = [];
  bool _isLoading = true;
  bool _sortAscending = false;
  bool _isDescExpanded = false;

  // Chapter filter & search
  String _chapterFilter = 'All'; // 'All', 'Unread', 'Downloaded', 'Bookmarked'
  String _chapterSearch = '';
  bool _isSearchingChapters = false;

  // Multi-chapter selection state
  final Set<int> _selectedChapterIds = {};

  double _extractChapterNumber(String name, int index, int totalCount) {
    final match = RegExp(r'(?:ch(?:apter)?\.?|ep(?:isode)?\.?|#)\s*(\d+(?:\.\d+)?)', caseSensitive: false).firstMatch(name)
        ?? RegExp(r'(\d+(?:\.\d+)?)').firstMatch(name);
    if (match != null) {
      final parsed = double.tryParse(match.group(1)!);
      if (parsed != null && parsed > 0) return parsed;
    }
    return (index + 1).toDouble();
  }

  String _formatChapterSubtitle(Chapter ch) {
    final parts = <String>[];

    // 1. Reading progress or page count
    if (ch.pageCount > 0) {
      if (ch.lastPageRead > 0) {
        parts.add('Page ${ch.lastPageRead}/${ch.pageCount}');
      } else {
        parts.add('${ch.pageCount} pages');
      }
    } else if (ch.lastPageRead > 0) {
      parts.add('Page ${ch.lastPageRead}');
    }

    // 2. Scanlator group
    if (ch.scanlator != null && ch.scanlator!.isNotEmpty) {
      parts.add(ch.scanlator!);
    }

    return parts.join(' • ');
  }

  String? _formatChapterDate(int? rawTimestamp) {
    if (rawTimestamp == null || rawTimestamp <= 0) return null;
    final ms = rawTimestamp > 1000000000000 ? rawTimestamp : rawTimestamp * 1000;
    final date = DateTime.fromMillisecondsSinceEpoch(ms);
    if (date.year < 2005 || date.isAfter(DateTime.now().add(const Duration(days: 2)))) {
      return null;
    }
    return _formatRelativeTime(date);
  }

  String _formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.isNegative) return 'Today';
    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        if (diff.inMinutes <= 1) return 'Just now';
        return '${diff.inMinutes}m ago';
      }
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 30) {
      return '${diff.inDays}d ago';
    } else if (diff.inDays < 365) {
      final months = (diff.inDays / 30).floor();
      return '${months}mo ago';
    } else {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }

  @override
  void initState() {
    super.initState();
    _loadMangaDetails();
  }

  Future<void> _loadMangaDetails() async {
    setState(() => _isLoading = true);
    final serverUrl = GraphQLClientService.instance.baseUrl ?? 'http://localhost:4567';

    // 1. Check local Isar DB first to display immediate cached state
    _manga = await IsarService.instance.getMangaByServerId(widget.mangaServerId);
    _chapters = await IsarService.instance.getChaptersForManga(widget.mangaServerId);
    if (_manga != null && _chapters.isNotEmpty && mounted) {
      setState(() => _isLoading = false);
    }

    // 2. Fetch fresh details AND chapters from Suwayomi GraphQL
    if (GraphQLClientService.instance.isConfigured && widget.mangaServerId > 0 && widget.mangaServerId < 2147483647) {
      try {
        var detailsData = await GraphQLClientService.instance.fetchMangaDetails(widget.mangaServerId);

        // If chapters are empty on server, scrape online from source directly!
        final rawChNodes = (detailsData?['manga']?['chapters']?['nodes'] as List<dynamic>?) ?? [];
        if (rawChNodes.isEmpty) {
          await GraphQLClientService.instance.fetchMangaAndChapters(widget.mangaServerId);
          detailsData = await GraphQLClientService.instance.fetchMangaDetails(widget.mangaServerId);
        }

        if (detailsData != null && detailsData.containsKey('manga') && detailsData['manga'] != null) {
          final mMap = detailsData['manga'] as Map<String, dynamic>;
          _manga ??= Manga()..serverId = widget.mangaServerId;
          _manga!.title = mMap['title'] as String? ?? _manga!.title;
          _manga!.author = mMap['author'] as String?;
          _manga!.artist = mMap['artist'] as String?;
          _manga!.description = mMap['description'] as String?;
          _manga!.status = mMap['status'] as String?;
          _manga!.inLibrary = mMap['inLibrary'] as bool? ?? _manga!.inLibrary;

          final rawMangaUrl = (mMap['url'] ?? mMap['realUrl']) as String?;
          if (rawMangaUrl != null && rawMangaUrl.isNotEmpty) {
            _manga!.url = rawMangaUrl;
          }

          final rawThumb = mMap['thumbnailUrl'] as String?;
          if (rawThumb != null && rawThumb.isNotEmpty) {
            _manga!.thumbnailUrl = rawThumb.startsWith('http') ? rawThumb : '$serverUrl$rawThumb';
          }

          if (mMap.containsKey('genre') && mMap['genre'] != null) {
            _manga!.genres = (mMap['genre'] as List<dynamic>).map((g) => g.toString()).toList();
          }

          final sourceMap = mMap['source'] as Map<String, dynamic>?;
          if (sourceMap != null) {
            _manga!.sourceName = sourceMap['displayName'] as String? ?? sourceMap['name'] as String? ?? _manga!.sourceName;
          }

          await IsarService.instance.saveManga(_manga!);

          // Process nested chapters
          final chaptersMap = mMap['chapters'] as Map<String, dynamic>?;
          if (chaptersMap != null && chaptersMap.containsKey('nodes')) {
            final chNodes = chaptersMap['nodes'] as List<dynamic>?;
            if (chNodes != null && chNodes.isNotEmpty) {
              final fetched = <Chapter>[];
              for (final n in chNodes) {
                final chMap = n as Map<String, dynamic>;
                final rawFetched = chMap['fetchedAt'] ?? chMap['uploadDate'] ?? chMap['dateUpload'];
                int? fetchedTimestamp;
                if (rawFetched is num) {
                  fetchedTimestamp = rawFetched.toInt();
                } else if (rawFetched is String && rawFetched.isNotEmpty) {
                  fetchedTimestamp = int.tryParse(rawFetched) ?? (DateTime.tryParse(rawFetched)?.millisecondsSinceEpoch != null ? DateTime.tryParse(rawFetched)!.millisecondsSinceEpoch ~/ 1000 : null);
                }

                final rawChUrl = (chMap['url'] ?? chMap['realUrl'] ?? '').toString();
                final rawChRealUrl = (chMap['realUrl'] ?? chMap['url'] ?? '').toString();

                final ch = Chapter()
                  ..serverId = parseIntSafe(chMap['id'])
                  ..mangaId = widget.mangaServerId
                  ..name = chMap['name']?.toString() ?? 'Chapter ${chMap['chapterNumber'] ?? ""}'
                  ..chapterNumber = parseDoubleSafe(chMap['chapterNumber'])
                  ..url = rawChUrl
                  ..realUrl = rawChRealUrl
                  ..isRead = parseBoolSafe(chMap['isRead'])
                  ..lastPageRead = parseIntSafe(chMap['lastPageRead'])
                  ..lastReadAt = parseIntSafe(chMap['lastReadAt'])
                  ..pageCount = parseIntSafe(chMap['pageCount'])
                  ..mangaTitle = _manga!.title
                  ..mangaThumbnailUrl = _manga!.thumbnailUrl
                  ..fetchedAt = fetchedTimestamp;
                fetched.add(ch);
              }
              await IsarService.instance.saveChapters(fetched);
              _chapters = fetched;
            }
          }
        }
      } catch (e) {
        await LoggerService.instance.logWarning('Failed to fetch server chapters: $e', 'MangaDetail');
      }
    }

    // 3. Offline / Local Scraper: Scrape chapters directly via QuickJS ONLY if:
    //    - Chapters list is completely empty, OR
    //    - Every chapter has an empty name (truly invalid data)
    // NOTE: Server chapters from GraphQL intentionally have relative URLs or no page URLs — that's normal.
    //       URLs are resolved lazily at read time via ContentResolverService.
    final chaptersNeedEnrichment = _chapters.isEmpty ||
        _chapters.every((c) => c.name.trim().isEmpty);
    if (chaptersNeedEnrichment && _manga != null && _manga!.sourceName.isNotEmpty) {
      try {
        final localData = await QuickJsService.instance.fetchMangaDetailsLocal(
          _manga!.sourceName,
          _manga!.url.isNotEmpty ? _manga!.url : _manga!.title,
        );
        if (localData.isNotEmpty) {
          if (localData['description'] != null && (_manga!.description == null || _manga!.description!.isEmpty)) {
            _manga!.description = localData['description'].toString();
          }
          if (localData['author'] != null && (_manga!.author == null || _manga!.author!.isEmpty)) {
            _manga!.author = localData['author'].toString();
          }
          if (localData['imageUrl'] != null && (_manga!.thumbnailUrl == null || _manga!.thumbnailUrl!.isEmpty)) {
            _manga!.thumbnailUrl = localData['imageUrl'].toString();
          }
          await IsarService.instance.saveManga(_manga!);

          final chList = (localData['chapters'] ?? localData['chapterList'] ?? localData['epList'] ?? localData['episodes']) as List<dynamic>?;
          if (chList != null && chList.isNotEmpty) {
            final fetched = <Chapter>[];
            for (var i = 0; i < chList.length; i++) {
              final cMap = chList[i] as Map<String, dynamic>;
              final chUrl = (cMap['url'] ?? cMap['link'] ?? '').toString();
              final chName = cMap['name']?.toString() ?? 'Chapter ${i + 1}';
              final rawChNum = (cMap['chapterNumber'] as num?)?.toDouble();
              final chNum = (rawChNum != null && rawChNum > 0) ? rawChNum : _extractChapterNumber(chName, i, chList.length);

              final chServerId = (widget.mangaServerId > 0 && widget.mangaServerId < 200000)
                  ? (widget.mangaServerId * 10000 + i + 1)
                  : (((widget.mangaServerId.hashCode & 0x0007FFFF) * 1000) + (i + 1));

              final rawDate = cMap['dateUpload'] ?? cMap['uploadDate'] ?? cMap['date'] ?? cMap['releaseDate'];
              int? parsedDate;
              if (rawDate is num) {
                parsedDate = rawDate.toInt();
              } else if (rawDate is String && rawDate.isNotEmpty) {
                parsedDate = int.tryParse(rawDate) ?? (DateTime.tryParse(rawDate)?.millisecondsSinceEpoch != null ? DateTime.tryParse(rawDate)!.millisecondsSinceEpoch ~/ 1000 : null);
              }

              final ch = Chapter()
                ..serverId = chServerId
                ..mangaId = widget.mangaServerId
                ..name = chName
                ..chapterNumber = chNum
                ..url = chUrl
                ..realUrl = chUrl
                ..mangaTitle = _manga!.title
                ..fetchedAt = parsedDate;
              fetched.add(ch);
            }
            final existingChapters = await IsarService.instance.getChaptersForManga(widget.mangaServerId);

            // Transfer read progress from existing chapters to freshly scraped ones
            // so we don't wipe reading history when the chapter list refreshes
            if (existingChapters.isNotEmpty) {
              // Build lookup map keyed by URL, by number, and by name for fuzzy matching
              final progressByUrl = <String, Chapter>{};
              final progressByName = <String, Chapter>{};
              final progressByNum = <double, Chapter>{};
              for (final existing in existingChapters) {
                if (existing.url.isNotEmpty) progressByUrl[existing.url] = existing;
                progressByName[existing.name.trim().toLowerCase()] = existing;
                if (existing.chapterNumber > 0) progressByNum[existing.chapterNumber] = existing;
              }
              for (final ch in fetched) {
                final match = progressByUrl[ch.url] ??
                    (ch.chapterNumber > 0 ? progressByNum[ch.chapterNumber] : null) ??
                    progressByName[ch.name.trim().toLowerCase()];
                if (match != null) {
                  ch.serverId = match.serverId; // Preserve canonical server ID
                  ch.isRead = match.isRead;
                  ch.lastPageRead = match.lastPageRead;
                  ch.lastReadAt = match.lastReadAt;
                  ch.isDownloaded = match.isDownloaded;
                  ch.pageCount = match.pageCount;
                  match.url = ch.url;
                  match.realUrl = ch.realUrl;
                }
              }
              await IsarService.instance.saveChapters(existingChapters);

              final isar = IsarService.instance.isar;
              await isar.writeTxn(() async {
                await isar.chapters.deleteAll(existingChapters.map((c) => c.id).toList());
              });
            }
            await IsarService.instance.saveChapters(fetched);
            _chapters = fetched;
            if (_manga != null) {
              await IsarService.instance.saveManga(_manga!);
            }
          }
        }
      } catch (_) {}
    }

    _manga ??= Manga()
      ..serverId = widget.mangaServerId
      ..title = 'Manga #${widget.mangaServerId}'
      ..inLibrary = true;

    if (_manga != null) {
      await IsarService.instance.saveManga(_manga!);
    }

    if (_chapters.isEmpty) {
      _chapters = await IsarService.instance.getChaptersForManga(widget.mangaServerId);
    }

    // Merge and deduplicate chapters cleanly
    _chapters = _mergeAndDeduplicateChapters(_chapters);

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  List<Chapter> _mergeAndDeduplicateChapters(List<Chapter> list) {
    final map = <String, Chapter>{};
    final mangaTitleLower = _manga?.title.trim().toLowerCase() ?? '';

    for (final ch in list) {
      var cleanName = ch.name.trim();

      // Strip redundant leading manga title prefix if present (e.g. Mangahere)
      if (mangaTitleLower.isNotEmpty && cleanName.toLowerCase().startsWith(mangaTitleLower)) {
        final stripped = cleanName.substring(mangaTitleLower.length).replaceAll(RegExp(r'^[\s\-–—:]+'), '').trim();
        if (stripped.isNotEmpty) cleanName = stripped;
      }

      // Strip redundant trailing (ch. 1115) or (Ch. 1115) suffix
      cleanName = cleanName.replaceAll(RegExp(r'\s*\([Cc]h\.?\s*\d+\)$'), '').trim();
      if (cleanName.isEmpty) cleanName = ch.name.trim();
      ch.name = cleanName;

      final extractedNum = _extractChapterNumber(cleanName, 0, list.length);
      if (extractedNum > 0) {
        ch.chapterNumber = extractedNum;
      }

      final numKey = ch.chapterNumber > 0 ? 'num_${ch.chapterNumber.toStringAsFixed(2)}' : null;
      final urlKey = ch.url.isNotEmpty ? 'url_${ch.url.toLowerCase().trim()}' : null;
      final nameKey = 'name_${cleanName.toLowerCase()}';

      final key = numKey ?? urlKey ?? nameKey;

      if (!map.containsKey(key)) {
        map[key] = ch;
      } else {
        final existing = map[key]!;
        if (existing.url.isEmpty && ch.url.isNotEmpty) existing.url = ch.url;
        if (existing.realUrl.isEmpty && ch.realUrl.isNotEmpty) existing.realUrl = ch.realUrl;
        if ((existing.fetchedAt == null || existing.fetchedAt == 0) && ch.fetchedAt != null && ch.fetchedAt! > 0) {
          existing.fetchedAt = ch.fetchedAt;
        }
        if (!existing.isRead && ch.isRead) existing.isRead = true;
        if (existing.lastPageRead == 0 && ch.lastPageRead > 0) existing.lastPageRead = ch.lastPageRead;
        if (existing.lastReadAt == null && ch.lastReadAt != null) existing.lastReadAt = ch.lastReadAt;
        if (!existing.isDownloaded && ch.isDownloaded) existing.isDownloaded = true;
        if (existing.pageCount == 0 && ch.pageCount > 0) existing.pageCount = ch.pageCount;
      }
    }

    return map.values.toList();
  }

  void _toggleInLibrary() async {
    if (_manga == null) return;
    final newState = !_manga!.inLibrary;
    setState(() => _manga!.inLibrary = newState);
    await IsarService.instance.saveManga(_manga!);

    try {
      if (GraphQLClientService.instance.isConfigured) {
        await GraphQLClientService.instance.updateMangaLibraryState(widget.mangaServerId, newState);

        // If newly added to library and a default category is set, assign it!
        if (newState && SettingsService.instance.defaultCategoryId != null) {
          await GraphQLClientService.instance.updateMangaCategories(
            widget.mangaServerId,
            [SettingsService.instance.defaultCategoryId!],
          );
        }
      }
    } catch (_) {}

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newState
                ? 'Added to library (${SettingsService.instance.defaultCategoryName})'
                : 'Removed from library',
          ),
        ),
      );
    }
  }

  void _openReader(int chapterServerId) {
    context.push('/reader/$chapterServerId');
  }

  void _continueReading() {
    if (_chapters.isEmpty) return;
    // 1. Resume chapter currently in progress
    final inProgress = _chapters.where((c) => !c.isRead && c.lastPageRead > 0).toList();
    if (inProgress.isNotEmpty) {
      inProgress.sort((a, b) => (b.lastReadAt ?? 0).compareTo(a.lastReadAt ?? 0));
      _openReader(inProgress.first.serverId);
      return;
    }
    // 2. Find next unread chapter in reading order (lowest chapter number)
    final sortedByNum = List<Chapter>.from(_chapters)..sort((a, b) => a.chapterNumber.compareTo(b.chapterNumber));
    final unread = sortedByNum.firstWhere((c) => !c.isRead, orElse: () => sortedByNum.first);
    _openReader(unread.serverId);
  }

  void _toggleChapterRead(Chapter ch) async {
    final newState = !ch.isRead;
    setState(() {
      ch.isRead = newState;
      if (!newState) ch.lastPageRead = 0;
    });
    await IsarService.instance.saveChapter(ch);

    if (newState && _settings.deleteChapterAfterMarkedRead && ch.isDownloaded) {
      if (!ch.isBookmarked || _settings.allowDeletingBookmarkedChapters) {
        DownloadManagerService.instance.deleteLocalDownload(ch.serverId);
      }
    }

    if (GraphQLClientService.instance.isConfigured) {
      GraphQLClientService.instance.updateChapterReadStatus(ch.serverId, newState, ch.lastPageRead);
    }
  }

  void _toggleChapterBookmark(Chapter ch) async {
    final newState = !ch.isBookmarked;
    setState(() => ch.isBookmarked = newState);
    await IsarService.instance.saveChapter(ch);

    if (GraphQLClientService.instance.isConfigured) {
      GraphQLClientService.instance.updateChapterBookmark(ch.serverId, newState);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(newState ? 'Bookmark added' : 'Bookmark removed')),
      );
    }
  }

  void _markPreviousChaptersRead(Chapter ch) async {
    final prevs = _chapters.where((c) => c.chapterNumber < ch.chapterNumber && !c.isRead).toList();
    for (final p in prevs) {
      p.isRead = true;
      if (_settings.deleteChapterAfterMarkedRead && p.isDownloaded) {
        if (!p.isBookmarked || _settings.allowDeletingBookmarkedChapters) {
          DownloadManagerService.instance.deleteLocalDownload(p.serverId);
        }
      }
      if (GraphQLClientService.instance.isConfigured) {
        GraphQLClientService.instance.updateChapterReadStatus(p.serverId, true, p.lastPageRead);
      }
    }
    await IsarService.instance.saveChapters(prevs);
    setState(() {});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Marked ${prevs.length} previous chapters as read')),
      );
    }
  }

  // ── MULTI-CHAPTER SELECTION ACTIONS ────────────────────────
  void _enterSelectionMode(Chapter ch) {
    setState(() {
      _selectedChapterIds.add(ch.serverId);
    });
  }

  void _selectAllChapters() {
    setState(() {
      if (_selectedChapterIds.length == _chapters.length) {
        _selectedChapterIds.clear();
      } else {
        _selectedChapterIds.addAll(_chapters.map((c) => c.serverId));
      }
    });
  }

  void _markSelectedRead(bool read) async {
    final targets = _chapters.where((c) => _selectedChapterIds.contains(c.serverId)).toList();
    for (final c in targets) {
      c.isRead = read;
      if (!read) c.lastPageRead = 0;
      if (read && _settings.deleteChapterAfterMarkedRead && c.isDownloaded) {
        if (!c.isBookmarked || _settings.allowDeletingBookmarkedChapters) {
          DownloadManagerService.instance.deleteLocalDownload(c.serverId);
        }
      }
      if (GraphQLClientService.instance.isConfigured) {
        GraphQLClientService.instance.updateChapterReadStatus(c.serverId, read, c.lastPageRead);
      }
    }
    await IsarService.instance.saveChapters(targets);
    setState(() => _selectedChapterIds.clear());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Marked ${targets.length} chapters as ${read ? "read" : "unread"}')),
      );
    }
  }

  void _downloadSelected(bool local) async {
    final targets = _chapters.where((c) => _selectedChapterIds.contains(c.serverId)).toList();
    if (local) {
      for (final c in targets) {
        await DownloadManagerService.instance.enqueueLocalDownload(
          chapterId: c.serverId,
          mangaId: widget.mangaServerId,
          chapterName: c.name,
          mangaTitle: _manga?.title ?? 'Manga',
        );
      }
    } else {
      final ids = targets.map((c) => c.serverId).toList();
      await DownloadManagerService.instance.enqueueServerDownloads(ids);
    }
    setState(() => _selectedChapterIds.clear());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enqueued ${targets.length} chapters for ${local ? "device" : "server"} download')),
      );
    }
  }

  void _deleteSelectedDownloads() async {
    final targets = _chapters.where((c) => _selectedChapterIds.contains(c.serverId)).toList();
    for (final c in targets) {
      await DownloadManagerService.instance.deleteLocalDownload(c.serverId);
      await DownloadManagerService.instance.deleteServerDownload(c.serverId);
    }
    setState(() => _selectedChapterIds.clear());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted downloads for ${targets.length} chapters')),
      );
    }
  }

  void _showBatchDownloadModal() {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final unreadChapters = _chapters.where((c) => !c.isRead).toList();
    bool downloadToLocal = true;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F1F24),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Download Options',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(value: true, label: Text('Device', style: TextStyle(fontSize: 11))),
                          ButtonSegment(value: false, label: Text('Server', style: TextStyle(fontSize: 11))),
                        ],
                        selected: {downloadToLocal},
                        onSelectionChanged: (set) {
                          setSheetState(() => downloadToLocal = set.first);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDownloadOptionTile('Next chapter', 1, unreadChapters, primaryColor, downloadToLocal),
                  _buildDownloadOptionTile('Next 5 chapters', 5, unreadChapters, primaryColor, downloadToLocal),
                  _buildDownloadOptionTile('Next 10 chapters', 10, unreadChapters, primaryColor, downloadToLocal),
                  _buildDownloadOptionTile('All unread chapters (${unreadChapters.length})', unreadChapters.length, unreadChapters, primaryColor, downloadToLocal),
                  _buildDownloadOptionTile('All chapters (${_chapters.length})', _chapters.length, _chapters, primaryColor, downloadToLocal),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDownloadOptionTile(String title, int count, List<Chapter> sourceList, Color primaryColor, bool downloadToLocal) {
    return ListTile(
      leading: Icon(downloadToLocal ? Icons.phone_android_rounded : Icons.cloud_download_rounded, color: primaryColor),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(downloadToLocal ? 'Download to offline device' : 'Download to Suwayomi server', style: const TextStyle(color: Colors.grey, fontSize: 11)),
      onTap: () async {
        Navigator.pop(context);
        final targets = sourceList.take(count).toList();
        if (downloadToLocal) {
          for (final c in targets) {
            await DownloadManagerService.instance.enqueueLocalDownload(
              chapterId: c.serverId,
              mangaId: widget.mangaServerId,
              chapterName: c.name,
              mangaTitle: _manga?.title ?? 'Manga',
            );
          }
        } else {
          final ids = targets.map((c) => c.serverId).toList();
          await DownloadManagerService.instance.enqueueServerDownloads(ids);
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Enqueued $count chapters for ${downloadToLocal ? "device" : "server"} download')),
          );
        }
      },
    );
  }

  void _showSingleChapterOptions(Chapter ch) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final messenger = ScaffoldMessenger.of(context);
    final isDownloadedLocally = DownloadManagerService.instance.isChapterDownloadedLocally(ch.serverId);
    final isDownloadedOnServer = DownloadManagerService.instance.isChapterDownloadedOnServer(ch.serverId) || ch.isDownloaded;

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
                leading: Icon(Icons.check_box_outlined, color: primaryColor),
                title: const Text('Select', style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _enterSelectionMode(ch);
                },
              ),
              ListTile(
                leading: Icon(ch.isBookmarked ? Icons.bookmark_remove_rounded : Icons.bookmark_add_rounded, color: Colors.amber),
                title: Text(ch.isBookmarked ? 'Remove Bookmark' : 'Add Bookmark', style: const TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _toggleChapterBookmark(ch);
                },
              ),
              ListTile(
                leading: Icon(ch.isRead ? Icons.mark_chat_unread_rounded : Icons.check_circle_rounded, color: primaryColor),
                title: Text(ch.isRead ? 'Mark as Unread' : 'Mark as Read', style: const TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _toggleChapterRead(ch);
                },
              ),
              ListTile(
                leading: const Icon(Icons.done_all_rounded, color: Colors.grey),
                title: const Text('Mark Previous as Read', style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _markPreviousChaptersRead(ch);
                },
              ),

              // Local Download option: Only show Download if not downloaded; show Delete if downloaded!
              if (!isDownloadedLocally)
                ListTile(
                  leading: Icon(Icons.phone_android_rounded, color: primaryColor),
                  title: const Text('Download to Local Device (Offline)', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Save images to device for offline reading'),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await DownloadManagerService.instance.enqueueLocalDownload(
                      chapterId: ch.serverId,
                      mangaId: widget.mangaServerId,
                      chapterName: ch.name,
                      mangaTitle: _manga?.title ?? 'Manga',
                    );
                    messenger.showSnackBar(
                      SnackBar(content: Text('Downloading ${ch.name} to device...')),
                    );
                  },
                )
              else
                ListTile(
                  leading: const Icon(Icons.delete_sweep_rounded, color: Colors.orangeAccent),
                  title: const Text('Delete from Local Device', style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await DownloadManagerService.instance.deleteLocalDownload(ch.serverId);
                    messenger.showSnackBar(
                      SnackBar(content: Text('Deleted ${ch.name} from local storage')),
                    );
                  },
                ),

              // Server Download option: Only show Download if not downloaded; show Delete if downloaded!
              if (!isDownloadedOnServer)
                ListTile(
                  leading: Icon(Icons.cloud_download_rounded, color: primaryColor),
                  title: const Text('Download to Server', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Queue download on Suwayomi server storage'),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await DownloadManagerService.instance.enqueueServerDownload(ch.serverId);
                    messenger.showSnackBar(
                      SnackBar(content: Text('Enqueued ${ch.name} on server')),
                    );
                  },
                )
              else
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                  title: const Text('Delete Download from Server', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await DownloadManagerService.instance.deleteServerDownload(ch.serverId);
                    messenger.showSnackBar(
                      SnackBar(content: Text('Deleted ${ch.name} from server')),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    final manga = _manga!;
    var sortedChapters = List<Chapter>.from(_chapters);

    // Filter by Read/Downloaded/Bookmarked status
    if (_chapterFilter == 'Unread') {
      sortedChapters = sortedChapters.where((c) => !c.isRead).toList();
    } else if (_chapterFilter == 'Downloaded') {
      sortedChapters = sortedChapters.where((c) =>
        DownloadManagerService.instance.isChapterDownloadedLocally(c.serverId) ||
        DownloadManagerService.instance.isChapterDownloadedOnServer(c.serverId) ||
        c.isDownloaded
      ).toList();
    } else if (_chapterFilter == 'Bookmarked') {
      sortedChapters = sortedChapters.where((c) => c.isBookmarked).toList();
    }

    // Filter by search query
    if (_chapterSearch.trim().isNotEmpty) {
      final q = _chapterSearch.trim().toLowerCase();
      sortedChapters = sortedChapters.where((c) =>
        c.name.toLowerCase().contains(q) ||
        c.chapterNumber.toString().contains(q)
      ).toList();
    }

    if (_sortAscending) {
      sortedChapters.sort((a, b) => a.chapterNumber.compareTo(b.chapterNumber));
    } else {
      sortedChapters.sort((a, b) => b.chapterNumber.compareTo(a.chapterNumber));
    }

    final isSelecting = _selectedChapterIds.isNotEmpty;

    return Scaffold(
      appBar: isSelecting
          ? AppBar(
              backgroundColor: const Color(0xFF1F1F24),
              leading: IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => setState(() => _selectedChapterIds.clear()),
              ),
              title: Text('${_selectedChapterIds.length} Selected', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.select_all_rounded),
                  tooltip: 'Select / Deselect All',
                  onPressed: _selectAllChapters,
                ),
                IconButton(
                  icon: const Icon(Icons.done_all_rounded),
                  tooltip: 'Mark as Read',
                  onPressed: () => _markSelectedRead(true),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_done_rounded),
                  tooltip: 'Mark as Unread',
                  onPressed: () => _markSelectedRead(false),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded),
                  onSelected: (val) {
                    if (val == 'download_local') _downloadSelected(true);
                    if (val == 'download_server') _downloadSelected(false);
                    if (val == 'delete') _deleteSelectedDownloads();
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'download_local', child: Text('Download to Device')),
                    PopupMenuItem(value: 'download_server', child: Text('Download to Server')),
                    PopupMenuItem(value: 'delete', child: Text('Delete Downloads', style: TextStyle(color: Colors.redAccent))),
                  ],
                ),
              ],
            )
          : null,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 840) {
            return _buildTabletLayout(context, manga, sortedChapters, primaryColor, isSelecting);
          }
          return _buildPhoneLayout(context, manga, sortedChapters, primaryColor, isSelecting);
        },
      ),
    );
  }

  Widget _buildTabletLayout(
    BuildContext context,
    Manga manga,
    List<Chapter> sortedChapters,
    Color primaryColor,
    bool isSelecting,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── LEFT PANE: COVER, INFO & ACTIONS ─────────────────
        SizedBox(
          width: 380,
          child: Container(
            decoration: const BoxDecoration(
              border: Border(right: BorderSide(color: Color(0x1AFFFFFF), width: 1)),
            ),
            child: ListView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              padding: const EdgeInsets.all(24.0),
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        manga.inLibrary ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: manga.inLibrary ? Colors.redAccent : Colors.white,
                      ),
                      onPressed: _toggleInLibrary,
                    ),
                    IconButton(
                      icon: const Icon(Icons.download_rounded),
                      tooltip: 'Download Chapters',
                      onPressed: _showBatchDownloadModal,
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded),
                      onPressed: _loadMangaDetails,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: SizedBox(
                      width: 200,
                      height: 280,
                      child: MangaCoverImage(
                        mangaServerId: manga.serverId,
                        thumbnailUrl: manga.thumbnailUrl,
                        sourceName: manga.sourceName,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  manga.title,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                ),
                const SizedBox(height: 6),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (manga.author != null && manga.author!.isNotEmpty)
                      Text(manga.author!, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                    if (manga.author != null && manga.author!.isNotEmpty)
                      const Text(' • ', style: TextStyle(color: Colors.white70)),
                    Text(manga.sourceName, style: TextStyle(color: primaryColor, fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0x334CAF50),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.greenAccent, width: 0.8),
                      ),
                      child: Text(
                        (manga.status ?? 'Ongoing').toUpperCase(),
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.greenAccent),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0x1F2A2A32),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0x2BFFFFFF), width: 0.8),
                      ),
                      child: Text(
                        '${sortedChapters.length} CHAPTERS',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: manga.inLibrary ? const Color(0x33FF3D00) : primaryColor,
                          foregroundColor: manga.inLibrary ? Colors.redAccent : Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: _toggleInLibrary,
                        icon: Icon(manga.inLibrary ? Icons.favorite_rounded : Icons.favorite_border_rounded, size: 18),
                        label: Text(
                          manga.inLibrary ? 'IN LIBRARY' : 'ADD TO LIBRARY',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Color(0x2BFFFFFF)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => TrackingBottomSheet.show(context, widget.mangaServerId, manga.title),
                        icon: const Icon(Icons.sync_alt_rounded, size: 18),
                        label: const Text('TRACKING', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0x33FFFFFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: _continueReading,
                  icon: Icon(Icons.play_arrow_rounded, color: primaryColor, size: 22),
                  label: const Text('Continue Reading', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),
                if (manga.genres.isNotEmpty) ...[
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: manga.genres.map((g) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0x1F2A2A32),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0x2BFFFFFF), width: 0.8),
                        ),
                        child: Text(g, style: const TextStyle(fontSize: 11, color: Colors.white70)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  manga.description ?? 'No synopsis available for this manga.',
                  style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
        ),

        // ── RIGHT PANE: CHAPTER LIST ─────────────────────────
        Expanded(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${sortedChapters.length} Chapters',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.checklist_rounded),
                          tooltip: 'Select Chapters',
                          onPressed: () {
                            if (sortedChapters.isNotEmpty) {
                              _enterSelectionMode(sortedChapters.first);
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.download_for_offline_rounded),
                          tooltip: 'Batch Download',
                          onPressed: _showBatchDownloadModal,
                        ),
                        IconButton(
                          icon: Icon(_sortAscending ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, color: primaryColor),
                          onPressed: () {
                            setState(() {
                              _sortAscending = !_sortAscending;
                              SettingsService.instance.chapterSortAscending = _sortAscending;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0x1AFFFFFF)),
              Expanded(
                child: sortedChapters.isEmpty
                    ? const Center(child: Text('No chapters found.', style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                        itemCount: sortedChapters.length,
                        itemBuilder: (context, index) {
                          final ch = sortedChapters[index];
                          final isSelected = _selectedChapterIds.contains(ch.serverId);
                          return _buildChapterListTile(ch, isSelected, isSelecting, primaryColor);
                        },
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneLayout(
    BuildContext context,
    Manga manga,
    List<Chapter> sortedChapters,
    Color primaryColor,
    bool isSelecting,
  ) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      scrollCacheExtent: ScrollCacheExtent.pixels(1000),
      slivers: [
        if (!isSelecting)
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: const Color(0xFF121216),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  manga.inLibrary ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: manga.inLibrary ? Colors.redAccent : Colors.white,
                ),
                onPressed: _toggleInLibrary,
              ),
              IconButton(
                icon: const Icon(Icons.download_rounded, color: Colors.white),
                tooltip: 'Download Chapters',
                onPressed: _showBatchDownloadModal,
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                onPressed: _loadMangaDetails,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // 1. Blurred Artwork Backdrop
                  Positioned.fill(
                    child: ImageFiltered(
                      imageFilter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Transform.scale(
                        scale: 1.15,
                        child: MangaCoverImage(
                          mangaServerId: manga.serverId,
                          thumbnailUrl: manga.thumbnailUrl,
                          sourceName: manga.sourceName,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  // 2. Gradient surface blend
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0x80000000),
                          Color(0xB3121216),
                          Color(0xFF121216),
                        ],
                        stops: [0.0, 0.55, 1.0],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // 3. Foreground Hero Content
                  Positioned(
                    bottom: 16,
                    left: 18,
                    right: 18,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Cover card
                        Container(
                          width: 90,
                          height: 130,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0x33FFFFFF), width: 1.2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.6),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(11),
                            child: MangaCoverImage(
                              mangaServerId: manga.serverId,
                              thumbnailUrl: manga.thumbnailUrl,
                              sourceName: manga.sourceName,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Metadata column
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                manga.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.2,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 5),
                              if (manga.author != null && manga.author!.isNotEmpty)
                                Text(
                                  manga.author!,
                                  style: const TextStyle(color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.w500),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withAlpha(40),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: primaryColor.withAlpha(120), width: 0.8),
                                    ),
                                    child: Text(
                                      manga.sourceName,
                                      style: TextStyle(color: primaryColor, fontSize: 10.5, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0x334CAF50),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: Colors.greenAccent.withAlpha(150), width: 0.8),
                                    ),
                                    child: Text(
                                      (manga.status ?? 'Ongoing').toUpperCase(),
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.greenAccent),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0x1F2A2A32),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: const Color(0x2BFFFFFF), width: 0.8),
                                    ),
                                    child: Text(
                                      '${sortedChapters.length} CH',
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: manga.inLibrary ? const Color(0x33FF3D00) : primaryColor,
                          foregroundColor: manga.inLibrary ? Colors.redAccent : Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: _toggleInLibrary,
                        icon: Icon(manga.inLibrary ? Icons.favorite_rounded : Icons.favorite_border_rounded, size: 20),
                        label: Text(
                          manga.inLibrary ? 'IN LIBRARY' : 'ADD TO LIBRARY',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Color(0x2BFFFFFF)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => TrackingBottomSheet.show(context, widget.mangaServerId, manga.title),
                        icon: const Icon(Icons.sync_alt_rounded, size: 20),
                        label: const Text('TRACKING', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Builder(
                  builder: (context) {
                    final hasReadAny = _chapters.any((c) => c.isRead || c.lastPageRead > 0);
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [
                            primaryColor.withValues(alpha: 0.25),
                            const Color(0x1F2A2A32),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(color: primaryColor.withValues(alpha: 0.4), width: 0.8),
                      ),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: _continueReading,
                        icon: Icon(Icons.play_arrow_rounded, color: primaryColor, size: 24),
                        label: Text(
                          hasReadAny ? 'Continue Reading' : 'Start Reading',
                          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: -0.2),
                        ),
                      ),
                    );
                  }
                ),
                const SizedBox(height: 16),
                if (manga.genres.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: manga.genres.map((g) {
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            // Quick search for this genre/tag
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Tag: $g'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0x1A2A2A32),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0x2EFFFFFF), width: 0.8),
                            ),
                            child: Text(
                              g,
                              style: const TextStyle(fontSize: 11.5, color: Colors.white70, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
                GestureDetector(
                  onTap: () => setState(() => _isDescExpanded = !_isDescExpanded),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0x1F2A2A32),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0x2BFFFFFF), width: 0.8),
                    ),
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            manga.description ?? 'No synopsis available for this manga.',
                            maxLines: _isDescExpanded ? null : 3,
                            overflow: _isDescExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white70, fontSize: 13.5, height: 1.45),
                          ),
                          if (manga.description != null && manga.description!.length > 100) ...[
                            const SizedBox(height: 8),
                            Text(
                              _isDescExpanded ? 'Show less' : 'Read more',
                              style: TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${sortedChapters.length} Chapters',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(_isSearchingChapters ? Icons.search_off_rounded : Icons.search_rounded),
                          tooltip: 'Search Chapters',
                          onPressed: () => setState(() {
                            _isSearchingChapters = !_isSearchingChapters;
                            if (!_isSearchingChapters) _chapterSearch = '';
                          }),
                        ),
                        IconButton(
                          icon: const Icon(Icons.checklist_rounded),
                          tooltip: 'Select Chapters',
                          onPressed: () {
                            if (sortedChapters.isNotEmpty) {
                              _enterSelectionMode(sortedChapters.first);
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.download_for_offline_rounded),
                          tooltip: 'Batch Download',
                          onPressed: _showBatchDownloadModal,
                        ),
                        IconButton(
                          icon: Icon(_sortAscending ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, color: primaryColor),
                          tooltip: _sortAscending ? 'Sort Oldest First' : 'Sort Newest First',
                          onPressed: () {
                            setState(() {
                              _sortAscending = !_sortAscending;
                              SettingsService.instance.chapterSortAscending = _sortAscending;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                if (_isSearchingChapters) ...[
                  const SizedBox(height: 8),
                  TextField(
                    autofocus: true,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search chapters (e.g. 10 or Prologue)...',
                      hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                      prefixIcon: Icon(Icons.search_rounded, color: primaryColor, size: 20),
                      suffixIcon: _chapterSearch.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () => setState(() => _chapterSearch = ''),
                            )
                          : null,
                      filled: true,
                      fillColor: const Color(0xFF1F1F24),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    onChanged: (val) => setState(() => _chapterSearch = val),
                  ),
                ],
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Unread', 'Downloaded', 'Bookmarked'].map((filter) {
                      final isSel = _chapterFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(filter),
                          selected: isSel,
                          selectedColor: primaryColor.withValues(alpha: 0.25),
                          backgroundColor: const Color(0x1F2A2A32),
                          labelStyle: TextStyle(
                            color: isSel ? primaryColor : Colors.white70,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSel ? primaryColor : const Color(0x2BFFFFFF),
                              width: 0.8,
                            ),
                          ),
                          onSelected: (_) => setState(() => _chapterFilter = filter),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),

        if (sortedChapters.isEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(child: Text('No chapters found.', style: TextStyle(color: Colors.grey))),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 120.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final ch = sortedChapters[index];
                  final isSelected = _selectedChapterIds.contains(ch.serverId);
                  return _buildChapterListTile(ch, isSelected, isSelecting, primaryColor);
                },
                childCount: sortedChapters.length,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildChapterListTile(
    Chapter ch,
    bool isSelected,
    bool isSelecting,
    Color primaryColor,
  ) {
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Material(
          color: isSelected ? primaryColor.withAlpha(30) : const Color(0x1F2A2A32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: isSelected ? primaryColor : const Color(0x1AFFFFFF),
              width: isSelected ? 1.4 : 0.8,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            onTap: () {
              if (isSelecting) {
                setState(() {
                  if (isSelected) {
                    _selectedChapterIds.remove(ch.serverId);
                  } else {
                    _selectedChapterIds.add(ch.serverId);
                  }
                });
              } else {
                _openReader(ch.serverId);
              }
            },
            onLongPress: () => _enterSelectionMode(ch),
            leading: isSelecting
                ? Checkbox(
                    value: isSelected,
                    activeColor: primaryColor,
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _selectedChapterIds.add(ch.serverId);
                        } else {
                          _selectedChapterIds.remove(ch.serverId);
                        }
                      });
                    },
                  )
                : ch.isBookmarked
                    ? const Icon(Icons.bookmark_rounded, color: Colors.amber, size: 18)
                    : null,
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    ch.name.trim().isNotEmpty
                        ? ch.name
                        : 'Chapter ${ch.chapterNumber.toString().replaceAll(RegExp(r'\.0$'), '')}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                      color: ch.isRead ? Colors.grey : Colors.white,
                    ),
                  ),
                ),
                Builder(
                  builder: (context) {
                    final dateStr = _formatChapterDate(ch.fetchedAt);
                    if (dateStr == null) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(left: 6.0),
                      child: Text(
                        dateStr,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_formatChapterSubtitle(ch).isNotEmpty)
                  Text(
                    _formatChapterSubtitle(ch),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11.5, color: ch.isRead ? Colors.grey[600] : primaryColor),
                  ),
                if (!ch.isRead && ch.lastPageRead > 0 && ch.pageCount > 0) ...[
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: (ch.lastPageRead / ch.pageCount).clamp(0.0, 1.0),
                      minHeight: 3,
                      backgroundColor: const Color(0x33FFFFFF),
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  ),
                ],
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (DownloadManagerService.instance.isChapterDownloadedLocally(ch.serverId))
                  const Padding(
                    padding: EdgeInsets.only(right: 2.0),
                    child: Icon(Icons.phone_android_rounded, color: Colors.greenAccent, size: 16),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.download_rounded, color: Colors.grey, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      DownloadManagerService.instance.enqueueLocalDownload(chapterId: ch.serverId, mangaId: _manga!.serverId, chapterName: ch.name, mangaTitle: _manga!.title);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Queued ${ch.name} for local download')));
                      setState(() {});
                    },
                  ),
                if (DownloadManagerService.instance.isChapterDownloadedOnServer(ch.serverId) || ch.isDownloaded)
                  const Padding(
                    padding: EdgeInsets.only(right: 2.0),
                    child: Icon(Icons.cloud_done_rounded, color: Colors.cyanAccent, size: 16),
                  ),
                IconButton(
                  icon: const Icon(Icons.more_vert_rounded, color: Colors.grey, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _showSingleChapterOptions(ch),
                ),
                if (ch.isRead)
                  const Icon(Icons.check_circle_rounded, color: Colors.grey, size: 18)
                else
                  Icon(Icons.play_circle_fill_rounded, color: primaryColor, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
