import '../../../../../domain/settings/graphql/__generated__/fragment.graphql.dart';
import 'dart:async';
import 'package:flutter/widgets.dart' as widgets;
import 'package:gql/ast.dart';
import 'package:graphql/client.dart' as graphql;
import 'package:graphql_flutter/graphql_flutter.dart' as graphql_flutter;

class Variables$Mutation$UpdateDownloadsLocation {
  factory Variables$Mutation$UpdateDownloadsLocation(
          {required String downloadsPath}) =>
      Variables$Mutation$UpdateDownloadsLocation._({
        r'downloadsPath': downloadsPath,
      });

  Variables$Mutation$UpdateDownloadsLocation._(this._$data);

  factory Variables$Mutation$UpdateDownloadsLocation.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$downloadsPath = data['downloadsPath'];
    result$data['downloadsPath'] = (l$downloadsPath as String);
    return Variables$Mutation$UpdateDownloadsLocation._(result$data);
  }

  Map<String, dynamic> _$data;

  String get downloadsPath => (_$data['downloadsPath'] as String);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$downloadsPath = downloadsPath;
    result$data['downloadsPath'] = l$downloadsPath;
    return result$data;
  }

  CopyWith$Variables$Mutation$UpdateDownloadsLocation<
          Variables$Mutation$UpdateDownloadsLocation>
      get copyWith => CopyWith$Variables$Mutation$UpdateDownloadsLocation(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$UpdateDownloadsLocation ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$downloadsPath = downloadsPath;
    final lOther$downloadsPath = other.downloadsPath;
    if (l$downloadsPath != lOther$downloadsPath) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$downloadsPath = downloadsPath;
    return Object.hashAll([l$downloadsPath]);
  }
}

abstract class CopyWith$Variables$Mutation$UpdateDownloadsLocation<TRes> {
  factory CopyWith$Variables$Mutation$UpdateDownloadsLocation(
    Variables$Mutation$UpdateDownloadsLocation instance,
    TRes Function(Variables$Mutation$UpdateDownloadsLocation) then,
  ) = _CopyWithImpl$Variables$Mutation$UpdateDownloadsLocation;

  factory CopyWith$Variables$Mutation$UpdateDownloadsLocation.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$UpdateDownloadsLocation;

  TRes call({String? downloadsPath});
}

class _CopyWithImpl$Variables$Mutation$UpdateDownloadsLocation<TRes>
    implements CopyWith$Variables$Mutation$UpdateDownloadsLocation<TRes> {
  _CopyWithImpl$Variables$Mutation$UpdateDownloadsLocation(
    this._instance,
    this._then,
  );

  final Variables$Mutation$UpdateDownloadsLocation _instance;

  final TRes Function(Variables$Mutation$UpdateDownloadsLocation) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? downloadsPath = _undefined}) =>
      _then(Variables$Mutation$UpdateDownloadsLocation._({
        ..._instance._$data,
        if (downloadsPath != _undefined && downloadsPath != null)
          'downloadsPath': (downloadsPath as String),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$UpdateDownloadsLocation<TRes>
    implements CopyWith$Variables$Mutation$UpdateDownloadsLocation<TRes> {
  _CopyWithStubImpl$Variables$Mutation$UpdateDownloadsLocation(this._res);

  TRes _res;

  call({String? downloadsPath}) => _res;
}

class Mutation$UpdateDownloadsLocation {
  Mutation$UpdateDownloadsLocation({
    required this.setSettings,
    this.$__typename = 'Mutation',
  });

  factory Mutation$UpdateDownloadsLocation.fromJson(Map<String, dynamic> json) {
    final l$setSettings = json['setSettings'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateDownloadsLocation(
      setSettings: Mutation$UpdateDownloadsLocation$setSettings.fromJson(
          (l$setSettings as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$UpdateDownloadsLocation$setSettings setSettings;

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
    if (other is! Mutation$UpdateDownloadsLocation ||
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

extension UtilityExtension$Mutation$UpdateDownloadsLocation
    on Mutation$UpdateDownloadsLocation {
  CopyWith$Mutation$UpdateDownloadsLocation<Mutation$UpdateDownloadsLocation>
      get copyWith => CopyWith$Mutation$UpdateDownloadsLocation(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdateDownloadsLocation<TRes> {
  factory CopyWith$Mutation$UpdateDownloadsLocation(
    Mutation$UpdateDownloadsLocation instance,
    TRes Function(Mutation$UpdateDownloadsLocation) then,
  ) = _CopyWithImpl$Mutation$UpdateDownloadsLocation;

  factory CopyWith$Mutation$UpdateDownloadsLocation.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateDownloadsLocation;

  TRes call({
    Mutation$UpdateDownloadsLocation$setSettings? setSettings,
    String? $__typename,
  });
  CopyWith$Mutation$UpdateDownloadsLocation$setSettings<TRes> get setSettings;
}

class _CopyWithImpl$Mutation$UpdateDownloadsLocation<TRes>
    implements CopyWith$Mutation$UpdateDownloadsLocation<TRes> {
  _CopyWithImpl$Mutation$UpdateDownloadsLocation(
    this._instance,
    this._then,
  );

  final Mutation$UpdateDownloadsLocation _instance;

  final TRes Function(Mutation$UpdateDownloadsLocation) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? setSettings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateDownloadsLocation(
        setSettings: setSettings == _undefined || setSettings == null
            ? _instance.setSettings
            : (setSettings as Mutation$UpdateDownloadsLocation$setSettings),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$UpdateDownloadsLocation$setSettings<TRes> get setSettings {
    final local$setSettings = _instance.setSettings;
    return CopyWith$Mutation$UpdateDownloadsLocation$setSettings(
        local$setSettings, (e) => call(setSettings: e));
  }
}

class _CopyWithStubImpl$Mutation$UpdateDownloadsLocation<TRes>
    implements CopyWith$Mutation$UpdateDownloadsLocation<TRes> {
  _CopyWithStubImpl$Mutation$UpdateDownloadsLocation(this._res);

  TRes _res;

  call({
    Mutation$UpdateDownloadsLocation$setSettings? setSettings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$UpdateDownloadsLocation$setSettings<TRes> get setSettings =>
      CopyWith$Mutation$UpdateDownloadsLocation$setSettings.stub(_res);
}

const documentNodeMutationUpdateDownloadsLocation = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'UpdateDownloadsLocation'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'downloadsPath')),
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
                    name: NameNode(value: 'downloadsPath'),
                    value: VariableNode(name: NameNode(value: 'downloadsPath')),
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
Mutation$UpdateDownloadsLocation _parserFn$Mutation$UpdateDownloadsLocation(
        Map<String, dynamic> data) =>
    Mutation$UpdateDownloadsLocation.fromJson(data);
typedef OnMutationCompleted$Mutation$UpdateDownloadsLocation = FutureOr<void>
    Function(
  Map<String, dynamic>?,
  Mutation$UpdateDownloadsLocation?,
);

class Options$Mutation$UpdateDownloadsLocation
    extends graphql.MutationOptions<Mutation$UpdateDownloadsLocation> {
  Options$Mutation$UpdateDownloadsLocation({
    String? operationName,
    required Variables$Mutation$UpdateDownloadsLocation variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateDownloadsLocation? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateDownloadsLocation? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateDownloadsLocation>? update,
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
                        : _parserFn$Mutation$UpdateDownloadsLocation(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateDownloadsLocation,
          parserFn: _parserFn$Mutation$UpdateDownloadsLocation,
        );

  final OnMutationCompleted$Mutation$UpdateDownloadsLocation?
      onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$UpdateDownloadsLocation
    extends graphql.WatchQueryOptions<Mutation$UpdateDownloadsLocation> {
  WatchOptions$Mutation$UpdateDownloadsLocation({
    String? operationName,
    required Variables$Mutation$UpdateDownloadsLocation variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateDownloadsLocation? typedOptimisticResult,
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
          document: documentNodeMutationUpdateDownloadsLocation,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$UpdateDownloadsLocation,
        );
}

extension ClientExtension$Mutation$UpdateDownloadsLocation
    on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$UpdateDownloadsLocation>>
      mutate$UpdateDownloadsLocation(
              Options$Mutation$UpdateDownloadsLocation options) async =>
          await this.mutate(options);

  graphql.ObservableQuery<Mutation$UpdateDownloadsLocation>
      watchMutation$UpdateDownloadsLocation(
              WatchOptions$Mutation$UpdateDownloadsLocation options) =>
          this.watchMutation(options);
}

class Mutation$UpdateDownloadsLocation$HookResult {
  Mutation$UpdateDownloadsLocation$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$UpdateDownloadsLocation runMutation;

  final graphql.QueryResult<Mutation$UpdateDownloadsLocation> result;
}

Mutation$UpdateDownloadsLocation$HookResult useMutation$UpdateDownloadsLocation(
    [WidgetOptions$Mutation$UpdateDownloadsLocation? options]) {
  final result = graphql_flutter
      .useMutation(options ?? WidgetOptions$Mutation$UpdateDownloadsLocation());
  return Mutation$UpdateDownloadsLocation$HookResult(
    (variables, {optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables.toJson(),
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$UpdateDownloadsLocation>
    useWatchMutation$UpdateDownloadsLocation(
            WatchOptions$Mutation$UpdateDownloadsLocation options) =>
        graphql_flutter.useWatchMutation(options);

class WidgetOptions$Mutation$UpdateDownloadsLocation
    extends graphql.MutationOptions<Mutation$UpdateDownloadsLocation> {
  WidgetOptions$Mutation$UpdateDownloadsLocation({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateDownloadsLocation? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateDownloadsLocation? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateDownloadsLocation>? update,
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
                        : _parserFn$Mutation$UpdateDownloadsLocation(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateDownloadsLocation,
          parserFn: _parserFn$Mutation$UpdateDownloadsLocation,
        );

  final OnMutationCompleted$Mutation$UpdateDownloadsLocation?
      onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$UpdateDownloadsLocation
    = graphql.MultiSourceResult<Mutation$UpdateDownloadsLocation> Function(
  Variables$Mutation$UpdateDownloadsLocation, {
  Object? optimisticResult,
  Mutation$UpdateDownloadsLocation? typedOptimisticResult,
});
typedef Builder$Mutation$UpdateDownloadsLocation = widgets.Widget Function(
  RunMutation$Mutation$UpdateDownloadsLocation,
  graphql.QueryResult<Mutation$UpdateDownloadsLocation>?,
);

class Mutation$UpdateDownloadsLocation$Widget
    extends graphql_flutter.Mutation<Mutation$UpdateDownloadsLocation> {
  Mutation$UpdateDownloadsLocation$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$UpdateDownloadsLocation? options,
    required Builder$Mutation$UpdateDownloadsLocation builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$UpdateDownloadsLocation(),
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

class Mutation$UpdateDownloadsLocation$setSettings {
  Mutation$UpdateDownloadsLocation$setSettings({
    required this.settings,
    this.$__typename = 'SetSettingsPayload',
  });

  factory Mutation$UpdateDownloadsLocation$setSettings.fromJson(
      Map<String, dynamic> json) {
    final l$settings = json['settings'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateDownloadsLocation$setSettings(
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
    if (other is! Mutation$UpdateDownloadsLocation$setSettings ||
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

extension UtilityExtension$Mutation$UpdateDownloadsLocation$setSettings
    on Mutation$UpdateDownloadsLocation$setSettings {
  CopyWith$Mutation$UpdateDownloadsLocation$setSettings<
          Mutation$UpdateDownloadsLocation$setSettings>
      get copyWith => CopyWith$Mutation$UpdateDownloadsLocation$setSettings(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdateDownloadsLocation$setSettings<TRes> {
  factory CopyWith$Mutation$UpdateDownloadsLocation$setSettings(
    Mutation$UpdateDownloadsLocation$setSettings instance,
    TRes Function(Mutation$UpdateDownloadsLocation$setSettings) then,
  ) = _CopyWithImpl$Mutation$UpdateDownloadsLocation$setSettings;

  factory CopyWith$Mutation$UpdateDownloadsLocation$setSettings.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateDownloadsLocation$setSettings;

  TRes call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  });
  CopyWith$Fragment$SettingsDto<TRes> get settings;
}

class _CopyWithImpl$Mutation$UpdateDownloadsLocation$setSettings<TRes>
    implements CopyWith$Mutation$UpdateDownloadsLocation$setSettings<TRes> {
  _CopyWithImpl$Mutation$UpdateDownloadsLocation$setSettings(
    this._instance,
    this._then,
  );

  final Mutation$UpdateDownloadsLocation$setSettings _instance;

  final TRes Function(Mutation$UpdateDownloadsLocation$setSettings) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? settings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateDownloadsLocation$setSettings(
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

class _CopyWithStubImpl$Mutation$UpdateDownloadsLocation$setSettings<TRes>
    implements CopyWith$Mutation$UpdateDownloadsLocation$setSettings<TRes> {
  _CopyWithStubImpl$Mutation$UpdateDownloadsLocation$setSettings(this._res);

  TRes _res;

  call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$SettingsDto<TRes> get settings =>
      CopyWith$Fragment$SettingsDto.stub(_res);
}

class Variables$Mutation$UpdateDownloadAsCbz {
  factory Variables$Mutation$UpdateDownloadAsCbz({bool? downloadAsCbz}) =>
      Variables$Mutation$UpdateDownloadAsCbz._({
        if (downloadAsCbz != null) r'downloadAsCbz': downloadAsCbz,
      });

  Variables$Mutation$UpdateDownloadAsCbz._(this._$data);

  factory Variables$Mutation$UpdateDownloadAsCbz.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('downloadAsCbz')) {
      final l$downloadAsCbz = data['downloadAsCbz'];
      result$data['downloadAsCbz'] = (l$downloadAsCbz as bool?);
    }
    return Variables$Mutation$UpdateDownloadAsCbz._(result$data);
  }

  Map<String, dynamic> _$data;

  bool? get downloadAsCbz => (_$data['downloadAsCbz'] as bool?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('downloadAsCbz')) {
      final l$downloadAsCbz = downloadAsCbz;
      result$data['downloadAsCbz'] = l$downloadAsCbz;
    }
    return result$data;
  }

  CopyWith$Variables$Mutation$UpdateDownloadAsCbz<
          Variables$Mutation$UpdateDownloadAsCbz>
      get copyWith => CopyWith$Variables$Mutation$UpdateDownloadAsCbz(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$UpdateDownloadAsCbz ||
        runtimeType != other.runtimeType) {
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
    return true;
  }

  @override
  int get hashCode {
    final l$downloadAsCbz = downloadAsCbz;
    return Object.hashAll(
        [_$data.containsKey('downloadAsCbz') ? l$downloadAsCbz : const {}]);
  }
}

abstract class CopyWith$Variables$Mutation$UpdateDownloadAsCbz<TRes> {
  factory CopyWith$Variables$Mutation$UpdateDownloadAsCbz(
    Variables$Mutation$UpdateDownloadAsCbz instance,
    TRes Function(Variables$Mutation$UpdateDownloadAsCbz) then,
  ) = _CopyWithImpl$Variables$Mutation$UpdateDownloadAsCbz;

  factory CopyWith$Variables$Mutation$UpdateDownloadAsCbz.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$UpdateDownloadAsCbz;

  TRes call({bool? downloadAsCbz});
}

class _CopyWithImpl$Variables$Mutation$UpdateDownloadAsCbz<TRes>
    implements CopyWith$Variables$Mutation$UpdateDownloadAsCbz<TRes> {
  _CopyWithImpl$Variables$Mutation$UpdateDownloadAsCbz(
    this._instance,
    this._then,
  );

  final Variables$Mutation$UpdateDownloadAsCbz _instance;

  final TRes Function(Variables$Mutation$UpdateDownloadAsCbz) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? downloadAsCbz = _undefined}) =>
      _then(Variables$Mutation$UpdateDownloadAsCbz._({
        ..._instance._$data,
        if (downloadAsCbz != _undefined)
          'downloadAsCbz': (downloadAsCbz as bool?),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$UpdateDownloadAsCbz<TRes>
    implements CopyWith$Variables$Mutation$UpdateDownloadAsCbz<TRes> {
  _CopyWithStubImpl$Variables$Mutation$UpdateDownloadAsCbz(this._res);

  TRes _res;

  call({bool? downloadAsCbz}) => _res;
}

class Mutation$UpdateDownloadAsCbz {
  Mutation$UpdateDownloadAsCbz({
    required this.setSettings,
    this.$__typename = 'Mutation',
  });

  factory Mutation$UpdateDownloadAsCbz.fromJson(Map<String, dynamic> json) {
    final l$setSettings = json['setSettings'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateDownloadAsCbz(
      setSettings: Mutation$UpdateDownloadAsCbz$setSettings.fromJson(
          (l$setSettings as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$UpdateDownloadAsCbz$setSettings setSettings;

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
    if (other is! Mutation$UpdateDownloadAsCbz ||
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

extension UtilityExtension$Mutation$UpdateDownloadAsCbz
    on Mutation$UpdateDownloadAsCbz {
  CopyWith$Mutation$UpdateDownloadAsCbz<Mutation$UpdateDownloadAsCbz>
      get copyWith => CopyWith$Mutation$UpdateDownloadAsCbz(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdateDownloadAsCbz<TRes> {
  factory CopyWith$Mutation$UpdateDownloadAsCbz(
    Mutation$UpdateDownloadAsCbz instance,
    TRes Function(Mutation$UpdateDownloadAsCbz) then,
  ) = _CopyWithImpl$Mutation$UpdateDownloadAsCbz;

  factory CopyWith$Mutation$UpdateDownloadAsCbz.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateDownloadAsCbz;

  TRes call({
    Mutation$UpdateDownloadAsCbz$setSettings? setSettings,
    String? $__typename,
  });
  CopyWith$Mutation$UpdateDownloadAsCbz$setSettings<TRes> get setSettings;
}

class _CopyWithImpl$Mutation$UpdateDownloadAsCbz<TRes>
    implements CopyWith$Mutation$UpdateDownloadAsCbz<TRes> {
  _CopyWithImpl$Mutation$UpdateDownloadAsCbz(
    this._instance,
    this._then,
  );

  final Mutation$UpdateDownloadAsCbz _instance;

  final TRes Function(Mutation$UpdateDownloadAsCbz) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? setSettings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateDownloadAsCbz(
        setSettings: setSettings == _undefined || setSettings == null
            ? _instance.setSettings
            : (setSettings as Mutation$UpdateDownloadAsCbz$setSettings),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$UpdateDownloadAsCbz$setSettings<TRes> get setSettings {
    final local$setSettings = _instance.setSettings;
    return CopyWith$Mutation$UpdateDownloadAsCbz$setSettings(
        local$setSettings, (e) => call(setSettings: e));
  }
}

class _CopyWithStubImpl$Mutation$UpdateDownloadAsCbz<TRes>
    implements CopyWith$Mutation$UpdateDownloadAsCbz<TRes> {
  _CopyWithStubImpl$Mutation$UpdateDownloadAsCbz(this._res);

  TRes _res;

  call({
    Mutation$UpdateDownloadAsCbz$setSettings? setSettings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$UpdateDownloadAsCbz$setSettings<TRes> get setSettings =>
      CopyWith$Mutation$UpdateDownloadAsCbz$setSettings.stub(_res);
}

const documentNodeMutationUpdateDownloadAsCbz = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'UpdateDownloadAsCbz'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'downloadAsCbz')),
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
                    name: NameNode(value: 'downloadAsCbz'),
                    value: VariableNode(name: NameNode(value: 'downloadAsCbz')),
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
Mutation$UpdateDownloadAsCbz _parserFn$Mutation$UpdateDownloadAsCbz(
        Map<String, dynamic> data) =>
    Mutation$UpdateDownloadAsCbz.fromJson(data);
typedef OnMutationCompleted$Mutation$UpdateDownloadAsCbz = FutureOr<void>
    Function(
  Map<String, dynamic>?,
  Mutation$UpdateDownloadAsCbz?,
);

class Options$Mutation$UpdateDownloadAsCbz
    extends graphql.MutationOptions<Mutation$UpdateDownloadAsCbz> {
  Options$Mutation$UpdateDownloadAsCbz({
    String? operationName,
    Variables$Mutation$UpdateDownloadAsCbz? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateDownloadAsCbz? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateDownloadAsCbz? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateDownloadAsCbz>? update,
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
                        : _parserFn$Mutation$UpdateDownloadAsCbz(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateDownloadAsCbz,
          parserFn: _parserFn$Mutation$UpdateDownloadAsCbz,
        );

  final OnMutationCompleted$Mutation$UpdateDownloadAsCbz? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$UpdateDownloadAsCbz
    extends graphql.WatchQueryOptions<Mutation$UpdateDownloadAsCbz> {
  WatchOptions$Mutation$UpdateDownloadAsCbz({
    String? operationName,
    Variables$Mutation$UpdateDownloadAsCbz? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateDownloadAsCbz? typedOptimisticResult,
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
          document: documentNodeMutationUpdateDownloadAsCbz,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$UpdateDownloadAsCbz,
        );
}

extension ClientExtension$Mutation$UpdateDownloadAsCbz
    on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$UpdateDownloadAsCbz>>
      mutate$UpdateDownloadAsCbz(
              [Options$Mutation$UpdateDownloadAsCbz? options]) async =>
          await this.mutate(options ?? Options$Mutation$UpdateDownloadAsCbz());

  graphql.ObservableQuery<Mutation$UpdateDownloadAsCbz>
      watchMutation$UpdateDownloadAsCbz(
              [WatchOptions$Mutation$UpdateDownloadAsCbz? options]) =>
          this.watchMutation(
              options ?? WatchOptions$Mutation$UpdateDownloadAsCbz());
}

class Mutation$UpdateDownloadAsCbz$HookResult {
  Mutation$UpdateDownloadAsCbz$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$UpdateDownloadAsCbz runMutation;

  final graphql.QueryResult<Mutation$UpdateDownloadAsCbz> result;
}

Mutation$UpdateDownloadAsCbz$HookResult useMutation$UpdateDownloadAsCbz(
    [WidgetOptions$Mutation$UpdateDownloadAsCbz? options]) {
  final result = graphql_flutter
      .useMutation(options ?? WidgetOptions$Mutation$UpdateDownloadAsCbz());
  return Mutation$UpdateDownloadAsCbz$HookResult(
    ({variables, optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables?.toJson() ?? const {},
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$UpdateDownloadAsCbz>
    useWatchMutation$UpdateDownloadAsCbz(
            [WatchOptions$Mutation$UpdateDownloadAsCbz? options]) =>
        graphql_flutter.useWatchMutation(
            options ?? WatchOptions$Mutation$UpdateDownloadAsCbz());

class WidgetOptions$Mutation$UpdateDownloadAsCbz
    extends graphql.MutationOptions<Mutation$UpdateDownloadAsCbz> {
  WidgetOptions$Mutation$UpdateDownloadAsCbz({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateDownloadAsCbz? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateDownloadAsCbz? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateDownloadAsCbz>? update,
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
                        : _parserFn$Mutation$UpdateDownloadAsCbz(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateDownloadAsCbz,
          parserFn: _parserFn$Mutation$UpdateDownloadAsCbz,
        );

  final OnMutationCompleted$Mutation$UpdateDownloadAsCbz? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$UpdateDownloadAsCbz
    = graphql.MultiSourceResult<Mutation$UpdateDownloadAsCbz> Function({
  Variables$Mutation$UpdateDownloadAsCbz? variables,
  Object? optimisticResult,
  Mutation$UpdateDownloadAsCbz? typedOptimisticResult,
});
typedef Builder$Mutation$UpdateDownloadAsCbz = widgets.Widget Function(
  RunMutation$Mutation$UpdateDownloadAsCbz,
  graphql.QueryResult<Mutation$UpdateDownloadAsCbz>?,
);

class Mutation$UpdateDownloadAsCbz$Widget
    extends graphql_flutter.Mutation<Mutation$UpdateDownloadAsCbz> {
  Mutation$UpdateDownloadAsCbz$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$UpdateDownloadAsCbz? options,
    required Builder$Mutation$UpdateDownloadAsCbz builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$UpdateDownloadAsCbz(),
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

class Mutation$UpdateDownloadAsCbz$setSettings {
  Mutation$UpdateDownloadAsCbz$setSettings({
    required this.settings,
    this.$__typename = 'SetSettingsPayload',
  });

  factory Mutation$UpdateDownloadAsCbz$setSettings.fromJson(
      Map<String, dynamic> json) {
    final l$settings = json['settings'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateDownloadAsCbz$setSettings(
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
    if (other is! Mutation$UpdateDownloadAsCbz$setSettings ||
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

extension UtilityExtension$Mutation$UpdateDownloadAsCbz$setSettings
    on Mutation$UpdateDownloadAsCbz$setSettings {
  CopyWith$Mutation$UpdateDownloadAsCbz$setSettings<
          Mutation$UpdateDownloadAsCbz$setSettings>
      get copyWith => CopyWith$Mutation$UpdateDownloadAsCbz$setSettings(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdateDownloadAsCbz$setSettings<TRes> {
  factory CopyWith$Mutation$UpdateDownloadAsCbz$setSettings(
    Mutation$UpdateDownloadAsCbz$setSettings instance,
    TRes Function(Mutation$UpdateDownloadAsCbz$setSettings) then,
  ) = _CopyWithImpl$Mutation$UpdateDownloadAsCbz$setSettings;

  factory CopyWith$Mutation$UpdateDownloadAsCbz$setSettings.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateDownloadAsCbz$setSettings;

  TRes call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  });
  CopyWith$Fragment$SettingsDto<TRes> get settings;
}

class _CopyWithImpl$Mutation$UpdateDownloadAsCbz$setSettings<TRes>
    implements CopyWith$Mutation$UpdateDownloadAsCbz$setSettings<TRes> {
  _CopyWithImpl$Mutation$UpdateDownloadAsCbz$setSettings(
    this._instance,
    this._then,
  );

  final Mutation$UpdateDownloadAsCbz$setSettings _instance;

  final TRes Function(Mutation$UpdateDownloadAsCbz$setSettings) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? settings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateDownloadAsCbz$setSettings(
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

class _CopyWithStubImpl$Mutation$UpdateDownloadAsCbz$setSettings<TRes>
    implements CopyWith$Mutation$UpdateDownloadAsCbz$setSettings<TRes> {
  _CopyWithStubImpl$Mutation$UpdateDownloadAsCbz$setSettings(this._res);

  TRes _res;

  call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$SettingsDto<TRes> get settings =>
      CopyWith$Fragment$SettingsDto.stub(_res);
}

class Variables$Mutation$UpdateAutoDownloadNewChaptersLimit {
  factory Variables$Mutation$UpdateAutoDownloadNewChaptersLimit(
          {int? autoDownloadNewChaptersLimit}) =>
      Variables$Mutation$UpdateAutoDownloadNewChaptersLimit._({
        if (autoDownloadNewChaptersLimit != null)
          r'autoDownloadNewChaptersLimit': autoDownloadNewChaptersLimit,
      });

  Variables$Mutation$UpdateAutoDownloadNewChaptersLimit._(this._$data);

  factory Variables$Mutation$UpdateAutoDownloadNewChaptersLimit.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('autoDownloadNewChaptersLimit')) {
      final l$autoDownloadNewChaptersLimit =
          data['autoDownloadNewChaptersLimit'];
      result$data['autoDownloadNewChaptersLimit'] =
          (l$autoDownloadNewChaptersLimit as int?);
    }
    return Variables$Mutation$UpdateAutoDownloadNewChaptersLimit._(result$data);
  }

  Map<String, dynamic> _$data;

  int? get autoDownloadNewChaptersLimit =>
      (_$data['autoDownloadNewChaptersLimit'] as int?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('autoDownloadNewChaptersLimit')) {
      final l$autoDownloadNewChaptersLimit = autoDownloadNewChaptersLimit;
      result$data['autoDownloadNewChaptersLimit'] =
          l$autoDownloadNewChaptersLimit;
    }
    return result$data;
  }

  CopyWith$Variables$Mutation$UpdateAutoDownloadNewChaptersLimit<
          Variables$Mutation$UpdateAutoDownloadNewChaptersLimit>
      get copyWith =>
          CopyWith$Variables$Mutation$UpdateAutoDownloadNewChaptersLimit(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$UpdateAutoDownloadNewChaptersLimit ||
        runtimeType != other.runtimeType) {
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
    return true;
  }

  @override
  int get hashCode {
    final l$autoDownloadNewChaptersLimit = autoDownloadNewChaptersLimit;
    return Object.hashAll([
      _$data.containsKey('autoDownloadNewChaptersLimit')
          ? l$autoDownloadNewChaptersLimit
          : const {}
    ]);
  }
}

abstract class CopyWith$Variables$Mutation$UpdateAutoDownloadNewChaptersLimit<
    TRes> {
  factory CopyWith$Variables$Mutation$UpdateAutoDownloadNewChaptersLimit(
    Variables$Mutation$UpdateAutoDownloadNewChaptersLimit instance,
    TRes Function(Variables$Mutation$UpdateAutoDownloadNewChaptersLimit) then,
  ) = _CopyWithImpl$Variables$Mutation$UpdateAutoDownloadNewChaptersLimit;

  factory CopyWith$Variables$Mutation$UpdateAutoDownloadNewChaptersLimit.stub(
          TRes res) =
      _CopyWithStubImpl$Variables$Mutation$UpdateAutoDownloadNewChaptersLimit;

  TRes call({int? autoDownloadNewChaptersLimit});
}

class _CopyWithImpl$Variables$Mutation$UpdateAutoDownloadNewChaptersLimit<TRes>
    implements
        CopyWith$Variables$Mutation$UpdateAutoDownloadNewChaptersLimit<TRes> {
  _CopyWithImpl$Variables$Mutation$UpdateAutoDownloadNewChaptersLimit(
    this._instance,
    this._then,
  );

  final Variables$Mutation$UpdateAutoDownloadNewChaptersLimit _instance;

  final TRes Function(Variables$Mutation$UpdateAutoDownloadNewChaptersLimit)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? autoDownloadNewChaptersLimit = _undefined}) =>
      _then(Variables$Mutation$UpdateAutoDownloadNewChaptersLimit._({
        ..._instance._$data,
        if (autoDownloadNewChaptersLimit != _undefined)
          'autoDownloadNewChaptersLimit':
              (autoDownloadNewChaptersLimit as int?),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$UpdateAutoDownloadNewChaptersLimit<
        TRes>
    implements
        CopyWith$Variables$Mutation$UpdateAutoDownloadNewChaptersLimit<TRes> {
  _CopyWithStubImpl$Variables$Mutation$UpdateAutoDownloadNewChaptersLimit(
      this._res);

  TRes _res;

  call({int? autoDownloadNewChaptersLimit}) => _res;
}

class Mutation$UpdateAutoDownloadNewChaptersLimit {
  Mutation$UpdateAutoDownloadNewChaptersLimit({
    required this.setSettings,
    this.$__typename = 'Mutation',
  });

  factory Mutation$UpdateAutoDownloadNewChaptersLimit.fromJson(
      Map<String, dynamic> json) {
    final l$setSettings = json['setSettings'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateAutoDownloadNewChaptersLimit(
      setSettings:
          Mutation$UpdateAutoDownloadNewChaptersLimit$setSettings.fromJson(
              (l$setSettings as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$UpdateAutoDownloadNewChaptersLimit$setSettings setSettings;

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
    if (other is! Mutation$UpdateAutoDownloadNewChaptersLimit ||
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

extension UtilityExtension$Mutation$UpdateAutoDownloadNewChaptersLimit
    on Mutation$UpdateAutoDownloadNewChaptersLimit {
  CopyWith$Mutation$UpdateAutoDownloadNewChaptersLimit<
          Mutation$UpdateAutoDownloadNewChaptersLimit>
      get copyWith => CopyWith$Mutation$UpdateAutoDownloadNewChaptersLimit(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdateAutoDownloadNewChaptersLimit<TRes> {
  factory CopyWith$Mutation$UpdateAutoDownloadNewChaptersLimit(
    Mutation$UpdateAutoDownloadNewChaptersLimit instance,
    TRes Function(Mutation$UpdateAutoDownloadNewChaptersLimit) then,
  ) = _CopyWithImpl$Mutation$UpdateAutoDownloadNewChaptersLimit;

  factory CopyWith$Mutation$UpdateAutoDownloadNewChaptersLimit.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateAutoDownloadNewChaptersLimit;

  TRes call({
    Mutation$UpdateAutoDownloadNewChaptersLimit$setSettings? setSettings,
    String? $__typename,
  });
  CopyWith$Mutation$UpdateAutoDownloadNewChaptersLimit$setSettings<TRes>
      get setSettings;
}

class _CopyWithImpl$Mutation$UpdateAutoDownloadNewChaptersLimit<TRes>
    implements CopyWith$Mutation$UpdateAutoDownloadNewChaptersLimit<TRes> {
  _CopyWithImpl$Mutation$UpdateAutoDownloadNewChaptersLimit(
    this._instance,
    this._then,
  );

  final Mutation$UpdateAutoDownloadNewChaptersLimit _instance;

  final TRes Function(Mutation$UpdateAutoDownloadNewChaptersLimit) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? setSettings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateAutoDownloadNewChaptersLimit(
        setSettings: setSettings == _undefined || setSettings == null
            ? _instance.setSettings
            : (setSettings
                as Mutation$UpdateAutoDownloadNewChaptersLimit$setSettings),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$UpdateAutoDownloadNewChaptersLimit$setSettings<TRes>
      get setSettings {
    final local$setSettings = _instance.setSettings;
    return CopyWith$Mutation$UpdateAutoDownloadNewChaptersLimit$setSettings(
        local$setSettings, (e) => call(setSettings: e));
  }
}

class _CopyWithStubImpl$Mutation$UpdateAutoDownloadNewChaptersLimit<TRes>
    implements CopyWith$Mutation$UpdateAutoDownloadNewChaptersLimit<TRes> {
  _CopyWithStubImpl$Mutation$UpdateAutoDownloadNewChaptersLimit(this._res);

  TRes _res;

  call({
    Mutation$UpdateAutoDownloadNewChaptersLimit$setSettings? setSettings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$UpdateAutoDownloadNewChaptersLimit$setSettings<TRes>
      get setSettings =>
          CopyWith$Mutation$UpdateAutoDownloadNewChaptersLimit$setSettings.stub(
              _res);
}

const documentNodeMutationUpdateAutoDownloadNewChaptersLimit =
    DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'UpdateAutoDownloadNewChaptersLimit'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable:
            VariableNode(name: NameNode(value: 'autoDownloadNewChaptersLimit')),
        type: NamedTypeNode(
          name: NameNode(value: 'Int'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: IntValueNode(value: '3')),
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
                    name: NameNode(value: 'autoDownloadNewChaptersLimit'),
                    value: VariableNode(
                        name: NameNode(value: 'autoDownloadNewChaptersLimit')),
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
Mutation$UpdateAutoDownloadNewChaptersLimit
    _parserFn$Mutation$UpdateAutoDownloadNewChaptersLimit(
            Map<String, dynamic> data) =>
        Mutation$UpdateAutoDownloadNewChaptersLimit.fromJson(data);
typedef OnMutationCompleted$Mutation$UpdateAutoDownloadNewChaptersLimit
    = FutureOr<void> Function(
  Map<String, dynamic>?,
  Mutation$UpdateAutoDownloadNewChaptersLimit?,
);

class Options$Mutation$UpdateAutoDownloadNewChaptersLimit extends graphql
    .MutationOptions<Mutation$UpdateAutoDownloadNewChaptersLimit> {
  Options$Mutation$UpdateAutoDownloadNewChaptersLimit({
    String? operationName,
    Variables$Mutation$UpdateAutoDownloadNewChaptersLimit? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateAutoDownloadNewChaptersLimit? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateAutoDownloadNewChaptersLimit?
        onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateAutoDownloadNewChaptersLimit>?
        update,
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
                        : _parserFn$Mutation$UpdateAutoDownloadNewChaptersLimit(
                            data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateAutoDownloadNewChaptersLimit,
          parserFn: _parserFn$Mutation$UpdateAutoDownloadNewChaptersLimit,
        );

  final OnMutationCompleted$Mutation$UpdateAutoDownloadNewChaptersLimit?
      onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$UpdateAutoDownloadNewChaptersLimit extends graphql
    .WatchQueryOptions<Mutation$UpdateAutoDownloadNewChaptersLimit> {
  WatchOptions$Mutation$UpdateAutoDownloadNewChaptersLimit({
    String? operationName,
    Variables$Mutation$UpdateAutoDownloadNewChaptersLimit? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateAutoDownloadNewChaptersLimit? typedOptimisticResult,
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
          document: documentNodeMutationUpdateAutoDownloadNewChaptersLimit,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$UpdateAutoDownloadNewChaptersLimit,
        );
}

extension ClientExtension$Mutation$UpdateAutoDownloadNewChaptersLimit
    on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$UpdateAutoDownloadNewChaptersLimit>>
      mutate$UpdateAutoDownloadNewChaptersLimit(
              [Options$Mutation$UpdateAutoDownloadNewChaptersLimit?
                  options]) async =>
          await this.mutate(
              options ?? Options$Mutation$UpdateAutoDownloadNewChaptersLimit());

  graphql.ObservableQuery<Mutation$UpdateAutoDownloadNewChaptersLimit>
      watchMutation$UpdateAutoDownloadNewChaptersLimit(
              [WatchOptions$Mutation$UpdateAutoDownloadNewChaptersLimit?
                  options]) =>
          this.watchMutation(options ??
              WatchOptions$Mutation$UpdateAutoDownloadNewChaptersLimit());
}

class Mutation$UpdateAutoDownloadNewChaptersLimit$HookResult {
  Mutation$UpdateAutoDownloadNewChaptersLimit$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$UpdateAutoDownloadNewChaptersLimit runMutation;

  final graphql.QueryResult<Mutation$UpdateAutoDownloadNewChaptersLimit> result;
}

Mutation$UpdateAutoDownloadNewChaptersLimit$HookResult
    useMutation$UpdateAutoDownloadNewChaptersLimit(
        [WidgetOptions$Mutation$UpdateAutoDownloadNewChaptersLimit? options]) {
  final result = graphql_flutter.useMutation(
      options ?? WidgetOptions$Mutation$UpdateAutoDownloadNewChaptersLimit());
  return Mutation$UpdateAutoDownloadNewChaptersLimit$HookResult(
    ({variables, optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables?.toJson() ?? const {},
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$UpdateAutoDownloadNewChaptersLimit>
    useWatchMutation$UpdateAutoDownloadNewChaptersLimit(
            [WatchOptions$Mutation$UpdateAutoDownloadNewChaptersLimit?
                options]) =>
        graphql_flutter.useWatchMutation(options ??
            WatchOptions$Mutation$UpdateAutoDownloadNewChaptersLimit());

class WidgetOptions$Mutation$UpdateAutoDownloadNewChaptersLimit extends graphql
    .MutationOptions<Mutation$UpdateAutoDownloadNewChaptersLimit> {
  WidgetOptions$Mutation$UpdateAutoDownloadNewChaptersLimit({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateAutoDownloadNewChaptersLimit? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateAutoDownloadNewChaptersLimit?
        onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateAutoDownloadNewChaptersLimit>?
        update,
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
                        : _parserFn$Mutation$UpdateAutoDownloadNewChaptersLimit(
                            data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateAutoDownloadNewChaptersLimit,
          parserFn: _parserFn$Mutation$UpdateAutoDownloadNewChaptersLimit,
        );

  final OnMutationCompleted$Mutation$UpdateAutoDownloadNewChaptersLimit?
      onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$UpdateAutoDownloadNewChaptersLimit
    = graphql.MultiSourceResult<Mutation$UpdateAutoDownloadNewChaptersLimit>
        Function({
  Variables$Mutation$UpdateAutoDownloadNewChaptersLimit? variables,
  Object? optimisticResult,
  Mutation$UpdateAutoDownloadNewChaptersLimit? typedOptimisticResult,
});
typedef Builder$Mutation$UpdateAutoDownloadNewChaptersLimit = widgets.Widget
    Function(
  RunMutation$Mutation$UpdateAutoDownloadNewChaptersLimit,
  graphql.QueryResult<Mutation$UpdateAutoDownloadNewChaptersLimit>?,
);

class Mutation$UpdateAutoDownloadNewChaptersLimit$Widget extends graphql_flutter
    .Mutation<Mutation$UpdateAutoDownloadNewChaptersLimit> {
  Mutation$UpdateAutoDownloadNewChaptersLimit$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$UpdateAutoDownloadNewChaptersLimit? options,
    required Builder$Mutation$UpdateAutoDownloadNewChaptersLimit builder,
  }) : super(
          key: key,
          options: options ??
              WidgetOptions$Mutation$UpdateAutoDownloadNewChaptersLimit(),
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

class Mutation$UpdateAutoDownloadNewChaptersLimit$setSettings {
  Mutation$UpdateAutoDownloadNewChaptersLimit$setSettings({
    required this.settings,
    this.$__typename = 'SetSettingsPayload',
  });

  factory Mutation$UpdateAutoDownloadNewChaptersLimit$setSettings.fromJson(
      Map<String, dynamic> json) {
    final l$settings = json['settings'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateAutoDownloadNewChaptersLimit$setSettings(
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
    if (other is! Mutation$UpdateAutoDownloadNewChaptersLimit$setSettings ||
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

extension UtilityExtension$Mutation$UpdateAutoDownloadNewChaptersLimit$setSettings
    on Mutation$UpdateAutoDownloadNewChaptersLimit$setSettings {
  CopyWith$Mutation$UpdateAutoDownloadNewChaptersLimit$setSettings<
          Mutation$UpdateAutoDownloadNewChaptersLimit$setSettings>
      get copyWith =>
          CopyWith$Mutation$UpdateAutoDownloadNewChaptersLimit$setSettings(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdateAutoDownloadNewChaptersLimit$setSettings<
    TRes> {
  factory CopyWith$Mutation$UpdateAutoDownloadNewChaptersLimit$setSettings(
    Mutation$UpdateAutoDownloadNewChaptersLimit$setSettings instance,
    TRes Function(Mutation$UpdateAutoDownloadNewChaptersLimit$setSettings) then,
  ) = _CopyWithImpl$Mutation$UpdateAutoDownloadNewChaptersLimit$setSettings;

  factory CopyWith$Mutation$UpdateAutoDownloadNewChaptersLimit$setSettings.stub(
          TRes res) =
      _CopyWithStubImpl$Mutation$UpdateAutoDownloadNewChaptersLimit$setSettings;

  TRes call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  });
  CopyWith$Fragment$SettingsDto<TRes> get settings;
}

class _CopyWithImpl$Mutation$UpdateAutoDownloadNewChaptersLimit$setSettings<
        TRes>
    implements
        CopyWith$Mutation$UpdateAutoDownloadNewChaptersLimit$setSettings<TRes> {
  _CopyWithImpl$Mutation$UpdateAutoDownloadNewChaptersLimit$setSettings(
    this._instance,
    this._then,
  );

  final Mutation$UpdateAutoDownloadNewChaptersLimit$setSettings _instance;

  final TRes Function(Mutation$UpdateAutoDownloadNewChaptersLimit$setSettings)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? settings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateAutoDownloadNewChaptersLimit$setSettings(
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

class _CopyWithStubImpl$Mutation$UpdateAutoDownloadNewChaptersLimit$setSettings<
        TRes>
    implements
        CopyWith$Mutation$UpdateAutoDownloadNewChaptersLimit$setSettings<TRes> {
  _CopyWithStubImpl$Mutation$UpdateAutoDownloadNewChaptersLimit$setSettings(
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

class Variables$Mutation$ToggleExcludeEntryWithUnreadChapters {
  factory Variables$Mutation$ToggleExcludeEntryWithUnreadChapters(
          {bool? excludeEntryWithUnreadChapters}) =>
      Variables$Mutation$ToggleExcludeEntryWithUnreadChapters._({
        if (excludeEntryWithUnreadChapters != null)
          r'excludeEntryWithUnreadChapters': excludeEntryWithUnreadChapters,
      });

  Variables$Mutation$ToggleExcludeEntryWithUnreadChapters._(this._$data);

  factory Variables$Mutation$ToggleExcludeEntryWithUnreadChapters.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('excludeEntryWithUnreadChapters')) {
      final l$excludeEntryWithUnreadChapters =
          data['excludeEntryWithUnreadChapters'];
      result$data['excludeEntryWithUnreadChapters'] =
          (l$excludeEntryWithUnreadChapters as bool?);
    }
    return Variables$Mutation$ToggleExcludeEntryWithUnreadChapters._(
        result$data);
  }

  Map<String, dynamic> _$data;

  bool? get excludeEntryWithUnreadChapters =>
      (_$data['excludeEntryWithUnreadChapters'] as bool?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('excludeEntryWithUnreadChapters')) {
      final l$excludeEntryWithUnreadChapters = excludeEntryWithUnreadChapters;
      result$data['excludeEntryWithUnreadChapters'] =
          l$excludeEntryWithUnreadChapters;
    }
    return result$data;
  }

  CopyWith$Variables$Mutation$ToggleExcludeEntryWithUnreadChapters<
          Variables$Mutation$ToggleExcludeEntryWithUnreadChapters>
      get copyWith =>
          CopyWith$Variables$Mutation$ToggleExcludeEntryWithUnreadChapters(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$ToggleExcludeEntryWithUnreadChapters ||
        runtimeType != other.runtimeType) {
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
    return true;
  }

  @override
  int get hashCode {
    final l$excludeEntryWithUnreadChapters = excludeEntryWithUnreadChapters;
    return Object.hashAll([
      _$data.containsKey('excludeEntryWithUnreadChapters')
          ? l$excludeEntryWithUnreadChapters
          : const {}
    ]);
  }
}

abstract class CopyWith$Variables$Mutation$ToggleExcludeEntryWithUnreadChapters<
    TRes> {
  factory CopyWith$Variables$Mutation$ToggleExcludeEntryWithUnreadChapters(
    Variables$Mutation$ToggleExcludeEntryWithUnreadChapters instance,
    TRes Function(Variables$Mutation$ToggleExcludeEntryWithUnreadChapters) then,
  ) = _CopyWithImpl$Variables$Mutation$ToggleExcludeEntryWithUnreadChapters;

  factory CopyWith$Variables$Mutation$ToggleExcludeEntryWithUnreadChapters.stub(
          TRes res) =
      _CopyWithStubImpl$Variables$Mutation$ToggleExcludeEntryWithUnreadChapters;

  TRes call({bool? excludeEntryWithUnreadChapters});
}

class _CopyWithImpl$Variables$Mutation$ToggleExcludeEntryWithUnreadChapters<
        TRes>
    implements
        CopyWith$Variables$Mutation$ToggleExcludeEntryWithUnreadChapters<TRes> {
  _CopyWithImpl$Variables$Mutation$ToggleExcludeEntryWithUnreadChapters(
    this._instance,
    this._then,
  );

  final Variables$Mutation$ToggleExcludeEntryWithUnreadChapters _instance;

  final TRes Function(Variables$Mutation$ToggleExcludeEntryWithUnreadChapters)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? excludeEntryWithUnreadChapters = _undefined}) =>
      _then(Variables$Mutation$ToggleExcludeEntryWithUnreadChapters._({
        ..._instance._$data,
        if (excludeEntryWithUnreadChapters != _undefined)
          'excludeEntryWithUnreadChapters':
              (excludeEntryWithUnreadChapters as bool?),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$ToggleExcludeEntryWithUnreadChapters<
        TRes>
    implements
        CopyWith$Variables$Mutation$ToggleExcludeEntryWithUnreadChapters<TRes> {
  _CopyWithStubImpl$Variables$Mutation$ToggleExcludeEntryWithUnreadChapters(
      this._res);

  TRes _res;

  call({bool? excludeEntryWithUnreadChapters}) => _res;
}

class Mutation$ToggleExcludeEntryWithUnreadChapters {
  Mutation$ToggleExcludeEntryWithUnreadChapters({
    required this.setSettings,
    this.$__typename = 'Mutation',
  });

  factory Mutation$ToggleExcludeEntryWithUnreadChapters.fromJson(
      Map<String, dynamic> json) {
    final l$setSettings = json['setSettings'];
    final l$$__typename = json['__typename'];
    return Mutation$ToggleExcludeEntryWithUnreadChapters(
      setSettings:
          Mutation$ToggleExcludeEntryWithUnreadChapters$setSettings.fromJson(
              (l$setSettings as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$ToggleExcludeEntryWithUnreadChapters$setSettings setSettings;

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
    if (other is! Mutation$ToggleExcludeEntryWithUnreadChapters ||
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

extension UtilityExtension$Mutation$ToggleExcludeEntryWithUnreadChapters
    on Mutation$ToggleExcludeEntryWithUnreadChapters {
  CopyWith$Mutation$ToggleExcludeEntryWithUnreadChapters<
          Mutation$ToggleExcludeEntryWithUnreadChapters>
      get copyWith => CopyWith$Mutation$ToggleExcludeEntryWithUnreadChapters(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$ToggleExcludeEntryWithUnreadChapters<TRes> {
  factory CopyWith$Mutation$ToggleExcludeEntryWithUnreadChapters(
    Mutation$ToggleExcludeEntryWithUnreadChapters instance,
    TRes Function(Mutation$ToggleExcludeEntryWithUnreadChapters) then,
  ) = _CopyWithImpl$Mutation$ToggleExcludeEntryWithUnreadChapters;

  factory CopyWith$Mutation$ToggleExcludeEntryWithUnreadChapters.stub(
          TRes res) =
      _CopyWithStubImpl$Mutation$ToggleExcludeEntryWithUnreadChapters;

  TRes call({
    Mutation$ToggleExcludeEntryWithUnreadChapters$setSettings? setSettings,
    String? $__typename,
  });
  CopyWith$Mutation$ToggleExcludeEntryWithUnreadChapters$setSettings<TRes>
      get setSettings;
}

class _CopyWithImpl$Mutation$ToggleExcludeEntryWithUnreadChapters<TRes>
    implements CopyWith$Mutation$ToggleExcludeEntryWithUnreadChapters<TRes> {
  _CopyWithImpl$Mutation$ToggleExcludeEntryWithUnreadChapters(
    this._instance,
    this._then,
  );

  final Mutation$ToggleExcludeEntryWithUnreadChapters _instance;

  final TRes Function(Mutation$ToggleExcludeEntryWithUnreadChapters) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? setSettings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$ToggleExcludeEntryWithUnreadChapters(
        setSettings: setSettings == _undefined || setSettings == null
            ? _instance.setSettings
            : (setSettings
                as Mutation$ToggleExcludeEntryWithUnreadChapters$setSettings),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$ToggleExcludeEntryWithUnreadChapters$setSettings<TRes>
      get setSettings {
    final local$setSettings = _instance.setSettings;
    return CopyWith$Mutation$ToggleExcludeEntryWithUnreadChapters$setSettings(
        local$setSettings, (e) => call(setSettings: e));
  }
}

class _CopyWithStubImpl$Mutation$ToggleExcludeEntryWithUnreadChapters<TRes>
    implements CopyWith$Mutation$ToggleExcludeEntryWithUnreadChapters<TRes> {
  _CopyWithStubImpl$Mutation$ToggleExcludeEntryWithUnreadChapters(this._res);

  TRes _res;

  call({
    Mutation$ToggleExcludeEntryWithUnreadChapters$setSettings? setSettings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$ToggleExcludeEntryWithUnreadChapters$setSettings<TRes>
      get setSettings =>
          CopyWith$Mutation$ToggleExcludeEntryWithUnreadChapters$setSettings
              .stub(_res);
}

const documentNodeMutationToggleExcludeEntryWithUnreadChapters =
    DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'ToggleExcludeEntryWithUnreadChapters'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(
            name: NameNode(value: 'excludeEntryWithUnreadChapters')),
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
                    name: NameNode(value: 'excludeEntryWithUnreadChapters'),
                    value: VariableNode(
                        name:
                            NameNode(value: 'excludeEntryWithUnreadChapters')),
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
Mutation$ToggleExcludeEntryWithUnreadChapters
    _parserFn$Mutation$ToggleExcludeEntryWithUnreadChapters(
            Map<String, dynamic> data) =>
        Mutation$ToggleExcludeEntryWithUnreadChapters.fromJson(data);
typedef OnMutationCompleted$Mutation$ToggleExcludeEntryWithUnreadChapters
    = FutureOr<void> Function(
  Map<String, dynamic>?,
  Mutation$ToggleExcludeEntryWithUnreadChapters?,
);

class Options$Mutation$ToggleExcludeEntryWithUnreadChapters extends graphql
    .MutationOptions<Mutation$ToggleExcludeEntryWithUnreadChapters> {
  Options$Mutation$ToggleExcludeEntryWithUnreadChapters({
    String? operationName,
    Variables$Mutation$ToggleExcludeEntryWithUnreadChapters? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$ToggleExcludeEntryWithUnreadChapters? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$ToggleExcludeEntryWithUnreadChapters?
        onCompleted,
    graphql.OnMutationUpdate<Mutation$ToggleExcludeEntryWithUnreadChapters>?
        update,
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
                        : _parserFn$Mutation$ToggleExcludeEntryWithUnreadChapters(
                            data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationToggleExcludeEntryWithUnreadChapters,
          parserFn: _parserFn$Mutation$ToggleExcludeEntryWithUnreadChapters,
        );

  final OnMutationCompleted$Mutation$ToggleExcludeEntryWithUnreadChapters?
      onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$ToggleExcludeEntryWithUnreadChapters extends graphql
    .WatchQueryOptions<Mutation$ToggleExcludeEntryWithUnreadChapters> {
  WatchOptions$Mutation$ToggleExcludeEntryWithUnreadChapters({
    String? operationName,
    Variables$Mutation$ToggleExcludeEntryWithUnreadChapters? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$ToggleExcludeEntryWithUnreadChapters? typedOptimisticResult,
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
          document: documentNodeMutationToggleExcludeEntryWithUnreadChapters,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$ToggleExcludeEntryWithUnreadChapters,
        );
}

extension ClientExtension$Mutation$ToggleExcludeEntryWithUnreadChapters
    on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$ToggleExcludeEntryWithUnreadChapters>>
      mutate$ToggleExcludeEntryWithUnreadChapters(
              [Options$Mutation$ToggleExcludeEntryWithUnreadChapters?
                  options]) async =>
          await this.mutate(options ??
              Options$Mutation$ToggleExcludeEntryWithUnreadChapters());

  graphql.ObservableQuery<Mutation$ToggleExcludeEntryWithUnreadChapters>
      watchMutation$ToggleExcludeEntryWithUnreadChapters(
              [WatchOptions$Mutation$ToggleExcludeEntryWithUnreadChapters?
                  options]) =>
          this.watchMutation(options ??
              WatchOptions$Mutation$ToggleExcludeEntryWithUnreadChapters());
}

class Mutation$ToggleExcludeEntryWithUnreadChapters$HookResult {
  Mutation$ToggleExcludeEntryWithUnreadChapters$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$ToggleExcludeEntryWithUnreadChapters runMutation;

  final graphql.QueryResult<Mutation$ToggleExcludeEntryWithUnreadChapters>
      result;
}

Mutation$ToggleExcludeEntryWithUnreadChapters$HookResult
    useMutation$ToggleExcludeEntryWithUnreadChapters(
        [WidgetOptions$Mutation$ToggleExcludeEntryWithUnreadChapters?
            options]) {
  final result = graphql_flutter.useMutation(
      options ?? WidgetOptions$Mutation$ToggleExcludeEntryWithUnreadChapters());
  return Mutation$ToggleExcludeEntryWithUnreadChapters$HookResult(
    ({variables, optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables?.toJson() ?? const {},
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$ToggleExcludeEntryWithUnreadChapters>
    useWatchMutation$ToggleExcludeEntryWithUnreadChapters(
            [WatchOptions$Mutation$ToggleExcludeEntryWithUnreadChapters?
                options]) =>
        graphql_flutter.useWatchMutation(options ??
            WatchOptions$Mutation$ToggleExcludeEntryWithUnreadChapters());

class WidgetOptions$Mutation$ToggleExcludeEntryWithUnreadChapters
    extends graphql
    .MutationOptions<Mutation$ToggleExcludeEntryWithUnreadChapters> {
  WidgetOptions$Mutation$ToggleExcludeEntryWithUnreadChapters({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$ToggleExcludeEntryWithUnreadChapters? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$ToggleExcludeEntryWithUnreadChapters?
        onCompleted,
    graphql.OnMutationUpdate<Mutation$ToggleExcludeEntryWithUnreadChapters>?
        update,
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
                        : _parserFn$Mutation$ToggleExcludeEntryWithUnreadChapters(
                            data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationToggleExcludeEntryWithUnreadChapters,
          parserFn: _parserFn$Mutation$ToggleExcludeEntryWithUnreadChapters,
        );

  final OnMutationCompleted$Mutation$ToggleExcludeEntryWithUnreadChapters?
      onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$ToggleExcludeEntryWithUnreadChapters
    = graphql.MultiSourceResult<Mutation$ToggleExcludeEntryWithUnreadChapters>
        Function({
  Variables$Mutation$ToggleExcludeEntryWithUnreadChapters? variables,
  Object? optimisticResult,
  Mutation$ToggleExcludeEntryWithUnreadChapters? typedOptimisticResult,
});
typedef Builder$Mutation$ToggleExcludeEntryWithUnreadChapters = widgets.Widget
    Function(
  RunMutation$Mutation$ToggleExcludeEntryWithUnreadChapters,
  graphql.QueryResult<Mutation$ToggleExcludeEntryWithUnreadChapters>?,
);

class Mutation$ToggleExcludeEntryWithUnreadChapters$Widget
    extends graphql_flutter
    .Mutation<Mutation$ToggleExcludeEntryWithUnreadChapters> {
  Mutation$ToggleExcludeEntryWithUnreadChapters$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$ToggleExcludeEntryWithUnreadChapters? options,
    required Builder$Mutation$ToggleExcludeEntryWithUnreadChapters builder,
  }) : super(
          key: key,
          options: options ??
              WidgetOptions$Mutation$ToggleExcludeEntryWithUnreadChapters(),
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

class Mutation$ToggleExcludeEntryWithUnreadChapters$setSettings {
  Mutation$ToggleExcludeEntryWithUnreadChapters$setSettings({
    required this.settings,
    this.$__typename = 'SetSettingsPayload',
  });

  factory Mutation$ToggleExcludeEntryWithUnreadChapters$setSettings.fromJson(
      Map<String, dynamic> json) {
    final l$settings = json['settings'];
    final l$$__typename = json['__typename'];
    return Mutation$ToggleExcludeEntryWithUnreadChapters$setSettings(
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
    if (other is! Mutation$ToggleExcludeEntryWithUnreadChapters$setSettings ||
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

extension UtilityExtension$Mutation$ToggleExcludeEntryWithUnreadChapters$setSettings
    on Mutation$ToggleExcludeEntryWithUnreadChapters$setSettings {
  CopyWith$Mutation$ToggleExcludeEntryWithUnreadChapters$setSettings<
          Mutation$ToggleExcludeEntryWithUnreadChapters$setSettings>
      get copyWith =>
          CopyWith$Mutation$ToggleExcludeEntryWithUnreadChapters$setSettings(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$ToggleExcludeEntryWithUnreadChapters$setSettings<
    TRes> {
  factory CopyWith$Mutation$ToggleExcludeEntryWithUnreadChapters$setSettings(
    Mutation$ToggleExcludeEntryWithUnreadChapters$setSettings instance,
    TRes Function(Mutation$ToggleExcludeEntryWithUnreadChapters$setSettings)
        then,
  ) = _CopyWithImpl$Mutation$ToggleExcludeEntryWithUnreadChapters$setSettings;

  factory CopyWith$Mutation$ToggleExcludeEntryWithUnreadChapters$setSettings.stub(
          TRes res) =
      _CopyWithStubImpl$Mutation$ToggleExcludeEntryWithUnreadChapters$setSettings;

  TRes call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  });
  CopyWith$Fragment$SettingsDto<TRes> get settings;
}

class _CopyWithImpl$Mutation$ToggleExcludeEntryWithUnreadChapters$setSettings<
        TRes>
    implements
        CopyWith$Mutation$ToggleExcludeEntryWithUnreadChapters$setSettings<
            TRes> {
  _CopyWithImpl$Mutation$ToggleExcludeEntryWithUnreadChapters$setSettings(
    this._instance,
    this._then,
  );

  final Mutation$ToggleExcludeEntryWithUnreadChapters$setSettings _instance;

  final TRes Function(Mutation$ToggleExcludeEntryWithUnreadChapters$setSettings)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? settings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$ToggleExcludeEntryWithUnreadChapters$setSettings(
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

class _CopyWithStubImpl$Mutation$ToggleExcludeEntryWithUnreadChapters$setSettings<
        TRes>
    implements
        CopyWith$Mutation$ToggleExcludeEntryWithUnreadChapters$setSettings<
            TRes> {
  _CopyWithStubImpl$Mutation$ToggleExcludeEntryWithUnreadChapters$setSettings(
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

class Variables$Mutation$ToggleAutoDownloadNewChapters {
  factory Variables$Mutation$ToggleAutoDownloadNewChapters(
          {bool? autoDownloadNewChapters}) =>
      Variables$Mutation$ToggleAutoDownloadNewChapters._({
        if (autoDownloadNewChapters != null)
          r'autoDownloadNewChapters': autoDownloadNewChapters,
      });

  Variables$Mutation$ToggleAutoDownloadNewChapters._(this._$data);

  factory Variables$Mutation$ToggleAutoDownloadNewChapters.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('autoDownloadNewChapters')) {
      final l$autoDownloadNewChapters = data['autoDownloadNewChapters'];
      result$data['autoDownloadNewChapters'] =
          (l$autoDownloadNewChapters as bool?);
    }
    return Variables$Mutation$ToggleAutoDownloadNewChapters._(result$data);
  }

  Map<String, dynamic> _$data;

  bool? get autoDownloadNewChapters =>
      (_$data['autoDownloadNewChapters'] as bool?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('autoDownloadNewChapters')) {
      final l$autoDownloadNewChapters = autoDownloadNewChapters;
      result$data['autoDownloadNewChapters'] = l$autoDownloadNewChapters;
    }
    return result$data;
  }

  CopyWith$Variables$Mutation$ToggleAutoDownloadNewChapters<
          Variables$Mutation$ToggleAutoDownloadNewChapters>
      get copyWith => CopyWith$Variables$Mutation$ToggleAutoDownloadNewChapters(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$ToggleAutoDownloadNewChapters ||
        runtimeType != other.runtimeType) {
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
    return true;
  }

  @override
  int get hashCode {
    final l$autoDownloadNewChapters = autoDownloadNewChapters;
    return Object.hashAll([
      _$data.containsKey('autoDownloadNewChapters')
          ? l$autoDownloadNewChapters
          : const {}
    ]);
  }
}

abstract class CopyWith$Variables$Mutation$ToggleAutoDownloadNewChapters<TRes> {
  factory CopyWith$Variables$Mutation$ToggleAutoDownloadNewChapters(
    Variables$Mutation$ToggleAutoDownloadNewChapters instance,
    TRes Function(Variables$Mutation$ToggleAutoDownloadNewChapters) then,
  ) = _CopyWithImpl$Variables$Mutation$ToggleAutoDownloadNewChapters;

  factory CopyWith$Variables$Mutation$ToggleAutoDownloadNewChapters.stub(
          TRes res) =
      _CopyWithStubImpl$Variables$Mutation$ToggleAutoDownloadNewChapters;

  TRes call({bool? autoDownloadNewChapters});
}

class _CopyWithImpl$Variables$Mutation$ToggleAutoDownloadNewChapters<TRes>
    implements CopyWith$Variables$Mutation$ToggleAutoDownloadNewChapters<TRes> {
  _CopyWithImpl$Variables$Mutation$ToggleAutoDownloadNewChapters(
    this._instance,
    this._then,
  );

  final Variables$Mutation$ToggleAutoDownloadNewChapters _instance;

  final TRes Function(Variables$Mutation$ToggleAutoDownloadNewChapters) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? autoDownloadNewChapters = _undefined}) =>
      _then(Variables$Mutation$ToggleAutoDownloadNewChapters._({
        ..._instance._$data,
        if (autoDownloadNewChapters != _undefined)
          'autoDownloadNewChapters': (autoDownloadNewChapters as bool?),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$ToggleAutoDownloadNewChapters<TRes>
    implements CopyWith$Variables$Mutation$ToggleAutoDownloadNewChapters<TRes> {
  _CopyWithStubImpl$Variables$Mutation$ToggleAutoDownloadNewChapters(this._res);

  TRes _res;

  call({bool? autoDownloadNewChapters}) => _res;
}

class Mutation$ToggleAutoDownloadNewChapters {
  Mutation$ToggleAutoDownloadNewChapters({
    required this.setSettings,
    this.$__typename = 'Mutation',
  });

  factory Mutation$ToggleAutoDownloadNewChapters.fromJson(
      Map<String, dynamic> json) {
    final l$setSettings = json['setSettings'];
    final l$$__typename = json['__typename'];
    return Mutation$ToggleAutoDownloadNewChapters(
      setSettings: Mutation$ToggleAutoDownloadNewChapters$setSettings.fromJson(
          (l$setSettings as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$ToggleAutoDownloadNewChapters$setSettings setSettings;

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
    if (other is! Mutation$ToggleAutoDownloadNewChapters ||
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

extension UtilityExtension$Mutation$ToggleAutoDownloadNewChapters
    on Mutation$ToggleAutoDownloadNewChapters {
  CopyWith$Mutation$ToggleAutoDownloadNewChapters<
          Mutation$ToggleAutoDownloadNewChapters>
      get copyWith => CopyWith$Mutation$ToggleAutoDownloadNewChapters(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$ToggleAutoDownloadNewChapters<TRes> {
  factory CopyWith$Mutation$ToggleAutoDownloadNewChapters(
    Mutation$ToggleAutoDownloadNewChapters instance,
    TRes Function(Mutation$ToggleAutoDownloadNewChapters) then,
  ) = _CopyWithImpl$Mutation$ToggleAutoDownloadNewChapters;

  factory CopyWith$Mutation$ToggleAutoDownloadNewChapters.stub(TRes res) =
      _CopyWithStubImpl$Mutation$ToggleAutoDownloadNewChapters;

  TRes call({
    Mutation$ToggleAutoDownloadNewChapters$setSettings? setSettings,
    String? $__typename,
  });
  CopyWith$Mutation$ToggleAutoDownloadNewChapters$setSettings<TRes>
      get setSettings;
}

class _CopyWithImpl$Mutation$ToggleAutoDownloadNewChapters<TRes>
    implements CopyWith$Mutation$ToggleAutoDownloadNewChapters<TRes> {
  _CopyWithImpl$Mutation$ToggleAutoDownloadNewChapters(
    this._instance,
    this._then,
  );

  final Mutation$ToggleAutoDownloadNewChapters _instance;

  final TRes Function(Mutation$ToggleAutoDownloadNewChapters) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? setSettings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$ToggleAutoDownloadNewChapters(
        setSettings: setSettings == _undefined || setSettings == null
            ? _instance.setSettings
            : (setSettings
                as Mutation$ToggleAutoDownloadNewChapters$setSettings),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$ToggleAutoDownloadNewChapters$setSettings<TRes>
      get setSettings {
    final local$setSettings = _instance.setSettings;
    return CopyWith$Mutation$ToggleAutoDownloadNewChapters$setSettings(
        local$setSettings, (e) => call(setSettings: e));
  }
}

class _CopyWithStubImpl$Mutation$ToggleAutoDownloadNewChapters<TRes>
    implements CopyWith$Mutation$ToggleAutoDownloadNewChapters<TRes> {
  _CopyWithStubImpl$Mutation$ToggleAutoDownloadNewChapters(this._res);

  TRes _res;

  call({
    Mutation$ToggleAutoDownloadNewChapters$setSettings? setSettings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$ToggleAutoDownloadNewChapters$setSettings<TRes>
      get setSettings =>
          CopyWith$Mutation$ToggleAutoDownloadNewChapters$setSettings.stub(
              _res);
}

const documentNodeMutationToggleAutoDownloadNewChapters =
    DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'ToggleAutoDownloadNewChapters'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable:
            VariableNode(name: NameNode(value: 'autoDownloadNewChapters')),
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
                    name: NameNode(value: 'autoDownloadNewChapters'),
                    value: VariableNode(
                        name: NameNode(value: 'autoDownloadNewChapters')),
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
Mutation$ToggleAutoDownloadNewChapters
    _parserFn$Mutation$ToggleAutoDownloadNewChapters(
            Map<String, dynamic> data) =>
        Mutation$ToggleAutoDownloadNewChapters.fromJson(data);
typedef OnMutationCompleted$Mutation$ToggleAutoDownloadNewChapters
    = FutureOr<void> Function(
  Map<String, dynamic>?,
  Mutation$ToggleAutoDownloadNewChapters?,
);

class Options$Mutation$ToggleAutoDownloadNewChapters
    extends graphql.MutationOptions<Mutation$ToggleAutoDownloadNewChapters> {
  Options$Mutation$ToggleAutoDownloadNewChapters({
    String? operationName,
    Variables$Mutation$ToggleAutoDownloadNewChapters? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$ToggleAutoDownloadNewChapters? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$ToggleAutoDownloadNewChapters? onCompleted,
    graphql.OnMutationUpdate<Mutation$ToggleAutoDownloadNewChapters>? update,
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
                        : _parserFn$Mutation$ToggleAutoDownloadNewChapters(
                            data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationToggleAutoDownloadNewChapters,
          parserFn: _parserFn$Mutation$ToggleAutoDownloadNewChapters,
        );

  final OnMutationCompleted$Mutation$ToggleAutoDownloadNewChapters?
      onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$ToggleAutoDownloadNewChapters
    extends graphql.WatchQueryOptions<Mutation$ToggleAutoDownloadNewChapters> {
  WatchOptions$Mutation$ToggleAutoDownloadNewChapters({
    String? operationName,
    Variables$Mutation$ToggleAutoDownloadNewChapters? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$ToggleAutoDownloadNewChapters? typedOptimisticResult,
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
          document: documentNodeMutationToggleAutoDownloadNewChapters,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$ToggleAutoDownloadNewChapters,
        );
}

extension ClientExtension$Mutation$ToggleAutoDownloadNewChapters
    on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$ToggleAutoDownloadNewChapters>>
      mutate$ToggleAutoDownloadNewChapters(
              [Options$Mutation$ToggleAutoDownloadNewChapters?
                  options]) async =>
          await this.mutate(
              options ?? Options$Mutation$ToggleAutoDownloadNewChapters());

  graphql.ObservableQuery<Mutation$ToggleAutoDownloadNewChapters>
      watchMutation$ToggleAutoDownloadNewChapters(
              [WatchOptions$Mutation$ToggleAutoDownloadNewChapters? options]) =>
          this.watchMutation(
              options ?? WatchOptions$Mutation$ToggleAutoDownloadNewChapters());
}

class Mutation$ToggleAutoDownloadNewChapters$HookResult {
  Mutation$ToggleAutoDownloadNewChapters$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$ToggleAutoDownloadNewChapters runMutation;

  final graphql.QueryResult<Mutation$ToggleAutoDownloadNewChapters> result;
}

Mutation$ToggleAutoDownloadNewChapters$HookResult
    useMutation$ToggleAutoDownloadNewChapters(
        [WidgetOptions$Mutation$ToggleAutoDownloadNewChapters? options]) {
  final result = graphql_flutter.useMutation(
      options ?? WidgetOptions$Mutation$ToggleAutoDownloadNewChapters());
  return Mutation$ToggleAutoDownloadNewChapters$HookResult(
    ({variables, optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables?.toJson() ?? const {},
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$ToggleAutoDownloadNewChapters>
    useWatchMutation$ToggleAutoDownloadNewChapters(
            [WatchOptions$Mutation$ToggleAutoDownloadNewChapters? options]) =>
        graphql_flutter.useWatchMutation(
            options ?? WatchOptions$Mutation$ToggleAutoDownloadNewChapters());

class WidgetOptions$Mutation$ToggleAutoDownloadNewChapters
    extends graphql.MutationOptions<Mutation$ToggleAutoDownloadNewChapters> {
  WidgetOptions$Mutation$ToggleAutoDownloadNewChapters({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$ToggleAutoDownloadNewChapters? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$ToggleAutoDownloadNewChapters? onCompleted,
    graphql.OnMutationUpdate<Mutation$ToggleAutoDownloadNewChapters>? update,
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
                        : _parserFn$Mutation$ToggleAutoDownloadNewChapters(
                            data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationToggleAutoDownloadNewChapters,
          parserFn: _parserFn$Mutation$ToggleAutoDownloadNewChapters,
        );

  final OnMutationCompleted$Mutation$ToggleAutoDownloadNewChapters?
      onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$ToggleAutoDownloadNewChapters
    = graphql.MultiSourceResult<Mutation$ToggleAutoDownloadNewChapters>
        Function({
  Variables$Mutation$ToggleAutoDownloadNewChapters? variables,
  Object? optimisticResult,
  Mutation$ToggleAutoDownloadNewChapters? typedOptimisticResult,
});
typedef Builder$Mutation$ToggleAutoDownloadNewChapters = widgets.Widget
    Function(
  RunMutation$Mutation$ToggleAutoDownloadNewChapters,
  graphql.QueryResult<Mutation$ToggleAutoDownloadNewChapters>?,
);

class Mutation$ToggleAutoDownloadNewChapters$Widget
    extends graphql_flutter.Mutation<Mutation$ToggleAutoDownloadNewChapters> {
  Mutation$ToggleAutoDownloadNewChapters$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$ToggleAutoDownloadNewChapters? options,
    required Builder$Mutation$ToggleAutoDownloadNewChapters builder,
  }) : super(
          key: key,
          options:
              options ?? WidgetOptions$Mutation$ToggleAutoDownloadNewChapters(),
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

class Mutation$ToggleAutoDownloadNewChapters$setSettings {
  Mutation$ToggleAutoDownloadNewChapters$setSettings({
    required this.settings,
    this.$__typename = 'SetSettingsPayload',
  });

  factory Mutation$ToggleAutoDownloadNewChapters$setSettings.fromJson(
      Map<String, dynamic> json) {
    final l$settings = json['settings'];
    final l$$__typename = json['__typename'];
    return Mutation$ToggleAutoDownloadNewChapters$setSettings(
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
    if (other is! Mutation$ToggleAutoDownloadNewChapters$setSettings ||
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

extension UtilityExtension$Mutation$ToggleAutoDownloadNewChapters$setSettings
    on Mutation$ToggleAutoDownloadNewChapters$setSettings {
  CopyWith$Mutation$ToggleAutoDownloadNewChapters$setSettings<
          Mutation$ToggleAutoDownloadNewChapters$setSettings>
      get copyWith =>
          CopyWith$Mutation$ToggleAutoDownloadNewChapters$setSettings(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$ToggleAutoDownloadNewChapters$setSettings<
    TRes> {
  factory CopyWith$Mutation$ToggleAutoDownloadNewChapters$setSettings(
    Mutation$ToggleAutoDownloadNewChapters$setSettings instance,
    TRes Function(Mutation$ToggleAutoDownloadNewChapters$setSettings) then,
  ) = _CopyWithImpl$Mutation$ToggleAutoDownloadNewChapters$setSettings;

  factory CopyWith$Mutation$ToggleAutoDownloadNewChapters$setSettings.stub(
          TRes res) =
      _CopyWithStubImpl$Mutation$ToggleAutoDownloadNewChapters$setSettings;

  TRes call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  });
  CopyWith$Fragment$SettingsDto<TRes> get settings;
}

class _CopyWithImpl$Mutation$ToggleAutoDownloadNewChapters$setSettings<TRes>
    implements
        CopyWith$Mutation$ToggleAutoDownloadNewChapters$setSettings<TRes> {
  _CopyWithImpl$Mutation$ToggleAutoDownloadNewChapters$setSettings(
    this._instance,
    this._then,
  );

  final Mutation$ToggleAutoDownloadNewChapters$setSettings _instance;

  final TRes Function(Mutation$ToggleAutoDownloadNewChapters$setSettings) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? settings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$ToggleAutoDownloadNewChapters$setSettings(
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

class _CopyWithStubImpl$Mutation$ToggleAutoDownloadNewChapters$setSettings<TRes>
    implements
        CopyWith$Mutation$ToggleAutoDownloadNewChapters$setSettings<TRes> {
  _CopyWithStubImpl$Mutation$ToggleAutoDownloadNewChapters$setSettings(
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
