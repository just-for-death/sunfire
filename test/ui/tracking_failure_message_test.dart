import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/sync/server_mutation_exception.dart';
import 'package:sunfire/src/features/manga_detail/tracking_bottom_sheet.dart';

void main() {
  test('transport failure says server unreachable', () {
    final m = trackingFailureMessage("Couldn't link tracker",
        const ServerMutationException('bindTrack', isTransportFailure: true));
    expect(m, "Couldn't link tracker. Could not reach the server. Please try again.");
  });
  test('server rejection says rejected', () {
    final m = trackingFailureMessage("Couldn't unlink tracker", const ServerMutationException('unbindTrack'));
    expect(m, contains('rejected'));
  });
  test('other errors get generic retry text', () {
    expect(trackingFailureMessage("Couldn't update tracker", Exception('x')),
        "Couldn't update tracker. Please try again.");
  });
}
