import 'package:isar/isar.dart';

part 'category.g.dart';

@collection
class Category {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  int serverId = 0;

  String name = '';
  int order = 0;
  bool isDefault = false;

  Category();
}
