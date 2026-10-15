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

import 'dart:async' show unawaited;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../core/db/models/chapter.dart';
import '../../../core/engine/javascript/m_client.dart';
import '../../../core/engine/quickjs_service.dart';
import '../../../ui/design_system/tokens/sunfire_colors.dart';
import '../../../ui/design_system/tokens/sunfire_spacing.dart';
import '../double_page_layout.dart';
import '../reading_mode.dart';
import 'navigation_controller.dart'
    show ReaderItem, ReaderPageItem, ReaderChapterBoundary, kReaderChapterBoundaryExtent;
import 'page_transition.dart';
import 'reader_controller.dart';
import 'reader_decode_size.dart';
import 'reader_theme.dart';
import 'webtoon_item_registry.dart';

/// Builds a page widget for [ReaderCanvas].
///
/// Live [ReaderScreen] supplies this so curl/recovery/desktop prefetch stay on
/// the production image path while the canvas owns layout.
typedef ReaderPageBuilder = Widget Function(
  BuildContext context,
  String url,
  int index, {
  required bool isPaged,
  double? contentWidth,
  bool enablePerPageZoom,
});

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
    this.pageBuilder,
    this.transitionBuilder,
    this.onRequestNextChapter,
    this.spreadSlots,
    this.webtoonItems,
  });

  final ReaderController controller;
  final ScrollController scrollController;
  final PageController pageController;
  final TransformationController transformationController;
  final Map<int, TransformationController> webtoonZoomControllers;
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
  /// When set, replaces the built-in Image.network page path (R1.6 live cutover).
  final ReaderPageBuilder? pageBuilder;
  /// When set, replaces the built-in end-of-chapter transition card.
  final WidgetBuilder? transitionBuilder;
  /// When set, used by the default transition card's "Read Next" button.
  final VoidCallback? onRequestNextChapter;
  /// When non-null, use these spread slots (live reader wide-page isolation).
  /// An empty list forces single-page paged layout.
  final List<SpreadSlot>? spreadSlots;
  /// IMP-012: when non-null in webtoon mode, the strip renders these items
  /// (pages of several chapters plus thin chapterBoundary separators) instead
  /// of [pageUrls] + end-of-chapter transition card. Index keys of
  /// [webtoonZoomControllers] keys are item indices.
  final List<ReaderItem>? webtoonItems;

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
    // IMP-011: vertical paged turns top-to-bottom; spreads stay horizontal-only.
    final isVertical = isVerticalPagedReadingMode(widget.readingMode);
    final useDouble = !isVertical && _shouldUseDoublePages(context);
    final slots = useDouble ? _currentSpreadSlots() : const <SpreadSlot>[];
    final contentCount = useDouble ? slots.length : widget.pageUrls.length;
    final withTransition = widget.showTransitionCard && widget.pageUrls.isNotEmpty;
    final itemCount = widget.pageUrls.isEmpty ? 0 : (withTransition ? contentCount + 1 : contentCount);
    final fade = parsePageTransition(widget.controller.settings.pageTransition) ==
        PageTransitionMode.fade;

    return PageView.builder(
      controller: widget.pageController,
      physics: widget.controller.isZoomed
          ? const NeverScrollableScrollPhysics()
          : const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      scrollDirection: isVertical ? Axis.vertical : Axis.horizontal,
      reverse: isRtl && !isVertical,
      itemCount: itemCount,
      onPageChanged: widget.onPageChanged,
      itemBuilder: (context, index) {
        final Widget item;
        if (withTransition && index == contentCount) {
          item = widget.transitionBuilder?.call(context) ??
              _buildTransitionCard(context);
        } else if (useDouble) {
          item = _buildSpreadItem(context, slots[index], index);
        } else {
          item = _buildSinglePageItem(context, index);
        }
        if (fade) return ReaderPageFadeIn(key: ValueKey(index), child: item);
        return item;
      },
    );
  }

  Widget _buildSpreadItem(BuildContext context, SpreadSlot slot, int spreadIndex) {
    final order = slot.visualOrder(
      invertDoublePages: widget.controller.settings.invertDoublePages,
    );
    final left = order.$1;
    final right = order.$2;

    Widget pageAt(int i) => Expanded(
      child: Center(
        child: _buildPageWidget(
          context,
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
      child: Center(
        child: _buildPageWidget(
          context,
          widget.pageUrls[index],
          index,
          isPaged: true,
        ),
      ),
    );
  }

  // ─── Webtoon Mode ────────────────────────────────────────────────

  Widget _buildWebtoonView(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 800;
    final contentWidth = isWideScreen ? 780.0 : MediaQuery.of(context).size.width;
    final gap = webtoonPageGap(widget.readingMode);
    final items = widget.webtoonItems;
    final withTransition =
        items == null && widget.showTransitionCard && widget.pageUrls.isNotEmpty;
    final itemCount = items != null
        ? items.length
        : widget.pageUrls.isEmpty
            ? 0
            : (withTransition ? widget.pageUrls.length + 1 : widget.pageUrls.length);

    final itemIndexByKey = <String, int>{
      for (var i = 0; i < itemCount; i++) webtoonItemKey(items, i): i,
    };

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
          // IMP-028: ~1.5 screens of look-ahead, scaled to the device
          // (was a fixed 2500px, i.e. 4+ screens on phones).
          scrollCacheExtent: const ScrollCacheExtent.viewport(1.5),
          // IMP-028: stable per-item keys let the list keep each page's
          // element when a strip trim shifts indices (no reload/flash).
          findChildIndexCallback: (key) {
            if (key is! ValueKey<String>) return null;
            final i = itemIndexByKey[key.value];
            return i;
          },
          addRepaintBoundaries: false,
          clipBehavior: Clip.none,
          itemCount: itemCount,
          itemBuilder: (context, index) {
            if (withTransition && index == widget.pageUrls.length) {
              return widget.transitionBuilder?.call(context) ??
                  _buildTransitionCard(context);
            }
            final readerItem = items?[index];
            if (readerItem is ReaderChapterBoundary) {
              return WebtoonItemSlot(
                key: ValueKey<String>(webtoonItemKey(items, index)),
                index: index,
                registry: widget.controller.webtoonItemRegistry,
                child: _buildChapterBoundary(context, readerItem, contentWidth),
              );
            }
            final pageWidget = _buildPageWidget(
              context,
              readerItem is ReaderPageItem ? readerItem.url : widget.pageUrls[index],
              index,
              isPaged: false,
              contentWidth: contentWidth,
              enablePerPageZoom: true,
            );
            // IMP-028: no GlobalKey per page; the slot registers its context.
            Widget item = WebtoonItemSlot(
              index: index,
              registry: widget.controller.webtoonItemRegistry,
              child: RepaintBoundary(
                child: Center(
                  child: SizedBox(
                    width: contentWidth,
                    child: pageWidget,
                  ),
                ),
              ),
            );

            final itemKey = ValueKey<String>(webtoonItemKey(items, index));
            if (gap > 0) {
              return Padding(key: itemKey, padding: EdgeInsets.only(bottom: gap), child: item);
            }

            final prevIsBoundary =
                items != null && index > 0 && items[index - 1] is ReaderChapterBoundary;
            if (!prevIsBoundary && webtoonShouldOverlapPrevious(widget.readingMode, index)) {
              item = Transform.translate(offset: const Offset(0, -1), child: item);
            }
            return KeyedSubtree(key: itemKey, child: item);
          },
        ),
      ),
    );
  }

  /// IMP-012: thin inline separator between two chapters in the strip.
  Widget _buildChapterBoundary(
    BuildContext context,
    ReaderChapterBoundary boundary,
    double contentWidth,
  ) {
    final name = boundary.next?.name;
    // Follow the reader theme so the separator stays readable on white too.
    final fg = canvasForegroundColor(canvasBackgroundColor(widget.readerTheme));
    return Center(
      key: ValueKey('chapterBoundary-${boundary.previous.id}'),
      child: SizedBox(
        width: contentWidth,
        // Fixed extent: lets the controller correct the scroll offset exactly
        // when a finished chapter is trimmed from the strip.
        height: kReaderChapterBoundaryExtent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Finished: ${boundary.previous.name}',
                style: TextStyle(color: fg.withValues(alpha: 0.54), fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: SunfireSpacing.sm),
              Divider(color: fg.withValues(alpha: 0.24), height: 1),
              const SizedBox(height: SunfireSpacing.sm),
              Text(
                name == null ? 'No next chapter' : 'Next: $name',
                style: TextStyle(
                  color: fg,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Page Widget ─────────────────────────────────────────────────

  Widget _buildPageWidget(
    BuildContext context,
    String url,
    int index, {
    required bool isPaged,
    double? contentWidth,
    bool enablePerPageZoom = false,
  }) {
    final custom = widget.pageBuilder;
    if (custom != null) {
      return custom(
        context,
        url,
        index,
        isPaged: isPaged,
        contentWidth: contentWidth,
        enablePerPageZoom: enablePerPageZoom,
      );
    }

    final colorFilter = activeColorFilter(widget.colorFilter);

    Widget image = Image.network(
      url,
      headers: _buildHeaders(url),
      // IMP-009: decode near display width (null = full size, as before).
      cacheWidth: readerDecodeCacheWidth(contentWidth, MediaQuery.devicePixelRatioOf(context)),
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
            const Icon(Icons.broken_image_rounded, size: SunfireIconSize.xxl, color: SunfireColors.contentTertiary),
            const SizedBox(height: SunfireSpacing.md),
            Text(
              'Failed to load image',
              style: TextStyle(color: SunfireColors.contentTertiary),
            ),
            const SizedBox(height: SunfireSpacing.sm),
            OutlinedButton.icon(
              icon: const Icon(Icons.refresh_rounded, size: SunfireIconSize.std),
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
                const SizedBox(height: SunfireSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SunfireRadius.md)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      if (widget.onRequestNextChapter != null) {
                        widget.onRequestNextChapter!();
                      } else {
                        unawaited(widget.controller.loadNextChapter());
                      }
                    },
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
                    borderRadius: BorderRadius.circular(SunfireRadius.md),
                    border: Border.all(color: colorScheme.outlineVariant, width: 0.8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: primaryColor, size: SunfireIconSize.md),
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
              Icon(Icons.check_circle_rounded, color: labelColor, size: SunfireIconSize.std),
              const SizedBox(width: SunfireSpacing.sm),
            ],
            Expanded(
              child: Text(
                chapter.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: SunfireColors.contentPrimary,
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
    final override = widget.spreadSlots;
    if (override != null) return override.isNotEmpty;
    final mode = parseDoublePageDisplayMode(widget.controller.settings.doublePageDisplayMode);
    final isLandscape = MediaQuery.of(context).size.width > MediaQuery.of(context).size.height;
    return shouldUseDoublePages(mode: mode, isLandscape: isLandscape);
  }

  List<SpreadSlot> _currentSpreadSlots() {
    final override = widget.spreadSlots;
    if (override != null) return override;
    return buildSpreadSlots(pageCount: widget.pageUrls.length);
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
    }
  }
}
/// IMP-014: fades a paged item in when it is first built (fade transition).
@visibleForTesting
class ReaderPageFadeIn extends StatefulWidget {
  const ReaderPageFadeIn({super.key, required this.child});
  final Widget child;

  @override
  State<ReaderPageFadeIn> createState() => _ReaderPageFadeInState();
}

class _ReaderPageFadeInState extends State<ReaderPageFadeIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 180),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      FadeTransition(opacity: _c, child: widget.child);
}

/// IMP-028: stable identity of webtoon item [index]: chapter + page for strip
/// items (survives index shifts on trim), the index otherwise.
@visibleForTesting
String webtoonItemKey(List<ReaderItem>? items, int index) {
  final item = (items != null && index >= 0 && index < items.length) ? items[index] : null;
  if (item is ReaderPageItem) return 'p:${item.chapter.id}:${item.chapter.serverId}:${item.pageIndex}';
  if (item is ReaderChapterBoundary) return 'b:${item.previous.id}:${item.previous.serverId}';
  return 'i:$index';
}
