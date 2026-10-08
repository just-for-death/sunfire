# Changelog

All notable changes to Sunfire are recorded here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

[4.0.0]: https://github.com/just-for-death/sunfire/releases/tag/v4.0.0
[3.0.0]: https://github.com/just-for-death/sunfire/releases/tag/v3.0.0
[2.5.0]: https://github.com/just-for-death/sunfire/releases/tag/v2.5.0
[2.0.0]: https://github.com/just-for-death/sunfire/releases/tag/v2.0.0
[1.5.0]: https://github.com/just-for-death/sunfire/releases/tag/v1.5.0
