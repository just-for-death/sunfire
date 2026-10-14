/// ISS-088: copy tracker bindings during migration with per-bind error
/// isolation. One failing bind no longer aborts the rest, and every failure
/// is returned so the caller can surface it.
class TrackCopyFailure {
  final int trackerId;
  final String remoteId;
  final Object error;
  const TrackCopyFailure(this.trackerId, this.remoteId, this.error);
  @override
  String toString() => 'tracker $trackerId ($remoteId): $error';
}

class TrackCopyResult {
  final int copied;
  final List<TrackCopyFailure> failures;
  const TrackCopyResult(this.copied, this.failures);
  bool get hasFailures => failures.isNotEmpty;
}

typedef TrackBindFn = Future<void> Function(int trackerId, String remoteId);

int _toInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;

/// Binds each valid node in [nodes] via [bind]; never throws per node.
Future<TrackCopyResult> copyTrackBindings(List<dynamic> nodes, TrackBindFn bind) async {
  var copied = 0;
  final failures = <TrackCopyFailure>[];
  for (final tr in nodes) {
    if (tr is! Map) continue;
    final trackerId = _toInt(tr['trackerId']);
    final remoteId = tr['remoteId']?.toString() ?? tr['id']?.toString();
    if (trackerId <= 0 || remoteId == null) continue;
    try {
      await bind(trackerId, remoteId);
      copied++;
    } catch (e) {
      failures.add(TrackCopyFailure(trackerId, remoteId, e));
    }
  }
  return TrackCopyResult(copied, failures);
}
