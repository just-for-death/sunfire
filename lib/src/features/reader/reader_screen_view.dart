// Widget tree: scaffold/states, canvases, page widgets, sheets, menu actions, layout height cache, reading-mode prefs.
// Split from reader_screen.dart (v6 Step 9); no behaviour change.
part of 'reader_screen.dart';

extension _ReaderView on _ReaderScreenState {

  Future<void> _clearCookiesAndCache() async {
    final ok = await ContentResolverService.instance.clearCookiesAndCache();
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Cookies and cache cleared. Tap Retry to reload.'
              : 'Could not clear cookies. Check the server connection.',
        ),
      ),
    );
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
      } else if (effectiveUrl.contains('.') && !effectiveUrl.contains(' ')) {
        effectiveUrl = 'https://$effectiveUrl';
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

  bool _doublePagesActive(BoxConstraints constraints) {
    if (!isPagedReadingMode(_readingMode)) return false;
    final mode = parseDoublePageDisplayMode(_settings.doublePageDisplayMode);
    final landscape = constraints.maxWidth > constraints.maxHeight;
    return shouldUseDoublePages(mode: mode, isLandscape: landscape);
  }

  List<bool> _wideFlagsForPages() {
    return [
      for (final url in _pageUrls) isWidePage(_cachedPageAspects[url]),
    ];
  }

  List<SpreadSlot> _currentSpreadSlots() {
    if (!isPagedReadingMode(_readingMode)) return const [];
    return buildSpreadSlots(
      pageCount: _pageUrls.length,
      pageOffset: _settings.doublePageOffset,
      wideFlags: _wideFlagsForPages(),
    );
  }

  ReaderPageBuilder _livePageBuilder(BoxConstraints constraints) {
    return (context, url, index,
        {required bool isPaged,
        double? contentWidth,
        bool enablePerPageZoom = false}) {
      return _buildPageWidget(
        url,
        index,
        constraints: constraints,
        isPaged: isPaged,
        contentWidth: contentWidth,
        enablePerPageZoom: enablePerPageZoom,
      );
    };
  }

  /// R1.6: webtoon layout via [ReaderCanvas]; pages still built by live recover path.
  Widget _buildLiveWebtoonCanvas(BoxConstraints constraints) {
    return ValueListenableBuilder<List<ReaderChapterPages>>(
      valueListenable: _readerController.stripChaptersListenable,
      builder: (context, strip, _) => _buildLiveWebtoonCanvasFor(constraints, strip),
    );
  }

  /// IMP-012: with seamless transitions on and the next chapter's pages ready,
  /// the strip shows current + next with a chapterBoundary separator. Item
  /// indices for the current chapter equal its page indices.
  Widget _buildLiveWebtoonCanvasFor(BoxConstraints constraints, List<ReaderChapterPages> strip) {
    _syncReaderControllerPresentation();
    final webtoonItems = _readerController.activeStripItems;
    final showTransition =
        webtoonItems == null &&
        _pageUrls.isNotEmpty &&
        _settings.seamlessTransitions &&
        _settings.showEndOfChapterDialog;
    return ReaderCanvas(
      webtoonItems: webtoonItems,
      controller: _readerController,
      scrollController: _scrollController,
      pageController: _pageController,
      transformationController: _transformationController,
      webtoonZoomControllers: _webtoonZoomControllers,
      readingMode: _readingMode,
      pageUrls: _pageUrls,
      currentPage: _currentPage,
      colorFilter: _colorFilter,
      cropBorders: _cropBorders,
      scaleType: _scaleType,
      readerTheme: _readerTheme,
      chapter: _chapter,
      nextChapter: _nextChapter,
      showTransitionCard: showTransition,
      transitionBuilder: (_) => _buildChapterTransitionCard(),
      onRequestNextChapter: () {
        if (_nextChapter == null) return;
        unawaited(_readerController.loadChapter(_chapterTargetId(_nextChapter!)));
      },
      pageBuilder: _livePageBuilder(constraints),
    );
  }

  /// R1.6: paged layout via [ReaderCanvas] with live spread isolation + pageBuilder.
  Widget _buildLivePagedCanvas(BoxConstraints constraints) {
    _syncReaderControllerPresentation();
    final useDouble = _doublePagesActive(constraints);
    final slots = useDouble ? _currentSpreadSlots() : const <SpreadSlot>[];
    final showTransition =
        _pageUrls.isNotEmpty &&
        _settings.seamlessTransitions &&
        _settings.showEndOfChapterDialog;
    return ReaderCanvas(
      controller: _readerController,
      scrollController: _scrollController,
      pageController: _pageController,
      transformationController: _transformationController,
      webtoonZoomControllers: _webtoonZoomControllers,
      readingMode: _readingMode,
      pageUrls: _pageUrls,
      currentPage: _currentPage,
      colorFilter: _colorFilter,
      cropBorders: _cropBorders,
      scaleType: _scaleType,
      readerTheme: _readerTheme,
      chapter: _chapter,
      nextChapter: _nextChapter,
      showTransitionCard: showTransition,
      spreadSlots: slots,
      onPageChanged: _onPageChanged,
      transitionBuilder: (_) => Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: _buildChapterTransitionCard(),
        ),
      ),
      onRequestNextChapter: () {
        if (_nextChapter == null) return;
        unawaited(_readerController.loadChapter(_chapterTargetId(_nextChapter!)));
      },
      pageBuilder: _livePageBuilder(constraints),
    );
  }

  // R1.7: theme/filter/scale helpers live in reader_theme.dart.
  Color get _canvasBackgroundColor => canvasBackgroundColor(_readerTheme);

  Future<void> _toggleReaderBookmark() async {
    final target = _chapter;
    if (target == null) return;
    // Snapshot: _chapter is reassigned by chapter loads; saving/syncing the
    // live field after the await below could persist and push the WRONG
    // (newly loaded) chapter's state.
    final newState = !target.isBookmarked;
    _rebuild(() => target.isBookmarked = newState);
    await IsarService.instance.saveChapter(target);
    if (target.serverId > 0) {
      unawaited(SyncEngine.instance.syncChapterBookmark(target.serverId, newState));
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(newState ? 'Bookmark added' : 'Bookmark removed'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// IMP-013: "This series" saves a per-series override; "All" writes the
  /// global setting and clears this series' override for [key].
  void _persistScopedSetting(String key, Object value, VoidCallback writeGlobal) {
    final manga = _parentManga;
    if (manga == null) {
      writeGlobal();
      return;
    }
    final current = loadReaderSettingsOverride(_settings, manga.id);
    if (_readerSettingsScope == ReaderSettingsScope.manga) {
      unawaited(saveReaderSettingsOverride(_settings, manga.id, current.withValue(key, value)));
    } else {
      writeGlobal();
      unawaited(saveReaderSettingsOverride(_settings, manga.id, current.withValue(key, null)));
    }
  }

  void _showReaderSettingsSheet() {
    unawaited(ReaderSettingsSheet.show(
      context: context,
      model: ReaderSettingsSheetModel(
        settings: _settings,
        hasParentManga: _parentManga != null,
        scope: _readerSettingsScope,
        readingMode: _readingMode,
        readerTheme: _readerTheme,
        colorFilter: _colorFilter,
        scaleType: _scaleType,
        invertTaps: _invertTaps,
        cropBorders: _cropBorders,
        onScopeChanged: (next) {
          _rebuild(() => _readerSettingsScope = next);
          unawaited(_persistReadingMode(_readingMode));
        },
        onApplyReadingMode: _applyReadingMode,
        onThemeChanged: (theme) {
          _rebuild(() => _readerTheme = theme);
          _settings.readerTheme = themeModeLabel(theme);
        },
        onColorFilterChanged: (filter) {
          _rebuild(() => _colorFilter = filter);
          _settings.colorFilter = colorFilterLabel(filter);
        },
        onScaleTypeChanged: (scale) {
          _rebuild(() => _scaleType = scale);
          _persistScopedSetting('scaleType', scaleTypeLabel(scale),
              () => _settings.scaleType = scaleTypeLabel(scale));
        },
        onInvertTapsChanged: (val) {
          _rebuild(() => _invertTaps = val);
          _persistScopedSetting('invertTapZones', val, () => _settings.invertTapZones = val);
        },
        onCropBordersChanged: (val) {
          _rebuild(() => _cropBorders = val);
          _persistScopedSetting('cropBorders', val, () => _settings.cropBorders = val);
        },
        onKeepScreenAwakeChanged: (val) {
          _rebuild(() => _settings.keepScreenAwake = val);
          _safeSetWakelock(val);
        },
      ),
    ));
  }

  void _showChapterSelectorSheet() {
    unawaited(ReaderChapterSelectorSheet.show(
      context: context,
      siblings: _siblingChapters,
      current: _chapter,
      onSelect: (ch) {
        unawaited(_readerController.loadChapter(_chapterTargetId(ch)));
      },
    ));
  }

  /// R9.3/R9.4: Listen sheet - OCR transcript with TTS playback.
  void _showListenSheet() {
    if (_pageUrls.isEmpty) return;
    final safePage = _currentPage.clamp(1, _pageUrls.length);
    final currentUrl = _pageUrls[safePage - 1];
    final headers = QuickJsService.getImageHeaders(_sourceName ?? '', currentUrl);
    unawaited(ListenSheet.show(
      context,
      pageUrl: currentUrl,
      headers: headers,
      title: _chapter?.name ?? 'Page $_currentPage',
    ));
  }

  Widget _buildPageWidget(String url, int index, {BoxConstraints? constraints, bool isPaged = false, double? contentWidth, bool enablePerPageZoom = false}) {
    _resyncHeightBucket(contentWidth ?? constraints?.maxWidth);
    return buildReaderPageWidget(ReaderPageWidgetConfig(
      url: url,
      devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
      index: index,
      constraints: constraints,
      isPaged: isPaged,
      contentWidth: contentWidth,
      enablePerPageZoom: enablePerPageZoom,
      readingMode: _readingMode,
      colorFilter: _colorFilter,
      cropBorders: _cropBorders,
      scaleType: _scaleType,
      readerTheme: _readerTheme,
      pageLoader: _pageLoader,
      sourceName: _sourceName ?? '',
      settings: _settings,
      cachedPageHeights: _cachedPageHeights,
      cachedPageAspects: _cachedPageAspects,
      recoveringUrls: _recoveringUrls,
      failedImageUrls: _failedImageUrls,
      canvasBackgroundColor: _canvasBackgroundColor,
      colorScheme: Theme.of(context).colorScheme,
      onRecoverImage: _recoverImage,
      onScheduleHeightCache: _schedulePageHeightCacheForProvider,
      onDoubleTapDown: (details) => _doubleTapDetails = details,
      onDoubleTapZoom: _handleDoubleTapZoom,
      onPruneZoomState: _pruneWebtoonZoomState,
      webtoonZoomControllerFor: _webtoonZoomControllerFor,
      transformationController: _transformationController,
      minZoomScale: _ReaderScreenState._minZoomScale,
      maxZoomScale: _ReaderScreenState._maxZoomScale,
      isZoomed: _isZoomed,
      onInteractionUpdate: (details) {
        _syncGesturePipelineState();
        _gesturePipeline.handleInteractionUpdate(details);
      },
      onInteractionEnd: (details) {
        _syncGesturePipelineState();
        _gesturePipeline.handleInteractionEnd(details);
      },
    ));
  }

  Widget _buildChapterTransitionCard() {
    return ReaderChapterTransitionCard(
      chapter: _chapter,
      nextChapter: _nextChapter,
      onReadNext: () {
        if (_nextChapter == null) return;
        unawaited(
            _readerController.loadChapter(_chapterTargetId(_nextChapter!)));
      },
    );
  }

  Widget _buildScreen(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: _canvasBackgroundColor,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: primaryColor),
              const SizedBox(height: SunfireSpacing.lg),
              Text(
                _chapter?.name ?? 'Loading Chapter...',
                style: TextStyle(color: canvasForegroundColor(_canvasBackgroundColor).withValues(alpha: 0.7), fontSize: 14, fontWeight: FontWeight.bold),
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
          backgroundColor: SunfireColors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: canvasForegroundColor(_canvasBackgroundColor)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.broken_image_rounded, size: 64, color: SunfireColors.contentTertiary),
                const SizedBox(height: SunfireSpacing.lg),
                Text(
                  'Could not load ${_chapter?.name.replaceAll(RegExp(r'\s+'), ' ').trim() ?? "chapter pages"}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: canvasForegroundColor(_canvasBackgroundColor), fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: SunfireSpacing.sm),
                const Text(
                  'Check network or source availability',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: SunfireColors.contentTertiary, fontSize: 13),
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
                        // IMP-018: theme contrast pair instead of white on accent.
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SunfireRadius.md)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      icon: const Icon(Icons.refresh_rounded, size: SunfireIconSize.std),
                      onPressed: () => _readerController.loadChapter(_currentChapterId),
                      label: const Text('Retry', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: canvasForegroundColor(_canvasBackgroundColor),
                        side: BorderSide(color: canvasForegroundColor(_canvasBackgroundColor).withValues(alpha: 0.2)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SunfireRadius.md)),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      ),
                      icon: const Icon(Icons.open_in_browser_rounded, size: SunfireIconSize.std),
                      onPressed: _openChapterInBrowser,
                      label: const Text('Open in Browser', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    if (SettingsService.instance.cfProxyUrl.isEmpty)
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.tertiary,
                          side: BorderSide(color: Theme.of(context).colorScheme.tertiary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SunfireRadius.md)),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        ),
                        icon: const Icon(Icons.security_rounded, size: SunfireIconSize.std),
                        onPressed: () => context.push('/settings/advanced'),
                        label: const Text('Configure FlareSolverr', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    OutlinedButton.icon(
                      key: const Key('reader_clear_cookies_button'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: canvasForegroundColor(_canvasBackgroundColor).withValues(alpha: 0.7),
                        side: BorderSide(color: canvasForegroundColor(_canvasBackgroundColor).withValues(alpha: 0.2)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SunfireRadius.md)),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      ),
                      icon: const Icon(Icons.cleaning_services_outlined, size: SunfireIconSize.std),
                      onPressed: () => unawaited(_clearCookiesAndCache()),
                      label: const Text('Clear cookies', style: TextStyle(fontWeight: FontWeight.bold)),
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
          _rebuild(() {
            _showControls = true;
            unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
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
              onPointerDown: (e) {
                _syncGesturePipelineState();
                _gesturePipeline.handlePointerDown(e);
              },
              onPointerUp: (e) {
                _syncGesturePipelineState();
                _gesturePipeline.handlePointerUp(e);
              },
              onPointerCancel: (e) {
                _syncGesturePipelineState();
                _gesturePipeline.handlePointerCancel(e);
              },
              onPointerSignal: (pointerSignal) {
                _syncGesturePipelineState();
                _gesturePipeline.handlePointerSignal(pointerSignal);
              },
              child: GestureDetector(
                onTapUp: (details) => _handleTapZone(details, constraints),
                child: Stack(
                children: [
                  // ── 1. READER CANVAS (+ iPad sidebar on tablets) ──
                  if (SunfireBreakpoints.isTabletLayout(context) && _showControls && _siblingChapters.isNotEmpty)
                    Row(
                      children: [
                        ReaderChapterSidebar(
                          siblings: _siblingChapters,
                          current: _chapter,
                          onSelect: (ch) => unawaited(_readerController.loadChapter(_chapterTargetId(ch))),
                        ),
                        Expanded(
                          child: ScrollConfiguration(
                            behavior: ScrollConfiguration.of(context).copyWith(
                              dragDevices: {
                                PointerDeviceKind.touch,
                                PointerDeviceKind.mouse,
                                PointerDeviceKind.trackpad,
                                PointerDeviceKind.stylus,
                              },
                            ),
                            child: _readingMode == ReadingMode.longStrip ||
                                    _readingMode == ReadingMode.longStripGaps
                                ? _buildLiveWebtoonCanvas(constraints)
                                : _buildLivePagedCanvas(constraints),
                          ),
                        ),
                      ],
                    )
                  else
                    ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(
                        dragDevices: {
                          PointerDeviceKind.touch,
                          PointerDeviceKind.mouse,
                          PointerDeviceKind.trackpad,
                          PointerDeviceKind.stylus,
                        },
                      ),
                      child: _readingMode == ReadingMode.longStrip ||
                              _readingMode == ReadingMode.longStripGaps
                          ? _buildLiveWebtoonCanvas(constraints)
                          : _buildLivePagedCanvas(constraints),
                    ),

                  // ── 1b. FIRST-RUN TAP ZONE OVERLAY ───────────────
                  if (_showTapZoneOverlay)
                    Positioned.fill(
                      child: TapZoneOverlay(
                        preset: _activeTapZonePreset(),
                        invert: _invertTaps,
                        rtlPaged: _readingMode == ReadingMode.pagedRtl,
                        onDismissed: _dismissTapZoneOverlay,
                      ),
                    ),

                  // ── 2–4. OVERLAY HUD (R1.8 extracted) ──
                  Positioned.fill(
                    child: ReaderOverlayHud(
                    showControls: _showControls,
                    primaryColor: primaryColor,
                    chapter: _chapter,
                    readingMode: _readingMode,
                    readerTheme: _readerTheme,
                    incognitoMode: _settings.incognitoMode,
                    prevChapter: _prevChapter,
                    nextChapter: _nextChapter,
                    pageUrlsLength: _pageUrls.length,
                    pageIndicator: _pageIndicator,
                    scrollIndicatorVisible: _scrollIndicatorVisible,
                    isDraggingSlider: _isDraggingSlider,
                    sliderDragValue: _sliderDragValue,
                    isAutoScrolling: _isAutoScrolling,
                    isUserTouching: _isUserTouching,
                    autoScrollSpeed: _autoScrollSpeed,
                    isAutoScrollHudCollapsed: _isAutoScrollHudCollapsed,
                    autoScrollShowFloatingHud: _settings.autoScrollShowFloatingHud,
                    onExit: _safeExitReader,
                    onToggleBookmark: _toggleReaderBookmark,
                    onToggleIncognito: () {
                      _rebuild(() => _settings.incognitoMode = !_settings.incognitoMode);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(_settings.incognitoMode
                              ? 'Incognito Mode Active (History & tracking paused)'
                              : 'Incognito Mode Deactivated'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    onShowChapters: _showChapterSelectorSheet,
                    onShowListen: _showListenSheet,
                    onShowSettings: _showReaderSettingsSheet,
                    onLoadPrevChapter: _prevChapter != null
                        ? () => _readerController.loadChapter(_chapterTargetId(_prevChapter!))
                        : null,
                    onLoadNextChapter: _nextChapter != null
                        ? () => _readerController.loadChapter(_chapterTargetId(_nextChapter!))
                        : null,
                    onCycleReadingMode: _cycleReadingMode,
                    onToggleAutoScroll: _toggleAutoScroll,
                    onShowAutoScrollSpeed: _showAutoScrollSpeedDialog,
                    onSliderChangeStart: () {
                      _rebuild(() => _isDraggingSlider = true);
                    },
                    onSliderChanged: (val) {
                      final targetPage = val.round();
                      _rebuild(() {
                        _sliderDragValue = val;
                        _currentPage = targetPage;
                      });
                      _setPageIndicator(targetPage);
                      if (isPagedReadingMode(_readingMode)) {
                        if (_pageController.hasClients) {
                          _pageController.jumpToPage(_pagedControllerIndexForPage(targetPage));
                        }
                      } else if (_scrollController.hasClients) {
                        _jumpToWebtoonPage(targetPage);
                      }
                    },
                    onSliderChangeEnd: (val) {
                      final targetPage = val.round();
                      _rebuild(() {
                        _isDraggingSlider = false;
                        _sliderDragValue = null;
                        _currentPage = targetPage;
                      });
                      _setPageIndicator(targetPage);
                      _debouncedUpdateProgress(targetPage);
                    },
                    onAutoScrollSpeedDelta: (delta) {
                      _rebuild(() {
                        _autoScrollSpeed =
                            (_autoScrollSpeed + delta).clamp(10.0, 2000.0);
                      });
                    },
                    onAutoScrollSpeedCycle: () {
                      _rebuild(() {
                        if (_autoScrollSpeed < 180.0) {
                          _autoScrollSpeed = 250.0;
                        } else if (_autoScrollSpeed < 450.0) {
                          _autoScrollSpeed = 500.0;
                        } else {
                          _autoScrollSpeed = _settings.defaultAutoScrollSpeed;
                        }
                      });
                    },
                    onCollapseAutoScrollHud: () {
                      _rebuild(() => _isAutoScrollHudCollapsed = true);
                    },
                    onExpandAutoScrollHud: () {
                      _rebuild(() => _isAutoScrollHudCollapsed = false);
                    },
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

  void _rememberPageHeight(String url, double width, Size intrinsic) {
    final h = fittedHeightForWidth(intrinsic, width);
    if (intrinsic.height > 0) {
      _cachedPageAspects[url] = intrinsic.width / intrinsic.height;
    }
    final prev = _cachedPageHeights[url];
    if (prev != null && (prev - h).abs() < 1.0) return;
    _cachedPageHeights[url] = h;
    // R1.8: keep PageLoader height cache in sync for layout consumers.
    _pageLoader?.cacheHeight(url, h);
    // The placeholder was an estimate: rebuild once (guarded to the live
    // chapter) so the strip adopts the intrinsic height now instead of
    // jumping on the next unrelated rebuild. Debounce so a burst of probes
    // (long chapters) coalesces into a single frame.
    if (_pageUrls.contains(url)) {
      _heightRebuildTimer?.cancel();
      _heightRebuildTimer = Timer(const Duration(milliseconds: 16), () {
        _heightRebuildTimer = null;
        if (mounted) _rebuild(() {});
      });
    }
  }

  void _schedulePageHeightCacheForProvider(String url, double width, ImageProvider provider) {
    // Failed URLs must never be probed again: resolving them would issue a
    // fresh network fetch and, when the stream never completes, leak the
    // ImageStreamListener. Cached heights are already known — skip those too.
    if (_failedImageUrls.contains(url) || _cachedPageHeights.containsKey(url)) return;
    // The only dedup used to be the height cache, which is absent while a page
    // is still LOADING — the normal state. So every rebuild of a loading page
    // attached ANOTHER listener to the same ImageStream, and the stream held
    // them all: neither the closure nor the ImageStreamCompleter was
    // collectable, so memory grew for the life of the chapter and each
    // notifyListeners fanned out to N listeners. On a slow CDN, scrolling back
    // and forth over one page added one per frame per visit.
    if (!_heightProbesInFlight.add(url)) return;

    final stream = provider.resolve(ImageConfiguration(size: Size(width, width * 2)));
    late final ImageStreamListener listener;
    var released = false;
    Timer? watchdog;
    void release() {
      // Idempotent. An ImageStream can deliver onError and then onImage for the
      // same key (Flutter's completer transitions loading -> error, and a
      // subsequent resolve of the same key creates a new completer). A second
      // call would remove a NEWER probe's dedup entry for this url, after
      // which a rebuild could stack a second listener — reintroducing exactly
      // the leak this guard exists to prevent.
      if (released) return;
      released = true;
      watchdog?.cancel();
      _heightProbesInFlight.remove(url);
      stream.removeListener(listener);
    }

    listener = ImageStreamListener((info, _) {
      _rememberPageHeight(url, width, Size(info.image.width.toDouble(), info.image.height.toDouble()));
      release();
    }, onError: (_, __) {
      release();
    });
    stream.addListener(listener);
    // A hung stream (or a page scrolled away before completion) must not
    // pin the dedup entry forever and block all future probes for the URL.
    watchdog = Timer(const Duration(seconds: 30), release);
  }

  /// Layout-width bucket lives on the state (extensions cannot hold
  /// instance fields); see [_heightWidthBucket].
  void _resyncHeightBucket(double? width) {
    if (width == null) return;
    final bucket = (width / 8).round();
    if (bucket == _heightWidthBucket) return;
    _heightWidthBucket = bucket;
    _cachedPageHeights.clear();
    _pageLoader?.clearHeights();
  }

  void _applyMangaReadingMode(Manga? manga) {
    _parentManga = manga;
    _positionManager.setParentManga(manga);
    final override = manga?.readingModeOverride?.trim();
    _readerSettingsScope = initialReaderSettingsScope(override);
    if (override != null && override.isNotEmpty) {
      _readingMode = parseReadingMode(override);
    }
  }

  Future<void> _persistReadingMode(ReadingMode mode) async {
    final value = readingModeSettingsValue(mode);
    final plan = planReadingModePersist(
      scope: _readerSettingsScope,
      modeValue: value,
      hasManga: _parentManga != null,
    );
    if (plan.globalValue != null) {
      _settings.readingMode = plan.globalValue!;
    }
    if (_parentManga != null) {
      if (plan.clearMangaOverride) {
        _parentManga!.readingModeOverride = null;
        await IsarService.instance.saveManga(_parentManga!);
      } else if (plan.mangaOverride != null) {
        _parentManga!.readingModeOverride = plan.mangaOverride;
        await IsarService.instance.saveManga(_parentManga!);
      }
    }
  }
}
