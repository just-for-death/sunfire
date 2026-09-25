# Sunfire audit fixes — batches 1-5 (cumulative)

Batches 1-3 were delivered as a static zip/patch (no toolchain in that
sandbox). Batch 4 landed directly in the repo under the normal git workflow
and was validated with `flutter analyze` (clean) and `flutter test`
(448 passed / 1 skipped). Batch 5 (final deep-audit sweep: sync/DB, engine,
browse/migrate, library/detail, tracking, updates/reader, settings,
notifications) was validated with `fvm flutter analyze` (clean) and
`fvm flutter test` (448 passed / 1 skipped).

## Apply
Unzip over your repo root (this zip already contains batch 1, so it just
overwrites those files again):

    unzip -o sunfire-fixes.zip -d /path/to/sunfire
    cd /path/to/sunfire && flutter analyze && flutter test test/batch2_fixes_test.dart

`fixes.patch` is the cumulative diff against upstream `main` @ 15931ac
(only use it on a tree that does NOT already have batch 1 applied).

## Batch 1 (unchanged)
1. isar_service.dart — removed the serverId→Isar-local-id fallbacks (ID collisions overwrote/deleted unrelated records).
2. content_resolver_service.dart + download_manager_service.dart — `.download_complete` marker; partial folders are no longer treated as finished downloads; downloader never resolves its own partial output.
3. download_manager_service.dart — `_pauseEpoch` so pause→quick resume no longer marks the active chapter failed.
4. reader_screen.dart — stale-load guards before sibling/next/prev/reading-mode writes and before the self-healing scrape persists a URL.

## Batch 2 (new)
5. reader_chapter_navigation.dart — `findSiblingChapterIndex` matches in strict tiers (id → serverId → url → unique name). Duplicate names ("Chapter 10" twice) no longer make Next reload the same chapter; an ambiguous name-only lookup returns -1 instead of guessing.
6. reader_screen.dart — a chapter already marked read reopens at page 1 instead of the last page (which popped the end-of-chapter dialog).
7. NEW services/wakelock_coordinator.dart, sync_engine.dart, reader_screen.dart — reference-counted wakelock; background sync no longer turns off the reader's keep-screen-awake.
8. reader_screen.dart — auto-scroll "auto next chapter" now resumes scrolling after the next chapter loads (it was stopped by the load and never restarted).
9. repo_manager.dart, background_service.dart — unattended background extension updates now require a declared sha256 and an https source; otherwise the update is skipped and logged (manual updates unchanged). NOTE: the hash still comes from the same unsigned index.json, so it only guards against corruption/partial tampering. A real fix needs signed indexes or a user confirmation prompt for third-party repos — not done here.
10. NEW services/safe_curl.dart + download_manager_service.dart, image_cache_helper.dart, reader_screen.dart — curl fallbacks now use `--`, `--proto =http,https`, reject non-http(s)/multi-line URLs, drop header entries containing CR/LF, and try one plain `curl` instead of two duplicates.
11. dom_extensions.dart — new `splitTopLevelSelectors` (respects parentheses, brackets, quotes); comma-lists return a de-duplicated union in DOCUMENT order; `selectFirst` returns the first match in document order. Fixes `:is(a, b)`, `:has(a, b)`, `[x="a,b"]`.
12. library_update_service.dart — the `_isUpdating` flag is released if a constraint check throws (previously blocked all updates until restart).
13. download_manager_service.dart — `_isValidImageBytes` no longer accepts "any non-HTML blob over 500 bytes"; recognises AVIF/HEIC/JXL explicitly; GIF needs `GIF8`.
14. NEW test/batch2_fixes_test.dart — pure unit tests for 5, 10 and 11.


## Batch 3 (re-audit, reader first)
15. reader_screen.dart — **Chapter wrongly marked READ.** `_updateProgress` ran with no pages loaded (`dispose()` while loading, load timeout, source returned nothing). With `pageCount == 0` the completion test collapsed to `1 >= 1`, so backing out of a chapter that failed to load marked it read, scrobbled it, synced it to the server and could delete its download ("Immediately" rule). It now returns when there are no pages, and `dispose()` only saves progress for a fully loaded chapter.
16. reader_screen.dart — **Stale load overwrote `_chapter`.** `_chapter = await ...` was assigned before the generation check, so a slower older load could replace the newer chapter and progress/next/prev then ran against the wrong one. Now loaded into a local and published only after the check. Also `dispose()` bumps `_loadGeneration` to cancel in-flight loads.
17. reader_screen.dart + isar_service.dart — chapter lookup no longer scans the whole chapter table and no longer matches a server id against an unrelated chapter's local id (new `getChapterByLocalId`, used only for chapters with no server id).
18. reader_screen.dart — **Image retry storm.** A failed page re-ran the full multi-pass fetch (and up to 4 curl attempts on desktop) on every rebuild. Failed URLs are remembered; only tapping Retry tries again. The spinner now flips to Retry when recovery fails.
19. reader_screen.dart — paged-mode tap/volume throttle 700ms → 250ms (animation is 220ms), so quick page turns are no longer swallowed.
20. download_manager_service.dart — **Regression fix for batch 1.** Downloads made before the completion marker existed would have stopped counting as downloaded. A one-time migration (`downloads_completion_marker_migrated_v1`) grandfathers existing folders that have images and are not in the queue. Runs before the startup scan.
21. browse_screen.dart — setState after the awaited extension install/uninstall is now guarded by `mounted` (leaving the tab mid-install threw in release).

## Correction to the original audit
Finding 9 said extensions install "without a user prompt". Manual installs from a non-official repo DO show a third-party confirmation (browse_screen `_confirmThirdPartyInstall`). Only the unattended background auto-update lacked one, which is what item 9 addresses.

## Behaviour changes to be aware of
- Repos that declare no sha256 will no longer auto-update in the background (item 9).
- Stricter image validation (item 13): a source serving an unusual format will now fail to download instead of saving junk. Tell me the format if you hit this.

## Batch 4 (new — post-v3.0.0-stable deep audit)

Batch 4 fixes the final deep-audit findings (feature + UI + code-path audit,
validated with `flutter analyze` clean and `flutter test` 448 passed / 1 skipped):

**Core engine / reliability**
22. quickjs_service.dart — (6.3) production mock-data scrape fallback is gated
    behind `kDebugMode` so a Cloudflare-blocked source can never surface a
    phantom "manga" to users (Browse/library/detail). (6.1) `_AsyncLock` now
    reports wait overruns and `withRuntime` routes overrun callers onto a
    temporary fresh runtime instead of re-entering the still-busy native one
    (flutter_qjs `evaluateAsync` is a synchronous FFI eval; two overlapping
    evals on one runtime is undefined behavior). Overrun holder futures are
    re-chained so later callers keep waiting for the straggler.
23. metron_api_client.dart — (7.1) HTTP 429 retries are capped at 3
    (`requestOptions.extra['_metron429Retries']`) instead of retrying forever
    while the rate-limit stays active.
24. isar_service.dart — (5.2) `deleteCategory` uses serverId only; the local-id
    fallback that could delete the wrong row is removed (mirrors Batch 1 item 1).
25. graphql_client_service.dart — (3.1) HTTP-200 GraphQL payloads that carry an
    auth-shaped error now surface a reconnect prompt via the new
    `_looksLikeAuthError` + `notifyAuthError()` path; (3.2) `fetchLibrary`
    stops truncating at the server's first `totalCount` position (offset-stall
    guard) so the library no longer silently stops at chapter/Manga boundaries;
    (3.3) details-fetch loop capped against an offset-ignoring server plus a
    25000-node ceiling; (3.4) `updateExtension` propagates failure instead of
    always returning success.
26. sync_engine.dart — (2.4) dispatch failures are classified `transient` only
    when the server is genuinely unreachable AND there is no auth error, so
    rejected credentials no longer enter the 14-day retry churn.
27. websocket_service.dart — (4.1) pong watchdog: pings were sent every 25s but
    pongs were never verified, so a half-open TCP connection (server killed
    without FIN) kept `_isConnected=true` forever. Now a pong timestamp is
    tracked and 75s of silence forces a disconnect + reconnect.
28. repo_manager.dart — repo cache files are only written AFTER JSON parses AND
    `_coerceSourceList` validates, so a corrupted cache can never be persisted.
29. Empty `catch (_) {}` blocks: audited every catch in lib/; the two genuinely
    empty ones (tracking_settings_screen.dart `_fetchServerTrackers`,
    image_cache_helper.dart guarded direct fetch) now log via `kDebugMode`.

**Browse / search / import**
30. browse_screen.dart — uninstall now shows a confirmation dialog for BOTH JS
    and server extensions (with dependent-library count warning); the
    `deleteLocalExtension` result is honored; a busy-set prevents double-tap
    races; all setters mounted-guarded.
31. global_search_screen.dart / migrate_search_screen.dart — generation tokens +
    15s per-source timeouts so a slow source can never clobber the results of a
    newer search with stale ones.
32. import_tachibk_screen.dart — `_applyImport` wrapped in try/catch with
    error surface instead of an unhandled async failure.
33. tracking_bottom_sheet.dart — `_bindManga`/`_unbindRecord`/Save-Changes are
    try/catch + mounted-guarded; the score-dropdown snaps to saved value.

**Settings / onboarding / stats / updates / reader**
34. onboarding_screen.dart — `_finishOnboarding` persists the NORMALIZED server
    URL (scheme-repaired like `_testAndConnectServer`), so typing
    `192.168.1.5:4567` survives; hydration catch/finally are mounted-guarded.
35. server_settings_screen.dart — URL tile normalizes (trim, strip trailing
    slashes, prepend `http://`) before persisting/initializing, matching
    onboarding.
36. stats_screen.dart — "1 days" → "1 day".
37. updates_screen.dart — filtered-to-empty state ("No Matching Updates" with
    Clear-filters) instead of a blank list when unread/language/search filters
    exclude everything.
38. reader_screen.dart — paged-mode EOC transition-card itemCount is gated on
    `seamlessTransitions && showEndOfChapterDialog` (same as long-strip), so
    the dead end-of-chapter toggle can no longer produce a phantom page.

## Still NOT done (from the audit) — as of Batch 5
Image retry-storm memory, 700ms page-turn throttle, SyncRecord coalescing and
transient-error abandon counting, unread-state propagation, wipe-guard
count/8s timeout, N+1 chapter queries / startup scan cost,
volume-key paging at min/max, debug-key release fallback in build.gradle,
charger banner / resume flicker, "Continue reading" sort, CI workflow.

Items from the original list that ARE now done in Batch 4: the JS 180s lock vs
30s reader timeout (item 22, overrun ephemeral runtime) and the empty
`catch (_) {}` blocks (item 29 — the two genuinely empty ones now log; there
are no remaining empty catch bodies).

Item from the original list that IS now done in Batch 5: the
`cleanupBulkScrapedUpdates` `serverId > 200000` heuristic (item 40 — only
negative synthetic ids are treated as standalone-scraped now).

---

## Batch 5 (new — final deep-audit sweep)

Final pass over the deep audit: sync/DB, engine, browse/migrate,
library/detail, tracking, updates/reader, settings, backup import and
notifications. Validated with `fvm flutter analyze` clean and
`fvm flutter test` 448 passed / 1 skipped.

**Sync / database**
39. isar_service.dart — `getRecentChapters` and `getInProgressChapters` no
    longer under-fill via a single `limit * N` pre-fetch; both now page through
    the feed (pageSize + hard scan ceiling) and filter to library manga in
    Dart, and `getInProgressChapters` excludes titles removed from the library
    (previously a removed/never-added title could surface in Continue Reading).
40. isar_service.dart — `cleanupBulkScrapedUpdates` only treats NEGATIVE
    serverIds (the one synthetic range this app ever mints for standalone
    chapters) as standalone-scraped; the old `serverId > 200000` heuristic
    could delete genuine server history on libraries whose real chapter ids
    exceed 200000.
41. graphql_client_service.dart — `fetchHistoryChapters` paginates the whole
    read history (`LAST_READ_AT DESC`, 500/page, offset-stall guard, 5000-node
    ceiling) instead of one un-ordered 500-row shot that could silently lose
    the most recently read entries.
42. graphql_client_service.dart — `fetchServerUpdateStatus` queries the modern
    `libraryUpdateStatus { jobsInfo { isRunning finishedJobs totalJobs } }`
    field; library_update_service.dart and websocket_service.dart consume the
    new shape, with the deprecated `updateStatus`/`updateStatusChanged` names
    kept as a fallback for older server builds.
43. graphql_client_service.dart — `createServerBackup` sends the
    `PartialBackupFlagsInput` (`flags: { includeManga, includeCategories,
    includeChapters }`) the current schema expects instead of the removed
    top-level booleans; backup_settings_screen.dart surfaces a failure when the
    server returns no backup URL instead of reporting a fake success.
44. graphql_client_service.dart — library/extension/category queries now fetch
    the `lang`/`default` fields they use, and `fetchChapterPages`'s loop-stall
    guard uses the node-count delta so a server that ignores `offset` can no
    longer loop (the old offset-equality check could compare new offset to an
    unchanged one and keep looping on a server returning fewer rows per page).
45. sync_engine.dart — `fetchLibrary` pull is hardened per node: non-map nodes,
    non-positive ids and badly-typed fields are skipped instead of aborting the
    entire sync; source name falls back through name/displayName/sourceId;
    source language comes from the new `lang` field. The outer 8s `fetchLibrary`
    timeout is removed — each page request is already individually bounded and
    the cap wrongly disabled sync permanently for any library needing more than
    one page (~200+ manga) or a slower server.
46. sync_engine.dart — `syncMangaCategories` accepts `existingCategoryIds` and
    `setMangaCategories` becomes a diff (add/remove) instead of a blind
    replace, so editing categories on a client that doesn't currently know all
    server categories can no longer wipe the unknown ones.
47. sync_engine.dart — `_pushTrackerProgressForManga` treats a null
    track-records payload as a failure (record stays queued for retry) instead
    of "no tracker bound / success" — a transport or GraphQL error could
    previously drop a pending progress mutation silently.
48. websocket_service.dart — subscribes to `libraryUpdateStatusChanged` (the
    modern event name; the old name is kept as a fallback) and `dispose()`
    now cancels the pong watchdog timer/state.
49. background_service.dart — disabling the update frequency (0h) now cancels
    any stale periodic task registered on a previous boot instead of letting it
    keep running after the user turned auto-update off.
50. notification_service.dart — background-isolate notification taps (app
    killed) are forwarded to the main isolate via `IsolateNameServer`, so the
    payload actually navigates; new-chapter notifications use a per-batch
    unique id (wrapping under the reserved download range) instead of a shared
    `1001` that made successive notifications silently replace each other.

**Engine**
51. quickjs_service.dart — `getExtensionCoverUrl` is now `Future<String?>` and
    runs under the per-source `withRuntime` lock. It previously evaled
    directly on the shared pooled runtime (`_getOrCreateRuntime`) — an
    unsynchronized FFI eval that is undefined behavior when it overlaps
    another call on the same runtime. All 8 call sites
    (sync_engine ×2, image_cache_helper ×3, library ×2, manga_detail) await it.

**Browse / search / migrate**
52. source_manga_grid_screen.dart + global_search_screen.dart — results not
    from the Suwayomi server (`origin != 'server'`) get synthetic NEGATIVE
    serverIds so a local JS scrape can never collide with a genuine server id
    in Isar's unique index; quick-add gates its server mutations
    (`updateMangaLibraryState` / `updateMangaCategories`) on `isServerSourced`
    so a bogus/foreign id is never pushed up.
53. migrate_search_screen.dart — hard `as String` / `as List<dynamic>` casts
    replaced with `_sourceDisplayNameOf()` / `_coerceGenres()` helpers
    (genre field accepts List, Map or comma-separated String from different
    sources; chapter-list entries that aren't maps are skipped instead of
    throwing mid-migration).
54. manga_detail_screen.dart — `_loadMangaDetails` gets a generation token and
    hardened `Map`/`List` casts, so a stale or schema-drifted response can
    neither crash nor clobber a newer load; chapter dedup keys prefer URL over
    chapter number (numbers are shared by prologues/re-releases and would
    wrongly collapse distinct chapters).
55. metron_series_detail_screen.dart + metron_api_client.dart —
    `_applyMetronLink` persists the issue map with `jsonEncode` (a hand-joined
    JSON string silently corrupted future scrobble lookups whenever a key
    contained JSON-special characters); `_scheduleNextSpacing` completes the
    CAPTURED completer instead of the (possibly replaced) current one — under
    concurrency a late response swapping the completer before the spacing timer
    fired left the older request hung forever.

**Library / detail / tracking**
56. library_screen.dart — `_clampCategoryIndex` keeps the selected category
    valid after a server category rename/delete; the "Downloaded" filter also
    matches SERVER-downloaded manga via the new `downloadedServerMangaIds`;
    `chapterCount` is denormalized alongside `unreadCount` after library
    updates; select-all decides on "are all VISIBLE items selected" instead of
    list-length equality (stale selection ids toggled it the wrong way);
    category create uses `max(order) + 1` instead of list length (collisions
    after a deletion scrambled the tab order); the tune-icon dot now reflects
    every active display customization.
57. download_manager_service.dart — server-downloaded manga id set keeps the
    library "Downloaded" filter in sync; rebuilt after every server-queue
    mutation (enqueue, enqueue-many, delete, `markChapterDownloadedOnServer`)
    and `deleteLocalDownload` only clears the LOCAL flag — a server download of
    the same chapter keeps its flag.
58. manga_detail_screen.dart — `_refreshUnreadCount` queries the route id first
    (for standalone titles the old code queried a different id space, matched
    nothing and silently saved unreadCount=0 on every read/unread action,
    wiping the library badge); `_targetMangaId` guards a zero/unset id;
    `setState` in the multi-select actions is mounted-guarded; chapter merge
    copies download state per-flag so a server-only download isn't relabeled
    local (and vice-versa).
59. tracking_bottom_sheet.dart — search generation tokens (a slow/stale Metron
    or tracker search can't clobber a newer one, finding #21/#22); track dates
    normalized ms↔seconds (`_normalizeTrackEpoch`); unknown statuses clamped to
    a known Dropdown value (#20); chapter stepper clamps at `totalChapters`
    (#24); start/finish date rows get a clear button; `_bindManga` /
    `_unlinkMetron` / `_scrobbleAllReadChapters` / `_unbindRecord` are
    mounted/loading guarded; unbound status label shows "Unknown" instead of a
    misleading "Reading".

**Updates / reader / settings / shell**
60. updates_screen.dart — the server-merge copies download state per-flag
    (`isDownloadedLocally` / `isDownloadedOnServer`) instead of the combined
    setter; the single-toggle and bulk mark-read actions now keep the library
    unread badge in sync and run the manga-detail side effects
    (delete-if-marked-read + Metron auto-scrobble) exactly as the detail screen
    does — previously the badge went stale until the next full refresh.
61. reader_screen.dart — the manga `lastReadAt` stamp the reader writes is
    epoch-SECONDS (matching `Chapter.lastReadAt` and the server's chapter
    lastReadAt), so library "Last Read" sorting no longer mixes milliseconds
    and seconds.
62. settings — server_settings_screen.dart: `authMode` now uses the real schema
    enum (`BASIC_AUTH`/`SIMPLE_LOGIN`/`UI_LOGIN`), the WebUI flavor/channel/
    interface dropdowns carry real enum values (`WEBUI`/`VUI`/`CUSTOM`,
    `BUNDLED`/`STABLE`/`PREVIEW`, `BROWSER`/`ELECTRON` — the old `TAIDI`/
    `SYSTEM` values never existed and could never be restored), version display
    starts as "Unknown"; browse/downloads/server settings guard `setState`
    after awaits, and `_update` no longer silently swallows the optimistic UI
    change when disconnected (it tells the user nothing was persisted);
    library_settings_screen.dart resolves the default category by id (a stale
    stored name left the radio dialog with nothing selected) and adds a
    dynamic dropdown item when the server's update interval isn't one of the
    presets; tachibk import respects `favorite` (library membership) and only
    creates categories actually referenced by imported entries.
63. main_shell.dart — the start tab honors `MainShell.selectedTabNotifier`
    (already set by the route pageBuilder for deep links / notification taps)
    instead of clobbering it with the startScreen preference — previously a
    notification's `/updates` route landed on the wrong tab with the URL
    desynced.
