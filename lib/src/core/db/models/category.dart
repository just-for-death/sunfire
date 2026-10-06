import 'package:isar_community/isar.dart';

part 'category.g.dart';

@collection
class Category {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  int serverId = 0;

  String name = '';
  int order = 0;
  bool isDefault = false;

  /// Suwayomi `IncludeOrExclude`: INCLUDE | EXCLUDE | UNSET (ISS-071).
  String includeInUpdate = 'UNSET';

  /// Suwayomi `IncludeOrExclude`: INCLUDE | EXCLUDE | UNSET (ISS-071).
  String includeInDownload = 'UNSET';

  Category();
}
