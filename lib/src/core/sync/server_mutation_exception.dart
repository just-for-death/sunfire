/// Thrown by GraphQLClientService mutation helpers when the server did not
/// apply a mutation (GraphQL `errors`, validation failure, transport failure,
/// or client not configured). Callers must treat this as "nothing changed on
/// the server" and must not commit / must roll back local state.
class ServerMutationException implements Exception {
  /// Mutation label, e.g. `bindTrack`, `updateMangaLibraryState`.
  final String operation;

  /// True when the failure was a transport problem (timeout, 5xx, dropped
  /// connection) — the action may succeed if retried later. False means the
  /// server rejected it (validation / GraphQL error / not configured).
  final bool isTransportFailure;

  const ServerMutationException(this.operation, {this.isTransportFailure = false});

  /// Short user-facing message UIS can show directly.
  String get userMessage => isTransportFailure
      ? 'Could not reach the server. Please try again.'
      : 'The server rejected this change.';

  @override
  String toString() =>
      'ServerMutationException($operation, transport: $isTransportFailure)';
}
