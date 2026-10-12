import 'package:isar_community/isar.dart';

part 'sync_meta.g.dart';

@collection
class SyncMeta {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String key = '';

  String value = '';

  /// Unix timestamp (seconds) of the last successful sync
  int? lastSyncTimestamp;

  SyncMeta();
}