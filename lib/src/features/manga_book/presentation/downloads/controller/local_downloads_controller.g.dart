// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_downloads_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$localChapterDownloadHash() =>
    r'1b5b9e01fcf9f3f4e548f92b3f0978cfc19791bb';

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

abstract class _$LocalChapterDownload
    extends BuildlessAutoDisposeNotifier<LocalDownloadState> {
  late final int chapterId;

  LocalDownloadState build({
    required int chapterId,
  });
}

/// See also [LocalChapterDownload].
@ProviderFor(LocalChapterDownload)
const localChapterDownloadProvider = LocalChapterDownloadFamily();

/// See also [LocalChapterDownload].
class LocalChapterDownloadFamily extends Family<LocalDownloadState> {
  /// See also [LocalChapterDownload].
  const LocalChapterDownloadFamily();

  /// See also [LocalChapterDownload].
  LocalChapterDownloadProvider call({
    required int chapterId,
  }) {
    return LocalChapterDownloadProvider(
      chapterId: chapterId,
    );
  }

  @override
  LocalChapterDownloadProvider getProviderOverride(
    covariant LocalChapterDownloadProvider provider,
  ) {
    return call(
      chapterId: provider.chapterId,
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
  String? get name => r'localChapterDownloadProvider';
}

/// See also [LocalChapterDownload].
class LocalChapterDownloadProvider extends AutoDisposeNotifierProviderImpl<
    LocalChapterDownload, LocalDownloadState> {
  /// See also [LocalChapterDownload].
  LocalChapterDownloadProvider({
    required int chapterId,
  }) : this._internal(
          () => LocalChapterDownload()..chapterId = chapterId,
          from: localChapterDownloadProvider,
          name: r'localChapterDownloadProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$localChapterDownloadHash,
          dependencies: LocalChapterDownloadFamily._dependencies,
          allTransitiveDependencies:
              LocalChapterDownloadFamily._allTransitiveDependencies,
          chapterId: chapterId,
        );

  LocalChapterDownloadProvider._internal(
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
  LocalDownloadState runNotifierBuild(
    covariant LocalChapterDownload notifier,
  ) {
    return notifier.build(
      chapterId: chapterId,
    );
  }

  @override
  Override overrideWith(LocalChapterDownload Function() create) {
    return ProviderOverride(
      origin: this,
      override: LocalChapterDownloadProvider._internal(
        () => create()..chapterId = chapterId,
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
  AutoDisposeNotifierProviderElement<LocalChapterDownload, LocalDownloadState>
      createElement() {
    return _LocalChapterDownloadProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LocalChapterDownloadProvider &&
        other.chapterId == chapterId;
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
mixin LocalChapterDownloadRef
    on AutoDisposeNotifierProviderRef<LocalDownloadState> {
  /// The parameter `chapterId` of this provider.
  int get chapterId;
}

class _LocalChapterDownloadProviderElement
    extends AutoDisposeNotifierProviderElement<LocalChapterDownload,
        LocalDownloadState> with LocalChapterDownloadRef {
  _LocalChapterDownloadProviderElement(super.provider);

  @override
  int get chapterId => (origin as LocalChapterDownloadProvider).chapterId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
