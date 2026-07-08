import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../routes/router_config.dart';
import '../../../domain/chapter/chapter_model.dart';
import '../controller/reader_controller.dart';
import 'reader_session.dart';

/// Warms Riverpod caches so the next chapter opens without a full-screen loader.
void prefetchReaderChapter(WidgetRef ref, int chapterId) {
  if (chapterId <= 0) return;
  unawaited(ref.read(chapterProvider(chapterId: chapterId).future));
  unawaited(ref.read(chapterPagesProvider(chapterId: chapterId).future));
}

void prefetchAdjacentReaderChapters(
  WidgetRef ref, {
  ChapterDto? next,
  ChapterDto? previous,
}) {
  if (next != null) prefetchReaderChapter(ref, next.id);
  if (previous != null) prefetchReaderChapter(ref, previous.id);
}

/// Replaces the current reader route with another chapter of the same manga.
void navigateToReaderChapter(
  BuildContext context,
  WidgetRef ref, {
  required int mangaId,
  required int chapterId,
  required bool transVertical,
  required bool toPrev,
}) {
  if (!context.mounted || chapterId <= 0) return;
  prefetchReaderChapter(ref, chapterId);
  // Prevent wakelock / system-UI flicker while pushReplacement disposes the old screen.
  ReaderSession.enter();
  ReaderRoute(
    mangaId: mangaId,
    chapterId: chapterId,
    transVertical: transVertical,
    toPrev: toPrev,
  ).pushReplacement(context);
}
