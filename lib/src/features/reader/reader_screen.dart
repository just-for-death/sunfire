import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/isar_service.dart';
import '../../core/db/models/chapter.dart';
import '../../core/engine/content_resolver_service.dart';
import '../../core/engine/quickjs_service.dart';
import '../../core/services/settings_service.dart';
import '../../core/sync/graphql_client_service.dart';

enum ReadingMode { webtoon, continuousVertical, pagedLtr, pagedRtl }
enum ReaderThemeMode { black, darkGray, white }
enum ReaderColorFilter { none, invert, grayscale, nightAmber }
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
  bool _isLoading = true;
  bool _showControls = true;
  int _currentPage = 1;

  late ReadingMode _readingMode;
  late ReaderThemeMode _readerTheme;
  late ReaderColorFilter _colorFilter;
  late ImageScaleType _scaleType;
  late bool _cropBorders;
  late bool _invertTaps;

  final ScrollController _scrollController = ScrollController();
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initPreferences();
    _scrollController.addListener(_onVerticalScroll);
    _loadChapterAndPages(widget.chapterServerId);
  }

  void _initPreferences() {
    _readingMode = _parseReadingMode(_settings.readingMode);
    _readerTheme = _parseReaderTheme(_settings.readerTheme);
    _colorFilter = _parseColorFilter(_settings.colorFilter);
    _scaleType = _parseScaleType(_settings.scaleType);
    _cropBorders = _settings.cropBorders;
    _invertTaps = _settings.invertTapZones;
  }

  ReadingMode _parseReadingMode(String str) {
    switch (str.toLowerCase()) {
      case 'continuous vertical':
        return ReadingMode.continuousVertical;
      case 'paged ltr':
      case 'paged left-to-right':
        return ReadingMode.pagedLtr;
      case 'paged rtl':
      case 'paged right-to-left':
        return ReadingMode.pagedRtl;
      default:
        return ReadingMode.webtoon;
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
        return ReaderColorFilter.invert;
      case 'grayscale':
        return ReaderColorFilter.grayscale;
      case 'amber tint':
      case 'night amber':
        return ReaderColorFilter.nightAmber;
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
        _scrollController.animateTo(
          _scrollController.offset + 500,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
        );
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
        _scrollController.animateTo(
          _scrollController.offset - 500,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
        );
      }
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.arrowDown) {
      if (isPaged) {
        _goToNextPage();
      } else {
        _scrollController.animateTo(
          _scrollController.offset + 300,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
        );
      }
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.arrowUp) {
      if (isPaged) {
        _goToPrevPage();
      } else {
        _scrollController.animateTo(
          _scrollController.offset - 300,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
        );
      }
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.escape) {
      context.pop();
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

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _focusNode.dispose();
    _scrollController.removeListener(_onVerticalScroll);
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadChapterAndPages(int chapterId) async {
    setState(() {
      _isLoading = true;
      _pageUrls = [];
      _currentPage = 1;
      _nextChapter = null;
      _prevChapter = null;
    });

    _chapter = await IsarService.instance.getChapterByServerId(chapterId);

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
    _sourceName = sourceName;

    final chapterUrlToResolve = (_chapter?.url.isNotEmpty == true)
        ? _chapter!.url
        : ((_chapter?.realUrl.isNotEmpty == true)
            ? _chapter!.realUrl
            : _chapter?.localPath);

    final resolved = await ContentResolverService.instance.resolveChapterPages(
      chapterServerId: chapterId,
      chapterUrl: chapterUrlToResolve,
      sourceName: sourceName,
    );

    _sourceName = resolved.effectiveSourceName ?? sourceName;
    _pageUrls = resolved.pageUrls;

    if (_chapter != null && _chapter!.lastPageRead > 0 && _chapter!.lastPageRead <= _pageUrls.length) {
      _currentPage = _chapter!.lastPageRead;
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _onVerticalScroll() {
    if (_pageUrls.isEmpty || !_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    if (maxScroll <= 0) return;

    final pageRatio = (currentScroll / maxScroll).clamp(0.0, 1.0);
    final computedPage = ((pageRatio * (_pageUrls.length - 1)) + 1).round();

    if (computedPage != _currentPage) {
      setState(() => _currentPage = computedPage);
      _updateProgress(computedPage);
    }
  }

  void _onPageChanged(int index) {
    final page = index + 1;
    setState(() => _currentPage = page);
    _updateProgress(page);
  }

  void _updateProgress(int page) {
    if (_chapter == null) return;
    final isComplete = page >= _pageUrls.length;
    _chapter!.lastPageRead = page;
    if (isComplete) {
      _chapter!.isRead = true;
    }
    _chapter!.lastReadAt = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    IsarService.instance.saveChapter(_chapter!);

    if (GraphQLClientService.instance.isConfigured) {
      GraphQLClientService.instance.updateChapterReadStatus(_chapter!.serverId, _chapter!.isRead, page);
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
    final width = constraints.maxWidth;
    final dx = details.localPosition.dx;

    final isLeft = dx < width * 0.30;
    final isRight = dx > width * 0.70;

    final isNext = _invertTaps ? isLeft : isRight;
    final isPrev = _invertTaps ? isRight : isLeft;

    if (_readingMode == ReadingMode.pagedLtr || _readingMode == ReadingMode.pagedRtl) {
      if (_readingMode == ReadingMode.pagedRtl) {
        if (isLeft) {
          _goToNextPage();
        } else if (isRight) {
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
      } else if (isRight) {
        _scrollController.animateTo(
          _scrollController.offset + 400,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
        );
      } else if (isLeft) {
        _scrollController.animateTo(
          _scrollController.offset - 400,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  void _goToNextPage() {
    if (_currentPage < _pageUrls.length) {
      HapticFeedback.lightImpact();
      _pageController.nextPage(duration: const Duration(milliseconds: 220), curve: Curves.easeOutCubic);
    } else if (_nextChapter != null) {
      _loadChapterAndPages(_nextChapter!.serverId);
    }
  }

  void _goToPrevPage() {
    if (_currentPage > 1) {
      HapticFeedback.lightImpact();
      _pageController.previousPage(duration: const Duration(milliseconds: 220), curve: Curves.easeOutCubic);
    } else if (_prevChapter != null) {
      _loadChapterAndPages(_prevChapter!.serverId);
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
                        _buildFilterChip('Webtoon', _readingMode == ReadingMode.webtoon, () {
                          setState(() => _readingMode = ReadingMode.webtoon);
                          _settings.readingMode = 'Webtoon';
                          setSheetState(() {});
                        }, primaryColor),
                        _buildFilterChip('Continuous Vertical', _readingMode == ReadingMode.continuousVertical, () {
                          setState(() => _readingMode = ReadingMode.continuousVertical);
                          _settings.readingMode = 'Continuous Vertical';
                          setSheetState(() {});
                        }, primaryColor),
                        _buildFilterChip('Paged LTR', _readingMode == ReadingMode.pagedLtr, () {
                          setState(() => _readingMode = ReadingMode.pagedLtr);
                          _settings.readingMode = 'Paged LTR';
                          setSheetState(() {});
                        }, primaryColor),
                        _buildFilterChip('Paged RTL (Manga)', _readingMode == ReadingMode.pagedRtl, () {
                          setState(() => _readingMode = ReadingMode.pagedRtl);
                          _settings.readingMode = 'Paged RTL';
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

  Widget _buildPageWidget(String url, int index, {BoxConstraints? constraints, bool isPaged = false}) {
    final isWebtoon = _readingMode == ReadingMode.webtoon;
    final boxFit = isWebtoon ? BoxFit.fitWidth : _imageBoxFit;

    Widget image;
    if (url.startsWith('/')) {
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
    } else {
      final headers = QuickJsService.getImageHeaders(_sourceName ?? '', url);

      image = Image.network(
        url,
        headers: headers,
        width: isWebtoon ? (constraints?.maxWidth ?? double.infinity) : null,
        fit: boxFit,
        gaplessPlayback: true,
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          if (isWebtoon) {
            return Container(
              height: 180,
              width: constraints?.maxWidth,
              color: _canvasBackgroundColor,
              child: Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary, strokeWidth: 2)),
            );
          }
          return Container(
            height: 400,
            color: _canvasBackgroundColor,
            child: Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary, strokeWidth: 2)),
          );
        },
        errorBuilder: (_, __, ___) => Container(
          height: 300,
          color: const Color(0xFF1A1A22),
          child: Center(
            child: Text('Page ${index + 1} Failed to Load', style: const TextStyle(color: Colors.grey)),
          ),
        ),
      );
    }

    if (_activeColorFilter != null) {
      image = ColorFiltered(colorFilter: _activeColorFilter!, child: image);
    }

    if (_cropBorders) {
      image = ClipRect(child: image);
    }

    if (isPaged) {
      return InteractiveViewer(
        minScale: 1.0,
        maxScale: 3.5,
        child: image,
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
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: () => _loadChapterAndPages(widget.chapterServerId),
                  child: const Text('Retry', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _canvasBackgroundColor,
      body: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return GestureDetector(
              onTapUp: (details) => _handleTapZone(details, constraints),
              child: Stack(
                children: [
                  // ── 1. READER CANVAS ──────────────────────────────
                  if (_readingMode == ReadingMode.webtoon || _readingMode == ReadingMode.continuousVertical)
                    ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.zero,
                      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                      cacheExtent: 2500,
                      itemCount: _pageUrls.isEmpty ? 0 : (_settings.seamlessTransitions ? _pageUrls.length + 1 : _pageUrls.length),
                      itemBuilder: (context, index) {
                        if (index == _pageUrls.length) {
                          return _buildChapterTransitionCard();
                        }
                        final pageWidget = _buildPageWidget(_pageUrls[index], index, constraints: constraints, isPaged: false);
                        return RepaintBoundary(
                          child: _readingMode == ReadingMode.continuousVertical
                              ? Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: Center(child: pageWidget),
                                )
                              : pageWidget,
                        );
                      },
                    )
                  else
                    PageView.builder(
                      controller: _pageController,
                      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
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
                  if (_showControls) ...[
                    // Top Overlay Bar
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
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
                              onPressed: () => context.pop(),
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
                                  Text(
                                    '${_readingMode.name.toUpperCase()} • ${_readerTheme.name.toUpperCase()}',
                                    style: TextStyle(color: primaryColor, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.tune_rounded, color: Colors.white),
                              onPressed: _showReaderSettingsSheet,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Bottom HUD Bar with Scrubber Slider
                    Positioned(
                      bottom: 24,
                      left: 16,
                      right: 16,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xE61F1F24),
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
                                  IconButton(
                                    icon: const Icon(Icons.skip_next_rounded, color: Colors.white),
                                    tooltip: 'Next Chapter',
                                    onPressed: _nextChapter != null ? () => _loadChapterAndPages(_nextChapter!.serverId) : null,
                                  ),
                                ],
                              ),
                              if (_pageUrls.length > 1)
                                SizedBox(
                                  width: 260,
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
                                          _pageController.jumpToPage(targetPage - 1);
                                        } else {
                                          final targetOffset = ((targetPage - 1) / (_pageUrls.length - 1)) * _scrollController.position.maxScrollExtent;
                                          _scrollController.jumpTo(targetOffset);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
