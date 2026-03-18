import 'package:catalyst/src/utils/misc/scalars.dart';

class Input$BindTrackInput {
  factory Input$BindTrackInput({
    String? clientMutationId,
    required int mangaId,
    required String remoteId,
    required int trackerId,
  }) =>
      Input$BindTrackInput._({
        if (clientMutationId != null) r'clientMutationId': clientMutationId,
        r'mangaId': mangaId,
        r'remoteId': remoteId,
        r'trackerId': trackerId,
      });

  Input$BindTrackInput._(this._$data);

  factory Input$BindTrackInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('clientMutationId')) {
      final l$clientMutationId = data['clientMutationId'];
      result$data['clientMutationId'] = (l$clientMutationId as String?);
    }
    final l$mangaId = data['mangaId'];
    result$data['mangaId'] = (l$mangaId as int);
    final l$remoteId = data['remoteId'];
    result$data['remoteId'] = longStringFromJson(l$remoteId);
    final l$trackerId = data['trackerId'];
    result$data['trackerId'] = (l$trackerId as int);
    return Input$BindTrackInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get clientMutationId => (_$data['clientMutationId'] as String?);

  int get mangaId => (_$data['mangaId'] as int);

  String get remoteId => (_$data['remoteId'] as String);

  int get trackerId => (_$data['trackerId'] as int);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('clientMutationId')) {
      final l$clientMutationId = clientMutationId;
      result$data['clientMutationId'] = l$clientMutationId;
    }
    final l$mangaId = mangaId;
    result$data['mangaId'] = l$mangaId;
    final l$remoteId = remoteId;
    result$data['remoteId'] = longStringToJson(l$remoteId);
    final l$trackerId = trackerId;
    result$data['trackerId'] = l$trackerId;
    return result$data;
  }

  CopyWith$Input$BindTrackInput<Input$BindTrackInput> get copyWith =>
      CopyWith$Input$BindTrackInput(
        this,
        (i) => i,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$BindTrackInput || runtimeType != other.runtimeType) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (_$data.containsKey('clientMutationId') !=
        other._$data.containsKey('clientMutationId')) {
      return false;
    }
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    final l$mangaId = mangaId;
    final lOther$mangaId = other.mangaId;
    if (l$mangaId != lOther$mangaId) {
      return false;
    }
    final l$remoteId = remoteId;
    final lOther$remoteId = other.remoteId;
    if (l$remoteId != lOther$remoteId) {
      return false;
    }
    final l$trackerId = trackerId;
    final lOther$trackerId = other.trackerId;
    if (l$trackerId != lOther$trackerId) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$clientMutationId = clientMutationId;
    final l$mangaId = mangaId;
    final l$remoteId = remoteId;
    final l$trackerId = trackerId;
    return Object.hashAll([
      _$data.containsKey('clientMutationId') ? l$clientMutationId : const {},
      l$mangaId,
      l$remoteId,
      l$trackerId,
    ]);
  }
}

abstract class CopyWith$Input$BindTrackInput<TRes> {
  factory CopyWith$Input$BindTrackInput(
    Input$BindTrackInput instance,
    TRes Function(Input$BindTrackInput) then,
  ) = _CopyWithImpl$Input$BindTrackInput;

  factory CopyWith$Input$BindTrackInput.stub(TRes res) =
      _CopyWithStubImpl$Input$BindTrackInput;

  TRes call({
    String? clientMutationId,
    int? mangaId,
    String? remoteId,
    int? trackerId,
  });
}

class _CopyWithImpl$Input$BindTrackInput<TRes>
    implements CopyWith$Input$BindTrackInput<TRes> {
  _CopyWithImpl$Input$BindTrackInput(
    this._instance,
    this._then,
  );

  final Input$BindTrackInput _instance;

  final TRes Function(Input$BindTrackInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? clientMutationId = _undefined,
    Object? mangaId = _undefined,
    Object? remoteId = _undefined,
    Object? trackerId = _undefined,
  }) =>
      _then(Input$BindTrackInput._({
        ..._instance._$data,
        if (clientMutationId != _undefined)
          'clientMutationId': (clientMutationId as String?),
        if (mangaId != _undefined && mangaId != null)
          'mangaId': (mangaId as int),
        if (remoteId != _undefined && remoteId != null)
          'remoteId': (remoteId as String),
        if (trackerId != _undefined && trackerId != null)
          'trackerId': (trackerId as int),
      }));
}

class _CopyWithStubImpl$Input$BindTrackInput<TRes>
    implements CopyWith$Input$BindTrackInput<TRes> {
  _CopyWithStubImpl$Input$BindTrackInput(this._res);

  TRes _res;

  call({
    String? clientMutationId,
    int? mangaId,
    String? remoteId,
    int? trackerId,
  }) =>
      _res;
}

class Input$BooleanFilterInput {
  factory Input$BooleanFilterInput({
    bool? distinctFrom,
    List<bool>? distinctFromAll,
    List<bool>? distinctFromAny,
    bool? equalTo,
    bool? greaterThan,
    bool? greaterThanOrEqualTo,
    List<bool>? $in,
    bool? isNull,
    bool? lessThan,
    bool? lessThanOrEqualTo,
    bool? notDistinctFrom,
    bool? notEqualTo,
    List<bool>? notEqualToAll,
    List<bool>? notEqualToAny,
    List<bool>? notIn,
  }) =>
      Input$BooleanFilterInput._({
        if (distinctFrom != null) r'distinctFrom': distinctFrom,
        if (distinctFromAll != null) r'distinctFromAll': distinctFromAll,
        if (distinctFromAny != null) r'distinctFromAny': distinctFromAny,
        if (equalTo != null) r'equalTo': equalTo,
        if (greaterThan != null) r'greaterThan': greaterThan,
        if (greaterThanOrEqualTo != null)
          r'greaterThanOrEqualTo': greaterThanOrEqualTo,
        if ($in != null) r'in': $in,
        if (isNull != null) r'isNull': isNull,
        if (lessThan != null) r'lessThan': lessThan,
        if (lessThanOrEqualTo != null) r'lessThanOrEqualTo': lessThanOrEqualTo,
        if (notDistinctFrom != null) r'notDistinctFrom': notDistinctFrom,
        if (notEqualTo != null) r'notEqualTo': notEqualTo,
        if (notEqualToAll != null) r'notEqualToAll': notEqualToAll,
        if (notEqualToAny != null) r'notEqualToAny': notEqualToAny,
        if (notIn != null) r'notIn': notIn,
      });

  Input$BooleanFilterInput._(this._$data);

  factory Input$BooleanFilterInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('distinctFrom')) {
      final l$distinctFrom = data['distinctFrom'];
      result$data['distinctFrom'] = (l$distinctFrom as bool?);
    }
    if (data.containsKey('distinctFromAll')) {
      final l$distinctFromAll = data['distinctFromAll'];
      result$data['distinctFromAll'] = (l$distinctFromAll as List<dynamic>?)
          ?.map((e) => (e as bool))
          .toList();
    }
    if (data.containsKey('distinctFromAny')) {
      final l$distinctFromAny = data['distinctFromAny'];
      result$data['distinctFromAny'] = (l$distinctFromAny as List<dynamic>?)
          ?.map((e) => (e as bool))
          .toList();
    }
    if (data.containsKey('equalTo')) {
      final l$equalTo = data['equalTo'];
      result$data['equalTo'] = (l$equalTo as bool?);
    }
    if (data.containsKey('greaterThan')) {
      final l$greaterThan = data['greaterThan'];
      result$data['greaterThan'] = (l$greaterThan as bool?);
    }
    if (data.containsKey('greaterThanOrEqualTo')) {
      final l$greaterThanOrEqualTo = data['greaterThanOrEqualTo'];
      result$data['greaterThanOrEqualTo'] = (l$greaterThanOrEqualTo as bool?);
    }
    if (data.containsKey('in')) {
      final l$$in = data['in'];
      result$data['in'] =
          (l$$in as List<dynamic>?)?.map((e) => (e as bool)).toList();
    }
    if (data.containsKey('isNull')) {
      final l$isNull = data['isNull'];
      result$data['isNull'] = (l$isNull as bool?);
    }
    if (data.containsKey('lessThan')) {
      final l$lessThan = data['lessThan'];
      result$data['lessThan'] = (l$lessThan as bool?);
    }
    if (data.containsKey('lessThanOrEqualTo')) {
      final l$lessThanOrEqualTo = data['lessThanOrEqualTo'];
      result$data['lessThanOrEqualTo'] = (l$lessThanOrEqualTo as bool?);
    }
    if (data.containsKey('notDistinctFrom')) {
      final l$notDistinctFrom = data['notDistinctFrom'];
      result$data['notDistinctFrom'] = (l$notDistinctFrom as bool?);
    }
    if (data.containsKey('notEqualTo')) {
      final l$notEqualTo = data['notEqualTo'];
      result$data['notEqualTo'] = (l$notEqualTo as bool?);
    }
    if (data.containsKey('notEqualToAll')) {
      final l$notEqualToAll = data['notEqualToAll'];
      result$data['notEqualToAll'] =
          (l$notEqualToAll as List<dynamic>?)?.map((e) => (e as bool)).toList();
    }
    if (data.containsKey('notEqualToAny')) {
      final l$notEqualToAny = data['notEqualToAny'];
      result$data['notEqualToAny'] =
          (l$notEqualToAny as List<dynamic>?)?.map((e) => (e as bool)).toList();
    }
    if (data.containsKey('notIn')) {
      final l$notIn = data['notIn'];
      result$data['notIn'] =
          (l$notIn as List<dynamic>?)?.map((e) => (e as bool)).toList();
    }
    return Input$BooleanFilterInput._(result$data);
  }

  Map<String, dynamic> _$data;

  bool? get distinctFrom => (_$data['distinctFrom'] as bool?);

  List<bool>? get distinctFromAll => (_$data['distinctFromAll'] as List<bool>?);

  List<bool>? get distinctFromAny => (_$data['distinctFromAny'] as List<bool>?);

  bool? get equalTo => (_$data['equalTo'] as bool?);

  bool? get greaterThan => (_$data['greaterThan'] as bool?);

  bool? get greaterThanOrEqualTo => (_$data['greaterThanOrEqualTo'] as bool?);

  List<bool>? get $in => (_$data['in'] as List<bool>?);

  bool? get isNull => (_$data['isNull'] as bool?);

  bool? get lessThan => (_$data['lessThan'] as bool?);

  bool? get lessThanOrEqualTo => (_$data['lessThanOrEqualTo'] as bool?);

  bool? get notDistinctFrom => (_$data['notDistinctFrom'] as bool?);

  bool? get notEqualTo => (_$data['notEqualTo'] as bool?);

  List<bool>? get notEqualToAll => (_$data['notEqualToAll'] as List<bool>?);

  List<bool>? get notEqualToAny => (_$data['notEqualToAny'] as List<bool>?);

  List<bool>? get notIn => (_$data['notIn'] as List<bool>?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('distinctFrom')) {
      final l$distinctFrom = distinctFrom;
      result$data['distinctFrom'] = l$distinctFrom;
    }
    if (_$data.containsKey('distinctFromAll')) {
      final l$distinctFromAll = distinctFromAll;
      result$data['distinctFromAll'] =
          l$distinctFromAll?.map((e) => e).toList();
    }
    if (_$data.containsKey('distinctFromAny')) {
      final l$distinctFromAny = distinctFromAny;
      result$data['distinctFromAny'] =
          l$distinctFromAny?.map((e) => e).toList();
    }
    if (_$data.containsKey('equalTo')) {
      final l$equalTo = equalTo;
      result$data['equalTo'] = l$equalTo;
    }
    if (_$data.containsKey('greaterThan')) {
      final l$greaterThan = greaterThan;
      result$data['greaterThan'] = l$greaterThan;
    }
    if (_$data.containsKey('greaterThanOrEqualTo')) {
      final l$greaterThanOrEqualTo = greaterThanOrEqualTo;
      result$data['greaterThanOrEqualTo'] = l$greaterThanOrEqualTo;
    }
    if (_$data.containsKey('in')) {
      final l$$in = $in;
      result$data['in'] = l$$in?.map((e) => e).toList();
    }
    if (_$data.containsKey('isNull')) {
      final l$isNull = isNull;
      result$data['isNull'] = l$isNull;
    }
    if (_$data.containsKey('lessThan')) {
      final l$lessThan = lessThan;
      result$data['lessThan'] = l$lessThan;
    }
    if (_$data.containsKey('lessThanOrEqualTo')) {
      final l$lessThanOrEqualTo = lessThanOrEqualTo;
      result$data['lessThanOrEqualTo'] = l$lessThanOrEqualTo;
    }
    if (_$data.containsKey('notDistinctFrom')) {
      final l$notDistinctFrom = notDistinctFrom;
      result$data['notDistinctFrom'] = l$notDistinctFrom;
    }
    if (_$data.containsKey('notEqualTo')) {
      final l$notEqualTo = notEqualTo;
      result$data['notEqualTo'] = l$notEqualTo;
    }
    if (_$data.containsKey('notEqualToAll')) {
      final l$notEqualToAll = notEqualToAll;
      result$data['notEqualToAll'] = l$notEqualToAll?.map((e) => e).toList();
    }
    if (_$data.containsKey('notEqualToAny')) {
      final l$notEqualToAny = notEqualToAny;
      result$data['notEqualToAny'] = l$notEqualToAny?.map((e) => e).toList();
    }
    if (_$data.containsKey('notIn')) {
      final l$notIn = notIn;
      result$data['notIn'] = l$notIn?.map((e) => e).toList();
    }
    return result$data;
  }

  CopyWith$Input$BooleanFilterInput<Input$BooleanFilterInput> get copyWith =>
      CopyWith$Input$BooleanFilterInput(
        this,
        (i) => i,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$BooleanFilterInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$distinctFrom = distinctFrom;
    final lOther$distinctFrom = other.distinctFrom;
    if (_$data.containsKey('distinctFrom') !=
        other._$data.containsKey('distinctFrom')) {
      return false;
    }
    if (l$distinctFrom != lOther$distinctFrom) {
      return false;
    }
    final l$distinctFromAll = distinctFromAll;
    final lOther$distinctFromAll = other.distinctFromAll;
    if (_$data.containsKey('distinctFromAll') !=
        other._$data.containsKey('distinctFromAll')) {
      return false;
    }
    if (l$distinctFromAll != null && lOther$distinctFromAll != null) {
      if (l$distinctFromAll.length != lOther$distinctFromAll.length) {
        return false;
      }
      for (int i = 0; i < l$distinctFromAll.length; i++) {
        final l$distinctFromAll$entry = l$distinctFromAll[i];
        final lOther$distinctFromAll$entry = lOther$distinctFromAll[i];
        if (l$distinctFromAll$entry != lOther$distinctFromAll$entry) {
          return false;
        }
      }
    } else if (l$distinctFromAll != lOther$distinctFromAll) {
      return false;
    }
    final l$distinctFromAny = distinctFromAny;
    final lOther$distinctFromAny = other.distinctFromAny;
    if (_$data.containsKey('distinctFromAny') !=
        other._$data.containsKey('distinctFromAny')) {
      return false;
    }
    if (l$distinctFromAny != null && lOther$distinctFromAny != null) {
      if (l$distinctFromAny.length != lOther$distinctFromAny.length) {
        return false;
      }
      for (int i = 0; i < l$distinctFromAny.length; i++) {
        final l$distinctFromAny$entry = l$distinctFromAny[i];
        final lOther$distinctFromAny$entry = lOther$distinctFromAny[i];
        if (l$distinctFromAny$entry != lOther$distinctFromAny$entry) {
          return false;
        }
      }
    } else if (l$distinctFromAny != lOther$distinctFromAny) {
      return false;
    }
    final l$equalTo = equalTo;
    final lOther$equalTo = other.equalTo;
    if (_$data.containsKey('equalTo') != other._$data.containsKey('equalTo')) {
      return false;
    }
    if (l$equalTo != lOther$equalTo) {
      return false;
    }
    final l$greaterThan = greaterThan;
    final lOther$greaterThan = other.greaterThan;
    if (_$data.containsKey('greaterThan') !=
        other._$data.containsKey('greaterThan')) {
      return false;
    }
    if (l$greaterThan != lOther$greaterThan) {
      return false;
    }
    final l$greaterThanOrEqualTo = greaterThanOrEqualTo;
    final lOther$greaterThanOrEqualTo = other.greaterThanOrEqualTo;
    if (_$data.containsKey('greaterThanOrEqualTo') !=
        other._$data.containsKey('greaterThanOrEqualTo')) {
      return false;
    }
    if (l$greaterThanOrEqualTo != lOther$greaterThanOrEqualTo) {
      return false;
    }
    final l$$in = $in;
    final lOther$$in = other.$in;
    if (_$data.containsKey('in') != other._$data.containsKey('in')) {
      return false;
    }
    if (l$$in != null && lOther$$in != null) {
      if (l$$in.length != lOther$$in.length) {
        return false;
      }
      for (int i = 0; i < l$$in.length; i++) {
        final l$$in$entry = l$$in[i];
        final lOther$$in$entry = lOther$$in[i];
        if (l$$in$entry != lOther$$in$entry) {
          return false;
        }
      }
    } else if (l$$in != lOther$$in) {
      return false;
    }
    final l$isNull = isNull;
    final lOther$isNull = other.isNull;
    if (_$data.containsKey('isNull') != other._$data.containsKey('isNull')) {
      return false;
    }
    if (l$isNull != lOther$isNull) {
      return false;
    }
    final l$lessThan = lessThan;
    final lOther$lessThan = other.lessThan;
    if (_$data.containsKey('lessThan') !=
        other._$data.containsKey('lessThan')) {
      return false;
    }
    if (l$lessThan != lOther$lessThan) {
      return false;
    }
    final l$lessThanOrEqualTo = lessThanOrEqualTo;
    final lOther$lessThanOrEqualTo = other.lessThanOrEqualTo;
    if (_$data.containsKey('lessThanOrEqualTo') !=
        other._$data.containsKey('lessThanOrEqualTo')) {
      return false;
    }
    if (l$lessThanOrEqualTo != lOther$lessThanOrEqualTo) {
      return false;
    }
    final l$notDistinctFrom = notDistinctFrom;
    final lOther$notDistinctFrom = other.notDistinctFrom;
    if (_$data.containsKey('notDistinctFrom') !=
        other._$data.containsKey('notDistinctFrom')) {
      return false;
    }
    if (l$notDistinctFrom != lOther$notDistinctFrom) {
      return false;
    }
    final l$notEqualTo = notEqualTo;
    final lOther$notEqualTo = other.notEqualTo;
    if (_$data.containsKey('notEqualTo') !=
        other._$data.containsKey('notEqualTo')) {
      return false;
    }
    if (l$notEqualTo != lOther$notEqualTo) {
      return false;
    }
    final l$notEqualToAll = notEqualToAll;
    final lOther$notEqualToAll = other.notEqualToAll;
    if (_$data.containsKey('notEqualToAll') !=
        other._$data.containsKey('notEqualToAll')) {
      return false;
    }
    if (l$notEqualToAll != null && lOther$notEqualToAll != null) {
      if (l$notEqualToAll.length != lOther$notEqualToAll.length) {
        return false;
      }
      for (int i = 0; i < l$notEqualToAll.length; i++) {
        final l$notEqualToAll$entry = l$notEqualToAll[i];
        final lOther$notEqualToAll$entry = lOther$notEqualToAll[i];
        if (l$notEqualToAll$entry != lOther$notEqualToAll$entry) {
          return false;
        }
      }
    } else if (l$notEqualToAll != lOther$notEqualToAll) {
      return false;
    }
    final l$notEqualToAny = notEqualToAny;
    final lOther$notEqualToAny = other.notEqualToAny;
    if (_$data.containsKey('notEqualToAny') !=
        other._$data.containsKey('notEqualToAny')) {
      return false;
    }
    if (l$notEqualToAny != null && lOther$notEqualToAny != null) {
      if (l$notEqualToAny.length != lOther$notEqualToAny.length) {
        return false;
      }
      for (int i = 0; i < l$notEqualToAny.length; i++) {
        final l$notEqualToAny$entry = l$notEqualToAny[i];
        final lOther$notEqualToAny$entry = lOther$notEqualToAny[i];
        if (l$notEqualToAny$entry != lOther$notEqualToAny$entry) {
          return false;
        }
      }
    } else if (l$notEqualToAny != lOther$notEqualToAny) {
      return false;
    }
    final l$notIn = notIn;
    final lOther$notIn = other.notIn;
    if (_$data.containsKey('notIn') != other._$data.containsKey('notIn')) {
      return false;
    }
    if (l$notIn != null && lOther$notIn != null) {
      if (l$notIn.length != lOther$notIn.length) {
        return false;
      }
      for (int i = 0; i < l$notIn.length; i++) {
        final l$notIn$entry = l$notIn[i];
        final lOther$notIn$entry = lOther$notIn[i];
        if (l$notIn$entry != lOther$notIn$entry) {
          return false;
        }
      }
    } else if (l$notIn != lOther$notIn) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$distinctFrom = distinctFrom;
    final l$distinctFromAll = distinctFromAll;
    final l$distinctFromAny = distinctFromAny;
    final l$equalTo = equalTo;
    final l$greaterThan = greaterThan;
    final l$greaterThanOrEqualTo = greaterThanOrEqualTo;
    final l$$in = $in;
    final l$isNull = isNull;
    final l$lessThan = lessThan;
    final l$lessThanOrEqualTo = lessThanOrEqualTo;
    final l$notDistinctFrom = notDistinctFrom;
    final l$notEqualTo = notEqualTo;
    final l$notEqualToAll = notEqualToAll;
    final l$notEqualToAny = notEqualToAny;
    final l$notIn = notIn;
    return Object.hashAll([
      _$data.containsKey('distinctFrom') ? l$distinctFrom : const {},
      _$data.containsKey('distinctFromAll')
          ? l$distinctFromAll == null
              ? null
              : Object.hashAll(l$distinctFromAll.map((v) => v))
          : const {},
      _$data.containsKey('distinctFromAny')
          ? l$distinctFromAny == null
              ? null
              : Object.hashAll(l$distinctFromAny.map((v) => v))
          : const {},
      _$data.containsKey('equalTo') ? l$equalTo : const {},
      _$data.containsKey('greaterThan') ? l$greaterThan : const {},
      _$data.containsKey('greaterThanOrEqualTo')
          ? l$greaterThanOrEqualTo
          : const {},
      _$data.containsKey('in')
          ? l$$in == null
              ? null
              : Object.hashAll(l$$in.map((v) => v))
          : const {},
      _$data.containsKey('isNull') ? l$isNull : const {},
      _$data.containsKey('lessThan') ? l$lessThan : const {},
      _$data.containsKey('lessThanOrEqualTo') ? l$lessThanOrEqualTo : const {},
      _$data.containsKey('notDistinctFrom') ? l$notDistinctFrom : const {},
      _$data.containsKey('notEqualTo') ? l$notEqualTo : const {},
      _$data.containsKey('notEqualToAll')
          ? l$notEqualToAll == null
              ? null
              : Object.hashAll(l$notEqualToAll.map((v) => v))
          : const {},
      _$data.containsKey('notEqualToAny')
          ? l$notEqualToAny == null
              ? null
              : Object.hashAll(l$notEqualToAny.map((v) => v))
          : const {},
      _$data.containsKey('notIn')
          ? l$notIn == null
              ? null
              : Object.hashAll(l$notIn.map((v) => v))
          : const {},
    ]);
  }
}

abstract class CopyWith$Input$BooleanFilterInput<TRes> {
  factory CopyWith$Input$BooleanFilterInput(
    Input$BooleanFilterInput instance,
    TRes Function(Input$BooleanFilterInput) then,
  ) = _CopyWithImpl$Input$BooleanFilterInput;

  factory CopyWith$Input$BooleanFilterInput.stub(TRes res) =
      _CopyWithStubImpl$Input$BooleanFilterInput;

  TRes call({
    bool? distinctFrom,
    List<bool>? distinctFromAll,
    List<bool>? distinctFromAny,
    bool? equalTo,
    bool? greaterThan,
    bool? greaterThanOrEqualTo,
    List<bool>? $in,
    bool? isNull,
    bool? lessThan,
    bool? lessThanOrEqualTo,
    bool? notDistinctFrom,
    bool? notEqualTo,
    List<bool>? notEqualToAll,
    List<bool>? notEqualToAny,
    List<bool>? notIn,
  });
}

class _CopyWithImpl$Input$BooleanFilterInput<TRes>
    implements CopyWith$Input$BooleanFilterInput<TRes> {
  _CopyWithImpl$Input$BooleanFilterInput(
    this._instance,
    this._then,
  );

  final Input$BooleanFilterInput _instance;

  final TRes Function(Input$BooleanFilterInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? distinctFrom = _undefined,
    Object? distinctFromAll = _undefined,
    Object? distinctFromAny = _undefined,
    Object? equalTo = _undefined,
    Object? greaterThan = _undefined,
    Object? greaterThanOrEqualTo = _undefined,
    Object? $in = _undefined,
    Object? isNull = _undefined,
    Object? lessThan = _undefined,
    Object? lessThanOrEqualTo = _undefined,
    Object? notDistinctFrom = _undefined,
    Object? notEqualTo = _undefined,
    Object? notEqualToAll = _undefined,
    Object? notEqualToAny = _undefined,
    Object? notIn = _undefined,
  }) =>
      _then(Input$BooleanFilterInput._({
        ..._instance._$data,
        if (distinctFrom != _undefined) 'distinctFrom': (distinctFrom as bool?),
        if (distinctFromAll != _undefined)
          'distinctFromAll': (distinctFromAll as List<bool>?),
        if (distinctFromAny != _undefined)
          'distinctFromAny': (distinctFromAny as List<bool>?),
        if (equalTo != _undefined) 'equalTo': (equalTo as bool?),
        if (greaterThan != _undefined) 'greaterThan': (greaterThan as bool?),
        if (greaterThanOrEqualTo != _undefined)
          'greaterThanOrEqualTo': (greaterThanOrEqualTo as bool?),
        if ($in != _undefined) 'in': ($in as List<bool>?),
        if (isNull != _undefined) 'isNull': (isNull as bool?),
        if (lessThan != _undefined) 'lessThan': (lessThan as bool?),
        if (lessThanOrEqualTo != _undefined)
          'lessThanOrEqualTo': (lessThanOrEqualTo as bool?),
        if (notDistinctFrom != _undefined)
          'notDistinctFrom': (notDistinctFrom as bool?),
        if (notEqualTo != _undefined) 'notEqualTo': (notEqualTo as bool?),
        if (notEqualToAll != _undefined)
          'notEqualToAll': (notEqualToAll as List<bool>?),
        if (notEqualToAny != _undefined)
          'notEqualToAny': (notEqualToAny as List<bool>?),
        if (notIn != _undefined) 'notIn': (notIn as List<bool>?),
      }));
}

class _CopyWithStubImpl$Input$BooleanFilterInput<TRes>
    implements CopyWith$Input$BooleanFilterInput<TRes> {
  _CopyWithStubImpl$Input$BooleanFilterInput(this._res);

  TRes _res;

  call({
    bool? distinctFrom,
    List<bool>? distinctFromAll,
    List<bool>? distinctFromAny,
    bool? equalTo,
    bool? greaterThan,
    bool? greaterThanOrEqualTo,
    List<bool>? $in,
    bool? isNull,
    bool? lessThan,
    bool? lessThanOrEqualTo,
    bool? notDistinctFrom,
    bool? notEqualTo,
    List<bool>? notEqualToAll,
    List<bool>? notEqualToAny,
    List<bool>? notIn,
  }) =>
      _res;
}

class Input$CategoryConditionInput {
  factory Input$CategoryConditionInput({
    bool? $default,
    int? id,
    String? name,
    int? order,
  }) =>
      Input$CategoryConditionInput._({
        if ($default != null) r'default': $default,
        if (id != null) r'id': id,
        if (name != null) r'name': name,
        if (order != null) r'order': order,
      });

  Input$CategoryConditionInput._(this._$data);

  factory Input$CategoryConditionInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('default')) {
      final l$$default = data['default'];
      result$data['default'] = (l$$default as bool?);
    }
    if (data.containsKey('id')) {
      final l$id = data['id'];
      result$data['id'] = (l$id as int?);
    }
    if (data.containsKey('name')) {
      final l$name = data['name'];
      result$data['name'] = (l$name as String?);
    }
    if (data.containsKey('order')) {
      final l$order = data['order'];
      result$data['order'] = (l$order as int?);
    }
    return Input$CategoryConditionInput._(result$data);
  }

  Map<String, dynamic> _$data;

  bool? get $default => (_$data['default'] as bool?);

  int? get id => (_$data['id'] as int?);

  String? get name => (_$data['name'] as String?);

  int? get order => (_$data['order'] as int?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('default')) {
      final l$$default = $default;
      result$data['default'] = l$$default;
    }
    if (_$data.containsKey('id')) {
      final l$id = id;
      result$data['id'] = l$id;
    }
    if (_$data.containsKey('name')) {
      final l$name = name;
      result$data['name'] = l$name;
    }
    if (_$data.containsKey('order')) {
      final l$order = order;
      result$data['order'] = l$order;
    }
    return result$data;
  }

  CopyWith$Input$CategoryConditionInput<Input$CategoryConditionInput>
      get copyWith => CopyWith$Input$CategoryConditionInput(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$CategoryConditionInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$$default = $default;
    final lOther$$default = other.$default;
    if (_$data.containsKey('default') != other._$data.containsKey('default')) {
      return false;
    }
    if (l$$default != lOther$$default) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (_$data.containsKey('id') != other._$data.containsKey('id')) {
      return false;
    }
    if (l$id != lOther$id) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (_$data.containsKey('name') != other._$data.containsKey('name')) {
      return false;
    }
    if (l$name != lOther$name) {
      return false;
    }
    final l$order = order;
    final lOther$order = other.order;
    if (_$data.containsKey('order') != other._$data.containsKey('order')) {
      return false;
    }
    if (l$order != lOther$order) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$$default = $default;
    final l$id = id;
    final l$name = name;
    final l$order = order;
    return Object.hashAll([
      _$data.containsKey('default') ? l$$default : const {},
      _$data.containsKey('id') ? l$id : const {},
      _$data.containsKey('name') ? l$name : const {},
      _$data.containsKey('order') ? l$order : const {},
    ]);
  }
}

abstract class CopyWith$Input$CategoryConditionInput<TRes> {
  factory CopyWith$Input$CategoryConditionInput(
    Input$CategoryConditionInput instance,
    TRes Function(Input$CategoryConditionInput) then,
  ) = _CopyWithImpl$Input$CategoryConditionInput;

  factory CopyWith$Input$CategoryConditionInput.stub(TRes res) =
      _CopyWithStubImpl$Input$CategoryConditionInput;

  TRes call({
    bool? $default,
    int? id,
    String? name,
    int? order,
  });
}

class _CopyWithImpl$Input$CategoryConditionInput<TRes>
    implements CopyWith$Input$CategoryConditionInput<TRes> {
  _CopyWithImpl$Input$CategoryConditionInput(
    this._instance,
    this._then,
  );

  final Input$CategoryConditionInput _instance;

  final TRes Function(Input$CategoryConditionInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? $default = _undefined,
    Object? id = _undefined,
    Object? name = _undefined,
    Object? order = _undefined,
  }) =>
      _then(Input$CategoryConditionInput._({
        ..._instance._$data,
        if ($default != _undefined) 'default': ($default as bool?),
        if (id != _undefined) 'id': (id as int?),
        if (name != _undefined) 'name': (name as String?),
        if (order != _undefined) 'order': (order as int?),
      }));
}

class _CopyWithStubImpl$Input$CategoryConditionInput<TRes>
    implements CopyWith$Input$CategoryConditionInput<TRes> {
  _CopyWithStubImpl$Input$CategoryConditionInput(this._res);

  TRes _res;

  call({
    bool? $default,
    int? id,
    String? name,
    int? order,
  }) =>
      _res;
}

class Input$CategoryFilterInput {
  factory Input$CategoryFilterInput({
    List<Input$CategoryFilterInput>? and,
    Input$BooleanFilterInput? $default,
    Input$IntFilterInput? id,
    Input$StringFilterInput? name,
    Input$CategoryFilterInput? not,
    List<Input$CategoryFilterInput>? or,
    Input$IntFilterInput? order,
  }) =>
      Input$CategoryFilterInput._({
        if (and != null) r'and': and,
        if ($default != null) r'default': $default,
        if (id != null) r'id': id,
        if (name != null) r'name': name,
        if (not != null) r'not': not,
        if (or != null) r'or': or,
        if (order != null) r'order': order,
      });

  Input$CategoryFilterInput._(this._$data);

  factory Input$CategoryFilterInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('and')) {
      final l$and = data['and'];
      result$data['and'] = (l$and as List<dynamic>?)
          ?.map((e) =>
              Input$CategoryFilterInput.fromJson((e as Map<String, dynamic>)))
          .toList();
    }
    if (data.containsKey('default')) {
      final l$$default = data['default'];
      result$data['default'] = l$$default == null
          ? null
          : Input$BooleanFilterInput.fromJson(
              (l$$default as Map<String, dynamic>));
    }
    if (data.containsKey('id')) {
      final l$id = data['id'];
      result$data['id'] = l$id == null
          ? null
          : Input$IntFilterInput.fromJson((l$id as Map<String, dynamic>));
    }
    if (data.containsKey('name')) {
      final l$name = data['name'];
      result$data['name'] = l$name == null
          ? null
          : Input$StringFilterInput.fromJson((l$name as Map<String, dynamic>));
    }
    if (data.containsKey('not')) {
      final l$not = data['not'];
      result$data['not'] = l$not == null
          ? null
          : Input$CategoryFilterInput.fromJson((l$not as Map<String, dynamic>));
    }
    if (data.containsKey('or')) {
      final l$or = data['or'];
      result$data['or'] = (l$or as List<dynamic>?)
          ?.map((e) =>
              Input$CategoryFilterInput.fromJson((e as Map<String, dynamic>)))
          .toList();
    }
    if (data.containsKey('order')) {
      final l$order = data['order'];
      result$data['order'] = l$order == null
          ? null
          : Input$IntFilterInput.fromJson((l$order as Map<String, dynamic>));
    }
    return Input$CategoryFilterInput._(result$data);
  }

  Map<String, dynamic> _$data;

  List<Input$CategoryFilterInput>? get and =>
      (_$data['and'] as List<Input$CategoryFilterInput>?);

  Input$BooleanFilterInput? get $default =>
      (_$data['default'] as Input$BooleanFilterInput?);

  Input$IntFilterInput? get id => (_$data['id'] as Input$IntFilterInput?);

  Input$StringFilterInput? get name =>
      (_$data['name'] as Input$StringFilterInput?);

  Input$CategoryFilterInput? get not =>
      (_$data['not'] as Input$CategoryFilterInput?);

  List<Input$CategoryFilterInput>? get or =>
      (_$data['or'] as List<Input$CategoryFilterInput>?);

  Input$IntFilterInput? get order => (_$data['order'] as Input$IntFilterInput?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('and')) {
      final l$and = and;
      result$data['and'] = l$and?.map((e) => e.toJson()).toList();
    }
    if (_$data.containsKey('default')) {
      final l$$default = $default;
      result$data['default'] = l$$default?.toJson();
    }
    if (_$data.containsKey('id')) {
      final l$id = id;
      result$data['id'] = l$id?.toJson();
    }
    if (_$data.containsKey('name')) {
      final l$name = name;
      result$data['name'] = l$name?.toJson();
    }
    if (_$data.containsKey('not')) {
      final l$not = not;
      result$data['not'] = l$not?.toJson();
    }
    if (_$data.containsKey('or')) {
      final l$or = or;
      result$data['or'] = l$or?.map((e) => e.toJson()).toList();
    }
    if (_$data.containsKey('order')) {
      final l$order = order;
      result$data['order'] = l$order?.toJson();
    }
    return result$data;
  }

  CopyWith$Input$CategoryFilterInput<Input$CategoryFilterInput> get copyWith =>
      CopyWith$Input$CategoryFilterInput(
        this,
        (i) => i,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$CategoryFilterInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$and = and;
    final lOther$and = other.and;
    if (_$data.containsKey('and') != other._$data.containsKey('and')) {
      return false;
    }
    if (l$and != null && lOther$and != null) {
      if (l$and.length != lOther$and.length) {
        return false;
      }
      for (int i = 0; i < l$and.length; i++) {
        final l$and$entry = l$and[i];
        final lOther$and$entry = lOther$and[i];
        if (l$and$entry != lOther$and$entry) {
          return false;
        }
      }
    } else if (l$and != lOther$and) {
      return false;
    }
    final l$$default = $default;
    final lOther$$default = other.$default;
    if (_$data.containsKey('default') != other._$data.containsKey('default')) {
      return false;
    }
    if (l$$default != lOther$$default) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (_$data.containsKey('id') != other._$data.containsKey('id')) {
      return false;
    }
    if (l$id != lOther$id) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (_$data.containsKey('name') != other._$data.containsKey('name')) {
      return false;
    }
    if (l$name != lOther$name) {
      return false;
    }
    final l$not = not;
    final lOther$not = other.not;
    if (_$data.containsKey('not') != other._$data.containsKey('not')) {
      return false;
    }
    if (l$not != lOther$not) {
      return false;
    }
    final l$or = or;
    final lOther$or = other.or;
    if (_$data.containsKey('or') != other._$data.containsKey('or')) {
      return false;
    }
    if (l$or != null && lOther$or != null) {
      if (l$or.length != lOther$or.length) {
        return false;
      }
      for (int i = 0; i < l$or.length; i++) {
        final l$or$entry = l$or[i];
        final lOther$or$entry = lOther$or[i];
        if (l$or$entry != lOther$or$entry) {
          return false;
        }
      }
    } else if (l$or != lOther$or) {
      return false;
    }
    final l$order = order;
    final lOther$order = other.order;
    if (_$data.containsKey('order') != other._$data.containsKey('order')) {
      return false;
    }
    if (l$order != lOther$order) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$and = and;
    final l$$default = $default;
    final l$id = id;
    final l$name = name;
    final l$not = not;
    final l$or = or;
    final l$order = order;
    return Object.hashAll([
      _$data.containsKey('and')
          ? l$and == null
              ? null
              : Object.hashAll(l$and.map((v) => v))
          : const {},
      _$data.containsKey('default') ? l$$default : const {},
      _$data.containsKey('id') ? l$id : const {},
      _$data.containsKey('name') ? l$name : const {},
      _$data.containsKey('not') ? l$not : const {},
      _$data.containsKey('or')
          ? l$or == null
              ? null
              : Object.hashAll(l$or.map((v) => v))
          : const {},
      _$data.containsKey('order') ? l$order : const {},
    ]);
  }
}

abstract class CopyWith$Input$CategoryFilterInput<TRes> {
  factory CopyWith$Input$CategoryFilterInput(
    Input$CategoryFilterInput instance,
    TRes Function(Input$CategoryFilterInput) then,
  ) = _CopyWithImpl$Input$CategoryFilterInput;

  factory CopyWith$Input$CategoryFilterInput.stub(TRes res) =
      _CopyWithStubImpl$Input$CategoryFilterInput;

  TRes call({
    List<Input$CategoryFilterInput>? and,
    Input$BooleanFilterInput? $default,
    Input$IntFilterInput? id,
    Input$StringFilterInput? name,
    Input$CategoryFilterInput? not,
    List<Input$CategoryFilterInput>? or,
    Input$IntFilterInput? order,
  });
  TRes and(
      Iterable<Input$CategoryFilterInput>? Function(
              Iterable<
                  CopyWith$Input$CategoryFilterInput<
                      Input$CategoryFilterInput>>?)
          _fn);
  CopyWith$Input$BooleanFilterInput<TRes> get $default;
  CopyWith$Input$IntFilterInput<TRes> get id;
  CopyWith$Input$StringFilterInput<TRes> get name;
  CopyWith$Input$CategoryFilterInput<TRes> get not;
  TRes or(
      Iterable<Input$CategoryFilterInput>? Function(
              Iterable<
                  CopyWith$Input$CategoryFilterInput<
                      Input$CategoryFilterInput>>?)
          _fn);
  CopyWith$Input$IntFilterInput<TRes> get order;
}

class _CopyWithImpl$Input$CategoryFilterInput<TRes>
    implements CopyWith$Input$CategoryFilterInput<TRes> {
  _CopyWithImpl$Input$CategoryFilterInput(
    this._instance,
    this._then,
  );

  final Input$CategoryFilterInput _instance;

  final TRes Function(Input$CategoryFilterInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? and = _undefined,
    Object? $default = _undefined,
    Object? id = _undefined,
    Object? name = _undefined,
    Object? not = _undefined,
    Object? or = _undefined,
    Object? order = _undefined,
  }) =>
      _then(Input$CategoryFilterInput._({
        ..._instance._$data,
        if (and != _undefined) 'and': (and as List<Input$CategoryFilterInput>?),
        if ($default != _undefined)
          'default': ($default as Input$BooleanFilterInput?),
        if (id != _undefined) 'id': (id as Input$IntFilterInput?),
        if (name != _undefined) 'name': (name as Input$StringFilterInput?),
        if (not != _undefined) 'not': (not as Input$CategoryFilterInput?),
        if (or != _undefined) 'or': (or as List<Input$CategoryFilterInput>?),
        if (order != _undefined) 'order': (order as Input$IntFilterInput?),
      }));

  TRes and(
          Iterable<Input$CategoryFilterInput>? Function(
                  Iterable<
                      CopyWith$Input$CategoryFilterInput<
                          Input$CategoryFilterInput>>?)
              _fn) =>
      call(
          and: _fn(_instance.and?.map((e) => CopyWith$Input$CategoryFilterInput(
                e,
                (i) => i,
              )))?.toList());

  CopyWith$Input$BooleanFilterInput<TRes> get $default {
    final local$$default = _instance.$default;
    return local$$default == null
        ? CopyWith$Input$BooleanFilterInput.stub(_then(_instance))
        : CopyWith$Input$BooleanFilterInput(
            local$$default, (e) => call($default: e));
  }

  CopyWith$Input$IntFilterInput<TRes> get id {
    final local$id = _instance.id;
    return local$id == null
        ? CopyWith$Input$IntFilterInput.stub(_then(_instance))
        : CopyWith$Input$IntFilterInput(local$id, (e) => call(id: e));
  }

  CopyWith$Input$StringFilterInput<TRes> get name {
    final local$name = _instance.name;
    return local$name == null
        ? CopyWith$Input$StringFilterInput.stub(_then(_instance))
        : CopyWith$Input$StringFilterInput(local$name, (e) => call(name: e));
  }

  CopyWith$Input$CategoryFilterInput<TRes> get not {
    final local$not = _instance.not;
    return local$not == null
        ? CopyWith$Input$CategoryFilterInput.stub(_then(_instance))
        : CopyWith$Input$CategoryFilterInput(local$not, (e) => call(not: e));
  }

  TRes or(
          Iterable<Input$CategoryFilterInput>? Function(
                  Iterable<
                      CopyWith$Input$CategoryFilterInput<
                          Input$CategoryFilterInput>>?)
              _fn) =>
      call(
          or: _fn(_instance.or?.map((e) => CopyWith$Input$CategoryFilterInput(
                e,
                (i) => i,
              )))?.toList());

  CopyWith$Input$IntFilterInput<TRes> get order {
    final local$order = _instance.order;
    return local$order == null
        ? CopyWith$Input$IntFilterInput.stub(_then(_instance))
        : CopyWith$Input$IntFilterInput(local$order, (e) => call(order: e));
  }
}

class _CopyWithStubImpl$Input$CategoryFilterInput<TRes>
    implements CopyWith$Input$CategoryFilterInput<TRes> {
  _CopyWithStubImpl$Input$CategoryFilterInput(this._res);

  TRes _res;

  call({
    List<Input$CategoryFilterInput>? and,
    Input$BooleanFilterInput? $default,
    Input$IntFilterInput? id,
    Input$StringFilterInput? name,
    Input$CategoryFilterInput? not,
    List<Input$CategoryFilterInput>? or,
    Input$IntFilterInput? order,
  }) =>
      _res;

  and(_fn) => _res;

  CopyWith$Input$BooleanFilterInput<TRes> get $default =>
      CopyWith$Input$BooleanFilterInput.stub(_res);

  CopyWith$Input$IntFilterInput<TRes> get id =>
      CopyWith$Input$IntFilterInput.stub(_res);

  CopyWith$Input$StringFilterInput<TRes> get name =>
      CopyWith$Input$StringFilterInput.stub(_res);

  CopyWith$Input$CategoryFilterInput<TRes> get not =>
      CopyWith$Input$CategoryFilterInput.stub(_res);

  or(_fn) => _res;

  CopyWith$Input$IntFilterInput<TRes> get order =>
      CopyWith$Input$IntFilterInput.stub(_res);
}

class Input$CategoryMetaTypeInput {
  factory Input$CategoryMetaTypeInput({
    required int categoryId,
    required String key,
    required String value,
  }) =>
      Input$CategoryMetaTypeInput._({
        r'categoryId': categoryId,
        r'key': key,
        r'value': value,
      });

  Input$CategoryMetaTypeInput._(this._$data);

  factory Input$CategoryMetaTypeInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$categoryId = data['categoryId'];
    result$data['categoryId'] = (l$categoryId as int);
    final l$key = data['key'];
    result$data['key'] = (l$key as String);
    final l$value = data['value'];
    result$data['value'] = (l$value as String);
    return Input$CategoryMetaTypeInput._(result$data);
  }

  Map<String, dynamic> _$data;

  int get categoryId => (_$data['categoryId'] as int);

  String get key => (_$data['key'] as String);

  String get value => (_$data['value'] as String);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$categoryId = categoryId;
    result$data['categoryId'] = l$categoryId;
    final l$key = key;
    result$data['key'] = l$key;
    final l$value = value;
    result$data['value'] = l$value;
    return result$data;
  }

  CopyWith$Input$CategoryMetaTypeInput<Input$CategoryMetaTypeInput>
      get copyWith => CopyWith$Input$CategoryMetaTypeInput(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$CategoryMetaTypeInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$categoryId = categoryId;
    final lOther$categoryId = other.categoryId;
    if (l$categoryId != lOther$categoryId) {
      return false;
    }
    final l$key = key;
    final lOther$key = other.key;
    if (l$key != lOther$key) {
      return false;
    }
    final l$value = value;
    final lOther$value = other.value;
    if (l$value != lOther$value) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$categoryId = categoryId;
    final l$key = key;
    final l$value = value;
    return Object.hashAll([
      l$categoryId,
      l$key,
      l$value,
    ]);
  }
}

abstract class CopyWith$Input$CategoryMetaTypeInput<TRes> {
  factory CopyWith$Input$CategoryMetaTypeInput(
    Input$CategoryMetaTypeInput instance,
    TRes Function(Input$CategoryMetaTypeInput) then,
  ) = _CopyWithImpl$Input$CategoryMetaTypeInput;

  factory CopyWith$Input$CategoryMetaTypeInput.stub(TRes res) =
      _CopyWithStubImpl$Input$CategoryMetaTypeInput;

  TRes call({
    int? categoryId,
    String? key,
    String? value,
  });
}

class _CopyWithImpl$Input$CategoryMetaTypeInput<TRes>
    implements CopyWith$Input$CategoryMetaTypeInput<TRes> {
  _CopyWithImpl$Input$CategoryMetaTypeInput(
    this._instance,
    this._then,
  );

  final Input$CategoryMetaTypeInput _instance;

  final TRes Function(Input$CategoryMetaTypeInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? categoryId = _undefined,
    Object? key = _undefined,
    Object? value = _undefined,
  }) =>
      _then(Input$CategoryMetaTypeInput._({
        ..._instance._$data,
        if (categoryId != _undefined && categoryId != null)
          'categoryId': (categoryId as int),
        if (key != _undefined && key != null) 'key': (key as String),
        if (value != _undefined && value != null) 'value': (value as String),
      }));
}

class _CopyWithStubImpl$Input$CategoryMetaTypeInput<TRes>
    implements CopyWith$Input$CategoryMetaTypeInput<TRes> {
  _CopyWithStubImpl$Input$CategoryMetaTypeInput(this._res);

  TRes _res;

  call({
    int? categoryId,
    String? key,
    String? value,
  }) =>
      _res;
}

class Input$CategoryOrderInput {
  factory Input$CategoryOrderInput({
    required Enum$CategoryOrderBy by,
    Enum$SortOrder? byType,
  }) =>
      Input$CategoryOrderInput._({
        r'by': by,
        if (byType != null) r'byType': byType,
      });

  Input$CategoryOrderInput._(this._$data);

  factory Input$CategoryOrderInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$by = data['by'];
    result$data['by'] = fromJson$Enum$CategoryOrderBy((l$by as String));
    if (data.containsKey('byType')) {
      final l$byType = data['byType'];
      result$data['byType'] = l$byType == null
          ? null
          : fromJson$Enum$SortOrder((l$byType as String));
    }
    return Input$CategoryOrderInput._(result$data);
  }

  Map<String, dynamic> _$data;

  Enum$CategoryOrderBy get by => (_$data['by'] as Enum$CategoryOrderBy);

  Enum$SortOrder? get byType => (_$data['byType'] as Enum$SortOrder?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$by = by;
    result$data['by'] = toJson$Enum$CategoryOrderBy(l$by);
    if (_$data.containsKey('byType')) {
      final l$byType = byType;
      result$data['byType'] =
          l$byType == null ? null : toJson$Enum$SortOrder(l$byType);
    }
    return result$data;
  }

  CopyWith$Input$CategoryOrderInput<Input$CategoryOrderInput> get copyWith =>
      CopyWith$Input$CategoryOrderInput(
        this,
        (i) => i,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$CategoryOrderInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$by = by;
    final lOther$by = other.by;
    if (l$by != lOther$by) {
      return false;
    }
    final l$byType = byType;
    final lOther$byType = other.byType;
    if (_$data.containsKey('byType') != other._$data.containsKey('byType')) {
      return false;
    }
    if (l$byType != lOther$byType) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$by = by;
    final l$byType = byType;
    return Object.hashAll([
      l$by,
      _$data.containsKey('byType') ? l$byType : const {},
    ]);
  }
}

abstract class CopyWith$Input$CategoryOrderInput<TRes> {
  factory CopyWith$Input$CategoryOrderInput(
    Input$CategoryOrderInput instance,
    TRes Function(Input$CategoryOrderInput) then,
  ) = _CopyWithImpl$Input$CategoryOrderInput;

  factory CopyWith$Input$CategoryOrderInput.stub(TRes res) =
      _CopyWithStubImpl$Input$CategoryOrderInput;

  TRes call({
    Enum$CategoryOrderBy? by,
    Enum$SortOrder? byType,
  });
}

class _CopyWithImpl$Input$CategoryOrderInput<TRes>
    implements CopyWith$Input$CategoryOrderInput<TRes> {
  _CopyWithImpl$Input$CategoryOrderInput(
    this._instance,
    this._then,
  );

  final Input$CategoryOrderInput _instance;

  final TRes Function(Input$CategoryOrderInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? by = _undefined,
    Object? byType = _undefined,
  }) =>
      _then(Input$CategoryOrderInput._({
        ..._instance._$data,
        if (by != _undefined && by != null) 'by': (by as Enum$CategoryOrderBy),
        if (byType != _undefined) 'byType': (byType as Enum$SortOrder?),
      }));
}

class _CopyWithStubImpl$Input$CategoryOrderInput<TRes>
    implements CopyWith$Input$CategoryOrderInput<TRes> {
  _CopyWithStubImpl$Input$CategoryOrderInput(this._res);

  TRes _res;

  call({
    Enum$CategoryOrderBy? by,
    Enum$SortOrder? byType,
  }) =>
      _res;
}

class Input$ChapterConditionInput {
  factory Input$ChapterConditionInput({
    double? chapterNumber,
    String? fetchedAt,
    int? id,
    bool? isBookmarked,
    bool? isDownloaded,
    bool? isRead,
    int? lastPageRead,
    String? lastReadAt,
    int? mangaId,
    String? name,
    int? pageCount,
    String? realUrl,
    String? scanlator,
    int? sourceOrder,
    String? uploadDate,
    String? url,
  }) =>
      Input$ChapterConditionInput._({
        if (chapterNumber != null) r'chapterNumber': chapterNumber,
        if (fetchedAt != null) r'fetchedAt': fetchedAt,
        if (id != null) r'id': id,
        if (isBookmarked != null) r'isBookmarked': isBookmarked,
        if (isDownloaded != null) r'isDownloaded': isDownloaded,
        if (isRead != null) r'isRead': isRead,
        if (lastPageRead != null) r'lastPageRead': lastPageRead,
        if (lastReadAt != null) r'lastReadAt': lastReadAt,
        if (mangaId != null) r'mangaId': mangaId,
        if (name != null) r'name': name,
        if (pageCount != null) r'pageCount': pageCount,
        if (realUrl != null) r'realUrl': realUrl,
        if (scanlator != null) r'scanlator': scanlator,
        if (sourceOrder != null) r'sourceOrder': sourceOrder,
        if (uploadDate != null) r'uploadDate': uploadDate,
        if (url != null) r'url': url,
      });

  Input$ChapterConditionInput._(this._$data);

  factory Input$ChapterConditionInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('chapterNumber')) {
      final l$chapterNumber = data['chapterNumber'];
      result$data['chapterNumber'] = (l$chapterNumber as num?)?.toDouble();
    }
    if (data.containsKey('fetchedAt')) {
      final l$fetchedAt = data['fetchedAt'];
      result$data['fetchedAt'] =
          l$fetchedAt == null ? null : longStringFromJson(l$fetchedAt);
    }
    if (data.containsKey('id')) {
      final l$id = data['id'];
      result$data['id'] = (l$id as int?);
    }
    if (data.containsKey('isBookmarked')) {
      final l$isBookmarked = data['isBookmarked'];
      result$data['isBookmarked'] = (l$isBookmarked as bool?);
    }
    if (data.containsKey('isDownloaded')) {
      final l$isDownloaded = data['isDownloaded'];
      result$data['isDownloaded'] = (l$isDownloaded as bool?);
    }
    if (data.containsKey('isRead')) {
      final l$isRead = data['isRead'];
      result$data['isRead'] = (l$isRead as bool?);
    }
    if (data.containsKey('lastPageRead')) {
      final l$lastPageRead = data['lastPageRead'];
      result$data['lastPageRead'] = (l$lastPageRead as int?);
    }
    if (data.containsKey('lastReadAt')) {
      final l$lastReadAt = data['lastReadAt'];
      result$data['lastReadAt'] =
          l$lastReadAt == null ? null : longStringFromJson(l$lastReadAt);
    }
    if (data.containsKey('mangaId')) {
      final l$mangaId = data['mangaId'];
      result$data['mangaId'] = (l$mangaId as int?);
    }
    if (data.containsKey('name')) {
      final l$name = data['name'];
      result$data['name'] = (l$name as String?);
    }
    if (data.containsKey('pageCount')) {
      final l$pageCount = data['pageCount'];
      result$data['pageCount'] = (l$pageCount as int?);
    }
    if (data.containsKey('realUrl')) {
      final l$realUrl = data['realUrl'];
      result$data['realUrl'] = (l$realUrl as String?);
    }
    if (data.containsKey('scanlator')) {
      final l$scanlator = data['scanlator'];
      result$data['scanlator'] = (l$scanlator as String?);
    }
    if (data.containsKey('sourceOrder')) {
      final l$sourceOrder = data['sourceOrder'];
      result$data['sourceOrder'] = (l$sourceOrder as int?);
    }
    if (data.containsKey('uploadDate')) {
      final l$uploadDate = data['uploadDate'];
      result$data['uploadDate'] =
          l$uploadDate == null ? null : longStringFromJson(l$uploadDate);
    }
    if (data.containsKey('url')) {
      final l$url = data['url'];
      result$data['url'] = (l$url as String?);
    }
    return Input$ChapterConditionInput._(result$data);
  }

  Map<String, dynamic> _$data;

  double? get chapterNumber => (_$data['chapterNumber'] as double?);

  String? get fetchedAt => (_$data['fetchedAt'] as String?);

  int? get id => (_$data['id'] as int?);

  bool? get isBookmarked => (_$data['isBookmarked'] as bool?);

  bool? get isDownloaded => (_$data['isDownloaded'] as bool?);

  bool? get isRead => (_$data['isRead'] as bool?);

  int? get lastPageRead => (_$data['lastPageRead'] as int?);

  String? get lastReadAt => (_$data['lastReadAt'] as String?);

  int? get mangaId => (_$data['mangaId'] as int?);

  String? get name => (_$data['name'] as String?);

  int? get pageCount => (_$data['pageCount'] as int?);

  String? get realUrl => (_$data['realUrl'] as String?);

  String? get scanlator => (_$data['scanlator'] as String?);

  int? get sourceOrder => (_$data['sourceOrder'] as int?);

  String? get uploadDate => (_$data['uploadDate'] as String?);

  String? get url => (_$data['url'] as String?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('chapterNumber')) {
      final l$chapterNumber = chapterNumber;
      result$data['chapterNumber'] = l$chapterNumber;
    }
    if (_$data.containsKey('fetchedAt')) {
      final l$fetchedAt = fetchedAt;
      result$data['fetchedAt'] =
          l$fetchedAt == null ? null : longStringToJson(l$fetchedAt);
    }
    if (_$data.containsKey('id')) {
      final l$id = id;
      result$data['id'] = l$id;
    }
    if (_$data.containsKey('isBookmarked')) {
      final l$isBookmarked = isBookmarked;
      result$data['isBookmarked'] = l$isBookmarked;
    }
    if (_$data.containsKey('isDownloaded')) {
      final l$isDownloaded = isDownloaded;
      result$data['isDownloaded'] = l$isDownloaded;
    }
    if (_$data.containsKey('isRead')) {
      final l$isRead = isRead;
      result$data['isRead'] = l$isRead;
    }
    if (_$data.containsKey('lastPageRead')) {
      final l$lastPageRead = lastPageRead;
      result$data['lastPageRead'] = l$lastPageRead;
    }
    if (_$data.containsKey('lastReadAt')) {
      final l$lastReadAt = lastReadAt;
      result$data['lastReadAt'] =
          l$lastReadAt == null ? null : longStringToJson(l$lastReadAt);
    }
    if (_$data.containsKey('mangaId')) {
      final l$mangaId = mangaId;
      result$data['mangaId'] = l$mangaId;
    }
    if (_$data.containsKey('name')) {
      final l$name = name;
      result$data['name'] = l$name;
    }
    if (_$data.containsKey('pageCount')) {
      final l$pageCount = pageCount;
      result$data['pageCount'] = l$pageCount;
    }
    if (_$data.containsKey('realUrl')) {
      final l$realUrl = realUrl;
      result$data['realUrl'] = l$realUrl;
    }
    if (_$data.containsKey('scanlator')) {
      final l$scanlator = scanlator;
      result$data['scanlator'] = l$scanlator;
    }
    if (_$data.containsKey('sourceOrder')) {
      final l$sourceOrder = sourceOrder;
      result$data['sourceOrder'] = l$sourceOrder;
    }
    if (_$data.containsKey('uploadDate')) {
      final l$uploadDate = uploadDate;
      result$data['uploadDate'] =
          l$uploadDate == null ? null : longStringToJson(l$uploadDate);
    }
    if (_$data.containsKey('url')) {
      final l$url = url;
      result$data['url'] = l$url;
    }
    return result$data;
  }

  CopyWith$Input$ChapterConditionInput<Input$ChapterConditionInput>
      get copyWith => CopyWith$Input$ChapterConditionInput(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$ChapterConditionInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$chapterNumber = chapterNumber;
    final lOther$chapterNumber = other.chapterNumber;
    if (_$data.containsKey('chapterNumber') !=
        other._$data.containsKey('chapterNumber')) {
      return false;
    }
    if (l$chapterNumber != lOther$chapterNumber) {
      return false;
    }
    final l$fetchedAt = fetchedAt;
    final lOther$fetchedAt = other.fetchedAt;
    if (_$data.containsKey('fetchedAt') !=
        other._$data.containsKey('fetchedAt')) {
      return false;
    }
    if (l$fetchedAt != lOther$fetchedAt) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (_$data.containsKey('id') != other._$data.containsKey('id')) {
      return false;
    }
    if (l$id != lOther$id) {
      return false;
    }
    final l$isBookmarked = isBookmarked;
    final lOther$isBookmarked = other.isBookmarked;
    if (_$data.containsKey('isBookmarked') !=
        other._$data.containsKey('isBookmarked')) {
      return false;
    }
    if (l$isBookmarked != lOther$isBookmarked) {
      return false;
    }
    final l$isDownloaded = isDownloaded;
    final lOther$isDownloaded = other.isDownloaded;
    if (_$data.containsKey('isDownloaded') !=
        other._$data.containsKey('isDownloaded')) {
      return false;
    }
    if (l$isDownloaded != lOther$isDownloaded) {
      return false;
    }
    final l$isRead = isRead;
    final lOther$isRead = other.isRead;
    if (_$data.containsKey('isRead') != other._$data.containsKey('isRead')) {
      return false;
    }
    if (l$isRead != lOther$isRead) {
      return false;
    }
    final l$lastPageRead = lastPageRead;
    final lOther$lastPageRead = other.lastPageRead;
    if (_$data.containsKey('lastPageRead') !=
        other._$data.containsKey('lastPageRead')) {
      return false;
    }
    if (l$lastPageRead != lOther$lastPageRead) {
      return false;
    }
    final l$lastReadAt = lastReadAt;
    final lOther$lastReadAt = other.lastReadAt;
    if (_$data.containsKey('lastReadAt') !=
        other._$data.containsKey('lastReadAt')) {
      return false;
    }
    if (l$lastReadAt != lOther$lastReadAt) {
      return false;
    }
    final l$mangaId = mangaId;
    final lOther$mangaId = other.mangaId;
    if (_$data.containsKey('mangaId') != other._$data.containsKey('mangaId')) {
      return false;
    }
    if (l$mangaId != lOther$mangaId) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (_$data.containsKey('name') != other._$data.containsKey('name')) {
      return false;
    }
    if (l$name != lOther$name) {
      return false;
    }
    final l$pageCount = pageCount;
    final lOther$pageCount = other.pageCount;
    if (_$data.containsKey('pageCount') !=
        other._$data.containsKey('pageCount')) {
      return false;
    }
    if (l$pageCount != lOther$pageCount) {
      return false;
    }
    final l$realUrl = realUrl;
    final lOther$realUrl = other.realUrl;
    if (_$data.containsKey('realUrl') != other._$data.containsKey('realUrl')) {
      return false;
    }
    if (l$realUrl != lOther$realUrl) {
      return false;
    }
    final l$scanlator = scanlator;
    final lOther$scanlator = other.scanlator;
    if (_$data.containsKey('scanlator') !=
        other._$data.containsKey('scanlator')) {
      return false;
    }
    if (l$scanlator != lOther$scanlator) {
      return false;
    }
    final l$sourceOrder = sourceOrder;
    final lOther$sourceOrder = other.sourceOrder;
    if (_$data.containsKey('sourceOrder') !=
        other._$data.containsKey('sourceOrder')) {
      return false;
    }
    if (l$sourceOrder != lOther$sourceOrder) {
      return false;
    }
    final l$uploadDate = uploadDate;
    final lOther$uploadDate = other.uploadDate;
    if (_$data.containsKey('uploadDate') !=
        other._$data.containsKey('uploadDate')) {
      return false;
    }
    if (l$uploadDate != lOther$uploadDate) {
      return false;
    }
    final l$url = url;
    final lOther$url = other.url;
    if (_$data.containsKey('url') != other._$data.containsKey('url')) {
      return false;
    }
    if (l$url != lOther$url) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$chapterNumber = chapterNumber;
    final l$fetchedAt = fetchedAt;
    final l$id = id;
    final l$isBookmarked = isBookmarked;
    final l$isDownloaded = isDownloaded;
    final l$isRead = isRead;
    final l$lastPageRead = lastPageRead;
    final l$lastReadAt = lastReadAt;
    final l$mangaId = mangaId;
    final l$name = name;
    final l$pageCount = pageCount;
    final l$realUrl = realUrl;
    final l$scanlator = scanlator;
    final l$sourceOrder = sourceOrder;
    final l$uploadDate = uploadDate;
    final l$url = url;
    return Object.hashAll([
      _$data.containsKey('chapterNumber') ? l$chapterNumber : const {},
      _$data.containsKey('fetchedAt') ? l$fetchedAt : const {},
      _$data.containsKey('id') ? l$id : const {},
      _$data.containsKey('isBookmarked') ? l$isBookmarked : const {},
      _$data.containsKey('isDownloaded') ? l$isDownloaded : const {},
      _$data.containsKey('isRead') ? l$isRead : const {},
      _$data.containsKey('lastPageRead') ? l$lastPageRead : const {},
      _$data.containsKey('lastReadAt') ? l$lastReadAt : const {},
      _$data.containsKey('mangaId') ? l$mangaId : const {},
      _$data.containsKey('name') ? l$name : const {},
      _$data.containsKey('pageCount') ? l$pageCount : const {},
      _$data.containsKey('realUrl') ? l$realUrl : const {},
      _$data.containsKey('scanlator') ? l$scanlator : const {},
      _$data.containsKey('sourceOrder') ? l$sourceOrder : const {},
      _$data.containsKey('uploadDate') ? l$uploadDate : const {},
      _$data.containsKey('url') ? l$url : const {},
    ]);
  }
}

abstract class CopyWith$Input$ChapterConditionInput<TRes> {
  factory CopyWith$Input$ChapterConditionInput(
    Input$ChapterConditionInput instance,
    TRes Function(Input$ChapterConditionInput) then,
  ) = _CopyWithImpl$Input$ChapterConditionInput;

  factory CopyWith$Input$ChapterConditionInput.stub(TRes res) =
      _CopyWithStubImpl$Input$ChapterConditionInput;

  TRes call({
    double? chapterNumber,
    String? fetchedAt,
    int? id,
    bool? isBookmarked,
    bool? isDownloaded,
    bool? isRead,
    int? lastPageRead,
    String? lastReadAt,
    int? mangaId,
    String? name,
    int? pageCount,
    String? realUrl,
    String? scanlator,
    int? sourceOrder,
    String? uploadDate,
    String? url,
  });
}

class _CopyWithImpl$Input$ChapterConditionInput<TRes>
    implements CopyWith$Input$ChapterConditionInput<TRes> {
  _CopyWithImpl$Input$ChapterConditionInput(
    this._instance,
    this._then,
  );

  final Input$ChapterConditionInput _instance;

  final TRes Function(Input$ChapterConditionInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? chapterNumber = _undefined,
    Object? fetchedAt = _undefined,
    Object? id = _undefined,
    Object? isBookmarked = _undefined,
    Object? isDownloaded = _undefined,
    Object? isRead = _undefined,
    Object? lastPageRead = _undefined,
    Object? lastReadAt = _undefined,
    Object? mangaId = _undefined,
    Object? name = _undefined,
    Object? pageCount = _undefined,
    Object? realUrl = _undefined,
    Object? scanlator = _undefined,
    Object? sourceOrder = _undefined,
    Object? uploadDate = _undefined,
    Object? url = _undefined,
  }) =>
      _then(Input$ChapterConditionInput._({
        ..._instance._$data,
        if (chapterNumber != _undefined)
          'chapterNumber': (chapterNumber as double?),
        if (fetchedAt != _undefined) 'fetchedAt': (fetchedAt as String?),
        if (id != _undefined) 'id': (id as int?),
        if (isBookmarked != _undefined) 'isBookmarked': (isBookmarked as bool?),
        if (isDownloaded != _undefined) 'isDownloaded': (isDownloaded as bool?),
        if (isRead != _undefined) 'isRead': (isRead as bool?),
        if (lastPageRead != _undefined) 'lastPageRead': (lastPageRead as int?),
        if (lastReadAt != _undefined) 'lastReadAt': (lastReadAt as String?),
        if (mangaId != _undefined) 'mangaId': (mangaId as int?),
        if (name != _undefined) 'name': (name as String?),
        if (pageCount != _undefined) 'pageCount': (pageCount as int?),
        if (realUrl != _undefined) 'realUrl': (realUrl as String?),
        if (scanlator != _undefined) 'scanlator': (scanlator as String?),
        if (sourceOrder != _undefined) 'sourceOrder': (sourceOrder as int?),
        if (uploadDate != _undefined) 'uploadDate': (uploadDate as String?),
        if (url != _undefined) 'url': (url as String?),
      }));
}

class _CopyWithStubImpl$Input$ChapterConditionInput<TRes>
    implements CopyWith$Input$ChapterConditionInput<TRes> {
  _CopyWithStubImpl$Input$ChapterConditionInput(this._res);

  TRes _res;

  call({
    double? chapterNumber,
    String? fetchedAt,
    int? id,
    bool? isBookmarked,
    bool? isDownloaded,
    bool? isRead,
    int? lastPageRead,
    String? lastReadAt,
    int? mangaId,
    String? name,
    int? pageCount,
    String? realUrl,
    String? scanlator,
    int? sourceOrder,
    String? uploadDate,
    String? url,
  }) =>
      _res;
}

class Input$ChapterFilterInput {
  factory Input$ChapterFilterInput({
    List<Input$ChapterFilterInput>? and,
    Input$FloatFilterInput? chapterNumber,
    Input$LongFilterInput? fetchedAt,
    Input$IntFilterInput? id,
    Input$BooleanFilterInput? inLibrary,
    Input$BooleanFilterInput? isBookmarked,
    Input$BooleanFilterInput? isDownloaded,
    Input$BooleanFilterInput? isRead,
    Input$IntFilterInput? lastPageRead,
    Input$LongFilterInput? lastReadAt,
    Input$IntFilterInput? mangaId,
    Input$StringFilterInput? name,
    Input$ChapterFilterInput? not,
    List<Input$ChapterFilterInput>? or,
    Input$IntFilterInput? pageCount,
    Input$StringFilterInput? realUrl,
    Input$StringFilterInput? scanlator,
    Input$IntFilterInput? sourceOrder,
    Input$LongFilterInput? uploadDate,
    Input$StringFilterInput? url,
  }) =>
      Input$ChapterFilterInput._({
        if (and != null) r'and': and,
        if (chapterNumber != null) r'chapterNumber': chapterNumber,
        if (fetchedAt != null) r'fetchedAt': fetchedAt,
        if (id != null) r'id': id,
        if (inLibrary != null) r'inLibrary': inLibrary,
        if (isBookmarked != null) r'isBookmarked': isBookmarked,
        if (isDownloaded != null) r'isDownloaded': isDownloaded,
        if (isRead != null) r'isRead': isRead,
        if (lastPageRead != null) r'lastPageRead': lastPageRead,
        if (lastReadAt != null) r'lastReadAt': lastReadAt,
        if (mangaId != null) r'mangaId': mangaId,
        if (name != null) r'name': name,
        if (not != null) r'not': not,
        if (or != null) r'or': or,
        if (pageCount != null) r'pageCount': pageCount,
        if (realUrl != null) r'realUrl': realUrl,
        if (scanlator != null) r'scanlator': scanlator,
        if (sourceOrder != null) r'sourceOrder': sourceOrder,
        if (uploadDate != null) r'uploadDate': uploadDate,
        if (url != null) r'url': url,
      });

  Input$ChapterFilterInput._(this._$data);

  factory Input$ChapterFilterInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('and')) {
      final l$and = data['and'];
      result$data['and'] = (l$and as List<dynamic>?)
          ?.map((e) =>
              Input$ChapterFilterInput.fromJson((e as Map<String, dynamic>)))
          .toList();
    }
    if (data.containsKey('chapterNumber')) {
      final l$chapterNumber = data['chapterNumber'];
      result$data['chapterNumber'] = l$chapterNumber == null
          ? null
          : Input$FloatFilterInput.fromJson(
              (l$chapterNumber as Map<String, dynamic>));
    }
    if (data.containsKey('fetchedAt')) {
      final l$fetchedAt = data['fetchedAt'];
      result$data['fetchedAt'] = l$fetchedAt == null
          ? null
          : Input$LongFilterInput.fromJson(
              (l$fetchedAt as Map<String, dynamic>));
    }
    if (data.containsKey('id')) {
      final l$id = data['id'];
      result$data['id'] = l$id == null
          ? null
          : Input$IntFilterInput.fromJson((l$id as Map<String, dynamic>));
    }
    if (data.containsKey('inLibrary')) {
      final l$inLibrary = data['inLibrary'];
      result$data['inLibrary'] = l$inLibrary == null
          ? null
          : Input$BooleanFilterInput.fromJson(
              (l$inLibrary as Map<String, dynamic>));
    }
    if (data.containsKey('isBookmarked')) {
      final l$isBookmarked = data['isBookmarked'];
      result$data['isBookmarked'] = l$isBookmarked == null
          ? null
          : Input$BooleanFilterInput.fromJson(
              (l$isBookmarked as Map<String, dynamic>));
    }
    if (data.containsKey('isDownloaded')) {
      final l$isDownloaded = data['isDownloaded'];
      result$data['isDownloaded'] = l$isDownloaded == null
          ? null
          : Input$BooleanFilterInput.fromJson(
              (l$isDownloaded as Map<String, dynamic>));
    }
    if (data.containsKey('isRead')) {
      final l$isRead = data['isRead'];
      result$data['isRead'] = l$isRead == null
          ? null
          : Input$BooleanFilterInput.fromJson(
              (l$isRead as Map<String, dynamic>));
    }
    if (data.containsKey('lastPageRead')) {
      final l$lastPageRead = data['lastPageRead'];
      result$data['lastPageRead'] = l$lastPageRead == null
          ? null
          : Input$IntFilterInput.fromJson(
              (l$lastPageRead as Map<String, dynamic>));
    }
    if (data.containsKey('lastReadAt')) {
      final l$lastReadAt = data['lastReadAt'];
      result$data['lastReadAt'] = l$lastReadAt == null
          ? null
          : Input$LongFilterInput.fromJson(
              (l$lastReadAt as Map<String, dynamic>));
    }
    if (data.containsKey('mangaId')) {
      final l$mangaId = data['mangaId'];
      result$data['mangaId'] = l$mangaId == null
          ? null
          : Input$IntFilterInput.fromJson((l$mangaId as Map<String, dynamic>));
    }
    if (data.containsKey('name')) {
      final l$name = data['name'];
      result$data['name'] = l$name == null
          ? null
          : Input$StringFilterInput.fromJson((l$name as Map<String, dynamic>));
    }
    if (data.containsKey('not')) {
      final l$not = data['not'];
      result$data['not'] = l$not == null
          ? null
          : Input$ChapterFilterInput.fromJson((l$not as Map<String, dynamic>));
    }
    if (data.containsKey('or')) {
      final l$or = data['or'];
      result$data['or'] = (l$or as List<dynamic>?)
          ?.map((e) =>
              Input$ChapterFilterInput.fromJson((e as Map<String, dynamic>)))
          .toList();
    }
    if (data.containsKey('pageCount')) {
      final l$pageCount = data['pageCount'];
      result$data['pageCount'] = l$pageCount == null
          ? null
          : Input$IntFilterInput.fromJson(
              (l$pageCount as Map<String, dynamic>));
    }
    if (data.containsKey('realUrl')) {
      final l$realUrl = data['realUrl'];
      result$data['realUrl'] = l$realUrl == null
          ? null
          : Input$StringFilterInput.fromJson(
              (l$realUrl as Map<String, dynamic>));
    }
    if (data.containsKey('scanlator')) {
      final l$scanlator = data['scanlator'];
      result$data['scanlator'] = l$scanlator == null
          ? null
          : Input$StringFilterInput.fromJson(
              (l$scanlator as Map<String, dynamic>));
    }
    if (data.containsKey('sourceOrder')) {
      final l$sourceOrder = data['sourceOrder'];
      result$data['sourceOrder'] = l$sourceOrder == null
          ? null
          : Input$IntFilterInput.fromJson(
              (l$sourceOrder as Map<String, dynamic>));
    }
    if (data.containsKey('uploadDate')) {
      final l$uploadDate = data['uploadDate'];
      result$data['uploadDate'] = l$uploadDate == null
          ? null
          : Input$LongFilterInput.fromJson(
              (l$uploadDate as Map<String, dynamic>));
    }
    if (data.containsKey('url')) {
      final l$url = data['url'];
      result$data['url'] = l$url == null
          ? null
          : Input$StringFilterInput.fromJson((l$url as Map<String, dynamic>));
    }
    return Input$ChapterFilterInput._(result$data);
  }

  Map<String, dynamic> _$data;

  List<Input$ChapterFilterInput>? get and =>
      (_$data['and'] as List<Input$ChapterFilterInput>?);

  Input$FloatFilterInput? get chapterNumber =>
      (_$data['chapterNumber'] as Input$FloatFilterInput?);

  Input$LongFilterInput? get fetchedAt =>
      (_$data['fetchedAt'] as Input$LongFilterInput?);

  Input$IntFilterInput? get id => (_$data['id'] as Input$IntFilterInput?);

  Input$BooleanFilterInput? get inLibrary =>
      (_$data['inLibrary'] as Input$BooleanFilterInput?);

  Input$BooleanFilterInput? get isBookmarked =>
      (_$data['isBookmarked'] as Input$BooleanFilterInput?);

  Input$BooleanFilterInput? get isDownloaded =>
      (_$data['isDownloaded'] as Input$BooleanFilterInput?);

  Input$BooleanFilterInput? get isRead =>
      (_$data['isRead'] as Input$BooleanFilterInput?);

  Input$IntFilterInput? get lastPageRead =>
      (_$data['lastPageRead'] as Input$IntFilterInput?);

  Input$LongFilterInput? get lastReadAt =>
      (_$data['lastReadAt'] as Input$LongFilterInput?);

  Input$IntFilterInput? get mangaId =>
      (_$data['mangaId'] as Input$IntFilterInput?);

  Input$StringFilterInput? get name =>
      (_$data['name'] as Input$StringFilterInput?);

  Input$ChapterFilterInput? get not =>
      (_$data['not'] as Input$ChapterFilterInput?);

  List<Input$ChapterFilterInput>? get or =>
      (_$data['or'] as List<Input$ChapterFilterInput>?);

  Input$IntFilterInput? get pageCount =>
      (_$data['pageCount'] as Input$IntFilterInput?);

  Input$StringFilterInput? get realUrl =>
      (_$data['realUrl'] as Input$StringFilterInput?);

  Input$StringFilterInput? get scanlator =>
      (_$data['scanlator'] as Input$StringFilterInput?);

  Input$IntFilterInput? get sourceOrder =>
      (_$data['sourceOrder'] as Input$IntFilterInput?);

  Input$LongFilterInput? get uploadDate =>
      (_$data['uploadDate'] as Input$LongFilterInput?);

  Input$StringFilterInput? get url =>
      (_$data['url'] as Input$StringFilterInput?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('and')) {
      final l$and = and;
      result$data['and'] = l$and?.map((e) => e.toJson()).toList();
    }
    if (_$data.containsKey('chapterNumber')) {
      final l$chapterNumber = chapterNumber;
      result$data['chapterNumber'] = l$chapterNumber?.toJson();
    }
    if (_$data.containsKey('fetchedAt')) {
      final l$fetchedAt = fetchedAt;
      result$data['fetchedAt'] = l$fetchedAt?.toJson();
    }
    if (_$data.containsKey('id')) {
      final l$id = id;
      result$data['id'] = l$id?.toJson();
    }
    if (_$data.containsKey('inLibrary')) {
      final l$inLibrary = inLibrary;
      result$data['inLibrary'] = l$inLibrary?.toJson();
    }
    if (_$data.containsKey('isBookmarked')) {
      final l$isBookmarked = isBookmarked;
      result$data['isBookmarked'] = l$isBookmarked?.toJson();
    }
    if (_$data.containsKey('isDownloaded')) {
      final l$isDownloaded = isDownloaded;
      result$data['isDownloaded'] = l$isDownloaded?.toJson();
    }
    if (_$data.containsKey('isRead')) {
      final l$isRead = isRead;
      result$data['isRead'] = l$isRead?.toJson();
    }
    if (_$data.containsKey('lastPageRead')) {
      final l$lastPageRead = lastPageRead;
      result$data['lastPageRead'] = l$lastPageRead?.toJson();
    }
    if (_$data.containsKey('lastReadAt')) {
      final l$lastReadAt = lastReadAt;
      result$data['lastReadAt'] = l$lastReadAt?.toJson();
    }
    if (_$data.containsKey('mangaId')) {
      final l$mangaId = mangaId;
      result$data['mangaId'] = l$mangaId?.toJson();
    }
    if (_$data.containsKey('name')) {
      final l$name = name;
      result$data['name'] = l$name?.toJson();
    }
    if (_$data.containsKey('not')) {
      final l$not = not;
      result$data['not'] = l$not?.toJson();
    }
    if (_$data.containsKey('or')) {
      final l$or = or;
      result$data['or'] = l$or?.map((e) => e.toJson()).toList();
    }
    if (_$data.containsKey('pageCount')) {
      final l$pageCount = pageCount;
      result$data['pageCount'] = l$pageCount?.toJson();
    }
    if (_$data.containsKey('realUrl')) {
      final l$realUrl = realUrl;
      result$data['realUrl'] = l$realUrl?.toJson();
    }
    if (_$data.containsKey('scanlator')) {
      final l$scanlator = scanlator;
      result$data['scanlator'] = l$scanlator?.toJson();
    }
    if (_$data.containsKey('sourceOrder')) {
      final l$sourceOrder = sourceOrder;
      result$data['sourceOrder'] = l$sourceOrder?.toJson();
    }
    if (_$data.containsKey('uploadDate')) {
      final l$uploadDate = uploadDate;
      result$data['uploadDate'] = l$uploadDate?.toJson();
    }
    if (_$data.containsKey('url')) {
      final l$url = url;
      result$data['url'] = l$url?.toJson();
    }
    return result$data;
  }

  CopyWith$Input$ChapterFilterInput<Input$ChapterFilterInput> get copyWith =>
      CopyWith$Input$ChapterFilterInput(
        this,
        (i) => i,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$ChapterFilterInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$and = and;
    final lOther$and = other.and;
    if (_$data.containsKey('and') != other._$data.containsKey('and')) {
      return false;
    }
    if (l$and != null && lOther$and != null) {
      if (l$and.length != lOther$and.length) {
        return false;
      }
      for (int i = 0; i < l$and.length; i++) {
        final l$and$entry = l$and[i];
        final lOther$and$entry = lOther$and[i];
        if (l$and$entry != lOther$and$entry) {
          return false;
        }
      }
    } else if (l$and != lOther$and) {
      return false;
    }
    final l$chapterNumber = chapterNumber;
    final lOther$chapterNumber = other.chapterNumber;
    if (_$data.containsKey('chapterNumber') !=
        other._$data.containsKey('chapterNumber')) {
      return false;
    }
    if (l$chapterNumber != lOther$chapterNumber) {
      return false;
    }
    final l$fetchedAt = fetchedAt;
    final lOther$fetchedAt = other.fetchedAt;
    if (_$data.containsKey('fetchedAt') !=
        other._$data.containsKey('fetchedAt')) {
      return false;
    }
    if (l$fetchedAt != lOther$fetchedAt) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (_$data.containsKey('id') != other._$data.containsKey('id')) {
      return false;
    }
    if (l$id != lOther$id) {
      return false;
    }
    final l$inLibrary = inLibrary;
    final lOther$inLibrary = other.inLibrary;
    if (_$data.containsKey('inLibrary') !=
        other._$data.containsKey('inLibrary')) {
      return false;
    }
    if (l$inLibrary != lOther$inLibrary) {
      return false;
    }
    final l$isBookmarked = isBookmarked;
    final lOther$isBookmarked = other.isBookmarked;
    if (_$data.containsKey('isBookmarked') !=
        other._$data.containsKey('isBookmarked')) {
      return false;
    }
    if (l$isBookmarked != lOther$isBookmarked) {
      return false;
    }
    final l$isDownloaded = isDownloaded;
    final lOther$isDownloaded = other.isDownloaded;
    if (_$data.containsKey('isDownloaded') !=
        other._$data.containsKey('isDownloaded')) {
      return false;
    }
    if (l$isDownloaded != lOther$isDownloaded) {
      return false;
    }
    final l$isRead = isRead;
    final lOther$isRead = other.isRead;
    if (_$data.containsKey('isRead') != other._$data.containsKey('isRead')) {
      return false;
    }
    if (l$isRead != lOther$isRead) {
      return false;
    }
    final l$lastPageRead = lastPageRead;
    final lOther$lastPageRead = other.lastPageRead;
    if (_$data.containsKey('lastPageRead') !=
        other._$data.containsKey('lastPageRead')) {
      return false;
    }
    if (l$lastPageRead != lOther$lastPageRead) {
      return false;
    }
    final l$lastReadAt = lastReadAt;
    final lOther$lastReadAt = other.lastReadAt;
    if (_$data.containsKey('lastReadAt') !=
        other._$data.containsKey('lastReadAt')) {
      return false;
    }
    if (l$lastReadAt != lOther$lastReadAt) {
      return false;
    }
    final l$mangaId = mangaId;
    final lOther$mangaId = other.mangaId;
    if (_$data.containsKey('mangaId') != other._$data.containsKey('mangaId')) {
      return false;
    }
    if (l$mangaId != lOther$mangaId) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (_$data.containsKey('name') != other._$data.containsKey('name')) {
      return false;
    }
    if (l$name != lOther$name) {
      return false;
    }
    final l$not = not;
    final lOther$not = other.not;
    if (_$data.containsKey('not') != other._$data.containsKey('not')) {
      return false;
    }
    if (l$not != lOther$not) {
      return false;
    }
    final l$or = or;
    final lOther$or = other.or;
    if (_$data.containsKey('or') != other._$data.containsKey('or')) {
      return false;
    }
    if (l$or != null && lOther$or != null) {
      if (l$or.length != lOther$or.length) {
        return false;
      }
      for (int i = 0; i < l$or.length; i++) {
        final l$or$entry = l$or[i];
        final lOther$or$entry = lOther$or[i];
        if (l$or$entry != lOther$or$entry) {
          return false;
        }
      }
    } else if (l$or != lOther$or) {
      return false;
    }
    final l$pageCount = pageCount;
    final lOther$pageCount = other.pageCount;
    if (_$data.containsKey('pageCount') !=
        other._$data.containsKey('pageCount')) {
      return false;
    }
    if (l$pageCount != lOther$pageCount) {
      return false;
    }
    final l$realUrl = realUrl;
    final lOther$realUrl = other.realUrl;
    if (_$data.containsKey('realUrl') != other._$data.containsKey('realUrl')) {
      return false;
    }
    if (l$realUrl != lOther$realUrl) {
      return false;
    }
    final l$scanlator = scanlator;
    final lOther$scanlator = other.scanlator;
    if (_$data.containsKey('scanlator') !=
        other._$data.containsKey('scanlator')) {
      return false;
    }
    if (l$scanlator != lOther$scanlator) {
      return false;
    }
    final l$sourceOrder = sourceOrder;
    final lOther$sourceOrder = other.sourceOrder;
    if (_$data.containsKey('sourceOrder') !=
        other._$data.containsKey('sourceOrder')) {
      return false;
    }
    if (l$sourceOrder != lOther$sourceOrder) {
      return false;
    }
    final l$uploadDate = uploadDate;
    final lOther$uploadDate = other.uploadDate;
    if (_$data.containsKey('uploadDate') !=
        other._$data.containsKey('uploadDate')) {
      return false;
    }
    if (l$uploadDate != lOther$uploadDate) {
      return false;
    }
    final l$url = url;
    final lOther$url = other.url;
    if (_$data.containsKey('url') != other._$data.containsKey('url')) {
      return false;
    }
    if (l$url != lOther$url) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$and = and;
    final l$chapterNumber = chapterNumber;
    final l$fetchedAt = fetchedAt;
    final l$id = id;
    final l$inLibrary = inLibrary;
    final l$isBookmarked = isBookmarked;
    final l$isDownloaded = isDownloaded;
    final l$isRead = isRead;
    final l$lastPageRead = lastPageRead;
    final l$lastReadAt = lastReadAt;
    final l$mangaId = mangaId;
    final l$name = name;
    final l$not = not;
    final l$or = or;
    final l$pageCount = pageCount;
    final l$realUrl = realUrl;
    final l$scanlator = scanlator;
    final l$sourceOrder = sourceOrder;
    final l$uploadDate = uploadDate;
    final l$url = url;
    return Object.hashAll([
      _$data.containsKey('and')
          ? l$and == null
              ? null
              : Object.hashAll(l$and.map((v) => v))
          : const {},
      _$data.containsKey('chapterNumber') ? l$chapterNumber : const {},
      _$data.containsKey('fetchedAt') ? l$fetchedAt : const {},
      _$data.containsKey('id') ? l$id : const {},
      _$data.containsKey('inLibrary') ? l$inLibrary : const {},
      _$data.containsKey('isBookmarked') ? l$isBookmarked : const {},
      _$data.containsKey('isDownloaded') ? l$isDownloaded : const {},
      _$data.containsKey('isRead') ? l$isRead : const {},
      _$data.containsKey('lastPageRead') ? l$lastPageRead : const {},
      _$data.containsKey('lastReadAt') ? l$lastReadAt : const {},
      _$data.containsKey('mangaId') ? l$mangaId : const {},
      _$data.containsKey('name') ? l$name : const {},
      _$data.containsKey('not') ? l$not : const {},
      _$data.containsKey('or')
          ? l$or == null
              ? null
              : Object.hashAll(l$or.map((v) => v))
          : const {},
      _$data.containsKey('pageCount') ? l$pageCount : const {},
      _$data.containsKey('realUrl') ? l$realUrl : const {},
      _$data.containsKey('scanlator') ? l$scanlator : const {},
      _$data.containsKey('sourceOrder') ? l$sourceOrder : const {},
      _$data.containsKey('uploadDate') ? l$uploadDate : const {},
      _$data.containsKey('url') ? l$url : const {},
    ]);
  }
}

abstract class CopyWith$Input$ChapterFilterInput<TRes> {
  factory CopyWith$Input$ChapterFilterInput(
    Input$ChapterFilterInput instance,
    TRes Function(Input$ChapterFilterInput) then,
  ) = _CopyWithImpl$Input$ChapterFilterInput;

  factory CopyWith$Input$ChapterFilterInput.stub(TRes res) =
      _CopyWithStubImpl$Input$ChapterFilterInput;

  TRes call({
    List<Input$ChapterFilterInput>? and,
    Input$FloatFilterInput? chapterNumber,
    Input$LongFilterInput? fetchedAt,
    Input$IntFilterInput? id,
    Input$BooleanFilterInput? inLibrary,
    Input$BooleanFilterInput? isBookmarked,
    Input$BooleanFilterInput? isDownloaded,
    Input$BooleanFilterInput? isRead,
    Input$IntFilterInput? lastPageRead,
    Input$LongFilterInput? lastReadAt,
    Input$IntFilterInput? mangaId,
    Input$StringFilterInput? name,
    Input$ChapterFilterInput? not,
    List<Input$ChapterFilterInput>? or,
    Input$IntFilterInput? pageCount,
    Input$StringFilterInput? realUrl,
    Input$StringFilterInput? scanlator,
    Input$IntFilterInput? sourceOrder,
    Input$LongFilterInput? uploadDate,
    Input$StringFilterInput? url,
  });
  TRes and(
      Iterable<Input$ChapterFilterInput>? Function(
              Iterable<
                  CopyWith$Input$ChapterFilterInput<Input$ChapterFilterInput>>?)
          _fn);
  CopyWith$Input$FloatFilterInput<TRes> get chapterNumber;
  CopyWith$Input$LongFilterInput<TRes> get fetchedAt;
  CopyWith$Input$IntFilterInput<TRes> get id;
  CopyWith$Input$BooleanFilterInput<TRes> get inLibrary;
  CopyWith$Input$BooleanFilterInput<TRes> get isBookmarked;
  CopyWith$Input$BooleanFilterInput<TRes> get isDownloaded;
  CopyWith$Input$BooleanFilterInput<TRes> get isRead;
  CopyWith$Input$IntFilterInput<TRes> get lastPageRead;
  CopyWith$Input$LongFilterInput<TRes> get lastReadAt;
  CopyWith$Input$IntFilterInput<TRes> get mangaId;
  CopyWith$Input$StringFilterInput<TRes> get name;
  CopyWith$Input$ChapterFilterInput<TRes> get not;
  TRes or(
      Iterable<Input$ChapterFilterInput>? Function(
              Iterable<
                  CopyWith$Input$ChapterFilterInput<Input$ChapterFilterInput>>?)
          _fn);
  CopyWith$Input$IntFilterInput<TRes> get pageCount;
  CopyWith$Input$StringFilterInput<TRes> get realUrl;
  CopyWith$Input$StringFilterInput<TRes> get scanlator;
  CopyWith$Input$IntFilterInput<TRes> get sourceOrder;
  CopyWith$Input$LongFilterInput<TRes> get uploadDate;
  CopyWith$Input$StringFilterInput<TRes> get url;
}

class _CopyWithImpl$Input$ChapterFilterInput<TRes>
    implements CopyWith$Input$ChapterFilterInput<TRes> {
  _CopyWithImpl$Input$ChapterFilterInput(
    this._instance,
    this._then,
  );

  final Input$ChapterFilterInput _instance;

  final TRes Function(Input$ChapterFilterInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? and = _undefined,
    Object? chapterNumber = _undefined,
    Object? fetchedAt = _undefined,
    Object? id = _undefined,
    Object? inLibrary = _undefined,
    Object? isBookmarked = _undefined,
    Object? isDownloaded = _undefined,
    Object? isRead = _undefined,
    Object? lastPageRead = _undefined,
    Object? lastReadAt = _undefined,
    Object? mangaId = _undefined,
    Object? name = _undefined,
    Object? not = _undefined,
    Object? or = _undefined,
    Object? pageCount = _undefined,
    Object? realUrl = _undefined,
    Object? scanlator = _undefined,
    Object? sourceOrder = _undefined,
    Object? uploadDate = _undefined,
    Object? url = _undefined,
  }) =>
      _then(Input$ChapterFilterInput._({
        ..._instance._$data,
        if (and != _undefined) 'and': (and as List<Input$ChapterFilterInput>?),
        if (chapterNumber != _undefined)
          'chapterNumber': (chapterNumber as Input$FloatFilterInput?),
        if (fetchedAt != _undefined)
          'fetchedAt': (fetchedAt as Input$LongFilterInput?),
        if (id != _undefined) 'id': (id as Input$IntFilterInput?),
        if (inLibrary != _undefined)
          'inLibrary': (inLibrary as Input$BooleanFilterInput?),
        if (isBookmarked != _undefined)
          'isBookmarked': (isBookmarked as Input$BooleanFilterInput?),
        if (isDownloaded != _undefined)
          'isDownloaded': (isDownloaded as Input$BooleanFilterInput?),
        if (isRead != _undefined)
          'isRead': (isRead as Input$BooleanFilterInput?),
        if (lastPageRead != _undefined)
          'lastPageRead': (lastPageRead as Input$IntFilterInput?),
        if (lastReadAt != _undefined)
          'lastReadAt': (lastReadAt as Input$LongFilterInput?),
        if (mangaId != _undefined)
          'mangaId': (mangaId as Input$IntFilterInput?),
        if (name != _undefined) 'name': (name as Input$StringFilterInput?),
        if (not != _undefined) 'not': (not as Input$ChapterFilterInput?),
        if (or != _undefined) 'or': (or as List<Input$ChapterFilterInput>?),
        if (pageCount != _undefined)
          'pageCount': (pageCount as Input$IntFilterInput?),
        if (realUrl != _undefined)
          'realUrl': (realUrl as Input$StringFilterInput?),
        if (scanlator != _undefined)
          'scanlator': (scanlator as Input$StringFilterInput?),
        if (sourceOrder != _undefined)
          'sourceOrder': (sourceOrder as Input$IntFilterInput?),
        if (uploadDate != _undefined)
          'uploadDate': (uploadDate as Input$LongFilterInput?),
        if (url != _undefined) 'url': (url as Input$StringFilterInput?),
      }));

  TRes and(
          Iterable<Input$ChapterFilterInput>? Function(
                  Iterable<
                      CopyWith$Input$ChapterFilterInput<
                          Input$ChapterFilterInput>>?)
              _fn) =>
      call(
          and: _fn(_instance.and?.map((e) => CopyWith$Input$ChapterFilterInput(
                e,
                (i) => i,
              )))?.toList());

  CopyWith$Input$FloatFilterInput<TRes> get chapterNumber {
    final local$chapterNumber = _instance.chapterNumber;
    return local$chapterNumber == null
        ? CopyWith$Input$FloatFilterInput.stub(_then(_instance))
        : CopyWith$Input$FloatFilterInput(
            local$chapterNumber, (e) => call(chapterNumber: e));
  }

  CopyWith$Input$LongFilterInput<TRes> get fetchedAt {
    final local$fetchedAt = _instance.fetchedAt;
    return local$fetchedAt == null
        ? CopyWith$Input$LongFilterInput.stub(_then(_instance))
        : CopyWith$Input$LongFilterInput(
            local$fetchedAt, (e) => call(fetchedAt: e));
  }

  CopyWith$Input$IntFilterInput<TRes> get id {
    final local$id = _instance.id;
    return local$id == null
        ? CopyWith$Input$IntFilterInput.stub(_then(_instance))
        : CopyWith$Input$IntFilterInput(local$id, (e) => call(id: e));
  }

  CopyWith$Input$BooleanFilterInput<TRes> get inLibrary {
    final local$inLibrary = _instance.inLibrary;
    return local$inLibrary == null
        ? CopyWith$Input$BooleanFilterInput.stub(_then(_instance))
        : CopyWith$Input$BooleanFilterInput(
            local$inLibrary, (e) => call(inLibrary: e));
  }

  CopyWith$Input$BooleanFilterInput<TRes> get isBookmarked {
    final local$isBookmarked = _instance.isBookmarked;
    return local$isBookmarked == null
        ? CopyWith$Input$BooleanFilterInput.stub(_then(_instance))
        : CopyWith$Input$BooleanFilterInput(
            local$isBookmarked, (e) => call(isBookmarked: e));
  }

  CopyWith$Input$BooleanFilterInput<TRes> get isDownloaded {
    final local$isDownloaded = _instance.isDownloaded;
    return local$isDownloaded == null
        ? CopyWith$Input$BooleanFilterInput.stub(_then(_instance))
        : CopyWith$Input$BooleanFilterInput(
            local$isDownloaded, (e) => call(isDownloaded: e));
  }

  CopyWith$Input$BooleanFilterInput<TRes> get isRead {
    final local$isRead = _instance.isRead;
    return local$isRead == null
        ? CopyWith$Input$BooleanFilterInput.stub(_then(_instance))
        : CopyWith$Input$BooleanFilterInput(
            local$isRead, (e) => call(isRead: e));
  }

  CopyWith$Input$IntFilterInput<TRes> get lastPageRead {
    final local$lastPageRead = _instance.lastPageRead;
    return local$lastPageRead == null
        ? CopyWith$Input$IntFilterInput.stub(_then(_instance))
        : CopyWith$Input$IntFilterInput(
            local$lastPageRead, (e) => call(lastPageRead: e));
  }

  CopyWith$Input$LongFilterInput<TRes> get lastReadAt {
    final local$lastReadAt = _instance.lastReadAt;
    return local$lastReadAt == null
        ? CopyWith$Input$LongFilterInput.stub(_then(_instance))
        : CopyWith$Input$LongFilterInput(
            local$lastReadAt, (e) => call(lastReadAt: e));
  }

  CopyWith$Input$IntFilterInput<TRes> get mangaId {
    final local$mangaId = _instance.mangaId;
    return local$mangaId == null
        ? CopyWith$Input$IntFilterInput.stub(_then(_instance))
        : CopyWith$Input$IntFilterInput(local$mangaId, (e) => call(mangaId: e));
  }

  CopyWith$Input$StringFilterInput<TRes> get name {
    final local$name = _instance.name;
    return local$name == null
        ? CopyWith$Input$StringFilterInput.stub(_then(_instance))
        : CopyWith$Input$StringFilterInput(local$name, (e) => call(name: e));
  }

  CopyWith$Input$ChapterFilterInput<TRes> get not {
    final local$not = _instance.not;
    return local$not == null
        ? CopyWith$Input$ChapterFilterInput.stub(_then(_instance))
        : CopyWith$Input$ChapterFilterInput(local$not, (e) => call(not: e));
  }

  TRes or(
          Iterable<Input$ChapterFilterInput>? Function(
                  Iterable<
                      CopyWith$Input$ChapterFilterInput<
                          Input$ChapterFilterInput>>?)
              _fn) =>
      call(
          or: _fn(_instance.or?.map((e) => CopyWith$Input$ChapterFilterInput(
                e,
                (i) => i,
              )))?.toList());

  CopyWith$Input$IntFilterInput<TRes> get pageCount {
    final local$pageCount = _instance.pageCount;
    return local$pageCount == null
        ? CopyWith$Input$IntFilterInput.stub(_then(_instance))
        : CopyWith$Input$IntFilterInput(
            local$pageCount, (e) => call(pageCount: e));
  }

  CopyWith$Input$StringFilterInput<TRes> get realUrl {
    final local$realUrl = _instance.realUrl;
    return local$realUrl == null
        ? CopyWith$Input$StringFilterInput.stub(_then(_instance))
        : CopyWith$Input$StringFilterInput(
            local$realUrl, (e) => call(realUrl: e));
  }

  CopyWith$Input$StringFilterInput<TRes> get scanlator {
    final local$scanlator = _instance.scanlator;
    return local$scanlator == null
        ? CopyWith$Input$StringFilterInput.stub(_then(_instance))
        : CopyWith$Input$StringFilterInput(
            local$scanlator, (e) => call(scanlator: e));
  }

  CopyWith$Input$IntFilterInput<TRes> get sourceOrder {
    final local$sourceOrder = _instance.sourceOrder;
    return local$sourceOrder == null
        ? CopyWith$Input$IntFilterInput.stub(_then(_instance))
        : CopyWith$Input$IntFilterInput(
            local$sourceOrder, (e) => call(sourceOrder: e));
  }

  CopyWith$Input$LongFilterInput<TRes> get uploadDate {
    final local$uploadDate = _instance.uploadDate;
    return local$uploadDate == null
        ? CopyWith$Input$LongFilterInput.stub(_then(_instance))
        : CopyWith$Input$LongFilterInput(
            local$uploadDate, (e) => call(uploadDate: e));
  }

  CopyWith$Input$StringFilterInput<TRes> get url {
    final local$url = _instance.url;
    return local$url == null
        ? CopyWith$Input$StringFilterInput.stub(_then(_instance))
        : CopyWith$Input$StringFilterInput(local$url, (e) => call(url: e));
  }
}

class _CopyWithStubImpl$Input$ChapterFilterInput<TRes>
    implements CopyWith$Input$ChapterFilterInput<TRes> {
  _CopyWithStubImpl$Input$ChapterFilterInput(this._res);

  TRes _res;

  call({
    List<Input$ChapterFilterInput>? and,
    Input$FloatFilterInput? chapterNumber,
    Input$LongFilterInput? fetchedAt,
    Input$IntFilterInput? id,
    Input$BooleanFilterInput? inLibrary,
    Input$BooleanFilterInput? isBookmarked,
    Input$BooleanFilterInput? isDownloaded,
    Input$BooleanFilterInput? isRead,
    Input$IntFilterInput? lastPageRead,
    Input$LongFilterInput? lastReadAt,
    Input$IntFilterInput? mangaId,
    Input$StringFilterInput? name,
    Input$ChapterFilterInput? not,
    List<Input$ChapterFilterInput>? or,
    Input$IntFilterInput? pageCount,
    Input$StringFilterInput? realUrl,
    Input$StringFilterInput? scanlator,
    Input$IntFilterInput? sourceOrder,
    Input$LongFilterInput? uploadDate,
    Input$StringFilterInput? url,
  }) =>
      _res;

  and(_fn) => _res;

  CopyWith$Input$FloatFilterInput<TRes> get chapterNumber =>
      CopyWith$Input$FloatFilterInput.stub(_res);

  CopyWith$Input$LongFilterInput<TRes> get fetchedAt =>
      CopyWith$Input$LongFilterInput.stub(_res);

  CopyWith$Input$IntFilterInput<TRes> get id =>
      CopyWith$Input$IntFilterInput.stub(_res);

  CopyWith$Input$BooleanFilterInput<TRes> get inLibrary =>
      CopyWith$Input$BooleanFilterInput.stub(_res);

  CopyWith$Input$BooleanFilterInput<TRes> get isBookmarked =>
      CopyWith$Input$BooleanFilterInput.stub(_res);

  CopyWith$Input$BooleanFilterInput<TRes> get isDownloaded =>
      CopyWith$Input$BooleanFilterInput.stub(_res);

  CopyWith$Input$BooleanFilterInput<TRes> get isRead =>
      CopyWith$Input$BooleanFilterInput.stub(_res);

  CopyWith$Input$IntFilterInput<TRes> get lastPageRead =>
      CopyWith$Input$IntFilterInput.stub(_res);

  CopyWith$Input$LongFilterInput<TRes> get lastReadAt =>
      CopyWith$Input$LongFilterInput.stub(_res);

  CopyWith$Input$IntFilterInput<TRes> get mangaId =>
      CopyWith$Input$IntFilterInput.stub(_res);

  CopyWith$Input$StringFilterInput<TRes> get name =>
      CopyWith$Input$StringFilterInput.stub(_res);

  CopyWith$Input$ChapterFilterInput<TRes> get not =>
      CopyWith$Input$ChapterFilterInput.stub(_res);

  or(_fn) => _res;

  CopyWith$Input$IntFilterInput<TRes> get pageCount =>
      CopyWith$Input$IntFilterInput.stub(_res);

  CopyWith$Input$StringFilterInput<TRes> get realUrl =>
      CopyWith$Input$StringFilterInput.stub(_res);

  CopyWith$Input$StringFilterInput<TRes> get scanlator =>
      CopyWith$Input$StringFilterInput.stub(_res);

  CopyWith$Input$IntFilterInput<TRes> get sourceOrder =>
      CopyWith$Input$IntFilterInput.stub(_res);

  CopyWith$Input$LongFilterInput<TRes> get uploadDate =>
      CopyWith$Input$LongFilterInput.stub(_res);

  CopyWith$Input$StringFilterInput<TRes> get url =>
      CopyWith$Input$StringFilterInput.stub(_res);
}

class Input$ChapterMetaTypeInput {
  factory Input$ChapterMetaTypeInput({
    required int chapterId,
    required String key,
    required String value,
  }) =>
      Input$ChapterMetaTypeInput._({
        r'chapterId': chapterId,
        r'key': key,
        r'value': value,
      });

  Input$ChapterMetaTypeInput._(this._$data);

  factory Input$ChapterMetaTypeInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$chapterId = data['chapterId'];
    result$data['chapterId'] = (l$chapterId as int);
    final l$key = data['key'];
    result$data['key'] = (l$key as String);
    final l$value = data['value'];
    result$data['value'] = (l$value as String);
    return Input$ChapterMetaTypeInput._(result$data);
  }

  Map<String, dynamic> _$data;

  int get chapterId => (_$data['chapterId'] as int);

  String get key => (_$data['key'] as String);

  String get value => (_$data['value'] as String);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$chapterId = chapterId;
    result$data['chapterId'] = l$chapterId;
    final l$key = key;
    result$data['key'] = l$key;
    final l$value = value;
    result$data['value'] = l$value;
    return result$data;
  }

  CopyWith$Input$ChapterMetaTypeInput<Input$ChapterMetaTypeInput>
      get copyWith => CopyWith$Input$ChapterMetaTypeInput(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$ChapterMetaTypeInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$chapterId = chapterId;
    final lOther$chapterId = other.chapterId;
    if (l$chapterId != lOther$chapterId) {
      return false;
    }
    final l$key = key;
    final lOther$key = other.key;
    if (l$key != lOther$key) {
      return false;
    }
    final l$value = value;
    final lOther$value = other.value;
    if (l$value != lOther$value) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$chapterId = chapterId;
    final l$key = key;
    final l$value = value;
    return Object.hashAll([
      l$chapterId,
      l$key,
      l$value,
    ]);
  }
}

abstract class CopyWith$Input$ChapterMetaTypeInput<TRes> {
  factory CopyWith$Input$ChapterMetaTypeInput(
    Input$ChapterMetaTypeInput instance,
    TRes Function(Input$ChapterMetaTypeInput) then,
  ) = _CopyWithImpl$Input$ChapterMetaTypeInput;

  factory CopyWith$Input$ChapterMetaTypeInput.stub(TRes res) =
      _CopyWithStubImpl$Input$ChapterMetaTypeInput;

  TRes call({
    int? chapterId,
    String? key,
    String? value,
  });
}

class _CopyWithImpl$Input$ChapterMetaTypeInput<TRes>
    implements CopyWith$Input$ChapterMetaTypeInput<TRes> {
  _CopyWithImpl$Input$ChapterMetaTypeInput(
    this._instance,
    this._then,
  );

  final Input$ChapterMetaTypeInput _instance;

  final TRes Function(Input$ChapterMetaTypeInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? chapterId = _undefined,
    Object? key = _undefined,
    Object? value = _undefined,
  }) =>
      _then(Input$ChapterMetaTypeInput._({
        ..._instance._$data,
        if (chapterId != _undefined && chapterId != null)
          'chapterId': (chapterId as int),
        if (key != _undefined && key != null) 'key': (key as String),
        if (value != _undefined && value != null) 'value': (value as String),
      }));
}

class _CopyWithStubImpl$Input$ChapterMetaTypeInput<TRes>
    implements CopyWith$Input$ChapterMetaTypeInput<TRes> {
  _CopyWithStubImpl$Input$ChapterMetaTypeInput(this._res);

  TRes _res;

  call({
    int? chapterId,
    String? key,
    String? value,
  }) =>
      _res;
}

class Input$ChapterOrderInput {
  factory Input$ChapterOrderInput({
    required Enum$ChapterOrderBy by,
    Enum$SortOrder? byType,
  }) =>
      Input$ChapterOrderInput._({
        r'by': by,
        if (byType != null) r'byType': byType,
      });

  Input$ChapterOrderInput._(this._$data);

  factory Input$ChapterOrderInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$by = data['by'];
    result$data['by'] = fromJson$Enum$ChapterOrderBy((l$by as String));
    if (data.containsKey('byType')) {
      final l$byType = data['byType'];
      result$data['byType'] = l$byType == null
          ? null
          : fromJson$Enum$SortOrder((l$byType as String));
    }
    return Input$ChapterOrderInput._(result$data);
  }

  Map<String, dynamic> _$data;

  Enum$ChapterOrderBy get by => (_$data['by'] as Enum$ChapterOrderBy);

  Enum$SortOrder? get byType => (_$data['byType'] as Enum$SortOrder?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$by = by;
    result$data['by'] = toJson$Enum$ChapterOrderBy(l$by);
    if (_$data.containsKey('byType')) {
      final l$byType = byType;
      result$data['byType'] =
          l$byType == null ? null : toJson$Enum$SortOrder(l$byType);
    }
    return result$data;
  }

  CopyWith$Input$ChapterOrderInput<Input$ChapterOrderInput> get copyWith =>
      CopyWith$Input$ChapterOrderInput(
        this,
        (i) => i,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$ChapterOrderInput || runtimeType != other.runtimeType) {
      return false;
    }
    final l$by = by;
    final lOther$by = other.by;
    if (l$by != lOther$by) {
      return false;
    }
    final l$byType = byType;
    final lOther$byType = other.byType;
    if (_$data.containsKey('byType') != other._$data.containsKey('byType')) {
      return false;
    }
    if (l$byType != lOther$byType) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$by = by;
    final l$byType = byType;
    return Object.hashAll([
      l$by,
      _$data.containsKey('byType') ? l$byType : const {},
    ]);
  }
}

abstract class CopyWith$Input$ChapterOrderInput<TRes> {
  factory CopyWith$Input$ChapterOrderInput(
    Input$ChapterOrderInput instance,
    TRes Function(Input$ChapterOrderInput) then,
  ) = _CopyWithImpl$Input$ChapterOrderInput;

  factory CopyWith$Input$ChapterOrderInput.stub(TRes res) =
      _CopyWithStubImpl$Input$ChapterOrderInput;

  TRes call({
    Enum$ChapterOrderBy? by,
    Enum$SortOrder? byType,
  });
}

class _CopyWithImpl$Input$ChapterOrderInput<TRes>
    implements CopyWith$Input$ChapterOrderInput<TRes> {
  _CopyWithImpl$Input$ChapterOrderInput(
    this._instance,
    this._then,
  );

  final Input$ChapterOrderInput _instance;

  final TRes Function(Input$ChapterOrderInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? by = _undefined,
    Object? byType = _undefined,
  }) =>
      _then(Input$ChapterOrderInput._({
        ..._instance._$data,
        if (by != _undefined && by != null) 'by': (by as Enum$ChapterOrderBy),
        if (byType != _undefined) 'byType': (byType as Enum$SortOrder?),
      }));
}

class _CopyWithStubImpl$Input$ChapterOrderInput<TRes>
    implements CopyWith$Input$ChapterOrderInput<TRes> {
  _CopyWithStubImpl$Input$ChapterOrderInput(this._res);

  TRes _res;

  call({
    Enum$ChapterOrderBy? by,
    Enum$SortOrder? byType,
  }) =>
      _res;
}

class Input$ClearCachedImagesInput {
  factory Input$ClearCachedImagesInput({
    bool? cachedPages,
    bool? cachedThumbnails,
    String? clientMutationId,
    bool? downloadedThumbnails,
  }) =>
      Input$ClearCachedImagesInput._({
        if (cachedPages != null) r'cachedPages': cachedPages,
        if (cachedThumbnails != null) r'cachedThumbnails': cachedThumbnails,
        if (clientMutationId != null) r'clientMutationId': clientMutationId,
        if (downloadedThumbnails != null)
          r'downloadedThumbnails': downloadedThumbnails,
      });

  Input$ClearCachedImagesInput._(this._$data);

  factory Input$ClearCachedImagesInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('cachedPages')) {
      final l$cachedPages = data['cachedPages'];
      result$data['cachedPages'] = (l$cachedPages as bool?);
    }
    if (data.containsKey('cachedThumbnails')) {
      final l$cachedThumbnails = data['cachedThumbnails'];
      result$data['cachedThumbnails'] = (l$cachedThumbnails as bool?);
    }
    if (data.containsKey('clientMutationId')) {
      final l$clientMutationId = data['clientMutationId'];
      result$data['clientMutationId'] = (l$clientMutationId as String?);
    }
    if (data.containsKey('downloadedThumbnails')) {
      final l$downloadedThumbnails = data['downloadedThumbnails'];
      result$data['downloadedThumbnails'] = (l$downloadedThumbnails as bool?);
    }
    return Input$ClearCachedImagesInput._(result$data);
  }

  Map<String, dynamic> _$data;

  bool? get cachedPages => (_$data['cachedPages'] as bool?);

  bool? get cachedThumbnails => (_$data['cachedThumbnails'] as bool?);

  String? get clientMutationId => (_$data['clientMutationId'] as String?);

  bool? get downloadedThumbnails => (_$data['downloadedThumbnails'] as bool?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('cachedPages')) {
      final l$cachedPages = cachedPages;
      result$data['cachedPages'] = l$cachedPages;
    }
    if (_$data.containsKey('cachedThumbnails')) {
      final l$cachedThumbnails = cachedThumbnails;
      result$data['cachedThumbnails'] = l$cachedThumbnails;
    }
    if (_$data.containsKey('clientMutationId')) {
      final l$clientMutationId = clientMutationId;
      result$data['clientMutationId'] = l$clientMutationId;
    }
    if (_$data.containsKey('downloadedThumbnails')) {
      final l$downloadedThumbnails = downloadedThumbnails;
      result$data['downloadedThumbnails'] = l$downloadedThumbnails;
    }
    return result$data;
  }

  CopyWith$Input$ClearCachedImagesInput<Input$ClearCachedImagesInput>
      get copyWith => CopyWith$Input$ClearCachedImagesInput(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$ClearCachedImagesInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$cachedPages = cachedPages;
    final lOther$cachedPages = other.cachedPages;
    if (_$data.containsKey('cachedPages') !=
        other._$data.containsKey('cachedPages')) {
      return false;
    }
    if (l$cachedPages != lOther$cachedPages) {
      return false;
    }
    final l$cachedThumbnails = cachedThumbnails;
    final lOther$cachedThumbnails = other.cachedThumbnails;
    if (_$data.containsKey('cachedThumbnails') !=
        other._$data.containsKey('cachedThumbnails')) {
      return false;
    }
    if (l$cachedThumbnails != lOther$cachedThumbnails) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (_$data.containsKey('clientMutationId') !=
        other._$data.containsKey('clientMutationId')) {
      return false;
    }
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    final l$downloadedThumbnails = downloadedThumbnails;
    final lOther$downloadedThumbnails = other.downloadedThumbnails;
    if (_$data.containsKey('downloadedThumbnails') !=
        other._$data.containsKey('downloadedThumbnails')) {
      return false;
    }
    if (l$downloadedThumbnails != lOther$downloadedThumbnails) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$cachedPages = cachedPages;
    final l$cachedThumbnails = cachedThumbnails;
    final l$clientMutationId = clientMutationId;
    final l$downloadedThumbnails = downloadedThumbnails;
    return Object.hashAll([
      _$data.containsKey('cachedPages') ? l$cachedPages : const {},
      _$data.containsKey('cachedThumbnails') ? l$cachedThumbnails : const {},
      _$data.containsKey('clientMutationId') ? l$clientMutationId : const {},
      _$data.containsKey('downloadedThumbnails')
          ? l$downloadedThumbnails
          : const {},
    ]);
  }
}

abstract class CopyWith$Input$ClearCachedImagesInput<TRes> {
  factory CopyWith$Input$ClearCachedImagesInput(
    Input$ClearCachedImagesInput instance,
    TRes Function(Input$ClearCachedImagesInput) then,
  ) = _CopyWithImpl$Input$ClearCachedImagesInput;

  factory CopyWith$Input$ClearCachedImagesInput.stub(TRes res) =
      _CopyWithStubImpl$Input$ClearCachedImagesInput;

  TRes call({
    bool? cachedPages,
    bool? cachedThumbnails,
    String? clientMutationId,
    bool? downloadedThumbnails,
  });
}

class _CopyWithImpl$Input$ClearCachedImagesInput<TRes>
    implements CopyWith$Input$ClearCachedImagesInput<TRes> {
  _CopyWithImpl$Input$ClearCachedImagesInput(
    this._instance,
    this._then,
  );

  final Input$ClearCachedImagesInput _instance;

  final TRes Function(Input$ClearCachedImagesInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? cachedPages = _undefined,
    Object? cachedThumbnails = _undefined,
    Object? clientMutationId = _undefined,
    Object? downloadedThumbnails = _undefined,
  }) =>
      _then(Input$ClearCachedImagesInput._({
        ..._instance._$data,
        if (cachedPages != _undefined) 'cachedPages': (cachedPages as bool?),
        if (cachedThumbnails != _undefined)
          'cachedThumbnails': (cachedThumbnails as bool?),
        if (clientMutationId != _undefined)
          'clientMutationId': (clientMutationId as String?),
        if (downloadedThumbnails != _undefined)
          'downloadedThumbnails': (downloadedThumbnails as bool?),
      }));
}

class _CopyWithStubImpl$Input$ClearCachedImagesInput<TRes>
    implements CopyWith$Input$ClearCachedImagesInput<TRes> {
  _CopyWithStubImpl$Input$ClearCachedImagesInput(this._res);

  TRes _res;

  call({
    bool? cachedPages,
    bool? cachedThumbnails,
    String? clientMutationId,
    bool? downloadedThumbnails,
  }) =>
      _res;
}

class Input$ClearDownloaderInput {
  factory Input$ClearDownloaderInput({String? clientMutationId}) =>
      Input$ClearDownloaderInput._({
        if (clientMutationId != null) r'clientMutationId': clientMutationId,
      });

  Input$ClearDownloaderInput._(this._$data);

  factory Input$ClearDownloaderInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('clientMutationId')) {
      final l$clientMutationId = data['clientMutationId'];
      result$data['clientMutationId'] = (l$clientMutationId as String?);
    }
    return Input$ClearDownloaderInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get clientMutationId => (_$data['clientMutationId'] as String?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('clientMutationId')) {
      final l$clientMutationId = clientMutationId;
      result$data['clientMutationId'] = l$clientMutationId;
    }
    return result$data;
  }

  CopyWith$Input$ClearDownloaderInput<Input$ClearDownloaderInput>
      get copyWith => CopyWith$Input$ClearDownloaderInput(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$ClearDownloaderInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (_$data.containsKey('clientMutationId') !=
        other._$data.containsKey('clientMutationId')) {
      return false;
    }
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$clientMutationId = clientMutationId;
    return Object.hashAll([
      _$data.containsKey('clientMutationId') ? l$clientMutationId : const {}
    ]);
  }
}

abstract class CopyWith$Input$ClearDownloaderInput<TRes> {
  factory CopyWith$Input$ClearDownloaderInput(
    Input$ClearDownloaderInput instance,
    TRes Function(Input$ClearDownloaderInput) then,
  ) = _CopyWithImpl$Input$ClearDownloaderInput;

  factory CopyWith$Input$ClearDownloaderInput.stub(TRes res) =
      _CopyWithStubImpl$Input$ClearDownloaderInput;

  TRes call({String? clientMutationId});
}

class _CopyWithImpl$Input$ClearDownloaderInput<TRes>
    implements CopyWith$Input$ClearDownloaderInput<TRes> {
  _CopyWithImpl$Input$ClearDownloaderInput(
    this._instance,
    this._then,
  );

  final Input$ClearDownloaderInput _instance;

  final TRes Function(Input$ClearDownloaderInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? clientMutationId = _undefined}) =>
      _then(Input$ClearDownloaderInput._({
        ..._instance._$data,
        if (clientMutationId != _undefined)
          'clientMutationId': (clientMutationId as String?),
      }));
}

class _CopyWithStubImpl$Input$ClearDownloaderInput<TRes>
    implements CopyWith$Input$ClearDownloaderInput<TRes> {
  _CopyWithStubImpl$Input$ClearDownloaderInput(this._res);

  TRes _res;

  call({String? clientMutationId}) => _res;
}

class Input$CreateBackupInput {
  factory Input$CreateBackupInput({
    String? clientMutationId,
    bool? includeCategories,
    bool? includeChapters,
  }) =>
      Input$CreateBackupInput._({
        if (clientMutationId != null) r'clientMutationId': clientMutationId,
        if (includeCategories != null) r'includeCategories': includeCategories,
        if (includeChapters != null) r'includeChapters': includeChapters,
      });

  Input$CreateBackupInput._(this._$data);

  factory Input$CreateBackupInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('clientMutationId')) {
      final l$clientMutationId = data['clientMutationId'];
      result$data['clientMutationId'] = (l$clientMutationId as String?);
    }
    if (data.containsKey('includeCategories')) {
      final l$includeCategories = data['includeCategories'];
      result$data['includeCategories'] = (l$includeCategories as bool?);
    }
    if (data.containsKey('includeChapters')) {
      final l$includeChapters = data['includeChapters'];
      result$data['includeChapters'] = (l$includeChapters as bool?);
    }
    return Input$CreateBackupInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get clientMutationId => (_$data['clientMutationId'] as String?);

  bool? get includeCategories => (_$data['includeCategories'] as bool?);

  bool? get includeChapters => (_$data['includeChapters'] as bool?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('clientMutationId')) {
      final l$clientMutationId = clientMutationId;
      result$data['clientMutationId'] = l$clientMutationId;
    }
    if (_$data.containsKey('includeCategories')) {
      final l$includeCategories = includeCategories;
      result$data['includeCategories'] = l$includeCategories;
    }
    if (_$data.containsKey('includeChapters')) {
      final l$includeChapters = includeChapters;
      result$data['includeChapters'] = l$includeChapters;
    }
    return result$data;
  }

  CopyWith$Input$CreateBackupInput<Input$CreateBackupInput> get copyWith =>
      CopyWith$Input$CreateBackupInput(
        this,
        (i) => i,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$CreateBackupInput || runtimeType != other.runtimeType) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (_$data.containsKey('clientMutationId') !=
        other._$data.containsKey('clientMutationId')) {
      return false;
    }
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    final l$includeCategories = includeCategories;
    final lOther$includeCategories = other.includeCategories;
    if (_$data.containsKey('includeCategories') !=
        other._$data.containsKey('includeCategories')) {
      return false;
    }
    if (l$includeCategories != lOther$includeCategories) {
      return false;
    }
    final l$includeChapters = includeChapters;
    final lOther$includeChapters = other.includeChapters;
    if (_$data.containsKey('includeChapters') !=
        other._$data.containsKey('includeChapters')) {
      return false;
    }
    if (l$includeChapters != lOther$includeChapters) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$clientMutationId = clientMutationId;
    final l$includeCategories = includeCategories;
    final l$includeChapters = includeChapters;
    return Object.hashAll([
      _$data.containsKey('clientMutationId') ? l$clientMutationId : const {},
      _$data.containsKey('includeCategories') ? l$includeCategories : const {},
      _$data.containsKey('includeChapters') ? l$includeChapters : const {},
    ]);
  }
}

abstract class CopyWith$Input$CreateBackupInput<TRes> {
  factory CopyWith$Input$CreateBackupInput(
    Input$CreateBackupInput instance,
    TRes Function(Input$CreateBackupInput) then,
  ) = _CopyWithImpl$Input$CreateBackupInput;

  factory CopyWith$Input$CreateBackupInput.stub(TRes res) =
      _CopyWithStubImpl$Input$CreateBackupInput;

  TRes call({
    String? clientMutationId,
    bool? includeCategories,
    bool? includeChapters,
  });
}

class _CopyWithImpl$Input$CreateBackupInput<TRes>
    implements CopyWith$Input$CreateBackupInput<TRes> {
  _CopyWithImpl$Input$CreateBackupInput(
    this._instance,
    this._then,
  );

  final Input$CreateBackupInput _instance;

  final TRes Function(Input$CreateBackupInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? clientMutationId = _undefined,
    Object? includeCategories = _undefined,
    Object? includeChapters = _undefined,
  }) =>
      _then(Input$CreateBackupInput._({
        ..._instance._$data,
        if (clientMutationId != _undefined)
          'clientMutationId': (clientMutationId as String?),
        if (includeCategories != _undefined)
          'includeCategories': (includeCategories as bool?),
        if (includeChapters != _undefined)
          'includeChapters': (includeChapters as bool?),
      }));
}

class _CopyWithStubImpl$Input$CreateBackupInput<TRes>
    implements CopyWith$Input$CreateBackupInput<TRes> {
  _CopyWithStubImpl$Input$CreateBackupInput(this._res);

  TRes _res;

  call({
    String? clientMutationId,
    bool? includeCategories,
    bool? includeChapters,
  }) =>
      _res;
}

class Input$CreateCategoryInput {
  factory Input$CreateCategoryInput({
    String? clientMutationId,
    bool? $default,
    Enum$IncludeOrExclude? includeInDownload,
    Enum$IncludeOrExclude? includeInUpdate,
    required String name,
    int? order,
  }) =>
      Input$CreateCategoryInput._({
        if (clientMutationId != null) r'clientMutationId': clientMutationId,
        if ($default != null) r'default': $default,
        if (includeInDownload != null) r'includeInDownload': includeInDownload,
        if (includeInUpdate != null) r'includeInUpdate': includeInUpdate,
        r'name': name,
        if (order != null) r'order': order,
      });

  Input$CreateCategoryInput._(this._$data);

  factory Input$CreateCategoryInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('clientMutationId')) {
      final l$clientMutationId = data['clientMutationId'];
      result$data['clientMutationId'] = (l$clientMutationId as String?);
    }
    if (data.containsKey('default')) {
      final l$$default = data['default'];
      result$data['default'] = (l$$default as bool?);
    }
    if (data.containsKey('includeInDownload')) {
      final l$includeInDownload = data['includeInDownload'];
      result$data['includeInDownload'] = l$includeInDownload == null
          ? null
          : fromJson$Enum$IncludeOrExclude((l$includeInDownload as String));
    }
    if (data.containsKey('includeInUpdate')) {
      final l$includeInUpdate = data['includeInUpdate'];
      result$data['includeInUpdate'] = l$includeInUpdate == null
          ? null
          : fromJson$Enum$IncludeOrExclude((l$includeInUpdate as String));
    }
    final l$name = data['name'];
    result$data['name'] = (l$name as String);
    if (data.containsKey('order')) {
      final l$order = data['order'];
      result$data['order'] = (l$order as int?);
    }
    return Input$CreateCategoryInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get clientMutationId => (_$data['clientMutationId'] as String?);

  bool? get $default => (_$data['default'] as bool?);

  Enum$IncludeOrExclude? get includeInDownload =>
      (_$data['includeInDownload'] as Enum$IncludeOrExclude?);

  Enum$IncludeOrExclude? get includeInUpdate =>
      (_$data['includeInUpdate'] as Enum$IncludeOrExclude?);

  String get name => (_$data['name'] as String);

  int? get order => (_$data['order'] as int?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('clientMutationId')) {
      final l$clientMutationId = clientMutationId;
      result$data['clientMutationId'] = l$clientMutationId;
    }
    if (_$data.containsKey('default')) {
      final l$$default = $default;
      result$data['default'] = l$$default;
    }
    if (_$data.containsKey('includeInDownload')) {
      final l$includeInDownload = includeInDownload;
      result$data['includeInDownload'] = l$includeInDownload == null
          ? null
          : toJson$Enum$IncludeOrExclude(l$includeInDownload);
    }
    if (_$data.containsKey('includeInUpdate')) {
      final l$includeInUpdate = includeInUpdate;
      result$data['includeInUpdate'] = l$includeInUpdate == null
          ? null
          : toJson$Enum$IncludeOrExclude(l$includeInUpdate);
    }
    final l$name = name;
    result$data['name'] = l$name;
    if (_$data.containsKey('order')) {
      final l$order = order;
      result$data['order'] = l$order;
    }
    return result$data;
  }

  CopyWith$Input$CreateCategoryInput<Input$CreateCategoryInput> get copyWith =>
      CopyWith$Input$CreateCategoryInput(
        this,
        (i) => i,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$CreateCategoryInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (_$data.containsKey('clientMutationId') !=
        other._$data.containsKey('clientMutationId')) {
      return false;
    }
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    final l$$default = $default;
    final lOther$$default = other.$default;
    if (_$data.containsKey('default') != other._$data.containsKey('default')) {
      return false;
    }
    if (l$$default != lOther$$default) {
      return false;
    }
    final l$includeInDownload = includeInDownload;
    final lOther$includeInDownload = other.includeInDownload;
    if (_$data.containsKey('includeInDownload') !=
        other._$data.containsKey('includeInDownload')) {
      return false;
    }
    if (l$includeInDownload != lOther$includeInDownload) {
      return false;
    }
    final l$includeInUpdate = includeInUpdate;
    final lOther$includeInUpdate = other.includeInUpdate;
    if (_$data.containsKey('includeInUpdate') !=
        other._$data.containsKey('includeInUpdate')) {
      return false;
    }
    if (l$includeInUpdate != lOther$includeInUpdate) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (l$name != lOther$name) {
      return false;
    }
    final l$order = order;
    final lOther$order = other.order;
    if (_$data.containsKey('order') != other._$data.containsKey('order')) {
      return false;
    }
    if (l$order != lOther$order) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$clientMutationId = clientMutationId;
    final l$$default = $default;
    final l$includeInDownload = includeInDownload;
    final l$includeInUpdate = includeInUpdate;
    final l$name = name;
    final l$order = order;
    return Object.hashAll([
      _$data.containsKey('clientMutationId') ? l$clientMutationId : const {},
      _$data.containsKey('default') ? l$$default : const {},
      _$data.containsKey('includeInDownload') ? l$includeInDownload : const {},
      _$data.containsKey('includeInUpdate') ? l$includeInUpdate : const {},
      l$name,
      _$data.containsKey('order') ? l$order : const {},
    ]);
  }
}

abstract class CopyWith$Input$CreateCategoryInput<TRes> {
  factory CopyWith$Input$CreateCategoryInput(
    Input$CreateCategoryInput instance,
    TRes Function(Input$CreateCategoryInput) then,
  ) = _CopyWithImpl$Input$CreateCategoryInput;

  factory CopyWith$Input$CreateCategoryInput.stub(TRes res) =
      _CopyWithStubImpl$Input$CreateCategoryInput;

  TRes call({
    String? clientMutationId,
    bool? $default,
    Enum$IncludeOrExclude? includeInDownload,
    Enum$IncludeOrExclude? includeInUpdate,
    String? name,
    int? order,
  });
}

class _CopyWithImpl$Input$CreateCategoryInput<TRes>
    implements CopyWith$Input$CreateCategoryInput<TRes> {
  _CopyWithImpl$Input$CreateCategoryInput(
    this._instance,
    this._then,
  );

  final Input$CreateCategoryInput _instance;

  final TRes Function(Input$CreateCategoryInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? clientMutationId = _undefined,
    Object? $default = _undefined,
    Object? includeInDownload = _undefined,
    Object? includeInUpdate = _undefined,
    Object? name = _undefined,
    Object? order = _undefined,
  }) =>
      _then(Input$CreateCategoryInput._({
        ..._instance._$data,
        if (clientMutationId != _undefined)
          'clientMutationId': (clientMutationId as String?),
        if ($default != _undefined) 'default': ($default as bool?),
        if (includeInDownload != _undefined)
          'includeInDownload': (includeInDownload as Enum$IncludeOrExclude?),
        if (includeInUpdate != _undefined)
          'includeInUpdate': (includeInUpdate as Enum$IncludeOrExclude?),
        if (name != _undefined && name != null) 'name': (name as String),
        if (order != _undefined) 'order': (order as int?),
      }));
}

class _CopyWithStubImpl$Input$CreateCategoryInput<TRes>
    implements CopyWith$Input$CreateCategoryInput<TRes> {
  _CopyWithStubImpl$Input$CreateCategoryInput(this._res);

  TRes _res;

  call({
    String? clientMutationId,
    bool? $default,
    Enum$IncludeOrExclude? includeInDownload,
    Enum$IncludeOrExclude? includeInUpdate,
    String? name,
    int? order,
  }) =>
      _res;
}

class Input$DeleteCategoryInput {
  factory Input$DeleteCategoryInput({
    required int categoryId,
    String? clientMutationId,
  }) =>
      Input$DeleteCategoryInput._({
        r'categoryId': categoryId,
        if (clientMutationId != null) r'clientMutationId': clientMutationId,
      });

  Input$DeleteCategoryInput._(this._$data);

  factory Input$DeleteCategoryInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$categoryId = data['categoryId'];
    result$data['categoryId'] = (l$categoryId as int);
    if (data.containsKey('clientMutationId')) {
      final l$clientMutationId = data['clientMutationId'];
      result$data['clientMutationId'] = (l$clientMutationId as String?);
    }
    return Input$DeleteCategoryInput._(result$data);
  }

  Map<String, dynamic> _$data;

  int get categoryId => (_$data['categoryId'] as int);

  String? get clientMutationId => (_$data['clientMutationId'] as String?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$categoryId = categoryId;
    result$data['categoryId'] = l$categoryId;
    if (_$data.containsKey('clientMutationId')) {
      final l$clientMutationId = clientMutationId;
      result$data['clientMutationId'] = l$clientMutationId;
    }
    return result$data;
  }

  CopyWith$Input$DeleteCategoryInput<Input$DeleteCategoryInput> get copyWith =>
      CopyWith$Input$DeleteCategoryInput(
        this,
        (i) => i,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$DeleteCategoryInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$categoryId = categoryId;
    final lOther$categoryId = other.categoryId;
    if (l$categoryId != lOther$categoryId) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (_$data.containsKey('clientMutationId') !=
        other._$data.containsKey('clientMutationId')) {
      return false;
    }
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$categoryId = categoryId;
    final l$clientMutationId = clientMutationId;
    return Object.hashAll([
      l$categoryId,
      _$data.containsKey('clientMutationId') ? l$clientMutationId : const {},
    ]);
  }
}

abstract class CopyWith$Input$DeleteCategoryInput<TRes> {
  factory CopyWith$Input$DeleteCategoryInput(
    Input$DeleteCategoryInput instance,
    TRes Function(Input$DeleteCategoryInput) then,
  ) = _CopyWithImpl$Input$DeleteCategoryInput;

  factory CopyWith$Input$DeleteCategoryInput.stub(TRes res) =
      _CopyWithStubImpl$Input$DeleteCategoryInput;

  TRes call({
    int? categoryId,
    String? clientMutationId,
  });
}

class _CopyWithImpl$Input$DeleteCategoryInput<TRes>
    implements CopyWith$Input$DeleteCategoryInput<TRes> {
  _CopyWithImpl$Input$DeleteCategoryInput(
    this._instance,
    this._then,
  );

  final Input$DeleteCategoryInput _instance;

  final TRes Function(Input$DeleteCategoryInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? categoryId = _undefined,
    Object? clientMutationId = _undefined,
  }) =>
      _then(Input$DeleteCategoryInput._({
        ..._instance._$data,
        if (categoryId != _undefined && categoryId != null)
          'categoryId': (categoryId as int),
        if (clientMutationId != _undefined)
          'clientMutationId': (clientMutationId as String?),
      }));
}

class _CopyWithStubImpl$Input$DeleteCategoryInput<TRes>
    implements CopyWith$Input$DeleteCategoryInput<TRes> {
  _CopyWithStubImpl$Input$DeleteCategoryInput(this._res);

  TRes _res;

  call({
    int? categoryId,
    String? clientMutationId,
  }) =>
      _res;
}

class Input$DeleteCategoryMetaInput {
  factory Input$DeleteCategoryMetaInput({
    required int categoryId,
    String? clientMutationId,
    required String key,
  }) =>
      Input$DeleteCategoryMetaInput._({
        r'categoryId': categoryId,
        if (clientMutationId != null) r'clientMutationId': clientMutationId,
        r'key': key,
      });

  Input$DeleteCategoryMetaInput._(this._$data);

  factory Input$DeleteCategoryMetaInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$categoryId = data['categoryId'];
    result$data['categoryId'] = (l$categoryId as int);
    if (data.containsKey('clientMutationId')) {
      final l$clientMutationId = data['clientMutationId'];
      result$data['clientMutationId'] = (l$clientMutationId as String?);
    }
    final l$key = data['key'];
    result$data['key'] = (l$key as String);
    return Input$DeleteCategoryMetaInput._(result$data);
  }

  Map<String, dynamic> _$data;

  int get categoryId => (_$data['categoryId'] as int);

  String? get clientMutationId => (_$data['clientMutationId'] as String?);

  String get key => (_$data['key'] as String);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$categoryId = categoryId;
    result$data['categoryId'] = l$categoryId;
    if (_$data.containsKey('clientMutationId')) {
      final l$clientMutationId = clientMutationId;
      result$data['clientMutationId'] = l$clientMutationId;
    }
    final l$key = key;
    result$data['key'] = l$key;
    return result$data;
  }

  CopyWith$Input$DeleteCategoryMetaInput<Input$DeleteCategoryMetaInput>
      get copyWith => CopyWith$Input$DeleteCategoryMetaInput(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$DeleteCategoryMetaInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$categoryId = categoryId;
    final lOther$categoryId = other.categoryId;
    if (l$categoryId != lOther$categoryId) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (_$data.containsKey('clientMutationId') !=
        other._$data.containsKey('clientMutationId')) {
      return false;
    }
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    final l$key = key;
    final lOther$key = other.key;
    if (l$key != lOther$key) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$categoryId = categoryId;
    final l$clientMutationId = clientMutationId;
    final l$key = key;
    return Object.hashAll([
      l$categoryId,
      _$data.containsKey('clientMutationId') ? l$clientMutationId : const {},
      l$key,
    ]);
  }
}

abstract class CopyWith$Input$DeleteCategoryMetaInput<TRes> {
  factory CopyWith$Input$DeleteCategoryMetaInput(
    Input$DeleteCategoryMetaInput instance,
    TRes Function(Input$DeleteCategoryMetaInput) then,
  ) = _CopyWithImpl$Input$DeleteCategoryMetaInput;

  factory CopyWith$Input$DeleteCategoryMetaInput.stub(TRes res) =
      _CopyWithStubImpl$Input$DeleteCategoryMetaInput;

  TRes call({
    int? categoryId,
    String? clientMutationId,
    String? key,
  });
}

class _CopyWithImpl$Input$DeleteCategoryMetaInput<TRes>
    implements CopyWith$Input$DeleteCategoryMetaInput<TRes> {
  _CopyWithImpl$Input$DeleteCategoryMetaInput(
    this._instance,
    this._then,
  );

  final Input$DeleteCategoryMetaInput _instance;

  final TRes Function(Input$DeleteCategoryMetaInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? categoryId = _undefined,
    Object? clientMutationId = _undefined,
    Object? key = _undefined,
  }) =>
      _then(Input$DeleteCategoryMetaInput._({
        ..._instance._$data,
        if (categoryId != _undefined && categoryId != null)
          'categoryId': (categoryId as int),
        if (clientMutationId != _undefined)
          'clientMutationId': (clientMutationId as String?),
        if (key != _undefined && key != null) 'key': (key as String),
      }));
}

class _CopyWithStubImpl$Input$DeleteCategoryMetaInput<TRes>
    implements CopyWith$Input$DeleteCategoryMetaInput<TRes> {
  _CopyWithStubImpl$Input$DeleteCategoryMetaInput(this._res);

  TRes _res;

  call({
    int? categoryId,
    String? clientMutationId,
    String? key,
  }) =>
      _res;
}

class Input$DeleteChapterMetaInput {
  factory Input$DeleteChapterMetaInput({
    required int chapterId,
    String? clientMutationId,
    required String key,
  }) =>
      Input$DeleteChapterMetaInput._({
        r'chapterId': chapterId,
        if (clientMutationId != null) r'clientMutationId': clientMutationId,
        r'key': key,
      });

  Input$DeleteChapterMetaInput._(this._$data);

  factory Input$DeleteChapterMetaInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$chapterId = data['chapterId'];
    result$data['chapterId'] = (l$chapterId as int);
    if (data.containsKey('clientMutationId')) {
      final l$clientMutationId = data['clientMutationId'];
      result$data['clientMutationId'] = (l$clientMutationId as String?);
    }
    final l$key = data['key'];
    result$data['key'] = (l$key as String);
    return Input$DeleteChapterMetaInput._(result$data);
  }

  Map<String, dynamic> _$data;

  int get chapterId => (_$data['chapterId'] as int);

  String? get clientMutationId => (_$data['clientMutationId'] as String?);

  String get key => (_$data['key'] as String);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$chapterId = chapterId;
    result$data['chapterId'] = l$chapterId;
    if (_$data.containsKey('clientMutationId')) {
      final l$clientMutationId = clientMutationId;
      result$data['clientMutationId'] = l$clientMutationId;
    }
    final l$key = key;
    result$data['key'] = l$key;
    return result$data;
  }

  CopyWith$Input$DeleteChapterMetaInput<Input$DeleteChapterMetaInput>
      get copyWith => CopyWith$Input$DeleteChapterMetaInput(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$DeleteChapterMetaInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$chapterId = chapterId;
    final lOther$chapterId = other.chapterId;
    if (l$chapterId != lOther$chapterId) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (_$data.containsKey('clientMutationId') !=
        other._$data.containsKey('clientMutationId')) {
      return false;
    }
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    final l$key = key;
    final lOther$key = other.key;
    if (l$key != lOther$key) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$chapterId = chapterId;
    final l$clientMutationId = clientMutationId;
    final l$key = key;
    return Object.hashAll([
      l$chapterId,
      _$data.containsKey('clientMutationId') ? l$clientMutationId : const {},
      l$key,
    ]);
  }
}

abstract class CopyWith$Input$DeleteChapterMetaInput<TRes> {
  factory CopyWith$Input$DeleteChapterMetaInput(
    Input$DeleteChapterMetaInput instance,
    TRes Function(Input$DeleteChapterMetaInput) then,
  ) = _CopyWithImpl$Input$DeleteChapterMetaInput;

  factory CopyWith$Input$DeleteChapterMetaInput.stub(TRes res) =
      _CopyWithStubImpl$Input$DeleteChapterMetaInput;

  TRes call({
    int? chapterId,
    String? clientMutationId,
    String? key,
  });
}

class _CopyWithImpl$Input$DeleteChapterMetaInput<TRes>
    implements CopyWith$Input$DeleteChapterMetaInput<TRes> {
  _CopyWithImpl$Input$DeleteChapterMetaInput(
    this._instance,
    this._then,
  );

  final Input$DeleteChapterMetaInput _instance;

  final TRes Function(Input$DeleteChapterMetaInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? chapterId = _undefined,
    Object? clientMutationId = _undefined,
    Object? key = _undefined,
  }) =>
      _then(Input$DeleteChapterMetaInput._({
        ..._instance._$data,
        if (chapterId != _undefined && chapterId != null)
          'chapterId': (chapterId as int),
        if (clientMutationId != _undefined)
          'clientMutationId': (clientMutationId as String?),
        if (key != _undefined && key != null) 'key': (key as String),
      }));
}

class _CopyWithStubImpl$Input$DeleteChapterMetaInput<TRes>
    implements CopyWith$Input$DeleteChapterMetaInput<TRes> {
  _CopyWithStubImpl$Input$DeleteChapterMetaInput(this._res);

  TRes _res;

  call({
    int? chapterId,
    String? clientMutationId,
    String? key,
  }) =>
      _res;
}

class Input$DeleteDownloadedChapterInput {
  factory Input$DeleteDownloadedChapterInput({
    String? clientMutationId,
    required int id,
  }) =>
      Input$DeleteDownloadedChapterInput._({
        if (clientMutationId != null) r'clientMutationId': clientMutationId,
        r'id': id,
      });

  Input$DeleteDownloadedChapterInput._(this._$data);

  factory Input$DeleteDownloadedChapterInput.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('clientMutationId')) {
      final l$clientMutationId = data['clientMutationId'];
      result$data['clientMutationId'] = (l$clientMutationId as String?);
    }
    final l$id = data['id'];
    result$data['id'] = (l$id as int);
    return Input$DeleteDownloadedChapterInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get clientMutationId => (_$data['clientMutationId'] as String?);

  int get id => (_$data['id'] as int);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('clientMutationId')) {
      final l$clientMutationId = clientMutationId;
      result$data['clientMutationId'] = l$clientMutationId;
    }
    final l$id = id;
    result$data['id'] = l$id;
    return result$data;
  }

  CopyWith$Input$DeleteDownloadedChapterInput<
          Input$DeleteDownloadedChapterInput>
      get copyWith => CopyWith$Input$DeleteDownloadedChapterInput(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$DeleteDownloadedChapterInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (_$data.containsKey('clientMutationId') !=
        other._$data.containsKey('clientMutationId')) {
      return false;
    }
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$clientMutationId = clientMutationId;
    final l$id = id;
    return Object.hashAll([
      _$data.containsKey('clientMutationId') ? l$clientMutationId : const {},
      l$id,
    ]);
  }
}

abstract class CopyWith$Input$DeleteDownloadedChapterInput<TRes> {
  factory CopyWith$Input$DeleteDownloadedChapterInput(
    Input$DeleteDownloadedChapterInput instance,
    TRes Function(Input$DeleteDownloadedChapterInput) then,
  ) = _CopyWithImpl$Input$DeleteDownloadedChapterInput;

  factory CopyWith$Input$DeleteDownloadedChapterInput.stub(TRes res) =
      _CopyWithStubImpl$Input$DeleteDownloadedChapterInput;

  TRes call({
    String? clientMutationId,
    int? id,
  });
}

class _CopyWithImpl$Input$DeleteDownloadedChapterInput<TRes>
    implements CopyWith$Input$DeleteDownloadedChapterInput<TRes> {
  _CopyWithImpl$Input$DeleteDownloadedChapterInput(
    this._instance,
    this._then,
  );

  final Input$DeleteDownloadedChapterInput _instance;

  final TRes Function(Input$DeleteDownloadedChapterInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? clientMutationId = _undefined,
    Object? id = _undefined,
  }) =>
      _then(Input$DeleteDownloadedChapterInput._({
        ..._instance._$data,
        if (clientMutationId != _undefined)
          'clientMutationId': (clientMutationId as String?),
        if (id != _undefined && id != null) 'id': (id as int),
      }));
}

class _CopyWithStubImpl$Input$DeleteDownloadedChapterInput<TRes>
    implements CopyWith$Input$DeleteDownloadedChapterInput<TRes> {
  _CopyWithStubImpl$Input$DeleteDownloadedChapterInput(this._res);

  TRes _res;

  call({
    String? clientMutationId,
    int? id,
  }) =>
      _res;
}

class Input$DeleteDownloadedChaptersInput {
  factory Input$DeleteDownloadedChaptersInput({
    String? clientMutationId,
    required List<int> ids,
  }) =>
      Input$DeleteDownloadedChaptersInput._({
        if (clientMutationId != null) r'clientMutationId': clientMutationId,
        r'ids': ids,
      });

  Input$DeleteDownloadedChaptersInput._(this._$data);

  factory Input$DeleteDownloadedChaptersInput.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('clientMutationId')) {
      final l$clientMutationId = data['clientMutationId'];
      result$data['clientMutationId'] = (l$clientMutationId as String?);
    }
    final l$ids = data['ids'];
    result$data['ids'] =
        (l$ids as List<dynamic>).map((e) => (e as int)).toList();
    return Input$DeleteDownloadedChaptersInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get clientMutationId => (_$data['clientMutationId'] as String?);

  List<int> get ids => (_$data['ids'] as List<int>);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('clientMutationId')) {
      final l$clientMutationId = clientMutationId;
      result$data['clientMutationId'] = l$clientMutationId;
    }
    final l$ids = ids;
    result$data['ids'] = l$ids.map((e) => e).toList();
    return result$data;
  }

  CopyWith$Input$DeleteDownloadedChaptersInput<
          Input$DeleteDownloadedChaptersInput>
      get copyWith => CopyWith$Input$DeleteDownloadedChaptersInput(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$DeleteDownloadedChaptersInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (_$data.containsKey('clientMutationId') !=
        other._$data.containsKey('clientMutationId')) {
      return false;
    }
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    final l$ids = ids;
    final lOther$ids = other.ids;
    if (l$ids.length != lOther$ids.length) {
      return false;
    }
    for (int i = 0; i < l$ids.length; i++) {
      final l$ids$entry = l$ids[i];
      final lOther$ids$entry = lOther$ids[i];
      if (l$ids$entry != lOther$ids$entry) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode {
    final l$clientMutationId = clientMutationId;
    final l$ids = ids;
    return Object.hashAll([
      _$data.containsKey('clientMutationId') ? l$clientMutationId : const {},
      Object.hashAll(l$ids.map((v) => v)),
    ]);
  }
}

abstract class CopyWith$Input$DeleteDownloadedChaptersInput<TRes> {
  factory CopyWith$Input$DeleteDownloadedChaptersInput(
    Input$DeleteDownloadedChaptersInput instance,
    TRes Function(Input$DeleteDownloadedChaptersInput) then,
  ) = _CopyWithImpl$Input$DeleteDownloadedChaptersInput;

  factory CopyWith$Input$DeleteDownloadedChaptersInput.stub(TRes res) =
      _CopyWithStubImpl$Input$DeleteDownloadedChaptersInput;

  TRes call({
    String? clientMutationId,
    List<int>? ids,
  });
}

class _CopyWithImpl$Input$DeleteDownloadedChaptersInput<TRes>
    implements CopyWith$Input$DeleteDownloadedChaptersInput<TRes> {
  _CopyWithImpl$Input$DeleteDownloadedChaptersInput(
    this._instance,
    this._then,
  );

  final Input$DeleteDownloadedChaptersInput _instance;

  final TRes Function(Input$DeleteDownloadedChaptersInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? clientMutationId = _undefined,
    Object? ids = _undefined,
  }) =>
      _then(Input$DeleteDownloadedChaptersInput._({
        ..._instance._$data,
        if (clientMutationId != _undefined)
          'clientMutationId': (clientMutationId as String?),
        if (ids != _undefined && ids != null) 'ids': (ids as List<int>),
      }));
}

class _CopyWithStubImpl$Input$DeleteDownloadedChaptersInput<TRes>
    implements CopyWith$Input$DeleteDownloadedChaptersInput<TRes> {
  _CopyWithStubImpl$Input$DeleteDownloadedChaptersInput(this._res);

  TRes _res;

  call({
    String? clientMutationId,
    List<int>? ids,
  }) =>
      _res;
}

class Input$DeleteGlobalMetaInput {
  factory Input$DeleteGlobalMetaInput({
    String? clientMutationId,
    required String key,
  }) =>
      Input$DeleteGlobalMetaInput._({
        if (clientMutationId != null) r'clientMutationId': clientMutationId,
        r'key': key,
      });

  Input$DeleteGlobalMetaInput._(this._$data);

  factory Input$DeleteGlobalMetaInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('clientMutationId')) {
      final l$clientMutationId = data['clientMutationId'];
      result$data['clientMutationId'] = (l$clientMutationId as String?);
    }
    final l$key = data['key'];
    result$data['key'] = (l$key as String);
    return Input$DeleteGlobalMetaInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get clientMutationId => (_$data['clientMutationId'] as String?);

  String get key => (_$data['key'] as String);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('clientMutationId')) {
      final l$clientMutationId = clientMutationId;
      result$data['clientMutationId'] = l$clientMutationId;
    }
    final l$key = key;
    result$data['key'] = l$key;
    return result$data;
  }

  CopyWith$Input$DeleteGlobalMetaInput<Input$DeleteGlobalMetaInput>
      get copyWith => CopyWith$Input$DeleteGlobalMetaInput(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$DeleteGlobalMetaInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (_$data.containsKey('clientMutationId') !=
        other._$data.containsKey('clientMutationId')) {
      return false;
    }
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    final l$key = key;
    final lOther$key = other.key;
    if (l$key != lOther$key) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$clientMutationId = clientMutationId;
    final l$key = key;
    return Object.hashAll([
      _$data.containsKey('clientMutationId') ? l$clientMutationId : const {},
      l$key,
    ]);
  }
}

abstract class CopyWith$Input$DeleteGlobalMetaInput<TRes> {
  factory CopyWith$Input$DeleteGlobalMetaInput(
    Input$DeleteGlobalMetaInput instance,
    TRes Function(Input$DeleteGlobalMetaInput) then,
  ) = _CopyWithImpl$Input$DeleteGlobalMetaInput;

  factory CopyWith$Input$DeleteGlobalMetaInput.stub(TRes res) =
      _CopyWithStubImpl$Input$DeleteGlobalMetaInput;

  TRes call({
    String? clientMutationId,
    String? key,
  });
}

class _CopyWithImpl$Input$DeleteGlobalMetaInput<TRes>
    implements CopyWith$Input$DeleteGlobalMetaInput<TRes> {
  _CopyWithImpl$Input$DeleteGlobalMetaInput(
    this._instance,
    this._then,
  );

  final Input$DeleteGlobalMetaInput _instance;

  final TRes Function(Input$DeleteGlobalMetaInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? clientMutationId = _undefined,
    Object? key = _undefined,
  }) =>
      _then(Input$DeleteGlobalMetaInput._({
        ..._instance._$data,
        if (clientMutationId != _undefined)
          'clientMutationId': (clientMutationId as String?),
        if (key != _undefined && key != null) 'key': (key as String),
      }));
}

class _CopyWithStubImpl$Input$DeleteGlobalMetaInput<TRes>
    implements CopyWith$Input$DeleteGlobalMetaInput<TRes> {
  _CopyWithStubImpl$Input$DeleteGlobalMetaInput(this._res);

  TRes _res;

  call({
    String? clientMutationId,
    String? key,
  }) =>
      _res;
}

class Input$DeleteMangaMetaInput {
  factory Input$DeleteMangaMetaInput({
    String? clientMutationId,
    required String key,
    required int mangaId,
  }) =>
      Input$DeleteMangaMetaInput._({
        if (clientMutationId != null) r'clientMutationId': clientMutationId,
        r'key': key,
        r'mangaId': mangaId,
      });

  Input$DeleteMangaMetaInput._(this._$data);

  factory Input$DeleteMangaMetaInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('clientMutationId')) {
      final l$clientMutationId = data['clientMutationId'];
      result$data['clientMutationId'] = (l$clientMutationId as String?);
    }
    final l$key = data['key'];
    result$data['key'] = (l$key as String);
    final l$mangaId = data['mangaId'];
    result$data['mangaId'] = (l$mangaId as int);
    return Input$DeleteMangaMetaInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get clientMutationId => (_$data['clientMutationId'] as String?);

  String get key => (_$data['key'] as String);

  int get mangaId => (_$data['mangaId'] as int);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('clientMutationId')) {
      final l$clientMutationId = clientMutationId;
      result$data['clientMutationId'] = l$clientMutationId;
    }
    final l$key = key;
    result$data['key'] = l$key;
    final l$mangaId = mangaId;
    result$data['mangaId'] = l$mangaId;
    return result$data;
  }

  CopyWith$Input$DeleteMangaMetaInput<Input$DeleteMangaMetaInput>
      get copyWith => CopyWith$Input$DeleteMangaMetaInput(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$DeleteMangaMetaInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (_$data.containsKey('clientMutationId') !=
        other._$data.containsKey('clientMutationId')) {
      return false;
    }
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    final l$key = key;
    final lOther$key = other.key;
    if (l$key != lOther$key) {
      return false;
    }
    final l$mangaId = mangaId;
    final lOther$mangaId = other.mangaId;
    if (l$mangaId != lOther$mangaId) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$clientMutationId = clientMutationId;
    final l$key = key;
    final l$mangaId = mangaId;
    return Object.hashAll([
      _$data.containsKey('clientMutationId') ? l$clientMutationId : const {},
      l$key,
      l$mangaId,
    ]);
  }
}

abstract class CopyWith$Input$DeleteMangaMetaInput<TRes> {
  factory CopyWith$Input$DeleteMangaMetaInput(
    Input$DeleteMangaMetaInput instance,
    TRes Function(Input$DeleteMangaMetaInput) then,
  ) = _CopyWithImpl$Input$DeleteMangaMetaInput;

  factory CopyWith$Input$DeleteMangaMetaInput.stub(TRes res) =
      _CopyWithStubImpl$Input$DeleteMangaMetaInput;

  TRes call({
    String? clientMutationId,
    String? key,
    int? mangaId,
  });
}

class _CopyWithImpl$Input$DeleteMangaMetaInput<TRes>
    implements CopyWith$Input$DeleteMangaMetaInput<TRes> {
  _CopyWithImpl$Input$DeleteMangaMetaInput(
    this._instance,
    this._then,
  );

  final Input$DeleteMangaMetaInput _instance;

  final TRes Function(Input$DeleteMangaMetaInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? clientMutationId = _undefined,
    Object? key = _undefined,
    Object? mangaId = _undefined,
  }) =>
      _then(Input$DeleteMangaMetaInput._({
        ..._instance._$data,
        if (clientMutationId != _undefined)
          'clientMutationId': (clientMutationId as String?),
        if (key != _undefined && key != null) 'key': (key as String),
        if (mangaId != _undefined && mangaId != null)
          'mangaId': (mangaId as int),
      }));
}

class _CopyWithStubImpl$Input$DeleteMangaMetaInput<TRes>
    implements CopyWith$Input$DeleteMangaMetaInput<TRes> {
  _CopyWithStubImpl$Input$DeleteMangaMetaInput(this._res);

  TRes _res;

  call({
    String? clientMutationId,
    String? key,
    int? mangaId,
  }) =>
      _res;
}

class Input$DeleteSourceMetaInput {
  factory Input$DeleteSourceMetaInput({
    String? clientMutationId,
    required String key,
    required String sourceId,
  }) =>
      Input$DeleteSourceMetaInput._({
        if (clientMutationId != null) r'clientMutationId': clientMutationId,
        r'key': key,
        r'sourceId': sourceId,
      });

  Input$DeleteSourceMetaInput._(this._$data);

  factory Input$DeleteSourceMetaInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('clientMutationId')) {
      final l$clientMutationId = data['clientMutationId'];
      result$data['clientMutationId'] = (l$clientMutationId as String?);
    }
    final l$key = data['key'];
    result$data['key'] = (l$key as String);
    final l$sourceId = data['sourceId'];
    result$data['sourceId'] = longStringFromJson(l$sourceId);
    return Input$DeleteSourceMetaInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get clientMutationId => (_$data['clientMutationId'] as String?);

  String get key => (_$data['key'] as String);

  String get sourceId => (_$data['sourceId'] as String);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('clientMutationId')) {
      final l$clientMutationId = clientMutationId;
      result$data['clientMutationId'] = l$clientMutationId;
    }
    final l$key = key;
    result$data['key'] = l$key;
    final l$sourceId = sourceId;
    result$data['sourceId'] = longStringToJson(l$sourceId);
    return result$data;
  }

  CopyWith$Input$DeleteSourceMetaInput<Input$DeleteSourceMetaInput>
      get copyWith => CopyWith$Input$DeleteSourceMetaInput(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$DeleteSourceMetaInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (_$data.containsKey('clientMutationId') !=
        other._$data.containsKey('clientMutationId')) {
      return false;
    }
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    final l$key = key;
    final lOther$key = other.key;
    if (l$key != lOther$key) {
      return false;
    }
    final l$sourceId = sourceId;
    final lOther$sourceId = other.sourceId;
    if (l$sourceId != lOther$sourceId) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$clientMutationId = clientMutationId;
    final l$key = key;
    final l$sourceId = sourceId;
    return Object.hashAll([
      _$data.containsKey('clientMutationId') ? l$clientMutationId : const {},
      l$key,
      l$sourceId,
    ]);
  }
}

abstract class CopyWith$Input$DeleteSourceMetaInput<TRes> {
  factory CopyWith$Input$DeleteSourceMetaInput(
    Input$DeleteSourceMetaInput instance,
    TRes Function(Input$DeleteSourceMetaInput) then,
  ) = _CopyWithImpl$Input$DeleteSourceMetaInput;

  factory CopyWith$Input$DeleteSourceMetaInput.stub(TRes res) =
      _CopyWithStubImpl$Input$DeleteSourceMetaInput;

  TRes call({
    String? clientMutationId,
    String? key,
    String? sourceId,
  });
}

class _CopyWithImpl$Input$DeleteSourceMetaInput<TRes>
    implements CopyWith$Input$DeleteSourceMetaInput<TRes> {
  _CopyWithImpl$Input$DeleteSourceMetaInput(
    this._instance,
    this._then,
  );

  final Input$DeleteSourceMetaInput _instance;

  final TRes Function(Input$DeleteSourceMetaInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? clientMutationId = _undefined,
    Object? key = _undefined,
    Object? sourceId = _undefined,
  }) =>
      _then(Input$DeleteSourceMetaInput._({
        ..._instance._$data,
        if (clientMutationId != _undefined)
          'clientMutationId': (clientMutationId as String?),
        if (key != _undefined && key != null) 'key': (key as String),
        if (sourceId != _undefined && sourceId != null)
          'sourceId': (sourceId as String),
      }));
}

class _CopyWithStubImpl$Input$DeleteSourceMetaInput<TRes>
    implements CopyWith$Input$DeleteSourceMetaInput<TRes> {
  _CopyWithStubImpl$Input$DeleteSourceMetaInput(this._res);

  TRes _res;

  call({
    String? clientMutationId,
    String? key,
    String? sourceId,
  }) =>
      _res;
}

class Input$DequeueChapterDownloadInput {
  factory Input$DequeueChapterDownloadInput({
    String? clientMutationId,
    required int id,
  }) =>
      Input$DequeueChapterDownloadInput._({
        if (clientMutationId != null) r'clientMutationId': clientMutationId,
        r'id': id,
      });

  Input$DequeueChapterDownloadInput._(this._$data);

  factory Input$DequeueChapterDownloadInput.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('clientMutationId')) {
      final l$clientMutationId = data['clientMutationId'];
      result$data['clientMutationId'] = (l$clientMutationId as String?);
    }
    final l$id = data['id'];
    result$data['id'] = (l$id as int);
    return Input$DequeueChapterDownloadInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get clientMutationId => (_$data['clientMutationId'] as String?);

  int get id => (_$data['id'] as int);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('clientMutationId')) {
      final l$clientMutationId = clientMutationId;
      result$data['clientMutationId'] = l$clientMutationId;
    }
    final l$id = id;
    result$data['id'] = l$id;
    return result$data;
  }

  CopyWith$Input$DequeueChapterDownloadInput<Input$DequeueChapterDownloadInput>
      get copyWith => CopyWith$Input$DequeueChapterDownloadInput(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$DequeueChapterDownloadInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (_$data.containsKey('clientMutationId') !=
        other._$data.containsKey('clientMutationId')) {
      return false;
    }
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$clientMutationId = clientMutationId;
    final l$id = id;
    return Object.hashAll([
      _$data.containsKey('clientMutationId') ? l$clientMutationId : const {},
      l$id,
    ]);
  }
}

abstract class CopyWith$Input$DequeueChapterDownloadInput<TRes> {
  factory CopyWith$Input$DequeueChapterDownloadInput(
    Input$DequeueChapterDownloadInput instance,
    TRes Function(Input$DequeueChapterDownloadInput) then,
  ) = _CopyWithImpl$Input$DequeueChapterDownloadInput;

  factory CopyWith$Input$DequeueChapterDownloadInput.stub(TRes res) =
      _CopyWithStubImpl$Input$DequeueChapterDownloadInput;

  TRes call({
    String? clientMutationId,
    int? id,
  });
}

class _CopyWithImpl$Input$DequeueChapterDownloadInput<TRes>
    implements CopyWith$Input$DequeueChapterDownloadInput<TRes> {
  _CopyWithImpl$Input$DequeueChapterDownloadInput(
    this._instance,
    this._then,
  );

  final Input$DequeueChapterDownloadInput _instance;

  final TRes Function(Input$DequeueChapterDownloadInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? clientMutationId = _undefined,
    Object? id = _undefined,
  }) =>
      _then(Input$DequeueChapterDownloadInput._({
        ..._instance._$data,
        if (clientMutationId != _undefined)
          'clientMutationId': (clientMutationId as String?),
        if (id != _undefined && id != null) 'id': (id as int),
      }));
}

class _CopyWithStubImpl$Input$DequeueChapterDownloadInput<TRes>
    implements CopyWith$Input$DequeueChapterDownloadInput<TRes> {
  _CopyWithStubImpl$Input$DequeueChapterDownloadInput(this._res);

  TRes _res;

  call({
    String? clientMutationId,
    int? id,
  }) =>
      _res;
}

class Input$DequeueChapterDownloadsInput {
  factory Input$DequeueChapterDownloadsInput({
    String? clientMutationId,
    required List<int> ids,
  }) =>
      Input$DequeueChapterDownloadsInput._({
        if (clientMutationId != null) r'clientMutationId': clientMutationId,
        r'ids': ids,
      });

  Input$DequeueChapterDownloadsInput._(this._$data);

  factory Input$DequeueChapterDownloadsInput.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('clientMutationId')) {
      final l$clientMutationId = data['clientMutationId'];
      result$data['clientMutationId'] = (l$clientMutationId as String?);
    }
    final l$ids = data['ids'];
    result$data['ids'] =
        (l$ids as List<dynamic>).map((e) => (e as int)).toList();
    return Input$DequeueChapterDownloadsInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get clientMutationId => (_$data['clientMutationId'] as String?);

  List<int> get ids => (_$data['ids'] as List<int>);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('clientMutationId')) {
      final l$clientMutationId = clientMutationId;
      result$data['clientMutationId'] = l$clientMutationId;
    }
    final l$ids = ids;
    result$data['ids'] = l$ids.map((e) => e).toList();
    return result$data;
  }

  CopyWith$Input$DequeueChapterDownloadsInput<
          Input$DequeueChapterDownloadsInput>
      get copyWith => CopyWith$Input$DequeueChapterDownloadsInput(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$DequeueChapterDownloadsInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (_$data.containsKey('clientMutationId') !=
        other._$data.containsKey('clientMutationId')) {
      return false;
    }
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    final l$ids = ids;
    final lOther$ids = other.ids;
    if (l$ids.length != lOther$ids.length) {
      return false;
    }
    for (int i = 0; i < l$ids.length; i++) {
      final l$ids$entry = l$ids[i];
      final lOther$ids$entry = lOther$ids[i];
      if (l$ids$entry != lOther$ids$entry) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode {
    final l$clientMutationId = clientMutationId;
    final l$ids = ids;
    return Object.hashAll([
      _$data.containsKey('clientMutationId') ? l$clientMutationId : const {},
      Object.hashAll(l$ids.map((v) => v)),
    ]);
  }
}

abstract class CopyWith$Input$DequeueChapterDownloadsInput<TRes> {
  factory CopyWith$Input$DequeueChapterDownloadsInput(
    Input$DequeueChapterDownloadsInput instance,
    TRes Function(Input$DequeueChapterDownloadsInput) then,
  ) = _CopyWithImpl$Input$DequeueChapterDownloadsInput;

  factory CopyWith$Input$DequeueChapterDownloadsInput.stub(TRes res) =
      _CopyWithStubImpl$Input$DequeueChapterDownloadsInput;

  TRes call({
    String? clientMutationId,
    List<int>? ids,
  });
}

class _CopyWithImpl$Input$DequeueChapterDownloadsInput<TRes>
    implements CopyWith$Input$DequeueChapterDownloadsInput<TRes> {
  _CopyWithImpl$Input$DequeueChapterDownloadsInput(
    this._instance,
    this._then,
  );

  final Input$DequeueChapterDownloadsInput _instance;

  final TRes Function(Input$DequeueChapterDownloadsInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? clientMutationId = _undefined,
    Object? ids = _undefined,
  }) =>
      _then(Input$DequeueChapterDownloadsInput._({
        ..._instance._$data,
        if (clientMutationId != _undefined)
          'clientMutationId': (clientMutationId as String?),
        if (ids != _undefined && ids != null) 'ids': (ids as List<int>),
      }));
}

class _CopyWithStubImpl$Input$DequeueChapterDownloadsInput<TRes>
    implements CopyWith$Input$DequeueChapterDownloadsInput<TRes> {
  _CopyWithStubImpl$Input$DequeueChapterDownloadsInput(this._res);

  TRes _res;

  call({
    String? clientMutationId,
    List<int>? ids,
  }) =>
      _res;
}

class Input$DoubleFilterInput {
  factory Input$DoubleFilterInput({
    double? distinctFrom,
    List<double>? distinctFromAll,
    List<double>? distinctFromAny,
    double? equalTo,
    double? greaterThan,
    double? greaterThanOrEqualTo,
    List<double>? $in,
    bool? isNull,
    double? lessThan,
    double? lessThanOrEqualTo,
    double? notDistinctFrom,
    double? notEqualTo,
    List<double>? notEqualToAll,
    List<double>? notEqualToAny,
    List<double>? notIn,
  }) =>
      Input$DoubleFilterInput._({
        if (distinctFrom != null) r'distinctFrom': distinctFrom,
        if (distinctFromAll != null) r'distinctFromAll': distinctFromAll,
        if (distinctFromAny != null) r'distinctFromAny': distinctFromAny,
        if (equalTo != null) r'equalTo': equalTo,
        if (greaterThan != null) r'greaterThan': greaterThan,
        if (greaterThanOrEqualTo != null)
          r'greaterThanOrEqualTo': greaterThanOrEqualTo,
        if ($in != null) r'in': $in,
        if (isNull != null) r'isNull': isNull,
        if (lessThan != null) r'lessThan': lessThan,
        if (lessThanOrEqualTo != null) r'lessThanOrEqualTo': lessThanOrEqualTo,
        if (notDistinctFrom != null) r'notDistinctFrom': notDistinctFrom,
        if (notEqualTo != null) r'notEqualTo': notEqualTo,
        if (notEqualToAll != null) r'notEqualToAll': notEqualToAll,
        if (notEqualToAny != null) r'notEqualToAny': notEqualToAny,
        if (notIn != null) r'notIn': notIn,
      });

  Input$DoubleFilterInput._(this._$data);

  factory Input$DoubleFilterInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('distinctFrom')) {
      final l$distinctFrom = data['distinctFrom'];
      result$data['distinctFrom'] = (l$distinctFrom as num?)?.toDouble();
    }
    if (data.containsKey('distinctFromAll')) {
      final l$distinctFromAll = data['distinctFromAll'];
      result$data['distinctFromAll'] = (l$distinctFromAll as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList();
    }
    if (data.containsKey('distinctFromAny')) {
      final l$distinctFromAny = data['distinctFromAny'];
      result$data['distinctFromAny'] = (l$distinctFromAny as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList();
    }
    if (data.containsKey('equalTo')) {
      final l$equalTo = data['equalTo'];
      result$data['equalTo'] = (l$equalTo as num?)?.toDouble();
    }
    if (data.containsKey('greaterThan')) {
      final l$greaterThan = data['greaterThan'];
      result$data['greaterThan'] = (l$greaterThan as num?)?.toDouble();
    }
    if (data.containsKey('greaterThanOrEqualTo')) {
      final l$greaterThanOrEqualTo = data['greaterThanOrEqualTo'];
      result$data['greaterThanOrEqualTo'] =
          (l$greaterThanOrEqualTo as num?)?.toDouble();
    }
    if (data.containsKey('in')) {
      final l$$in = data['in'];
      result$data['in'] =
          (l$$in as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList();
    }
    if (data.containsKey('isNull')) {
      final l$isNull = data['isNull'];
      result$data['isNull'] = (l$isNull as bool?);
    }
    if (data.containsKey('lessThan')) {
      final l$lessThan = data['lessThan'];
      result$data['lessThan'] = (l$lessThan as num?)?.toDouble();
    }
    if (data.containsKey('lessThanOrEqualTo')) {
      final l$lessThanOrEqualTo = data['lessThanOrEqualTo'];
      result$data['lessThanOrEqualTo'] =
          (l$lessThanOrEqualTo as num?)?.toDouble();
    }
    if (data.containsKey('notDistinctFrom')) {
      final l$notDistinctFrom = data['notDistinctFrom'];
      result$data['notDistinctFrom'] = (l$notDistinctFrom as num?)?.toDouble();
    }
    if (data.containsKey('notEqualTo')) {
      final l$notEqualTo = data['notEqualTo'];
      result$data['notEqualTo'] = (l$notEqualTo as num?)?.toDouble();
    }
    if (data.containsKey('notEqualToAll')) {
      final l$notEqualToAll = data['notEqualToAll'];
      result$data['notEqualToAll'] = (l$notEqualToAll as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList();
    }
    if (data.containsKey('notEqualToAny')) {
      final l$notEqualToAny = data['notEqualToAny'];
      result$data['notEqualToAny'] = (l$notEqualToAny as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList();
    }
    if (data.containsKey('notIn')) {
      final l$notIn = data['notIn'];
      result$data['notIn'] = (l$notIn as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList();
    }
    return Input$DoubleFilterInput._(result$data);
  }

  Map<String, dynamic> _$data;

  double? get distinctFrom => (_$data['distinctFrom'] as double?);

  List<double>? get distinctFromAll =>
      (_$data['distinctFromAll'] as List<double>?);

  List<double>? get distinctFromAny =>
      (_$data['distinctFromAny'] as List<double>?);

  double? get equalTo => (_$data['equalTo'] as double?);

  double? get greaterThan => (_$data['greaterThan'] as double?);

  double? get greaterThanOrEqualTo =>
      (_$data['greaterThanOrEqualTo'] as double?);

  List<double>? get $in => (_$data['in'] as List<double>?);

  bool? get isNull => (_$data['isNull'] as bool?);

  double? get lessThan => (_$data['lessThan'] as double?);

  double? get lessThanOrEqualTo => (_$data['lessThanOrEqualTo'] as double?);

  double? get notDistinctFrom => (_$data['notDistinctFrom'] as double?);

  double? get notEqualTo => (_$data['notEqualTo'] as double?);

  List<double>? get notEqualToAll => (_$data['notEqualToAll'] as List<double>?);

  List<double>? get notEqualToAny => (_$data['notEqualToAny'] as List<double>?);

  List<double>? get notIn => (_$data['notIn'] as List<double>?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('distinctFrom')) {
      final l$distinctFrom = distinctFrom;
      result$data['distinctFrom'] = l$distinctFrom;
    }
    if (_$data.containsKey('distinctFromAll')) {
      final l$distinctFromAll = distinctFromAll;
      result$data['distinctFromAll'] =
          l$distinctFromAll?.map((e) => e).toList();
    }
    if (_$data.containsKey('distinctFromAny')) {
      final l$distinctFromAny = distinctFromAny;
      result$data['distinctFromAny'] =
          l$distinctFromAny?.map((e) => e).toList();
    }
    if (_$data.containsKey('equalTo')) {
      final l$equalTo = equalTo;
      result$data['equalTo'] = l$equalTo;
    }
    if (_$data.containsKey('greaterThan')) {
      final l$greaterThan = greaterThan;
      result$data['greaterThan'] = l$greaterThan;
    }
    if (_$data.containsKey('greaterThanOrEqualTo')) {
      final l$greaterThanOrEqualTo = greaterThanOrEqualTo;
      result$data['greaterThanOrEqualTo'] = l$greaterThanOrEqualTo;
    }
    if (_$data.containsKey('in')) {
      final l$$in = $in;
      result$data['in'] = l$$in?.map((e) => e).toList();
    }
    if (_$data.containsKey('isNull')) {
      final l$isNull = isNull;
      result$data['isNull'] = l$isNull;
    }
    if (_$data.containsKey('lessThan')) {
      final l$lessThan = lessThan;
      result$data['lessThan'] = l$lessThan;
    }
    if (_$data.containsKey('lessThanOrEqualTo')) {
      final l$lessThanOrEqualTo = lessThanOrEqualTo;
      result$data['lessThanOrEqualTo'] = l$lessThanOrEqualTo;
    }
    if (_$data.containsKey('notDistinctFrom')) {
      final l$notDistinctFrom = notDistinctFrom;
      result$data['notDistinctFrom'] = l$notDistinctFrom;
    }
    if (_$data.containsKey('notEqualTo')) {
      final l$notEqualTo = notEqualTo;
      result$data['notEqualTo'] = l$notEqualTo;
    }
    if (_$data.containsKey('notEqualToAll')) {
      final l$notEqualToAll = notEqualToAll;
      result$data['notEqualToAll'] = l$notEqualToAll?.map((e) => e).toList();
    }
    if (_$data.containsKey('notEqualToAny')) {
      final l$notEqualToAny = notEqualToAny;
      result$data['notEqualToAny'] = l$notEqualToAny?.map((e) => e).toList();
    }
    if (_$data.containsKey('notIn')) {
      final l$notIn = notIn;
      result$data['notIn'] = l$notIn?.map((e) => e).toList();
    }
    return result$data;
  }

  CopyWith$Input$DoubleFilterInput<Input$DoubleFilterInput> get copyWith =>
      CopyWith$Input$DoubleFilterInput(
        this,
        (i) => i,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$DoubleFilterInput || runtimeType != other.runtimeType) {
      return false;
    }
    final l$distinctFrom = distinctFrom;
    final lOther$distinctFrom = other.distinctFrom;
    if (_$data.containsKey('distinctFrom') !=
        other._$data.containsKey('distinctFrom')) {
      return false;
    }
    if (l$distinctFrom != lOther$distinctFrom) {
      return false;
    }
    final l$distinctFromAll = distinctFromAll;
    final lOther$distinctFromAll = other.distinctFromAll;
    if (_$data.containsKey('distinctFromAll') !=
        other._$data.containsKey('distinctFromAll')) {
      return false;
    }
    if (l$distinctFromAll != null && lOther$distinctFromAll != null) {
      if (l$distinctFromAll.length != lOther$distinctFromAll.length) {
        return false;
      }
      for (int i = 0; i < l$distinctFromAll.length; i++) {
        final l$distinctFromAll$entry = l$distinctFromAll[i];
        final lOther$distinctFromAll$entry = lOther$distinctFromAll[i];
        if (l$distinctFromAll$entry != lOther$distinctFromAll$entry) {
          return false;
        }
      }
    } else if (l$distinctFromAll != lOther$distinctFromAll) {
      return false;
    }
    final l$distinctFromAny = distinctFromAny;
    final lOther$distinctFromAny = other.distinctFromAny;
    if (_$data.containsKey('distinctFromAny') !=
        other._$data.containsKey('distinctFromAny')) {
      return false;
    }
    if (l$distinctFromAny != null && lOther$distinctFromAny != null) {
      if (l$distinctFromAny.length != lOther$distinctFromAny.length) {
        return false;
      }
      for (int i = 0; i < l$distinctFromAny.length; i++) {
        final l$distinctFromAny$entry = l$distinctFromAny[i];
        final lOther$distinctFromAny$entry = lOther$distinctFromAny[i];
        if (l$distinctFromAny$entry != lOther$distinctFromAny$entry) {
          return false;
        }
      }
    } else if (l$distinctFromAny != lOther$distinctFromAny) {
      return false;
    }
    final l$equalTo = equalTo;
    final lOther$equalTo = other.equalTo;
    if (_$data.containsKey('equalTo') != other._$data.containsKey('equalTo')) {
      return false;
    }
    if (l$equalTo != lOther$equalTo) {
      return false;
    }
    final l$greaterThan = greaterThan;
    final lOther$greaterThan = other.greaterThan;
    if (_$data.containsKey('greaterThan') !=
        other._$data.containsKey('greaterThan')) {
      return false;
    }
    if (l$greaterThan != lOther$greaterThan) {
      return false;
    }
    final l$greaterThanOrEqualTo = greaterThanOrEqualTo;
    final lOther$greaterThanOrEqualTo = other.greaterThanOrEqualTo;
    if (_$data.containsKey('greaterThanOrEqualTo') !=
        other._$data.containsKey('greaterThanOrEqualTo')) {
      return false;
    }
    if (l$greaterThanOrEqualTo != lOther$greaterThanOrEqualTo) {
      return false;
    }
    final l$$in = $in;
    final lOther$$in = other.$in;
    if (_$data.containsKey('in') != other._$data.containsKey('in')) {
      return false;
    }
    if (l$$in != null && lOther$$in != null) {
      if (l$$in.length != lOther$$in.length) {
        return false;
      }
      for (int i = 0; i < l$$in.length; i++) {
        final l$$in$entry = l$$in[i];
        final lOther$$in$entry = lOther$$in[i];
        if (l$$in$entry != lOther$$in$entry) {
          return false;
        }
      }
    } else if (l$$in != lOther$$in) {
      return false;
    }
    final l$isNull = isNull;
    final lOther$isNull = other.isNull;
    if (_$data.containsKey('isNull') != other._$data.containsKey('isNull')) {
      return false;
    }
    if (l$isNull != lOther$isNull) {
      return false;
    }
    final l$lessThan = lessThan;
    final lOther$lessThan = other.lessThan;
    if (_$data.containsKey('lessThan') !=
        other._$data.containsKey('lessThan')) {
      return false;
    }
    if (l$lessThan != lOther$lessThan) {
      return false;
    }
    final l$lessThanOrEqualTo = lessThanOrEqualTo;
    final lOther$lessThanOrEqualTo = other.lessThanOrEqualTo;
    if (_$data.containsKey('lessThanOrEqualTo') !=
        other._$data.containsKey('lessThanOrEqualTo')) {
      return false;
    }
    if (l$lessThanOrEqualTo != lOther$lessThanOrEqualTo) {
      return false;
    }
    final l$notDistinctFrom = notDistinctFrom;
    final lOther$notDistinctFrom = other.notDistinctFrom;
    if (_$data.containsKey('notDistinctFrom') !=
        other._$data.containsKey('notDistinctFrom')) {
      return false;
    }
    if (l$notDistinctFrom != lOther$notDistinctFrom) {
      return false;
    }
    final l$notEqualTo = notEqualTo;
    final lOther$notEqualTo = other.notEqualTo;
    if (_$data.containsKey('notEqualTo') !=
        other._$data.containsKey('notEqualTo')) {
      return false;
    }
    if (l$notEqualTo != lOther$notEqualTo) {
      return false;
    }
    final l$notEqualToAll = notEqualToAll;
    final lOther$notEqualToAll = other.notEqualToAll;
    if (_$data.containsKey('notEqualToAll') !=
        other._$data.containsKey('notEqualToAll')) {
      return false;
    }
    if (l$notEqualToAll != null && lOther$notEqualToAll != null) {
      if (l$notEqualToAll.length != lOther$notEqualToAll.length) {
        return false;
      }
      for (int i = 0; i < l$notEqualToAll.length; i++) {
        final l$notEqualToAll$entry = l$notEqualToAll[i];
        final lOther$notEqualToAll$entry = lOther$notEqualToAll[i];
        if (l$notEqualToAll$entry != lOther$notEqualToAll$entry) {
          return false;
        }
      }
    } else if (l$notEqualToAll != lOther$notEqualToAll) {
      return false;
    }
    final l$notEqualToAny = notEqualToAny;
    final lOther$notEqualToAny = other.notEqualToAny;
    if (_$data.containsKey('notEqualToAny') !=
        other._$data.containsKey('notEqualToAny')) {
      return false;
    }
    if (l$notEqualToAny != null && lOther$notEqualToAny != null) {
      if (l$notEqualToAny.length != lOther$notEqualToAny.length) {
        return false;
      }
      for (int i = 0; i < l$notEqualToAny.length; i++) {
        final l$notEqualToAny$entry = l$notEqualToAny[i];
        final lOther$notEqualToAny$entry = lOther$notEqualToAny[i];
        if (l$notEqualToAny$entry != lOther$notEqualToAny$entry) {
          return false;
        }
      }
    } else if (l$notEqualToAny != lOther$notEqualToAny) {
      return false;
    }
    final l$notIn = notIn;
    final lOther$notIn = other.notIn;
    if (_$data.containsKey('notIn') != other._$data.containsKey('notIn')) {
      return false;
    }
    if (l$notIn != null && lOther$notIn != null) {
      if (l$notIn.length != lOther$notIn.length) {
        return false;
      }
      for (int i = 0; i < l$notIn.length; i++) {
        final l$notIn$entry = l$notIn[i];
        final lOther$notIn$entry = lOther$notIn[i];
        if (l$notIn$entry != lOther$notIn$entry) {
          return false;
        }
      }
    } else if (l$notIn != lOther$notIn) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$distinctFrom = distinctFrom;
    final l$distinctFromAll = distinctFromAll;
    final l$distinctFromAny = distinctFromAny;
    final l$equalTo = equalTo;
    final l$greaterThan = greaterThan;
    final l$greaterThanOrEqualTo = greaterThanOrEqualTo;
    final l$$in = $in;
    final l$isNull = isNull;
    final l$lessThan = lessThan;
    final l$lessThanOrEqualTo = lessThanOrEqualTo;
    final l$notDistinctFrom = notDistinctFrom;
    final l$notEqualTo = notEqualTo;
    final l$notEqualToAll = notEqualToAll;
    final l$notEqualToAny = notEqualToAny;
    final l$notIn = notIn;
    return Object.hashAll([
      _$data.containsKey('distinctFrom') ? l$distinctFrom : const {},
      _$data.containsKey('distinctFromAll')
          ? l$distinctFromAll == null
              ? null
              : Object.hashAll(l$distinctFromAll.map((v) => v))
          : const {},
      _$data.containsKey('distinctFromAny')
          ? l$distinctFromAny == null
              ? null
              : Object.hashAll(l$distinctFromAny.map((v) => v))
          : const {},
      _$data.containsKey('equalTo') ? l$equalTo : const {},
      _$data.containsKey('greaterThan') ? l$greaterThan : const {},
      _$data.containsKey('greaterThanOrEqualTo')
          ? l$greaterThanOrEqualTo
          : const {},
      _$data.containsKey('in')
          ? l$$in == null
              ? null
              : Object.hashAll(l$$in.map((v) => v))
          : const {},
      _$data.containsKey('isNull') ? l$isNull : const {},
      _$data.containsKey('lessThan') ? l$lessThan : const {},
      _$data.containsKey('lessThanOrEqualTo') ? l$lessThanOrEqualTo : const {},
      _$data.containsKey('notDistinctFrom') ? l$notDistinctFrom : const {},
      _$data.containsKey('notEqualTo') ? l$notEqualTo : const {},
      _$data.containsKey('notEqualToAll')
          ? l$notEqualToAll == null
              ? null
              : Object.hashAll(l$notEqualToAll.map((v) => v))
          : const {},
      _$data.containsKey('notEqualToAny')
          ? l$notEqualToAny == null
              ? null
              : Object.hashAll(l$notEqualToAny.map((v) => v))
          : const {},
      _$data.containsKey('notIn')
          ? l$notIn == null
              ? null
              : Object.hashAll(l$notIn.map((v) => v))
          : const {},
    ]);
  }
}

abstract class CopyWith$Input$DoubleFilterInput<TRes> {
  factory CopyWith$Input$DoubleFilterInput(
    Input$DoubleFilterInput instance,
    TRes Function(Input$DoubleFilterInput) then,
  ) = _CopyWithImpl$Input$DoubleFilterInput;

  factory CopyWith$Input$DoubleFilterInput.stub(TRes res) =
      _CopyWithStubImpl$Input$DoubleFilterInput;

  TRes call({
    double? distinctFrom,
    List<double>? distinctFromAll,
    List<double>? distinctFromAny,
    double? equalTo,
    double? greaterThan,
    double? greaterThanOrEqualTo,
    List<double>? $in,
    bool? isNull,
    double? lessThan,
    double? lessThanOrEqualTo,
    double? notDistinctFrom,
    double? notEqualTo,
    List<double>? notEqualToAll,
    List<double>? notEqualToAny,
    List<double>? notIn,
  });
}

class _CopyWithImpl$Input$DoubleFilterInput<TRes>
    implements CopyWith$Input$DoubleFilterInput<TRes> {
  _CopyWithImpl$Input$DoubleFilterInput(
    this._instance,
    this._then,
  );

  final Input$DoubleFilterInput _instance;

  final TRes Function(Input$DoubleFilterInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? distinctFrom = _undefined,
    Object? distinctFromAll = _undefined,
    Object? distinctFromAny = _undefined,
    Object? equalTo = _undefined,
    Object? greaterThan = _undefined,
    Object? greaterThanOrEqualTo = _undefined,
    Object? $in = _undefined,
    Object? isNull = _undefined,
    Object? lessThan = _undefined,
    Object? lessThanOrEqualTo = _undefined,
    Object? notDistinctFrom = _undefined,
    Object? notEqualTo = _undefined,
    Object? notEqualToAll = _undefined,
    Object? notEqualToAny = _undefined,
    Object? notIn = _undefined,
  }) =>
      _then(Input$DoubleFilterInput._({
        ..._instance._$data,
        if (distinctFrom != _undefined)
          'distinctFrom': (distinctFrom as double?),
        if (distinctFromAll != _undefined)
          'distinctFromAll': (distinctFromAll as List<double>?),
        if (distinctFromAny != _undefined)
          'distinctFromAny': (distinctFromAny as List<double>?),
        if (equalTo != _undefined) 'equalTo': (equalTo as double?),
        if (greaterThan != _undefined) 'greaterThan': (greaterThan as double?),
        if (greaterThanOrEqualTo != _undefined)
          'greaterThanOrEqualTo': (greaterThanOrEqualTo as double?),
        if ($in != _undefined) 'in': ($in as List<double>?),
        if (isNull != _undefined) 'isNull': (isNull as bool?),
        if (lessThan != _undefined) 'lessThan': (lessThan as double?),
        if (lessThanOrEqualTo != _undefined)
          'lessThanOrEqualTo': (lessThanOrEqualTo as double?),
        if (notDistinctFrom != _undefined)
          'notDistinctFrom': (notDistinctFrom as double?),
        if (notEqualTo != _undefined) 'notEqualTo': (notEqualTo as double?),
        if (notEqualToAll != _undefined)
          'notEqualToAll': (notEqualToAll as List<double>?),
        if (notEqualToAny != _undefined)
          'notEqualToAny': (notEqualToAny as List<double>?),
        if (notIn != _undefined) 'notIn': (notIn as List<double>?),
      }));
}

class _CopyWithStubImpl$Input$DoubleFilterInput<TRes>
    implements CopyWith$Input$DoubleFilterInput<TRes> {
  _CopyWithStubImpl$Input$DoubleFilterInput(this._res);

  TRes _res;

  call({
    double? distinctFrom,
    List<double>? distinctFromAll,
    List<double>? distinctFromAny,
    double? equalTo,
    double? greaterThan,
    double? greaterThanOrEqualTo,
    List<double>? $in,
    bool? isNull,
    double? lessThan,
    double? lessThanOrEqualTo,
    double? notDistinctFrom,
    double? notEqualTo,
    List<double>? notEqualToAll,
    List<double>? notEqualToAny,
    List<double>? notIn,
  }) =>
      _res;
}

class Input$DownloadChangedInput {
  factory Input$DownloadChangedInput({int? maxUpdates}) =>
      Input$DownloadChangedInput._({
        if (maxUpdates != null) r'maxUpdates': maxUpdates,
      });

  Input$DownloadChangedInput._(this._$data);

  factory Input$DownloadChangedInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('maxUpdates')) {
      final l$maxUpdates = data['maxUpdates'];
      result$data['maxUpdates'] = (l$maxUpdates as int?);
    }
    return Input$DownloadChangedInput._(result$data);
  }

  Map<String, dynamic> _$data;

  int? get maxUpdates => (_$data['maxUpdates'] as int?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('maxUpdates')) {
      final l$maxUpdates = maxUpdates;
      result$data['maxUpdates'] = l$maxUpdates;
    }
    return result$data;
  }

  CopyWith$Input$DownloadChangedInput<Input$DownloadChangedInput>
      get copyWith => CopyWith$Input$DownloadChangedInput(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$DownloadChangedInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$maxUpdates = maxUpdates;
    final lOther$maxUpdates = other.maxUpdates;
    if (_$data.containsKey('maxUpdates') !=
        other._$data.containsKey('maxUpdates')) {
      return false;
    }
    if (l$maxUpdates != lOther$maxUpdates) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$maxUpdates = maxUpdates;
    return Object.hashAll(
        [_$data.containsKey('maxUpdates') ? l$maxUpdates : const {}]);
  }
}

abstract class CopyWith$Input$DownloadChangedInput<TRes> {
  factory CopyWith$Input$DownloadChangedInput(
    Input$DownloadChangedInput instance,
    TRes Function(Input$DownloadChangedInput) then,
  ) = _CopyWithImpl$Input$DownloadChangedInput;

  factory CopyWith$Input$DownloadChangedInput.stub(TRes res) =
      _CopyWithStubImpl$Input$DownloadChangedInput;

  TRes call({int? maxUpdates});
}

class _CopyWithImpl$Input$DownloadChangedInput<TRes>
    implements CopyWith$Input$DownloadChangedInput<TRes> {
  _CopyWithImpl$Input$DownloadChangedInput(
    this._instance,
    this._then,
  );

  final Input$DownloadChangedInput _instance;

  final TRes Function(Input$DownloadChangedInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? maxUpdates = _undefined}) =>
      _then(Input$DownloadChangedInput._({
        ..._instance._$data,
        if (maxUpdates != _undefined) 'maxUpdates': (maxUpdates as int?),
      }));
}

class _CopyWithStubImpl$Input$DownloadChangedInput<TRes>
    implements CopyWith$Input$DownloadChangedInput<TRes> {
  _CopyWithStubImpl$Input$DownloadChangedInput(this._res);

  TRes _res;

  call({int? maxUpdates}) => _res;
}

class Input$EnqueueChapterDownloadInput {
  factory Input$EnqueueChapterDownloadInput({
    String? clientMutationId,
    required int id,
  }) =>
      Input$EnqueueChapterDownloadInput._({
        if (clientMutationId != null) r'clientMutationId': clientMutationId,
        r'id': id,
      });

  Input$EnqueueChapterDownloadInput._(this._$data);

  factory Input$EnqueueChapterDownloadInput.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('clientMutationId')) {
      final l$clientMutationId = data['clientMutationId'];
      result$data['clientMutationId'] = (l$clientMutationId as String?);
    }
    final l$id = data['id'];
    result$data['id'] = (l$id as int);
    return Input$EnqueueChapterDownloadInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get clientMutationId => (_$data['clientMutationId'] as String?);

  int get id => (_$data['id'] as int);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('clientMutationId')) {
      final l$clientMutationId = clientMutationId;
      result$data['clientMutationId'] = l$clientMutationId;
    }
    final l$id = id;
    result$data['id'] = l$id;
    return result$data;
  }

  CopyWith$Input$EnqueueChapterDownloadInput<Input$EnqueueChapterDownloadInput>
      get copyWith => CopyWith$Input$EnqueueChapterDownloadInput(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$EnqueueChapterDownloadInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (_$data.containsKey('clientMutationId') !=
        other._$data.containsKey('clientMutationId')) {
      return false;
    }
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$clientMutationId = clientMutationId;
    final l$id = id;
    return Object.hashAll([
      _$data.containsKey('clientMutationId') ? l$clientMutationId : const {},
      l$id,
    ]);
  }
}

abstract class CopyWith$Input$EnqueueChapterDownloadInput<TRes> {
  factory CopyWith$Input$EnqueueChapterDownloadInput(
    Input$EnqueueChapterDownloadInput instance,
    TRes Function(Input$EnqueueChapterDownloadInput) then,
  ) = _CopyWithImpl$Input$EnqueueChapterDownloadInput;

  factory CopyWith$Input$EnqueueChapterDownloadInput.stub(TRes res) =
      _CopyWithStubImpl$Input$EnqueueChapterDownloadInput;

  TRes call({
    String? clientMutationId,
    int? id,
  });
}

class _CopyWithImpl$Input$EnqueueChapterDownloadInput<TRes>
    implements CopyWith$Input$EnqueueChapterDownloadInput<TRes> {
  _CopyWithImpl$Input$EnqueueChapterDownloadInput(
    this._instance,
    this._then,
  );

  final Input$EnqueueChapterDownloadInput _instance;

  final TRes Function(Input$EnqueueChapterDownloadInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? clientMutationId = _undefined,
    Object? id = _undefined,
  }) =>
      _then(Input$EnqueueChapterDownloadInput._({
        ..._instance._$data,
        if (clientMutationId != _undefined)
          'clientMutationId': (clientMutationId as String?),
        if (id != _undefined && id != null) 'id': (id as int),
      }));
}

class _CopyWithStubImpl$Input$EnqueueChapterDownloadInput<TRes>
    implements CopyWith$Input$EnqueueChapterDownloadInput<TRes> {
  _CopyWithStubImpl$Input$EnqueueChapterDownloadInput(this._res);

  TRes _res;

  call({
    String? clientMutationId,
    int? id,
  }) =>
      _res;
}

class Input$EnqueueChapterDownloadsInput {
  factory Input$EnqueueChapterDownloadsInput({
    String? clientMutationId,
    required List<int> ids,
  }) =>
      Input$EnqueueChapterDownloadsInput._({
        if (clientMutationId != null) r'clientMutationId': clientMutationId,
        r'ids': ids,
      });

  Input$EnqueueChapterDownloadsInput._(this._$data);

  factory Input$EnqueueChapterDownloadsInput.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('clientMutationId')) {
      final l$clientMutationId = data['clientMutationId'];
      result$data['clientMutationId'] = (l$clientMutationId as String?);
    }
    final l$ids = data['ids'];
    result$data['ids'] =
        (l$ids as List<dynamic>).map((e) => (e as int)).toList();
    return Input$EnqueueChapterDownloadsInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get clientMutationId => (_$data['clientMutationId'] as String?);

  List<int> get ids => (_$data['ids'] as List<int>);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('clientMutationId')) {
      final l$clientMutationId = clientMutationId;
      result$data['clientMutationId'] = l$clientMutationId;
    }
    final l$ids = ids;
    result$data['ids'] = l$ids.map((e) => e).toList();
    return result$data;
  }

  CopyWith$Input$EnqueueChapterDownloadsInput<
          Input$EnqueueChapterDownloadsInput>
      get copyWith => CopyWith$Input$EnqueueChapterDownloadsInput(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$EnqueueChapterDownloadsInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (_$data.containsKey('clientMutationId') !=
        other._$data.containsKey('clientMutationId')) {
      return false;
    }
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    final l$ids = ids;
    final lOther$ids = other.ids;
    if (l$ids.length != lOther$ids.length) {
      return false;
    }
    for (int i = 0; i < l$ids.length; i++) {
      final l$ids$entry = l$ids[i];
      final lOther$ids$entry = lOther$ids[i];
      if (l$ids$entry != lOther$ids$entry) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode {
    final l$clientMutationId = clientMutationId;
    final l$ids = ids;
    return Object.hashAll([
      _$data.containsKey('clientMutationId') ? l$clientMutationId : const {},
      Object.hashAll(l$ids.map((v) => v)),
    ]);
  }
}

abstract class CopyWith$Input$EnqueueChapterDownloadsInput<TRes> {
  factory CopyWith$Input$EnqueueChapterDownloadsInput(
    Input$EnqueueChapterDownloadsInput instance,
    TRes Function(Input$EnqueueChapterDownloadsInput) then,
  ) = _CopyWithImpl$Input$EnqueueChapterDownloadsInput;

  factory CopyWith$Input$EnqueueChapterDownloadsInput.stub(TRes res) =
      _CopyWithStubImpl$Input$EnqueueChapterDownloadsInput;

  TRes call({
    String? clientMutationId,
    List<int>? ids,
  });
}

class _CopyWithImpl$Input$EnqueueChapterDownloadsInput<TRes>
    implements CopyWith$Input$EnqueueChapterDownloadsInput<TRes> {
  _CopyWithImpl$Input$EnqueueChapterDownloadsInput(
    this._instance,
    this._then,
  );

  final Input$EnqueueChapterDownloadsInput _instance;

  final TRes Function(Input$EnqueueChapterDownloadsInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? clientMutationId = _undefined,
    Object? ids = _undefined,
  }) =>
      _then(Input$EnqueueChapterDownloadsInput._({
        ..._instance._$data,
        if (clientMutationId != _undefined)
          'clientMutationId': (clientMutationId as String?),
        if (ids != _undefined && ids != null) 'ids': (ids as List<int>),
      }));
}

class _CopyWithStubImpl$Input$EnqueueChapterDownloadsInput<TRes>
    implements CopyWith$Input$EnqueueChapterDownloadsInput<TRes> {
  _CopyWithStubImpl$Input$EnqueueChapterDownloadsInput(this._res);

  TRes _res;

  call({
    String? clientMutationId,
    List<int>? ids,
  }) =>
      _res;
}

class Input$ExtensionConditionInput {
  factory Input$ExtensionConditionInput({
    String? apkName,
    bool? hasUpdate,
    String? iconUrl,
    bool? isInstalled,
    bool? isNsfw,
    bool? isObsolete,
    String? lang,
    String? name,
    String? pkgName,
    String? repo,
    int? versionCode,
    String? versionName,
  }) =>
      Input$ExtensionConditionInput._({
        if (apkName != null) r'apkName': apkName,
        if (hasUpdate != null) r'hasUpdate': hasUpdate,
        if (iconUrl != null) r'iconUrl': iconUrl,
        if (isInstalled != null) r'isInstalled': isInstalled,
        if (isNsfw != null) r'isNsfw': isNsfw,
        if (isObsolete != null) r'isObsolete': isObsolete,
        if (lang != null) r'lang': lang,
        if (name != null) r'name': name,
        if (pkgName != null) r'pkgName': pkgName,
        if (repo != null) r'repo': repo,
        if (versionCode != null) r'versionCode': versionCode,
        if (versionName != null) r'versionName': versionName,
      });

  Input$ExtensionConditionInput._(this._$data);

  factory Input$ExtensionConditionInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('apkName')) {
      final l$apkName = data['apkName'];
      result$data['apkName'] = (l$apkName as String?);
    }
    if (data.containsKey('hasUpdate')) {
      final l$hasUpdate = data['hasUpdate'];
      result$data['hasUpdate'] = (l$hasUpdate as bool?);
    }
    if (data.containsKey('iconUrl')) {
      final l$iconUrl = data['iconUrl'];
      result$data['iconUrl'] = (l$iconUrl as String?);
    }
    if (data.containsKey('isInstalled')) {
      final l$isInstalled = data['isInstalled'];
      result$data['isInstalled'] = (l$isInstalled as bool?);
    }
    if (data.containsKey('isNsfw')) {
      final l$isNsfw = data['isNsfw'];
      result$data['isNsfw'] = (l$isNsfw as bool?);
    }
    if (data.containsKey('isObsolete')) {
      final l$isObsolete = data['isObsolete'];
      result$data['isObsolete'] = (l$isObsolete as bool?);
    }
    if (data.containsKey('lang')) {
      final l$lang = data['lang'];
      result$data['lang'] = (l$lang as String?);
    }
    if (data.containsKey('name')) {
      final l$name = data['name'];
      result$data['name'] = (l$name as String?);
    }
    if (data.containsKey('pkgName')) {
      final l$pkgName = data['pkgName'];
      result$data['pkgName'] = (l$pkgName as String?);
    }
    if (data.containsKey('repo')) {
      final l$repo = data['repo'];
      result$data['repo'] = (l$repo as String?);
    }
    if (data.containsKey('versionCode')) {
      final l$versionCode = data['versionCode'];
      result$data['versionCode'] = (l$versionCode as int?);
    }
    if (data.containsKey('versionName')) {
      final l$versionName = data['versionName'];
      result$data['versionName'] = (l$versionName as String?);
    }
    return Input$ExtensionConditionInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get apkName => (_$data['apkName'] as String?);

  bool? get hasUpdate => (_$data['hasUpdate'] as bool?);

  String? get iconUrl => (_$data['iconUrl'] as String?);

  bool? get isInstalled => (_$data['isInstalled'] as bool?);

  bool? get isNsfw => (_$data['isNsfw'] as bool?);

  bool? get isObsolete => (_$data['isObsolete'] as bool?);

  String? get lang => (_$data['lang'] as String?);

  String? get name => (_$data['name'] as String?);

  String? get pkgName => (_$data['pkgName'] as String?);

  String? get repo => (_$data['repo'] as String?);

  int? get versionCode => (_$data['versionCode'] as int?);

  String? get versionName => (_$data['versionName'] as String?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('apkName')) {
      final l$apkName = apkName;
      result$data['apkName'] = l$apkName;
    }
    if (_$data.containsKey('hasUpdate')) {
      final l$hasUpdate = hasUpdate;
      result$data['hasUpdate'] = l$hasUpdate;
    }
    if (_$data.containsKey('iconUrl')) {
      final l$iconUrl = iconUrl;
      result$data['iconUrl'] = l$iconUrl;
    }
    if (_$data.containsKey('isInstalled')) {
      final l$isInstalled = isInstalled;
      result$data['isInstalled'] = l$isInstalled;
    }
    if (_$data.containsKey('isNsfw')) {
      final l$isNsfw = isNsfw;
      result$data['isNsfw'] = l$isNsfw;
    }
    if (_$data.containsKey('isObsolete')) {
      final l$isObsolete = isObsolete;
      result$data['isObsolete'] = l$isObsolete;
    }
    if (_$data.containsKey('lang')) {
      final l$lang = lang;
      result$data['lang'] = l$lang;
    }
    if (_$data.containsKey('name')) {
      final l$name = name;
      result$data['name'] = l$name;
    }
    if (_$data.containsKey('pkgName')) {
      final l$pkgName = pkgName;
      result$data['pkgName'] = l$pkgName;
    }
    if (_$data.containsKey('repo')) {
      final l$repo = repo;
      result$data['repo'] = l$repo;
    }
    if (_$data.containsKey('versionCode')) {
      final l$versionCode = versionCode;
      result$data['versionCode'] = l$versionCode;
    }
    if (_$data.containsKey('versionName')) {
      final l$versionName = versionName;
      result$data['versionName'] = l$versionName;
    }
    return result$data;
  }

  CopyWith$Input$ExtensionConditionInput<Input$ExtensionConditionInput>
      get copyWith => CopyWith$Input$ExtensionConditionInput(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$ExtensionConditionInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$apkName = apkName;
    final lOther$apkName = other.apkName;
    if (_$data.containsKey('apkName') != other._$data.containsKey('apkName')) {
      return false;
    }
    if (l$apkName != lOther$apkName) {
      return false;
    }
    final l$hasUpdate = hasUpdate;
    final lOther$hasUpdate = other.hasUpdate;
    if (_$data.containsKey('hasUpdate') !=
        other._$data.containsKey('hasUpdate')) {
      return false;
    }
    if (l$hasUpdate != lOther$hasUpdate) {
      return false;
    }
    final l$iconUrl = iconUrl;
    final lOther$iconUrl = other.iconUrl;
    if (_$data.containsKey('iconUrl') != other._$data.containsKey('iconUrl')) {
      return false;
    }
    if (l$iconUrl != lOther$iconUrl) {
      return false;
    }
    final l$isInstalled = isInstalled;
    final lOther$isInstalled = other.isInstalled;
    if (_$data.containsKey('isInstalled') !=
        other._$data.containsKey('isInstalled')) {
      return false;
    }
    if (l$isInstalled != lOther$isInstalled) {
      return false;
    }
    final l$isNsfw = isNsfw;
    final lOther$isNsfw = other.isNsfw;
    if (_$data.containsKey('isNsfw') != other._$data.containsKey('isNsfw')) {
      return false;
    }
    if (l$isNsfw != lOther$isNsfw) {
      return false;
    }
    final l$isObsolete = isObsolete;
    final lOther$isObsolete = other.isObsolete;
    if (_$data.containsKey('isObsolete') !=
        other._$data.containsKey('isObsolete')) {
      return false;
    }
    if (l$isObsolete != lOther$isObsolete) {
      return false;
    }
    final l$lang = lang;
    final lOther$lang = other.lang;
    if (_$data.containsKey('lang') != other._$data.containsKey('lang')) {
      return false;
    }
    if (l$lang != lOther$lang) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (_$data.containsKey('name') != other._$data.containsKey('name')) {
      return false;
    }
    if (l$name != lOther$name) {
      return false;
    }
    final l$pkgName = pkgName;
    final lOther$pkgName = other.pkgName;
    if (_$data.containsKey('pkgName') != other._$data.containsKey('pkgName')) {
      return false;
    }
    if (l$pkgName != lOther$pkgName) {
      return false;
    }
    final l$repo = repo;
    final lOther$repo = other.repo;
    if (_$data.containsKey('repo') != other._$data.containsKey('repo')) {
      return false;
    }
    if (l$repo != lOther$repo) {
      return false;
    }
    final l$versionCode = versionCode;
    final lOther$versionCode = other.versionCode;
    if (_$data.containsKey('versionCode') !=
        other._$data.containsKey('versionCode')) {
      return false;
    }
    if (l$versionCode != lOther$versionCode) {
      return false;
    }
    final l$versionName = versionName;
    final lOther$versionName = other.versionName;
    if (_$data.containsKey('versionName') !=
        other._$data.containsKey('versionName')) {
      return false;
    }
    if (l$versionName != lOther$versionName) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$apkName = apkName;
    final l$hasUpdate = hasUpdate;
    final l$iconUrl = iconUrl;
    final l$isInstalled = isInstalled;
    final l$isNsfw = isNsfw;
    final l$isObsolete = isObsolete;
    final l$lang = lang;
    final l$name = name;
    final l$pkgName = pkgName;
    final l$repo = repo;
    final l$versionCode = versionCode;
    final l$versionName = versionName;
    return Object.hashAll([
      _$data.containsKey('apkName') ? l$apkName : const {},
      _$data.containsKey('hasUpdate') ? l$hasUpdate : const {},
      _$data.containsKey('iconUrl') ? l$iconUrl : const {},
      _$data.containsKey('isInstalled') ? l$isInstalled : const {},
      _$data.containsKey('isNsfw') ? l$isNsfw : const {},
      _$data.containsKey('isObsolete') ? l$isObsolete : const {},
      _$data.containsKey('lang') ? l$lang : const {},
      _$data.containsKey('name') ? l$name : const {},
      _$data.containsKey('pkgName') ? l$pkgName : const {},
      _$data.containsKey('repo') ? l$repo : const {},
      _$data.containsKey('versionCode') ? l$versionCode : const {},
      _$data.containsKey('versionName') ? l$versionName : const {},
    ]);
  }
}

abstract class CopyWith$Input$ExtensionConditionInput<TRes> {
  factory CopyWith$Input$ExtensionConditionInput(
    Input$ExtensionConditionInput instance,
    TRes Function(Input$ExtensionConditionInput) then,
  ) = _CopyWithImpl$Input$ExtensionConditionInput;

  factory CopyWith$Input$ExtensionConditionInput.stub(TRes res) =
      _CopyWithStubImpl$Input$ExtensionConditionInput;

  TRes call({
    String? apkName,
    bool? hasUpdate,
    String? iconUrl,
    bool? isInstalled,
    bool? isNsfw,
    bool? isObsolete,
    String? lang,
    String? name,
    String? pkgName,
    String? repo,
    int? versionCode,
    String? versionName,
  });
}

class _CopyWithImpl$Input$ExtensionConditionInput<TRes>
    implements CopyWith$Input$ExtensionConditionInput<TRes> {
  _CopyWithImpl$Input$ExtensionConditionInput(
    this._instance,
    this._then,
  );

  final Input$ExtensionConditionInput _instance;

  final TRes Function(Input$ExtensionConditionInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? apkName = _undefined,
    Object? hasUpdate = _undefined,
    Object? iconUrl = _undefined,
    Object? isInstalled = _undefined,
    Object? isNsfw = _undefined,
    Object? isObsolete = _undefined,
    Object? lang = _undefined,
    Object? name = _undefined,
    Object? pkgName = _undefined,
    Object? repo = _undefined,
    Object? versionCode = _undefined,
    Object? versionName = _undefined,
  }) =>
      _then(Input$ExtensionConditionInput._({
        ..._instance._$data,
        if (apkName != _undefined) 'apkName': (apkName as String?),
        if (hasUpdate != _undefined) 'hasUpdate': (hasUpdate as bool?),
        if (iconUrl != _undefined) 'iconUrl': (iconUrl as String?),
        if (isInstalled != _undefined) 'isInstalled': (isInstalled as bool?),
        if (isNsfw != _undefined) 'isNsfw': (isNsfw as bool?),
        if (isObsolete != _undefined) 'isObsolete': (isObsolete as bool?),
        if (lang != _undefined) 'lang': (lang as String?),
        if (name != _undefined) 'name': (name as String?),
        if (pkgName != _undefined) 'pkgName': (pkgName as String?),
        if (repo != _undefined) 'repo': (repo as String?),
        if (versionCode != _undefined) 'versionCode': (versionCode as int?),
        if (versionName != _undefined) 'versionName': (versionName as String?),
      }));
}

class _CopyWithStubImpl$Input$ExtensionConditionInput<TRes>
    implements CopyWith$Input$ExtensionConditionInput<TRes> {
  _CopyWithStubImpl$Input$ExtensionConditionInput(this._res);

  TRes _res;

  call({
    String? apkName,
    bool? hasUpdate,
    String? iconUrl,
    bool? isInstalled,
    bool? isNsfw,
    bool? isObsolete,
    String? lang,
    String? name,
    String? pkgName,
    String? repo,
    int? versionCode,
    String? versionName,
  }) =>
      _res;
}

class Input$ExtensionFilterInput {
  factory Input$ExtensionFilterInput({
    List<Input$ExtensionFilterInput>? and,
    Input$StringFilterInput? apkName,
    Input$BooleanFilterInput? hasUpdate,
    Input$StringFilterInput? iconUrl,
    Input$BooleanFilterInput? isInstalled,
    Input$BooleanFilterInput? isNsfw,
    Input$BooleanFilterInput? isObsolete,
    Input$StringFilterInput? lang,
    Input$StringFilterInput? name,
    Input$ExtensionFilterInput? not,
    List<Input$ExtensionFilterInput>? or,
    Input$StringFilterInput? pkgName,
    Input$StringFilterInput? repo,
    Input$IntFilterInput? versionCode,
    Input$StringFilterInput? versionName,
  }) =>
      Input$ExtensionFilterInput._({
        if (and != null) r'and': and,
        if (apkName != null) r'apkName': apkName,
        if (hasUpdate != null) r'hasUpdate': hasUpdate,
        if (iconUrl != null) r'iconUrl': iconUrl,
        if (isInstalled != null) r'isInstalled': isInstalled,
        if (isNsfw != null) r'isNsfw': isNsfw,
        if (isObsolete != null) r'isObsolete': isObsolete,
        if (lang != null) r'lang': lang,
        if (name != null) r'name': name,
        if (not != null) r'not': not,
        if (or != null) r'or': or,
        if (pkgName != null) r'pkgName': pkgName,
        if (repo != null) r'repo': repo,
        if (versionCode != null) r'versionCode': versionCode,
        if (versionName != null) r'versionName': versionName,
      });

  Input$ExtensionFilterInput._(this._$data);

  factory Input$ExtensionFilterInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('and')) {
      final l$and = data['and'];
      result$data['and'] = (l$and as List<dynamic>?)
          ?.map((e) =>
              Input$ExtensionFilterInput.fromJson((e as Map<String, dynamic>)))
          .toList();
    }
    if (data.containsKey('apkName')) {
      final l$apkName = data['apkName'];
      result$data['apkName'] = l$apkName == null
          ? null
          : Input$StringFilterInput.fromJson(
              (l$apkName as Map<String, dynamic>));
    }
    if (data.containsKey('hasUpdate')) {
      final l$hasUpdate = data['hasUpdate'];
      result$data['hasUpdate'] = l$hasUpdate == null
          ? null
          : Input$BooleanFilterInput.fromJson(
              (l$hasUpdate as Map<String, dynamic>));
    }
    if (data.containsKey('iconUrl')) {
      final l$iconUrl = data['iconUrl'];
      result$data['iconUrl'] = l$iconUrl == null
          ? null
          : Input$StringFilterInput.fromJson(
              (l$iconUrl as Map<String, dynamic>));
    }
    if (data.containsKey('isInstalled')) {
      final l$isInstalled = data['isInstalled'];
      result$data['isInstalled'] = l$isInstalled == null
          ? null
          : Input$BooleanFilterInput.fromJson(
              (l$isInstalled as Map<String, dynamic>));
    }
    if (data.containsKey('isNsfw')) {
      final l$isNsfw = data['isNsfw'];
      result$data['isNsfw'] = l$isNsfw == null
          ? null
          : Input$BooleanFilterInput.fromJson(
              (l$isNsfw as Map<String, dynamic>));
    }
    if (data.containsKey('isObsolete')) {
      final l$isObsolete = data['isObsolete'];
      result$data['isObsolete'] = l$isObsolete == null
          ? null
          : Input$BooleanFilterInput.fromJson(
              (l$isObsolete as Map<String, dynamic>));
    }
    if (data.containsKey('lang')) {
      final l$lang = data['lang'];
      result$data['lang'] = l$lang == null
          ? null
          : Input$StringFilterInput.fromJson((l$lang as Map<String, dynamic>));
    }
    if (data.containsKey('name')) {
      final l$name = data['name'];
      result$data['name'] = l$name == null
          ? null
          : Input$StringFilterInput.fromJson((l$name as Map<String, dynamic>));
    }
    if (data.containsKey('not')) {
      final l$not = data['not'];
      result$data['not'] = l$not == null
          ? null
          : Input$ExtensionFilterInput.fromJson(
              (l$not as Map<String, dynamic>));
    }
    if (data.containsKey('or')) {
      final l$or = data['or'];
      result$data['or'] = (l$or as List<dynamic>?)
          ?.map((e) =>
              Input$ExtensionFilterInput.fromJson((e as Map<String, dynamic>)))
          .toList();
    }
    if (data.containsKey('pkgName')) {
      final l$pkgName = data['pkgName'];
      result$data['pkgName'] = l$pkgName == null
          ? null
          : Input$StringFilterInput.fromJson(
              (l$pkgName as Map<String, dynamic>));
    }
    if (data.containsKey('repo')) {
      final l$repo = data['repo'];
      result$data['repo'] = l$repo == null
          ? null
          : Input$StringFilterInput.fromJson((l$repo as Map<String, dynamic>));
    }
    if (data.containsKey('versionCode')) {
      final l$versionCode = data['versionCode'];
      result$data['versionCode'] = l$versionCode == null
          ? null
          : Input$IntFilterInput.fromJson(
              (l$versionCode as Map<String, dynamic>));
    }
    if (data.containsKey('versionName')) {
      final l$versionName = data['versionName'];
      result$data['versionName'] = l$versionName == null
          ? null
          : Input$StringFilterInput.fromJson(
              (l$versionName as Map<String, dynamic>));
    }
    return Input$ExtensionFilterInput._(result$data);
  }

  Map<String, dynamic> _$data;

  List<Input$ExtensionFilterInput>? get and =>
      (_$data['and'] as List<Input$ExtensionFilterInput>?);

  Input$StringFilterInput? get apkName =>
      (_$data['apkName'] as Input$StringFilterInput?);

  Input$BooleanFilterInput? get hasUpdate =>
      (_$data['hasUpdate'] as Input$BooleanFilterInput?);

  Input$StringFilterInput? get iconUrl =>
      (_$data['iconUrl'] as Input$StringFilterInput?);

  Input$BooleanFilterInput? get isInstalled =>
      (_$data['isInstalled'] as Input$BooleanFilterInput?);

  Input$BooleanFilterInput? get isNsfw =>
      (_$data['isNsfw'] as Input$BooleanFilterInput?);

  Input$BooleanFilterInput? get isObsolete =>
      (_$data['isObsolete'] as Input$BooleanFilterInput?);

  Input$StringFilterInput? get lang =>
      (_$data['lang'] as Input$StringFilterInput?);

  Input$StringFilterInput? get name =>
      (_$data['name'] as Input$StringFilterInput?);

  Input$ExtensionFilterInput? get not =>
      (_$data['not'] as Input$ExtensionFilterInput?);

  List<Input$ExtensionFilterInput>? get or =>
      (_$data['or'] as List<Input$ExtensionFilterInput>?);

  Input$StringFilterInput? get pkgName =>
      (_$data['pkgName'] as Input$StringFilterInput?);

  Input$StringFilterInput? get repo =>
      (_$data['repo'] as Input$StringFilterInput?);

  Input$IntFilterInput? get versionCode =>
      (_$data['versionCode'] as Input$IntFilterInput?);

  Input$StringFilterInput? get versionName =>
      (_$data['versionName'] as Input$StringFilterInput?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('and')) {
      final l$and = and;
      result$data['and'] = l$and?.map((e) => e.toJson()).toList();
    }
    if (_$data.containsKey('apkName')) {
      final l$apkName = apkName;
      result$data['apkName'] = l$apkName?.toJson();
    }
    if (_$data.containsKey('hasUpdate')) {
      final l$hasUpdate = hasUpdate;
      result$data['hasUpdate'] = l$hasUpdate?.toJson();
    }
    if (_$data.containsKey('iconUrl')) {
      final l$iconUrl = iconUrl;
      result$data['iconUrl'] = l$iconUrl?.toJson();
    }
    if (_$data.containsKey('isInstalled')) {
      final l$isInstalled = isInstalled;
      result$data['isInstalled'] = l$isInstalled?.toJson();
    }
    if (_$data.containsKey('isNsfw')) {
      final l$isNsfw = isNsfw;
      result$data['isNsfw'] = l$isNsfw?.toJson();
    }
    if (_$data.containsKey('isObsolete')) {
      final l$isObsolete = isObsolete;
      result$data['isObsolete'] = l$isObsolete?.toJson();
    }
    if (_$data.containsKey('lang')) {
      final l$lang = lang;
      result$data['lang'] = l$lang?.toJson();
    }
    if (_$data.containsKey('name')) {
      final l$name = name;
      result$data['name'] = l$name?.toJson();
    }
    if (_$data.containsKey('not')) {
      final l$not = not;
      result$data['not'] = l$not?.toJson();
    }
    if (_$data.containsKey('or')) {
      final l$or = or;
      result$data['or'] = l$or?.map((e) => e.toJson()).toList();
    }
    if (_$data.containsKey('pkgName')) {
      final l$pkgName = pkgName;
      result$data['pkgName'] = l$pkgName?.toJson();
    }
    if (_$data.containsKey('repo')) {
      final l$repo = repo;
      result$data['repo'] = l$repo?.toJson();
    }
    if (_$data.containsKey('versionCode')) {
      final l$versionCode = versionCode;
      result$data['versionCode'] = l$versionCode?.toJson();
    }
    if (_$data.containsKey('versionName')) {
      final l$versionName = versionName;
      result$data['versionName'] = l$versionName?.toJson();
    }
    return result$data;
  }

  CopyWith$Input$ExtensionFilterInput<Input$ExtensionFilterInput>
      get copyWith => CopyWith$Input$ExtensionFilterInput(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$ExtensionFilterInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$and = and;
    final lOther$and = other.and;
    if (_$data.containsKey('and') != other._$data.containsKey('and')) {
      return false;
    }
    if (l$and != null && lOther$and != null) {
      if (l$and.length != lOther$and.length) {
        return false;
      }
      for (int i = 0; i < l$and.length; i++) {
        final l$and$entry = l$and[i];
        final lOther$and$entry = lOther$and[i];
        if (l$and$entry != lOther$and$entry) {
          return false;
        }
      }
    } else if (l$and != lOther$and) {
      return false;
    }
    final l$apkName = apkName;
    final lOther$apkName = other.apkName;
    if (_$data.containsKey('apkName') != other._$data.containsKey('apkName')) {
      return false;
    }
    if (l$apkName != lOther$apkName) {
      return false;
    }
    final l$hasUpdate = hasUpdate;
    final lOther$hasUpdate = other.hasUpdate;
    if (_$data.containsKey('hasUpdate') !=
        other._$data.containsKey('hasUpdate')) {
      return false;
    }
    if (l$hasUpdate != lOther$hasUpdate) {
      return false;
    }
    final l$iconUrl = iconUrl;
    final lOther$iconUrl = other.iconUrl;
    if (_$data.containsKey('iconUrl') != other._$data.containsKey('iconUrl')) {
      return false;
    }
    if (l$iconUrl != lOther$iconUrl) {
      return false;
    }
    final l$isInstalled = isInstalled;
    final lOther$isInstalled = other.isInstalled;
    if (_$data.containsKey('isInstalled') !=
        other._$data.containsKey('isInstalled')) {
      return false;
    }
    if (l$isInstalled != lOther$isInstalled) {
      return false;
    }
    final l$isNsfw = isNsfw;
    final lOther$isNsfw = other.isNsfw;
    if (_$data.containsKey('isNsfw') != other._$data.containsKey('isNsfw')) {
      return false;
    }
    if (l$isNsfw != lOther$isNsfw) {
      return false;
    }
    final l$isObsolete = isObsolete;
    final lOther$isObsolete = other.isObsolete;
    if (_$data.containsKey('isObsolete') !=
        other._$data.containsKey('isObsolete')) {
      return false;
    }
    if (l$isObsolete != lOther$isObsolete) {
      return false;
    }
    final l$lang = lang;
    final lOther$lang = other.lang;
    if (_$data.containsKey('lang') != other._$data.containsKey('lang')) {
      return false;
    }
    if (l$lang != lOther$lang) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (_$data.containsKey('name') != other._$data.containsKey('name')) {
      return false;
    }
    if (l$name != lOther$name) {
      return false;
    }
    final l$not = not;
    final lOther$not = other.not;
    if (_$data.containsKey('not') != other._$data.containsKey('not')) {
      return false;
    }
    if (l$not != lOther$not) {
      return false;
    }
    final l$or = or;
    final lOther$or = other.or;
    if (_$data.containsKey('or') != other._$data.containsKey('or')) {
      return false;
    }
    if (l$or != null && lOther$or != null) {
      if (l$or.length != lOther$or.length) {
        return false;
      }
      for (int i = 0; i < l$or.length; i++) {
        final l$or$entry = l$or[i];
        final lOther$or$entry = lOther$or[i];
        if (l$or$entry != lOther$or$entry) {
          return false;
        }
      }
    } else if (l$or != lOther$or) {
      return false;
    }
    final l$pkgName = pkgName;
    final lOther$pkgName = other.pkgName;
    if (_$data.containsKey('pkgName') != other._$data.containsKey('pkgName')) {
      return false;
    }
    if (l$pkgName != lOther$pkgName) {
      return false;
    }
    final l$repo = repo;
    final lOther$repo = other.repo;
    if (_$data.containsKey('repo') != other._$data.containsKey('repo')) {
      return false;
    }
    if (l$repo != lOther$repo) {
      return false;
    }
    final l$versionCode = versionCode;
    final lOther$versionCode = other.versionCode;
    if (_$data.containsKey('versionCode') !=
        other._$data.containsKey('versionCode')) {
      return false;
    }
    if (l$versionCode != lOther$versionCode) {
      return false;
    }
    final l$versionName = versionName;
    final lOther$versionName = other.versionName;
    if (_$data.containsKey('versionName') !=
        other._$data.containsKey('versionName')) {
      return false;
    }
    if (l$versionName != lOther$versionName) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$and = and;
    final l$apkName = apkName;
    final l$hasUpdate = hasUpdate;
    final l$iconUrl = iconUrl;
    final l$isInstalled = isInstalled;
    final l$isNsfw = isNsfw;
    final l$isObsolete = isObsolete;
    final l$lang = lang;
    final l$name = name;
    final l$not = not;
    final l$or = or;
    final l$pkgName = pkgName;
    final l$repo = repo;
    final l$versionCode = versionCode;
    final l$versionName = versionName;
    return Object.hashAll([
      _$data.containsKey('and')
          ? l$and == null
              ? null
              : Object.hashAll(l$and.map((v) => v))
          : const {},
      _$data.containsKey('apkName') ? l$apkName : const {},
      _$data.containsKey('hasUpdate') ? l$hasUpdate : const {},
      _$data.containsKey('iconUrl') ? l$iconUrl : const {},
      _$data.containsKey('isInstalled') ? l$isInstalled : const {},
      _$data.containsKey('isNsfw') ? l$isNsfw : const {},
      _$data.containsKey('isObsolete') ? l$isObsolete : const {},
      _$data.containsKey('lang') ? l$lang : const {},
      _$data.containsKey('name') ? l$name : const {},
      _$data.containsKey('not') ? l$not : const {},
      _$data.containsKey('or')
          ? l$or == null
              ? null
              : Object.hashAll(l$or.map((v) => v))
          : const {},
      _$data.containsKey('pkgName') ? l$pkgName : const {},
      _$data.containsKey('repo') ? l$repo : const {},
      _$data.containsKey('versionCode') ? l$versionCode : const {},
      _$data.containsKey('versionName') ? l$versionName : const {},
    ]);
  }
}

abstract class CopyWith$Input$ExtensionFilterInput<TRes> {
  factory CopyWith$Input$ExtensionFilterInput(
    Input$ExtensionFilterInput instance,
    TRes Function(Input$ExtensionFilterInput) then,
  ) = _CopyWithImpl$Input$ExtensionFilterInput;

  factory CopyWith$Input$ExtensionFilterInput.stub(TRes res) =
      _CopyWithStubImpl$Input$ExtensionFilterInput;

  TRes call({
    List<Input$ExtensionFilterInput>? and,
    Input$StringFilterInput? apkName,
    Input$BooleanFilterInput? hasUpdate,
    Input$StringFilterInput? iconUrl,
    Input$BooleanFilterInput? isInstalled,
    Input$BooleanFilterInput? isNsfw,
    Input$BooleanFilterInput? isObsolete,
    Input$StringFilterInput? lang,
    Input$StringFilterInput? name,
    Input$ExtensionFilterInput? not,
    List<Input$ExtensionFilterInput>? or,
    Input$StringFilterInput? pkgName,
    Input$StringFilterInput? repo,
    Input$IntFilterInput? versionCode,
    Input$StringFilterInput? versionName,
  });
  TRes and(
      Iterable<Input$ExtensionFilterInput>? Function(
              Iterable<
                  CopyWith$Input$ExtensionFilterInput<
                      Input$ExtensionFilterInput>>?)
          _fn);
  CopyWith$Input$StringFilterInput<TRes> get apkName;
  CopyWith$Input$BooleanFilterInput<TRes> get hasUpdate;
  CopyWith$Input$StringFilterInput<TRes> get iconUrl;
  CopyWith$Input$BooleanFilterInput<TRes> get isInstalled;
  CopyWith$Input$BooleanFilterInput<TRes> get isNsfw;
  CopyWith$Input$BooleanFilterInput<TRes> get isObsolete;
  CopyWith$Input$StringFilterInput<TRes> get lang;
  CopyWith$Input$StringFilterInput<TRes> get name;
  CopyWith$Input$ExtensionFilterInput<TRes> get not;
  TRes or(
      Iterable<Input$ExtensionFilterInput>? Function(
              Iterable<
                  CopyWith$Input$ExtensionFilterInput<
                      Input$ExtensionFilterInput>>?)
          _fn);
  CopyWith$Input$StringFilterInput<TRes> get pkgName;
  CopyWith$Input$StringFilterInput<TRes> get repo;
  CopyWith$Input$IntFilterInput<TRes> get versionCode;
  CopyWith$Input$StringFilterInput<TRes> get versionName;
}

class _CopyWithImpl$Input$ExtensionFilterInput<TRes>
    implements CopyWith$Input$ExtensionFilterInput<TRes> {
  _CopyWithImpl$Input$ExtensionFilterInput(
    this._instance,
    this._then,
  );

  final Input$ExtensionFilterInput _instance;

  final TRes Function(Input$ExtensionFilterInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? and = _undefined,
    Object? apkName = _undefined,
    Object? hasUpdate = _undefined,
    Object? iconUrl = _undefined,
    Object? isInstalled = _undefined,
    Object? isNsfw = _undefined,
    Object? isObsolete = _undefined,
    Object? lang = _undefined,
    Object? name = _undefined,
    Object? not = _undefined,
    Object? or = _undefined,
    Object? pkgName = _undefined,
    Object? repo = _undefined,
    Object? versionCode = _undefined,
    Object? versionName = _undefined,
  }) =>
      _then(Input$ExtensionFilterInput._({
        ..._instance._$data,
        if (and != _undefined)
          'and': (and as List<Input$ExtensionFilterInput>?),
        if (apkName != _undefined)
          'apkName': (apkName as Input$StringFilterInput?),
        if (hasUpdate != _undefined)
          'hasUpdate': (hasUpdate as Input$BooleanFilterInput?),
        if (iconUrl != _undefined)
          'iconUrl': (iconUrl as Input$StringFilterInput?),
        if (isInstalled != _undefined)
          'isInstalled': (isInstalled as Input$BooleanFilterInput?),
        if (isNsfw != _undefined)
          'isNsfw': (isNsfw as Input$BooleanFilterInput?),
        if (isObsolete != _undefined)
          'isObsolete': (isObsolete as Input$BooleanFilterInput?),
        if (lang != _undefined) 'lang': (lang as Input$StringFilterInput?),
        if (name != _undefined) 'name': (name as Input$StringFilterInput?),
        if (not != _undefined) 'not': (not as Input$ExtensionFilterInput?),
        if (or != _undefined) 'or': (or as List<Input$ExtensionFilterInput>?),
        if (pkgName != _undefined)
          'pkgName': (pkgName as Input$StringFilterInput?),
        if (repo != _undefined) 'repo': (repo as Input$StringFilterInput?),
        if (versionCode != _undefined)
          'versionCode': (versionCode as Input$IntFilterInput?),
        if (versionName != _undefined)
          'versionName': (versionName as Input$StringFilterInput?),
      }));

  TRes and(
          Iterable<Input$ExtensionFilterInput>? Function(
                  Iterable<
                      CopyWith$Input$ExtensionFilterInput<
                          Input$ExtensionFilterInput>>?)
              _fn) =>
      call(
          and:
              _fn(_instance.and?.map((e) => CopyWith$Input$ExtensionFilterInput(
                    e,
                    (i) => i,
                  )))?.toList());

  CopyWith$Input$StringFilterInput<TRes> get apkName {
    final local$apkName = _instance.apkName;
    return local$apkName == null
        ? CopyWith$Input$StringFilterInput.stub(_then(_instance))
        : CopyWith$Input$StringFilterInput(
            local$apkName, (e) => call(apkName: e));
  }

  CopyWith$Input$BooleanFilterInput<TRes> get hasUpdate {
    final local$hasUpdate = _instance.hasUpdate;
    return local$hasUpdate == null
        ? CopyWith$Input$BooleanFilterInput.stub(_then(_instance))
        : CopyWith$Input$BooleanFilterInput(
            local$hasUpdate, (e) => call(hasUpdate: e));
  }

  CopyWith$Input$StringFilterInput<TRes> get iconUrl {
    final local$iconUrl = _instance.iconUrl;
    return local$iconUrl == null
        ? CopyWith$Input$StringFilterInput.stub(_then(_instance))
        : CopyWith$Input$StringFilterInput(
            local$iconUrl, (e) => call(iconUrl: e));
  }

  CopyWith$Input$BooleanFilterInput<TRes> get isInstalled {
    final local$isInstalled = _instance.isInstalled;
    return local$isInstalled == null
        ? CopyWith$Input$BooleanFilterInput.stub(_then(_instance))
        : CopyWith$Input$BooleanFilterInput(
            local$isInstalled, (e) => call(isInstalled: e));
  }

  CopyWith$Input$BooleanFilterInput<TRes> get isNsfw {
    final local$isNsfw = _instance.isNsfw;
    return local$isNsfw == null
        ? CopyWith$Input$BooleanFilterInput.stub(_then(_instance))
        : CopyWith$Input$BooleanFilterInput(
            local$isNsfw, (e) => call(isNsfw: e));
  }

  CopyWith$Input$BooleanFilterInput<TRes> get isObsolete {
    final local$isObsolete = _instance.isObsolete;
    return local$isObsolete == null
        ? CopyWith$Input$BooleanFilterInput.stub(_then(_instance))
        : CopyWith$Input$BooleanFilterInput(
            local$isObsolete, (e) => call(isObsolete: e));
  }

  CopyWith$Input$StringFilterInput<TRes> get lang {
    final local$lang = _instance.lang;
    return local$lang == null
        ? CopyWith$Input$StringFilterInput.stub(_then(_instance))
        : CopyWith$Input$StringFilterInput(local$lang, (e) => call(lang: e));
  }

  CopyWith$Input$StringFilterInput<TRes> get name {
    final local$name = _instance.name;
    return local$name == null
        ? CopyWith$Input$StringFilterInput.stub(_then(_instance))
        : CopyWith$Input$StringFilterInput(local$name, (e) => call(name: e));
  }

  CopyWith$Input$ExtensionFilterInput<TRes> get not {
    final local$not = _instance.not;
    return local$not == null
        ? CopyWith$Input$ExtensionFilterInput.stub(_then(_instance))
        : CopyWith$Input$ExtensionFilterInput(local$not, (e) => call(not: e));
  }

  TRes or(
          Iterable<Input$ExtensionFilterInput>? Function(
                  Iterable<
                      CopyWith$Input$ExtensionFilterInput<
                          Input$ExtensionFilterInput>>?)
              _fn) =>
      call(
          or: _fn(_instance.or?.map((e) => CopyWith$Input$ExtensionFilterInput(
                e,
                (i) => i,
              )))?.toList());

  CopyWith$Input$StringFilterInput<TRes> get pkgName {
    final local$pkgName = _instance.pkgName;
    return local$pkgName == null
        ? CopyWith$Input$StringFilterInput.stub(_then(_instance))
        : CopyWith$Input$StringFilterInput(
            local$pkgName, (e) => call(pkgName: e));
  }

  CopyWith$Input$StringFilterInput<TRes> get repo {
    final local$repo = _instance.repo;
    return local$repo == null
        ? CopyWith$Input$StringFilterInput.stub(_then(_instance))
        : CopyWith$Input$StringFilterInput(local$repo, (e) => call(repo: e));
  }

  CopyWith$Input$IntFilterInput<TRes> get versionCode {
    final local$versionCode = _instance.versionCode;
    return local$versionCode == null
        ? CopyWith$Input$IntFilterInput.stub(_then(_instance))
        : CopyWith$Input$IntFilterInput(
            local$versionCode, (e) => call(versionCode: e));
  }

  CopyWith$Input$StringFilterInput<TRes> get versionName {
    final local$versionName = _instance.versionName;
    return local$versionName == null
        ? CopyWith$Input$StringFilterInput.stub(_then(_instance))
        : CopyWith$Input$StringFilterInput(
            local$versionName, (e) => call(versionName: e));
  }
}

class _CopyWithStubImpl$Input$ExtensionFilterInput<TRes>
    implements CopyWith$Input$ExtensionFilterInput<TRes> {
  _CopyWithStubImpl$Input$ExtensionFilterInput(this._res);

  TRes _res;

  call({
    List<Input$ExtensionFilterInput>? and,
    Input$StringFilterInput? apkName,
    Input$BooleanFilterInput? hasUpdate,
    Input$StringFilterInput? iconUrl,
    Input$BooleanFilterInput? isInstalled,
    Input$BooleanFilterInput? isNsfw,
    Input$BooleanFilterInput? isObsolete,
    Input$StringFilterInput? lang,
    Input$StringFilterInput? name,
    Input$ExtensionFilterInput? not,
    List<Input$ExtensionFilterInput>? or,
    Input$StringFilterInput? pkgName,
    Input$StringFilterInput? repo,
    Input$IntFilterInput? versionCode,
    Input$StringFilterInput? versionName,
  }) =>
      _res;

  and(_fn) => _res;

  CopyWith$Input$StringFilterInput<TRes> get apkName =>
      CopyWith$Input$StringFilterInput.stub(_res);

  CopyWith$Input$BooleanFilterInput<TRes> get hasUpdate =>
      CopyWith$Input$BooleanFilterInput.stub(_res);

  CopyWith$Input$StringFilterInput<TRes> get iconUrl =>
      CopyWith$Input$StringFilterInput.stub(_res);

  CopyWith$Input$BooleanFilterInput<TRes> get isInstalled =>
      CopyWith$Input$BooleanFilterInput.stub(_res);

  CopyWith$Input$BooleanFilterInput<TRes> get isNsfw =>
      CopyWith$Input$BooleanFilterInput.stub(_res);

  CopyWith$Input$BooleanFilterInput<TRes> get isObsolete =>
      CopyWith$Input$BooleanFilterInput.stub(_res);

  CopyWith$Input$StringFilterInput<TRes> get lang =>
      CopyWith$Input$StringFilterInput.stub(_res);

  CopyWith$Input$StringFilterInput<TRes> get name =>
      CopyWith$Input$StringFilterInput.stub(_res);

  CopyWith$Input$ExtensionFilterInput<TRes> get not =>
      CopyWith$Input$ExtensionFilterInput.stub(_res);

  or(_fn) => _res;

  CopyWith$Input$StringFilterInput<TRes> get pkgName =>
      CopyWith$Input$StringFilterInput.stub(_res);

  CopyWith$Input$StringFilterInput<TRes> get repo =>
      CopyWith$Input$StringFilterInput.stub(_res);

  CopyWith$Input$IntFilterInput<TRes> get versionCode =>
      CopyWith$Input$IntFilterInput.stub(_res);

  CopyWith$Input$StringFilterInput<TRes> get versionName =>
      CopyWith$Input$StringFilterInput.stub(_res);
}

class Input$ExtensionOrderInput {
  factory Input$ExtensionOrderInput({
    required Enum$ExtensionOrderBy by,
    Enum$SortOrder? byType,
  }) =>
      Input$ExtensionOrderInput._({
        r'by': by,
        if (byType != null) r'byType': byType,
      });

  Input$ExtensionOrderInput._(this._$data);

  factory Input$ExtensionOrderInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$by = data['by'];
    result$data['by'] = fromJson$Enum$ExtensionOrderBy((l$by as String));
    if (data.containsKey('byType')) {
      final l$byType = data['byType'];
      result$data['byType'] = l$byType == null
          ? null
          : fromJson$Enum$SortOrder((l$byType as String));
    }
    return Input$ExtensionOrderInput._(result$data);
  }

  Map<String, dynamic> _$data;

  Enum$ExtensionOrderBy get by => (_$data['by'] as Enum$ExtensionOrderBy);

  Enum$SortOrder? get byType => (_$data['byType'] as Enum$SortOrder?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$by = by;
    result$data['by'] = toJson$Enum$ExtensionOrderBy(l$by);
    if (_$data.containsKey('byType')) {
      final l$byType = byType;
      result$data['byType'] =
          l$byType == null ? null : toJson$Enum$SortOrder(l$byType);
    }
    return result$data;
  }

  CopyWith$Input$ExtensionOrderInput<Input$ExtensionOrderInput> get copyWith =>
      CopyWith$Input$ExtensionOrderInput(
        this,
        (i) => i,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$ExtensionOrderInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$by = by;
    final lOther$by = other.by;
    if (l$by != lOther$by) {
      return false;
    }
    final l$byType = byType;
    final lOther$byType = other.byType;
    if (_$data.containsKey('byType') != other._$data.containsKey('byType')) {
      return false;
    }
    if (l$byType != lOther$byType) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$by = by;
    final l$byType = byType;
    return Object.hashAll([
      l$by,
      _$data.containsKey('byType') ? l$byType : const {},
    ]);
  }
}

abstract class CopyWith$Input$ExtensionOrderInput<TRes> {
  factory CopyWith$Input$ExtensionOrderInput(
    Input$ExtensionOrderInput instance,
    TRes Function(Input$ExtensionOrderInput) then,
  ) = _CopyWithImpl$Input$ExtensionOrderInput;

  factory CopyWith$Input$ExtensionOrderInput.stub(TRes res) =
      _CopyWithStubImpl$Input$ExtensionOrderInput;

  TRes call({
    Enum$ExtensionOrderBy? by,
    Enum$SortOrder? byType,
  });
}

class _CopyWithImpl$Input$ExtensionOrderInput<TRes>
    implements CopyWith$Input$ExtensionOrderInput<TRes> {
  _CopyWithImpl$Input$ExtensionOrderInput(
    this._instance,
    this._then,
  );

  final Input$ExtensionOrderInput _instance;

  final TRes Function(Input$ExtensionOrderInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? by = _undefined,
    Object? byType = _undefined,
  }) =>
      _then(Input$ExtensionOrderInput._({
        ..._instance._$data,
        if (by != _undefined && by != null) 'by': (by as Enum$ExtensionOrderBy),
        if (byType != _undefined) 'byType': (byType as Enum$SortOrder?),
      }));
}

class _CopyWithStubImpl$Input$ExtensionOrderInput<TRes>
    implements CopyWith$Input$ExtensionOrderInput<TRes> {
  _CopyWithStubImpl$Input$ExtensionOrderInput(this._res);

  TRes _res;

  call({
    Enum$ExtensionOrderBy? by,
    Enum$SortOrder? byType,
  }) =>
      _res;
}

class Input$FetchChapterPagesInput {
  factory Input$FetchChapterPagesInput({
    required int chapterId,
    String? clientMutationId,
  }) =>
      Input$FetchChapterPagesInput._({
        r'chapterId': chapterId,
        if (clientMutationId != null) r'clientMutationId': clientMutationId,
      });

  Input$FetchChapterPagesInput._(this._$data);

  factory Input$FetchChapterPagesInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$chapterId = data['chapterId'];
    result$data['chapterId'] = (l$chapterId as int);
    if (data.containsKey('clientMutationId')) {
      final l$clientMutationId = data['clientMutationId'];
      result$data['clientMutationId'] = (l$clientMutationId as String?);
    }
    return Input$FetchChapterPagesInput._(result$data);
  }

  Map<String, dynamic> _$data;

  int get chapterId => (_$data['chapterId'] as int);

  String? get clientMutationId => (_$data['clientMutationId'] as String?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$chapterId = chapterId;
    result$data['chapterId'] = l$chapterId;
    if (_$data.containsKey('clientMutationId')) {
      final l$clientMutationId = clientMutationId;
      result$data['clientMutationId'] = l$clientMutationId;
    }
    return result$data;
  }

  CopyWith$Input$FetchChapterPagesInput<Input$FetchChapterPagesInput>
      get copyWith => CopyWith$Input$FetchChapterPagesInput(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$FetchChapterPagesInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$chapterId = chapterId;
    final lOther$chapterId = other.chapterId;
    if (l$chapterId != lOther$chapterId) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (_$data.containsKey('clientMutationId') !=
        other._$data.containsKey('clientMutationId')) {
      return false;
    }
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$chapterId = chapterId;
    final l$clientMutationId = clientMutationId;
    return Object.hashAll([
      l$chapterId,
      _$data.containsKey('clientMutationId') ? l$clientMutationId : const {},
    ]);
  }
}

abstract class CopyWith$Input$FetchChapterPagesInput<TRes> {
  factory CopyWith$Input$FetchChapterPagesInput(
    Input$FetchChapterPagesInput instance,
    TRes Function(Input$FetchChapterPagesInput) then,
  ) = _CopyWithImpl$Input$FetchChapterPagesInput;

  factory CopyWith$Input$FetchChapterPagesInput.stub(TRes res) =
      _CopyWithStubImpl$Input$FetchChapterPagesInput;

  TRes call({
    int? chapterId,
    String? clientMutationId,
  });
}

class _CopyWithImpl$Input$FetchChapterPagesInput<TRes>
    implements CopyWith$Input$FetchChapterPagesInput<TRes> {
  _CopyWithImpl$Input$FetchChapterPagesInput(
    this._instance,
    this._then,
  );

  final Input$FetchChapterPagesInput _instance;

  final TRes Function(Input$FetchChapterPagesInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? chapterId = _undefined,
    Object? clientMutationId = _undefined,
  }) =>
      _then(Input$FetchChapterPagesInput._({
        ..._instance._$data,
        if (chapterId != _undefined && chapterId != null)
          'chapterId': (chapterId as int),
        if (clientMutationId != _undefined)
          'clientMutationId': (clientMutationId as String?),
      }));
}

class _CopyWithStubImpl$Input$FetchChapterPagesInput<TRes>
    implements CopyWith$Input$FetchChapterPagesInput<TRes> {
  _CopyWithStubImpl$Input$FetchChapterPagesInput(this._res);

  TRes _res;

  call({
    int? chapterId,
    String? clientMutationId,
  }) =>
      _res;
}

class Input$FetchChaptersInput {
  factory Input$FetchChaptersInput({
    String? clientMutationId,
    required int mangaId,
  }) =>
      Input$FetchChaptersInput._({
        if (clientMutationId != null) r'clientMutationId': clientMutationId,
        r'mangaId': mangaId,
      });

  Input$FetchChaptersInput._(this._$data);

  factory Input$FetchChaptersInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('clientMutationId')) {
      final l$clientMutationId = data['clientMutationId'];
      result$data['clientMutationId'] = (l$clientMutationId as String?);
    }
    final l$mangaId = data['mangaId'];
    result$data['mangaId'] = (l$mangaId as int);
    return Input$FetchChaptersInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get clientMutationId => (_$data['clientMutationId'] as String?);

  int get mangaId => (_$data['mangaId'] as int);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('clientMutationId')) {
      final l$clientMutationId = clientMutationId;
      result$data['clientMutationId'] = l$clientMutationId;
    }
    final l$mangaId = mangaId;
    result$data['mangaId'] = l$mangaId;
    return result$data;
  }

  CopyWith$Input$FetchChaptersInput<Input$FetchChaptersInput> get copyWith =>
      CopyWith$Input$FetchChaptersInput(
        this,
        (i) => i,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$FetchChaptersInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (_$data.containsKey('clientMutationId') !=
        other._$data.containsKey('clientMutationId')) {
      return false;
    }
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    final l$mangaId = mangaId;
    final lOther$mangaId = other.mangaId;
    if (l$mangaId != lOther$mangaId) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$clientMutationId = clientMutationId;
    final l$mangaId = mangaId;
    return Object.hashAll([
      _$data.containsKey('clientMutationId') ? l$clientMutationId : const {},
      l$mangaId,
    ]);
  }
}

abstract class CopyWith$Input$FetchChaptersInput<TRes> {
  factory CopyWith$Input$FetchChaptersInput(
    Input$FetchChaptersInput instance,
    TRes Function(Input$FetchChaptersInput) then,
  ) = _CopyWithImpl$Input$FetchChaptersInput;

  factory CopyWith$Input$FetchChaptersInput.stub(TRes res) =
      _CopyWithStubImpl$Input$FetchChaptersInput;

  TRes call({
    String? clientMutationId,
    int? mangaId,
  });
}

class _CopyWithImpl$Input$FetchChaptersInput<TRes>
    implements CopyWith$Input$FetchChaptersInput<TRes> {
  _CopyWithImpl$Input$FetchChaptersInput(
    this._instance,
    this._then,
  );

  final Input$FetchChaptersInput _instance;

  final TRes Function(Input$FetchChaptersInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? clientMutationId = _undefined,
    Object? mangaId = _undefined,
  }) =>
      _then(Input$FetchChaptersInput._({
        ..._instance._$data,
        if (clientMutationId != _undefined)
          'clientMutationId': (clientMutationId as String?),
        if (mangaId != _undefined && mangaId != null)
          'mangaId': (mangaId as int),
      }));
}

class _CopyWithStubImpl$Input$FetchChaptersInput<TRes>
    implements CopyWith$Input$FetchChaptersInput<TRes> {
  _CopyWithStubImpl$Input$FetchChaptersInput(this._res);

  TRes _res;

  call({
    String? clientMutationId,
    int? mangaId,
  }) =>
      _res;
}

class Input$FetchExtensionsInput {
  factory Input$FetchExtensionsInput({String? clientMutationId}) =>
      Input$FetchExtensionsInput._({
        if (clientMutationId != null) r'clientMutationId': clientMutationId,
      });

  Input$FetchExtensionsInput._(this._$data);

  factory Input$FetchExtensionsInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('clientMutationId')) {
      final l$clientMutationId = data['clientMutationId'];
      result$data['clientMutationId'] = (l$clientMutationId as String?);
    }
    return Input$FetchExtensionsInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get clientMutationId => (_$data['clientMutationId'] as String?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('clientMutationId')) {
      final l$clientMutationId = clientMutationId;
      result$data['clientMutationId'] = l$clientMutationId;
    }
    return result$data;
  }

  CopyWith$Input$FetchExtensionsInput<Input$FetchExtensionsInput>
      get copyWith => CopyWith$Input$FetchExtensionsInput(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$FetchExtensionsInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (_$data.containsKey('clientMutationId') !=
        other._$data.containsKey('clientMutationId')) {
      return false;
    }
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$clientMutationId = clientMutationId;
    return Object.hashAll([
      _$data.containsKey('clientMutationId') ? l$clientMutationId : const {}
    ]);
  }
}

abstract class CopyWith$Input$FetchExtensionsInput<TRes> {
  factory CopyWith$Input$FetchExtensionsInput(
    Input$FetchExtensionsInput instance,
    TRes Function(Input$FetchExtensionsInput) then,
  ) = _CopyWithImpl$Input$FetchExtensionsInput;

  factory CopyWith$Input$FetchExtensionsInput.stub(TRes res) =
      _CopyWithStubImpl$Input$FetchExtensionsInput;

  TRes call({String? clientMutationId});
}

class _CopyWithImpl$Input$FetchExtensionsInput<TRes>
    implements CopyWith$Input$FetchExtensionsInput<TRes> {
  _CopyWithImpl$Input$FetchExtensionsInput(
    this._instance,
    this._then,
  );

  final Input$FetchExtensionsInput _instance;

  final TRes Function(Input$FetchExtensionsInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? clientMutationId = _undefined}) =>
      _then(Input$FetchExtensionsInput._({
        ..._instance._$data,
        if (clientMutationId != _undefined)
          'clientMutationId': (clientMutationId as String?),
      }));
}

class _CopyWithStubImpl$Input$FetchExtensionsInput<TRes>
    implements CopyWith$Input$FetchExtensionsInput<TRes> {
  _CopyWithStubImpl$Input$FetchExtensionsInput(this._res);

  TRes _res;

  call({String? clientMutationId}) => _res;
}

class Input$FetchMangaInput {
  factory Input$FetchMangaInput({
    String? clientMutationId,
    required int id,
  }) =>
      Input$FetchMangaInput._({
        if (clientMutationId != null) r'clientMutationId': clientMutationId,
        r'id': id,
      });

  Input$FetchMangaInput._(this._$data);

  factory Input$FetchMangaInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('clientMutationId')) {
      final l$clientMutationId = data['clientMutationId'];
      result$data['clientMutationId'] = (l$clientMutationId as String?);
    }
    final l$id = data['id'];
    result$data['id'] = (l$id as int);
    return Input$FetchMangaInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get clientMutationId => (_$data['clientMutationId'] as String?);

  int get id => (_$data['id'] as int);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('clientMutationId')) {
      final l$clientMutationId = clientMutationId;
      result$data['clientMutationId'] = l$clientMutationId;
    }
    final l$id = id;
    result$data['id'] = l$id;
    return result$data;
  }

  CopyWith$Input$FetchMangaInput<Input$FetchMangaInput> get copyWith =>
      CopyWith$Input$FetchMangaInput(
        this,
        (i) => i,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$FetchMangaInput || runtimeType != other.runtimeType) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (_$data.containsKey('clientMutationId') !=
        other._$data.containsKey('clientMutationId')) {
      return false;
    }
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$clientMutationId = clientMutationId;
    final l$id = id;
    return Object.hashAll([
      _$data.containsKey('clientMutationId') ? l$clientMutationId : const {},
      l$id,
    ]);
  }
}

abstract class CopyWith$Input$FetchMangaInput<TRes> {
  factory CopyWith$Input$FetchMangaInput(
    Input$FetchMangaInput instance,
    TRes Function(Input$FetchMangaInput) then,
  ) = _CopyWithImpl$Input$FetchMangaInput;

  factory CopyWith$Input$FetchMangaInput.stub(TRes res) =
      _CopyWithStubImpl$Input$FetchMangaInput;

  TRes call({
    String? clientMutationId,
    int? id,
  });
}

class _CopyWithImpl$Input$FetchMangaInput<TRes>
    implements CopyWith$Input$FetchMangaInput<TRes> {
  _CopyWithImpl$Input$FetchMangaInput(
    this._instance,
    this._then,
  );

  final Input$FetchMangaInput _instance;

  final TRes Function(Input$FetchMangaInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? clientMutationId = _undefined,
    Object? id = _undefined,
  }) =>
      _then(Input$FetchMangaInput._({
        ..._instance._$data,
        if (clientMutationId != _undefined)
          'clientMutationId': (clientMutationId as String?),
        if (id != _undefined && id != null) 'id': (id as int),
      }));
}

class _CopyWithStubImpl$Input$FetchMangaInput<TRes>
    implements CopyWith$Input$FetchMangaInput<TRes> {
  _CopyWithStubImpl$Input$FetchMangaInput(this._res);

  TRes _res;

  call({
    String? clientMutationId,
    int? id,
  }) =>
      _res;
}

class Input$FetchSourceMangaInput {
  factory Input$FetchSourceMangaInput({
    String? clientMutationId,
    List<Input$FilterChangeInput>? filters,
    required int page,
    String? query,
    required String source,
    required Enum$FetchSourceMangaType type,
  }) =>
      Input$FetchSourceMangaInput._({
        if (clientMutationId != null) r'clientMutationId': clientMutationId,
        if (filters != null) r'filters': filters,
        r'page': page,
        if (query != null) r'query': query,
        r'source': source,
        r'type': type,
      });

  Input$FetchSourceMangaInput._(this._$data);

  factory Input$FetchSourceMangaInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('clientMutationId')) {
      final l$clientMutationId = data['clientMutationId'];
      result$data['clientMutationId'] = (l$clientMutationId as String?);
    }
    if (data.containsKey('filters')) {
      final l$filters = data['filters'];
      result$data['filters'] = (l$filters as List<dynamic>?)
          ?.map((e) =>
              Input$FilterChangeInput.fromJson((e as Map<String, dynamic>)))
          .toList();
    }
    final l$page = data['page'];
    result$data['page'] = (l$page as int);
    if (data.containsKey('query')) {
      final l$query = data['query'];
      result$data['query'] = (l$query as String?);
    }
    final l$source = data['source'];
    result$data['source'] = longStringFromJson(l$source);
    final l$type = data['type'];
    result$data['type'] =
        fromJson$Enum$FetchSourceMangaType((l$type as String));
    return Input$FetchSourceMangaInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get clientMutationId => (_$data['clientMutationId'] as String?);

  List<Input$FilterChangeInput>? get filters =>
      (_$data['filters'] as List<Input$FilterChangeInput>?);

  int get page => (_$data['page'] as int);

  String? get query => (_$data['query'] as String?);

  String get source => (_$data['source'] as String);

  Enum$FetchSourceMangaType get type =>
      (_$data['type'] as Enum$FetchSourceMangaType);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('clientMutationId')) {
      final l$clientMutationId = clientMutationId;
      result$data['clientMutationId'] = l$clientMutationId;
    }
    if (_$data.containsKey('filters')) {
      final l$filters = filters;
      result$data['filters'] = l$filters?.map((e) => e.toJson()).toList();
    }
    final l$page = page;
    result$data['page'] = l$page;
    if (_$data.containsKey('query')) {
      final l$query = query;
      result$data['query'] = l$query;
    }
    final l$source = source;
    result$data['source'] = longStringToJson(l$source);
    final l$type = type;
    result$data['type'] = toJson$Enum$FetchSourceMangaType(l$type);
    return result$data;
  }

  CopyWith$Input$FetchSourceMangaInput<Input$FetchSourceMangaInput>
      get copyWith => CopyWith$Input$FetchSourceMangaInput(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$FetchSourceMangaInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (_$data.containsKey('clientMutationId') !=
        other._$data.containsKey('clientMutationId')) {
      return false;
    }
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    final l$filters = filters;
    final lOther$filters = other.filters;
    if (_$data.containsKey('filters') != other._$data.containsKey('filters')) {
      return false;
    }
    if (l$filters != null && lOther$filters != null) {
      if (l$filters.length != lOther$filters.length) {
        return false;
      }
      for (int i = 0; i < l$filters.length; i++) {
        final l$filters$entry = l$filters[i];
        final lOther$filters$entry = lOther$filters[i];
        if (l$filters$entry != lOther$filters$entry) {
          return false;
        }
      }
    } else if (l$filters != lOther$filters) {
      return false;
    }
    final l$page = page;
    final lOther$page = other.page;
    if (l$page != lOther$page) {
      return false;
    }
    final l$query = query;
    final lOther$query = other.query;
    if (_$data.containsKey('query') != other._$data.containsKey('query')) {
      return false;
    }
    if (l$query != lOther$query) {
      return false;
    }
    final l$source = source;
    final lOther$source = other.source;
    if (l$source != lOther$source) {
      return false;
    }
    final l$type = type;
    final lOther$type = other.type;
    if (l$type != lOther$type) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$clientMutationId = clientMutationId;
    final l$filters = filters;
    final l$page = page;
    final l$query = query;
    final l$source = source;
    final l$type = type;
    return Object.hashAll([
      _$data.containsKey('clientMutationId') ? l$clientMutationId : const {},
      _$data.containsKey('filters')
          ? l$filters == null
              ? null
              : Object.hashAll(l$filters.map((v) => v))
          : const {},
      l$page,
      _$data.containsKey('query') ? l$query : const {},
      l$source,
      l$type,
    ]);
  }
}

abstract class CopyWith$Input$FetchSourceMangaInput<TRes> {
  factory CopyWith$Input$FetchSourceMangaInput(
    Input$FetchSourceMangaInput instance,
    TRes Function(Input$FetchSourceMangaInput) then,
  ) = _CopyWithImpl$Input$FetchSourceMangaInput;

  factory CopyWith$Input$FetchSourceMangaInput.stub(TRes res) =
      _CopyWithStubImpl$Input$FetchSourceMangaInput;

  TRes call({
    String? clientMutationId,
    List<Input$FilterChangeInput>? filters,
    int? page,
    String? query,
    String? source,
    Enum$FetchSourceMangaType? type,
  });
  TRes filters(
      Iterable<Input$FilterChangeInput>? Function(
              Iterable<
                  CopyWith$Input$FilterChangeInput<Input$FilterChangeInput>>?)
          _fn);
}

class _CopyWithImpl$Input$FetchSourceMangaInput<TRes>
    implements CopyWith$Input$FetchSourceMangaInput<TRes> {
  _CopyWithImpl$Input$FetchSourceMangaInput(
    this._instance,
    this._then,
  );

  final Input$FetchSourceMangaInput _instance;

  final TRes Function(Input$FetchSourceMangaInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? clientMutationId = _undefined,
    Object? filters = _undefined,
    Object? page = _undefined,
    Object? query = _undefined,
    Object? source = _undefined,
    Object? type = _undefined,
  }) =>
      _then(Input$FetchSourceMangaInput._({
        ..._instance._$data,
        if (clientMutationId != _undefined)
          'clientMutationId': (clientMutationId as String?),
        if (filters != _undefined)
          'filters': (filters as List<Input$FilterChangeInput>?),
        if (page != _undefined && page != null) 'page': (page as int),
        if (query != _undefined) 'query': (query as String?),
        if (source != _undefined && source != null)
          'source': (source as String),
        if (type != _undefined && type != null)
          'type': (type as Enum$FetchSourceMangaType),
      }));

  TRes filters(
          Iterable<Input$FilterChangeInput>? Function(
                  Iterable<
                      CopyWith$Input$FilterChangeInput<
                          Input$FilterChangeInput>>?)
              _fn) =>
      call(
          filters: _fn(
              _instance.filters?.map((e) => CopyWith$Input$FilterChangeInput(
                    e,
                    (i) => i,
                  )))?.toList());
}

class _CopyWithStubImpl$Input$FetchSourceMangaInput<TRes>
    implements CopyWith$Input$FetchSourceMangaInput<TRes> {
  _CopyWithStubImpl$Input$FetchSourceMangaInput(this._res);

  TRes _res;

  call({
    String? clientMutationId,
    List<Input$FilterChangeInput>? filters,
    int? page,
    String? query,
    String? source,
    Enum$FetchSourceMangaType? type,
  }) =>
      _res;

  filters(_fn) => _res;
}

class Input$FetchTrackInput {
  factory Input$FetchTrackInput({
    String? clientMutationId,
    required int recordId,
  }) =>
      Input$FetchTrackInput._({
        if (clientMutationId != null) r'clientMutationId': clientMutationId,
        r'recordId': recordId,
      });

  Input$FetchTrackInput._(this._$data);

  factory Input$FetchTrackInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('clientMutationId')) {
      final l$clientMutationId = data['clientMutationId'];
      result$data['clientMutationId'] = (l$clientMutationId as String?);
    }
    final l$recordId = data['recordId'];
    result$data['recordId'] = (l$recordId as int);
    return Input$FetchTrackInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get clientMutationId => (_$data['clientMutationId'] as String?);

  int get recordId => (_$data['recordId'] as int);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('clientMutationId')) {
      final l$clientMutationId = clientMutationId;
      result$data['clientMutationId'] = l$clientMutationId;
    }
    final l$recordId = recordId;
    result$data['recordId'] = l$recordId;
    return result$data;
  }

  CopyWith$Input$FetchTrackInput<Input$FetchTrackInput> get copyWith =>
      CopyWith$Input$FetchTrackInput(
        this,
        (i) => i,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$FetchTrackInput || runtimeType != other.runtimeType) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (_$data.containsKey('clientMutationId') !=
        other._$data.containsKey('clientMutationId')) {
      return false;
    }
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    final l$recordId = recordId;
    final lOther$recordId = other.recordId;
    if (l$recordId != lOther$recordId) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$clientMutationId = clientMutationId;
    final l$recordId = recordId;
    return Object.hashAll([
      _$data.containsKey('clientMutationId') ? l$clientMutationId : const {},
      l$recordId,
    ]);
  }
}

abstract class CopyWith$Input$FetchTrackInput<TRes> {
  factory CopyWith$Input$FetchTrackInput(
    Input$FetchTrackInput instance,
    TRes Function(Input$FetchTrackInput) then,
  ) = _CopyWithImpl$Input$FetchTrackInput;

  factory CopyWith$Input$FetchTrackInput.stub(TRes res) =
      _CopyWithStubImpl$Input$FetchTrackInput;

  TRes call({
    String? clientMutationId,
    int? recordId,
  });
}

class _CopyWithImpl$Input$FetchTrackInput<TRes>
    implements CopyWith$Input$FetchTrackInput<TRes> {
  _CopyWithImpl$Input$FetchTrackInput(
    this._instance,
    this._then,
  );

  final Input$FetchTrackInput _instance;

  final TRes Function(Input$FetchTrackInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? clientMutationId = _undefined,
    Object? recordId = _undefined,
  }) =>
      _then(Input$FetchTrackInput._({
        ..._instance._$data,
        if (clientMutationId != _undefined)
          'clientMutationId': (clientMutationId as String?),
        if (recordId != _undefined && recordId != null)
          'recordId': (recordId as int),
      }));
}

class _CopyWithStubImpl$Input$FetchTrackInput<TRes>
    implements CopyWith$Input$FetchTrackInput<TRes> {
  _CopyWithStubImpl$Input$FetchTrackInput(this._res);

  TRes _res;

  call({
    String? clientMutationId,
    int? recordId,
  }) =>
      _res;
}

class Input$FilterChangeInput {
  factory Input$FilterChangeInput({
    bool? checkBoxState,
    Input$FilterChangeInput? groupChange,
    required int position,
    int? selectState,
    Input$SortSelectionInput? sortState,
    String? textState,
    Enum$TriState? triState,
  }) =>
      Input$FilterChangeInput._({
        if (checkBoxState != null) r'checkBoxState': checkBoxState,
        if (groupChange != null) r'groupChange': groupChange,
        r'position': position,
        if (selectState != null) r'selectState': selectState,
        if (sortState != null) r'sortState': sortState,
        if (textState != null) r'textState': textState,
        if (triState != null) r'triState': triState,
      });

  Input$FilterChangeInput._(this._$data);

  factory Input$FilterChangeInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('checkBoxState')) {
      final l$checkBoxState = data['checkBoxState'];
      result$data['checkBoxState'] = (l$checkBoxState as bool?);
    }
    if (data.containsKey('groupChange')) {
      final l$groupChange = data['groupChange'];
      result$data['groupChange'] = l$groupChange == null
          ? null
          : Input$FilterChangeInput.fromJson(
              (l$groupChange as Map<String, dynamic>));
    }
    final l$position = data['position'];
    result$data['position'] = (l$position as int);
    if (data.containsKey('selectState')) {
      final l$selectState = data['selectState'];
      result$data['selectState'] = (l$selectState as int?);
    }
    if (data.containsKey('sortState')) {
      final l$sortState = data['sortState'];
      result$data['sortState'] = l$sortState == null
          ? null
          : Input$SortSelectionInput.fromJson(
              (l$sortState as Map<String, dynamic>));
    }
    if (data.containsKey('textState')) {
      final l$textState = data['textState'];
      result$data['textState'] = (l$textState as String?);
    }
    if (data.containsKey('triState')) {
      final l$triState = data['triState'];
      result$data['triState'] = l$triState == null
          ? null
          : fromJson$Enum$TriState((l$triState as String));
    }
    return Input$FilterChangeInput._(result$data);
  }

  Map<String, dynamic> _$data;

  bool? get checkBoxState => (_$data['checkBoxState'] as bool?);

  Input$FilterChangeInput? get groupChange =>
      (_$data['groupChange'] as Input$FilterChangeInput?);

  int get position => (_$data['position'] as int);

  int? get selectState => (_$data['selectState'] as int?);

  Input$SortSelectionInput? get sortState =>
      (_$data['sortState'] as Input$SortSelectionInput?);

  String? get textState => (_$data['textState'] as String?);

  Enum$TriState? get triState => (_$data['triState'] as Enum$TriState?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('checkBoxState')) {
      final l$checkBoxState = checkBoxState;
      result$data['checkBoxState'] = l$checkBoxState;
    }
    if (_$data.containsKey('groupChange')) {
      final l$groupChange = groupChange;
      result$data['groupChange'] = l$groupChange?.toJson();
    }
    final l$position = position;
    result$data['position'] = l$position;
    if (_$data.containsKey('selectState')) {
      final l$selectState = selectState;
      result$data['selectState'] = l$selectState;
    }
    if (_$data.containsKey('sortState')) {
      final l$sortState = sortState;
      result$data['sortState'] = l$sortState?.toJson();
    }
    if (_$data.containsKey('textState')) {
      final l$textState = textState;
      result$data['textState'] = l$textState;
    }
    if (_$data.containsKey('triState')) {
      final l$triState = triState;
      result$data['triState'] =
          l$triState == null ? null : toJson$Enum$TriState(l$triState);
    }
    return result$data;
  }

  CopyWith$Input$FilterChangeInput<Input$FilterChangeInput> get copyWith =>
      CopyWith$Input$FilterChangeInput(
        this,
        (i) => i,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$FilterChangeInput || runtimeType != other.runtimeType) {
      return false;
    }
    final l$checkBoxState = checkBoxState;
    final lOther$checkBoxState = other.checkBoxState;
    if (_$data.containsKey('checkBoxState') !=
        other._$data.containsKey('checkBoxState')) {
      return false;
    }
    if (l$checkBoxState != lOther$checkBoxState) {
      return false;
    }
    final l$groupChange = groupChange;
    final lOther$groupChange = other.groupChange;
    if (_$data.containsKey('groupChange') !=
        other._$data.containsKey('groupChange')) {
      return false;
    }
    if (l$groupChange != lOther$groupChange) {
      return false;
    }
    final l$position = position;
    final lOther$position = other.position;
    if (l$position != lOther$position) {
      return false;
    }
    final l$selectState = selectState;
    final lOther$selectState = other.selectState;
    if (_$data.containsKey('selectState') !=
        other._$data.containsKey('selectState')) {
      return false;
    }
    if (l$selectState != lOther$selectState) {
      return false;
    }
    final l$sortState = sortState;
    final lOther$sortState = other.sortState;
    if (_$data.containsKey('sortState') !=
        other._$data.containsKey('sortState')) {
      return false;
    }
    if (l$sortState != lOther$sortState) {
      return false;
    }
    final l$textState = textState;
    final lOther$textState = other.textState;
    if (_$data.containsKey('textState') !=
        other._$data.containsKey('textState')) {
      return false;
    }
    if (l$textState != lOther$textState) {
      return false;
    }
    final l$triState = triState;
    final lOther$triState = other.triState;
    if (_$data.containsKey('triState') !=
        other._$data.containsKey('triState')) {
      return false;
    }
    if (l$triState != lOther$triState) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$checkBoxState = checkBoxState;
    final l$groupChange = groupChange;
    final l$position = position;
    final l$selectState = selectState;
    final l$sortState = sortState;
    final l$textState = textState;
    final l$triState = triState;
    return Object.hashAll([
      _$data.containsKey('checkBoxState') ? l$checkBoxState : const {},
      _$data.containsKey('groupChange') ? l$groupChange : const {},
      l$position,
      _$data.containsKey('selectState') ? l$selectState : const {},
      _$data.containsKey('sortState') ? l$sortState : const {},
      _$data.containsKey('textState') ? l$textState : const {},
      _$data.containsKey('triState') ? l$triState : const {},
    ]);
  }
}

abstract class CopyWith$Input$FilterChangeInput<TRes> {
  factory CopyWith$Input$FilterChangeInput(
    Input$FilterChangeInput instance,
    TRes Function(Input$FilterChangeInput) then,
  ) = _CopyWithImpl$Input$FilterChangeInput;

  factory CopyWith$Input$FilterChangeInput.stub(TRes res) =
      _CopyWithStubImpl$Input$FilterChangeInput;

  TRes call({
    bool? checkBoxState,
    Input$FilterChangeInput? groupChange,
    int? position,
    int? selectState,
    Input$SortSelectionInput? sortState,
    String? textState,
    Enum$TriState? triState,
  });
  CopyWith$Input$FilterChangeInput<TRes> get groupChange;
  CopyWith$Input$SortSelectionInput<TRes> get sortState;
}

class _CopyWithImpl$Input$FilterChangeInput<TRes>
    implements CopyWith$Input$FilterChangeInput<TRes> {
  _CopyWithImpl$Input$FilterChangeInput(
    this._instance,
    this._then,
  );

  final Input$FilterChangeInput _instance;

  final TRes Function(Input$FilterChangeInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? checkBoxState = _undefined,
    Object? groupChange = _undefined,
    Object? position = _undefined,
    Object? selectState = _undefined,
    Object? sortState = _undefined,
    Object? textState = _undefined,
    Object? triState = _undefined,
  }) =>
      _then(Input$FilterChangeInput._({
        ..._instance._$data,
        if (checkBoxState != _undefined)
          'checkBoxState': (checkBoxState as bool?),
        if (groupChange != _undefined)
          'groupChange': (groupChange as Input$FilterChangeInput?),
        if (position != _undefined && position != null)
          'position': (position as int),
        if (selectState != _undefined) 'selectState': (selectState as int?),
        if (sortState != _undefined)
          'sortState': (sortState as Input$SortSelectionInput?),
        if (textState != _undefined) 'textState': (textState as String?),
        if (triState != _undefined) 'triState': (triState as Enum$TriState?),
      }));

  CopyWith$Input$FilterChangeInput<TRes> get groupChange {
    final local$groupChange = _instance.groupChange;
    return local$groupChange == null
        ? CopyWith$Input$FilterChangeInput.stub(_then(_instance))
        : CopyWith$Input$FilterChangeInput(
            local$groupChange, (e) => call(groupChange: e));
  }

  CopyWith$Input$SortSelectionInput<TRes> get sortState {
    final local$sortState = _instance.sortState;
    return local$sortState == null
        ? CopyWith$Input$SortSelectionInput.stub(_then(_instance))
        : CopyWith$Input$SortSelectionInput(
            local$sortState, (e) => call(sortState: e));
  }
}

class _CopyWithStubImpl$Input$FilterChangeInput<TRes>
    implements CopyWith$Input$FilterChangeInput<TRes> {
  _CopyWithStubImpl$Input$FilterChangeInput(this._res);

  TRes _res;

  call({
    bool? checkBoxState,
    Input$FilterChangeInput? groupChange,
    int? position,
    int? selectState,
    Input$SortSelectionInput? sortState,
    String? textState,
    Enum$TriState? triState,
  }) =>
      _res;

  CopyWith$Input$FilterChangeInput<TRes> get groupChange =>
      CopyWith$Input$FilterChangeInput.stub(_res);

  CopyWith$Input$SortSelectionInput<TRes> get sortState =>
      CopyWith$Input$SortSelectionInput.stub(_res);
}

class Input$FloatFilterInput {
  factory Input$FloatFilterInput({
    double? distinctFrom,
    List<double>? distinctFromAll,
    List<double>? distinctFromAny,
    double? equalTo,
    double? greaterThan,
    double? greaterThanOrEqualTo,
    List<double>? $in,
    bool? isNull,
    double? lessThan,
    double? lessThanOrEqualTo,
    double? notDistinctFrom,
    double? notEqualTo,
    List<double>? notEqualToAll,
    List<double>? notEqualToAny,
    List<double>? notIn,
  }) =>
      Input$FloatFilterInput._({
        if (distinctFrom != null) r'distinctFrom': distinctFrom,
        if (distinctFromAll != null) r'distinctFromAll': distinctFromAll,
        if (distinctFromAny != null) r'distinctFromAny': distinctFromAny,
        if (equalTo != null) r'equalTo': equalTo,
        if (greaterThan != null) r'greaterThan': greaterThan,
        if (greaterThanOrEqualTo != null)
          r'greaterThanOrEqualTo': greaterThanOrEqualTo,
        if ($in != null) r'in': $in,
        if (isNull != null) r'isNull': isNull,
        if (lessThan != null) r'lessThan': lessThan,
        if (lessThanOrEqualTo != null) r'lessThanOrEqualTo': lessThanOrEqualTo,
        if (notDistinctFrom != null) r'notDistinctFrom': notDistinctFrom,
        if (notEqualTo != null) r'notEqualTo': notEqualTo,
        if (notEqualToAll != null) r'notEqualToAll': notEqualToAll,
        if (notEqualToAny != null) r'notEqualToAny': notEqualToAny,
        if (notIn != null) r'notIn': notIn,
      });

  Input$FloatFilterInput._(this._$data);

  factory Input$FloatFilterInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('distinctFrom')) {
      final l$distinctFrom = data['distinctFrom'];
      result$data['distinctFrom'] = (l$distinctFrom as num?)?.toDouble();
    }
    if (data.containsKey('distinctFromAll')) {
      final l$distinctFromAll = data['distinctFromAll'];
      result$data['distinctFromAll'] = (l$distinctFromAll as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList();
    }
    if (data.containsKey('distinctFromAny')) {
      final l$distinctFromAny = data['distinctFromAny'];
      result$data['distinctFromAny'] = (l$distinctFromAny as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList();
    }
    if (data.containsKey('equalTo')) {
      final l$equalTo = data['equalTo'];
      result$data['equalTo'] = (l$equalTo as num?)?.toDouble();
    }
    if (data.containsKey('greaterThan')) {
      final l$greaterThan = data['greaterThan'];
      result$data['greaterThan'] = (l$greaterThan as num?)?.toDouble();
    }
    if (data.containsKey('greaterThanOrEqualTo')) {
      final l$greaterThanOrEqualTo = data['greaterThanOrEqualTo'];
      result$data['greaterThanOrEqualTo'] =
          (l$greaterThanOrEqualTo as num?)?.toDouble();
    }
    if (data.containsKey('in')) {
      final l$$in = data['in'];
      result$data['in'] =
          (l$$in as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList();
    }
    if (data.containsKey('isNull')) {
      final l$isNull = data['isNull'];
      result$data['isNull'] = (l$isNull as bool?);
    }
    if (data.containsKey('lessThan')) {
      final l$lessThan = data['lessThan'];
      result$data['lessThan'] = (l$lessThan as num?)?.toDouble();
    }
    if (data.containsKey('lessThanOrEqualTo')) {
      final l$lessThanOrEqualTo = data['lessThanOrEqualTo'];
      result$data['lessThanOrEqualTo'] =
          (l$lessThanOrEqualTo as num?)?.toDouble();
    }
    if (data.containsKey('notDistinctFrom')) {
      final l$notDistinctFrom = data['notDistinctFrom'];
      result$data['notDistinctFrom'] = (l$notDistinctFrom as num?)?.toDouble();
    }
    if (data.containsKey('notEqualTo')) {
      final l$notEqualTo = data['notEqualTo'];
      result$data['notEqualTo'] = (l$notEqualTo as num?)?.toDouble();
    }
    if (data.containsKey('notEqualToAll')) {
      final l$notEqualToAll = data['notEqualToAll'];
      result$data['notEqualToAll'] = (l$notEqualToAll as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList();
    }
    if (data.containsKey('notEqualToAny')) {
      final l$notEqualToAny = data['notEqualToAny'];
      result$data['notEqualToAny'] = (l$notEqualToAny as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList();
    }
    if (data.containsKey('notIn')) {
      final l$notIn = data['notIn'];
      result$data['notIn'] = (l$notIn as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList();
    }
    return Input$FloatFilterInput._(result$data);
  }

  Map<String, dynamic> _$data;

  double? get distinctFrom => (_$data['distinctFrom'] as double?);

  List<double>? get distinctFromAll =>
      (_$data['distinctFromAll'] as List<double>?);

  List<double>? get distinctFromAny =>
      (_$data['distinctFromAny'] as List<double>?);

  double? get equalTo => (_$data['equalTo'] as double?);

  double? get greaterThan => (_$data['greaterThan'] as double?);

  double? get greaterThanOrEqualTo =>
      (_$data['greaterThanOrEqualTo'] as double?);

  List<double>? get $in => (_$data['in'] as List<double>?);

  bool? get isNull => (_$data['isNull'] as bool?);

  double? get lessThan => (_$data['lessThan'] as double?);

  double? get lessThanOrEqualTo => (_$data['lessThanOrEqualTo'] as double?);

  double? get notDistinctFrom => (_$data['notDistinctFrom'] as double?);

  double? get notEqualTo => (_$data['notEqualTo'] as double?);

  List<double>? get notEqualToAll => (_$data['notEqualToAll'] as List<double>?);

  List<double>? get notEqualToAny => (_$data['notEqualToAny'] as List<double>?);

  List<double>? get notIn => (_$data['notIn'] as List<double>?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('distinctFrom')) {
      final l$distinctFrom = distinctFrom;
      result$data['distinctFrom'] = l$distinctFrom;
    }
    if (_$data.containsKey('distinctFromAll')) {
      final l$distinctFromAll = distinctFromAll;
      result$data['distinctFromAll'] =
          l$distinctFromAll?.map((e) => e).toList();
    }
    if (_$data.containsKey('distinctFromAny')) {
      final l$distinctFromAny = distinctFromAny;
      result$data['distinctFromAny'] =
          l$distinctFromAny?.map((e) => e).toList();
    }
    if (_$data.containsKey('equalTo')) {
      final l$equalTo = equalTo;
      result$data['equalTo'] = l$equalTo;
    }
    if (_$data.containsKey('greaterThan')) {
      final l$greaterThan = greaterThan;
      result$data['greaterThan'] = l$greaterThan;
    }
    if (_$data.containsKey('greaterThanOrEqualTo')) {
      final l$greaterThanOrEqualTo = greaterThanOrEqualTo;
      result$data['greaterThanOrEqualTo'] = l$greaterThanOrEqualTo;
    }
    if (_$data.containsKey('in')) {
      final l$$in = $in;
      result$data['in'] = l$$in?.map((e) => e).toList();
    }
    if (_$data.containsKey('isNull')) {
      final l$isNull = isNull;
      result$data['isNull'] = l$isNull;
    }
    if (_$data.containsKey('lessThan')) {
      final l$lessThan = lessThan;
      result$data['lessThan'] = l$lessThan;
    }
    if (_$data.containsKey('lessThanOrEqualTo')) {
      final l$lessThanOrEqualTo = lessThanOrEqualTo;
      result$data['lessThanOrEqualTo'] = l$lessThanOrEqualTo;
    }
    if (_$data.containsKey('notDistinctFrom')) {
      final l$notDistinctFrom = notDistinctFrom;
      result$data['notDistinctFrom'] = l$notDistinctFrom;
    }
    if (_$data.containsKey('notEqualTo')) {
      final l$notEqualTo = notEqualTo;
      result$data['notEqualTo'] = l$notEqualTo;
    }
    if (_$data.containsKey('notEqualToAll')) {
      final l$notEqualToAll = notEqualToAll;
      result$data['notEqualToAll'] = l$notEqualToAll?.map((e) => e).toList();
    }
    if (_$data.containsKey('notEqualToAny')) {
      final l$notEqualToAny = notEqualToAny;
      result$data['notEqualToAny'] = l$notEqualToAny?.map((e) => e).toList();
    }
    if (_$data.containsKey('notIn')) {
      final l$notIn = notIn;
      result$data['notIn'] = l$notIn?.map((e) => e).toList();
    }
    return result$data;
  }

  CopyWith$Input$FloatFilterInput<Input$FloatFilterInput> get copyWith =>
      CopyWith$Input$FloatFilterInput(
        this,
        (i) => i,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$FloatFilterInput || runtimeType != other.runtimeType) {
      return false;
    }
    final l$distinctFrom = distinctFrom;
    final lOther$distinctFrom = other.distinctFrom;
    if (_$data.containsKey('distinctFrom') !=
        other._$data.containsKey('distinctFrom')) {
      return false;
    }
    if (l$distinctFrom != lOther$distinctFrom) {
      return false;
    }
    final l$distinctFromAll = distinctFromAll;
    final lOther$distinctFromAll = other.distinctFromAll;
    if (_$data.containsKey('distinctFromAll') !=
        other._$data.containsKey('distinctFromAll')) {
      return false;
    }
    if (l$distinctFromAll != null && lOther$distinctFromAll != null) {
      if (l$distinctFromAll.length != lOther$distinctFromAll.length) {
        return false;
      }
      for (int i = 0; i < l$distinctFromAll.length; i++) {
        final l$distinctFromAll$entry = l$distinctFromAll[i];
        final lOther$distinctFromAll$entry = lOther$distinctFromAll[i];
        if (l$distinctFromAll$entry != lOther$distinctFromAll$entry) {
          return false;
        }
      }
    } else if (l$distinctFromAll != lOther$distinctFromAll) {
      return false;
    }
    final l$distinctFromAny = distinctFromAny;
    final lOther$distinctFromAny = other.distinctFromAny;
    if (_$data.containsKey('distinctFromAny') !=
        other._$data.containsKey('distinctFromAny')) {
      return false;
    }
    if (l$distinctFromAny != null && lOther$distinctFromAny != null) {
      if (l$distinctFromAny.length != lOther$distinctFromAny.length) {
        return false;
      }
      for (int i = 0; i < l$distinctFromAny.length; i++) {
        final l$distinctFromAny$entry = l$distinctFromAny[i];
        final lOther$distinctFromAny$entry = lOther$distinctFromAny[i];
        if (l$distinctFromAny$entry != lOther$distinctFromAny$entry) {
          return false;
        }
      }
    } else if (l$distinctFromAny != lOther$distinctFromAny) {
      return false;
    }
    final l$equalTo = equalTo;
    final lOther$equalTo = other.equalTo;
    if (_$data.containsKey('equalTo') != other._$data.containsKey('equalTo')) {
      return false;
    }
    if (l$equalTo != lOther$equalTo) {
      return false;
    }
    final l$greaterThan = greaterThan;
    final lOther$greaterThan = other.greaterThan;
    if (_$data.containsKey('greaterThan') !=
        other._$data.containsKey('greaterThan')) {
      return false;
    }
    if (l$greaterThan != lOther$greaterThan) {
      return false;
    }
    final l$greaterThanOrEqualTo = greaterThanOrEqualTo;
    final lOther$greaterThanOrEqualTo = other.greaterThanOrEqualTo;
    if (_$data.containsKey('greaterThanOrEqualTo') !=
        other._$data.containsKey('greaterThanOrEqualTo')) {
      return false;
    }
    if (l$greaterThanOrEqualTo != lOther$greaterThanOrEqualTo) {
      return false;
    }
    final l$$in = $in;
    final lOther$$in = other.$in;
    if (_$data.containsKey('in') != other._$data.containsKey('in')) {
      return false;
    }
    if (l$$in != null && lOther$$in != null) {
      if (l$$in.length != lOther$$in.length) {
        return false;
      }
      for (int i = 0; i < l$$in.length; i++) {
        final l$$in$entry = l$$in[i];
        final lOther$$in$entry = lOther$$in[i];
        if (l$$in$entry != lOther$$in$entry) {
          return false;
        }
      }
    } else if (l$$in != lOther$$in) {
      return false;
    }
    final l$isNull = isNull;
    final lOther$isNull = other.isNull;
    if (_$data.containsKey('isNull') != other._$data.containsKey('isNull')) {
      return false;
    }
    if (l$isNull != lOther$isNull) {
      return false;
    }
    final l$lessThan = lessThan;
    final lOther$lessThan = other.lessThan;
    if (_$data.containsKey('lessThan') !=
        other._$data.containsKey('lessThan')) {
      return false;
    }
    if (l$lessThan != lOther$lessThan) {
      return false;
    }
    final l$lessThanOrEqualTo = lessThanOrEqualTo;
    final lOther$lessThanOrEqualTo = other.lessThanOrEqualTo;
    if (_$data.containsKey('lessThanOrEqualTo') !=
        other._$data.containsKey('lessThanOrEqualTo')) {
      return false;
    }
    if (l$lessThanOrEqualTo != lOther$lessThanOrEqualTo) {
      return false;
    }
    final l$notDistinctFrom = notDistinctFrom;
    final lOther$notDistinctFrom = other.notDistinctFrom;
    if (_$data.containsKey('notDistinctFrom') !=
        other._$data.containsKey('notDistinctFrom')) {
      return false;
    }
    if (l$notDistinctFrom != lOther$notDistinctFrom) {
      return false;
    }
    final l$notEqualTo = notEqualTo;
    final lOther$notEqualTo = other.notEqualTo;
    if (_$data.containsKey('notEqualTo') !=
        other._$data.containsKey('notEqualTo')) {
      return false;
    }
    if (l$notEqualTo != lOther$notEqualTo) {
      return false;
    }
    final l$notEqualToAll = notEqualToAll;
    final lOther$notEqualToAll = other.notEqualToAll;
    if (_$data.containsKey('notEqualToAll') !=
        other._$data.containsKey('notEqualToAll')) {
      return false;
    }
    if (l$notEqualToAll != null && lOther$notEqualToAll != null) {
      if (l$notEqualToAll.length != lOther$notEqualToAll.length) {
        return false;
      }
      for (int i = 0; i < l$notEqualToAll.length; i++) {
        final l$notEqualToAll$entry = l$notEqualToAll[i];
        final lOther$notEqualToAll$entry = lOther$notEqualToAll[i];
        if (l$notEqualToAll$entry != lOther$notEqualToAll$entry) {
          return false;
        }
      }
    } else if (l$notEqualToAll != lOther$notEqualToAll) {
      return false;
    }
    final l$notEqualToAny = notEqualToAny;
    final lOther$notEqualToAny = other.notEqualToAny;
    if (_$data.containsKey('notEqualToAny') !=
        other._$data.containsKey('notEqualToAny')) {
      return false;
    }
    if (l$notEqualToAny != null && lOther$notEqualToAny != null) {
      if (l$notEqualToAny.length != lOther$notEqualToAny.length) {
        return false;
      }
      for (int i = 0; i < l$notEqualToAny.length; i++) {
        final l$notEqualToAny$entry = l$notEqualToAny[i];
        final lOther$notEqualToAny$entry = lOther$notEqualToAny[i];
        if (l$notEqualToAny$entry != lOther$notEqualToAny$entry) {
          return false;
        }
      }
    } else if (l$notEqualToAny != lOther$notEqualToAny) {
      return false;
    }
    final l$notIn = notIn;
    final lOther$notIn = other.notIn;
    if (_$data.containsKey('notIn') != other._$data.containsKey('notIn')) {
      return false;
    }
    if (l$notIn != null && lOther$notIn != null) {
      if (l$notIn.length != lOther$notIn.length) {
        return false;
      }
      for (int i = 0; i < l$notIn.length; i++) {
        final l$notIn$entry = l$notIn[i];
        final lOther$notIn$entry = lOther$notIn[i];
        if (l$notIn$entry != lOther$notIn$entry) {
          return false;
        }
      }
    } else if (l$notIn != lOther$notIn) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$distinctFrom = distinctFrom;
    final l$distinctFromAll = distinctFromAll;
    final l$distinctFromAny = distinctFromAny;
    final l$equalTo = equalTo;
    final l$greaterThan = greaterThan;
    final l$greaterThanOrEqualTo = greaterThanOrEqualTo;
    final l$$in = $in;
    final l$isNull = isNull;
    final l$lessThan = lessThan;
    final l$lessThanOrEqualTo = lessThanOrEqualTo;
    final l$notDistinctFrom = notDistinctFrom;
    final l$notEqualTo = notEqualTo;
    final l$notEqualToAll = notEqualToAll;
    final l$notEqualToAny = notEqualToAny;
    final l$notIn = notIn;
    return Object.hashAll([
      _$data.containsKey('distinctFrom') ? l$distinctFrom : const {},
      _$data.containsKey('distinctFromAll')
          ? l$distinctFromAll == null
              ? null
              : Object.hashAll(l$distinctFromAll.map((v) => v))
          : const {},
      _$data.containsKey('distinctFromAny')
          ? l$distinctFromAny == null
              ? null
              : Object.hashAll(l$distinctFromAny.map((v) => v))
          : const {},
      _$data.containsKey('equalTo') ? l$equalTo : const {},
      _$data.containsKey('greaterThan') ? l$greaterThan : const {},
      _$data.containsKey('greaterThanOrEqualTo')
          ? l$greaterThanOrEqualTo
          : const {},
      _$data.containsKey('in')
          ? l$$in == null
              ? null
              : Object.hashAll(l$$in.map((v) => v))
          : const {},
      _$data.containsKey('isNull') ? l$isNull : const {},
      _$data.containsKey('lessThan') ? l$lessThan : const {},
      _$data.containsKey('lessThanOrEqualTo') ? l$lessThanOrEqualTo : const {},
      _$data.containsKey('notDistinctFrom') ? l$notDistinctFrom : const {},
      _$data.containsKey('notEqualTo') ? l$notEqualTo : const {},
      _$data.containsKey('notEqualToAll')
          ? l$notEqualToAll == null
              ? null
              : Object.hashAll(l$notEqualToAll.map((v) => v))
          : const {},
      _$data.containsKey('notEqualToAny')
          ? l$notEqualToAny == null
              ? null
              : Object.hashAll(l$notEqualToAny.map((v) => v))
          : const {},
      _$data.containsKey('notIn')
          ? l$notIn == null
              ? null
              : Object.hashAll(l$notIn.map((v) => v))
          : const {},
    ]);
  }
}

abstract class CopyWith$Input$FloatFilterInput<TRes> {
  factory CopyWith$Input$FloatFilterInput(
    Input$FloatFilterInput instance,
    TRes Function(Input$FloatFilterInput) then,
  ) = _CopyWithImpl$Input$FloatFilterInput;

  factory CopyWith$Input$FloatFilterInput.stub(TRes res) =
      _CopyWithStubImpl$Input$FloatFilterInput;

  TRes call({
    double? distinctFrom,
    List<double>? distinctFromAll,
    List<double>? distinctFromAny,
    double? equalTo,
    double? greaterThan,
    double? greaterThanOrEqualTo,
    List<double>? $in,
    bool? isNull,
    double? lessThan,
    double? lessThanOrEqualTo,
    double? notDistinctFrom,
    double? notEqualTo,
    List<double>? notEqualToAll,
    List<double>? notEqualToAny,
    List<double>? notIn,
  });
}

class _CopyWithImpl$Input$FloatFilterInput<TRes>
    implements CopyWith$Input$FloatFilterInput<TRes> {
  _CopyWithImpl$Input$FloatFilterInput(
    this._instance,
    this._then,
  );

  final Input$FloatFilterInput _instance;

  final TRes Function(Input$FloatFilterInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? distinctFrom = _undefined,
    Object? distinctFromAll = _undefined,
    Object? distinctFromAny = _undefined,
    Object? equalTo = _undefined,
    Object? greaterThan = _undefined,
    Object? greaterThanOrEqualTo = _undefined,
    Object? $in = _undefined,
    Object? isNull = _undefined,
    Object? lessThan = _undefined,
    Object? lessThanOrEqualTo = _undefined,
    Object? notDistinctFrom = _undefined,
    Object? notEqualTo = _undefined,
    Object? notEqualToAll = _undefined,
    Object? notEqualToAny = _undefined,
    Object? notIn = _undefined,
  }) =>
      _then(Input$FloatFilterInput._({
        ..._instance._$data,
        if (distinctFrom != _undefined)
          'distinctFrom': (distinctFrom as double?),
        if (distinctFromAll != _undefined)
          'distinctFromAll': (distinctFromAll as List<double>?),
        if (distinctFromAny != _undefined)
          'distinctFromAny': (distinctFromAny as List<double>?),
        if (equalTo != _undefined) 'equalTo': (equalTo as double?),
        if (greaterThan != _undefined) 'greaterThan': (greaterThan as double?),
        if (greaterThanOrEqualTo != _undefined)
          'greaterThanOrEqualTo': (greaterThanOrEqualTo as double?),
        if ($in != _undefined) 'in': ($in as List<double>?),
        if (isNull != _undefined) 'isNull': (isNull as bool?),
        if (lessThan != _undefined) 'lessThan': (lessThan as double?),
        if (lessThanOrEqualTo != _undefined)
          'lessThanOrEqualTo': (lessThanOrEqualTo as double?),
        if (notDistinctFrom != _undefined)
          'notDistinctFrom': (notDistinctFrom as double?),
        if (notEqualTo != _undefined) 'notEqualTo': (notEqualTo as double?),
        if (notEqualToAll != _undefined)
          'notEqualToAll': (notEqualToAll as List<double>?),
        if (notEqualToAny != _undefined)
          'notEqualToAny': (notEqualToAny as List<double>?),
        if (notIn != _undefined) 'notIn': (notIn as List<double>?),
      }));
}

class _CopyWithStubImpl$Input$FloatFilterInput<TRes>
    implements CopyWith$Input$FloatFilterInput<TRes> {
  _CopyWithStubImpl$Input$FloatFilterInput(this._res);

  TRes _res;

  call({
    double? distinctFrom,
    List<double>? distinctFromAll,
    List<double>? distinctFromAny,
    double? equalTo,
    double? greaterThan,
    double? greaterThanOrEqualTo,
    List<double>? $in,
    bool? isNull,
    double? lessThan,
    double? lessThanOrEqualTo,
    double? notDistinctFrom,
    double? notEqualTo,
    List<double>? notEqualToAll,
    List<double>? notEqualToAny,
    List<double>? notIn,
  }) =>
      _res;
}

class Input$GlobalMetaTypeInput {
  factory Input$GlobalMetaTypeInput({
    required String key,
    required String value,
  }) =>
      Input$GlobalMetaTypeInput._({
        r'key': key,
        r'value': value,
      });

  Input$GlobalMetaTypeInput._(this._$data);

  factory Input$GlobalMetaTypeInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$key = data['key'];
    result$data['key'] = (l$key as String);
    final l$value = data['value'];
    result$data['value'] = (l$value as String);
    return Input$GlobalMetaTypeInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String get key => (_$data['key'] as String);

  String get value => (_$data['value'] as String);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$key = key;
    result$data['key'] = l$key;
    final l$value = value;
    result$data['value'] = l$value;
    return result$data;
  }

  CopyWith$Input$GlobalMetaTypeInput<Input$GlobalMetaTypeInput> get copyWith =>
      CopyWith$Input$GlobalMetaTypeInput(
        this,
        (i) => i,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$GlobalMetaTypeInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$key = key;
    final lOther$key = other.key;
    if (l$key != lOther$key) {
      return false;
    }
    final l$value = value;
    final lOther$value = other.value;
    if (l$value != lOther$value) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$key = key;
    final l$value = value;
    return Object.hashAll([
      l$key,
      l$value,
    ]);
  }
}

abstract class CopyWith$Input$GlobalMetaTypeInput<TRes> {
  factory CopyWith$Input$GlobalMetaTypeInput(
    Input$GlobalMetaTypeInput instance,
    TRes Function(Input$GlobalMetaTypeInput) then,
  ) = _CopyWithImpl$Input$GlobalMetaTypeInput;

  factory CopyWith$Input$GlobalMetaTypeInput.stub(TRes res) =
      _CopyWithStubImpl$Input$GlobalMetaTypeInput;

  TRes call({
    String? key,
    String? value,
  });
}

class _CopyWithImpl$Input$GlobalMetaTypeInput<TRes>
    implements CopyWith$Input$GlobalMetaTypeInput<TRes> {
  _CopyWithImpl$Input$GlobalMetaTypeInput(
    this._instance,
    this._then,
  );

  final Input$GlobalMetaTypeInput _instance;

  final TRes Function(Input$GlobalMetaTypeInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? key = _undefined,
    Object? value = _undefined,
  }) =>
      _then(Input$GlobalMetaTypeInput._({
        ..._instance._$data,
        if (key != _undefined && key != null) 'key': (key as String),
        if (value != _undefined && value != null) 'value': (value as String),
      }));
}

class _CopyWithStubImpl$Input$GlobalMetaTypeInput<TRes>
    implements CopyWith$Input$GlobalMetaTypeInput<TRes> {
  _CopyWithStubImpl$Input$GlobalMetaTypeInput(this._res);

  TRes _res;

  call({
    String? key,
    String? value,
  }) =>
      _res;
}

class Input$InstallExternalExtensionInput {
  factory Input$InstallExternalExtensionInput({
    String? clientMutationId,
    required MultipartFile extensionFile,
  }) =>
      Input$InstallExternalExtensionInput._({
        if (clientMutationId != null) r'clientMutationId': clientMutationId,
        r'extensionFile': extensionFile,
      });

  Input$InstallExternalExtensionInput._(this._$data);

  factory Input$InstallExternalExtensionInput.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('clientMutationId')) {
      final l$clientMutationId = data['clientMutationId'];
      result$data['clientMutationId'] = (l$clientMutationId as String?);
    }
    final l$extensionFile = data['extensionFile'];
    result$data['extensionFile'] = fileFromJson(l$extensionFile);
    return Input$InstallExternalExtensionInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get clientMutationId => (_$data['clientMutationId'] as String?);

  MultipartFile get extensionFile => (_$data['extensionFile'] as MultipartFile);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('clientMutationId')) {
      final l$clientMutationId = clientMutationId;
      result$data['clientMutationId'] = l$clientMutationId;
    }
    final l$extensionFile = extensionFile;
    result$data['extensionFile'] = fileToJson(l$extensionFile);
    return result$data;
  }

  CopyWith$Input$InstallExternalExtensionInput<
          Input$InstallExternalExtensionInput>
      get copyWith => CopyWith$Input$InstallExternalExtensionInput(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$InstallExternalExtensionInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (_$data.containsKey('clientMutationId') !=
        other._$data.containsKey('clientMutationId')) {
      return false;
    }
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    final l$extensionFile = extensionFile;
    final lOther$extensionFile = other.extensionFile;
    if (l$extensionFile != lOther$extensionFile) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$clientMutationId = clientMutationId;
    final l$extensionFile = extensionFile;
    return Object.hashAll([
      _$data.containsKey('clientMutationId') ? l$clientMutationId : const {},
      l$extensionFile,
    ]);
  }
}

abstract class CopyWith$Input$InstallExternalExtensionInput<TRes> {
  factory CopyWith$Input$InstallExternalExtensionInput(
    Input$InstallExternalExtensionInput instance,
    TRes Function(Input$InstallExternalExtensionInput) then,
  ) = _CopyWithImpl$Input$InstallExternalExtensionInput;

  factory CopyWith$Input$InstallExternalExtensionInput.stub(TRes res) =
      _CopyWithStubImpl$Input$InstallExternalExtensionInput;

  TRes call({
    String? clientMutationId,
    MultipartFile? extensionFile,
  });
}

class _CopyWithImpl$Input$InstallExternalExtensionInput<TRes>
    implements CopyWith$Input$InstallExternalExtensionInput<TRes> {
  _CopyWithImpl$Input$InstallExternalExtensionInput(
    this._instance,
    this._then,
  );

  final Input$InstallExternalExtensionInput _instance;

  final TRes Function(Input$InstallExternalExtensionInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? clientMutationId = _undefined,
    Object? extensionFile = _undefined,
  }) =>
      _then(Input$InstallExternalExtensionInput._({
        ..._instance._$data,
        if (clientMutationId != _undefined)
          'clientMutationId': (clientMutationId as String?),
        if (extensionFile != _undefined && extensionFile != null)
          'extensionFile': (extensionFile as MultipartFile),
      }));
}

class _CopyWithStubImpl$Input$InstallExternalExtensionInput<TRes>
    implements CopyWith$Input$InstallExternalExtensionInput<TRes> {
  _CopyWithStubImpl$Input$InstallExternalExtensionInput(this._res);

  TRes _res;

  call({
    String? clientMutationId,
    MultipartFile? extensionFile,
  }) =>
      _res;
}

class Input$IntFilterInput {
  factory Input$IntFilterInput({
    int? distinctFrom,
    List<int>? distinctFromAll,
    List<int>? distinctFromAny,
    int? equalTo,
    int? greaterThan,
    int? greaterThanOrEqualTo,
    List<int>? $in,
    bool? isNull,
    int? lessThan,
    int? lessThanOrEqualTo,
    int? notDistinctFrom,
    int? notEqualTo,
    List<int>? notEqualToAll,
    List<int>? notEqualToAny,
    List<int>? notIn,
  }) =>
      Input$IntFilterInput._({
        if (distinctFrom != null) r'distinctFrom': distinctFrom,
        if (distinctFromAll != null) r'distinctFromAll': distinctFromAll,
        if (distinctFromAny != null) r'distinctFromAny': distinctFromAny,
        if (equalTo != null) r'equalTo': equalTo,
        if (greaterThan != null) r'greaterThan': greaterThan,
        if (greaterThanOrEqualTo != null)
          r'greaterThanOrEqualTo': greaterThanOrEqualTo,
        if ($in != null) r'in': $in,
        if (isNull != null) r'isNull': isNull,
        if (lessThan != null) r'lessThan': lessThan,
        if (lessThanOrEqualTo != null) r'lessThanOrEqualTo': lessThanOrEqualTo,
        if (notDistinctFrom != null) r'notDistinctFrom': notDistinctFrom,
        if (notEqualTo != null) r'notEqualTo': notEqualTo,
        if (notEqualToAll != null) r'notEqualToAll': notEqualToAll,
        if (notEqualToAny != null) r'notEqualToAny': notEqualToAny,
        if (notIn != null) r'notIn': notIn,
      });

  Input$IntFilterInput._(this._$data);

  factory Input$IntFilterInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('distinctFrom')) {
      final l$distinctFrom = data['distinctFrom'];
      result$data['distinctFrom'] = (l$distinctFrom as int?);
    }
    if (data.containsKey('distinctFromAll')) {
      final l$distinctFromAll = data['distinctFromAll'];
      result$data['distinctFromAll'] = (l$distinctFromAll as List<dynamic>?)
          ?.map((e) => (e as int))
          .toList();
    }
    if (data.containsKey('distinctFromAny')) {
      final l$distinctFromAny = data['distinctFromAny'];
      result$data['distinctFromAny'] = (l$distinctFromAny as List<dynamic>?)
          ?.map((e) => (e as int))
          .toList();
    }
    if (data.containsKey('equalTo')) {
      final l$equalTo = data['equalTo'];
      result$data['equalTo'] = (l$equalTo as int?);
    }
    if (data.containsKey('greaterThan')) {
      final l$greaterThan = data['greaterThan'];
      result$data['greaterThan'] = (l$greaterThan as int?);
    }
    if (data.containsKey('greaterThanOrEqualTo')) {
      final l$greaterThanOrEqualTo = data['greaterThanOrEqualTo'];
      result$data['greaterThanOrEqualTo'] = (l$greaterThanOrEqualTo as int?);
    }
    if (data.containsKey('in')) {
      final l$$in = data['in'];
      result$data['in'] =
          (l$$in as List<dynamic>?)?.map((e) => (e as int)).toList();
    }
    if (data.containsKey('isNull')) {
      final l$isNull = data['isNull'];
      result$data['isNull'] = (l$isNull as bool?);
    }
    if (data.containsKey('lessThan')) {
      final l$lessThan = data['lessThan'];
      result$data['lessThan'] = (l$lessThan as int?);
    }
    if (data.containsKey('lessThanOrEqualTo')) {
      final l$lessThanOrEqualTo = data['lessThanOrEqualTo'];
      result$data['lessThanOrEqualTo'] = (l$lessThanOrEqualTo as int?);
    }
    if (data.containsKey('notDistinctFrom')) {
      final l$notDistinctFrom = data['notDistinctFrom'];
      result$data['notDistinctFrom'] = (l$notDistinctFrom as int?);
    }
    if (data.containsKey('notEqualTo')) {
      final l$notEqualTo = data['notEqualTo'];
      result$data['notEqualTo'] = (l$notEqualTo as int?);
    }
    if (data.containsKey('notEqualToAll')) {
      final l$notEqualToAll = data['notEqualToAll'];
      result$data['notEqualToAll'] =
          (l$notEqualToAll as List<dynamic>?)?.map((e) => (e as int)).toList();
    }
    if (data.containsKey('notEqualToAny')) {
      final l$notEqualToAny = data['notEqualToAny'];
      result$data['notEqualToAny'] =
          (l$notEqualToAny as List<dynamic>?)?.map((e) => (e as int)).toList();
    }
    if (data.containsKey('notIn')) {
      final l$notIn = data['notIn'];
      result$data['notIn'] =
          (l$notIn as List<dynamic>?)?.map((e) => (e as int)).toList();
    }
    return Input$IntFilterInput._(result$data);
  }

  Map<String, dynamic> _$data;

  int? get distinctFrom => (_$data['distinctFrom'] as int?);

  List<int>? get distinctFromAll => (_$data['distinctFromAll'] as List<int>?);

  List<int>? get distinctFromAny => (_$data['distinctFromAny'] as List<int>?);

  int? get equalTo => (_$data['equalTo'] as int?);

  int? get greaterThan => (_$data['greaterThan'] as int?);

  int? get greaterThanOrEqualTo => (_$data['greaterThanOrEqualTo'] as int?);

  List<int>? get $in => (_$data['in'] as List<int>?);

  bool? get isNull => (_$data['isNull'] as bool?);

  int? get lessThan => (_$data['lessThan'] as int?);

  int? get lessThanOrEqualTo => (_$data['lessThanOrEqualTo'] as int?);

  int? get notDistinctFrom => (_$data['notDistinctFrom'] as int?);

  int? get notEqualTo => (_$data['notEqualTo'] as int?);

  List<int>? get notEqualToAll => (_$data['notEqualToAll'] as List<int>?);

  List<int>? get notEqualToAny => (_$data['notEqualToAny'] as List<int>?);

  List<int>? get notIn => (_$data['notIn'] as List<int>?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('distinctFrom')) {
      final l$distinctFrom = distinctFrom;
      result$data['distinctFrom'] = l$distinctFrom;
    }
    if (_$data.containsKey('distinctFromAll')) {
      final l$distinctFromAll = distinctFromAll;
      result$data['distinctFromAll'] =
          l$distinctFromAll?.map((e) => e).toList();
    }
    if (_$data.containsKey('distinctFromAny')) {
      final l$distinctFromAny = distinctFromAny;
      result$data['distinctFromAny'] =
          l$distinctFromAny?.map((e) => e).toList();
    }
    if (_$data.containsKey('equalTo')) {
      final l$equalTo = equalTo;
      result$data['equalTo'] = l$equalTo;
    }
    if (_$data.containsKey('greaterThan')) {
      final l$greaterThan = greaterThan;
      result$data['greaterThan'] = l$greaterThan;
    }
    if (_$data.containsKey('greaterThanOrEqualTo')) {
      final l$greaterThanOrEqualTo = greaterThanOrEqualTo;
      result$data['greaterThanOrEqualTo'] = l$greaterThanOrEqualTo;
    }
    if (_$data.containsKey('in')) {
      final l$$in = $in;
      result$data['in'] = l$$in?.map((e) => e).toList();
    }
    if (_$data.containsKey('isNull')) {
      final l$isNull = isNull;
      result$data['isNull'] = l$isNull;
    }
    if (_$data.containsKey('lessThan')) {
      final l$lessThan = lessThan;
      result$data['lessThan'] = l$lessThan;
    }
    if (_$data.containsKey('lessThanOrEqualTo')) {
      final l$lessThanOrEqualTo = lessThanOrEqualTo;
      result$data['lessThanOrEqualTo'] = l$lessThanOrEqualTo;
    }
    if (_$data.containsKey('notDistinctFrom')) {
      final l$notDistinctFrom = notDistinctFrom;
      result$data['notDistinctFrom'] = l$notDistinctFrom;
    }
    if (_$data.containsKey('notEqualTo')) {
      final l$notEqualTo = notEqualTo;
      result$data['notEqualTo'] = l$notEqualTo;
    }
    if (_$data.containsKey('notEqualToAll')) {
      final l$notEqualToAll = notEqualToAll;
      result$data['notEqualToAll'] = l$notEqualToAll?.map((e) => e).toList();
    }
    if (_$data.containsKey('notEqualToAny')) {
      final l$notEqualToAny = notEqualToAny;
      result$data['notEqualToAny'] = l$notEqualToAny?.map((e) => e).toList();
    }
    if (_$data.containsKey('notIn')) {
      final l$notIn = notIn;
      result$data['notIn'] = l$notIn?.map((e) => e).toList();
    }
    return result$data;
  }

  CopyWith$Input$IntFilterInput<Input$IntFilterInput> get copyWith =>
      CopyWith$Input$IntFilterInput(
        this,
        (i) => i,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$IntFilterInput || runtimeType != other.runtimeType) {
      return false;
    }
    final l$distinctFrom = distinctFrom;
    final lOther$distinctFrom = other.distinctFrom;
    if (_$data.containsKey('distinctFrom') !=
        other._$data.containsKey('distinctFrom')) {
      return false;
    }
    if (l$distinctFrom != lOther$distinctFrom) {
      return false;
    }
    final l$distinctFromAll = distinctFromAll;
    final lOther$distinctFromAll = other.distinctFromAll;
    if (_$data.containsKey('distinctFromAll') !=
        other._$data.containsKey('distinctFromAll')) {
      return false;
    }
    if (l$distinctFromAll != null && lOther$distinctFromAll != null) {
      if (l$distinctFromAll.length != lOther$distinctFromAll.length) {
        return false;
      }
      for (int i = 0; i < l$distinctFromAll.length; i++) {
        final l$distinctFromAll$entry = l$distinctFromAll[i];
        final lOther$distinctFromAll$entry = lOther$distinctFromAll[i];
        if (l$distinctFromAll$entry != lOther$distinctFromAll$entry) {
          return false;
        }
      }
    } else if (l$distinctFromAll != lOther$distinctFromAll) {
      return false;
    }
    final l$distinctFromAny = distinctFromAny;
    final lOther$distinctFromAny = other.distinctFromAny;
    if (_$data.containsKey('distinctFromAny') !=
        other._$data.containsKey('distinctFromAny')) {
      return false;
    }
    if (l$distinctFromAny != null && lOther$distinctFromAny != null) {
      if (l$distinctFromAny.length != lOther$distinctFromAny.length) {
        return false;
      }
      for (int i = 0; i < l$distinctFromAny.length; i++) {
        final l$distinctFromAny$entry = l$distinctFromAny[i];
        final lOther$distinctFromAny$entry = lOther$distinctFromAny[i];
        if (l$distinctFromAny$entry != lOther$distinctFromAny$entry) {
          return false;
        }
      }
    } else if (l$distinctFromAny != lOther$distinctFromAny) {
      return false;
    }
    final l$equalTo = equalTo;
    final lOther$equalTo = other.equalTo;
    if (_$data.containsKey('equalTo') != other._$data.containsKey('equalTo')) {
      return false;
    }
    if (l$equalTo != lOther$equalTo) {
      return false;
    }
    final l$greaterThan = greaterThan;
    final lOther$greaterThan = other.greaterThan;
    if (_$data.containsKey('greaterThan') !=
        other._$data.containsKey('greaterThan')) {
      return false;
    }
    if (l$greaterThan != lOther$greaterThan) {
      return false;
    }
    final l$greaterThanOrEqualTo = greaterThanOrEqualTo;
    final lOther$greaterThanOrEqualTo = other.greaterThanOrEqualTo;
    if (_$data.containsKey('greaterThanOrEqualTo') !=
        other._$data.containsKey('greaterThanOrEqualTo')) {
      return false;
    }
    if (l$greaterThanOrEqualTo != lOther$greaterThanOrEqualTo) {
      return false;
    }
    final l$$in = $in;
    final lOther$$in = other.$in;
    if (_$data.containsKey('in') != other._$data.containsKey('in')) {
      return false;
    }
    if (l$$in != null && lOther$$in != null) {
      if (l$$in.length != lOther$$in.length) {
        return false;
      }
      for (int i = 0; i < l$$in.length; i++) {
        final l$$in$entry = l$$in[i];
        final lOther$$in$entry = lOther$$in[i];
        if (l$$in$entry != lOther$$in$entry) {
          return false;
        }
      }
    } else if (l$$in != lOther$$in) {
      return false;
    }
    final l$isNull = isNull;
    final lOther$isNull = other.isNull;
    if (_$data.containsKey('isNull') != other._$data.containsKey('isNull')) {
      return false;
    }
    if (l$isNull != lOther$isNull) {
      return false;
    }
    final l$lessThan = lessThan;
    final lOther$lessThan = other.lessThan;
    if (_$data.containsKey('lessThan') !=
        other._$data.containsKey('lessThan')) {
      return false;
    }
    if (l$lessThan != lOther$lessThan) {
      return false;
    }
    final l$lessThanOrEqualTo = lessThanOrEqualTo;
    final lOther$lessThanOrEqualTo = other.lessThanOrEqualTo;
    if (_$data.containsKey('lessThanOrEqualTo') !=
        other._$data.containsKey('lessThanOrEqualTo')) {
      return false;
    }
    if (l$lessThanOrEqualTo != lOther$lessThanOrEqualTo) {
      return false;
    }
    final l$notDistinctFrom = notDistinctFrom;
    final lOther$notDistinctFrom = other.notDistinctFrom;
    if (_$data.containsKey('notDistinctFrom') !=
        other._$data.containsKey('notDistinctFrom')) {
      return false;
    }
    if (l$notDistinctFrom != lOther$notDistinctFrom) {
      return false;
    }
    final l$notEqualTo = notEqualTo;
    final lOther$notEqualTo = other.notEqualTo;
    if (_$data.containsKey('notEqualTo') !=
        other._$data.containsKey('notEqualTo')) {
      return false;
    }
    if (l$notEqualTo != lOther$notEqualTo) {
      return false;
    }
    final l$notEqualToAll = notEqualToAll;
    final lOther$notEqualToAll = other.notEqualToAll;
    if (_$data.containsKey('notEqualToAll') !=
        other._$data.containsKey('notEqualToAll')) {
      return false;
    }
    if (l$notEqualToAll != null && lOther$notEqualToAll != null) {
      if (l$notEqualToAll.length != lOther$notEqualToAll.length) {
        return false;
      }
      for (int i = 0; i < l$notEqualToAll.length; i++) {
        final l$notEqualToAll$entry = l$notEqualToAll[i];
        final lOther$notEqualToAll$entry = lOther$notEqualToAll[i];
        if (l$notEqualToAll$entry != lOther$notEqualToAll$entry) {
          return false;
        }
      }
    } else if (l$notEqualToAll != lOther$notEqualToAll) {
      return false;
    }
    final l$notEqualToAny = notEqualToAny;
    final lOther$notEqualToAny = other.notEqualToAny;
    if (_$data.containsKey('notEqualToAny') !=
        other._$data.containsKey('notEqualToAny')) {
      return false;
    }
    if (l$notEqualToAny != null && lOther$notEqualToAny != null) {
      if (l$notEqualToAny.length != lOther$notEqualToAny.length) {
        return false;
      }
      for (int i = 0; i < l$notEqualToAny.length; i++) {
        final l$notEqualToAny$entry = l$notEqualToAny[i];
        final lOther$notEqualToAny$entry = lOther$notEqualToAny[i];
        if (l$notEqualToAny$entry != lOther$notEqualToAny$entry) {
          return false;
        }
      }
    } else if (l$notEqualToAny != lOther$notEqualToAny) {
      return false;
    }
    final l$notIn = notIn;
    final lOther$notIn = other.notIn;
    if (_$data.containsKey('notIn') != other._$data.containsKey('notIn')) {
      return false;
    }
    if (l$notIn != null && lOther$notIn != null) {
      if (l$notIn.length != lOther$notIn.length) {
        return false;
      }
      for (int i = 0; i < l$notIn.length; i++) {
        final l$notIn$entry = l$notIn[i];
        final lOther$notIn$entry = lOther$notIn[i];
        if (l$notIn$entry != lOther$notIn$entry) {
          return false;
        }
      }
    } else if (l$notIn != lOther$notIn) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$distinctFrom = distinctFrom;
    final l$distinctFromAll = distinctFromAll;
    final l$distinctFromAny = distinctFromAny;
    final l$equalTo = equalTo;
    final l$greaterThan = greaterThan;
    final l$greaterThanOrEqualTo = greaterThanOrEqualTo;
    final l$$in = $in;
    final l$isNull = isNull;
    final l$lessThan = lessThan;
    final l$lessThanOrEqualTo = lessThanOrEqualTo;
    final l$notDistinctFrom = notDistinctFrom;
    final l$notEqualTo = notEqualTo;
    final l$notEqualToAll = notEqualToAll;
    final l$notEqualToAny = notEqualToAny;
    final l$notIn = notIn;
    return Object.hashAll([
      _$data.containsKey('distinctFrom') ? l$distinctFrom : const {},
      _$data.containsKey('distinctFromAll')
          ? l$distinctFromAll == null
              ? null
              : Object.hashAll(l$distinctFromAll.map((v) => v))
          : const {},
      _$data.containsKey('distinctFromAny')
          ? l$distinctFromAny == null
              ? null
              : Object.hashAll(l$distinctFromAny.map((v) => v))
          : const {},
      _$data.containsKey('equalTo') ? l$equalTo : const {},
      _$data.containsKey('greaterThan') ? l$greaterThan : const {},
      _$data.containsKey('greaterThanOrEqualTo')
          ? l$greaterThanOrEqualTo
          : const {},
      _$data.containsKey('in')
          ? l$$in == null
              ? null
              : Object.hashAll(l$$in.map((v) => v))
          : const {},
      _$data.containsKey('isNull') ? l$isNull : const {},
      _$data.containsKey('lessThan') ? l$lessThan : const {},
      _$data.containsKey('lessThanOrEqualTo') ? l$lessThanOrEqualTo : const {},
      _$data.containsKey('notDistinctFrom') ? l$notDistinctFrom : const {},
      _$data.containsKey('notEqualTo') ? l$notEqualTo : const {},
      _$data.containsKey('notEqualToAll')
          ? l$notEqualToAll == null
              ? null
              : Object.hashAll(l$notEqualToAll.map((v) => v))
          : const {},
      _$data.containsKey('notEqualToAny')
          ? l$notEqualToAny == null
              ? null
              : Object.hashAll(l$notEqualToAny.map((v) => v))
          : const {},
      _$data.containsKey('notIn')
          ? l$notIn == null
              ? null
              : Object.hashAll(l$notIn.map((v) => v))
          : const {},
    ]);
  }
}

abstract class CopyWith$Input$IntFilterInput<TRes> {
  factory CopyWith$Input$IntFilterInput(
    Input$IntFilterInput instance,
    TRes Function(Input$IntFilterInput) then,
  ) = _CopyWithImpl$Input$IntFilterInput;

  factory CopyWith$Input$IntFilterInput.stub(TRes res) =
      _CopyWithStubImpl$Input$IntFilterInput;

  TRes call({
    int? distinctFrom,
    List<int>? distinctFromAll,
    List<int>? distinctFromAny,
    int? equalTo,
    int? greaterThan,
    int? greaterThanOrEqualTo,
    List<int>? $in,
    bool? isNull,
    int? lessThan,
    int? lessThanOrEqualTo,
    int? notDistinctFrom,
    int? notEqualTo,
    List<int>? notEqualToAll,
    List<int>? notEqualToAny,
    List<int>? notIn,
  });
}

class _CopyWithImpl$Input$IntFilterInput<TRes>
    implements CopyWith$Input$IntFilterInput<TRes> {
  _CopyWithImpl$Input$IntFilterInput(
    this._instance,
    this._then,
  );

  final Input$IntFilterInput _instance;

  final TRes Function(Input$IntFilterInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? distinctFrom = _undefined,
    Object? distinctFromAll = _undefined,
    Object? distinctFromAny = _undefined,
    Object? equalTo = _undefined,
    Object? greaterThan = _undefined,
    Object? greaterThanOrEqualTo = _undefined,
    Object? $in = _undefined,
    Object? isNull = _undefined,
    Object? lessThan = _undefined,
    Object? lessThanOrEqualTo = _undefined,
    Object? notDistinctFrom = _undefined,
    Object? notEqualTo = _undefined,
    Object? notEqualToAll = _undefined,
    Object? notEqualToAny = _undefined,
    Object? notIn = _undefined,
  }) =>
      _then(Input$IntFilterInput._({
        ..._instance._$data,
        if (distinctFrom != _undefined) 'distinctFrom': (distinctFrom as int?),
        if (distinctFromAll != _undefined)
          'distinctFromAll': (distinctFromAll as List<int>?),
        if (distinctFromAny != _undefined)
          'distinctFromAny': (distinctFromAny as List<int>?),
        if (equalTo != _undefined) 'equalTo': (equalTo as int?),
        if (greaterThan != _undefined) 'greaterThan': (greaterThan as int?),
        if (greaterThanOrEqualTo != _undefined)
          'greaterThanOrEqualTo': (greaterThanOrEqualTo as int?),
        if ($in != _undefined) 'in': ($in as List<int>?),
        if (isNull != _undefined) 'isNull': (isNull as bool?),
        if (lessThan != _undefined) 'lessThan': (lessThan as int?),
        if (lessThanOrEqualTo != _undefined)
          'lessThanOrEqualTo': (lessThanOrEqualTo as int?),
        if (notDistinctFrom != _undefined)
          'notDistinctFrom': (notDistinctFrom as int?),
        if (notEqualTo != _undefined) 'notEqualTo': (notEqualTo as int?),
        if (notEqualToAll != _undefined)
          'notEqualToAll': (notEqualToAll as List<int>?),
        if (notEqualToAny != _undefined)
          'notEqualToAny': (notEqualToAny as List<int>?),
        if (notIn != _undefined) 'notIn': (notIn as List<int>?),
      }));
}

class _CopyWithStubImpl$Input$IntFilterInput<TRes>
    implements CopyWith$Input$IntFilterInput<TRes> {
  _CopyWithStubImpl$Input$IntFilterInput(this._res);

  TRes _res;

  call({
    int? distinctFrom,
    List<int>? distinctFromAll,
    List<int>? distinctFromAny,
    int? equalTo,
    int? greaterThan,
    int? greaterThanOrEqualTo,
    List<int>? $in,
    bool? isNull,
    int? lessThan,
    int? lessThanOrEqualTo,
    int? notDistinctFrom,
    int? notEqualTo,
    List<int>? notEqualToAll,
    List<int>? notEqualToAny,
    List<int>? notIn,
  }) =>
      _res;
}

class Input$LoginTrackerCredentialsInput {
  factory Input$LoginTrackerCredentialsInput({
    String? clientMutationId,
    required String password,
    required int trackerId,
    required String username,
  }) =>
      Input$LoginTrackerCredentialsInput._({
        if (clientMutationId != null) r'clientMutationId': clientMutationId,
        r'password': password,
        r'trackerId': trackerId,
        r'username': username,
      });

  Input$LoginTrackerCredentialsInput._(this._$data);

  factory Input$LoginTrackerCredentialsInput.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('clientMutationId')) {
      final l$clientMutationId = data['clientMutationId'];
      result$data['clientMutationId'] = (l$clientMutationId as String?);
    }
    final l$password = data['password'];
    result$data['password'] = (l$password as String);
    final l$trackerId = data['trackerId'];
    result$data['trackerId'] = (l$trackerId as int);
    final l$username = data['username'];
    result$data['username'] = (l$username as String);
    return Input$LoginTrackerCredentialsInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get clientMutationId => (_$data['clientMutationId'] as String?);

  String get password => (_$data['password'] as String);

  int get trackerId => (_$data['trackerId'] as int);

  String get username => (_$data['username'] as String);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('clientMutationId')) {
      final l$clientMutationId = clientMutationId;
      result$data['clientMutationId'] = l$clientMutationId;
    }
    final l$password = password;
    result$data['password'] = l$password;
    final l$trackerId = trackerId;
    result$data['trackerId'] = l$trackerId;
    final l$username = username;
    result$data['username'] = l$username;
    return result$data;
  }

  CopyWith$Input$LoginTrackerCredentialsInput<
          Input$LoginTrackerCredentialsInput>
      get copyWith => CopyWith$Input$LoginTrackerCredentialsInput(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$LoginTrackerCredentialsInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (_$data.containsKey('clientMutationId') !=
        other._$data.containsKey('clientMutationId')) {
      return false;
    }
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    final l$password = password;
    final lOther$password = other.password;
    if (l$password != lOther$password) {
      return false;
    }
    final l$trackerId = trackerId;
    final lOther$trackerId = other.trackerId;
    if (l$trackerId != lOther$trackerId) {
      return false;
    }
    final l$username = username;
    final lOther$username = other.username;
    if (l$username != lOther$username) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$clientMutationId = clientMutationId;
    final l$password = password;
    final l$trackerId = trackerId;
    final l$username = username;
    return Object.hashAll([
      _$data.containsKey('clientMutationId') ? l$clientMutationId : const {},
      l$password,
      l$trackerId,
      l$username,
    ]);
  }
}

abstract class CopyWith$Input$LoginTrackerCredentialsInput<TRes> {
  factory CopyWith$Input$LoginTrackerCredentialsInput(
    Input$LoginTrackerCredentialsInput instance,
    TRes Function(Input$LoginTrackerCredentialsInput) then,
  ) = _CopyWithImpl$Input$LoginTrackerCredentialsInput;

  factory CopyWith$Input$LoginTrackerCredentialsInput.stub(TRes res) =
      _CopyWithStubImpl$Input$LoginTrackerCredentialsInput;

  TRes call({
    String? clientMutationId,
    String? password,
    int? trackerId,
    String? username,
  });
}

class _CopyWithImpl$Input$LoginTrackerCredentialsInput<TRes>
    implements CopyWith$Input$LoginTrackerCredentialsInput<TRes> {
  _CopyWithImpl$Input$LoginTrackerCredentialsInput(
    this._instance,
    this._then,
  );

  final Input$LoginTrackerCredentialsInput _instance;

  final TRes Function(Input$LoginTrackerCredentialsInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? clientMutationId = _undefined,
    Object? password = _undefined,
    Object? trackerId = _undefined,
    Object? username = _undefined,
  }) =>
      _then(Input$LoginTrackerCredentialsInput._({
        ..._instance._$data,
        if (clientMutationId != _undefined)
          'clientMutationId': (clientMutationId as String?),
        if (password != _undefined && password != null)
          'password': (password as String),
        if (trackerId != _undefined && trackerId != null)
          'trackerId': (trackerId as int),
        if (username != _undefined && username != null)
          'username': (username as String),
      }));
}

class _CopyWithStubImpl$Input$LoginTrackerCredentialsInput<TRes>
    implements CopyWith$Input$LoginTrackerCredentialsInput<TRes> {
  _CopyWithStubImpl$Input$LoginTrackerCredentialsInput(this._res);

  TRes _res;

  call({
    String? clientMutationId,
    String? password,
    int? trackerId,
    String? username,
  }) =>
      _res;
}

class Input$LoginTrackerOAuthInput {
  factory Input$LoginTrackerOAuthInput({
    required String callbackUrl,
    String? clientMutationId,
    required int trackerId,
  }) =>
      Input$LoginTrackerOAuthInput._({
        r'callbackUrl': callbackUrl,
        if (clientMutationId != null) r'clientMutationId': clientMutationId,
        r'trackerId': trackerId,
      });

  Input$LoginTrackerOAuthInput._(this._$data);

  factory Input$LoginTrackerOAuthInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$callbackUrl = data['callbackUrl'];
    result$data['callbackUrl'] = (l$callbackUrl as String);
    if (data.containsKey('clientMutationId')) {
      final l$clientMutationId = data['clientMutationId'];
      result$data['clientMutationId'] = (l$clientMutationId as String?);
    }
    final l$trackerId = data['trackerId'];
    result$data['trackerId'] = (l$trackerId as int);
    return Input$LoginTrackerOAuthInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String get callbackUrl => (_$data['callbackUrl'] as String);

  String? get clientMutationId => (_$data['clientMutationId'] as String?);

  int get trackerId => (_$data['trackerId'] as int);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$callbackUrl = callbackUrl;
    result$data['callbackUrl'] = l$callbackUrl;
    if (_$data.containsKey('clientMutationId')) {
      final l$clientMutationId = clientMutationId;
      result$data['clientMutationId'] = l$clientMutationId;
    }
    final l$trackerId = trackerId;
    result$data['trackerId'] = l$trackerId;
    return result$data;
  }

  CopyWith$Input$LoginTrackerOAuthInput<Input$LoginTrackerOAuthInput>
      get copyWith => CopyWith$Input$LoginTrackerOAuthInput(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$LoginTrackerOAuthInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$callbackUrl = callbackUrl;
    final lOther$callbackUrl = other.callbackUrl;
    if (l$callbackUrl != lOther$callbackUrl) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (_$data.containsKey('clientMutationId') !=
        other._$data.containsKey('clientMutationId')) {
      return false;
    }
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    final l$trackerId = trackerId;
    final lOther$trackerId = other.trackerId;
    if (l$trackerId != lOther$trackerId) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$callbackUrl = callbackUrl;
    final l$clientMutationId = clientMutationId;
    final l$trackerId = trackerId;
    return Object.hashAll([
      l$callbackUrl,
      _$data.containsKey('clientMutationId') ? l$clientMutationId : const {},
      l$trackerId,
    ]);
  }
}

abstract class CopyWith$Input$LoginTrackerOAuthInput<TRes> {
  factory CopyWith$Input$LoginTrackerOAuthInput(
    Input$LoginTrackerOAuthInput instance,
    TRes Function(Input$LoginTrackerOAuthInput) then,
  ) = _CopyWithImpl$Input$LoginTrackerOAuthInput;

  factory CopyWith$Input$LoginTrackerOAuthInput.stub(TRes res) =
      _CopyWithStubImpl$Input$LoginTrackerOAuthInput;

  TRes call({
    String? callbackUrl,
    String? clientMutationId,
    int? trackerId,
  });
}

class _CopyWithImpl$Input$LoginTrackerOAuthInput<TRes>
    implements CopyWith$Input$LoginTrackerOAuthInput<TRes> {
  _CopyWithImpl$Input$LoginTrackerOAuthInput(
    this._instance,
    this._then,
  );

  final Input$LoginTrackerOAuthInput _instance;

  final TRes Function(Input$LoginTrackerOAuthInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? callbackUrl = _undefined,
    Object? clientMutationId = _undefined,
    Object? trackerId = _undefined,
  }) =>
      _then(Input$LoginTrackerOAuthInput._({
        ..._instance._$data,
        if (callbackUrl != _undefined && callbackUrl != null)
          'callbackUrl': (callbackUrl as String),
        if (clientMutationId != _undefined)
          'clientMutationId': (clientMutationId as String?),
        if (trackerId != _undefined && trackerId != null)
          'trackerId': (trackerId as int),
      }));
}

class _CopyWithStubImpl$Input$LoginTrackerOAuthInput<TRes>
    implements CopyWith$Input$LoginTrackerOAuthInput<TRes> {
  _CopyWithStubImpl$Input$LoginTrackerOAuthInput(this._res);

  TRes _res;

  call({
    String? callbackUrl,
    String? clientMutationId,
    int? trackerId,
  }) =>
      _res;
}

class Input$LogoutTrackerInput {
  factory Input$LogoutTrackerInput({
    String? clientMutationId,
    required int trackerId,
  }) =>
      Input$LogoutTrackerInput._({
        if (clientMutationId != null) r'clientMutationId': clientMutationId,
        r'trackerId': trackerId,
      });

  Input$LogoutTrackerInput._(this._$data);

  factory Input$LogoutTrackerInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('clientMutationId')) {
      final l$clientMutationId = data['clientMutationId'];
      result$data['clientMutationId'] = (l$clientMutationId as String?);
    }
    final l$trackerId = data['trackerId'];
    result$data['trackerId'] = (l$trackerId as int);
    return Input$LogoutTrackerInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get clientMutationId => (_$data['clientMutationId'] as String?);

  int get trackerId => (_$data['trackerId'] as int);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('clientMutationId')) {
      final l$clientMutationId = clientMutationId;
      result$data['clientMutationId'] = l$clientMutationId;
    }
    final l$trackerId = trackerId;
    result$data['trackerId'] = l$trackerId;
    return result$data;
  }

  CopyWith$Input$LogoutTrackerInput<Input$LogoutTrackerInput> get copyWith =>
      CopyWith$Input$LogoutTrackerInput(
        this,
        (i) => i,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$LogoutTrackerInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (_$data.containsKey('clientMutationId') !=
        other._$data.containsKey('clientMutationId')) {
      return false;
    }
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    final l$trackerId = trackerId;
    final lOther$trackerId = other.trackerId;
    if (l$trackerId != lOther$trackerId) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$clientMutationId = clientMutationId;
    final l$trackerId = trackerId;
    return Object.hashAll([
      _$data.containsKey('clientMutationId') ? l$clientMutationId : const {},
      l$trackerId,
    ]);
  }
}

abstract class CopyWith$Input$LogoutTrackerInput<TRes> {
  factory CopyWith$Input$LogoutTrackerInput(
    Input$LogoutTrackerInput instance,
    TRes Function(Input$LogoutTrackerInput) then,
  ) = _CopyWithImpl$Input$LogoutTrackerInput;

  factory CopyWith$Input$LogoutTrackerInput.stub(TRes res) =
      _CopyWithStubImpl$Input$LogoutTrackerInput;

  TRes call({
    String? clientMutationId,
    int? trackerId,
  });
}

class _CopyWithImpl$Input$LogoutTrackerInput<TRes>
    implements CopyWith$Input$LogoutTrackerInput<TRes> {
  _CopyWithImpl$Input$LogoutTrackerInput(
    this._instance,
    this._then,
  );

  final Input$LogoutTrackerInput _instance;

  final TRes Function(Input$LogoutTrackerInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? clientMutationId = _undefined,
    Object? trackerId = _undefined,
  }) =>
      _then(Input$LogoutTrackerInput._({
        ..._instance._$data,
        if (clientMutationId != _undefined)
          'clientMutationId': (clientMutationId as String?),
        if (trackerId != _undefined && trackerId != null)
          'trackerId': (trackerId as int),
      }));
}

class _CopyWithStubImpl$Input$LogoutTrackerInput<TRes>
    implements CopyWith$Input$LogoutTrackerInput<TRes> {
  _CopyWithStubImpl$Input$LogoutTrackerInput(this._res);

  TRes _res;

  call({
    String? clientMutationId,
    int? trackerId,
  }) =>
      _res;
}

class Input$LongFilterInput {
  factory Input$LongFilterInput({
    String? distinctFrom,
    List<String>? distinctFromAll,
    List<String>? distinctFromAny,
    String? equalTo,
    String? greaterThan,
    String? greaterThanOrEqualTo,
    List<String>? $in,
    bool? isNull,
    String? lessThan,
    String? lessThanOrEqualTo,
    String? notDistinctFrom,
    String? notEqualTo,
    List<String>? notEqualToAll,
    List<String>? notEqualToAny,
    List<String>? notIn,
  }) =>
      Input$LongFilterInput._({
        if (distinctFrom != null) r'distinctFrom': distinctFrom,
        if (distinctFromAll != null) r'distinctFromAll': distinctFromAll,
        if (distinctFromAny != null) r'distinctFromAny': distinctFromAny,
        if (equalTo != null) r'equalTo': equalTo,
        if (greaterThan != null) r'greaterThan': greaterThan,
        if (greaterThanOrEqualTo != null)
          r'greaterThanOrEqualTo': greaterThanOrEqualTo,
        if ($in != null) r'in': $in,
        if (isNull != null) r'isNull': isNull,
        if (lessThan != null) r'lessThan': lessThan,
        if (lessThanOrEqualTo != null) r'lessThanOrEqualTo': lessThanOrEqualTo,
        if (notDistinctFrom != null) r'notDistinctFrom': notDistinctFrom,
        if (notEqualTo != null) r'notEqualTo': notEqualTo,
        if (notEqualToAll != null) r'notEqualToAll': notEqualToAll,
        if (notEqualToAny != null) r'notEqualToAny': notEqualToAny,
        if (notIn != null) r'notIn': notIn,
      });

  Input$LongFilterInput._(this._$data);

  factory Input$LongFilterInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('distinctFrom')) {
      final l$distinctFrom = data['distinctFrom'];
      result$data['distinctFrom'] =
          l$distinctFrom == null ? null : longStringFromJson(l$distinctFrom);
    }
    if (data.containsKey('distinctFromAll')) {
      final l$distinctFromAll = data['distinctFromAll'];
      result$data['distinctFromAll'] = (l$distinctFromAll as List<dynamic>?)
          ?.map((e) => longStringFromJson(e))
          .toList();
    }
    if (data.containsKey('distinctFromAny')) {
      final l$distinctFromAny = data['distinctFromAny'];
      result$data['distinctFromAny'] = (l$distinctFromAny as List<dynamic>?)
          ?.map((e) => longStringFromJson(e))
          .toList();
    }
    if (data.containsKey('equalTo')) {
      final l$equalTo = data['equalTo'];
      result$data['equalTo'] =
          l$equalTo == null ? null : longStringFromJson(l$equalTo);
    }
    if (data.containsKey('greaterThan')) {
      final l$greaterThan = data['greaterThan'];
      result$data['greaterThan'] =
          l$greaterThan == null ? null : longStringFromJson(l$greaterThan);
    }
    if (data.containsKey('greaterThanOrEqualTo')) {
      final l$greaterThanOrEqualTo = data['greaterThanOrEqualTo'];
      result$data['greaterThanOrEqualTo'] = l$greaterThanOrEqualTo == null
          ? null
          : longStringFromJson(l$greaterThanOrEqualTo);
    }
    if (data.containsKey('in')) {
      final l$$in = data['in'];
      result$data['in'] =
          (l$$in as List<dynamic>?)?.map((e) => longStringFromJson(e)).toList();
    }
    if (data.containsKey('isNull')) {
      final l$isNull = data['isNull'];
      result$data['isNull'] = (l$isNull as bool?);
    }
    if (data.containsKey('lessThan')) {
      final l$lessThan = data['lessThan'];
      result$data['lessThan'] =
          l$lessThan == null ? null : longStringFromJson(l$lessThan);
    }
    if (data.containsKey('lessThanOrEqualTo')) {
      final l$lessThanOrEqualTo = data['lessThanOrEqualTo'];
      result$data['lessThanOrEqualTo'] = l$lessThanOrEqualTo == null
          ? null
          : longStringFromJson(l$lessThanOrEqualTo);
    }
    if (data.containsKey('notDistinctFrom')) {
      final l$notDistinctFrom = data['notDistinctFrom'];
      result$data['notDistinctFrom'] = l$notDistinctFrom == null
          ? null
          : longStringFromJson(l$notDistinctFrom);
    }
    if (data.containsKey('notEqualTo')) {
      final l$notEqualTo = data['notEqualTo'];
      result$data['notEqualTo'] =
          l$notEqualTo == null ? null : longStringFromJson(l$notEqualTo);
    }
    if (data.containsKey('notEqualToAll')) {
      final l$notEqualToAll = data['notEqualToAll'];
      result$data['notEqualToAll'] = (l$notEqualToAll as List<dynamic>?)
          ?.map((e) => longStringFromJson(e))
          .toList();
    }
    if (data.containsKey('notEqualToAny')) {
      final l$notEqualToAny = data['notEqualToAny'];
      result$data['notEqualToAny'] = (l$notEqualToAny as List<dynamic>?)
          ?.map((e) => longStringFromJson(e))
          .toList();
    }
    if (data.containsKey('notIn')) {
      final l$notIn = data['notIn'];
      result$data['notIn'] = (l$notIn as List<dynamic>?)
          ?.map((e) => longStringFromJson(e))
          .toList();
    }
    return Input$LongFilterInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get distinctFrom => (_$data['distinctFrom'] as String?);

  List<String>? get distinctFromAll =>
      (_$data['distinctFromAll'] as List<String>?);

  List<String>? get distinctFromAny =>
      (_$data['distinctFromAny'] as List<String>?);

  String? get equalTo => (_$data['equalTo'] as String?);

  String? get greaterThan => (_$data['greaterThan'] as String?);

  String? get greaterThanOrEqualTo =>
      (_$data['greaterThanOrEqualTo'] as String?);

  List<String>? get $in => (_$data['in'] as List<String>?);

  bool? get isNull => (_$data['isNull'] as bool?);

  String? get lessThan => (_$data['lessThan'] as String?);

  String? get lessThanOrEqualTo => (_$data['lessThanOrEqualTo'] as String?);

  String? get notDistinctFrom => (_$data['notDistinctFrom'] as String?);

  String? get notEqualTo => (_$data['notEqualTo'] as String?);

  List<String>? get notEqualToAll => (_$data['notEqualToAll'] as List<String>?);

  List<String>? get notEqualToAny => (_$data['notEqualToAny'] as List<String>?);

  List<String>? get notIn => (_$data['notIn'] as List<String>?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('distinctFrom')) {
      final l$distinctFrom = distinctFrom;
      result$data['distinctFrom'] =
          l$distinctFrom == null ? null : longStringToJson(l$distinctFrom);
    }
    if (_$data.containsKey('distinctFromAll')) {
      final l$distinctFromAll = distinctFromAll;
      result$data['distinctFromAll'] =
          l$distinctFromAll?.map((e) => longStringToJson(e)).toList();
    }
    if (_$data.containsKey('distinctFromAny')) {
      final l$distinctFromAny = distinctFromAny;
      result$data['distinctFromAny'] =
          l$distinctFromAny?.map((e) => longStringToJson(e)).toList();
    }
    if (_$data.containsKey('equalTo')) {
      final l$equalTo = equalTo;
      result$data['equalTo'] =
          l$equalTo == null ? null : longStringToJson(l$equalTo);
    }
    if (_$data.containsKey('greaterThan')) {
      final l$greaterThan = greaterThan;
      result$data['greaterThan'] =
          l$greaterThan == null ? null : longStringToJson(l$greaterThan);
    }
    if (_$data.containsKey('greaterThanOrEqualTo')) {
      final l$greaterThanOrEqualTo = greaterThanOrEqualTo;
      result$data['greaterThanOrEqualTo'] = l$greaterThanOrEqualTo == null
          ? null
          : longStringToJson(l$greaterThanOrEqualTo);
    }
    if (_$data.containsKey('in')) {
      final l$$in = $in;
      result$data['in'] = l$$in?.map((e) => longStringToJson(e)).toList();
    }
    if (_$data.containsKey('isNull')) {
      final l$isNull = isNull;
      result$data['isNull'] = l$isNull;
    }
    if (_$data.containsKey('lessThan')) {
      final l$lessThan = lessThan;
      result$data['lessThan'] =
          l$lessThan == null ? null : longStringToJson(l$lessThan);
    }
    if (_$data.containsKey('lessThanOrEqualTo')) {
      final l$lessThanOrEqualTo = lessThanOrEqualTo;
      result$data['lessThanOrEqualTo'] = l$lessThanOrEqualTo == null
          ? null
          : longStringToJson(l$lessThanOrEqualTo);
    }
    if (_$data.containsKey('notDistinctFrom')) {
      final l$notDistinctFrom = notDistinctFrom;
      result$data['notDistinctFrom'] = l$notDistinctFrom == null
          ? null
          : longStringToJson(l$notDistinctFrom);
    }
    if (_$data.containsKey('notEqualTo')) {
      final l$notEqualTo = notEqualTo;
      result$data['notEqualTo'] =
          l$notEqualTo == null ? null : longStringToJson(l$notEqualTo);
    }
    if (_$data.containsKey('notEqualToAll')) {
      final l$notEqualToAll = notEqualToAll;
      result$data['notEqualToAll'] =
          l$notEqualToAll?.map((e) => longStringToJson(e)).toList();
    }
    if (_$data.containsKey('notEqualToAny')) {
      final l$notEqualToAny = notEqualToAny;
      result$data['notEqualToAny'] =
          l$notEqualToAny?.map((e) => longStringToJson(e)).toList();
    }
    if (_$data.containsKey('notIn')) {
      final l$notIn = notIn;
      result$data['notIn'] = l$notIn?.map((e) => longStringToJson(e)).toList();
    }
    return result$data;
  }

  CopyWith$Input$LongFilterInput<Input$LongFilterInput> get copyWith =>
      CopyWith$Input$LongFilterInput(
        this,
        (i) => i,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$LongFilterInput || runtimeType != other.runtimeType) {
      return false;
    }
    final l$distinctFrom = distinctFrom;
    final lOther$distinctFrom = other.distinctFrom;
    if (_$data.containsKey('distinctFrom') !=
        other._$data.containsKey('distinctFrom')) {
      return false;
    }
    if (l$distinctFrom != lOther$distinctFrom) {
      return false;
    }
    final l$distinctFromAll = distinctFromAll;
    final lOther$distinctFromAll = other.distinctFromAll;
    if (_$data.containsKey('distinctFromAll') !=
        other._$data.containsKey('distinctFromAll')) {
      return false;
    }
    if (l$distinctFromAll != null && lOther$distinctFromAll != null) {
      if (l$distinctFromAll.length != lOther$distinctFromAll.length) {
        return false;
      }
      for (int i = 0; i < l$distinctFromAll.length; i++) {
        final l$distinctFromAll$entry = l$distinctFromAll[i];
        final lOther$distinctFromAll$entry = lOther$distinctFromAll[i];
        if (l$distinctFromAll$entry != lOther$distinctFromAll$entry) {
          return false;
        }
      }
    } else if (l$distinctFromAll != lOther$distinctFromAll) {
      return false;
    }
    final l$distinctFromAny = distinctFromAny;
    final lOther$distinctFromAny = other.distinctFromAny;
    if (_$data.containsKey('distinctFromAny') !=
        other._$data.containsKey('distinctFromAny')) {
      return false;
    }
    if (l$distinctFromAny != null && lOther$distinctFromAny != null) {
      if (l$distinctFromAny.length != lOther$distinctFromAny.length) {
        return false;
      }
      for (int i = 0; i < l$distinctFromAny.length; i++) {
        final l$distinctFromAny$entry = l$distinctFromAny[i];
        final lOther$distinctFromAny$entry = lOther$distinctFromAny[i];
        if (l$distinctFromAny$entry != lOther$distinctFromAny$entry) {
          return false;
        }
      }
    } else if (l$distinctFromAny != lOther$distinctFromAny) {
      return false;
    }
    final l$equalTo = equalTo;
    final lOther$equalTo = other.equalTo;
    if (_$data.containsKey('equalTo') != other._$data.containsKey('equalTo')) {
      return false;
    }
    if (l$equalTo != lOther$equalTo) {
      return false;
    }
    final l$greaterThan = greaterThan;
    final lOther$greaterThan = other.greaterThan;
    if (_$data.containsKey('greaterThan') !=
        other._$data.containsKey('greaterThan')) {
      return false;
    }
    if (l$greaterThan != lOther$greaterThan) {
      return false;
    }
    final l$greaterThanOrEqualTo = greaterThanOrEqualTo;
    final lOther$greaterThanOrEqualTo = other.greaterThanOrEqualTo;
    if (_$data.containsKey('greaterThanOrEqualTo') !=
        other._$data.containsKey('greaterThanOrEqualTo')) {
      return false;
    }
    if (l$greaterThanOrEqualTo != lOther$greaterThanOrEqualTo) {
      return false;
    }
    final l$$in = $in;
    final lOther$$in = other.$in;
    if (_$data.containsKey('in') != other._$data.containsKey('in')) {
      return false;
    }
    if (l$$in != null && lOther$$in != null) {
      if (l$$in.length != lOther$$in.length) {
        return false;
      }
      for (int i = 0; i < l$$in.length; i++) {
        final l$$in$entry = l$$in[i];
        final lOther$$in$entry = lOther$$in[i];
        if (l$$in$entry != lOther$$in$entry) {
          return false;
        }
      }
    } else if (l$$in != lOther$$in) {
      return false;
    }
    final l$isNull = isNull;
    final lOther$isNull = other.isNull;
    if (_$data.containsKey('isNull') != other._$data.containsKey('isNull')) {
      return false;
    }
    if (l$isNull != lOther$isNull) {
      return false;
    }
    final l$lessThan = lessThan;
    final lOther$lessThan = other.lessThan;
    if (_$data.containsKey('lessThan') !=
        other._$data.containsKey('lessThan')) {
      return false;
    }
    if (l$lessThan != lOther$lessThan) {
      return false;
    }
    final l$lessThanOrEqualTo = lessThanOrEqualTo;
    final lOther$lessThanOrEqualTo = other.lessThanOrEqualTo;
    if (_$data.containsKey('lessThanOrEqualTo') !=
        other._$data.containsKey('lessThanOrEqualTo')) {
      return false;
    }
    if (l$lessThanOrEqualTo != lOther$lessThanOrEqualTo) {
      return false;
    }
    final l$notDistinctFrom = notDistinctFrom;
    final lOther$notDistinctFrom = other.notDistinctFrom;
    if (_$data.containsKey('notDistinctFrom') !=
        other._$data.containsKey('notDistinctFrom')) {
      return false;
    }
    if (l$notDistinctFrom != lOther$notDistinctFrom) {
      return false;
    }
    final l$notEqualTo = notEqualTo;
    final lOther$notEqualTo = other.notEqualTo;
    if (_$data.containsKey('notEqualTo') !=
        other._$data.containsKey('notEqualTo')) {
      return false;
    }
    if (l$notEqualTo != lOther$notEqualTo) {
      return false;
    }
    final l$notEqualToAll = notEqualToAll;
    final lOther$notEqualToAll = other.notEqualToAll;
    if (_$data.containsKey('notEqualToAll') !=
        other._$data.containsKey('notEqualToAll')) {
      return false;
    }
    if (l$notEqualToAll != null && lOther$notEqualToAll != null) {
      if (l$notEqualToAll.length != lOther$notEqualToAll.length) {
        return false;
      }
      for (int i = 0; i < l$notEqualToAll.length; i++) {
        final l$notEqualToAll$entry = l$notEqualToAll[i];
        final lOther$notEqualToAll$entry = lOther$notEqualToAll[i];
        if (l$notEqualToAll$entry != lOther$notEqualToAll$entry) {
          return false;
        }
      }
    } else if (l$notEqualToAll != lOther$notEqualToAll) {
      return false;
    }
    final l$notEqualToAny = notEqualToAny;
    final lOther$notEqualToAny = other.notEqualToAny;
    if (_$data.containsKey('notEqualToAny') !=
        other._$data.containsKey('notEqualToAny')) {
      return false;
    }
    if (l$notEqualToAny != null && lOther$notEqualToAny != null) {
      if (l$notEqualToAny.length != lOther$notEqualToAny.length) {
        return false;
      }
      for (int i = 0; i < l$notEqualToAny.length; i++) {
        final l$notEqualToAny$entry = l$notEqualToAny[i];
        final lOther$notEqualToAny$entry = lOther$notEqualToAny[i];
        if (l$notEqualToAny$entry != lOther$notEqualToAny$entry) {
          return false;
        }
      }
    } else if (l$notEqualToAny != lOther$notEqualToAny) {
      return false;
    }
    final l$notIn = notIn;
    final lOther$notIn = other.notIn;
    if (_$data.containsKey('notIn') != other._$data.containsKey('notIn')) {
      return false;
    }
    if (l$notIn != null && lOther$notIn != null) {
      if (l$notIn.length != lOther$notIn.length) {
        return false;
      }
      for (int i = 0; i < l$notIn.length; i++) {
        final l$notIn$entry = l$notIn[i];
        final lOther$notIn$entry = lOther$notIn[i];
        if (l$notIn$entry != lOther$notIn$entry) {
          return false;
        }
      }
    } else if (l$notIn != lOther$notIn) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$distinctFrom = distinctFrom;
    final l$distinctFromAll = distinctFromAll;
    final l$distinctFromAny = distinctFromAny;
    final l$equalTo = equalTo;
    final l$greaterThan = greaterThan;
    final l$greaterThanOrEqualTo = greaterThanOrEqualTo;
    final l$$in = $in;
    final l$isNull = isNull;
    final l$lessThan = lessThan;
    final l$lessThanOrEqualTo = lessThanOrEqualTo;
    final l$notDistinctFrom = notDistinctFrom;
    final l$notEqualTo = notEqualTo;
    final l$notEqualToAll = notEqualToAll;
    final l$notEqualToAny = notEqualToAny;
    final l$notIn = notIn;
    return Object.hashAll([
      _$data.containsKey('distinctFrom') ? l$distinctFrom : const {},
      _$data.containsKey('distinctFromAll')
          ? l$distinctFromAll == null
              ? null
              : Object.hashAll(l$distinctFromAll.map((v) => v))
          : const {},
      _$data.containsKey('distinctFromAny')
          ? l$distinctFromAny == null
              ? null
              : Object.hashAll(l$distinctFromAny.map((v) => v))
          : const {},
      _$data.containsKey('equalTo') ? l$equalTo : const {},
      _$data.containsKey('greaterThan') ? l$greaterThan : const {},
      _$data.containsKey('greaterThanOrEqualTo')
          ? l$greaterThanOrEqualTo
          : const {},
      _$data.containsKey('in')
          ? l$$in == null
              ? null
              : Object.hashAll(l$$in.map((v) => v))
          : const {},
      _$data.containsKey('isNull') ? l$isNull : const {},
      _$data.containsKey('lessThan') ? l$lessThan : const {},
      _$data.containsKey('lessThanOrEqualTo') ? l$lessThanOrEqualTo : const {},
      _$data.containsKey('notDistinctFrom') ? l$notDistinctFrom : const {},
      _$data.containsKey('notEqualTo') ? l$notEqualTo : const {},
      _$data.containsKey('notEqualToAll')
          ? l$notEqualToAll == null
              ? null
              : Object.hashAll(l$notEqualToAll.map((v) => v))
          : const {},
      _$data.containsKey('notEqualToAny')
          ? l$notEqualToAny == null
              ? null
              : Object.hashAll(l$notEqualToAny.map((v) => v))
          : const {},
      _$data.containsKey('notIn')
          ? l$notIn == null
              ? null
              : Object.hashAll(l$notIn.map((v) => v))
          : const {},
    ]);
  }
}

abstract class CopyWith$Input$LongFilterInput<TRes> {
  factory CopyWith$Input$LongFilterInput(
    Input$LongFilterInput instance,
    TRes Function(Input$LongFilterInput) then,
  ) = _CopyWithImpl$Input$LongFilterInput;

  factory CopyWith$Input$LongFilterInput.stub(TRes res) =
      _CopyWithStubImpl$Input$LongFilterInput;

  TRes call({
    String? distinctFrom,
    List<String>? distinctFromAll,
    List<String>? distinctFromAny,
    String? equalTo,
    String? greaterThan,
    String? greaterThanOrEqualTo,
    List<String>? $in,
    bool? isNull,
    String? lessThan,
    String? lessThanOrEqualTo,
    String? notDistinctFrom,
    String? notEqualTo,
    List<String>? notEqualToAll,
    List<String>? notEqualToAny,
    List<String>? notIn,
  });
}

class _CopyWithImpl$Input$LongFilterInput<TRes>
    implements CopyWith$Input$LongFilterInput<TRes> {
  _CopyWithImpl$Input$LongFilterInput(
    this._instance,
    this._then,
  );

  final Input$LongFilterInput _instance;

  final TRes Function(Input$LongFilterInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? distinctFrom = _undefined,
    Object? distinctFromAll = _undefined,
    Object? distinctFromAny = _undefined,
    Object? equalTo = _undefined,
    Object? greaterThan = _undefined,
    Object? greaterThanOrEqualTo = _undefined,
    Object? $in = _undefined,
    Object? isNull = _undefined,
    Object? lessThan = _undefined,
    Object? lessThanOrEqualTo = _undefined,
    Object? notDistinctFrom = _undefined,
    Object? notEqualTo = _undefined,
    Object? notEqualToAll = _undefined,
    Object? notEqualToAny = _undefined,
    Object? notIn = _undefined,
  }) =>
      _then(Input$LongFilterInput._({
        ..._instance._$data,
        if (distinctFrom != _undefined)
          'distinctFrom': (distinctFrom as String?),
        if (distinctFromAll != _undefined)
          'distinctFromAll': (distinctFromAll as List<String>?),
        if (distinctFromAny != _undefined)
          'distinctFromAny': (distinctFromAny as List<String>?),
        if (equalTo != _undefined) 'equalTo': (equalTo as String?),
        if (greaterThan != _undefined) 'greaterThan': (greaterThan as String?),
        if (greaterThanOrEqualTo != _undefined)
          'greaterThanOrEqualTo': (greaterThanOrEqualTo as String?),
        if ($in != _undefined) 'in': ($in as List<String>?),
        if (isNull != _undefined) 'isNull': (isNull as bool?),
        if (lessThan != _undefined) 'lessThan': (lessThan as String?),
        if (lessThanOrEqualTo != _undefined)
          'lessThanOrEqualTo': (lessThanOrEqualTo as String?),
        if (notDistinctFrom != _undefined)
          'notDistinctFrom': (notDistinctFrom as String?),
        if (notEqualTo != _undefined) 'notEqualTo': (notEqualTo as String?),
        if (notEqualToAll != _undefined)
          'notEqualToAll': (notEqualToAll as List<String>?),
        if (notEqualToAny != _undefined)
          'notEqualToAny': (notEqualToAny as List<String>?),
        if (notIn != _undefined) 'notIn': (notIn as List<String>?),
      }));
}

class _CopyWithStubImpl$Input$LongFilterInput<TRes>
    implements CopyWith$Input$LongFilterInput<TRes> {
  _CopyWithStubImpl$Input$LongFilterInput(this._res);

  TRes _res;

  call({
    String? distinctFrom,
    List<String>? distinctFromAll,
    List<String>? distinctFromAny,
    String? equalTo,
    String? greaterThan,
    String? greaterThanOrEqualTo,
    List<String>? $in,
    bool? isNull,
    String? lessThan,
    String? lessThanOrEqualTo,
    String? notDistinctFrom,
    String? notEqualTo,
    List<String>? notEqualToAll,
    List<String>? notEqualToAny,
    List<String>? notIn,
  }) =>
      _res;
}

class Input$MangaConditionInput {
  factory Input$MangaConditionInput({
    String? artist,
    String? author,
    List<int>? categoryIds,
    String? chaptersLastFetchedAt,
    String? description,
    List<String>? genre,
    int? id,
    bool? inLibrary,
    String? inLibraryAt,
    bool? initialized,
    String? lastFetchedAt,
    String? realUrl,
    String? sourceId,
    Enum$MangaStatus? status,
    String? thumbnailUrl,
    String? title,
    String? url,
  }) =>
      Input$MangaConditionInput._({
        if (artist != null) r'artist': artist,
        if (author != null) r'author': author,
        if (categoryIds != null) r'categoryIds': categoryIds,
        if (chaptersLastFetchedAt != null)
          r'chaptersLastFetchedAt': chaptersLastFetchedAt,
        if (description != null) r'description': description,
        if (genre != null) r'genre': genre,
        if (id != null) r'id': id,
        if (inLibrary != null) r'inLibrary': inLibrary,
        if (inLibraryAt != null) r'inLibraryAt': inLibraryAt,
        if (initialized != null) r'initialized': initialized,
        if (lastFetchedAt != null) r'lastFetchedAt': lastFetchedAt,
        if (realUrl != null) r'realUrl': realUrl,
        if (sourceId != null) r'sourceId': sourceId,
        if (status != null) r'status': status,
        if (thumbnailUrl != null) r'thumbnailUrl': thumbnailUrl,
        if (title != null) r'title': title,
        if (url != null) r'url': url,
      });

  Input$MangaConditionInput._(this._$data);

  factory Input$MangaConditionInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('artist')) {
      final l$artist = data['artist'];
      result$data['artist'] = (l$artist as String?);
    }
    if (data.containsKey('author')) {
      final l$author = data['author'];
      result$data['author'] = (l$author as String?);
    }
    if (data.containsKey('categoryIds')) {
      final l$categoryIds = data['categoryIds'];
      result$data['categoryIds'] =
          (l$categoryIds as List<dynamic>?)?.map((e) => (e as int)).toList();
    }
    if (data.containsKey('chaptersLastFetchedAt')) {
      final l$chaptersLastFetchedAt = data['chaptersLastFetchedAt'];
      result$data['chaptersLastFetchedAt'] = l$chaptersLastFetchedAt == null
          ? null
          : longStringFromJson(l$chaptersLastFetchedAt);
    }
    if (data.containsKey('description')) {
      final l$description = data['description'];
      result$data['description'] = (l$description as String?);
    }
    if (data.containsKey('genre')) {
      final l$genre = data['genre'];
      result$data['genre'] =
          (l$genre as List<dynamic>?)?.map((e) => (e as String)).toList();
    }
    if (data.containsKey('id')) {
      final l$id = data['id'];
      result$data['id'] = (l$id as int?);
    }
    if (data.containsKey('inLibrary')) {
      final l$inLibrary = data['inLibrary'];
      result$data['inLibrary'] = (l$inLibrary as bool?);
    }
    if (data.containsKey('inLibraryAt')) {
      final l$inLibraryAt = data['inLibraryAt'];
      result$data['inLibraryAt'] =
          l$inLibraryAt == null ? null : longStringFromJson(l$inLibraryAt);
    }
    if (data.containsKey('initialized')) {
      final l$initialized = data['initialized'];
      result$data['initialized'] = (l$initialized as bool?);
    }
    if (data.containsKey('lastFetchedAt')) {
      final l$lastFetchedAt = data['lastFetchedAt'];
      result$data['lastFetchedAt'] =
          l$lastFetchedAt == null ? null : longStringFromJson(l$lastFetchedAt);
    }
    if (data.containsKey('realUrl')) {
      final l$realUrl = data['realUrl'];
      result$data['realUrl'] = (l$realUrl as String?);
    }
    if (data.containsKey('sourceId')) {
      final l$sourceId = data['sourceId'];
      result$data['sourceId'] =
          l$sourceId == null ? null : longStringFromJson(l$sourceId);
    }
    if (data.containsKey('status')) {
      final l$status = data['status'];
      result$data['status'] = l$status == null
          ? null
          : fromJson$Enum$MangaStatus((l$status as String));
    }
    if (data.containsKey('thumbnailUrl')) {
      final l$thumbnailUrl = data['thumbnailUrl'];
      result$data['thumbnailUrl'] = (l$thumbnailUrl as String?);
    }
    if (data.containsKey('title')) {
      final l$title = data['title'];
      result$data['title'] = (l$title as String?);
    }
    if (data.containsKey('url')) {
      final l$url = data['url'];
      result$data['url'] = (l$url as String?);
    }
    return Input$MangaConditionInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get artist => (_$data['artist'] as String?);

  String? get author => (_$data['author'] as String?);

  List<int>? get categoryIds => (_$data['categoryIds'] as List<int>?);

  String? get chaptersLastFetchedAt =>
      (_$data['chaptersLastFetchedAt'] as String?);

  String? get description => (_$data['description'] as String?);

  List<String>? get genre => (_$data['genre'] as List<String>?);

  int? get id => (_$data['id'] as int?);

  bool? get inLibrary => (_$data['inLibrary'] as bool?);

  String? get inLibraryAt => (_$data['inLibraryAt'] as String?);

  bool? get initialized => (_$data['initialized'] as bool?);

  String? get lastFetchedAt => (_$data['lastFetchedAt'] as String?);

  String? get realUrl => (_$data['realUrl'] as String?);

  String? get sourceId => (_$data['sourceId'] as String?);

  Enum$MangaStatus? get status => (_$data['status'] as Enum$MangaStatus?);

  String? get thumbnailUrl => (_$data['thumbnailUrl'] as String?);

  String? get title => (_$data['title'] as String?);

  String? get url => (_$data['url'] as String?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('artist')) {
      final l$artist = artist;
      result$data['artist'] = l$artist;
    }
    if (_$data.containsKey('author')) {
      final l$author = author;
      result$data['author'] = l$author;
    }
    if (_$data.containsKey('categoryIds')) {
      final l$categoryIds = categoryIds;
      result$data['categoryIds'] = l$categoryIds?.map((e) => e).toList();
    }
    if (_$data.containsKey('chaptersLastFetchedAt')) {
      final l$chaptersLastFetchedAt = chaptersLastFetchedAt;
      result$data['chaptersLastFetchedAt'] = l$chaptersLastFetchedAt == null
          ? null
          : longStringToJson(l$chaptersLastFetchedAt);
    }
    if (_$data.containsKey('description')) {
      final l$description = description;
      result$data['description'] = l$description;
    }
    if (_$data.containsKey('genre')) {
      final l$genre = genre;
      result$data['genre'] = l$genre?.map((e) => e).toList();
    }
    if (_$data.containsKey('id')) {
      final l$id = id;
      result$data['id'] = l$id;
    }
    if (_$data.containsKey('inLibrary')) {
      final l$inLibrary = inLibrary;
      result$data['inLibrary'] = l$inLibrary;
    }
    if (_$data.containsKey('inLibraryAt')) {
      final l$inLibraryAt = inLibraryAt;
      result$data['inLibraryAt'] =
          l$inLibraryAt == null ? null : longStringToJson(l$inLibraryAt);
    }
    if (_$data.containsKey('initialized')) {
      final l$initialized = initialized;
      result$data['initialized'] = l$initialized;
    }
    if (_$data.containsKey('lastFetchedAt')) {
      final l$lastFetchedAt = lastFetchedAt;
      result$data['lastFetchedAt'] =
          l$lastFetchedAt == null ? null : longStringToJson(l$lastFetchedAt);
    }
    if (_$data.containsKey('realUrl')) {
      final l$realUrl = realUrl;
      result$data['realUrl'] = l$realUrl;
    }
    if (_$data.containsKey('sourceId')) {
      final l$sourceId = sourceId;
      result$data['sourceId'] =
          l$sourceId == null ? null : longStringToJson(l$sourceId);
    }
    if (_$data.containsKey('status')) {
      final l$status = status;
      result$data['status'] =
          l$status == null ? null : toJson$Enum$MangaStatus(l$status);
    }
    if (_$data.containsKey('thumbnailUrl')) {
      final l$thumbnailUrl = thumbnailUrl;
      result$data['thumbnailUrl'] = l$thumbnailUrl;
    }
    if (_$data.containsKey('title')) {
      final l$title = title;
      result$data['title'] = l$title;
    }
    if (_$data.containsKey('url')) {
      final l$url = url;
      result$data['url'] = l$url;
    }
    return result$data;
  }

  CopyWith$Input$MangaConditionInput<Input$MangaConditionInput> get copyWith =>
      CopyWith$Input$MangaConditionInput(
        this,
        (i) => i,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$MangaConditionInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$artist = artist;
    final lOther$artist = other.artist;
    if (_$data.containsKey('artist') != other._$data.containsKey('artist')) {
      return false;
    }
    if (l$artist != lOther$artist) {
      return false;
    }
    final l$author = author;
    final lOther$author = other.author;
    if (_$data.containsKey('author') != other._$data.containsKey('author')) {
      return false;
    }
    if (l$author != lOther$author) {
      return false;
    }
    final l$categoryIds = categoryIds;
    final lOther$categoryIds = other.categoryIds;
    if (_$data.containsKey('categoryIds') !=
        other._$data.containsKey('categoryIds')) {
      return false;
    }
    if (l$categoryIds != null && lOther$categoryIds != null) {
      if (l$categoryIds.length != lOther$categoryIds.length) {
        return false;
      }
      for (int i = 0; i < l$categoryIds.length; i++) {
        final l$categoryIds$entry = l$categoryIds[i];
        final lOther$categoryIds$entry = lOther$categoryIds[i];
        if (l$categoryIds$entry != lOther$categoryIds$entry) {
          return false;
        }
      }
    } else if (l$categoryIds != lOther$categoryIds) {
      return false;
    }
    final l$chaptersLastFetchedAt = chaptersLastFetchedAt;
    final lOther$chaptersLastFetchedAt = other.chaptersLastFetchedAt;
    if (_$data.containsKey('chaptersLastFetchedAt') !=
        other._$data.containsKey('chaptersLastFetchedAt')) {
      return false;
    }
    if (l$chaptersLastFetchedAt != lOther$chaptersLastFetchedAt) {
      return false;
    }
    final l$description = description;
    final lOther$description = other.description;
    if (_$data.containsKey('description') !=
        other._$data.containsKey('description')) {
      return false;
    }
    if (l$description != lOther$description) {
      return false;
    }
    final l$genre = genre;
    final lOther$genre = other.genre;
    if (_$data.containsKey('genre') != other._$data.containsKey('genre')) {
      return false;
    }
    if (l$genre != null && lOther$genre != null) {
      if (l$genre.length != lOther$genre.length) {
        return false;
      }
      for (int i = 0; i < l$genre.length; i++) {
        final l$genre$entry = l$genre[i];
        final lOther$genre$entry = lOther$genre[i];
        if (l$genre$entry != lOther$genre$entry) {
          return false;
        }
      }
    } else if (l$genre != lOther$genre) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (_$data.containsKey('id') != other._$data.containsKey('id')) {
      return false;
    }
    if (l$id != lOther$id) {
      return false;
    }
    final l$inLibrary = inLibrary;
    final lOther$inLibrary = other.inLibrary;
    if (_$data.containsKey('inLibrary') !=
        other._$data.containsKey('inLibrary')) {
      return false;
    }
    if (l$inLibrary != lOther$inLibrary) {
      return false;
    }
    final l$inLibraryAt = inLibraryAt;
    final lOther$inLibraryAt = other.inLibraryAt;
    if (_$data.containsKey('inLibraryAt') !=
        other._$data.containsKey('inLibraryAt')) {
      return false;
    }
    if (l$inLibraryAt != lOther$inLibraryAt) {
      return false;
    }
    final l$initialized = initialized;
    final lOther$initialized = other.initialized;
    if (_$data.containsKey('initialized') !=
        other._$data.containsKey('initialized')) {
      return false;
    }
    if (l$initialized != lOther$initialized) {
      return false;
    }
    final l$lastFetchedAt = lastFetchedAt;
    final lOther$lastFetchedAt = other.lastFetchedAt;
    if (_$data.containsKey('lastFetchedAt') !=
        other._$data.containsKey('lastFetchedAt')) {
      return false;
    }
    if (l$lastFetchedAt != lOther$lastFetchedAt) {
      return false;
    }
    final l$realUrl = realUrl;
    final lOther$realUrl = other.realUrl;
    if (_$data.containsKey('realUrl') != other._$data.containsKey('realUrl')) {
      return false;
    }
    if (l$realUrl != lOther$realUrl) {
      return false;
    }
    final l$sourceId = sourceId;
    final lOther$sourceId = other.sourceId;
    if (_$data.containsKey('sourceId') !=
        other._$data.containsKey('sourceId')) {
      return false;
    }
    if (l$sourceId != lOther$sourceId) {
      return false;
    }
    final l$status = status;
    final lOther$status = other.status;
    if (_$data.containsKey('status') != other._$data.containsKey('status')) {
      return false;
    }
    if (l$status != lOther$status) {
      return false;
    }
    final l$thumbnailUrl = thumbnailUrl;
    final lOther$thumbnailUrl = other.thumbnailUrl;
    if (_$data.containsKey('thumbnailUrl') !=
        other._$data.containsKey('thumbnailUrl')) {
      return false;
    }
    if (l$thumbnailUrl != lOther$thumbnailUrl) {
      return false;
    }
    final l$title = title;
    final lOther$title = other.title;
    if (_$data.containsKey('title') != other._$data.containsKey('title')) {
      return false;
    }
    if (l$title != lOther$title) {
      return false;
    }
    final l$url = url;
    final lOther$url = other.url;
    if (_$data.containsKey('url') != other._$data.containsKey('url')) {
      return false;
    }
    if (l$url != lOther$url) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$artist = artist;
    final l$author = author;
    final l$categoryIds = categoryIds;
    final l$chaptersLastFetchedAt = chaptersLastFetchedAt;
    final l$description = description;
    final l$genre = genre;
    final l$id = id;
    final l$inLibrary = inLibrary;
    final l$inLibraryAt = inLibraryAt;
    final l$initialized = initialized;
    final l$lastFetchedAt = lastFetchedAt;
    final l$realUrl = realUrl;
    final l$sourceId = sourceId;
    final l$status = status;
    final l$thumbnailUrl = thumbnailUrl;
    final l$title = title;
    final l$url = url;
    return Object.hashAll([
      _$data.containsKey('artist') ? l$artist : const {},
      _$data.containsKey('author') ? l$author : const {},
      _$data.containsKey('categoryIds')
          ? l$categoryIds == null
              ? null
              : Object.hashAll(l$categoryIds.map((v) => v))
          : const {},
      _$data.containsKey('chaptersLastFetchedAt')
          ? l$chaptersLastFetchedAt
          : const {},
      _$data.containsKey('description') ? l$description : const {},
      _$data.containsKey('genre')
          ? l$genre == null
              ? null
              : Object.hashAll(l$genre.map((v) => v))
          : const {},
      _$data.containsKey('id') ? l$id : const {},
      _$data.containsKey('inLibrary') ? l$inLibrary : const {},
      _$data.containsKey('inLibraryAt') ? l$inLibraryAt : const {},
      _$data.containsKey('initialized') ? l$initialized : const {},
      _$data.containsKey('lastFetchedAt') ? l$lastFetchedAt : const {},
      _$data.containsKey('realUrl') ? l$realUrl : const {},
      _$data.containsKey('sourceId') ? l$sourceId : const {},
      _$data.containsKey('status') ? l$status : const {},
      _$data.containsKey('thumbnailUrl') ? l$thumbnailUrl : const {},
      _$data.containsKey('title') ? l$title : const {},
      _$data.containsKey('url') ? l$url : const {},
    ]);
  }
}

abstract class CopyWith$Input$MangaConditionInput<TRes> {
  factory CopyWith$Input$MangaConditionInput(
    Input$MangaConditionInput instance,
    TRes Function(Input$MangaConditionInput) then,
  ) = _CopyWithImpl$Input$MangaConditionInput;

  factory CopyWith$Input$MangaConditionInput.stub(TRes res) =
      _CopyWithStubImpl$Input$MangaConditionInput;

  TRes call({
    String? artist,
    String? author,
    List<int>? categoryIds,
    String? chaptersLastFetchedAt,
    String? description,
    List<String>? genre,
    int? id,
    bool? inLibrary,
    String? inLibraryAt,
    bool? initialized,
    String? lastFetchedAt,
    String? realUrl,
    String? sourceId,
    Enum$MangaStatus? status,
    String? thumbnailUrl,
    String? title,
    String? url,
  });
}

class _CopyWithImpl$Input$MangaConditionInput<TRes>
    implements CopyWith$Input$MangaConditionInput<TRes> {
  _CopyWithImpl$Input$MangaConditionInput(
    this._instance,
    this._then,
  );

  final Input$MangaConditionInput _instance;

  final TRes Function(Input$MangaConditionInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? artist = _undefined,
    Object? author = _undefined,
    Object? categoryIds = _undefined,
    Object? chaptersLastFetchedAt = _undefined,
    Object? description = _undefined,
    Object? genre = _undefined,
    Object? id = _undefined,
    Object? inLibrary = _undefined,
    Object? inLibraryAt = _undefined,
    Object? initialized = _undefined,
    Object? lastFetchedAt = _undefined,
    Object? realUrl = _undefined,
    Object? sourceId = _undefined,
    Object? status = _undefined,
    Object? thumbnailUrl = _undefined,
    Object? title = _undefined,
    Object? url = _undefined,
  }) =>
      _then(Input$MangaConditionInput._({
        ..._instance._$data,
        if (artist != _undefined) 'artist': (artist as String?),
        if (author != _undefined) 'author': (author as String?),
        if (categoryIds != _undefined)
          'categoryIds': (categoryIds as List<int>?),
        if (chaptersLastFetchedAt != _undefined)
          'chaptersLastFetchedAt': (chaptersLastFetchedAt as String?),
        if (description != _undefined) 'description': (description as String?),
        if (genre != _undefined) 'genre': (genre as List<String>?),
        if (id != _undefined) 'id': (id as int?),
        if (inLibrary != _undefined) 'inLibrary': (inLibrary as bool?),
        if (inLibraryAt != _undefined) 'inLibraryAt': (inLibraryAt as String?),
        if (initialized != _undefined) 'initialized': (initialized as bool?),
        if (lastFetchedAt != _undefined)
          'lastFetchedAt': (lastFetchedAt as String?),
        if (realUrl != _undefined) 'realUrl': (realUrl as String?),
        if (sourceId != _undefined) 'sourceId': (sourceId as String?),
        if (status != _undefined) 'status': (status as Enum$MangaStatus?),
        if (thumbnailUrl != _undefined)
          'thumbnailUrl': (thumbnailUrl as String?),
        if (title != _undefined) 'title': (title as String?),
        if (url != _undefined) 'url': (url as String?),
      }));
}

class _CopyWithStubImpl$Input$MangaConditionInput<TRes>
    implements CopyWith$Input$MangaConditionInput<TRes> {
  _CopyWithStubImpl$Input$MangaConditionInput(this._res);

  TRes _res;

  call({
    String? artist,
    String? author,
    List<int>? categoryIds,
    String? chaptersLastFetchedAt,
    String? description,
    List<String>? genre,
    int? id,
    bool? inLibrary,
    String? inLibraryAt,
    bool? initialized,
    String? lastFetchedAt,
    String? realUrl,
    String? sourceId,
    Enum$MangaStatus? status,
    String? thumbnailUrl,
    String? title,
    String? url,
  }) =>
      _res;
}

class Input$MangaFilterInput {
  factory Input$MangaFilterInput({
    List<Input$MangaFilterInput>? and,
    Input$StringFilterInput? artist,
    Input$StringFilterInput? author,
    Input$IntFilterInput? categoryId,
    Input$LongFilterInput? chaptersLastFetchedAt,
    Input$StringFilterInput? description,
    Input$StringFilterInput? genre,
    Input$IntFilterInput? id,
    Input$BooleanFilterInput? inLibrary,
    Input$LongFilterInput? inLibraryAt,
    Input$BooleanFilterInput? initialized,
    Input$LongFilterInput? lastFetchedAt,
    Input$MangaFilterInput? not,
    List<Input$MangaFilterInput>? or,
    Input$StringFilterInput? realUrl,
    Input$LongFilterInput? sourceId,
    Input$MangaStatusFilterInput? status,
    Input$StringFilterInput? thumbnailUrl,
    Input$StringFilterInput? title,
    Input$StringFilterInput? url,
  }) =>
      Input$MangaFilterInput._({
        if (and != null) r'and': and,
        if (artist != null) r'artist': artist,
        if (author != null) r'author': author,
        if (categoryId != null) r'categoryId': categoryId,
        if (chaptersLastFetchedAt != null)
          r'chaptersLastFetchedAt': chaptersLastFetchedAt,
        if (description != null) r'description': description,
        if (genre != null) r'genre': genre,
        if (id != null) r'id': id,
        if (inLibrary != null) r'inLibrary': inLibrary,
        if (inLibraryAt != null) r'inLibraryAt': inLibraryAt,
        if (initialized != null) r'initialized': initialized,
        if (lastFetchedAt != null) r'lastFetchedAt': lastFetchedAt,
        if (not != null) r'not': not,
        if (or != null) r'or': or,
        if (realUrl != null) r'realUrl': realUrl,
        if (sourceId != null) r'sourceId': sourceId,
        if (status != null) r'status': status,
        if (thumbnailUrl != null) r'thumbnailUrl': thumbnailUrl,
        if (title != null) r'title': title,
        if (url != null) r'url': url,
      });

  Input$MangaFilterInput._(this._$data);

  factory Input$MangaFilterInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('and')) {
      final l$and = data['and'];
      result$data['and'] = (l$and as List<dynamic>?)
          ?.map((e) =>
              Input$MangaFilterInput.fromJson((e as Map<String, dynamic>)))
          .toList();
    }
    if (data.containsKey('artist')) {
      final l$artist = data['artist'];
      result$data['artist'] = l$artist == null
          ? null
          : Input$StringFilterInput.fromJson(
              (l$artist as Map<String, dynamic>));
    }
    if (data.containsKey('author')) {
      final l$author = data['author'];
      result$data['author'] = l$author == null
          ? null
          : Input$StringFilterInput.fromJson(
              (l$author as Map<String, dynamic>));
    }
    if (data.containsKey('categoryId')) {
      final l$categoryId = data['categoryId'];
      result$data['categoryId'] = l$categoryId == null
          ? null
          : Input$IntFilterInput.fromJson(
              (l$categoryId as Map<String, dynamic>));
    }
    if (data.containsKey('chaptersLastFetchedAt')) {
      final l$chaptersLastFetchedAt = data['chaptersLastFetchedAt'];
      result$data['chaptersLastFetchedAt'] = l$chaptersLastFetchedAt == null
          ? null
          : Input$LongFilterInput.fromJson(
              (l$chaptersLastFetchedAt as Map<String, dynamic>));
    }
    if (data.containsKey('description')) {
      final l$description = data['description'];
      result$data['description'] = l$description == null
          ? null
          : Input$StringFilterInput.fromJson(
              (l$description as Map<String, dynamic>));
    }
    if (data.containsKey('genre')) {
      final l$genre = data['genre'];
      result$data['genre'] = l$genre == null
          ? null
          : Input$StringFilterInput.fromJson((l$genre as Map<String, dynamic>));
    }
    if (data.containsKey('id')) {
      final l$id = data['id'];
      result$data['id'] = l$id == null
          ? null
          : Input$IntFilterInput.fromJson((l$id as Map<String, dynamic>));
    }
    if (data.containsKey('inLibrary')) {
      final l$inLibrary = data['inLibrary'];
      result$data['inLibrary'] = l$inLibrary == null
          ? null
          : Input$BooleanFilterInput.fromJson(
              (l$inLibrary as Map<String, dynamic>));
    }
    if (data.containsKey('inLibraryAt')) {
      final l$inLibraryAt = data['inLibraryAt'];
      result$data['inLibraryAt'] = l$inLibraryAt == null
          ? null
          : Input$LongFilterInput.fromJson(
              (l$inLibraryAt as Map<String, dynamic>));
    }
    if (data.containsKey('initialized')) {
      final l$initialized = data['initialized'];
      result$data['initialized'] = l$initialized == null
          ? null
          : Input$BooleanFilterInput.fromJson(
              (l$initialized as Map<String, dynamic>));
    }
    if (data.containsKey('lastFetchedAt')) {
      final l$lastFetchedAt = data['lastFetchedAt'];
      result$data['lastFetchedAt'] = l$lastFetchedAt == null
          ? null
          : Input$LongFilterInput.fromJson(
              (l$lastFetchedAt as Map<String, dynamic>));
    }
    if (data.containsKey('not')) {
      final l$not = data['not'];
      result$data['not'] = l$not == null
          ? null
          : Input$MangaFilterInput.fromJson((l$not as Map<String, dynamic>));
    }
    if (data.containsKey('or')) {
      final l$or = data['or'];
      result$data['or'] = (l$or as List<dynamic>?)
          ?.map((e) =>
              Input$MangaFilterInput.fromJson((e as Map<String, dynamic>)))
          .toList();
    }
    if (data.containsKey('realUrl')) {
      final l$realUrl = data['realUrl'];
      result$data['realUrl'] = l$realUrl == null
          ? null
          : Input$StringFilterInput.fromJson(
              (l$realUrl as Map<String, dynamic>));
    }
    if (data.containsKey('sourceId')) {
      final l$sourceId = data['sourceId'];
      result$data['sourceId'] = l$sourceId == null
          ? null
          : Input$LongFilterInput.fromJson(
              (l$sourceId as Map<String, dynamic>));
    }
    if (data.containsKey('status')) {
      final l$status = data['status'];
      result$data['status'] = l$status == null
          ? null
          : Input$MangaStatusFilterInput.fromJson(
              (l$status as Map<String, dynamic>));
    }
    if (data.containsKey('thumbnailUrl')) {
      final l$thumbnailUrl = data['thumbnailUrl'];
      result$data['thumbnailUrl'] = l$thumbnailUrl == null
          ? null
          : Input$StringFilterInput.fromJson(
              (l$thumbnailUrl as Map<String, dynamic>));
    }
    if (data.containsKey('title')) {
      final l$title = data['title'];
      result$data['title'] = l$title == null
          ? null
          : Input$StringFilterInput.fromJson((l$title as Map<String, dynamic>));
    }
    if (data.containsKey('url')) {
      final l$url = data['url'];
      result$data['url'] = l$url == null
          ? null
          : Input$StringFilterInput.fromJson((l$url as Map<String, dynamic>));
    }
    return Input$MangaFilterInput._(result$data);
  }

  Map<String, dynamic> _$data;

  List<Input$MangaFilterInput>? get and =>
      (_$data['and'] as List<Input$MangaFilterInput>?);

  Input$StringFilterInput? get artist =>
      (_$data['artist'] as Input$StringFilterInput?);

  Input$StringFilterInput? get author =>
      (_$data['author'] as Input$StringFilterInput?);

  Input$IntFilterInput? get categoryId =>
      (_$data['categoryId'] as Input$IntFilterInput?);

  Input$LongFilterInput? get chaptersLastFetchedAt =>
      (_$data['chaptersLastFetchedAt'] as Input$LongFilterInput?);

  Input$StringFilterInput? get description =>
      (_$data['description'] as Input$StringFilterInput?);

  Input$StringFilterInput? get genre =>
      (_$data['genre'] as Input$StringFilterInput?);

  Input$IntFilterInput? get id => (_$data['id'] as Input$IntFilterInput?);

  Input$BooleanFilterInput? get inLibrary =>
      (_$data['inLibrary'] as Input$BooleanFilterInput?);

  Input$LongFilterInput? get inLibraryAt =>
      (_$data['inLibraryAt'] as Input$LongFilterInput?);

  Input$BooleanFilterInput? get initialized =>
      (_$data['initialized'] as Input$BooleanFilterInput?);

  Input$LongFilterInput? get lastFetchedAt =>
      (_$data['lastFetchedAt'] as Input$LongFilterInput?);

  Input$MangaFilterInput? get not => (_$data['not'] as Input$MangaFilterInput?);

  List<Input$MangaFilterInput>? get or =>
      (_$data['or'] as List<Input$MangaFilterInput>?);

  Input$StringFilterInput? get realUrl =>
      (_$data['realUrl'] as Input$StringFilterInput?);

  Input$LongFilterInput? get sourceId =>
      (_$data['sourceId'] as Input$LongFilterInput?);

  Input$MangaStatusFilterInput? get status =>
      (_$data['status'] as Input$MangaStatusFilterInput?);

  Input$StringFilterInput? get thumbnailUrl =>
      (_$data['thumbnailUrl'] as Input$StringFilterInput?);

  Input$StringFilterInput? get title =>
      (_$data['title'] as Input$StringFilterInput?);

  Input$StringFilterInput? get url =>
      (_$data['url'] as Input$StringFilterInput?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('and')) {
      final l$and = and;
      result$data['and'] = l$and?.map((e) => e.toJson()).toList();
    }
    if (_$data.containsKey('artist')) {
      final l$artist = artist;
      result$data['artist'] = l$artist?.toJson();
    }
    if (_$data.containsKey('author')) {
      final l$author = author;
      result$data['author'] = l$author?.toJson();
    }
    if (_$data.containsKey('categoryId')) {
      final l$categoryId = categoryId;
      result$data['categoryId'] = l$categoryId?.toJson();
    }
    if (_$data.containsKey('chaptersLastFetchedAt')) {
      final l$chaptersLastFetchedAt = chaptersLastFetchedAt;
      result$data['chaptersLastFetchedAt'] = l$chaptersLastFetchedAt?.toJson();
    }
    if (_$data.containsKey('description')) {
      final l$description = description;
      result$data['description'] = l$description?.toJson();
    }
    if (_$data.containsKey('genre')) {
      final l$genre = genre;
      result$data['genre'] = l$genre?.toJson();
    }
    if (_$data.containsKey('id')) {
      final l$id = id;
      result$data['id'] = l$id?.toJson();
    }
    if (_$data.containsKey('inLibrary')) {
      final l$inLibrary = inLibrary;
      result$data['inLibrary'] = l$inLibrary?.toJson();
    }
    if (_$data.containsKey('inLibraryAt')) {
      final l$inLibraryAt = inLibraryAt;
      result$data['inLibraryAt'] = l$inLibraryAt?.toJson();
    }
    if (_$data.containsKey('initialized')) {
      final l$initialized = initialized;
      result$data['initialized'] = l$initialized?.toJson();
    }
    if (_$data.containsKey('lastFetchedAt')) {
      final l$lastFetchedAt = lastFetchedAt;
      result$data['lastFetchedAt'] = l$lastFetchedAt?.toJson();
    }
    if (_$data.containsKey('not')) {
      final l$not = not;
      result$data['not'] = l$not?.toJson();
    }
    if (_$data.containsKey('or')) {
      final l$or = or;
      result$data['or'] = l$or?.map((e) => e.toJson()).toList();
    }
    if (_$data.containsKey('realUrl')) {
      final l$realUrl = realUrl;
      result$data['realUrl'] = l$realUrl?.toJson();
    }
    if (_$data.containsKey('sourceId')) {
      final l$sourceId = sourceId;
      result$data['sourceId'] = l$sourceId?.toJson();
    }
    if (_$data.containsKey('status')) {
      final l$status = status;
      result$data['status'] = l$status?.toJson();
    }
    if (_$data.containsKey('thumbnailUrl')) {
      final l$thumbnailUrl = thumbnailUrl;
      result$data['thumbnailUrl'] = l$thumbnailUrl?.toJson();
    }
    if (_$data.containsKey('title')) {
      final l$title = title;
      result$data['title'] = l$title?.toJson();
    }
    if (_$data.containsKey('url')) {
      final l$url = url;
      result$data['url'] = l$url?.toJson();
    }
    return result$data;
  }

  CopyWith$Input$MangaFilterInput<Input$MangaFilterInput> get copyWith =>
      CopyWith$Input$MangaFilterInput(
        this,
        (i) => i,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$MangaFilterInput || runtimeType != other.runtimeType) {
      return false;
    }
    final l$and = and;
    final lOther$and = other.and;
    if (_$data.containsKey('and') != other._$data.containsKey('and')) {
      return false;
    }
    if (l$and != null && lOther$and != null) {
      if (l$and.length != lOther$and.length) {
        return false;
      }
      for (int i = 0; i < l$and.length; i++) {
        final l$and$entry = l$and[i];
        final lOther$and$entry = lOther$and[i];
        if (l$and$entry != lOther$and$entry) {
          return false;
        }
      }
    } else if (l$and != lOther$and) {
      return false;
    }
    final l$artist = artist;
    final lOther$artist = other.artist;
    if (_$data.containsKey('artist') != other._$data.containsKey('artist')) {
      return false;
    }
    if (l$artist != lOther$artist) {
      return false;
    }
    final l$author = author;
    final lOther$author = other.author;
    if (_$data.containsKey('author') != other._$data.containsKey('author')) {
      return false;
    }
    if (l$author != lOther$author) {
      return false;
    }
    final l$categoryId = categoryId;
    final lOther$categoryId = other.categoryId;
    if (_$data.containsKey('categoryId') !=
        other._$data.containsKey('categoryId')) {
      return false;
    }
    if (l$categoryId != lOther$categoryId) {
      return false;
    }
    final l$chaptersLastFetchedAt = chaptersLastFetchedAt;
    final lOther$chaptersLastFetchedAt = other.chaptersLastFetchedAt;
    if (_$data.containsKey('chaptersLastFetchedAt') !=
        other._$data.containsKey('chaptersLastFetchedAt')) {
      return false;
    }
    if (l$chaptersLastFetchedAt != lOther$chaptersLastFetchedAt) {
      return false;
    }
    final l$description = description;
    final lOther$description = other.description;
    if (_$data.containsKey('description') !=
        other._$data.containsKey('description')) {
      return false;
    }
    if (l$description != lOther$description) {
      return false;
    }
    final l$genre = genre;
    final lOther$genre = other.genre;
    if (_$data.containsKey('genre') != other._$data.containsKey('genre')) {
      return false;
    }
    if (l$genre != lOther$genre) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (_$data.containsKey('id') != other._$data.containsKey('id')) {
      return false;
    }
    if (l$id != lOther$id) {
      return false;
    }
    final l$inLibrary = inLibrary;
    final lOther$inLibrary = other.inLibrary;
    if (_$data.containsKey('inLibrary') !=
        other._$data.containsKey('inLibrary')) {
      return false;
    }
    if (l$inLibrary != lOther$inLibrary) {
      return false;
    }
    final l$inLibraryAt = inLibraryAt;
    final lOther$inLibraryAt = other.inLibraryAt;
    if (_$data.containsKey('inLibraryAt') !=
        other._$data.containsKey('inLibraryAt')) {
      return false;
    }
    if (l$inLibraryAt != lOther$inLibraryAt) {
      return false;
    }
    final l$initialized = initialized;
    final lOther$initialized = other.initialized;
    if (_$data.containsKey('initialized') !=
        other._$data.containsKey('initialized')) {
      return false;
    }
    if (l$initialized != lOther$initialized) {
      return false;
    }
    final l$lastFetchedAt = lastFetchedAt;
    final lOther$lastFetchedAt = other.lastFetchedAt;
    if (_$data.containsKey('lastFetchedAt') !=
        other._$data.containsKey('lastFetchedAt')) {
      return false;
    }
    if (l$lastFetchedAt != lOther$lastFetchedAt) {
      return false;
    }
    final l$not = not;
    final lOther$not = other.not;
    if (_$data.containsKey('not') != other._$data.containsKey('not')) {
      return false;
    }
    if (l$not != lOther$not) {
      return false;
    }
    final l$or = or;
    final lOther$or = other.or;
    if (_$data.containsKey('or') != other._$data.containsKey('or')) {
      return false;
    }
    if (l$or != null && lOther$or != null) {
      if (l$or.length != lOther$or.length) {
        return false;
      }
      for (int i = 0; i < l$or.length; i++) {
        final l$or$entry = l$or[i];
        final lOther$or$entry = lOther$or[i];
        if (l$or$entry != lOther$or$entry) {
          return false;
        }
      }
    } else if (l$or != lOther$or) {
      return false;
    }
    final l$realUrl = realUrl;
    final lOther$realUrl = other.realUrl;
    if (_$data.containsKey('realUrl') != other._$data.containsKey('realUrl')) {
      return false;
    }
    if (l$realUrl != lOther$realUrl) {
      return false;
    }
    final l$sourceId = sourceId;
    final lOther$sourceId = other.sourceId;
    if (_$data.containsKey('sourceId') !=
        other._$data.containsKey('sourceId')) {
      return false;
    }
    if (l$sourceId != lOther$sourceId) {
      return false;
    }
    final l$status = status;
    final lOther$status = other.status;
    if (_$data.containsKey('status') != other._$data.containsKey('status')) {
      return false;
    }
    if (l$status != lOther$status) {
      return false;
    }
    final l$thumbnailUrl = thumbnailUrl;
    final lOther$thumbnailUrl = other.thumbnailUrl;
    if (_$data.containsKey('thumbnailUrl') !=
        other._$data.containsKey('thumbnailUrl')) {
      return false;
    }
    if (l$thumbnailUrl != lOther$thumbnailUrl) {
      return false;
    }
    final l$title = title;
    final lOther$title = other.title;
    if (_$data.containsKey('title') != other._$data.containsKey('title')) {
      return false;
    }
    if (l$title != lOther$title) {
      return false;
    }
    final l$url = url;
    final lOther$url = other.url;
    if (_$data.containsKey('url') != other._$data.containsKey('url')) {
      return false;
    }
    if (l$url != lOther$url) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$and = and;
    final l$artist = artist;
    final l$author = author;
    final l$categoryId = categoryId;
    final l$chaptersLastFetchedAt = chaptersLastFetchedAt;
    final l$description = description;
    final l$genre = genre;
    final l$id = id;
    final l$inLibrary = inLibrary;
    final l$inLibraryAt = inLibraryAt;
    final l$initialized = initialized;
    final l$lastFetchedAt = lastFetchedAt;
    final l$not = not;
    final l$or = or;
    final l$realUrl = realUrl;
    final l$sourceId = sourceId;
    final l$status = status;
    final l$thumbnailUrl = thumbnailUrl;
    final l$title = title;
    final l$url = url;
    return Object.hashAll([
      _$data.containsKey('and')
          ? l$and == null
              ? null
              : Object.hashAll(l$and.map((v) => v))
          : const {},
      _$data.containsKey('artist') ? l$artist : const {},
      _$data.containsKey('author') ? l$author : const {},
      _$data.containsKey('categoryId') ? l$categoryId : const {},
      _$data.containsKey('chaptersLastFetchedAt')
          ? l$chaptersLastFetchedAt
          : const {},
      _$data.containsKey('description') ? l$description : const {},
      _$data.containsKey('genre') ? l$genre : const {},
      _$data.containsKey('id') ? l$id : const {},
      _$data.containsKey('inLibrary') ? l$inLibrary : const {},
      _$data.containsKey('inLibraryAt') ? l$inLibraryAt : const {},
      _$data.containsKey('initialized') ? l$initialized : const {},
      _$data.containsKey('lastFetchedAt') ? l$lastFetchedAt : const {},
      _$data.containsKey('not') ? l$not : const {},
      _$data.containsKey('or')
          ? l$or == null
              ? null
              : Object.hashAll(l$or.map((v) => v))
          : const {},
      _$data.containsKey('realUrl') ? l$realUrl : const {},
      _$data.containsKey('sourceId') ? l$sourceId : const {},
      _$data.containsKey('status') ? l$status : const {},
      _$data.containsKey('thumbnailUrl') ? l$thumbnailUrl : const {},
      _$data.containsKey('title') ? l$title : const {},
      _$data.containsKey('url') ? l$url : const {},
    ]);
  }
}

abstract class CopyWith$Input$MangaFilterInput<TRes> {
  factory CopyWith$Input$MangaFilterInput(
    Input$MangaFilterInput instance,
    TRes Function(Input$MangaFilterInput) then,
  ) = _CopyWithImpl$Input$MangaFilterInput;

  factory CopyWith$Input$MangaFilterInput.stub(TRes res) =
      _CopyWithStubImpl$Input$MangaFilterInput;

  TRes call({
    List<Input$MangaFilterInput>? and,
    Input$StringFilterInput? artist,
    Input$StringFilterInput? author,
    Input$IntFilterInput? categoryId,
    Input$LongFilterInput? chaptersLastFetchedAt,
    Input$StringFilterInput? description,
    Input$StringFilterInput? genre,
    Input$IntFilterInput? id,
    Input$BooleanFilterInput? inLibrary,
    Input$LongFilterInput? inLibraryAt,
    Input$BooleanFilterInput? initialized,
    Input$LongFilterInput? lastFetchedAt,
    Input$MangaFilterInput? not,
    List<Input$MangaFilterInput>? or,
    Input$StringFilterInput? realUrl,
    Input$LongFilterInput? sourceId,
    Input$MangaStatusFilterInput? status,
    Input$StringFilterInput? thumbnailUrl,
    Input$StringFilterInput? title,
    Input$StringFilterInput? url,
  });
  TRes and(
      Iterable<Input$MangaFilterInput>? Function(
              Iterable<
                  CopyWith$Input$MangaFilterInput<Input$MangaFilterInput>>?)
          _fn);
  CopyWith$Input$StringFilterInput<TRes> get artist;
  CopyWith$Input$StringFilterInput<TRes> get author;
  CopyWith$Input$IntFilterInput<TRes> get categoryId;
  CopyWith$Input$LongFilterInput<TRes> get chaptersLastFetchedAt;
  CopyWith$Input$StringFilterInput<TRes> get description;
  CopyWith$Input$StringFilterInput<TRes> get genre;
  CopyWith$Input$IntFilterInput<TRes> get id;
  CopyWith$Input$BooleanFilterInput<TRes> get inLibrary;
  CopyWith$Input$LongFilterInput<TRes> get inLibraryAt;
  CopyWith$Input$BooleanFilterInput<TRes> get initialized;
  CopyWith$Input$LongFilterInput<TRes> get lastFetchedAt;
  CopyWith$Input$MangaFilterInput<TRes> get not;
  TRes or(
      Iterable<Input$MangaFilterInput>? Function(
              Iterable<
                  CopyWith$Input$MangaFilterInput<Input$MangaFilterInput>>?)
          _fn);
  CopyWith$Input$StringFilterInput<TRes> get realUrl;
  CopyWith$Input$LongFilterInput<TRes> get sourceId;
  CopyWith$Input$MangaStatusFilterInput<TRes> get status;
  CopyWith$Input$StringFilterInput<TRes> get thumbnailUrl;
  CopyWith$Input$StringFilterInput<TRes> get title;
  CopyWith$Input$StringFilterInput<TRes> get url;
}

class _CopyWithImpl$Input$MangaFilterInput<TRes>
    implements CopyWith$Input$MangaFilterInput<TRes> {
  _CopyWithImpl$Input$MangaFilterInput(
    this._instance,
    this._then,
  );

  final Input$MangaFilterInput _instance;

  final TRes Function(Input$MangaFilterInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? and = _undefined,
    Object? artist = _undefined,
    Object? author = _undefined,
    Object? categoryId = _undefined,
    Object? chaptersLastFetchedAt = _undefined,
    Object? description = _undefined,
    Object? genre = _undefined,
    Object? id = _undefined,
    Object? inLibrary = _undefined,
    Object? inLibraryAt = _undefined,
    Object? initialized = _undefined,
    Object? lastFetchedAt = _undefined,
    Object? not = _undefined,
    Object? or = _undefined,
    Object? realUrl = _undefined,
    Object? sourceId = _undefined,
    Object? status = _undefined,
    Object? thumbnailUrl = _undefined,
    Object? title = _undefined,
    Object? url = _undefined,
  }) =>
      _then(Input$MangaFilterInput._({
        ..._instance._$data,
        if (and != _undefined) 'and': (and as List<Input$MangaFilterInput>?),
        if (artist != _undefined)
          'artist': (artist as Input$StringFilterInput?),
        if (author != _undefined)
          'author': (author as Input$StringFilterInput?),
        if (categoryId != _undefined)
          'categoryId': (categoryId as Input$IntFilterInput?),
        if (chaptersLastFetchedAt != _undefined)
          'chaptersLastFetchedAt':
              (chaptersLastFetchedAt as Input$LongFilterInput?),
        if (description != _undefined)
          'description': (description as Input$StringFilterInput?),
        if (genre != _undefined) 'genre': (genre as Input$StringFilterInput?),
        if (id != _undefined) 'id': (id as Input$IntFilterInput?),
        if (inLibrary != _undefined)
          'inLibrary': (inLibrary as Input$BooleanFilterInput?),
        if (inLibraryAt != _undefined)
          'inLibraryAt': (inLibraryAt as Input$LongFilterInput?),
        if (initialized != _undefined)
          'initialized': (initialized as Input$BooleanFilterInput?),
        if (lastFetchedAt != _undefined)
          'lastFetchedAt': (lastFetchedAt as Input$LongFilterInput?),
        if (not != _undefined) 'not': (not as Input$MangaFilterInput?),
        if (or != _undefined) 'or': (or as List<Input$MangaFilterInput>?),
        if (realUrl != _undefined)
          'realUrl': (realUrl as Input$StringFilterInput?),
        if (sourceId != _undefined)
          'sourceId': (sourceId as Input$LongFilterInput?),
        if (status != _undefined)
          'status': (status as Input$MangaStatusFilterInput?),
        if (thumbnailUrl != _undefined)
          'thumbnailUrl': (thumbnailUrl as Input$StringFilterInput?),
        if (title != _undefined) 'title': (title as Input$StringFilterInput?),
        if (url != _undefined) 'url': (url as Input$StringFilterInput?),
      }));

  TRes and(
          Iterable<Input$MangaFilterInput>? Function(
                  Iterable<
                      CopyWith$Input$MangaFilterInput<Input$MangaFilterInput>>?)
              _fn) =>
      call(
          and: _fn(_instance.and?.map((e) => CopyWith$Input$MangaFilterInput(
                e,
                (i) => i,
              )))?.toList());

  CopyWith$Input$StringFilterInput<TRes> get artist {
    final local$artist = _instance.artist;
    return local$artist == null
        ? CopyWith$Input$StringFilterInput.stub(_then(_instance))
        : CopyWith$Input$StringFilterInput(
            local$artist, (e) => call(artist: e));
  }

  CopyWith$Input$StringFilterInput<TRes> get author {
    final local$author = _instance.author;
    return local$author == null
        ? CopyWith$Input$StringFilterInput.stub(_then(_instance))
        : CopyWith$Input$StringFilterInput(
            local$author, (e) => call(author: e));
  }

  CopyWith$Input$IntFilterInput<TRes> get categoryId {
    final local$categoryId = _instance.categoryId;
    return local$categoryId == null
        ? CopyWith$Input$IntFilterInput.stub(_then(_instance))
        : CopyWith$Input$IntFilterInput(
            local$categoryId, (e) => call(categoryId: e));
  }

  CopyWith$Input$LongFilterInput<TRes> get chaptersLastFetchedAt {
    final local$chaptersLastFetchedAt = _instance.chaptersLastFetchedAt;
    return local$chaptersLastFetchedAt == null
        ? CopyWith$Input$LongFilterInput.stub(_then(_instance))
        : CopyWith$Input$LongFilterInput(
            local$chaptersLastFetchedAt, (e) => call(chaptersLastFetchedAt: e));
  }

  CopyWith$Input$StringFilterInput<TRes> get description {
    final local$description = _instance.description;
    return local$description == null
        ? CopyWith$Input$StringFilterInput.stub(_then(_instance))
        : CopyWith$Input$StringFilterInput(
            local$description, (e) => call(description: e));
  }

  CopyWith$Input$StringFilterInput<TRes> get genre {
    final local$genre = _instance.genre;
    return local$genre == null
        ? CopyWith$Input$StringFilterInput.stub(_then(_instance))
        : CopyWith$Input$StringFilterInput(local$genre, (e) => call(genre: e));
  }

  CopyWith$Input$IntFilterInput<TRes> get id {
    final local$id = _instance.id;
    return local$id == null
        ? CopyWith$Input$IntFilterInput.stub(_then(_instance))
        : CopyWith$Input$IntFilterInput(local$id, (e) => call(id: e));
  }

  CopyWith$Input$BooleanFilterInput<TRes> get inLibrary {
    final local$inLibrary = _instance.inLibrary;
    return local$inLibrary == null
        ? CopyWith$Input$BooleanFilterInput.stub(_then(_instance))
        : CopyWith$Input$BooleanFilterInput(
            local$inLibrary, (e) => call(inLibrary: e));
  }

  CopyWith$Input$LongFilterInput<TRes> get inLibraryAt {
    final local$inLibraryAt = _instance.inLibraryAt;
    return local$inLibraryAt == null
        ? CopyWith$Input$LongFilterInput.stub(_then(_instance))
        : CopyWith$Input$LongFilterInput(
            local$inLibraryAt, (e) => call(inLibraryAt: e));
  }

  CopyWith$Input$BooleanFilterInput<TRes> get initialized {
    final local$initialized = _instance.initialized;
    return local$initialized == null
        ? CopyWith$Input$BooleanFilterInput.stub(_then(_instance))
        : CopyWith$Input$BooleanFilterInput(
            local$initialized, (e) => call(initialized: e));
  }

  CopyWith$Input$LongFilterInput<TRes> get lastFetchedAt {
    final local$lastFetchedAt = _instance.lastFetchedAt;
    return local$lastFetchedAt == null
        ? CopyWith$Input$LongFilterInput.stub(_then(_instance))
        : CopyWith$Input$LongFilterInput(
            local$lastFetchedAt, (e) => call(lastFetchedAt: e));
  }

  CopyWith$Input$MangaFilterInput<TRes> get not {
    final local$not = _instance.not;
    return local$not == null
        ? CopyWith$Input$MangaFilterInput.stub(_then(_instance))
        : CopyWith$Input$MangaFilterInput(local$not, (e) => call(not: e));
  }

  TRes or(
          Iterable<Input$MangaFilterInput>? Function(
                  Iterable<
                      CopyWith$Input$MangaFilterInput<Input$MangaFilterInput>>?)
              _fn) =>
      call(
          or: _fn(_instance.or?.map((e) => CopyWith$Input$MangaFilterInput(
                e,
                (i) => i,
              )))?.toList());

  CopyWith$Input$StringFilterInput<TRes> get realUrl {
    final local$realUrl = _instance.realUrl;
    return local$realUrl == null
        ? CopyWith$Input$StringFilterInput.stub(_then(_instance))
        : CopyWith$Input$StringFilterInput(
            local$realUrl, (e) => call(realUrl: e));
  }

  CopyWith$Input$LongFilterInput<TRes> get sourceId {
    final local$sourceId = _instance.sourceId;
    return local$sourceId == null
        ? CopyWith$Input$LongFilterInput.stub(_then(_instance))
        : CopyWith$Input$LongFilterInput(
            local$sourceId, (e) => call(sourceId: e));
  }

  CopyWith$Input$MangaStatusFilterInput<TRes> get status {
    final local$status = _instance.status;
    return local$status == null
        ? CopyWith$Input$MangaStatusFilterInput.stub(_then(_instance))
        : CopyWith$Input$MangaStatusFilterInput(
            local$status, (e) => call(status: e));
  }

  CopyWith$Input$StringFilterInput<TRes> get thumbnailUrl {
    final local$thumbnailUrl = _instance.thumbnailUrl;
    return local$thumbnailUrl == null
        ? CopyWith$Input$StringFilterInput.stub(_then(_instance))
        : CopyWith$Input$StringFilterInput(
            local$thumbnailUrl, (e) => call(thumbnailUrl: e));
  }

  CopyWith$Input$StringFilterInput<TRes> get title {
    final local$title = _instance.title;
    return local$title == null
        ? CopyWith$Input$StringFilterInput.stub(_then(_instance))
        : CopyWith$Input$StringFilterInput(local$title, (e) => call(title: e));
  }

  CopyWith$Input$StringFilterInput<TRes> get url {
    final local$url = _instance.url;
    return local$url == null
        ? CopyWith$Input$StringFilterInput.stub(_then(_instance))
        : CopyWith$Input$StringFilterInput(local$url, (e) => call(url: e));
  }
}

class _CopyWithStubImpl$Input$MangaFilterInput<TRes>
    implements CopyWith$Input$MangaFilterInput<TRes> {
  _CopyWithStubImpl$Input$MangaFilterInput(this._res);

  TRes _res;

  call({
    List<Input$MangaFilterInput>? and,
    Input$StringFilterInput? artist,
    Input$StringFilterInput? author,
    Input$IntFilterInput? categoryId,
    Input$LongFilterInput? chaptersLastFetchedAt,
    Input$StringFilterInput? description,
    Input$StringFilterInput? genre,
    Input$IntFilterInput? id,
    Input$BooleanFilterInput? inLibrary,
    Input$LongFilterInput? inLibraryAt,
    Input$BooleanFilterInput? initialized,
    Input$LongFilterInput? lastFetchedAt,
    Input$MangaFilterInput? not,
    List<Input$MangaFilterInput>? or,
    Input$StringFilterInput? realUrl,
    Input$LongFilterInput? sourceId,
    Input$MangaStatusFilterInput? status,
    Input$StringFilterInput? thumbnailUrl,
    Input$StringFilterInput? title,
    Input$StringFilterInput? url,
  }) =>
      _res;

  and(_fn) => _res;

  CopyWith$Input$StringFilterInput<TRes> get artist =>
      CopyWith$Input$StringFilterInput.stub(_res);

  CopyWith$Input$StringFilterInput<TRes> get author =>
      CopyWith$Input$StringFilterInput.stub(_res);

  CopyWith$Input$IntFilterInput<TRes> get categoryId =>
      CopyWith$Input$IntFilterInput.stub(_res);

  CopyWith$Input$LongFilterInput<TRes> get chaptersLastFetchedAt =>
      CopyWith$Input$LongFilterInput.stub(_res);

  CopyWith$Input$StringFilterInput<TRes> get description =>
      CopyWith$Input$StringFilterInput.stub(_res);

  CopyWith$Input$StringFilterInput<TRes> get genre =>
      CopyWith$Input$StringFilterInput.stub(_res);

  CopyWith$Input$IntFilterInput<TRes> get id =>
      CopyWith$Input$IntFilterInput.stub(_res);

  CopyWith$Input$BooleanFilterInput<TRes> get inLibrary =>
      CopyWith$Input$BooleanFilterInput.stub(_res);

  CopyWith$Input$LongFilterInput<TRes> get inLibraryAt =>
      CopyWith$Input$LongFilterInput.stub(_res);

  CopyWith$Input$BooleanFilterInput<TRes> get initialized =>
      CopyWith$Input$BooleanFilterInput.stub(_res);

  CopyWith$Input$LongFilterInput<TRes> get lastFetchedAt =>
      CopyWith$Input$LongFilterInput.stub(_res);

  CopyWith$Input$MangaFilterInput<TRes> get not =>
      CopyWith$Input$MangaFilterInput.stub(_res);

  or(_fn) => _res;

  CopyWith$Input$StringFilterInput<TRes> get realUrl =>
      CopyWith$Input$StringFilterInput.stub(_res);

  CopyWith$Input$LongFilterInput<TRes> get sourceId =>
      CopyWith$Input$LongFilterInput.stub(_res);

  CopyWith$Input$MangaStatusFilterInput<TRes> get status =>
      CopyWith$Input$MangaStatusFilterInput.stub(_res);

  CopyWith$Input$StringFilterInput<TRes> get thumbnailUrl =>
      CopyWith$Input$StringFilterInput.stub(_res);

  CopyWith$Input$StringFilterInput<TRes> get title =>
      CopyWith$Input$StringFilterInput.stub(_res);

  CopyWith$Input$StringFilterInput<TRes> get url =>
      CopyWith$Input$StringFilterInput.stub(_res);
}

class Input$MangaMetaTypeInput {
  factory Input$MangaMetaTypeInput({
    required String key,
    required int mangaId,
    required String value,
  }) =>
      Input$MangaMetaTypeInput._({
        r'key': key,
        r'mangaId': mangaId,
        r'value': value,
      });

  Input$MangaMetaTypeInput._(this._$data);

  factory Input$MangaMetaTypeInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$key = data['key'];
    result$data['key'] = (l$key as String);
    final l$mangaId = data['mangaId'];
    result$data['mangaId'] = (l$mangaId as int);
    final l$value = data['value'];
    result$data['value'] = (l$value as String);
    return Input$MangaMetaTypeInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String get key => (_$data['key'] as String);

  int get mangaId => (_$data['mangaId'] as int);

  String get value => (_$data['value'] as String);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$key = key;
    result$data['key'] = l$key;
    final l$mangaId = mangaId;
    result$data['mangaId'] = l$mangaId;
    final l$value = value;
    result$data['value'] = l$value;
    return result$data;
  }

  CopyWith$Input$MangaMetaTypeInput<Input$MangaMetaTypeInput> get copyWith =>
      CopyWith$Input$MangaMetaTypeInput(
        this,
        (i) => i,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$MangaMetaTypeInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$key = key;
    final lOther$key = other.key;
    if (l$key != lOther$key) {
      return false;
    }
    final l$mangaId = mangaId;
    final lOther$mangaId = other.mangaId;
    if (l$mangaId != lOther$mangaId) {
      return false;
    }
    final l$value = value;
    final lOther$value = other.value;
    if (l$value != lOther$value) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$key = key;
    final l$mangaId = mangaId;
    final l$value = value;
    return Object.hashAll([
      l$key,
      l$mangaId,
      l$value,
    ]);
  }
}

abstract class CopyWith$Input$MangaMetaTypeInput<TRes> {
  factory CopyWith$Input$MangaMetaTypeInput(
    Input$MangaMetaTypeInput instance,
    TRes Function(Input$MangaMetaTypeInput) then,
  ) = _CopyWithImpl$Input$MangaMetaTypeInput;

  factory CopyWith$Input$MangaMetaTypeInput.stub(TRes res) =
      _CopyWithStubImpl$Input$MangaMetaTypeInput;

  TRes call({
    String? key,
    int? mangaId,
    String? value,
  });
}

class _CopyWithImpl$Input$MangaMetaTypeInput<TRes>
    implements CopyWith$Input$MangaMetaTypeInput<TRes> {
  _CopyWithImpl$Input$MangaMetaTypeInput(
    this._instance,
    this._then,
  );

  final Input$MangaMetaTypeInput _instance;

  final TRes Function(Input$MangaMetaTypeInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? key = _undefined,
    Object? mangaId = _undefined,
    Object? value = _undefined,
  }) =>
      _then(Input$MangaMetaTypeInput._({
        ..._instance._$data,
        if (key != _undefined && key != null) 'key': (key as String),
        if (mangaId != _undefined && mangaId != null)
          'mangaId': (mangaId as int),
        if (value != _undefined && value != null) 'value': (value as String),
      }));
}

class _CopyWithStubImpl$Input$MangaMetaTypeInput<TRes>
    implements CopyWith$Input$MangaMetaTypeInput<TRes> {
  _CopyWithStubImpl$Input$MangaMetaTypeInput(this._res);

  TRes _res;

  call({
    String? key,
    int? mangaId,
    String? value,
  }) =>
      _res;
}

class Input$MangaOrderInput {
  factory Input$MangaOrderInput({
    required Enum$MangaOrderBy by,
    Enum$SortOrder? byType,
  }) =>
      Input$MangaOrderInput._({
        r'by': by,
        if (byType != null) r'byType': byType,
      });

  Input$MangaOrderInput._(this._$data);

  factory Input$MangaOrderInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$by = data['by'];
    result$data['by'] = fromJson$Enum$MangaOrderBy((l$by as String));
    if (data.containsKey('byType')) {
      final l$byType = data['byType'];
      result$data['byType'] = l$byType == null
          ? null
          : fromJson$Enum$SortOrder((l$byType as String));
    }
    return Input$MangaOrderInput._(result$data);
  }

  Map<String, dynamic> _$data;

  Enum$MangaOrderBy get by => (_$data['by'] as Enum$MangaOrderBy);

  Enum$SortOrder? get byType => (_$data['byType'] as Enum$SortOrder?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$by = by;
    result$data['by'] = toJson$Enum$MangaOrderBy(l$by);
    if (_$data.containsKey('byType')) {
      final l$byType = byType;
      result$data['byType'] =
          l$byType == null ? null : toJson$Enum$SortOrder(l$byType);
    }
    return result$data;
  }

  CopyWith$Input$MangaOrderInput<Input$MangaOrderInput> get copyWith =>
      CopyWith$Input$MangaOrderInput(
        this,
        (i) => i,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$MangaOrderInput || runtimeType != other.runtimeType) {
      return false;
    }
    final l$by = by;
    final lOther$by = other.by;
    if (l$by != lOther$by) {
      return false;
    }
    final l$byType = byType;
    final lOther$byType = other.byType;
    if (_$data.containsKey('byType') != other._$data.containsKey('byType')) {
      return false;
    }
    if (l$byType != lOther$byType) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$by = by;
    final l$byType = byType;
    return Object.hashAll([
      l$by,
      _$data.containsKey('byType') ? l$byType : const {},
    ]);
  }
}

abstract class CopyWith$Input$MangaOrderInput<TRes> {
  factory CopyWith$Input$MangaOrderInput(
    Input$MangaOrderInput instance,
    TRes Function(Input$MangaOrderInput) then,
  ) = _CopyWithImpl$Input$MangaOrderInput;

  factory CopyWith$Input$MangaOrderInput.stub(TRes res) =
      _CopyWithStubImpl$Input$MangaOrderInput;

  TRes call({
    Enum$MangaOrderBy? by,
    Enum$SortOrder? byType,
  });
}

class _CopyWithImpl$Input$MangaOrderInput<TRes>
    implements CopyWith$Input$MangaOrderInput<TRes> {
  _CopyWithImpl$Input$MangaOrderInput(
    this._instance,
    this._then,
  );

  final Input$MangaOrderInput _instance;

  final TRes Function(Input$MangaOrderInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? by = _undefined,
    Object? byType = _undefined,
  }) =>
      _then(Input$MangaOrderInput._({
        ..._instance._$data,
        if (by != _undefined && by != null) 'by': (by as Enum$MangaOrderBy),
        if (byType != _undefined) 'byType': (byType as Enum$SortOrder?),
      }));
}

class _CopyWithStubImpl$Input$MangaOrderInput<TRes>
    implements CopyWith$Input$MangaOrderInput<TRes> {
  _CopyWithStubImpl$Input$MangaOrderInput(this._res);

  TRes _res;

  call({
    Enum$MangaOrderBy? by,
    Enum$SortOrder? byType,
  }) =>
      _res;
}

class Input$MangaStatusFilterInput {
  factory Input$MangaStatusFilterInput({
    Enum$MangaStatus? distinctFrom,
    List<Enum$MangaStatus>? distinctFromAll,
    List<Enum$MangaStatus>? distinctFromAny,
    Enum$MangaStatus? equalTo,
    Enum$MangaStatus? greaterThan,
    Enum$MangaStatus? greaterThanOrEqualTo,
    List<Enum$MangaStatus>? $in,
    bool? isNull,
    Enum$MangaStatus? lessThan,
    Enum$MangaStatus? lessThanOrEqualTo,
    Enum$MangaStatus? notDistinctFrom,
    Enum$MangaStatus? notEqualTo,
    List<Enum$MangaStatus>? notEqualToAll,
    List<Enum$MangaStatus>? notEqualToAny,
    List<Enum$MangaStatus>? notIn,
  }) =>
      Input$MangaStatusFilterInput._({
        if (distinctFrom != null) r'distinctFrom': distinctFrom,
        if (distinctFromAll != null) r'distinctFromAll': distinctFromAll,
        if (distinctFromAny != null) r'distinctFromAny': distinctFromAny,
        if (equalTo != null) r'equalTo': equalTo,
        if (greaterThan != null) r'greaterThan': greaterThan,
        if (greaterThanOrEqualTo != null)
          r'greaterThanOrEqualTo': greaterThanOrEqualTo,
        if ($in != null) r'in': $in,
        if (isNull != null) r'isNull': isNull,
        if (lessThan != null) r'lessThan': lessThan,
        if (lessThanOrEqualTo != null) r'lessThanOrEqualTo': lessThanOrEqualTo,
        if (notDistinctFrom != null) r'notDistinctFrom': notDistinctFrom,
        if (notEqualTo != null) r'notEqualTo': notEqualTo,
        if (notEqualToAll != null) r'notEqualToAll': notEqualToAll,
        if (notEqualToAny != null) r'notEqualToAny': notEqualToAny,
        if (notIn != null) r'notIn': notIn,
      });

  Input$MangaStatusFilterInput._(this._$data);

  factory Input$MangaStatusFilterInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('distinctFrom')) {
      final l$distinctFrom = data['distinctFrom'];
      result$data['distinctFrom'] = l$distinctFrom == null
          ? null
          : fromJson$Enum$MangaStatus((l$distinctFrom as String));
    }
    if (data.containsKey('distinctFromAll')) {
      final l$distinctFromAll = data['distinctFromAll'];
      result$data['distinctFromAll'] = (l$distinctFromAll as List<dynamic>?)
          ?.map((e) => fromJson$Enum$MangaStatus((e as String)))
          .toList();
    }
    if (data.containsKey('distinctFromAny')) {
      final l$distinctFromAny = data['distinctFromAny'];
      result$data['distinctFromAny'] = (l$distinctFromAny as List<dynamic>?)
          ?.map((e) => fromJson$Enum$MangaStatus((e as String)))
          .toList();
    }
    if (data.containsKey('equalTo')) {
      final l$equalTo = data['equalTo'];
      result$data['equalTo'] = l$equalTo == null
          ? null
          : fromJson$Enum$MangaStatus((l$equalTo as String));
    }
    if (data.containsKey('greaterThan')) {
      final l$greaterThan = data['greaterThan'];
      result$data['greaterThan'] = l$greaterThan == null
          ? null
          : fromJson$Enum$MangaStatus((l$greaterThan as String));
    }
    if (data.containsKey('greaterThanOrEqualTo')) {
      final l$greaterThanOrEqualTo = data['greaterThanOrEqualTo'];
      result$data['greaterThanOrEqualTo'] = l$greaterThanOrEqualTo == null
          ? null
          : fromJson$Enum$MangaStatus((l$greaterThanOrEqualTo as String));
    }
    if (data.containsKey('in')) {
      final l$$in = data['in'];
      result$data['in'] = (l$$in as List<dynamic>?)
          ?.map((e) => fromJson$Enum$MangaStatus((e as String)))
          .toList();
    }
    if (data.containsKey('isNull')) {
      final l$isNull = data['isNull'];
      result$data['isNull'] = (l$isNull as bool?);
    }
    if (data.containsKey('lessThan')) {
      final l$lessThan = data['lessThan'];
      result$data['lessThan'] = l$lessThan == null
          ? null
          : fromJson$Enum$MangaStatus((l$lessThan as String));
    }
    if (data.containsKey('lessThanOrEqualTo')) {
      final l$lessThanOrEqualTo = data['lessThanOrEqualTo'];
      result$data['lessThanOrEqualTo'] = l$lessThanOrEqualTo == null
          ? null
          : fromJson$Enum$MangaStatus((l$lessThanOrEqualTo as String));
    }
    if (data.containsKey('notDistinctFrom')) {
      final l$notDistinctFrom = data['notDistinctFrom'];
      result$data['notDistinctFrom'] = l$notDistinctFrom == null
          ? null
          : fromJson$Enum$MangaStatus((l$notDistinctFrom as String));
    }
    if (data.containsKey('notEqualTo')) {
      final l$notEqualTo = data['notEqualTo'];
      result$data['notEqualTo'] = l$notEqualTo == null
          ? null
          : fromJson$Enum$MangaStatus((l$notEqualTo as String));
    }
    if (data.containsKey('notEqualToAll')) {
      final l$notEqualToAll = data['notEqualToAll'];
      result$data['notEqualToAll'] = (l$notEqualToAll as List<dynamic>?)
          ?.map((e) => fromJson$Enum$MangaStatus((e as String)))
          .toList();
    }
    if (data.containsKey('notEqualToAny')) {
      final l$notEqualToAny = data['notEqualToAny'];
      result$data['notEqualToAny'] = (l$notEqualToAny as List<dynamic>?)
          ?.map((e) => fromJson$Enum$MangaStatus((e as String)))
          .toList();
    }
    if (data.containsKey('notIn')) {
      final l$notIn = data['notIn'];
      result$data['notIn'] = (l$notIn as List<dynamic>?)
          ?.map((e) => fromJson$Enum$MangaStatus((e as String)))
          .toList();
    }
    return Input$MangaStatusFilterInput._(result$data);
  }

  Map<String, dynamic> _$data;

  Enum$MangaStatus? get distinctFrom =>
      (_$data['distinctFrom'] as Enum$MangaStatus?);

  List<Enum$MangaStatus>? get distinctFromAll =>
      (_$data['distinctFromAll'] as List<Enum$MangaStatus>?);

  List<Enum$MangaStatus>? get distinctFromAny =>
      (_$data['distinctFromAny'] as List<Enum$MangaStatus>?);

  Enum$MangaStatus? get equalTo => (_$data['equalTo'] as Enum$MangaStatus?);

  Enum$MangaStatus? get greaterThan =>
      (_$data['greaterThan'] as Enum$MangaStatus?);

  Enum$MangaStatus? get greaterThanOrEqualTo =>
      (_$data['greaterThanOrEqualTo'] as Enum$MangaStatus?);

  List<Enum$MangaStatus>? get $in => (_$data['in'] as List<Enum$MangaStatus>?);

  bool? get isNull => (_$data['isNull'] as bool?);

  Enum$MangaStatus? get lessThan => (_$data['lessThan'] as Enum$MangaStatus?);

  Enum$MangaStatus? get lessThanOrEqualTo =>
      (_$data['lessThanOrEqualTo'] as Enum$MangaStatus?);

  Enum$MangaStatus? get notDistinctFrom =>
      (_$data['notDistinctFrom'] as Enum$MangaStatus?);

  Enum$MangaStatus? get notEqualTo =>
      (_$data['notEqualTo'] as Enum$MangaStatus?);

  List<Enum$MangaStatus>? get notEqualToAll =>
      (_$data['notEqualToAll'] as List<Enum$MangaStatus>?);

  List<Enum$MangaStatus>? get notEqualToAny =>
      (_$data['notEqualToAny'] as List<Enum$MangaStatus>?);

  List<Enum$MangaStatus>? get notIn =>
      (_$data['notIn'] as List<Enum$MangaStatus>?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('distinctFrom')) {
      final l$distinctFrom = distinctFrom;
      result$data['distinctFrom'] = l$distinctFrom == null
          ? null
          : toJson$Enum$MangaStatus(l$distinctFrom);
    }
    if (_$data.containsKey('distinctFromAll')) {
      final l$distinctFromAll = distinctFromAll;
      result$data['distinctFromAll'] =
          l$distinctFromAll?.map((e) => toJson$Enum$MangaStatus(e)).toList();
    }
    if (_$data.containsKey('distinctFromAny')) {
      final l$distinctFromAny = distinctFromAny;
      result$data['distinctFromAny'] =
          l$distinctFromAny?.map((e) => toJson$Enum$MangaStatus(e)).toList();
    }
    if (_$data.containsKey('equalTo')) {
      final l$equalTo = equalTo;
      result$data['equalTo'] =
          l$equalTo == null ? null : toJson$Enum$MangaStatus(l$equalTo);
    }
    if (_$data.containsKey('greaterThan')) {
      final l$greaterThan = greaterThan;
      result$data['greaterThan'] =
          l$greaterThan == null ? null : toJson$Enum$MangaStatus(l$greaterThan);
    }
    if (_$data.containsKey('greaterThanOrEqualTo')) {
      final l$greaterThanOrEqualTo = greaterThanOrEqualTo;
      result$data['greaterThanOrEqualTo'] = l$greaterThanOrEqualTo == null
          ? null
          : toJson$Enum$MangaStatus(l$greaterThanOrEqualTo);
    }
    if (_$data.containsKey('in')) {
      final l$$in = $in;
      result$data['in'] =
          l$$in?.map((e) => toJson$Enum$MangaStatus(e)).toList();
    }
    if (_$data.containsKey('isNull')) {
      final l$isNull = isNull;
      result$data['isNull'] = l$isNull;
    }
    if (_$data.containsKey('lessThan')) {
      final l$lessThan = lessThan;
      result$data['lessThan'] =
          l$lessThan == null ? null : toJson$Enum$MangaStatus(l$lessThan);
    }
    if (_$data.containsKey('lessThanOrEqualTo')) {
      final l$lessThanOrEqualTo = lessThanOrEqualTo;
      result$data['lessThanOrEqualTo'] = l$lessThanOrEqualTo == null
          ? null
          : toJson$Enum$MangaStatus(l$lessThanOrEqualTo);
    }
    if (_$data.containsKey('notDistinctFrom')) {
      final l$notDistinctFrom = notDistinctFrom;
      result$data['notDistinctFrom'] = l$notDistinctFrom == null
          ? null
          : toJson$Enum$MangaStatus(l$notDistinctFrom);
    }
    if (_$data.containsKey('notEqualTo')) {
      final l$notEqualTo = notEqualTo;
      result$data['notEqualTo'] =
          l$notEqualTo == null ? null : toJson$Enum$MangaStatus(l$notEqualTo);
    }
    if (_$data.containsKey('notEqualToAll')) {
      final l$notEqualToAll = notEqualToAll;
      result$data['notEqualToAll'] =
          l$notEqualToAll?.map((e) => toJson$Enum$MangaStatus(e)).toList();
    }
    if (_$data.containsKey('notEqualToAny')) {
      final l$notEqualToAny = notEqualToAny;
      result$data['notEqualToAny'] =
          l$notEqualToAny?.map((e) => toJson$Enum$MangaStatus(e)).toList();
    }
    if (_$data.containsKey('notIn')) {
      final l$notIn = notIn;
      result$data['notIn'] =
          l$notIn?.map((e) => toJson$Enum$MangaStatus(e)).toList();
    }
    return result$data;
  }

  CopyWith$Input$MangaStatusFilterInput<Input$MangaStatusFilterInput>
      get copyWith => CopyWith$Input$MangaStatusFilterInput(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$MangaStatusFilterInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$distinctFrom = distinctFrom;
    final lOther$distinctFrom = other.distinctFrom;
    if (_$data.containsKey('distinctFrom') !=
        other._$data.containsKey('distinctFrom')) {
      return false;
    }
    if (l$distinctFrom != lOther$distinctFrom) {
      return false;
    }
    final l$distinctFromAll = distinctFromAll;
    final lOther$distinctFromAll = other.distinctFromAll;
    if (_$data.containsKey('distinctFromAll') !=
        other._$data.containsKey('distinctFromAll')) {
      return false;
    }
    if (l$distinctFromAll != null && lOther$distinctFromAll != null) {
      if (l$distinctFromAll.length != lOther$distinctFromAll.length) {
        return false;
      }
      for (int i = 0; i < l$distinctFromAll.length; i++) {
        final l$distinctFromAll$entry = l$distinctFromAll[i];
        final lOther$distinctFromAll$entry = lOther$distinctFromAll[i];
        if (l$distinctFromAll$entry != lOther$distinctFromAll$entry) {
          return false;
        }
      }
    } else if (l$distinctFromAll != lOther$distinctFromAll) {
      return false;
    }
    final l$distinctFromAny = distinctFromAny;
    final lOther$distinctFromAny = other.distinctFromAny;
    if (_$data.containsKey('distinctFromAny') !=
        other._$data.containsKey('distinctFromAny')) {
      return false;
    }
    if (l$distinctFromAny != null && lOther$distinctFromAny != null) {
      if (l$distinctFromAny.length != lOther$distinctFromAny.length) {
        return false;
      }
      for (int i = 0; i < l$distinctFromAny.length; i++) {
        final l$distinctFromAny$entry = l$distinctFromAny[i];
        final lOther$distinctFromAny$entry = lOther$distinctFromAny[i];
        if (l$distinctFromAny$entry != lOther$distinctFromAny$entry) {
          return false;
        }
      }
    } else if (l$distinctFromAny != lOther$distinctFromAny) {
      return false;
    }
    final l$equalTo = equalTo;
    final lOther$equalTo = other.equalTo;
    if (_$data.containsKey('equalTo') != other._$data.containsKey('equalTo')) {
      return false;
    }
    if (l$equalTo != lOther$equalTo) {
      return false;
    }
    final l$greaterThan = greaterThan;
    final lOther$greaterThan = other.greaterThan;
    if (_$data.containsKey('greaterThan') !=
        other._$data.containsKey('greaterThan')) {
      return false;
    }
    if (l$greaterThan != lOther$greaterThan) {
      return false;
    }
    final l$greaterThanOrEqualTo = greaterThanOrEqualTo;
    final lOther$greaterThanOrEqualTo = other.greaterThanOrEqualTo;
    if (_$data.containsKey('greaterThanOrEqualTo') !=
        other._$data.containsKey('greaterThanOrEqualTo')) {
      return false;
    }
    if (l$greaterThanOrEqualTo != lOther$greaterThanOrEqualTo) {
      return false;
    }
    final l$$in = $in;
    final lOther$$in = other.$in;
    if (_$data.containsKey('in') != other._$data.containsKey('in')) {
      return false;
    }
    if (l$$in != null && lOther$$in != null) {
      if (l$$in.length != lOther$$in.length) {
        return false;
      }
      for (int i = 0; i < l$$in.length; i++) {
        final l$$in$entry = l$$in[i];
        final lOther$$in$entry = lOther$$in[i];
        if (l$$in$entry != lOther$$in$entry) {
          return false;
        }
      }
    } else if (l$$in != lOther$$in) {
      return false;
    }
    final l$isNull = isNull;
    final lOther$isNull = other.isNull;
    if (_$data.containsKey('isNull') != other._$data.containsKey('isNull')) {
      return false;
    }
    if (l$isNull != lOther$isNull) {
      return false;
    }
    final l$lessThan = lessThan;
    final lOther$lessThan = other.lessThan;
    if (_$data.containsKey('lessThan') !=
        other._$data.containsKey('lessThan')) {
      return false;
    }
    if (l$lessThan != lOther$lessThan) {
      return false;
    }
    final l$lessThanOrEqualTo = lessThanOrEqualTo;
    final lOther$lessThanOrEqualTo = other.lessThanOrEqualTo;
    if (_$data.containsKey('lessThanOrEqualTo') !=
        other._$data.containsKey('lessThanOrEqualTo')) {
      return false;
    }
    if (l$lessThanOrEqualTo != lOther$lessThanOrEqualTo) {
      return false;
    }
    final l$notDistinctFrom = notDistinctFrom;
    final lOther$notDistinctFrom = other.notDistinctFrom;
    if (_$data.containsKey('notDistinctFrom') !=
        other._$data.containsKey('notDistinctFrom')) {
      return false;
    }
    if (l$notDistinctFrom != lOther$notDistinctFrom) {
      return false;
    }
    final l$notEqualTo = notEqualTo;
    final lOther$notEqualTo = other.notEqualTo;
    if (_$data.containsKey('notEqualTo') !=
        other._$data.containsKey('notEqualTo')) {
      return false;
    }
    if (l$notEqualTo != lOther$notEqualTo) {
      return false;
    }
    final l$notEqualToAll = notEqualToAll;
    final lOther$notEqualToAll = other.notEqualToAll;
    if (_$data.containsKey('notEqualToAll') !=
        other._$data.containsKey('notEqualToAll')) {
      return false;
    }
    if (l$notEqualToAll != null && lOther$notEqualToAll != null) {
      if (l$notEqualToAll.length != lOther$notEqualToAll.length) {
        return false;
      }
      for (int i = 0; i < l$notEqualToAll.length; i++) {
        final l$notEqualToAll$entry = l$notEqualToAll[i];
        final lOther$notEqualToAll$entry = lOther$notEqualToAll[i];
        if (l$notEqualToAll$entry != lOther$notEqualToAll$entry) {
          return false;
        }
      }
    } else if (l$notEqualToAll != lOther$notEqualToAll) {
      return false;
    }
    final l$notEqualToAny = notEqualToAny;
    final lOther$notEqualToAny = other.notEqualToAny;
    if (_$data.containsKey('notEqualToAny') !=
        other._$data.containsKey('notEqualToAny')) {
      return false;
    }
    if (l$notEqualToAny != null && lOther$notEqualToAny != null) {
      if (l$notEqualToAny.length != lOther$notEqualToAny.length) {
        return false;
      }
      for (int i = 0; i < l$notEqualToAny.length; i++) {
        final l$notEqualToAny$entry = l$notEqualToAny[i];
        final lOther$notEqualToAny$entry = lOther$notEqualToAny[i];
        if (l$notEqualToAny$entry != lOther$notEqualToAny$entry) {
          return false;
        }
      }
    } else if (l$notEqualToAny != lOther$notEqualToAny) {
      return false;
    }
    final l$notIn = notIn;
    final lOther$notIn = other.notIn;
    if (_$data.containsKey('notIn') != other._$data.containsKey('notIn')) {
      return false;
    }
    if (l$notIn != null && lOther$notIn != null) {
      if (l$notIn.length != lOther$notIn.length) {
        return false;
      }
      for (int i = 0; i < l$notIn.length; i++) {
        final l$notIn$entry = l$notIn[i];
        final lOther$notIn$entry = lOther$notIn[i];
        if (l$notIn$entry != lOther$notIn$entry) {
          return false;
        }
      }
    } else if (l$notIn != lOther$notIn) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$distinctFrom = distinctFrom;
    final l$distinctFromAll = distinctFromAll;
    final l$distinctFromAny = distinctFromAny;
    final l$equalTo = equalTo;
    final l$greaterThan = greaterThan;
    final l$greaterThanOrEqualTo = greaterThanOrEqualTo;
    final l$$in = $in;
    final l$isNull = isNull;
    final l$lessThan = lessThan;
    final l$lessThanOrEqualTo = lessThanOrEqualTo;
    final l$notDistinctFrom = notDistinctFrom;
    final l$notEqualTo = notEqualTo;
    final l$notEqualToAll = notEqualToAll;
    final l$notEqualToAny = notEqualToAny;
    final l$notIn = notIn;
    return Object.hashAll([
      _$data.containsKey('distinctFrom') ? l$distinctFrom : const {},
      _$data.containsKey('distinctFromAll')
          ? l$distinctFromAll == null
              ? null
              : Object.hashAll(l$distinctFromAll.map((v) => v))
          : const {},
      _$data.containsKey('distinctFromAny')
          ? l$distinctFromAny == null
              ? null
              : Object.hashAll(l$distinctFromAny.map((v) => v))
          : const {},
      _$data.containsKey('equalTo') ? l$equalTo : const {},
      _$data.containsKey('greaterThan') ? l$greaterThan : const {},
      _$data.containsKey('greaterThanOrEqualTo')
          ? l$greaterThanOrEqualTo
          : const {},
      _$data.containsKey('in')
          ? l$$in == null
              ? null
              : Object.hashAll(l$$in.map((v) => v))
          : const {},
      _$data.containsKey('isNull') ? l$isNull : const {},
      _$data.containsKey('lessThan') ? l$lessThan : const {},
      _$data.containsKey('lessThanOrEqualTo') ? l$lessThanOrEqualTo : const {},
      _$data.containsKey('notDistinctFrom') ? l$notDistinctFrom : const {},
      _$data.containsKey('notEqualTo') ? l$notEqualTo : const {},
      _$data.containsKey('notEqualToAll')
          ? l$notEqualToAll == null
              ? null
              : Object.hashAll(l$notEqualToAll.map((v) => v))
          : const {},
      _$data.containsKey('notEqualToAny')
          ? l$notEqualToAny == null
              ? null
              : Object.hashAll(l$notEqualToAny.map((v) => v))
          : const {},
      _$data.containsKey('notIn')
          ? l$notIn == null
              ? null
              : Object.hashAll(l$notIn.map((v) => v))
          : const {},
    ]);
  }
}

abstract class CopyWith$Input$MangaStatusFilterInput<TRes> {
  factory CopyWith$Input$MangaStatusFilterInput(
    Input$MangaStatusFilterInput instance,
    TRes Function(Input$MangaStatusFilterInput) then,
  ) = _CopyWithImpl$Input$MangaStatusFilterInput;

  factory CopyWith$Input$MangaStatusFilterInput.stub(TRes res) =
      _CopyWithStubImpl$Input$MangaStatusFilterInput;

  TRes call({
    Enum$MangaStatus? distinctFrom,
    List<Enum$MangaStatus>? distinctFromAll,
    List<Enum$MangaStatus>? distinctFromAny,
    Enum$MangaStatus? equalTo,
    Enum$MangaStatus? greaterThan,
    Enum$MangaStatus? greaterThanOrEqualTo,
    List<Enum$MangaStatus>? $in,
    bool? isNull,
    Enum$MangaStatus? lessThan,
    Enum$MangaStatus? lessThanOrEqualTo,
    Enum$MangaStatus? notDistinctFrom,
    Enum$MangaStatus? notEqualTo,
    List<Enum$MangaStatus>? notEqualToAll,
    List<Enum$MangaStatus>? notEqualToAny,
    List<Enum$MangaStatus>? notIn,
  });
}

class _CopyWithImpl$Input$MangaStatusFilterInput<TRes>
    implements CopyWith$Input$MangaStatusFilterInput<TRes> {
  _CopyWithImpl$Input$MangaStatusFilterInput(
    this._instance,
    this._then,
  );

  final Input$MangaStatusFilterInput _instance;

  final TRes Function(Input$MangaStatusFilterInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? distinctFrom = _undefined,
    Object? distinctFromAll = _undefined,
    Object? distinctFromAny = _undefined,
    Object? equalTo = _undefined,
    Object? greaterThan = _undefined,
    Object? greaterThanOrEqualTo = _undefined,
    Object? $in = _undefined,
    Object? isNull = _undefined,
    Object? lessThan = _undefined,
    Object? lessThanOrEqualTo = _undefined,
    Object? notDistinctFrom = _undefined,
    Object? notEqualTo = _undefined,
    Object? notEqualToAll = _undefined,
    Object? notEqualToAny = _undefined,
    Object? notIn = _undefined,
  }) =>
      _then(Input$MangaStatusFilterInput._({
        ..._instance._$data,
        if (distinctFrom != _undefined)
          'distinctFrom': (distinctFrom as Enum$MangaStatus?),
        if (distinctFromAll != _undefined)
          'distinctFromAll': (distinctFromAll as List<Enum$MangaStatus>?),
        if (distinctFromAny != _undefined)
          'distinctFromAny': (distinctFromAny as List<Enum$MangaStatus>?),
        if (equalTo != _undefined) 'equalTo': (equalTo as Enum$MangaStatus?),
        if (greaterThan != _undefined)
          'greaterThan': (greaterThan as Enum$MangaStatus?),
        if (greaterThanOrEqualTo != _undefined)
          'greaterThanOrEqualTo': (greaterThanOrEqualTo as Enum$MangaStatus?),
        if ($in != _undefined) 'in': ($in as List<Enum$MangaStatus>?),
        if (isNull != _undefined) 'isNull': (isNull as bool?),
        if (lessThan != _undefined) 'lessThan': (lessThan as Enum$MangaStatus?),
        if (lessThanOrEqualTo != _undefined)
          'lessThanOrEqualTo': (lessThanOrEqualTo as Enum$MangaStatus?),
        if (notDistinctFrom != _undefined)
          'notDistinctFrom': (notDistinctFrom as Enum$MangaStatus?),
        if (notEqualTo != _undefined)
          'notEqualTo': (notEqualTo as Enum$MangaStatus?),
        if (notEqualToAll != _undefined)
          'notEqualToAll': (notEqualToAll as List<Enum$MangaStatus>?),
        if (notEqualToAny != _undefined)
          'notEqualToAny': (notEqualToAny as List<Enum$MangaStatus>?),
        if (notIn != _undefined) 'notIn': (notIn as List<Enum$MangaStatus>?),
      }));
}

class _CopyWithStubImpl$Input$MangaStatusFilterInput<TRes>
    implements CopyWith$Input$MangaStatusFilterInput<TRes> {
  _CopyWithStubImpl$Input$MangaStatusFilterInput(this._res);

  TRes _res;

  call({
    Enum$MangaStatus? distinctFrom,
    List<Enum$MangaStatus>? distinctFromAll,
    List<Enum$MangaStatus>? distinctFromAny,
    Enum$MangaStatus? equalTo,
    Enum$MangaStatus? greaterThan,
    Enum$MangaStatus? greaterThanOrEqualTo,
    List<Enum$MangaStatus>? $in,
    bool? isNull,
    Enum$MangaStatus? lessThan,
    Enum$MangaStatus? lessThanOrEqualTo,
    Enum$MangaStatus? notDistinctFrom,
    Enum$MangaStatus? notEqualTo,
    List<Enum$MangaStatus>? notEqualToAll,
    List<Enum$MangaStatus>? notEqualToAny,
    List<Enum$MangaStatus>? notIn,
  }) =>
      _res;
}

class Input$MetaConditionInput {
  factory Input$MetaConditionInput({
    String? key,
    String? value,
  }) =>
      Input$MetaConditionInput._({
        if (key != null) r'key': key,
        if (value != null) r'value': value,
      });

  Input$MetaConditionInput._(this._$data);

  factory Input$MetaConditionInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('key')) {
      final l$key = data['key'];
      result$data['key'] = (l$key as String?);
    }
    if (data.containsKey('value')) {
      final l$value = data['value'];
      result$data['value'] = (l$value as String?);
    }
    return Input$MetaConditionInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get key => (_$data['key'] as String?);

  String? get value => (_$data['value'] as String?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('key')) {
      final l$key = key;
      result$data['key'] = l$key;
    }
    if (_$data.containsKey('value')) {
      final l$value = value;
      result$data['value'] = l$value;
    }
    return result$data;
  }

  CopyWith$Input$MetaConditionInput<Input$MetaConditionInput> get copyWith =>
      CopyWith$Input$MetaConditionInput(
        this,
        (i) => i,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$MetaConditionInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$key = key;
    final lOther$key = other.key;
    if (_$data.containsKey('key') != other._$data.containsKey('key')) {
      return false;
    }
    if (l$key != lOther$key) {
      return false;
    }
    final l$value = value;
    final lOther$value = other.value;
    if (_$data.containsKey('value') != other._$data.containsKey('value')) {
      return false;
    }
    if (l$value != lOther$value) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$key = key;
    final l$value = value;
    return Object.hashAll([
      _$data.containsKey('key') ? l$key : const {},
      _$data.containsKey('value') ? l$value : const {},
    ]);
  }
}

abstract class CopyWith$Input$MetaConditionInput<TRes> {
  factory CopyWith$Input$MetaConditionInput(
    Input$MetaConditionInput instance,
    TRes Function(Input$MetaConditionInput) then,
  ) = _CopyWithImpl$Input$MetaConditionInput;

  factory CopyWith$Input$MetaConditionInput.stub(TRes res) =
      _CopyWithStubImpl$Input$MetaConditionInput;

  TRes call({
    String? key,
    String? value,
  });
}

class _CopyWithImpl$Input$MetaConditionInput<TRes>
    implements CopyWith$Input$MetaConditionInput<TRes> {
  _CopyWithImpl$Input$MetaConditionInput(
    this._instance,
    this._then,
  );

  final Input$MetaConditionInput _instance;

  final TRes Function(Input$MetaConditionInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? key = _undefined,
    Object? value = _undefined,
  }) =>
      _then(Input$MetaConditionInput._({
        ..._instance._$data,
        if (key != _undefined) 'key': (key as String?),
        if (value != _undefined) 'value': (value as String?),
      }));
}

class _CopyWithStubImpl$Input$MetaConditionInput<TRes>
    implements CopyWith$Input$MetaConditionInput<TRes> {
  _CopyWithStubImpl$Input$MetaConditionInput(this._res);

  TRes _res;

  call({
    String? key,
    String? value,
  }) =>
      _res;
}

class Input$MetaFilterInput {
  factory Input$MetaFilterInput({
    List<Input$MetaFilterInput>? and,
    Input$StringFilterInput? key,
    Input$MetaFilterInput? not,
    List<Input$MetaFilterInput>? or,
    Input$StringFilterInput? value,
  }) =>
      Input$MetaFilterInput._({
        if (and != null) r'and': and,
        if (key != null) r'key': key,
        if (not != null) r'not': not,
        if (or != null) r'or': or,
        if (value != null) r'value': value,
      });

  Input$MetaFilterInput._(this._$data);

  factory Input$MetaFilterInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('and')) {
      final l$and = data['and'];
      result$data['and'] = (l$and as List<dynamic>?)
          ?.map((e) =>
              Input$MetaFilterInput.fromJson((e as Map<String, dynamic>)))
          .toList();
    }
    if (data.containsKey('key')) {
      final l$key = data['key'];
      result$data['key'] = l$key == null
          ? null
          : Input$StringFilterInput.fromJson((l$key as Map<String, dynamic>));
    }
    if (data.containsKey('not')) {
      final l$not = data['not'];
      result$data['not'] = l$not == null
          ? null
          : Input$MetaFilterInput.fromJson((l$not as Map<String, dynamic>));
    }
    if (data.containsKey('or')) {
      final l$or = data['or'];
      result$data['or'] = (l$or as List<dynamic>?)
          ?.map((e) =>
              Input$MetaFilterInput.fromJson((e as Map<String, dynamic>)))
          .toList();
    }
    if (data.containsKey('value')) {
      final l$value = data['value'];
      result$data['value'] = l$value == null
          ? null
          : Input$StringFilterInput.fromJson((l$value as Map<String, dynamic>));
    }
    return Input$MetaFilterInput._(result$data);
  }

  Map<String, dynamic> _$data;

  List<Input$MetaFilterInput>? get and =>
      (_$data['and'] as List<Input$MetaFilterInput>?);

  Input$StringFilterInput? get key =>
      (_$data['key'] as Input$StringFilterInput?);

  Input$MetaFilterInput? get not => (_$data['not'] as Input$MetaFilterInput?);

  List<Input$MetaFilterInput>? get or =>
      (_$data['or'] as List<Input$MetaFilterInput>?);

  Input$StringFilterInput? get value =>
      (_$data['value'] as Input$StringFilterInput?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('and')) {
      final l$and = and;
      result$data['and'] = l$and?.map((e) => e.toJson()).toList();
    }
    if (_$data.containsKey('key')) {
      final l$key = key;
      result$data['key'] = l$key?.toJson();
    }
    if (_$data.containsKey('not')) {
      final l$not = not;
      result$data['not'] = l$not?.toJson();
    }
    if (_$data.containsKey('or')) {
      final l$or = or;
      result$data['or'] = l$or?.map((e) => e.toJson()).toList();
    }
    if (_$data.containsKey('value')) {
      final l$value = value;
      result$data['value'] = l$value?.toJson();
    }
    return result$data;
  }

  CopyWith$Input$MetaFilterInput<Input$MetaFilterInput> get copyWith =>
      CopyWith$Input$MetaFilterInput(
        this,
        (i) => i,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$MetaFilterInput || runtimeType != other.runtimeType) {
      return false;
    }
    final l$and = and;
    final lOther$and = other.and;
    if (_$data.containsKey('and') != other._$data.containsKey('and')) {
      return false;
    }
    if (l$and != null && lOther$and != null) {
      if (l$and.length != lOther$and.length) {
        return false;
      }
      for (int i = 0; i < l$and.length; i++) {
        final l$and$entry = l$and[i];
        final lOther$and$entry = lOther$and[i];
        if (l$and$entry != lOther$and$entry) {
          return false;
        }
      }
    } else if (l$and != lOther$and) {
      return false;
    }
    final l$key = key;
    final lOther$key = other.key;
    if (_$data.containsKey('key') != other._$data.containsKey('key')) {
      return false;
    }
    if (l$key != lOther$key) {
      return false;
    }
    final l$not = not;
    final lOther$not = other.not;
    if (_$data.containsKey('not') != other._$data.containsKey('not')) {
      return false;
    }
    if (l$not != lOther$not) {
      return false;
    }
    final l$or = or;
    final lOther$or = other.or;
    if (_$data.containsKey('or') != other._$data.containsKey('or')) {
      return false;
    }
    if (l$or != null && lOther$or != null) {
      if (l$or.length != lOther$or.length) {
        return false;
      }
      for (int i = 0; i < l$or.length; i++) {
        final l$or$entry = l$or[i];
        final lOther$or$entry = lOther$or[i];
        if (l$or$entry != lOther$or$entry) {
          return false;
        }
      }
    } else if (l$or != lOther$or) {
      return false;
    }
    final l$value = value;
    final lOther$value = other.value;
    if (_$data.containsKey('value') != other._$data.containsKey('value')) {
      return false;
    }
    if (l$value != lOther$value) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$and = and;
    final l$key = key;
    final l$not = not;
    final l$or = or;
    final l$value = value;
    return Object.hashAll([
      _$data.containsKey('and')
          ? l$and == null
              ? null
              : Object.hashAll(l$and.map((v) => v))
          : const {},
      _$data.containsKey('key') ? l$key : const {},
      _$data.containsKey('not') ? l$not : const {},
      _$data.containsKey('or')
          ? l$or == null
              ? null
              : Object.hashAll(l$or.map((v) => v))
          : const {},
      _$data.containsKey('value') ? l$value : const {},
    ]);
  }
}

abstract class CopyWith$Input$MetaFilterInput<TRes> {
  factory CopyWith$Input$MetaFilterInput(
    Input$MetaFilterInput instance,
    TRes Function(Input$MetaFilterInput) then,
  ) = _CopyWithImpl$Input$MetaFilterInput;

  factory CopyWith$Input$MetaFilterInput.stub(TRes res) =
      _CopyWithStubImpl$Input$MetaFilterInput;

  TRes call({
    List<Input$MetaFilterInput>? and,
    Input$StringFilterInput? key,
    Input$MetaFilterInput? not,
    List<Input$MetaFilterInput>? or,
    Input$StringFilterInput? value,
  });
  TRes and(
      Iterable<Input$MetaFilterInput>? Function(
              Iterable<CopyWith$Input$MetaFilterInput<Input$MetaFilterInput>>?)
          _fn);
  CopyWith$Input$StringFilterInput<TRes> get key;
  CopyWith$Input$MetaFilterInput<TRes> get not;
  TRes or(
      Iterable<Input$MetaFilterInput>? Function(
              Iterable<CopyWith$Input$MetaFilterInput<Input$MetaFilterInput>>?)
          _fn);
  CopyWith$Input$StringFilterInput<TRes> get value;
}

class _CopyWithImpl$Input$MetaFilterInput<TRes>
    implements CopyWith$Input$MetaFilterInput<TRes> {
  _CopyWithImpl$Input$MetaFilterInput(
    this._instance,
    this._then,
  );

  final Input$MetaFilterInput _instance;

  final TRes Function(Input$MetaFilterInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? and = _undefined,
    Object? key = _undefined,
    Object? not = _undefined,
    Object? or = _undefined,
    Object? value = _undefined,
  }) =>
      _then(Input$MetaFilterInput._({
        ..._instance._$data,
        if (and != _undefined) 'and': (and as List<Input$MetaFilterInput>?),
        if (key != _undefined) 'key': (key as Input$StringFilterInput?),
        if (not != _undefined) 'not': (not as Input$MetaFilterInput?),
        if (or != _undefined) 'or': (or as List<Input$MetaFilterInput>?),
        if (value != _undefined) 'value': (value as Input$StringFilterInput?),
      }));

  TRes and(
          Iterable<Input$MetaFilterInput>? Function(
                  Iterable<
                      CopyWith$Input$MetaFilterInput<Input$MetaFilterInput>>?)
              _fn) =>
      call(
          and: _fn(_instance.and?.map((e) => CopyWith$Input$MetaFilterInput(
                e,
                (i) => i,
              )))?.toList());

  CopyWith$Input$StringFilterInput<TRes> get key {
    final local$key = _instance.key;
    return local$key == null
        ? CopyWith$Input$StringFilterInput.stub(_then(_instance))
        : CopyWith$Input$StringFilterInput(local$key, (e) => call(key: e));
  }

  CopyWith$Input$MetaFilterInput<TRes> get not {
    final local$not = _instance.not;
    return local$not == null
        ? CopyWith$Input$MetaFilterInput.stub(_then(_instance))
        : CopyWith$Input$MetaFilterInput(local$not, (e) => call(not: e));
  }

  TRes or(
          Iterable<Input$MetaFilterInput>? Function(
                  Iterable<
                      CopyWith$Input$MetaFilterInput<Input$MetaFilterInput>>?)
              _fn) =>
      call(
          or: _fn(_instance.or?.map((e) => CopyWith$Input$MetaFilterInput(
                e,
                (i) => i,
              )))?.toList());

  CopyWith$Input$StringFilterInput<TRes> get value {
    final local$value = _instance.value;
    return local$value == null
        ? CopyWith$Input$StringFilterInput.stub(_then(_instance))
        : CopyWith$Input$StringFilterInput(local$value, (e) => call(value: e));
  }
}

class _CopyWithStubImpl$Input$MetaFilterInput<TRes>
    implements CopyWith$Input$MetaFilterInput<TRes> {
  _CopyWithStubImpl$Input$MetaFilterInput(this._res);

  TRes _res;

  call({
    List<Input$MetaFilterInput>? and,
    Input$StringFilterInput? key,
    Input$MetaFilterInput? not,
    List<Input$MetaFilterInput>? or,
    Input$StringFilterInput? value,
  }) =>
      _res;

  and(_fn) => _res;

  CopyWith$Input$StringFilterInput<TRes> get key =>
      CopyWith$Input$StringFilterInput.stub(_res);

  CopyWith$Input$MetaFilterInput<TRes> get not =>
      CopyWith$Input$MetaFilterInput.stub(_res);

  or(_fn) => _res;

  CopyWith$Input$StringFilterInput<TRes> get value =>
      CopyWith$Input$StringFilterInput.stub(_res);
}

class Input$MetaOrderInput {
  factory Input$MetaOrderInput({
    required Enum$MetaOrderBy by,
    Enum$SortOrder? byType,
  }) =>
      Input$MetaOrderInput._({
        r'by': by,
        if (byType != null) r'byType': byType,
      });

  Input$MetaOrderInput._(this._$data);

  factory Input$MetaOrderInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$by = data['by'];
    result$data['by'] = fromJson$Enum$MetaOrderBy((l$by as String));
    if (data.containsKey('byType')) {
      final l$byType = data['byType'];
      result$data['byType'] = l$byType == null
          ? null
          : fromJson$Enum$SortOrder((l$byType as String));
    }
    return Input$MetaOrderInput._(result$data);
  }

  Map<String, dynamic> _$data;

  Enum$MetaOrderBy get by => (_$data['by'] as Enum$MetaOrderBy);

  Enum$SortOrder? get byType => (_$data['byType'] as Enum$SortOrder?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$by = by;
    result$data['by'] = toJson$Enum$MetaOrderBy(l$by);
    if (_$data.containsKey('byType')) {
      final l$byType = byType;
      result$data['byType'] =
          l$byType == null ? null : toJson$Enum$SortOrder(l$byType);
    }
    return result$data;
  }

  CopyWith$Input$MetaOrderInput<Input$MetaOrderInput> get copyWith =>
      CopyWith$Input$MetaOrderInput(
        this,
        (i) => i,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$MetaOrderInput || runtimeType != other.runtimeType) {
      return false;
    }
    final l$by = by;
    final lOther$by = other.by;
    if (l$by != lOther$by) {
      return false;
    }
    final l$byType = byType;
    final lOther$byType = other.byType;
    if (_$data.containsKey('byType') != other._$data.containsKey('byType')) {
      return false;
    }
    if (l$byType != lOther$byType) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$by = by;
    final l$byType = byType;
    return Object.hashAll([
      l$by,
      _$data.containsKey('byType') ? l$byType : const {},
    ]);
  }
}

abstract class CopyWith$Input$MetaOrderInput<TRes> {
  factory CopyWith$Input$MetaOrderInput(
    Input$MetaOrderInput instance,
    TRes Function(Input$MetaOrderInput) then,
  ) = _CopyWithImpl$Input$MetaOrderInput;

  factory CopyWith$Input$MetaOrderInput.stub(TRes res) =
      _CopyWithStubImpl$Input$MetaOrderInput;

  TRes call({
    Enum$MetaOrderBy? by,
    Enum$SortOrder? byType,
  });
}

class _CopyWithImpl$Input$MetaOrderInput<TRes>
    implements CopyWith$Input$MetaOrderInput<TRes> {
  _CopyWithImpl$Input$MetaOrderInput(
    this._instance,
    this._then,
  );

  final Input$MetaOrderInput _instance;

  final TRes Function(Input$MetaOrderInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? by = _undefined,
    Object? byType = _undefined,
  }) =>
      _then(Input$MetaOrderInput._({
        ..._instance._$data,
        if (by != _undefined && by != null) 'by': (by as Enum$MetaOrderBy),
        if (byType != _undefined) 'byType': (byType as Enum$SortOrder?),
      }));
}

class _CopyWithStubImpl$Input$MetaOrderInput<TRes>
    implements CopyWith$Input$MetaOrderInput<TRes> {
  _CopyWithStubImpl$Input$MetaOrderInput(this._res);

  TRes _res;

  call({
    Enum$MetaOrderBy? by,
    Enum$SortOrder? byType,
  }) =>
      _res;
}

class Input$PartialSettingsTypeInput {
  factory Input$PartialSettingsTypeInput({
    bool? autoDownloadIgnoreReUploads,
    bool? autoDownloadNewChapters,
    int? autoDownloadNewChaptersLimit,
    int? backupInterval,
    String? backupPath,
    int? backupTTL,
    String? backupTime,
    bool? basicAuthEnabled,
    String? basicAuthPassword,
    String? basicAuthUsername,
    bool? debugLogsEnabled,
    bool? downloadAsCbz,
    String? downloadsPath,
    String? electronPath,
    bool? excludeCompleted,
    bool? excludeEntryWithUnreadChapters,
    bool? excludeNotStarted,
    bool? excludeUnreadChapters,
    List<String>? extensionRepos,
    bool? flareSolverrAsResponseFallback,
    bool? flareSolverrEnabled,
    String? flareSolverrSessionName,
    int? flareSolverrSessionTtl,
    int? flareSolverrTimeout,
    String? flareSolverrUrl,
    double? globalUpdateInterval,
    bool? initialOpenInBrowserEnabled,
    String? ip,
    String? localSourcePath,
    String? maxLogFileSize,
    int? maxLogFiles,
    String? maxLogFolderSize,
    int? maxSourcesInParallel,
    int? port,
    bool? socksProxyEnabled,
    String? socksProxyHost,
    String? socksProxyPassword,
    String? socksProxyPort,
    String? socksProxyUsername,
    int? socksProxyVersion,
    bool? systemTrayEnabled,
    bool? updateMangas,
    Enum$WebUIChannel? webUIChannel,
    Enum$WebUIFlavor? webUIFlavor,
    Enum$WebUIInterface? webUIInterface,
    double? webUIUpdateCheckInterval,
  }) =>
      Input$PartialSettingsTypeInput._({
        if (autoDownloadIgnoreReUploads != null)
          r'autoDownloadIgnoreReUploads': autoDownloadIgnoreReUploads,
        if (autoDownloadNewChapters != null)
          r'autoDownloadNewChapters': autoDownloadNewChapters,
        if (autoDownloadNewChaptersLimit != null)
          r'autoDownloadNewChaptersLimit': autoDownloadNewChaptersLimit,
        if (backupInterval != null) r'backupInterval': backupInterval,
        if (backupPath != null) r'backupPath': backupPath,
        if (backupTTL != null) r'backupTTL': backupTTL,
        if (backupTime != null) r'backupTime': backupTime,
        if (basicAuthEnabled != null) r'basicAuthEnabled': basicAuthEnabled,
        if (basicAuthPassword != null) r'basicAuthPassword': basicAuthPassword,
        if (basicAuthUsername != null) r'basicAuthUsername': basicAuthUsername,
        if (debugLogsEnabled != null) r'debugLogsEnabled': debugLogsEnabled,
        if (downloadAsCbz != null) r'downloadAsCbz': downloadAsCbz,
        if (downloadsPath != null) r'downloadsPath': downloadsPath,
        if (electronPath != null) r'electronPath': electronPath,
        if (excludeCompleted != null) r'excludeCompleted': excludeCompleted,
        if (excludeEntryWithUnreadChapters != null)
          r'excludeEntryWithUnreadChapters': excludeEntryWithUnreadChapters,
        if (excludeNotStarted != null) r'excludeNotStarted': excludeNotStarted,
        if (excludeUnreadChapters != null)
          r'excludeUnreadChapters': excludeUnreadChapters,
        if (extensionRepos != null) r'extensionRepos': extensionRepos,
        if (flareSolverrAsResponseFallback != null)
          r'flareSolverrAsResponseFallback': flareSolverrAsResponseFallback,
        if (flareSolverrEnabled != null)
          r'flareSolverrEnabled': flareSolverrEnabled,
        if (flareSolverrSessionName != null)
          r'flareSolverrSessionName': flareSolverrSessionName,
        if (flareSolverrSessionTtl != null)
          r'flareSolverrSessionTtl': flareSolverrSessionTtl,
        if (flareSolverrTimeout != null)
          r'flareSolverrTimeout': flareSolverrTimeout,
        if (flareSolverrUrl != null) r'flareSolverrUrl': flareSolverrUrl,
        if (globalUpdateInterval != null)
          r'globalUpdateInterval': globalUpdateInterval,
        if (initialOpenInBrowserEnabled != null)
          r'initialOpenInBrowserEnabled': initialOpenInBrowserEnabled,
        if (ip != null) r'ip': ip,
        if (localSourcePath != null) r'localSourcePath': localSourcePath,
        if (maxLogFileSize != null) r'maxLogFileSize': maxLogFileSize,
        if (maxLogFiles != null) r'maxLogFiles': maxLogFiles,
        if (maxLogFolderSize != null) r'maxLogFolderSize': maxLogFolderSize,
        if (maxSourcesInParallel != null)
          r'maxSourcesInParallel': maxSourcesInParallel,
        if (port != null) r'port': port,
        if (socksProxyEnabled != null) r'socksProxyEnabled': socksProxyEnabled,
        if (socksProxyHost != null) r'socksProxyHost': socksProxyHost,
        if (socksProxyPassword != null)
          r'socksProxyPassword': socksProxyPassword,
        if (socksProxyPort != null) r'socksProxyPort': socksProxyPort,
        if (socksProxyUsername != null)
          r'socksProxyUsername': socksProxyUsername,
        if (socksProxyVersion != null) r'socksProxyVersion': socksProxyVersion,
        if (systemTrayEnabled != null) r'systemTrayEnabled': systemTrayEnabled,
        if (updateMangas != null) r'updateMangas': updateMangas,
        if (webUIChannel != null) r'webUIChannel': webUIChannel,
        if (webUIFlavor != null) r'webUIFlavor': webUIFlavor,
        if (webUIInterface != null) r'webUIInterface': webUIInterface,
        if (webUIUpdateCheckInterval != null)
          r'webUIUpdateCheckInterval': webUIUpdateCheckInterval,
      });

  Input$PartialSettingsTypeInput._(this._$data);

  factory Input$PartialSettingsTypeInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('autoDownloadIgnoreReUploads')) {
      final l$autoDownloadIgnoreReUploads = data['autoDownloadIgnoreReUploads'];
      result$data['autoDownloadIgnoreReUploads'] =
          (l$autoDownloadIgnoreReUploads as bool?);
    }
    if (data.containsKey('autoDownloadNewChapters')) {
      final l$autoDownloadNewChapters = data['autoDownloadNewChapters'];
      result$data['autoDownloadNewChapters'] =
          (l$autoDownloadNewChapters as bool?);
    }
    if (data.containsKey('autoDownloadNewChaptersLimit')) {
      final l$autoDownloadNewChaptersLimit =
          data['autoDownloadNewChaptersLimit'];
      result$data['autoDownloadNewChaptersLimit'] =
          (l$autoDownloadNewChaptersLimit as int?);
    }
    if (data.containsKey('backupInterval')) {
      final l$backupInterval = data['backupInterval'];
      result$data['backupInterval'] = (l$backupInterval as int?);
    }
    if (data.containsKey('backupPath')) {
      final l$backupPath = data['backupPath'];
      result$data['backupPath'] = (l$backupPath as String?);
    }
    if (data.containsKey('backupTTL')) {
      final l$backupTTL = data['backupTTL'];
      result$data['backupTTL'] = (l$backupTTL as int?);
    }
    if (data.containsKey('backupTime')) {
      final l$backupTime = data['backupTime'];
      result$data['backupTime'] = (l$backupTime as String?);
    }
    if (data.containsKey('basicAuthEnabled')) {
      final l$basicAuthEnabled = data['basicAuthEnabled'];
      result$data['basicAuthEnabled'] = (l$basicAuthEnabled as bool?);
    }
    if (data.containsKey('basicAuthPassword')) {
      final l$basicAuthPassword = data['basicAuthPassword'];
      result$data['basicAuthPassword'] = (l$basicAuthPassword as String?);
    }
    if (data.containsKey('basicAuthUsername')) {
      final l$basicAuthUsername = data['basicAuthUsername'];
      result$data['basicAuthUsername'] = (l$basicAuthUsername as String?);
    }
    if (data.containsKey('debugLogsEnabled')) {
      final l$debugLogsEnabled = data['debugLogsEnabled'];
      result$data['debugLogsEnabled'] = (l$debugLogsEnabled as bool?);
    }
    if (data.containsKey('downloadAsCbz')) {
      final l$downloadAsCbz = data['downloadAsCbz'];
      result$data['downloadAsCbz'] = (l$downloadAsCbz as bool?);
    }
    if (data.containsKey('downloadsPath')) {
      final l$downloadsPath = data['downloadsPath'];
      result$data['downloadsPath'] = (l$downloadsPath as String?);
    }
    if (data.containsKey('electronPath')) {
      final l$electronPath = data['electronPath'];
      result$data['electronPath'] = (l$electronPath as String?);
    }
    if (data.containsKey('excludeCompleted')) {
      final l$excludeCompleted = data['excludeCompleted'];
      result$data['excludeCompleted'] = (l$excludeCompleted as bool?);
    }
    if (data.containsKey('excludeEntryWithUnreadChapters')) {
      final l$excludeEntryWithUnreadChapters =
          data['excludeEntryWithUnreadChapters'];
      result$data['excludeEntryWithUnreadChapters'] =
          (l$excludeEntryWithUnreadChapters as bool?);
    }
    if (data.containsKey('excludeNotStarted')) {
      final l$excludeNotStarted = data['excludeNotStarted'];
      result$data['excludeNotStarted'] = (l$excludeNotStarted as bool?);
    }
    if (data.containsKey('excludeUnreadChapters')) {
      final l$excludeUnreadChapters = data['excludeUnreadChapters'];
      result$data['excludeUnreadChapters'] = (l$excludeUnreadChapters as bool?);
    }
    if (data.containsKey('extensionRepos')) {
      final l$extensionRepos = data['extensionRepos'];
      result$data['extensionRepos'] = (l$extensionRepos as List<dynamic>?)
          ?.map((e) => (e as String))
          .toList();
    }
    if (data.containsKey('flareSolverrAsResponseFallback')) {
      final l$flareSolverrAsResponseFallback =
          data['flareSolverrAsResponseFallback'];
      result$data['flareSolverrAsResponseFallback'] =
          (l$flareSolverrAsResponseFallback as bool?);
    }
    if (data.containsKey('flareSolverrEnabled')) {
      final l$flareSolverrEnabled = data['flareSolverrEnabled'];
      result$data['flareSolverrEnabled'] = (l$flareSolverrEnabled as bool?);
    }
    if (data.containsKey('flareSolverrSessionName')) {
      final l$flareSolverrSessionName = data['flareSolverrSessionName'];
      result$data['flareSolverrSessionName'] =
          (l$flareSolverrSessionName as String?);
    }
    if (data.containsKey('flareSolverrSessionTtl')) {
      final l$flareSolverrSessionTtl = data['flareSolverrSessionTtl'];
      result$data['flareSolverrSessionTtl'] =
          (l$flareSolverrSessionTtl as int?);
    }
    if (data.containsKey('flareSolverrTimeout')) {
      final l$flareSolverrTimeout = data['flareSolverrTimeout'];
      result$data['flareSolverrTimeout'] = (l$flareSolverrTimeout as int?);
    }
    if (data.containsKey('flareSolverrUrl')) {
      final l$flareSolverrUrl = data['flareSolverrUrl'];
      result$data['flareSolverrUrl'] = (l$flareSolverrUrl as String?);
    }
    if (data.containsKey('globalUpdateInterval')) {
      final l$globalUpdateInterval = data['globalUpdateInterval'];
      result$data['globalUpdateInterval'] =
          (l$globalUpdateInterval as num?)?.toDouble();
    }
    if (data.containsKey('initialOpenInBrowserEnabled')) {
      final l$initialOpenInBrowserEnabled = data['initialOpenInBrowserEnabled'];
      result$data['initialOpenInBrowserEnabled'] =
          (l$initialOpenInBrowserEnabled as bool?);
    }
    if (data.containsKey('ip')) {
      final l$ip = data['ip'];
      result$data['ip'] = (l$ip as String?);
    }
    if (data.containsKey('localSourcePath')) {
      final l$localSourcePath = data['localSourcePath'];
      result$data['localSourcePath'] = (l$localSourcePath as String?);
    }
    if (data.containsKey('maxLogFileSize')) {
      final l$maxLogFileSize = data['maxLogFileSize'];
      result$data['maxLogFileSize'] = (l$maxLogFileSize as String?);
    }
    if (data.containsKey('maxLogFiles')) {
      final l$maxLogFiles = data['maxLogFiles'];
      result$data['maxLogFiles'] = (l$maxLogFiles as int?);
    }
    if (data.containsKey('maxLogFolderSize')) {
      final l$maxLogFolderSize = data['maxLogFolderSize'];
      result$data['maxLogFolderSize'] = (l$maxLogFolderSize as String?);
    }
    if (data.containsKey('maxSourcesInParallel')) {
      final l$maxSourcesInParallel = data['maxSourcesInParallel'];
      result$data['maxSourcesInParallel'] = (l$maxSourcesInParallel as int?);
    }
    if (data.containsKey('port')) {
      final l$port = data['port'];
      result$data['port'] = (l$port as int?);
    }
    if (data.containsKey('socksProxyEnabled')) {
      final l$socksProxyEnabled = data['socksProxyEnabled'];
      result$data['socksProxyEnabled'] = (l$socksProxyEnabled as bool?);
    }
    if (data.containsKey('socksProxyHost')) {
      final l$socksProxyHost = data['socksProxyHost'];
      result$data['socksProxyHost'] = (l$socksProxyHost as String?);
    }
    if (data.containsKey('socksProxyPassword')) {
      final l$socksProxyPassword = data['socksProxyPassword'];
      result$data['socksProxyPassword'] = (l$socksProxyPassword as String?);
    }
    if (data.containsKey('socksProxyPort')) {
      final l$socksProxyPort = data['socksProxyPort'];
      result$data['socksProxyPort'] = (l$socksProxyPort as String?);
    }
    if (data.containsKey('socksProxyUsername')) {
      final l$socksProxyUsername = data['socksProxyUsername'];
      result$data['socksProxyUsername'] = (l$socksProxyUsername as String?);
    }
    if (data.containsKey('socksProxyVersion')) {
      final l$socksProxyVersion = data['socksProxyVersion'];
      result$data['socksProxyVersion'] = (l$socksProxyVersion as int?);
    }
    if (data.containsKey('systemTrayEnabled')) {
      final l$systemTrayEnabled = data['systemTrayEnabled'];
      result$data['systemTrayEnabled'] = (l$systemTrayEnabled as bool?);
    }
    if (data.containsKey('updateMangas')) {
      final l$updateMangas = data['updateMangas'];
      result$data['updateMangas'] = (l$updateMangas as bool?);
    }
    if (data.containsKey('webUIChannel')) {
      final l$webUIChannel = data['webUIChannel'];
      result$data['webUIChannel'] = l$webUIChannel == null
          ? null
          : fromJson$Enum$WebUIChannel((l$webUIChannel as String));
    }
    if (data.containsKey('webUIFlavor')) {
      final l$webUIFlavor = data['webUIFlavor'];
      result$data['webUIFlavor'] = l$webUIFlavor == null
          ? null
          : fromJson$Enum$WebUIFlavor((l$webUIFlavor as String));
    }
    if (data.containsKey('webUIInterface')) {
      final l$webUIInterface = data['webUIInterface'];
      result$data['webUIInterface'] = l$webUIInterface == null
          ? null
          : fromJson$Enum$WebUIInterface((l$webUIInterface as String));
    }
    if (data.containsKey('webUIUpdateCheckInterval')) {
      final l$webUIUpdateCheckInterval = data['webUIUpdateCheckInterval'];
      result$data['webUIUpdateCheckInterval'] =
          (l$webUIUpdateCheckInterval as num?)?.toDouble();
    }
    return Input$PartialSettingsTypeInput._(result$data);
  }

  Map<String, dynamic> _$data;

  bool? get autoDownloadIgnoreReUploads =>
      (_$data['autoDownloadIgnoreReUploads'] as bool?);

  bool? get autoDownloadNewChapters =>
      (_$data['autoDownloadNewChapters'] as bool?);

  int? get autoDownloadNewChaptersLimit =>
      (_$data['autoDownloadNewChaptersLimit'] as int?);

  int? get backupInterval => (_$data['backupInterval'] as int?);

  String? get backupPath => (_$data['backupPath'] as String?);

  int? get backupTTL => (_$data['backupTTL'] as int?);

  String? get backupTime => (_$data['backupTime'] as String?);

  bool? get basicAuthEnabled => (_$data['basicAuthEnabled'] as bool?);

  String? get basicAuthPassword => (_$data['basicAuthPassword'] as String?);

  String? get basicAuthUsername => (_$data['basicAuthUsername'] as String?);

  bool? get debugLogsEnabled => (_$data['debugLogsEnabled'] as bool?);

  bool? get downloadAsCbz => (_$data['downloadAsCbz'] as bool?);

  String? get downloadsPath => (_$data['downloadsPath'] as String?);

  String? get electronPath => (_$data['electronPath'] as String?);

  bool? get excludeCompleted => (_$data['excludeCompleted'] as bool?);

  bool? get excludeEntryWithUnreadChapters =>
      (_$data['excludeEntryWithUnreadChapters'] as bool?);

  bool? get excludeNotStarted => (_$data['excludeNotStarted'] as bool?);

  bool? get excludeUnreadChapters => (_$data['excludeUnreadChapters'] as bool?);

  List<String>? get extensionRepos =>
      (_$data['extensionRepos'] as List<String>?);

  bool? get flareSolverrAsResponseFallback =>
      (_$data['flareSolverrAsResponseFallback'] as bool?);

  bool? get flareSolverrEnabled => (_$data['flareSolverrEnabled'] as bool?);

  String? get flareSolverrSessionName =>
      (_$data['flareSolverrSessionName'] as String?);

  int? get flareSolverrSessionTtl => (_$data['flareSolverrSessionTtl'] as int?);

  int? get flareSolverrTimeout => (_$data['flareSolverrTimeout'] as int?);

  String? get flareSolverrUrl => (_$data['flareSolverrUrl'] as String?);

  double? get globalUpdateInterval =>
      (_$data['globalUpdateInterval'] as double?);

  bool? get initialOpenInBrowserEnabled =>
      (_$data['initialOpenInBrowserEnabled'] as bool?);

  String? get ip => (_$data['ip'] as String?);

  String? get localSourcePath => (_$data['localSourcePath'] as String?);

  String? get maxLogFileSize => (_$data['maxLogFileSize'] as String?);

  int? get maxLogFiles => (_$data['maxLogFiles'] as int?);

  String? get maxLogFolderSize => (_$data['maxLogFolderSize'] as String?);

  int? get maxSourcesInParallel => (_$data['maxSourcesInParallel'] as int?);

  int? get port => (_$data['port'] as int?);

  bool? get socksProxyEnabled => (_$data['socksProxyEnabled'] as bool?);

  String? get socksProxyHost => (_$data['socksProxyHost'] as String?);

  String? get socksProxyPassword => (_$data['socksProxyPassword'] as String?);

  String? get socksProxyPort => (_$data['socksProxyPort'] as String?);

  String? get socksProxyUsername => (_$data['socksProxyUsername'] as String?);

  int? get socksProxyVersion => (_$data['socksProxyVersion'] as int?);

  bool? get systemTrayEnabled => (_$data['systemTrayEnabled'] as bool?);

  bool? get updateMangas => (_$data['updateMangas'] as bool?);

  Enum$WebUIChannel? get webUIChannel =>
      (_$data['webUIChannel'] as Enum$WebUIChannel?);

  Enum$WebUIFlavor? get webUIFlavor =>
      (_$data['webUIFlavor'] as Enum$WebUIFlavor?);

  Enum$WebUIInterface? get webUIInterface =>
      (_$data['webUIInterface'] as Enum$WebUIInterface?);

  double? get webUIUpdateCheckInterval =>
      (_$data['webUIUpdateCheckInterval'] as double?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('autoDownloadIgnoreReUploads')) {
      final l$autoDownloadIgnoreReUploads = autoDownloadIgnoreReUploads;
      result$data['autoDownloadIgnoreReUploads'] =
          l$autoDownloadIgnoreReUploads;
    }
    if (_$data.containsKey('autoDownloadNewChapters')) {
      final l$autoDownloadNewChapters = autoDownloadNewChapters;
      result$data['autoDownloadNewChapters'] = l$autoDownloadNewChapters;
    }
    if (_$data.containsKey('autoDownloadNewChaptersLimit')) {
      final l$autoDownloadNewChaptersLimit = autoDownloadNewChaptersLimit;
      result$data['autoDownloadNewChaptersLimit'] =
          l$autoDownloadNewChaptersLimit;
    }
    if (_$data.containsKey('backupInterval')) {
      final l$backupInterval = backupInterval;
      result$data['backupInterval'] = l$backupInterval;
    }
    if (_$data.containsKey('backupPath')) {
      final l$backupPath = backupPath;
      result$data['backupPath'] = l$backupPath;
    }
    if (_$data.containsKey('backupTTL')) {
      final l$backupTTL = backupTTL;
      result$data['backupTTL'] = l$backupTTL;
    }
    if (_$data.containsKey('backupTime')) {
      final l$backupTime = backupTime;
      result$data['backupTime'] = l$backupTime;
    }
    if (_$data.containsKey('basicAuthEnabled')) {
      final l$basicAuthEnabled = basicAuthEnabled;
      result$data['basicAuthEnabled'] = l$basicAuthEnabled;
    }
    if (_$data.containsKey('basicAuthPassword')) {
      final l$basicAuthPassword = basicAuthPassword;
      result$data['basicAuthPassword'] = l$basicAuthPassword;
    }
    if (_$data.containsKey('basicAuthUsername')) {
      final l$basicAuthUsername = basicAuthUsername;
      result$data['basicAuthUsername'] = l$basicAuthUsername;
    }
    if (_$data.containsKey('debugLogsEnabled')) {
      final l$debugLogsEnabled = debugLogsEnabled;
      result$data['debugLogsEnabled'] = l$debugLogsEnabled;
    }
    if (_$data.containsKey('downloadAsCbz')) {
      final l$downloadAsCbz = downloadAsCbz;
      result$data['downloadAsCbz'] = l$downloadAsCbz;
    }
    if (_$data.containsKey('downloadsPath')) {
      final l$downloadsPath = downloadsPath;
      result$data['downloadsPath'] = l$downloadsPath;
    }
    if (_$data.containsKey('electronPath')) {
      final l$electronPath = electronPath;
      result$data['electronPath'] = l$electronPath;
    }
    if (_$data.containsKey('excludeCompleted')) {
      final l$excludeCompleted = excludeCompleted;
      result$data['excludeCompleted'] = l$excludeCompleted;
    }
    if (_$data.containsKey('excludeEntryWithUnreadChapters')) {
      final l$excludeEntryWithUnreadChapters = excludeEntryWithUnreadChapters;
      result$data['excludeEntryWithUnreadChapters'] =
          l$excludeEntryWithUnreadChapters;
    }
    if (_$data.containsKey('excludeNotStarted')) {
      final l$excludeNotStarted = excludeNotStarted;
      result$data['excludeNotStarted'] = l$excludeNotStarted;
    }
    if (_$data.containsKey('excludeUnreadChapters')) {
      final l$excludeUnreadChapters = excludeUnreadChapters;
      result$data['excludeUnreadChapters'] = l$excludeUnreadChapters;
    }
    if (_$data.containsKey('extensionRepos')) {
      final l$extensionRepos = extensionRepos;
      result$data['extensionRepos'] = l$extensionRepos?.map((e) => e).toList();
    }
    if (_$data.containsKey('flareSolverrAsResponseFallback')) {
      final l$flareSolverrAsResponseFallback = flareSolverrAsResponseFallback;
      result$data['flareSolverrAsResponseFallback'] =
          l$flareSolverrAsResponseFallback;
    }
    if (_$data.containsKey('flareSolverrEnabled')) {
      final l$flareSolverrEnabled = flareSolverrEnabled;
      result$data['flareSolverrEnabled'] = l$flareSolverrEnabled;
    }
    if (_$data.containsKey('flareSolverrSessionName')) {
      final l$flareSolverrSessionName = flareSolverrSessionName;
      result$data['flareSolverrSessionName'] = l$flareSolverrSessionName;
    }
    if (_$data.containsKey('flareSolverrSessionTtl')) {
      final l$flareSolverrSessionTtl = flareSolverrSessionTtl;
      result$data['flareSolverrSessionTtl'] = l$flareSolverrSessionTtl;
    }
    if (_$data.containsKey('flareSolverrTimeout')) {
      final l$flareSolverrTimeout = flareSolverrTimeout;
      result$data['flareSolverrTimeout'] = l$flareSolverrTimeout;
    }
    if (_$data.containsKey('flareSolverrUrl')) {
      final l$flareSolverrUrl = flareSolverrUrl;
      result$data['flareSolverrUrl'] = l$flareSolverrUrl;
    }
    if (_$data.containsKey('globalUpdateInterval')) {
      final l$globalUpdateInterval = globalUpdateInterval;
      result$data['globalUpdateInterval'] = l$globalUpdateInterval;
    }
    if (_$data.containsKey('initialOpenInBrowserEnabled')) {
      final l$initialOpenInBrowserEnabled = initialOpenInBrowserEnabled;
      result$data['initialOpenInBrowserEnabled'] =
          l$initialOpenInBrowserEnabled;
    }
    if (_$data.containsKey('ip')) {
      final l$ip = ip;
      result$data['ip'] = l$ip;
    }
    if (_$data.containsKey('localSourcePath')) {
      final l$localSourcePath = localSourcePath;
      result$data['localSourcePath'] = l$localSourcePath;
    }
    if (_$data.containsKey('maxLogFileSize')) {
      final l$maxLogFileSize = maxLogFileSize;
      result$data['maxLogFileSize'] = l$maxLogFileSize;
    }
    if (_$data.containsKey('maxLogFiles')) {
      final l$maxLogFiles = maxLogFiles;
      result$data['maxLogFiles'] = l$maxLogFiles;
    }
    if (_$data.containsKey('maxLogFolderSize')) {
      final l$maxLogFolderSize = maxLogFolderSize;
      result$data['maxLogFolderSize'] = l$maxLogFolderSize;
    }
    if (_$data.containsKey('maxSourcesInParallel')) {
      final l$maxSourcesInParallel = maxSourcesInParallel;
      result$data['maxSourcesInParallel'] = l$maxSourcesInParallel;
    }
    if (_$data.containsKey('port')) {
      final l$port = port;
      result$data['port'] = l$port;
    }
    if (_$data.containsKey('socksProxyEnabled')) {
      final l$socksProxyEnabled = socksProxyEnabled;
      result$data['socksProxyEnabled'] = l$socksProxyEnabled;
    }
    if (_$data.containsKey('socksProxyHost')) {
      final l$socksProxyHost = socksProxyHost;
      result$data['socksProxyHost'] = l$socksProxyHost;
    }
    if (_$data.containsKey('socksProxyPassword')) {
      final l$socksProxyPassword = socksProxyPassword;
      result$data['socksProxyPassword'] = l$socksProxyPassword;
    }
    if (_$data.containsKey('socksProxyPort')) {
      final l$socksProxyPort = socksProxyPort;
      result$data['socksProxyPort'] = l$socksProxyPort;
    }
    if (_$data.containsKey('socksProxyUsername')) {
      final l$socksProxyUsername = socksProxyUsername;
      result$data['socksProxyUsername'] = l$socksProxyUsername;
    }
    if (_$data.containsKey('socksProxyVersion')) {
      final l$socksProxyVersion = socksProxyVersion;
      result$data['socksProxyVersion'] = l$socksProxyVersion;
    }
    if (_$data.containsKey('systemTrayEnabled')) {
      final l$systemTrayEnabled = systemTrayEnabled;
      result$data['systemTrayEnabled'] = l$systemTrayEnabled;
    }
    if (_$data.containsKey('updateMangas')) {
      final l$updateMangas = updateMangas;
      result$data['updateMangas'] = l$updateMangas;
    }
    if (_$data.containsKey('webUIChannel')) {
      final l$webUIChannel = webUIChannel;
      result$data['webUIChannel'] = l$webUIChannel == null
          ? null
          : toJson$Enum$WebUIChannel(l$webUIChannel);
    }
    if (_$data.containsKey('webUIFlavor')) {
      final l$webUIFlavor = webUIFlavor;
      result$data['webUIFlavor'] =
          l$webUIFlavor == null ? null : toJson$Enum$WebUIFlavor(l$webUIFlavor);
    }
    if (_$data.containsKey('webUIInterface')) {
      final l$webUIInterface = webUIInterface;
      result$data['webUIInterface'] = l$webUIInterface == null
          ? null
          : toJson$Enum$WebUIInterface(l$webUIInterface);
    }
    if (_$data.containsKey('webUIUpdateCheckInterval')) {
      final l$webUIUpdateCheckInterval = webUIUpdateCheckInterval;
      result$data['webUIUpdateCheckInterval'] = l$webUIUpdateCheckInterval;
    }
    return result$data;
  }

  CopyWith$Input$PartialSettingsTypeInput<Input$PartialSettingsTypeInput>
      get copyWith => CopyWith$Input$PartialSettingsTypeInput(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$PartialSettingsTypeInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$autoDownloadIgnoreReUploads = autoDownloadIgnoreReUploads;
    final lOther$autoDownloadIgnoreReUploads =
        other.autoDownloadIgnoreReUploads;
    if (_$data.containsKey('autoDownloadIgnoreReUploads') !=
        other._$data.containsKey('autoDownloadIgnoreReUploads')) {
      return false;
    }
    if (l$autoDownloadIgnoreReUploads != lOther$autoDownloadIgnoreReUploads) {
      return false;
    }
    final l$autoDownloadNewChapters = autoDownloadNewChapters;
    final lOther$autoDownloadNewChapters = other.autoDownloadNewChapters;
    if (_$data.containsKey('autoDownloadNewChapters') !=
        other._$data.containsKey('autoDownloadNewChapters')) {
      return false;
    }
    if (l$autoDownloadNewChapters != lOther$autoDownloadNewChapters) {
      return false;
    }
    final l$autoDownloadNewChaptersLimit = autoDownloadNewChaptersLimit;
    final lOther$autoDownloadNewChaptersLimit =
        other.autoDownloadNewChaptersLimit;
    if (_$data.containsKey('autoDownloadNewChaptersLimit') !=
        other._$data.containsKey('autoDownloadNewChaptersLimit')) {
      return false;
    }
    if (l$autoDownloadNewChaptersLimit != lOther$autoDownloadNewChaptersLimit) {
      return false;
    }
    final l$backupInterval = backupInterval;
    final lOther$backupInterval = other.backupInterval;
    if (_$data.containsKey('backupInterval') !=
        other._$data.containsKey('backupInterval')) {
      return false;
    }
    if (l$backupInterval != lOther$backupInterval) {
      return false;
    }
    final l$backupPath = backupPath;
    final lOther$backupPath = other.backupPath;
    if (_$data.containsKey('backupPath') !=
        other._$data.containsKey('backupPath')) {
      return false;
    }
    if (l$backupPath != lOther$backupPath) {
      return false;
    }
    final l$backupTTL = backupTTL;
    final lOther$backupTTL = other.backupTTL;
    if (_$data.containsKey('backupTTL') !=
        other._$data.containsKey('backupTTL')) {
      return false;
    }
    if (l$backupTTL != lOther$backupTTL) {
      return false;
    }
    final l$backupTime = backupTime;
    final lOther$backupTime = other.backupTime;
    if (_$data.containsKey('backupTime') !=
        other._$data.containsKey('backupTime')) {
      return false;
    }
    if (l$backupTime != lOther$backupTime) {
      return false;
    }
    final l$basicAuthEnabled = basicAuthEnabled;
    final lOther$basicAuthEnabled = other.basicAuthEnabled;
    if (_$data.containsKey('basicAuthEnabled') !=
        other._$data.containsKey('basicAuthEnabled')) {
      return false;
    }
    if (l$basicAuthEnabled != lOther$basicAuthEnabled) {
      return false;
    }
    final l$basicAuthPassword = basicAuthPassword;
    final lOther$basicAuthPassword = other.basicAuthPassword;
    if (_$data.containsKey('basicAuthPassword') !=
        other._$data.containsKey('basicAuthPassword')) {
      return false;
    }
    if (l$basicAuthPassword != lOther$basicAuthPassword) {
      return false;
    }
    final l$basicAuthUsername = basicAuthUsername;
    final lOther$basicAuthUsername = other.basicAuthUsername;
    if (_$data.containsKey('basicAuthUsername') !=
        other._$data.containsKey('basicAuthUsername')) {
      return false;
    }
    if (l$basicAuthUsername != lOther$basicAuthUsername) {
      return false;
    }
    final l$debugLogsEnabled = debugLogsEnabled;
    final lOther$debugLogsEnabled = other.debugLogsEnabled;
    if (_$data.containsKey('debugLogsEnabled') !=
        other._$data.containsKey('debugLogsEnabled')) {
      return false;
    }
    if (l$debugLogsEnabled != lOther$debugLogsEnabled) {
      return false;
    }
    final l$downloadAsCbz = downloadAsCbz;
    final lOther$downloadAsCbz = other.downloadAsCbz;
    if (_$data.containsKey('downloadAsCbz') !=
        other._$data.containsKey('downloadAsCbz')) {
      return false;
    }
    if (l$downloadAsCbz != lOther$downloadAsCbz) {
      return false;
    }
    final l$downloadsPath = downloadsPath;
    final lOther$downloadsPath = other.downloadsPath;
    if (_$data.containsKey('downloadsPath') !=
        other._$data.containsKey('downloadsPath')) {
      return false;
    }
    if (l$downloadsPath != lOther$downloadsPath) {
      return false;
    }
    final l$electronPath = electronPath;
    final lOther$electronPath = other.electronPath;
    if (_$data.containsKey('electronPath') !=
        other._$data.containsKey('electronPath')) {
      return false;
    }
    if (l$electronPath != lOther$electronPath) {
      return false;
    }
    final l$excludeCompleted = excludeCompleted;
    final lOther$excludeCompleted = other.excludeCompleted;
    if (_$data.containsKey('excludeCompleted') !=
        other._$data.containsKey('excludeCompleted')) {
      return false;
    }
    if (l$excludeCompleted != lOther$excludeCompleted) {
      return false;
    }
    final l$excludeEntryWithUnreadChapters = excludeEntryWithUnreadChapters;
    final lOther$excludeEntryWithUnreadChapters =
        other.excludeEntryWithUnreadChapters;
    if (_$data.containsKey('excludeEntryWithUnreadChapters') !=
        other._$data.containsKey('excludeEntryWithUnreadChapters')) {
      return false;
    }
    if (l$excludeEntryWithUnreadChapters !=
        lOther$excludeEntryWithUnreadChapters) {
      return false;
    }
    final l$excludeNotStarted = excludeNotStarted;
    final lOther$excludeNotStarted = other.excludeNotStarted;
    if (_$data.containsKey('excludeNotStarted') !=
        other._$data.containsKey('excludeNotStarted')) {
      return false;
    }
    if (l$excludeNotStarted != lOther$excludeNotStarted) {
      return false;
    }
    final l$excludeUnreadChapters = excludeUnreadChapters;
    final lOther$excludeUnreadChapters = other.excludeUnreadChapters;
    if (_$data.containsKey('excludeUnreadChapters') !=
        other._$data.containsKey('excludeUnreadChapters')) {
      return false;
    }
    if (l$excludeUnreadChapters != lOther$excludeUnreadChapters) {
      return false;
    }
    final l$extensionRepos = extensionRepos;
    final lOther$extensionRepos = other.extensionRepos;
    if (_$data.containsKey('extensionRepos') !=
        other._$data.containsKey('extensionRepos')) {
      return false;
    }
    if (l$extensionRepos != null && lOther$extensionRepos != null) {
      if (l$extensionRepos.length != lOther$extensionRepos.length) {
        return false;
      }
      for (int i = 0; i < l$extensionRepos.length; i++) {
        final l$extensionRepos$entry = l$extensionRepos[i];
        final lOther$extensionRepos$entry = lOther$extensionRepos[i];
        if (l$extensionRepos$entry != lOther$extensionRepos$entry) {
          return false;
        }
      }
    } else if (l$extensionRepos != lOther$extensionRepos) {
      return false;
    }
    final l$flareSolverrAsResponseFallback = flareSolverrAsResponseFallback;
    final lOther$flareSolverrAsResponseFallback =
        other.flareSolverrAsResponseFallback;
    if (_$data.containsKey('flareSolverrAsResponseFallback') !=
        other._$data.containsKey('flareSolverrAsResponseFallback')) {
      return false;
    }
    if (l$flareSolverrAsResponseFallback !=
        lOther$flareSolverrAsResponseFallback) {
      return false;
    }
    final l$flareSolverrEnabled = flareSolverrEnabled;
    final lOther$flareSolverrEnabled = other.flareSolverrEnabled;
    if (_$data.containsKey('flareSolverrEnabled') !=
        other._$data.containsKey('flareSolverrEnabled')) {
      return false;
    }
    if (l$flareSolverrEnabled != lOther$flareSolverrEnabled) {
      return false;
    }
    final l$flareSolverrSessionName = flareSolverrSessionName;
    final lOther$flareSolverrSessionName = other.flareSolverrSessionName;
    if (_$data.containsKey('flareSolverrSessionName') !=
        other._$data.containsKey('flareSolverrSessionName')) {
      return false;
    }
    if (l$flareSolverrSessionName != lOther$flareSolverrSessionName) {
      return false;
    }
    final l$flareSolverrSessionTtl = flareSolverrSessionTtl;
    final lOther$flareSolverrSessionTtl = other.flareSolverrSessionTtl;
    if (_$data.containsKey('flareSolverrSessionTtl') !=
        other._$data.containsKey('flareSolverrSessionTtl')) {
      return false;
    }
    if (l$flareSolverrSessionTtl != lOther$flareSolverrSessionTtl) {
      return false;
    }
    final l$flareSolverrTimeout = flareSolverrTimeout;
    final lOther$flareSolverrTimeout = other.flareSolverrTimeout;
    if (_$data.containsKey('flareSolverrTimeout') !=
        other._$data.containsKey('flareSolverrTimeout')) {
      return false;
    }
    if (l$flareSolverrTimeout != lOther$flareSolverrTimeout) {
      return false;
    }
    final l$flareSolverrUrl = flareSolverrUrl;
    final lOther$flareSolverrUrl = other.flareSolverrUrl;
    if (_$data.containsKey('flareSolverrUrl') !=
        other._$data.containsKey('flareSolverrUrl')) {
      return false;
    }
    if (l$flareSolverrUrl != lOther$flareSolverrUrl) {
      return false;
    }
    final l$globalUpdateInterval = globalUpdateInterval;
    final lOther$globalUpdateInterval = other.globalUpdateInterval;
    if (_$data.containsKey('globalUpdateInterval') !=
        other._$data.containsKey('globalUpdateInterval')) {
      return false;
    }
    if (l$globalUpdateInterval != lOther$globalUpdateInterval) {
      return false;
    }
    final l$initialOpenInBrowserEnabled = initialOpenInBrowserEnabled;
    final lOther$initialOpenInBrowserEnabled =
        other.initialOpenInBrowserEnabled;
    if (_$data.containsKey('initialOpenInBrowserEnabled') !=
        other._$data.containsKey('initialOpenInBrowserEnabled')) {
      return false;
    }
    if (l$initialOpenInBrowserEnabled != lOther$initialOpenInBrowserEnabled) {
      return false;
    }
    final l$ip = ip;
    final lOther$ip = other.ip;
    if (_$data.containsKey('ip') != other._$data.containsKey('ip')) {
      return false;
    }
    if (l$ip != lOther$ip) {
      return false;
    }
    final l$localSourcePath = localSourcePath;
    final lOther$localSourcePath = other.localSourcePath;
    if (_$data.containsKey('localSourcePath') !=
        other._$data.containsKey('localSourcePath')) {
      return false;
    }
    if (l$localSourcePath != lOther$localSourcePath) {
      return false;
    }
    final l$maxLogFileSize = maxLogFileSize;
    final lOther$maxLogFileSize = other.maxLogFileSize;
    if (_$data.containsKey('maxLogFileSize') !=
        other._$data.containsKey('maxLogFileSize')) {
      return false;
    }
    if (l$maxLogFileSize != lOther$maxLogFileSize) {
      return false;
    }
    final l$maxLogFiles = maxLogFiles;
    final lOther$maxLogFiles = other.maxLogFiles;
    if (_$data.containsKey('maxLogFiles') !=
        other._$data.containsKey('maxLogFiles')) {
      return false;
    }
    if (l$maxLogFiles != lOther$maxLogFiles) {
      return false;
    }
    final l$maxLogFolderSize = maxLogFolderSize;
    final lOther$maxLogFolderSize = other.maxLogFolderSize;
    if (_$data.containsKey('maxLogFolderSize') !=
        other._$data.containsKey('maxLogFolderSize')) {
      return false;
    }
    if (l$maxLogFolderSize != lOther$maxLogFolderSize) {
      return false;
    }
    final l$maxSourcesInParallel = maxSourcesInParallel;
    final lOther$maxSourcesInParallel = other.maxSourcesInParallel;
    if (_$data.containsKey('maxSourcesInParallel') !=
        other._$data.containsKey('maxSourcesInParallel')) {
      return false;
    }
    if (l$maxSourcesInParallel != lOther$maxSourcesInParallel) {
      return false;
    }
    final l$port = port;
    final lOther$port = other.port;
    if (_$data.containsKey('port') != other._$data.containsKey('port')) {
      return false;
    }
    if (l$port != lOther$port) {
      return false;
    }
    final l$socksProxyEnabled = socksProxyEnabled;
    final lOther$socksProxyEnabled = other.socksProxyEnabled;
    if (_$data.containsKey('socksProxyEnabled') !=
        other._$data.containsKey('socksProxyEnabled')) {
      return false;
    }
    if (l$socksProxyEnabled != lOther$socksProxyEnabled) {
      return false;
    }
    final l$socksProxyHost = socksProxyHost;
    final lOther$socksProxyHost = other.socksProxyHost;
    if (_$data.containsKey('socksProxyHost') !=
        other._$data.containsKey('socksProxyHost')) {
      return false;
    }
    if (l$socksProxyHost != lOther$socksProxyHost) {
      return false;
    }
    final l$socksProxyPassword = socksProxyPassword;
    final lOther$socksProxyPassword = other.socksProxyPassword;
    if (_$data.containsKey('socksProxyPassword') !=
        other._$data.containsKey('socksProxyPassword')) {
      return false;
    }
    if (l$socksProxyPassword != lOther$socksProxyPassword) {
      return false;
    }
    final l$socksProxyPort = socksProxyPort;
    final lOther$socksProxyPort = other.socksProxyPort;
    if (_$data.containsKey('socksProxyPort') !=
        other._$data.containsKey('socksProxyPort')) {
      return false;
    }
    if (l$socksProxyPort != lOther$socksProxyPort) {
      return false;
    }
    final l$socksProxyUsername = socksProxyUsername;
    final lOther$socksProxyUsername = other.socksProxyUsername;
    if (_$data.containsKey('socksProxyUsername') !=
        other._$data.containsKey('socksProxyUsername')) {
      return false;
    }
    if (l$socksProxyUsername != lOther$socksProxyUsername) {
      return false;
    }
    final l$socksProxyVersion = socksProxyVersion;
    final lOther$socksProxyVersion = other.socksProxyVersion;
    if (_$data.containsKey('socksProxyVersion') !=
        other._$data.containsKey('socksProxyVersion')) {
      return false;
    }
    if (l$socksProxyVersion != lOther$socksProxyVersion) {
      return false;
    }
    final l$systemTrayEnabled = systemTrayEnabled;
    final lOther$systemTrayEnabled = other.systemTrayEnabled;
    if (_$data.containsKey('systemTrayEnabled') !=
        other._$data.containsKey('systemTrayEnabled')) {
      return false;
    }
    if (l$systemTrayEnabled != lOther$systemTrayEnabled) {
      return false;
    }
    final l$updateMangas = updateMangas;
    final lOther$updateMangas = other.updateMangas;
    if (_$data.containsKey('updateMangas') !=
        other._$data.containsKey('updateMangas')) {
      return false;
    }
    if (l$updateMangas != lOther$updateMangas) {
      return false;
    }
    final l$webUIChannel = webUIChannel;
    final lOther$webUIChannel = other.webUIChannel;
    if (_$data.containsKey('webUIChannel') !=
        other._$data.containsKey('webUIChannel')) {
      return false;
    }
    if (l$webUIChannel != lOther$webUIChannel) {
      return false;
    }
    final l$webUIFlavor = webUIFlavor;
    final lOther$webUIFlavor = other.webUIFlavor;
    if (_$data.containsKey('webUIFlavor') !=
        other._$data.containsKey('webUIFlavor')) {
      return false;
    }
    if (l$webUIFlavor != lOther$webUIFlavor) {
      return false;
    }
    final l$webUIInterface = webUIInterface;
    final lOther$webUIInterface = other.webUIInterface;
    if (_$data.containsKey('webUIInterface') !=
        other._$data.containsKey('webUIInterface')) {
      return false;
    }
    if (l$webUIInterface != lOther$webUIInterface) {
      return false;
    }
    final l$webUIUpdateCheckInterval = webUIUpdateCheckInterval;
    final lOther$webUIUpdateCheckInterval = other.webUIUpdateCheckInterval;
    if (_$data.containsKey('webUIUpdateCheckInterval') !=
        other._$data.containsKey('webUIUpdateCheckInterval')) {
      return false;
    }
    if (l$webUIUpdateCheckInterval != lOther$webUIUpdateCheckInterval) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$autoDownloadIgnoreReUploads = autoDownloadIgnoreReUploads;
    final l$autoDownloadNewChapters = autoDownloadNewChapters;
    final l$autoDownloadNewChaptersLimit = autoDownloadNewChaptersLimit;
    final l$backupInterval = backupInterval;
    final l$backupPath = backupPath;
    final l$backupTTL = backupTTL;
    final l$backupTime = backupTime;
    final l$basicAuthEnabled = basicAuthEnabled;
    final l$basicAuthPassword = basicAuthPassword;
    final l$basicAuthUsername = basicAuthUsername;
    final l$debugLogsEnabled = debugLogsEnabled;
    final l$downloadAsCbz = downloadAsCbz;
    final l$downloadsPath = downloadsPath;
    final l$electronPath = electronPath;
    final l$excludeCompleted = excludeCompleted;
    final l$excludeEntryWithUnreadChapters = excludeEntryWithUnreadChapters;
    final l$excludeNotStarted = excludeNotStarted;
    final l$excludeUnreadChapters = excludeUnreadChapters;
    final l$extensionRepos = extensionRepos;
    final l$flareSolverrAsResponseFallback = flareSolverrAsResponseFallback;
    final l$flareSolverrEnabled = flareSolverrEnabled;
    final l$flareSolverrSessionName = flareSolverrSessionName;
    final l$flareSolverrSessionTtl = flareSolverrSessionTtl;
    final l$flareSolverrTimeout = flareSolverrTimeout;
    final l$flareSolverrUrl = flareSolverrUrl;
    final l$globalUpdateInterval = globalUpdateInterval;
    final l$initialOpenInBrowserEnabled = initialOpenInBrowserEnabled;
    final l$ip = ip;
    final l$localSourcePath = localSourcePath;
    final l$maxLogFileSize = maxLogFileSize;
    final l$maxLogFiles = maxLogFiles;
    final l$maxLogFolderSize = maxLogFolderSize;
    final l$maxSourcesInParallel = maxSourcesInParallel;
    final l$port = port;
    final l$socksProxyEnabled = socksProxyEnabled;
    final l$socksProxyHost = socksProxyHost;
    final l$socksProxyPassword = socksProxyPassword;
    final l$socksProxyPort = socksProxyPort;
    final l$socksProxyUsername = socksProxyUsername;
    final l$socksProxyVersion = socksProxyVersion;
    final l$systemTrayEnabled = systemTrayEnabled;
    final l$updateMangas = updateMangas;
    final l$webUIChannel = webUIChannel;
    final l$webUIFlavor = webUIFlavor;
    final l$webUIInterface = webUIInterface;
    final l$webUIUpdateCheckInterval = webUIUpdateCheckInterval;
    return Object.hashAll([
      _$data.containsKey('autoDownloadIgnoreReUploads')
          ? l$autoDownloadIgnoreReUploads
          : const {},
      _$data.containsKey('autoDownloadNewChapters')
          ? l$autoDownloadNewChapters
          : const {},
      _$data.containsKey('autoDownloadNewChaptersLimit')
          ? l$autoDownloadNewChaptersLimit
          : const {},
      _$data.containsKey('backupInterval') ? l$backupInterval : const {},
      _$data.containsKey('backupPath') ? l$backupPath : const {},
      _$data.containsKey('backupTTL') ? l$backupTTL : const {},
      _$data.containsKey('backupTime') ? l$backupTime : const {},
      _$data.containsKey('basicAuthEnabled') ? l$basicAuthEnabled : const {},
      _$data.containsKey('basicAuthPassword') ? l$basicAuthPassword : const {},
      _$data.containsKey('basicAuthUsername') ? l$basicAuthUsername : const {},
      _$data.containsKey('debugLogsEnabled') ? l$debugLogsEnabled : const {},
      _$data.containsKey('downloadAsCbz') ? l$downloadAsCbz : const {},
      _$data.containsKey('downloadsPath') ? l$downloadsPath : const {},
      _$data.containsKey('electronPath') ? l$electronPath : const {},
      _$data.containsKey('excludeCompleted') ? l$excludeCompleted : const {},
      _$data.containsKey('excludeEntryWithUnreadChapters')
          ? l$excludeEntryWithUnreadChapters
          : const {},
      _$data.containsKey('excludeNotStarted') ? l$excludeNotStarted : const {},
      _$data.containsKey('excludeUnreadChapters')
          ? l$excludeUnreadChapters
          : const {},
      _$data.containsKey('extensionRepos')
          ? l$extensionRepos == null
              ? null
              : Object.hashAll(l$extensionRepos.map((v) => v))
          : const {},
      _$data.containsKey('flareSolverrAsResponseFallback')
          ? l$flareSolverrAsResponseFallback
          : const {},
      _$data.containsKey('flareSolverrEnabled')
          ? l$flareSolverrEnabled
          : const {},
      _$data.containsKey('flareSolverrSessionName')
          ? l$flareSolverrSessionName
          : const {},
      _$data.containsKey('flareSolverrSessionTtl')
          ? l$flareSolverrSessionTtl
          : const {},
      _$data.containsKey('flareSolverrTimeout')
          ? l$flareSolverrTimeout
          : const {},
      _$data.containsKey('flareSolverrUrl') ? l$flareSolverrUrl : const {},
      _$data.containsKey('globalUpdateInterval')
          ? l$globalUpdateInterval
          : const {},
      _$data.containsKey('initialOpenInBrowserEnabled')
          ? l$initialOpenInBrowserEnabled
          : const {},
      _$data.containsKey('ip') ? l$ip : const {},
      _$data.containsKey('localSourcePath') ? l$localSourcePath : const {},
      _$data.containsKey('maxLogFileSize') ? l$maxLogFileSize : const {},
      _$data.containsKey('maxLogFiles') ? l$maxLogFiles : const {},
      _$data.containsKey('maxLogFolderSize') ? l$maxLogFolderSize : const {},
      _$data.containsKey('maxSourcesInParallel')
          ? l$maxSourcesInParallel
          : const {},
      _$data.containsKey('port') ? l$port : const {},
      _$data.containsKey('socksProxyEnabled') ? l$socksProxyEnabled : const {},
      _$data.containsKey('socksProxyHost') ? l$socksProxyHost : const {},
      _$data.containsKey('socksProxyPassword')
          ? l$socksProxyPassword
          : const {},
      _$data.containsKey('socksProxyPort') ? l$socksProxyPort : const {},
      _$data.containsKey('socksProxyUsername')
          ? l$socksProxyUsername
          : const {},
      _$data.containsKey('socksProxyVersion') ? l$socksProxyVersion : const {},
      _$data.containsKey('systemTrayEnabled') ? l$systemTrayEnabled : const {},
      _$data.containsKey('updateMangas') ? l$updateMangas : const {},
      _$data.containsKey('webUIChannel') ? l$webUIChannel : const {},
      _$data.containsKey('webUIFlavor') ? l$webUIFlavor : const {},
      _$data.containsKey('webUIInterface') ? l$webUIInterface : const {},
      _$data.containsKey('webUIUpdateCheckInterval')
          ? l$webUIUpdateCheckInterval
          : const {},
    ]);
  }
}

abstract class CopyWith$Input$PartialSettingsTypeInput<TRes> {
  factory CopyWith$Input$PartialSettingsTypeInput(
    Input$PartialSettingsTypeInput instance,
    TRes Function(Input$PartialSettingsTypeInput) then,
  ) = _CopyWithImpl$Input$PartialSettingsTypeInput;

  factory CopyWith$Input$PartialSettingsTypeInput.stub(TRes res) =
      _CopyWithStubImpl$Input$PartialSettingsTypeInput;

  TRes call({
    bool? autoDownloadIgnoreReUploads,
    bool? autoDownloadNewChapters,
    int? autoDownloadNewChaptersLimit,
    int? backupInterval,
    String? backupPath,
    int? backupTTL,
    String? backupTime,
    bool? basicAuthEnabled,
    String? basicAuthPassword,
    String? basicAuthUsername,
    bool? debugLogsEnabled,
    bool? downloadAsCbz,
    String? downloadsPath,
    String? electronPath,
    bool? excludeCompleted,
    bool? excludeEntryWithUnreadChapters,
    bool? excludeNotStarted,
    bool? excludeUnreadChapters,
    List<String>? extensionRepos,
    bool? flareSolverrAsResponseFallback,
    bool? flareSolverrEnabled,
    String? flareSolverrSessionName,
    int? flareSolverrSessionTtl,
    int? flareSolverrTimeout,
    String? flareSolverrUrl,
    double? globalUpdateInterval,
    bool? initialOpenInBrowserEnabled,
    String? ip,
    String? localSourcePath,
    String? maxLogFileSize,
    int? maxLogFiles,
    String? maxLogFolderSize,
    int? maxSourcesInParallel,
    int? port,
    bool? socksProxyEnabled,
    String? socksProxyHost,
    String? socksProxyPassword,
    String? socksProxyPort,
    String? socksProxyUsername,
    int? socksProxyVersion,
    bool? systemTrayEnabled,
    bool? updateMangas,
    Enum$WebUIChannel? webUIChannel,
    Enum$WebUIFlavor? webUIFlavor,
    Enum$WebUIInterface? webUIInterface,
    double? webUIUpdateCheckInterval,
  });
}

class _CopyWithImpl$Input$PartialSettingsTypeInput<TRes>
    implements CopyWith$Input$PartialSettingsTypeInput<TRes> {
  _CopyWithImpl$Input$PartialSettingsTypeInput(
    this._instance,
    this._then,
  );

  final Input$PartialSettingsTypeInput _instance;

  final TRes Function(Input$PartialSettingsTypeInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? autoDownloadIgnoreReUploads = _undefined,
    Object? autoDownloadNewChapters = _undefined,
    Object? autoDownloadNewChaptersLimit = _undefined,
    Object? backupInterval = _undefined,
    Object? backupPath = _undefined,
    Object? backupTTL = _undefined,
    Object? backupTime = _undefined,
    Object? basicAuthEnabled = _undefined,
    Object? basicAuthPassword = _undefined,
    Object? basicAuthUsername = _undefined,
    Object? debugLogsEnabled = _undefined,
    Object? downloadAsCbz = _undefined,
    Object? downloadsPath = _undefined,
    Object? electronPath = _undefined,
    Object? excludeCompleted = _undefined,
    Object? excludeEntryWithUnreadChapters = _undefined,
    Object? excludeNotStarted = _undefined,
    Object? excludeUnreadChapters = _undefined,
    Object? extensionRepos = _undefined,
    Object? flareSolverrAsResponseFallback = _undefined,
    Object? flareSolverrEnabled = _undefined,
    Object? flareSolverrSessionName = _undefined,
    Object? flareSolverrSessionTtl = _undefined,
    Object? flareSolverrTimeout = _undefined,
    Object? flareSolverrUrl = _undefined,
    Object? globalUpdateInterval = _undefined,
    Object? initialOpenInBrowserEnabled = _undefined,
    Object? ip = _undefined,
    Object? localSourcePath = _undefined,
    Object? maxLogFileSize = _undefined,
    Object? maxLogFiles = _undefined,
    Object? maxLogFolderSize = _undefined,
    Object? maxSourcesInParallel = _undefined,
    Object? port = _undefined,
    Object? socksProxyEnabled = _undefined,
    Object? socksProxyHost = _undefined,
    Object? socksProxyPassword = _undefined,
    Object? socksProxyPort = _undefined,
    Object? socksProxyUsername = _undefined,
    Object? socksProxyVersion = _undefined,
    Object? systemTrayEnabled = _undefined,
    Object? updateMangas = _undefined,
    Object? webUIChannel = _undefined,
    Object? webUIFlavor = _undefined,
    Object? webUIInterface = _undefined,
    Object? webUIUpdateCheckInterval = _undefined,
  }) =>
      _then(Input$PartialSettingsTypeInput._({
        ..._instance._$data,
        if (autoDownloadIgnoreReUploads != _undefined)
          'autoDownloadIgnoreReUploads': (autoDownloadIgnoreReUploads as bool?),
        if (autoDownloadNewChapters != _undefined)
          'autoDownloadNewChapters': (autoDownloadNewChapters as bool?),
        if (autoDownloadNewChaptersLimit != _undefined)
          'autoDownloadNewChaptersLimit':
              (autoDownloadNewChaptersLimit as int?),
        if (backupInterval != _undefined)
          'backupInterval': (backupInterval as int?),
        if (backupPath != _undefined) 'backupPath': (backupPath as String?),
        if (backupTTL != _undefined) 'backupTTL': (backupTTL as int?),
        if (backupTime != _undefined) 'backupTime': (backupTime as String?),
        if (basicAuthEnabled != _undefined)
          'basicAuthEnabled': (basicAuthEnabled as bool?),
        if (basicAuthPassword != _undefined)
          'basicAuthPassword': (basicAuthPassword as String?),
        if (basicAuthUsername != _undefined)
          'basicAuthUsername': (basicAuthUsername as String?),
        if (debugLogsEnabled != _undefined)
          'debugLogsEnabled': (debugLogsEnabled as bool?),
        if (downloadAsCbz != _undefined)
          'downloadAsCbz': (downloadAsCbz as bool?),
        if (downloadsPath != _undefined)
          'downloadsPath': (downloadsPath as String?),
        if (electronPath != _undefined)
          'electronPath': (electronPath as String?),
        if (excludeCompleted != _undefined)
          'excludeCompleted': (excludeCompleted as bool?),
        if (excludeEntryWithUnreadChapters != _undefined)
          'excludeEntryWithUnreadChapters':
              (excludeEntryWithUnreadChapters as bool?),
        if (excludeNotStarted != _undefined)
          'excludeNotStarted': (excludeNotStarted as bool?),
        if (excludeUnreadChapters != _undefined)
          'excludeUnreadChapters': (excludeUnreadChapters as bool?),
        if (extensionRepos != _undefined)
          'extensionRepos': (extensionRepos as List<String>?),
        if (flareSolverrAsResponseFallback != _undefined)
          'flareSolverrAsResponseFallback':
              (flareSolverrAsResponseFallback as bool?),
        if (flareSolverrEnabled != _undefined)
          'flareSolverrEnabled': (flareSolverrEnabled as bool?),
        if (flareSolverrSessionName != _undefined)
          'flareSolverrSessionName': (flareSolverrSessionName as String?),
        if (flareSolverrSessionTtl != _undefined)
          'flareSolverrSessionTtl': (flareSolverrSessionTtl as int?),
        if (flareSolverrTimeout != _undefined)
          'flareSolverrTimeout': (flareSolverrTimeout as int?),
        if (flareSolverrUrl != _undefined)
          'flareSolverrUrl': (flareSolverrUrl as String?),
        if (globalUpdateInterval != _undefined)
          'globalUpdateInterval': (globalUpdateInterval as double?),
        if (initialOpenInBrowserEnabled != _undefined)
          'initialOpenInBrowserEnabled': (initialOpenInBrowserEnabled as bool?),
        if (ip != _undefined) 'ip': (ip as String?),
        if (localSourcePath != _undefined)
          'localSourcePath': (localSourcePath as String?),
        if (maxLogFileSize != _undefined)
          'maxLogFileSize': (maxLogFileSize as String?),
        if (maxLogFiles != _undefined) 'maxLogFiles': (maxLogFiles as int?),
        if (maxLogFolderSize != _undefined)
          'maxLogFolderSize': (maxLogFolderSize as String?),
        if (maxSourcesInParallel != _undefined)
          'maxSourcesInParallel': (maxSourcesInParallel as int?),
        if (port != _undefined) 'port': (port as int?),
        if (socksProxyEnabled != _undefined)
          'socksProxyEnabled': (socksProxyEnabled as bool?),
        if (socksProxyHost != _undefined)
          'socksProxyHost': (socksProxyHost as String?),
        if (socksProxyPassword != _undefined)
          'socksProxyPassword': (socksProxyPassword as String?),
        if (socksProxyPort != _undefined)
          'socksProxyPort': (socksProxyPort as String?),
        if (socksProxyUsername != _undefined)
          'socksProxyUsername': (socksProxyUsername as String?),
        if (socksProxyVersion != _undefined)
          'socksProxyVersion': (socksProxyVersion as int?),
        if (systemTrayEnabled != _undefined)
          'systemTrayEnabled': (systemTrayEnabled as bool?),
        if (updateMangas != _undefined) 'updateMangas': (updateMangas as bool?),
        if (webUIChannel != _undefined)
          'webUIChannel': (webUIChannel as Enum$WebUIChannel?),
        if (webUIFlavor != _undefined)
          'webUIFlavor': (webUIFlavor as Enum$WebUIFlavor?),
        if (webUIInterface != _undefined)
          'webUIInterface': (webUIInterface as Enum$WebUIInterface?),
        if (webUIUpdateCheckInterval != _undefined)
          'webUIUpdateCheckInterval': (webUIUpdateCheckInterval as double?),
      }));
}

class _CopyWithStubImpl$Input$PartialSettingsTypeInput<TRes>
    implements CopyWith$Input$PartialSettingsTypeInput<TRes> {
  _CopyWithStubImpl$Input$PartialSettingsTypeInput(this._res);

  TRes _res;

  call({
    bool? autoDownloadIgnoreReUploads,
    bool? autoDownloadNewChapters,
    int? autoDownloadNewChaptersLimit,
    int? backupInterval,
    String? backupPath,
    int? backupTTL,
    String? backupTime,
    bool? basicAuthEnabled,
    String? basicAuthPassword,
    String? basicAuthUsername,
    bool? debugLogsEnabled,
    bool? downloadAsCbz,
    String? downloadsPath,
    String? electronPath,
    bool? excludeCompleted,
    bool? excludeEntryWithUnreadChapters,
    bool? excludeNotStarted,
    bool? excludeUnreadChapters,
    List<String>? extensionRepos,
    bool? flareSolverrAsResponseFallback,
    bool? flareSolverrEnabled,
    String? flareSolverrSessionName,
    int? flareSolverrSessionTtl,
    int? flareSolverrTimeout,
    String? flareSolverrUrl,
    double? globalUpdateInterval,
    bool? initialOpenInBrowserEnabled,
    String? ip,
    String? localSourcePath,
    String? maxLogFileSize,
    int? maxLogFiles,
    String? maxLogFolderSize,
    int? maxSourcesInParallel,
    int? port,
    bool? socksProxyEnabled,
    String? socksProxyHost,
    String? socksProxyPassword,
    String? socksProxyPort,
    String? socksProxyUsername,
    int? socksProxyVersion,
    bool? systemTrayEnabled,
    bool? updateMangas,
    Enum$WebUIChannel? webUIChannel,
    Enum$WebUIFlavor? webUIFlavor,
    Enum$WebUIInterface? webUIInterface,
    double? webUIUpdateCheckInterval,
  }) =>
      _res;
}

class Input$ReorderChapterDownloadInput {
  factory Input$ReorderChapterDownloadInput({
    required int chapterId,
    String? clientMutationId,
    required int to,
  }) =>
      Input$ReorderChapterDownloadInput._({
        r'chapterId': chapterId,
        if (clientMutationId != null) r'clientMutationId': clientMutationId,
        r'to': to,
      });

  Input$ReorderChapterDownloadInput._(this._$data);

  factory Input$ReorderChapterDownloadInput.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$chapterId = data['chapterId'];
    result$data['chapterId'] = (l$chapterId as int);
    if (data.containsKey('clientMutationId')) {
      final l$clientMutationId = data['clientMutationId'];
      result$data['clientMutationId'] = (l$clientMutationId as String?);
    }
    final l$to = data['to'];
    result$data['to'] = (l$to as int);
    return Input$ReorderChapterDownloadInput._(result$data);
  }

  Map<String, dynamic> _$data;

  int get chapterId => (_$data['chapterId'] as int);

  String? get clientMutationId => (_$data['clientMutationId'] as String?);

  int get to => (_$data['to'] as int);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$chapterId = chapterId;
    result$data['chapterId'] = l$chapterId;
    if (_$data.containsKey('clientMutationId')) {
      final l$clientMutationId = clientMutationId;
      result$data['clientMutationId'] = l$clientMutationId;
    }
    final l$to = to;
    result$data['to'] = l$to;
    return result$data;
  }

  CopyWith$Input$ReorderChapterDownloadInput<Input$ReorderChapterDownloadInput>
      get copyWith => CopyWith$Input$ReorderChapterDownloadInput(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$ReorderChapterDownloadInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$chapterId = chapterId;
    final lOther$chapterId = other.chapterId;
    if (l$chapterId != lOther$chapterId) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (_$data.containsKey('clientMutationId') !=
        other._$data.containsKey('clientMutationId')) {
      return false;
    }
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    final l$to = to;
    final lOther$to = other.to;
    if (l$to != lOther$to) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$chapterId = chapterId;
    final l$clientMutationId = clientMutationId;
    final l$to = to;
    return Object.hashAll([
      l$chapterId,
      _$data.containsKey('clientMutationId') ? l$clientMutationId : const {},
      l$to,
    ]);
  }
}

abstract class CopyWith$Input$ReorderChapterDownloadInput<TRes> {
  factory CopyWith$Input$ReorderChapterDownloadInput(
    Input$ReorderChapterDownloadInput instance,
    TRes Function(Input$ReorderChapterDownloadInput) then,
  ) = _CopyWithImpl$Input$ReorderChapterDownloadInput;

  factory CopyWith$Input$ReorderChapterDownloadInput.stub(TRes res) =
      _CopyWithStubImpl$Input$ReorderChapterDownloadInput;

  TRes call({
    int? chapterId,
    String? clientMutationId,
    int? to,
  });
}

class _CopyWithImpl$Input$ReorderChapterDownloadInput<TRes>
    implements CopyWith$Input$ReorderChapterDownloadInput<TRes> {
  _CopyWithImpl$Input$ReorderChapterDownloadInput(
    this._instance,
    this._then,
  );

  final Input$ReorderChapterDownloadInput _instance;

  final TRes Function(Input$ReorderChapterDownloadInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? chapterId = _undefined,
    Object? clientMutationId = _undefined,
    Object? to = _undefined,
  }) =>
      _then(Input$ReorderChapterDownloadInput._({
        ..._instance._$data,
        if (chapterId != _undefined && chapterId != null)
          'chapterId': (chapterId as int),
        if (clientMutationId != _undefined)
          'clientMutationId': (clientMutationId as String?),
        if (to != _undefined && to != null) 'to': (to as int),
      }));
}

class _CopyWithStubImpl$Input$ReorderChapterDownloadInput<TRes>
    implements CopyWith$Input$ReorderChapterDownloadInput<TRes> {
  _CopyWithStubImpl$Input$ReorderChapterDownloadInput(this._res);

  TRes _res;

  call({
    int? chapterId,
    String? clientMutationId,
    int? to,
  }) =>
      _res;
}

class Input$ResetSettingsInput {
  factory Input$ResetSettingsInput({String? clientMutationId}) =>
      Input$ResetSettingsInput._({
        if (clientMutationId != null) r'clientMutationId': clientMutationId,
      });

  Input$ResetSettingsInput._(this._$data);

  factory Input$ResetSettingsInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('clientMutationId')) {
      final l$clientMutationId = data['clientMutationId'];
      result$data['clientMutationId'] = (l$clientMutationId as String?);
    }
    return Input$ResetSettingsInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get clientMutationId => (_$data['clientMutationId'] as String?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('clientMutationId')) {
      final l$clientMutationId = clientMutationId;
      result$data['clientMutationId'] = l$clientMutationId;
    }
    return result$data;
  }

  CopyWith$Input$ResetSettingsInput<Input$ResetSettingsInput> get copyWith =>
      CopyWith$Input$ResetSettingsInput(
        this,
        (i) => i,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$ResetSettingsInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (_$data.containsKey('clientMutationId') !=
        other._$data.containsKey('clientMutationId')) {
      return false;
    }
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$clientMutationId = clientMutationId;
    return Object.hashAll([
      _$data.containsKey('clientMutationId') ? l$clientMutationId : const {}
    ]);
  }
}

abstract class CopyWith$Input$ResetSettingsInput<TRes> {
  factory CopyWith$Input$ResetSettingsInput(
    Input$ResetSettingsInput instance,
    TRes Function(Input$ResetSettingsInput) then,
  ) = _CopyWithImpl$Input$ResetSettingsInput;

  factory CopyWith$Input$ResetSettingsInput.stub(TRes res) =
      _CopyWithStubImpl$Input$ResetSettingsInput;

  TRes call({String? clientMutationId});
}

class _CopyWithImpl$Input$ResetSettingsInput<TRes>
    implements CopyWith$Input$ResetSettingsInput<TRes> {
  _CopyWithImpl$Input$ResetSettingsInput(
    this._instance,
    this._then,
  );

  final Input$ResetSettingsInput _instance;

  final TRes Function(Input$ResetSettingsInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? clientMutationId = _undefined}) =>
      _then(Input$ResetSettingsInput._({
        ..._instance._$data,
        if (clientMutationId != _undefined)
          'clientMutationId': (clientMutationId as String?),
      }));
}

class _CopyWithStubImpl$Input$ResetSettingsInput<TRes>
    implements CopyWith$Input$ResetSettingsInput<TRes> {
  _CopyWithStubImpl$Input$ResetSettingsInput(this._res);

  TRes _res;

  call({String? clientMutationId}) => _res;
}

class Input$RestoreBackupInput {
  factory Input$RestoreBackupInput({
    required MultipartFile backup,
    String? clientMutationId,
  }) =>
      Input$RestoreBackupInput._({
        r'backup': backup,
        if (clientMutationId != null) r'clientMutationId': clientMutationId,
      });

  Input$RestoreBackupInput._(this._$data);

  factory Input$RestoreBackupInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$backup = data['backup'];
    result$data['backup'] = fileFromJson(l$backup);
    if (data.containsKey('clientMutationId')) {
      final l$clientMutationId = data['clientMutationId'];
      result$data['clientMutationId'] = (l$clientMutationId as String?);
    }
    return Input$RestoreBackupInput._(result$data);
  }

  Map<String, dynamic> _$data;

  MultipartFile get backup => (_$data['backup'] as MultipartFile);

  String? get clientMutationId => (_$data['clientMutationId'] as String?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$backup = backup;
    result$data['backup'] = fileToJson(l$backup);
    if (_$data.containsKey('clientMutationId')) {
      final l$clientMutationId = clientMutationId;
      result$data['clientMutationId'] = l$clientMutationId;
    }
    return result$data;
  }

  CopyWith$Input$RestoreBackupInput<Input$RestoreBackupInput> get copyWith =>
      CopyWith$Input$RestoreBackupInput(
        this,
        (i) => i,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$RestoreBackupInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$backup = backup;
    final lOther$backup = other.backup;
    if (l$backup != lOther$backup) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (_$data.containsKey('clientMutationId') !=
        other._$data.containsKey('clientMutationId')) {
      return false;
    }
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$backup = backup;
    final l$clientMutationId = clientMutationId;
    return Object.hashAll([
      l$backup,
      _$data.containsKey('clientMutationId') ? l$clientMutationId : const {},
    ]);
  }
}

abstract class CopyWith$Input$RestoreBackupInput<TRes> {
  factory CopyWith$Input$RestoreBackupInput(
    Input$RestoreBackupInput instance,
    TRes Function(Input$RestoreBackupInput) then,
  ) = _CopyWithImpl$Input$RestoreBackupInput;

  factory CopyWith$Input$RestoreBackupInput.stub(TRes res) =
      _CopyWithStubImpl$Input$RestoreBackupInput;

  TRes call({
    MultipartFile? backup,
    String? clientMutationId,
  });
}

class _CopyWithImpl$Input$RestoreBackupInput<TRes>
    implements CopyWith$Input$RestoreBackupInput<TRes> {
  _CopyWithImpl$Input$RestoreBackupInput(
    this._instance,
    this._then,
  );

  final Input$RestoreBackupInput _instance;

  final TRes Function(Input$RestoreBackupInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? backup = _undefined,
    Object? clientMutationId = _undefined,
  }) =>
      _then(Input$RestoreBackupInput._({
        ..._instance._$data,
        if (backup != _undefined && backup != null)
          'backup': (backup as MultipartFile),
        if (clientMutationId != _undefined)
          'clientMutationId': (clientMutationId as String?),
      }));
}

class _CopyWithStubImpl$Input$RestoreBackupInput<TRes>
    implements CopyWith$Input$RestoreBackupInput<TRes> {
  _CopyWithStubImpl$Input$RestoreBackupInput(this._res);

  TRes _res;

  call({
    MultipartFile? backup,
    String? clientMutationId,
  }) =>
      _res;
}

class Input$SearchTrackerInput {
  factory Input$SearchTrackerInput({
    required String query,
    required int trackerId,
  }) =>
      Input$SearchTrackerInput._({
        r'query': query,
        r'trackerId': trackerId,
      });

  Input$SearchTrackerInput._(this._$data);

  factory Input$SearchTrackerInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$query = data['query'];
    result$data['query'] = (l$query as String);
    final l$trackerId = data['trackerId'];
    result$data['trackerId'] = (l$trackerId as int);
    return Input$SearchTrackerInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String get query => (_$data['query'] as String);

  int get trackerId => (_$data['trackerId'] as int);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$query = query;
    result$data['query'] = l$query;
    final l$trackerId = trackerId;
    result$data['trackerId'] = l$trackerId;
    return result$data;
  }

  CopyWith$Input$SearchTrackerInput<Input$SearchTrackerInput> get copyWith =>
      CopyWith$Input$SearchTrackerInput(
        this,
        (i) => i,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$SearchTrackerInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$query = query;
    final lOther$query = other.query;
    if (l$query != lOther$query) {
      return false;
    }
    final l$trackerId = trackerId;
    final lOther$trackerId = other.trackerId;
    if (l$trackerId != lOther$trackerId) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$query = query;
    final l$trackerId = trackerId;
    return Object.hashAll([
      l$query,
      l$trackerId,
    ]);
  }
}

abstract class CopyWith$Input$SearchTrackerInput<TRes> {
  factory CopyWith$Input$SearchTrackerInput(
    Input$SearchTrackerInput instance,
    TRes Function(Input$SearchTrackerInput) then,
  ) = _CopyWithImpl$Input$SearchTrackerInput;

  factory CopyWith$Input$SearchTrackerInput.stub(TRes res) =
      _CopyWithStubImpl$Input$SearchTrackerInput;

  TRes call({
    String? query,
    int? trackerId,
  });
}

class _CopyWithImpl$Input$SearchTrackerInput<TRes>
    implements CopyWith$Input$SearchTrackerInput<TRes> {
  _CopyWithImpl$Input$SearchTrackerInput(
    this._instance,
    this._then,
  );

  final Input$SearchTrackerInput _instance;

  final TRes Function(Input$SearchTrackerInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? query = _undefined,
    Object? trackerId = _undefined,
  }) =>
      _then(Input$SearchTrackerInput._({
        ..._instance._$data,
        if (query != _undefined && query != null) 'query': (query as String),
        if (trackerId != _undefined && trackerId != null)
          'trackerId': (trackerId as int),
      }));
}

class _CopyWithStubImpl$Input$SearchTrackerInput<TRes>
    implements CopyWith$Input$SearchTrackerInput<TRes> {
  _CopyWithStubImpl$Input$SearchTrackerInput(this._res);

  TRes _res;

  call({
    String? query,
    int? trackerId,
  }) =>
      _res;
}

class Input$SetCategoryMetaInput {
  factory Input$SetCategoryMetaInput({
    String? clientMutationId,
    required Input$CategoryMetaTypeInput meta,
  }) =>
      Input$SetCategoryMetaInput._({
        if (clientMutationId != null) r'clientMutationId': clientMutationId,
        r'meta': meta,
      });

  Input$SetCategoryMetaInput._(this._$data);

  factory Input$SetCategoryMetaInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('clientMutationId')) {
      final l$clientMutationId = data['clientMutationId'];
      result$data['clientMutationId'] = (l$clientMutationId as String?);
    }
    final l$meta = data['meta'];
    result$data['meta'] =
        Input$CategoryMetaTypeInput.fromJson((l$meta as Map<String, dynamic>));
    return Input$SetCategoryMetaInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get clientMutationId => (_$data['clientMutationId'] as String?);

  Input$CategoryMetaTypeInput get meta =>
      (_$data['meta'] as Input$CategoryMetaTypeInput);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('clientMutationId')) {
      final l$clientMutationId = clientMutationId;
      result$data['clientMutationId'] = l$clientMutationId;
    }
    final l$meta = meta;
    result$data['meta'] = l$meta.toJson();
    return result$data;
  }

  CopyWith$Input$SetCategoryMetaInput<Input$SetCategoryMetaInput>
      get copyWith => CopyWith$Input$SetCategoryMetaInput(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$SetCategoryMetaInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (_$data.containsKey('clientMutationId') !=
        other._$data.containsKey('clientMutationId')) {
      return false;
    }
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    final l$meta = meta;
    final lOther$meta = other.meta;
    if (l$meta != lOther$meta) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$clientMutationId = clientMutationId;
    final l$meta = meta;
    return Object.hashAll([
      _$data.containsKey('clientMutationId') ? l$clientMutationId : const {},
      l$meta,
    ]);
  }
}

abstract class CopyWith$Input$SetCategoryMetaInput<TRes> {
  factory CopyWith$Input$SetCategoryMetaInput(
    Input$SetCategoryMetaInput instance,
    TRes Function(Input$SetCategoryMetaInput) then,
  ) = _CopyWithImpl$Input$SetCategoryMetaInput;

  factory CopyWith$Input$SetCategoryMetaInput.stub(TRes res) =
      _CopyWithStubImpl$Input$SetCategoryMetaInput;

  TRes call({
    String? clientMutationId,
    Input$CategoryMetaTypeInput? meta,
  });
  CopyWith$Input$CategoryMetaTypeInput<TRes> get meta;
}

class _CopyWithImpl$Input$SetCategoryMetaInput<TRes>
    implements CopyWith$Input$SetCategoryMetaInput<TRes> {
  _CopyWithImpl$Input$SetCategoryMetaInput(
    this._instance,
    this._then,
  );

  final Input$SetCategoryMetaInput _instance;

  final TRes Function(Input$SetCategoryMetaInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? clientMutationId = _undefined,
    Object? meta = _undefined,
  }) =>
      _then(Input$SetCategoryMetaInput._({
        ..._instance._$data,
        if (clientMutationId != _undefined)
          'clientMutationId': (clientMutationId as String?),
        if (meta != _undefined && meta != null)
          'meta': (meta as Input$CategoryMetaTypeInput),
      }));

  CopyWith$Input$CategoryMetaTypeInput<TRes> get meta {
    final local$meta = _instance.meta;
    return CopyWith$Input$CategoryMetaTypeInput(
        local$meta, (e) => call(meta: e));
  }
}

class _CopyWithStubImpl$Input$SetCategoryMetaInput<TRes>
    implements CopyWith$Input$SetCategoryMetaInput<TRes> {
  _CopyWithStubImpl$Input$SetCategoryMetaInput(this._res);

  TRes _res;

  call({
    String? clientMutationId,
    Input$CategoryMetaTypeInput? meta,
  }) =>
      _res;

  CopyWith$Input$CategoryMetaTypeInput<TRes> get meta =>
      CopyWith$Input$CategoryMetaTypeInput.stub(_res);
}

class Input$SetChapterMetaInput {
  factory Input$SetChapterMetaInput({
    String? clientMutationId,
    required Input$ChapterMetaTypeInput meta,
  }) =>
      Input$SetChapterMetaInput._({
        if (clientMutationId != null) r'clientMutationId': clientMutationId,
        r'meta': meta,
      });

  Input$SetChapterMetaInput._(this._$data);

  factory Input$SetChapterMetaInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('clientMutationId')) {
      final l$clientMutationId = data['clientMutationId'];
      result$data['clientMutationId'] = (l$clientMutationId as String?);
    }
    final l$meta = data['meta'];
    result$data['meta'] =
        Input$ChapterMetaTypeInput.fromJson((l$meta as Map<String, dynamic>));
    return Input$SetChapterMetaInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get clientMutationId => (_$data['clientMutationId'] as String?);

  Input$ChapterMetaTypeInput get meta =>
      (_$data['meta'] as Input$ChapterMetaTypeInput);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('clientMutationId')) {
      final l$clientMutationId = clientMutationId;
      result$data['clientMutationId'] = l$clientMutationId;
    }
    final l$meta = meta;
    result$data['meta'] = l$meta.toJson();
    return result$data;
  }

  CopyWith$Input$SetChapterMetaInput<Input$SetChapterMetaInput> get copyWith =>
      CopyWith$Input$SetChapterMetaInput(
        this,
        (i) => i,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$SetChapterMetaInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (_$data.containsKey('clientMutationId') !=
        other._$data.containsKey('clientMutationId')) {
      return false;
    }
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    final l$meta = meta;
    final lOther$meta = other.meta;
    if (l$meta != lOther$meta) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$clientMutationId = clientMutationId;
    final l$meta = meta;
    return Object.hashAll([
      _$data.containsKey('clientMutationId') ? l$clientMutationId : const {},
      l$meta,
    ]);
  }
}

abstract class CopyWith$Input$SetChapterMetaInput<TRes> {
  factory CopyWith$Input$SetChapterMetaInput(
    Input$SetChapterMetaInput instance,
    TRes Function(Input$SetChapterMetaInput) then,
  ) = _CopyWithImpl$Input$SetChapterMetaInput;

  factory CopyWith$Input$SetChapterMetaInput.stub(TRes res) =
      _CopyWithStubImpl$Input$SetChapterMetaInput;

  TRes call({
    String? clientMutationId,
    Input$ChapterMetaTypeInput? meta,
  });
  CopyWith$Input$ChapterMetaTypeInput<TRes> get meta;
}

class _CopyWithImpl$Input$SetChapterMetaInput<TRes>
    implements CopyWith$Input$SetChapterMetaInput<TRes> {
  _CopyWithImpl$Input$SetChapterMetaInput(
    this._instance,
    this._then,
  );

  final Input$SetChapterMetaInput _instance;

  final TRes Function(Input$SetChapterMetaInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? clientMutationId = _undefined,
    Object? meta = _undefined,
  }) =>
      _then(Input$SetChapterMetaInput._({
        ..._instance._$data,
        if (clientMutationId != _undefined)
          'clientMutationId': (clientMutationId as String?),
        if (meta != _undefined && meta != null)
          'meta': (meta as Input$ChapterMetaTypeInput),
      }));

  CopyWith$Input$ChapterMetaTypeInput<TRes> get meta {
    final local$meta = _instance.meta;
    return CopyWith$Input$ChapterMetaTypeInput(
        local$meta, (e) => call(meta: e));
  }
}

class _CopyWithStubImpl$Input$SetChapterMetaInput<TRes>
    implements CopyWith$Input$SetChapterMetaInput<TRes> {
  _CopyWithStubImpl$Input$SetChapterMetaInput(this._res);

  TRes _res;

  call({
    String? clientMutationId,
    Input$ChapterMetaTypeInput? meta,
  }) =>
      _res;

  CopyWith$Input$ChapterMetaTypeInput<TRes> get meta =>
      CopyWith$Input$ChapterMetaTypeInput.stub(_res);
}

class Input$SetGlobalMetaInput {
  factory Input$SetGlobalMetaInput({
    String? clientMutationId,
    required Input$GlobalMetaTypeInput meta,
  }) =>
      Input$SetGlobalMetaInput._({
        if (clientMutationId != null) r'clientMutationId': clientMutationId,
        r'meta': meta,
      });

  Input$SetGlobalMetaInput._(this._$data);

  factory Input$SetGlobalMetaInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('clientMutationId')) {
      final l$clientMutationId = data['clientMutationId'];
      result$data['clientMutationId'] = (l$clientMutationId as String?);
    }
    final l$meta = data['meta'];
    result$data['meta'] =
        Input$GlobalMetaTypeInput.fromJson((l$meta as Map<String, dynamic>));
    return Input$SetGlobalMetaInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get clientMutationId => (_$data['clientMutationId'] as String?);

  Input$GlobalMetaTypeInput get meta =>
      (_$data['meta'] as Input$GlobalMetaTypeInput);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('clientMutationId')) {
      final l$clientMutationId = clientMutationId;
      result$data['clientMutationId'] = l$clientMutationId;
    }
    final l$meta = meta;
    result$data['meta'] = l$meta.toJson();
    return result$data;
  }

  CopyWith$Input$SetGlobalMetaInput<Input$SetGlobalMetaInput> get copyWith =>
      CopyWith$Input$SetGlobalMetaInput(
        this,
        (i) => i,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$SetGlobalMetaInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (_$data.containsKey('clientMutationId') !=
        other._$data.containsKey('clientMutationId')) {
      return false;
    }
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    final l$meta = meta;
    final lOther$meta = other.meta;
    if (l$meta != lOther$meta) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$clientMutationId = clientMutationId;
    final l$meta = meta;
    return Object.hashAll([
      _$data.containsKey('clientMutationId') ? l$clientMutationId : const {},
      l$meta,
    ]);
  }
}

abstract class CopyWith$Input$SetGlobalMetaInput<TRes> {
  factory CopyWith$Input$SetGlobalMetaInput(
    Input$SetGlobalMetaInput instance,
    TRes Function(Input$SetGlobalMetaInput) then,
  ) = _CopyWithImpl$Input$SetGlobalMetaInput;

  factory CopyWith$Input$SetGlobalMetaInput.stub(TRes res) =
      _CopyWithStubImpl$Input$SetGlobalMetaInput;

  TRes call({
    String? clientMutationId,
    Input$GlobalMetaTypeInput? meta,
  });
  CopyWith$Input$GlobalMetaTypeInput<TRes> get meta;
}

class _CopyWithImpl$Input$SetGlobalMetaInput<TRes>
    implements CopyWith$Input$SetGlobalMetaInput<TRes> {
  _CopyWithImpl$Input$SetGlobalMetaInput(
    this._instance,
    this._then,
  );

  final Input$SetGlobalMetaInput _instance;

  final TRes Function(Input$SetGlobalMetaInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? clientMutationId = _undefined,
    Object? meta = _undefined,
  }) =>
      _then(Input$SetGlobalMetaInput._({
        ..._instance._$data,
        if (clientMutationId != _undefined)
          'clientMutationId': (clientMutationId as String?),
        if (meta != _undefined && meta != null)
          'meta': (meta as Input$GlobalMetaTypeInput),
      }));

  CopyWith$Input$GlobalMetaTypeInput<TRes> get meta {
    final local$meta = _instance.meta;
    return CopyWith$Input$GlobalMetaTypeInput(local$meta, (e) => call(meta: e));
  }
}

class _CopyWithStubImpl$Input$SetGlobalMetaInput<TRes>
    implements CopyWith$Input$SetGlobalMetaInput<TRes> {
  _CopyWithStubImpl$Input$SetGlobalMetaInput(this._res);

  TRes _res;

  call({
    String? clientMutationId,
    Input$GlobalMetaTypeInput? meta,
  }) =>
      _res;

  CopyWith$Input$GlobalMetaTypeInput<TRes> get meta =>
      CopyWith$Input$GlobalMetaTypeInput.stub(_res);
}

class Input$SetMangaMetaInput {
  factory Input$SetMangaMetaInput({
    String? clientMutationId,
    required Input$MangaMetaTypeInput meta,
  }) =>
      Input$SetMangaMetaInput._({
        if (clientMutationId != null) r'clientMutationId': clientMutationId,
        r'meta': meta,
      });

  Input$SetMangaMetaInput._(this._$data);

  factory Input$SetMangaMetaInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('clientMutationId')) {
      final l$clientMutationId = data['clientMutationId'];
      result$data['clientMutationId'] = (l$clientMutationId as String?);
    }
    final l$meta = data['meta'];
    result$data['meta'] =
        Input$MangaMetaTypeInput.fromJson((l$meta as Map<String, dynamic>));
    return Input$SetMangaMetaInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get clientMutationId => (_$data['clientMutationId'] as String?);

  Input$MangaMetaTypeInput get meta =>
      (_$data['meta'] as Input$MangaMetaTypeInput);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('clientMutationId')) {
      final l$clientMutationId = clientMutationId;
      result$data['clientMutationId'] = l$clientMutationId;
    }
    final l$meta = meta;
    result$data['meta'] = l$meta.toJson();
    return result$data;
  }

  CopyWith$Input$SetMangaMetaInput<Input$SetMangaMetaInput> get copyWith =>
      CopyWith$Input$SetMangaMetaInput(
        this,
        (i) => i,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$SetMangaMetaInput || runtimeType != other.runtimeType) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (_$data.containsKey('clientMutationId') !=
        other._$data.containsKey('clientMutationId')) {
      return false;
    }
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    final l$meta = meta;
    final lOther$meta = other.meta;
    if (l$meta != lOther$meta) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$clientMutationId = clientMutationId;
    final l$meta = meta;
    return Object.hashAll([
      _$data.containsKey('clientMutationId') ? l$clientMutationId : const {},
      l$meta,
    ]);
  }
}

abstract class CopyWith$Input$SetMangaMetaInput<TRes> {
  factory CopyWith$Input$SetMangaMetaInput(
    Input$SetMangaMetaInput instance,
    TRes Function(Input$SetMangaMetaInput) then,
  ) = _CopyWithImpl$Input$SetMangaMetaInput;

  factory CopyWith$Input$SetMangaMetaInput.stub(TRes res) =
      _CopyWithStubImpl$Input$SetMangaMetaInput;

  TRes call({
    String? clientMutationId,
    Input$MangaMetaTypeInput? meta,
  });
  CopyWith$Input$MangaMetaTypeInput<TRes> get meta;
}

class _CopyWithImpl$Input$SetMangaMetaInput<TRes>
    implements CopyWith$Input$SetMangaMetaInput<TRes> {
  _CopyWithImpl$Input$SetMangaMetaInput(
    this._instance,
    this._then,
  );

  final Input$SetMangaMetaInput _instance;

  final TRes Function(Input$SetMangaMetaInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? clientMutationId = _undefined,
    Object? meta = _undefined,
  }) =>
      _then(Input$SetMangaMetaInput._({
        ..._instance._$data,
        if (clientMutationId != _undefined)
          'clientMutationId': (clientMutationId as String?),
        if (meta != _undefined && meta != null)
          'meta': (meta as Input$MangaMetaTypeInput),
      }));

  CopyWith$Input$MangaMetaTypeInput<TRes> get meta {
    final local$meta = _instance.meta;
    return CopyWith$Input$MangaMetaTypeInput(local$meta, (e) => call(meta: e));
  }
}

class _CopyWithStubImpl$Input$SetMangaMetaInput<TRes>
    implements CopyWith$Input$SetMangaMetaInput<TRes> {
  _CopyWithStubImpl$Input$SetMangaMetaInput(this._res);

  TRes _res;

  call({
    String? clientMutationId,
    Input$MangaMetaTypeInput? meta,
  }) =>
      _res;

  CopyWith$Input$MangaMetaTypeInput<TRes> get meta =>
      CopyWith$Input$MangaMetaTypeInput.stub(_res);
}

class Input$SetSettingsInput {
  factory Input$SetSettingsInput({
    String? clientMutationId,
    required Input$PartialSettingsTypeInput settings,
  }) =>
      Input$SetSettingsInput._({
        if (clientMutationId != null) r'clientMutationId': clientMutationId,
        r'settings': settings,
      });

  Input$SetSettingsInput._(this._$data);

  factory Input$SetSettingsInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('clientMutationId')) {
      final l$clientMutationId = data['clientMutationId'];
      result$data['clientMutationId'] = (l$clientMutationId as String?);
    }
    final l$settings = data['settings'];
    result$data['settings'] = Input$PartialSettingsTypeInput.fromJson(
        (l$settings as Map<String, dynamic>));
    return Input$SetSettingsInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get clientMutationId => (_$data['clientMutationId'] as String?);

  Input$PartialSettingsTypeInput get settings =>
      (_$data['settings'] as Input$PartialSettingsTypeInput);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('clientMutationId')) {
      final l$clientMutationId = clientMutationId;
      result$data['clientMutationId'] = l$clientMutationId;
    }
    final l$settings = settings;
    result$data['settings'] = l$settings.toJson();
    return result$data;
  }

  CopyWith$Input$SetSettingsInput<Input$SetSettingsInput> get copyWith =>
      CopyWith$Input$SetSettingsInput(
        this,
        (i) => i,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$SetSettingsInput || runtimeType != other.runtimeType) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (_$data.containsKey('clientMutationId') !=
        other._$data.containsKey('clientMutationId')) {
      return false;
    }
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    final l$settings = settings;
    final lOther$settings = other.settings;
    if (l$settings != lOther$settings) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$clientMutationId = clientMutationId;
    final l$settings = settings;
    return Object.hashAll([
      _$data.containsKey('clientMutationId') ? l$clientMutationId : const {},
      l$settings,
    ]);
  }
}

abstract class CopyWith$Input$SetSettingsInput<TRes> {
  factory CopyWith$Input$SetSettingsInput(
    Input$SetSettingsInput instance,
    TRes Function(Input$SetSettingsInput) then,
  ) = _CopyWithImpl$Input$SetSettingsInput;

  factory CopyWith$Input$SetSettingsInput.stub(TRes res) =
      _CopyWithStubImpl$Input$SetSettingsInput;

  TRes call({
    String? clientMutationId,
    Input$PartialSettingsTypeInput? settings,
  });
  CopyWith$Input$PartialSettingsTypeInput<TRes> get settings;
}

class _CopyWithImpl$Input$SetSettingsInput<TRes>
    implements CopyWith$Input$SetSettingsInput<TRes> {
  _CopyWithImpl$Input$SetSettingsInput(
    this._instance,
    this._then,
  );

  final Input$SetSettingsInput _instance;

  final TRes Function(Input$SetSettingsInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? clientMutationId = _undefined,
    Object? settings = _undefined,
  }) =>
      _then(Input$SetSettingsInput._({
        ..._instance._$data,
        if (clientMutationId != _undefined)
          'clientMutationId': (clientMutationId as String?),
        if (settings != _undefined && settings != null)
          'settings': (settings as Input$PartialSettingsTypeInput),
      }));

  CopyWith$Input$PartialSettingsTypeInput<TRes> get settings {
    final local$settings = _instance.settings;
    return CopyWith$Input$PartialSettingsTypeInput(
        local$settings, (e) => call(settings: e));
  }
}

class _CopyWithStubImpl$Input$SetSettingsInput<TRes>
    implements CopyWith$Input$SetSettingsInput<TRes> {
  _CopyWithStubImpl$Input$SetSettingsInput(this._res);

  TRes _res;

  call({
    String? clientMutationId,
    Input$PartialSettingsTypeInput? settings,
  }) =>
      _res;

  CopyWith$Input$PartialSettingsTypeInput<TRes> get settings =>
      CopyWith$Input$PartialSettingsTypeInput.stub(_res);
}

class Input$SetSourceMetaInput {
  factory Input$SetSourceMetaInput({
    String? clientMutationId,
    required Input$SourceMetaTypeInput meta,
  }) =>
      Input$SetSourceMetaInput._({
        if (clientMutationId != null) r'clientMutationId': clientMutationId,
        r'meta': meta,
      });

  Input$SetSourceMetaInput._(this._$data);

  factory Input$SetSourceMetaInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('clientMutationId')) {
      final l$clientMutationId = data['clientMutationId'];
      result$data['clientMutationId'] = (l$clientMutationId as String?);
    }
    final l$meta = data['meta'];
    result$data['meta'] =
        Input$SourceMetaTypeInput.fromJson((l$meta as Map<String, dynamic>));
    return Input$SetSourceMetaInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get clientMutationId => (_$data['clientMutationId'] as String?);

  Input$SourceMetaTypeInput get meta =>
      (_$data['meta'] as Input$SourceMetaTypeInput);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('clientMutationId')) {
      final l$clientMutationId = clientMutationId;
      result$data['clientMutationId'] = l$clientMutationId;
    }
    final l$meta = meta;
    result$data['meta'] = l$meta.toJson();
    return result$data;
  }

  CopyWith$Input$SetSourceMetaInput<Input$SetSourceMetaInput> get copyWith =>
      CopyWith$Input$SetSourceMetaInput(
        this,
        (i) => i,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$SetSourceMetaInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (_$data.containsKey('clientMutationId') !=
        other._$data.containsKey('clientMutationId')) {
      return false;
    }
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    final l$meta = meta;
    final lOther$meta = other.meta;
    if (l$meta != lOther$meta) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$clientMutationId = clientMutationId;
    final l$meta = meta;
    return Object.hashAll([
      _$data.containsKey('clientMutationId') ? l$clientMutationId : const {},
      l$meta,
    ]);
  }
}

abstract class CopyWith$Input$SetSourceMetaInput<TRes> {
  factory CopyWith$Input$SetSourceMetaInput(
    Input$SetSourceMetaInput instance,
    TRes Function(Input$SetSourceMetaInput) then,
  ) = _CopyWithImpl$Input$SetSourceMetaInput;

  factory CopyWith$Input$SetSourceMetaInput.stub(TRes res) =
      _CopyWithStubImpl$Input$SetSourceMetaInput;

  TRes call({
    String? clientMutationId,
    Input$SourceMetaTypeInput? meta,
  });
  CopyWith$Input$SourceMetaTypeInput<TRes> get meta;
}

class _CopyWithImpl$Input$SetSourceMetaInput<TRes>
    implements CopyWith$Input$SetSourceMetaInput<TRes> {
  _CopyWithImpl$Input$SetSourceMetaInput(
    this._instance,
    this._then,
  );

  final Input$SetSourceMetaInput _instance;

  final TRes Function(Input$SetSourceMetaInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? clientMutationId = _undefined,
    Object? meta = _undefined,
  }) =>
      _then(Input$SetSourceMetaInput._({
        ..._instance._$data,
        if (clientMutationId != _undefined)
          'clientMutationId': (clientMutationId as String?),
        if (meta != _undefined && meta != null)
          'meta': (meta as Input$SourceMetaTypeInput),
      }));

  CopyWith$Input$SourceMetaTypeInput<TRes> get meta {
    final local$meta = _instance.meta;
    return CopyWith$Input$SourceMetaTypeInput(local$meta, (e) => call(meta: e));
  }
}

class _CopyWithStubImpl$Input$SetSourceMetaInput<TRes>
    implements CopyWith$Input$SetSourceMetaInput<TRes> {
  _CopyWithStubImpl$Input$SetSourceMetaInput(this._res);

  TRes _res;

  call({
    String? clientMutationId,
    Input$SourceMetaTypeInput? meta,
  }) =>
      _res;

  CopyWith$Input$SourceMetaTypeInput<TRes> get meta =>
      CopyWith$Input$SourceMetaTypeInput.stub(_res);
}

class Input$SortSelectionInput {
  factory Input$SortSelectionInput({
    required bool ascending,
    required int index,
  }) =>
      Input$SortSelectionInput._({
        r'ascending': ascending,
        r'index': index,
      });

  Input$SortSelectionInput._(this._$data);

  factory Input$SortSelectionInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$ascending = data['ascending'];
    result$data['ascending'] = (l$ascending as bool);
    final l$index = data['index'];
    result$data['index'] = (l$index as int);
    return Input$SortSelectionInput._(result$data);
  }

  Map<String, dynamic> _$data;

  bool get ascending => (_$data['ascending'] as bool);

  int get index => (_$data['index'] as int);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$ascending = ascending;
    result$data['ascending'] = l$ascending;
    final l$index = index;
    result$data['index'] = l$index;
    return result$data;
  }

  CopyWith$Input$SortSelectionInput<Input$SortSelectionInput> get copyWith =>
      CopyWith$Input$SortSelectionInput(
        this,
        (i) => i,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$SortSelectionInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$ascending = ascending;
    final lOther$ascending = other.ascending;
    if (l$ascending != lOther$ascending) {
      return false;
    }
    final l$index = index;
    final lOther$index = other.index;
    if (l$index != lOther$index) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$ascending = ascending;
    final l$index = index;
    return Object.hashAll([
      l$ascending,
      l$index,
    ]);
  }
}

abstract class CopyWith$Input$SortSelectionInput<TRes> {
  factory CopyWith$Input$SortSelectionInput(
    Input$SortSelectionInput instance,
    TRes Function(Input$SortSelectionInput) then,
  ) = _CopyWithImpl$Input$SortSelectionInput;

  factory CopyWith$Input$SortSelectionInput.stub(TRes res) =
      _CopyWithStubImpl$Input$SortSelectionInput;

  TRes call({
    bool? ascending,
    int? index,
  });
}

class _CopyWithImpl$Input$SortSelectionInput<TRes>
    implements CopyWith$Input$SortSelectionInput<TRes> {
  _CopyWithImpl$Input$SortSelectionInput(
    this._instance,
    this._then,
  );

  final Input$SortSelectionInput _instance;

  final TRes Function(Input$SortSelectionInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? ascending = _undefined,
    Object? index = _undefined,
  }) =>
      _then(Input$SortSelectionInput._({
        ..._instance._$data,
        if (ascending != _undefined && ascending != null)
          'ascending': (ascending as bool),
        if (index != _undefined && index != null) 'index': (index as int),
      }));
}

class _CopyWithStubImpl$Input$SortSelectionInput<TRes>
    implements CopyWith$Input$SortSelectionInput<TRes> {
  _CopyWithStubImpl$Input$SortSelectionInput(this._res);

  TRes _res;

  call({
    bool? ascending,
    int? index,
  }) =>
      _res;
}

class Input$SourceConditionInput {
  factory Input$SourceConditionInput({
    String? id,
    bool? isNsfw,
    String? lang,
    String? name,
  }) =>
      Input$SourceConditionInput._({
        if (id != null) r'id': id,
        if (isNsfw != null) r'isNsfw': isNsfw,
        if (lang != null) r'lang': lang,
        if (name != null) r'name': name,
      });

  Input$SourceConditionInput._(this._$data);

  factory Input$SourceConditionInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('id')) {
      final l$id = data['id'];
      result$data['id'] = l$id == null ? null : longStringFromJson(l$id);
    }
    if (data.containsKey('isNsfw')) {
      final l$isNsfw = data['isNsfw'];
      result$data['isNsfw'] = (l$isNsfw as bool?);
    }
    if (data.containsKey('lang')) {
      final l$lang = data['lang'];
      result$data['lang'] = (l$lang as String?);
    }
    if (data.containsKey('name')) {
      final l$name = data['name'];
      result$data['name'] = (l$name as String?);
    }
    return Input$SourceConditionInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get id => (_$data['id'] as String?);

  bool? get isNsfw => (_$data['isNsfw'] as bool?);

  String? get lang => (_$data['lang'] as String?);

  String? get name => (_$data['name'] as String?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('id')) {
      final l$id = id;
      result$data['id'] = l$id == null ? null : longStringToJson(l$id);
    }
    if (_$data.containsKey('isNsfw')) {
      final l$isNsfw = isNsfw;
      result$data['isNsfw'] = l$isNsfw;
    }
    if (_$data.containsKey('lang')) {
      final l$lang = lang;
      result$data['lang'] = l$lang;
    }
    if (_$data.containsKey('name')) {
      final l$name = name;
      result$data['name'] = l$name;
    }
    return result$data;
  }

  CopyWith$Input$SourceConditionInput<Input$SourceConditionInput>
      get copyWith => CopyWith$Input$SourceConditionInput(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$SourceConditionInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (_$data.containsKey('id') != other._$data.containsKey('id')) {
      return false;
    }
    if (l$id != lOther$id) {
      return false;
    }
    final l$isNsfw = isNsfw;
    final lOther$isNsfw = other.isNsfw;
    if (_$data.containsKey('isNsfw') != other._$data.containsKey('isNsfw')) {
      return false;
    }
    if (l$isNsfw != lOther$isNsfw) {
      return false;
    }
    final l$lang = lang;
    final lOther$lang = other.lang;
    if (_$data.containsKey('lang') != other._$data.containsKey('lang')) {
      return false;
    }
    if (l$lang != lOther$lang) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (_$data.containsKey('name') != other._$data.containsKey('name')) {
      return false;
    }
    if (l$name != lOther$name) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$isNsfw = isNsfw;
    final l$lang = lang;
    final l$name = name;
    return Object.hashAll([
      _$data.containsKey('id') ? l$id : const {},
      _$data.containsKey('isNsfw') ? l$isNsfw : const {},
      _$data.containsKey('lang') ? l$lang : const {},
      _$data.containsKey('name') ? l$name : const {},
    ]);
  }
}

abstract class CopyWith$Input$SourceConditionInput<TRes> {
  factory CopyWith$Input$SourceConditionInput(
    Input$SourceConditionInput instance,
    TRes Function(Input$SourceConditionInput) then,
  ) = _CopyWithImpl$Input$SourceConditionInput;

  factory CopyWith$Input$SourceConditionInput.stub(TRes res) =
      _CopyWithStubImpl$Input$SourceConditionInput;

  TRes call({
    String? id,
    bool? isNsfw,
    String? lang,
    String? name,
  });
}

class _CopyWithImpl$Input$SourceConditionInput<TRes>
    implements CopyWith$Input$SourceConditionInput<TRes> {
  _CopyWithImpl$Input$SourceConditionInput(
    this._instance,
    this._then,
  );

  final Input$SourceConditionInput _instance;

  final TRes Function(Input$SourceConditionInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? isNsfw = _undefined,
    Object? lang = _undefined,
    Object? name = _undefined,
  }) =>
      _then(Input$SourceConditionInput._({
        ..._instance._$data,
        if (id != _undefined) 'id': (id as String?),
        if (isNsfw != _undefined) 'isNsfw': (isNsfw as bool?),
        if (lang != _undefined) 'lang': (lang as String?),
        if (name != _undefined) 'name': (name as String?),
      }));
}

class _CopyWithStubImpl$Input$SourceConditionInput<TRes>
    implements CopyWith$Input$SourceConditionInput<TRes> {
  _CopyWithStubImpl$Input$SourceConditionInput(this._res);

  TRes _res;

  call({
    String? id,
    bool? isNsfw,
    String? lang,
    String? name,
  }) =>
      _res;
}

class Input$SourceFilterInput {
  factory Input$SourceFilterInput({
    List<Input$SourceFilterInput>? and,
    Input$LongFilterInput? id,
    Input$BooleanFilterInput? isNsfw,
    Input$StringFilterInput? lang,
    Input$StringFilterInput? name,
    Input$SourceFilterInput? not,
    List<Input$SourceFilterInput>? or,
  }) =>
      Input$SourceFilterInput._({
        if (and != null) r'and': and,
        if (id != null) r'id': id,
        if (isNsfw != null) r'isNsfw': isNsfw,
        if (lang != null) r'lang': lang,
        if (name != null) r'name': name,
        if (not != null) r'not': not,
        if (or != null) r'or': or,
      });

  Input$SourceFilterInput._(this._$data);

  factory Input$SourceFilterInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('and')) {
      final l$and = data['and'];
      result$data['and'] = (l$and as List<dynamic>?)
          ?.map((e) =>
              Input$SourceFilterInput.fromJson((e as Map<String, dynamic>)))
          .toList();
    }
    if (data.containsKey('id')) {
      final l$id = data['id'];
      result$data['id'] = l$id == null
          ? null
          : Input$LongFilterInput.fromJson((l$id as Map<String, dynamic>));
    }
    if (data.containsKey('isNsfw')) {
      final l$isNsfw = data['isNsfw'];
      result$data['isNsfw'] = l$isNsfw == null
          ? null
          : Input$BooleanFilterInput.fromJson(
              (l$isNsfw as Map<String, dynamic>));
    }
    if (data.containsKey('lang')) {
      final l$lang = data['lang'];
      result$data['lang'] = l$lang == null
          ? null
          : Input$StringFilterInput.fromJson((l$lang as Map<String, dynamic>));
    }
    if (data.containsKey('name')) {
      final l$name = data['name'];
      result$data['name'] = l$name == null
          ? null
          : Input$StringFilterInput.fromJson((l$name as Map<String, dynamic>));
    }
    if (data.containsKey('not')) {
      final l$not = data['not'];
      result$data['not'] = l$not == null
          ? null
          : Input$SourceFilterInput.fromJson((l$not as Map<String, dynamic>));
    }
    if (data.containsKey('or')) {
      final l$or = data['or'];
      result$data['or'] = (l$or as List<dynamic>?)
          ?.map((e) =>
              Input$SourceFilterInput.fromJson((e as Map<String, dynamic>)))
          .toList();
    }
    return Input$SourceFilterInput._(result$data);
  }

  Map<String, dynamic> _$data;

  List<Input$SourceFilterInput>? get and =>
      (_$data['and'] as List<Input$SourceFilterInput>?);

  Input$LongFilterInput? get id => (_$data['id'] as Input$LongFilterInput?);

  Input$BooleanFilterInput? get isNsfw =>
      (_$data['isNsfw'] as Input$BooleanFilterInput?);

  Input$StringFilterInput? get lang =>
      (_$data['lang'] as Input$StringFilterInput?);

  Input$StringFilterInput? get name =>
      (_$data['name'] as Input$StringFilterInput?);

  Input$SourceFilterInput? get not =>
      (_$data['not'] as Input$SourceFilterInput?);

  List<Input$SourceFilterInput>? get or =>
      (_$data['or'] as List<Input$SourceFilterInput>?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('and')) {
      final l$and = and;
      result$data['and'] = l$and?.map((e) => e.toJson()).toList();
    }
    if (_$data.containsKey('id')) {
      final l$id = id;
      result$data['id'] = l$id?.toJson();
    }
    if (_$data.containsKey('isNsfw')) {
      final l$isNsfw = isNsfw;
      result$data['isNsfw'] = l$isNsfw?.toJson();
    }
    if (_$data.containsKey('lang')) {
      final l$lang = lang;
      result$data['lang'] = l$lang?.toJson();
    }
    if (_$data.containsKey('name')) {
      final l$name = name;
      result$data['name'] = l$name?.toJson();
    }
    if (_$data.containsKey('not')) {
      final l$not = not;
      result$data['not'] = l$not?.toJson();
    }
    if (_$data.containsKey('or')) {
      final l$or = or;
      result$data['or'] = l$or?.map((e) => e.toJson()).toList();
    }
    return result$data;
  }

  CopyWith$Input$SourceFilterInput<Input$SourceFilterInput> get copyWith =>
      CopyWith$Input$SourceFilterInput(
        this,
        (i) => i,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$SourceFilterInput || runtimeType != other.runtimeType) {
      return false;
    }
    final l$and = and;
    final lOther$and = other.and;
    if (_$data.containsKey('and') != other._$data.containsKey('and')) {
      return false;
    }
    if (l$and != null && lOther$and != null) {
      if (l$and.length != lOther$and.length) {
        return false;
      }
      for (int i = 0; i < l$and.length; i++) {
        final l$and$entry = l$and[i];
        final lOther$and$entry = lOther$and[i];
        if (l$and$entry != lOther$and$entry) {
          return false;
        }
      }
    } else if (l$and != lOther$and) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (_$data.containsKey('id') != other._$data.containsKey('id')) {
      return false;
    }
    if (l$id != lOther$id) {
      return false;
    }
    final l$isNsfw = isNsfw;
    final lOther$isNsfw = other.isNsfw;
    if (_$data.containsKey('isNsfw') != other._$data.containsKey('isNsfw')) {
      return false;
    }
    if (l$isNsfw != lOther$isNsfw) {
      return false;
    }
    final l$lang = lang;
    final lOther$lang = other.lang;
    if (_$data.containsKey('lang') != other._$data.containsKey('lang')) {
      return false;
    }
    if (l$lang != lOther$lang) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (_$data.containsKey('name') != other._$data.containsKey('name')) {
      return false;
    }
    if (l$name != lOther$name) {
      return false;
    }
    final l$not = not;
    final lOther$not = other.not;
    if (_$data.containsKey('not') != other._$data.containsKey('not')) {
      return false;
    }
    if (l$not != lOther$not) {
      return false;
    }
    final l$or = or;
    final lOther$or = other.or;
    if (_$data.containsKey('or') != other._$data.containsKey('or')) {
      return false;
    }
    if (l$or != null && lOther$or != null) {
      if (l$or.length != lOther$or.length) {
        return false;
      }
      for (int i = 0; i < l$or.length; i++) {
        final l$or$entry = l$or[i];
        final lOther$or$entry = lOther$or[i];
        if (l$or$entry != lOther$or$entry) {
          return false;
        }
      }
    } else if (l$or != lOther$or) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$and = and;
    final l$id = id;
    final l$isNsfw = isNsfw;
    final l$lang = lang;
    final l$name = name;
    final l$not = not;
    final l$or = or;
    return Object.hashAll([
      _$data.containsKey('and')
          ? l$and == null
              ? null
              : Object.hashAll(l$and.map((v) => v))
          : const {},
      _$data.containsKey('id') ? l$id : const {},
      _$data.containsKey('isNsfw') ? l$isNsfw : const {},
      _$data.containsKey('lang') ? l$lang : const {},
      _$data.containsKey('name') ? l$name : const {},
      _$data.containsKey('not') ? l$not : const {},
      _$data.containsKey('or')
          ? l$or == null
              ? null
              : Object.hashAll(l$or.map((v) => v))
          : const {},
    ]);
  }
}

abstract class CopyWith$Input$SourceFilterInput<TRes> {
  factory CopyWith$Input$SourceFilterInput(
    Input$SourceFilterInput instance,
    TRes Function(Input$SourceFilterInput) then,
  ) = _CopyWithImpl$Input$SourceFilterInput;

  factory CopyWith$Input$SourceFilterInput.stub(TRes res) =
      _CopyWithStubImpl$Input$SourceFilterInput;

  TRes call({
    List<Input$SourceFilterInput>? and,
    Input$LongFilterInput? id,
    Input$BooleanFilterInput? isNsfw,
    Input$StringFilterInput? lang,
    Input$StringFilterInput? name,
    Input$SourceFilterInput? not,
    List<Input$SourceFilterInput>? or,
  });
  TRes and(
      Iterable<Input$SourceFilterInput>? Function(
              Iterable<
                  CopyWith$Input$SourceFilterInput<Input$SourceFilterInput>>?)
          _fn);
  CopyWith$Input$LongFilterInput<TRes> get id;
  CopyWith$Input$BooleanFilterInput<TRes> get isNsfw;
  CopyWith$Input$StringFilterInput<TRes> get lang;
  CopyWith$Input$StringFilterInput<TRes> get name;
  CopyWith$Input$SourceFilterInput<TRes> get not;
  TRes or(
      Iterable<Input$SourceFilterInput>? Function(
              Iterable<
                  CopyWith$Input$SourceFilterInput<Input$SourceFilterInput>>?)
          _fn);
}

class _CopyWithImpl$Input$SourceFilterInput<TRes>
    implements CopyWith$Input$SourceFilterInput<TRes> {
  _CopyWithImpl$Input$SourceFilterInput(
    this._instance,
    this._then,
  );

  final Input$SourceFilterInput _instance;

  final TRes Function(Input$SourceFilterInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? and = _undefined,
    Object? id = _undefined,
    Object? isNsfw = _undefined,
    Object? lang = _undefined,
    Object? name = _undefined,
    Object? not = _undefined,
    Object? or = _undefined,
  }) =>
      _then(Input$SourceFilterInput._({
        ..._instance._$data,
        if (and != _undefined) 'and': (and as List<Input$SourceFilterInput>?),
        if (id != _undefined) 'id': (id as Input$LongFilterInput?),
        if (isNsfw != _undefined)
          'isNsfw': (isNsfw as Input$BooleanFilterInput?),
        if (lang != _undefined) 'lang': (lang as Input$StringFilterInput?),
        if (name != _undefined) 'name': (name as Input$StringFilterInput?),
        if (not != _undefined) 'not': (not as Input$SourceFilterInput?),
        if (or != _undefined) 'or': (or as List<Input$SourceFilterInput>?),
      }));

  TRes and(
          Iterable<Input$SourceFilterInput>? Function(
                  Iterable<
                      CopyWith$Input$SourceFilterInput<
                          Input$SourceFilterInput>>?)
              _fn) =>
      call(
          and: _fn(_instance.and?.map((e) => CopyWith$Input$SourceFilterInput(
                e,
                (i) => i,
              )))?.toList());

  CopyWith$Input$LongFilterInput<TRes> get id {
    final local$id = _instance.id;
    return local$id == null
        ? CopyWith$Input$LongFilterInput.stub(_then(_instance))
        : CopyWith$Input$LongFilterInput(local$id, (e) => call(id: e));
  }

  CopyWith$Input$BooleanFilterInput<TRes> get isNsfw {
    final local$isNsfw = _instance.isNsfw;
    return local$isNsfw == null
        ? CopyWith$Input$BooleanFilterInput.stub(_then(_instance))
        : CopyWith$Input$BooleanFilterInput(
            local$isNsfw, (e) => call(isNsfw: e));
  }

  CopyWith$Input$StringFilterInput<TRes> get lang {
    final local$lang = _instance.lang;
    return local$lang == null
        ? CopyWith$Input$StringFilterInput.stub(_then(_instance))
        : CopyWith$Input$StringFilterInput(local$lang, (e) => call(lang: e));
  }

  CopyWith$Input$StringFilterInput<TRes> get name {
    final local$name = _instance.name;
    return local$name == null
        ? CopyWith$Input$StringFilterInput.stub(_then(_instance))
        : CopyWith$Input$StringFilterInput(local$name, (e) => call(name: e));
  }

  CopyWith$Input$SourceFilterInput<TRes> get not {
    final local$not = _instance.not;
    return local$not == null
        ? CopyWith$Input$SourceFilterInput.stub(_then(_instance))
        : CopyWith$Input$SourceFilterInput(local$not, (e) => call(not: e));
  }

  TRes or(
          Iterable<Input$SourceFilterInput>? Function(
                  Iterable<
                      CopyWith$Input$SourceFilterInput<
                          Input$SourceFilterInput>>?)
              _fn) =>
      call(
          or: _fn(_instance.or?.map((e) => CopyWith$Input$SourceFilterInput(
                e,
                (i) => i,
              )))?.toList());
}

class _CopyWithStubImpl$Input$SourceFilterInput<TRes>
    implements CopyWith$Input$SourceFilterInput<TRes> {
  _CopyWithStubImpl$Input$SourceFilterInput(this._res);

  TRes _res;

  call({
    List<Input$SourceFilterInput>? and,
    Input$LongFilterInput? id,
    Input$BooleanFilterInput? isNsfw,
    Input$StringFilterInput? lang,
    Input$StringFilterInput? name,
    Input$SourceFilterInput? not,
    List<Input$SourceFilterInput>? or,
  }) =>
      _res;

  and(_fn) => _res;

  CopyWith$Input$LongFilterInput<TRes> get id =>
      CopyWith$Input$LongFilterInput.stub(_res);

  CopyWith$Input$BooleanFilterInput<TRes> get isNsfw =>
      CopyWith$Input$BooleanFilterInput.stub(_res);

  CopyWith$Input$StringFilterInput<TRes> get lang =>
      CopyWith$Input$StringFilterInput.stub(_res);

  CopyWith$Input$StringFilterInput<TRes> get name =>
      CopyWith$Input$StringFilterInput.stub(_res);

  CopyWith$Input$SourceFilterInput<TRes> get not =>
      CopyWith$Input$SourceFilterInput.stub(_res);

  or(_fn) => _res;
}

class Input$SourceMetaTypeInput {
  factory Input$SourceMetaTypeInput({
    required String key,
    required String sourceId,
    required String value,
  }) =>
      Input$SourceMetaTypeInput._({
        r'key': key,
        r'sourceId': sourceId,
        r'value': value,
      });

  Input$SourceMetaTypeInput._(this._$data);

  factory Input$SourceMetaTypeInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$key = data['key'];
    result$data['key'] = (l$key as String);
    final l$sourceId = data['sourceId'];
    result$data['sourceId'] = longStringFromJson(l$sourceId);
    final l$value = data['value'];
    result$data['value'] = (l$value as String);
    return Input$SourceMetaTypeInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String get key => (_$data['key'] as String);

  String get sourceId => (_$data['sourceId'] as String);

  String get value => (_$data['value'] as String);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$key = key;
    result$data['key'] = l$key;
    final l$sourceId = sourceId;
    result$data['sourceId'] = longStringToJson(l$sourceId);
    final l$value = value;
    result$data['value'] = l$value;
    return result$data;
  }

  CopyWith$Input$SourceMetaTypeInput<Input$SourceMetaTypeInput> get copyWith =>
      CopyWith$Input$SourceMetaTypeInput(
        this,
        (i) => i,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$SourceMetaTypeInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$key = key;
    final lOther$key = other.key;
    if (l$key != lOther$key) {
      return false;
    }
    final l$sourceId = sourceId;
    final lOther$sourceId = other.sourceId;
    if (l$sourceId != lOther$sourceId) {
      return false;
    }
    final l$value = value;
    final lOther$value = other.value;
    if (l$value != lOther$value) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$key = key;
    final l$sourceId = sourceId;
    final l$value = value;
    return Object.hashAll([
      l$key,
      l$sourceId,
      l$value,
    ]);
  }
}

abstract class CopyWith$Input$SourceMetaTypeInput<TRes> {
  factory CopyWith$Input$SourceMetaTypeInput(
    Input$SourceMetaTypeInput instance,
    TRes Function(Input$SourceMetaTypeInput) then,
  ) = _CopyWithImpl$Input$SourceMetaTypeInput;

  factory CopyWith$Input$SourceMetaTypeInput.stub(TRes res) =
      _CopyWithStubImpl$Input$SourceMetaTypeInput;

  TRes call({
    String? key,
    String? sourceId,
    String? value,
  });
}

class _CopyWithImpl$Input$SourceMetaTypeInput<TRes>
    implements CopyWith$Input$SourceMetaTypeInput<TRes> {
  _CopyWithImpl$Input$SourceMetaTypeInput(
    this._instance,
    this._then,
  );

  final Input$SourceMetaTypeInput _instance;

  final TRes Function(Input$SourceMetaTypeInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? key = _undefined,
    Object? sourceId = _undefined,
    Object? value = _undefined,
  }) =>
      _then(Input$SourceMetaTypeInput._({
        ..._instance._$data,
        if (key != _undefined && key != null) 'key': (key as String),
        if (sourceId != _undefined && sourceId != null)
          'sourceId': (sourceId as String),
        if (value != _undefined && value != null) 'value': (value as String),
      }));
}

class _CopyWithStubImpl$Input$SourceMetaTypeInput<TRes>
    implements CopyWith$Input$SourceMetaTypeInput<TRes> {
  _CopyWithStubImpl$Input$SourceMetaTypeInput(this._res);

  TRes _res;

  call({
    String? key,
    String? sourceId,
    String? value,
  }) =>
      _res;
}

class Input$SourceOrderInput {
  factory Input$SourceOrderInput({
    required Enum$SourceOrderBy by,
    Enum$SortOrder? byType,
  }) =>
      Input$SourceOrderInput._({
        r'by': by,
        if (byType != null) r'byType': byType,
      });

  Input$SourceOrderInput._(this._$data);

  factory Input$SourceOrderInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$by = data['by'];
    result$data['by'] = fromJson$Enum$SourceOrderBy((l$by as String));
    if (data.containsKey('byType')) {
      final l$byType = data['byType'];
      result$data['byType'] = l$byType == null
          ? null
          : fromJson$Enum$SortOrder((l$byType as String));
    }
    return Input$SourceOrderInput._(result$data);
  }

  Map<String, dynamic> _$data;

  Enum$SourceOrderBy get by => (_$data['by'] as Enum$SourceOrderBy);

  Enum$SortOrder? get byType => (_$data['byType'] as Enum$SortOrder?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$by = by;
    result$data['by'] = toJson$Enum$SourceOrderBy(l$by);
    if (_$data.containsKey('byType')) {
      final l$byType = byType;
      result$data['byType'] =
          l$byType == null ? null : toJson$Enum$SortOrder(l$byType);
    }
    return result$data;
  }

  CopyWith$Input$SourceOrderInput<Input$SourceOrderInput> get copyWith =>
      CopyWith$Input$SourceOrderInput(
        this,
        (i) => i,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$SourceOrderInput || runtimeType != other.runtimeType) {
      return false;
    }
    final l$by = by;
    final lOther$by = other.by;
    if (l$by != lOther$by) {
      return false;
    }
    final l$byType = byType;
    final lOther$byType = other.byType;
    if (_$data.containsKey('byType') != other._$data.containsKey('byType')) {
      return false;
    }
    if (l$byType != lOther$byType) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$by = by;
    final l$byType = byType;
    return Object.hashAll([
      l$by,
      _$data.containsKey('byType') ? l$byType : const {},
    ]);
  }
}

abstract class CopyWith$Input$SourceOrderInput<TRes> {
  factory CopyWith$Input$SourceOrderInput(
    Input$SourceOrderInput instance,
    TRes Function(Input$SourceOrderInput) then,
  ) = _CopyWithImpl$Input$SourceOrderInput;

  factory CopyWith$Input$SourceOrderInput.stub(TRes res) =
      _CopyWithStubImpl$Input$SourceOrderInput;

  TRes call({
    Enum$SourceOrderBy? by,
    Enum$SortOrder? byType,
  });
}

class _CopyWithImpl$Input$SourceOrderInput<TRes>
    implements CopyWith$Input$SourceOrderInput<TRes> {
  _CopyWithImpl$Input$SourceOrderInput(
    this._instance,
    this._then,
  );

  final Input$SourceOrderInput _instance;

  final TRes Function(Input$SourceOrderInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? by = _undefined,
    Object? byType = _undefined,
  }) =>
      _then(Input$SourceOrderInput._({
        ..._instance._$data,
        if (by != _undefined && by != null) 'by': (by as Enum$SourceOrderBy),
        if (byType != _undefined) 'byType': (byType as Enum$SortOrder?),
      }));
}

class _CopyWithStubImpl$Input$SourceOrderInput<TRes>
    implements CopyWith$Input$SourceOrderInput<TRes> {
  _CopyWithStubImpl$Input$SourceOrderInput(this._res);

  TRes _res;

  call({
    Enum$SourceOrderBy? by,
    Enum$SortOrder? byType,
  }) =>
      _res;
}

class Input$SourcePreferenceChangeInput {
  factory Input$SourcePreferenceChangeInput({
    bool? checkBoxState,
    String? editTextState,
    String? listState,
    List<String>? multiSelectState,
    required int position,
    bool? switchState,
  }) =>
      Input$SourcePreferenceChangeInput._({
        if (checkBoxState != null) r'checkBoxState': checkBoxState,
        if (editTextState != null) r'editTextState': editTextState,
        if (listState != null) r'listState': listState,
        if (multiSelectState != null) r'multiSelectState': multiSelectState,
        r'position': position,
        if (switchState != null) r'switchState': switchState,
      });

  Input$SourcePreferenceChangeInput._(this._$data);

  factory Input$SourcePreferenceChangeInput.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('checkBoxState')) {
      final l$checkBoxState = data['checkBoxState'];
      result$data['checkBoxState'] = (l$checkBoxState as bool?);
    }
    if (data.containsKey('editTextState')) {
      final l$editTextState = data['editTextState'];
      result$data['editTextState'] = (l$editTextState as String?);
    }
    if (data.containsKey('listState')) {
      final l$listState = data['listState'];
      result$data['listState'] = (l$listState as String?);
    }
    if (data.containsKey('multiSelectState')) {
      final l$multiSelectState = data['multiSelectState'];
      result$data['multiSelectState'] = (l$multiSelectState as List<dynamic>?)
          ?.map((e) => (e as String))
          .toList();
    }
    final l$position = data['position'];
    result$data['position'] = (l$position as int);
    if (data.containsKey('switchState')) {
      final l$switchState = data['switchState'];
      result$data['switchState'] = (l$switchState as bool?);
    }
    return Input$SourcePreferenceChangeInput._(result$data);
  }

  Map<String, dynamic> _$data;

  bool? get checkBoxState => (_$data['checkBoxState'] as bool?);

  String? get editTextState => (_$data['editTextState'] as String?);

  String? get listState => (_$data['listState'] as String?);

  List<String>? get multiSelectState =>
      (_$data['multiSelectState'] as List<String>?);

  int get position => (_$data['position'] as int);

  bool? get switchState => (_$data['switchState'] as bool?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('checkBoxState')) {
      final l$checkBoxState = checkBoxState;
      result$data['checkBoxState'] = l$checkBoxState;
    }
    if (_$data.containsKey('editTextState')) {
      final l$editTextState = editTextState;
      result$data['editTextState'] = l$editTextState;
    }
    if (_$data.containsKey('listState')) {
      final l$listState = listState;
      result$data['listState'] = l$listState;
    }
    if (_$data.containsKey('multiSelectState')) {
      final l$multiSelectState = multiSelectState;
      result$data['multiSelectState'] =
          l$multiSelectState?.map((e) => e).toList();
    }
    final l$position = position;
    result$data['position'] = l$position;
    if (_$data.containsKey('switchState')) {
      final l$switchState = switchState;
      result$data['switchState'] = l$switchState;
    }
    return result$data;
  }

  CopyWith$Input$SourcePreferenceChangeInput<Input$SourcePreferenceChangeInput>
      get copyWith => CopyWith$Input$SourcePreferenceChangeInput(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$SourcePreferenceChangeInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$checkBoxState = checkBoxState;
    final lOther$checkBoxState = other.checkBoxState;
    if (_$data.containsKey('checkBoxState') !=
        other._$data.containsKey('checkBoxState')) {
      return false;
    }
    if (l$checkBoxState != lOther$checkBoxState) {
      return false;
    }
    final l$editTextState = editTextState;
    final lOther$editTextState = other.editTextState;
    if (_$data.containsKey('editTextState') !=
        other._$data.containsKey('editTextState')) {
      return false;
    }
    if (l$editTextState != lOther$editTextState) {
      return false;
    }
    final l$listState = listState;
    final lOther$listState = other.listState;
    if (_$data.containsKey('listState') !=
        other._$data.containsKey('listState')) {
      return false;
    }
    if (l$listState != lOther$listState) {
      return false;
    }
    final l$multiSelectState = multiSelectState;
    final lOther$multiSelectState = other.multiSelectState;
    if (_$data.containsKey('multiSelectState') !=
        other._$data.containsKey('multiSelectState')) {
      return false;
    }
    if (l$multiSelectState != null && lOther$multiSelectState != null) {
      if (l$multiSelectState.length != lOther$multiSelectState.length) {
        return false;
      }
      for (int i = 0; i < l$multiSelectState.length; i++) {
        final l$multiSelectState$entry = l$multiSelectState[i];
        final lOther$multiSelectState$entry = lOther$multiSelectState[i];
        if (l$multiSelectState$entry != lOther$multiSelectState$entry) {
          return false;
        }
      }
    } else if (l$multiSelectState != lOther$multiSelectState) {
      return false;
    }
    final l$position = position;
    final lOther$position = other.position;
    if (l$position != lOther$position) {
      return false;
    }
    final l$switchState = switchState;
    final lOther$switchState = other.switchState;
    if (_$data.containsKey('switchState') !=
        other._$data.containsKey('switchState')) {
      return false;
    }
    if (l$switchState != lOther$switchState) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$checkBoxState = checkBoxState;
    final l$editTextState = editTextState;
    final l$listState = listState;
    final l$multiSelectState = multiSelectState;
    final l$position = position;
    final l$switchState = switchState;
    return Object.hashAll([
      _$data.containsKey('checkBoxState') ? l$checkBoxState : const {},
      _$data.containsKey('editTextState') ? l$editTextState : const {},
      _$data.containsKey('listState') ? l$listState : const {},
      _$data.containsKey('multiSelectState')
          ? l$multiSelectState == null
              ? null
              : Object.hashAll(l$multiSelectState.map((v) => v))
          : const {},
      l$position,
      _$data.containsKey('switchState') ? l$switchState : const {},
    ]);
  }
}

abstract class CopyWith$Input$SourcePreferenceChangeInput<TRes> {
  factory CopyWith$Input$SourcePreferenceChangeInput(
    Input$SourcePreferenceChangeInput instance,
    TRes Function(Input$SourcePreferenceChangeInput) then,
  ) = _CopyWithImpl$Input$SourcePreferenceChangeInput;

  factory CopyWith$Input$SourcePreferenceChangeInput.stub(TRes res) =
      _CopyWithStubImpl$Input$SourcePreferenceChangeInput;

  TRes call({
    bool? checkBoxState,
    String? editTextState,
    String? listState,
    List<String>? multiSelectState,
    int? position,
    bool? switchState,
  });
}

class _CopyWithImpl$Input$SourcePreferenceChangeInput<TRes>
    implements CopyWith$Input$SourcePreferenceChangeInput<TRes> {
  _CopyWithImpl$Input$SourcePreferenceChangeInput(
    this._instance,
    this._then,
  );

  final Input$SourcePreferenceChangeInput _instance;

  final TRes Function(Input$SourcePreferenceChangeInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? checkBoxState = _undefined,
    Object? editTextState = _undefined,
    Object? listState = _undefined,
    Object? multiSelectState = _undefined,
    Object? position = _undefined,
    Object? switchState = _undefined,
  }) =>
      _then(Input$SourcePreferenceChangeInput._({
        ..._instance._$data,
        if (checkBoxState != _undefined)
          'checkBoxState': (checkBoxState as bool?),
        if (editTextState != _undefined)
          'editTextState': (editTextState as String?),
        if (listState != _undefined) 'listState': (listState as String?),
        if (multiSelectState != _undefined)
          'multiSelectState': (multiSelectState as List<String>?),
        if (position != _undefined && position != null)
          'position': (position as int),
        if (switchState != _undefined) 'switchState': (switchState as bool?),
      }));
}

class _CopyWithStubImpl$Input$SourcePreferenceChangeInput<TRes>
    implements CopyWith$Input$SourcePreferenceChangeInput<TRes> {
  _CopyWithStubImpl$Input$SourcePreferenceChangeInput(this._res);

  TRes _res;

  call({
    bool? checkBoxState,
    String? editTextState,
    String? listState,
    List<String>? multiSelectState,
    int? position,
    bool? switchState,
  }) =>
      _res;
}

class Input$StartDownloaderInput {
  factory Input$StartDownloaderInput({String? clientMutationId}) =>
      Input$StartDownloaderInput._({
        if (clientMutationId != null) r'clientMutationId': clientMutationId,
      });

  Input$StartDownloaderInput._(this._$data);

  factory Input$StartDownloaderInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('clientMutationId')) {
      final l$clientMutationId = data['clientMutationId'];
      result$data['clientMutationId'] = (l$clientMutationId as String?);
    }
    return Input$StartDownloaderInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get clientMutationId => (_$data['clientMutationId'] as String?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('clientMutationId')) {
      final l$clientMutationId = clientMutationId;
      result$data['clientMutationId'] = l$clientMutationId;
    }
    return result$data;
  }

  CopyWith$Input$StartDownloaderInput<Input$StartDownloaderInput>
      get copyWith => CopyWith$Input$StartDownloaderInput(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$StartDownloaderInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (_$data.containsKey('clientMutationId') !=
        other._$data.containsKey('clientMutationId')) {
      return false;
    }
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$clientMutationId = clientMutationId;
    return Object.hashAll([
      _$data.containsKey('clientMutationId') ? l$clientMutationId : const {}
    ]);
  }
}

abstract class CopyWith$Input$StartDownloaderInput<TRes> {
  factory CopyWith$Input$StartDownloaderInput(
    Input$StartDownloaderInput instance,
    TRes Function(Input$StartDownloaderInput) then,
  ) = _CopyWithImpl$Input$StartDownloaderInput;

  factory CopyWith$Input$StartDownloaderInput.stub(TRes res) =
      _CopyWithStubImpl$Input$StartDownloaderInput;

  TRes call({String? clientMutationId});
}

class _CopyWithImpl$Input$StartDownloaderInput<TRes>
    implements CopyWith$Input$StartDownloaderInput<TRes> {
  _CopyWithImpl$Input$StartDownloaderInput(
    this._instance,
    this._then,
  );

  final Input$StartDownloaderInput _instance;

  final TRes Function(Input$StartDownloaderInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? clientMutationId = _undefined}) =>
      _then(Input$StartDownloaderInput._({
        ..._instance._$data,
        if (clientMutationId != _undefined)
          'clientMutationId': (clientMutationId as String?),
      }));
}

class _CopyWithStubImpl$Input$StartDownloaderInput<TRes>
    implements CopyWith$Input$StartDownloaderInput<TRes> {
  _CopyWithStubImpl$Input$StartDownloaderInput(this._res);

  TRes _res;

  call({String? clientMutationId}) => _res;
}

class Input$StopDownloaderInput {
  factory Input$StopDownloaderInput({String? clientMutationId}) =>
      Input$StopDownloaderInput._({
        if (clientMutationId != null) r'clientMutationId': clientMutationId,
      });

  Input$StopDownloaderInput._(this._$data);

  factory Input$StopDownloaderInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('clientMutationId')) {
      final l$clientMutationId = data['clientMutationId'];
      result$data['clientMutationId'] = (l$clientMutationId as String?);
    }
    return Input$StopDownloaderInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get clientMutationId => (_$data['clientMutationId'] as String?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('clientMutationId')) {
      final l$clientMutationId = clientMutationId;
      result$data['clientMutationId'] = l$clientMutationId;
    }
    return result$data;
  }

  CopyWith$Input$StopDownloaderInput<Input$StopDownloaderInput> get copyWith =>
      CopyWith$Input$StopDownloaderInput(
        this,
        (i) => i,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$StopDownloaderInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (_$data.containsKey('clientMutationId') !=
        other._$data.containsKey('clientMutationId')) {
      return false;
    }
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$clientMutationId = clientMutationId;
    return Object.hashAll([
      _$data.containsKey('clientMutationId') ? l$clientMutationId : const {}
    ]);
  }
}

abstract class CopyWith$Input$StopDownloaderInput<TRes> {
  factory CopyWith$Input$StopDownloaderInput(
    Input$StopDownloaderInput instance,
    TRes Function(Input$StopDownloaderInput) then,
  ) = _CopyWithImpl$Input$StopDownloaderInput;

  factory CopyWith$Input$StopDownloaderInput.stub(TRes res) =
      _CopyWithStubImpl$Input$StopDownloaderInput;

  TRes call({String? clientMutationId});
}

class _CopyWithImpl$Input$StopDownloaderInput<TRes>
    implements CopyWith$Input$StopDownloaderInput<TRes> {
  _CopyWithImpl$Input$StopDownloaderInput(
    this._instance,
    this._then,
  );

  final Input$StopDownloaderInput _instance;

  final TRes Function(Input$StopDownloaderInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? clientMutationId = _undefined}) =>
      _then(Input$StopDownloaderInput._({
        ..._instance._$data,
        if (clientMutationId != _undefined)
          'clientMutationId': (clientMutationId as String?),
      }));
}

class _CopyWithStubImpl$Input$StopDownloaderInput<TRes>
    implements CopyWith$Input$StopDownloaderInput<TRes> {
  _CopyWithStubImpl$Input$StopDownloaderInput(this._res);

  TRes _res;

  call({String? clientMutationId}) => _res;
}

class Input$StringFilterInput {
  factory Input$StringFilterInput({
    String? distinctFrom,
    List<String>? distinctFromAll,
    List<String>? distinctFromAny,
    String? distinctFromInsensitive,
    List<String>? distinctFromInsensitiveAll,
    List<String>? distinctFromInsensitiveAny,
    String? endsWith,
    List<String>? endsWithAll,
    List<String>? endsWithAny,
    String? endsWithInsensitive,
    List<String>? endsWithInsensitiveAll,
    List<String>? endsWithInsensitiveAny,
    String? equalTo,
    String? greaterThan,
    String? greaterThanInsensitive,
    String? greaterThanOrEqualTo,
    String? greaterThanOrEqualToInsensitive,
    List<String>? $in,
    List<String>? inInsensitive,
    String? includes,
    List<String>? includesAll,
    List<String>? includesAny,
    String? includesInsensitive,
    List<String>? includesInsensitiveAll,
    List<String>? includesInsensitiveAny,
    bool? isNull,
    String? lessThan,
    String? lessThanInsensitive,
    String? lessThanOrEqualTo,
    String? lessThanOrEqualToInsensitive,
    String? like,
    List<String>? likeAll,
    List<String>? likeAny,
    String? likeInsensitive,
    List<String>? likeInsensitiveAll,
    List<String>? likeInsensitiveAny,
    String? notDistinctFrom,
    String? notDistinctFromInsensitive,
    String? notEndsWith,
    List<String>? notEndsWithAll,
    List<String>? notEndsWithAny,
    String? notEndsWithInsensitive,
    List<String>? notEndsWithInsensitiveAll,
    List<String>? notEndsWithInsensitiveAny,
    String? notEqualTo,
    List<String>? notEqualToAll,
    List<String>? notEqualToAny,
    List<String>? notIn,
    List<String>? notInInsensitive,
    String? notIncludes,
    List<String>? notIncludesAll,
    List<String>? notIncludesAny,
    String? notIncludesInsensitive,
    List<String>? notIncludesInsensitiveAll,
    List<String>? notIncludesInsensitiveAny,
    String? notLike,
    List<String>? notLikeAll,
    List<String>? notLikeAny,
    String? notLikeInsensitive,
    List<String>? notLikeInsensitiveAll,
    List<String>? notLikeInsensitiveAny,
    String? notStartsWith,
    List<String>? notStartsWithAll,
    List<String>? notStartsWithAny,
    String? notStartsWithInsensitive,
    List<String>? notStartsWithInsensitiveAll,
    List<String>? notStartsWithInsensitiveAny,
    String? startsWith,
    List<String>? startsWithAll,
    List<String>? startsWithAny,
    String? startsWithInsensitive,
    List<String>? startsWithInsensitiveAll,
    List<String>? startsWithInsensitiveAny,
  }) =>
      Input$StringFilterInput._({
        if (distinctFrom != null) r'distinctFrom': distinctFrom,
        if (distinctFromAll != null) r'distinctFromAll': distinctFromAll,
        if (distinctFromAny != null) r'distinctFromAny': distinctFromAny,
        if (distinctFromInsensitive != null)
          r'distinctFromInsensitive': distinctFromInsensitive,
        if (distinctFromInsensitiveAll != null)
          r'distinctFromInsensitiveAll': distinctFromInsensitiveAll,
        if (distinctFromInsensitiveAny != null)
          r'distinctFromInsensitiveAny': distinctFromInsensitiveAny,
        if (endsWith != null) r'endsWith': endsWith,
        if (endsWithAll != null) r'endsWithAll': endsWithAll,
        if (endsWithAny != null) r'endsWithAny': endsWithAny,
        if (endsWithInsensitive != null)
          r'endsWithInsensitive': endsWithInsensitive,
        if (endsWithInsensitiveAll != null)
          r'endsWithInsensitiveAll': endsWithInsensitiveAll,
        if (endsWithInsensitiveAny != null)
          r'endsWithInsensitiveAny': endsWithInsensitiveAny,
        if (equalTo != null) r'equalTo': equalTo,
        if (greaterThan != null) r'greaterThan': greaterThan,
        if (greaterThanInsensitive != null)
          r'greaterThanInsensitive': greaterThanInsensitive,
        if (greaterThanOrEqualTo != null)
          r'greaterThanOrEqualTo': greaterThanOrEqualTo,
        if (greaterThanOrEqualToInsensitive != null)
          r'greaterThanOrEqualToInsensitive': greaterThanOrEqualToInsensitive,
        if ($in != null) r'in': $in,
        if (inInsensitive != null) r'inInsensitive': inInsensitive,
        if (includes != null) r'includes': includes,
        if (includesAll != null) r'includesAll': includesAll,
        if (includesAny != null) r'includesAny': includesAny,
        if (includesInsensitive != null)
          r'includesInsensitive': includesInsensitive,
        if (includesInsensitiveAll != null)
          r'includesInsensitiveAll': includesInsensitiveAll,
        if (includesInsensitiveAny != null)
          r'includesInsensitiveAny': includesInsensitiveAny,
        if (isNull != null) r'isNull': isNull,
        if (lessThan != null) r'lessThan': lessThan,
        if (lessThanInsensitive != null)
          r'lessThanInsensitive': lessThanInsensitive,
        if (lessThanOrEqualTo != null) r'lessThanOrEqualTo': lessThanOrEqualTo,
        if (lessThanOrEqualToInsensitive != null)
          r'lessThanOrEqualToInsensitive': lessThanOrEqualToInsensitive,
        if (like != null) r'like': like,
        if (likeAll != null) r'likeAll': likeAll,
        if (likeAny != null) r'likeAny': likeAny,
        if (likeInsensitive != null) r'likeInsensitive': likeInsensitive,
        if (likeInsensitiveAll != null)
          r'likeInsensitiveAll': likeInsensitiveAll,
        if (likeInsensitiveAny != null)
          r'likeInsensitiveAny': likeInsensitiveAny,
        if (notDistinctFrom != null) r'notDistinctFrom': notDistinctFrom,
        if (notDistinctFromInsensitive != null)
          r'notDistinctFromInsensitive': notDistinctFromInsensitive,
        if (notEndsWith != null) r'notEndsWith': notEndsWith,
        if (notEndsWithAll != null) r'notEndsWithAll': notEndsWithAll,
        if (notEndsWithAny != null) r'notEndsWithAny': notEndsWithAny,
        if (notEndsWithInsensitive != null)
          r'notEndsWithInsensitive': notEndsWithInsensitive,
        if (notEndsWithInsensitiveAll != null)
          r'notEndsWithInsensitiveAll': notEndsWithInsensitiveAll,
        if (notEndsWithInsensitiveAny != null)
          r'notEndsWithInsensitiveAny': notEndsWithInsensitiveAny,
        if (notEqualTo != null) r'notEqualTo': notEqualTo,
        if (notEqualToAll != null) r'notEqualToAll': notEqualToAll,
        if (notEqualToAny != null) r'notEqualToAny': notEqualToAny,
        if (notIn != null) r'notIn': notIn,
        if (notInInsensitive != null) r'notInInsensitive': notInInsensitive,
        if (notIncludes != null) r'notIncludes': notIncludes,
        if (notIncludesAll != null) r'notIncludesAll': notIncludesAll,
        if (notIncludesAny != null) r'notIncludesAny': notIncludesAny,
        if (notIncludesInsensitive != null)
          r'notIncludesInsensitive': notIncludesInsensitive,
        if (notIncludesInsensitiveAll != null)
          r'notIncludesInsensitiveAll': notIncludesInsensitiveAll,
        if (notIncludesInsensitiveAny != null)
          r'notIncludesInsensitiveAny': notIncludesInsensitiveAny,
        if (notLike != null) r'notLike': notLike,
        if (notLikeAll != null) r'notLikeAll': notLikeAll,
        if (notLikeAny != null) r'notLikeAny': notLikeAny,
        if (notLikeInsensitive != null)
          r'notLikeInsensitive': notLikeInsensitive,
        if (notLikeInsensitiveAll != null)
          r'notLikeInsensitiveAll': notLikeInsensitiveAll,
        if (notLikeInsensitiveAny != null)
          r'notLikeInsensitiveAny': notLikeInsensitiveAny,
        if (notStartsWith != null) r'notStartsWith': notStartsWith,
        if (notStartsWithAll != null) r'notStartsWithAll': notStartsWithAll,
        if (notStartsWithAny != null) r'notStartsWithAny': notStartsWithAny,
        if (notStartsWithInsensitive != null)
          r'notStartsWithInsensitive': notStartsWithInsensitive,
        if (notStartsWithInsensitiveAll != null)
          r'notStartsWithInsensitiveAll': notStartsWithInsensitiveAll,
        if (notStartsWithInsensitiveAny != null)
          r'notStartsWithInsensitiveAny': notStartsWithInsensitiveAny,
        if (startsWith != null) r'startsWith': startsWith,
        if (startsWithAll != null) r'startsWithAll': startsWithAll,
        if (startsWithAny != null) r'startsWithAny': startsWithAny,
        if (startsWithInsensitive != null)
          r'startsWithInsensitive': startsWithInsensitive,
        if (startsWithInsensitiveAll != null)
          r'startsWithInsensitiveAll': startsWithInsensitiveAll,
        if (startsWithInsensitiveAny != null)
          r'startsWithInsensitiveAny': startsWithInsensitiveAny,
      });

  Input$StringFilterInput._(this._$data);

  factory Input$StringFilterInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('distinctFrom')) {
      final l$distinctFrom = data['distinctFrom'];
      result$data['distinctFrom'] = (l$distinctFrom as String?);
    }
    if (data.containsKey('distinctFromAll')) {
      final l$distinctFromAll = data['distinctFromAll'];
      result$data['distinctFromAll'] = (l$distinctFromAll as List<dynamic>?)
          ?.map((e) => (e as String))
          .toList();
    }
    if (data.containsKey('distinctFromAny')) {
      final l$distinctFromAny = data['distinctFromAny'];
      result$data['distinctFromAny'] = (l$distinctFromAny as List<dynamic>?)
          ?.map((e) => (e as String))
          .toList();
    }
    if (data.containsKey('distinctFromInsensitive')) {
      final l$distinctFromInsensitive = data['distinctFromInsensitive'];
      result$data['distinctFromInsensitive'] =
          (l$distinctFromInsensitive as String?);
    }
    if (data.containsKey('distinctFromInsensitiveAll')) {
      final l$distinctFromInsensitiveAll = data['distinctFromInsensitiveAll'];
      result$data['distinctFromInsensitiveAll'] =
          (l$distinctFromInsensitiveAll as List<dynamic>?)
              ?.map((e) => (e as String))
              .toList();
    }
    if (data.containsKey('distinctFromInsensitiveAny')) {
      final l$distinctFromInsensitiveAny = data['distinctFromInsensitiveAny'];
      result$data['distinctFromInsensitiveAny'] =
          (l$distinctFromInsensitiveAny as List<dynamic>?)
              ?.map((e) => (e as String))
              .toList();
    }
    if (data.containsKey('endsWith')) {
      final l$endsWith = data['endsWith'];
      result$data['endsWith'] = (l$endsWith as String?);
    }
    if (data.containsKey('endsWithAll')) {
      final l$endsWithAll = data['endsWithAll'];
      result$data['endsWithAll'] =
          (l$endsWithAll as List<dynamic>?)?.map((e) => (e as String)).toList();
    }
    if (data.containsKey('endsWithAny')) {
      final l$endsWithAny = data['endsWithAny'];
      result$data['endsWithAny'] =
          (l$endsWithAny as List<dynamic>?)?.map((e) => (e as String)).toList();
    }
    if (data.containsKey('endsWithInsensitive')) {
      final l$endsWithInsensitive = data['endsWithInsensitive'];
      result$data['endsWithInsensitive'] = (l$endsWithInsensitive as String?);
    }
    if (data.containsKey('endsWithInsensitiveAll')) {
      final l$endsWithInsensitiveAll = data['endsWithInsensitiveAll'];
      result$data['endsWithInsensitiveAll'] =
          (l$endsWithInsensitiveAll as List<dynamic>?)
              ?.map((e) => (e as String))
              .toList();
    }
    if (data.containsKey('endsWithInsensitiveAny')) {
      final l$endsWithInsensitiveAny = data['endsWithInsensitiveAny'];
      result$data['endsWithInsensitiveAny'] =
          (l$endsWithInsensitiveAny as List<dynamic>?)
              ?.map((e) => (e as String))
              .toList();
    }
    if (data.containsKey('equalTo')) {
      final l$equalTo = data['equalTo'];
      result$data['equalTo'] = (l$equalTo as String?);
    }
    if (data.containsKey('greaterThan')) {
      final l$greaterThan = data['greaterThan'];
      result$data['greaterThan'] = (l$greaterThan as String?);
    }
    if (data.containsKey('greaterThanInsensitive')) {
      final l$greaterThanInsensitive = data['greaterThanInsensitive'];
      result$data['greaterThanInsensitive'] =
          (l$greaterThanInsensitive as String?);
    }
    if (data.containsKey('greaterThanOrEqualTo')) {
      final l$greaterThanOrEqualTo = data['greaterThanOrEqualTo'];
      result$data['greaterThanOrEqualTo'] = (l$greaterThanOrEqualTo as String?);
    }
    if (data.containsKey('greaterThanOrEqualToInsensitive')) {
      final l$greaterThanOrEqualToInsensitive =
          data['greaterThanOrEqualToInsensitive'];
      result$data['greaterThanOrEqualToInsensitive'] =
          (l$greaterThanOrEqualToInsensitive as String?);
    }
    if (data.containsKey('in')) {
      final l$$in = data['in'];
      result$data['in'] =
          (l$$in as List<dynamic>?)?.map((e) => (e as String)).toList();
    }
    if (data.containsKey('inInsensitive')) {
      final l$inInsensitive = data['inInsensitive'];
      result$data['inInsensitive'] = (l$inInsensitive as List<dynamic>?)
          ?.map((e) => (e as String))
          .toList();
    }
    if (data.containsKey('includes')) {
      final l$includes = data['includes'];
      result$data['includes'] = (l$includes as String?);
    }
    if (data.containsKey('includesAll')) {
      final l$includesAll = data['includesAll'];
      result$data['includesAll'] =
          (l$includesAll as List<dynamic>?)?.map((e) => (e as String)).toList();
    }
    if (data.containsKey('includesAny')) {
      final l$includesAny = data['includesAny'];
      result$data['includesAny'] =
          (l$includesAny as List<dynamic>?)?.map((e) => (e as String)).toList();
    }
    if (data.containsKey('includesInsensitive')) {
      final l$includesInsensitive = data['includesInsensitive'];
      result$data['includesInsensitive'] = (l$includesInsensitive as String?);
    }
    if (data.containsKey('includesInsensitiveAll')) {
      final l$includesInsensitiveAll = data['includesInsensitiveAll'];
      result$data['includesInsensitiveAll'] =
          (l$includesInsensitiveAll as List<dynamic>?)
              ?.map((e) => (e as String))
              .toList();
    }
    if (data.containsKey('includesInsensitiveAny')) {
      final l$includesInsensitiveAny = data['includesInsensitiveAny'];
      result$data['includesInsensitiveAny'] =
          (l$includesInsensitiveAny as List<dynamic>?)
              ?.map((e) => (e as String))
              .toList();
    }
    if (data.containsKey('isNull')) {
      final l$isNull = data['isNull'];
      result$data['isNull'] = (l$isNull as bool?);
    }
    if (data.containsKey('lessThan')) {
      final l$lessThan = data['lessThan'];
      result$data['lessThan'] = (l$lessThan as String?);
    }
    if (data.containsKey('lessThanInsensitive')) {
      final l$lessThanInsensitive = data['lessThanInsensitive'];
      result$data['lessThanInsensitive'] = (l$lessThanInsensitive as String?);
    }
    if (data.containsKey('lessThanOrEqualTo')) {
      final l$lessThanOrEqualTo = data['lessThanOrEqualTo'];
      result$data['lessThanOrEqualTo'] = (l$lessThanOrEqualTo as String?);
    }
    if (data.containsKey('lessThanOrEqualToInsensitive')) {
      final l$lessThanOrEqualToInsensitive =
          data['lessThanOrEqualToInsensitive'];
      result$data['lessThanOrEqualToInsensitive'] =
          (l$lessThanOrEqualToInsensitive as String?);
    }
    if (data.containsKey('like')) {
      final l$like = data['like'];
      result$data['like'] = (l$like as String?);
    }
    if (data.containsKey('likeAll')) {
      final l$likeAll = data['likeAll'];
      result$data['likeAll'] =
          (l$likeAll as List<dynamic>?)?.map((e) => (e as String)).toList();
    }
    if (data.containsKey('likeAny')) {
      final l$likeAny = data['likeAny'];
      result$data['likeAny'] =
          (l$likeAny as List<dynamic>?)?.map((e) => (e as String)).toList();
    }
    if (data.containsKey('likeInsensitive')) {
      final l$likeInsensitive = data['likeInsensitive'];
      result$data['likeInsensitive'] = (l$likeInsensitive as String?);
    }
    if (data.containsKey('likeInsensitiveAll')) {
      final l$likeInsensitiveAll = data['likeInsensitiveAll'];
      result$data['likeInsensitiveAll'] =
          (l$likeInsensitiveAll as List<dynamic>?)
              ?.map((e) => (e as String))
              .toList();
    }
    if (data.containsKey('likeInsensitiveAny')) {
      final l$likeInsensitiveAny = data['likeInsensitiveAny'];
      result$data['likeInsensitiveAny'] =
          (l$likeInsensitiveAny as List<dynamic>?)
              ?.map((e) => (e as String))
              .toList();
    }
    if (data.containsKey('notDistinctFrom')) {
      final l$notDistinctFrom = data['notDistinctFrom'];
      result$data['notDistinctFrom'] = (l$notDistinctFrom as String?);
    }
    if (data.containsKey('notDistinctFromInsensitive')) {
      final l$notDistinctFromInsensitive = data['notDistinctFromInsensitive'];
      result$data['notDistinctFromInsensitive'] =
          (l$notDistinctFromInsensitive as String?);
    }
    if (data.containsKey('notEndsWith')) {
      final l$notEndsWith = data['notEndsWith'];
      result$data['notEndsWith'] = (l$notEndsWith as String?);
    }
    if (data.containsKey('notEndsWithAll')) {
      final l$notEndsWithAll = data['notEndsWithAll'];
      result$data['notEndsWithAll'] = (l$notEndsWithAll as List<dynamic>?)
          ?.map((e) => (e as String))
          .toList();
    }
    if (data.containsKey('notEndsWithAny')) {
      final l$notEndsWithAny = data['notEndsWithAny'];
      result$data['notEndsWithAny'] = (l$notEndsWithAny as List<dynamic>?)
          ?.map((e) => (e as String))
          .toList();
    }
    if (data.containsKey('notEndsWithInsensitive')) {
      final l$notEndsWithInsensitive = data['notEndsWithInsensitive'];
      result$data['notEndsWithInsensitive'] =
          (l$notEndsWithInsensitive as String?);
    }
    if (data.containsKey('notEndsWithInsensitiveAll')) {
      final l$notEndsWithInsensitiveAll = data['notEndsWithInsensitiveAll'];
      result$data['notEndsWithInsensitiveAll'] =
          (l$notEndsWithInsensitiveAll as List<dynamic>?)
              ?.map((e) => (e as String))
              .toList();
    }
    if (data.containsKey('notEndsWithInsensitiveAny')) {
      final l$notEndsWithInsensitiveAny = data['notEndsWithInsensitiveAny'];
      result$data['notEndsWithInsensitiveAny'] =
          (l$notEndsWithInsensitiveAny as List<dynamic>?)
              ?.map((e) => (e as String))
              .toList();
    }
    if (data.containsKey('notEqualTo')) {
      final l$notEqualTo = data['notEqualTo'];
      result$data['notEqualTo'] = (l$notEqualTo as String?);
    }
    if (data.containsKey('notEqualToAll')) {
      final l$notEqualToAll = data['notEqualToAll'];
      result$data['notEqualToAll'] = (l$notEqualToAll as List<dynamic>?)
          ?.map((e) => (e as String))
          .toList();
    }
    if (data.containsKey('notEqualToAny')) {
      final l$notEqualToAny = data['notEqualToAny'];
      result$data['notEqualToAny'] = (l$notEqualToAny as List<dynamic>?)
          ?.map((e) => (e as String))
          .toList();
    }
    if (data.containsKey('notIn')) {
      final l$notIn = data['notIn'];
      result$data['notIn'] =
          (l$notIn as List<dynamic>?)?.map((e) => (e as String)).toList();
    }
    if (data.containsKey('notInInsensitive')) {
      final l$notInInsensitive = data['notInInsensitive'];
      result$data['notInInsensitive'] = (l$notInInsensitive as List<dynamic>?)
          ?.map((e) => (e as String))
          .toList();
    }
    if (data.containsKey('notIncludes')) {
      final l$notIncludes = data['notIncludes'];
      result$data['notIncludes'] = (l$notIncludes as String?);
    }
    if (data.containsKey('notIncludesAll')) {
      final l$notIncludesAll = data['notIncludesAll'];
      result$data['notIncludesAll'] = (l$notIncludesAll as List<dynamic>?)
          ?.map((e) => (e as String))
          .toList();
    }
    if (data.containsKey('notIncludesAny')) {
      final l$notIncludesAny = data['notIncludesAny'];
      result$data['notIncludesAny'] = (l$notIncludesAny as List<dynamic>?)
          ?.map((e) => (e as String))
          .toList();
    }
    if (data.containsKey('notIncludesInsensitive')) {
      final l$notIncludesInsensitive = data['notIncludesInsensitive'];
      result$data['notIncludesInsensitive'] =
          (l$notIncludesInsensitive as String?);
    }
    if (data.containsKey('notIncludesInsensitiveAll')) {
      final l$notIncludesInsensitiveAll = data['notIncludesInsensitiveAll'];
      result$data['notIncludesInsensitiveAll'] =
          (l$notIncludesInsensitiveAll as List<dynamic>?)
              ?.map((e) => (e as String))
              .toList();
    }
    if (data.containsKey('notIncludesInsensitiveAny')) {
      final l$notIncludesInsensitiveAny = data['notIncludesInsensitiveAny'];
      result$data['notIncludesInsensitiveAny'] =
          (l$notIncludesInsensitiveAny as List<dynamic>?)
              ?.map((e) => (e as String))
              .toList();
    }
    if (data.containsKey('notLike')) {
      final l$notLike = data['notLike'];
      result$data['notLike'] = (l$notLike as String?);
    }
    if (data.containsKey('notLikeAll')) {
      final l$notLikeAll = data['notLikeAll'];
      result$data['notLikeAll'] =
          (l$notLikeAll as List<dynamic>?)?.map((e) => (e as String)).toList();
    }
    if (data.containsKey('notLikeAny')) {
      final l$notLikeAny = data['notLikeAny'];
      result$data['notLikeAny'] =
          (l$notLikeAny as List<dynamic>?)?.map((e) => (e as String)).toList();
    }
    if (data.containsKey('notLikeInsensitive')) {
      final l$notLikeInsensitive = data['notLikeInsensitive'];
      result$data['notLikeInsensitive'] = (l$notLikeInsensitive as String?);
    }
    if (data.containsKey('notLikeInsensitiveAll')) {
      final l$notLikeInsensitiveAll = data['notLikeInsensitiveAll'];
      result$data['notLikeInsensitiveAll'] =
          (l$notLikeInsensitiveAll as List<dynamic>?)
              ?.map((e) => (e as String))
              .toList();
    }
    if (data.containsKey('notLikeInsensitiveAny')) {
      final l$notLikeInsensitiveAny = data['notLikeInsensitiveAny'];
      result$data['notLikeInsensitiveAny'] =
          (l$notLikeInsensitiveAny as List<dynamic>?)
              ?.map((e) => (e as String))
              .toList();
    }
    if (data.containsKey('notStartsWith')) {
      final l$notStartsWith = data['notStartsWith'];
      result$data['notStartsWith'] = (l$notStartsWith as String?);
    }
    if (data.containsKey('notStartsWithAll')) {
      final l$notStartsWithAll = data['notStartsWithAll'];
      result$data['notStartsWithAll'] = (l$notStartsWithAll as List<dynamic>?)
          ?.map((e) => (e as String))
          .toList();
    }
    if (data.containsKey('notStartsWithAny')) {
      final l$notStartsWithAny = data['notStartsWithAny'];
      result$data['notStartsWithAny'] = (l$notStartsWithAny as List<dynamic>?)
          ?.map((e) => (e as String))
          .toList();
    }
    if (data.containsKey('notStartsWithInsensitive')) {
      final l$notStartsWithInsensitive = data['notStartsWithInsensitive'];
      result$data['notStartsWithInsensitive'] =
          (l$notStartsWithInsensitive as String?);
    }
    if (data.containsKey('notStartsWithInsensitiveAll')) {
      final l$notStartsWithInsensitiveAll = data['notStartsWithInsensitiveAll'];
      result$data['notStartsWithInsensitiveAll'] =
          (l$notStartsWithInsensitiveAll as List<dynamic>?)
              ?.map((e) => (e as String))
              .toList();
    }
    if (data.containsKey('notStartsWithInsensitiveAny')) {
      final l$notStartsWithInsensitiveAny = data['notStartsWithInsensitiveAny'];
      result$data['notStartsWithInsensitiveAny'] =
          (l$notStartsWithInsensitiveAny as List<dynamic>?)
              ?.map((e) => (e as String))
              .toList();
    }
    if (data.containsKey('startsWith')) {
      final l$startsWith = data['startsWith'];
      result$data['startsWith'] = (l$startsWith as String?);
    }
    if (data.containsKey('startsWithAll')) {
      final l$startsWithAll = data['startsWithAll'];
      result$data['startsWithAll'] = (l$startsWithAll as List<dynamic>?)
          ?.map((e) => (e as String))
          .toList();
    }
    if (data.containsKey('startsWithAny')) {
      final l$startsWithAny = data['startsWithAny'];
      result$data['startsWithAny'] = (l$startsWithAny as List<dynamic>?)
          ?.map((e) => (e as String))
          .toList();
    }
    if (data.containsKey('startsWithInsensitive')) {
      final l$startsWithInsensitive = data['startsWithInsensitive'];
      result$data['startsWithInsensitive'] =
          (l$startsWithInsensitive as String?);
    }
    if (data.containsKey('startsWithInsensitiveAll')) {
      final l$startsWithInsensitiveAll = data['startsWithInsensitiveAll'];
      result$data['startsWithInsensitiveAll'] =
          (l$startsWithInsensitiveAll as List<dynamic>?)
              ?.map((e) => (e as String))
              .toList();
    }
    if (data.containsKey('startsWithInsensitiveAny')) {
      final l$startsWithInsensitiveAny = data['startsWithInsensitiveAny'];
      result$data['startsWithInsensitiveAny'] =
          (l$startsWithInsensitiveAny as List<dynamic>?)
              ?.map((e) => (e as String))
              .toList();
    }
    return Input$StringFilterInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get distinctFrom => (_$data['distinctFrom'] as String?);

  List<String>? get distinctFromAll =>
      (_$data['distinctFromAll'] as List<String>?);

  List<String>? get distinctFromAny =>
      (_$data['distinctFromAny'] as List<String>?);

  String? get distinctFromInsensitive =>
      (_$data['distinctFromInsensitive'] as String?);

  List<String>? get distinctFromInsensitiveAll =>
      (_$data['distinctFromInsensitiveAll'] as List<String>?);

  List<String>? get distinctFromInsensitiveAny =>
      (_$data['distinctFromInsensitiveAny'] as List<String>?);

  String? get endsWith => (_$data['endsWith'] as String?);

  List<String>? get endsWithAll => (_$data['endsWithAll'] as List<String>?);

  List<String>? get endsWithAny => (_$data['endsWithAny'] as List<String>?);

  String? get endsWithInsensitive => (_$data['endsWithInsensitive'] as String?);

  List<String>? get endsWithInsensitiveAll =>
      (_$data['endsWithInsensitiveAll'] as List<String>?);

  List<String>? get endsWithInsensitiveAny =>
      (_$data['endsWithInsensitiveAny'] as List<String>?);

  String? get equalTo => (_$data['equalTo'] as String?);

  String? get greaterThan => (_$data['greaterThan'] as String?);

  String? get greaterThanInsensitive =>
      (_$data['greaterThanInsensitive'] as String?);

  String? get greaterThanOrEqualTo =>
      (_$data['greaterThanOrEqualTo'] as String?);

  String? get greaterThanOrEqualToInsensitive =>
      (_$data['greaterThanOrEqualToInsensitive'] as String?);

  List<String>? get $in => (_$data['in'] as List<String>?);

  List<String>? get inInsensitive => (_$data['inInsensitive'] as List<String>?);

  String? get includes => (_$data['includes'] as String?);

  List<String>? get includesAll => (_$data['includesAll'] as List<String>?);

  List<String>? get includesAny => (_$data['includesAny'] as List<String>?);

  String? get includesInsensitive => (_$data['includesInsensitive'] as String?);

  List<String>? get includesInsensitiveAll =>
      (_$data['includesInsensitiveAll'] as List<String>?);

  List<String>? get includesInsensitiveAny =>
      (_$data['includesInsensitiveAny'] as List<String>?);

  bool? get isNull => (_$data['isNull'] as bool?);

  String? get lessThan => (_$data['lessThan'] as String?);

  String? get lessThanInsensitive => (_$data['lessThanInsensitive'] as String?);

  String? get lessThanOrEqualTo => (_$data['lessThanOrEqualTo'] as String?);

  String? get lessThanOrEqualToInsensitive =>
      (_$data['lessThanOrEqualToInsensitive'] as String?);

  String? get like => (_$data['like'] as String?);

  List<String>? get likeAll => (_$data['likeAll'] as List<String>?);

  List<String>? get likeAny => (_$data['likeAny'] as List<String>?);

  String? get likeInsensitive => (_$data['likeInsensitive'] as String?);

  List<String>? get likeInsensitiveAll =>
      (_$data['likeInsensitiveAll'] as List<String>?);

  List<String>? get likeInsensitiveAny =>
      (_$data['likeInsensitiveAny'] as List<String>?);

  String? get notDistinctFrom => (_$data['notDistinctFrom'] as String?);

  String? get notDistinctFromInsensitive =>
      (_$data['notDistinctFromInsensitive'] as String?);

  String? get notEndsWith => (_$data['notEndsWith'] as String?);

  List<String>? get notEndsWithAll =>
      (_$data['notEndsWithAll'] as List<String>?);

  List<String>? get notEndsWithAny =>
      (_$data['notEndsWithAny'] as List<String>?);

  String? get notEndsWithInsensitive =>
      (_$data['notEndsWithInsensitive'] as String?);

  List<String>? get notEndsWithInsensitiveAll =>
      (_$data['notEndsWithInsensitiveAll'] as List<String>?);

  List<String>? get notEndsWithInsensitiveAny =>
      (_$data['notEndsWithInsensitiveAny'] as List<String>?);

  String? get notEqualTo => (_$data['notEqualTo'] as String?);

  List<String>? get notEqualToAll => (_$data['notEqualToAll'] as List<String>?);

  List<String>? get notEqualToAny => (_$data['notEqualToAny'] as List<String>?);

  List<String>? get notIn => (_$data['notIn'] as List<String>?);

  List<String>? get notInInsensitive =>
      (_$data['notInInsensitive'] as List<String>?);

  String? get notIncludes => (_$data['notIncludes'] as String?);

  List<String>? get notIncludesAll =>
      (_$data['notIncludesAll'] as List<String>?);

  List<String>? get notIncludesAny =>
      (_$data['notIncludesAny'] as List<String>?);

  String? get notIncludesInsensitive =>
      (_$data['notIncludesInsensitive'] as String?);

  List<String>? get notIncludesInsensitiveAll =>
      (_$data['notIncludesInsensitiveAll'] as List<String>?);

  List<String>? get notIncludesInsensitiveAny =>
      (_$data['notIncludesInsensitiveAny'] as List<String>?);

  String? get notLike => (_$data['notLike'] as String?);

  List<String>? get notLikeAll => (_$data['notLikeAll'] as List<String>?);

  List<String>? get notLikeAny => (_$data['notLikeAny'] as List<String>?);

  String? get notLikeInsensitive => (_$data['notLikeInsensitive'] as String?);

  List<String>? get notLikeInsensitiveAll =>
      (_$data['notLikeInsensitiveAll'] as List<String>?);

  List<String>? get notLikeInsensitiveAny =>
      (_$data['notLikeInsensitiveAny'] as List<String>?);

  String? get notStartsWith => (_$data['notStartsWith'] as String?);

  List<String>? get notStartsWithAll =>
      (_$data['notStartsWithAll'] as List<String>?);

  List<String>? get notStartsWithAny =>
      (_$data['notStartsWithAny'] as List<String>?);

  String? get notStartsWithInsensitive =>
      (_$data['notStartsWithInsensitive'] as String?);

  List<String>? get notStartsWithInsensitiveAll =>
      (_$data['notStartsWithInsensitiveAll'] as List<String>?);

  List<String>? get notStartsWithInsensitiveAny =>
      (_$data['notStartsWithInsensitiveAny'] as List<String>?);

  String? get startsWith => (_$data['startsWith'] as String?);

  List<String>? get startsWithAll => (_$data['startsWithAll'] as List<String>?);

  List<String>? get startsWithAny => (_$data['startsWithAny'] as List<String>?);

  String? get startsWithInsensitive =>
      (_$data['startsWithInsensitive'] as String?);

  List<String>? get startsWithInsensitiveAll =>
      (_$data['startsWithInsensitiveAll'] as List<String>?);

  List<String>? get startsWithInsensitiveAny =>
      (_$data['startsWithInsensitiveAny'] as List<String>?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('distinctFrom')) {
      final l$distinctFrom = distinctFrom;
      result$data['distinctFrom'] = l$distinctFrom;
    }
    if (_$data.containsKey('distinctFromAll')) {
      final l$distinctFromAll = distinctFromAll;
      result$data['distinctFromAll'] =
          l$distinctFromAll?.map((e) => e).toList();
    }
    if (_$data.containsKey('distinctFromAny')) {
      final l$distinctFromAny = distinctFromAny;
      result$data['distinctFromAny'] =
          l$distinctFromAny?.map((e) => e).toList();
    }
    if (_$data.containsKey('distinctFromInsensitive')) {
      final l$distinctFromInsensitive = distinctFromInsensitive;
      result$data['distinctFromInsensitive'] = l$distinctFromInsensitive;
    }
    if (_$data.containsKey('distinctFromInsensitiveAll')) {
      final l$distinctFromInsensitiveAll = distinctFromInsensitiveAll;
      result$data['distinctFromInsensitiveAll'] =
          l$distinctFromInsensitiveAll?.map((e) => e).toList();
    }
    if (_$data.containsKey('distinctFromInsensitiveAny')) {
      final l$distinctFromInsensitiveAny = distinctFromInsensitiveAny;
      result$data['distinctFromInsensitiveAny'] =
          l$distinctFromInsensitiveAny?.map((e) => e).toList();
    }
    if (_$data.containsKey('endsWith')) {
      final l$endsWith = endsWith;
      result$data['endsWith'] = l$endsWith;
    }
    if (_$data.containsKey('endsWithAll')) {
      final l$endsWithAll = endsWithAll;
      result$data['endsWithAll'] = l$endsWithAll?.map((e) => e).toList();
    }
    if (_$data.containsKey('endsWithAny')) {
      final l$endsWithAny = endsWithAny;
      result$data['endsWithAny'] = l$endsWithAny?.map((e) => e).toList();
    }
    if (_$data.containsKey('endsWithInsensitive')) {
      final l$endsWithInsensitive = endsWithInsensitive;
      result$data['endsWithInsensitive'] = l$endsWithInsensitive;
    }
    if (_$data.containsKey('endsWithInsensitiveAll')) {
      final l$endsWithInsensitiveAll = endsWithInsensitiveAll;
      result$data['endsWithInsensitiveAll'] =
          l$endsWithInsensitiveAll?.map((e) => e).toList();
    }
    if (_$data.containsKey('endsWithInsensitiveAny')) {
      final l$endsWithInsensitiveAny = endsWithInsensitiveAny;
      result$data['endsWithInsensitiveAny'] =
          l$endsWithInsensitiveAny?.map((e) => e).toList();
    }
    if (_$data.containsKey('equalTo')) {
      final l$equalTo = equalTo;
      result$data['equalTo'] = l$equalTo;
    }
    if (_$data.containsKey('greaterThan')) {
      final l$greaterThan = greaterThan;
      result$data['greaterThan'] = l$greaterThan;
    }
    if (_$data.containsKey('greaterThanInsensitive')) {
      final l$greaterThanInsensitive = greaterThanInsensitive;
      result$data['greaterThanInsensitive'] = l$greaterThanInsensitive;
    }
    if (_$data.containsKey('greaterThanOrEqualTo')) {
      final l$greaterThanOrEqualTo = greaterThanOrEqualTo;
      result$data['greaterThanOrEqualTo'] = l$greaterThanOrEqualTo;
    }
    if (_$data.containsKey('greaterThanOrEqualToInsensitive')) {
      final l$greaterThanOrEqualToInsensitive = greaterThanOrEqualToInsensitive;
      result$data['greaterThanOrEqualToInsensitive'] =
          l$greaterThanOrEqualToInsensitive;
    }
    if (_$data.containsKey('in')) {
      final l$$in = $in;
      result$data['in'] = l$$in?.map((e) => e).toList();
    }
    if (_$data.containsKey('inInsensitive')) {
      final l$inInsensitive = inInsensitive;
      result$data['inInsensitive'] = l$inInsensitive?.map((e) => e).toList();
    }
    if (_$data.containsKey('includes')) {
      final l$includes = includes;
      result$data['includes'] = l$includes;
    }
    if (_$data.containsKey('includesAll')) {
      final l$includesAll = includesAll;
      result$data['includesAll'] = l$includesAll?.map((e) => e).toList();
    }
    if (_$data.containsKey('includesAny')) {
      final l$includesAny = includesAny;
      result$data['includesAny'] = l$includesAny?.map((e) => e).toList();
    }
    if (_$data.containsKey('includesInsensitive')) {
      final l$includesInsensitive = includesInsensitive;
      result$data['includesInsensitive'] = l$includesInsensitive;
    }
    if (_$data.containsKey('includesInsensitiveAll')) {
      final l$includesInsensitiveAll = includesInsensitiveAll;
      result$data['includesInsensitiveAll'] =
          l$includesInsensitiveAll?.map((e) => e).toList();
    }
    if (_$data.containsKey('includesInsensitiveAny')) {
      final l$includesInsensitiveAny = includesInsensitiveAny;
      result$data['includesInsensitiveAny'] =
          l$includesInsensitiveAny?.map((e) => e).toList();
    }
    if (_$data.containsKey('isNull')) {
      final l$isNull = isNull;
      result$data['isNull'] = l$isNull;
    }
    if (_$data.containsKey('lessThan')) {
      final l$lessThan = lessThan;
      result$data['lessThan'] = l$lessThan;
    }
    if (_$data.containsKey('lessThanInsensitive')) {
      final l$lessThanInsensitive = lessThanInsensitive;
      result$data['lessThanInsensitive'] = l$lessThanInsensitive;
    }
    if (_$data.containsKey('lessThanOrEqualTo')) {
      final l$lessThanOrEqualTo = lessThanOrEqualTo;
      result$data['lessThanOrEqualTo'] = l$lessThanOrEqualTo;
    }
    if (_$data.containsKey('lessThanOrEqualToInsensitive')) {
      final l$lessThanOrEqualToInsensitive = lessThanOrEqualToInsensitive;
      result$data['lessThanOrEqualToInsensitive'] =
          l$lessThanOrEqualToInsensitive;
    }
    if (_$data.containsKey('like')) {
      final l$like = like;
      result$data['like'] = l$like;
    }
    if (_$data.containsKey('likeAll')) {
      final l$likeAll = likeAll;
      result$data['likeAll'] = l$likeAll?.map((e) => e).toList();
    }
    if (_$data.containsKey('likeAny')) {
      final l$likeAny = likeAny;
      result$data['likeAny'] = l$likeAny?.map((e) => e).toList();
    }
    if (_$data.containsKey('likeInsensitive')) {
      final l$likeInsensitive = likeInsensitive;
      result$data['likeInsensitive'] = l$likeInsensitive;
    }
    if (_$data.containsKey('likeInsensitiveAll')) {
      final l$likeInsensitiveAll = likeInsensitiveAll;
      result$data['likeInsensitiveAll'] =
          l$likeInsensitiveAll?.map((e) => e).toList();
    }
    if (_$data.containsKey('likeInsensitiveAny')) {
      final l$likeInsensitiveAny = likeInsensitiveAny;
      result$data['likeInsensitiveAny'] =
          l$likeInsensitiveAny?.map((e) => e).toList();
    }
    if (_$data.containsKey('notDistinctFrom')) {
      final l$notDistinctFrom = notDistinctFrom;
      result$data['notDistinctFrom'] = l$notDistinctFrom;
    }
    if (_$data.containsKey('notDistinctFromInsensitive')) {
      final l$notDistinctFromInsensitive = notDistinctFromInsensitive;
      result$data['notDistinctFromInsensitive'] = l$notDistinctFromInsensitive;
    }
    if (_$data.containsKey('notEndsWith')) {
      final l$notEndsWith = notEndsWith;
      result$data['notEndsWith'] = l$notEndsWith;
    }
    if (_$data.containsKey('notEndsWithAll')) {
      final l$notEndsWithAll = notEndsWithAll;
      result$data['notEndsWithAll'] = l$notEndsWithAll?.map((e) => e).toList();
    }
    if (_$data.containsKey('notEndsWithAny')) {
      final l$notEndsWithAny = notEndsWithAny;
      result$data['notEndsWithAny'] = l$notEndsWithAny?.map((e) => e).toList();
    }
    if (_$data.containsKey('notEndsWithInsensitive')) {
      final l$notEndsWithInsensitive = notEndsWithInsensitive;
      result$data['notEndsWithInsensitive'] = l$notEndsWithInsensitive;
    }
    if (_$data.containsKey('notEndsWithInsensitiveAll')) {
      final l$notEndsWithInsensitiveAll = notEndsWithInsensitiveAll;
      result$data['notEndsWithInsensitiveAll'] =
          l$notEndsWithInsensitiveAll?.map((e) => e).toList();
    }
    if (_$data.containsKey('notEndsWithInsensitiveAny')) {
      final l$notEndsWithInsensitiveAny = notEndsWithInsensitiveAny;
      result$data['notEndsWithInsensitiveAny'] =
          l$notEndsWithInsensitiveAny?.map((e) => e).toList();
    }
    if (_$data.containsKey('notEqualTo')) {
      final l$notEqualTo = notEqualTo;
      result$data['notEqualTo'] = l$notEqualTo;
    }
    if (_$data.containsKey('notEqualToAll')) {
      final l$notEqualToAll = notEqualToAll;
      result$data['notEqualToAll'] = l$notEqualToAll?.map((e) => e).toList();
    }
    if (_$data.containsKey('notEqualToAny')) {
      final l$notEqualToAny = notEqualToAny;
      result$data['notEqualToAny'] = l$notEqualToAny?.map((e) => e).toList();
    }
    if (_$data.containsKey('notIn')) {
      final l$notIn = notIn;
      result$data['notIn'] = l$notIn?.map((e) => e).toList();
    }
    if (_$data.containsKey('notInInsensitive')) {
      final l$notInInsensitive = notInInsensitive;
      result$data['notInInsensitive'] =
          l$notInInsensitive?.map((e) => e).toList();
    }
    if (_$data.containsKey('notIncludes')) {
      final l$notIncludes = notIncludes;
      result$data['notIncludes'] = l$notIncludes;
    }
    if (_$data.containsKey('notIncludesAll')) {
      final l$notIncludesAll = notIncludesAll;
      result$data['notIncludesAll'] = l$notIncludesAll?.map((e) => e).toList();
    }
    if (_$data.containsKey('notIncludesAny')) {
      final l$notIncludesAny = notIncludesAny;
      result$data['notIncludesAny'] = l$notIncludesAny?.map((e) => e).toList();
    }
    if (_$data.containsKey('notIncludesInsensitive')) {
      final l$notIncludesInsensitive = notIncludesInsensitive;
      result$data['notIncludesInsensitive'] = l$notIncludesInsensitive;
    }
    if (_$data.containsKey('notIncludesInsensitiveAll')) {
      final l$notIncludesInsensitiveAll = notIncludesInsensitiveAll;
      result$data['notIncludesInsensitiveAll'] =
          l$notIncludesInsensitiveAll?.map((e) => e).toList();
    }
    if (_$data.containsKey('notIncludesInsensitiveAny')) {
      final l$notIncludesInsensitiveAny = notIncludesInsensitiveAny;
      result$data['notIncludesInsensitiveAny'] =
          l$notIncludesInsensitiveAny?.map((e) => e).toList();
    }
    if (_$data.containsKey('notLike')) {
      final l$notLike = notLike;
      result$data['notLike'] = l$notLike;
    }
    if (_$data.containsKey('notLikeAll')) {
      final l$notLikeAll = notLikeAll;
      result$data['notLikeAll'] = l$notLikeAll?.map((e) => e).toList();
    }
    if (_$data.containsKey('notLikeAny')) {
      final l$notLikeAny = notLikeAny;
      result$data['notLikeAny'] = l$notLikeAny?.map((e) => e).toList();
    }
    if (_$data.containsKey('notLikeInsensitive')) {
      final l$notLikeInsensitive = notLikeInsensitive;
      result$data['notLikeInsensitive'] = l$notLikeInsensitive;
    }
    if (_$data.containsKey('notLikeInsensitiveAll')) {
      final l$notLikeInsensitiveAll = notLikeInsensitiveAll;
      result$data['notLikeInsensitiveAll'] =
          l$notLikeInsensitiveAll?.map((e) => e).toList();
    }
    if (_$data.containsKey('notLikeInsensitiveAny')) {
      final l$notLikeInsensitiveAny = notLikeInsensitiveAny;
      result$data['notLikeInsensitiveAny'] =
          l$notLikeInsensitiveAny?.map((e) => e).toList();
    }
    if (_$data.containsKey('notStartsWith')) {
      final l$notStartsWith = notStartsWith;
      result$data['notStartsWith'] = l$notStartsWith;
    }
    if (_$data.containsKey('notStartsWithAll')) {
      final l$notStartsWithAll = notStartsWithAll;
      result$data['notStartsWithAll'] =
          l$notStartsWithAll?.map((e) => e).toList();
    }
    if (_$data.containsKey('notStartsWithAny')) {
      final l$notStartsWithAny = notStartsWithAny;
      result$data['notStartsWithAny'] =
          l$notStartsWithAny?.map((e) => e).toList();
    }
    if (_$data.containsKey('notStartsWithInsensitive')) {
      final l$notStartsWithInsensitive = notStartsWithInsensitive;
      result$data['notStartsWithInsensitive'] = l$notStartsWithInsensitive;
    }
    if (_$data.containsKey('notStartsWithInsensitiveAll')) {
      final l$notStartsWithInsensitiveAll = notStartsWithInsensitiveAll;
      result$data['notStartsWithInsensitiveAll'] =
          l$notStartsWithInsensitiveAll?.map((e) => e).toList();
    }
    if (_$data.containsKey('notStartsWithInsensitiveAny')) {
      final l$notStartsWithInsensitiveAny = notStartsWithInsensitiveAny;
      result$data['notStartsWithInsensitiveAny'] =
          l$notStartsWithInsensitiveAny?.map((e) => e).toList();
    }
    if (_$data.containsKey('startsWith')) {
      final l$startsWith = startsWith;
      result$data['startsWith'] = l$startsWith;
    }
    if (_$data.containsKey('startsWithAll')) {
      final l$startsWithAll = startsWithAll;
      result$data['startsWithAll'] = l$startsWithAll?.map((e) => e).toList();
    }
    if (_$data.containsKey('startsWithAny')) {
      final l$startsWithAny = startsWithAny;
      result$data['startsWithAny'] = l$startsWithAny?.map((e) => e).toList();
    }
    if (_$data.containsKey('startsWithInsensitive')) {
      final l$startsWithInsensitive = startsWithInsensitive;
      result$data['startsWithInsensitive'] = l$startsWithInsensitive;
    }
    if (_$data.containsKey('startsWithInsensitiveAll')) {
      final l$startsWithInsensitiveAll = startsWithInsensitiveAll;
      result$data['startsWithInsensitiveAll'] =
          l$startsWithInsensitiveAll?.map((e) => e).toList();
    }
    if (_$data.containsKey('startsWithInsensitiveAny')) {
      final l$startsWithInsensitiveAny = startsWithInsensitiveAny;
      result$data['startsWithInsensitiveAny'] =
          l$startsWithInsensitiveAny?.map((e) => e).toList();
    }
    return result$data;
  }

  CopyWith$Input$StringFilterInput<Input$StringFilterInput> get copyWith =>
      CopyWith$Input$StringFilterInput(
        this,
        (i) => i,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$StringFilterInput || runtimeType != other.runtimeType) {
      return false;
    }
    final l$distinctFrom = distinctFrom;
    final lOther$distinctFrom = other.distinctFrom;
    if (_$data.containsKey('distinctFrom') !=
        other._$data.containsKey('distinctFrom')) {
      return false;
    }
    if (l$distinctFrom != lOther$distinctFrom) {
      return false;
    }
    final l$distinctFromAll = distinctFromAll;
    final lOther$distinctFromAll = other.distinctFromAll;
    if (_$data.containsKey('distinctFromAll') !=
        other._$data.containsKey('distinctFromAll')) {
      return false;
    }
    if (l$distinctFromAll != null && lOther$distinctFromAll != null) {
      if (l$distinctFromAll.length != lOther$distinctFromAll.length) {
        return false;
      }
      for (int i = 0; i < l$distinctFromAll.length; i++) {
        final l$distinctFromAll$entry = l$distinctFromAll[i];
        final lOther$distinctFromAll$entry = lOther$distinctFromAll[i];
        if (l$distinctFromAll$entry != lOther$distinctFromAll$entry) {
          return false;
        }
      }
    } else if (l$distinctFromAll != lOther$distinctFromAll) {
      return false;
    }
    final l$distinctFromAny = distinctFromAny;
    final lOther$distinctFromAny = other.distinctFromAny;
    if (_$data.containsKey('distinctFromAny') !=
        other._$data.containsKey('distinctFromAny')) {
      return false;
    }
    if (l$distinctFromAny != null && lOther$distinctFromAny != null) {
      if (l$distinctFromAny.length != lOther$distinctFromAny.length) {
        return false;
      }
      for (int i = 0; i < l$distinctFromAny.length; i++) {
        final l$distinctFromAny$entry = l$distinctFromAny[i];
        final lOther$distinctFromAny$entry = lOther$distinctFromAny[i];
        if (l$distinctFromAny$entry != lOther$distinctFromAny$entry) {
          return false;
        }
      }
    } else if (l$distinctFromAny != lOther$distinctFromAny) {
      return false;
    }
    final l$distinctFromInsensitive = distinctFromInsensitive;
    final lOther$distinctFromInsensitive = other.distinctFromInsensitive;
    if (_$data.containsKey('distinctFromInsensitive') !=
        other._$data.containsKey('distinctFromInsensitive')) {
      return false;
    }
    if (l$distinctFromInsensitive != lOther$distinctFromInsensitive) {
      return false;
    }
    final l$distinctFromInsensitiveAll = distinctFromInsensitiveAll;
    final lOther$distinctFromInsensitiveAll = other.distinctFromInsensitiveAll;
    if (_$data.containsKey('distinctFromInsensitiveAll') !=
        other._$data.containsKey('distinctFromInsensitiveAll')) {
      return false;
    }
    if (l$distinctFromInsensitiveAll != null &&
        lOther$distinctFromInsensitiveAll != null) {
      if (l$distinctFromInsensitiveAll.length !=
          lOther$distinctFromInsensitiveAll.length) {
        return false;
      }
      for (int i = 0; i < l$distinctFromInsensitiveAll.length; i++) {
        final l$distinctFromInsensitiveAll$entry =
            l$distinctFromInsensitiveAll[i];
        final lOther$distinctFromInsensitiveAll$entry =
            lOther$distinctFromInsensitiveAll[i];
        if (l$distinctFromInsensitiveAll$entry !=
            lOther$distinctFromInsensitiveAll$entry) {
          return false;
        }
      }
    } else if (l$distinctFromInsensitiveAll !=
        lOther$distinctFromInsensitiveAll) {
      return false;
    }
    final l$distinctFromInsensitiveAny = distinctFromInsensitiveAny;
    final lOther$distinctFromInsensitiveAny = other.distinctFromInsensitiveAny;
    if (_$data.containsKey('distinctFromInsensitiveAny') !=
        other._$data.containsKey('distinctFromInsensitiveAny')) {
      return false;
    }
    if (l$distinctFromInsensitiveAny != null &&
        lOther$distinctFromInsensitiveAny != null) {
      if (l$distinctFromInsensitiveAny.length !=
          lOther$distinctFromInsensitiveAny.length) {
        return false;
      }
      for (int i = 0; i < l$distinctFromInsensitiveAny.length; i++) {
        final l$distinctFromInsensitiveAny$entry =
            l$distinctFromInsensitiveAny[i];
        final lOther$distinctFromInsensitiveAny$entry =
            lOther$distinctFromInsensitiveAny[i];
        if (l$distinctFromInsensitiveAny$entry !=
            lOther$distinctFromInsensitiveAny$entry) {
          return false;
        }
      }
    } else if (l$distinctFromInsensitiveAny !=
        lOther$distinctFromInsensitiveAny) {
      return false;
    }
    final l$endsWith = endsWith;
    final lOther$endsWith = other.endsWith;
    if (_$data.containsKey('endsWith') !=
        other._$data.containsKey('endsWith')) {
      return false;
    }
    if (l$endsWith != lOther$endsWith) {
      return false;
    }
    final l$endsWithAll = endsWithAll;
    final lOther$endsWithAll = other.endsWithAll;
    if (_$data.containsKey('endsWithAll') !=
        other._$data.containsKey('endsWithAll')) {
      return false;
    }
    if (l$endsWithAll != null && lOther$endsWithAll != null) {
      if (l$endsWithAll.length != lOther$endsWithAll.length) {
        return false;
      }
      for (int i = 0; i < l$endsWithAll.length; i++) {
        final l$endsWithAll$entry = l$endsWithAll[i];
        final lOther$endsWithAll$entry = lOther$endsWithAll[i];
        if (l$endsWithAll$entry != lOther$endsWithAll$entry) {
          return false;
        }
      }
    } else if (l$endsWithAll != lOther$endsWithAll) {
      return false;
    }
    final l$endsWithAny = endsWithAny;
    final lOther$endsWithAny = other.endsWithAny;
    if (_$data.containsKey('endsWithAny') !=
        other._$data.containsKey('endsWithAny')) {
      return false;
    }
    if (l$endsWithAny != null && lOther$endsWithAny != null) {
      if (l$endsWithAny.length != lOther$endsWithAny.length) {
        return false;
      }
      for (int i = 0; i < l$endsWithAny.length; i++) {
        final l$endsWithAny$entry = l$endsWithAny[i];
        final lOther$endsWithAny$entry = lOther$endsWithAny[i];
        if (l$endsWithAny$entry != lOther$endsWithAny$entry) {
          return false;
        }
      }
    } else if (l$endsWithAny != lOther$endsWithAny) {
      return false;
    }
    final l$endsWithInsensitive = endsWithInsensitive;
    final lOther$endsWithInsensitive = other.endsWithInsensitive;
    if (_$data.containsKey('endsWithInsensitive') !=
        other._$data.containsKey('endsWithInsensitive')) {
      return false;
    }
    if (l$endsWithInsensitive != lOther$endsWithInsensitive) {
      return false;
    }
    final l$endsWithInsensitiveAll = endsWithInsensitiveAll;
    final lOther$endsWithInsensitiveAll = other.endsWithInsensitiveAll;
    if (_$data.containsKey('endsWithInsensitiveAll') !=
        other._$data.containsKey('endsWithInsensitiveAll')) {
      return false;
    }
    if (l$endsWithInsensitiveAll != null &&
        lOther$endsWithInsensitiveAll != null) {
      if (l$endsWithInsensitiveAll.length !=
          lOther$endsWithInsensitiveAll.length) {
        return false;
      }
      for (int i = 0; i < l$endsWithInsensitiveAll.length; i++) {
        final l$endsWithInsensitiveAll$entry = l$endsWithInsensitiveAll[i];
        final lOther$endsWithInsensitiveAll$entry =
            lOther$endsWithInsensitiveAll[i];
        if (l$endsWithInsensitiveAll$entry !=
            lOther$endsWithInsensitiveAll$entry) {
          return false;
        }
      }
    } else if (l$endsWithInsensitiveAll != lOther$endsWithInsensitiveAll) {
      return false;
    }
    final l$endsWithInsensitiveAny = endsWithInsensitiveAny;
    final lOther$endsWithInsensitiveAny = other.endsWithInsensitiveAny;
    if (_$data.containsKey('endsWithInsensitiveAny') !=
        other._$data.containsKey('endsWithInsensitiveAny')) {
      return false;
    }
    if (l$endsWithInsensitiveAny != null &&
        lOther$endsWithInsensitiveAny != null) {
      if (l$endsWithInsensitiveAny.length !=
          lOther$endsWithInsensitiveAny.length) {
        return false;
      }
      for (int i = 0; i < l$endsWithInsensitiveAny.length; i++) {
        final l$endsWithInsensitiveAny$entry = l$endsWithInsensitiveAny[i];
        final lOther$endsWithInsensitiveAny$entry =
            lOther$endsWithInsensitiveAny[i];
        if (l$endsWithInsensitiveAny$entry !=
            lOther$endsWithInsensitiveAny$entry) {
          return false;
        }
      }
    } else if (l$endsWithInsensitiveAny != lOther$endsWithInsensitiveAny) {
      return false;
    }
    final l$equalTo = equalTo;
    final lOther$equalTo = other.equalTo;
    if (_$data.containsKey('equalTo') != other._$data.containsKey('equalTo')) {
      return false;
    }
    if (l$equalTo != lOther$equalTo) {
      return false;
    }
    final l$greaterThan = greaterThan;
    final lOther$greaterThan = other.greaterThan;
    if (_$data.containsKey('greaterThan') !=
        other._$data.containsKey('greaterThan')) {
      return false;
    }
    if (l$greaterThan != lOther$greaterThan) {
      return false;
    }
    final l$greaterThanInsensitive = greaterThanInsensitive;
    final lOther$greaterThanInsensitive = other.greaterThanInsensitive;
    if (_$data.containsKey('greaterThanInsensitive') !=
        other._$data.containsKey('greaterThanInsensitive')) {
      return false;
    }
    if (l$greaterThanInsensitive != lOther$greaterThanInsensitive) {
      return false;
    }
    final l$greaterThanOrEqualTo = greaterThanOrEqualTo;
    final lOther$greaterThanOrEqualTo = other.greaterThanOrEqualTo;
    if (_$data.containsKey('greaterThanOrEqualTo') !=
        other._$data.containsKey('greaterThanOrEqualTo')) {
      return false;
    }
    if (l$greaterThanOrEqualTo != lOther$greaterThanOrEqualTo) {
      return false;
    }
    final l$greaterThanOrEqualToInsensitive = greaterThanOrEqualToInsensitive;
    final lOther$greaterThanOrEqualToInsensitive =
        other.greaterThanOrEqualToInsensitive;
    if (_$data.containsKey('greaterThanOrEqualToInsensitive') !=
        other._$data.containsKey('greaterThanOrEqualToInsensitive')) {
      return false;
    }
    if (l$greaterThanOrEqualToInsensitive !=
        lOther$greaterThanOrEqualToInsensitive) {
      return false;
    }
    final l$$in = $in;
    final lOther$$in = other.$in;
    if (_$data.containsKey('in') != other._$data.containsKey('in')) {
      return false;
    }
    if (l$$in != null && lOther$$in != null) {
      if (l$$in.length != lOther$$in.length) {
        return false;
      }
      for (int i = 0; i < l$$in.length; i++) {
        final l$$in$entry = l$$in[i];
        final lOther$$in$entry = lOther$$in[i];
        if (l$$in$entry != lOther$$in$entry) {
          return false;
        }
      }
    } else if (l$$in != lOther$$in) {
      return false;
    }
    final l$inInsensitive = inInsensitive;
    final lOther$inInsensitive = other.inInsensitive;
    if (_$data.containsKey('inInsensitive') !=
        other._$data.containsKey('inInsensitive')) {
      return false;
    }
    if (l$inInsensitive != null && lOther$inInsensitive != null) {
      if (l$inInsensitive.length != lOther$inInsensitive.length) {
        return false;
      }
      for (int i = 0; i < l$inInsensitive.length; i++) {
        final l$inInsensitive$entry = l$inInsensitive[i];
        final lOther$inInsensitive$entry = lOther$inInsensitive[i];
        if (l$inInsensitive$entry != lOther$inInsensitive$entry) {
          return false;
        }
      }
    } else if (l$inInsensitive != lOther$inInsensitive) {
      return false;
    }
    final l$includes = includes;
    final lOther$includes = other.includes;
    if (_$data.containsKey('includes') !=
        other._$data.containsKey('includes')) {
      return false;
    }
    if (l$includes != lOther$includes) {
      return false;
    }
    final l$includesAll = includesAll;
    final lOther$includesAll = other.includesAll;
    if (_$data.containsKey('includesAll') !=
        other._$data.containsKey('includesAll')) {
      return false;
    }
    if (l$includesAll != null && lOther$includesAll != null) {
      if (l$includesAll.length != lOther$includesAll.length) {
        return false;
      }
      for (int i = 0; i < l$includesAll.length; i++) {
        final l$includesAll$entry = l$includesAll[i];
        final lOther$includesAll$entry = lOther$includesAll[i];
        if (l$includesAll$entry != lOther$includesAll$entry) {
          return false;
        }
      }
    } else if (l$includesAll != lOther$includesAll) {
      return false;
    }
    final l$includesAny = includesAny;
    final lOther$includesAny = other.includesAny;
    if (_$data.containsKey('includesAny') !=
        other._$data.containsKey('includesAny')) {
      return false;
    }
    if (l$includesAny != null && lOther$includesAny != null) {
      if (l$includesAny.length != lOther$includesAny.length) {
        return false;
      }
      for (int i = 0; i < l$includesAny.length; i++) {
        final l$includesAny$entry = l$includesAny[i];
        final lOther$includesAny$entry = lOther$includesAny[i];
        if (l$includesAny$entry != lOther$includesAny$entry) {
          return false;
        }
      }
    } else if (l$includesAny != lOther$includesAny) {
      return false;
    }
    final l$includesInsensitive = includesInsensitive;
    final lOther$includesInsensitive = other.includesInsensitive;
    if (_$data.containsKey('includesInsensitive') !=
        other._$data.containsKey('includesInsensitive')) {
      return false;
    }
    if (l$includesInsensitive != lOther$includesInsensitive) {
      return false;
    }
    final l$includesInsensitiveAll = includesInsensitiveAll;
    final lOther$includesInsensitiveAll = other.includesInsensitiveAll;
    if (_$data.containsKey('includesInsensitiveAll') !=
        other._$data.containsKey('includesInsensitiveAll')) {
      return false;
    }
    if (l$includesInsensitiveAll != null &&
        lOther$includesInsensitiveAll != null) {
      if (l$includesInsensitiveAll.length !=
          lOther$includesInsensitiveAll.length) {
        return false;
      }
      for (int i = 0; i < l$includesInsensitiveAll.length; i++) {
        final l$includesInsensitiveAll$entry = l$includesInsensitiveAll[i];
        final lOther$includesInsensitiveAll$entry =
            lOther$includesInsensitiveAll[i];
        if (l$includesInsensitiveAll$entry !=
            lOther$includesInsensitiveAll$entry) {
          return false;
        }
      }
    } else if (l$includesInsensitiveAll != lOther$includesInsensitiveAll) {
      return false;
    }
    final l$includesInsensitiveAny = includesInsensitiveAny;
    final lOther$includesInsensitiveAny = other.includesInsensitiveAny;
    if (_$data.containsKey('includesInsensitiveAny') !=
        other._$data.containsKey('includesInsensitiveAny')) {
      return false;
    }
    if (l$includesInsensitiveAny != null &&
        lOther$includesInsensitiveAny != null) {
      if (l$includesInsensitiveAny.length !=
          lOther$includesInsensitiveAny.length) {
        return false;
      }
      for (int i = 0; i < l$includesInsensitiveAny.length; i++) {
        final l$includesInsensitiveAny$entry = l$includesInsensitiveAny[i];
        final lOther$includesInsensitiveAny$entry =
            lOther$includesInsensitiveAny[i];
        if (l$includesInsensitiveAny$entry !=
            lOther$includesInsensitiveAny$entry) {
          return false;
        }
      }
    } else if (l$includesInsensitiveAny != lOther$includesInsensitiveAny) {
      return false;
    }
    final l$isNull = isNull;
    final lOther$isNull = other.isNull;
    if (_$data.containsKey('isNull') != other._$data.containsKey('isNull')) {
      return false;
    }
    if (l$isNull != lOther$isNull) {
      return false;
    }
    final l$lessThan = lessThan;
    final lOther$lessThan = other.lessThan;
    if (_$data.containsKey('lessThan') !=
        other._$data.containsKey('lessThan')) {
      return false;
    }
    if (l$lessThan != lOther$lessThan) {
      return false;
    }
    final l$lessThanInsensitive = lessThanInsensitive;
    final lOther$lessThanInsensitive = other.lessThanInsensitive;
    if (_$data.containsKey('lessThanInsensitive') !=
        other._$data.containsKey('lessThanInsensitive')) {
      return false;
    }
    if (l$lessThanInsensitive != lOther$lessThanInsensitive) {
      return false;
    }
    final l$lessThanOrEqualTo = lessThanOrEqualTo;
    final lOther$lessThanOrEqualTo = other.lessThanOrEqualTo;
    if (_$data.containsKey('lessThanOrEqualTo') !=
        other._$data.containsKey('lessThanOrEqualTo')) {
      return false;
    }
    if (l$lessThanOrEqualTo != lOther$lessThanOrEqualTo) {
      return false;
    }
    final l$lessThanOrEqualToInsensitive = lessThanOrEqualToInsensitive;
    final lOther$lessThanOrEqualToInsensitive =
        other.lessThanOrEqualToInsensitive;
    if (_$data.containsKey('lessThanOrEqualToInsensitive') !=
        other._$data.containsKey('lessThanOrEqualToInsensitive')) {
      return false;
    }
    if (l$lessThanOrEqualToInsensitive != lOther$lessThanOrEqualToInsensitive) {
      return false;
    }
    final l$like = like;
    final lOther$like = other.like;
    if (_$data.containsKey('like') != other._$data.containsKey('like')) {
      return false;
    }
    if (l$like != lOther$like) {
      return false;
    }
    final l$likeAll = likeAll;
    final lOther$likeAll = other.likeAll;
    if (_$data.containsKey('likeAll') != other._$data.containsKey('likeAll')) {
      return false;
    }
    if (l$likeAll != null && lOther$likeAll != null) {
      if (l$likeAll.length != lOther$likeAll.length) {
        return false;
      }
      for (int i = 0; i < l$likeAll.length; i++) {
        final l$likeAll$entry = l$likeAll[i];
        final lOther$likeAll$entry = lOther$likeAll[i];
        if (l$likeAll$entry != lOther$likeAll$entry) {
          return false;
        }
      }
    } else if (l$likeAll != lOther$likeAll) {
      return false;
    }
    final l$likeAny = likeAny;
    final lOther$likeAny = other.likeAny;
    if (_$data.containsKey('likeAny') != other._$data.containsKey('likeAny')) {
      return false;
    }
    if (l$likeAny != null && lOther$likeAny != null) {
      if (l$likeAny.length != lOther$likeAny.length) {
        return false;
      }
      for (int i = 0; i < l$likeAny.length; i++) {
        final l$likeAny$entry = l$likeAny[i];
        final lOther$likeAny$entry = lOther$likeAny[i];
        if (l$likeAny$entry != lOther$likeAny$entry) {
          return false;
        }
      }
    } else if (l$likeAny != lOther$likeAny) {
      return false;
    }
    final l$likeInsensitive = likeInsensitive;
    final lOther$likeInsensitive = other.likeInsensitive;
    if (_$data.containsKey('likeInsensitive') !=
        other._$data.containsKey('likeInsensitive')) {
      return false;
    }
    if (l$likeInsensitive != lOther$likeInsensitive) {
      return false;
    }
    final l$likeInsensitiveAll = likeInsensitiveAll;
    final lOther$likeInsensitiveAll = other.likeInsensitiveAll;
    if (_$data.containsKey('likeInsensitiveAll') !=
        other._$data.containsKey('likeInsensitiveAll')) {
      return false;
    }
    if (l$likeInsensitiveAll != null && lOther$likeInsensitiveAll != null) {
      if (l$likeInsensitiveAll.length != lOther$likeInsensitiveAll.length) {
        return false;
      }
      for (int i = 0; i < l$likeInsensitiveAll.length; i++) {
        final l$likeInsensitiveAll$entry = l$likeInsensitiveAll[i];
        final lOther$likeInsensitiveAll$entry = lOther$likeInsensitiveAll[i];
        if (l$likeInsensitiveAll$entry != lOther$likeInsensitiveAll$entry) {
          return false;
        }
      }
    } else if (l$likeInsensitiveAll != lOther$likeInsensitiveAll) {
      return false;
    }
    final l$likeInsensitiveAny = likeInsensitiveAny;
    final lOther$likeInsensitiveAny = other.likeInsensitiveAny;
    if (_$data.containsKey('likeInsensitiveAny') !=
        other._$data.containsKey('likeInsensitiveAny')) {
      return false;
    }
    if (l$likeInsensitiveAny != null && lOther$likeInsensitiveAny != null) {
      if (l$likeInsensitiveAny.length != lOther$likeInsensitiveAny.length) {
        return false;
      }
      for (int i = 0; i < l$likeInsensitiveAny.length; i++) {
        final l$likeInsensitiveAny$entry = l$likeInsensitiveAny[i];
        final lOther$likeInsensitiveAny$entry = lOther$likeInsensitiveAny[i];
        if (l$likeInsensitiveAny$entry != lOther$likeInsensitiveAny$entry) {
          return false;
        }
      }
    } else if (l$likeInsensitiveAny != lOther$likeInsensitiveAny) {
      return false;
    }
    final l$notDistinctFrom = notDistinctFrom;
    final lOther$notDistinctFrom = other.notDistinctFrom;
    if (_$data.containsKey('notDistinctFrom') !=
        other._$data.containsKey('notDistinctFrom')) {
      return false;
    }
    if (l$notDistinctFrom != lOther$notDistinctFrom) {
      return false;
    }
    final l$notDistinctFromInsensitive = notDistinctFromInsensitive;
    final lOther$notDistinctFromInsensitive = other.notDistinctFromInsensitive;
    if (_$data.containsKey('notDistinctFromInsensitive') !=
        other._$data.containsKey('notDistinctFromInsensitive')) {
      return false;
    }
    if (l$notDistinctFromInsensitive != lOther$notDistinctFromInsensitive) {
      return false;
    }
    final l$notEndsWith = notEndsWith;
    final lOther$notEndsWith = other.notEndsWith;
    if (_$data.containsKey('notEndsWith') !=
        other._$data.containsKey('notEndsWith')) {
      return false;
    }
    if (l$notEndsWith != lOther$notEndsWith) {
      return false;
    }
    final l$notEndsWithAll = notEndsWithAll;
    final lOther$notEndsWithAll = other.notEndsWithAll;
    if (_$data.containsKey('notEndsWithAll') !=
        other._$data.containsKey('notEndsWithAll')) {
      return false;
    }
    if (l$notEndsWithAll != null && lOther$notEndsWithAll != null) {
      if (l$notEndsWithAll.length != lOther$notEndsWithAll.length) {
        return false;
      }
      for (int i = 0; i < l$notEndsWithAll.length; i++) {
        final l$notEndsWithAll$entry = l$notEndsWithAll[i];
        final lOther$notEndsWithAll$entry = lOther$notEndsWithAll[i];
        if (l$notEndsWithAll$entry != lOther$notEndsWithAll$entry) {
          return false;
        }
      }
    } else if (l$notEndsWithAll != lOther$notEndsWithAll) {
      return false;
    }
    final l$notEndsWithAny = notEndsWithAny;
    final lOther$notEndsWithAny = other.notEndsWithAny;
    if (_$data.containsKey('notEndsWithAny') !=
        other._$data.containsKey('notEndsWithAny')) {
      return false;
    }
    if (l$notEndsWithAny != null && lOther$notEndsWithAny != null) {
      if (l$notEndsWithAny.length != lOther$notEndsWithAny.length) {
        return false;
      }
      for (int i = 0; i < l$notEndsWithAny.length; i++) {
        final l$notEndsWithAny$entry = l$notEndsWithAny[i];
        final lOther$notEndsWithAny$entry = lOther$notEndsWithAny[i];
        if (l$notEndsWithAny$entry != lOther$notEndsWithAny$entry) {
          return false;
        }
      }
    } else if (l$notEndsWithAny != lOther$notEndsWithAny) {
      return false;
    }
    final l$notEndsWithInsensitive = notEndsWithInsensitive;
    final lOther$notEndsWithInsensitive = other.notEndsWithInsensitive;
    if (_$data.containsKey('notEndsWithInsensitive') !=
        other._$data.containsKey('notEndsWithInsensitive')) {
      return false;
    }
    if (l$notEndsWithInsensitive != lOther$notEndsWithInsensitive) {
      return false;
    }
    final l$notEndsWithInsensitiveAll = notEndsWithInsensitiveAll;
    final lOther$notEndsWithInsensitiveAll = other.notEndsWithInsensitiveAll;
    if (_$data.containsKey('notEndsWithInsensitiveAll') !=
        other._$data.containsKey('notEndsWithInsensitiveAll')) {
      return false;
    }
    if (l$notEndsWithInsensitiveAll != null &&
        lOther$notEndsWithInsensitiveAll != null) {
      if (l$notEndsWithInsensitiveAll.length !=
          lOther$notEndsWithInsensitiveAll.length) {
        return false;
      }
      for (int i = 0; i < l$notEndsWithInsensitiveAll.length; i++) {
        final l$notEndsWithInsensitiveAll$entry =
            l$notEndsWithInsensitiveAll[i];
        final lOther$notEndsWithInsensitiveAll$entry =
            lOther$notEndsWithInsensitiveAll[i];
        if (l$notEndsWithInsensitiveAll$entry !=
            lOther$notEndsWithInsensitiveAll$entry) {
          return false;
        }
      }
    } else if (l$notEndsWithInsensitiveAll !=
        lOther$notEndsWithInsensitiveAll) {
      return false;
    }
    final l$notEndsWithInsensitiveAny = notEndsWithInsensitiveAny;
    final lOther$notEndsWithInsensitiveAny = other.notEndsWithInsensitiveAny;
    if (_$data.containsKey('notEndsWithInsensitiveAny') !=
        other._$data.containsKey('notEndsWithInsensitiveAny')) {
      return false;
    }
    if (l$notEndsWithInsensitiveAny != null &&
        lOther$notEndsWithInsensitiveAny != null) {
      if (l$notEndsWithInsensitiveAny.length !=
          lOther$notEndsWithInsensitiveAny.length) {
        return false;
      }
      for (int i = 0; i < l$notEndsWithInsensitiveAny.length; i++) {
        final l$notEndsWithInsensitiveAny$entry =
            l$notEndsWithInsensitiveAny[i];
        final lOther$notEndsWithInsensitiveAny$entry =
            lOther$notEndsWithInsensitiveAny[i];
        if (l$notEndsWithInsensitiveAny$entry !=
            lOther$notEndsWithInsensitiveAny$entry) {
          return false;
        }
      }
    } else if (l$notEndsWithInsensitiveAny !=
        lOther$notEndsWithInsensitiveAny) {
      return false;
    }
    final l$notEqualTo = notEqualTo;
    final lOther$notEqualTo = other.notEqualTo;
    if (_$data.containsKey('notEqualTo') !=
        other._$data.containsKey('notEqualTo')) {
      return false;
    }
    if (l$notEqualTo != lOther$notEqualTo) {
      return false;
    }
    final l$notEqualToAll = notEqualToAll;
    final lOther$notEqualToAll = other.notEqualToAll;
    if (_$data.containsKey('notEqualToAll') !=
        other._$data.containsKey('notEqualToAll')) {
      return false;
    }
    if (l$notEqualToAll != null && lOther$notEqualToAll != null) {
      if (l$notEqualToAll.length != lOther$notEqualToAll.length) {
        return false;
      }
      for (int i = 0; i < l$notEqualToAll.length; i++) {
        final l$notEqualToAll$entry = l$notEqualToAll[i];
        final lOther$notEqualToAll$entry = lOther$notEqualToAll[i];
        if (l$notEqualToAll$entry != lOther$notEqualToAll$entry) {
          return false;
        }
      }
    } else if (l$notEqualToAll != lOther$notEqualToAll) {
      return false;
    }
    final l$notEqualToAny = notEqualToAny;
    final lOther$notEqualToAny = other.notEqualToAny;
    if (_$data.containsKey('notEqualToAny') !=
        other._$data.containsKey('notEqualToAny')) {
      return false;
    }
    if (l$notEqualToAny != null && lOther$notEqualToAny != null) {
      if (l$notEqualToAny.length != lOther$notEqualToAny.length) {
        return false;
      }
      for (int i = 0; i < l$notEqualToAny.length; i++) {
        final l$notEqualToAny$entry = l$notEqualToAny[i];
        final lOther$notEqualToAny$entry = lOther$notEqualToAny[i];
        if (l$notEqualToAny$entry != lOther$notEqualToAny$entry) {
          return false;
        }
      }
    } else if (l$notEqualToAny != lOther$notEqualToAny) {
      return false;
    }
    final l$notIn = notIn;
    final lOther$notIn = other.notIn;
    if (_$data.containsKey('notIn') != other._$data.containsKey('notIn')) {
      return false;
    }
    if (l$notIn != null && lOther$notIn != null) {
      if (l$notIn.length != lOther$notIn.length) {
        return false;
      }
      for (int i = 0; i < l$notIn.length; i++) {
        final l$notIn$entry = l$notIn[i];
        final lOther$notIn$entry = lOther$notIn[i];
        if (l$notIn$entry != lOther$notIn$entry) {
          return false;
        }
      }
    } else if (l$notIn != lOther$notIn) {
      return false;
    }
    final l$notInInsensitive = notInInsensitive;
    final lOther$notInInsensitive = other.notInInsensitive;
    if (_$data.containsKey('notInInsensitive') !=
        other._$data.containsKey('notInInsensitive')) {
      return false;
    }
    if (l$notInInsensitive != null && lOther$notInInsensitive != null) {
      if (l$notInInsensitive.length != lOther$notInInsensitive.length) {
        return false;
      }
      for (int i = 0; i < l$notInInsensitive.length; i++) {
        final l$notInInsensitive$entry = l$notInInsensitive[i];
        final lOther$notInInsensitive$entry = lOther$notInInsensitive[i];
        if (l$notInInsensitive$entry != lOther$notInInsensitive$entry) {
          return false;
        }
      }
    } else if (l$notInInsensitive != lOther$notInInsensitive) {
      return false;
    }
    final l$notIncludes = notIncludes;
    final lOther$notIncludes = other.notIncludes;
    if (_$data.containsKey('notIncludes') !=
        other._$data.containsKey('notIncludes')) {
      return false;
    }
    if (l$notIncludes != lOther$notIncludes) {
      return false;
    }
    final l$notIncludesAll = notIncludesAll;
    final lOther$notIncludesAll = other.notIncludesAll;
    if (_$data.containsKey('notIncludesAll') !=
        other._$data.containsKey('notIncludesAll')) {
      return false;
    }
    if (l$notIncludesAll != null && lOther$notIncludesAll != null) {
      if (l$notIncludesAll.length != lOther$notIncludesAll.length) {
        return false;
      }
      for (int i = 0; i < l$notIncludesAll.length; i++) {
        final l$notIncludesAll$entry = l$notIncludesAll[i];
        final lOther$notIncludesAll$entry = lOther$notIncludesAll[i];
        if (l$notIncludesAll$entry != lOther$notIncludesAll$entry) {
          return false;
        }
      }
    } else if (l$notIncludesAll != lOther$notIncludesAll) {
      return false;
    }
    final l$notIncludesAny = notIncludesAny;
    final lOther$notIncludesAny = other.notIncludesAny;
    if (_$data.containsKey('notIncludesAny') !=
        other._$data.containsKey('notIncludesAny')) {
      return false;
    }
    if (l$notIncludesAny != null && lOther$notIncludesAny != null) {
      if (l$notIncludesAny.length != lOther$notIncludesAny.length) {
        return false;
      }
      for (int i = 0; i < l$notIncludesAny.length; i++) {
        final l$notIncludesAny$entry = l$notIncludesAny[i];
        final lOther$notIncludesAny$entry = lOther$notIncludesAny[i];
        if (l$notIncludesAny$entry != lOther$notIncludesAny$entry) {
          return false;
        }
      }
    } else if (l$notIncludesAny != lOther$notIncludesAny) {
      return false;
    }
    final l$notIncludesInsensitive = notIncludesInsensitive;
    final lOther$notIncludesInsensitive = other.notIncludesInsensitive;
    if (_$data.containsKey('notIncludesInsensitive') !=
        other._$data.containsKey('notIncludesInsensitive')) {
      return false;
    }
    if (l$notIncludesInsensitive != lOther$notIncludesInsensitive) {
      return false;
    }
    final l$notIncludesInsensitiveAll = notIncludesInsensitiveAll;
    final lOther$notIncludesInsensitiveAll = other.notIncludesInsensitiveAll;
    if (_$data.containsKey('notIncludesInsensitiveAll') !=
        other._$data.containsKey('notIncludesInsensitiveAll')) {
      return false;
    }
    if (l$notIncludesInsensitiveAll != null &&
        lOther$notIncludesInsensitiveAll != null) {
      if (l$notIncludesInsensitiveAll.length !=
          lOther$notIncludesInsensitiveAll.length) {
        return false;
      }
      for (int i = 0; i < l$notIncludesInsensitiveAll.length; i++) {
        final l$notIncludesInsensitiveAll$entry =
            l$notIncludesInsensitiveAll[i];
        final lOther$notIncludesInsensitiveAll$entry =
            lOther$notIncludesInsensitiveAll[i];
        if (l$notIncludesInsensitiveAll$entry !=
            lOther$notIncludesInsensitiveAll$entry) {
          return false;
        }
      }
    } else if (l$notIncludesInsensitiveAll !=
        lOther$notIncludesInsensitiveAll) {
      return false;
    }
    final l$notIncludesInsensitiveAny = notIncludesInsensitiveAny;
    final lOther$notIncludesInsensitiveAny = other.notIncludesInsensitiveAny;
    if (_$data.containsKey('notIncludesInsensitiveAny') !=
        other._$data.containsKey('notIncludesInsensitiveAny')) {
      return false;
    }
    if (l$notIncludesInsensitiveAny != null &&
        lOther$notIncludesInsensitiveAny != null) {
      if (l$notIncludesInsensitiveAny.length !=
          lOther$notIncludesInsensitiveAny.length) {
        return false;
      }
      for (int i = 0; i < l$notIncludesInsensitiveAny.length; i++) {
        final l$notIncludesInsensitiveAny$entry =
            l$notIncludesInsensitiveAny[i];
        final lOther$notIncludesInsensitiveAny$entry =
            lOther$notIncludesInsensitiveAny[i];
        if (l$notIncludesInsensitiveAny$entry !=
            lOther$notIncludesInsensitiveAny$entry) {
          return false;
        }
      }
    } else if (l$notIncludesInsensitiveAny !=
        lOther$notIncludesInsensitiveAny) {
      return false;
    }
    final l$notLike = notLike;
    final lOther$notLike = other.notLike;
    if (_$data.containsKey('notLike') != other._$data.containsKey('notLike')) {
      return false;
    }
    if (l$notLike != lOther$notLike) {
      return false;
    }
    final l$notLikeAll = notLikeAll;
    final lOther$notLikeAll = other.notLikeAll;
    if (_$data.containsKey('notLikeAll') !=
        other._$data.containsKey('notLikeAll')) {
      return false;
    }
    if (l$notLikeAll != null && lOther$notLikeAll != null) {
      if (l$notLikeAll.length != lOther$notLikeAll.length) {
        return false;
      }
      for (int i = 0; i < l$notLikeAll.length; i++) {
        final l$notLikeAll$entry = l$notLikeAll[i];
        final lOther$notLikeAll$entry = lOther$notLikeAll[i];
        if (l$notLikeAll$entry != lOther$notLikeAll$entry) {
          return false;
        }
      }
    } else if (l$notLikeAll != lOther$notLikeAll) {
      return false;
    }
    final l$notLikeAny = notLikeAny;
    final lOther$notLikeAny = other.notLikeAny;
    if (_$data.containsKey('notLikeAny') !=
        other._$data.containsKey('notLikeAny')) {
      return false;
    }
    if (l$notLikeAny != null && lOther$notLikeAny != null) {
      if (l$notLikeAny.length != lOther$notLikeAny.length) {
        return false;
      }
      for (int i = 0; i < l$notLikeAny.length; i++) {
        final l$notLikeAny$entry = l$notLikeAny[i];
        final lOther$notLikeAny$entry = lOther$notLikeAny[i];
        if (l$notLikeAny$entry != lOther$notLikeAny$entry) {
          return false;
        }
      }
    } else if (l$notLikeAny != lOther$notLikeAny) {
      return false;
    }
    final l$notLikeInsensitive = notLikeInsensitive;
    final lOther$notLikeInsensitive = other.notLikeInsensitive;
    if (_$data.containsKey('notLikeInsensitive') !=
        other._$data.containsKey('notLikeInsensitive')) {
      return false;
    }
    if (l$notLikeInsensitive != lOther$notLikeInsensitive) {
      return false;
    }
    final l$notLikeInsensitiveAll = notLikeInsensitiveAll;
    final lOther$notLikeInsensitiveAll = other.notLikeInsensitiveAll;
    if (_$data.containsKey('notLikeInsensitiveAll') !=
        other._$data.containsKey('notLikeInsensitiveAll')) {
      return false;
    }
    if (l$notLikeInsensitiveAll != null &&
        lOther$notLikeInsensitiveAll != null) {
      if (l$notLikeInsensitiveAll.length !=
          lOther$notLikeInsensitiveAll.length) {
        return false;
      }
      for (int i = 0; i < l$notLikeInsensitiveAll.length; i++) {
        final l$notLikeInsensitiveAll$entry = l$notLikeInsensitiveAll[i];
        final lOther$notLikeInsensitiveAll$entry =
            lOther$notLikeInsensitiveAll[i];
        if (l$notLikeInsensitiveAll$entry !=
            lOther$notLikeInsensitiveAll$entry) {
          return false;
        }
      }
    } else if (l$notLikeInsensitiveAll != lOther$notLikeInsensitiveAll) {
      return false;
    }
    final l$notLikeInsensitiveAny = notLikeInsensitiveAny;
    final lOther$notLikeInsensitiveAny = other.notLikeInsensitiveAny;
    if (_$data.containsKey('notLikeInsensitiveAny') !=
        other._$data.containsKey('notLikeInsensitiveAny')) {
      return false;
    }
    if (l$notLikeInsensitiveAny != null &&
        lOther$notLikeInsensitiveAny != null) {
      if (l$notLikeInsensitiveAny.length !=
          lOther$notLikeInsensitiveAny.length) {
        return false;
      }
      for (int i = 0; i < l$notLikeInsensitiveAny.length; i++) {
        final l$notLikeInsensitiveAny$entry = l$notLikeInsensitiveAny[i];
        final lOther$notLikeInsensitiveAny$entry =
            lOther$notLikeInsensitiveAny[i];
        if (l$notLikeInsensitiveAny$entry !=
            lOther$notLikeInsensitiveAny$entry) {
          return false;
        }
      }
    } else if (l$notLikeInsensitiveAny != lOther$notLikeInsensitiveAny) {
      return false;
    }
    final l$notStartsWith = notStartsWith;
    final lOther$notStartsWith = other.notStartsWith;
    if (_$data.containsKey('notStartsWith') !=
        other._$data.containsKey('notStartsWith')) {
      return false;
    }
    if (l$notStartsWith != lOther$notStartsWith) {
      return false;
    }
    final l$notStartsWithAll = notStartsWithAll;
    final lOther$notStartsWithAll = other.notStartsWithAll;
    if (_$data.containsKey('notStartsWithAll') !=
        other._$data.containsKey('notStartsWithAll')) {
      return false;
    }
    if (l$notStartsWithAll != null && lOther$notStartsWithAll != null) {
      if (l$notStartsWithAll.length != lOther$notStartsWithAll.length) {
        return false;
      }
      for (int i = 0; i < l$notStartsWithAll.length; i++) {
        final l$notStartsWithAll$entry = l$notStartsWithAll[i];
        final lOther$notStartsWithAll$entry = lOther$notStartsWithAll[i];
        if (l$notStartsWithAll$entry != lOther$notStartsWithAll$entry) {
          return false;
        }
      }
    } else if (l$notStartsWithAll != lOther$notStartsWithAll) {
      return false;
    }
    final l$notStartsWithAny = notStartsWithAny;
    final lOther$notStartsWithAny = other.notStartsWithAny;
    if (_$data.containsKey('notStartsWithAny') !=
        other._$data.containsKey('notStartsWithAny')) {
      return false;
    }
    if (l$notStartsWithAny != null && lOther$notStartsWithAny != null) {
      if (l$notStartsWithAny.length != lOther$notStartsWithAny.length) {
        return false;
      }
      for (int i = 0; i < l$notStartsWithAny.length; i++) {
        final l$notStartsWithAny$entry = l$notStartsWithAny[i];
        final lOther$notStartsWithAny$entry = lOther$notStartsWithAny[i];
        if (l$notStartsWithAny$entry != lOther$notStartsWithAny$entry) {
          return false;
        }
      }
    } else if (l$notStartsWithAny != lOther$notStartsWithAny) {
      return false;
    }
    final l$notStartsWithInsensitive = notStartsWithInsensitive;
    final lOther$notStartsWithInsensitive = other.notStartsWithInsensitive;
    if (_$data.containsKey('notStartsWithInsensitive') !=
        other._$data.containsKey('notStartsWithInsensitive')) {
      return false;
    }
    if (l$notStartsWithInsensitive != lOther$notStartsWithInsensitive) {
      return false;
    }
    final l$notStartsWithInsensitiveAll = notStartsWithInsensitiveAll;
    final lOther$notStartsWithInsensitiveAll =
        other.notStartsWithInsensitiveAll;
    if (_$data.containsKey('notStartsWithInsensitiveAll') !=
        other._$data.containsKey('notStartsWithInsensitiveAll')) {
      return false;
    }
    if (l$notStartsWithInsensitiveAll != null &&
        lOther$notStartsWithInsensitiveAll != null) {
      if (l$notStartsWithInsensitiveAll.length !=
          lOther$notStartsWithInsensitiveAll.length) {
        return false;
      }
      for (int i = 0; i < l$notStartsWithInsensitiveAll.length; i++) {
        final l$notStartsWithInsensitiveAll$entry =
            l$notStartsWithInsensitiveAll[i];
        final lOther$notStartsWithInsensitiveAll$entry =
            lOther$notStartsWithInsensitiveAll[i];
        if (l$notStartsWithInsensitiveAll$entry !=
            lOther$notStartsWithInsensitiveAll$entry) {
          return false;
        }
      }
    } else if (l$notStartsWithInsensitiveAll !=
        lOther$notStartsWithInsensitiveAll) {
      return false;
    }
    final l$notStartsWithInsensitiveAny = notStartsWithInsensitiveAny;
    final lOther$notStartsWithInsensitiveAny =
        other.notStartsWithInsensitiveAny;
    if (_$data.containsKey('notStartsWithInsensitiveAny') !=
        other._$data.containsKey('notStartsWithInsensitiveAny')) {
      return false;
    }
    if (l$notStartsWithInsensitiveAny != null &&
        lOther$notStartsWithInsensitiveAny != null) {
      if (l$notStartsWithInsensitiveAny.length !=
          lOther$notStartsWithInsensitiveAny.length) {
        return false;
      }
      for (int i = 0; i < l$notStartsWithInsensitiveAny.length; i++) {
        final l$notStartsWithInsensitiveAny$entry =
            l$notStartsWithInsensitiveAny[i];
        final lOther$notStartsWithInsensitiveAny$entry =
            lOther$notStartsWithInsensitiveAny[i];
        if (l$notStartsWithInsensitiveAny$entry !=
            lOther$notStartsWithInsensitiveAny$entry) {
          return false;
        }
      }
    } else if (l$notStartsWithInsensitiveAny !=
        lOther$notStartsWithInsensitiveAny) {
      return false;
    }
    final l$startsWith = startsWith;
    final lOther$startsWith = other.startsWith;
    if (_$data.containsKey('startsWith') !=
        other._$data.containsKey('startsWith')) {
      return false;
    }
    if (l$startsWith != lOther$startsWith) {
      return false;
    }
    final l$startsWithAll = startsWithAll;
    final lOther$startsWithAll = other.startsWithAll;
    if (_$data.containsKey('startsWithAll') !=
        other._$data.containsKey('startsWithAll')) {
      return false;
    }
    if (l$startsWithAll != null && lOther$startsWithAll != null) {
      if (l$startsWithAll.length != lOther$startsWithAll.length) {
        return false;
      }
      for (int i = 0; i < l$startsWithAll.length; i++) {
        final l$startsWithAll$entry = l$startsWithAll[i];
        final lOther$startsWithAll$entry = lOther$startsWithAll[i];
        if (l$startsWithAll$entry != lOther$startsWithAll$entry) {
          return false;
        }
      }
    } else if (l$startsWithAll != lOther$startsWithAll) {
      return false;
    }
    final l$startsWithAny = startsWithAny;
    final lOther$startsWithAny = other.startsWithAny;
    if (_$data.containsKey('startsWithAny') !=
        other._$data.containsKey('startsWithAny')) {
      return false;
    }
    if (l$startsWithAny != null && lOther$startsWithAny != null) {
      if (l$startsWithAny.length != lOther$startsWithAny.length) {
        return false;
      }
      for (int i = 0; i < l$startsWithAny.length; i++) {
        final l$startsWithAny$entry = l$startsWithAny[i];
        final lOther$startsWithAny$entry = lOther$startsWithAny[i];
        if (l$startsWithAny$entry != lOther$startsWithAny$entry) {
          return false;
        }
      }
    } else if (l$startsWithAny != lOther$startsWithAny) {
      return false;
    }
    final l$startsWithInsensitive = startsWithInsensitive;
    final lOther$startsWithInsensitive = other.startsWithInsensitive;
    if (_$data.containsKey('startsWithInsensitive') !=
        other._$data.containsKey('startsWithInsensitive')) {
      return false;
    }
    if (l$startsWithInsensitive != lOther$startsWithInsensitive) {
      return false;
    }
    final l$startsWithInsensitiveAll = startsWithInsensitiveAll;
    final lOther$startsWithInsensitiveAll = other.startsWithInsensitiveAll;
    if (_$data.containsKey('startsWithInsensitiveAll') !=
        other._$data.containsKey('startsWithInsensitiveAll')) {
      return false;
    }
    if (l$startsWithInsensitiveAll != null &&
        lOther$startsWithInsensitiveAll != null) {
      if (l$startsWithInsensitiveAll.length !=
          lOther$startsWithInsensitiveAll.length) {
        return false;
      }
      for (int i = 0; i < l$startsWithInsensitiveAll.length; i++) {
        final l$startsWithInsensitiveAll$entry = l$startsWithInsensitiveAll[i];
        final lOther$startsWithInsensitiveAll$entry =
            lOther$startsWithInsensitiveAll[i];
        if (l$startsWithInsensitiveAll$entry !=
            lOther$startsWithInsensitiveAll$entry) {
          return false;
        }
      }
    } else if (l$startsWithInsensitiveAll != lOther$startsWithInsensitiveAll) {
      return false;
    }
    final l$startsWithInsensitiveAny = startsWithInsensitiveAny;
    final lOther$startsWithInsensitiveAny = other.startsWithInsensitiveAny;
    if (_$data.containsKey('startsWithInsensitiveAny') !=
        other._$data.containsKey('startsWithInsensitiveAny')) {
      return false;
    }
    if (l$startsWithInsensitiveAny != null &&
        lOther$startsWithInsensitiveAny != null) {
      if (l$startsWithInsensitiveAny.length !=
          lOther$startsWithInsensitiveAny.length) {
        return false;
      }
      for (int i = 0; i < l$startsWithInsensitiveAny.length; i++) {
        final l$startsWithInsensitiveAny$entry = l$startsWithInsensitiveAny[i];
        final lOther$startsWithInsensitiveAny$entry =
            lOther$startsWithInsensitiveAny[i];
        if (l$startsWithInsensitiveAny$entry !=
            lOther$startsWithInsensitiveAny$entry) {
          return false;
        }
      }
    } else if (l$startsWithInsensitiveAny != lOther$startsWithInsensitiveAny) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$distinctFrom = distinctFrom;
    final l$distinctFromAll = distinctFromAll;
    final l$distinctFromAny = distinctFromAny;
    final l$distinctFromInsensitive = distinctFromInsensitive;
    final l$distinctFromInsensitiveAll = distinctFromInsensitiveAll;
    final l$distinctFromInsensitiveAny = distinctFromInsensitiveAny;
    final l$endsWith = endsWith;
    final l$endsWithAll = endsWithAll;
    final l$endsWithAny = endsWithAny;
    final l$endsWithInsensitive = endsWithInsensitive;
    final l$endsWithInsensitiveAll = endsWithInsensitiveAll;
    final l$endsWithInsensitiveAny = endsWithInsensitiveAny;
    final l$equalTo = equalTo;
    final l$greaterThan = greaterThan;
    final l$greaterThanInsensitive = greaterThanInsensitive;
    final l$greaterThanOrEqualTo = greaterThanOrEqualTo;
    final l$greaterThanOrEqualToInsensitive = greaterThanOrEqualToInsensitive;
    final l$$in = $in;
    final l$inInsensitive = inInsensitive;
    final l$includes = includes;
    final l$includesAll = includesAll;
    final l$includesAny = includesAny;
    final l$includesInsensitive = includesInsensitive;
    final l$includesInsensitiveAll = includesInsensitiveAll;
    final l$includesInsensitiveAny = includesInsensitiveAny;
    final l$isNull = isNull;
    final l$lessThan = lessThan;
    final l$lessThanInsensitive = lessThanInsensitive;
    final l$lessThanOrEqualTo = lessThanOrEqualTo;
    final l$lessThanOrEqualToInsensitive = lessThanOrEqualToInsensitive;
    final l$like = like;
    final l$likeAll = likeAll;
    final l$likeAny = likeAny;
    final l$likeInsensitive = likeInsensitive;
    final l$likeInsensitiveAll = likeInsensitiveAll;
    final l$likeInsensitiveAny = likeInsensitiveAny;
    final l$notDistinctFrom = notDistinctFrom;
    final l$notDistinctFromInsensitive = notDistinctFromInsensitive;
    final l$notEndsWith = notEndsWith;
    final l$notEndsWithAll = notEndsWithAll;
    final l$notEndsWithAny = notEndsWithAny;
    final l$notEndsWithInsensitive = notEndsWithInsensitive;
    final l$notEndsWithInsensitiveAll = notEndsWithInsensitiveAll;
    final l$notEndsWithInsensitiveAny = notEndsWithInsensitiveAny;
    final l$notEqualTo = notEqualTo;
    final l$notEqualToAll = notEqualToAll;
    final l$notEqualToAny = notEqualToAny;
    final l$notIn = notIn;
    final l$notInInsensitive = notInInsensitive;
    final l$notIncludes = notIncludes;
    final l$notIncludesAll = notIncludesAll;
    final l$notIncludesAny = notIncludesAny;
    final l$notIncludesInsensitive = notIncludesInsensitive;
    final l$notIncludesInsensitiveAll = notIncludesInsensitiveAll;
    final l$notIncludesInsensitiveAny = notIncludesInsensitiveAny;
    final l$notLike = notLike;
    final l$notLikeAll = notLikeAll;
    final l$notLikeAny = notLikeAny;
    final l$notLikeInsensitive = notLikeInsensitive;
    final l$notLikeInsensitiveAll = notLikeInsensitiveAll;
    final l$notLikeInsensitiveAny = notLikeInsensitiveAny;
    final l$notStartsWith = notStartsWith;
    final l$notStartsWithAll = notStartsWithAll;
    final l$notStartsWithAny = notStartsWithAny;
    final l$notStartsWithInsensitive = notStartsWithInsensitive;
    final l$notStartsWithInsensitiveAll = notStartsWithInsensitiveAll;
    final l$notStartsWithInsensitiveAny = notStartsWithInsensitiveAny;
    final l$startsWith = startsWith;
    final l$startsWithAll = startsWithAll;
    final l$startsWithAny = startsWithAny;
    final l$startsWithInsensitive = startsWithInsensitive;
    final l$startsWithInsensitiveAll = startsWithInsensitiveAll;
    final l$startsWithInsensitiveAny = startsWithInsensitiveAny;
    return Object.hashAll([
      _$data.containsKey('distinctFrom') ? l$distinctFrom : const {},
      _$data.containsKey('distinctFromAll')
          ? l$distinctFromAll == null
              ? null
              : Object.hashAll(l$distinctFromAll.map((v) => v))
          : const {},
      _$data.containsKey('distinctFromAny')
          ? l$distinctFromAny == null
              ? null
              : Object.hashAll(l$distinctFromAny.map((v) => v))
          : const {},
      _$data.containsKey('distinctFromInsensitive')
          ? l$distinctFromInsensitive
          : const {},
      _$data.containsKey('distinctFromInsensitiveAll')
          ? l$distinctFromInsensitiveAll == null
              ? null
              : Object.hashAll(l$distinctFromInsensitiveAll.map((v) => v))
          : const {},
      _$data.containsKey('distinctFromInsensitiveAny')
          ? l$distinctFromInsensitiveAny == null
              ? null
              : Object.hashAll(l$distinctFromInsensitiveAny.map((v) => v))
          : const {},
      _$data.containsKey('endsWith') ? l$endsWith : const {},
      _$data.containsKey('endsWithAll')
          ? l$endsWithAll == null
              ? null
              : Object.hashAll(l$endsWithAll.map((v) => v))
          : const {},
      _$data.containsKey('endsWithAny')
          ? l$endsWithAny == null
              ? null
              : Object.hashAll(l$endsWithAny.map((v) => v))
          : const {},
      _$data.containsKey('endsWithInsensitive')
          ? l$endsWithInsensitive
          : const {},
      _$data.containsKey('endsWithInsensitiveAll')
          ? l$endsWithInsensitiveAll == null
              ? null
              : Object.hashAll(l$endsWithInsensitiveAll.map((v) => v))
          : const {},
      _$data.containsKey('endsWithInsensitiveAny')
          ? l$endsWithInsensitiveAny == null
              ? null
              : Object.hashAll(l$endsWithInsensitiveAny.map((v) => v))
          : const {},
      _$data.containsKey('equalTo') ? l$equalTo : const {},
      _$data.containsKey('greaterThan') ? l$greaterThan : const {},
      _$data.containsKey('greaterThanInsensitive')
          ? l$greaterThanInsensitive
          : const {},
      _$data.containsKey('greaterThanOrEqualTo')
          ? l$greaterThanOrEqualTo
          : const {},
      _$data.containsKey('greaterThanOrEqualToInsensitive')
          ? l$greaterThanOrEqualToInsensitive
          : const {},
      _$data.containsKey('in')
          ? l$$in == null
              ? null
              : Object.hashAll(l$$in.map((v) => v))
          : const {},
      _$data.containsKey('inInsensitive')
          ? l$inInsensitive == null
              ? null
              : Object.hashAll(l$inInsensitive.map((v) => v))
          : const {},
      _$data.containsKey('includes') ? l$includes : const {},
      _$data.containsKey('includesAll')
          ? l$includesAll == null
              ? null
              : Object.hashAll(l$includesAll.map((v) => v))
          : const {},
      _$data.containsKey('includesAny')
          ? l$includesAny == null
              ? null
              : Object.hashAll(l$includesAny.map((v) => v))
          : const {},
      _$data.containsKey('includesInsensitive')
          ? l$includesInsensitive
          : const {},
      _$data.containsKey('includesInsensitiveAll')
          ? l$includesInsensitiveAll == null
              ? null
              : Object.hashAll(l$includesInsensitiveAll.map((v) => v))
          : const {},
      _$data.containsKey('includesInsensitiveAny')
          ? l$includesInsensitiveAny == null
              ? null
              : Object.hashAll(l$includesInsensitiveAny.map((v) => v))
          : const {},
      _$data.containsKey('isNull') ? l$isNull : const {},
      _$data.containsKey('lessThan') ? l$lessThan : const {},
      _$data.containsKey('lessThanInsensitive')
          ? l$lessThanInsensitive
          : const {},
      _$data.containsKey('lessThanOrEqualTo') ? l$lessThanOrEqualTo : const {},
      _$data.containsKey('lessThanOrEqualToInsensitive')
          ? l$lessThanOrEqualToInsensitive
          : const {},
      _$data.containsKey('like') ? l$like : const {},
      _$data.containsKey('likeAll')
          ? l$likeAll == null
              ? null
              : Object.hashAll(l$likeAll.map((v) => v))
          : const {},
      _$data.containsKey('likeAny')
          ? l$likeAny == null
              ? null
              : Object.hashAll(l$likeAny.map((v) => v))
          : const {},
      _$data.containsKey('likeInsensitive') ? l$likeInsensitive : const {},
      _$data.containsKey('likeInsensitiveAll')
          ? l$likeInsensitiveAll == null
              ? null
              : Object.hashAll(l$likeInsensitiveAll.map((v) => v))
          : const {},
      _$data.containsKey('likeInsensitiveAny')
          ? l$likeInsensitiveAny == null
              ? null
              : Object.hashAll(l$likeInsensitiveAny.map((v) => v))
          : const {},
      _$data.containsKey('notDistinctFrom') ? l$notDistinctFrom : const {},
      _$data.containsKey('notDistinctFromInsensitive')
          ? l$notDistinctFromInsensitive
          : const {},
      _$data.containsKey('notEndsWith') ? l$notEndsWith : const {},
      _$data.containsKey('notEndsWithAll')
          ? l$notEndsWithAll == null
              ? null
              : Object.hashAll(l$notEndsWithAll.map((v) => v))
          : const {},
      _$data.containsKey('notEndsWithAny')
          ? l$notEndsWithAny == null
              ? null
              : Object.hashAll(l$notEndsWithAny.map((v) => v))
          : const {},
      _$data.containsKey('notEndsWithInsensitive')
          ? l$notEndsWithInsensitive
          : const {},
      _$data.containsKey('notEndsWithInsensitiveAll')
          ? l$notEndsWithInsensitiveAll == null
              ? null
              : Object.hashAll(l$notEndsWithInsensitiveAll.map((v) => v))
          : const {},
      _$data.containsKey('notEndsWithInsensitiveAny')
          ? l$notEndsWithInsensitiveAny == null
              ? null
              : Object.hashAll(l$notEndsWithInsensitiveAny.map((v) => v))
          : const {},
      _$data.containsKey('notEqualTo') ? l$notEqualTo : const {},
      _$data.containsKey('notEqualToAll')
          ? l$notEqualToAll == null
              ? null
              : Object.hashAll(l$notEqualToAll.map((v) => v))
          : const {},
      _$data.containsKey('notEqualToAny')
          ? l$notEqualToAny == null
              ? null
              : Object.hashAll(l$notEqualToAny.map((v) => v))
          : const {},
      _$data.containsKey('notIn')
          ? l$notIn == null
              ? null
              : Object.hashAll(l$notIn.map((v) => v))
          : const {},
      _$data.containsKey('notInInsensitive')
          ? l$notInInsensitive == null
              ? null
              : Object.hashAll(l$notInInsensitive.map((v) => v))
          : const {},
      _$data.containsKey('notIncludes') ? l$notIncludes : const {},
      _$data.containsKey('notIncludesAll')
          ? l$notIncludesAll == null
              ? null
              : Object.hashAll(l$notIncludesAll.map((v) => v))
          : const {},
      _$data.containsKey('notIncludesAny')
          ? l$notIncludesAny == null
              ? null
              : Object.hashAll(l$notIncludesAny.map((v) => v))
          : const {},
      _$data.containsKey('notIncludesInsensitive')
          ? l$notIncludesInsensitive
          : const {},
      _$data.containsKey('notIncludesInsensitiveAll')
          ? l$notIncludesInsensitiveAll == null
              ? null
              : Object.hashAll(l$notIncludesInsensitiveAll.map((v) => v))
          : const {},
      _$data.containsKey('notIncludesInsensitiveAny')
          ? l$notIncludesInsensitiveAny == null
              ? null
              : Object.hashAll(l$notIncludesInsensitiveAny.map((v) => v))
          : const {},
      _$data.containsKey('notLike') ? l$notLike : const {},
      _$data.containsKey('notLikeAll')
          ? l$notLikeAll == null
              ? null
              : Object.hashAll(l$notLikeAll.map((v) => v))
          : const {},
      _$data.containsKey('notLikeAny')
          ? l$notLikeAny == null
              ? null
              : Object.hashAll(l$notLikeAny.map((v) => v))
          : const {},
      _$data.containsKey('notLikeInsensitive')
          ? l$notLikeInsensitive
          : const {},
      _$data.containsKey('notLikeInsensitiveAll')
          ? l$notLikeInsensitiveAll == null
              ? null
              : Object.hashAll(l$notLikeInsensitiveAll.map((v) => v))
          : const {},
      _$data.containsKey('notLikeInsensitiveAny')
          ? l$notLikeInsensitiveAny == null
              ? null
              : Object.hashAll(l$notLikeInsensitiveAny.map((v) => v))
          : const {},
      _$data.containsKey('notStartsWith') ? l$notStartsWith : const {},
      _$data.containsKey('notStartsWithAll')
          ? l$notStartsWithAll == null
              ? null
              : Object.hashAll(l$notStartsWithAll.map((v) => v))
          : const {},
      _$data.containsKey('notStartsWithAny')
          ? l$notStartsWithAny == null
              ? null
              : Object.hashAll(l$notStartsWithAny.map((v) => v))
          : const {},
      _$data.containsKey('notStartsWithInsensitive')
          ? l$notStartsWithInsensitive
          : const {},
      _$data.containsKey('notStartsWithInsensitiveAll')
          ? l$notStartsWithInsensitiveAll == null
              ? null
              : Object.hashAll(l$notStartsWithInsensitiveAll.map((v) => v))
          : const {},
      _$data.containsKey('notStartsWithInsensitiveAny')
          ? l$notStartsWithInsensitiveAny == null
              ? null
              : Object.hashAll(l$notStartsWithInsensitiveAny.map((v) => v))
          : const {},
      _$data.containsKey('startsWith') ? l$startsWith : const {},
      _$data.containsKey('startsWithAll')
          ? l$startsWithAll == null
              ? null
              : Object.hashAll(l$startsWithAll.map((v) => v))
          : const {},
      _$data.containsKey('startsWithAny')
          ? l$startsWithAny == null
              ? null
              : Object.hashAll(l$startsWithAny.map((v) => v))
          : const {},
      _$data.containsKey('startsWithInsensitive')
          ? l$startsWithInsensitive
          : const {},
      _$data.containsKey('startsWithInsensitiveAll')
          ? l$startsWithInsensitiveAll == null
              ? null
              : Object.hashAll(l$startsWithInsensitiveAll.map((v) => v))
          : const {},
      _$data.containsKey('startsWithInsensitiveAny')
          ? l$startsWithInsensitiveAny == null
              ? null
              : Object.hashAll(l$startsWithInsensitiveAny.map((v) => v))
          : const {},
    ]);
  }
}

abstract class CopyWith$Input$StringFilterInput<TRes> {
  factory CopyWith$Input$StringFilterInput(
    Input$StringFilterInput instance,
    TRes Function(Input$StringFilterInput) then,
  ) = _CopyWithImpl$Input$StringFilterInput;

  factory CopyWith$Input$StringFilterInput.stub(TRes res) =
      _CopyWithStubImpl$Input$StringFilterInput;

  TRes call({
    String? distinctFrom,
    List<String>? distinctFromAll,
    List<String>? distinctFromAny,
    String? distinctFromInsensitive,
    List<String>? distinctFromInsensitiveAll,
    List<String>? distinctFromInsensitiveAny,
    String? endsWith,
    List<String>? endsWithAll,
    List<String>? endsWithAny,
    String? endsWithInsensitive,
    List<String>? endsWithInsensitiveAll,
    List<String>? endsWithInsensitiveAny,
    String? equalTo,
    String? greaterThan,
    String? greaterThanInsensitive,
    String? greaterThanOrEqualTo,
    String? greaterThanOrEqualToInsensitive,
    List<String>? $in,
    List<String>? inInsensitive,
    String? includes,
    List<String>? includesAll,
    List<String>? includesAny,
    String? includesInsensitive,
    List<String>? includesInsensitiveAll,
    List<String>? includesInsensitiveAny,
    bool? isNull,
    String? lessThan,
    String? lessThanInsensitive,
    String? lessThanOrEqualTo,
    String? lessThanOrEqualToInsensitive,
    String? like,
    List<String>? likeAll,
    List<String>? likeAny,
    String? likeInsensitive,
    List<String>? likeInsensitiveAll,
    List<String>? likeInsensitiveAny,
    String? notDistinctFrom,
    String? notDistinctFromInsensitive,
    String? notEndsWith,
    List<String>? notEndsWithAll,
    List<String>? notEndsWithAny,
    String? notEndsWithInsensitive,
    List<String>? notEndsWithInsensitiveAll,
    List<String>? notEndsWithInsensitiveAny,
    String? notEqualTo,
    List<String>? notEqualToAll,
    List<String>? notEqualToAny,
    List<String>? notIn,
    List<String>? notInInsensitive,
    String? notIncludes,
    List<String>? notIncludesAll,
    List<String>? notIncludesAny,
    String? notIncludesInsensitive,
    List<String>? notIncludesInsensitiveAll,
    List<String>? notIncludesInsensitiveAny,
    String? notLike,
    List<String>? notLikeAll,
    List<String>? notLikeAny,
    String? notLikeInsensitive,
    List<String>? notLikeInsensitiveAll,
    List<String>? notLikeInsensitiveAny,
    String? notStartsWith,
    List<String>? notStartsWithAll,
    List<String>? notStartsWithAny,
    String? notStartsWithInsensitive,
    List<String>? notStartsWithInsensitiveAll,
    List<String>? notStartsWithInsensitiveAny,
    String? startsWith,
    List<String>? startsWithAll,
    List<String>? startsWithAny,
    String? startsWithInsensitive,
    List<String>? startsWithInsensitiveAll,
    List<String>? startsWithInsensitiveAny,
  });
}

class _CopyWithImpl$Input$StringFilterInput<TRes>
    implements CopyWith$Input$StringFilterInput<TRes> {
  _CopyWithImpl$Input$StringFilterInput(
    this._instance,
    this._then,
  );

  final Input$StringFilterInput _instance;

  final TRes Function(Input$StringFilterInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? distinctFrom = _undefined,
    Object? distinctFromAll = _undefined,
    Object? distinctFromAny = _undefined,
    Object? distinctFromInsensitive = _undefined,
    Object? distinctFromInsensitiveAll = _undefined,
    Object? distinctFromInsensitiveAny = _undefined,
    Object? endsWith = _undefined,
    Object? endsWithAll = _undefined,
    Object? endsWithAny = _undefined,
    Object? endsWithInsensitive = _undefined,
    Object? endsWithInsensitiveAll = _undefined,
    Object? endsWithInsensitiveAny = _undefined,
    Object? equalTo = _undefined,
    Object? greaterThan = _undefined,
    Object? greaterThanInsensitive = _undefined,
    Object? greaterThanOrEqualTo = _undefined,
    Object? greaterThanOrEqualToInsensitive = _undefined,
    Object? $in = _undefined,
    Object? inInsensitive = _undefined,
    Object? includes = _undefined,
    Object? includesAll = _undefined,
    Object? includesAny = _undefined,
    Object? includesInsensitive = _undefined,
    Object? includesInsensitiveAll = _undefined,
    Object? includesInsensitiveAny = _undefined,
    Object? isNull = _undefined,
    Object? lessThan = _undefined,
    Object? lessThanInsensitive = _undefined,
    Object? lessThanOrEqualTo = _undefined,
    Object? lessThanOrEqualToInsensitive = _undefined,
    Object? like = _undefined,
    Object? likeAll = _undefined,
    Object? likeAny = _undefined,
    Object? likeInsensitive = _undefined,
    Object? likeInsensitiveAll = _undefined,
    Object? likeInsensitiveAny = _undefined,
    Object? notDistinctFrom = _undefined,
    Object? notDistinctFromInsensitive = _undefined,
    Object? notEndsWith = _undefined,
    Object? notEndsWithAll = _undefined,
    Object? notEndsWithAny = _undefined,
    Object? notEndsWithInsensitive = _undefined,
    Object? notEndsWithInsensitiveAll = _undefined,
    Object? notEndsWithInsensitiveAny = _undefined,
    Object? notEqualTo = _undefined,
    Object? notEqualToAll = _undefined,
    Object? notEqualToAny = _undefined,
    Object? notIn = _undefined,
    Object? notInInsensitive = _undefined,
    Object? notIncludes = _undefined,
    Object? notIncludesAll = _undefined,
    Object? notIncludesAny = _undefined,
    Object? notIncludesInsensitive = _undefined,
    Object? notIncludesInsensitiveAll = _undefined,
    Object? notIncludesInsensitiveAny = _undefined,
    Object? notLike = _undefined,
    Object? notLikeAll = _undefined,
    Object? notLikeAny = _undefined,
    Object? notLikeInsensitive = _undefined,
    Object? notLikeInsensitiveAll = _undefined,
    Object? notLikeInsensitiveAny = _undefined,
    Object? notStartsWith = _undefined,
    Object? notStartsWithAll = _undefined,
    Object? notStartsWithAny = _undefined,
    Object? notStartsWithInsensitive = _undefined,
    Object? notStartsWithInsensitiveAll = _undefined,
    Object? notStartsWithInsensitiveAny = _undefined,
    Object? startsWith = _undefined,
    Object? startsWithAll = _undefined,
    Object? startsWithAny = _undefined,
    Object? startsWithInsensitive = _undefined,
    Object? startsWithInsensitiveAll = _undefined,
    Object? startsWithInsensitiveAny = _undefined,
  }) =>
      _then(Input$StringFilterInput._({
        ..._instance._$data,
        if (distinctFrom != _undefined)
          'distinctFrom': (distinctFrom as String?),
        if (distinctFromAll != _undefined)
          'distinctFromAll': (distinctFromAll as List<String>?),
        if (distinctFromAny != _undefined)
          'distinctFromAny': (distinctFromAny as List<String>?),
        if (distinctFromInsensitive != _undefined)
          'distinctFromInsensitive': (distinctFromInsensitive as String?),
        if (distinctFromInsensitiveAll != _undefined)
          'distinctFromInsensitiveAll':
              (distinctFromInsensitiveAll as List<String>?),
        if (distinctFromInsensitiveAny != _undefined)
          'distinctFromInsensitiveAny':
              (distinctFromInsensitiveAny as List<String>?),
        if (endsWith != _undefined) 'endsWith': (endsWith as String?),
        if (endsWithAll != _undefined)
          'endsWithAll': (endsWithAll as List<String>?),
        if (endsWithAny != _undefined)
          'endsWithAny': (endsWithAny as List<String>?),
        if (endsWithInsensitive != _undefined)
          'endsWithInsensitive': (endsWithInsensitive as String?),
        if (endsWithInsensitiveAll != _undefined)
          'endsWithInsensitiveAll': (endsWithInsensitiveAll as List<String>?),
        if (endsWithInsensitiveAny != _undefined)
          'endsWithInsensitiveAny': (endsWithInsensitiveAny as List<String>?),
        if (equalTo != _undefined) 'equalTo': (equalTo as String?),
        if (greaterThan != _undefined) 'greaterThan': (greaterThan as String?),
        if (greaterThanInsensitive != _undefined)
          'greaterThanInsensitive': (greaterThanInsensitive as String?),
        if (greaterThanOrEqualTo != _undefined)
          'greaterThanOrEqualTo': (greaterThanOrEqualTo as String?),
        if (greaterThanOrEqualToInsensitive != _undefined)
          'greaterThanOrEqualToInsensitive':
              (greaterThanOrEqualToInsensitive as String?),
        if ($in != _undefined) 'in': ($in as List<String>?),
        if (inInsensitive != _undefined)
          'inInsensitive': (inInsensitive as List<String>?),
        if (includes != _undefined) 'includes': (includes as String?),
        if (includesAll != _undefined)
          'includesAll': (includesAll as List<String>?),
        if (includesAny != _undefined)
          'includesAny': (includesAny as List<String>?),
        if (includesInsensitive != _undefined)
          'includesInsensitive': (includesInsensitive as String?),
        if (includesInsensitiveAll != _undefined)
          'includesInsensitiveAll': (includesInsensitiveAll as List<String>?),
        if (includesInsensitiveAny != _undefined)
          'includesInsensitiveAny': (includesInsensitiveAny as List<String>?),
        if (isNull != _undefined) 'isNull': (isNull as bool?),
        if (lessThan != _undefined) 'lessThan': (lessThan as String?),
        if (lessThanInsensitive != _undefined)
          'lessThanInsensitive': (lessThanInsensitive as String?),
        if (lessThanOrEqualTo != _undefined)
          'lessThanOrEqualTo': (lessThanOrEqualTo as String?),
        if (lessThanOrEqualToInsensitive != _undefined)
          'lessThanOrEqualToInsensitive':
              (lessThanOrEqualToInsensitive as String?),
        if (like != _undefined) 'like': (like as String?),
        if (likeAll != _undefined) 'likeAll': (likeAll as List<String>?),
        if (likeAny != _undefined) 'likeAny': (likeAny as List<String>?),
        if (likeInsensitive != _undefined)
          'likeInsensitive': (likeInsensitive as String?),
        if (likeInsensitiveAll != _undefined)
          'likeInsensitiveAll': (likeInsensitiveAll as List<String>?),
        if (likeInsensitiveAny != _undefined)
          'likeInsensitiveAny': (likeInsensitiveAny as List<String>?),
        if (notDistinctFrom != _undefined)
          'notDistinctFrom': (notDistinctFrom as String?),
        if (notDistinctFromInsensitive != _undefined)
          'notDistinctFromInsensitive': (notDistinctFromInsensitive as String?),
        if (notEndsWith != _undefined) 'notEndsWith': (notEndsWith as String?),
        if (notEndsWithAll != _undefined)
          'notEndsWithAll': (notEndsWithAll as List<String>?),
        if (notEndsWithAny != _undefined)
          'notEndsWithAny': (notEndsWithAny as List<String>?),
        if (notEndsWithInsensitive != _undefined)
          'notEndsWithInsensitive': (notEndsWithInsensitive as String?),
        if (notEndsWithInsensitiveAll != _undefined)
          'notEndsWithInsensitiveAll':
              (notEndsWithInsensitiveAll as List<String>?),
        if (notEndsWithInsensitiveAny != _undefined)
          'notEndsWithInsensitiveAny':
              (notEndsWithInsensitiveAny as List<String>?),
        if (notEqualTo != _undefined) 'notEqualTo': (notEqualTo as String?),
        if (notEqualToAll != _undefined)
          'notEqualToAll': (notEqualToAll as List<String>?),
        if (notEqualToAny != _undefined)
          'notEqualToAny': (notEqualToAny as List<String>?),
        if (notIn != _undefined) 'notIn': (notIn as List<String>?),
        if (notInInsensitive != _undefined)
          'notInInsensitive': (notInInsensitive as List<String>?),
        if (notIncludes != _undefined) 'notIncludes': (notIncludes as String?),
        if (notIncludesAll != _undefined)
          'notIncludesAll': (notIncludesAll as List<String>?),
        if (notIncludesAny != _undefined)
          'notIncludesAny': (notIncludesAny as List<String>?),
        if (notIncludesInsensitive != _undefined)
          'notIncludesInsensitive': (notIncludesInsensitive as String?),
        if (notIncludesInsensitiveAll != _undefined)
          'notIncludesInsensitiveAll':
              (notIncludesInsensitiveAll as List<String>?),
        if (notIncludesInsensitiveAny != _undefined)
          'notIncludesInsensitiveAny':
              (notIncludesInsensitiveAny as List<String>?),
        if (notLike != _undefined) 'notLike': (notLike as String?),
        if (notLikeAll != _undefined)
          'notLikeAll': (notLikeAll as List<String>?),
        if (notLikeAny != _undefined)
          'notLikeAny': (notLikeAny as List<String>?),
        if (notLikeInsensitive != _undefined)
          'notLikeInsensitive': (notLikeInsensitive as String?),
        if (notLikeInsensitiveAll != _undefined)
          'notLikeInsensitiveAll': (notLikeInsensitiveAll as List<String>?),
        if (notLikeInsensitiveAny != _undefined)
          'notLikeInsensitiveAny': (notLikeInsensitiveAny as List<String>?),
        if (notStartsWith != _undefined)
          'notStartsWith': (notStartsWith as String?),
        if (notStartsWithAll != _undefined)
          'notStartsWithAll': (notStartsWithAll as List<String>?),
        if (notStartsWithAny != _undefined)
          'notStartsWithAny': (notStartsWithAny as List<String>?),
        if (notStartsWithInsensitive != _undefined)
          'notStartsWithInsensitive': (notStartsWithInsensitive as String?),
        if (notStartsWithInsensitiveAll != _undefined)
          'notStartsWithInsensitiveAll':
              (notStartsWithInsensitiveAll as List<String>?),
        if (notStartsWithInsensitiveAny != _undefined)
          'notStartsWithInsensitiveAny':
              (notStartsWithInsensitiveAny as List<String>?),
        if (startsWith != _undefined) 'startsWith': (startsWith as String?),
        if (startsWithAll != _undefined)
          'startsWithAll': (startsWithAll as List<String>?),
        if (startsWithAny != _undefined)
          'startsWithAny': (startsWithAny as List<String>?),
        if (startsWithInsensitive != _undefined)
          'startsWithInsensitive': (startsWithInsensitive as String?),
        if (startsWithInsensitiveAll != _undefined)
          'startsWithInsensitiveAll':
              (startsWithInsensitiveAll as List<String>?),
        if (startsWithInsensitiveAny != _undefined)
          'startsWithInsensitiveAny':
              (startsWithInsensitiveAny as List<String>?),
      }));
}

class _CopyWithStubImpl$Input$StringFilterInput<TRes>
    implements CopyWith$Input$StringFilterInput<TRes> {
  _CopyWithStubImpl$Input$StringFilterInput(this._res);

  TRes _res;

  call({
    String? distinctFrom,
    List<String>? distinctFromAll,
    List<String>? distinctFromAny,
    String? distinctFromInsensitive,
    List<String>? distinctFromInsensitiveAll,
    List<String>? distinctFromInsensitiveAny,
    String? endsWith,
    List<String>? endsWithAll,
    List<String>? endsWithAny,
    String? endsWithInsensitive,
    List<String>? endsWithInsensitiveAll,
    List<String>? endsWithInsensitiveAny,
    String? equalTo,
    String? greaterThan,
    String? greaterThanInsensitive,
    String? greaterThanOrEqualTo,
    String? greaterThanOrEqualToInsensitive,
    List<String>? $in,
    List<String>? inInsensitive,
    String? includes,
    List<String>? includesAll,
    List<String>? includesAny,
    String? includesInsensitive,
    List<String>? includesInsensitiveAll,
    List<String>? includesInsensitiveAny,
    bool? isNull,
    String? lessThan,
    String? lessThanInsensitive,
    String? lessThanOrEqualTo,
    String? lessThanOrEqualToInsensitive,
    String? like,
    List<String>? likeAll,
    List<String>? likeAny,
    String? likeInsensitive,
    List<String>? likeInsensitiveAll,
    List<String>? likeInsensitiveAny,
    String? notDistinctFrom,
    String? notDistinctFromInsensitive,
    String? notEndsWith,
    List<String>? notEndsWithAll,
    List<String>? notEndsWithAny,
    String? notEndsWithInsensitive,
    List<String>? notEndsWithInsensitiveAll,
    List<String>? notEndsWithInsensitiveAny,
    String? notEqualTo,
    List<String>? notEqualToAll,
    List<String>? notEqualToAny,
    List<String>? notIn,
    List<String>? notInInsensitive,
    String? notIncludes,
    List<String>? notIncludesAll,
    List<String>? notIncludesAny,
    String? notIncludesInsensitive,
    List<String>? notIncludesInsensitiveAll,
    List<String>? notIncludesInsensitiveAny,
    String? notLike,
    List<String>? notLikeAll,
    List<String>? notLikeAny,
    String? notLikeInsensitive,
    List<String>? notLikeInsensitiveAll,
    List<String>? notLikeInsensitiveAny,
    String? notStartsWith,
    List<String>? notStartsWithAll,
    List<String>? notStartsWithAny,
    String? notStartsWithInsensitive,
    List<String>? notStartsWithInsensitiveAll,
    List<String>? notStartsWithInsensitiveAny,
    String? startsWith,
    List<String>? startsWithAll,
    List<String>? startsWithAny,
    String? startsWithInsensitive,
    List<String>? startsWithInsensitiveAll,
    List<String>? startsWithInsensitiveAny,
  }) =>
      _res;
}

class Input$TrackerConditionInput {
  factory Input$TrackerConditionInput({
    String? icon,
    int? id,
    bool? isLoggedIn,
    String? name,
  }) =>
      Input$TrackerConditionInput._({
        if (icon != null) r'icon': icon,
        if (id != null) r'id': id,
        if (isLoggedIn != null) r'isLoggedIn': isLoggedIn,
        if (name != null) r'name': name,
      });

  Input$TrackerConditionInput._(this._$data);

  factory Input$TrackerConditionInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('icon')) {
      final l$icon = data['icon'];
      result$data['icon'] = (l$icon as String?);
    }
    if (data.containsKey('id')) {
      final l$id = data['id'];
      result$data['id'] = (l$id as int?);
    }
    if (data.containsKey('isLoggedIn')) {
      final l$isLoggedIn = data['isLoggedIn'];
      result$data['isLoggedIn'] = (l$isLoggedIn as bool?);
    }
    if (data.containsKey('name')) {
      final l$name = data['name'];
      result$data['name'] = (l$name as String?);
    }
    return Input$TrackerConditionInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get icon => (_$data['icon'] as String?);

  int? get id => (_$data['id'] as int?);

  bool? get isLoggedIn => (_$data['isLoggedIn'] as bool?);

  String? get name => (_$data['name'] as String?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('icon')) {
      final l$icon = icon;
      result$data['icon'] = l$icon;
    }
    if (_$data.containsKey('id')) {
      final l$id = id;
      result$data['id'] = l$id;
    }
    if (_$data.containsKey('isLoggedIn')) {
      final l$isLoggedIn = isLoggedIn;
      result$data['isLoggedIn'] = l$isLoggedIn;
    }
    if (_$data.containsKey('name')) {
      final l$name = name;
      result$data['name'] = l$name;
    }
    return result$data;
  }

  CopyWith$Input$TrackerConditionInput<Input$TrackerConditionInput>
      get copyWith => CopyWith$Input$TrackerConditionInput(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$TrackerConditionInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$icon = icon;
    final lOther$icon = other.icon;
    if (_$data.containsKey('icon') != other._$data.containsKey('icon')) {
      return false;
    }
    if (l$icon != lOther$icon) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (_$data.containsKey('id') != other._$data.containsKey('id')) {
      return false;
    }
    if (l$id != lOther$id) {
      return false;
    }
    final l$isLoggedIn = isLoggedIn;
    final lOther$isLoggedIn = other.isLoggedIn;
    if (_$data.containsKey('isLoggedIn') !=
        other._$data.containsKey('isLoggedIn')) {
      return false;
    }
    if (l$isLoggedIn != lOther$isLoggedIn) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (_$data.containsKey('name') != other._$data.containsKey('name')) {
      return false;
    }
    if (l$name != lOther$name) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$icon = icon;
    final l$id = id;
    final l$isLoggedIn = isLoggedIn;
    final l$name = name;
    return Object.hashAll([
      _$data.containsKey('icon') ? l$icon : const {},
      _$data.containsKey('id') ? l$id : const {},
      _$data.containsKey('isLoggedIn') ? l$isLoggedIn : const {},
      _$data.containsKey('name') ? l$name : const {},
    ]);
  }
}

abstract class CopyWith$Input$TrackerConditionInput<TRes> {
  factory CopyWith$Input$TrackerConditionInput(
    Input$TrackerConditionInput instance,
    TRes Function(Input$TrackerConditionInput) then,
  ) = _CopyWithImpl$Input$TrackerConditionInput;

  factory CopyWith$Input$TrackerConditionInput.stub(TRes res) =
      _CopyWithStubImpl$Input$TrackerConditionInput;

  TRes call({
    String? icon,
    int? id,
    bool? isLoggedIn,
    String? name,
  });
}

class _CopyWithImpl$Input$TrackerConditionInput<TRes>
    implements CopyWith$Input$TrackerConditionInput<TRes> {
  _CopyWithImpl$Input$TrackerConditionInput(
    this._instance,
    this._then,
  );

  final Input$TrackerConditionInput _instance;

  final TRes Function(Input$TrackerConditionInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? icon = _undefined,
    Object? id = _undefined,
    Object? isLoggedIn = _undefined,
    Object? name = _undefined,
  }) =>
      _then(Input$TrackerConditionInput._({
        ..._instance._$data,
        if (icon != _undefined) 'icon': (icon as String?),
        if (id != _undefined) 'id': (id as int?),
        if (isLoggedIn != _undefined) 'isLoggedIn': (isLoggedIn as bool?),
        if (name != _undefined) 'name': (name as String?),
      }));
}

class _CopyWithStubImpl$Input$TrackerConditionInput<TRes>
    implements CopyWith$Input$TrackerConditionInput<TRes> {
  _CopyWithStubImpl$Input$TrackerConditionInput(this._res);

  TRes _res;

  call({
    String? icon,
    int? id,
    bool? isLoggedIn,
    String? name,
  }) =>
      _res;
}

class Input$TrackerOrderInput {
  factory Input$TrackerOrderInput({
    required Enum$TrackerOrderBy by,
    Enum$SortOrder? byType,
  }) =>
      Input$TrackerOrderInput._({
        r'by': by,
        if (byType != null) r'byType': byType,
      });

  Input$TrackerOrderInput._(this._$data);

  factory Input$TrackerOrderInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$by = data['by'];
    result$data['by'] = fromJson$Enum$TrackerOrderBy((l$by as String));
    if (data.containsKey('byType')) {
      final l$byType = data['byType'];
      result$data['byType'] = l$byType == null
          ? null
          : fromJson$Enum$SortOrder((l$byType as String));
    }
    return Input$TrackerOrderInput._(result$data);
  }

  Map<String, dynamic> _$data;

  Enum$TrackerOrderBy get by => (_$data['by'] as Enum$TrackerOrderBy);

  Enum$SortOrder? get byType => (_$data['byType'] as Enum$SortOrder?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$by = by;
    result$data['by'] = toJson$Enum$TrackerOrderBy(l$by);
    if (_$data.containsKey('byType')) {
      final l$byType = byType;
      result$data['byType'] =
          l$byType == null ? null : toJson$Enum$SortOrder(l$byType);
    }
    return result$data;
  }

  CopyWith$Input$TrackerOrderInput<Input$TrackerOrderInput> get copyWith =>
      CopyWith$Input$TrackerOrderInput(
        this,
        (i) => i,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$TrackerOrderInput || runtimeType != other.runtimeType) {
      return false;
    }
    final l$by = by;
    final lOther$by = other.by;
    if (l$by != lOther$by) {
      return false;
    }
    final l$byType = byType;
    final lOther$byType = other.byType;
    if (_$data.containsKey('byType') != other._$data.containsKey('byType')) {
      return false;
    }
    if (l$byType != lOther$byType) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$by = by;
    final l$byType = byType;
    return Object.hashAll([
      l$by,
      _$data.containsKey('byType') ? l$byType : const {},
    ]);
  }
}

abstract class CopyWith$Input$TrackerOrderInput<TRes> {
  factory CopyWith$Input$TrackerOrderInput(
    Input$TrackerOrderInput instance,
    TRes Function(Input$TrackerOrderInput) then,
  ) = _CopyWithImpl$Input$TrackerOrderInput;

  factory CopyWith$Input$TrackerOrderInput.stub(TRes res) =
      _CopyWithStubImpl$Input$TrackerOrderInput;

  TRes call({
    Enum$TrackerOrderBy? by,
    Enum$SortOrder? byType,
  });
}

class _CopyWithImpl$Input$TrackerOrderInput<TRes>
    implements CopyWith$Input$TrackerOrderInput<TRes> {
  _CopyWithImpl$Input$TrackerOrderInput(
    this._instance,
    this._then,
  );

  final Input$TrackerOrderInput _instance;

  final TRes Function(Input$TrackerOrderInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? by = _undefined,
    Object? byType = _undefined,
  }) =>
      _then(Input$TrackerOrderInput._({
        ..._instance._$data,
        if (by != _undefined && by != null) 'by': (by as Enum$TrackerOrderBy),
        if (byType != _undefined) 'byType': (byType as Enum$SortOrder?),
      }));
}

class _CopyWithStubImpl$Input$TrackerOrderInput<TRes>
    implements CopyWith$Input$TrackerOrderInput<TRes> {
  _CopyWithStubImpl$Input$TrackerOrderInput(this._res);

  TRes _res;

  call({
    Enum$TrackerOrderBy? by,
    Enum$SortOrder? byType,
  }) =>
      _res;
}

class Input$TrackProgressInput {
  factory Input$TrackProgressInput({
    String? clientMutationId,
    required int mangaId,
  }) =>
      Input$TrackProgressInput._({
        if (clientMutationId != null) r'clientMutationId': clientMutationId,
        r'mangaId': mangaId,
      });

  Input$TrackProgressInput._(this._$data);

  factory Input$TrackProgressInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('clientMutationId')) {
      final l$clientMutationId = data['clientMutationId'];
      result$data['clientMutationId'] = (l$clientMutationId as String?);
    }
    final l$mangaId = data['mangaId'];
    result$data['mangaId'] = (l$mangaId as int);
    return Input$TrackProgressInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get clientMutationId => (_$data['clientMutationId'] as String?);

  int get mangaId => (_$data['mangaId'] as int);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('clientMutationId')) {
      final l$clientMutationId = clientMutationId;
      result$data['clientMutationId'] = l$clientMutationId;
    }
    final l$mangaId = mangaId;
    result$data['mangaId'] = l$mangaId;
    return result$data;
  }

  CopyWith$Input$TrackProgressInput<Input$TrackProgressInput> get copyWith =>
      CopyWith$Input$TrackProgressInput(
        this,
        (i) => i,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$TrackProgressInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (_$data.containsKey('clientMutationId') !=
        other._$data.containsKey('clientMutationId')) {
      return false;
    }
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    final l$mangaId = mangaId;
    final lOther$mangaId = other.mangaId;
    if (l$mangaId != lOther$mangaId) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$clientMutationId = clientMutationId;
    final l$mangaId = mangaId;
    return Object.hashAll([
      _$data.containsKey('clientMutationId') ? l$clientMutationId : const {},
      l$mangaId,
    ]);
  }
}

abstract class CopyWith$Input$TrackProgressInput<TRes> {
  factory CopyWith$Input$TrackProgressInput(
    Input$TrackProgressInput instance,
    TRes Function(Input$TrackProgressInput) then,
  ) = _CopyWithImpl$Input$TrackProgressInput;

  factory CopyWith$Input$TrackProgressInput.stub(TRes res) =
      _CopyWithStubImpl$Input$TrackProgressInput;

  TRes call({
    String? clientMutationId,
    int? mangaId,
  });
}

class _CopyWithImpl$Input$TrackProgressInput<TRes>
    implements CopyWith$Input$TrackProgressInput<TRes> {
  _CopyWithImpl$Input$TrackProgressInput(
    this._instance,
    this._then,
  );

  final Input$TrackProgressInput _instance;

  final TRes Function(Input$TrackProgressInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? clientMutationId = _undefined,
    Object? mangaId = _undefined,
  }) =>
      _then(Input$TrackProgressInput._({
        ..._instance._$data,
        if (clientMutationId != _undefined)
          'clientMutationId': (clientMutationId as String?),
        if (mangaId != _undefined && mangaId != null)
          'mangaId': (mangaId as int),
      }));
}

class _CopyWithStubImpl$Input$TrackProgressInput<TRes>
    implements CopyWith$Input$TrackProgressInput<TRes> {
  _CopyWithStubImpl$Input$TrackProgressInput(this._res);

  TRes _res;

  call({
    String? clientMutationId,
    int? mangaId,
  }) =>
      _res;
}

class Input$TrackRecordConditionInput {
  factory Input$TrackRecordConditionInput({
    String? finishDate,
    int? id,
    double? lastChapterRead,
    String? libraryId,
    int? mangaId,
    String? remoteId,
    String? remoteUrl,
    double? score,
    String? startDate,
    int? status,
    String? title,
    int? totalChapters,
    int? trackerId,
  }) =>
      Input$TrackRecordConditionInput._({
        if (finishDate != null) r'finishDate': finishDate,
        if (id != null) r'id': id,
        if (lastChapterRead != null) r'lastChapterRead': lastChapterRead,
        if (libraryId != null) r'libraryId': libraryId,
        if (mangaId != null) r'mangaId': mangaId,
        if (remoteId != null) r'remoteId': remoteId,
        if (remoteUrl != null) r'remoteUrl': remoteUrl,
        if (score != null) r'score': score,
        if (startDate != null) r'startDate': startDate,
        if (status != null) r'status': status,
        if (title != null) r'title': title,
        if (totalChapters != null) r'totalChapters': totalChapters,
        if (trackerId != null) r'trackerId': trackerId,
      });

  Input$TrackRecordConditionInput._(this._$data);

  factory Input$TrackRecordConditionInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('finishDate')) {
      final l$finishDate = data['finishDate'];
      result$data['finishDate'] =
          l$finishDate == null ? null : longStringFromJson(l$finishDate);
    }
    if (data.containsKey('id')) {
      final l$id = data['id'];
      result$data['id'] = (l$id as int?);
    }
    if (data.containsKey('lastChapterRead')) {
      final l$lastChapterRead = data['lastChapterRead'];
      result$data['lastChapterRead'] = (l$lastChapterRead as num?)?.toDouble();
    }
    if (data.containsKey('libraryId')) {
      final l$libraryId = data['libraryId'];
      result$data['libraryId'] =
          l$libraryId == null ? null : longStringFromJson(l$libraryId);
    }
    if (data.containsKey('mangaId')) {
      final l$mangaId = data['mangaId'];
      result$data['mangaId'] = (l$mangaId as int?);
    }
    if (data.containsKey('remoteId')) {
      final l$remoteId = data['remoteId'];
      result$data['remoteId'] =
          l$remoteId == null ? null : longStringFromJson(l$remoteId);
    }
    if (data.containsKey('remoteUrl')) {
      final l$remoteUrl = data['remoteUrl'];
      result$data['remoteUrl'] = (l$remoteUrl as String?);
    }
    if (data.containsKey('score')) {
      final l$score = data['score'];
      result$data['score'] = (l$score as num?)?.toDouble();
    }
    if (data.containsKey('startDate')) {
      final l$startDate = data['startDate'];
      result$data['startDate'] =
          l$startDate == null ? null : longStringFromJson(l$startDate);
    }
    if (data.containsKey('status')) {
      final l$status = data['status'];
      result$data['status'] = (l$status as int?);
    }
    if (data.containsKey('title')) {
      final l$title = data['title'];
      result$data['title'] = (l$title as String?);
    }
    if (data.containsKey('totalChapters')) {
      final l$totalChapters = data['totalChapters'];
      result$data['totalChapters'] = (l$totalChapters as int?);
    }
    if (data.containsKey('trackerId')) {
      final l$trackerId = data['trackerId'];
      result$data['trackerId'] = (l$trackerId as int?);
    }
    return Input$TrackRecordConditionInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get finishDate => (_$data['finishDate'] as String?);

  int? get id => (_$data['id'] as int?);

  double? get lastChapterRead => (_$data['lastChapterRead'] as double?);

  String? get libraryId => (_$data['libraryId'] as String?);

  int? get mangaId => (_$data['mangaId'] as int?);

  String? get remoteId => (_$data['remoteId'] as String?);

  String? get remoteUrl => (_$data['remoteUrl'] as String?);

  double? get score => (_$data['score'] as double?);

  String? get startDate => (_$data['startDate'] as String?);

  int? get status => (_$data['status'] as int?);

  String? get title => (_$data['title'] as String?);

  int? get totalChapters => (_$data['totalChapters'] as int?);

  int? get trackerId => (_$data['trackerId'] as int?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('finishDate')) {
      final l$finishDate = finishDate;
      result$data['finishDate'] =
          l$finishDate == null ? null : longStringToJson(l$finishDate);
    }
    if (_$data.containsKey('id')) {
      final l$id = id;
      result$data['id'] = l$id;
    }
    if (_$data.containsKey('lastChapterRead')) {
      final l$lastChapterRead = lastChapterRead;
      result$data['lastChapterRead'] = l$lastChapterRead;
    }
    if (_$data.containsKey('libraryId')) {
      final l$libraryId = libraryId;
      result$data['libraryId'] =
          l$libraryId == null ? null : longStringToJson(l$libraryId);
    }
    if (_$data.containsKey('mangaId')) {
      final l$mangaId = mangaId;
      result$data['mangaId'] = l$mangaId;
    }
    if (_$data.containsKey('remoteId')) {
      final l$remoteId = remoteId;
      result$data['remoteId'] =
          l$remoteId == null ? null : longStringToJson(l$remoteId);
    }
    if (_$data.containsKey('remoteUrl')) {
      final l$remoteUrl = remoteUrl;
      result$data['remoteUrl'] = l$remoteUrl;
    }
    if (_$data.containsKey('score')) {
      final l$score = score;
      result$data['score'] = l$score;
    }
    if (_$data.containsKey('startDate')) {
      final l$startDate = startDate;
      result$data['startDate'] =
          l$startDate == null ? null : longStringToJson(l$startDate);
    }
    if (_$data.containsKey('status')) {
      final l$status = status;
      result$data['status'] = l$status;
    }
    if (_$data.containsKey('title')) {
      final l$title = title;
      result$data['title'] = l$title;
    }
    if (_$data.containsKey('totalChapters')) {
      final l$totalChapters = totalChapters;
      result$data['totalChapters'] = l$totalChapters;
    }
    if (_$data.containsKey('trackerId')) {
      final l$trackerId = trackerId;
      result$data['trackerId'] = l$trackerId;
    }
    return result$data;
  }

  CopyWith$Input$TrackRecordConditionInput<Input$TrackRecordConditionInput>
      get copyWith => CopyWith$Input$TrackRecordConditionInput(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$TrackRecordConditionInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$finishDate = finishDate;
    final lOther$finishDate = other.finishDate;
    if (_$data.containsKey('finishDate') !=
        other._$data.containsKey('finishDate')) {
      return false;
    }
    if (l$finishDate != lOther$finishDate) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (_$data.containsKey('id') != other._$data.containsKey('id')) {
      return false;
    }
    if (l$id != lOther$id) {
      return false;
    }
    final l$lastChapterRead = lastChapterRead;
    final lOther$lastChapterRead = other.lastChapterRead;
    if (_$data.containsKey('lastChapterRead') !=
        other._$data.containsKey('lastChapterRead')) {
      return false;
    }
    if (l$lastChapterRead != lOther$lastChapterRead) {
      return false;
    }
    final l$libraryId = libraryId;
    final lOther$libraryId = other.libraryId;
    if (_$data.containsKey('libraryId') !=
        other._$data.containsKey('libraryId')) {
      return false;
    }
    if (l$libraryId != lOther$libraryId) {
      return false;
    }
    final l$mangaId = mangaId;
    final lOther$mangaId = other.mangaId;
    if (_$data.containsKey('mangaId') != other._$data.containsKey('mangaId')) {
      return false;
    }
    if (l$mangaId != lOther$mangaId) {
      return false;
    }
    final l$remoteId = remoteId;
    final lOther$remoteId = other.remoteId;
    if (_$data.containsKey('remoteId') !=
        other._$data.containsKey('remoteId')) {
      return false;
    }
    if (l$remoteId != lOther$remoteId) {
      return false;
    }
    final l$remoteUrl = remoteUrl;
    final lOther$remoteUrl = other.remoteUrl;
    if (_$data.containsKey('remoteUrl') !=
        other._$data.containsKey('remoteUrl')) {
      return false;
    }
    if (l$remoteUrl != lOther$remoteUrl) {
      return false;
    }
    final l$score = score;
    final lOther$score = other.score;
    if (_$data.containsKey('score') != other._$data.containsKey('score')) {
      return false;
    }
    if (l$score != lOther$score) {
      return false;
    }
    final l$startDate = startDate;
    final lOther$startDate = other.startDate;
    if (_$data.containsKey('startDate') !=
        other._$data.containsKey('startDate')) {
      return false;
    }
    if (l$startDate != lOther$startDate) {
      return false;
    }
    final l$status = status;
    final lOther$status = other.status;
    if (_$data.containsKey('status') != other._$data.containsKey('status')) {
      return false;
    }
    if (l$status != lOther$status) {
      return false;
    }
    final l$title = title;
    final lOther$title = other.title;
    if (_$data.containsKey('title') != other._$data.containsKey('title')) {
      return false;
    }
    if (l$title != lOther$title) {
      return false;
    }
    final l$totalChapters = totalChapters;
    final lOther$totalChapters = other.totalChapters;
    if (_$data.containsKey('totalChapters') !=
        other._$data.containsKey('totalChapters')) {
      return false;
    }
    if (l$totalChapters != lOther$totalChapters) {
      return false;
    }
    final l$trackerId = trackerId;
    final lOther$trackerId = other.trackerId;
    if (_$data.containsKey('trackerId') !=
        other._$data.containsKey('trackerId')) {
      return false;
    }
    if (l$trackerId != lOther$trackerId) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$finishDate = finishDate;
    final l$id = id;
    final l$lastChapterRead = lastChapterRead;
    final l$libraryId = libraryId;
    final l$mangaId = mangaId;
    final l$remoteId = remoteId;
    final l$remoteUrl = remoteUrl;
    final l$score = score;
    final l$startDate = startDate;
    final l$status = status;
    final l$title = title;
    final l$totalChapters = totalChapters;
    final l$trackerId = trackerId;
    return Object.hashAll([
      _$data.containsKey('finishDate') ? l$finishDate : const {},
      _$data.containsKey('id') ? l$id : const {},
      _$data.containsKey('lastChapterRead') ? l$lastChapterRead : const {},
      _$data.containsKey('libraryId') ? l$libraryId : const {},
      _$data.containsKey('mangaId') ? l$mangaId : const {},
      _$data.containsKey('remoteId') ? l$remoteId : const {},
      _$data.containsKey('remoteUrl') ? l$remoteUrl : const {},
      _$data.containsKey('score') ? l$score : const {},
      _$data.containsKey('startDate') ? l$startDate : const {},
      _$data.containsKey('status') ? l$status : const {},
      _$data.containsKey('title') ? l$title : const {},
      _$data.containsKey('totalChapters') ? l$totalChapters : const {},
      _$data.containsKey('trackerId') ? l$trackerId : const {},
    ]);
  }
}

abstract class CopyWith$Input$TrackRecordConditionInput<TRes> {
  factory CopyWith$Input$TrackRecordConditionInput(
    Input$TrackRecordConditionInput instance,
    TRes Function(Input$TrackRecordConditionInput) then,
  ) = _CopyWithImpl$Input$TrackRecordConditionInput;

  factory CopyWith$Input$TrackRecordConditionInput.stub(TRes res) =
      _CopyWithStubImpl$Input$TrackRecordConditionInput;

  TRes call({
    String? finishDate,
    int? id,
    double? lastChapterRead,
    String? libraryId,
    int? mangaId,
    String? remoteId,
    String? remoteUrl,
    double? score,
    String? startDate,
    int? status,
    String? title,
    int? totalChapters,
    int? trackerId,
  });
}

class _CopyWithImpl$Input$TrackRecordConditionInput<TRes>
    implements CopyWith$Input$TrackRecordConditionInput<TRes> {
  _CopyWithImpl$Input$TrackRecordConditionInput(
    this._instance,
    this._then,
  );

  final Input$TrackRecordConditionInput _instance;

  final TRes Function(Input$TrackRecordConditionInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? finishDate = _undefined,
    Object? id = _undefined,
    Object? lastChapterRead = _undefined,
    Object? libraryId = _undefined,
    Object? mangaId = _undefined,
    Object? remoteId = _undefined,
    Object? remoteUrl = _undefined,
    Object? score = _undefined,
    Object? startDate = _undefined,
    Object? status = _undefined,
    Object? title = _undefined,
    Object? totalChapters = _undefined,
    Object? trackerId = _undefined,
  }) =>
      _then(Input$TrackRecordConditionInput._({
        ..._instance._$data,
        if (finishDate != _undefined) 'finishDate': (finishDate as String?),
        if (id != _undefined) 'id': (id as int?),
        if (lastChapterRead != _undefined)
          'lastChapterRead': (lastChapterRead as double?),
        if (libraryId != _undefined) 'libraryId': (libraryId as String?),
        if (mangaId != _undefined) 'mangaId': (mangaId as int?),
        if (remoteId != _undefined) 'remoteId': (remoteId as String?),
        if (remoteUrl != _undefined) 'remoteUrl': (remoteUrl as String?),
        if (score != _undefined) 'score': (score as double?),
        if (startDate != _undefined) 'startDate': (startDate as String?),
        if (status != _undefined) 'status': (status as int?),
        if (title != _undefined) 'title': (title as String?),
        if (totalChapters != _undefined)
          'totalChapters': (totalChapters as int?),
        if (trackerId != _undefined) 'trackerId': (trackerId as int?),
      }));
}

class _CopyWithStubImpl$Input$TrackRecordConditionInput<TRes>
    implements CopyWith$Input$TrackRecordConditionInput<TRes> {
  _CopyWithStubImpl$Input$TrackRecordConditionInput(this._res);

  TRes _res;

  call({
    String? finishDate,
    int? id,
    double? lastChapterRead,
    String? libraryId,
    int? mangaId,
    String? remoteId,
    String? remoteUrl,
    double? score,
    String? startDate,
    int? status,
    String? title,
    int? totalChapters,
    int? trackerId,
  }) =>
      _res;
}

class Input$TrackRecordFilterInput {
  factory Input$TrackRecordFilterInput({
    List<Input$TrackRecordFilterInput>? and,
    Input$LongFilterInput? finishDate,
    Input$IntFilterInput? id,
    Input$DoubleFilterInput? lastChapterRead,
    Input$LongFilterInput? libraryId,
    Input$IntFilterInput? mangaId,
    Input$TrackRecordFilterInput? not,
    List<Input$TrackRecordFilterInput>? or,
    Input$LongFilterInput? remoteId,
    Input$StringFilterInput? remoteUrl,
    Input$DoubleFilterInput? score,
    Input$LongFilterInput? startDate,
    Input$IntFilterInput? status,
    Input$StringFilterInput? title,
    Input$IntFilterInput? totalChapters,
    Input$IntFilterInput? trackerId,
  }) =>
      Input$TrackRecordFilterInput._({
        if (and != null) r'and': and,
        if (finishDate != null) r'finishDate': finishDate,
        if (id != null) r'id': id,
        if (lastChapterRead != null) r'lastChapterRead': lastChapterRead,
        if (libraryId != null) r'libraryId': libraryId,
        if (mangaId != null) r'mangaId': mangaId,
        if (not != null) r'not': not,
        if (or != null) r'or': or,
        if (remoteId != null) r'remoteId': remoteId,
        if (remoteUrl != null) r'remoteUrl': remoteUrl,
        if (score != null) r'score': score,
        if (startDate != null) r'startDate': startDate,
        if (status != null) r'status': status,
        if (title != null) r'title': title,
        if (totalChapters != null) r'totalChapters': totalChapters,
        if (trackerId != null) r'trackerId': trackerId,
      });

  Input$TrackRecordFilterInput._(this._$data);

  factory Input$TrackRecordFilterInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('and')) {
      final l$and = data['and'];
      result$data['and'] = (l$and as List<dynamic>?)
          ?.map((e) => Input$TrackRecordFilterInput.fromJson(
              (e as Map<String, dynamic>)))
          .toList();
    }
    if (data.containsKey('finishDate')) {
      final l$finishDate = data['finishDate'];
      result$data['finishDate'] = l$finishDate == null
          ? null
          : Input$LongFilterInput.fromJson(
              (l$finishDate as Map<String, dynamic>));
    }
    if (data.containsKey('id')) {
      final l$id = data['id'];
      result$data['id'] = l$id == null
          ? null
          : Input$IntFilterInput.fromJson((l$id as Map<String, dynamic>));
    }
    if (data.containsKey('lastChapterRead')) {
      final l$lastChapterRead = data['lastChapterRead'];
      result$data['lastChapterRead'] = l$lastChapterRead == null
          ? null
          : Input$DoubleFilterInput.fromJson(
              (l$lastChapterRead as Map<String, dynamic>));
    }
    if (data.containsKey('libraryId')) {
      final l$libraryId = data['libraryId'];
      result$data['libraryId'] = l$libraryId == null
          ? null
          : Input$LongFilterInput.fromJson(
              (l$libraryId as Map<String, dynamic>));
    }
    if (data.containsKey('mangaId')) {
      final l$mangaId = data['mangaId'];
      result$data['mangaId'] = l$mangaId == null
          ? null
          : Input$IntFilterInput.fromJson((l$mangaId as Map<String, dynamic>));
    }
    if (data.containsKey('not')) {
      final l$not = data['not'];
      result$data['not'] = l$not == null
          ? null
          : Input$TrackRecordFilterInput.fromJson(
              (l$not as Map<String, dynamic>));
    }
    if (data.containsKey('or')) {
      final l$or = data['or'];
      result$data['or'] = (l$or as List<dynamic>?)
          ?.map((e) => Input$TrackRecordFilterInput.fromJson(
              (e as Map<String, dynamic>)))
          .toList();
    }
    if (data.containsKey('remoteId')) {
      final l$remoteId = data['remoteId'];
      result$data['remoteId'] = l$remoteId == null
          ? null
          : Input$LongFilterInput.fromJson(
              (l$remoteId as Map<String, dynamic>));
    }
    if (data.containsKey('remoteUrl')) {
      final l$remoteUrl = data['remoteUrl'];
      result$data['remoteUrl'] = l$remoteUrl == null
          ? null
          : Input$StringFilterInput.fromJson(
              (l$remoteUrl as Map<String, dynamic>));
    }
    if (data.containsKey('score')) {
      final l$score = data['score'];
      result$data['score'] = l$score == null
          ? null
          : Input$DoubleFilterInput.fromJson((l$score as Map<String, dynamic>));
    }
    if (data.containsKey('startDate')) {
      final l$startDate = data['startDate'];
      result$data['startDate'] = l$startDate == null
          ? null
          : Input$LongFilterInput.fromJson(
              (l$startDate as Map<String, dynamic>));
    }
    if (data.containsKey('status')) {
      final l$status = data['status'];
      result$data['status'] = l$status == null
          ? null
          : Input$IntFilterInput.fromJson((l$status as Map<String, dynamic>));
    }
    if (data.containsKey('title')) {
      final l$title = data['title'];
      result$data['title'] = l$title == null
          ? null
          : Input$StringFilterInput.fromJson((l$title as Map<String, dynamic>));
    }
    if (data.containsKey('totalChapters')) {
      final l$totalChapters = data['totalChapters'];
      result$data['totalChapters'] = l$totalChapters == null
          ? null
          : Input$IntFilterInput.fromJson(
              (l$totalChapters as Map<String, dynamic>));
    }
    if (data.containsKey('trackerId')) {
      final l$trackerId = data['trackerId'];
      result$data['trackerId'] = l$trackerId == null
          ? null
          : Input$IntFilterInput.fromJson(
              (l$trackerId as Map<String, dynamic>));
    }
    return Input$TrackRecordFilterInput._(result$data);
  }

  Map<String, dynamic> _$data;

  List<Input$TrackRecordFilterInput>? get and =>
      (_$data['and'] as List<Input$TrackRecordFilterInput>?);

  Input$LongFilterInput? get finishDate =>
      (_$data['finishDate'] as Input$LongFilterInput?);

  Input$IntFilterInput? get id => (_$data['id'] as Input$IntFilterInput?);

  Input$DoubleFilterInput? get lastChapterRead =>
      (_$data['lastChapterRead'] as Input$DoubleFilterInput?);

  Input$LongFilterInput? get libraryId =>
      (_$data['libraryId'] as Input$LongFilterInput?);

  Input$IntFilterInput? get mangaId =>
      (_$data['mangaId'] as Input$IntFilterInput?);

  Input$TrackRecordFilterInput? get not =>
      (_$data['not'] as Input$TrackRecordFilterInput?);

  List<Input$TrackRecordFilterInput>? get or =>
      (_$data['or'] as List<Input$TrackRecordFilterInput>?);

  Input$LongFilterInput? get remoteId =>
      (_$data['remoteId'] as Input$LongFilterInput?);

  Input$StringFilterInput? get remoteUrl =>
      (_$data['remoteUrl'] as Input$StringFilterInput?);

  Input$DoubleFilterInput? get score =>
      (_$data['score'] as Input$DoubleFilterInput?);

  Input$LongFilterInput? get startDate =>
      (_$data['startDate'] as Input$LongFilterInput?);

  Input$IntFilterInput? get status =>
      (_$data['status'] as Input$IntFilterInput?);

  Input$StringFilterInput? get title =>
      (_$data['title'] as Input$StringFilterInput?);

  Input$IntFilterInput? get totalChapters =>
      (_$data['totalChapters'] as Input$IntFilterInput?);

  Input$IntFilterInput? get trackerId =>
      (_$data['trackerId'] as Input$IntFilterInput?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('and')) {
      final l$and = and;
      result$data['and'] = l$and?.map((e) => e.toJson()).toList();
    }
    if (_$data.containsKey('finishDate')) {
      final l$finishDate = finishDate;
      result$data['finishDate'] = l$finishDate?.toJson();
    }
    if (_$data.containsKey('id')) {
      final l$id = id;
      result$data['id'] = l$id?.toJson();
    }
    if (_$data.containsKey('lastChapterRead')) {
      final l$lastChapterRead = lastChapterRead;
      result$data['lastChapterRead'] = l$lastChapterRead?.toJson();
    }
    if (_$data.containsKey('libraryId')) {
      final l$libraryId = libraryId;
      result$data['libraryId'] = l$libraryId?.toJson();
    }
    if (_$data.containsKey('mangaId')) {
      final l$mangaId = mangaId;
      result$data['mangaId'] = l$mangaId?.toJson();
    }
    if (_$data.containsKey('not')) {
      final l$not = not;
      result$data['not'] = l$not?.toJson();
    }
    if (_$data.containsKey('or')) {
      final l$or = or;
      result$data['or'] = l$or?.map((e) => e.toJson()).toList();
    }
    if (_$data.containsKey('remoteId')) {
      final l$remoteId = remoteId;
      result$data['remoteId'] = l$remoteId?.toJson();
    }
    if (_$data.containsKey('remoteUrl')) {
      final l$remoteUrl = remoteUrl;
      result$data['remoteUrl'] = l$remoteUrl?.toJson();
    }
    if (_$data.containsKey('score')) {
      final l$score = score;
      result$data['score'] = l$score?.toJson();
    }
    if (_$data.containsKey('startDate')) {
      final l$startDate = startDate;
      result$data['startDate'] = l$startDate?.toJson();
    }
    if (_$data.containsKey('status')) {
      final l$status = status;
      result$data['status'] = l$status?.toJson();
    }
    if (_$data.containsKey('title')) {
      final l$title = title;
      result$data['title'] = l$title?.toJson();
    }
    if (_$data.containsKey('totalChapters')) {
      final l$totalChapters = totalChapters;
      result$data['totalChapters'] = l$totalChapters?.toJson();
    }
    if (_$data.containsKey('trackerId')) {
      final l$trackerId = trackerId;
      result$data['trackerId'] = l$trackerId?.toJson();
    }
    return result$data;
  }

  CopyWith$Input$TrackRecordFilterInput<Input$TrackRecordFilterInput>
      get copyWith => CopyWith$Input$TrackRecordFilterInput(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$TrackRecordFilterInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$and = and;
    final lOther$and = other.and;
    if (_$data.containsKey('and') != other._$data.containsKey('and')) {
      return false;
    }
    if (l$and != null && lOther$and != null) {
      if (l$and.length != lOther$and.length) {
        return false;
      }
      for (int i = 0; i < l$and.length; i++) {
        final l$and$entry = l$and[i];
        final lOther$and$entry = lOther$and[i];
        if (l$and$entry != lOther$and$entry) {
          return false;
        }
      }
    } else if (l$and != lOther$and) {
      return false;
    }
    final l$finishDate = finishDate;
    final lOther$finishDate = other.finishDate;
    if (_$data.containsKey('finishDate') !=
        other._$data.containsKey('finishDate')) {
      return false;
    }
    if (l$finishDate != lOther$finishDate) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (_$data.containsKey('id') != other._$data.containsKey('id')) {
      return false;
    }
    if (l$id != lOther$id) {
      return false;
    }
    final l$lastChapterRead = lastChapterRead;
    final lOther$lastChapterRead = other.lastChapterRead;
    if (_$data.containsKey('lastChapterRead') !=
        other._$data.containsKey('lastChapterRead')) {
      return false;
    }
    if (l$lastChapterRead != lOther$lastChapterRead) {
      return false;
    }
    final l$libraryId = libraryId;
    final lOther$libraryId = other.libraryId;
    if (_$data.containsKey('libraryId') !=
        other._$data.containsKey('libraryId')) {
      return false;
    }
    if (l$libraryId != lOther$libraryId) {
      return false;
    }
    final l$mangaId = mangaId;
    final lOther$mangaId = other.mangaId;
    if (_$data.containsKey('mangaId') != other._$data.containsKey('mangaId')) {
      return false;
    }
    if (l$mangaId != lOther$mangaId) {
      return false;
    }
    final l$not = not;
    final lOther$not = other.not;
    if (_$data.containsKey('not') != other._$data.containsKey('not')) {
      return false;
    }
    if (l$not != lOther$not) {
      return false;
    }
    final l$or = or;
    final lOther$or = other.or;
    if (_$data.containsKey('or') != other._$data.containsKey('or')) {
      return false;
    }
    if (l$or != null && lOther$or != null) {
      if (l$or.length != lOther$or.length) {
        return false;
      }
      for (int i = 0; i < l$or.length; i++) {
        final l$or$entry = l$or[i];
        final lOther$or$entry = lOther$or[i];
        if (l$or$entry != lOther$or$entry) {
          return false;
        }
      }
    } else if (l$or != lOther$or) {
      return false;
    }
    final l$remoteId = remoteId;
    final lOther$remoteId = other.remoteId;
    if (_$data.containsKey('remoteId') !=
        other._$data.containsKey('remoteId')) {
      return false;
    }
    if (l$remoteId != lOther$remoteId) {
      return false;
    }
    final l$remoteUrl = remoteUrl;
    final lOther$remoteUrl = other.remoteUrl;
    if (_$data.containsKey('remoteUrl') !=
        other._$data.containsKey('remoteUrl')) {
      return false;
    }
    if (l$remoteUrl != lOther$remoteUrl) {
      return false;
    }
    final l$score = score;
    final lOther$score = other.score;
    if (_$data.containsKey('score') != other._$data.containsKey('score')) {
      return false;
    }
    if (l$score != lOther$score) {
      return false;
    }
    final l$startDate = startDate;
    final lOther$startDate = other.startDate;
    if (_$data.containsKey('startDate') !=
        other._$data.containsKey('startDate')) {
      return false;
    }
    if (l$startDate != lOther$startDate) {
      return false;
    }
    final l$status = status;
    final lOther$status = other.status;
    if (_$data.containsKey('status') != other._$data.containsKey('status')) {
      return false;
    }
    if (l$status != lOther$status) {
      return false;
    }
    final l$title = title;
    final lOther$title = other.title;
    if (_$data.containsKey('title') != other._$data.containsKey('title')) {
      return false;
    }
    if (l$title != lOther$title) {
      return false;
    }
    final l$totalChapters = totalChapters;
    final lOther$totalChapters = other.totalChapters;
    if (_$data.containsKey('totalChapters') !=
        other._$data.containsKey('totalChapters')) {
      return false;
    }
    if (l$totalChapters != lOther$totalChapters) {
      return false;
    }
    final l$trackerId = trackerId;
    final lOther$trackerId = other.trackerId;
    if (_$data.containsKey('trackerId') !=
        other._$data.containsKey('trackerId')) {
      return false;
    }
    if (l$trackerId != lOther$trackerId) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$and = and;
    final l$finishDate = finishDate;
    final l$id = id;
    final l$lastChapterRead = lastChapterRead;
    final l$libraryId = libraryId;
    final l$mangaId = mangaId;
    final l$not = not;
    final l$or = or;
    final l$remoteId = remoteId;
    final l$remoteUrl = remoteUrl;
    final l$score = score;
    final l$startDate = startDate;
    final l$status = status;
    final l$title = title;
    final l$totalChapters = totalChapters;
    final l$trackerId = trackerId;
    return Object.hashAll([
      _$data.containsKey('and')
          ? l$and == null
              ? null
              : Object.hashAll(l$and.map((v) => v))
          : const {},
      _$data.containsKey('finishDate') ? l$finishDate : const {},
      _$data.containsKey('id') ? l$id : const {},
      _$data.containsKey('lastChapterRead') ? l$lastChapterRead : const {},
      _$data.containsKey('libraryId') ? l$libraryId : const {},
      _$data.containsKey('mangaId') ? l$mangaId : const {},
      _$data.containsKey('not') ? l$not : const {},
      _$data.containsKey('or')
          ? l$or == null
              ? null
              : Object.hashAll(l$or.map((v) => v))
          : const {},
      _$data.containsKey('remoteId') ? l$remoteId : const {},
      _$data.containsKey('remoteUrl') ? l$remoteUrl : const {},
      _$data.containsKey('score') ? l$score : const {},
      _$data.containsKey('startDate') ? l$startDate : const {},
      _$data.containsKey('status') ? l$status : const {},
      _$data.containsKey('title') ? l$title : const {},
      _$data.containsKey('totalChapters') ? l$totalChapters : const {},
      _$data.containsKey('trackerId') ? l$trackerId : const {},
    ]);
  }
}

abstract class CopyWith$Input$TrackRecordFilterInput<TRes> {
  factory CopyWith$Input$TrackRecordFilterInput(
    Input$TrackRecordFilterInput instance,
    TRes Function(Input$TrackRecordFilterInput) then,
  ) = _CopyWithImpl$Input$TrackRecordFilterInput;

  factory CopyWith$Input$TrackRecordFilterInput.stub(TRes res) =
      _CopyWithStubImpl$Input$TrackRecordFilterInput;

  TRes call({
    List<Input$TrackRecordFilterInput>? and,
    Input$LongFilterInput? finishDate,
    Input$IntFilterInput? id,
    Input$DoubleFilterInput? lastChapterRead,
    Input$LongFilterInput? libraryId,
    Input$IntFilterInput? mangaId,
    Input$TrackRecordFilterInput? not,
    List<Input$TrackRecordFilterInput>? or,
    Input$LongFilterInput? remoteId,
    Input$StringFilterInput? remoteUrl,
    Input$DoubleFilterInput? score,
    Input$LongFilterInput? startDate,
    Input$IntFilterInput? status,
    Input$StringFilterInput? title,
    Input$IntFilterInput? totalChapters,
    Input$IntFilterInput? trackerId,
  });
  TRes and(
      Iterable<Input$TrackRecordFilterInput>? Function(
              Iterable<
                  CopyWith$Input$TrackRecordFilterInput<
                      Input$TrackRecordFilterInput>>?)
          _fn);
  CopyWith$Input$LongFilterInput<TRes> get finishDate;
  CopyWith$Input$IntFilterInput<TRes> get id;
  CopyWith$Input$DoubleFilterInput<TRes> get lastChapterRead;
  CopyWith$Input$LongFilterInput<TRes> get libraryId;
  CopyWith$Input$IntFilterInput<TRes> get mangaId;
  CopyWith$Input$TrackRecordFilterInput<TRes> get not;
  TRes or(
      Iterable<Input$TrackRecordFilterInput>? Function(
              Iterable<
                  CopyWith$Input$TrackRecordFilterInput<
                      Input$TrackRecordFilterInput>>?)
          _fn);
  CopyWith$Input$LongFilterInput<TRes> get remoteId;
  CopyWith$Input$StringFilterInput<TRes> get remoteUrl;
  CopyWith$Input$DoubleFilterInput<TRes> get score;
  CopyWith$Input$LongFilterInput<TRes> get startDate;
  CopyWith$Input$IntFilterInput<TRes> get status;
  CopyWith$Input$StringFilterInput<TRes> get title;
  CopyWith$Input$IntFilterInput<TRes> get totalChapters;
  CopyWith$Input$IntFilterInput<TRes> get trackerId;
}

class _CopyWithImpl$Input$TrackRecordFilterInput<TRes>
    implements CopyWith$Input$TrackRecordFilterInput<TRes> {
  _CopyWithImpl$Input$TrackRecordFilterInput(
    this._instance,
    this._then,
  );

  final Input$TrackRecordFilterInput _instance;

  final TRes Function(Input$TrackRecordFilterInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? and = _undefined,
    Object? finishDate = _undefined,
    Object? id = _undefined,
    Object? lastChapterRead = _undefined,
    Object? libraryId = _undefined,
    Object? mangaId = _undefined,
    Object? not = _undefined,
    Object? or = _undefined,
    Object? remoteId = _undefined,
    Object? remoteUrl = _undefined,
    Object? score = _undefined,
    Object? startDate = _undefined,
    Object? status = _undefined,
    Object? title = _undefined,
    Object? totalChapters = _undefined,
    Object? trackerId = _undefined,
  }) =>
      _then(Input$TrackRecordFilterInput._({
        ..._instance._$data,
        if (and != _undefined)
          'and': (and as List<Input$TrackRecordFilterInput>?),
        if (finishDate != _undefined)
          'finishDate': (finishDate as Input$LongFilterInput?),
        if (id != _undefined) 'id': (id as Input$IntFilterInput?),
        if (lastChapterRead != _undefined)
          'lastChapterRead': (lastChapterRead as Input$DoubleFilterInput?),
        if (libraryId != _undefined)
          'libraryId': (libraryId as Input$LongFilterInput?),
        if (mangaId != _undefined)
          'mangaId': (mangaId as Input$IntFilterInput?),
        if (not != _undefined) 'not': (not as Input$TrackRecordFilterInput?),
        if (or != _undefined) 'or': (or as List<Input$TrackRecordFilterInput>?),
        if (remoteId != _undefined)
          'remoteId': (remoteId as Input$LongFilterInput?),
        if (remoteUrl != _undefined)
          'remoteUrl': (remoteUrl as Input$StringFilterInput?),
        if (score != _undefined) 'score': (score as Input$DoubleFilterInput?),
        if (startDate != _undefined)
          'startDate': (startDate as Input$LongFilterInput?),
        if (status != _undefined) 'status': (status as Input$IntFilterInput?),
        if (title != _undefined) 'title': (title as Input$StringFilterInput?),
        if (totalChapters != _undefined)
          'totalChapters': (totalChapters as Input$IntFilterInput?),
        if (trackerId != _undefined)
          'trackerId': (trackerId as Input$IntFilterInput?),
      }));

  TRes and(
          Iterable<Input$TrackRecordFilterInput>? Function(
                  Iterable<
                      CopyWith$Input$TrackRecordFilterInput<
                          Input$TrackRecordFilterInput>>?)
              _fn) =>
      call(
          and: _fn(
              _instance.and?.map((e) => CopyWith$Input$TrackRecordFilterInput(
                    e,
                    (i) => i,
                  )))?.toList());

  CopyWith$Input$LongFilterInput<TRes> get finishDate {
    final local$finishDate = _instance.finishDate;
    return local$finishDate == null
        ? CopyWith$Input$LongFilterInput.stub(_then(_instance))
        : CopyWith$Input$LongFilterInput(
            local$finishDate, (e) => call(finishDate: e));
  }

  CopyWith$Input$IntFilterInput<TRes> get id {
    final local$id = _instance.id;
    return local$id == null
        ? CopyWith$Input$IntFilterInput.stub(_then(_instance))
        : CopyWith$Input$IntFilterInput(local$id, (e) => call(id: e));
  }

  CopyWith$Input$DoubleFilterInput<TRes> get lastChapterRead {
    final local$lastChapterRead = _instance.lastChapterRead;
    return local$lastChapterRead == null
        ? CopyWith$Input$DoubleFilterInput.stub(_then(_instance))
        : CopyWith$Input$DoubleFilterInput(
            local$lastChapterRead, (e) => call(lastChapterRead: e));
  }

  CopyWith$Input$LongFilterInput<TRes> get libraryId {
    final local$libraryId = _instance.libraryId;
    return local$libraryId == null
        ? CopyWith$Input$LongFilterInput.stub(_then(_instance))
        : CopyWith$Input$LongFilterInput(
            local$libraryId, (e) => call(libraryId: e));
  }

  CopyWith$Input$IntFilterInput<TRes> get mangaId {
    final local$mangaId = _instance.mangaId;
    return local$mangaId == null
        ? CopyWith$Input$IntFilterInput.stub(_then(_instance))
        : CopyWith$Input$IntFilterInput(local$mangaId, (e) => call(mangaId: e));
  }

  CopyWith$Input$TrackRecordFilterInput<TRes> get not {
    final local$not = _instance.not;
    return local$not == null
        ? CopyWith$Input$TrackRecordFilterInput.stub(_then(_instance))
        : CopyWith$Input$TrackRecordFilterInput(local$not, (e) => call(not: e));
  }

  TRes or(
          Iterable<Input$TrackRecordFilterInput>? Function(
                  Iterable<
                      CopyWith$Input$TrackRecordFilterInput<
                          Input$TrackRecordFilterInput>>?)
              _fn) =>
      call(
          or: _fn(
              _instance.or?.map((e) => CopyWith$Input$TrackRecordFilterInput(
                    e,
                    (i) => i,
                  )))?.toList());

  CopyWith$Input$LongFilterInput<TRes> get remoteId {
    final local$remoteId = _instance.remoteId;
    return local$remoteId == null
        ? CopyWith$Input$LongFilterInput.stub(_then(_instance))
        : CopyWith$Input$LongFilterInput(
            local$remoteId, (e) => call(remoteId: e));
  }

  CopyWith$Input$StringFilterInput<TRes> get remoteUrl {
    final local$remoteUrl = _instance.remoteUrl;
    return local$remoteUrl == null
        ? CopyWith$Input$StringFilterInput.stub(_then(_instance))
        : CopyWith$Input$StringFilterInput(
            local$remoteUrl, (e) => call(remoteUrl: e));
  }

  CopyWith$Input$DoubleFilterInput<TRes> get score {
    final local$score = _instance.score;
    return local$score == null
        ? CopyWith$Input$DoubleFilterInput.stub(_then(_instance))
        : CopyWith$Input$DoubleFilterInput(local$score, (e) => call(score: e));
  }

  CopyWith$Input$LongFilterInput<TRes> get startDate {
    final local$startDate = _instance.startDate;
    return local$startDate == null
        ? CopyWith$Input$LongFilterInput.stub(_then(_instance))
        : CopyWith$Input$LongFilterInput(
            local$startDate, (e) => call(startDate: e));
  }

  CopyWith$Input$IntFilterInput<TRes> get status {
    final local$status = _instance.status;
    return local$status == null
        ? CopyWith$Input$IntFilterInput.stub(_then(_instance))
        : CopyWith$Input$IntFilterInput(local$status, (e) => call(status: e));
  }

  CopyWith$Input$StringFilterInput<TRes> get title {
    final local$title = _instance.title;
    return local$title == null
        ? CopyWith$Input$StringFilterInput.stub(_then(_instance))
        : CopyWith$Input$StringFilterInput(local$title, (e) => call(title: e));
  }

  CopyWith$Input$IntFilterInput<TRes> get totalChapters {
    final local$totalChapters = _instance.totalChapters;
    return local$totalChapters == null
        ? CopyWith$Input$IntFilterInput.stub(_then(_instance))
        : CopyWith$Input$IntFilterInput(
            local$totalChapters, (e) => call(totalChapters: e));
  }

  CopyWith$Input$IntFilterInput<TRes> get trackerId {
    final local$trackerId = _instance.trackerId;
    return local$trackerId == null
        ? CopyWith$Input$IntFilterInput.stub(_then(_instance))
        : CopyWith$Input$IntFilterInput(
            local$trackerId, (e) => call(trackerId: e));
  }
}

class _CopyWithStubImpl$Input$TrackRecordFilterInput<TRes>
    implements CopyWith$Input$TrackRecordFilterInput<TRes> {
  _CopyWithStubImpl$Input$TrackRecordFilterInput(this._res);

  TRes _res;

  call({
    List<Input$TrackRecordFilterInput>? and,
    Input$LongFilterInput? finishDate,
    Input$IntFilterInput? id,
    Input$DoubleFilterInput? lastChapterRead,
    Input$LongFilterInput? libraryId,
    Input$IntFilterInput? mangaId,
    Input$TrackRecordFilterInput? not,
    List<Input$TrackRecordFilterInput>? or,
    Input$LongFilterInput? remoteId,
    Input$StringFilterInput? remoteUrl,
    Input$DoubleFilterInput? score,
    Input$LongFilterInput? startDate,
    Input$IntFilterInput? status,
    Input$StringFilterInput? title,
    Input$IntFilterInput? totalChapters,
    Input$IntFilterInput? trackerId,
  }) =>
      _res;

  and(_fn) => _res;

  CopyWith$Input$LongFilterInput<TRes> get finishDate =>
      CopyWith$Input$LongFilterInput.stub(_res);

  CopyWith$Input$IntFilterInput<TRes> get id =>
      CopyWith$Input$IntFilterInput.stub(_res);

  CopyWith$Input$DoubleFilterInput<TRes> get lastChapterRead =>
      CopyWith$Input$DoubleFilterInput.stub(_res);

  CopyWith$Input$LongFilterInput<TRes> get libraryId =>
      CopyWith$Input$LongFilterInput.stub(_res);

  CopyWith$Input$IntFilterInput<TRes> get mangaId =>
      CopyWith$Input$IntFilterInput.stub(_res);

  CopyWith$Input$TrackRecordFilterInput<TRes> get not =>
      CopyWith$Input$TrackRecordFilterInput.stub(_res);

  or(_fn) => _res;

  CopyWith$Input$LongFilterInput<TRes> get remoteId =>
      CopyWith$Input$LongFilterInput.stub(_res);

  CopyWith$Input$StringFilterInput<TRes> get remoteUrl =>
      CopyWith$Input$StringFilterInput.stub(_res);

  CopyWith$Input$DoubleFilterInput<TRes> get score =>
      CopyWith$Input$DoubleFilterInput.stub(_res);

  CopyWith$Input$LongFilterInput<TRes> get startDate =>
      CopyWith$Input$LongFilterInput.stub(_res);

  CopyWith$Input$IntFilterInput<TRes> get status =>
      CopyWith$Input$IntFilterInput.stub(_res);

  CopyWith$Input$StringFilterInput<TRes> get title =>
      CopyWith$Input$StringFilterInput.stub(_res);

  CopyWith$Input$IntFilterInput<TRes> get totalChapters =>
      CopyWith$Input$IntFilterInput.stub(_res);

  CopyWith$Input$IntFilterInput<TRes> get trackerId =>
      CopyWith$Input$IntFilterInput.stub(_res);
}

class Input$TrackRecordOrderInput {
  factory Input$TrackRecordOrderInput({
    required Enum$TrackRecordOrderBy by,
    Enum$SortOrder? byType,
  }) =>
      Input$TrackRecordOrderInput._({
        r'by': by,
        if (byType != null) r'byType': byType,
      });

  Input$TrackRecordOrderInput._(this._$data);

  factory Input$TrackRecordOrderInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$by = data['by'];
    result$data['by'] = fromJson$Enum$TrackRecordOrderBy((l$by as String));
    if (data.containsKey('byType')) {
      final l$byType = data['byType'];
      result$data['byType'] = l$byType == null
          ? null
          : fromJson$Enum$SortOrder((l$byType as String));
    }
    return Input$TrackRecordOrderInput._(result$data);
  }

  Map<String, dynamic> _$data;

  Enum$TrackRecordOrderBy get by => (_$data['by'] as Enum$TrackRecordOrderBy);

  Enum$SortOrder? get byType => (_$data['byType'] as Enum$SortOrder?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$by = by;
    result$data['by'] = toJson$Enum$TrackRecordOrderBy(l$by);
    if (_$data.containsKey('byType')) {
      final l$byType = byType;
      result$data['byType'] =
          l$byType == null ? null : toJson$Enum$SortOrder(l$byType);
    }
    return result$data;
  }

  CopyWith$Input$TrackRecordOrderInput<Input$TrackRecordOrderInput>
      get copyWith => CopyWith$Input$TrackRecordOrderInput(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$TrackRecordOrderInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$by = by;
    final lOther$by = other.by;
    if (l$by != lOther$by) {
      return false;
    }
    final l$byType = byType;
    final lOther$byType = other.byType;
    if (_$data.containsKey('byType') != other._$data.containsKey('byType')) {
      return false;
    }
    if (l$byType != lOther$byType) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$by = by;
    final l$byType = byType;
    return Object.hashAll([
      l$by,
      _$data.containsKey('byType') ? l$byType : const {},
    ]);
  }
}

abstract class CopyWith$Input$TrackRecordOrderInput<TRes> {
  factory CopyWith$Input$TrackRecordOrderInput(
    Input$TrackRecordOrderInput instance,
    TRes Function(Input$TrackRecordOrderInput) then,
  ) = _CopyWithImpl$Input$TrackRecordOrderInput;

  factory CopyWith$Input$TrackRecordOrderInput.stub(TRes res) =
      _CopyWithStubImpl$Input$TrackRecordOrderInput;

  TRes call({
    Enum$TrackRecordOrderBy? by,
    Enum$SortOrder? byType,
  });
}

class _CopyWithImpl$Input$TrackRecordOrderInput<TRes>
    implements CopyWith$Input$TrackRecordOrderInput<TRes> {
  _CopyWithImpl$Input$TrackRecordOrderInput(
    this._instance,
    this._then,
  );

  final Input$TrackRecordOrderInput _instance;

  final TRes Function(Input$TrackRecordOrderInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? by = _undefined,
    Object? byType = _undefined,
  }) =>
      _then(Input$TrackRecordOrderInput._({
        ..._instance._$data,
        if (by != _undefined && by != null)
          'by': (by as Enum$TrackRecordOrderBy),
        if (byType != _undefined) 'byType': (byType as Enum$SortOrder?),
      }));
}

class _CopyWithStubImpl$Input$TrackRecordOrderInput<TRes>
    implements CopyWith$Input$TrackRecordOrderInput<TRes> {
  _CopyWithStubImpl$Input$TrackRecordOrderInput(this._res);

  TRes _res;

  call({
    Enum$TrackRecordOrderBy? by,
    Enum$SortOrder? byType,
  }) =>
      _res;
}

class Input$UnbindTrackInput {
  factory Input$UnbindTrackInput({
    String? clientMutationId,
    bool? deleteRemoteTrack,
    required int recordId,
  }) =>
      Input$UnbindTrackInput._({
        if (clientMutationId != null) r'clientMutationId': clientMutationId,
        if (deleteRemoteTrack != null) r'deleteRemoteTrack': deleteRemoteTrack,
        r'recordId': recordId,
      });

  Input$UnbindTrackInput._(this._$data);

  factory Input$UnbindTrackInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('clientMutationId')) {
      final l$clientMutationId = data['clientMutationId'];
      result$data['clientMutationId'] = (l$clientMutationId as String?);
    }
    if (data.containsKey('deleteRemoteTrack')) {
      final l$deleteRemoteTrack = data['deleteRemoteTrack'];
      result$data['deleteRemoteTrack'] = (l$deleteRemoteTrack as bool?);
    }
    final l$recordId = data['recordId'];
    result$data['recordId'] = (l$recordId as int);
    return Input$UnbindTrackInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get clientMutationId => (_$data['clientMutationId'] as String?);

  bool? get deleteRemoteTrack => (_$data['deleteRemoteTrack'] as bool?);

  int get recordId => (_$data['recordId'] as int);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('clientMutationId')) {
      final l$clientMutationId = clientMutationId;
      result$data['clientMutationId'] = l$clientMutationId;
    }
    if (_$data.containsKey('deleteRemoteTrack')) {
      final l$deleteRemoteTrack = deleteRemoteTrack;
      result$data['deleteRemoteTrack'] = l$deleteRemoteTrack;
    }
    final l$recordId = recordId;
    result$data['recordId'] = l$recordId;
    return result$data;
  }

  CopyWith$Input$UnbindTrackInput<Input$UnbindTrackInput> get copyWith =>
      CopyWith$Input$UnbindTrackInput(
        this,
        (i) => i,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$UnbindTrackInput || runtimeType != other.runtimeType) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (_$data.containsKey('clientMutationId') !=
        other._$data.containsKey('clientMutationId')) {
      return false;
    }
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    final l$deleteRemoteTrack = deleteRemoteTrack;
    final lOther$deleteRemoteTrack = other.deleteRemoteTrack;
    if (_$data.containsKey('deleteRemoteTrack') !=
        other._$data.containsKey('deleteRemoteTrack')) {
      return false;
    }
    if (l$deleteRemoteTrack != lOther$deleteRemoteTrack) {
      return false;
    }
    final l$recordId = recordId;
    final lOther$recordId = other.recordId;
    if (l$recordId != lOther$recordId) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$clientMutationId = clientMutationId;
    final l$deleteRemoteTrack = deleteRemoteTrack;
    final l$recordId = recordId;
    return Object.hashAll([
      _$data.containsKey('clientMutationId') ? l$clientMutationId : const {},
      _$data.containsKey('deleteRemoteTrack') ? l$deleteRemoteTrack : const {},
      l$recordId,
    ]);
  }
}

abstract class CopyWith$Input$UnbindTrackInput<TRes> {
  factory CopyWith$Input$UnbindTrackInput(
    Input$UnbindTrackInput instance,
    TRes Function(Input$UnbindTrackInput) then,
  ) = _CopyWithImpl$Input$UnbindTrackInput;

  factory CopyWith$Input$UnbindTrackInput.stub(TRes res) =
      _CopyWithStubImpl$Input$UnbindTrackInput;

  TRes call({
    String? clientMutationId,
    bool? deleteRemoteTrack,
    int? recordId,
  });
}

class _CopyWithImpl$Input$UnbindTrackInput<TRes>
    implements CopyWith$Input$UnbindTrackInput<TRes> {
  _CopyWithImpl$Input$UnbindTrackInput(
    this._instance,
    this._then,
  );

  final Input$UnbindTrackInput _instance;

  final TRes Function(Input$UnbindTrackInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? clientMutationId = _undefined,
    Object? deleteRemoteTrack = _undefined,
    Object? recordId = _undefined,
  }) =>
      _then(Input$UnbindTrackInput._({
        ..._instance._$data,
        if (clientMutationId != _undefined)
          'clientMutationId': (clientMutationId as String?),
        if (deleteRemoteTrack != _undefined)
          'deleteRemoteTrack': (deleteRemoteTrack as bool?),
        if (recordId != _undefined && recordId != null)
          'recordId': (recordId as int),
      }));
}

class _CopyWithStubImpl$Input$UnbindTrackInput<TRes>
    implements CopyWith$Input$UnbindTrackInput<TRes> {
  _CopyWithStubImpl$Input$UnbindTrackInput(this._res);

  TRes _res;

  call({
    String? clientMutationId,
    bool? deleteRemoteTrack,
    int? recordId,
  }) =>
      _res;
}

class Input$UpdateCategoriesInput {
  factory Input$UpdateCategoriesInput({
    String? clientMutationId,
    required List<int> ids,
    required Input$UpdateCategoryPatchInput patch,
  }) =>
      Input$UpdateCategoriesInput._({
        if (clientMutationId != null) r'clientMutationId': clientMutationId,
        r'ids': ids,
        r'patch': patch,
      });

  Input$UpdateCategoriesInput._(this._$data);

  factory Input$UpdateCategoriesInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('clientMutationId')) {
      final l$clientMutationId = data['clientMutationId'];
      result$data['clientMutationId'] = (l$clientMutationId as String?);
    }
    final l$ids = data['ids'];
    result$data['ids'] =
        (l$ids as List<dynamic>).map((e) => (e as int)).toList();
    final l$patch = data['patch'];
    result$data['patch'] = Input$UpdateCategoryPatchInput.fromJson(
        (l$patch as Map<String, dynamic>));
    return Input$UpdateCategoriesInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get clientMutationId => (_$data['clientMutationId'] as String?);

  List<int> get ids => (_$data['ids'] as List<int>);

  Input$UpdateCategoryPatchInput get patch =>
      (_$data['patch'] as Input$UpdateCategoryPatchInput);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('clientMutationId')) {
      final l$clientMutationId = clientMutationId;
      result$data['clientMutationId'] = l$clientMutationId;
    }
    final l$ids = ids;
    result$data['ids'] = l$ids.map((e) => e).toList();
    final l$patch = patch;
    result$data['patch'] = l$patch.toJson();
    return result$data;
  }

  CopyWith$Input$UpdateCategoriesInput<Input$UpdateCategoriesInput>
      get copyWith => CopyWith$Input$UpdateCategoriesInput(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$UpdateCategoriesInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (_$data.containsKey('clientMutationId') !=
        other._$data.containsKey('clientMutationId')) {
      return false;
    }
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    final l$ids = ids;
    final lOther$ids = other.ids;
    if (l$ids.length != lOther$ids.length) {
      return false;
    }
    for (int i = 0; i < l$ids.length; i++) {
      final l$ids$entry = l$ids[i];
      final lOther$ids$entry = lOther$ids[i];
      if (l$ids$entry != lOther$ids$entry) {
        return false;
      }
    }
    final l$patch = patch;
    final lOther$patch = other.patch;
    if (l$patch != lOther$patch) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$clientMutationId = clientMutationId;
    final l$ids = ids;
    final l$patch = patch;
    return Object.hashAll([
      _$data.containsKey('clientMutationId') ? l$clientMutationId : const {},
      Object.hashAll(l$ids.map((v) => v)),
      l$patch,
    ]);
  }
}

abstract class CopyWith$Input$UpdateCategoriesInput<TRes> {
  factory CopyWith$Input$UpdateCategoriesInput(
    Input$UpdateCategoriesInput instance,
    TRes Function(Input$UpdateCategoriesInput) then,
  ) = _CopyWithImpl$Input$UpdateCategoriesInput;

  factory CopyWith$Input$UpdateCategoriesInput.stub(TRes res) =
      _CopyWithStubImpl$Input$UpdateCategoriesInput;

  TRes call({
    String? clientMutationId,
    List<int>? ids,
    Input$UpdateCategoryPatchInput? patch,
  });
  CopyWith$Input$UpdateCategoryPatchInput<TRes> get patch;
}

class _CopyWithImpl$Input$UpdateCategoriesInput<TRes>
    implements CopyWith$Input$UpdateCategoriesInput<TRes> {
  _CopyWithImpl$Input$UpdateCategoriesInput(
    this._instance,
    this._then,
  );

  final Input$UpdateCategoriesInput _instance;

  final TRes Function(Input$UpdateCategoriesInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? clientMutationId = _undefined,
    Object? ids = _undefined,
    Object? patch = _undefined,
  }) =>
      _then(Input$UpdateCategoriesInput._({
        ..._instance._$data,
        if (clientMutationId != _undefined)
          'clientMutationId': (clientMutationId as String?),
        if (ids != _undefined && ids != null) 'ids': (ids as List<int>),
        if (patch != _undefined && patch != null)
          'patch': (patch as Input$UpdateCategoryPatchInput),
      }));

  CopyWith$Input$UpdateCategoryPatchInput<TRes> get patch {
    final local$patch = _instance.patch;
    return CopyWith$Input$UpdateCategoryPatchInput(
        local$patch, (e) => call(patch: e));
  }
}

class _CopyWithStubImpl$Input$UpdateCategoriesInput<TRes>
    implements CopyWith$Input$UpdateCategoriesInput<TRes> {
  _CopyWithStubImpl$Input$UpdateCategoriesInput(this._res);

  TRes _res;

  call({
    String? clientMutationId,
    List<int>? ids,
    Input$UpdateCategoryPatchInput? patch,
  }) =>
      _res;

  CopyWith$Input$UpdateCategoryPatchInput<TRes> get patch =>
      CopyWith$Input$UpdateCategoryPatchInput.stub(_res);
}

class Input$UpdateCategoryInput {
  factory Input$UpdateCategoryInput({
    String? clientMutationId,
    required int id,
    required Input$UpdateCategoryPatchInput patch,
  }) =>
      Input$UpdateCategoryInput._({
        if (clientMutationId != null) r'clientMutationId': clientMutationId,
        r'id': id,
        r'patch': patch,
      });

  Input$UpdateCategoryInput._(this._$data);

  factory Input$UpdateCategoryInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('clientMutationId')) {
      final l$clientMutationId = data['clientMutationId'];
      result$data['clientMutationId'] = (l$clientMutationId as String?);
    }
    final l$id = data['id'];
    result$data['id'] = (l$id as int);
    final l$patch = data['patch'];
    result$data['patch'] = Input$UpdateCategoryPatchInput.fromJson(
        (l$patch as Map<String, dynamic>));
    return Input$UpdateCategoryInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get clientMutationId => (_$data['clientMutationId'] as String?);

  int get id => (_$data['id'] as int);

  Input$UpdateCategoryPatchInput get patch =>
      (_$data['patch'] as Input$UpdateCategoryPatchInput);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('clientMutationId')) {
      final l$clientMutationId = clientMutationId;
      result$data['clientMutationId'] = l$clientMutationId;
    }
    final l$id = id;
    result$data['id'] = l$id;
    final l$patch = patch;
    result$data['patch'] = l$patch.toJson();
    return result$data;
  }

  CopyWith$Input$UpdateCategoryInput<Input$UpdateCategoryInput> get copyWith =>
      CopyWith$Input$UpdateCategoryInput(
        this,
        (i) => i,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$UpdateCategoryInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (_$data.containsKey('clientMutationId') !=
        other._$data.containsKey('clientMutationId')) {
      return false;
    }
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$patch = patch;
    final lOther$patch = other.patch;
    if (l$patch != lOther$patch) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$clientMutationId = clientMutationId;
    final l$id = id;
    final l$patch = patch;
    return Object.hashAll([
      _$data.containsKey('clientMutationId') ? l$clientMutationId : const {},
      l$id,
      l$patch,
    ]);
  }
}

abstract class CopyWith$Input$UpdateCategoryInput<TRes> {
  factory CopyWith$Input$UpdateCategoryInput(
    Input$UpdateCategoryInput instance,
    TRes Function(Input$UpdateCategoryInput) then,
  ) = _CopyWithImpl$Input$UpdateCategoryInput;

  factory CopyWith$Input$UpdateCategoryInput.stub(TRes res) =
      _CopyWithStubImpl$Input$UpdateCategoryInput;

  TRes call({
    String? clientMutationId,
    int? id,
    Input$UpdateCategoryPatchInput? patch,
  });
  CopyWith$Input$UpdateCategoryPatchInput<TRes> get patch;
}

class _CopyWithImpl$Input$UpdateCategoryInput<TRes>
    implements CopyWith$Input$UpdateCategoryInput<TRes> {
  _CopyWithImpl$Input$UpdateCategoryInput(
    this._instance,
    this._then,
  );

  final Input$UpdateCategoryInput _instance;

  final TRes Function(Input$UpdateCategoryInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? clientMutationId = _undefined,
    Object? id = _undefined,
    Object? patch = _undefined,
  }) =>
      _then(Input$UpdateCategoryInput._({
        ..._instance._$data,
        if (clientMutationId != _undefined)
          'clientMutationId': (clientMutationId as String?),
        if (id != _undefined && id != null) 'id': (id as int),
        if (patch != _undefined && patch != null)
          'patch': (patch as Input$UpdateCategoryPatchInput),
      }));

  CopyWith$Input$UpdateCategoryPatchInput<TRes> get patch {
    final local$patch = _instance.patch;
    return CopyWith$Input$UpdateCategoryPatchInput(
        local$patch, (e) => call(patch: e));
  }
}

class _CopyWithStubImpl$Input$UpdateCategoryInput<TRes>
    implements CopyWith$Input$UpdateCategoryInput<TRes> {
  _CopyWithStubImpl$Input$UpdateCategoryInput(this._res);

  TRes _res;

  call({
    String? clientMutationId,
    int? id,
    Input$UpdateCategoryPatchInput? patch,
  }) =>
      _res;

  CopyWith$Input$UpdateCategoryPatchInput<TRes> get patch =>
      CopyWith$Input$UpdateCategoryPatchInput.stub(_res);
}

class Input$UpdateCategoryMangaInput {
  factory Input$UpdateCategoryMangaInput({
    required List<int> categories,
    String? clientMutationId,
  }) =>
      Input$UpdateCategoryMangaInput._({
        r'categories': categories,
        if (clientMutationId != null) r'clientMutationId': clientMutationId,
      });

  Input$UpdateCategoryMangaInput._(this._$data);

  factory Input$UpdateCategoryMangaInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$categories = data['categories'];
    result$data['categories'] =
        (l$categories as List<dynamic>).map((e) => (e as int)).toList();
    if (data.containsKey('clientMutationId')) {
      final l$clientMutationId = data['clientMutationId'];
      result$data['clientMutationId'] = (l$clientMutationId as String?);
    }
    return Input$UpdateCategoryMangaInput._(result$data);
  }

  Map<String, dynamic> _$data;

  List<int> get categories => (_$data['categories'] as List<int>);

  String? get clientMutationId => (_$data['clientMutationId'] as String?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$categories = categories;
    result$data['categories'] = l$categories.map((e) => e).toList();
    if (_$data.containsKey('clientMutationId')) {
      final l$clientMutationId = clientMutationId;
      result$data['clientMutationId'] = l$clientMutationId;
    }
    return result$data;
  }

  CopyWith$Input$UpdateCategoryMangaInput<Input$UpdateCategoryMangaInput>
      get copyWith => CopyWith$Input$UpdateCategoryMangaInput(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$UpdateCategoryMangaInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$categories = categories;
    final lOther$categories = other.categories;
    if (l$categories.length != lOther$categories.length) {
      return false;
    }
    for (int i = 0; i < l$categories.length; i++) {
      final l$categories$entry = l$categories[i];
      final lOther$categories$entry = lOther$categories[i];
      if (l$categories$entry != lOther$categories$entry) {
        return false;
      }
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (_$data.containsKey('clientMutationId') !=
        other._$data.containsKey('clientMutationId')) {
      return false;
    }
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$categories = categories;
    final l$clientMutationId = clientMutationId;
    return Object.hashAll([
      Object.hashAll(l$categories.map((v) => v)),
      _$data.containsKey('clientMutationId') ? l$clientMutationId : const {},
    ]);
  }
}

abstract class CopyWith$Input$UpdateCategoryMangaInput<TRes> {
  factory CopyWith$Input$UpdateCategoryMangaInput(
    Input$UpdateCategoryMangaInput instance,
    TRes Function(Input$UpdateCategoryMangaInput) then,
  ) = _CopyWithImpl$Input$UpdateCategoryMangaInput;

  factory CopyWith$Input$UpdateCategoryMangaInput.stub(TRes res) =
      _CopyWithStubImpl$Input$UpdateCategoryMangaInput;

  TRes call({
    List<int>? categories,
    String? clientMutationId,
  });
}

class _CopyWithImpl$Input$UpdateCategoryMangaInput<TRes>
    implements CopyWith$Input$UpdateCategoryMangaInput<TRes> {
  _CopyWithImpl$Input$UpdateCategoryMangaInput(
    this._instance,
    this._then,
  );

  final Input$UpdateCategoryMangaInput _instance;

  final TRes Function(Input$UpdateCategoryMangaInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? categories = _undefined,
    Object? clientMutationId = _undefined,
  }) =>
      _then(Input$UpdateCategoryMangaInput._({
        ..._instance._$data,
        if (categories != _undefined && categories != null)
          'categories': (categories as List<int>),
        if (clientMutationId != _undefined)
          'clientMutationId': (clientMutationId as String?),
      }));
}

class _CopyWithStubImpl$Input$UpdateCategoryMangaInput<TRes>
    implements CopyWith$Input$UpdateCategoryMangaInput<TRes> {
  _CopyWithStubImpl$Input$UpdateCategoryMangaInput(this._res);

  TRes _res;

  call({
    List<int>? categories,
    String? clientMutationId,
  }) =>
      _res;
}

class Input$UpdateCategoryOrderInput {
  factory Input$UpdateCategoryOrderInput({
    String? clientMutationId,
    required int id,
    required int position,
  }) =>
      Input$UpdateCategoryOrderInput._({
        if (clientMutationId != null) r'clientMutationId': clientMutationId,
        r'id': id,
        r'position': position,
      });

  Input$UpdateCategoryOrderInput._(this._$data);

  factory Input$UpdateCategoryOrderInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('clientMutationId')) {
      final l$clientMutationId = data['clientMutationId'];
      result$data['clientMutationId'] = (l$clientMutationId as String?);
    }
    final l$id = data['id'];
    result$data['id'] = (l$id as int);
    final l$position = data['position'];
    result$data['position'] = (l$position as int);
    return Input$UpdateCategoryOrderInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get clientMutationId => (_$data['clientMutationId'] as String?);

  int get id => (_$data['id'] as int);

  int get position => (_$data['position'] as int);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('clientMutationId')) {
      final l$clientMutationId = clientMutationId;
      result$data['clientMutationId'] = l$clientMutationId;
    }
    final l$id = id;
    result$data['id'] = l$id;
    final l$position = position;
    result$data['position'] = l$position;
    return result$data;
  }

  CopyWith$Input$UpdateCategoryOrderInput<Input$UpdateCategoryOrderInput>
      get copyWith => CopyWith$Input$UpdateCategoryOrderInput(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$UpdateCategoryOrderInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (_$data.containsKey('clientMutationId') !=
        other._$data.containsKey('clientMutationId')) {
      return false;
    }
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$position = position;
    final lOther$position = other.position;
    if (l$position != lOther$position) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$clientMutationId = clientMutationId;
    final l$id = id;
    final l$position = position;
    return Object.hashAll([
      _$data.containsKey('clientMutationId') ? l$clientMutationId : const {},
      l$id,
      l$position,
    ]);
  }
}

abstract class CopyWith$Input$UpdateCategoryOrderInput<TRes> {
  factory CopyWith$Input$UpdateCategoryOrderInput(
    Input$UpdateCategoryOrderInput instance,
    TRes Function(Input$UpdateCategoryOrderInput) then,
  ) = _CopyWithImpl$Input$UpdateCategoryOrderInput;

  factory CopyWith$Input$UpdateCategoryOrderInput.stub(TRes res) =
      _CopyWithStubImpl$Input$UpdateCategoryOrderInput;

  TRes call({
    String? clientMutationId,
    int? id,
    int? position,
  });
}

class _CopyWithImpl$Input$UpdateCategoryOrderInput<TRes>
    implements CopyWith$Input$UpdateCategoryOrderInput<TRes> {
  _CopyWithImpl$Input$UpdateCategoryOrderInput(
    this._instance,
    this._then,
  );

  final Input$UpdateCategoryOrderInput _instance;

  final TRes Function(Input$UpdateCategoryOrderInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? clientMutationId = _undefined,
    Object? id = _undefined,
    Object? position = _undefined,
  }) =>
      _then(Input$UpdateCategoryOrderInput._({
        ..._instance._$data,
        if (clientMutationId != _undefined)
          'clientMutationId': (clientMutationId as String?),
        if (id != _undefined && id != null) 'id': (id as int),
        if (position != _undefined && position != null)
          'position': (position as int),
      }));
}

class _CopyWithStubImpl$Input$UpdateCategoryOrderInput<TRes>
    implements CopyWith$Input$UpdateCategoryOrderInput<TRes> {
  _CopyWithStubImpl$Input$UpdateCategoryOrderInput(this._res);

  TRes _res;

  call({
    String? clientMutationId,
    int? id,
    int? position,
  }) =>
      _res;
}

class Input$UpdateCategoryPatchInput {
  factory Input$UpdateCategoryPatchInput({
    bool? $default,
    Enum$IncludeOrExclude? includeInDownload,
    Enum$IncludeOrExclude? includeInUpdate,
    String? name,
  }) =>
      Input$UpdateCategoryPatchInput._({
        if ($default != null) r'default': $default,
        if (includeInDownload != null) r'includeInDownload': includeInDownload,
        if (includeInUpdate != null) r'includeInUpdate': includeInUpdate,
        if (name != null) r'name': name,
      });

  Input$UpdateCategoryPatchInput._(this._$data);

  factory Input$UpdateCategoryPatchInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('default')) {
      final l$$default = data['default'];
      result$data['default'] = (l$$default as bool?);
    }
    if (data.containsKey('includeInDownload')) {
      final l$includeInDownload = data['includeInDownload'];
      result$data['includeInDownload'] = l$includeInDownload == null
          ? null
          : fromJson$Enum$IncludeOrExclude((l$includeInDownload as String));
    }
    if (data.containsKey('includeInUpdate')) {
      final l$includeInUpdate = data['includeInUpdate'];
      result$data['includeInUpdate'] = l$includeInUpdate == null
          ? null
          : fromJson$Enum$IncludeOrExclude((l$includeInUpdate as String));
    }
    if (data.containsKey('name')) {
      final l$name = data['name'];
      result$data['name'] = (l$name as String?);
    }
    return Input$UpdateCategoryPatchInput._(result$data);
  }

  Map<String, dynamic> _$data;

  bool? get $default => (_$data['default'] as bool?);

  Enum$IncludeOrExclude? get includeInDownload =>
      (_$data['includeInDownload'] as Enum$IncludeOrExclude?);

  Enum$IncludeOrExclude? get includeInUpdate =>
      (_$data['includeInUpdate'] as Enum$IncludeOrExclude?);

  String? get name => (_$data['name'] as String?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('default')) {
      final l$$default = $default;
      result$data['default'] = l$$default;
    }
    if (_$data.containsKey('includeInDownload')) {
      final l$includeInDownload = includeInDownload;
      result$data['includeInDownload'] = l$includeInDownload == null
          ? null
          : toJson$Enum$IncludeOrExclude(l$includeInDownload);
    }
    if (_$data.containsKey('includeInUpdate')) {
      final l$includeInUpdate = includeInUpdate;
      result$data['includeInUpdate'] = l$includeInUpdate == null
          ? null
          : toJson$Enum$IncludeOrExclude(l$includeInUpdate);
    }
    if (_$data.containsKey('name')) {
      final l$name = name;
      result$data['name'] = l$name;
    }
    return result$data;
  }

  CopyWith$Input$UpdateCategoryPatchInput<Input$UpdateCategoryPatchInput>
      get copyWith => CopyWith$Input$UpdateCategoryPatchInput(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$UpdateCategoryPatchInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$$default = $default;
    final lOther$$default = other.$default;
    if (_$data.containsKey('default') != other._$data.containsKey('default')) {
      return false;
    }
    if (l$$default != lOther$$default) {
      return false;
    }
    final l$includeInDownload = includeInDownload;
    final lOther$includeInDownload = other.includeInDownload;
    if (_$data.containsKey('includeInDownload') !=
        other._$data.containsKey('includeInDownload')) {
      return false;
    }
    if (l$includeInDownload != lOther$includeInDownload) {
      return false;
    }
    final l$includeInUpdate = includeInUpdate;
    final lOther$includeInUpdate = other.includeInUpdate;
    if (_$data.containsKey('includeInUpdate') !=
        other._$data.containsKey('includeInUpdate')) {
      return false;
    }
    if (l$includeInUpdate != lOther$includeInUpdate) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (_$data.containsKey('name') != other._$data.containsKey('name')) {
      return false;
    }
    if (l$name != lOther$name) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$$default = $default;
    final l$includeInDownload = includeInDownload;
    final l$includeInUpdate = includeInUpdate;
    final l$name = name;
    return Object.hashAll([
      _$data.containsKey('default') ? l$$default : const {},
      _$data.containsKey('includeInDownload') ? l$includeInDownload : const {},
      _$data.containsKey('includeInUpdate') ? l$includeInUpdate : const {},
      _$data.containsKey('name') ? l$name : const {},
    ]);
  }
}

abstract class CopyWith$Input$UpdateCategoryPatchInput<TRes> {
  factory CopyWith$Input$UpdateCategoryPatchInput(
    Input$UpdateCategoryPatchInput instance,
    TRes Function(Input$UpdateCategoryPatchInput) then,
  ) = _CopyWithImpl$Input$UpdateCategoryPatchInput;

  factory CopyWith$Input$UpdateCategoryPatchInput.stub(TRes res) =
      _CopyWithStubImpl$Input$UpdateCategoryPatchInput;

  TRes call({
    bool? $default,
    Enum$IncludeOrExclude? includeInDownload,
    Enum$IncludeOrExclude? includeInUpdate,
    String? name,
  });
}

class _CopyWithImpl$Input$UpdateCategoryPatchInput<TRes>
    implements CopyWith$Input$UpdateCategoryPatchInput<TRes> {
  _CopyWithImpl$Input$UpdateCategoryPatchInput(
    this._instance,
    this._then,
  );

  final Input$UpdateCategoryPatchInput _instance;

  final TRes Function(Input$UpdateCategoryPatchInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? $default = _undefined,
    Object? includeInDownload = _undefined,
    Object? includeInUpdate = _undefined,
    Object? name = _undefined,
  }) =>
      _then(Input$UpdateCategoryPatchInput._({
        ..._instance._$data,
        if ($default != _undefined) 'default': ($default as bool?),
        if (includeInDownload != _undefined)
          'includeInDownload': (includeInDownload as Enum$IncludeOrExclude?),
        if (includeInUpdate != _undefined)
          'includeInUpdate': (includeInUpdate as Enum$IncludeOrExclude?),
        if (name != _undefined) 'name': (name as String?),
      }));
}

class _CopyWithStubImpl$Input$UpdateCategoryPatchInput<TRes>
    implements CopyWith$Input$UpdateCategoryPatchInput<TRes> {
  _CopyWithStubImpl$Input$UpdateCategoryPatchInput(this._res);

  TRes _res;

  call({
    bool? $default,
    Enum$IncludeOrExclude? includeInDownload,
    Enum$IncludeOrExclude? includeInUpdate,
    String? name,
  }) =>
      _res;
}

class Input$UpdateChapterInput {
  factory Input$UpdateChapterInput({
    String? clientMutationId,
    required int id,
    required Input$UpdateChapterPatchInput patch,
  }) =>
      Input$UpdateChapterInput._({
        if (clientMutationId != null) r'clientMutationId': clientMutationId,
        r'id': id,
        r'patch': patch,
      });

  Input$UpdateChapterInput._(this._$data);

  factory Input$UpdateChapterInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('clientMutationId')) {
      final l$clientMutationId = data['clientMutationId'];
      result$data['clientMutationId'] = (l$clientMutationId as String?);
    }
    final l$id = data['id'];
    result$data['id'] = (l$id as int);
    final l$patch = data['patch'];
    result$data['patch'] = Input$UpdateChapterPatchInput.fromJson(
        (l$patch as Map<String, dynamic>));
    return Input$UpdateChapterInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get clientMutationId => (_$data['clientMutationId'] as String?);

  int get id => (_$data['id'] as int);

  Input$UpdateChapterPatchInput get patch =>
      (_$data['patch'] as Input$UpdateChapterPatchInput);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('clientMutationId')) {
      final l$clientMutationId = clientMutationId;
      result$data['clientMutationId'] = l$clientMutationId;
    }
    final l$id = id;
    result$data['id'] = l$id;
    final l$patch = patch;
    result$data['patch'] = l$patch.toJson();
    return result$data;
  }

  CopyWith$Input$UpdateChapterInput<Input$UpdateChapterInput> get copyWith =>
      CopyWith$Input$UpdateChapterInput(
        this,
        (i) => i,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$UpdateChapterInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (_$data.containsKey('clientMutationId') !=
        other._$data.containsKey('clientMutationId')) {
      return false;
    }
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$patch = patch;
    final lOther$patch = other.patch;
    if (l$patch != lOther$patch) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$clientMutationId = clientMutationId;
    final l$id = id;
    final l$patch = patch;
    return Object.hashAll([
      _$data.containsKey('clientMutationId') ? l$clientMutationId : const {},
      l$id,
      l$patch,
    ]);
  }
}

abstract class CopyWith$Input$UpdateChapterInput<TRes> {
  factory CopyWith$Input$UpdateChapterInput(
    Input$UpdateChapterInput instance,
    TRes Function(Input$UpdateChapterInput) then,
  ) = _CopyWithImpl$Input$UpdateChapterInput;

  factory CopyWith$Input$UpdateChapterInput.stub(TRes res) =
      _CopyWithStubImpl$Input$UpdateChapterInput;

  TRes call({
    String? clientMutationId,
    int? id,
    Input$UpdateChapterPatchInput? patch,
  });
  CopyWith$Input$UpdateChapterPatchInput<TRes> get patch;
}

class _CopyWithImpl$Input$UpdateChapterInput<TRes>
    implements CopyWith$Input$UpdateChapterInput<TRes> {
  _CopyWithImpl$Input$UpdateChapterInput(
    this._instance,
    this._then,
  );

  final Input$UpdateChapterInput _instance;

  final TRes Function(Input$UpdateChapterInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? clientMutationId = _undefined,
    Object? id = _undefined,
    Object? patch = _undefined,
  }) =>
      _then(Input$UpdateChapterInput._({
        ..._instance._$data,
        if (clientMutationId != _undefined)
          'clientMutationId': (clientMutationId as String?),
        if (id != _undefined && id != null) 'id': (id as int),
        if (patch != _undefined && patch != null)
          'patch': (patch as Input$UpdateChapterPatchInput),
      }));

  CopyWith$Input$UpdateChapterPatchInput<TRes> get patch {
    final local$patch = _instance.patch;
    return CopyWith$Input$UpdateChapterPatchInput(
        local$patch, (e) => call(patch: e));
  }
}

class _CopyWithStubImpl$Input$UpdateChapterInput<TRes>
    implements CopyWith$Input$UpdateChapterInput<TRes> {
  _CopyWithStubImpl$Input$UpdateChapterInput(this._res);

  TRes _res;

  call({
    String? clientMutationId,
    int? id,
    Input$UpdateChapterPatchInput? patch,
  }) =>
      _res;

  CopyWith$Input$UpdateChapterPatchInput<TRes> get patch =>
      CopyWith$Input$UpdateChapterPatchInput.stub(_res);
}

class Input$UpdateChapterPatchInput {
  factory Input$UpdateChapterPatchInput({
    bool? isBookmarked,
    bool? isRead,
    int? lastPageRead,
  }) =>
      Input$UpdateChapterPatchInput._({
        if (isBookmarked != null) r'isBookmarked': isBookmarked,
        if (isRead != null) r'isRead': isRead,
        if (lastPageRead != null) r'lastPageRead': lastPageRead,
      });

  Input$UpdateChapterPatchInput._(this._$data);

  factory Input$UpdateChapterPatchInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('isBookmarked')) {
      final l$isBookmarked = data['isBookmarked'];
      result$data['isBookmarked'] = (l$isBookmarked as bool?);
    }
    if (data.containsKey('isRead')) {
      final l$isRead = data['isRead'];
      result$data['isRead'] = (l$isRead as bool?);
    }
    if (data.containsKey('lastPageRead')) {
      final l$lastPageRead = data['lastPageRead'];
      result$data['lastPageRead'] = (l$lastPageRead as int?);
    }
    return Input$UpdateChapterPatchInput._(result$data);
  }

  Map<String, dynamic> _$data;

  bool? get isBookmarked => (_$data['isBookmarked'] as bool?);

  bool? get isRead => (_$data['isRead'] as bool?);

  int? get lastPageRead => (_$data['lastPageRead'] as int?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('isBookmarked')) {
      final l$isBookmarked = isBookmarked;
      result$data['isBookmarked'] = l$isBookmarked;
    }
    if (_$data.containsKey('isRead')) {
      final l$isRead = isRead;
      result$data['isRead'] = l$isRead;
    }
    if (_$data.containsKey('lastPageRead')) {
      final l$lastPageRead = lastPageRead;
      result$data['lastPageRead'] = l$lastPageRead;
    }
    return result$data;
  }

  CopyWith$Input$UpdateChapterPatchInput<Input$UpdateChapterPatchInput>
      get copyWith => CopyWith$Input$UpdateChapterPatchInput(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$UpdateChapterPatchInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$isBookmarked = isBookmarked;
    final lOther$isBookmarked = other.isBookmarked;
    if (_$data.containsKey('isBookmarked') !=
        other._$data.containsKey('isBookmarked')) {
      return false;
    }
    if (l$isBookmarked != lOther$isBookmarked) {
      return false;
    }
    final l$isRead = isRead;
    final lOther$isRead = other.isRead;
    if (_$data.containsKey('isRead') != other._$data.containsKey('isRead')) {
      return false;
    }
    if (l$isRead != lOther$isRead) {
      return false;
    }
    final l$lastPageRead = lastPageRead;
    final lOther$lastPageRead = other.lastPageRead;
    if (_$data.containsKey('lastPageRead') !=
        other._$data.containsKey('lastPageRead')) {
      return false;
    }
    if (l$lastPageRead != lOther$lastPageRead) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$isBookmarked = isBookmarked;
    final l$isRead = isRead;
    final l$lastPageRead = lastPageRead;
    return Object.hashAll([
      _$data.containsKey('isBookmarked') ? l$isBookmarked : const {},
      _$data.containsKey('isRead') ? l$isRead : const {},
      _$data.containsKey('lastPageRead') ? l$lastPageRead : const {},
    ]);
  }
}

abstract class CopyWith$Input$UpdateChapterPatchInput<TRes> {
  factory CopyWith$Input$UpdateChapterPatchInput(
    Input$UpdateChapterPatchInput instance,
    TRes Function(Input$UpdateChapterPatchInput) then,
  ) = _CopyWithImpl$Input$UpdateChapterPatchInput;

  factory CopyWith$Input$UpdateChapterPatchInput.stub(TRes res) =
      _CopyWithStubImpl$Input$UpdateChapterPatchInput;

  TRes call({
    bool? isBookmarked,
    bool? isRead,
    int? lastPageRead,
  });
}

class _CopyWithImpl$Input$UpdateChapterPatchInput<TRes>
    implements CopyWith$Input$UpdateChapterPatchInput<TRes> {
  _CopyWithImpl$Input$UpdateChapterPatchInput(
    this._instance,
    this._then,
  );

  final Input$UpdateChapterPatchInput _instance;

  final TRes Function(Input$UpdateChapterPatchInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? isBookmarked = _undefined,
    Object? isRead = _undefined,
    Object? lastPageRead = _undefined,
  }) =>
      _then(Input$UpdateChapterPatchInput._({
        ..._instance._$data,
        if (isBookmarked != _undefined) 'isBookmarked': (isBookmarked as bool?),
        if (isRead != _undefined) 'isRead': (isRead as bool?),
        if (lastPageRead != _undefined) 'lastPageRead': (lastPageRead as int?),
      }));
}

class _CopyWithStubImpl$Input$UpdateChapterPatchInput<TRes>
    implements CopyWith$Input$UpdateChapterPatchInput<TRes> {
  _CopyWithStubImpl$Input$UpdateChapterPatchInput(this._res);

  TRes _res;

  call({
    bool? isBookmarked,
    bool? isRead,
    int? lastPageRead,
  }) =>
      _res;
}

class Input$UpdateChaptersInput {
  factory Input$UpdateChaptersInput({
    String? clientMutationId,
    required List<int> ids,
    required Input$UpdateChapterPatchInput patch,
  }) =>
      Input$UpdateChaptersInput._({
        if (clientMutationId != null) r'clientMutationId': clientMutationId,
        r'ids': ids,
        r'patch': patch,
      });

  Input$UpdateChaptersInput._(this._$data);

  factory Input$UpdateChaptersInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('clientMutationId')) {
      final l$clientMutationId = data['clientMutationId'];
      result$data['clientMutationId'] = (l$clientMutationId as String?);
    }
    final l$ids = data['ids'];
    result$data['ids'] =
        (l$ids as List<dynamic>).map((e) => (e as int)).toList();
    final l$patch = data['patch'];
    result$data['patch'] = Input$UpdateChapterPatchInput.fromJson(
        (l$patch as Map<String, dynamic>));
    return Input$UpdateChaptersInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get clientMutationId => (_$data['clientMutationId'] as String?);

  List<int> get ids => (_$data['ids'] as List<int>);

  Input$UpdateChapterPatchInput get patch =>
      (_$data['patch'] as Input$UpdateChapterPatchInput);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('clientMutationId')) {
      final l$clientMutationId = clientMutationId;
      result$data['clientMutationId'] = l$clientMutationId;
    }
    final l$ids = ids;
    result$data['ids'] = l$ids.map((e) => e).toList();
    final l$patch = patch;
    result$data['patch'] = l$patch.toJson();
    return result$data;
  }

  CopyWith$Input$UpdateChaptersInput<Input$UpdateChaptersInput> get copyWith =>
      CopyWith$Input$UpdateChaptersInput(
        this,
        (i) => i,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$UpdateChaptersInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (_$data.containsKey('clientMutationId') !=
        other._$data.containsKey('clientMutationId')) {
      return false;
    }
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    final l$ids = ids;
    final lOther$ids = other.ids;
    if (l$ids.length != lOther$ids.length) {
      return false;
    }
    for (int i = 0; i < l$ids.length; i++) {
      final l$ids$entry = l$ids[i];
      final lOther$ids$entry = lOther$ids[i];
      if (l$ids$entry != lOther$ids$entry) {
        return false;
      }
    }
    final l$patch = patch;
    final lOther$patch = other.patch;
    if (l$patch != lOther$patch) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$clientMutationId = clientMutationId;
    final l$ids = ids;
    final l$patch = patch;
    return Object.hashAll([
      _$data.containsKey('clientMutationId') ? l$clientMutationId : const {},
      Object.hashAll(l$ids.map((v) => v)),
      l$patch,
    ]);
  }
}

abstract class CopyWith$Input$UpdateChaptersInput<TRes> {
  factory CopyWith$Input$UpdateChaptersInput(
    Input$UpdateChaptersInput instance,
    TRes Function(Input$UpdateChaptersInput) then,
  ) = _CopyWithImpl$Input$UpdateChaptersInput;

  factory CopyWith$Input$UpdateChaptersInput.stub(TRes res) =
      _CopyWithStubImpl$Input$UpdateChaptersInput;

  TRes call({
    String? clientMutationId,
    List<int>? ids,
    Input$UpdateChapterPatchInput? patch,
  });
  CopyWith$Input$UpdateChapterPatchInput<TRes> get patch;
}

class _CopyWithImpl$Input$UpdateChaptersInput<TRes>
    implements CopyWith$Input$UpdateChaptersInput<TRes> {
  _CopyWithImpl$Input$UpdateChaptersInput(
    this._instance,
    this._then,
  );

  final Input$UpdateChaptersInput _instance;

  final TRes Function(Input$UpdateChaptersInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? clientMutationId = _undefined,
    Object? ids = _undefined,
    Object? patch = _undefined,
  }) =>
      _then(Input$UpdateChaptersInput._({
        ..._instance._$data,
        if (clientMutationId != _undefined)
          'clientMutationId': (clientMutationId as String?),
        if (ids != _undefined && ids != null) 'ids': (ids as List<int>),
        if (patch != _undefined && patch != null)
          'patch': (patch as Input$UpdateChapterPatchInput),
      }));

  CopyWith$Input$UpdateChapterPatchInput<TRes> get patch {
    final local$patch = _instance.patch;
    return CopyWith$Input$UpdateChapterPatchInput(
        local$patch, (e) => call(patch: e));
  }
}

class _CopyWithStubImpl$Input$UpdateChaptersInput<TRes>
    implements CopyWith$Input$UpdateChaptersInput<TRes> {
  _CopyWithStubImpl$Input$UpdateChaptersInput(this._res);

  TRes _res;

  call({
    String? clientMutationId,
    List<int>? ids,
    Input$UpdateChapterPatchInput? patch,
  }) =>
      _res;

  CopyWith$Input$UpdateChapterPatchInput<TRes> get patch =>
      CopyWith$Input$UpdateChapterPatchInput.stub(_res);
}

class Input$UpdateExtensionInput {
  factory Input$UpdateExtensionInput({
    String? clientMutationId,
    required String id,
    required Input$UpdateExtensionPatchInput patch,
  }) =>
      Input$UpdateExtensionInput._({
        if (clientMutationId != null) r'clientMutationId': clientMutationId,
        r'id': id,
        r'patch': patch,
      });

  Input$UpdateExtensionInput._(this._$data);

  factory Input$UpdateExtensionInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('clientMutationId')) {
      final l$clientMutationId = data['clientMutationId'];
      result$data['clientMutationId'] = (l$clientMutationId as String?);
    }
    final l$id = data['id'];
    result$data['id'] = (l$id as String);
    final l$patch = data['patch'];
    result$data['patch'] = Input$UpdateExtensionPatchInput.fromJson(
        (l$patch as Map<String, dynamic>));
    return Input$UpdateExtensionInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get clientMutationId => (_$data['clientMutationId'] as String?);

  String get id => (_$data['id'] as String);

  Input$UpdateExtensionPatchInput get patch =>
      (_$data['patch'] as Input$UpdateExtensionPatchInput);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('clientMutationId')) {
      final l$clientMutationId = clientMutationId;
      result$data['clientMutationId'] = l$clientMutationId;
    }
    final l$id = id;
    result$data['id'] = l$id;
    final l$patch = patch;
    result$data['patch'] = l$patch.toJson();
    return result$data;
  }

  CopyWith$Input$UpdateExtensionInput<Input$UpdateExtensionInput>
      get copyWith => CopyWith$Input$UpdateExtensionInput(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$UpdateExtensionInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (_$data.containsKey('clientMutationId') !=
        other._$data.containsKey('clientMutationId')) {
      return false;
    }
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$patch = patch;
    final lOther$patch = other.patch;
    if (l$patch != lOther$patch) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$clientMutationId = clientMutationId;
    final l$id = id;
    final l$patch = patch;
    return Object.hashAll([
      _$data.containsKey('clientMutationId') ? l$clientMutationId : const {},
      l$id,
      l$patch,
    ]);
  }
}

abstract class CopyWith$Input$UpdateExtensionInput<TRes> {
  factory CopyWith$Input$UpdateExtensionInput(
    Input$UpdateExtensionInput instance,
    TRes Function(Input$UpdateExtensionInput) then,
  ) = _CopyWithImpl$Input$UpdateExtensionInput;

  factory CopyWith$Input$UpdateExtensionInput.stub(TRes res) =
      _CopyWithStubImpl$Input$UpdateExtensionInput;

  TRes call({
    String? clientMutationId,
    String? id,
    Input$UpdateExtensionPatchInput? patch,
  });
  CopyWith$Input$UpdateExtensionPatchInput<TRes> get patch;
}

class _CopyWithImpl$Input$UpdateExtensionInput<TRes>
    implements CopyWith$Input$UpdateExtensionInput<TRes> {
  _CopyWithImpl$Input$UpdateExtensionInput(
    this._instance,
    this._then,
  );

  final Input$UpdateExtensionInput _instance;

  final TRes Function(Input$UpdateExtensionInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? clientMutationId = _undefined,
    Object? id = _undefined,
    Object? patch = _undefined,
  }) =>
      _then(Input$UpdateExtensionInput._({
        ..._instance._$data,
        if (clientMutationId != _undefined)
          'clientMutationId': (clientMutationId as String?),
        if (id != _undefined && id != null) 'id': (id as String),
        if (patch != _undefined && patch != null)
          'patch': (patch as Input$UpdateExtensionPatchInput),
      }));

  CopyWith$Input$UpdateExtensionPatchInput<TRes> get patch {
    final local$patch = _instance.patch;
    return CopyWith$Input$UpdateExtensionPatchInput(
        local$patch, (e) => call(patch: e));
  }
}

class _CopyWithStubImpl$Input$UpdateExtensionInput<TRes>
    implements CopyWith$Input$UpdateExtensionInput<TRes> {
  _CopyWithStubImpl$Input$UpdateExtensionInput(this._res);

  TRes _res;

  call({
    String? clientMutationId,
    String? id,
    Input$UpdateExtensionPatchInput? patch,
  }) =>
      _res;

  CopyWith$Input$UpdateExtensionPatchInput<TRes> get patch =>
      CopyWith$Input$UpdateExtensionPatchInput.stub(_res);
}

class Input$UpdateExtensionPatchInput {
  factory Input$UpdateExtensionPatchInput({
    bool? install,
    bool? uninstall,
    bool? update,
  }) =>
      Input$UpdateExtensionPatchInput._({
        if (install != null) r'install': install,
        if (uninstall != null) r'uninstall': uninstall,
        if (update != null) r'update': update,
      });

  Input$UpdateExtensionPatchInput._(this._$data);

  factory Input$UpdateExtensionPatchInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('install')) {
      final l$install = data['install'];
      result$data['install'] = (l$install as bool?);
    }
    if (data.containsKey('uninstall')) {
      final l$uninstall = data['uninstall'];
      result$data['uninstall'] = (l$uninstall as bool?);
    }
    if (data.containsKey('update')) {
      final l$update = data['update'];
      result$data['update'] = (l$update as bool?);
    }
    return Input$UpdateExtensionPatchInput._(result$data);
  }

  Map<String, dynamic> _$data;

  bool? get install => (_$data['install'] as bool?);

  bool? get uninstall => (_$data['uninstall'] as bool?);

  bool? get update => (_$data['update'] as bool?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('install')) {
      final l$install = install;
      result$data['install'] = l$install;
    }
    if (_$data.containsKey('uninstall')) {
      final l$uninstall = uninstall;
      result$data['uninstall'] = l$uninstall;
    }
    if (_$data.containsKey('update')) {
      final l$update = update;
      result$data['update'] = l$update;
    }
    return result$data;
  }

  CopyWith$Input$UpdateExtensionPatchInput<Input$UpdateExtensionPatchInput>
      get copyWith => CopyWith$Input$UpdateExtensionPatchInput(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$UpdateExtensionPatchInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$install = install;
    final lOther$install = other.install;
    if (_$data.containsKey('install') != other._$data.containsKey('install')) {
      return false;
    }
    if (l$install != lOther$install) {
      return false;
    }
    final l$uninstall = uninstall;
    final lOther$uninstall = other.uninstall;
    if (_$data.containsKey('uninstall') !=
        other._$data.containsKey('uninstall')) {
      return false;
    }
    if (l$uninstall != lOther$uninstall) {
      return false;
    }
    final l$update = update;
    final lOther$update = other.update;
    if (_$data.containsKey('update') != other._$data.containsKey('update')) {
      return false;
    }
    if (l$update != lOther$update) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$install = install;
    final l$uninstall = uninstall;
    final l$update = update;
    return Object.hashAll([
      _$data.containsKey('install') ? l$install : const {},
      _$data.containsKey('uninstall') ? l$uninstall : const {},
      _$data.containsKey('update') ? l$update : const {},
    ]);
  }
}

abstract class CopyWith$Input$UpdateExtensionPatchInput<TRes> {
  factory CopyWith$Input$UpdateExtensionPatchInput(
    Input$UpdateExtensionPatchInput instance,
    TRes Function(Input$UpdateExtensionPatchInput) then,
  ) = _CopyWithImpl$Input$UpdateExtensionPatchInput;

  factory CopyWith$Input$UpdateExtensionPatchInput.stub(TRes res) =
      _CopyWithStubImpl$Input$UpdateExtensionPatchInput;

  TRes call({
    bool? install,
    bool? uninstall,
    bool? update,
  });
}

class _CopyWithImpl$Input$UpdateExtensionPatchInput<TRes>
    implements CopyWith$Input$UpdateExtensionPatchInput<TRes> {
  _CopyWithImpl$Input$UpdateExtensionPatchInput(
    this._instance,
    this._then,
  );

  final Input$UpdateExtensionPatchInput _instance;

  final TRes Function(Input$UpdateExtensionPatchInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? install = _undefined,
    Object? uninstall = _undefined,
    Object? update = _undefined,
  }) =>
      _then(Input$UpdateExtensionPatchInput._({
        ..._instance._$data,
        if (install != _undefined) 'install': (install as bool?),
        if (uninstall != _undefined) 'uninstall': (uninstall as bool?),
        if (update != _undefined) 'update': (update as bool?),
      }));
}

class _CopyWithStubImpl$Input$UpdateExtensionPatchInput<TRes>
    implements CopyWith$Input$UpdateExtensionPatchInput<TRes> {
  _CopyWithStubImpl$Input$UpdateExtensionPatchInput(this._res);

  TRes _res;

  call({
    bool? install,
    bool? uninstall,
    bool? update,
  }) =>
      _res;
}

class Input$UpdateExtensionsInput {
  factory Input$UpdateExtensionsInput({
    String? clientMutationId,
    required List<String> ids,
    required Input$UpdateExtensionPatchInput patch,
  }) =>
      Input$UpdateExtensionsInput._({
        if (clientMutationId != null) r'clientMutationId': clientMutationId,
        r'ids': ids,
        r'patch': patch,
      });

  Input$UpdateExtensionsInput._(this._$data);

  factory Input$UpdateExtensionsInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('clientMutationId')) {
      final l$clientMutationId = data['clientMutationId'];
      result$data['clientMutationId'] = (l$clientMutationId as String?);
    }
    final l$ids = data['ids'];
    result$data['ids'] =
        (l$ids as List<dynamic>).map((e) => (e as String)).toList();
    final l$patch = data['patch'];
    result$data['patch'] = Input$UpdateExtensionPatchInput.fromJson(
        (l$patch as Map<String, dynamic>));
    return Input$UpdateExtensionsInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get clientMutationId => (_$data['clientMutationId'] as String?);

  List<String> get ids => (_$data['ids'] as List<String>);

  Input$UpdateExtensionPatchInput get patch =>
      (_$data['patch'] as Input$UpdateExtensionPatchInput);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('clientMutationId')) {
      final l$clientMutationId = clientMutationId;
      result$data['clientMutationId'] = l$clientMutationId;
    }
    final l$ids = ids;
    result$data['ids'] = l$ids.map((e) => e).toList();
    final l$patch = patch;
    result$data['patch'] = l$patch.toJson();
    return result$data;
  }

  CopyWith$Input$UpdateExtensionsInput<Input$UpdateExtensionsInput>
      get copyWith => CopyWith$Input$UpdateExtensionsInput(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$UpdateExtensionsInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (_$data.containsKey('clientMutationId') !=
        other._$data.containsKey('clientMutationId')) {
      return false;
    }
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    final l$ids = ids;
    final lOther$ids = other.ids;
    if (l$ids.length != lOther$ids.length) {
      return false;
    }
    for (int i = 0; i < l$ids.length; i++) {
      final l$ids$entry = l$ids[i];
      final lOther$ids$entry = lOther$ids[i];
      if (l$ids$entry != lOther$ids$entry) {
        return false;
      }
    }
    final l$patch = patch;
    final lOther$patch = other.patch;
    if (l$patch != lOther$patch) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$clientMutationId = clientMutationId;
    final l$ids = ids;
    final l$patch = patch;
    return Object.hashAll([
      _$data.containsKey('clientMutationId') ? l$clientMutationId : const {},
      Object.hashAll(l$ids.map((v) => v)),
      l$patch,
    ]);
  }
}

abstract class CopyWith$Input$UpdateExtensionsInput<TRes> {
  factory CopyWith$Input$UpdateExtensionsInput(
    Input$UpdateExtensionsInput instance,
    TRes Function(Input$UpdateExtensionsInput) then,
  ) = _CopyWithImpl$Input$UpdateExtensionsInput;

  factory CopyWith$Input$UpdateExtensionsInput.stub(TRes res) =
      _CopyWithStubImpl$Input$UpdateExtensionsInput;

  TRes call({
    String? clientMutationId,
    List<String>? ids,
    Input$UpdateExtensionPatchInput? patch,
  });
  CopyWith$Input$UpdateExtensionPatchInput<TRes> get patch;
}

class _CopyWithImpl$Input$UpdateExtensionsInput<TRes>
    implements CopyWith$Input$UpdateExtensionsInput<TRes> {
  _CopyWithImpl$Input$UpdateExtensionsInput(
    this._instance,
    this._then,
  );

  final Input$UpdateExtensionsInput _instance;

  final TRes Function(Input$UpdateExtensionsInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? clientMutationId = _undefined,
    Object? ids = _undefined,
    Object? patch = _undefined,
  }) =>
      _then(Input$UpdateExtensionsInput._({
        ..._instance._$data,
        if (clientMutationId != _undefined)
          'clientMutationId': (clientMutationId as String?),
        if (ids != _undefined && ids != null) 'ids': (ids as List<String>),
        if (patch != _undefined && patch != null)
          'patch': (patch as Input$UpdateExtensionPatchInput),
      }));

  CopyWith$Input$UpdateExtensionPatchInput<TRes> get patch {
    final local$patch = _instance.patch;
    return CopyWith$Input$UpdateExtensionPatchInput(
        local$patch, (e) => call(patch: e));
  }
}

class _CopyWithStubImpl$Input$UpdateExtensionsInput<TRes>
    implements CopyWith$Input$UpdateExtensionsInput<TRes> {
  _CopyWithStubImpl$Input$UpdateExtensionsInput(this._res);

  TRes _res;

  call({
    String? clientMutationId,
    List<String>? ids,
    Input$UpdateExtensionPatchInput? patch,
  }) =>
      _res;

  CopyWith$Input$UpdateExtensionPatchInput<TRes> get patch =>
      CopyWith$Input$UpdateExtensionPatchInput.stub(_res);
}

class Input$UpdateLibraryMangaInput {
  factory Input$UpdateLibraryMangaInput({String? clientMutationId}) =>
      Input$UpdateLibraryMangaInput._({
        if (clientMutationId != null) r'clientMutationId': clientMutationId,
      });

  Input$UpdateLibraryMangaInput._(this._$data);

  factory Input$UpdateLibraryMangaInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('clientMutationId')) {
      final l$clientMutationId = data['clientMutationId'];
      result$data['clientMutationId'] = (l$clientMutationId as String?);
    }
    return Input$UpdateLibraryMangaInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get clientMutationId => (_$data['clientMutationId'] as String?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('clientMutationId')) {
      final l$clientMutationId = clientMutationId;
      result$data['clientMutationId'] = l$clientMutationId;
    }
    return result$data;
  }

  CopyWith$Input$UpdateLibraryMangaInput<Input$UpdateLibraryMangaInput>
      get copyWith => CopyWith$Input$UpdateLibraryMangaInput(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$UpdateLibraryMangaInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (_$data.containsKey('clientMutationId') !=
        other._$data.containsKey('clientMutationId')) {
      return false;
    }
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$clientMutationId = clientMutationId;
    return Object.hashAll([
      _$data.containsKey('clientMutationId') ? l$clientMutationId : const {}
    ]);
  }
}

abstract class CopyWith$Input$UpdateLibraryMangaInput<TRes> {
  factory CopyWith$Input$UpdateLibraryMangaInput(
    Input$UpdateLibraryMangaInput instance,
    TRes Function(Input$UpdateLibraryMangaInput) then,
  ) = _CopyWithImpl$Input$UpdateLibraryMangaInput;

  factory CopyWith$Input$UpdateLibraryMangaInput.stub(TRes res) =
      _CopyWithStubImpl$Input$UpdateLibraryMangaInput;

  TRes call({String? clientMutationId});
}

class _CopyWithImpl$Input$UpdateLibraryMangaInput<TRes>
    implements CopyWith$Input$UpdateLibraryMangaInput<TRes> {
  _CopyWithImpl$Input$UpdateLibraryMangaInput(
    this._instance,
    this._then,
  );

  final Input$UpdateLibraryMangaInput _instance;

  final TRes Function(Input$UpdateLibraryMangaInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? clientMutationId = _undefined}) =>
      _then(Input$UpdateLibraryMangaInput._({
        ..._instance._$data,
        if (clientMutationId != _undefined)
          'clientMutationId': (clientMutationId as String?),
      }));
}

class _CopyWithStubImpl$Input$UpdateLibraryMangaInput<TRes>
    implements CopyWith$Input$UpdateLibraryMangaInput<TRes> {
  _CopyWithStubImpl$Input$UpdateLibraryMangaInput(this._res);

  TRes _res;

  call({String? clientMutationId}) => _res;
}

class Input$UpdateMangaCategoriesInput {
  factory Input$UpdateMangaCategoriesInput({
    String? clientMutationId,
    required int id,
    required Input$UpdateMangaCategoriesPatchInput patch,
  }) =>
      Input$UpdateMangaCategoriesInput._({
        if (clientMutationId != null) r'clientMutationId': clientMutationId,
        r'id': id,
        r'patch': patch,
      });

  Input$UpdateMangaCategoriesInput._(this._$data);

  factory Input$UpdateMangaCategoriesInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('clientMutationId')) {
      final l$clientMutationId = data['clientMutationId'];
      result$data['clientMutationId'] = (l$clientMutationId as String?);
    }
    final l$id = data['id'];
    result$data['id'] = (l$id as int);
    final l$patch = data['patch'];
    result$data['patch'] = Input$UpdateMangaCategoriesPatchInput.fromJson(
        (l$patch as Map<String, dynamic>));
    return Input$UpdateMangaCategoriesInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get clientMutationId => (_$data['clientMutationId'] as String?);

  int get id => (_$data['id'] as int);

  Input$UpdateMangaCategoriesPatchInput get patch =>
      (_$data['patch'] as Input$UpdateMangaCategoriesPatchInput);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('clientMutationId')) {
      final l$clientMutationId = clientMutationId;
      result$data['clientMutationId'] = l$clientMutationId;
    }
    final l$id = id;
    result$data['id'] = l$id;
    final l$patch = patch;
    result$data['patch'] = l$patch.toJson();
    return result$data;
  }

  CopyWith$Input$UpdateMangaCategoriesInput<Input$UpdateMangaCategoriesInput>
      get copyWith => CopyWith$Input$UpdateMangaCategoriesInput(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$UpdateMangaCategoriesInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (_$data.containsKey('clientMutationId') !=
        other._$data.containsKey('clientMutationId')) {
      return false;
    }
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$patch = patch;
    final lOther$patch = other.patch;
    if (l$patch != lOther$patch) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$clientMutationId = clientMutationId;
    final l$id = id;
    final l$patch = patch;
    return Object.hashAll([
      _$data.containsKey('clientMutationId') ? l$clientMutationId : const {},
      l$id,
      l$patch,
    ]);
  }
}

abstract class CopyWith$Input$UpdateMangaCategoriesInput<TRes> {
  factory CopyWith$Input$UpdateMangaCategoriesInput(
    Input$UpdateMangaCategoriesInput instance,
    TRes Function(Input$UpdateMangaCategoriesInput) then,
  ) = _CopyWithImpl$Input$UpdateMangaCategoriesInput;

  factory CopyWith$Input$UpdateMangaCategoriesInput.stub(TRes res) =
      _CopyWithStubImpl$Input$UpdateMangaCategoriesInput;

  TRes call({
    String? clientMutationId,
    int? id,
    Input$UpdateMangaCategoriesPatchInput? patch,
  });
  CopyWith$Input$UpdateMangaCategoriesPatchInput<TRes> get patch;
}

class _CopyWithImpl$Input$UpdateMangaCategoriesInput<TRes>
    implements CopyWith$Input$UpdateMangaCategoriesInput<TRes> {
  _CopyWithImpl$Input$UpdateMangaCategoriesInput(
    this._instance,
    this._then,
  );

  final Input$UpdateMangaCategoriesInput _instance;

  final TRes Function(Input$UpdateMangaCategoriesInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? clientMutationId = _undefined,
    Object? id = _undefined,
    Object? patch = _undefined,
  }) =>
      _then(Input$UpdateMangaCategoriesInput._({
        ..._instance._$data,
        if (clientMutationId != _undefined)
          'clientMutationId': (clientMutationId as String?),
        if (id != _undefined && id != null) 'id': (id as int),
        if (patch != _undefined && patch != null)
          'patch': (patch as Input$UpdateMangaCategoriesPatchInput),
      }));

  CopyWith$Input$UpdateMangaCategoriesPatchInput<TRes> get patch {
    final local$patch = _instance.patch;
    return CopyWith$Input$UpdateMangaCategoriesPatchInput(
        local$patch, (e) => call(patch: e));
  }
}

class _CopyWithStubImpl$Input$UpdateMangaCategoriesInput<TRes>
    implements CopyWith$Input$UpdateMangaCategoriesInput<TRes> {
  _CopyWithStubImpl$Input$UpdateMangaCategoriesInput(this._res);

  TRes _res;

  call({
    String? clientMutationId,
    int? id,
    Input$UpdateMangaCategoriesPatchInput? patch,
  }) =>
      _res;

  CopyWith$Input$UpdateMangaCategoriesPatchInput<TRes> get patch =>
      CopyWith$Input$UpdateMangaCategoriesPatchInput.stub(_res);
}

class Input$UpdateMangaCategoriesPatchInput {
  factory Input$UpdateMangaCategoriesPatchInput({
    List<int>? addToCategories,
    bool? clearCategories,
    List<int>? removeFromCategories,
  }) =>
      Input$UpdateMangaCategoriesPatchInput._({
        if (addToCategories != null) r'addToCategories': addToCategories,
        if (clearCategories != null) r'clearCategories': clearCategories,
        if (removeFromCategories != null)
          r'removeFromCategories': removeFromCategories,
      });

  Input$UpdateMangaCategoriesPatchInput._(this._$data);

  factory Input$UpdateMangaCategoriesPatchInput.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('addToCategories')) {
      final l$addToCategories = data['addToCategories'];
      result$data['addToCategories'] = (l$addToCategories as List<dynamic>?)
          ?.map((e) => (e as int))
          .toList();
    }
    if (data.containsKey('clearCategories')) {
      final l$clearCategories = data['clearCategories'];
      result$data['clearCategories'] = (l$clearCategories as bool?);
    }
    if (data.containsKey('removeFromCategories')) {
      final l$removeFromCategories = data['removeFromCategories'];
      result$data['removeFromCategories'] =
          (l$removeFromCategories as List<dynamic>?)
              ?.map((e) => (e as int))
              .toList();
    }
    return Input$UpdateMangaCategoriesPatchInput._(result$data);
  }

  Map<String, dynamic> _$data;

  List<int>? get addToCategories => (_$data['addToCategories'] as List<int>?);

  bool? get clearCategories => (_$data['clearCategories'] as bool?);

  List<int>? get removeFromCategories =>
      (_$data['removeFromCategories'] as List<int>?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('addToCategories')) {
      final l$addToCategories = addToCategories;
      result$data['addToCategories'] =
          l$addToCategories?.map((e) => e).toList();
    }
    if (_$data.containsKey('clearCategories')) {
      final l$clearCategories = clearCategories;
      result$data['clearCategories'] = l$clearCategories;
    }
    if (_$data.containsKey('removeFromCategories')) {
      final l$removeFromCategories = removeFromCategories;
      result$data['removeFromCategories'] =
          l$removeFromCategories?.map((e) => e).toList();
    }
    return result$data;
  }

  CopyWith$Input$UpdateMangaCategoriesPatchInput<
          Input$UpdateMangaCategoriesPatchInput>
      get copyWith => CopyWith$Input$UpdateMangaCategoriesPatchInput(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$UpdateMangaCategoriesPatchInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$addToCategories = addToCategories;
    final lOther$addToCategories = other.addToCategories;
    if (_$data.containsKey('addToCategories') !=
        other._$data.containsKey('addToCategories')) {
      return false;
    }
    if (l$addToCategories != null && lOther$addToCategories != null) {
      if (l$addToCategories.length != lOther$addToCategories.length) {
        return false;
      }
      for (int i = 0; i < l$addToCategories.length; i++) {
        final l$addToCategories$entry = l$addToCategories[i];
        final lOther$addToCategories$entry = lOther$addToCategories[i];
        if (l$addToCategories$entry != lOther$addToCategories$entry) {
          return false;
        }
      }
    } else if (l$addToCategories != lOther$addToCategories) {
      return false;
    }
    final l$clearCategories = clearCategories;
    final lOther$clearCategories = other.clearCategories;
    if (_$data.containsKey('clearCategories') !=
        other._$data.containsKey('clearCategories')) {
      return false;
    }
    if (l$clearCategories != lOther$clearCategories) {
      return false;
    }
    final l$removeFromCategories = removeFromCategories;
    final lOther$removeFromCategories = other.removeFromCategories;
    if (_$data.containsKey('removeFromCategories') !=
        other._$data.containsKey('removeFromCategories')) {
      return false;
    }
    if (l$removeFromCategories != null && lOther$removeFromCategories != null) {
      if (l$removeFromCategories.length != lOther$removeFromCategories.length) {
        return false;
      }
      for (int i = 0; i < l$removeFromCategories.length; i++) {
        final l$removeFromCategories$entry = l$removeFromCategories[i];
        final lOther$removeFromCategories$entry =
            lOther$removeFromCategories[i];
        if (l$removeFromCategories$entry != lOther$removeFromCategories$entry) {
          return false;
        }
      }
    } else if (l$removeFromCategories != lOther$removeFromCategories) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$addToCategories = addToCategories;
    final l$clearCategories = clearCategories;
    final l$removeFromCategories = removeFromCategories;
    return Object.hashAll([
      _$data.containsKey('addToCategories')
          ? l$addToCategories == null
              ? null
              : Object.hashAll(l$addToCategories.map((v) => v))
          : const {},
      _$data.containsKey('clearCategories') ? l$clearCategories : const {},
      _$data.containsKey('removeFromCategories')
          ? l$removeFromCategories == null
              ? null
              : Object.hashAll(l$removeFromCategories.map((v) => v))
          : const {},
    ]);
  }
}

abstract class CopyWith$Input$UpdateMangaCategoriesPatchInput<TRes> {
  factory CopyWith$Input$UpdateMangaCategoriesPatchInput(
    Input$UpdateMangaCategoriesPatchInput instance,
    TRes Function(Input$UpdateMangaCategoriesPatchInput) then,
  ) = _CopyWithImpl$Input$UpdateMangaCategoriesPatchInput;

  factory CopyWith$Input$UpdateMangaCategoriesPatchInput.stub(TRes res) =
      _CopyWithStubImpl$Input$UpdateMangaCategoriesPatchInput;

  TRes call({
    List<int>? addToCategories,
    bool? clearCategories,
    List<int>? removeFromCategories,
  });
}

class _CopyWithImpl$Input$UpdateMangaCategoriesPatchInput<TRes>
    implements CopyWith$Input$UpdateMangaCategoriesPatchInput<TRes> {
  _CopyWithImpl$Input$UpdateMangaCategoriesPatchInput(
    this._instance,
    this._then,
  );

  final Input$UpdateMangaCategoriesPatchInput _instance;

  final TRes Function(Input$UpdateMangaCategoriesPatchInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? addToCategories = _undefined,
    Object? clearCategories = _undefined,
    Object? removeFromCategories = _undefined,
  }) =>
      _then(Input$UpdateMangaCategoriesPatchInput._({
        ..._instance._$data,
        if (addToCategories != _undefined)
          'addToCategories': (addToCategories as List<int>?),
        if (clearCategories != _undefined)
          'clearCategories': (clearCategories as bool?),
        if (removeFromCategories != _undefined)
          'removeFromCategories': (removeFromCategories as List<int>?),
      }));
}

class _CopyWithStubImpl$Input$UpdateMangaCategoriesPatchInput<TRes>
    implements CopyWith$Input$UpdateMangaCategoriesPatchInput<TRes> {
  _CopyWithStubImpl$Input$UpdateMangaCategoriesPatchInput(this._res);

  TRes _res;

  call({
    List<int>? addToCategories,
    bool? clearCategories,
    List<int>? removeFromCategories,
  }) =>
      _res;
}

class Input$UpdateMangaInput {
  factory Input$UpdateMangaInput({
    String? clientMutationId,
    required int id,
    required Input$UpdateMangaPatchInput patch,
  }) =>
      Input$UpdateMangaInput._({
        if (clientMutationId != null) r'clientMutationId': clientMutationId,
        r'id': id,
        r'patch': patch,
      });

  Input$UpdateMangaInput._(this._$data);

  factory Input$UpdateMangaInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('clientMutationId')) {
      final l$clientMutationId = data['clientMutationId'];
      result$data['clientMutationId'] = (l$clientMutationId as String?);
    }
    final l$id = data['id'];
    result$data['id'] = (l$id as int);
    final l$patch = data['patch'];
    result$data['patch'] =
        Input$UpdateMangaPatchInput.fromJson((l$patch as Map<String, dynamic>));
    return Input$UpdateMangaInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get clientMutationId => (_$data['clientMutationId'] as String?);

  int get id => (_$data['id'] as int);

  Input$UpdateMangaPatchInput get patch =>
      (_$data['patch'] as Input$UpdateMangaPatchInput);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('clientMutationId')) {
      final l$clientMutationId = clientMutationId;
      result$data['clientMutationId'] = l$clientMutationId;
    }
    final l$id = id;
    result$data['id'] = l$id;
    final l$patch = patch;
    result$data['patch'] = l$patch.toJson();
    return result$data;
  }

  CopyWith$Input$UpdateMangaInput<Input$UpdateMangaInput> get copyWith =>
      CopyWith$Input$UpdateMangaInput(
        this,
        (i) => i,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$UpdateMangaInput || runtimeType != other.runtimeType) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (_$data.containsKey('clientMutationId') !=
        other._$data.containsKey('clientMutationId')) {
      return false;
    }
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$patch = patch;
    final lOther$patch = other.patch;
    if (l$patch != lOther$patch) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$clientMutationId = clientMutationId;
    final l$id = id;
    final l$patch = patch;
    return Object.hashAll([
      _$data.containsKey('clientMutationId') ? l$clientMutationId : const {},
      l$id,
      l$patch,
    ]);
  }
}

abstract class CopyWith$Input$UpdateMangaInput<TRes> {
  factory CopyWith$Input$UpdateMangaInput(
    Input$UpdateMangaInput instance,
    TRes Function(Input$UpdateMangaInput) then,
  ) = _CopyWithImpl$Input$UpdateMangaInput;

  factory CopyWith$Input$UpdateMangaInput.stub(TRes res) =
      _CopyWithStubImpl$Input$UpdateMangaInput;

  TRes call({
    String? clientMutationId,
    int? id,
    Input$UpdateMangaPatchInput? patch,
  });
  CopyWith$Input$UpdateMangaPatchInput<TRes> get patch;
}

class _CopyWithImpl$Input$UpdateMangaInput<TRes>
    implements CopyWith$Input$UpdateMangaInput<TRes> {
  _CopyWithImpl$Input$UpdateMangaInput(
    this._instance,
    this._then,
  );

  final Input$UpdateMangaInput _instance;

  final TRes Function(Input$UpdateMangaInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? clientMutationId = _undefined,
    Object? id = _undefined,
    Object? patch = _undefined,
  }) =>
      _then(Input$UpdateMangaInput._({
        ..._instance._$data,
        if (clientMutationId != _undefined)
          'clientMutationId': (clientMutationId as String?),
        if (id != _undefined && id != null) 'id': (id as int),
        if (patch != _undefined && patch != null)
          'patch': (patch as Input$UpdateMangaPatchInput),
      }));

  CopyWith$Input$UpdateMangaPatchInput<TRes> get patch {
    final local$patch = _instance.patch;
    return CopyWith$Input$UpdateMangaPatchInput(
        local$patch, (e) => call(patch: e));
  }
}

class _CopyWithStubImpl$Input$UpdateMangaInput<TRes>
    implements CopyWith$Input$UpdateMangaInput<TRes> {
  _CopyWithStubImpl$Input$UpdateMangaInput(this._res);

  TRes _res;

  call({
    String? clientMutationId,
    int? id,
    Input$UpdateMangaPatchInput? patch,
  }) =>
      _res;

  CopyWith$Input$UpdateMangaPatchInput<TRes> get patch =>
      CopyWith$Input$UpdateMangaPatchInput.stub(_res);
}

class Input$UpdateMangaPatchInput {
  factory Input$UpdateMangaPatchInput({bool? inLibrary}) =>
      Input$UpdateMangaPatchInput._({
        if (inLibrary != null) r'inLibrary': inLibrary,
      });

  Input$UpdateMangaPatchInput._(this._$data);

  factory Input$UpdateMangaPatchInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('inLibrary')) {
      final l$inLibrary = data['inLibrary'];
      result$data['inLibrary'] = (l$inLibrary as bool?);
    }
    return Input$UpdateMangaPatchInput._(result$data);
  }

  Map<String, dynamic> _$data;

  bool? get inLibrary => (_$data['inLibrary'] as bool?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('inLibrary')) {
      final l$inLibrary = inLibrary;
      result$data['inLibrary'] = l$inLibrary;
    }
    return result$data;
  }

  CopyWith$Input$UpdateMangaPatchInput<Input$UpdateMangaPatchInput>
      get copyWith => CopyWith$Input$UpdateMangaPatchInput(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$UpdateMangaPatchInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$inLibrary = inLibrary;
    final lOther$inLibrary = other.inLibrary;
    if (_$data.containsKey('inLibrary') !=
        other._$data.containsKey('inLibrary')) {
      return false;
    }
    if (l$inLibrary != lOther$inLibrary) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$inLibrary = inLibrary;
    return Object.hashAll(
        [_$data.containsKey('inLibrary') ? l$inLibrary : const {}]);
  }
}

abstract class CopyWith$Input$UpdateMangaPatchInput<TRes> {
  factory CopyWith$Input$UpdateMangaPatchInput(
    Input$UpdateMangaPatchInput instance,
    TRes Function(Input$UpdateMangaPatchInput) then,
  ) = _CopyWithImpl$Input$UpdateMangaPatchInput;

  factory CopyWith$Input$UpdateMangaPatchInput.stub(TRes res) =
      _CopyWithStubImpl$Input$UpdateMangaPatchInput;

  TRes call({bool? inLibrary});
}

class _CopyWithImpl$Input$UpdateMangaPatchInput<TRes>
    implements CopyWith$Input$UpdateMangaPatchInput<TRes> {
  _CopyWithImpl$Input$UpdateMangaPatchInput(
    this._instance,
    this._then,
  );

  final Input$UpdateMangaPatchInput _instance;

  final TRes Function(Input$UpdateMangaPatchInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? inLibrary = _undefined}) =>
      _then(Input$UpdateMangaPatchInput._({
        ..._instance._$data,
        if (inLibrary != _undefined) 'inLibrary': (inLibrary as bool?),
      }));
}

class _CopyWithStubImpl$Input$UpdateMangaPatchInput<TRes>
    implements CopyWith$Input$UpdateMangaPatchInput<TRes> {
  _CopyWithStubImpl$Input$UpdateMangaPatchInput(this._res);

  TRes _res;

  call({bool? inLibrary}) => _res;
}

class Input$UpdateMangasCategoriesInput {
  factory Input$UpdateMangasCategoriesInput({
    String? clientMutationId,
    required List<int> ids,
    required Input$UpdateMangaCategoriesPatchInput patch,
  }) =>
      Input$UpdateMangasCategoriesInput._({
        if (clientMutationId != null) r'clientMutationId': clientMutationId,
        r'ids': ids,
        r'patch': patch,
      });

  Input$UpdateMangasCategoriesInput._(this._$data);

  factory Input$UpdateMangasCategoriesInput.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('clientMutationId')) {
      final l$clientMutationId = data['clientMutationId'];
      result$data['clientMutationId'] = (l$clientMutationId as String?);
    }
    final l$ids = data['ids'];
    result$data['ids'] =
        (l$ids as List<dynamic>).map((e) => (e as int)).toList();
    final l$patch = data['patch'];
    result$data['patch'] = Input$UpdateMangaCategoriesPatchInput.fromJson(
        (l$patch as Map<String, dynamic>));
    return Input$UpdateMangasCategoriesInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get clientMutationId => (_$data['clientMutationId'] as String?);

  List<int> get ids => (_$data['ids'] as List<int>);

  Input$UpdateMangaCategoriesPatchInput get patch =>
      (_$data['patch'] as Input$UpdateMangaCategoriesPatchInput);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('clientMutationId')) {
      final l$clientMutationId = clientMutationId;
      result$data['clientMutationId'] = l$clientMutationId;
    }
    final l$ids = ids;
    result$data['ids'] = l$ids.map((e) => e).toList();
    final l$patch = patch;
    result$data['patch'] = l$patch.toJson();
    return result$data;
  }

  CopyWith$Input$UpdateMangasCategoriesInput<Input$UpdateMangasCategoriesInput>
      get copyWith => CopyWith$Input$UpdateMangasCategoriesInput(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$UpdateMangasCategoriesInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (_$data.containsKey('clientMutationId') !=
        other._$data.containsKey('clientMutationId')) {
      return false;
    }
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    final l$ids = ids;
    final lOther$ids = other.ids;
    if (l$ids.length != lOther$ids.length) {
      return false;
    }
    for (int i = 0; i < l$ids.length; i++) {
      final l$ids$entry = l$ids[i];
      final lOther$ids$entry = lOther$ids[i];
      if (l$ids$entry != lOther$ids$entry) {
        return false;
      }
    }
    final l$patch = patch;
    final lOther$patch = other.patch;
    if (l$patch != lOther$patch) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$clientMutationId = clientMutationId;
    final l$ids = ids;
    final l$patch = patch;
    return Object.hashAll([
      _$data.containsKey('clientMutationId') ? l$clientMutationId : const {},
      Object.hashAll(l$ids.map((v) => v)),
      l$patch,
    ]);
  }
}

abstract class CopyWith$Input$UpdateMangasCategoriesInput<TRes> {
  factory CopyWith$Input$UpdateMangasCategoriesInput(
    Input$UpdateMangasCategoriesInput instance,
    TRes Function(Input$UpdateMangasCategoriesInput) then,
  ) = _CopyWithImpl$Input$UpdateMangasCategoriesInput;

  factory CopyWith$Input$UpdateMangasCategoriesInput.stub(TRes res) =
      _CopyWithStubImpl$Input$UpdateMangasCategoriesInput;

  TRes call({
    String? clientMutationId,
    List<int>? ids,
    Input$UpdateMangaCategoriesPatchInput? patch,
  });
  CopyWith$Input$UpdateMangaCategoriesPatchInput<TRes> get patch;
}

class _CopyWithImpl$Input$UpdateMangasCategoriesInput<TRes>
    implements CopyWith$Input$UpdateMangasCategoriesInput<TRes> {
  _CopyWithImpl$Input$UpdateMangasCategoriesInput(
    this._instance,
    this._then,
  );

  final Input$UpdateMangasCategoriesInput _instance;

  final TRes Function(Input$UpdateMangasCategoriesInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? clientMutationId = _undefined,
    Object? ids = _undefined,
    Object? patch = _undefined,
  }) =>
      _then(Input$UpdateMangasCategoriesInput._({
        ..._instance._$data,
        if (clientMutationId != _undefined)
          'clientMutationId': (clientMutationId as String?),
        if (ids != _undefined && ids != null) 'ids': (ids as List<int>),
        if (patch != _undefined && patch != null)
          'patch': (patch as Input$UpdateMangaCategoriesPatchInput),
      }));

  CopyWith$Input$UpdateMangaCategoriesPatchInput<TRes> get patch {
    final local$patch = _instance.patch;
    return CopyWith$Input$UpdateMangaCategoriesPatchInput(
        local$patch, (e) => call(patch: e));
  }
}

class _CopyWithStubImpl$Input$UpdateMangasCategoriesInput<TRes>
    implements CopyWith$Input$UpdateMangasCategoriesInput<TRes> {
  _CopyWithStubImpl$Input$UpdateMangasCategoriesInput(this._res);

  TRes _res;

  call({
    String? clientMutationId,
    List<int>? ids,
    Input$UpdateMangaCategoriesPatchInput? patch,
  }) =>
      _res;

  CopyWith$Input$UpdateMangaCategoriesPatchInput<TRes> get patch =>
      CopyWith$Input$UpdateMangaCategoriesPatchInput.stub(_res);
}

class Input$UpdateMangasInput {
  factory Input$UpdateMangasInput({
    String? clientMutationId,
    required List<int> ids,
    required Input$UpdateMangaPatchInput patch,
  }) =>
      Input$UpdateMangasInput._({
        if (clientMutationId != null) r'clientMutationId': clientMutationId,
        r'ids': ids,
        r'patch': patch,
      });

  Input$UpdateMangasInput._(this._$data);

  factory Input$UpdateMangasInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('clientMutationId')) {
      final l$clientMutationId = data['clientMutationId'];
      result$data['clientMutationId'] = (l$clientMutationId as String?);
    }
    final l$ids = data['ids'];
    result$data['ids'] =
        (l$ids as List<dynamic>).map((e) => (e as int)).toList();
    final l$patch = data['patch'];
    result$data['patch'] =
        Input$UpdateMangaPatchInput.fromJson((l$patch as Map<String, dynamic>));
    return Input$UpdateMangasInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get clientMutationId => (_$data['clientMutationId'] as String?);

  List<int> get ids => (_$data['ids'] as List<int>);

  Input$UpdateMangaPatchInput get patch =>
      (_$data['patch'] as Input$UpdateMangaPatchInput);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('clientMutationId')) {
      final l$clientMutationId = clientMutationId;
      result$data['clientMutationId'] = l$clientMutationId;
    }
    final l$ids = ids;
    result$data['ids'] = l$ids.map((e) => e).toList();
    final l$patch = patch;
    result$data['patch'] = l$patch.toJson();
    return result$data;
  }

  CopyWith$Input$UpdateMangasInput<Input$UpdateMangasInput> get copyWith =>
      CopyWith$Input$UpdateMangasInput(
        this,
        (i) => i,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$UpdateMangasInput || runtimeType != other.runtimeType) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (_$data.containsKey('clientMutationId') !=
        other._$data.containsKey('clientMutationId')) {
      return false;
    }
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    final l$ids = ids;
    final lOther$ids = other.ids;
    if (l$ids.length != lOther$ids.length) {
      return false;
    }
    for (int i = 0; i < l$ids.length; i++) {
      final l$ids$entry = l$ids[i];
      final lOther$ids$entry = lOther$ids[i];
      if (l$ids$entry != lOther$ids$entry) {
        return false;
      }
    }
    final l$patch = patch;
    final lOther$patch = other.patch;
    if (l$patch != lOther$patch) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$clientMutationId = clientMutationId;
    final l$ids = ids;
    final l$patch = patch;
    return Object.hashAll([
      _$data.containsKey('clientMutationId') ? l$clientMutationId : const {},
      Object.hashAll(l$ids.map((v) => v)),
      l$patch,
    ]);
  }
}

abstract class CopyWith$Input$UpdateMangasInput<TRes> {
  factory CopyWith$Input$UpdateMangasInput(
    Input$UpdateMangasInput instance,
    TRes Function(Input$UpdateMangasInput) then,
  ) = _CopyWithImpl$Input$UpdateMangasInput;

  factory CopyWith$Input$UpdateMangasInput.stub(TRes res) =
      _CopyWithStubImpl$Input$UpdateMangasInput;

  TRes call({
    String? clientMutationId,
    List<int>? ids,
    Input$UpdateMangaPatchInput? patch,
  });
  CopyWith$Input$UpdateMangaPatchInput<TRes> get patch;
}

class _CopyWithImpl$Input$UpdateMangasInput<TRes>
    implements CopyWith$Input$UpdateMangasInput<TRes> {
  _CopyWithImpl$Input$UpdateMangasInput(
    this._instance,
    this._then,
  );

  final Input$UpdateMangasInput _instance;

  final TRes Function(Input$UpdateMangasInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? clientMutationId = _undefined,
    Object? ids = _undefined,
    Object? patch = _undefined,
  }) =>
      _then(Input$UpdateMangasInput._({
        ..._instance._$data,
        if (clientMutationId != _undefined)
          'clientMutationId': (clientMutationId as String?),
        if (ids != _undefined && ids != null) 'ids': (ids as List<int>),
        if (patch != _undefined && patch != null)
          'patch': (patch as Input$UpdateMangaPatchInput),
      }));

  CopyWith$Input$UpdateMangaPatchInput<TRes> get patch {
    final local$patch = _instance.patch;
    return CopyWith$Input$UpdateMangaPatchInput(
        local$patch, (e) => call(patch: e));
  }
}

class _CopyWithStubImpl$Input$UpdateMangasInput<TRes>
    implements CopyWith$Input$UpdateMangasInput<TRes> {
  _CopyWithStubImpl$Input$UpdateMangasInput(this._res);

  TRes _res;

  call({
    String? clientMutationId,
    List<int>? ids,
    Input$UpdateMangaPatchInput? patch,
  }) =>
      _res;

  CopyWith$Input$UpdateMangaPatchInput<TRes> get patch =>
      CopyWith$Input$UpdateMangaPatchInput.stub(_res);
}

class Input$UpdateSourcePreferenceInput {
  factory Input$UpdateSourcePreferenceInput({
    required Input$SourcePreferenceChangeInput change,
    String? clientMutationId,
    required String source,
  }) =>
      Input$UpdateSourcePreferenceInput._({
        r'change': change,
        if (clientMutationId != null) r'clientMutationId': clientMutationId,
        r'source': source,
      });

  Input$UpdateSourcePreferenceInput._(this._$data);

  factory Input$UpdateSourcePreferenceInput.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$change = data['change'];
    result$data['change'] = Input$SourcePreferenceChangeInput.fromJson(
        (l$change as Map<String, dynamic>));
    if (data.containsKey('clientMutationId')) {
      final l$clientMutationId = data['clientMutationId'];
      result$data['clientMutationId'] = (l$clientMutationId as String?);
    }
    final l$source = data['source'];
    result$data['source'] = longStringFromJson(l$source);
    return Input$UpdateSourcePreferenceInput._(result$data);
  }

  Map<String, dynamic> _$data;

  Input$SourcePreferenceChangeInput get change =>
      (_$data['change'] as Input$SourcePreferenceChangeInput);

  String? get clientMutationId => (_$data['clientMutationId'] as String?);

  String get source => (_$data['source'] as String);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$change = change;
    result$data['change'] = l$change.toJson();
    if (_$data.containsKey('clientMutationId')) {
      final l$clientMutationId = clientMutationId;
      result$data['clientMutationId'] = l$clientMutationId;
    }
    final l$source = source;
    result$data['source'] = longStringToJson(l$source);
    return result$data;
  }

  CopyWith$Input$UpdateSourcePreferenceInput<Input$UpdateSourcePreferenceInput>
      get copyWith => CopyWith$Input$UpdateSourcePreferenceInput(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$UpdateSourcePreferenceInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$change = change;
    final lOther$change = other.change;
    if (l$change != lOther$change) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (_$data.containsKey('clientMutationId') !=
        other._$data.containsKey('clientMutationId')) {
      return false;
    }
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    final l$source = source;
    final lOther$source = other.source;
    if (l$source != lOther$source) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$change = change;
    final l$clientMutationId = clientMutationId;
    final l$source = source;
    return Object.hashAll([
      l$change,
      _$data.containsKey('clientMutationId') ? l$clientMutationId : const {},
      l$source,
    ]);
  }
}

abstract class CopyWith$Input$UpdateSourcePreferenceInput<TRes> {
  factory CopyWith$Input$UpdateSourcePreferenceInput(
    Input$UpdateSourcePreferenceInput instance,
    TRes Function(Input$UpdateSourcePreferenceInput) then,
  ) = _CopyWithImpl$Input$UpdateSourcePreferenceInput;

  factory CopyWith$Input$UpdateSourcePreferenceInput.stub(TRes res) =
      _CopyWithStubImpl$Input$UpdateSourcePreferenceInput;

  TRes call({
    Input$SourcePreferenceChangeInput? change,
    String? clientMutationId,
    String? source,
  });
  CopyWith$Input$SourcePreferenceChangeInput<TRes> get change;
}

class _CopyWithImpl$Input$UpdateSourcePreferenceInput<TRes>
    implements CopyWith$Input$UpdateSourcePreferenceInput<TRes> {
  _CopyWithImpl$Input$UpdateSourcePreferenceInput(
    this._instance,
    this._then,
  );

  final Input$UpdateSourcePreferenceInput _instance;

  final TRes Function(Input$UpdateSourcePreferenceInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? change = _undefined,
    Object? clientMutationId = _undefined,
    Object? source = _undefined,
  }) =>
      _then(Input$UpdateSourcePreferenceInput._({
        ..._instance._$data,
        if (change != _undefined && change != null)
          'change': (change as Input$SourcePreferenceChangeInput),
        if (clientMutationId != _undefined)
          'clientMutationId': (clientMutationId as String?),
        if (source != _undefined && source != null)
          'source': (source as String),
      }));

  CopyWith$Input$SourcePreferenceChangeInput<TRes> get change {
    final local$change = _instance.change;
    return CopyWith$Input$SourcePreferenceChangeInput(
        local$change, (e) => call(change: e));
  }
}

class _CopyWithStubImpl$Input$UpdateSourcePreferenceInput<TRes>
    implements CopyWith$Input$UpdateSourcePreferenceInput<TRes> {
  _CopyWithStubImpl$Input$UpdateSourcePreferenceInput(this._res);

  TRes _res;

  call({
    Input$SourcePreferenceChangeInput? change,
    String? clientMutationId,
    String? source,
  }) =>
      _res;

  CopyWith$Input$SourcePreferenceChangeInput<TRes> get change =>
      CopyWith$Input$SourcePreferenceChangeInput.stub(_res);
}

class Input$UpdateStopInput {
  factory Input$UpdateStopInput({String? clientMutationId}) =>
      Input$UpdateStopInput._({
        if (clientMutationId != null) r'clientMutationId': clientMutationId,
      });

  Input$UpdateStopInput._(this._$data);

  factory Input$UpdateStopInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('clientMutationId')) {
      final l$clientMutationId = data['clientMutationId'];
      result$data['clientMutationId'] = (l$clientMutationId as String?);
    }
    return Input$UpdateStopInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get clientMutationId => (_$data['clientMutationId'] as String?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('clientMutationId')) {
      final l$clientMutationId = clientMutationId;
      result$data['clientMutationId'] = l$clientMutationId;
    }
    return result$data;
  }

  CopyWith$Input$UpdateStopInput<Input$UpdateStopInput> get copyWith =>
      CopyWith$Input$UpdateStopInput(
        this,
        (i) => i,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$UpdateStopInput || runtimeType != other.runtimeType) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (_$data.containsKey('clientMutationId') !=
        other._$data.containsKey('clientMutationId')) {
      return false;
    }
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$clientMutationId = clientMutationId;
    return Object.hashAll([
      _$data.containsKey('clientMutationId') ? l$clientMutationId : const {}
    ]);
  }
}

abstract class CopyWith$Input$UpdateStopInput<TRes> {
  factory CopyWith$Input$UpdateStopInput(
    Input$UpdateStopInput instance,
    TRes Function(Input$UpdateStopInput) then,
  ) = _CopyWithImpl$Input$UpdateStopInput;

  factory CopyWith$Input$UpdateStopInput.stub(TRes res) =
      _CopyWithStubImpl$Input$UpdateStopInput;

  TRes call({String? clientMutationId});
}

class _CopyWithImpl$Input$UpdateStopInput<TRes>
    implements CopyWith$Input$UpdateStopInput<TRes> {
  _CopyWithImpl$Input$UpdateStopInput(
    this._instance,
    this._then,
  );

  final Input$UpdateStopInput _instance;

  final TRes Function(Input$UpdateStopInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? clientMutationId = _undefined}) =>
      _then(Input$UpdateStopInput._({
        ..._instance._$data,
        if (clientMutationId != _undefined)
          'clientMutationId': (clientMutationId as String?),
      }));
}

class _CopyWithStubImpl$Input$UpdateStopInput<TRes>
    implements CopyWith$Input$UpdateStopInput<TRes> {
  _CopyWithStubImpl$Input$UpdateStopInput(this._res);

  TRes _res;

  call({String? clientMutationId}) => _res;
}

class Input$UpdateTrackInput {
  factory Input$UpdateTrackInput({
    String? clientMutationId,
    String? finishDate,
    double? lastChapterRead,
    required int recordId,
    String? scoreString,
    String? startDate,
    int? status,
  }) =>
      Input$UpdateTrackInput._({
        if (clientMutationId != null) r'clientMutationId': clientMutationId,
        if (finishDate != null) r'finishDate': finishDate,
        if (lastChapterRead != null) r'lastChapterRead': lastChapterRead,
        r'recordId': recordId,
        if (scoreString != null) r'scoreString': scoreString,
        if (startDate != null) r'startDate': startDate,
        if (status != null) r'status': status,
      });

  Input$UpdateTrackInput._(this._$data);

  factory Input$UpdateTrackInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('clientMutationId')) {
      final l$clientMutationId = data['clientMutationId'];
      result$data['clientMutationId'] = (l$clientMutationId as String?);
    }
    if (data.containsKey('finishDate')) {
      final l$finishDate = data['finishDate'];
      result$data['finishDate'] =
          l$finishDate == null ? null : longStringFromJson(l$finishDate);
    }
    if (data.containsKey('lastChapterRead')) {
      final l$lastChapterRead = data['lastChapterRead'];
      result$data['lastChapterRead'] = (l$lastChapterRead as num?)?.toDouble();
    }
    final l$recordId = data['recordId'];
    result$data['recordId'] = (l$recordId as int);
    if (data.containsKey('scoreString')) {
      final l$scoreString = data['scoreString'];
      result$data['scoreString'] = (l$scoreString as String?);
    }
    if (data.containsKey('startDate')) {
      final l$startDate = data['startDate'];
      result$data['startDate'] =
          l$startDate == null ? null : longStringFromJson(l$startDate);
    }
    if (data.containsKey('status')) {
      final l$status = data['status'];
      result$data['status'] = (l$status as int?);
    }
    return Input$UpdateTrackInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get clientMutationId => (_$data['clientMutationId'] as String?);

  String? get finishDate => (_$data['finishDate'] as String?);

  double? get lastChapterRead => (_$data['lastChapterRead'] as double?);

  int get recordId => (_$data['recordId'] as int);

  String? get scoreString => (_$data['scoreString'] as String?);

  String? get startDate => (_$data['startDate'] as String?);

  int? get status => (_$data['status'] as int?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('clientMutationId')) {
      final l$clientMutationId = clientMutationId;
      result$data['clientMutationId'] = l$clientMutationId;
    }
    if (_$data.containsKey('finishDate')) {
      final l$finishDate = finishDate;
      result$data['finishDate'] =
          l$finishDate == null ? null : longStringToJson(l$finishDate);
    }
    if (_$data.containsKey('lastChapterRead')) {
      final l$lastChapterRead = lastChapterRead;
      result$data['lastChapterRead'] = l$lastChapterRead;
    }
    final l$recordId = recordId;
    result$data['recordId'] = l$recordId;
    if (_$data.containsKey('scoreString')) {
      final l$scoreString = scoreString;
      result$data['scoreString'] = l$scoreString;
    }
    if (_$data.containsKey('startDate')) {
      final l$startDate = startDate;
      result$data['startDate'] =
          l$startDate == null ? null : longStringToJson(l$startDate);
    }
    if (_$data.containsKey('status')) {
      final l$status = status;
      result$data['status'] = l$status;
    }
    return result$data;
  }

  CopyWith$Input$UpdateTrackInput<Input$UpdateTrackInput> get copyWith =>
      CopyWith$Input$UpdateTrackInput(
        this,
        (i) => i,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$UpdateTrackInput || runtimeType != other.runtimeType) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (_$data.containsKey('clientMutationId') !=
        other._$data.containsKey('clientMutationId')) {
      return false;
    }
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    final l$finishDate = finishDate;
    final lOther$finishDate = other.finishDate;
    if (_$data.containsKey('finishDate') !=
        other._$data.containsKey('finishDate')) {
      return false;
    }
    if (l$finishDate != lOther$finishDate) {
      return false;
    }
    final l$lastChapterRead = lastChapterRead;
    final lOther$lastChapterRead = other.lastChapterRead;
    if (_$data.containsKey('lastChapterRead') !=
        other._$data.containsKey('lastChapterRead')) {
      return false;
    }
    if (l$lastChapterRead != lOther$lastChapterRead) {
      return false;
    }
    final l$recordId = recordId;
    final lOther$recordId = other.recordId;
    if (l$recordId != lOther$recordId) {
      return false;
    }
    final l$scoreString = scoreString;
    final lOther$scoreString = other.scoreString;
    if (_$data.containsKey('scoreString') !=
        other._$data.containsKey('scoreString')) {
      return false;
    }
    if (l$scoreString != lOther$scoreString) {
      return false;
    }
    final l$startDate = startDate;
    final lOther$startDate = other.startDate;
    if (_$data.containsKey('startDate') !=
        other._$data.containsKey('startDate')) {
      return false;
    }
    if (l$startDate != lOther$startDate) {
      return false;
    }
    final l$status = status;
    final lOther$status = other.status;
    if (_$data.containsKey('status') != other._$data.containsKey('status')) {
      return false;
    }
    if (l$status != lOther$status) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$clientMutationId = clientMutationId;
    final l$finishDate = finishDate;
    final l$lastChapterRead = lastChapterRead;
    final l$recordId = recordId;
    final l$scoreString = scoreString;
    final l$startDate = startDate;
    final l$status = status;
    return Object.hashAll([
      _$data.containsKey('clientMutationId') ? l$clientMutationId : const {},
      _$data.containsKey('finishDate') ? l$finishDate : const {},
      _$data.containsKey('lastChapterRead') ? l$lastChapterRead : const {},
      l$recordId,
      _$data.containsKey('scoreString') ? l$scoreString : const {},
      _$data.containsKey('startDate') ? l$startDate : const {},
      _$data.containsKey('status') ? l$status : const {},
    ]);
  }
}

abstract class CopyWith$Input$UpdateTrackInput<TRes> {
  factory CopyWith$Input$UpdateTrackInput(
    Input$UpdateTrackInput instance,
    TRes Function(Input$UpdateTrackInput) then,
  ) = _CopyWithImpl$Input$UpdateTrackInput;

  factory CopyWith$Input$UpdateTrackInput.stub(TRes res) =
      _CopyWithStubImpl$Input$UpdateTrackInput;

  TRes call({
    String? clientMutationId,
    String? finishDate,
    double? lastChapterRead,
    int? recordId,
    String? scoreString,
    String? startDate,
    int? status,
  });
}

class _CopyWithImpl$Input$UpdateTrackInput<TRes>
    implements CopyWith$Input$UpdateTrackInput<TRes> {
  _CopyWithImpl$Input$UpdateTrackInput(
    this._instance,
    this._then,
  );

  final Input$UpdateTrackInput _instance;

  final TRes Function(Input$UpdateTrackInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? clientMutationId = _undefined,
    Object? finishDate = _undefined,
    Object? lastChapterRead = _undefined,
    Object? recordId = _undefined,
    Object? scoreString = _undefined,
    Object? startDate = _undefined,
    Object? status = _undefined,
  }) =>
      _then(Input$UpdateTrackInput._({
        ..._instance._$data,
        if (clientMutationId != _undefined)
          'clientMutationId': (clientMutationId as String?),
        if (finishDate != _undefined) 'finishDate': (finishDate as String?),
        if (lastChapterRead != _undefined)
          'lastChapterRead': (lastChapterRead as double?),
        if (recordId != _undefined && recordId != null)
          'recordId': (recordId as int),
        if (scoreString != _undefined) 'scoreString': (scoreString as String?),
        if (startDate != _undefined) 'startDate': (startDate as String?),
        if (status != _undefined) 'status': (status as int?),
      }));
}

class _CopyWithStubImpl$Input$UpdateTrackInput<TRes>
    implements CopyWith$Input$UpdateTrackInput<TRes> {
  _CopyWithStubImpl$Input$UpdateTrackInput(this._res);

  TRes _res;

  call({
    String? clientMutationId,
    String? finishDate,
    double? lastChapterRead,
    int? recordId,
    String? scoreString,
    String? startDate,
    int? status,
  }) =>
      _res;
}

class Input$ValidateBackupInput {
  factory Input$ValidateBackupInput({required MultipartFile backup}) =>
      Input$ValidateBackupInput._({
        r'backup': backup,
      });

  Input$ValidateBackupInput._(this._$data);

  factory Input$ValidateBackupInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$backup = data['backup'];
    result$data['backup'] = fileFromJson(l$backup);
    return Input$ValidateBackupInput._(result$data);
  }

  Map<String, dynamic> _$data;

  MultipartFile get backup => (_$data['backup'] as MultipartFile);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$backup = backup;
    result$data['backup'] = fileToJson(l$backup);
    return result$data;
  }

  CopyWith$Input$ValidateBackupInput<Input$ValidateBackupInput> get copyWith =>
      CopyWith$Input$ValidateBackupInput(
        this,
        (i) => i,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$ValidateBackupInput ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$backup = backup;
    final lOther$backup = other.backup;
    if (l$backup != lOther$backup) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$backup = backup;
    return Object.hashAll([l$backup]);
  }
}

abstract class CopyWith$Input$ValidateBackupInput<TRes> {
  factory CopyWith$Input$ValidateBackupInput(
    Input$ValidateBackupInput instance,
    TRes Function(Input$ValidateBackupInput) then,
  ) = _CopyWithImpl$Input$ValidateBackupInput;

  factory CopyWith$Input$ValidateBackupInput.stub(TRes res) =
      _CopyWithStubImpl$Input$ValidateBackupInput;

  TRes call({MultipartFile? backup});
}

class _CopyWithImpl$Input$ValidateBackupInput<TRes>
    implements CopyWith$Input$ValidateBackupInput<TRes> {
  _CopyWithImpl$Input$ValidateBackupInput(
    this._instance,
    this._then,
  );

  final Input$ValidateBackupInput _instance;

  final TRes Function(Input$ValidateBackupInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? backup = _undefined}) =>
      _then(Input$ValidateBackupInput._({
        ..._instance._$data,
        if (backup != _undefined && backup != null)
          'backup': (backup as MultipartFile),
      }));
}

class _CopyWithStubImpl$Input$ValidateBackupInput<TRes>
    implements CopyWith$Input$ValidateBackupInput<TRes> {
  _CopyWithStubImpl$Input$ValidateBackupInput(this._res);

  TRes _res;

  call({MultipartFile? backup}) => _res;
}

class Input$WebUIUpdateInput {
  factory Input$WebUIUpdateInput({String? clientMutationId}) =>
      Input$WebUIUpdateInput._({
        if (clientMutationId != null) r'clientMutationId': clientMutationId,
      });

  Input$WebUIUpdateInput._(this._$data);

  factory Input$WebUIUpdateInput.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('clientMutationId')) {
      final l$clientMutationId = data['clientMutationId'];
      result$data['clientMutationId'] = (l$clientMutationId as String?);
    }
    return Input$WebUIUpdateInput._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get clientMutationId => (_$data['clientMutationId'] as String?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('clientMutationId')) {
      final l$clientMutationId = clientMutationId;
      result$data['clientMutationId'] = l$clientMutationId;
    }
    return result$data;
  }

  CopyWith$Input$WebUIUpdateInput<Input$WebUIUpdateInput> get copyWith =>
      CopyWith$Input$WebUIUpdateInput(
        this,
        (i) => i,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$WebUIUpdateInput || runtimeType != other.runtimeType) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (_$data.containsKey('clientMutationId') !=
        other._$data.containsKey('clientMutationId')) {
      return false;
    }
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$clientMutationId = clientMutationId;
    return Object.hashAll([
      _$data.containsKey('clientMutationId') ? l$clientMutationId : const {}
    ]);
  }
}

abstract class CopyWith$Input$WebUIUpdateInput<TRes> {
  factory CopyWith$Input$WebUIUpdateInput(
    Input$WebUIUpdateInput instance,
    TRes Function(Input$WebUIUpdateInput) then,
  ) = _CopyWithImpl$Input$WebUIUpdateInput;

  factory CopyWith$Input$WebUIUpdateInput.stub(TRes res) =
      _CopyWithStubImpl$Input$WebUIUpdateInput;

  TRes call({String? clientMutationId});
}

class _CopyWithImpl$Input$WebUIUpdateInput<TRes>
    implements CopyWith$Input$WebUIUpdateInput<TRes> {
  _CopyWithImpl$Input$WebUIUpdateInput(
    this._instance,
    this._then,
  );

  final Input$WebUIUpdateInput _instance;

  final TRes Function(Input$WebUIUpdateInput) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? clientMutationId = _undefined}) =>
      _then(Input$WebUIUpdateInput._({
        ..._instance._$data,
        if (clientMutationId != _undefined)
          'clientMutationId': (clientMutationId as String?),
      }));
}

class _CopyWithStubImpl$Input$WebUIUpdateInput<TRes>
    implements CopyWith$Input$WebUIUpdateInput<TRes> {
  _CopyWithStubImpl$Input$WebUIUpdateInput(this._res);

  TRes _res;

  call({String? clientMutationId}) => _res;
}

enum Enum$BackupRestoreState {
  IDLE,
  SUCCESS,
  FAILURE,
  RESTORING_CATEGORIES,
  RESTORING_MANGA,
  $unknown;

  factory Enum$BackupRestoreState.fromJson(String value) =>
      fromJson$Enum$BackupRestoreState(value);

  String toJson() => toJson$Enum$BackupRestoreState(this);
}

String toJson$Enum$BackupRestoreState(Enum$BackupRestoreState e) {
  switch (e) {
    case Enum$BackupRestoreState.IDLE:
      return r'IDLE';
    case Enum$BackupRestoreState.SUCCESS:
      return r'SUCCESS';
    case Enum$BackupRestoreState.FAILURE:
      return r'FAILURE';
    case Enum$BackupRestoreState.RESTORING_CATEGORIES:
      return r'RESTORING_CATEGORIES';
    case Enum$BackupRestoreState.RESTORING_MANGA:
      return r'RESTORING_MANGA';
    case Enum$BackupRestoreState.$unknown:
      return r'$unknown';
  }
}

Enum$BackupRestoreState fromJson$Enum$BackupRestoreState(String value) {
  switch (value) {
    case r'IDLE':
      return Enum$BackupRestoreState.IDLE;
    case r'SUCCESS':
      return Enum$BackupRestoreState.SUCCESS;
    case r'FAILURE':
      return Enum$BackupRestoreState.FAILURE;
    case r'RESTORING_CATEGORIES':
      return Enum$BackupRestoreState.RESTORING_CATEGORIES;
    case r'RESTORING_MANGA':
      return Enum$BackupRestoreState.RESTORING_MANGA;
    default:
      return Enum$BackupRestoreState.$unknown;
  }
}

enum Enum$CategoryOrderBy {
  ID,
  NAME,
  ORDER,
  $unknown;

  factory Enum$CategoryOrderBy.fromJson(String value) =>
      fromJson$Enum$CategoryOrderBy(value);

  String toJson() => toJson$Enum$CategoryOrderBy(this);
}

String toJson$Enum$CategoryOrderBy(Enum$CategoryOrderBy e) {
  switch (e) {
    case Enum$CategoryOrderBy.ID:
      return r'ID';
    case Enum$CategoryOrderBy.NAME:
      return r'NAME';
    case Enum$CategoryOrderBy.ORDER:
      return r'ORDER';
    case Enum$CategoryOrderBy.$unknown:
      return r'$unknown';
  }
}

Enum$CategoryOrderBy fromJson$Enum$CategoryOrderBy(String value) {
  switch (value) {
    case r'ID':
      return Enum$CategoryOrderBy.ID;
    case r'NAME':
      return Enum$CategoryOrderBy.NAME;
    case r'ORDER':
      return Enum$CategoryOrderBy.ORDER;
    default:
      return Enum$CategoryOrderBy.$unknown;
  }
}

enum Enum$ChapterOrderBy {
  ID,
  SOURCE_ORDER,
  NAME,
  UPLOAD_DATE,
  CHAPTER_NUMBER,
  LAST_READ_AT,
  FETCHED_AT,
  $unknown;

  factory Enum$ChapterOrderBy.fromJson(String value) =>
      fromJson$Enum$ChapterOrderBy(value);

  String toJson() => toJson$Enum$ChapterOrderBy(this);
}

String toJson$Enum$ChapterOrderBy(Enum$ChapterOrderBy e) {
  switch (e) {
    case Enum$ChapterOrderBy.ID:
      return r'ID';
    case Enum$ChapterOrderBy.SOURCE_ORDER:
      return r'SOURCE_ORDER';
    case Enum$ChapterOrderBy.NAME:
      return r'NAME';
    case Enum$ChapterOrderBy.UPLOAD_DATE:
      return r'UPLOAD_DATE';
    case Enum$ChapterOrderBy.CHAPTER_NUMBER:
      return r'CHAPTER_NUMBER';
    case Enum$ChapterOrderBy.LAST_READ_AT:
      return r'LAST_READ_AT';
    case Enum$ChapterOrderBy.FETCHED_AT:
      return r'FETCHED_AT';
    case Enum$ChapterOrderBy.$unknown:
      return r'$unknown';
  }
}

Enum$ChapterOrderBy fromJson$Enum$ChapterOrderBy(String value) {
  switch (value) {
    case r'ID':
      return Enum$ChapterOrderBy.ID;
    case r'SOURCE_ORDER':
      return Enum$ChapterOrderBy.SOURCE_ORDER;
    case r'NAME':
      return Enum$ChapterOrderBy.NAME;
    case r'UPLOAD_DATE':
      return Enum$ChapterOrderBy.UPLOAD_DATE;
    case r'CHAPTER_NUMBER':
      return Enum$ChapterOrderBy.CHAPTER_NUMBER;
    case r'LAST_READ_AT':
      return Enum$ChapterOrderBy.LAST_READ_AT;
    case r'FETCHED_AT':
      return Enum$ChapterOrderBy.FETCHED_AT;
    default:
      return Enum$ChapterOrderBy.$unknown;
  }
}

enum Enum$DownloaderState {
  STARTED,
  STOPPED,
  $unknown;

  factory Enum$DownloaderState.fromJson(String value) =>
      fromJson$Enum$DownloaderState(value);

  String toJson() => toJson$Enum$DownloaderState(this);
}

String toJson$Enum$DownloaderState(Enum$DownloaderState e) {
  switch (e) {
    case Enum$DownloaderState.STARTED:
      return r'STARTED';
    case Enum$DownloaderState.STOPPED:
      return r'STOPPED';
    case Enum$DownloaderState.$unknown:
      return r'$unknown';
  }
}

Enum$DownloaderState fromJson$Enum$DownloaderState(String value) {
  switch (value) {
    case r'STARTED':
      return Enum$DownloaderState.STARTED;
    case r'STOPPED':
      return Enum$DownloaderState.STOPPED;
    default:
      return Enum$DownloaderState.$unknown;
  }
}

enum Enum$DownloadState {
  QUEUED,
  DOWNLOADING,
  FINISHED,
  ERROR,
  $unknown;

  factory Enum$DownloadState.fromJson(String value) =>
      fromJson$Enum$DownloadState(value);

  String toJson() => toJson$Enum$DownloadState(this);
}

String toJson$Enum$DownloadState(Enum$DownloadState e) {
  switch (e) {
    case Enum$DownloadState.QUEUED:
      return r'QUEUED';
    case Enum$DownloadState.DOWNLOADING:
      return r'DOWNLOADING';
    case Enum$DownloadState.FINISHED:
      return r'FINISHED';
    case Enum$DownloadState.ERROR:
      return r'ERROR';
    case Enum$DownloadState.$unknown:
      return r'$unknown';
  }
}

Enum$DownloadState fromJson$Enum$DownloadState(String value) {
  switch (value) {
    case r'QUEUED':
      return Enum$DownloadState.QUEUED;
    case r'DOWNLOADING':
      return Enum$DownloadState.DOWNLOADING;
    case r'FINISHED':
      return Enum$DownloadState.FINISHED;
    case r'ERROR':
      return Enum$DownloadState.ERROR;
    default:
      return Enum$DownloadState.$unknown;
  }
}

enum Enum$DownloadUpdateType {
  QUEUED,
  DEQUEUED,
  PAUSED,
  STOPPED,
  PROGRESS,
  FINISHED,
  ERROR,
  POSITION,
  $unknown;

  factory Enum$DownloadUpdateType.fromJson(String value) =>
      fromJson$Enum$DownloadUpdateType(value);

  String toJson() => toJson$Enum$DownloadUpdateType(this);
}

String toJson$Enum$DownloadUpdateType(Enum$DownloadUpdateType e) {
  switch (e) {
    case Enum$DownloadUpdateType.QUEUED:
      return r'QUEUED';
    case Enum$DownloadUpdateType.DEQUEUED:
      return r'DEQUEUED';
    case Enum$DownloadUpdateType.PAUSED:
      return r'PAUSED';
    case Enum$DownloadUpdateType.STOPPED:
      return r'STOPPED';
    case Enum$DownloadUpdateType.PROGRESS:
      return r'PROGRESS';
    case Enum$DownloadUpdateType.FINISHED:
      return r'FINISHED';
    case Enum$DownloadUpdateType.ERROR:
      return r'ERROR';
    case Enum$DownloadUpdateType.POSITION:
      return r'POSITION';
    case Enum$DownloadUpdateType.$unknown:
      return r'$unknown';
  }
}

Enum$DownloadUpdateType fromJson$Enum$DownloadUpdateType(String value) {
  switch (value) {
    case r'QUEUED':
      return Enum$DownloadUpdateType.QUEUED;
    case r'DEQUEUED':
      return Enum$DownloadUpdateType.DEQUEUED;
    case r'PAUSED':
      return Enum$DownloadUpdateType.PAUSED;
    case r'STOPPED':
      return Enum$DownloadUpdateType.STOPPED;
    case r'PROGRESS':
      return Enum$DownloadUpdateType.PROGRESS;
    case r'FINISHED':
      return Enum$DownloadUpdateType.FINISHED;
    case r'ERROR':
      return Enum$DownloadUpdateType.ERROR;
    case r'POSITION':
      return Enum$DownloadUpdateType.POSITION;
    default:
      return Enum$DownloadUpdateType.$unknown;
  }
}

enum Enum$ExtensionOrderBy {
  PKG_NAME,
  NAME,
  APK_NAME,
  $unknown;

  factory Enum$ExtensionOrderBy.fromJson(String value) =>
      fromJson$Enum$ExtensionOrderBy(value);

  String toJson() => toJson$Enum$ExtensionOrderBy(this);
}

String toJson$Enum$ExtensionOrderBy(Enum$ExtensionOrderBy e) {
  switch (e) {
    case Enum$ExtensionOrderBy.PKG_NAME:
      return r'PKG_NAME';
    case Enum$ExtensionOrderBy.NAME:
      return r'NAME';
    case Enum$ExtensionOrderBy.APK_NAME:
      return r'APK_NAME';
    case Enum$ExtensionOrderBy.$unknown:
      return r'$unknown';
  }
}

Enum$ExtensionOrderBy fromJson$Enum$ExtensionOrderBy(String value) {
  switch (value) {
    case r'PKG_NAME':
      return Enum$ExtensionOrderBy.PKG_NAME;
    case r'NAME':
      return Enum$ExtensionOrderBy.NAME;
    case r'APK_NAME':
      return Enum$ExtensionOrderBy.APK_NAME;
    default:
      return Enum$ExtensionOrderBy.$unknown;
  }
}

enum Enum$FetchSourceMangaType {
  SEARCH,
  POPULAR,
  LATEST,
  $unknown;

  factory Enum$FetchSourceMangaType.fromJson(String value) =>
      fromJson$Enum$FetchSourceMangaType(value);

  String toJson() => toJson$Enum$FetchSourceMangaType(this);
}

String toJson$Enum$FetchSourceMangaType(Enum$FetchSourceMangaType e) {
  switch (e) {
    case Enum$FetchSourceMangaType.SEARCH:
      return r'SEARCH';
    case Enum$FetchSourceMangaType.POPULAR:
      return r'POPULAR';
    case Enum$FetchSourceMangaType.LATEST:
      return r'LATEST';
    case Enum$FetchSourceMangaType.$unknown:
      return r'$unknown';
  }
}

Enum$FetchSourceMangaType fromJson$Enum$FetchSourceMangaType(String value) {
  switch (value) {
    case r'SEARCH':
      return Enum$FetchSourceMangaType.SEARCH;
    case r'POPULAR':
      return Enum$FetchSourceMangaType.POPULAR;
    case r'LATEST':
      return Enum$FetchSourceMangaType.LATEST;
    default:
      return Enum$FetchSourceMangaType.$unknown;
  }
}

enum Enum$IncludeOrExclude {
  EXCLUDE,
  INCLUDE,
  UNSET,
  $unknown;

  factory Enum$IncludeOrExclude.fromJson(String value) =>
      fromJson$Enum$IncludeOrExclude(value);

  String toJson() => toJson$Enum$IncludeOrExclude(this);
}

String toJson$Enum$IncludeOrExclude(Enum$IncludeOrExclude e) {
  switch (e) {
    case Enum$IncludeOrExclude.EXCLUDE:
      return r'EXCLUDE';
    case Enum$IncludeOrExclude.INCLUDE:
      return r'INCLUDE';
    case Enum$IncludeOrExclude.UNSET:
      return r'UNSET';
    case Enum$IncludeOrExclude.$unknown:
      return r'$unknown';
  }
}

Enum$IncludeOrExclude fromJson$Enum$IncludeOrExclude(String value) {
  switch (value) {
    case r'EXCLUDE':
      return Enum$IncludeOrExclude.EXCLUDE;
    case r'INCLUDE':
      return Enum$IncludeOrExclude.INCLUDE;
    case r'UNSET':
      return Enum$IncludeOrExclude.UNSET;
    default:
      return Enum$IncludeOrExclude.$unknown;
  }
}

enum Enum$MangaOrderBy {
  ID,
  TITLE,
  IN_LIBRARY_AT,
  LAST_FETCHED_AT,
  $unknown;

  factory Enum$MangaOrderBy.fromJson(String value) =>
      fromJson$Enum$MangaOrderBy(value);

  String toJson() => toJson$Enum$MangaOrderBy(this);
}

String toJson$Enum$MangaOrderBy(Enum$MangaOrderBy e) {
  switch (e) {
    case Enum$MangaOrderBy.ID:
      return r'ID';
    case Enum$MangaOrderBy.TITLE:
      return r'TITLE';
    case Enum$MangaOrderBy.IN_LIBRARY_AT:
      return r'IN_LIBRARY_AT';
    case Enum$MangaOrderBy.LAST_FETCHED_AT:
      return r'LAST_FETCHED_AT';
    case Enum$MangaOrderBy.$unknown:
      return r'$unknown';
  }
}

Enum$MangaOrderBy fromJson$Enum$MangaOrderBy(String value) {
  switch (value) {
    case r'ID':
      return Enum$MangaOrderBy.ID;
    case r'TITLE':
      return Enum$MangaOrderBy.TITLE;
    case r'IN_LIBRARY_AT':
      return Enum$MangaOrderBy.IN_LIBRARY_AT;
    case r'LAST_FETCHED_AT':
      return Enum$MangaOrderBy.LAST_FETCHED_AT;
    default:
      return Enum$MangaOrderBy.$unknown;
  }
}

enum Enum$MangaStatus {
  UNKNOWN,
  ONGOING,
  COMPLETED,
  LICENSED,
  PUBLISHING_FINISHED,
  CANCELLED,
  ON_HIATUS,
  $unknown;

  factory Enum$MangaStatus.fromJson(String value) =>
      fromJson$Enum$MangaStatus(value);

  String toJson() => toJson$Enum$MangaStatus(this);
}

String toJson$Enum$MangaStatus(Enum$MangaStatus e) {
  switch (e) {
    case Enum$MangaStatus.UNKNOWN:
      return r'UNKNOWN';
    case Enum$MangaStatus.ONGOING:
      return r'ONGOING';
    case Enum$MangaStatus.COMPLETED:
      return r'COMPLETED';
    case Enum$MangaStatus.LICENSED:
      return r'LICENSED';
    case Enum$MangaStatus.PUBLISHING_FINISHED:
      return r'PUBLISHING_FINISHED';
    case Enum$MangaStatus.CANCELLED:
      return r'CANCELLED';
    case Enum$MangaStatus.ON_HIATUS:
      return r'ON_HIATUS';
    case Enum$MangaStatus.$unknown:
      return r'$unknown';
  }
}

Enum$MangaStatus fromJson$Enum$MangaStatus(String value) {
  switch (value) {
    case r'UNKNOWN':
      return Enum$MangaStatus.UNKNOWN;
    case r'ONGOING':
      return Enum$MangaStatus.ONGOING;
    case r'COMPLETED':
      return Enum$MangaStatus.COMPLETED;
    case r'LICENSED':
      return Enum$MangaStatus.LICENSED;
    case r'PUBLISHING_FINISHED':
      return Enum$MangaStatus.PUBLISHING_FINISHED;
    case r'CANCELLED':
      return Enum$MangaStatus.CANCELLED;
    case r'ON_HIATUS':
      return Enum$MangaStatus.ON_HIATUS;
    default:
      return Enum$MangaStatus.$unknown;
  }
}

enum Enum$MetaOrderBy {
  KEY,
  VALUE,
  $unknown;

  factory Enum$MetaOrderBy.fromJson(String value) =>
      fromJson$Enum$MetaOrderBy(value);

  String toJson() => toJson$Enum$MetaOrderBy(this);
}

String toJson$Enum$MetaOrderBy(Enum$MetaOrderBy e) {
  switch (e) {
    case Enum$MetaOrderBy.KEY:
      return r'KEY';
    case Enum$MetaOrderBy.VALUE:
      return r'VALUE';
    case Enum$MetaOrderBy.$unknown:
      return r'$unknown';
  }
}

Enum$MetaOrderBy fromJson$Enum$MetaOrderBy(String value) {
  switch (value) {
    case r'KEY':
      return Enum$MetaOrderBy.KEY;
    case r'VALUE':
      return Enum$MetaOrderBy.VALUE;
    default:
      return Enum$MetaOrderBy.$unknown;
  }
}

enum Enum$SortOrder {
  ASC,
  DESC,
  ASC_NULLS_FIRST,
  DESC_NULLS_FIRST,
  ASC_NULLS_LAST,
  DESC_NULLS_LAST,
  $unknown;

  factory Enum$SortOrder.fromJson(String value) =>
      fromJson$Enum$SortOrder(value);

  String toJson() => toJson$Enum$SortOrder(this);
}

String toJson$Enum$SortOrder(Enum$SortOrder e) {
  switch (e) {
    case Enum$SortOrder.ASC:
      return r'ASC';
    case Enum$SortOrder.DESC:
      return r'DESC';
    case Enum$SortOrder.ASC_NULLS_FIRST:
      return r'ASC_NULLS_FIRST';
    case Enum$SortOrder.DESC_NULLS_FIRST:
      return r'DESC_NULLS_FIRST';
    case Enum$SortOrder.ASC_NULLS_LAST:
      return r'ASC_NULLS_LAST';
    case Enum$SortOrder.DESC_NULLS_LAST:
      return r'DESC_NULLS_LAST';
    case Enum$SortOrder.$unknown:
      return r'$unknown';
  }
}

Enum$SortOrder fromJson$Enum$SortOrder(String value) {
  switch (value) {
    case r'ASC':
      return Enum$SortOrder.ASC;
    case r'DESC':
      return Enum$SortOrder.DESC;
    case r'ASC_NULLS_FIRST':
      return Enum$SortOrder.ASC_NULLS_FIRST;
    case r'DESC_NULLS_FIRST':
      return Enum$SortOrder.DESC_NULLS_FIRST;
    case r'ASC_NULLS_LAST':
      return Enum$SortOrder.ASC_NULLS_LAST;
    case r'DESC_NULLS_LAST':
      return Enum$SortOrder.DESC_NULLS_LAST;
    default:
      return Enum$SortOrder.$unknown;
  }
}

enum Enum$SourceOrderBy {
  ID,
  NAME,
  LANG,
  $unknown;

  factory Enum$SourceOrderBy.fromJson(String value) =>
      fromJson$Enum$SourceOrderBy(value);

  String toJson() => toJson$Enum$SourceOrderBy(this);
}

String toJson$Enum$SourceOrderBy(Enum$SourceOrderBy e) {
  switch (e) {
    case Enum$SourceOrderBy.ID:
      return r'ID';
    case Enum$SourceOrderBy.NAME:
      return r'NAME';
    case Enum$SourceOrderBy.LANG:
      return r'LANG';
    case Enum$SourceOrderBy.$unknown:
      return r'$unknown';
  }
}

Enum$SourceOrderBy fromJson$Enum$SourceOrderBy(String value) {
  switch (value) {
    case r'ID':
      return Enum$SourceOrderBy.ID;
    case r'NAME':
      return Enum$SourceOrderBy.NAME;
    case r'LANG':
      return Enum$SourceOrderBy.LANG;
    default:
      return Enum$SourceOrderBy.$unknown;
  }
}

enum Enum$TrackerOrderBy {
  ID,
  NAME,
  IS_LOGGED_IN,
  $unknown;

  factory Enum$TrackerOrderBy.fromJson(String value) =>
      fromJson$Enum$TrackerOrderBy(value);

  String toJson() => toJson$Enum$TrackerOrderBy(this);
}

String toJson$Enum$TrackerOrderBy(Enum$TrackerOrderBy e) {
  switch (e) {
    case Enum$TrackerOrderBy.ID:
      return r'ID';
    case Enum$TrackerOrderBy.NAME:
      return r'NAME';
    case Enum$TrackerOrderBy.IS_LOGGED_IN:
      return r'IS_LOGGED_IN';
    case Enum$TrackerOrderBy.$unknown:
      return r'$unknown';
  }
}

Enum$TrackerOrderBy fromJson$Enum$TrackerOrderBy(String value) {
  switch (value) {
    case r'ID':
      return Enum$TrackerOrderBy.ID;
    case r'NAME':
      return Enum$TrackerOrderBy.NAME;
    case r'IS_LOGGED_IN':
      return Enum$TrackerOrderBy.IS_LOGGED_IN;
    default:
      return Enum$TrackerOrderBy.$unknown;
  }
}

enum Enum$TrackRecordOrderBy {
  ID,
  MANGA_ID,
  TRACKER_ID,
  REMOTE_ID,
  TITLE,
  LAST_CHAPTER_READ,
  TOTAL_CHAPTERS,
  SCORE,
  START_DATE,
  FINISH_DATE,
  $unknown;

  factory Enum$TrackRecordOrderBy.fromJson(String value) =>
      fromJson$Enum$TrackRecordOrderBy(value);

  String toJson() => toJson$Enum$TrackRecordOrderBy(this);
}

String toJson$Enum$TrackRecordOrderBy(Enum$TrackRecordOrderBy e) {
  switch (e) {
    case Enum$TrackRecordOrderBy.ID:
      return r'ID';
    case Enum$TrackRecordOrderBy.MANGA_ID:
      return r'MANGA_ID';
    case Enum$TrackRecordOrderBy.TRACKER_ID:
      return r'TRACKER_ID';
    case Enum$TrackRecordOrderBy.REMOTE_ID:
      return r'REMOTE_ID';
    case Enum$TrackRecordOrderBy.TITLE:
      return r'TITLE';
    case Enum$TrackRecordOrderBy.LAST_CHAPTER_READ:
      return r'LAST_CHAPTER_READ';
    case Enum$TrackRecordOrderBy.TOTAL_CHAPTERS:
      return r'TOTAL_CHAPTERS';
    case Enum$TrackRecordOrderBy.SCORE:
      return r'SCORE';
    case Enum$TrackRecordOrderBy.START_DATE:
      return r'START_DATE';
    case Enum$TrackRecordOrderBy.FINISH_DATE:
      return r'FINISH_DATE';
    case Enum$TrackRecordOrderBy.$unknown:
      return r'$unknown';
  }
}

Enum$TrackRecordOrderBy fromJson$Enum$TrackRecordOrderBy(String value) {
  switch (value) {
    case r'ID':
      return Enum$TrackRecordOrderBy.ID;
    case r'MANGA_ID':
      return Enum$TrackRecordOrderBy.MANGA_ID;
    case r'TRACKER_ID':
      return Enum$TrackRecordOrderBy.TRACKER_ID;
    case r'REMOTE_ID':
      return Enum$TrackRecordOrderBy.REMOTE_ID;
    case r'TITLE':
      return Enum$TrackRecordOrderBy.TITLE;
    case r'LAST_CHAPTER_READ':
      return Enum$TrackRecordOrderBy.LAST_CHAPTER_READ;
    case r'TOTAL_CHAPTERS':
      return Enum$TrackRecordOrderBy.TOTAL_CHAPTERS;
    case r'SCORE':
      return Enum$TrackRecordOrderBy.SCORE;
    case r'START_DATE':
      return Enum$TrackRecordOrderBy.START_DATE;
    case r'FINISH_DATE':
      return Enum$TrackRecordOrderBy.FINISH_DATE;
    default:
      return Enum$TrackRecordOrderBy.$unknown;
  }
}

enum Enum$TriState {
  IGNORE,
  INCLUDE,
  EXCLUDE,
  $unknown;

  factory Enum$TriState.fromJson(String value) => fromJson$Enum$TriState(value);

  String toJson() => toJson$Enum$TriState(this);
}

String toJson$Enum$TriState(Enum$TriState e) {
  switch (e) {
    case Enum$TriState.IGNORE:
      return r'IGNORE';
    case Enum$TriState.INCLUDE:
      return r'INCLUDE';
    case Enum$TriState.EXCLUDE:
      return r'EXCLUDE';
    case Enum$TriState.$unknown:
      return r'$unknown';
  }
}

Enum$TriState fromJson$Enum$TriState(String value) {
  switch (value) {
    case r'IGNORE':
      return Enum$TriState.IGNORE;
    case r'INCLUDE':
      return Enum$TriState.INCLUDE;
    case r'EXCLUDE':
      return Enum$TriState.EXCLUDE;
    default:
      return Enum$TriState.$unknown;
  }
}

enum Enum$UpdateState {
  IDLE,
  DOWNLOADING,
  FINISHED,
  ERROR,
  $unknown;

  factory Enum$UpdateState.fromJson(String value) =>
      fromJson$Enum$UpdateState(value);

  String toJson() => toJson$Enum$UpdateState(this);
}

String toJson$Enum$UpdateState(Enum$UpdateState e) {
  switch (e) {
    case Enum$UpdateState.IDLE:
      return r'IDLE';
    case Enum$UpdateState.DOWNLOADING:
      return r'DOWNLOADING';
    case Enum$UpdateState.FINISHED:
      return r'FINISHED';
    case Enum$UpdateState.ERROR:
      return r'ERROR';
    case Enum$UpdateState.$unknown:
      return r'$unknown';
  }
}

Enum$UpdateState fromJson$Enum$UpdateState(String value) {
  switch (value) {
    case r'IDLE':
      return Enum$UpdateState.IDLE;
    case r'DOWNLOADING':
      return Enum$UpdateState.DOWNLOADING;
    case r'FINISHED':
      return Enum$UpdateState.FINISHED;
    case r'ERROR':
      return Enum$UpdateState.ERROR;
    default:
      return Enum$UpdateState.$unknown;
  }
}

enum Enum$UpdateStrategy {
  ALWAYS_UPDATE,
  ONLY_FETCH_ONCE,
  $unknown;

  factory Enum$UpdateStrategy.fromJson(String value) =>
      fromJson$Enum$UpdateStrategy(value);

  String toJson() => toJson$Enum$UpdateStrategy(this);
}

String toJson$Enum$UpdateStrategy(Enum$UpdateStrategy e) {
  switch (e) {
    case Enum$UpdateStrategy.ALWAYS_UPDATE:
      return r'ALWAYS_UPDATE';
    case Enum$UpdateStrategy.ONLY_FETCH_ONCE:
      return r'ONLY_FETCH_ONCE';
    case Enum$UpdateStrategy.$unknown:
      return r'$unknown';
  }
}

Enum$UpdateStrategy fromJson$Enum$UpdateStrategy(String value) {
  switch (value) {
    case r'ALWAYS_UPDATE':
      return Enum$UpdateStrategy.ALWAYS_UPDATE;
    case r'ONLY_FETCH_ONCE':
      return Enum$UpdateStrategy.ONLY_FETCH_ONCE;
    default:
      return Enum$UpdateStrategy.$unknown;
  }
}

enum Enum$WebUIChannel {
  BUNDLED,
  STABLE,
  PREVIEW,
  $unknown;

  factory Enum$WebUIChannel.fromJson(String value) =>
      fromJson$Enum$WebUIChannel(value);

  String toJson() => toJson$Enum$WebUIChannel(this);
}

String toJson$Enum$WebUIChannel(Enum$WebUIChannel e) {
  switch (e) {
    case Enum$WebUIChannel.BUNDLED:
      return r'BUNDLED';
    case Enum$WebUIChannel.STABLE:
      return r'STABLE';
    case Enum$WebUIChannel.PREVIEW:
      return r'PREVIEW';
    case Enum$WebUIChannel.$unknown:
      return r'$unknown';
  }
}

Enum$WebUIChannel fromJson$Enum$WebUIChannel(String value) {
  switch (value) {
    case r'BUNDLED':
      return Enum$WebUIChannel.BUNDLED;
    case r'STABLE':
      return Enum$WebUIChannel.STABLE;
    case r'PREVIEW':
      return Enum$WebUIChannel.PREVIEW;
    default:
      return Enum$WebUIChannel.$unknown;
  }
}

enum Enum$WebUIFlavor {
  WEBUI,
  VUI,
  CUSTOM,
  $unknown;

  factory Enum$WebUIFlavor.fromJson(String value) =>
      fromJson$Enum$WebUIFlavor(value);

  String toJson() => toJson$Enum$WebUIFlavor(this);
}

String toJson$Enum$WebUIFlavor(Enum$WebUIFlavor e) {
  switch (e) {
    case Enum$WebUIFlavor.WEBUI:
      return r'WEBUI';
    case Enum$WebUIFlavor.VUI:
      return r'VUI';
    case Enum$WebUIFlavor.CUSTOM:
      return r'CUSTOM';
    case Enum$WebUIFlavor.$unknown:
      return r'$unknown';
  }
}

Enum$WebUIFlavor fromJson$Enum$WebUIFlavor(String value) {
  switch (value) {
    case r'WEBUI':
      return Enum$WebUIFlavor.WEBUI;
    case r'VUI':
      return Enum$WebUIFlavor.VUI;
    case r'CUSTOM':
      return Enum$WebUIFlavor.CUSTOM;
    default:
      return Enum$WebUIFlavor.$unknown;
  }
}

enum Enum$WebUIInterface {
  BROWSER,
  ELECTRON,
  $unknown;

  factory Enum$WebUIInterface.fromJson(String value) =>
      fromJson$Enum$WebUIInterface(value);

  String toJson() => toJson$Enum$WebUIInterface(this);
}

String toJson$Enum$WebUIInterface(Enum$WebUIInterface e) {
  switch (e) {
    case Enum$WebUIInterface.BROWSER:
      return r'BROWSER';
    case Enum$WebUIInterface.ELECTRON:
      return r'ELECTRON';
    case Enum$WebUIInterface.$unknown:
      return r'$unknown';
  }
}

Enum$WebUIInterface fromJson$Enum$WebUIInterface(String value) {
  switch (value) {
    case r'BROWSER':
      return Enum$WebUIInterface.BROWSER;
    case r'ELECTRON':
      return Enum$WebUIInterface.ELECTRON;
    default:
      return Enum$WebUIInterface.$unknown;
  }
}

enum Enum$__TypeKind {
  SCALAR,
  OBJECT,
  INTERFACE,
  UNION,
  ENUM,
  INPUT_OBJECT,
  LIST,
  NON_NULL,
  $unknown;

  factory Enum$__TypeKind.fromJson(String value) =>
      fromJson$Enum$__TypeKind(value);

  String toJson() => toJson$Enum$__TypeKind(this);
}

String toJson$Enum$__TypeKind(Enum$__TypeKind e) {
  switch (e) {
    case Enum$__TypeKind.SCALAR:
      return r'SCALAR';
    case Enum$__TypeKind.OBJECT:
      return r'OBJECT';
    case Enum$__TypeKind.INTERFACE:
      return r'INTERFACE';
    case Enum$__TypeKind.UNION:
      return r'UNION';
    case Enum$__TypeKind.ENUM:
      return r'ENUM';
    case Enum$__TypeKind.INPUT_OBJECT:
      return r'INPUT_OBJECT';
    case Enum$__TypeKind.LIST:
      return r'LIST';
    case Enum$__TypeKind.NON_NULL:
      return r'NON_NULL';
    case Enum$__TypeKind.$unknown:
      return r'$unknown';
  }
}

Enum$__TypeKind fromJson$Enum$__TypeKind(String value) {
  switch (value) {
    case r'SCALAR':
      return Enum$__TypeKind.SCALAR;
    case r'OBJECT':
      return Enum$__TypeKind.OBJECT;
    case r'INTERFACE':
      return Enum$__TypeKind.INTERFACE;
    case r'UNION':
      return Enum$__TypeKind.UNION;
    case r'ENUM':
      return Enum$__TypeKind.ENUM;
    case r'INPUT_OBJECT':
      return Enum$__TypeKind.INPUT_OBJECT;
    case r'LIST':
      return Enum$__TypeKind.LIST;
    case r'NON_NULL':
      return Enum$__TypeKind.NON_NULL;
    default:
      return Enum$__TypeKind.$unknown;
  }
}

enum Enum$__DirectiveLocation {
  QUERY,
  MUTATION,
  SUBSCRIPTION,
  FIELD,
  FRAGMENT_DEFINITION,
  FRAGMENT_SPREAD,
  INLINE_FRAGMENT,
  VARIABLE_DEFINITION,
  SCHEMA,
  SCALAR,
  OBJECT,
  FIELD_DEFINITION,
  ARGUMENT_DEFINITION,
  INTERFACE,
  UNION,
  ENUM,
  ENUM_VALUE,
  INPUT_OBJECT,
  INPUT_FIELD_DEFINITION,
  $unknown;

  factory Enum$__DirectiveLocation.fromJson(String value) =>
      fromJson$Enum$__DirectiveLocation(value);

  String toJson() => toJson$Enum$__DirectiveLocation(this);
}

String toJson$Enum$__DirectiveLocation(Enum$__DirectiveLocation e) {
  switch (e) {
    case Enum$__DirectiveLocation.QUERY:
      return r'QUERY';
    case Enum$__DirectiveLocation.MUTATION:
      return r'MUTATION';
    case Enum$__DirectiveLocation.SUBSCRIPTION:
      return r'SUBSCRIPTION';
    case Enum$__DirectiveLocation.FIELD:
      return r'FIELD';
    case Enum$__DirectiveLocation.FRAGMENT_DEFINITION:
      return r'FRAGMENT_DEFINITION';
    case Enum$__DirectiveLocation.FRAGMENT_SPREAD:
      return r'FRAGMENT_SPREAD';
    case Enum$__DirectiveLocation.INLINE_FRAGMENT:
      return r'INLINE_FRAGMENT';
    case Enum$__DirectiveLocation.VARIABLE_DEFINITION:
      return r'VARIABLE_DEFINITION';
    case Enum$__DirectiveLocation.SCHEMA:
      return r'SCHEMA';
    case Enum$__DirectiveLocation.SCALAR:
      return r'SCALAR';
    case Enum$__DirectiveLocation.OBJECT:
      return r'OBJECT';
    case Enum$__DirectiveLocation.FIELD_DEFINITION:
      return r'FIELD_DEFINITION';
    case Enum$__DirectiveLocation.ARGUMENT_DEFINITION:
      return r'ARGUMENT_DEFINITION';
    case Enum$__DirectiveLocation.INTERFACE:
      return r'INTERFACE';
    case Enum$__DirectiveLocation.UNION:
      return r'UNION';
    case Enum$__DirectiveLocation.ENUM:
      return r'ENUM';
    case Enum$__DirectiveLocation.ENUM_VALUE:
      return r'ENUM_VALUE';
    case Enum$__DirectiveLocation.INPUT_OBJECT:
      return r'INPUT_OBJECT';
    case Enum$__DirectiveLocation.INPUT_FIELD_DEFINITION:
      return r'INPUT_FIELD_DEFINITION';
    case Enum$__DirectiveLocation.$unknown:
      return r'$unknown';
  }
}

Enum$__DirectiveLocation fromJson$Enum$__DirectiveLocation(String value) {
  switch (value) {
    case r'QUERY':
      return Enum$__DirectiveLocation.QUERY;
    case r'MUTATION':
      return Enum$__DirectiveLocation.MUTATION;
    case r'SUBSCRIPTION':
      return Enum$__DirectiveLocation.SUBSCRIPTION;
    case r'FIELD':
      return Enum$__DirectiveLocation.FIELD;
    case r'FRAGMENT_DEFINITION':
      return Enum$__DirectiveLocation.FRAGMENT_DEFINITION;
    case r'FRAGMENT_SPREAD':
      return Enum$__DirectiveLocation.FRAGMENT_SPREAD;
    case r'INLINE_FRAGMENT':
      return Enum$__DirectiveLocation.INLINE_FRAGMENT;
    case r'VARIABLE_DEFINITION':
      return Enum$__DirectiveLocation.VARIABLE_DEFINITION;
    case r'SCHEMA':
      return Enum$__DirectiveLocation.SCHEMA;
    case r'SCALAR':
      return Enum$__DirectiveLocation.SCALAR;
    case r'OBJECT':
      return Enum$__DirectiveLocation.OBJECT;
    case r'FIELD_DEFINITION':
      return Enum$__DirectiveLocation.FIELD_DEFINITION;
    case r'ARGUMENT_DEFINITION':
      return Enum$__DirectiveLocation.ARGUMENT_DEFINITION;
    case r'INTERFACE':
      return Enum$__DirectiveLocation.INTERFACE;
    case r'UNION':
      return Enum$__DirectiveLocation.UNION;
    case r'ENUM':
      return Enum$__DirectiveLocation.ENUM;
    case r'ENUM_VALUE':
      return Enum$__DirectiveLocation.ENUM_VALUE;
    case r'INPUT_OBJECT':
      return Enum$__DirectiveLocation.INPUT_OBJECT;
    case r'INPUT_FIELD_DEFINITION':
      return Enum$__DirectiveLocation.INPUT_FIELD_DEFINITION;
    default:
      return Enum$__DirectiveLocation.$unknown;
  }
}

const possibleTypesMap = <String, Set<String>>{
  'Edge': {
    'CategoryEdge',
    'ChapterEdge',
    'DownloadEdge',
    'ExtensionEdge',
    'MangaEdge',
    'MetaEdge',
    'SourceEdge',
    'TrackerEdge',
    'TrackRecordEdge',
  },
  'MetaType': {
    'CategoryMetaType',
    'ChapterMetaType',
    'GlobalMetaType',
    'MangaMetaType',
    'SourceMetaType',
  },
  'NodeList': {
    'CategoryNodeList',
    'ChapterNodeList',
    'DownloadNodeList',
    'ExtensionNodeList',
    'GlobalMetaNodeList',
    'MangaNodeList',
    'SourceNodeList',
    'TrackerNodeList',
    'TrackRecordNodeList',
  },
  'Filter': {
    'CheckBoxFilter',
    'GroupFilter',
    'HeaderFilter',
    'SelectFilter',
    'SeparatorFilter',
    'SortFilter',
    'TextFilter',
    'TriStateFilter',
  },
  'Node': {
    'CategoryMetaType',
    'CategoryType',
    'ChapterMetaType',
    'ChapterType',
    'DownloadType',
    'DownloadUpdate',
    'ExtensionType',
    'GlobalMetaType',
    'MangaMetaType',
    'MangaType',
    'PartialSettingsType',
    'SettingsType',
    'SourceMetaType',
    'SourceType',
    'TrackRecordType',
    'TrackerType',
  },
  'Settings': {
    'PartialSettingsType',
    'SettingsType',
  },
  'Preference': {
    'CheckBoxPreference',
    'EditTextPreference',
    'ListPreference',
    'MultiSelectListPreference',
    'SwitchPreference',
  },
};
