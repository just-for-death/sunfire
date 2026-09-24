# Sunfire audit fixes — batches 1-3 (cumulative)

Static, uncompiled fixes (no Flutter/Dart toolchain in the sandbox — every
file was syntax-checked with tree-sitter only). Run `flutter analyze` and
`flutter test` locally before pushing.

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

## Still NOT done (from the audit)
Image retry-storm memory, 700ms page-turn throttle, SyncRecord coalescing and
transient-error abandon counting, unread-state propagation, wipe-guard
count/8s timeout, N+1 chapter queries / startup scan cost, JS 180s lock vs 30s
reader timeout, `cleanupBulkScrapedUpdates` serverId>200000 heuristic,
volume-key paging at min/max, debug-key release fallback in build.gradle,
charger banner / resume flicker, "Continue reading" sort, CI workflow,
91 empty `catch (_) {}` blocks.
