// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'migration_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MigrationSource _$MigrationSourceFromJson(Map<String, dynamic> json) {
  return _MigrationSource.fromJson(json);
}

/// @nodoc
mixin _$MigrationSource {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get lang => throw _privateConstructorUsedError;
  bool get isConfigured => throw _privateConstructorUsedError;
  int get mangaCount => throw _privateConstructorUsedError;
  String? get displayName => throw _privateConstructorUsedError;
  bool? get supportsLatest => throw _privateConstructorUsedError;

  /// Serializes this MigrationSource to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MigrationSource
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MigrationSourceCopyWith<MigrationSource> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MigrationSourceCopyWith<$Res> {
  factory $MigrationSourceCopyWith(
          MigrationSource value, $Res Function(MigrationSource) then) =
      _$MigrationSourceCopyWithImpl<$Res, MigrationSource>;
  @useResult
  $Res call(
      {String id,
      String name,
      String lang,
      bool isConfigured,
      int mangaCount,
      String? displayName,
      bool? supportsLatest});
}

/// @nodoc
class _$MigrationSourceCopyWithImpl<$Res, $Val extends MigrationSource>
    implements $MigrationSourceCopyWith<$Res> {
  _$MigrationSourceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MigrationSource
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? lang = null,
    Object? isConfigured = null,
    Object? mangaCount = null,
    Object? displayName = freezed,
    Object? supportsLatest = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      lang: null == lang
          ? _value.lang
          : lang // ignore: cast_nullable_to_non_nullable
              as String,
      isConfigured: null == isConfigured
          ? _value.isConfigured
          : isConfigured // ignore: cast_nullable_to_non_nullable
              as bool,
      mangaCount: null == mangaCount
          ? _value.mangaCount
          : mangaCount // ignore: cast_nullable_to_non_nullable
              as int,
      displayName: freezed == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String?,
      supportsLatest: freezed == supportsLatest
          ? _value.supportsLatest
          : supportsLatest // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MigrationSourceImplCopyWith<$Res>
    implements $MigrationSourceCopyWith<$Res> {
  factory _$$MigrationSourceImplCopyWith(_$MigrationSourceImpl value,
          $Res Function(_$MigrationSourceImpl) then) =
      __$$MigrationSourceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String lang,
      bool isConfigured,
      int mangaCount,
      String? displayName,
      bool? supportsLatest});
}

/// @nodoc
class __$$MigrationSourceImplCopyWithImpl<$Res>
    extends _$MigrationSourceCopyWithImpl<$Res, _$MigrationSourceImpl>
    implements _$$MigrationSourceImplCopyWith<$Res> {
  __$$MigrationSourceImplCopyWithImpl(
      _$MigrationSourceImpl _value, $Res Function(_$MigrationSourceImpl) _then)
      : super(_value, _then);

  /// Create a copy of MigrationSource
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? lang = null,
    Object? isConfigured = null,
    Object? mangaCount = null,
    Object? displayName = freezed,
    Object? supportsLatest = freezed,
  }) {
    return _then(_$MigrationSourceImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      lang: null == lang
          ? _value.lang
          : lang // ignore: cast_nullable_to_non_nullable
              as String,
      isConfigured: null == isConfigured
          ? _value.isConfigured
          : isConfigured // ignore: cast_nullable_to_non_nullable
              as bool,
      mangaCount: null == mangaCount
          ? _value.mangaCount
          : mangaCount // ignore: cast_nullable_to_non_nullable
              as int,
      displayName: freezed == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String?,
      supportsLatest: freezed == supportsLatest
          ? _value.supportsLatest
          : supportsLatest // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MigrationSourceImpl implements _MigrationSource {
  const _$MigrationSourceImpl(
      {required this.id,
      required this.name,
      required this.lang,
      this.isConfigured = false,
      this.mangaCount = 0,
      this.displayName,
      this.supportsLatest});

  factory _$MigrationSourceImpl.fromJson(Map<String, dynamic> json) =>
      _$$MigrationSourceImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String lang;
  @override
  @JsonKey()
  final bool isConfigured;
  @override
  @JsonKey()
  final int mangaCount;
  @override
  final String? displayName;
  @override
  final bool? supportsLatest;

  @override
  String toString() {
    return 'MigrationSource(id: $id, name: $name, lang: $lang, isConfigured: $isConfigured, mangaCount: $mangaCount, displayName: $displayName, supportsLatest: $supportsLatest)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MigrationSourceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.lang, lang) || other.lang == lang) &&
            (identical(other.isConfigured, isConfigured) ||
                other.isConfigured == isConfigured) &&
            (identical(other.mangaCount, mangaCount) ||
                other.mangaCount == mangaCount) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.supportsLatest, supportsLatest) ||
                other.supportsLatest == supportsLatest));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, lang, isConfigured,
      mangaCount, displayName, supportsLatest);

  /// Create a copy of MigrationSource
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MigrationSourceImplCopyWith<_$MigrationSourceImpl> get copyWith =>
      __$$MigrationSourceImplCopyWithImpl<_$MigrationSourceImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MigrationSourceImplToJson(
      this,
    );
  }
}

abstract class _MigrationSource implements MigrationSource {
  const factory _MigrationSource(
      {required final String id,
      required final String name,
      required final String lang,
      final bool isConfigured,
      final int mangaCount,
      final String? displayName,
      final bool? supportsLatest}) = _$MigrationSourceImpl;

  factory _MigrationSource.fromJson(Map<String, dynamic> json) =
      _$MigrationSourceImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get lang;
  @override
  bool get isConfigured;
  @override
  int get mangaCount;
  @override
  String? get displayName;
  @override
  bool? get supportsLatest;

  /// Create a copy of MigrationSource
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MigrationSourceImplCopyWith<_$MigrationSourceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MigrationOption _$MigrationOptionFromJson(Map<String, dynamic> json) {
  return _MigrationOption.fromJson(json);
}

/// @nodoc
mixin _$MigrationOption {
  bool get migrateChapters => throw _privateConstructorUsedError;
  bool get migrateCategories => throw _privateConstructorUsedError;
  bool get migrateDownloads => throw _privateConstructorUsedError;
  bool get migrateTracking => throw _privateConstructorUsedError;
  bool get deleteSource => throw _privateConstructorUsedError;

  /// Serializes this MigrationOption to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MigrationOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MigrationOptionCopyWith<MigrationOption> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MigrationOptionCopyWith<$Res> {
  factory $MigrationOptionCopyWith(
          MigrationOption value, $Res Function(MigrationOption) then) =
      _$MigrationOptionCopyWithImpl<$Res, MigrationOption>;
  @useResult
  $Res call(
      {bool migrateChapters,
      bool migrateCategories,
      bool migrateDownloads,
      bool migrateTracking,
      bool deleteSource});
}

/// @nodoc
class _$MigrationOptionCopyWithImpl<$Res, $Val extends MigrationOption>
    implements $MigrationOptionCopyWith<$Res> {
  _$MigrationOptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MigrationOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? migrateChapters = null,
    Object? migrateCategories = null,
    Object? migrateDownloads = null,
    Object? migrateTracking = null,
    Object? deleteSource = null,
  }) {
    return _then(_value.copyWith(
      migrateChapters: null == migrateChapters
          ? _value.migrateChapters
          : migrateChapters // ignore: cast_nullable_to_non_nullable
              as bool,
      migrateCategories: null == migrateCategories
          ? _value.migrateCategories
          : migrateCategories // ignore: cast_nullable_to_non_nullable
              as bool,
      migrateDownloads: null == migrateDownloads
          ? _value.migrateDownloads
          : migrateDownloads // ignore: cast_nullable_to_non_nullable
              as bool,
      migrateTracking: null == migrateTracking
          ? _value.migrateTracking
          : migrateTracking // ignore: cast_nullable_to_non_nullable
              as bool,
      deleteSource: null == deleteSource
          ? _value.deleteSource
          : deleteSource // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MigrationOptionImplCopyWith<$Res>
    implements $MigrationOptionCopyWith<$Res> {
  factory _$$MigrationOptionImplCopyWith(_$MigrationOptionImpl value,
          $Res Function(_$MigrationOptionImpl) then) =
      __$$MigrationOptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool migrateChapters,
      bool migrateCategories,
      bool migrateDownloads,
      bool migrateTracking,
      bool deleteSource});
}

/// @nodoc
class __$$MigrationOptionImplCopyWithImpl<$Res>
    extends _$MigrationOptionCopyWithImpl<$Res, _$MigrationOptionImpl>
    implements _$$MigrationOptionImplCopyWith<$Res> {
  __$$MigrationOptionImplCopyWithImpl(
      _$MigrationOptionImpl _value, $Res Function(_$MigrationOptionImpl) _then)
      : super(_value, _then);

  /// Create a copy of MigrationOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? migrateChapters = null,
    Object? migrateCategories = null,
    Object? migrateDownloads = null,
    Object? migrateTracking = null,
    Object? deleteSource = null,
  }) {
    return _then(_$MigrationOptionImpl(
      migrateChapters: null == migrateChapters
          ? _value.migrateChapters
          : migrateChapters // ignore: cast_nullable_to_non_nullable
              as bool,
      migrateCategories: null == migrateCategories
          ? _value.migrateCategories
          : migrateCategories // ignore: cast_nullable_to_non_nullable
              as bool,
      migrateDownloads: null == migrateDownloads
          ? _value.migrateDownloads
          : migrateDownloads // ignore: cast_nullable_to_non_nullable
              as bool,
      migrateTracking: null == migrateTracking
          ? _value.migrateTracking
          : migrateTracking // ignore: cast_nullable_to_non_nullable
              as bool,
      deleteSource: null == deleteSource
          ? _value.deleteSource
          : deleteSource // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MigrationOptionImpl implements _MigrationOption {
  const _$MigrationOptionImpl(
      {this.migrateChapters = true,
      this.migrateCategories = true,
      this.migrateDownloads = false,
      this.migrateTracking = false,
      this.deleteSource = true});

  factory _$MigrationOptionImpl.fromJson(Map<String, dynamic> json) =>
      _$$MigrationOptionImplFromJson(json);

  @override
  @JsonKey()
  final bool migrateChapters;
  @override
  @JsonKey()
  final bool migrateCategories;
  @override
  @JsonKey()
  final bool migrateDownloads;
  @override
  @JsonKey()
  final bool migrateTracking;
  @override
  @JsonKey()
  final bool deleteSource;

  @override
  String toString() {
    return 'MigrationOption(migrateChapters: $migrateChapters, migrateCategories: $migrateCategories, migrateDownloads: $migrateDownloads, migrateTracking: $migrateTracking, deleteSource: $deleteSource)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MigrationOptionImpl &&
            (identical(other.migrateChapters, migrateChapters) ||
                other.migrateChapters == migrateChapters) &&
            (identical(other.migrateCategories, migrateCategories) ||
                other.migrateCategories == migrateCategories) &&
            (identical(other.migrateDownloads, migrateDownloads) ||
                other.migrateDownloads == migrateDownloads) &&
            (identical(other.migrateTracking, migrateTracking) ||
                other.migrateTracking == migrateTracking) &&
            (identical(other.deleteSource, deleteSource) ||
                other.deleteSource == deleteSource));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, migrateChapters,
      migrateCategories, migrateDownloads, migrateTracking, deleteSource);

  /// Create a copy of MigrationOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MigrationOptionImplCopyWith<_$MigrationOptionImpl> get copyWith =>
      __$$MigrationOptionImplCopyWithImpl<_$MigrationOptionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MigrationOptionImplToJson(
      this,
    );
  }
}

abstract class _MigrationOption implements MigrationOption {
  const factory _MigrationOption(
      {final bool migrateChapters,
      final bool migrateCategories,
      final bool migrateDownloads,
      final bool migrateTracking,
      final bool deleteSource}) = _$MigrationOptionImpl;

  factory _MigrationOption.fromJson(Map<String, dynamic> json) =
      _$MigrationOptionImpl.fromJson;

  @override
  bool get migrateChapters;
  @override
  bool get migrateCategories;
  @override
  bool get migrateDownloads;
  @override
  bool get migrateTracking;
  @override
  bool get deleteSource;

  /// Create a copy of MigrationOption
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MigrationOptionImplCopyWith<_$MigrationOptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MigrationResult _$MigrationResultFromJson(Map<String, dynamic> json) {
  return _MigrationResult.fromJson(json);
}

/// @nodoc
mixin _$MigrationResult {
  bool get success => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  int get migratedChapters => throw _privateConstructorUsedError;
  List<String> get warnings => throw _privateConstructorUsedError;
  Fragment$MangaDto? get newManga => throw _privateConstructorUsedError;
  int get migratedCategories => throw _privateConstructorUsedError;
  int get migratedDownloads => throw _privateConstructorUsedError;

  /// Serializes this MigrationResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MigrationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MigrationResultCopyWith<MigrationResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MigrationResultCopyWith<$Res> {
  factory $MigrationResultCopyWith(
          MigrationResult value, $Res Function(MigrationResult) then) =
      _$MigrationResultCopyWithImpl<$Res, MigrationResult>;
  @useResult
  $Res call(
      {bool success,
      String? error,
      int migratedChapters,
      List<String> warnings,
      Fragment$MangaDto? newManga,
      int migratedCategories,
      int migratedDownloads});
}

/// @nodoc
class _$MigrationResultCopyWithImpl<$Res, $Val extends MigrationResult>
    implements $MigrationResultCopyWith<$Res> {
  _$MigrationResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MigrationResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? error = freezed,
    Object? migratedChapters = null,
    Object? warnings = null,
    Object? newManga = freezed,
    Object? migratedCategories = null,
    Object? migratedDownloads = null,
  }) {
    return _then(_value.copyWith(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      migratedChapters: null == migratedChapters
          ? _value.migratedChapters
          : migratedChapters // ignore: cast_nullable_to_non_nullable
              as int,
      warnings: null == warnings
          ? _value.warnings
          : warnings // ignore: cast_nullable_to_non_nullable
              as List<String>,
      newManga: freezed == newManga
          ? _value.newManga
          : newManga // ignore: cast_nullable_to_non_nullable
              as Fragment$MangaDto?,
      migratedCategories: null == migratedCategories
          ? _value.migratedCategories
          : migratedCategories // ignore: cast_nullable_to_non_nullable
              as int,
      migratedDownloads: null == migratedDownloads
          ? _value.migratedDownloads
          : migratedDownloads // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MigrationResultImplCopyWith<$Res>
    implements $MigrationResultCopyWith<$Res> {
  factory _$$MigrationResultImplCopyWith(_$MigrationResultImpl value,
          $Res Function(_$MigrationResultImpl) then) =
      __$$MigrationResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool success,
      String? error,
      int migratedChapters,
      List<String> warnings,
      Fragment$MangaDto? newManga,
      int migratedCategories,
      int migratedDownloads});
}

/// @nodoc
class __$$MigrationResultImplCopyWithImpl<$Res>
    extends _$MigrationResultCopyWithImpl<$Res, _$MigrationResultImpl>
    implements _$$MigrationResultImplCopyWith<$Res> {
  __$$MigrationResultImplCopyWithImpl(
      _$MigrationResultImpl _value, $Res Function(_$MigrationResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of MigrationResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? error = freezed,
    Object? migratedChapters = null,
    Object? warnings = null,
    Object? newManga = freezed,
    Object? migratedCategories = null,
    Object? migratedDownloads = null,
  }) {
    return _then(_$MigrationResultImpl(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      migratedChapters: null == migratedChapters
          ? _value.migratedChapters
          : migratedChapters // ignore: cast_nullable_to_non_nullable
              as int,
      warnings: null == warnings
          ? _value._warnings
          : warnings // ignore: cast_nullable_to_non_nullable
              as List<String>,
      newManga: freezed == newManga
          ? _value.newManga
          : newManga // ignore: cast_nullable_to_non_nullable
              as Fragment$MangaDto?,
      migratedCategories: null == migratedCategories
          ? _value.migratedCategories
          : migratedCategories // ignore: cast_nullable_to_non_nullable
              as int,
      migratedDownloads: null == migratedDownloads
          ? _value.migratedDownloads
          : migratedDownloads // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MigrationResultImpl implements _MigrationResult {
  const _$MigrationResultImpl(
      {required this.success,
      this.error,
      this.migratedChapters = 0,
      final List<String> warnings = const <String>[],
      this.newManga,
      this.migratedCategories = 0,
      this.migratedDownloads = 0})
      : _warnings = warnings;

  factory _$MigrationResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$MigrationResultImplFromJson(json);

  @override
  final bool success;
  @override
  final String? error;
  @override
  @JsonKey()
  final int migratedChapters;
  final List<String> _warnings;
  @override
  @JsonKey()
  List<String> get warnings {
    if (_warnings is EqualUnmodifiableListView) return _warnings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_warnings);
  }

  @override
  final Fragment$MangaDto? newManga;
  @override
  @JsonKey()
  final int migratedCategories;
  @override
  @JsonKey()
  final int migratedDownloads;

  @override
  String toString() {
    return 'MigrationResult(success: $success, error: $error, migratedChapters: $migratedChapters, warnings: $warnings, newManga: $newManga, migratedCategories: $migratedCategories, migratedDownloads: $migratedDownloads)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MigrationResultImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.migratedChapters, migratedChapters) ||
                other.migratedChapters == migratedChapters) &&
            const DeepCollectionEquality().equals(other._warnings, _warnings) &&
            (identical(other.newManga, newManga) ||
                other.newManga == newManga) &&
            (identical(other.migratedCategories, migratedCategories) ||
                other.migratedCategories == migratedCategories) &&
            (identical(other.migratedDownloads, migratedDownloads) ||
                other.migratedDownloads == migratedDownloads));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      success,
      error,
      migratedChapters,
      const DeepCollectionEquality().hash(_warnings),
      newManga,
      migratedCategories,
      migratedDownloads);

  /// Create a copy of MigrationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MigrationResultImplCopyWith<_$MigrationResultImpl> get copyWith =>
      __$$MigrationResultImplCopyWithImpl<_$MigrationResultImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MigrationResultImplToJson(
      this,
    );
  }
}

abstract class _MigrationResult implements MigrationResult {
  const factory _MigrationResult(
      {required final bool success,
      final String? error,
      final int migratedChapters,
      final List<String> warnings,
      final Fragment$MangaDto? newManga,
      final int migratedCategories,
      final int migratedDownloads}) = _$MigrationResultImpl;

  factory _MigrationResult.fromJson(Map<String, dynamic> json) =
      _$MigrationResultImpl.fromJson;

  @override
  bool get success;
  @override
  String? get error;
  @override
  int get migratedChapters;
  @override
  List<String> get warnings;
  @override
  Fragment$MangaDto? get newManga;
  @override
  int get migratedCategories;
  @override
  int get migratedDownloads;

  /// Create a copy of MigrationResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MigrationResultImplCopyWith<_$MigrationResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MigrationProgress _$MigrationProgressFromJson(Map<String, dynamic> json) {
  return _MigrationProgress.fromJson(json);
}

/// @nodoc
mixin _$MigrationProgress {
  MigrationStep get currentStep => throw _privateConstructorUsedError;
  double get percentage => throw _privateConstructorUsedError;
  MigrationStatus get status => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  int get processedItems => throw _privateConstructorUsedError;
  int get totalItems => throw _privateConstructorUsedError;

  /// Serializes this MigrationProgress to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MigrationProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MigrationProgressCopyWith<MigrationProgress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MigrationProgressCopyWith<$Res> {
  factory $MigrationProgressCopyWith(
          MigrationProgress value, $Res Function(MigrationProgress) then) =
      _$MigrationProgressCopyWithImpl<$Res, MigrationProgress>;
  @useResult
  $Res call(
      {MigrationStep currentStep,
      double percentage,
      MigrationStatus status,
      String? errorMessage,
      int processedItems,
      int totalItems});
}

/// @nodoc
class _$MigrationProgressCopyWithImpl<$Res, $Val extends MigrationProgress>
    implements $MigrationProgressCopyWith<$Res> {
  _$MigrationProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MigrationProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStep = null,
    Object? percentage = null,
    Object? status = null,
    Object? errorMessage = freezed,
    Object? processedItems = null,
    Object? totalItems = null,
  }) {
    return _then(_value.copyWith(
      currentStep: null == currentStep
          ? _value.currentStep
          : currentStep // ignore: cast_nullable_to_non_nullable
              as MigrationStep,
      percentage: null == percentage
          ? _value.percentage
          : percentage // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as MigrationStatus,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      processedItems: null == processedItems
          ? _value.processedItems
          : processedItems // ignore: cast_nullable_to_non_nullable
              as int,
      totalItems: null == totalItems
          ? _value.totalItems
          : totalItems // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MigrationProgressImplCopyWith<$Res>
    implements $MigrationProgressCopyWith<$Res> {
  factory _$$MigrationProgressImplCopyWith(_$MigrationProgressImpl value,
          $Res Function(_$MigrationProgressImpl) then) =
      __$$MigrationProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {MigrationStep currentStep,
      double percentage,
      MigrationStatus status,
      String? errorMessage,
      int processedItems,
      int totalItems});
}

/// @nodoc
class __$$MigrationProgressImplCopyWithImpl<$Res>
    extends _$MigrationProgressCopyWithImpl<$Res, _$MigrationProgressImpl>
    implements _$$MigrationProgressImplCopyWith<$Res> {
  __$$MigrationProgressImplCopyWithImpl(_$MigrationProgressImpl _value,
      $Res Function(_$MigrationProgressImpl) _then)
      : super(_value, _then);

  /// Create a copy of MigrationProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStep = null,
    Object? percentage = null,
    Object? status = null,
    Object? errorMessage = freezed,
    Object? processedItems = null,
    Object? totalItems = null,
  }) {
    return _then(_$MigrationProgressImpl(
      currentStep: null == currentStep
          ? _value.currentStep
          : currentStep // ignore: cast_nullable_to_non_nullable
              as MigrationStep,
      percentage: null == percentage
          ? _value.percentage
          : percentage // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as MigrationStatus,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      processedItems: null == processedItems
          ? _value.processedItems
          : processedItems // ignore: cast_nullable_to_non_nullable
              as int,
      totalItems: null == totalItems
          ? _value.totalItems
          : totalItems // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MigrationProgressImpl implements _MigrationProgress {
  const _$MigrationProgressImpl(
      {required this.currentStep,
      this.percentage = 0.0,
      this.status = MigrationStatus.idle,
      this.errorMessage,
      this.processedItems = 0,
      this.totalItems = 0});

  factory _$MigrationProgressImpl.fromJson(Map<String, dynamic> json) =>
      _$$MigrationProgressImplFromJson(json);

  @override
  final MigrationStep currentStep;
  @override
  @JsonKey()
  final double percentage;
  @override
  @JsonKey()
  final MigrationStatus status;
  @override
  final String? errorMessage;
  @override
  @JsonKey()
  final int processedItems;
  @override
  @JsonKey()
  final int totalItems;

  @override
  String toString() {
    return 'MigrationProgress(currentStep: $currentStep, percentage: $percentage, status: $status, errorMessage: $errorMessage, processedItems: $processedItems, totalItems: $totalItems)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MigrationProgressImpl &&
            (identical(other.currentStep, currentStep) ||
                other.currentStep == currentStep) &&
            (identical(other.percentage, percentage) ||
                other.percentage == percentage) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.processedItems, processedItems) ||
                other.processedItems == processedItems) &&
            (identical(other.totalItems, totalItems) ||
                other.totalItems == totalItems));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, currentStep, percentage, status,
      errorMessage, processedItems, totalItems);

  /// Create a copy of MigrationProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MigrationProgressImplCopyWith<_$MigrationProgressImpl> get copyWith =>
      __$$MigrationProgressImplCopyWithImpl<_$MigrationProgressImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MigrationProgressImplToJson(
      this,
    );
  }
}

abstract class _MigrationProgress implements MigrationProgress {
  const factory _MigrationProgress(
      {required final MigrationStep currentStep,
      final double percentage,
      final MigrationStatus status,
      final String? errorMessage,
      final int processedItems,
      final int totalItems}) = _$MigrationProgressImpl;

  factory _MigrationProgress.fromJson(Map<String, dynamic> json) =
      _$MigrationProgressImpl.fromJson;

  @override
  MigrationStep get currentStep;
  @override
  double get percentage;
  @override
  MigrationStatus get status;
  @override
  String? get errorMessage;
  @override
  int get processedItems;
  @override
  int get totalItems;

  /// Create a copy of MigrationProgress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MigrationProgressImplCopyWith<_$MigrationProgressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MangaSearchResult _$MangaSearchResultFromJson(Map<String, dynamic> json) {
  return _MangaSearchResult.fromJson(json);
}

/// @nodoc
mixin _$MangaSearchResult {
  Fragment$MangaDto get manga => throw _privateConstructorUsedError;
  double get similarity => throw _privateConstructorUsedError;
  String? get matchReason => throw _privateConstructorUsedError;

  /// Serializes this MangaSearchResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MangaSearchResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MangaSearchResultCopyWith<MangaSearchResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MangaSearchResultCopyWith<$Res> {
  factory $MangaSearchResultCopyWith(
          MangaSearchResult value, $Res Function(MangaSearchResult) then) =
      _$MangaSearchResultCopyWithImpl<$Res, MangaSearchResult>;
  @useResult
  $Res call({Fragment$MangaDto manga, double similarity, String? matchReason});
}

/// @nodoc
class _$MangaSearchResultCopyWithImpl<$Res, $Val extends MangaSearchResult>
    implements $MangaSearchResultCopyWith<$Res> {
  _$MangaSearchResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MangaSearchResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? manga = null,
    Object? similarity = null,
    Object? matchReason = freezed,
  }) {
    return _then(_value.copyWith(
      manga: null == manga
          ? _value.manga
          : manga // ignore: cast_nullable_to_non_nullable
              as Fragment$MangaDto,
      similarity: null == similarity
          ? _value.similarity
          : similarity // ignore: cast_nullable_to_non_nullable
              as double,
      matchReason: freezed == matchReason
          ? _value.matchReason
          : matchReason // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MangaSearchResultImplCopyWith<$Res>
    implements $MangaSearchResultCopyWith<$Res> {
  factory _$$MangaSearchResultImplCopyWith(_$MangaSearchResultImpl value,
          $Res Function(_$MangaSearchResultImpl) then) =
      __$$MangaSearchResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Fragment$MangaDto manga, double similarity, String? matchReason});
}

/// @nodoc
class __$$MangaSearchResultImplCopyWithImpl<$Res>
    extends _$MangaSearchResultCopyWithImpl<$Res, _$MangaSearchResultImpl>
    implements _$$MangaSearchResultImplCopyWith<$Res> {
  __$$MangaSearchResultImplCopyWithImpl(_$MangaSearchResultImpl _value,
      $Res Function(_$MangaSearchResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of MangaSearchResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? manga = null,
    Object? similarity = null,
    Object? matchReason = freezed,
  }) {
    return _then(_$MangaSearchResultImpl(
      manga: null == manga
          ? _value.manga
          : manga // ignore: cast_nullable_to_non_nullable
              as Fragment$MangaDto,
      similarity: null == similarity
          ? _value.similarity
          : similarity // ignore: cast_nullable_to_non_nullable
              as double,
      matchReason: freezed == matchReason
          ? _value.matchReason
          : matchReason // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MangaSearchResultImpl implements _MangaSearchResult {
  const _$MangaSearchResultImpl(
      {required this.manga, this.similarity = 0.0, this.matchReason});

  factory _$MangaSearchResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$MangaSearchResultImplFromJson(json);

  @override
  final Fragment$MangaDto manga;
  @override
  @JsonKey()
  final double similarity;
  @override
  final String? matchReason;

  @override
  String toString() {
    return 'MangaSearchResult(manga: $manga, similarity: $similarity, matchReason: $matchReason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MangaSearchResultImpl &&
            (identical(other.manga, manga) || other.manga == manga) &&
            (identical(other.similarity, similarity) ||
                other.similarity == similarity) &&
            (identical(other.matchReason, matchReason) ||
                other.matchReason == matchReason));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, manga, similarity, matchReason);

  /// Create a copy of MangaSearchResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MangaSearchResultImplCopyWith<_$MangaSearchResultImpl> get copyWith =>
      __$$MangaSearchResultImplCopyWithImpl<_$MangaSearchResultImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MangaSearchResultImplToJson(
      this,
    );
  }
}

abstract class _MangaSearchResult implements MangaSearchResult {
  const factory _MangaSearchResult(
      {required final Fragment$MangaDto manga,
      final double similarity,
      final String? matchReason}) = _$MangaSearchResultImpl;

  factory _MangaSearchResult.fromJson(Map<String, dynamic> json) =
      _$MangaSearchResultImpl.fromJson;

  @override
  Fragment$MangaDto get manga;
  @override
  double get similarity;
  @override
  String? get matchReason;

  /// Create a copy of MangaSearchResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MangaSearchResultImplCopyWith<_$MangaSearchResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$MigrationRouteData {
  Fragment$MangaDto get sourceManga => throw _privateConstructorUsedError;

  /// Create a copy of MigrationRouteData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MigrationRouteDataCopyWith<MigrationRouteData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MigrationRouteDataCopyWith<$Res> {
  factory $MigrationRouteDataCopyWith(
          MigrationRouteData value, $Res Function(MigrationRouteData) then) =
      _$MigrationRouteDataCopyWithImpl<$Res, MigrationRouteData>;
  @useResult
  $Res call({Fragment$MangaDto sourceManga});
}

/// @nodoc
class _$MigrationRouteDataCopyWithImpl<$Res, $Val extends MigrationRouteData>
    implements $MigrationRouteDataCopyWith<$Res> {
  _$MigrationRouteDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MigrationRouteData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sourceManga = null,
  }) {
    return _then(_value.copyWith(
      sourceManga: null == sourceManga
          ? _value.sourceManga
          : sourceManga // ignore: cast_nullable_to_non_nullable
              as Fragment$MangaDto,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MigrationRouteDataImplCopyWith<$Res>
    implements $MigrationRouteDataCopyWith<$Res> {
  factory _$$MigrationRouteDataImplCopyWith(_$MigrationRouteDataImpl value,
          $Res Function(_$MigrationRouteDataImpl) then) =
      __$$MigrationRouteDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Fragment$MangaDto sourceManga});
}

/// @nodoc
class __$$MigrationRouteDataImplCopyWithImpl<$Res>
    extends _$MigrationRouteDataCopyWithImpl<$Res, _$MigrationRouteDataImpl>
    implements _$$MigrationRouteDataImplCopyWith<$Res> {
  __$$MigrationRouteDataImplCopyWithImpl(_$MigrationRouteDataImpl _value,
      $Res Function(_$MigrationRouteDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of MigrationRouteData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sourceManga = null,
  }) {
    return _then(_$MigrationRouteDataImpl(
      sourceManga: null == sourceManga
          ? _value.sourceManga
          : sourceManga // ignore: cast_nullable_to_non_nullable
              as Fragment$MangaDto,
    ));
  }
}

/// @nodoc

class _$MigrationRouteDataImpl implements _MigrationRouteData {
  const _$MigrationRouteDataImpl({required this.sourceManga});

  @override
  final Fragment$MangaDto sourceManga;

  @override
  String toString() {
    return 'MigrationRouteData(sourceManga: $sourceManga)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MigrationRouteDataImpl &&
            (identical(other.sourceManga, sourceManga) ||
                other.sourceManga == sourceManga));
  }

  @override
  int get hashCode => Object.hash(runtimeType, sourceManga);

  /// Create a copy of MigrationRouteData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MigrationRouteDataImplCopyWith<_$MigrationRouteDataImpl> get copyWith =>
      __$$MigrationRouteDataImplCopyWithImpl<_$MigrationRouteDataImpl>(
          this, _$identity);
}

abstract class _MigrationRouteData implements MigrationRouteData {
  const factory _MigrationRouteData(
          {required final Fragment$MangaDto sourceManga}) =
      _$MigrationRouteDataImpl;

  @override
  Fragment$MangaDto get sourceManga;

  /// Create a copy of MigrationRouteData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MigrationRouteDataImplCopyWith<_$MigrationRouteDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$MigrationSearchRouteData {
  Fragment$MangaDto get sourceManga => throw _privateConstructorUsedError;
  Fragment$SourceDto get targetSource => throw _privateConstructorUsedError;

  /// Create a copy of MigrationSearchRouteData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MigrationSearchRouteDataCopyWith<MigrationSearchRouteData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MigrationSearchRouteDataCopyWith<$Res> {
  factory $MigrationSearchRouteDataCopyWith(MigrationSearchRouteData value,
          $Res Function(MigrationSearchRouteData) then) =
      _$MigrationSearchRouteDataCopyWithImpl<$Res, MigrationSearchRouteData>;
  @useResult
  $Res call({Fragment$MangaDto sourceManga, Fragment$SourceDto targetSource});
}

/// @nodoc
class _$MigrationSearchRouteDataCopyWithImpl<$Res,
        $Val extends MigrationSearchRouteData>
    implements $MigrationSearchRouteDataCopyWith<$Res> {
  _$MigrationSearchRouteDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MigrationSearchRouteData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sourceManga = null,
    Object? targetSource = null,
  }) {
    return _then(_value.copyWith(
      sourceManga: null == sourceManga
          ? _value.sourceManga
          : sourceManga // ignore: cast_nullable_to_non_nullable
              as Fragment$MangaDto,
      targetSource: null == targetSource
          ? _value.targetSource
          : targetSource // ignore: cast_nullable_to_non_nullable
              as Fragment$SourceDto,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MigrationSearchRouteDataImplCopyWith<$Res>
    implements $MigrationSearchRouteDataCopyWith<$Res> {
  factory _$$MigrationSearchRouteDataImplCopyWith(
          _$MigrationSearchRouteDataImpl value,
          $Res Function(_$MigrationSearchRouteDataImpl) then) =
      __$$MigrationSearchRouteDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Fragment$MangaDto sourceManga, Fragment$SourceDto targetSource});
}

/// @nodoc
class __$$MigrationSearchRouteDataImplCopyWithImpl<$Res>
    extends _$MigrationSearchRouteDataCopyWithImpl<$Res,
        _$MigrationSearchRouteDataImpl>
    implements _$$MigrationSearchRouteDataImplCopyWith<$Res> {
  __$$MigrationSearchRouteDataImplCopyWithImpl(
      _$MigrationSearchRouteDataImpl _value,
      $Res Function(_$MigrationSearchRouteDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of MigrationSearchRouteData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sourceManga = null,
    Object? targetSource = null,
  }) {
    return _then(_$MigrationSearchRouteDataImpl(
      sourceManga: null == sourceManga
          ? _value.sourceManga
          : sourceManga // ignore: cast_nullable_to_non_nullable
              as Fragment$MangaDto,
      targetSource: null == targetSource
          ? _value.targetSource
          : targetSource // ignore: cast_nullable_to_non_nullable
              as Fragment$SourceDto,
    ));
  }
}

/// @nodoc

class _$MigrationSearchRouteDataImpl implements _MigrationSearchRouteData {
  const _$MigrationSearchRouteDataImpl(
      {required this.sourceManga, required this.targetSource});

  @override
  final Fragment$MangaDto sourceManga;
  @override
  final Fragment$SourceDto targetSource;

  @override
  String toString() {
    return 'MigrationSearchRouteData(sourceManga: $sourceManga, targetSource: $targetSource)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MigrationSearchRouteDataImpl &&
            (identical(other.sourceManga, sourceManga) ||
                other.sourceManga == sourceManga) &&
            (identical(other.targetSource, targetSource) ||
                other.targetSource == targetSource));
  }

  @override
  int get hashCode => Object.hash(runtimeType, sourceManga, targetSource);

  /// Create a copy of MigrationSearchRouteData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MigrationSearchRouteDataImplCopyWith<_$MigrationSearchRouteDataImpl>
      get copyWith => __$$MigrationSearchRouteDataImplCopyWithImpl<
          _$MigrationSearchRouteDataImpl>(this, _$identity);
}

abstract class _MigrationSearchRouteData implements MigrationSearchRouteData {
  const factory _MigrationSearchRouteData(
          {required final Fragment$MangaDto sourceManga,
          required final Fragment$SourceDto targetSource}) =
      _$MigrationSearchRouteDataImpl;

  @override
  Fragment$MangaDto get sourceManga;
  @override
  Fragment$SourceDto get targetSource;

  /// Create a copy of MigrationSearchRouteData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MigrationSearchRouteDataImplCopyWith<_$MigrationSearchRouteDataImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$MigrationPreviewRouteData {
  Fragment$MangaDto get sourceManga => throw _privateConstructorUsedError;
  Fragment$MangaDto get targetManga => throw _privateConstructorUsedError;
  Fragment$SourceDto get targetSource => throw _privateConstructorUsedError;

  /// Create a copy of MigrationPreviewRouteData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MigrationPreviewRouteDataCopyWith<MigrationPreviewRouteData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MigrationPreviewRouteDataCopyWith<$Res> {
  factory $MigrationPreviewRouteDataCopyWith(MigrationPreviewRouteData value,
          $Res Function(MigrationPreviewRouteData) then) =
      _$MigrationPreviewRouteDataCopyWithImpl<$Res, MigrationPreviewRouteData>;
  @useResult
  $Res call(
      {Fragment$MangaDto sourceManga,
      Fragment$MangaDto targetManga,
      Fragment$SourceDto targetSource});
}

/// @nodoc
class _$MigrationPreviewRouteDataCopyWithImpl<$Res,
        $Val extends MigrationPreviewRouteData>
    implements $MigrationPreviewRouteDataCopyWith<$Res> {
  _$MigrationPreviewRouteDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MigrationPreviewRouteData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sourceManga = null,
    Object? targetManga = null,
    Object? targetSource = null,
  }) {
    return _then(_value.copyWith(
      sourceManga: null == sourceManga
          ? _value.sourceManga
          : sourceManga // ignore: cast_nullable_to_non_nullable
              as Fragment$MangaDto,
      targetManga: null == targetManga
          ? _value.targetManga
          : targetManga // ignore: cast_nullable_to_non_nullable
              as Fragment$MangaDto,
      targetSource: null == targetSource
          ? _value.targetSource
          : targetSource // ignore: cast_nullable_to_non_nullable
              as Fragment$SourceDto,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MigrationPreviewRouteDataImplCopyWith<$Res>
    implements $MigrationPreviewRouteDataCopyWith<$Res> {
  factory _$$MigrationPreviewRouteDataImplCopyWith(
          _$MigrationPreviewRouteDataImpl value,
          $Res Function(_$MigrationPreviewRouteDataImpl) then) =
      __$$MigrationPreviewRouteDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Fragment$MangaDto sourceManga,
      Fragment$MangaDto targetManga,
      Fragment$SourceDto targetSource});
}

/// @nodoc
class __$$MigrationPreviewRouteDataImplCopyWithImpl<$Res>
    extends _$MigrationPreviewRouteDataCopyWithImpl<$Res,
        _$MigrationPreviewRouteDataImpl>
    implements _$$MigrationPreviewRouteDataImplCopyWith<$Res> {
  __$$MigrationPreviewRouteDataImplCopyWithImpl(
      _$MigrationPreviewRouteDataImpl _value,
      $Res Function(_$MigrationPreviewRouteDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of MigrationPreviewRouteData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sourceManga = null,
    Object? targetManga = null,
    Object? targetSource = null,
  }) {
    return _then(_$MigrationPreviewRouteDataImpl(
      sourceManga: null == sourceManga
          ? _value.sourceManga
          : sourceManga // ignore: cast_nullable_to_non_nullable
              as Fragment$MangaDto,
      targetManga: null == targetManga
          ? _value.targetManga
          : targetManga // ignore: cast_nullable_to_non_nullable
              as Fragment$MangaDto,
      targetSource: null == targetSource
          ? _value.targetSource
          : targetSource // ignore: cast_nullable_to_non_nullable
              as Fragment$SourceDto,
    ));
  }
}

/// @nodoc

class _$MigrationPreviewRouteDataImpl implements _MigrationPreviewRouteData {
  const _$MigrationPreviewRouteDataImpl(
      {required this.sourceManga,
      required this.targetManga,
      required this.targetSource});

  @override
  final Fragment$MangaDto sourceManga;
  @override
  final Fragment$MangaDto targetManga;
  @override
  final Fragment$SourceDto targetSource;

  @override
  String toString() {
    return 'MigrationPreviewRouteData(sourceManga: $sourceManga, targetManga: $targetManga, targetSource: $targetSource)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MigrationPreviewRouteDataImpl &&
            (identical(other.sourceManga, sourceManga) ||
                other.sourceManga == sourceManga) &&
            (identical(other.targetManga, targetManga) ||
                other.targetManga == targetManga) &&
            (identical(other.targetSource, targetSource) ||
                other.targetSource == targetSource));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, sourceManga, targetManga, targetSource);

  /// Create a copy of MigrationPreviewRouteData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MigrationPreviewRouteDataImplCopyWith<_$MigrationPreviewRouteDataImpl>
      get copyWith => __$$MigrationPreviewRouteDataImplCopyWithImpl<
          _$MigrationPreviewRouteDataImpl>(this, _$identity);
}

abstract class _MigrationPreviewRouteData implements MigrationPreviewRouteData {
  const factory _MigrationPreviewRouteData(
          {required final Fragment$MangaDto sourceManga,
          required final Fragment$MangaDto targetManga,
          required final Fragment$SourceDto targetSource}) =
      _$MigrationPreviewRouteDataImpl;

  @override
  Fragment$MangaDto get sourceManga;
  @override
  Fragment$MangaDto get targetManga;
  @override
  Fragment$SourceDto get targetSource;

  /// Create a copy of MigrationPreviewRouteData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MigrationPreviewRouteDataImplCopyWith<_$MigrationPreviewRouteDataImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$MigrationProgressRouteData {
  Fragment$MangaDto get sourceManga => throw _privateConstructorUsedError;
  Fragment$MangaDto get targetManga => throw _privateConstructorUsedError;
  Fragment$SourceDto get targetSource => throw _privateConstructorUsedError;
  MigrationOption get options => throw _privateConstructorUsedError;

  /// Create a copy of MigrationProgressRouteData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MigrationProgressRouteDataCopyWith<MigrationProgressRouteData>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MigrationProgressRouteDataCopyWith<$Res> {
  factory $MigrationProgressRouteDataCopyWith(MigrationProgressRouteData value,
          $Res Function(MigrationProgressRouteData) then) =
      _$MigrationProgressRouteDataCopyWithImpl<$Res,
          MigrationProgressRouteData>;
  @useResult
  $Res call(
      {Fragment$MangaDto sourceManga,
      Fragment$MangaDto targetManga,
      Fragment$SourceDto targetSource,
      MigrationOption options});

  $MigrationOptionCopyWith<$Res> get options;
}

/// @nodoc
class _$MigrationProgressRouteDataCopyWithImpl<$Res,
        $Val extends MigrationProgressRouteData>
    implements $MigrationProgressRouteDataCopyWith<$Res> {
  _$MigrationProgressRouteDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MigrationProgressRouteData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sourceManga = null,
    Object? targetManga = null,
    Object? targetSource = null,
    Object? options = null,
  }) {
    return _then(_value.copyWith(
      sourceManga: null == sourceManga
          ? _value.sourceManga
          : sourceManga // ignore: cast_nullable_to_non_nullable
              as Fragment$MangaDto,
      targetManga: null == targetManga
          ? _value.targetManga
          : targetManga // ignore: cast_nullable_to_non_nullable
              as Fragment$MangaDto,
      targetSource: null == targetSource
          ? _value.targetSource
          : targetSource // ignore: cast_nullable_to_non_nullable
              as Fragment$SourceDto,
      options: null == options
          ? _value.options
          : options // ignore: cast_nullable_to_non_nullable
              as MigrationOption,
    ) as $Val);
  }

  /// Create a copy of MigrationProgressRouteData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MigrationOptionCopyWith<$Res> get options {
    return $MigrationOptionCopyWith<$Res>(_value.options, (value) {
      return _then(_value.copyWith(options: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MigrationProgressRouteDataImplCopyWith<$Res>
    implements $MigrationProgressRouteDataCopyWith<$Res> {
  factory _$$MigrationProgressRouteDataImplCopyWith(
          _$MigrationProgressRouteDataImpl value,
          $Res Function(_$MigrationProgressRouteDataImpl) then) =
      __$$MigrationProgressRouteDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Fragment$MangaDto sourceManga,
      Fragment$MangaDto targetManga,
      Fragment$SourceDto targetSource,
      MigrationOption options});

  @override
  $MigrationOptionCopyWith<$Res> get options;
}

/// @nodoc
class __$$MigrationProgressRouteDataImplCopyWithImpl<$Res>
    extends _$MigrationProgressRouteDataCopyWithImpl<$Res,
        _$MigrationProgressRouteDataImpl>
    implements _$$MigrationProgressRouteDataImplCopyWith<$Res> {
  __$$MigrationProgressRouteDataImplCopyWithImpl(
      _$MigrationProgressRouteDataImpl _value,
      $Res Function(_$MigrationProgressRouteDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of MigrationProgressRouteData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sourceManga = null,
    Object? targetManga = null,
    Object? targetSource = null,
    Object? options = null,
  }) {
    return _then(_$MigrationProgressRouteDataImpl(
      sourceManga: null == sourceManga
          ? _value.sourceManga
          : sourceManga // ignore: cast_nullable_to_non_nullable
              as Fragment$MangaDto,
      targetManga: null == targetManga
          ? _value.targetManga
          : targetManga // ignore: cast_nullable_to_non_nullable
              as Fragment$MangaDto,
      targetSource: null == targetSource
          ? _value.targetSource
          : targetSource // ignore: cast_nullable_to_non_nullable
              as Fragment$SourceDto,
      options: null == options
          ? _value.options
          : options // ignore: cast_nullable_to_non_nullable
              as MigrationOption,
    ));
  }
}

/// @nodoc

class _$MigrationProgressRouteDataImpl implements _MigrationProgressRouteData {
  const _$MigrationProgressRouteDataImpl(
      {required this.sourceManga,
      required this.targetManga,
      required this.targetSource,
      required this.options});

  @override
  final Fragment$MangaDto sourceManga;
  @override
  final Fragment$MangaDto targetManga;
  @override
  final Fragment$SourceDto targetSource;
  @override
  final MigrationOption options;

  @override
  String toString() {
    return 'MigrationProgressRouteData(sourceManga: $sourceManga, targetManga: $targetManga, targetSource: $targetSource, options: $options)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MigrationProgressRouteDataImpl &&
            (identical(other.sourceManga, sourceManga) ||
                other.sourceManga == sourceManga) &&
            (identical(other.targetManga, targetManga) ||
                other.targetManga == targetManga) &&
            (identical(other.targetSource, targetSource) ||
                other.targetSource == targetSource) &&
            (identical(other.options, options) || other.options == options));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, sourceManga, targetManga, targetSource, options);

  /// Create a copy of MigrationProgressRouteData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MigrationProgressRouteDataImplCopyWith<_$MigrationProgressRouteDataImpl>
      get copyWith => __$$MigrationProgressRouteDataImplCopyWithImpl<
          _$MigrationProgressRouteDataImpl>(this, _$identity);
}

abstract class _MigrationProgressRouteData
    implements MigrationProgressRouteData {
  const factory _MigrationProgressRouteData(
          {required final Fragment$MangaDto sourceManga,
          required final Fragment$MangaDto targetManga,
          required final Fragment$SourceDto targetSource,
          required final MigrationOption options}) =
      _$MigrationProgressRouteDataImpl;

  @override
  Fragment$MangaDto get sourceManga;
  @override
  Fragment$MangaDto get targetManga;
  @override
  Fragment$SourceDto get targetSource;
  @override
  MigrationOption get options;

  /// Create a copy of MigrationProgressRouteData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MigrationProgressRouteDataImplCopyWith<_$MigrationProgressRouteDataImpl>
      get copyWith => throw _privateConstructorUsedError;
}
