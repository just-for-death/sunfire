import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/services/image_cache_helper.dart';

void main() {
  test('a cover URL on a local address is refused before any request', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    var hits = 0;
    server.listen((req) {
      hits++;
      req.response
        ..statusCode = 200
        ..add(const [0xFF, 0xD8, 0xFF, 0xE0]);
      unawaited(req.response.close());
    });
    addTearDown(() => server.close(force: true));

    final bytes = await ImageCacheHelper.attemptHttpFetch(
      'http://127.0.0.1:${server.port}/cover.jpg',
      const {'Cookie': 'session=1'},
    );
    expect(bytes, isNull);
    expect(hits, 0);
  });
}
