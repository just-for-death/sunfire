import 'package:isar/isar.dart';

part 'sync_meta.g.dart';

@collection
class SyncMeta {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String key;

  late String value;

  SyncMeta();
}
