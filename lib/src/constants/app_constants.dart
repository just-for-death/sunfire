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