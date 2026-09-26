/// Shared constants for Sunfire.
library;

/// Desktop Chrome user agent used for scraping and image fetches so websites
/// serve full desktop (non-mobile) pages to the quickjs engine and downloaders.
const String kBrowserUserAgent =
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36';

/// Default mobile Chrome user agent used by the JS engine's HTTP client when
/// no explicit desktop UA is supplied.
const String kMobileUserAgent =
    'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.6832.64 Mobile Safari/537.36';

/// Wall-clock ceiling for a single QuickJS execution, in milliseconds.
///
/// Extensions are remote, downloaded code running unsandboxed on the UI
/// isolate, so this is a liveness guarantee rather than a tuning knob: it is
/// what installs QuickJS's interrupt handler. Without it a `while(true){}` in
/// any scraper blocks the FFI call permanently, and because every Dart-side
/// timeout in the pipeline is scheduled on that same isolate, none of them can
/// fire — the app wedges and only a force-kill recovers it.
///
/// 15s is comfortably above any real scrape step (a page fetch plus DOM parse)
/// while still bounding a runaway loop to something the user can wait out.
const int kJsExecutionTimeoutMs = 15000;

/// Heap ceiling for the QuickJS runtime, in bytes (64 MiB).
///
/// Also a liveness guarantee. An extension that grows an array without bound
/// otherwise takes the process down with an OS low-memory kill, which the user
/// experiences as a random crash rather than as a broken source.
const int kJsMemoryLimitBytes = 64 * 1024 * 1024;

/// Largest extension source or repo index Sunfire will download, in bytes.
///
/// A hostile or compromised repo can name an arbitrarily large "extension".
/// Without a cap the body is buffered whole into a Dart string and then
/// compiled, so a single index entry is enough to OOM the app. 2 MiB is far
/// above any real scraper.
const int kMaxExtensionDownloadBytes = 2 * 1024 * 1024;

/// Largest chapter payload accepted from a scraper before it is rejected.
///
/// The result is serialised to JSON inside the runtime and then decoded into
/// unbounded Dart collections. A scraper returning millions of page entries
/// OOMs the process before the UI ever shows a spinner.
const int kMaxScraperPageEntries = 2000;