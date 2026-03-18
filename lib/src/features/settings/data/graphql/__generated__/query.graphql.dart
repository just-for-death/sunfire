import '../../../domain/settings/graphql/__generated__/fragment.graphql.dart';
import 'dart:async';
import 'package:flutter/widgets.dart' as widgets;
import 'package:gql/ast.dart';
import 'package:graphql/client.dart' as graphql;
import 'package:graphql_flutter/graphql_flutter.dart' as graphql_flutter;

class Query$ServerSettings {
  Query$ServerSettings({
    required this.settings,
    this.$__typename = 'Query',
  });

  factory Query$ServerSettings.fromJson(Map<String, dynamic> json) {
    final l$settings = json['settings'];
    final l$$__typename = json['__typename'];
    return Query$ServerSettings(
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
    if (other is! Query$ServerSettings || runtimeType != other.runtimeType) {
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

extension UtilityExtension$Query$ServerSettings on Query$ServerSettings {
  CopyWith$Query$ServerSettings<Query$ServerSettings> get copyWith =>
      CopyWith$Query$ServerSettings(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Query$ServerSettings<TRes> {
  factory CopyWith$Query$ServerSettings(
    Query$ServerSettings instance,
    TRes Function(Query$ServerSettings) then,
  ) = _CopyWithImpl$Query$ServerSettings;

  factory CopyWith$Query$ServerSettings.stub(TRes res) =
      _CopyWithStubImpl$Query$ServerSettings;

  TRes call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  });
  CopyWith$Fragment$SettingsDto<TRes> get settings;
}

class _CopyWithImpl$Query$ServerSettings<TRes>
    implements CopyWith$Query$ServerSettings<TRes> {
  _CopyWithImpl$Query$ServerSettings(
    this._instance,
    this._then,
  );

  final Query$ServerSettings _instance;

  final TRes Function(Query$ServerSettings) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? settings = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$ServerSettings(
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

class _CopyWithStubImpl$Query$ServerSettings<TRes>
    implements CopyWith$Query$ServerSettings<TRes> {
  _CopyWithStubImpl$Query$ServerSettings(this._res);

  TRes _res;

  call({
    Fragment$SettingsDto? settings,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$SettingsDto<TRes> get settings =>
      CopyWith$Fragment$SettingsDto.stub(_res);
}

const documentNodeQueryServerSettings = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.query,
    name: NameNode(value: 'ServerSettings'),
    variableDefinitions: [],
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
Query$ServerSettings _parserFn$Query$ServerSettings(
        Map<String, dynamic> data) =>
    Query$ServerSettings.fromJson(data);
typedef OnQueryComplete$Query$ServerSettings = FutureOr<void> Function(
  Map<String, dynamic>?,
  Query$ServerSettings?,
);

class Options$Query$ServerSettings
    extends graphql.QueryOptions<Query$ServerSettings> {
  Options$Query$ServerSettings({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$ServerSettings? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$ServerSettings? onComplete,
    graphql.OnQueryError? onError,
  })  : onCompleteWithParsed = onComplete,
        super(
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
                    data == null ? null : _parserFn$Query$ServerSettings(data),
                  ),
          onError: onError,
          document: documentNodeQueryServerSettings,
          parserFn: _parserFn$Query$ServerSettings,
        );

  final OnQueryComplete$Query$ServerSettings? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onComplete == null
            ? super.properties
            : super.properties.where((property) => property != onComplete),
        onCompleteWithParsed,
      ];
}

class WatchOptions$Query$ServerSettings
    extends graphql.WatchQueryOptions<Query$ServerSettings> {
  WatchOptions$Query$ServerSettings({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$ServerSettings? typedOptimisticResult,
    graphql.Context? context,
    Duration? pollInterval,
    bool? eagerlyFetchResults,
    bool carryForwardDataOnException = true,
    bool fetchResults = false,
  }) : super(
          operationName: operationName,
          fetchPolicy: fetchPolicy,
          errorPolicy: errorPolicy,
          cacheRereadPolicy: cacheRereadPolicy,
          optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
          context: context,
          document: documentNodeQueryServerSettings,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Query$ServerSettings,
        );
}

class FetchMoreOptions$Query$ServerSettings extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$ServerSettings(
      {required graphql.UpdateQuery updateQuery})
      : super(
          updateQuery: updateQuery,
          document: documentNodeQueryServerSettings,
        );
}

extension ClientExtension$Query$ServerSettings on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$ServerSettings>> query$ServerSettings(
          [Options$Query$ServerSettings? options]) async =>
      await this.query(options ?? Options$Query$ServerSettings());

  graphql.ObservableQuery<Query$ServerSettings> watchQuery$ServerSettings(
          [WatchOptions$Query$ServerSettings? options]) =>
      this.watchQuery(options ?? WatchOptions$Query$ServerSettings());

  void writeQuery$ServerSettings({
    required Query$ServerSettings data,
    bool broadcast = true,
  }) =>
      this.writeQuery(
        graphql.Request(
            operation:
                graphql.Operation(document: documentNodeQueryServerSettings)),
        data: data.toJson(),
        broadcast: broadcast,
      );

  Query$ServerSettings? readQuery$ServerSettings({bool optimistic = true}) {
    final result = this.readQuery(
      graphql.Request(
          operation:
              graphql.Operation(document: documentNodeQueryServerSettings)),
      optimistic: optimistic,
    );
    return result == null ? null : Query$ServerSettings.fromJson(result);
  }
}

graphql_flutter.QueryHookResult<Query$ServerSettings> useQuery$ServerSettings(
        [Options$Query$ServerSettings? options]) =>
    graphql_flutter.useQuery(options ?? Options$Query$ServerSettings());
graphql.ObservableQuery<Query$ServerSettings> useWatchQuery$ServerSettings(
        [WatchOptions$Query$ServerSettings? options]) =>
    graphql_flutter
        .useWatchQuery(options ?? WatchOptions$Query$ServerSettings());

class Query$ServerSettings$Widget
    extends graphql_flutter.Query<Query$ServerSettings> {
  Query$ServerSettings$Widget({
    widgets.Key? key,
    Options$Query$ServerSettings? options,
    required graphql_flutter.QueryBuilder<Query$ServerSettings> builder,
  }) : super(
          key: key,
          options: options ?? Options$Query$ServerSettings(),
          builder: builder,
        );
}
