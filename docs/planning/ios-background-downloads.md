# iOS / macOS Background Downloads — Limitation & v2 Behavior

Status: **accepted limitation for v2.0.0**; native spike deferred to v2.1.

## The constraint
Sunfire's download queue runs in the Dart isolate. When the app is suspended by
iOS/macOS, that isolate stops receiving CPU time, so in-flight HTTP transfers are
suspended with it. Granting `UIBackgroundModes` alone does **not** fix this:
- `fetch` / `beginBackgroundTask` only buys a short grace period (seconds to a
  couple of minutes) and cannot carry a multi-chapter queue.
- A real fix requires transferring the queue to a native **`URLSession`
  background configuration** (`URLSessionConfiguration.background`) or a
  **`BGTaskScheduler`** job — i.e., a platform-channel / plugin change that
  performs the network I/O outside the suspended Dart isolate.

Android already uses a `dataSync` foreground service (`flutter_foreground_task`)
for this, so Android is unaffected.

## What v2.0.0 does instead
1. **Pause on suspend, resume on foreground** (paperback/Tachiyomi-compatible
   behavior). `DownloadManagerService.resumeLocalQueueAfterForeground()` restarts
   an unpaused queue and never overrides an explicit user pause.
2. **Never silent.** `noteAppBackgrounded()` marks the queue as interrupted when
   the app backgrounds while downloads are active; on `AppLifecycleState.resumed`
   the shell consumes the marker and posts a **"Downloads resumed"** notification
   (`NotificationService.showDownloadsResumedNotification`) reporting how many
   transfers were paused and are running again. Gated by
   `downloadNotificationsEnabled`.
3. **Schedulers**: `LibraryUpdateService` and the sync engine are gated on
   foreground/connectivity, so a suspended app does not log spurious failures;
   they re-run on resume.

Relevant symbols:
- `DownloadManagerService.backgroundInterruptsDownloads({isProcessing, hasActiveDownloads})`
  (pure predicate) · `noteAppBackgrounded()` · `consumeBackgroundInterrupted()`.
- `NotificationService.downloadsResumedSummary({queuedCount})` (pure copy) ·
  `showDownloadsResumedNotification(...)`.
- `main_shell.dart` → `didChangeAppLifecycleState`.

## v2.1 spike (not scheduled)
- iOS: a `URLSession` background-session channel that hands off each chapter
  download, plus a `BGProcessingTask` to kick the queue; persist completion back
  into Isar/SharedPreferences.
- macOS: `NSURLSession` background configuration + `NSBackgroundActivityScheduler`.
- Acceptance: a multi-chapter queue continues while the app is suspended and the
  UI reflects progress on return.
