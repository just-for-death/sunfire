# Sync Engine Audit Findings

## 1. `_progressLocks` chain — `guarded` future may never complete if `_syncChapterProgressInner` throws synchronously

**File:** `lib/src/core/sync/sync_engine.dart`  
**Lines:** 960–977  

**Issue:**  
`syncChapterProgress` chains `prior.then(_syncChapterProgressInner)`, wraps it in `guarded = current.then(_, onError: (_) {})`, stores `guarded` in `_progressLocks`, then `await current` in a `try`/`finally` that removes the entry. If `_syncChapterProgressInner` throws **synchronously** (before returning a Future), `current` completes with an error **synchronously**. The `guarded` future catches it and completes normally, but the `await current` in the `try` block also throws — the `catch` is empty (only `onError` on `guarded`), so the exception propagates out of `syncChapterProgress`. The `finally` block runs and removes the entry **only if** `identical(_progressLocks[chapterServerId], guarded)`. However, a synchronous throw means `current` never yielded; the caller's `await` sees the error, but `guarded` is already stored. The next caller for the same chapter gets `prior = guarded` (a completed future), chains onto it, and proceeds — **but the failed work was never retried**, and the chapter's progress is lost.

**Impact:** Silent loss of chapter progress updates when a synchronous exception occurs (e.g., JSON encoding error, Isar closed, incognito check race).

**Fix:** Move the `try`/`catch` inside the chain, or use `Future.sync(() => _syncChapterProgressInner(...))` to force async boundary, or store `current` (not `guarded`) and handle removal in a `.whenComplete` on `current`.

---

## 2. `lastRequestWasTransportFailure` — read/write race between `_queryOnce` and `_flushPendingMutations`

**File:** `lib/src/core/sync/graphql_client_service.dart` (lines 590–594, 1777–1782 in sync_engine.dart)  

**Issue:**  
`_queryOnce` sets `lastRequestWasTransportFailure = true` in the `DioException` catch block (line 593), then returns. `_flushPendingMutations` reads it at line 1782 **after** `await GraphQLClientService.instance.updateChapterReadStatus(...)` returns. However, `updateChapterReadStatus` calls `query()`, which calls `_queryOnce`. If **another concurrent request** (e.g., WS pull, category fetch, image preload) completes between the dispatch's `_queryOnce` returning and the dispatch reading the flag, that other request's `_queryOnce` will overwrite `lastRequestWasTransportFailure`. The dispatch then classifies its own failure based on **someone else's** outcome.

**Impact:** A transport failure (timeout, 5xx) misclassified as non-transient → burns retry budget, abandons record prematurely. Or a GraphQL error misclassified as transient → infinite retries of a rejected mutation.

**Fix:** Thread the classification through the return value. `_queryOnce` already returns `retryable: isRetryableTransportFailure(e)`. Have mutation helpers (`updateChapterReadStatus`, etc.) return that boolean, or capture `lastRequestWasTransportFailure` **immediately** after the `await` in a local variable before any `await` point.

---

## 3. `_dispatchAttempts` persistence — bare `setString` races, no `_pendingSave` chain

**File:** `lib/src/core/sync/sync_engine.dart`  
**Lines:** 1839–1849, 760, 786, 1802, 1890, 1903  

**Issue:**  
`_persistDispatchAttempts` is called from 6 paths (lines 760, 786, 1802, 1890, 1903, plus implicit via `retryFailedSyncRecords` and `quarantinePendingForServerSwitch`), all using `unawaited(_persistDispatchAttempts())`. Each call does `prefs.setString(...)` directly with **no serialization/coalescing**. Under concurrent flushes (e.g., manual retry + background sync + WS-triggered sync), multiple `setString` calls race. SharedPreferences on Android uses `apply()` (async, non-atomic), so the last writer wins — earlier attempt counts are lost. A record that failed 39 times transiently gets its attempt count reset to 0 on restart if the persistence race dropped the update.

**Impact:** Poison records (permanent 5xx) regain full 40-attempt budget on restart, hammering the server for 14 days per restart.

**Fix:** Introduce a `_pendingSave` completer chain (like `_progressLocks`): `Future<void> _saveChain = Future.value(); _saveChain = _saveChain.then((_) => _doPersist());` — or debounce with a short timer and a dirty flag.

---

## 4. `quarantinePendingForServerSwitch` — does not clear `_wsUpdatePullTimer` or `_progressLocks`

**File:** `lib/src/core/sync/sync_engine.dart`  
**Lines:** 776–795  

**Issue:**  
When the server URL changes, `quarantinePendingForServerSwitch` deletes pending/failed SyncRecords and clears `_dispatchAttempts` entries, but **does not**:
- Cancel `_wsUpdatePullTimer` (line 672) — a pending 800ms timer will fire `triggerSync()` against the **new** server with stale local state.
- Clear `_progressLocks` (line 942) — in-flight chapter progress chains for the old server remain, and their `guarded` futures will eventually complete and try to sync against the new server.
- Clear `_lastDirectPage` (line 947) — stale "last successfully dispatched page" map may cause incorrect coalescing on the new server.
- Reset `_cycleGate` / `_isSyncing` — a sync cycle already in flight continues against the old server config.

**Impact:** Cross-server contamination: progress updates, category assigns, and library state changes queued for Server A get replayed against Server B, corrupting both libraries silently.

**Fix:** In `quarantinePendingForServerSwitch`, also: `_wsUpdatePullTimer?.cancel(); _wsUpdatePullTimer = null; _progressLocks.clear(); _lastDirectPage.clear(); _cycleGate.end();` (or reset the gate).

---

## 5. Category assign coalescing — `_isAssignPayload` swallows malformed JSON; delete+save not atomic

**File:** `lib/src/core/sync/sync_engine.dart`  
**Lines:** 1368–1379, 1382–1391  

**Issue A (suboptimal but safe):** `_isAssignPayload` returns `false` on any JSON parse error. A malformed pending assign payload (corrupted DB row) escapes coalescing → multiple assigns pile up → each replays `setMangaCategories` on flush. Safe but wastes bandwidth.

**Issue B (race):** Lines 1369–1377 iterate pending records and **delete** matching assigns, then line 1379 saves the new record. This is **not atomic**. Two concurrent `syncMangaCategories` calls for the same manga (e.g., user rapidly toggles categories in UI) both load pending list, both delete each other's records, both save — **one assign is lost**. The last writer wins, but the intermediate state (first caller's delete + second caller's save) means the first caller's intended category set never reaches the server.

**Impact:** Category assignment lost under concurrent UI interaction; server state diverges from user intent.

**Fix:** Coalesce at the **database level** — use a single transaction that upserts by `(entityType, entityId, action, op='assign')`, or acquire a per-manga lock (like `_progressLocks`) around the delete+save.

---

## 6. OfflineMonitor integration — `reportTransportSuccess` resets failures immediately, but sync dispatch uses 15s window

**File:** `lib/src/core/sync/offline_monitor.dart` (lines 44–58), `graphql_client_service.dart` (lines 263, 538–543)  

**Issue:**  
`OfflineMonitor.reportTransportSuccess()` resets `_consecutiveFailures = 0` and `_offline = false` **immediately** (line 48–56). However, `GraphQLClientService._queryOnce` fast-fail (line 538–543) checks `_lastReachableStatus` and a **15-second window** (`_lastReachableCheck`). A single successful probe (e.g., `checkServerReachable` ping) calls `reportTransportSuccess()` → `OfflineMonitor.isOnline == true`, but `_queryOnce` still fast-fails for 15s because `_lastReachableStatus` is still `false` until the next probe succeeds. Conversely, 3 transport failures flip `OfflineMonitor.isOffline = true`, but `_queryOnce` fast-fail only activates after `_lastReachableCheck` is set (which happens on failure). The two systems have **different debounce windows and triggers** — UI may show "online" while sync silently drops requests, or vice versa.

**Impact:** Inconsistent offline/online state between UI (OfflineMonitor) and sync engine (GraphQLClientService), leading to user confusion and missed sync opportunities.

**Fix:** Unify the source of truth. Either make `OfflineMonitor` the sole authority (have `_queryOnce` consult `OfflineMonitor.instance.isOnline`), or make `GraphQLClientService` drive `OfflineMonitor` with the same 15s window semantics.

---

## 7. `retryFailedSyncRecords` — clears `_dispatchAttempts` but does not reload after persist

**File:** `lib/src/core/sync/sync_engine.dart`  
**Lines:** 747–768  

**Issue:**  
`retryFailedSyncRecords` iterates failed records, sets `retryCount = 0`, `state = pending`, removes `_dispatchAttempts[record.id]`, saves each record, then calls `unawaited(_persistDispatchAttempts())` and `unawaited(triggerSync())`. It **does not** call `_loadDispatchAttempts()` after persisting. The in-memory `_dispatchAttempts` map now lacks entries for the reset records (correct), but if the process restarts before the unawaited persist completes, `_loadDispatchAttempts` (called in `initialize`) will read the **old** persisted map (which still has the high attempt counts) because the `setString` from `_persistDispatchAttempts` hasn't landed yet. On restart, the poison records regain their attempt budget.

**Impact:** Manual "Retry failed sync" appears to work, but after app restart the records are still treated as poisoned (high attempt count) and may be abandoned immediately.

**Fix:** After the loop, `await _persistDispatchAttempts()` (not unawaited), then `await _loadDispatchAttempts()` to sync in-memory map with persisted state, then `triggerSync()`.

---

## 8. `triggerSync` while `_isSyncing` — guard exists but `_cycleGate.tryBegin` queues only one follow-up

**File:** `lib/src/core/sync/sync_engine.dart`  
**Lines:** 415–441, 818–837  

**Issue:**  
`SyncCycleGate.tryBegin` allows **one** queued follow-up (`queued = true`). If `triggerSync` is called **three times** while a cycle is running (e.g., pull-to-refresh + WS update + chapter read), only **one** additional cycle runs. The third call awaits the in-flight completer (`_cycleCompleter`) and returns **without scheduling another pass**. The `queued` flag is cleared at `beginPass()` (line 432), so a rapid burst of 3+ calls coalesces to 2 cycles max.

**Impact:** Under high contention (user pulls to refresh while WS fires and reader sends progress), sync cycles are dropped. Local mutations may not be flushed until the next periodic sync.

**Fix:** Change `queued` from `bool` to `int` counter, or use a `Completer` chain where each caller gets its own completer that chains to the next. Or accept that a one-deep queue is intentional (documented at line 413) and verify callers don't rely on "every call triggers a cycle".

---

## Summary Table

| # | Component | Severity | Type |
|---|-----------|----------|------|
| 1 | `_progressLocks` chain | High | Data loss / silent failure |
| 2 | `lastRequestWasTransportFailure` race | High | Misclassification → retry budget corruption |
| 3 | `_dispatchAttempts` persistence race | High | Poison records regain budget on restart |
| 4 | `quarantinePendingForServerSwitch` incomplete cleanup | High | Cross-server data corruption |
| 5 | Category assign coalescing race | Medium | Lost category assignments |
| 6 | OfflineMonitor / GraphQLClientService desync | Medium | Inconsistent offline state |
| 7 | `retryFailedSyncRecords` missing reload | Medium | Retry appears to work but fails on restart |
| 8 | `triggerSync` one-deep queue drop | Low | Dropped sync cycles under burst |