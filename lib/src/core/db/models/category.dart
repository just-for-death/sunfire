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

  /// Suwayomi `isDefaultCategory` (server v2.4.2366+, "in preparation of
  /// incompatible changes"). Read when the server exposes it; until then the
  /// legacy `default` flag above remains the source of truth.
  bool isDefaultCategory = false;

  /// Suwayomi `IncludeOrExclude`: INCLUDE | EXCLUDE | UNSET (ISS-071).
  String includeInUpdate = 'UNSET';

  /// Suwayomi `IncludeOrExclude`: INCLUDE | EXCLUDE | UNSET (ISS-071).
  String includeInDownload = 'UNSET';

  Category();
}
