// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'source_preference_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$baseSourcePreferenceListHash() =>
    r'601d51825a166c0fca26ccf6662a044e88c5e0c5';

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

/// See also [baseSourcePreferenceList].
@ProviderFor(baseSourcePreferenceList)
const baseSourcePreferenceListProvider = BaseSourcePreferenceListFamily();

/// See also [baseSourcePreferenceList].
class BaseSourcePreferenceListFamily
    extends Family<AsyncValue<List<SourcePreference>?>> {
  /// See also [baseSourcePreferenceList].
  const BaseSourcePreferenceListFamily();

  /// See also [baseSourcePreferenceList].
  BaseSourcePreferenceListProvider call(
    String sourceId,
  ) {
    return BaseSourcePreferenceListProvider(
      sourceId,
    );
  }

  @override
  BaseSourcePreferenceListProvider getProviderOverride(
    covariant BaseSourcePreferenceListProvider provider,
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
  String? get name => r'baseSourcePreferenceListProvider';
}

/// See also [baseSourcePreferenceList].
class BaseSourcePreferenceListProvider
    extends AutoDisposeFutureProvider<List<SourcePreference>?> {
  /// See also [baseSourcePreferenceList].
  BaseSourcePreferenceListProvider(
    String sourceId,
  ) : this._internal(
          (ref) => baseSourcePreferenceList(
            ref as BaseSourcePreferenceListRef,
            sourceId,
          ),
          from: baseSourcePreferenceListProvider,
          name: r'baseSourcePreferenceListProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$baseSourcePreferenceListHash,
          dependencies: BaseSourcePreferenceListFamily._dependencies,
          allTransitiveDependencies:
              BaseSourcePreferenceListFamily._allTransitiveDependencies,
          sourceId: sourceId,
        );

  BaseSourcePreferenceListProvider._internal(
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
    FutureOr<List<SourcePreference>?> Function(
            BaseSourcePreferenceListRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BaseSourcePreferenceListProvider._internal(
        (ref) => create(ref as BaseSourcePreferenceListRef),
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
  AutoDisposeFutureProviderElement<List<SourcePreference>?> createElement() {
    return _BaseSourcePreferenceListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BaseSourcePreferenceListProvider &&
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
mixin BaseSourcePreferenceListRef
    on AutoDisposeFutureProviderRef<List<SourcePreference>?> {
  /// The parameter `sourceId` of this provider.
  String get sourceId;
}

class _BaseSourcePreferenceListProviderElement
    extends AutoDisposeFutureProviderElement<List<SourcePreference>?>
    with BaseSourcePreferenceListRef {
  _BaseSourcePreferenceListProviderElement(super.provider);

  @override
  String get sourceId => (origin as BaseSourcePreferenceListProvider).sourceId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
