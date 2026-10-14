// IMP-003: smart library-update restrictions.
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunfire/src/core/db/models/manga.dart';
import 'package:sunfire/src/core/services/settings_service.dart';
import 'package:sunfire/src/core/services/update_restrictions.dart';

Manga _m(int id, {String? status, int? unread, int? lastRead}) => Manga()
  ..id = id
  ..status = status
  ..unreadCount = unread
  ..lastReadAt = lastRead;

void main() {
  final all = [
    _m(1, status: 'COMPLETED', lastRead: 5),
    _m(2, status: 'ONGOING', unread: 3, lastRead: 5),
    _m(3, status: 'ongoing'),
    _m(4, status: 'Finished', unread: 0, lastRead: 9),
    _m(5, unread: 0, lastRead: 1),
  ];
  List<int> ids(List<Manga> l) => l.map((m) => m.id).toList();

  test('no restrictions keeps everything', () {
    final r = applyUpdateRestrictions(all);
    expect(ids(r.keep), [1, 2, 3, 4, 5]);
    expect(r.skipped, 0);
  });

  test('each restriction filters its own titles', () {
    expect(ids(applyUpdateRestrictions(all, skipCompleted: true).keep), [2, 3, 5]);
    expect(ids(applyUpdateRestrictions(all, skipWithUnread: true).keep), [1, 3, 4, 5]);
    expect(ids(applyUpdateRestrictions(all, skipNotStarted: true).keep), [1, 2, 4, 5]);
    final r = applyUpdateRestrictions(all, skipCompleted: true, skipWithUnread: true, skipNotStarted: true);
    expect(ids(r.keep), [5]);
    expect(r.skipped, 4);
  });

  test('completed status matching is case-insensitive and null-safe', () {
    expect(isCompletedMangaStatus('PUBLISHING_FINISHED'), isTrue);
    expect(isCompletedMangaStatus(' cancelled '), isTrue);
    expect(isCompletedMangaStatus('ONGOING'), isFalse);
    expect(isCompletedMangaStatus(null), isFalse);
  });

  test('settings default off and persist', () async {
    SharedPreferences.setMockInitialValues({});
    final s = SettingsService.instance;
    await s.initialize();
    expect([s.updateSkipCompleted, s.updateSkipWithUnread, s.updateSkipNotStarted], [false, false, false]);
    s.updateSkipCompleted = true;
    s.updateSkipNotStarted = true;
    final p = await SharedPreferences.getInstance();
    expect(p.getBool('update_skip_completed'), isTrue);
    expect(p.getBool('update_skip_not_started'), isTrue);
    expect(s.updateSkipWithUnread, isFalse);
  });
}
