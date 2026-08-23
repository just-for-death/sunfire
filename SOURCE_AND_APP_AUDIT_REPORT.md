# Comprehensive Audit & Diagnostic Report: Sunfire & Extension Sources

---

## 1. Executive Summary

This report documents the architectural bottlenecks, networking blockers, and extension-specific bugs identified across the Sunfire Flutter application and the JavaScript source extensions ecosystem.

---

## 2. Core Engine & Application Architecture Issues

### 2.1 Cloudflare Bot Fight Mode vs. Image CDN Downloads
- **Mechanism**: FlareSolverr solves HTML challenges and passes cookies back to the app. However, Flutter's image loaders (`Image.network`, `CronetClient`, and `HttpClient`) download binary image streams directly from content delivery networks (CDNs).
- **The Issue**: Certain CDNs (notably `cdn.readcomicsonline.ru`) enforce **Cloudflare Bot Fight Mode** directly at the TLS/TCP handshake layer (JA3 fingerprinting). Even with a valid `cf_clearance` cookie, non-browser TLS handshakes from mobile apps are rejected with **HTTP 403 Forbidden**.
- **Impact**: Chapter pages resolve and chapter counts appear correctly, but image slots fail to render or trigger perpetual 403 retries.

### 2.2 FlareSolverr Pre-warming Subdomain Mismatch (`_doPrewarm`)
- **Mechanism**: When an image request fails with 403, `_recoverImage` calls `MClient.prewarmSession(url)`.
- **The Issue**: If the failed URL is `https://cdn.readcomicsonline.ru/...`, `_doPrewarm` sends `https://cdn.readcomicsonline.ru` to FlareSolverr. Because the static CDN subdomain does not host the interactive Cloudflare challenge HTML page, FlareSolverr returns `Cookies: []` (0 cookies).
- **Required Fix**: Pre-warming must always resolve against the root domain (`https://readcomicsonline.ru`) rather than static asset subdomains.

### 2.3 QuickJS Extension Metadata Parsing (`extractSourceMetadata`)
- **Mechanism**: In `quickjs_service.dart`, `extractSourceMetadata` uses Dart's native `jsonDecode` to extract `const mangayomiSources = [{ ... }]`.
- **The Issue**: JavaScript extension files frequently use single quotes (`'baseUrl'`), unquoted keys, or trailing commas. `jsonDecode` throws a `FormatException` on non-strict JSON, falling back to an empty metadata object (`name: ''`), which breaks source identification and header resolution.

---

## 3. Extension Source Diagnostic Matrix

| Source | Status | Root Cause & Failure Analysis | Action Required |
| :--- | :--- | :--- | :--- |
| **Weeb Central** (`weeb_central.js`) | **WORKING** | Chapter list uses `/series/{id}/full-chapter-list`. Images on `official.lowee.us` / `scans.lastation.us` allow direct mobile streaming without Bot Fight Mode (22/22 pages @ 500 KB load with HTTP 200). | Maintain current stable configuration. |
| **Webtoons** (`webtoons.js`) | **BROKEN (Fixed)** | `get headers()` was defined as a property getter but invoked as a function (`this.getHeaders(url)`), causing a fatal `TypeError` in QuickJS that returned 0 pages. | Ensure explicit `getHeaders(url)` function and exact `div#_imageList img` selectors. |
| **ReadComicOnline** (`read_comics_online.js`) | **BLOCKED (403)** | HTML and chapters scrape via FlareSolverr, but `cdn.readcomicsonline.ru` enforces Cloudflare Bot Fight Mode on raw binary images. | Replace `.ru` with an open comic catalog or CDN provider that does not enforce Bot Fight Mode on images. |
| **MangaPill** (`mangapill.js`) | **FILTER CRASH** | `search()` crashes with `Cannot read property 'state' of undefined` when executed without active filter selections. Page scraper requires `Referer: https://mangapill.com/`. | Add defensive null-safe checks on all `filters` array indices. |
| **MangaFreak** (`mangafreak.js`) | **SEARCH 404** | Search endpoint `/Search/${query}` returns HTTP 404. MangaFreak migrated search to `/Find/${query}`. Chapter URLs use `/Read1_` patterns. | Update search route to `/Find/` and expand chapter regexes. |
| **MangaHere** (`mangahere.js`) | **TOKEN BLOCKED** | Chapter pages load images dynamically via `chapterfun.ashx`. Images require dynamic security tokens (`?token=...&ttl=...`); static URLs return 403. | Unpack `chapterfun.ashx` dynamically to append required security tokens. |
| **Mangago** (`mangago.js`) | **PROMO CHAPTERS** | Notice/promo chapters (`Ch0`, `/bt/` paths) return banners instead of manga pages. Real chapters are located under `/read-manga/`. | Filter out notice items and target `/read-manga/` paths with `Referer: https://www.mangago.me/`. |
| **nHentai** (`nhentai.js`) | **NEEDS MAPPING** | Cloudflare protected. Thumbnail paths (`t.nhentai.net/.../1t.webp`) must be converted to full image domains (`i.nhentai.net/.../1.webp`). | Ensure exact thumb-to-full string substitution. |
| **NineHentai** (`ninehentai.js`) | **PERMANENTLY DEAD** | Domain `ninehentai.to` has no DNS resolution (`Errno -2: Name or service not known`). Service was shut down. | Remove extension from repository. |

---

## 4. Step-by-Step Resolution Roadmap

1. **Step 1: Cleanup & Deprecations**
   - Remove dead `ninehentai.js` from `index.json` and repository.
   - Replace Cloudflare Bot Fight-blocked `read_comics_online.js` (`.ru`) with a reliable, open source.

2. **Step 2: Extension Logic Stabilization**
   - Apply null-safe filter handling across `mangapill.js`, `webtoons.js`, and `mangago.js`.
   - Update `mangafreak.js` search and chapter selectors.
   - Integrate `chapterfun.ashx` dynamic token resolution in `mangahere.js`.

3. **Step 3: App Engine Hardening**
   - Fix `_doPrewarm` in `m_client.dart` to strictly target root domains (`https://${root}`).
   - Enhance `extractSourceMetadata` in `quickjs_service.dart` with tolerant regex-based JS property extraction.
   - Propagate solved Cloudflare cookies and User-Agent headers dynamically on all image fetch retries.

4. **Step 4: Device-Level Verification**
   - Validate each source sequentially on hardware (`RZCW1166S3X`), confirming HTTP 200, valid image magic bytes, and in-app reader rendering.
