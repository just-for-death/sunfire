import 'dart:io';

/// Image-format sniffing and download-folder validation, shared by the
/// downloader and the content resolver.
///
/// These used to be two private copies that had drifted. The resolver's copy
/// recognised JPEG/PNG/WebP only, while the downloader's also accepted GIF,
/// BMP, AVIF/HEIC and JPEG XL. The consequence was a chapter that downloaded,
/// passed validation, got its `.download_complete` marker written and showed
/// "Completed" in the UI, but which `isDownloadFolderComplete` then rejected
/// forever — so it never registered as downloaded, never appeared in the
/// library's Downloaded filter, and the reader always went back online. One
/// AVIF page was enough.
///
/// The resolver also read every page in full with `readAsBytesSync()` just to
/// look at the first 12 bytes, on the UI isolate, during `initialize()` —
/// which `main.dart` awaits before `runApp`. For a large offline library that
/// is gigabytes of blocking reads and a black screen on every cold start.
/// [looksLikeImageFile] reads only a header prefix and yields between files.

const String kDownloadCompleteMarkerName = '.download_complete';

/// File extensions treated as chapter page images.
const Set<String> kImagePageExtensions = <String>{
  '.jpg',
  '.jpeg',
  '.png',
  '.webp',
  '.gif',
  '.bmp',
  '.avif',
  '.jxl',
};

/// Whether [path] looks like a downloaded chapter page by extension.
bool isImagePagePath(String path) {
  final lower = path.toLowerCase();
  for (final ext in kImagePageExtensions) {
    if (lower.endsWith(ext)) return true;
  }
  return false;
}

/// Whether [header] — the first bytes of a file — is a recognised image format.
///
/// Deliberately header-only. It cannot detect a truncated image whose header
/// survived, which is why page writes are atomic (see the downloader); but it
/// is enough to reject the real failure mode, which is an HTML error page or a
/// Cloudflare challenge body saved in place of a page.
///
/// Accepts JPEG, PNG, WebP, GIF, BMP, AVIF/HEIC and JPEG XL. The AVIF/HEIC
/// and JPEG XL branches are what the resolver was missing.
bool looksLikeImageHeader(List<int>? b) {
  if (b == null || b.length < 12) return false;
  // JPEG: FF D8
  if (b[0] == 0xFF && b[1] == 0xD8) return true;
  // PNG: 89 50 4E 47
  if (b[0] == 0x89 && b[1] == 0x50 && b[2] == 0x4E && b[3] == 0x47) return true;
  // WebP: RIFF....WEBP
  if (b[0] == 0x52 && b[1] == 0x49 && b[2] == 0x46 && b[3] == 0x46 &&
      b[8] == 0x57 && b[9] == 0x45 && b[10] == 0x42 && b[11] == 0x50) {
    return true;
  }
  // GIF: GIF87a / GIF89a
  if (b[0] == 0x47 && b[1] == 0x49 && b[2] == 0x46 && b[3] == 0x38) return true;
  // BMP: 42 4D
  if (b[0] == 0x42 && b[1] == 0x4D) return true;
  // AVIF / HEIC: ISO-BMFF box, "ftyp" at offset 4
  if (b[4] == 0x66 && b[5] == 0x74 && b[6] == 0x79 && b[7] == 0x70) return true;
  // JPEG XL: bare codestream (FF 0A) or container signature box
  if (b[0] == 0xFF && b[1] == 0x0A) return true;
  if (b[0] == 0x00 && b[1] == 0x00 && b[2] == 0x00 && b[3] == 0x0C &&
      b[4] == 0x4A && b[5] == 0x58 && b[6] == 0x4C && b[7] == 0x20) {
    return true;
  }
  // Anything else (HTML/JSON/Cloudflare challenge pages, truncated junk) is NOT
  // an image. The old "any non-HTML blob over 500 bytes" fallback let error
  // bodies be saved as pages and the chapter marked downloaded.
  return false;
}

/// Smallest plausible image, used to reject truncated stubs.
const int kMinImageBytes = 500;

/// Whether [file] is a plausibly valid downloaded page.
///
/// Reads only a header prefix and the length, never the whole file, and does
/// not block: this runs over every page of every downloaded chapter on the UI
/// isolate during startup.
Future<bool> looksLikeImageFile(File file) async {
  try {
    final length = await file.length();
    if (length <= kMinImageBytes) return false;
    final handle = await file.open();
    try {
      final header = await handle.read(kImageHeaderProbeBytes);
      return looksLikeImageHeader(header);
    } finally {
      await handle.close();
    }
  } catch (_) {
    // An unreadable file cannot be validated, so it must not count towards a
    // complete chapter — that is the correct answer, not a swallowed error.
    return false;
  }
}

/// How many leading bytes [looksLikeImageHeader] needs.
const int kImageHeaderProbeBytes = 16;

/// Whether [chapterDir] holds a chapter that finished downloading.
///
/// The marker's presence is the only thing that makes a folder eligible to
/// resolve as "downloaded" — a folder without it is mid-download or was left by
/// a failed attempt.
///
/// When [expectedPageCount] is null the marked count is validated against the
/// files actually on disk, which catches a source whose page count changed, a
/// folder where files were lost, and a torn write. That path reads only header
/// prefixes and yields to the event loop between files, so a large offline
/// library no longer blocks the first frame.
Future<bool> isDownloadFolderComplete(Directory chapterDir, {int? expectedPageCount}) async {
  final marker = File('${chapterDir.path}/$kDownloadCompleteMarkerName');
  if (!await marker.exists()) return false;

  final raw = (await marker.readAsString()).trim();
  final markedCount = int.tryParse(raw);
  if (markedCount == null) return false;

  if (expectedPageCount != null) {
    return markedCount == expectedPageCount;
  }

  var validCount = 0;
  var yielded = 0;
  await for (final entity in chapterDir.list(followLinks: false)) {
    if (entity is! File) continue;
    if (!isImagePagePath(entity.path)) continue;
    if (await looksLikeImageFile(entity)) validCount++;
    // Give the UI isolate a turn every so often so a big library cannot
    // monopolise the frame budget during startup.
    if (++yielded % 32 == 0) await Future<void>.delayed(Duration.zero);
  }
  return validCount == markedCount;
}
