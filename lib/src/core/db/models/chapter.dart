import 'package:isar/isar.dart';

part 'chapter.g.dart';

@collection
class Chapter {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  int serverId = 0;

  @Index()
  int mangaId = 0;

  String name = '';
  double chapterNumber = 0.0;
  
  bool isRead = false;
  int lastPageRead = 0;
  
  @Index()
  int? lastReadAt;
  
  int pageCount = 0;
  bool isBookmarked = false;
  
  String? scanlator;
  String? localPath;
  bool isDownloadedLocally = false;
  bool isDownloadedOnServer = false;

  bool get isDownloaded => isDownloadedLocally || isDownloadedOnServer;
  set isDownloaded(bool val) {
    isDownloadedLocally = val;
  }

  Chapter();
}
