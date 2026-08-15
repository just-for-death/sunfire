import 'package:isar/isar.dart';

part 'manga.g.dart';

@collection
class Manga {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  int serverId = 0;

  String title = '';
  String? artist;
  String? author;
  String? description;
  List<String> genres = [];
  String? status;
  
  bool inLibrary = false;
  int? inLibraryAt;
  
  List<int> categoryIds = [];
  
  String sourceName = '';
  String lang = '';
  String url = '';
  String? thumbnailUrl;
  
  int? lastFetchedAt;
  int? unreadCount;

  Manga();
}
