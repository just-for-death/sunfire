import '../../../../../graphql/__generated__/fragments.graphql.dart';
import '../../../../../graphql/__generated__/schema.graphql.dart';
import '../../../../browse_center/domain/source/graphql/__generated__/fragment.graphql.dart';
import '../../../../manga_book/domain/chapter/graphql/__generated__/fragment.graphql.dart';
import '../../../../manga_book/domain/manga/graphql/__generated__/fragment.graphql.dart';
import '../../../domain/category/graphql/__generated__/fragment.graphql.dart';
import 'dart:async';
import 'package:flutter/widgets.dart' as widgets;
import 'package:gql/ast.dart';
import 'package:graphql/client.dart' as graphql;
import 'package:graphql_flutter/graphql_flutter.dart' as graphql_flutter;

class Variables$Query$AllCategories {
  factory Variables$Query$AllCategories({
    Input$CategoryConditionInput? condition,
    Input$CategoryFilterInput? filter,
    int? first,
    int? offset,
  }) =>
      Variables$Query$AllCategories._({
        if (condition != null) r'condition': condition,
        if (filter != null) r'filter': filter,
        if (first != null) r'first': first,
        if (offset != null) r'offset': offset,
      });

  Variables$Query$AllCategories._(this._$data);

  factory Variables$Query$AllCategories.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('condition')) {
      final l$condition = data['condition'];
      result$data['condition'] = l$condition == null
          ? null
          : Input$CategoryConditionInput.fromJson(
              (l$condition as Map<String, dynamic>));
    }
    if (data.containsKey('filter')) {
      final l$filter = data['filter'];
      result$data['filter'] = l$filter == null
          ? null
          : Input$CategoryFilterInput.fromJson(
              (l$filter as Map<String, dynamic>));
    }
    if (data.containsKey('first')) {
      final l$first = data['first'];
      result$data['first'] = (l$first as int?);
    }
    if (data.containsKey('offset')) {
      final l$offset = data['offset'];
      result$data['offset'] = (l$offset as int?);
    }
    return Variables$Query$AllCategories._(result$data);
  }

  Map<String, dynamic> _$data;

  Input$CategoryConditionInput? get condition =>
      (_$data['condition'] as Input$CategoryConditionInput?);

  Input$CategoryFilterInput? get filter =>
      (_$data['filter'] as Input$CategoryFilterInput?);

  int? get first => (_$data['first'] as int?);

  int? get offset => (_$data['offset'] as int?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('condition')) {
      final l$condition = condition;
      result$data['condition'] = l$condition?.toJson();
    }
    if (_$data.containsKey('filter')) {
      final l$filter = filter;
      result$data['filter'] = l$filter?.toJson();
    }
    if (_$data.containsKey('first')) {
      final l$first = first;
      result$data['first'] = l$first;
    }
    if (_$data.containsKey('offset')) {
      final l$offset = offset;
      result$data['offset'] = l$offset;
    }
    return result$data;
  }

  CopyWith$Variables$Query$AllCategories<Variables$Query$AllCategories>
      get copyWith => CopyWith$Variables$Query$AllCategories(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Query$AllCategories ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$condition = condition;
    final lOther$condition = other.condition;
    if (_$data.containsKey('condition') !=
        other._$data.containsKey('condition')) {
      return false;
    }
    if (l$condition != lOther$condition) {
      return false;
    }
    final l$filter = filter;
    final lOther$filter = other.filter;
    if (_$data.containsKey('filter') != other._$data.containsKey('filter')) {
      return false;
    }
    if (l$filter != lOther$filter) {
      return false;
    }
    final l$first = first;
    final lOther$first = other.first;
    if (_$data.containsKey('first') != other._$data.containsKey('first')) {
      return false;
    }
    if (l$first != lOther$first) {
      return false;
    }
    final l$offset = offset;
    final lOther$offset = other.offset;
    if (_$data.containsKey('offset') != other._$data.containsKey('offset')) {
      return false;
    }
    if (l$offset != lOther$offset) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$condition = condition;
    final l$filter = filter;
    final l$first = first;
    final l$offset = offset;
    return Object.hashAll([
      _$data.containsKey('condition') ? l$condition : const {},
      _$data.containsKey('filter') ? l$filter : const {},
      _$data.containsKey('first') ? l$first : const {},
      _$data.containsKey('offset') ? l$offset : const {},
    ]);
  }
}

abstract class CopyWith$Variables$Query$AllCategories<TRes> {
  factory CopyWith$Variables$Query$AllCategories(
    Variables$Query$AllCategories instance,
    TRes Function(Variables$Query$AllCategories) then,
  ) = _CopyWithImpl$Variables$Query$AllCategories;

  factory CopyWith$Variables$Query$AllCategories.stub(TRes res) =
      _CopyWithStubImpl$Variables$Query$AllCategories;

  TRes call({
    Input$CategoryConditionInput? condition,
    Input$CategoryFilterInput? filter,
    int? first,
    int? offset,
  });
}

class _CopyWithImpl$Variables$Query$AllCategories<TRes>
    implements CopyWith$Variables$Query$AllCategories<TRes> {
  _CopyWithImpl$Variables$Query$AllCategories(
    this._instance,
    this._then,
  );

  final Variables$Query$AllCategories _instance;

  final TRes Function(Variables$Query$AllCategories) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? condition = _undefined,
    Object? filter = _undefined,
    Object? first = _undefined,
    Object? offset = _undefined,
  }) =>
      _then(Variables$Query$AllCategories._({
        ..._instance._$data,
        if (condition != _undefined)
          'condition': (condition as Input$CategoryConditionInput?),
        if (filter != _undefined)
          'filter': (filter as Input$CategoryFilterInput?),
        if (first != _undefined) 'first': (first as int?),
        if (offset != _undefined) 'offset': (offset as int?),
      }));
}

class _CopyWithStubImpl$Variables$Query$AllCategories<TRes>
    implements CopyWith$Variables$Query$AllCategories<TRes> {
  _CopyWithStubImpl$Variables$Query$AllCategories(this._res);

  TRes _res;

  call({
    Input$CategoryConditionInput? condition,
    Input$CategoryFilterInput? filter,
    int? first,
    int? offset,
  }) =>
      _res;
}

class Query$AllCategories {
  Query$AllCategories({
    required this.categories,
    this.$__typename = 'Query',
  });

  factory Query$AllCategories.fromJson(Map<String, dynamic> json) {
    final l$categories = json['categories'];
    final l$$__typename = json['__typename'];
    return Query$AllCategories(
      categories: Query$AllCategories$categories.fromJson(
          (l$categories as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Query$AllCategories$categories categories;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$categories = categories;
    _resultData['categories'] = l$categories.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$categories = categories;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$categories,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$AllCategories || runtimeType != other.runtimeType) {
      return false;
    }
    final l$categories = categories;
    final lOther$categories = other.categories;
    if (l$categories != lOther$categories) {
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

extension UtilityExtension$Query$AllCategories on Query$AllCategories {
  CopyWith$Query$AllCategories<Query$AllCategories> get copyWith =>
      CopyWith$Query$AllCategories(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Query$AllCategories<TRes> {
  factory CopyWith$Query$AllCategories(
    Query$AllCategories instance,
    TRes Function(Query$AllCategories) then,
  ) = _CopyWithImpl$Query$AllCategories;

  factory CopyWith$Query$AllCategories.stub(TRes res) =
      _CopyWithStubImpl$Query$AllCategories;

  TRes call({
    Query$AllCategories$categories? categories,
    String? $__typename,
  });
  CopyWith$Query$AllCategories$categories<TRes> get categories;
}

class _CopyWithImpl$Query$AllCategories<TRes>
    implements CopyWith$Query$AllCategories<TRes> {
  _CopyWithImpl$Query$AllCategories(
    this._instance,
    this._then,
  );

  final Query$AllCategories _instance;

  final TRes Function(Query$AllCategories) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? categories = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$AllCategories(
        categories: categories == _undefined || categories == null
            ? _instance.categories
            : (categories as Query$AllCategories$categories),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$AllCategories$categories<TRes> get categories {
    final local$categories = _instance.categories;
    return CopyWith$Query$AllCategories$categories(
        local$categories, (e) => call(categories: e));
  }
}

class _CopyWithStubImpl$Query$AllCategories<TRes>
    implements CopyWith$Query$AllCategories<TRes> {
  _CopyWithStubImpl$Query$AllCategories(this._res);

  TRes _res;

  call({
    Query$AllCategories$categories? categories,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$AllCategories$categories<TRes> get categories =>
      CopyWith$Query$AllCategories$categories.stub(_res);
}

const documentNodeQueryAllCategories = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.query,
    name: NameNode(value: 'AllCategories'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'condition')),
        type: NamedTypeNode(
          name: NameNode(value: 'CategoryConditionInput'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'filter')),
        type: NamedTypeNode(
          name: NameNode(value: 'CategoryFilterInput'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'first')),
        type: NamedTypeNode(
          name: NameNode(value: 'Int'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'offset')),
        type: NamedTypeNode(
          name: NameNode(value: 'Int'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
    ],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'categories'),
        alias: null,
        arguments: [
          ArgumentNode(
            name: NameNode(value: 'condition'),
            value: VariableNode(name: NameNode(value: 'condition')),
          ),
          ArgumentNode(
            name: NameNode(value: 'filter'),
            value: VariableNode(name: NameNode(value: 'filter')),
          ),
          ArgumentNode(
            name: NameNode(value: 'first'),
            value: VariableNode(name: NameNode(value: 'first')),
          ),
          ArgumentNode(
            name: NameNode(value: 'orderBy'),
            value: EnumValueNode(name: NameNode(value: 'ORDER')),
          ),
          ArgumentNode(
            name: NameNode(value: 'orderByType'),
            value: EnumValueNode(name: NameNode(value: 'ASC')),
          ),
          ArgumentNode(
            name: NameNode(value: 'offset'),
            value: VariableNode(name: NameNode(value: 'offset')),
          ),
        ],
        directives: [],
        selectionSet: SelectionSetNode(selections: [
          FieldNode(
            name: NameNode(value: 'nodes'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: SelectionSetNode(selections: [
              FragmentSpreadNode(
                name: NameNode(value: 'CategoryDto'),
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
            name: NameNode(value: 'pageInfo'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: SelectionSetNode(selections: [
              FragmentSpreadNode(
                name: NameNode(value: 'PageInfoDto'),
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
            name: NameNode(value: 'totalCount'),
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
  fragmentDefinitionCategoryDto,
  fragmentDefinitionPageInfoDto,
]);
Query$AllCategories _parserFn$Query$AllCategories(Map<String, dynamic> data) =>
    Query$AllCategories.fromJson(data);
typedef OnQueryComplete$Query$AllCategories = FutureOr<void> Function(
  Map<String, dynamic>?,
  Query$AllCategories?,
);

class Options$Query$AllCategories
    extends graphql.QueryOptions<Query$AllCategories> {
  Options$Query$AllCategories({
    String? operationName,
    Variables$Query$AllCategories? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$AllCategories? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$AllCategories? onComplete,
    graphql.OnQueryError? onError,
  })  : onCompleteWithParsed = onComplete,
        super(
          variables: variables?.toJson() ?? {},
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
                    data == null ? null : _parserFn$Query$AllCategories(data),
                  ),
          onError: onError,
          document: documentNodeQueryAllCategories,
          parserFn: _parserFn$Query$AllCategories,
        );

  final OnQueryComplete$Query$AllCategories? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onComplete == null
            ? super.properties
            : super.properties.where((property) => property != onComplete),
        onCompleteWithParsed,
      ];
}

class WatchOptions$Query$AllCategories
    extends graphql.WatchQueryOptions<Query$AllCategories> {
  WatchOptions$Query$AllCategories({
    String? operationName,
    Variables$Query$AllCategories? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$AllCategories? typedOptimisticResult,
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
          document: documentNodeQueryAllCategories,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Query$AllCategories,
        );
}

class FetchMoreOptions$Query$AllCategories extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$AllCategories({
    required graphql.UpdateQuery updateQuery,
    Variables$Query$AllCategories? variables,
  }) : super(
          updateQuery: updateQuery,
          variables: variables?.toJson() ?? {},
          document: documentNodeQueryAllCategories,
        );
}

extension ClientExtension$Query$AllCategories on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$AllCategories>> query$AllCategories(
          [Options$Query$AllCategories? options]) async =>
      await this.query(options ?? Options$Query$AllCategories());

  graphql.ObservableQuery<Query$AllCategories> watchQuery$AllCategories(
          [WatchOptions$Query$AllCategories? options]) =>
      this.watchQuery(options ?? WatchOptions$Query$AllCategories());

  void writeQuery$AllCategories({
    required Query$AllCategories data,
    Variables$Query$AllCategories? variables,
    bool broadcast = true,
  }) =>
      this.writeQuery(
        graphql.Request(
          operation:
              graphql.Operation(document: documentNodeQueryAllCategories),
          variables: variables?.toJson() ?? const {},
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );

  Query$AllCategories? readQuery$AllCategories({
    Variables$Query$AllCategories? variables,
    bool optimistic = true,
  }) {
    final result = this.readQuery(
      graphql.Request(
        operation: graphql.Operation(document: documentNodeQueryAllCategories),
        variables: variables?.toJson() ?? const {},
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Query$AllCategories.fromJson(result);
  }
}

graphql_flutter.QueryHookResult<Query$AllCategories> useQuery$AllCategories(
        [Options$Query$AllCategories? options]) =>
    graphql_flutter.useQuery(options ?? Options$Query$AllCategories());
graphql.ObservableQuery<Query$AllCategories> useWatchQuery$AllCategories(
        [WatchOptions$Query$AllCategories? options]) =>
    graphql_flutter
        .useWatchQuery(options ?? WatchOptions$Query$AllCategories());

class Query$AllCategories$Widget
    extends graphql_flutter.Query<Query$AllCategories> {
  Query$AllCategories$Widget({
    widgets.Key? key,
    Options$Query$AllCategories? options,
    required graphql_flutter.QueryBuilder<Query$AllCategories> builder,
  }) : super(
          key: key,
          options: options ?? Options$Query$AllCategories(),
          builder: builder,
        );
}

class Query$AllCategories$categories {
  Query$AllCategories$categories({
    required this.nodes,
    required this.pageInfo,
    required this.totalCount,
    this.$__typename = 'CategoryNodeList',
  });

  factory Query$AllCategories$categories.fromJson(Map<String, dynamic> json) {
    final l$nodes = json['nodes'];
    final l$pageInfo = json['pageInfo'];
    final l$totalCount = json['totalCount'];
    final l$$__typename = json['__typename'];
    return Query$AllCategories$categories(
      nodes: (l$nodes as List<dynamic>)
          .map(
              (e) => Fragment$CategoryDto.fromJson((e as Map<String, dynamic>)))
          .toList(),
      pageInfo:
          Fragment$PageInfoDto.fromJson((l$pageInfo as Map<String, dynamic>)),
      totalCount: (l$totalCount as int),
      $__typename: (l$$__typename as String),
    );
  }

  final List<Fragment$CategoryDto> nodes;

  final Fragment$PageInfoDto pageInfo;

  final int totalCount;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$nodes = nodes;
    _resultData['nodes'] = l$nodes.map((e) => e.toJson()).toList();
    final l$pageInfo = pageInfo;
    _resultData['pageInfo'] = l$pageInfo.toJson();
    final l$totalCount = totalCount;
    _resultData['totalCount'] = l$totalCount;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$nodes = nodes;
    final l$pageInfo = pageInfo;
    final l$totalCount = totalCount;
    final l$$__typename = $__typename;
    return Object.hashAll([
      Object.hashAll(l$nodes.map((v) => v)),
      l$pageInfo,
      l$totalCount,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$AllCategories$categories ||
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
    final l$pageInfo = pageInfo;
    final lOther$pageInfo = other.pageInfo;
    if (l$pageInfo != lOther$pageInfo) {
      return false;
    }
    final l$totalCount = totalCount;
    final lOther$totalCount = other.totalCount;
    if (l$totalCount != lOther$totalCount) {
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

extension UtilityExtension$Query$AllCategories$categories
    on Query$AllCategories$categories {
  CopyWith$Query$AllCategories$categories<Query$AllCategories$categories>
      get copyWith => CopyWith$Query$AllCategories$categories(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$AllCategories$categories<TRes> {
  factory CopyWith$Query$AllCategories$categories(
    Query$AllCategories$categories instance,
    TRes Function(Query$AllCategories$categories) then,
  ) = _CopyWithImpl$Query$AllCategories$categories;

  factory CopyWith$Query$AllCategories$categories.stub(TRes res) =
      _CopyWithStubImpl$Query$AllCategories$categories;

  TRes call({
    List<Fragment$CategoryDto>? nodes,
    Fragment$PageInfoDto? pageInfo,
    int? totalCount,
    String? $__typename,
  });
  TRes nodes(
      Iterable<Fragment$CategoryDto> Function(
              Iterable<CopyWith$Fragment$CategoryDto<Fragment$CategoryDto>>)
          _fn);
  CopyWith$Fragment$PageInfoDto<TRes> get pageInfo;
}

class _CopyWithImpl$Query$AllCategories$categories<TRes>
    implements CopyWith$Query$AllCategories$categories<TRes> {
  _CopyWithImpl$Query$AllCategories$categories(
    this._instance,
    this._then,
  );

  final Query$AllCategories$categories _instance;

  final TRes Function(Query$AllCategories$categories) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? nodes = _undefined,
    Object? pageInfo = _undefined,
    Object? totalCount = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$AllCategories$categories(
        nodes: nodes == _undefined || nodes == null
            ? _instance.nodes
            : (nodes as List<Fragment$CategoryDto>),
        pageInfo: pageInfo == _undefined || pageInfo == null
            ? _instance.pageInfo
            : (pageInfo as Fragment$PageInfoDto),
        totalCount: totalCount == _undefined || totalCount == null
            ? _instance.totalCount
            : (totalCount as int),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  TRes nodes(
          Iterable<Fragment$CategoryDto> Function(
                  Iterable<CopyWith$Fragment$CategoryDto<Fragment$CategoryDto>>)
              _fn) =>
      call(
          nodes: _fn(_instance.nodes.map((e) => CopyWith$Fragment$CategoryDto(
                e,
                (i) => i,
              ))).toList());

  CopyWith$Fragment$PageInfoDto<TRes> get pageInfo {
    final local$pageInfo = _instance.pageInfo;
    return CopyWith$Fragment$PageInfoDto(
        local$pageInfo, (e) => call(pageInfo: e));
  }
}

class _CopyWithStubImpl$Query$AllCategories$categories<TRes>
    implements CopyWith$Query$AllCategories$categories<TRes> {
  _CopyWithStubImpl$Query$AllCategories$categories(this._res);

  TRes _res;

  call({
    List<Fragment$CategoryDto>? nodes,
    Fragment$PageInfoDto? pageInfo,
    int? totalCount,
    String? $__typename,
  }) =>
      _res;

  nodes(_fn) => _res;

  CopyWith$Fragment$PageInfoDto<TRes> get pageInfo =>
      CopyWith$Fragment$PageInfoDto.stub(_res);
}

class Variables$Mutation$CreateCategory {
  factory Variables$Mutation$CreateCategory(
          {required Input$CreateCategoryInput input}) =>
      Variables$Mutation$CreateCategory._({
        r'input': input,
      });

  Variables$Mutation$CreateCategory._(this._$data);

  factory Variables$Mutation$CreateCategory.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$input = data['input'];
    result$data['input'] =
        Input$CreateCategoryInput.fromJson((l$input as Map<String, dynamic>));
    return Variables$Mutation$CreateCategory._(result$data);
  }

  Map<String, dynamic> _$data;

  Input$CreateCategoryInput get input =>
      (_$data['input'] as Input$CreateCategoryInput);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$input = input;
    result$data['input'] = l$input.toJson();
    return result$data;
  }

  CopyWith$Variables$Mutation$CreateCategory<Variables$Mutation$CreateCategory>
      get copyWith => CopyWith$Variables$Mutation$CreateCategory(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$CreateCategory ||
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

abstract class CopyWith$Variables$Mutation$CreateCategory<TRes> {
  factory CopyWith$Variables$Mutation$CreateCategory(
    Variables$Mutation$CreateCategory instance,
    TRes Function(Variables$Mutation$CreateCategory) then,
  ) = _CopyWithImpl$Variables$Mutation$CreateCategory;

  factory CopyWith$Variables$Mutation$CreateCategory.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$CreateCategory;

  TRes call({Input$CreateCategoryInput? input});
}

class _CopyWithImpl$Variables$Mutation$CreateCategory<TRes>
    implements CopyWith$Variables$Mutation$CreateCategory<TRes> {
  _CopyWithImpl$Variables$Mutation$CreateCategory(
    this._instance,
    this._then,
  );

  final Variables$Mutation$CreateCategory _instance;

  final TRes Function(Variables$Mutation$CreateCategory) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? input = _undefined}) =>
      _then(Variables$Mutation$CreateCategory._({
        ..._instance._$data,
        if (input != _undefined && input != null)
          'input': (input as Input$CreateCategoryInput),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$CreateCategory<TRes>
    implements CopyWith$Variables$Mutation$CreateCategory<TRes> {
  _CopyWithStubImpl$Variables$Mutation$CreateCategory(this._res);

  TRes _res;

  call({Input$CreateCategoryInput? input}) => _res;
}

class Mutation$CreateCategory {
  Mutation$CreateCategory({
    this.createCategory,
    this.$__typename = 'Mutation',
  });

  factory Mutation$CreateCategory.fromJson(Map<String, dynamic> json) {
    final l$createCategory = json['createCategory'];
    final l$$__typename = json['__typename'];
    return Mutation$CreateCategory(
      createCategory: l$createCategory == null
          ? null
          : Mutation$CreateCategory$createCategory.fromJson(
              (l$createCategory as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$CreateCategory$createCategory? createCategory;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$createCategory = createCategory;
    _resultData['createCategory'] = l$createCategory?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$createCategory = createCategory;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$createCategory,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$CreateCategory || runtimeType != other.runtimeType) {
      return false;
    }
    final l$createCategory = createCategory;
    final lOther$createCategory = other.createCategory;
    if (l$createCategory != lOther$createCategory) {
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

extension UtilityExtension$Mutation$CreateCategory on Mutation$CreateCategory {
  CopyWith$Mutation$CreateCategory<Mutation$CreateCategory> get copyWith =>
      CopyWith$Mutation$CreateCategory(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Mutation$CreateCategory<TRes> {
  factory CopyWith$Mutation$CreateCategory(
    Mutation$CreateCategory instance,
    TRes Function(Mutation$CreateCategory) then,
  ) = _CopyWithImpl$Mutation$CreateCategory;

  factory CopyWith$Mutation$CreateCategory.stub(TRes res) =
      _CopyWithStubImpl$Mutation$CreateCategory;

  TRes call({
    Mutation$CreateCategory$createCategory? createCategory,
    String? $__typename,
  });
  CopyWith$Mutation$CreateCategory$createCategory<TRes> get createCategory;
}

class _CopyWithImpl$Mutation$CreateCategory<TRes>
    implements CopyWith$Mutation$CreateCategory<TRes> {
  _CopyWithImpl$Mutation$CreateCategory(
    this._instance,
    this._then,
  );

  final Mutation$CreateCategory _instance;

  final TRes Function(Mutation$CreateCategory) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? createCategory = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$CreateCategory(
        createCategory: createCategory == _undefined
            ? _instance.createCategory
            : (createCategory as Mutation$CreateCategory$createCategory?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$CreateCategory$createCategory<TRes> get createCategory {
    final local$createCategory = _instance.createCategory;
    return local$createCategory == null
        ? CopyWith$Mutation$CreateCategory$createCategory.stub(_then(_instance))
        : CopyWith$Mutation$CreateCategory$createCategory(
            local$createCategory, (e) => call(createCategory: e));
  }
}

class _CopyWithStubImpl$Mutation$CreateCategory<TRes>
    implements CopyWith$Mutation$CreateCategory<TRes> {
  _CopyWithStubImpl$Mutation$CreateCategory(this._res);

  TRes _res;

  call({
    Mutation$CreateCategory$createCategory? createCategory,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$CreateCategory$createCategory<TRes> get createCategory =>
      CopyWith$Mutation$CreateCategory$createCategory.stub(_res);
}

const documentNodeMutationCreateCategory = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'CreateCategory'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'input')),
        type: NamedTypeNode(
          name: NameNode(value: 'CreateCategoryInput'),
          isNonNull: true,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      )
    ],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'createCategory'),
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
          )
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
Mutation$CreateCategory _parserFn$Mutation$CreateCategory(
        Map<String, dynamic> data) =>
    Mutation$CreateCategory.fromJson(data);
typedef OnMutationCompleted$Mutation$CreateCategory = FutureOr<void> Function(
  Map<String, dynamic>?,
  Mutation$CreateCategory?,
);

class Options$Mutation$CreateCategory
    extends graphql.MutationOptions<Mutation$CreateCategory> {
  Options$Mutation$CreateCategory({
    String? operationName,
    required Variables$Mutation$CreateCategory variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$CreateCategory? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$CreateCategory? onCompleted,
    graphql.OnMutationUpdate<Mutation$CreateCategory>? update,
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
                        : _parserFn$Mutation$CreateCategory(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationCreateCategory,
          parserFn: _parserFn$Mutation$CreateCategory,
        );

  final OnMutationCompleted$Mutation$CreateCategory? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$CreateCategory
    extends graphql.WatchQueryOptions<Mutation$CreateCategory> {
  WatchOptions$Mutation$CreateCategory({
    String? operationName,
    required Variables$Mutation$CreateCategory variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$CreateCategory? typedOptimisticResult,
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
          document: documentNodeMutationCreateCategory,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$CreateCategory,
        );
}

extension ClientExtension$Mutation$CreateCategory on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$CreateCategory>> mutate$CreateCategory(
          Options$Mutation$CreateCategory options) async =>
      await this.mutate(options);

  graphql.ObservableQuery<Mutation$CreateCategory> watchMutation$CreateCategory(
          WatchOptions$Mutation$CreateCategory options) =>
      this.watchMutation(options);
}

class Mutation$CreateCategory$HookResult {
  Mutation$CreateCategory$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$CreateCategory runMutation;

  final graphql.QueryResult<Mutation$CreateCategory> result;
}

Mutation$CreateCategory$HookResult useMutation$CreateCategory(
    [WidgetOptions$Mutation$CreateCategory? options]) {
  final result = graphql_flutter
      .useMutation(options ?? WidgetOptions$Mutation$CreateCategory());
  return Mutation$CreateCategory$HookResult(
    (variables, {optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables.toJson(),
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$CreateCategory>
    useWatchMutation$CreateCategory(
            WatchOptions$Mutation$CreateCategory options) =>
        graphql_flutter.useWatchMutation(options);

class WidgetOptions$Mutation$CreateCategory
    extends graphql.MutationOptions<Mutation$CreateCategory> {
  WidgetOptions$Mutation$CreateCategory({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$CreateCategory? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$CreateCategory? onCompleted,
    graphql.OnMutationUpdate<Mutation$CreateCategory>? update,
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
                        : _parserFn$Mutation$CreateCategory(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationCreateCategory,
          parserFn: _parserFn$Mutation$CreateCategory,
        );

  final OnMutationCompleted$Mutation$CreateCategory? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$CreateCategory
    = graphql.MultiSourceResult<Mutation$CreateCategory> Function(
  Variables$Mutation$CreateCategory, {
  Object? optimisticResult,
  Mutation$CreateCategory? typedOptimisticResult,
});
typedef Builder$Mutation$CreateCategory = widgets.Widget Function(
  RunMutation$Mutation$CreateCategory,
  graphql.QueryResult<Mutation$CreateCategory>?,
);

class Mutation$CreateCategory$Widget
    extends graphql_flutter.Mutation<Mutation$CreateCategory> {
  Mutation$CreateCategory$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$CreateCategory? options,
    required Builder$Mutation$CreateCategory builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$CreateCategory(),
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

class Mutation$CreateCategory$createCategory {
  Mutation$CreateCategory$createCategory(
      {this.$__typename = 'CreateCategoryPayload'});

  factory Mutation$CreateCategory$createCategory.fromJson(
      Map<String, dynamic> json) {
    final l$$__typename = json['__typename'];
    return Mutation$CreateCategory$createCategory(
        $__typename: (l$$__typename as String));
  }

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    return Object.hashAll([l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$CreateCategory$createCategory ||
        runtimeType != other.runtimeType) {
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

extension UtilityExtension$Mutation$CreateCategory$createCategory
    on Mutation$CreateCategory$createCategory {
  CopyWith$Mutation$CreateCategory$createCategory<
          Mutation$CreateCategory$createCategory>
      get copyWith => CopyWith$Mutation$CreateCategory$createCategory(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$CreateCategory$createCategory<TRes> {
  factory CopyWith$Mutation$CreateCategory$createCategory(
    Mutation$CreateCategory$createCategory instance,
    TRes Function(Mutation$CreateCategory$createCategory) then,
  ) = _CopyWithImpl$Mutation$CreateCategory$createCategory;

  factory CopyWith$Mutation$CreateCategory$createCategory.stub(TRes res) =
      _CopyWithStubImpl$Mutation$CreateCategory$createCategory;

  TRes call({String? $__typename});
}

class _CopyWithImpl$Mutation$CreateCategory$createCategory<TRes>
    implements CopyWith$Mutation$CreateCategory$createCategory<TRes> {
  _CopyWithImpl$Mutation$CreateCategory$createCategory(
    this._instance,
    this._then,
  );

  final Mutation$CreateCategory$createCategory _instance;

  final TRes Function(Mutation$CreateCategory$createCategory) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? $__typename = _undefined}) =>
      _then(Mutation$CreateCategory$createCategory(
          $__typename: $__typename == _undefined || $__typename == null
              ? _instance.$__typename
              : ($__typename as String)));
}

class _CopyWithStubImpl$Mutation$CreateCategory$createCategory<TRes>
    implements CopyWith$Mutation$CreateCategory$createCategory<TRes> {
  _CopyWithStubImpl$Mutation$CreateCategory$createCategory(this._res);

  TRes _res;

  call({String? $__typename}) => _res;
}

class Variables$Mutation$UpdateCategory {
  factory Variables$Mutation$UpdateCategory(
          {required Input$UpdateCategoryInput input}) =>
      Variables$Mutation$UpdateCategory._({
        r'input': input,
      });

  Variables$Mutation$UpdateCategory._(this._$data);

  factory Variables$Mutation$UpdateCategory.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$input = data['input'];
    result$data['input'] =
        Input$UpdateCategoryInput.fromJson((l$input as Map<String, dynamic>));
    return Variables$Mutation$UpdateCategory._(result$data);
  }

  Map<String, dynamic> _$data;

  Input$UpdateCategoryInput get input =>
      (_$data['input'] as Input$UpdateCategoryInput);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$input = input;
    result$data['input'] = l$input.toJson();
    return result$data;
  }

  CopyWith$Variables$Mutation$UpdateCategory<Variables$Mutation$UpdateCategory>
      get copyWith => CopyWith$Variables$Mutation$UpdateCategory(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$UpdateCategory ||
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

abstract class CopyWith$Variables$Mutation$UpdateCategory<TRes> {
  factory CopyWith$Variables$Mutation$UpdateCategory(
    Variables$Mutation$UpdateCategory instance,
    TRes Function(Variables$Mutation$UpdateCategory) then,
  ) = _CopyWithImpl$Variables$Mutation$UpdateCategory;

  factory CopyWith$Variables$Mutation$UpdateCategory.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$UpdateCategory;

  TRes call({Input$UpdateCategoryInput? input});
}

class _CopyWithImpl$Variables$Mutation$UpdateCategory<TRes>
    implements CopyWith$Variables$Mutation$UpdateCategory<TRes> {
  _CopyWithImpl$Variables$Mutation$UpdateCategory(
    this._instance,
    this._then,
  );

  final Variables$Mutation$UpdateCategory _instance;

  final TRes Function(Variables$Mutation$UpdateCategory) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? input = _undefined}) =>
      _then(Variables$Mutation$UpdateCategory._({
        ..._instance._$data,
        if (input != _undefined && input != null)
          'input': (input as Input$UpdateCategoryInput),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$UpdateCategory<TRes>
    implements CopyWith$Variables$Mutation$UpdateCategory<TRes> {
  _CopyWithStubImpl$Variables$Mutation$UpdateCategory(this._res);

  TRes _res;

  call({Input$UpdateCategoryInput? input}) => _res;
}

class Mutation$UpdateCategory {
  Mutation$UpdateCategory({
    this.updateCategory,
    this.$__typename = 'Mutation',
  });

  factory Mutation$UpdateCategory.fromJson(Map<String, dynamic> json) {
    final l$updateCategory = json['updateCategory'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateCategory(
      updateCategory: l$updateCategory == null
          ? null
          : Mutation$UpdateCategory$updateCategory.fromJson(
              (l$updateCategory as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$UpdateCategory$updateCategory? updateCategory;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$updateCategory = updateCategory;
    _resultData['updateCategory'] = l$updateCategory?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$updateCategory = updateCategory;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$updateCategory,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$UpdateCategory || runtimeType != other.runtimeType) {
      return false;
    }
    final l$updateCategory = updateCategory;
    final lOther$updateCategory = other.updateCategory;
    if (l$updateCategory != lOther$updateCategory) {
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

extension UtilityExtension$Mutation$UpdateCategory on Mutation$UpdateCategory {
  CopyWith$Mutation$UpdateCategory<Mutation$UpdateCategory> get copyWith =>
      CopyWith$Mutation$UpdateCategory(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Mutation$UpdateCategory<TRes> {
  factory CopyWith$Mutation$UpdateCategory(
    Mutation$UpdateCategory instance,
    TRes Function(Mutation$UpdateCategory) then,
  ) = _CopyWithImpl$Mutation$UpdateCategory;

  factory CopyWith$Mutation$UpdateCategory.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateCategory;

  TRes call({
    Mutation$UpdateCategory$updateCategory? updateCategory,
    String? $__typename,
  });
  CopyWith$Mutation$UpdateCategory$updateCategory<TRes> get updateCategory;
}

class _CopyWithImpl$Mutation$UpdateCategory<TRes>
    implements CopyWith$Mutation$UpdateCategory<TRes> {
  _CopyWithImpl$Mutation$UpdateCategory(
    this._instance,
    this._then,
  );

  final Mutation$UpdateCategory _instance;

  final TRes Function(Mutation$UpdateCategory) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? updateCategory = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateCategory(
        updateCategory: updateCategory == _undefined
            ? _instance.updateCategory
            : (updateCategory as Mutation$UpdateCategory$updateCategory?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$UpdateCategory$updateCategory<TRes> get updateCategory {
    final local$updateCategory = _instance.updateCategory;
    return local$updateCategory == null
        ? CopyWith$Mutation$UpdateCategory$updateCategory.stub(_then(_instance))
        : CopyWith$Mutation$UpdateCategory$updateCategory(
            local$updateCategory, (e) => call(updateCategory: e));
  }
}

class _CopyWithStubImpl$Mutation$UpdateCategory<TRes>
    implements CopyWith$Mutation$UpdateCategory<TRes> {
  _CopyWithStubImpl$Mutation$UpdateCategory(this._res);

  TRes _res;

  call({
    Mutation$UpdateCategory$updateCategory? updateCategory,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$UpdateCategory$updateCategory<TRes> get updateCategory =>
      CopyWith$Mutation$UpdateCategory$updateCategory.stub(_res);
}

const documentNodeMutationUpdateCategory = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'UpdateCategory'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'input')),
        type: NamedTypeNode(
          name: NameNode(value: 'UpdateCategoryInput'),
          isNonNull: true,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      )
    ],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'updateCategory'),
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
          )
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
Mutation$UpdateCategory _parserFn$Mutation$UpdateCategory(
        Map<String, dynamic> data) =>
    Mutation$UpdateCategory.fromJson(data);
typedef OnMutationCompleted$Mutation$UpdateCategory = FutureOr<void> Function(
  Map<String, dynamic>?,
  Mutation$UpdateCategory?,
);

class Options$Mutation$UpdateCategory
    extends graphql.MutationOptions<Mutation$UpdateCategory> {
  Options$Mutation$UpdateCategory({
    String? operationName,
    required Variables$Mutation$UpdateCategory variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateCategory? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateCategory? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateCategory>? update,
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
                        : _parserFn$Mutation$UpdateCategory(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateCategory,
          parserFn: _parserFn$Mutation$UpdateCategory,
        );

  final OnMutationCompleted$Mutation$UpdateCategory? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$UpdateCategory
    extends graphql.WatchQueryOptions<Mutation$UpdateCategory> {
  WatchOptions$Mutation$UpdateCategory({
    String? operationName,
    required Variables$Mutation$UpdateCategory variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateCategory? typedOptimisticResult,
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
          document: documentNodeMutationUpdateCategory,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$UpdateCategory,
        );
}

extension ClientExtension$Mutation$UpdateCategory on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$UpdateCategory>> mutate$UpdateCategory(
          Options$Mutation$UpdateCategory options) async =>
      await this.mutate(options);

  graphql.ObservableQuery<Mutation$UpdateCategory> watchMutation$UpdateCategory(
          WatchOptions$Mutation$UpdateCategory options) =>
      this.watchMutation(options);
}

class Mutation$UpdateCategory$HookResult {
  Mutation$UpdateCategory$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$UpdateCategory runMutation;

  final graphql.QueryResult<Mutation$UpdateCategory> result;
}

Mutation$UpdateCategory$HookResult useMutation$UpdateCategory(
    [WidgetOptions$Mutation$UpdateCategory? options]) {
  final result = graphql_flutter
      .useMutation(options ?? WidgetOptions$Mutation$UpdateCategory());
  return Mutation$UpdateCategory$HookResult(
    (variables, {optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables.toJson(),
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$UpdateCategory>
    useWatchMutation$UpdateCategory(
            WatchOptions$Mutation$UpdateCategory options) =>
        graphql_flutter.useWatchMutation(options);

class WidgetOptions$Mutation$UpdateCategory
    extends graphql.MutationOptions<Mutation$UpdateCategory> {
  WidgetOptions$Mutation$UpdateCategory({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateCategory? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateCategory? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateCategory>? update,
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
                        : _parserFn$Mutation$UpdateCategory(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateCategory,
          parserFn: _parserFn$Mutation$UpdateCategory,
        );

  final OnMutationCompleted$Mutation$UpdateCategory? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$UpdateCategory
    = graphql.MultiSourceResult<Mutation$UpdateCategory> Function(
  Variables$Mutation$UpdateCategory, {
  Object? optimisticResult,
  Mutation$UpdateCategory? typedOptimisticResult,
});
typedef Builder$Mutation$UpdateCategory = widgets.Widget Function(
  RunMutation$Mutation$UpdateCategory,
  graphql.QueryResult<Mutation$UpdateCategory>?,
);

class Mutation$UpdateCategory$Widget
    extends graphql_flutter.Mutation<Mutation$UpdateCategory> {
  Mutation$UpdateCategory$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$UpdateCategory? options,
    required Builder$Mutation$UpdateCategory builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$UpdateCategory(),
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

class Mutation$UpdateCategory$updateCategory {
  Mutation$UpdateCategory$updateCategory(
      {this.$__typename = 'UpdateCategoryPayload'});

  factory Mutation$UpdateCategory$updateCategory.fromJson(
      Map<String, dynamic> json) {
    final l$$__typename = json['__typename'];
    return Mutation$UpdateCategory$updateCategory(
        $__typename: (l$$__typename as String));
  }

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    return Object.hashAll([l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$UpdateCategory$updateCategory ||
        runtimeType != other.runtimeType) {
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

extension UtilityExtension$Mutation$UpdateCategory$updateCategory
    on Mutation$UpdateCategory$updateCategory {
  CopyWith$Mutation$UpdateCategory$updateCategory<
          Mutation$UpdateCategory$updateCategory>
      get copyWith => CopyWith$Mutation$UpdateCategory$updateCategory(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdateCategory$updateCategory<TRes> {
  factory CopyWith$Mutation$UpdateCategory$updateCategory(
    Mutation$UpdateCategory$updateCategory instance,
    TRes Function(Mutation$UpdateCategory$updateCategory) then,
  ) = _CopyWithImpl$Mutation$UpdateCategory$updateCategory;

  factory CopyWith$Mutation$UpdateCategory$updateCategory.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateCategory$updateCategory;

  TRes call({String? $__typename});
}

class _CopyWithImpl$Mutation$UpdateCategory$updateCategory<TRes>
    implements CopyWith$Mutation$UpdateCategory$updateCategory<TRes> {
  _CopyWithImpl$Mutation$UpdateCategory$updateCategory(
    this._instance,
    this._then,
  );

  final Mutation$UpdateCategory$updateCategory _instance;

  final TRes Function(Mutation$UpdateCategory$updateCategory) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? $__typename = _undefined}) =>
      _then(Mutation$UpdateCategory$updateCategory(
          $__typename: $__typename == _undefined || $__typename == null
              ? _instance.$__typename
              : ($__typename as String)));
}

class _CopyWithStubImpl$Mutation$UpdateCategory$updateCategory<TRes>
    implements CopyWith$Mutation$UpdateCategory$updateCategory<TRes> {
  _CopyWithStubImpl$Mutation$UpdateCategory$updateCategory(this._res);

  TRes _res;

  call({String? $__typename}) => _res;
}

class Variables$Mutation$DeleteCategory {
  factory Variables$Mutation$DeleteCategory(
          {required Input$DeleteCategoryInput input}) =>
      Variables$Mutation$DeleteCategory._({
        r'input': input,
      });

  Variables$Mutation$DeleteCategory._(this._$data);

  factory Variables$Mutation$DeleteCategory.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$input = data['input'];
    result$data['input'] =
        Input$DeleteCategoryInput.fromJson((l$input as Map<String, dynamic>));
    return Variables$Mutation$DeleteCategory._(result$data);
  }

  Map<String, dynamic> _$data;

  Input$DeleteCategoryInput get input =>
      (_$data['input'] as Input$DeleteCategoryInput);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$input = input;
    result$data['input'] = l$input.toJson();
    return result$data;
  }

  CopyWith$Variables$Mutation$DeleteCategory<Variables$Mutation$DeleteCategory>
      get copyWith => CopyWith$Variables$Mutation$DeleteCategory(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$DeleteCategory ||
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

abstract class CopyWith$Variables$Mutation$DeleteCategory<TRes> {
  factory CopyWith$Variables$Mutation$DeleteCategory(
    Variables$Mutation$DeleteCategory instance,
    TRes Function(Variables$Mutation$DeleteCategory) then,
  ) = _CopyWithImpl$Variables$Mutation$DeleteCategory;

  factory CopyWith$Variables$Mutation$DeleteCategory.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$DeleteCategory;

  TRes call({Input$DeleteCategoryInput? input});
}

class _CopyWithImpl$Variables$Mutation$DeleteCategory<TRes>
    implements CopyWith$Variables$Mutation$DeleteCategory<TRes> {
  _CopyWithImpl$Variables$Mutation$DeleteCategory(
    this._instance,
    this._then,
  );

  final Variables$Mutation$DeleteCategory _instance;

  final TRes Function(Variables$Mutation$DeleteCategory) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? input = _undefined}) =>
      _then(Variables$Mutation$DeleteCategory._({
        ..._instance._$data,
        if (input != _undefined && input != null)
          'input': (input as Input$DeleteCategoryInput),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$DeleteCategory<TRes>
    implements CopyWith$Variables$Mutation$DeleteCategory<TRes> {
  _CopyWithStubImpl$Variables$Mutation$DeleteCategory(this._res);

  TRes _res;

  call({Input$DeleteCategoryInput? input}) => _res;
}

class Mutation$DeleteCategory {
  Mutation$DeleteCategory({
    this.deleteCategory,
    this.$__typename = 'Mutation',
  });

  factory Mutation$DeleteCategory.fromJson(Map<String, dynamic> json) {
    final l$deleteCategory = json['deleteCategory'];
    final l$$__typename = json['__typename'];
    return Mutation$DeleteCategory(
      deleteCategory: l$deleteCategory == null
          ? null
          : Mutation$DeleteCategory$deleteCategory.fromJson(
              (l$deleteCategory as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$DeleteCategory$deleteCategory? deleteCategory;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$deleteCategory = deleteCategory;
    _resultData['deleteCategory'] = l$deleteCategory?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$deleteCategory = deleteCategory;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$deleteCategory,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$DeleteCategory || runtimeType != other.runtimeType) {
      return false;
    }
    final l$deleteCategory = deleteCategory;
    final lOther$deleteCategory = other.deleteCategory;
    if (l$deleteCategory != lOther$deleteCategory) {
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

extension UtilityExtension$Mutation$DeleteCategory on Mutation$DeleteCategory {
  CopyWith$Mutation$DeleteCategory<Mutation$DeleteCategory> get copyWith =>
      CopyWith$Mutation$DeleteCategory(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Mutation$DeleteCategory<TRes> {
  factory CopyWith$Mutation$DeleteCategory(
    Mutation$DeleteCategory instance,
    TRes Function(Mutation$DeleteCategory) then,
  ) = _CopyWithImpl$Mutation$DeleteCategory;

  factory CopyWith$Mutation$DeleteCategory.stub(TRes res) =
      _CopyWithStubImpl$Mutation$DeleteCategory;

  TRes call({
    Mutation$DeleteCategory$deleteCategory? deleteCategory,
    String? $__typename,
  });
  CopyWith$Mutation$DeleteCategory$deleteCategory<TRes> get deleteCategory;
}

class _CopyWithImpl$Mutation$DeleteCategory<TRes>
    implements CopyWith$Mutation$DeleteCategory<TRes> {
  _CopyWithImpl$Mutation$DeleteCategory(
    this._instance,
    this._then,
  );

  final Mutation$DeleteCategory _instance;

  final TRes Function(Mutation$DeleteCategory) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? deleteCategory = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$DeleteCategory(
        deleteCategory: deleteCategory == _undefined
            ? _instance.deleteCategory
            : (deleteCategory as Mutation$DeleteCategory$deleteCategory?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$DeleteCategory$deleteCategory<TRes> get deleteCategory {
    final local$deleteCategory = _instance.deleteCategory;
    return local$deleteCategory == null
        ? CopyWith$Mutation$DeleteCategory$deleteCategory.stub(_then(_instance))
        : CopyWith$Mutation$DeleteCategory$deleteCategory(
            local$deleteCategory, (e) => call(deleteCategory: e));
  }
}

class _CopyWithStubImpl$Mutation$DeleteCategory<TRes>
    implements CopyWith$Mutation$DeleteCategory<TRes> {
  _CopyWithStubImpl$Mutation$DeleteCategory(this._res);

  TRes _res;

  call({
    Mutation$DeleteCategory$deleteCategory? deleteCategory,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$DeleteCategory$deleteCategory<TRes> get deleteCategory =>
      CopyWith$Mutation$DeleteCategory$deleteCategory.stub(_res);
}

const documentNodeMutationDeleteCategory = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'DeleteCategory'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'input')),
        type: NamedTypeNode(
          name: NameNode(value: 'DeleteCategoryInput'),
          isNonNull: true,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      )
    ],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'deleteCategory'),
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
          )
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
Mutation$DeleteCategory _parserFn$Mutation$DeleteCategory(
        Map<String, dynamic> data) =>
    Mutation$DeleteCategory.fromJson(data);
typedef OnMutationCompleted$Mutation$DeleteCategory = FutureOr<void> Function(
  Map<String, dynamic>?,
  Mutation$DeleteCategory?,
);

class Options$Mutation$DeleteCategory
    extends graphql.MutationOptions<Mutation$DeleteCategory> {
  Options$Mutation$DeleteCategory({
    String? operationName,
    required Variables$Mutation$DeleteCategory variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$DeleteCategory? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$DeleteCategory? onCompleted,
    graphql.OnMutationUpdate<Mutation$DeleteCategory>? update,
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
                        : _parserFn$Mutation$DeleteCategory(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationDeleteCategory,
          parserFn: _parserFn$Mutation$DeleteCategory,
        );

  final OnMutationCompleted$Mutation$DeleteCategory? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$DeleteCategory
    extends graphql.WatchQueryOptions<Mutation$DeleteCategory> {
  WatchOptions$Mutation$DeleteCategory({
    String? operationName,
    required Variables$Mutation$DeleteCategory variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$DeleteCategory? typedOptimisticResult,
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
          document: documentNodeMutationDeleteCategory,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$DeleteCategory,
        );
}

extension ClientExtension$Mutation$DeleteCategory on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$DeleteCategory>> mutate$DeleteCategory(
          Options$Mutation$DeleteCategory options) async =>
      await this.mutate(options);

  graphql.ObservableQuery<Mutation$DeleteCategory> watchMutation$DeleteCategory(
          WatchOptions$Mutation$DeleteCategory options) =>
      this.watchMutation(options);
}

class Mutation$DeleteCategory$HookResult {
  Mutation$DeleteCategory$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$DeleteCategory runMutation;

  final graphql.QueryResult<Mutation$DeleteCategory> result;
}

Mutation$DeleteCategory$HookResult useMutation$DeleteCategory(
    [WidgetOptions$Mutation$DeleteCategory? options]) {
  final result = graphql_flutter
      .useMutation(options ?? WidgetOptions$Mutation$DeleteCategory());
  return Mutation$DeleteCategory$HookResult(
    (variables, {optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables.toJson(),
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$DeleteCategory>
    useWatchMutation$DeleteCategory(
            WatchOptions$Mutation$DeleteCategory options) =>
        graphql_flutter.useWatchMutation(options);

class WidgetOptions$Mutation$DeleteCategory
    extends graphql.MutationOptions<Mutation$DeleteCategory> {
  WidgetOptions$Mutation$DeleteCategory({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$DeleteCategory? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$DeleteCategory? onCompleted,
    graphql.OnMutationUpdate<Mutation$DeleteCategory>? update,
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
                        : _parserFn$Mutation$DeleteCategory(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationDeleteCategory,
          parserFn: _parserFn$Mutation$DeleteCategory,
        );

  final OnMutationCompleted$Mutation$DeleteCategory? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$DeleteCategory
    = graphql.MultiSourceResult<Mutation$DeleteCategory> Function(
  Variables$Mutation$DeleteCategory, {
  Object? optimisticResult,
  Mutation$DeleteCategory? typedOptimisticResult,
});
typedef Builder$Mutation$DeleteCategory = widgets.Widget Function(
  RunMutation$Mutation$DeleteCategory,
  graphql.QueryResult<Mutation$DeleteCategory>?,
);

class Mutation$DeleteCategory$Widget
    extends graphql_flutter.Mutation<Mutation$DeleteCategory> {
  Mutation$DeleteCategory$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$DeleteCategory? options,
    required Builder$Mutation$DeleteCategory builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$DeleteCategory(),
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

class Mutation$DeleteCategory$deleteCategory {
  Mutation$DeleteCategory$deleteCategory(
      {this.$__typename = 'DeleteCategoryPayload'});

  factory Mutation$DeleteCategory$deleteCategory.fromJson(
      Map<String, dynamic> json) {
    final l$$__typename = json['__typename'];
    return Mutation$DeleteCategory$deleteCategory(
        $__typename: (l$$__typename as String));
  }

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    return Object.hashAll([l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$DeleteCategory$deleteCategory ||
        runtimeType != other.runtimeType) {
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

extension UtilityExtension$Mutation$DeleteCategory$deleteCategory
    on Mutation$DeleteCategory$deleteCategory {
  CopyWith$Mutation$DeleteCategory$deleteCategory<
          Mutation$DeleteCategory$deleteCategory>
      get copyWith => CopyWith$Mutation$DeleteCategory$deleteCategory(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$DeleteCategory$deleteCategory<TRes> {
  factory CopyWith$Mutation$DeleteCategory$deleteCategory(
    Mutation$DeleteCategory$deleteCategory instance,
    TRes Function(Mutation$DeleteCategory$deleteCategory) then,
  ) = _CopyWithImpl$Mutation$DeleteCategory$deleteCategory;

  factory CopyWith$Mutation$DeleteCategory$deleteCategory.stub(TRes res) =
      _CopyWithStubImpl$Mutation$DeleteCategory$deleteCategory;

  TRes call({String? $__typename});
}

class _CopyWithImpl$Mutation$DeleteCategory$deleteCategory<TRes>
    implements CopyWith$Mutation$DeleteCategory$deleteCategory<TRes> {
  _CopyWithImpl$Mutation$DeleteCategory$deleteCategory(
    this._instance,
    this._then,
  );

  final Mutation$DeleteCategory$deleteCategory _instance;

  final TRes Function(Mutation$DeleteCategory$deleteCategory) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? $__typename = _undefined}) =>
      _then(Mutation$DeleteCategory$deleteCategory(
          $__typename: $__typename == _undefined || $__typename == null
              ? _instance.$__typename
              : ($__typename as String)));
}

class _CopyWithStubImpl$Mutation$DeleteCategory$deleteCategory<TRes>
    implements CopyWith$Mutation$DeleteCategory$deleteCategory<TRes> {
  _CopyWithStubImpl$Mutation$DeleteCategory$deleteCategory(this._res);

  TRes _res;

  call({String? $__typename}) => _res;
}

class Variables$Mutation$UpdateCategoryOrder {
  factory Variables$Mutation$UpdateCategoryOrder(
          {required Input$UpdateCategoryOrderInput input}) =>
      Variables$Mutation$UpdateCategoryOrder._({
        r'input': input,
      });

  Variables$Mutation$UpdateCategoryOrder._(this._$data);

  factory Variables$Mutation$UpdateCategoryOrder.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$input = data['input'];
    result$data['input'] = Input$UpdateCategoryOrderInput.fromJson(
        (l$input as Map<String, dynamic>));
    return Variables$Mutation$UpdateCategoryOrder._(result$data);
  }

  Map<String, dynamic> _$data;

  Input$UpdateCategoryOrderInput get input =>
      (_$data['input'] as Input$UpdateCategoryOrderInput);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$input = input;
    result$data['input'] = l$input.toJson();
    return result$data;
  }

  CopyWith$Variables$Mutation$UpdateCategoryOrder<
          Variables$Mutation$UpdateCategoryOrder>
      get copyWith => CopyWith$Variables$Mutation$UpdateCategoryOrder(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$UpdateCategoryOrder ||
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

abstract class CopyWith$Variables$Mutation$UpdateCategoryOrder<TRes> {
  factory CopyWith$Variables$Mutation$UpdateCategoryOrder(
    Variables$Mutation$UpdateCategoryOrder instance,
    TRes Function(Variables$Mutation$UpdateCategoryOrder) then,
  ) = _CopyWithImpl$Variables$Mutation$UpdateCategoryOrder;

  factory CopyWith$Variables$Mutation$UpdateCategoryOrder.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$UpdateCategoryOrder;

  TRes call({Input$UpdateCategoryOrderInput? input});
}

class _CopyWithImpl$Variables$Mutation$UpdateCategoryOrder<TRes>
    implements CopyWith$Variables$Mutation$UpdateCategoryOrder<TRes> {
  _CopyWithImpl$Variables$Mutation$UpdateCategoryOrder(
    this._instance,
    this._then,
  );

  final Variables$Mutation$UpdateCategoryOrder _instance;

  final TRes Function(Variables$Mutation$UpdateCategoryOrder) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? input = _undefined}) =>
      _then(Variables$Mutation$UpdateCategoryOrder._({
        ..._instance._$data,
        if (input != _undefined && input != null)
          'input': (input as Input$UpdateCategoryOrderInput),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$UpdateCategoryOrder<TRes>
    implements CopyWith$Variables$Mutation$UpdateCategoryOrder<TRes> {
  _CopyWithStubImpl$Variables$Mutation$UpdateCategoryOrder(this._res);

  TRes _res;

  call({Input$UpdateCategoryOrderInput? input}) => _res;
}

class Mutation$UpdateCategoryOrder {
  Mutation$UpdateCategoryOrder({
    this.updateCategoryOrder,
    this.$__typename = 'Mutation',
  });

  factory Mutation$UpdateCategoryOrder.fromJson(Map<String, dynamic> json) {
    final l$updateCategoryOrder = json['updateCategoryOrder'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateCategoryOrder(
      updateCategoryOrder: l$updateCategoryOrder == null
          ? null
          : Mutation$UpdateCategoryOrder$updateCategoryOrder.fromJson(
              (l$updateCategoryOrder as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$UpdateCategoryOrder$updateCategoryOrder? updateCategoryOrder;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$updateCategoryOrder = updateCategoryOrder;
    _resultData['updateCategoryOrder'] = l$updateCategoryOrder?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$updateCategoryOrder = updateCategoryOrder;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$updateCategoryOrder,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$UpdateCategoryOrder ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$updateCategoryOrder = updateCategoryOrder;
    final lOther$updateCategoryOrder = other.updateCategoryOrder;
    if (l$updateCategoryOrder != lOther$updateCategoryOrder) {
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

extension UtilityExtension$Mutation$UpdateCategoryOrder
    on Mutation$UpdateCategoryOrder {
  CopyWith$Mutation$UpdateCategoryOrder<Mutation$UpdateCategoryOrder>
      get copyWith => CopyWith$Mutation$UpdateCategoryOrder(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdateCategoryOrder<TRes> {
  factory CopyWith$Mutation$UpdateCategoryOrder(
    Mutation$UpdateCategoryOrder instance,
    TRes Function(Mutation$UpdateCategoryOrder) then,
  ) = _CopyWithImpl$Mutation$UpdateCategoryOrder;

  factory CopyWith$Mutation$UpdateCategoryOrder.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateCategoryOrder;

  TRes call({
    Mutation$UpdateCategoryOrder$updateCategoryOrder? updateCategoryOrder,
    String? $__typename,
  });
  CopyWith$Mutation$UpdateCategoryOrder$updateCategoryOrder<TRes>
      get updateCategoryOrder;
}

class _CopyWithImpl$Mutation$UpdateCategoryOrder<TRes>
    implements CopyWith$Mutation$UpdateCategoryOrder<TRes> {
  _CopyWithImpl$Mutation$UpdateCategoryOrder(
    this._instance,
    this._then,
  );

  final Mutation$UpdateCategoryOrder _instance;

  final TRes Function(Mutation$UpdateCategoryOrder) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? updateCategoryOrder = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateCategoryOrder(
        updateCategoryOrder: updateCategoryOrder == _undefined
            ? _instance.updateCategoryOrder
            : (updateCategoryOrder
                as Mutation$UpdateCategoryOrder$updateCategoryOrder?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$UpdateCategoryOrder$updateCategoryOrder<TRes>
      get updateCategoryOrder {
    final local$updateCategoryOrder = _instance.updateCategoryOrder;
    return local$updateCategoryOrder == null
        ? CopyWith$Mutation$UpdateCategoryOrder$updateCategoryOrder.stub(
            _then(_instance))
        : CopyWith$Mutation$UpdateCategoryOrder$updateCategoryOrder(
            local$updateCategoryOrder, (e) => call(updateCategoryOrder: e));
  }
}

class _CopyWithStubImpl$Mutation$UpdateCategoryOrder<TRes>
    implements CopyWith$Mutation$UpdateCategoryOrder<TRes> {
  _CopyWithStubImpl$Mutation$UpdateCategoryOrder(this._res);

  TRes _res;

  call({
    Mutation$UpdateCategoryOrder$updateCategoryOrder? updateCategoryOrder,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$UpdateCategoryOrder$updateCategoryOrder<TRes>
      get updateCategoryOrder =>
          CopyWith$Mutation$UpdateCategoryOrder$updateCategoryOrder.stub(_res);
}

const documentNodeMutationUpdateCategoryOrder = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'UpdateCategoryOrder'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'input')),
        type: NamedTypeNode(
          name: NameNode(value: 'UpdateCategoryOrderInput'),
          isNonNull: true,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      )
    ],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'updateCategoryOrder'),
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
            name: NameNode(value: 'categories'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: SelectionSetNode(selections: [
              FragmentSpreadNode(
                name: NameNode(value: 'CategoryDto'),
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
  fragmentDefinitionCategoryDto,
]);
Mutation$UpdateCategoryOrder _parserFn$Mutation$UpdateCategoryOrder(
        Map<String, dynamic> data) =>
    Mutation$UpdateCategoryOrder.fromJson(data);
typedef OnMutationCompleted$Mutation$UpdateCategoryOrder = FutureOr<void>
    Function(
  Map<String, dynamic>?,
  Mutation$UpdateCategoryOrder?,
);

class Options$Mutation$UpdateCategoryOrder
    extends graphql.MutationOptions<Mutation$UpdateCategoryOrder> {
  Options$Mutation$UpdateCategoryOrder({
    String? operationName,
    required Variables$Mutation$UpdateCategoryOrder variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateCategoryOrder? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateCategoryOrder? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateCategoryOrder>? update,
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
                        : _parserFn$Mutation$UpdateCategoryOrder(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateCategoryOrder,
          parserFn: _parserFn$Mutation$UpdateCategoryOrder,
        );

  final OnMutationCompleted$Mutation$UpdateCategoryOrder? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$UpdateCategoryOrder
    extends graphql.WatchQueryOptions<Mutation$UpdateCategoryOrder> {
  WatchOptions$Mutation$UpdateCategoryOrder({
    String? operationName,
    required Variables$Mutation$UpdateCategoryOrder variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateCategoryOrder? typedOptimisticResult,
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
          document: documentNodeMutationUpdateCategoryOrder,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$UpdateCategoryOrder,
        );
}

extension ClientExtension$Mutation$UpdateCategoryOrder
    on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$UpdateCategoryOrder>>
      mutate$UpdateCategoryOrder(
              Options$Mutation$UpdateCategoryOrder options) async =>
          await this.mutate(options);

  graphql.ObservableQuery<Mutation$UpdateCategoryOrder>
      watchMutation$UpdateCategoryOrder(
              WatchOptions$Mutation$UpdateCategoryOrder options) =>
          this.watchMutation(options);
}

class Mutation$UpdateCategoryOrder$HookResult {
  Mutation$UpdateCategoryOrder$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$UpdateCategoryOrder runMutation;

  final graphql.QueryResult<Mutation$UpdateCategoryOrder> result;
}

Mutation$UpdateCategoryOrder$HookResult useMutation$UpdateCategoryOrder(
    [WidgetOptions$Mutation$UpdateCategoryOrder? options]) {
  final result = graphql_flutter
      .useMutation(options ?? WidgetOptions$Mutation$UpdateCategoryOrder());
  return Mutation$UpdateCategoryOrder$HookResult(
    (variables, {optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables.toJson(),
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$UpdateCategoryOrder>
    useWatchMutation$UpdateCategoryOrder(
            WatchOptions$Mutation$UpdateCategoryOrder options) =>
        graphql_flutter.useWatchMutation(options);

class WidgetOptions$Mutation$UpdateCategoryOrder
    extends graphql.MutationOptions<Mutation$UpdateCategoryOrder> {
  WidgetOptions$Mutation$UpdateCategoryOrder({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateCategoryOrder? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateCategoryOrder? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateCategoryOrder>? update,
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
                        : _parserFn$Mutation$UpdateCategoryOrder(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateCategoryOrder,
          parserFn: _parserFn$Mutation$UpdateCategoryOrder,
        );

  final OnMutationCompleted$Mutation$UpdateCategoryOrder? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$UpdateCategoryOrder
    = graphql.MultiSourceResult<Mutation$UpdateCategoryOrder> Function(
  Variables$Mutation$UpdateCategoryOrder, {
  Object? optimisticResult,
  Mutation$UpdateCategoryOrder? typedOptimisticResult,
});
typedef Builder$Mutation$UpdateCategoryOrder = widgets.Widget Function(
  RunMutation$Mutation$UpdateCategoryOrder,
  graphql.QueryResult<Mutation$UpdateCategoryOrder>?,
);

class Mutation$UpdateCategoryOrder$Widget
    extends graphql_flutter.Mutation<Mutation$UpdateCategoryOrder> {
  Mutation$UpdateCategoryOrder$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$UpdateCategoryOrder? options,
    required Builder$Mutation$UpdateCategoryOrder builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$UpdateCategoryOrder(),
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

class Mutation$UpdateCategoryOrder$updateCategoryOrder {
  Mutation$UpdateCategoryOrder$updateCategoryOrder({
    required this.categories,
    this.$__typename = 'UpdateCategoryOrderPayload',
  });

  factory Mutation$UpdateCategoryOrder$updateCategoryOrder.fromJson(
      Map<String, dynamic> json) {
    final l$categories = json['categories'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateCategoryOrder$updateCategoryOrder(
      categories: (l$categories as List<dynamic>)
          .map(
              (e) => Fragment$CategoryDto.fromJson((e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final List<Fragment$CategoryDto> categories;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$categories = categories;
    _resultData['categories'] = l$categories.map((e) => e.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$categories = categories;
    final l$$__typename = $__typename;
    return Object.hashAll([
      Object.hashAll(l$categories.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$UpdateCategoryOrder$updateCategoryOrder ||
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
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Mutation$UpdateCategoryOrder$updateCategoryOrder
    on Mutation$UpdateCategoryOrder$updateCategoryOrder {
  CopyWith$Mutation$UpdateCategoryOrder$updateCategoryOrder<
          Mutation$UpdateCategoryOrder$updateCategoryOrder>
      get copyWith => CopyWith$Mutation$UpdateCategoryOrder$updateCategoryOrder(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdateCategoryOrder$updateCategoryOrder<TRes> {
  factory CopyWith$Mutation$UpdateCategoryOrder$updateCategoryOrder(
    Mutation$UpdateCategoryOrder$updateCategoryOrder instance,
    TRes Function(Mutation$UpdateCategoryOrder$updateCategoryOrder) then,
  ) = _CopyWithImpl$Mutation$UpdateCategoryOrder$updateCategoryOrder;

  factory CopyWith$Mutation$UpdateCategoryOrder$updateCategoryOrder.stub(
          TRes res) =
      _CopyWithStubImpl$Mutation$UpdateCategoryOrder$updateCategoryOrder;

  TRes call({
    List<Fragment$CategoryDto>? categories,
    String? $__typename,
  });
  TRes categories(
      Iterable<Fragment$CategoryDto> Function(
              Iterable<CopyWith$Fragment$CategoryDto<Fragment$CategoryDto>>)
          _fn);
}

class _CopyWithImpl$Mutation$UpdateCategoryOrder$updateCategoryOrder<TRes>
    implements CopyWith$Mutation$UpdateCategoryOrder$updateCategoryOrder<TRes> {
  _CopyWithImpl$Mutation$UpdateCategoryOrder$updateCategoryOrder(
    this._instance,
    this._then,
  );

  final Mutation$UpdateCategoryOrder$updateCategoryOrder _instance;

  final TRes Function(Mutation$UpdateCategoryOrder$updateCategoryOrder) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? categories = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateCategoryOrder$updateCategoryOrder(
        categories: categories == _undefined || categories == null
            ? _instance.categories
            : (categories as List<Fragment$CategoryDto>),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  TRes categories(
          Iterable<Fragment$CategoryDto> Function(
                  Iterable<CopyWith$Fragment$CategoryDto<Fragment$CategoryDto>>)
              _fn) =>
      call(
          categories:
              _fn(_instance.categories.map((e) => CopyWith$Fragment$CategoryDto(
                    e,
                    (i) => i,
                  ))).toList());
}

class _CopyWithStubImpl$Mutation$UpdateCategoryOrder$updateCategoryOrder<TRes>
    implements CopyWith$Mutation$UpdateCategoryOrder$updateCategoryOrder<TRes> {
  _CopyWithStubImpl$Mutation$UpdateCategoryOrder$updateCategoryOrder(this._res);

  TRes _res;

  call({
    List<Fragment$CategoryDto>? categories,
    String? $__typename,
  }) =>
      _res;

  categories(_fn) => _res;
}

class Variables$Query$GetCategoryMangas {
  factory Variables$Query$GetCategoryMangas({required int id}) =>
      Variables$Query$GetCategoryMangas._({
        r'id': id,
      });

  Variables$Query$GetCategoryMangas._(this._$data);

  factory Variables$Query$GetCategoryMangas.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$id = data['id'];
    result$data['id'] = (l$id as int);
    return Variables$Query$GetCategoryMangas._(result$data);
  }

  Map<String, dynamic> _$data;

  int get id => (_$data['id'] as int);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$id = id;
    result$data['id'] = l$id;
    return result$data;
  }

  CopyWith$Variables$Query$GetCategoryMangas<Variables$Query$GetCategoryMangas>
      get copyWith => CopyWith$Variables$Query$GetCategoryMangas(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Query$GetCategoryMangas ||
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

abstract class CopyWith$Variables$Query$GetCategoryMangas<TRes> {
  factory CopyWith$Variables$Query$GetCategoryMangas(
    Variables$Query$GetCategoryMangas instance,
    TRes Function(Variables$Query$GetCategoryMangas) then,
  ) = _CopyWithImpl$Variables$Query$GetCategoryMangas;

  factory CopyWith$Variables$Query$GetCategoryMangas.stub(TRes res) =
      _CopyWithStubImpl$Variables$Query$GetCategoryMangas;

  TRes call({int? id});
}

class _CopyWithImpl$Variables$Query$GetCategoryMangas<TRes>
    implements CopyWith$Variables$Query$GetCategoryMangas<TRes> {
  _CopyWithImpl$Variables$Query$GetCategoryMangas(
    this._instance,
    this._then,
  );

  final Variables$Query$GetCategoryMangas _instance;

  final TRes Function(Variables$Query$GetCategoryMangas) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? id = _undefined}) =>
      _then(Variables$Query$GetCategoryMangas._({
        ..._instance._$data,
        if (id != _undefined && id != null) 'id': (id as int),
      }));
}

class _CopyWithStubImpl$Variables$Query$GetCategoryMangas<TRes>
    implements CopyWith$Variables$Query$GetCategoryMangas<TRes> {
  _CopyWithStubImpl$Variables$Query$GetCategoryMangas(this._res);

  TRes _res;

  call({int? id}) => _res;
}

class Query$GetCategoryMangas {
  Query$GetCategoryMangas({
    required this.category,
    this.$__typename = 'Query',
  });

  factory Query$GetCategoryMangas.fromJson(Map<String, dynamic> json) {
    final l$category = json['category'];
    final l$$__typename = json['__typename'];
    return Query$GetCategoryMangas(
      category: Query$GetCategoryMangas$category.fromJson(
          (l$category as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Query$GetCategoryMangas$category category;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$category = category;
    _resultData['category'] = l$category.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$category = category;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$category,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetCategoryMangas || runtimeType != other.runtimeType) {
      return false;
    }
    final l$category = category;
    final lOther$category = other.category;
    if (l$category != lOther$category) {
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

extension UtilityExtension$Query$GetCategoryMangas on Query$GetCategoryMangas {
  CopyWith$Query$GetCategoryMangas<Query$GetCategoryMangas> get copyWith =>
      CopyWith$Query$GetCategoryMangas(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Query$GetCategoryMangas<TRes> {
  factory CopyWith$Query$GetCategoryMangas(
    Query$GetCategoryMangas instance,
    TRes Function(Query$GetCategoryMangas) then,
  ) = _CopyWithImpl$Query$GetCategoryMangas;

  factory CopyWith$Query$GetCategoryMangas.stub(TRes res) =
      _CopyWithStubImpl$Query$GetCategoryMangas;

  TRes call({
    Query$GetCategoryMangas$category? category,
    String? $__typename,
  });
  CopyWith$Query$GetCategoryMangas$category<TRes> get category;
}

class _CopyWithImpl$Query$GetCategoryMangas<TRes>
    implements CopyWith$Query$GetCategoryMangas<TRes> {
  _CopyWithImpl$Query$GetCategoryMangas(
    this._instance,
    this._then,
  );

  final Query$GetCategoryMangas _instance;

  final TRes Function(Query$GetCategoryMangas) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? category = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetCategoryMangas(
        category: category == _undefined || category == null
            ? _instance.category
            : (category as Query$GetCategoryMangas$category),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$GetCategoryMangas$category<TRes> get category {
    final local$category = _instance.category;
    return CopyWith$Query$GetCategoryMangas$category(
        local$category, (e) => call(category: e));
  }
}

class _CopyWithStubImpl$Query$GetCategoryMangas<TRes>
    implements CopyWith$Query$GetCategoryMangas<TRes> {
  _CopyWithStubImpl$Query$GetCategoryMangas(this._res);

  TRes _res;

  call({
    Query$GetCategoryMangas$category? category,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$GetCategoryMangas$category<TRes> get category =>
      CopyWith$Query$GetCategoryMangas$category.stub(_res);
}

const documentNodeQueryGetCategoryMangas = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.query,
    name: NameNode(value: 'GetCategoryMangas'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'id')),
        type: NamedTypeNode(
          name: NameNode(value: 'Int'),
          isNonNull: true,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      )
    ],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'category'),
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
            name: NameNode(value: 'id'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null,
          ),
          FieldNode(
            name: NameNode(value: 'mangas'),
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
                    name: NameNode(value: 'MangaDto'),
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
                name: NameNode(value: 'pageInfo'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: SelectionSetNode(selections: [
                  FragmentSpreadNode(
                    name: NameNode(value: 'PageInfoDto'),
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
                name: NameNode(value: 'totalCount'),
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
  fragmentDefinitionMangaDto,
  fragmentDefinitionChapterDto,
  fragmentDefinitionSourceDto,
  fragmentDefinitionPageInfoDto,
]);
Query$GetCategoryMangas _parserFn$Query$GetCategoryMangas(
        Map<String, dynamic> data) =>
    Query$GetCategoryMangas.fromJson(data);
typedef OnQueryComplete$Query$GetCategoryMangas = FutureOr<void> Function(
  Map<String, dynamic>?,
  Query$GetCategoryMangas?,
);

class Options$Query$GetCategoryMangas
    extends graphql.QueryOptions<Query$GetCategoryMangas> {
  Options$Query$GetCategoryMangas({
    String? operationName,
    required Variables$Query$GetCategoryMangas variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetCategoryMangas? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$GetCategoryMangas? onComplete,
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
                        : _parserFn$Query$GetCategoryMangas(data),
                  ),
          onError: onError,
          document: documentNodeQueryGetCategoryMangas,
          parserFn: _parserFn$Query$GetCategoryMangas,
        );

  final OnQueryComplete$Query$GetCategoryMangas? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onComplete == null
            ? super.properties
            : super.properties.where((property) => property != onComplete),
        onCompleteWithParsed,
      ];
}

class WatchOptions$Query$GetCategoryMangas
    extends graphql.WatchQueryOptions<Query$GetCategoryMangas> {
  WatchOptions$Query$GetCategoryMangas({
    String? operationName,
    required Variables$Query$GetCategoryMangas variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetCategoryMangas? typedOptimisticResult,
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
          document: documentNodeQueryGetCategoryMangas,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Query$GetCategoryMangas,
        );
}

class FetchMoreOptions$Query$GetCategoryMangas
    extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$GetCategoryMangas({
    required graphql.UpdateQuery updateQuery,
    required Variables$Query$GetCategoryMangas variables,
  }) : super(
          updateQuery: updateQuery,
          variables: variables.toJson(),
          document: documentNodeQueryGetCategoryMangas,
        );
}

extension ClientExtension$Query$GetCategoryMangas on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$GetCategoryMangas>> query$GetCategoryMangas(
          Options$Query$GetCategoryMangas options) async =>
      await this.query(options);

  graphql.ObservableQuery<Query$GetCategoryMangas> watchQuery$GetCategoryMangas(
          WatchOptions$Query$GetCategoryMangas options) =>
      this.watchQuery(options);

  void writeQuery$GetCategoryMangas({
    required Query$GetCategoryMangas data,
    required Variables$Query$GetCategoryMangas variables,
    bool broadcast = true,
  }) =>
      this.writeQuery(
        graphql.Request(
          operation:
              graphql.Operation(document: documentNodeQueryGetCategoryMangas),
          variables: variables.toJson(),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );

  Query$GetCategoryMangas? readQuery$GetCategoryMangas({
    required Variables$Query$GetCategoryMangas variables,
    bool optimistic = true,
  }) {
    final result = this.readQuery(
      graphql.Request(
        operation:
            graphql.Operation(document: documentNodeQueryGetCategoryMangas),
        variables: variables.toJson(),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Query$GetCategoryMangas.fromJson(result);
  }
}

graphql_flutter.QueryHookResult<Query$GetCategoryMangas>
    useQuery$GetCategoryMangas(Options$Query$GetCategoryMangas options) =>
        graphql_flutter.useQuery(options);
graphql.ObservableQuery<Query$GetCategoryMangas>
    useWatchQuery$GetCategoryMangas(
            WatchOptions$Query$GetCategoryMangas options) =>
        graphql_flutter.useWatchQuery(options);

class Query$GetCategoryMangas$Widget
    extends graphql_flutter.Query<Query$GetCategoryMangas> {
  Query$GetCategoryMangas$Widget({
    widgets.Key? key,
    required Options$Query$GetCategoryMangas options,
    required graphql_flutter.QueryBuilder<Query$GetCategoryMangas> builder,
  }) : super(
          key: key,
          options: options,
          builder: builder,
        );
}

class Query$GetCategoryMangas$category {
  Query$GetCategoryMangas$category({
    required this.id,
    required this.mangas,
    this.$__typename = 'CategoryType',
  });

  factory Query$GetCategoryMangas$category.fromJson(Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$mangas = json['mangas'];
    final l$$__typename = json['__typename'];
    return Query$GetCategoryMangas$category(
      id: (l$id as int),
      mangas: Query$GetCategoryMangas$category$mangas.fromJson(
          (l$mangas as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final int id;

  final Query$GetCategoryMangas$category$mangas mangas;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$mangas = mangas;
    _resultData['mangas'] = l$mangas.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$mangas = mangas;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$mangas,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetCategoryMangas$category ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$mangas = mangas;
    final lOther$mangas = other.mangas;
    if (l$mangas != lOther$mangas) {
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

extension UtilityExtension$Query$GetCategoryMangas$category
    on Query$GetCategoryMangas$category {
  CopyWith$Query$GetCategoryMangas$category<Query$GetCategoryMangas$category>
      get copyWith => CopyWith$Query$GetCategoryMangas$category(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetCategoryMangas$category<TRes> {
  factory CopyWith$Query$GetCategoryMangas$category(
    Query$GetCategoryMangas$category instance,
    TRes Function(Query$GetCategoryMangas$category) then,
  ) = _CopyWithImpl$Query$GetCategoryMangas$category;

  factory CopyWith$Query$GetCategoryMangas$category.stub(TRes res) =
      _CopyWithStubImpl$Query$GetCategoryMangas$category;

  TRes call({
    int? id,
    Query$GetCategoryMangas$category$mangas? mangas,
    String? $__typename,
  });
  CopyWith$Query$GetCategoryMangas$category$mangas<TRes> get mangas;
}

class _CopyWithImpl$Query$GetCategoryMangas$category<TRes>
    implements CopyWith$Query$GetCategoryMangas$category<TRes> {
  _CopyWithImpl$Query$GetCategoryMangas$category(
    this._instance,
    this._then,
  );

  final Query$GetCategoryMangas$category _instance;

  final TRes Function(Query$GetCategoryMangas$category) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? mangas = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetCategoryMangas$category(
        id: id == _undefined || id == null ? _instance.id : (id as int),
        mangas: mangas == _undefined || mangas == null
            ? _instance.mangas
            : (mangas as Query$GetCategoryMangas$category$mangas),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$GetCategoryMangas$category$mangas<TRes> get mangas {
    final local$mangas = _instance.mangas;
    return CopyWith$Query$GetCategoryMangas$category$mangas(
        local$mangas, (e) => call(mangas: e));
  }
}

class _CopyWithStubImpl$Query$GetCategoryMangas$category<TRes>
    implements CopyWith$Query$GetCategoryMangas$category<TRes> {
  _CopyWithStubImpl$Query$GetCategoryMangas$category(this._res);

  TRes _res;

  call({
    int? id,
    Query$GetCategoryMangas$category$mangas? mangas,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$GetCategoryMangas$category$mangas<TRes> get mangas =>
      CopyWith$Query$GetCategoryMangas$category$mangas.stub(_res);
}

class Query$GetCategoryMangas$category$mangas {
  Query$GetCategoryMangas$category$mangas({
    required this.nodes,
    required this.pageInfo,
    required this.totalCount,
    this.$__typename = 'MangaNodeList',
  });

  factory Query$GetCategoryMangas$category$mangas.fromJson(
      Map<String, dynamic> json) {
    final l$nodes = json['nodes'];
    final l$pageInfo = json['pageInfo'];
    final l$totalCount = json['totalCount'];
    final l$$__typename = json['__typename'];
    return Query$GetCategoryMangas$category$mangas(
      nodes: (l$nodes as List<dynamic>)
          .map((e) => Fragment$MangaDto.fromJson((e as Map<String, dynamic>)))
          .toList(),
      pageInfo:
          Fragment$PageInfoDto.fromJson((l$pageInfo as Map<String, dynamic>)),
      totalCount: (l$totalCount as int),
      $__typename: (l$$__typename as String),
    );
  }

  final List<Fragment$MangaDto> nodes;

  final Fragment$PageInfoDto pageInfo;

  final int totalCount;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$nodes = nodes;
    _resultData['nodes'] = l$nodes.map((e) => e.toJson()).toList();
    final l$pageInfo = pageInfo;
    _resultData['pageInfo'] = l$pageInfo.toJson();
    final l$totalCount = totalCount;
    _resultData['totalCount'] = l$totalCount;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$nodes = nodes;
    final l$pageInfo = pageInfo;
    final l$totalCount = totalCount;
    final l$$__typename = $__typename;
    return Object.hashAll([
      Object.hashAll(l$nodes.map((v) => v)),
      l$pageInfo,
      l$totalCount,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetCategoryMangas$category$mangas ||
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
    final l$pageInfo = pageInfo;
    final lOther$pageInfo = other.pageInfo;
    if (l$pageInfo != lOther$pageInfo) {
      return false;
    }
    final l$totalCount = totalCount;
    final lOther$totalCount = other.totalCount;
    if (l$totalCount != lOther$totalCount) {
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

extension UtilityExtension$Query$GetCategoryMangas$category$mangas
    on Query$GetCategoryMangas$category$mangas {
  CopyWith$Query$GetCategoryMangas$category$mangas<
          Query$GetCategoryMangas$category$mangas>
      get copyWith => CopyWith$Query$GetCategoryMangas$category$mangas(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetCategoryMangas$category$mangas<TRes> {
  factory CopyWith$Query$GetCategoryMangas$category$mangas(
    Query$GetCategoryMangas$category$mangas instance,
    TRes Function(Query$GetCategoryMangas$category$mangas) then,
  ) = _CopyWithImpl$Query$GetCategoryMangas$category$mangas;

  factory CopyWith$Query$GetCategoryMangas$category$mangas.stub(TRes res) =
      _CopyWithStubImpl$Query$GetCategoryMangas$category$mangas;

  TRes call({
    List<Fragment$MangaDto>? nodes,
    Fragment$PageInfoDto? pageInfo,
    int? totalCount,
    String? $__typename,
  });
  TRes nodes(
      Iterable<Fragment$MangaDto> Function(
              Iterable<CopyWith$Fragment$MangaDto<Fragment$MangaDto>>)
          _fn);
  CopyWith$Fragment$PageInfoDto<TRes> get pageInfo;
}

class _CopyWithImpl$Query$GetCategoryMangas$category$mangas<TRes>
    implements CopyWith$Query$GetCategoryMangas$category$mangas<TRes> {
  _CopyWithImpl$Query$GetCategoryMangas$category$mangas(
    this._instance,
    this._then,
  );

  final Query$GetCategoryMangas$category$mangas _instance;

  final TRes Function(Query$GetCategoryMangas$category$mangas) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? nodes = _undefined,
    Object? pageInfo = _undefined,
    Object? totalCount = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetCategoryMangas$category$mangas(
        nodes: nodes == _undefined || nodes == null
            ? _instance.nodes
            : (nodes as List<Fragment$MangaDto>),
        pageInfo: pageInfo == _undefined || pageInfo == null
            ? _instance.pageInfo
            : (pageInfo as Fragment$PageInfoDto),
        totalCount: totalCount == _undefined || totalCount == null
            ? _instance.totalCount
            : (totalCount as int),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  TRes nodes(
          Iterable<Fragment$MangaDto> Function(
                  Iterable<CopyWith$Fragment$MangaDto<Fragment$MangaDto>>)
              _fn) =>
      call(
          nodes: _fn(_instance.nodes.map((e) => CopyWith$Fragment$MangaDto(
                e,
                (i) => i,
              ))).toList());

  CopyWith$Fragment$PageInfoDto<TRes> get pageInfo {
    final local$pageInfo = _instance.pageInfo;
    return CopyWith$Fragment$PageInfoDto(
        local$pageInfo, (e) => call(pageInfo: e));
  }
}

class _CopyWithStubImpl$Query$GetCategoryMangas$category$mangas<TRes>
    implements CopyWith$Query$GetCategoryMangas$category$mangas<TRes> {
  _CopyWithStubImpl$Query$GetCategoryMangas$category$mangas(this._res);

  TRes _res;

  call({
    List<Fragment$MangaDto>? nodes,
    Fragment$PageInfoDto? pageInfo,
    int? totalCount,
    String? $__typename,
  }) =>
      _res;

  nodes(_fn) => _res;

  CopyWith$Fragment$PageInfoDto<TRes> get pageInfo =>
      CopyWith$Fragment$PageInfoDto.stub(_res);
}
