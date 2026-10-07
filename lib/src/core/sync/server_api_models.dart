// Thin value types for server / WebUI version endpoints (ISS-084 B13) and
// per-operation network policy (ISS-075 B12). Kept free of Flutter imports so
// they are trivially unit-testable.

import 'dart:math' as math;

/// Network policy class for a GraphQL operation (ISS-075).
///
/// Only [read], [slowRead] and [scrapeRead] are retried — they are idempotent.
/// [write] (and anything that changes user state) is never retried, so a
/// timed-out mutation that actually landed cannot be applied twice.
enum GraphQLOp {
  /// Cheap reachability probe: short timeouts, no retry.
  probe,

  /// Ordinary query (library, chapters, settings…): 30s receive, 2 retries.
  read,

  /// Read that makes the server call out (GitHub update checks): 90s, 1 retry.
  slowRead,

  /// Server-side source scrape (`fetchChapterPages`, `fetchMangaAndChapters`,
  /// `fetchSourceManga`). Idempotent despite being GraphQL mutations; the
  /// server may sit in FlareSolverr for `flareSolverrTimeout` (default 73s),
  /// so receive = that + 30s headroom. 1 retry.
  scrapeRead,

  /// State-changing mutation: 30s receive, never retried.
  write,
}

class GraphQLOpPolicy {
  final Duration send;
  final Duration receive;
  final int maxRetries;
  const GraphQLOpPolicy({required this.send, required this.receive, required this.maxRetries});
}

/// Default FlareSolverr solve timeout on Suwayomi (seconds).
const int kDefaultFlareSolverrTimeoutSeconds = 73;

/// Resolves the timeout/retry policy for [op]. [flareSolverrTimeoutSeconds]
/// comes from server settings when known.
GraphQLOpPolicy policyForOp(GraphQLOp op, {int flareSolverrTimeoutSeconds = kDefaultFlareSolverrTimeoutSeconds}) {
  switch (op) {
    case GraphQLOp.probe:
      return const GraphQLOpPolicy(send: Duration(seconds: 3), receive: Duration(seconds: 3), maxRetries: 0);
    case GraphQLOp.read:
      return const GraphQLOpPolicy(send: Duration(seconds: 15), receive: Duration(seconds: 30), maxRetries: 2);
    case GraphQLOp.slowRead:
      return const GraphQLOpPolicy(send: Duration(seconds: 15), receive: Duration(seconds: 90), maxRetries: 1);
    case GraphQLOp.scrapeRead:
      final fs = math.max(kDefaultFlareSolverrTimeoutSeconds, flareSolverrTimeoutSeconds);
      return GraphQLOpPolicy(
        send: const Duration(seconds: 15),
        receive: Duration(seconds: fs + 30),
        maxRetries: 1,
      );
    case GraphQLOp.write:
      return const GraphQLOpPolicy(send: Duration(seconds: 15), receive: Duration(seconds: 30), maxRetries: 0);
  }
}

/// Infers the op class when a caller did not pass one: `mutation` → [GraphQLOp.write],
/// anything else (query / `{ … }` shorthand) → [GraphQLOp.read].
GraphQLOp inferGraphQLOp(String document) {
  final t = document.trimLeft();
  return t.startsWith('mutation') ? GraphQLOp.write : GraphQLOp.read;
}

/// Jittered exponential backoff for retry [attempt] (1-based):
/// 400ms·2^(attempt-1) + [0, 300)ms.
Duration jitteredBackoff(int attempt, {math.Random? random}) {
  final r = random ?? math.Random();
  final base = 400 * (1 << (attempt - 1).clamp(0, 6));
  return Duration(milliseconds: base + r.nextInt(300));
}

/// `checkForServerUpdates` entry.
class ServerUpdateInfo {
  final String channel;
  final String tag;
  final String url;
  const ServerUpdateInfo({required this.channel, required this.tag, required this.url});
  factory ServerUpdateInfo.fromMap(Map<String, dynamic> m) => ServerUpdateInfo(
        channel: m['channel']?.toString() ?? '',
        tag: m['tag']?.toString() ?? '',
        url: m['url']?.toString() ?? '',
      );
}

/// `aboutWebUI`.
class WebUIInfo {
  final String channel;
  final String tag;
  /// Raw LongString (epoch ms) as sent by the server; null when absent.
  final int? updateTimestamp;
  const WebUIInfo({required this.channel, required this.tag, this.updateTimestamp});
  factory WebUIInfo.fromMap(Map<String, dynamic> m) => WebUIInfo(
        channel: m['channel']?.toString() ?? '',
        tag: m['tag']?.toString() ?? '',
        updateTimestamp: int.tryParse(m['updateTimestamp']?.toString() ?? ''),
      );
}

/// `getWebUIUpdateStatus`. [state] is IDLE | DOWNLOADING | FINISHED | ERROR.
class WebUIUpdateStatusInfo {
  final String state;
  final int progress;
  final String channel;
  final String tag;
  const WebUIUpdateStatusInfo({required this.state, required this.progress, required this.channel, required this.tag});
  bool get isError => state == 'ERROR';
  bool get isDownloading => state == 'DOWNLOADING';
  factory WebUIUpdateStatusInfo.fromMap(Map<String, dynamic> m) {
    final info = m['info'] is Map ? Map<String, dynamic>.from(m['info'] as Map) : const <String, dynamic>{};
    final p = m['progress'];
    return WebUIUpdateStatusInfo(
      state: m['state']?.toString() ?? 'IDLE',
      progress: p is num ? p.toInt() : int.tryParse(p?.toString() ?? '') ?? 0,
      channel: info['channel']?.toString() ?? '',
      tag: info['tag']?.toString() ?? '',
    );
  }
}

/// `checkForWebUIUpdate`.
class WebUIUpdateCheckInfo {
  final String channel;
  final String tag;
  final bool updateAvailable;
  const WebUIUpdateCheckInfo({required this.channel, required this.tag, required this.updateAvailable});
  factory WebUIUpdateCheckInfo.fromMap(Map<String, dynamic> m) => WebUIUpdateCheckInfo(
        channel: m['channel']?.toString() ?? '',
        tag: m['tag']?.toString() ?? '',
        updateAvailable: m['updateAvailable'] == true,
      );
}

/// Bundle returned by `GraphQLClientService.fetchServerVersionBundle`.
class ServerVersionBundle {
  /// Raw `aboutServer` map: name, version, buildType, buildTime, github, discord.
  final Map<String, dynamic>? aboutServer;
  final WebUIInfo? webUI;
  final WebUIUpdateStatusInfo? webUIUpdateStatus;
  /// Only populated when `includeUpdateCheck: true`.
  final List<ServerUpdateInfo>? serverUpdates;
  const ServerVersionBundle({this.aboutServer, this.webUI, this.webUIUpdateStatus, this.serverUpdates});
  String? get serverVersion => aboutServer?['version']?.toString();
  String? get buildType => aboutServer?['buildType']?.toString();
  String? get serverPlatform => aboutServer?['platform']?.toString();
  bool get hasServerUpdate => serverUpdates != null && serverUpdates!.isNotEmpty;
}

/// Download-queue item state helpers (ISS-080). `state` is
/// QUEUED | DOWNLOADING | FINISHED | ERROR.
bool isDownloadItemError(Map<String, dynamic> item) => item['state']?.toString() == 'ERROR';

int downloadItemTries(Map<String, dynamic> item) {
  final t = item['tries'];
  return t is num ? t.toInt() : int.tryParse(t?.toString() ?? '') ?? 0;
}

/// Builds the `reorders` variable for `reorderChapterDownloads` (clamps `to` ≥ 0).
List<Map<String, int>> buildDownloadReorderVariables(List<({int chapterId, int to})> reorders) => [
      for (final r in reorders) {'chapterId': r.chapterId, 'to': r.to < 0 ? 0 : r.to},
    ];

/// One-line About / Server settings summary (ISS-084 / B13).
String serverVersionSummaryLabel({
  String? version,
  String? buildType,
  String? webUIChannel,
  String? webUITag,
  String? serverPlatform,
}) {
  if (version == null || version.isEmpty) return 'Server version unknown';
  final type = (buildType == null || buildType.isEmpty) ? '' : ' ($buildType)';
  final plat = (serverPlatform == null || serverPlatform.isEmpty) ? '' : ' · $serverPlatform';
  final webBits = <String>[
    if (webUIChannel != null && webUIChannel.isNotEmpty) webUIChannel,
    if (webUITag != null && webUITag.isNotEmpty) webUITag,
  ];
  final web = webBits.isEmpty ? '' : '; WebUI ${webBits.join(' ')}';
  return 'Server v$version$type$plat$web';
}
