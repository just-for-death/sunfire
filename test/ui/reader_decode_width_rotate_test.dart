import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/features/reader/controller/reader_page_widget.dart';

void main() {
  test('no rotation uses the screen width', () {
    expect(decodeLogicalWidth(imageWidth: null, maxWidth: 400, maxHeight: 900, mayRotate: false), 400);
  });
  test('rotation enabled sizes for the longer side', () {
    expect(decodeLogicalWidth(imageWidth: null, maxWidth: 400, maxHeight: 900, mayRotate: true), 900);
  });
  test('landscape keeps width when it is longer', () {
    expect(decodeLogicalWidth(imageWidth: null, maxWidth: 1200, maxHeight: 700, mayRotate: true), 1200);
  });
  test('unbounded height falls back to width', () {
    expect(decodeLogicalWidth(imageWidth: null, maxWidth: 400, maxHeight: double.infinity, mayRotate: true), 400);
  });
}
