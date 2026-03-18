// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_category_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$categoryListQueryHash() => r'020895a910380c647c83a5a44f9814cb72b7a7bd';

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

/// See also [categoryListQuery].
@ProviderFor(categoryListQuery)
const categoryListQueryProvider = CategoryListQueryFamily();

/// See also [categoryListQuery].
class CategoryListQueryFamily extends Family<List<CategoryDto>?> {
  /// See also [categoryListQuery].
  const CategoryListQueryFamily();

  /// See also [categoryListQuery].
  CategoryListQueryProvider call({
    required String query,
  }) {
    return CategoryListQueryProvider(
      query: query,
    );
  }

  @override
  CategoryListQueryProvider getProviderOverride(
    covariant CategoryListQueryProvider provider,
  ) {
    return call(
      query: provider.query,
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
  String? get name => r'categoryListQueryProvider';
}

/// See also [categoryListQuery].
class CategoryListQueryProvider
    extends AutoDisposeProvider<List<CategoryDto>?> {
  /// See also [categoryListQuery].
  CategoryListQueryProvider({
    required String query,
  }) : this._internal(
          (ref) => categoryListQuery(
            ref as CategoryListQueryRef,
            query: query,
          ),
          from: categoryListQueryProvider,
          name: r'categoryListQueryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$categoryListQueryHash,
          dependencies: CategoryListQueryFamily._dependencies,
          allTransitiveDependencies:
              CategoryListQueryFamily._allTransitiveDependencies,
          query: query,
        );

  CategoryListQueryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final String query;

  @override
  Override overrideWith(
    List<CategoryDto>? Function(CategoryListQueryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CategoryListQueryProvider._internal(
        (ref) => create(ref as CategoryListQueryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<CategoryDto>?> createElement() {
    return _CategoryListQueryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CategoryListQueryProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CategoryListQueryRef on AutoDisposeProviderRef<List<CategoryDto>?> {
  /// The parameter `query` of this provider.
  String get query;
}

class _CategoryListQueryProviderElement
    extends AutoDisposeProviderElement<List<CategoryDto>?>
    with CategoryListQueryRef {
  _CategoryListQueryProviderElement(super.provider);

  @override
  String get query => (origin as CategoryListQueryProvider).query;
}

String _$nonZeroCategoryListHash() =>
    r'e7e9ca19544f7788b969a8590b5608f612e4f44f';

/// See also [nonZeroCategoryList].
@ProviderFor(nonZeroCategoryList)
final nonZeroCategoryListProvider =
    AutoDisposeProvider<AsyncValue<List<CategoryDto>?>>.internal(
  nonZeroCategoryList,
  name: r'nonZeroCategoryListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$nonZeroCategoryListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NonZeroCategoryListRef
    = AutoDisposeProviderRef<AsyncValue<List<CategoryDto>?>>;
String _$categoryControllerHash() =>
    r'b640d88bc43da0b85c39ba9ea0b27cc6f7fd3b01';

/// See also [CategoryController].
@ProviderFor(CategoryController)
final categoryControllerProvider = AutoDisposeAsyncNotifierProvider<
    CategoryController, List<CategoryDto>?>.internal(
  CategoryController.new,
  name: r'categoryControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$categoryControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CategoryController = AutoDisposeAsyncNotifier<List<CategoryDto>?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
