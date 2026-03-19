import '../../../../../domain/settings/graphql/__generated__/fragment.graphql.dart';
import 'dart:async';
import 'package:catalyst/src/utils/misc/scalars.dart';
import 'package:flutter/widgets.dart' as widgets;
import 'package:gql/ast.dart';
import 'package:graphql/client.dart' as graphql;
import 'package:graphql_flutter/graphql_flutter.dart' as graphql_flutter;

class Variables$Mutation$UpdateBackupTTL {
  factory Variables$Mutation$UpdateBackupTTL({int? backupTTL}) =>
      Variables$Mutation$UpdateBackupTTL._({
        if (backupTTL != null) r'backupTTL': backupTTL,
      });

  Variables$Mutation$UpdateBackupTTL._(this._$data);

  factory Variables$Mutation$UpdateBackupTTL.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('backupTTL')) {
      final l$backupTTL = data['backupTTL'];
      result$data['backupTTL'] = (l$backupTTL as int?);
    }
    return Variables$Mutation$UpdateBackupTTL._(result$data);
  }

  Map<String, dynamic> _$data;

  int? get backupTTL => (_$data['backupTTL'] as int?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('backupTTL')) {
      final l$backupTTL = backupTTL;
      result$data['backupTTL'] = l$backupTTL;
    }
    return result$data;
  }

  CopyWith$Variables$Mutation$UpdateBackupTTL<
          Variables$Mutation$UpdateBackupTTL>
      get copyWith => CopyWith$Variables$Mutation$UpdateBackupTTL(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$UpdateBackupTTL ||
        runtimeType != other.runtimeType) {
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
    return true;
  }

  @override
  int get hashCode {
    final l$backupTTL = backupTTL;
    return Object.hashAll(
        [_$data.containsKey('backupTTL') ? l$backupTTL : const {}]);
  }
}

abstract class CopyWith$Variables$Mutation$UpdateBackupTTL<TRes> {
  factory CopyWith$Variables$Mutation$UpdateBackupTTL(
    Variables$Mutation$UpdateBackupTTL instance,
    TRes Function(Variables$Mutation$UpdateBackupTTL) then,
  ) = _CopyWithImpl$Variables$Mutation$UpdateBackupTTL;

  factory CopyWith$Variables$Mutation$UpdateBackupTTL.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$UpdateBackupTTL;

  TRes call({int? backupTTL});
}

class _CopyWithImpl$Variables$Mutation$UpdateBackupTTL<TRes>
    implements CopyWith$Variables$Mutation$UpdateBackupTTL<TRes> {
  _CopyWithImpl$Variables$Mutation$UpdateBackupTTL(
    this._instance,
    this._then,
  );

  final Variables$Mutation$UpdateBackupTTL _instance;

  final TRes Function(Variables$Mutation$UpdateBackupTTL) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? backupTTL = _undefined}) =>
      _then(Variables$Mutation$UpdateBackupTTL._({
        ..._instance._$data,
        if (backupTTL != _undefined) 'backupTTL': (backupTTL as int?),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$UpdateBackupTTL<TRes>
    implements CopyWith$Variables$Mutation$UpdateBackupTTL<TRes> {
  _CopyWithStubImpl$Variables$Mutation$UpdateBackupTTL(this._res);

  TRes _res;

  call({int? backupTTL}) => _res;
}

class Mutation$UpdateBackupTTL {
  Mutation$UpdateBackupTTL({
    required this.setSettings,
    this.$__typename = 'Mutation',
  });

  factory Mutation$UpdateBackupTTL.fromJson(Map<String, dynamic> json) {
    final l$setSettings = json['setSettings'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateBackupTTL(
      setSettings: Mutation$UpdateBackupTTL$setSettings.fromJson(
          (l$setSettings as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$UpdateBackupTTL$setSettings setSettings;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$setSettings = setSettings;
    _resultData['setSettings'] = l$setSettings.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$setSettings = setSettings;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$setSettings,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$UpdateBackupTTL ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$setSettings = setSettings;
    final lOther$setSettings = other.setSettings;
    if (l$setSettings != lOther$setSettings) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Mutation$UpdateBackupTTL
    on Mutation$UpdateBackupTTL {
  CopyWith$Mutation$UpdateBackupTTL<Mutation$UpdateBackupTTL> get copyWith =>
      CopyWith$Mutation$UpdateBackupTTL(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Mutation$UpdateBackupTTL<TRes> {
  factory CopyWith$Mutation$UpdateBackupTTL(
    Mutation$UpdateBackupTTL instance,
    TRes Function(Mutation$UpdateBackupTTL) then,
  ) = _CopyWithImpl$Mutation$UpdateBackupTTL;

  factory CopyWith$Mutation$UpdateBackupTTL.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateBackupTTL;

  TRes call({
    Mutation$UpdateBackupTTL$setSettings? setSettings,
    String? $__typename,
  });
  CopyWith$Mutation$UpdateBackupTTL$setSettings<TRes> get setSettings;
}

class _CopyWithImpl$Mutation$UpdateBackupTTL<TRes>
    implements CopyWith$Mutation$UpdateBackupTTL<TRes> {
  _CopyWithImpl$Mutation$UpdateBackupTTL(
    this._instance,
    this._then,
  );

  final Mutation$UpdateBackupTTL _instance;

  final TRes Function(Mutation$UpdateBackupTTL) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? setSettings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateBackupTTL(
        setSettings: setSettings == _undefined || setSettings == null
            ? _instance.setSettings
            : (setSettings as Mutation$UpdateBackupTTL$setSettings),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$UpdateBackupTTL$setSettings<TRes> get setSettings {
    final local$setSettings = _instance.setSettings;
    return CopyWith$Mutation$UpdateBackupTTL$setSettings(
        local$setSettings, (e) => call(setSettings: e));
  }
}

class _CopyWithStubImpl$Mutation$UpdateBackupTTL<TRes>
    implements CopyWith$Mutation$UpdateBackupTTL<TRes> {
  _CopyWithStubImpl$Mutation$UpdateBackupTTL(this._res);

  TRes _res;

  call({
    Mutation$UpdateBackupTTL$setSettings? setSettings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$UpdateBackupTTL$setSettings<TRes> get setSettings =>
      CopyWith$Mutation$UpdateBackupTTL$setSettings.stub(_res);
}

const documentNodeMutationUpdateBackupTTL = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'UpdateBackupTTL'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'backupTTL')),
        type: NamedTypeNode(
          name: NameNode(value: 'Int'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: IntValueNode(value: '14')),
        directives: [],
      )
    ],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'setSettings'),
        alias: null,
        arguments: [
          ArgumentNode(
            name: NameNode(value: 'input'),
            value: ObjectValueNode(fields: [
              ObjectFieldNode(
                name: NameNode(value: 'settings'),
                value: ObjectValueNode(fields: [
                  ObjectFieldNode(
                    name: NameNode(value: 'backupTTL'),
                    value: VariableNode(name: NameNode(value: 'backupTTL')),
                  )
                ]),
              )
            ]),
          )
        ],
        directives: [],
        selectionSet: SelectionSetNode(selections: [
          FieldNode(
            name: NameNode(value: 'settings'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: SelectionSetNode(selections: [
              FragmentSpreadNode(
                name: NameNode(value: 'SettingsDto'),
                directives: [],
              ),
              FieldNode(
                name: NameNode(value: '__typename'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
            ]),
          ),
          FieldNode(
            name: NameNode(value: '__typename'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null,
          ),
        ]),
      ),
      FieldNode(
        name: NameNode(value: '__typename'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
    ]),
  ),
  fragmentDefinitionSettingsDto,
  fragmentDefinitionAutomaticBackupSettingsDto,
  fragmentDefinitionServerBindingDto,
  fragmentDefinitionSocksProxyDto,
  fragmentDefinitionCloudFlareBypassDto,
  fragmentDefinitionMiscSettingsDto,
  fragmentDefinitionBrowserSettingsDto,
  fragmentDefinitionLibrarySettingsDto,
  fragmentDefinitionDownloadsSettingsDto,
]);
Mutation$UpdateBackupTTL _parserFn$Mutation$UpdateBackupTTL(
        Map<String, dynamic> data) =>
    Mutation$UpdateBackupTTL.fromJson(data);
typedef OnMutationCompleted$Mutation$UpdateBackupTTL = FutureOr<void> Function(
  Map<String, dynamic>?,
  Mutation$UpdateBackupTTL?,
);

class Options$Mutation$UpdateBackupTTL
    extends graphql.MutationOptions<Mutation$UpdateBackupTTL> {
  Options$Mutation$UpdateBackupTTL({
    String? operationName,
    Variables$Mutation$UpdateBackupTTL? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateBackupTTL? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateBackupTTL? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateBackupTTL>? update,
    graphql.OnError? onError,
  })  : onCompletedWithParsed = onCompleted,
        super(
          variables: variables?.toJson() ?? {},
          operationName: operationName,
          fetchPolicy: fetchPolicy,
          errorPolicy: errorPolicy,
          cacheRereadPolicy: cacheRereadPolicy,
          optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
          context: context,
          onCompleted: onCompleted == null
              ? null
              : (data) => onCompleted(
                    data,
                    data == null
                        ? null
                        : _parserFn$Mutation$UpdateBackupTTL(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateBackupTTL,
          parserFn: _parserFn$Mutation$UpdateBackupTTL,
        );

  final OnMutationCompleted$Mutation$UpdateBackupTTL? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$UpdateBackupTTL
    extends graphql.WatchQueryOptions<Mutation$UpdateBackupTTL> {
  WatchOptions$Mutation$UpdateBackupTTL({
    String? operationName,
    Variables$Mutation$UpdateBackupTTL? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateBackupTTL? typedOptimisticResult,
    graphql.Context? context,
    Duration? pollInterval,
    bool? eagerlyFetchResults,
    bool carryForwardDataOnException = true,
    bool fetchResults = false,
  }) : super(
          variables: variables?.toJson() ?? {},
          operationName: operationName,
          fetchPolicy: fetchPolicy,
          errorPolicy: errorPolicy,
          cacheRereadPolicy: cacheRereadPolicy,
          optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
          context: context,
          document: documentNodeMutationUpdateBackupTTL,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$UpdateBackupTTL,
        );
}

extension ClientExtension$Mutation$UpdateBackupTTL on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$UpdateBackupTTL>> mutate$UpdateBackupTTL(
          [Options$Mutation$UpdateBackupTTL? options]) async =>
      await this.mutate(options ?? Options$Mutation$UpdateBackupTTL());

  graphql.ObservableQuery<
      Mutation$UpdateBackupTTL> watchMutation$UpdateBackupTTL(
          [WatchOptions$Mutation$UpdateBackupTTL? options]) =>
      this.watchMutation(options ?? WatchOptions$Mutation$UpdateBackupTTL());
}

class Mutation$UpdateBackupTTL$HookResult {
  Mutation$UpdateBackupTTL$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$UpdateBackupTTL runMutation;

  final graphql.QueryResult<Mutation$UpdateBackupTTL> result;
}

Mutation$UpdateBackupTTL$HookResult useMutation$UpdateBackupTTL(
    [WidgetOptions$Mutation$UpdateBackupTTL? options]) {
  final result = graphql_flutter
      .useMutation(options ?? WidgetOptions$Mutation$UpdateBackupTTL());
  return Mutation$UpdateBackupTTL$HookResult(
    ({variables, optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables?.toJson() ?? const {},
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$UpdateBackupTTL>
    useWatchMutation$UpdateBackupTTL(
            [WatchOptions$Mutation$UpdateBackupTTL? options]) =>
        graphql_flutter.useWatchMutation(
            options ?? WatchOptions$Mutation$UpdateBackupTTL());

class WidgetOptions$Mutation$UpdateBackupTTL
    extends graphql.MutationOptions<Mutation$UpdateBackupTTL> {
  WidgetOptions$Mutation$UpdateBackupTTL({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateBackupTTL? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateBackupTTL? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateBackupTTL>? update,
    graphql.OnError? onError,
  })  : onCompletedWithParsed = onCompleted,
        super(
          operationName: operationName,
          fetchPolicy: fetchPolicy,
          errorPolicy: errorPolicy,
          cacheRereadPolicy: cacheRereadPolicy,
          optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
          context: context,
          onCompleted: onCompleted == null
              ? null
              : (data) => onCompleted(
                    data,
                    data == null
                        ? null
                        : _parserFn$Mutation$UpdateBackupTTL(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateBackupTTL,
          parserFn: _parserFn$Mutation$UpdateBackupTTL,
        );

  final OnMutationCompleted$Mutation$UpdateBackupTTL? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$UpdateBackupTTL
    = graphql.MultiSourceResult<Mutation$UpdateBackupTTL> Function({
  Variables$Mutation$UpdateBackupTTL? variables,
  Object? optimisticResult,
  Mutation$UpdateBackupTTL? typedOptimisticResult,
});
typedef Builder$Mutation$UpdateBackupTTL = widgets.Widget Function(
  RunMutation$Mutation$UpdateBackupTTL,
  graphql.QueryResult<Mutation$UpdateBackupTTL>?,
);

class Mutation$UpdateBackupTTL$Widget
    extends graphql_flutter.Mutation<Mutation$UpdateBackupTTL> {
  Mutation$UpdateBackupTTL$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$UpdateBackupTTL? options,
    required Builder$Mutation$UpdateBackupTTL builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$UpdateBackupTTL(),
          builder: (
            run,
            result,
          ) =>
              builder(
            ({
              variables,
              optimisticResult,
              typedOptimisticResult,
            }) =>
                run(
              variables?.toJson() ?? const {},
              optimisticResult:
                  optimisticResult ?? typedOptimisticResult?.toJson(),
            ),
            result,
          ),
        );
}

class Mutation$UpdateBackupTTL$setSettings {
  Mutation$UpdateBackupTTL$setSettings({
    required this.settings,
    this.$__typename = 'SetSettingsPayload',
  });

  factory Mutation$UpdateBackupTTL$setSettings.fromJson(
      Map<String, dynamic> json) {
    final l$settings = json['settings'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateBackupTTL$setSettings(
      settings:
          Fragment$SettingsDto.fromJson((l$settings as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Fragment$SettingsDto settings;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$settings = settings;
    _resultData['settings'] = l$settings.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$settings = settings;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$settings,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$UpdateBackupTTL$setSettings ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$settings = settings;
    final lOther$settings = other.settings;
    if (l$settings != lOther$settings) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Mutation$UpdateBackupTTL$setSettings
    on Mutation$UpdateBackupTTL$setSettings {
  CopyWith$Mutation$UpdateBackupTTL$setSettings<
          Mutation$UpdateBackupTTL$setSettings>
      get copyWith => CopyWith$Mutation$UpdateBackupTTL$setSettings(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdateBackupTTL$setSettings<TRes> {
  factory CopyWith$Mutation$UpdateBackupTTL$setSettings(
    Mutation$UpdateBackupTTL$setSettings instance,
    TRes Function(Mutation$UpdateBackupTTL$setSettings) then,
  ) = _CopyWithImpl$Mutation$UpdateBackupTTL$setSettings;

  factory CopyWith$Mutation$UpdateBackupTTL$setSettings.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateBackupTTL$setSettings;

  TRes call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  });
  CopyWith$Fragment$SettingsDto<TRes> get settings;
}

class _CopyWithImpl$Mutation$UpdateBackupTTL$setSettings<TRes>
    implements CopyWith$Mutation$UpdateBackupTTL$setSettings<TRes> {
  _CopyWithImpl$Mutation$UpdateBackupTTL$setSettings(
    this._instance,
    this._then,
  );

  final Mutation$UpdateBackupTTL$setSettings _instance;

  final TRes Function(Mutation$UpdateBackupTTL$setSettings) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? settings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateBackupTTL$setSettings(
        settings: settings == _undefined || settings == null
            ? _instance.settings
            : (settings as Fragment$SettingsDto),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Fragment$SettingsDto<TRes> get settings {
    final local$settings = _instance.settings;
    return CopyWith$Fragment$SettingsDto(
        local$settings, (e) => call(settings: e));
  }
}

class _CopyWithStubImpl$Mutation$UpdateBackupTTL$setSettings<TRes>
    implements CopyWith$Mutation$UpdateBackupTTL$setSettings<TRes> {
  _CopyWithStubImpl$Mutation$UpdateBackupTTL$setSettings(this._res);

  TRes _res;

  call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$SettingsDto<TRes> get settings =>
      CopyWith$Fragment$SettingsDto.stub(_res);
}

class Variables$Mutation$UpdateBackupTime {
  factory Variables$Mutation$UpdateBackupTime({String? backupTime}) =>
      Variables$Mutation$UpdateBackupTime._({
        if (backupTime != null) r'backupTime': backupTime,
      });

  Variables$Mutation$UpdateBackupTime._(this._$data);

  factory Variables$Mutation$UpdateBackupTime.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('backupTime')) {
      final l$backupTime = data['backupTime'];
      result$data['backupTime'] = (l$backupTime as String?);
    }
    return Variables$Mutation$UpdateBackupTime._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get backupTime => (_$data['backupTime'] as String?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('backupTime')) {
      final l$backupTime = backupTime;
      result$data['backupTime'] = l$backupTime;
    }
    return result$data;
  }

  CopyWith$Variables$Mutation$UpdateBackupTime<
          Variables$Mutation$UpdateBackupTime>
      get copyWith => CopyWith$Variables$Mutation$UpdateBackupTime(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$UpdateBackupTime ||
        runtimeType != other.runtimeType) {
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
    return true;
  }

  @override
  int get hashCode {
    final l$backupTime = backupTime;
    return Object.hashAll(
        [_$data.containsKey('backupTime') ? l$backupTime : const {}]);
  }
}

abstract class CopyWith$Variables$Mutation$UpdateBackupTime<TRes> {
  factory CopyWith$Variables$Mutation$UpdateBackupTime(
    Variables$Mutation$UpdateBackupTime instance,
    TRes Function(Variables$Mutation$UpdateBackupTime) then,
  ) = _CopyWithImpl$Variables$Mutation$UpdateBackupTime;

  factory CopyWith$Variables$Mutation$UpdateBackupTime.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$UpdateBackupTime;

  TRes call({String? backupTime});
}

class _CopyWithImpl$Variables$Mutation$UpdateBackupTime<TRes>
    implements CopyWith$Variables$Mutation$UpdateBackupTime<TRes> {
  _CopyWithImpl$Variables$Mutation$UpdateBackupTime(
    this._instance,
    this._then,
  );

  final Variables$Mutation$UpdateBackupTime _instance;

  final TRes Function(Variables$Mutation$UpdateBackupTime) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? backupTime = _undefined}) =>
      _then(Variables$Mutation$UpdateBackupTime._({
        ..._instance._$data,
        if (backupTime != _undefined) 'backupTime': (backupTime as String?),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$UpdateBackupTime<TRes>
    implements CopyWith$Variables$Mutation$UpdateBackupTime<TRes> {
  _CopyWithStubImpl$Variables$Mutation$UpdateBackupTime(this._res);

  TRes _res;

  call({String? backupTime}) => _res;
}

class Mutation$UpdateBackupTime {
  Mutation$UpdateBackupTime({
    required this.setSettings,
    this.$__typename = 'Mutation',
  });

  factory Mutation$UpdateBackupTime.fromJson(Map<String, dynamic> json) {
    final l$setSettings = json['setSettings'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateBackupTime(
      setSettings: Mutation$UpdateBackupTime$setSettings.fromJson(
          (l$setSettings as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$UpdateBackupTime$setSettings setSettings;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$setSettings = setSettings;
    _resultData['setSettings'] = l$setSettings.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$setSettings = setSettings;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$setSettings,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$UpdateBackupTime ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$setSettings = setSettings;
    final lOther$setSettings = other.setSettings;
    if (l$setSettings != lOther$setSettings) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Mutation$UpdateBackupTime
    on Mutation$UpdateBackupTime {
  CopyWith$Mutation$UpdateBackupTime<Mutation$UpdateBackupTime> get copyWith =>
      CopyWith$Mutation$UpdateBackupTime(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Mutation$UpdateBackupTime<TRes> {
  factory CopyWith$Mutation$UpdateBackupTime(
    Mutation$UpdateBackupTime instance,
    TRes Function(Mutation$UpdateBackupTime) then,
  ) = _CopyWithImpl$Mutation$UpdateBackupTime;

  factory CopyWith$Mutation$UpdateBackupTime.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateBackupTime;

  TRes call({
    Mutation$UpdateBackupTime$setSettings? setSettings,
    String? $__typename,
  });
  CopyWith$Mutation$UpdateBackupTime$setSettings<TRes> get setSettings;
}

class _CopyWithImpl$Mutation$UpdateBackupTime<TRes>
    implements CopyWith$Mutation$UpdateBackupTime<TRes> {
  _CopyWithImpl$Mutation$UpdateBackupTime(
    this._instance,
    this._then,
  );

  final Mutation$UpdateBackupTime _instance;

  final TRes Function(Mutation$UpdateBackupTime) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? setSettings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateBackupTime(
        setSettings: setSettings == _undefined || setSettings == null
            ? _instance.setSettings
            : (setSettings as Mutation$UpdateBackupTime$setSettings),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$UpdateBackupTime$setSettings<TRes> get setSettings {
    final local$setSettings = _instance.setSettings;
    return CopyWith$Mutation$UpdateBackupTime$setSettings(
        local$setSettings, (e) => call(setSettings: e));
  }
}

class _CopyWithStubImpl$Mutation$UpdateBackupTime<TRes>
    implements CopyWith$Mutation$UpdateBackupTime<TRes> {
  _CopyWithStubImpl$Mutation$UpdateBackupTime(this._res);

  TRes _res;

  call({
    Mutation$UpdateBackupTime$setSettings? setSettings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$UpdateBackupTime$setSettings<TRes> get setSettings =>
      CopyWith$Mutation$UpdateBackupTime$setSettings.stub(_res);
}

const documentNodeMutationUpdateBackupTime = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'UpdateBackupTime'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'backupTime')),
        type: NamedTypeNode(
          name: NameNode(value: 'String'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(
            value: StringValueNode(
          value: '12:00',
          isBlock: false,
        )),
        directives: [],
      )
    ],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'setSettings'),
        alias: null,
        arguments: [
          ArgumentNode(
            name: NameNode(value: 'input'),
            value: ObjectValueNode(fields: [
              ObjectFieldNode(
                name: NameNode(value: 'settings'),
                value: ObjectValueNode(fields: [
                  ObjectFieldNode(
                    name: NameNode(value: 'backupTime'),
                    value: VariableNode(name: NameNode(value: 'backupTime')),
                  )
                ]),
              )
            ]),
          )
        ],
        directives: [],
        selectionSet: SelectionSetNode(selections: [
          FieldNode(
            name: NameNode(value: 'settings'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: SelectionSetNode(selections: [
              FragmentSpreadNode(
                name: NameNode(value: 'SettingsDto'),
                directives: [],
              ),
              FieldNode(
                name: NameNode(value: '__typename'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
            ]),
          ),
          FieldNode(
            name: NameNode(value: '__typename'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null,
          ),
        ]),
      ),
      FieldNode(
        name: NameNode(value: '__typename'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
    ]),
  ),
  fragmentDefinitionSettingsDto,
  fragmentDefinitionAutomaticBackupSettingsDto,
  fragmentDefinitionServerBindingDto,
  fragmentDefinitionSocksProxyDto,
  fragmentDefinitionCloudFlareBypassDto,
  fragmentDefinitionMiscSettingsDto,
  fragmentDefinitionBrowserSettingsDto,
  fragmentDefinitionLibrarySettingsDto,
  fragmentDefinitionDownloadsSettingsDto,
]);
Mutation$UpdateBackupTime _parserFn$Mutation$UpdateBackupTime(
        Map<String, dynamic> data) =>
    Mutation$UpdateBackupTime.fromJson(data);
typedef OnMutationCompleted$Mutation$UpdateBackupTime = FutureOr<void> Function(
  Map<String, dynamic>?,
  Mutation$UpdateBackupTime?,
);

class Options$Mutation$UpdateBackupTime
    extends graphql.MutationOptions<Mutation$UpdateBackupTime> {
  Options$Mutation$UpdateBackupTime({
    String? operationName,
    Variables$Mutation$UpdateBackupTime? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateBackupTime? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateBackupTime? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateBackupTime>? update,
    graphql.OnError? onError,
  })  : onCompletedWithParsed = onCompleted,
        super(
          variables: variables?.toJson() ?? {},
          operationName: operationName,
          fetchPolicy: fetchPolicy,
          errorPolicy: errorPolicy,
          cacheRereadPolicy: cacheRereadPolicy,
          optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
          context: context,
          onCompleted: onCompleted == null
              ? null
              : (data) => onCompleted(
                    data,
                    data == null
                        ? null
                        : _parserFn$Mutation$UpdateBackupTime(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateBackupTime,
          parserFn: _parserFn$Mutation$UpdateBackupTime,
        );

  final OnMutationCompleted$Mutation$UpdateBackupTime? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$UpdateBackupTime
    extends graphql.WatchQueryOptions<Mutation$UpdateBackupTime> {
  WatchOptions$Mutation$UpdateBackupTime({
    String? operationName,
    Variables$Mutation$UpdateBackupTime? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateBackupTime? typedOptimisticResult,
    graphql.Context? context,
    Duration? pollInterval,
    bool? eagerlyFetchResults,
    bool carryForwardDataOnException = true,
    bool fetchResults = false,
  }) : super(
          variables: variables?.toJson() ?? {},
          operationName: operationName,
          fetchPolicy: fetchPolicy,
          errorPolicy: errorPolicy,
          cacheRereadPolicy: cacheRereadPolicy,
          optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
          context: context,
          document: documentNodeMutationUpdateBackupTime,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$UpdateBackupTime,
        );
}

extension ClientExtension$Mutation$UpdateBackupTime on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$UpdateBackupTime>>
      mutate$UpdateBackupTime(
              [Options$Mutation$UpdateBackupTime? options]) async =>
          await this.mutate(options ?? Options$Mutation$UpdateBackupTime());

  graphql.ObservableQuery<
      Mutation$UpdateBackupTime> watchMutation$UpdateBackupTime(
          [WatchOptions$Mutation$UpdateBackupTime? options]) =>
      this.watchMutation(options ?? WatchOptions$Mutation$UpdateBackupTime());
}

class Mutation$UpdateBackupTime$HookResult {
  Mutation$UpdateBackupTime$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$UpdateBackupTime runMutation;

  final graphql.QueryResult<Mutation$UpdateBackupTime> result;
}

Mutation$UpdateBackupTime$HookResult useMutation$UpdateBackupTime(
    [WidgetOptions$Mutation$UpdateBackupTime? options]) {
  final result = graphql_flutter
      .useMutation(options ?? WidgetOptions$Mutation$UpdateBackupTime());
  return Mutation$UpdateBackupTime$HookResult(
    ({variables, optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables?.toJson() ?? const {},
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$UpdateBackupTime>
    useWatchMutation$UpdateBackupTime(
            [WatchOptions$Mutation$UpdateBackupTime? options]) =>
        graphql_flutter.useWatchMutation(
            options ?? WatchOptions$Mutation$UpdateBackupTime());

class WidgetOptions$Mutation$UpdateBackupTime
    extends graphql.MutationOptions<Mutation$UpdateBackupTime> {
  WidgetOptions$Mutation$UpdateBackupTime({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateBackupTime? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateBackupTime? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateBackupTime>? update,
    graphql.OnError? onError,
  })  : onCompletedWithParsed = onCompleted,
        super(
          operationName: operationName,
          fetchPolicy: fetchPolicy,
          errorPolicy: errorPolicy,
          cacheRereadPolicy: cacheRereadPolicy,
          optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
          context: context,
          onCompleted: onCompleted == null
              ? null
              : (data) => onCompleted(
                    data,
                    data == null
                        ? null
                        : _parserFn$Mutation$UpdateBackupTime(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateBackupTime,
          parserFn: _parserFn$Mutation$UpdateBackupTime,
        );

  final OnMutationCompleted$Mutation$UpdateBackupTime? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$UpdateBackupTime
    = graphql.MultiSourceResult<Mutation$UpdateBackupTime> Function({
  Variables$Mutation$UpdateBackupTime? variables,
  Object? optimisticResult,
  Mutation$UpdateBackupTime? typedOptimisticResult,
});
typedef Builder$Mutation$UpdateBackupTime = widgets.Widget Function(
  RunMutation$Mutation$UpdateBackupTime,
  graphql.QueryResult<Mutation$UpdateBackupTime>?,
);

class Mutation$UpdateBackupTime$Widget
    extends graphql_flutter.Mutation<Mutation$UpdateBackupTime> {
  Mutation$UpdateBackupTime$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$UpdateBackupTime? options,
    required Builder$Mutation$UpdateBackupTime builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$UpdateBackupTime(),
          builder: (
            run,
            result,
          ) =>
              builder(
            ({
              variables,
              optimisticResult,
              typedOptimisticResult,
            }) =>
                run(
              variables?.toJson() ?? const {},
              optimisticResult:
                  optimisticResult ?? typedOptimisticResult?.toJson(),
            ),
            result,
          ),
        );
}

class Mutation$UpdateBackupTime$setSettings {
  Mutation$UpdateBackupTime$setSettings({
    required this.settings,
    this.$__typename = 'SetSettingsPayload',
  });

  factory Mutation$UpdateBackupTime$setSettings.fromJson(
      Map<String, dynamic> json) {
    final l$settings = json['settings'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateBackupTime$setSettings(
      settings:
          Fragment$SettingsDto.fromJson((l$settings as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Fragment$SettingsDto settings;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$settings = settings;
    _resultData['settings'] = l$settings.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$settings = settings;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$settings,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$UpdateBackupTime$setSettings ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$settings = settings;
    final lOther$settings = other.settings;
    if (l$settings != lOther$settings) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Mutation$UpdateBackupTime$setSettings
    on Mutation$UpdateBackupTime$setSettings {
  CopyWith$Mutation$UpdateBackupTime$setSettings<
          Mutation$UpdateBackupTime$setSettings>
      get copyWith => CopyWith$Mutation$UpdateBackupTime$setSettings(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdateBackupTime$setSettings<TRes> {
  factory CopyWith$Mutation$UpdateBackupTime$setSettings(
    Mutation$UpdateBackupTime$setSettings instance,
    TRes Function(Mutation$UpdateBackupTime$setSettings) then,
  ) = _CopyWithImpl$Mutation$UpdateBackupTime$setSettings;

  factory CopyWith$Mutation$UpdateBackupTime$setSettings.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateBackupTime$setSettings;

  TRes call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  });
  CopyWith$Fragment$SettingsDto<TRes> get settings;
}

class _CopyWithImpl$Mutation$UpdateBackupTime$setSettings<TRes>
    implements CopyWith$Mutation$UpdateBackupTime$setSettings<TRes> {
  _CopyWithImpl$Mutation$UpdateBackupTime$setSettings(
    this._instance,
    this._then,
  );

  final Mutation$UpdateBackupTime$setSettings _instance;

  final TRes Function(Mutation$UpdateBackupTime$setSettings) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? settings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateBackupTime$setSettings(
        settings: settings == _undefined || settings == null
            ? _instance.settings
            : (settings as Fragment$SettingsDto),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Fragment$SettingsDto<TRes> get settings {
    final local$settings = _instance.settings;
    return CopyWith$Fragment$SettingsDto(
        local$settings, (e) => call(settings: e));
  }
}

class _CopyWithStubImpl$Mutation$UpdateBackupTime$setSettings<TRes>
    implements CopyWith$Mutation$UpdateBackupTime$setSettings<TRes> {
  _CopyWithStubImpl$Mutation$UpdateBackupTime$setSettings(this._res);

  TRes _res;

  call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$SettingsDto<TRes> get settings =>
      CopyWith$Fragment$SettingsDto.stub(_res);
}

class Variables$Mutation$UpdateBackupPath {
  factory Variables$Mutation$UpdateBackupPath({required String backupPath}) =>
      Variables$Mutation$UpdateBackupPath._({
        r'backupPath': backupPath,
      });

  Variables$Mutation$UpdateBackupPath._(this._$data);

  factory Variables$Mutation$UpdateBackupPath.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$backupPath = data['backupPath'];
    result$data['backupPath'] = (l$backupPath as String);
    return Variables$Mutation$UpdateBackupPath._(result$data);
  }

  Map<String, dynamic> _$data;

  String get backupPath => (_$data['backupPath'] as String);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$backupPath = backupPath;
    result$data['backupPath'] = l$backupPath;
    return result$data;
  }

  CopyWith$Variables$Mutation$UpdateBackupPath<
          Variables$Mutation$UpdateBackupPath>
      get copyWith => CopyWith$Variables$Mutation$UpdateBackupPath(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$UpdateBackupPath ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$backupPath = backupPath;
    final lOther$backupPath = other.backupPath;
    if (l$backupPath != lOther$backupPath) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$backupPath = backupPath;
    return Object.hashAll([l$backupPath]);
  }
}

abstract class CopyWith$Variables$Mutation$UpdateBackupPath<TRes> {
  factory CopyWith$Variables$Mutation$UpdateBackupPath(
    Variables$Mutation$UpdateBackupPath instance,
    TRes Function(Variables$Mutation$UpdateBackupPath) then,
  ) = _CopyWithImpl$Variables$Mutation$UpdateBackupPath;

  factory CopyWith$Variables$Mutation$UpdateBackupPath.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$UpdateBackupPath;

  TRes call({String? backupPath});
}

class _CopyWithImpl$Variables$Mutation$UpdateBackupPath<TRes>
    implements CopyWith$Variables$Mutation$UpdateBackupPath<TRes> {
  _CopyWithImpl$Variables$Mutation$UpdateBackupPath(
    this._instance,
    this._then,
  );

  final Variables$Mutation$UpdateBackupPath _instance;

  final TRes Function(Variables$Mutation$UpdateBackupPath) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? backupPath = _undefined}) =>
      _then(Variables$Mutation$UpdateBackupPath._({
        ..._instance._$data,
        if (backupPath != _undefined && backupPath != null)
          'backupPath': (backupPath as String),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$UpdateBackupPath<TRes>
    implements CopyWith$Variables$Mutation$UpdateBackupPath<TRes> {
  _CopyWithStubImpl$Variables$Mutation$UpdateBackupPath(this._res);

  TRes _res;

  call({String? backupPath}) => _res;
}

class Mutation$UpdateBackupPath {
  Mutation$UpdateBackupPath({
    required this.setSettings,
    this.$__typename = 'Mutation',
  });

  factory Mutation$UpdateBackupPath.fromJson(Map<String, dynamic> json) {
    final l$setSettings = json['setSettings'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateBackupPath(
      setSettings: Mutation$UpdateBackupPath$setSettings.fromJson(
          (l$setSettings as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$UpdateBackupPath$setSettings setSettings;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$setSettings = setSettings;
    _resultData['setSettings'] = l$setSettings.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$setSettings = setSettings;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$setSettings,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$UpdateBackupPath ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$setSettings = setSettings;
    final lOther$setSettings = other.setSettings;
    if (l$setSettings != lOther$setSettings) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Mutation$UpdateBackupPath
    on Mutation$UpdateBackupPath {
  CopyWith$Mutation$UpdateBackupPath<Mutation$UpdateBackupPath> get copyWith =>
      CopyWith$Mutation$UpdateBackupPath(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Mutation$UpdateBackupPath<TRes> {
  factory CopyWith$Mutation$UpdateBackupPath(
    Mutation$UpdateBackupPath instance,
    TRes Function(Mutation$UpdateBackupPath) then,
  ) = _CopyWithImpl$Mutation$UpdateBackupPath;

  factory CopyWith$Mutation$UpdateBackupPath.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateBackupPath;

  TRes call({
    Mutation$UpdateBackupPath$setSettings? setSettings,
    String? $__typename,
  });
  CopyWith$Mutation$UpdateBackupPath$setSettings<TRes> get setSettings;
}

class _CopyWithImpl$Mutation$UpdateBackupPath<TRes>
    implements CopyWith$Mutation$UpdateBackupPath<TRes> {
  _CopyWithImpl$Mutation$UpdateBackupPath(
    this._instance,
    this._then,
  );

  final Mutation$UpdateBackupPath _instance;

  final TRes Function(Mutation$UpdateBackupPath) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? setSettings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateBackupPath(
        setSettings: setSettings == _undefined || setSettings == null
            ? _instance.setSettings
            : (setSettings as Mutation$UpdateBackupPath$setSettings),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$UpdateBackupPath$setSettings<TRes> get setSettings {
    final local$setSettings = _instance.setSettings;
    return CopyWith$Mutation$UpdateBackupPath$setSettings(
        local$setSettings, (e) => call(setSettings: e));
  }
}

class _CopyWithStubImpl$Mutation$UpdateBackupPath<TRes>
    implements CopyWith$Mutation$UpdateBackupPath<TRes> {
  _CopyWithStubImpl$Mutation$UpdateBackupPath(this._res);

  TRes _res;

  call({
    Mutation$UpdateBackupPath$setSettings? setSettings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$UpdateBackupPath$setSettings<TRes> get setSettings =>
      CopyWith$Mutation$UpdateBackupPath$setSettings.stub(_res);
}

const documentNodeMutationUpdateBackupPath = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'UpdateBackupPath'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'backupPath')),
        type: NamedTypeNode(
          name: NameNode(value: 'String'),
          isNonNull: true,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      )
    ],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'setSettings'),
        alias: null,
        arguments: [
          ArgumentNode(
            name: NameNode(value: 'input'),
            value: ObjectValueNode(fields: [
              ObjectFieldNode(
                name: NameNode(value: 'settings'),
                value: ObjectValueNode(fields: [
                  ObjectFieldNode(
                    name: NameNode(value: 'backupPath'),
                    value: VariableNode(name: NameNode(value: 'backupPath')),
                  )
                ]),
              )
            ]),
          )
        ],
        directives: [],
        selectionSet: SelectionSetNode(selections: [
          FieldNode(
            name: NameNode(value: 'settings'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: SelectionSetNode(selections: [
              FragmentSpreadNode(
                name: NameNode(value: 'SettingsDto'),
                directives: [],
              ),
              FieldNode(
                name: NameNode(value: '__typename'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
            ]),
          ),
          FieldNode(
            name: NameNode(value: '__typename'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null,
          ),
        ]),
      ),
      FieldNode(
        name: NameNode(value: '__typename'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
    ]),
  ),
  fragmentDefinitionSettingsDto,
  fragmentDefinitionAutomaticBackupSettingsDto,
  fragmentDefinitionServerBindingDto,
  fragmentDefinitionSocksProxyDto,
  fragmentDefinitionCloudFlareBypassDto,
  fragmentDefinitionMiscSettingsDto,
  fragmentDefinitionBrowserSettingsDto,
  fragmentDefinitionLibrarySettingsDto,
  fragmentDefinitionDownloadsSettingsDto,
]);
Mutation$UpdateBackupPath _parserFn$Mutation$UpdateBackupPath(
        Map<String, dynamic> data) =>
    Mutation$UpdateBackupPath.fromJson(data);
typedef OnMutationCompleted$Mutation$UpdateBackupPath = FutureOr<void> Function(
  Map<String, dynamic>?,
  Mutation$UpdateBackupPath?,
);

class Options$Mutation$UpdateBackupPath
    extends graphql.MutationOptions<Mutation$UpdateBackupPath> {
  Options$Mutation$UpdateBackupPath({
    String? operationName,
    required Variables$Mutation$UpdateBackupPath variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateBackupPath? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateBackupPath? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateBackupPath>? update,
    graphql.OnError? onError,
  })  : onCompletedWithParsed = onCompleted,
        super(
          variables: variables.toJson(),
          operationName: operationName,
          fetchPolicy: fetchPolicy,
          errorPolicy: errorPolicy,
          cacheRereadPolicy: cacheRereadPolicy,
          optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
          context: context,
          onCompleted: onCompleted == null
              ? null
              : (data) => onCompleted(
                    data,
                    data == null
                        ? null
                        : _parserFn$Mutation$UpdateBackupPath(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateBackupPath,
          parserFn: _parserFn$Mutation$UpdateBackupPath,
        );

  final OnMutationCompleted$Mutation$UpdateBackupPath? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$UpdateBackupPath
    extends graphql.WatchQueryOptions<Mutation$UpdateBackupPath> {
  WatchOptions$Mutation$UpdateBackupPath({
    String? operationName,
    required Variables$Mutation$UpdateBackupPath variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateBackupPath? typedOptimisticResult,
    graphql.Context? context,
    Duration? pollInterval,
    bool? eagerlyFetchResults,
    bool carryForwardDataOnException = true,
    bool fetchResults = false,
  }) : super(
          variables: variables.toJson(),
          operationName: operationName,
          fetchPolicy: fetchPolicy,
          errorPolicy: errorPolicy,
          cacheRereadPolicy: cacheRereadPolicy,
          optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
          context: context,
          document: documentNodeMutationUpdateBackupPath,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$UpdateBackupPath,
        );
}

extension ClientExtension$Mutation$UpdateBackupPath on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$UpdateBackupPath>>
      mutate$UpdateBackupPath(
              Options$Mutation$UpdateBackupPath options) async =>
          await this.mutate(options);

  graphql.ObservableQuery<Mutation$UpdateBackupPath>
      watchMutation$UpdateBackupPath(
              WatchOptions$Mutation$UpdateBackupPath options) =>
          this.watchMutation(options);
}

class Mutation$UpdateBackupPath$HookResult {
  Mutation$UpdateBackupPath$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$UpdateBackupPath runMutation;

  final graphql.QueryResult<Mutation$UpdateBackupPath> result;
}

Mutation$UpdateBackupPath$HookResult useMutation$UpdateBackupPath(
    [WidgetOptions$Mutation$UpdateBackupPath? options]) {
  final result = graphql_flutter
      .useMutation(options ?? WidgetOptions$Mutation$UpdateBackupPath());
  return Mutation$UpdateBackupPath$HookResult(
    (variables, {optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables.toJson(),
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$UpdateBackupPath>
    useWatchMutation$UpdateBackupPath(
            WatchOptions$Mutation$UpdateBackupPath options) =>
        graphql_flutter.useWatchMutation(options);

class WidgetOptions$Mutation$UpdateBackupPath
    extends graphql.MutationOptions<Mutation$UpdateBackupPath> {
  WidgetOptions$Mutation$UpdateBackupPath({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateBackupPath? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateBackupPath? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateBackupPath>? update,
    graphql.OnError? onError,
  })  : onCompletedWithParsed = onCompleted,
        super(
          operationName: operationName,
          fetchPolicy: fetchPolicy,
          errorPolicy: errorPolicy,
          cacheRereadPolicy: cacheRereadPolicy,
          optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
          context: context,
          onCompleted: onCompleted == null
              ? null
              : (data) => onCompleted(
                    data,
                    data == null
                        ? null
                        : _parserFn$Mutation$UpdateBackupPath(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateBackupPath,
          parserFn: _parserFn$Mutation$UpdateBackupPath,
        );

  final OnMutationCompleted$Mutation$UpdateBackupPath? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$UpdateBackupPath
    = graphql.MultiSourceResult<Mutation$UpdateBackupPath> Function(
  Variables$Mutation$UpdateBackupPath, {
  Object? optimisticResult,
  Mutation$UpdateBackupPath? typedOptimisticResult,
});
typedef Builder$Mutation$UpdateBackupPath = widgets.Widget Function(
  RunMutation$Mutation$UpdateBackupPath,
  graphql.QueryResult<Mutation$UpdateBackupPath>?,
);

class Mutation$UpdateBackupPath$Widget
    extends graphql_flutter.Mutation<Mutation$UpdateBackupPath> {
  Mutation$UpdateBackupPath$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$UpdateBackupPath? options,
    required Builder$Mutation$UpdateBackupPath builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$UpdateBackupPath(),
          builder: (
            run,
            result,
          ) =>
              builder(
            (
              variables, {
              optimisticResult,
              typedOptimisticResult,
            }) =>
                run(
              variables.toJson(),
              optimisticResult:
                  optimisticResult ?? typedOptimisticResult?.toJson(),
            ),
            result,
          ),
        );
}

class Mutation$UpdateBackupPath$setSettings {
  Mutation$UpdateBackupPath$setSettings({
    required this.settings,
    this.$__typename = 'SetSettingsPayload',
  });

  factory Mutation$UpdateBackupPath$setSettings.fromJson(
      Map<String, dynamic> json) {
    final l$settings = json['settings'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateBackupPath$setSettings(
      settings:
          Fragment$SettingsDto.fromJson((l$settings as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Fragment$SettingsDto settings;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$settings = settings;
    _resultData['settings'] = l$settings.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$settings = settings;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$settings,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$UpdateBackupPath$setSettings ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$settings = settings;
    final lOther$settings = other.settings;
    if (l$settings != lOther$settings) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Mutation$UpdateBackupPath$setSettings
    on Mutation$UpdateBackupPath$setSettings {
  CopyWith$Mutation$UpdateBackupPath$setSettings<
          Mutation$UpdateBackupPath$setSettings>
      get copyWith => CopyWith$Mutation$UpdateBackupPath$setSettings(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdateBackupPath$setSettings<TRes> {
  factory CopyWith$Mutation$UpdateBackupPath$setSettings(
    Mutation$UpdateBackupPath$setSettings instance,
    TRes Function(Mutation$UpdateBackupPath$setSettings) then,
  ) = _CopyWithImpl$Mutation$UpdateBackupPath$setSettings;

  factory CopyWith$Mutation$UpdateBackupPath$setSettings.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateBackupPath$setSettings;

  TRes call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  });
  CopyWith$Fragment$SettingsDto<TRes> get settings;
}

class _CopyWithImpl$Mutation$UpdateBackupPath$setSettings<TRes>
    implements CopyWith$Mutation$UpdateBackupPath$setSettings<TRes> {
  _CopyWithImpl$Mutation$UpdateBackupPath$setSettings(
    this._instance,
    this._then,
  );

  final Mutation$UpdateBackupPath$setSettings _instance;

  final TRes Function(Mutation$UpdateBackupPath$setSettings) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? settings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateBackupPath$setSettings(
        settings: settings == _undefined || settings == null
            ? _instance.settings
            : (settings as Fragment$SettingsDto),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Fragment$SettingsDto<TRes> get settings {
    final local$settings = _instance.settings;
    return CopyWith$Fragment$SettingsDto(
        local$settings, (e) => call(settings: e));
  }
}

class _CopyWithStubImpl$Mutation$UpdateBackupPath$setSettings<TRes>
    implements CopyWith$Mutation$UpdateBackupPath$setSettings<TRes> {
  _CopyWithStubImpl$Mutation$UpdateBackupPath$setSettings(this._res);

  TRes _res;

  call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$SettingsDto<TRes> get settings =>
      CopyWith$Fragment$SettingsDto.stub(_res);
}

class Variables$Mutation$UpdateBackupInterval {
  factory Variables$Mutation$UpdateBackupInterval({int? backupInterval}) =>
      Variables$Mutation$UpdateBackupInterval._({
        if (backupInterval != null) r'backupInterval': backupInterval,
      });

  Variables$Mutation$UpdateBackupInterval._(this._$data);

  factory Variables$Mutation$UpdateBackupInterval.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('backupInterval')) {
      final l$backupInterval = data['backupInterval'];
      result$data['backupInterval'] = (l$backupInterval as int?);
    }
    return Variables$Mutation$UpdateBackupInterval._(result$data);
  }

  Map<String, dynamic> _$data;

  int? get backupInterval => (_$data['backupInterval'] as int?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('backupInterval')) {
      final l$backupInterval = backupInterval;
      result$data['backupInterval'] = l$backupInterval;
    }
    return result$data;
  }

  CopyWith$Variables$Mutation$UpdateBackupInterval<
          Variables$Mutation$UpdateBackupInterval>
      get copyWith => CopyWith$Variables$Mutation$UpdateBackupInterval(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$UpdateBackupInterval ||
        runtimeType != other.runtimeType) {
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
    return true;
  }

  @override
  int get hashCode {
    final l$backupInterval = backupInterval;
    return Object.hashAll(
        [_$data.containsKey('backupInterval') ? l$backupInterval : const {}]);
  }
}

abstract class CopyWith$Variables$Mutation$UpdateBackupInterval<TRes> {
  factory CopyWith$Variables$Mutation$UpdateBackupInterval(
    Variables$Mutation$UpdateBackupInterval instance,
    TRes Function(Variables$Mutation$UpdateBackupInterval) then,
  ) = _CopyWithImpl$Variables$Mutation$UpdateBackupInterval;

  factory CopyWith$Variables$Mutation$UpdateBackupInterval.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$UpdateBackupInterval;

  TRes call({int? backupInterval});
}

class _CopyWithImpl$Variables$Mutation$UpdateBackupInterval<TRes>
    implements CopyWith$Variables$Mutation$UpdateBackupInterval<TRes> {
  _CopyWithImpl$Variables$Mutation$UpdateBackupInterval(
    this._instance,
    this._then,
  );

  final Variables$Mutation$UpdateBackupInterval _instance;

  final TRes Function(Variables$Mutation$UpdateBackupInterval) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? backupInterval = _undefined}) =>
      _then(Variables$Mutation$UpdateBackupInterval._({
        ..._instance._$data,
        if (backupInterval != _undefined)
          'backupInterval': (backupInterval as int?),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$UpdateBackupInterval<TRes>
    implements CopyWith$Variables$Mutation$UpdateBackupInterval<TRes> {
  _CopyWithStubImpl$Variables$Mutation$UpdateBackupInterval(this._res);

  TRes _res;

  call({int? backupInterval}) => _res;
}

class Mutation$UpdateBackupInterval {
  Mutation$UpdateBackupInterval({
    required this.setSettings,
    this.$__typename = 'Mutation',
  });

  factory Mutation$UpdateBackupInterval.fromJson(Map<String, dynamic> json) {
    final l$setSettings = json['setSettings'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateBackupInterval(
      setSettings: Mutation$UpdateBackupInterval$setSettings.fromJson(
          (l$setSettings as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$UpdateBackupInterval$setSettings setSettings;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$setSettings = setSettings;
    _resultData['setSettings'] = l$setSettings.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$setSettings = setSettings;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$setSettings,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$UpdateBackupInterval ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$setSettings = setSettings;
    final lOther$setSettings = other.setSettings;
    if (l$setSettings != lOther$setSettings) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Mutation$UpdateBackupInterval
    on Mutation$UpdateBackupInterval {
  CopyWith$Mutation$UpdateBackupInterval<Mutation$UpdateBackupInterval>
      get copyWith => CopyWith$Mutation$UpdateBackupInterval(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdateBackupInterval<TRes> {
  factory CopyWith$Mutation$UpdateBackupInterval(
    Mutation$UpdateBackupInterval instance,
    TRes Function(Mutation$UpdateBackupInterval) then,
  ) = _CopyWithImpl$Mutation$UpdateBackupInterval;

  factory CopyWith$Mutation$UpdateBackupInterval.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateBackupInterval;

  TRes call({
    Mutation$UpdateBackupInterval$setSettings? setSettings,
    String? $__typename,
  });
  CopyWith$Mutation$UpdateBackupInterval$setSettings<TRes> get setSettings;
}

class _CopyWithImpl$Mutation$UpdateBackupInterval<TRes>
    implements CopyWith$Mutation$UpdateBackupInterval<TRes> {
  _CopyWithImpl$Mutation$UpdateBackupInterval(
    this._instance,
    this._then,
  );

  final Mutation$UpdateBackupInterval _instance;

  final TRes Function(Mutation$UpdateBackupInterval) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? setSettings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateBackupInterval(
        setSettings: setSettings == _undefined || setSettings == null
            ? _instance.setSettings
            : (setSettings as Mutation$UpdateBackupInterval$setSettings),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$UpdateBackupInterval$setSettings<TRes> get setSettings {
    final local$setSettings = _instance.setSettings;
    return CopyWith$Mutation$UpdateBackupInterval$setSettings(
        local$setSettings, (e) => call(setSettings: e));
  }
}

class _CopyWithStubImpl$Mutation$UpdateBackupInterval<TRes>
    implements CopyWith$Mutation$UpdateBackupInterval<TRes> {
  _CopyWithStubImpl$Mutation$UpdateBackupInterval(this._res);

  TRes _res;

  call({
    Mutation$UpdateBackupInterval$setSettings? setSettings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$UpdateBackupInterval$setSettings<TRes> get setSettings =>
      CopyWith$Mutation$UpdateBackupInterval$setSettings.stub(_res);
}

const documentNodeMutationUpdateBackupInterval = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'UpdateBackupInterval'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'backupInterval')),
        type: NamedTypeNode(
          name: NameNode(value: 'Int'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: IntValueNode(value: '1')),
        directives: [],
      )
    ],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'setSettings'),
        alias: null,
        arguments: [
          ArgumentNode(
            name: NameNode(value: 'input'),
            value: ObjectValueNode(fields: [
              ObjectFieldNode(
                name: NameNode(value: 'settings'),
                value: ObjectValueNode(fields: [
                  ObjectFieldNode(
                    name: NameNode(value: 'backupInterval'),
                    value:
                        VariableNode(name: NameNode(value: 'backupInterval')),
                  )
                ]),
              )
            ]),
          )
        ],
        directives: [],
        selectionSet: SelectionSetNode(selections: [
          FieldNode(
            name: NameNode(value: 'settings'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: SelectionSetNode(selections: [
              FragmentSpreadNode(
                name: NameNode(value: 'SettingsDto'),
                directives: [],
              ),
              FieldNode(
                name: NameNode(value: '__typename'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
            ]),
          ),
          FieldNode(
            name: NameNode(value: '__typename'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null,
          ),
        ]),
      ),
      FieldNode(
        name: NameNode(value: '__typename'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
    ]),
  ),
  fragmentDefinitionSettingsDto,
  fragmentDefinitionAutomaticBackupSettingsDto,
  fragmentDefinitionServerBindingDto,
  fragmentDefinitionSocksProxyDto,
  fragmentDefinitionCloudFlareBypassDto,
  fragmentDefinitionMiscSettingsDto,
  fragmentDefinitionBrowserSettingsDto,
  fragmentDefinitionLibrarySettingsDto,
  fragmentDefinitionDownloadsSettingsDto,
]);
Mutation$UpdateBackupInterval _parserFn$Mutation$UpdateBackupInterval(
        Map<String, dynamic> data) =>
    Mutation$UpdateBackupInterval.fromJson(data);
typedef OnMutationCompleted$Mutation$UpdateBackupInterval = FutureOr<void>
    Function(
  Map<String, dynamic>?,
  Mutation$UpdateBackupInterval?,
);

class Options$Mutation$UpdateBackupInterval
    extends graphql.MutationOptions<Mutation$UpdateBackupInterval> {
  Options$Mutation$UpdateBackupInterval({
    String? operationName,
    Variables$Mutation$UpdateBackupInterval? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateBackupInterval? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateBackupInterval? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateBackupInterval>? update,
    graphql.OnError? onError,
  })  : onCompletedWithParsed = onCompleted,
        super(
          variables: variables?.toJson() ?? {},
          operationName: operationName,
          fetchPolicy: fetchPolicy,
          errorPolicy: errorPolicy,
          cacheRereadPolicy: cacheRereadPolicy,
          optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
          context: context,
          onCompleted: onCompleted == null
              ? null
              : (data) => onCompleted(
                    data,
                    data == null
                        ? null
                        : _parserFn$Mutation$UpdateBackupInterval(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateBackupInterval,
          parserFn: _parserFn$Mutation$UpdateBackupInterval,
        );

  final OnMutationCompleted$Mutation$UpdateBackupInterval?
      onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$UpdateBackupInterval
    extends graphql.WatchQueryOptions<Mutation$UpdateBackupInterval> {
  WatchOptions$Mutation$UpdateBackupInterval({
    String? operationName,
    Variables$Mutation$UpdateBackupInterval? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateBackupInterval? typedOptimisticResult,
    graphql.Context? context,
    Duration? pollInterval,
    bool? eagerlyFetchResults,
    bool carryForwardDataOnException = true,
    bool fetchResults = false,
  }) : super(
          variables: variables?.toJson() ?? {},
          operationName: operationName,
          fetchPolicy: fetchPolicy,
          errorPolicy: errorPolicy,
          cacheRereadPolicy: cacheRereadPolicy,
          optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
          context: context,
          document: documentNodeMutationUpdateBackupInterval,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$UpdateBackupInterval,
        );
}

extension ClientExtension$Mutation$UpdateBackupInterval
    on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$UpdateBackupInterval>>
      mutate$UpdateBackupInterval(
              [Options$Mutation$UpdateBackupInterval? options]) async =>
          await this.mutate(options ?? Options$Mutation$UpdateBackupInterval());

  graphql.ObservableQuery<Mutation$UpdateBackupInterval>
      watchMutation$UpdateBackupInterval(
              [WatchOptions$Mutation$UpdateBackupInterval? options]) =>
          this.watchMutation(
              options ?? WatchOptions$Mutation$UpdateBackupInterval());
}

class Mutation$UpdateBackupInterval$HookResult {
  Mutation$UpdateBackupInterval$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$UpdateBackupInterval runMutation;

  final graphql.QueryResult<Mutation$UpdateBackupInterval> result;
}

Mutation$UpdateBackupInterval$HookResult useMutation$UpdateBackupInterval(
    [WidgetOptions$Mutation$UpdateBackupInterval? options]) {
  final result = graphql_flutter
      .useMutation(options ?? WidgetOptions$Mutation$UpdateBackupInterval());
  return Mutation$UpdateBackupInterval$HookResult(
    ({variables, optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables?.toJson() ?? const {},
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$UpdateBackupInterval>
    useWatchMutation$UpdateBackupInterval(
            [WatchOptions$Mutation$UpdateBackupInterval? options]) =>
        graphql_flutter.useWatchMutation(
            options ?? WatchOptions$Mutation$UpdateBackupInterval());

class WidgetOptions$Mutation$UpdateBackupInterval
    extends graphql.MutationOptions<Mutation$UpdateBackupInterval> {
  WidgetOptions$Mutation$UpdateBackupInterval({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateBackupInterval? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateBackupInterval? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateBackupInterval>? update,
    graphql.OnError? onError,
  })  : onCompletedWithParsed = onCompleted,
        super(
          operationName: operationName,
          fetchPolicy: fetchPolicy,
          errorPolicy: errorPolicy,
          cacheRereadPolicy: cacheRereadPolicy,
          optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
          context: context,
          onCompleted: onCompleted == null
              ? null
              : (data) => onCompleted(
                    data,
                    data == null
                        ? null
                        : _parserFn$Mutation$UpdateBackupInterval(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateBackupInterval,
          parserFn: _parserFn$Mutation$UpdateBackupInterval,
        );

  final OnMutationCompleted$Mutation$UpdateBackupInterval?
      onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$UpdateBackupInterval
    = graphql.MultiSourceResult<Mutation$UpdateBackupInterval> Function({
  Variables$Mutation$UpdateBackupInterval? variables,
  Object? optimisticResult,
  Mutation$UpdateBackupInterval? typedOptimisticResult,
});
typedef Builder$Mutation$UpdateBackupInterval = widgets.Widget Function(
  RunMutation$Mutation$UpdateBackupInterval,
  graphql.QueryResult<Mutation$UpdateBackupInterval>?,
);

class Mutation$UpdateBackupInterval$Widget
    extends graphql_flutter.Mutation<Mutation$UpdateBackupInterval> {
  Mutation$UpdateBackupInterval$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$UpdateBackupInterval? options,
    required Builder$Mutation$UpdateBackupInterval builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$UpdateBackupInterval(),
          builder: (
            run,
            result,
          ) =>
              builder(
            ({
              variables,
              optimisticResult,
              typedOptimisticResult,
            }) =>
                run(
              variables?.toJson() ?? const {},
              optimisticResult:
                  optimisticResult ?? typedOptimisticResult?.toJson(),
            ),
            result,
          ),
        );
}

class Mutation$UpdateBackupInterval$setSettings {
  Mutation$UpdateBackupInterval$setSettings({
    required this.settings,
    this.$__typename = 'SetSettingsPayload',
  });

  factory Mutation$UpdateBackupInterval$setSettings.fromJson(
      Map<String, dynamic> json) {
    final l$settings = json['settings'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateBackupInterval$setSettings(
      settings:
          Fragment$SettingsDto.fromJson((l$settings as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Fragment$SettingsDto settings;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$settings = settings;
    _resultData['settings'] = l$settings.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$settings = settings;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$settings,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$UpdateBackupInterval$setSettings ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$settings = settings;
    final lOther$settings = other.settings;
    if (l$settings != lOther$settings) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Mutation$UpdateBackupInterval$setSettings
    on Mutation$UpdateBackupInterval$setSettings {
  CopyWith$Mutation$UpdateBackupInterval$setSettings<
          Mutation$UpdateBackupInterval$setSettings>
      get copyWith => CopyWith$Mutation$UpdateBackupInterval$setSettings(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdateBackupInterval$setSettings<TRes> {
  factory CopyWith$Mutation$UpdateBackupInterval$setSettings(
    Mutation$UpdateBackupInterval$setSettings instance,
    TRes Function(Mutation$UpdateBackupInterval$setSettings) then,
  ) = _CopyWithImpl$Mutation$UpdateBackupInterval$setSettings;

  factory CopyWith$Mutation$UpdateBackupInterval$setSettings.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateBackupInterval$setSettings;

  TRes call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  });
  CopyWith$Fragment$SettingsDto<TRes> get settings;
}

class _CopyWithImpl$Mutation$UpdateBackupInterval$setSettings<TRes>
    implements CopyWith$Mutation$UpdateBackupInterval$setSettings<TRes> {
  _CopyWithImpl$Mutation$UpdateBackupInterval$setSettings(
    this._instance,
    this._then,
  );

  final Mutation$UpdateBackupInterval$setSettings _instance;

  final TRes Function(Mutation$UpdateBackupInterval$setSettings) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? settings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateBackupInterval$setSettings(
        settings: settings == _undefined || settings == null
            ? _instance.settings
            : (settings as Fragment$SettingsDto),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Fragment$SettingsDto<TRes> get settings {
    final local$settings = _instance.settings;
    return CopyWith$Fragment$SettingsDto(
        local$settings, (e) => call(settings: e));
  }
}

class _CopyWithStubImpl$Mutation$UpdateBackupInterval$setSettings<TRes>
    implements CopyWith$Mutation$UpdateBackupInterval$setSettings<TRes> {
  _CopyWithStubImpl$Mutation$UpdateBackupInterval$setSettings(this._res);

  TRes _res;

  call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$SettingsDto<TRes> get settings =>
      CopyWith$Fragment$SettingsDto.stub(_res);
}

class Variables$Query$RestoreStatus {
  factory Variables$Query$RestoreStatus({required String restoreId}) =>
      Variables$Query$RestoreStatus._({
        r'restoreId': restoreId,
      });

  Variables$Query$RestoreStatus._(this._$data);

  factory Variables$Query$RestoreStatus.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$restoreId = data['restoreId'];
    result$data['restoreId'] = (l$restoreId as String);
    return Variables$Query$RestoreStatus._(result$data);
  }

  Map<String, dynamic> _$data;

  String get restoreId => (_$data['restoreId'] as String);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$restoreId = restoreId;
    result$data['restoreId'] = l$restoreId;
    return result$data;
  }

  CopyWith$Variables$Query$RestoreStatus<Variables$Query$RestoreStatus>
      get copyWith => CopyWith$Variables$Query$RestoreStatus(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Query$RestoreStatus ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$restoreId = restoreId;
    final lOther$restoreId = other.restoreId;
    if (l$restoreId != lOther$restoreId) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$restoreId = restoreId;
    return Object.hashAll([l$restoreId]);
  }
}

abstract class CopyWith$Variables$Query$RestoreStatus<TRes> {
  factory CopyWith$Variables$Query$RestoreStatus(
    Variables$Query$RestoreStatus instance,
    TRes Function(Variables$Query$RestoreStatus) then,
  ) = _CopyWithImpl$Variables$Query$RestoreStatus;

  factory CopyWith$Variables$Query$RestoreStatus.stub(TRes res) =
      _CopyWithStubImpl$Variables$Query$RestoreStatus;

  TRes call({String? restoreId});
}

class _CopyWithImpl$Variables$Query$RestoreStatus<TRes>
    implements CopyWith$Variables$Query$RestoreStatus<TRes> {
  _CopyWithImpl$Variables$Query$RestoreStatus(
    this._instance,
    this._then,
  );

  final Variables$Query$RestoreStatus _instance;

  final TRes Function(Variables$Query$RestoreStatus) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? restoreId = _undefined}) =>
      _then(Variables$Query$RestoreStatus._({
        ..._instance._$data,
        if (restoreId != _undefined && restoreId != null)
          'restoreId': (restoreId as String),
      }));
}

class _CopyWithStubImpl$Variables$Query$RestoreStatus<TRes>
    implements CopyWith$Variables$Query$RestoreStatus<TRes> {
  _CopyWithStubImpl$Variables$Query$RestoreStatus(this._res);

  TRes _res;

  call({String? restoreId}) => _res;
}

class Query$RestoreStatus {
  Query$RestoreStatus({
    this.restoreStatus,
    this.$__typename = 'Query',
  });

  factory Query$RestoreStatus.fromJson(Map<String, dynamic> json) {
    final l$restoreStatus = json['restoreStatus'];
    final l$$__typename = json['__typename'];
    return Query$RestoreStatus(
      restoreStatus: l$restoreStatus == null
          ? null
          : Fragment$RestoreStatusDto.fromJson(
              (l$restoreStatus as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Fragment$RestoreStatusDto? restoreStatus;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$restoreStatus = restoreStatus;
    _resultData['restoreStatus'] = l$restoreStatus?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$restoreStatus = restoreStatus;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$restoreStatus,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$RestoreStatus || runtimeType != other.runtimeType) {
      return false;
    }
    final l$restoreStatus = restoreStatus;
    final lOther$restoreStatus = other.restoreStatus;
    if (l$restoreStatus != lOther$restoreStatus) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Query$RestoreStatus on Query$RestoreStatus {
  CopyWith$Query$RestoreStatus<Query$RestoreStatus> get copyWith =>
      CopyWith$Query$RestoreStatus(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Query$RestoreStatus<TRes> {
  factory CopyWith$Query$RestoreStatus(
    Query$RestoreStatus instance,
    TRes Function(Query$RestoreStatus) then,
  ) = _CopyWithImpl$Query$RestoreStatus;

  factory CopyWith$Query$RestoreStatus.stub(TRes res) =
      _CopyWithStubImpl$Query$RestoreStatus;

  TRes call({
    Fragment$RestoreStatusDto? restoreStatus,
    String? $__typename,
  });
  CopyWith$Fragment$RestoreStatusDto<TRes> get restoreStatus;
}

class _CopyWithImpl$Query$RestoreStatus<TRes>
    implements CopyWith$Query$RestoreStatus<TRes> {
  _CopyWithImpl$Query$RestoreStatus(
    this._instance,
    this._then,
  );

  final Query$RestoreStatus _instance;

  final TRes Function(Query$RestoreStatus) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? restoreStatus = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$RestoreStatus(
        restoreStatus: restoreStatus == _undefined
            ? _instance.restoreStatus
            : (restoreStatus as Fragment$RestoreStatusDto?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Fragment$RestoreStatusDto<TRes> get restoreStatus {
    final local$restoreStatus = _instance.restoreStatus;
    return local$restoreStatus == null
        ? CopyWith$Fragment$RestoreStatusDto.stub(_then(_instance))
        : CopyWith$Fragment$RestoreStatusDto(
            local$restoreStatus, (e) => call(restoreStatus: e));
  }
}

class _CopyWithStubImpl$Query$RestoreStatus<TRes>
    implements CopyWith$Query$RestoreStatus<TRes> {
  _CopyWithStubImpl$Query$RestoreStatus(this._res);

  TRes _res;

  call({
    Fragment$RestoreStatusDto? restoreStatus,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$RestoreStatusDto<TRes> get restoreStatus =>
      CopyWith$Fragment$RestoreStatusDto.stub(_res);
}

const documentNodeQueryRestoreStatus = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.query,
    name: NameNode(value: 'RestoreStatus'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'restoreId')),
        type: NamedTypeNode(
          name: NameNode(value: 'String'),
          isNonNull: true,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      )
    ],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'restoreStatus'),
        alias: null,
        arguments: [
          ArgumentNode(
            name: NameNode(value: 'id'),
            value: VariableNode(name: NameNode(value: 'restoreId')),
          )
        ],
        directives: [],
        selectionSet: SelectionSetNode(selections: [
          FragmentSpreadNode(
            name: NameNode(value: 'RestoreStatusDto'),
            directives: [],
          ),
          FieldNode(
            name: NameNode(value: '__typename'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null,
          ),
        ]),
      ),
      FieldNode(
        name: NameNode(value: '__typename'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
    ]),
  ),
  fragmentDefinitionRestoreStatusDto,
]);
Query$RestoreStatus _parserFn$Query$RestoreStatus(Map<String, dynamic> data) =>
    Query$RestoreStatus.fromJson(data);
typedef OnQueryComplete$Query$RestoreStatus = FutureOr<void> Function(
  Map<String, dynamic>?,
  Query$RestoreStatus?,
);

class Options$Query$RestoreStatus
    extends graphql.QueryOptions<Query$RestoreStatus> {
  Options$Query$RestoreStatus({
    String? operationName,
    required Variables$Query$RestoreStatus variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$RestoreStatus? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$RestoreStatus? onComplete,
    graphql.OnQueryError? onError,
  })  : onCompleteWithParsed = onComplete,
        super(
          variables: variables.toJson(),
          operationName: operationName,
          fetchPolicy: fetchPolicy,
          errorPolicy: errorPolicy,
          cacheRereadPolicy: cacheRereadPolicy,
          optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
          pollInterval: pollInterval,
          context: context,
          onComplete: onComplete == null
              ? null
              : (data) => onComplete(
                    data,
                    data == null ? null : _parserFn$Query$RestoreStatus(data),
                  ),
          onError: onError,
          document: documentNodeQueryRestoreStatus,
          parserFn: _parserFn$Query$RestoreStatus,
        );

  final OnQueryComplete$Query$RestoreStatus? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onComplete == null
            ? super.properties
            : super.properties.where((property) => property != onComplete),
        onCompleteWithParsed,
      ];
}

class WatchOptions$Query$RestoreStatus
    extends graphql.WatchQueryOptions<Query$RestoreStatus> {
  WatchOptions$Query$RestoreStatus({
    String? operationName,
    required Variables$Query$RestoreStatus variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$RestoreStatus? typedOptimisticResult,
    graphql.Context? context,
    Duration? pollInterval,
    bool? eagerlyFetchResults,
    bool carryForwardDataOnException = true,
    bool fetchResults = false,
  }) : super(
          variables: variables.toJson(),
          operationName: operationName,
          fetchPolicy: fetchPolicy,
          errorPolicy: errorPolicy,
          cacheRereadPolicy: cacheRereadPolicy,
          optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
          context: context,
          document: documentNodeQueryRestoreStatus,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Query$RestoreStatus,
        );
}

class FetchMoreOptions$Query$RestoreStatus extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$RestoreStatus({
    required graphql.UpdateQuery updateQuery,
    required Variables$Query$RestoreStatus variables,
  }) : super(
          updateQuery: updateQuery,
          variables: variables.toJson(),
          document: documentNodeQueryRestoreStatus,
        );
}

extension ClientExtension$Query$RestoreStatus on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$RestoreStatus>> query$RestoreStatus(
          Options$Query$RestoreStatus options) async =>
      await this.query(options);

  graphql.ObservableQuery<Query$RestoreStatus> watchQuery$RestoreStatus(
          WatchOptions$Query$RestoreStatus options) =>
      this.watchQuery(options);

  void writeQuery$RestoreStatus({
    required Query$RestoreStatus data,
    required Variables$Query$RestoreStatus variables,
    bool broadcast = true,
  }) =>
      this.writeQuery(
        graphql.Request(
          operation:
              graphql.Operation(document: documentNodeQueryRestoreStatus),
          variables: variables.toJson(),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );

  Query$RestoreStatus? readQuery$RestoreStatus({
    required Variables$Query$RestoreStatus variables,
    bool optimistic = true,
  }) {
    final result = this.readQuery(
      graphql.Request(
        operation: graphql.Operation(document: documentNodeQueryRestoreStatus),
        variables: variables.toJson(),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Query$RestoreStatus.fromJson(result);
  }
}

graphql_flutter.QueryHookResult<Query$RestoreStatus> useQuery$RestoreStatus(
        Options$Query$RestoreStatus options) =>
    graphql_flutter.useQuery(options);
graphql.ObservableQuery<Query$RestoreStatus> useWatchQuery$RestoreStatus(
        WatchOptions$Query$RestoreStatus options) =>
    graphql_flutter.useWatchQuery(options);

class Query$RestoreStatus$Widget
    extends graphql_flutter.Query<Query$RestoreStatus> {
  Query$RestoreStatus$Widget({
    widgets.Key? key,
    required Options$Query$RestoreStatus options,
    required graphql_flutter.QueryBuilder<Query$RestoreStatus> builder,
  }) : super(
          key: key,
          options: options,
          builder: builder,
        );
}

class Variables$Mutation$RestoreBackup {
  factory Variables$Mutation$RestoreBackup({required MultipartFile backup}) =>
      Variables$Mutation$RestoreBackup._({
        r'backup': backup,
      });

  Variables$Mutation$RestoreBackup._(this._$data);

  factory Variables$Mutation$RestoreBackup.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$backup = data['backup'];
    result$data['backup'] = fileFromJson(l$backup);
    return Variables$Mutation$RestoreBackup._(result$data);
  }

  Map<String, dynamic> _$data;

  MultipartFile get backup => (_$data['backup'] as MultipartFile);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$backup = backup;
    result$data['backup'] = fileToJson(l$backup);
    return result$data;
  }

  CopyWith$Variables$Mutation$RestoreBackup<Variables$Mutation$RestoreBackup>
      get copyWith => CopyWith$Variables$Mutation$RestoreBackup(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$RestoreBackup ||
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

abstract class CopyWith$Variables$Mutation$RestoreBackup<TRes> {
  factory CopyWith$Variables$Mutation$RestoreBackup(
    Variables$Mutation$RestoreBackup instance,
    TRes Function(Variables$Mutation$RestoreBackup) then,
  ) = _CopyWithImpl$Variables$Mutation$RestoreBackup;

  factory CopyWith$Variables$Mutation$RestoreBackup.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$RestoreBackup;

  TRes call({MultipartFile? backup});
}

class _CopyWithImpl$Variables$Mutation$RestoreBackup<TRes>
    implements CopyWith$Variables$Mutation$RestoreBackup<TRes> {
  _CopyWithImpl$Variables$Mutation$RestoreBackup(
    this._instance,
    this._then,
  );

  final Variables$Mutation$RestoreBackup _instance;

  final TRes Function(Variables$Mutation$RestoreBackup) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? backup = _undefined}) =>
      _then(Variables$Mutation$RestoreBackup._({
        ..._instance._$data,
        if (backup != _undefined && backup != null)
          'backup': (backup as MultipartFile),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$RestoreBackup<TRes>
    implements CopyWith$Variables$Mutation$RestoreBackup<TRes> {
  _CopyWithStubImpl$Variables$Mutation$RestoreBackup(this._res);

  TRes _res;

  call({MultipartFile? backup}) => _res;
}

class Mutation$RestoreBackup {
  Mutation$RestoreBackup({
    required this.restoreBackup,
    this.$__typename = 'Mutation',
  });

  factory Mutation$RestoreBackup.fromJson(Map<String, dynamic> json) {
    final l$restoreBackup = json['restoreBackup'];
    final l$$__typename = json['__typename'];
    return Mutation$RestoreBackup(
      restoreBackup: Mutation$RestoreBackup$restoreBackup.fromJson(
          (l$restoreBackup as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$RestoreBackup$restoreBackup restoreBackup;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$restoreBackup = restoreBackup;
    _resultData['restoreBackup'] = l$restoreBackup.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$restoreBackup = restoreBackup;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$restoreBackup,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$RestoreBackup || runtimeType != other.runtimeType) {
      return false;
    }
    final l$restoreBackup = restoreBackup;
    final lOther$restoreBackup = other.restoreBackup;
    if (l$restoreBackup != lOther$restoreBackup) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Mutation$RestoreBackup on Mutation$RestoreBackup {
  CopyWith$Mutation$RestoreBackup<Mutation$RestoreBackup> get copyWith =>
      CopyWith$Mutation$RestoreBackup(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Mutation$RestoreBackup<TRes> {
  factory CopyWith$Mutation$RestoreBackup(
    Mutation$RestoreBackup instance,
    TRes Function(Mutation$RestoreBackup) then,
  ) = _CopyWithImpl$Mutation$RestoreBackup;

  factory CopyWith$Mutation$RestoreBackup.stub(TRes res) =
      _CopyWithStubImpl$Mutation$RestoreBackup;

  TRes call({
    Mutation$RestoreBackup$restoreBackup? restoreBackup,
    String? $__typename,
  });
  CopyWith$Mutation$RestoreBackup$restoreBackup<TRes> get restoreBackup;
}

class _CopyWithImpl$Mutation$RestoreBackup<TRes>
    implements CopyWith$Mutation$RestoreBackup<TRes> {
  _CopyWithImpl$Mutation$RestoreBackup(
    this._instance,
    this._then,
  );

  final Mutation$RestoreBackup _instance;

  final TRes Function(Mutation$RestoreBackup) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? restoreBackup = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$RestoreBackup(
        restoreBackup: restoreBackup == _undefined || restoreBackup == null
            ? _instance.restoreBackup
            : (restoreBackup as Mutation$RestoreBackup$restoreBackup),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$RestoreBackup$restoreBackup<TRes> get restoreBackup {
    final local$restoreBackup = _instance.restoreBackup;
    return CopyWith$Mutation$RestoreBackup$restoreBackup(
        local$restoreBackup, (e) => call(restoreBackup: e));
  }
}

class _CopyWithStubImpl$Mutation$RestoreBackup<TRes>
    implements CopyWith$Mutation$RestoreBackup<TRes> {
  _CopyWithStubImpl$Mutation$RestoreBackup(this._res);

  TRes _res;

  call({
    Mutation$RestoreBackup$restoreBackup? restoreBackup,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$RestoreBackup$restoreBackup<TRes> get restoreBackup =>
      CopyWith$Mutation$RestoreBackup$restoreBackup.stub(_res);
}

const documentNodeMutationRestoreBackup = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'RestoreBackup'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'backup')),
        type: NamedTypeNode(
          name: NameNode(value: 'Upload'),
          isNonNull: true,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      )
    ],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'restoreBackup'),
        alias: null,
        arguments: [
          ArgumentNode(
            name: NameNode(value: 'input'),
            value: ObjectValueNode(fields: [
              ObjectFieldNode(
                name: NameNode(value: 'backup'),
                value: VariableNode(name: NameNode(value: 'backup')),
              )
            ]),
          )
        ],
        directives: [],
        selectionSet: SelectionSetNode(selections: [
          FieldNode(
            name: NameNode(value: 'clientMutationId'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null,
          ),
          FieldNode(
            name: NameNode(value: 'id'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null,
          ),
          FieldNode(
            name: NameNode(value: 'status'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: SelectionSetNode(selections: [
              FragmentSpreadNode(
                name: NameNode(value: 'RestoreStatusDto'),
                directives: [],
              ),
              FieldNode(
                name: NameNode(value: '__typename'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
            ]),
          ),
          FieldNode(
            name: NameNode(value: '__typename'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null,
          ),
        ]),
      ),
      FieldNode(
        name: NameNode(value: '__typename'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
    ]),
  ),
  fragmentDefinitionRestoreStatusDto,
]);
Mutation$RestoreBackup _parserFn$Mutation$RestoreBackup(
        Map<String, dynamic> data) =>
    Mutation$RestoreBackup.fromJson(data);
typedef OnMutationCompleted$Mutation$RestoreBackup = FutureOr<void> Function(
  Map<String, dynamic>?,
  Mutation$RestoreBackup?,
);

class Options$Mutation$RestoreBackup
    extends graphql.MutationOptions<Mutation$RestoreBackup> {
  Options$Mutation$RestoreBackup({
    String? operationName,
    required Variables$Mutation$RestoreBackup variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$RestoreBackup? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$RestoreBackup? onCompleted,
    graphql.OnMutationUpdate<Mutation$RestoreBackup>? update,
    graphql.OnError? onError,
  })  : onCompletedWithParsed = onCompleted,
        super(
          variables: variables.toJson(),
          operationName: operationName,
          fetchPolicy: fetchPolicy,
          errorPolicy: errorPolicy,
          cacheRereadPolicy: cacheRereadPolicy,
          optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
          context: context,
          onCompleted: onCompleted == null
              ? null
              : (data) => onCompleted(
                    data,
                    data == null
                        ? null
                        : _parserFn$Mutation$RestoreBackup(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationRestoreBackup,
          parserFn: _parserFn$Mutation$RestoreBackup,
        );

  final OnMutationCompleted$Mutation$RestoreBackup? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$RestoreBackup
    extends graphql.WatchQueryOptions<Mutation$RestoreBackup> {
  WatchOptions$Mutation$RestoreBackup({
    String? operationName,
    required Variables$Mutation$RestoreBackup variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$RestoreBackup? typedOptimisticResult,
    graphql.Context? context,
    Duration? pollInterval,
    bool? eagerlyFetchResults,
    bool carryForwardDataOnException = true,
    bool fetchResults = false,
  }) : super(
          variables: variables.toJson(),
          operationName: operationName,
          fetchPolicy: fetchPolicy,
          errorPolicy: errorPolicy,
          cacheRereadPolicy: cacheRereadPolicy,
          optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
          context: context,
          document: documentNodeMutationRestoreBackup,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$RestoreBackup,
        );
}

extension ClientExtension$Mutation$RestoreBackup on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$RestoreBackup>> mutate$RestoreBackup(
          Options$Mutation$RestoreBackup options) async =>
      await this.mutate(options);

  graphql.ObservableQuery<Mutation$RestoreBackup> watchMutation$RestoreBackup(
          WatchOptions$Mutation$RestoreBackup options) =>
      this.watchMutation(options);
}

class Mutation$RestoreBackup$HookResult {
  Mutation$RestoreBackup$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$RestoreBackup runMutation;

  final graphql.QueryResult<Mutation$RestoreBackup> result;
}

Mutation$RestoreBackup$HookResult useMutation$RestoreBackup(
    [WidgetOptions$Mutation$RestoreBackup? options]) {
  final result = graphql_flutter
      .useMutation(options ?? WidgetOptions$Mutation$RestoreBackup());
  return Mutation$RestoreBackup$HookResult(
    (variables, {optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables.toJson(),
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$RestoreBackup> useWatchMutation$RestoreBackup(
        WatchOptions$Mutation$RestoreBackup options) =>
    graphql_flutter.useWatchMutation(options);

class WidgetOptions$Mutation$RestoreBackup
    extends graphql.MutationOptions<Mutation$RestoreBackup> {
  WidgetOptions$Mutation$RestoreBackup({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$RestoreBackup? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$RestoreBackup? onCompleted,
    graphql.OnMutationUpdate<Mutation$RestoreBackup>? update,
    graphql.OnError? onError,
  })  : onCompletedWithParsed = onCompleted,
        super(
          operationName: operationName,
          fetchPolicy: fetchPolicy,
          errorPolicy: errorPolicy,
          cacheRereadPolicy: cacheRereadPolicy,
          optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
          context: context,
          onCompleted: onCompleted == null
              ? null
              : (data) => onCompleted(
                    data,
                    data == null
                        ? null
                        : _parserFn$Mutation$RestoreBackup(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationRestoreBackup,
          parserFn: _parserFn$Mutation$RestoreBackup,
        );

  final OnMutationCompleted$Mutation$RestoreBackup? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$RestoreBackup
    = graphql.MultiSourceResult<Mutation$RestoreBackup> Function(
  Variables$Mutation$RestoreBackup, {
  Object? optimisticResult,
  Mutation$RestoreBackup? typedOptimisticResult,
});
typedef Builder$Mutation$RestoreBackup = widgets.Widget Function(
  RunMutation$Mutation$RestoreBackup,
  graphql.QueryResult<Mutation$RestoreBackup>?,
);

class Mutation$RestoreBackup$Widget
    extends graphql_flutter.Mutation<Mutation$RestoreBackup> {
  Mutation$RestoreBackup$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$RestoreBackup? options,
    required Builder$Mutation$RestoreBackup builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$RestoreBackup(),
          builder: (
            run,
            result,
          ) =>
              builder(
            (
              variables, {
              optimisticResult,
              typedOptimisticResult,
            }) =>
                run(
              variables.toJson(),
              optimisticResult:
                  optimisticResult ?? typedOptimisticResult?.toJson(),
            ),
            result,
          ),
        );
}

class Mutation$RestoreBackup$restoreBackup {
  Mutation$RestoreBackup$restoreBackup({
    this.clientMutationId,
    required this.id,
    this.status,
    this.$__typename = 'RestoreBackupPayload',
  });

  factory Mutation$RestoreBackup$restoreBackup.fromJson(
      Map<String, dynamic> json) {
    final l$clientMutationId = json['clientMutationId'];
    final l$id = json['id'];
    final l$status = json['status'];
    final l$$__typename = json['__typename'];
    return Mutation$RestoreBackup$restoreBackup(
      clientMutationId: (l$clientMutationId as String?),
      id: (l$id as String),
      status: l$status == null
          ? null
          : Fragment$RestoreStatusDto.fromJson(
              (l$status as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final String? clientMutationId;

  final String id;

  final Fragment$RestoreStatusDto? status;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$clientMutationId = clientMutationId;
    _resultData['clientMutationId'] = l$clientMutationId;
    final l$id = id;
    _resultData['id'] = l$id;
    final l$status = status;
    _resultData['status'] = l$status?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$clientMutationId = clientMutationId;
    final l$id = id;
    final l$status = status;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$clientMutationId,
      l$id,
      l$status,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$RestoreBackup$restoreBackup ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$status = status;
    final lOther$status = other.status;
    if (l$status != lOther$status) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Mutation$RestoreBackup$restoreBackup
    on Mutation$RestoreBackup$restoreBackup {
  CopyWith$Mutation$RestoreBackup$restoreBackup<
          Mutation$RestoreBackup$restoreBackup>
      get copyWith => CopyWith$Mutation$RestoreBackup$restoreBackup(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$RestoreBackup$restoreBackup<TRes> {
  factory CopyWith$Mutation$RestoreBackup$restoreBackup(
    Mutation$RestoreBackup$restoreBackup instance,
    TRes Function(Mutation$RestoreBackup$restoreBackup) then,
  ) = _CopyWithImpl$Mutation$RestoreBackup$restoreBackup;

  factory CopyWith$Mutation$RestoreBackup$restoreBackup.stub(TRes res) =
      _CopyWithStubImpl$Mutation$RestoreBackup$restoreBackup;

  TRes call({
    String? clientMutationId,
    String? id,
    Fragment$RestoreStatusDto? status,
    String? $__typename,
  });
  CopyWith$Fragment$RestoreStatusDto<TRes> get status;
}

class _CopyWithImpl$Mutation$RestoreBackup$restoreBackup<TRes>
    implements CopyWith$Mutation$RestoreBackup$restoreBackup<TRes> {
  _CopyWithImpl$Mutation$RestoreBackup$restoreBackup(
    this._instance,
    this._then,
  );

  final Mutation$RestoreBackup$restoreBackup _instance;

  final TRes Function(Mutation$RestoreBackup$restoreBackup) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? clientMutationId = _undefined,
    Object? id = _undefined,
    Object? status = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$RestoreBackup$restoreBackup(
        clientMutationId: clientMutationId == _undefined
            ? _instance.clientMutationId
            : (clientMutationId as String?),
        id: id == _undefined || id == null ? _instance.id : (id as String),
        status: status == _undefined
            ? _instance.status
            : (status as Fragment$RestoreStatusDto?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Fragment$RestoreStatusDto<TRes> get status {
    final local$status = _instance.status;
    return local$status == null
        ? CopyWith$Fragment$RestoreStatusDto.stub(_then(_instance))
        : CopyWith$Fragment$RestoreStatusDto(
            local$status, (e) => call(status: e));
  }
}

class _CopyWithStubImpl$Mutation$RestoreBackup$restoreBackup<TRes>
    implements CopyWith$Mutation$RestoreBackup$restoreBackup<TRes> {
  _CopyWithStubImpl$Mutation$RestoreBackup$restoreBackup(this._res);

  TRes _res;

  call({
    String? clientMutationId,
    String? id,
    Fragment$RestoreStatusDto? status,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$RestoreStatusDto<TRes> get status =>
      CopyWith$Fragment$RestoreStatusDto.stub(_res);
}

class Variables$Mutation$CreateBackup {
  factory Variables$Mutation$CreateBackup({
    bool? includeCategories,
    bool? includeChapters,
  }) =>
      Variables$Mutation$CreateBackup._({
        if (includeCategories != null) r'includeCategories': includeCategories,
        if (includeChapters != null) r'includeChapters': includeChapters,
      });

  Variables$Mutation$CreateBackup._(this._$data);

  factory Variables$Mutation$CreateBackup.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('includeCategories')) {
      final l$includeCategories = data['includeCategories'];
      result$data['includeCategories'] = (l$includeCategories as bool?);
    }
    if (data.containsKey('includeChapters')) {
      final l$includeChapters = data['includeChapters'];
      result$data['includeChapters'] = (l$includeChapters as bool?);
    }
    return Variables$Mutation$CreateBackup._(result$data);
  }

  Map<String, dynamic> _$data;

  bool? get includeCategories => (_$data['includeCategories'] as bool?);

  bool? get includeChapters => (_$data['includeChapters'] as bool?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
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

  CopyWith$Variables$Mutation$CreateBackup<Variables$Mutation$CreateBackup>
      get copyWith => CopyWith$Variables$Mutation$CreateBackup(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$CreateBackup ||
        runtimeType != other.runtimeType) {
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
    final l$includeCategories = includeCategories;
    final l$includeChapters = includeChapters;
    return Object.hashAll([
      _$data.containsKey('includeCategories') ? l$includeCategories : const {},
      _$data.containsKey('includeChapters') ? l$includeChapters : const {},
    ]);
  }
}

abstract class CopyWith$Variables$Mutation$CreateBackup<TRes> {
  factory CopyWith$Variables$Mutation$CreateBackup(
    Variables$Mutation$CreateBackup instance,
    TRes Function(Variables$Mutation$CreateBackup) then,
  ) = _CopyWithImpl$Variables$Mutation$CreateBackup;

  factory CopyWith$Variables$Mutation$CreateBackup.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$CreateBackup;

  TRes call({
    bool? includeCategories,
    bool? includeChapters,
  });
}

class _CopyWithImpl$Variables$Mutation$CreateBackup<TRes>
    implements CopyWith$Variables$Mutation$CreateBackup<TRes> {
  _CopyWithImpl$Variables$Mutation$CreateBackup(
    this._instance,
    this._then,
  );

  final Variables$Mutation$CreateBackup _instance;

  final TRes Function(Variables$Mutation$CreateBackup) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? includeCategories = _undefined,
    Object? includeChapters = _undefined,
  }) =>
      _then(Variables$Mutation$CreateBackup._({
        ..._instance._$data,
        if (includeCategories != _undefined)
          'includeCategories': (includeCategories as bool?),
        if (includeChapters != _undefined)
          'includeChapters': (includeChapters as bool?),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$CreateBackup<TRes>
    implements CopyWith$Variables$Mutation$CreateBackup<TRes> {
  _CopyWithStubImpl$Variables$Mutation$CreateBackup(this._res);

  TRes _res;

  call({
    bool? includeCategories,
    bool? includeChapters,
  }) =>
      _res;
}

class Mutation$CreateBackup {
  Mutation$CreateBackup({
    required this.createBackup,
    this.$__typename = 'Mutation',
  });

  factory Mutation$CreateBackup.fromJson(Map<String, dynamic> json) {
    final l$createBackup = json['createBackup'];
    final l$$__typename = json['__typename'];
    return Mutation$CreateBackup(
      createBackup: Mutation$CreateBackup$createBackup.fromJson(
          (l$createBackup as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$CreateBackup$createBackup createBackup;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$createBackup = createBackup;
    _resultData['createBackup'] = l$createBackup.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$createBackup = createBackup;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$createBackup,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$CreateBackup || runtimeType != other.runtimeType) {
      return false;
    }
    final l$createBackup = createBackup;
    final lOther$createBackup = other.createBackup;
    if (l$createBackup != lOther$createBackup) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Mutation$CreateBackup on Mutation$CreateBackup {
  CopyWith$Mutation$CreateBackup<Mutation$CreateBackup> get copyWith =>
      CopyWith$Mutation$CreateBackup(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Mutation$CreateBackup<TRes> {
  factory CopyWith$Mutation$CreateBackup(
    Mutation$CreateBackup instance,
    TRes Function(Mutation$CreateBackup) then,
  ) = _CopyWithImpl$Mutation$CreateBackup;

  factory CopyWith$Mutation$CreateBackup.stub(TRes res) =
      _CopyWithStubImpl$Mutation$CreateBackup;

  TRes call({
    Mutation$CreateBackup$createBackup? createBackup,
    String? $__typename,
  });
  CopyWith$Mutation$CreateBackup$createBackup<TRes> get createBackup;
}

class _CopyWithImpl$Mutation$CreateBackup<TRes>
    implements CopyWith$Mutation$CreateBackup<TRes> {
  _CopyWithImpl$Mutation$CreateBackup(
    this._instance,
    this._then,
  );

  final Mutation$CreateBackup _instance;

  final TRes Function(Mutation$CreateBackup) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? createBackup = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$CreateBackup(
        createBackup: createBackup == _undefined || createBackup == null
            ? _instance.createBackup
            : (createBackup as Mutation$CreateBackup$createBackup),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$CreateBackup$createBackup<TRes> get createBackup {
    final local$createBackup = _instance.createBackup;
    return CopyWith$Mutation$CreateBackup$createBackup(
        local$createBackup, (e) => call(createBackup: e));
  }
}

class _CopyWithStubImpl$Mutation$CreateBackup<TRes>
    implements CopyWith$Mutation$CreateBackup<TRes> {
  _CopyWithStubImpl$Mutation$CreateBackup(this._res);

  TRes _res;

  call({
    Mutation$CreateBackup$createBackup? createBackup,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$CreateBackup$createBackup<TRes> get createBackup =>
      CopyWith$Mutation$CreateBackup$createBackup.stub(_res);
}

const documentNodeMutationCreateBackup = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'CreateBackup'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'includeCategories')),
        type: NamedTypeNode(
          name: NameNode(value: 'Boolean'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: BooleanValueNode(value: true)),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'includeChapters')),
        type: NamedTypeNode(
          name: NameNode(value: 'Boolean'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: BooleanValueNode(value: true)),
        directives: [],
      ),
    ],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'createBackup'),
        alias: null,
        arguments: [
          ArgumentNode(
            name: NameNode(value: 'input'),
            value: ObjectValueNode(fields: [
              ObjectFieldNode(
                name: NameNode(value: 'includeCategories'),
                value: VariableNode(name: NameNode(value: 'includeCategories')),
              ),
              ObjectFieldNode(
                name: NameNode(value: 'includeChapters'),
                value: VariableNode(name: NameNode(value: 'includeChapters')),
              ),
            ]),
          )
        ],
        directives: [],
        selectionSet: SelectionSetNode(selections: [
          FieldNode(
            name: NameNode(value: 'clientMutationId'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null,
          ),
          FieldNode(
            name: NameNode(value: 'url'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null,
          ),
          FieldNode(
            name: NameNode(value: '__typename'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null,
          ),
        ]),
      ),
      FieldNode(
        name: NameNode(value: '__typename'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
    ]),
  ),
]);
Mutation$CreateBackup _parserFn$Mutation$CreateBackup(
        Map<String, dynamic> data) =>
    Mutation$CreateBackup.fromJson(data);
typedef OnMutationCompleted$Mutation$CreateBackup = FutureOr<void> Function(
  Map<String, dynamic>?,
  Mutation$CreateBackup?,
);

class Options$Mutation$CreateBackup
    extends graphql.MutationOptions<Mutation$CreateBackup> {
  Options$Mutation$CreateBackup({
    String? operationName,
    Variables$Mutation$CreateBackup? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$CreateBackup? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$CreateBackup? onCompleted,
    graphql.OnMutationUpdate<Mutation$CreateBackup>? update,
    graphql.OnError? onError,
  })  : onCompletedWithParsed = onCompleted,
        super(
          variables: variables?.toJson() ?? {},
          operationName: operationName,
          fetchPolicy: fetchPolicy,
          errorPolicy: errorPolicy,
          cacheRereadPolicy: cacheRereadPolicy,
          optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
          context: context,
          onCompleted: onCompleted == null
              ? null
              : (data) => onCompleted(
                    data,
                    data == null ? null : _parserFn$Mutation$CreateBackup(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationCreateBackup,
          parserFn: _parserFn$Mutation$CreateBackup,
        );

  final OnMutationCompleted$Mutation$CreateBackup? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$CreateBackup
    extends graphql.WatchQueryOptions<Mutation$CreateBackup> {
  WatchOptions$Mutation$CreateBackup({
    String? operationName,
    Variables$Mutation$CreateBackup? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$CreateBackup? typedOptimisticResult,
    graphql.Context? context,
    Duration? pollInterval,
    bool? eagerlyFetchResults,
    bool carryForwardDataOnException = true,
    bool fetchResults = false,
  }) : super(
          variables: variables?.toJson() ?? {},
          operationName: operationName,
          fetchPolicy: fetchPolicy,
          errorPolicy: errorPolicy,
          cacheRereadPolicy: cacheRereadPolicy,
          optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
          context: context,
          document: documentNodeMutationCreateBackup,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$CreateBackup,
        );
}

extension ClientExtension$Mutation$CreateBackup on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$CreateBackup>> mutate$CreateBackup(
          [Options$Mutation$CreateBackup? options]) async =>
      await this.mutate(options ?? Options$Mutation$CreateBackup());

  graphql.ObservableQuery<Mutation$CreateBackup> watchMutation$CreateBackup(
          [WatchOptions$Mutation$CreateBackup? options]) =>
      this.watchMutation(options ?? WatchOptions$Mutation$CreateBackup());
}

class Mutation$CreateBackup$HookResult {
  Mutation$CreateBackup$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$CreateBackup runMutation;

  final graphql.QueryResult<Mutation$CreateBackup> result;
}

Mutation$CreateBackup$HookResult useMutation$CreateBackup(
    [WidgetOptions$Mutation$CreateBackup? options]) {
  final result = graphql_flutter
      .useMutation(options ?? WidgetOptions$Mutation$CreateBackup());
  return Mutation$CreateBackup$HookResult(
    ({variables, optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables?.toJson() ?? const {},
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$CreateBackup> useWatchMutation$CreateBackup(
        [WatchOptions$Mutation$CreateBackup? options]) =>
    graphql_flutter
        .useWatchMutation(options ?? WatchOptions$Mutation$CreateBackup());

class WidgetOptions$Mutation$CreateBackup
    extends graphql.MutationOptions<Mutation$CreateBackup> {
  WidgetOptions$Mutation$CreateBackup({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$CreateBackup? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$CreateBackup? onCompleted,
    graphql.OnMutationUpdate<Mutation$CreateBackup>? update,
    graphql.OnError? onError,
  })  : onCompletedWithParsed = onCompleted,
        super(
          operationName: operationName,
          fetchPolicy: fetchPolicy,
          errorPolicy: errorPolicy,
          cacheRereadPolicy: cacheRereadPolicy,
          optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
          context: context,
          onCompleted: onCompleted == null
              ? null
              : (data) => onCompleted(
                    data,
                    data == null ? null : _parserFn$Mutation$CreateBackup(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationCreateBackup,
          parserFn: _parserFn$Mutation$CreateBackup,
        );

  final OnMutationCompleted$Mutation$CreateBackup? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$CreateBackup
    = graphql.MultiSourceResult<Mutation$CreateBackup> Function({
  Variables$Mutation$CreateBackup? variables,
  Object? optimisticResult,
  Mutation$CreateBackup? typedOptimisticResult,
});
typedef Builder$Mutation$CreateBackup = widgets.Widget Function(
  RunMutation$Mutation$CreateBackup,
  graphql.QueryResult<Mutation$CreateBackup>?,
);

class Mutation$CreateBackup$Widget
    extends graphql_flutter.Mutation<Mutation$CreateBackup> {
  Mutation$CreateBackup$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$CreateBackup? options,
    required Builder$Mutation$CreateBackup builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$CreateBackup(),
          builder: (
            run,
            result,
          ) =>
              builder(
            ({
              variables,
              optimisticResult,
              typedOptimisticResult,
            }) =>
                run(
              variables?.toJson() ?? const {},
              optimisticResult:
                  optimisticResult ?? typedOptimisticResult?.toJson(),
            ),
            result,
          ),
        );
}

class Mutation$CreateBackup$createBackup {
  Mutation$CreateBackup$createBackup({
    this.clientMutationId,
    required this.url,
    this.$__typename = 'CreateBackupPayload',
  });

  factory Mutation$CreateBackup$createBackup.fromJson(
      Map<String, dynamic> json) {
    final l$clientMutationId = json['clientMutationId'];
    final l$url = json['url'];
    final l$$__typename = json['__typename'];
    return Mutation$CreateBackup$createBackup(
      clientMutationId: (l$clientMutationId as String?),
      url: (l$url as String),
      $__typename: (l$$__typename as String),
    );
  }

  final String? clientMutationId;

  final String url;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$clientMutationId = clientMutationId;
    _resultData['clientMutationId'] = l$clientMutationId;
    final l$url = url;
    _resultData['url'] = l$url;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$clientMutationId = clientMutationId;
    final l$url = url;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$clientMutationId,
      l$url,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$CreateBackup$createBackup ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    final l$url = url;
    final lOther$url = other.url;
    if (l$url != lOther$url) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Mutation$CreateBackup$createBackup
    on Mutation$CreateBackup$createBackup {
  CopyWith$Mutation$CreateBackup$createBackup<
          Mutation$CreateBackup$createBackup>
      get copyWith => CopyWith$Mutation$CreateBackup$createBackup(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$CreateBackup$createBackup<TRes> {
  factory CopyWith$Mutation$CreateBackup$createBackup(
    Mutation$CreateBackup$createBackup instance,
    TRes Function(Mutation$CreateBackup$createBackup) then,
  ) = _CopyWithImpl$Mutation$CreateBackup$createBackup;

  factory CopyWith$Mutation$CreateBackup$createBackup.stub(TRes res) =
      _CopyWithStubImpl$Mutation$CreateBackup$createBackup;

  TRes call({
    String? clientMutationId,
    String? url,
    String? $__typename,
  });
}

class _CopyWithImpl$Mutation$CreateBackup$createBackup<TRes>
    implements CopyWith$Mutation$CreateBackup$createBackup<TRes> {
  _CopyWithImpl$Mutation$CreateBackup$createBackup(
    this._instance,
    this._then,
  );

  final Mutation$CreateBackup$createBackup _instance;

  final TRes Function(Mutation$CreateBackup$createBackup) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? clientMutationId = _undefined,
    Object? url = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$CreateBackup$createBackup(
        clientMutationId: clientMutationId == _undefined
            ? _instance.clientMutationId
            : (clientMutationId as String?),
        url: url == _undefined || url == null ? _instance.url : (url as String),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Mutation$CreateBackup$createBackup<TRes>
    implements CopyWith$Mutation$CreateBackup$createBackup<TRes> {
  _CopyWithStubImpl$Mutation$CreateBackup$createBackup(this._res);

  TRes _res;

  call({
    String? clientMutationId,
    String? url,
    String? $__typename,
  }) =>
      _res;
}

class Variables$Query$ValidateBackup {
  factory Variables$Query$ValidateBackup({required MultipartFile backup}) =>
      Variables$Query$ValidateBackup._({
        r'backup': backup,
      });

  Variables$Query$ValidateBackup._(this._$data);

  factory Variables$Query$ValidateBackup.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$backup = data['backup'];
    result$data['backup'] = fileFromJson(l$backup);
    return Variables$Query$ValidateBackup._(result$data);
  }

  Map<String, dynamic> _$data;

  MultipartFile get backup => (_$data['backup'] as MultipartFile);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$backup = backup;
    result$data['backup'] = fileToJson(l$backup);
    return result$data;
  }

  CopyWith$Variables$Query$ValidateBackup<Variables$Query$ValidateBackup>
      get copyWith => CopyWith$Variables$Query$ValidateBackup(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Query$ValidateBackup ||
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

abstract class CopyWith$Variables$Query$ValidateBackup<TRes> {
  factory CopyWith$Variables$Query$ValidateBackup(
    Variables$Query$ValidateBackup instance,
    TRes Function(Variables$Query$ValidateBackup) then,
  ) = _CopyWithImpl$Variables$Query$ValidateBackup;

  factory CopyWith$Variables$Query$ValidateBackup.stub(TRes res) =
      _CopyWithStubImpl$Variables$Query$ValidateBackup;

  TRes call({MultipartFile? backup});
}

class _CopyWithImpl$Variables$Query$ValidateBackup<TRes>
    implements CopyWith$Variables$Query$ValidateBackup<TRes> {
  _CopyWithImpl$Variables$Query$ValidateBackup(
    this._instance,
    this._then,
  );

  final Variables$Query$ValidateBackup _instance;

  final TRes Function(Variables$Query$ValidateBackup) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? backup = _undefined}) =>
      _then(Variables$Query$ValidateBackup._({
        ..._instance._$data,
        if (backup != _undefined && backup != null)
          'backup': (backup as MultipartFile),
      }));
}

class _CopyWithStubImpl$Variables$Query$ValidateBackup<TRes>
    implements CopyWith$Variables$Query$ValidateBackup<TRes> {
  _CopyWithStubImpl$Variables$Query$ValidateBackup(this._res);

  TRes _res;

  call({MultipartFile? backup}) => _res;
}

class Query$ValidateBackup {
  Query$ValidateBackup({
    required this.validateBackup,
    this.$__typename = 'Query',
  });

  factory Query$ValidateBackup.fromJson(Map<String, dynamic> json) {
    final l$validateBackup = json['validateBackup'];
    final l$$__typename = json['__typename'];
    return Query$ValidateBackup(
      validateBackup: Query$ValidateBackup$validateBackup.fromJson(
          (l$validateBackup as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Query$ValidateBackup$validateBackup validateBackup;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$validateBackup = validateBackup;
    _resultData['validateBackup'] = l$validateBackup.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$validateBackup = validateBackup;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$validateBackup,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$ValidateBackup || runtimeType != other.runtimeType) {
      return false;
    }
    final l$validateBackup = validateBackup;
    final lOther$validateBackup = other.validateBackup;
    if (l$validateBackup != lOther$validateBackup) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Query$ValidateBackup on Query$ValidateBackup {
  CopyWith$Query$ValidateBackup<Query$ValidateBackup> get copyWith =>
      CopyWith$Query$ValidateBackup(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Query$ValidateBackup<TRes> {
  factory CopyWith$Query$ValidateBackup(
    Query$ValidateBackup instance,
    TRes Function(Query$ValidateBackup) then,
  ) = _CopyWithImpl$Query$ValidateBackup;

  factory CopyWith$Query$ValidateBackup.stub(TRes res) =
      _CopyWithStubImpl$Query$ValidateBackup;

  TRes call({
    Query$ValidateBackup$validateBackup? validateBackup,
    String? $__typename,
  });
  CopyWith$Query$ValidateBackup$validateBackup<TRes> get validateBackup;
}

class _CopyWithImpl$Query$ValidateBackup<TRes>
    implements CopyWith$Query$ValidateBackup<TRes> {
  _CopyWithImpl$Query$ValidateBackup(
    this._instance,
    this._then,
  );

  final Query$ValidateBackup _instance;

  final TRes Function(Query$ValidateBackup) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? validateBackup = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$ValidateBackup(
        validateBackup: validateBackup == _undefined || validateBackup == null
            ? _instance.validateBackup
            : (validateBackup as Query$ValidateBackup$validateBackup),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$ValidateBackup$validateBackup<TRes> get validateBackup {
    final local$validateBackup = _instance.validateBackup;
    return CopyWith$Query$ValidateBackup$validateBackup(
        local$validateBackup, (e) => call(validateBackup: e));
  }
}

class _CopyWithStubImpl$Query$ValidateBackup<TRes>
    implements CopyWith$Query$ValidateBackup<TRes> {
  _CopyWithStubImpl$Query$ValidateBackup(this._res);

  TRes _res;

  call({
    Query$ValidateBackup$validateBackup? validateBackup,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$ValidateBackup$validateBackup<TRes> get validateBackup =>
      CopyWith$Query$ValidateBackup$validateBackup.stub(_res);
}

const documentNodeQueryValidateBackup = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.query,
    name: NameNode(value: 'ValidateBackup'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'backup')),
        type: NamedTypeNode(
          name: NameNode(value: 'Upload'),
          isNonNull: true,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      )
    ],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'validateBackup'),
        alias: null,
        arguments: [
          ArgumentNode(
            name: NameNode(value: 'input'),
            value: ObjectValueNode(fields: [
              ObjectFieldNode(
                name: NameNode(value: 'backup'),
                value: VariableNode(name: NameNode(value: 'backup')),
              )
            ]),
          )
        ],
        directives: [],
        selectionSet: SelectionSetNode(selections: [
          FieldNode(
            name: NameNode(value: 'missingSources'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: SelectionSetNode(selections: [
              FieldNode(
                name: NameNode(value: 'name'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
              FieldNode(
                name: NameNode(value: 'id'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
              FieldNode(
                name: NameNode(value: '__typename'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
            ]),
          ),
          FieldNode(
            name: NameNode(value: '__typename'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null,
          ),
        ]),
      ),
      FieldNode(
        name: NameNode(value: '__typename'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
    ]),
  ),
]);
Query$ValidateBackup _parserFn$Query$ValidateBackup(
        Map<String, dynamic> data) =>
    Query$ValidateBackup.fromJson(data);
typedef OnQueryComplete$Query$ValidateBackup = FutureOr<void> Function(
  Map<String, dynamic>?,
  Query$ValidateBackup?,
);

class Options$Query$ValidateBackup
    extends graphql.QueryOptions<Query$ValidateBackup> {
  Options$Query$ValidateBackup({
    String? operationName,
    required Variables$Query$ValidateBackup variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$ValidateBackup? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$ValidateBackup? onComplete,
    graphql.OnQueryError? onError,
  })  : onCompleteWithParsed = onComplete,
        super(
          variables: variables.toJson(),
          operationName: operationName,
          fetchPolicy: fetchPolicy,
          errorPolicy: errorPolicy,
          cacheRereadPolicy: cacheRereadPolicy,
          optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
          pollInterval: pollInterval,
          context: context,
          onComplete: onComplete == null
              ? null
              : (data) => onComplete(
                    data,
                    data == null ? null : _parserFn$Query$ValidateBackup(data),
                  ),
          onError: onError,
          document: documentNodeQueryValidateBackup,
          parserFn: _parserFn$Query$ValidateBackup,
        );

  final OnQueryComplete$Query$ValidateBackup? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onComplete == null
            ? super.properties
            : super.properties.where((property) => property != onComplete),
        onCompleteWithParsed,
      ];
}

class WatchOptions$Query$ValidateBackup
    extends graphql.WatchQueryOptions<Query$ValidateBackup> {
  WatchOptions$Query$ValidateBackup({
    String? operationName,
    required Variables$Query$ValidateBackup variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$ValidateBackup? typedOptimisticResult,
    graphql.Context? context,
    Duration? pollInterval,
    bool? eagerlyFetchResults,
    bool carryForwardDataOnException = true,
    bool fetchResults = false,
  }) : super(
          variables: variables.toJson(),
          operationName: operationName,
          fetchPolicy: fetchPolicy,
          errorPolicy: errorPolicy,
          cacheRereadPolicy: cacheRereadPolicy,
          optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
          context: context,
          document: documentNodeQueryValidateBackup,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Query$ValidateBackup,
        );
}

class FetchMoreOptions$Query$ValidateBackup extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$ValidateBackup({
    required graphql.UpdateQuery updateQuery,
    required Variables$Query$ValidateBackup variables,
  }) : super(
          updateQuery: updateQuery,
          variables: variables.toJson(),
          document: documentNodeQueryValidateBackup,
        );
}

extension ClientExtension$Query$ValidateBackup on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$ValidateBackup>> query$ValidateBackup(
          Options$Query$ValidateBackup options) async =>
      await this.query(options);

  graphql.ObservableQuery<Query$ValidateBackup> watchQuery$ValidateBackup(
          WatchOptions$Query$ValidateBackup options) =>
      this.watchQuery(options);

  void writeQuery$ValidateBackup({
    required Query$ValidateBackup data,
    required Variables$Query$ValidateBackup variables,
    bool broadcast = true,
  }) =>
      this.writeQuery(
        graphql.Request(
          operation:
              graphql.Operation(document: documentNodeQueryValidateBackup),
          variables: variables.toJson(),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );

  Query$ValidateBackup? readQuery$ValidateBackup({
    required Variables$Query$ValidateBackup variables,
    bool optimistic = true,
  }) {
    final result = this.readQuery(
      graphql.Request(
        operation: graphql.Operation(document: documentNodeQueryValidateBackup),
        variables: variables.toJson(),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Query$ValidateBackup.fromJson(result);
  }
}

graphql_flutter.QueryHookResult<Query$ValidateBackup> useQuery$ValidateBackup(
        Options$Query$ValidateBackup options) =>
    graphql_flutter.useQuery(options);
graphql.ObservableQuery<Query$ValidateBackup> useWatchQuery$ValidateBackup(
        WatchOptions$Query$ValidateBackup options) =>
    graphql_flutter.useWatchQuery(options);

class Query$ValidateBackup$Widget
    extends graphql_flutter.Query<Query$ValidateBackup> {
  Query$ValidateBackup$Widget({
    widgets.Key? key,
    required Options$Query$ValidateBackup options,
    required graphql_flutter.QueryBuilder<Query$ValidateBackup> builder,
  }) : super(
          key: key,
          options: options,
          builder: builder,
        );
}

class Query$ValidateBackup$validateBackup {
  Query$ValidateBackup$validateBackup({
    required this.missingSources,
    this.$__typename = 'ValidateBackupResult',
  });

  factory Query$ValidateBackup$validateBackup.fromJson(
      Map<String, dynamic> json) {
    final l$missingSources = json['missingSources'];
    final l$$__typename = json['__typename'];
    return Query$ValidateBackup$validateBackup(
      missingSources: (l$missingSources as List<dynamic>)
          .map((e) =>
              Query$ValidateBackup$validateBackup$missingSources.fromJson(
                  (e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final List<Query$ValidateBackup$validateBackup$missingSources> missingSources;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$missingSources = missingSources;
    _resultData['missingSources'] =
        l$missingSources.map((e) => e.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$missingSources = missingSources;
    final l$$__typename = $__typename;
    return Object.hashAll([
      Object.hashAll(l$missingSources.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$ValidateBackup$validateBackup ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$missingSources = missingSources;
    final lOther$missingSources = other.missingSources;
    if (l$missingSources.length != lOther$missingSources.length) {
      return false;
    }
    for (int i = 0; i < l$missingSources.length; i++) {
      final l$missingSources$entry = l$missingSources[i];
      final lOther$missingSources$entry = lOther$missingSources[i];
      if (l$missingSources$entry != lOther$missingSources$entry) {
        return false;
      }
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Query$ValidateBackup$validateBackup
    on Query$ValidateBackup$validateBackup {
  CopyWith$Query$ValidateBackup$validateBackup<
          Query$ValidateBackup$validateBackup>
      get copyWith => CopyWith$Query$ValidateBackup$validateBackup(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$ValidateBackup$validateBackup<TRes> {
  factory CopyWith$Query$ValidateBackup$validateBackup(
    Query$ValidateBackup$validateBackup instance,
    TRes Function(Query$ValidateBackup$validateBackup) then,
  ) = _CopyWithImpl$Query$ValidateBackup$validateBackup;

  factory CopyWith$Query$ValidateBackup$validateBackup.stub(TRes res) =
      _CopyWithStubImpl$Query$ValidateBackup$validateBackup;

  TRes call({
    List<Query$ValidateBackup$validateBackup$missingSources>? missingSources,
    String? $__typename,
  });
  TRes missingSources(
      Iterable<Query$ValidateBackup$validateBackup$missingSources> Function(
              Iterable<
                  CopyWith$Query$ValidateBackup$validateBackup$missingSources<
                      Query$ValidateBackup$validateBackup$missingSources>>)
          _fn);
}

class _CopyWithImpl$Query$ValidateBackup$validateBackup<TRes>
    implements CopyWith$Query$ValidateBackup$validateBackup<TRes> {
  _CopyWithImpl$Query$ValidateBackup$validateBackup(
    this._instance,
    this._then,
  );

  final Query$ValidateBackup$validateBackup _instance;

  final TRes Function(Query$ValidateBackup$validateBackup) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? missingSources = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$ValidateBackup$validateBackup(
        missingSources: missingSources == _undefined || missingSources == null
            ? _instance.missingSources
            : (missingSources
                as List<Query$ValidateBackup$validateBackup$missingSources>),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  TRes missingSources(
          Iterable<Query$ValidateBackup$validateBackup$missingSources> Function(
                  Iterable<
                      CopyWith$Query$ValidateBackup$validateBackup$missingSources<
                          Query$ValidateBackup$validateBackup$missingSources>>)
              _fn) =>
      call(
          missingSources: _fn(_instance.missingSources.map((e) =>
              CopyWith$Query$ValidateBackup$validateBackup$missingSources(
                e,
                (i) => i,
              ))).toList());
}

class _CopyWithStubImpl$Query$ValidateBackup$validateBackup<TRes>
    implements CopyWith$Query$ValidateBackup$validateBackup<TRes> {
  _CopyWithStubImpl$Query$ValidateBackup$validateBackup(this._res);

  TRes _res;

  call({
    List<Query$ValidateBackup$validateBackup$missingSources>? missingSources,
    String? $__typename,
  }) =>
      _res;

  missingSources(_fn) => _res;
}

class Query$ValidateBackup$validateBackup$missingSources {
  Query$ValidateBackup$validateBackup$missingSources({
    required this.name,
    required this.id,
    this.$__typename = 'ValidateBackupSource',
  });

  factory Query$ValidateBackup$validateBackup$missingSources.fromJson(
      Map<String, dynamic> json) {
    final l$name = json['name'];
    final l$id = json['id'];
    final l$$__typename = json['__typename'];
    return Query$ValidateBackup$validateBackup$missingSources(
      name: (l$name as String),
      id: longStringFromJson(l$id),
      $__typename: (l$$__typename as String),
    );
  }

  final String name;

  final String id;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$name = name;
    _resultData['name'] = l$name;
    final l$id = id;
    _resultData['id'] = longStringToJson(l$id);
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$name = name;
    final l$id = id;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$name,
      l$id,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$ValidateBackup$validateBackup$missingSources ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (l$name != lOther$name) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Query$ValidateBackup$validateBackup$missingSources
    on Query$ValidateBackup$validateBackup$missingSources {
  CopyWith$Query$ValidateBackup$validateBackup$missingSources<
          Query$ValidateBackup$validateBackup$missingSources>
      get copyWith =>
          CopyWith$Query$ValidateBackup$validateBackup$missingSources(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$ValidateBackup$validateBackup$missingSources<
    TRes> {
  factory CopyWith$Query$ValidateBackup$validateBackup$missingSources(
    Query$ValidateBackup$validateBackup$missingSources instance,
    TRes Function(Query$ValidateBackup$validateBackup$missingSources) then,
  ) = _CopyWithImpl$Query$ValidateBackup$validateBackup$missingSources;

  factory CopyWith$Query$ValidateBackup$validateBackup$missingSources.stub(
          TRes res) =
      _CopyWithStubImpl$Query$ValidateBackup$validateBackup$missingSources;

  TRes call({
    String? name,
    String? id,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$ValidateBackup$validateBackup$missingSources<TRes>
    implements
        CopyWith$Query$ValidateBackup$validateBackup$missingSources<TRes> {
  _CopyWithImpl$Query$ValidateBackup$validateBackup$missingSources(
    this._instance,
    this._then,
  );

  final Query$ValidateBackup$validateBackup$missingSources _instance;

  final TRes Function(Query$ValidateBackup$validateBackup$missingSources) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? name = _undefined,
    Object? id = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$ValidateBackup$validateBackup$missingSources(
        name: name == _undefined || name == null
            ? _instance.name
            : (name as String),
        id: id == _undefined || id == null ? _instance.id : (id as String),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$ValidateBackup$validateBackup$missingSources<TRes>
    implements
        CopyWith$Query$ValidateBackup$validateBackup$missingSources<TRes> {
  _CopyWithStubImpl$Query$ValidateBackup$validateBackup$missingSources(
      this._res);

  TRes _res;

  call({
    String? name,
    String? id,
    String? $__typename,
  }) =>
      _res;
}
