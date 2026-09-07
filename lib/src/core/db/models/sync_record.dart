import 'package:isar/isar.dart';

part 'sync_record.g.dart';

enum SyncEntityType { manga, chapter, category, tracker, source }
enum SyncAction { create, update, delete }
enum SyncRecordState { pending, inFlight, synced, failed, abandoned }

@collection
class SyncRecord {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String recordId = '';

  @Enumerated(EnumType.name)
  SyncEntityType entityType = SyncEntityType.manga;

  String entityId = '';

  @Enumerated(EnumType.name)
  SyncAction action = SyncAction.update;

  String payloadJson = '{}';
  int timestamp = 0;
  String deviceId = '';

  @Enumerated(EnumType.name)
  SyncRecordState state = SyncRecordState.pending;

  int retryCount = 0;

  SyncRecord();
}
