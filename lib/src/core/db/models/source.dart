import 'package:isar/isar.dart';

part 'source.g.dart';

@collection
class Source {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String sourceId;

  late String name;
  late String lang;
  String? jsCode;
  String? baseUrl;
  String? version;
  String? repoUrl;
  bool isServerOnly = false;

  Source();
}
