// IMP-030: typed server results. A null map from GraphQLClientService.query
// used to mean "something went wrong"; ServerResult says what.
import 'package:flutter/foundation.dart';

enum ServerFailureKind {
  /// Not configured / no server URL.
  notConfigured,

  /// Network, timeout, 5xx: worth retrying.
  transport,

  /// The server answered and refused (GraphQL errors, empty data).
  rejected,
}

@immutable
class ServerFailure {
  const ServerFailure(this.kind, [this.message]);
  final ServerFailureKind kind;
  final String? message;

  bool get isRetryable => kind == ServerFailureKind.transport;

  @override
  String toString() => 'ServerFailure(${kind.name}${message == null ? '' : ': $message'})';
}

sealed class ServerResult<T> {
  const ServerResult();

  bool get isOk => this is ServerOk<T>;
  T? get valueOrNull => switch (this) { ServerOk(:final value) => value, ServerErr() => null };
  ServerFailure? get failureOrNull => switch (this) { ServerOk() => null, ServerErr(:final failure) => failure };

  ServerResult<R> map<R>(R Function(T value) f) => switch (this) {
        ServerOk(:final value) => ServerOk(f(value)),
        ServerErr(:final failure) => ServerErr(failure),
      };
}

final class ServerOk<T> extends ServerResult<T> {
  const ServerOk(this.value);
  final T value;
}

final class ServerErr<T> extends ServerResult<T> {
  const ServerErr(this.failure);
  final ServerFailure failure;
}

/// Converts the legacy classification record into a typed result.
ServerResult<Map<String, dynamic>> classifyServerResponse(
  ({Map<String, dynamic>? data, bool wasTransportFailure}) r, {
  bool configured = true,
  String? label,
}) {
  if (!configured) return ServerErr(ServerFailure(ServerFailureKind.notConfigured, label));
  final data = r.data;
  if (data != null) return ServerOk(data);
  return ServerErr(ServerFailure(
    r.wasTransportFailure ? ServerFailureKind.transport : ServerFailureKind.rejected,
    label,
  ));
}

extension ServerClassificationX on ({Map<String, dynamic>? data, bool wasTransportFailure}) {
  ServerResult<Map<String, dynamic>> toServerResult({String? label}) => classifyServerResponse(this, label: label);
}
