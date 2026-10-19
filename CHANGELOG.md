# Changelog

All notable changes to Sunfire are recorded here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [7.0.0] — 2026-10-19

### Added

- Tablet reader HUD: wider edge insets and a larger page capsule on tablets.
- Guards: width-unsafe-`Text`-in-`Row` lint with a frozen allowlist (driven to
  empty this release); narrow-width + large-text overflow tests across the
  settings, browse and onboarding screens; DB-backed overflow and
  semantics-tree a11y audits for the library, manga-detail and reader screens;
  real-screen performance budgets; component and full-screen golden baselines.

### Fixed

- Reader: the webtoon chapter-boundary separator overflowed its fixed-extent
  slot with long chapter names at large accessibility text scales; both labels
  now clip to two ellipsized lines.
- Library: the search button and the category long-press target now expose
  screen-reader labels; the manga-detail back button exposes a localized
  tooltip.
- Overflow: width-unsafe `Text` inside `Row`s (tracking sheet/settings, stats,
  manga detail, metron detail, source grid, library offline banner, updates,
  history, browse, migrate-search, reader settings/HUD, reading heatmap and the
  conflict dialog) now wrap/ellipsize instead of overflowing on narrow phones
  and large text.
- Reader settings: "Webtoon Panel" preset tile no longer overflows at 1.3x/1.5x
  text scale.
- Settings subpages: back button exposes a localized tooltip for screen readers.
- Library: category strip scales with accessibility text size (was clipped at 44px).

### Changed

- Perf tests use generous budgets that catch pathological regressions rather
  than machine-to-machine noise.

---

## [6.2.0] — 2026-10-17

### Added

- Auto-scroll single-ticker architecture (owner-driven, no leak).
- Tap/double-tap disambiguation (260ms window, cancelled by double-tap zoom).
- Independent prev/next page throttles (250ms each).
- Haptic feedback on webtoon page turns and volume key turns.
- Accessibility: `Semantics` labels on tap zone overlay, auto-scroll HUD controls, page navigation slider, and `liveRegion` on canvas page announcements.
- Performance: debounced height-cache rebuilds (16ms) to reduce jank on long chapters.
- Code quality: extracted triplicated error placeholder into `_retryTile` helper.

### Fixed

- Auto-scroll: single ticker owned by pipeline (was leaking on stop).
- Zoom: flag syncs on pinch-in (was gated on already-zoomed).
- Webtoon zoom: checks all pages in controller map (was only current page).
- Volume rocker: single path per platform (key events off-Apple, listener on Apple); Android dispose restores volume HUD.
- Key-repeat: held keys swallowed (was spamming page turns).
- Chapter loads: gated by 700ms stamps (was double-loading).
- Controller dispose: guards against disposed zoom controller crash.
- RTL: spread pairing mirrors by default (XORs user override); paged index always page-1.
- Webtoon: vertical-paged guard in spread math; height rebuild on probe completion.
- Tap zones: out-of-bounds taps resolve to menu (was clamping to prev/next).
- Listen sheet: clamps stale page index (was RangeError).
- Prune: detaches now, disposes post-frame (was mid-build teardown).
- Progress: routes through nav coalescing timer (was separate debounce).
- Strip: null-safe guards after dispose.

### Changed

- `ReaderInputPipeline` (1,234 LOC) and `ReaderController` (1,129 LOC) hardened with dispose guards and generation counters.

## [6.1.0] — 2026-10-16

### Added

- Mihon / Tachiyomi protobuf `.tachibk` backup import (gzip protobuf and
  legacy zip JSON both accepted).
- Durable per-source `SourceCallLock` so QuickJS evals never overlap on
  one runtime (with overrun handling for hung scrapes).
- Extension HTTP redirects are followed under the SSRF request guard
  (credentials stripped on host change).

### Fixed

- Multi-language Mangayomi scripts (MangaDex, etc.) resolve one lang/id
  from `langs` / `ids` instead of stringifying the whole list.
- Extension install/update keeps the installed language — FR is never
  silently replaced by EN.
- First-run auto-install only pulls `en` / `all` JS extensions with a
  real `.js` URL (non-English still installs on demand).
- Delta sync merges server manga onto the stored row so tags, metadata
  locks, reading-mode override and `lastReadAt` survive.
- Burst sync (pull-to-refresh + WebSocket + resume) collapses into one
  follow-up pass instead of stacking full cycles.
- Cover fetches to loopback / LAN addresses are refused before any
  request leaves the device.
- Source migration matching is stricter so short tokens cannot claim
  unrelated sources.

### Security

- Same-origin checks reject prefix look-alikes (`srv.com.evil.net`).
- Session cookies are attached fresh per image request so clearing
  cookies takes effect immediately.

---

## [6.0.0] — 2026-10-14

### Added

- Tap-zone presets with a first-run overlay, and double-page spreads
  (Single / Double / Automatic, page offset, wide-page isolation).
- Smart double-tap zoom that fits the column.
- Library custom tags, smart collections, duplicate detection and
  JSON/CSV import-export.
- Sync Health screen, sync conflict dialogs and selective sync.
- "Prefetch next chapter" setting: Always, Wi-Fi only or Off.
- Migrating a manga to another source now copies its tracking.

### Changed

- The reader was rebuilt into separate parts for page loading, navigation
  and gestures. It now loads, retries and switches chapters more reliably.
- Android uses Material 3 with dynamic colour, predictive back and
  edge-to-edge.

### Fixed

- Pages that fail to load or decode show a working Retry.
- Pages appear as soon as their images arrive on desktop.
- Rapid chapter switching no longer shows a stale chapter or an error
  flash.
- Sync no longer drops a request made while another sync is running.
- Category changes and extension-store removals made offline now sync once
  you are back online.

---

## [5.0.0] — 2026-10-08

### Added

- Suwayomi-Server v2.4.2366 compatibility: `aboutServer.platform` in the
  About screen, `Category.isDefaultCategory` forward-compat field.
- Tracking edit dialog offers server-published score strings verbatim.
- Reader is fullscreen on phone and tablet (no sidebar rail / bottom bar).
- Auto-scroll range extended to 10–2000 px/s with Warp/Light presets.
- Updates tab mirrors the server when connected.

### Fixed

- Browse grid taps now open extension results (local IDs were swallowed).
- Updates header no longer leaks raw sync payloads.
- Cross-series chapters filtered at fetch and repaired at startup.
- Mangago grids deduplicated; ReadComicsOnline chapters scoped to series.
- Extension auto-install deferred until onboarding completes.
- First-run metadata parse hardened for trailing-comma headers.

### Security & Privacy

- **Credential fallback visibility** — Settings → Server shows an orange
  banner when credentials are stored in plaintext because the OS keystore is
  unavailable; secure write success cleans up the plaintext copy automatically.
- **Log sanitization** — MClient request/response logs strip query, fragment,
  and userinfo from URLs via `sanitizeUrlForLog`.
- **RFC 6761 + punycode SSRF guard** — request_guard blocks `.test`, `.example`,
  `.invalid`, `.onion`, `.lan`, `.corp`, `.intranet`, `.home`, `.localdomain`,
  and any punycode (`xn--`) labels that could decode to reserved suffixes.
- **Secure storage error handling** — narrow catches, throw on total failure
  instead of silently losing credentials.

### Sync & Download Hardening

- **Per-dispatch transport verdict** — `WithClassification` mutation helpers
  return atomically captured transport-failure verdict, eliminating cross-
  request races that misclassified GraphQL rejections as transient.
- **Attempt persistence chain** — `_attemptsSaveChain` serializes
  `_dispatchAttempts` writes; poison records never regain budget on restart.
- **Server-switch quarantine** — clears `_wsUpdatePullTimer`, `_progressLocks`,
  `_lastDirectPage`, `_cycleGate`; discarded count surfaced to user.
- **Category assign coalescing** — per-manga lock serializes rapid UI toggles;
  older pending assigns deleted before new one saved.
- **Multi-deep sync queue** — counter-based `_queuedCount` prevents dropped
  cycles under burst contention (pull-to-refresh + WS + chapter read).
- **Retry reloads attempts** — `_loadDispatchAttempts` called after persist so
  manual retry state survives restart.
- **Batch counter invariant** — `_batchMembers` + `_batchAccounted` sets
  enforce `succeeded + failed + pending == total` at all times.
- **Atomic queue+paused write** — single JSON with embedded `paused` field
  eliminates race window on process death.
- **Cancel-then-dismiss accounting fix** — stores `_statusBeforeCancel` so
  dismissing a cancelled task decrements the correct counter bucket.
- **Charger gate logic** — `_waitingForCharger` only true when charger is the
  *sole* blocker (`!chargingOk && networkAllowed`).
- **Retry adds to denominator** — re-enqueued failed task joins batch members
  and increments total.
- **Batch state validation** — corrupt/missing `members`/`accounted` resets
  counters instead of silently making batch uncountable.
- **Legacy paused flag removed** — new format embeds flag in queue JSON; old
  separate key no longer overwrites correct state on upgrade.

### Database & Backup

- **Synthetic ID collision fix** — global mutex `_mintLock` serializes
  `_mintUniqueSyntheticServerId` across concurrent `saveMangas`/`saveChapters`
  calls; prevents silent replace under `unique: true, replace: true`.
- **Bulk-stamp evidence gating** — `getRecentChapters` counts per-manga window
  before dropping bulk-import rows; evidence threshold matches flood cap.
- **Removed dangerous `clearAll()`** — no longer exposed; sign-out uses
  targeted deletes.
- **Zip bomb protection** — `.tachibk` limited to 64 MB compressed + 128 MB
  uncompressed + 1000 entries; nested archives rejected.
- **Required ID validation** — `_toInt` throws for non-integer `id` fields in
  backup JSON instead of silently collapsing to 0.
- **Honest import scope** — UI explicitly states "Library and categories only:
  reading progress, bookmarks, history, tracker bindings not imported".
- **All 6 backup flags in dialog** — categories, chapters, history, tracking,
  client data, manga (previously only 2).

### Tracker UI Overhaul

- **TrackingSettingsScreen** — Metron connection card with status dot, rate
  limit progress bars with health warnings (burst + daily), server tracker
  cards with authorization badge and login button.
- **TrackingBottomSheet** — Metron 3-state card (Linked/Connected/Not
  Configured) with rich metadata chips (Publisher, Issues in Series, Locked
  indicator, Series ID); server tracker 4 states (Tracking Active, Authorized
  Not Linked, Session Expired, Not Authorized) with color-coded borders and
  status dots; bound tracker status chips (Status, Chapters, Score, Private);
  search results with cover images and publisher info; Metron session dedup.

### Reader & Manga Detail

- **Bookmark snapshot** — captures `_chapter` before `await` so concurrent
  chapter loads cannot persist/sync the wrong chapter.
- **Auto-scroll short-chapter fix** — `maxScrollExtent <= 50` treated as
  "at bottom" instead of hanging; immediate auto-advance works correctly.
- **Next/previous chapter debounce** — 700 ms guards (`_lastNextChapterNavAt`,
  `_lastPrevChapterNavAt`) prevent accidental double-advance from tap-zone
  and auto-scroll racing.
- **Position-based prev-chapters-read** — sorts by reading order then ID; fixes
  prologue/extras with `chapterNumber=0` being skipped.
- **Scrobble session dedup** — `_scrobbledThisSession` per (series, issue)
  prevents duplicate Metron entries from rapid re-taps.
- **Incognito guards** — tracking sheet and reader paths check incognito
  before any scrobble/sync.

### Navigation & Browse

- **Route typo fix** — `/mnga/$id` → `/manga/$id` (dead-end search results).
- **Reader deep link** — `/reader/:id` handler added.
- **Fullscreen back handling** — `PopScope` allows system-back on reader
  routes instead of hijacking to Library.
- **Non-English extension badges** — `isEn` gate removed; update badges show
  for all languages.
- **Full filter reset** — clears GroupFilter/CheckBox state + clears
  `_serverFilterChanges`; stale filters no longer persist.
- **Onboarding repo choice respect** — explicit empty choice installs nothing;
  hardcoded catalogs no longer bulk-install over user choice.

### Other Fixes

- **Image cache** — true LRU (re-insert on hit), disk prune (800 files/dir,
  10-min throttle), dual-key invalidation after extension cover resolution.
- **Global search route** — `/mnga` typo fixed.
- **Extension details screen** — removed dead `_isSourceEnabled` toggle.
- **Settings persistence** — `default_catgory_id` typo fixed, `syncDeviceId`
  setter notifies listeners.
- **RepoManager version compare** — prerelease identifiers compared
  numerically (e.g., `1.0.0-beta.2` < `1.0.0-beta.10`).

[6.0.0]: https://github.com/just-for-death/sunfire/releases/tag/v6.0.0
[5.0.0]: https://github.com/just-for-death/sunfire/releases/tag/v5.0.0

## [4.0.0] — 2026-09-27

The first release under the remote-extension architecture. This is a
substantial internal rework; the user-visible surface is mostly the same, but
the way sources are delivered, the way the app behaves offline, and the way it
talks to your server all changed.

### Added

- **About page** (`Settings → About`) — app version and build number, a real
  **Check for updates** against the GitHub releases API, project links, the
  full third-party license list, a copyable diagnostics block, and links to the
  license, privacy policy, and changelog.
- **Privacy policy** and **changelog** documents, both linked from the About
  page.
- **Remote extension auto-install.** On first run, when no sources are
  installed, Sunfire fetches the official and community extension indexes and
  installs the sources to the app documents directory. Nothing is bundled in
  the app binary, so a new source reaches users without an app update.
- **Public `hasInstalledExtensions` seam** on `QuickJsService` so the
  auto-install path is directly testable.
- **First-run catalog install waits for onboarding.** No extension repo
  traffic happens before the user chooses server vs standalone; onboarding
  completion triggers the install for both paths.

### Changed

- **Updates tab mirrors the server when connected.** A successful server
  fetch makes the feed exactly the server's rows (queued read states and
  local backfills preserved per row); local-only scrapes and stale rows no
  longer linger. Offline or unconfigured keeps the local cache feed.
- **Auto-scroll range is now 10–2000 px/s** (was capped at 1000), with new
  Warp (1200) and Light (1600) presets in the reader sheet and Reader
  settings.
- **Removed bundled extensions.** The duplicated `assets/extensions/` tree is
  gone, along with its `pubspec.yaml` entry and the now-obsolete
  `scripts/sync_bundled_extensions.sh`. The remote catalog is the single
  source of truth.
- **Index schema is now strict.** `RepoSourceItem.fromJson` resolves a source's
  language from `lang`, falling back to a single-element `langs` array. Without
  this, a source published as `{"langs": ["en", "fr", ...]}` was classified as
  multi-language and vanished whenever Browse was filtered by English.
- **Per-chapter auto-scroll state**, so returning to a chapter no longer
  restores the previous chapter's scroll offset.
- **Image cache eviction** can no longer evict an image that is currently on
  screen.
- **Prefetch and download-ahead are generation-guarded**, so a late response
  from a chapter you already left can no longer overwrite the current one.
- **Curl image fallback** is limited to 2 concurrent requests instead of
  saturating the connection pool.

### Fixed

#### Sync and connectivity

- **Incognito Mode is enforced on every read-state path**, not just the reader.
  Chapter completion from the end-of-chapter card, "mark as read" from the
  chapter list, and the auto-advance path were all still writing history while
  incognito was on.
- **WebSocket liveness now means "any inbound traffic", not "a literal `pong`
  frame."** Nothing in `graphql-transport-ws` requires a server to answer a
  client ping, so a server that ignored them was force-disconnected every 75
  seconds forever — roughly 1150 handshakes a day against a socket that was
  never broken, and a window where update and download events were missed.
- **HTTP 401/403 no longer poisons server reachability.** An auth rejection was
  being recorded as a transport failure, so a server that came back with
  working credentials stayed marked unreachable. Reachability and
  authentication are now tracked separately.
- Server epochs are normalized to seconds, and a dead `last_sync_unix` write
  was removed.
- Bookmarks are pulled down; chapters deleted on the server are pruned; local
  read activity is stamped on merge; WebSocket auth is refreshed on
  reconnection; subscription setup is single-flight.
- Poison SyncRecords are abandoned after bounded retries instead of retrying
  forever.

#### Downloads

- **Local-only chapters (negative server IDs) are readable offline.** They
  downloaded successfully but could not be opened, because the reader gate
  required a non-zero server ID.
- **Foregrounding no longer resets `downloading` tasks back to `queued`**,
  which restarted in-flight downloads and double-counted batch progress.
- **No optimistic server-download marking.** A chapter was reported as
  downloaded before the server confirmed it, so a failed request left a
  permanently wrong library badge.
- A stale paused flag left by a crash is reconciled on startup.
- Partial download folders are reclaimed on failure and dismissed.
- Pages and completion markers are validated on resume and completion.
- The "Downloads resumed" notification uses a distinct ID, so it no longer
  replaces the foreground notification, and only fires on a genuine resume.
- Charging and Wi-Fi toggles respect an explicit Pause.
- Batch counters reset on interrupt; cancelling decrements the total.
- Local manga (negative manga ID) support for batch download, with badge
  cleanup.

#### Reader

- Android no longer double-advances a page turn. The volume-key listener was
  registered on every platform, including Android, which fires alongside the
  normal tap zone.
- Prefetch is keyed on `chapterId|mangaId|sourceName`, so two chapters with the
  same local ID from different sources no longer collide.
- `_pageUrls.isEmpty` guards prevent navigation actions firing before pages
  have resolved.
- `_prefetchChapter` verifies the widget is still mounted and the source still
  matches.
- Progress is written from a snapshot, so a fast chapter switch cannot write
  the previous chapter's page count against the new one.
- Self-healing a broken scrape matches on URL rather than title.

#### Errors and diagnostics

- **Silent `.catchError((_) => false)` calls are gone.** Every one now logs
  through `LoggerService` and returns a value. Previously eight failure paths
  reported "no" with no record of why.
- `ContentResolver` has a 20-second overall timeout so a stuck platform call
  cannot hang a download indefinitely.
- The Web browser URL-scheme fallback prepends `https://` to a bare domain.
- JSON metadata extraction in `QuickJsService` uses `replaceAllMapped`, so
  multiple placeholders in one string are all substituted.
- **Browse grid taps open extension results.** Local (negative-ID) results
  were silently ignored by the tap gate; any nonzero ID now opens details.
- **Updates header no longer leaks raw sync payloads** (`{jobsInfo: …}`).
  Only human-readable statuses display.
- **Cross-series chapters are filtered and repaired.** Over-broad selectors
  saved related-comic links as chapters of the scraped series; new ones are
  dropped at the fetch seam and a startup pass removed the bad rows.
- Source metadata parsing tolerates trailing commas in headers instead of
  failing into the fallback path.
- Metron 401s only warn when a token was actually sent; the tracking sheet
  no longer searches without a configured token. Notification init survives
  platforms without launch-details support (Linux) instead of re-running
  init on every notification.

### Removed

- `assets/extensions/` and its sync script.
- Executed planning documents (`UI_IMPROVEMENT_PLAN.md`,
  `READER_UPDATES_DEEP_DIVE.md`, `docs/planning/*`), now gitignored.

---

## [3.0.0]

- Reader end-of-chapter unified UX.
- Universal server sync for source migration.
- Audit fixes across the ID space: collisions between local and server IDs,
  category patching, dual resolution in manga detail.
- Offline category safety, paginated chapter fetching, a QuickJS status
  surface.

## [2.5.0]

- Batch sync hardening and follow-up fixes.
- CI pipeline and compile fixes.

## [2.0.0]

- Deep-audit remediation: data integrity, reader hardening, security.
- Extension update-key bug fix.

## [1.5.0]

- Downloads survive backgrounding, with notifications.
- End-of-chapter popup.
- Deep-audit hardening.

---

[7.0.0]: https://github.com/just-for-death/sunfire/releases/tag/v7.0.0
[6.3.0]: https://github.com/just-for-death/sunfire/releases/tag/v6.3.0
[6.2.0]: https://github.com/just-for-death/sunfire/releases/tag/v6.2.0
[6.1.0]: https://github.com/just-for-death/sunfire/releases/tag/v6.1.0
[6.0.0]: https://github.com/just-for-death/sunfire/releases/tag/v6.0.0
[5.0.0]: https://github.com/just-for-death/sunfire/releases/tag/v5.0.0
[4.0.0]: https://github.com/just-for-death/sunfire/releases/tag/v4.0.0
[3.0.0]: https://github.com/just-for-death/sunfire/releases/tag/v3.0.0
[2.5.0]: https://github.com/just-for-death/sunfire/releases/tag/v2.5.0
[2.0.0]: https://github.com/just-for-death/sunfire/releases/tag/v2.0.0
[1.5.0]: https://github.com/just-for-death/sunfire/releases/tag/v1.5.0
