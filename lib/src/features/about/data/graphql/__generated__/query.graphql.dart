import '../../../domain/about/graphql/__generated__/fragment.graphql.dart';
import '../../../domain/server_update/graphql/__generated__/fragment.graphql.dart';
import 'dart:async';
import 'package:flutter/widgets.dart' as widgets;
import 'package:gql/ast.dart';
import 'package:graphql/client.dart' as graphql;
import 'package:graphql_flutter/graphql_flutter.dart' as graphql_flutter;

class Query$GetServerUpdate {
  Query$GetServerUpdate({
    required this.checkForServerUpdates,
    this.$__typename = 'Query',
  });

  factory Query$GetServerUpdate.fromJson(Map<String, dynamic> json) {
    final l$checkForServerUpdates = json['checkForServerUpdates'];
    final l$$__typename = json['__typename'];
    return Query$GetServerUpdate(
      checkForServerUpdates: (l$checkForServerUpdates as List<dynamic>)
          .map((e) =>
              Fragment$ServerUpdateDto.fromJson((e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final List<Fragment$ServerUpdateDto> checkForServerUpdates;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$checkForServerUpdates = checkForServerUpdates;
    _resultData['checkForServerUpdates'] =
        l$checkForServerUpdates.map((e) => e.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$checkForServerUpdates = checkForServerUpdates;
    final l$$__typename = $__typename;
    return Object.hashAll([
      Object.hashAll(l$checkForServerUpdates.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetServerUpdate || runtimeType != other.runtimeType) {
      return false;
    }
    final l$checkForServerUpdates = checkForServerUpdates;
    final lOther$checkForServerUpdates = other.checkForServerUpdates;
    if (l$checkForServerUpdates.length != lOther$checkForServerUpdates.length) {
      return false;
    }
    for (int i = 0; i < l$checkForServerUpdates.length; i++) {
      final l$checkForServerUpdates$entry = l$checkForServerUpdates[i];
      final lOther$checkForServerUpdates$entry =
          lOther$checkForServerUpdates[i];
      if (l$checkForServerUpdates$entry != lOther$checkForServerUpdates$entry) {
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

extension UtilityExtension$Query$GetServerUpdate on Query$GetServerUpdate {
  CopyWith$Query$GetServerUpdate<Query$GetServerUpdate> get copyWith =>
      CopyWith$Query$GetServerUpdate(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Query$GetServerUpdate<TRes> {
  factory CopyWith$Query$GetServerUpdate(
    Query$GetServerUpdate instance,
    TRes Function(Query$GetServerUpdate) then,
  ) = _CopyWithImpl$Query$GetServerUpdate;

  factory CopyWith$Query$GetServerUpdate.stub(TRes res) =
      _CopyWithStubImpl$Query$GetServerUpdate;

  TRes call({
    List<Fragment$ServerUpdateDto>? checkForServerUpdates,
    String? $__typename,
  });
  TRes checkForServerUpdates(
      Iterable<Fragment$ServerUpdateDto> Function(
              Iterable<
                  CopyWith$Fragment$ServerUpdateDto<Fragment$ServerUpdateDto>>)
          _fn);
}

class _CopyWithImpl$Query$GetServerUpdate<TRes>
    implements CopyWith$Query$GetServerUpdate<TRes> {
  _CopyWithImpl$Query$GetServerUpdate(
    this._instance,
    this._then,
  );

  final Query$GetServerUpdate _instance;

  final TRes Function(Query$GetServerUpdate) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? checkForServerUpdates = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetServerUpdate(
        checkForServerUpdates:
            checkForServerUpdates == _undefined || checkForServerUpdates == null
                ? _instance.checkForServerUpdates
                : (checkForServerUpdates as List<Fragment$ServerUpdateDto>),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  TRes checkForServerUpdates(
          Iterable<Fragment$ServerUpdateDto> Function(
                  Iterable<
                      CopyWith$Fragment$ServerUpdateDto<
                          Fragment$ServerUpdateDto>>)
              _fn) =>
      call(
          checkForServerUpdates: _fn(_instance.checkForServerUpdates
              .map((e) => CopyWith$Fragment$ServerUpdateDto(
                    e,
                    (i) => i,
                  ))).toList());
}

class _CopyWithStubImpl$Query$GetServerUpdate<TRes>
    implements CopyWith$Query$GetServerUpdate<TRes> {
  _CopyWithStubImpl$Query$GetServerUpdate(this._res);

  TRes _res;

  call({
    List<Fragment$ServerUpdateDto>? checkForServerUpdates,
    String? $__typename,
  }) =>
      _res;

  checkForServerUpdates(_fn) => _res;
}

const documentNodeQueryGetServerUpdate = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.query,
    name: NameNode(value: 'GetServerUpdate'),
    variableDefinitions: [],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'checkForServerUpdates'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: SelectionSetNode(selections: [
          FragmentSpreadNode(
            name: NameNode(value: 'ServerUpdateDto'),
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
  fragmentDefinitionServerUpdateDto,
]);
Query$GetServerUpdate _parserFn$Query$GetServerUpdate(
        Map<String, dynamic> data) =>
    Query$GetServerUpdate.fromJson(data);
typedef OnQueryComplete$Query$GetServerUpdate = FutureOr<void> Function(
  Map<String, dynamic>?,
  Query$GetServerUpdate?,
);

class Options$Query$GetServerUpdate
    extends graphql.QueryOptions<Query$GetServerUpdate> {
  Options$Query$GetServerUpdate({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetServerUpdate? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$GetServerUpdate? onComplete,
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
                    data == null ? null : _parserFn$Query$GetServerUpdate(data),
                  ),
          onError: onError,
          document: documentNodeQueryGetServerUpdate,
          parserFn: _parserFn$Query$GetServerUpdate,
        );

  final OnQueryComplete$Query$GetServerUpdate? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onComplete == null
            ? super.properties
            : super.properties.where((property) => property != onComplete),
        onCompleteWithParsed,
      ];
}

class WatchOptions$Query$GetServerUpdate
    extends graphql.WatchQueryOptions<Query$GetServerUpdate> {
  WatchOptions$Query$GetServerUpdate({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetServerUpdate? typedOptimisticResult,
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
          document: documentNodeQueryGetServerUpdate,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Query$GetServerUpdate,
        );
}

class FetchMoreOptions$Query$GetServerUpdate extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$GetServerUpdate(
      {required graphql.UpdateQuery updateQuery})
      : super(
          updateQuery: updateQuery,
          document: documentNodeQueryGetServerUpdate,
        );
}

extension ClientExtension$Query$GetServerUpdate on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$GetServerUpdate>> query$GetServerUpdate(
          [Options$Query$GetServerUpdate? options]) async =>
      await this.query(options ?? Options$Query$GetServerUpdate());

  graphql.ObservableQuery<Query$GetServerUpdate> watchQuery$GetServerUpdate(
          [WatchOptions$Query$GetServerUpdate? options]) =>
      this.watchQuery(options ?? WatchOptions$Query$GetServerUpdate());

  void writeQuery$GetServerUpdate({
    required Query$GetServerUpdate data,
    bool broadcast = true,
  }) =>
      this.writeQuery(
        graphql.Request(
            operation:
                graphql.Operation(document: documentNodeQueryGetServerUpdate)),
        data: data.toJson(),
        broadcast: broadcast,
      );

  Query$GetServerUpdate? readQuery$GetServerUpdate({bool optimistic = true}) {
    final result = this.readQuery(
      graphql.Request(
          operation:
              graphql.Operation(document: documentNodeQueryGetServerUpdate)),
      optimistic: optimistic,
    );
    return result == null ? null : Query$GetServerUpdate.fromJson(result);
  }
}

graphql_flutter.QueryHookResult<Query$GetServerUpdate> useQuery$GetServerUpdate(
        [Options$Query$GetServerUpdate? options]) =>
    graphql_flutter.useQuery(options ?? Options$Query$GetServerUpdate());
graphql.ObservableQuery<Query$GetServerUpdate> useWatchQuery$GetServerUpdate(
        [WatchOptions$Query$GetServerUpdate? options]) =>
    graphql_flutter
        .useWatchQuery(options ?? WatchOptions$Query$GetServerUpdate());

class Query$GetServerUpdate$Widget
    extends graphql_flutter.Query<Query$GetServerUpdate> {
  Query$GetServerUpdate$Widget({
    widgets.Key? key,
    Options$Query$GetServerUpdate? options,
    required graphql_flutter.QueryBuilder<Query$GetServerUpdate> builder,
  }) : super(
          key: key,
          options: options ?? Options$Query$GetServerUpdate(),
          builder: builder,
        );
}

class Query$GetAbout {
  Query$GetAbout({
    required this.aboutServer,
    this.$__typename = 'Query',
  });

  factory Query$GetAbout.fromJson(Map<String, dynamic> json) {
    final l$aboutServer = json['aboutServer'];
    final l$$__typename = json['__typename'];
    return Query$GetAbout(
      aboutServer:
          Fragment$AboutDto.fromJson((l$aboutServer as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Fragment$AboutDto aboutServer;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$aboutServer = aboutServer;
    _resultData['aboutServer'] = l$aboutServer.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$aboutServer = aboutServer;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$aboutServer,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetAbout || runtimeType != other.runtimeType) {
      return false;
    }
    final l$aboutServer = aboutServer;
    final lOther$aboutServer = other.aboutServer;
    if (l$aboutServer != lOther$aboutServer) {
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

extension UtilityExtension$Query$GetAbout on Query$GetAbout {
  CopyWith$Query$GetAbout<Query$GetAbout> get copyWith =>
      CopyWith$Query$GetAbout(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Query$GetAbout<TRes> {
  factory CopyWith$Query$GetAbout(
    Query$GetAbout instance,
    TRes Function(Query$GetAbout) then,
  ) = _CopyWithImpl$Query$GetAbout;

  factory CopyWith$Query$GetAbout.stub(TRes res) =
      _CopyWithStubImpl$Query$GetAbout;

  TRes call({
    Fragment$AboutDto? aboutServer,
    String? $__typename,
  });
  CopyWith$Fragment$AboutDto<TRes> get aboutServer;
}

class _CopyWithImpl$Query$GetAbout<TRes>
    implements CopyWith$Query$GetAbout<TRes> {
  _CopyWithImpl$Query$GetAbout(
    this._instance,
    this._then,
  );

  final Query$GetAbout _instance;

  final TRes Function(Query$GetAbout) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? aboutServer = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetAbout(
        aboutServer: aboutServer == _undefined || aboutServer == null
            ? _instance.aboutServer
            : (aboutServer as Fragment$AboutDto),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Fragment$AboutDto<TRes> get aboutServer {
    final local$aboutServer = _instance.aboutServer;
    return CopyWith$Fragment$AboutDto(
        local$aboutServer, (e) => call(aboutServer: e));
  }
}

class _CopyWithStubImpl$Query$GetAbout<TRes>
    implements CopyWith$Query$GetAbout<TRes> {
  _CopyWithStubImpl$Query$GetAbout(this._res);

  TRes _res;

  call({
    Fragment$AboutDto? aboutServer,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$AboutDto<TRes> get aboutServer =>
      CopyWith$Fragment$AboutDto.stub(_res);
}

const documentNodeQueryGetAbout = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.query,
    name: NameNode(value: 'GetAbout'),
    variableDefinitions: [],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'aboutServer'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: SelectionSetNode(selections: [
          FragmentSpreadNode(
            name: NameNode(value: 'AboutDto'),
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
  fragmentDefinitionAboutDto,
]);
Query$GetAbout _parserFn$Query$GetAbout(Map<String, dynamic> data) =>
    Query$GetAbout.fromJson(data);
typedef OnQueryComplete$Query$GetAbout = FutureOr<void> Function(
  Map<String, dynamic>?,
  Query$GetAbout?,
);

class Options$Query$GetAbout extends graphql.QueryOptions<Query$GetAbout> {
  Options$Query$GetAbout({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetAbout? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$GetAbout? onComplete,
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
                    data == null ? null : _parserFn$Query$GetAbout(data),
                  ),
          onError: onError,
          document: documentNodeQueryGetAbout,
          parserFn: _parserFn$Query$GetAbout,
        );

  final OnQueryComplete$Query$GetAbout? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onComplete == null
            ? super.properties
            : super.properties.where((property) => property != onComplete),
        onCompleteWithParsed,
      ];
}

class WatchOptions$Query$GetAbout
    extends graphql.WatchQueryOptions<Query$GetAbout> {
  WatchOptions$Query$GetAbout({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetAbout? typedOptimisticResult,
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
          document: documentNodeQueryGetAbout,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Query$GetAbout,
        );
}

class FetchMoreOptions$Query$GetAbout extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$GetAbout({required graphql.UpdateQuery updateQuery})
      : super(
          updateQuery: updateQuery,
          document: documentNodeQueryGetAbout,
        );
}

extension ClientExtension$Query$GetAbout on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$GetAbout>> query$GetAbout(
          [Options$Query$GetAbout? options]) async =>
      await this.query(options ?? Options$Query$GetAbout());

  graphql.ObservableQuery<Query$GetAbout> watchQuery$GetAbout(
          [WatchOptions$Query$GetAbout? options]) =>
      this.watchQuery(options ?? WatchOptions$Query$GetAbout());

  void writeQuery$GetAbout({
    required Query$GetAbout data,
    bool broadcast = true,
  }) =>
      this.writeQuery(
        graphql.Request(
            operation: graphql.Operation(document: documentNodeQueryGetAbout)),
        data: data.toJson(),
        broadcast: broadcast,
      );

  Query$GetAbout? readQuery$GetAbout({bool optimistic = true}) {
    final result = this.readQuery(
      graphql.Request(
          operation: graphql.Operation(document: documentNodeQueryGetAbout)),
      optimistic: optimistic,
    );
    return result == null ? null : Query$GetAbout.fromJson(result);
  }
}

graphql_flutter.QueryHookResult<Query$GetAbout> useQuery$GetAbout(
        [Options$Query$GetAbout? options]) =>
    graphql_flutter.useQuery(options ?? Options$Query$GetAbout());
graphql.ObservableQuery<Query$GetAbout> useWatchQuery$GetAbout(
        [WatchOptions$Query$GetAbout? options]) =>
    graphql_flutter.useWatchQuery(options ?? WatchOptions$Query$GetAbout());

class Query$GetAbout$Widget extends graphql_flutter.Query<Query$GetAbout> {
  Query$GetAbout$Widget({
    widgets.Key? key,
    Options$Query$GetAbout? options,
    required graphql_flutter.QueryBuilder<Query$GetAbout> builder,
  }) : super(
          key: key,
          options: options ?? Options$Query$GetAbout(),
          builder: builder,
        );
}
