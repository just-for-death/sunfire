import '../../../../../domain/settings/graphql/__generated__/fragment.graphql.dart';
import 'dart:async';
import 'package:flutter/widgets.dart' as widgets;
import 'package:gql/ast.dart';
import 'package:graphql/client.dart' as graphql;
import 'package:graphql_flutter/graphql_flutter.dart' as graphql_flutter;

class Variables$Mutation$UpdateMangaMetaData {
  factory Variables$Mutation$UpdateMangaMetaData({bool? updateMangas}) =>
      Variables$Mutation$UpdateMangaMetaData._({
        if (updateMangas != null) r'updateMangas': updateMangas,
      });

  Variables$Mutation$UpdateMangaMetaData._(this._$data);

  factory Variables$Mutation$UpdateMangaMetaData.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('updateMangas')) {
      final l$updateMangas = data['updateMangas'];
      result$data['updateMangas'] = (l$updateMangas as bool?);
    }
    return Variables$Mutation$UpdateMangaMetaData._(result$data);
  }

  Map<String, dynamic> _$data;

  bool? get updateMangas => (_$data['updateMangas'] as bool?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('updateMangas')) {
      final l$updateMangas = updateMangas;
      result$data['updateMangas'] = l$updateMangas;
    }
    return result$data;
  }

  CopyWith$Variables$Mutation$UpdateMangaMetaData<
          Variables$Mutation$UpdateMangaMetaData>
      get copyWith => CopyWith$Variables$Mutation$UpdateMangaMetaData(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$UpdateMangaMetaData ||
        runtimeType != other.runtimeType) {
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
    return true;
  }

  @override
  int get hashCode {
    final l$updateMangas = updateMangas;
    return Object.hashAll(
        [_$data.containsKey('updateMangas') ? l$updateMangas : const {}]);
  }
}

abstract class CopyWith$Variables$Mutation$UpdateMangaMetaData<TRes> {
  factory CopyWith$Variables$Mutation$UpdateMangaMetaData(
    Variables$Mutation$UpdateMangaMetaData instance,
    TRes Function(Variables$Mutation$UpdateMangaMetaData) then,
  ) = _CopyWithImpl$Variables$Mutation$UpdateMangaMetaData;

  factory CopyWith$Variables$Mutation$UpdateMangaMetaData.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$UpdateMangaMetaData;

  TRes call({bool? updateMangas});
}

class _CopyWithImpl$Variables$Mutation$UpdateMangaMetaData<TRes>
    implements CopyWith$Variables$Mutation$UpdateMangaMetaData<TRes> {
  _CopyWithImpl$Variables$Mutation$UpdateMangaMetaData(
    this._instance,
    this._then,
  );

  final Variables$Mutation$UpdateMangaMetaData _instance;

  final TRes Function(Variables$Mutation$UpdateMangaMetaData) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? updateMangas = _undefined}) =>
      _then(Variables$Mutation$UpdateMangaMetaData._({
        ..._instance._$data,
        if (updateMangas != _undefined) 'updateMangas': (updateMangas as bool?),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$UpdateMangaMetaData<TRes>
    implements CopyWith$Variables$Mutation$UpdateMangaMetaData<TRes> {
  _CopyWithStubImpl$Variables$Mutation$UpdateMangaMetaData(this._res);

  TRes _res;

  call({bool? updateMangas}) => _res;
}

class Mutation$UpdateMangaMetaData {
  Mutation$UpdateMangaMetaData({
    required this.setSettings,
    this.$__typename = 'Mutation',
  });

  factory Mutation$UpdateMangaMetaData.fromJson(Map<String, dynamic> json) {
    final l$setSettings = json['setSettings'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateMangaMetaData(
      setSettings: Mutation$UpdateMangaMetaData$setSettings.fromJson(
          (l$setSettings as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$UpdateMangaMetaData$setSettings setSettings;

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
    if (other is! Mutation$UpdateMangaMetaData ||
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

extension UtilityExtension$Mutation$UpdateMangaMetaData
    on Mutation$UpdateMangaMetaData {
  CopyWith$Mutation$UpdateMangaMetaData<Mutation$UpdateMangaMetaData>
      get copyWith => CopyWith$Mutation$UpdateMangaMetaData(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdateMangaMetaData<TRes> {
  factory CopyWith$Mutation$UpdateMangaMetaData(
    Mutation$UpdateMangaMetaData instance,
    TRes Function(Mutation$UpdateMangaMetaData) then,
  ) = _CopyWithImpl$Mutation$UpdateMangaMetaData;

  factory CopyWith$Mutation$UpdateMangaMetaData.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateMangaMetaData;

  TRes call({
    Mutation$UpdateMangaMetaData$setSettings? setSettings,
    String? $__typename,
  });
  CopyWith$Mutation$UpdateMangaMetaData$setSettings<TRes> get setSettings;
}

class _CopyWithImpl$Mutation$UpdateMangaMetaData<TRes>
    implements CopyWith$Mutation$UpdateMangaMetaData<TRes> {
  _CopyWithImpl$Mutation$UpdateMangaMetaData(
    this._instance,
    this._then,
  );

  final Mutation$UpdateMangaMetaData _instance;

  final TRes Function(Mutation$UpdateMangaMetaData) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? setSettings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateMangaMetaData(
        setSettings: setSettings == _undefined || setSettings == null
            ? _instance.setSettings
            : (setSettings as Mutation$UpdateMangaMetaData$setSettings),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$UpdateMangaMetaData$setSettings<TRes> get setSettings {
    final local$setSettings = _instance.setSettings;
    return CopyWith$Mutation$UpdateMangaMetaData$setSettings(
        local$setSettings, (e) => call(setSettings: e));
  }
}

class _CopyWithStubImpl$Mutation$UpdateMangaMetaData<TRes>
    implements CopyWith$Mutation$UpdateMangaMetaData<TRes> {
  _CopyWithStubImpl$Mutation$UpdateMangaMetaData(this._res);

  TRes _res;

  call({
    Mutation$UpdateMangaMetaData$setSettings? setSettings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$UpdateMangaMetaData$setSettings<TRes> get setSettings =>
      CopyWith$Mutation$UpdateMangaMetaData$setSettings.stub(_res);
}

const documentNodeMutationUpdateMangaMetaData = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'UpdateMangaMetaData'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'updateMangas')),
        type: NamedTypeNode(
          name: NameNode(value: 'Boolean'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: BooleanValueNode(value: false)),
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
                    name: NameNode(value: 'updateMangas'),
                    value: VariableNode(name: NameNode(value: 'updateMangas')),
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
Mutation$UpdateMangaMetaData _parserFn$Mutation$UpdateMangaMetaData(
        Map<String, dynamic> data) =>
    Mutation$UpdateMangaMetaData.fromJson(data);
typedef OnMutationCompleted$Mutation$UpdateMangaMetaData = FutureOr<void>
    Function(
  Map<String, dynamic>?,
  Mutation$UpdateMangaMetaData?,
);

class Options$Mutation$UpdateMangaMetaData
    extends graphql.MutationOptions<Mutation$UpdateMangaMetaData> {
  Options$Mutation$UpdateMangaMetaData({
    String? operationName,
    Variables$Mutation$UpdateMangaMetaData? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateMangaMetaData? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateMangaMetaData? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateMangaMetaData>? update,
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
                        : _parserFn$Mutation$UpdateMangaMetaData(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateMangaMetaData,
          parserFn: _parserFn$Mutation$UpdateMangaMetaData,
        );

  final OnMutationCompleted$Mutation$UpdateMangaMetaData? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$UpdateMangaMetaData
    extends graphql.WatchQueryOptions<Mutation$UpdateMangaMetaData> {
  WatchOptions$Mutation$UpdateMangaMetaData({
    String? operationName,
    Variables$Mutation$UpdateMangaMetaData? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateMangaMetaData? typedOptimisticResult,
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
          document: documentNodeMutationUpdateMangaMetaData,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$UpdateMangaMetaData,
        );
}

extension ClientExtension$Mutation$UpdateMangaMetaData
    on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$UpdateMangaMetaData>>
      mutate$UpdateMangaMetaData(
              [Options$Mutation$UpdateMangaMetaData? options]) async =>
          await this.mutate(options ?? Options$Mutation$UpdateMangaMetaData());

  graphql.ObservableQuery<Mutation$UpdateMangaMetaData>
      watchMutation$UpdateMangaMetaData(
              [WatchOptions$Mutation$UpdateMangaMetaData? options]) =>
          this.watchMutation(
              options ?? WatchOptions$Mutation$UpdateMangaMetaData());
}

class Mutation$UpdateMangaMetaData$HookResult {
  Mutation$UpdateMangaMetaData$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$UpdateMangaMetaData runMutation;

  final graphql.QueryResult<Mutation$UpdateMangaMetaData> result;
}

Mutation$UpdateMangaMetaData$HookResult useMutation$UpdateMangaMetaData(
    [WidgetOptions$Mutation$UpdateMangaMetaData? options]) {
  final result = graphql_flutter
      .useMutation(options ?? WidgetOptions$Mutation$UpdateMangaMetaData());
  return Mutation$UpdateMangaMetaData$HookResult(
    ({variables, optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables?.toJson() ?? const {},
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$UpdateMangaMetaData>
    useWatchMutation$UpdateMangaMetaData(
            [WatchOptions$Mutation$UpdateMangaMetaData? options]) =>
        graphql_flutter.useWatchMutation(
            options ?? WatchOptions$Mutation$UpdateMangaMetaData());

class WidgetOptions$Mutation$UpdateMangaMetaData
    extends graphql.MutationOptions<Mutation$UpdateMangaMetaData> {
  WidgetOptions$Mutation$UpdateMangaMetaData({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateMangaMetaData? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateMangaMetaData? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateMangaMetaData>? update,
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
                        : _parserFn$Mutation$UpdateMangaMetaData(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateMangaMetaData,
          parserFn: _parserFn$Mutation$UpdateMangaMetaData,
        );

  final OnMutationCompleted$Mutation$UpdateMangaMetaData? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$UpdateMangaMetaData
    = graphql.MultiSourceResult<Mutation$UpdateMangaMetaData> Function({
  Variables$Mutation$UpdateMangaMetaData? variables,
  Object? optimisticResult,
  Mutation$UpdateMangaMetaData? typedOptimisticResult,
});
typedef Builder$Mutation$UpdateMangaMetaData = widgets.Widget Function(
  RunMutation$Mutation$UpdateMangaMetaData,
  graphql.QueryResult<Mutation$UpdateMangaMetaData>?,
);

class Mutation$UpdateMangaMetaData$Widget
    extends graphql_flutter.Mutation<Mutation$UpdateMangaMetaData> {
  Mutation$UpdateMangaMetaData$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$UpdateMangaMetaData? options,
    required Builder$Mutation$UpdateMangaMetaData builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$UpdateMangaMetaData(),
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

class Mutation$UpdateMangaMetaData$setSettings {
  Mutation$UpdateMangaMetaData$setSettings({
    required this.settings,
    this.$__typename = 'SetSettingsPayload',
  });

  factory Mutation$UpdateMangaMetaData$setSettings.fromJson(
      Map<String, dynamic> json) {
    final l$settings = json['settings'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateMangaMetaData$setSettings(
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
    if (other is! Mutation$UpdateMangaMetaData$setSettings ||
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

extension UtilityExtension$Mutation$UpdateMangaMetaData$setSettings
    on Mutation$UpdateMangaMetaData$setSettings {
  CopyWith$Mutation$UpdateMangaMetaData$setSettings<
          Mutation$UpdateMangaMetaData$setSettings>
      get copyWith => CopyWith$Mutation$UpdateMangaMetaData$setSettings(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdateMangaMetaData$setSettings<TRes> {
  factory CopyWith$Mutation$UpdateMangaMetaData$setSettings(
    Mutation$UpdateMangaMetaData$setSettings instance,
    TRes Function(Mutation$UpdateMangaMetaData$setSettings) then,
  ) = _CopyWithImpl$Mutation$UpdateMangaMetaData$setSettings;

  factory CopyWith$Mutation$UpdateMangaMetaData$setSettings.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateMangaMetaData$setSettings;

  TRes call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  });
  CopyWith$Fragment$SettingsDto<TRes> get settings;
}

class _CopyWithImpl$Mutation$UpdateMangaMetaData$setSettings<TRes>
    implements CopyWith$Mutation$UpdateMangaMetaData$setSettings<TRes> {
  _CopyWithImpl$Mutation$UpdateMangaMetaData$setSettings(
    this._instance,
    this._then,
  );

  final Mutation$UpdateMangaMetaData$setSettings _instance;

  final TRes Function(Mutation$UpdateMangaMetaData$setSettings) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? settings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateMangaMetaData$setSettings(
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

class _CopyWithStubImpl$Mutation$UpdateMangaMetaData$setSettings<TRes>
    implements CopyWith$Mutation$UpdateMangaMetaData$setSettings<TRes> {
  _CopyWithStubImpl$Mutation$UpdateMangaMetaData$setSettings(this._res);

  TRes _res;

  call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$SettingsDto<TRes> get settings =>
      CopyWith$Fragment$SettingsDto.stub(_res);
}

class Variables$Mutation$UpdateGlobalUpdateInterval {
  factory Variables$Mutation$UpdateGlobalUpdateInterval(
          {double? globalUpdateInterval}) =>
      Variables$Mutation$UpdateGlobalUpdateInterval._({
        if (globalUpdateInterval != null)
          r'globalUpdateInterval': globalUpdateInterval,
      });

  Variables$Mutation$UpdateGlobalUpdateInterval._(this._$data);

  factory Variables$Mutation$UpdateGlobalUpdateInterval.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('globalUpdateInterval')) {
      final l$globalUpdateInterval = data['globalUpdateInterval'];
      result$data['globalUpdateInterval'] =
          (l$globalUpdateInterval as num?)?.toDouble();
    }
    return Variables$Mutation$UpdateGlobalUpdateInterval._(result$data);
  }

  Map<String, dynamic> _$data;

  double? get globalUpdateInterval =>
      (_$data['globalUpdateInterval'] as double?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('globalUpdateInterval')) {
      final l$globalUpdateInterval = globalUpdateInterval;
      result$data['globalUpdateInterval'] = l$globalUpdateInterval;
    }
    return result$data;
  }

  CopyWith$Variables$Mutation$UpdateGlobalUpdateInterval<
          Variables$Mutation$UpdateGlobalUpdateInterval>
      get copyWith => CopyWith$Variables$Mutation$UpdateGlobalUpdateInterval(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$UpdateGlobalUpdateInterval ||
        runtimeType != other.runtimeType) {
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
    return true;
  }

  @override
  int get hashCode {
    final l$globalUpdateInterval = globalUpdateInterval;
    return Object.hashAll([
      _$data.containsKey('globalUpdateInterval')
          ? l$globalUpdateInterval
          : const {}
    ]);
  }
}

abstract class CopyWith$Variables$Mutation$UpdateGlobalUpdateInterval<TRes> {
  factory CopyWith$Variables$Mutation$UpdateGlobalUpdateInterval(
    Variables$Mutation$UpdateGlobalUpdateInterval instance,
    TRes Function(Variables$Mutation$UpdateGlobalUpdateInterval) then,
  ) = _CopyWithImpl$Variables$Mutation$UpdateGlobalUpdateInterval;

  factory CopyWith$Variables$Mutation$UpdateGlobalUpdateInterval.stub(
          TRes res) =
      _CopyWithStubImpl$Variables$Mutation$UpdateGlobalUpdateInterval;

  TRes call({double? globalUpdateInterval});
}

class _CopyWithImpl$Variables$Mutation$UpdateGlobalUpdateInterval<TRes>
    implements CopyWith$Variables$Mutation$UpdateGlobalUpdateInterval<TRes> {
  _CopyWithImpl$Variables$Mutation$UpdateGlobalUpdateInterval(
    this._instance,
    this._then,
  );

  final Variables$Mutation$UpdateGlobalUpdateInterval _instance;

  final TRes Function(Variables$Mutation$UpdateGlobalUpdateInterval) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? globalUpdateInterval = _undefined}) =>
      _then(Variables$Mutation$UpdateGlobalUpdateInterval._({
        ..._instance._$data,
        if (globalUpdateInterval != _undefined)
          'globalUpdateInterval': (globalUpdateInterval as double?),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$UpdateGlobalUpdateInterval<TRes>
    implements CopyWith$Variables$Mutation$UpdateGlobalUpdateInterval<TRes> {
  _CopyWithStubImpl$Variables$Mutation$UpdateGlobalUpdateInterval(this._res);

  TRes _res;

  call({double? globalUpdateInterval}) => _res;
}

class Mutation$UpdateGlobalUpdateInterval {
  Mutation$UpdateGlobalUpdateInterval({
    required this.setSettings,
    this.$__typename = 'Mutation',
  });

  factory Mutation$UpdateGlobalUpdateInterval.fromJson(
      Map<String, dynamic> json) {
    final l$setSettings = json['setSettings'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateGlobalUpdateInterval(
      setSettings: Mutation$UpdateGlobalUpdateInterval$setSettings.fromJson(
          (l$setSettings as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$UpdateGlobalUpdateInterval$setSettings setSettings;

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
    if (other is! Mutation$UpdateGlobalUpdateInterval ||
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

extension UtilityExtension$Mutation$UpdateGlobalUpdateInterval
    on Mutation$UpdateGlobalUpdateInterval {
  CopyWith$Mutation$UpdateGlobalUpdateInterval<
          Mutation$UpdateGlobalUpdateInterval>
      get copyWith => CopyWith$Mutation$UpdateGlobalUpdateInterval(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdateGlobalUpdateInterval<TRes> {
  factory CopyWith$Mutation$UpdateGlobalUpdateInterval(
    Mutation$UpdateGlobalUpdateInterval instance,
    TRes Function(Mutation$UpdateGlobalUpdateInterval) then,
  ) = _CopyWithImpl$Mutation$UpdateGlobalUpdateInterval;

  factory CopyWith$Mutation$UpdateGlobalUpdateInterval.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateGlobalUpdateInterval;

  TRes call({
    Mutation$UpdateGlobalUpdateInterval$setSettings? setSettings,
    String? $__typename,
  });
  CopyWith$Mutation$UpdateGlobalUpdateInterval$setSettings<TRes>
      get setSettings;
}

class _CopyWithImpl$Mutation$UpdateGlobalUpdateInterval<TRes>
    implements CopyWith$Mutation$UpdateGlobalUpdateInterval<TRes> {
  _CopyWithImpl$Mutation$UpdateGlobalUpdateInterval(
    this._instance,
    this._then,
  );

  final Mutation$UpdateGlobalUpdateInterval _instance;

  final TRes Function(Mutation$UpdateGlobalUpdateInterval) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? setSettings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateGlobalUpdateInterval(
        setSettings: setSettings == _undefined || setSettings == null
            ? _instance.setSettings
            : (setSettings as Mutation$UpdateGlobalUpdateInterval$setSettings),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$UpdateGlobalUpdateInterval$setSettings<TRes>
      get setSettings {
    final local$setSettings = _instance.setSettings;
    return CopyWith$Mutation$UpdateGlobalUpdateInterval$setSettings(
        local$setSettings, (e) => call(setSettings: e));
  }
}

class _CopyWithStubImpl$Mutation$UpdateGlobalUpdateInterval<TRes>
    implements CopyWith$Mutation$UpdateGlobalUpdateInterval<TRes> {
  _CopyWithStubImpl$Mutation$UpdateGlobalUpdateInterval(this._res);

  TRes _res;

  call({
    Mutation$UpdateGlobalUpdateInterval$setSettings? setSettings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$UpdateGlobalUpdateInterval$setSettings<TRes>
      get setSettings =>
          CopyWith$Mutation$UpdateGlobalUpdateInterval$setSettings.stub(_res);
}

const documentNodeMutationUpdateGlobalUpdateInterval =
    DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'UpdateGlobalUpdateInterval'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'globalUpdateInterval')),
        type: NamedTypeNode(
          name: NameNode(value: 'Float'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: IntValueNode(value: '12')),
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
                    name: NameNode(value: 'globalUpdateInterval'),
                    value: VariableNode(
                        name: NameNode(value: 'globalUpdateInterval')),
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
Mutation$UpdateGlobalUpdateInterval
    _parserFn$Mutation$UpdateGlobalUpdateInterval(Map<String, dynamic> data) =>
        Mutation$UpdateGlobalUpdateInterval.fromJson(data);
typedef OnMutationCompleted$Mutation$UpdateGlobalUpdateInterval = FutureOr<void>
    Function(
  Map<String, dynamic>?,
  Mutation$UpdateGlobalUpdateInterval?,
);

class Options$Mutation$UpdateGlobalUpdateInterval
    extends graphql.MutationOptions<Mutation$UpdateGlobalUpdateInterval> {
  Options$Mutation$UpdateGlobalUpdateInterval({
    String? operationName,
    Variables$Mutation$UpdateGlobalUpdateInterval? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateGlobalUpdateInterval? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateGlobalUpdateInterval? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateGlobalUpdateInterval>? update,
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
                        : _parserFn$Mutation$UpdateGlobalUpdateInterval(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateGlobalUpdateInterval,
          parserFn: _parserFn$Mutation$UpdateGlobalUpdateInterval,
        );

  final OnMutationCompleted$Mutation$UpdateGlobalUpdateInterval?
      onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$UpdateGlobalUpdateInterval
    extends graphql.WatchQueryOptions<Mutation$UpdateGlobalUpdateInterval> {
  WatchOptions$Mutation$UpdateGlobalUpdateInterval({
    String? operationName,
    Variables$Mutation$UpdateGlobalUpdateInterval? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateGlobalUpdateInterval? typedOptimisticResult,
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
          document: documentNodeMutationUpdateGlobalUpdateInterval,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$UpdateGlobalUpdateInterval,
        );
}

extension ClientExtension$Mutation$UpdateGlobalUpdateInterval
    on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$UpdateGlobalUpdateInterval>>
      mutate$UpdateGlobalUpdateInterval(
              [Options$Mutation$UpdateGlobalUpdateInterval? options]) async =>
          await this
              .mutate(options ?? Options$Mutation$UpdateGlobalUpdateInterval());

  graphql.ObservableQuery<Mutation$UpdateGlobalUpdateInterval>
      watchMutation$UpdateGlobalUpdateInterval(
              [WatchOptions$Mutation$UpdateGlobalUpdateInterval? options]) =>
          this.watchMutation(
              options ?? WatchOptions$Mutation$UpdateGlobalUpdateInterval());
}

class Mutation$UpdateGlobalUpdateInterval$HookResult {
  Mutation$UpdateGlobalUpdateInterval$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$UpdateGlobalUpdateInterval runMutation;

  final graphql.QueryResult<Mutation$UpdateGlobalUpdateInterval> result;
}

Mutation$UpdateGlobalUpdateInterval$HookResult
    useMutation$UpdateGlobalUpdateInterval(
        [WidgetOptions$Mutation$UpdateGlobalUpdateInterval? options]) {
  final result = graphql_flutter.useMutation(
      options ?? WidgetOptions$Mutation$UpdateGlobalUpdateInterval());
  return Mutation$UpdateGlobalUpdateInterval$HookResult(
    ({variables, optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables?.toJson() ?? const {},
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$UpdateGlobalUpdateInterval>
    useWatchMutation$UpdateGlobalUpdateInterval(
            [WatchOptions$Mutation$UpdateGlobalUpdateInterval? options]) =>
        graphql_flutter.useWatchMutation(
            options ?? WatchOptions$Mutation$UpdateGlobalUpdateInterval());

class WidgetOptions$Mutation$UpdateGlobalUpdateInterval
    extends graphql.MutationOptions<Mutation$UpdateGlobalUpdateInterval> {
  WidgetOptions$Mutation$UpdateGlobalUpdateInterval({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateGlobalUpdateInterval? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateGlobalUpdateInterval? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateGlobalUpdateInterval>? update,
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
                        : _parserFn$Mutation$UpdateGlobalUpdateInterval(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateGlobalUpdateInterval,
          parserFn: _parserFn$Mutation$UpdateGlobalUpdateInterval,
        );

  final OnMutationCompleted$Mutation$UpdateGlobalUpdateInterval?
      onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$UpdateGlobalUpdateInterval
    = graphql.MultiSourceResult<Mutation$UpdateGlobalUpdateInterval> Function({
  Variables$Mutation$UpdateGlobalUpdateInterval? variables,
  Object? optimisticResult,
  Mutation$UpdateGlobalUpdateInterval? typedOptimisticResult,
});
typedef Builder$Mutation$UpdateGlobalUpdateInterval = widgets.Widget Function(
  RunMutation$Mutation$UpdateGlobalUpdateInterval,
  graphql.QueryResult<Mutation$UpdateGlobalUpdateInterval>?,
);

class Mutation$UpdateGlobalUpdateInterval$Widget
    extends graphql_flutter.Mutation<Mutation$UpdateGlobalUpdateInterval> {
  Mutation$UpdateGlobalUpdateInterval$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$UpdateGlobalUpdateInterval? options,
    required Builder$Mutation$UpdateGlobalUpdateInterval builder,
  }) : super(
          key: key,
          options:
              options ?? WidgetOptions$Mutation$UpdateGlobalUpdateInterval(),
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

class Mutation$UpdateGlobalUpdateInterval$setSettings {
  Mutation$UpdateGlobalUpdateInterval$setSettings({
    required this.settings,
    this.$__typename = 'SetSettingsPayload',
  });

  factory Mutation$UpdateGlobalUpdateInterval$setSettings.fromJson(
      Map<String, dynamic> json) {
    final l$settings = json['settings'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateGlobalUpdateInterval$setSettings(
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
    if (other is! Mutation$UpdateGlobalUpdateInterval$setSettings ||
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

extension UtilityExtension$Mutation$UpdateGlobalUpdateInterval$setSettings
    on Mutation$UpdateGlobalUpdateInterval$setSettings {
  CopyWith$Mutation$UpdateGlobalUpdateInterval$setSettings<
          Mutation$UpdateGlobalUpdateInterval$setSettings>
      get copyWith => CopyWith$Mutation$UpdateGlobalUpdateInterval$setSettings(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdateGlobalUpdateInterval$setSettings<TRes> {
  factory CopyWith$Mutation$UpdateGlobalUpdateInterval$setSettings(
    Mutation$UpdateGlobalUpdateInterval$setSettings instance,
    TRes Function(Mutation$UpdateGlobalUpdateInterval$setSettings) then,
  ) = _CopyWithImpl$Mutation$UpdateGlobalUpdateInterval$setSettings;

  factory CopyWith$Mutation$UpdateGlobalUpdateInterval$setSettings.stub(
          TRes res) =
      _CopyWithStubImpl$Mutation$UpdateGlobalUpdateInterval$setSettings;

  TRes call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  });
  CopyWith$Fragment$SettingsDto<TRes> get settings;
}

class _CopyWithImpl$Mutation$UpdateGlobalUpdateInterval$setSettings<TRes>
    implements CopyWith$Mutation$UpdateGlobalUpdateInterval$setSettings<TRes> {
  _CopyWithImpl$Mutation$UpdateGlobalUpdateInterval$setSettings(
    this._instance,
    this._then,
  );

  final Mutation$UpdateGlobalUpdateInterval$setSettings _instance;

  final TRes Function(Mutation$UpdateGlobalUpdateInterval$setSettings) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? settings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateGlobalUpdateInterval$setSettings(
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

class _CopyWithStubImpl$Mutation$UpdateGlobalUpdateInterval$setSettings<TRes>
    implements CopyWith$Mutation$UpdateGlobalUpdateInterval$setSettings<TRes> {
  _CopyWithStubImpl$Mutation$UpdateGlobalUpdateInterval$setSettings(this._res);

  TRes _res;

  call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$SettingsDto<TRes> get settings =>
      CopyWith$Fragment$SettingsDto.stub(_res);
}

class Variables$Mutation$ToggleExcludeNotStarted {
  factory Variables$Mutation$ToggleExcludeNotStarted(
          {bool? excludeNotStarted}) =>
      Variables$Mutation$ToggleExcludeNotStarted._({
        if (excludeNotStarted != null) r'excludeNotStarted': excludeNotStarted,
      });

  Variables$Mutation$ToggleExcludeNotStarted._(this._$data);

  factory Variables$Mutation$ToggleExcludeNotStarted.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('excludeNotStarted')) {
      final l$excludeNotStarted = data['excludeNotStarted'];
      result$data['excludeNotStarted'] = (l$excludeNotStarted as bool?);
    }
    return Variables$Mutation$ToggleExcludeNotStarted._(result$data);
  }

  Map<String, dynamic> _$data;

  bool? get excludeNotStarted => (_$data['excludeNotStarted'] as bool?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('excludeNotStarted')) {
      final l$excludeNotStarted = excludeNotStarted;
      result$data['excludeNotStarted'] = l$excludeNotStarted;
    }
    return result$data;
  }

  CopyWith$Variables$Mutation$ToggleExcludeNotStarted<
          Variables$Mutation$ToggleExcludeNotStarted>
      get copyWith => CopyWith$Variables$Mutation$ToggleExcludeNotStarted(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$ToggleExcludeNotStarted ||
        runtimeType != other.runtimeType) {
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
    return true;
  }

  @override
  int get hashCode {
    final l$excludeNotStarted = excludeNotStarted;
    return Object.hashAll([
      _$data.containsKey('excludeNotStarted') ? l$excludeNotStarted : const {}
    ]);
  }
}

abstract class CopyWith$Variables$Mutation$ToggleExcludeNotStarted<TRes> {
  factory CopyWith$Variables$Mutation$ToggleExcludeNotStarted(
    Variables$Mutation$ToggleExcludeNotStarted instance,
    TRes Function(Variables$Mutation$ToggleExcludeNotStarted) then,
  ) = _CopyWithImpl$Variables$Mutation$ToggleExcludeNotStarted;

  factory CopyWith$Variables$Mutation$ToggleExcludeNotStarted.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$ToggleExcludeNotStarted;

  TRes call({bool? excludeNotStarted});
}

class _CopyWithImpl$Variables$Mutation$ToggleExcludeNotStarted<TRes>
    implements CopyWith$Variables$Mutation$ToggleExcludeNotStarted<TRes> {
  _CopyWithImpl$Variables$Mutation$ToggleExcludeNotStarted(
    this._instance,
    this._then,
  );

  final Variables$Mutation$ToggleExcludeNotStarted _instance;

  final TRes Function(Variables$Mutation$ToggleExcludeNotStarted) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? excludeNotStarted = _undefined}) =>
      _then(Variables$Mutation$ToggleExcludeNotStarted._({
        ..._instance._$data,
        if (excludeNotStarted != _undefined)
          'excludeNotStarted': (excludeNotStarted as bool?),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$ToggleExcludeNotStarted<TRes>
    implements CopyWith$Variables$Mutation$ToggleExcludeNotStarted<TRes> {
  _CopyWithStubImpl$Variables$Mutation$ToggleExcludeNotStarted(this._res);

  TRes _res;

  call({bool? excludeNotStarted}) => _res;
}

class Mutation$ToggleExcludeNotStarted {
  Mutation$ToggleExcludeNotStarted({
    required this.setSettings,
    this.$__typename = 'Mutation',
  });

  factory Mutation$ToggleExcludeNotStarted.fromJson(Map<String, dynamic> json) {
    final l$setSettings = json['setSettings'];
    final l$$__typename = json['__typename'];
    return Mutation$ToggleExcludeNotStarted(
      setSettings: Mutation$ToggleExcludeNotStarted$setSettings.fromJson(
          (l$setSettings as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$ToggleExcludeNotStarted$setSettings setSettings;

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
    if (other is! Mutation$ToggleExcludeNotStarted ||
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

extension UtilityExtension$Mutation$ToggleExcludeNotStarted
    on Mutation$ToggleExcludeNotStarted {
  CopyWith$Mutation$ToggleExcludeNotStarted<Mutation$ToggleExcludeNotStarted>
      get copyWith => CopyWith$Mutation$ToggleExcludeNotStarted(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$ToggleExcludeNotStarted<TRes> {
  factory CopyWith$Mutation$ToggleExcludeNotStarted(
    Mutation$ToggleExcludeNotStarted instance,
    TRes Function(Mutation$ToggleExcludeNotStarted) then,
  ) = _CopyWithImpl$Mutation$ToggleExcludeNotStarted;

  factory CopyWith$Mutation$ToggleExcludeNotStarted.stub(TRes res) =
      _CopyWithStubImpl$Mutation$ToggleExcludeNotStarted;

  TRes call({
    Mutation$ToggleExcludeNotStarted$setSettings? setSettings,
    String? $__typename,
  });
  CopyWith$Mutation$ToggleExcludeNotStarted$setSettings<TRes> get setSettings;
}

class _CopyWithImpl$Mutation$ToggleExcludeNotStarted<TRes>
    implements CopyWith$Mutation$ToggleExcludeNotStarted<TRes> {
  _CopyWithImpl$Mutation$ToggleExcludeNotStarted(
    this._instance,
    this._then,
  );

  final Mutation$ToggleExcludeNotStarted _instance;

  final TRes Function(Mutation$ToggleExcludeNotStarted) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? setSettings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$ToggleExcludeNotStarted(
        setSettings: setSettings == _undefined || setSettings == null
            ? _instance.setSettings
            : (setSettings as Mutation$ToggleExcludeNotStarted$setSettings),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$ToggleExcludeNotStarted$setSettings<TRes> get setSettings {
    final local$setSettings = _instance.setSettings;
    return CopyWith$Mutation$ToggleExcludeNotStarted$setSettings(
        local$setSettings, (e) => call(setSettings: e));
  }
}

class _CopyWithStubImpl$Mutation$ToggleExcludeNotStarted<TRes>
    implements CopyWith$Mutation$ToggleExcludeNotStarted<TRes> {
  _CopyWithStubImpl$Mutation$ToggleExcludeNotStarted(this._res);

  TRes _res;

  call({
    Mutation$ToggleExcludeNotStarted$setSettings? setSettings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$ToggleExcludeNotStarted$setSettings<TRes> get setSettings =>
      CopyWith$Mutation$ToggleExcludeNotStarted$setSettings.stub(_res);
}

const documentNodeMutationToggleExcludeNotStarted = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'ToggleExcludeNotStarted'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'excludeNotStarted')),
        type: NamedTypeNode(
          name: NameNode(value: 'Boolean'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: BooleanValueNode(value: false)),
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
                    name: NameNode(value: 'excludeNotStarted'),
                    value: VariableNode(
                        name: NameNode(value: 'excludeNotStarted')),
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
Mutation$ToggleExcludeNotStarted _parserFn$Mutation$ToggleExcludeNotStarted(
        Map<String, dynamic> data) =>
    Mutation$ToggleExcludeNotStarted.fromJson(data);
typedef OnMutationCompleted$Mutation$ToggleExcludeNotStarted = FutureOr<void>
    Function(
  Map<String, dynamic>?,
  Mutation$ToggleExcludeNotStarted?,
);

class Options$Mutation$ToggleExcludeNotStarted
    extends graphql.MutationOptions<Mutation$ToggleExcludeNotStarted> {
  Options$Mutation$ToggleExcludeNotStarted({
    String? operationName,
    Variables$Mutation$ToggleExcludeNotStarted? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$ToggleExcludeNotStarted? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$ToggleExcludeNotStarted? onCompleted,
    graphql.OnMutationUpdate<Mutation$ToggleExcludeNotStarted>? update,
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
                        : _parserFn$Mutation$ToggleExcludeNotStarted(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationToggleExcludeNotStarted,
          parserFn: _parserFn$Mutation$ToggleExcludeNotStarted,
        );

  final OnMutationCompleted$Mutation$ToggleExcludeNotStarted?
      onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$ToggleExcludeNotStarted
    extends graphql.WatchQueryOptions<Mutation$ToggleExcludeNotStarted> {
  WatchOptions$Mutation$ToggleExcludeNotStarted({
    String? operationName,
    Variables$Mutation$ToggleExcludeNotStarted? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$ToggleExcludeNotStarted? typedOptimisticResult,
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
          document: documentNodeMutationToggleExcludeNotStarted,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$ToggleExcludeNotStarted,
        );
}

extension ClientExtension$Mutation$ToggleExcludeNotStarted
    on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$ToggleExcludeNotStarted>>
      mutate$ToggleExcludeNotStarted(
              [Options$Mutation$ToggleExcludeNotStarted? options]) async =>
          await this
              .mutate(options ?? Options$Mutation$ToggleExcludeNotStarted());

  graphql.ObservableQuery<Mutation$ToggleExcludeNotStarted>
      watchMutation$ToggleExcludeNotStarted(
              [WatchOptions$Mutation$ToggleExcludeNotStarted? options]) =>
          this.watchMutation(
              options ?? WatchOptions$Mutation$ToggleExcludeNotStarted());
}

class Mutation$ToggleExcludeNotStarted$HookResult {
  Mutation$ToggleExcludeNotStarted$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$ToggleExcludeNotStarted runMutation;

  final graphql.QueryResult<Mutation$ToggleExcludeNotStarted> result;
}

Mutation$ToggleExcludeNotStarted$HookResult useMutation$ToggleExcludeNotStarted(
    [WidgetOptions$Mutation$ToggleExcludeNotStarted? options]) {
  final result = graphql_flutter
      .useMutation(options ?? WidgetOptions$Mutation$ToggleExcludeNotStarted());
  return Mutation$ToggleExcludeNotStarted$HookResult(
    ({variables, optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables?.toJson() ?? const {},
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$ToggleExcludeNotStarted>
    useWatchMutation$ToggleExcludeNotStarted(
            [WatchOptions$Mutation$ToggleExcludeNotStarted? options]) =>
        graphql_flutter.useWatchMutation(
            options ?? WatchOptions$Mutation$ToggleExcludeNotStarted());

class WidgetOptions$Mutation$ToggleExcludeNotStarted
    extends graphql.MutationOptions<Mutation$ToggleExcludeNotStarted> {
  WidgetOptions$Mutation$ToggleExcludeNotStarted({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$ToggleExcludeNotStarted? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$ToggleExcludeNotStarted? onCompleted,
    graphql.OnMutationUpdate<Mutation$ToggleExcludeNotStarted>? update,
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
                        : _parserFn$Mutation$ToggleExcludeNotStarted(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationToggleExcludeNotStarted,
          parserFn: _parserFn$Mutation$ToggleExcludeNotStarted,
        );

  final OnMutationCompleted$Mutation$ToggleExcludeNotStarted?
      onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$ToggleExcludeNotStarted
    = graphql.MultiSourceResult<Mutation$ToggleExcludeNotStarted> Function({
  Variables$Mutation$ToggleExcludeNotStarted? variables,
  Object? optimisticResult,
  Mutation$ToggleExcludeNotStarted? typedOptimisticResult,
});
typedef Builder$Mutation$ToggleExcludeNotStarted = widgets.Widget Function(
  RunMutation$Mutation$ToggleExcludeNotStarted,
  graphql.QueryResult<Mutation$ToggleExcludeNotStarted>?,
);

class Mutation$ToggleExcludeNotStarted$Widget
    extends graphql_flutter.Mutation<Mutation$ToggleExcludeNotStarted> {
  Mutation$ToggleExcludeNotStarted$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$ToggleExcludeNotStarted? options,
    required Builder$Mutation$ToggleExcludeNotStarted builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$ToggleExcludeNotStarted(),
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

class Mutation$ToggleExcludeNotStarted$setSettings {
  Mutation$ToggleExcludeNotStarted$setSettings({
    required this.settings,
    this.$__typename = 'SetSettingsPayload',
  });

  factory Mutation$ToggleExcludeNotStarted$setSettings.fromJson(
      Map<String, dynamic> json) {
    final l$settings = json['settings'];
    final l$$__typename = json['__typename'];
    return Mutation$ToggleExcludeNotStarted$setSettings(
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
    if (other is! Mutation$ToggleExcludeNotStarted$setSettings ||
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

extension UtilityExtension$Mutation$ToggleExcludeNotStarted$setSettings
    on Mutation$ToggleExcludeNotStarted$setSettings {
  CopyWith$Mutation$ToggleExcludeNotStarted$setSettings<
          Mutation$ToggleExcludeNotStarted$setSettings>
      get copyWith => CopyWith$Mutation$ToggleExcludeNotStarted$setSettings(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$ToggleExcludeNotStarted$setSettings<TRes> {
  factory CopyWith$Mutation$ToggleExcludeNotStarted$setSettings(
    Mutation$ToggleExcludeNotStarted$setSettings instance,
    TRes Function(Mutation$ToggleExcludeNotStarted$setSettings) then,
  ) = _CopyWithImpl$Mutation$ToggleExcludeNotStarted$setSettings;

  factory CopyWith$Mutation$ToggleExcludeNotStarted$setSettings.stub(TRes res) =
      _CopyWithStubImpl$Mutation$ToggleExcludeNotStarted$setSettings;

  TRes call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  });
  CopyWith$Fragment$SettingsDto<TRes> get settings;
}

class _CopyWithImpl$Mutation$ToggleExcludeNotStarted$setSettings<TRes>
    implements CopyWith$Mutation$ToggleExcludeNotStarted$setSettings<TRes> {
  _CopyWithImpl$Mutation$ToggleExcludeNotStarted$setSettings(
    this._instance,
    this._then,
  );

  final Mutation$ToggleExcludeNotStarted$setSettings _instance;

  final TRes Function(Mutation$ToggleExcludeNotStarted$setSettings) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? settings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$ToggleExcludeNotStarted$setSettings(
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

class _CopyWithStubImpl$Mutation$ToggleExcludeNotStarted$setSettings<TRes>
    implements CopyWith$Mutation$ToggleExcludeNotStarted$setSettings<TRes> {
  _CopyWithStubImpl$Mutation$ToggleExcludeNotStarted$setSettings(this._res);

  TRes _res;

  call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$SettingsDto<TRes> get settings =>
      CopyWith$Fragment$SettingsDto.stub(_res);
}

class Variables$Mutation$ToggleExcludeUnreadChapters {
  factory Variables$Mutation$ToggleExcludeUnreadChapters(
          {bool? excludeUnreadChapters}) =>
      Variables$Mutation$ToggleExcludeUnreadChapters._({
        if (excludeUnreadChapters != null)
          r'excludeUnreadChapters': excludeUnreadChapters,
      });

  Variables$Mutation$ToggleExcludeUnreadChapters._(this._$data);

  factory Variables$Mutation$ToggleExcludeUnreadChapters.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('excludeUnreadChapters')) {
      final l$excludeUnreadChapters = data['excludeUnreadChapters'];
      result$data['excludeUnreadChapters'] = (l$excludeUnreadChapters as bool?);
    }
    return Variables$Mutation$ToggleExcludeUnreadChapters._(result$data);
  }

  Map<String, dynamic> _$data;

  bool? get excludeUnreadChapters => (_$data['excludeUnreadChapters'] as bool?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('excludeUnreadChapters')) {
      final l$excludeUnreadChapters = excludeUnreadChapters;
      result$data['excludeUnreadChapters'] = l$excludeUnreadChapters;
    }
    return result$data;
  }

  CopyWith$Variables$Mutation$ToggleExcludeUnreadChapters<
          Variables$Mutation$ToggleExcludeUnreadChapters>
      get copyWith => CopyWith$Variables$Mutation$ToggleExcludeUnreadChapters(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$ToggleExcludeUnreadChapters ||
        runtimeType != other.runtimeType) {
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
    return true;
  }

  @override
  int get hashCode {
    final l$excludeUnreadChapters = excludeUnreadChapters;
    return Object.hashAll([
      _$data.containsKey('excludeUnreadChapters')
          ? l$excludeUnreadChapters
          : const {}
    ]);
  }
}

abstract class CopyWith$Variables$Mutation$ToggleExcludeUnreadChapters<TRes> {
  factory CopyWith$Variables$Mutation$ToggleExcludeUnreadChapters(
    Variables$Mutation$ToggleExcludeUnreadChapters instance,
    TRes Function(Variables$Mutation$ToggleExcludeUnreadChapters) then,
  ) = _CopyWithImpl$Variables$Mutation$ToggleExcludeUnreadChapters;

  factory CopyWith$Variables$Mutation$ToggleExcludeUnreadChapters.stub(
          TRes res) =
      _CopyWithStubImpl$Variables$Mutation$ToggleExcludeUnreadChapters;

  TRes call({bool? excludeUnreadChapters});
}

class _CopyWithImpl$Variables$Mutation$ToggleExcludeUnreadChapters<TRes>
    implements CopyWith$Variables$Mutation$ToggleExcludeUnreadChapters<TRes> {
  _CopyWithImpl$Variables$Mutation$ToggleExcludeUnreadChapters(
    this._instance,
    this._then,
  );

  final Variables$Mutation$ToggleExcludeUnreadChapters _instance;

  final TRes Function(Variables$Mutation$ToggleExcludeUnreadChapters) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? excludeUnreadChapters = _undefined}) =>
      _then(Variables$Mutation$ToggleExcludeUnreadChapters._({
        ..._instance._$data,
        if (excludeUnreadChapters != _undefined)
          'excludeUnreadChapters': (excludeUnreadChapters as bool?),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$ToggleExcludeUnreadChapters<TRes>
    implements CopyWith$Variables$Mutation$ToggleExcludeUnreadChapters<TRes> {
  _CopyWithStubImpl$Variables$Mutation$ToggleExcludeUnreadChapters(this._res);

  TRes _res;

  call({bool? excludeUnreadChapters}) => _res;
}

class Mutation$ToggleExcludeUnreadChapters {
  Mutation$ToggleExcludeUnreadChapters({
    required this.setSettings,
    this.$__typename = 'Mutation',
  });

  factory Mutation$ToggleExcludeUnreadChapters.fromJson(
      Map<String, dynamic> json) {
    final l$setSettings = json['setSettings'];
    final l$$__typename = json['__typename'];
    return Mutation$ToggleExcludeUnreadChapters(
      setSettings: Mutation$ToggleExcludeUnreadChapters$setSettings.fromJson(
          (l$setSettings as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$ToggleExcludeUnreadChapters$setSettings setSettings;

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
    if (other is! Mutation$ToggleExcludeUnreadChapters ||
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

extension UtilityExtension$Mutation$ToggleExcludeUnreadChapters
    on Mutation$ToggleExcludeUnreadChapters {
  CopyWith$Mutation$ToggleExcludeUnreadChapters<
          Mutation$ToggleExcludeUnreadChapters>
      get copyWith => CopyWith$Mutation$ToggleExcludeUnreadChapters(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$ToggleExcludeUnreadChapters<TRes> {
  factory CopyWith$Mutation$ToggleExcludeUnreadChapters(
    Mutation$ToggleExcludeUnreadChapters instance,
    TRes Function(Mutation$ToggleExcludeUnreadChapters) then,
  ) = _CopyWithImpl$Mutation$ToggleExcludeUnreadChapters;

  factory CopyWith$Mutation$ToggleExcludeUnreadChapters.stub(TRes res) =
      _CopyWithStubImpl$Mutation$ToggleExcludeUnreadChapters;

  TRes call({
    Mutation$ToggleExcludeUnreadChapters$setSettings? setSettings,
    String? $__typename,
  });
  CopyWith$Mutation$ToggleExcludeUnreadChapters$setSettings<TRes>
      get setSettings;
}

class _CopyWithImpl$Mutation$ToggleExcludeUnreadChapters<TRes>
    implements CopyWith$Mutation$ToggleExcludeUnreadChapters<TRes> {
  _CopyWithImpl$Mutation$ToggleExcludeUnreadChapters(
    this._instance,
    this._then,
  );

  final Mutation$ToggleExcludeUnreadChapters _instance;

  final TRes Function(Mutation$ToggleExcludeUnreadChapters) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? setSettings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$ToggleExcludeUnreadChapters(
        setSettings: setSettings == _undefined || setSettings == null
            ? _instance.setSettings
            : (setSettings as Mutation$ToggleExcludeUnreadChapters$setSettings),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$ToggleExcludeUnreadChapters$setSettings<TRes>
      get setSettings {
    final local$setSettings = _instance.setSettings;
    return CopyWith$Mutation$ToggleExcludeUnreadChapters$setSettings(
        local$setSettings, (e) => call(setSettings: e));
  }
}

class _CopyWithStubImpl$Mutation$ToggleExcludeUnreadChapters<TRes>
    implements CopyWith$Mutation$ToggleExcludeUnreadChapters<TRes> {
  _CopyWithStubImpl$Mutation$ToggleExcludeUnreadChapters(this._res);

  TRes _res;

  call({
    Mutation$ToggleExcludeUnreadChapters$setSettings? setSettings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$ToggleExcludeUnreadChapters$setSettings<TRes>
      get setSettings =>
          CopyWith$Mutation$ToggleExcludeUnreadChapters$setSettings.stub(_res);
}

const documentNodeMutationToggleExcludeUnreadChapters =
    DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'ToggleExcludeUnreadChapters'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'excludeUnreadChapters')),
        type: NamedTypeNode(
          name: NameNode(value: 'Boolean'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: BooleanValueNode(value: false)),
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
                    name: NameNode(value: 'excludeUnreadChapters'),
                    value: VariableNode(
                        name: NameNode(value: 'excludeUnreadChapters')),
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
Mutation$ToggleExcludeUnreadChapters
    _parserFn$Mutation$ToggleExcludeUnreadChapters(Map<String, dynamic> data) =>
        Mutation$ToggleExcludeUnreadChapters.fromJson(data);
typedef OnMutationCompleted$Mutation$ToggleExcludeUnreadChapters
    = FutureOr<void> Function(
  Map<String, dynamic>?,
  Mutation$ToggleExcludeUnreadChapters?,
);

class Options$Mutation$ToggleExcludeUnreadChapters
    extends graphql.MutationOptions<Mutation$ToggleExcludeUnreadChapters> {
  Options$Mutation$ToggleExcludeUnreadChapters({
    String? operationName,
    Variables$Mutation$ToggleExcludeUnreadChapters? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$ToggleExcludeUnreadChapters? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$ToggleExcludeUnreadChapters? onCompleted,
    graphql.OnMutationUpdate<Mutation$ToggleExcludeUnreadChapters>? update,
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
                        : _parserFn$Mutation$ToggleExcludeUnreadChapters(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationToggleExcludeUnreadChapters,
          parserFn: _parserFn$Mutation$ToggleExcludeUnreadChapters,
        );

  final OnMutationCompleted$Mutation$ToggleExcludeUnreadChapters?
      onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$ToggleExcludeUnreadChapters
    extends graphql.WatchQueryOptions<Mutation$ToggleExcludeUnreadChapters> {
  WatchOptions$Mutation$ToggleExcludeUnreadChapters({
    String? operationName,
    Variables$Mutation$ToggleExcludeUnreadChapters? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$ToggleExcludeUnreadChapters? typedOptimisticResult,
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
          document: documentNodeMutationToggleExcludeUnreadChapters,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$ToggleExcludeUnreadChapters,
        );
}

extension ClientExtension$Mutation$ToggleExcludeUnreadChapters
    on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$ToggleExcludeUnreadChapters>>
      mutate$ToggleExcludeUnreadChapters(
              [Options$Mutation$ToggleExcludeUnreadChapters? options]) async =>
          await this.mutate(
              options ?? Options$Mutation$ToggleExcludeUnreadChapters());

  graphql.ObservableQuery<Mutation$ToggleExcludeUnreadChapters>
      watchMutation$ToggleExcludeUnreadChapters(
              [WatchOptions$Mutation$ToggleExcludeUnreadChapters? options]) =>
          this.watchMutation(
              options ?? WatchOptions$Mutation$ToggleExcludeUnreadChapters());
}

class Mutation$ToggleExcludeUnreadChapters$HookResult {
  Mutation$ToggleExcludeUnreadChapters$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$ToggleExcludeUnreadChapters runMutation;

  final graphql.QueryResult<Mutation$ToggleExcludeUnreadChapters> result;
}

Mutation$ToggleExcludeUnreadChapters$HookResult
    useMutation$ToggleExcludeUnreadChapters(
        [WidgetOptions$Mutation$ToggleExcludeUnreadChapters? options]) {
  final result = graphql_flutter.useMutation(
      options ?? WidgetOptions$Mutation$ToggleExcludeUnreadChapters());
  return Mutation$ToggleExcludeUnreadChapters$HookResult(
    ({variables, optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables?.toJson() ?? const {},
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$ToggleExcludeUnreadChapters>
    useWatchMutation$ToggleExcludeUnreadChapters(
            [WatchOptions$Mutation$ToggleExcludeUnreadChapters? options]) =>
        graphql_flutter.useWatchMutation(
            options ?? WatchOptions$Mutation$ToggleExcludeUnreadChapters());

class WidgetOptions$Mutation$ToggleExcludeUnreadChapters
    extends graphql.MutationOptions<Mutation$ToggleExcludeUnreadChapters> {
  WidgetOptions$Mutation$ToggleExcludeUnreadChapters({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$ToggleExcludeUnreadChapters? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$ToggleExcludeUnreadChapters? onCompleted,
    graphql.OnMutationUpdate<Mutation$ToggleExcludeUnreadChapters>? update,
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
                        : _parserFn$Mutation$ToggleExcludeUnreadChapters(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationToggleExcludeUnreadChapters,
          parserFn: _parserFn$Mutation$ToggleExcludeUnreadChapters,
        );

  final OnMutationCompleted$Mutation$ToggleExcludeUnreadChapters?
      onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$ToggleExcludeUnreadChapters
    = graphql.MultiSourceResult<Mutation$ToggleExcludeUnreadChapters> Function({
  Variables$Mutation$ToggleExcludeUnreadChapters? variables,
  Object? optimisticResult,
  Mutation$ToggleExcludeUnreadChapters? typedOptimisticResult,
});
typedef Builder$Mutation$ToggleExcludeUnreadChapters = widgets.Widget Function(
  RunMutation$Mutation$ToggleExcludeUnreadChapters,
  graphql.QueryResult<Mutation$ToggleExcludeUnreadChapters>?,
);

class Mutation$ToggleExcludeUnreadChapters$Widget
    extends graphql_flutter.Mutation<Mutation$ToggleExcludeUnreadChapters> {
  Mutation$ToggleExcludeUnreadChapters$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$ToggleExcludeUnreadChapters? options,
    required Builder$Mutation$ToggleExcludeUnreadChapters builder,
  }) : super(
          key: key,
          options:
              options ?? WidgetOptions$Mutation$ToggleExcludeUnreadChapters(),
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

class Mutation$ToggleExcludeUnreadChapters$setSettings {
  Mutation$ToggleExcludeUnreadChapters$setSettings({
    required this.settings,
    this.$__typename = 'SetSettingsPayload',
  });

  factory Mutation$ToggleExcludeUnreadChapters$setSettings.fromJson(
      Map<String, dynamic> json) {
    final l$settings = json['settings'];
    final l$$__typename = json['__typename'];
    return Mutation$ToggleExcludeUnreadChapters$setSettings(
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
    if (other is! Mutation$ToggleExcludeUnreadChapters$setSettings ||
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

extension UtilityExtension$Mutation$ToggleExcludeUnreadChapters$setSettings
    on Mutation$ToggleExcludeUnreadChapters$setSettings {
  CopyWith$Mutation$ToggleExcludeUnreadChapters$setSettings<
          Mutation$ToggleExcludeUnreadChapters$setSettings>
      get copyWith => CopyWith$Mutation$ToggleExcludeUnreadChapters$setSettings(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$ToggleExcludeUnreadChapters$setSettings<TRes> {
  factory CopyWith$Mutation$ToggleExcludeUnreadChapters$setSettings(
    Mutation$ToggleExcludeUnreadChapters$setSettings instance,
    TRes Function(Mutation$ToggleExcludeUnreadChapters$setSettings) then,
  ) = _CopyWithImpl$Mutation$ToggleExcludeUnreadChapters$setSettings;

  factory CopyWith$Mutation$ToggleExcludeUnreadChapters$setSettings.stub(
          TRes res) =
      _CopyWithStubImpl$Mutation$ToggleExcludeUnreadChapters$setSettings;

  TRes call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  });
  CopyWith$Fragment$SettingsDto<TRes> get settings;
}

class _CopyWithImpl$Mutation$ToggleExcludeUnreadChapters$setSettings<TRes>
    implements CopyWith$Mutation$ToggleExcludeUnreadChapters$setSettings<TRes> {
  _CopyWithImpl$Mutation$ToggleExcludeUnreadChapters$setSettings(
    this._instance,
    this._then,
  );

  final Mutation$ToggleExcludeUnreadChapters$setSettings _instance;

  final TRes Function(Mutation$ToggleExcludeUnreadChapters$setSettings) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? settings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$ToggleExcludeUnreadChapters$setSettings(
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

class _CopyWithStubImpl$Mutation$ToggleExcludeUnreadChapters$setSettings<TRes>
    implements CopyWith$Mutation$ToggleExcludeUnreadChapters$setSettings<TRes> {
  _CopyWithStubImpl$Mutation$ToggleExcludeUnreadChapters$setSettings(this._res);

  TRes _res;

  call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$SettingsDto<TRes> get settings =>
      CopyWith$Fragment$SettingsDto.stub(_res);
}

class Variables$Mutation$ToggleExcludeCompleted {
  factory Variables$Mutation$ToggleExcludeCompleted({bool? excludeCompleted}) =>
      Variables$Mutation$ToggleExcludeCompleted._({
        if (excludeCompleted != null) r'excludeCompleted': excludeCompleted,
      });

  Variables$Mutation$ToggleExcludeCompleted._(this._$data);

  factory Variables$Mutation$ToggleExcludeCompleted.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('excludeCompleted')) {
      final l$excludeCompleted = data['excludeCompleted'];
      result$data['excludeCompleted'] = (l$excludeCompleted as bool?);
    }
    return Variables$Mutation$ToggleExcludeCompleted._(result$data);
  }

  Map<String, dynamic> _$data;

  bool? get excludeCompleted => (_$data['excludeCompleted'] as bool?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('excludeCompleted')) {
      final l$excludeCompleted = excludeCompleted;
      result$data['excludeCompleted'] = l$excludeCompleted;
    }
    return result$data;
  }

  CopyWith$Variables$Mutation$ToggleExcludeCompleted<
          Variables$Mutation$ToggleExcludeCompleted>
      get copyWith => CopyWith$Variables$Mutation$ToggleExcludeCompleted(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$ToggleExcludeCompleted ||
        runtimeType != other.runtimeType) {
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
    return true;
  }

  @override
  int get hashCode {
    final l$excludeCompleted = excludeCompleted;
    return Object.hashAll([
      _$data.containsKey('excludeCompleted') ? l$excludeCompleted : const {}
    ]);
  }
}

abstract class CopyWith$Variables$Mutation$ToggleExcludeCompleted<TRes> {
  factory CopyWith$Variables$Mutation$ToggleExcludeCompleted(
    Variables$Mutation$ToggleExcludeCompleted instance,
    TRes Function(Variables$Mutation$ToggleExcludeCompleted) then,
  ) = _CopyWithImpl$Variables$Mutation$ToggleExcludeCompleted;

  factory CopyWith$Variables$Mutation$ToggleExcludeCompleted.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$ToggleExcludeCompleted;

  TRes call({bool? excludeCompleted});
}

class _CopyWithImpl$Variables$Mutation$ToggleExcludeCompleted<TRes>
    implements CopyWith$Variables$Mutation$ToggleExcludeCompleted<TRes> {
  _CopyWithImpl$Variables$Mutation$ToggleExcludeCompleted(
    this._instance,
    this._then,
  );

  final Variables$Mutation$ToggleExcludeCompleted _instance;

  final TRes Function(Variables$Mutation$ToggleExcludeCompleted) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? excludeCompleted = _undefined}) =>
      _then(Variables$Mutation$ToggleExcludeCompleted._({
        ..._instance._$data,
        if (excludeCompleted != _undefined)
          'excludeCompleted': (excludeCompleted as bool?),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$ToggleExcludeCompleted<TRes>
    implements CopyWith$Variables$Mutation$ToggleExcludeCompleted<TRes> {
  _CopyWithStubImpl$Variables$Mutation$ToggleExcludeCompleted(this._res);

  TRes _res;

  call({bool? excludeCompleted}) => _res;
}

class Mutation$ToggleExcludeCompleted {
  Mutation$ToggleExcludeCompleted({
    required this.setSettings,
    this.$__typename = 'Mutation',
  });

  factory Mutation$ToggleExcludeCompleted.fromJson(Map<String, dynamic> json) {
    final l$setSettings = json['setSettings'];
    final l$$__typename = json['__typename'];
    return Mutation$ToggleExcludeCompleted(
      setSettings: Mutation$ToggleExcludeCompleted$setSettings.fromJson(
          (l$setSettings as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$ToggleExcludeCompleted$setSettings setSettings;

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
    if (other is! Mutation$ToggleExcludeCompleted ||
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

extension UtilityExtension$Mutation$ToggleExcludeCompleted
    on Mutation$ToggleExcludeCompleted {
  CopyWith$Mutation$ToggleExcludeCompleted<Mutation$ToggleExcludeCompleted>
      get copyWith => CopyWith$Mutation$ToggleExcludeCompleted(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$ToggleExcludeCompleted<TRes> {
  factory CopyWith$Mutation$ToggleExcludeCompleted(
    Mutation$ToggleExcludeCompleted instance,
    TRes Function(Mutation$ToggleExcludeCompleted) then,
  ) = _CopyWithImpl$Mutation$ToggleExcludeCompleted;

  factory CopyWith$Mutation$ToggleExcludeCompleted.stub(TRes res) =
      _CopyWithStubImpl$Mutation$ToggleExcludeCompleted;

  TRes call({
    Mutation$ToggleExcludeCompleted$setSettings? setSettings,
    String? $__typename,
  });
  CopyWith$Mutation$ToggleExcludeCompleted$setSettings<TRes> get setSettings;
}

class _CopyWithImpl$Mutation$ToggleExcludeCompleted<TRes>
    implements CopyWith$Mutation$ToggleExcludeCompleted<TRes> {
  _CopyWithImpl$Mutation$ToggleExcludeCompleted(
    this._instance,
    this._then,
  );

  final Mutation$ToggleExcludeCompleted _instance;

  final TRes Function(Mutation$ToggleExcludeCompleted) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? setSettings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$ToggleExcludeCompleted(
        setSettings: setSettings == _undefined || setSettings == null
            ? _instance.setSettings
            : (setSettings as Mutation$ToggleExcludeCompleted$setSettings),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$ToggleExcludeCompleted$setSettings<TRes> get setSettings {
    final local$setSettings = _instance.setSettings;
    return CopyWith$Mutation$ToggleExcludeCompleted$setSettings(
        local$setSettings, (e) => call(setSettings: e));
  }
}

class _CopyWithStubImpl$Mutation$ToggleExcludeCompleted<TRes>
    implements CopyWith$Mutation$ToggleExcludeCompleted<TRes> {
  _CopyWithStubImpl$Mutation$ToggleExcludeCompleted(this._res);

  TRes _res;

  call({
    Mutation$ToggleExcludeCompleted$setSettings? setSettings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$ToggleExcludeCompleted$setSettings<TRes> get setSettings =>
      CopyWith$Mutation$ToggleExcludeCompleted$setSettings.stub(_res);
}

const documentNodeMutationToggleExcludeCompleted = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'ToggleExcludeCompleted'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'excludeCompleted')),
        type: NamedTypeNode(
          name: NameNode(value: 'Boolean'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: BooleanValueNode(value: false)),
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
                    name: NameNode(value: 'excludeCompleted'),
                    value:
                        VariableNode(name: NameNode(value: 'excludeCompleted')),
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
Mutation$ToggleExcludeCompleted _parserFn$Mutation$ToggleExcludeCompleted(
        Map<String, dynamic> data) =>
    Mutation$ToggleExcludeCompleted.fromJson(data);
typedef OnMutationCompleted$Mutation$ToggleExcludeCompleted = FutureOr<void>
    Function(
  Map<String, dynamic>?,
  Mutation$ToggleExcludeCompleted?,
);

class Options$Mutation$ToggleExcludeCompleted
    extends graphql.MutationOptions<Mutation$ToggleExcludeCompleted> {
  Options$Mutation$ToggleExcludeCompleted({
    String? operationName,
    Variables$Mutation$ToggleExcludeCompleted? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$ToggleExcludeCompleted? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$ToggleExcludeCompleted? onCompleted,
    graphql.OnMutationUpdate<Mutation$ToggleExcludeCompleted>? update,
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
                        : _parserFn$Mutation$ToggleExcludeCompleted(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationToggleExcludeCompleted,
          parserFn: _parserFn$Mutation$ToggleExcludeCompleted,
        );

  final OnMutationCompleted$Mutation$ToggleExcludeCompleted?
      onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$ToggleExcludeCompleted
    extends graphql.WatchQueryOptions<Mutation$ToggleExcludeCompleted> {
  WatchOptions$Mutation$ToggleExcludeCompleted({
    String? operationName,
    Variables$Mutation$ToggleExcludeCompleted? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$ToggleExcludeCompleted? typedOptimisticResult,
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
          document: documentNodeMutationToggleExcludeCompleted,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$ToggleExcludeCompleted,
        );
}

extension ClientExtension$Mutation$ToggleExcludeCompleted
    on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$ToggleExcludeCompleted>>
      mutate$ToggleExcludeCompleted(
              [Options$Mutation$ToggleExcludeCompleted? options]) async =>
          await this
              .mutate(options ?? Options$Mutation$ToggleExcludeCompleted());

  graphql.ObservableQuery<Mutation$ToggleExcludeCompleted>
      watchMutation$ToggleExcludeCompleted(
              [WatchOptions$Mutation$ToggleExcludeCompleted? options]) =>
          this.watchMutation(
              options ?? WatchOptions$Mutation$ToggleExcludeCompleted());
}

class Mutation$ToggleExcludeCompleted$HookResult {
  Mutation$ToggleExcludeCompleted$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$ToggleExcludeCompleted runMutation;

  final graphql.QueryResult<Mutation$ToggleExcludeCompleted> result;
}

Mutation$ToggleExcludeCompleted$HookResult useMutation$ToggleExcludeCompleted(
    [WidgetOptions$Mutation$ToggleExcludeCompleted? options]) {
  final result = graphql_flutter
      .useMutation(options ?? WidgetOptions$Mutation$ToggleExcludeCompleted());
  return Mutation$ToggleExcludeCompleted$HookResult(
    ({variables, optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables?.toJson() ?? const {},
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$ToggleExcludeCompleted>
    useWatchMutation$ToggleExcludeCompleted(
            [WatchOptions$Mutation$ToggleExcludeCompleted? options]) =>
        graphql_flutter.useWatchMutation(
            options ?? WatchOptions$Mutation$ToggleExcludeCompleted());

class WidgetOptions$Mutation$ToggleExcludeCompleted
    extends graphql.MutationOptions<Mutation$ToggleExcludeCompleted> {
  WidgetOptions$Mutation$ToggleExcludeCompleted({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$ToggleExcludeCompleted? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$ToggleExcludeCompleted? onCompleted,
    graphql.OnMutationUpdate<Mutation$ToggleExcludeCompleted>? update,
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
                        : _parserFn$Mutation$ToggleExcludeCompleted(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationToggleExcludeCompleted,
          parserFn: _parserFn$Mutation$ToggleExcludeCompleted,
        );

  final OnMutationCompleted$Mutation$ToggleExcludeCompleted?
      onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$ToggleExcludeCompleted
    = graphql.MultiSourceResult<Mutation$ToggleExcludeCompleted> Function({
  Variables$Mutation$ToggleExcludeCompleted? variables,
  Object? optimisticResult,
  Mutation$ToggleExcludeCompleted? typedOptimisticResult,
});
typedef Builder$Mutation$ToggleExcludeCompleted = widgets.Widget Function(
  RunMutation$Mutation$ToggleExcludeCompleted,
  graphql.QueryResult<Mutation$ToggleExcludeCompleted>?,
);

class Mutation$ToggleExcludeCompleted$Widget
    extends graphql_flutter.Mutation<Mutation$ToggleExcludeCompleted> {
  Mutation$ToggleExcludeCompleted$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$ToggleExcludeCompleted? options,
    required Builder$Mutation$ToggleExcludeCompleted builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$ToggleExcludeCompleted(),
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

class Mutation$ToggleExcludeCompleted$setSettings {
  Mutation$ToggleExcludeCompleted$setSettings({
    required this.settings,
    this.$__typename = 'SetSettingsPayload',
  });

  factory Mutation$ToggleExcludeCompleted$setSettings.fromJson(
      Map<String, dynamic> json) {
    final l$settings = json['settings'];
    final l$$__typename = json['__typename'];
    return Mutation$ToggleExcludeCompleted$setSettings(
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
    if (other is! Mutation$ToggleExcludeCompleted$setSettings ||
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

extension UtilityExtension$Mutation$ToggleExcludeCompleted$setSettings
    on Mutation$ToggleExcludeCompleted$setSettings {
  CopyWith$Mutation$ToggleExcludeCompleted$setSettings<
          Mutation$ToggleExcludeCompleted$setSettings>
      get copyWith => CopyWith$Mutation$ToggleExcludeCompleted$setSettings(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$ToggleExcludeCompleted$setSettings<TRes> {
  factory CopyWith$Mutation$ToggleExcludeCompleted$setSettings(
    Mutation$ToggleExcludeCompleted$setSettings instance,
    TRes Function(Mutation$ToggleExcludeCompleted$setSettings) then,
  ) = _CopyWithImpl$Mutation$ToggleExcludeCompleted$setSettings;

  factory CopyWith$Mutation$ToggleExcludeCompleted$setSettings.stub(TRes res) =
      _CopyWithStubImpl$Mutation$ToggleExcludeCompleted$setSettings;

  TRes call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  });
  CopyWith$Fragment$SettingsDto<TRes> get settings;
}

class _CopyWithImpl$Mutation$ToggleExcludeCompleted$setSettings<TRes>
    implements CopyWith$Mutation$ToggleExcludeCompleted$setSettings<TRes> {
  _CopyWithImpl$Mutation$ToggleExcludeCompleted$setSettings(
    this._instance,
    this._then,
  );

  final Mutation$ToggleExcludeCompleted$setSettings _instance;

  final TRes Function(Mutation$ToggleExcludeCompleted$setSettings) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? settings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$ToggleExcludeCompleted$setSettings(
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

class _CopyWithStubImpl$Mutation$ToggleExcludeCompleted$setSettings<TRes>
    implements CopyWith$Mutation$ToggleExcludeCompleted$setSettings<TRes> {
  _CopyWithStubImpl$Mutation$ToggleExcludeCompleted$setSettings(this._res);

  TRes _res;

  call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$SettingsDto<TRes> get settings =>
      CopyWith$Fragment$SettingsDto.stub(_res);
}
