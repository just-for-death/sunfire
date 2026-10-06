// UIX-06 (Jane decision A): certificate pinning is hidden this release.
// The old pin check gave no protection (it only ran for certs that had
// already failed CA validation, and compared whole-DER hashes to SPKI pins),
// so no UI may offer it and no client may receive a pin list.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/services/server_tls_trust.dart';

void main() {
  test('Advanced settings shows no certificate pinning UI', () {
    final src = File('lib/src/features/settings/advanced_settings_screen.dart').readAsStringSync();
    expect(src, isNot(contains('_showCertificatePinningDialog')));
    expect(src, isNot(contains('Certificate Pinning (SPKI)')));
    expect(src, isNot(contains('SPKI Fingerprint')));
    expect(src, isNot(contains('certificatePins')));
  });

  test('no lib code passes or reads certificate pins', () {
    final offenders = <String>[];
    for (final f in Directory('lib').listSync(recursive: true).whereType<File>()) {
      if (!f.path.endsWith('.dart')) continue;
      final src = f.readAsStringSync();
      if (src.contains('certificatePins') || src.contains('validateCertificatePin')) {
        offenders.add(f.path);
      }
    }
    expect(offenders, isEmpty);
  });

  test('server-trusting client still applies host-based self-signed trust', () {
    final client = createServerTrustingHttpClient(() => 'https://manga.example.lan:4567');
    addTearDown(() => client.close(force: true));
    // badCertificateCallback delegates to shouldTrustCertificateForHost.
    expect(shouldTrustCertificateForHost('manga.example.lan', 'https://manga.example.lan:4567'), isTrue);
    expect(shouldTrustCertificateForHost('evil.example.com', 'https://manga.example.lan:4567'), isFalse);
  });
}
