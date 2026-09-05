import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../core/db/isar_service.dart';
import '../../core/db/models/chapter.dart';
import '../../core/engine/content_resolver_service.dart';
import '../../core/engine/javascript/m_client.dart';
import '../../core/engine/quickjs_service.dart';
import '../../core/services/download_manager_service.dart';
import '../../core/services/settings_service.dart';
import '../../core/sync/graphql_client_service.dart';
import '../settings/advanced_settings_screen.dart';

enum ReadingMode { longStrip, longStripGaps, pagedLtr, pagedRtl }
enum ReaderThemeMode { black, darkGray, white }
enum ReaderColorFilter { none, invert, grayscale, nightAmber, sepia }
enum ImageScaleType { fitWidth, fitHeight, fitScreen, original }

class ReaderScreen extends StatefulWidget {
  final int chapterServerId;
  const ReaderScreen({super.key, required this.chapterServerId});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  final SettingsService _settings = SettingsService.instance;
  String? _sourceName;
  Chapter? _chapter;
  Chapter? _nextChapter;
  Chapter? _prevChapter;
  List<Chapter> _siblingChapters = [];
  List<String> _pageUrls = [];
  final Map<String, Uint8List> _recoveredImageBytes = {};
  final Set<String> _recoveringUrls = {};
  bool _isLoading = true;
  bool _showControls = true;
  int _currentPage = 1;

  // Zoom & Gestures
  bool _isZoomed = false;
  TapDownDetails? _doubleTapDetails;
  final TransformationController _transformationController = TransformationController();

  // Floating scroll indicator for Webtoon mode
  Timer? _scrollIndicatorTimer;
  bool _showScrollIndicator = false;

  // Prefetch cache: chapterServerId → resolved page URLs
  final Map<int, List<String>> _prefetchedChapters = {};
  final Set<int> _prefetchingChapters = {};

  late ReadingMode _readingMode;
  late ReaderThemeMode _readerTheme;
  late ReaderColorFilter _colorFilter;
  late ImageScaleType _scaleType;
  late bool _cropBorders;
  late bool _invertTaps;

  final ScrollController _scrollController = ScrollController();
  late PageController _pageController;
  Timer? _progressDebounceTimer;
  late int _currentChapterId;

  // iOS Hardware Volume Rocker Turn
  double? _lastIosVolume;
  DateTime _lastIosVolumeTurnTime = DateTime.now();

  // Hands-free Webtoon Auto-Scroll
  bool _isAutoScrolling = false;
  double _autoScrollSpeed = 35.0; // px/sec
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _currentChapterId = widget.chapterServerId;
    _pageController = PageController();
    _initPreferences();
    if (_settings.keepScreenAwake) {
      _safeSetWakelock(true);
    }
    _scrollController.addListener(_onVerticalScroll);
    if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) {
      _initIosVolumeListener();
    }
    _loadChapterAndPages(widget.chapterServerId);
  }

  void _initIosVolumeListener() {
    try {
      VolumeController.instance.showSystemUI = false;
      VolumeController.instance.getVolume().then((v) => _lastIosVolume = v);
      VolumeController.instance.addListener((volume) {
        if (!_settings.volumeKeyTurn || !mounted) return;
        final now = DateTime.now();
        if (now.difference(_lastIosVolumeTurnTime).inMilliseconds < 280) return;
        if (_lastIosVolume != null) {
          if (volume > _lastIosVolume!) {
            _lastIosVolumeTurnTime = now;
            _goToPrevPage();
          } else if (volume < _lastIosVolume!) {
            _lastIosVolumeTurnTime = now;
            _goToNextPage();
          }
        }
        _lastIosVolume = volume;
      });
    } catch (_) {}
  }

  void _toggleAutoScroll() {
    setState(() {
      _isAutoScrolling = !_isAutoScrolling;
      if (_isAutoScrolling) {
        _startAutoScroll();
      } else {
        _stopAutoScroll();
      }
    });
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 25), (_) {
      if (!_isAutoScrolling || !mounted || !_scrollController.hasClients) {
        _stopAutoScroll();
        return;
      }
      final max = _scrollController.position.maxScrollExtent;
      final cur = _scrollController.offset;
      if (max > 50 && cur >= max - 10) {
        _stopAutoScroll();
        if (_nextChapter != null) {
          _loadChapterAndPages(_nextChapter!.serverId);
        }
        return;
      }
      final step = _autoScrollSpeed * 0.025;
      _scrollController.jumpTo((cur + step).clamp(0.0, max));
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
    if (_isAutoScrolling && mounted) {
      setState(() => _isAutoScrolling = false);
    }
  }

  void _showAutoScrollSpeedDialog() {
    final primaryColor = Theme.of(context).colorScheme.primary;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141419),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Auto-Scroll Speed', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${_autoScrollSpeed.round()} px/s', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: primaryColor)),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              icon: const Icon(Icons.bookmark_border_rounded, size: 14, color: Colors.amberAccent),
                              label: const Text('Save Default', style: TextStyle(fontSize: 11, color: Colors.amberAccent)),
                              onPressed: () {
                                _settings.defaultAutoScrollSpeed = _autoScrollSpeed;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Default auto-scroll speed set to ${_autoScrollSpeed.round()} px/s'),
                                    duration: const Duration(seconds: 1),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Slider(
                      value: _autoScrollSpeed.clamp(10.0, 1000.0),
                      min: 10.0,
                      max: 1000.0,
                      divisions: 99,
                      activeColor: primaryColor,
                      label: '${_autoScrollSpeed.round()} px/s',
                      onChanged: (val) {
                        setState(() => _autoScrollSpeed = val);
                        setSheetState(() {});
                      },
                    ),
                    const SizedBox(height: 8),
                    const Text('Quick Presets', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildSpeedChip('Slow (25 px/s)', 25.0, primaryColor, setSheetState),
                        _buildSpeedChip('Normal (50 px/s)', 50.0, primaryColor, setSheetState),
                        _buildSpeedChip('Fast (120 px/s)', 120.0, primaryColor, setSheetState),
                        _buildSpeedChip('⚡ Faster (250 px/s)', 250.0, primaryColor, setSheetState),
                        _buildSpeedChip('🚀 Turbo (500 px/s)', 500.0, primaryColor, setSheetState),
                        _buildSpeedChip('💨 Hyper (800 px/s)', 800.0, primaryColor, setSheetState),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSpeedChip(String label, double speed, Color primaryColor, StateSetter setSheetState) {
    final isSelected = (_autoScrollSpeed - speed).abs() < 5.0;
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.white70)),
      selected: isSelected,
      selectedColor: primaryColor.withValues(alpha: 0.35),
      backgroundColor: const Color(0x1FFFFFFF),
      side: BorderSide(color: isSelected ? primaryColor : Colors.white24, width: 0.8),
      onSelected: (_) {
        setState(() => _autoScrollSpeed = speed);
        setSheetState(() {});
      },
    );
  }

  void _safeSetWakelock(bool enable) {
    try {
      if (enable) {
        unawaited(WakelockPlus.enable().catchError((_) {}));
      } else {
        unawaited(WakelockPlus.disable().catchError((_) {}));
      }
    } catch (_) {}
  }

  void _scrollVerticalBy(double delta) {
    if (!_scrollController.hasClients) return;
    try {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentOffset = _scrollController.offset;
      final target = (currentOffset + delta).clamp(0.0, maxScroll);
      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    } catch (_) {}
  }

  void _initPreferences() {
    _readingMode = _parseReadingMode(_settings.readingMode);
    _readerTheme = _parseReaderTheme(_settings.readerTheme);
    _colorFilter = _parseColorFilter(_settings.colorFilter);
    _scaleType = _parseScaleType(_settings.scaleType);
    _cropBorders = _settings.cropBorders;
    _invertTaps = _settings.invertTapZones;
    _autoScrollSpeed = _settings.defaultAutoScrollSpeed;
  }

  ReadingMode _parseReadingMode(String str) {
    switch (str.toLowerCase()) {
      case 'long strip (gaps)':
      case 'long strip gaps':
      case 'continuous vertical':
        return ReadingMode.longStripGaps;
      case 'paged ltr':
      case 'paged left-to-right':
        return ReadingMode.pagedLtr;
      case 'paged rtl':
      case 'paged rtl (manga)':
      case 'paged right-to-left':
        return ReadingMode.pagedRtl;
      case 'long strip':
      case 'webtoon':
      default:
        return ReadingMode.longStrip;
    }
  }

  ReaderThemeMode _parseReaderTheme(String str) {
    switch (str.toLowerCase()) {
      case 'dark gray':
      case 'gray':
        return ReaderThemeMode.darkGray;
      case 'white':
        return ReaderThemeMode.white;
      default:
        return ReaderThemeMode.black;
    }
  }

  ReaderColorFilter _parseColorFilter(String str) {
    switch (str.toLowerCase()) {
      case 'invert':
      case 'invert colors':
        return ReaderColorFilter.invert;
      case 'grayscale':
        return ReaderColorFilter.grayscale;
      case 'amber tint':
      case 'night amber':
        return ReaderColorFilter.nightAmber;
      case 'sepia':
        return ReaderColorFilter.sepia;
      default:
        return ReaderColorFilter.none;
    }
  }

  ImageScaleType _parseScaleType(String str) {
    switch (str.toLowerCase()) {
      case 'fit height':
        return ImageScaleType.fitHeight;
      case 'fit screen':
        return ImageScaleType.fitScreen;
      case 'original':
        return ImageScaleType.original;
      default:
        return ImageScaleType.fitWidth;
    }
  }

  final FocusNode _focusNode = FocusNode();

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final key = event.logicalKey;
    final isPaged = _readingMode == ReadingMode.pagedLtr || _readingMode == ReadingMode.pagedRtl;
    final isRtl = _readingMode == ReadingMode.pagedRtl;

    if (key == LogicalKeyboardKey.arrowRight || key == LogicalKeyboardKey.keyD) {
      if (isRtl) {
        _goToPrevPage();
      } else {
        _goToNextPage();
      }
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.arrowLeft || key == LogicalKeyboardKey.keyA) {
      if (isRtl) {
        _goToNextPage();
      } else {
        _goToPrevPage();
      }
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.space || key == LogicalKeyboardKey.pageDown) {
      if (isPaged) {
        if (isRtl) {
          _goToPrevPage();
        } else {
          _goToNextPage();
        }
      } else {
        _scrollVerticalBy(500);
      }
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.pageUp) {
      if (isPaged) {
        if (isRtl) {
          _goToNextPage();
        } else {
          _goToPrevPage();
        }
      } else {
        _scrollVerticalBy(-500);
      }
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.arrowDown) {
      if (isPaged) {
        _goToNextPage();
      } else {
        _scrollVerticalBy(300);
      }
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.arrowUp) {
      if (isPaged) {
        _goToPrevPage();
      } else {
        _scrollVerticalBy(-300);
      }
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.escape) {
      _safeExitReader();
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.audioVolumeDown && _settings.volumeKeyTurn) {
      _goToNextPage();
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.audioVolumeUp && _settings.volumeKeyTurn) {
      _goToPrevPage();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _safeExitReader() {
    if (context.canPop()) {
      context.pop();
    } else if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else if (_chapter?.mangaId != null) {
      context.go('/manga/${_chapter!.mangaId}');
    } else {
      context.go('/library');
    }
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) {
      try {
        VolumeController.instance.removeListener();
        VolumeController.instance.showSystemUI = true;
      } catch (_) {}
    }
    _progressDebounceTimer?.cancel();
    _scrollIndicatorTimer?.cancel();
    _transformationController.dispose();
    if (_settings.keepScreenAwake) {
      _safeSetWakelock(false);
    }
    if (_chapter != null) {
      _updateProgress(_currentPage);
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _focusNode.dispose();
    _scrollController.removeListener(_onVerticalScroll);
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadChapterAndPages(int chapterId) async {
    _currentChapterId = chapterId;
    _progressDebounceTimer?.cancel();
    _stopAutoScroll();
    _recoveredImageBytes.clear();
    _recoveringUrls.clear();
    if (_isZoomed) {
      _transformationController.value = Matrix4.identity();
      _isZoomed = false;
    }

    setState(() {
      _isLoading = true;
      _pageUrls = [];
      _currentPage = 1;
      _nextChapter = null;
      _prevChapter = null;
    });

    _chapter = await IsarService.instance.getChapterByServerId(chapterId) ??
        (await IsarService.instance.getAllChapters()).where((c) => c.serverId == chapterId || c.id == chapterId).firstOrNull;

    if (_chapter != null) {
      _siblingChapters = await IsarService.instance.getChaptersForManga(_chapter!.mangaId);
      _siblingChapters.sort((a, b) => a.chapterNumber.compareTo(b.chapterNumber));
      final idx = _siblingChapters.indexWhere((c) => c.serverId == _chapter!.serverId);
      if (idx != -1) {
        if (idx + 1 < _siblingChapters.length) _nextChapter = _siblingChapters[idx + 1];
        if (idx - 1 >= 0) _prevChapter = _siblingChapters[idx - 1];
      }
    }

    // ── 3-TIER RESOLVER: 1. Local Extension -> 2. Local Download -> 3. Server ──
    String? sourceName;
    if (_chapter != null) {
      final manga = await IsarService.instance.getMangaByServerId(_chapter!.mangaId);
      sourceName = manga?.sourceName;
    }

    var chapterUrlToResolve = (_chapter?.url.isNotEmpty == true)
        ? _chapter!.url
        : ((_chapter?.realUrl.isNotEmpty == true)
            ? _chapter!.realUrl
            : _chapter?.localPath);

    // On-demand self-healing: If chapter has empty/blank URL in DB, scrape parent manga details immediately!
    if ((chapterUrlToResolve == null || chapterUrlToResolve.isEmpty) && _chapter != null) {
      try {
        final manga = await IsarService.instance.getMangaByServerId(_chapter!.mangaId);
        final effectiveSource = sourceName ?? manga?.sourceName ?? '';
        if (manga != null && effectiveSource.isNotEmpty) {
          final target = manga.url.isNotEmpty ? manga.url : manga.title;
          final details = await QuickJsService.instance.fetchMangaDetailsLocal(effectiveSource, target);
          final chList = (details['chapters'] ?? details['chapterList'] ?? details['epList']) as List<dynamic>?;
          if (chList != null && chList.isNotEmpty) {
            final match = chList.firstWhere(
              (c) => (c['name'] != null && c['name'].toString().trim().toLowerCase() == _chapter!.name.trim().toLowerCase()) ||
                     (c['chapterNumber'] != null && (c['chapterNumber'] as num).toDouble() == _chapter!.chapterNumber),
              orElse: () => chList.first,
            );
            final freshUrl = (match['url'] ?? match['link'] ?? '').toString();
            if (freshUrl.isNotEmpty) {
              chapterUrlToResolve = freshUrl;
              _chapter!.url = freshUrl;
              _chapter!.realUrl = freshUrl;
              await IsarService.instance.saveChapter(_chapter!);
            }
          }
        }
      } catch (_) {}
    }

    // Auto-detect source name from URL if missing
    if ((sourceName == null || sourceName.isEmpty) && chapterUrlToResolve != null && chapterUrlToResolve.isNotEmpty) {
      final installed = QuickJsService.instance.getInstalledExtensionNames();
      final urlLower = chapterUrlToResolve.toLowerCase();
      for (final name in installed) {
        final code = QuickJsService.instance.getExtensionCode(name);
        if (code != null) {
          final baseUrl = QuickJsService.instance.extractBaseUrl(code);
          if (baseUrl != null && baseUrl.isNotEmpty) {
            try {
              final host = Uri.parse(baseUrl).host.replaceAll('www.', '').toLowerCase();
              if (host.isNotEmpty && urlLower.contains(host)) {
                sourceName = name;
                break;
              }
            } catch (_) {}
          }
        }
      }
    }
    _sourceName = sourceName;

    // Pre-warm FlareSolverr session for this source immediately before resolving,
    // so cookies are ready when images start loading.
    if (chapterUrlToResolve != null && chapterUrlToResolve.startsWith('http')) {
      try {
        final uri = Uri.parse(chapterUrlToResolve);
        unawaited(MClient.prewarmSession('${uri.scheme}://${uri.host}'));
      } catch (_) {}
    }

    // Use prefetched pages if already available (instant load on next-chapter nav)
    List<String>? prefetchedUrls = _prefetchedChapters.remove(chapterId);

    ChapterPagesResult resolved;
    if (prefetchedUrls != null && prefetchedUrls.isNotEmpty) {
      debugPrint('[Reader] Using prefetched ${prefetchedUrls.length} pages for chapter $chapterId');
      resolved = ChapterPagesResult(
        pageUrls: prefetchedUrls,
        source: ContentSourceType.localExtension,
        effectiveSourceName: sourceName,
        isLocalFiles: false,
      );
    } else {
      try {
        resolved = await ContentResolverService.instance.resolveChapterPages(
          chapterServerId: chapterId,
          chapterUrl: chapterUrlToResolve,
          sourceName: sourceName,
        ).timeout(const Duration(seconds: 30), onTimeout: () {
          debugPrint('[Reader] ⏱️ Resolution timed out for chapter $chapterId');
          return ChapterPagesResult(
            pageUrls: [],
            source: ContentSourceType.fallback,
            effectiveSourceName: sourceName,
            isLocalFiles: false,
          );
        });
      } catch (e) {
        debugPrint('[Reader] ❌ Resolution threw: $e');
        resolved = ChapterPagesResult(
          pageUrls: [],
          source: ContentSourceType.fallback,
          effectiveSourceName: sourceName,
          isLocalFiles: false,
        );
      }
    }

    _sourceName = resolved.effectiveSourceName ?? sourceName;
    _pageUrls = resolved.pageUrls;
    if (_chapter != null && _pageUrls.isNotEmpty && _chapter!.pageCount != _pageUrls.length) {
      _chapter!.pageCount = _pageUrls.length;
      IsarService.instance.saveChapter(_chapter!);
    }
    debugPrint('[Reader] Resolved ${_pageUrls.length} pages for source=$_sourceName: ${_pageUrls.take(3).toList()}');

    // Proactively pre-fetch first 5 pages on desktop to bypass Cloudflare image CDN blocking immediately
    if (!kIsWeb && (Platform.isLinux || Platform.isMacOS || Platform.isWindows)) {
      for (int i = 0; i < _pageUrls.length && i < 5; i++) {
        _recoverImage(_pageUrls[i], i);
      }
    }

    _currentPage = (_chapter != null && _chapter!.lastPageRead > 0 && _chapter!.lastPageRead <= _pageUrls.length)
        ? _chapter!.lastPageRead
        : 1;

    if (mounted) {
      setState(() => _isLoading = false);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final isPaged = _readingMode == ReadingMode.pagedLtr || _readingMode == ReadingMode.pagedRtl;
      if (isPaged && _pageController.hasClients && _currentPage > 1) {
        _pageController.jumpToPage(_currentPage - 1);
      } else if (!isPaged && _scrollController.hasClients) {
        if (_currentPage > 1) {
           // Estimate the scroll position for vertical long strip based on average screen height
           final screenHeight = MediaQuery.of(context).size.height;
           final estimatedOffset = (_currentPage - 1) * screenHeight;
           final maxScroll = _scrollController.position.maxScrollExtent;
           final targetOffset = maxScroll > 0 ? estimatedOffset.clamp(0.0, maxScroll) : estimatedOffset;
           _scrollController.jumpTo(targetOffset);
        } else {
           _scrollController.jumpTo(0);
        }
      }
    });

    // Kick off next-chapter prefetch in background after current chapter is displayed
    if (_nextChapter != null) {
      unawaited(_prefetchChapter(_nextChapter!));
    }

    // Auto-download ahead trigger
    if (_settings.autoDownloadWhileReading) {
      _triggerDownloadAhead();
    }

    // "When next chapter opens" deletion check for previous read chapters
    if (_settings.deleteFinishedChaptersWhileReading == 'When next chapter opens' && _prevChapter != null) {
      if (_prevChapter!.isRead) {
        if (!_prevChapter!.isBookmarked || _settings.allowDeletingBookmarkedChapters) {
          DownloadManagerService.instance.deleteLocalDownload(_prevChapter!.serverId);
        }
      }
    }
  }

  void _triggerDownloadAhead() async {
    final count = _settings.downloadAheadChapterCount;
    if (count <= 0 || _chapter == null) return;
    final currentIdx = _siblingChapters.indexWhere((c) => c.serverId == _chapter!.serverId);
    if (currentIdx == -1) return;

    final upcoming = _siblingChapters
        .skip(currentIdx + 1)
        .where((c) => !c.isRead && !DownloadManagerService.instance.isChapterDownloadedLocally(c.serverId))
        .take(count)
        .toList();

    final manga = await IsarService.instance.getMangaByServerId(_chapter!.mangaId);
    final mangaTitle = manga?.title ?? 'Manga';

    for (final ch in upcoming) {
      DownloadManagerService.instance.enqueueLocalDownload(
        chapterId: ch.serverId,
        mangaId: ch.mangaId,
        chapterName: ch.name,
        mangaTitle: mangaTitle,
      );
    }
  }

  /// Prefetch the next chapter's page URLs into cache and precache image bitmaps into memory
  Future<void> _prefetchChapter(Chapter chapter) async {
    final sid = chapter.serverId;
    if (_prefetchedChapters.containsKey(sid) || _prefetchingChapters.contains(sid)) return;
    _prefetchingChapters.add(sid);
    try {
      final manga = await IsarService.instance.getMangaByServerId(chapter.mangaId);
      final url = chapter.url.isNotEmpty ? chapter.url : chapter.realUrl;
      final resolved = await ContentResolverService.instance.resolveChapterPages(
        chapterServerId: sid,
        chapterUrl: url.isNotEmpty ? url : null,
        sourceName: manga?.sourceName,
      );
      if (resolved.pageUrls.isNotEmpty) {
        _prefetchedChapters[sid] = resolved.pageUrls;
        debugPrint('[Reader] Prefetched ${resolved.pageUrls.length} pages for next chapter $sid');

        // Precache first 3 image bitmaps into Flutter memory cache for 0ms transition
        for (final pUrl in resolved.pageUrls.take(3)) {
          if (mounted && pUrl.startsWith('http')) {
            try {
              final headers = QuickJsService.getImageHeaders(_sourceName ?? '', pUrl);
              precacheImage(
                NetworkImage(pUrl, headers: headers),
                context,
              );
            } catch (_) {}
          }
        }
      }
    } catch (e) {
      debugPrint('[Reader] Prefetch failed for chapter $sid: $e');
    } finally {
      _prefetchingChapters.remove(sid);
    }
  }

  void _onVerticalScroll() {
    if (_pageUrls.isEmpty || !_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    if (maxScroll <= 0) return;

    // Show floating page indicator when scrolling with controls hidden
    if (!_showControls) {
      if (!_showScrollIndicator && mounted) {
        setState(() => _showScrollIndicator = true);
      }
      _scrollIndicatorTimer?.cancel();
      _scrollIndicatorTimer = Timer(const Duration(milliseconds: 1500), () {
        if (mounted && _showScrollIndicator) {
          setState(() => _showScrollIndicator = false);
        }
      });
    }

    final pageRatio = (currentScroll / maxScroll).clamp(0.0, 1.0);
    final computedPage = ((pageRatio * (_pageUrls.length - 1)) + 1).round();

    // Trigger prefetch early when reaching 65% of chapter
    if (pageRatio >= 0.65 && _nextChapter != null) {
      _prefetchChapter(_nextChapter!);
    }

    if (computedPage != _currentPage) {
      _currentPage = computedPage;
      if (mounted) {
        setState(() {});
      }
      _debouncedUpdateProgress(computedPage);
    }
  }

  void _onPageChanged(int index) {
    if (_isZoomed) {
      _transformationController.value = Matrix4.identity();
      _isZoomed = false;
    }
    final page = index + 1;
    _currentPage = page;

    // Trigger prefetch early when reaching 65% of pages in paged mode
    if (_pageUrls.isNotEmpty && page >= (_pageUrls.length * 0.65).round() && _nextChapter != null) {
      _prefetchChapter(_nextChapter!);
    }

    if (mounted) {
      setState(() {});
    }
    _debouncedUpdateProgress(page);
  }

  void _debouncedUpdateProgress(int page) {
    _progressDebounceTimer?.cancel();
    _progressDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      _updateProgress(page);
    });
  }

  void _updateProgress(int page) {
    if (_chapter == null) return;
    // Privacy & Security: If Incognito Mode is enabled, do not persist reading progress or sync to server
    if (_settings.incognitoMode) return;

    final totalPages = _pageUrls.isNotEmpty
        ? _pageUrls.length
        : (_chapter!.pageCount > 0 ? _chapter!.pageCount : page);
    final clampedPage = totalPages > 0 ? page.clamp(1, totalPages) : page;
    final isComplete = page >= totalPages;

    _chapter!.lastPageRead = clampedPage;
    if (_pageUrls.isNotEmpty && _chapter!.pageCount != _pageUrls.length) {
      _chapter!.pageCount = _pageUrls.length;
    }
    if (isComplete) {
      _chapter!.isRead = true;
      if (_settings.deleteFinishedChaptersWhileReading == 'Immediately') {
        if (!_chapter!.isBookmarked || _settings.allowDeletingBookmarkedChapters) {
          DownloadManagerService.instance.deleteLocalDownload(_chapter!.serverId);
        }
      }
    }
    _chapter!.lastReadAt = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    IsarService.instance.saveChapter(_chapter!);

    final isLocal = QuickJsService.instance.hasExtension(_sourceName ?? '');
    if (GraphQLClientService.instance.isConfigured && !isLocal) {
      GraphQLClientService.instance.updateChapterReadStatus(_chapter!.serverId, _chapter!.isRead, clampedPage);
    }
  }

  Future<void> _openChapterInBrowser() async {
    String? rawUrl = (_chapter?.url.isNotEmpty == true)
        ? _chapter!.url
        : ((_chapter?.realUrl.isNotEmpty == true) ? _chapter!.realUrl : null);

    final manga = _chapter != null ? await IsarService.instance.getMangaByServerId(_chapter!.mangaId) : null;
    rawUrl ??= manga?.url;

    if (rawUrl == null || rawUrl.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No web URL available for this chapter')),
        );
      }
      return;
    }

    var effectiveUrl = rawUrl.trim();
    if (!effectiveUrl.startsWith('http://') && !effectiveUrl.startsWith('https://')) {
      final sourceName = _sourceName ?? manga?.sourceName ?? '';
      final baseUrl = QuickJsService.instance.getSourceBaseUrl(sourceName);
      if (baseUrl != null && baseUrl.isNotEmpty) {
        final cleanBase = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
        final cleanPath = effectiveUrl.startsWith('/') ? effectiveUrl : '/$effectiveUrl';
        effectiveUrl = '$cleanBase$cleanPath';
      }
    }

    final uri = Uri.tryParse(effectiveUrl);
    if (uri != null) {
      try {
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!launched && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open $effectiveUrl')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open $effectiveUrl: $e')),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $effectiveUrl')),
        );
      }
    }
  }

  void _toggleControls() {
    HapticFeedback.selectionClick();
    setState(() {
      _showControls = !_showControls;
      if (!_showControls) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      } else {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }
    });
  }

  void _handleTapZone(TapUpDetails details, BoxConstraints constraints) {
    if (_isAutoScrolling) {
      _stopAutoScroll();
      return;
    }
    if (!_settings.tapZonesEnabled || _isZoomed) {
      _toggleControls();
      return;
    }

    final width = constraints.maxWidth;
    final dx = details.localPosition.dx;

    final isLeft = dx < width * 0.30;
    final isRight = dx > width * 0.70;

    final isNext = _invertTaps ? isLeft : isRight;
    final isPrev = _invertTaps ? isRight : isLeft;

    if (_readingMode == ReadingMode.pagedLtr || _readingMode == ReadingMode.pagedRtl) {
      if (_readingMode == ReadingMode.pagedRtl) {
        // In Manga RTL mode: Left is Next, Right is Prev by default; reversed if inverted
        final isRtlNext = _invertTaps ? isRight : isLeft;
        final isRtlPrev = _invertTaps ? isLeft : isRight;
        if (isRtlNext) {
          _goToNextPage();
        } else if (isRtlPrev) {
          _goToPrevPage();
        } else {
          _toggleControls();
        }
      } else {
        if (isNext) {
          _goToNextPage();
        } else if (isPrev) {
          _goToPrevPage();
        } else {
          _toggleControls();
        }
      }
    } else {
      // In Webtoon / Vertical mode, center tap toggles controls
      if (!isLeft && !isRight) {
        _toggleControls();
      } else if (isNext) {
        if (_scrollController.hasClients &&
            _scrollController.position.maxScrollExtent > 50 &&
            _scrollController.offset >= _scrollController.position.maxScrollExtent - 20) {
          if (_nextChapter != null) {
            _loadChapterAndPages(_nextChapter!.serverId);
          }
        } else {
          _scrollVerticalBy(400);
        }
      } else if (isPrev) {
        if (_scrollController.hasClients &&
            _scrollController.position.maxScrollExtent > 50 &&
            _scrollController.offset <= 20) {
          if (_prevChapter != null) {
            _loadChapterAndPages(_prevChapter!.serverId);
          }
        } else {
          _scrollVerticalBy(-400);
        }
      }
    }
  }

  void _handleDoubleTapZoom() {
    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    if (currentScale > 1.05) {
      setState(() {
        _transformationController.value = Matrix4.identity();
        _isZoomed = false;
      });
    } else {
      final pos = _doubleTapDetails?.localPosition ?? Offset.zero;
      final x = -pos.dx * 1.5;
      final y = -pos.dy * 1.5;
      final zoomedMatrix = Matrix4.identity()
        ..translateByDouble(x, y, 0.0, 1.0)
        ..scaleByDouble(2.5, 2.5, 1.0, 1.0);
      setState(() {
        _transformationController.value = zoomedMatrix;
        _isZoomed = true;
      });
    }
  }

  void _goToNextPage() {
    final isPaged = _readingMode == ReadingMode.pagedLtr || _readingMode == ReadingMode.pagedRtl;
    if (isPaged) {
      if (_currentPage < _pageUrls.length && _pageController.hasClients) {
        HapticFeedback.lightImpact();
        _pageController.nextPage(duration: const Duration(milliseconds: 220), curve: Curves.easeOutCubic);
      } else if (_nextChapter != null) {
        _loadChapterAndPages(_nextChapter!.serverId);
      }
    } else {
      if (_scrollController.hasClients) {
        final screenHeight = MediaQuery.of(context).size.height;
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentOffset = _scrollController.offset;
        if (maxScroll > 50 && currentOffset >= maxScroll - 20) {
          if (_nextChapter != null) {
            _loadChapterAndPages(_nextChapter!.serverId);
          }
        } else {
          final targetOffset = (currentOffset + screenHeight * 0.85).clamp(0.0, maxScroll);
          _scrollController.animateTo(
            targetOffset,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
          );
        }
      }
    }
  }

  void _goToPrevPage() {
    final isPaged = _readingMode == ReadingMode.pagedLtr || _readingMode == ReadingMode.pagedRtl;
    if (isPaged) {
      if (_currentPage > 1 && _pageController.hasClients) {
        HapticFeedback.lightImpact();
        _pageController.previousPage(duration: const Duration(milliseconds: 220), curve: Curves.easeOutCubic);
      } else if (_prevChapter != null) {
        _loadChapterAndPages(_prevChapter!.serverId);
      }
    } else {
      if (_scrollController.hasClients) {
        final screenHeight = MediaQuery.of(context).size.height;
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentOffset = _scrollController.offset;
        if (currentOffset <= 20) {
          if (_prevChapter != null) {
            _loadChapterAndPages(_prevChapter!.serverId);
          }
        } else {
          final targetOffset = (currentOffset - screenHeight * 0.85).clamp(0.0, maxScroll);
          _scrollController.animateTo(
            targetOffset,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
          );
        }
      }
    }
  }

  Color get _canvasBackgroundColor {
    switch (_readerTheme) {
      case ReaderThemeMode.white:
        return const Color(0xFFFFFFFF);
      case ReaderThemeMode.darkGray:
        return const Color(0xFF1A1A20);
      case ReaderThemeMode.black:
        return const Color(0xFF000000);
    }
  }

  ColorFilter? get _activeColorFilter {
    switch (_colorFilter) {
      case ReaderColorFilter.invert:
        return const ColorFilter.matrix([
          -1, 0, 0, 0, 255,
          0, -1, 0, 0, 255,
          0, 0, -1, 0, 255,
          0, 0, 0, 1, 0,
        ]);
      case ReaderColorFilter.grayscale:
        return const ColorFilter.matrix([
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0, 0, 0, 1, 0,
        ]);
      case ReaderColorFilter.nightAmber:
        return ColorFilter.mode(Colors.amber.withAlpha(50), BlendMode.colorBurn);
      case ReaderColorFilter.sepia:
        return const ColorFilter.matrix([
          0.393, 0.769, 0.189, 0, 0,
          0.349, 0.686, 0.168, 0, 0,
          0.272, 0.534, 0.131, 0, 0,
          0, 0, 0, 1, 0,
        ]);
      case ReaderColorFilter.none:
        return null;
    }
  }

  BoxFit get _imageBoxFit {
    switch (_scaleType) {
      case ImageScaleType.fitHeight:
        return BoxFit.fitHeight;
      case ImageScaleType.fitScreen:
        return BoxFit.contain;
      case ImageScaleType.original:
        return BoxFit.none;
      case ImageScaleType.fitWidth:
        return BoxFit.fitWidth;
    }
  }

  void _cycleReadingMode() {
    setState(() {
      if (_readingMode == ReadingMode.longStrip) {
        _readingMode = ReadingMode.pagedRtl;
        _settings.readingMode = 'Paged RTL (Manga)';
      } else if (_readingMode == ReadingMode.pagedRtl) {
        _readingMode = ReadingMode.pagedLtr;
        _settings.readingMode = 'Paged LTR';
      } else {
        _readingMode = ReadingMode.longStrip;
        _settings.readingMode = 'Long Strip';
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final isPaged = _readingMode == ReadingMode.pagedLtr || _readingMode == ReadingMode.pagedRtl;
      if (isPaged && _pageController.hasClients && _currentPage > 1) {
        _pageController.jumpToPage(_currentPage - 1);
      } else if (!isPaged && _scrollController.hasClients && _pageUrls.isNotEmpty) {
        if (_currentPage > 1 && _pageUrls.length > 1) {
          final targetOffset = ((_currentPage - 1) / (_pageUrls.length - 1)) * _scrollController.position.maxScrollExtent;
          _scrollController.jumpTo(targetOffset);
        } else {
          _scrollController.jumpTo(0);
        }
      }
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reading Mode: ${_readingMode == ReadingMode.longStrip ? "Webtoon (Long Strip)" : (_readingMode == ReadingMode.pagedRtl ? "Manga (Right to Left)" : "Comic (Left to Right)")}'),
        duration: const Duration(milliseconds: 1200),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showReaderSettingsSheet() {
    final primaryColor = Theme.of(context).colorScheme.primary;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F1F24),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              maxChildSize: 0.9,
              minChildSize: 0.4,
              expand: false,
              builder: (context, scrollCtrl) {
                return ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.all(20.0),
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Reader Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),

                    // 1. READING MODE
                    _buildSectionHeader('READING MODE'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildFilterChip('Long Strip', _readingMode == ReadingMode.longStrip, () {
                          setState(() => _readingMode = ReadingMode.longStrip);
                          _settings.readingMode = 'Long Strip';
                          setSheetState(() {});
                        }, primaryColor),
                        _buildFilterChip('Long Strip (Gaps)', _readingMode == ReadingMode.longStripGaps, () {
                          setState(() => _readingMode = ReadingMode.longStripGaps);
                          _settings.readingMode = 'Long Strip (Gaps)';
                          setSheetState(() {});
                        }, primaryColor),
                        _buildFilterChip('Paged LTR', _readingMode == ReadingMode.pagedLtr, () {
                          setState(() => _readingMode = ReadingMode.pagedLtr);
                          _settings.readingMode = 'Paged LTR';
                          setSheetState(() {});
                        }, primaryColor),
                        _buildFilterChip('Paged RTL (Manga)', _readingMode == ReadingMode.pagedRtl, () {
                          setState(() => _readingMode = ReadingMode.pagedRtl);
                          _settings.readingMode = 'Paged RTL (Manga)';
                          setSheetState(() {});
                        }, primaryColor),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 2. BACKGROUND THEME
                    _buildSectionHeader('BACKGROUND COLOR'),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildFilterChip('OLED Black', _readerTheme == ReaderThemeMode.black, () {
                          setState(() => _readerTheme = ReaderThemeMode.black);
                          _settings.readerTheme = 'Black';
                          setSheetState(() {});
                        }, primaryColor),
                        _buildFilterChip('Dark Slate', _readerTheme == ReaderThemeMode.darkGray, () {
                          setState(() => _readerTheme = ReaderThemeMode.darkGray);
                          _settings.readerTheme = 'Dark Gray';
                          setSheetState(() {});
                        }, primaryColor),
                        _buildFilterChip('Paper White', _readerTheme == ReaderThemeMode.white, () {
                          setState(() => _readerTheme = ReaderThemeMode.white);
                          _settings.readerTheme = 'White';
                          setSheetState(() {});
                        }, primaryColor),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 3. COLOR FILTER
                    _buildSectionHeader('COLOR FILTER / NIGHT MODE'),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildFilterChip('None', _colorFilter == ReaderColorFilter.none, () {
                          setState(() => _colorFilter = ReaderColorFilter.none);
                          _settings.colorFilter = 'None';
                          setSheetState(() {});
                        }, primaryColor),
                        _buildFilterChip('Invert Colors', _colorFilter == ReaderColorFilter.invert, () {
                          setState(() => _colorFilter = ReaderColorFilter.invert);
                          _settings.colorFilter = 'Invert';
                          setSheetState(() {});
                        }, primaryColor),
                        _buildFilterChip('Grayscale', _colorFilter == ReaderColorFilter.grayscale, () {
                          setState(() => _colorFilter = ReaderColorFilter.grayscale);
                          _settings.colorFilter = 'Grayscale';
                          setSheetState(() {});
                        }, primaryColor),
                        _buildFilterChip('Amber Night', _colorFilter == ReaderColorFilter.nightAmber, () {
                          setState(() => _colorFilter = ReaderColorFilter.nightAmber);
                          _settings.colorFilter = 'Amber Tint';
                          setSheetState(() {});
                        }, primaryColor),
                        _buildFilterChip('Sepia', _colorFilter == ReaderColorFilter.sepia, () {
                          setState(() => _colorFilter = ReaderColorFilter.sepia);
                          _settings.colorFilter = 'Sepia';
                          setSheetState(() {});
                        }, primaryColor),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 4. IMAGE SCALE
                    _buildSectionHeader('SCALE TYPE'),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildFilterChip('Fit Width', _scaleType == ImageScaleType.fitWidth, () {
                          setState(() => _scaleType = ImageScaleType.fitWidth);
                          _settings.scaleType = 'Fit Width';
                          setSheetState(() {});
                        }, primaryColor),
                        _buildFilterChip('Fit Height', _scaleType == ImageScaleType.fitHeight, () {
                          setState(() => _scaleType = ImageScaleType.fitHeight);
                          _settings.scaleType = 'Fit Height';
                          setSheetState(() {});
                        }, primaryColor),
                        _buildFilterChip('Fit Screen', _scaleType == ImageScaleType.fitScreen, () {
                          setState(() => _scaleType = ImageScaleType.fitScreen);
                          _settings.scaleType = 'Fit Screen';
                          setSheetState(() {});
                        }, primaryColor),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 5. NAVIGATION TOGGLES
                    _buildSectionHeader('NAVIGATION & GESTURES'),
                    SwitchListTile(
                      title: const Text('3-Zone Tap Navigation'),
                      subtitle: const Text('Tap left/right edges to turn pages'),
                      value: _settings.tapZonesEnabled,
                      activeThumbColor: primaryColor,
                      onChanged: (val) {
                        setState(() => _settings.tapZonesEnabled = val);
                        setSheetState(() {});
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Invert Tap Zones'),
                      subtitle: const Text('Swap previous and next page tap areas'),
                      value: _invertTaps,
                      activeThumbColor: primaryColor,
                      onChanged: (val) {
                        setState(() => _invertTaps = val);
                        _settings.invertTapZones = val;
                        setSheetState(() {});
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Volume Key Page Turn'),
                      subtitle: const Text('Turn pages with physical volume rocker'),
                      value: _settings.volumeKeyTurn,
                      activeThumbColor: primaryColor,
                      onChanged: (val) {
                        setState(() => _settings.volumeKeyTurn = val);
                        setSheetState(() {});
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Keep Screen Awake'),
                      subtitle: const Text('Prevent device display from sleeping'),
                      value: _settings.keepScreenAwake,
                      activeThumbColor: primaryColor,
                      onChanged: (val) {
                        setState(() => _settings.keepScreenAwake = val);
                        _safeSetWakelock(val);
                        setSheetState(() {});
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Crop White Borders'),
                      subtitle: const Text('Trim page whitespace margins automatically'),
                      value: _cropBorders,
                      activeThumbColor: primaryColor,
                      onChanged: (val) {
                        setState(() => _cropBorders = val);
                        _settings.cropBorders = val;
                        setSheetState(() {});
                      },
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _showChapterSelectorSheet() {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final currentIndex = _siblingChapters.indexWhere((c) => c.serverId == _chapter?.serverId);

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF18181D),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.35,
          maxChildSize: 0.92,
          expand: false,
          builder: (context, scrollController) {
            if (currentIndex > 0) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (scrollController.hasClients) {
                  final targetOffset = (currentIndex * 58.0).clamp(0.0, scrollController.position.maxScrollExtent);
                  scrollController.jumpTo(targetOffset);
                }
              });
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Chapters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text('${_siblingChapters.length} Total', style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                      itemCount: _siblingChapters.length,
                      itemBuilder: (context, index) {
                        final ch = _siblingChapters[index];
                        final isCurrent = ch.serverId == _chapter?.serverId;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Material(
                            color: isCurrent ? primaryColor.withValues(alpha: 0.15) : const Color(0x1F2A2A32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isCurrent ? primaryColor.withValues(alpha: 0.6) : const Color(0x2BFFFFFF),
                                width: 0.8,
                              ),
                            ),
                            child: ListTile(
                              dense: true,
                              title: Text(
                                ch.name.isNotEmpty ? ch.name : 'Chapter ${ch.chapterNumber}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isCurrent ? primaryColor : (ch.isRead ? Colors.grey : Colors.white),
                                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 13,
                                ),
                              ),
                              trailing: isCurrent
                                  ? Icon(Icons.check_circle_rounded, color: primaryColor, size: 18)
                                  : (ch.isRead ? const Icon(Icons.done_rounded, color: Colors.grey, size: 16) : null),
                              onTap: () {
                                Navigator.pop(sheetContext);
                                if (!isCurrent) {
                                  _loadChapterAndPages(ch.serverId);
                                }
                              },
                            ),
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
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap, Color primaryColor) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: primaryColor,
      backgroundColor: const Color(0x1F2A2A32),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isSelected ? primaryColor : const Color(0x2BFFFFFF), width: 0.8),
      ),
      onSelected: (_) => onTap(),
    );
  }

  bool _isMagicImage(List<int> bytes) {
    if (bytes.length < 4) return false;
    // JPEG: FF D8 FF
    if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) return true;
    // PNG: 89 50 4E 47
    if (bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) return true;
    // GIF: 47 49 46 38
    if (bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46) return true;
    // WebP: RIFF ... WEBP
    if (bytes.length >= 12 && bytes[0] == 0x52 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x46 && bytes[8] == 0x57 && bytes[9] == 0x45 && bytes[10] == 0x42 && bytes[11] == 0x50) return true;
    return false;
  }

  Future<void> _recoverImage(String url, int index) async {
    if (_recoveringUrls.contains(url) || _recoveredImageBytes.containsKey(url)) return;
    _recoveringUrls.add(url);
    try {
      final baseHeaders = QuickJsService.getImageHeaders(_sourceName ?? '', url);
      final cookieHeaders = MClient.getCookiesPref(url);

      // 1. On Desktop: try curl-impersonate FIRST with clean baseHeaders (Referer only)
      if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
        for (final exe in ['/usr/bin/curl-impersonate', 'curl-impersonate', 'curl-impersonate-chrome', '/usr/bin/curl', 'curl']) {
          try {
            final args = <String>['-s', '-L', '--max-time', '15'];
            baseHeaders.forEach((k, v) {
              final kLower = k.toLowerCase();
              if (kLower != 'user-agent' && kLower != 'cookie') {
                args.addAll(['-H', '$k: $v']);
              }
            });
            args.add(url);
            final processRes = await Process.run(exe, args, stdoutEncoding: null);
            if (processRes.exitCode == 0) {
              final bytes = processRes.stdout as List<int>;
              if (bytes.length > 200 && _isMagicImage(bytes)) {
                if (mounted) {
                  setState(() {
                    _recoveredImageBytes[url] = Uint8List.fromList(bytes);
                  });
                }
                return;
              }
            }
          } catch (_) {}
        }
      }

      // 2. Standard HTTP fetch fallback with multi-pass self-healing
      final initialHeaders = {...baseHeaders, ...cookieHeaders, 'User-Agent': MClient.userAgent};
      final client = MClient.init(showCloudFlareError: false);
      http.Response? res;

      try {
        final uri = Uri.tryParse(url) ?? Uri.tryParse(Uri.encodeFull(url));
        if (uri == null) return;

        // Pass 1: Standard fetch
        try {
          res = await client.get(uri, headers: initialHeaders).timeout(const Duration(seconds: 15));
        } catch (_) {}

        // Pass 2: If failed and had Referer, retry with NO Referer (anti-hotlink bypass)
        if ((res == null || res.statusCode != 200 || res.bodyBytes.isEmpty || !_isMagicImage(res.bodyBytes)) && initialHeaders.containsKey('Referer')) {
          final noReferer = Map<String, String>.from(initialHeaders)..remove('Referer');
          try {
            res = await client.get(uri, headers: noReferer).timeout(const Duration(seconds: 15));
          } catch (_) {}
        }

        // Pass 3: If still failed, retry with Origin Referer (same-origin requirement bypass)
        if (res == null || res.statusCode != 200 || res.bodyBytes.isEmpty || !_isMagicImage(res.bodyBytes)) {
          try {
            final originReferer = Map<String, String>.from(initialHeaders)..['Referer'] = '${uri.origin}/';
            res = await client.get(uri, headers: originReferer).timeout(const Duration(seconds: 15));
          } catch (_) {}
        }

        // Pass 4: Clean Browser User-Agent and Accept headers
        if (res == null || res.statusCode != 200 || res.bodyBytes.isEmpty || !_isMagicImage(res.bodyBytes)) {
          try {
            final browserHeaders = Map<String, String>.from(initialHeaders)
              ..['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36'
              ..['Accept'] = 'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8';
            res = await client.get(uri, headers: browserHeaders).timeout(const Duration(seconds: 15));
          } catch (_) {}
        }

        if (res != null && res.statusCode == 200 && res.bodyBytes.isNotEmpty && _isMagicImage(res.bodyBytes)) {
          if (mounted) {
            setState(() {
              _recoveredImageBytes[url] = res!.bodyBytes;
            });
          }
        } else {
          debugPrint('[Reader] ❌ Image still failed $url -> ${res?.statusCode}');
        }
      } finally {
        client.close();
      }
    } catch (e) {
      debugPrint('[Reader] Image fetch error for $url: $e');
    } finally {
      _recoveringUrls.remove(url);
    }
  }

  void _prefetchUpcomingPages(int currentIndex) {
    if (!kIsWeb && (Platform.isLinux || Platform.isMacOS || Platform.isWindows)) {
      for (int i = currentIndex + 1; i <= currentIndex + 4 && i < _pageUrls.length; i++) {
        final nextUrl = _pageUrls[i];
        if (!_recoveredImageBytes.containsKey(nextUrl) && !_recoveringUrls.contains(nextUrl) && (nextUrl.startsWith('http://') || nextUrl.startsWith('https://'))) {
          _recoverImage(nextUrl, i);
        }
      }
    }
  }

  Widget _buildPageWidget(String url, int index, {BoxConstraints? constraints, bool isPaged = false}) {
    final isWebtoon = _readingMode == ReadingMode.longStrip || _readingMode == ReadingMode.longStripGaps;
    final boxFit = isWebtoon ? BoxFit.fitWidth : _imageBoxFit;

    final isDesktop = !kIsWeb && (Platform.isLinux || Platform.isMacOS || Platform.isWindows);
    if (isDesktop) {
      _prefetchUpcomingPages(index);
    }

    Widget image;
    if (_recoveredImageBytes.containsKey(url)) {
      image = Image.memory(
        _recoveredImageBytes[url]!,
        width: isWebtoon ? (constraints?.maxWidth ?? double.infinity) : null,
        fit: boxFit,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => Container(
          height: isWebtoon ? (constraints?.maxHeight ?? 600.0) : 300.0,
          color: const Color(0xFF1A1A22),
          child: Center(
            child: Text('Page ${index + 1} Failed to Load', style: const TextStyle(color: Colors.grey)),
          ),
        ),
      );
    } else if (url.startsWith('/')) {
      image = Image.file(
        File(url),
        width: isWebtoon ? (constraints?.maxWidth ?? double.infinity) : null,
        fit: boxFit,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => Container(
          height: 300,
          color: const Color(0xFF1A1A22),
          child: Center(
            child: Text('Page ${index + 1} Failed to Load', style: const TextStyle(color: Colors.grey)),
          ),
        ),
      );
    } else if (isDesktop) {
      // On desktop: fetch directly via curl-impersonate without firing failing Dart Image.network 403s
      _recoverImage(url, index);
      final placeholderHeight = isWebtoon ? (constraints?.maxHeight ?? 600.0) : 400.0;
      image = Container(
        height: placeholderHeight,
        width: constraints?.maxWidth ?? double.infinity,
        color: _canvasBackgroundColor,
        child: Center(
          child: _recoveringUrls.contains(url)
              ? CircularProgressIndicator(color: Theme.of(context).colorScheme.primary, strokeWidth: 2)
              : IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: Colors.grey),
                  tooltip: 'Retry Page ${index + 1}',
                  onPressed: () => _recoverImage(url, index),
                ),
        ),
      );
    } else {
      final baseHeaders = QuickJsService.getImageHeaders(_sourceName ?? '', url);
      final cookieHeaders = MClient.getCookiesPref(url);
      final headers = {...baseHeaders, ...cookieHeaders, 'User-Agent': MClient.userAgent};

      image = Image.network(
        url,
        headers: headers,
        width: isWebtoon ? (constraints?.maxWidth ?? double.infinity) : null,
        fit: boxFit,
        gaplessPlayback: true,
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          final placeholderHeight = isWebtoon ? (constraints?.maxHeight ?? 600.0) : 400.0;
          return Container(
            height: placeholderHeight,
            width: constraints?.maxWidth ?? double.infinity,
            color: _canvasBackgroundColor,
            child: Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary, strokeWidth: 2)),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          _recoverImage(url, index);
          final placeholderHeight = isWebtoon ? (constraints?.maxHeight ?? 600.0) : 300.0;
          return Container(
            height: placeholderHeight,
            width: constraints?.maxWidth ?? double.infinity,
            color: _canvasBackgroundColor,
            child: Center(
              child: _recoveringUrls.contains(url)
                  ? CircularProgressIndicator(color: Theme.of(context).colorScheme.primary, strokeWidth: 2)
                  : InkWell(
                      onTap: () => _recoverImage(url, index),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.refresh_rounded, color: Colors.grey, size: 28),
                            const SizedBox(height: 6),
                            Text('Page ${index + 1} Failed to Load', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('Tap to Retry', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
            ),
          );
        },
      );
    }

    if (_activeColorFilter != null) {
      image = ColorFiltered(colorFilter: _activeColorFilter!, child: image);
    }

    if (_cropBorders) {
      image = ClipRect(child: image);
    }

    if (isPaged) {
      return GestureDetector(
        onDoubleTapDown: (details) => _doubleTapDetails = details,
        onDoubleTap: _handleDoubleTapZoom,
        child: InteractiveViewer(
          transformationController: _transformationController,
          minScale: 1.0,
          maxScale: 3.5,
          onInteractionUpdate: (_) {
            final scale = _transformationController.value.getMaxScaleOnAxis();
            final isNowZoomed = scale > 1.05;
            if (isNowZoomed != _isZoomed) {
              setState(() => _isZoomed = isNowZoomed);
            }
          },
          onInteractionEnd: (_) {
            final scale = _transformationController.value.getMaxScaleOnAxis();
            final isNowZoomed = scale > 1.05;
            if (isNowZoomed != _isZoomed) {
              setState(() => _isZoomed = isNowZoomed);
            }
          },
          child: image,
        ),
      );
    }

    return image;
  }

  Widget _buildChapterTransitionCard() {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F24),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x2BFFFFFF), width: 0.8),
      ),
      child: Column(
        children: [
          Icon(Icons.check_circle_outline_rounded, color: primaryColor, size: 48),
          const SizedBox(height: 12),
          Text('Finished ${_chapter?.name ?? "Chapter"}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (_nextChapter != null) ...[
            Text('Up Next: ${_nextChapter!.name}', style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => _loadChapterAndPages(_nextChapter!.serverId),
              child: const Text('Read Next Chapter', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ] else ...[
            const Text('You have caught up with the latest chapter!', style: TextStyle(color: Colors.grey)),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: _canvasBackgroundColor,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: primaryColor),
              const SizedBox(height: 16),
              Text(
                _chapter?.name ?? 'Loading Chapter...',
                style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }

    if (_pageUrls.isEmpty) {
      return Scaffold(
        backgroundColor: _canvasBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.broken_image_rounded, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'Could not load ${_chapter?.name.replaceAll(RegExp(r'\s+'), ' ').trim() ?? "chapter pages"}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Check network or source availability',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                      onPressed: () => _loadChapterAndPages(_currentChapterId),
                      label: const Text('Retry', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0x33FFFFFF)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      ),
                      icon: const Icon(Icons.open_in_browser_rounded, size: 18),
                      onPressed: _openChapterInBrowser,
                      label: const Text('Open in Browser', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    if (SettingsService.instance.cfProxyUrl.isEmpty)
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.amberAccent,
                          side: const BorderSide(color: Colors.amberAccent),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        ),
                        icon: const Icon(Icons.security_rounded, size: 18),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AdvancedSettingsScreen()),
                          );
                        },
                        label: const Text('Configure FlareSolverr', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return PopScope(
      canPop: _showControls,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (!_showControls) {
          setState(() {
            _showControls = true;
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
          });
        }
      },
      child: Scaffold(
      backgroundColor: _canvasBackgroundColor,
      body: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Listener(
              onPointerSignal: (pointerSignal) {
                if (pointerSignal is PointerScrollEvent) {
                  final isPaged = _readingMode == ReadingMode.pagedLtr || _readingMode == ReadingMode.pagedRtl;
                  if (isPaged) {
                    if (pointerSignal.scrollDelta.dx > 25 || pointerSignal.scrollDelta.dy > 25) {
                      _goToNextPage();
                    } else if (pointerSignal.scrollDelta.dx < -25 || pointerSignal.scrollDelta.dy < -25) {
                      _goToPrevPage();
                    }
                  }
                }
              },
              child: GestureDetector(
                onTapUp: (details) => _handleTapZone(details, constraints),
                child: Stack(
                children: [
                  // ── 1. READER CANVAS ──────────────────────────────
                  if (_readingMode == ReadingMode.longStrip || _readingMode == ReadingMode.longStripGaps)
                    ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.zero,
                      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                      scrollCacheExtent: ScrollCacheExtent.pixels(2500),
                      itemCount: _pageUrls.isEmpty ? 0 : (_settings.seamlessTransitions ? _pageUrls.length + 1 : _pageUrls.length),
                      itemBuilder: (context, index) {
                        if (index == _pageUrls.length) {
                          return _buildChapterTransitionCard();
                        }
                        final pageWidget = _buildPageWidget(_pageUrls[index], index, constraints: constraints, isPaged: false);
                        final isWideScreen = constraints.maxWidth > 800;
                        final contentWidth = isWideScreen ? 780.0 : constraints.maxWidth;

                        if (_readingMode == ReadingMode.longStrip) {
                          // Long Strip: continuous zero gap
                          return RepaintBoundary(
                            child: Center(
                              child: SizedBox(
                                width: contentWidth,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(minHeight: (constraints.maxHeight * 0.75).clamp(300.0, 900.0)),
                                  child: pageWidget,
                                ),
                              ),
                            ),
                          );
                        }
                        // Long Strip (Gaps): continuous vertical with 12px gap between pages
                        return RepaintBoundary(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Center(
                              child: SizedBox(
                                width: contentWidth,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(minHeight: (constraints.maxHeight * 0.75).clamp(300.0, 900.0)),
                                  child: pageWidget,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  else
                    PageView.builder(
                      controller: _pageController,
                      physics: _isZoomed
                          ? const NeverScrollableScrollPhysics()
                          : const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                      reverse: _readingMode == ReadingMode.pagedRtl,
                      itemCount: _pageUrls.length,
                      onPageChanged: _onPageChanged,
                      itemBuilder: (context, index) {
                        return RepaintBoundary(
                          child: Center(child: _buildPageWidget(_pageUrls[index], index, constraints: constraints, isPaged: true)),
                        );
                      },
                    ),

                  // ── 2. OVERLAY HUD (TOP APP BAR & BOTTOM SLIDER) ──
                  // Top Overlay Bar with smooth 200ms slide & fade
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: AnimatedSlide(
                      offset: _showControls ? Offset.zero : const Offset(0, -1),
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      child: AnimatedOpacity(
                        opacity: _showControls ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: IgnorePointer(
                          ignoring: !_showControls,
                          child: Container(
                            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, left: 16, right: 16, bottom: 12),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xCC000000), Colors.transparent],
                              ),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                                  onPressed: _safeExitReader,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _chapter?.name ?? 'Reader',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            '${_readingMode.name.toUpperCase()} • ${_readerTheme.name.toUpperCase()}',
                                            style: TextStyle(color: primaryColor, fontSize: 10, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '• ${DateFormat.jm().format(DateTime.now())}',
                                            style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    _settings.incognitoMode ? Icons.visibility_off_rounded : Icons.visibility_outlined,
                                    color: _settings.incognitoMode ? Colors.amberAccent : Colors.white70,
                                  ),
                                  tooltip: _settings.incognitoMode ? 'Incognito Mode: ON' : 'Incognito Mode: OFF',
                                  onPressed: () {
                                    setState(() => _settings.incognitoMode = !_settings.incognitoMode);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(_settings.incognitoMode ? '🕵️ Incognito Mode Active (History & tracking paused)' : 'Incognito Mode Deactivated'),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.format_list_bulleted_rounded, color: Colors.white),
                                  tooltip: 'Chapters',
                                  onPressed: _showChapterSelectorSheet,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.tune_rounded, color: Colors.white),
                                  tooltip: 'Settings',
                                  onPressed: _showReaderSettingsSheet,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Bottom HUD Bar with Scrubber Slider with smooth 200ms slide & fade
                  Positioned(
                    bottom: 16 + MediaQuery.of(context).padding.bottom,
                    left: 16,
                    right: 16,
                    child: AnimatedSlide(
                      offset: _showControls ? Offset.zero : const Offset(0, 1),
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      child: AnimatedOpacity(
                        opacity: _showControls ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: IgnorePointer(
                          ignoring: !_showControls,
                          child: Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xE614141A),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(color: const Color(0x33FFFFFF), width: 0.8),
                                    boxShadow: const [
                                      BoxShadow(color: Color(0x66000000), blurRadius: 16, offset: Offset(0, 4)),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.skip_previous_rounded, color: Colors.white),
                                            tooltip: 'Previous Chapter',
                                            onPressed: _prevChapter != null ? () => _loadChapterAndPages(_prevChapter!.serverId) : null,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Page $_currentPage / ${_pageUrls.length}',
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                          ),
                                          const SizedBox(width: 8),
                                          InkWell(
                                            onTap: _cycleReadingMode,
                                            borderRadius: BorderRadius.circular(10),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: primaryColor.withValues(alpha: 0.2),
                                                borderRadius: BorderRadius.circular(10),
                                                border: Border.all(color: primaryColor.withValues(alpha: 0.5), width: 0.8),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    _readingMode == ReadingMode.longStrip
                                                        ? Icons.swap_vert_rounded
                                                        : (_readingMode == ReadingMode.pagedRtl ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded),
                                                    size: 13,
                                                    color: primaryColor,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    _readingMode == ReadingMode.longStrip
                                                        ? 'WEBTOON'
                                                        : (_readingMode == ReadingMode.pagedRtl ? 'RTL' : 'LTR'),
                                                    style: TextStyle(
                                                      color: primaryColor,
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                           if (_readingMode == ReadingMode.longStrip || _readingMode == ReadingMode.longStripGaps) ...[
                                             const SizedBox(width: 6),
                                             GestureDetector(
                                               onTap: _toggleAutoScroll,
                                               onLongPress: _showAutoScrollSpeedDialog,
                                               child: Container(
                                                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                 decoration: BoxDecoration(
                                                   color: _isAutoScrolling ? primaryColor.withValues(alpha: 0.3) : const Color(0x22FFFFFF),
                                                   borderRadius: BorderRadius.circular(12),
                                                   border: Border.all(
                                                     color: _isAutoScrolling ? primaryColor : Colors.white24,
                                                     width: 0.8,
                                                   ),
                                                 ),
                                                 child: Row(
                                                   mainAxisSize: MainAxisSize.min,
                                                   children: [
                                                     Icon(
                                                       _isAutoScrolling ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                                       size: 13,
                                                       color: _isAutoScrolling ? primaryColor : Colors.white,
                                                     ),
                                                     const SizedBox(width: 3),
                                                     Text(
                                                       'AUTO',
                                                       style: TextStyle(
                                                         color: _isAutoScrolling ? primaryColor : Colors.white,
                                                         fontSize: 10,
                                                         fontWeight: FontWeight.bold,
                                                         letterSpacing: 0.5,
                                                       ),
                                                     ),
                                                   ],
                                                 ),
                                               ),
                                             ),
                                           ],
                                           const SizedBox(width: 8),
                                           IconButton(
                                             icon: const Icon(Icons.skip_next_rounded, color: Colors.white),
                                            tooltip: 'Next Chapter',
                                            onPressed: _nextChapter != null ? () => _loadChapterAndPages(_nextChapter!.serverId) : null,
                                          ),
                                        ],
                                      ),
                                      if (_pageUrls.length > 1)
                                        ConstrainedBox(
                                          constraints: BoxConstraints(maxWidth: (MediaQuery.of(context).size.width - 64).clamp(180.0, 320.0)),
                                          child: SizedBox(
                                            height: 28,
                                            child: SliderTheme(
                                              data: SliderThemeData(
                                                activeTrackColor: primaryColor,
                                                inactiveTrackColor: Colors.grey[800],
                                                thumbColor: primaryColor,
                                                trackHeight: 3,
                                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                              ),
                                              child: Slider(
                                                value: _currentPage.toDouble().clamp(1.0, _pageUrls.length.toDouble()),
                                                min: 1.0,
                                                max: _pageUrls.length.toDouble(),
                                                divisions: _pageUrls.length > 1 ? _pageUrls.length - 1 : 1,
                                                onChanged: (val) {
                                                  final targetPage = val.round();
                                                  setState(() => _currentPage = targetPage);
                                                  if (_readingMode == ReadingMode.pagedLtr || _readingMode == ReadingMode.pagedRtl) {
                                                    if (_pageController.hasClients) {
                                                      _pageController.jumpToPage(targetPage - 1);
                                                    }
                                                  } else {
                                                    if (_scrollController.hasClients && _pageUrls.length > 1 && _scrollController.position.maxScrollExtent > 0) {
                                                      final targetOffset = ((targetPage - 1) / (_pageUrls.length - 1)) * _scrollController.position.maxScrollExtent;
                                                      _scrollController.jumpTo(targetOffset);
                                                    }
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── 3. FLOATING PAGE INDICATOR CAPSULE (Webtoon Mode) ──
                  if (_readingMode == ReadingMode.longStrip || _readingMode == ReadingMode.longStripGaps)
                    Positioned(
                      bottom: 24 + MediaQuery.of(context).padding.bottom,
                      right: 20,
                      child: AnimatedOpacity(
                        opacity: (!_showControls && _showScrollIndicator && _pageUrls.isNotEmpty) ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 250),
                        child: IgnorePointer(
                          ignoring: !_showScrollIndicator || _showControls,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xCC14141A),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0x33FFFFFF), width: 0.8),
                              boxShadow: const [
                                BoxShadow(color: Color(0x40000000), blurRadius: 8, offset: Offset(0, 2)),
                              ],
                            ),
                            child: Text(
                              '$_currentPage / ${_pageUrls.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // ── 4. FLOATING AUTO-SCROLL CONTROLS CAPSULE (Webtoon Mode) ──
                  if ((_readingMode == ReadingMode.longStrip || _readingMode == ReadingMode.longStripGaps) && _isAutoScrolling && !_showControls)
                    Positioned(
                      bottom: 24 + MediaQuery.of(context).padding.bottom,
                      left: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xCC14141A),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: primaryColor.withValues(alpha: 0.6), width: 0.8),
                          boxShadow: const [
                            BoxShadow(color: Color(0x40000000), blurRadius: 8, offset: Offset(0, 2)),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: _toggleAutoScroll,
                              child: Icon(Icons.pause_rounded, size: 16, color: primaryColor),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: _showAutoScrollSpeedDialog,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${_autoScrollSpeed.round()} px/s',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  final step = _autoScrollSpeed >= 300 ? 50.0 : (_autoScrollSpeed >= 100 ? 25.0 : 10.0);
                                  _autoScrollSpeed = (_autoScrollSpeed - step).clamp(10.0, 1000.0);
                                });
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                child: Icon(Icons.remove_rounded, size: 14, color: Colors.white70),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  final step = _autoScrollSpeed >= 300 ? 50.0 : (_autoScrollSpeed >= 100 ? 25.0 : 10.0);
                                  _autoScrollSpeed = (_autoScrollSpeed + step).clamp(10.0, 1000.0);
                                });
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                child: Icon(Icons.add_rounded, size: 14, color: Colors.white70),
                              ),
                            ),
                            const SizedBox(width: 6),
                            // Dedicated "FASTER" Button
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (_autoScrollSpeed < 180.0) {
                                    _autoScrollSpeed = 250.0;
                                  } else if (_autoScrollSpeed < 450.0) {
                                    _autoScrollSpeed = 500.0;
                                  } else {
                                    _autoScrollSpeed = _settings.defaultAutoScrollSpeed;
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _autoScrollSpeed >= 180.0
                                      ? primaryColor.withValues(alpha: 0.35)
                                      : Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _autoScrollSpeed >= 180.0 ? primaryColor : Colors.white24,
                                    width: 0.6,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.fast_forward_rounded,
                                      size: 13,
                                      color: _autoScrollSpeed >= 180.0 ? primaryColor : Colors.amberAccent,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      _autoScrollSpeed >= 450.0
                                          ? 'TURBO'
                                          : (_autoScrollSpeed >= 180.0 ? 'FASTER' : 'FAST'),
                                      style: TextStyle(
                                        color: _autoScrollSpeed >= 180.0 ? primaryColor : Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ],
          ),
        ),
      );
    },
        ),
      ),
    ),
  );
}
}
