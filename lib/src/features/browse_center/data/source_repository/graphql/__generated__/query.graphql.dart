import '../../../../../../graphql/__generated__/schema.graphql.dart';
import '../../../../../manga_book/domain/chapter/graphql/__generated__/fragment.graphql.dart';
import '../../../../../manga_book/domain/manga/graphql/__generated__/fragment.graphql.dart';
import '../../../../domain/filter/graphql/__generated__/fragment.graphql.dart';
import '../../../../domain/manga_page/graphql/__generated__/fragment.graphql.dart';
import '../../../../domain/source/graphql/__generated__/fragment.graphql.dart';
import '../../../../domain/source_preference/graphql/__generated__/fragment.graphql.dart';
import 'dart:async';
import 'package:catalyst/src/utils/misc/scalars.dart';
import 'package:flutter/widgets.dart' as widgets;
import 'package:gql/ast.dart';
import 'package:graphql/client.dart' as graphql;
import 'package:graphql_flutter/graphql_flutter.dart' as graphql_flutter;

class Query$SourceList {
  Query$SourceList({
    required this.sources,
    this.$__typename = 'Query',
  });

  factory Query$SourceList.fromJson(Map<String, dynamic> json) {
    final l$sources = json['sources'];
    final l$$__typename = json['__typename'];
    return Query$SourceList(
      sources: Query$SourceList$sources.fromJson(
          (l$sources as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Query$SourceList$sources sources;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$sources = sources;
    _resultData['sources'] = l$sources.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$sources = sources;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$sources,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$SourceList || runtimeType != other.runtimeType) {
      return false;
    }
    final l$sources = sources;
    final lOther$sources = other.sources;
    if (l$sources != lOther$sources) {
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

extension UtilityExtension$Query$SourceList on Query$SourceList {
  CopyWith$Query$SourceList<Query$SourceList> get copyWith =>
      CopyWith$Query$SourceList(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Query$SourceList<TRes> {
  factory CopyWith$Query$SourceList(
    Query$SourceList instance,
    TRes Function(Query$SourceList) then,
  ) = _CopyWithImpl$Query$SourceList;

  factory CopyWith$Query$SourceList.stub(TRes res) =
      _CopyWithStubImpl$Query$SourceList;

  TRes call({
    Query$SourceList$sources? sources,
    String? $__typename,
  });
  CopyWith$Query$SourceList$sources<TRes> get sources;
}

class _CopyWithImpl$Query$SourceList<TRes>
    implements CopyWith$Query$SourceList<TRes> {
  _CopyWithImpl$Query$SourceList(
    this._instance,
    this._then,
  );

  final Query$SourceList _instance;

  final TRes Function(Query$SourceList) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? sources = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$SourceList(
        sources: sources == _undefined || sources == null
            ? _instance.sources
            : (sources as Query$SourceList$sources),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$SourceList$sources<TRes> get sources {
    final local$sources = _instance.sources;
    return CopyWith$Query$SourceList$sources(
        local$sources, (e) => call(sources: e));
  }
}

class _CopyWithStubImpl$Query$SourceList<TRes>
    implements CopyWith$Query$SourceList<TRes> {
  _CopyWithStubImpl$Query$SourceList(this._res);

  TRes _res;

  call({
    Query$SourceList$sources? sources,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$SourceList$sources<TRes> get sources =>
      CopyWith$Query$SourceList$sources.stub(_res);
}

const documentNodeQuerySourceList = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.query,
    name: NameNode(value: 'SourceList'),
    variableDefinitions: [],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'sources'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: SelectionSetNode(selections: [
          FieldNode(
            name: NameNode(value: 'nodes'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: SelectionSetNode(selections: [
              FragmentSpreadNode(
                name: NameNode(value: 'SourceDto'),
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
  fragmentDefinitionSourceDto,
]);
Query$SourceList _parserFn$Query$SourceList(Map<String, dynamic> data) =>
    Query$SourceList.fromJson(data);
typedef OnQueryComplete$Query$SourceList = FutureOr<void> Function(
  Map<String, dynamic>?,
  Query$SourceList?,
);

class Options$Query$SourceList extends graphql.QueryOptions<Query$SourceList> {
  Options$Query$SourceList({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$SourceList? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$SourceList? onComplete,
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
                    data == null ? null : _parserFn$Query$SourceList(data),
                  ),
          onError: onError,
          document: documentNodeQuerySourceList,
          parserFn: _parserFn$Query$SourceList,
        );

  final OnQueryComplete$Query$SourceList? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onComplete == null
            ? super.properties
            : super.properties.where((property) => property != onComplete),
        onCompleteWithParsed,
      ];
}

class WatchOptions$Query$SourceList
    extends graphql.WatchQueryOptions<Query$SourceList> {
  WatchOptions$Query$SourceList({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$SourceList? typedOptimisticResult,
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
          document: documentNodeQuerySourceList,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Query$SourceList,
        );
}

class FetchMoreOptions$Query$SourceList extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$SourceList({required graphql.UpdateQuery updateQuery})
      : super(
          updateQuery: updateQuery,
          document: documentNodeQuerySourceList,
        );
}

extension ClientExtension$Query$SourceList on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$SourceList>> query$SourceList(
          [Options$Query$SourceList? options]) async =>
      await this.query(options ?? Options$Query$SourceList());

  graphql.ObservableQuery<Query$SourceList> watchQuery$SourceList(
          [WatchOptions$Query$SourceList? options]) =>
      this.watchQuery(options ?? WatchOptions$Query$SourceList());

  void writeQuery$SourceList({
    required Query$SourceList data,
    bool broadcast = true,
  }) =>
      this.writeQuery(
        graphql.Request(
            operation:
                graphql.Operation(document: documentNodeQuerySourceList)),
        data: data.toJson(),
        broadcast: broadcast,
      );

  Query$SourceList? readQuery$SourceList({bool optimistic = true}) {
    final result = this.readQuery(
      graphql.Request(
          operation: graphql.Operation(document: documentNodeQuerySourceList)),
      optimistic: optimistic,
    );
    return result == null ? null : Query$SourceList.fromJson(result);
  }
}

graphql_flutter.QueryHookResult<Query$SourceList> useQuery$SourceList(
        [Options$Query$SourceList? options]) =>
    graphql_flutter.useQuery(options ?? Options$Query$SourceList());
graphql.ObservableQuery<Query$SourceList> useWatchQuery$SourceList(
        [WatchOptions$Query$SourceList? options]) =>
    graphql_flutter.useWatchQuery(options ?? WatchOptions$Query$SourceList());

class Query$SourceList$Widget extends graphql_flutter.Query<Query$SourceList> {
  Query$SourceList$Widget({
    widgets.Key? key,
    Options$Query$SourceList? options,
    required graphql_flutter.QueryBuilder<Query$SourceList> builder,
  }) : super(
          key: key,
          options: options ?? Options$Query$SourceList(),
          builder: builder,
        );
}

class Query$SourceList$sources {
  Query$SourceList$sources({
    required this.nodes,
    this.$__typename = 'SourceNodeList',
  });

  factory Query$SourceList$sources.fromJson(Map<String, dynamic> json) {
    final l$nodes = json['nodes'];
    final l$$__typename = json['__typename'];
    return Query$SourceList$sources(
      nodes: (l$nodes as List<dynamic>)
          .map((e) => Fragment$SourceDto.fromJson((e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final List<Fragment$SourceDto> nodes;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$nodes = nodes;
    _resultData['nodes'] = l$nodes.map((e) => e.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$nodes = nodes;
    final l$$__typename = $__typename;
    return Object.hashAll([
      Object.hashAll(l$nodes.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$SourceList$sources ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$nodes = nodes;
    final lOther$nodes = other.nodes;
    if (l$nodes.length != lOther$nodes.length) {
      return false;
    }
    for (int i = 0; i < l$nodes.length; i++) {
      final l$nodes$entry = l$nodes[i];
      final lOther$nodes$entry = lOther$nodes[i];
      if (l$nodes$entry != lOther$nodes$entry) {
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

extension UtilityExtension$Query$SourceList$sources
    on Query$SourceList$sources {
  CopyWith$Query$SourceList$sources<Query$SourceList$sources> get copyWith =>
      CopyWith$Query$SourceList$sources(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Query$SourceList$sources<TRes> {
  factory CopyWith$Query$SourceList$sources(
    Query$SourceList$sources instance,
    TRes Function(Query$SourceList$sources) then,
  ) = _CopyWithImpl$Query$SourceList$sources;

  factory CopyWith$Query$SourceList$sources.stub(TRes res) =
      _CopyWithStubImpl$Query$SourceList$sources;

  TRes call({
    List<Fragment$SourceDto>? nodes,
    String? $__typename,
  });
  TRes nodes(
      Iterable<Fragment$SourceDto> Function(
              Iterable<CopyWith$Fragment$SourceDto<Fragment$SourceDto>>)
          _fn);
}

class _CopyWithImpl$Query$SourceList$sources<TRes>
    implements CopyWith$Query$SourceList$sources<TRes> {
  _CopyWithImpl$Query$SourceList$sources(
    this._instance,
    this._then,
  );

  final Query$SourceList$sources _instance;

  final TRes Function(Query$SourceList$sources) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? nodes = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$SourceList$sources(
        nodes: nodes == _undefined || nodes == null
            ? _instance.nodes
            : (nodes as List<Fragment$SourceDto>),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  TRes nodes(
          Iterable<Fragment$SourceDto> Function(
                  Iterable<CopyWith$Fragment$SourceDto<Fragment$SourceDto>>)
              _fn) =>
      call(
          nodes: _fn(_instance.nodes.map((e) => CopyWith$Fragment$SourceDto(
                e,
                (i) => i,
              ))).toList());
}

class _CopyWithStubImpl$Query$SourceList$sources<TRes>
    implements CopyWith$Query$SourceList$sources<TRes> {
  _CopyWithStubImpl$Query$SourceList$sources(this._res);

  TRes _res;

  call({
    List<Fragment$SourceDto>? nodes,
    String? $__typename,
  }) =>
      _res;

  nodes(_fn) => _res;
}

class Variables$Query$SourceFilterById {
  factory Variables$Query$SourceFilterById({required String id}) =>
      Variables$Query$SourceFilterById._({
        r'id': id,
      });

  Variables$Query$SourceFilterById._(this._$data);

  factory Variables$Query$SourceFilterById.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$id = data['id'];
    result$data['id'] = longStringFromJson(l$id);
    return Variables$Query$SourceFilterById._(result$data);
  }

  Map<String, dynamic> _$data;

  String get id => (_$data['id'] as String);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$id = id;
    result$data['id'] = longStringToJson(l$id);
    return result$data;
  }

  CopyWith$Variables$Query$SourceFilterById<Variables$Query$SourceFilterById>
      get copyWith => CopyWith$Variables$Query$SourceFilterById(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Query$SourceFilterById ||
        runtimeType != other.runtimeType) {
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
    final l$id = id;
    return Object.hashAll([l$id]);
  }
}

abstract class CopyWith$Variables$Query$SourceFilterById<TRes> {
  factory CopyWith$Variables$Query$SourceFilterById(
    Variables$Query$SourceFilterById instance,
    TRes Function(Variables$Query$SourceFilterById) then,
  ) = _CopyWithImpl$Variables$Query$SourceFilterById;

  factory CopyWith$Variables$Query$SourceFilterById.stub(TRes res) =
      _CopyWithStubImpl$Variables$Query$SourceFilterById;

  TRes call({String? id});
}

class _CopyWithImpl$Variables$Query$SourceFilterById<TRes>
    implements CopyWith$Variables$Query$SourceFilterById<TRes> {
  _CopyWithImpl$Variables$Query$SourceFilterById(
    this._instance,
    this._then,
  );

  final Variables$Query$SourceFilterById _instance;

  final TRes Function(Variables$Query$SourceFilterById) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? id = _undefined}) =>
      _then(Variables$Query$SourceFilterById._({
        ..._instance._$data,
        if (id != _undefined && id != null) 'id': (id as String),
      }));
}

class _CopyWithStubImpl$Variables$Query$SourceFilterById<TRes>
    implements CopyWith$Variables$Query$SourceFilterById<TRes> {
  _CopyWithStubImpl$Variables$Query$SourceFilterById(this._res);

  TRes _res;

  call({String? id}) => _res;
}

class Query$SourceFilterById {
  Query$SourceFilterById({
    required this.source,
    this.$__typename = 'Query',
  });

  factory Query$SourceFilterById.fromJson(Map<String, dynamic> json) {
    final l$source = json['source'];
    final l$$__typename = json['__typename'];
    return Query$SourceFilterById(
      source: Query$SourceFilterById$source.fromJson(
          (l$source as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Query$SourceFilterById$source source;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$source = source;
    _resultData['source'] = l$source.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$source = source;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$source,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$SourceFilterById || runtimeType != other.runtimeType) {
      return false;
    }
    final l$source = source;
    final lOther$source = other.source;
    if (l$source != lOther$source) {
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

extension UtilityExtension$Query$SourceFilterById on Query$SourceFilterById {
  CopyWith$Query$SourceFilterById<Query$SourceFilterById> get copyWith =>
      CopyWith$Query$SourceFilterById(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Query$SourceFilterById<TRes> {
  factory CopyWith$Query$SourceFilterById(
    Query$SourceFilterById instance,
    TRes Function(Query$SourceFilterById) then,
  ) = _CopyWithImpl$Query$SourceFilterById;

  factory CopyWith$Query$SourceFilterById.stub(TRes res) =
      _CopyWithStubImpl$Query$SourceFilterById;

  TRes call({
    Query$SourceFilterById$source? source,
    String? $__typename,
  });
  CopyWith$Query$SourceFilterById$source<TRes> get source;
}

class _CopyWithImpl$Query$SourceFilterById<TRes>
    implements CopyWith$Query$SourceFilterById<TRes> {
  _CopyWithImpl$Query$SourceFilterById(
    this._instance,
    this._then,
  );

  final Query$SourceFilterById _instance;

  final TRes Function(Query$SourceFilterById) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? source = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$SourceFilterById(
        source: source == _undefined || source == null
            ? _instance.source
            : (source as Query$SourceFilterById$source),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$SourceFilterById$source<TRes> get source {
    final local$source = _instance.source;
    return CopyWith$Query$SourceFilterById$source(
        local$source, (e) => call(source: e));
  }
}

class _CopyWithStubImpl$Query$SourceFilterById<TRes>
    implements CopyWith$Query$SourceFilterById<TRes> {
  _CopyWithStubImpl$Query$SourceFilterById(this._res);

  TRes _res;

  call({
    Query$SourceFilterById$source? source,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$SourceFilterById$source<TRes> get source =>
      CopyWith$Query$SourceFilterById$source.stub(_res);
}

const documentNodeQuerySourceFilterById = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.query,
    name: NameNode(value: 'SourceFilterById'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'id')),
        type: NamedTypeNode(
          name: NameNode(value: 'LongString'),
          isNonNull: true,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      )
    ],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'source'),
        alias: null,
        arguments: [
          ArgumentNode(
            name: NameNode(value: 'id'),
            value: VariableNode(name: NameNode(value: 'id')),
          )
        ],
        directives: [],
        selectionSet: SelectionSetNode(selections: [
          FieldNode(
            name: NameNode(value: 'filters'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: SelectionSetNode(selections: [
              FragmentSpreadNode(
                name: NameNode(value: 'FilterDto'),
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
  fragmentDefinitionFilterDto,
  fragmentDefinitionPrimitiveFilterDto,
  fragmentDefinitionSortSelectionDto,
]);
Query$SourceFilterById _parserFn$Query$SourceFilterById(
        Map<String, dynamic> data) =>
    Query$SourceFilterById.fromJson(data);
typedef OnQueryComplete$Query$SourceFilterById = FutureOr<void> Function(
  Map<String, dynamic>?,
  Query$SourceFilterById?,
);

class Options$Query$SourceFilterById
    extends graphql.QueryOptions<Query$SourceFilterById> {
  Options$Query$SourceFilterById({
    String? operationName,
    required Variables$Query$SourceFilterById variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$SourceFilterById? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$SourceFilterById? onComplete,
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
                    data == null
                        ? null
                        : _parserFn$Query$SourceFilterById(data),
                  ),
          onError: onError,
          document: documentNodeQuerySourceFilterById,
          parserFn: _parserFn$Query$SourceFilterById,
        );

  final OnQueryComplete$Query$SourceFilterById? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onComplete == null
            ? super.properties
            : super.properties.where((property) => property != onComplete),
        onCompleteWithParsed,
      ];
}

class WatchOptions$Query$SourceFilterById
    extends graphql.WatchQueryOptions<Query$SourceFilterById> {
  WatchOptions$Query$SourceFilterById({
    String? operationName,
    required Variables$Query$SourceFilterById variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$SourceFilterById? typedOptimisticResult,
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
          document: documentNodeQuerySourceFilterById,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Query$SourceFilterById,
        );
}

class FetchMoreOptions$Query$SourceFilterById extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$SourceFilterById({
    required graphql.UpdateQuery updateQuery,
    required Variables$Query$SourceFilterById variables,
  }) : super(
          updateQuery: updateQuery,
          variables: variables.toJson(),
          document: documentNodeQuerySourceFilterById,
        );
}

extension ClientExtension$Query$SourceFilterById on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$SourceFilterById>> query$SourceFilterById(
          Options$Query$SourceFilterById options) async =>
      await this.query(options);

  graphql.ObservableQuery<Query$SourceFilterById> watchQuery$SourceFilterById(
          WatchOptions$Query$SourceFilterById options) =>
      this.watchQuery(options);

  void writeQuery$SourceFilterById({
    required Query$SourceFilterById data,
    required Variables$Query$SourceFilterById variables,
    bool broadcast = true,
  }) =>
      this.writeQuery(
        graphql.Request(
          operation:
              graphql.Operation(document: documentNodeQuerySourceFilterById),
          variables: variables.toJson(),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );

  Query$SourceFilterById? readQuery$SourceFilterById({
    required Variables$Query$SourceFilterById variables,
    bool optimistic = true,
  }) {
    final result = this.readQuery(
      graphql.Request(
        operation:
            graphql.Operation(document: documentNodeQuerySourceFilterById),
        variables: variables.toJson(),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Query$SourceFilterById.fromJson(result);
  }
}

graphql_flutter.QueryHookResult<Query$SourceFilterById>
    useQuery$SourceFilterById(Options$Query$SourceFilterById options) =>
        graphql_flutter.useQuery(options);
graphql.ObservableQuery<Query$SourceFilterById> useWatchQuery$SourceFilterById(
        WatchOptions$Query$SourceFilterById options) =>
    graphql_flutter.useWatchQuery(options);

class Query$SourceFilterById$Widget
    extends graphql_flutter.Query<Query$SourceFilterById> {
  Query$SourceFilterById$Widget({
    widgets.Key? key,
    required Options$Query$SourceFilterById options,
    required graphql_flutter.QueryBuilder<Query$SourceFilterById> builder,
  }) : super(
          key: key,
          options: options,
          builder: builder,
        );
}

class Query$SourceFilterById$source {
  Query$SourceFilterById$source({
    required this.filters,
    this.$__typename = 'SourceType',
  });

  factory Query$SourceFilterById$source.fromJson(Map<String, dynamic> json) {
    final l$filters = json['filters'];
    final l$$__typename = json['__typename'];
    return Query$SourceFilterById$source(
      filters: (l$filters as List<dynamic>)
          .map((e) => Fragment$FilterDto.fromJson((e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final List<Fragment$FilterDto> filters;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$filters = filters;
    _resultData['filters'] = l$filters.map((e) => e.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$filters = filters;
    final l$$__typename = $__typename;
    return Object.hashAll([
      Object.hashAll(l$filters.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$SourceFilterById$source ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$filters = filters;
    final lOther$filters = other.filters;
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
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Query$SourceFilterById$source
    on Query$SourceFilterById$source {
  CopyWith$Query$SourceFilterById$source<Query$SourceFilterById$source>
      get copyWith => CopyWith$Query$SourceFilterById$source(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$SourceFilterById$source<TRes> {
  factory CopyWith$Query$SourceFilterById$source(
    Query$SourceFilterById$source instance,
    TRes Function(Query$SourceFilterById$source) then,
  ) = _CopyWithImpl$Query$SourceFilterById$source;

  factory CopyWith$Query$SourceFilterById$source.stub(TRes res) =
      _CopyWithStubImpl$Query$SourceFilterById$source;

  TRes call({
    List<Fragment$FilterDto>? filters,
    String? $__typename,
  });
  TRes filters(
      Iterable<Fragment$FilterDto> Function(
              Iterable<CopyWith$Fragment$FilterDto<Fragment$FilterDto>>)
          _fn);
}

class _CopyWithImpl$Query$SourceFilterById$source<TRes>
    implements CopyWith$Query$SourceFilterById$source<TRes> {
  _CopyWithImpl$Query$SourceFilterById$source(
    this._instance,
    this._then,
  );

  final Query$SourceFilterById$source _instance;

  final TRes Function(Query$SourceFilterById$source) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? filters = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$SourceFilterById$source(
        filters: filters == _undefined || filters == null
            ? _instance.filters
            : (filters as List<Fragment$FilterDto>),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  TRes filters(
          Iterable<Fragment$FilterDto> Function(
                  Iterable<CopyWith$Fragment$FilterDto<Fragment$FilterDto>>)
              _fn) =>
      call(
          filters: _fn(_instance.filters.map((e) => CopyWith$Fragment$FilterDto(
                e,
                (i) => i,
              ))).toList());
}

class _CopyWithStubImpl$Query$SourceFilterById$source<TRes>
    implements CopyWith$Query$SourceFilterById$source<TRes> {
  _CopyWithStubImpl$Query$SourceFilterById$source(this._res);

  TRes _res;

  call({
    List<Fragment$FilterDto>? filters,
    String? $__typename,
  }) =>
      _res;

  filters(_fn) => _res;
}

class Variables$Query$SourceById {
  factory Variables$Query$SourceById({required String id}) =>
      Variables$Query$SourceById._({
        r'id': id,
      });

  Variables$Query$SourceById._(this._$data);

  factory Variables$Query$SourceById.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$id = data['id'];
    result$data['id'] = longStringFromJson(l$id);
    return Variables$Query$SourceById._(result$data);
  }

  Map<String, dynamic> _$data;

  String get id => (_$data['id'] as String);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$id = id;
    result$data['id'] = longStringToJson(l$id);
    return result$data;
  }

  CopyWith$Variables$Query$SourceById<Variables$Query$SourceById>
      get copyWith => CopyWith$Variables$Query$SourceById(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Query$SourceById ||
        runtimeType != other.runtimeType) {
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
    final l$id = id;
    return Object.hashAll([l$id]);
  }
}

abstract class CopyWith$Variables$Query$SourceById<TRes> {
  factory CopyWith$Variables$Query$SourceById(
    Variables$Query$SourceById instance,
    TRes Function(Variables$Query$SourceById) then,
  ) = _CopyWithImpl$Variables$Query$SourceById;

  factory CopyWith$Variables$Query$SourceById.stub(TRes res) =
      _CopyWithStubImpl$Variables$Query$SourceById;

  TRes call({String? id});
}

class _CopyWithImpl$Variables$Query$SourceById<TRes>
    implements CopyWith$Variables$Query$SourceById<TRes> {
  _CopyWithImpl$Variables$Query$SourceById(
    this._instance,
    this._then,
  );

  final Variables$Query$SourceById _instance;

  final TRes Function(Variables$Query$SourceById) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? id = _undefined}) => _then(Variables$Query$SourceById._({
        ..._instance._$data,
        if (id != _undefined && id != null) 'id': (id as String),
      }));
}

class _CopyWithStubImpl$Variables$Query$SourceById<TRes>
    implements CopyWith$Variables$Query$SourceById<TRes> {
  _CopyWithStubImpl$Variables$Query$SourceById(this._res);

  TRes _res;

  call({String? id}) => _res;
}

class Query$SourceById {
  Query$SourceById({
    required this.source,
    this.$__typename = 'Query',
  });

  factory Query$SourceById.fromJson(Map<String, dynamic> json) {
    final l$source = json['source'];
    final l$$__typename = json['__typename'];
    return Query$SourceById(
      source: Fragment$SourceDto.fromJson((l$source as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Fragment$SourceDto source;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$source = source;
    _resultData['source'] = l$source.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$source = source;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$source,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$SourceById || runtimeType != other.runtimeType) {
      return false;
    }
    final l$source = source;
    final lOther$source = other.source;
    if (l$source != lOther$source) {
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

extension UtilityExtension$Query$SourceById on Query$SourceById {
  CopyWith$Query$SourceById<Query$SourceById> get copyWith =>
      CopyWith$Query$SourceById(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Query$SourceById<TRes> {
  factory CopyWith$Query$SourceById(
    Query$SourceById instance,
    TRes Function(Query$SourceById) then,
  ) = _CopyWithImpl$Query$SourceById;

  factory CopyWith$Query$SourceById.stub(TRes res) =
      _CopyWithStubImpl$Query$SourceById;

  TRes call({
    Fragment$SourceDto? source,
    String? $__typename,
  });
  CopyWith$Fragment$SourceDto<TRes> get source;
}

class _CopyWithImpl$Query$SourceById<TRes>
    implements CopyWith$Query$SourceById<TRes> {
  _CopyWithImpl$Query$SourceById(
    this._instance,
    this._then,
  );

  final Query$SourceById _instance;

  final TRes Function(Query$SourceById) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? source = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$SourceById(
        source: source == _undefined || source == null
            ? _instance.source
            : (source as Fragment$SourceDto),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Fragment$SourceDto<TRes> get source {
    final local$source = _instance.source;
    return CopyWith$Fragment$SourceDto(local$source, (e) => call(source: e));
  }
}

class _CopyWithStubImpl$Query$SourceById<TRes>
    implements CopyWith$Query$SourceById<TRes> {
  _CopyWithStubImpl$Query$SourceById(this._res);

  TRes _res;

  call({
    Fragment$SourceDto? source,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$SourceDto<TRes> get source =>
      CopyWith$Fragment$SourceDto.stub(_res);
}

const documentNodeQuerySourceById = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.query,
    name: NameNode(value: 'SourceById'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'id')),
        type: NamedTypeNode(
          name: NameNode(value: 'LongString'),
          isNonNull: true,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      )
    ],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'source'),
        alias: null,
        arguments: [
          ArgumentNode(
            name: NameNode(value: 'id'),
            value: VariableNode(name: NameNode(value: 'id')),
          )
        ],
        directives: [],
        selectionSet: SelectionSetNode(selections: [
          FragmentSpreadNode(
            name: NameNode(value: 'SourceDto'),
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
  fragmentDefinitionSourceDto,
]);
Query$SourceById _parserFn$Query$SourceById(Map<String, dynamic> data) =>
    Query$SourceById.fromJson(data);
typedef OnQueryComplete$Query$SourceById = FutureOr<void> Function(
  Map<String, dynamic>?,
  Query$SourceById?,
);

class Options$Query$SourceById extends graphql.QueryOptions<Query$SourceById> {
  Options$Query$SourceById({
    String? operationName,
    required Variables$Query$SourceById variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$SourceById? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$SourceById? onComplete,
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
                    data == null ? null : _parserFn$Query$SourceById(data),
                  ),
          onError: onError,
          document: documentNodeQuerySourceById,
          parserFn: _parserFn$Query$SourceById,
        );

  final OnQueryComplete$Query$SourceById? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onComplete == null
            ? super.properties
            : super.properties.where((property) => property != onComplete),
        onCompleteWithParsed,
      ];
}

class WatchOptions$Query$SourceById
    extends graphql.WatchQueryOptions<Query$SourceById> {
  WatchOptions$Query$SourceById({
    String? operationName,
    required Variables$Query$SourceById variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$SourceById? typedOptimisticResult,
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
          document: documentNodeQuerySourceById,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Query$SourceById,
        );
}

class FetchMoreOptions$Query$SourceById extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$SourceById({
    required graphql.UpdateQuery updateQuery,
    required Variables$Query$SourceById variables,
  }) : super(
          updateQuery: updateQuery,
          variables: variables.toJson(),
          document: documentNodeQuerySourceById,
        );
}

extension ClientExtension$Query$SourceById on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$SourceById>> query$SourceById(
          Options$Query$SourceById options) async =>
      await this.query(options);

  graphql.ObservableQuery<Query$SourceById> watchQuery$SourceById(
          WatchOptions$Query$SourceById options) =>
      this.watchQuery(options);

  void writeQuery$SourceById({
    required Query$SourceById data,
    required Variables$Query$SourceById variables,
    bool broadcast = true,
  }) =>
      this.writeQuery(
        graphql.Request(
          operation: graphql.Operation(document: documentNodeQuerySourceById),
          variables: variables.toJson(),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );

  Query$SourceById? readQuery$SourceById({
    required Variables$Query$SourceById variables,
    bool optimistic = true,
  }) {
    final result = this.readQuery(
      graphql.Request(
        operation: graphql.Operation(document: documentNodeQuerySourceById),
        variables: variables.toJson(),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Query$SourceById.fromJson(result);
  }
}

graphql_flutter.QueryHookResult<Query$SourceById> useQuery$SourceById(
        Options$Query$SourceById options) =>
    graphql_flutter.useQuery(options);
graphql.ObservableQuery<Query$SourceById> useWatchQuery$SourceById(
        WatchOptions$Query$SourceById options) =>
    graphql_flutter.useWatchQuery(options);

class Query$SourceById$Widget extends graphql_flutter.Query<Query$SourceById> {
  Query$SourceById$Widget({
    widgets.Key? key,
    required Options$Query$SourceById options,
    required graphql_flutter.QueryBuilder<Query$SourceById> builder,
  }) : super(
          key: key,
          options: options,
          builder: builder,
        );
}

class Variables$Mutation$FetchSourceManga {
  factory Variables$Mutation$FetchSourceManga(
          {required Input$FetchSourceMangaInput input}) =>
      Variables$Mutation$FetchSourceManga._({
        r'input': input,
      });

  Variables$Mutation$FetchSourceManga._(this._$data);

  factory Variables$Mutation$FetchSourceManga.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$input = data['input'];
    result$data['input'] =
        Input$FetchSourceMangaInput.fromJson((l$input as Map<String, dynamic>));
    return Variables$Mutation$FetchSourceManga._(result$data);
  }

  Map<String, dynamic> _$data;

  Input$FetchSourceMangaInput get input =>
      (_$data['input'] as Input$FetchSourceMangaInput);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$input = input;
    result$data['input'] = l$input.toJson();
    return result$data;
  }

  CopyWith$Variables$Mutation$FetchSourceManga<
          Variables$Mutation$FetchSourceManga>
      get copyWith => CopyWith$Variables$Mutation$FetchSourceManga(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$FetchSourceManga ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$input = input;
    final lOther$input = other.input;
    if (l$input != lOther$input) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$input = input;
    return Object.hashAll([l$input]);
  }
}

abstract class CopyWith$Variables$Mutation$FetchSourceManga<TRes> {
  factory CopyWith$Variables$Mutation$FetchSourceManga(
    Variables$Mutation$FetchSourceManga instance,
    TRes Function(Variables$Mutation$FetchSourceManga) then,
  ) = _CopyWithImpl$Variables$Mutation$FetchSourceManga;

  factory CopyWith$Variables$Mutation$FetchSourceManga.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$FetchSourceManga;

  TRes call({Input$FetchSourceMangaInput? input});
}

class _CopyWithImpl$Variables$Mutation$FetchSourceManga<TRes>
    implements CopyWith$Variables$Mutation$FetchSourceManga<TRes> {
  _CopyWithImpl$Variables$Mutation$FetchSourceManga(
    this._instance,
    this._then,
  );

  final Variables$Mutation$FetchSourceManga _instance;

  final TRes Function(Variables$Mutation$FetchSourceManga) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? input = _undefined}) =>
      _then(Variables$Mutation$FetchSourceManga._({
        ..._instance._$data,
        if (input != _undefined && input != null)
          'input': (input as Input$FetchSourceMangaInput),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$FetchSourceManga<TRes>
    implements CopyWith$Variables$Mutation$FetchSourceManga<TRes> {
  _CopyWithStubImpl$Variables$Mutation$FetchSourceManga(this._res);

  TRes _res;

  call({Input$FetchSourceMangaInput? input}) => _res;
}

class Mutation$FetchSourceManga {
  Mutation$FetchSourceManga({
    this.fetchSourceManga,
    this.$__typename = 'Mutation',
  });

  factory Mutation$FetchSourceManga.fromJson(Map<String, dynamic> json) {
    final l$fetchSourceManga = json['fetchSourceManga'];
    final l$$__typename = json['__typename'];
    return Mutation$FetchSourceManga(
      fetchSourceManga: l$fetchSourceManga == null
          ? null
          : Fragment$SourceMangaPage.fromJson(
              (l$fetchSourceManga as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Fragment$SourceMangaPage? fetchSourceManga;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$fetchSourceManga = fetchSourceManga;
    _resultData['fetchSourceManga'] = l$fetchSourceManga?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$fetchSourceManga = fetchSourceManga;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$fetchSourceManga,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$FetchSourceManga ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$fetchSourceManga = fetchSourceManga;
    final lOther$fetchSourceManga = other.fetchSourceManga;
    if (l$fetchSourceManga != lOther$fetchSourceManga) {
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

extension UtilityExtension$Mutation$FetchSourceManga
    on Mutation$FetchSourceManga {
  CopyWith$Mutation$FetchSourceManga<Mutation$FetchSourceManga> get copyWith =>
      CopyWith$Mutation$FetchSourceManga(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Mutation$FetchSourceManga<TRes> {
  factory CopyWith$Mutation$FetchSourceManga(
    Mutation$FetchSourceManga instance,
    TRes Function(Mutation$FetchSourceManga) then,
  ) = _CopyWithImpl$Mutation$FetchSourceManga;

  factory CopyWith$Mutation$FetchSourceManga.stub(TRes res) =
      _CopyWithStubImpl$Mutation$FetchSourceManga;

  TRes call({
    Fragment$SourceMangaPage? fetchSourceManga,
    String? $__typename,
  });
  CopyWith$Fragment$SourceMangaPage<TRes> get fetchSourceManga;
}

class _CopyWithImpl$Mutation$FetchSourceManga<TRes>
    implements CopyWith$Mutation$FetchSourceManga<TRes> {
  _CopyWithImpl$Mutation$FetchSourceManga(
    this._instance,
    this._then,
  );

  final Mutation$FetchSourceManga _instance;

  final TRes Function(Mutation$FetchSourceManga) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? fetchSourceManga = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$FetchSourceManga(
        fetchSourceManga: fetchSourceManga == _undefined
            ? _instance.fetchSourceManga
            : (fetchSourceManga as Fragment$SourceMangaPage?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Fragment$SourceMangaPage<TRes> get fetchSourceManga {
    final local$fetchSourceManga = _instance.fetchSourceManga;
    return local$fetchSourceManga == null
        ? CopyWith$Fragment$SourceMangaPage.stub(_then(_instance))
        : CopyWith$Fragment$SourceMangaPage(
            local$fetchSourceManga, (e) => call(fetchSourceManga: e));
  }
}

class _CopyWithStubImpl$Mutation$FetchSourceManga<TRes>
    implements CopyWith$Mutation$FetchSourceManga<TRes> {
  _CopyWithStubImpl$Mutation$FetchSourceManga(this._res);

  TRes _res;

  call({
    Fragment$SourceMangaPage? fetchSourceManga,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$SourceMangaPage<TRes> get fetchSourceManga =>
      CopyWith$Fragment$SourceMangaPage.stub(_res);
}

const documentNodeMutationFetchSourceManga = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'FetchSourceManga'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'input')),
        type: NamedTypeNode(
          name: NameNode(value: 'FetchSourceMangaInput'),
          isNonNull: true,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      )
    ],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'fetchSourceManga'),
        alias: null,
        arguments: [
          ArgumentNode(
            name: NameNode(value: 'input'),
            value: VariableNode(name: NameNode(value: 'input')),
          )
        ],
        directives: [],
        selectionSet: SelectionSetNode(selections: [
          FragmentSpreadNode(
            name: NameNode(value: 'SourceMangaPage'),
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
  fragmentDefinitionSourceMangaPage,
  fragmentDefinitionMangaDto,
  fragmentDefinitionChapterDto,
  fragmentDefinitionSourceDto,
]);
Mutation$FetchSourceManga _parserFn$Mutation$FetchSourceManga(
        Map<String, dynamic> data) =>
    Mutation$FetchSourceManga.fromJson(data);
typedef OnMutationCompleted$Mutation$FetchSourceManga = FutureOr<void> Function(
  Map<String, dynamic>?,
  Mutation$FetchSourceManga?,
);

class Options$Mutation$FetchSourceManga
    extends graphql.MutationOptions<Mutation$FetchSourceManga> {
  Options$Mutation$FetchSourceManga({
    String? operationName,
    required Variables$Mutation$FetchSourceManga variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$FetchSourceManga? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$FetchSourceManga? onCompleted,
    graphql.OnMutationUpdate<Mutation$FetchSourceManga>? update,
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
                        : _parserFn$Mutation$FetchSourceManga(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationFetchSourceManga,
          parserFn: _parserFn$Mutation$FetchSourceManga,
        );

  final OnMutationCompleted$Mutation$FetchSourceManga? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$FetchSourceManga
    extends graphql.WatchQueryOptions<Mutation$FetchSourceManga> {
  WatchOptions$Mutation$FetchSourceManga({
    String? operationName,
    required Variables$Mutation$FetchSourceManga variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$FetchSourceManga? typedOptimisticResult,
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
          document: documentNodeMutationFetchSourceManga,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$FetchSourceManga,
        );
}

extension ClientExtension$Mutation$FetchSourceManga on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$FetchSourceManga>>
      mutate$FetchSourceManga(
              Options$Mutation$FetchSourceManga options) async =>
          await this.mutate(options);

  graphql.ObservableQuery<Mutation$FetchSourceManga>
      watchMutation$FetchSourceManga(
              WatchOptions$Mutation$FetchSourceManga options) =>
          this.watchMutation(options);
}

class Mutation$FetchSourceManga$HookResult {
  Mutation$FetchSourceManga$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$FetchSourceManga runMutation;

  final graphql.QueryResult<Mutation$FetchSourceManga> result;
}

Mutation$FetchSourceManga$HookResult useMutation$FetchSourceManga(
    [WidgetOptions$Mutation$FetchSourceManga? options]) {
  final result = graphql_flutter
      .useMutation(options ?? WidgetOptions$Mutation$FetchSourceManga());
  return Mutation$FetchSourceManga$HookResult(
    (variables, {optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables.toJson(),
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$FetchSourceManga>
    useWatchMutation$FetchSourceManga(
            WatchOptions$Mutation$FetchSourceManga options) =>
        graphql_flutter.useWatchMutation(options);

class WidgetOptions$Mutation$FetchSourceManga
    extends graphql.MutationOptions<Mutation$FetchSourceManga> {
  WidgetOptions$Mutation$FetchSourceManga({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$FetchSourceManga? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$FetchSourceManga? onCompleted,
    graphql.OnMutationUpdate<Mutation$FetchSourceManga>? update,
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
                        : _parserFn$Mutation$FetchSourceManga(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationFetchSourceManga,
          parserFn: _parserFn$Mutation$FetchSourceManga,
        );

  final OnMutationCompleted$Mutation$FetchSourceManga? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$FetchSourceManga
    = graphql.MultiSourceResult<Mutation$FetchSourceManga> Function(
  Variables$Mutation$FetchSourceManga, {
  Object? optimisticResult,
  Mutation$FetchSourceManga? typedOptimisticResult,
});
typedef Builder$Mutation$FetchSourceManga = widgets.Widget Function(
  RunMutation$Mutation$FetchSourceManga,
  graphql.QueryResult<Mutation$FetchSourceManga>?,
);

class Mutation$FetchSourceManga$Widget
    extends graphql_flutter.Mutation<Mutation$FetchSourceManga> {
  Mutation$FetchSourceManga$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$FetchSourceManga? options,
    required Builder$Mutation$FetchSourceManga builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$FetchSourceManga(),
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

class Variables$Query$SourcePreferenceById {
  factory Variables$Query$SourcePreferenceById({required String id}) =>
      Variables$Query$SourcePreferenceById._({
        r'id': id,
      });

  Variables$Query$SourcePreferenceById._(this._$data);

  factory Variables$Query$SourcePreferenceById.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$id = data['id'];
    result$data['id'] = longStringFromJson(l$id);
    return Variables$Query$SourcePreferenceById._(result$data);
  }

  Map<String, dynamic> _$data;

  String get id => (_$data['id'] as String);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$id = id;
    result$data['id'] = longStringToJson(l$id);
    return result$data;
  }

  CopyWith$Variables$Query$SourcePreferenceById<
          Variables$Query$SourcePreferenceById>
      get copyWith => CopyWith$Variables$Query$SourcePreferenceById(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Query$SourcePreferenceById ||
        runtimeType != other.runtimeType) {
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
    final l$id = id;
    return Object.hashAll([l$id]);
  }
}

abstract class CopyWith$Variables$Query$SourcePreferenceById<TRes> {
  factory CopyWith$Variables$Query$SourcePreferenceById(
    Variables$Query$SourcePreferenceById instance,
    TRes Function(Variables$Query$SourcePreferenceById) then,
  ) = _CopyWithImpl$Variables$Query$SourcePreferenceById;

  factory CopyWith$Variables$Query$SourcePreferenceById.stub(TRes res) =
      _CopyWithStubImpl$Variables$Query$SourcePreferenceById;

  TRes call({String? id});
}

class _CopyWithImpl$Variables$Query$SourcePreferenceById<TRes>
    implements CopyWith$Variables$Query$SourcePreferenceById<TRes> {
  _CopyWithImpl$Variables$Query$SourcePreferenceById(
    this._instance,
    this._then,
  );

  final Variables$Query$SourcePreferenceById _instance;

  final TRes Function(Variables$Query$SourcePreferenceById) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? id = _undefined}) =>
      _then(Variables$Query$SourcePreferenceById._({
        ..._instance._$data,
        if (id != _undefined && id != null) 'id': (id as String),
      }));
}

class _CopyWithStubImpl$Variables$Query$SourcePreferenceById<TRes>
    implements CopyWith$Variables$Query$SourcePreferenceById<TRes> {
  _CopyWithStubImpl$Variables$Query$SourcePreferenceById(this._res);

  TRes _res;

  call({String? id}) => _res;
}

class Query$SourcePreferenceById {
  Query$SourcePreferenceById({
    required this.source,
    this.$__typename = 'Query',
  });

  factory Query$SourcePreferenceById.fromJson(Map<String, dynamic> json) {
    final l$source = json['source'];
    final l$$__typename = json['__typename'];
    return Query$SourcePreferenceById(
      source: Query$SourcePreferenceById$source.fromJson(
          (l$source as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Query$SourcePreferenceById$source source;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$source = source;
    _resultData['source'] = l$source.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$source = source;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$source,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$SourcePreferenceById ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$source = source;
    final lOther$source = other.source;
    if (l$source != lOther$source) {
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

extension UtilityExtension$Query$SourcePreferenceById
    on Query$SourcePreferenceById {
  CopyWith$Query$SourcePreferenceById<Query$SourcePreferenceById>
      get copyWith => CopyWith$Query$SourcePreferenceById(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$SourcePreferenceById<TRes> {
  factory CopyWith$Query$SourcePreferenceById(
    Query$SourcePreferenceById instance,
    TRes Function(Query$SourcePreferenceById) then,
  ) = _CopyWithImpl$Query$SourcePreferenceById;

  factory CopyWith$Query$SourcePreferenceById.stub(TRes res) =
      _CopyWithStubImpl$Query$SourcePreferenceById;

  TRes call({
    Query$SourcePreferenceById$source? source,
    String? $__typename,
  });
  CopyWith$Query$SourcePreferenceById$source<TRes> get source;
}

class _CopyWithImpl$Query$SourcePreferenceById<TRes>
    implements CopyWith$Query$SourcePreferenceById<TRes> {
  _CopyWithImpl$Query$SourcePreferenceById(
    this._instance,
    this._then,
  );

  final Query$SourcePreferenceById _instance;

  final TRes Function(Query$SourcePreferenceById) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? source = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$SourcePreferenceById(
        source: source == _undefined || source == null
            ? _instance.source
            : (source as Query$SourcePreferenceById$source),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$SourcePreferenceById$source<TRes> get source {
    final local$source = _instance.source;
    return CopyWith$Query$SourcePreferenceById$source(
        local$source, (e) => call(source: e));
  }
}

class _CopyWithStubImpl$Query$SourcePreferenceById<TRes>
    implements CopyWith$Query$SourcePreferenceById<TRes> {
  _CopyWithStubImpl$Query$SourcePreferenceById(this._res);

  TRes _res;

  call({
    Query$SourcePreferenceById$source? source,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$SourcePreferenceById$source<TRes> get source =>
      CopyWith$Query$SourcePreferenceById$source.stub(_res);
}

const documentNodeQuerySourcePreferenceById = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.query,
    name: NameNode(value: 'SourcePreferenceById'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'id')),
        type: NamedTypeNode(
          name: NameNode(value: 'LongString'),
          isNonNull: true,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      )
    ],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'source'),
        alias: null,
        arguments: [
          ArgumentNode(
            name: NameNode(value: 'id'),
            value: VariableNode(name: NameNode(value: 'id')),
          )
        ],
        directives: [],
        selectionSet: SelectionSetNode(selections: [
          FieldNode(
            name: NameNode(value: 'preferences'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: SelectionSetNode(selections: [
              FragmentSpreadNode(
                name: NameNode(value: 'SourcePreference'),
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
  fragmentDefinitionSourcePreference,
]);
Query$SourcePreferenceById _parserFn$Query$SourcePreferenceById(
        Map<String, dynamic> data) =>
    Query$SourcePreferenceById.fromJson(data);
typedef OnQueryComplete$Query$SourcePreferenceById = FutureOr<void> Function(
  Map<String, dynamic>?,
  Query$SourcePreferenceById?,
);

class Options$Query$SourcePreferenceById
    extends graphql.QueryOptions<Query$SourcePreferenceById> {
  Options$Query$SourcePreferenceById({
    String? operationName,
    required Variables$Query$SourcePreferenceById variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$SourcePreferenceById? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$SourcePreferenceById? onComplete,
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
                    data == null
                        ? null
                        : _parserFn$Query$SourcePreferenceById(data),
                  ),
          onError: onError,
          document: documentNodeQuerySourcePreferenceById,
          parserFn: _parserFn$Query$SourcePreferenceById,
        );

  final OnQueryComplete$Query$SourcePreferenceById? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onComplete == null
            ? super.properties
            : super.properties.where((property) => property != onComplete),
        onCompleteWithParsed,
      ];
}

class WatchOptions$Query$SourcePreferenceById
    extends graphql.WatchQueryOptions<Query$SourcePreferenceById> {
  WatchOptions$Query$SourcePreferenceById({
    String? operationName,
    required Variables$Query$SourcePreferenceById variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$SourcePreferenceById? typedOptimisticResult,
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
          document: documentNodeQuerySourcePreferenceById,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Query$SourcePreferenceById,
        );
}

class FetchMoreOptions$Query$SourcePreferenceById
    extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$SourcePreferenceById({
    required graphql.UpdateQuery updateQuery,
    required Variables$Query$SourcePreferenceById variables,
  }) : super(
          updateQuery: updateQuery,
          variables: variables.toJson(),
          document: documentNodeQuerySourcePreferenceById,
        );
}

extension ClientExtension$Query$SourcePreferenceById on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$SourcePreferenceById>>
      query$SourcePreferenceById(
              Options$Query$SourcePreferenceById options) async =>
          await this.query(options);

  graphql.ObservableQuery<Query$SourcePreferenceById>
      watchQuery$SourcePreferenceById(
              WatchOptions$Query$SourcePreferenceById options) =>
          this.watchQuery(options);

  void writeQuery$SourcePreferenceById({
    required Query$SourcePreferenceById data,
    required Variables$Query$SourcePreferenceById variables,
    bool broadcast = true,
  }) =>
      this.writeQuery(
        graphql.Request(
          operation: graphql.Operation(
              document: documentNodeQuerySourcePreferenceById),
          variables: variables.toJson(),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );

  Query$SourcePreferenceById? readQuery$SourcePreferenceById({
    required Variables$Query$SourcePreferenceById variables,
    bool optimistic = true,
  }) {
    final result = this.readQuery(
      graphql.Request(
        operation:
            graphql.Operation(document: documentNodeQuerySourcePreferenceById),
        variables: variables.toJson(),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Query$SourcePreferenceById.fromJson(result);
  }
}

graphql_flutter.QueryHookResult<Query$SourcePreferenceById>
    useQuery$SourcePreferenceById(Options$Query$SourcePreferenceById options) =>
        graphql_flutter.useQuery(options);
graphql.ObservableQuery<Query$SourcePreferenceById>
    useWatchQuery$SourcePreferenceById(
            WatchOptions$Query$SourcePreferenceById options) =>
        graphql_flutter.useWatchQuery(options);

class Query$SourcePreferenceById$Widget
    extends graphql_flutter.Query<Query$SourcePreferenceById> {
  Query$SourcePreferenceById$Widget({
    widgets.Key? key,
    required Options$Query$SourcePreferenceById options,
    required graphql_flutter.QueryBuilder<Query$SourcePreferenceById> builder,
  }) : super(
          key: key,
          options: options,
          builder: builder,
        );
}

class Query$SourcePreferenceById$source {
  Query$SourcePreferenceById$source({
    required this.preferences,
    this.$__typename = 'SourceType',
  });

  factory Query$SourcePreferenceById$source.fromJson(
      Map<String, dynamic> json) {
    final l$preferences = json['preferences'];
    final l$$__typename = json['__typename'];
    return Query$SourcePreferenceById$source(
      preferences: (l$preferences as List<dynamic>)
          .map((e) =>
              Fragment$SourcePreference.fromJson((e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final List<Fragment$SourcePreference> preferences;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$preferences = preferences;
    _resultData['preferences'] = l$preferences.map((e) => e.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$preferences = preferences;
    final l$$__typename = $__typename;
    return Object.hashAll([
      Object.hashAll(l$preferences.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$SourcePreferenceById$source ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$preferences = preferences;
    final lOther$preferences = other.preferences;
    if (l$preferences.length != lOther$preferences.length) {
      return false;
    }
    for (int i = 0; i < l$preferences.length; i++) {
      final l$preferences$entry = l$preferences[i];
      final lOther$preferences$entry = lOther$preferences[i];
      if (l$preferences$entry != lOther$preferences$entry) {
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

extension UtilityExtension$Query$SourcePreferenceById$source
    on Query$SourcePreferenceById$source {
  CopyWith$Query$SourcePreferenceById$source<Query$SourcePreferenceById$source>
      get copyWith => CopyWith$Query$SourcePreferenceById$source(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$SourcePreferenceById$source<TRes> {
  factory CopyWith$Query$SourcePreferenceById$source(
    Query$SourcePreferenceById$source instance,
    TRes Function(Query$SourcePreferenceById$source) then,
  ) = _CopyWithImpl$Query$SourcePreferenceById$source;

  factory CopyWith$Query$SourcePreferenceById$source.stub(TRes res) =
      _CopyWithStubImpl$Query$SourcePreferenceById$source;

  TRes call({
    List<Fragment$SourcePreference>? preferences,
    String? $__typename,
  });
  TRes preferences(
      Iterable<Fragment$SourcePreference> Function(
              Iterable<
                  CopyWith$Fragment$SourcePreference<
                      Fragment$SourcePreference>>)
          _fn);
}

class _CopyWithImpl$Query$SourcePreferenceById$source<TRes>
    implements CopyWith$Query$SourcePreferenceById$source<TRes> {
  _CopyWithImpl$Query$SourcePreferenceById$source(
    this._instance,
    this._then,
  );

  final Query$SourcePreferenceById$source _instance;

  final TRes Function(Query$SourcePreferenceById$source) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? preferences = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$SourcePreferenceById$source(
        preferences: preferences == _undefined || preferences == null
            ? _instance.preferences
            : (preferences as List<Fragment$SourcePreference>),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  TRes preferences(
          Iterable<Fragment$SourcePreference> Function(
                  Iterable<
                      CopyWith$Fragment$SourcePreference<
                          Fragment$SourcePreference>>)
              _fn) =>
      call(
          preferences: _fn(_instance.preferences
              .map((e) => CopyWith$Fragment$SourcePreference(
                    e,
                    (i) => i,
                  ))).toList());
}

class _CopyWithStubImpl$Query$SourcePreferenceById$source<TRes>
    implements CopyWith$Query$SourcePreferenceById$source<TRes> {
  _CopyWithStubImpl$Query$SourcePreferenceById$source(this._res);

  TRes _res;

  call({
    List<Fragment$SourcePreference>? preferences,
    String? $__typename,
  }) =>
      _res;

  preferences(_fn) => _res;
}

class Variables$Mutation$UpdateSourcePreference {
  factory Variables$Mutation$UpdateSourcePreference(
          {required Input$UpdateSourcePreferenceInput input}) =>
      Variables$Mutation$UpdateSourcePreference._({
        r'input': input,
      });

  Variables$Mutation$UpdateSourcePreference._(this._$data);

  factory Variables$Mutation$UpdateSourcePreference.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$input = data['input'];
    result$data['input'] = Input$UpdateSourcePreferenceInput.fromJson(
        (l$input as Map<String, dynamic>));
    return Variables$Mutation$UpdateSourcePreference._(result$data);
  }

  Map<String, dynamic> _$data;

  Input$UpdateSourcePreferenceInput get input =>
      (_$data['input'] as Input$UpdateSourcePreferenceInput);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$input = input;
    result$data['input'] = l$input.toJson();
    return result$data;
  }

  CopyWith$Variables$Mutation$UpdateSourcePreference<
          Variables$Mutation$UpdateSourcePreference>
      get copyWith => CopyWith$Variables$Mutation$UpdateSourcePreference(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$UpdateSourcePreference ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$input = input;
    final lOther$input = other.input;
    if (l$input != lOther$input) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$input = input;
    return Object.hashAll([l$input]);
  }
}

abstract class CopyWith$Variables$Mutation$UpdateSourcePreference<TRes> {
  factory CopyWith$Variables$Mutation$UpdateSourcePreference(
    Variables$Mutation$UpdateSourcePreference instance,
    TRes Function(Variables$Mutation$UpdateSourcePreference) then,
  ) = _CopyWithImpl$Variables$Mutation$UpdateSourcePreference;

  factory CopyWith$Variables$Mutation$UpdateSourcePreference.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$UpdateSourcePreference;

  TRes call({Input$UpdateSourcePreferenceInput? input});
}

class _CopyWithImpl$Variables$Mutation$UpdateSourcePreference<TRes>
    implements CopyWith$Variables$Mutation$UpdateSourcePreference<TRes> {
  _CopyWithImpl$Variables$Mutation$UpdateSourcePreference(
    this._instance,
    this._then,
  );

  final Variables$Mutation$UpdateSourcePreference _instance;

  final TRes Function(Variables$Mutation$UpdateSourcePreference) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? input = _undefined}) =>
      _then(Variables$Mutation$UpdateSourcePreference._({
        ..._instance._$data,
        if (input != _undefined && input != null)
          'input': (input as Input$UpdateSourcePreferenceInput),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$UpdateSourcePreference<TRes>
    implements CopyWith$Variables$Mutation$UpdateSourcePreference<TRes> {
  _CopyWithStubImpl$Variables$Mutation$UpdateSourcePreference(this._res);

  TRes _res;

  call({Input$UpdateSourcePreferenceInput? input}) => _res;
}

class Mutation$UpdateSourcePreference {
  Mutation$UpdateSourcePreference({
    this.updateSourcePreference,
    this.$__typename = 'Mutation',
  });

  factory Mutation$UpdateSourcePreference.fromJson(Map<String, dynamic> json) {
    final l$updateSourcePreference = json['updateSourcePreference'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateSourcePreference(
      updateSourcePreference: l$updateSourcePreference == null
          ? null
          : Mutation$UpdateSourcePreference$updateSourcePreference.fromJson(
              (l$updateSourcePreference as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$UpdateSourcePreference$updateSourcePreference?
      updateSourcePreference;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$updateSourcePreference = updateSourcePreference;
    _resultData['updateSourcePreference'] = l$updateSourcePreference?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$updateSourcePreference = updateSourcePreference;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$updateSourcePreference,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$UpdateSourcePreference ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$updateSourcePreference = updateSourcePreference;
    final lOther$updateSourcePreference = other.updateSourcePreference;
    if (l$updateSourcePreference != lOther$updateSourcePreference) {
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

extension UtilityExtension$Mutation$UpdateSourcePreference
    on Mutation$UpdateSourcePreference {
  CopyWith$Mutation$UpdateSourcePreference<Mutation$UpdateSourcePreference>
      get copyWith => CopyWith$Mutation$UpdateSourcePreference(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdateSourcePreference<TRes> {
  factory CopyWith$Mutation$UpdateSourcePreference(
    Mutation$UpdateSourcePreference instance,
    TRes Function(Mutation$UpdateSourcePreference) then,
  ) = _CopyWithImpl$Mutation$UpdateSourcePreference;

  factory CopyWith$Mutation$UpdateSourcePreference.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateSourcePreference;

  TRes call({
    Mutation$UpdateSourcePreference$updateSourcePreference?
        updateSourcePreference,
    String? $__typename,
  });
  CopyWith$Mutation$UpdateSourcePreference$updateSourcePreference<TRes>
      get updateSourcePreference;
}

class _CopyWithImpl$Mutation$UpdateSourcePreference<TRes>
    implements CopyWith$Mutation$UpdateSourcePreference<TRes> {
  _CopyWithImpl$Mutation$UpdateSourcePreference(
    this._instance,
    this._then,
  );

  final Mutation$UpdateSourcePreference _instance;

  final TRes Function(Mutation$UpdateSourcePreference) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? updateSourcePreference = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateSourcePreference(
        updateSourcePreference: updateSourcePreference == _undefined
            ? _instance.updateSourcePreference
            : (updateSourcePreference
                as Mutation$UpdateSourcePreference$updateSourcePreference?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$UpdateSourcePreference$updateSourcePreference<TRes>
      get updateSourcePreference {
    final local$updateSourcePreference = _instance.updateSourcePreference;
    return local$updateSourcePreference == null
        ? CopyWith$Mutation$UpdateSourcePreference$updateSourcePreference.stub(
            _then(_instance))
        : CopyWith$Mutation$UpdateSourcePreference$updateSourcePreference(
            local$updateSourcePreference,
            (e) => call(updateSourcePreference: e));
  }
}

class _CopyWithStubImpl$Mutation$UpdateSourcePreference<TRes>
    implements CopyWith$Mutation$UpdateSourcePreference<TRes> {
  _CopyWithStubImpl$Mutation$UpdateSourcePreference(this._res);

  TRes _res;

  call({
    Mutation$UpdateSourcePreference$updateSourcePreference?
        updateSourcePreference,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$UpdateSourcePreference$updateSourcePreference<TRes>
      get updateSourcePreference =>
          CopyWith$Mutation$UpdateSourcePreference$updateSourcePreference.stub(
              _res);
}

const documentNodeMutationUpdateSourcePreference = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'UpdateSourcePreference'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'input')),
        type: NamedTypeNode(
          name: NameNode(value: 'UpdateSourcePreferenceInput'),
          isNonNull: true,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      )
    ],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'updateSourcePreference'),
        alias: null,
        arguments: [
          ArgumentNode(
            name: NameNode(value: 'input'),
            value: VariableNode(name: NameNode(value: 'input')),
          )
        ],
        directives: [],
        selectionSet: SelectionSetNode(selections: [
          FieldNode(
            name: NameNode(value: '__typename'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null,
          ),
          FieldNode(
            name: NameNode(value: 'preferences'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: SelectionSetNode(selections: [
              FragmentSpreadNode(
                name: NameNode(value: 'SourcePreference'),
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
  fragmentDefinitionSourcePreference,
]);
Mutation$UpdateSourcePreference _parserFn$Mutation$UpdateSourcePreference(
        Map<String, dynamic> data) =>
    Mutation$UpdateSourcePreference.fromJson(data);
typedef OnMutationCompleted$Mutation$UpdateSourcePreference = FutureOr<void>
    Function(
  Map<String, dynamic>?,
  Mutation$UpdateSourcePreference?,
);

class Options$Mutation$UpdateSourcePreference
    extends graphql.MutationOptions<Mutation$UpdateSourcePreference> {
  Options$Mutation$UpdateSourcePreference({
    String? operationName,
    required Variables$Mutation$UpdateSourcePreference variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateSourcePreference? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateSourcePreference? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateSourcePreference>? update,
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
                        : _parserFn$Mutation$UpdateSourcePreference(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateSourcePreference,
          parserFn: _parserFn$Mutation$UpdateSourcePreference,
        );

  final OnMutationCompleted$Mutation$UpdateSourcePreference?
      onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$UpdateSourcePreference
    extends graphql.WatchQueryOptions<Mutation$UpdateSourcePreference> {
  WatchOptions$Mutation$UpdateSourcePreference({
    String? operationName,
    required Variables$Mutation$UpdateSourcePreference variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateSourcePreference? typedOptimisticResult,
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
          document: documentNodeMutationUpdateSourcePreference,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$UpdateSourcePreference,
        );
}

extension ClientExtension$Mutation$UpdateSourcePreference
    on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$UpdateSourcePreference>>
      mutate$UpdateSourcePreference(
              Options$Mutation$UpdateSourcePreference options) async =>
          await this.mutate(options);

  graphql.ObservableQuery<Mutation$UpdateSourcePreference>
      watchMutation$UpdateSourcePreference(
              WatchOptions$Mutation$UpdateSourcePreference options) =>
          this.watchMutation(options);
}

class Mutation$UpdateSourcePreference$HookResult {
  Mutation$UpdateSourcePreference$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$UpdateSourcePreference runMutation;

  final graphql.QueryResult<Mutation$UpdateSourcePreference> result;
}

Mutation$UpdateSourcePreference$HookResult useMutation$UpdateSourcePreference(
    [WidgetOptions$Mutation$UpdateSourcePreference? options]) {
  final result = graphql_flutter
      .useMutation(options ?? WidgetOptions$Mutation$UpdateSourcePreference());
  return Mutation$UpdateSourcePreference$HookResult(
    (variables, {optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables.toJson(),
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$UpdateSourcePreference>
    useWatchMutation$UpdateSourcePreference(
            WatchOptions$Mutation$UpdateSourcePreference options) =>
        graphql_flutter.useWatchMutation(options);

class WidgetOptions$Mutation$UpdateSourcePreference
    extends graphql.MutationOptions<Mutation$UpdateSourcePreference> {
  WidgetOptions$Mutation$UpdateSourcePreference({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateSourcePreference? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateSourcePreference? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateSourcePreference>? update,
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
                        : _parserFn$Mutation$UpdateSourcePreference(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateSourcePreference,
          parserFn: _parserFn$Mutation$UpdateSourcePreference,
        );

  final OnMutationCompleted$Mutation$UpdateSourcePreference?
      onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$UpdateSourcePreference
    = graphql.MultiSourceResult<Mutation$UpdateSourcePreference> Function(
  Variables$Mutation$UpdateSourcePreference, {
  Object? optimisticResult,
  Mutation$UpdateSourcePreference? typedOptimisticResult,
});
typedef Builder$Mutation$UpdateSourcePreference = widgets.Widget Function(
  RunMutation$Mutation$UpdateSourcePreference,
  graphql.QueryResult<Mutation$UpdateSourcePreference>?,
);

class Mutation$UpdateSourcePreference$Widget
    extends graphql_flutter.Mutation<Mutation$UpdateSourcePreference> {
  Mutation$UpdateSourcePreference$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$UpdateSourcePreference? options,
    required Builder$Mutation$UpdateSourcePreference builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$UpdateSourcePreference(),
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

class Mutation$UpdateSourcePreference$updateSourcePreference {
  Mutation$UpdateSourcePreference$updateSourcePreference({
    this.$__typename = 'UpdateSourcePreferencePayload',
    required this.preferences,
  });

  factory Mutation$UpdateSourcePreference$updateSourcePreference.fromJson(
      Map<String, dynamic> json) {
    final l$$__typename = json['__typename'];
    final l$preferences = json['preferences'];
    return Mutation$UpdateSourcePreference$updateSourcePreference(
      $__typename: (l$$__typename as String),
      preferences: (l$preferences as List<dynamic>)
          .map((e) =>
              Fragment$SourcePreference.fromJson((e as Map<String, dynamic>)))
          .toList(),
    );
  }

  final String $__typename;

  final List<Fragment$SourcePreference> preferences;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    final l$preferences = preferences;
    _resultData['preferences'] = l$preferences.map((e) => e.toJson()).toList();
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    final l$preferences = preferences;
    return Object.hashAll([
      l$$__typename,
      Object.hashAll(l$preferences.map((v) => v)),
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$UpdateSourcePreference$updateSourcePreference ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    final l$preferences = preferences;
    final lOther$preferences = other.preferences;
    if (l$preferences.length != lOther$preferences.length) {
      return false;
    }
    for (int i = 0; i < l$preferences.length; i++) {
      final l$preferences$entry = l$preferences[i];
      final lOther$preferences$entry = lOther$preferences[i];
      if (l$preferences$entry != lOther$preferences$entry) {
        return false;
      }
    }
    return true;
  }
}

extension UtilityExtension$Mutation$UpdateSourcePreference$updateSourcePreference
    on Mutation$UpdateSourcePreference$updateSourcePreference {
  CopyWith$Mutation$UpdateSourcePreference$updateSourcePreference<
          Mutation$UpdateSourcePreference$updateSourcePreference>
      get copyWith =>
          CopyWith$Mutation$UpdateSourcePreference$updateSourcePreference(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdateSourcePreference$updateSourcePreference<
    TRes> {
  factory CopyWith$Mutation$UpdateSourcePreference$updateSourcePreference(
    Mutation$UpdateSourcePreference$updateSourcePreference instance,
    TRes Function(Mutation$UpdateSourcePreference$updateSourcePreference) then,
  ) = _CopyWithImpl$Mutation$UpdateSourcePreference$updateSourcePreference;

  factory CopyWith$Mutation$UpdateSourcePreference$updateSourcePreference.stub(
          TRes res) =
      _CopyWithStubImpl$Mutation$UpdateSourcePreference$updateSourcePreference;

  TRes call({
    String? $__typename,
    List<Fragment$SourcePreference>? preferences,
  });
  TRes preferences(
      Iterable<Fragment$SourcePreference> Function(
              Iterable<
                  CopyWith$Fragment$SourcePreference<
                      Fragment$SourcePreference>>)
          _fn);
}

class _CopyWithImpl$Mutation$UpdateSourcePreference$updateSourcePreference<TRes>
    implements
        CopyWith$Mutation$UpdateSourcePreference$updateSourcePreference<TRes> {
  _CopyWithImpl$Mutation$UpdateSourcePreference$updateSourcePreference(
    this._instance,
    this._then,
  );

  final Mutation$UpdateSourcePreference$updateSourcePreference _instance;

  final TRes Function(Mutation$UpdateSourcePreference$updateSourcePreference)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? $__typename = _undefined,
    Object? preferences = _undefined,
  }) =>
      _then(Mutation$UpdateSourcePreference$updateSourcePreference(
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
        preferences: preferences == _undefined || preferences == null
            ? _instance.preferences
            : (preferences as List<Fragment$SourcePreference>),
      ));

  TRes preferences(
          Iterable<Fragment$SourcePreference> Function(
                  Iterable<
                      CopyWith$Fragment$SourcePreference<
                          Fragment$SourcePreference>>)
              _fn) =>
      call(
          preferences: _fn(_instance.preferences
              .map((e) => CopyWith$Fragment$SourcePreference(
                    e,
                    (i) => i,
                  ))).toList());
}

class _CopyWithStubImpl$Mutation$UpdateSourcePreference$updateSourcePreference<
        TRes>
    implements
        CopyWith$Mutation$UpdateSourcePreference$updateSourcePreference<TRes> {
  _CopyWithStubImpl$Mutation$UpdateSourcePreference$updateSourcePreference(
      this._res);

  TRes _res;

  call({
    String? $__typename,
    List<Fragment$SourcePreference>? preferences,
  }) =>
      _res;

  preferences(_fn) => _res;
}
