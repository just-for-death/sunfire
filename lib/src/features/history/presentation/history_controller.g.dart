// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$historyGroupedByDateHash() =>
    r'6f852afaf6a64418708f78b122b60a0dc1b5b004';

/// See also [historyGroupedByDate].
@ProviderFor(historyGroupedByDate)
final historyGroupedByDateProvider =
    AutoDisposeProvider<List<HistoryGroup>>.internal(
  historyGroupedByDate,
  name: r'historyGroupedByDateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$historyGroupedByDateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HistoryGroupedByDateRef = AutoDisposeProviderRef<List<HistoryGroup>>;
String _$filteredHistoryGroupsHash() =>
    r'd7ae10ad569fc5955b165787bc416ea9504779c6';

/// See also [filteredHistoryGroups].
@ProviderFor(filteredHistoryGroups)
final filteredHistoryGroupsProvider =
    AutoDisposeProvider<List<HistoryGroup>>.internal(
  filteredHistoryGroups,
  name: r'filteredHistoryGroupsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredHistoryGroupsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredHistoryGroupsRef = AutoDisposeProviderRef<List<HistoryGroup>>;
String _$readingHistoryHash() => r'9f1da311d52a07df49fdb74c340fe4e7359a4eee';

/// See also [ReadingHistory].
@ProviderFor(ReadingHistory)
final readingHistoryProvider = AutoDisposeAsyncNotifierProvider<ReadingHistory,
    List<HistoryItemDto>?>.internal(
  ReadingHistory.new,
  name: r'readingHistoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$readingHistoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ReadingHistory = AutoDisposeAsyncNotifier<List<HistoryItemDto>?>;
String _$mangaReadingHistoryHash() =>
    r'902d0275b42d3b88fb51bd0f5ef33a877e8497e0';

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

abstract class _$MangaReadingHistory
    extends BuildlessAutoDisposeAsyncNotifier<List<HistoryItemDto>?> {
  late final int mangaId;

  FutureOr<List<HistoryItemDto>?> build({
    required int mangaId,
  });
}

/// See also [MangaReadingHistory].
@ProviderFor(MangaReadingHistory)
const mangaReadingHistoryProvider = MangaReadingHistoryFamily();

/// See also [MangaReadingHistory].
class MangaReadingHistoryFamily
    extends Family<AsyncValue<List<HistoryItemDto>?>> {
  /// See also [MangaReadingHistory].
  const MangaReadingHistoryFamily();

  /// See also [MangaReadingHistory].
  MangaReadingHistoryProvider call({
    required int mangaId,
  }) {
    return MangaReadingHistoryProvider(
      mangaId: mangaId,
    );
  }

  @override
  MangaReadingHistoryProvider getProviderOverride(
    covariant MangaReadingHistoryProvider provider,
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
  String? get name => r'mangaReadingHistoryProvider';
}

/// See also [MangaReadingHistory].
class MangaReadingHistoryProvider extends AutoDisposeAsyncNotifierProviderImpl<
    MangaReadingHistory, List<HistoryItemDto>?> {
  /// See also [MangaReadingHistory].
  MangaReadingHistoryProvider({
    required int mangaId,
  }) : this._internal(
          () => MangaReadingHistory()..mangaId = mangaId,
          from: mangaReadingHistoryProvider,
          name: r'mangaReadingHistoryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$mangaReadingHistoryHash,
          dependencies: MangaReadingHistoryFamily._dependencies,
          allTransitiveDependencies:
              MangaReadingHistoryFamily._allTransitiveDependencies,
          mangaId: mangaId,
        );

  MangaReadingHistoryProvider._internal(
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
  FutureOr<List<HistoryItemDto>?> runNotifierBuild(
    covariant MangaReadingHistory notifier,
  ) {
    return notifier.build(
      mangaId: mangaId,
    );
  }

  @override
  Override overrideWith(MangaReadingHistory Function() create) {
    return ProviderOverride(
      origin: this,
      override: MangaReadingHistoryProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<MangaReadingHistory,
      List<HistoryItemDto>?> createElement() {
    return _MangaReadingHistoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MangaReadingHistoryProvider && other.mangaId == mangaId;
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
mixin MangaReadingHistoryRef
    on AutoDisposeAsyncNotifierProviderRef<List<HistoryItemDto>?> {
  /// The parameter `mangaId` of this provider.
  int get mangaId;
}

class _MangaReadingHistoryProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<MangaReadingHistory,
        List<HistoryItemDto>?> with MangaReadingHistoryRef {
  _MangaReadingHistoryProviderElement(super.provider);

  @override
  int get mangaId => (origin as MangaReadingHistoryProvider).mangaId;
}

String _$historySearchQueryHash() =>
    r'7ef06517b91fd267ca6fc2bf684f3e0dd132d625';

/// See also [HistorySearchQuery].
@ProviderFor(HistorySearchQuery)
final historySearchQueryProvider =
    AutoDisposeNotifierProvider<HistorySearchQuery, String>.internal(
  HistorySearchQuery.new,
  name: r'historySearchQueryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$historySearchQueryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$HistorySearchQuery = AutoDisposeNotifier<String>;
String _$historyRetentionDaysHash() =>
    r'110a7c6e622ef483f4012759d908fc453c1e1634';

/// See also [HistoryRetentionDays].
@ProviderFor(HistoryRetentionDays)
final historyRetentionDaysProvider =
    AutoDisposeNotifierProvider<HistoryRetentionDays, int?>.internal(
  HistoryRetentionDays.new,
  name: r'historyRetentionDaysProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$historyRetentionDaysHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$HistoryRetentionDays = AutoDisposeNotifier<int?>;
String _$historyEnabledHash() => r'507e1030909d91177ba95ff8198bcadfd9587a2c';

/// See also [HistoryEnabled].
@ProviderFor(HistoryEnabled)
final historyEnabledProvider =
    AutoDisposeNotifierProvider<HistoryEnabled, bool?>.internal(
  HistoryEnabled.new,
  name: r'historyEnabledProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$historyEnabledHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$HistoryEnabled = AutoDisposeNotifier<bool?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
