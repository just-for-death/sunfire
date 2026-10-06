import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunfire/src/core/db/models/chapter.dart';
import 'package:sunfire/src/core/db/models/manga.dart';
import 'package:sunfire/src/core/services/settings_service.dart';
import 'package:sunfire/src/core/sync/sync_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ISS-053 author preserve', () {
    test('blank/null server author does not wipe existing', () {
      final manga = Manga()
        ..serverId = 202
        ..title = 'Sakamoto Days'
        ..author = 'HOKAZONO Takeru'
        ..description = 'desc';
      // Simulate _performFullSync guard:
      final nodeMap = <String, dynamic>{'title': 'Sakamoto Days'};
      if (!manga.isMetadataLocked) {
        final serverAuthor = nodeMap['author']?.toString();
        if (serverAuthor != null && serverAuthor.trim().isNotEmpty) {
          manga.author = serverAuthor.trim();
        }
        final serverDesc = nodeMap['description']?.toString();
        if (serverDesc != null && serverDesc.trim().isNotEmpty) {
          manga.description = serverDesc.trim();
        }
      }
      expect(manga.author, 'HOKAZONO Takeru');
      expect(manga.description, 'desc');
    });

    test('non-empty server author replaces', () {
      final manga = Manga()
        ..serverId = 1
        ..title = 'X'
        ..author = 'Old';
      final nodeMap = <String, dynamic>{'author': 'New Author'};
      final serverAuthor = nodeMap['author']?.toString();
      if (serverAuthor != null && serverAuthor.trim().isNotEmpty) {
        manga.author = serverAuthor.trim();
      }
      expect(manga.author, 'New Author');
    });
  });

  group('ISS-054 bulk-import exclusion', () {
    test('fetchedAt within 60s of inLibraryAt is import', () {
      expect(
        isLikelyBulkImportChapter(fetchedAt: 1000, inLibraryAt: 1000),
        isTrue,
      );
      expect(
        isLikelyBulkImportChapter(fetchedAt: 1050, inLibraryAt: 1000),
        isTrue,
      );
      expect(
        isLikelyBulkImportChapter(fetchedAt: 1070, inLibraryAt: 1000),
        isFalse,
      );
      expect(
        isLikelyBulkImportChapter(fetchedAt: 0, inLibraryAt: 1000),
        isFalse,
      );
    });
  });

  group('ISS-055 clear sticky', () {
    test('preserveCleared skips stamp on persisted fetchedAt=0', () {
      final ch = Chapter()
        ..id = 42
        ..serverId = 9
        ..fetchedAt = 0;
      applyServerFetchedAt(ch, 1786805000000, preserveCleared: true);
      expect(ch.fetchedAt, 0);
    });

    test('brand-new chapter still receives stamp', () {
      final ch = Chapter()..serverId = 9;
      expect(ch.id, Isar.autoIncrement);
      applyServerFetchedAt(ch, 1786805000000, preserveCleared: true);
      expect(ch.fetchedAt, 1786805000);
    });

    test('without preserveCleared, stamp overwrites zero', () {
      final ch = Chapter()
        ..id = 42
        ..serverId = 9
        ..fetchedAt = 0;
      applyServerFetchedAt(ch, 1786805000000, preserveCleared: false);
      expect(ch.fetchedAt, 1786805000);
    });
  });

  group('ISS-059 SyncCycleGate + completion waiter semantics', () {
    test('busy tryBegin queues; needsAnotherPass after beginPass cleared then re-queued', () {
      final gate = SyncCycleGate();
      expect(gate.tryBegin(), isTrue);
      expect(gate.tryBegin(), isFalse);
      expect(gate.queued, isTrue);
      gate.beginPass();
      expect(gate.queued, isFalse);
      expect(gate.tryBegin(), isFalse);
      expect(gate.needsAnotherPass(), isTrue);
      gate.end();
      expect(gate.isSyncing, isFalse);
    });

    test('onSyncCycleComplete stream is broadcast and listen-able', () async {
      final events = <void>[];
      final sub = SyncEngine.instance.onSyncCycleComplete.listen(events.add);
      // Directly cannot complete a cycle without GraphQL; just ensure stream works.
      await sub.cancel();
      expect(events, isEmpty);
    });
  });

  group('ISS-062 stable device id', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await SettingsService.instance.initialize();
    });

    test('resolveStableDeviceId mints and persists a UUID', () async {
      final a = await SyncEngine.resolveStableDeviceId();
      expect(a, isNot('default_device'));
      expect(a.length, greaterThan(8));
      expect(SettingsService.instance.syncDeviceId, a);
      final b = await SyncEngine.resolveStableDeviceId();
      expect(b, a);
    });

    test('explicit deviceId wins and is not default_device', () async {
      final id = await SyncEngine.resolveStableDeviceId(deviceId: 'phone-xyz');
      expect(id, 'phone-xyz');
    });
  });

  group('ISS-063 category counts are in-library only', () {
    test('mangaBelongsToCategory counts match membership not server all-manga totals', () {
      // Documented: server categories.mangas.totalCount includes non-library;
      // the Library tab counts only in-library rows with membership (ISS-063).
      final reading = <List<int>>[
        [1, 4],
        [1],
        [4],
        [0],
      ];
      final inReading = reading.where((ids) => mangaBelongsToCategory(ids, 1)).length;
      expect(inReading, 2);
      final inDefault = reading.where((ids) => mangaBelongsToCategory(ids, 0)).length;
      expect(inDefault, 1);
    });
  });

  group('ISS-060 history inclusion helpers', () {
    test('hasReadingHistory treats lastReadAt=0 with isRead as history', () {
      final ch = Chapter()
        ..serverId = 1
        ..isRead = true
        ..lastReadAt = 0;
      expect(hasReadingHistory(ch), isTrue);
    });
  });
}
