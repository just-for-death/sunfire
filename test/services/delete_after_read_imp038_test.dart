// IMP-038: delete-after-read offset + exclude bookmarked.
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunfire/src/core/db/models/chapter.dart';
import 'package:sunfire/src/core/services/delete_after_read.dart';
import 'package:sunfire/src/core/services/settings_service.dart';

Chapter _c(int n, {bool read = true, bool bookmarked = false}) => Chapter()
  ..id = n
  ..serverId = n
  ..isRead = read
  ..isBookmarked = bookmarked;

void main() {
  final chapters = [_c(1), _c(2, bookmarked: true), _c(3), _c(4, read: false)];

  test('offset 0 deletes the finished chapter', () {
    final t = chapterToDeleteAfterRead(
        finished: chapters[2], sortedSiblings: chapters, offset: 0, excludeBookmarked: true);
    expect(t?.serverId, 3);
  });

  test('offset N keeps the N latest read chapters', () {
    final t = chapterToDeleteAfterRead(
        finished: chapters[2], sortedSiblings: chapters, offset: 2, excludeBookmarked: true);
    expect(t?.serverId, 1);
    expect(
        chapterToDeleteAfterRead(
            finished: chapters[0], sortedSiblings: chapters, offset: 1, excludeBookmarked: true),
        isNull,
        reason: 'nothing before the first chapter');
  });

  test('exclude bookmarked protects the target; off allows it', () {
    expect(
        chapterToDeleteAfterRead(
            finished: chapters[2], sortedSiblings: chapters, offset: 1, excludeBookmarked: true),
        isNull);
    expect(
        chapterToDeleteAfterRead(
                finished: chapters[2], sortedSiblings: chapters, offset: 1, excludeBookmarked: false)
            ?.serverId,
        2);
  });

  test('an unread target is never deleted', () {
    final list = [_c(1, read: false), _c(2)];
    expect(
        chapterToDeleteAfterRead(finished: list[1], sortedSiblings: list, offset: 1, excludeBookmarked: false),
        isNull);
  });

  test('settings: offset clamps 0-4; excludeBookmarked mirrors allowDeletingBookmarked', () async {
    SharedPreferences.setMockInitialValues({});
    final s = SettingsService.instance;
    await s.initialize();
    expect(s.deleteAfterReadOffset, 0);
    s.deleteAfterReadOffset = 9;
    expect(s.deleteAfterReadOffset, 4);
    expect(s.deleteAfterReadExcludeBookmarked, isTrue);
    s.deleteAfterReadExcludeBookmarked = false;
    expect(s.allowDeletingBookmarkedChapters, isTrue);
  });
}
