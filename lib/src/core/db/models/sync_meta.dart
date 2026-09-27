import 'package:isar_community/isar.dart';

part 'sync_meta.g.dart';

@collection
class SyncMeta {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String key = '';

  String value = '';

  SyncMeta();
}
