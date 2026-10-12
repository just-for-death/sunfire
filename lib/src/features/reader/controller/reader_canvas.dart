// lib/src/features/reader/controller/reader_canvas.dart
//
// CustomPainter-based rendering for the v6 reader.
// Handles:
// - Single page rendering (paged & webtoon)
// - Double-page spreads with RTL support
// - Per-page zoom (InteractiveViewer)
// - Color filters, crop borders
// - Placeholder/error states
// - Chapter transition cards

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../core/engine/quickjs_service.dart';
import '../../../core/engine/javascript/m_client.dart';
import '../../../core/db/models/chapter.dart';
import '../double_page_layout.dart';
import '../reading_mode.dart';
import 'reader_controller.dart';
import 'reader_theme.dart';

/// ReaderCanvas — renders manga pages using CustomPainter for performance.
///
/// Features:
/// - Paged (LTR/RTL) and webtoon (long strip) modes
/// - Double-page spreads with wide-page isolation
/// - Per-page zoom via InteractiveViewer
/// - Color filters, crop borders
/// - Webtoon page gaps and overlap
/// - Chapter transition cards
/// - Image loading/error placeholders
class ReaderCanvas extends StatefulWidget {
  const ReaderCanvas({
    super.key,
    required this.controller,
    required this.scrollController,
    required this.pageController,
    required this.transformationController,
    required this.webtoonZoomControllers,
    required this.webtoonPageKeys,
    required this.readingMode,
    required this.pageUrls,
    required this.currentPage,
    required this.colorFilter,
    required this.cropBorders,
    required this.scaleType,
    required this.readerTheme,
    this.onPageChanged,
    this.onImageRecovered,
    this.showTransitionCard = false,
    this.nextChapter,
    this.chapter,
  });

  final ReaderController controller;
  final ScrollController scrollController;
  final PageController pageController;
  final TransformationController transformationController;
  final Map<int, TransformationController> webtoonZoomControllers;
  final Map<int, GlobalKey> webtoonPageKeys;
  final ReadingMode readingMode;
  final List<String> pageUrls;
  final int currentPage;
  final ReaderColorFilter colorFilter;
  final bool cropBorders;
  final ImageScaleType scaleType;
  final ReaderThemeMode readerTheme;
  final Chapter? chapter;
  final Chapter? nextChapter;
  final bool showTransitionCard;
  final void Function(int page)? onPageChanged;
  final void Function(String url, int index)? onImageRecovered;

  @override
  State<ReaderCanvas> createState() => _ReaderCanvasState();
}

class _ReaderCanvasState extends State<ReaderCanvas> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // ─── Build ────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isPaged = isPagedReadingMode(widget.readingMode);
    final isRtl = widget.readingMode == ReadingMode.pagedRtl;

    // S6.6: screen-reader announcement for the current page/chapter.
    final total = widget.pageUrls.length;
    final label = widget.chapter != null
        ? 'Page ${widget.currentPage} of $total, ${widget.chapter!.name}'
        : 'Page ${widget.currentPage} of $total';

    final Widget content;
    if (isPaged) {
      content = _buildPagedView(context, isRtl);
    } else {
      content = _buildWebtoonView(context);
    }
    return Semantics(
      label: label,
      image: false,
      container: true,
      child: content,
    );
  }

  // ─── Paged Mode ──────────────────────────────────────────────────

  Widget _buildPagedView(BuildContext context, bool isRtl) {
    final useDouble = _shouldUseDoublePages(context);
    final slots = useDouble ? _currentSpreadSlots() : const <SpreadSlot>[];
    final contentCount = useDouble ? slots.length : widget.pageUrls.length;
    final withTransition = widget.showTransitionCard && widget.pageUrls.isNotEmpty;
    final itemCount = widget.pageUrls.isEmpty ? 0 : (withTransition ? contentCount + 1 : contentCount);

    return PageView.builder(
      controller: widget.pageController,
      physics: widget.controller.isZoomed
          ? const NeverScrollableScrollPhysics()
          : const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      reverse: isRtl,
      itemCount: itemCount,
      onPageChanged: widget.onPageChanged,
      itemBuilder: (context, index) {
        if (withTransition && index == contentCount) {
          return _buildTransitionCard(context);
        }
        if (useDouble) {
          return _buildSpreadItem(context, slots[index], index);
        }
        return _buildSinglePageItem(context, index);
      },
    );
  }

  Widget _buildSpreadItem(BuildContext context, SpreadSlot slot, int spreadIndex) {
    final order = slot.visualOrder(invertDoublePages: widget.controller.invertTaps);
    final left = order.$1;
    final right = order.$2;

    Widget pageAt(int i) => Expanded(
      child: Center(
        child: _buildPageWidget(
          widget.pageUrls[i],
          i,
          isPaged: true,
        ),
      ),
    );

    if (right == null) {
      return RepaintBoundary(
        child: Row(children: [pageAt(left)]),
      );
    }
    return RepaintBoundary(
      child: Row(children: [pageAt(left), pageAt(right)]),
    );
  }

  Widget _buildSinglePageItem(BuildContext context, int index) {
    return RepaintBoundary(
      child: Center(child: _buildPageWidget(widget.pageUrls[index], index, isPaged: true)),
    );
  }

  // ─── Webtoon Mode ────────────────────────────────────────────────

  Widget _buildWebtoonView(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 800;
    final contentWidth = isWideScreen ? 780.0 : MediaQuery.of(context).size.width;
    final gap = webtoonPageGap(widget.readingMode);
    final withTransition = widget.showTransitionCard && widget.pageUrls.isNotEmpty;
    final itemCount = widget.pageUrls.isEmpty ? 0 : (withTransition ? widget.pageUrls.length + 1 : widget.pageUrls.length);

    final dragDevices = <PointerDeviceKind>{
      PointerDeviceKind.touch,
      PointerDeviceKind.mouse,
      PointerDeviceKind.trackpad,
      PointerDeviceKind.stylus,
    };

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(dragDevices: dragDevices),
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        child: ListView.builder(
          controller: widget.scrollController,
          padding: EdgeInsets.zero,
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          scrollCacheExtent: ScrollCacheExtent.pixels(2500),
          addRepaintBoundaries: false,
          clipBehavior: Clip.none,
          itemCount: itemCount,
          itemBuilder: (context, index) {
            if (withTransition && index == widget.pageUrls.length) {
              return _buildTransitionCard(context);
            }
            final pageWidget = _buildPageWidget(
              widget.pageUrls[index],
              index,
              isPaged: false,
              contentWidth: contentWidth,
              enablePerPageZoom: true,
            );
            final itemKey = widget.webtoonPageKeys.putIfAbsent(index, () => GlobalKey());

            Widget item = KeyedSubtree(
              key: itemKey,
              child: RepaintBoundary(
                child: Center(
                  child: SizedBox(
                    width: contentWidth,
                    child: pageWidget,
                  ),
                ),
              ),
            );

            if (gap > 0) {
              return Padding(padding: EdgeInsets.only(bottom: gap), child: item);
            }

            if (webtoonShouldOverlapPrevious(widget.readingMode, index)) {
              item = Transform.translate(offset: const Offset(0, -1), child: item);
            }
            return item;
          },
        ),
      ),
    );
  }

  // ─── Page Widget ─────────────────────────────────────────────────

  Widget _buildPageWidget(
    String url,
    int index, {
    required bool isPaged,
    double? contentWidth,
    bool enablePerPageZoom = false,
  }) {
    final colorFilter = activeColorFilter(widget.colorFilter);

    Widget image = Image.network(
      url,
      headers: _buildHeaders(url),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return _buildPlaceholder(loadingProgress);
      },
      errorBuilder: (context, error, stackTrace) {
        return _buildErrorWidget(url, index, error);
      },
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          return child;
        }
        return _buildPlaceholder(null);
      },
    );

    if (colorFilter != null) {
      image = ColorFiltered(colorFilter: colorFilter, child: image);
    }

    if (widget.cropBorders) {
      image = ClipRect(child: image);
    }

    // Wrap with zoom for paged mode or webtoon with per-page zoom
    final useZoom = isPaged || enablePerPageZoom;
    if (useZoom) {
      final transform = enablePerPageZoom
          ? widget.webtoonZoomControllers.putIfAbsent(index, TransformationController.new)
          : widget.transformationController;

      if (enablePerPageZoom) {
        _pruneWebtoonZoomState(index);
      }

      image = GestureDetector(
        onDoubleTapDown: (details) {
          widget.controller.setDoubleTapDetails(details.localPosition);
        },
        onDoubleTap: () {
          if (!enablePerPageZoom) {
            widget.controller.handleDoubleTapZoom();
            return;
          }
          widget.controller.handleDoubleTapZoom(controllerOverride: transform);
        },
        child: InteractiveViewer(
          transformationController: transform,
          minScale: 1.0,
          maxScale: 3.5,
          panEnabled: enablePerPageZoom
              ? (transform.value.getMaxScaleOnAxis() > 1.05)
              : widget.controller.isZoomed,
          onInteractionUpdate: (_) {
            if (!enablePerPageZoom) {
              // Zoom state sync handled by controller
            }
          },
          onInteractionEnd: (_) {
            if (!enablePerPageZoom) {
              // Zoom state sync handled by controller
            }
          },
          child: image,
        ),
      );
    }

    return image;
  }

  Widget _buildPlaceholder(ImageChunkEvent? progress) {
    return Container(
      color: canvasBackgroundColor(widget.readerTheme),
      child: Center(
        child: progress != null && progress.expectedTotalBytes != null
            ? CircularProgressIndicator(
                value: progress.cumulativeBytesLoaded / progress.expectedTotalBytes!,
                strokeWidth: 2,
              )
            : const CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildErrorWidget(String url, int index, Object error) {
    return Container(
      color: canvasBackgroundColor(widget.readerTheme),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.broken_image_rounded, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              'Failed to load image',
              style: TextStyle(color: Colors.grey[400]),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
              onPressed: () => widget.onImageRecovered?.call(url, index),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Transition Card ────────────────────────────────────────────

  Widget _buildTransitionCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = colorScheme.primary;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          constraints: const BoxConstraints(maxWidth: 460),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.chapter != null)
                _buildTransitionSection(
                  label: 'Finished',
                  chapter: widget.chapter!,
                  labelColor: primaryColor,
                ),
              const SizedBox(height: 28),
              if (widget.nextChapter != null) ...[
                _buildTransitionSection(
                  label: 'Next',
                  chapter: widget.nextChapter!,
                  labelColor: primaryColor,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: () => widget.controller.loadNextChapter(),
                    child: const Text(
                      'Read Next Chapter',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ),
                ),
              ] else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outlineVariant, width: 0.8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: primaryColor, size: 20),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Text(
                          "You're all caught up — there's no next chapter.",
                          style: TextStyle(fontSize: 13, height: 1.35),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransitionSection({
    required String label,
    required Chapter chapter,
    required Color labelColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: labelColor,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            if (chapter.isDownloaded) ...[
              Icon(Icons.check_circle_rounded, color: labelColor, size: 18),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                chapter.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Helpers ────────────────────────────────────────────────────

  bool _shouldUseDoublePages(BuildContext context) {
    final mode = parseDoublePageDisplayMode(widget.controller.settings.doublePageDisplayMode);
    final isLandscape = MediaQuery.of(context).size.width > MediaQuery.of(context).size.height;
    return shouldUseDoublePages(mode: mode, isLandscape: isLandscape);
  }

  List<SpreadSlot> _currentSpreadSlots() {
    final slots = <SpreadSlot>[];
    if (widget.pageUrls.length < 2) return slots;

    for (var i = 0; i < widget.pageUrls.length; i += 2) {
      if (i + 1 < widget.pageUrls.length) {
        slots.add(SpreadSlot(primaryIndex: i, secondaryIndex: i + 1));
      } else {
        slots.add(SpreadSlot(primaryIndex: i, secondaryIndex: null));
      }
    }
    return slots;
  }

  Map<String, String> _buildHeaders(String url) {
    final baseHeaders = QuickJsService.getImageHeaders(
      widget.controller.parentManga?.sourceName ?? '',
      url,
    );
    final cookieHeaders = MClient.getCookiesPref(url);
    return {
      ...baseHeaders,
      ...cookieHeaders,
      'User-Agent': MClient.userAgent,
    };
  }

  void _pruneWebtoonZoomState(int currentIndex) {
    const keepWindow = 40;
    final evict = widget.webtoonZoomControllers.keys
        .where((k) => (k - currentIndex).abs() > keepWindow)
        .toList();
    for (final k in evict) {
      widget.webtoonZoomControllers.remove(k)?.dispose();
      widget.webtoonPageKeys.remove(k);
    }
  }
}