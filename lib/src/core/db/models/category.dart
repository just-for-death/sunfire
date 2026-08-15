import 'package:isar/isar.dart';

part 'category.g.dart';

@collection
class Category {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late int serverId;

  late String name;
  late int order;
  bool isDefault = false;

  Category();
}
