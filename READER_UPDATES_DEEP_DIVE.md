# Reader & Updates Deep Dive — Bug Fix Plan
**Based on:** Full audit of `reader_screen.dart`, `updates_screen.dart`, `library_update_service.dart`, `sync_engine.dart`, `websocket_service.dart`

---

## 🔴 CRITICAL (Data Loss / State Corruption)

### 1. SyncEngine `mergeLastPageRead` — Server Unread Rewinds Local Progress
**File:** `lib/src/core/sync/sync_engine.dart:81-100` (line 98)
```dart
if (localWasRead && !serverIsRead) return server;  // WRONG: rewinds to server's page (often 0)
```
**Fix:** Only take server's page if it's > local (server has MORE progress).
```dart
if (localWasRead && !serverIsRead) return local > server ? local : server;
```
**Test:** Read chapter to page 50 → another device marks unread (server page=0) → sync → local stays at 50.

### 2. Updates Screen — Race: Local List Clobbered by Stale Server Data
**File:** `lib/src/features/updates/updates_screen.dart:121-128, 162-180`
```dart
// _loadUpdates: local first, then background server fetch overwrites
_loadUpdatesFromIsarCache();  // shows local
_fetchServerUpdatesInBackground();  // overwrites with server
```
**Root Cause:** `_fetchServerUpdatesInBackground` rebuilds entire `_updatesList` from server response, discarding local-only chapters and any pending read-state changes not yet synced.
**Fix:**
- Keep local list as base, merge server chapters by `serverId`
- Preserve local read-state for chapters with pending mutations
- Only add server chapters not in local list

### 3. Reader `_toggleChapterRead` — No Rollback on Sync Failure
**File:** `lib/src/features/updates/updates_screen.dart:400-431`
```dart
setState(() => ch.applyReadState(newState));  // optimistic UI
await IsarService.instance.saveChapter(ch);
_syncEngine.syncChapterProgress(...);  // if fails, local stays toggled but server doesn't
```
**Fix:** Track pending mutation; on sync failure, rollback local state + show error.

### 4. Reader Self-Healing Scrape — Duplicate Chapter Match Creates Wrong Chapter
**File:** `lib/src/features/reader/reader_screen.dart:1082-1114`
```dart
// _scrapeChapterPagesFallback: searches by mangaTitle, takes FIRST result
final searchRes = await ContentResolverService.instance.resolveSourceManga(
  sourceName: sourceName, searchQuery: mangaTitle);
```
**Root Cause:** Multiple manga can share title (e.g., "One Piece", "Naruto"). Takes first match → wrong chapter list → wrong pages.
**Fix:** Must match by source-specific manga URL or ID, not just title. Pass `manga.url` to resolver.

### 5. Reader Image Cache — Eviction Can Remove On-Screen Images
**File:** `lib/src/features/reader/reader_screen.dart:631-647` (`_schedulePageHeightCache`)
```dart
if (_recoveredImageBytes.length > 40) {
  final oldest = _recoveredImageBytes.keys.first;
  _recoveredImageBytes.remove(oldest);  // NO CHECK if currently displayed
}
```
**Fix:** Never evict URLs in `_pageUrls[currentPage ± 2]` (current + adjacent).

---

## 🟠 HIGH (UX Breakage)

### 6. Updates Bulk Mark-Read — Partial Failure Leaves Inconsistent State
**File:** `lib/src/features/updates/updates_screen.dart:469-553`
```dart
for (final ch in chaptersToUpdate) {
  if (ch.serverId > 0) {
    SyncEngine.instance.syncChapterProgress(ch.serverId, isRead: true, ...);  // fire-and-forget
  }
}
```
**Issues:**
- No error handling — failed syncs silently dropped
- No transaction — some chapters marked, others not
- `_adjustMangaUnreadCount` runs before sync, not after
**Fix:** Batch with `Future.wait`, rollback on any failure, adjust unread count after successful sync.

### 7. WebSocket — Duplicate Subscriptions on Reconnect
**File:** `lib/src/core/sync/websocket_service.dart:194-213, 215-235`
```dart
void _subscribeEvents() {
  _channel?.sink.add(jsonEncode({... id: '1' ...}));  // libraryUpdateStatusChanged
  _channel?.sink.add(jsonEncode({... id: '2' ...}));  // downloadStatusChanged
}
void _handleDisconnect(...) {
  _reconnectTimer = Timer(... connect());
}
```
**Root Cause:** On reconnect, sends new subscriptions with same IDs. Old subscriptions may persist on server → duplicate events.
**Fix:** Send `unsubscribe` for IDs '1' and '2' before reconnect, or use new IDs per connection.

### 8. WebSocket — Auth Token Expires, Reconnect Loops Forever
**File:** `lib/src/core/sync/websocket_service.dart:39-78, 97-101`
```dart
void initialize(String httpUrl, {String? authToken}) {
  _authToken = authToken;
  connect();  // uses _authToken
}
```
**Root Cause:** JWT expires (typically 15min-1h). Reconnect uses stale token → auth fails → disconnect → reconnect loop.
**Fix:** Add `authRefresher` callback to `initialize()`; call before reconnect; on auth error, trigger re-login flow.

### 9. Auto-Scroll Resume Flag — Chapter-Agnostic, Resumes Wrong Chapter
**File:** `lib/src/features/reader/reader_screen.dart:1212-1217`
```dart
_resumeAutoScrollAfterLoad = true;  // global flag
```
**Root Cause:** If user reads Chapter A with auto-scroll, navigates to Chapter B (no auto-scroll), then back to A — `_resumeAutoScrollAfterLoad` is still true from previous session, resumes auto-scroll on B incorrectly.
**Fix:** Track per-chapter: `Map<int, bool> _resumeAutoScrollForChapter`.

### 10. Volume Key Recentering Race
**File:** `lib/src/features/reader/reader_screen.dart:177-187, 153-168`
```dart
// Volume listener sets recentrePending, _recenterGuardTimer cancels it
// But app lifecycle also triggers recentre on resume
```
**Root Cause:** Volume key press sets `_recentrePending = true`; `_recenterGuardTimer` (280ms) cancels it. But if app goes to background and resumes during that window, `didChangeAppLifecycleState` → `_recenterPending = true` → recenters after resume even if user didn't press volume.
**Fix:** Use generation token for recentre, or track source of recentre request.

### 11. Prefetch Consumed Before Generation Guard
**File:** `lib/src/features/reader/reader_screen.dart:1254, 1307-1319`
```dart
unawaited(_prefetchChapter(_nextChapter));  // line 1254
// ...
void _prefetchChapter(Chapter chapter) async {
  final sid = _chapterTargetId(chapter);  // computed at call time
  _prefetchedChapters[sid] = ...;  // stored
}
```
**Root Cause:** Prefetch fires, but `_loadGeneration` may increment before prefetch completes. If generation changes, `_loadChapterAndPagesInner` discards prefetched data, but cache still polluted.
**Fix:** Store `generation` with prefetch; on read, check `prefetch.generation == _loadGeneration`.

### 12. ContentResolver — No Per-Resolver Timeout
**File:** `lib/src/core/services/content_resolver_service.dart:193-235`
```dart
final localResult = await fetchChapterPagesLocal(...).timeout(const Duration(seconds: 30));
// Then server fallback with no timeout on the overall chain
```
**Root Cause:** Local scrape can hang 30s, then server fallback starts → total 60s+ for failed chapter. User sees blank screen.
**Fix:** Overall timeout (e.g., 15s) with `Future.any([local, server])` race.

### 13. SyncEngine — Full Chapter Snapshot Every Sync (No Incremental)
**File:** `lib/src/core/sync/sync_engine.dart:1030-1177`
```dart
Future<void> _syncAllChaptersForLibrary() async {
  for (final manga in library) {
    final data = await GraphQLClientService.instance.fetchMangaDetails(manga.serverId);
    // saves ALL chapters every sync
  }
}
```
**Root Cause:** No `since` timestamp / incremental sync. For 500 manga × 100 chapters = 50k chapters every sync.
**Fix:** Add `lastChapterSyncTimestamp` per manga; fetch only chapters with `fetchedAt > lastSync`.

### 14. SyncEngine — Chapter Sync Has No Wipe Guard
**File:** `lib/src/core/sync/sync_engine.dart:1030-1177`
```dart
// Manga sync has wipe guard (lines 963-998); chapter sync does NOT
```
**Root Cause:** Server returns empty/corrupted chapter list → local chapters (including locally-scraped) overwritten.
**Fix:** Apply same wipe-guard logic: if server returns 0 chapters for a manga that has local chapters, skip update.

### 15. SettingsService — No Change Notifications
**File:** `lib/src/core/services/settings_service.dart`
**Root Cause:** `SettingsService` is singleton with getters/setters but no `ChangeNotifier`. Reader/Updates don't react to settings changes in real-time.
**Fix:** Extend `ChangeNotifier`; notify on every setter. Add `ListenableBuilder` in Reader/Updates.

### 16. Error Swallowing — Silent Failures Everywhere
**Files:** Multiple
```dart
catch (ignoredError) { if (kDebugMode) debugPrint(...); }  // updates_screen:141
catch (e) { debugPrint(...); }  // library_update_service:266
catch (_) {}  // reader_screen:2282
```
**Fix:** Use `LoggerService` consistently; show user-facing SnackBar for actionable errors; add retry UI.

### 17. Incognito Mode — Incomplete
**File:** `lib/src/features/reader/reader_screen.dart:1446`
```dart
if (_settings.incognitoMode) return;  // only in _updateProgress
```
**Missing:** Download-ahead, prefetch, WebSocket events, history/scrobble, image cache.

---

## 🟡 MEDIUM (Correctness/Polish)

### 18. Updates Flood Detection Inconsistent
**File:** `lib/src/features/updates/updates_screen.dart:181-204, 303-319`
```dart
// Server fetch: per-manga max 3 if >4 chapters
// Local cache: no flood detection applied
```
**Fix:** Apply same flood detection to local cache load.

### 19. Pull-to-Refresh — Too Heavy
**File:** `lib/src/features/updates/updates_screen.dart:191-198`
```dart
Future<void> _handleRefresh() async {
  await _fetchServerUpdatesInBackground();  // full server fetch + rebuild
  await _loadUpdatesFromIsarCache();  // then reload from cache
}
```
**Fix:** Background refresh only; pull-to-refresh just reloads local cache.

### 20. Tab Reload — Wasteful
**File:** `lib/src/features/updates/updates_screen.dart:63-66`
```dart
void _onTabChanged() {
  if (MainShell.selectedTabNotifier.value == 1 && mounted) {
    _loadUpdatesFromIsarCache();  // reloads every tab visit
  }
}
```
**Fix:** Only reload if data stale (>5min) or manual pull.

### 21. Language Filter — Hides Unknown Lang
**File:** `lib/src/features/updates/updates_screen.dart:75-81`
```dart
final lang = (it['lang'] as String? ?? '').trim().toLowerCase();
return SettingsService.languageMatchesFilter(lang, selectedLangs);
```
**Root Cause:** Chapters with empty lang filtered out when specific languages selected.
**Fix:** Treat empty lang as "unknown" — include unless explicitly filtered.

### 22. Search — No Debounce
**File:** `lib/src/features/updates/updates_screen.dart:1036-1050`
```dart
onChanged: (v) => setState(() => _searchQuery = v);  // rebuilds on every keystroke
```
**Fix:** Debounce 300ms.

### 23. Clear Feed UX — No Feedback
**File:** `lib/src/features/updates/updates_screen.dart:1150-1170`
```dart
void _clearFeed() async {
  // deletes all chapters from Isar
  // no progress, no undo, no confirmation of count
}
```
**Fix:** Show count, add undo SnackBar, run in background.

### 24. Download-Ahead — Uses Stale Sibling Data
**File:** `lib/src/features/reader/reader_screen.dart:1282-1302`
```dart
void _triggerDownloadAhead() {
  for (final ch in _siblingChapters) {  // from current load
    if (ch.serverId > 0 && !DownloadManagerService.instance.isChapterDownloadedLocally(...)) {
      DownloadManagerService.instance.enqueueLocalDownload(...);
    }
  }
}
```
**Root Cause:** `_siblingChapters` may be stale if `_loadGeneration` changed. Downloads wrong chapters.
**Fix:** Check `_loadGeneration` before enqueueing; only download if generation matches.

### 25. Prefetch Cache — Unbounded Growth
**File:** `lib/src/features/reader/reader_screen.dart:1307-1319`
```dart
_prefetchedChapters[sid] = ...;  // no size limit, no eviction on chapter change
```
**Fix:** Max 3 chapters in prefetch cache; clear on chapter load.

### 26. Curl Concurrency — Unlimited
**File:** `lib/src/features/reader/reader_screen.dart:2201`
```dart
for (final exe in kCurlCandidates) {  // tries multiple curl binaries sequentially per image
```
**Root Cause:** Many failed images × multiple curl candidates = unbounded process spawns.
**Fix:** Semaphore (max 2 concurrent curl processes).

### 27. SyncEngine `syncChapterProgress` — `lastReadAt` Not Updated on Direct Success
**File:** `lib/src/core/sync/sync_engine.dart:190-216`
```dart
if (res != null) {
  await _dropQueuedProgressRecords(chapterServerId);
  return;  // local Isar chapter.lastReadAt NOT updated
}
```
**Fix:** Update local chapter's `lastReadAt` on direct HTTP success.

### 28. LibraryUpdateService — Race: UI Reads Before Sync Completes
**File:** `lib/src/core/services/library_update_service.dart:137-185`
```dart
await SyncEngine.instance.triggerSync();  // fire-and-forget
return newFound;  // UI reads cache BEFORE sync writes new chapters
```
**Fix:** `triggerSync` should return `Future`; await it before returning count.

### 29. LibraryUpdateService — Local Scrape Duplicates Server Work
**File:** `lib/src/core/services/library_update_service.dart:188-270`
```dart
// Even when server sync ran, still scrapes locally for manga with local extensions
```
**Fix:** Skip local scrape for manga that server already synced (track synced manga IDs).

### 30. ImageStreamListener — No Timeout
**File:** `lib/src/features/reader/reader_screen.dart:631-647`
```dart
stream.addListener(ImageStreamListener(
  (info, _) { ... removeListener ... },
  (exception, _) { ... removeListener ... },
));  // NO TIMEOUT — if image never resolves, listener leaks
```
**Fix:** Wrap in `Future.any([listenerFuture, timeout])`.

---

## 🟢 LOW (Nice to Have)

### 31. Scroll Indicator Timer — Churn
**File:** `lib/src/features/reader/reader_screen.dart:1360-1368`
```dart
_scrollIndicatorTimer?.cancel();
_scrollIndicatorTimer = Timer(...);  // every scroll event
```
**Fix:** Debounce or single timer with `reset()`.

### 32. Prefetch Desktop-Only
**File:** `lib/src/features/reader/reader_screen.dart:2294-2303`
```dart
if (!kIsWeb && (Platform.isLinux || Platform.isMacOS || Platform.isWindows)) {
  _prefetchUpcomingPages(...);  // mobile gets no prefetch
}
```
**Fix:** Enable on mobile with lighter prefetch (2 pages instead of 4).

### 33. Double-Tap Zoom — Global Variable
**File:** `lib/src/features/reader/reader_screen.dart:185-195`
```dart
static bool _lastDoubleTapWasZoom = false;  // global, not per-reader-instance
```
**Fix:** Instance variable.

### 34. Lifecycle — Missing `detached`
**File:** `lib/src/features/reader/reader_screen.dart:147-171`
```dart
if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) { ... }
else if (state == AppLifecycleState.resumed) { ... }
// missing: detached (iOS termination, Android process death)
```
**Fix:** Handle `detached` → cleanup wakelock, volume, auto-scroll.

### 35. Transient Error — String Matching
**File:** `lib/src/core/sync/sync_engine.dart:36-48`
```dart
return s.contains('connection refused') ...  // misclassifies "connection refused: bad auth"
```
**Fix:** Use structured error types from GraphQL client.

---

## 📋 Implementation Priority Order

### Sprint 1 (Immediate — Data Loss Prevention)
| # | Fix | Files |
|---|-----|-------|
| 1 | `mergeLastPageRead` fix | `sync_engine.dart` |
| 2 | Updates race: merge don't clobber | `updates_screen.dart` |
| 3 | `_toggleChapterRead` rollback | `updates_screen.dart` |
| 4 | Self-healing scrape URL match | `reader_screen.dart`, `content_resolver_service.dart` |
| 5 | Image cache eviction guard | `reader_screen.dart` |

### Sprint 2 (High — UX Breakage)
| # | Fix | Files |
|---|-----|-------|
| 6 | Bulk mark-read atomic + error handling | `updates_screen.dart` |
| 7 | WS unsubscribe on reconnect | `websocket_service.dart` |
| 8 | WS auth refresh callback | `websocket_service.dart`, `sync_engine.dart` |
| 9 | Auto-scroll per-chapter flag | `reader_screen.dart` |
| 10 | Volume key recentre generation | `reader_screen.dart` |
| 11 | Prefetch generation guard | `reader_screen.dart` |
| 12 | ContentResolver overall timeout | `content_resolver_service.dart` |
| 13 | SettingsService ChangeNotifier | `settings_service.dart`, `reader_screen.dart`, `updates_screen.dart` |
| 14 | Error handling standardization | Multiple |

### Sprint 3 (Medium — Correctness)
| # | Fix | Files |
|---|-----|-------|
| 15 | Incremental chapter sync | `sync_engine.dart` |
| 16 | Chapter wipe guard | `sync_engine.dart` |
| 16 | Flood detection consistency | `updates_screen.dart` |
| 18 | Pull-to-refresh light | `updates_screen.dart` |
| 20 | Tab reload debounce | `updates_screen.dart` |
| 21 | Language filter empty lang | `updates_screen.dart` |
| 22 | Search debounce | `updates_screen.dart` |
| 23 | Clear feed UX | `updates_screen.dart` |
| 24 | Download-ahead generation guard | `reader_screen.dart` |
| 25 | Prefetch cache size limit | `reader_screen.dart` |
| 26 | Curl semaphore | `reader_screen.dart`, `safe_curl.dart` |
| 27 | `lastReadAt` on direct sync | `sync_engine.dart` |
| 28 | LibraryUpdateService await sync | `library_update_service.dart` |
| 29 | Skip local scrape after server | `library_update_service.dart` |
| 30 | ImageStreamListener timeout | `reader_screen.dart` |

### Sprint 4 (Low — Polish)
| # | Fix | Files |
|---|-----|-------|
| 31 | Scroll indicator timer debounce | `reader_screen.dart` |
| 32 | Mobile prefetch | `reader_screen.dart` |
| 33 | Double-tap zoom instance var | `reader_screen.dart` |
| 34 | Lifecycle detached | `reader_screen.dart` |
| 35 | Transient error types | `sync_engine.dart` |

---

## 🧪 Test Requirements (Add to Plan)

### Integration Tests Needed
```dart
// test/reader_updates_integration_test.dart
group('Reader + Updates Integration', () {
  test('Read progress not rewound when server marks unread');
  test('Updates local list preserved when server fetch returns');
  test('Mark-read rollback on sync failure');
  test('Self-healing scrape uses manga URL not title');
  test('Image cache never evicts current page');
  test('Bulk mark-read atomic or full rollback');
  test('WS reconnect uses fresh auth token');
  test('Auto-scroll flag per-chapter');
  test('Volume key recentre not triggered by lifecycle');
  test('Prefetch respects generation');
  test('ContentResolver races local vs server');
  test('Incremental chapter sync works');
  test('Chapter wipe guard prevents overwrite');
  test('Settings changes propagate without navigation');
  test('Bulk mark-read rollback on partial failure');
  test('Auto-scroll resume per-chapter');
  test('Volume key recentre not from lifecycle');
  test('Prefetch generation guard works');
  test('ContentResolver 15s overall timeout');
  test('Incremental chapter sync only fetches new');
  test('Chapter wipe guard skips empty server response');
  test('Settings changes propagate to Reader/Updates');
  test('Errors show user-facing SnackBar');
  test('Incognito blocks all tracking');
  test('Flood detection applied to local cache');
  test('Pull-to-refresh only reloads local');
  test('Tab reload only if stale');
  test('Language filter includes unknown');
  test('Search debounced 300ms');
  test('Clear feed shows count + undo');
  test('Download-ahead respects generation');
  test('Prefetch cache limited to 3');
  test('Curl limited to 2 concurrent');
  test('lastReadAt updated on direct sync');
  test('LibraryUpdateService awaits sync completion');
  test('Local scrape skipped for server-synced manga');
  test('ImageStreamListener has 10s timeout');
});
```

---

## 📝 Files to Modify (Priority Order)

| File | Changes |
|------|---------|
| `lib/src/core/sync/sync_engine.dart` | mergeLastPageRead, incremental sync, wipe guard, lastReadAt on direct success, transient error types |
| `lib/src/features/updates/updates_screen.dart` | Race fix merge, bulk mark-read atomic, rollback, flood detection, pull-to-refresh, tab reload, language filter, search debounce, clear feed UX, error handling |
| `lib/src/features/reader/reader_screen.dart` | Auto-scroll per-chapter, volume key recentre, prefetch generation guard, download-ahead gen guard, image cache eviction, self-healing URL match, prefetch cache limit, curl semaphore, incognito coverage, ImageStreamListener timeout, scroll indicator timer, lifecycle detached |
| `lib/src/core/services/content_resolver_service.dart` | Overall timeout race |
| `lib/src/core/sync/websocket_service.dart` | Unsubscribe on reconnect, auth refresher callback |
| `lib/src/core/sync/sync_engine.dart` | Incremental sync, wipe guard, lastReadAt on direct success, transient error types |
| `lib/src/core/services/library_update_service.dart` | Await sync, skip local scrape after server, race fix |
| `lib/src/core/services/settings_service.dart` | Extend ChangeNotifier |
| `lib/src/core/services/safe_curl.dart` | Semaphore for concurrent curl |
| `lib/src/features/reader/reader_chapter_navigation.dart` | (if needed) |

---

## ✅ Verification Criteria

| Fix | Verification |
|-----|--------------|
| mergeLastPageRead | Unit test: local=50, server=0, localWasRead=true, serverIsRead=false → returns 50 |
| Updates race | Integration test: local has 5 chapters, server returns 3 → merged list has 5 |
| Mark-read rollback | Integration test: toggle read → sync fails → local state reverted, SnackBar shown |
| Self-healing scrape | Integration test: two manga same title, different URLs → correct chapter list loaded |
| Image cache | Unit test: 45 images cached, current page + 2 neighbors retained, oldest evicted |
| Bulk mark-read | Integration test: 10 chapters, 3 fail sync → all rolled back, unread count correct |
| WS auth refresh | Integration test: token expires → reconnect calls refresher → new token used |
| Auto-scroll per-chapter | Integration test: A(auto)→B(manual)→A → A resumes, B doesn't |
| Prefetch generation | Unit test: prefetch for gen 5, gen increments to 6 → prefetch ignored |
| ContentResolver timeout | Integration test: local hangs 10s, server responds 2s → server wins |
| Incremental sync | Integration test: 100 chapters, 5 new since last sync → only 5 fetched |
| Settings notifier | Integration test: change reading mode in settings → Reader updates without navigation |
| Error handling | Integration test: sync fails → SnackBar with retry action shown |

---

## 📦 Updated UI Improvement Plan Integration

Add these as **Phase -1 (Pre-Foundation)** to the UI Improvement Plan — fix critical bugs before polishing UI.