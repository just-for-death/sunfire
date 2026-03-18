import '../../../../../graphql/__generated__/fragments.graphql.dart';
import '../../../../../graphql/__generated__/schema.graphql.dart';
import '../../../../browse_center/domain/source/graphql/__generated__/fragment.graphql.dart';
import '../../../../library/domain/category/graphql/__generated__/fragment.graphql.dart';
import '../../../domain/chapter/graphql/__generated__/fragment.graphql.dart';
import '../../../domain/chapter_page/graphql/__generated__/fragment.graphql.dart';
import '../../../domain/manga/graphql/__generated__/fragment.graphql.dart';
import 'dart:async';
import 'package:flutter/widgets.dart' as widgets;
import 'package:gql/ast.dart';
import 'package:graphql/client.dart' as graphql;
import 'package:graphql_flutter/graphql_flutter.dart' as graphql_flutter;
import 'package:catalyst/src/utils/misc/scalars.dart';

class Variables$Query$GetManga {
  factory Variables$Query$GetManga({required int id}) =>
      Variables$Query$GetManga._({
        r'id': id,
      });

  Variables$Query$GetManga._(this._$data);

  factory Variables$Query$GetManga.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$id = data['id'];
    result$data['id'] = (l$id as int);
    return Variables$Query$GetManga._(result$data);
  }

  Map<String, dynamic> _$data;

  int get id => (_$data['id'] as int);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$id = id;
    result$data['id'] = l$id;
    return result$data;
  }

  CopyWith$Variables$Query$GetManga<Variables$Query$GetManga> get copyWith =>
      CopyWith$Variables$Query$GetManga(
        this,
        (i) => i,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Query$GetManga ||
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

abstract class CopyWith$Variables$Query$GetManga<TRes> {
  factory CopyWith$Variables$Query$GetManga(
    Variables$Query$GetManga instance,
    TRes Function(Variables$Query$GetManga) then,
  ) = _CopyWithImpl$Variables$Query$GetManga;

  factory CopyWith$Variables$Query$GetManga.stub(TRes res) =
      _CopyWithStubImpl$Variables$Query$GetManga;

  TRes call({int? id});
}

class _CopyWithImpl$Variables$Query$GetManga<TRes>
    implements CopyWith$Variables$Query$GetManga<TRes> {
  _CopyWithImpl$Variables$Query$GetManga(
    this._instance,
    this._then,
  );

  final Variables$Query$GetManga _instance;

  final TRes Function(Variables$Query$GetManga) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? id = _undefined}) => _then(Variables$Query$GetManga._({
        ..._instance._$data,
        if (id != _undefined && id != null) 'id': (id as int),
      }));
}

class _CopyWithStubImpl$Variables$Query$GetManga<TRes>
    implements CopyWith$Variables$Query$GetManga<TRes> {
  _CopyWithStubImpl$Variables$Query$GetManga(this._res);

  TRes _res;

  call({int? id}) => _res;
}

class Query$GetManga {
  Query$GetManga({
    required this.manga,
    this.$__typename = 'Query',
  });

  factory Query$GetManga.fromJson(Map<String, dynamic> json) {
    final l$manga = json['manga'];
    final l$$__typename = json['__typename'];
    return Query$GetManga(
      manga: Fragment$MangaDto.fromJson((l$manga as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Fragment$MangaDto manga;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$manga = manga;
    _resultData['manga'] = l$manga.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$manga = manga;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$manga,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetManga || runtimeType != other.runtimeType) {
      return false;
    }
    final l$manga = manga;
    final lOther$manga = other.manga;
    if (l$manga != lOther$manga) {
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

extension UtilityExtension$Query$GetManga on Query$GetManga {
  CopyWith$Query$GetManga<Query$GetManga> get copyWith =>
      CopyWith$Query$GetManga(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Query$GetManga<TRes> {
  factory CopyWith$Query$GetManga(
    Query$GetManga instance,
    TRes Function(Query$GetManga) then,
  ) = _CopyWithImpl$Query$GetManga;

  factory CopyWith$Query$GetManga.stub(TRes res) =
      _CopyWithStubImpl$Query$GetManga;

  TRes call({
    Fragment$MangaDto? manga,
    String? $__typename,
  });
  CopyWith$Fragment$MangaDto<TRes> get manga;
}

class _CopyWithImpl$Query$GetManga<TRes>
    implements CopyWith$Query$GetManga<TRes> {
  _CopyWithImpl$Query$GetManga(
    this._instance,
    this._then,
  );

  final Query$GetManga _instance;

  final TRes Function(Query$GetManga) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? manga = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetManga(
        manga: manga == _undefined || manga == null
            ? _instance.manga
            : (manga as Fragment$MangaDto),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Fragment$MangaDto<TRes> get manga {
    final local$manga = _instance.manga;
    return CopyWith$Fragment$MangaDto(local$manga, (e) => call(manga: e));
  }
}

class _CopyWithStubImpl$Query$GetManga<TRes>
    implements CopyWith$Query$GetManga<TRes> {
  _CopyWithStubImpl$Query$GetManga(this._res);

  TRes _res;

  call({
    Fragment$MangaDto? manga,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$MangaDto<TRes> get manga =>
      CopyWith$Fragment$MangaDto.stub(_res);
}

const documentNodeQueryGetManga = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.query,
    name: NameNode(value: 'GetManga'),
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
        name: NameNode(value: 'manga'),
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
]);
Query$GetManga _parserFn$Query$GetManga(Map<String, dynamic> data) =>
    Query$GetManga.fromJson(data);
typedef OnQueryComplete$Query$GetManga = FutureOr<void> Function(
  Map<String, dynamic>?,
  Query$GetManga?,
);

class Options$Query$GetManga extends graphql.QueryOptions<Query$GetManga> {
  Options$Query$GetManga({
    String? operationName,
    required Variables$Query$GetManga variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetManga? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$GetManga? onComplete,
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
                    data == null ? null : _parserFn$Query$GetManga(data),
                  ),
          onError: onError,
          document: documentNodeQueryGetManga,
          parserFn: _parserFn$Query$GetManga,
        );

  final OnQueryComplete$Query$GetManga? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onComplete == null
            ? super.properties
            : super.properties.where((property) => property != onComplete),
        onCompleteWithParsed,
      ];
}

class WatchOptions$Query$GetManga
    extends graphql.WatchQueryOptions<Query$GetManga> {
  WatchOptions$Query$GetManga({
    String? operationName,
    required Variables$Query$GetManga variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetManga? typedOptimisticResult,
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
          document: documentNodeQueryGetManga,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Query$GetManga,
        );
}

class FetchMoreOptions$Query$GetManga extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$GetManga({
    required graphql.UpdateQuery updateQuery,
    required Variables$Query$GetManga variables,
  }) : super(
          updateQuery: updateQuery,
          variables: variables.toJson(),
          document: documentNodeQueryGetManga,
        );
}

extension ClientExtension$Query$GetManga on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$GetManga>> query$GetManga(
          Options$Query$GetManga options) async =>
      await this.query(options);

  graphql.ObservableQuery<Query$GetManga> watchQuery$GetManga(
          WatchOptions$Query$GetManga options) =>
      this.watchQuery(options);

  void writeQuery$GetManga({
    required Query$GetManga data,
    required Variables$Query$GetManga variables,
    bool broadcast = true,
  }) =>
      this.writeQuery(
        graphql.Request(
          operation: graphql.Operation(document: documentNodeQueryGetManga),
          variables: variables.toJson(),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );

  Query$GetManga? readQuery$GetManga({
    required Variables$Query$GetManga variables,
    bool optimistic = true,
  }) {
    final result = this.readQuery(
      graphql.Request(
        operation: graphql.Operation(document: documentNodeQueryGetManga),
        variables: variables.toJson(),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Query$GetManga.fromJson(result);
  }
}

graphql_flutter.QueryHookResult<Query$GetManga> useQuery$GetManga(
        Options$Query$GetManga options) =>
    graphql_flutter.useQuery(options);
graphql.ObservableQuery<Query$GetManga> useWatchQuery$GetManga(
        WatchOptions$Query$GetManga options) =>
    graphql_flutter.useWatchQuery(options);

class Query$GetManga$Widget extends graphql_flutter.Query<Query$GetManga> {
  Query$GetManga$Widget({
    widgets.Key? key,
    required Options$Query$GetManga options,
    required graphql_flutter.QueryBuilder<Query$GetManga> builder,
  }) : super(
          key: key,
          options: options,
          builder: builder,
        );
}

class Variables$Mutation$UpdateManga {
  factory Variables$Mutation$UpdateManga(
          {required Input$UpdateMangaInput input}) =>
      Variables$Mutation$UpdateManga._({
        r'input': input,
      });

  Variables$Mutation$UpdateManga._(this._$data);

  factory Variables$Mutation$UpdateManga.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$input = data['input'];
    result$data['input'] =
        Input$UpdateMangaInput.fromJson((l$input as Map<String, dynamic>));
    return Variables$Mutation$UpdateManga._(result$data);
  }

  Map<String, dynamic> _$data;

  Input$UpdateMangaInput get input =>
      (_$data['input'] as Input$UpdateMangaInput);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$input = input;
    result$data['input'] = l$input.toJson();
    return result$data;
  }

  CopyWith$Variables$Mutation$UpdateManga<Variables$Mutation$UpdateManga>
      get copyWith => CopyWith$Variables$Mutation$UpdateManga(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$UpdateManga ||
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

abstract class CopyWith$Variables$Mutation$UpdateManga<TRes> {
  factory CopyWith$Variables$Mutation$UpdateManga(
    Variables$Mutation$UpdateManga instance,
    TRes Function(Variables$Mutation$UpdateManga) then,
  ) = _CopyWithImpl$Variables$Mutation$UpdateManga;

  factory CopyWith$Variables$Mutation$UpdateManga.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$UpdateManga;

  TRes call({Input$UpdateMangaInput? input});
}

class _CopyWithImpl$Variables$Mutation$UpdateManga<TRes>
    implements CopyWith$Variables$Mutation$UpdateManga<TRes> {
  _CopyWithImpl$Variables$Mutation$UpdateManga(
    this._instance,
    this._then,
  );

  final Variables$Mutation$UpdateManga _instance;

  final TRes Function(Variables$Mutation$UpdateManga) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? input = _undefined}) =>
      _then(Variables$Mutation$UpdateManga._({
        ..._instance._$data,
        if (input != _undefined && input != null)
          'input': (input as Input$UpdateMangaInput),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$UpdateManga<TRes>
    implements CopyWith$Variables$Mutation$UpdateManga<TRes> {
  _CopyWithStubImpl$Variables$Mutation$UpdateManga(this._res);

  TRes _res;

  call({Input$UpdateMangaInput? input}) => _res;
}

class Mutation$UpdateManga {
  Mutation$UpdateManga({
    this.updateManga,
    this.$__typename = 'Mutation',
  });

  factory Mutation$UpdateManga.fromJson(Map<String, dynamic> json) {
    final l$updateManga = json['updateManga'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateManga(
      updateManga: l$updateManga == null
          ? null
          : Mutation$UpdateManga$updateManga.fromJson(
              (l$updateManga as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$UpdateManga$updateManga? updateManga;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$updateManga = updateManga;
    _resultData['updateManga'] = l$updateManga?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$updateManga = updateManga;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$updateManga,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$UpdateManga || runtimeType != other.runtimeType) {
      return false;
    }
    final l$updateManga = updateManga;
    final lOther$updateManga = other.updateManga;
    if (l$updateManga != lOther$updateManga) {
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

extension UtilityExtension$Mutation$UpdateManga on Mutation$UpdateManga {
  CopyWith$Mutation$UpdateManga<Mutation$UpdateManga> get copyWith =>
      CopyWith$Mutation$UpdateManga(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Mutation$UpdateManga<TRes> {
  factory CopyWith$Mutation$UpdateManga(
    Mutation$UpdateManga instance,
    TRes Function(Mutation$UpdateManga) then,
  ) = _CopyWithImpl$Mutation$UpdateManga;

  factory CopyWith$Mutation$UpdateManga.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateManga;

  TRes call({
    Mutation$UpdateManga$updateManga? updateManga,
    String? $__typename,
  });
  CopyWith$Mutation$UpdateManga$updateManga<TRes> get updateManga;
}

class _CopyWithImpl$Mutation$UpdateManga<TRes>
    implements CopyWith$Mutation$UpdateManga<TRes> {
  _CopyWithImpl$Mutation$UpdateManga(
    this._instance,
    this._then,
  );

  final Mutation$UpdateManga _instance;

  final TRes Function(Mutation$UpdateManga) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? updateManga = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateManga(
        updateManga: updateManga == _undefined
            ? _instance.updateManga
            : (updateManga as Mutation$UpdateManga$updateManga?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$UpdateManga$updateManga<TRes> get updateManga {
    final local$updateManga = _instance.updateManga;
    return local$updateManga == null
        ? CopyWith$Mutation$UpdateManga$updateManga.stub(_then(_instance))
        : CopyWith$Mutation$UpdateManga$updateManga(
            local$updateManga, (e) => call(updateManga: e));
  }
}

class _CopyWithStubImpl$Mutation$UpdateManga<TRes>
    implements CopyWith$Mutation$UpdateManga<TRes> {
  _CopyWithStubImpl$Mutation$UpdateManga(this._res);

  TRes _res;

  call({
    Mutation$UpdateManga$updateManga? updateManga,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$UpdateManga$updateManga<TRes> get updateManga =>
      CopyWith$Mutation$UpdateManga$updateManga.stub(_res);
}

const documentNodeMutationUpdateManga = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'UpdateManga'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'input')),
        type: NamedTypeNode(
          name: NameNode(value: 'UpdateMangaInput'),
          isNonNull: true,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      )
    ],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'updateManga'),
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
            name: NameNode(value: 'manga'),
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
]);
Mutation$UpdateManga _parserFn$Mutation$UpdateManga(
        Map<String, dynamic> data) =>
    Mutation$UpdateManga.fromJson(data);
typedef OnMutationCompleted$Mutation$UpdateManga = FutureOr<void> Function(
  Map<String, dynamic>?,
  Mutation$UpdateManga?,
);

class Options$Mutation$UpdateManga
    extends graphql.MutationOptions<Mutation$UpdateManga> {
  Options$Mutation$UpdateManga({
    String? operationName,
    required Variables$Mutation$UpdateManga variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateManga? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateManga? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateManga>? update,
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
                    data == null ? null : _parserFn$Mutation$UpdateManga(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateManga,
          parserFn: _parserFn$Mutation$UpdateManga,
        );

  final OnMutationCompleted$Mutation$UpdateManga? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$UpdateManga
    extends graphql.WatchQueryOptions<Mutation$UpdateManga> {
  WatchOptions$Mutation$UpdateManga({
    String? operationName,
    required Variables$Mutation$UpdateManga variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateManga? typedOptimisticResult,
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
          document: documentNodeMutationUpdateManga,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$UpdateManga,
        );
}

extension ClientExtension$Mutation$UpdateManga on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$UpdateManga>> mutate$UpdateManga(
          Options$Mutation$UpdateManga options) async =>
      await this.mutate(options);

  graphql.ObservableQuery<Mutation$UpdateManga> watchMutation$UpdateManga(
          WatchOptions$Mutation$UpdateManga options) =>
      this.watchMutation(options);
}

class Mutation$UpdateManga$HookResult {
  Mutation$UpdateManga$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$UpdateManga runMutation;

  final graphql.QueryResult<Mutation$UpdateManga> result;
}

Mutation$UpdateManga$HookResult useMutation$UpdateManga(
    [WidgetOptions$Mutation$UpdateManga? options]) {
  final result = graphql_flutter
      .useMutation(options ?? WidgetOptions$Mutation$UpdateManga());
  return Mutation$UpdateManga$HookResult(
    (variables, {optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables.toJson(),
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$UpdateManga> useWatchMutation$UpdateManga(
        WatchOptions$Mutation$UpdateManga options) =>
    graphql_flutter.useWatchMutation(options);

class WidgetOptions$Mutation$UpdateManga
    extends graphql.MutationOptions<Mutation$UpdateManga> {
  WidgetOptions$Mutation$UpdateManga({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateManga? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateManga? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateManga>? update,
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
                    data == null ? null : _parserFn$Mutation$UpdateManga(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateManga,
          parserFn: _parserFn$Mutation$UpdateManga,
        );

  final OnMutationCompleted$Mutation$UpdateManga? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$UpdateManga
    = graphql.MultiSourceResult<Mutation$UpdateManga> Function(
  Variables$Mutation$UpdateManga, {
  Object? optimisticResult,
  Mutation$UpdateManga? typedOptimisticResult,
});
typedef Builder$Mutation$UpdateManga = widgets.Widget Function(
  RunMutation$Mutation$UpdateManga,
  graphql.QueryResult<Mutation$UpdateManga>?,
);

class Mutation$UpdateManga$Widget
    extends graphql_flutter.Mutation<Mutation$UpdateManga> {
  Mutation$UpdateManga$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$UpdateManga? options,
    required Builder$Mutation$UpdateManga builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$UpdateManga(),
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

class Mutation$UpdateManga$updateManga {
  Mutation$UpdateManga$updateManga({
    required this.manga,
    this.$__typename = 'UpdateMangaPayload',
  });

  factory Mutation$UpdateManga$updateManga.fromJson(Map<String, dynamic> json) {
    final l$manga = json['manga'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateManga$updateManga(
      manga: Fragment$MangaDto.fromJson((l$manga as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Fragment$MangaDto manga;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$manga = manga;
    _resultData['manga'] = l$manga.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$manga = manga;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$manga,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$UpdateManga$updateManga ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$manga = manga;
    final lOther$manga = other.manga;
    if (l$manga != lOther$manga) {
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

extension UtilityExtension$Mutation$UpdateManga$updateManga
    on Mutation$UpdateManga$updateManga {
  CopyWith$Mutation$UpdateManga$updateManga<Mutation$UpdateManga$updateManga>
      get copyWith => CopyWith$Mutation$UpdateManga$updateManga(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdateManga$updateManga<TRes> {
  factory CopyWith$Mutation$UpdateManga$updateManga(
    Mutation$UpdateManga$updateManga instance,
    TRes Function(Mutation$UpdateManga$updateManga) then,
  ) = _CopyWithImpl$Mutation$UpdateManga$updateManga;

  factory CopyWith$Mutation$UpdateManga$updateManga.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateManga$updateManga;

  TRes call({
    Fragment$MangaDto? manga,
    String? $__typename,
  });
  CopyWith$Fragment$MangaDto<TRes> get manga;
}

class _CopyWithImpl$Mutation$UpdateManga$updateManga<TRes>
    implements CopyWith$Mutation$UpdateManga$updateManga<TRes> {
  _CopyWithImpl$Mutation$UpdateManga$updateManga(
    this._instance,
    this._then,
  );

  final Mutation$UpdateManga$updateManga _instance;

  final TRes Function(Mutation$UpdateManga$updateManga) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? manga = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateManga$updateManga(
        manga: manga == _undefined || manga == null
            ? _instance.manga
            : (manga as Fragment$MangaDto),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Fragment$MangaDto<TRes> get manga {
    final local$manga = _instance.manga;
    return CopyWith$Fragment$MangaDto(local$manga, (e) => call(manga: e));
  }
}

class _CopyWithStubImpl$Mutation$UpdateManga$updateManga<TRes>
    implements CopyWith$Mutation$UpdateManga$updateManga<TRes> {
  _CopyWithStubImpl$Mutation$UpdateManga$updateManga(this._res);

  TRes _res;

  call({
    Fragment$MangaDto? manga,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$MangaDto<TRes> get manga =>
      CopyWith$Fragment$MangaDto.stub(_res);
}

class Variables$Mutation$UpdateMangaCategories {
  factory Variables$Mutation$UpdateMangaCategories(
          {required Input$UpdateMangaCategoriesInput updateCategoryInput}) =>
      Variables$Mutation$UpdateMangaCategories._({
        r'updateCategoryInput': updateCategoryInput,
      });

  Variables$Mutation$UpdateMangaCategories._(this._$data);

  factory Variables$Mutation$UpdateMangaCategories.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$updateCategoryInput = data['updateCategoryInput'];
    result$data['updateCategoryInput'] =
        Input$UpdateMangaCategoriesInput.fromJson(
            (l$updateCategoryInput as Map<String, dynamic>));
    return Variables$Mutation$UpdateMangaCategories._(result$data);
  }

  Map<String, dynamic> _$data;

  Input$UpdateMangaCategoriesInput get updateCategoryInput =>
      (_$data['updateCategoryInput'] as Input$UpdateMangaCategoriesInput);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$updateCategoryInput = updateCategoryInput;
    result$data['updateCategoryInput'] = l$updateCategoryInput.toJson();
    return result$data;
  }

  CopyWith$Variables$Mutation$UpdateMangaCategories<
          Variables$Mutation$UpdateMangaCategories>
      get copyWith => CopyWith$Variables$Mutation$UpdateMangaCategories(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$UpdateMangaCategories ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$updateCategoryInput = updateCategoryInput;
    final lOther$updateCategoryInput = other.updateCategoryInput;
    if (l$updateCategoryInput != lOther$updateCategoryInput) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$updateCategoryInput = updateCategoryInput;
    return Object.hashAll([l$updateCategoryInput]);
  }
}

abstract class CopyWith$Variables$Mutation$UpdateMangaCategories<TRes> {
  factory CopyWith$Variables$Mutation$UpdateMangaCategories(
    Variables$Mutation$UpdateMangaCategories instance,
    TRes Function(Variables$Mutation$UpdateMangaCategories) then,
  ) = _CopyWithImpl$Variables$Mutation$UpdateMangaCategories;

  factory CopyWith$Variables$Mutation$UpdateMangaCategories.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$UpdateMangaCategories;

  TRes call({Input$UpdateMangaCategoriesInput? updateCategoryInput});
}

class _CopyWithImpl$Variables$Mutation$UpdateMangaCategories<TRes>
    implements CopyWith$Variables$Mutation$UpdateMangaCategories<TRes> {
  _CopyWithImpl$Variables$Mutation$UpdateMangaCategories(
    this._instance,
    this._then,
  );

  final Variables$Mutation$UpdateMangaCategories _instance;

  final TRes Function(Variables$Mutation$UpdateMangaCategories) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? updateCategoryInput = _undefined}) =>
      _then(Variables$Mutation$UpdateMangaCategories._({
        ..._instance._$data,
        if (updateCategoryInput != _undefined && updateCategoryInput != null)
          'updateCategoryInput':
              (updateCategoryInput as Input$UpdateMangaCategoriesInput),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$UpdateMangaCategories<TRes>
    implements CopyWith$Variables$Mutation$UpdateMangaCategories<TRes> {
  _CopyWithStubImpl$Variables$Mutation$UpdateMangaCategories(this._res);

  TRes _res;

  call({Input$UpdateMangaCategoriesInput? updateCategoryInput}) => _res;
}

class Mutation$UpdateMangaCategories {
  Mutation$UpdateMangaCategories({
    this.updateMangaCategories,
    this.$__typename = 'Mutation',
  });

  factory Mutation$UpdateMangaCategories.fromJson(Map<String, dynamic> json) {
    final l$updateMangaCategories = json['updateMangaCategories'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateMangaCategories(
      updateMangaCategories: l$updateMangaCategories == null
          ? null
          : Mutation$UpdateMangaCategories$updateMangaCategories.fromJson(
              (l$updateMangaCategories as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$UpdateMangaCategories$updateMangaCategories?
      updateMangaCategories;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$updateMangaCategories = updateMangaCategories;
    _resultData['updateMangaCategories'] = l$updateMangaCategories?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$updateMangaCategories = updateMangaCategories;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$updateMangaCategories,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$UpdateMangaCategories ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$updateMangaCategories = updateMangaCategories;
    final lOther$updateMangaCategories = other.updateMangaCategories;
    if (l$updateMangaCategories != lOther$updateMangaCategories) {
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

extension UtilityExtension$Mutation$UpdateMangaCategories
    on Mutation$UpdateMangaCategories {
  CopyWith$Mutation$UpdateMangaCategories<Mutation$UpdateMangaCategories>
      get copyWith => CopyWith$Mutation$UpdateMangaCategories(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdateMangaCategories<TRes> {
  factory CopyWith$Mutation$UpdateMangaCategories(
    Mutation$UpdateMangaCategories instance,
    TRes Function(Mutation$UpdateMangaCategories) then,
  ) = _CopyWithImpl$Mutation$UpdateMangaCategories;

  factory CopyWith$Mutation$UpdateMangaCategories.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateMangaCategories;

  TRes call({
    Mutation$UpdateMangaCategories$updateMangaCategories? updateMangaCategories,
    String? $__typename,
  });
  CopyWith$Mutation$UpdateMangaCategories$updateMangaCategories<TRes>
      get updateMangaCategories;
}

class _CopyWithImpl$Mutation$UpdateMangaCategories<TRes>
    implements CopyWith$Mutation$UpdateMangaCategories<TRes> {
  _CopyWithImpl$Mutation$UpdateMangaCategories(
    this._instance,
    this._then,
  );

  final Mutation$UpdateMangaCategories _instance;

  final TRes Function(Mutation$UpdateMangaCategories) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? updateMangaCategories = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateMangaCategories(
        updateMangaCategories: updateMangaCategories == _undefined
            ? _instance.updateMangaCategories
            : (updateMangaCategories
                as Mutation$UpdateMangaCategories$updateMangaCategories?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$UpdateMangaCategories$updateMangaCategories<TRes>
      get updateMangaCategories {
    final local$updateMangaCategories = _instance.updateMangaCategories;
    return local$updateMangaCategories == null
        ? CopyWith$Mutation$UpdateMangaCategories$updateMangaCategories.stub(
            _then(_instance))
        : CopyWith$Mutation$UpdateMangaCategories$updateMangaCategories(
            local$updateMangaCategories, (e) => call(updateMangaCategories: e));
  }
}

class _CopyWithStubImpl$Mutation$UpdateMangaCategories<TRes>
    implements CopyWith$Mutation$UpdateMangaCategories<TRes> {
  _CopyWithStubImpl$Mutation$UpdateMangaCategories(this._res);

  TRes _res;

  call({
    Mutation$UpdateMangaCategories$updateMangaCategories? updateMangaCategories,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$UpdateMangaCategories$updateMangaCategories<TRes>
      get updateMangaCategories =>
          CopyWith$Mutation$UpdateMangaCategories$updateMangaCategories.stub(
              _res);
}

const documentNodeMutationUpdateMangaCategories = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'UpdateMangaCategories'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'updateCategoryInput')),
        type: NamedTypeNode(
          name: NameNode(value: 'UpdateMangaCategoriesInput'),
          isNonNull: true,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      )
    ],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'updateMangaCategories'),
        alias: null,
        arguments: [
          ArgumentNode(
            name: NameNode(value: 'input'),
            value: VariableNode(name: NameNode(value: 'updateCategoryInput')),
          )
        ],
        directives: [],
        selectionSet: SelectionSetNode(selections: [
          FieldNode(
            name: NameNode(value: 'manga'),
            alias: null,
            arguments: [],
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
                name: NameNode(value: 'categories'),
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
Mutation$UpdateMangaCategories _parserFn$Mutation$UpdateMangaCategories(
        Map<String, dynamic> data) =>
    Mutation$UpdateMangaCategories.fromJson(data);
typedef OnMutationCompleted$Mutation$UpdateMangaCategories = FutureOr<void>
    Function(
  Map<String, dynamic>?,
  Mutation$UpdateMangaCategories?,
);

class Options$Mutation$UpdateMangaCategories
    extends graphql.MutationOptions<Mutation$UpdateMangaCategories> {
  Options$Mutation$UpdateMangaCategories({
    String? operationName,
    required Variables$Mutation$UpdateMangaCategories variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateMangaCategories? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateMangaCategories? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateMangaCategories>? update,
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
                        : _parserFn$Mutation$UpdateMangaCategories(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateMangaCategories,
          parserFn: _parserFn$Mutation$UpdateMangaCategories,
        );

  final OnMutationCompleted$Mutation$UpdateMangaCategories?
      onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$UpdateMangaCategories
    extends graphql.WatchQueryOptions<Mutation$UpdateMangaCategories> {
  WatchOptions$Mutation$UpdateMangaCategories({
    String? operationName,
    required Variables$Mutation$UpdateMangaCategories variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateMangaCategories? typedOptimisticResult,
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
          document: documentNodeMutationUpdateMangaCategories,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$UpdateMangaCategories,
        );
}

extension ClientExtension$Mutation$UpdateMangaCategories
    on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$UpdateMangaCategories>>
      mutate$UpdateMangaCategories(
              Options$Mutation$UpdateMangaCategories options) async =>
          await this.mutate(options);

  graphql.ObservableQuery<Mutation$UpdateMangaCategories>
      watchMutation$UpdateMangaCategories(
              WatchOptions$Mutation$UpdateMangaCategories options) =>
          this.watchMutation(options);
}

class Mutation$UpdateMangaCategories$HookResult {
  Mutation$UpdateMangaCategories$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$UpdateMangaCategories runMutation;

  final graphql.QueryResult<Mutation$UpdateMangaCategories> result;
}

Mutation$UpdateMangaCategories$HookResult useMutation$UpdateMangaCategories(
    [WidgetOptions$Mutation$UpdateMangaCategories? options]) {
  final result = graphql_flutter
      .useMutation(options ?? WidgetOptions$Mutation$UpdateMangaCategories());
  return Mutation$UpdateMangaCategories$HookResult(
    (variables, {optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables.toJson(),
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$UpdateMangaCategories>
    useWatchMutation$UpdateMangaCategories(
            WatchOptions$Mutation$UpdateMangaCategories options) =>
        graphql_flutter.useWatchMutation(options);

class WidgetOptions$Mutation$UpdateMangaCategories
    extends graphql.MutationOptions<Mutation$UpdateMangaCategories> {
  WidgetOptions$Mutation$UpdateMangaCategories({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateMangaCategories? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateMangaCategories? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateMangaCategories>? update,
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
                        : _parserFn$Mutation$UpdateMangaCategories(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateMangaCategories,
          parserFn: _parserFn$Mutation$UpdateMangaCategories,
        );

  final OnMutationCompleted$Mutation$UpdateMangaCategories?
      onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$UpdateMangaCategories
    = graphql.MultiSourceResult<Mutation$UpdateMangaCategories> Function(
  Variables$Mutation$UpdateMangaCategories, {
  Object? optimisticResult,
  Mutation$UpdateMangaCategories? typedOptimisticResult,
});
typedef Builder$Mutation$UpdateMangaCategories = widgets.Widget Function(
  RunMutation$Mutation$UpdateMangaCategories,
  graphql.QueryResult<Mutation$UpdateMangaCategories>?,
);

class Mutation$UpdateMangaCategories$Widget
    extends graphql_flutter.Mutation<Mutation$UpdateMangaCategories> {
  Mutation$UpdateMangaCategories$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$UpdateMangaCategories? options,
    required Builder$Mutation$UpdateMangaCategories builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$UpdateMangaCategories(),
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

class Mutation$UpdateMangaCategories$updateMangaCategories {
  Mutation$UpdateMangaCategories$updateMangaCategories({
    required this.manga,
    this.$__typename = 'UpdateMangaCategoriesPayload',
  });

  factory Mutation$UpdateMangaCategories$updateMangaCategories.fromJson(
      Map<String, dynamic> json) {
    final l$manga = json['manga'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateMangaCategories$updateMangaCategories(
      manga:
          Mutation$UpdateMangaCategories$updateMangaCategories$manga.fromJson(
              (l$manga as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$UpdateMangaCategories$updateMangaCategories$manga manga;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$manga = manga;
    _resultData['manga'] = l$manga.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$manga = manga;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$manga,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$UpdateMangaCategories$updateMangaCategories ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$manga = manga;
    final lOther$manga = other.manga;
    if (l$manga != lOther$manga) {
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

extension UtilityExtension$Mutation$UpdateMangaCategories$updateMangaCategories
    on Mutation$UpdateMangaCategories$updateMangaCategories {
  CopyWith$Mutation$UpdateMangaCategories$updateMangaCategories<
          Mutation$UpdateMangaCategories$updateMangaCategories>
      get copyWith =>
          CopyWith$Mutation$UpdateMangaCategories$updateMangaCategories(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdateMangaCategories$updateMangaCategories<
    TRes> {
  factory CopyWith$Mutation$UpdateMangaCategories$updateMangaCategories(
    Mutation$UpdateMangaCategories$updateMangaCategories instance,
    TRes Function(Mutation$UpdateMangaCategories$updateMangaCategories) then,
  ) = _CopyWithImpl$Mutation$UpdateMangaCategories$updateMangaCategories;

  factory CopyWith$Mutation$UpdateMangaCategories$updateMangaCategories.stub(
          TRes res) =
      _CopyWithStubImpl$Mutation$UpdateMangaCategories$updateMangaCategories;

  TRes call({
    Mutation$UpdateMangaCategories$updateMangaCategories$manga? manga,
    String? $__typename,
  });
  CopyWith$Mutation$UpdateMangaCategories$updateMangaCategories$manga<TRes>
      get manga;
}

class _CopyWithImpl$Mutation$UpdateMangaCategories$updateMangaCategories<TRes>
    implements
        CopyWith$Mutation$UpdateMangaCategories$updateMangaCategories<TRes> {
  _CopyWithImpl$Mutation$UpdateMangaCategories$updateMangaCategories(
    this._instance,
    this._then,
  );

  final Mutation$UpdateMangaCategories$updateMangaCategories _instance;

  final TRes Function(Mutation$UpdateMangaCategories$updateMangaCategories)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? manga = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateMangaCategories$updateMangaCategories(
        manga: manga == _undefined || manga == null
            ? _instance.manga
            : (manga
                as Mutation$UpdateMangaCategories$updateMangaCategories$manga),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$UpdateMangaCategories$updateMangaCategories$manga<TRes>
      get manga {
    final local$manga = _instance.manga;
    return CopyWith$Mutation$UpdateMangaCategories$updateMangaCategories$manga(
        local$manga, (e) => call(manga: e));
  }
}

class _CopyWithStubImpl$Mutation$UpdateMangaCategories$updateMangaCategories<
        TRes>
    implements
        CopyWith$Mutation$UpdateMangaCategories$updateMangaCategories<TRes> {
  _CopyWithStubImpl$Mutation$UpdateMangaCategories$updateMangaCategories(
      this._res);

  TRes _res;

  call({
    Mutation$UpdateMangaCategories$updateMangaCategories$manga? manga,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$UpdateMangaCategories$updateMangaCategories$manga<TRes>
      get manga =>
          CopyWith$Mutation$UpdateMangaCategories$updateMangaCategories$manga
              .stub(_res);
}

class Mutation$UpdateMangaCategories$updateMangaCategories$manga {
  Mutation$UpdateMangaCategories$updateMangaCategories$manga({
    required this.id,
    required this.categories,
    this.$__typename = 'MangaType',
  });

  factory Mutation$UpdateMangaCategories$updateMangaCategories$manga.fromJson(
      Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$categories = json['categories'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateMangaCategories$updateMangaCategories$manga(
      id: (l$id as int),
      categories:
          Mutation$UpdateMangaCategories$updateMangaCategories$manga$categories
              .fromJson((l$categories as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final int id;

  final Mutation$UpdateMangaCategories$updateMangaCategories$manga$categories
      categories;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$categories = categories;
    _resultData['categories'] = l$categories.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$categories = categories;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$categories,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$UpdateMangaCategories$updateMangaCategories$manga ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
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

extension UtilityExtension$Mutation$UpdateMangaCategories$updateMangaCategories$manga
    on Mutation$UpdateMangaCategories$updateMangaCategories$manga {
  CopyWith$Mutation$UpdateMangaCategories$updateMangaCategories$manga<
          Mutation$UpdateMangaCategories$updateMangaCategories$manga>
      get copyWith =>
          CopyWith$Mutation$UpdateMangaCategories$updateMangaCategories$manga(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdateMangaCategories$updateMangaCategories$manga<
    TRes> {
  factory CopyWith$Mutation$UpdateMangaCategories$updateMangaCategories$manga(
    Mutation$UpdateMangaCategories$updateMangaCategories$manga instance,
    TRes Function(Mutation$UpdateMangaCategories$updateMangaCategories$manga)
        then,
  ) = _CopyWithImpl$Mutation$UpdateMangaCategories$updateMangaCategories$manga;

  factory CopyWith$Mutation$UpdateMangaCategories$updateMangaCategories$manga.stub(
          TRes res) =
      _CopyWithStubImpl$Mutation$UpdateMangaCategories$updateMangaCategories$manga;

  TRes call({
    int? id,
    Mutation$UpdateMangaCategories$updateMangaCategories$manga$categories?
        categories,
    String? $__typename,
  });
  CopyWith$Mutation$UpdateMangaCategories$updateMangaCategories$manga$categories<
      TRes> get categories;
}

class _CopyWithImpl$Mutation$UpdateMangaCategories$updateMangaCategories$manga<
        TRes>
    implements
        CopyWith$Mutation$UpdateMangaCategories$updateMangaCategories$manga<
            TRes> {
  _CopyWithImpl$Mutation$UpdateMangaCategories$updateMangaCategories$manga(
    this._instance,
    this._then,
  );

  final Mutation$UpdateMangaCategories$updateMangaCategories$manga _instance;

  final TRes Function(
      Mutation$UpdateMangaCategories$updateMangaCategories$manga) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? categories = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateMangaCategories$updateMangaCategories$manga(
        id: id == _undefined || id == null ? _instance.id : (id as int),
        categories: categories == _undefined || categories == null
            ? _instance.categories
            : (categories
                as Mutation$UpdateMangaCategories$updateMangaCategories$manga$categories),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$UpdateMangaCategories$updateMangaCategories$manga$categories<
      TRes> get categories {
    final local$categories = _instance.categories;
    return CopyWith$Mutation$UpdateMangaCategories$updateMangaCategories$manga$categories(
        local$categories, (e) => call(categories: e));
  }
}

class _CopyWithStubImpl$Mutation$UpdateMangaCategories$updateMangaCategories$manga<
        TRes>
    implements
        CopyWith$Mutation$UpdateMangaCategories$updateMangaCategories$manga<
            TRes> {
  _CopyWithStubImpl$Mutation$UpdateMangaCategories$updateMangaCategories$manga(
      this._res);

  TRes _res;

  call({
    int? id,
    Mutation$UpdateMangaCategories$updateMangaCategories$manga$categories?
        categories,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$UpdateMangaCategories$updateMangaCategories$manga$categories<
          TRes>
      get categories =>
          CopyWith$Mutation$UpdateMangaCategories$updateMangaCategories$manga$categories
              .stub(_res);
}

class Mutation$UpdateMangaCategories$updateMangaCategories$manga$categories {
  Mutation$UpdateMangaCategories$updateMangaCategories$manga$categories({
    required this.nodes,
    required this.totalCount,
    this.$__typename = 'CategoryNodeList',
  });

  factory Mutation$UpdateMangaCategories$updateMangaCategories$manga$categories.fromJson(
      Map<String, dynamic> json) {
    final l$nodes = json['nodes'];
    final l$totalCount = json['totalCount'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateMangaCategories$updateMangaCategories$manga$categories(
      nodes: (l$nodes as List<dynamic>)
          .map(
              (e) => Fragment$CategoryDto.fromJson((e as Map<String, dynamic>)))
          .toList(),
      totalCount: (l$totalCount as int),
      $__typename: (l$$__typename as String),
    );
  }

  final List<Fragment$CategoryDto> nodes;

  final int totalCount;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$nodes = nodes;
    _resultData['nodes'] = l$nodes.map((e) => e.toJson()).toList();
    final l$totalCount = totalCount;
    _resultData['totalCount'] = l$totalCount;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$nodes = nodes;
    final l$totalCount = totalCount;
    final l$$__typename = $__typename;
    return Object.hashAll([
      Object.hashAll(l$nodes.map((v) => v)),
      l$totalCount,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Mutation$UpdateMangaCategories$updateMangaCategories$manga$categories ||
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

extension UtilityExtension$Mutation$UpdateMangaCategories$updateMangaCategories$manga$categories
    on Mutation$UpdateMangaCategories$updateMangaCategories$manga$categories {
  CopyWith$Mutation$UpdateMangaCategories$updateMangaCategories$manga$categories<
          Mutation$UpdateMangaCategories$updateMangaCategories$manga$categories>
      get copyWith =>
          CopyWith$Mutation$UpdateMangaCategories$updateMangaCategories$manga$categories(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdateMangaCategories$updateMangaCategories$manga$categories<
    TRes> {
  factory CopyWith$Mutation$UpdateMangaCategories$updateMangaCategories$manga$categories(
    Mutation$UpdateMangaCategories$updateMangaCategories$manga$categories
        instance,
    TRes Function(
            Mutation$UpdateMangaCategories$updateMangaCategories$manga$categories)
        then,
  ) = _CopyWithImpl$Mutation$UpdateMangaCategories$updateMangaCategories$manga$categories;

  factory CopyWith$Mutation$UpdateMangaCategories$updateMangaCategories$manga$categories.stub(
          TRes res) =
      _CopyWithStubImpl$Mutation$UpdateMangaCategories$updateMangaCategories$manga$categories;

  TRes call({
    List<Fragment$CategoryDto>? nodes,
    int? totalCount,
    String? $__typename,
  });
  TRes nodes(
      Iterable<Fragment$CategoryDto> Function(
              Iterable<CopyWith$Fragment$CategoryDto<Fragment$CategoryDto>>)
          _fn);
}

class _CopyWithImpl$Mutation$UpdateMangaCategories$updateMangaCategories$manga$categories<
        TRes>
    implements
        CopyWith$Mutation$UpdateMangaCategories$updateMangaCategories$manga$categories<
            TRes> {
  _CopyWithImpl$Mutation$UpdateMangaCategories$updateMangaCategories$manga$categories(
    this._instance,
    this._then,
  );

  final Mutation$UpdateMangaCategories$updateMangaCategories$manga$categories
      _instance;

  final TRes Function(
          Mutation$UpdateMangaCategories$updateMangaCategories$manga$categories)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? nodes = _undefined,
    Object? totalCount = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(
          Mutation$UpdateMangaCategories$updateMangaCategories$manga$categories(
        nodes: nodes == _undefined || nodes == null
            ? _instance.nodes
            : (nodes as List<Fragment$CategoryDto>),
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
}

class _CopyWithStubImpl$Mutation$UpdateMangaCategories$updateMangaCategories$manga$categories<
        TRes>
    implements
        CopyWith$Mutation$UpdateMangaCategories$updateMangaCategories$manga$categories<
            TRes> {
  _CopyWithStubImpl$Mutation$UpdateMangaCategories$updateMangaCategories$manga$categories(
      this._res);

  TRes _res;

  call({
    List<Fragment$CategoryDto>? nodes,
    int? totalCount,
    String? $__typename,
  }) =>
      _res;

  nodes(_fn) => _res;
}

class Variables$Query$GetChapter {
  factory Variables$Query$GetChapter({required int id}) =>
      Variables$Query$GetChapter._({
        r'id': id,
      });

  Variables$Query$GetChapter._(this._$data);

  factory Variables$Query$GetChapter.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$id = data['id'];
    result$data['id'] = (l$id as int);
    return Variables$Query$GetChapter._(result$data);
  }

  Map<String, dynamic> _$data;

  int get id => (_$data['id'] as int);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$id = id;
    result$data['id'] = l$id;
    return result$data;
  }

  CopyWith$Variables$Query$GetChapter<Variables$Query$GetChapter>
      get copyWith => CopyWith$Variables$Query$GetChapter(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Query$GetChapter ||
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

abstract class CopyWith$Variables$Query$GetChapter<TRes> {
  factory CopyWith$Variables$Query$GetChapter(
    Variables$Query$GetChapter instance,
    TRes Function(Variables$Query$GetChapter) then,
  ) = _CopyWithImpl$Variables$Query$GetChapter;

  factory CopyWith$Variables$Query$GetChapter.stub(TRes res) =
      _CopyWithStubImpl$Variables$Query$GetChapter;

  TRes call({int? id});
}

class _CopyWithImpl$Variables$Query$GetChapter<TRes>
    implements CopyWith$Variables$Query$GetChapter<TRes> {
  _CopyWithImpl$Variables$Query$GetChapter(
    this._instance,
    this._then,
  );

  final Variables$Query$GetChapter _instance;

  final TRes Function(Variables$Query$GetChapter) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? id = _undefined}) => _then(Variables$Query$GetChapter._({
        ..._instance._$data,
        if (id != _undefined && id != null) 'id': (id as int),
      }));
}

class _CopyWithStubImpl$Variables$Query$GetChapter<TRes>
    implements CopyWith$Variables$Query$GetChapter<TRes> {
  _CopyWithStubImpl$Variables$Query$GetChapter(this._res);

  TRes _res;

  call({int? id}) => _res;
}

class Query$GetChapter {
  Query$GetChapter({
    required this.chapter,
    this.$__typename = 'Query',
  });

  factory Query$GetChapter.fromJson(Map<String, dynamic> json) {
    final l$chapter = json['chapter'];
    final l$$__typename = json['__typename'];
    return Query$GetChapter(
      chapter:
          Fragment$ChapterDto.fromJson((l$chapter as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Fragment$ChapterDto chapter;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$chapter = chapter;
    _resultData['chapter'] = l$chapter.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$chapter = chapter;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$chapter,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetChapter || runtimeType != other.runtimeType) {
      return false;
    }
    final l$chapter = chapter;
    final lOther$chapter = other.chapter;
    if (l$chapter != lOther$chapter) {
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

extension UtilityExtension$Query$GetChapter on Query$GetChapter {
  CopyWith$Query$GetChapter<Query$GetChapter> get copyWith =>
      CopyWith$Query$GetChapter(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Query$GetChapter<TRes> {
  factory CopyWith$Query$GetChapter(
    Query$GetChapter instance,
    TRes Function(Query$GetChapter) then,
  ) = _CopyWithImpl$Query$GetChapter;

  factory CopyWith$Query$GetChapter.stub(TRes res) =
      _CopyWithStubImpl$Query$GetChapter;

  TRes call({
    Fragment$ChapterDto? chapter,
    String? $__typename,
  });
  CopyWith$Fragment$ChapterDto<TRes> get chapter;
}

class _CopyWithImpl$Query$GetChapter<TRes>
    implements CopyWith$Query$GetChapter<TRes> {
  _CopyWithImpl$Query$GetChapter(
    this._instance,
    this._then,
  );

  final Query$GetChapter _instance;

  final TRes Function(Query$GetChapter) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? chapter = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetChapter(
        chapter: chapter == _undefined || chapter == null
            ? _instance.chapter
            : (chapter as Fragment$ChapterDto),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Fragment$ChapterDto<TRes> get chapter {
    final local$chapter = _instance.chapter;
    return CopyWith$Fragment$ChapterDto(local$chapter, (e) => call(chapter: e));
  }
}

class _CopyWithStubImpl$Query$GetChapter<TRes>
    implements CopyWith$Query$GetChapter<TRes> {
  _CopyWithStubImpl$Query$GetChapter(this._res);

  TRes _res;

  call({
    Fragment$ChapterDto? chapter,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$ChapterDto<TRes> get chapter =>
      CopyWith$Fragment$ChapterDto.stub(_res);
}

const documentNodeQueryGetChapter = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.query,
    name: NameNode(value: 'GetChapter'),
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
        name: NameNode(value: 'chapter'),
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
            name: NameNode(value: 'ChapterDto'),
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
  fragmentDefinitionChapterDto,
]);
Query$GetChapter _parserFn$Query$GetChapter(Map<String, dynamic> data) =>
    Query$GetChapter.fromJson(data);
typedef OnQueryComplete$Query$GetChapter = FutureOr<void> Function(
  Map<String, dynamic>?,
  Query$GetChapter?,
);

class Options$Query$GetChapter extends graphql.QueryOptions<Query$GetChapter> {
  Options$Query$GetChapter({
    String? operationName,
    required Variables$Query$GetChapter variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetChapter? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$GetChapter? onComplete,
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
                    data == null ? null : _parserFn$Query$GetChapter(data),
                  ),
          onError: onError,
          document: documentNodeQueryGetChapter,
          parserFn: _parserFn$Query$GetChapter,
        );

  final OnQueryComplete$Query$GetChapter? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onComplete == null
            ? super.properties
            : super.properties.where((property) => property != onComplete),
        onCompleteWithParsed,
      ];
}

class WatchOptions$Query$GetChapter
    extends graphql.WatchQueryOptions<Query$GetChapter> {
  WatchOptions$Query$GetChapter({
    String? operationName,
    required Variables$Query$GetChapter variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetChapter? typedOptimisticResult,
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
          document: documentNodeQueryGetChapter,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Query$GetChapter,
        );
}

class FetchMoreOptions$Query$GetChapter extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$GetChapter({
    required graphql.UpdateQuery updateQuery,
    required Variables$Query$GetChapter variables,
  }) : super(
          updateQuery: updateQuery,
          variables: variables.toJson(),
          document: documentNodeQueryGetChapter,
        );
}

extension ClientExtension$Query$GetChapter on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$GetChapter>> query$GetChapter(
          Options$Query$GetChapter options) async =>
      await this.query(options);

  graphql.ObservableQuery<Query$GetChapter> watchQuery$GetChapter(
          WatchOptions$Query$GetChapter options) =>
      this.watchQuery(options);

  void writeQuery$GetChapter({
    required Query$GetChapter data,
    required Variables$Query$GetChapter variables,
    bool broadcast = true,
  }) =>
      this.writeQuery(
        graphql.Request(
          operation: graphql.Operation(document: documentNodeQueryGetChapter),
          variables: variables.toJson(),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );

  Query$GetChapter? readQuery$GetChapter({
    required Variables$Query$GetChapter variables,
    bool optimistic = true,
  }) {
    final result = this.readQuery(
      graphql.Request(
        operation: graphql.Operation(document: documentNodeQueryGetChapter),
        variables: variables.toJson(),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Query$GetChapter.fromJson(result);
  }
}

graphql_flutter.QueryHookResult<Query$GetChapter> useQuery$GetChapter(
        Options$Query$GetChapter options) =>
    graphql_flutter.useQuery(options);
graphql.ObservableQuery<Query$GetChapter> useWatchQuery$GetChapter(
        WatchOptions$Query$GetChapter options) =>
    graphql_flutter.useWatchQuery(options);

class Query$GetChapter$Widget extends graphql_flutter.Query<Query$GetChapter> {
  Query$GetChapter$Widget({
    widgets.Key? key,
    required Options$Query$GetChapter options,
    required graphql_flutter.QueryBuilder<Query$GetChapter> builder,
  }) : super(
          key: key,
          options: options,
          builder: builder,
        );
}

class Variables$Query$GetChapterPage {
  factory Variables$Query$GetChapterPage({
    int? after,
    int? before,
    Input$ChapterConditionInput? condition,
    Input$ChapterFilterInput? filter,
    int? first,
    int? last,
    int? offset,
    List<Input$ChapterOrderInput>? order,
  }) =>
      Variables$Query$GetChapterPage._({
        if (after != null) r'after': after,
        if (before != null) r'before': before,
        if (condition != null) r'condition': condition,
        if (filter != null) r'filter': filter,
        if (first != null) r'first': first,
        if (last != null) r'last': last,
        if (offset != null) r'offset': offset,
        if (order != null) r'order': order,
      });

  Variables$Query$GetChapterPage._(this._$data);

  factory Variables$Query$GetChapterPage.fromJson(Map<String, dynamic> data) {
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
    return Variables$Query$GetChapterPage._(result$data);
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

  CopyWith$Variables$Query$GetChapterPage<Variables$Query$GetChapterPage>
      get copyWith => CopyWith$Variables$Query$GetChapterPage(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Query$GetChapterPage ||
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

abstract class CopyWith$Variables$Query$GetChapterPage<TRes> {
  factory CopyWith$Variables$Query$GetChapterPage(
    Variables$Query$GetChapterPage instance,
    TRes Function(Variables$Query$GetChapterPage) then,
  ) = _CopyWithImpl$Variables$Query$GetChapterPage;

  factory CopyWith$Variables$Query$GetChapterPage.stub(TRes res) =
      _CopyWithStubImpl$Variables$Query$GetChapterPage;

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

class _CopyWithImpl$Variables$Query$GetChapterPage<TRes>
    implements CopyWith$Variables$Query$GetChapterPage<TRes> {
  _CopyWithImpl$Variables$Query$GetChapterPage(
    this._instance,
    this._then,
  );

  final Variables$Query$GetChapterPage _instance;

  final TRes Function(Variables$Query$GetChapterPage) _then;

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
      _then(Variables$Query$GetChapterPage._({
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

class _CopyWithStubImpl$Variables$Query$GetChapterPage<TRes>
    implements CopyWith$Variables$Query$GetChapterPage<TRes> {
  _CopyWithStubImpl$Variables$Query$GetChapterPage(this._res);

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

class Query$GetChapterPage {
  Query$GetChapterPage({
    required this.chapters,
    this.$__typename = 'Query',
  });

  factory Query$GetChapterPage.fromJson(Map<String, dynamic> json) {
    final l$chapters = json['chapters'];
    final l$$__typename = json['__typename'];
    return Query$GetChapterPage(
      chapters: Query$GetChapterPage$chapters.fromJson(
          (l$chapters as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Query$GetChapterPage$chapters chapters;

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
    if (other is! Query$GetChapterPage || runtimeType != other.runtimeType) {
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

extension UtilityExtension$Query$GetChapterPage on Query$GetChapterPage {
  CopyWith$Query$GetChapterPage<Query$GetChapterPage> get copyWith =>
      CopyWith$Query$GetChapterPage(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Query$GetChapterPage<TRes> {
  factory CopyWith$Query$GetChapterPage(
    Query$GetChapterPage instance,
    TRes Function(Query$GetChapterPage) then,
  ) = _CopyWithImpl$Query$GetChapterPage;

  factory CopyWith$Query$GetChapterPage.stub(TRes res) =
      _CopyWithStubImpl$Query$GetChapterPage;

  TRes call({
    Query$GetChapterPage$chapters? chapters,
    String? $__typename,
  });
  CopyWith$Query$GetChapterPage$chapters<TRes> get chapters;
}

class _CopyWithImpl$Query$GetChapterPage<TRes>
    implements CopyWith$Query$GetChapterPage<TRes> {
  _CopyWithImpl$Query$GetChapterPage(
    this._instance,
    this._then,
  );

  final Query$GetChapterPage _instance;

  final TRes Function(Query$GetChapterPage) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? chapters = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetChapterPage(
        chapters: chapters == _undefined || chapters == null
            ? _instance.chapters
            : (chapters as Query$GetChapterPage$chapters),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$GetChapterPage$chapters<TRes> get chapters {
    final local$chapters = _instance.chapters;
    return CopyWith$Query$GetChapterPage$chapters(
        local$chapters, (e) => call(chapters: e));
  }
}

class _CopyWithStubImpl$Query$GetChapterPage<TRes>
    implements CopyWith$Query$GetChapterPage<TRes> {
  _CopyWithStubImpl$Query$GetChapterPage(this._res);

  TRes _res;

  call({
    Query$GetChapterPage$chapters? chapters,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$GetChapterPage$chapters<TRes> get chapters =>
      CopyWith$Query$GetChapterPage$chapters.stub(_res);
}

const documentNodeQueryGetChapterPage = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.query,
    name: NameNode(value: 'GetChapterPage'),
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
          FieldNode(
            name: NameNode(value: 'nodes'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: SelectionSetNode(selections: [
              FragmentSpreadNode(
                name: NameNode(value: 'ChapterDto'),
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
  fragmentDefinitionChapterDto,
  fragmentDefinitionPageInfoDto,
]);
Query$GetChapterPage _parserFn$Query$GetChapterPage(
        Map<String, dynamic> data) =>
    Query$GetChapterPage.fromJson(data);
typedef OnQueryComplete$Query$GetChapterPage = FutureOr<void> Function(
  Map<String, dynamic>?,
  Query$GetChapterPage?,
);

class Options$Query$GetChapterPage
    extends graphql.QueryOptions<Query$GetChapterPage> {
  Options$Query$GetChapterPage({
    String? operationName,
    Variables$Query$GetChapterPage? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetChapterPage? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$GetChapterPage? onComplete,
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
                    data == null ? null : _parserFn$Query$GetChapterPage(data),
                  ),
          onError: onError,
          document: documentNodeQueryGetChapterPage,
          parserFn: _parserFn$Query$GetChapterPage,
        );

  final OnQueryComplete$Query$GetChapterPage? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onComplete == null
            ? super.properties
            : super.properties.where((property) => property != onComplete),
        onCompleteWithParsed,
      ];
}

class WatchOptions$Query$GetChapterPage
    extends graphql.WatchQueryOptions<Query$GetChapterPage> {
  WatchOptions$Query$GetChapterPage({
    String? operationName,
    Variables$Query$GetChapterPage? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetChapterPage? typedOptimisticResult,
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
          document: documentNodeQueryGetChapterPage,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Query$GetChapterPage,
        );
}

class FetchMoreOptions$Query$GetChapterPage extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$GetChapterPage({
    required graphql.UpdateQuery updateQuery,
    Variables$Query$GetChapterPage? variables,
  }) : super(
          updateQuery: updateQuery,
          variables: variables?.toJson() ?? {},
          document: documentNodeQueryGetChapterPage,
        );
}

extension ClientExtension$Query$GetChapterPage on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$GetChapterPage>> query$GetChapterPage(
          [Options$Query$GetChapterPage? options]) async =>
      await this.query(options ?? Options$Query$GetChapterPage());

  graphql.ObservableQuery<Query$GetChapterPage> watchQuery$GetChapterPage(
          [WatchOptions$Query$GetChapterPage? options]) =>
      this.watchQuery(options ?? WatchOptions$Query$GetChapterPage());

  void writeQuery$GetChapterPage({
    required Query$GetChapterPage data,
    Variables$Query$GetChapterPage? variables,
    bool broadcast = true,
  }) =>
      this.writeQuery(
        graphql.Request(
          operation:
              graphql.Operation(document: documentNodeQueryGetChapterPage),
          variables: variables?.toJson() ?? const {},
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );

  Query$GetChapterPage? readQuery$GetChapterPage({
    Variables$Query$GetChapterPage? variables,
    bool optimistic = true,
  }) {
    final result = this.readQuery(
      graphql.Request(
        operation: graphql.Operation(document: documentNodeQueryGetChapterPage),
        variables: variables?.toJson() ?? const {},
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Query$GetChapterPage.fromJson(result);
  }
}

graphql_flutter.QueryHookResult<Query$GetChapterPage> useQuery$GetChapterPage(
        [Options$Query$GetChapterPage? options]) =>
    graphql_flutter.useQuery(options ?? Options$Query$GetChapterPage());
graphql.ObservableQuery<Query$GetChapterPage> useWatchQuery$GetChapterPage(
        [WatchOptions$Query$GetChapterPage? options]) =>
    graphql_flutter
        .useWatchQuery(options ?? WatchOptions$Query$GetChapterPage());

class Query$GetChapterPage$Widget
    extends graphql_flutter.Query<Query$GetChapterPage> {
  Query$GetChapterPage$Widget({
    widgets.Key? key,
    Options$Query$GetChapterPage? options,
    required graphql_flutter.QueryBuilder<Query$GetChapterPage> builder,
  }) : super(
          key: key,
          options: options ?? Options$Query$GetChapterPage(),
          builder: builder,
        );
}

class Query$GetChapterPage$chapters {
  Query$GetChapterPage$chapters({
    required this.nodes,
    required this.pageInfo,
    required this.totalCount,
    this.$__typename = 'ChapterNodeList',
  });

  factory Query$GetChapterPage$chapters.fromJson(Map<String, dynamic> json) {
    final l$nodes = json['nodes'];
    final l$pageInfo = json['pageInfo'];
    final l$totalCount = json['totalCount'];
    final l$$__typename = json['__typename'];
    return Query$GetChapterPage$chapters(
      nodes: (l$nodes as List<dynamic>)
          .map((e) => Fragment$ChapterDto.fromJson((e as Map<String, dynamic>)))
          .toList(),
      pageInfo:
          Fragment$PageInfoDto.fromJson((l$pageInfo as Map<String, dynamic>)),
      totalCount: (l$totalCount as int),
      $__typename: (l$$__typename as String),
    );
  }

  final List<Fragment$ChapterDto> nodes;

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
    if (other is! Query$GetChapterPage$chapters ||
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

extension UtilityExtension$Query$GetChapterPage$chapters
    on Query$GetChapterPage$chapters {
  CopyWith$Query$GetChapterPage$chapters<Query$GetChapterPage$chapters>
      get copyWith => CopyWith$Query$GetChapterPage$chapters(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetChapterPage$chapters<TRes> {
  factory CopyWith$Query$GetChapterPage$chapters(
    Query$GetChapterPage$chapters instance,
    TRes Function(Query$GetChapterPage$chapters) then,
  ) = _CopyWithImpl$Query$GetChapterPage$chapters;

  factory CopyWith$Query$GetChapterPage$chapters.stub(TRes res) =
      _CopyWithStubImpl$Query$GetChapterPage$chapters;

  TRes call({
    List<Fragment$ChapterDto>? nodes,
    Fragment$PageInfoDto? pageInfo,
    int? totalCount,
    String? $__typename,
  });
  TRes nodes(
      Iterable<Fragment$ChapterDto> Function(
              Iterable<CopyWith$Fragment$ChapterDto<Fragment$ChapterDto>>)
          _fn);
  CopyWith$Fragment$PageInfoDto<TRes> get pageInfo;
}

class _CopyWithImpl$Query$GetChapterPage$chapters<TRes>
    implements CopyWith$Query$GetChapterPage$chapters<TRes> {
  _CopyWithImpl$Query$GetChapterPage$chapters(
    this._instance,
    this._then,
  );

  final Query$GetChapterPage$chapters _instance;

  final TRes Function(Query$GetChapterPage$chapters) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? nodes = _undefined,
    Object? pageInfo = _undefined,
    Object? totalCount = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetChapterPage$chapters(
        nodes: nodes == _undefined || nodes == null
            ? _instance.nodes
            : (nodes as List<Fragment$ChapterDto>),
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
          Iterable<Fragment$ChapterDto> Function(
                  Iterable<CopyWith$Fragment$ChapterDto<Fragment$ChapterDto>>)
              _fn) =>
      call(
          nodes: _fn(_instance.nodes.map((e) => CopyWith$Fragment$ChapterDto(
                e,
                (i) => i,
              ))).toList());

  CopyWith$Fragment$PageInfoDto<TRes> get pageInfo {
    final local$pageInfo = _instance.pageInfo;
    return CopyWith$Fragment$PageInfoDto(
        local$pageInfo, (e) => call(pageInfo: e));
  }
}

class _CopyWithStubImpl$Query$GetChapterPage$chapters<TRes>
    implements CopyWith$Query$GetChapterPage$chapters<TRes> {
  _CopyWithStubImpl$Query$GetChapterPage$chapters(this._res);

  TRes _res;

  call({
    List<Fragment$ChapterDto>? nodes,
    Fragment$PageInfoDto? pageInfo,
    int? totalCount,
    String? $__typename,
  }) =>
      _res;

  nodes(_fn) => _res;

  CopyWith$Fragment$PageInfoDto<TRes> get pageInfo =>
      CopyWith$Fragment$PageInfoDto.stub(_res);
}

class Variables$Mutation$UpdateChapters {
  factory Variables$Mutation$UpdateChapters(
          {required Input$UpdateChaptersInput input}) =>
      Variables$Mutation$UpdateChapters._({
        r'input': input,
      });

  Variables$Mutation$UpdateChapters._(this._$data);

  factory Variables$Mutation$UpdateChapters.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$input = data['input'];
    result$data['input'] =
        Input$UpdateChaptersInput.fromJson((l$input as Map<String, dynamic>));
    return Variables$Mutation$UpdateChapters._(result$data);
  }

  Map<String, dynamic> _$data;

  Input$UpdateChaptersInput get input =>
      (_$data['input'] as Input$UpdateChaptersInput);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$input = input;
    result$data['input'] = l$input.toJson();
    return result$data;
  }

  CopyWith$Variables$Mutation$UpdateChapters<Variables$Mutation$UpdateChapters>
      get copyWith => CopyWith$Variables$Mutation$UpdateChapters(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$UpdateChapters ||
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

abstract class CopyWith$Variables$Mutation$UpdateChapters<TRes> {
  factory CopyWith$Variables$Mutation$UpdateChapters(
    Variables$Mutation$UpdateChapters instance,
    TRes Function(Variables$Mutation$UpdateChapters) then,
  ) = _CopyWithImpl$Variables$Mutation$UpdateChapters;

  factory CopyWith$Variables$Mutation$UpdateChapters.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$UpdateChapters;

  TRes call({Input$UpdateChaptersInput? input});
}

class _CopyWithImpl$Variables$Mutation$UpdateChapters<TRes>
    implements CopyWith$Variables$Mutation$UpdateChapters<TRes> {
  _CopyWithImpl$Variables$Mutation$UpdateChapters(
    this._instance,
    this._then,
  );

  final Variables$Mutation$UpdateChapters _instance;

  final TRes Function(Variables$Mutation$UpdateChapters) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? input = _undefined}) =>
      _then(Variables$Mutation$UpdateChapters._({
        ..._instance._$data,
        if (input != _undefined && input != null)
          'input': (input as Input$UpdateChaptersInput),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$UpdateChapters<TRes>
    implements CopyWith$Variables$Mutation$UpdateChapters<TRes> {
  _CopyWithStubImpl$Variables$Mutation$UpdateChapters(this._res);

  TRes _res;

  call({Input$UpdateChaptersInput? input}) => _res;
}

class Mutation$UpdateChapters {
  Mutation$UpdateChapters({
    this.updateChapters,
    this.$__typename = 'Mutation',
  });

  factory Mutation$UpdateChapters.fromJson(Map<String, dynamic> json) {
    final l$updateChapters = json['updateChapters'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateChapters(
      updateChapters: l$updateChapters == null
          ? null
          : Mutation$UpdateChapters$updateChapters.fromJson(
              (l$updateChapters as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$UpdateChapters$updateChapters? updateChapters;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$updateChapters = updateChapters;
    _resultData['updateChapters'] = l$updateChapters?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$updateChapters = updateChapters;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$updateChapters,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$UpdateChapters || runtimeType != other.runtimeType) {
      return false;
    }
    final l$updateChapters = updateChapters;
    final lOther$updateChapters = other.updateChapters;
    if (l$updateChapters != lOther$updateChapters) {
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

extension UtilityExtension$Mutation$UpdateChapters on Mutation$UpdateChapters {
  CopyWith$Mutation$UpdateChapters<Mutation$UpdateChapters> get copyWith =>
      CopyWith$Mutation$UpdateChapters(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Mutation$UpdateChapters<TRes> {
  factory CopyWith$Mutation$UpdateChapters(
    Mutation$UpdateChapters instance,
    TRes Function(Mutation$UpdateChapters) then,
  ) = _CopyWithImpl$Mutation$UpdateChapters;

  factory CopyWith$Mutation$UpdateChapters.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateChapters;

  TRes call({
    Mutation$UpdateChapters$updateChapters? updateChapters,
    String? $__typename,
  });
  CopyWith$Mutation$UpdateChapters$updateChapters<TRes> get updateChapters;
}

class _CopyWithImpl$Mutation$UpdateChapters<TRes>
    implements CopyWith$Mutation$UpdateChapters<TRes> {
  _CopyWithImpl$Mutation$UpdateChapters(
    this._instance,
    this._then,
  );

  final Mutation$UpdateChapters _instance;

  final TRes Function(Mutation$UpdateChapters) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? updateChapters = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateChapters(
        updateChapters: updateChapters == _undefined
            ? _instance.updateChapters
            : (updateChapters as Mutation$UpdateChapters$updateChapters?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$UpdateChapters$updateChapters<TRes> get updateChapters {
    final local$updateChapters = _instance.updateChapters;
    return local$updateChapters == null
        ? CopyWith$Mutation$UpdateChapters$updateChapters.stub(_then(_instance))
        : CopyWith$Mutation$UpdateChapters$updateChapters(
            local$updateChapters, (e) => call(updateChapters: e));
  }
}

class _CopyWithStubImpl$Mutation$UpdateChapters<TRes>
    implements CopyWith$Mutation$UpdateChapters<TRes> {
  _CopyWithStubImpl$Mutation$UpdateChapters(this._res);

  TRes _res;

  call({
    Mutation$UpdateChapters$updateChapters? updateChapters,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$UpdateChapters$updateChapters<TRes> get updateChapters =>
      CopyWith$Mutation$UpdateChapters$updateChapters.stub(_res);
}

const documentNodeMutationUpdateChapters = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'UpdateChapters'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'input')),
        type: NamedTypeNode(
          name: NameNode(value: 'UpdateChaptersInput'),
          isNonNull: true,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      )
    ],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'updateChapters'),
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
            name: NameNode(value: 'chapters'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: SelectionSetNode(selections: [
              FragmentSpreadNode(
                name: NameNode(value: 'ChapterDto'),
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
  fragmentDefinitionChapterDto,
]);
Mutation$UpdateChapters _parserFn$Mutation$UpdateChapters(
        Map<String, dynamic> data) =>
    Mutation$UpdateChapters.fromJson(data);
typedef OnMutationCompleted$Mutation$UpdateChapters = FutureOr<void> Function(
  Map<String, dynamic>?,
  Mutation$UpdateChapters?,
);

class Options$Mutation$UpdateChapters
    extends graphql.MutationOptions<Mutation$UpdateChapters> {
  Options$Mutation$UpdateChapters({
    String? operationName,
    required Variables$Mutation$UpdateChapters variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateChapters? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateChapters? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateChapters>? update,
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
                        : _parserFn$Mutation$UpdateChapters(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateChapters,
          parserFn: _parserFn$Mutation$UpdateChapters,
        );

  final OnMutationCompleted$Mutation$UpdateChapters? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$UpdateChapters
    extends graphql.WatchQueryOptions<Mutation$UpdateChapters> {
  WatchOptions$Mutation$UpdateChapters({
    String? operationName,
    required Variables$Mutation$UpdateChapters variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateChapters? typedOptimisticResult,
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
          document: documentNodeMutationUpdateChapters,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$UpdateChapters,
        );
}

extension ClientExtension$Mutation$UpdateChapters on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$UpdateChapters>> mutate$UpdateChapters(
          Options$Mutation$UpdateChapters options) async =>
      await this.mutate(options);

  graphql.ObservableQuery<Mutation$UpdateChapters> watchMutation$UpdateChapters(
          WatchOptions$Mutation$UpdateChapters options) =>
      this.watchMutation(options);
}

class Mutation$UpdateChapters$HookResult {
  Mutation$UpdateChapters$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$UpdateChapters runMutation;

  final graphql.QueryResult<Mutation$UpdateChapters> result;
}

Mutation$UpdateChapters$HookResult useMutation$UpdateChapters(
    [WidgetOptions$Mutation$UpdateChapters? options]) {
  final result = graphql_flutter
      .useMutation(options ?? WidgetOptions$Mutation$UpdateChapters());
  return Mutation$UpdateChapters$HookResult(
    (variables, {optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables.toJson(),
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$UpdateChapters>
    useWatchMutation$UpdateChapters(
            WatchOptions$Mutation$UpdateChapters options) =>
        graphql_flutter.useWatchMutation(options);

class WidgetOptions$Mutation$UpdateChapters
    extends graphql.MutationOptions<Mutation$UpdateChapters> {
  WidgetOptions$Mutation$UpdateChapters({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateChapters? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateChapters? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateChapters>? update,
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
                        : _parserFn$Mutation$UpdateChapters(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateChapters,
          parserFn: _parserFn$Mutation$UpdateChapters,
        );

  final OnMutationCompleted$Mutation$UpdateChapters? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$UpdateChapters
    = graphql.MultiSourceResult<Mutation$UpdateChapters> Function(
  Variables$Mutation$UpdateChapters, {
  Object? optimisticResult,
  Mutation$UpdateChapters? typedOptimisticResult,
});
typedef Builder$Mutation$UpdateChapters = widgets.Widget Function(
  RunMutation$Mutation$UpdateChapters,
  graphql.QueryResult<Mutation$UpdateChapters>?,
);

class Mutation$UpdateChapters$Widget
    extends graphql_flutter.Mutation<Mutation$UpdateChapters> {
  Mutation$UpdateChapters$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$UpdateChapters? options,
    required Builder$Mutation$UpdateChapters builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$UpdateChapters(),
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

class Mutation$UpdateChapters$updateChapters {
  Mutation$UpdateChapters$updateChapters({
    required this.chapters,
    this.$__typename = 'UpdateChaptersPayload',
  });

  factory Mutation$UpdateChapters$updateChapters.fromJson(
      Map<String, dynamic> json) {
    final l$chapters = json['chapters'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateChapters$updateChapters(
      chapters: (l$chapters as List<dynamic>)
          .map((e) => Fragment$ChapterDto.fromJson((e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final List<Fragment$ChapterDto> chapters;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$chapters = chapters;
    _resultData['chapters'] = l$chapters.map((e) => e.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$chapters = chapters;
    final l$$__typename = $__typename;
    return Object.hashAll([
      Object.hashAll(l$chapters.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$UpdateChapters$updateChapters ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$chapters = chapters;
    final lOther$chapters = other.chapters;
    if (l$chapters.length != lOther$chapters.length) {
      return false;
    }
    for (int i = 0; i < l$chapters.length; i++) {
      final l$chapters$entry = l$chapters[i];
      final lOther$chapters$entry = lOther$chapters[i];
      if (l$chapters$entry != lOther$chapters$entry) {
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

extension UtilityExtension$Mutation$UpdateChapters$updateChapters
    on Mutation$UpdateChapters$updateChapters {
  CopyWith$Mutation$UpdateChapters$updateChapters<
          Mutation$UpdateChapters$updateChapters>
      get copyWith => CopyWith$Mutation$UpdateChapters$updateChapters(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdateChapters$updateChapters<TRes> {
  factory CopyWith$Mutation$UpdateChapters$updateChapters(
    Mutation$UpdateChapters$updateChapters instance,
    TRes Function(Mutation$UpdateChapters$updateChapters) then,
  ) = _CopyWithImpl$Mutation$UpdateChapters$updateChapters;

  factory CopyWith$Mutation$UpdateChapters$updateChapters.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateChapters$updateChapters;

  TRes call({
    List<Fragment$ChapterDto>? chapters,
    String? $__typename,
  });
  TRes chapters(
      Iterable<Fragment$ChapterDto> Function(
              Iterable<CopyWith$Fragment$ChapterDto<Fragment$ChapterDto>>)
          _fn);
}

class _CopyWithImpl$Mutation$UpdateChapters$updateChapters<TRes>
    implements CopyWith$Mutation$UpdateChapters$updateChapters<TRes> {
  _CopyWithImpl$Mutation$UpdateChapters$updateChapters(
    this._instance,
    this._then,
  );

  final Mutation$UpdateChapters$updateChapters _instance;

  final TRes Function(Mutation$UpdateChapters$updateChapters) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? chapters = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateChapters$updateChapters(
        chapters: chapters == _undefined || chapters == null
            ? _instance.chapters
            : (chapters as List<Fragment$ChapterDto>),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  TRes chapters(
          Iterable<Fragment$ChapterDto> Function(
                  Iterable<CopyWith$Fragment$ChapterDto<Fragment$ChapterDto>>)
              _fn) =>
      call(
          chapters:
              _fn(_instance.chapters.map((e) => CopyWith$Fragment$ChapterDto(
                    e,
                    (i) => i,
                  ))).toList());
}

class _CopyWithStubImpl$Mutation$UpdateChapters$updateChapters<TRes>
    implements CopyWith$Mutation$UpdateChapters$updateChapters<TRes> {
  _CopyWithStubImpl$Mutation$UpdateChapters$updateChapters(this._res);

  TRes _res;

  call({
    List<Fragment$ChapterDto>? chapters,
    String? $__typename,
  }) =>
      _res;

  chapters(_fn) => _res;
}

class Variables$Mutation$UpdateChapter {
  factory Variables$Mutation$UpdateChapter(
          {required Input$UpdateChapterInput input}) =>
      Variables$Mutation$UpdateChapter._({
        r'input': input,
      });

  Variables$Mutation$UpdateChapter._(this._$data);

  factory Variables$Mutation$UpdateChapter.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$input = data['input'];
    result$data['input'] =
        Input$UpdateChapterInput.fromJson((l$input as Map<String, dynamic>));
    return Variables$Mutation$UpdateChapter._(result$data);
  }

  Map<String, dynamic> _$data;

  Input$UpdateChapterInput get input =>
      (_$data['input'] as Input$UpdateChapterInput);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$input = input;
    result$data['input'] = l$input.toJson();
    return result$data;
  }

  CopyWith$Variables$Mutation$UpdateChapter<Variables$Mutation$UpdateChapter>
      get copyWith => CopyWith$Variables$Mutation$UpdateChapter(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$UpdateChapter ||
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

abstract class CopyWith$Variables$Mutation$UpdateChapter<TRes> {
  factory CopyWith$Variables$Mutation$UpdateChapter(
    Variables$Mutation$UpdateChapter instance,
    TRes Function(Variables$Mutation$UpdateChapter) then,
  ) = _CopyWithImpl$Variables$Mutation$UpdateChapter;

  factory CopyWith$Variables$Mutation$UpdateChapter.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$UpdateChapter;

  TRes call({Input$UpdateChapterInput? input});
}

class _CopyWithImpl$Variables$Mutation$UpdateChapter<TRes>
    implements CopyWith$Variables$Mutation$UpdateChapter<TRes> {
  _CopyWithImpl$Variables$Mutation$UpdateChapter(
    this._instance,
    this._then,
  );

  final Variables$Mutation$UpdateChapter _instance;

  final TRes Function(Variables$Mutation$UpdateChapter) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? input = _undefined}) =>
      _then(Variables$Mutation$UpdateChapter._({
        ..._instance._$data,
        if (input != _undefined && input != null)
          'input': (input as Input$UpdateChapterInput),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$UpdateChapter<TRes>
    implements CopyWith$Variables$Mutation$UpdateChapter<TRes> {
  _CopyWithStubImpl$Variables$Mutation$UpdateChapter(this._res);

  TRes _res;

  call({Input$UpdateChapterInput? input}) => _res;
}

class Mutation$UpdateChapter {
  Mutation$UpdateChapter({
    this.updateChapter,
    this.$__typename = 'Mutation',
  });

  factory Mutation$UpdateChapter.fromJson(Map<String, dynamic> json) {
    final l$updateChapter = json['updateChapter'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateChapter(
      updateChapter: l$updateChapter == null
          ? null
          : Mutation$UpdateChapter$updateChapter.fromJson(
              (l$updateChapter as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$UpdateChapter$updateChapter? updateChapter;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$updateChapter = updateChapter;
    _resultData['updateChapter'] = l$updateChapter?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$updateChapter = updateChapter;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$updateChapter,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$UpdateChapter || runtimeType != other.runtimeType) {
      return false;
    }
    final l$updateChapter = updateChapter;
    final lOther$updateChapter = other.updateChapter;
    if (l$updateChapter != lOther$updateChapter) {
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

extension UtilityExtension$Mutation$UpdateChapter on Mutation$UpdateChapter {
  CopyWith$Mutation$UpdateChapter<Mutation$UpdateChapter> get copyWith =>
      CopyWith$Mutation$UpdateChapter(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Mutation$UpdateChapter<TRes> {
  factory CopyWith$Mutation$UpdateChapter(
    Mutation$UpdateChapter instance,
    TRes Function(Mutation$UpdateChapter) then,
  ) = _CopyWithImpl$Mutation$UpdateChapter;

  factory CopyWith$Mutation$UpdateChapter.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateChapter;

  TRes call({
    Mutation$UpdateChapter$updateChapter? updateChapter,
    String? $__typename,
  });
  CopyWith$Mutation$UpdateChapter$updateChapter<TRes> get updateChapter;
}

class _CopyWithImpl$Mutation$UpdateChapter<TRes>
    implements CopyWith$Mutation$UpdateChapter<TRes> {
  _CopyWithImpl$Mutation$UpdateChapter(
    this._instance,
    this._then,
  );

  final Mutation$UpdateChapter _instance;

  final TRes Function(Mutation$UpdateChapter) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? updateChapter = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateChapter(
        updateChapter: updateChapter == _undefined
            ? _instance.updateChapter
            : (updateChapter as Mutation$UpdateChapter$updateChapter?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$UpdateChapter$updateChapter<TRes> get updateChapter {
    final local$updateChapter = _instance.updateChapter;
    return local$updateChapter == null
        ? CopyWith$Mutation$UpdateChapter$updateChapter.stub(_then(_instance))
        : CopyWith$Mutation$UpdateChapter$updateChapter(
            local$updateChapter, (e) => call(updateChapter: e));
  }
}

class _CopyWithStubImpl$Mutation$UpdateChapter<TRes>
    implements CopyWith$Mutation$UpdateChapter<TRes> {
  _CopyWithStubImpl$Mutation$UpdateChapter(this._res);

  TRes _res;

  call({
    Mutation$UpdateChapter$updateChapter? updateChapter,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$UpdateChapter$updateChapter<TRes> get updateChapter =>
      CopyWith$Mutation$UpdateChapter$updateChapter.stub(_res);
}

const documentNodeMutationUpdateChapter = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'UpdateChapter'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'input')),
        type: NamedTypeNode(
          name: NameNode(value: 'UpdateChapterInput'),
          isNonNull: true,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      )
    ],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'updateChapter'),
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
            name: NameNode(value: 'chapter'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: SelectionSetNode(selections: [
              FragmentSpreadNode(
                name: NameNode(value: 'ChapterDto'),
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
  fragmentDefinitionChapterDto,
]);
Mutation$UpdateChapter _parserFn$Mutation$UpdateChapter(
        Map<String, dynamic> data) =>
    Mutation$UpdateChapter.fromJson(data);
typedef OnMutationCompleted$Mutation$UpdateChapter = FutureOr<void> Function(
  Map<String, dynamic>?,
  Mutation$UpdateChapter?,
);

class Options$Mutation$UpdateChapter
    extends graphql.MutationOptions<Mutation$UpdateChapter> {
  Options$Mutation$UpdateChapter({
    String? operationName,
    required Variables$Mutation$UpdateChapter variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateChapter? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateChapter? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateChapter>? update,
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
                        : _parserFn$Mutation$UpdateChapter(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateChapter,
          parserFn: _parserFn$Mutation$UpdateChapter,
        );

  final OnMutationCompleted$Mutation$UpdateChapter? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$UpdateChapter
    extends graphql.WatchQueryOptions<Mutation$UpdateChapter> {
  WatchOptions$Mutation$UpdateChapter({
    String? operationName,
    required Variables$Mutation$UpdateChapter variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateChapter? typedOptimisticResult,
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
          document: documentNodeMutationUpdateChapter,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$UpdateChapter,
        );
}

extension ClientExtension$Mutation$UpdateChapter on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$UpdateChapter>> mutate$UpdateChapter(
          Options$Mutation$UpdateChapter options) async =>
      await this.mutate(options);

  graphql.ObservableQuery<Mutation$UpdateChapter> watchMutation$UpdateChapter(
          WatchOptions$Mutation$UpdateChapter options) =>
      this.watchMutation(options);
}

class Mutation$UpdateChapter$HookResult {
  Mutation$UpdateChapter$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$UpdateChapter runMutation;

  final graphql.QueryResult<Mutation$UpdateChapter> result;
}

Mutation$UpdateChapter$HookResult useMutation$UpdateChapter(
    [WidgetOptions$Mutation$UpdateChapter? options]) {
  final result = graphql_flutter
      .useMutation(options ?? WidgetOptions$Mutation$UpdateChapter());
  return Mutation$UpdateChapter$HookResult(
    (variables, {optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables.toJson(),
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$UpdateChapter> useWatchMutation$UpdateChapter(
        WatchOptions$Mutation$UpdateChapter options) =>
    graphql_flutter.useWatchMutation(options);

class WidgetOptions$Mutation$UpdateChapter
    extends graphql.MutationOptions<Mutation$UpdateChapter> {
  WidgetOptions$Mutation$UpdateChapter({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateChapter? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateChapter? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateChapter>? update,
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
                        : _parserFn$Mutation$UpdateChapter(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateChapter,
          parserFn: _parserFn$Mutation$UpdateChapter,
        );

  final OnMutationCompleted$Mutation$UpdateChapter? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$UpdateChapter
    = graphql.MultiSourceResult<Mutation$UpdateChapter> Function(
  Variables$Mutation$UpdateChapter, {
  Object? optimisticResult,
  Mutation$UpdateChapter? typedOptimisticResult,
});
typedef Builder$Mutation$UpdateChapter = widgets.Widget Function(
  RunMutation$Mutation$UpdateChapter,
  graphql.QueryResult<Mutation$UpdateChapter>?,
);

class Mutation$UpdateChapter$Widget
    extends graphql_flutter.Mutation<Mutation$UpdateChapter> {
  Mutation$UpdateChapter$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$UpdateChapter? options,
    required Builder$Mutation$UpdateChapter builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$UpdateChapter(),
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

class Mutation$UpdateChapter$updateChapter {
  Mutation$UpdateChapter$updateChapter({
    required this.chapter,
    this.$__typename = 'UpdateChapterPayload',
  });

  factory Mutation$UpdateChapter$updateChapter.fromJson(
      Map<String, dynamic> json) {
    final l$chapter = json['chapter'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateChapter$updateChapter(
      chapter:
          Fragment$ChapterDto.fromJson((l$chapter as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Fragment$ChapterDto chapter;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$chapter = chapter;
    _resultData['chapter'] = l$chapter.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$chapter = chapter;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$chapter,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$UpdateChapter$updateChapter ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$chapter = chapter;
    final lOther$chapter = other.chapter;
    if (l$chapter != lOther$chapter) {
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

extension UtilityExtension$Mutation$UpdateChapter$updateChapter
    on Mutation$UpdateChapter$updateChapter {
  CopyWith$Mutation$UpdateChapter$updateChapter<
          Mutation$UpdateChapter$updateChapter>
      get copyWith => CopyWith$Mutation$UpdateChapter$updateChapter(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdateChapter$updateChapter<TRes> {
  factory CopyWith$Mutation$UpdateChapter$updateChapter(
    Mutation$UpdateChapter$updateChapter instance,
    TRes Function(Mutation$UpdateChapter$updateChapter) then,
  ) = _CopyWithImpl$Mutation$UpdateChapter$updateChapter;

  factory CopyWith$Mutation$UpdateChapter$updateChapter.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateChapter$updateChapter;

  TRes call({
    Fragment$ChapterDto? chapter,
    String? $__typename,
  });
  CopyWith$Fragment$ChapterDto<TRes> get chapter;
}

class _CopyWithImpl$Mutation$UpdateChapter$updateChapter<TRes>
    implements CopyWith$Mutation$UpdateChapter$updateChapter<TRes> {
  _CopyWithImpl$Mutation$UpdateChapter$updateChapter(
    this._instance,
    this._then,
  );

  final Mutation$UpdateChapter$updateChapter _instance;

  final TRes Function(Mutation$UpdateChapter$updateChapter) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? chapter = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateChapter$updateChapter(
        chapter: chapter == _undefined || chapter == null
            ? _instance.chapter
            : (chapter as Fragment$ChapterDto),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Fragment$ChapterDto<TRes> get chapter {
    final local$chapter = _instance.chapter;
    return CopyWith$Fragment$ChapterDto(local$chapter, (e) => call(chapter: e));
  }
}

class _CopyWithStubImpl$Mutation$UpdateChapter$updateChapter<TRes>
    implements CopyWith$Mutation$UpdateChapter$updateChapter<TRes> {
  _CopyWithStubImpl$Mutation$UpdateChapter$updateChapter(this._res);

  TRes _res;

  call({
    Fragment$ChapterDto? chapter,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$ChapterDto<TRes> get chapter =>
      CopyWith$Fragment$ChapterDto.stub(_res);
}

class Variables$Mutation$DeleteDownloadedChapters {
  factory Variables$Mutation$DeleteDownloadedChapters(
          {required Input$DeleteDownloadedChaptersInput input}) =>
      Variables$Mutation$DeleteDownloadedChapters._({
        r'input': input,
      });

  Variables$Mutation$DeleteDownloadedChapters._(this._$data);

  factory Variables$Mutation$DeleteDownloadedChapters.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$input = data['input'];
    result$data['input'] = Input$DeleteDownloadedChaptersInput.fromJson(
        (l$input as Map<String, dynamic>));
    return Variables$Mutation$DeleteDownloadedChapters._(result$data);
  }

  Map<String, dynamic> _$data;

  Input$DeleteDownloadedChaptersInput get input =>
      (_$data['input'] as Input$DeleteDownloadedChaptersInput);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$input = input;
    result$data['input'] = l$input.toJson();
    return result$data;
  }

  CopyWith$Variables$Mutation$DeleteDownloadedChapters<
          Variables$Mutation$DeleteDownloadedChapters>
      get copyWith => CopyWith$Variables$Mutation$DeleteDownloadedChapters(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$DeleteDownloadedChapters ||
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

abstract class CopyWith$Variables$Mutation$DeleteDownloadedChapters<TRes> {
  factory CopyWith$Variables$Mutation$DeleteDownloadedChapters(
    Variables$Mutation$DeleteDownloadedChapters instance,
    TRes Function(Variables$Mutation$DeleteDownloadedChapters) then,
  ) = _CopyWithImpl$Variables$Mutation$DeleteDownloadedChapters;

  factory CopyWith$Variables$Mutation$DeleteDownloadedChapters.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$DeleteDownloadedChapters;

  TRes call({Input$DeleteDownloadedChaptersInput? input});
}

class _CopyWithImpl$Variables$Mutation$DeleteDownloadedChapters<TRes>
    implements CopyWith$Variables$Mutation$DeleteDownloadedChapters<TRes> {
  _CopyWithImpl$Variables$Mutation$DeleteDownloadedChapters(
    this._instance,
    this._then,
  );

  final Variables$Mutation$DeleteDownloadedChapters _instance;

  final TRes Function(Variables$Mutation$DeleteDownloadedChapters) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? input = _undefined}) =>
      _then(Variables$Mutation$DeleteDownloadedChapters._({
        ..._instance._$data,
        if (input != _undefined && input != null)
          'input': (input as Input$DeleteDownloadedChaptersInput),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$DeleteDownloadedChapters<TRes>
    implements CopyWith$Variables$Mutation$DeleteDownloadedChapters<TRes> {
  _CopyWithStubImpl$Variables$Mutation$DeleteDownloadedChapters(this._res);

  TRes _res;

  call({Input$DeleteDownloadedChaptersInput? input}) => _res;
}

class Mutation$DeleteDownloadedChapters {
  Mutation$DeleteDownloadedChapters({
    this.deleteDownloadedChapters,
    this.$__typename = 'Mutation',
  });

  factory Mutation$DeleteDownloadedChapters.fromJson(
      Map<String, dynamic> json) {
    final l$deleteDownloadedChapters = json['deleteDownloadedChapters'];
    final l$$__typename = json['__typename'];
    return Mutation$DeleteDownloadedChapters(
      deleteDownloadedChapters: l$deleteDownloadedChapters == null
          ? null
          : Mutation$DeleteDownloadedChapters$deleteDownloadedChapters.fromJson(
              (l$deleteDownloadedChapters as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$DeleteDownloadedChapters$deleteDownloadedChapters?
      deleteDownloadedChapters;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$deleteDownloadedChapters = deleteDownloadedChapters;
    _resultData['deleteDownloadedChapters'] =
        l$deleteDownloadedChapters?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$deleteDownloadedChapters = deleteDownloadedChapters;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$deleteDownloadedChapters,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$DeleteDownloadedChapters ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$deleteDownloadedChapters = deleteDownloadedChapters;
    final lOther$deleteDownloadedChapters = other.deleteDownloadedChapters;
    if (l$deleteDownloadedChapters != lOther$deleteDownloadedChapters) {
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

extension UtilityExtension$Mutation$DeleteDownloadedChapters
    on Mutation$DeleteDownloadedChapters {
  CopyWith$Mutation$DeleteDownloadedChapters<Mutation$DeleteDownloadedChapters>
      get copyWith => CopyWith$Mutation$DeleteDownloadedChapters(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$DeleteDownloadedChapters<TRes> {
  factory CopyWith$Mutation$DeleteDownloadedChapters(
    Mutation$DeleteDownloadedChapters instance,
    TRes Function(Mutation$DeleteDownloadedChapters) then,
  ) = _CopyWithImpl$Mutation$DeleteDownloadedChapters;

  factory CopyWith$Mutation$DeleteDownloadedChapters.stub(TRes res) =
      _CopyWithStubImpl$Mutation$DeleteDownloadedChapters;

  TRes call({
    Mutation$DeleteDownloadedChapters$deleteDownloadedChapters?
        deleteDownloadedChapters,
    String? $__typename,
  });
  CopyWith$Mutation$DeleteDownloadedChapters$deleteDownloadedChapters<TRes>
      get deleteDownloadedChapters;
}

class _CopyWithImpl$Mutation$DeleteDownloadedChapters<TRes>
    implements CopyWith$Mutation$DeleteDownloadedChapters<TRes> {
  _CopyWithImpl$Mutation$DeleteDownloadedChapters(
    this._instance,
    this._then,
  );

  final Mutation$DeleteDownloadedChapters _instance;

  final TRes Function(Mutation$DeleteDownloadedChapters) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? deleteDownloadedChapters = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$DeleteDownloadedChapters(
        deleteDownloadedChapters: deleteDownloadedChapters == _undefined
            ? _instance.deleteDownloadedChapters
            : (deleteDownloadedChapters
                as Mutation$DeleteDownloadedChapters$deleteDownloadedChapters?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$DeleteDownloadedChapters$deleteDownloadedChapters<TRes>
      get deleteDownloadedChapters {
    final local$deleteDownloadedChapters = _instance.deleteDownloadedChapters;
    return local$deleteDownloadedChapters == null
        ? CopyWith$Mutation$DeleteDownloadedChapters$deleteDownloadedChapters
            .stub(_then(_instance))
        : CopyWith$Mutation$DeleteDownloadedChapters$deleteDownloadedChapters(
            local$deleteDownloadedChapters,
            (e) => call(deleteDownloadedChapters: e));
  }
}

class _CopyWithStubImpl$Mutation$DeleteDownloadedChapters<TRes>
    implements CopyWith$Mutation$DeleteDownloadedChapters<TRes> {
  _CopyWithStubImpl$Mutation$DeleteDownloadedChapters(this._res);

  TRes _res;

  call({
    Mutation$DeleteDownloadedChapters$deleteDownloadedChapters?
        deleteDownloadedChapters,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$DeleteDownloadedChapters$deleteDownloadedChapters<TRes>
      get deleteDownloadedChapters =>
          CopyWith$Mutation$DeleteDownloadedChapters$deleteDownloadedChapters
              .stub(_res);
}

const documentNodeMutationDeleteDownloadedChapters = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'DeleteDownloadedChapters'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'input')),
        type: NamedTypeNode(
          name: NameNode(value: 'DeleteDownloadedChaptersInput'),
          isNonNull: true,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      )
    ],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'deleteDownloadedChapters'),
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
            name: NameNode(value: 'chapters'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: SelectionSetNode(selections: [
              FragmentSpreadNode(
                name: NameNode(value: 'ChapterDto'),
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
  fragmentDefinitionChapterDto,
]);
Mutation$DeleteDownloadedChapters _parserFn$Mutation$DeleteDownloadedChapters(
        Map<String, dynamic> data) =>
    Mutation$DeleteDownloadedChapters.fromJson(data);
typedef OnMutationCompleted$Mutation$DeleteDownloadedChapters = FutureOr<void>
    Function(
  Map<String, dynamic>?,
  Mutation$DeleteDownloadedChapters?,
);

class Options$Mutation$DeleteDownloadedChapters
    extends graphql.MutationOptions<Mutation$DeleteDownloadedChapters> {
  Options$Mutation$DeleteDownloadedChapters({
    String? operationName,
    required Variables$Mutation$DeleteDownloadedChapters variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$DeleteDownloadedChapters? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$DeleteDownloadedChapters? onCompleted,
    graphql.OnMutationUpdate<Mutation$DeleteDownloadedChapters>? update,
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
                        : _parserFn$Mutation$DeleteDownloadedChapters(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationDeleteDownloadedChapters,
          parserFn: _parserFn$Mutation$DeleteDownloadedChapters,
        );

  final OnMutationCompleted$Mutation$DeleteDownloadedChapters?
      onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$DeleteDownloadedChapters
    extends graphql.WatchQueryOptions<Mutation$DeleteDownloadedChapters> {
  WatchOptions$Mutation$DeleteDownloadedChapters({
    String? operationName,
    required Variables$Mutation$DeleteDownloadedChapters variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$DeleteDownloadedChapters? typedOptimisticResult,
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
          document: documentNodeMutationDeleteDownloadedChapters,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$DeleteDownloadedChapters,
        );
}

extension ClientExtension$Mutation$DeleteDownloadedChapters
    on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$DeleteDownloadedChapters>>
      mutate$DeleteDownloadedChapters(
              Options$Mutation$DeleteDownloadedChapters options) async =>
          await this.mutate(options);

  graphql.ObservableQuery<Mutation$DeleteDownloadedChapters>
      watchMutation$DeleteDownloadedChapters(
              WatchOptions$Mutation$DeleteDownloadedChapters options) =>
          this.watchMutation(options);
}

class Mutation$DeleteDownloadedChapters$HookResult {
  Mutation$DeleteDownloadedChapters$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$DeleteDownloadedChapters runMutation;

  final graphql.QueryResult<Mutation$DeleteDownloadedChapters> result;
}

Mutation$DeleteDownloadedChapters$HookResult
    useMutation$DeleteDownloadedChapters(
        [WidgetOptions$Mutation$DeleteDownloadedChapters? options]) {
  final result = graphql_flutter.useMutation(
      options ?? WidgetOptions$Mutation$DeleteDownloadedChapters());
  return Mutation$DeleteDownloadedChapters$HookResult(
    (variables, {optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables.toJson(),
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$DeleteDownloadedChapters>
    useWatchMutation$DeleteDownloadedChapters(
            WatchOptions$Mutation$DeleteDownloadedChapters options) =>
        graphql_flutter.useWatchMutation(options);

class WidgetOptions$Mutation$DeleteDownloadedChapters
    extends graphql.MutationOptions<Mutation$DeleteDownloadedChapters> {
  WidgetOptions$Mutation$DeleteDownloadedChapters({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$DeleteDownloadedChapters? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$DeleteDownloadedChapters? onCompleted,
    graphql.OnMutationUpdate<Mutation$DeleteDownloadedChapters>? update,
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
                        : _parserFn$Mutation$DeleteDownloadedChapters(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationDeleteDownloadedChapters,
          parserFn: _parserFn$Mutation$DeleteDownloadedChapters,
        );

  final OnMutationCompleted$Mutation$DeleteDownloadedChapters?
      onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$DeleteDownloadedChapters
    = graphql.MultiSourceResult<Mutation$DeleteDownloadedChapters> Function(
  Variables$Mutation$DeleteDownloadedChapters, {
  Object? optimisticResult,
  Mutation$DeleteDownloadedChapters? typedOptimisticResult,
});
typedef Builder$Mutation$DeleteDownloadedChapters = widgets.Widget Function(
  RunMutation$Mutation$DeleteDownloadedChapters,
  graphql.QueryResult<Mutation$DeleteDownloadedChapters>?,
);

class Mutation$DeleteDownloadedChapters$Widget
    extends graphql_flutter.Mutation<Mutation$DeleteDownloadedChapters> {
  Mutation$DeleteDownloadedChapters$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$DeleteDownloadedChapters? options,
    required Builder$Mutation$DeleteDownloadedChapters builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$DeleteDownloadedChapters(),
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

class Mutation$DeleteDownloadedChapters$deleteDownloadedChapters {
  Mutation$DeleteDownloadedChapters$deleteDownloadedChapters({
    required this.chapters,
    this.$__typename = 'DeleteDownloadedChaptersPayload',
  });

  factory Mutation$DeleteDownloadedChapters$deleteDownloadedChapters.fromJson(
      Map<String, dynamic> json) {
    final l$chapters = json['chapters'];
    final l$$__typename = json['__typename'];
    return Mutation$DeleteDownloadedChapters$deleteDownloadedChapters(
      chapters: (l$chapters as List<dynamic>)
          .map((e) => Fragment$ChapterDto.fromJson((e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final List<Fragment$ChapterDto> chapters;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$chapters = chapters;
    _resultData['chapters'] = l$chapters.map((e) => e.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$chapters = chapters;
    final l$$__typename = $__typename;
    return Object.hashAll([
      Object.hashAll(l$chapters.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$DeleteDownloadedChapters$deleteDownloadedChapters ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$chapters = chapters;
    final lOther$chapters = other.chapters;
    if (l$chapters.length != lOther$chapters.length) {
      return false;
    }
    for (int i = 0; i < l$chapters.length; i++) {
      final l$chapters$entry = l$chapters[i];
      final lOther$chapters$entry = lOther$chapters[i];
      if (l$chapters$entry != lOther$chapters$entry) {
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

extension UtilityExtension$Mutation$DeleteDownloadedChapters$deleteDownloadedChapters
    on Mutation$DeleteDownloadedChapters$deleteDownloadedChapters {
  CopyWith$Mutation$DeleteDownloadedChapters$deleteDownloadedChapters<
          Mutation$DeleteDownloadedChapters$deleteDownloadedChapters>
      get copyWith =>
          CopyWith$Mutation$DeleteDownloadedChapters$deleteDownloadedChapters(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$DeleteDownloadedChapters$deleteDownloadedChapters<
    TRes> {
  factory CopyWith$Mutation$DeleteDownloadedChapters$deleteDownloadedChapters(
    Mutation$DeleteDownloadedChapters$deleteDownloadedChapters instance,
    TRes Function(Mutation$DeleteDownloadedChapters$deleteDownloadedChapters)
        then,
  ) = _CopyWithImpl$Mutation$DeleteDownloadedChapters$deleteDownloadedChapters;

  factory CopyWith$Mutation$DeleteDownloadedChapters$deleteDownloadedChapters.stub(
          TRes res) =
      _CopyWithStubImpl$Mutation$DeleteDownloadedChapters$deleteDownloadedChapters;

  TRes call({
    List<Fragment$ChapterDto>? chapters,
    String? $__typename,
  });
  TRes chapters(
      Iterable<Fragment$ChapterDto> Function(
              Iterable<CopyWith$Fragment$ChapterDto<Fragment$ChapterDto>>)
          _fn);
}

class _CopyWithImpl$Mutation$DeleteDownloadedChapters$deleteDownloadedChapters<
        TRes>
    implements
        CopyWith$Mutation$DeleteDownloadedChapters$deleteDownloadedChapters<
            TRes> {
  _CopyWithImpl$Mutation$DeleteDownloadedChapters$deleteDownloadedChapters(
    this._instance,
    this._then,
  );

  final Mutation$DeleteDownloadedChapters$deleteDownloadedChapters _instance;

  final TRes Function(
      Mutation$DeleteDownloadedChapters$deleteDownloadedChapters) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? chapters = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$DeleteDownloadedChapters$deleteDownloadedChapters(
        chapters: chapters == _undefined || chapters == null
            ? _instance.chapters
            : (chapters as List<Fragment$ChapterDto>),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  TRes chapters(
          Iterable<Fragment$ChapterDto> Function(
                  Iterable<CopyWith$Fragment$ChapterDto<Fragment$ChapterDto>>)
              _fn) =>
      call(
          chapters:
              _fn(_instance.chapters.map((e) => CopyWith$Fragment$ChapterDto(
                    e,
                    (i) => i,
                  ))).toList());
}

class _CopyWithStubImpl$Mutation$DeleteDownloadedChapters$deleteDownloadedChapters<
        TRes>
    implements
        CopyWith$Mutation$DeleteDownloadedChapters$deleteDownloadedChapters<
            TRes> {
  _CopyWithStubImpl$Mutation$DeleteDownloadedChapters$deleteDownloadedChapters(
      this._res);

  TRes _res;

  call({
    List<Fragment$ChapterDto>? chapters,
    String? $__typename,
  }) =>
      _res;

  chapters(_fn) => _res;
}

class Variables$Mutation$SetMangaMeta {
  factory Variables$Mutation$SetMangaMeta(
          {required Input$SetMangaMetaInput input}) =>
      Variables$Mutation$SetMangaMeta._({
        r'input': input,
      });

  Variables$Mutation$SetMangaMeta._(this._$data);

  factory Variables$Mutation$SetMangaMeta.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$input = data['input'];
    result$data['input'] =
        Input$SetMangaMetaInput.fromJson((l$input as Map<String, dynamic>));
    return Variables$Mutation$SetMangaMeta._(result$data);
  }

  Map<String, dynamic> _$data;

  Input$SetMangaMetaInput get input =>
      (_$data['input'] as Input$SetMangaMetaInput);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$input = input;
    result$data['input'] = l$input.toJson();
    return result$data;
  }

  CopyWith$Variables$Mutation$SetMangaMeta<Variables$Mutation$SetMangaMeta>
      get copyWith => CopyWith$Variables$Mutation$SetMangaMeta(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$SetMangaMeta ||
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

abstract class CopyWith$Variables$Mutation$SetMangaMeta<TRes> {
  factory CopyWith$Variables$Mutation$SetMangaMeta(
    Variables$Mutation$SetMangaMeta instance,
    TRes Function(Variables$Mutation$SetMangaMeta) then,
  ) = _CopyWithImpl$Variables$Mutation$SetMangaMeta;

  factory CopyWith$Variables$Mutation$SetMangaMeta.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$SetMangaMeta;

  TRes call({Input$SetMangaMetaInput? input});
}

class _CopyWithImpl$Variables$Mutation$SetMangaMeta<TRes>
    implements CopyWith$Variables$Mutation$SetMangaMeta<TRes> {
  _CopyWithImpl$Variables$Mutation$SetMangaMeta(
    this._instance,
    this._then,
  );

  final Variables$Mutation$SetMangaMeta _instance;

  final TRes Function(Variables$Mutation$SetMangaMeta) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? input = _undefined}) =>
      _then(Variables$Mutation$SetMangaMeta._({
        ..._instance._$data,
        if (input != _undefined && input != null)
          'input': (input as Input$SetMangaMetaInput),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$SetMangaMeta<TRes>
    implements CopyWith$Variables$Mutation$SetMangaMeta<TRes> {
  _CopyWithStubImpl$Variables$Mutation$SetMangaMeta(this._res);

  TRes _res;

  call({Input$SetMangaMetaInput? input}) => _res;
}

class Mutation$SetMangaMeta {
  Mutation$SetMangaMeta({
    this.setMangaMeta,
    this.$__typename = 'Mutation',
  });

  factory Mutation$SetMangaMeta.fromJson(Map<String, dynamic> json) {
    final l$setMangaMeta = json['setMangaMeta'];
    final l$$__typename = json['__typename'];
    return Mutation$SetMangaMeta(
      setMangaMeta: l$setMangaMeta == null
          ? null
          : Mutation$SetMangaMeta$setMangaMeta.fromJson(
              (l$setMangaMeta as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$SetMangaMeta$setMangaMeta? setMangaMeta;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$setMangaMeta = setMangaMeta;
    _resultData['setMangaMeta'] = l$setMangaMeta?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$setMangaMeta = setMangaMeta;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$setMangaMeta,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$SetMangaMeta || runtimeType != other.runtimeType) {
      return false;
    }
    final l$setMangaMeta = setMangaMeta;
    final lOther$setMangaMeta = other.setMangaMeta;
    if (l$setMangaMeta != lOther$setMangaMeta) {
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

extension UtilityExtension$Mutation$SetMangaMeta on Mutation$SetMangaMeta {
  CopyWith$Mutation$SetMangaMeta<Mutation$SetMangaMeta> get copyWith =>
      CopyWith$Mutation$SetMangaMeta(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Mutation$SetMangaMeta<TRes> {
  factory CopyWith$Mutation$SetMangaMeta(
    Mutation$SetMangaMeta instance,
    TRes Function(Mutation$SetMangaMeta) then,
  ) = _CopyWithImpl$Mutation$SetMangaMeta;

  factory CopyWith$Mutation$SetMangaMeta.stub(TRes res) =
      _CopyWithStubImpl$Mutation$SetMangaMeta;

  TRes call({
    Mutation$SetMangaMeta$setMangaMeta? setMangaMeta,
    String? $__typename,
  });
  CopyWith$Mutation$SetMangaMeta$setMangaMeta<TRes> get setMangaMeta;
}

class _CopyWithImpl$Mutation$SetMangaMeta<TRes>
    implements CopyWith$Mutation$SetMangaMeta<TRes> {
  _CopyWithImpl$Mutation$SetMangaMeta(
    this._instance,
    this._then,
  );

  final Mutation$SetMangaMeta _instance;

  final TRes Function(Mutation$SetMangaMeta) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? setMangaMeta = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$SetMangaMeta(
        setMangaMeta: setMangaMeta == _undefined
            ? _instance.setMangaMeta
            : (setMangaMeta as Mutation$SetMangaMeta$setMangaMeta?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$SetMangaMeta$setMangaMeta<TRes> get setMangaMeta {
    final local$setMangaMeta = _instance.setMangaMeta;
    return local$setMangaMeta == null
        ? CopyWith$Mutation$SetMangaMeta$setMangaMeta.stub(_then(_instance))
        : CopyWith$Mutation$SetMangaMeta$setMangaMeta(
            local$setMangaMeta, (e) => call(setMangaMeta: e));
  }
}

class _CopyWithStubImpl$Mutation$SetMangaMeta<TRes>
    implements CopyWith$Mutation$SetMangaMeta<TRes> {
  _CopyWithStubImpl$Mutation$SetMangaMeta(this._res);

  TRes _res;

  call({
    Mutation$SetMangaMeta$setMangaMeta? setMangaMeta,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$SetMangaMeta$setMangaMeta<TRes> get setMangaMeta =>
      CopyWith$Mutation$SetMangaMeta$setMangaMeta.stub(_res);
}

const documentNodeMutationSetMangaMeta = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'SetMangaMeta'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'input')),
        type: NamedTypeNode(
          name: NameNode(value: 'SetMangaMetaInput'),
          isNonNull: true,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      )
    ],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'setMangaMeta'),
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
            name: NameNode(value: 'meta'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: SelectionSetNode(selections: [
              FragmentSpreadNode(
                name: NameNode(value: 'MangaMetaDto'),
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
  fragmentDefinitionMangaMetaDto,
]);
Mutation$SetMangaMeta _parserFn$Mutation$SetMangaMeta(
        Map<String, dynamic> data) =>
    Mutation$SetMangaMeta.fromJson(data);
typedef OnMutationCompleted$Mutation$SetMangaMeta = FutureOr<void> Function(
  Map<String, dynamic>?,
  Mutation$SetMangaMeta?,
);

class Options$Mutation$SetMangaMeta
    extends graphql.MutationOptions<Mutation$SetMangaMeta> {
  Options$Mutation$SetMangaMeta({
    String? operationName,
    required Variables$Mutation$SetMangaMeta variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$SetMangaMeta? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$SetMangaMeta? onCompleted,
    graphql.OnMutationUpdate<Mutation$SetMangaMeta>? update,
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
                    data == null ? null : _parserFn$Mutation$SetMangaMeta(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationSetMangaMeta,
          parserFn: _parserFn$Mutation$SetMangaMeta,
        );

  final OnMutationCompleted$Mutation$SetMangaMeta? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$SetMangaMeta
    extends graphql.WatchQueryOptions<Mutation$SetMangaMeta> {
  WatchOptions$Mutation$SetMangaMeta({
    String? operationName,
    required Variables$Mutation$SetMangaMeta variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$SetMangaMeta? typedOptimisticResult,
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
          document: documentNodeMutationSetMangaMeta,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$SetMangaMeta,
        );
}

extension ClientExtension$Mutation$SetMangaMeta on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$SetMangaMeta>> mutate$SetMangaMeta(
          Options$Mutation$SetMangaMeta options) async =>
      await this.mutate(options);

  graphql.ObservableQuery<Mutation$SetMangaMeta> watchMutation$SetMangaMeta(
          WatchOptions$Mutation$SetMangaMeta options) =>
      this.watchMutation(options);
}

class Mutation$SetMangaMeta$HookResult {
  Mutation$SetMangaMeta$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$SetMangaMeta runMutation;

  final graphql.QueryResult<Mutation$SetMangaMeta> result;
}

Mutation$SetMangaMeta$HookResult useMutation$SetMangaMeta(
    [WidgetOptions$Mutation$SetMangaMeta? options]) {
  final result = graphql_flutter
      .useMutation(options ?? WidgetOptions$Mutation$SetMangaMeta());
  return Mutation$SetMangaMeta$HookResult(
    (variables, {optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables.toJson(),
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$SetMangaMeta> useWatchMutation$SetMangaMeta(
        WatchOptions$Mutation$SetMangaMeta options) =>
    graphql_flutter.useWatchMutation(options);

class WidgetOptions$Mutation$SetMangaMeta
    extends graphql.MutationOptions<Mutation$SetMangaMeta> {
  WidgetOptions$Mutation$SetMangaMeta({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$SetMangaMeta? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$SetMangaMeta? onCompleted,
    graphql.OnMutationUpdate<Mutation$SetMangaMeta>? update,
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
                    data == null ? null : _parserFn$Mutation$SetMangaMeta(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationSetMangaMeta,
          parserFn: _parserFn$Mutation$SetMangaMeta,
        );

  final OnMutationCompleted$Mutation$SetMangaMeta? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$SetMangaMeta
    = graphql.MultiSourceResult<Mutation$SetMangaMeta> Function(
  Variables$Mutation$SetMangaMeta, {
  Object? optimisticResult,
  Mutation$SetMangaMeta? typedOptimisticResult,
});
typedef Builder$Mutation$SetMangaMeta = widgets.Widget Function(
  RunMutation$Mutation$SetMangaMeta,
  graphql.QueryResult<Mutation$SetMangaMeta>?,
);

class Mutation$SetMangaMeta$Widget
    extends graphql_flutter.Mutation<Mutation$SetMangaMeta> {
  Mutation$SetMangaMeta$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$SetMangaMeta? options,
    required Builder$Mutation$SetMangaMeta builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$SetMangaMeta(),
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

class Mutation$SetMangaMeta$setMangaMeta {
  Mutation$SetMangaMeta$setMangaMeta({
    required this.meta,
    this.$__typename = 'SetMangaMetaPayload',
  });

  factory Mutation$SetMangaMeta$setMangaMeta.fromJson(
      Map<String, dynamic> json) {
    final l$meta = json['meta'];
    final l$$__typename = json['__typename'];
    return Mutation$SetMangaMeta$setMangaMeta(
      meta: Fragment$MangaMetaDto.fromJson((l$meta as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Fragment$MangaMetaDto meta;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$meta = meta;
    _resultData['meta'] = l$meta.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$meta = meta;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$meta,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$SetMangaMeta$setMangaMeta ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$meta = meta;
    final lOther$meta = other.meta;
    if (l$meta != lOther$meta) {
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

extension UtilityExtension$Mutation$SetMangaMeta$setMangaMeta
    on Mutation$SetMangaMeta$setMangaMeta {
  CopyWith$Mutation$SetMangaMeta$setMangaMeta<
          Mutation$SetMangaMeta$setMangaMeta>
      get copyWith => CopyWith$Mutation$SetMangaMeta$setMangaMeta(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$SetMangaMeta$setMangaMeta<TRes> {
  factory CopyWith$Mutation$SetMangaMeta$setMangaMeta(
    Mutation$SetMangaMeta$setMangaMeta instance,
    TRes Function(Mutation$SetMangaMeta$setMangaMeta) then,
  ) = _CopyWithImpl$Mutation$SetMangaMeta$setMangaMeta;

  factory CopyWith$Mutation$SetMangaMeta$setMangaMeta.stub(TRes res) =
      _CopyWithStubImpl$Mutation$SetMangaMeta$setMangaMeta;

  TRes call({
    Fragment$MangaMetaDto? meta,
    String? $__typename,
  });
  CopyWith$Fragment$MangaMetaDto<TRes> get meta;
}

class _CopyWithImpl$Mutation$SetMangaMeta$setMangaMeta<TRes>
    implements CopyWith$Mutation$SetMangaMeta$setMangaMeta<TRes> {
  _CopyWithImpl$Mutation$SetMangaMeta$setMangaMeta(
    this._instance,
    this._then,
  );

  final Mutation$SetMangaMeta$setMangaMeta _instance;

  final TRes Function(Mutation$SetMangaMeta$setMangaMeta) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? meta = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$SetMangaMeta$setMangaMeta(
        meta: meta == _undefined || meta == null
            ? _instance.meta
            : (meta as Fragment$MangaMetaDto),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Fragment$MangaMetaDto<TRes> get meta {
    final local$meta = _instance.meta;
    return CopyWith$Fragment$MangaMetaDto(local$meta, (e) => call(meta: e));
  }
}

class _CopyWithStubImpl$Mutation$SetMangaMeta$setMangaMeta<TRes>
    implements CopyWith$Mutation$SetMangaMeta$setMangaMeta<TRes> {
  _CopyWithStubImpl$Mutation$SetMangaMeta$setMangaMeta(this._res);

  TRes _res;

  call({
    Fragment$MangaMetaDto? meta,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$MangaMetaDto<TRes> get meta =>
      CopyWith$Fragment$MangaMetaDto.stub(_res);
}

class Variables$Mutation$GetChaptersByMangaId {
  factory Variables$Mutation$GetChaptersByMangaId(
          {required Input$FetchChaptersInput input}) =>
      Variables$Mutation$GetChaptersByMangaId._({
        r'input': input,
      });

  Variables$Mutation$GetChaptersByMangaId._(this._$data);

  factory Variables$Mutation$GetChaptersByMangaId.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$input = data['input'];
    result$data['input'] =
        Input$FetchChaptersInput.fromJson((l$input as Map<String, dynamic>));
    return Variables$Mutation$GetChaptersByMangaId._(result$data);
  }

  Map<String, dynamic> _$data;

  Input$FetchChaptersInput get input =>
      (_$data['input'] as Input$FetchChaptersInput);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$input = input;
    result$data['input'] = l$input.toJson();
    return result$data;
  }

  CopyWith$Variables$Mutation$GetChaptersByMangaId<
          Variables$Mutation$GetChaptersByMangaId>
      get copyWith => CopyWith$Variables$Mutation$GetChaptersByMangaId(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$GetChaptersByMangaId ||
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

abstract class CopyWith$Variables$Mutation$GetChaptersByMangaId<TRes> {
  factory CopyWith$Variables$Mutation$GetChaptersByMangaId(
    Variables$Mutation$GetChaptersByMangaId instance,
    TRes Function(Variables$Mutation$GetChaptersByMangaId) then,
  ) = _CopyWithImpl$Variables$Mutation$GetChaptersByMangaId;

  factory CopyWith$Variables$Mutation$GetChaptersByMangaId.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$GetChaptersByMangaId;

  TRes call({Input$FetchChaptersInput? input});
}

class _CopyWithImpl$Variables$Mutation$GetChaptersByMangaId<TRes>
    implements CopyWith$Variables$Mutation$GetChaptersByMangaId<TRes> {
  _CopyWithImpl$Variables$Mutation$GetChaptersByMangaId(
    this._instance,
    this._then,
  );

  final Variables$Mutation$GetChaptersByMangaId _instance;

  final TRes Function(Variables$Mutation$GetChaptersByMangaId) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? input = _undefined}) =>
      _then(Variables$Mutation$GetChaptersByMangaId._({
        ..._instance._$data,
        if (input != _undefined && input != null)
          'input': (input as Input$FetchChaptersInput),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$GetChaptersByMangaId<TRes>
    implements CopyWith$Variables$Mutation$GetChaptersByMangaId<TRes> {
  _CopyWithStubImpl$Variables$Mutation$GetChaptersByMangaId(this._res);

  TRes _res;

  call({Input$FetchChaptersInput? input}) => _res;
}

class Mutation$GetChaptersByMangaId {
  Mutation$GetChaptersByMangaId({
    this.fetchChapters,
    this.$__typename = 'Mutation',
  });

  factory Mutation$GetChaptersByMangaId.fromJson(Map<String, dynamic> json) {
    final l$fetchChapters = json['fetchChapters'];
    final l$$__typename = json['__typename'];
    return Mutation$GetChaptersByMangaId(
      fetchChapters: l$fetchChapters == null
          ? null
          : Mutation$GetChaptersByMangaId$fetchChapters.fromJson(
              (l$fetchChapters as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$GetChaptersByMangaId$fetchChapters? fetchChapters;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$fetchChapters = fetchChapters;
    _resultData['fetchChapters'] = l$fetchChapters?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$fetchChapters = fetchChapters;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$fetchChapters,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$GetChaptersByMangaId ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$fetchChapters = fetchChapters;
    final lOther$fetchChapters = other.fetchChapters;
    if (l$fetchChapters != lOther$fetchChapters) {
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

extension UtilityExtension$Mutation$GetChaptersByMangaId
    on Mutation$GetChaptersByMangaId {
  CopyWith$Mutation$GetChaptersByMangaId<Mutation$GetChaptersByMangaId>
      get copyWith => CopyWith$Mutation$GetChaptersByMangaId(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$GetChaptersByMangaId<TRes> {
  factory CopyWith$Mutation$GetChaptersByMangaId(
    Mutation$GetChaptersByMangaId instance,
    TRes Function(Mutation$GetChaptersByMangaId) then,
  ) = _CopyWithImpl$Mutation$GetChaptersByMangaId;

  factory CopyWith$Mutation$GetChaptersByMangaId.stub(TRes res) =
      _CopyWithStubImpl$Mutation$GetChaptersByMangaId;

  TRes call({
    Mutation$GetChaptersByMangaId$fetchChapters? fetchChapters,
    String? $__typename,
  });
  CopyWith$Mutation$GetChaptersByMangaId$fetchChapters<TRes> get fetchChapters;
}

class _CopyWithImpl$Mutation$GetChaptersByMangaId<TRes>
    implements CopyWith$Mutation$GetChaptersByMangaId<TRes> {
  _CopyWithImpl$Mutation$GetChaptersByMangaId(
    this._instance,
    this._then,
  );

  final Mutation$GetChaptersByMangaId _instance;

  final TRes Function(Mutation$GetChaptersByMangaId) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? fetchChapters = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$GetChaptersByMangaId(
        fetchChapters: fetchChapters == _undefined
            ? _instance.fetchChapters
            : (fetchChapters as Mutation$GetChaptersByMangaId$fetchChapters?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$GetChaptersByMangaId$fetchChapters<TRes> get fetchChapters {
    final local$fetchChapters = _instance.fetchChapters;
    return local$fetchChapters == null
        ? CopyWith$Mutation$GetChaptersByMangaId$fetchChapters.stub(
            _then(_instance))
        : CopyWith$Mutation$GetChaptersByMangaId$fetchChapters(
            local$fetchChapters, (e) => call(fetchChapters: e));
  }
}

class _CopyWithStubImpl$Mutation$GetChaptersByMangaId<TRes>
    implements CopyWith$Mutation$GetChaptersByMangaId<TRes> {
  _CopyWithStubImpl$Mutation$GetChaptersByMangaId(this._res);

  TRes _res;

  call({
    Mutation$GetChaptersByMangaId$fetchChapters? fetchChapters,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$GetChaptersByMangaId$fetchChapters<TRes>
      get fetchChapters =>
          CopyWith$Mutation$GetChaptersByMangaId$fetchChapters.stub(_res);
}

const documentNodeMutationGetChaptersByMangaId = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'GetChaptersByMangaId'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'input')),
        type: NamedTypeNode(
          name: NameNode(value: 'FetchChaptersInput'),
          isNonNull: true,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      )
    ],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'fetchChapters'),
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
            name: NameNode(value: 'chapters'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: SelectionSetNode(selections: [
              FragmentSpreadNode(
                name: NameNode(value: 'ChapterDto'),
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
  fragmentDefinitionChapterDto,
]);
Mutation$GetChaptersByMangaId _parserFn$Mutation$GetChaptersByMangaId(
        Map<String, dynamic> data) =>
    Mutation$GetChaptersByMangaId.fromJson(data);
typedef OnMutationCompleted$Mutation$GetChaptersByMangaId = FutureOr<void>
    Function(
  Map<String, dynamic>?,
  Mutation$GetChaptersByMangaId?,
);

class Options$Mutation$GetChaptersByMangaId
    extends graphql.MutationOptions<Mutation$GetChaptersByMangaId> {
  Options$Mutation$GetChaptersByMangaId({
    String? operationName,
    required Variables$Mutation$GetChaptersByMangaId variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$GetChaptersByMangaId? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$GetChaptersByMangaId? onCompleted,
    graphql.OnMutationUpdate<Mutation$GetChaptersByMangaId>? update,
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
                        : _parserFn$Mutation$GetChaptersByMangaId(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationGetChaptersByMangaId,
          parserFn: _parserFn$Mutation$GetChaptersByMangaId,
        );

  final OnMutationCompleted$Mutation$GetChaptersByMangaId?
      onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$GetChaptersByMangaId
    extends graphql.WatchQueryOptions<Mutation$GetChaptersByMangaId> {
  WatchOptions$Mutation$GetChaptersByMangaId({
    String? operationName,
    required Variables$Mutation$GetChaptersByMangaId variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$GetChaptersByMangaId? typedOptimisticResult,
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
          document: documentNodeMutationGetChaptersByMangaId,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$GetChaptersByMangaId,
        );
}

extension ClientExtension$Mutation$GetChaptersByMangaId
    on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$GetChaptersByMangaId>>
      mutate$GetChaptersByMangaId(
              Options$Mutation$GetChaptersByMangaId options) async =>
          await this.mutate(options);

  graphql.ObservableQuery<Mutation$GetChaptersByMangaId>
      watchMutation$GetChaptersByMangaId(
              WatchOptions$Mutation$GetChaptersByMangaId options) =>
          this.watchMutation(options);
}

class Mutation$GetChaptersByMangaId$HookResult {
  Mutation$GetChaptersByMangaId$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$GetChaptersByMangaId runMutation;

  final graphql.QueryResult<Mutation$GetChaptersByMangaId> result;
}

Mutation$GetChaptersByMangaId$HookResult useMutation$GetChaptersByMangaId(
    [WidgetOptions$Mutation$GetChaptersByMangaId? options]) {
  final result = graphql_flutter
      .useMutation(options ?? WidgetOptions$Mutation$GetChaptersByMangaId());
  return Mutation$GetChaptersByMangaId$HookResult(
    (variables, {optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables.toJson(),
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$GetChaptersByMangaId>
    useWatchMutation$GetChaptersByMangaId(
            WatchOptions$Mutation$GetChaptersByMangaId options) =>
        graphql_flutter.useWatchMutation(options);

class WidgetOptions$Mutation$GetChaptersByMangaId
    extends graphql.MutationOptions<Mutation$GetChaptersByMangaId> {
  WidgetOptions$Mutation$GetChaptersByMangaId({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$GetChaptersByMangaId? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$GetChaptersByMangaId? onCompleted,
    graphql.OnMutationUpdate<Mutation$GetChaptersByMangaId>? update,
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
                        : _parserFn$Mutation$GetChaptersByMangaId(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationGetChaptersByMangaId,
          parserFn: _parserFn$Mutation$GetChaptersByMangaId,
        );

  final OnMutationCompleted$Mutation$GetChaptersByMangaId?
      onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$GetChaptersByMangaId
    = graphql.MultiSourceResult<Mutation$GetChaptersByMangaId> Function(
  Variables$Mutation$GetChaptersByMangaId, {
  Object? optimisticResult,
  Mutation$GetChaptersByMangaId? typedOptimisticResult,
});
typedef Builder$Mutation$GetChaptersByMangaId = widgets.Widget Function(
  RunMutation$Mutation$GetChaptersByMangaId,
  graphql.QueryResult<Mutation$GetChaptersByMangaId>?,
);

class Mutation$GetChaptersByMangaId$Widget
    extends graphql_flutter.Mutation<Mutation$GetChaptersByMangaId> {
  Mutation$GetChaptersByMangaId$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$GetChaptersByMangaId? options,
    required Builder$Mutation$GetChaptersByMangaId builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$GetChaptersByMangaId(),
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

class Mutation$GetChaptersByMangaId$fetchChapters {
  Mutation$GetChaptersByMangaId$fetchChapters({
    required this.chapters,
    this.$__typename = 'FetchChaptersPayload',
  });

  factory Mutation$GetChaptersByMangaId$fetchChapters.fromJson(
      Map<String, dynamic> json) {
    final l$chapters = json['chapters'];
    final l$$__typename = json['__typename'];
    return Mutation$GetChaptersByMangaId$fetchChapters(
      chapters: (l$chapters as List<dynamic>)
          .map((e) => Fragment$ChapterDto.fromJson((e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final List<Fragment$ChapterDto> chapters;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$chapters = chapters;
    _resultData['chapters'] = l$chapters.map((e) => e.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$chapters = chapters;
    final l$$__typename = $__typename;
    return Object.hashAll([
      Object.hashAll(l$chapters.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$GetChaptersByMangaId$fetchChapters ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$chapters = chapters;
    final lOther$chapters = other.chapters;
    if (l$chapters.length != lOther$chapters.length) {
      return false;
    }
    for (int i = 0; i < l$chapters.length; i++) {
      final l$chapters$entry = l$chapters[i];
      final lOther$chapters$entry = lOther$chapters[i];
      if (l$chapters$entry != lOther$chapters$entry) {
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

extension UtilityExtension$Mutation$GetChaptersByMangaId$fetchChapters
    on Mutation$GetChaptersByMangaId$fetchChapters {
  CopyWith$Mutation$GetChaptersByMangaId$fetchChapters<
          Mutation$GetChaptersByMangaId$fetchChapters>
      get copyWith => CopyWith$Mutation$GetChaptersByMangaId$fetchChapters(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$GetChaptersByMangaId$fetchChapters<TRes> {
  factory CopyWith$Mutation$GetChaptersByMangaId$fetchChapters(
    Mutation$GetChaptersByMangaId$fetchChapters instance,
    TRes Function(Mutation$GetChaptersByMangaId$fetchChapters) then,
  ) = _CopyWithImpl$Mutation$GetChaptersByMangaId$fetchChapters;

  factory CopyWith$Mutation$GetChaptersByMangaId$fetchChapters.stub(TRes res) =
      _CopyWithStubImpl$Mutation$GetChaptersByMangaId$fetchChapters;

  TRes call({
    List<Fragment$ChapterDto>? chapters,
    String? $__typename,
  });
  TRes chapters(
      Iterable<Fragment$ChapterDto> Function(
              Iterable<CopyWith$Fragment$ChapterDto<Fragment$ChapterDto>>)
          _fn);
}

class _CopyWithImpl$Mutation$GetChaptersByMangaId$fetchChapters<TRes>
    implements CopyWith$Mutation$GetChaptersByMangaId$fetchChapters<TRes> {
  _CopyWithImpl$Mutation$GetChaptersByMangaId$fetchChapters(
    this._instance,
    this._then,
  );

  final Mutation$GetChaptersByMangaId$fetchChapters _instance;

  final TRes Function(Mutation$GetChaptersByMangaId$fetchChapters) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? chapters = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$GetChaptersByMangaId$fetchChapters(
        chapters: chapters == _undefined || chapters == null
            ? _instance.chapters
            : (chapters as List<Fragment$ChapterDto>),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  TRes chapters(
          Iterable<Fragment$ChapterDto> Function(
                  Iterable<CopyWith$Fragment$ChapterDto<Fragment$ChapterDto>>)
              _fn) =>
      call(
          chapters:
              _fn(_instance.chapters.map((e) => CopyWith$Fragment$ChapterDto(
                    e,
                    (i) => i,
                  ))).toList());
}

class _CopyWithStubImpl$Mutation$GetChaptersByMangaId$fetchChapters<TRes>
    implements CopyWith$Mutation$GetChaptersByMangaId$fetchChapters<TRes> {
  _CopyWithStubImpl$Mutation$GetChaptersByMangaId$fetchChapters(this._res);

  TRes _res;

  call({
    List<Fragment$ChapterDto>? chapters,
    String? $__typename,
  }) =>
      _res;

  chapters(_fn) => _res;
}

class Variables$Query$GetMangaCategories {
  factory Variables$Query$GetMangaCategories({required int id}) =>
      Variables$Query$GetMangaCategories._({
        r'id': id,
      });

  Variables$Query$GetMangaCategories._(this._$data);

  factory Variables$Query$GetMangaCategories.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$id = data['id'];
    result$data['id'] = (l$id as int);
    return Variables$Query$GetMangaCategories._(result$data);
  }

  Map<String, dynamic> _$data;

  int get id => (_$data['id'] as int);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$id = id;
    result$data['id'] = l$id;
    return result$data;
  }

  CopyWith$Variables$Query$GetMangaCategories<
          Variables$Query$GetMangaCategories>
      get copyWith => CopyWith$Variables$Query$GetMangaCategories(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Query$GetMangaCategories ||
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

abstract class CopyWith$Variables$Query$GetMangaCategories<TRes> {
  factory CopyWith$Variables$Query$GetMangaCategories(
    Variables$Query$GetMangaCategories instance,
    TRes Function(Variables$Query$GetMangaCategories) then,
  ) = _CopyWithImpl$Variables$Query$GetMangaCategories;

  factory CopyWith$Variables$Query$GetMangaCategories.stub(TRes res) =
      _CopyWithStubImpl$Variables$Query$GetMangaCategories;

  TRes call({int? id});
}

class _CopyWithImpl$Variables$Query$GetMangaCategories<TRes>
    implements CopyWith$Variables$Query$GetMangaCategories<TRes> {
  _CopyWithImpl$Variables$Query$GetMangaCategories(
    this._instance,
    this._then,
  );

  final Variables$Query$GetMangaCategories _instance;

  final TRes Function(Variables$Query$GetMangaCategories) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? id = _undefined}) =>
      _then(Variables$Query$GetMangaCategories._({
        ..._instance._$data,
        if (id != _undefined && id != null) 'id': (id as int),
      }));
}

class _CopyWithStubImpl$Variables$Query$GetMangaCategories<TRes>
    implements CopyWith$Variables$Query$GetMangaCategories<TRes> {
  _CopyWithStubImpl$Variables$Query$GetMangaCategories(this._res);

  TRes _res;

  call({int? id}) => _res;
}

class Query$GetMangaCategories {
  Query$GetMangaCategories({
    required this.manga,
    this.$__typename = 'Query',
  });

  factory Query$GetMangaCategories.fromJson(Map<String, dynamic> json) {
    final l$manga = json['manga'];
    final l$$__typename = json['__typename'];
    return Query$GetMangaCategories(
      manga: Query$GetMangaCategories$manga.fromJson(
          (l$manga as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Query$GetMangaCategories$manga manga;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$manga = manga;
    _resultData['manga'] = l$manga.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$manga = manga;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$manga,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetMangaCategories ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$manga = manga;
    final lOther$manga = other.manga;
    if (l$manga != lOther$manga) {
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

extension UtilityExtension$Query$GetMangaCategories
    on Query$GetMangaCategories {
  CopyWith$Query$GetMangaCategories<Query$GetMangaCategories> get copyWith =>
      CopyWith$Query$GetMangaCategories(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Query$GetMangaCategories<TRes> {
  factory CopyWith$Query$GetMangaCategories(
    Query$GetMangaCategories instance,
    TRes Function(Query$GetMangaCategories) then,
  ) = _CopyWithImpl$Query$GetMangaCategories;

  factory CopyWith$Query$GetMangaCategories.stub(TRes res) =
      _CopyWithStubImpl$Query$GetMangaCategories;

  TRes call({
    Query$GetMangaCategories$manga? manga,
    String? $__typename,
  });
  CopyWith$Query$GetMangaCategories$manga<TRes> get manga;
}

class _CopyWithImpl$Query$GetMangaCategories<TRes>
    implements CopyWith$Query$GetMangaCategories<TRes> {
  _CopyWithImpl$Query$GetMangaCategories(
    this._instance,
    this._then,
  );

  final Query$GetMangaCategories _instance;

  final TRes Function(Query$GetMangaCategories) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? manga = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetMangaCategories(
        manga: manga == _undefined || manga == null
            ? _instance.manga
            : (manga as Query$GetMangaCategories$manga),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$GetMangaCategories$manga<TRes> get manga {
    final local$manga = _instance.manga;
    return CopyWith$Query$GetMangaCategories$manga(
        local$manga, (e) => call(manga: e));
  }
}

class _CopyWithStubImpl$Query$GetMangaCategories<TRes>
    implements CopyWith$Query$GetMangaCategories<TRes> {
  _CopyWithStubImpl$Query$GetMangaCategories(this._res);

  TRes _res;

  call({
    Query$GetMangaCategories$manga? manga,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$GetMangaCategories$manga<TRes> get manga =>
      CopyWith$Query$GetMangaCategories$manga.stub(_res);
}

const documentNodeQueryGetMangaCategories = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.query,
    name: NameNode(value: 'GetMangaCategories'),
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
        name: NameNode(value: 'manga'),
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
            name: NameNode(value: 'categories'),
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
Query$GetMangaCategories _parserFn$Query$GetMangaCategories(
        Map<String, dynamic> data) =>
    Query$GetMangaCategories.fromJson(data);
typedef OnQueryComplete$Query$GetMangaCategories = FutureOr<void> Function(
  Map<String, dynamic>?,
  Query$GetMangaCategories?,
);

class Options$Query$GetMangaCategories
    extends graphql.QueryOptions<Query$GetMangaCategories> {
  Options$Query$GetMangaCategories({
    String? operationName,
    required Variables$Query$GetMangaCategories variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetMangaCategories? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$GetMangaCategories? onComplete,
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
                        : _parserFn$Query$GetMangaCategories(data),
                  ),
          onError: onError,
          document: documentNodeQueryGetMangaCategories,
          parserFn: _parserFn$Query$GetMangaCategories,
        );

  final OnQueryComplete$Query$GetMangaCategories? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onComplete == null
            ? super.properties
            : super.properties.where((property) => property != onComplete),
        onCompleteWithParsed,
      ];
}

class WatchOptions$Query$GetMangaCategories
    extends graphql.WatchQueryOptions<Query$GetMangaCategories> {
  WatchOptions$Query$GetMangaCategories({
    String? operationName,
    required Variables$Query$GetMangaCategories variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetMangaCategories? typedOptimisticResult,
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
          document: documentNodeQueryGetMangaCategories,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Query$GetMangaCategories,
        );
}

class FetchMoreOptions$Query$GetMangaCategories
    extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$GetMangaCategories({
    required graphql.UpdateQuery updateQuery,
    required Variables$Query$GetMangaCategories variables,
  }) : super(
          updateQuery: updateQuery,
          variables: variables.toJson(),
          document: documentNodeQueryGetMangaCategories,
        );
}

extension ClientExtension$Query$GetMangaCategories on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$GetMangaCategories>>
      query$GetMangaCategories(
              Options$Query$GetMangaCategories options) async =>
          await this.query(options);

  graphql.ObservableQuery<Query$GetMangaCategories>
      watchQuery$GetMangaCategories(
              WatchOptions$Query$GetMangaCategories options) =>
          this.watchQuery(options);

  void writeQuery$GetMangaCategories({
    required Query$GetMangaCategories data,
    required Variables$Query$GetMangaCategories variables,
    bool broadcast = true,
  }) =>
      this.writeQuery(
        graphql.Request(
          operation:
              graphql.Operation(document: documentNodeQueryGetMangaCategories),
          variables: variables.toJson(),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );

  Query$GetMangaCategories? readQuery$GetMangaCategories({
    required Variables$Query$GetMangaCategories variables,
    bool optimistic = true,
  }) {
    final result = this.readQuery(
      graphql.Request(
        operation:
            graphql.Operation(document: documentNodeQueryGetMangaCategories),
        variables: variables.toJson(),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Query$GetMangaCategories.fromJson(result);
  }
}

graphql_flutter.QueryHookResult<Query$GetMangaCategories>
    useQuery$GetMangaCategories(Options$Query$GetMangaCategories options) =>
        graphql_flutter.useQuery(options);
graphql.ObservableQuery<Query$GetMangaCategories>
    useWatchQuery$GetMangaCategories(
            WatchOptions$Query$GetMangaCategories options) =>
        graphql_flutter.useWatchQuery(options);

class Query$GetMangaCategories$Widget
    extends graphql_flutter.Query<Query$GetMangaCategories> {
  Query$GetMangaCategories$Widget({
    widgets.Key? key,
    required Options$Query$GetMangaCategories options,
    required graphql_flutter.QueryBuilder<Query$GetMangaCategories> builder,
  }) : super(
          key: key,
          options: options,
          builder: builder,
        );
}

class Query$GetMangaCategories$manga {
  Query$GetMangaCategories$manga({
    required this.categories,
    this.$__typename = 'MangaType',
  });

  factory Query$GetMangaCategories$manga.fromJson(Map<String, dynamic> json) {
    final l$categories = json['categories'];
    final l$$__typename = json['__typename'];
    return Query$GetMangaCategories$manga(
      categories: Query$GetMangaCategories$manga$categories.fromJson(
          (l$categories as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Query$GetMangaCategories$manga$categories categories;

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
    if (other is! Query$GetMangaCategories$manga ||
        runtimeType != other.runtimeType) {
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

extension UtilityExtension$Query$GetMangaCategories$manga
    on Query$GetMangaCategories$manga {
  CopyWith$Query$GetMangaCategories$manga<Query$GetMangaCategories$manga>
      get copyWith => CopyWith$Query$GetMangaCategories$manga(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetMangaCategories$manga<TRes> {
  factory CopyWith$Query$GetMangaCategories$manga(
    Query$GetMangaCategories$manga instance,
    TRes Function(Query$GetMangaCategories$manga) then,
  ) = _CopyWithImpl$Query$GetMangaCategories$manga;

  factory CopyWith$Query$GetMangaCategories$manga.stub(TRes res) =
      _CopyWithStubImpl$Query$GetMangaCategories$manga;

  TRes call({
    Query$GetMangaCategories$manga$categories? categories,
    String? $__typename,
  });
  CopyWith$Query$GetMangaCategories$manga$categories<TRes> get categories;
}

class _CopyWithImpl$Query$GetMangaCategories$manga<TRes>
    implements CopyWith$Query$GetMangaCategories$manga<TRes> {
  _CopyWithImpl$Query$GetMangaCategories$manga(
    this._instance,
    this._then,
  );

  final Query$GetMangaCategories$manga _instance;

  final TRes Function(Query$GetMangaCategories$manga) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? categories = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetMangaCategories$manga(
        categories: categories == _undefined || categories == null
            ? _instance.categories
            : (categories as Query$GetMangaCategories$manga$categories),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$GetMangaCategories$manga$categories<TRes> get categories {
    final local$categories = _instance.categories;
    return CopyWith$Query$GetMangaCategories$manga$categories(
        local$categories, (e) => call(categories: e));
  }
}

class _CopyWithStubImpl$Query$GetMangaCategories$manga<TRes>
    implements CopyWith$Query$GetMangaCategories$manga<TRes> {
  _CopyWithStubImpl$Query$GetMangaCategories$manga(this._res);

  TRes _res;

  call({
    Query$GetMangaCategories$manga$categories? categories,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$GetMangaCategories$manga$categories<TRes> get categories =>
      CopyWith$Query$GetMangaCategories$manga$categories.stub(_res);
}

class Query$GetMangaCategories$manga$categories {
  Query$GetMangaCategories$manga$categories({
    required this.nodes,
    this.$__typename = 'CategoryNodeList',
  });

  factory Query$GetMangaCategories$manga$categories.fromJson(
      Map<String, dynamic> json) {
    final l$nodes = json['nodes'];
    final l$$__typename = json['__typename'];
    return Query$GetMangaCategories$manga$categories(
      nodes: (l$nodes as List<dynamic>)
          .map(
              (e) => Fragment$CategoryDto.fromJson((e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final List<Fragment$CategoryDto> nodes;

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
    if (other is! Query$GetMangaCategories$manga$categories ||
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

extension UtilityExtension$Query$GetMangaCategories$manga$categories
    on Query$GetMangaCategories$manga$categories {
  CopyWith$Query$GetMangaCategories$manga$categories<
          Query$GetMangaCategories$manga$categories>
      get copyWith => CopyWith$Query$GetMangaCategories$manga$categories(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetMangaCategories$manga$categories<TRes> {
  factory CopyWith$Query$GetMangaCategories$manga$categories(
    Query$GetMangaCategories$manga$categories instance,
    TRes Function(Query$GetMangaCategories$manga$categories) then,
  ) = _CopyWithImpl$Query$GetMangaCategories$manga$categories;

  factory CopyWith$Query$GetMangaCategories$manga$categories.stub(TRes res) =
      _CopyWithStubImpl$Query$GetMangaCategories$manga$categories;

  TRes call({
    List<Fragment$CategoryDto>? nodes,
    String? $__typename,
  });
  TRes nodes(
      Iterable<Fragment$CategoryDto> Function(
              Iterable<CopyWith$Fragment$CategoryDto<Fragment$CategoryDto>>)
          _fn);
}

class _CopyWithImpl$Query$GetMangaCategories$manga$categories<TRes>
    implements CopyWith$Query$GetMangaCategories$manga$categories<TRes> {
  _CopyWithImpl$Query$GetMangaCategories$manga$categories(
    this._instance,
    this._then,
  );

  final Query$GetMangaCategories$manga$categories _instance;

  final TRes Function(Query$GetMangaCategories$manga$categories) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? nodes = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetMangaCategories$manga$categories(
        nodes: nodes == _undefined || nodes == null
            ? _instance.nodes
            : (nodes as List<Fragment$CategoryDto>),
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
}

class _CopyWithStubImpl$Query$GetMangaCategories$manga$categories<TRes>
    implements CopyWith$Query$GetMangaCategories$manga$categories<TRes> {
  _CopyWithStubImpl$Query$GetMangaCategories$manga$categories(this._res);

  TRes _res;

  call({
    List<Fragment$CategoryDto>? nodes,
    String? $__typename,
  }) =>
      _res;

  nodes(_fn) => _res;
}

class Variables$Mutation$GetChapterPages {
  factory Variables$Mutation$GetChapterPages(
          {required Input$FetchChapterPagesInput input}) =>
      Variables$Mutation$GetChapterPages._({
        r'input': input,
      });

  Variables$Mutation$GetChapterPages._(this._$data);

  factory Variables$Mutation$GetChapterPages.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$input = data['input'];
    result$data['input'] = Input$FetchChapterPagesInput.fromJson(
        (l$input as Map<String, dynamic>));
    return Variables$Mutation$GetChapterPages._(result$data);
  }

  Map<String, dynamic> _$data;

  Input$FetchChapterPagesInput get input =>
      (_$data['input'] as Input$FetchChapterPagesInput);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$input = input;
    result$data['input'] = l$input.toJson();
    return result$data;
  }

  CopyWith$Variables$Mutation$GetChapterPages<
          Variables$Mutation$GetChapterPages>
      get copyWith => CopyWith$Variables$Mutation$GetChapterPages(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$GetChapterPages ||
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

abstract class CopyWith$Variables$Mutation$GetChapterPages<TRes> {
  factory CopyWith$Variables$Mutation$GetChapterPages(
    Variables$Mutation$GetChapterPages instance,
    TRes Function(Variables$Mutation$GetChapterPages) then,
  ) = _CopyWithImpl$Variables$Mutation$GetChapterPages;

  factory CopyWith$Variables$Mutation$GetChapterPages.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$GetChapterPages;

  TRes call({Input$FetchChapterPagesInput? input});
}

class _CopyWithImpl$Variables$Mutation$GetChapterPages<TRes>
    implements CopyWith$Variables$Mutation$GetChapterPages<TRes> {
  _CopyWithImpl$Variables$Mutation$GetChapterPages(
    this._instance,
    this._then,
  );

  final Variables$Mutation$GetChapterPages _instance;

  final TRes Function(Variables$Mutation$GetChapterPages) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? input = _undefined}) =>
      _then(Variables$Mutation$GetChapterPages._({
        ..._instance._$data,
        if (input != _undefined && input != null)
          'input': (input as Input$FetchChapterPagesInput),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$GetChapterPages<TRes>
    implements CopyWith$Variables$Mutation$GetChapterPages<TRes> {
  _CopyWithStubImpl$Variables$Mutation$GetChapterPages(this._res);

  TRes _res;

  call({Input$FetchChapterPagesInput? input}) => _res;
}

class Mutation$GetChapterPages {
  Mutation$GetChapterPages({
    this.fetchChapterPages,
    this.$__typename = 'Mutation',
  });

  factory Mutation$GetChapterPages.fromJson(Map<String, dynamic> json) {
    final l$fetchChapterPages = json['fetchChapterPages'];
    final l$$__typename = json['__typename'];
    return Mutation$GetChapterPages(
      fetchChapterPages: l$fetchChapterPages == null
          ? null
          : Fragment$ChapterPagesDto.fromJson(
              (l$fetchChapterPages as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Fragment$ChapterPagesDto? fetchChapterPages;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$fetchChapterPages = fetchChapterPages;
    _resultData['fetchChapterPages'] = l$fetchChapterPages?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$fetchChapterPages = fetchChapterPages;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$fetchChapterPages,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$GetChapterPages ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$fetchChapterPages = fetchChapterPages;
    final lOther$fetchChapterPages = other.fetchChapterPages;
    if (l$fetchChapterPages != lOther$fetchChapterPages) {
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

extension UtilityExtension$Mutation$GetChapterPages
    on Mutation$GetChapterPages {
  CopyWith$Mutation$GetChapterPages<Mutation$GetChapterPages> get copyWith =>
      CopyWith$Mutation$GetChapterPages(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Mutation$GetChapterPages<TRes> {
  factory CopyWith$Mutation$GetChapterPages(
    Mutation$GetChapterPages instance,
    TRes Function(Mutation$GetChapterPages) then,
  ) = _CopyWithImpl$Mutation$GetChapterPages;

  factory CopyWith$Mutation$GetChapterPages.stub(TRes res) =
      _CopyWithStubImpl$Mutation$GetChapterPages;

  TRes call({
    Fragment$ChapterPagesDto? fetchChapterPages,
    String? $__typename,
  });
  CopyWith$Fragment$ChapterPagesDto<TRes> get fetchChapterPages;
}

class _CopyWithImpl$Mutation$GetChapterPages<TRes>
    implements CopyWith$Mutation$GetChapterPages<TRes> {
  _CopyWithImpl$Mutation$GetChapterPages(
    this._instance,
    this._then,
  );

  final Mutation$GetChapterPages _instance;

  final TRes Function(Mutation$GetChapterPages) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? fetchChapterPages = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$GetChapterPages(
        fetchChapterPages: fetchChapterPages == _undefined
            ? _instance.fetchChapterPages
            : (fetchChapterPages as Fragment$ChapterPagesDto?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Fragment$ChapterPagesDto<TRes> get fetchChapterPages {
    final local$fetchChapterPages = _instance.fetchChapterPages;
    return local$fetchChapterPages == null
        ? CopyWith$Fragment$ChapterPagesDto.stub(_then(_instance))
        : CopyWith$Fragment$ChapterPagesDto(
            local$fetchChapterPages, (e) => call(fetchChapterPages: e));
  }
}

class _CopyWithStubImpl$Mutation$GetChapterPages<TRes>
    implements CopyWith$Mutation$GetChapterPages<TRes> {
  _CopyWithStubImpl$Mutation$GetChapterPages(this._res);

  TRes _res;

  call({
    Fragment$ChapterPagesDto? fetchChapterPages,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$ChapterPagesDto<TRes> get fetchChapterPages =>
      CopyWith$Fragment$ChapterPagesDto.stub(_res);
}

const documentNodeMutationGetChapterPages = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'GetChapterPages'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'input')),
        type: NamedTypeNode(
          name: NameNode(value: 'FetchChapterPagesInput'),
          isNonNull: true,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      )
    ],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'fetchChapterPages'),
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
            name: NameNode(value: 'ChapterPagesDto'),
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
  fragmentDefinitionChapterPagesDto,
]);
Mutation$GetChapterPages _parserFn$Mutation$GetChapterPages(
        Map<String, dynamic> data) =>
    Mutation$GetChapterPages.fromJson(data);
typedef OnMutationCompleted$Mutation$GetChapterPages = FutureOr<void> Function(
  Map<String, dynamic>?,
  Mutation$GetChapterPages?,
);

class Options$Mutation$GetChapterPages
    extends graphql.MutationOptions<Mutation$GetChapterPages> {
  Options$Mutation$GetChapterPages({
    String? operationName,
    required Variables$Mutation$GetChapterPages variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$GetChapterPages? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$GetChapterPages? onCompleted,
    graphql.OnMutationUpdate<Mutation$GetChapterPages>? update,
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
                        : _parserFn$Mutation$GetChapterPages(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationGetChapterPages,
          parserFn: _parserFn$Mutation$GetChapterPages,
        );

  final OnMutationCompleted$Mutation$GetChapterPages? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$GetChapterPages
    extends graphql.WatchQueryOptions<Mutation$GetChapterPages> {
  WatchOptions$Mutation$GetChapterPages({
    String? operationName,
    required Variables$Mutation$GetChapterPages variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$GetChapterPages? typedOptimisticResult,
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
          document: documentNodeMutationGetChapterPages,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$GetChapterPages,
        );
}

extension ClientExtension$Mutation$GetChapterPages on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$GetChapterPages>> mutate$GetChapterPages(
          Options$Mutation$GetChapterPages options) async =>
      await this.mutate(options);

  graphql.ObservableQuery<Mutation$GetChapterPages>
      watchMutation$GetChapterPages(
              WatchOptions$Mutation$GetChapterPages options) =>
          this.watchMutation(options);
}

class Mutation$GetChapterPages$HookResult {
  Mutation$GetChapterPages$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$GetChapterPages runMutation;

  final graphql.QueryResult<Mutation$GetChapterPages> result;
}

Mutation$GetChapterPages$HookResult useMutation$GetChapterPages(
    [WidgetOptions$Mutation$GetChapterPages? options]) {
  final result = graphql_flutter
      .useMutation(options ?? WidgetOptions$Mutation$GetChapterPages());
  return Mutation$GetChapterPages$HookResult(
    (variables, {optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables.toJson(),
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$GetChapterPages>
    useWatchMutation$GetChapterPages(
            WatchOptions$Mutation$GetChapterPages options) =>
        graphql_flutter.useWatchMutation(options);

class WidgetOptions$Mutation$GetChapterPages
    extends graphql.MutationOptions<Mutation$GetChapterPages> {
  WidgetOptions$Mutation$GetChapterPages({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$GetChapterPages? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$GetChapterPages? onCompleted,
    graphql.OnMutationUpdate<Mutation$GetChapterPages>? update,
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
                        : _parserFn$Mutation$GetChapterPages(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationGetChapterPages,
          parserFn: _parserFn$Mutation$GetChapterPages,
        );

  final OnMutationCompleted$Mutation$GetChapterPages? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$GetChapterPages
    = graphql.MultiSourceResult<Mutation$GetChapterPages> Function(
  Variables$Mutation$GetChapterPages, {
  Object? optimisticResult,
  Mutation$GetChapterPages? typedOptimisticResult,
});
typedef Builder$Mutation$GetChapterPages = widgets.Widget Function(
  RunMutation$Mutation$GetChapterPages,
  graphql.QueryResult<Mutation$GetChapterPages>?,
);

class Mutation$GetChapterPages$Widget
    extends graphql_flutter.Mutation<Mutation$GetChapterPages> {
  Mutation$GetChapterPages$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$GetChapterPages? options,
    required Builder$Mutation$GetChapterPages builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$GetChapterPages(),
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
