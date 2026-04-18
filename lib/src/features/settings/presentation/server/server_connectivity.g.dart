// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_connectivity.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$serverConnectivityHttpGetHash() =>
    r'1fccabef5c6bd017f6a1bc3aeae4b7839d949745';

/// HTTP GET for server reachability checks. Override in tests to mock responses.
///
/// Copied from [serverConnectivityHttpGet].
@ProviderFor(serverConnectivityHttpGet)
final serverConnectivityHttpGetProvider =
    AutoDisposeProvider<Future<http.Response> Function(Uri uri)>.internal(
  serverConnectivityHttpGet,
  name: r'serverConnectivityHttpGetProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$serverConnectivityHttpGetHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ServerConnectivityHttpGetRef
    = AutoDisposeProviderRef<Future<http.Response> Function(Uri uri)>;
String _$serverConnectivityHash() =>
    r'8037735558c9158ce5720206ff607bb19695c070';

/// See also [ServerConnectivity].
@ProviderFor(ServerConnectivity)
final serverConnectivityProvider =
    AutoDisposeNotifierProvider<ServerConnectivity, ServerStatus>.internal(
  ServerConnectivity.new,
  name: r'serverConnectivityProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$serverConnectivityHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ServerConnectivity = AutoDisposeNotifier<ServerStatus>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
