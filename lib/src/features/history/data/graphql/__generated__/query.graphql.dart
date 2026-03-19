import '../../../../../graphql/__generated__/fragments.graphql.dart';
import '../../../../../graphql/__generated__/schema.graphql.dart';
import '../../../../manga_book/domain/chapter/graphql/__generated__/fragment.graphql.dart';
import '../../../../manga_book/domain/chapter_page/graphql/__generated__/fragment.graphql.dart';
import '../../../../manga_book/domain/manga/graphql/__generated__/fragment.graphql.dart';
import 'dart:async';
import 'package:catalyst/src/utils/misc/scalars.dart';
import 'package:flutter/widgets.dart' as widgets;
import 'package:gql/ast.dart';
import 'package:graphql/client.dart' as graphql;
import 'package:graphql_flutter/graphql_flutter.dart' as graphql_flutter;

class Variables$Query$GetReadingHistory {
  factory Variables$Query$GetReadingHistory({
    int? first,
    int? offset,
    int? after,
    int? before,
    Input$ChapterFilterInput? filter,
    List<Input$ChapterOrderInput>? order,
  }) =>
      Variables$Query$GetReadingHistory._({
        if (first != null) r'first': first,
        if (offset != null) r'offset': offset,
        if (after != null) r'after': after,
        if (before != null) r'before': before,
        if (filter != null) r'filter': filter,
        if (order != null) r'order': order,
      });

  Variables$Query$GetReadingHistory._(this._$data);

  factory Variables$Query$GetReadingHistory.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('first')) {
      final l$first = data['first'];
      result$data['first'] = (l$first as int?);
    }
    if (data.containsKey('offset')) {
      final l$offset = data['offset'];
      result$data['offset'] = (l$offset as int?);
    }
    if (data.containsKey('after')) {
      final l$after = data['after'];
      result$data['after'] = l$after == null ? null : cursorFromJson(l$after);
    }
    if (data.containsKey('before')) {
      final l$before = data['before'];
      result$data['before'] =
          l$before == null ? null : cursorFromJson(l$before);
    }
    if (data.containsKey('filter')) {
      final l$filter = data['filter'];
      result$data['filter'] = l$filter == null
          ? null
          : Input$ChapterFilterInput.fromJson(
              (l$filter as Map<String, dynamic>));
    }
    if (data.containsKey('order')) {
      final l$order = data['order'];
      result$data['order'] = (l$order as List<dynamic>?)
          ?.map((e) =>
              Input$ChapterOrderInput.fromJson((e as Map<String, dynamic>)))
          .toList();
    }
    return Variables$Query$GetReadingHistory._(result$data);
  }

  Map<String, dynamic> _$data;

  int? get first => (_$data['first'] as int?);

  int? get offset => (_$data['offset'] as int?);

  int? get after => (_$data['after'] as int?);

  int? get before => (_$data['before'] as int?);

  Input$ChapterFilterInput? get filter =>
      (_$data['filter'] as Input$ChapterFilterInput?);

  List<Input$ChapterOrderInput>? get order =>
      (_$data['order'] as List<Input$ChapterOrderInput>?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('first')) {
      final l$first = first;
      result$data['first'] = l$first;
    }
    if (_$data.containsKey('offset')) {
      final l$offset = offset;
      result$data['offset'] = l$offset;
    }
    if (_$data.containsKey('after')) {
      final l$after = after;
      result$data['after'] = l$after == null ? null : cursorToJson(l$after);
    }
    if (_$data.containsKey('before')) {
      final l$before = before;
      result$data['before'] = l$before == null ? null : cursorToJson(l$before);
    }
    if (_$data.containsKey('filter')) {
      final l$filter = filter;
      result$data['filter'] = l$filter?.toJson();
    }
    if (_$data.containsKey('order')) {
      final l$order = order;
      result$data['order'] = l$order?.map((e) => e.toJson()).toList();
    }
    return result$data;
  }

  CopyWith$Variables$Query$GetReadingHistory<Variables$Query$GetReadingHistory>
      get copyWith => CopyWith$Variables$Query$GetReadingHistory(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Query$GetReadingHistory ||
        runtimeType != other.runtimeType) {
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
    final l$after = after;
    final lOther$after = other.after;
    if (_$data.containsKey('after') != other._$data.containsKey('after')) {
      return false;
    }
    if (l$after != lOther$after) {
      return false;
    }
    final l$before = before;
    final lOther$before = other.before;
    if (_$data.containsKey('before') != other._$data.containsKey('before')) {
      return false;
    }
    if (l$before != lOther$before) {
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
    final l$order = order;
    final lOther$order = other.order;
    if (_$data.containsKey('order') != other._$data.containsKey('order')) {
      return false;
    }
    if (l$order != null && lOther$order != null) {
      if (l$order.length != lOther$order.length) {
        return false;
      }
      for (int i = 0; i < l$order.length; i++) {
        final l$order$entry = l$order[i];
        final lOther$order$entry = lOther$order[i];
        if (l$order$entry != lOther$order$entry) {
          return false;
        }
      }
    } else if (l$order != lOther$order) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$first = first;
    final l$offset = offset;
    final l$after = after;
    final l$before = before;
    final l$filter = filter;
    final l$order = order;
    return Object.hashAll([
      _$data.containsKey('first') ? l$first : const {},
      _$data.containsKey('offset') ? l$offset : const {},
      _$data.containsKey('after') ? l$after : const {},
      _$data.containsKey('before') ? l$before : const {},
      _$data.containsKey('filter') ? l$filter : const {},
      _$data.containsKey('order')
          ? l$order == null
              ? null
              : Object.hashAll(l$order.map((v) => v))
          : const {},
    ]);
  }
}

abstract class CopyWith$Variables$Query$GetReadingHistory<TRes> {
  factory CopyWith$Variables$Query$GetReadingHistory(
    Variables$Query$GetReadingHistory instance,
    TRes Function(Variables$Query$GetReadingHistory) then,
  ) = _CopyWithImpl$Variables$Query$GetReadingHistory;

  factory CopyWith$Variables$Query$GetReadingHistory.stub(TRes res) =
      _CopyWithStubImpl$Variables$Query$GetReadingHistory;

  TRes call({
    int? first,
    int? offset,
    int? after,
    int? before,
    Input$ChapterFilterInput? filter,
    List<Input$ChapterOrderInput>? order,
  });
}

class _CopyWithImpl$Variables$Query$GetReadingHistory<TRes>
    implements CopyWith$Variables$Query$GetReadingHistory<TRes> {
  _CopyWithImpl$Variables$Query$GetReadingHistory(
    this._instance,
    this._then,
  );

  final Variables$Query$GetReadingHistory _instance;

  final TRes Function(Variables$Query$GetReadingHistory) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? first = _undefined,
    Object? offset = _undefined,
    Object? after = _undefined,
    Object? before = _undefined,
    Object? filter = _undefined,
    Object? order = _undefined,
  }) =>
      _then(Variables$Query$GetReadingHistory._({
        ..._instance._$data,
        if (first != _undefined) 'first': (first as int?),
        if (offset != _undefined) 'offset': (offset as int?),
        if (after != _undefined) 'after': (after as int?),
        if (before != _undefined) 'before': (before as int?),
        if (filter != _undefined)
          'filter': (filter as Input$ChapterFilterInput?),
        if (order != _undefined)
          'order': (order as List<Input$ChapterOrderInput>?),
      }));
}

class _CopyWithStubImpl$Variables$Query$GetReadingHistory<TRes>
    implements CopyWith$Variables$Query$GetReadingHistory<TRes> {
  _CopyWithStubImpl$Variables$Query$GetReadingHistory(this._res);

  TRes _res;

  call({
    int? first,
    int? offset,
    int? after,
    int? before,
    Input$ChapterFilterInput? filter,
    List<Input$ChapterOrderInput>? order,
  }) =>
      _res;
}

class Query$GetReadingHistory {
  Query$GetReadingHistory({
    required this.chapters,
    this.$__typename = 'Query',
  });

  factory Query$GetReadingHistory.fromJson(Map<String, dynamic> json) {
    final l$chapters = json['chapters'];
    final l$$__typename = json['__typename'];
    return Query$GetReadingHistory(
      chapters: Fragment$ChapterPageWithMangaDto.fromJson(
          (l$chapters as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Fragment$ChapterPageWithMangaDto chapters;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$chapters = chapters;
    _resultData['chapters'] = l$chapters.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$chapters = chapters;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$chapters,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetReadingHistory || runtimeType != other.runtimeType) {
      return false;
    }
    final l$chapters = chapters;
    final lOther$chapters = other.chapters;
    if (l$chapters != lOther$chapters) {
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

extension UtilityExtension$Query$GetReadingHistory on Query$GetReadingHistory {
  CopyWith$Query$GetReadingHistory<Query$GetReadingHistory> get copyWith =>
      CopyWith$Query$GetReadingHistory(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Query$GetReadingHistory<TRes> {
  factory CopyWith$Query$GetReadingHistory(
    Query$GetReadingHistory instance,
    TRes Function(Query$GetReadingHistory) then,
  ) = _CopyWithImpl$Query$GetReadingHistory;

  factory CopyWith$Query$GetReadingHistory.stub(TRes res) =
      _CopyWithStubImpl$Query$GetReadingHistory;

  TRes call({
    Fragment$ChapterPageWithMangaDto? chapters,
    String? $__typename,
  });
  CopyWith$Fragment$ChapterPageWithMangaDto<TRes> get chapters;
}

class _CopyWithImpl$Query$GetReadingHistory<TRes>
    implements CopyWith$Query$GetReadingHistory<TRes> {
  _CopyWithImpl$Query$GetReadingHistory(
    this._instance,
    this._then,
  );

  final Query$GetReadingHistory _instance;

  final TRes Function(Query$GetReadingHistory) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? chapters = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetReadingHistory(
        chapters: chapters == _undefined || chapters == null
            ? _instance.chapters
            : (chapters as Fragment$ChapterPageWithMangaDto),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Fragment$ChapterPageWithMangaDto<TRes> get chapters {
    final local$chapters = _instance.chapters;
    return CopyWith$Fragment$ChapterPageWithMangaDto(
        local$chapters, (e) => call(chapters: e));
  }
}

class _CopyWithStubImpl$Query$GetReadingHistory<TRes>
    implements CopyWith$Query$GetReadingHistory<TRes> {
  _CopyWithStubImpl$Query$GetReadingHistory(this._res);

  TRes _res;

  call({
    Fragment$ChapterPageWithMangaDto? chapters,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$ChapterPageWithMangaDto<TRes> get chapters =>
      CopyWith$Fragment$ChapterPageWithMangaDto.stub(_res);
}

const documentNodeQueryGetReadingHistory = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.query,
    name: NameNode(value: 'GetReadingHistory'),
    variableDefinitions: [
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
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'after')),
        type: NamedTypeNode(
          name: NameNode(value: 'Cursor'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'before')),
        type: NamedTypeNode(
          name: NameNode(value: 'Cursor'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'filter')),
        type: NamedTypeNode(
          name: NameNode(value: 'ChapterFilterInput'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'order')),
        type: ListTypeNode(
          type: NamedTypeNode(
            name: NameNode(value: 'ChapterOrderInput'),
            isNonNull: true,
          ),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
    ],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'chapters'),
        alias: null,
        arguments: [
          ArgumentNode(
            name: NameNode(value: 'first'),
            value: VariableNode(name: NameNode(value: 'first')),
          ),
          ArgumentNode(
            name: NameNode(value: 'offset'),
            value: VariableNode(name: NameNode(value: 'offset')),
          ),
          ArgumentNode(
            name: NameNode(value: 'after'),
            value: VariableNode(name: NameNode(value: 'after')),
          ),
          ArgumentNode(
            name: NameNode(value: 'before'),
            value: VariableNode(name: NameNode(value: 'before')),
          ),
          ArgumentNode(
            name: NameNode(value: 'filter'),
            value: VariableNode(name: NameNode(value: 'filter')),
          ),
          ArgumentNode(
            name: NameNode(value: 'order'),
            value: VariableNode(name: NameNode(value: 'order')),
          ),
        ],
        directives: [],
        selectionSet: SelectionSetNode(selections: [
          FragmentSpreadNode(
            name: NameNode(value: 'ChapterPageWithMangaDto'),
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
  fragmentDefinitionChapterPageWithMangaDto,
  fragmentDefinitionChapterWithMangaDto,
  fragmentDefinitionChapterDto,
  fragmentDefinitionMangaBaseDto,
  fragmentDefinitionPageInfoDto,
]);
Query$GetReadingHistory _parserFn$Query$GetReadingHistory(
        Map<String, dynamic> data) =>
    Query$GetReadingHistory.fromJson(data);
typedef OnQueryComplete$Query$GetReadingHistory = FutureOr<void> Function(
  Map<String, dynamic>?,
  Query$GetReadingHistory?,
);

class Options$Query$GetReadingHistory
    extends graphql.QueryOptions<Query$GetReadingHistory> {
  Options$Query$GetReadingHistory({
    String? operationName,
    Variables$Query$GetReadingHistory? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetReadingHistory? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$GetReadingHistory? onComplete,
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
                    data == null
                        ? null
                        : _parserFn$Query$GetReadingHistory(data),
                  ),
          onError: onError,
          document: documentNodeQueryGetReadingHistory,
          parserFn: _parserFn$Query$GetReadingHistory,
        );

  final OnQueryComplete$Query$GetReadingHistory? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onComplete == null
            ? super.properties
            : super.properties.where((property) => property != onComplete),
        onCompleteWithParsed,
      ];
}

class WatchOptions$Query$GetReadingHistory
    extends graphql.WatchQueryOptions<Query$GetReadingHistory> {
  WatchOptions$Query$GetReadingHistory({
    String? operationName,
    Variables$Query$GetReadingHistory? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetReadingHistory? typedOptimisticResult,
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
          document: documentNodeQueryGetReadingHistory,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Query$GetReadingHistory,
        );
}

class FetchMoreOptions$Query$GetReadingHistory
    extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$GetReadingHistory({
    required graphql.UpdateQuery updateQuery,
    Variables$Query$GetReadingHistory? variables,
  }) : super(
          updateQuery: updateQuery,
          variables: variables?.toJson() ?? {},
          document: documentNodeQueryGetReadingHistory,
        );
}

extension ClientExtension$Query$GetReadingHistory on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$GetReadingHistory>> query$GetReadingHistory(
          [Options$Query$GetReadingHistory? options]) async =>
      await this.query(options ?? Options$Query$GetReadingHistory());

  graphql.ObservableQuery<Query$GetReadingHistory> watchQuery$GetReadingHistory(
          [WatchOptions$Query$GetReadingHistory? options]) =>
      this.watchQuery(options ?? WatchOptions$Query$GetReadingHistory());

  void writeQuery$GetReadingHistory({
    required Query$GetReadingHistory data,
    Variables$Query$GetReadingHistory? variables,
    bool broadcast = true,
  }) =>
      this.writeQuery(
        graphql.Request(
          operation:
              graphql.Operation(document: documentNodeQueryGetReadingHistory),
          variables: variables?.toJson() ?? const {},
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );

  Query$GetReadingHistory? readQuery$GetReadingHistory({
    Variables$Query$GetReadingHistory? variables,
    bool optimistic = true,
  }) {
    final result = this.readQuery(
      graphql.Request(
        operation:
            graphql.Operation(document: documentNodeQueryGetReadingHistory),
        variables: variables?.toJson() ?? const {},
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Query$GetReadingHistory.fromJson(result);
  }
}

graphql_flutter.QueryHookResult<Query$GetReadingHistory>
    useQuery$GetReadingHistory([Options$Query$GetReadingHistory? options]) =>
        graphql_flutter.useQuery(options ?? Options$Query$GetReadingHistory());
graphql.ObservableQuery<Query$GetReadingHistory>
    useWatchQuery$GetReadingHistory(
            [WatchOptions$Query$GetReadingHistory? options]) =>
        graphql_flutter
            .useWatchQuery(options ?? WatchOptions$Query$GetReadingHistory());

class Query$GetReadingHistory$Widget
    extends graphql_flutter.Query<Query$GetReadingHistory> {
  Query$GetReadingHistory$Widget({
    widgets.Key? key,
    Options$Query$GetReadingHistory? options,
    required graphql_flutter.QueryBuilder<Query$GetReadingHistory> builder,
  }) : super(
          key: key,
          options: options ?? Options$Query$GetReadingHistory(),
          builder: builder,
        );
}
