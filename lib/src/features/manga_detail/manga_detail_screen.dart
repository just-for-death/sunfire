import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/db/isar_service.dart';
import '../../core/db/models/chapter.dart';
import '../../core/db/models/manga.dart';
import '../../core/engine/quickjs_service.dart';
import '../../core/logging/logger_service.dart';
import '../../core/metron/metron_service.dart';
import '../../core/services/download_manager_service.dart';
import '../../core/services/image_cache_helper.dart';
import '../../core/services/settings_service.dart';
import '../../core/sync/graphql_client_service.dart';
import '../../core/sync/sync_engine.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../core/widgets/sunfire_badge.dart';
import '../../features/reader/chapter_number_utils.dart';
import '../../main_shell.dart';
import '../browse/global_search_screen.dart';
import '../browse/migrate_search_screen.dart';
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

  /// Monotonic token for [_loadMangaDetails]: a refresh started while an older
  /// load is still in flight must not let the stale result clobber the newer one.
  int _loadGeneration = 0;

  // Chapter filter & search
  String _chapterFilter = 'All'; // 'All', 'Unread', 'Downloaded', 'Bookmarked'
  String _chapterSearch = '';
  bool _isSearchingChapters = false;

  // Multi-chapter selection state
  final Set<int> _selectedChapterIds = {};

  double _extractChapterNumber(String name, int index, int totalCount) {
    return chapterSortNumberFromParts(
      name: name,
      fallbackIndex: index,
    );
  }

  String _formatChapterSubtitle(Chapter ch) {
    final parts = <String>[];

    // 1. Reading progress or page count (only displayed for unread chapters)
    if (!ch.isRead) {
      if (ch.pageCount > 0) {
        if (ch.lastPageRead > 0) {
          final displayPage = ch.lastPageRead.clamp(1, ch.pageCount);
          parts.add('Page $displayPage/${ch.pageCount}');
        } else {
          parts.add('${ch.pageCount} pages');
        }
      } else if (ch.lastPageRead > 0) {
        parts.add('Page ${ch.lastPageRead}');
      }
    }

    // 2. Scanlator group
    if (ch.scanlator != null && ch.scanlator!.isNotEmpty) {
      parts.add(ch.scanlator!);
    }

    return parts.join(' • ');
  }

  static int? parseDateToUnix(dynamic raw) {
    if (raw == null) return null;
    if (raw is num) {
      final val = raw.toInt();
      if (val <= 0) return null;
      return val > 1000000000000 ? val ~/ 1000 : val;
    }
    final str = raw.toString().trim();
    if (str.isEmpty || str == '0' || str == 'null') return null;

    final parsedInt = int.tryParse(str);
    if (parsedInt != null) {
      if (parsedInt <= 0) return null;
      return parsedInt > 1000000000000 ? parsedInt ~/ 1000 : parsedInt;
    }

    final parsedDt = DateTime.tryParse(str);
    if (parsedDt != null) {
      return parsedDt.millisecondsSinceEpoch ~/ 1000;
    }

    final commonFormats = [
      'd MMM yyyy',
      'dd MMM yyyy',
      'd MMMM yyyy',
      'dd MMMM yyyy',
      'MMM d, yyyy',
      'MMMM d, yyyy',
      'yyyy-MM-dd',
      'dd/MM/yyyy',
      'MM/dd/yyyy',
    ];
    for (final fmt in commonFormats) {
      try {
        final dt = DateFormat(fmt, 'en_US').parseLoose(str);
        if (dt.year >= 1975) {
          return dt.millisecondsSinceEpoch ~/ 1000;
        }
      } catch (ignoredError) { if (kDebugMode) debugPrint('[manga_detail_screen] ignored error: $ignoredError'); }
    }

    return null;
  }

  String? _formatChapterDisplayDate(Chapter ch) {
    // 1. If extension site provided its authentic published date, use it directly!
    final raw = ch.dateUpload?.trim();
    if (raw != null && raw.isNotEmpty && raw != '0' && raw != 'null') {
      // If the extension returned an ISO-8601 string with timestamp (e.g. 2026-05-26T20:56:45.293Z),
      // extract the clean date component: 2026-05-26
      if (raw.contains('T') && raw.length >= 10 && RegExp(r'^\d{4}-\d{2}-\d{2}T').hasMatch(raw)) {
        return raw.split('T')[0];
      }
      // If it's pure digits (unix timestamp string in ms or s, e.g. 1778025600000), format nicely
      final numericVal = int.tryParse(raw);
      if (numericVal != null && numericVal > 0) {
        final ms = numericVal > 1000000000000 ? numericVal : numericVal * 1000;
        final dt = DateTime.fromMillisecondsSinceEpoch(ms);
        if (dt.year >= 1975) {
          return DateFormat.yMMMd().format(dt);
        }
      }
      // Return the extension site's authentic published date as-is (e.g. "May 6, 2026", "26 Aug 2026", "Nov 14, 2024", "2025-07-19")
      return raw;
    }

    // 2. Fallback to uploadDate timestamp (e.g. from Suwayomi sync)
    if (ch.uploadDate != null && ch.uploadDate! > 0) {
      final ms = ch.uploadDate! > 1000000000000 ? ch.uploadDate! : ch.uploadDate! * 1000;
      final dt = DateTime.fromMillisecondsSinceEpoch(ms);
      if (dt.year >= 1975 && !dt.isAfter(DateTime.now().add(const Duration(days: 2)))) {
        final now = DateTime.now();
        final diff = now.difference(dt);
        if (diff.inDays == 0 && !diff.isNegative) {
          return 'Today';
        } else if (diff.inDays == 1) {
          return 'Yesterday';
        }
        // Respect the user's Date Format setting (General → Date Format)
        // instead of a hardcoded locale format.
        return _settings.formatDate(dt);
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _sortAscending = _settings.chapterSortAscending;
    _loadMangaDetails();
  }

  Future<void> _loadMangaDetails() async {
    if (mounted) setState(() => _isLoading = true);
    final loadGen = ++_loadGeneration;
    final serverUrl = GraphQLClientService.instance.baseUrl ?? '';

    // 1. Check local Isar DB first to display immediate cached state only if valid
    _manga = await IsarService.instance.getMangaByServerId(widget.mangaServerId);
    if (_manga == null) {
      // The route may address a LOCAL standalone manga by its Isar auto-increment
      // id (such manga carry synthetic negative serverIds). Only accept a
      // local-id hit that is actually standalone — never one with a real
      // (positive) serverId, which would mean we collided with a different series.
      final byLocal = await IsarService.instance.getManga(widget.mangaServerId);
      if (byLocal != null && byLocal.serverId < 0) _manga = byLocal;
    }
    _chapters = await IsarService.instance.getChaptersForManga(widget.mangaServerId);
    final hasValidCachedChapters = _chapters.isNotEmpty && _chapters.every((c) => c.url.isNotEmpty);
    if (_manga != null && hasValidCachedChapters && mounted && loadGen == _loadGeneration) {
      setState(() => _isLoading = false);
    }

    final isLocalExtension = QuickJsService.instance.hasExtension(_manga?.sourceName ?? '');

    // 2. Fetch fresh details AND chapters from Suwayomi GraphQL ONLY for server manga.
    // A local standalone resolved above (serverId < 0) must never trigger a server
    // fetch keyed by its local auto-increment id.
    final resolvedAsServerManga = _manga != null
        ? (_manga!.serverId > 0 && _manga!.serverId == widget.mangaServerId)
        : widget.mangaServerId > 0;
    if (resolvedAsServerManga && !isLocalExtension && GraphQLClientService.instance.isConfigured) {
      try {
        var detailsData = await GraphQLClientService.instance.fetchMangaDetails(widget.mangaServerId);

        // If chapters are empty on server, scrape online from source directly!
        final rawChNodes = detailsData?['manga']?['chapters']?['nodes'];
        if (rawChNodes is! List) return;
        if (rawChNodes.isEmpty) {
          await GraphQLClientService.instance.fetchMangaAndChapters(widget.mangaServerId);
          detailsData = await GraphQLClientService.instance.fetchMangaDetails(widget.mangaServerId);
        }

        if (detailsData != null && detailsData.containsKey('manga') && detailsData['manga'] != null) {
          // Guard the cast: a schema change or non-object value must not crash
          // the whole detail load.
          final rawManga = detailsData['manga'];
          if (rawManga is! Map<String, dynamic> && rawManga is! Map) return;
          final mMap = rawManga is Map<String, dynamic> ? rawManga : Map<String, dynamic>.from(rawManga as Map);
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

          final sourceMap = mMap['source'] as Map<String, dynamic>?;
          if (sourceMap != null) {
            _manga!.sourceName = sourceMap['displayName'] as String? ?? sourceMap['name'] as String? ?? _manga!.sourceName;
          }

          final rawThumb = mMap['thumbnailUrl'] as String?;
          final isServerProxy = rawThumb == null || rawThumb.isEmpty || rawThumb.contains('/api/v1/manga/');
          final currentThumb = _manga!.thumbnailUrl;
          final hasDirectThumb = currentThumb != null &&
              currentThumb.isNotEmpty &&
              !currentThumb.contains('/api/v1/manga/') &&
              currentThumb.startsWith('http');

          if (!hasDirectThumb) {
            String? directThumb;
            if (_manga!.sourceName.isNotEmpty && _manga!.url.isNotEmpty) {
              directThumb = await QuickJsService.instance.getExtensionCoverUrl(_manga!.sourceName, _manga!.url);
            }
            if (directThumb != null && directThumb.isNotEmpty) {
              _manga!.thumbnailUrl = directThumb;
            } else if (!isServerProxy) {
              _manga!.thumbnailUrl = rawThumb.startsWith('http') ? rawThumb : '$serverUrl$rawThumb';
            } else if (serverUrl.isNotEmpty && _manga!.serverId > 0 && (_manga!.thumbnailUrl == null || _manga!.thumbnailUrl!.isEmpty)) {
              _manga!.thumbnailUrl = '$serverUrl/api/v1/manga/${_manga!.serverId}/thumbnail';
            }
          }

          if (mMap.containsKey('genre') && mMap['genre'] != null) {
            final rawGenre = mMap['genre'];
            _manga!.genres = rawGenre is List
                ? rawGenre.map((g) => g.toString()).toList()
                : [rawGenre.toString()];
          }

          await IsarService.instance.saveManga(_manga!);

          // Process nested chapters
          final chaptersMap = mMap['chapters'];
          if (chaptersMap is Map && chaptersMap.containsKey('nodes')) {
            final nodesRaw = chaptersMap['nodes'];
            if (nodesRaw is List && nodesRaw.isNotEmpty) {
              final existingChapters = await IsarService.instance.getChaptersForManga(widget.mangaServerId);
              final existingByServerId = <int, Chapter>{
                for (final c in existingChapters)
                  if (c.serverId > 0) c.serverId: c,
              };
              final existingByUrl = <String, Chapter>{
                for (final c in existingChapters)
                  if (c.url.isNotEmpty) c.url: c,
              };
              final existingByNum = <double, Chapter>{
                for (final c in existingChapters)
                  if (c.chapterNumber > 0) c.chapterNumber: c,
              };

              final fetched = <Chapter>[];
              for (final n in nodesRaw) {
                if (n is! Map) continue;
                final chMap = Map<String, dynamic>.from(n);
                final rawDateUpload = (chMap['dateUpload'] ?? chMap['uploadDate'])?.toString();
                final uploadTimestamp = parseDateToUnix(rawDateUpload);

                final rawChUrl = (chMap['url'] ?? chMap['realUrl'] ?? '').toString();
                final rawChRealUrl = (chMap['realUrl'] ?? chMap['url'] ?? '').toString();
                final chServerId = parseIntSafe(chMap['id']);
                final chNum = parseDoubleSafe(chMap['chapterNumber']);

                final match = existingByServerId[chServerId] ??
                    (rawChUrl.isNotEmpty ? existingByUrl[rawChUrl] : null) ??
                    (chNum > 0 ? existingByNum[chNum] : null);

                final isReadServer = parseBoolSafe(chMap['isRead']);
                final lastPageReadServer = parseIntSafe(chMap['lastPageRead']);
                final lastReadAtServer = parseIntSafe(chMap['lastReadAt']);

                final ch = Chapter()
                  ..serverId = chServerId
                  ..mangaId = widget.mangaServerId
                  ..name = chMap['name']?.toString() ?? 'Chapter ${chMap['chapterNumber'] ?? ""}'
                  ..chapterNumber = chNum
                  ..url = rawChUrl
                  ..realUrl = rawChRealUrl
                  ..pageCount = parseIntSafe(chMap['pageCount'])
                  ..scanlator = chMap['scanlator']?.toString()
                  ..mangaTitle = _manga!.title
                  ..mangaThumbnailUrl = _manga!.thumbnailUrl
                  ..uploadDate = uploadTimestamp
                  ..dateUpload = (rawDateUpload != null && rawDateUpload.isNotEmpty && rawDateUpload != '0' && rawDateUpload != 'null') ? rawDateUpload : null;

                if (match != null) {
                  ch.id = match.id;
                  ch.fetchedAt = match.fetchedAt; // PRESERVE authentic fetchedAt (never overwrite with bulk server timestamp)
                  ch.isRead = match.isRead || isReadServer;
                  ch.lastPageRead = math.max(match.lastPageRead, lastPageReadServer);
                  ch.lastReadAt = (lastReadAtServer > 0)
                      ? lastReadAtServer
                      : match.lastReadAt;
                  ch.isDownloadedLocally = match.isDownloadedLocally;
                  ch.localPath = match.localPath;
                  ch.isBookmarked = match.isBookmarked;
                  if (ch.url.isEmpty && match.url.isNotEmpty) ch.url = match.url;
                  if (ch.realUrl.isEmpty && match.realUrl.isNotEmpty) ch.realUrl = match.realUrl;
                } else {
                  ch.isRead = isReadServer;
                  ch.lastPageRead = lastPageReadServer;
                  ch.lastReadAt = lastReadAtServer;
                  // Genuinely NEW chapter added to an existing library manga
                  if (existingChapters.isNotEmpty && _manga != null && _manga!.inLibrary) {
                    ch.fetchedAt = DateTime.now().millisecondsSinceEpoch ~/ 1000;
                  } else {
                    ch.fetchedAt = 0;
                  }
                }
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

    // 3. Offline / Local Scraper: Scrape chapters directly via QuickJS if:
    //    - Source is a local JS extension, OR
    //    - Chapters list is empty or has blank names/URLs
    final chaptersNeedEnrichment = _chapters.isEmpty ||
        _chapters.every((c) => c.name.trim().isEmpty || c.url.trim().isEmpty);
    if ((isLocalExtension || chaptersNeedEnrichment) && _manga != null && _manga!.sourceName.isNotEmpty) {
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
          if (localData['imageUrl'] != null && localData['imageUrl'].toString().isNotEmpty) {
            final directImg = localData['imageUrl'].toString();
            if (_manga!.thumbnailUrl == null || _manga!.thumbnailUrl!.isEmpty || _manga!.thumbnailUrl!.contains('/api/v1/manga/')) {
              _manga!.thumbnailUrl = directImg;
            }
          }
          await IsarService.instance.saveManga(_manga!);

          final rawChList = (localData['chapters'] ?? localData['chapterList'] ?? localData['epList'] ?? localData['episodes']);
          if (rawChList is List && rawChList.isNotEmpty) {
            final chList = rawChList;
            final fetched = <Chapter>[];
            for (var i = 0; i < chList.length; i++) {
              final rawCMap = chList[i];
              if (rawCMap is! Map) continue;
              final cMap = Map<String, dynamic>.from(rawCMap);
              final chUrl = (cMap['url'] ?? cMap['link'] ?? '').toString();
              final chName = cMap['name']?.toString() ?? 'Chapter ${i + 1}';
              final rawChNum = (cMap['chapterNumber'] as num?)?.toDouble();
              final chNum = (rawChNum != null && rawChNum > 0) ? rawChNum : _extractChapterNumber(chName, i, chList.length);

              // Negative synthetic id — positive ids would share the unique
              // serverId index with real Suwayomi chapters (overwrite/alias).
              final chServerId = -((widget.mangaServerId.abs() * 100000) + i + 1);

              final rawDate = cMap['dateUpload'] ?? cMap['uploadDate'] ?? cMap['date'] ?? cMap['releaseDate'];
              final rawDateStr = rawDate?.toString().trim();
              final parsedDate = parseDateToUnix(rawDate);

              final ch = Chapter()
                ..serverId = chServerId
                ..mangaId = widget.mangaServerId
                ..name = chName
                ..chapterNumber = chNum
                ..url = chUrl
                ..realUrl = chUrl
                ..mangaTitle = _manga!.title
                ..mangaThumbnailUrl = _manga!.thumbnailUrl
                ..uploadDate = parsedDate
                ..dateUpload = (rawDateStr != null && rawDateStr.isNotEmpty && rawDateStr != '0' && rawDateStr != 'null') ? rawDateStr : null
                ..fetchedAt = 0;
              fetched.add(ch);
            }
            final existingChapters = await IsarService.instance.getChaptersForManga(widget.mangaServerId);
            final existingServerIds = existingChapters.map((c) => c.serverId).toSet();

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
                  ch.id = match.id; // PRESERVE existing Isar ID for in-place update
                  ch.serverId = match.serverId; // Preserve canonical server ID
                  ch.fetchedAt = match.fetchedAt; // PRESERVE authentic fetchedAt (never overwrite with now!)
                  ch.isRead = match.isRead;
                  ch.lastPageRead = match.lastPageRead;
                  ch.lastReadAt = match.lastReadAt;
                  ch.isDownloadedLocally = match.isDownloadedLocally;
                  ch.localPath = match.localPath;
                  ch.isBookmarked = match.isBookmarked;
                  ch.pageCount = match.pageCount;
                  if ((ch.dateUpload == null || ch.dateUpload!.isEmpty) && match.dateUpload != null && match.dateUpload!.isNotEmpty) {
                    ch.dateUpload = match.dateUpload;
                  }
                  if (ch.uploadDate == null && match.uploadDate != null) {
                    ch.uploadDate = match.uploadDate;
                  }
                  if (ch.url.isEmpty && match.url.isNotEmpty) ch.url = match.url;
                  if (ch.realUrl.isEmpty && match.realUrl.isNotEmpty) ch.realUrl = match.realUrl;
                } else {
                  // Ensure newly minted chapter serverId does not collide with existing ones
                  while (existingServerIds.contains(ch.serverId)) {
                    ch.serverId++;
                  }
                  existingServerIds.add(ch.serverId);
                  // Genuinely NEW chapter added to an existing library manga (manga already had chapters)
                  if (existingChapters.isNotEmpty && _manga != null && _manga!.inLibrary) {
                    ch.fetchedAt = DateTime.now().millisecondsSinceEpoch ~/ 1000;
                  } else {
                    ch.fetchedAt = 0;
                  }
                }
              }
            }
            await IsarService.instance.saveChapters(fetched);
            _chapters = fetched;
            if (_manga != null) {
              await IsarService.instance.saveManga(_manga!);
            }
          }
        }
      } catch (ignoredError) { if (kDebugMode) debugPrint('[manga_detail_screen] ignored error: $ignoredError'); }
    }

    _manga ??= Manga()
      ..serverId = widget.mangaServerId
      ..title = 'Manga #${widget.mangaServerId}'
      ..inLibrary = false;

    if (_manga != null) {
      await IsarService.instance.saveManga(_manga!);
    }

    // A newer load was started while this one was in flight — its results are
    // fresher; don't let this stale pass overwrite chapters/state.
    if (loadGen != _loadGeneration) return;

    if (_chapters.isEmpty) {
      _chapters = await IsarService.instance.getChaptersForManga(widget.mangaServerId);
    }

    // Merge and deduplicate chapters cleanly
    _chapters = _mergeAndDeduplicateChapters(_chapters);

    if (mounted && loadGen == _loadGeneration) {
      setState(() => _isLoading = false);
    }
  }

  List<Chapter> _mergeAndDeduplicateChapters(List<Chapter> list) {
    final map = <String, Chapter>{};
    final mangaTitleLower = _manga?.title.trim().toLowerCase() ?? '';

    for (final ch in list) {
      var cleanName = ch.name.trim();

      // Strip redundant leading manga title prefix if present in chapter title
      if (mangaTitleLower.isNotEmpty && cleanName.toLowerCase().startsWith(mangaTitleLower)) {
        final stripped = cleanName.substring(mangaTitleLower.length).replaceAll(RegExp(r'^[\s\-–—:]+'), '').trim();
        if (stripped.isNotEmpty) cleanName = stripped;
      }

      // Strip redundant trailing (ch. 1115) or (Ch. 1115) suffix
      cleanName = cleanName.replaceAll(RegExp(r'\s*\([Cc]h\.?\s*\d+\)$'), '').trim();
      if (cleanName.isEmpty) cleanName = ch.name.trim();
      ch.name = cleanName;

      final extractedNum = _extractChapterNumber(cleanName, 0, list.length);
      if (extractedNum >= 0) {
        ch.chapterNumber = extractedNum;
      }

      final scanlatorPart = (ch.scanlator != null && ch.scanlator!.trim().isNotEmpty)
          ? ch.scanlator!.trim().toLowerCase()
          : '';
      final numKey = ch.chapterNumber >= 0
          ? 'num_${ch.chapterNumber.toStringAsFixed(2)}${scanlatorPart.isNotEmpty ? '_$scanlatorPart' : ''}'
          : null;
      final urlKey = ch.url.isNotEmpty ? 'url_${ch.url.toLowerCase().trim()}' : null;
      final nameKey = 'name_${cleanName.toLowerCase()}${scanlatorPart.isNotEmpty ? '_$scanlatorPart' : ''}';

      // Dedup key priority: URL first (a URL identifies a distinct chapter
      // release; a number can be shared by "Prologue" / "Chapter 0" or by
      // re-releases, which would wrongly collapse them together).
      final key = urlKey ?? numKey ?? nameKey;

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
        // Copy download state per-flag: the combined `isDownloaded` setter would
        // mark a server-only download as a local one (and vice-versa), so
        // preserve the local/server distinction across the merge.
        if (!existing.isDownloadedLocally && ch.isDownloadedLocally) existing.isDownloadedLocally = true;
        if (!existing.isDownloadedOnServer && ch.isDownloadedOnServer) existing.isDownloadedOnServer = true;
        if (existing.pageCount == 0 && ch.pageCount > 0) existing.pageCount = ch.pageCount;
      }
    }

    return map.values.toList();
  }

  void _toggleInLibrary() async {
    if (_manga == null) return;
    final newState = !_manga!.inLibrary;
    setState(() {
      _manga!.inLibrary = newState;
      if (newState) {
        // Server stores inLibraryAt as epoch SECONDS (Instant.now().epochSecond);
        // keep local writes in the same unit so library sort/sync stay consistent.
        _manga!.inLibraryAt = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        if (SettingsService.instance.defaultCategoryId != null) {
          final defId = SettingsService.instance.defaultCategoryId!;
          if (!_manga!.categoryIds.contains(defId)) {
            _manga!.categoryIds = [..._manga!.categoryIds, defId];
          }
        }
      } else {
        _manga!.inLibraryAt = null;
      }
    });
    await IsarService.instance.saveManga(_manga!);

    try {
      await SyncEngine.instance.syncMangaLibraryState(widget.mangaServerId, newState);

      // If newly added to library and a default category is set, assign it on server!
      if (newState && SettingsService.instance.defaultCategoryId != null && widget.mangaServerId > 0) {
        await SyncEngine.instance.syncMangaCategories(
          widget.mangaServerId,
          _manga!.categoryIds,
        );
      }
    } catch (ignoredError) { if (kDebugMode) debugPrint('[manga_detail_screen] ignored error: $ignoredError'); }

    if (mounted) {
      final defCatName = SettingsService.instance.defaultCategoryId != null
          ? SettingsService.instance.defaultCategoryName
          : null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newState
                ? defCatName != null
                    ? 'Added to library ($defCatName)'
                    : 'Added to library'
                : 'Removed from library',
          ),
        ),
      );
    }
  }

  Future<void> _showCategoryPickerDialog() async {
    if (_manga == null) return;
    final categories = await IsarService.instance.getCategories();
    if (!mounted) return;
    if (categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No categories created yet. Create one in Settings > Library.')),
      );
      return;
    }

    final selectedCatIds = Set<int>.from(_manga!.categoryIds);
    // Snapshot the pre-edit category set so the server sync can be sent as an
    // add/remove diff instead of a full replace — a replace would wipe server
    // categories this client doesn't currently know about.
    final previousCatIds = List<int>.from(_manga!.categoryIds);
    await showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F1F24),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Edit Categories', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(sheetContext),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(_manga!.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 280),
                    child: ListView(
                      shrinkWrap: true,
                      children: categories.map((cat) {
                        final isChecked = selectedCatIds.contains(cat.serverId);
                        return CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          value: isChecked,
                          activeColor: Theme.of(context).colorScheme.primary,
                          onChanged: (val) {
                            setSheetState(() {
                              if (val == true) {
                                selectedCatIds.add(cat.serverId);
                              } else {
                                selectedCatIds.remove(cat.serverId);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () async {
                      final catList = selectedCatIds.toList();
                      setState(() {
                        _manga!.categoryIds = catList;
                      });
                      await IsarService.instance.saveManga(_manga!);
                      if (widget.mangaServerId > 0) {
                        await SyncEngine.instance.syncMangaCategories(
                          widget.mangaServerId,
                          catList,
                          existingCategoryIds: previousCatIds,
                        );
                      }
                      if (sheetContext.mounted) {
                        Navigator.pop(sheetContext);
                      }
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Categories updated')),
                        );
                      }
                    },
                    child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _loadLocalDataOnly() async {
    // Same two-step resolution as the main loader. This used to assign the
    // getMangaByServerId result unconditionally, and standalone series are
    // routed by their LOCAL Isar id — which getMangaByServerId never matches,
    // because it filters the unique serverId index and refuses to fall back by
    // design. So `_manga` became null for every standalone/Local-JS series, and
    // `build()` force-unwraps it (`final manga = _manga!;`) — a hard crash on
    // the primary flow: open a local series, read a chapter, press back.
    //
    // Never overwrite a good `_manga` with null.
    final byServerId = await IsarService.instance.getMangaByServerId(widget.mangaServerId);
    if (byServerId != null) {
      _manga = byServerId;
    } else if (_manga == null) {
      final byLocal = await IsarService.instance.getManga(widget.mangaServerId);
      if (byLocal != null && byLocal.serverId < 0) _manga = byLocal;
    }
    final chapters = await IsarService.instance.getChaptersForManga(widget.mangaServerId);
    if (chapters.isNotEmpty || _chapters.isEmpty) _chapters = chapters;
    if (mounted) {
      setState(() {});
    }
  }

  // Never pass a raw auto-increment id as a chapter target: local chapters
  // carry synthetic negative serverIds and resolve through them.
  int _targetChapterId(Chapter ch) => ch.serverId != 0 ? ch.serverId : ch.id;

  /// Resolves the manga id used for local-download tasks. For server manga this
  /// is the real positive serverId; for standalone titles it must be the local
  /// Isar id used across the library/download pipeline. Guard against a
  /// zero/unset id (fresh Manga object not yet saved) and fall back to the
  /// route id, which the rest of this screen treats as authoritative.
  int _targetMangaId() {
    if (_manga != null && _manga!.serverId > 0) return _manga!.serverId;
    final localId = _manga?.id ?? 0;
    return localId > 0 ? localId : widget.mangaServerId;
  }

  void _openReader(int chapterServerId) async {
    await context.push('/reader/$chapterServerId');
    if (mounted) {
      _loadLocalDataOnly();
    }
  }

  void _continueReading() {
    if (_chapters.isEmpty) return;
    final target = pickContinueReadingChapter(_chapters);
    if (target != null) _openReader(_targetChapterId(target));
  }

  Future<void> _openMigrate(Manga manga) async {
    final installed = QuickJsService.instance.getInstalledExtensionNames();
    final sources = installed
        .map((name) => {
              'id': 'local_js_${name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_').toLowerCase()}',
              'name': name,
              'displayName': name,
              'isLocalJs': true,
            })
        .toList();
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MigrateSearchScreen(manga: manga, sources: sources),
      ),
    );
    if (mounted) _loadLocalDataOnly();
  }

  void _onGenreTap(String genre) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GlobalSearchScreen(initialQuery: genre),
      ),
    );
  }

  Widget _chapterEmptyState() {
    final hasFilter = _chapterFilter != 'All' || _chapterSearch.trim().isNotEmpty;
    return EmptyStateWidget(
      icon: hasFilter ? Icons.filter_alt_off_rounded : Icons.menu_book_outlined,
      title: hasFilter ? 'No Matching Chapters' : 'No Chapters Found',
      subtitle: hasFilter
          ? 'Clear the chapter filter or search to see all chapters.'
          : 'Pull to refresh or check the source connection.',
      actionLabel: hasFilter ? 'Clear Filter' : null,
      onAction: hasFilter
          ? () => setState(() {
                _chapterFilter = 'All';
                _chapterSearch = '';
                _isSearchingChapters = false;
              })
          : null,
    );
  }

  Future<void> _refreshUnreadCount() async {
    if (_manga == null) return;
    // This screen always reads AND writes chapters with
    // `mangaId = widget.mangaServerId` (the route id), no matter whether it is
    // a real Suwayomi id or a synthetic/local id for standalone manga. The old
    // code queried `_manga!.serverId`/`_manga!.id` instead, which for a
    // standalone title opened via the library is a DIFFERENT id space, the
    // query matched nothing, and unreadCount was silently saved as 0 on every
    // read/unread action — wiping the library unread badge. Query the route id
    // first (authoritative for this screen), then fall back to the other id
    // spaces in case legacy rows were minted under them.
    var chs = await IsarService.instance.getChaptersForManga(widget.mangaServerId);
    if (chs.isEmpty) {
      final serverId = _manga!.serverId;
      if (serverId != widget.mangaServerId) {
        chs = await IsarService.instance.getChaptersForManga(serverId);
      }
      if (chs.isEmpty && _manga!.id != widget.mangaServerId && _manga!.id != serverId) {
        chs = await IsarService.instance.getChaptersForManga(_manga!.id);
      }
    }
    final unread = chs.where((c) => !c.isRead).length;
    _manga!.unreadCount = unread;
    await IsarService.instance.saveManga(_manga!);
  }

  void _toggleChapterRead(Chapter ch) async {
    final newState = !ch.isRead;
    // Centralised so the Incognito guard matches the reader's. Previously this
    // path persisted to Isar and pushed to the server with Incognito on.
    final wrote = await SyncEngine.instance.commitChapterReadState(ch, isRead: newState);
    if (!wrote) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incognito Mode is on — reading state is not saved')),
        );
      }
      return;
    }
    if (mounted) setState(() {});
    await _refreshUnreadCount();

    if (newState && _settings.deleteChapterAfterMarkedRead && ch.isDownloaded) {
      if (!ch.isBookmarked || _settings.allowDeletingBookmarkedChapters) {
        DownloadManagerService.instance.deleteLocalDownload(_targetChapterId(ch));
      }
    }

    if (newState && _manga != null && _manga!.metronSeriesId != null && _settings.metronAutoScrobble) {
      MetronService.instance.scrobbleMangaChapter(manga: _manga!, chapter: ch).catchError((e, st) {
        LoggerService.instance.logError('Metron scrobble failed', exception: e, stackTrace: st, category: 'Metron');
        return false;
      });
    }
  }

  void _toggleChapterBookmark(Chapter ch) async {
    final newState = !ch.isBookmarked;
    setState(() => ch.isBookmarked = newState);
    await IsarService.instance.saveChapter(ch);

    if (ch.serverId > 0) {
      SyncEngine.instance.syncChapterBookmark(ch.serverId, newState);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(newState ? 'Bookmark added' : 'Bookmark removed')),
      );
    }
  }

  void _markPreviousChaptersRead(Chapter ch) async {
    // Centralised Incognito guard (see commitChapterReadState).
    if (SettingsService.instance.incognitoMode) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incognito Mode is on — reading state is not saved')),
        );
      }
      return;
    }
    final prevs = _chapters.where((c) => c.chapterNumber < ch.chapterNumber && !c.isRead).toList();
    for (final p in prevs) {
      p.applyReadState(true);
      if (_settings.deleteChapterAfterMarkedRead && p.isDownloaded) {
        if (!p.isBookmarked || _settings.allowDeletingBookmarkedChapters) {
          DownloadManagerService.instance.deleteLocalDownload(_targetChapterId(p));
        }
      }
      await SyncEngine.instance.stampLocalReadActivity(p);
      if (p.serverId > 0) {
        SyncEngine.instance.syncChapterProgress(p.serverId, isRead: true, lastPageRead: p.lastPageRead);
      }
      if (_manga != null && _manga!.metronSeriesId != null && _settings.metronAutoScrobble) {
        MetronService.instance.scrobbleMangaChapter(manga: _manga!, chapter: p).catchError((e, st) {
          LoggerService.instance.logError('Metron scrobble failed', exception: e, stackTrace: st, category: 'Metron');
          return false;
        });
      }
    }
    await IsarService.instance.saveChapters(prevs);
    await _refreshUnreadCount();
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
      _selectedChapterIds.add(_targetChapterId(ch));
    });
  }

  void _selectAllChapters() {
    final visible = _visibleChapters();
    setState(() {
      final visibleIds = visible.map(_targetChapterId).toSet();
      final allVisibleSelected =
          visibleIds.isNotEmpty && visibleIds.every(_selectedChapterIds.contains);
      if (allVisibleSelected) {
        _selectedChapterIds.removeAll(visibleIds);
      } else {
        _selectedChapterIds.addAll(visibleIds);
      }
    });
  }

  List<Chapter> _visibleChapters() {
    var sortedChapters = List<Chapter>.from(_chapters);
    if (_chapterFilter == 'Unread') {
      sortedChapters = sortedChapters.where((c) => !c.isRead).toList();
    } else if (_chapterFilter == 'Downloaded') {
      sortedChapters = sortedChapters.where((c) =>
        DownloadManagerService.instance.isChapterDownloadedLocally(_targetChapterId(c)) ||
        (c.serverId > 0 && DownloadManagerService.instance.isChapterDownloadedOnServer(c.serverId)) ||
        c.isDownloaded
      ).toList();
    } else if (_chapterFilter == 'Bookmarked') {
      sortedChapters = sortedChapters.where((c) => c.isBookmarked).toList();
    }
    if (_chapterSearch.trim().isNotEmpty) {
      final q = _chapterSearch.trim().toLowerCase();
      sortedChapters = sortedChapters.where((c) =>
        c.name.toLowerCase().contains(q) ||
        c.chapterNumber.toString().contains(q)
      ).toList();
    }
    return sortedChapters;
  }

  void _markSelectedRead(bool read) async {
    final targets = _chapters.where((c) => _selectedChapterIds.contains(_targetChapterId(c))).toList();
    // Centralised Incognito guard (see commitChapterReadState).
    if (SettingsService.instance.incognitoMode) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incognito Mode is on — reading state is not saved')),
        );
      }
      return;
    }
    for (final c in targets) {
      c.applyReadState(read);
      if (read && _settings.deleteChapterAfterMarkedRead && c.isDownloaded) {
        if (!c.isBookmarked || _settings.allowDeletingBookmarkedChapters) {
          DownloadManagerService.instance.deleteLocalDownload(_targetChapterId(c));
        }
      }
      if (read) await SyncEngine.instance.stampLocalReadActivity(c);
      if (c.serverId > 0) {
        unawaited(
          SyncEngine.instance.syncChapterProgress(
            c.serverId,
            isRead: read,
            lastPageRead: c.lastPageRead,
          ),
        );
      }
      if (read && _manga != null && _manga!.metronSeriesId != null && _settings.metronAutoScrobble) {
        MetronService.instance.scrobbleMangaChapter(manga: _manga!, chapter: c).catchError((e, st) {
          LoggerService.instance.logError('Metron scrobble failed', exception: e, stackTrace: st, category: 'Metron');
          return false;
        });
      }
    }
    await IsarService.instance.saveChapters(targets);
    await _refreshUnreadCount();
    if (mounted) {
      setState(() => _selectedChapterIds.clear());
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Marked ${targets.length} chapters as ${read ? "read" : "unread"}')),
      );
    }
  }

  void _downloadSelected(bool local) async {
    // Download in reading order: chapter 1 before chapter 2, etc. Source
    // chapter lists are usually newest-first, so without this sort a batch
    // would start from the latest chapter and work backwards.
    final targets = _chapters
        .where((c) => _selectedChapterIds.contains(_targetChapterId(c)))
        .toList()
      ..sort((a, b) => a.chapterNumber.compareTo(b.chapterNumber));
    if (local) {
      for (final c in targets) {
        await DownloadManagerService.instance.enqueueLocalDownload(
          chapterId: _targetChapterId(c),
          mangaId: _targetMangaId(),
          chapterName: c.name,
          mangaTitle: _manga?.title ?? 'Manga',
          chapterNumber: c.chapterNumber,
        );
      }
    } else {
      final ids = targets.where((c) => c.serverId > 0).map((c) => c.serverId).toList();
      if (ids.isNotEmpty) {
        await DownloadManagerService.instance.enqueueServerDownloads(ids);
      }
    }
    if (mounted) {
      setState(() => _selectedChapterIds.clear());
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enqueued ${targets.length} chapters for ${local ? "device" : "server"} download')),
      );
    }
  }

  void _deleteSelectedDownloads() async {
    final targets = _chapters.where((c) => _selectedChapterIds.contains(_targetChapterId(c))).toList();
    for (final c in targets) {
      await DownloadManagerService.instance.deleteLocalDownload(_targetChapterId(c));
      if (c.serverId > 0) {
        await DownloadManagerService.instance.deleteServerDownload(c.serverId);
      }
    }
    if (mounted) {
      setState(() => _selectedChapterIds.clear());
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted downloads for ${targets.length} chapters')),
      );
    }
  }

  void _showBatchDownloadModal() {
    final primaryColor = Theme.of(context).colorScheme.primary;
    // Sort unread chapters in ascending reading order so "Next chapter(s)" downloads the chronological next to read
    final unreadChapters = _chapters.where((c) => !c.isRead).toList()
      ..sort((a, b) => a.chapterNumber.compareTo(b.chapterNumber));
    // "All chapters" must also start from chapter 1 (source lists are newest-first).
    final allChapters = List<Chapter>.from(_chapters)
      ..sort((a, b) => a.chapterNumber.compareTo(b.chapterNumber));
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
                      if (GraphQLClientService.instance.isConfigured)
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
                  _buildDownloadOptionTile('All chapters (${allChapters.length})', allChapters.length, allChapters, primaryColor, downloadToLocal),
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
              chapterId: _targetChapterId(c),
              mangaId: _targetMangaId(),
              chapterName: c.name,
              mangaTitle: _manga?.title ?? 'Manga',
              chapterNumber: c.chapterNumber,
            );
          }
        } else {
          final ids = targets.where((c) => c.serverId > 0).map((c) => c.serverId).toList();
          if (ids.isNotEmpty) {
            await DownloadManagerService.instance.enqueueServerDownloads(ids);
          }
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Enqueued $count chapters for ${downloadToLocal ? "device" : "server"} download')),
          );
        }
      },
    );
  }

  String? _resolveFullUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.trim().isEmpty) return null;
    final trimmed = rawUrl.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    final sourceName = _manga?.sourceName ?? '';
    final baseUrl = QuickJsService.instance.getSourceBaseUrl(sourceName);
    if (baseUrl != null && baseUrl.isNotEmpty) {
      final cleanBase = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
      final cleanPath = trimmed.startsWith('/') ? trimmed : '/$trimmed';
      return '$cleanBase$cleanPath';
    }
    if (trimmed.contains('.') && !trimmed.contains(' ')) {
      return 'https://$trimmed';
    }
    return null;
  }

  Future<void> _openInBrowser(String rawUrl) async {
    final fullUrl = _resolveFullUrl(rawUrl);
    if (fullUrl == null || fullUrl.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No web link available for this item')),
        );
      }
      return;
    }
    final uri = Uri.tryParse(fullUrl);
    if (uri != null) {
      try {
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!launched && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open $fullUrl')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open $fullUrl: $e')),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $fullUrl')),
        );
      }
    }
  }

  void _showSingleChapterOptions(Chapter ch) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final messenger = ScaffoldMessenger.of(context);
    final targetChId = _targetChapterId(ch);
    final isDownloadedLocally = DownloadManagerService.instance.isChapterDownloadedLocally(targetChId);
    final isDownloadedOnServer = (ch.serverId > 0 && DownloadManagerService.instance.isChapterDownloadedOnServer(ch.serverId)) || ch.isDownloaded;

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
              ListTile(
                leading: const Icon(Icons.open_in_browser_rounded, color: Colors.blueAccent),
                title: const Text('Open Chapter in Browser', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  ch.url.isNotEmpty ? ch.url : (_manga?.url.isNotEmpty == true ? _manga!.url : 'View web page'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  final target = ch.url.isNotEmpty ? ch.url : (_manga?.url ?? '');
                  _openInBrowser(target);
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
                      chapterId: targetChId,
                      mangaId: _targetMangaId(),
                      chapterName: ch.name,
                      mangaTitle: _manga?.title ?? 'Manga',
                      chapterNumber: ch.chapterNumber,
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
                    await DownloadManagerService.instance.deleteLocalDownload(targetChId);
                    messenger.showSnackBar(
                      SnackBar(content: Text('Deleted ${ch.name} from local storage')),
                    );
                  },
                ),

              // Server Download option: Only show if chapter is associated with remote server
              if (ch.serverId > 0) ...[
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

    final manga = _manga;
    if (manga == null) {
      // Defensive. The loader resolves a standalone series through its local
      // Isar id, and any future path that leaves `_manga` null would otherwise
      // crash here rather than degrade. An unresolvable series is a real state
      // (deleted locally, or routed with a stale id), not a programming error.
      return Scaffold(
        appBar: AppBar(title: const Text('Not found')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.withValues(alpha: 0.6)),
                const SizedBox(height: 12),
                const Text(
                  'This series is no longer in your library.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 6),
                const Text(
                  'It may have been removed on another device, or its local entry was deleted.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => context.canPop() ? context.pop() : context.go('/library'),
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text('Back to library'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    var sortedChapters = _visibleChapters();

    if (_sortAscending) {
      sortedChapters.sort((a, b) {
        final cmp = a.chapterNumber.compareTo(b.chapterNumber);
        return cmp != 0 ? cmp : a.id.compareTo(b.id);
      });
    } else {
      sortedChapters.sort((a, b) {
        final cmp = b.chapterNumber.compareTo(a.chapterNumber);
        return cmp != 0 ? cmp : b.id.compareTo(a.id);
      });
    }

    final isSelecting = _selectedChapterIds.isNotEmpty;

    return PopScope(
      canPop: !isSelecting && !_isSearchingChapters,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (isSelecting) {
          setState(() => _selectedChapterIds.clear());
        } else if (_isSearchingChapters) {
          setState(() {
            _isSearchingChapters = false;
            _chapterSearch = '';
          });
        }
      },
      child: Scaffold(
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
          if (constraints.maxWidth >= sunfireDetailTwoPaneMinWidth) {
            return _buildTabletLayout(context, manga, sortedChapters, primaryColor, isSelecting);
          }
          return _buildPhoneLayout(context, manga, sortedChapters, primaryColor, isSelecting);
        },
      ),
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
    return SafeArea(
      bottom: false,
      child: Row(
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
                      tooltip: manga.inLibrary ? 'In Library (Tap to remove)' : 'Add to Library',
                      onPressed: _toggleInLibrary,
                    ),
                    if (manga.inLibrary)
                      IconButton(
                        icon: const Icon(Icons.label_outline_rounded),
                        tooltip: 'Edit Categories',
                        onPressed: _showCategoryPickerDialog,
                      ),
                    IconButton(
                      icon: const Icon(Icons.download_rounded),
                      tooltip: 'Download Chapters',
                      onPressed: _showBatchDownloadModal,
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded),
                      tooltip: 'Refresh',
                      onPressed: _loadMangaDetails,
                    ),
                    IconButton(
                      icon: const Icon(Icons.public_rounded),
                      tooltip: 'Open in Browser',
                      onPressed: () => _openInBrowser(manga.url),
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
                    SunfireBadge(
                      label: (manga.status ?? 'Ongoing').toUpperCase(),
                      color: Colors.greenAccent,
                    ),
                    const SizedBox(width: 8),
                    SunfireBadge(
                      label: '${sortedChapters.length} CHAPTERS',
                      color: Colors.grey,
                      textColor: Colors.white70,
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
                        onLongPress: manga.inLibrary ? _showCategoryPickerDialog : null,
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
                Builder(
                  builder: (context) {
                    final hasReadAny = _chapters.any((c) => c.isRead || c.lastPageRead > 0);
                    return ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0x33FFFFFF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: _continueReading,
                      icon: Icon(Icons.play_arrow_rounded, color: primaryColor, size: 22),
                      label: Text(
                        hasReadAny ? 'Continue Reading' : 'Start Reading',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                if (manga.genres.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: manga.genres.map((g) {
                      return SunfireBadge(
                        label: g,
                        variant: SunfireBadgeVariant.chip,
                        onTap: () => _onGenreTap(g),
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
              if (_isSearchingChapters) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
                  child: TextField(
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
                ),
              ],
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
                child: SingleChildScrollView(
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
              ),
              const Divider(height: 1, color: Color(0x1AFFFFFF)),
              Expanded(
                child: sortedChapters.isEmpty
                    ? _chapterEmptyState()
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                        itemCount: sortedChapters.length,
                        itemBuilder: (context, index) {
                          final ch = sortedChapters[index];
                          final isSelected = _selectedChapterIds.contains(_targetChapterId(ch));
                          return _buildChapterListTile(ch, isSelected, isSelecting, primaryColor);
                        },
                      ),
              ),
            ],
          ),
        ),
      ],
      ),
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
            expandedHeight: 320,
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
                tooltip: manga.inLibrary ? 'In Library (Tap to remove)' : 'Add to Library',
                onPressed: _toggleInLibrary,
              ),
              IconButton(
                icon: const Icon(Icons.download_rounded, color: Colors.white),
                tooltip: 'Download Chapters',
                onPressed: _showBatchDownloadModal,
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
                color: const Color(0xFF1F1F26),
                onSelected: (value) async {
                  switch (value) {
                    case 'categories':
                      await _showCategoryPickerDialog();
                      break;
                    case 'refresh':
                      await _loadMangaDetails();
                      break;
                    case 'browser':
                      await _openInBrowser(manga.url);
                      break;
                    case 'migrate':
                      await _openMigrate(manga);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  if (manga.inLibrary)
                    const PopupMenuItem(value: 'categories', child: Text('Edit Categories')),
                  const PopupMenuItem(value: 'refresh', child: Text('Refresh')),
                  const PopupMenuItem(value: 'browser', child: Text('Open in Browser')),
                  const PopupMenuItem(value: 'migrate', child: Text('Migrate Source')),
                ],
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
                                  SunfireBadge(
                                    label: manga.sourceName,
                                    color: primaryColor,
                                  ),
                                  SunfireBadge(
                                    label: (manga.status ?? 'Ongoing').toUpperCase(),
                                    color: Colors.greenAccent,
                                  ),
                                  SunfireBadge(
                                    label: '${sortedChapters.length} CH',
                                    color: Colors.grey,
                                    textColor: Colors.white70,
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
                        onLongPress: manga.inLibrary ? _showCategoryPickerDialog : null,
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
                      return SunfireBadge(
                        label: g,
                        variant: SunfireBadgeVariant.chip,
                        onTap: () => _onGenreTap(g),
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
          SliverFillRemaining(
            hasScrollBody: false,
            child: _chapterEmptyState(),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 120.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final ch = sortedChapters[index];
                  final isSelected = _selectedChapterIds.contains(_targetChapterId(ch));
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
    final targetChId = _targetChapterId(ch);
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
                    _selectedChapterIds.remove(targetChId);
                  } else {
                    _selectedChapterIds.add(targetChId);
                  }
                });
              } else {
                _openReader(targetChId);
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
                          _selectedChapterIds.add(targetChId);
                        } else {
                          _selectedChapterIds.remove(targetChId);
                        }
                      });
                    },
                  )
                : ch.isBookmarked
                    ? const Icon(Icons.bookmark_rounded, color: Colors.amber, size: 18)
                    : null,
            title: Text(
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
            subtitle: Builder(
              builder: (context) {
                final dateStr = _formatChapterDisplayDate(ch);
                final sub = _formatChapterSubtitle(ch);
                final metaText = [
                  if (sub.isNotEmpty) sub,
                  if (dateStr != null) dateStr,
                ].join(' • ');

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (metaText.isNotEmpty)
                      Text(
                        metaText,
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
                );
              },
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (DownloadManagerService.instance.isChapterDownloadedLocally(targetChId))
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
                      DownloadManagerService.instance.enqueueLocalDownload(
                        chapterId: targetChId,
                        mangaId: _targetMangaId(),
                        chapterName: ch.name,
                        mangaTitle: _manga?.title ?? 'Manga',
                        chapterNumber: ch.chapterNumber,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Queued ${ch.name} for local download')));
                      setState(() {});
                    },
                  ),
                if ((ch.serverId > 0 && DownloadManagerService.instance.isChapterDownloadedOnServer(ch.serverId)) || ch.isDownloaded)
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
