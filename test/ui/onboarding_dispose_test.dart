// UIS-08: friendlyNetworkError mapping (dispose mid-request covered by mounted guards).
import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/features/shared/friendly_network_error.dart';

void main() {
  test('friendlyNetworkError maps common failures', () {
    expect(
      friendlyNetworkError(TimeoutException('x'), tag: 't'),
      'Timed out',
    );
    expect(
      friendlyNetworkError(
        const SocketException('Connection refused'),
        tag: 't',
      ),
      'Connection refused',
    );
    expect(
      friendlyNetworkError(
        const SocketException('Failed host lookup: example.com'),
        tag: 't',
      ),
      'Host not found',
    );
    expect(
      friendlyNetworkError(const HandshakeException('bad cert'), tag: 't'),
      'TLS/certificate error',
    );
    expect(friendlyNetworkError(StateError('nope'), tag: 't'), 'Unexpected error');
  });
}
