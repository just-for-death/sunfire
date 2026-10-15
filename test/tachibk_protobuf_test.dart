import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/backup/tachibk_import_service.dart';
import 'package:sunfire/src/core/backup/tachibk_parser.dart';

/// Tiny protobuf writer for the fields Mihon's backup uses.
class _Pb {
  final _b = BytesBuilder();

  void _varint(int v) {
    var x = v;
    while (true) {
      if (x >= 0 && x < 0x80) {
        _b.addByte(x);
        return;
      }
      _b.addByte((x & 0x7F) | 0x80);
      x = x >>> 7;
    }
  }

  void int64(int field, int v) {
    _varint(field << 3);
    _varint(v);
  }

  void bytes(int field, List<int> v) {
    _varint((field << 3) | 2);
    _varint(v.length);
    _b.add(v);
  }

  void str(int field, String v) => bytes(field, utf8.encode(v));
  void msg(int field, _Pb m) => bytes(field, m.done());
  void fixed32(int field) {
    _varint((field << 3) | 5);
    _b.add(const [1, 2, 3, 4]);
  }

  Uint8List done() => _b.toBytes();
}

Uint8List _mihonBackup() {
  final root = _Pb()
    ..msg(1, _Pb()
      ..int64(1, 2499283573021220255) // MangaDex (en) source id
      ..str(2, '/manga/abc')
      ..str(3, 'Favorite One')
      ..int64(17, 2)
      ..int64(17, 0)
      ..fixed32(18)) // unknown fixed field must be skipped
    ..msg(1, _Pb()
      ..int64(1, 42)
      ..str(2, '/m/2')
      ..str(3, 'Not In Library')
      ..int64(100, 0))
    ..msg(2, _Pb()
      ..str(1, 'Reading')
      ..int64(2, 2))
    ..msg(2, _Pb()
      ..str(1, 'Default-ish')
      ..int64(2, 0))
    ..msg(101, _Pb()
      ..str(1, 'MangaDex')
      ..int64(2, 2499283573021220255));
  return Uint8List.fromList(gzip.encode(root.done()));
}

void main() {
  test('parses a gzip+protobuf backup as Mihon writes it', () {
    final backup = TachiBkParser.parseBytes(_mihonBackup());

    expect(backup.categories, ['Default-ish', 'Reading'], reason: 'sorted by order');
    expect(backup.sources.single.name, 'MangaDex');
    expect(backup.sources.single.id, 2499283573021220255);

    final first = backup.manga.first;
    expect(first.title, 'Favorite One');
    expect(first.url, '/manga/abc');
    expect(first.sourceId, 2499283573021220255);
    expect(first.favorite, isTrue, reason: 'proto default when omitted');
    expect(first.categories, ['Reading', 'Default-ish'], reason: 'mapped by category order');

    expect(backup.manga[1].favorite, isFalse);
    expect(backup.manga[1].categories, isEmpty);
  });

  test('packed repeated category orders are accepted', () {
    final root = _Pb()
      ..msg(1, _Pb()
        ..int64(1, 1)
        ..str(3, 'Packed')
        ..bytes(17, const [1, 3]))
      ..msg(2, _Pb()..str(1, 'A')..int64(2, 1))
      ..msg(2, _Pb()..str(1, 'B')..int64(2, 3));
    final backup = TachiBkParser.parseBytes(Uint8List.fromList(gzip.encode(root.done())));
    expect(backup.manga.single.categories, ['A', 'B']);
  });

  test('a gzip bomb is refused at the uncompressed limit', () {
    final big = Uint8List(TachiBkParser.kMaxUncompressedBytes + 1);
    final bomb = Uint8List.fromList(gzip.encode(big));
    expect(() => TachiBkParser.parseBytes(bomb), throwsA(isA<TachiBkParseException>()));
  });

  test('a protobuf backup matches server sources by id', () {
    final backup = TachiBkParser.parseBytes(_mihonBackup());
    final plan = TachiBkImportService.planImport(backup, const [
      ServerSourceInfo(id: '1', name: 'MangaDex', displayName: 'MangaDex (JA)', lang: 'ja'),
      ServerSourceInfo(id: '2499283573021220255', name: 'MangaDex', displayName: 'MangaDex (EN)', lang: 'en'),
    ]);
    expect(plan.entries.first.matchedSource?.lang, 'en');
    expect(plan.entries.first.status, TachiBkPlanEntryStatus.ready);
  });
}
