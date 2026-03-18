import '../../../../../../graphql/__generated__/fragments.graphql.dart';
import '../../../../../../graphql/__generated__/schema.graphql.dart';
import '../../../../../browse_center/domain/manga_page/graphql/__generated__/fragment.graphql.dart';
import '../../../../../browse_center/domain/source/graphql/__generated__/fragment.graphql.dart';
import '../../../../../library/domain/category/graphql/__generated__/fragment.graphql.dart';
import '../../../../domain/chapter/graphql/__generated__/fragment.graphql.dart';
import '../../../../domain/chapter_page/graphql/__generated__/fragment.graphql.dart';
import '../../../../domain/manga/graphql/__generated__/fragment.graphql.dart';
import '../../../../domain/update_status/graphql/__generated__/fragment.graphql.dart';
import 'dart:async';
import 'package:flutter/widgets.dart' as widgets;
import 'package:gql/ast.dart';
import 'package:graphql/client.dart' as graphql;
import 'package:graphql_flutter/graphql_flutter.dart' as graphql_flutter;
import 'package:catalyst/src/utils/misc/scalars.dart';

class Variables$Query$GetChapterWithMangaPage {
  factory Variables$Query$GetChapterWithMangaPage({
    int? after,
    int? before,
    Input$ChapterConditionInput? condition,
    Input$ChapterFilterInput? filter,
    int? first,
    int? last,
    int? offset,
    List<Input$ChapterOrderInput>? order,
  }) =>
      Variables$Query$GetChapterWithMangaPage._({
        if (after != null) r'after': after,
        if (before != null) r'before': before,
        if (condition != null) r'condition': condition,
        if (filter != null) r'filter': filter,
        if (first != null) r'first': first,
        if (last != null) r'last': last,
        if (offset != null) r'offset': offset,
        if (order != null) r'order': order,
      });

  Variables$Query$GetChapterWithMangaPage._(this._$data);

  factory Variables$Query$GetChapterWithMangaPage.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('after')) {
      final l$after = data['after'];
      result$data['after'] = l$after == null ? null : cursorFromJson(l$after);
    }
    if (data.containsKey('before')) {
      final l$before = data['before'];
      result$data['before'] =
          l$before == null ? null : cursorFromJson(l$before);
    }
    if (data.containsKey('condition')) {
      final l$condition = data['condition'];
      result$data['condition'] = l$condition == null
          ? null
          : Input$ChapterConditionInput.fromJson(
              (l$condition as Map<String, dynamic>));
    }
    if (data.containsKey('filter')) {
      final l$filter = data['filter'];
      result$data['filter'] = l$filter == null
          ? null
          : Input$ChapterFilterInput.fromJson(
              (l$filter as Map<String, dynamic>));
    }
    if (data.containsKey('first')) {
      final l$first = data['first'];
      result$data['first'] = (l$first as int?);
    }
    if (data.containsKey('last')) {
      final l$last = data['last'];
      result$data['last'] = (l$last as int?);
    }
    if (data.containsKey('offset')) {
      final l$offset = data['offset'];
      result$data['offset'] = (l$offset as int?);
    }
    if (data.containsKey('order')) {
      final l$order = data['order'];
      result$data['order'] = (l$order as List<dynamic>?)
          ?.map((e) =>
              Input$ChapterOrderInput.fromJson((e as Map<String, dynamic>)))
          .toList();
    }
    return Variables$Query$GetChapterWithMangaPage._(result$data);
  }

  Map<String, dynamic> _$data;

  int? get after => (_$data['after'] as int?);

  int? get before => (_$data['before'] as int?);

  Input$ChapterConditionInput? get condition =>
      (_$data['condition'] as Input$ChapterConditionInput?);

  Input$ChapterFilterInput? get filter =>
      (_$data['filter'] as Input$ChapterFilterInput?);

  int? get first => (_$data['first'] as int?);

  int? get last => (_$data['last'] as int?);

  int? get offset => (_$data['offset'] as int?);

  List<Input$ChapterOrderInput>? get order =>
      (_$data['order'] as List<Input$ChapterOrderInput>?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('after')) {
      final l$after = after;
      result$data['after'] = l$after == null ? null : cursorToJson(l$after);
    }
    if (_$data.containsKey('before')) {
      final l$before = before;
      result$data['before'] = l$before == null ? null : cursorToJson(l$before);
    }
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
    if (_$data.containsKey('last')) {
      final l$last = last;
      result$data['last'] = l$last;
    }
    if (_$data.containsKey('offset')) {
      final l$offset = offset;
      result$data['offset'] = l$offset;
    }
    if (_$data.containsKey('order')) {
      final l$order = order;
      result$data['order'] = l$order?.map((e) => e.toJson()).toList();
    }
    return result$data;
  }

  CopyWith$Variables$Query$GetChapterWithMangaPage<
          Variables$Query$GetChapterWithMangaPage>
      get copyWith => CopyWith$Variables$Query$GetChapterWithMangaPage(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Query$GetChapterWithMangaPage ||
        runtimeType != other.runtimeType) {
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
    final l$last = last;
    final lOther$last = other.last;
    if (_$data.containsKey('last') != other._$data.containsKey('last')) {
      return false;
    }
    if (l$last != lOther$last) {
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
    final l$after = after;
    final l$before = before;
    final l$condition = condition;
    final l$filter = filter;
    final l$first = first;
    final l$last = last;
    final l$offset = offset;
    final l$order = order;
    return Object.hashAll([
      _$data.containsKey('after') ? l$after : const {},
      _$data.containsKey('before') ? l$before : const {},
      _$data.containsKey('condition') ? l$condition : const {},
      _$data.containsKey('filter') ? l$filter : const {},
      _$data.containsKey('first') ? l$first : const {},
      _$data.containsKey('last') ? l$last : const {},
      _$data.containsKey('offset') ? l$offset : const {},
      _$data.containsKey('order')
          ? l$order == null
              ? null
              : Object.hashAll(l$order.map((v) => v))
          : const {},
    ]);
  }
}

abstract class CopyWith$Variables$Query$GetChapterWithMangaPage<TRes> {
  factory CopyWith$Variables$Query$GetChapterWithMangaPage(
    Variables$Query$GetChapterWithMangaPage instance,
    TRes Function(Variables$Query$GetChapterWithMangaPage) then,
  ) = _CopyWithImpl$Variables$Query$GetChapterWithMangaPage;

  factory CopyWith$Variables$Query$GetChapterWithMangaPage.stub(TRes res) =
      _CopyWithStubImpl$Variables$Query$GetChapterWithMangaPage;

  TRes call({
    int? after,
    int? before,
    Input$ChapterConditionInput? condition,
    Input$ChapterFilterInput? filter,
    int? first,
    int? last,
    int? offset,
    List<Input$ChapterOrderInput>? order,
  });
}

class _CopyWithImpl$Variables$Query$GetChapterWithMangaPage<TRes>
    implements CopyWith$Variables$Query$GetChapterWithMangaPage<TRes> {
  _CopyWithImpl$Variables$Query$GetChapterWithMangaPage(
    this._instance,
    this._then,
  );

  final Variables$Query$GetChapterWithMangaPage _instance;

  final TRes Function(Variables$Query$GetChapterWithMangaPage) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? after = _undefined,
    Object? before = _undefined,
    Object? condition = _undefined,
    Object? filter = _undefined,
    Object? first = _undefined,
    Object? last = _undefined,
    Object? offset = _undefined,
    Object? order = _undefined,
  }) =>
      _then(Variables$Query$GetChapterWithMangaPage._({
        ..._instance._$data,
        if (after != _undefined) 'after': (after as int?),
        if (before != _undefined) 'before': (before as int?),
        if (condition != _undefined)
          'condition': (condition as Input$ChapterConditionInput?),
        if (filter != _undefined)
          'filter': (filter as Input$ChapterFilterInput?),
        if (first != _undefined) 'first': (first as int?),
        if (last != _undefined) 'last': (last as int?),
        if (offset != _undefined) 'offset': (offset as int?),
        if (order != _undefined)
          'order': (order as List<Input$ChapterOrderInput>?),
      }));
}

class _CopyWithStubImpl$Variables$Query$GetChapterWithMangaPage<TRes>
    implements CopyWith$Variables$Query$GetChapterWithMangaPage<TRes> {
  _CopyWithStubImpl$Variables$Query$GetChapterWithMangaPage(this._res);

  TRes _res;

  call({
    int? after,
    int? before,
    Input$ChapterConditionInput? condition,
    Input$ChapterFilterInput? filter,
    int? first,
    int? last,
    int? offset,
    List<Input$ChapterOrderInput>? order,
  }) =>
      _res;
}

class Query$GetChapterWithMangaPage {
  Query$GetChapterWithMangaPage({
    required this.chapters,
    this.$__typename = 'Query',
  });

  factory Query$GetChapterWithMangaPage.fromJson(Map<String, dynamic> json) {
    final l$chapters = json['chapters'];
    final l$$__typename = json['__typename'];
    return Query$GetChapterWithMangaPage(
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
    if (other is! Query$GetChapterWithMangaPage ||
        runtimeType != other.runtimeType) {
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

extension UtilityExtension$Query$GetChapterWithMangaPage
    on Query$GetChapterWithMangaPage {
  CopyWith$Query$GetChapterWithMangaPage<Query$GetChapterWithMangaPage>
      get copyWith => CopyWith$Query$GetChapterWithMangaPage(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetChapterWithMangaPage<TRes> {
  factory CopyWith$Query$GetChapterWithMangaPage(
    Query$GetChapterWithMangaPage instance,
    TRes Function(Query$GetChapterWithMangaPage) then,
  ) = _CopyWithImpl$Query$GetChapterWithMangaPage;

  factory CopyWith$Query$GetChapterWithMangaPage.stub(TRes res) =
      _CopyWithStubImpl$Query$GetChapterWithMangaPage;

  TRes call({
    Fragment$ChapterPageWithMangaDto? chapters,
    String? $__typename,
  });
  CopyWith$Fragment$ChapterPageWithMangaDto<TRes> get chapters;
}

class _CopyWithImpl$Query$GetChapterWithMangaPage<TRes>
    implements CopyWith$Query$GetChapterWithMangaPage<TRes> {
  _CopyWithImpl$Query$GetChapterWithMangaPage(
    this._instance,
    this._then,
  );

  final Query$GetChapterWithMangaPage _instance;

  final TRes Function(Query$GetChapterWithMangaPage) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? chapters = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetChapterWithMangaPage(
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

class _CopyWithStubImpl$Query$GetChapterWithMangaPage<TRes>
    implements CopyWith$Query$GetChapterWithMangaPage<TRes> {
  _CopyWithStubImpl$Query$GetChapterWithMangaPage(this._res);

  TRes _res;

  call({
    Fragment$ChapterPageWithMangaDto? chapters,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$ChapterPageWithMangaDto<TRes> get chapters =>
      CopyWith$Fragment$ChapterPageWithMangaDto.stub(_res);
}

const documentNodeQueryGetChapterWithMangaPage = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.query,
    name: NameNode(value: 'GetChapterWithMangaPage'),
    variableDefinitions: [
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
        variable: VariableNode(name: NameNode(value: 'condition')),
        type: NamedTypeNode(
          name: NameNode(value: 'ChapterConditionInput'),
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
        variable: VariableNode(name: NameNode(value: 'first')),
        type: NamedTypeNode(
          name: NameNode(value: 'Int'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'last')),
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
            name: NameNode(value: 'after'),
            value: VariableNode(name: NameNode(value: 'after')),
          ),
          ArgumentNode(
            name: NameNode(value: 'before'),
            value: VariableNode(name: NameNode(value: 'before')),
          ),
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
            name: NameNode(value: 'last'),
            value: VariableNode(name: NameNode(value: 'last')),
          ),
          ArgumentNode(
            name: NameNode(value: 'offset'),
            value: VariableNode(name: NameNode(value: 'offset')),
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
Query$GetChapterWithMangaPage _parserFn$Query$GetChapterWithMangaPage(
        Map<String, dynamic> data) =>
    Query$GetChapterWithMangaPage.fromJson(data);
typedef OnQueryComplete$Query$GetChapterWithMangaPage = FutureOr<void> Function(
  Map<String, dynamic>?,
  Query$GetChapterWithMangaPage?,
);

class Options$Query$GetChapterWithMangaPage
    extends graphql.QueryOptions<Query$GetChapterWithMangaPage> {
  Options$Query$GetChapterWithMangaPage({
    String? operationName,
    Variables$Query$GetChapterWithMangaPage? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetChapterWithMangaPage? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$GetChapterWithMangaPage? onComplete,
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
                        : _parserFn$Query$GetChapterWithMangaPage(data),
                  ),
          onError: onError,
          document: documentNodeQueryGetChapterWithMangaPage,
          parserFn: _parserFn$Query$GetChapterWithMangaPage,
        );

  final OnQueryComplete$Query$GetChapterWithMangaPage? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onComplete == null
            ? super.properties
            : super.properties.where((property) => property != onComplete),
        onCompleteWithParsed,
      ];
}

class WatchOptions$Query$GetChapterWithMangaPage
    extends graphql.WatchQueryOptions<Query$GetChapterWithMangaPage> {
  WatchOptions$Query$GetChapterWithMangaPage({
    String? operationName,
    Variables$Query$GetChapterWithMangaPage? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetChapterWithMangaPage? typedOptimisticResult,
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
          document: documentNodeQueryGetChapterWithMangaPage,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Query$GetChapterWithMangaPage,
        );
}

class FetchMoreOptions$Query$GetChapterWithMangaPage
    extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$GetChapterWithMangaPage({
    required graphql.UpdateQuery updateQuery,
    Variables$Query$GetChapterWithMangaPage? variables,
  }) : super(
          updateQuery: updateQuery,
          variables: variables?.toJson() ?? {},
          document: documentNodeQueryGetChapterWithMangaPage,
        );
}

extension ClientExtension$Query$GetChapterWithMangaPage
    on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$GetChapterWithMangaPage>>
      query$GetChapterWithMangaPage(
              [Options$Query$GetChapterWithMangaPage? options]) async =>
          await this.query(options ?? Options$Query$GetChapterWithMangaPage());

  graphql.ObservableQuery<
      Query$GetChapterWithMangaPage> watchQuery$GetChapterWithMangaPage(
          [WatchOptions$Query$GetChapterWithMangaPage? options]) =>
      this.watchQuery(options ?? WatchOptions$Query$GetChapterWithMangaPage());

  void writeQuery$GetChapterWithMangaPage({
    required Query$GetChapterWithMangaPage data,
    Variables$Query$GetChapterWithMangaPage? variables,
    bool broadcast = true,
  }) =>
      this.writeQuery(
        graphql.Request(
          operation: graphql.Operation(
              document: documentNodeQueryGetChapterWithMangaPage),
          variables: variables?.toJson() ?? const {},
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );

  Query$GetChapterWithMangaPage? readQuery$GetChapterWithMangaPage({
    Variables$Query$GetChapterWithMangaPage? variables,
    bool optimistic = true,
  }) {
    final result = this.readQuery(
      graphql.Request(
        operation: graphql.Operation(
            document: documentNodeQueryGetChapterWithMangaPage),
        variables: variables?.toJson() ?? const {},
      ),
      optimistic: optimistic,
    );
    return result == null
        ? null
        : Query$GetChapterWithMangaPage.fromJson(result);
  }
}

graphql_flutter.QueryHookResult<Query$GetChapterWithMangaPage>
    useQuery$GetChapterWithMangaPage(
            [Options$Query$GetChapterWithMangaPage? options]) =>
        graphql_flutter
            .useQuery(options ?? Options$Query$GetChapterWithMangaPage());
graphql.ObservableQuery<Query$GetChapterWithMangaPage>
    useWatchQuery$GetChapterWithMangaPage(
            [WatchOptions$Query$GetChapterWithMangaPage? options]) =>
        graphql_flutter.useWatchQuery(
            options ?? WatchOptions$Query$GetChapterWithMangaPage());

class Query$GetChapterWithMangaPage$Widget
    extends graphql_flutter.Query<Query$GetChapterWithMangaPage> {
  Query$GetChapterWithMangaPage$Widget({
    widgets.Key? key,
    Options$Query$GetChapterWithMangaPage? options,
    required graphql_flutter.QueryBuilder<Query$GetChapterWithMangaPage>
        builder,
  }) : super(
          key: key,
          options: options ?? Options$Query$GetChapterWithMangaPage(),
          builder: builder,
        );
}

class Variables$Mutation$UpdateLibraryMangas {
  factory Variables$Mutation$UpdateLibraryMangas(
          {required Input$UpdateLibraryMangaInput input}) =>
      Variables$Mutation$UpdateLibraryMangas._({
        r'input': input,
      });

  Variables$Mutation$UpdateLibraryMangas._(this._$data);

  factory Variables$Mutation$UpdateLibraryMangas.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$input = data['input'];
    result$data['input'] = Input$UpdateLibraryMangaInput.fromJson(
        (l$input as Map<String, dynamic>));
    return Variables$Mutation$UpdateLibraryMangas._(result$data);
  }

  Map<String, dynamic> _$data;

  Input$UpdateLibraryMangaInput get input =>
      (_$data['input'] as Input$UpdateLibraryMangaInput);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$input = input;
    result$data['input'] = l$input.toJson();
    return result$data;
  }

  CopyWith$Variables$Mutation$UpdateLibraryMangas<
          Variables$Mutation$UpdateLibraryMangas>
      get copyWith => CopyWith$Variables$Mutation$UpdateLibraryMangas(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$UpdateLibraryMangas ||
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

abstract class CopyWith$Variables$Mutation$UpdateLibraryMangas<TRes> {
  factory CopyWith$Variables$Mutation$UpdateLibraryMangas(
    Variables$Mutation$UpdateLibraryMangas instance,
    TRes Function(Variables$Mutation$UpdateLibraryMangas) then,
  ) = _CopyWithImpl$Variables$Mutation$UpdateLibraryMangas;

  factory CopyWith$Variables$Mutation$UpdateLibraryMangas.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$UpdateLibraryMangas;

  TRes call({Input$UpdateLibraryMangaInput? input});
}

class _CopyWithImpl$Variables$Mutation$UpdateLibraryMangas<TRes>
    implements CopyWith$Variables$Mutation$UpdateLibraryMangas<TRes> {
  _CopyWithImpl$Variables$Mutation$UpdateLibraryMangas(
    this._instance,
    this._then,
  );

  final Variables$Mutation$UpdateLibraryMangas _instance;

  final TRes Function(Variables$Mutation$UpdateLibraryMangas) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? input = _undefined}) =>
      _then(Variables$Mutation$UpdateLibraryMangas._({
        ..._instance._$data,
        if (input != _undefined && input != null)
          'input': (input as Input$UpdateLibraryMangaInput),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$UpdateLibraryMangas<TRes>
    implements CopyWith$Variables$Mutation$UpdateLibraryMangas<TRes> {
  _CopyWithStubImpl$Variables$Mutation$UpdateLibraryMangas(this._res);

  TRes _res;

  call({Input$UpdateLibraryMangaInput? input}) => _res;
}

class Mutation$UpdateLibraryMangas {
  Mutation$UpdateLibraryMangas({
    this.updateLibraryManga,
    this.$__typename = 'Mutation',
  });

  factory Mutation$UpdateLibraryMangas.fromJson(Map<String, dynamic> json) {
    final l$updateLibraryManga = json['updateLibraryManga'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateLibraryMangas(
      updateLibraryManga: l$updateLibraryManga == null
          ? null
          : Mutation$UpdateLibraryMangas$updateLibraryManga.fromJson(
              (l$updateLibraryManga as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$UpdateLibraryMangas$updateLibraryManga? updateLibraryManga;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$updateLibraryManga = updateLibraryManga;
    _resultData['updateLibraryManga'] = l$updateLibraryManga?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$updateLibraryManga = updateLibraryManga;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$updateLibraryManga,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$UpdateLibraryMangas ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$updateLibraryManga = updateLibraryManga;
    final lOther$updateLibraryManga = other.updateLibraryManga;
    if (l$updateLibraryManga != lOther$updateLibraryManga) {
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

extension UtilityExtension$Mutation$UpdateLibraryMangas
    on Mutation$UpdateLibraryMangas {
  CopyWith$Mutation$UpdateLibraryMangas<Mutation$UpdateLibraryMangas>
      get copyWith => CopyWith$Mutation$UpdateLibraryMangas(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdateLibraryMangas<TRes> {
  factory CopyWith$Mutation$UpdateLibraryMangas(
    Mutation$UpdateLibraryMangas instance,
    TRes Function(Mutation$UpdateLibraryMangas) then,
  ) = _CopyWithImpl$Mutation$UpdateLibraryMangas;

  factory CopyWith$Mutation$UpdateLibraryMangas.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateLibraryMangas;

  TRes call({
    Mutation$UpdateLibraryMangas$updateLibraryManga? updateLibraryManga,
    String? $__typename,
  });
  CopyWith$Mutation$UpdateLibraryMangas$updateLibraryManga<TRes>
      get updateLibraryManga;
}

class _CopyWithImpl$Mutation$UpdateLibraryMangas<TRes>
    implements CopyWith$Mutation$UpdateLibraryMangas<TRes> {
  _CopyWithImpl$Mutation$UpdateLibraryMangas(
    this._instance,
    this._then,
  );

  final Mutation$UpdateLibraryMangas _instance;

  final TRes Function(Mutation$UpdateLibraryMangas) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? updateLibraryManga = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateLibraryMangas(
        updateLibraryManga: updateLibraryManga == _undefined
            ? _instance.updateLibraryManga
            : (updateLibraryManga
                as Mutation$UpdateLibraryMangas$updateLibraryManga?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$UpdateLibraryMangas$updateLibraryManga<TRes>
      get updateLibraryManga {
    final local$updateLibraryManga = _instance.updateLibraryManga;
    return local$updateLibraryManga == null
        ? CopyWith$Mutation$UpdateLibraryMangas$updateLibraryManga.stub(
            _then(_instance))
        : CopyWith$Mutation$UpdateLibraryMangas$updateLibraryManga(
            local$updateLibraryManga, (e) => call(updateLibraryManga: e));
  }
}

class _CopyWithStubImpl$Mutation$UpdateLibraryMangas<TRes>
    implements CopyWith$Mutation$UpdateLibraryMangas<TRes> {
  _CopyWithStubImpl$Mutation$UpdateLibraryMangas(this._res);

  TRes _res;

  call({
    Mutation$UpdateLibraryMangas$updateLibraryManga? updateLibraryManga,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$UpdateLibraryMangas$updateLibraryManga<TRes>
      get updateLibraryManga =>
          CopyWith$Mutation$UpdateLibraryMangas$updateLibraryManga.stub(_res);
}

const documentNodeMutationUpdateLibraryMangas = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'UpdateLibraryMangas'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'input')),
        type: NamedTypeNode(
          name: NameNode(value: 'UpdateLibraryMangaInput'),
          isNonNull: true,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      )
    ],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'updateLibraryManga'),
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
            name: NameNode(value: 'updateStatus'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: SelectionSetNode(selections: [
              FragmentSpreadNode(
                name: NameNode(value: 'UpdateStatusBaseDto'),
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
  fragmentDefinitionUpdateStatusBaseDto,
]);
Mutation$UpdateLibraryMangas _parserFn$Mutation$UpdateLibraryMangas(
        Map<String, dynamic> data) =>
    Mutation$UpdateLibraryMangas.fromJson(data);
typedef OnMutationCompleted$Mutation$UpdateLibraryMangas = FutureOr<void>
    Function(
  Map<String, dynamic>?,
  Mutation$UpdateLibraryMangas?,
);

class Options$Mutation$UpdateLibraryMangas
    extends graphql.MutationOptions<Mutation$UpdateLibraryMangas> {
  Options$Mutation$UpdateLibraryMangas({
    String? operationName,
    required Variables$Mutation$UpdateLibraryMangas variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateLibraryMangas? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateLibraryMangas? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateLibraryMangas>? update,
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
                        : _parserFn$Mutation$UpdateLibraryMangas(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateLibraryMangas,
          parserFn: _parserFn$Mutation$UpdateLibraryMangas,
        );

  final OnMutationCompleted$Mutation$UpdateLibraryMangas? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$UpdateLibraryMangas
    extends graphql.WatchQueryOptions<Mutation$UpdateLibraryMangas> {
  WatchOptions$Mutation$UpdateLibraryMangas({
    String? operationName,
    required Variables$Mutation$UpdateLibraryMangas variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateLibraryMangas? typedOptimisticResult,
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
          document: documentNodeMutationUpdateLibraryMangas,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$UpdateLibraryMangas,
        );
}

extension ClientExtension$Mutation$UpdateLibraryMangas
    on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$UpdateLibraryMangas>>
      mutate$UpdateLibraryMangas(
              Options$Mutation$UpdateLibraryMangas options) async =>
          await this.mutate(options);

  graphql.ObservableQuery<Mutation$UpdateLibraryMangas>
      watchMutation$UpdateLibraryMangas(
              WatchOptions$Mutation$UpdateLibraryMangas options) =>
          this.watchMutation(options);
}

class Mutation$UpdateLibraryMangas$HookResult {
  Mutation$UpdateLibraryMangas$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$UpdateLibraryMangas runMutation;

  final graphql.QueryResult<Mutation$UpdateLibraryMangas> result;
}

Mutation$UpdateLibraryMangas$HookResult useMutation$UpdateLibraryMangas(
    [WidgetOptions$Mutation$UpdateLibraryMangas? options]) {
  final result = graphql_flutter
      .useMutation(options ?? WidgetOptions$Mutation$UpdateLibraryMangas());
  return Mutation$UpdateLibraryMangas$HookResult(
    (variables, {optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables.toJson(),
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$UpdateLibraryMangas>
    useWatchMutation$UpdateLibraryMangas(
            WatchOptions$Mutation$UpdateLibraryMangas options) =>
        graphql_flutter.useWatchMutation(options);

class WidgetOptions$Mutation$UpdateLibraryMangas
    extends graphql.MutationOptions<Mutation$UpdateLibraryMangas> {
  WidgetOptions$Mutation$UpdateLibraryMangas({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateLibraryMangas? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateLibraryMangas? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateLibraryMangas>? update,
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
                        : _parserFn$Mutation$UpdateLibraryMangas(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateLibraryMangas,
          parserFn: _parserFn$Mutation$UpdateLibraryMangas,
        );

  final OnMutationCompleted$Mutation$UpdateLibraryMangas? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$UpdateLibraryMangas
    = graphql.MultiSourceResult<Mutation$UpdateLibraryMangas> Function(
  Variables$Mutation$UpdateLibraryMangas, {
  Object? optimisticResult,
  Mutation$UpdateLibraryMangas? typedOptimisticResult,
});
typedef Builder$Mutation$UpdateLibraryMangas = widgets.Widget Function(
  RunMutation$Mutation$UpdateLibraryMangas,
  graphql.QueryResult<Mutation$UpdateLibraryMangas>?,
);

class Mutation$UpdateLibraryMangas$Widget
    extends graphql_flutter.Mutation<Mutation$UpdateLibraryMangas> {
  Mutation$UpdateLibraryMangas$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$UpdateLibraryMangas? options,
    required Builder$Mutation$UpdateLibraryMangas builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$UpdateLibraryMangas(),
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

class Mutation$UpdateLibraryMangas$updateLibraryManga {
  Mutation$UpdateLibraryMangas$updateLibraryManga({
    required this.updateStatus,
    this.$__typename = 'UpdateLibraryMangaPayload',
  });

  factory Mutation$UpdateLibraryMangas$updateLibraryManga.fromJson(
      Map<String, dynamic> json) {
    final l$updateStatus = json['updateStatus'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateLibraryMangas$updateLibraryManga(
      updateStatus: Fragment$UpdateStatusBaseDto.fromJson(
          (l$updateStatus as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Fragment$UpdateStatusBaseDto updateStatus;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$updateStatus = updateStatus;
    _resultData['updateStatus'] = l$updateStatus.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$updateStatus = updateStatus;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$updateStatus,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$UpdateLibraryMangas$updateLibraryManga ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$updateStatus = updateStatus;
    final lOther$updateStatus = other.updateStatus;
    if (l$updateStatus != lOther$updateStatus) {
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

extension UtilityExtension$Mutation$UpdateLibraryMangas$updateLibraryManga
    on Mutation$UpdateLibraryMangas$updateLibraryManga {
  CopyWith$Mutation$UpdateLibraryMangas$updateLibraryManga<
          Mutation$UpdateLibraryMangas$updateLibraryManga>
      get copyWith => CopyWith$Mutation$UpdateLibraryMangas$updateLibraryManga(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdateLibraryMangas$updateLibraryManga<TRes> {
  factory CopyWith$Mutation$UpdateLibraryMangas$updateLibraryManga(
    Mutation$UpdateLibraryMangas$updateLibraryManga instance,
    TRes Function(Mutation$UpdateLibraryMangas$updateLibraryManga) then,
  ) = _CopyWithImpl$Mutation$UpdateLibraryMangas$updateLibraryManga;

  factory CopyWith$Mutation$UpdateLibraryMangas$updateLibraryManga.stub(
          TRes res) =
      _CopyWithStubImpl$Mutation$UpdateLibraryMangas$updateLibraryManga;

  TRes call({
    Fragment$UpdateStatusBaseDto? updateStatus,
    String? $__typename,
  });
  CopyWith$Fragment$UpdateStatusBaseDto<TRes> get updateStatus;
}

class _CopyWithImpl$Mutation$UpdateLibraryMangas$updateLibraryManga<TRes>
    implements CopyWith$Mutation$UpdateLibraryMangas$updateLibraryManga<TRes> {
  _CopyWithImpl$Mutation$UpdateLibraryMangas$updateLibraryManga(
    this._instance,
    this._then,
  );

  final Mutation$UpdateLibraryMangas$updateLibraryManga _instance;

  final TRes Function(Mutation$UpdateLibraryMangas$updateLibraryManga) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? updateStatus = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateLibraryMangas$updateLibraryManga(
        updateStatus: updateStatus == _undefined || updateStatus == null
            ? _instance.updateStatus
            : (updateStatus as Fragment$UpdateStatusBaseDto),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Fragment$UpdateStatusBaseDto<TRes> get updateStatus {
    final local$updateStatus = _instance.updateStatus;
    return CopyWith$Fragment$UpdateStatusBaseDto(
        local$updateStatus, (e) => call(updateStatus: e));
  }
}

class _CopyWithStubImpl$Mutation$UpdateLibraryMangas$updateLibraryManga<TRes>
    implements CopyWith$Mutation$UpdateLibraryMangas$updateLibraryManga<TRes> {
  _CopyWithStubImpl$Mutation$UpdateLibraryMangas$updateLibraryManga(this._res);

  TRes _res;

  call({
    Fragment$UpdateStatusBaseDto? updateStatus,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$UpdateStatusBaseDto<TRes> get updateStatus =>
      CopyWith$Fragment$UpdateStatusBaseDto.stub(_res);
}

class Variables$Mutation$UpdateCategoryMangas {
  factory Variables$Mutation$UpdateCategoryMangas(
          {required Input$UpdateCategoryMangaInput input}) =>
      Variables$Mutation$UpdateCategoryMangas._({
        r'input': input,
      });

  Variables$Mutation$UpdateCategoryMangas._(this._$data);

  factory Variables$Mutation$UpdateCategoryMangas.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$input = data['input'];
    result$data['input'] = Input$UpdateCategoryMangaInput.fromJson(
        (l$input as Map<String, dynamic>));
    return Variables$Mutation$UpdateCategoryMangas._(result$data);
  }

  Map<String, dynamic> _$data;

  Input$UpdateCategoryMangaInput get input =>
      (_$data['input'] as Input$UpdateCategoryMangaInput);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$input = input;
    result$data['input'] = l$input.toJson();
    return result$data;
  }

  CopyWith$Variables$Mutation$UpdateCategoryMangas<
          Variables$Mutation$UpdateCategoryMangas>
      get copyWith => CopyWith$Variables$Mutation$UpdateCategoryMangas(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$UpdateCategoryMangas ||
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

abstract class CopyWith$Variables$Mutation$UpdateCategoryMangas<TRes> {
  factory CopyWith$Variables$Mutation$UpdateCategoryMangas(
    Variables$Mutation$UpdateCategoryMangas instance,
    TRes Function(Variables$Mutation$UpdateCategoryMangas) then,
  ) = _CopyWithImpl$Variables$Mutation$UpdateCategoryMangas;

  factory CopyWith$Variables$Mutation$UpdateCategoryMangas.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$UpdateCategoryMangas;

  TRes call({Input$UpdateCategoryMangaInput? input});
}

class _CopyWithImpl$Variables$Mutation$UpdateCategoryMangas<TRes>
    implements CopyWith$Variables$Mutation$UpdateCategoryMangas<TRes> {
  _CopyWithImpl$Variables$Mutation$UpdateCategoryMangas(
    this._instance,
    this._then,
  );

  final Variables$Mutation$UpdateCategoryMangas _instance;

  final TRes Function(Variables$Mutation$UpdateCategoryMangas) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? input = _undefined}) =>
      _then(Variables$Mutation$UpdateCategoryMangas._({
        ..._instance._$data,
        if (input != _undefined && input != null)
          'input': (input as Input$UpdateCategoryMangaInput),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$UpdateCategoryMangas<TRes>
    implements CopyWith$Variables$Mutation$UpdateCategoryMangas<TRes> {
  _CopyWithStubImpl$Variables$Mutation$UpdateCategoryMangas(this._res);

  TRes _res;

  call({Input$UpdateCategoryMangaInput? input}) => _res;
}

class Mutation$UpdateCategoryMangas {
  Mutation$UpdateCategoryMangas({
    this.updateCategoryManga,
    this.$__typename = 'Mutation',
  });

  factory Mutation$UpdateCategoryMangas.fromJson(Map<String, dynamic> json) {
    final l$updateCategoryManga = json['updateCategoryManga'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateCategoryMangas(
      updateCategoryManga: l$updateCategoryManga == null
          ? null
          : Mutation$UpdateCategoryMangas$updateCategoryManga.fromJson(
              (l$updateCategoryManga as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$UpdateCategoryMangas$updateCategoryManga? updateCategoryManga;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$updateCategoryManga = updateCategoryManga;
    _resultData['updateCategoryManga'] = l$updateCategoryManga?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$updateCategoryManga = updateCategoryManga;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$updateCategoryManga,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$UpdateCategoryMangas ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$updateCategoryManga = updateCategoryManga;
    final lOther$updateCategoryManga = other.updateCategoryManga;
    if (l$updateCategoryManga != lOther$updateCategoryManga) {
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

extension UtilityExtension$Mutation$UpdateCategoryMangas
    on Mutation$UpdateCategoryMangas {
  CopyWith$Mutation$UpdateCategoryMangas<Mutation$UpdateCategoryMangas>
      get copyWith => CopyWith$Mutation$UpdateCategoryMangas(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdateCategoryMangas<TRes> {
  factory CopyWith$Mutation$UpdateCategoryMangas(
    Mutation$UpdateCategoryMangas instance,
    TRes Function(Mutation$UpdateCategoryMangas) then,
  ) = _CopyWithImpl$Mutation$UpdateCategoryMangas;

  factory CopyWith$Mutation$UpdateCategoryMangas.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateCategoryMangas;

  TRes call({
    Mutation$UpdateCategoryMangas$updateCategoryManga? updateCategoryManga,
    String? $__typename,
  });
  CopyWith$Mutation$UpdateCategoryMangas$updateCategoryManga<TRes>
      get updateCategoryManga;
}

class _CopyWithImpl$Mutation$UpdateCategoryMangas<TRes>
    implements CopyWith$Mutation$UpdateCategoryMangas<TRes> {
  _CopyWithImpl$Mutation$UpdateCategoryMangas(
    this._instance,
    this._then,
  );

  final Mutation$UpdateCategoryMangas _instance;

  final TRes Function(Mutation$UpdateCategoryMangas) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? updateCategoryManga = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateCategoryMangas(
        updateCategoryManga: updateCategoryManga == _undefined
            ? _instance.updateCategoryManga
            : (updateCategoryManga
                as Mutation$UpdateCategoryMangas$updateCategoryManga?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$UpdateCategoryMangas$updateCategoryManga<TRes>
      get updateCategoryManga {
    final local$updateCategoryManga = _instance.updateCategoryManga;
    return local$updateCategoryManga == null
        ? CopyWith$Mutation$UpdateCategoryMangas$updateCategoryManga.stub(
            _then(_instance))
        : CopyWith$Mutation$UpdateCategoryMangas$updateCategoryManga(
            local$updateCategoryManga, (e) => call(updateCategoryManga: e));
  }
}

class _CopyWithStubImpl$Mutation$UpdateCategoryMangas<TRes>
    implements CopyWith$Mutation$UpdateCategoryMangas<TRes> {
  _CopyWithStubImpl$Mutation$UpdateCategoryMangas(this._res);

  TRes _res;

  call({
    Mutation$UpdateCategoryMangas$updateCategoryManga? updateCategoryManga,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$UpdateCategoryMangas$updateCategoryManga<TRes>
      get updateCategoryManga =>
          CopyWith$Mutation$UpdateCategoryMangas$updateCategoryManga.stub(_res);
}

const documentNodeMutationUpdateCategoryMangas = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'UpdateCategoryMangas'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'input')),
        type: NamedTypeNode(
          name: NameNode(value: 'UpdateCategoryMangaInput'),
          isNonNull: true,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      )
    ],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'updateCategoryManga'),
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
            name: NameNode(value: 'updateStatus'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: SelectionSetNode(selections: [
              FragmentSpreadNode(
                name: NameNode(value: 'UpdateStatusBaseDto'),
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
  fragmentDefinitionUpdateStatusBaseDto,
]);
Mutation$UpdateCategoryMangas _parserFn$Mutation$UpdateCategoryMangas(
        Map<String, dynamic> data) =>
    Mutation$UpdateCategoryMangas.fromJson(data);
typedef OnMutationCompleted$Mutation$UpdateCategoryMangas = FutureOr<void>
    Function(
  Map<String, dynamic>?,
  Mutation$UpdateCategoryMangas?,
);

class Options$Mutation$UpdateCategoryMangas
    extends graphql.MutationOptions<Mutation$UpdateCategoryMangas> {
  Options$Mutation$UpdateCategoryMangas({
    String? operationName,
    required Variables$Mutation$UpdateCategoryMangas variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateCategoryMangas? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateCategoryMangas? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateCategoryMangas>? update,
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
                        : _parserFn$Mutation$UpdateCategoryMangas(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateCategoryMangas,
          parserFn: _parserFn$Mutation$UpdateCategoryMangas,
        );

  final OnMutationCompleted$Mutation$UpdateCategoryMangas?
      onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$UpdateCategoryMangas
    extends graphql.WatchQueryOptions<Mutation$UpdateCategoryMangas> {
  WatchOptions$Mutation$UpdateCategoryMangas({
    String? operationName,
    required Variables$Mutation$UpdateCategoryMangas variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateCategoryMangas? typedOptimisticResult,
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
          document: documentNodeMutationUpdateCategoryMangas,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$UpdateCategoryMangas,
        );
}

extension ClientExtension$Mutation$UpdateCategoryMangas
    on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$UpdateCategoryMangas>>
      mutate$UpdateCategoryMangas(
              Options$Mutation$UpdateCategoryMangas options) async =>
          await this.mutate(options);

  graphql.ObservableQuery<Mutation$UpdateCategoryMangas>
      watchMutation$UpdateCategoryMangas(
              WatchOptions$Mutation$UpdateCategoryMangas options) =>
          this.watchMutation(options);
}

class Mutation$UpdateCategoryMangas$HookResult {
  Mutation$UpdateCategoryMangas$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$UpdateCategoryMangas runMutation;

  final graphql.QueryResult<Mutation$UpdateCategoryMangas> result;
}

Mutation$UpdateCategoryMangas$HookResult useMutation$UpdateCategoryMangas(
    [WidgetOptions$Mutation$UpdateCategoryMangas? options]) {
  final result = graphql_flutter
      .useMutation(options ?? WidgetOptions$Mutation$UpdateCategoryMangas());
  return Mutation$UpdateCategoryMangas$HookResult(
    (variables, {optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables.toJson(),
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$UpdateCategoryMangas>
    useWatchMutation$UpdateCategoryMangas(
            WatchOptions$Mutation$UpdateCategoryMangas options) =>
        graphql_flutter.useWatchMutation(options);

class WidgetOptions$Mutation$UpdateCategoryMangas
    extends graphql.MutationOptions<Mutation$UpdateCategoryMangas> {
  WidgetOptions$Mutation$UpdateCategoryMangas({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateCategoryMangas? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateCategoryMangas? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateCategoryMangas>? update,
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
                        : _parserFn$Mutation$UpdateCategoryMangas(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateCategoryMangas,
          parserFn: _parserFn$Mutation$UpdateCategoryMangas,
        );

  final OnMutationCompleted$Mutation$UpdateCategoryMangas?
      onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$UpdateCategoryMangas
    = graphql.MultiSourceResult<Mutation$UpdateCategoryMangas> Function(
  Variables$Mutation$UpdateCategoryMangas, {
  Object? optimisticResult,
  Mutation$UpdateCategoryMangas? typedOptimisticResult,
});
typedef Builder$Mutation$UpdateCategoryMangas = widgets.Widget Function(
  RunMutation$Mutation$UpdateCategoryMangas,
  graphql.QueryResult<Mutation$UpdateCategoryMangas>?,
);

class Mutation$UpdateCategoryMangas$Widget
    extends graphql_flutter.Mutation<Mutation$UpdateCategoryMangas> {
  Mutation$UpdateCategoryMangas$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$UpdateCategoryMangas? options,
    required Builder$Mutation$UpdateCategoryMangas builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$UpdateCategoryMangas(),
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

class Mutation$UpdateCategoryMangas$updateCategoryManga {
  Mutation$UpdateCategoryMangas$updateCategoryManga({
    required this.updateStatus,
    this.$__typename = 'UpdateCategoryMangaPayload',
  });

  factory Mutation$UpdateCategoryMangas$updateCategoryManga.fromJson(
      Map<String, dynamic> json) {
    final l$updateStatus = json['updateStatus'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateCategoryMangas$updateCategoryManga(
      updateStatus: Fragment$UpdateStatusBaseDto.fromJson(
          (l$updateStatus as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Fragment$UpdateStatusBaseDto updateStatus;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$updateStatus = updateStatus;
    _resultData['updateStatus'] = l$updateStatus.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$updateStatus = updateStatus;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$updateStatus,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$UpdateCategoryMangas$updateCategoryManga ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$updateStatus = updateStatus;
    final lOther$updateStatus = other.updateStatus;
    if (l$updateStatus != lOther$updateStatus) {
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

extension UtilityExtension$Mutation$UpdateCategoryMangas$updateCategoryManga
    on Mutation$UpdateCategoryMangas$updateCategoryManga {
  CopyWith$Mutation$UpdateCategoryMangas$updateCategoryManga<
          Mutation$UpdateCategoryMangas$updateCategoryManga>
      get copyWith =>
          CopyWith$Mutation$UpdateCategoryMangas$updateCategoryManga(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdateCategoryMangas$updateCategoryManga<
    TRes> {
  factory CopyWith$Mutation$UpdateCategoryMangas$updateCategoryManga(
    Mutation$UpdateCategoryMangas$updateCategoryManga instance,
    TRes Function(Mutation$UpdateCategoryMangas$updateCategoryManga) then,
  ) = _CopyWithImpl$Mutation$UpdateCategoryMangas$updateCategoryManga;

  factory CopyWith$Mutation$UpdateCategoryMangas$updateCategoryManga.stub(
          TRes res) =
      _CopyWithStubImpl$Mutation$UpdateCategoryMangas$updateCategoryManga;

  TRes call({
    Fragment$UpdateStatusBaseDto? updateStatus,
    String? $__typename,
  });
  CopyWith$Fragment$UpdateStatusBaseDto<TRes> get updateStatus;
}

class _CopyWithImpl$Mutation$UpdateCategoryMangas$updateCategoryManga<TRes>
    implements
        CopyWith$Mutation$UpdateCategoryMangas$updateCategoryManga<TRes> {
  _CopyWithImpl$Mutation$UpdateCategoryMangas$updateCategoryManga(
    this._instance,
    this._then,
  );

  final Mutation$UpdateCategoryMangas$updateCategoryManga _instance;

  final TRes Function(Mutation$UpdateCategoryMangas$updateCategoryManga) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? updateStatus = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateCategoryMangas$updateCategoryManga(
        updateStatus: updateStatus == _undefined || updateStatus == null
            ? _instance.updateStatus
            : (updateStatus as Fragment$UpdateStatusBaseDto),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Fragment$UpdateStatusBaseDto<TRes> get updateStatus {
    final local$updateStatus = _instance.updateStatus;
    return CopyWith$Fragment$UpdateStatusBaseDto(
        local$updateStatus, (e) => call(updateStatus: e));
  }
}

class _CopyWithStubImpl$Mutation$UpdateCategoryMangas$updateCategoryManga<TRes>
    implements
        CopyWith$Mutation$UpdateCategoryMangas$updateCategoryManga<TRes> {
  _CopyWithStubImpl$Mutation$UpdateCategoryMangas$updateCategoryManga(
      this._res);

  TRes _res;

  call({
    Fragment$UpdateStatusBaseDto? updateStatus,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$UpdateStatusBaseDto<TRes> get updateStatus =>
      CopyWith$Fragment$UpdateStatusBaseDto.stub(_res);
}

class Variables$Mutation$StopCategoryUpdate {
  factory Variables$Mutation$StopCategoryUpdate(
          {required Input$UpdateStopInput input}) =>
      Variables$Mutation$StopCategoryUpdate._({
        r'input': input,
      });

  Variables$Mutation$StopCategoryUpdate._(this._$data);

  factory Variables$Mutation$StopCategoryUpdate.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$input = data['input'];
    result$data['input'] =
        Input$UpdateStopInput.fromJson((l$input as Map<String, dynamic>));
    return Variables$Mutation$StopCategoryUpdate._(result$data);
  }

  Map<String, dynamic> _$data;

  Input$UpdateStopInput get input => (_$data['input'] as Input$UpdateStopInput);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$input = input;
    result$data['input'] = l$input.toJson();
    return result$data;
  }

  CopyWith$Variables$Mutation$StopCategoryUpdate<
          Variables$Mutation$StopCategoryUpdate>
      get copyWith => CopyWith$Variables$Mutation$StopCategoryUpdate(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$StopCategoryUpdate ||
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

abstract class CopyWith$Variables$Mutation$StopCategoryUpdate<TRes> {
  factory CopyWith$Variables$Mutation$StopCategoryUpdate(
    Variables$Mutation$StopCategoryUpdate instance,
    TRes Function(Variables$Mutation$StopCategoryUpdate) then,
  ) = _CopyWithImpl$Variables$Mutation$StopCategoryUpdate;

  factory CopyWith$Variables$Mutation$StopCategoryUpdate.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$StopCategoryUpdate;

  TRes call({Input$UpdateStopInput? input});
}

class _CopyWithImpl$Variables$Mutation$StopCategoryUpdate<TRes>
    implements CopyWith$Variables$Mutation$StopCategoryUpdate<TRes> {
  _CopyWithImpl$Variables$Mutation$StopCategoryUpdate(
    this._instance,
    this._then,
  );

  final Variables$Mutation$StopCategoryUpdate _instance;

  final TRes Function(Variables$Mutation$StopCategoryUpdate) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? input = _undefined}) =>
      _then(Variables$Mutation$StopCategoryUpdate._({
        ..._instance._$data,
        if (input != _undefined && input != null)
          'input': (input as Input$UpdateStopInput),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$StopCategoryUpdate<TRes>
    implements CopyWith$Variables$Mutation$StopCategoryUpdate<TRes> {
  _CopyWithStubImpl$Variables$Mutation$StopCategoryUpdate(this._res);

  TRes _res;

  call({Input$UpdateStopInput? input}) => _res;
}

class Mutation$StopCategoryUpdate {
  Mutation$StopCategoryUpdate({
    required this.updateStop,
    this.$__typename = 'Mutation',
  });

  factory Mutation$StopCategoryUpdate.fromJson(Map<String, dynamic> json) {
    final l$updateStop = json['updateStop'];
    final l$$__typename = json['__typename'];
    return Mutation$StopCategoryUpdate(
      updateStop: Mutation$StopCategoryUpdate$updateStop.fromJson(
          (l$updateStop as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$StopCategoryUpdate$updateStop updateStop;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$updateStop = updateStop;
    _resultData['updateStop'] = l$updateStop.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$updateStop = updateStop;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$updateStop,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$StopCategoryUpdate ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$updateStop = updateStop;
    final lOther$updateStop = other.updateStop;
    if (l$updateStop != lOther$updateStop) {
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

extension UtilityExtension$Mutation$StopCategoryUpdate
    on Mutation$StopCategoryUpdate {
  CopyWith$Mutation$StopCategoryUpdate<Mutation$StopCategoryUpdate>
      get copyWith => CopyWith$Mutation$StopCategoryUpdate(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$StopCategoryUpdate<TRes> {
  factory CopyWith$Mutation$StopCategoryUpdate(
    Mutation$StopCategoryUpdate instance,
    TRes Function(Mutation$StopCategoryUpdate) then,
  ) = _CopyWithImpl$Mutation$StopCategoryUpdate;

  factory CopyWith$Mutation$StopCategoryUpdate.stub(TRes res) =
      _CopyWithStubImpl$Mutation$StopCategoryUpdate;

  TRes call({
    Mutation$StopCategoryUpdate$updateStop? updateStop,
    String? $__typename,
  });
  CopyWith$Mutation$StopCategoryUpdate$updateStop<TRes> get updateStop;
}

class _CopyWithImpl$Mutation$StopCategoryUpdate<TRes>
    implements CopyWith$Mutation$StopCategoryUpdate<TRes> {
  _CopyWithImpl$Mutation$StopCategoryUpdate(
    this._instance,
    this._then,
  );

  final Mutation$StopCategoryUpdate _instance;

  final TRes Function(Mutation$StopCategoryUpdate) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? updateStop = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$StopCategoryUpdate(
        updateStop: updateStop == _undefined || updateStop == null
            ? _instance.updateStop
            : (updateStop as Mutation$StopCategoryUpdate$updateStop),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$StopCategoryUpdate$updateStop<TRes> get updateStop {
    final local$updateStop = _instance.updateStop;
    return CopyWith$Mutation$StopCategoryUpdate$updateStop(
        local$updateStop, (e) => call(updateStop: e));
  }
}

class _CopyWithStubImpl$Mutation$StopCategoryUpdate<TRes>
    implements CopyWith$Mutation$StopCategoryUpdate<TRes> {
  _CopyWithStubImpl$Mutation$StopCategoryUpdate(this._res);

  TRes _res;

  call({
    Mutation$StopCategoryUpdate$updateStop? updateStop,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$StopCategoryUpdate$updateStop<TRes> get updateStop =>
      CopyWith$Mutation$StopCategoryUpdate$updateStop.stub(_res);
}

const documentNodeMutationStopCategoryUpdate = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'StopCategoryUpdate'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'input')),
        type: NamedTypeNode(
          name: NameNode(value: 'UpdateStopInput'),
          isNonNull: true,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      )
    ],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'updateStop'),
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
Mutation$StopCategoryUpdate _parserFn$Mutation$StopCategoryUpdate(
        Map<String, dynamic> data) =>
    Mutation$StopCategoryUpdate.fromJson(data);
typedef OnMutationCompleted$Mutation$StopCategoryUpdate = FutureOr<void>
    Function(
  Map<String, dynamic>?,
  Mutation$StopCategoryUpdate?,
);

class Options$Mutation$StopCategoryUpdate
    extends graphql.MutationOptions<Mutation$StopCategoryUpdate> {
  Options$Mutation$StopCategoryUpdate({
    String? operationName,
    required Variables$Mutation$StopCategoryUpdate variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$StopCategoryUpdate? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$StopCategoryUpdate? onCompleted,
    graphql.OnMutationUpdate<Mutation$StopCategoryUpdate>? update,
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
                        : _parserFn$Mutation$StopCategoryUpdate(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationStopCategoryUpdate,
          parserFn: _parserFn$Mutation$StopCategoryUpdate,
        );

  final OnMutationCompleted$Mutation$StopCategoryUpdate? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$StopCategoryUpdate
    extends graphql.WatchQueryOptions<Mutation$StopCategoryUpdate> {
  WatchOptions$Mutation$StopCategoryUpdate({
    String? operationName,
    required Variables$Mutation$StopCategoryUpdate variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$StopCategoryUpdate? typedOptimisticResult,
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
          document: documentNodeMutationStopCategoryUpdate,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$StopCategoryUpdate,
        );
}

extension ClientExtension$Mutation$StopCategoryUpdate on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$StopCategoryUpdate>>
      mutate$StopCategoryUpdate(
              Options$Mutation$StopCategoryUpdate options) async =>
          await this.mutate(options);

  graphql.ObservableQuery<Mutation$StopCategoryUpdate>
      watchMutation$StopCategoryUpdate(
              WatchOptions$Mutation$StopCategoryUpdate options) =>
          this.watchMutation(options);
}

class Mutation$StopCategoryUpdate$HookResult {
  Mutation$StopCategoryUpdate$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$StopCategoryUpdate runMutation;

  final graphql.QueryResult<Mutation$StopCategoryUpdate> result;
}

Mutation$StopCategoryUpdate$HookResult useMutation$StopCategoryUpdate(
    [WidgetOptions$Mutation$StopCategoryUpdate? options]) {
  final result = graphql_flutter
      .useMutation(options ?? WidgetOptions$Mutation$StopCategoryUpdate());
  return Mutation$StopCategoryUpdate$HookResult(
    (variables, {optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables.toJson(),
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$StopCategoryUpdate>
    useWatchMutation$StopCategoryUpdate(
            WatchOptions$Mutation$StopCategoryUpdate options) =>
        graphql_flutter.useWatchMutation(options);

class WidgetOptions$Mutation$StopCategoryUpdate
    extends graphql.MutationOptions<Mutation$StopCategoryUpdate> {
  WidgetOptions$Mutation$StopCategoryUpdate({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$StopCategoryUpdate? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$StopCategoryUpdate? onCompleted,
    graphql.OnMutationUpdate<Mutation$StopCategoryUpdate>? update,
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
                        : _parserFn$Mutation$StopCategoryUpdate(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationStopCategoryUpdate,
          parserFn: _parserFn$Mutation$StopCategoryUpdate,
        );

  final OnMutationCompleted$Mutation$StopCategoryUpdate? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$StopCategoryUpdate
    = graphql.MultiSourceResult<Mutation$StopCategoryUpdate> Function(
  Variables$Mutation$StopCategoryUpdate, {
  Object? optimisticResult,
  Mutation$StopCategoryUpdate? typedOptimisticResult,
});
typedef Builder$Mutation$StopCategoryUpdate = widgets.Widget Function(
  RunMutation$Mutation$StopCategoryUpdate,
  graphql.QueryResult<Mutation$StopCategoryUpdate>?,
);

class Mutation$StopCategoryUpdate$Widget
    extends graphql_flutter.Mutation<Mutation$StopCategoryUpdate> {
  Mutation$StopCategoryUpdate$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$StopCategoryUpdate? options,
    required Builder$Mutation$StopCategoryUpdate builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$StopCategoryUpdate(),
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

class Mutation$StopCategoryUpdate$updateStop {
  Mutation$StopCategoryUpdate$updateStop(
      {this.$__typename = 'UpdateStopPayload'});

  factory Mutation$StopCategoryUpdate$updateStop.fromJson(
      Map<String, dynamic> json) {
    final l$$__typename = json['__typename'];
    return Mutation$StopCategoryUpdate$updateStop(
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
    if (other is! Mutation$StopCategoryUpdate$updateStop ||
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

extension UtilityExtension$Mutation$StopCategoryUpdate$updateStop
    on Mutation$StopCategoryUpdate$updateStop {
  CopyWith$Mutation$StopCategoryUpdate$updateStop<
          Mutation$StopCategoryUpdate$updateStop>
      get copyWith => CopyWith$Mutation$StopCategoryUpdate$updateStop(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$StopCategoryUpdate$updateStop<TRes> {
  factory CopyWith$Mutation$StopCategoryUpdate$updateStop(
    Mutation$StopCategoryUpdate$updateStop instance,
    TRes Function(Mutation$StopCategoryUpdate$updateStop) then,
  ) = _CopyWithImpl$Mutation$StopCategoryUpdate$updateStop;

  factory CopyWith$Mutation$StopCategoryUpdate$updateStop.stub(TRes res) =
      _CopyWithStubImpl$Mutation$StopCategoryUpdate$updateStop;

  TRes call({String? $__typename});
}

class _CopyWithImpl$Mutation$StopCategoryUpdate$updateStop<TRes>
    implements CopyWith$Mutation$StopCategoryUpdate$updateStop<TRes> {
  _CopyWithImpl$Mutation$StopCategoryUpdate$updateStop(
    this._instance,
    this._then,
  );

  final Mutation$StopCategoryUpdate$updateStop _instance;

  final TRes Function(Mutation$StopCategoryUpdate$updateStop) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? $__typename = _undefined}) =>
      _then(Mutation$StopCategoryUpdate$updateStop(
          $__typename: $__typename == _undefined || $__typename == null
              ? _instance.$__typename
              : ($__typename as String)));
}

class _CopyWithStubImpl$Mutation$StopCategoryUpdate$updateStop<TRes>
    implements CopyWith$Mutation$StopCategoryUpdate$updateStop<TRes> {
  _CopyWithStubImpl$Mutation$StopCategoryUpdate$updateStop(this._res);

  TRes _res;

  call({String? $__typename}) => _res;
}

class Query$UpdateStatusDto {
  Query$UpdateStatusDto({
    required this.updateStatus,
    this.$__typename = 'Query',
  });

  factory Query$UpdateStatusDto.fromJson(Map<String, dynamic> json) {
    final l$updateStatus = json['updateStatus'];
    final l$$__typename = json['__typename'];
    return Query$UpdateStatusDto(
      updateStatus: Fragment$UpdateStatusDto.fromJson(
          (l$updateStatus as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Fragment$UpdateStatusDto updateStatus;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$updateStatus = updateStatus;
    _resultData['updateStatus'] = l$updateStatus.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$updateStatus = updateStatus;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$updateStatus,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$UpdateStatusDto || runtimeType != other.runtimeType) {
      return false;
    }
    final l$updateStatus = updateStatus;
    final lOther$updateStatus = other.updateStatus;
    if (l$updateStatus != lOther$updateStatus) {
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

extension UtilityExtension$Query$UpdateStatusDto on Query$UpdateStatusDto {
  CopyWith$Query$UpdateStatusDto<Query$UpdateStatusDto> get copyWith =>
      CopyWith$Query$UpdateStatusDto(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Query$UpdateStatusDto<TRes> {
  factory CopyWith$Query$UpdateStatusDto(
    Query$UpdateStatusDto instance,
    TRes Function(Query$UpdateStatusDto) then,
  ) = _CopyWithImpl$Query$UpdateStatusDto;

  factory CopyWith$Query$UpdateStatusDto.stub(TRes res) =
      _CopyWithStubImpl$Query$UpdateStatusDto;

  TRes call({
    Fragment$UpdateStatusDto? updateStatus,
    String? $__typename,
  });
  CopyWith$Fragment$UpdateStatusDto<TRes> get updateStatus;
}

class _CopyWithImpl$Query$UpdateStatusDto<TRes>
    implements CopyWith$Query$UpdateStatusDto<TRes> {
  _CopyWithImpl$Query$UpdateStatusDto(
    this._instance,
    this._then,
  );

  final Query$UpdateStatusDto _instance;

  final TRes Function(Query$UpdateStatusDto) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? updateStatus = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$UpdateStatusDto(
        updateStatus: updateStatus == _undefined || updateStatus == null
            ? _instance.updateStatus
            : (updateStatus as Fragment$UpdateStatusDto),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Fragment$UpdateStatusDto<TRes> get updateStatus {
    final local$updateStatus = _instance.updateStatus;
    return CopyWith$Fragment$UpdateStatusDto(
        local$updateStatus, (e) => call(updateStatus: e));
  }
}

class _CopyWithStubImpl$Query$UpdateStatusDto<TRes>
    implements CopyWith$Query$UpdateStatusDto<TRes> {
  _CopyWithStubImpl$Query$UpdateStatusDto(this._res);

  TRes _res;

  call({
    Fragment$UpdateStatusDto? updateStatus,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$UpdateStatusDto<TRes> get updateStatus =>
      CopyWith$Fragment$UpdateStatusDto.stub(_res);
}

const documentNodeQueryUpdateStatusDto = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.query,
    name: NameNode(value: 'UpdateStatusDto'),
    variableDefinitions: [],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'updateStatus'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: SelectionSetNode(selections: [
          FragmentSpreadNode(
            name: NameNode(value: 'UpdateStatusDto'),
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
  fragmentDefinitionUpdateStatusDto,
  fragmentDefinitionUpdateStatusBaseDto,
  fragmentDefinitionUpdateStatusJobDto,
  fragmentDefinitionMangaPageDto,
  fragmentDefinitionMangaDto,
  fragmentDefinitionChapterDto,
  fragmentDefinitionSourceDto,
  fragmentDefinitionPageInfoDto,
  fragmentDefinitionCategoryPageDto,
  fragmentDefinitionCategoryDto,
]);
Query$UpdateStatusDto _parserFn$Query$UpdateStatusDto(
        Map<String, dynamic> data) =>
    Query$UpdateStatusDto.fromJson(data);
typedef OnQueryComplete$Query$UpdateStatusDto = FutureOr<void> Function(
  Map<String, dynamic>?,
  Query$UpdateStatusDto?,
);

class Options$Query$UpdateStatusDto
    extends graphql.QueryOptions<Query$UpdateStatusDto> {
  Options$Query$UpdateStatusDto({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$UpdateStatusDto? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$UpdateStatusDto? onComplete,
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
                    data == null ? null : _parserFn$Query$UpdateStatusDto(data),
                  ),
          onError: onError,
          document: documentNodeQueryUpdateStatusDto,
          parserFn: _parserFn$Query$UpdateStatusDto,
        );

  final OnQueryComplete$Query$UpdateStatusDto? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onComplete == null
            ? super.properties
            : super.properties.where((property) => property != onComplete),
        onCompleteWithParsed,
      ];
}

class WatchOptions$Query$UpdateStatusDto
    extends graphql.WatchQueryOptions<Query$UpdateStatusDto> {
  WatchOptions$Query$UpdateStatusDto({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$UpdateStatusDto? typedOptimisticResult,
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
          document: documentNodeQueryUpdateStatusDto,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Query$UpdateStatusDto,
        );
}

class FetchMoreOptions$Query$UpdateStatusDto extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$UpdateStatusDto(
      {required graphql.UpdateQuery updateQuery})
      : super(
          updateQuery: updateQuery,
          document: documentNodeQueryUpdateStatusDto,
        );
}

extension ClientExtension$Query$UpdateStatusDto on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$UpdateStatusDto>> query$UpdateStatusDto(
          [Options$Query$UpdateStatusDto? options]) async =>
      await this.query(options ?? Options$Query$UpdateStatusDto());

  graphql.ObservableQuery<Query$UpdateStatusDto> watchQuery$UpdateStatusDto(
          [WatchOptions$Query$UpdateStatusDto? options]) =>
      this.watchQuery(options ?? WatchOptions$Query$UpdateStatusDto());

  void writeQuery$UpdateStatusDto({
    required Query$UpdateStatusDto data,
    bool broadcast = true,
  }) =>
      this.writeQuery(
        graphql.Request(
            operation:
                graphql.Operation(document: documentNodeQueryUpdateStatusDto)),
        data: data.toJson(),
        broadcast: broadcast,
      );

  Query$UpdateStatusDto? readQuery$UpdateStatusDto({bool optimistic = true}) {
    final result = this.readQuery(
      graphql.Request(
          operation:
              graphql.Operation(document: documentNodeQueryUpdateStatusDto)),
      optimistic: optimistic,
    );
    return result == null ? null : Query$UpdateStatusDto.fromJson(result);
  }
}

graphql_flutter.QueryHookResult<Query$UpdateStatusDto> useQuery$UpdateStatusDto(
        [Options$Query$UpdateStatusDto? options]) =>
    graphql_flutter.useQuery(options ?? Options$Query$UpdateStatusDto());
graphql.ObservableQuery<Query$UpdateStatusDto> useWatchQuery$UpdateStatusDto(
        [WatchOptions$Query$UpdateStatusDto? options]) =>
    graphql_flutter
        .useWatchQuery(options ?? WatchOptions$Query$UpdateStatusDto());

class Query$UpdateStatusDto$Widget
    extends graphql_flutter.Query<Query$UpdateStatusDto> {
  Query$UpdateStatusDto$Widget({
    widgets.Key? key,
    Options$Query$UpdateStatusDto? options,
    required graphql_flutter.QueryBuilder<Query$UpdateStatusDto> builder,
  }) : super(
          key: key,
          options: options ?? Options$Query$UpdateStatusDto(),
          builder: builder,
        );
}

class Subscription$UpdateStatusChange {
  Subscription$UpdateStatusChange({required this.updateStatusChanged});

  factory Subscription$UpdateStatusChange.fromJson(Map<String, dynamic> json) {
    final l$updateStatusChanged = json['updateStatusChanged'];
    return Subscription$UpdateStatusChange(
        updateStatusChanged: Fragment$UpdateStatusDto.fromJson(
            (l$updateStatusChanged as Map<String, dynamic>)));
  }

  final Fragment$UpdateStatusDto updateStatusChanged;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$updateStatusChanged = updateStatusChanged;
    _resultData['updateStatusChanged'] = l$updateStatusChanged.toJson();
    return _resultData;
  }

  @override
  int get hashCode {
    final l$updateStatusChanged = updateStatusChanged;
    return Object.hashAll([l$updateStatusChanged]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Subscription$UpdateStatusChange ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$updateStatusChanged = updateStatusChanged;
    final lOther$updateStatusChanged = other.updateStatusChanged;
    if (l$updateStatusChanged != lOther$updateStatusChanged) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Subscription$UpdateStatusChange
    on Subscription$UpdateStatusChange {
  CopyWith$Subscription$UpdateStatusChange<Subscription$UpdateStatusChange>
      get copyWith => CopyWith$Subscription$UpdateStatusChange(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Subscription$UpdateStatusChange<TRes> {
  factory CopyWith$Subscription$UpdateStatusChange(
    Subscription$UpdateStatusChange instance,
    TRes Function(Subscription$UpdateStatusChange) then,
  ) = _CopyWithImpl$Subscription$UpdateStatusChange;

  factory CopyWith$Subscription$UpdateStatusChange.stub(TRes res) =
      _CopyWithStubImpl$Subscription$UpdateStatusChange;

  TRes call({Fragment$UpdateStatusDto? updateStatusChanged});
  CopyWith$Fragment$UpdateStatusDto<TRes> get updateStatusChanged;
}

class _CopyWithImpl$Subscription$UpdateStatusChange<TRes>
    implements CopyWith$Subscription$UpdateStatusChange<TRes> {
  _CopyWithImpl$Subscription$UpdateStatusChange(
    this._instance,
    this._then,
  );

  final Subscription$UpdateStatusChange _instance;

  final TRes Function(Subscription$UpdateStatusChange) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? updateStatusChanged = _undefined}) =>
      _then(Subscription$UpdateStatusChange(
          updateStatusChanged:
              updateStatusChanged == _undefined || updateStatusChanged == null
                  ? _instance.updateStatusChanged
                  : (updateStatusChanged as Fragment$UpdateStatusDto)));

  CopyWith$Fragment$UpdateStatusDto<TRes> get updateStatusChanged {
    final local$updateStatusChanged = _instance.updateStatusChanged;
    return CopyWith$Fragment$UpdateStatusDto(
        local$updateStatusChanged, (e) => call(updateStatusChanged: e));
  }
}

class _CopyWithStubImpl$Subscription$UpdateStatusChange<TRes>
    implements CopyWith$Subscription$UpdateStatusChange<TRes> {
  _CopyWithStubImpl$Subscription$UpdateStatusChange(this._res);

  TRes _res;

  call({Fragment$UpdateStatusDto? updateStatusChanged}) => _res;

  CopyWith$Fragment$UpdateStatusDto<TRes> get updateStatusChanged =>
      CopyWith$Fragment$UpdateStatusDto.stub(_res);
}

const documentNodeSubscriptionUpdateStatusChange = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.subscription,
    name: NameNode(value: 'UpdateStatusChange'),
    variableDefinitions: [],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'updateStatusChanged'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: SelectionSetNode(selections: [
          FragmentSpreadNode(
            name: NameNode(value: 'UpdateStatusDto'),
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
      )
    ]),
  ),
  fragmentDefinitionUpdateStatusDto,
  fragmentDefinitionUpdateStatusBaseDto,
  fragmentDefinitionUpdateStatusJobDto,
  fragmentDefinitionMangaPageDto,
  fragmentDefinitionMangaDto,
  fragmentDefinitionChapterDto,
  fragmentDefinitionSourceDto,
  fragmentDefinitionPageInfoDto,
  fragmentDefinitionCategoryPageDto,
  fragmentDefinitionCategoryDto,
]);
Subscription$UpdateStatusChange _parserFn$Subscription$UpdateStatusChange(
        Map<String, dynamic> data) =>
    Subscription$UpdateStatusChange.fromJson(data);

class Options$Subscription$UpdateStatusChange
    extends graphql.SubscriptionOptions<Subscription$UpdateStatusChange> {
  Options$Subscription$UpdateStatusChange({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Subscription$UpdateStatusChange? typedOptimisticResult,
    graphql.Context? context,
  }) : super(
          operationName: operationName,
          fetchPolicy: fetchPolicy,
          errorPolicy: errorPolicy,
          cacheRereadPolicy: cacheRereadPolicy,
          optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
          context: context,
          document: documentNodeSubscriptionUpdateStatusChange,
          parserFn: _parserFn$Subscription$UpdateStatusChange,
        );
}

class WatchOptions$Subscription$UpdateStatusChange
    extends graphql.WatchQueryOptions<Subscription$UpdateStatusChange> {
  WatchOptions$Subscription$UpdateStatusChange({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Subscription$UpdateStatusChange? typedOptimisticResult,
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
          document: documentNodeSubscriptionUpdateStatusChange,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Subscription$UpdateStatusChange,
        );
}

class FetchMoreOptions$Subscription$UpdateStatusChange
    extends graphql.FetchMoreOptions {
  FetchMoreOptions$Subscription$UpdateStatusChange(
      {required graphql.UpdateQuery updateQuery})
      : super(
          updateQuery: updateQuery,
          document: documentNodeSubscriptionUpdateStatusChange,
        );
}

extension ClientExtension$Subscription$UpdateStatusChange
    on graphql.GraphQLClient {
  Stream<graphql.QueryResult<Subscription$UpdateStatusChange>>
      subscribe$UpdateStatusChange(
              [Options$Subscription$UpdateStatusChange? options]) =>
          this.subscribe(options ?? Options$Subscription$UpdateStatusChange());

  graphql.ObservableQuery<Subscription$UpdateStatusChange>
      watchSubscription$UpdateStatusChange(
              [WatchOptions$Subscription$UpdateStatusChange? options]) =>
          this.watchQuery(
              options ?? WatchOptions$Subscription$UpdateStatusChange());
}

graphql.QueryResult<Subscription$UpdateStatusChange>
    useSubscription$UpdateStatusChange(
            Options$Subscription$UpdateStatusChange options) =>
        graphql_flutter.useSubscription(options);

class Subscription$UpdateStatusChange$Widget
    extends graphql_flutter.Subscription<Subscription$UpdateStatusChange> {
  Subscription$UpdateStatusChange$Widget({
    widgets.Key? key,
    Options$Subscription$UpdateStatusChange? options,
    required graphql_flutter
        .SubscriptionBuilder<Subscription$UpdateStatusChange>
        builder,
    graphql_flutter.OnSubscriptionResult<Subscription$UpdateStatusChange>?
        onSubscriptionResult,
  }) : super(
          key: key,
          options: options ?? Options$Subscription$UpdateStatusChange(),
          builder: builder,
          onSubscriptionResult: onSubscriptionResult,
        );
}
