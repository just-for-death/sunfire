// Copyright (c) 2026 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import '../../../../../constants/enum.dart';

/// Index mapping for tablet double-page spread in horizontal paged reader modes.
abstract final class SpreadPageUtils {
  SpreadPageUtils._();

  static bool isHorizontalSinglePage(ReaderMode mode) =>
      mode == ReaderMode.singleHorizontalLTR ||
      mode == ReaderMode.singleHorizontalRTL;

  static bool isRTL(ReaderMode mode) => mode == ReaderMode.singleHorizontalRTL;

  static bool shouldEnable({
    required ReaderDoublePageSpread setting,
    required ReaderMode mode,
    required bool isTablet,
    required bool isLandscape,
  }) {
    if (!isHorizontalSinglePage(mode)) return false;
    return switch (setting) {
      ReaderDoublePageSpread.never => false,
      ReaderDoublePageSpread.always => true,
      ReaderDoublePageSpread.auto => isTablet && isLandscape,
    };
  }

  /// Number of PageView items when spread is active.
  static int spreadCount(int pageCount) {
    if (pageCount <= 0) return 1;
    if (pageCount == 1) return 1;
    return 1 + ((pageCount - 1) / 2).ceil();
  }

  /// Spread index that contains [pageIndex].
  static int spreadIndexForPage(int pageIndex) {
    if (pageIndex <= 0) return 0;
    return 1 + (pageIndex - 1) ~/ 2;
  }

  /// Leading (first-in-reading-order) page index for a spread.
  static int leadingPageForSpread(int spreadIndex) {
    if (spreadIndex <= 0) return 0;
    return spreadIndex * 2 - 1;
  }

  /// Furthest page reached in [spreadIndex] — used for progress and last-page checks.
  static int logicalPageForSpread(int spreadIndex, int pageCount) {
    final pages = pagesInSpread(spreadIndex, pageCount);
    if (pages.isEmpty) return 0;
    return pages.last;
  }

  /// Page indices shown together in [spreadIndex].
  static List<int> pagesInSpread(int spreadIndex, int pageCount) {
    if (pageCount <= 0 || spreadIndex < 0) return const [];
    if (spreadIndex == 0) return const [0];
    final first = spreadIndex * 2 - 1;
    final second = first + 1;
    if (second < pageCount) return [first, second];
    if (first < pageCount) return [first];
    return [pageCount - 1];
  }

  /// Display order within a spread row (RTL manga: higher index on the right).
  static List<int> displayOrder(List<int> pages, {required bool rtl}) =>
      rtl ? pages.reversed.toList() : pages;
}
