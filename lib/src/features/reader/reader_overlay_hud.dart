// R1.8: overlay chrome extracted from reader_screen so the screen stays orchestrator-only.
import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/db/models/chapter.dart';
import '../../ui/design_system/tokens/sunfire_colors.dart';
import '../../ui/design_system/tokens/sunfire_spacing.dart';
import 'controller/reader_theme.dart';
import 'reading_mode.dart';

/// Top app bar, bottom scrubber, webtoon page capsule, and auto-scroll floating HUD.
class ReaderOverlayHud extends StatelessWidget {
  const ReaderOverlayHud({
    super.key,
    required this.showControls,
    required this.primaryColor,
    required this.chapter,
    required this.readingMode,
    required this.readerTheme,
    required this.incognitoMode,
    required this.prevChapter,
    required this.nextChapter,
    required this.pageUrlsLength,
    required this.pageIndicator,
    required this.scrollIndicatorVisible,
    required this.isDraggingSlider,
    required this.sliderDragValue,
    required this.isAutoScrolling,
    required this.isUserTouching,
    required this.autoScrollSpeed,
    required this.isAutoScrollHudCollapsed,
    required this.autoScrollShowFloatingHud,
    required this.onExit,
    required this.onToggleBookmark,
    required this.onToggleIncognito,
    required this.onShowChapters,
    required this.onShowListen,
    required this.onShowSettings,
    required this.onLoadPrevChapter,
    required this.onLoadNextChapter,
    required this.onCycleReadingMode,
    required this.onToggleAutoScroll,
    required this.onShowAutoScrollSpeed,
    required this.onSliderChangeStart,
    required this.onSliderChanged,
    required this.onSliderChangeEnd,
    required this.onAutoScrollSpeedDelta,
    required this.onAutoScrollSpeedCycle,
    required this.onCollapseAutoScrollHud,
    required this.onExpandAutoScrollHud,
  });

  final bool showControls;
  final Color primaryColor;
  final Chapter? chapter;
  final ReadingMode readingMode;
  final ReaderThemeMode readerTheme;
  final bool incognitoMode;
  final Chapter? prevChapter;
  final Chapter? nextChapter;
  final int pageUrlsLength;
  final ValueNotifier<int> pageIndicator;
  final ValueNotifier<bool> scrollIndicatorVisible;
  final bool isDraggingSlider;
  final double? sliderDragValue;
  final bool isAutoScrolling;
  final bool isUserTouching;
  final double autoScrollSpeed;
  final bool isAutoScrollHudCollapsed;
  final bool autoScrollShowFloatingHud;

  final VoidCallback onExit;
  final VoidCallback onToggleBookmark;
  final VoidCallback onToggleIncognito;
  final VoidCallback onShowChapters;
  final VoidCallback onShowListen;
  final VoidCallback onShowSettings;
  final VoidCallback? onLoadPrevChapter;
  final VoidCallback? onLoadNextChapter;
  final VoidCallback onCycleReadingMode;
  final VoidCallback onToggleAutoScroll;
  final VoidCallback onShowAutoScrollSpeed;
  final VoidCallback onSliderChangeStart;
  final ValueChanged<double> onSliderChanged;
  final ValueChanged<double> onSliderChangeEnd;
  final void Function(double delta) onAutoScrollSpeedDelta;
  final VoidCallback onAutoScrollSpeedCycle;
  final VoidCallback onCollapseAutoScrollHud;
  final VoidCallback onExpandAutoScrollHud;

  bool get _isWebtoon =>
      readingMode == ReadingMode.longStrip ||
      readingMode == ReadingMode.longStripGaps;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _TopBar(
          showControls: showControls,
          primaryColor: primaryColor,
          chapter: chapter,
          readingMode: readingMode,
          readerTheme: readerTheme,
          incognitoMode: incognitoMode,
          onExit: onExit,
          onToggleBookmark: onToggleBookmark,
          onToggleIncognito: onToggleIncognito,
          onShowChapters: onShowChapters,
          onShowListen: onShowListen,
          onShowSettings: onShowSettings,
        ),
        _BottomBar(
          showControls: showControls,
          primaryColor: primaryColor,
          readingMode: readingMode,
          prevChapter: prevChapter,
          nextChapter: nextChapter,
          pageUrlsLength: pageUrlsLength,
          pageIndicator: pageIndicator,
          isDraggingSlider: isDraggingSlider,
          sliderDragValue: sliderDragValue,
          isAutoScrolling: isAutoScrolling,
          onLoadPrevChapter: onLoadPrevChapter,
          onLoadNextChapter: onLoadNextChapter,
          onCycleReadingMode: onCycleReadingMode,
          onToggleAutoScroll: onToggleAutoScroll,
          onShowAutoScrollSpeed: onShowAutoScrollSpeed,
          onSliderChangeStart: onSliderChangeStart,
          onSliderChanged: onSliderChanged,
          onSliderChangeEnd: onSliderChangeEnd,
        ),
        if (_isWebtoon)
          _PageCapsule(
            showControls: showControls,
            pageUrlsLength: pageUrlsLength,
            pageIndicator: pageIndicator,
            scrollIndicatorVisible: scrollIndicatorVisible,
          ),
        if (_isWebtoon &&
            isAutoScrolling &&
            !showControls &&
            autoScrollShowFloatingHud)
          _AutoScrollCapsule(
            primaryColor: primaryColor,
            isUserTouching: isUserTouching,
            autoScrollSpeed: autoScrollSpeed,
            isCollapsed: isAutoScrollHudCollapsed,
            onToggleAutoScroll: onToggleAutoScroll,
            onShowAutoScrollSpeed: onShowAutoScrollSpeed,
            onAutoScrollSpeedDelta: onAutoScrollSpeedDelta,
            onAutoScrollSpeedCycle: onAutoScrollSpeedCycle,
            onCollapse: onCollapseAutoScrollHud,
            onExpand: onExpandAutoScrollHud,
          ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.showControls,
    required this.primaryColor,
    required this.chapter,
    required this.readingMode,
    required this.readerTheme,
    required this.incognitoMode,
    required this.onExit,
    required this.onToggleBookmark,
    required this.onToggleIncognito,
    required this.onShowChapters,
    required this.onShowListen,
    required this.onShowSettings,
  });

  final bool showControls;
  final Color primaryColor;
  final Chapter? chapter;
  final ReadingMode readingMode;
  final ReaderThemeMode readerTheme;
  final bool incognitoMode;
  final VoidCallback onExit;
  final VoidCallback onToggleBookmark;
  final VoidCallback onToggleIncognito;
  final VoidCallback onShowChapters;
  final VoidCallback onShowListen;
  final VoidCallback onShowSettings;

  @override
  Widget build(BuildContext context) {
    final bookmarked = chapter?.isBookmarked == true;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedSlide(
        offset: showControls ? Offset.zero : const Offset(0, -1),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: AnimatedOpacity(
          opacity: showControls ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: IgnorePointer(
            ignoring: !showControls,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                right: 16,
                bottom: 12,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [SunfireColors.overlayScrim, SunfireColors.transparent],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: SunfireColors.contentPrimary),
                    onPressed: onExit,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chapter?.name ?? 'Reader',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: SunfireColors.contentPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${readingModeHudLabel(readingMode)} • ${readerTheme.name.toUpperCase()}',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      bookmarked
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: bookmarked ? SunfireColors.overlayHighlight : SunfireColors.contentSecondary,
                    ),
                    tooltip: bookmarked ? 'Remove Bookmark' : 'Bookmark Chapter',
                    onPressed: onToggleBookmark,
                  ),
                  IconButton(
                    icon: Icon(
                      incognitoMode
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_outlined,
                      color: incognitoMode ? SunfireColors.overlayHighlight : SunfireColors.contentSecondary,
                    ),
                    tooltip: incognitoMode
                        ? 'Incognito Mode: ON'
                        : 'Incognito Mode: OFF',
                    onPressed: onToggleIncognito,
                  ),
                  IconButton(
                    icon: const Icon(Icons.format_list_bulleted_rounded,
                        color: SunfireColors.contentPrimary),
                    tooltip: 'Chapters',
                    onPressed: onShowChapters,
                  ),
                  IconButton(
                    icon: const Icon(Icons.headset_rounded, color: SunfireColors.contentPrimary),
                    tooltip: 'Listen (OCR + TTS)',
                    onPressed: onShowListen,
                  ),
                  IconButton(
                    icon: const Icon(Icons.tune_rounded, color: SunfireColors.contentPrimary),
                    tooltip: 'Settings',
                    onPressed: onShowSettings,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.showControls,
    required this.primaryColor,
    required this.readingMode,
    required this.prevChapter,
    required this.nextChapter,
    required this.pageUrlsLength,
    required this.pageIndicator,
    required this.isDraggingSlider,
    required this.sliderDragValue,
    required this.isAutoScrolling,
    required this.onLoadPrevChapter,
    required this.onLoadNextChapter,
    required this.onCycleReadingMode,
    required this.onToggleAutoScroll,
    required this.onShowAutoScrollSpeed,
    required this.onSliderChangeStart,
    required this.onSliderChanged,
    required this.onSliderChangeEnd,
  });

  final bool showControls;
  final Color primaryColor;
  final ReadingMode readingMode;
  final Chapter? prevChapter;
  final Chapter? nextChapter;
  final int pageUrlsLength;
  final ValueNotifier<int> pageIndicator;
  final bool isDraggingSlider;
  final double? sliderDragValue;
  final bool isAutoScrolling;
  final VoidCallback? onLoadPrevChapter;
  final VoidCallback? onLoadNextChapter;
  final VoidCallback onCycleReadingMode;
  final VoidCallback onToggleAutoScroll;
  final VoidCallback onShowAutoScrollSpeed;
  final VoidCallback onSliderChangeStart;
  final ValueChanged<double> onSliderChanged;
  final ValueChanged<double> onSliderChangeEnd;

  bool get _isWebtoon =>
      readingMode == ReadingMode.longStrip ||
      readingMode == ReadingMode.longStripGaps;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 16 + MediaQuery.of(context).padding.bottom,
      left: 16,
      right: 16,
      child: AnimatedSlide(
        offset: showControls ? Offset.zero : const Offset(0, 1),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: AnimatedOpacity(
          opacity: showControls ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: IgnorePointer(
            ignoring: !showControls,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(SunfireRadius.pill),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: SunfireColors.overlaySurface,
                      borderRadius: BorderRadius.circular(SunfireRadius.pill),
                      border: Border.all(
                          color: SunfireColors.borderStrong, width: 0.8),
                      boxShadow: const [
                        BoxShadow(
                          color: SunfireColors.shadowDefault,
                          blurRadius: 16,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 4,
                          runSpacing: 4,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.skip_previous_rounded,
                                  color: SunfireColors.contentPrimary),
                              tooltip: 'Previous Chapter',
                              onPressed: onLoadPrevChapter,
                            ),
                            ValueListenableBuilder<int>(
                              valueListenable: pageIndicator,
                              builder: (_, activePage, __) => Text(
                                'Page $activePage / $pageUrlsLength',
                                style: const TextStyle(
                                  color: SunfireColors.contentPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: onCycleReadingMode,
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: primaryColor.withValues(alpha: 0.5),
                                    width: 0.8,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _isWebtoon
                                          ? Icons.swap_vert_rounded
                                          : readingMode == ReadingMode.pagedVertical
                                              ? Icons.arrow_downward_rounded
                                              : (readingMode == ReadingMode.pagedRtl
                                                  ? Icons.arrow_back_rounded
                                                  : Icons.arrow_forward_rounded),
                                      size: 13,
                                      color: primaryColor,
                                    ),
                                    const SizedBox(width: SunfireSpacing.xs),
                                    Text(
                                      readingModeHudLabel(readingMode),
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
                            if (_isWebtoon)
                              Semantics(
                                label: isAutoScrolling ? 'Pause auto-scroll' : 'Start auto-scroll',
                                button: true,
                                child: GestureDetector(
                                onTap: onToggleAutoScroll,
                                onLongPress: onShowAutoScrollSpeed,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isAutoScrolling
                                        ? primaryColor.withValues(alpha: 0.3)
                                        : SunfireColors.borderStrong,
                                    borderRadius: BorderRadius.circular(SunfireRadius.md),
                                    border: Border.all(
                                      color: isAutoScrolling
                                          ? primaryColor
                                          : SunfireColors.borderDefault,
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isAutoScrolling
                                            ? Icons.pause_rounded
                                            : Icons.play_arrow_rounded,
                                        size: 13,
                                        color: isAutoScrolling
                                            ? primaryColor
                                            : SunfireColors.contentPrimary,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        'AUTO',
                                        style: TextStyle(
                                          color: isAutoScrolling
                                              ? primaryColor
                                              : SunfireColors.contentPrimary,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              ),
                            IconButton(
                              icon: const Icon(Icons.skip_next_rounded,
                                  color: SunfireColors.contentPrimary),
                              tooltip: 'Next Chapter',
                              onPressed: onLoadNextChapter,
                            ),
                          ],
                        ),
                        if (pageUrlsLength > 1)
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: (MediaQuery.of(context).size.width - 64)
                                  .clamp(180.0, 320.0),
                            ),
                            child: SizedBox(
                              height: 28,
                              child: SliderTheme(
                                data: SliderThemeData(
                                  activeTrackColor: primaryColor,
                                  inactiveTrackColor: SunfireColors.overlayTrack,
                                  thumbColor: primaryColor,
                                  trackHeight: 3,
                                  thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 6),
                                ),
                                child: ValueListenableBuilder<int>(
                                  valueListenable: pageIndicator,
                                  builder: (_, activePage, __) => Semantics(
                                    label: 'Page navigation slider',
                                    child: Slider(
                                    value: (isDraggingSlider
                                            ? (sliderDragValue ??
                                                activePage.toDouble())
                                            : activePage.toDouble())
                                        .clamp(1.0, pageUrlsLength.toDouble()),
                                    min: 1.0,
                                    max: pageUrlsLength.toDouble(),
                                    divisions: pageUrlsLength > 1
                                        ? pageUrlsLength - 1
                                        : 1,
                                    onChangeStart: (_) => onSliderChangeStart(),
                                    onChanged: onSliderChanged,
                                    onChangeEnd: onSliderChangeEnd,
                                  ),
                                    ),
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
    );
  }
}

class _PageCapsule extends StatelessWidget {
  const _PageCapsule({
    required this.showControls,
    required this.pageUrlsLength,
    required this.pageIndicator,
    required this.scrollIndicatorVisible,
  });

  final bool showControls;
  final int pageUrlsLength;
  final ValueNotifier<int> pageIndicator;
  final ValueNotifier<bool> scrollIndicatorVisible;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24 + MediaQuery.of(context).padding.bottom,
      right: 20,
      child: ValueListenableBuilder<bool>(
        valueListenable: scrollIndicatorVisible,
        builder: (context, showIndicator, _) {
          return AnimatedOpacity(
            opacity: (!showControls && showIndicator && pageUrlsLength > 0)
                ? 1.0
                : 0.0,
            duration: const Duration(milliseconds: 250),
            child: IgnorePointer(
              ignoring: !showIndicator || showControls,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: SunfireColors.overlaySurface,
                  borderRadius: BorderRadius.circular(SunfireRadius.lg),
                  border:
                      Border.all(color: SunfireColors.borderStrong, width: 0.8),
                  boxShadow: const [
                    BoxShadow(
                      color: SunfireColors.shadowDefault,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ValueListenableBuilder<int>(
                  valueListenable: pageIndicator,
                  builder: (context, page, _) => Text(
                    '$page / $pageUrlsLength',
                    style: const TextStyle(
                      color: SunfireColors.contentPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AutoScrollCapsule extends StatelessWidget {
  const _AutoScrollCapsule({
    required this.primaryColor,
    required this.isUserTouching,
    required this.autoScrollSpeed,
    required this.isCollapsed,
    required this.onToggleAutoScroll,
    required this.onShowAutoScrollSpeed,
    required this.onAutoScrollSpeedDelta,
    required this.onAutoScrollSpeedCycle,
    required this.onCollapse,
    required this.onExpand,
  });

  final Color primaryColor;
  final bool isUserTouching;
  final double autoScrollSpeed;
  final bool isCollapsed;
  final VoidCallback onToggleAutoScroll;
  final VoidCallback onShowAutoScrollSpeed;
  final void Function(double delta) onAutoScrollSpeedDelta;
  final VoidCallback onAutoScrollSpeedCycle;
  final VoidCallback onCollapse;
  final VoidCallback onExpand;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24 + MediaQuery.of(context).padding.bottom,
      left: 20,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(SunfireRadius.pill),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: SunfireColors.overlaySurface,
              borderRadius: BorderRadius.circular(SunfireRadius.pill),
              border: Border.all(
                color: isUserTouching
                    ? SunfireColors.overlayHighlight.withValues(alpha: 0.8)
                    : primaryColor.withValues(alpha: 0.6),
                width: 1.0,
              ),
              boxShadow: const [
                BoxShadow(
                  color: SunfireColors.shadowDefault,
                  blurRadius: 12,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: isCollapsed
                ? Semantics(
                    label: 'Expand auto-scroll controls',
                    button: true,
                    child: GestureDetector(
                    onTap: () {
                      unawaited(HapticFeedback.lightImpact());
                      onExpand();
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isUserTouching
                              ? Icons.touch_app_rounded
                              : Icons.speed_rounded,
                          size: 15,
                          color: isUserTouching
                              ? SunfireColors.overlayHighlight
                              : primaryColor,
                        ),
                        const SizedBox(width: SunfireSpacing.xs),
                        Text(
                          '${autoScrollSpeed.round()}',
                          style: TextStyle(
                            color: isUserTouching
                                ? SunfireColors.overlayHighlight
                                : SunfireColors.contentPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(Icons.chevron_right_rounded,
                            size: 14, color: SunfireColors.contentDisabled),
                      ],
                    ),
                  ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          unawaited(HapticFeedback.selectionClick());
                          onToggleAutoScroll();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isUserTouching
                                ? Icons.touch_app_rounded
                                : Icons.pause_rounded,
                            size: 15,
                            color: isUserTouching
                                ? SunfireColors.overlayHighlight
                                : primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {
                          unawaited(HapticFeedback.lightImpact());
                          onShowAutoScrollSpeed();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: SunfireColors.overlayButton,
                            borderRadius: BorderRadius.circular(SunfireRadius.sm),
                            border:
                                Border.all(color: SunfireColors.borderSubtle, width: 0.6),
                          ),
                          child: Text(
                            isUserTouching
                                ? 'PAUSED'
                                : '${autoScrollSpeed.round()} px/s',
                            style: TextStyle(
                              color: isUserTouching
                                  ? SunfireColors.overlayHighlight
                                  : SunfireColors.contentPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: SunfireSpacing.xs),
                      GestureDetector(
                        onTap: () {
                          unawaited(HapticFeedback.selectionClick());
                          final step = autoScrollSpeed >= 300
                              ? 50.0
                              : (autoScrollSpeed >= 100 ? 25.0 : 10.0);
                          onAutoScrollSpeedDelta(-step);
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(Icons.remove_rounded,
                              size: 15, color: SunfireColors.contentSecondary),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          unawaited(HapticFeedback.selectionClick());
                          final step = autoScrollSpeed >= 300
                              ? 50.0
                              : (autoScrollSpeed >= 100 ? 25.0 : 10.0);
                          onAutoScrollSpeedDelta(step);
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(Icons.add_rounded,
                              size: 15, color: SunfireColors.contentSecondary),
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {
                          unawaited(HapticFeedback.selectionClick());
                          onAutoScrollSpeedCycle();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: autoScrollSpeed >= 180.0
                                ? primaryColor.withValues(alpha: 0.35)
                                : SunfireColors.overlayButton,
                            borderRadius: BorderRadius.circular(SunfireRadius.sm),
                            border: Border.all(
                              color: autoScrollSpeed >= 180.0
                                  ? primaryColor
                                  : SunfireColors.borderDefault,
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.bolt_rounded,
                                size: 13,
                                color: autoScrollSpeed >= 180.0
                                    ? primaryColor
                                    : SunfireColors.overlayHighlight,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                autoScrollSpeed >= 450.0
                                    ? 'TURBO'
                                    : (autoScrollSpeed >= 180.0
                                        ? 'FAST'
                                        : 'NORM'),
                                style: TextStyle(
                                  color: autoScrollSpeed >= 180.0
                                      ? primaryColor
                                      : SunfireColors.contentPrimary,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: SunfireSpacing.xs),
                      Semantics(
                        label: 'Collapse auto-scroll controls',
                        button: true,
                        child: GestureDetector(
                        onTap: () {
                          unawaited(HapticFeedback.lightImpact());
                          onCollapse();
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2),
                          child: Icon(Icons.chevron_left_rounded,
                              size: 16, color: SunfireColors.contentDisabled),
                        ),
                      ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
