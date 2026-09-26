
/// Why an extension-issued HTTP request was refused, or null when it is fine.
///
/// The QuickJS `Client` bridge is a global inside the scraper sandbox and the
/// whole response body is handed back to the script. That combination is a
/// read primitive with an exfiltration channel, and the code on the other end
/// is downloaded from a repo index and auto-installed without review. A scraper
/// is only ever supposed to talk to the manga site it was written for, so the
/// default answer for anything that is not a public host is "no".
///
/// Refused:
///  - anything that is not http/https (`file:`, `ftp:`, `gopher:`,
///    `data:`, … — `data:` in particular is not a network fetch but does hand
///    the script arbitrary content);
///  - loopback, so a script cannot read the app's own FlareSolverr or any
///    locally-running service;
///  - RFC1918 private ranges and carrier-grade NAT, i.e. the user's LAN;
///  - link-local, which is where the `169.254.169.254` cloud metadata endpoint
///    lives on most networks;
///  - the unspecified address, and IPv6 loopback / unique-local / link-local;
///  - bare and dot-suffixed `.local` / `.internal` / `.home.arpa` names, which
///    are the mDNS and split-horizon names for the same hosts.
///
/// Deliberately NOT refused: public addresses, including a hostname that
/// resolves to one. A hostname cannot be classified without DNS, and resolving
/// it here would both leak the lookup to a third party and be trivially bypassed
/// by rebinding between the check and the request. Hostnames are covered by the
/// literal-name rules above; a hostile publisher who controls DNS already owns
/// a public host, which is not the escalation being prevented here.
String? blockedRequestReason(Uri uri) {
  final scheme = uri.scheme.toLowerCase();
  if (scheme != 'http' && scheme != 'https') return 'scheme "$scheme" is not http(s)';

  final host = uri.host.toLowerCase();
  if (host.isEmpty) return 'no host';

  // Strip the IPv6 brackets Dart keeps in `host` for authority-form URIs.
  final bare = host.startsWith('[') && host.endsWith(']')
      ? host.substring(1, host.length - 1)
      : host;

  if (_blockedNames.contains(bare)) return 'host "$bare" is local';

  if (bare.endsWith('.local') ||
      bare.endsWith('.internal') ||
      bare.endsWith('.localhost') ||
      bare.endsWith('.home.arpa')) {
    return 'host "$bare" is a local-network name';
  }

  // IPv6 literals. Anything not in the allow-listed global range is refused:
  // ::1 loopback, fc00::/7 unique-local, fe80::/10 link-local, :: unspecified.
  if (bare.contains(':')) {
    if (_isBlockedIpv6(bare)) return 'host "$bare" is local';
    return null;
  }

  // IPv4 literals.
  final octets = _parseIpv4(bare);
  if (octets != null) {
    if (_isBlockedIpv4(octets)) return 'host "$bare" is a private or local address';
    return null;
  }

  // Not an IP literal, so it is a DNS name. Two shapes are refused because
  // neither can be a public site:
  //
  //  - a single label ("intranet", "router"). No public hostname has no dot,
  //    so this is always a split-horizon or mDNS name.
  //  - all-numeric labels ("010.0.0.1", "127.0.0.01", "999.1.1.1"). These are
  //    malformed or legacy-encoded IPv4. Parsing them leniently would let
  //    010.0.0.1 through as if it were a public address when a stack that
  //    accepts the octal form resolves it to 10.0.0.1; ignoring them entirely
  //    would treat private space as a hostname and allow it.
  final labels = bare.split('.');
  if (labels.length == 1) return 'host "$bare" is a single-label intranet name';
  final allNumeric = labels.every((l) => l.isNotEmpty && _isAllDigits(l));
  if (allNumeric) return 'host "$bare" is a malformed IP literal';

  return null;
}

bool _isAllDigits(String value) {
  for (final c in value.codeUnits) {
    if (c < 0x30 || c > 0x39) return false;
  }
  return true;
}

const Set<String> _blockedNames = <String>{
  'localhost',
  'localhost.localdomain',
  'ip6-localhost',
  'ip6-loopback',
  '0.0.0.0',
  '::',
  '::1',
  'broadcasthost',
};

/// Parses a dotted-quad IPv4 literal, returning null when [host] is not one.
///
/// Rejects anything with a leading zero or a wrong component count, so
/// `010.0.0.1` and `1.2.3` are treated as hostnames rather than being
/// silently coerced into an address a check would then wave through.
List<int>? _parseIpv4(String host) {
  final parts = host.split('.');
  if (parts.length != 4) return null;
  final out = <int>[];
  for (final part in parts) {
    if (part.isEmpty || part.length > 3) return null;
    for (final c in part.codeUnits) {
      if (c < 0x30 || c > 0x39) return null;
    }
    if (part.length > 1 && part.startsWith('0')) return null;
    final value = int.tryParse(part);
    if (value == null || value > 255) return null;
    out.add(value);
  }
  return out;
}

bool _isBlockedIpv4(List<int> o) {
  // 0.0.0.0/8 — "this network"
  if (o[0] == 0) return true;
  // 127.0.0.0/8 — loopback
  if (o[0] == 127) return true;
  // 10.0.0.0/8 — private
  if (o[0] == 10) return true;
  // 172.16.0.0/12 — private
  if (o[0] == 172 && o[1] >= 16 && o[1] <= 31) return true;
  // 192.168.0.0/16 — private
  if (o[0] == 192 && o[1] == 168) return true;
  // 169.254.0.0/16 — link-local, where cloud metadata lives
  if (o[0] == 169 && o[1] == 254) return true;
  // 100.64.0.0/10 — carrier-grade NAT
  if (o[0] == 100 && o[1] >= 64 && o[1] <= 127) return true;
  // 192.0.0.0/24 and 198.18.0.0/15 — protocol assignments / benchmarking
  if (o[0] == 192 && o[1] == 0 && o[2] == 0) return true;
  if (o[0] == 198 && (o[1] == 18 || o[1] == 19)) return true;
  // 224.0.0.0/4 multicast and 240.0.0.0/4 reserved
  if (o[0] >= 224) return true;
  return false;
}

bool _isBlockedIpv6(String host) {
  final lower = host.toLowerCase();

  // Strip a zone id ("fe80::1%eth0") before comparing.
  final zoneIndex = lower.indexOf('%');
  final h = zoneIndex == -1 ? lower : lower.substring(0, zoneIndex);

  if (h == '::1' || h == '::') return true;
  // IPv4-mapped (::ffff:127.0.0.1) — check the embedded v4.
  final mapped = RegExp(r'::ffff:(\d+\.\d+\.\d+\.\d+)$').firstMatch(h);
  if (mapped != null) {
    final octets = _parseIpv4(mapped.group(1)!);
    return octets == null || _isBlockedIpv4(octets);
  }
  // fc00::/7 unique-local, fe80::/10 link-local.
  if (h.startsWith('fc') || h.startsWith('fd')) return true;
  if (h.startsWith('fe8') || h.startsWith('fe9') || h.startsWith('fea') || h.startsWith('feb')) return true;
  // ff00::/8 multicast.
  if (h.startsWith('ff')) return true;
  return false;
}
