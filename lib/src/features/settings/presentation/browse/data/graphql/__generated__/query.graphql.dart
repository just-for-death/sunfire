import '../../../../../domain/settings/graphql/__generated__/fragment.graphql.dart';
import 'dart:async';
import 'package:flutter/widgets.dart' as widgets;
import 'package:gql/ast.dart';
import 'package:graphql/client.dart' as graphql;
import 'package:graphql_flutter/graphql_flutter.dart' as graphql_flutter;

class Variables$Mutation$UpdateSourceInParallel {
  factory Variables$Mutation$UpdateSourceInParallel(
          {int? maxSourcesInParallel}) =>
      Variables$Mutation$UpdateSourceInParallel._({
        if (maxSourcesInParallel != null)
          r'maxSourcesInParallel': maxSourcesInParallel,
      });

  Variables$Mutation$UpdateSourceInParallel._(this._$data);

  factory Variables$Mutation$UpdateSourceInParallel.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('maxSourcesInParallel')) {
      final l$maxSourcesInParallel = data['maxSourcesInParallel'];
      result$data['maxSourcesInParallel'] = (l$maxSourcesInParallel as int?);
    }
    return Variables$Mutation$UpdateSourceInParallel._(result$data);
  }

  Map<String, dynamic> _$data;

  int? get maxSourcesInParallel => (_$data['maxSourcesInParallel'] as int?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('maxSourcesInParallel')) {
      final l$maxSourcesInParallel = maxSourcesInParallel;
      result$data['maxSourcesInParallel'] = l$maxSourcesInParallel;
    }
    return result$data;
  }

  CopyWith$Variables$Mutation$UpdateSourceInParallel<
          Variables$Mutation$UpdateSourceInParallel>
      get copyWith => CopyWith$Variables$Mutation$UpdateSourceInParallel(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$UpdateSourceInParallel ||
        runtimeType != other.runtimeType) {
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
    return true;
  }

  @override
  int get hashCode {
    final l$maxSourcesInParallel = maxSourcesInParallel;
    return Object.hashAll([
      _$data.containsKey('maxSourcesInParallel')
          ? l$maxSourcesInParallel
          : const {}
    ]);
  }
}

abstract class CopyWith$Variables$Mutation$UpdateSourceInParallel<TRes> {
  factory CopyWith$Variables$Mutation$UpdateSourceInParallel(
    Variables$Mutation$UpdateSourceInParallel instance,
    TRes Function(Variables$Mutation$UpdateSourceInParallel) then,
  ) = _CopyWithImpl$Variables$Mutation$UpdateSourceInParallel;

  factory CopyWith$Variables$Mutation$UpdateSourceInParallel.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$UpdateSourceInParallel;

  TRes call({int? maxSourcesInParallel});
}

class _CopyWithImpl$Variables$Mutation$UpdateSourceInParallel<TRes>
    implements CopyWith$Variables$Mutation$UpdateSourceInParallel<TRes> {
  _CopyWithImpl$Variables$Mutation$UpdateSourceInParallel(
    this._instance,
    this._then,
  );

  final Variables$Mutation$UpdateSourceInParallel _instance;

  final TRes Function(Variables$Mutation$UpdateSourceInParallel) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? maxSourcesInParallel = _undefined}) =>
      _then(Variables$Mutation$UpdateSourceInParallel._({
        ..._instance._$data,
        if (maxSourcesInParallel != _undefined)
          'maxSourcesInParallel': (maxSourcesInParallel as int?),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$UpdateSourceInParallel<TRes>
    implements CopyWith$Variables$Mutation$UpdateSourceInParallel<TRes> {
  _CopyWithStubImpl$Variables$Mutation$UpdateSourceInParallel(this._res);

  TRes _res;

  call({int? maxSourcesInParallel}) => _res;
}

class Mutation$UpdateSourceInParallel {
  Mutation$UpdateSourceInParallel({
    required this.setSettings,
    this.$__typename = 'Mutation',
  });

  factory Mutation$UpdateSourceInParallel.fromJson(Map<String, dynamic> json) {
    final l$setSettings = json['setSettings'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateSourceInParallel(
      setSettings: Mutation$UpdateSourceInParallel$setSettings.fromJson(
          (l$setSettings as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$UpdateSourceInParallel$setSettings setSettings;

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
    if (other is! Mutation$UpdateSourceInParallel ||
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

extension UtilityExtension$Mutation$UpdateSourceInParallel
    on Mutation$UpdateSourceInParallel {
  CopyWith$Mutation$UpdateSourceInParallel<Mutation$UpdateSourceInParallel>
      get copyWith => CopyWith$Mutation$UpdateSourceInParallel(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdateSourceInParallel<TRes> {
  factory CopyWith$Mutation$UpdateSourceInParallel(
    Mutation$UpdateSourceInParallel instance,
    TRes Function(Mutation$UpdateSourceInParallel) then,
  ) = _CopyWithImpl$Mutation$UpdateSourceInParallel;

  factory CopyWith$Mutation$UpdateSourceInParallel.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateSourceInParallel;

  TRes call({
    Mutation$UpdateSourceInParallel$setSettings? setSettings,
    String? $__typename,
  });
  CopyWith$Mutation$UpdateSourceInParallel$setSettings<TRes> get setSettings;
}

class _CopyWithImpl$Mutation$UpdateSourceInParallel<TRes>
    implements CopyWith$Mutation$UpdateSourceInParallel<TRes> {
  _CopyWithImpl$Mutation$UpdateSourceInParallel(
    this._instance,
    this._then,
  );

  final Mutation$UpdateSourceInParallel _instance;

  final TRes Function(Mutation$UpdateSourceInParallel) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? setSettings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateSourceInParallel(
        setSettings: setSettings == _undefined || setSettings == null
            ? _instance.setSettings
            : (setSettings as Mutation$UpdateSourceInParallel$setSettings),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$UpdateSourceInParallel$setSettings<TRes> get setSettings {
    final local$setSettings = _instance.setSettings;
    return CopyWith$Mutation$UpdateSourceInParallel$setSettings(
        local$setSettings, (e) => call(setSettings: e));
  }
}

class _CopyWithStubImpl$Mutation$UpdateSourceInParallel<TRes>
    implements CopyWith$Mutation$UpdateSourceInParallel<TRes> {
  _CopyWithStubImpl$Mutation$UpdateSourceInParallel(this._res);

  TRes _res;

  call({
    Mutation$UpdateSourceInParallel$setSettings? setSettings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$UpdateSourceInParallel$setSettings<TRes> get setSettings =>
      CopyWith$Mutation$UpdateSourceInParallel$setSettings.stub(_res);
}

const documentNodeMutationUpdateSourceInParallel = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'UpdateSourceInParallel'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'maxSourcesInParallel')),
        type: NamedTypeNode(
          name: NameNode(value: 'Int'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: IntValueNode(value: '6')),
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
                    name: NameNode(value: 'maxSourcesInParallel'),
                    value: VariableNode(
                        name: NameNode(value: 'maxSourcesInParallel')),
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
Mutation$UpdateSourceInParallel _parserFn$Mutation$UpdateSourceInParallel(
        Map<String, dynamic> data) =>
    Mutation$UpdateSourceInParallel.fromJson(data);
typedef OnMutationCompleted$Mutation$UpdateSourceInParallel = FutureOr<void>
    Function(
  Map<String, dynamic>?,
  Mutation$UpdateSourceInParallel?,
);

class Options$Mutation$UpdateSourceInParallel
    extends graphql.MutationOptions<Mutation$UpdateSourceInParallel> {
  Options$Mutation$UpdateSourceInParallel({
    String? operationName,
    Variables$Mutation$UpdateSourceInParallel? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateSourceInParallel? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateSourceInParallel? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateSourceInParallel>? update,
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
                        : _parserFn$Mutation$UpdateSourceInParallel(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateSourceInParallel,
          parserFn: _parserFn$Mutation$UpdateSourceInParallel,
        );

  final OnMutationCompleted$Mutation$UpdateSourceInParallel?
      onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$UpdateSourceInParallel
    extends graphql.WatchQueryOptions<Mutation$UpdateSourceInParallel> {
  WatchOptions$Mutation$UpdateSourceInParallel({
    String? operationName,
    Variables$Mutation$UpdateSourceInParallel? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateSourceInParallel? typedOptimisticResult,
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
          document: documentNodeMutationUpdateSourceInParallel,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$UpdateSourceInParallel,
        );
}

extension ClientExtension$Mutation$UpdateSourceInParallel
    on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$UpdateSourceInParallel>>
      mutate$UpdateSourceInParallel(
              [Options$Mutation$UpdateSourceInParallel? options]) async =>
          await this
              .mutate(options ?? Options$Mutation$UpdateSourceInParallel());

  graphql.ObservableQuery<Mutation$UpdateSourceInParallel>
      watchMutation$UpdateSourceInParallel(
              [WatchOptions$Mutation$UpdateSourceInParallel? options]) =>
          this.watchMutation(
              options ?? WatchOptions$Mutation$UpdateSourceInParallel());
}

class Mutation$UpdateSourceInParallel$HookResult {
  Mutation$UpdateSourceInParallel$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$UpdateSourceInParallel runMutation;

  final graphql.QueryResult<Mutation$UpdateSourceInParallel> result;
}

Mutation$UpdateSourceInParallel$HookResult useMutation$UpdateSourceInParallel(
    [WidgetOptions$Mutation$UpdateSourceInParallel? options]) {
  final result = graphql_flutter
      .useMutation(options ?? WidgetOptions$Mutation$UpdateSourceInParallel());
  return Mutation$UpdateSourceInParallel$HookResult(
    ({variables, optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables?.toJson() ?? const {},
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$UpdateSourceInParallel>
    useWatchMutation$UpdateSourceInParallel(
            [WatchOptions$Mutation$UpdateSourceInParallel? options]) =>
        graphql_flutter.useWatchMutation(
            options ?? WatchOptions$Mutation$UpdateSourceInParallel());

class WidgetOptions$Mutation$UpdateSourceInParallel
    extends graphql.MutationOptions<Mutation$UpdateSourceInParallel> {
  WidgetOptions$Mutation$UpdateSourceInParallel({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateSourceInParallel? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateSourceInParallel? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateSourceInParallel>? update,
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
                        : _parserFn$Mutation$UpdateSourceInParallel(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateSourceInParallel,
          parserFn: _parserFn$Mutation$UpdateSourceInParallel,
        );

  final OnMutationCompleted$Mutation$UpdateSourceInParallel?
      onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$UpdateSourceInParallel
    = graphql.MultiSourceResult<Mutation$UpdateSourceInParallel> Function({
  Variables$Mutation$UpdateSourceInParallel? variables,
  Object? optimisticResult,
  Mutation$UpdateSourceInParallel? typedOptimisticResult,
});
typedef Builder$Mutation$UpdateSourceInParallel = widgets.Widget Function(
  RunMutation$Mutation$UpdateSourceInParallel,
  graphql.QueryResult<Mutation$UpdateSourceInParallel>?,
);

class Mutation$UpdateSourceInParallel$Widget
    extends graphql_flutter.Mutation<Mutation$UpdateSourceInParallel> {
  Mutation$UpdateSourceInParallel$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$UpdateSourceInParallel? options,
    required Builder$Mutation$UpdateSourceInParallel builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$UpdateSourceInParallel(),
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

class Mutation$UpdateSourceInParallel$setSettings {
  Mutation$UpdateSourceInParallel$setSettings({
    required this.settings,
    this.$__typename = 'SetSettingsPayload',
  });

  factory Mutation$UpdateSourceInParallel$setSettings.fromJson(
      Map<String, dynamic> json) {
    final l$settings = json['settings'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateSourceInParallel$setSettings(
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
    if (other is! Mutation$UpdateSourceInParallel$setSettings ||
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

extension UtilityExtension$Mutation$UpdateSourceInParallel$setSettings
    on Mutation$UpdateSourceInParallel$setSettings {
  CopyWith$Mutation$UpdateSourceInParallel$setSettings<
          Mutation$UpdateSourceInParallel$setSettings>
      get copyWith => CopyWith$Mutation$UpdateSourceInParallel$setSettings(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdateSourceInParallel$setSettings<TRes> {
  factory CopyWith$Mutation$UpdateSourceInParallel$setSettings(
    Mutation$UpdateSourceInParallel$setSettings instance,
    TRes Function(Mutation$UpdateSourceInParallel$setSettings) then,
  ) = _CopyWithImpl$Mutation$UpdateSourceInParallel$setSettings;

  factory CopyWith$Mutation$UpdateSourceInParallel$setSettings.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateSourceInParallel$setSettings;

  TRes call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  });
  CopyWith$Fragment$SettingsDto<TRes> get settings;
}

class _CopyWithImpl$Mutation$UpdateSourceInParallel$setSettings<TRes>
    implements CopyWith$Mutation$UpdateSourceInParallel$setSettings<TRes> {
  _CopyWithImpl$Mutation$UpdateSourceInParallel$setSettings(
    this._instance,
    this._then,
  );

  final Mutation$UpdateSourceInParallel$setSettings _instance;

  final TRes Function(Mutation$UpdateSourceInParallel$setSettings) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? settings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateSourceInParallel$setSettings(
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

class _CopyWithStubImpl$Mutation$UpdateSourceInParallel$setSettings<TRes>
    implements CopyWith$Mutation$UpdateSourceInParallel$setSettings<TRes> {
  _CopyWithStubImpl$Mutation$UpdateSourceInParallel$setSettings(this._res);

  TRes _res;

  call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$SettingsDto<TRes> get settings =>
      CopyWith$Fragment$SettingsDto.stub(_res);
}

class Variables$Mutation$UpdateLocalSourcePath {
  factory Variables$Mutation$UpdateLocalSourcePath(
          {required String localSourcePath}) =>
      Variables$Mutation$UpdateLocalSourcePath._({
        r'localSourcePath': localSourcePath,
      });

  Variables$Mutation$UpdateLocalSourcePath._(this._$data);

  factory Variables$Mutation$UpdateLocalSourcePath.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$localSourcePath = data['localSourcePath'];
    result$data['localSourcePath'] = (l$localSourcePath as String);
    return Variables$Mutation$UpdateLocalSourcePath._(result$data);
  }

  Map<String, dynamic> _$data;

  String get localSourcePath => (_$data['localSourcePath'] as String);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$localSourcePath = localSourcePath;
    result$data['localSourcePath'] = l$localSourcePath;
    return result$data;
  }

  CopyWith$Variables$Mutation$UpdateLocalSourcePath<
          Variables$Mutation$UpdateLocalSourcePath>
      get copyWith => CopyWith$Variables$Mutation$UpdateLocalSourcePath(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$UpdateLocalSourcePath ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$localSourcePath = localSourcePath;
    final lOther$localSourcePath = other.localSourcePath;
    if (l$localSourcePath != lOther$localSourcePath) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$localSourcePath = localSourcePath;
    return Object.hashAll([l$localSourcePath]);
  }
}

abstract class CopyWith$Variables$Mutation$UpdateLocalSourcePath<TRes> {
  factory CopyWith$Variables$Mutation$UpdateLocalSourcePath(
    Variables$Mutation$UpdateLocalSourcePath instance,
    TRes Function(Variables$Mutation$UpdateLocalSourcePath) then,
  ) = _CopyWithImpl$Variables$Mutation$UpdateLocalSourcePath;

  factory CopyWith$Variables$Mutation$UpdateLocalSourcePath.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$UpdateLocalSourcePath;

  TRes call({String? localSourcePath});
}

class _CopyWithImpl$Variables$Mutation$UpdateLocalSourcePath<TRes>
    implements CopyWith$Variables$Mutation$UpdateLocalSourcePath<TRes> {
  _CopyWithImpl$Variables$Mutation$UpdateLocalSourcePath(
    this._instance,
    this._then,
  );

  final Variables$Mutation$UpdateLocalSourcePath _instance;

  final TRes Function(Variables$Mutation$UpdateLocalSourcePath) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? localSourcePath = _undefined}) =>
      _then(Variables$Mutation$UpdateLocalSourcePath._({
        ..._instance._$data,
        if (localSourcePath != _undefined && localSourcePath != null)
          'localSourcePath': (localSourcePath as String),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$UpdateLocalSourcePath<TRes>
    implements CopyWith$Variables$Mutation$UpdateLocalSourcePath<TRes> {
  _CopyWithStubImpl$Variables$Mutation$UpdateLocalSourcePath(this._res);

  TRes _res;

  call({String? localSourcePath}) => _res;
}

class Mutation$UpdateLocalSourcePath {
  Mutation$UpdateLocalSourcePath({
    required this.setSettings,
    this.$__typename = 'Mutation',
  });

  factory Mutation$UpdateLocalSourcePath.fromJson(Map<String, dynamic> json) {
    final l$setSettings = json['setSettings'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateLocalSourcePath(
      setSettings: Mutation$UpdateLocalSourcePath$setSettings.fromJson(
          (l$setSettings as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$UpdateLocalSourcePath$setSettings setSettings;

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
    if (other is! Mutation$UpdateLocalSourcePath ||
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

extension UtilityExtension$Mutation$UpdateLocalSourcePath
    on Mutation$UpdateLocalSourcePath {
  CopyWith$Mutation$UpdateLocalSourcePath<Mutation$UpdateLocalSourcePath>
      get copyWith => CopyWith$Mutation$UpdateLocalSourcePath(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdateLocalSourcePath<TRes> {
  factory CopyWith$Mutation$UpdateLocalSourcePath(
    Mutation$UpdateLocalSourcePath instance,
    TRes Function(Mutation$UpdateLocalSourcePath) then,
  ) = _CopyWithImpl$Mutation$UpdateLocalSourcePath;

  factory CopyWith$Mutation$UpdateLocalSourcePath.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateLocalSourcePath;

  TRes call({
    Mutation$UpdateLocalSourcePath$setSettings? setSettings,
    String? $__typename,
  });
  CopyWith$Mutation$UpdateLocalSourcePath$setSettings<TRes> get setSettings;
}

class _CopyWithImpl$Mutation$UpdateLocalSourcePath<TRes>
    implements CopyWith$Mutation$UpdateLocalSourcePath<TRes> {
  _CopyWithImpl$Mutation$UpdateLocalSourcePath(
    this._instance,
    this._then,
  );

  final Mutation$UpdateLocalSourcePath _instance;

  final TRes Function(Mutation$UpdateLocalSourcePath) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? setSettings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateLocalSourcePath(
        setSettings: setSettings == _undefined || setSettings == null
            ? _instance.setSettings
            : (setSettings as Mutation$UpdateLocalSourcePath$setSettings),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$UpdateLocalSourcePath$setSettings<TRes> get setSettings {
    final local$setSettings = _instance.setSettings;
    return CopyWith$Mutation$UpdateLocalSourcePath$setSettings(
        local$setSettings, (e) => call(setSettings: e));
  }
}

class _CopyWithStubImpl$Mutation$UpdateLocalSourcePath<TRes>
    implements CopyWith$Mutation$UpdateLocalSourcePath<TRes> {
  _CopyWithStubImpl$Mutation$UpdateLocalSourcePath(this._res);

  TRes _res;

  call({
    Mutation$UpdateLocalSourcePath$setSettings? setSettings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$UpdateLocalSourcePath$setSettings<TRes> get setSettings =>
      CopyWith$Mutation$UpdateLocalSourcePath$setSettings.stub(_res);
}

const documentNodeMutationUpdateLocalSourcePath = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'UpdateLocalSourcePath'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'localSourcePath')),
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
                    name: NameNode(value: 'localSourcePath'),
                    value:
                        VariableNode(name: NameNode(value: 'localSourcePath')),
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
Mutation$UpdateLocalSourcePath _parserFn$Mutation$UpdateLocalSourcePath(
        Map<String, dynamic> data) =>
    Mutation$UpdateLocalSourcePath.fromJson(data);
typedef OnMutationCompleted$Mutation$UpdateLocalSourcePath = FutureOr<void>
    Function(
  Map<String, dynamic>?,
  Mutation$UpdateLocalSourcePath?,
);

class Options$Mutation$UpdateLocalSourcePath
    extends graphql.MutationOptions<Mutation$UpdateLocalSourcePath> {
  Options$Mutation$UpdateLocalSourcePath({
    String? operationName,
    required Variables$Mutation$UpdateLocalSourcePath variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateLocalSourcePath? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateLocalSourcePath? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateLocalSourcePath>? update,
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
                        : _parserFn$Mutation$UpdateLocalSourcePath(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateLocalSourcePath,
          parserFn: _parserFn$Mutation$UpdateLocalSourcePath,
        );

  final OnMutationCompleted$Mutation$UpdateLocalSourcePath?
      onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$UpdateLocalSourcePath
    extends graphql.WatchQueryOptions<Mutation$UpdateLocalSourcePath> {
  WatchOptions$Mutation$UpdateLocalSourcePath({
    String? operationName,
    required Variables$Mutation$UpdateLocalSourcePath variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateLocalSourcePath? typedOptimisticResult,
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
          document: documentNodeMutationUpdateLocalSourcePath,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$UpdateLocalSourcePath,
        );
}

extension ClientExtension$Mutation$UpdateLocalSourcePath
    on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$UpdateLocalSourcePath>>
      mutate$UpdateLocalSourcePath(
              Options$Mutation$UpdateLocalSourcePath options) async =>
          await this.mutate(options);

  graphql.ObservableQuery<Mutation$UpdateLocalSourcePath>
      watchMutation$UpdateLocalSourcePath(
              WatchOptions$Mutation$UpdateLocalSourcePath options) =>
          this.watchMutation(options);
}

class Mutation$UpdateLocalSourcePath$HookResult {
  Mutation$UpdateLocalSourcePath$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$UpdateLocalSourcePath runMutation;

  final graphql.QueryResult<Mutation$UpdateLocalSourcePath> result;
}

Mutation$UpdateLocalSourcePath$HookResult useMutation$UpdateLocalSourcePath(
    [WidgetOptions$Mutation$UpdateLocalSourcePath? options]) {
  final result = graphql_flutter
      .useMutation(options ?? WidgetOptions$Mutation$UpdateLocalSourcePath());
  return Mutation$UpdateLocalSourcePath$HookResult(
    (variables, {optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables.toJson(),
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$UpdateLocalSourcePath>
    useWatchMutation$UpdateLocalSourcePath(
            WatchOptions$Mutation$UpdateLocalSourcePath options) =>
        graphql_flutter.useWatchMutation(options);

class WidgetOptions$Mutation$UpdateLocalSourcePath
    extends graphql.MutationOptions<Mutation$UpdateLocalSourcePath> {
  WidgetOptions$Mutation$UpdateLocalSourcePath({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateLocalSourcePath? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateLocalSourcePath? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateLocalSourcePath>? update,
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
                        : _parserFn$Mutation$UpdateLocalSourcePath(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateLocalSourcePath,
          parserFn: _parserFn$Mutation$UpdateLocalSourcePath,
        );

  final OnMutationCompleted$Mutation$UpdateLocalSourcePath?
      onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$UpdateLocalSourcePath
    = graphql.MultiSourceResult<Mutation$UpdateLocalSourcePath> Function(
  Variables$Mutation$UpdateLocalSourcePath, {
  Object? optimisticResult,
  Mutation$UpdateLocalSourcePath? typedOptimisticResult,
});
typedef Builder$Mutation$UpdateLocalSourcePath = widgets.Widget Function(
  RunMutation$Mutation$UpdateLocalSourcePath,
  graphql.QueryResult<Mutation$UpdateLocalSourcePath>?,
);

class Mutation$UpdateLocalSourcePath$Widget
    extends graphql_flutter.Mutation<Mutation$UpdateLocalSourcePath> {
  Mutation$UpdateLocalSourcePath$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$UpdateLocalSourcePath? options,
    required Builder$Mutation$UpdateLocalSourcePath builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$UpdateLocalSourcePath(),
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

class Mutation$UpdateLocalSourcePath$setSettings {
  Mutation$UpdateLocalSourcePath$setSettings({
    required this.settings,
    this.$__typename = 'SetSettingsPayload',
  });

  factory Mutation$UpdateLocalSourcePath$setSettings.fromJson(
      Map<String, dynamic> json) {
    final l$settings = json['settings'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateLocalSourcePath$setSettings(
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
    if (other is! Mutation$UpdateLocalSourcePath$setSettings ||
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

extension UtilityExtension$Mutation$UpdateLocalSourcePath$setSettings
    on Mutation$UpdateLocalSourcePath$setSettings {
  CopyWith$Mutation$UpdateLocalSourcePath$setSettings<
          Mutation$UpdateLocalSourcePath$setSettings>
      get copyWith => CopyWith$Mutation$UpdateLocalSourcePath$setSettings(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdateLocalSourcePath$setSettings<TRes> {
  factory CopyWith$Mutation$UpdateLocalSourcePath$setSettings(
    Mutation$UpdateLocalSourcePath$setSettings instance,
    TRes Function(Mutation$UpdateLocalSourcePath$setSettings) then,
  ) = _CopyWithImpl$Mutation$UpdateLocalSourcePath$setSettings;

  factory CopyWith$Mutation$UpdateLocalSourcePath$setSettings.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateLocalSourcePath$setSettings;

  TRes call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  });
  CopyWith$Fragment$SettingsDto<TRes> get settings;
}

class _CopyWithImpl$Mutation$UpdateLocalSourcePath$setSettings<TRes>
    implements CopyWith$Mutation$UpdateLocalSourcePath$setSettings<TRes> {
  _CopyWithImpl$Mutation$UpdateLocalSourcePath$setSettings(
    this._instance,
    this._then,
  );

  final Mutation$UpdateLocalSourcePath$setSettings _instance;

  final TRes Function(Mutation$UpdateLocalSourcePath$setSettings) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? settings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateLocalSourcePath$setSettings(
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

class _CopyWithStubImpl$Mutation$UpdateLocalSourcePath$setSettings<TRes>
    implements CopyWith$Mutation$UpdateLocalSourcePath$setSettings<TRes> {
  _CopyWithStubImpl$Mutation$UpdateLocalSourcePath$setSettings(this._res);

  TRes _res;

  call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$SettingsDto<TRes> get settings =>
      CopyWith$Fragment$SettingsDto.stub(_res);
}

class Variables$Mutation$UpdateExtensionRepos {
  factory Variables$Mutation$UpdateExtensionRepos(
          {required List<String> extensionRepos}) =>
      Variables$Mutation$UpdateExtensionRepos._({
        r'extensionRepos': extensionRepos,
      });

  Variables$Mutation$UpdateExtensionRepos._(this._$data);

  factory Variables$Mutation$UpdateExtensionRepos.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$extensionRepos = data['extensionRepos'];
    result$data['extensionRepos'] =
        (l$extensionRepos as List<dynamic>).map((e) => (e as String)).toList();
    return Variables$Mutation$UpdateExtensionRepos._(result$data);
  }

  Map<String, dynamic> _$data;

  List<String> get extensionRepos => (_$data['extensionRepos'] as List<String>);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$extensionRepos = extensionRepos;
    result$data['extensionRepos'] = l$extensionRepos.map((e) => e).toList();
    return result$data;
  }

  CopyWith$Variables$Mutation$UpdateExtensionRepos<
          Variables$Mutation$UpdateExtensionRepos>
      get copyWith => CopyWith$Variables$Mutation$UpdateExtensionRepos(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$UpdateExtensionRepos ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$extensionRepos = extensionRepos;
    final lOther$extensionRepos = other.extensionRepos;
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
    return true;
  }

  @override
  int get hashCode {
    final l$extensionRepos = extensionRepos;
    return Object.hashAll([Object.hashAll(l$extensionRepos.map((v) => v))]);
  }
}

abstract class CopyWith$Variables$Mutation$UpdateExtensionRepos<TRes> {
  factory CopyWith$Variables$Mutation$UpdateExtensionRepos(
    Variables$Mutation$UpdateExtensionRepos instance,
    TRes Function(Variables$Mutation$UpdateExtensionRepos) then,
  ) = _CopyWithImpl$Variables$Mutation$UpdateExtensionRepos;

  factory CopyWith$Variables$Mutation$UpdateExtensionRepos.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$UpdateExtensionRepos;

  TRes call({List<String>? extensionRepos});
}

class _CopyWithImpl$Variables$Mutation$UpdateExtensionRepos<TRes>
    implements CopyWith$Variables$Mutation$UpdateExtensionRepos<TRes> {
  _CopyWithImpl$Variables$Mutation$UpdateExtensionRepos(
    this._instance,
    this._then,
  );

  final Variables$Mutation$UpdateExtensionRepos _instance;

  final TRes Function(Variables$Mutation$UpdateExtensionRepos) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? extensionRepos = _undefined}) =>
      _then(Variables$Mutation$UpdateExtensionRepos._({
        ..._instance._$data,
        if (extensionRepos != _undefined && extensionRepos != null)
          'extensionRepos': (extensionRepos as List<String>),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$UpdateExtensionRepos<TRes>
    implements CopyWith$Variables$Mutation$UpdateExtensionRepos<TRes> {
  _CopyWithStubImpl$Variables$Mutation$UpdateExtensionRepos(this._res);

  TRes _res;

  call({List<String>? extensionRepos}) => _res;
}

class Mutation$UpdateExtensionRepos {
  Mutation$UpdateExtensionRepos({
    required this.setSettings,
    this.$__typename = 'Mutation',
  });

  factory Mutation$UpdateExtensionRepos.fromJson(Map<String, dynamic> json) {
    final l$setSettings = json['setSettings'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateExtensionRepos(
      setSettings: Mutation$UpdateExtensionRepos$setSettings.fromJson(
          (l$setSettings as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$UpdateExtensionRepos$setSettings setSettings;

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
    if (other is! Mutation$UpdateExtensionRepos ||
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

extension UtilityExtension$Mutation$UpdateExtensionRepos
    on Mutation$UpdateExtensionRepos {
  CopyWith$Mutation$UpdateExtensionRepos<Mutation$UpdateExtensionRepos>
      get copyWith => CopyWith$Mutation$UpdateExtensionRepos(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdateExtensionRepos<TRes> {
  factory CopyWith$Mutation$UpdateExtensionRepos(
    Mutation$UpdateExtensionRepos instance,
    TRes Function(Mutation$UpdateExtensionRepos) then,
  ) = _CopyWithImpl$Mutation$UpdateExtensionRepos;

  factory CopyWith$Mutation$UpdateExtensionRepos.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateExtensionRepos;

  TRes call({
    Mutation$UpdateExtensionRepos$setSettings? setSettings,
    String? $__typename,
  });
  CopyWith$Mutation$UpdateExtensionRepos$setSettings<TRes> get setSettings;
}

class _CopyWithImpl$Mutation$UpdateExtensionRepos<TRes>
    implements CopyWith$Mutation$UpdateExtensionRepos<TRes> {
  _CopyWithImpl$Mutation$UpdateExtensionRepos(
    this._instance,
    this._then,
  );

  final Mutation$UpdateExtensionRepos _instance;

  final TRes Function(Mutation$UpdateExtensionRepos) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? setSettings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateExtensionRepos(
        setSettings: setSettings == _undefined || setSettings == null
            ? _instance.setSettings
            : (setSettings as Mutation$UpdateExtensionRepos$setSettings),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$UpdateExtensionRepos$setSettings<TRes> get setSettings {
    final local$setSettings = _instance.setSettings;
    return CopyWith$Mutation$UpdateExtensionRepos$setSettings(
        local$setSettings, (e) => call(setSettings: e));
  }
}

class _CopyWithStubImpl$Mutation$UpdateExtensionRepos<TRes>
    implements CopyWith$Mutation$UpdateExtensionRepos<TRes> {
  _CopyWithStubImpl$Mutation$UpdateExtensionRepos(this._res);

  TRes _res;

  call({
    Mutation$UpdateExtensionRepos$setSettings? setSettings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$UpdateExtensionRepos$setSettings<TRes> get setSettings =>
      CopyWith$Mutation$UpdateExtensionRepos$setSettings.stub(_res);
}

const documentNodeMutationUpdateExtensionRepos = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'UpdateExtensionRepos'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'extensionRepos')),
        type: ListTypeNode(
          type: NamedTypeNode(
            name: NameNode(value: 'String'),
            isNonNull: true,
          ),
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
                    name: NameNode(value: 'extensionRepos'),
                    value:
                        VariableNode(name: NameNode(value: 'extensionRepos')),
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
Mutation$UpdateExtensionRepos _parserFn$Mutation$UpdateExtensionRepos(
        Map<String, dynamic> data) =>
    Mutation$UpdateExtensionRepos.fromJson(data);
typedef OnMutationCompleted$Mutation$UpdateExtensionRepos = FutureOr<void>
    Function(
  Map<String, dynamic>?,
  Mutation$UpdateExtensionRepos?,
);

class Options$Mutation$UpdateExtensionRepos
    extends graphql.MutationOptions<Mutation$UpdateExtensionRepos> {
  Options$Mutation$UpdateExtensionRepos({
    String? operationName,
    required Variables$Mutation$UpdateExtensionRepos variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateExtensionRepos? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateExtensionRepos? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateExtensionRepos>? update,
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
                        : _parserFn$Mutation$UpdateExtensionRepos(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateExtensionRepos,
          parserFn: _parserFn$Mutation$UpdateExtensionRepos,
        );

  final OnMutationCompleted$Mutation$UpdateExtensionRepos?
      onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$UpdateExtensionRepos
    extends graphql.WatchQueryOptions<Mutation$UpdateExtensionRepos> {
  WatchOptions$Mutation$UpdateExtensionRepos({
    String? operationName,
    required Variables$Mutation$UpdateExtensionRepos variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateExtensionRepos? typedOptimisticResult,
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
          document: documentNodeMutationUpdateExtensionRepos,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$UpdateExtensionRepos,
        );
}

extension ClientExtension$Mutation$UpdateExtensionRepos
    on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$UpdateExtensionRepos>>
      mutate$UpdateExtensionRepos(
              Options$Mutation$UpdateExtensionRepos options) async =>
          await this.mutate(options);

  graphql.ObservableQuery<Mutation$UpdateExtensionRepos>
      watchMutation$UpdateExtensionRepos(
              WatchOptions$Mutation$UpdateExtensionRepos options) =>
          this.watchMutation(options);
}

class Mutation$UpdateExtensionRepos$HookResult {
  Mutation$UpdateExtensionRepos$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$UpdateExtensionRepos runMutation;

  final graphql.QueryResult<Mutation$UpdateExtensionRepos> result;
}

Mutation$UpdateExtensionRepos$HookResult useMutation$UpdateExtensionRepos(
    [WidgetOptions$Mutation$UpdateExtensionRepos? options]) {
  final result = graphql_flutter
      .useMutation(options ?? WidgetOptions$Mutation$UpdateExtensionRepos());
  return Mutation$UpdateExtensionRepos$HookResult(
    (variables, {optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables.toJson(),
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$UpdateExtensionRepos>
    useWatchMutation$UpdateExtensionRepos(
            WatchOptions$Mutation$UpdateExtensionRepos options) =>
        graphql_flutter.useWatchMutation(options);

class WidgetOptions$Mutation$UpdateExtensionRepos
    extends graphql.MutationOptions<Mutation$UpdateExtensionRepos> {
  WidgetOptions$Mutation$UpdateExtensionRepos({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateExtensionRepos? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateExtensionRepos? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateExtensionRepos>? update,
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
                        : _parserFn$Mutation$UpdateExtensionRepos(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateExtensionRepos,
          parserFn: _parserFn$Mutation$UpdateExtensionRepos,
        );

  final OnMutationCompleted$Mutation$UpdateExtensionRepos?
      onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$UpdateExtensionRepos
    = graphql.MultiSourceResult<Mutation$UpdateExtensionRepos> Function(
  Variables$Mutation$UpdateExtensionRepos, {
  Object? optimisticResult,
  Mutation$UpdateExtensionRepos? typedOptimisticResult,
});
typedef Builder$Mutation$UpdateExtensionRepos = widgets.Widget Function(
  RunMutation$Mutation$UpdateExtensionRepos,
  graphql.QueryResult<Mutation$UpdateExtensionRepos>?,
);

class Mutation$UpdateExtensionRepos$Widget
    extends graphql_flutter.Mutation<Mutation$UpdateExtensionRepos> {
  Mutation$UpdateExtensionRepos$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$UpdateExtensionRepos? options,
    required Builder$Mutation$UpdateExtensionRepos builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$UpdateExtensionRepos(),
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

class Mutation$UpdateExtensionRepos$setSettings {
  Mutation$UpdateExtensionRepos$setSettings({
    required this.settings,
    this.$__typename = 'SetSettingsPayload',
  });

  factory Mutation$UpdateExtensionRepos$setSettings.fromJson(
      Map<String, dynamic> json) {
    final l$settings = json['settings'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateExtensionRepos$setSettings(
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
    if (other is! Mutation$UpdateExtensionRepos$setSettings ||
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

extension UtilityExtension$Mutation$UpdateExtensionRepos$setSettings
    on Mutation$UpdateExtensionRepos$setSettings {
  CopyWith$Mutation$UpdateExtensionRepos$setSettings<
          Mutation$UpdateExtensionRepos$setSettings>
      get copyWith => CopyWith$Mutation$UpdateExtensionRepos$setSettings(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdateExtensionRepos$setSettings<TRes> {
  factory CopyWith$Mutation$UpdateExtensionRepos$setSettings(
    Mutation$UpdateExtensionRepos$setSettings instance,
    TRes Function(Mutation$UpdateExtensionRepos$setSettings) then,
  ) = _CopyWithImpl$Mutation$UpdateExtensionRepos$setSettings;

  factory CopyWith$Mutation$UpdateExtensionRepos$setSettings.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateExtensionRepos$setSettings;

  TRes call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  });
  CopyWith$Fragment$SettingsDto<TRes> get settings;
}

class _CopyWithImpl$Mutation$UpdateExtensionRepos$setSettings<TRes>
    implements CopyWith$Mutation$UpdateExtensionRepos$setSettings<TRes> {
  _CopyWithImpl$Mutation$UpdateExtensionRepos$setSettings(
    this._instance,
    this._then,
  );

  final Mutation$UpdateExtensionRepos$setSettings _instance;

  final TRes Function(Mutation$UpdateExtensionRepos$setSettings) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? settings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateExtensionRepos$setSettings(
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

class _CopyWithStubImpl$Mutation$UpdateExtensionRepos$setSettings<TRes>
    implements CopyWith$Mutation$UpdateExtensionRepos$setSettings<TRes> {
  _CopyWithStubImpl$Mutation$UpdateExtensionRepos$setSettings(this._res);

  TRes _res;

  call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$SettingsDto<TRes> get settings =>
      CopyWith$Fragment$SettingsDto.stub(_res);
}
