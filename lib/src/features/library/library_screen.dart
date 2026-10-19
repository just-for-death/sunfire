import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/isar_service.dart';
import '../../core/db/models/category.dart';
import '../../core/db/models/chapter.dart';
import '../../core/db/models/manga.dart';
import '../../core/db/models/tag.dart';
import '../../core/engine/quickjs_service.dart';
import '../../core/logging/logger_service.dart';
import '../../core/services/batch_mode_service.dart';
import '../../core/services/download_manager_service.dart';
import '../../core/services/image_cache_helper.dart';
import '../../core/services/library_matching.dart';
import '../../core/services/settings_service.dart';
import '../../core/services/tag_service.dart';
import '../../core/sync/graphql_client_service.dart';
import '../../core/sync/sync_engine.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../main_shell.dart';
import '../../ui/design_system/components/sunfire_skeleton.dart';
import '../../ui/design_system/sunfire_theme.dart';
import '../../ui/design_system/tokens/sunfire_colors.dart';
import '../../ui/design_system/tokens/sunfire_spacing.dart';
import '../../ui/design_system/tokens/sunfire_typography.dart';
import '../../ui/shell/sunfire_breakpoints.dart';
import '../../ui/widgets/dialog_title.dart';
import '../../ui/widgets/library_update_progress_banner.dart';
import 'library_tag_filter.dart';


class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> with AutomaticKeepAliveClientMixin {

  // ISS-018: theme-aware colours so Light mode stays readable.
  ColorScheme get _cs => Theme.of(context).colorScheme;
  bool get _isLight => _cs.brightness == Brightness.light;
  @override
  bool get wantKeepAlive => true;
  final SettingsService _settings = SettingsService.instance;
  int _selectedCategoryIndex = 0;
  List<Manga> _allManga = [];
  List<Category> _categories = [];
  List<Tag> _tags = const [];
  /// Null = all tags. Isar tag id when filtering.
  int? _selectedTagId;
  // Starts TRUE. It was declared false and never set true outside the loader, so
  // the very first frame of the tab unconditionally rendered the "Your Library
  // is Empty" panel with a "Browse Sources" button — a false claim, on every
  // cold start, for a user with a full library, for at least one frame. Both
  // exits of `_loadFromIsarThenSync` clear it, including the catch.
  bool _isLoading = true;

  /// Set when a library load threw, so the empty state can distinguish "you have
  /// no manga" from "we could not read the database".
  String? _loadError;
  bool _isSearching = false;
  String _searchQuery = '';
  String _sortBy = 'Title';
  bool _isSortAscending = true;
  String _statusFilter = 'All'; // 'All', 'Unread', 'Downloaded', 'Completed'

  // Offline banner state
  bool _isOffline = false;
  bool _isSyncing = false;

  // Multi-select batch mode
  bool _isBatchMode = false;
  final Set<int> _selectedMangaIds = {};

  // Tab-switch reload coalescing (see _onTabChanged)
  Timer? _tabReloadTimer;
  bool _isLoadingIsar = false;
  bool _reloadQueued = false;

  /// Manga whose cover could not be resolved by QuickJS this session. Retrying
  /// them is pure cost: the failure is deterministic for a given (source, url)
  /// pair, and without this the healing loop re-executed JS for every one of
  /// them on every single Library tab visit. Reset whenever the source or URL
  /// changes, which is handled because a changed row produces a new key.
  final Set<String> _coverHealFailed = {};
  StreamSubscription<void>? _syncCompleteSub;
  StreamSubscription<void>? _mangaWatchSub;

  @override
  void initState() {
    super.initState();
    unawaited(_loadFromIsarThenSync());
    // ISS-059: when a mid-flight triggerSync was queued behind another cycle,
    // reload Isar once the gate finishes so the grid is not left empty.
    _syncCompleteSub = SyncEngine.instance.onSyncCycleComplete.listen((_) {
      if (!mounted) return;
      unawaited(_loadFromIsarOnly());
    });
    // UIX6-07: live library — reload when any manga row changes (debounced),
    // e.g. Add to Library from Browse or a queued outbox change.
    _mangaWatchSub = IsarService.instance.watchMangaLazy().listen((_) {
      if (!mounted) return;
      unawaited(_loadFromIsarOnly());
    });
    MainShell.selectedTabNotifier.addListener(_onTabChanged);
    // This screen reads six display settings straight out of `build()`
    // (showCategoryTabs, libraryDisplayMode, gridColumnCount,
    // showUnreadBadges, showDownloadedBadges, showLanguageBadges) with no
    // listener, so it only refreshed them as a side effect of the tab switch:
    // Settings lives under the "More" tab, so navigating there set the tab
    // notifier to 4 and coming back fired _onTabChanged. That is a coincidence
    // of the navigation graph, not a guarantee — any settings write that
    // happened while this tab stayed selected was silently ignored until some
    // unrelated rebuild. Listening makes the dependency explicit.
    _settings.addListener(_onSettingsChanged);
  }

  void _onSettingsChanged() {
    if (mounted) setState(() {});
  }

  void _onTabChanged() {
    if (MainShell.selectedTabNotifier.value != 0 || !mounted) return;
    // Coalesced + single-flight. This reload runs the QuickJS cover-healing
    // loop, so an undebounced call on every Library tab visit re-executed JS
    // for every manga whose cover could not be resolved — for the life of the
    // session, since a failed heal looks identical to a fresh one.
    _tabReloadTimer?.cancel();
    _tabReloadTimer = Timer(const Duration(milliseconds: 250), () {
      _tabReloadTimer = null;
      if (!mounted) return;
      if (_isLoadingIsar) {
        _reloadQueued = true;
        return;
      }
      unawaited(_loadFromIsarOnly());
    });
  }

  @override
  void dispose() {
    unawaited(_mangaWatchSub?.cancel());
    _tabReloadTimer?.cancel();
    unawaited(_syncCompleteSub?.cancel());
    _settings.removeListener(_onSettingsChanged);
    MainShell.selectedTabNotifier.removeListener(_onTabChanged);
    super.dispose();
  }

  /// Library rows, after resolving direct CDN covers for series that only have
  /// a server-proxy cover. Each lookup runs QuickJS (network-bound), so only the
  /// thumbnail is patched onto a freshly read row and the library is re-read
  /// afterwards; saving the list read before the loop reverted whatever a sync
  /// or another screen changed meanwhile.
  Future<List<Manga>> _loadLibraryHealingCovers({required bool rememberFailures}) async {
    final list = await IsarService.instance.getLibraryManga();
    var healed = false;
    for (final m in list) {
      final thumb = m.thumbnailUrl;
      if (thumb != null && thumb.isNotEmpty && !thumb.contains('/api/v1/manga/')) continue;
      if (m.sourceName.isEmpty || m.url.isEmpty) continue;
      final healKey = '${m.sourceName}\u0000${m.url}';
      if (rememberFailures && _coverHealFailed.contains(healKey)) continue;
      final direct = await QuickJsService.instance.getExtensionCoverUrl(m.sourceName, m.url);
      if (direct == null || direct.isEmpty) {
        if (rememberFailures) _coverHealFailed.add(healKey);
        continue;
      }
      final current = await IsarService.instance.getMangaByServerId(m.serverId);
      if (current == null) continue;
      current.thumbnailUrl = direct;
      await IsarService.instance.saveManga(current);
      healed = true;
    }
    return healed ? IsarService.instance.getLibraryManga() : list;
  }

  /// Load Isar immediately (never blocks on network). Then attempt a background
  /// sync to update. This guarantees the library is visible instantly even when
  /// the server is down, wiped, or unreachable.
  Future<void> _loadFromIsarThenSync() async {
    try {
      final list = await _loadLibraryHealingCovers(rememberFailures: false);
      final cats = await IsarService.instance.getCategories();
      final tags = await TagService.instance.getAllTags();

      if (mounted) {
        setState(() {
          _allManga = list;
          _categories = cats;
          _tags = tags;
          _clampCategoryIndex();
          _clampTagSelection();
          _isLoading = false;
          _loadError = null;
        });
      }
    } catch (e, stack) {
      unawaited(LoggerService.instance.logError('Library load from Isar failed: $e', exception: e, stackTrace: stack, category: 'Library'));
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Recorded so the empty state can say "could not load" with a Retry
          // instead of claiming the library is empty. A transient Isar failure
          // (locked DB, migration in flight, corrupt index) previously rendered
          // "Your Library is Empty" and offered "Browse Sources", pushing the
          // user AWAY from data they already had.
          _loadError = '$e';
        });
      }
      return;
    }

    // 2. Background sync (silent — only if server is configured)
    if (GraphQLClientService.instance.isConfigured) {
      unawaited(_backgroundSync());
    }
  }

  /// Keeps [_selectedCategoryIndex] valid after a category reload: if the
  /// previously selected category no longer exists (deleted/renamed), fall back
  /// to 'All' (index 0) instead of pointing past the end of the tab list or at
  /// a different category than the user picked.
  void _clampCategoryIndex() {
    if (_selectedCategoryIndex > _categories.length) {
      _selectedCategoryIndex = 0;
    } else if (_selectedCategoryIndex > 0) {
      final selectedId = _categories[_selectedCategoryIndex - 1].serverId;
      if (!_categories.any((c) => c.serverId == selectedId)) {
        _selectedCategoryIndex = 0;
      }
    }
  }

  void _clampTagSelection() {
    final selected = _selectedTagId;
    if (selected == null) return;
    if (!_tags.any((t) => t.id == selected)) {
      _selectedTagId = null;
    }
  }

  Future<void> _loadFromIsarOnly() async {
    if (_isLoadingIsar) {
      _reloadQueued = true;
      return;
    }
    _isLoadingIsar = true;
    try {
      await _loadFromIsarOnlyInner();
    } finally {
      _isLoadingIsar = false;
      if (_reloadQueued) {
        _reloadQueued = false;
        unawaited(_loadFromIsarOnly());
      }
    }
  }

  Future<void> _loadFromIsarOnlyInner() async {
    try {
      final list = await _loadLibraryHealingCovers(rememberFailures: true);
      final cats = await IsarService.instance.getCategories();
      final tags = await TagService.instance.getAllTags();

      if (mounted) {
        setState(() {
          _allManga = list;
          _categories = cats;
          _tags = tags;
          _clampCategoryIndex();
          _clampTagSelection();
        });
      }
    } catch (e, stack) {
      unawaited(LoggerService.instance.logError('Failed to load library from Isar: $e', exception: e, stackTrace: stack, category: 'Library'));
    }
  }

  Future<void> _backgroundSync() async {
    if (_isSyncing) return;
    if (mounted) setState(() => _isSyncing = true);
    try {
      await SyncEngine.instance.triggerSync().timeout(
        const Duration(seconds: 30),
        onTimeout: () {},
      );
      final list = await IsarService.instance.getLibraryManga();
      final cats = await IsarService.instance.getCategories();
      final tags = await TagService.instance.getAllTags();
      if (mounted) {
        setState(() {
          _allManga = list;
          _categories = cats;
          _tags = tags;
          _clampCategoryIndex();
          _clampTagSelection();
          _isOffline = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isOffline = true);
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  Future<void> _handleRefresh() async {
    // Same guard as _backgroundSync. Without it a second pull while the first
    // is in flight hits SyncEngine's own single-flight check, returns
    // immediately, re-reads a stale Isar snapshot and then clears _isSyncing in
    // its finally — so the spinner vanished while the first sync was still
    // running, and the user saw "refreshed" data that was not.
    if (_isSyncing) return;
    if (mounted) setState(() => _isSyncing = true);
    try {
      if (GraphQLClientService.instance.isConfigured) {
        // Bounded like _backgroundSync: a full per-manga detail snapshot over
        // a large library can run for minutes, and RefreshIndicator would spin
        // the whole time. Bailing out still leaves the results in Isar, which
        // the next reload picks up.
        await SyncEngine.instance.triggerSync().timeout(
          const Duration(seconds: 30),
          onTimeout: () {},
        );
      } else {
        // Standalone mode: check local JS extensions for new chapters across library titles
        await _checkStandaloneUpdates();
      }
      final list = await IsarService.instance.getLibraryManga();
      final cats = await IsarService.instance.getCategories();
      final tags = await TagService.instance.getAllTags();
      if (mounted) {
        setState(() {
          _allManga = list;
          _categories = cats;
          _tags = tags;
          _clampCategoryIndex();
          _clampTagSelection();
          _isOffline = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isOffline = true);
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  Future<void> _checkStandaloneUpdates() async {
    final libraryManga = await IsarService.instance.getLibraryManga();
    // One batched query up front instead of one per manga inside the loop.
    final existingChaptersByManga = await IsarService.instance.getChaptersForMangas(
      libraryManga.map((m) => m.canonicalKey).toList(),
    );
    for (final manga in libraryManga) {
      if (manga.sourceName.isEmpty || manga.url.isEmpty) continue;
      try {
        final detail = await QuickJsService.instance.fetchMangaDetailsLocal(
          manga.sourceName,
          manga.url,
        );
        if (detail.containsKey('chapters')) {
          final rawChapters = detail['chapters'] as List<dynamic>?;
          if (rawChapters != null && rawChapters.isNotEmpty) {
            final mId = manga.canonicalKey;
            final existingChapters = existingChaptersByManga[mId] ?? const <Chapter>[];
            final existingUrls = existingChapters.map((c) => c.url).toSet();
            // Seeded with every id this manga already uses so the minting below
            // cannot collide with one. Without this the index-derived id of a
            // newly prepended chapter lands on the row of the chapter that used
            // to occupy that slot, and saveChapters' putAll silently replaces
            // it — wiping its read state, bookmark and local download.
            final existingServerIds = existingChapters.map((c) => c.serverId).toSet();
            final newChapters = <Chapter>[];
            for (int i = 0; i < rawChapters.length; i++) {
              final chMap = rawChapters[i] as Map<String, dynamic>;
              final chUrl = chMap['url']?.toString() ?? '';
              if (chUrl.isNotEmpty && !existingUrls.contains(chUrl)) {
                final chServerId = mintLocalChapterServerId(
                  mangaId: mId,
                  index: i,
                  takenServerIds: existingServerIds,
                );
                final ch = Chapter()
                  ..serverId = chServerId
                  ..mangaId = mId
                  ..name = chMap['name']?.toString() ?? 'Chapter ${i + 1}'
                  ..chapterNumber = (chMap['chapterNumber'] as num?)?.toDouble() ?? (i + 1).toDouble()
                  ..url = chUrl
                  ..realUrl = chUrl
                  ..mangaTitle = manga.title
                  ..mangaThumbnailUrl = manga.thumbnailUrl
                  ..isRead = false
                  ..lastPageRead = 0;
                newChapters.add(ch);
              }
            }
            if (newChapters.isNotEmpty) {
              // Shared flood gate. A whole first import stays out of the feed
              // (getRecentChapters filters fetchedAt > 0); later batches are
              // capped at the newest few so a bulk refresh cannot make the
              // Library tile, the notification and the Updates feed disagree.
              applyFloodCapToNewChapters(
                newChapters,
                isFirstImport: existingChapters.isEmpty,
              );
              await IsarService.instance.saveChapters(newChapters);
              manga.unreadCount = (manga.unreadCount ?? 0) + newChapters.length;
              // Keep the denormalized chapter count in sync too — otherwise the
              // "Chapters" sort and detail badge go stale after updates.
              manga.chapterCount = existingChapters.length + newChapters.length;
              await IsarService.instance.saveManga(manga);
            }
          }
        }
      } catch (e) {
        unawaited(LoggerService.instance.logWarning('Standalone update check failed for ${manga.title}: $e', 'Library'));
      }
    }
  }

  List<Manga> get _filteredManga {
    var list = List<Manga>.from(_allManga);

    // 0. Status Filter
    if (_statusFilter == 'Unread') {
      list = list.where((m) => (m.unreadCount ?? 0) > 0).toList();
    } else if (_statusFilter == 'Downloaded') {
      final downloadedMangaIds = DownloadManagerService.instance.downloadedMangaIds;
      final serverDownloadedIds = DownloadManagerService.instance.downloadedServerMangaIds;
      list = list.where((m) {
        final key = m.canonicalKey;
        return downloadedMangaIds.contains(key) || serverDownloadedIds.contains(key);
      }).toList();
    } else if (_statusFilter == 'Completed') {
      list = list.where((m) => (m.status ?? '').toLowerCase() == 'completed').toList();
    }

    // 1. Category Filter
    if (_settings.showCategoryTabs && _selectedCategoryIndex > 0 && _selectedCategoryIndex <= _categories.length) {
      final selectedCatId = _categories[_selectedCategoryIndex - 1].serverId;
      list = list.where((m) => mangaBelongsToCategory(m.categoryIds, selectedCatId)).toList();
    }

    // 1b. Custom tag filter (L10.2)
    if (_selectedTagId != null) {
      list = list
          .where((m) => mangaMatchesTagFilter(
                mangaTagIds: m.tagIds,
                selectedTagId: _selectedTagId,
              ))
          .toList();
    }

    // 2. Smart Search Query Filter (Mihon / Mangayomi Tokens)
    if (_searchQuery.trim().isNotEmpty) {
      final downloadedMangaIds = DownloadManagerService.instance.downloadedMangaIds;
      final serverDownloadedIds = DownloadManagerService.instance.downloadedServerMangaIds;
      final tokens = _searchQuery.trim().toLowerCase().split(RegExp(r'\s+'));
      
      list = list.where((m) {
        final title = m.title.toLowerCase();
        final source = m.sourceName.toLowerCase();
        final author = (m.author ?? '').toLowerCase();
        final artist = (m.artist ?? '').toLowerCase();
        final genres = m.genres.map((g) => g.toLowerCase()).toList();
        final status = (m.status ?? '').toLowerCase();
        final isDownloaded = downloadedMangaIds.contains(m.canonicalKey) || serverDownloadedIds.contains(m.canonicalKey);

        for (final token in tokens) {
          if (token.isEmpty) continue;
          if (token.startsWith('tag:') || token.startsWith('genre:')) {
            final val = token.substring(token.indexOf(':') + 1);
            if (!genres.any((g) => g.contains(val))) return false;
          } else if (token.startsWith('src:') || token.startsWith('source:')) {
            final val = token.substring(token.indexOf(':') + 1);
            if (!source.contains(val)) return false;
          } else if (token.startsWith('author:')) {
            final val = token.substring(7);
            if (!author.contains(val)) return false;
          } else if (token.startsWith('artist:')) {
            final val = token.substring(7);
            if (!artist.contains(val)) return false;
          } else if (token.startsWith('status:')) {
            final val = token.substring(7);
            if (!status.contains(val)) return false;
          } else if (token == 'unread:true' || token == 'unread:yes') {
            if ((m.unreadCount ?? 0) <= 0) return false;
          } else if (token == 'downloaded:true' || token == 'downloaded:yes') {
            if (!isDownloaded) return false;
          } else {
            // Default keyword search matches title, author, or source
            if (!title.contains(token) && !source.contains(token) && !author.contains(token)) {
              return false;
            }
          }
        }
        return true;
      }).toList();
    }

    // 3. Sorting
    list.sort((a, b) {
      int cmp = 0;
      if (_sortBy == 'Title') {
        cmp = a.title.toLowerCase().compareTo(b.title.toLowerCase());
      } else if (_sortBy == 'Unread') {
        cmp = (a.unreadCount ?? 0).compareTo(b.unreadCount ?? 0);
      } else if (_sortBy == 'Recent') {
        // Normalised on read as well as on write. Rows written before the
        // sync-side fix can still hold a millis value, and comparing those
        // against seconds values would pin the affected entries to one end of
        // the list indefinitely — sorting them correctly is also a cheap,
        // self-healing way to make existing data behave.
        cmp = (normalizeEpochToSeconds(a.inLibraryAt) ?? 0)
            .compareTo(normalizeEpochToSeconds(b.inLibraryAt) ?? 0);
      } else if (_sortBy == 'Last Read') {
        cmp = (a.lastReadAt ?? 0).compareTo(b.lastReadAt ?? 0);
      } else if (_sortBy == 'Chapters') {
        cmp = a.chapterCount.compareTo(b.chapterCount);
      }
      return _isSortAscending ? cmp : -cmp;
    });

    return list;
  }

  void _toggleBatchSelection(int mangaServerId) {
    setState(() {
      if (_selectedMangaIds.contains(mangaServerId)) {
        unawaited(HapticFeedback.selectionClick());
        _selectedMangaIds.remove(mangaServerId);
        if (_selectedMangaIds.isEmpty) {
          _isBatchMode = false;
          BatchModeService.instance.disable();
        }
      } else {
        if (!_isBatchMode) {
          unawaited(HapticFeedback.mediumImpact());
        } else {
          unawaited(HapticFeedback.selectionClick());
        }
        _selectedMangaIds.add(mangaServerId);
        _isBatchMode = true;
        BatchModeService.instance.enable();
      }
    });
  }

  void _selectAll() {
    unawaited(HapticFeedback.selectionClick());
    final currentList = _filteredManga;
    // Decide based on whether *all currently visible* items are selected, not
    // on matching lengths: the selection set may contain stale ids (e.g. the
    // filter changed since items were picked), which made the old
    // `length == length` check toggle the wrong way.
    final allVisibleSelected = currentList.isNotEmpty &&
        currentList.every((m) => _selectedMangaIds.contains(m.canonicalKey));
    setState(() {
      if (allVisibleSelected) {
        _selectedMangaIds.clear();
        _isBatchMode = false;
        BatchModeService.instance.disable();
      } else {
        _selectedMangaIds.addAll(currentList.map((m) => m.canonicalKey));
        _isBatchMode = true;
        BatchModeService.instance.enable();
      }
    });
  }

  /// Leaves batch mode.
  ///
  /// Guarded internally because all five call sites invoke this after awaits —
  /// a per-chapter `stampLocalReadActivity` loop, an `enqueueLocalDownload`
  /// loop, a `syncMangaLibraryState` round trip — which on a large selection is
  /// seconds to minutes of wall time during which the route can be popped. The
  /// sheet pop immediately above one of these call sites was already guarded,
  /// which is what made the omission visible.
  void _exitBatchMode() {
    if (!mounted) return;
    unawaited(HapticFeedback.lightImpact());
    setState(() {
      _selectedMangaIds.clear();
      _isBatchMode = false;
      BatchModeService.instance.disable();
    });
  }

  Future<Manga?> _resolveManga(int id) async {
    if (id > 0) {
      final m = await IsarService.instance.getMangaByServerId(id);
      if (m != null) return m;
    }
    return await IsarService.instance.getManga(id) ?? await IsarService.instance.getMangaByServerId(id);
  }

  Future<void> _batchMoveToCategory() async {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final Set<int> selectedCatIds = {};

    if (_selectedMangaIds.length == 1) {
      final m = await _resolveManga(_selectedMangaIds.first);
      if (m != null) {
        selectedCatIds.addAll(m.categoryIds);
      }
    } else {
      final allSelectedManga = await Future.wait(
        _selectedMangaIds.map((id) => _resolveManga(id)),
      );
      final validManga = allSelectedManga.whereType<Manga>().toList();
      if (validManga.isNotEmpty) {
        final common = validManga.first.categoryIds.toSet();
        for (final m in validManga.skip(1)) {
          common.retainAll(m.categoryIds);
        }
        selectedCatIds.addAll(common);
      }
    }
    final Set<int> initialCommonCatIds = Set<int>.from(selectedCatIds);
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      // UIS-ISS-012: theme surface (was hard-coded dark hex)
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(SunfireRadius.sheet))),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetBuilderContext, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.folder_open_rounded, color: primaryColor, size: SunfireIconSize.lg),
                        const SizedBox(width: 10),
                        Expanded(child: Text(
                          'Categories (${_selectedMangaIds.length} selected)',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        )),
                      ],
                    ),
                    const SizedBox(height: SunfireSpacing.md),
                    if (_categories.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text('No categories created yet. Tap "Edit Categories" to create one.', style: TextStyle(color: SunfireColors.contentTertiary)),
                      )
                    else
                      Flexible(
                        child: ListView(
                          shrinkWrap: true,
                          children: _categories.map((cat) {
                            final isChecked = selectedCatIds.contains(cat.serverId);
                            return CheckboxListTile(
                              activeColor: primaryColor,
                              contentPadding: EdgeInsets.zero,
                              title: Tooltip(message: cat.name, child: Text(cat.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600))),
                              value: isChecked,
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
                    const SizedBox(height: SunfireSpacing.lg),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SunfireRadius.md)),
                      ),
                      onPressed: () async {
                        try {
                          final isSingle = _selectedMangaIds.length == 1;
                          final addedCats = selectedCatIds.difference(initialCommonCatIds);
                          final removedCats = initialCommonCatIds.difference(selectedCatIds);
                          final updatedManga = <Manga>[];
                          for (final id in _selectedMangaIds) {
                            final m = await _resolveManga(id);
                            if (m != null) {
                              if (isSingle) {
                                m.categoryIds = selectedCatIds.toList();
                              } else {
                                final curSet = m.categoryIds.toSet();
                                curSet.addAll(addedCats);
                                curSet.removeAll(removedCats);
                                m.categoryIds = curSet.toList();
                              }
                              updatedManga.add(m);
                              if (m.serverId > 0) {
                                await SyncEngine.instance.syncMangaCategories(m.serverId, m.categoryIds);
                              }
                            }
                          }
                          if (updatedManga.isNotEmpty) {
                            await IsarService.instance.saveMangas(updatedManga);
                          }
                          if (sheetContext.mounted) {
                            Navigator.pop(sheetContext);
                          }
                          _exitBatchMode();
                          await _loadFromIsarOnly();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Categories updated for selected titles')),
                            );
                          }
                        } catch (e, stack) {
                          unawaited(LoggerService.instance.logError('Batch category move failed: $e', exception: e, stackTrace: stack, category: 'Library'));
                          if (sheetContext.mounted) {
                            Navigator.pop(sheetContext);
                          }
                          _exitBatchMode();
                        }
                      },
                      child: Text('Apply Categories', style: TextStyle(fontWeight: FontWeight.bold, color: _cs.onPrimary)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Manga per chapter-batch query in the batch actions below. Bounds memory
  /// (all chapters of a chunk are held at once) while still replacing one Isar
  /// query per manga with one per chunk.
  static const int _batchChunkSize = 50;

  Future<void> _batchMarkRead(bool isRead) async {
    // Hoisted out of the chunk loop.
    //
    // The guard used to live inside `_markChunkRead`, so it fired once per
    // chunk and then `_batchMarkRead` overwrote that message with "Marked all
    // as read" regardless. With Incognito on and 50 titles selected, the user
    // was told the library was cleared when not a single badge had changed —
    // and worse, they could conclude Incognito was protecting them and later
    // turn it off assuming it never mattered. Matches the pattern
    // `updates_screen._markAllAsRead` already uses.
    if (SettingsService.instance.incognitoMode) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incognito Mode is on — reading state is not saved')),
        );
      }
      return;
    }
    final selectedIds = List<int>.from(_selectedMangaIds);
    final chaptersByManga = <int, List<Chapter>>{};
    for (var i = 0; i < selectedIds.length; i += _batchChunkSize) {
      final end = i + _batchChunkSize > selectedIds.length ? selectedIds.length : i + _batchChunkSize;
      chaptersByManga
        ..clear()
        ..addAll(await IsarService.instance.getChaptersForMangas(selectedIds.sublist(i, end)));
      await _markChunkRead(selectedIds.sublist(i, end), chaptersByManga, isRead);
    }
    _exitBatchMode();
    await _loadFromIsarOnly();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isRead ? 'Marked all as read' : 'Marked all as unread')),
      );
    }
  }

  Future<void> _markChunkRead(List<int> ids, Map<int, List<Chapter>> chaptersByManga, bool isRead) async {
    // Defence in depth: `_batchMarkRead` already bails before the loop, but
    // this method must stay safe for any other caller.
    if (SettingsService.instance.incognitoMode) return;
    for (final id in ids) {
      final chapters = chaptersByManga[id] ?? <Chapter>[];
      for (final ch in chapters) {
        ch.applyReadState(isRead);
        // Advance the read stamp for freshly-read chapters so History and
        // Library "Last Read" sorting pick the action up without a resync.
        if (isRead) await SyncEngine.instance.stampLocalReadActivity(ch);
      }
      // ISS-069: one bulk server call per manga instead of one per chapter.
      final serverIds = [for (final ch in chapters) if (ch.serverId > 0) ch.serverId];
      if (serverIds.isNotEmpty) {
        unawaited(SyncEngine.instance.syncChaptersProgressBulk(serverIds, isRead: isRead));
      }
      await IsarService.instance.saveChapters(chapters);
      final m = await _resolveManga(id);
      if (m != null) {
        m.unreadCount = isRead ? 0 : chapters.length;
        await IsarService.instance.saveManga(m);
      }
    }
  }

  Future<void> _batchDownloadMenu() async {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final selectedCount = _selectedMangaIds.length;
    if (selectedCount == 0) return;

    await showModalBottomSheet<void>(
      context: context,
      // UIS-ISS-012: theme surface (was hard-coded dark hex)
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(SunfireRadius.sheet))),
      builder: (sheetCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.download_rounded, color: primaryColor, size: SunfireIconSize.lg),
                    const SizedBox(width: 10),
                    Expanded(child: Text(
                      'Download ($selectedCount selected)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    )),
                  ],
                ),
                const SizedBox(height: 14),
                _buildDownloadOptionTile(sheetCtx, 'Next 1 Chapter', 1),
                _buildDownloadOptionTile(sheetCtx, 'Next 5 Chapters', 5),
                _buildDownloadOptionTile(sheetCtx, 'Next 10 Chapters', 10),
                _buildDownloadOptionTile(sheetCtx, 'All Unread Chapters', -1),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDownloadOptionTile(BuildContext sheetCtx, String title, int count) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.download_for_offline_outlined, color: Theme.of(sheetCtx).colorScheme.onSurfaceVariant),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      onTap: () {
        Navigator.pop(sheetCtx);
        unawaited(_executeBatchDownload(count));
      },
    );
  }

  Future<void> _executeBatchDownload(int maxPerManga) async {
    int totalQueued = 0;
    final mangaList = List<int>.from(_selectedMangaIds);

    final chaptersByManga = <int, List<Chapter>>{};
    for (var i = 0; i < mangaList.length; i++) {
      final mangaId = mangaList[i];
      // Load chapters a chunk at a time instead of one query per manga.
      if (i % _batchChunkSize == 0) {
        final end = i + _batchChunkSize > mangaList.length ? mangaList.length : i + _batchChunkSize;
        chaptersByManga
          ..clear()
          ..addAll(await IsarService.instance.getChaptersForMangas(mangaList.sublist(i, end)));
      }
      final m = await _resolveManga(mangaId);
      final chapters = List<Chapter>.of(chaptersByManga[mangaId] ?? const <Chapter>[]);
      chapters.sort((a, b) => a.chapterNumber.compareTo(b.chapterNumber));

      final unreadNotDownloaded = chapters.where((c) {
        if (c.isRead) return false;
        if (c.isDownloaded) return false;
        final cId = c.serverId != 0 ? c.serverId : c.id;
        if (DownloadManagerService.instance.isChapterDownloadedLocally(cId)) return false;
        return true;
      }).toList();

      final toQueue = maxPerManga == -1
          ? unreadNotDownloaded
          : unreadNotDownloaded.take(maxPerManga).toList();

      for (final ch in toQueue) {
        final cId = ch.serverId != 0 ? ch.serverId : ch.id;
        await DownloadManagerService.instance.enqueueLocalDownload(
          chapterId: cId,
          mangaId: mangaId,
          chapterName: ch.name,
          mangaTitle: m?.title ?? 'Manga',
          chapterNumber: ch.chapterNumber,
        );
        totalQueued++;
      }
    }

    _exitBatchMode();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            totalQueued > 0
                ? 'Queued $totalQueued chapters for download across ${mangaList.length} titles'
                : 'No unread chapters eligible for download',
          ),
        ),
      );
    }
  }

  Future<void> _batchRemoveFromLibrary() async {
    final count = _selectedMangaIds.length;
    if (count == 0) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        // UIS-ISS-012: theme surface (was hard-coded dark hex)
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SunfireRadius.dialog)),
        title: const DialogTitle(
          icon: Icons.delete_outline_rounded,
          iconColor: SunfireColors.error,
          text: 'Remove from Library',
        ),
        content: Text(
          'Remove $count selected ${count == 1 ? "title" : "titles"} from your library? This will not delete downloaded chapters.',
          style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: SunfireColors.contentTertiary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: SunfireColors.error,
              foregroundColor: SunfireColors.onTrackerAmber,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SunfireRadius.md)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    for (final id in _selectedMangaIds) {
      final m = await _resolveManga(id);
      if (m != null) {
        m.inLibrary = false;
        await IsarService.instance.saveManga(m);
        if (m.serverId > 0) {
          await SyncEngine.instance.syncMangaLibraryState(m.serverId, false);
        }
      }
    }
    _exitBatchMode();
    await _handleRefresh();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Removed $count titles from library')),
      );
    }
  }

  Widget _buildBatchActionDock(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final dockRow = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildBatchActionItem(
          icon: Icons.drive_file_move_outlined,
          label: 'Category',
          color: _cs.onSurfaceVariant,
          onTap: _batchMoveToCategory,
        ),
        _buildBatchActionItem(
          icon: Icons.done_all_rounded,
          label: 'Read',
          color: SunfireColors.success,
          onTap: () => _batchMarkRead(true),
        ),
        _buildBatchActionItem(
          icon: Icons.remove_done_rounded,
          label: 'Unread',
          color: _isLight ? SunfireColors.warning : SunfireColors.trackerAmber,
          onTap: () => _batchMarkRead(false),
        ),
        _buildBatchActionItem(
          icon: Icons.download_rounded,
          label: 'Download',
          color: _isLight ? SunfireColors.trackerBlue : SunfireColors.trackerBlueContainer,
          onTap: _batchDownloadMenu,
        ),
        _buildBatchActionItem(
          icon: Icons.delete_outline_rounded,
          label: 'Remove',
          color: SunfireColors.error,
          onTap: _batchRemoveFromLibrary,
        ),
      ],
    );

    return SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: _cs.shadow.withValues(alpha: _isLight ? 0.18 : 0.55),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: isIOS
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: _cs.surfaceContainer.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: _cs.outlineVariant.withValues(alpha: 0.4), width: 0.8),
                        ),
                        child: dockRow,
                      ),
                    ),
                  )
                : Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(32),
                    color: _cs.surfaceContainerHigh,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: _cs.outlineVariant.withValues(alpha: 0.4), width: 0.8),
                      ),
                      child: dockRow,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildBatchActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(SunfireRadius.pill),
      onTap: () {
        unawaited(HapticFeedback.selectionClick());
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(child: Icon(icon, color: color, size: SunfireIconSize.lg)),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: color.withValues(alpha: 0.9),
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryManagementDialog() {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final textController = TextEditingController();

    unawaited(showModalBottomSheet<void>(
      context: context,
      // UIS-ISS-012: theme surface (was hard-coded dark hex)
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(SunfireRadius.sheet))),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Edit Categories', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: SunfireSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: textController,
                          decoration: InputDecoration(
                            hintText: 'New category name...',
                            filled: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(SunfireRadius.md), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      const SizedBox(width: SunfireSpacing.sm),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SunfireRadius.md))),
                        onPressed: () async {
                          final name = textController.text.trim();
                          if (name.isNotEmpty) {
                            // Order must be max(existing)+1: using the list
                            // length can collide with an existing order after a
                            // deletion, which scrambles the tab ordering
                            // (getCategories sorts by `order`).
                            final maxOrder = _categories.fold<int>(
                              0,
                              (acc, c) => c.order > acc ? c.order : acc,
                            );
                            // serverId left 0: saveCategory mints a
                            // collision-checked synthetic id in place.
                            final newCat = Category()
                              ..name = name
                              ..order = maxOrder + 1;
                            await IsarService.instance.saveCategory(newCat);
                            await SyncEngine.instance.syncCategoryCreate(
                              name: name,
                              localServerId: newCat.serverId,
                              order: newCat.order,
                            );
                            // The sheet is swipe-dismissible and
                            // `whenComplete` disposes this controller the
                            // moment it closes, so after an await that can
                            // block for 30s (or unbounded in standalone mode)
                            // the sheet may be gone. `setSheetState` on an
                            // unmounted StatefulBuilder and `clear()` on a
                            // disposed controller are both hard crashes in
                            // release, not just assert failures.
                            if (!sheetContext.mounted) return;
                            textController.clear();
                            await _handleRefresh();
                            if (!sheetContext.mounted) return;
                            setSheetState(() {});
                          }
                        },
                        child: Text('Add', style: TextStyle(color: _cs.onPrimary, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: SunfireSpacing.lg),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 280),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        return ListTile(
                          title: Tooltip(message: cat.name, child: Text(cat.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600))),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: SunfireColors.error),
                            onPressed: () async {
                              await IsarService.instance.deleteCategory(cat.serverId);
                              await SyncEngine.instance.syncCategoryDelete(cat.serverId);
                              await _handleRefresh();
                              if (!sheetContext.mounted) return;
                              setSheetState(() {});
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() => textController.dispose()));
  }


  Future<void> _updateSelectedCategory(Category cat) async {
    if (!GraphQLClientService.instance.isConfigured) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connect a server to update a category'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final res = await GraphQLClientService.instance.updateLibraryForCategories([cat.serverId]);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          res != null
              ? 'Updating "${cat.name}" on server…'
              : 'Failed to start update for "${cat.name}"',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showCategoryChipMenu(Category cat) {
    unawaited(showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.refresh_rounded),
                title: Text('Update "${cat.name}"'),
                subtitle: Text(
                  'Run a server library update for this category only',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12.5),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  unawaited(_updateSelectedCategory(cat));
                },
              ),
            ],
          ),
        );
      },
    ));
  }

  int _getCategoryMangaCount(int catServerId) {
    return _allManga.where((m) => mangaBelongsToCategory(m.categoryIds, catServerId)).length;
  }

  /// True when any filter/display customization in the "Filter & Display" sheet
  /// is active (non-default). Drives the dot on the tune icon.
  bool get _hasCustomDisplay {
    return _statusFilter != 'All' ||
        _selectedTagId != null ||
        _settings.libraryDisplayMode != 'Comfortable Grid' ||
        _settings.gridColumnCount != 0 ||
        !_settings.showUnreadBadges ||
        !_settings.showDownloadedBadges ||
        _sortBy != 'Title' ||
        !_isSortAscending;
  }

  void _showSortAndDisplayDialog() {
    final primaryColor = Theme.of(context).colorScheme.primary;
unawaited(
    showModalBottomSheet<void>(
      context: context,
      // UIS-ISS-012: theme surface (was hard-coded dark hex)
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(SunfireRadius.sheet))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20.0),
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: _cs.onSurfaceVariant.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Library View & Sort', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        TextButton.icon(
                          icon: const Icon(Icons.bookmark_add_outlined, size: SunfireIconSize.std),
                          label: const Text('Save Preset', style: TextStyle(fontSize: 12)),
                          onPressed: () async {
                            final nameCtrl = TextEditingController();
                            final name = await showDialog<String>(
                              context: context,
                              builder: (dCtx) => AlertDialog(
                                title: const Text('Save Filter Preset'),
                                content: TextField(
                                  controller: nameCtrl,
                                  autofocus: true,
                                  decoration: const InputDecoration(hintText: 'Preset name (e.g. Unread Action)'),
                                ),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(dCtx), child: const Text('Cancel')),
                                  FilledButton(
                                    onPressed: () => Navigator.pop(dCtx, nameCtrl.text.trim()),
                                    child: const Text('Save'),
                                  ),
                                ],
                              ),
                            );
                            if (name != null && name.isNotEmpty) {
                              await saveLibraryFilter(
                                _settings,
                                SavedLibraryFilter(name, {
                                  'status': _statusFilter,
                                  'tagId': _selectedTagId,
                                  'displayMode': _settings.libraryDisplayMode,
                                  'columns': _settings.gridColumnCount,
                                  'showUnread': _settings.showUnreadBadges,
                                  'showDownloaded': _settings.showDownloadedBadges,
                                  'sortBy': _sortBy,
                                  'isSortAscending': _isSortAscending,
                                }),
                              );
                              setSheetState(() {});
                            }
                          },
                        ),
                      ],
                    ),
                    Builder(
                      builder: (ctx) {
                        final presets = loadSavedLibraryFilters(_settings);
                        if (presets.isEmpty) return const SizedBox.shrink();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SAVED PRESETS',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _cs.onSurfaceVariant, letterSpacing: 1),
                            ),
                            const SizedBox(height: SunfireSpacing.sm),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                for (final p in presets)
                                  InputChip(
                                    label: Text(p.name),
                                    onPressed: () {
                                      final q = p.query;
                                      setState(() {
                                        if (q['status'] is String) _statusFilter = q['status'] as String;
                                        _selectedTagId = q['tagId'] as int?;
                                        if (q['displayMode'] is String) _settings.libraryDisplayMode = q['displayMode'] as String;
                                        if (q['columns'] is int) _settings.gridColumnCount = q['columns'] as int;
                                        if (q['showUnread'] is bool) _settings.showUnreadBadges = q['showUnread'] as bool;
                                        if (q['showDownloaded'] is bool) _settings.showDownloadedBadges = q['showDownloaded'] as bool;
                                        if (q['sortBy'] is String) _sortBy = q['sortBy'] as String;
                                        if (q['isSortAscending'] is bool) _isSortAscending = q['isSortAscending'] as bool;
                                      });
                                      setSheetState(() {});
                                    },
                                    onDeleted: () async {
                                      await deleteLibraryFilter(_settings, p.name);
                                      setSheetState(() {});
                                    },
                                  ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: SunfireSpacing.lg),
                    Text('DISPLAY MODE', style: SunfireTypography.withColor(SunfireTypography.sectionHeader, SunfireColors.contentTertiary)),
                    const SizedBox(height: SunfireSpacing.sm),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ['Comfortable Grid', 'Compact Grid', 'Cover Only', 'List'].map((mode) {
                        final isSel = _settings.libraryDisplayMode == mode;
                        return ChoiceChip(
                          label: Text(mode),
                          selected: isSel,
                          selectedColor: primaryColor,
                          backgroundColor: SunfireTheme.tileSurface(context),
                          labelStyle: TextStyle(color: isSel ? _cs.onPrimary : _cs.onSurfaceVariant, fontWeight: isSel ? FontWeight.bold : FontWeight.normal),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SunfireRadius.pill), side: BorderSide(color: isSel ? primaryColor : SunfireTheme.tileBorder(context), width: 0.8)),
                          onSelected: (_) {
                            setState(() => _settings.libraryDisplayMode = mode);
                            setSheetState(() {});
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: SunfireSpacing.lg),
                    Text('GRID COLUMNS', style: SunfireTypography.withColor(SunfireTypography.sectionHeader, SunfireColors.contentTertiary)),
                    const SizedBox(height: SunfireSpacing.sm),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        {'label': 'Auto', 'val': 0},
                        {'label': '2', 'val': 2},
                        {'label': '3', 'val': 3},
                        {'label': '4', 'val': 4},
                        {'label': '5', 'val': 5},
                        {'label': '6', 'val': 6},
                      ].map((item) {
                        final isSel = _settings.gridColumnCount == (item['val'] as int);
                        return ChoiceChip(
                          label: Text(item['label'] as String),
                          selected: isSel,
                          selectedColor: primaryColor,
                          backgroundColor: SunfireTheme.tileSurface(context),
                          labelStyle: TextStyle(color: isSel ? _cs.onPrimary : _cs.onSurfaceVariant, fontWeight: isSel ? FontWeight.bold : FontWeight.normal),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SunfireRadius.pill), side: BorderSide(color: isSel ? primaryColor : SunfireTheme.tileBorder(context), width: 0.8)),
                          onSelected: (_) {
                            setState(() => _settings.gridColumnCount = item['val'] as int);
                            setSheetState(() {});
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: SunfireSpacing.lg),
                    Text('BADGES & INDICATORS', style: SunfireTypography.withColor(SunfireTypography.sectionHeader, SunfireColors.contentTertiary)),
                    const SizedBox(height: SunfireSpacing.sm),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilterChip(
                          label: const Text('Unread Count'),
                          selected: _settings.showUnreadBadges,
                          selectedColor: primaryColor.withAlpha(80),
                          checkmarkColor: _cs.onSurface,
                          onSelected: (val) {
                            setState(() => _settings.showUnreadBadges = val);
                            setSheetState(() {});
                          },
                        ),
                        FilterChip(
                          label: const Text('Downloaded Check'),
                          selected: _settings.showDownloadedBadges,
                          selectedColor: primaryColor.withAlpha(80),
                          checkmarkColor: _cs.onSurface,
                          onSelected: (val) {
                            setState(() => _settings.showDownloadedBadges = val);
                            setSheetState(() {});
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: SunfireSpacing.lg),
                    Text('FILTER BY STATUS', style: SunfireTypography.withColor(SunfireTypography.sectionHeader, SunfireColors.contentTertiary)),
                    const SizedBox(height: SunfireSpacing.sm),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ['All', 'Unread', 'Downloaded', 'Completed'].map((filter) {
                        final isSel = _statusFilter == filter;
                        return ChoiceChip(
                          label: Text(filter),
                          selected: isSel,
                          selectedColor: primaryColor,
                          backgroundColor: SunfireTheme.tileSurface(context),
                          labelStyle: TextStyle(color: isSel ? _cs.onPrimary : _cs.onSurfaceVariant, fontWeight: isSel ? FontWeight.bold : FontWeight.normal),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SunfireRadius.pill), side: BorderSide(color: isSel ? primaryColor : SunfireTheme.tileBorder(context), width: 0.8)),
                          onSelected: (_) {
                            setState(() => _statusFilter = filter);
                            setSheetState(() {});
                          },
                        );
                      }).toList(),
                    ),
                    if (_tags.isNotEmpty) ...[
                      const SizedBox(height: SunfireSpacing.lg),
                      Text('FILTER BY TAG', style: SunfireTypography.withColor(SunfireTypography.sectionHeader, SunfireColors.contentTertiary)),
                      const SizedBox(height: SunfireSpacing.sm),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ChoiceChip(
                            label: Text(
                              'All (${_allManga.length})',
                            ),
                            selected: _selectedTagId == null,
                            selectedColor: primaryColor,
                            backgroundColor: SunfireTheme.tileSurface(context),
                            labelStyle: TextStyle(
                              color: _selectedTagId == null
                                  ? _cs.onPrimary
                                  : _cs.onSurfaceVariant,
                              fontWeight: _selectedTagId == null
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            onSelected: (_) {
                              setState(() => _selectedTagId = null);
                              setSheetState(() {});
                            },
                          ),
                          ..._tags.map((tag) {
                            final count = countMangaWithTag(
                              _allManga.map((m) => m.tagIds),
                              tag.id,
                            );
                            final selected = _selectedTagId == tag.id;
                            return ChoiceChip(
                              label: Text('${tag.name} ($count)'),
                              selected: selected,
                              selectedColor: primaryColor,
                              backgroundColor: SunfireTheme.tileSurface(context),
                              labelStyle: TextStyle(
                                color: selected
                                    ? _cs.onPrimary
                                    : _cs.onSurfaceVariant,
                                fontWeight: selected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              onSelected: (_) {
                                setState(() => _selectedTagId = tag.id);
                                setSheetState(() {});
                              },
                            );
                          }),
                        ],
                      ),
                    ],
                    const SizedBox(height: SunfireSpacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('SORT BY', style: SunfireTypography.withColor(SunfireTypography.sectionHeader, SunfireColors.contentTertiary)),
                        IconButton(
                          icon: Icon(_isSortAscending ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, size: SunfireIconSize.md, color: primaryColor),
                          onPressed: () {
                            setState(() => _isSortAscending = !_isSortAscending);
                            setSheetState(() {});
                          },
                        ),
                      ],
                    ),
                    ListTile(
                      title: const Text('Title (Alphabetical)'),
                      trailing: _sortBy == 'Title' ? Icon(Icons.check_rounded, color: primaryColor) : null,
                      onTap: () {
                        setState(() {
                          _sortBy = 'Title';
                          _isSortAscending = true;
                        });
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: const Text('Unread Count'),
                      trailing: _sortBy == 'Unread' ? Icon(Icons.check_rounded, color: primaryColor) : null,
                      onTap: () {
                        setState(() {
                          _sortBy = 'Unread';
                          _isSortAscending = false;
                        });
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: const Text('Recently Added'),
                      trailing: _sortBy == 'Recent' ? Icon(Icons.check_rounded, color: primaryColor) : null,
                      onTap: () {
                        setState(() {
                          _sortBy = 'Recent';
                          _isSortAscending = false;
                        });
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: const Text('Last Read'),
                      trailing: _sortBy == 'Last Read' ? Icon(Icons.check_rounded, color: primaryColor) : null,
                      onTap: () {
                        setState(() {
                          _sortBy = 'Last Read';
                          _isSortAscending = false;
                        });
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: const Text('Total Chapters'),
                      trailing: _sortBy == 'Chapters' ? Icon(Icons.check_rounded, color: primaryColor) : null,
                      onTap: () {
                        setState(() {
                          _sortBy = 'Chapters';
                          _isSortAscending = false;
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ],
                );
              },
);
          },
        );
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final primaryColor = Theme.of(context).colorScheme.primary;
    final displayManga = _filteredManga;
    final displayMode = _settings.libraryDisplayMode;
    final isCoverOnly = displayMode == 'Cover Only';
    final isCompact = displayMode == 'Compact Grid';
    final isList = displayMode == 'List';
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= SunfireBreakpoints.narrowTabletMaxWidth;
    // UIS-02: real bar height (shell extendBody) + room for the batch dock.
    final bottomPadding = SunfireBreakpoints.scrollBottomPadding(context, extra: _isBatchMode ? 96 : 16);
    final horizontalPadding = isTablet ? 24.0 : 16.0;
    
    final columnsSetting = _settings.gridColumnCount;

    return PopScope(
      canPop: !_isBatchMode && !_isSearching,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_isBatchMode) {
          _exitBatchMode();
        } else if (_isSearching) {
          setState(() {
            _isSearching = false;
            _searchQuery = '';
          });
        }
      },
      child: Scaffold(
      appBar: AppBar(
        toolbarHeight: isTablet ? 64.0 : kToolbarHeight,
        title: _isBatchMode
            ? Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: _exitBatchMode,
                  ),
                  Expanded(child: Text('${_selectedMangaIds.length} Selected', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                  const Spacer(),
                  TextButton(
                    onPressed: _selectAll,
                    child: Text(_selectedMangaIds.length == displayManga.length ? 'Deselect All' : 'Select All', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                  ),
                ],
              )
            : _isSearching
                ? TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Search library...',
                      prefixIcon: Icon(Icons.search_rounded, color: primaryColor),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => setState(() {
                          _isSearching = false;
                          _searchQuery = '';
                        }),
                      ),
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(SunfireRadius.lg), borderSide: BorderSide.none),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  )
                : Text('Library', style: SunfireTypography.withWeight(SunfireTypography.headlineMedium, FontWeight.bold)),
        actions: _isBatchMode
            ? null
            : [
                if (_isSyncing)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                if (!_isSearching) ...[
                  IconButton(
                    icon: const Icon(Icons.search_rounded, size: SunfireIconSize.lg),
                    onPressed: () => setState(() => _isSearching = true),
                  ),
                  IconButton(
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(Icons.tune_rounded, size: SunfireIconSize.lg),
                        if (_hasCustomDisplay)
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                            ),
                          ),
                      ],
                    ),
                    tooltip: 'Filter & Display',
                    onPressed: _showSortAndDisplayDialog,
                  ),
                  IconButton(
                    icon: const Icon(Icons.label_outline_rounded, size: SunfireIconSize.lg),
                    tooltip: 'Categories',
                    onPressed: _showCategoryManagementDialog,
                  ),
                  ListenableBuilder(
                    listenable: DownloadManagerService.instance,
                    builder: (context, _) {
                      final activeCount = DownloadManagerService.instance.localTasks
                          .where((t) => t.status == LocalDownloadStatus.downloading || t.status == LocalDownloadStatus.queued)
                          .length;
                      return IconButton(
                        icon: Badge(
                          isLabelVisible: activeCount > 0,
                          label: Text('$activeCount', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          child: const Icon(Icons.download_rounded, size: SunfireIconSize.lg),
                        ),
                        tooltip: 'Downloads Queue',
                        onPressed: () => context.push('/downloads'),
                      );
                    },
                  ),
                ],
              ],
        bottom: !_settings.showCategoryTabs || _categories.isEmpty
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(52),
                child: Container(
                  height: 44,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    itemCount: _categories.length + 1,
              itemBuilder: (context, index) {
                final isSelected = _selectedCategoryIndex == index;
                final count = index == 0 ? _allManga.length : _getCategoryMangaCount(_categories[index - 1].serverId);
                final label = index == 0 ? 'All ($count)' : '${_categories[index - 1].name} ($count)';
                final chip = ChoiceChip(
                  label: Text(label),
                  selected: isSelected,
                  selectedColor: primaryColor,
                  backgroundColor: SunfireTheme.tileSurface(context),
                  showCheckmark: false,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  labelStyle: TextStyle(
                    color: isSelected ? _cs.onPrimary : _cs.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(SunfireRadius.pill),
                    side: BorderSide(
                      color: isSelected ? primaryColor : SunfireTheme.tileBorder(context),
                      width: isSelected ? 1.2 : 0.8,
                    ),
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedCategoryIndex = index);
                    }
                  },
                );
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: index == 0
                      ? chip
                      : GestureDetector(
                          onLongPress: () => _showCategoryChipMenu(_categories[index - 1]),
                          child: chip,
                        ),
                );
              },
            ),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final canvasWidth = constraints.maxWidth;
          final int crossAxisCount = columnsSetting > 0
              ? columnsSetting
              : (isTablet
                  ? (canvasWidth / 175.0).floor().clamp(3, 6)
                  : (canvasWidth / 120.0).floor().clamp(2, 4));
          final childAspectRatio = isCoverOnly
              ? 0.70
              : (isCompact ? 0.70 : (isTablet ? 0.61 : 0.65));

          return Stack(
            children: [
              RefreshIndicator(
            color: primaryColor,
            onRefresh: _handleRefresh,
            child: _isLoading && _filteredManga.isEmpty
                // S6.1: skeleton grid on cold start instead of a bare
                // spinner, so first paint already shows layout shape.
                // When refreshing with data visible, keep the list.
                ? SunfireSkeletonGrid(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: childAspectRatio,
                  )
                : CustomScrollView(
                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    scrollCacheExtent: ScrollCacheExtent.pixels(800),
                    slivers: [
                      if (_isOffline && GraphQLClientService.instance.isConfigured)
                        SliverToBoxAdapter(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: SunfireColors.trackerAmber.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(SunfireRadius.md),
                              border: Border.all(color: SunfireColors.trackerAmber.withValues(alpha: 0.3), width: 0.8),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.wifi_off_rounded, color: SunfireColors.trackerAmber, size: SunfireIconSize.sm),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Offline — Showing cached library',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: SunfireColors.trackerAmber, fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      LibraryUpdateProgressBanner(
                        asSliver: true,
                        margin: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: 6,
                        ),
                      ),
                      // S6.1: hero stats strip — total titles, unread chapter
                      // count, reading-progress bar. Shown only when the
                      // library is non-empty and no text search query is active
                      // (search replaces it with result-count which is more
                      // informative in that state).
                      if (_allManga.isNotEmpty && _searchQuery.isEmpty)
                        SliverToBoxAdapter(
                          child: _LibraryHeroStats(
                            allManga: _allManga,
                            horizontalPadding: horizontalPadding,
                          ),
                        ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 6),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: ['All', 'Unread', 'Downloaded', 'Completed'].map((filter) {
                                final isSel = _statusFilter == filter;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 6.0),
                                  child: FilterChip(
                                    label: Text(filter),
                                    selected: isSel,
                                    showCheckmark: false,
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                                    visualDensity: VisualDensity.compact,
                                    selectedColor: primaryColor.withValues(alpha: 0.25),
                                    backgroundColor: SunfireTheme.tileSurface(context),
                                    labelStyle: TextStyle(
                                      color: isSel ? primaryColor : SunfireColors.contentDisabled,
                                      fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                      fontSize: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(SunfireRadius.pill),
                                      side: BorderSide(
                                        color: isSel ? primaryColor.withValues(alpha: 0.6) : SunfireTheme.tileBorder(context),
                                        width: 0.8,
                                      ),
                                    ),
                                    onSelected: (_) {
                                      setState(() => _statusFilter = filter);
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                      if (displayManga.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: EmptyStateWidget(
                            icon: _searchQuery.isNotEmpty || _statusFilter != 'All' || _selectedCategoryIndex > 0
                                ? Icons.filter_alt_off_rounded
                                : Icons.auto_stories_rounded,
                            title: _loadError != null
                                ? 'Could not load your library'
                                : _searchQuery.isNotEmpty
                                    ? 'No Results Found'
                                    : (_statusFilter != 'All' || _selectedCategoryIndex > 0)
                                        ? 'Nothing Matches This Filter'
                                        : 'Your Library is Empty',
                            subtitle: _loadError != null
                                ? 'The local database could not be read. Your data is '
                                    'probably still there — try again.'
                                : _searchQuery.isNotEmpty
                                    ? 'Try adjusting your search query.'
                                    : (_statusFilter != 'All' || _selectedCategoryIndex > 0)
                                        ? 'Clear status or category filters to see more titles.'
                                        : 'Browse extensions to find and add manga to your library.',
                            actionLabel: _loadError != null
                                ? 'Retry'
                                : (_searchQuery.isNotEmpty || _statusFilter != 'All' || _selectedCategoryIndex > 0)
                                    ? 'Clear Filters'
                                    : 'Browse Sources',
                            onAction: () {
                              // A failed load retries; it does not navigate away
                              // from the data the user already has.
                              if (_loadError != null) {
                                unawaited(_loadFromIsarOnly());
                                return;
                              }
                              if (_searchQuery.isNotEmpty || _statusFilter != 'All' || _selectedCategoryIndex > 0) {
                                setState(() {
                                  _searchQuery = '';
                                  _isSearching = false;
                                  _statusFilter = 'All';
                                  _selectedCategoryIndex = 0;
                                });
                              } else {
                                MainShell.switchToTab(3);
                              }
                            },
                          ),
                        )
                      else if (isList)
                        SliverPadding(
                          padding: EdgeInsets.only(left: horizontalPadding, right: horizontalPadding, top: 8, bottom: bottomPadding),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => _buildMangaListItem(displayManga[index]),
                              childCount: displayManga.length,
                              addAutomaticKeepAlives: true,
                              addRepaintBoundaries: true,
                              addSemanticIndexes: false,
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: EdgeInsets.only(left: horizontalPadding, right: horizontalPadding, top: 8, bottom: bottomPadding),
                          sliver: SliverGrid(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              childAspectRatio: childAspectRatio,
                              crossAxisSpacing: isTablet ? 16 : 12,
                              mainAxisSpacing: isTablet ? 20 : 16,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => _buildMangaCard(
                                displayManga[index],
                                isCompact: isCompact,
                                isCoverOnly: isCoverOnly,
                                isTablet: isTablet,
                              ),
                              childCount: displayManga.length,
                              addAutomaticKeepAlives: true,
                              addRepaintBoundaries: true,
                              addSemanticIndexes: false,
                            ),
                          ),
                        ),
                    ],
                  ),
              ),
              if (_isBatchMode)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: isTablet ? 24.0 : 16.0,
                  child: _buildBatchActionDock(context),
                ),
            ],
          );
        },
      ),
      ),
    );
  }

  /// Short uppercase language code for badges, or null for default English/
  /// universal manga that doesn't warrant a badge.
  String? _languageBadgeLabel(String lang) {
    if (!SettingsService.instance.showLanguageBadges) return null;
    return SettingsService.languageBadgeLabel(lang);
  }

  Widget _buildMangaCard(Manga manga, {bool isCompact = false, bool isCoverOnly = false, bool isTablet = false}) {
    final mId = manga.canonicalKey;
    final isSelected = _selectedMangaIds.contains(mId);
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isDownloaded = DownloadManagerService.instance.downloadedMangaIds.contains(mId);
    final langBadge = _languageBadgeLabel(manga.lang);

    return RepaintBoundary(
      child: Material(
        color: SunfireColors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(SunfireRadius.lg),
          onTap: () async {
            if (_isBatchMode) {
              _toggleBatchSelection(mId);
            } else {
              await context.push('/manga/$mId');
              if (mounted) {
                await _loadFromIsarOnly();
              }
            }
          },
          onLongPress: () => _toggleBatchSelection(mId),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(SunfireRadius.lg),
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        border: Border.all(
                          color: isSelected
                              ? primaryColor
                              : Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4),
                          width: isSelected ? 2.5 : 0.8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: SunfireColors.overlayScrim.withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(SunfireRadius.md),
                        child: MangaCoverImage(
                          mangaServerId: mId,
                          thumbnailUrl: manga.thumbnailUrl,
                          sourceName: manga.sourceName,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    if (isCompact && !isSelected)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(8, 6, 8, 10),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [SunfireColors.transparent, SunfireColors.overlayScrim, SunfireColors.overlayScrim],
                              stops: [0.0, 0.5, 1.0],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
                          ),
                          child: Text(
                            manga.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: SunfireTypography.withColor(SunfireTypography.mangaTitle, SunfireColors.contentPrimary),
                          ),
                        ),
                      ),
                    if (isSelected)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                          child: Icon(Icons.check_rounded, size: SunfireIconSize.sm, color: _cs.onPrimary),
                        ),
                      ),
                    if (_settings.showUnreadBadges && (manga.unreadCount ?? 0) > 0 && !isSelected)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: SunfireColors.overlayScrim.withValues(alpha: 0.5),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            '${manga.unreadCount}',
                            style: TextStyle(color: _cs.onPrimary, fontSize: 10.5, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    if (langBadge != null && !isSelected)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: SunfireColors.sourceLocalJs.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: SunfireColors.overlayScrim.withValues(alpha: 0.45),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Text(
                            langBadge,
                            style: SunfireTypography.withColor(SunfireTypography.languageBadge, SunfireColors.onTrackerAmber),
                          ),
                        ),
                      ),
                    if (_settings.showDownloadedBadges && isDownloaded && !isSelected)
                      Positioned(
                        top: langBadge != null ? 34 : 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: SunfireColors.success.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(SunfireRadius.sm),
                            boxShadow: [
                              BoxShadow(
                                color: SunfireColors.overlayScrim.withValues(alpha: 0.4),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.download_done_rounded, size: SunfireIconSize.xs, color: SunfireColors.onTrackerAmber),
                        ),
                      ),
                    if (isCoverOnly && !isSelected)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [SunfireColors.transparent, SunfireColors.overlayScrim],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
                          ),
                          child: Text(
                            manga.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: SunfireColors.onTrackerAmber),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (!isCompact && !isCoverOnly) ...[
                const SizedBox(height: 6),
                Text(
                  manga.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: isTablet ? 13.5 : 12.5,
                    height: 1.25,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMangaListItem(Manga manga) {
    final mId = manga.canonicalKey;
    final isSelected = _selectedMangaIds.contains(mId);
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isDownloaded = DownloadManagerService.instance.downloadedMangaIds.contains(mId);
    final langBadge = _languageBadgeLabel(manga.lang);

    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Material(
          color: isSelected ? primaryColor.withAlpha(40) : SunfireTheme.tileSurface(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SunfireRadius.md),
            side: BorderSide(color: isSelected ? primaryColor : SunfireTheme.tileBorder(context), width: 0.8),
          ),
          child: ListTile(
            onTap: () async {
              if (_isBatchMode) {
                _toggleBatchSelection(mId);
              } else {
                await context.push('/manga/$mId');
                if (mounted) {
                  await _loadFromIsarOnly();
                }
              }
            },
            onLongPress: () => _toggleBatchSelection(mId),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(SunfireRadius.sm),
              child: MangaCoverImage(
                mangaServerId: mId,
                thumbnailUrl: manga.thumbnailUrl,
                sourceName: manga.sourceName,
                width: 40,
                height: 56,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(manga.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Row(
              children: [
                Flexible(child: Text(manga.sourceName, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: SunfireColors.contentTertiary, fontSize: 12))),
                if (langBadge != null) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: _cs.onSurface.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(langBadge, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: _cs.onSurfaceVariant, letterSpacing: 0.4)),
                  ),
                ],
                if (isDownloaded && _settings.showDownloadedBadges) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.download_done_rounded, size: SunfireIconSize.xs, color: SunfireColors.success),
                ],
              ],
            ),
            trailing: _settings.showUnreadBadges && manga.unreadCount != null && manga.unreadCount! > 0
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(10)),
                    child: Text('${manga.unreadCount}', style: TextStyle(color: _cs.onPrimary, fontSize: 11, fontWeight: FontWeight.bold)),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

/// S6.1: Hero stats header for the library screen.
/// Displays total manga count, unread chapters count, and reading progress summary.
/// Uses only theme tokens (ColorScheme/Theme) to strictly obey raw color lint rules.
class _LibraryHeroStats extends StatelessWidget {
  final List<Manga> allManga;
  final double horizontalPadding;

  const _LibraryHeroStats({
    required this.allManga,
    required this.horizontalPadding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final totalTitles = allManga.length;

    int totalUnread = 0;
    int totalChapters = 0;
    int completedTitles = 0;

    for (final m in allManga) {
      totalUnread += m.unreadCount ?? 0;
      totalChapters += m.chapterCount;
      if ((m.status ?? '').toLowerCase() == 'completed') {
        completedTitles++;
      }
    }

    final readChapters = (totalChapters - totalUnread).clamp(0, totalChapters);
    final readPercentage = totalChapters > 0
        ? (readChapters / totalChapters).clamp(0.0, 1.0)
        : 0.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 6.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: SunfireTheme.tileSurface(context),
          borderRadius: BorderRadius.circular(SunfireRadius.lg),
          border: Border.all(
            color: SunfireTheme.tileBorder(context),
            width: 0.8,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _StatColumn(
                    label: 'Titles',
                    value: '$totalTitles',
                    subtext: completedTitles > 0 ? '$completedTitles done' : null,
                  ),
                ),
                Container(
                  width: 1,
                  height: 32,
                  color: cs.outlineVariant.withValues(alpha: 0.4),
                ),
                Expanded(
                  child: _StatColumn(
                    label: 'Unread',
                    value: '$totalUnread',
                    valueColor: totalUnread > 0 ? cs.primary : null,
                  ),
                ),
                Container(
                  width: 1,
                  height: 32,
                  color: cs.outlineVariant.withValues(alpha: 0.4),
                ),
                Expanded(
                  child: _StatColumn(
                    label: 'Progress',
                    value: '${(readPercentage * 100).toInt()}%',
                    subtext: '$readChapters/$totalChapters ch',
                  ),
                ),
              ],
            ),
            if (totalChapters > 0) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(SunfireRadius.xs),
                child: LinearProgressIndicator(
                  value: readPercentage,
                  minHeight: 4,
                  backgroundColor: cs.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final String? subtext;

  const _StatColumn({
    required this.label,
    required this.value,
    this.valueColor,
    this.subtext,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor ?? cs.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (subtext != null) ...[
          const SizedBox(height: 1),
          Text(
            subtext!,
            style: TextStyle(
              fontSize: 10,
              color: cs.outline,
            ),
          ),
        ],
      ],
    );
  }
}
