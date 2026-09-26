import 'dart:async';
import 'package:flutter/material.dart';

import '../../core/db/isar_service.dart';
import '../../core/db/models/chapter.dart';
import '../../core/db/models/manga.dart';
import '../../core/engine/content_resolver_service.dart';
import '../../core/engine/quickjs_service.dart';
import '../../core/engine/source_migration_service.dart';
import '../../core/logging/logger_service.dart';
import '../../core/services/image_cache_helper.dart';
import '../../core/services/settings_service.dart';
import '../../core/sync/graphql_client_service.dart';
import '../../core/sync/sync_engine.dart';

/// Coerce a source map's display/name field to a non-null String. Extension
/// lists come from mixed origins (GraphQL nodes, repo JSON, GQL metadata) and
/// a missing or non-String value must never throw a cast error mid-migration.
String _sourceDisplayNameOf(Map<String, dynamic> source) {
  final display = source['displayName'];
  if (display is String && display.trim().isNotEmpty) return display;
  final name = source['name'];
  if (name is String && name.trim().isNotEmpty) return name;
  return (source['id']?.toString() ?? '').isNotEmpty ? source['id'].toString() : 'Source';
}

/// Coerce a target manga's genre field to a list of strings. Extensions and
/// the GraphQL server disagree on shape (List vs comma-joined String vs
/// Map), so accept all of them without throwing.
List<String> _coerceGenres(dynamic genre) {
  if (genre == null) return const <String>[];
  if (genre is List) {
    return genre.where((e) => e != null).map((e) => e.toString()).toList();
  }
  if (genre is Map) {
    return genre.values.where((e) => e != null).map((e) => e.toString()).toList();
  }
  final str = genre.toString().trim();
  if (str.isEmpty) return const <String>[];
  return str
      .split(RegExp(r'\s*[,;|]\s*'))
      .where((e) => e.trim().isNotEmpty)
      .map((e) => e.trim())
      .toList();
}

class MigrateSearchScreen extends StatefulWidget {
  final Manga manga;
  final List<Map<String, dynamic>> sources;

  const MigrateSearchScreen({
    super.key,
    required this.manga,
    required this.sources,
  });

  @override
  State<MigrateSearchScreen> createState() => _MigrateSearchScreenState();
}

class _MigrateSearchScreenState extends State<MigrateSearchScreen> {
  late TextEditingController _searchController;
  String _activeFilter = 'PINNED'; // 'PINNED', 'ALL', 'HAS_RESULTS'
  final Map<String, List<Map<String, dynamic>>> _searchResults = {};
  final Map<String, bool> _loadingStates = {};
  int _searchGeneration = 0;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.manga.title);
    _performSearchAcrossSources();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getTargetSources() {
    return widget.sources.where((s) {
      final id = s['id'].toString();
      final name = s['name'] as String? ?? '';
      if (name == widget.manga.sourceName || id == widget.manga.sourceName) return false;
      return true;
    }).toList();
  }

  Future<void> _performSearchAcrossSources() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    // Generation token: stale per-source searches from an earlier run must not
    // write their results/loading flags into this run's freshly-cleared maps.
    final generation = ++_searchGeneration;

    final targetSources = _getTargetSources();

    setState(() {
      _searchResults.clear();
      _loadingStates.clear();
      for (final s in targetSources) {
        final id = s['id'].toString();
        _loadingStates[id] = true;
      }
    });

    // Run searches with individual timeouts so no source blocks the UI
    await Future.wait(
      targetSources.map((s) => _searchSingleSource(
        s['id'].toString(),
        query,
        s['name'] as String? ?? s['displayName'] as String? ?? 'Source',
        generation,
      )),
    );
  }

  Future<void> _searchSingleSource(String sourceId, String query, String sourceName, int generation) async {
    try {
      final list = await ContentResolverService.instance.resolveSourceManga(
        sourceId: sourceId,
        sourceName: sourceName,
        searchQuery: query,
        page: 1,
      ).timeout(const Duration(seconds: 8), onTimeout: () => []);

      if (generation != _searchGeneration || !mounted) return;
      setState(() {
        _searchResults[sourceId] = list;
        _loadingStates[sourceId] = false;
      });
    } catch (e) {
      if (generation != _searchGeneration) return;
      await LoggerService.instance.logWarning('Search timed out on source $sourceId: $e', 'Migrate');
    } finally {
      if (generation == _searchGeneration && mounted) {
        setState(() {
          _searchResults.putIfAbsent(sourceId, () => []);
          _loadingStates[sourceId] = false;
        });
      }
    }
  }

  void _showMigrationConfirmation(Map<String, dynamic> targetManga, Map<String, dynamic> targetSource) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final targetTitle = (targetManga['title'] ?? targetManga['name'] ?? widget.manga.title).toString();
    final targetSourceName = _sourceDisplayNameOf(targetSource);
    final targetThumb = (targetManga['imageUrl'] ?? targetManga['thumbnailUrl'] ?? targetManga['cover'] ?? '').toString();

    bool copyHistory = true;
    bool copyCategories = true;
    bool copyTracking = true;
    bool deleteOriginal = true;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1F1F24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Row(
                children: [
                  Icon(Icons.swap_horiz_rounded, color: Colors.blueAccent, size: 24),
                  SizedBox(width: 10),
                  Text('Migrate Manga', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF26262E),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        children: [
                          // Source Manga Preview
                          Expanded(
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: MangaCoverImage(
                                    mangaServerId: widget.manga.canonicalKey,
                                    thumbnailUrl: widget.manga.thumbnailUrl,
                                    sourceName: widget.manga.sourceName,
                                    width: 48,
                                    height: 68,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  widget.manga.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  widget.manga.sourceName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Icon(Icons.arrow_forward_rounded, color: primaryColor, size: 22),
                          ),
                          // Target Manga Preview
                          Expanded(
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: targetThumb.isNotEmpty
                                      ? Image.network(
                                          targetThumb,
                                          headers: QuickJsService.getImageHeaders(targetSourceName, targetThumb),
                                          width: 48,
                                          height: 68,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => const Icon(Icons.book_rounded, size: 48),
                                        )
                                      : const Icon(Icons.book_rounded, size: 48),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  targetTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  targetSourceName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('WHAT TO INCLUDE', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      value: copyHistory,
                      activeColor: primaryColor,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Transfer chapter reading progress', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      onChanged: (v) => setDialogState(() => copyHistory = v ?? true),
                    ),
                    CheckboxListTile(
                      value: copyCategories,
                      activeColor: primaryColor,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Transfer category assignments', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      onChanged: (v) => setDialogState(() => copyCategories = v ?? true),
                    ),
                    CheckboxListTile(
                      value: copyTracking,
                      activeColor: primaryColor,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Transfer manga tracking records', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      onChanged: (v) => setDialogState(() => copyTracking = v ?? true),
                    ),
                    CheckboxListTile(
                      value: deleteOriginal,
                      activeColor: primaryColor,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Delete original manga from library', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      onChanged: (v) => setDialogState(() => deleteOriginal = v ?? true),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    Navigator.pop(dialogCtx);
                    await _executeMigration(
                      targetManga,
                      targetSource,
                      copyHistory: copyHistory,
                      copyCategories: copyCategories,
                      copyTracking: copyTracking,
                      deleteOriginal: deleteOriginal,
                    );
                  },
                  child: const Text('Migrate', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _executeMigration(
    Map<String, dynamic> targetManga,
    Map<String, dynamic> targetSource, {
    required bool copyHistory,
    required bool copyCategories,
    required bool copyTracking,
    required bool deleteOriginal,
  }) async {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final targetSourceName = _sourceDisplayNameOf(targetSource);
    final targetLink = (targetManga['link'] ?? targetManga['url'] ?? '').toString();
    final targetThumb = (targetManga['imageUrl'] ?? targetManga['thumbnailUrl'] ?? targetManga['cover'] ?? '').toString();
    final rawTargetTitle = (targetManga['title'] ?? targetManga['name'] ?? '').toString().trim();
    final targetTitle = rawTargetTitle.isNotEmpty ? rawTargetTitle : widget.manga.title;
    // Only results that demonstrably came from the Suwayomi server carry a real
    // server manga id. Local JS-extension scrapes may return arbitrary numeric
    // website ids — treating one as a server id would push server mutations
    // against a bogus/foreign record.
    bool isServerSource = targetManga['origin'] == 'server' &&
        targetManga.containsKey('id') &&
        targetManga['id'] != null &&
        int.tryParse(targetManga['id'].toString()) != null &&
        parseIntSafe(targetManga['id']) > 0;
    var targetMangaId = parseIntSafe(targetManga['id']);

    // Show loading progress overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: const Color(0xFF1F1F24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              children: [
                CircularProgressIndicator(color: primaryColor),
                const SizedBox(width: 20),
                const Expanded(
                  child: Text(
                    'Migrating manga & chapters...',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    bool migrationSuccess = false;
    try {
      // If target manga came from a local JS scraper (no server ID) but Suwayomi is connected,
      // resolve or create the manga on the Suwayomi server so both client and server stay in sync.
      // This runs for EVERY source: search first, then always fall back to addManga-by-URL so
      // the server tracks the migrated manga even when the search misses (webtoons and friends).
      if (!isServerSource && GraphQLClientService.instance.isConfigured) {
        String? serverSourceId;
        if (targetSource['id'] != null &&
            int.tryParse(targetSource['id'].toString()) != null &&
            parseIntSafe(targetSource['id']) > 0) {
          serverSourceId = targetSource['id'].toString();
        } else {
          serverSourceId = await GraphQLClientService.instance.resolveServerSourceId(targetSourceName);
        }

        if (serverSourceId != null) {
          // (a) Try searching on Suwayomi with target title. A failed or empty search
          // must never prevent the addManga fallback in (b), so it has its own catch.
          try {
            final searchRes = await GraphQLClientService.instance.fetchSourceManga(
              serverSourceId,
              searchQuery: targetTitle,
            );
            final mangas = searchRes?['fetchSourceManga']?['mangas'] as List<dynamic>?;
            if (mangas != null && mangas.isNotEmpty) {
              final normTargetLink = targetLink.toLowerCase().replaceAll(RegExp(r'^https?://[^/]+'), '');
              final normTargetTitle = targetTitle.toLowerCase().trim();
              final normAlphaTitle = normTargetTitle.replaceAll(RegExp(r'[^a-z0-9]'), '');
              final normAlphaTargetLink = normTargetLink.replaceAll(RegExp(r'[/?#]+$'), '');
              for (final m in mangas) {
                final mMap = m as Map<String, dynamic>;
                final mUrl = (mMap['url'] ?? '').toString().toLowerCase();
                final mTitle = (mMap['title'] ?? '').toString().toLowerCase().trim();
                final mAlphaTitle = mTitle.replaceAll(RegExp(r'[^a-z0-9]'), '');
                final normAlphaMUrl = mUrl.replaceAll(RegExp(r'^https?://[^/]+'), '').replaceAll(RegExp(r'[/?#]+$'), '');
                // Exact URL, fuzzy path-alias, exact title, then normalized-title
                // fallback (webtoons and friends often differ in casing/punctuation
                // between the local extension and the Suwayomi source record).
                if ((normTargetLink.isNotEmpty && normAlphaMUrl.isNotEmpty &&
                        (normAlphaMUrl == normAlphaTargetLink ||
                            (normAlphaMUrl.length >= 6 &&
                                (normAlphaMUrl.contains(normAlphaTargetLink) || normAlphaTargetLink.contains(normAlphaMUrl))))) ||
                    mTitle == normTargetTitle ||
                    (normAlphaTitle.isNotEmpty && normAlphaTitle.length >= 4 && normAlphaMUrl.isEmpty && mAlphaTitle == normAlphaTitle)) {
                  final sid = parseIntSafe(mMap['id']);
                  if (sid > 0) {
                    targetMangaId = sid;
                    isServerSource = true;
                    break;
                  }
                }
              }
            }
          } catch (e) {
            await LoggerService.instance.logWarning('Server search failed during migration: $e', 'Migrate');
          }

          // (b) Create/resolve the manga on the server by URL — ALWAYS attempted for
          // every source when the search above did not resolve an existing record.
          if (!isServerSource && targetLink.isNotEmpty) {
            try {
              final remoteId = await GraphQLClientService.instance.fetchMangaIdByUrl(
                serverSourceId,
                targetLink,
                title: targetTitle,
              );
              if (remoteId != null && remoteId > 0) {
                targetMangaId = remoteId;
                isServerSource = true;
              }
            } catch (e) {
              await LoggerService.instance.logWarning('Server addManga failed during migration: $e', 'Migrate');
            }
          }
        }
      }

      if (targetMangaId <= 0 && targetLink.isNotEmpty) {
        // MUST be a stable content hash: `String.hashCode` is seeded per
        // isolate, so persisting it as `Manga.serverId` gave the same series a
        // new identity on every cold start — a duplicate row each time, with
        // the previous identity's chapters (read state, bookmarks, downloads)
        // orphaned.
        targetMangaId = stableLocalMangaServerId(
          sourceName: targetSourceName,
          url: targetLink,
          title: targetTitle,
        ).abs();
      } else if (targetMangaId <= 0 && targetTitle.isNotEmpty) {
        // Empty link: derive from title so serverId is never 0 — serverId is a
        // unique-indexed field and a 0 would `replace` any other record that
        // still holds the default value (Isar unique + replace:true).
        targetMangaId = stableLocalMangaServerId(
          sourceName: targetSourceName,
          url: targetLink,
          title: targetTitle,
        ).abs();
      }

      Manga? targetMangaEntity;

      // 1. Fetch Target Manga into Suwayomi Library if server-backed
      if (isServerSource && GraphQLClientService.instance.isConfigured && targetMangaId > 0) {
        await GraphQLClientService.instance.updateMangaLibraryState(targetMangaId, true);
        if (copyCategories && widget.manga.categoryIds.isNotEmpty) {
          try {
            await GraphQLClientService.instance.updateMangaCategories(
              targetMangaId,
              List<int>.from(widget.manga.categoryIds),
            );
          } catch (e) {
            await LoggerService.instance.logWarning('Failed to sync migrated categories: $e', 'Migrate');
          }
        }
        await GraphQLClientService.instance.fetchMangaAndChapters(targetMangaId);
        targetMangaEntity = await IsarService.instance.getMangaByServerId(targetMangaId);
      }

      // 1b. FUSE instead of duplicate: the same series may already exist locally
      // under this source (e.g. a webtoons entry the Suwayomi server sync
      // created). Reuse it so we keep the server link and history instead of
      // creating a second webtoons entry.
      if (targetMangaEntity == null) {
        targetMangaEntity = await SourceMigrationService.instance.findExistingLibraryManga(
          sourceName: targetSourceName,
          url: targetLink,
          title: targetTitle,
        );
        if (targetMangaEntity != null) {
          await LoggerService.instance.logInfo(
            'Migration fused with existing library entry ${targetMangaEntity.serverId} ("${targetMangaEntity.title}", ${targetMangaEntity.sourceName}) for $targetSourceName — no duplicate created',
            'Migrate',
          );
        }
      }

      // 2. If target entity is local or not in Isar yet, ensure it is created and saved
      if (targetMangaEntity == null) {
        targetMangaEntity = Manga()
          ..serverId = isServerSource ? targetMangaId : -targetMangaId
          ..title = targetTitle
          ..url = targetLink
          ..thumbnailUrl = targetThumb
          ..sourceName = targetSourceName
          ..inLibrary = true
          ..inLibraryAt = DateTime.now().millisecondsSinceEpoch ~/ 1000
          ..status = targetManga['status'] is String ? targetManga['status'] as String : targetManga['status']?.toString() ?? 'UNKNOWN'
          ..artist = targetManga['artist']?.toString()
          ..author = targetManga['author']?.toString()
          ..description = targetManga['description']?.toString()
          ..genres = _coerceGenres(targetManga['genre'])
          ..categoryIds = copyCategories ? List<int>.from(widget.manga.categoryIds) : [];
        await IsarService.instance.saveManga(targetMangaEntity);
      } else {
        targetMangaEntity.inLibrary = true;
        if (isServerSource && targetMangaEntity.serverId != targetMangaId) {
          targetMangaEntity.serverId = targetMangaId;
        }
        if (targetMangaEntity.url.isEmpty && targetLink.isNotEmpty) {
          targetMangaEntity.url = targetLink;
        }
        if ((targetMangaEntity.thumbnailUrl == null || targetMangaEntity.thumbnailUrl!.isEmpty) && targetThumb.isNotEmpty) {
          targetMangaEntity.thumbnailUrl = targetThumb;
        }
        if (copyCategories && widget.manga.categoryIds.isNotEmpty) {
          targetMangaEntity.categoryIds = List<int>.from(widget.manga.categoryIds);
        }
        await IsarService.instance.saveManga(targetMangaEntity);
      }

      // 2b. Server backfill for EVERY source migration: if the target ended up as a
      // local-only entity (serverId <= 0) — e.g. a freshly created entry whose
      // server resolution missed, or a fused entry from an earlier failed
      // migration — create it on Suwayomi by URL so the server tracks it too,
      // then keep the real server id locally. This is what guarantees the migrated
      // manga is synced server-side regardless of which source it came from.
      if (GraphQLClientService.instance.isConfigured &&
          targetMangaEntity.serverId <= 0 &&
          targetLink.isNotEmpty) {
        try {
          String? serverSourceId;
          if (targetSource['id'] != null &&
              int.tryParse(targetSource['id'].toString()) != null &&
              parseIntSafe(targetSource['id']) > 0) {
            serverSourceId = targetSource['id'].toString();
          } else {
            serverSourceId = await GraphQLClientService.instance.resolveServerSourceId(targetSourceName);
          }

          if (serverSourceId != null) {
            final remoteId = await GraphQLClientService.instance.fetchMangaIdByUrl(
              serverSourceId,
              targetLink,
              title: targetTitle,
            );
            if (remoteId != null && remoteId > 0) {
              targetMangaId = remoteId;
              targetMangaEntity.serverId = remoteId;
              isServerSource = true;

              if (copyCategories && widget.manga.categoryIds.isNotEmpty) {
                try {
                  await GraphQLClientService.instance.updateMangaCategories(
                    remoteId,
                    List<int>.from(widget.manga.categoryIds),
                  );
                } catch (e) {
                  await LoggerService.instance.logWarning('Failed to sync migrated categories to server: $e', 'Migrate');
                }
              }
              await GraphQLClientService.instance.updateMangaLibraryState(remoteId, true);
              await GraphQLClientService.instance.fetchMangaAndChapters(remoteId);
              await IsarService.instance.saveManga(targetMangaEntity);
              await LoggerService.instance.logInfo(
                'Migration linked to server: server manga id $remoteId ("${targetMangaEntity.title}") — server will track chapters & progress',
                'Migrate',
              );
            }
          }
        } catch (e) {
          await LoggerService.instance.logWarning('Server backfill failed during migration: $e', 'Migrate');
        }
      }

      // 3. Transfer Category assignments
      if (copyCategories && widget.manga.categoryIds.isNotEmpty) {
        targetMangaEntity.categoryIds = List<int>.from(widget.manga.categoryIds);
        await IsarService.instance.saveManga(targetMangaEntity);
        if (isServerSource && GraphQLClientService.instance.isConfigured && targetMangaId > 0) {
          try {
            await GraphQLClientService.instance.updateMangaCategories(
              targetMangaId,
              targetMangaEntity.categoryIds,
            );
          } catch (e) {
            await LoggerService.instance.logWarning('Failed to sync migrated categories: $e', 'Migrate');
          }
        }
      }

      // 4. Ensure target chapters are populated for local JS extensions
      final tgtMangaId = targetMangaEntity.canonicalKey;
      var targetChapters = await IsarService.instance.getChaptersForManga(tgtMangaId);

      if (targetChapters.isEmpty && targetSourceName.isNotEmpty && QuickJsService.instance.hasExtension(targetSourceName)) {
        try {
          final targetUrl = targetMangaEntity.url.isNotEmpty ? targetMangaEntity.url : targetMangaEntity.title;
          final details = await QuickJsService.instance.fetchMangaDetailsLocal(targetSourceName, targetUrl);

          bool metaUpdated = false;
          if ((targetMangaEntity.description == null || targetMangaEntity.description!.isEmpty) && details['description'] != null) {
            targetMangaEntity.description = details['description'].toString();
            metaUpdated = true;
          }
          if ((targetMangaEntity.author == null || targetMangaEntity.author!.isEmpty) && details['author'] != null) {
            targetMangaEntity.author = details['author'].toString();
            metaUpdated = true;
          }
          if ((targetMangaEntity.artist == null || targetMangaEntity.artist!.isEmpty) && details['artist'] != null) {
            targetMangaEntity.artist = details['artist'].toString();
            metaUpdated = true;
          }
          final detailThumb = (details['imageUrl'] ?? details['thumbnailUrl'] ?? details['cover'])?.toString();
          if ((targetMangaEntity.thumbnailUrl == null || targetMangaEntity.thumbnailUrl!.isEmpty) && detailThumb != null && detailThumb.isNotEmpty) {
            targetMangaEntity.thumbnailUrl = detailThumb;
            metaUpdated = true;
          }
          if (metaUpdated) {
            await IsarService.instance.saveManga(targetMangaEntity);
          }

          final chList = (details['chapters'] ?? details['chapterList'] ?? details['epList'] ?? details['episodes']) as List<dynamic>? ?? [];
          final toSave = <Chapter>[];
          // Seed the collision probe with every chapter id already in use for
          // this series. The raw formula this replaces
          // (`-(mangaId * 10000 + i + 1)`) overlapped the canonical
          // `mintLocalChapterServerId` range (`-(mangaId * 100000 + i + 1)`)
          // ACROSS different series: migrating series 10 to a local extension
          // produced -100001, and a later scrape of series 1 minted the same
          // -100001. `Chapter.serverId` is `unique: true, replace: true`, so
          // that silently REPLACED the migrated row — its isRead, lastPageRead,
          // bookmark, download flag and local path all overwritten by a fresh
          // unread chapter, with no error anywhere.
          final takenServerIds = <int>{
            for (final existing in await IsarService.instance.getChaptersForManga(tgtMangaId))
              existing.serverId,
          };
          for (var i = 0; i < chList.length; i++) {
            final entry = chList[i];
            if (entry is! Map) continue;
            final cMap = Map<String, dynamic>.from(entry);
            final cUrl = (cMap['url'] ?? cMap['link'] ?? '').toString();
            final ch = Chapter()
              ..serverId = mintLocalChapterServerId(
                mangaId: tgtMangaId,
                index: i,
                takenServerIds: takenServerIds,
              )
              ..mangaId = tgtMangaId
              ..name = cMap['name']?.toString() ?? 'Chapter ${i + 1}'
              ..chapterNumber = (cMap['chapterNumber'] as num?)?.toDouble() ?? (i + 1).toDouble()
              ..url = cUrl
              ..realUrl = cUrl
              ..mangaTitle = targetMangaEntity.title
              ..mangaThumbnailUrl = targetMangaEntity.thumbnailUrl
              ..fetchedAt = 0
              ..isRead = false
              ..lastPageRead = 0;
            toSave.add(ch);
          }
          if (toSave.isNotEmpty) {
            await IsarService.instance.saveChapters(toSave);
            targetChapters = await IsarService.instance.getChaptersForManga(tgtMangaId);
            targetMangaEntity.unreadCount = targetChapters.length;
            await IsarService.instance.saveManga(targetMangaEntity);
          }
        } catch (e) {
          await LoggerService.instance.logWarning('Failed to fetch target chapters during migration: $e', 'Migrate');
        }
      }

      // 5. Transfer Chapter Reading Progress & History
      if (copyHistory) {
        final srcMangaId = widget.manga.canonicalKey;
        final sourceChapters = await IsarService.instance.getChaptersForManga(srcMangaId);

        if (sourceChapters.isNotEmpty && targetChapters.isNotEmpty) {
          final sourceByNumber = <double, Chapter>{};
          final sourceByTitle = <String, Chapter>{};

          for (final sc in sourceChapters) {
            if (sc.chapterNumber >= 0) {
              sourceByNumber[sc.chapterNumber] = sc;
            }
            final normTitle = sc.name.trim().toLowerCase();
            if (normTitle.isNotEmpty) {
              sourceByTitle[normTitle] = sc;
            }
          }

          final updatedTargetChapters = <Chapter>[];

          for (final tc in targetChapters) {
            Chapter? match;
            if (tc.chapterNumber >= 0 && sourceByNumber.containsKey(tc.chapterNumber)) {
              match = sourceByNumber[tc.chapterNumber];
            } else {
              final normTitle = tc.name.trim().toLowerCase();
              if (sourceByTitle.containsKey(normTitle)) {
                match = sourceByTitle[normTitle];
              }
            }

            // Incognito suppresses reading history, so migrating a series must
            // not resurrect it. Without this the target chapters get isRead,
            // lastPageRead and lastReadAt written straight to Isar and the
            // parent is stamped via stampLocalReadActivity — the private read
            // then appears in History, in the in-progress query, and floats
            // the series to the top of Library "Last Read" sorting. The
            // network push was already blocked, so the user ended up with read
            // state that existed locally but never synced: exactly the
            // half-broken outcome the central guards exist to prevent.
            //
            // Bookmarks and download state are not reading history, so they
            // still copy.
            final copyingHistory = !SettingsService.instance.incognitoMode;

            if (match != null &&
                (match.isBookmarked ||
                    match.isDownloadedLocally ||
                    (copyingHistory && (match.isRead || match.lastPageRead > 0)))) {
              if (copyingHistory) {
                tc.isRead = match.isRead;
                tc.lastPageRead = match.lastPageRead;
                tc.lastReadAt = match.lastReadAt;
              }
              tc.isBookmarked = match.isBookmarked;
              // NOTE: download state is deliberately NOT copied — the source
              // chapters' downloaded files belong to the source URLs, not the
              // target's, so claiming them downloaded here would be a lie.
              tc.fetchedAt = match.fetchedAt;
              updatedTargetChapters.add(tc);

              if (tc.isRead) {
                // The migrated chapter arrives read, so carry over the read
                // activity locally too — otherwise it is invisible to History
                // and the in-progress query until the next full sync.
                await SyncEngine.instance.stampLocalReadActivity(tc);
              }
              if (tc.serverId > 0) {
                await SyncEngine.instance.syncChapterProgress(
                  tc.serverId,
                  isRead: tc.isRead,
                  lastPageRead: tc.lastPageRead,
                );
              }
            }
          }

          if (updatedTargetChapters.isNotEmpty) {
            await IsarService.instance.saveChapters(updatedTargetChapters);
            final allTargetChapters = await IsarService.instance.getChaptersForManga(tgtMangaId);
            targetMangaEntity.unreadCount = allTargetChapters.where((c) => !c.isRead).length;
            await IsarService.instance.saveManga(targetMangaEntity);
          }
        }
      }

      // 6. Transfer Manga Tracking records
      if (copyTracking && isServerSource && widget.manga.serverId > 0 && targetMangaId > 0 && GraphQLClientService.instance.isConfigured) {
        try {
          final existingTracks = await GraphQLClientService.instance.fetchTrackRecords(widget.manga.serverId);
          final nodes = existingTracks?['trackRecords']?['nodes'] as List<dynamic>? ?? [];
          for (final tr in nodes) {
            final trackerId = parseIntSafe(tr['trackerId']);
            final remoteId = tr['remoteId']?.toString() ?? tr['id']?.toString();
            if (trackerId > 0 && remoteId != null) {
              await GraphQLClientService.instance.bindTrack(targetMangaId, trackerId, remoteId);
            }
          }
        } catch (e) {
          await LoggerService.instance.logWarning('Failed to copy track records: $e', 'Migrate');
        }
      }

      // 6. Delete Original Manga from Library if requested
      if (deleteOriginal) {
        // Fetch fresh copy to avoid mutating widget parameter directly
        final originalManga = await IsarService.instance.getMangaByServerId(widget.manga.canonicalKey);
        if (originalManga != null) {
          originalManga.inLibrary = false;
          await IsarService.instance.saveManga(originalManga);
          if (originalManga.serverId > 0) {
            await SyncEngine.instance.syncMangaLibraryState(originalManga.serverId, false);
          }
        }
      }
      // Every migration that achieved a server link (resolved by search, by URL
      // addManga, or via backfill) triggers a background sync so client and server
      // converge — for every source, not just server-resolvable ones.
      final serverLinked = isServerSource || targetMangaEntity.serverId > 0;
      if (serverLinked && GraphQLClientService.instance.isConfigured) {
        unawaited(SyncEngine.instance.triggerSync());
      }
      migrationSuccess = true;
    } catch (e, stack) {
      await LoggerService.instance.logError('Migration error: $e', exception: e, stackTrace: stack, category: 'Migrate');
    } finally {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }

    if (mounted) {
      if (migrationSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully migrated "${widget.manga.title}" to $targetSourceName!'),
            backgroundColor: primaryColor,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to migrate "${widget.manga.title}". Please try again.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    final targetSources = widget.sources.where((s) {
      final name = s['name'] as String? ?? '';
      final id = s['id'].toString();
      if (name == widget.manga.sourceName || id == widget.manga.sourceName) return false;

      if (_activeFilter == 'PINNED') return s['isPinned'] == true;
      if (_activeFilter == 'HAS_RESULTS') {
        return (_searchResults[id]?.isNotEmpty ?? false);
      }
      return true;
    }).toList();

    final isAnyLoading = _loadingStates.values.any((loading) => loading);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: 'Search title...',
            border: InputBorder.none,
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  ),
                IconButton(
                  icon: Icon(Icons.search_rounded, color: primaryColor),
                  onPressed: _performSearchAcrossSources,
                ),
              ],
            ),
          ),
          onSubmitted: (_) => _performSearchAcrossSources(),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // ── FILTER CHIPS (PINNED, ALL, HAS RESULTS) ─────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                FilterChip(
                  label: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.push_pin_rounded, size: 14),
                      SizedBox(width: 4),
                      Text('PINNED'),
                    ],
                  ),
                  selected: _activeFilter == 'PINNED',
                  selectedColor: primaryColor.withAlpha(50),
                  backgroundColor: const Color(0x1F2A2A32),
                  labelStyle: TextStyle(
                    color: _activeFilter == 'PINNED' ? primaryColor : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: _activeFilter == 'PINNED' ? primaryColor : const Color(0x2BFFFFFF), width: 0.8),
                  ),
                  onSelected: (_) => setState(() => _activeFilter = 'PINNED'),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.done_all_rounded, size: 14),
                      SizedBox(width: 4),
                      Text('ALL'),
                    ],
                  ),
                  selected: _activeFilter == 'ALL',
                  selectedColor: primaryColor.withAlpha(50),
                  backgroundColor: const Color(0x1F2A2A32),
                  labelStyle: TextStyle(
                    color: _activeFilter == 'ALL' ? primaryColor : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: _activeFilter == 'ALL' ? primaryColor : const Color(0x2BFFFFFF), width: 0.8),
                  ),
                  onSelected: (_) => setState(() => _activeFilter = 'ALL'),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_outline_rounded, size: 14),
                      SizedBox(width: 4),
                      Text('HAS RESULTS'),
                    ],
                  ),
                  selected: _activeFilter == 'HAS_RESULTS',
                  selectedColor: primaryColor.withAlpha(50),
                  backgroundColor: const Color(0x1F2A2A32),
                  labelStyle: TextStyle(
                    color: _activeFilter == 'HAS_RESULTS' ? primaryColor : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: _activeFilter == 'HAS_RESULTS' ? primaryColor : const Color(0x2BFFFFFF), width: 0.8),
                  ),
                  onSelected: (_) => setState(() => _activeFilter = 'HAS_RESULTS'),
                ),
                if (isAnyLoading) ...[
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: primaryColor),
                  ),
                  const SizedBox(width: 6),
                  const Text('Searching...', style: TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0x1AFFFFFF)),

          // ── SOURCES EXPANDABLE LIST ─────────────────────────────
          Expanded(
            child: targetSources.isEmpty
                ? Center(
                    child: Text(
                      _activeFilter == 'PINNED'
                          ? 'No pinned sources found.\nSwitch to "ALL" to search across all sources.'
                          : 'No sources available for migration.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: targetSources.length,
                    itemBuilder: (context, index) {
                      final source = targetSources[index];
                      final sourceId = source['id'].toString();
                      final sourceName = _sourceDisplayNameOf(source);
                      final lang = (source['lang'] as String? ?? 'en').toUpperCase();
                      final isLoading = _loadingStates[sourceId] ?? false;
                      final results = _searchResults[sourceId] ?? [];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Material(
                          color: const Color(0x1F2A2A32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: Color(0x2BFFFFFF), width: 0.8),
                          ),
                          child: ExpansionTile(
                            initiallyExpanded: results.isNotEmpty,
                            shape: const Border(),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    sourceName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: const Color(0x33FFFFFF), borderRadius: BorderRadius.circular(4)),
                                  child: Text(lang, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            trailing: isLoading
                                ? SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: primaryColor),
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (results.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: primaryColor.withAlpha(50),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            '${results.length}',
                                            style: TextStyle(color: primaryColor, fontSize: 11, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                                    ],
                                  ),
                            children: [
                              if (results.isEmpty && !isLoading)
                                const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text('No matching results found on this source.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                )
                              else
                                ...results.map((res) {
                                  final thumb = (res['thumbnailUrl'] ?? res['imageUrl'] ?? res['cover'] ?? '').toString();
                                  final rawTitle = (res['title'] ?? res['name'] ?? '').toString().trim();
                                  final title = rawTitle.isNotEmpty ? rawTitle : 'Untitled';

                                  return ListTile(
                                    leading: thumb.isNotEmpty
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(6),
                                            child: Image.network(
                                              thumb,
                                              headers: QuickJsService.getImageHeaders(sourceName, thumb),
                                              width: 38,
                                              height: 52,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => Icon(Icons.book_rounded, color: primaryColor),
                                            ),
                                          )
                                        : Icon(Icons.book_rounded, color: primaryColor),
                                    title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                                    trailing: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColor,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      ),
                                      child: const Text('Select', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                      onPressed: () => _showMigrationConfirmation(res, source),
                                    ),
                                  );
                                }),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
