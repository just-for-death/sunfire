// Download-folder completion detection.
//
// WHY THIS EXISTS
//
// A downloaded chapter is "offline available" purely on the strength of a marker
// file the downloader writes after every page was verified as a real image.
// Anything that reports a folder as complete when it is not sends the reader
// online for a chapter it believes it has, and anything that reports it as
// incomplete drops the chapter from the library's Downloaded filter.
//
// This check is on a startup path. `main.dart` used to await
// `DownloadManagerService.initialize()` before `runApp`, and that included a scan
// validating every page header of every downloaded chapter — ~8000
// open/read/stat round-trips for a 200-chapter library at 40 pages each, before
// the first frame, on every cold start. The scan has since been moved off the
// critical path rather than weakened, and THIS FILE is the reason that was the
// right call: a cheaper variant of the check was written, reviewed, and was
// wrong. See the "rejects every shape" group below for the cases that caught it.
//
// Run: fvm flutter test test/download_folder_validation_test.dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/engine/image_validation.dart';

/// A minimal valid JPEG: SOI, APP0/JFIF payload, EOI. Only the magic prefix is
/// inspected, but the length must clear the minimum-bytes floor.
List<int> _jpeg(int bytes) {
  final out = List<int>.filled(bytes, 0x20);
  out[0] = 0xFF;
  out[1] = 0xD8;
  out[2] = 0xFF;
  out[3] = 0xE0;
  out[bytes - 2] = 0xFF;
  out[bytes - 1] = 0xD9;
  return out;
}

List<int> _png(int bytes) {
  final out = List<int>.filled(bytes, 0);
  out.setAll(0, [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
  return out;
}

/// A body that is not an image at all — a Cloudflare challenge page, an HTML
/// error body, a JSON payload. Deliberately well over the length floor so that
/// only the magic-header check can reject it.
List<int> _htmlError(int bytes) => List<int>.filled(bytes, 0x3C); // '<'

void main() {
  late Directory root;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('sunfire_dl_complete');
  });

  tearDown(() async {
    if (await root.exists()) await root.delete(recursive: true);
  });

  Future<Directory> chapter(String name) async {
    final d = Directory('${root.path}/$name');
    await d.create(recursive: true);
    return d;
  }

  Future<void> writeMarker(Directory dir, String count) async {
    await File('${dir.path}/$kDownloadCompleteMarkerName').writeAsString(count);
  }

  Future<void> writePage(Directory dir, int index, List<int> bytes) async {
    await File('${dir.path}/page_${(index + 1).toString().padLeft(3, '0')}.jpg')
        .writeAsBytes(bytes);
  }

  group('marker presence is required', () {
    test('no marker means not complete, however full the folder is', () async {
      // A folder without a marker is mid-download, or the leftover of a failed,
      // cancelled or paused attempt. Trusting it makes the reader believe it has
      // pages it does not.
      final dir = await chapter('no-marker');
      for (var i = 0; i < 3; i++) {
        await writePage(dir, i, _jpeg(4000));
      }
      expect(await isDownloadFolderComplete(dir), isFalse);
    });

    test('an unusable marker means not complete', () async {
      // A truncated or empty marker must fail safe.
      for (final bad in ['', '   ', 'abc', '3.5', '-1']) {
        final dir = await chapter('bad-marker-${bad.hashCode.abs()}');
        await writePage(dir, 0, _jpeg(4000));
        await writeMarker(dir, bad);
        expect(await isDownloadFolderComplete(dir), isFalse, reason: 'marker "$bad"');
      }
    });

    test('a zero marker is rejected, not matched against an empty folder', () async {
      // The tempting shortcut is "0 pages on disk == 0 marked, so complete". It
      // is wrong: a folder is only ever marked by a run that got as far as
      // writing pages, so a marker of 0 means the marker itself is not
      // trustworthy. The original guard admitted 0 by only rejecting null.
      final dir = await chapter('empty-zero');
      await writeMarker(dir, '0');
      expect(await isDownloadFolderComplete(dir), isFalse);
    });
  });

  group('rejects every shape of incomplete folder', () {
    // These are the cases that caught the reverted fast variant. In particular
    // the invalid-page cases below have the invalid content already on disk
    // BEFORE the marker is written, so the file count matches the marker and
    // nothing is newer than it — both conditions a count-plus-mtime shortcut
    // would treat as proof of validity. It was wrong: "the marker is only
    // written after the pages were verified" holds for the current downloader
    // and not for an install that predates the validator, or content replaced
    // outside the app.

    Future<void> expectNotComplete(String name, Future<void> Function(Directory) build) async {
      final dir = await chapter(name);
      await build(dir);
      expect(await isDownloadFolderComplete(dir), isFalse, reason: '"$name" must not read as complete');
    }

    test('CONTROL: a fully valid folder is complete', () async {
      // Without this, a checker that returned false for everything would pass
      // every other case in this group.
      final dir = await chapter('valid');
      for (var i = 0; i < 5; i++) {
        await writePage(dir, i, _jpeg(4000));
      }
      await writeMarker(dir, '5');
      expect(await isDownloadFolderComplete(dir), isTrue);
    });

    test('CONTROL: mixed formats are complete', () async {
      final dir = await chapter('mixed');
      await File('${dir.path}/page_001.jpg').writeAsBytes(_jpeg(4000));
      await File('${dir.path}/page_002.png').writeAsBytes(_png(4000));
      await writeMarker(dir, '2');
      expect(await isDownloadFolderComplete(dir), isTrue);
    });

    test('a missing page — count disagrees with the marker', () async {
      // The source returned 10 pages; one was lost or never written.
      await expectNotComplete('short', (dir) async {
        for (var i = 0; i < 3; i++) {
          await writePage(dir, i, _jpeg(4000));
        }
        await writeMarker(dir, '10');
      });
    });

    test('extra stale pages — folder holds more than the marker claims', () async {
      // Resuming against a longer earlier download leaves orphans behind.
      await expectNotComplete('extra', (dir) async {
        for (var i = 0; i < 12; i++) {
          await writePage(dir, i, _jpeg(4000));
        }
        await writeMarker(dir, '10');
      });
    });

    test('a page that is an HTML error body, not an image', () async {
      // The Cloudflare-challenge case, and the reason the length floor is not
      // sufficient on its own: this body is well over it.
      await expectNotComplete('html-error', (dir) async {
        await writePage(dir, 0, _htmlError(9000));
        await writeMarker(dir, '1');
      });
    });

    test('DOCUMENTS A LIMIT: a truncated page is NOT detected by a prefix probe', () async {
      // This asserts the KNOWN behaviour, deliberately, because it is the thing
      // a future reader is most likely to assume away.
      //
      // `looksLikeImageHeader` reads a prefix, so a page cut off after its SOI
      // and APP0 but before its scan data matches the JPEG branch exactly as a
      // whole page does. Detecting this would mean reading every page to the
      // end, which is precisely the cost the probe exists to avoid.
      //
      // So truncated pages are PREVENTED, not detected: the downloader writes
      // each page to `page_NNN.jpg.part` and renames it into place, which is
      // atomic, so a page on disk is either absent or whole. This test is the
      // record of why the code does it that way — if it ever starts passing,
      // the probe changed and the reasoning above needs revisiting.
      final dir = await chapter('truncated');
      final truncated = List<int>.filled(4000, 0x20);
      truncated[0] = 0xFF;
      truncated[1] = 0xD8;
      truncated[2] = 0xFF;
      truncated[3] = 0xE0;
      // deliberately no trailing FF D9, and no scan data
      await File('${dir.path}/page_001.jpg').writeAsBytes(truncated);
      await writeMarker(dir, '1');

      expect(looksLikeImageHeader(truncated), isTrue,
          reason: 'a prefix probe cannot see the missing tail — this is why the '
              'write must be atomic rather than the check being stricter');
      expect(await isDownloadFolderComplete(dir), isTrue,
          reason: 'documented limit, not an endorsement: see the comment above');
    });

    test('a page under the minimum length floor', () async {
      await expectNotComplete('tiny', (dir) async {
        await writePage(dir, 0, _jpeg(64));
        await writeMarker(dir, '1');
      });
    });

    test('one bad page among good ones is enough', () async {
      // The count matches the marker and every other page is valid, so only
      // per-file inspection can catch this.
      await expectNotComplete('one-bad', (dir) async {
        for (var i = 0; i < 4; i++) {
          await writePage(dir, i, _jpeg(4000));
        }
        await writePage(dir, 4, _htmlError(9000));
        await writeMarker(dir, '5');
      });
    });
  });

  group('expectedPageCount short-circuits the disk walk', () {
    test('compares against the marker and ignores disk contents', () async {
      final dir = await chapter('expected');
      for (var i = 0; i < 4; i++) {
        await writePage(dir, i, _jpeg(4000));
      }
      await writeMarker(dir, '4');
      expect(await isDownloadFolderComplete(dir, expectedPageCount: 4), isTrue);
      expect(await isDownloadFolderComplete(dir, expectedPageCount: 5), isFalse);
    });

    test('an unusable marker still fails even with a matching expected count', () async {
      // The short-circuit must not become a way to bypass the marker check.
      final dir = await chapter('expected-bad-marker');
      await writePage(dir, 0, _jpeg(4000));
      await writeMarker(dir, 'garbage');
      expect(await isDownloadFolderComplete(dir, expectedPageCount: 1), isFalse);
    });
  });
}
