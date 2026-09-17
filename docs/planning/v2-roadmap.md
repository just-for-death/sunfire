# Sunfire v2 — Limitations Inventory & Feasibility

Status: planning. Every item below is either a documented limitation (release notes /
knowledge base) or a known audit finding. Feasibility is rated against doing the work
with the project's rules: no debug builds / no local APK (validate via `flutter analyze`
+ unit tests), and Codemagic builds the artifacts.

Legend — **S** solvable now · **M** medium effort · **L** large effort · **?** blocked by OS/platform

---

## A. Data & Sync

| # | Limitation | Solvable? | Effort | Approach |
|---|---|---|---|---|
| A1 | **401/403 auth errors collapse to `null`** GraphQL responses and are only logged — a stale/invalid token gives no user feedback and no auto-reconnect | ✅ Yes | M | Classify GraphQL errors by status; on 401/403 enter an "auth error" mode: stop sync loops, surface a "Reconnect to server" sheet in Settings / on the sync banner that re-runs `ServerAuthHelper` (re-auth from stored credentials / re-onboard). |
| A2 | **Abandoned sync records are a dead end** — after 5 retries a `SyncRecord` is marked `abandoned` and never picked up again (`getPendingSyncRecords` filters pending/failed only); no retry UI | ✅ Yes | S | Add a "Retry failed sync" action (queue screen / advanced settings) that resets abandoned+failed records to `pending`, and include them in a manual flush. Add a pure test for record-restore selection. |
| A3 | **Backup "Restore" is server-driven only** — the tile tells the user to upload `.tachibk` to the server; client-side restore is unimplemented | ✅ Yes | L | Parse Suwayomi `.tachibk` JSON (manga, categories, history) client-side with a file picker, then apply via GraphQL upserts (or local Isar import for local-only manga). Highest-value offline feature; largest scope. Needs a backup-format parser + careful id remapping (split into phases). |
| A4 | Sync identity/token storage | ✅ Yes | S | (Verify `ServerAuthHelper` refresh; minor hardening — validate token before full sync to avoid repeated 401 loops.) |

## B. Downloads & Backgrounding

| # | Limitation | Solvable? | Effort | Approach |
|---|---|---|---|---|
| B1 | **iOS/macOS background downloads not granted** — downloads pause when suspended and resume on foreground (`UIBackgroundModes` absent) | ⚠️ Partial | L | Real fix needs native URLSession background transfers / BGTaskScheduler (few minutes of work) — a plugin-level change. Realistic v2: keep resume-on-foreground (paperback/Tachiyomi-compatible behavior), add a "paused in background — resumed" notification + queue badge so it's never silent. Native BGTask work can be a v2.1 spike. |
| B2 | **Android 15 6-hour dataSync budget** — OS-imposed; queue auto-pauses at the limit (v1.5 FGS `onDestroy(isTimeout)`) | ❌ Not fully | — | OS constraint, not a bug. Mitigation already in place (clean pause + resume on foreground). Optionally surface "approaching background limit" text in the queue screen. |
| B3 | **`downloadOnlyWhileCharging` setting is inert** — no battery plugin is bundled, so the toggle does nothing | ✅ Yes | S | Add `battery_plus`; gate `isNetworkAllowed`-style check in `_processLocalQueue` (pause when unplugged, resume on charge via battery + connectivity stream); show state in the Downloads queue screen. Pure logic extracted + unit-tested. |
| B4 | Webtoon per-page `TransformationController`s + `GlobalKey`s are never pruned **within** a chapter | ✅ Yes | M | Evict controllers/keys for pages more than ~2 viewports away from the current page (keep per-chapter cap); also drop the tautological `getMaxScaleOnAxis() != null` check while in there. |
| B5 | Reader byte-eviction can evict **currently visible** page bytes under memory pressure | ✅ Yes | M | Eviction candidate set excludes URLs in the visible viewport; only evict out-of-view URLs (keeps the 25-entry/byte caps). |
| B6 | **Paged next/prev has no throttle** — rapid taps can double-advance (webtoon path already throttles via `_lastPrevChapterNavAt`) | ✅ Yes | S | Reuse the same window guard for paged `_goToNextPage`/`_goToPrevPage`. |
| B7 | **Single-page chapters** only persist progress on dispose/leave — kill mid-read loses it | ✅ Yes | S | After a chapter loads with exactly 1 page, immediately run the progress/read pipeline (respects delete-finished + scrobble rules). |
| B8 | `VolumeController.getVolume().then(...)` promise is unhandled (no `catchError`) | ✅ Yes | S | Add `catchError` like the scrobble calls. |
| B9 | Dead branch: `_onPageChanged` `index >= _pageUrls.length` (legacy transition-card code) is unreachable | ✅ Yes | S | Remove or repurpose — decide whether "end" signalling for the card is needed; keep behavior explicit. |

## C. Settings & UI

| # | Limitation | Solvable? | Effort | Approach |
|---|---|---|---|---|
| C1 | **`showLanguageBadges` / `selectedLanguages` settings are stored but unused** — no language badges rendered, no Updates filter | ✅ Yes | M | Render a small language badge on library/updates items from extension metadata (source lang); honor `selectedLanguages` when building Updates/Downloads source lists. |
| C2 | **Navigation mix** — most settings screens use `MaterialPageRoute`, the rest go_router; functionally correct but inconsistent | ✅ Yes | M | Unify settings screens onto go_router routes; pure navigation refactor (medium churn, low functional risk — tests + manual smoke). |
| C3 | Settings search surfaces "**Restore Backup File**" → tile only explains server upload | (see A3) | — | Resolved by implementing A3. |

## D. Security / Trust

| # | Limitation | Solvable? | Effort | Approach |
|---|---|---|---|---|
| D1 | **Extensions run untrusted JS (QuickJS)** by design — nothing warns when installing from a non-official repo | ✅ Yes | S | Allowlist the Mangayomi-official repos; show a "third-party extension — trust at your own risk" confirmation at install/update for anything else (UI only; no policy change). |
| D2 | **No extension integrity check** — `index.json` has no hash; a tampered repo could swap JS in transit | ✅ Yes | M | Optional `sha256` field in `index.json`: verify before install; fall back to the D1 warning when absent. Keep backwards-compatible. |

## E. Platform (accepted, out of scope)

| # | Limitation | Solvable? | Effort | Notes |
|---|---|---|---|---|
| E1 | **Web platform unsupported** (`dart:io`, path_provider, QuickJS native) | ❌ No | L | Not viable without a rewrite of the I/O + engine layer; README already flags it. |
| E2 | Extensions trust model is inherent to Mangayomi compatibility | ⚠️ | — | Mitigated by D1/D2; the architecture itself is correct. |

---

## Recommended v2 scope (proposal)

**Phase 1 — "Close the loops" (S items, low risk, high value):**
A2 retry-abandoned-sync · B3 charging gate · B6 paged throttle · B7 single-page progress ·
B8 volume promise · B9 dead branch · D1 third-party install warning

**Phase 2 — "Polish & trust" (M items):**
A1 auth-error UX · B4/B5 webtoon memory + eviction · C1 language badges ·
D2 extension hash verify · C2 navigation unification

**Phase 3 — "Big features" (L items, staged):**
A3 client-side `.tachibk` restore (split: parser → import UI → GraphQL apply) ·
B1 iOS background transfers (native spike; otherwise document badge/notification UX)

**Not solvable / accept:** B2 (Android 6h budget), E1 (web), E2 (JS trust floor).

---

## Implementation status — shipped in v2.0.0

| ID | Status | Notes |
|---|---|---|
| A1 | ✅ Shipped | 401/403 classified via `GraphQLClientService.authErrorNotifier`; one-shot "Reconnect to server" snackbar in the main shell; cleared on success/reconnect. |
| A2 | ✅ Shipped | `SyncEngine.retryFailedSyncRecords()` + `IsarService.getFailedSyncRecords()`; "Retry Failed Sync" tile in Advanced Settings. |
| A3 | ✅ Shipped | Client-side `.tachibk` parser + import planner/service + "Restore from .tachibk File (Device)" screen; url-based `addManga` apply. |
| A4 | ✅ Covered | Token validated via the auth-error path (A1); no repeated-401 loop. |
| B1 | ⚠️ Partial (by design) | Resume-on-foreground kept; "Downloads resumed" notification added; native URLSession/BGTaskScheduler deferred to v2.1 — see `ios-background-downloads.md`. |
| B2 | ❌ Accepted | OS constraint; clean pause + foreground resume (unchanged). |
| B3 | ✅ Shipped | `battery_plus` gate in `_processLocalQueue` + library updates; charger banner in the queue screen. |
| B4 | ✅ Shipped | Webtoon zoom controller/key pruning (keep-window ±40 pages). |
| B5 | ✅ Shipped | Eviction excludes current ±1 visible pages. |
| B6 | ✅ Shipped | Paged next/prev throttle shared with the webtoon window guard. |
| B7 | ✅ Shipped | Single-page chapters persist progress immediately after load. |
| B8 | ✅ Shipped | `catchError` on the iOS volume promise. |
| B9 | ✅ Shipped | Unreachable `_onPageChanged` branch removed. |
| C1 | ✅ Shipped | Language pills on updates + library cards; `selectedLanguages` filter in Updates. |
| C2 | ✅ Shipped | Settings pushes converted to go_router routes. |
| C3 | ✅ Resolved | Resolved by A3. |
| D1 | ✅ Shipped | Official-repo allowlist + third-party install/update confirmation. |
| D2 | ✅ Shipped | Optional `sha256`/`hash`/`sourceCodeHash` in `index.json`; verified before install; D1 warning when absent. |
| E1 | ❌ Out of scope | Web platform unsupported. |
| E2 | ⚠️ Accepted | Mitigated by D1/D2. |

New tests: `test/v2_extension_update_key_test.dart` (extension identity/reconciliation) and
`test/v2_features_test.dart` (tachibk parse/plan, sha256, auth notifier, background-interrupt,
notification copy, language helpers, sync-retry no-op).