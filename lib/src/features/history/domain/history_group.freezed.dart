// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'history_group.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$HistoryGroup {
  String get title => throw _privateConstructorUsedError;
  List<Fragment$ChapterWithMangaDto> get items =>
      throw _privateConstructorUsedError;

  /// Create a copy of HistoryGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HistoryGroupCopyWith<HistoryGroup> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HistoryGroupCopyWith<$Res> {
  factory $HistoryGroupCopyWith(
          HistoryGroup value, $Res Function(HistoryGroup) then) =
      _$HistoryGroupCopyWithImpl<$Res, HistoryGroup>;
  @useResult
  $Res call({String title, List<Fragment$ChapterWithMangaDto> items});
}

/// @nodoc
class _$HistoryGroupCopyWithImpl<$Res, $Val extends HistoryGroup>
    implements $HistoryGroupCopyWith<$Res> {
  _$HistoryGroupCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HistoryGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? items = null,
  }) {
    return _then(_value.copyWith(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<Fragment$ChapterWithMangaDto>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HistoryGroupImplCopyWith<$Res>
    implements $HistoryGroupCopyWith<$Res> {
  factory _$$HistoryGroupImplCopyWith(
          _$HistoryGroupImpl value, $Res Function(_$HistoryGroupImpl) then) =
      __$$HistoryGroupImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String title, List<Fragment$ChapterWithMangaDto> items});
}

/// @nodoc
class __$$HistoryGroupImplCopyWithImpl<$Res>
    extends _$HistoryGroupCopyWithImpl<$Res, _$HistoryGroupImpl>
    implements _$$HistoryGroupImplCopyWith<$Res> {
  __$$HistoryGroupImplCopyWithImpl(
      _$HistoryGroupImpl _value, $Res Function(_$HistoryGroupImpl) _then)
      : super(_value, _then);

  /// Create a copy of HistoryGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? items = null,
  }) {
    return _then(_$HistoryGroupImpl(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<Fragment$ChapterWithMangaDto>,
    ));
  }
}

/// @nodoc

class _$HistoryGroupImpl extends _HistoryGroup {
  const _$HistoryGroupImpl(
      {required this.title,
      required final List<Fragment$ChapterWithMangaDto> items})
      : _items = items,
        super._();

  @override
  final String title;
  final List<Fragment$ChapterWithMangaDto> _items;
  @override
  List<Fragment$ChapterWithMangaDto> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  String toString() {
    return 'HistoryGroup(title: $title, items: $items)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HistoryGroupImpl &&
            (identical(other.title, title) || other.title == title) &&
            const DeepCollectionEquality().equals(other._items, _items));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, title, const DeepCollectionEquality().hash(_items));

  /// Create a copy of HistoryGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HistoryGroupImplCopyWith<_$HistoryGroupImpl> get copyWith =>
      __$$HistoryGroupImplCopyWithImpl<_$HistoryGroupImpl>(this, _$identity);
}

abstract class _HistoryGroup extends HistoryGroup {
  const factory _HistoryGroup(
          {required final String title,
          required final List<Fragment$ChapterWithMangaDto> items}) =
      _$HistoryGroupImpl;
  const _HistoryGroup._() : super._();

  @override
  String get title;
  @override
  List<Fragment$ChapterWithMangaDto> get items;

  /// Create a copy of HistoryGroup
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HistoryGroupImplCopyWith<_$HistoryGroupImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
