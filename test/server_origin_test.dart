import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/sync/graphql_client_service.dart';

void main() {
  test('isSameOrigin rejects prefix look-alikes that a startsWith check accepted', () {
    const server = 'https://srv.com';
    expect(isSameOrigin(server, 'https://srv.com/api/v1/manga/1/thumbnail'), isTrue);
    expect(isSameOrigin(server, 'https://SRV.com:443/x'), isTrue);
    expect(isSameOrigin(server, 'https://srv.com.evil.net/x'), isFalse);
    expect(isSameOrigin(server, 'http://srv.com/x'), isFalse);
    expect(isSameOrigin('http://10.0.0.2:4567', 'http://10.0.0.2:45678/x'), isFalse);
    expect(isSameOrigin('http://10.0.0.2:4567', 'http://10.0.0.2:4567/api'), isTrue);
  });
}
