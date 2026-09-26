// Local id allocation contracts.
//
// WHY THIS EXISTS
//
// Local (non-server) rows are identified by a negative synthetic id, because
// `serverId` is `@Index(unique: true, replace: true)` on both Manga and
// Chapter. Two independent bugs lived in how those ids were produced, and both
// destroyed user data silently — a collision REPLACES the row, it does not
// error.
//
// BUG 1 — `String.hashCode` as a persistent identity.
//
// Dart seeds `String.hashCode` per isolate, so it differs between process
// runs. `source_manga_grid_screen` used
// `(link.hashCode ^ sourceName.hashCode).abs()` for a browsed series and
// persisted it as `Manga.serverId`. Every cold start therefore gave the same
// series a new identity: `getMangaByServerId` missed, a duplicate row was
// inserted, and the previous identity's chapters — keyed on the old id — were
// orphaned along with their read state, bookmarks and downloads. Re-browsing a
// local source a few times a week quietly filled the library with duplicates.
//
// BUG 2 — a second, incompatible synthetic-chapter formula.
//
// `migrate_search_screen` minted `-(mangaId * 10000 + i + 1)` while
// `mintLocalChapterServerId` mints `-(mangaId * 100000 + i + 1)`. The ranges
// overlap ACROSS series: migrating series 10 produced -100001, and a later
// scrape of series 1 minted the same -100001, replacing the migrated chapter
// with a fresh unread one. The repo's own
// `local_chapter_id_collision_test.dart` documents this exact failure mode but
// only covers the same-manga case, which is why the second formula slipped
// through.
//
// Run: fvm flutter test test/local_id_allocation_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/db/models/chapter.dart';
import 'package:sunfire/src/core/db/models/manga.dart';

void main() {
  group('stableLocalMangaServerId', () {
    test('is deterministic for the same series', () {
      // The whole point. A per-run hash made every cold start a new identity.
      final a = stableLocalMangaServerId(sourceName: 'MangaDex', url: '/title/1', title: 'One Piece');
      final b = stableLocalMangaServerId(sourceName: 'MangaDex', url: '/title/1', title: 'One Piece');
      expect(a, b);
    });

    test('is always negative, so it never enters the server id space', () {
      // Every writer treats a negative serverId as "local only, never push".
      for (final url in ['/a', '/b', '/c', '']) {
        final id = stableLocalMangaServerId(sourceName: 'S', url: url, title: 'T');
        expect(id, lessThan(0), reason: 'url="$url" produced a non-negative id');
      }
    });

    test('is never zero', () {
      // Zero means "no persisted identity" to every lookup in the app.
      expect(stableLocalMangaServerId(sourceName: '', url: '', title: ''), isNot(0));
    });

    test('differs per series and per source', () {
      final one = stableLocalMangaServerId(sourceName: 'MangaDex', url: '/title/1', title: 'A');
      final two = stableLocalMangaServerId(sourceName: 'MangaDex', url: '/title/2', title: 'B');
      final otherSource = stableLocalMangaServerId(sourceName: 'Mangapill', url: '/title/1', title: 'A');

      expect(one, isNot(two), reason: 'two series must not collide');
      expect(one, isNot(otherSource),
          reason: 'the same URL on two sources is two different series');
    });

    test('normalises case and surrounding whitespace', () {
      // Otherwise re-browsing with a differently-cased URL forks the identity,
      // which is the duplicate-row bug in a smaller window.
      final canonical = stableLocalMangaServerId(sourceName: 'MangaDex', url: '/Title/1', title: 'X');
      expect(
        stableLocalMangaServerId(sourceName: 'mangadex', url: '  /Title/1  ', title: 'x'),
        canonical,
      );
    });

    test('prefers the url over the title when the url is known', () {
      // A title can be duplicated across volumes; a url cannot.
      final byUrl = stableLocalMangaServerId(sourceName: 'S', url: '/series/7', title: 'Same');
      final differentUrl = stableLocalMangaServerId(sourceName: 'S', url: '/series/8', title: 'Same');
      expect(byUrl, isNot(differentUrl));
    });

    test('falls back to the title when no url is available', () {
      final a = stableLocalMangaServerId(sourceName: 'S', url: '', title: 'Series A');
      final b = stableLocalMangaServerId(sourceName: 'S', url: '', title: 'Series B');
      expect(a, isNot(b));
    });

    test('stays inside a JS-safe integer range', () {
      // 52 bits, so a value survives a round trip through the QuickJS bridge
      // (which uses doubles) without silent precision loss.
      for (var i = 0; i < 200; i++) {
        final id = stableLocalMangaServerId(sourceName: 'S', url: '/x/$i', title: 'T$i');
        expect(id.abs(), lessThan(9007199254740992), reason: 'url /x/$i');
      }
    });
  });

  group('mintLocalChapterServerId', () {
    test('produces negative ids namespaced per manga', () {
      final taken = <int>{};
      final a = mintLocalChapterServerId(mangaId: 1, index: 0, takenServerIds: taken);
      final b = mintLocalChapterServerId(mangaId: 1, index: 1, takenServerIds: taken);

      expect(a, lessThan(0));
      expect(b, lessThan(0));
      expect(a, isNot(b));
    });

    test('never collides within a manga', () {
      final taken = <int>{};
      final ids = <int>{
        for (var i = 0; i < 500; i++) mintLocalChapterServerId(mangaId: 42, index: i, takenServerIds: taken),
      };
      expect(ids, hasLength(500));
    });

    test('probes past an id that is already taken', () {
      // The collision case: a row already holds the id this formula wants.
      final taken = <int>{};
      final first = mintLocalChapterServerId(mangaId: 7, index: 0, takenServerIds: taken);
      final second = mintLocalChapterServerId(mangaId: 7, index: 0, takenServerIds: taken);

      expect(second, isNot(first), reason: 're-minting the same index must not collide');
      expect(taken, containsAll([first, second]));
    });

    test('ranges for different manga do not overlap', () {
      // The defect the second formula caused. `-(id * 10000 + i + 1)` for manga
      // 10 produced exactly the id `-(1 * 100000 + 0 + 1)` produces for manga 1,
      // and since serverId is `unique: true, replace: true` that silently
      // replaced one series' chapter with another's.
      final taken = <int>{};
      final ids = <int>{};
      for (final mangaId in [1, 2, 10, 100, 999]) {
        for (var i = 0; i < 20; i++) {
          ids.add(mintLocalChapterServerId(mangaId: mangaId, index: i, takenServerIds: taken));
        }
      }
      expect(ids, hasLength(5 * 20), reason: 'a cross-manga id collision would reduce the count');
    });

    // ── The regression this section exists for ────────────────────────────
    //
    // `stableLocalMangaServerId` originally returned a 52-bit value, and the
    // mint multiplies `mangaId.abs() * 100000`. Dart ints are 64-bit and wrap
    // silently, so 4.5e15 * 1e5 = 4.5e20 overflowed and the result came out
    // POSITIVE. Only the bottom 2% of the 52-bit range is safe, so ~98% of
    // locally-scraped series were handed positive chapter ids — which alias real
    // server chapters in the unique index, get pushed to the server as bogus
    // progress, and are picked up by the sync prune.
    //
    // The earlier assertions in this file only ever passed small ids (1, 2, 7,
    // 10, 42, 999), so they all passed while the real input domain was broken.

    test('stays negative for a REAL hashed local manga id', () {
      for (var i = 0; i < 500; i++) {
        final mangaId = stableLocalMangaServerId(
          sourceName: 'MangaDex',
          url: '/title/$i',
          title: 'Series $i',
        );
        final chapterId = mintLocalChapterServerId(
          mangaId: mangaId,
          index: i,
          takenServerIds: <int>{},
        );
        expect(chapterId, lessThan(0), reason: 'mangaId=$mangaId index=$i produced a positive chapter id');
      }
    });

    test('the manga id width leaves headroom for the stride multiply', () {
      // Pins the arithmetic relationship the two functions depend on. If the
      // hash is ever widened, this fails before the overflow does.
      const stride = 100000;
      for (var i = 0; i < 200; i++) {
        final id = stableLocalMangaServerId(sourceName: 'S', url: '/w/$i', title: 'T').abs();
        expect(id * stride, lessThan(1 << 62), reason: 'id=$i leaves no headroom for the stride');
      }
    });

    test('never returns a positive id for any input, however large', () {
      // Defence in depth: the clamp must hold even for an id far outside the
      // range the hash produces.
      for (final mangaId in <int>[
        0,
        1,
        -1,
        90000000000,
        -90000000000,
        90000000001,
        4503599627370495, // the old 52-bit maximum
        -4503599627370495,
        9007199254740991, // 2^53 - 1, JS's max safe integer
        9223372036854775807, // Int64 max
      ]) {
        for (var i = 0; i < 5; i++) {
          final minted = mintLocalChapterServerId(
            mangaId: mangaId,
            index: i,
            takenServerIds: <int>{},
          );
          expect(minted, lessThan(0), reason: 'mangaId=$mangaId index=$i');
        }
      }
    });

    test('probing moves away from zero, never across it', () {
      // The detail screen used to probe with `ch.serverId++`, which walks a
      // NEGATIVE id toward the positive namespace that belongs to real server
      // chapters. Enough colliding slots and it crossed zero.
      final taken = <int>{};
      final first = mintLocalChapterServerId(mangaId: 5, index: 0, takenServerIds: taken);
      final probed = <int>[];
      for (var i = 0; i < 200; i++) {
        probed.add(mintLocalChapterServerId(mangaId: 5, index: 0, takenServerIds: taken));
      }
      expect(probed.every((id) => id < 0), isTrue, reason: 'a probe crossed zero');
      // Monotonically decreasing: each probe lands below the last.
      for (var i = 1; i < probed.length; i++) {
        expect(probed[i], lessThan(probed[i - 1]), reason: 'probe $i did not move away from zero');
      }
      expect(first, greaterThan(probed.last));
    });

    test('a large index is clamped into the band, not into another series', () {
      final taken = <int>{};
      final a = mintLocalChapterServerId(mangaId: 3, index: 0, takenServerIds: taken);
      final b = mintLocalChapterServerId(mangaId: 3, index: 100000000, takenServerIds: taken);
      // The index is reduced modulo the stride so it cannot spill into the next
      // manga's band and collide with it.
      expect(b, lessThan(0));
      expect((a.abs() ~/ 100000) == (b.abs() ~/ 100000), isTrue,
          reason: 'a huge index escaped the series band');
    });

    test('a manga id that was previously used by the old formula is probed past', () {
      // Seed with the id the removed `-(mangaId * 10000 + i + 1)` formula would
      // have produced for a DIFFERENT manga, and confirm the canonical mint
      // never hands it out.
      const staleLegacyId = -100001; // -(10 * 10000 + 0 + 1)
      final taken = <int>{staleLegacyId};
      final minted = mintLocalChapterServerId(mangaId: 1, index: 0, takenServerIds: taken);
      expect(minted, isNot(staleLegacyId));
    });
  });

  group('Manga.canonicalKey', () {
    test('is the serverId, including for a negative local id', () {
      final local = Manga()..serverId = -987654321;
      expect(local.canonicalKey, -987654321);

      final server = Manga()..serverId = 42;
      expect(server.canonicalKey, 42);
    });

    test('is not the Isar auto-increment id', () {
      // A local row has canonicalKey = its negative synthetic serverId while
      // `id` is a small positive auto-increment that can collide with another
      // series' serverId. That collision is the bug this accessor removes.
      final manga = Manga()
        ..id = 7
        ..serverId = -12345;
      expect(manga.canonicalKey, isNot(manga.id));
    });
  });
}
