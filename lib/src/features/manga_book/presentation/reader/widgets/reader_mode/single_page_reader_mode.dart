// Copyright (c) 2022 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../../constants/app_constants.dart';
import '../../../../../../constants/enum.dart';
import '../../../../../../utils/extensions/cache_manager_extensions.dart';
import '../../../../../../utils/extensions/custom_extensions.dart';
import '../../../../../../utils/misc/app_utils.dart';
import '../../../../../../widgets/custom_circular_progress_indicator.dart';
import '../../../../../../widgets/server_image.dart';
import '../../../../../settings/presentation/reader/widgets/reader_double_page_spread_tile/reader_double_page_spread_tile.dart';
import '../../../../../settings/presentation/reader/widgets/reader_scroll_animation_tile/reader_scroll_animation_tile.dart';
import '../../../../domain/chapter/chapter_model.dart';
import '../../../../domain/chapter_page/chapter_page_model.dart';
import '../../../../domain/manga/manga_model.dart';
import '../../utils/spread_page_utils.dart';
import '../reader_wrapper.dart';

class SinglePageReaderMode extends HookConsumerWidget {
  const SinglePageReaderMode({
    super.key,
    required this.manga,
    required this.chapter,
    required this.chapterPages,
    required this.readerMode,
    this.onPageChanged,
    this.reverse = false,
    this.scrollDirection = Axis.horizontal,
    this.showReaderLayoutAnimation = false,
  });

  final MangaDto manga;
  final ChapterDto chapter;
  final ValueSetter<int>? onPageChanged;
  final bool reverse;
  final Axis scrollDirection;
  final bool showReaderLayoutAnimation;
  final ChapterPagesDto chapterPages;
  final ReaderMode readerMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cacheManager = useMemoized(() => DefaultCacheManager());
    final spreadSetting = ref.watch(readerDoublePageSpreadKeyProvider) ??
        ReaderDoublePageSpread.auto;
    final spreadEnabled = SpreadPageUtils.shouldEnable(
      setting: spreadSetting,
      mode: readerMode,
      isTablet: context.isTablet,
      isLandscape: context.isLandscape,
    );
    final rtl = SpreadPageUtils.isRTL(readerMode);

    final pageCount = chapterPages.pages.isNotEmpty
        ? chapterPages.pages.length
        : chapterPages.chapter.pageCount;
    final initialPage = _clampPageIndex(
      chapter.isRead.ifNull()
          ? 0
          : chapter.lastPageRead.getValueOnNullOrNegative(),
      pageCount,
    );
    final initialSpread = spreadEnabled
        ? SpreadPageUtils.spreadIndexForPage(initialPage)
        : initialPage;

    final scrollController = usePageController(initialPage: initialSpread);
    final currentIndex = useState(initialPage);

    useEffect(() {
      if (onPageChanged != null) onPageChanged!(currentIndex.value);
      if (chapterPages.pages.isEmpty) return null;

      final spreadsToPrefetch = spreadEnabled
          ? {
              SpreadPageUtils.spreadIndexForPage(currentIndex.value) - 1,
              SpreadPageUtils.spreadIndexForPage(currentIndex.value),
              SpreadPageUtils.spreadIndexForPage(currentIndex.value) + 1,
            }
          : {
              currentIndex.value - 1,
              currentIndex.value,
              currentIndex.value + 1,
              currentIndex.value + 2,
            };

      for (final spread in spreadsToPrefetch) {
        final indices = spreadEnabled
            ? SpreadPageUtils.pagesInSpread(spread, chapterPages.pages.length)
            : (spread >= 0 && spread < chapterPages.pages.length ? [spread] : []);
        for (final page in indices) {
          cacheManager.getServerFile(ref, chapterPages.pages[page]);
        }
      }
      return null;
    }, [currentIndex.value, chapterPages.pages.length, spreadEnabled]);

    useEffect(() {
      listener() {
        final currentPage = scrollController.page;
        if (currentPage == null) return;
        final viewportIndex = currentPage.round();
        final settled = (currentPage - viewportIndex).abs() < 0.01;
        currentIndex.value = spreadEnabled
            ? (settled
                ? SpreadPageUtils.logicalPageForSpread(
                    viewportIndex,
                    chapterPages.pages.length,
                  )
                : SpreadPageUtils.leadingPageForSpread(viewportIndex))
            : viewportIndex.clamp(0, pageCount > 0 ? pageCount - 1 : 0);
      }

      scrollController.addListener(listener);
      return () => scrollController.removeListener(listener);
    }, [scrollController, spreadEnabled, pageCount]);

    useEffect(() {
      final target = spreadEnabled
          ? SpreadPageUtils.spreadIndexForPage(currentIndex.value)
          : currentIndex.value;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!scrollController.hasClients) return;
        final clamped = target.clamp(
          0,
          (spreadEnabled
                  ? SpreadPageUtils.spreadCount(
                      chapterPages.pages.isEmpty ? 1 : chapterPages.pages.length,
                    )
                  : pageCount) -
              1,
        );
        if (scrollController.page?.round() != clamped) {
          scrollController.jumpToPage(clamped);
        }
      });
      return null;
    }, [spreadEnabled, chapterPages.pages.length]);

    final isAnimationEnabled =
        ref.read(readerScrollAnimationProvider).ifNull(true);

    void jumpToLogicalPage(int pageIndex) {
      final target = spreadEnabled
          ? SpreadPageUtils.spreadIndexForPage(pageIndex)
          : pageIndex;
      scrollController.jumpToPage(target);
      currentIndex.value = pageIndex;
    }

    return ReaderWrapper(
      scrollDirection: scrollDirection,
      chapter: chapter,
      manga: manga,
      chapterPages: chapterPages,
      currentIndex: currentIndex.value,
      livePageIndex: currentIndex,
      onChanged: jumpToLogicalPage,
      showReaderLayoutAnimation: showReaderLayoutAnimation,
      onPrevious: () => scrollController.previousPage(
        duration: isAnimationEnabled ? kDuration : kInstantDuration,
        curve: kCurve,
      ),
      onNext: () => scrollController.nextPage(
        duration: isAnimationEnabled ? kDuration : kInstantDuration,
        curve: kCurve,
      ),
      pageController: scrollController,
      child: PageView.builder(
        scrollDirection: scrollDirection,
        reverse: reverse,
        controller: scrollController,
        allowImplicitScrolling: true,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        itemBuilder: (BuildContext context, int index) {
          if (chapterPages.pages.isEmpty) {
            return const Center(child: CenterCatalystShimmerIndicator());
          }

          if (!spreadEnabled) {
            if (index >= chapterPages.pages.length) {
              return const Center(child: CenterCatalystShimmerIndicator());
            }
            return _buildPageImage(context, ref, chapterPages.pages[index]);
          }

          final pages = SpreadPageUtils.displayOrder(
            SpreadPageUtils.pagesInSpread(index, chapterPages.pages.length),
            rtl: rtl,
          );

          if (pages.length == 1) {
            return Center(
              child: _buildPageImage(context, ref, chapterPages.pages[pages[0]]),
            );
          }

          return Row(
            children: pages
                .map(
                  (pageIndex) => Expanded(
                    child: _buildPageImage(
                      context,
                      ref,
                      chapterPages.pages[pageIndex],
                    ),
                  ),
                )
                .toList(),
          );
        },
        itemCount: chapterPages.pages.isEmpty
            ? 1
            : spreadEnabled
                ? SpreadPageUtils.spreadCount(chapterPages.pages.length)
                : chapterPages.pages.length,
      ),
    );
  }

  Widget _buildPageImage(BuildContext context, WidgetRef ref, String pageUrl) {
    final image = ServerImage(
      showReloadButton: true,
      fit: BoxFit.contain,
      size: Size.fromHeight(context.height),
      appendApiToUrl: false,
      imageUrl: pageUrl,
      progressIndicatorBuilder: (context, url, downloadProgress) =>
          CenterCatalystShimmerIndicator(
        value: downloadProgress.progress,
      ),
    );
    return AppUtils.wrapOn(
      !kIsWeb && (Platform.isAndroid || Platform.isIOS)
          ? (child) => InteractiveViewer(maxScale: 5, child: child)
          : null,
      image,
    );
  }

  static int _clampPageIndex(int index, int pageCount) {
    if (pageCount <= 0) return 0;
    return index.clamp(0, pageCount - 1);
  }
}
