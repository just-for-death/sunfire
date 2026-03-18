// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'migration_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$migrationSourceQuickSearchMangaListHash() =>
    r'9dfaddde9264ce09ea177029b0777287a15e8132';

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

/// See also [migrationSourceQuickSearchMangaList].
@ProviderFor(migrationSourceQuickSearchMangaList)
const migrationSourceQuickSearchMangaListProvider =
    MigrationSourceQuickSearchMangaListFamily();

/// See also [migrationSourceQuickSearchMangaList].
class MigrationSourceQuickSearchMangaListFamily
    extends Family<AsyncValue<List<MangaDto>>> {
  /// See also [migrationSourceQuickSearchMangaList].
  const MigrationSourceQuickSearchMangaListFamily();

  /// See also [migrationSourceQuickSearchMangaList].
  MigrationSourceQuickSearchMangaListProvider call(
    String sourceId, {
    String? query,
  }) {
    return MigrationSourceQuickSearchMangaListProvider(
      sourceId,
      query: query,
    );
  }

  @override
  MigrationSourceQuickSearchMangaListProvider getProviderOverride(
    covariant MigrationSourceQuickSearchMangaListProvider provider,
  ) {
    return call(
      provider.sourceId,
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
  String? get name => r'migrationSourceQuickSearchMangaListProvider';
}

/// See also [migrationSourceQuickSearchMangaList].
class MigrationSourceQuickSearchMangaListProvider
    extends AutoDisposeFutureProvider<List<MangaDto>> {
  /// See also [migrationSourceQuickSearchMangaList].
  MigrationSourceQuickSearchMangaListProvider(
    String sourceId, {
    String? query,
  }) : this._internal(
          (ref) => migrationSourceQuickSearchMangaList(
            ref as MigrationSourceQuickSearchMangaListRef,
            sourceId,
            query: query,
          ),
          from: migrationSourceQuickSearchMangaListProvider,
          name: r'migrationSourceQuickSearchMangaListProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$migrationSourceQuickSearchMangaListHash,
          dependencies: MigrationSourceQuickSearchMangaListFamily._dependencies,
          allTransitiveDependencies: MigrationSourceQuickSearchMangaListFamily
              ._allTransitiveDependencies,
          sourceId: sourceId,
          query: query,
        );

  MigrationSourceQuickSearchMangaListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.sourceId,
    required this.query,
  }) : super.internal();

  final String sourceId;
  final String? query;

  @override
  Override overrideWith(
    FutureOr<List<MangaDto>> Function(
            MigrationSourceQuickSearchMangaListRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MigrationSourceQuickSearchMangaListProvider._internal(
        (ref) => create(ref as MigrationSourceQuickSearchMangaListRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        sourceId: sourceId,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<MangaDto>> createElement() {
    return _MigrationSourceQuickSearchMangaListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MigrationSourceQuickSearchMangaListProvider &&
        other.sourceId == sourceId &&
        other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, sourceId.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MigrationSourceQuickSearchMangaListRef
    on AutoDisposeFutureProviderRef<List<MangaDto>> {
  /// The parameter `sourceId` of this provider.
  String get sourceId;

  /// The parameter `query` of this provider.
  String? get query;
}

class _MigrationSourceQuickSearchMangaListProviderElement
    extends AutoDisposeFutureProviderElement<List<MangaDto>>
    with MigrationSourceQuickSearchMangaListRef {
  _MigrationSourceQuickSearchMangaListProviderElement(super.provider);

  @override
  String get sourceId =>
      (origin as MigrationSourceQuickSearchMangaListProvider).sourceId;
  @override
  String? get query =>
      (origin as MigrationSourceQuickSearchMangaListProvider).query;
}

String _$migrationGlobalSearchResultsHash() =>
    r'87e65d01ab45a502e5c3ae9d5d955579160e3a5b';

/// See also [migrationGlobalSearchResults].
@ProviderFor(migrationGlobalSearchResults)
const migrationGlobalSearchResultsProvider =
    MigrationGlobalSearchResultsFamily();

/// See also [migrationGlobalSearchResults].
class MigrationGlobalSearchResultsFamily
    extends Family<AsyncValue<List<MigrationQuickSearchResults>>> {
  /// See also [migrationGlobalSearchResults].
  const MigrationGlobalSearchResultsFamily();

  /// See also [migrationGlobalSearchResults].
  MigrationGlobalSearchResultsProvider call({
    String? query,
  }) {
    return MigrationGlobalSearchResultsProvider(
      query: query,
    );
  }

  @override
  MigrationGlobalSearchResultsProvider getProviderOverride(
    covariant MigrationGlobalSearchResultsProvider provider,
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
  String? get name => r'migrationGlobalSearchResultsProvider';
}

/// See also [migrationGlobalSearchResults].
class MigrationGlobalSearchResultsProvider
    extends AutoDisposeProvider<AsyncValue<List<MigrationQuickSearchResults>>> {
  /// See also [migrationGlobalSearchResults].
  MigrationGlobalSearchResultsProvider({
    String? query,
  }) : this._internal(
          (ref) => migrationGlobalSearchResults(
            ref as MigrationGlobalSearchResultsRef,
            query: query,
          ),
          from: migrationGlobalSearchResultsProvider,
          name: r'migrationGlobalSearchResultsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$migrationGlobalSearchResultsHash,
          dependencies: MigrationGlobalSearchResultsFamily._dependencies,
          allTransitiveDependencies:
              MigrationGlobalSearchResultsFamily._allTransitiveDependencies,
          query: query,
        );

  MigrationGlobalSearchResultsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final String? query;

  @override
  Override overrideWith(
    AsyncValue<List<MigrationQuickSearchResults>> Function(
            MigrationGlobalSearchResultsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MigrationGlobalSearchResultsProvider._internal(
        (ref) => create(ref as MigrationGlobalSearchResultsRef),
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
  AutoDisposeProviderElement<AsyncValue<List<MigrationQuickSearchResults>>>
      createElement() {
    return _MigrationGlobalSearchResultsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MigrationGlobalSearchResultsProvider &&
        other.query == query;
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
mixin MigrationGlobalSearchResultsRef
    on AutoDisposeProviderRef<AsyncValue<List<MigrationQuickSearchResults>>> {
  /// The parameter `query` of this provider.
  String? get query;
}

class _MigrationGlobalSearchResultsProviderElement
    extends AutoDisposeProviderElement<
        AsyncValue<List<MigrationQuickSearchResults>>>
    with MigrationGlobalSearchResultsRef {
  _MigrationGlobalSearchResultsProviderElement(super.provider);

  @override
  String? get query => (origin as MigrationGlobalSearchResultsProvider).query;
}

String _$migrationSourcesHash() => r'2808536b81fd53cf0c4bad7fc198250eeda5fc13';

abstract class _$MigrationSources
    extends BuildlessAutoDisposeAsyncNotifier<List<MigrationSource>?> {
  late final int mangaId;

  FutureOr<List<MigrationSource>?> build({
    required int mangaId,
  });
}

/// See also [MigrationSources].
@ProviderFor(MigrationSources)
const migrationSourcesProvider = MigrationSourcesFamily();

/// See also [MigrationSources].
class MigrationSourcesFamily
    extends Family<AsyncValue<List<MigrationSource>?>> {
  /// See also [MigrationSources].
  const MigrationSourcesFamily();

  /// See also [MigrationSources].
  MigrationSourcesProvider call({
    required int mangaId,
  }) {
    return MigrationSourcesProvider(
      mangaId: mangaId,
    );
  }

  @override
  MigrationSourcesProvider getProviderOverride(
    covariant MigrationSourcesProvider provider,
  ) {
    return call(
      mangaId: provider.mangaId,
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
  String? get name => r'migrationSourcesProvider';
}

/// See also [MigrationSources].
class MigrationSourcesProvider extends AutoDisposeAsyncNotifierProviderImpl<
    MigrationSources, List<MigrationSource>?> {
  /// See also [MigrationSources].
  MigrationSourcesProvider({
    required int mangaId,
  }) : this._internal(
          () => MigrationSources()..mangaId = mangaId,
          from: migrationSourcesProvider,
          name: r'migrationSourcesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$migrationSourcesHash,
          dependencies: MigrationSourcesFamily._dependencies,
          allTransitiveDependencies:
              MigrationSourcesFamily._allTransitiveDependencies,
          mangaId: mangaId,
        );

  MigrationSourcesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.mangaId,
  }) : super.internal();

  final int mangaId;

  @override
  FutureOr<List<MigrationSource>?> runNotifierBuild(
    covariant MigrationSources notifier,
  ) {
    return notifier.build(
      mangaId: mangaId,
    );
  }

  @override
  Override overrideWith(MigrationSources Function() create) {
    return ProviderOverride(
      origin: this,
      override: MigrationSourcesProvider._internal(
        () => create()..mangaId = mangaId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        mangaId: mangaId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<MigrationSources,
      List<MigrationSource>?> createElement() {
    return _MigrationSourcesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MigrationSourcesProvider && other.mangaId == mangaId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, mangaId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MigrationSourcesRef
    on AutoDisposeAsyncNotifierProviderRef<List<MigrationSource>?> {
  /// The parameter `mangaId` of this provider.
  int get mangaId;
}

class _MigrationSourcesProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<MigrationSources,
        List<MigrationSource>?> with MigrationSourcesRef {
  _MigrationSourcesProviderElement(super.provider);

  @override
  int get mangaId => (origin as MigrationSourcesProvider).mangaId;
}

String _$migrationSearchHash() => r'ad7a5714f045976d1251453e72125036f0483901';

abstract class _$MigrationSearch
    extends BuildlessAutoDisposeAsyncNotifier<List<Fragment$MangaDto>?> {
  late final String sourceId;
  late final String query;

  FutureOr<List<Fragment$MangaDto>?> build({
    required String sourceId,
    required String query,
  });
}

/// See also [MigrationSearch].
@ProviderFor(MigrationSearch)
const migrationSearchProvider = MigrationSearchFamily();

/// See also [MigrationSearch].
class MigrationSearchFamily
    extends Family<AsyncValue<List<Fragment$MangaDto>?>> {
  /// See also [MigrationSearch].
  const MigrationSearchFamily();

  /// See also [MigrationSearch].
  MigrationSearchProvider call({
    required String sourceId,
    required String query,
  }) {
    return MigrationSearchProvider(
      sourceId: sourceId,
      query: query,
    );
  }

  @override
  MigrationSearchProvider getProviderOverride(
    covariant MigrationSearchProvider provider,
  ) {
    return call(
      sourceId: provider.sourceId,
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
  String? get name => r'migrationSearchProvider';
}

/// See also [MigrationSearch].
class MigrationSearchProvider extends AutoDisposeAsyncNotifierProviderImpl<
    MigrationSearch, List<Fragment$MangaDto>?> {
  /// See also [MigrationSearch].
  MigrationSearchProvider({
    required String sourceId,
    required String query,
  }) : this._internal(
          () => MigrationSearch()
            ..sourceId = sourceId
            ..query = query,
          from: migrationSearchProvider,
          name: r'migrationSearchProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$migrationSearchHash,
          dependencies: MigrationSearchFamily._dependencies,
          allTransitiveDependencies:
              MigrationSearchFamily._allTransitiveDependencies,
          sourceId: sourceId,
          query: query,
        );

  MigrationSearchProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.sourceId,
    required this.query,
  }) : super.internal();

  final String sourceId;
  final String query;

  @override
  FutureOr<List<Fragment$MangaDto>?> runNotifierBuild(
    covariant MigrationSearch notifier,
  ) {
    return notifier.build(
      sourceId: sourceId,
      query: query,
    );
  }

  @override
  Override overrideWith(MigrationSearch Function() create) {
    return ProviderOverride(
      origin: this,
      override: MigrationSearchProvider._internal(
        () => create()
          ..sourceId = sourceId
          ..query = query,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        sourceId: sourceId,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<MigrationSearch,
      List<Fragment$MangaDto>?> createElement() {
    return _MigrationSearchProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MigrationSearchProvider &&
        other.sourceId == sourceId &&
        other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, sourceId.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MigrationSearchRef
    on AutoDisposeAsyncNotifierProviderRef<List<Fragment$MangaDto>?> {
  /// The parameter `sourceId` of this provider.
  String get sourceId;

  /// The parameter `query` of this provider.
  String get query;
}

class _MigrationSearchProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<MigrationSearch,
        List<Fragment$MangaDto>?> with MigrationSearchRef {
  _MigrationSearchProviderElement(super.provider);

  @override
  String get sourceId => (origin as MigrationSearchProvider).sourceId;
  @override
  String get query => (origin as MigrationSearchProvider).query;
}

String _$migrationExecutionHash() =>
    r'ac63e3c08b57f2f47230ba3caffc01da50295744';

/// See also [MigrationExecution].
@ProviderFor(MigrationExecution)
final migrationExecutionProvider = AutoDisposeNotifierProvider<
    MigrationExecution, MigrationProgress?>.internal(
  MigrationExecution.new,
  name: r'migrationExecutionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$migrationExecutionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MigrationExecution = AutoDisposeNotifier<MigrationProgress?>;
String _$migrationSearchQueryHash() =>
    r'1ad1acb7b94e0ef15139d8747be601fa63b2d45a';

/// See also [MigrationSearchQuery].
@ProviderFor(MigrationSearchQuery)
final migrationSearchQueryProvider =
    AutoDisposeNotifierProvider<MigrationSearchQuery, String>.internal(
  MigrationSearchQuery.new,
  name: r'migrationSearchQueryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$migrationSearchQueryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MigrationSearchQuery = AutoDisposeNotifier<String>;
String _$selectedMigrationSourceHash() =>
    r'b5f3db5903ec6d9601f08b3d9527359182cf23e5';

/// See also [SelectedMigrationSource].
@ProviderFor(SelectedMigrationSource)
final selectedMigrationSourceProvider = AutoDisposeNotifierProvider<
    SelectedMigrationSource, MigrationSource?>.internal(
  SelectedMigrationSource.new,
  name: r'selectedMigrationSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedMigrationSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedMigrationSource = AutoDisposeNotifier<MigrationSource?>;
String _$selectedTargetMangaHash() =>
    r'294e00c9a3501747596985ac830e58a97d4234f6';

/// See also [SelectedTargetManga].
@ProviderFor(SelectedTargetManga)
final selectedTargetMangaProvider = AutoDisposeNotifierProvider<
    SelectedTargetManga, Fragment$MangaDto?>.internal(
  SelectedTargetManga.new,
  name: r'selectedTargetMangaProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedTargetMangaHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedTargetManga = AutoDisposeNotifier<Fragment$MangaDto?>;
String _$migrationOptionsHash() => r'a6561ac3966c6d170aaa32939e9771bbbcb2583e';

/// See also [MigrationOptions].
@ProviderFor(MigrationOptions)
final migrationOptionsProvider =
    AutoDisposeNotifierProvider<MigrationOptions, MigrationOption>.internal(
  MigrationOptions.new,
  name: r'migrationOptionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$migrationOptionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MigrationOptions = AutoDisposeNotifier<MigrationOption>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
