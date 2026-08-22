# 🌐 Universal Source Architecture Specification (Sunfire)

This document specifies the universal, zero-hardcoding architectural standard for extension loading, browsing feeds, thumbnail headers, searching, and filter management in Sunfire.

---

## 1. Zero Hardcoded URL/Source Routing in Dart Engine

### Problem
Previously, `QuickJsService.fetchSourceMangaLocal` used `if (sourceName.contains('weeb central'))` style blocks to construct scrape URLs in Dart. This caused bugs such as Popular and Latest feeds receiving the exact same hardcoded query string (`sort=Subscribers&order=Ascending`).

### Universal Rule
* **Extensions own their URLs & Logic**: Dart must **never** manually construct specific source URLs for standard operations.
* **Standard Invocation Protocol**:
  1. **Popular**: Invoke `_inst.getPopular(page)` on the JavaScript instance.
  2. **Latest Updates**: Invoke `_inst.getLatestUpdates(page)` on the JavaScript instance.
  3. **Search / Filter**: Invoke `_inst.search(query, page, filters)` on the JavaScript instance.
* The JS extension dynamically accesses its own `getFilterList()`, selects its default sort (`Popularity` vs `Latest Updates`), builds its request query, and queries the network through the engine bridge.

---

## 2. Universal Dynamic Thumbnail & CDN Image Headers

### Problem
Screens in the app were using hardcoded string matching (e.g. `thumb.contains('pstatic') ? 'https://webtoons.com/' : ...`) to set HTTP `Referer` headers. Unlisted sources failed with HTTP 403 / broken covers.

### Universal Rule
* All image display components (`ReaderScreen`, `SourceMangaGridScreen`, `MangaCoverImage`, `LibraryScreen`) must use `QuickJsService.getImageHeaders(url, sourceBaseUrl: sourceBaseUrl)`.
* `getImageHeaders` dynamically computes:
  - `User-Agent`: Modern browser User-Agent string.
  - `Referer`: If `sourceBaseUrl` is provided, uses it. Otherwise, extracts `${uri.scheme}://${uri.host}/` from the image's own URI.
  - `Accept`: Standard web image MIME types (`image/avif,image/webp,image/png,image/*,*/*;q=0.8`).

---

## 3. High-Fidelity QuickJS DOM Engine

### Problem
Community extensions rely on complex CSS selectors (e.g. `article:has(section)`, `section > a`, `div.flex.items-center`, `a[href*='/chapters/']`, `p.whitespace-pre-wrap.break-words`). If the embedded parser fails on pseudo-selectors, scrapers return 0 items.

### Universal Rule
* The engine provides a full micro-DOM implementation with:
  1. `:has(...)` relational pseudo-class resolution.
  2. Child combinators (`>`) and descendant combinators (` `).
  3. Multi-class matching (`.class1.class2`).
  4. Attribute operators (`[attr]`, `[attr="val"]`, `[attr*="val"]`, `[attr^="val"]`, `[attr$="val"]`).
  5. Fallback regex element extractors when DOM tree parsing encounters non-standard HTML5 structures.

---

## 4. Dynamic Mihon Filter Sheet

### Problem
The filter sheet in `SourceMangaGridScreen` was displaying a static list of hardcoded chips (`Popularity`, `Latest`, `Ongoing`, `Completed`), which didn't match the specific filters of individual sources (like Weeb Central's "Official Translation", MangaDex's "Content Rating", or Webtoons' "Originals").

### Universal Rule
* When a source screen opens, query `_inst.getFilterList()` via QuickJS.
* The UI dynamically renders the exact filter types returned:
  - `SelectFilter` $\rightarrow$ Dropdown / Segmented Chip Group.
  - `GroupFilter` / `CheckBox` $\rightarrow$ Filter Chips / Multi-select dialog.
  - `SortFilter` $\rightarrow$ Sort Direction + Criteria picker.
* When the user hits "Apply", the updated filter state array is serialized directly into `_inst.search(query, page, filters)`.

---

## 5. Universal Self-Healing Engine Protocol

### Rule
If an extension fails to return chapters or details (due to upstream site layout changes or missing URLs):
1. **Canonical ID Extraction**: Engine normalizes `/series/<ID>/slug` to canonical endpoints.
2. **Double-layer Fallback**: Engine scans HTTP response bodies for standard manga/chapter link patterns (`/chapters/...`, `/viewer?...`, `chapterfun.ashx`).
3. **Automatic DB Healing**: Successfully resolved URLs are cached to the local Isar database to ensure subsequent reading is instantaneous.
