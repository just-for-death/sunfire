// Copyright (c) 2026 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import '../../domain/chapter/chapter_model.dart';

/// Neighbor toward the end of the story (next chapter to read).
ChapterDto? chapterForwardInReadingOrder(
  List<ChapterDto> sortedList,
  int currentIndex, {
  required bool listAscending,
}) {
  final nextIndex = listAscending ? currentIndex + 1 : currentIndex - 1;
  if (nextIndex < 0 || nextIndex >= sortedList.length) return null;
  return sortedList[nextIndex];
}

/// Neighbor toward the start of the story (previous chapter to read).
ChapterDto? chapterBackwardInReadingOrder(
  List<ChapterDto> sortedList,
  int currentIndex, {
  required bool listAscending,
}) {
  final prevIndex = listAscending ? currentIndex - 1 : currentIndex + 1;
  if (prevIndex < 0 || prevIndex >= sortedList.length) return null;
  return sortedList[prevIndex];
}

/// Like [chapterForwardInReadingOrder] but skips chapters that fail [passesFilter].
ChapterDto? chapterForwardInReadingOrderFiltered(
  List<ChapterDto> sortedList,
  int currentIndex, {
  required bool listAscending,
  required bool Function(ChapterDto chapter) passesFilter,
}) {
  final step = listAscending ? 1 : -1;
  var i = currentIndex + step;
  while (i >= 0 && i < sortedList.length) {
    if (passesFilter(sortedList[i])) return sortedList[i];
    i += step;
  }
  return null;
}

/// Like [chapterBackwardInReadingOrder] but skips chapters that fail [passesFilter].
ChapterDto? chapterBackwardInReadingOrderFiltered(
  List<ChapterDto> sortedList,
  int currentIndex, {
  required bool listAscending,
  required bool Function(ChapterDto chapter) passesFilter,
}) {
  final step = listAscending ? -1 : 1;
  var i = currentIndex + step;
  while (i >= 0 && i < sortedList.length) {
    if (passesFilter(sortedList[i])) return sortedList[i];
    i += step;
  }
  return null;
}
