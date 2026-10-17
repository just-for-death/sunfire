// lib/src/features/reader/controller/reader_page_widget.dart
//
// Extracted page widget builder for the reader.
// Shared between ReaderScreen and ReaderCanvas.
// Designed to be independent of UI state — all dependencies passed as parameters.

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../core/engine/javascript/m_client.dart';
import '../../../core/engine/quickjs_service.dart';
import '../../../core/services/settings_service.dart';
import '../../../ui/design_system/tokens/sunfire_colors.dart';
import '../../../ui/design_system/tokens/sunfire_spacing.dart';
import '../double_page_layout.dart' show isWidePage;
import '../reader_scroll_utils.dart' show estimateWebtoonPlaceholderHeight;
import '../reading_mode.dart';
import 'page_loader.dart';
import 'reader_decode_size.dart';
import 'reader_theme.dart';

/// Configuration for building a reader page widget.
class ReaderPageWidgetConfig {
  const ReaderPageWidgetConfig({
    required this.url,
    required this.index,
    required this.constraints,
    required this.isPaged,
    required this.contentWidth,
    this.devicePixelRatio,
    required this.enablePerPageZoom,
    required this.readingMode,
    required this.colorFilter,
    required this.cropBorders,
    required this.scaleType,
    required this.readerTheme,
    required this.pageLoader,
    required this.sourceName,
    required this.settings,
    required this.cachedPageHeights,
    required this.cachedPageAspects,
    required this.recoveringUrls,
    required this.failedImageUrls,
    required this.canvasBackgroundColor,
    required this.colorScheme,
    required this.onRecoverImage,
    required this.onScheduleHeightCache,
    required this.onDoubleTapDown,
    required this.onDoubleTapZoom,
    required this.onPruneZoomState,
    required this.webtoonZoomControllerFor,
    required this.transformationController,
    required this.minZoomScale,
    required this.maxZoomScale,
    required this.isZoomed,
    required this.onInteractionUpdate,
    required this.onInteractionEnd,
  });

  final String url;
  final int index;
  final BoxConstraints? constraints;
  final bool isPaged;
  final double? contentWidth;

  /// Screen pixel ratio for decode sizing (IMP-009); falls back to the first view.
  final double? devicePixelRatio;
  final bool enablePerPageZoom;
  final ReadingMode readingMode;
  final ReaderColorFilter colorFilter;
  final bool cropBorders;
  final ImageScaleType scaleType;
  final ReaderThemeMode readerTheme;
  final PageLoader? pageLoader;
  final String sourceName;
  final SettingsService settings;
  final Map<String, double> cachedPageHeights;
  final Map<String, double> cachedPageAspects;
  final Set<String> recoveringUrls;
  final Set<String> failedImageUrls;
  final Color canvasBackgroundColor;
  final ColorScheme colorScheme;
  final Future<void> Function(String url, int index, {bool manual}) onRecoverImage;
  final void Function(String url, double width, ImageProvider provider) onScheduleHeightCache;
  final void Function(TapDownDetails details) onDoubleTapDown;
  final void Function({TransformationController? controllerOverride, int? pageIndex}) onDoubleTapZoom;
  final void Function(int index) onPruneZoomState;
  final TransformationController Function(int) webtoonZoomControllerFor;
  final TransformationController? transformationController;
  final double minZoomScale;
  final double maxZoomScale;
  final bool isZoomed;
  final void Function(ScaleUpdateDetails) onInteractionUpdate;
  final void Function(ScaleEndDetails) onInteractionEnd;
}

/// ISS-124: the same "Failed to Load / Tap to Retry" tile the failed-URL path
/// uses, so every error state offers a Retry (spinner while recovering).
Widget _retryTile(ReaderPageWidgetConfig config, {required double height, double? width, required VoidCallback onRetry}) {
  return Container(
    height: height,
    width: width ?? double.infinity,
    color: config.canvasBackgroundColor,
    child: Center(
      child: config.recoveringUrls.contains(config.url)
          ? CircularProgressIndicator(color: config.colorScheme.primary, strokeWidth: 2)
          : InkWell(
              onTap: onRetry,
              borderRadius: BorderRadius.circular(SunfireRadius.md),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.refresh_rounded, size: 28, color: SunfireColors.contentTertiary),
                    const SizedBox(height: 6),
                    Text('Page ${config.index + 1} Failed to Load', style: const TextStyle(color: SunfireColors.contentPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: SunfireSpacing.xs),
                    Text('Tap to Retry', style: TextStyle(color: config.colorScheme.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
    ),
  );
}

/// Drops undecodable cached bytes (if any) then runs the normal manual retry.
void _retryUndecodable(ReaderPageWidgetConfig config) {
  final loader = config.pageLoader;
  if (loader != null && !config.url.startsWith('/')) {
    unawaited(loader.retryUndecodablePage(config.url, config.index));
  } else {
    unawaited(config.onRecoverImage(config.url, config.index, manual: true));
  }
}

/// Builds a page widget for the reader.
///
/// This is the shared implementation used by both [ReaderScreen] and [ReaderCanvas].
Widget buildReaderPageWidget(ReaderPageWidgetConfig config) {
  final isWebtoon = config.readingMode == ReadingMode.longStrip || config.readingMode == ReadingMode.longStripGaps;
  final boxFit = isWebtoon ? BoxFit.fitWidth : _imageBoxFit(config.scaleType);
  final imageAlignment = isWebtoon ? Alignment.topCenter : Alignment.center;
  final resolvedWidth = config.contentWidth ?? config.constraints?.maxWidth ?? 800.0;
  final imageWidth = isWebtoon ? resolvedWidth : null;
  final dpr = config.devicePixelRatio ??
      WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
  final decodeWidth = readerDecodeCacheWidth(
    decodeLogicalWidth(
      imageWidth: imageWidth,
      maxWidth: config.constraints?.maxWidth,
      maxHeight: config.constraints?.maxHeight,
      mayRotate: !isWebtoon && config.settings.rotateWidePages,
    ),
    dpr,
  );
  final placeholderHeight = isWebtoon
      ? estimateWebtoonPlaceholderHeight(resolvedWidth, cachedHeight: config.cachedPageHeights[config.url])
      : 400.0;

  final isDesktop = !kIsWeb && (Platform.isLinux || Platform.isMacOS || Platform.isWindows);

  // I3: prefer screen recover map, then PageLoader LRU (warm/prefetch).
  final memoryBytes = config.pageLoader?.peekCachedBytes(config.url);

  Widget image;
  if (memoryBytes != null) {
    image = Image.memory(
      memoryBytes,
      width: imageWidth,
      cacheWidth: decodeWidth,
      fit: boxFit,
      alignment: imageAlignment,
      gaplessPlayback: true,
      isAntiAlias: !isWebtoon,
      filterQuality: isWebtoon ? FilterQuality.low : FilterQuality.medium,
      errorBuilder: (_, __, ___) => _retryTile(
        config,
        height: isWebtoon ? placeholderHeight : 300.0,
        width: imageWidth,
        onRetry: () => _retryUndecodable(config),
      ),
    );
  } else if (config.url.startsWith('/')) {
    image = Image.file(
      File(config.url),
      width: imageWidth,
      cacheWidth: decodeWidth,
      fit: boxFit,
      alignment: imageAlignment,
      gaplessPlayback: true,
      isAntiAlias: !isWebtoon,
      filterQuality: isWebtoon ? FilterQuality.low : FilterQuality.medium,
      errorBuilder: (_, __, ___) => _retryTile(
        config,
        height: isWebtoon ? placeholderHeight : 300.0,
        width: imageWidth,
        onRetry: () => _retryUndecodable(config),
      ),
    );
  } else if (isDesktop) {
    // Desktop renders remote pages from curl-fetched bytes. The fetch is
    // started by the owner on load / page change / scroll (ISS-128: build
    // has no side effects); this shows its progress or a Retry.
    image = Container(
      height: placeholderHeight,
      width: imageWidth ?? double.infinity,
      color: config.canvasBackgroundColor,
      child: Center(
        child: config.recoveringUrls.contains(config.url)
            ? CircularProgressIndicator(color: config.colorScheme.primary, strokeWidth: 2)
            : IconButton(
                icon: const Icon(Icons.refresh_rounded, color: SunfireColors.contentTertiary),
                tooltip: 'Retry Page ${config.index + 1}',
                onPressed: () => config.onRecoverImage(config.url, config.index, manual: true),
              ),
      ),
    );
  } else {
    // Gate on the known-failed set FIRST so a failed URL renders the static
    // retry affordance instead of re-issuing an Image.network fetch on every
    // webtoon item rebuild. onRecoverImage(manual:) clears the flag to retry.
    if (config.failedImageUrls.contains(config.url)) {
      image = _retryTile(
        config,
        height: isWebtoon ? placeholderHeight : 300.0,
        width: imageWidth,
        onRetry: () => config.onRecoverImage(config.url, config.index, manual: true),
      );
    } else {
      final baseHeaders = QuickJsService.getImageHeaders(config.sourceName, config.url);
      final cookieHeaders = MClient.getCookiesPref(config.url);
      final headers = {...baseHeaders, ...cookieHeaders, 'User-Agent': MClient.userAgent};

      image = Image.network(
        config.url,
        headers: headers,
        width: imageWidth,
        cacheWidth: decodeWidth,
        fit: boxFit,
        alignment: imageAlignment,
        gaplessPlayback: true,
        isAntiAlias: !isWebtoon,
        filterQuality: isWebtoon ? FilterQuality.low : FilterQuality.medium,
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return Container(
            height: placeholderHeight,
            width: imageWidth ?? double.infinity,
            color: config.canvasBackgroundColor,
            child: Center(child: CircularProgressIndicator(color: config.colorScheme.primary, strokeWidth: 2)),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          // Never fetch during build: schedule the recovery after the frame.
          SchedulerBinding.instance.addPostFrameCallback((_) {
            unawaited(config.onRecoverImage(config.url, config.index));
          });
          return _retryTile(
            config,
            height: isWebtoon ? placeholderHeight : 300.0,
            width: imageWidth,
            onRetry: () => config.onRecoverImage(config.url, config.index, manual: true),
          );
        },
      );
    }
  }

  // Capture the provider BEFORE any wrapping.
  //
  // The height probe used to be handed the widget *after* the colour filter
  // and crop were applied, and it does `if (imageWidget is! Image) return;`.
  // With invert/grayscale/night-amber/sepia on, or crop-borders on, `image` is
  // a ColorFiltered/ClipRect and never an Image — so `_cachedPageHeights`
  // stayed permanently empty and every consumer fell back to the crude
  // `contentWidth * 1.5` estimate. That broke two things: `resumeOffsetForPage`
  // summed 1.5x width for every page, so `_jumpToWebtoonPage` (the only path
  // used on chapter open, since the page-key shortcut misses on first load)
  // landed a long webtoon dozens of pages off; and the per-page placeholder
  // height was wrong, so the strip visibly reflowed as images streamed in.
  final webtoonImageProvider = isWebtoon && image is Image ? image.image : null;

  if (shouldRotateWidePage(
    enabled: config.settings.rotateWidePages,
    isPaged: config.isPaged,
    aspectRatio: config.cachedPageAspects[config.url],
  )) {
    image = RotatedBox(quarterTurns: 1, child: image);
  }

  if (config.colorFilter != ReaderColorFilter.none) {
    image = ColorFiltered(colorFilter: _activeColorFilter(config.colorFilter)!, child: image);
  }

  if (config.cropBorders) {
    image = ClipRect(child: image);
  }

  if (webtoonImageProvider != null) {
    config.onScheduleHeightCache(config.url, resolvedWidth, webtoonImageProvider);
  }

  final useZoom = config.isPaged || config.enablePerPageZoom;
  if (useZoom) {
    if (config.enablePerPageZoom) config.onPruneZoomState(config.index);
    final transform = config.enablePerPageZoom ? config.webtoonZoomControllerFor(config.index) : config.transformationController!;
    return GestureDetector(
      onDoubleTapDown: config.onDoubleTapDown,
      onDoubleTap: () {
        config.onDoubleTapZoom(
          controllerOverride: config.enablePerPageZoom ? transform : null,
          pageIndex: config.index,
        );
      },
      child: InteractiveViewer(
        transformationController: transform,
        minScale: config.minZoomScale,
        maxScale: config.maxZoomScale,
        panEnabled: config.enablePerPageZoom ? (transform.value.getMaxScaleOnAxis() > 1.05) : config.isZoomed,
        onInteractionUpdate: config.onInteractionUpdate,
        onInteractionEnd: config.onInteractionEnd,
        child: image,
      ),
    );
  }

  return image;
}

/// IMP-015: a wide page (width/height >= 1) is turned a quarter turn when the
/// setting is on and the reader is paged. Webtoon strips never rotate, and a
/// page with no measured aspect yet stays upright.
bool shouldRotateWidePage({required bool enabled, required bool isPaged, required double? aspectRatio}) =>
    enabled && isPaged && isWidePage(aspectRatio);

BoxFit _imageBoxFit(ImageScaleType scaleType) {
  switch (scaleType) {
    case ImageScaleType.fitWidth:
      return BoxFit.fitWidth;
    case ImageScaleType.fitHeight:
      return BoxFit.fitHeight;
    case ImageScaleType.fitScreen:
      return BoxFit.contain;
    case ImageScaleType.original:
      return BoxFit.cover;
  }
}

ColorFilter? _activeColorFilter(ReaderColorFilter filter) {
  switch (filter) {
    case ReaderColorFilter.none:
      return null;
    case ReaderColorFilter.invert:
      return const ColorFilter.matrix(<double>[
        -1, 0, 0, 0, 255,
        0, -1, 0, 0, 255,
        0, 0, -1, 0, 255,
        0, 0, 0, 1, 0,
      ]);
    case ReaderColorFilter.grayscale:
      return const ColorFilter.matrix(<double>[
        0.2126, 0.7152, 0.0722, 0, 0,
        0.2126, 0.7152, 0.0722, 0, 0,
        0.2126, 0.7152, 0.0722, 0, 0,
        0, 0, 0, 1, 0,
      ]);
    case ReaderColorFilter.sepia:
      return const ColorFilter.matrix(<double>[
        0.393, 0.769, 0.189, 0, 0,
        0.349, 0.686, 0.168, 0, 0,
        0.272, 0.534, 0.131, 0, 0,
        0, 0, 0, 1, 0,
      ]);
    case ReaderColorFilter.nightAmber:
      return const ColorFilter.matrix(<double>[
        1, 0, 0, 0, 0,
        0, 0.8, 0, 0, 0,
        0, 0, 0.3, 0, 0,
        0, 0, 0, 1, 0,
      ]);
  }
}

/// Logical width to decode a page at (ISS-136). A rotated wide page shows its
/// source width along the screen's height, so when rotation may apply we size
/// for the longer side. The aspect ratio isn't known before decode.
@visibleForTesting
double? decodeLogicalWidth({
  required double? imageWidth,
  required double? maxWidth,
  required double? maxHeight,
  required bool mayRotate,
}) {
  final base = imageWidth ?? maxWidth;
  if (!mayRotate || maxHeight == null || !maxHeight.isFinite) return base;
  if (base == null) return maxHeight;
  return maxHeight > base ? maxHeight : base;
}
