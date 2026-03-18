// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manga_details_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$mangaScanlatorListHash() =>
    r'aa65884a0f8c44453afeffc4d13548e264a0fb40';

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

/// See also [mangaScanlatorList].
@ProviderFor(mangaScanlatorList)
const mangaScanlatorListProvider = MangaScanlatorListFamily();

/// See also [mangaScanlatorList].
class MangaScanlatorListFamily extends Family<Set<String>> {
  /// See also [mangaScanlatorList].
  const MangaScanlatorListFamily();

  /// See also [mangaScanlatorList].
  MangaScanlatorListProvider call({
    required int mangaId,
  }) {
    return MangaScanlatorListProvider(
      mangaId: mangaId,
    );
  }

  @override
  MangaScanlatorListProvider getProviderOverride(
    covariant MangaScanlatorListProvider provider,
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
  String? get name => r'mangaScanlatorListProvider';
}

/// See also [mangaScanlatorList].
class MangaScanlatorListProvider extends AutoDisposeProvider<Set<String>> {
  /// See also [mangaScanlatorList].
  MangaScanlatorListProvider({
    required int mangaId,
  }) : this._internal(
          (ref) => mangaScanlatorList(
            ref as MangaScanlatorListRef,
            mangaId: mangaId,
          ),
          from: mangaScanlatorListProvider,
          name: r'mangaScanlatorListProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$mangaScanlatorListHash,
          dependencies: MangaScanlatorListFamily._dependencies,
          allTransitiveDependencies:
              MangaScanlatorListFamily._allTransitiveDependencies,
          mangaId: mangaId,
        );

  MangaScanlatorListProvider._internal(
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
  Override overrideWith(
    Set<String> Function(MangaScanlatorListRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MangaScanlatorListProvider._internal(
        (ref) => create(ref as MangaScanlatorListRef),
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
  AutoDisposeProviderElement<Set<String>> createElement() {
    return _MangaScanlatorListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MangaScanlatorListProvider && other.mangaId == mangaId;
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
mixin MangaScanlatorListRef on AutoDisposeProviderRef<Set<String>> {
  /// The parameter `mangaId` of this provider.
  int get mangaId;
}

class _MangaScanlatorListProviderElement
    extends AutoDisposeProviderElement<Set<String>> with MangaScanlatorListRef {
  _MangaScanlatorListProviderElement(super.provider);

  @override
  int get mangaId => (origin as MangaScanlatorListProvider).mangaId;
}

String _$mangaChapterListWithFilterHash() =>
    r'70d0e80d79087bacfadd55c7d1edb5777f2b61a7';

/// See also [mangaChapterListWithFilter].
@ProviderFor(mangaChapterListWithFilter)
const mangaChapterListWithFilterProvider = MangaChapterListWithFilterFamily();

/// See also [mangaChapterListWithFilter].
class MangaChapterListWithFilterFamily
    extends Family<AsyncValue<List<ChapterDto>?>> {
  /// See also [mangaChapterListWithFilter].
  const MangaChapterListWithFilterFamily();

  /// See also [mangaChapterListWithFilter].
  MangaChapterListWithFilterProvider call({
    required int mangaId,
  }) {
    return MangaChapterListWithFilterProvider(
      mangaId: mangaId,
    );
  }

  @override
  MangaChapterListWithFilterProvider getProviderOverride(
    covariant MangaChapterListWithFilterProvider provider,
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
  String? get name => r'mangaChapterListWithFilterProvider';
}

/// See also [mangaChapterListWithFilter].
class MangaChapterListWithFilterProvider
    extends AutoDisposeProvider<AsyncValue<List<ChapterDto>?>> {
  /// See also [mangaChapterListWithFilter].
  MangaChapterListWithFilterProvider({
    required int mangaId,
  }) : this._internal(
          (ref) => mangaChapterListWithFilter(
            ref as MangaChapterListWithFilterRef,
            mangaId: mangaId,
          ),
          from: mangaChapterListWithFilterProvider,
          name: r'mangaChapterListWithFilterProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$mangaChapterListWithFilterHash,
          dependencies: MangaChapterListWithFilterFamily._dependencies,
          allTransitiveDependencies:
              MangaChapterListWithFilterFamily._allTransitiveDependencies,
          mangaId: mangaId,
        );

  MangaChapterListWithFilterProvider._internal(
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
  Override overrideWith(
    AsyncValue<List<ChapterDto>?> Function(
            MangaChapterListWithFilterRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MangaChapterListWithFilterProvider._internal(
        (ref) => create(ref as MangaChapterListWithFilterRef),
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
  AutoDisposeProviderElement<AsyncValue<List<ChapterDto>?>> createElement() {
    return _MangaChapterListWithFilterProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MangaChapterListWithFilterProvider &&
        other.mangaId == mangaId;
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
mixin MangaChapterListWithFilterRef
    on AutoDisposeProviderRef<AsyncValue<List<ChapterDto>?>> {
  /// The parameter `mangaId` of this provider.
  int get mangaId;
}

class _MangaChapterListWithFilterProviderElement
    extends AutoDisposeProviderElement<AsyncValue<List<ChapterDto>?>>
    with MangaChapterListWithFilterRef {
  _MangaChapterListWithFilterProviderElement(super.provider);

  @override
  int get mangaId => (origin as MangaChapterListWithFilterProvider).mangaId;
}

String _$firstUnreadInFilteredChapterListHash() =>
    r'c74a2960d390a97dbffb2b8077678f77fc79cce8';

/// See also [firstUnreadInFilteredChapterList].
@ProviderFor(firstUnreadInFilteredChapterList)
const firstUnreadInFilteredChapterListProvider =
    FirstUnreadInFilteredChapterListFamily();

/// See also [firstUnreadInFilteredChapterList].
class FirstUnreadInFilteredChapterListFamily extends Family<ChapterDto?> {
  /// See also [firstUnreadInFilteredChapterList].
  const FirstUnreadInFilteredChapterListFamily();

  /// See also [firstUnreadInFilteredChapterList].
  FirstUnreadInFilteredChapterListProvider call({
    required int mangaId,
  }) {
    return FirstUnreadInFilteredChapterListProvider(
      mangaId: mangaId,
    );
  }

  @override
  FirstUnreadInFilteredChapterListProvider getProviderOverride(
    covariant FirstUnreadInFilteredChapterListProvider provider,
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
  String? get name => r'firstUnreadInFilteredChapterListProvider';
}

/// See also [firstUnreadInFilteredChapterList].
class FirstUnreadInFilteredChapterListProvider
    extends AutoDisposeProvider<ChapterDto?> {
  /// See also [firstUnreadInFilteredChapterList].
  FirstUnreadInFilteredChapterListProvider({
    required int mangaId,
  }) : this._internal(
          (ref) => firstUnreadInFilteredChapterList(
            ref as FirstUnreadInFilteredChapterListRef,
            mangaId: mangaId,
          ),
          from: firstUnreadInFilteredChapterListProvider,
          name: r'firstUnreadInFilteredChapterListProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$firstUnreadInFilteredChapterListHash,
          dependencies: FirstUnreadInFilteredChapterListFamily._dependencies,
          allTransitiveDependencies:
              FirstUnreadInFilteredChapterListFamily._allTransitiveDependencies,
          mangaId: mangaId,
        );

  FirstUnreadInFilteredChapterListProvider._internal(
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
  Override overrideWith(
    ChapterDto? Function(FirstUnreadInFilteredChapterListRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FirstUnreadInFilteredChapterListProvider._internal(
        (ref) => create(ref as FirstUnreadInFilteredChapterListRef),
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
  AutoDisposeProviderElement<ChapterDto?> createElement() {
    return _FirstUnreadInFilteredChapterListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FirstUnreadInFilteredChapterListProvider &&
        other.mangaId == mangaId;
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
mixin FirstUnreadInFilteredChapterListRef
    on AutoDisposeProviderRef<ChapterDto?> {
  /// The parameter `mangaId` of this provider.
  int get mangaId;
}

class _FirstUnreadInFilteredChapterListProviderElement
    extends AutoDisposeProviderElement<ChapterDto?>
    with FirstUnreadInFilteredChapterListRef {
  _FirstUnreadInFilteredChapterListProviderElement(super.provider);

  @override
  int get mangaId =>
      (origin as FirstUnreadInFilteredChapterListProvider).mangaId;
}

String _$getNextAndPreviousChaptersHash() =>
    r'7c6460c72af5b8d633268e97204c3d01cd3843e2';

/// See also [getNextAndPreviousChapters].
@ProviderFor(getNextAndPreviousChapters)
const getNextAndPreviousChaptersProvider = GetNextAndPreviousChaptersFamily();

/// See also [getNextAndPreviousChapters].
class GetNextAndPreviousChaptersFamily
    extends Family<({ChapterDto? first, ChapterDto? second})?> {
  /// See also [getNextAndPreviousChapters].
  const GetNextAndPreviousChaptersFamily();

  /// See also [getNextAndPreviousChapters].
  GetNextAndPreviousChaptersProvider call({
    required int mangaId,
    required int chapterId,
    bool shouldAscSort = true,
  }) {
    return GetNextAndPreviousChaptersProvider(
      mangaId: mangaId,
      chapterId: chapterId,
      shouldAscSort: shouldAscSort,
    );
  }

  @override
  GetNextAndPreviousChaptersProvider getProviderOverride(
    covariant GetNextAndPreviousChaptersProvider provider,
  ) {
    return call(
      mangaId: provider.mangaId,
      chapterId: provider.chapterId,
      shouldAscSort: provider.shouldAscSort,
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
  String? get name => r'getNextAndPreviousChaptersProvider';
}

/// See also [getNextAndPreviousChapters].
class GetNextAndPreviousChaptersProvider
    extends AutoDisposeProvider<({ChapterDto? first, ChapterDto? second})?> {
  /// See also [getNextAndPreviousChapters].
  GetNextAndPreviousChaptersProvider({
    required int mangaId,
    required int chapterId,
    bool shouldAscSort = true,
  }) : this._internal(
          (ref) => getNextAndPreviousChapters(
            ref as GetNextAndPreviousChaptersRef,
            mangaId: mangaId,
            chapterId: chapterId,
            shouldAscSort: shouldAscSort,
          ),
          from: getNextAndPreviousChaptersProvider,
          name: r'getNextAndPreviousChaptersProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$getNextAndPreviousChaptersHash,
          dependencies: GetNextAndPreviousChaptersFamily._dependencies,
          allTransitiveDependencies:
              GetNextAndPreviousChaptersFamily._allTransitiveDependencies,
          mangaId: mangaId,
          chapterId: chapterId,
          shouldAscSort: shouldAscSort,
        );

  GetNextAndPreviousChaptersProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.mangaId,
    required this.chapterId,
    required this.shouldAscSort,
  }) : super.internal();

  final int mangaId;
  final int chapterId;
  final bool shouldAscSort;

  @override
  Override overrideWith(
    ({ChapterDto? first, ChapterDto? second})? Function(
            GetNextAndPreviousChaptersRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GetNextAndPreviousChaptersProvider._internal(
        (ref) => create(ref as GetNextAndPreviousChaptersRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        mangaId: mangaId,
        chapterId: chapterId,
        shouldAscSort: shouldAscSort,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<({ChapterDto? first, ChapterDto? second})?>
      createElement() {
    return _GetNextAndPreviousChaptersProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GetNextAndPreviousChaptersProvider &&
        other.mangaId == mangaId &&
        other.chapterId == chapterId &&
        other.shouldAscSort == shouldAscSort;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, mangaId.hashCode);
    hash = _SystemHash.combine(hash, chapterId.hashCode);
    hash = _SystemHash.combine(hash, shouldAscSort.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GetNextAndPreviousChaptersRef
    on AutoDisposeProviderRef<({ChapterDto? first, ChapterDto? second})?> {
  /// The parameter `mangaId` of this provider.
  int get mangaId;

  /// The parameter `chapterId` of this provider.
  int get chapterId;

  /// The parameter `shouldAscSort` of this provider.
  bool get shouldAscSort;
}

class _GetNextAndPreviousChaptersProviderElement
    extends AutoDisposeProviderElement<
        ({ChapterDto? first, ChapterDto? second})?>
    with GetNextAndPreviousChaptersRef {
  _GetNextAndPreviousChaptersProviderElement(super.provider);

  @override
  int get mangaId => (origin as GetNextAndPreviousChaptersProvider).mangaId;
  @override
  int get chapterId => (origin as GetNextAndPreviousChaptersProvider).chapterId;
  @override
  bool get shouldAscSort =>
      (origin as GetNextAndPreviousChaptersProvider).shouldAscSort;
}

String _$mangaWithIdHash() => r'faa83bdcd254e12f87bc10c572994b05df3e53af';

abstract class _$MangaWithId
    extends BuildlessAutoDisposeAsyncNotifier<MangaDto?> {
  late final int mangaId;

  FutureOr<MangaDto?> build({
    required int mangaId,
  });
}

/// See also [MangaWithId].
@ProviderFor(MangaWithId)
const mangaWithIdProvider = MangaWithIdFamily();

/// See also [MangaWithId].
class MangaWithIdFamily extends Family<AsyncValue<MangaDto?>> {
  /// See also [MangaWithId].
  const MangaWithIdFamily();

  /// See also [MangaWithId].
  MangaWithIdProvider call({
    required int mangaId,
  }) {
    return MangaWithIdProvider(
      mangaId: mangaId,
    );
  }

  @override
  MangaWithIdProvider getProviderOverride(
    covariant MangaWithIdProvider provider,
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
  String? get name => r'mangaWithIdProvider';
}

/// See also [MangaWithId].
class MangaWithIdProvider
    extends AutoDisposeAsyncNotifierProviderImpl<MangaWithId, MangaDto?> {
  /// See also [MangaWithId].
  MangaWithIdProvider({
    required int mangaId,
  }) : this._internal(
          () => MangaWithId()..mangaId = mangaId,
          from: mangaWithIdProvider,
          name: r'mangaWithIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$mangaWithIdHash,
          dependencies: MangaWithIdFamily._dependencies,
          allTransitiveDependencies:
              MangaWithIdFamily._allTransitiveDependencies,
          mangaId: mangaId,
        );

  MangaWithIdProvider._internal(
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
  FutureOr<MangaDto?> runNotifierBuild(
    covariant MangaWithId notifier,
  ) {
    return notifier.build(
      mangaId: mangaId,
    );
  }

  @override
  Override overrideWith(MangaWithId Function() create) {
    return ProviderOverride(
      origin: this,
      override: MangaWithIdProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<MangaWithId, MangaDto?>
      createElement() {
    return _MangaWithIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MangaWithIdProvider && other.mangaId == mangaId;
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
mixin MangaWithIdRef on AutoDisposeAsyncNotifierProviderRef<MangaDto?> {
  /// The parameter `mangaId` of this provider.
  int get mangaId;
}

class _MangaWithIdProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<MangaWithId, MangaDto?>
    with MangaWithIdRef {
  _MangaWithIdProviderElement(super.provider);

  @override
  int get mangaId => (origin as MangaWithIdProvider).mangaId;
}

String _$mangaChapterListHash() => r'133c9a5c9c1ed54a1ef40dec499ff2177d11dc88';

abstract class _$MangaChapterList
    extends BuildlessAutoDisposeAsyncNotifier<List<ChapterDto>?> {
  late final int mangaId;

  FutureOr<List<ChapterDto>?> build({
    required int mangaId,
  });
}

/// See also [MangaChapterList].
@ProviderFor(MangaChapterList)
const mangaChapterListProvider = MangaChapterListFamily();

/// See also [MangaChapterList].
class MangaChapterListFamily extends Family<AsyncValue<List<ChapterDto>?>> {
  /// See also [MangaChapterList].
  const MangaChapterListFamily();

  /// See also [MangaChapterList].
  MangaChapterListProvider call({
    required int mangaId,
  }) {
    return MangaChapterListProvider(
      mangaId: mangaId,
    );
  }

  @override
  MangaChapterListProvider getProviderOverride(
    covariant MangaChapterListProvider provider,
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
  String? get name => r'mangaChapterListProvider';
}

/// See also [MangaChapterList].
class MangaChapterListProvider extends AutoDisposeAsyncNotifierProviderImpl<
    MangaChapterList, List<ChapterDto>?> {
  /// See also [MangaChapterList].
  MangaChapterListProvider({
    required int mangaId,
  }) : this._internal(
          () => MangaChapterList()..mangaId = mangaId,
          from: mangaChapterListProvider,
          name: r'mangaChapterListProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$mangaChapterListHash,
          dependencies: MangaChapterListFamily._dependencies,
          allTransitiveDependencies:
              MangaChapterListFamily._allTransitiveDependencies,
          mangaId: mangaId,
        );

  MangaChapterListProvider._internal(
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
  FutureOr<List<ChapterDto>?> runNotifierBuild(
    covariant MangaChapterList notifier,
  ) {
    return notifier.build(
      mangaId: mangaId,
    );
  }

  @override
  Override overrideWith(MangaChapterList Function() create) {
    return ProviderOverride(
      origin: this,
      override: MangaChapterListProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<MangaChapterList, List<ChapterDto>?>
      createElement() {
    return _MangaChapterListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MangaChapterListProvider && other.mangaId == mangaId;
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
mixin MangaChapterListRef
    on AutoDisposeAsyncNotifierProviderRef<List<ChapterDto>?> {
  /// The parameter `mangaId` of this provider.
  int get mangaId;
}

class _MangaChapterListProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<MangaChapterList,
        List<ChapterDto>?> with MangaChapterListRef {
  _MangaChapterListProviderElement(super.provider);

  @override
  int get mangaId => (origin as MangaChapterListProvider).mangaId;
}

String _$mangaChapterFilterScanlatorHash() =>
    r'1e9cc2f48459bce949610737e71ad921f2d9aece';

abstract class _$MangaChapterFilterScanlator
    extends BuildlessAutoDisposeNotifier<String> {
  late final int mangaId;

  String build({
    required int mangaId,
  });
}

/// See also [MangaChapterFilterScanlator].
@ProviderFor(MangaChapterFilterScanlator)
const mangaChapterFilterScanlatorProvider = MangaChapterFilterScanlatorFamily();

/// See also [MangaChapterFilterScanlator].
class MangaChapterFilterScanlatorFamily extends Family<String> {
  /// See also [MangaChapterFilterScanlator].
  const MangaChapterFilterScanlatorFamily();

  /// See also [MangaChapterFilterScanlator].
  MangaChapterFilterScanlatorProvider call({
    required int mangaId,
  }) {
    return MangaChapterFilterScanlatorProvider(
      mangaId: mangaId,
    );
  }

  @override
  MangaChapterFilterScanlatorProvider getProviderOverride(
    covariant MangaChapterFilterScanlatorProvider provider,
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
  String? get name => r'mangaChapterFilterScanlatorProvider';
}

/// See also [MangaChapterFilterScanlator].
class MangaChapterFilterScanlatorProvider
    extends AutoDisposeNotifierProviderImpl<MangaChapterFilterScanlator,
        String> {
  /// See also [MangaChapterFilterScanlator].
  MangaChapterFilterScanlatorProvider({
    required int mangaId,
  }) : this._internal(
          () => MangaChapterFilterScanlator()..mangaId = mangaId,
          from: mangaChapterFilterScanlatorProvider,
          name: r'mangaChapterFilterScanlatorProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$mangaChapterFilterScanlatorHash,
          dependencies: MangaChapterFilterScanlatorFamily._dependencies,
          allTransitiveDependencies:
              MangaChapterFilterScanlatorFamily._allTransitiveDependencies,
          mangaId: mangaId,
        );

  MangaChapterFilterScanlatorProvider._internal(
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
  String runNotifierBuild(
    covariant MangaChapterFilterScanlator notifier,
  ) {
    return notifier.build(
      mangaId: mangaId,
    );
  }

  @override
  Override overrideWith(MangaChapterFilterScanlator Function() create) {
    return ProviderOverride(
      origin: this,
      override: MangaChapterFilterScanlatorProvider._internal(
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
  AutoDisposeNotifierProviderElement<MangaChapterFilterScanlator, String>
      createElement() {
    return _MangaChapterFilterScanlatorProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MangaChapterFilterScanlatorProvider &&
        other.mangaId == mangaId;
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
mixin MangaChapterFilterScanlatorRef on AutoDisposeNotifierProviderRef<String> {
  /// The parameter `mangaId` of this provider.
  int get mangaId;
}

class _MangaChapterFilterScanlatorProviderElement
    extends AutoDisposeNotifierProviderElement<MangaChapterFilterScanlator,
        String> with MangaChapterFilterScanlatorRef {
  _MangaChapterFilterScanlatorProviderElement(super.provider);

  @override
  int get mangaId => (origin as MangaChapterFilterScanlatorProvider).mangaId;
}

String _$mangaChapterSortHash() => r'65cfa4018101913a9afb73cfe0f1dc8e7e9051c6';

/// See also [MangaChapterSort].
@ProviderFor(MangaChapterSort)
final mangaChapterSortProvider =
    AutoDisposeNotifierProvider<MangaChapterSort, ChapterSort?>.internal(
  MangaChapterSort.new,
  name: r'mangaChapterSortProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$mangaChapterSortHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MangaChapterSort = AutoDisposeNotifier<ChapterSort?>;
String _$mangaChapterSortDirectionHash() =>
    r'178008eb77e4c802bde58a23b3b288b33fbbcbfd';

/// See also [MangaChapterSortDirection].
@ProviderFor(MangaChapterSortDirection)
final mangaChapterSortDirectionProvider =
    AutoDisposeNotifierProvider<MangaChapterSortDirection, bool?>.internal(
  MangaChapterSortDirection.new,
  name: r'mangaChapterSortDirectionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$mangaChapterSortDirectionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MangaChapterSortDirection = AutoDisposeNotifier<bool?>;
String _$mangaChapterFilterDownloadedHash() =>
    r'f22afc19cbdca59e0a9f73c875ef02640d414bc7';

/// See also [MangaChapterFilterDownloaded].
@ProviderFor(MangaChapterFilterDownloaded)
final mangaChapterFilterDownloadedProvider =
    AutoDisposeNotifierProvider<MangaChapterFilterDownloaded, bool?>.internal(
  MangaChapterFilterDownloaded.new,
  name: r'mangaChapterFilterDownloadedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$mangaChapterFilterDownloadedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MangaChapterFilterDownloaded = AutoDisposeNotifier<bool?>;
String _$mangaChapterFilterUnreadHash() =>
    r'75a99006c8f2ed6c2b52da3f7c9ffdecef0ac4fe';

/// See also [MangaChapterFilterUnread].
@ProviderFor(MangaChapterFilterUnread)
final mangaChapterFilterUnreadProvider =
    AutoDisposeNotifierProvider<MangaChapterFilterUnread, bool?>.internal(
  MangaChapterFilterUnread.new,
  name: r'mangaChapterFilterUnreadProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$mangaChapterFilterUnreadHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MangaChapterFilterUnread = AutoDisposeNotifier<bool?>;
String _$mangaChapterFilterBookmarkedHash() =>
    r'5d99f8a20682b1c278652ea51463fbfc5b0f676b';

/// See also [MangaChapterFilterBookmarked].
@ProviderFor(MangaChapterFilterBookmarked)
final mangaChapterFilterBookmarkedProvider =
    AutoDisposeNotifierProvider<MangaChapterFilterBookmarked, bool?>.internal(
  MangaChapterFilterBookmarked.new,
  name: r'mangaChapterFilterBookmarkedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$mangaChapterFilterBookmarkedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MangaChapterFilterBookmarked = AutoDisposeNotifier<bool?>;
String _$mangaCategoryListHash() => r'924971bc8c1eab416bebc636fe4224451d3a99ef';

abstract class _$MangaCategoryList
    extends BuildlessAutoDisposeAsyncNotifier<Map<String, CategoryDto>?> {
  late final int mangaId;

  FutureOr<Map<String, CategoryDto>?> build(
    int mangaId,
  );
}

/// See also [MangaCategoryList].
@ProviderFor(MangaCategoryList)
const mangaCategoryListProvider = MangaCategoryListFamily();

/// See also [MangaCategoryList].
class MangaCategoryListFamily
    extends Family<AsyncValue<Map<String, CategoryDto>?>> {
  /// See also [MangaCategoryList].
  const MangaCategoryListFamily();

  /// See also [MangaCategoryList].
  MangaCategoryListProvider call(
    int mangaId,
  ) {
    return MangaCategoryListProvider(
      mangaId,
    );
  }

  @override
  MangaCategoryListProvider getProviderOverride(
    covariant MangaCategoryListProvider provider,
  ) {
    return call(
      provider.mangaId,
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
  String? get name => r'mangaCategoryListProvider';
}

/// See also [MangaCategoryList].
class MangaCategoryListProvider extends AutoDisposeAsyncNotifierProviderImpl<
    MangaCategoryList, Map<String, CategoryDto>?> {
  /// See also [MangaCategoryList].
  MangaCategoryListProvider(
    int mangaId,
  ) : this._internal(
          () => MangaCategoryList()..mangaId = mangaId,
          from: mangaCategoryListProvider,
          name: r'mangaCategoryListProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$mangaCategoryListHash,
          dependencies: MangaCategoryListFamily._dependencies,
          allTransitiveDependencies:
              MangaCategoryListFamily._allTransitiveDependencies,
          mangaId: mangaId,
        );

  MangaCategoryListProvider._internal(
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
  FutureOr<Map<String, CategoryDto>?> runNotifierBuild(
    covariant MangaCategoryList notifier,
  ) {
    return notifier.build(
      mangaId,
    );
  }

  @override
  Override overrideWith(MangaCategoryList Function() create) {
    return ProviderOverride(
      origin: this,
      override: MangaCategoryListProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<MangaCategoryList,
      Map<String, CategoryDto>?> createElement() {
    return _MangaCategoryListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MangaCategoryListProvider && other.mangaId == mangaId;
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
mixin MangaCategoryListRef
    on AutoDisposeAsyncNotifierProviderRef<Map<String, CategoryDto>?> {
  /// The parameter `mangaId` of this provider.
  int get mangaId;
}

class _MangaCategoryListProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<MangaCategoryList,
        Map<String, CategoryDto>?> with MangaCategoryListRef {
  _MangaCategoryListProviderElement(super.provider);

  @override
  int get mangaId => (origin as MangaCategoryListProvider).mangaId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
