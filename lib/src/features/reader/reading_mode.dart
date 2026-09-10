enum ReadingMode { longStrip, longStripGaps, pagedLtr, pagedRtl }

bool isWebtoonReadingMode(ReadingMode mode) =>
    mode == ReadingMode.longStrip || mode == ReadingMode.longStripGaps;

bool isPagedReadingMode(ReadingMode mode) =>
    mode == ReadingMode.pagedLtr || mode == ReadingMode.pagedRtl;

ReadingMode parseReadingMode(String str) {
  switch (str.toLowerCase().trim()) {
    case 'long strip (gaps)':
    case 'long strip gaps':
    case 'continuous vertical':
      return ReadingMode.longStripGaps;
    case 'paged ltr':
    case 'paged left-to-right':
      return ReadingMode.pagedLtr;
    case 'paged rtl':
    case 'paged rtl (manga)':
    case 'paged right-to-left':
      return ReadingMode.pagedRtl;
    case 'long strip':
    case 'webtoon':
    default:
      return ReadingMode.longStrip;
  }
}

ReadingMode cycleReadingMode(ReadingMode current) {
  switch (current) {
    case ReadingMode.longStrip:
      return ReadingMode.longStripGaps;
    case ReadingMode.longStripGaps:
      return ReadingMode.pagedRtl;
    case ReadingMode.pagedRtl:
      return ReadingMode.pagedLtr;
    case ReadingMode.pagedLtr:
      return ReadingMode.longStrip;
  }
}

String readingModeSettingsValue(ReadingMode mode) {
  switch (mode) {
    case ReadingMode.longStrip:
      return 'Long Strip';
    case ReadingMode.longStripGaps:
      return 'Long Strip (Gaps)';
    case ReadingMode.pagedLtr:
      return 'Paged LTR';
    case ReadingMode.pagedRtl:
      return 'Paged RTL (Manga)';
  }
}

String readingModeHudLabel(ReadingMode mode) {
  switch (mode) {
    case ReadingMode.longStrip:
      return 'WEBTOON';
    case ReadingMode.longStripGaps:
      return 'GAPS';
    case ReadingMode.pagedRtl:
      return 'RTL';
    case ReadingMode.pagedLtr:
      return 'LTR';
  }
}

String readingModeSnackLabel(ReadingMode mode) {
  switch (mode) {
    case ReadingMode.longStrip:
      return 'Webtoon (Long Strip)';
    case ReadingMode.longStripGaps:
      return 'Webtoon (Long Strip with Gaps)';
    case ReadingMode.pagedRtl:
      return 'Manga (Right to Left)';
    case ReadingMode.pagedLtr:
      return 'Comic (Left to Right)';
  }
}

/// Extra space between webtoon pages. Long strip (no gaps) is flush.
double webtoonPageGap(ReadingMode mode) => mode == ReadingMode.longStripGaps ? 12.0 : 0.0;

/// 1px overlap hides subpixel hairlines between flush strips.
bool webtoonShouldOverlapPrevious(ReadingMode mode, int index) =>
    mode == ReadingMode.longStrip && index > 0;
