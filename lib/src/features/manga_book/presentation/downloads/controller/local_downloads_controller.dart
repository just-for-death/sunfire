// Copyright (c) 2026 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/local_downloads/local_downloads_service.dart';
import '../../manga_details/controller/manga_details_controller.dart';
import '../../reader/controller/reader_controller.dart';

part 'local_downloads_controller.g.dart';

enum LocalDownloadState { idle, downloading, finished, error }

/// Tracks per-page progress for a single chapter's offline download.
///
/// Holds (current, total) — e.g. (3, 12) means page 3 of 12 saved.
/// Old-style StateProvider.family — no build_runner needed.
final localDownloadProgressProvider =
    StateProvider.family<({int current, int total}), int>(
  (ref, chapterId) => (current: 0, total: 0),
);

@riverpod
class LocalChapterDownload extends _$LocalChapterDownload {
  bool _cancelRequested = false;
  int _downloadGeneration = 0;

  @override
  LocalDownloadState build({required int chapterId}) {
    return LocalDownloadState.idle;
  }

  bool _isStaleDownload(int generation) => generation != _downloadGeneration;

  Future<bool> isDownloaded() async {
    final service = ref.read(localDownloadsServiceProvider);
    return service.isChapterDownloaded(chapterId);
  }

  Future<List<String>?> getLocalPages() async {
    final service = ref.read(localDownloadsServiceProvider);
    return service.getLocalPages(chapterId);
  }

  Future<void> cancel() async {
    if (state != LocalDownloadState.downloading) return;
    _cancelRequested = true;
    state = LocalDownloadState.idle;
    ref.read(localDownloadProgressProvider(chapterId).notifier).state =
        (current: 0, total: 0);
  }

  Future<void> download() async {
    if (kIsWeb) return; // no local filesystem on web
    // Allow on Android, iOS, and desktop (Linux/macOS/Windows).

    final generation = ++_downloadGeneration;
    _cancelRequested = false;
    state = LocalDownloadState.downloading;

    // Reset progress counter before starting.
    ref.read(localDownloadProgressProvider(chapterId).notifier).state =
        (current: 0, total: 0);

    try {
      final service = ref.read(localDownloadsServiceProvider);
      await service.downloadChapter(
        ref: ref,
        chapterId: chapterId,
        onProgress: (current, total) {
          if (_isStaleDownload(generation)) return;
          try {
            ref.read(localDownloadProgressProvider(chapterId).notifier).state =
                (current: current, total: total);
          } catch (_) {}
        },
        isCancelled: () =>
            _cancelRequested || _isStaleDownload(generation),
      );
      if (_isStaleDownload(generation)) return;
      state = LocalDownloadState.finished;
      ref.invalidate(chapterPagesProvider(chapterId: chapterId));
      ref.invalidate(localDownloadedChapterIdsProvider);
      ref.invalidate(offlineStorageSizeProvider);
      state = LocalDownloadState.idle;
    } on DownloadCancelledException {
      if (_isStaleDownload(generation)) return;
      state = LocalDownloadState.idle;
      ref.read(localDownloadProgressProvider(chapterId).notifier).state =
          (current: 0, total: 0);
    } catch (_) {
      if (_isStaleDownload(generation)) return;
      if (_cancelRequested) {
        state = LocalDownloadState.idle;
        ref.read(localDownloadProgressProvider(chapterId).notifier).state =
            (current: 0, total: 0);
      } else {
        state = LocalDownloadState.error;
      }
    }
  }

  Future<void> delete() async {
    if (kIsWeb) return;
    state = LocalDownloadState.downloading;
    try {
      final service = ref.read(localDownloadsServiceProvider);
      final manifest = await service.getOfflineManifest(chapterId);
      await service.deleteChapter(chapterId);
      state = LocalDownloadState.idle;
      ref.invalidate(chapterPagesProvider(chapterId: chapterId));
      ref.invalidate(localDownloadedChapterIdsProvider);
      ref.invalidate(offlineStorageSizeProvider);
      final mangaId = manifest?.mangaId;
      if (mangaId != null && mangaId > 0) {
        ref.invalidate(mangaWithIdProvider(mangaId: mangaId));
        ref.invalidate(mangaChapterListProvider(mangaId: mangaId));
      }
    } catch (_) {
      state = LocalDownloadState.error;
    }
  }
}
