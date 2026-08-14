# Catalyst — AI Handoff Document

> **Purpose:** Resume this conversation’s work without re-deriving context.  
> **Last updated:** 2026-08-14  
> **Branch:** `main` (tracks `origin/main`)  
> **Verify before continuing:** `flutter analyze` → No issues; `flutter test` → **102** tests passing.

---

## 1. What this project is

- **Catalyst** — Flutter manga client for **Suwayomi** (GraphQL backend).
- Cross-platform: Android, iOS, Linux desktop (user develops on CachyOS / Niri Wayland).
- Stack: Flutter + Riverpod (`hooks_riverpod`, codegen) + go_router + GraphQL codegen + Freezed.
- Flutter SDK: official install at `~/flutter` (not AUR/`fvm` system Dart — those conflicted).
- Repo: `/home/zoro/Documents/Projects/catalyst`

**Related product the user researched:** [UsagiApp/Usagi](https://github.com/UsagiApp/Usagi) — Kotlin/local-first Tachiyomi-style app. User wanted Usagi-like UI and dual online/offline modes. Full dual-mode architecture was planned then **paused**; UI polish + bugfix + offline downloads visibility took priority.

---

## 2. Where we left off (current tip of work)

### Just finished (most recent user request)

**Offline library when server is unreachable.**

Problem: local chapter downloads existed, but Library still required live GraphQL → empty/error UI offline. Covers were not persisted.

**Implemented:**

1. Cover cache under `{appDocuments}/catalyst_offline/covers/{mangaId}.*`
2. `listOfflineManga()` / `buildOfflineMangaStub()` on `LocalDownloadsService`
3. Library fallback: if category fetch fails and offline manga exist → synthetic category `kOfflineLibraryCategoryId = -1` labeled via `l10n.downloads`
4. `categoryMangaList` returns offline stubs for that category (or soft-fallback on fetch failure)
5. `MangaWithId` uses `buildOfflineMangaStub` (title, cover/`file://`, downloadCount, unreadCount)
6. New downloads call `cacheCoverFromUrl`; older downloads fall back to first page image as cover
7. Details + reader offline paths already existed; Library discovery was the hole

**Key files:**

- `lib/src/features/manga_book/data/local_downloads/local_downloads_service.dart`
- `lib/src/features/library/presentation/category/controller/edit_category_controller.dart` (`offlineLibraryCategory`)
- `lib/src/features/library/presentation/library/controller/library_controller.dart` (`categoryMangaList`)
- `lib/src/features/library/presentation/library/library_screen.dart` (`_categoryLabel`)
- `lib/src/features/manga_book/presentation/manga_details/controller/manga_details_controller.dart`
- `test/offline_library_test.dart`

**Not committed.** Large uncommitted working tree on `main` (see §7). Do **not** commit unless user asks.

---

## 3. User intent across this conversation (priorities)

| Theme | Status |
|--------|--------|
| Iterative bug hunt (“until it’s 00”) | Many rounds; cannot literally reach zero by inspection |
| Usagi dual online/offline mode | Designed, **not built** (except offline downloads visibility above) |
| Usagi-like UI (fonts/colors/motion) | Partially done earlier (`CatalystUiTokens`, themes); not the active focus at handoff |
| History detail pane (“opened manga”) | **Removed** — list-only on all sizes |
| Collapsible library category rail | Done |
| Android bottom gaps too big | Fixed via `scrollBottomInset` |
| iOS home parity | Progress bars + long-press menu on history tiles |
| “How can I be sure it’s bug-free?” | Explained limits; user chose **tests** next |
| Core logic test suite | Done (~45 → **102** tests); regression-proven against old bugs |
| Offline downloaded manga visible | Done (this tip) |
| Push / release v7 / Codemagic | Done earlier in conversation; current tree has more unpushed local work |

---

## 4. Critical bugs fixed this conversation (do not reintroduce)

These were real production bugs. Several now have regression tests.

### Reader / session

- **`WidgetRef` after dispose** in reader `useEffect` cleanup → use `ProviderScope.containerOf` / `ProviderContainer`; `ReaderSession.leave()` in `finally`.
- **`ReaderSession._depth` leak** on chapter `pushReplacement` → `ReaderSession.beginTransition()` (+ post-frame `leave`). Sites: `reader_chapter_navigation.dart`, `directional_swipe_gesture_handler.dart`. Test: `test/reader_session_test.dart`.
- Tracker sync only on **chapter complete**, not every page save (`tracker_progress_sync.dart` + `reader_screen.dart`).
- Last-page flush: only advance `lastFlushedPage` if save cleared `pendingPageIndex`.
- Continuous reader: guard `index <= 0`; slider timer must clear `isUserScrolling`.

### Offline pages / downloads

- `getLocalPages` must return `List<String?>?` with **null holes** (no index shift). Merge via `mergeLocalAndRemotePages` in `reader_page_merge.dart`. Tests: `reader_page_merge_test.dart`, `local_downloads_pages_test.dart`.
- Delete must cancel in-flight download (`_cancelRequested`, generation bump); don’t write manifest after cancel.
- Download queue reorder: pass **absolute** queue indices; don’t wipe state if reorder API returns null.

### Library / chapters / reading order

- Resume / “first unread” and “mark previous as read” must use **source order** (`ChapterDto.index` = `sourceOrder`), not display list position. Helpers: `firstUnreadInReadingOrder`, `chaptersBeforeInReadingOrder` in `chapter_navigation_utils.dart`. Test: `reading_order_test.dart`.
- Library tri-state filters: **`false` must persist** (do not coerce `false → null` in provider `build`). Tests: `library_filter_persistence_test.dart`, `library_filter_test.dart`.
- Alphabetical sort: **case-insensitive** (`library_filter_utils.dart`).
- Selection range guards on manga details; prune stale selected chapters; null-safe tablet AppBar `realUrl`.

### Other

- Backup restore: create a **fresh** `MultipartFile` after validate (finalize-once).
- `MangaMeta.fromJsonToDouble`: `double.tryParse`.
- Category FAB: always clear loading + toast on error.
- Route redirect: invalid manga ID without chapter → `/manga/0`; with chapter → `/manga/0/chapter/0`. Test: `route_redirect_test.dart`.
- History: pagination offset by consumed chapters; search client-side; auto-page empty visible sets; disabled history guards.
- Browse: shared `openSource` for tablet split; show **all** local sources; search submit ignore null close.

### UI / shell

- History tablet master-detail **removed** (`history_detail_pane.dart` deleted).
- Collapsible nav rail + library category rail (prefs persisted).
- `AppBreakpoints.usesSideRail` excludes compact nav / narrow tablets.
- `scrollBottomInset` uses safe area + fab; side rail → no bottom-nav inset.

---

## 5. Test suite (current contract)

**102 tests, analyze clean.**

| File | Guards |
|------|--------|
| `reading_order_test.dart` | Resume / mark-previous reading order |
| `reader_page_merge_test.dart` | Local+remote page merge holes |
| `local_downloads_pages_test.dart` | FS alignment of `getLocalPages` |
| `library_filter_test.dart` | Tri-state filters + case-insensitive sort |
| `library_filter_persistence_test.dart` | `false` survives SharedPreferences rebuild |
| `offline_library_test.dart` | Offline stubs, cover cache, cover delete |
| `reader_session_test.dart` | Session depth / beginTransition |
| `route_redirect_test.dart` | Bad manga paths |
| `shell_layout_test.dart` | Breakpoints / scroll inset |
| Older: theme, chapter nav, connectivity, swipe, spread, history progress | Still present |

**Convention:** extract pure helpers (`*_utils.dart`) and test them; for FS use temp dir + `path_provider_platform_interface` mock. When adding a bugfix, prefer a test that **fails against the old logic**.

Dev dep added: `path_provider_platform_interface`.

---

## 6. Architecture notes agents keep forgetting

- GraphQL default **`FetchPolicy.noCache`** — no stale library from Hive when offline.
- Offline root: `{getApplicationDocumentsDirectory()}/catalyst_offline/` → `chapters/{id}/manifest.json` + pages; `covers/{mangaId}.*`.
- `OfflineChapterManifest`: chapterId, mangaId, chapterName, chapterNumber, mangaTitle, pageCount, pages, lastPageRead, isRead. **No** full MangaDto / categories on disk.
- `ServerImage` already supports `file://`.
- Reader + manga details already had offline stubs/pages; **Library** was the missing discovery surface (now fixed).
- Do **not** use `ref` in hook dispose after unmount — capture `ProviderContainer` while mounted.
- Chapter **display** sort ≠ **reading** order (`sourceOrder` / `index`).
- `http.MultipartFile` can be finalized only once.
- Generated files: `*.g.dart`, `*.freezed.dart`, GraphQL fragments — don’t hand-edit; regenerate if schema/annotations change.

---

## 7. Git / release state

- Branch: **`main`**.
- **Many uncommitted changes** from this conversation (library, reader, history, downloads, tests, offline library, themes/shells, etc.).
- **Do not commit** binary artifacts: `Catalyst.ipa`, `app-*-release.apk`, or secrets in `android/local.properties`.
- Earlier: version **7** release / Codemagic / changelog / APK commands were handled; local tree has moved past that tag’s contents.
- Push previously needed HTTPS + `gh auth` when SSH keys failed.

---

## 8. Explicitly deferred / not done

1. **Full dual-mode app** (Usagi-like: rich offline shell, local history, extension browsing without Suwayomi) — only offline **downloaded** library/details/reader path exists.
2. **OAuth tracker login** deep-link handling (feature).
3. **Manga Refresh** calling `fetchManga` (needs GraphQL + codegen).
4. **Crash reporting** in releases (recommended for confidence).
5. **Real-device smoke** of reader (wakelock / orientation / immersive / volume / swipe) — desktop cannot prove these.
6. **Re-download covers** for manga downloaded before cover caching (fallback = first page until a new chapter download while online).
7. Offline stubs still lack description/genres/status/categories.
8. Library bulk “remove from library” / update library while offline may error — open + read is the supported path.
9. Further unread areas for audit: data/repos beyond what’s fixed, notifications, bootstrap, full history-offline, browse when offline.

---

## 9. Environment quirks (this machine)

- OS: Linux CachyOS, compositor **Niri** (Wayland).
- Flutter: `~/flutter` on PATH (prefer over system packages).
- Android emulator: memory pressure / OOM can kill emulator during Gradle; use SDK `adb` (`/opt/android-sdk/platform-tools`), not mismatched system `adb`.
- `pkill -f 'bundle/catalyst'` can kill the shell — prefer precise process kill.
- Hot reload sometimes flaky; relaunch debug binary if needed.

Useful commands:

```bash
export PATH="$HOME/flutter/bin:$PATH"
cd /home/zoro/Documents/Projects/catalyst
flutter analyze
flutter test
flutter run -d linux
# APK (when user asks): flutter build apk --release
```

---

## 10. Suggested next steps (ask user which)

1. **Device smoke test** offline library: download chapters → kill server/network → Library → open → read (Android + iOS).
2. **Commit** a focused PR (exclude APKs/IPA/`local.properties`) — only if user requests.
3. Continue **dual-mode** plan (offline home/history, reconnect sync) if user wants Usagi-like behavior beyond downloads.
4. Add **Sentry/crash reporting**.
5. Cache covers for existing downloads without requiring a new chapter (e.g. one-shot cover fetch while online).
6. Another **targeted audit** of unread layers (notifications, repos) with tests for anything found.

---

## 11. How to talk to the user (learned preferences)

- Direct, concise; don’t over-bold or pad.
- They push hard on polish and “find more bugs”; be honest that inspection ≠ bug-free; prefer tests + device runs.
- Do not commit/push/release unless explicitly asked.
- Don’t create drive-by docs/markdown unless asked (this file was requested).
- Match existing code style; extract testable utils like existing `chapter_navigation_utils.dart`.
- Frontend design rules in user rules apply to branded web work — for this Flutter app, preserve Catalyst/Usagi-inspired Material tokens already introduced.

---

## 12. Transcript / prior agent context

Full prior chat JSONL (tool calls excluded from some views):

`/home/zoro/.cursor/projects/home-zoro-Documents-Projects-catalyst/agent-transcripts/43d44f93-525a-4bb2-b5ec-a34b6ae8940c/`

Search that transcript for filenames, “offline”, “ReaderSession”, “Usagi”, “Codemagic”, “version 7” if reconstructing older decisions.

---

## 13. Quick “you are here” checklist for the next model

1. Read this file fully.  
2. Run `flutter analyze` + `flutter test` (expect clean / 102+).  
3. Offline library is implemented but **uncommitted** — verify on device if user cares.  
4. Do not restart Usagi dual-mode or mass UI redesign unless user asks.  
5. Prefer extending the test-backed util pattern for any new logic bugs.  
6. Ask before committing or releasing.
