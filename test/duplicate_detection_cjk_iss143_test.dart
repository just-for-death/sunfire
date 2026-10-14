// ISS-143: duplicate detection normalised titles to [a-z0-9] only, so CJK
// titles became '' and never matched (and '' == '' could match via the
// chapter-overlap rule). It now uses normalizeMangaTitle.
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/db/models/manga.dart';
import 'package:sunfire/src/core/library/duplicate_detection_service.dart';
import 'package:sunfire/src/core/services/library_matching.dart';

Manga _m(int id, String title, {int chapters = 0}) => Manga()
  ..serverId = id
  ..title = title
  ..url = ''
  ..chapterCount = chapters;

void main() {
  final svc = DuplicateDetectionService.instance;

  test('Japanese title pair matches (trailing space, full-width forms)', () {
    expect(svc.debugAreDuplicates(_m(1, 'ワンピース'), _m(2, 'ワンピース ')), isTrue);
    expect(svc.debugAreDuplicates(_m(1, 'ワンピース'), _m(2, 'ワンピース　')), isTrue);
    expect(svc.debugAreDuplicates(_m(1, 'One Piece'), _m(2, 'ＯＮＥ　ＰＩＥＣＥ')), isTrue);
    expect(normalizeMangaTitle('ＯＮＥ　ＰＩＥＣＥ'), 'one piece');
  });

  test('different CJK titles do not match', () {
    expect(svc.debugAreDuplicates(_m(1, 'ワンピース'), _m(2, 'ワンパンマン')), isFalse);
    expect(svc.debugAreDuplicates(_m(1, '進撃の巨人'), _m(2, '鬼滅の刃')), isFalse);
  });

  test('empty normalized titles never match, even with chapter overlap', () {
    expect(svc.debugAreDuplicates(_m(1, '!!!', chapters: 10), _m(2, '???', chapters: 10)), isFalse);
    expect(svc.debugAreDuplicates(_m(1, ''), _m(2, '')), isFalse);
  });
}
