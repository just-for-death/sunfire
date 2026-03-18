import '../../../../../domain/settings/graphql/__generated__/fragment.graphql.dart';
import 'dart:async';
import 'package:flutter/widgets.dart' as widgets;
import 'package:gql/ast.dart';
import 'package:graphql/client.dart' as graphql;
import 'package:graphql_flutter/graphql_flutter.dart' as graphql_flutter;

class Variables$Mutation$UpdateSocksVersion {
  factory Variables$Mutation$UpdateSocksVersion({int? socksProxyVersion}) =>
      Variables$Mutation$UpdateSocksVersion._({
        if (socksProxyVersion != null) r'socksProxyVersion': socksProxyVersion,
      });

  Variables$Mutation$UpdateSocksVersion._(this._$data);

  factory Variables$Mutation$UpdateSocksVersion.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('socksProxyVersion')) {
      final l$socksProxyVersion = data['socksProxyVersion'];
      result$data['socksProxyVersion'] = (l$socksProxyVersion as int?);
    }
    return Variables$Mutation$UpdateSocksVersion._(result$data);
  }

  Map<String, dynamic> _$data;

  int? get socksProxyVersion => (_$data['socksProxyVersion'] as int?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('socksProxyVersion')) {
      final l$socksProxyVersion = socksProxyVersion;
      result$data['socksProxyVersion'] = l$socksProxyVersion;
    }
    return result$data;
  }

  CopyWith$Variables$Mutation$UpdateSocksVersion<
          Variables$Mutation$UpdateSocksVersion>
      get copyWith => CopyWith$Variables$Mutation$UpdateSocksVersion(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$UpdateSocksVersion ||
        runtimeType != other.runtimeType) {
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
    return true;
  }

  @override
  int get hashCode {
    final l$socksProxyVersion = socksProxyVersion;
    return Object.hashAll([
      _$data.containsKey('socksProxyVersion') ? l$socksProxyVersion : const {}
    ]);
  }
}

abstract class CopyWith$Variables$Mutation$UpdateSocksVersion<TRes> {
  factory CopyWith$Variables$Mutation$UpdateSocksVersion(
    Variables$Mutation$UpdateSocksVersion instance,
    TRes Function(Variables$Mutation$UpdateSocksVersion) then,
  ) = _CopyWithImpl$Variables$Mutation$UpdateSocksVersion;

  factory CopyWith$Variables$Mutation$UpdateSocksVersion.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$UpdateSocksVersion;

  TRes call({int? socksProxyVersion});
}

class _CopyWithImpl$Variables$Mutation$UpdateSocksVersion<TRes>
    implements CopyWith$Variables$Mutation$UpdateSocksVersion<TRes> {
  _CopyWithImpl$Variables$Mutation$UpdateSocksVersion(
    this._instance,
    this._then,
  );

  final Variables$Mutation$UpdateSocksVersion _instance;

  final TRes Function(Variables$Mutation$UpdateSocksVersion) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? socksProxyVersion = _undefined}) =>
      _then(Variables$Mutation$UpdateSocksVersion._({
        ..._instance._$data,
        if (socksProxyVersion != _undefined)
          'socksProxyVersion': (socksProxyVersion as int?),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$UpdateSocksVersion<TRes>
    implements CopyWith$Variables$Mutation$UpdateSocksVersion<TRes> {
  _CopyWithStubImpl$Variables$Mutation$UpdateSocksVersion(this._res);

  TRes _res;

  call({int? socksProxyVersion}) => _res;
}

class Mutation$UpdateSocksVersion {
  Mutation$UpdateSocksVersion({
    required this.setSettings,
    this.$__typename = 'Mutation',
  });

  factory Mutation$UpdateSocksVersion.fromJson(Map<String, dynamic> json) {
    final l$setSettings = json['setSettings'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateSocksVersion(
      setSettings: Mutation$UpdateSocksVersion$setSettings.fromJson(
          (l$setSettings as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$UpdateSocksVersion$setSettings setSettings;

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
    if (other is! Mutation$UpdateSocksVersion ||
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

extension UtilityExtension$Mutation$UpdateSocksVersion
    on Mutation$UpdateSocksVersion {
  CopyWith$Mutation$UpdateSocksVersion<Mutation$UpdateSocksVersion>
      get copyWith => CopyWith$Mutation$UpdateSocksVersion(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdateSocksVersion<TRes> {
  factory CopyWith$Mutation$UpdateSocksVersion(
    Mutation$UpdateSocksVersion instance,
    TRes Function(Mutation$UpdateSocksVersion) then,
  ) = _CopyWithImpl$Mutation$UpdateSocksVersion;

  factory CopyWith$Mutation$UpdateSocksVersion.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateSocksVersion;

  TRes call({
    Mutation$UpdateSocksVersion$setSettings? setSettings,
    String? $__typename,
  });
  CopyWith$Mutation$UpdateSocksVersion$setSettings<TRes> get setSettings;
}

class _CopyWithImpl$Mutation$UpdateSocksVersion<TRes>
    implements CopyWith$Mutation$UpdateSocksVersion<TRes> {
  _CopyWithImpl$Mutation$UpdateSocksVersion(
    this._instance,
    this._then,
  );

  final Mutation$UpdateSocksVersion _instance;

  final TRes Function(Mutation$UpdateSocksVersion) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? setSettings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateSocksVersion(
        setSettings: setSettings == _undefined || setSettings == null
            ? _instance.setSettings
            : (setSettings as Mutation$UpdateSocksVersion$setSettings),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$UpdateSocksVersion$setSettings<TRes> get setSettings {
    final local$setSettings = _instance.setSettings;
    return CopyWith$Mutation$UpdateSocksVersion$setSettings(
        local$setSettings, (e) => call(setSettings: e));
  }
}

class _CopyWithStubImpl$Mutation$UpdateSocksVersion<TRes>
    implements CopyWith$Mutation$UpdateSocksVersion<TRes> {
  _CopyWithStubImpl$Mutation$UpdateSocksVersion(this._res);

  TRes _res;

  call({
    Mutation$UpdateSocksVersion$setSettings? setSettings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$UpdateSocksVersion$setSettings<TRes> get setSettings =>
      CopyWith$Mutation$UpdateSocksVersion$setSettings.stub(_res);
}

const documentNodeMutationUpdateSocksVersion = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'UpdateSocksVersion'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'socksProxyVersion')),
        type: NamedTypeNode(
          name: NameNode(value: 'Int'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: IntValueNode(value: '10')),
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
                    name: NameNode(value: 'socksProxyVersion'),
                    value: VariableNode(
                        name: NameNode(value: 'socksProxyVersion')),
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
Mutation$UpdateSocksVersion _parserFn$Mutation$UpdateSocksVersion(
        Map<String, dynamic> data) =>
    Mutation$UpdateSocksVersion.fromJson(data);
typedef OnMutationCompleted$Mutation$UpdateSocksVersion = FutureOr<void>
    Function(
  Map<String, dynamic>?,
  Mutation$UpdateSocksVersion?,
);

class Options$Mutation$UpdateSocksVersion
    extends graphql.MutationOptions<Mutation$UpdateSocksVersion> {
  Options$Mutation$UpdateSocksVersion({
    String? operationName,
    Variables$Mutation$UpdateSocksVersion? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateSocksVersion? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateSocksVersion? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateSocksVersion>? update,
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
                        : _parserFn$Mutation$UpdateSocksVersion(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateSocksVersion,
          parserFn: _parserFn$Mutation$UpdateSocksVersion,
        );

  final OnMutationCompleted$Mutation$UpdateSocksVersion? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$UpdateSocksVersion
    extends graphql.WatchQueryOptions<Mutation$UpdateSocksVersion> {
  WatchOptions$Mutation$UpdateSocksVersion({
    String? operationName,
    Variables$Mutation$UpdateSocksVersion? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateSocksVersion? typedOptimisticResult,
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
          document: documentNodeMutationUpdateSocksVersion,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$UpdateSocksVersion,
        );
}

extension ClientExtension$Mutation$UpdateSocksVersion on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$UpdateSocksVersion>>
      mutate$UpdateSocksVersion(
              [Options$Mutation$UpdateSocksVersion? options]) async =>
          await this.mutate(options ?? Options$Mutation$UpdateSocksVersion());

  graphql.ObservableQuery<
      Mutation$UpdateSocksVersion> watchMutation$UpdateSocksVersion(
          [WatchOptions$Mutation$UpdateSocksVersion? options]) =>
      this.watchMutation(options ?? WatchOptions$Mutation$UpdateSocksVersion());
}

class Mutation$UpdateSocksVersion$HookResult {
  Mutation$UpdateSocksVersion$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$UpdateSocksVersion runMutation;

  final graphql.QueryResult<Mutation$UpdateSocksVersion> result;
}

Mutation$UpdateSocksVersion$HookResult useMutation$UpdateSocksVersion(
    [WidgetOptions$Mutation$UpdateSocksVersion? options]) {
  final result = graphql_flutter
      .useMutation(options ?? WidgetOptions$Mutation$UpdateSocksVersion());
  return Mutation$UpdateSocksVersion$HookResult(
    ({variables, optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables?.toJson() ?? const {},
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$UpdateSocksVersion>
    useWatchMutation$UpdateSocksVersion(
            [WatchOptions$Mutation$UpdateSocksVersion? options]) =>
        graphql_flutter.useWatchMutation(
            options ?? WatchOptions$Mutation$UpdateSocksVersion());

class WidgetOptions$Mutation$UpdateSocksVersion
    extends graphql.MutationOptions<Mutation$UpdateSocksVersion> {
  WidgetOptions$Mutation$UpdateSocksVersion({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateSocksVersion? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateSocksVersion? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateSocksVersion>? update,
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
                        : _parserFn$Mutation$UpdateSocksVersion(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateSocksVersion,
          parserFn: _parserFn$Mutation$UpdateSocksVersion,
        );

  final OnMutationCompleted$Mutation$UpdateSocksVersion? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$UpdateSocksVersion
    = graphql.MultiSourceResult<Mutation$UpdateSocksVersion> Function({
  Variables$Mutation$UpdateSocksVersion? variables,
  Object? optimisticResult,
  Mutation$UpdateSocksVersion? typedOptimisticResult,
});
typedef Builder$Mutation$UpdateSocksVersion = widgets.Widget Function(
  RunMutation$Mutation$UpdateSocksVersion,
  graphql.QueryResult<Mutation$UpdateSocksVersion>?,
);

class Mutation$UpdateSocksVersion$Widget
    extends graphql_flutter.Mutation<Mutation$UpdateSocksVersion> {
  Mutation$UpdateSocksVersion$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$UpdateSocksVersion? options,
    required Builder$Mutation$UpdateSocksVersion builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$UpdateSocksVersion(),
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

class Mutation$UpdateSocksVersion$setSettings {
  Mutation$UpdateSocksVersion$setSettings({
    required this.settings,
    this.$__typename = 'SetSettingsPayload',
  });

  factory Mutation$UpdateSocksVersion$setSettings.fromJson(
      Map<String, dynamic> json) {
    final l$settings = json['settings'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateSocksVersion$setSettings(
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
    if (other is! Mutation$UpdateSocksVersion$setSettings ||
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

extension UtilityExtension$Mutation$UpdateSocksVersion$setSettings
    on Mutation$UpdateSocksVersion$setSettings {
  CopyWith$Mutation$UpdateSocksVersion$setSettings<
          Mutation$UpdateSocksVersion$setSettings>
      get copyWith => CopyWith$Mutation$UpdateSocksVersion$setSettings(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdateSocksVersion$setSettings<TRes> {
  factory CopyWith$Mutation$UpdateSocksVersion$setSettings(
    Mutation$UpdateSocksVersion$setSettings instance,
    TRes Function(Mutation$UpdateSocksVersion$setSettings) then,
  ) = _CopyWithImpl$Mutation$UpdateSocksVersion$setSettings;

  factory CopyWith$Mutation$UpdateSocksVersion$setSettings.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateSocksVersion$setSettings;

  TRes call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  });
  CopyWith$Fragment$SettingsDto<TRes> get settings;
}

class _CopyWithImpl$Mutation$UpdateSocksVersion$setSettings<TRes>
    implements CopyWith$Mutation$UpdateSocksVersion$setSettings<TRes> {
  _CopyWithImpl$Mutation$UpdateSocksVersion$setSettings(
    this._instance,
    this._then,
  );

  final Mutation$UpdateSocksVersion$setSettings _instance;

  final TRes Function(Mutation$UpdateSocksVersion$setSettings) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? settings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateSocksVersion$setSettings(
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

class _CopyWithStubImpl$Mutation$UpdateSocksVersion$setSettings<TRes>
    implements CopyWith$Mutation$UpdateSocksVersion$setSettings<TRes> {
  _CopyWithStubImpl$Mutation$UpdateSocksVersion$setSettings(this._res);

  TRes _res;

  call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$SettingsDto<TRes> get settings =>
      CopyWith$Fragment$SettingsDto.stub(_res);
}

class Variables$Mutation$UpdateSocksUserName {
  factory Variables$Mutation$UpdateSocksUserName(
          {required String socksProxyUsername}) =>
      Variables$Mutation$UpdateSocksUserName._({
        r'socksProxyUsername': socksProxyUsername,
      });

  Variables$Mutation$UpdateSocksUserName._(this._$data);

  factory Variables$Mutation$UpdateSocksUserName.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$socksProxyUsername = data['socksProxyUsername'];
    result$data['socksProxyUsername'] = (l$socksProxyUsername as String);
    return Variables$Mutation$UpdateSocksUserName._(result$data);
  }

  Map<String, dynamic> _$data;

  String get socksProxyUsername => (_$data['socksProxyUsername'] as String);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$socksProxyUsername = socksProxyUsername;
    result$data['socksProxyUsername'] = l$socksProxyUsername;
    return result$data;
  }

  CopyWith$Variables$Mutation$UpdateSocksUserName<
          Variables$Mutation$UpdateSocksUserName>
      get copyWith => CopyWith$Variables$Mutation$UpdateSocksUserName(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$UpdateSocksUserName ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$socksProxyUsername = socksProxyUsername;
    final lOther$socksProxyUsername = other.socksProxyUsername;
    if (l$socksProxyUsername != lOther$socksProxyUsername) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$socksProxyUsername = socksProxyUsername;
    return Object.hashAll([l$socksProxyUsername]);
  }
}

abstract class CopyWith$Variables$Mutation$UpdateSocksUserName<TRes> {
  factory CopyWith$Variables$Mutation$UpdateSocksUserName(
    Variables$Mutation$UpdateSocksUserName instance,
    TRes Function(Variables$Mutation$UpdateSocksUserName) then,
  ) = _CopyWithImpl$Variables$Mutation$UpdateSocksUserName;

  factory CopyWith$Variables$Mutation$UpdateSocksUserName.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$UpdateSocksUserName;

  TRes call({String? socksProxyUsername});
}

class _CopyWithImpl$Variables$Mutation$UpdateSocksUserName<TRes>
    implements CopyWith$Variables$Mutation$UpdateSocksUserName<TRes> {
  _CopyWithImpl$Variables$Mutation$UpdateSocksUserName(
    this._instance,
    this._then,
  );

  final Variables$Mutation$UpdateSocksUserName _instance;

  final TRes Function(Variables$Mutation$UpdateSocksUserName) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? socksProxyUsername = _undefined}) =>
      _then(Variables$Mutation$UpdateSocksUserName._({
        ..._instance._$data,
        if (socksProxyUsername != _undefined && socksProxyUsername != null)
          'socksProxyUsername': (socksProxyUsername as String),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$UpdateSocksUserName<TRes>
    implements CopyWith$Variables$Mutation$UpdateSocksUserName<TRes> {
  _CopyWithStubImpl$Variables$Mutation$UpdateSocksUserName(this._res);

  TRes _res;

  call({String? socksProxyUsername}) => _res;
}

class Mutation$UpdateSocksUserName {
  Mutation$UpdateSocksUserName({
    required this.setSettings,
    this.$__typename = 'Mutation',
  });

  factory Mutation$UpdateSocksUserName.fromJson(Map<String, dynamic> json) {
    final l$setSettings = json['setSettings'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateSocksUserName(
      setSettings: Mutation$UpdateSocksUserName$setSettings.fromJson(
          (l$setSettings as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$UpdateSocksUserName$setSettings setSettings;

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
    if (other is! Mutation$UpdateSocksUserName ||
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

extension UtilityExtension$Mutation$UpdateSocksUserName
    on Mutation$UpdateSocksUserName {
  CopyWith$Mutation$UpdateSocksUserName<Mutation$UpdateSocksUserName>
      get copyWith => CopyWith$Mutation$UpdateSocksUserName(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdateSocksUserName<TRes> {
  factory CopyWith$Mutation$UpdateSocksUserName(
    Mutation$UpdateSocksUserName instance,
    TRes Function(Mutation$UpdateSocksUserName) then,
  ) = _CopyWithImpl$Mutation$UpdateSocksUserName;

  factory CopyWith$Mutation$UpdateSocksUserName.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateSocksUserName;

  TRes call({
    Mutation$UpdateSocksUserName$setSettings? setSettings,
    String? $__typename,
  });
  CopyWith$Mutation$UpdateSocksUserName$setSettings<TRes> get setSettings;
}

class _CopyWithImpl$Mutation$UpdateSocksUserName<TRes>
    implements CopyWith$Mutation$UpdateSocksUserName<TRes> {
  _CopyWithImpl$Mutation$UpdateSocksUserName(
    this._instance,
    this._then,
  );

  final Mutation$UpdateSocksUserName _instance;

  final TRes Function(Mutation$UpdateSocksUserName) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? setSettings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateSocksUserName(
        setSettings: setSettings == _undefined || setSettings == null
            ? _instance.setSettings
            : (setSettings as Mutation$UpdateSocksUserName$setSettings),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$UpdateSocksUserName$setSettings<TRes> get setSettings {
    final local$setSettings = _instance.setSettings;
    return CopyWith$Mutation$UpdateSocksUserName$setSettings(
        local$setSettings, (e) => call(setSettings: e));
  }
}

class _CopyWithStubImpl$Mutation$UpdateSocksUserName<TRes>
    implements CopyWith$Mutation$UpdateSocksUserName<TRes> {
  _CopyWithStubImpl$Mutation$UpdateSocksUserName(this._res);

  TRes _res;

  call({
    Mutation$UpdateSocksUserName$setSettings? setSettings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$UpdateSocksUserName$setSettings<TRes> get setSettings =>
      CopyWith$Mutation$UpdateSocksUserName$setSettings.stub(_res);
}

const documentNodeMutationUpdateSocksUserName = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'UpdateSocksUserName'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'socksProxyUsername')),
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
                    name: NameNode(value: 'socksProxyUsername'),
                    value: VariableNode(
                        name: NameNode(value: 'socksProxyUsername')),
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
Mutation$UpdateSocksUserName _parserFn$Mutation$UpdateSocksUserName(
        Map<String, dynamic> data) =>
    Mutation$UpdateSocksUserName.fromJson(data);
typedef OnMutationCompleted$Mutation$UpdateSocksUserName = FutureOr<void>
    Function(
  Map<String, dynamic>?,
  Mutation$UpdateSocksUserName?,
);

class Options$Mutation$UpdateSocksUserName
    extends graphql.MutationOptions<Mutation$UpdateSocksUserName> {
  Options$Mutation$UpdateSocksUserName({
    String? operationName,
    required Variables$Mutation$UpdateSocksUserName variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateSocksUserName? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateSocksUserName? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateSocksUserName>? update,
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
                        : _parserFn$Mutation$UpdateSocksUserName(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateSocksUserName,
          parserFn: _parserFn$Mutation$UpdateSocksUserName,
        );

  final OnMutationCompleted$Mutation$UpdateSocksUserName? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$UpdateSocksUserName
    extends graphql.WatchQueryOptions<Mutation$UpdateSocksUserName> {
  WatchOptions$Mutation$UpdateSocksUserName({
    String? operationName,
    required Variables$Mutation$UpdateSocksUserName variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateSocksUserName? typedOptimisticResult,
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
          document: documentNodeMutationUpdateSocksUserName,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$UpdateSocksUserName,
        );
}

extension ClientExtension$Mutation$UpdateSocksUserName
    on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$UpdateSocksUserName>>
      mutate$UpdateSocksUserName(
              Options$Mutation$UpdateSocksUserName options) async =>
          await this.mutate(options);

  graphql.ObservableQuery<Mutation$UpdateSocksUserName>
      watchMutation$UpdateSocksUserName(
              WatchOptions$Mutation$UpdateSocksUserName options) =>
          this.watchMutation(options);
}

class Mutation$UpdateSocksUserName$HookResult {
  Mutation$UpdateSocksUserName$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$UpdateSocksUserName runMutation;

  final graphql.QueryResult<Mutation$UpdateSocksUserName> result;
}

Mutation$UpdateSocksUserName$HookResult useMutation$UpdateSocksUserName(
    [WidgetOptions$Mutation$UpdateSocksUserName? options]) {
  final result = graphql_flutter
      .useMutation(options ?? WidgetOptions$Mutation$UpdateSocksUserName());
  return Mutation$UpdateSocksUserName$HookResult(
    (variables, {optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables.toJson(),
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$UpdateSocksUserName>
    useWatchMutation$UpdateSocksUserName(
            WatchOptions$Mutation$UpdateSocksUserName options) =>
        graphql_flutter.useWatchMutation(options);

class WidgetOptions$Mutation$UpdateSocksUserName
    extends graphql.MutationOptions<Mutation$UpdateSocksUserName> {
  WidgetOptions$Mutation$UpdateSocksUserName({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateSocksUserName? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateSocksUserName? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateSocksUserName>? update,
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
                        : _parserFn$Mutation$UpdateSocksUserName(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateSocksUserName,
          parserFn: _parserFn$Mutation$UpdateSocksUserName,
        );

  final OnMutationCompleted$Mutation$UpdateSocksUserName? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$UpdateSocksUserName
    = graphql.MultiSourceResult<Mutation$UpdateSocksUserName> Function(
  Variables$Mutation$UpdateSocksUserName, {
  Object? optimisticResult,
  Mutation$UpdateSocksUserName? typedOptimisticResult,
});
typedef Builder$Mutation$UpdateSocksUserName = widgets.Widget Function(
  RunMutation$Mutation$UpdateSocksUserName,
  graphql.QueryResult<Mutation$UpdateSocksUserName>?,
);

class Mutation$UpdateSocksUserName$Widget
    extends graphql_flutter.Mutation<Mutation$UpdateSocksUserName> {
  Mutation$UpdateSocksUserName$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$UpdateSocksUserName? options,
    required Builder$Mutation$UpdateSocksUserName builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$UpdateSocksUserName(),
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

class Mutation$UpdateSocksUserName$setSettings {
  Mutation$UpdateSocksUserName$setSettings({
    required this.settings,
    this.$__typename = 'SetSettingsPayload',
  });

  factory Mutation$UpdateSocksUserName$setSettings.fromJson(
      Map<String, dynamic> json) {
    final l$settings = json['settings'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateSocksUserName$setSettings(
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
    if (other is! Mutation$UpdateSocksUserName$setSettings ||
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

extension UtilityExtension$Mutation$UpdateSocksUserName$setSettings
    on Mutation$UpdateSocksUserName$setSettings {
  CopyWith$Mutation$UpdateSocksUserName$setSettings<
          Mutation$UpdateSocksUserName$setSettings>
      get copyWith => CopyWith$Mutation$UpdateSocksUserName$setSettings(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdateSocksUserName$setSettings<TRes> {
  factory CopyWith$Mutation$UpdateSocksUserName$setSettings(
    Mutation$UpdateSocksUserName$setSettings instance,
    TRes Function(Mutation$UpdateSocksUserName$setSettings) then,
  ) = _CopyWithImpl$Mutation$UpdateSocksUserName$setSettings;

  factory CopyWith$Mutation$UpdateSocksUserName$setSettings.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateSocksUserName$setSettings;

  TRes call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  });
  CopyWith$Fragment$SettingsDto<TRes> get settings;
}

class _CopyWithImpl$Mutation$UpdateSocksUserName$setSettings<TRes>
    implements CopyWith$Mutation$UpdateSocksUserName$setSettings<TRes> {
  _CopyWithImpl$Mutation$UpdateSocksUserName$setSettings(
    this._instance,
    this._then,
  );

  final Mutation$UpdateSocksUserName$setSettings _instance;

  final TRes Function(Mutation$UpdateSocksUserName$setSettings) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? settings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateSocksUserName$setSettings(
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

class _CopyWithStubImpl$Mutation$UpdateSocksUserName$setSettings<TRes>
    implements CopyWith$Mutation$UpdateSocksUserName$setSettings<TRes> {
  _CopyWithStubImpl$Mutation$UpdateSocksUserName$setSettings(this._res);

  TRes _res;

  call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$SettingsDto<TRes> get settings =>
      CopyWith$Fragment$SettingsDto.stub(_res);
}

class Variables$Mutation$UpdateSocksPort {
  factory Variables$Mutation$UpdateSocksPort(
          {required String socksProxyPort}) =>
      Variables$Mutation$UpdateSocksPort._({
        r'socksProxyPort': socksProxyPort,
      });

  Variables$Mutation$UpdateSocksPort._(this._$data);

  factory Variables$Mutation$UpdateSocksPort.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$socksProxyPort = data['socksProxyPort'];
    result$data['socksProxyPort'] = (l$socksProxyPort as String);
    return Variables$Mutation$UpdateSocksPort._(result$data);
  }

  Map<String, dynamic> _$data;

  String get socksProxyPort => (_$data['socksProxyPort'] as String);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$socksProxyPort = socksProxyPort;
    result$data['socksProxyPort'] = l$socksProxyPort;
    return result$data;
  }

  CopyWith$Variables$Mutation$UpdateSocksPort<
          Variables$Mutation$UpdateSocksPort>
      get copyWith => CopyWith$Variables$Mutation$UpdateSocksPort(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$UpdateSocksPort ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$socksProxyPort = socksProxyPort;
    final lOther$socksProxyPort = other.socksProxyPort;
    if (l$socksProxyPort != lOther$socksProxyPort) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$socksProxyPort = socksProxyPort;
    return Object.hashAll([l$socksProxyPort]);
  }
}

abstract class CopyWith$Variables$Mutation$UpdateSocksPort<TRes> {
  factory CopyWith$Variables$Mutation$UpdateSocksPort(
    Variables$Mutation$UpdateSocksPort instance,
    TRes Function(Variables$Mutation$UpdateSocksPort) then,
  ) = _CopyWithImpl$Variables$Mutation$UpdateSocksPort;

  factory CopyWith$Variables$Mutation$UpdateSocksPort.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$UpdateSocksPort;

  TRes call({String? socksProxyPort});
}

class _CopyWithImpl$Variables$Mutation$UpdateSocksPort<TRes>
    implements CopyWith$Variables$Mutation$UpdateSocksPort<TRes> {
  _CopyWithImpl$Variables$Mutation$UpdateSocksPort(
    this._instance,
    this._then,
  );

  final Variables$Mutation$UpdateSocksPort _instance;

  final TRes Function(Variables$Mutation$UpdateSocksPort) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? socksProxyPort = _undefined}) =>
      _then(Variables$Mutation$UpdateSocksPort._({
        ..._instance._$data,
        if (socksProxyPort != _undefined && socksProxyPort != null)
          'socksProxyPort': (socksProxyPort as String),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$UpdateSocksPort<TRes>
    implements CopyWith$Variables$Mutation$UpdateSocksPort<TRes> {
  _CopyWithStubImpl$Variables$Mutation$UpdateSocksPort(this._res);

  TRes _res;

  call({String? socksProxyPort}) => _res;
}

class Mutation$UpdateSocksPort {
  Mutation$UpdateSocksPort({
    required this.setSettings,
    this.$__typename = 'Mutation',
  });

  factory Mutation$UpdateSocksPort.fromJson(Map<String, dynamic> json) {
    final l$setSettings = json['setSettings'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateSocksPort(
      setSettings: Mutation$UpdateSocksPort$setSettings.fromJson(
          (l$setSettings as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$UpdateSocksPort$setSettings setSettings;

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
    if (other is! Mutation$UpdateSocksPort ||
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

extension UtilityExtension$Mutation$UpdateSocksPort
    on Mutation$UpdateSocksPort {
  CopyWith$Mutation$UpdateSocksPort<Mutation$UpdateSocksPort> get copyWith =>
      CopyWith$Mutation$UpdateSocksPort(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Mutation$UpdateSocksPort<TRes> {
  factory CopyWith$Mutation$UpdateSocksPort(
    Mutation$UpdateSocksPort instance,
    TRes Function(Mutation$UpdateSocksPort) then,
  ) = _CopyWithImpl$Mutation$UpdateSocksPort;

  factory CopyWith$Mutation$UpdateSocksPort.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateSocksPort;

  TRes call({
    Mutation$UpdateSocksPort$setSettings? setSettings,
    String? $__typename,
  });
  CopyWith$Mutation$UpdateSocksPort$setSettings<TRes> get setSettings;
}

class _CopyWithImpl$Mutation$UpdateSocksPort<TRes>
    implements CopyWith$Mutation$UpdateSocksPort<TRes> {
  _CopyWithImpl$Mutation$UpdateSocksPort(
    this._instance,
    this._then,
  );

  final Mutation$UpdateSocksPort _instance;

  final TRes Function(Mutation$UpdateSocksPort) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? setSettings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateSocksPort(
        setSettings: setSettings == _undefined || setSettings == null
            ? _instance.setSettings
            : (setSettings as Mutation$UpdateSocksPort$setSettings),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$UpdateSocksPort$setSettings<TRes> get setSettings {
    final local$setSettings = _instance.setSettings;
    return CopyWith$Mutation$UpdateSocksPort$setSettings(
        local$setSettings, (e) => call(setSettings: e));
  }
}

class _CopyWithStubImpl$Mutation$UpdateSocksPort<TRes>
    implements CopyWith$Mutation$UpdateSocksPort<TRes> {
  _CopyWithStubImpl$Mutation$UpdateSocksPort(this._res);

  TRes _res;

  call({
    Mutation$UpdateSocksPort$setSettings? setSettings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$UpdateSocksPort$setSettings<TRes> get setSettings =>
      CopyWith$Mutation$UpdateSocksPort$setSettings.stub(_res);
}

const documentNodeMutationUpdateSocksPort = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'UpdateSocksPort'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'socksProxyPort')),
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
                    name: NameNode(value: 'socksProxyPort'),
                    value:
                        VariableNode(name: NameNode(value: 'socksProxyPort')),
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
Mutation$UpdateSocksPort _parserFn$Mutation$UpdateSocksPort(
        Map<String, dynamic> data) =>
    Mutation$UpdateSocksPort.fromJson(data);
typedef OnMutationCompleted$Mutation$UpdateSocksPort = FutureOr<void> Function(
  Map<String, dynamic>?,
  Mutation$UpdateSocksPort?,
);

class Options$Mutation$UpdateSocksPort
    extends graphql.MutationOptions<Mutation$UpdateSocksPort> {
  Options$Mutation$UpdateSocksPort({
    String? operationName,
    required Variables$Mutation$UpdateSocksPort variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateSocksPort? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateSocksPort? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateSocksPort>? update,
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
                        : _parserFn$Mutation$UpdateSocksPort(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateSocksPort,
          parserFn: _parserFn$Mutation$UpdateSocksPort,
        );

  final OnMutationCompleted$Mutation$UpdateSocksPort? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$UpdateSocksPort
    extends graphql.WatchQueryOptions<Mutation$UpdateSocksPort> {
  WatchOptions$Mutation$UpdateSocksPort({
    String? operationName,
    required Variables$Mutation$UpdateSocksPort variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateSocksPort? typedOptimisticResult,
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
          document: documentNodeMutationUpdateSocksPort,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$UpdateSocksPort,
        );
}

extension ClientExtension$Mutation$UpdateSocksPort on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$UpdateSocksPort>> mutate$UpdateSocksPort(
          Options$Mutation$UpdateSocksPort options) async =>
      await this.mutate(options);

  graphql.ObservableQuery<Mutation$UpdateSocksPort>
      watchMutation$UpdateSocksPort(
              WatchOptions$Mutation$UpdateSocksPort options) =>
          this.watchMutation(options);
}

class Mutation$UpdateSocksPort$HookResult {
  Mutation$UpdateSocksPort$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$UpdateSocksPort runMutation;

  final graphql.QueryResult<Mutation$UpdateSocksPort> result;
}

Mutation$UpdateSocksPort$HookResult useMutation$UpdateSocksPort(
    [WidgetOptions$Mutation$UpdateSocksPort? options]) {
  final result = graphql_flutter
      .useMutation(options ?? WidgetOptions$Mutation$UpdateSocksPort());
  return Mutation$UpdateSocksPort$HookResult(
    (variables, {optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables.toJson(),
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$UpdateSocksPort>
    useWatchMutation$UpdateSocksPort(
            WatchOptions$Mutation$UpdateSocksPort options) =>
        graphql_flutter.useWatchMutation(options);

class WidgetOptions$Mutation$UpdateSocksPort
    extends graphql.MutationOptions<Mutation$UpdateSocksPort> {
  WidgetOptions$Mutation$UpdateSocksPort({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateSocksPort? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateSocksPort? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateSocksPort>? update,
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
                        : _parserFn$Mutation$UpdateSocksPort(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateSocksPort,
          parserFn: _parserFn$Mutation$UpdateSocksPort,
        );

  final OnMutationCompleted$Mutation$UpdateSocksPort? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$UpdateSocksPort
    = graphql.MultiSourceResult<Mutation$UpdateSocksPort> Function(
  Variables$Mutation$UpdateSocksPort, {
  Object? optimisticResult,
  Mutation$UpdateSocksPort? typedOptimisticResult,
});
typedef Builder$Mutation$UpdateSocksPort = widgets.Widget Function(
  RunMutation$Mutation$UpdateSocksPort,
  graphql.QueryResult<Mutation$UpdateSocksPort>?,
);

class Mutation$UpdateSocksPort$Widget
    extends graphql_flutter.Mutation<Mutation$UpdateSocksPort> {
  Mutation$UpdateSocksPort$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$UpdateSocksPort? options,
    required Builder$Mutation$UpdateSocksPort builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$UpdateSocksPort(),
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

class Mutation$UpdateSocksPort$setSettings {
  Mutation$UpdateSocksPort$setSettings({
    required this.settings,
    this.$__typename = 'SetSettingsPayload',
  });

  factory Mutation$UpdateSocksPort$setSettings.fromJson(
      Map<String, dynamic> json) {
    final l$settings = json['settings'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateSocksPort$setSettings(
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
    if (other is! Mutation$UpdateSocksPort$setSettings ||
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

extension UtilityExtension$Mutation$UpdateSocksPort$setSettings
    on Mutation$UpdateSocksPort$setSettings {
  CopyWith$Mutation$UpdateSocksPort$setSettings<
          Mutation$UpdateSocksPort$setSettings>
      get copyWith => CopyWith$Mutation$UpdateSocksPort$setSettings(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdateSocksPort$setSettings<TRes> {
  factory CopyWith$Mutation$UpdateSocksPort$setSettings(
    Mutation$UpdateSocksPort$setSettings instance,
    TRes Function(Mutation$UpdateSocksPort$setSettings) then,
  ) = _CopyWithImpl$Mutation$UpdateSocksPort$setSettings;

  factory CopyWith$Mutation$UpdateSocksPort$setSettings.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateSocksPort$setSettings;

  TRes call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  });
  CopyWith$Fragment$SettingsDto<TRes> get settings;
}

class _CopyWithImpl$Mutation$UpdateSocksPort$setSettings<TRes>
    implements CopyWith$Mutation$UpdateSocksPort$setSettings<TRes> {
  _CopyWithImpl$Mutation$UpdateSocksPort$setSettings(
    this._instance,
    this._then,
  );

  final Mutation$UpdateSocksPort$setSettings _instance;

  final TRes Function(Mutation$UpdateSocksPort$setSettings) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? settings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateSocksPort$setSettings(
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

class _CopyWithStubImpl$Mutation$UpdateSocksPort$setSettings<TRes>
    implements CopyWith$Mutation$UpdateSocksPort$setSettings<TRes> {
  _CopyWithStubImpl$Mutation$UpdateSocksPort$setSettings(this._res);

  TRes _res;

  call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$SettingsDto<TRes> get settings =>
      CopyWith$Fragment$SettingsDto.stub(_res);
}

class Variables$Mutation$UpdateSocksPassword {
  factory Variables$Mutation$UpdateSocksPassword(
          {required String socksProxyPassword}) =>
      Variables$Mutation$UpdateSocksPassword._({
        r'socksProxyPassword': socksProxyPassword,
      });

  Variables$Mutation$UpdateSocksPassword._(this._$data);

  factory Variables$Mutation$UpdateSocksPassword.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$socksProxyPassword = data['socksProxyPassword'];
    result$data['socksProxyPassword'] = (l$socksProxyPassword as String);
    return Variables$Mutation$UpdateSocksPassword._(result$data);
  }

  Map<String, dynamic> _$data;

  String get socksProxyPassword => (_$data['socksProxyPassword'] as String);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$socksProxyPassword = socksProxyPassword;
    result$data['socksProxyPassword'] = l$socksProxyPassword;
    return result$data;
  }

  CopyWith$Variables$Mutation$UpdateSocksPassword<
          Variables$Mutation$UpdateSocksPassword>
      get copyWith => CopyWith$Variables$Mutation$UpdateSocksPassword(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$UpdateSocksPassword ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$socksProxyPassword = socksProxyPassword;
    final lOther$socksProxyPassword = other.socksProxyPassword;
    if (l$socksProxyPassword != lOther$socksProxyPassword) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$socksProxyPassword = socksProxyPassword;
    return Object.hashAll([l$socksProxyPassword]);
  }
}

abstract class CopyWith$Variables$Mutation$UpdateSocksPassword<TRes> {
  factory CopyWith$Variables$Mutation$UpdateSocksPassword(
    Variables$Mutation$UpdateSocksPassword instance,
    TRes Function(Variables$Mutation$UpdateSocksPassword) then,
  ) = _CopyWithImpl$Variables$Mutation$UpdateSocksPassword;

  factory CopyWith$Variables$Mutation$UpdateSocksPassword.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$UpdateSocksPassword;

  TRes call({String? socksProxyPassword});
}

class _CopyWithImpl$Variables$Mutation$UpdateSocksPassword<TRes>
    implements CopyWith$Variables$Mutation$UpdateSocksPassword<TRes> {
  _CopyWithImpl$Variables$Mutation$UpdateSocksPassword(
    this._instance,
    this._then,
  );

  final Variables$Mutation$UpdateSocksPassword _instance;

  final TRes Function(Variables$Mutation$UpdateSocksPassword) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? socksProxyPassword = _undefined}) =>
      _then(Variables$Mutation$UpdateSocksPassword._({
        ..._instance._$data,
        if (socksProxyPassword != _undefined && socksProxyPassword != null)
          'socksProxyPassword': (socksProxyPassword as String),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$UpdateSocksPassword<TRes>
    implements CopyWith$Variables$Mutation$UpdateSocksPassword<TRes> {
  _CopyWithStubImpl$Variables$Mutation$UpdateSocksPassword(this._res);

  TRes _res;

  call({String? socksProxyPassword}) => _res;
}

class Mutation$UpdateSocksPassword {
  Mutation$UpdateSocksPassword({
    required this.setSettings,
    this.$__typename = 'Mutation',
  });

  factory Mutation$UpdateSocksPassword.fromJson(Map<String, dynamic> json) {
    final l$setSettings = json['setSettings'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateSocksPassword(
      setSettings: Mutation$UpdateSocksPassword$setSettings.fromJson(
          (l$setSettings as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$UpdateSocksPassword$setSettings setSettings;

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
    if (other is! Mutation$UpdateSocksPassword ||
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

extension UtilityExtension$Mutation$UpdateSocksPassword
    on Mutation$UpdateSocksPassword {
  CopyWith$Mutation$UpdateSocksPassword<Mutation$UpdateSocksPassword>
      get copyWith => CopyWith$Mutation$UpdateSocksPassword(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdateSocksPassword<TRes> {
  factory CopyWith$Mutation$UpdateSocksPassword(
    Mutation$UpdateSocksPassword instance,
    TRes Function(Mutation$UpdateSocksPassword) then,
  ) = _CopyWithImpl$Mutation$UpdateSocksPassword;

  factory CopyWith$Mutation$UpdateSocksPassword.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateSocksPassword;

  TRes call({
    Mutation$UpdateSocksPassword$setSettings? setSettings,
    String? $__typename,
  });
  CopyWith$Mutation$UpdateSocksPassword$setSettings<TRes> get setSettings;
}

class _CopyWithImpl$Mutation$UpdateSocksPassword<TRes>
    implements CopyWith$Mutation$UpdateSocksPassword<TRes> {
  _CopyWithImpl$Mutation$UpdateSocksPassword(
    this._instance,
    this._then,
  );

  final Mutation$UpdateSocksPassword _instance;

  final TRes Function(Mutation$UpdateSocksPassword) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? setSettings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateSocksPassword(
        setSettings: setSettings == _undefined || setSettings == null
            ? _instance.setSettings
            : (setSettings as Mutation$UpdateSocksPassword$setSettings),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$UpdateSocksPassword$setSettings<TRes> get setSettings {
    final local$setSettings = _instance.setSettings;
    return CopyWith$Mutation$UpdateSocksPassword$setSettings(
        local$setSettings, (e) => call(setSettings: e));
  }
}

class _CopyWithStubImpl$Mutation$UpdateSocksPassword<TRes>
    implements CopyWith$Mutation$UpdateSocksPassword<TRes> {
  _CopyWithStubImpl$Mutation$UpdateSocksPassword(this._res);

  TRes _res;

  call({
    Mutation$UpdateSocksPassword$setSettings? setSettings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$UpdateSocksPassword$setSettings<TRes> get setSettings =>
      CopyWith$Mutation$UpdateSocksPassword$setSettings.stub(_res);
}

const documentNodeMutationUpdateSocksPassword = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'UpdateSocksPassword'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'socksProxyPassword')),
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
                    name: NameNode(value: 'socksProxyPassword'),
                    value: VariableNode(
                        name: NameNode(value: 'socksProxyPassword')),
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
Mutation$UpdateSocksPassword _parserFn$Mutation$UpdateSocksPassword(
        Map<String, dynamic> data) =>
    Mutation$UpdateSocksPassword.fromJson(data);
typedef OnMutationCompleted$Mutation$UpdateSocksPassword = FutureOr<void>
    Function(
  Map<String, dynamic>?,
  Mutation$UpdateSocksPassword?,
);

class Options$Mutation$UpdateSocksPassword
    extends graphql.MutationOptions<Mutation$UpdateSocksPassword> {
  Options$Mutation$UpdateSocksPassword({
    String? operationName,
    required Variables$Mutation$UpdateSocksPassword variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateSocksPassword? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateSocksPassword? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateSocksPassword>? update,
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
                        : _parserFn$Mutation$UpdateSocksPassword(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateSocksPassword,
          parserFn: _parserFn$Mutation$UpdateSocksPassword,
        );

  final OnMutationCompleted$Mutation$UpdateSocksPassword? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$UpdateSocksPassword
    extends graphql.WatchQueryOptions<Mutation$UpdateSocksPassword> {
  WatchOptions$Mutation$UpdateSocksPassword({
    String? operationName,
    required Variables$Mutation$UpdateSocksPassword variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateSocksPassword? typedOptimisticResult,
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
          document: documentNodeMutationUpdateSocksPassword,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$UpdateSocksPassword,
        );
}

extension ClientExtension$Mutation$UpdateSocksPassword
    on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$UpdateSocksPassword>>
      mutate$UpdateSocksPassword(
              Options$Mutation$UpdateSocksPassword options) async =>
          await this.mutate(options);

  graphql.ObservableQuery<Mutation$UpdateSocksPassword>
      watchMutation$UpdateSocksPassword(
              WatchOptions$Mutation$UpdateSocksPassword options) =>
          this.watchMutation(options);
}

class Mutation$UpdateSocksPassword$HookResult {
  Mutation$UpdateSocksPassword$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$UpdateSocksPassword runMutation;

  final graphql.QueryResult<Mutation$UpdateSocksPassword> result;
}

Mutation$UpdateSocksPassword$HookResult useMutation$UpdateSocksPassword(
    [WidgetOptions$Mutation$UpdateSocksPassword? options]) {
  final result = graphql_flutter
      .useMutation(options ?? WidgetOptions$Mutation$UpdateSocksPassword());
  return Mutation$UpdateSocksPassword$HookResult(
    (variables, {optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables.toJson(),
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$UpdateSocksPassword>
    useWatchMutation$UpdateSocksPassword(
            WatchOptions$Mutation$UpdateSocksPassword options) =>
        graphql_flutter.useWatchMutation(options);

class WidgetOptions$Mutation$UpdateSocksPassword
    extends graphql.MutationOptions<Mutation$UpdateSocksPassword> {
  WidgetOptions$Mutation$UpdateSocksPassword({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateSocksPassword? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateSocksPassword? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateSocksPassword>? update,
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
                        : _parserFn$Mutation$UpdateSocksPassword(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateSocksPassword,
          parserFn: _parserFn$Mutation$UpdateSocksPassword,
        );

  final OnMutationCompleted$Mutation$UpdateSocksPassword? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$UpdateSocksPassword
    = graphql.MultiSourceResult<Mutation$UpdateSocksPassword> Function(
  Variables$Mutation$UpdateSocksPassword, {
  Object? optimisticResult,
  Mutation$UpdateSocksPassword? typedOptimisticResult,
});
typedef Builder$Mutation$UpdateSocksPassword = widgets.Widget Function(
  RunMutation$Mutation$UpdateSocksPassword,
  graphql.QueryResult<Mutation$UpdateSocksPassword>?,
);

class Mutation$UpdateSocksPassword$Widget
    extends graphql_flutter.Mutation<Mutation$UpdateSocksPassword> {
  Mutation$UpdateSocksPassword$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$UpdateSocksPassword? options,
    required Builder$Mutation$UpdateSocksPassword builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$UpdateSocksPassword(),
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

class Mutation$UpdateSocksPassword$setSettings {
  Mutation$UpdateSocksPassword$setSettings({
    required this.settings,
    this.$__typename = 'SetSettingsPayload',
  });

  factory Mutation$UpdateSocksPassword$setSettings.fromJson(
      Map<String, dynamic> json) {
    final l$settings = json['settings'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateSocksPassword$setSettings(
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
    if (other is! Mutation$UpdateSocksPassword$setSettings ||
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

extension UtilityExtension$Mutation$UpdateSocksPassword$setSettings
    on Mutation$UpdateSocksPassword$setSettings {
  CopyWith$Mutation$UpdateSocksPassword$setSettings<
          Mutation$UpdateSocksPassword$setSettings>
      get copyWith => CopyWith$Mutation$UpdateSocksPassword$setSettings(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdateSocksPassword$setSettings<TRes> {
  factory CopyWith$Mutation$UpdateSocksPassword$setSettings(
    Mutation$UpdateSocksPassword$setSettings instance,
    TRes Function(Mutation$UpdateSocksPassword$setSettings) then,
  ) = _CopyWithImpl$Mutation$UpdateSocksPassword$setSettings;

  factory CopyWith$Mutation$UpdateSocksPassword$setSettings.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateSocksPassword$setSettings;

  TRes call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  });
  CopyWith$Fragment$SettingsDto<TRes> get settings;
}

class _CopyWithImpl$Mutation$UpdateSocksPassword$setSettings<TRes>
    implements CopyWith$Mutation$UpdateSocksPassword$setSettings<TRes> {
  _CopyWithImpl$Mutation$UpdateSocksPassword$setSettings(
    this._instance,
    this._then,
  );

  final Mutation$UpdateSocksPassword$setSettings _instance;

  final TRes Function(Mutation$UpdateSocksPassword$setSettings) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? settings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateSocksPassword$setSettings(
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

class _CopyWithStubImpl$Mutation$UpdateSocksPassword$setSettings<TRes>
    implements CopyWith$Mutation$UpdateSocksPassword$setSettings<TRes> {
  _CopyWithStubImpl$Mutation$UpdateSocksPassword$setSettings(this._res);

  TRes _res;

  call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$SettingsDto<TRes> get settings =>
      CopyWith$Fragment$SettingsDto.stub(_res);
}

class Variables$Mutation$UpdateSocksHost {
  factory Variables$Mutation$UpdateSocksHost(
          {required String socksProxyHost}) =>
      Variables$Mutation$UpdateSocksHost._({
        r'socksProxyHost': socksProxyHost,
      });

  Variables$Mutation$UpdateSocksHost._(this._$data);

  factory Variables$Mutation$UpdateSocksHost.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$socksProxyHost = data['socksProxyHost'];
    result$data['socksProxyHost'] = (l$socksProxyHost as String);
    return Variables$Mutation$UpdateSocksHost._(result$data);
  }

  Map<String, dynamic> _$data;

  String get socksProxyHost => (_$data['socksProxyHost'] as String);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$socksProxyHost = socksProxyHost;
    result$data['socksProxyHost'] = l$socksProxyHost;
    return result$data;
  }

  CopyWith$Variables$Mutation$UpdateSocksHost<
          Variables$Mutation$UpdateSocksHost>
      get copyWith => CopyWith$Variables$Mutation$UpdateSocksHost(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$UpdateSocksHost ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$socksProxyHost = socksProxyHost;
    final lOther$socksProxyHost = other.socksProxyHost;
    if (l$socksProxyHost != lOther$socksProxyHost) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$socksProxyHost = socksProxyHost;
    return Object.hashAll([l$socksProxyHost]);
  }
}

abstract class CopyWith$Variables$Mutation$UpdateSocksHost<TRes> {
  factory CopyWith$Variables$Mutation$UpdateSocksHost(
    Variables$Mutation$UpdateSocksHost instance,
    TRes Function(Variables$Mutation$UpdateSocksHost) then,
  ) = _CopyWithImpl$Variables$Mutation$UpdateSocksHost;

  factory CopyWith$Variables$Mutation$UpdateSocksHost.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$UpdateSocksHost;

  TRes call({String? socksProxyHost});
}

class _CopyWithImpl$Variables$Mutation$UpdateSocksHost<TRes>
    implements CopyWith$Variables$Mutation$UpdateSocksHost<TRes> {
  _CopyWithImpl$Variables$Mutation$UpdateSocksHost(
    this._instance,
    this._then,
  );

  final Variables$Mutation$UpdateSocksHost _instance;

  final TRes Function(Variables$Mutation$UpdateSocksHost) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? socksProxyHost = _undefined}) =>
      _then(Variables$Mutation$UpdateSocksHost._({
        ..._instance._$data,
        if (socksProxyHost != _undefined && socksProxyHost != null)
          'socksProxyHost': (socksProxyHost as String),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$UpdateSocksHost<TRes>
    implements CopyWith$Variables$Mutation$UpdateSocksHost<TRes> {
  _CopyWithStubImpl$Variables$Mutation$UpdateSocksHost(this._res);

  TRes _res;

  call({String? socksProxyHost}) => _res;
}

class Mutation$UpdateSocksHost {
  Mutation$UpdateSocksHost({
    required this.setSettings,
    this.$__typename = 'Mutation',
  });

  factory Mutation$UpdateSocksHost.fromJson(Map<String, dynamic> json) {
    final l$setSettings = json['setSettings'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateSocksHost(
      setSettings: Mutation$UpdateSocksHost$setSettings.fromJson(
          (l$setSettings as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$UpdateSocksHost$setSettings setSettings;

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
    if (other is! Mutation$UpdateSocksHost ||
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

extension UtilityExtension$Mutation$UpdateSocksHost
    on Mutation$UpdateSocksHost {
  CopyWith$Mutation$UpdateSocksHost<Mutation$UpdateSocksHost> get copyWith =>
      CopyWith$Mutation$UpdateSocksHost(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Mutation$UpdateSocksHost<TRes> {
  factory CopyWith$Mutation$UpdateSocksHost(
    Mutation$UpdateSocksHost instance,
    TRes Function(Mutation$UpdateSocksHost) then,
  ) = _CopyWithImpl$Mutation$UpdateSocksHost;

  factory CopyWith$Mutation$UpdateSocksHost.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateSocksHost;

  TRes call({
    Mutation$UpdateSocksHost$setSettings? setSettings,
    String? $__typename,
  });
  CopyWith$Mutation$UpdateSocksHost$setSettings<TRes> get setSettings;
}

class _CopyWithImpl$Mutation$UpdateSocksHost<TRes>
    implements CopyWith$Mutation$UpdateSocksHost<TRes> {
  _CopyWithImpl$Mutation$UpdateSocksHost(
    this._instance,
    this._then,
  );

  final Mutation$UpdateSocksHost _instance;

  final TRes Function(Mutation$UpdateSocksHost) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? setSettings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateSocksHost(
        setSettings: setSettings == _undefined || setSettings == null
            ? _instance.setSettings
            : (setSettings as Mutation$UpdateSocksHost$setSettings),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$UpdateSocksHost$setSettings<TRes> get setSettings {
    final local$setSettings = _instance.setSettings;
    return CopyWith$Mutation$UpdateSocksHost$setSettings(
        local$setSettings, (e) => call(setSettings: e));
  }
}

class _CopyWithStubImpl$Mutation$UpdateSocksHost<TRes>
    implements CopyWith$Mutation$UpdateSocksHost<TRes> {
  _CopyWithStubImpl$Mutation$UpdateSocksHost(this._res);

  TRes _res;

  call({
    Mutation$UpdateSocksHost$setSettings? setSettings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$UpdateSocksHost$setSettings<TRes> get setSettings =>
      CopyWith$Mutation$UpdateSocksHost$setSettings.stub(_res);
}

const documentNodeMutationUpdateSocksHost = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'UpdateSocksHost'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'socksProxyHost')),
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
                    name: NameNode(value: 'socksProxyHost'),
                    value:
                        VariableNode(name: NameNode(value: 'socksProxyHost')),
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
Mutation$UpdateSocksHost _parserFn$Mutation$UpdateSocksHost(
        Map<String, dynamic> data) =>
    Mutation$UpdateSocksHost.fromJson(data);
typedef OnMutationCompleted$Mutation$UpdateSocksHost = FutureOr<void> Function(
  Map<String, dynamic>?,
  Mutation$UpdateSocksHost?,
);

class Options$Mutation$UpdateSocksHost
    extends graphql.MutationOptions<Mutation$UpdateSocksHost> {
  Options$Mutation$UpdateSocksHost({
    String? operationName,
    required Variables$Mutation$UpdateSocksHost variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateSocksHost? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateSocksHost? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateSocksHost>? update,
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
                        : _parserFn$Mutation$UpdateSocksHost(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateSocksHost,
          parserFn: _parserFn$Mutation$UpdateSocksHost,
        );

  final OnMutationCompleted$Mutation$UpdateSocksHost? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$UpdateSocksHost
    extends graphql.WatchQueryOptions<Mutation$UpdateSocksHost> {
  WatchOptions$Mutation$UpdateSocksHost({
    String? operationName,
    required Variables$Mutation$UpdateSocksHost variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateSocksHost? typedOptimisticResult,
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
          document: documentNodeMutationUpdateSocksHost,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$UpdateSocksHost,
        );
}

extension ClientExtension$Mutation$UpdateSocksHost on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$UpdateSocksHost>> mutate$UpdateSocksHost(
          Options$Mutation$UpdateSocksHost options) async =>
      await this.mutate(options);

  graphql.ObservableQuery<Mutation$UpdateSocksHost>
      watchMutation$UpdateSocksHost(
              WatchOptions$Mutation$UpdateSocksHost options) =>
          this.watchMutation(options);
}

class Mutation$UpdateSocksHost$HookResult {
  Mutation$UpdateSocksHost$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$UpdateSocksHost runMutation;

  final graphql.QueryResult<Mutation$UpdateSocksHost> result;
}

Mutation$UpdateSocksHost$HookResult useMutation$UpdateSocksHost(
    [WidgetOptions$Mutation$UpdateSocksHost? options]) {
  final result = graphql_flutter
      .useMutation(options ?? WidgetOptions$Mutation$UpdateSocksHost());
  return Mutation$UpdateSocksHost$HookResult(
    (variables, {optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables.toJson(),
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$UpdateSocksHost>
    useWatchMutation$UpdateSocksHost(
            WatchOptions$Mutation$UpdateSocksHost options) =>
        graphql_flutter.useWatchMutation(options);

class WidgetOptions$Mutation$UpdateSocksHost
    extends graphql.MutationOptions<Mutation$UpdateSocksHost> {
  WidgetOptions$Mutation$UpdateSocksHost({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateSocksHost? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateSocksHost? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateSocksHost>? update,
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
                        : _parserFn$Mutation$UpdateSocksHost(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateSocksHost,
          parserFn: _parserFn$Mutation$UpdateSocksHost,
        );

  final OnMutationCompleted$Mutation$UpdateSocksHost? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$UpdateSocksHost
    = graphql.MultiSourceResult<Mutation$UpdateSocksHost> Function(
  Variables$Mutation$UpdateSocksHost, {
  Object? optimisticResult,
  Mutation$UpdateSocksHost? typedOptimisticResult,
});
typedef Builder$Mutation$UpdateSocksHost = widgets.Widget Function(
  RunMutation$Mutation$UpdateSocksHost,
  graphql.QueryResult<Mutation$UpdateSocksHost>?,
);

class Mutation$UpdateSocksHost$Widget
    extends graphql_flutter.Mutation<Mutation$UpdateSocksHost> {
  Mutation$UpdateSocksHost$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$UpdateSocksHost? options,
    required Builder$Mutation$UpdateSocksHost builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$UpdateSocksHost(),
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

class Mutation$UpdateSocksHost$setSettings {
  Mutation$UpdateSocksHost$setSettings({
    required this.settings,
    this.$__typename = 'SetSettingsPayload',
  });

  factory Mutation$UpdateSocksHost$setSettings.fromJson(
      Map<String, dynamic> json) {
    final l$settings = json['settings'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateSocksHost$setSettings(
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
    if (other is! Mutation$UpdateSocksHost$setSettings ||
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

extension UtilityExtension$Mutation$UpdateSocksHost$setSettings
    on Mutation$UpdateSocksHost$setSettings {
  CopyWith$Mutation$UpdateSocksHost$setSettings<
          Mutation$UpdateSocksHost$setSettings>
      get copyWith => CopyWith$Mutation$UpdateSocksHost$setSettings(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdateSocksHost$setSettings<TRes> {
  factory CopyWith$Mutation$UpdateSocksHost$setSettings(
    Mutation$UpdateSocksHost$setSettings instance,
    TRes Function(Mutation$UpdateSocksHost$setSettings) then,
  ) = _CopyWithImpl$Mutation$UpdateSocksHost$setSettings;

  factory CopyWith$Mutation$UpdateSocksHost$setSettings.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateSocksHost$setSettings;

  TRes call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  });
  CopyWith$Fragment$SettingsDto<TRes> get settings;
}

class _CopyWithImpl$Mutation$UpdateSocksHost$setSettings<TRes>
    implements CopyWith$Mutation$UpdateSocksHost$setSettings<TRes> {
  _CopyWithImpl$Mutation$UpdateSocksHost$setSettings(
    this._instance,
    this._then,
  );

  final Mutation$UpdateSocksHost$setSettings _instance;

  final TRes Function(Mutation$UpdateSocksHost$setSettings) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? settings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateSocksHost$setSettings(
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

class _CopyWithStubImpl$Mutation$UpdateSocksHost$setSettings<TRes>
    implements CopyWith$Mutation$UpdateSocksHost$setSettings<TRes> {
  _CopyWithStubImpl$Mutation$UpdateSocksHost$setSettings(this._res);

  TRes _res;

  call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$SettingsDto<TRes> get settings =>
      CopyWith$Fragment$SettingsDto.stub(_res);
}

class Variables$Mutation$UpdateServerIp {
  factory Variables$Mutation$UpdateServerIp({String? ip}) =>
      Variables$Mutation$UpdateServerIp._({
        if (ip != null) r'ip': ip,
      });

  Variables$Mutation$UpdateServerIp._(this._$data);

  factory Variables$Mutation$UpdateServerIp.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('ip')) {
      final l$ip = data['ip'];
      result$data['ip'] = (l$ip as String?);
    }
    return Variables$Mutation$UpdateServerIp._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get ip => (_$data['ip'] as String?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('ip')) {
      final l$ip = ip;
      result$data['ip'] = l$ip;
    }
    return result$data;
  }

  CopyWith$Variables$Mutation$UpdateServerIp<Variables$Mutation$UpdateServerIp>
      get copyWith => CopyWith$Variables$Mutation$UpdateServerIp(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$UpdateServerIp ||
        runtimeType != other.runtimeType) {
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
    return true;
  }

  @override
  int get hashCode {
    final l$ip = ip;
    return Object.hashAll([_$data.containsKey('ip') ? l$ip : const {}]);
  }
}

abstract class CopyWith$Variables$Mutation$UpdateServerIp<TRes> {
  factory CopyWith$Variables$Mutation$UpdateServerIp(
    Variables$Mutation$UpdateServerIp instance,
    TRes Function(Variables$Mutation$UpdateServerIp) then,
  ) = _CopyWithImpl$Variables$Mutation$UpdateServerIp;

  factory CopyWith$Variables$Mutation$UpdateServerIp.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$UpdateServerIp;

  TRes call({String? ip});
}

class _CopyWithImpl$Variables$Mutation$UpdateServerIp<TRes>
    implements CopyWith$Variables$Mutation$UpdateServerIp<TRes> {
  _CopyWithImpl$Variables$Mutation$UpdateServerIp(
    this._instance,
    this._then,
  );

  final Variables$Mutation$UpdateServerIp _instance;

  final TRes Function(Variables$Mutation$UpdateServerIp) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? ip = _undefined}) =>
      _then(Variables$Mutation$UpdateServerIp._({
        ..._instance._$data,
        if (ip != _undefined) 'ip': (ip as String?),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$UpdateServerIp<TRes>
    implements CopyWith$Variables$Mutation$UpdateServerIp<TRes> {
  _CopyWithStubImpl$Variables$Mutation$UpdateServerIp(this._res);

  TRes _res;

  call({String? ip}) => _res;
}

class Mutation$UpdateServerIp {
  Mutation$UpdateServerIp({
    required this.setSettings,
    this.$__typename = 'Mutation',
  });

  factory Mutation$UpdateServerIp.fromJson(Map<String, dynamic> json) {
    final l$setSettings = json['setSettings'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateServerIp(
      setSettings: Mutation$UpdateServerIp$setSettings.fromJson(
          (l$setSettings as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$UpdateServerIp$setSettings setSettings;

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
    if (other is! Mutation$UpdateServerIp || runtimeType != other.runtimeType) {
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

extension UtilityExtension$Mutation$UpdateServerIp on Mutation$UpdateServerIp {
  CopyWith$Mutation$UpdateServerIp<Mutation$UpdateServerIp> get copyWith =>
      CopyWith$Mutation$UpdateServerIp(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Mutation$UpdateServerIp<TRes> {
  factory CopyWith$Mutation$UpdateServerIp(
    Mutation$UpdateServerIp instance,
    TRes Function(Mutation$UpdateServerIp) then,
  ) = _CopyWithImpl$Mutation$UpdateServerIp;

  factory CopyWith$Mutation$UpdateServerIp.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateServerIp;

  TRes call({
    Mutation$UpdateServerIp$setSettings? setSettings,
    String? $__typename,
  });
  CopyWith$Mutation$UpdateServerIp$setSettings<TRes> get setSettings;
}

class _CopyWithImpl$Mutation$UpdateServerIp<TRes>
    implements CopyWith$Mutation$UpdateServerIp<TRes> {
  _CopyWithImpl$Mutation$UpdateServerIp(
    this._instance,
    this._then,
  );

  final Mutation$UpdateServerIp _instance;

  final TRes Function(Mutation$UpdateServerIp) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? setSettings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateServerIp(
        setSettings: setSettings == _undefined || setSettings == null
            ? _instance.setSettings
            : (setSettings as Mutation$UpdateServerIp$setSettings),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$UpdateServerIp$setSettings<TRes> get setSettings {
    final local$setSettings = _instance.setSettings;
    return CopyWith$Mutation$UpdateServerIp$setSettings(
        local$setSettings, (e) => call(setSettings: e));
  }
}

class _CopyWithStubImpl$Mutation$UpdateServerIp<TRes>
    implements CopyWith$Mutation$UpdateServerIp<TRes> {
  _CopyWithStubImpl$Mutation$UpdateServerIp(this._res);

  TRes _res;

  call({
    Mutation$UpdateServerIp$setSettings? setSettings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$UpdateServerIp$setSettings<TRes> get setSettings =>
      CopyWith$Mutation$UpdateServerIp$setSettings.stub(_res);
}

const documentNodeMutationUpdateServerIp = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'UpdateServerIp'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'ip')),
        type: NamedTypeNode(
          name: NameNode(value: 'String'),
          isNonNull: false,
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
                    name: NameNode(value: 'ip'),
                    value: VariableNode(name: NameNode(value: 'ip')),
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
Mutation$UpdateServerIp _parserFn$Mutation$UpdateServerIp(
        Map<String, dynamic> data) =>
    Mutation$UpdateServerIp.fromJson(data);
typedef OnMutationCompleted$Mutation$UpdateServerIp = FutureOr<void> Function(
  Map<String, dynamic>?,
  Mutation$UpdateServerIp?,
);

class Options$Mutation$UpdateServerIp
    extends graphql.MutationOptions<Mutation$UpdateServerIp> {
  Options$Mutation$UpdateServerIp({
    String? operationName,
    Variables$Mutation$UpdateServerIp? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateServerIp? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateServerIp? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateServerIp>? update,
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
                        : _parserFn$Mutation$UpdateServerIp(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateServerIp,
          parserFn: _parserFn$Mutation$UpdateServerIp,
        );

  final OnMutationCompleted$Mutation$UpdateServerIp? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$UpdateServerIp
    extends graphql.WatchQueryOptions<Mutation$UpdateServerIp> {
  WatchOptions$Mutation$UpdateServerIp({
    String? operationName,
    Variables$Mutation$UpdateServerIp? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateServerIp? typedOptimisticResult,
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
          document: documentNodeMutationUpdateServerIp,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$UpdateServerIp,
        );
}

extension ClientExtension$Mutation$UpdateServerIp on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$UpdateServerIp>> mutate$UpdateServerIp(
          [Options$Mutation$UpdateServerIp? options]) async =>
      await this.mutate(options ?? Options$Mutation$UpdateServerIp());

  graphql.ObservableQuery<Mutation$UpdateServerIp> watchMutation$UpdateServerIp(
          [WatchOptions$Mutation$UpdateServerIp? options]) =>
      this.watchMutation(options ?? WatchOptions$Mutation$UpdateServerIp());
}

class Mutation$UpdateServerIp$HookResult {
  Mutation$UpdateServerIp$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$UpdateServerIp runMutation;

  final graphql.QueryResult<Mutation$UpdateServerIp> result;
}

Mutation$UpdateServerIp$HookResult useMutation$UpdateServerIp(
    [WidgetOptions$Mutation$UpdateServerIp? options]) {
  final result = graphql_flutter
      .useMutation(options ?? WidgetOptions$Mutation$UpdateServerIp());
  return Mutation$UpdateServerIp$HookResult(
    ({variables, optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables?.toJson() ?? const {},
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$UpdateServerIp>
    useWatchMutation$UpdateServerIp(
            [WatchOptions$Mutation$UpdateServerIp? options]) =>
        graphql_flutter.useWatchMutation(
            options ?? WatchOptions$Mutation$UpdateServerIp());

class WidgetOptions$Mutation$UpdateServerIp
    extends graphql.MutationOptions<Mutation$UpdateServerIp> {
  WidgetOptions$Mutation$UpdateServerIp({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateServerIp? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateServerIp? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateServerIp>? update,
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
                        : _parserFn$Mutation$UpdateServerIp(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateServerIp,
          parserFn: _parserFn$Mutation$UpdateServerIp,
        );

  final OnMutationCompleted$Mutation$UpdateServerIp? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$UpdateServerIp
    = graphql.MultiSourceResult<Mutation$UpdateServerIp> Function({
  Variables$Mutation$UpdateServerIp? variables,
  Object? optimisticResult,
  Mutation$UpdateServerIp? typedOptimisticResult,
});
typedef Builder$Mutation$UpdateServerIp = widgets.Widget Function(
  RunMutation$Mutation$UpdateServerIp,
  graphql.QueryResult<Mutation$UpdateServerIp>?,
);

class Mutation$UpdateServerIp$Widget
    extends graphql_flutter.Mutation<Mutation$UpdateServerIp> {
  Mutation$UpdateServerIp$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$UpdateServerIp? options,
    required Builder$Mutation$UpdateServerIp builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$UpdateServerIp(),
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

class Mutation$UpdateServerIp$setSettings {
  Mutation$UpdateServerIp$setSettings({
    required this.settings,
    this.$__typename = 'SetSettingsPayload',
  });

  factory Mutation$UpdateServerIp$setSettings.fromJson(
      Map<String, dynamic> json) {
    final l$settings = json['settings'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateServerIp$setSettings(
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
    if (other is! Mutation$UpdateServerIp$setSettings ||
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

extension UtilityExtension$Mutation$UpdateServerIp$setSettings
    on Mutation$UpdateServerIp$setSettings {
  CopyWith$Mutation$UpdateServerIp$setSettings<
          Mutation$UpdateServerIp$setSettings>
      get copyWith => CopyWith$Mutation$UpdateServerIp$setSettings(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdateServerIp$setSettings<TRes> {
  factory CopyWith$Mutation$UpdateServerIp$setSettings(
    Mutation$UpdateServerIp$setSettings instance,
    TRes Function(Mutation$UpdateServerIp$setSettings) then,
  ) = _CopyWithImpl$Mutation$UpdateServerIp$setSettings;

  factory CopyWith$Mutation$UpdateServerIp$setSettings.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateServerIp$setSettings;

  TRes call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  });
  CopyWith$Fragment$SettingsDto<TRes> get settings;
}

class _CopyWithImpl$Mutation$UpdateServerIp$setSettings<TRes>
    implements CopyWith$Mutation$UpdateServerIp$setSettings<TRes> {
  _CopyWithImpl$Mutation$UpdateServerIp$setSettings(
    this._instance,
    this._then,
  );

  final Mutation$UpdateServerIp$setSettings _instance;

  final TRes Function(Mutation$UpdateServerIp$setSettings) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? settings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateServerIp$setSettings(
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

class _CopyWithStubImpl$Mutation$UpdateServerIp$setSettings<TRes>
    implements CopyWith$Mutation$UpdateServerIp$setSettings<TRes> {
  _CopyWithStubImpl$Mutation$UpdateServerIp$setSettings(this._res);

  TRes _res;

  call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$SettingsDto<TRes> get settings =>
      CopyWith$Fragment$SettingsDto.stub(_res);
}

class Variables$Mutation$UpdatePort {
  factory Variables$Mutation$UpdatePort({int? port}) =>
      Variables$Mutation$UpdatePort._({
        if (port != null) r'port': port,
      });

  Variables$Mutation$UpdatePort._(this._$data);

  factory Variables$Mutation$UpdatePort.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('port')) {
      final l$port = data['port'];
      result$data['port'] = (l$port as int?);
    }
    return Variables$Mutation$UpdatePort._(result$data);
  }

  Map<String, dynamic> _$data;

  int? get port => (_$data['port'] as int?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('port')) {
      final l$port = port;
      result$data['port'] = l$port;
    }
    return result$data;
  }

  CopyWith$Variables$Mutation$UpdatePort<Variables$Mutation$UpdatePort>
      get copyWith => CopyWith$Variables$Mutation$UpdatePort(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$UpdatePort ||
        runtimeType != other.runtimeType) {
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
    return true;
  }

  @override
  int get hashCode {
    final l$port = port;
    return Object.hashAll([_$data.containsKey('port') ? l$port : const {}]);
  }
}

abstract class CopyWith$Variables$Mutation$UpdatePort<TRes> {
  factory CopyWith$Variables$Mutation$UpdatePort(
    Variables$Mutation$UpdatePort instance,
    TRes Function(Variables$Mutation$UpdatePort) then,
  ) = _CopyWithImpl$Variables$Mutation$UpdatePort;

  factory CopyWith$Variables$Mutation$UpdatePort.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$UpdatePort;

  TRes call({int? port});
}

class _CopyWithImpl$Variables$Mutation$UpdatePort<TRes>
    implements CopyWith$Variables$Mutation$UpdatePort<TRes> {
  _CopyWithImpl$Variables$Mutation$UpdatePort(
    this._instance,
    this._then,
  );

  final Variables$Mutation$UpdatePort _instance;

  final TRes Function(Variables$Mutation$UpdatePort) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? port = _undefined}) =>
      _then(Variables$Mutation$UpdatePort._({
        ..._instance._$data,
        if (port != _undefined) 'port': (port as int?),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$UpdatePort<TRes>
    implements CopyWith$Variables$Mutation$UpdatePort<TRes> {
  _CopyWithStubImpl$Variables$Mutation$UpdatePort(this._res);

  TRes _res;

  call({int? port}) => _res;
}

class Mutation$UpdatePort {
  Mutation$UpdatePort({
    required this.setSettings,
    this.$__typename = 'Mutation',
  });

  factory Mutation$UpdatePort.fromJson(Map<String, dynamic> json) {
    final l$setSettings = json['setSettings'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdatePort(
      setSettings: Mutation$UpdatePort$setSettings.fromJson(
          (l$setSettings as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$UpdatePort$setSettings setSettings;

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
    if (other is! Mutation$UpdatePort || runtimeType != other.runtimeType) {
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

extension UtilityExtension$Mutation$UpdatePort on Mutation$UpdatePort {
  CopyWith$Mutation$UpdatePort<Mutation$UpdatePort> get copyWith =>
      CopyWith$Mutation$UpdatePort(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Mutation$UpdatePort<TRes> {
  factory CopyWith$Mutation$UpdatePort(
    Mutation$UpdatePort instance,
    TRes Function(Mutation$UpdatePort) then,
  ) = _CopyWithImpl$Mutation$UpdatePort;

  factory CopyWith$Mutation$UpdatePort.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdatePort;

  TRes call({
    Mutation$UpdatePort$setSettings? setSettings,
    String? $__typename,
  });
  CopyWith$Mutation$UpdatePort$setSettings<TRes> get setSettings;
}

class _CopyWithImpl$Mutation$UpdatePort<TRes>
    implements CopyWith$Mutation$UpdatePort<TRes> {
  _CopyWithImpl$Mutation$UpdatePort(
    this._instance,
    this._then,
  );

  final Mutation$UpdatePort _instance;

  final TRes Function(Mutation$UpdatePort) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? setSettings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdatePort(
        setSettings: setSettings == _undefined || setSettings == null
            ? _instance.setSettings
            : (setSettings as Mutation$UpdatePort$setSettings),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$UpdatePort$setSettings<TRes> get setSettings {
    final local$setSettings = _instance.setSettings;
    return CopyWith$Mutation$UpdatePort$setSettings(
        local$setSettings, (e) => call(setSettings: e));
  }
}

class _CopyWithStubImpl$Mutation$UpdatePort<TRes>
    implements CopyWith$Mutation$UpdatePort<TRes> {
  _CopyWithStubImpl$Mutation$UpdatePort(this._res);

  TRes _res;

  call({
    Mutation$UpdatePort$setSettings? setSettings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$UpdatePort$setSettings<TRes> get setSettings =>
      CopyWith$Mutation$UpdatePort$setSettings.stub(_res);
}

const documentNodeMutationUpdatePort = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'UpdatePort'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'port')),
        type: NamedTypeNode(
          name: NameNode(value: 'Int'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: IntValueNode(value: '4567')),
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
                    name: NameNode(value: 'port'),
                    value: VariableNode(name: NameNode(value: 'port')),
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
Mutation$UpdatePort _parserFn$Mutation$UpdatePort(Map<String, dynamic> data) =>
    Mutation$UpdatePort.fromJson(data);
typedef OnMutationCompleted$Mutation$UpdatePort = FutureOr<void> Function(
  Map<String, dynamic>?,
  Mutation$UpdatePort?,
);

class Options$Mutation$UpdatePort
    extends graphql.MutationOptions<Mutation$UpdatePort> {
  Options$Mutation$UpdatePort({
    String? operationName,
    Variables$Mutation$UpdatePort? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdatePort? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdatePort? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdatePort>? update,
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
                    data == null ? null : _parserFn$Mutation$UpdatePort(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdatePort,
          parserFn: _parserFn$Mutation$UpdatePort,
        );

  final OnMutationCompleted$Mutation$UpdatePort? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$UpdatePort
    extends graphql.WatchQueryOptions<Mutation$UpdatePort> {
  WatchOptions$Mutation$UpdatePort({
    String? operationName,
    Variables$Mutation$UpdatePort? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdatePort? typedOptimisticResult,
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
          document: documentNodeMutationUpdatePort,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$UpdatePort,
        );
}

extension ClientExtension$Mutation$UpdatePort on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$UpdatePort>> mutate$UpdatePort(
          [Options$Mutation$UpdatePort? options]) async =>
      await this.mutate(options ?? Options$Mutation$UpdatePort());

  graphql.ObservableQuery<Mutation$UpdatePort> watchMutation$UpdatePort(
          [WatchOptions$Mutation$UpdatePort? options]) =>
      this.watchMutation(options ?? WatchOptions$Mutation$UpdatePort());
}

class Mutation$UpdatePort$HookResult {
  Mutation$UpdatePort$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$UpdatePort runMutation;

  final graphql.QueryResult<Mutation$UpdatePort> result;
}

Mutation$UpdatePort$HookResult useMutation$UpdatePort(
    [WidgetOptions$Mutation$UpdatePort? options]) {
  final result = graphql_flutter
      .useMutation(options ?? WidgetOptions$Mutation$UpdatePort());
  return Mutation$UpdatePort$HookResult(
    ({variables, optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables?.toJson() ?? const {},
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$UpdatePort> useWatchMutation$UpdatePort(
        [WatchOptions$Mutation$UpdatePort? options]) =>
    graphql_flutter
        .useWatchMutation(options ?? WatchOptions$Mutation$UpdatePort());

class WidgetOptions$Mutation$UpdatePort
    extends graphql.MutationOptions<Mutation$UpdatePort> {
  WidgetOptions$Mutation$UpdatePort({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdatePort? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdatePort? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdatePort>? update,
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
                    data == null ? null : _parserFn$Mutation$UpdatePort(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdatePort,
          parserFn: _parserFn$Mutation$UpdatePort,
        );

  final OnMutationCompleted$Mutation$UpdatePort? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$UpdatePort
    = graphql.MultiSourceResult<Mutation$UpdatePort> Function({
  Variables$Mutation$UpdatePort? variables,
  Object? optimisticResult,
  Mutation$UpdatePort? typedOptimisticResult,
});
typedef Builder$Mutation$UpdatePort = widgets.Widget Function(
  RunMutation$Mutation$UpdatePort,
  graphql.QueryResult<Mutation$UpdatePort>?,
);

class Mutation$UpdatePort$Widget
    extends graphql_flutter.Mutation<Mutation$UpdatePort> {
  Mutation$UpdatePort$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$UpdatePort? options,
    required Builder$Mutation$UpdatePort builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$UpdatePort(),
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

class Mutation$UpdatePort$setSettings {
  Mutation$UpdatePort$setSettings({
    required this.settings,
    this.$__typename = 'SetSettingsPayload',
  });

  factory Mutation$UpdatePort$setSettings.fromJson(Map<String, dynamic> json) {
    final l$settings = json['settings'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdatePort$setSettings(
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
    if (other is! Mutation$UpdatePort$setSettings ||
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

extension UtilityExtension$Mutation$UpdatePort$setSettings
    on Mutation$UpdatePort$setSettings {
  CopyWith$Mutation$UpdatePort$setSettings<Mutation$UpdatePort$setSettings>
      get copyWith => CopyWith$Mutation$UpdatePort$setSettings(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdatePort$setSettings<TRes> {
  factory CopyWith$Mutation$UpdatePort$setSettings(
    Mutation$UpdatePort$setSettings instance,
    TRes Function(Mutation$UpdatePort$setSettings) then,
  ) = _CopyWithImpl$Mutation$UpdatePort$setSettings;

  factory CopyWith$Mutation$UpdatePort$setSettings.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdatePort$setSettings;

  TRes call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  });
  CopyWith$Fragment$SettingsDto<TRes> get settings;
}

class _CopyWithImpl$Mutation$UpdatePort$setSettings<TRes>
    implements CopyWith$Mutation$UpdatePort$setSettings<TRes> {
  _CopyWithImpl$Mutation$UpdatePort$setSettings(
    this._instance,
    this._then,
  );

  final Mutation$UpdatePort$setSettings _instance;

  final TRes Function(Mutation$UpdatePort$setSettings) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? settings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdatePort$setSettings(
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

class _CopyWithStubImpl$Mutation$UpdatePort$setSettings<TRes>
    implements CopyWith$Mutation$UpdatePort$setSettings<TRes> {
  _CopyWithStubImpl$Mutation$UpdatePort$setSettings(this._res);

  TRes _res;

  call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$SettingsDto<TRes> get settings =>
      CopyWith$Fragment$SettingsDto.stub(_res);
}

class Variables$Mutation$UpdateFlareSolverrUrl {
  factory Variables$Mutation$UpdateFlareSolverrUrl(
          {required String flareSolverrUrl}) =>
      Variables$Mutation$UpdateFlareSolverrUrl._({
        r'flareSolverrUrl': flareSolverrUrl,
      });

  Variables$Mutation$UpdateFlareSolverrUrl._(this._$data);

  factory Variables$Mutation$UpdateFlareSolverrUrl.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$flareSolverrUrl = data['flareSolverrUrl'];
    result$data['flareSolverrUrl'] = (l$flareSolverrUrl as String);
    return Variables$Mutation$UpdateFlareSolverrUrl._(result$data);
  }

  Map<String, dynamic> _$data;

  String get flareSolverrUrl => (_$data['flareSolverrUrl'] as String);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$flareSolverrUrl = flareSolverrUrl;
    result$data['flareSolverrUrl'] = l$flareSolverrUrl;
    return result$data;
  }

  CopyWith$Variables$Mutation$UpdateFlareSolverrUrl<
          Variables$Mutation$UpdateFlareSolverrUrl>
      get copyWith => CopyWith$Variables$Mutation$UpdateFlareSolverrUrl(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$UpdateFlareSolverrUrl ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$flareSolverrUrl = flareSolverrUrl;
    final lOther$flareSolverrUrl = other.flareSolverrUrl;
    if (l$flareSolverrUrl != lOther$flareSolverrUrl) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$flareSolverrUrl = flareSolverrUrl;
    return Object.hashAll([l$flareSolverrUrl]);
  }
}

abstract class CopyWith$Variables$Mutation$UpdateFlareSolverrUrl<TRes> {
  factory CopyWith$Variables$Mutation$UpdateFlareSolverrUrl(
    Variables$Mutation$UpdateFlareSolverrUrl instance,
    TRes Function(Variables$Mutation$UpdateFlareSolverrUrl) then,
  ) = _CopyWithImpl$Variables$Mutation$UpdateFlareSolverrUrl;

  factory CopyWith$Variables$Mutation$UpdateFlareSolverrUrl.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$UpdateFlareSolverrUrl;

  TRes call({String? flareSolverrUrl});
}

class _CopyWithImpl$Variables$Mutation$UpdateFlareSolverrUrl<TRes>
    implements CopyWith$Variables$Mutation$UpdateFlareSolverrUrl<TRes> {
  _CopyWithImpl$Variables$Mutation$UpdateFlareSolverrUrl(
    this._instance,
    this._then,
  );

  final Variables$Mutation$UpdateFlareSolverrUrl _instance;

  final TRes Function(Variables$Mutation$UpdateFlareSolverrUrl) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? flareSolverrUrl = _undefined}) =>
      _then(Variables$Mutation$UpdateFlareSolverrUrl._({
        ..._instance._$data,
        if (flareSolverrUrl != _undefined && flareSolverrUrl != null)
          'flareSolverrUrl': (flareSolverrUrl as String),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$UpdateFlareSolverrUrl<TRes>
    implements CopyWith$Variables$Mutation$UpdateFlareSolverrUrl<TRes> {
  _CopyWithStubImpl$Variables$Mutation$UpdateFlareSolverrUrl(this._res);

  TRes _res;

  call({String? flareSolverrUrl}) => _res;
}

class Mutation$UpdateFlareSolverrUrl {
  Mutation$UpdateFlareSolverrUrl({
    required this.setSettings,
    this.$__typename = 'Mutation',
  });

  factory Mutation$UpdateFlareSolverrUrl.fromJson(Map<String, dynamic> json) {
    final l$setSettings = json['setSettings'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateFlareSolverrUrl(
      setSettings: Mutation$UpdateFlareSolverrUrl$setSettings.fromJson(
          (l$setSettings as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$UpdateFlareSolverrUrl$setSettings setSettings;

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
    if (other is! Mutation$UpdateFlareSolverrUrl ||
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

extension UtilityExtension$Mutation$UpdateFlareSolverrUrl
    on Mutation$UpdateFlareSolverrUrl {
  CopyWith$Mutation$UpdateFlareSolverrUrl<Mutation$UpdateFlareSolverrUrl>
      get copyWith => CopyWith$Mutation$UpdateFlareSolverrUrl(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdateFlareSolverrUrl<TRes> {
  factory CopyWith$Mutation$UpdateFlareSolverrUrl(
    Mutation$UpdateFlareSolverrUrl instance,
    TRes Function(Mutation$UpdateFlareSolverrUrl) then,
  ) = _CopyWithImpl$Mutation$UpdateFlareSolverrUrl;

  factory CopyWith$Mutation$UpdateFlareSolverrUrl.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateFlareSolverrUrl;

  TRes call({
    Mutation$UpdateFlareSolverrUrl$setSettings? setSettings,
    String? $__typename,
  });
  CopyWith$Mutation$UpdateFlareSolverrUrl$setSettings<TRes> get setSettings;
}

class _CopyWithImpl$Mutation$UpdateFlareSolverrUrl<TRes>
    implements CopyWith$Mutation$UpdateFlareSolverrUrl<TRes> {
  _CopyWithImpl$Mutation$UpdateFlareSolverrUrl(
    this._instance,
    this._then,
  );

  final Mutation$UpdateFlareSolverrUrl _instance;

  final TRes Function(Mutation$UpdateFlareSolverrUrl) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? setSettings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateFlareSolverrUrl(
        setSettings: setSettings == _undefined || setSettings == null
            ? _instance.setSettings
            : (setSettings as Mutation$UpdateFlareSolverrUrl$setSettings),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$UpdateFlareSolverrUrl$setSettings<TRes> get setSettings {
    final local$setSettings = _instance.setSettings;
    return CopyWith$Mutation$UpdateFlareSolverrUrl$setSettings(
        local$setSettings, (e) => call(setSettings: e));
  }
}

class _CopyWithStubImpl$Mutation$UpdateFlareSolverrUrl<TRes>
    implements CopyWith$Mutation$UpdateFlareSolverrUrl<TRes> {
  _CopyWithStubImpl$Mutation$UpdateFlareSolverrUrl(this._res);

  TRes _res;

  call({
    Mutation$UpdateFlareSolverrUrl$setSettings? setSettings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$UpdateFlareSolverrUrl$setSettings<TRes> get setSettings =>
      CopyWith$Mutation$UpdateFlareSolverrUrl$setSettings.stub(_res);
}

const documentNodeMutationUpdateFlareSolverrUrl = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'UpdateFlareSolverrUrl'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'flareSolverrUrl')),
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
                    name: NameNode(value: 'flareSolverrUrl'),
                    value:
                        VariableNode(name: NameNode(value: 'flareSolverrUrl')),
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
Mutation$UpdateFlareSolverrUrl _parserFn$Mutation$UpdateFlareSolverrUrl(
        Map<String, dynamic> data) =>
    Mutation$UpdateFlareSolverrUrl.fromJson(data);
typedef OnMutationCompleted$Mutation$UpdateFlareSolverrUrl = FutureOr<void>
    Function(
  Map<String, dynamic>?,
  Mutation$UpdateFlareSolverrUrl?,
);

class Options$Mutation$UpdateFlareSolverrUrl
    extends graphql.MutationOptions<Mutation$UpdateFlareSolverrUrl> {
  Options$Mutation$UpdateFlareSolverrUrl({
    String? operationName,
    required Variables$Mutation$UpdateFlareSolverrUrl variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateFlareSolverrUrl? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateFlareSolverrUrl? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateFlareSolverrUrl>? update,
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
                        : _parserFn$Mutation$UpdateFlareSolverrUrl(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateFlareSolverrUrl,
          parserFn: _parserFn$Mutation$UpdateFlareSolverrUrl,
        );

  final OnMutationCompleted$Mutation$UpdateFlareSolverrUrl?
      onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$UpdateFlareSolverrUrl
    extends graphql.WatchQueryOptions<Mutation$UpdateFlareSolverrUrl> {
  WatchOptions$Mutation$UpdateFlareSolverrUrl({
    String? operationName,
    required Variables$Mutation$UpdateFlareSolverrUrl variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateFlareSolverrUrl? typedOptimisticResult,
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
          document: documentNodeMutationUpdateFlareSolverrUrl,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$UpdateFlareSolverrUrl,
        );
}

extension ClientExtension$Mutation$UpdateFlareSolverrUrl
    on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$UpdateFlareSolverrUrl>>
      mutate$UpdateFlareSolverrUrl(
              Options$Mutation$UpdateFlareSolverrUrl options) async =>
          await this.mutate(options);

  graphql.ObservableQuery<Mutation$UpdateFlareSolverrUrl>
      watchMutation$UpdateFlareSolverrUrl(
              WatchOptions$Mutation$UpdateFlareSolverrUrl options) =>
          this.watchMutation(options);
}

class Mutation$UpdateFlareSolverrUrl$HookResult {
  Mutation$UpdateFlareSolverrUrl$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$UpdateFlareSolverrUrl runMutation;

  final graphql.QueryResult<Mutation$UpdateFlareSolverrUrl> result;
}

Mutation$UpdateFlareSolverrUrl$HookResult useMutation$UpdateFlareSolverrUrl(
    [WidgetOptions$Mutation$UpdateFlareSolverrUrl? options]) {
  final result = graphql_flutter
      .useMutation(options ?? WidgetOptions$Mutation$UpdateFlareSolverrUrl());
  return Mutation$UpdateFlareSolverrUrl$HookResult(
    (variables, {optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables.toJson(),
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$UpdateFlareSolverrUrl>
    useWatchMutation$UpdateFlareSolverrUrl(
            WatchOptions$Mutation$UpdateFlareSolverrUrl options) =>
        graphql_flutter.useWatchMutation(options);

class WidgetOptions$Mutation$UpdateFlareSolverrUrl
    extends graphql.MutationOptions<Mutation$UpdateFlareSolverrUrl> {
  WidgetOptions$Mutation$UpdateFlareSolverrUrl({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateFlareSolverrUrl? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateFlareSolverrUrl? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateFlareSolverrUrl>? update,
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
                        : _parserFn$Mutation$UpdateFlareSolverrUrl(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateFlareSolverrUrl,
          parserFn: _parserFn$Mutation$UpdateFlareSolverrUrl,
        );

  final OnMutationCompleted$Mutation$UpdateFlareSolverrUrl?
      onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$UpdateFlareSolverrUrl
    = graphql.MultiSourceResult<Mutation$UpdateFlareSolverrUrl> Function(
  Variables$Mutation$UpdateFlareSolverrUrl, {
  Object? optimisticResult,
  Mutation$UpdateFlareSolverrUrl? typedOptimisticResult,
});
typedef Builder$Mutation$UpdateFlareSolverrUrl = widgets.Widget Function(
  RunMutation$Mutation$UpdateFlareSolverrUrl,
  graphql.QueryResult<Mutation$UpdateFlareSolverrUrl>?,
);

class Mutation$UpdateFlareSolverrUrl$Widget
    extends graphql_flutter.Mutation<Mutation$UpdateFlareSolverrUrl> {
  Mutation$UpdateFlareSolverrUrl$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$UpdateFlareSolverrUrl? options,
    required Builder$Mutation$UpdateFlareSolverrUrl builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$UpdateFlareSolverrUrl(),
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

class Mutation$UpdateFlareSolverrUrl$setSettings {
  Mutation$UpdateFlareSolverrUrl$setSettings({
    required this.settings,
    this.$__typename = 'SetSettingsPayload',
  });

  factory Mutation$UpdateFlareSolverrUrl$setSettings.fromJson(
      Map<String, dynamic> json) {
    final l$settings = json['settings'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateFlareSolverrUrl$setSettings(
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
    if (other is! Mutation$UpdateFlareSolverrUrl$setSettings ||
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

extension UtilityExtension$Mutation$UpdateFlareSolverrUrl$setSettings
    on Mutation$UpdateFlareSolverrUrl$setSettings {
  CopyWith$Mutation$UpdateFlareSolverrUrl$setSettings<
          Mutation$UpdateFlareSolverrUrl$setSettings>
      get copyWith => CopyWith$Mutation$UpdateFlareSolverrUrl$setSettings(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdateFlareSolverrUrl$setSettings<TRes> {
  factory CopyWith$Mutation$UpdateFlareSolverrUrl$setSettings(
    Mutation$UpdateFlareSolverrUrl$setSettings instance,
    TRes Function(Mutation$UpdateFlareSolverrUrl$setSettings) then,
  ) = _CopyWithImpl$Mutation$UpdateFlareSolverrUrl$setSettings;

  factory CopyWith$Mutation$UpdateFlareSolverrUrl$setSettings.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateFlareSolverrUrl$setSettings;

  TRes call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  });
  CopyWith$Fragment$SettingsDto<TRes> get settings;
}

class _CopyWithImpl$Mutation$UpdateFlareSolverrUrl$setSettings<TRes>
    implements CopyWith$Mutation$UpdateFlareSolverrUrl$setSettings<TRes> {
  _CopyWithImpl$Mutation$UpdateFlareSolverrUrl$setSettings(
    this._instance,
    this._then,
  );

  final Mutation$UpdateFlareSolverrUrl$setSettings _instance;

  final TRes Function(Mutation$UpdateFlareSolverrUrl$setSettings) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? settings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateFlareSolverrUrl$setSettings(
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

class _CopyWithStubImpl$Mutation$UpdateFlareSolverrUrl$setSettings<TRes>
    implements CopyWith$Mutation$UpdateFlareSolverrUrl$setSettings<TRes> {
  _CopyWithStubImpl$Mutation$UpdateFlareSolverrUrl$setSettings(this._res);

  TRes _res;

  call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$SettingsDto<TRes> get settings =>
      CopyWith$Fragment$SettingsDto.stub(_res);
}

class Variables$Mutation$UpdateFlareSolverrTimeout {
  factory Variables$Mutation$UpdateFlareSolverrTimeout(
          {int? flareSolverrTimeout}) =>
      Variables$Mutation$UpdateFlareSolverrTimeout._({
        if (flareSolverrTimeout != null)
          r'flareSolverrTimeout': flareSolverrTimeout,
      });

  Variables$Mutation$UpdateFlareSolverrTimeout._(this._$data);

  factory Variables$Mutation$UpdateFlareSolverrTimeout.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('flareSolverrTimeout')) {
      final l$flareSolverrTimeout = data['flareSolverrTimeout'];
      result$data['flareSolverrTimeout'] = (l$flareSolverrTimeout as int?);
    }
    return Variables$Mutation$UpdateFlareSolverrTimeout._(result$data);
  }

  Map<String, dynamic> _$data;

  int? get flareSolverrTimeout => (_$data['flareSolverrTimeout'] as int?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('flareSolverrTimeout')) {
      final l$flareSolverrTimeout = flareSolverrTimeout;
      result$data['flareSolverrTimeout'] = l$flareSolverrTimeout;
    }
    return result$data;
  }

  CopyWith$Variables$Mutation$UpdateFlareSolverrTimeout<
          Variables$Mutation$UpdateFlareSolverrTimeout>
      get copyWith => CopyWith$Variables$Mutation$UpdateFlareSolverrTimeout(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$UpdateFlareSolverrTimeout ||
        runtimeType != other.runtimeType) {
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
    return true;
  }

  @override
  int get hashCode {
    final l$flareSolverrTimeout = flareSolverrTimeout;
    return Object.hashAll([
      _$data.containsKey('flareSolverrTimeout')
          ? l$flareSolverrTimeout
          : const {}
    ]);
  }
}

abstract class CopyWith$Variables$Mutation$UpdateFlareSolverrTimeout<TRes> {
  factory CopyWith$Variables$Mutation$UpdateFlareSolverrTimeout(
    Variables$Mutation$UpdateFlareSolverrTimeout instance,
    TRes Function(Variables$Mutation$UpdateFlareSolverrTimeout) then,
  ) = _CopyWithImpl$Variables$Mutation$UpdateFlareSolverrTimeout;

  factory CopyWith$Variables$Mutation$UpdateFlareSolverrTimeout.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$UpdateFlareSolverrTimeout;

  TRes call({int? flareSolverrTimeout});
}

class _CopyWithImpl$Variables$Mutation$UpdateFlareSolverrTimeout<TRes>
    implements CopyWith$Variables$Mutation$UpdateFlareSolverrTimeout<TRes> {
  _CopyWithImpl$Variables$Mutation$UpdateFlareSolverrTimeout(
    this._instance,
    this._then,
  );

  final Variables$Mutation$UpdateFlareSolverrTimeout _instance;

  final TRes Function(Variables$Mutation$UpdateFlareSolverrTimeout) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? flareSolverrTimeout = _undefined}) =>
      _then(Variables$Mutation$UpdateFlareSolverrTimeout._({
        ..._instance._$data,
        if (flareSolverrTimeout != _undefined)
          'flareSolverrTimeout': (flareSolverrTimeout as int?),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$UpdateFlareSolverrTimeout<TRes>
    implements CopyWith$Variables$Mutation$UpdateFlareSolverrTimeout<TRes> {
  _CopyWithStubImpl$Variables$Mutation$UpdateFlareSolverrTimeout(this._res);

  TRes _res;

  call({int? flareSolverrTimeout}) => _res;
}

class Mutation$UpdateFlareSolverrTimeout {
  Mutation$UpdateFlareSolverrTimeout({
    required this.setSettings,
    this.$__typename = 'Mutation',
  });

  factory Mutation$UpdateFlareSolverrTimeout.fromJson(
      Map<String, dynamic> json) {
    final l$setSettings = json['setSettings'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateFlareSolverrTimeout(
      setSettings: Mutation$UpdateFlareSolverrTimeout$setSettings.fromJson(
          (l$setSettings as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$UpdateFlareSolverrTimeout$setSettings setSettings;

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
    if (other is! Mutation$UpdateFlareSolverrTimeout ||
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

extension UtilityExtension$Mutation$UpdateFlareSolverrTimeout
    on Mutation$UpdateFlareSolverrTimeout {
  CopyWith$Mutation$UpdateFlareSolverrTimeout<
          Mutation$UpdateFlareSolverrTimeout>
      get copyWith => CopyWith$Mutation$UpdateFlareSolverrTimeout(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdateFlareSolverrTimeout<TRes> {
  factory CopyWith$Mutation$UpdateFlareSolverrTimeout(
    Mutation$UpdateFlareSolverrTimeout instance,
    TRes Function(Mutation$UpdateFlareSolverrTimeout) then,
  ) = _CopyWithImpl$Mutation$UpdateFlareSolverrTimeout;

  factory CopyWith$Mutation$UpdateFlareSolverrTimeout.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateFlareSolverrTimeout;

  TRes call({
    Mutation$UpdateFlareSolverrTimeout$setSettings? setSettings,
    String? $__typename,
  });
  CopyWith$Mutation$UpdateFlareSolverrTimeout$setSettings<TRes> get setSettings;
}

class _CopyWithImpl$Mutation$UpdateFlareSolverrTimeout<TRes>
    implements CopyWith$Mutation$UpdateFlareSolverrTimeout<TRes> {
  _CopyWithImpl$Mutation$UpdateFlareSolverrTimeout(
    this._instance,
    this._then,
  );

  final Mutation$UpdateFlareSolverrTimeout _instance;

  final TRes Function(Mutation$UpdateFlareSolverrTimeout) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? setSettings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateFlareSolverrTimeout(
        setSettings: setSettings == _undefined || setSettings == null
            ? _instance.setSettings
            : (setSettings as Mutation$UpdateFlareSolverrTimeout$setSettings),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$UpdateFlareSolverrTimeout$setSettings<TRes>
      get setSettings {
    final local$setSettings = _instance.setSettings;
    return CopyWith$Mutation$UpdateFlareSolverrTimeout$setSettings(
        local$setSettings, (e) => call(setSettings: e));
  }
}

class _CopyWithStubImpl$Mutation$UpdateFlareSolverrTimeout<TRes>
    implements CopyWith$Mutation$UpdateFlareSolverrTimeout<TRes> {
  _CopyWithStubImpl$Mutation$UpdateFlareSolverrTimeout(this._res);

  TRes _res;

  call({
    Mutation$UpdateFlareSolverrTimeout$setSettings? setSettings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$UpdateFlareSolverrTimeout$setSettings<TRes>
      get setSettings =>
          CopyWith$Mutation$UpdateFlareSolverrTimeout$setSettings.stub(_res);
}

const documentNodeMutationUpdateFlareSolverrTimeout =
    DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'UpdateFlareSolverrTimeout'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'flareSolverrTimeout')),
        type: NamedTypeNode(
          name: NameNode(value: 'Int'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: IntValueNode(value: '10')),
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
                    name: NameNode(value: 'flareSolverrTimeout'),
                    value: VariableNode(
                        name: NameNode(value: 'flareSolverrTimeout')),
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
Mutation$UpdateFlareSolverrTimeout _parserFn$Mutation$UpdateFlareSolverrTimeout(
        Map<String, dynamic> data) =>
    Mutation$UpdateFlareSolverrTimeout.fromJson(data);
typedef OnMutationCompleted$Mutation$UpdateFlareSolverrTimeout = FutureOr<void>
    Function(
  Map<String, dynamic>?,
  Mutation$UpdateFlareSolverrTimeout?,
);

class Options$Mutation$UpdateFlareSolverrTimeout
    extends graphql.MutationOptions<Mutation$UpdateFlareSolverrTimeout> {
  Options$Mutation$UpdateFlareSolverrTimeout({
    String? operationName,
    Variables$Mutation$UpdateFlareSolverrTimeout? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateFlareSolverrTimeout? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateFlareSolverrTimeout? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateFlareSolverrTimeout>? update,
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
                        : _parserFn$Mutation$UpdateFlareSolverrTimeout(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateFlareSolverrTimeout,
          parserFn: _parserFn$Mutation$UpdateFlareSolverrTimeout,
        );

  final OnMutationCompleted$Mutation$UpdateFlareSolverrTimeout?
      onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$UpdateFlareSolverrTimeout
    extends graphql.WatchQueryOptions<Mutation$UpdateFlareSolverrTimeout> {
  WatchOptions$Mutation$UpdateFlareSolverrTimeout({
    String? operationName,
    Variables$Mutation$UpdateFlareSolverrTimeout? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateFlareSolverrTimeout? typedOptimisticResult,
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
          document: documentNodeMutationUpdateFlareSolverrTimeout,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$UpdateFlareSolverrTimeout,
        );
}

extension ClientExtension$Mutation$UpdateFlareSolverrTimeout
    on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$UpdateFlareSolverrTimeout>>
      mutate$UpdateFlareSolverrTimeout(
              [Options$Mutation$UpdateFlareSolverrTimeout? options]) async =>
          await this
              .mutate(options ?? Options$Mutation$UpdateFlareSolverrTimeout());

  graphql.ObservableQuery<Mutation$UpdateFlareSolverrTimeout>
      watchMutation$UpdateFlareSolverrTimeout(
              [WatchOptions$Mutation$UpdateFlareSolverrTimeout? options]) =>
          this.watchMutation(
              options ?? WatchOptions$Mutation$UpdateFlareSolverrTimeout());
}

class Mutation$UpdateFlareSolverrTimeout$HookResult {
  Mutation$UpdateFlareSolverrTimeout$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$UpdateFlareSolverrTimeout runMutation;

  final graphql.QueryResult<Mutation$UpdateFlareSolverrTimeout> result;
}

Mutation$UpdateFlareSolverrTimeout$HookResult
    useMutation$UpdateFlareSolverrTimeout(
        [WidgetOptions$Mutation$UpdateFlareSolverrTimeout? options]) {
  final result = graphql_flutter.useMutation(
      options ?? WidgetOptions$Mutation$UpdateFlareSolverrTimeout());
  return Mutation$UpdateFlareSolverrTimeout$HookResult(
    ({variables, optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables?.toJson() ?? const {},
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$UpdateFlareSolverrTimeout>
    useWatchMutation$UpdateFlareSolverrTimeout(
            [WatchOptions$Mutation$UpdateFlareSolverrTimeout? options]) =>
        graphql_flutter.useWatchMutation(
            options ?? WatchOptions$Mutation$UpdateFlareSolverrTimeout());

class WidgetOptions$Mutation$UpdateFlareSolverrTimeout
    extends graphql.MutationOptions<Mutation$UpdateFlareSolverrTimeout> {
  WidgetOptions$Mutation$UpdateFlareSolverrTimeout({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateFlareSolverrTimeout? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateFlareSolverrTimeout? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateFlareSolverrTimeout>? update,
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
                        : _parserFn$Mutation$UpdateFlareSolverrTimeout(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateFlareSolverrTimeout,
          parserFn: _parserFn$Mutation$UpdateFlareSolverrTimeout,
        );

  final OnMutationCompleted$Mutation$UpdateFlareSolverrTimeout?
      onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$UpdateFlareSolverrTimeout
    = graphql.MultiSourceResult<Mutation$UpdateFlareSolverrTimeout> Function({
  Variables$Mutation$UpdateFlareSolverrTimeout? variables,
  Object? optimisticResult,
  Mutation$UpdateFlareSolverrTimeout? typedOptimisticResult,
});
typedef Builder$Mutation$UpdateFlareSolverrTimeout = widgets.Widget Function(
  RunMutation$Mutation$UpdateFlareSolverrTimeout,
  graphql.QueryResult<Mutation$UpdateFlareSolverrTimeout>?,
);

class Mutation$UpdateFlareSolverrTimeout$Widget
    extends graphql_flutter.Mutation<Mutation$UpdateFlareSolverrTimeout> {
  Mutation$UpdateFlareSolverrTimeout$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$UpdateFlareSolverrTimeout? options,
    required Builder$Mutation$UpdateFlareSolverrTimeout builder,
  }) : super(
          key: key,
          options:
              options ?? WidgetOptions$Mutation$UpdateFlareSolverrTimeout(),
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

class Mutation$UpdateFlareSolverrTimeout$setSettings {
  Mutation$UpdateFlareSolverrTimeout$setSettings({
    required this.settings,
    this.$__typename = 'SetSettingsPayload',
  });

  factory Mutation$UpdateFlareSolverrTimeout$setSettings.fromJson(
      Map<String, dynamic> json) {
    final l$settings = json['settings'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateFlareSolverrTimeout$setSettings(
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
    if (other is! Mutation$UpdateFlareSolverrTimeout$setSettings ||
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

extension UtilityExtension$Mutation$UpdateFlareSolverrTimeout$setSettings
    on Mutation$UpdateFlareSolverrTimeout$setSettings {
  CopyWith$Mutation$UpdateFlareSolverrTimeout$setSettings<
          Mutation$UpdateFlareSolverrTimeout$setSettings>
      get copyWith => CopyWith$Mutation$UpdateFlareSolverrTimeout$setSettings(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdateFlareSolverrTimeout$setSettings<TRes> {
  factory CopyWith$Mutation$UpdateFlareSolverrTimeout$setSettings(
    Mutation$UpdateFlareSolverrTimeout$setSettings instance,
    TRes Function(Mutation$UpdateFlareSolverrTimeout$setSettings) then,
  ) = _CopyWithImpl$Mutation$UpdateFlareSolverrTimeout$setSettings;

  factory CopyWith$Mutation$UpdateFlareSolverrTimeout$setSettings.stub(
          TRes res) =
      _CopyWithStubImpl$Mutation$UpdateFlareSolverrTimeout$setSettings;

  TRes call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  });
  CopyWith$Fragment$SettingsDto<TRes> get settings;
}

class _CopyWithImpl$Mutation$UpdateFlareSolverrTimeout$setSettings<TRes>
    implements CopyWith$Mutation$UpdateFlareSolverrTimeout$setSettings<TRes> {
  _CopyWithImpl$Mutation$UpdateFlareSolverrTimeout$setSettings(
    this._instance,
    this._then,
  );

  final Mutation$UpdateFlareSolverrTimeout$setSettings _instance;

  final TRes Function(Mutation$UpdateFlareSolverrTimeout$setSettings) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? settings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateFlareSolverrTimeout$setSettings(
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

class _CopyWithStubImpl$Mutation$UpdateFlareSolverrTimeout$setSettings<TRes>
    implements CopyWith$Mutation$UpdateFlareSolverrTimeout$setSettings<TRes> {
  _CopyWithStubImpl$Mutation$UpdateFlareSolverrTimeout$setSettings(this._res);

  TRes _res;

  call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$SettingsDto<TRes> get settings =>
      CopyWith$Fragment$SettingsDto.stub(_res);
}

class Variables$Mutation$UpdateFlareSolverrSessionTtl {
  factory Variables$Mutation$UpdateFlareSolverrSessionTtl(
          {int? flareSolverrSessionTtl}) =>
      Variables$Mutation$UpdateFlareSolverrSessionTtl._({
        if (flareSolverrSessionTtl != null)
          r'flareSolverrSessionTtl': flareSolverrSessionTtl,
      });

  Variables$Mutation$UpdateFlareSolverrSessionTtl._(this._$data);

  factory Variables$Mutation$UpdateFlareSolverrSessionTtl.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('flareSolverrSessionTtl')) {
      final l$flareSolverrSessionTtl = data['flareSolverrSessionTtl'];
      result$data['flareSolverrSessionTtl'] =
          (l$flareSolverrSessionTtl as int?);
    }
    return Variables$Mutation$UpdateFlareSolverrSessionTtl._(result$data);
  }

  Map<String, dynamic> _$data;

  int? get flareSolverrSessionTtl => (_$data['flareSolverrSessionTtl'] as int?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('flareSolverrSessionTtl')) {
      final l$flareSolverrSessionTtl = flareSolverrSessionTtl;
      result$data['flareSolverrSessionTtl'] = l$flareSolverrSessionTtl;
    }
    return result$data;
  }

  CopyWith$Variables$Mutation$UpdateFlareSolverrSessionTtl<
          Variables$Mutation$UpdateFlareSolverrSessionTtl>
      get copyWith => CopyWith$Variables$Mutation$UpdateFlareSolverrSessionTtl(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$UpdateFlareSolverrSessionTtl ||
        runtimeType != other.runtimeType) {
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
    return true;
  }

  @override
  int get hashCode {
    final l$flareSolverrSessionTtl = flareSolverrSessionTtl;
    return Object.hashAll([
      _$data.containsKey('flareSolverrSessionTtl')
          ? l$flareSolverrSessionTtl
          : const {}
    ]);
  }
}

abstract class CopyWith$Variables$Mutation$UpdateFlareSolverrSessionTtl<TRes> {
  factory CopyWith$Variables$Mutation$UpdateFlareSolverrSessionTtl(
    Variables$Mutation$UpdateFlareSolverrSessionTtl instance,
    TRes Function(Variables$Mutation$UpdateFlareSolverrSessionTtl) then,
  ) = _CopyWithImpl$Variables$Mutation$UpdateFlareSolverrSessionTtl;

  factory CopyWith$Variables$Mutation$UpdateFlareSolverrSessionTtl.stub(
          TRes res) =
      _CopyWithStubImpl$Variables$Mutation$UpdateFlareSolverrSessionTtl;

  TRes call({int? flareSolverrSessionTtl});
}

class _CopyWithImpl$Variables$Mutation$UpdateFlareSolverrSessionTtl<TRes>
    implements CopyWith$Variables$Mutation$UpdateFlareSolverrSessionTtl<TRes> {
  _CopyWithImpl$Variables$Mutation$UpdateFlareSolverrSessionTtl(
    this._instance,
    this._then,
  );

  final Variables$Mutation$UpdateFlareSolverrSessionTtl _instance;

  final TRes Function(Variables$Mutation$UpdateFlareSolverrSessionTtl) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? flareSolverrSessionTtl = _undefined}) =>
      _then(Variables$Mutation$UpdateFlareSolverrSessionTtl._({
        ..._instance._$data,
        if (flareSolverrSessionTtl != _undefined)
          'flareSolverrSessionTtl': (flareSolverrSessionTtl as int?),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$UpdateFlareSolverrSessionTtl<TRes>
    implements CopyWith$Variables$Mutation$UpdateFlareSolverrSessionTtl<TRes> {
  _CopyWithStubImpl$Variables$Mutation$UpdateFlareSolverrSessionTtl(this._res);

  TRes _res;

  call({int? flareSolverrSessionTtl}) => _res;
}

class Mutation$UpdateFlareSolverrSessionTtl {
  Mutation$UpdateFlareSolverrSessionTtl({
    required this.setSettings,
    this.$__typename = 'Mutation',
  });

  factory Mutation$UpdateFlareSolverrSessionTtl.fromJson(
      Map<String, dynamic> json) {
    final l$setSettings = json['setSettings'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateFlareSolverrSessionTtl(
      setSettings: Mutation$UpdateFlareSolverrSessionTtl$setSettings.fromJson(
          (l$setSettings as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$UpdateFlareSolverrSessionTtl$setSettings setSettings;

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
    if (other is! Mutation$UpdateFlareSolverrSessionTtl ||
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

extension UtilityExtension$Mutation$UpdateFlareSolverrSessionTtl
    on Mutation$UpdateFlareSolverrSessionTtl {
  CopyWith$Mutation$UpdateFlareSolverrSessionTtl<
          Mutation$UpdateFlareSolverrSessionTtl>
      get copyWith => CopyWith$Mutation$UpdateFlareSolverrSessionTtl(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdateFlareSolverrSessionTtl<TRes> {
  factory CopyWith$Mutation$UpdateFlareSolverrSessionTtl(
    Mutation$UpdateFlareSolverrSessionTtl instance,
    TRes Function(Mutation$UpdateFlareSolverrSessionTtl) then,
  ) = _CopyWithImpl$Mutation$UpdateFlareSolverrSessionTtl;

  factory CopyWith$Mutation$UpdateFlareSolverrSessionTtl.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateFlareSolverrSessionTtl;

  TRes call({
    Mutation$UpdateFlareSolverrSessionTtl$setSettings? setSettings,
    String? $__typename,
  });
  CopyWith$Mutation$UpdateFlareSolverrSessionTtl$setSettings<TRes>
      get setSettings;
}

class _CopyWithImpl$Mutation$UpdateFlareSolverrSessionTtl<TRes>
    implements CopyWith$Mutation$UpdateFlareSolverrSessionTtl<TRes> {
  _CopyWithImpl$Mutation$UpdateFlareSolverrSessionTtl(
    this._instance,
    this._then,
  );

  final Mutation$UpdateFlareSolverrSessionTtl _instance;

  final TRes Function(Mutation$UpdateFlareSolverrSessionTtl) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? setSettings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateFlareSolverrSessionTtl(
        setSettings: setSettings == _undefined || setSettings == null
            ? _instance.setSettings
            : (setSettings
                as Mutation$UpdateFlareSolverrSessionTtl$setSettings),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$UpdateFlareSolverrSessionTtl$setSettings<TRes>
      get setSettings {
    final local$setSettings = _instance.setSettings;
    return CopyWith$Mutation$UpdateFlareSolverrSessionTtl$setSettings(
        local$setSettings, (e) => call(setSettings: e));
  }
}

class _CopyWithStubImpl$Mutation$UpdateFlareSolverrSessionTtl<TRes>
    implements CopyWith$Mutation$UpdateFlareSolverrSessionTtl<TRes> {
  _CopyWithStubImpl$Mutation$UpdateFlareSolverrSessionTtl(this._res);

  TRes _res;

  call({
    Mutation$UpdateFlareSolverrSessionTtl$setSettings? setSettings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$UpdateFlareSolverrSessionTtl$setSettings<TRes>
      get setSettings =>
          CopyWith$Mutation$UpdateFlareSolverrSessionTtl$setSettings.stub(_res);
}

const documentNodeMutationUpdateFlareSolverrSessionTtl =
    DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'UpdateFlareSolverrSessionTtl'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'flareSolverrSessionTtl')),
        type: NamedTypeNode(
          name: NameNode(value: 'Int'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: IntValueNode(value: '10')),
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
                    name: NameNode(value: 'flareSolverrSessionTtl'),
                    value: VariableNode(
                        name: NameNode(value: 'flareSolverrSessionTtl')),
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
Mutation$UpdateFlareSolverrSessionTtl
    _parserFn$Mutation$UpdateFlareSolverrSessionTtl(
            Map<String, dynamic> data) =>
        Mutation$UpdateFlareSolverrSessionTtl.fromJson(data);
typedef OnMutationCompleted$Mutation$UpdateFlareSolverrSessionTtl
    = FutureOr<void> Function(
  Map<String, dynamic>?,
  Mutation$UpdateFlareSolverrSessionTtl?,
);

class Options$Mutation$UpdateFlareSolverrSessionTtl
    extends graphql.MutationOptions<Mutation$UpdateFlareSolverrSessionTtl> {
  Options$Mutation$UpdateFlareSolverrSessionTtl({
    String? operationName,
    Variables$Mutation$UpdateFlareSolverrSessionTtl? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateFlareSolverrSessionTtl? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateFlareSolverrSessionTtl? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateFlareSolverrSessionTtl>? update,
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
                        : _parserFn$Mutation$UpdateFlareSolverrSessionTtl(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateFlareSolverrSessionTtl,
          parserFn: _parserFn$Mutation$UpdateFlareSolverrSessionTtl,
        );

  final OnMutationCompleted$Mutation$UpdateFlareSolverrSessionTtl?
      onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$UpdateFlareSolverrSessionTtl
    extends graphql.WatchQueryOptions<Mutation$UpdateFlareSolverrSessionTtl> {
  WatchOptions$Mutation$UpdateFlareSolverrSessionTtl({
    String? operationName,
    Variables$Mutation$UpdateFlareSolverrSessionTtl? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateFlareSolverrSessionTtl? typedOptimisticResult,
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
          document: documentNodeMutationUpdateFlareSolverrSessionTtl,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$UpdateFlareSolverrSessionTtl,
        );
}

extension ClientExtension$Mutation$UpdateFlareSolverrSessionTtl
    on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$UpdateFlareSolverrSessionTtl>>
      mutate$UpdateFlareSolverrSessionTtl(
              [Options$Mutation$UpdateFlareSolverrSessionTtl? options]) async =>
          await this.mutate(
              options ?? Options$Mutation$UpdateFlareSolverrSessionTtl());

  graphql.ObservableQuery<Mutation$UpdateFlareSolverrSessionTtl>
      watchMutation$UpdateFlareSolverrSessionTtl(
              [WatchOptions$Mutation$UpdateFlareSolverrSessionTtl? options]) =>
          this.watchMutation(
              options ?? WatchOptions$Mutation$UpdateFlareSolverrSessionTtl());
}

class Mutation$UpdateFlareSolverrSessionTtl$HookResult {
  Mutation$UpdateFlareSolverrSessionTtl$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$UpdateFlareSolverrSessionTtl runMutation;

  final graphql.QueryResult<Mutation$UpdateFlareSolverrSessionTtl> result;
}

Mutation$UpdateFlareSolverrSessionTtl$HookResult
    useMutation$UpdateFlareSolverrSessionTtl(
        [WidgetOptions$Mutation$UpdateFlareSolverrSessionTtl? options]) {
  final result = graphql_flutter.useMutation(
      options ?? WidgetOptions$Mutation$UpdateFlareSolverrSessionTtl());
  return Mutation$UpdateFlareSolverrSessionTtl$HookResult(
    ({variables, optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables?.toJson() ?? const {},
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$UpdateFlareSolverrSessionTtl>
    useWatchMutation$UpdateFlareSolverrSessionTtl(
            [WatchOptions$Mutation$UpdateFlareSolverrSessionTtl? options]) =>
        graphql_flutter.useWatchMutation(
            options ?? WatchOptions$Mutation$UpdateFlareSolverrSessionTtl());

class WidgetOptions$Mutation$UpdateFlareSolverrSessionTtl
    extends graphql.MutationOptions<Mutation$UpdateFlareSolverrSessionTtl> {
  WidgetOptions$Mutation$UpdateFlareSolverrSessionTtl({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateFlareSolverrSessionTtl? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateFlareSolverrSessionTtl? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateFlareSolverrSessionTtl>? update,
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
                        : _parserFn$Mutation$UpdateFlareSolverrSessionTtl(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateFlareSolverrSessionTtl,
          parserFn: _parserFn$Mutation$UpdateFlareSolverrSessionTtl,
        );

  final OnMutationCompleted$Mutation$UpdateFlareSolverrSessionTtl?
      onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$UpdateFlareSolverrSessionTtl
    = graphql.MultiSourceResult<Mutation$UpdateFlareSolverrSessionTtl>
        Function({
  Variables$Mutation$UpdateFlareSolverrSessionTtl? variables,
  Object? optimisticResult,
  Mutation$UpdateFlareSolverrSessionTtl? typedOptimisticResult,
});
typedef Builder$Mutation$UpdateFlareSolverrSessionTtl = widgets.Widget Function(
  RunMutation$Mutation$UpdateFlareSolverrSessionTtl,
  graphql.QueryResult<Mutation$UpdateFlareSolverrSessionTtl>?,
);

class Mutation$UpdateFlareSolverrSessionTtl$Widget
    extends graphql_flutter.Mutation<Mutation$UpdateFlareSolverrSessionTtl> {
  Mutation$UpdateFlareSolverrSessionTtl$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$UpdateFlareSolverrSessionTtl? options,
    required Builder$Mutation$UpdateFlareSolverrSessionTtl builder,
  }) : super(
          key: key,
          options:
              options ?? WidgetOptions$Mutation$UpdateFlareSolverrSessionTtl(),
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

class Mutation$UpdateFlareSolverrSessionTtl$setSettings {
  Mutation$UpdateFlareSolverrSessionTtl$setSettings({
    required this.settings,
    this.$__typename = 'SetSettingsPayload',
  });

  factory Mutation$UpdateFlareSolverrSessionTtl$setSettings.fromJson(
      Map<String, dynamic> json) {
    final l$settings = json['settings'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateFlareSolverrSessionTtl$setSettings(
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
    if (other is! Mutation$UpdateFlareSolverrSessionTtl$setSettings ||
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

extension UtilityExtension$Mutation$UpdateFlareSolverrSessionTtl$setSettings
    on Mutation$UpdateFlareSolverrSessionTtl$setSettings {
  CopyWith$Mutation$UpdateFlareSolverrSessionTtl$setSettings<
          Mutation$UpdateFlareSolverrSessionTtl$setSettings>
      get copyWith =>
          CopyWith$Mutation$UpdateFlareSolverrSessionTtl$setSettings(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdateFlareSolverrSessionTtl$setSettings<
    TRes> {
  factory CopyWith$Mutation$UpdateFlareSolverrSessionTtl$setSettings(
    Mutation$UpdateFlareSolverrSessionTtl$setSettings instance,
    TRes Function(Mutation$UpdateFlareSolverrSessionTtl$setSettings) then,
  ) = _CopyWithImpl$Mutation$UpdateFlareSolverrSessionTtl$setSettings;

  factory CopyWith$Mutation$UpdateFlareSolverrSessionTtl$setSettings.stub(
          TRes res) =
      _CopyWithStubImpl$Mutation$UpdateFlareSolverrSessionTtl$setSettings;

  TRes call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  });
  CopyWith$Fragment$SettingsDto<TRes> get settings;
}

class _CopyWithImpl$Mutation$UpdateFlareSolverrSessionTtl$setSettings<TRes>
    implements
        CopyWith$Mutation$UpdateFlareSolverrSessionTtl$setSettings<TRes> {
  _CopyWithImpl$Mutation$UpdateFlareSolverrSessionTtl$setSettings(
    this._instance,
    this._then,
  );

  final Mutation$UpdateFlareSolverrSessionTtl$setSettings _instance;

  final TRes Function(Mutation$UpdateFlareSolverrSessionTtl$setSettings) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? settings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateFlareSolverrSessionTtl$setSettings(
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

class _CopyWithStubImpl$Mutation$UpdateFlareSolverrSessionTtl$setSettings<TRes>
    implements
        CopyWith$Mutation$UpdateFlareSolverrSessionTtl$setSettings<TRes> {
  _CopyWithStubImpl$Mutation$UpdateFlareSolverrSessionTtl$setSettings(
      this._res);

  TRes _res;

  call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$SettingsDto<TRes> get settings =>
      CopyWith$Fragment$SettingsDto.stub(_res);
}

class Variables$Mutation$UpdateFlareSolverrSessionName {
  factory Variables$Mutation$UpdateFlareSolverrSessionName(
          {required String flareSolverrSessionName}) =>
      Variables$Mutation$UpdateFlareSolverrSessionName._({
        r'flareSolverrSessionName': flareSolverrSessionName,
      });

  Variables$Mutation$UpdateFlareSolverrSessionName._(this._$data);

  factory Variables$Mutation$UpdateFlareSolverrSessionName.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$flareSolverrSessionName = data['flareSolverrSessionName'];
    result$data['flareSolverrSessionName'] =
        (l$flareSolverrSessionName as String);
    return Variables$Mutation$UpdateFlareSolverrSessionName._(result$data);
  }

  Map<String, dynamic> _$data;

  String get flareSolverrSessionName =>
      (_$data['flareSolverrSessionName'] as String);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$flareSolverrSessionName = flareSolverrSessionName;
    result$data['flareSolverrSessionName'] = l$flareSolverrSessionName;
    return result$data;
  }

  CopyWith$Variables$Mutation$UpdateFlareSolverrSessionName<
          Variables$Mutation$UpdateFlareSolverrSessionName>
      get copyWith => CopyWith$Variables$Mutation$UpdateFlareSolverrSessionName(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$UpdateFlareSolverrSessionName ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$flareSolverrSessionName = flareSolverrSessionName;
    final lOther$flareSolverrSessionName = other.flareSolverrSessionName;
    if (l$flareSolverrSessionName != lOther$flareSolverrSessionName) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$flareSolverrSessionName = flareSolverrSessionName;
    return Object.hashAll([l$flareSolverrSessionName]);
  }
}

abstract class CopyWith$Variables$Mutation$UpdateFlareSolverrSessionName<TRes> {
  factory CopyWith$Variables$Mutation$UpdateFlareSolverrSessionName(
    Variables$Mutation$UpdateFlareSolverrSessionName instance,
    TRes Function(Variables$Mutation$UpdateFlareSolverrSessionName) then,
  ) = _CopyWithImpl$Variables$Mutation$UpdateFlareSolverrSessionName;

  factory CopyWith$Variables$Mutation$UpdateFlareSolverrSessionName.stub(
          TRes res) =
      _CopyWithStubImpl$Variables$Mutation$UpdateFlareSolverrSessionName;

  TRes call({String? flareSolverrSessionName});
}

class _CopyWithImpl$Variables$Mutation$UpdateFlareSolverrSessionName<TRes>
    implements CopyWith$Variables$Mutation$UpdateFlareSolverrSessionName<TRes> {
  _CopyWithImpl$Variables$Mutation$UpdateFlareSolverrSessionName(
    this._instance,
    this._then,
  );

  final Variables$Mutation$UpdateFlareSolverrSessionName _instance;

  final TRes Function(Variables$Mutation$UpdateFlareSolverrSessionName) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? flareSolverrSessionName = _undefined}) =>
      _then(Variables$Mutation$UpdateFlareSolverrSessionName._({
        ..._instance._$data,
        if (flareSolverrSessionName != _undefined &&
            flareSolverrSessionName != null)
          'flareSolverrSessionName': (flareSolverrSessionName as String),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$UpdateFlareSolverrSessionName<TRes>
    implements CopyWith$Variables$Mutation$UpdateFlareSolverrSessionName<TRes> {
  _CopyWithStubImpl$Variables$Mutation$UpdateFlareSolverrSessionName(this._res);

  TRes _res;

  call({String? flareSolverrSessionName}) => _res;
}

class Mutation$UpdateFlareSolverrSessionName {
  Mutation$UpdateFlareSolverrSessionName({
    required this.setSettings,
    this.$__typename = 'Mutation',
  });

  factory Mutation$UpdateFlareSolverrSessionName.fromJson(
      Map<String, dynamic> json) {
    final l$setSettings = json['setSettings'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateFlareSolverrSessionName(
      setSettings: Mutation$UpdateFlareSolverrSessionName$setSettings.fromJson(
          (l$setSettings as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$UpdateFlareSolverrSessionName$setSettings setSettings;

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
    if (other is! Mutation$UpdateFlareSolverrSessionName ||
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

extension UtilityExtension$Mutation$UpdateFlareSolverrSessionName
    on Mutation$UpdateFlareSolverrSessionName {
  CopyWith$Mutation$UpdateFlareSolverrSessionName<
          Mutation$UpdateFlareSolverrSessionName>
      get copyWith => CopyWith$Mutation$UpdateFlareSolverrSessionName(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdateFlareSolverrSessionName<TRes> {
  factory CopyWith$Mutation$UpdateFlareSolverrSessionName(
    Mutation$UpdateFlareSolverrSessionName instance,
    TRes Function(Mutation$UpdateFlareSolverrSessionName) then,
  ) = _CopyWithImpl$Mutation$UpdateFlareSolverrSessionName;

  factory CopyWith$Mutation$UpdateFlareSolverrSessionName.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateFlareSolverrSessionName;

  TRes call({
    Mutation$UpdateFlareSolverrSessionName$setSettings? setSettings,
    String? $__typename,
  });
  CopyWith$Mutation$UpdateFlareSolverrSessionName$setSettings<TRes>
      get setSettings;
}

class _CopyWithImpl$Mutation$UpdateFlareSolverrSessionName<TRes>
    implements CopyWith$Mutation$UpdateFlareSolverrSessionName<TRes> {
  _CopyWithImpl$Mutation$UpdateFlareSolverrSessionName(
    this._instance,
    this._then,
  );

  final Mutation$UpdateFlareSolverrSessionName _instance;

  final TRes Function(Mutation$UpdateFlareSolverrSessionName) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? setSettings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateFlareSolverrSessionName(
        setSettings: setSettings == _undefined || setSettings == null
            ? _instance.setSettings
            : (setSettings
                as Mutation$UpdateFlareSolverrSessionName$setSettings),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$UpdateFlareSolverrSessionName$setSettings<TRes>
      get setSettings {
    final local$setSettings = _instance.setSettings;
    return CopyWith$Mutation$UpdateFlareSolverrSessionName$setSettings(
        local$setSettings, (e) => call(setSettings: e));
  }
}

class _CopyWithStubImpl$Mutation$UpdateFlareSolverrSessionName<TRes>
    implements CopyWith$Mutation$UpdateFlareSolverrSessionName<TRes> {
  _CopyWithStubImpl$Mutation$UpdateFlareSolverrSessionName(this._res);

  TRes _res;

  call({
    Mutation$UpdateFlareSolverrSessionName$setSettings? setSettings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$UpdateFlareSolverrSessionName$setSettings<TRes>
      get setSettings =>
          CopyWith$Mutation$UpdateFlareSolverrSessionName$setSettings.stub(
              _res);
}

const documentNodeMutationUpdateFlareSolverrSessionName =
    DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'UpdateFlareSolverrSessionName'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable:
            VariableNode(name: NameNode(value: 'flareSolverrSessionName')),
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
                    name: NameNode(value: 'flareSolverrSessionName'),
                    value: VariableNode(
                        name: NameNode(value: 'flareSolverrSessionName')),
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
Mutation$UpdateFlareSolverrSessionName
    _parserFn$Mutation$UpdateFlareSolverrSessionName(
            Map<String, dynamic> data) =>
        Mutation$UpdateFlareSolverrSessionName.fromJson(data);
typedef OnMutationCompleted$Mutation$UpdateFlareSolverrSessionName
    = FutureOr<void> Function(
  Map<String, dynamic>?,
  Mutation$UpdateFlareSolverrSessionName?,
);

class Options$Mutation$UpdateFlareSolverrSessionName
    extends graphql.MutationOptions<Mutation$UpdateFlareSolverrSessionName> {
  Options$Mutation$UpdateFlareSolverrSessionName({
    String? operationName,
    required Variables$Mutation$UpdateFlareSolverrSessionName variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateFlareSolverrSessionName? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateFlareSolverrSessionName? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateFlareSolverrSessionName>? update,
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
                        : _parserFn$Mutation$UpdateFlareSolverrSessionName(
                            data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateFlareSolverrSessionName,
          parserFn: _parserFn$Mutation$UpdateFlareSolverrSessionName,
        );

  final OnMutationCompleted$Mutation$UpdateFlareSolverrSessionName?
      onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$UpdateFlareSolverrSessionName
    extends graphql.WatchQueryOptions<Mutation$UpdateFlareSolverrSessionName> {
  WatchOptions$Mutation$UpdateFlareSolverrSessionName({
    String? operationName,
    required Variables$Mutation$UpdateFlareSolverrSessionName variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateFlareSolverrSessionName? typedOptimisticResult,
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
          document: documentNodeMutationUpdateFlareSolverrSessionName,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$UpdateFlareSolverrSessionName,
        );
}

extension ClientExtension$Mutation$UpdateFlareSolverrSessionName
    on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$UpdateFlareSolverrSessionName>>
      mutate$UpdateFlareSolverrSessionName(
              Options$Mutation$UpdateFlareSolverrSessionName options) async =>
          await this.mutate(options);

  graphql.ObservableQuery<Mutation$UpdateFlareSolverrSessionName>
      watchMutation$UpdateFlareSolverrSessionName(
              WatchOptions$Mutation$UpdateFlareSolverrSessionName options) =>
          this.watchMutation(options);
}

class Mutation$UpdateFlareSolverrSessionName$HookResult {
  Mutation$UpdateFlareSolverrSessionName$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$UpdateFlareSolverrSessionName runMutation;

  final graphql.QueryResult<Mutation$UpdateFlareSolverrSessionName> result;
}

Mutation$UpdateFlareSolverrSessionName$HookResult
    useMutation$UpdateFlareSolverrSessionName(
        [WidgetOptions$Mutation$UpdateFlareSolverrSessionName? options]) {
  final result = graphql_flutter.useMutation(
      options ?? WidgetOptions$Mutation$UpdateFlareSolverrSessionName());
  return Mutation$UpdateFlareSolverrSessionName$HookResult(
    (variables, {optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables.toJson(),
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$UpdateFlareSolverrSessionName>
    useWatchMutation$UpdateFlareSolverrSessionName(
            WatchOptions$Mutation$UpdateFlareSolverrSessionName options) =>
        graphql_flutter.useWatchMutation(options);

class WidgetOptions$Mutation$UpdateFlareSolverrSessionName
    extends graphql.MutationOptions<Mutation$UpdateFlareSolverrSessionName> {
  WidgetOptions$Mutation$UpdateFlareSolverrSessionName({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateFlareSolverrSessionName? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateFlareSolverrSessionName? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateFlareSolverrSessionName>? update,
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
                        : _parserFn$Mutation$UpdateFlareSolverrSessionName(
                            data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateFlareSolverrSessionName,
          parserFn: _parserFn$Mutation$UpdateFlareSolverrSessionName,
        );

  final OnMutationCompleted$Mutation$UpdateFlareSolverrSessionName?
      onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$UpdateFlareSolverrSessionName
    = graphql.MultiSourceResult<Mutation$UpdateFlareSolverrSessionName>
        Function(
  Variables$Mutation$UpdateFlareSolverrSessionName, {
  Object? optimisticResult,
  Mutation$UpdateFlareSolverrSessionName? typedOptimisticResult,
});
typedef Builder$Mutation$UpdateFlareSolverrSessionName = widgets.Widget
    Function(
  RunMutation$Mutation$UpdateFlareSolverrSessionName,
  graphql.QueryResult<Mutation$UpdateFlareSolverrSessionName>?,
);

class Mutation$UpdateFlareSolverrSessionName$Widget
    extends graphql_flutter.Mutation<Mutation$UpdateFlareSolverrSessionName> {
  Mutation$UpdateFlareSolverrSessionName$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$UpdateFlareSolverrSessionName? options,
    required Builder$Mutation$UpdateFlareSolverrSessionName builder,
  }) : super(
          key: key,
          options:
              options ?? WidgetOptions$Mutation$UpdateFlareSolverrSessionName(),
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

class Mutation$UpdateFlareSolverrSessionName$setSettings {
  Mutation$UpdateFlareSolverrSessionName$setSettings({
    required this.settings,
    this.$__typename = 'SetSettingsPayload',
  });

  factory Mutation$UpdateFlareSolverrSessionName$setSettings.fromJson(
      Map<String, dynamic> json) {
    final l$settings = json['settings'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateFlareSolverrSessionName$setSettings(
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
    if (other is! Mutation$UpdateFlareSolverrSessionName$setSettings ||
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

extension UtilityExtension$Mutation$UpdateFlareSolverrSessionName$setSettings
    on Mutation$UpdateFlareSolverrSessionName$setSettings {
  CopyWith$Mutation$UpdateFlareSolverrSessionName$setSettings<
          Mutation$UpdateFlareSolverrSessionName$setSettings>
      get copyWith =>
          CopyWith$Mutation$UpdateFlareSolverrSessionName$setSettings(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdateFlareSolverrSessionName$setSettings<
    TRes> {
  factory CopyWith$Mutation$UpdateFlareSolverrSessionName$setSettings(
    Mutation$UpdateFlareSolverrSessionName$setSettings instance,
    TRes Function(Mutation$UpdateFlareSolverrSessionName$setSettings) then,
  ) = _CopyWithImpl$Mutation$UpdateFlareSolverrSessionName$setSettings;

  factory CopyWith$Mutation$UpdateFlareSolverrSessionName$setSettings.stub(
          TRes res) =
      _CopyWithStubImpl$Mutation$UpdateFlareSolverrSessionName$setSettings;

  TRes call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  });
  CopyWith$Fragment$SettingsDto<TRes> get settings;
}

class _CopyWithImpl$Mutation$UpdateFlareSolverrSessionName$setSettings<TRes>
    implements
        CopyWith$Mutation$UpdateFlareSolverrSessionName$setSettings<TRes> {
  _CopyWithImpl$Mutation$UpdateFlareSolverrSessionName$setSettings(
    this._instance,
    this._then,
  );

  final Mutation$UpdateFlareSolverrSessionName$setSettings _instance;

  final TRes Function(Mutation$UpdateFlareSolverrSessionName$setSettings) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? settings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateFlareSolverrSessionName$setSettings(
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

class _CopyWithStubImpl$Mutation$UpdateFlareSolverrSessionName$setSettings<TRes>
    implements
        CopyWith$Mutation$UpdateFlareSolverrSessionName$setSettings<TRes> {
  _CopyWithStubImpl$Mutation$UpdateFlareSolverrSessionName$setSettings(
      this._res);

  TRes _res;

  call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$SettingsDto<TRes> get settings =>
      CopyWith$Fragment$SettingsDto.stub(_res);
}

class Variables$Mutation$ToggleSystemTrayEnabled {
  factory Variables$Mutation$ToggleSystemTrayEnabled(
          {bool? systemTrayEnabled}) =>
      Variables$Mutation$ToggleSystemTrayEnabled._({
        if (systemTrayEnabled != null) r'systemTrayEnabled': systemTrayEnabled,
      });

  Variables$Mutation$ToggleSystemTrayEnabled._(this._$data);

  factory Variables$Mutation$ToggleSystemTrayEnabled.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('systemTrayEnabled')) {
      final l$systemTrayEnabled = data['systemTrayEnabled'];
      result$data['systemTrayEnabled'] = (l$systemTrayEnabled as bool?);
    }
    return Variables$Mutation$ToggleSystemTrayEnabled._(result$data);
  }

  Map<String, dynamic> _$data;

  bool? get systemTrayEnabled => (_$data['systemTrayEnabled'] as bool?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('systemTrayEnabled')) {
      final l$systemTrayEnabled = systemTrayEnabled;
      result$data['systemTrayEnabled'] = l$systemTrayEnabled;
    }
    return result$data;
  }

  CopyWith$Variables$Mutation$ToggleSystemTrayEnabled<
          Variables$Mutation$ToggleSystemTrayEnabled>
      get copyWith => CopyWith$Variables$Mutation$ToggleSystemTrayEnabled(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$ToggleSystemTrayEnabled ||
        runtimeType != other.runtimeType) {
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
    return true;
  }

  @override
  int get hashCode {
    final l$systemTrayEnabled = systemTrayEnabled;
    return Object.hashAll([
      _$data.containsKey('systemTrayEnabled') ? l$systemTrayEnabled : const {}
    ]);
  }
}

abstract class CopyWith$Variables$Mutation$ToggleSystemTrayEnabled<TRes> {
  factory CopyWith$Variables$Mutation$ToggleSystemTrayEnabled(
    Variables$Mutation$ToggleSystemTrayEnabled instance,
    TRes Function(Variables$Mutation$ToggleSystemTrayEnabled) then,
  ) = _CopyWithImpl$Variables$Mutation$ToggleSystemTrayEnabled;

  factory CopyWith$Variables$Mutation$ToggleSystemTrayEnabled.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$ToggleSystemTrayEnabled;

  TRes call({bool? systemTrayEnabled});
}

class _CopyWithImpl$Variables$Mutation$ToggleSystemTrayEnabled<TRes>
    implements CopyWith$Variables$Mutation$ToggleSystemTrayEnabled<TRes> {
  _CopyWithImpl$Variables$Mutation$ToggleSystemTrayEnabled(
    this._instance,
    this._then,
  );

  final Variables$Mutation$ToggleSystemTrayEnabled _instance;

  final TRes Function(Variables$Mutation$ToggleSystemTrayEnabled) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? systemTrayEnabled = _undefined}) =>
      _then(Variables$Mutation$ToggleSystemTrayEnabled._({
        ..._instance._$data,
        if (systemTrayEnabled != _undefined)
          'systemTrayEnabled': (systemTrayEnabled as bool?),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$ToggleSystemTrayEnabled<TRes>
    implements CopyWith$Variables$Mutation$ToggleSystemTrayEnabled<TRes> {
  _CopyWithStubImpl$Variables$Mutation$ToggleSystemTrayEnabled(this._res);

  TRes _res;

  call({bool? systemTrayEnabled}) => _res;
}

class Mutation$ToggleSystemTrayEnabled {
  Mutation$ToggleSystemTrayEnabled({
    required this.setSettings,
    this.$__typename = 'Mutation',
  });

  factory Mutation$ToggleSystemTrayEnabled.fromJson(Map<String, dynamic> json) {
    final l$setSettings = json['setSettings'];
    final l$$__typename = json['__typename'];
    return Mutation$ToggleSystemTrayEnabled(
      setSettings: Mutation$ToggleSystemTrayEnabled$setSettings.fromJson(
          (l$setSettings as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$ToggleSystemTrayEnabled$setSettings setSettings;

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
    if (other is! Mutation$ToggleSystemTrayEnabled ||
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

extension UtilityExtension$Mutation$ToggleSystemTrayEnabled
    on Mutation$ToggleSystemTrayEnabled {
  CopyWith$Mutation$ToggleSystemTrayEnabled<Mutation$ToggleSystemTrayEnabled>
      get copyWith => CopyWith$Mutation$ToggleSystemTrayEnabled(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$ToggleSystemTrayEnabled<TRes> {
  factory CopyWith$Mutation$ToggleSystemTrayEnabled(
    Mutation$ToggleSystemTrayEnabled instance,
    TRes Function(Mutation$ToggleSystemTrayEnabled) then,
  ) = _CopyWithImpl$Mutation$ToggleSystemTrayEnabled;

  factory CopyWith$Mutation$ToggleSystemTrayEnabled.stub(TRes res) =
      _CopyWithStubImpl$Mutation$ToggleSystemTrayEnabled;

  TRes call({
    Mutation$ToggleSystemTrayEnabled$setSettings? setSettings,
    String? $__typename,
  });
  CopyWith$Mutation$ToggleSystemTrayEnabled$setSettings<TRes> get setSettings;
}

class _CopyWithImpl$Mutation$ToggleSystemTrayEnabled<TRes>
    implements CopyWith$Mutation$ToggleSystemTrayEnabled<TRes> {
  _CopyWithImpl$Mutation$ToggleSystemTrayEnabled(
    this._instance,
    this._then,
  );

  final Mutation$ToggleSystemTrayEnabled _instance;

  final TRes Function(Mutation$ToggleSystemTrayEnabled) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? setSettings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$ToggleSystemTrayEnabled(
        setSettings: setSettings == _undefined || setSettings == null
            ? _instance.setSettings
            : (setSettings as Mutation$ToggleSystemTrayEnabled$setSettings),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$ToggleSystemTrayEnabled$setSettings<TRes> get setSettings {
    final local$setSettings = _instance.setSettings;
    return CopyWith$Mutation$ToggleSystemTrayEnabled$setSettings(
        local$setSettings, (e) => call(setSettings: e));
  }
}

class _CopyWithStubImpl$Mutation$ToggleSystemTrayEnabled<TRes>
    implements CopyWith$Mutation$ToggleSystemTrayEnabled<TRes> {
  _CopyWithStubImpl$Mutation$ToggleSystemTrayEnabled(this._res);

  TRes _res;

  call({
    Mutation$ToggleSystemTrayEnabled$setSettings? setSettings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$ToggleSystemTrayEnabled$setSettings<TRes> get setSettings =>
      CopyWith$Mutation$ToggleSystemTrayEnabled$setSettings.stub(_res);
}

const documentNodeMutationToggleSystemTrayEnabled = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'ToggleSystemTrayEnabled'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'systemTrayEnabled')),
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
                    name: NameNode(value: 'systemTrayEnabled'),
                    value: VariableNode(
                        name: NameNode(value: 'systemTrayEnabled')),
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
Mutation$ToggleSystemTrayEnabled _parserFn$Mutation$ToggleSystemTrayEnabled(
        Map<String, dynamic> data) =>
    Mutation$ToggleSystemTrayEnabled.fromJson(data);
typedef OnMutationCompleted$Mutation$ToggleSystemTrayEnabled = FutureOr<void>
    Function(
  Map<String, dynamic>?,
  Mutation$ToggleSystemTrayEnabled?,
);

class Options$Mutation$ToggleSystemTrayEnabled
    extends graphql.MutationOptions<Mutation$ToggleSystemTrayEnabled> {
  Options$Mutation$ToggleSystemTrayEnabled({
    String? operationName,
    Variables$Mutation$ToggleSystemTrayEnabled? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$ToggleSystemTrayEnabled? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$ToggleSystemTrayEnabled? onCompleted,
    graphql.OnMutationUpdate<Mutation$ToggleSystemTrayEnabled>? update,
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
                        : _parserFn$Mutation$ToggleSystemTrayEnabled(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationToggleSystemTrayEnabled,
          parserFn: _parserFn$Mutation$ToggleSystemTrayEnabled,
        );

  final OnMutationCompleted$Mutation$ToggleSystemTrayEnabled?
      onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$ToggleSystemTrayEnabled
    extends graphql.WatchQueryOptions<Mutation$ToggleSystemTrayEnabled> {
  WatchOptions$Mutation$ToggleSystemTrayEnabled({
    String? operationName,
    Variables$Mutation$ToggleSystemTrayEnabled? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$ToggleSystemTrayEnabled? typedOptimisticResult,
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
          document: documentNodeMutationToggleSystemTrayEnabled,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$ToggleSystemTrayEnabled,
        );
}

extension ClientExtension$Mutation$ToggleSystemTrayEnabled
    on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$ToggleSystemTrayEnabled>>
      mutate$ToggleSystemTrayEnabled(
              [Options$Mutation$ToggleSystemTrayEnabled? options]) async =>
          await this
              .mutate(options ?? Options$Mutation$ToggleSystemTrayEnabled());

  graphql.ObservableQuery<Mutation$ToggleSystemTrayEnabled>
      watchMutation$ToggleSystemTrayEnabled(
              [WatchOptions$Mutation$ToggleSystemTrayEnabled? options]) =>
          this.watchMutation(
              options ?? WatchOptions$Mutation$ToggleSystemTrayEnabled());
}

class Mutation$ToggleSystemTrayEnabled$HookResult {
  Mutation$ToggleSystemTrayEnabled$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$ToggleSystemTrayEnabled runMutation;

  final graphql.QueryResult<Mutation$ToggleSystemTrayEnabled> result;
}

Mutation$ToggleSystemTrayEnabled$HookResult useMutation$ToggleSystemTrayEnabled(
    [WidgetOptions$Mutation$ToggleSystemTrayEnabled? options]) {
  final result = graphql_flutter
      .useMutation(options ?? WidgetOptions$Mutation$ToggleSystemTrayEnabled());
  return Mutation$ToggleSystemTrayEnabled$HookResult(
    ({variables, optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables?.toJson() ?? const {},
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$ToggleSystemTrayEnabled>
    useWatchMutation$ToggleSystemTrayEnabled(
            [WatchOptions$Mutation$ToggleSystemTrayEnabled? options]) =>
        graphql_flutter.useWatchMutation(
            options ?? WatchOptions$Mutation$ToggleSystemTrayEnabled());

class WidgetOptions$Mutation$ToggleSystemTrayEnabled
    extends graphql.MutationOptions<Mutation$ToggleSystemTrayEnabled> {
  WidgetOptions$Mutation$ToggleSystemTrayEnabled({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$ToggleSystemTrayEnabled? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$ToggleSystemTrayEnabled? onCompleted,
    graphql.OnMutationUpdate<Mutation$ToggleSystemTrayEnabled>? update,
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
                        : _parserFn$Mutation$ToggleSystemTrayEnabled(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationToggleSystemTrayEnabled,
          parserFn: _parserFn$Mutation$ToggleSystemTrayEnabled,
        );

  final OnMutationCompleted$Mutation$ToggleSystemTrayEnabled?
      onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$ToggleSystemTrayEnabled
    = graphql.MultiSourceResult<Mutation$ToggleSystemTrayEnabled> Function({
  Variables$Mutation$ToggleSystemTrayEnabled? variables,
  Object? optimisticResult,
  Mutation$ToggleSystemTrayEnabled? typedOptimisticResult,
});
typedef Builder$Mutation$ToggleSystemTrayEnabled = widgets.Widget Function(
  RunMutation$Mutation$ToggleSystemTrayEnabled,
  graphql.QueryResult<Mutation$ToggleSystemTrayEnabled>?,
);

class Mutation$ToggleSystemTrayEnabled$Widget
    extends graphql_flutter.Mutation<Mutation$ToggleSystemTrayEnabled> {
  Mutation$ToggleSystemTrayEnabled$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$ToggleSystemTrayEnabled? options,
    required Builder$Mutation$ToggleSystemTrayEnabled builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$ToggleSystemTrayEnabled(),
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

class Mutation$ToggleSystemTrayEnabled$setSettings {
  Mutation$ToggleSystemTrayEnabled$setSettings({
    required this.settings,
    this.$__typename = 'SetSettingsPayload',
  });

  factory Mutation$ToggleSystemTrayEnabled$setSettings.fromJson(
      Map<String, dynamic> json) {
    final l$settings = json['settings'];
    final l$$__typename = json['__typename'];
    return Mutation$ToggleSystemTrayEnabled$setSettings(
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
    if (other is! Mutation$ToggleSystemTrayEnabled$setSettings ||
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

extension UtilityExtension$Mutation$ToggleSystemTrayEnabled$setSettings
    on Mutation$ToggleSystemTrayEnabled$setSettings {
  CopyWith$Mutation$ToggleSystemTrayEnabled$setSettings<
          Mutation$ToggleSystemTrayEnabled$setSettings>
      get copyWith => CopyWith$Mutation$ToggleSystemTrayEnabled$setSettings(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$ToggleSystemTrayEnabled$setSettings<TRes> {
  factory CopyWith$Mutation$ToggleSystemTrayEnabled$setSettings(
    Mutation$ToggleSystemTrayEnabled$setSettings instance,
    TRes Function(Mutation$ToggleSystemTrayEnabled$setSettings) then,
  ) = _CopyWithImpl$Mutation$ToggleSystemTrayEnabled$setSettings;

  factory CopyWith$Mutation$ToggleSystemTrayEnabled$setSettings.stub(TRes res) =
      _CopyWithStubImpl$Mutation$ToggleSystemTrayEnabled$setSettings;

  TRes call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  });
  CopyWith$Fragment$SettingsDto<TRes> get settings;
}

class _CopyWithImpl$Mutation$ToggleSystemTrayEnabled$setSettings<TRes>
    implements CopyWith$Mutation$ToggleSystemTrayEnabled$setSettings<TRes> {
  _CopyWithImpl$Mutation$ToggleSystemTrayEnabled$setSettings(
    this._instance,
    this._then,
  );

  final Mutation$ToggleSystemTrayEnabled$setSettings _instance;

  final TRes Function(Mutation$ToggleSystemTrayEnabled$setSettings) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? settings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$ToggleSystemTrayEnabled$setSettings(
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

class _CopyWithStubImpl$Mutation$ToggleSystemTrayEnabled$setSettings<TRes>
    implements CopyWith$Mutation$ToggleSystemTrayEnabled$setSettings<TRes> {
  _CopyWithStubImpl$Mutation$ToggleSystemTrayEnabled$setSettings(this._res);

  TRes _res;

  call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$SettingsDto<TRes> get settings =>
      CopyWith$Fragment$SettingsDto.stub(_res);
}

class Variables$Mutation$ToggleSocksProxy {
  factory Variables$Mutation$ToggleSocksProxy({bool? socksProxyEnabled}) =>
      Variables$Mutation$ToggleSocksProxy._({
        if (socksProxyEnabled != null) r'socksProxyEnabled': socksProxyEnabled,
      });

  Variables$Mutation$ToggleSocksProxy._(this._$data);

  factory Variables$Mutation$ToggleSocksProxy.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('socksProxyEnabled')) {
      final l$socksProxyEnabled = data['socksProxyEnabled'];
      result$data['socksProxyEnabled'] = (l$socksProxyEnabled as bool?);
    }
    return Variables$Mutation$ToggleSocksProxy._(result$data);
  }

  Map<String, dynamic> _$data;

  bool? get socksProxyEnabled => (_$data['socksProxyEnabled'] as bool?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('socksProxyEnabled')) {
      final l$socksProxyEnabled = socksProxyEnabled;
      result$data['socksProxyEnabled'] = l$socksProxyEnabled;
    }
    return result$data;
  }

  CopyWith$Variables$Mutation$ToggleSocksProxy<
          Variables$Mutation$ToggleSocksProxy>
      get copyWith => CopyWith$Variables$Mutation$ToggleSocksProxy(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$ToggleSocksProxy ||
        runtimeType != other.runtimeType) {
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
    return true;
  }

  @override
  int get hashCode {
    final l$socksProxyEnabled = socksProxyEnabled;
    return Object.hashAll([
      _$data.containsKey('socksProxyEnabled') ? l$socksProxyEnabled : const {}
    ]);
  }
}

abstract class CopyWith$Variables$Mutation$ToggleSocksProxy<TRes> {
  factory CopyWith$Variables$Mutation$ToggleSocksProxy(
    Variables$Mutation$ToggleSocksProxy instance,
    TRes Function(Variables$Mutation$ToggleSocksProxy) then,
  ) = _CopyWithImpl$Variables$Mutation$ToggleSocksProxy;

  factory CopyWith$Variables$Mutation$ToggleSocksProxy.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$ToggleSocksProxy;

  TRes call({bool? socksProxyEnabled});
}

class _CopyWithImpl$Variables$Mutation$ToggleSocksProxy<TRes>
    implements CopyWith$Variables$Mutation$ToggleSocksProxy<TRes> {
  _CopyWithImpl$Variables$Mutation$ToggleSocksProxy(
    this._instance,
    this._then,
  );

  final Variables$Mutation$ToggleSocksProxy _instance;

  final TRes Function(Variables$Mutation$ToggleSocksProxy) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? socksProxyEnabled = _undefined}) =>
      _then(Variables$Mutation$ToggleSocksProxy._({
        ..._instance._$data,
        if (socksProxyEnabled != _undefined)
          'socksProxyEnabled': (socksProxyEnabled as bool?),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$ToggleSocksProxy<TRes>
    implements CopyWith$Variables$Mutation$ToggleSocksProxy<TRes> {
  _CopyWithStubImpl$Variables$Mutation$ToggleSocksProxy(this._res);

  TRes _res;

  call({bool? socksProxyEnabled}) => _res;
}

class Mutation$ToggleSocksProxy {
  Mutation$ToggleSocksProxy({
    required this.setSettings,
    this.$__typename = 'Mutation',
  });

  factory Mutation$ToggleSocksProxy.fromJson(Map<String, dynamic> json) {
    final l$setSettings = json['setSettings'];
    final l$$__typename = json['__typename'];
    return Mutation$ToggleSocksProxy(
      setSettings: Mutation$ToggleSocksProxy$setSettings.fromJson(
          (l$setSettings as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$ToggleSocksProxy$setSettings setSettings;

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
    if (other is! Mutation$ToggleSocksProxy ||
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

extension UtilityExtension$Mutation$ToggleSocksProxy
    on Mutation$ToggleSocksProxy {
  CopyWith$Mutation$ToggleSocksProxy<Mutation$ToggleSocksProxy> get copyWith =>
      CopyWith$Mutation$ToggleSocksProxy(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Mutation$ToggleSocksProxy<TRes> {
  factory CopyWith$Mutation$ToggleSocksProxy(
    Mutation$ToggleSocksProxy instance,
    TRes Function(Mutation$ToggleSocksProxy) then,
  ) = _CopyWithImpl$Mutation$ToggleSocksProxy;

  factory CopyWith$Mutation$ToggleSocksProxy.stub(TRes res) =
      _CopyWithStubImpl$Mutation$ToggleSocksProxy;

  TRes call({
    Mutation$ToggleSocksProxy$setSettings? setSettings,
    String? $__typename,
  });
  CopyWith$Mutation$ToggleSocksProxy$setSettings<TRes> get setSettings;
}

class _CopyWithImpl$Mutation$ToggleSocksProxy<TRes>
    implements CopyWith$Mutation$ToggleSocksProxy<TRes> {
  _CopyWithImpl$Mutation$ToggleSocksProxy(
    this._instance,
    this._then,
  );

  final Mutation$ToggleSocksProxy _instance;

  final TRes Function(Mutation$ToggleSocksProxy) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? setSettings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$ToggleSocksProxy(
        setSettings: setSettings == _undefined || setSettings == null
            ? _instance.setSettings
            : (setSettings as Mutation$ToggleSocksProxy$setSettings),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$ToggleSocksProxy$setSettings<TRes> get setSettings {
    final local$setSettings = _instance.setSettings;
    return CopyWith$Mutation$ToggleSocksProxy$setSettings(
        local$setSettings, (e) => call(setSettings: e));
  }
}

class _CopyWithStubImpl$Mutation$ToggleSocksProxy<TRes>
    implements CopyWith$Mutation$ToggleSocksProxy<TRes> {
  _CopyWithStubImpl$Mutation$ToggleSocksProxy(this._res);

  TRes _res;

  call({
    Mutation$ToggleSocksProxy$setSettings? setSettings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$ToggleSocksProxy$setSettings<TRes> get setSettings =>
      CopyWith$Mutation$ToggleSocksProxy$setSettings.stub(_res);
}

const documentNodeMutationToggleSocksProxy = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'ToggleSocksProxy'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'socksProxyEnabled')),
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
                    name: NameNode(value: 'socksProxyEnabled'),
                    value: VariableNode(
                        name: NameNode(value: 'socksProxyEnabled')),
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
Mutation$ToggleSocksProxy _parserFn$Mutation$ToggleSocksProxy(
        Map<String, dynamic> data) =>
    Mutation$ToggleSocksProxy.fromJson(data);
typedef OnMutationCompleted$Mutation$ToggleSocksProxy = FutureOr<void> Function(
  Map<String, dynamic>?,
  Mutation$ToggleSocksProxy?,
);

class Options$Mutation$ToggleSocksProxy
    extends graphql.MutationOptions<Mutation$ToggleSocksProxy> {
  Options$Mutation$ToggleSocksProxy({
    String? operationName,
    Variables$Mutation$ToggleSocksProxy? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$ToggleSocksProxy? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$ToggleSocksProxy? onCompleted,
    graphql.OnMutationUpdate<Mutation$ToggleSocksProxy>? update,
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
                        : _parserFn$Mutation$ToggleSocksProxy(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationToggleSocksProxy,
          parserFn: _parserFn$Mutation$ToggleSocksProxy,
        );

  final OnMutationCompleted$Mutation$ToggleSocksProxy? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$ToggleSocksProxy
    extends graphql.WatchQueryOptions<Mutation$ToggleSocksProxy> {
  WatchOptions$Mutation$ToggleSocksProxy({
    String? operationName,
    Variables$Mutation$ToggleSocksProxy? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$ToggleSocksProxy? typedOptimisticResult,
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
          document: documentNodeMutationToggleSocksProxy,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$ToggleSocksProxy,
        );
}

extension ClientExtension$Mutation$ToggleSocksProxy on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$ToggleSocksProxy>>
      mutate$ToggleSocksProxy(
              [Options$Mutation$ToggleSocksProxy? options]) async =>
          await this.mutate(options ?? Options$Mutation$ToggleSocksProxy());

  graphql.ObservableQuery<
      Mutation$ToggleSocksProxy> watchMutation$ToggleSocksProxy(
          [WatchOptions$Mutation$ToggleSocksProxy? options]) =>
      this.watchMutation(options ?? WatchOptions$Mutation$ToggleSocksProxy());
}

class Mutation$ToggleSocksProxy$HookResult {
  Mutation$ToggleSocksProxy$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$ToggleSocksProxy runMutation;

  final graphql.QueryResult<Mutation$ToggleSocksProxy> result;
}

Mutation$ToggleSocksProxy$HookResult useMutation$ToggleSocksProxy(
    [WidgetOptions$Mutation$ToggleSocksProxy? options]) {
  final result = graphql_flutter
      .useMutation(options ?? WidgetOptions$Mutation$ToggleSocksProxy());
  return Mutation$ToggleSocksProxy$HookResult(
    ({variables, optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables?.toJson() ?? const {},
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$ToggleSocksProxy>
    useWatchMutation$ToggleSocksProxy(
            [WatchOptions$Mutation$ToggleSocksProxy? options]) =>
        graphql_flutter.useWatchMutation(
            options ?? WatchOptions$Mutation$ToggleSocksProxy());

class WidgetOptions$Mutation$ToggleSocksProxy
    extends graphql.MutationOptions<Mutation$ToggleSocksProxy> {
  WidgetOptions$Mutation$ToggleSocksProxy({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$ToggleSocksProxy? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$ToggleSocksProxy? onCompleted,
    graphql.OnMutationUpdate<Mutation$ToggleSocksProxy>? update,
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
                        : _parserFn$Mutation$ToggleSocksProxy(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationToggleSocksProxy,
          parserFn: _parserFn$Mutation$ToggleSocksProxy,
        );

  final OnMutationCompleted$Mutation$ToggleSocksProxy? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$ToggleSocksProxy
    = graphql.MultiSourceResult<Mutation$ToggleSocksProxy> Function({
  Variables$Mutation$ToggleSocksProxy? variables,
  Object? optimisticResult,
  Mutation$ToggleSocksProxy? typedOptimisticResult,
});
typedef Builder$Mutation$ToggleSocksProxy = widgets.Widget Function(
  RunMutation$Mutation$ToggleSocksProxy,
  graphql.QueryResult<Mutation$ToggleSocksProxy>?,
);

class Mutation$ToggleSocksProxy$Widget
    extends graphql_flutter.Mutation<Mutation$ToggleSocksProxy> {
  Mutation$ToggleSocksProxy$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$ToggleSocksProxy? options,
    required Builder$Mutation$ToggleSocksProxy builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$ToggleSocksProxy(),
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

class Mutation$ToggleSocksProxy$setSettings {
  Mutation$ToggleSocksProxy$setSettings({
    required this.settings,
    this.$__typename = 'SetSettingsPayload',
  });

  factory Mutation$ToggleSocksProxy$setSettings.fromJson(
      Map<String, dynamic> json) {
    final l$settings = json['settings'];
    final l$$__typename = json['__typename'];
    return Mutation$ToggleSocksProxy$setSettings(
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
    if (other is! Mutation$ToggleSocksProxy$setSettings ||
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

extension UtilityExtension$Mutation$ToggleSocksProxy$setSettings
    on Mutation$ToggleSocksProxy$setSettings {
  CopyWith$Mutation$ToggleSocksProxy$setSettings<
          Mutation$ToggleSocksProxy$setSettings>
      get copyWith => CopyWith$Mutation$ToggleSocksProxy$setSettings(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$ToggleSocksProxy$setSettings<TRes> {
  factory CopyWith$Mutation$ToggleSocksProxy$setSettings(
    Mutation$ToggleSocksProxy$setSettings instance,
    TRes Function(Mutation$ToggleSocksProxy$setSettings) then,
  ) = _CopyWithImpl$Mutation$ToggleSocksProxy$setSettings;

  factory CopyWith$Mutation$ToggleSocksProxy$setSettings.stub(TRes res) =
      _CopyWithStubImpl$Mutation$ToggleSocksProxy$setSettings;

  TRes call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  });
  CopyWith$Fragment$SettingsDto<TRes> get settings;
}

class _CopyWithImpl$Mutation$ToggleSocksProxy$setSettings<TRes>
    implements CopyWith$Mutation$ToggleSocksProxy$setSettings<TRes> {
  _CopyWithImpl$Mutation$ToggleSocksProxy$setSettings(
    this._instance,
    this._then,
  );

  final Mutation$ToggleSocksProxy$setSettings _instance;

  final TRes Function(Mutation$ToggleSocksProxy$setSettings) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? settings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$ToggleSocksProxy$setSettings(
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

class _CopyWithStubImpl$Mutation$ToggleSocksProxy$setSettings<TRes>
    implements CopyWith$Mutation$ToggleSocksProxy$setSettings<TRes> {
  _CopyWithStubImpl$Mutation$ToggleSocksProxy$setSettings(this._res);

  TRes _res;

  call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$SettingsDto<TRes> get settings =>
      CopyWith$Fragment$SettingsDto.stub(_res);
}

class Variables$Mutation$ToggleFlareSolverr {
  factory Variables$Mutation$ToggleFlareSolverr({bool? flareSolverrEnabled}) =>
      Variables$Mutation$ToggleFlareSolverr._({
        if (flareSolverrEnabled != null)
          r'flareSolverrEnabled': flareSolverrEnabled,
      });

  Variables$Mutation$ToggleFlareSolverr._(this._$data);

  factory Variables$Mutation$ToggleFlareSolverr.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('flareSolverrEnabled')) {
      final l$flareSolverrEnabled = data['flareSolverrEnabled'];
      result$data['flareSolverrEnabled'] = (l$flareSolverrEnabled as bool?);
    }
    return Variables$Mutation$ToggleFlareSolverr._(result$data);
  }

  Map<String, dynamic> _$data;

  bool? get flareSolverrEnabled => (_$data['flareSolverrEnabled'] as bool?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('flareSolverrEnabled')) {
      final l$flareSolverrEnabled = flareSolverrEnabled;
      result$data['flareSolverrEnabled'] = l$flareSolverrEnabled;
    }
    return result$data;
  }

  CopyWith$Variables$Mutation$ToggleFlareSolverr<
          Variables$Mutation$ToggleFlareSolverr>
      get copyWith => CopyWith$Variables$Mutation$ToggleFlareSolverr(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$ToggleFlareSolverr ||
        runtimeType != other.runtimeType) {
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
    return true;
  }

  @override
  int get hashCode {
    final l$flareSolverrEnabled = flareSolverrEnabled;
    return Object.hashAll([
      _$data.containsKey('flareSolverrEnabled')
          ? l$flareSolverrEnabled
          : const {}
    ]);
  }
}

abstract class CopyWith$Variables$Mutation$ToggleFlareSolverr<TRes> {
  factory CopyWith$Variables$Mutation$ToggleFlareSolverr(
    Variables$Mutation$ToggleFlareSolverr instance,
    TRes Function(Variables$Mutation$ToggleFlareSolverr) then,
  ) = _CopyWithImpl$Variables$Mutation$ToggleFlareSolverr;

  factory CopyWith$Variables$Mutation$ToggleFlareSolverr.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$ToggleFlareSolverr;

  TRes call({bool? flareSolverrEnabled});
}

class _CopyWithImpl$Variables$Mutation$ToggleFlareSolverr<TRes>
    implements CopyWith$Variables$Mutation$ToggleFlareSolverr<TRes> {
  _CopyWithImpl$Variables$Mutation$ToggleFlareSolverr(
    this._instance,
    this._then,
  );

  final Variables$Mutation$ToggleFlareSolverr _instance;

  final TRes Function(Variables$Mutation$ToggleFlareSolverr) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? flareSolverrEnabled = _undefined}) =>
      _then(Variables$Mutation$ToggleFlareSolverr._({
        ..._instance._$data,
        if (flareSolverrEnabled != _undefined)
          'flareSolverrEnabled': (flareSolverrEnabled as bool?),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$ToggleFlareSolverr<TRes>
    implements CopyWith$Variables$Mutation$ToggleFlareSolverr<TRes> {
  _CopyWithStubImpl$Variables$Mutation$ToggleFlareSolverr(this._res);

  TRes _res;

  call({bool? flareSolverrEnabled}) => _res;
}

class Mutation$ToggleFlareSolverr {
  Mutation$ToggleFlareSolverr({
    required this.setSettings,
    this.$__typename = 'Mutation',
  });

  factory Mutation$ToggleFlareSolverr.fromJson(Map<String, dynamic> json) {
    final l$setSettings = json['setSettings'];
    final l$$__typename = json['__typename'];
    return Mutation$ToggleFlareSolverr(
      setSettings: Mutation$ToggleFlareSolverr$setSettings.fromJson(
          (l$setSettings as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$ToggleFlareSolverr$setSettings setSettings;

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
    if (other is! Mutation$ToggleFlareSolverr ||
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

extension UtilityExtension$Mutation$ToggleFlareSolverr
    on Mutation$ToggleFlareSolverr {
  CopyWith$Mutation$ToggleFlareSolverr<Mutation$ToggleFlareSolverr>
      get copyWith => CopyWith$Mutation$ToggleFlareSolverr(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$ToggleFlareSolverr<TRes> {
  factory CopyWith$Mutation$ToggleFlareSolverr(
    Mutation$ToggleFlareSolverr instance,
    TRes Function(Mutation$ToggleFlareSolverr) then,
  ) = _CopyWithImpl$Mutation$ToggleFlareSolverr;

  factory CopyWith$Mutation$ToggleFlareSolverr.stub(TRes res) =
      _CopyWithStubImpl$Mutation$ToggleFlareSolverr;

  TRes call({
    Mutation$ToggleFlareSolverr$setSettings? setSettings,
    String? $__typename,
  });
  CopyWith$Mutation$ToggleFlareSolverr$setSettings<TRes> get setSettings;
}

class _CopyWithImpl$Mutation$ToggleFlareSolverr<TRes>
    implements CopyWith$Mutation$ToggleFlareSolverr<TRes> {
  _CopyWithImpl$Mutation$ToggleFlareSolverr(
    this._instance,
    this._then,
  );

  final Mutation$ToggleFlareSolverr _instance;

  final TRes Function(Mutation$ToggleFlareSolverr) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? setSettings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$ToggleFlareSolverr(
        setSettings: setSettings == _undefined || setSettings == null
            ? _instance.setSettings
            : (setSettings as Mutation$ToggleFlareSolverr$setSettings),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$ToggleFlareSolverr$setSettings<TRes> get setSettings {
    final local$setSettings = _instance.setSettings;
    return CopyWith$Mutation$ToggleFlareSolverr$setSettings(
        local$setSettings, (e) => call(setSettings: e));
  }
}

class _CopyWithStubImpl$Mutation$ToggleFlareSolverr<TRes>
    implements CopyWith$Mutation$ToggleFlareSolverr<TRes> {
  _CopyWithStubImpl$Mutation$ToggleFlareSolverr(this._res);

  TRes _res;

  call({
    Mutation$ToggleFlareSolverr$setSettings? setSettings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$ToggleFlareSolverr$setSettings<TRes> get setSettings =>
      CopyWith$Mutation$ToggleFlareSolverr$setSettings.stub(_res);
}

const documentNodeMutationToggleFlareSolverr = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'ToggleFlareSolverr'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'flareSolverrEnabled')),
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
                    name: NameNode(value: 'flareSolverrEnabled'),
                    value: VariableNode(
                        name: NameNode(value: 'flareSolverrEnabled')),
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
Mutation$ToggleFlareSolverr _parserFn$Mutation$ToggleFlareSolverr(
        Map<String, dynamic> data) =>
    Mutation$ToggleFlareSolverr.fromJson(data);
typedef OnMutationCompleted$Mutation$ToggleFlareSolverr = FutureOr<void>
    Function(
  Map<String, dynamic>?,
  Mutation$ToggleFlareSolverr?,
);

class Options$Mutation$ToggleFlareSolverr
    extends graphql.MutationOptions<Mutation$ToggleFlareSolverr> {
  Options$Mutation$ToggleFlareSolverr({
    String? operationName,
    Variables$Mutation$ToggleFlareSolverr? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$ToggleFlareSolverr? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$ToggleFlareSolverr? onCompleted,
    graphql.OnMutationUpdate<Mutation$ToggleFlareSolverr>? update,
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
                        : _parserFn$Mutation$ToggleFlareSolverr(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationToggleFlareSolverr,
          parserFn: _parserFn$Mutation$ToggleFlareSolverr,
        );

  final OnMutationCompleted$Mutation$ToggleFlareSolverr? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$ToggleFlareSolverr
    extends graphql.WatchQueryOptions<Mutation$ToggleFlareSolverr> {
  WatchOptions$Mutation$ToggleFlareSolverr({
    String? operationName,
    Variables$Mutation$ToggleFlareSolverr? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$ToggleFlareSolverr? typedOptimisticResult,
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
          document: documentNodeMutationToggleFlareSolverr,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$ToggleFlareSolverr,
        );
}

extension ClientExtension$Mutation$ToggleFlareSolverr on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$ToggleFlareSolverr>>
      mutate$ToggleFlareSolverr(
              [Options$Mutation$ToggleFlareSolverr? options]) async =>
          await this.mutate(options ?? Options$Mutation$ToggleFlareSolverr());

  graphql.ObservableQuery<
      Mutation$ToggleFlareSolverr> watchMutation$ToggleFlareSolverr(
          [WatchOptions$Mutation$ToggleFlareSolverr? options]) =>
      this.watchMutation(options ?? WatchOptions$Mutation$ToggleFlareSolverr());
}

class Mutation$ToggleFlareSolverr$HookResult {
  Mutation$ToggleFlareSolverr$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$ToggleFlareSolverr runMutation;

  final graphql.QueryResult<Mutation$ToggleFlareSolverr> result;
}

Mutation$ToggleFlareSolverr$HookResult useMutation$ToggleFlareSolverr(
    [WidgetOptions$Mutation$ToggleFlareSolverr? options]) {
  final result = graphql_flutter
      .useMutation(options ?? WidgetOptions$Mutation$ToggleFlareSolverr());
  return Mutation$ToggleFlareSolverr$HookResult(
    ({variables, optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables?.toJson() ?? const {},
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$ToggleFlareSolverr>
    useWatchMutation$ToggleFlareSolverr(
            [WatchOptions$Mutation$ToggleFlareSolverr? options]) =>
        graphql_flutter.useWatchMutation(
            options ?? WatchOptions$Mutation$ToggleFlareSolverr());

class WidgetOptions$Mutation$ToggleFlareSolverr
    extends graphql.MutationOptions<Mutation$ToggleFlareSolverr> {
  WidgetOptions$Mutation$ToggleFlareSolverr({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$ToggleFlareSolverr? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$ToggleFlareSolverr? onCompleted,
    graphql.OnMutationUpdate<Mutation$ToggleFlareSolverr>? update,
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
                        : _parserFn$Mutation$ToggleFlareSolverr(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationToggleFlareSolverr,
          parserFn: _parserFn$Mutation$ToggleFlareSolverr,
        );

  final OnMutationCompleted$Mutation$ToggleFlareSolverr? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$ToggleFlareSolverr
    = graphql.MultiSourceResult<Mutation$ToggleFlareSolverr> Function({
  Variables$Mutation$ToggleFlareSolverr? variables,
  Object? optimisticResult,
  Mutation$ToggleFlareSolverr? typedOptimisticResult,
});
typedef Builder$Mutation$ToggleFlareSolverr = widgets.Widget Function(
  RunMutation$Mutation$ToggleFlareSolverr,
  graphql.QueryResult<Mutation$ToggleFlareSolverr>?,
);

class Mutation$ToggleFlareSolverr$Widget
    extends graphql_flutter.Mutation<Mutation$ToggleFlareSolverr> {
  Mutation$ToggleFlareSolverr$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$ToggleFlareSolverr? options,
    required Builder$Mutation$ToggleFlareSolverr builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$ToggleFlareSolverr(),
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

class Mutation$ToggleFlareSolverr$setSettings {
  Mutation$ToggleFlareSolverr$setSettings({
    required this.settings,
    this.$__typename = 'SetSettingsPayload',
  });

  factory Mutation$ToggleFlareSolverr$setSettings.fromJson(
      Map<String, dynamic> json) {
    final l$settings = json['settings'];
    final l$$__typename = json['__typename'];
    return Mutation$ToggleFlareSolverr$setSettings(
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
    if (other is! Mutation$ToggleFlareSolverr$setSettings ||
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

extension UtilityExtension$Mutation$ToggleFlareSolverr$setSettings
    on Mutation$ToggleFlareSolverr$setSettings {
  CopyWith$Mutation$ToggleFlareSolverr$setSettings<
          Mutation$ToggleFlareSolverr$setSettings>
      get copyWith => CopyWith$Mutation$ToggleFlareSolverr$setSettings(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$ToggleFlareSolverr$setSettings<TRes> {
  factory CopyWith$Mutation$ToggleFlareSolverr$setSettings(
    Mutation$ToggleFlareSolverr$setSettings instance,
    TRes Function(Mutation$ToggleFlareSolverr$setSettings) then,
  ) = _CopyWithImpl$Mutation$ToggleFlareSolverr$setSettings;

  factory CopyWith$Mutation$ToggleFlareSolverr$setSettings.stub(TRes res) =
      _CopyWithStubImpl$Mutation$ToggleFlareSolverr$setSettings;

  TRes call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  });
  CopyWith$Fragment$SettingsDto<TRes> get settings;
}

class _CopyWithImpl$Mutation$ToggleFlareSolverr$setSettings<TRes>
    implements CopyWith$Mutation$ToggleFlareSolverr$setSettings<TRes> {
  _CopyWithImpl$Mutation$ToggleFlareSolverr$setSettings(
    this._instance,
    this._then,
  );

  final Mutation$ToggleFlareSolverr$setSettings _instance;

  final TRes Function(Mutation$ToggleFlareSolverr$setSettings) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? settings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$ToggleFlareSolverr$setSettings(
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

class _CopyWithStubImpl$Mutation$ToggleFlareSolverr$setSettings<TRes>
    implements CopyWith$Mutation$ToggleFlareSolverr$setSettings<TRes> {
  _CopyWithStubImpl$Mutation$ToggleFlareSolverr$setSettings(this._res);

  TRes _res;

  call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$SettingsDto<TRes> get settings =>
      CopyWith$Fragment$SettingsDto.stub(_res);
}

class Variables$Mutation$ToggleDebugLogs {
  factory Variables$Mutation$ToggleDebugLogs({bool? debugLogsEnabled}) =>
      Variables$Mutation$ToggleDebugLogs._({
        if (debugLogsEnabled != null) r'debugLogsEnabled': debugLogsEnabled,
      });

  Variables$Mutation$ToggleDebugLogs._(this._$data);

  factory Variables$Mutation$ToggleDebugLogs.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('debugLogsEnabled')) {
      final l$debugLogsEnabled = data['debugLogsEnabled'];
      result$data['debugLogsEnabled'] = (l$debugLogsEnabled as bool?);
    }
    return Variables$Mutation$ToggleDebugLogs._(result$data);
  }

  Map<String, dynamic> _$data;

  bool? get debugLogsEnabled => (_$data['debugLogsEnabled'] as bool?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('debugLogsEnabled')) {
      final l$debugLogsEnabled = debugLogsEnabled;
      result$data['debugLogsEnabled'] = l$debugLogsEnabled;
    }
    return result$data;
  }

  CopyWith$Variables$Mutation$ToggleDebugLogs<
          Variables$Mutation$ToggleDebugLogs>
      get copyWith => CopyWith$Variables$Mutation$ToggleDebugLogs(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$ToggleDebugLogs ||
        runtimeType != other.runtimeType) {
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
    return true;
  }

  @override
  int get hashCode {
    final l$debugLogsEnabled = debugLogsEnabled;
    return Object.hashAll([
      _$data.containsKey('debugLogsEnabled') ? l$debugLogsEnabled : const {}
    ]);
  }
}

abstract class CopyWith$Variables$Mutation$ToggleDebugLogs<TRes> {
  factory CopyWith$Variables$Mutation$ToggleDebugLogs(
    Variables$Mutation$ToggleDebugLogs instance,
    TRes Function(Variables$Mutation$ToggleDebugLogs) then,
  ) = _CopyWithImpl$Variables$Mutation$ToggleDebugLogs;

  factory CopyWith$Variables$Mutation$ToggleDebugLogs.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$ToggleDebugLogs;

  TRes call({bool? debugLogsEnabled});
}

class _CopyWithImpl$Variables$Mutation$ToggleDebugLogs<TRes>
    implements CopyWith$Variables$Mutation$ToggleDebugLogs<TRes> {
  _CopyWithImpl$Variables$Mutation$ToggleDebugLogs(
    this._instance,
    this._then,
  );

  final Variables$Mutation$ToggleDebugLogs _instance;

  final TRes Function(Variables$Mutation$ToggleDebugLogs) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? debugLogsEnabled = _undefined}) =>
      _then(Variables$Mutation$ToggleDebugLogs._({
        ..._instance._$data,
        if (debugLogsEnabled != _undefined)
          'debugLogsEnabled': (debugLogsEnabled as bool?),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$ToggleDebugLogs<TRes>
    implements CopyWith$Variables$Mutation$ToggleDebugLogs<TRes> {
  _CopyWithStubImpl$Variables$Mutation$ToggleDebugLogs(this._res);

  TRes _res;

  call({bool? debugLogsEnabled}) => _res;
}

class Mutation$ToggleDebugLogs {
  Mutation$ToggleDebugLogs({
    required this.setSettings,
    this.$__typename = 'Mutation',
  });

  factory Mutation$ToggleDebugLogs.fromJson(Map<String, dynamic> json) {
    final l$setSettings = json['setSettings'];
    final l$$__typename = json['__typename'];
    return Mutation$ToggleDebugLogs(
      setSettings: Mutation$ToggleDebugLogs$setSettings.fromJson(
          (l$setSettings as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$ToggleDebugLogs$setSettings setSettings;

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
    if (other is! Mutation$ToggleDebugLogs ||
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

extension UtilityExtension$Mutation$ToggleDebugLogs
    on Mutation$ToggleDebugLogs {
  CopyWith$Mutation$ToggleDebugLogs<Mutation$ToggleDebugLogs> get copyWith =>
      CopyWith$Mutation$ToggleDebugLogs(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Mutation$ToggleDebugLogs<TRes> {
  factory CopyWith$Mutation$ToggleDebugLogs(
    Mutation$ToggleDebugLogs instance,
    TRes Function(Mutation$ToggleDebugLogs) then,
  ) = _CopyWithImpl$Mutation$ToggleDebugLogs;

  factory CopyWith$Mutation$ToggleDebugLogs.stub(TRes res) =
      _CopyWithStubImpl$Mutation$ToggleDebugLogs;

  TRes call({
    Mutation$ToggleDebugLogs$setSettings? setSettings,
    String? $__typename,
  });
  CopyWith$Mutation$ToggleDebugLogs$setSettings<TRes> get setSettings;
}

class _CopyWithImpl$Mutation$ToggleDebugLogs<TRes>
    implements CopyWith$Mutation$ToggleDebugLogs<TRes> {
  _CopyWithImpl$Mutation$ToggleDebugLogs(
    this._instance,
    this._then,
  );

  final Mutation$ToggleDebugLogs _instance;

  final TRes Function(Mutation$ToggleDebugLogs) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? setSettings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$ToggleDebugLogs(
        setSettings: setSettings == _undefined || setSettings == null
            ? _instance.setSettings
            : (setSettings as Mutation$ToggleDebugLogs$setSettings),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$ToggleDebugLogs$setSettings<TRes> get setSettings {
    final local$setSettings = _instance.setSettings;
    return CopyWith$Mutation$ToggleDebugLogs$setSettings(
        local$setSettings, (e) => call(setSettings: e));
  }
}

class _CopyWithStubImpl$Mutation$ToggleDebugLogs<TRes>
    implements CopyWith$Mutation$ToggleDebugLogs<TRes> {
  _CopyWithStubImpl$Mutation$ToggleDebugLogs(this._res);

  TRes _res;

  call({
    Mutation$ToggleDebugLogs$setSettings? setSettings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$ToggleDebugLogs$setSettings<TRes> get setSettings =>
      CopyWith$Mutation$ToggleDebugLogs$setSettings.stub(_res);
}

const documentNodeMutationToggleDebugLogs = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'ToggleDebugLogs'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'debugLogsEnabled')),
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
                    name: NameNode(value: 'debugLogsEnabled'),
                    value:
                        VariableNode(name: NameNode(value: 'debugLogsEnabled')),
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
Mutation$ToggleDebugLogs _parserFn$Mutation$ToggleDebugLogs(
        Map<String, dynamic> data) =>
    Mutation$ToggleDebugLogs.fromJson(data);
typedef OnMutationCompleted$Mutation$ToggleDebugLogs = FutureOr<void> Function(
  Map<String, dynamic>?,
  Mutation$ToggleDebugLogs?,
);

class Options$Mutation$ToggleDebugLogs
    extends graphql.MutationOptions<Mutation$ToggleDebugLogs> {
  Options$Mutation$ToggleDebugLogs({
    String? operationName,
    Variables$Mutation$ToggleDebugLogs? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$ToggleDebugLogs? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$ToggleDebugLogs? onCompleted,
    graphql.OnMutationUpdate<Mutation$ToggleDebugLogs>? update,
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
                        : _parserFn$Mutation$ToggleDebugLogs(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationToggleDebugLogs,
          parserFn: _parserFn$Mutation$ToggleDebugLogs,
        );

  final OnMutationCompleted$Mutation$ToggleDebugLogs? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$ToggleDebugLogs
    extends graphql.WatchQueryOptions<Mutation$ToggleDebugLogs> {
  WatchOptions$Mutation$ToggleDebugLogs({
    String? operationName,
    Variables$Mutation$ToggleDebugLogs? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$ToggleDebugLogs? typedOptimisticResult,
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
          document: documentNodeMutationToggleDebugLogs,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$ToggleDebugLogs,
        );
}

extension ClientExtension$Mutation$ToggleDebugLogs on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$ToggleDebugLogs>> mutate$ToggleDebugLogs(
          [Options$Mutation$ToggleDebugLogs? options]) async =>
      await this.mutate(options ?? Options$Mutation$ToggleDebugLogs());

  graphql.ObservableQuery<
      Mutation$ToggleDebugLogs> watchMutation$ToggleDebugLogs(
          [WatchOptions$Mutation$ToggleDebugLogs? options]) =>
      this.watchMutation(options ?? WatchOptions$Mutation$ToggleDebugLogs());
}

class Mutation$ToggleDebugLogs$HookResult {
  Mutation$ToggleDebugLogs$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$ToggleDebugLogs runMutation;

  final graphql.QueryResult<Mutation$ToggleDebugLogs> result;
}

Mutation$ToggleDebugLogs$HookResult useMutation$ToggleDebugLogs(
    [WidgetOptions$Mutation$ToggleDebugLogs? options]) {
  final result = graphql_flutter
      .useMutation(options ?? WidgetOptions$Mutation$ToggleDebugLogs());
  return Mutation$ToggleDebugLogs$HookResult(
    ({variables, optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables?.toJson() ?? const {},
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$ToggleDebugLogs>
    useWatchMutation$ToggleDebugLogs(
            [WatchOptions$Mutation$ToggleDebugLogs? options]) =>
        graphql_flutter.useWatchMutation(
            options ?? WatchOptions$Mutation$ToggleDebugLogs());

class WidgetOptions$Mutation$ToggleDebugLogs
    extends graphql.MutationOptions<Mutation$ToggleDebugLogs> {
  WidgetOptions$Mutation$ToggleDebugLogs({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$ToggleDebugLogs? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$ToggleDebugLogs? onCompleted,
    graphql.OnMutationUpdate<Mutation$ToggleDebugLogs>? update,
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
                        : _parserFn$Mutation$ToggleDebugLogs(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationToggleDebugLogs,
          parserFn: _parserFn$Mutation$ToggleDebugLogs,
        );

  final OnMutationCompleted$Mutation$ToggleDebugLogs? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$ToggleDebugLogs
    = graphql.MultiSourceResult<Mutation$ToggleDebugLogs> Function({
  Variables$Mutation$ToggleDebugLogs? variables,
  Object? optimisticResult,
  Mutation$ToggleDebugLogs? typedOptimisticResult,
});
typedef Builder$Mutation$ToggleDebugLogs = widgets.Widget Function(
  RunMutation$Mutation$ToggleDebugLogs,
  graphql.QueryResult<Mutation$ToggleDebugLogs>?,
);

class Mutation$ToggleDebugLogs$Widget
    extends graphql_flutter.Mutation<Mutation$ToggleDebugLogs> {
  Mutation$ToggleDebugLogs$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$ToggleDebugLogs? options,
    required Builder$Mutation$ToggleDebugLogs builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$ToggleDebugLogs(),
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

class Mutation$ToggleDebugLogs$setSettings {
  Mutation$ToggleDebugLogs$setSettings({
    required this.settings,
    this.$__typename = 'SetSettingsPayload',
  });

  factory Mutation$ToggleDebugLogs$setSettings.fromJson(
      Map<String, dynamic> json) {
    final l$settings = json['settings'];
    final l$$__typename = json['__typename'];
    return Mutation$ToggleDebugLogs$setSettings(
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
    if (other is! Mutation$ToggleDebugLogs$setSettings ||
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

extension UtilityExtension$Mutation$ToggleDebugLogs$setSettings
    on Mutation$ToggleDebugLogs$setSettings {
  CopyWith$Mutation$ToggleDebugLogs$setSettings<
          Mutation$ToggleDebugLogs$setSettings>
      get copyWith => CopyWith$Mutation$ToggleDebugLogs$setSettings(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$ToggleDebugLogs$setSettings<TRes> {
  factory CopyWith$Mutation$ToggleDebugLogs$setSettings(
    Mutation$ToggleDebugLogs$setSettings instance,
    TRes Function(Mutation$ToggleDebugLogs$setSettings) then,
  ) = _CopyWithImpl$Mutation$ToggleDebugLogs$setSettings;

  factory CopyWith$Mutation$ToggleDebugLogs$setSettings.stub(TRes res) =
      _CopyWithStubImpl$Mutation$ToggleDebugLogs$setSettings;

  TRes call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  });
  CopyWith$Fragment$SettingsDto<TRes> get settings;
}

class _CopyWithImpl$Mutation$ToggleDebugLogs$setSettings<TRes>
    implements CopyWith$Mutation$ToggleDebugLogs$setSettings<TRes> {
  _CopyWithImpl$Mutation$ToggleDebugLogs$setSettings(
    this._instance,
    this._then,
  );

  final Mutation$ToggleDebugLogs$setSettings _instance;

  final TRes Function(Mutation$ToggleDebugLogs$setSettings) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? settings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$ToggleDebugLogs$setSettings(
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

class _CopyWithStubImpl$Mutation$ToggleDebugLogs$setSettings<TRes>
    implements CopyWith$Mutation$ToggleDebugLogs$setSettings<TRes> {
  _CopyWithStubImpl$Mutation$ToggleDebugLogs$setSettings(this._res);

  TRes _res;

  call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$SettingsDto<TRes> get settings =>
      CopyWith$Fragment$SettingsDto.stub(_res);
}
