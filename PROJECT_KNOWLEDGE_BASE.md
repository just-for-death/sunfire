# Sunfire & Mangayomi Extensions — Comprehensive Architecture & Knowledge Base

## 1. Project Overview & Ecosystem
* **Sunfire** (`just-for-death/sunfire`): Flutter-based manga reader and synchronization client for Suwayomi / Tachidesk servers with local QuickJS scraping support, offline library replication, and image cache resilience.
* **Mangayomi Extensions** (`just-for-death/mangayomi-extensions`): JavaScript-based source extensions defining web scraper logic for online manga catalogs, search, chapter metadata, and page image extraction.

---

## 2. Core Architecture & Workflows

### A. Dual-Mode Content Resolution (`ContentResolverService`)
1. **Server Mode**: When connected to Suwayomi GraphQL backend (`/api/graphql`), fetches catalog, chapters, library, reading history, and updates directly from the server.
2. **Local QuickJS Extension Mode**: When server is offline or for local browsing, executes source scrapers locally via QuickJS runtime.
3. **Continuous Source Migration (`SourceMigrationService`)**:
   - Automatically maps server-installed source names to local JS extensions.
   - Re-maps library items so chapters can be scraped on-device when server is offline.

### B. Networking & Cloudflare Bypass (`MClient`)
* **Cronet on Android, Cupertino on iOS/macOS, Standard Client on Linux/Desktop**.
* **FlareSolverr Integration**:
  - Automatically intercepts Cloudflare 403 / challenge pages.
  - Normalizes proxy endpoints to `/v1`.
  - Reuses named sessions (`sunfire_<domain>`) across requests to avoid re-solving challenges repeatedly.
  - Stores cookies globally and attaches them to subsequent requests.
  - In-flight request deduplication prevents concurrent spam to the challenge proxy.

### C. JavaScript Scraper Engine (`QuickJsService` & `JsExtensionService`)
* **Bundled Libraries**: Extensions bundle self-contained libraries (e.g. `CryptoJS` for AES decryption).
* **DOM Selector Support**: Custom `Document` and `Element` wrappers executing fast cheerio/jsoup-like queries.
* **Metadata Extraction**: Resilient regex handles unquoted, double-quoted, and single-quoted `mangayomiSources` metadata.
* **Header Cache**: Source headers (`User-Agent`, `Referer`) are captured per source/URL and cached for image fetchers.

### D. Image Cache & Magic Byte Validation (`ImageCacheHelper`)
* **Strict Validation (`_isValidImageBytes`)**:
  - Checks magic bytes: JPEG (`FF D8`), PNG (`89 50 4E 47`), WebP (`RIFF ... WEBP`), GIF (`47 49 46`), BMP (`42 4D`).
  - Rejects HTML (`<`), JSON (`{`), and array (`[`) error responses to prevent caching Cloudflare 403 pages as corrupted image files.
* **Two-Stage Fetch**: Standard `HttpClient` with custom headers, falling back to system `curl` with source headers and timeouts.
* **Disk Caching**: Stores verified image bytes in application documents/support cover directories.

### E. Database & Offline Resilience (`IsarService` & `SyncEngine`)
* **Isar Local Database**: Stores manga models, chapter lists, reading progress, and metadata.
* **Wipe Guard**: Prevents local library deletion if the server returns an empty or reset catalog.
* **Snapshot Caching**: Pre-fetches chapter lists and covers for library manga to allow uninterrupted offline reading.

---

## 3. Directory Layout & Extension Storage Locations
* **Source Extensions Repository**: `/home/zoro/Documents/Projects/manga/mangayomi-extensions`
  - Manifest: `index.json` (contains extension ID, name, version, pkgPath, baseUrl)
  - JS Sources: `javascript/manga/src/en/*.js`
* **Local App Runtime Extensions Directory**:
  - Linux Desktop: `~/Documents/extensions/` and `~/.local/share/com.sunfire.sunfire/extensions/`
  - Android / Mobile: `${getApplicationDocumentsDirectory()}/extensions/` and `${getApplicationSupportDirectory()}/extensions/`
  - Companion JSON: `<name>.json` (contains `name`, `version`, `iconUrl`)
* **Local Cover & Image Cache**:
  - `~/.local/share/com.sunfire.sunfire/covers/`

---

## 4. Extension Specific Details & Decryption Fixes
1. **MangaGo (`mangago.js`)**:
   - Encrypts chapter images in `var imgsrcs` (AES-128-CBC with ZeroBytePadding).
   - Keys: `e11adc3949ba59abbe56e057f20f883e`, IV: `1234567890abcdef1234567890abcdef`.
   - Fallback: Dynamic `SoJsonV4` deobfuscation from `chapter.js`.
   - Host transformation: `https://iweb_` -> `http://iweb_` (avoids Dart SSL rejection on underscored subdomains).
2. **MangaPill (`mangapill.js`)**:
   - Handles split sibling `<a>` tags for image thumbnail and title text.
   - Preserves items without dropping titles.
3. **MangaHere (`mangahere.js`)**:
   - Unescapes CDN query parameters (`&amp;` -> `&`).
   - Requires `Referer: https://fanfox.net/`.

---

## 5. Maintenance & Release Workflow
1. When modifying an extension in `mangayomi-extensions`:
   - Update `.js` code in `javascript/manga/src/en/`.
   - Bump version in `index.json` (e.g. `1.2.0` -> `1.3.0`).
   - Copy to local runtime directory (`~/Documents/extensions/`) with updated companion `.json`.
   - Commit and push to `just-for-death/mangayomi-extensions`.
2. When modifying the client in `sunfire`:
   - Run `fvm flutter analyze` to maintain 0 issues.
   - Run `fvm flutter test` for unit and regression tests.
   - Commit and push to `just-for-death/sunfire`.
