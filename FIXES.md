# Sunfire audit fixes — batches 1-4 (cumulative)

Batches 1-3 were delivered as a static zip/patch (no toolchain in that
sandbox). Batch 4 landed directly in the repo under the normal git workflow
and was validated with `flutter analyze` (clean) and `flutter test`
(448 passed / 1 skipped).

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

## Still NOT done (from the audit) — as of Batch 4
Image retry-storm memory, 700ms page-turn throttle, SyncRecord coalescing and
transient-error abandon counting, unread-state propagation, wipe-guard
count/8s timeout, N+1 chapter queries / startup scan cost,
`cleanupBulkScrapedUpdates` serverId>200000 heuristic,
volume-key paging at min/max, debug-key release fallback in build.gradle,
charger banner / resume flicker, "Continue reading" sort, CI workflow.

Items from the original list that ARE now done in Batch 4: the JS 180s lock vs
30s reader timeout (item 22, overrun ephemeral runtime) and the empty
`catch (_) {}` blocks (item 29 — the two genuinely empty ones now log; there
are no remaining empty catch bodies).
