import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/sync/server_api_models.dart';

void main() {
  group('serverVersionSummaryLabel (B13)', () {
    test('unknown when version missing', () {
      expect(serverVersionSummaryLabel(), 'Server version unknown');
    });

    test('version and buildType', () {
      expect(
        serverVersionSummaryLabel(version: '2.4.2379', buildType: 'Preview'),
        'Server v2.4.2379 (Preview)',
      );
    });

    test('includes WebUI channel/tag', () {
      expect(
        serverVersionSummaryLabel(
          version: '2.4.2366',
          buildType: 'Stable',
          webUIChannel: 'STABLE',
          webUITag: 'r1627',
        ),
        'Server v2.4.2366 (Stable); WebUI STABLE r1627',
      );
    });
  });
}
