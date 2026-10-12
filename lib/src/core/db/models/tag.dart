import 'package:isar_community/isar.dart';

part 'tag.g.dart';

/// User-defined custom tag for manga.
@collection
class Tag {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String name = '';

  /// Hex color string (e.g., "#FF5722").
  String color = '#FF5722';

  /// Creation timestamp (Unix ms).
  int createdAt = 0;

  /// Whether this tag is user-created (vs system-generated).
  bool isUserCreated = true;

  Tag();
}