# v6 Cutover Status (2026-10-13)

Tracked summary of wired vs remaining work on `v6-reader-rewrite`.
Local task boards `V6_PLAN.md` / `V6_TASKS.md` are gitignored; keep this file in sync when status changes.

## Verification

- `flutter analyze` — clean
- `flutter test --exclude-tags native,network` — **1207 pass / 1 skip**
- Live reader orchestrator: `lib/src/features/reader/reader_screen.dart` (~3082 LOC)

## Done (user-reachable)

| Area | Notes |
|---|---|
| **R1.2 / R1.4 / R1.6 / R1.7** | PositionManager, GesturePipeline, ReaderCanvas (webtoon+paged), ReaderTheme on live path |
| **R1.5 / R1.8 partial** | ReaderController mounted with injected PM/Nav/GP; `loadChapter` facade; UI extracts (HUD, transition, chapter list, settings); shared `reader_chapter_resolve` |
| **I3 partial** | PageLoader warm + `peekCachedBytes` / `cacheBytes`; live pages prefer memory from recover or loader LRU |
| **S1.\*** | Delta sync, conflicts, selective sync, SyncManager progress with titles + current/total |
| **C5.1–C5.6** | Design-system buttons/cards/chips/dialogs/sheets; Android nav via `SunfireBottomNav` / `SunfireNavRail` |
| **L10.\*** / platform | Tags, smart collections, import-export, duplicates; widget / Live Activities / Siri from live reader |

## Next (priority order)

1. **R1.8** — Move `_loadChapterAndPagesInner` (page resolve / recover / platform mirrors) off the screen into NavigationController / ReaderController
2. **I3** — End-to-end PageLoader fetch (drop dual `_recoverImage` / `Image.network` path)
3. **S6.6** — Finish modular reader once load+pages are controller-owned
4. **S6.\*** — Screen polish (Updates, Browse, Detail, Settings, History, Downloads)
5. **S4.1 / T2.5** — Multi-server depth; live-reader progress/offline integration test

## Recent commits (slice trail)

See `git log` on `v6-reader-rewrite` from `4079ec2`…`60f1199` (GesturePipeline → Canvas → load facade → HUD/I3/C5.6/S1.5 → resolve share → sheet extracts → analyze clean).
