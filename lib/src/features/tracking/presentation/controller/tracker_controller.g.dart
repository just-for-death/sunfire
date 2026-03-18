// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracker_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$trackersHash() => r'5eacea4e874bb9302015513ac64e741f79df00e5';

/// All available tracker services
///
/// Copied from [trackers].
@ProviderFor(trackers)
final trackersProvider = AutoDisposeFutureProvider<List<TrackerDto>>.internal(
  trackers,
  name: r'trackersProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$trackersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TrackersRef = AutoDisposeFutureProviderRef<List<TrackerDto>>;
String _$trackerAuthNotifierHash() =>
    r'81ec5a9ad26511d4dcb2149097f0eaa884e67f46';

/// Notifier that handles tracker login/logout mutations and refreshes state
///
/// Copied from [TrackerAuthNotifier].
@ProviderFor(TrackerAuthNotifier)
final trackerAuthNotifierProvider =
    AutoDisposeNotifierProvider<TrackerAuthNotifier, AsyncValue<void>>.internal(
  TrackerAuthNotifier.new,
  name: r'trackerAuthNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$trackerAuthNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TrackerAuthNotifier = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
