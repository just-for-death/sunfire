// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'migration_source_manga_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$migrationSourceMangaListHash() =>
    r'2f8f8c6ea9178420e39993f1efdae1f9f6448619';

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

/// See also [migrationSourceMangaList].
@ProviderFor(migrationSourceMangaList)
const migrationSourceMangaListProvider = MigrationSourceMangaListFamily();

/// See also [migrationSourceMangaList].
class MigrationSourceMangaListFamily
    extends Family<AsyncValue<List<MangaDto>>> {
  /// See also [migrationSourceMangaList].
  const MigrationSourceMangaListFamily();

  /// See also [migrationSourceMangaList].
  MigrationSourceMangaListProvider call(
    String sourceId,
  ) {
    return MigrationSourceMangaListProvider(
      sourceId,
    );
  }

  @override
  MigrationSourceMangaListProvider getProviderOverride(
    covariant MigrationSourceMangaListProvider provider,
  ) {
    return call(
      provider.sourceId,
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
  String? get name => r'migrationSourceMangaListProvider';
}

/// See also [migrationSourceMangaList].
class MigrationSourceMangaListProvider
    extends AutoDisposeFutureProvider<List<MangaDto>> {
  /// See also [migrationSourceMangaList].
  MigrationSourceMangaListProvider(
    String sourceId,
  ) : this._internal(
          (ref) => migrationSourceMangaList(
            ref as MigrationSourceMangaListRef,
            sourceId,
          ),
          from: migrationSourceMangaListProvider,
          name: r'migrationSourceMangaListProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$migrationSourceMangaListHash,
          dependencies: MigrationSourceMangaListFamily._dependencies,
          allTransitiveDependencies:
              MigrationSourceMangaListFamily._allTransitiveDependencies,
          sourceId: sourceId,
        );

  MigrationSourceMangaListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.sourceId,
  }) : super.internal();

  final String sourceId;

  @override
  Override overrideWith(
    FutureOr<List<MangaDto>> Function(MigrationSourceMangaListRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MigrationSourceMangaListProvider._internal(
        (ref) => create(ref as MigrationSourceMangaListRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        sourceId: sourceId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<MangaDto>> createElement() {
    return _MigrationSourceMangaListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MigrationSourceMangaListProvider &&
        other.sourceId == sourceId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, sourceId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MigrationSourceMangaListRef
    on AutoDisposeFutureProviderRef<List<MangaDto>> {
  /// The parameter `sourceId` of this provider.
  String get sourceId;
}

class _MigrationSourceMangaListProviderElement
    extends AutoDisposeFutureProviderElement<List<MangaDto>>
    with MigrationSourceMangaListRef {
  _MigrationSourceMangaListProviderElement(super.provider);

  @override
  String get sourceId => (origin as MigrationSourceMangaListProvider).sourceId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
