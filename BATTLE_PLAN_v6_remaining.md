# Battle Plan: Complete v6 Remaining Work (R1.8 + I3.* + S6.6)

## SCOPE

**Goal:** Move all chapter/page loading logic out of `reader_screen.dart` into `NavigationController` + `PageLoader`, making `ReaderScreen` a pure UI orchestrator (~300 lines). Replace dual `_recoverImage`/`Image.network` path with single `PageLoader`-owned fetch.

**Done when:**
- `reader_screen.dart` < 500 lines (down from 3082)
- `_loadChapterAndPagesInner` logic fully in `NavigationController`
- `_recoverImage` multi-pass logic fully in `PageLoader._loadImage`
- `PageLoader` handles curl-impersonate (desktop) + 4-pass HTTP fallback
- `ReaderScreen` only does: UI layout, gesture binding, callbacks, settings sheets
- All 1297+ tests pass
- `flutter analyze` clean (0 errors)

**Not doing:**
- S4.1 multi-server production cutover (experimental only)
- T2.5 integration test (depends on cutover)
- S6.1-S6.5/S6.7-S6.8 screen polish (separate phase)

---

## RECON

### Files to Modify

| File | Lines | What Changes |
|------|-------|--------------|
| `lib/src/features/reader/controller/navigation_controller.dart` | ~346 | Add: `_resolveChapterPages` full logic, self-healing, source auto-detect, prefetch, desktop preload, generation guards, progress flush |
| `lib/src/features/reader/controller/page_loader.dart` | ~533 | Add: 4-pass HTTP + curl fallback in `_loadImage`, failed URL tracking, `sourceName` setter, headers builder |
| `lib/src/features/reader/controller/reader_controller.dart` | ~824 | Wire callbacks fully, remove `onRequestChapterLoad` delegate |
| `lib/src/features/reader/reader_screen.dart` | ~3082 | **Delete** ~2500 lines: `_loadChapterAndPages`, `_loadChapterAndPagesInner`, `_recoverImage`, `_prefetchChapter`, `_prefetchUpcomingPages`, `_prefetchUpcomingViaPageLoader`, `_syncPageLoader`, `_warmPagesViaLoader`, `_syncGestureNavChapters`, chapter/sibling state, caches |

### New Files Needed

| File | Purpose |
|------|---------|
| `lib/src/features/reader/controller/reader_page_widget.dart` | Extracted `_buildPageWidget` logic (shared between screen/canvas) |

### Existing Patterns to Follow

- **Generation guards**: `_loadGeneration` pattern in `NavigationController` (already there)
- **Callbacks**: `onChapterLoaded`, `onPageChanged`, `onLoadingChanged` (already wired)
- **Priority queue**: `PageLoader` priority (current > next > prev > prefetch) exists
- **LRU cache**: `_LruCache` in `PageLoader` exists (200 entries)
- **Metrics**: `PageLoaderMetrics` (I3.4) exists
- **Desktop curl**: `runCurlWithSemaphore` from `safe_curl.dart`

### Dependencies/Callers

- `ReaderScreen` → calls `ReaderController.loadChapter()` → delegates to `NavigationController.loadChapterAndPages()`
- `ReaderCanvas` → uses `ReaderController.pageLoader` via `pageBuilder` callback
- `GesturePipeline` → calls `NavigationController.goToNextPage/PrevPage/loadChapterAndPages`
- `PositionManager` → progress persistence (already extracted)

### Tests

- `test/reader_controller_test.dart` - integration tests for controller
- `test/reader_canvas_test.dart` - widget tests
- `test/navigation_controller_test.dart` - unit tests (needs creation)
- `test/page_loader_test.dart` - unit tests (needs creation)

---

## PRE-MORTEM

**If this fails in 2 weeks, it's probably because:**

| # | Risk | Likelihood | Impact | Detection | Mitigation |
|---|------|------------|--------|-----------|------------|
| 1 | **HIGH**: Generation guard race — stale load overwrites newer chapter state | HIGH | Wrong chapter displayed, progress synced to wrong chapter, Isar corruption | User sees wrong pages, progress jumps, "chapter X failed" | Copy exact `_loadGeneration` pattern from `reader_screen`; add integration test for rapid chapter switching |
| 2 | **HIGH**: `PageLoader` 4-pass fallback breaks on desktop (curl missing, headers wrong) | HIGH | All images fail on Linux/Mac/Windows; blank reader | Desktop users report "all images broken" | Test `_loadImage` locally on desktop first; keep `_recoverImage` as fallback behind feature flag until verified |
| 3 | **HIGH**: Self-healing URL scrape writes to wrong chapter (stale `_chapter` ref) | HIGH | Permanent Isar corruption — chapter gets foreign URL, never loads again | Chapter permanently broken, requires re-scrape | Capture `targetChapter` local variable BEFORE awaits (pattern already in `reader_screen`); add test |
| 4 | **HIGH**: Source name auto-detection mismatch → all images 403 | HIGH | Entire chapter renders "Failed to Load" until navigate away/back | User sees all broken images, no obvious error | Guard `_sourceName` write with generation check (pattern in `reader_screen` line 1433); log source resolution |
| 5 | **HIGH**: `PageLoader` cache eviction purges visible pages | MED | Visible page flickers/re-fetches while paging | Visual flicker on fast paging | Eviction skips current page ±2 (pattern in `reader_screen` `_storeRecoveredImage`); add test |
| 6 | **MED**: Prefetch cache key collision across sources | MED | Wrong chapter prefetched, wasted bandwidth | Debug logs show source mismatch | Use composite key `chapterTargetId|mangaId` + source check on read (already in `PageLoader`) |
| 7 | **MED**: `NavigationController` missing callbacks for platform mirrors (widget/Live Activities/Siri) | MED | No "continue reading" widget, no Dynamic Island progress | Missing platform features | Mirror `_mirrorPlatformReadingSession` logic in `NavigationController.loadChapterAndPages` |
| 8 | **MED**: `_buildPageWidget` extraction breaks webtoon height probes | MED | Webtoon scroll position wrong on chapter open | Long webtoons land pages off | Extract widget WITH provider capture logic intact; test `resumeOffsetForPage` |
| 9 | **LOW**: Test breakage from API changes | MED | CI fails | CI red | Update tests alongside implementation; run tests after each step |

---

## ADJUSTED PLAN (Risk-Ordered)

1. **Step 1-2**: PageLoader `_loadImage` with 4-pass + curl (HIGH risk #2) — verify on desktop FIRST
2. **Step 3**: NavigationController `_resolveChapterPages` with self-healing + source detect (HIGH #1,3,4)
3. **Step 4**: NavigationController `loadChapterAndPages` full flow + callbacks (HIGH #1)
4. **Step 5**: ReaderController wire-up — remove `onRequestChapterLoad` delegate (HIGH #1)
5. **Step 6**: Extract `_buildPageWidget` → `reader_page_widget.dart` (MED #8)
6. **Step 7**: ReaderScreen delete ~2500 lines, become thin UI (MED #7)
7. **Step 8**: Run full test suite, fix breakage (LOW #9)

---

## ROLLBACK

```bash
# If broken:
git checkout HEAD -- lib/src/features/reader/
flutter test
flutter analyze
```

---

## ESTIMATE

| Phase | Time |
|-------|------|
| Recon & setup | 15 min |
| PageLoader `_loadImage` (desktop verify) | 45 min |
| NavigationController resolve logic | 60 min |
| NavigationController full load flow | 45 min |
| ReaderController wire-up | 30 min |
| Widget extraction | 30 min |
| ReaderScreen cleanup | 45 min |
| Testing & fixes | 60 min |
| **Total** | **~5.5-6.5 hours** |

**Checkpoint:** After Step 2 (PageLoader works on desktop)

---

## STEPS

### Step 1: [x] PageLoader — Implement 4-pass HTTP + curl fallback in `_loadImage`
**Output:** `PageLoader._loadImage` handles: curl (desktop) → Pass 1 (standard) → Pass 2 (no Referer) → Pass 3 (origin Referer) → Pass 4 (browser UA)
**Confidence:** HIGH (pattern exists in `reader_screen._recoverImage`)
**Depends on:** None

### Step 2: [x] PageLoader — Add `setSourceName`, failed URL tracking, headers builder
**Output:** `sourceName` mutable; `_failedUrls` set; `buildHeaders(url)` method
**Confidence:** HIGH
**Depends on:** Step 1

### Step 3: [x] NavigationController — Move `_resolveChapterPages` full logic
**Output:** `_resolveChapterPages` includes: 3-tier resolver, self-healing URL scrape, source auto-detect, generation guards, `_sourceName` write guard
**Confidence:** MED (complex async flow)
**Depends on:** Step 2

### Step 4: [x] NavigationController — Complete `loadChapterAndPages` flow
**Output:** Full flow: flush progress → clear state → load chapter → platform mirrors → load siblings → resolve pages → update state → callbacks → prefetch next
**Confidence:** MED
**Depends on:** Step 3

### Step 5: [x] NavigationController — Prefetch logic (next chapter + desktop preload)
**Output:** `prefetchNextChapter` uses `PageLoader.prefetchChapter`; desktop preload 5 pages via `PageLoader.loadPage`
**Confidence:** MED
**Depends on:** Step 4

### Step 6: [x] ReaderController — Remove `onRequestChapterLoad` delegate
**Output:** `loadChapter` always calls `_loadChapterAndPagesViaNavigation`; callbacks fully wired
**Confidence:** HIGH
**Depends on:** Step 4

### Step 7: [x] Extract `ReaderPageWidget` — `_buildPageWidget` → new file
**Output:** `lib/src/features/reader/controller/reader_page_widget.dart` with `buildPageWidget(url, index, constraints, isPaged, contentWidth, enablePerPageZoom, recoveredBytes, pageLoader, sourceName, settings, theme, colorFilter, cropBorders, scaleType, cachedHeights, cachedAspects, onHeightCached)`
**Confidence:** MED
**Depends on:** Step 6

### Step 8: [x] ReaderScreen — Delete ~2500 lines, thin UI orchestrator
**Output:** `reader_screen.dart` ~300 lines: only `build()`, gesture binding, callbacks, settings sheets
**Confidence:** HIGH (mechanical deletion)
**Depends on:** Step 7

### Step 9: [x] Tests — Update/fix all tests
**Output:** All 1297+ tests pass; add `navigation_controller_test.dart`, `page_loader_test.dart`
**Confidence:** HIGH
**Depends on:** Step 8

---

## Ready to Execute?

Type `go` to proceed with Step 1, or tell me what to adjust.