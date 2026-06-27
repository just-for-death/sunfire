// Copyright (c) 2022 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../../constants/enum.dart';
import '../../../../utils/extensions/custom_extensions.dart';
import '../../../../utils/misc/toast/toast.dart';
import '../../../../widgets/custom_circular_progress_indicator.dart';
import '../../../../widgets/emoticons.dart';
import '../../../history/presentation/history_controller.dart';
import '../../../settings/presentation/reader/widgets/reader_ignore_safe_area_tile/reader_ignore_safe_area_tile.dart';
import '../../../settings/presentation/reader/widgets/reader_mode_tile/reader_mode_tile.dart';
import '../../../settings/presentation/reader/widgets/reader_orientation_tile/reader_orientation_tile.dart';
import '../../../tracking/tracker_progress_sync.dart';
import '../../data/local_downloads/local_downloads_service.dart';
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
    if (mangaId <= 0 || chapterId <= 0) {
      return Scaffold(
        body: Emoticons(
          title: context.l10n.invalidChapterLink,
          button: TextButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: Text(context.l10n.close),
          ),
        ),
      );
    }

    final mangaProvider = mangaWithIdProvider(mangaId: mangaId);
    final chapterProviderWithIndex = chapterProvider(chapterId: chapterId);
    final chapterPages = ref.watch(chapterPagesProvider(chapterId: chapterId));
    final manga = ref.watch(mangaProvider);
    final chapter = ref.watch(chapterProviderWithIndex);
    final defaultReaderMode = ref.watch(readerModeKeyProvider);
    final ignoreSafeArea = ref.watch(readerIgnoreSafeAreaProvider).ifNull();
    final orientationLock = ref.watch(readerOrientationLockKeyProvider);

    final debounce = useRef<Timer?>(null);
    final pendingPageIndex = useRef<int?>(null);
    final lastFlushedPage = useRef<int?>(null);
    final resumeHintShown = useRef(false);

    final updateLastRead = useCallback((int currentPage) async {
      final chapterValue = chapter.valueOrNull;
      final chapterPagesValue = chapterPages.valueOrNull;
      if (chapterValue == null || chapterPagesValue == null) return;

      final pageCount = chapterPagesValue.pages.isNotEmpty
          ? chapterPagesValue.pages.length
          : chapterValue.pageCount;
      final isReadingCompleted =
          pageCount > 0 && currentPage >= (pageCount - 1);

      final lastPage = isReadingCompleted ? 0 : currentPage;

      final saveResult = await AsyncValue.guard(
        () => ref.read(mangaBookRepositoryProvider).putChapter(
              chapterId: chapterValue.id,
              patch: ChapterChange(
                lastPageRead: lastPage,
                isRead: isReadingCompleted,
              ),
            ),
      );

      await ref.read(localDownloadsServiceProvider).updateReadingProgress(
            chapterValue.id,
            lastPageRead: lastPage,
            isRead: isReadingCompleted,
          );

      if (saveResult.hasError) return;

      ref.invalidate(chapterProvider(chapterId: chapterValue.id));
      pendingPageIndex.value = null;

      ref.read(historyHiddenChapterIdsProvider.notifier).unhideChapter(
            chapterValue.id,
          );

      unawaited(
        syncTrackerProgressOnChapterComplete(
          ref,
          mangaId: mangaId,
          chapterNumber: chapterValue.chapterNumber,
        ),
      );

      if (isReadingCompleted) {
        final historyEnabled = ref.read(historyEnabledProvider) ?? true;
        if (historyEnabled) {
          ref.invalidate(readingHistoryProvider);
        }
      }
    }, [chapter.valueOrNull, chapterPages.valueOrNull]);

    final updateLastReadRef = useRef<Future<void> Function(int)?>(null);
    updateLastReadRef.value = updateLastRead;

    final flushProgress = useCallback((int index) async {
      if (lastFlushedPage.value == index) return;
      debounce.value?.cancel();
      await updateLastRead(index);
      lastFlushedPage.value = index;
    }, [updateLastRead]);

    useEffect(() {
      WakelockPlusBridge.register(
        enable: WakelockPlus.enable,
        disable: WakelockPlus.disable,
      );
      ReaderSession.enter();
      ReaderSession.onEnterReader(chromeVisible: false);
      return () {
        debounce.value?.cancel();
        final pending = pendingPageIndex.value;
        if (pending != null) {
          unawaited(updateLastReadRef.value?.call(pending) ?? Future.value());
        }
        ReaderSession.leave();
      };
    }, []);

    useEffect(() {
      ReaderSession.applyOrientationLock(orientationLock);
      return null;
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

    final onPageChanged = useCallback<AsyncValueSetter<int>>(
      (int index) async {
        final chapterValue = chapter.valueOrNull;
        final chapterPagesValue = chapterPages.valueOrNull;
        if (chapterValue == null || chapterPagesValue == null) return;

        pendingPageIndex.value = index;
        lastFlushedPage.value = null;

        final activeDebounce = debounce.value;
        if (activeDebounce?.isActive ?? false) {
          activeDebounce!.cancel();
        }

        final pageCount = chapterPagesValue.pages.isNotEmpty
            ? chapterPagesValue.pages.length
            : chapterValue.pageCount;

        if (index >= (pageCount - 1) && pageCount > 0) {
          await updateLastRead(index);
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
      final readerMode =
          mangaData.metaData.readerMode ?? defaultReaderMode ?? ReaderMode.defaultReader;
      return switch (readerMode) {
        ReaderMode.singleVertical => SinglePageReaderMode(
            chapter: chapterData,
            manga: mangaData,
            readerMode: ReaderMode.singleVertical,
            onPageChanged: onPageChanged,
            scrollDirection: Axis.vertical,
            showReaderLayoutAnimation: showReaderLayoutAnimation,
            chapterPages: chapterPagesData,
          ),
        ReaderMode.singleHorizontalRTL => SinglePageReaderMode(
            chapter: chapterData,
            manga: mangaData,
            readerMode: ReaderMode.singleHorizontalRTL,
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
            readerMode: ReaderMode.singleHorizontalLTR,
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
        ReaderMode.defaultReader =>
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
          title: context.l10n.errorSomethingWentWrong,
          button: TextButton(
            onPressed: () => ref.refresh(mangaProvider.future),
            child: Text(context.l10n.refresh),
          ),
        );
      }
      if (chapter.hasError) {
        return Emoticons(
          title: context.l10n.errorSomethingWentWrong,
          button: TextButton(
            onPressed: () => ref.refresh(chapterProviderWithIndex.future),
            child: Text(context.l10n.refresh),
          ),
        );
      }
      if (chapterPages.hasError) {
        return Emoticons(
          title: context.l10n.errorSomethingWentWrong,
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

      if (mangaData == null) {
        return Emoticons(
          title: context.l10n.errorSomethingWentWrong,
          button: TextButton(
            onPressed: () => ref.refresh(mangaProvider.future),
            child: Text(context.l10n.refresh),
          ),
        );
      }
      if (chapterData == null) {
        return Emoticons(
          title: context.l10n.errorSomethingWentWrong,
          button: TextButton(
            onPressed: () => ref.refresh(chapterProviderWithIndex.future),
            child: Text(context.l10n.refresh),
          ),
        );
      }
      if (chapterPagesData == null) {
        return Emoticons(
          title: context.l10n.readerPagesLoadFailed,
          button: TextButton(
            onPressed: () =>
                ref.refresh(chapterPagesProvider(chapterId: chapterId).future),
            child: Text(context.l10n.refresh),
          ),
        );
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
          final pending = pendingPageIndex.value;
          if (pending != null) {
            await flushProgress(pending);
          }
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
        readerMode: ReaderMode.singleHorizontalLTR,
        onPageChanged: onPageChanged,
        chapterPages: chapterPagesData,
      ),
    ReaderMode.singleHorizontalRTL => SinglePageReaderMode(
        chapter: chapterData,
        manga: mangaData,
        readerMode: ReaderMode.singleHorizontalRTL,
        onPageChanged: onPageChanged,
        reverse: true,
        showReaderLayoutAnimation: showReaderLayoutAnimation,
        chapterPages: chapterPagesData,
      ),
    ReaderMode.singleVertical => SinglePageReaderMode(
        chapter: chapterData,
        manga: mangaData,
        readerMode: ReaderMode.singleVertical,
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
