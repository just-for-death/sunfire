// Tests for the migration-server-sync fix:
//   1. normalizeUrlForMatch — URL identity used to FUSE a migration target with
//      an existing library entry instead of creating a duplicate (mangahere →
//      webtoons previously duplicated the server-synced webtoons entry).
//   2. findExistingLibraryManga — the dedup unit in SourceMigrationService,
//      exercised against a real in-memory Isar database.
import 'dart:ffi';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:sunfire/src/core/db/isar_service.dart';
import 'package:sunfire/src/core/db/models/manga.dart';
import 'package:sunfire/src/core/engine/source_migration_service.dart';

/// flutter test does not bundle the Isar native library; locate libisar.so in
/// the pub cache (from isar_flutter_libs) or the project's build output.
String? _findIsarNative() {
  final home = Platform.environment['HOME'] ?? '';
  final pubCache = Platform.environment['PUB_CACHE'] ?? '$home/.pub-cache';
  final candidates = <String>[
    '$pubCache/hosted/pub.dev/isar_flutter_libs-3.1.0+1/linux/libisar.so',
    '${Directory.current.path}/build/linux/x64/debug/bundle/lib/libisar.so',
    '${Directory.current.path}/../build/linux/x64/debug/bundle/lib/libisar.so',
  ];
  for (final c in candidates) {
    if (File(c).existsSync()) return c;
  }
  final rootDir = Directory('$pubCache/hosted/pub.dev');
  if (rootDir.existsSync()) {
    for (final d in rootDir.listSync().whereType<Directory>()) {
      if (d.path.contains('isar_flutter_libs')) {
        final f = File('${d.path}/linux/libisar.so');
        if (f.existsSync()) return f.path;
      }
    }
  }
  return null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('sunfire_migration_test');
    final native = _findIsarNative();
    if (native == null) {
      fail('libisar.so not found (pub cache or build output) — cannot run DB-backed tests');
    }
    await Isar.initializeIsarCore(libraries: {Abi.linuxX64: native});
    // Open Isar BEFORE IsarService.initialize() so the service picks up this
    // instance via Isar.getInstance() and never touches path_provider.
    await Isar.open([MangaSchema], directory: tempDir.path, inspector: false);
    await IsarService.instance.initialize();
  });

  tearDownAll(() async {
    await IsarService.instance.isar.close();
    try {
      await tempDir.delete(recursive: true);
    } catch (_) {}
  });

  group('normalizeUrlForMatch', () {
    test('1. Strips scheme + host, lowercases, and removes trailing separators', () {
      final svc = SourceMigrationService.instance;
      expect(
        svc.normalizeUrlForMatch('https://www.webtoons.com/en/fantasy/tower-of-god/list?title_no=95'),
        equals('/en/fantasy/tower-of-god/list?title_no=95'),
      );
      expect(
        svc.normalizeUrlForMatch('HTTP://WebToons.com/en/fantasy/tower-of-god/'),
        equals('/en/fantasy/tower-of-god'),
      );
      expect(
        svc.normalizeUrlForMatch('https://mangadex.org/title/abc-def/'),
        equals('/title/abc-def'),
      );
    });

    test('2. Left alone when already relative or empty', () {
      final svc = SourceMigrationService.instance;
      expect(svc.normalizeUrlForMatch('/en/fantasy/tower-of-god'), equals('/en/fantasy/tower-of-god'));
      expect(svc.normalizeUrlForMatch(''), equals(''));
    });
  });

  group('findExistingLibraryManga (dedup/fuse)', () {
    Future<Manga> seed({
      required String sourceName,
      required String url,
      required String title,
      required int serverId,
      bool inLibrary = true,
    }) async {
      final m = Manga()
        ..serverId = serverId
        ..sourceName = sourceName
        ..url = url
        ..title = title
        ..inLibrary = inLibrary;
      await IsarService.instance.isar.writeTxn(() async {
        await IsarService.instance.isar.mangas.put(m);
      });
      return m;
    }

    setUp(() async {
      await IsarService.instance.isar.writeTxn(() async {
        await IsarService.instance.isar.mangas.clear();
      });
    });

    test('3. Fuses with the existing server-synced entry by URL (the webtoons bug)', () async {
      // Simulates the record the Suwayomi server sync created for a webtoons source.
      final serverEntry = await seed(
        sourceName: 'Webtoons',
        url: 'https://www.webtoons.com/en/fantasy/tower-of-god/list?title_no=95',
        title: 'Tower of God',
        serverId: 4242,
      );

      // Migrating a mangahere entry onto webtoons must find the SAME record…
      final found = await SourceMigrationService.instance.findExistingLibraryManga(
        sourceName: 'MangaHere',
        url: 'https://www.mangahere.cc/manga/tower_of_god',
        title: 'Tower of God',
      );
      // …and must NOT find it (different source).
      expect(found, isNull);
      expect(serverEntry.id, greaterThan(0));

      // Now the migration's target-side lookup (webtoons target):
      final fused = await SourceMigrationService.instance.findExistingLibraryManga(
        sourceName: 'Webtoons',
        url: 'https://www.webtoons.com/en/fantasy/tower-of-god/list?title_no=95',
        title: 'Tower of God',
      );
      expect(fused, isNotNull);
      expect(fused!.serverId, equals(4242));
      expect(fused.id, equals(serverEntry.id));
    });

    test('4. URL alias (path-containment) still fuses', () async {
      await seed(
        sourceName: 'Webtoons',
        url: 'https://www.webtoons.com/en/fantasy/tower-of-god/list?title_no=95',
        title: 'Tower of God',
        serverId: 4243,
      );
      final fused = await SourceMigrationService.instance.findExistingLibraryManga(
        sourceName: 'Webtoons (EN)',
        url: 'https://www.webtoons.com/en/fantasy/tower-of-god/',
        title: 'Tower of God',
      );
      expect(fused, isNotNull);
      expect(fused!.serverId, equals(4243));
    });

    test('5. Distinct URL + same title must NOT fuse (avoids false merges)', () async {
      await seed(
        sourceName: 'Webtoons',
        url: 'https://www.webtoons.com/en/fantasy/tower-of-god/list?title_no=95',
        title: 'Tower of God',
        serverId: 4244,
      );
      final found = await SourceMigrationService.instance.findExistingLibraryManga(
        sourceName: 'Webtoons',
        url: 'https://www.webtoons.com/en/romance/true-beauty/list?title_no=2200',
        title: 'Tower of God',
      );
      expect(found, isNull);
    });

    test('6. Title-only fallback fuses when one side has no URL', () async {
      await seed(
        sourceName: 'Webtoons',
        url: '',
        title: 'Tower of God',
        serverId: 4245,
      );
      final fused = await SourceMigrationService.instance.findExistingLibraryManga(
        sourceName: 'Webtoons',
        url: 'https://www.webtoons.com/en/fantasy/tower-of-god/list?title_no=95',
        title: 'tower of god',
      );
      expect(fused, isNotNull);
      expect(fused!.serverId, equals(4245));
    });

    test('7. Source-name mismatch never fuses', () async {
      await seed(
        sourceName: 'Mangahere',
        url: 'https://www.mangahere.cc/manga/tower_of_god',
        title: 'Tower of God',
        serverId: 4246,
      );
      final found = await SourceMigrationService.instance.findExistingLibraryManga(
        sourceName: 'Webtoons',
        url: 'https://www.webtoons.com/en/fantasy/tower-of-god/list?title_no=95',
        title: 'Tower of God',
      );
      expect(found, isNull);
    });

    test('8. Entries not in the library are never fused', () async {
      await seed(
        sourceName: 'Webtoons',
        url: 'https://www.webtoons.com/en/fantasy/tower-of-god/list?title_no=95',
        title: 'Tower of God',
        serverId: 4247,
        inLibrary: false,
      );
      final found = await SourceMigrationService.instance.findExistingLibraryManga(
        sourceName: 'Webtoons',
        url: 'https://www.webtoons.com/en/fantasy/tower-of-god/list?title_no=95',
        title: 'Tower of God',
      );
      expect(found, isNull);
    });
  });
}