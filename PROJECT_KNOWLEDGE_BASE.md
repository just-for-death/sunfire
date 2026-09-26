# Sunfire & Mangayomi Extensions — Comprehensive Architecture & Knowledge Base

## 1. Project Overview & Ecosystem
* **Sunfire** (`just-for-death/sunfire`): Flutter-based manga reader and synchronization client for Suwayomi / Tachidesk servers with local QuickJS scraping support, offline library replication, and image cache resilience.
* **Mangayomi Extensions** (`just-for-death/mangayomi-extensions`): JavaScript-based source extensions defining web scraper logic for online manga catalogs, search, chapter metadata, and page image extraction.

---

## 2. Core Architecture & Workflows

### A. Dual-Mode Content Resolution (`ContentResolverService`)
1. **Server Mode**: When connected to Suwayomi GraphQL backend (`/api/graphql`), fetches catalog, chapters, library, reading history, and updates directly from the server.
2. **Local QuickJS Extension Mode**: When server is offline or for local browsing, executes source scrapers locally via QuickJS runtime.
3. **Continuous Source Migration (`SourceMigrationService`)**:
   - Automatically maps server-installed source names to local JS extensions.
   - Re-maps library items so chapters can be scraped on-device when server is offline.

### B. Networking & Cloudflare Bypass (`MClient`)
* `dart:io` HttpClient on Android/Linux/Windows (no Play Services Cronet / GMS).
* Cupertino `NSURLSession` on iOS/macOS.
* **FlareSolverr Integration**:
  - Automatically intercepts Cloudflare 403 / challenge pages.
  - Normalizes proxy endpoints to `/v1`.
  - Reuses named sessions (`sunfire_<domain>`) across requests to avoid re-solving challenges repeatedly.
  - Stores cookies globally and attaches them to subsequent requests.
  - In-flight request deduplication prevents concurrent spam to the challenge proxy.

### C. JavaScript Scraper Engine (`QuickJsService` & `JsExtensionService`)
* **Bundled Libraries**: Extensions bundle self-contained libraries (e.g. `CryptoJS` for AES decryption).
* **DOM Selector Support**: Custom `Document` and `Element` wrappers executing fast cheerio/jsoup-like queries.
* **Metadata Extraction**: Resilient regex handles unquoted, double-quoted, and single-quoted `mangayomiSources` metadata.
* **Header Cache**: Source headers (`User-Agent`, `Referer`) are captured per source/URL and cached for image fetchers.
* **Canonical extension identity (v2)**: Installs are keyed by *base name* via `extensionIdentityKey`/`extensionVariantIdentityKey`/`sameExtensionIdentity` — never by the repo/asset it came from. `saveLocalExtension` reconciles away stale variants (memory + disk, length-based `.js`/`.json` suffix stripping) so an update replaces instead of duplicating; `deleteLocalExtension`/`getInstalledVersion` are variant-aware and report the highest version. Fixes the "must delete the app before updating" bug.
* **Integrity verification (v2, D2)**: `index.json` entries may declare `sha256` (also accepts `hash`/`sourceCodeHash`). `RepoManager.downloadJsSourceCode(..., expectedSha256:)` verifies the digest (pure `RepoManager.verifySha256`) before install and refuses on mismatch; absent hashes fall back to the third-party (D1) warning.

### D. Image Cache & Magic Byte Validation (`ImageCacheHelper`)
* **Strict Validation (`_isValidImageBytes`)**:
  - Checks magic bytes: JPEG (`FF D8`), PNG (`89 50 4E 47`), WebP (`RIFF ... WEBP`), GIF (`47 49 46`), BMP (`42 4D`).
  - Rejects HTML (`<`), JSON (`{`), and array (`[`) error responses to prevent caching Cloudflare 403 pages as corrupted image files.
* **Two-Stage Fetch**: Standard `HttpClient` with custom headers, falling back to system `curl` with source headers and timeouts.
* **Disk Caching**: Stores verified image bytes in application documents/support cover directories.

### E. Database & Offline Resilience (`IsarService` & `SyncEngine`)
* **Isar Local Database**: Stores manga models, chapter lists, reading progress, and metadata.
* **Wipe Guard**: Prevents local library deletion if the server returns an empty or reset catalog.
* **Snapshot Caching**: Pre-fetches chapter lists and covers for library manga to allow uninterrupted offline reading.
* **Failed-sync recovery (v2, A2)**: After 5 retries a `SyncRecord` was marked `abandoned` and never retried. `IsarService.getFailedSyncRecords()` (failed **or** abandoned) feeds `SyncEngine.retryFailedSyncRecords()`, which resets them to `pending` and kicks an immediate flush — surfaced as **Settings → Advanced → "Retry Failed Sync"**.
* **Auth-error classification (v2, A1)**: `GraphQLClientService.authErrorNotifier` (a `ValueNotifier<bool>`) is set on any 401/403 (query or reachability probe) and cleared on the next successful authenticated request / `initialize()`. The main shell listens and shows a one-shot "Reconnect to server" snackbar routing to `/settings/server`, instead of silently returning `null`.

### F. Local Download Queue (`DownloadManagerService` & `DownloadForegroundTask`)
* **Queue persistence**: `_localTasks` is serialized to SharedPreferences (`sunfire_download_queue_v1`) on every transition. Interrupted `downloading` tasks reset to `queued` on load. `LocalDownloadTask` carries a JSON-persisted `chapterNumber` (default 0, backwards compatible) used for reading-order sorting.
* **Reading order**: `sortQueuedTasks` processes queued chapters ascending by `chapterNumber` (grouped by `mangaId`, deterministic `chapterId` tie-break because Dart's sort is unstable). Sources return chapters newest-first, so this sort is what makes a batch download 1, 2, 3… instead of 100, 99…
* **Background survival (Android)**: `flutter_foreground_task` runs a dataSync FGS while the queue is active. The UI isolate stores a JSON snapshot (`sunfire_fgt_download_progress` — built by `DownloadForegroundTask.buildSnapshot`, includes `updatedAt`) via `saveData`; the background `DownloadTaskHandler` re-renders the service notification from that snapshot in its own isolate. **Zombie guard**: the handler calls `DownloadForegroundTask.isSnapshotStale(raw)` (for any snapshot older than 90s or unparseable) and stops the service — a force-killed app can never leave a permanent FGS notification running. To keep the snapshot fresh even while one chapter downloads for minutes, `_processLocalQueue` runs a 30s heartbeat (`DownloadForegroundTask.heartbeatInterval`) that re-calls `_refreshActiveNotifier()`. Tapping the notification's "Stop" sends `{'action': 'pause'}` to the main isolate (wired in `main.dart` via `addTaskDataCallback` → `pauseLocalQueue()`).
* **Notifications**: Android uses the FGS notification while `backgroundDownloadsEnabled`; **when that toggle is off (or on non-Android platforms) the ongoing progress falls back to `flutter_local_notifications` (`sunfire_downloads` channel, id 4001)** so download feedback never disappears. Batch completion posts a summary (id 4002) whose copy is produced by the pure `NotificationService.downloadsCompletionSummary(...)`. Both are gated by `downloadNotificationsEnabled`.
* **Batch accounting**: `_beginBatch()` counts retryable tasks (queued+paused+downloading) via the testable `DownloadManagerService.countRetryableTasks(...)`; pause/cancel/delete/dismiss keep `_completedInBatch`/`_failedInBatch` accurate so the `$completed/$total` shown by the notifier reflects reality. Dismiss marks the task cancelled *before* cancelling its token (no double-count); retrying a failed task replaces its slot instead of inflating `_batchTotal`.
* **Pause persistence**: explicit `pauseLocalQueue()` persists `sunfire_download_queue_v1_paused`. `initialize()` only auto-resumes when the flag is clear, and `main_shell`'s foreground handler uses `resumeLocalQueueAfterForeground()` (never overrides an intentional pause). Only the user-facing resume (`resumeLocalQueue()`) clears the flag.
* **Lifecycle**: `main_shell.dart` calls `resumeLocalQueueAfterForeground()` on `AppLifecycleState.resumed`; `initialize()` resumes an unpaused queue so a killed app restarts its downloads on next launch. Android 15's 6h dataSync timeout is accepted — the FGS `onDestroy(isTimeout)` sends `{'action': 'pause'}` so chapters stop cleanly, and the queue resumes on next foreground. `startService` is gated on `FlutterForegroundTask.isAppOnForeground` (Android 12+ forbids background starts). FGS init + `addTaskDataCallback` run before `DownloadManagerService.initialize()` in `main.dart` so the Stop tap is never lost.
* **Charge gate (v2, B3)**: `battery_plus` is bundled behind `BatteryStateService` (fail-open `isCharging`). `DownloadManagerService._isCharging()` honors the `downloadOnlyWhileCharging` setting: the queue pauses when unplugged and resumes on a battery-state event when plugged in (only from a charge-gate — an explicit user pause is never overridden). `LibraryUpdateService.checkForNewChapters` honors `libraryUpdateOnlyCharging` the same way. The queue screen shows an "isWaitingForCharger" banner. `chargingProbe` is the unit-test seam.
* **Background-interrupt awareness (v2, B1)**: on suspend `noteAppBackgrounded()` records whether the queue was active (pure `backgroundInterruptsDownloads`); on resume `consumeBackgroundInterrupted()` returns the marker once and the shell posts `NotificationService.showDownloadsResumedNotification(...)` (pure `downloadsResumedSummary` copy). This makes the iOS/macOS pause-then-resume explicit. Native URLSession/BGTaskScheduler transfers remain a v2.1 spike — see `docs/planning/ios-background-downloads.md`.

### G. Reader: End-of-Chapter Dialog & Sibling Navigation (`reader_chapter_navigation.dart`)
* **Mihon/Mangayomi-style popup**: reaching the last page (paged modes via `_onPageChanged`, webtoon via `_onVerticalScroll` at `pageRatio >= 1.0`, or auto-scroll end when auto-next is off) shows an end-of-chapter `AlertDialog` with **Previous Chapter / Next Chapter / Close**, once per chapter (`_endOfChapterDialogChapterId` guard). Gated by the `showEndOfChapterDialog` setting (default true) and the pure `shouldShowEndOfChapterDialog(...)` helper. The existing transition-card overlay gained an `IgnorePointer` scrim so the decorative gradient no longer steals taps from the page.
* **Sibling resolution**: `_loadChapterAndPages` uses pure helpers — `chapterSortNumber` (explicit `chapterNumber`, else parse "Chapter 12"/"Ep. 7"/"#3"), `sortSiblingChapters` (reading order, newest-first reversed), `findSiblingChapterIndex` (id → serverId → url → name), `siblingChapterAt` (+1 next, −1 prev). All unit-tested; identical semantics to the old inline code.
* **Progress flush on chapter switch**: `_loadChapterAndPages` cancels the debounce timer *and* flushes a final `_updateProgress(_currentPage)` before tearing the chapter down, so reaching the last page and immediately advancing still marks read / pushes the tracker / runs the delete-finished-chapter rules. `_updateProgress` pushes tracker/Metron only on a `!wasRead && isRead` transition (no duplicate scrobbles).
* **Stale-resolution race guard**: the `_loadGeneration` check runs *before* any state write (source/page-list), so a timed-out resolution from a previous chapter can't clobber the current one.
* **DOM/sheet interplay**: the EOC dialog is suppressed while auto-scroll is driving the sheet (`_isAutoScrolling`); the keyboard volume-key handler shares the platform listener's 280ms debounce (`_lastIosVolumeTurnTime`) so one press can't double-turn; the chapter selector uses `findSiblingChapterIndex` so `serverId==0` local chapters still highlight.

### H. Audit-hardening details (v1.5 same-release)
* **Offline category → assign remap**: `SyncEngine.remapOfflineAssignRecords` rewrites pending `assign` payloads after a category-create flush remaps `localServerId → remoteId`; without it the server silently drops assignments made while offline.
* **Deterministic replay**: `_flushPendingMutations` ties same-timestamp records by `id` (Isar auto-increment) since Dart sort is unstable.
* **Relative URLs**: `ContentResolverService.resolveRelativeUrl(base, path)` uses `Uri.resolve` (protocol-relative paths, base-path handling, `//` collapse); applied to server pages, server thumbnails, and extension chapter URLs.
* **Repo cache fail-safe**: `RepoManager.fetchRepoSources` never discards a fresh fetch when the cache write fails (logged).
* **Date format wiring**: `SettingsService.formatDate` (driven by the `date_format` pref) is now used for absolute chapter dates in `manga_detail` (relative Today/Yesterday preserved).

### I. v2 features: `.tachibk` restore, language badges, navigation, third-party warning
* **Client-side `.tachibk` restore (A3)**:
  - `TachiBkParser` reads the `Tachiyomi/backup.json` entry from the zip (`archive` package) into `TachiBkBackup { sources, categories, manga }`; malformed archives throw `TachiBkParseException` with user-facing copy.
  - `TachiBkImportService.planImport(backup, serverSources)` is **pure**: matches each manga to an installed server source by normalized **(name, lang)** (displayName fallback), producing ready/source-missing entries + the sorted `categoriesToCreate`. `planImportFromServer` fetches `sources { nodes }`.
  - `applyPlan` creates missing categories (`createCategory`), resolves each manga via `GraphQLClientService.fetchMangaIdByUrl(sourceId, url)` (Suwayomi `addManga`), then `setMangaCategories`. Returns imported/failed counts + per-title messages.
  - UI: `ImportTachibkScreen` (file_picker → plan → per-entry checkboxes → apply → summary) at `/settings/import-backup`, launched from **Settings → Backup and Restore**.
* **Language badges & filter (C1)**: `SettingsService.languageBadgeLabel` (skips EN/ALL/MULTI/UNIVERSAL) drives pills on updates cards and library grid/list cards; `SettingsService.languageMatchesFilter` drives the Updates feed filter from `selectedLanguages` (unknown-language entries always pass). Gated by `showLanguageBadges`.
* **Navigation unification (C2)**: settings-facing pushes use go_router (`/settings/server|library|downloads|browse|backup|import-backup|reader|appearance|general|advanced`) instead of `MaterialPageRoute`.
* **Third-party extension warning (D1)**: installing/updating an extension from a repo outside the Sunfire Official allowlist shows a "third-party — trust at your own risk" confirmation (`browse_screen._isOfficialRepoOnly`).

---

## 3. Directory Layout & Extension Storage Locations
* **Source Extensions Repository**: `/home/zoro/Documents/Projects/manga/mangayomi-extensions`
  - Manifest: `index.json` (contains extension ID, name, version, pkgPath, baseUrl)
  - JS Sources: `javascript/manga/src/en/*.js`
* **Local App Runtime Extensions Directory**:
  - Linux Desktop: `~/Documents/extensions/` and `~/.local/share/com.sunfire.sunfire/extensions/`
  - Android / Mobile: `${getApplicationDocumentsDirectory()}/extensions/` and `${getApplicationSupportDirectory()}/extensions/`
  - Companion JSON: `<name>.json` (contains `name`, `version`, `iconUrl`)
* **Local Cover & Image Cache**:
  - `~/.local/share/com.sunfire.sunfire/covers/`

---

## 4. Extension Specific Details & Decryption Fixes
1. **MangaGo (`mangago.js`)**:
   - Encrypts chapter images in `var imgsrcs` (AES-128-CBC with ZeroBytePadding).
   - Keys: `e11adc3949ba59abbe56e057f20f883e`, IV: `1234567890abcdef1234567890abcdef`.
   - Fallback: Dynamic `SoJsonV4` deobfuscation from `chapter.js`.
   - Host transformation: `https://iweb_` -> `http://iweb_` (avoids Dart SSL rejection on underscored subdomains).
2. **MangaPill (`mangapill.js`)**:
   - Handles split sibling `<a>` tags for image thumbnail and title text.
   - Preserves items without dropping titles.
3. **MangaHere (`mangahere.js`)**:
   - Unescapes CDN query parameters (`&amp;` -> `&`).
   - Requires `Referer: https://fanfox.net/`.

---

## 5. Maintenance & Release Workflow
1. When modifying an extension in `mangayomi-extensions`:
   - Update `.js` code in `javascript/manga/src/en/`.
   - Bump version in both `mangayomiSources` (inside the JS file) and `index.json`.
   - Run `sunfire/scripts/sync_bundled_extensions.sh` so `sunfire/assets/extensions/` matches.
   - Commit and push to `just-for-death/mangayomi-extensions` (and Sunfire if assets changed).
2. When modifying the client in `sunfire`:
   - Run `fvm flutter analyze` to maintain 0 issues.
   - Run `fvm flutter test` for unit and regression tests.
   - Commit and push to `just-for-death/sunfire`.
3. **Version numbering convention** (post-stable): Sunfire betas were tagged up to `v11.0.0-beta`, then the stable line started at `v1.5.0` and moved to `v2.0.0`, then `v2.5.0`, then `v3.0.0`, then `v4.0.0`. Stable releases reset the build suffix to `+1` (so `4.0.0+1` is the current stable; beta builds carry larger suffixes like `3.0.0-beta+22`). Pure semver therefore compares `11.0.0-beta` as newer than `1.0.0`, which wrongly labels stable as a downgrade. Use `RepoManager.compareAppVersions(a, b)` for any Sunfire self-version comparison: it makes a stable release (no `-` prerelease marker) ALWAYS beat any prerelease, and otherwise delegates to the unchanged semver `RepoManager.compareVersions` (which still applies to extension versions). Current version: `4.0.0+1` (stable).
4. Test-file map for the v1.5 download/reader overhauls: `test/download_features_practical_test.dart` (order/batch/notification-copy/settings/FGS-snapshot/versioning), `test/platform_download_wiring_test.dart` (manifest/plist/registrant/text assertions), `test/reader_chapter_navigation_test.dart` (sibling sort + EOC dialog gating).
5. Test-file map for v2: `test/v2_extension_update_key_test.dart` (canonical extension identity + update reconciliation), `test/v2_features_test.dart` (tachibk parse/plan, sha256 verify, auth notifier, background-interrupt predicate/consume, resumed-notification copy, language badge/filter helpers, failed-sync retry no-op). Release notes: `docs/releases/v3.0.0.md` (v3.0.0 stable — includes the tablet/iPad navigation overhaul, iOS storage hardening, self-healing image loader, offline-category pull safety, paginated chapter fetch); roadmap status: `docs/planning/v2-roadmap.md`; iOS background limitation: `docs/planning/ios-background-downloads.md`.
6. Test-file map for v3 audit follow-ups (post-v2.5.0): `test/category_offline_sync_test.dart` (synthetic temp-id namespace, `saveCategories(replaceAll:)` pull protection, `syncCategoryDelete` pending-create/assign cancellation, legacy positive-epoch temp ids), `test/live_suwayomi_server_integration_test.dart` (paginated `fetchMangaDetails` merge parity vs root `chapters.totalCount`). Version bump convention: stable releases reset the build suffix to `+1` (`3.0.0+1`); betas carried larger suffixes (`3.0.0-beta+22`).
