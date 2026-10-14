// IMP-009: decode-size helper.
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/features/reader/controller/reader_decode_size.dart';

void main() {
  test('width x dpr x headroom, rounded up', () {
    expect(readerDecodeCacheWidth(400, 2.0), 1600);
    expect(readerDecodeCacheWidth(400, 2.5, zoomHeadroom: 1), 1000);
  });
  test('capped at maxCacheWidth', () {
    expect(readerDecodeCacheWidth(3000, 3.0), 4096);
  });
  test('unknown or invalid width decodes at full size (null)', () {
    expect(readerDecodeCacheWidth(null, 2), isNull);
    expect(readerDecodeCacheWidth(0, 2), isNull);
    expect(readerDecodeCacheWidth(double.infinity, 2), isNull);
  });
  test('non-positive dpr falls back to 1', () {
    expect(readerDecodeCacheWidth(100, 0), 200);
  });
}
