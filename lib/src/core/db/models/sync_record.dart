import 'package:isar/isar.dart';

part 'sync_record.g.dart';

enum SyncEntityType { manga, chapter, category, tracker, source }
enum SyncAction { create, update, delete }
enum SyncRecordState { pending, inFlight, synced, failed, abandoned }

@collection
class SyncRecord {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String recordId;

  @Enumerated(EnumType.name)
  late SyncEntityType entityType;

  late String entityId;

  @Enumerated(EnumType.name)
  late SyncAction action;

  late String payloadJson;
  late int timestamp;
  late String deviceId;

  @Enumerated(EnumType.name)
  late SyncRecordState state;

  int retryCount = 0;

  SyncRecord();
}
