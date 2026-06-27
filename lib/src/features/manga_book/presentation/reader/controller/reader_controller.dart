// Copyright (c) 2022 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/local_downloads/local_downloads_service.dart';
import '../../../data/manga_book/manga_book_repository.dart';
import '../../../domain/chapter/chapter_model.dart';
import '../../../domain/chapter/graphql/__generated__/fragment.graphql.dart';
import '../../../domain/chapter_page/chapter_page_model.dart';
import '../../../domain/chapter_page/graphql/__generated__/fragment.graphql.dart';

part 'reader_controller.g.dart';

/// Suwayomi stores `lastPageRead: 0` when a chapter is completed. Map that to
/// the last page index so `isRead` and progress stay consistent in the UI.
int _lastPageReadWhenCompleted({
  required int pageCount,
  int serverLastPageRead = 0,
  int manifestLastPageRead = 0,
}) {
  if (pageCount <= 0) return 0;
  final lastIndex = pageCount - 1;
  return [
    serverLastPageRead,
    manifestLastPageRead,
    lastIndex,
  ].reduce((a, b) => a > b ? a : b);
}

ChapterDto _mergeChapterWithOfflineProgress(
  ChapterDto server,
  OfflineChapterManifest manifest,
) {
  final localAhead = (manifest.isRead && !server.isRead) ||
      manifest.lastPageRead > server.lastPageRead;
  if (!localAhead) return server;
  final isRead = manifest.isRead || server.isRead;
  final pageCount = server.pageCount > 0 ? server.pageCount : manifest.pageCount;
  final lastPageRead = isRead
      ? _lastPageReadWhenCompleted(
          pageCount: pageCount,
          serverLastPageRead: server.lastPageRead,
          manifestLastPageRead: manifest.lastPageRead,
        )
      : manifest.lastPageRead;
  return server.copyWith(
    lastPageRead: lastPageRead,
    isRead: isRead,
  );
}

ChapterDto _chapterFromOfflineManifest(OfflineChapterManifest manifest) {
  final lastPageRead = manifest.isRead
      ? _lastPageReadWhenCompleted(
          pageCount: manifest.pageCount,
          manifestLastPageRead: manifest.lastPageRead,
        )
      : manifest.lastPageRead;
  return Fragment$ChapterDto(
    chapterNumber: manifest.chapterNumber,
    fetchedAt: '0',
    id: manifest.chapterId,
    isBookmarked: false,
    isDownloaded: true,
    isRead: manifest.isRead,
    lastPageRead: lastPageRead,
    lastReadAt: '0',
    mangaId: manifest.mangaId,
    name: manifest.chapterName.isNotEmpty
        ? manifest.chapterName
        : 'Chapter ${manifest.chapterId}',
    pageCount: manifest.pageCount,
    sourceOrder: 0,
    uploadDate: '0',
    url: '',
    meta: const [],
  );
}

Future<ChapterPagesDto?> _chapterPagesWithLocalFallback(
  Ref ref, {
  required int chapterId,
}) async {
  final service = ref.read(localDownloadsServiceProvider);
  final localPages = await service.getLocalPages(chapterId);
  final offlineManifest = await service.getOfflineManifest(chapterId);

  ChapterPagesDto? remote;
  try {
    remote = await ref
        .read(mangaBookRepositoryProvider)
        .getChapterPages(chapterId: chapterId);
  } catch (_) {
    remote = null;
  }

  if (remote != null) {
    if (localPages == null || localPages.isEmpty) return remote;
    if (localPages.length >= remote.pages.length) {
      return remote.copyWith(
        pages: localPages,
        chapter: remote.chapter.copyWith(pageCount: localPages.length),
      );
    }
    final mergedPages = <String>[];
    for (var i = 0; i < remote.pages.length; i++) {
      mergedPages.add(
        i < localPages.length ? localPages[i] : remote.pages[i],
      );
    }
    return remote.copyWith(
      pages: mergedPages,
      chapter: remote.chapter.copyWith(pageCount: mergedPages.length),
    );
  }

  if (localPages == null || localPages.isEmpty) return null;

  if (offlineManifest != null) {
    return ChapterPagesDto(
      chapter: Fragment$ChapterPagesDto$chapter(
        id: offlineManifest.chapterId,
        pageCount: localPages.length,
      ),
      pages: localPages,
    );
  }

  ChapterDto? chapter;
  try {
    chapter = await ref
        .read(mangaBookRepositoryProvider)
        .getChapter(chapterId: chapterId);
  } catch (_) {
    chapter = null;
  }

  return ChapterPagesDto(
    chapter: Fragment$ChapterPagesDto$chapter(
      id: chapter?.id ?? chapterId,
      pageCount: localPages.length,
    ),
    pages: localPages,
  );
}

Future<ChapterDto?> _chapterWithOfflineFallback(
  Ref ref, {
  required int chapterId,
}) async {
  final manifest =
      await ref.read(localDownloadsServiceProvider).getOfflineManifest(chapterId);

  try {
    final chapter = await ref
        .read(mangaBookRepositoryProvider)
        .getChapter(chapterId: chapterId);
    if (chapter != null) {
      if (manifest != null) {
        return _mergeChapterWithOfflineProgress(chapter, manifest);
      }
      return chapter;
    }
  } catch (_) {}

  if (manifest == null) return null;
  return _chapterFromOfflineManifest(manifest);
}

@riverpod
FutureOr<ChapterDto?> chapter(
  Ref ref, {
  required int chapterId,
}) =>
    _chapterWithOfflineFallback(ref, chapterId: chapterId);

@riverpod
Future<ChapterPagesDto?> chapterPages(Ref ref, {required int chapterId}) =>
    _chapterPagesWithLocalFallback(ref, chapterId: chapterId);
