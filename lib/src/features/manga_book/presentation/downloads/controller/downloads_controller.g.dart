// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'downloads_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$downloadUpdatesHash() => r'4b7236ca2698b472b34e055232652a1835f49949';

/// See also [downloadUpdates].
@ProviderFor(downloadUpdates)
final downloadUpdatesProvider =
    AutoDisposeStreamProvider<DownloadUpdatesDto?>.internal(
  downloadUpdates,
  name: r'downloadUpdatesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$downloadUpdatesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DownloadUpdatesRef = AutoDisposeStreamProviderRef<DownloadUpdatesDto?>;
String _$downloadStatusHash() => r'097682b067503fcb86b6b865a567e4f2731c2ad3';

/// See also [downloadStatus].
@ProviderFor(downloadStatus)
final downloadStatusProvider =
    AutoDisposeFutureProvider<DownloadStatusDto?>.internal(
  downloadStatus,
  name: r'downloadStatusProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$downloadStatusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DownloadStatusRef = AutoDisposeFutureProviderRef<DownloadStatusDto?>;
String _$downloadsFromIdHash() => r'd142a820625e34a430d8c86121df7f2f4af20e83';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [downloadsFromId].
@ProviderFor(downloadsFromId)
const downloadsFromIdProvider = DownloadsFromIdFamily();

/// See also [downloadsFromId].
class DownloadsFromIdFamily extends Family<DownloadDto?> {
  /// See also [downloadsFromId].
  const DownloadsFromIdFamily();

  /// See also [downloadsFromId].
  DownloadsFromIdProvider call(
    int chapterId,
  ) {
    return DownloadsFromIdProvider(
      chapterId,
    );
  }

  @override
  DownloadsFromIdProvider getProviderOverride(
    covariant DownloadsFromIdProvider provider,
  ) {
    return call(
      provider.chapterId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'downloadsFromIdProvider';
}

/// See also [downloadsFromId].
class DownloadsFromIdProvider extends AutoDisposeProvider<DownloadDto?> {
  /// See also [downloadsFromId].
  DownloadsFromIdProvider(
    int chapterId,
  ) : this._internal(
          (ref) => downloadsFromId(
            ref as DownloadsFromIdRef,
            chapterId,
          ),
          from: downloadsFromIdProvider,
          name: r'downloadsFromIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$downloadsFromIdHash,
          dependencies: DownloadsFromIdFamily._dependencies,
          allTransitiveDependencies:
              DownloadsFromIdFamily._allTransitiveDependencies,
          chapterId: chapterId,
        );

  DownloadsFromIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.chapterId,
  }) : super.internal();

  final int chapterId;

  @override
  Override overrideWith(
    DownloadDto? Function(DownloadsFromIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DownloadsFromIdProvider._internal(
        (ref) => create(ref as DownloadsFromIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        chapterId: chapterId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<DownloadDto?> createElement() {
    return _DownloadsFromIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DownloadsFromIdProvider && other.chapterId == chapterId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, chapterId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DownloadsFromIdRef on AutoDisposeProviderRef<DownloadDto?> {
  /// The parameter `chapterId` of this provider.
  int get chapterId;
}

class _DownloadsFromIdProviderElement
    extends AutoDisposeProviderElement<DownloadDto?> with DownloadsFromIdRef {
  _DownloadsFromIdProviderElement(super.provider);

  @override
  int get chapterId => (origin as DownloadsFromIdProvider).chapterId;
}

String _$downloadsChapterIdsHash() =>
    r'29f5eada0735f9a9a04bb52d44b8aaca39299477';

/// See also [downloadsChapterIds].
@ProviderFor(downloadsChapterIds)
final downloadsChapterIdsProvider = AutoDisposeProvider<List<int>>.internal(
  downloadsChapterIds,
  name: r'downloadsChapterIdsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$downloadsChapterIdsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DownloadsChapterIdsRef = AutoDisposeProviderRef<List<int>>;
String _$downloaderStateHash() => r'9611d58f53e65f7332b236f71bdf0736b65b19a4';

/// See also [downloaderState].
@ProviderFor(downloaderState)
final downloaderStateProvider =
    AutoDisposeProvider<AsyncValue<DownloaderState?>>.internal(
  downloaderState,
  name: r'downloaderStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$downloaderStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DownloaderStateRef
    = AutoDisposeProviderRef<AsyncValue<DownloaderState?>>;
String _$showDownloadsFABHash() => r'25df48f3c8df12a24b521b597cbc36cfa817afbe';

/// See also [showDownloadsFAB].
@ProviderFor(showDownloadsFAB)
final showDownloadsFABProvider = AutoDisposeProvider<bool>.internal(
  showDownloadsFAB,
  name: r'showDownloadsFABProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$showDownloadsFABHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ShowDownloadsFABRef = AutoDisposeProviderRef<bool>;
String _$downloadsMapHash() => r'baf5a318937f0d957a1c249800570115686dc14a';

/// See also [DownloadsMap].
@ProviderFor(DownloadsMap)
final downloadsMapProvider =
    AutoDisposeNotifierProvider<DownloadsMap, Map<int, DownloadDto>>.internal(
  DownloadsMap.new,
  name: r'downloadsMapProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$downloadsMapHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DownloadsMap = AutoDisposeNotifier<Map<int, DownloadDto>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
