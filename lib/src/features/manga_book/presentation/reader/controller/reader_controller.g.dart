// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reader_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chapterHash() => r'4985f136ebde69bd148eafc09305747890e6021c';

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

/// See also [chapter].
@ProviderFor(chapter)
const chapterProvider = ChapterFamily();

/// See also [chapter].
class ChapterFamily extends Family<AsyncValue<ChapterDto?>> {
  /// See also [chapter].
  const ChapterFamily();

  /// See also [chapter].
  ChapterProvider call({
    required int chapterId,
  }) {
    return ChapterProvider(
      chapterId: chapterId,
    );
  }

  @override
  ChapterProvider getProviderOverride(
    covariant ChapterProvider provider,
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
  String? get name => r'chapterProvider';
}

/// See also [chapter].
class ChapterProvider extends AutoDisposeFutureProvider<ChapterDto?> {
  /// See also [chapter].
  ChapterProvider({
    required int chapterId,
  }) : this._internal(
          (ref) => chapter(
            ref as ChapterRef,
            chapterId: chapterId,
          ),
          from: chapterProvider,
          name: r'chapterProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$chapterHash,
          dependencies: ChapterFamily._dependencies,
          allTransitiveDependencies: ChapterFamily._allTransitiveDependencies,
          chapterId: chapterId,
        );

  ChapterProvider._internal(
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
    FutureOr<ChapterDto?> Function(ChapterRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ChapterProvider._internal(
        (ref) => create(ref as ChapterRef),
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
  AutoDisposeFutureProviderElement<ChapterDto?> createElement() {
    return _ChapterProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChapterProvider && other.chapterId == chapterId;
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
mixin ChapterRef on AutoDisposeFutureProviderRef<ChapterDto?> {
  /// The parameter `chapterId` of this provider.
  int get chapterId;
}

class _ChapterProviderElement
    extends AutoDisposeFutureProviderElement<ChapterDto?> with ChapterRef {
  _ChapterProviderElement(super.provider);

  @override
  int get chapterId => (origin as ChapterProvider).chapterId;
}

String _$chapterPagesHash() => r'f8779291ccaf2bd2372f41e2f21b4e0108272e40';

/// See also [chapterPages].
@ProviderFor(chapterPages)
const chapterPagesProvider = ChapterPagesFamily();

/// See also [chapterPages].
class ChapterPagesFamily extends Family<AsyncValue<ChapterPagesDto?>> {
  /// See also [chapterPages].
  const ChapterPagesFamily();

  /// See also [chapterPages].
  ChapterPagesProvider call({
    required int chapterId,
  }) {
    return ChapterPagesProvider(
      chapterId: chapterId,
    );
  }

  @override
  ChapterPagesProvider getProviderOverride(
    covariant ChapterPagesProvider provider,
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
  String? get name => r'chapterPagesProvider';
}

/// See also [chapterPages].
class ChapterPagesProvider extends AutoDisposeFutureProvider<ChapterPagesDto?> {
  /// See also [chapterPages].
  ChapterPagesProvider({
    required int chapterId,
  }) : this._internal(
          (ref) => chapterPages(
            ref as ChapterPagesRef,
            chapterId: chapterId,
          ),
          from: chapterPagesProvider,
          name: r'chapterPagesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$chapterPagesHash,
          dependencies: ChapterPagesFamily._dependencies,
          allTransitiveDependencies:
              ChapterPagesFamily._allTransitiveDependencies,
          chapterId: chapterId,
        );

  ChapterPagesProvider._internal(
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
    FutureOr<ChapterPagesDto?> Function(ChapterPagesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ChapterPagesProvider._internal(
        (ref) => create(ref as ChapterPagesRef),
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
  AutoDisposeFutureProviderElement<ChapterPagesDto?> createElement() {
    return _ChapterPagesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChapterPagesProvider && other.chapterId == chapterId;
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
mixin ChapterPagesRef on AutoDisposeFutureProviderRef<ChapterPagesDto?> {
  /// The parameter `chapterId` of this provider.
  int get chapterId;
}

class _ChapterPagesProviderElement
    extends AutoDisposeFutureProviderElement<ChapterPagesDto?>
    with ChapterPagesRef {
  _ChapterPagesProviderElement(super.provider);

  @override
  int get chapterId => (origin as ChapterPagesProvider).chapterId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
