// Copyright (c) 2022 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../constants/enum.dart';
import '../../../../utils/extensions/custom_extensions.dart';
import '../../../../utils/misc/toast/toast.dart';
import '../../../../widgets/custom_circular_progress_indicator.dart';
import '../../../../widgets/emoticons.dart';
import '../../../history/presentation/history_controller.dart';
import '../../../settings/presentation/reader/widgets/reader_ignore_safe_area_tile/reader_ignore_safe_area_tile.dart';
import '../../../settings/presentation/reader/widgets/reader_orientation_tile/reader_orientation_tile.dart';
import '../../data/manga_book/manga_book_repository.dart';
import '../../domain/chapter/chapter_model.dart';
import '../../domain/chapter_batch/chapter_batch_model.dart';
import '../../domain/chapter_page/chapter_page_model.dart';
import '../../domain/manga/manga_model.dart';
import '../manga_details/controller/manga_details_controller.dart';
import 'controller/reader_controller.dart';
import 'utils/reader_session.dart';
import 'widgets/reader_mode/continuous_reader_mode.dart';
import 'widgets/reader_mode/single_page_reader_mode.dart';

/// Reader chrome (app bar, slider, drawer, gestures) lives in [ReaderWrapper] only.
/// This screen loads chapter data, tracks reading progress, and picks the reader mode.
class ReaderScreen extends HookConsumerWidget {
  const ReaderScreen({
    super.key,
    required this.mangaId,
    required this.chapterId,
    this.showReaderLayoutAnimation = false,
  });
  final int mangaId;
  final int chapterId;
  final bool showReaderLayoutAnimation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mangaProvider = mangaWithIdProvider(mangaId: mangaId);
    final chapterProviderWithIndex = chapterProvider(chapterId: chapterId);
    final chapterPages = ref.watch(chapterPagesProvider(chapterId: chapterId));
    final manga = ref.watch(mangaProvider);
    final chapter = ref.watch(chapterProviderWithIndex);
    final defaultReaderMode = ref.watch(readerModeKeyProvider);
    final ignoreSafeArea = ref.watch(readerIgnoreSafeAreaProvider).ifNull();
    final orientationLock = ref.watch(readerOrientationLockKeyProvider);

    final debounce = useRef<Timer?>(null);
    final resumeHintShown = useRef(false);

    useEffect(() {
      ReaderSession.enter();
      final lock = orientationLock ?? ReaderOrientationLock.auto;
      final orientations = switch (lock) {
        ReaderOrientationLock.portrait => [
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ],
        ReaderOrientationLock.landscape => [
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ],
        ReaderOrientationLock.auto => DeviceOrientation.values,
      };
      SystemChrome.setPreferredOrientations(orientations);
      return () {
        debounce.value?.cancel();
        SystemChrome.setPreferredOrientations(DeviceOrientation.values);
        ReaderSession.leave();
      };
    }, [orientationLock]);

    useEffect(() {
      final chapterData = chapter.valueOrNull;
      final chapterPagesData = chapterPages.valueOrNull;
      if (resumeHintShown.value ||
          chapterData == null ||
          chapterPagesData == null ||
          chapterData.isRead.ifNull() ||
          chapterData.lastPageRead <= 0) {
        return null;
      }
      resumeHintShown.value = true;
      final total = chapterPagesData.pages.isNotEmpty
          ? chapterPagesData.pages.length
          : chapterData.pageCount;
      final page = (chapterData.lastPageRead + 1).clamp(1, total);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        ref.read(toastProvider)?.show(
              context.l10n.readerResumedPage(page, total),
            );
      });
      return null;
    }, [chapter.valueOrNull?.id, chapterPages.valueOrNull?.pages.length]);

    final updateLastRead = useCallback((int currentPage) async {
      final chapterValue = chapter.valueOrNull;
      final chapterPagesValue = chapterPages.valueOrNull;
      if (chapterValue == null || chapterPagesValue == null) return;

      final actualPageCount = chapterPagesValue.pages.length;
      final isReadingCompleted =
          (currentPage >= (actualPageCount - 1)) && actualPageCount > 0;

      await AsyncValue.guard(
        () => ref.read(mangaBookRepositoryProvider).putChapter(
              chapterId: chapterValue.id,
              patch: ChapterChange(
                lastPageRead: isReadingCompleted ? 0 : currentPage,
                isRead: isReadingCompleted,
              ),
            ),
      );

      ref.invalidate(readingHistoryProvider);
    }, [chapter.valueOrNull, chapterPages.valueOrNull]);

    final onPageChanged = useCallback<AsyncValueSetter<int>>(
      (int index) async {
        final chapterValue = chapter.valueOrNull;
        final chapterPagesValue = chapterPages.valueOrNull;
        if (chapterValue == null || chapterPagesValue == null) return;

        if ((chapterValue.isRead).ifNull()) {
          return;
        }

        final activeDebounce = debounce.value;
        if (activeDebounce?.isActive ?? false) {
          activeDebounce!.cancel();
        }

        final actualPageCount = chapterPagesValue.pages.length;

        if (index >= (actualPageCount - 1) && actualPageCount > 0) {
          updateLastRead(index);
        } else {
          debounce.value = Timer(
            const Duration(seconds: 2),
            () => updateLastRead(index),
          );
        }
      },
      [chapter, chapterPages],
    );

    Widget buildReader({
      required MangaDto mangaData,
      required ChapterDto chapterData,
      required ChapterPagesDto chapterPagesData,
    }) {
      final readerMode = mangaData.metaData.readerMode ?? defaultReaderMode;
      return switch (readerMode) {
        ReaderMode.singleVertical => SinglePageReaderMode(
            chapter: chapterData,
            manga: mangaData,
            onPageChanged: onPageChanged,
            scrollDirection: Axis.vertical,
            showReaderLayoutAnimation: showReaderLayoutAnimation,
            chapterPages: chapterPagesData,
          ),
        ReaderMode.singleHorizontalRTL => SinglePageReaderMode(
            chapter: chapterData,
            manga: mangaData,
            onPageChanged: onPageChanged,
            reverse: true,
            showReaderLayoutAnimation: showReaderLayoutAnimation,
            chapterPages: chapterPagesData,
          ),
        ReaderMode.continuousHorizontalLTR => ContinuousReaderMode(
            chapter: chapterData,
            manga: mangaData,
            onPageChanged: onPageChanged,
            scrollDirection: Axis.horizontal,
            showReaderLayoutAnimation: showReaderLayoutAnimation,
            chapterPages: chapterPagesData,
          ),
        ReaderMode.continuousHorizontalRTL => ContinuousReaderMode(
            chapter: chapterData,
            manga: mangaData,
            onPageChanged: onPageChanged,
            scrollDirection: Axis.horizontal,
            reverse: true,
            showReaderLayoutAnimation: showReaderLayoutAnimation,
            chapterPages: chapterPagesData,
          ),
        ReaderMode.singleHorizontalLTR => SinglePageReaderMode(
            chapter: chapterData,
            manga: mangaData,
            onPageChanged: onPageChanged,
            chapterPages: chapterPagesData,
          ),
        ReaderMode.continuousVertical => ContinuousReaderMode(
            chapter: chapterData,
            manga: mangaData,
            onPageChanged: onPageChanged,
            showSeparator: true,
            showReaderLayoutAnimation: showReaderLayoutAnimation,
            chapterPages: chapterPagesData,
          ),
        ReaderMode.webtoon => ContinuousReaderMode(
            chapter: chapterData,
            manga: mangaData,
            onPageChanged: onPageChanged,
            showReaderLayoutAnimation: showReaderLayoutAnimation,
            chapterPages: chapterPagesData,
          ),
        ReaderMode.defaultReader || null =>
          _buildDefaultReaderMode(
            defaultReaderMode: defaultReaderMode,
            chapterData: chapterData,
            mangaData: mangaData,
            chapterPagesData: chapterPagesData,
            onPageChanged: onPageChanged,
            showReaderLayoutAnimation: showReaderLayoutAnimation,
          ),
      };
    }

    Widget buildBody() {
      final isInitialLoading = (manga.isLoading && !manga.hasValue) ||
          (chapter.isLoading && !chapter.hasValue) ||
          (chapterPages.isLoading && !chapterPages.hasValue);

      if (isInitialLoading) {
        return const Center(child: CenterCatalystShimmerIndicator());
      }

      if (manga.hasError) {
        return Emoticons(
          title: manga.error.toString(),
          button: TextButton(
            onPressed: () => ref.refresh(mangaProvider.future),
            child: Text(context.l10n.refresh),
          ),
        );
      }
      if (chapter.hasError) {
        return Emoticons(
          title: chapter.error.toString(),
          button: TextButton(
            onPressed: () => ref.refresh(chapterProviderWithIndex.future),
            child: Text(context.l10n.refresh),
          ),
        );
      }
      if (chapterPages.hasError) {
        return Emoticons(
          title: chapterPages.error.toString(),
          button: TextButton(
            onPressed: () =>
                ref.refresh(chapterPagesProvider(chapterId: chapterId).future),
            child: Text(context.l10n.refresh),
          ),
        );
      }

      final mangaData = manga.valueOrNull;
      final chapterData = chapter.valueOrNull;
      final chapterPagesData = chapterPages.valueOrNull;
      if (mangaData == null || chapterData == null || chapterPagesData == null) {
        return const SizedBox.shrink();
      }

      return buildReader(
        mangaData: mangaData,
        chapterData: chapterData,
        chapterPagesData: chapterPagesData,
      );
    }

    return PopScope(
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) {
          ref.invalidate(chapterProviderWithIndex);
          ref.invalidate(mangaChapterListProvider(mangaId: mangaId));
        }
      },
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: SafeArea(
          top: !ignoreSafeArea,
          bottom: !ignoreSafeArea,
          left: !ignoreSafeArea,
          right: !ignoreSafeArea,
          child: buildBody(),
        ),
      ),
    );
  }
}

Widget _buildDefaultReaderMode({
  required ReaderMode? defaultReaderMode,
  required ChapterDto chapterData,
  required MangaDto mangaData,
  required ChapterPagesDto chapterPagesData,
  required AsyncValueSetter<int> onPageChanged,
  required bool showReaderLayoutAnimation,
}) {
  return switch (defaultReaderMode ?? ReaderMode.webtoon) {
    ReaderMode.singleHorizontalLTR => SinglePageReaderMode(
        chapter: chapterData,
        manga: mangaData,
        onPageChanged: onPageChanged,
        chapterPages: chapterPagesData,
      ),
    ReaderMode.singleHorizontalRTL => SinglePageReaderMode(
        chapter: chapterData,
        manga: mangaData,
        onPageChanged: onPageChanged,
        reverse: true,
        showReaderLayoutAnimation: showReaderLayoutAnimation,
        chapterPages: chapterPagesData,
      ),
    ReaderMode.singleVertical => SinglePageReaderMode(
        chapter: chapterData,
        manga: mangaData,
        onPageChanged: onPageChanged,
        scrollDirection: Axis.vertical,
        showReaderLayoutAnimation: showReaderLayoutAnimation,
        chapterPages: chapterPagesData,
      ),
    ReaderMode.continuousHorizontalLTR => ContinuousReaderMode(
        chapter: chapterData,
        manga: mangaData,
        onPageChanged: onPageChanged,
        scrollDirection: Axis.horizontal,
        showReaderLayoutAnimation: showReaderLayoutAnimation,
        chapterPages: chapterPagesData,
      ),
    ReaderMode.continuousHorizontalRTL => ContinuousReaderMode(
        chapter: chapterData,
        manga: mangaData,
        onPageChanged: onPageChanged,
        scrollDirection: Axis.horizontal,
        reverse: true,
        showReaderLayoutAnimation: showReaderLayoutAnimation,
        chapterPages: chapterPagesData,
      ),
    ReaderMode.continuousVertical => ContinuousReaderMode(
        chapter: chapterData,
        manga: mangaData,
        onPageChanged: onPageChanged,
        showSeparator: true,
        showReaderLayoutAnimation: showReaderLayoutAnimation,
        chapterPages: chapterPagesData,
      ),
    ReaderMode.webtoon || _ => ContinuousReaderMode(
        chapter: chapterData,
        manga: mangaData,
        onPageChanged: onPageChanged,
        showReaderLayoutAnimation: showReaderLayoutAnimation,
        chapterPages: chapterPagesData,
      ),
  };
}
