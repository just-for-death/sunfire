// Copyright (c) 2026 Contributors to the Catalyst project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import '../../../../utils/extensions/custom_extensions.dart';
import '../../domain/chapter/chapter_model.dart';

/// The chapter to resume at: the earliest unread one in reading order.
///
/// Takes the lowest [ChapterDto.index] rather than the first list element,
/// because the list it is given is sorted for *display* — which defaults to
/// descending, and would otherwise resume at the newest unread chapter and
/// skip everything before it.
ChapterDto? firstUnreadInReadingOrder(List<ChapterDto> chapters) {
  ChapterDto? earliest;
  for (final chapter in chapters) {
    if (chapter.isRead.ifNull(false)) continue;
    if (earliest == null || chapter.index < earliest.index) {
      earliest = chapter;
    }
  }
  return earliest;
}

/// Chapters that come before [chapter] in reading order.
///
/// Position in the list is not usable for this: it reflects the display sort,
/// so with the default descending order the earlier positions are the *newer*
/// chapters.
List<ChapterDto> chaptersBeforeInReadingOrder(
  List<ChapterDto> chapters,
  ChapterDto chapter,
) =>
    [for (final c in chapters) if (c.index < chapter.index) c];

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
