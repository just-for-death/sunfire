import '../../../../../../graphql/__generated__/schema.graphql.dart';
import '../../../../domain/downloads/graphql/__generated__/fragment.graphql.dart';
import '../../../../domain/downloads_queue/graphql/__generated__/fragment.graphql.dart';
import 'dart:async';
import 'package:flutter/widgets.dart' as widgets;
import 'package:gql/ast.dart';
import 'package:graphql/client.dart' as graphql;
import 'package:graphql_flutter/graphql_flutter.dart' as graphql_flutter;

class Variables$Mutation$EnqueueChapterDownloads {
  factory Variables$Mutation$EnqueueChapterDownloads(
          {required Input$EnqueueChapterDownloadsInput input}) =>
      Variables$Mutation$EnqueueChapterDownloads._({
        r'input': input,
      });

  Variables$Mutation$EnqueueChapterDownloads._(this._$data);

  factory Variables$Mutation$EnqueueChapterDownloads.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$input = data['input'];
    result$data['input'] = Input$EnqueueChapterDownloadsInput.fromJson(
        (l$input as Map<String, dynamic>));
    return Variables$Mutation$EnqueueChapterDownloads._(result$data);
  }

  Map<String, dynamic> _$data;

  Input$EnqueueChapterDownloadsInput get input =>
      (_$data['input'] as Input$EnqueueChapterDownloadsInput);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$input = input;
    result$data['input'] = l$input.toJson();
    return result$data;
  }

  CopyWith$Variables$Mutation$EnqueueChapterDownloads<
          Variables$Mutation$EnqueueChapterDownloads>
      get copyWith => CopyWith$Variables$Mutation$EnqueueChapterDownloads(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$EnqueueChapterDownloads ||
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

abstract class CopyWith$Variables$Mutation$EnqueueChapterDownloads<TRes> {
  factory CopyWith$Variables$Mutation$EnqueueChapterDownloads(
    Variables$Mutation$EnqueueChapterDownloads instance,
    TRes Function(Variables$Mutation$EnqueueChapterDownloads) then,
  ) = _CopyWithImpl$Variables$Mutation$EnqueueChapterDownloads;

  factory CopyWith$Variables$Mutation$EnqueueChapterDownloads.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$EnqueueChapterDownloads;

  TRes call({Input$EnqueueChapterDownloadsInput? input});
}

class _CopyWithImpl$Variables$Mutation$EnqueueChapterDownloads<TRes>
    implements CopyWith$Variables$Mutation$EnqueueChapterDownloads<TRes> {
  _CopyWithImpl$Variables$Mutation$EnqueueChapterDownloads(
    this._instance,
    this._then,
  );

  final Variables$Mutation$EnqueueChapterDownloads _instance;

  final TRes Function(Variables$Mutation$EnqueueChapterDownloads) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? input = _undefined}) =>
      _then(Variables$Mutation$EnqueueChapterDownloads._({
        ..._instance._$data,
        if (input != _undefined && input != null)
          'input': (input as Input$EnqueueChapterDownloadsInput),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$EnqueueChapterDownloads<TRes>
    implements CopyWith$Variables$Mutation$EnqueueChapterDownloads<TRes> {
  _CopyWithStubImpl$Variables$Mutation$EnqueueChapterDownloads(this._res);

  TRes _res;

  call({Input$EnqueueChapterDownloadsInput? input}) => _res;
}

class Mutation$EnqueueChapterDownloads {
  Mutation$EnqueueChapterDownloads({
    this.enqueueChapterDownloads,
    this.$__typename = 'Mutation',
  });

  factory Mutation$EnqueueChapterDownloads.fromJson(Map<String, dynamic> json) {
    final l$enqueueChapterDownloads = json['enqueueChapterDownloads'];
    final l$$__typename = json['__typename'];
    return Mutation$EnqueueChapterDownloads(
      enqueueChapterDownloads: l$enqueueChapterDownloads == null
          ? null
          : Mutation$EnqueueChapterDownloads$enqueueChapterDownloads.fromJson(
              (l$enqueueChapterDownloads as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$EnqueueChapterDownloads$enqueueChapterDownloads?
      enqueueChapterDownloads;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$enqueueChapterDownloads = enqueueChapterDownloads;
    _resultData['enqueueChapterDownloads'] =
        l$enqueueChapterDownloads?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$enqueueChapterDownloads = enqueueChapterDownloads;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$enqueueChapterDownloads,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$EnqueueChapterDownloads ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$enqueueChapterDownloads = enqueueChapterDownloads;
    final lOther$enqueueChapterDownloads = other.enqueueChapterDownloads;
    if (l$enqueueChapterDownloads != lOther$enqueueChapterDownloads) {
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

extension UtilityExtension$Mutation$EnqueueChapterDownloads
    on Mutation$EnqueueChapterDownloads {
  CopyWith$Mutation$EnqueueChapterDownloads<Mutation$EnqueueChapterDownloads>
      get copyWith => CopyWith$Mutation$EnqueueChapterDownloads(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$EnqueueChapterDownloads<TRes> {
  factory CopyWith$Mutation$EnqueueChapterDownloads(
    Mutation$EnqueueChapterDownloads instance,
    TRes Function(Mutation$EnqueueChapterDownloads) then,
  ) = _CopyWithImpl$Mutation$EnqueueChapterDownloads;

  factory CopyWith$Mutation$EnqueueChapterDownloads.stub(TRes res) =
      _CopyWithStubImpl$Mutation$EnqueueChapterDownloads;

  TRes call({
    Mutation$EnqueueChapterDownloads$enqueueChapterDownloads?
        enqueueChapterDownloads,
    String? $__typename,
  });
  CopyWith$Mutation$EnqueueChapterDownloads$enqueueChapterDownloads<TRes>
      get enqueueChapterDownloads;
}

class _CopyWithImpl$Mutation$EnqueueChapterDownloads<TRes>
    implements CopyWith$Mutation$EnqueueChapterDownloads<TRes> {
  _CopyWithImpl$Mutation$EnqueueChapterDownloads(
    this._instance,
    this._then,
  );

  final Mutation$EnqueueChapterDownloads _instance;

  final TRes Function(Mutation$EnqueueChapterDownloads) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? enqueueChapterDownloads = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$EnqueueChapterDownloads(
        enqueueChapterDownloads: enqueueChapterDownloads == _undefined
            ? _instance.enqueueChapterDownloads
            : (enqueueChapterDownloads
                as Mutation$EnqueueChapterDownloads$enqueueChapterDownloads?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$EnqueueChapterDownloads$enqueueChapterDownloads<TRes>
      get enqueueChapterDownloads {
    final local$enqueueChapterDownloads = _instance.enqueueChapterDownloads;
    return local$enqueueChapterDownloads == null
        ? CopyWith$Mutation$EnqueueChapterDownloads$enqueueChapterDownloads
            .stub(_then(_instance))
        : CopyWith$Mutation$EnqueueChapterDownloads$enqueueChapterDownloads(
            local$enqueueChapterDownloads,
            (e) => call(enqueueChapterDownloads: e));
  }
}

class _CopyWithStubImpl$Mutation$EnqueueChapterDownloads<TRes>
    implements CopyWith$Mutation$EnqueueChapterDownloads<TRes> {
  _CopyWithStubImpl$Mutation$EnqueueChapterDownloads(this._res);

  TRes _res;

  call({
    Mutation$EnqueueChapterDownloads$enqueueChapterDownloads?
        enqueueChapterDownloads,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$EnqueueChapterDownloads$enqueueChapterDownloads<TRes>
      get enqueueChapterDownloads =>
          CopyWith$Mutation$EnqueueChapterDownloads$enqueueChapterDownloads
              .stub(_res);
}

const documentNodeMutationEnqueueChapterDownloads = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'EnqueueChapterDownloads'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'input')),
        type: NamedTypeNode(
          name: NameNode(value: 'EnqueueChapterDownloadsInput'),
          isNonNull: true,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      )
    ],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'enqueueChapterDownloads'),
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
Mutation$EnqueueChapterDownloads _parserFn$Mutation$EnqueueChapterDownloads(
        Map<String, dynamic> data) =>
    Mutation$EnqueueChapterDownloads.fromJson(data);
typedef OnMutationCompleted$Mutation$EnqueueChapterDownloads = FutureOr<void>
    Function(
  Map<String, dynamic>?,
  Mutation$EnqueueChapterDownloads?,
);

class Options$Mutation$EnqueueChapterDownloads
    extends graphql.MutationOptions<Mutation$EnqueueChapterDownloads> {
  Options$Mutation$EnqueueChapterDownloads({
    String? operationName,
    required Variables$Mutation$EnqueueChapterDownloads variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$EnqueueChapterDownloads? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$EnqueueChapterDownloads? onCompleted,
    graphql.OnMutationUpdate<Mutation$EnqueueChapterDownloads>? update,
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
                        : _parserFn$Mutation$EnqueueChapterDownloads(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationEnqueueChapterDownloads,
          parserFn: _parserFn$Mutation$EnqueueChapterDownloads,
        );

  final OnMutationCompleted$Mutation$EnqueueChapterDownloads?
      onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$EnqueueChapterDownloads
    extends graphql.WatchQueryOptions<Mutation$EnqueueChapterDownloads> {
  WatchOptions$Mutation$EnqueueChapterDownloads({
    String? operationName,
    required Variables$Mutation$EnqueueChapterDownloads variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$EnqueueChapterDownloads? typedOptimisticResult,
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
          document: documentNodeMutationEnqueueChapterDownloads,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$EnqueueChapterDownloads,
        );
}

extension ClientExtension$Mutation$EnqueueChapterDownloads
    on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$EnqueueChapterDownloads>>
      mutate$EnqueueChapterDownloads(
              Options$Mutation$EnqueueChapterDownloads options) async =>
          await this.mutate(options);

  graphql.ObservableQuery<Mutation$EnqueueChapterDownloads>
      watchMutation$EnqueueChapterDownloads(
              WatchOptions$Mutation$EnqueueChapterDownloads options) =>
          this.watchMutation(options);
}

class Mutation$EnqueueChapterDownloads$HookResult {
  Mutation$EnqueueChapterDownloads$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$EnqueueChapterDownloads runMutation;

  final graphql.QueryResult<Mutation$EnqueueChapterDownloads> result;
}

Mutation$EnqueueChapterDownloads$HookResult useMutation$EnqueueChapterDownloads(
    [WidgetOptions$Mutation$EnqueueChapterDownloads? options]) {
  final result = graphql_flutter
      .useMutation(options ?? WidgetOptions$Mutation$EnqueueChapterDownloads());
  return Mutation$EnqueueChapterDownloads$HookResult(
    (variables, {optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables.toJson(),
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$EnqueueChapterDownloads>
    useWatchMutation$EnqueueChapterDownloads(
            WatchOptions$Mutation$EnqueueChapterDownloads options) =>
        graphql_flutter.useWatchMutation(options);

class WidgetOptions$Mutation$EnqueueChapterDownloads
    extends graphql.MutationOptions<Mutation$EnqueueChapterDownloads> {
  WidgetOptions$Mutation$EnqueueChapterDownloads({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$EnqueueChapterDownloads? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$EnqueueChapterDownloads? onCompleted,
    graphql.OnMutationUpdate<Mutation$EnqueueChapterDownloads>? update,
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
                        : _parserFn$Mutation$EnqueueChapterDownloads(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationEnqueueChapterDownloads,
          parserFn: _parserFn$Mutation$EnqueueChapterDownloads,
        );

  final OnMutationCompleted$Mutation$EnqueueChapterDownloads?
      onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$EnqueueChapterDownloads
    = graphql.MultiSourceResult<Mutation$EnqueueChapterDownloads> Function(
  Variables$Mutation$EnqueueChapterDownloads, {
  Object? optimisticResult,
  Mutation$EnqueueChapterDownloads? typedOptimisticResult,
});
typedef Builder$Mutation$EnqueueChapterDownloads = widgets.Widget Function(
  RunMutation$Mutation$EnqueueChapterDownloads,
  graphql.QueryResult<Mutation$EnqueueChapterDownloads>?,
);

class Mutation$EnqueueChapterDownloads$Widget
    extends graphql_flutter.Mutation<Mutation$EnqueueChapterDownloads> {
  Mutation$EnqueueChapterDownloads$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$EnqueueChapterDownloads? options,
    required Builder$Mutation$EnqueueChapterDownloads builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$EnqueueChapterDownloads(),
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

class Mutation$EnqueueChapterDownloads$enqueueChapterDownloads {
  Mutation$EnqueueChapterDownloads$enqueueChapterDownloads(
      {this.$__typename = 'EnqueueChapterDownloadsPayload'});

  factory Mutation$EnqueueChapterDownloads$enqueueChapterDownloads.fromJson(
      Map<String, dynamic> json) {
    final l$$__typename = json['__typename'];
    return Mutation$EnqueueChapterDownloads$enqueueChapterDownloads(
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
    if (other is! Mutation$EnqueueChapterDownloads$enqueueChapterDownloads ||
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

extension UtilityExtension$Mutation$EnqueueChapterDownloads$enqueueChapterDownloads
    on Mutation$EnqueueChapterDownloads$enqueueChapterDownloads {
  CopyWith$Mutation$EnqueueChapterDownloads$enqueueChapterDownloads<
          Mutation$EnqueueChapterDownloads$enqueueChapterDownloads>
      get copyWith =>
          CopyWith$Mutation$EnqueueChapterDownloads$enqueueChapterDownloads(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$EnqueueChapterDownloads$enqueueChapterDownloads<
    TRes> {
  factory CopyWith$Mutation$EnqueueChapterDownloads$enqueueChapterDownloads(
    Mutation$EnqueueChapterDownloads$enqueueChapterDownloads instance,
    TRes Function(Mutation$EnqueueChapterDownloads$enqueueChapterDownloads)
        then,
  ) = _CopyWithImpl$Mutation$EnqueueChapterDownloads$enqueueChapterDownloads;

  factory CopyWith$Mutation$EnqueueChapterDownloads$enqueueChapterDownloads.stub(
          TRes res) =
      _CopyWithStubImpl$Mutation$EnqueueChapterDownloads$enqueueChapterDownloads;

  TRes call({String? $__typename});
}

class _CopyWithImpl$Mutation$EnqueueChapterDownloads$enqueueChapterDownloads<
        TRes>
    implements
        CopyWith$Mutation$EnqueueChapterDownloads$enqueueChapterDownloads<
            TRes> {
  _CopyWithImpl$Mutation$EnqueueChapterDownloads$enqueueChapterDownloads(
    this._instance,
    this._then,
  );

  final Mutation$EnqueueChapterDownloads$enqueueChapterDownloads _instance;

  final TRes Function(Mutation$EnqueueChapterDownloads$enqueueChapterDownloads)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? $__typename = _undefined}) =>
      _then(Mutation$EnqueueChapterDownloads$enqueueChapterDownloads(
          $__typename: $__typename == _undefined || $__typename == null
              ? _instance.$__typename
              : ($__typename as String)));
}

class _CopyWithStubImpl$Mutation$EnqueueChapterDownloads$enqueueChapterDownloads<
        TRes>
    implements
        CopyWith$Mutation$EnqueueChapterDownloads$enqueueChapterDownloads<
            TRes> {
  _CopyWithStubImpl$Mutation$EnqueueChapterDownloads$enqueueChapterDownloads(
      this._res);

  TRes _res;

  call({String? $__typename}) => _res;
}

class Variables$Mutation$DequeueChapterDownloads {
  factory Variables$Mutation$DequeueChapterDownloads(
          {required Input$DequeueChapterDownloadInput input}) =>
      Variables$Mutation$DequeueChapterDownloads._({
        r'input': input,
      });

  Variables$Mutation$DequeueChapterDownloads._(this._$data);

  factory Variables$Mutation$DequeueChapterDownloads.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$input = data['input'];
    result$data['input'] = Input$DequeueChapterDownloadInput.fromJson(
        (l$input as Map<String, dynamic>));
    return Variables$Mutation$DequeueChapterDownloads._(result$data);
  }

  Map<String, dynamic> _$data;

  Input$DequeueChapterDownloadInput get input =>
      (_$data['input'] as Input$DequeueChapterDownloadInput);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$input = input;
    result$data['input'] = l$input.toJson();
    return result$data;
  }

  CopyWith$Variables$Mutation$DequeueChapterDownloads<
          Variables$Mutation$DequeueChapterDownloads>
      get copyWith => CopyWith$Variables$Mutation$DequeueChapterDownloads(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$DequeueChapterDownloads ||
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

abstract class CopyWith$Variables$Mutation$DequeueChapterDownloads<TRes> {
  factory CopyWith$Variables$Mutation$DequeueChapterDownloads(
    Variables$Mutation$DequeueChapterDownloads instance,
    TRes Function(Variables$Mutation$DequeueChapterDownloads) then,
  ) = _CopyWithImpl$Variables$Mutation$DequeueChapterDownloads;

  factory CopyWith$Variables$Mutation$DequeueChapterDownloads.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$DequeueChapterDownloads;

  TRes call({Input$DequeueChapterDownloadInput? input});
}

class _CopyWithImpl$Variables$Mutation$DequeueChapterDownloads<TRes>
    implements CopyWith$Variables$Mutation$DequeueChapterDownloads<TRes> {
  _CopyWithImpl$Variables$Mutation$DequeueChapterDownloads(
    this._instance,
    this._then,
  );

  final Variables$Mutation$DequeueChapterDownloads _instance;

  final TRes Function(Variables$Mutation$DequeueChapterDownloads) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? input = _undefined}) =>
      _then(Variables$Mutation$DequeueChapterDownloads._({
        ..._instance._$data,
        if (input != _undefined && input != null)
          'input': (input as Input$DequeueChapterDownloadInput),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$DequeueChapterDownloads<TRes>
    implements CopyWith$Variables$Mutation$DequeueChapterDownloads<TRes> {
  _CopyWithStubImpl$Variables$Mutation$DequeueChapterDownloads(this._res);

  TRes _res;

  call({Input$DequeueChapterDownloadInput? input}) => _res;
}

class Mutation$DequeueChapterDownloads {
  Mutation$DequeueChapterDownloads({
    this.dequeueChapterDownload,
    this.$__typename = 'Mutation',
  });

  factory Mutation$DequeueChapterDownloads.fromJson(Map<String, dynamic> json) {
    final l$dequeueChapterDownload = json['dequeueChapterDownload'];
    final l$$__typename = json['__typename'];
    return Mutation$DequeueChapterDownloads(
      dequeueChapterDownload: l$dequeueChapterDownload == null
          ? null
          : Mutation$DequeueChapterDownloads$dequeueChapterDownload.fromJson(
              (l$dequeueChapterDownload as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$DequeueChapterDownloads$dequeueChapterDownload?
      dequeueChapterDownload;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$dequeueChapterDownload = dequeueChapterDownload;
    _resultData['dequeueChapterDownload'] = l$dequeueChapterDownload?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$dequeueChapterDownload = dequeueChapterDownload;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$dequeueChapterDownload,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$DequeueChapterDownloads ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$dequeueChapterDownload = dequeueChapterDownload;
    final lOther$dequeueChapterDownload = other.dequeueChapterDownload;
    if (l$dequeueChapterDownload != lOther$dequeueChapterDownload) {
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

extension UtilityExtension$Mutation$DequeueChapterDownloads
    on Mutation$DequeueChapterDownloads {
  CopyWith$Mutation$DequeueChapterDownloads<Mutation$DequeueChapterDownloads>
      get copyWith => CopyWith$Mutation$DequeueChapterDownloads(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$DequeueChapterDownloads<TRes> {
  factory CopyWith$Mutation$DequeueChapterDownloads(
    Mutation$DequeueChapterDownloads instance,
    TRes Function(Mutation$DequeueChapterDownloads) then,
  ) = _CopyWithImpl$Mutation$DequeueChapterDownloads;

  factory CopyWith$Mutation$DequeueChapterDownloads.stub(TRes res) =
      _CopyWithStubImpl$Mutation$DequeueChapterDownloads;

  TRes call({
    Mutation$DequeueChapterDownloads$dequeueChapterDownload?
        dequeueChapterDownload,
    String? $__typename,
  });
  CopyWith$Mutation$DequeueChapterDownloads$dequeueChapterDownload<TRes>
      get dequeueChapterDownload;
}

class _CopyWithImpl$Mutation$DequeueChapterDownloads<TRes>
    implements CopyWith$Mutation$DequeueChapterDownloads<TRes> {
  _CopyWithImpl$Mutation$DequeueChapterDownloads(
    this._instance,
    this._then,
  );

  final Mutation$DequeueChapterDownloads _instance;

  final TRes Function(Mutation$DequeueChapterDownloads) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? dequeueChapterDownload = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$DequeueChapterDownloads(
        dequeueChapterDownload: dequeueChapterDownload == _undefined
            ? _instance.dequeueChapterDownload
            : (dequeueChapterDownload
                as Mutation$DequeueChapterDownloads$dequeueChapterDownload?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$DequeueChapterDownloads$dequeueChapterDownload<TRes>
      get dequeueChapterDownload {
    final local$dequeueChapterDownload = _instance.dequeueChapterDownload;
    return local$dequeueChapterDownload == null
        ? CopyWith$Mutation$DequeueChapterDownloads$dequeueChapterDownload.stub(
            _then(_instance))
        : CopyWith$Mutation$DequeueChapterDownloads$dequeueChapterDownload(
            local$dequeueChapterDownload,
            (e) => call(dequeueChapterDownload: e));
  }
}

class _CopyWithStubImpl$Mutation$DequeueChapterDownloads<TRes>
    implements CopyWith$Mutation$DequeueChapterDownloads<TRes> {
  _CopyWithStubImpl$Mutation$DequeueChapterDownloads(this._res);

  TRes _res;

  call({
    Mutation$DequeueChapterDownloads$dequeueChapterDownload?
        dequeueChapterDownload,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$DequeueChapterDownloads$dequeueChapterDownload<TRes>
      get dequeueChapterDownload =>
          CopyWith$Mutation$DequeueChapterDownloads$dequeueChapterDownload.stub(
              _res);
}

const documentNodeMutationDequeueChapterDownloads = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'DequeueChapterDownloads'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'input')),
        type: NamedTypeNode(
          name: NameNode(value: 'DequeueChapterDownloadInput'),
          isNonNull: true,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      )
    ],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'dequeueChapterDownload'),
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
Mutation$DequeueChapterDownloads _parserFn$Mutation$DequeueChapterDownloads(
        Map<String, dynamic> data) =>
    Mutation$DequeueChapterDownloads.fromJson(data);
typedef OnMutationCompleted$Mutation$DequeueChapterDownloads = FutureOr<void>
    Function(
  Map<String, dynamic>?,
  Mutation$DequeueChapterDownloads?,
);

class Options$Mutation$DequeueChapterDownloads
    extends graphql.MutationOptions<Mutation$DequeueChapterDownloads> {
  Options$Mutation$DequeueChapterDownloads({
    String? operationName,
    required Variables$Mutation$DequeueChapterDownloads variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$DequeueChapterDownloads? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$DequeueChapterDownloads? onCompleted,
    graphql.OnMutationUpdate<Mutation$DequeueChapterDownloads>? update,
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
                        : _parserFn$Mutation$DequeueChapterDownloads(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationDequeueChapterDownloads,
          parserFn: _parserFn$Mutation$DequeueChapterDownloads,
        );

  final OnMutationCompleted$Mutation$DequeueChapterDownloads?
      onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$DequeueChapterDownloads
    extends graphql.WatchQueryOptions<Mutation$DequeueChapterDownloads> {
  WatchOptions$Mutation$DequeueChapterDownloads({
    String? operationName,
    required Variables$Mutation$DequeueChapterDownloads variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$DequeueChapterDownloads? typedOptimisticResult,
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
          document: documentNodeMutationDequeueChapterDownloads,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$DequeueChapterDownloads,
        );
}

extension ClientExtension$Mutation$DequeueChapterDownloads
    on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$DequeueChapterDownloads>>
      mutate$DequeueChapterDownloads(
              Options$Mutation$DequeueChapterDownloads options) async =>
          await this.mutate(options);

  graphql.ObservableQuery<Mutation$DequeueChapterDownloads>
      watchMutation$DequeueChapterDownloads(
              WatchOptions$Mutation$DequeueChapterDownloads options) =>
          this.watchMutation(options);
}

class Mutation$DequeueChapterDownloads$HookResult {
  Mutation$DequeueChapterDownloads$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$DequeueChapterDownloads runMutation;

  final graphql.QueryResult<Mutation$DequeueChapterDownloads> result;
}

Mutation$DequeueChapterDownloads$HookResult useMutation$DequeueChapterDownloads(
    [WidgetOptions$Mutation$DequeueChapterDownloads? options]) {
  final result = graphql_flutter
      .useMutation(options ?? WidgetOptions$Mutation$DequeueChapterDownloads());
  return Mutation$DequeueChapterDownloads$HookResult(
    (variables, {optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables.toJson(),
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$DequeueChapterDownloads>
    useWatchMutation$DequeueChapterDownloads(
            WatchOptions$Mutation$DequeueChapterDownloads options) =>
        graphql_flutter.useWatchMutation(options);

class WidgetOptions$Mutation$DequeueChapterDownloads
    extends graphql.MutationOptions<Mutation$DequeueChapterDownloads> {
  WidgetOptions$Mutation$DequeueChapterDownloads({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$DequeueChapterDownloads? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$DequeueChapterDownloads? onCompleted,
    graphql.OnMutationUpdate<Mutation$DequeueChapterDownloads>? update,
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
                        : _parserFn$Mutation$DequeueChapterDownloads(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationDequeueChapterDownloads,
          parserFn: _parserFn$Mutation$DequeueChapterDownloads,
        );

  final OnMutationCompleted$Mutation$DequeueChapterDownloads?
      onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$DequeueChapterDownloads
    = graphql.MultiSourceResult<Mutation$DequeueChapterDownloads> Function(
  Variables$Mutation$DequeueChapterDownloads, {
  Object? optimisticResult,
  Mutation$DequeueChapterDownloads? typedOptimisticResult,
});
typedef Builder$Mutation$DequeueChapterDownloads = widgets.Widget Function(
  RunMutation$Mutation$DequeueChapterDownloads,
  graphql.QueryResult<Mutation$DequeueChapterDownloads>?,
);

class Mutation$DequeueChapterDownloads$Widget
    extends graphql_flutter.Mutation<Mutation$DequeueChapterDownloads> {
  Mutation$DequeueChapterDownloads$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$DequeueChapterDownloads? options,
    required Builder$Mutation$DequeueChapterDownloads builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$DequeueChapterDownloads(),
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

class Mutation$DequeueChapterDownloads$dequeueChapterDownload {
  Mutation$DequeueChapterDownloads$dequeueChapterDownload(
      {this.$__typename = 'DequeueChapterDownloadPayload'});

  factory Mutation$DequeueChapterDownloads$dequeueChapterDownload.fromJson(
      Map<String, dynamic> json) {
    final l$$__typename = json['__typename'];
    return Mutation$DequeueChapterDownloads$dequeueChapterDownload(
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
    if (other is! Mutation$DequeueChapterDownloads$dequeueChapterDownload ||
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

extension UtilityExtension$Mutation$DequeueChapterDownloads$dequeueChapterDownload
    on Mutation$DequeueChapterDownloads$dequeueChapterDownload {
  CopyWith$Mutation$DequeueChapterDownloads$dequeueChapterDownload<
          Mutation$DequeueChapterDownloads$dequeueChapterDownload>
      get copyWith =>
          CopyWith$Mutation$DequeueChapterDownloads$dequeueChapterDownload(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$DequeueChapterDownloads$dequeueChapterDownload<
    TRes> {
  factory CopyWith$Mutation$DequeueChapterDownloads$dequeueChapterDownload(
    Mutation$DequeueChapterDownloads$dequeueChapterDownload instance,
    TRes Function(Mutation$DequeueChapterDownloads$dequeueChapterDownload) then,
  ) = _CopyWithImpl$Mutation$DequeueChapterDownloads$dequeueChapterDownload;

  factory CopyWith$Mutation$DequeueChapterDownloads$dequeueChapterDownload.stub(
          TRes res) =
      _CopyWithStubImpl$Mutation$DequeueChapterDownloads$dequeueChapterDownload;

  TRes call({String? $__typename});
}

class _CopyWithImpl$Mutation$DequeueChapterDownloads$dequeueChapterDownload<
        TRes>
    implements
        CopyWith$Mutation$DequeueChapterDownloads$dequeueChapterDownload<TRes> {
  _CopyWithImpl$Mutation$DequeueChapterDownloads$dequeueChapterDownload(
    this._instance,
    this._then,
  );

  final Mutation$DequeueChapterDownloads$dequeueChapterDownload _instance;

  final TRes Function(Mutation$DequeueChapterDownloads$dequeueChapterDownload)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? $__typename = _undefined}) =>
      _then(Mutation$DequeueChapterDownloads$dequeueChapterDownload(
          $__typename: $__typename == _undefined || $__typename == null
              ? _instance.$__typename
              : ($__typename as String)));
}

class _CopyWithStubImpl$Mutation$DequeueChapterDownloads$dequeueChapterDownload<
        TRes>
    implements
        CopyWith$Mutation$DequeueChapterDownloads$dequeueChapterDownload<TRes> {
  _CopyWithStubImpl$Mutation$DequeueChapterDownloads$dequeueChapterDownload(
      this._res);

  TRes _res;

  call({String? $__typename}) => _res;
}

class Variables$Mutation$StopDownloader {
  factory Variables$Mutation$StopDownloader(
          {required Input$StopDownloaderInput input}) =>
      Variables$Mutation$StopDownloader._({
        r'input': input,
      });

  Variables$Mutation$StopDownloader._(this._$data);

  factory Variables$Mutation$StopDownloader.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$input = data['input'];
    result$data['input'] =
        Input$StopDownloaderInput.fromJson((l$input as Map<String, dynamic>));
    return Variables$Mutation$StopDownloader._(result$data);
  }

  Map<String, dynamic> _$data;

  Input$StopDownloaderInput get input =>
      (_$data['input'] as Input$StopDownloaderInput);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$input = input;
    result$data['input'] = l$input.toJson();
    return result$data;
  }

  CopyWith$Variables$Mutation$StopDownloader<Variables$Mutation$StopDownloader>
      get copyWith => CopyWith$Variables$Mutation$StopDownloader(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$StopDownloader ||
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

abstract class CopyWith$Variables$Mutation$StopDownloader<TRes> {
  factory CopyWith$Variables$Mutation$StopDownloader(
    Variables$Mutation$StopDownloader instance,
    TRes Function(Variables$Mutation$StopDownloader) then,
  ) = _CopyWithImpl$Variables$Mutation$StopDownloader;

  factory CopyWith$Variables$Mutation$StopDownloader.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$StopDownloader;

  TRes call({Input$StopDownloaderInput? input});
}

class _CopyWithImpl$Variables$Mutation$StopDownloader<TRes>
    implements CopyWith$Variables$Mutation$StopDownloader<TRes> {
  _CopyWithImpl$Variables$Mutation$StopDownloader(
    this._instance,
    this._then,
  );

  final Variables$Mutation$StopDownloader _instance;

  final TRes Function(Variables$Mutation$StopDownloader) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? input = _undefined}) =>
      _then(Variables$Mutation$StopDownloader._({
        ..._instance._$data,
        if (input != _undefined && input != null)
          'input': (input as Input$StopDownloaderInput),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$StopDownloader<TRes>
    implements CopyWith$Variables$Mutation$StopDownloader<TRes> {
  _CopyWithStubImpl$Variables$Mutation$StopDownloader(this._res);

  TRes _res;

  call({Input$StopDownloaderInput? input}) => _res;
}

class Mutation$StopDownloader {
  Mutation$StopDownloader({
    this.stopDownloader,
    this.$__typename = 'Mutation',
  });

  factory Mutation$StopDownloader.fromJson(Map<String, dynamic> json) {
    final l$stopDownloader = json['stopDownloader'];
    final l$$__typename = json['__typename'];
    return Mutation$StopDownloader(
      stopDownloader: l$stopDownloader == null
          ? null
          : Mutation$StopDownloader$stopDownloader.fromJson(
              (l$stopDownloader as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$StopDownloader$stopDownloader? stopDownloader;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$stopDownloader = stopDownloader;
    _resultData['stopDownloader'] = l$stopDownloader?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$stopDownloader = stopDownloader;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$stopDownloader,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$StopDownloader || runtimeType != other.runtimeType) {
      return false;
    }
    final l$stopDownloader = stopDownloader;
    final lOther$stopDownloader = other.stopDownloader;
    if (l$stopDownloader != lOther$stopDownloader) {
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

extension UtilityExtension$Mutation$StopDownloader on Mutation$StopDownloader {
  CopyWith$Mutation$StopDownloader<Mutation$StopDownloader> get copyWith =>
      CopyWith$Mutation$StopDownloader(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Mutation$StopDownloader<TRes> {
  factory CopyWith$Mutation$StopDownloader(
    Mutation$StopDownloader instance,
    TRes Function(Mutation$StopDownloader) then,
  ) = _CopyWithImpl$Mutation$StopDownloader;

  factory CopyWith$Mutation$StopDownloader.stub(TRes res) =
      _CopyWithStubImpl$Mutation$StopDownloader;

  TRes call({
    Mutation$StopDownloader$stopDownloader? stopDownloader,
    String? $__typename,
  });
  CopyWith$Mutation$StopDownloader$stopDownloader<TRes> get stopDownloader;
}

class _CopyWithImpl$Mutation$StopDownloader<TRes>
    implements CopyWith$Mutation$StopDownloader<TRes> {
  _CopyWithImpl$Mutation$StopDownloader(
    this._instance,
    this._then,
  );

  final Mutation$StopDownloader _instance;

  final TRes Function(Mutation$StopDownloader) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? stopDownloader = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$StopDownloader(
        stopDownloader: stopDownloader == _undefined
            ? _instance.stopDownloader
            : (stopDownloader as Mutation$StopDownloader$stopDownloader?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$StopDownloader$stopDownloader<TRes> get stopDownloader {
    final local$stopDownloader = _instance.stopDownloader;
    return local$stopDownloader == null
        ? CopyWith$Mutation$StopDownloader$stopDownloader.stub(_then(_instance))
        : CopyWith$Mutation$StopDownloader$stopDownloader(
            local$stopDownloader, (e) => call(stopDownloader: e));
  }
}

class _CopyWithStubImpl$Mutation$StopDownloader<TRes>
    implements CopyWith$Mutation$StopDownloader<TRes> {
  _CopyWithStubImpl$Mutation$StopDownloader(this._res);

  TRes _res;

  call({
    Mutation$StopDownloader$stopDownloader? stopDownloader,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$StopDownloader$stopDownloader<TRes> get stopDownloader =>
      CopyWith$Mutation$StopDownloader$stopDownloader.stub(_res);
}

const documentNodeMutationStopDownloader = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'StopDownloader'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'input')),
        type: NamedTypeNode(
          name: NameNode(value: 'StopDownloaderInput'),
          isNonNull: true,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      )
    ],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'stopDownloader'),
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
Mutation$StopDownloader _parserFn$Mutation$StopDownloader(
        Map<String, dynamic> data) =>
    Mutation$StopDownloader.fromJson(data);
typedef OnMutationCompleted$Mutation$StopDownloader = FutureOr<void> Function(
  Map<String, dynamic>?,
  Mutation$StopDownloader?,
);

class Options$Mutation$StopDownloader
    extends graphql.MutationOptions<Mutation$StopDownloader> {
  Options$Mutation$StopDownloader({
    String? operationName,
    required Variables$Mutation$StopDownloader variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$StopDownloader? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$StopDownloader? onCompleted,
    graphql.OnMutationUpdate<Mutation$StopDownloader>? update,
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
                        : _parserFn$Mutation$StopDownloader(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationStopDownloader,
          parserFn: _parserFn$Mutation$StopDownloader,
        );

  final OnMutationCompleted$Mutation$StopDownloader? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$StopDownloader
    extends graphql.WatchQueryOptions<Mutation$StopDownloader> {
  WatchOptions$Mutation$StopDownloader({
    String? operationName,
    required Variables$Mutation$StopDownloader variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$StopDownloader? typedOptimisticResult,
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
          document: documentNodeMutationStopDownloader,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$StopDownloader,
        );
}

extension ClientExtension$Mutation$StopDownloader on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$StopDownloader>> mutate$StopDownloader(
          Options$Mutation$StopDownloader options) async =>
      await this.mutate(options);

  graphql.ObservableQuery<Mutation$StopDownloader> watchMutation$StopDownloader(
          WatchOptions$Mutation$StopDownloader options) =>
      this.watchMutation(options);
}

class Mutation$StopDownloader$HookResult {
  Mutation$StopDownloader$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$StopDownloader runMutation;

  final graphql.QueryResult<Mutation$StopDownloader> result;
}

Mutation$StopDownloader$HookResult useMutation$StopDownloader(
    [WidgetOptions$Mutation$StopDownloader? options]) {
  final result = graphql_flutter
      .useMutation(options ?? WidgetOptions$Mutation$StopDownloader());
  return Mutation$StopDownloader$HookResult(
    (variables, {optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables.toJson(),
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$StopDownloader>
    useWatchMutation$StopDownloader(
            WatchOptions$Mutation$StopDownloader options) =>
        graphql_flutter.useWatchMutation(options);

class WidgetOptions$Mutation$StopDownloader
    extends graphql.MutationOptions<Mutation$StopDownloader> {
  WidgetOptions$Mutation$StopDownloader({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$StopDownloader? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$StopDownloader? onCompleted,
    graphql.OnMutationUpdate<Mutation$StopDownloader>? update,
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
                        : _parserFn$Mutation$StopDownloader(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationStopDownloader,
          parserFn: _parserFn$Mutation$StopDownloader,
        );

  final OnMutationCompleted$Mutation$StopDownloader? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$StopDownloader
    = graphql.MultiSourceResult<Mutation$StopDownloader> Function(
  Variables$Mutation$StopDownloader, {
  Object? optimisticResult,
  Mutation$StopDownloader? typedOptimisticResult,
});
typedef Builder$Mutation$StopDownloader = widgets.Widget Function(
  RunMutation$Mutation$StopDownloader,
  graphql.QueryResult<Mutation$StopDownloader>?,
);

class Mutation$StopDownloader$Widget
    extends graphql_flutter.Mutation<Mutation$StopDownloader> {
  Mutation$StopDownloader$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$StopDownloader? options,
    required Builder$Mutation$StopDownloader builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$StopDownloader(),
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

class Mutation$StopDownloader$stopDownloader {
  Mutation$StopDownloader$stopDownloader(
      {this.$__typename = 'StopDownloaderPayload'});

  factory Mutation$StopDownloader$stopDownloader.fromJson(
      Map<String, dynamic> json) {
    final l$$__typename = json['__typename'];
    return Mutation$StopDownloader$stopDownloader(
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
    if (other is! Mutation$StopDownloader$stopDownloader ||
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

extension UtilityExtension$Mutation$StopDownloader$stopDownloader
    on Mutation$StopDownloader$stopDownloader {
  CopyWith$Mutation$StopDownloader$stopDownloader<
          Mutation$StopDownloader$stopDownloader>
      get copyWith => CopyWith$Mutation$StopDownloader$stopDownloader(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$StopDownloader$stopDownloader<TRes> {
  factory CopyWith$Mutation$StopDownloader$stopDownloader(
    Mutation$StopDownloader$stopDownloader instance,
    TRes Function(Mutation$StopDownloader$stopDownloader) then,
  ) = _CopyWithImpl$Mutation$StopDownloader$stopDownloader;

  factory CopyWith$Mutation$StopDownloader$stopDownloader.stub(TRes res) =
      _CopyWithStubImpl$Mutation$StopDownloader$stopDownloader;

  TRes call({String? $__typename});
}

class _CopyWithImpl$Mutation$StopDownloader$stopDownloader<TRes>
    implements CopyWith$Mutation$StopDownloader$stopDownloader<TRes> {
  _CopyWithImpl$Mutation$StopDownloader$stopDownloader(
    this._instance,
    this._then,
  );

  final Mutation$StopDownloader$stopDownloader _instance;

  final TRes Function(Mutation$StopDownloader$stopDownloader) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? $__typename = _undefined}) =>
      _then(Mutation$StopDownloader$stopDownloader(
          $__typename: $__typename == _undefined || $__typename == null
              ? _instance.$__typename
              : ($__typename as String)));
}

class _CopyWithStubImpl$Mutation$StopDownloader$stopDownloader<TRes>
    implements CopyWith$Mutation$StopDownloader$stopDownloader<TRes> {
  _CopyWithStubImpl$Mutation$StopDownloader$stopDownloader(this._res);

  TRes _res;

  call({String? $__typename}) => _res;
}

class Variables$Mutation$StartDownloader {
  factory Variables$Mutation$StartDownloader(
          {required Input$StartDownloaderInput input}) =>
      Variables$Mutation$StartDownloader._({
        r'input': input,
      });

  Variables$Mutation$StartDownloader._(this._$data);

  factory Variables$Mutation$StartDownloader.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$input = data['input'];
    result$data['input'] =
        Input$StartDownloaderInput.fromJson((l$input as Map<String, dynamic>));
    return Variables$Mutation$StartDownloader._(result$data);
  }

  Map<String, dynamic> _$data;

  Input$StartDownloaderInput get input =>
      (_$data['input'] as Input$StartDownloaderInput);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$input = input;
    result$data['input'] = l$input.toJson();
    return result$data;
  }

  CopyWith$Variables$Mutation$StartDownloader<
          Variables$Mutation$StartDownloader>
      get copyWith => CopyWith$Variables$Mutation$StartDownloader(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$StartDownloader ||
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

abstract class CopyWith$Variables$Mutation$StartDownloader<TRes> {
  factory CopyWith$Variables$Mutation$StartDownloader(
    Variables$Mutation$StartDownloader instance,
    TRes Function(Variables$Mutation$StartDownloader) then,
  ) = _CopyWithImpl$Variables$Mutation$StartDownloader;

  factory CopyWith$Variables$Mutation$StartDownloader.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$StartDownloader;

  TRes call({Input$StartDownloaderInput? input});
}

class _CopyWithImpl$Variables$Mutation$StartDownloader<TRes>
    implements CopyWith$Variables$Mutation$StartDownloader<TRes> {
  _CopyWithImpl$Variables$Mutation$StartDownloader(
    this._instance,
    this._then,
  );

  final Variables$Mutation$StartDownloader _instance;

  final TRes Function(Variables$Mutation$StartDownloader) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? input = _undefined}) =>
      _then(Variables$Mutation$StartDownloader._({
        ..._instance._$data,
        if (input != _undefined && input != null)
          'input': (input as Input$StartDownloaderInput),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$StartDownloader<TRes>
    implements CopyWith$Variables$Mutation$StartDownloader<TRes> {
  _CopyWithStubImpl$Variables$Mutation$StartDownloader(this._res);

  TRes _res;

  call({Input$StartDownloaderInput? input}) => _res;
}

class Mutation$StartDownloader {
  Mutation$StartDownloader({
    this.startDownloader,
    this.$__typename = 'Mutation',
  });

  factory Mutation$StartDownloader.fromJson(Map<String, dynamic> json) {
    final l$startDownloader = json['startDownloader'];
    final l$$__typename = json['__typename'];
    return Mutation$StartDownloader(
      startDownloader: l$startDownloader == null
          ? null
          : Mutation$StartDownloader$startDownloader.fromJson(
              (l$startDownloader as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$StartDownloader$startDownloader? startDownloader;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$startDownloader = startDownloader;
    _resultData['startDownloader'] = l$startDownloader?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$startDownloader = startDownloader;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$startDownloader,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$StartDownloader ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$startDownloader = startDownloader;
    final lOther$startDownloader = other.startDownloader;
    if (l$startDownloader != lOther$startDownloader) {
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

extension UtilityExtension$Mutation$StartDownloader
    on Mutation$StartDownloader {
  CopyWith$Mutation$StartDownloader<Mutation$StartDownloader> get copyWith =>
      CopyWith$Mutation$StartDownloader(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Mutation$StartDownloader<TRes> {
  factory CopyWith$Mutation$StartDownloader(
    Mutation$StartDownloader instance,
    TRes Function(Mutation$StartDownloader) then,
  ) = _CopyWithImpl$Mutation$StartDownloader;

  factory CopyWith$Mutation$StartDownloader.stub(TRes res) =
      _CopyWithStubImpl$Mutation$StartDownloader;

  TRes call({
    Mutation$StartDownloader$startDownloader? startDownloader,
    String? $__typename,
  });
  CopyWith$Mutation$StartDownloader$startDownloader<TRes> get startDownloader;
}

class _CopyWithImpl$Mutation$StartDownloader<TRes>
    implements CopyWith$Mutation$StartDownloader<TRes> {
  _CopyWithImpl$Mutation$StartDownloader(
    this._instance,
    this._then,
  );

  final Mutation$StartDownloader _instance;

  final TRes Function(Mutation$StartDownloader) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? startDownloader = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$StartDownloader(
        startDownloader: startDownloader == _undefined
            ? _instance.startDownloader
            : (startDownloader as Mutation$StartDownloader$startDownloader?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$StartDownloader$startDownloader<TRes> get startDownloader {
    final local$startDownloader = _instance.startDownloader;
    return local$startDownloader == null
        ? CopyWith$Mutation$StartDownloader$startDownloader.stub(
            _then(_instance))
        : CopyWith$Mutation$StartDownloader$startDownloader(
            local$startDownloader, (e) => call(startDownloader: e));
  }
}

class _CopyWithStubImpl$Mutation$StartDownloader<TRes>
    implements CopyWith$Mutation$StartDownloader<TRes> {
  _CopyWithStubImpl$Mutation$StartDownloader(this._res);

  TRes _res;

  call({
    Mutation$StartDownloader$startDownloader? startDownloader,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$StartDownloader$startDownloader<TRes> get startDownloader =>
      CopyWith$Mutation$StartDownloader$startDownloader.stub(_res);
}

const documentNodeMutationStartDownloader = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'StartDownloader'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'input')),
        type: NamedTypeNode(
          name: NameNode(value: 'StartDownloaderInput'),
          isNonNull: true,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      )
    ],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'startDownloader'),
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
Mutation$StartDownloader _parserFn$Mutation$StartDownloader(
        Map<String, dynamic> data) =>
    Mutation$StartDownloader.fromJson(data);
typedef OnMutationCompleted$Mutation$StartDownloader = FutureOr<void> Function(
  Map<String, dynamic>?,
  Mutation$StartDownloader?,
);

class Options$Mutation$StartDownloader
    extends graphql.MutationOptions<Mutation$StartDownloader> {
  Options$Mutation$StartDownloader({
    String? operationName,
    required Variables$Mutation$StartDownloader variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$StartDownloader? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$StartDownloader? onCompleted,
    graphql.OnMutationUpdate<Mutation$StartDownloader>? update,
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
                        : _parserFn$Mutation$StartDownloader(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationStartDownloader,
          parserFn: _parserFn$Mutation$StartDownloader,
        );

  final OnMutationCompleted$Mutation$StartDownloader? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$StartDownloader
    extends graphql.WatchQueryOptions<Mutation$StartDownloader> {
  WatchOptions$Mutation$StartDownloader({
    String? operationName,
    required Variables$Mutation$StartDownloader variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$StartDownloader? typedOptimisticResult,
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
          document: documentNodeMutationStartDownloader,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$StartDownloader,
        );
}

extension ClientExtension$Mutation$StartDownloader on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$StartDownloader>> mutate$StartDownloader(
          Options$Mutation$StartDownloader options) async =>
      await this.mutate(options);

  graphql.ObservableQuery<Mutation$StartDownloader>
      watchMutation$StartDownloader(
              WatchOptions$Mutation$StartDownloader options) =>
          this.watchMutation(options);
}

class Mutation$StartDownloader$HookResult {
  Mutation$StartDownloader$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$StartDownloader runMutation;

  final graphql.QueryResult<Mutation$StartDownloader> result;
}

Mutation$StartDownloader$HookResult useMutation$StartDownloader(
    [WidgetOptions$Mutation$StartDownloader? options]) {
  final result = graphql_flutter
      .useMutation(options ?? WidgetOptions$Mutation$StartDownloader());
  return Mutation$StartDownloader$HookResult(
    (variables, {optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables.toJson(),
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$StartDownloader>
    useWatchMutation$StartDownloader(
            WatchOptions$Mutation$StartDownloader options) =>
        graphql_flutter.useWatchMutation(options);

class WidgetOptions$Mutation$StartDownloader
    extends graphql.MutationOptions<Mutation$StartDownloader> {
  WidgetOptions$Mutation$StartDownloader({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$StartDownloader? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$StartDownloader? onCompleted,
    graphql.OnMutationUpdate<Mutation$StartDownloader>? update,
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
                        : _parserFn$Mutation$StartDownloader(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationStartDownloader,
          parserFn: _parserFn$Mutation$StartDownloader,
        );

  final OnMutationCompleted$Mutation$StartDownloader? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$StartDownloader
    = graphql.MultiSourceResult<Mutation$StartDownloader> Function(
  Variables$Mutation$StartDownloader, {
  Object? optimisticResult,
  Mutation$StartDownloader? typedOptimisticResult,
});
typedef Builder$Mutation$StartDownloader = widgets.Widget Function(
  RunMutation$Mutation$StartDownloader,
  graphql.QueryResult<Mutation$StartDownloader>?,
);

class Mutation$StartDownloader$Widget
    extends graphql_flutter.Mutation<Mutation$StartDownloader> {
  Mutation$StartDownloader$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$StartDownloader? options,
    required Builder$Mutation$StartDownloader builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$StartDownloader(),
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

class Mutation$StartDownloader$startDownloader {
  Mutation$StartDownloader$startDownloader(
      {this.$__typename = 'StartDownloaderPayload'});

  factory Mutation$StartDownloader$startDownloader.fromJson(
      Map<String, dynamic> json) {
    final l$$__typename = json['__typename'];
    return Mutation$StartDownloader$startDownloader(
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
    if (other is! Mutation$StartDownloader$startDownloader ||
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

extension UtilityExtension$Mutation$StartDownloader$startDownloader
    on Mutation$StartDownloader$startDownloader {
  CopyWith$Mutation$StartDownloader$startDownloader<
          Mutation$StartDownloader$startDownloader>
      get copyWith => CopyWith$Mutation$StartDownloader$startDownloader(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$StartDownloader$startDownloader<TRes> {
  factory CopyWith$Mutation$StartDownloader$startDownloader(
    Mutation$StartDownloader$startDownloader instance,
    TRes Function(Mutation$StartDownloader$startDownloader) then,
  ) = _CopyWithImpl$Mutation$StartDownloader$startDownloader;

  factory CopyWith$Mutation$StartDownloader$startDownloader.stub(TRes res) =
      _CopyWithStubImpl$Mutation$StartDownloader$startDownloader;

  TRes call({String? $__typename});
}

class _CopyWithImpl$Mutation$StartDownloader$startDownloader<TRes>
    implements CopyWith$Mutation$StartDownloader$startDownloader<TRes> {
  _CopyWithImpl$Mutation$StartDownloader$startDownloader(
    this._instance,
    this._then,
  );

  final Mutation$StartDownloader$startDownloader _instance;

  final TRes Function(Mutation$StartDownloader$startDownloader) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? $__typename = _undefined}) =>
      _then(Mutation$StartDownloader$startDownloader(
          $__typename: $__typename == _undefined || $__typename == null
              ? _instance.$__typename
              : ($__typename as String)));
}

class _CopyWithStubImpl$Mutation$StartDownloader$startDownloader<TRes>
    implements CopyWith$Mutation$StartDownloader$startDownloader<TRes> {
  _CopyWithStubImpl$Mutation$StartDownloader$startDownloader(this._res);

  TRes _res;

  call({String? $__typename}) => _res;
}

class Variables$Mutation$ClearDownloader {
  factory Variables$Mutation$ClearDownloader(
          {required Input$ClearDownloaderInput input}) =>
      Variables$Mutation$ClearDownloader._({
        r'input': input,
      });

  Variables$Mutation$ClearDownloader._(this._$data);

  factory Variables$Mutation$ClearDownloader.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$input = data['input'];
    result$data['input'] =
        Input$ClearDownloaderInput.fromJson((l$input as Map<String, dynamic>));
    return Variables$Mutation$ClearDownloader._(result$data);
  }

  Map<String, dynamic> _$data;

  Input$ClearDownloaderInput get input =>
      (_$data['input'] as Input$ClearDownloaderInput);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$input = input;
    result$data['input'] = l$input.toJson();
    return result$data;
  }

  CopyWith$Variables$Mutation$ClearDownloader<
          Variables$Mutation$ClearDownloader>
      get copyWith => CopyWith$Variables$Mutation$ClearDownloader(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$ClearDownloader ||
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

abstract class CopyWith$Variables$Mutation$ClearDownloader<TRes> {
  factory CopyWith$Variables$Mutation$ClearDownloader(
    Variables$Mutation$ClearDownloader instance,
    TRes Function(Variables$Mutation$ClearDownloader) then,
  ) = _CopyWithImpl$Variables$Mutation$ClearDownloader;

  factory CopyWith$Variables$Mutation$ClearDownloader.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$ClearDownloader;

  TRes call({Input$ClearDownloaderInput? input});
}

class _CopyWithImpl$Variables$Mutation$ClearDownloader<TRes>
    implements CopyWith$Variables$Mutation$ClearDownloader<TRes> {
  _CopyWithImpl$Variables$Mutation$ClearDownloader(
    this._instance,
    this._then,
  );

  final Variables$Mutation$ClearDownloader _instance;

  final TRes Function(Variables$Mutation$ClearDownloader) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? input = _undefined}) =>
      _then(Variables$Mutation$ClearDownloader._({
        ..._instance._$data,
        if (input != _undefined && input != null)
          'input': (input as Input$ClearDownloaderInput),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$ClearDownloader<TRes>
    implements CopyWith$Variables$Mutation$ClearDownloader<TRes> {
  _CopyWithStubImpl$Variables$Mutation$ClearDownloader(this._res);

  TRes _res;

  call({Input$ClearDownloaderInput? input}) => _res;
}

class Mutation$ClearDownloader {
  Mutation$ClearDownloader({
    this.clearDownloader,
    this.$__typename = 'Mutation',
  });

  factory Mutation$ClearDownloader.fromJson(Map<String, dynamic> json) {
    final l$clearDownloader = json['clearDownloader'];
    final l$$__typename = json['__typename'];
    return Mutation$ClearDownloader(
      clearDownloader: l$clearDownloader == null
          ? null
          : Mutation$ClearDownloader$clearDownloader.fromJson(
              (l$clearDownloader as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$ClearDownloader$clearDownloader? clearDownloader;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$clearDownloader = clearDownloader;
    _resultData['clearDownloader'] = l$clearDownloader?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$clearDownloader = clearDownloader;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$clearDownloader,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$ClearDownloader ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$clearDownloader = clearDownloader;
    final lOther$clearDownloader = other.clearDownloader;
    if (l$clearDownloader != lOther$clearDownloader) {
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

extension UtilityExtension$Mutation$ClearDownloader
    on Mutation$ClearDownloader {
  CopyWith$Mutation$ClearDownloader<Mutation$ClearDownloader> get copyWith =>
      CopyWith$Mutation$ClearDownloader(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Mutation$ClearDownloader<TRes> {
  factory CopyWith$Mutation$ClearDownloader(
    Mutation$ClearDownloader instance,
    TRes Function(Mutation$ClearDownloader) then,
  ) = _CopyWithImpl$Mutation$ClearDownloader;

  factory CopyWith$Mutation$ClearDownloader.stub(TRes res) =
      _CopyWithStubImpl$Mutation$ClearDownloader;

  TRes call({
    Mutation$ClearDownloader$clearDownloader? clearDownloader,
    String? $__typename,
  });
  CopyWith$Mutation$ClearDownloader$clearDownloader<TRes> get clearDownloader;
}

class _CopyWithImpl$Mutation$ClearDownloader<TRes>
    implements CopyWith$Mutation$ClearDownloader<TRes> {
  _CopyWithImpl$Mutation$ClearDownloader(
    this._instance,
    this._then,
  );

  final Mutation$ClearDownloader _instance;

  final TRes Function(Mutation$ClearDownloader) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? clearDownloader = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$ClearDownloader(
        clearDownloader: clearDownloader == _undefined
            ? _instance.clearDownloader
            : (clearDownloader as Mutation$ClearDownloader$clearDownloader?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$ClearDownloader$clearDownloader<TRes> get clearDownloader {
    final local$clearDownloader = _instance.clearDownloader;
    return local$clearDownloader == null
        ? CopyWith$Mutation$ClearDownloader$clearDownloader.stub(
            _then(_instance))
        : CopyWith$Mutation$ClearDownloader$clearDownloader(
            local$clearDownloader, (e) => call(clearDownloader: e));
  }
}

class _CopyWithStubImpl$Mutation$ClearDownloader<TRes>
    implements CopyWith$Mutation$ClearDownloader<TRes> {
  _CopyWithStubImpl$Mutation$ClearDownloader(this._res);

  TRes _res;

  call({
    Mutation$ClearDownloader$clearDownloader? clearDownloader,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$ClearDownloader$clearDownloader<TRes> get clearDownloader =>
      CopyWith$Mutation$ClearDownloader$clearDownloader.stub(_res);
}

const documentNodeMutationClearDownloader = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'ClearDownloader'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'input')),
        type: NamedTypeNode(
          name: NameNode(value: 'ClearDownloaderInput'),
          isNonNull: true,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      )
    ],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'clearDownloader'),
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
Mutation$ClearDownloader _parserFn$Mutation$ClearDownloader(
        Map<String, dynamic> data) =>
    Mutation$ClearDownloader.fromJson(data);
typedef OnMutationCompleted$Mutation$ClearDownloader = FutureOr<void> Function(
  Map<String, dynamic>?,
  Mutation$ClearDownloader?,
);

class Options$Mutation$ClearDownloader
    extends graphql.MutationOptions<Mutation$ClearDownloader> {
  Options$Mutation$ClearDownloader({
    String? operationName,
    required Variables$Mutation$ClearDownloader variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$ClearDownloader? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$ClearDownloader? onCompleted,
    graphql.OnMutationUpdate<Mutation$ClearDownloader>? update,
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
                        : _parserFn$Mutation$ClearDownloader(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationClearDownloader,
          parserFn: _parserFn$Mutation$ClearDownloader,
        );

  final OnMutationCompleted$Mutation$ClearDownloader? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$ClearDownloader
    extends graphql.WatchQueryOptions<Mutation$ClearDownloader> {
  WatchOptions$Mutation$ClearDownloader({
    String? operationName,
    required Variables$Mutation$ClearDownloader variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$ClearDownloader? typedOptimisticResult,
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
          document: documentNodeMutationClearDownloader,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$ClearDownloader,
        );
}

extension ClientExtension$Mutation$ClearDownloader on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$ClearDownloader>> mutate$ClearDownloader(
          Options$Mutation$ClearDownloader options) async =>
      await this.mutate(options);

  graphql.ObservableQuery<Mutation$ClearDownloader>
      watchMutation$ClearDownloader(
              WatchOptions$Mutation$ClearDownloader options) =>
          this.watchMutation(options);
}

class Mutation$ClearDownloader$HookResult {
  Mutation$ClearDownloader$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$ClearDownloader runMutation;

  final graphql.QueryResult<Mutation$ClearDownloader> result;
}

Mutation$ClearDownloader$HookResult useMutation$ClearDownloader(
    [WidgetOptions$Mutation$ClearDownloader? options]) {
  final result = graphql_flutter
      .useMutation(options ?? WidgetOptions$Mutation$ClearDownloader());
  return Mutation$ClearDownloader$HookResult(
    (variables, {optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables.toJson(),
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$ClearDownloader>
    useWatchMutation$ClearDownloader(
            WatchOptions$Mutation$ClearDownloader options) =>
        graphql_flutter.useWatchMutation(options);

class WidgetOptions$Mutation$ClearDownloader
    extends graphql.MutationOptions<Mutation$ClearDownloader> {
  WidgetOptions$Mutation$ClearDownloader({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$ClearDownloader? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$ClearDownloader? onCompleted,
    graphql.OnMutationUpdate<Mutation$ClearDownloader>? update,
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
                        : _parserFn$Mutation$ClearDownloader(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationClearDownloader,
          parserFn: _parserFn$Mutation$ClearDownloader,
        );

  final OnMutationCompleted$Mutation$ClearDownloader? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$ClearDownloader
    = graphql.MultiSourceResult<Mutation$ClearDownloader> Function(
  Variables$Mutation$ClearDownloader, {
  Object? optimisticResult,
  Mutation$ClearDownloader? typedOptimisticResult,
});
typedef Builder$Mutation$ClearDownloader = widgets.Widget Function(
  RunMutation$Mutation$ClearDownloader,
  graphql.QueryResult<Mutation$ClearDownloader>?,
);

class Mutation$ClearDownloader$Widget
    extends graphql_flutter.Mutation<Mutation$ClearDownloader> {
  Mutation$ClearDownloader$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$ClearDownloader? options,
    required Builder$Mutation$ClearDownloader builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$ClearDownloader(),
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

class Mutation$ClearDownloader$clearDownloader {
  Mutation$ClearDownloader$clearDownloader(
      {this.$__typename = 'ClearDownloaderPayload'});

  factory Mutation$ClearDownloader$clearDownloader.fromJson(
      Map<String, dynamic> json) {
    final l$$__typename = json['__typename'];
    return Mutation$ClearDownloader$clearDownloader(
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
    if (other is! Mutation$ClearDownloader$clearDownloader ||
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

extension UtilityExtension$Mutation$ClearDownloader$clearDownloader
    on Mutation$ClearDownloader$clearDownloader {
  CopyWith$Mutation$ClearDownloader$clearDownloader<
          Mutation$ClearDownloader$clearDownloader>
      get copyWith => CopyWith$Mutation$ClearDownloader$clearDownloader(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$ClearDownloader$clearDownloader<TRes> {
  factory CopyWith$Mutation$ClearDownloader$clearDownloader(
    Mutation$ClearDownloader$clearDownloader instance,
    TRes Function(Mutation$ClearDownloader$clearDownloader) then,
  ) = _CopyWithImpl$Mutation$ClearDownloader$clearDownloader;

  factory CopyWith$Mutation$ClearDownloader$clearDownloader.stub(TRes res) =
      _CopyWithStubImpl$Mutation$ClearDownloader$clearDownloader;

  TRes call({String? $__typename});
}

class _CopyWithImpl$Mutation$ClearDownloader$clearDownloader<TRes>
    implements CopyWith$Mutation$ClearDownloader$clearDownloader<TRes> {
  _CopyWithImpl$Mutation$ClearDownloader$clearDownloader(
    this._instance,
    this._then,
  );

  final Mutation$ClearDownloader$clearDownloader _instance;

  final TRes Function(Mutation$ClearDownloader$clearDownloader) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? $__typename = _undefined}) =>
      _then(Mutation$ClearDownloader$clearDownloader(
          $__typename: $__typename == _undefined || $__typename == null
              ? _instance.$__typename
              : ($__typename as String)));
}

class _CopyWithStubImpl$Mutation$ClearDownloader$clearDownloader<TRes>
    implements CopyWith$Mutation$ClearDownloader$clearDownloader<TRes> {
  _CopyWithStubImpl$Mutation$ClearDownloader$clearDownloader(this._res);

  TRes _res;

  call({String? $__typename}) => _res;
}

class Variables$Mutation$ReorderChapterDownload {
  factory Variables$Mutation$ReorderChapterDownload(
          {required Input$ReorderChapterDownloadInput input}) =>
      Variables$Mutation$ReorderChapterDownload._({
        r'input': input,
      });

  Variables$Mutation$ReorderChapterDownload._(this._$data);

  factory Variables$Mutation$ReorderChapterDownload.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$input = data['input'];
    result$data['input'] = Input$ReorderChapterDownloadInput.fromJson(
        (l$input as Map<String, dynamic>));
    return Variables$Mutation$ReorderChapterDownload._(result$data);
  }

  Map<String, dynamic> _$data;

  Input$ReorderChapterDownloadInput get input =>
      (_$data['input'] as Input$ReorderChapterDownloadInput);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$input = input;
    result$data['input'] = l$input.toJson();
    return result$data;
  }

  CopyWith$Variables$Mutation$ReorderChapterDownload<
          Variables$Mutation$ReorderChapterDownload>
      get copyWith => CopyWith$Variables$Mutation$ReorderChapterDownload(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$ReorderChapterDownload ||
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

abstract class CopyWith$Variables$Mutation$ReorderChapterDownload<TRes> {
  factory CopyWith$Variables$Mutation$ReorderChapterDownload(
    Variables$Mutation$ReorderChapterDownload instance,
    TRes Function(Variables$Mutation$ReorderChapterDownload) then,
  ) = _CopyWithImpl$Variables$Mutation$ReorderChapterDownload;

  factory CopyWith$Variables$Mutation$ReorderChapterDownload.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$ReorderChapterDownload;

  TRes call({Input$ReorderChapterDownloadInput? input});
}

class _CopyWithImpl$Variables$Mutation$ReorderChapterDownload<TRes>
    implements CopyWith$Variables$Mutation$ReorderChapterDownload<TRes> {
  _CopyWithImpl$Variables$Mutation$ReorderChapterDownload(
    this._instance,
    this._then,
  );

  final Variables$Mutation$ReorderChapterDownload _instance;

  final TRes Function(Variables$Mutation$ReorderChapterDownload) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? input = _undefined}) =>
      _then(Variables$Mutation$ReorderChapterDownload._({
        ..._instance._$data,
        if (input != _undefined && input != null)
          'input': (input as Input$ReorderChapterDownloadInput),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$ReorderChapterDownload<TRes>
    implements CopyWith$Variables$Mutation$ReorderChapterDownload<TRes> {
  _CopyWithStubImpl$Variables$Mutation$ReorderChapterDownload(this._res);

  TRes _res;

  call({Input$ReorderChapterDownloadInput? input}) => _res;
}

class Mutation$ReorderChapterDownload {
  Mutation$ReorderChapterDownload({
    this.reorderChapterDownload,
    this.$__typename = 'Mutation',
  });

  factory Mutation$ReorderChapterDownload.fromJson(Map<String, dynamic> json) {
    final l$reorderChapterDownload = json['reorderChapterDownload'];
    final l$$__typename = json['__typename'];
    return Mutation$ReorderChapterDownload(
      reorderChapterDownload: l$reorderChapterDownload == null
          ? null
          : Mutation$ReorderChapterDownload$reorderChapterDownload.fromJson(
              (l$reorderChapterDownload as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$ReorderChapterDownload$reorderChapterDownload?
      reorderChapterDownload;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$reorderChapterDownload = reorderChapterDownload;
    _resultData['reorderChapterDownload'] = l$reorderChapterDownload?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$reorderChapterDownload = reorderChapterDownload;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$reorderChapterDownload,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$ReorderChapterDownload ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$reorderChapterDownload = reorderChapterDownload;
    final lOther$reorderChapterDownload = other.reorderChapterDownload;
    if (l$reorderChapterDownload != lOther$reorderChapterDownload) {
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

extension UtilityExtension$Mutation$ReorderChapterDownload
    on Mutation$ReorderChapterDownload {
  CopyWith$Mutation$ReorderChapterDownload<Mutation$ReorderChapterDownload>
      get copyWith => CopyWith$Mutation$ReorderChapterDownload(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$ReorderChapterDownload<TRes> {
  factory CopyWith$Mutation$ReorderChapterDownload(
    Mutation$ReorderChapterDownload instance,
    TRes Function(Mutation$ReorderChapterDownload) then,
  ) = _CopyWithImpl$Mutation$ReorderChapterDownload;

  factory CopyWith$Mutation$ReorderChapterDownload.stub(TRes res) =
      _CopyWithStubImpl$Mutation$ReorderChapterDownload;

  TRes call({
    Mutation$ReorderChapterDownload$reorderChapterDownload?
        reorderChapterDownload,
    String? $__typename,
  });
  CopyWith$Mutation$ReorderChapterDownload$reorderChapterDownload<TRes>
      get reorderChapterDownload;
}

class _CopyWithImpl$Mutation$ReorderChapterDownload<TRes>
    implements CopyWith$Mutation$ReorderChapterDownload<TRes> {
  _CopyWithImpl$Mutation$ReorderChapterDownload(
    this._instance,
    this._then,
  );

  final Mutation$ReorderChapterDownload _instance;

  final TRes Function(Mutation$ReorderChapterDownload) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? reorderChapterDownload = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$ReorderChapterDownload(
        reorderChapterDownload: reorderChapterDownload == _undefined
            ? _instance.reorderChapterDownload
            : (reorderChapterDownload
                as Mutation$ReorderChapterDownload$reorderChapterDownload?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$ReorderChapterDownload$reorderChapterDownload<TRes>
      get reorderChapterDownload {
    final local$reorderChapterDownload = _instance.reorderChapterDownload;
    return local$reorderChapterDownload == null
        ? CopyWith$Mutation$ReorderChapterDownload$reorderChapterDownload.stub(
            _then(_instance))
        : CopyWith$Mutation$ReorderChapterDownload$reorderChapterDownload(
            local$reorderChapterDownload,
            (e) => call(reorderChapterDownload: e));
  }
}

class _CopyWithStubImpl$Mutation$ReorderChapterDownload<TRes>
    implements CopyWith$Mutation$ReorderChapterDownload<TRes> {
  _CopyWithStubImpl$Mutation$ReorderChapterDownload(this._res);

  TRes _res;

  call({
    Mutation$ReorderChapterDownload$reorderChapterDownload?
        reorderChapterDownload,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$ReorderChapterDownload$reorderChapterDownload<TRes>
      get reorderChapterDownload =>
          CopyWith$Mutation$ReorderChapterDownload$reorderChapterDownload.stub(
              _res);
}

const documentNodeMutationReorderChapterDownload = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'ReorderChapterDownload'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'input')),
        type: NamedTypeNode(
          name: NameNode(value: 'ReorderChapterDownloadInput'),
          isNonNull: true,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      )
    ],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'reorderChapterDownload'),
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
            name: NameNode(value: 'downloadStatus'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: SelectionSetNode(selections: [
              FragmentSpreadNode(
                name: NameNode(value: 'DownloadStatusDto'),
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
  fragmentDefinitionDownloadStatusDto,
  fragmentDefinitionDownloadDto,
]);
Mutation$ReorderChapterDownload _parserFn$Mutation$ReorderChapterDownload(
        Map<String, dynamic> data) =>
    Mutation$ReorderChapterDownload.fromJson(data);
typedef OnMutationCompleted$Mutation$ReorderChapterDownload = FutureOr<void>
    Function(
  Map<String, dynamic>?,
  Mutation$ReorderChapterDownload?,
);

class Options$Mutation$ReorderChapterDownload
    extends graphql.MutationOptions<Mutation$ReorderChapterDownload> {
  Options$Mutation$ReorderChapterDownload({
    String? operationName,
    required Variables$Mutation$ReorderChapterDownload variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$ReorderChapterDownload? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$ReorderChapterDownload? onCompleted,
    graphql.OnMutationUpdate<Mutation$ReorderChapterDownload>? update,
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
                        : _parserFn$Mutation$ReorderChapterDownload(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationReorderChapterDownload,
          parserFn: _parserFn$Mutation$ReorderChapterDownload,
        );

  final OnMutationCompleted$Mutation$ReorderChapterDownload?
      onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$ReorderChapterDownload
    extends graphql.WatchQueryOptions<Mutation$ReorderChapterDownload> {
  WatchOptions$Mutation$ReorderChapterDownload({
    String? operationName,
    required Variables$Mutation$ReorderChapterDownload variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$ReorderChapterDownload? typedOptimisticResult,
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
          document: documentNodeMutationReorderChapterDownload,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$ReorderChapterDownload,
        );
}

extension ClientExtension$Mutation$ReorderChapterDownload
    on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$ReorderChapterDownload>>
      mutate$ReorderChapterDownload(
              Options$Mutation$ReorderChapterDownload options) async =>
          await this.mutate(options);

  graphql.ObservableQuery<Mutation$ReorderChapterDownload>
      watchMutation$ReorderChapterDownload(
              WatchOptions$Mutation$ReorderChapterDownload options) =>
          this.watchMutation(options);
}

class Mutation$ReorderChapterDownload$HookResult {
  Mutation$ReorderChapterDownload$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$ReorderChapterDownload runMutation;

  final graphql.QueryResult<Mutation$ReorderChapterDownload> result;
}

Mutation$ReorderChapterDownload$HookResult useMutation$ReorderChapterDownload(
    [WidgetOptions$Mutation$ReorderChapterDownload? options]) {
  final result = graphql_flutter
      .useMutation(options ?? WidgetOptions$Mutation$ReorderChapterDownload());
  return Mutation$ReorderChapterDownload$HookResult(
    (variables, {optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables.toJson(),
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$ReorderChapterDownload>
    useWatchMutation$ReorderChapterDownload(
            WatchOptions$Mutation$ReorderChapterDownload options) =>
        graphql_flutter.useWatchMutation(options);

class WidgetOptions$Mutation$ReorderChapterDownload
    extends graphql.MutationOptions<Mutation$ReorderChapterDownload> {
  WidgetOptions$Mutation$ReorderChapterDownload({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$ReorderChapterDownload? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$ReorderChapterDownload? onCompleted,
    graphql.OnMutationUpdate<Mutation$ReorderChapterDownload>? update,
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
                        : _parserFn$Mutation$ReorderChapterDownload(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationReorderChapterDownload,
          parserFn: _parserFn$Mutation$ReorderChapterDownload,
        );

  final OnMutationCompleted$Mutation$ReorderChapterDownload?
      onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$ReorderChapterDownload
    = graphql.MultiSourceResult<Mutation$ReorderChapterDownload> Function(
  Variables$Mutation$ReorderChapterDownload, {
  Object? optimisticResult,
  Mutation$ReorderChapterDownload? typedOptimisticResult,
});
typedef Builder$Mutation$ReorderChapterDownload = widgets.Widget Function(
  RunMutation$Mutation$ReorderChapterDownload,
  graphql.QueryResult<Mutation$ReorderChapterDownload>?,
);

class Mutation$ReorderChapterDownload$Widget
    extends graphql_flutter.Mutation<Mutation$ReorderChapterDownload> {
  Mutation$ReorderChapterDownload$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$ReorderChapterDownload? options,
    required Builder$Mutation$ReorderChapterDownload builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$ReorderChapterDownload(),
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

class Mutation$ReorderChapterDownload$reorderChapterDownload {
  Mutation$ReorderChapterDownload$reorderChapterDownload({
    this.$__typename = 'ReorderChapterDownloadPayload',
    required this.downloadStatus,
  });

  factory Mutation$ReorderChapterDownload$reorderChapterDownload.fromJson(
      Map<String, dynamic> json) {
    final l$$__typename = json['__typename'];
    final l$downloadStatus = json['downloadStatus'];
    return Mutation$ReorderChapterDownload$reorderChapterDownload(
      $__typename: (l$$__typename as String),
      downloadStatus: Fragment$DownloadStatusDto.fromJson(
          (l$downloadStatus as Map<String, dynamic>)),
    );
  }

  final String $__typename;

  final Fragment$DownloadStatusDto downloadStatus;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    final l$downloadStatus = downloadStatus;
    _resultData['downloadStatus'] = l$downloadStatus.toJson();
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    final l$downloadStatus = downloadStatus;
    return Object.hashAll([
      l$$__typename,
      l$downloadStatus,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$ReorderChapterDownload$reorderChapterDownload ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    final l$downloadStatus = downloadStatus;
    final lOther$downloadStatus = other.downloadStatus;
    if (l$downloadStatus != lOther$downloadStatus) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Mutation$ReorderChapterDownload$reorderChapterDownload
    on Mutation$ReorderChapterDownload$reorderChapterDownload {
  CopyWith$Mutation$ReorderChapterDownload$reorderChapterDownload<
          Mutation$ReorderChapterDownload$reorderChapterDownload>
      get copyWith =>
          CopyWith$Mutation$ReorderChapterDownload$reorderChapterDownload(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$ReorderChapterDownload$reorderChapterDownload<
    TRes> {
  factory CopyWith$Mutation$ReorderChapterDownload$reorderChapterDownload(
    Mutation$ReorderChapterDownload$reorderChapterDownload instance,
    TRes Function(Mutation$ReorderChapterDownload$reorderChapterDownload) then,
  ) = _CopyWithImpl$Mutation$ReorderChapterDownload$reorderChapterDownload;

  factory CopyWith$Mutation$ReorderChapterDownload$reorderChapterDownload.stub(
          TRes res) =
      _CopyWithStubImpl$Mutation$ReorderChapterDownload$reorderChapterDownload;

  TRes call({
    String? $__typename,
    Fragment$DownloadStatusDto? downloadStatus,
  });
  CopyWith$Fragment$DownloadStatusDto<TRes> get downloadStatus;
}

class _CopyWithImpl$Mutation$ReorderChapterDownload$reorderChapterDownload<TRes>
    implements
        CopyWith$Mutation$ReorderChapterDownload$reorderChapterDownload<TRes> {
  _CopyWithImpl$Mutation$ReorderChapterDownload$reorderChapterDownload(
    this._instance,
    this._then,
  );

  final Mutation$ReorderChapterDownload$reorderChapterDownload _instance;

  final TRes Function(Mutation$ReorderChapterDownload$reorderChapterDownload)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? $__typename = _undefined,
    Object? downloadStatus = _undefined,
  }) =>
      _then(Mutation$ReorderChapterDownload$reorderChapterDownload(
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
        downloadStatus: downloadStatus == _undefined || downloadStatus == null
            ? _instance.downloadStatus
            : (downloadStatus as Fragment$DownloadStatusDto),
      ));

  CopyWith$Fragment$DownloadStatusDto<TRes> get downloadStatus {
    final local$downloadStatus = _instance.downloadStatus;
    return CopyWith$Fragment$DownloadStatusDto(
        local$downloadStatus, (e) => call(downloadStatus: e));
  }
}

class _CopyWithStubImpl$Mutation$ReorderChapterDownload$reorderChapterDownload<
        TRes>
    implements
        CopyWith$Mutation$ReorderChapterDownload$reorderChapterDownload<TRes> {
  _CopyWithStubImpl$Mutation$ReorderChapterDownload$reorderChapterDownload(
      this._res);

  TRes _res;

  call({
    String? $__typename,
    Fragment$DownloadStatusDto? downloadStatus,
  }) =>
      _res;

  CopyWith$Fragment$DownloadStatusDto<TRes> get downloadStatus =>
      CopyWith$Fragment$DownloadStatusDto.stub(_res);
}

class Variables$Subscription$DownloadStatusChanged {
  factory Variables$Subscription$DownloadStatusChanged(
          {required Input$DownloadChangedInput input}) =>
      Variables$Subscription$DownloadStatusChanged._({
        r'input': input,
      });

  Variables$Subscription$DownloadStatusChanged._(this._$data);

  factory Variables$Subscription$DownloadStatusChanged.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$input = data['input'];
    result$data['input'] =
        Input$DownloadChangedInput.fromJson((l$input as Map<String, dynamic>));
    return Variables$Subscription$DownloadStatusChanged._(result$data);
  }

  Map<String, dynamic> _$data;

  Input$DownloadChangedInput get input =>
      (_$data['input'] as Input$DownloadChangedInput);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$input = input;
    result$data['input'] = l$input.toJson();
    return result$data;
  }

  CopyWith$Variables$Subscription$DownloadStatusChanged<
          Variables$Subscription$DownloadStatusChanged>
      get copyWith => CopyWith$Variables$Subscription$DownloadStatusChanged(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Subscription$DownloadStatusChanged ||
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

abstract class CopyWith$Variables$Subscription$DownloadStatusChanged<TRes> {
  factory CopyWith$Variables$Subscription$DownloadStatusChanged(
    Variables$Subscription$DownloadStatusChanged instance,
    TRes Function(Variables$Subscription$DownloadStatusChanged) then,
  ) = _CopyWithImpl$Variables$Subscription$DownloadStatusChanged;

  factory CopyWith$Variables$Subscription$DownloadStatusChanged.stub(TRes res) =
      _CopyWithStubImpl$Variables$Subscription$DownloadStatusChanged;

  TRes call({Input$DownloadChangedInput? input});
}

class _CopyWithImpl$Variables$Subscription$DownloadStatusChanged<TRes>
    implements CopyWith$Variables$Subscription$DownloadStatusChanged<TRes> {
  _CopyWithImpl$Variables$Subscription$DownloadStatusChanged(
    this._instance,
    this._then,
  );

  final Variables$Subscription$DownloadStatusChanged _instance;

  final TRes Function(Variables$Subscription$DownloadStatusChanged) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? input = _undefined}) =>
      _then(Variables$Subscription$DownloadStatusChanged._({
        ..._instance._$data,
        if (input != _undefined && input != null)
          'input': (input as Input$DownloadChangedInput),
      }));
}

class _CopyWithStubImpl$Variables$Subscription$DownloadStatusChanged<TRes>
    implements CopyWith$Variables$Subscription$DownloadStatusChanged<TRes> {
  _CopyWithStubImpl$Variables$Subscription$DownloadStatusChanged(this._res);

  TRes _res;

  call({Input$DownloadChangedInput? input}) => _res;
}

class Subscription$DownloadStatusChanged {
  Subscription$DownloadStatusChanged({required this.downloadStatusChanged});

  factory Subscription$DownloadStatusChanged.fromJson(
      Map<String, dynamic> json) {
    final l$downloadStatusChanged = json['downloadStatusChanged'];
    return Subscription$DownloadStatusChanged(
        downloadStatusChanged: Fragment$DownloadUpdatesDto.fromJson(
            (l$downloadStatusChanged as Map<String, dynamic>)));
  }

  final Fragment$DownloadUpdatesDto downloadStatusChanged;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$downloadStatusChanged = downloadStatusChanged;
    _resultData['downloadStatusChanged'] = l$downloadStatusChanged.toJson();
    return _resultData;
  }

  @override
  int get hashCode {
    final l$downloadStatusChanged = downloadStatusChanged;
    return Object.hashAll([l$downloadStatusChanged]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Subscription$DownloadStatusChanged ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$downloadStatusChanged = downloadStatusChanged;
    final lOther$downloadStatusChanged = other.downloadStatusChanged;
    if (l$downloadStatusChanged != lOther$downloadStatusChanged) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Subscription$DownloadStatusChanged
    on Subscription$DownloadStatusChanged {
  CopyWith$Subscription$DownloadStatusChanged<
          Subscription$DownloadStatusChanged>
      get copyWith => CopyWith$Subscription$DownloadStatusChanged(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Subscription$DownloadStatusChanged<TRes> {
  factory CopyWith$Subscription$DownloadStatusChanged(
    Subscription$DownloadStatusChanged instance,
    TRes Function(Subscription$DownloadStatusChanged) then,
  ) = _CopyWithImpl$Subscription$DownloadStatusChanged;

  factory CopyWith$Subscription$DownloadStatusChanged.stub(TRes res) =
      _CopyWithStubImpl$Subscription$DownloadStatusChanged;

  TRes call({Fragment$DownloadUpdatesDto? downloadStatusChanged});
  CopyWith$Fragment$DownloadUpdatesDto<TRes> get downloadStatusChanged;
}

class _CopyWithImpl$Subscription$DownloadStatusChanged<TRes>
    implements CopyWith$Subscription$DownloadStatusChanged<TRes> {
  _CopyWithImpl$Subscription$DownloadStatusChanged(
    this._instance,
    this._then,
  );

  final Subscription$DownloadStatusChanged _instance;

  final TRes Function(Subscription$DownloadStatusChanged) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? downloadStatusChanged = _undefined}) =>
      _then(Subscription$DownloadStatusChanged(
          downloadStatusChanged: downloadStatusChanged == _undefined ||
                  downloadStatusChanged == null
              ? _instance.downloadStatusChanged
              : (downloadStatusChanged as Fragment$DownloadUpdatesDto)));

  CopyWith$Fragment$DownloadUpdatesDto<TRes> get downloadStatusChanged {
    final local$downloadStatusChanged = _instance.downloadStatusChanged;
    return CopyWith$Fragment$DownloadUpdatesDto(
        local$downloadStatusChanged, (e) => call(downloadStatusChanged: e));
  }
}

class _CopyWithStubImpl$Subscription$DownloadStatusChanged<TRes>
    implements CopyWith$Subscription$DownloadStatusChanged<TRes> {
  _CopyWithStubImpl$Subscription$DownloadStatusChanged(this._res);

  TRes _res;

  call({Fragment$DownloadUpdatesDto? downloadStatusChanged}) => _res;

  CopyWith$Fragment$DownloadUpdatesDto<TRes> get downloadStatusChanged =>
      CopyWith$Fragment$DownloadUpdatesDto.stub(_res);
}

const documentNodeSubscriptionDownloadStatusChanged =
    DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.subscription,
    name: NameNode(value: 'DownloadStatusChanged'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'input')),
        type: NamedTypeNode(
          name: NameNode(value: 'DownloadChangedInput'),
          isNonNull: true,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      )
    ],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'downloadStatusChanged'),
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
            name: NameNode(value: 'DownloadUpdatesDto'),
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
  fragmentDefinitionDownloadUpdatesDto,
  fragmentDefinitionDownloadUpdateDto,
  fragmentDefinitionDownloadDto,
]);
Subscription$DownloadStatusChanged _parserFn$Subscription$DownloadStatusChanged(
        Map<String, dynamic> data) =>
    Subscription$DownloadStatusChanged.fromJson(data);

class Options$Subscription$DownloadStatusChanged
    extends graphql.SubscriptionOptions<Subscription$DownloadStatusChanged> {
  Options$Subscription$DownloadStatusChanged({
    String? operationName,
    required Variables$Subscription$DownloadStatusChanged variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Subscription$DownloadStatusChanged? typedOptimisticResult,
    graphql.Context? context,
  }) : super(
          variables: variables.toJson(),
          operationName: operationName,
          fetchPolicy: fetchPolicy,
          errorPolicy: errorPolicy,
          cacheRereadPolicy: cacheRereadPolicy,
          optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
          context: context,
          document: documentNodeSubscriptionDownloadStatusChanged,
          parserFn: _parserFn$Subscription$DownloadStatusChanged,
        );
}

class WatchOptions$Subscription$DownloadStatusChanged
    extends graphql.WatchQueryOptions<Subscription$DownloadStatusChanged> {
  WatchOptions$Subscription$DownloadStatusChanged({
    String? operationName,
    required Variables$Subscription$DownloadStatusChanged variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Subscription$DownloadStatusChanged? typedOptimisticResult,
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
          document: documentNodeSubscriptionDownloadStatusChanged,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Subscription$DownloadStatusChanged,
        );
}

class FetchMoreOptions$Subscription$DownloadStatusChanged
    extends graphql.FetchMoreOptions {
  FetchMoreOptions$Subscription$DownloadStatusChanged({
    required graphql.UpdateQuery updateQuery,
    required Variables$Subscription$DownloadStatusChanged variables,
  }) : super(
          updateQuery: updateQuery,
          variables: variables.toJson(),
          document: documentNodeSubscriptionDownloadStatusChanged,
        );
}

extension ClientExtension$Subscription$DownloadStatusChanged
    on graphql.GraphQLClient {
  Stream<graphql.QueryResult<Subscription$DownloadStatusChanged>>
      subscribe$DownloadStatusChanged(
              Options$Subscription$DownloadStatusChanged options) =>
          this.subscribe(options);

  graphql.ObservableQuery<Subscription$DownloadStatusChanged>
      watchSubscription$DownloadStatusChanged(
              WatchOptions$Subscription$DownloadStatusChanged options) =>
          this.watchQuery(options);
}

graphql.QueryResult<Subscription$DownloadStatusChanged>
    useSubscription$DownloadStatusChanged(
            Options$Subscription$DownloadStatusChanged options) =>
        graphql_flutter.useSubscription(options);

class Subscription$DownloadStatusChanged$Widget
    extends graphql_flutter.Subscription<Subscription$DownloadStatusChanged> {
  Subscription$DownloadStatusChanged$Widget({
    widgets.Key? key,
    required Options$Subscription$DownloadStatusChanged options,
    required graphql_flutter
        .SubscriptionBuilder<Subscription$DownloadStatusChanged>
        builder,
    graphql_flutter.OnSubscriptionResult<Subscription$DownloadStatusChanged>?
        onSubscriptionResult,
  }) : super(
          key: key,
          options: options,
          builder: builder,
          onSubscriptionResult: onSubscriptionResult,
        );
}

class Query$GetDownloadStatus {
  Query$GetDownloadStatus({
    required this.downloadStatus,
    this.$__typename = 'Query',
  });

  factory Query$GetDownloadStatus.fromJson(Map<String, dynamic> json) {
    final l$downloadStatus = json['downloadStatus'];
    final l$$__typename = json['__typename'];
    return Query$GetDownloadStatus(
      downloadStatus: Fragment$DownloadStatusDto.fromJson(
          (l$downloadStatus as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Fragment$DownloadStatusDto downloadStatus;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$downloadStatus = downloadStatus;
    _resultData['downloadStatus'] = l$downloadStatus.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$downloadStatus = downloadStatus;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$downloadStatus,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetDownloadStatus || runtimeType != other.runtimeType) {
      return false;
    }
    final l$downloadStatus = downloadStatus;
    final lOther$downloadStatus = other.downloadStatus;
    if (l$downloadStatus != lOther$downloadStatus) {
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

extension UtilityExtension$Query$GetDownloadStatus on Query$GetDownloadStatus {
  CopyWith$Query$GetDownloadStatus<Query$GetDownloadStatus> get copyWith =>
      CopyWith$Query$GetDownloadStatus(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Query$GetDownloadStatus<TRes> {
  factory CopyWith$Query$GetDownloadStatus(
    Query$GetDownloadStatus instance,
    TRes Function(Query$GetDownloadStatus) then,
  ) = _CopyWithImpl$Query$GetDownloadStatus;

  factory CopyWith$Query$GetDownloadStatus.stub(TRes res) =
      _CopyWithStubImpl$Query$GetDownloadStatus;

  TRes call({
    Fragment$DownloadStatusDto? downloadStatus,
    String? $__typename,
  });
  CopyWith$Fragment$DownloadStatusDto<TRes> get downloadStatus;
}

class _CopyWithImpl$Query$GetDownloadStatus<TRes>
    implements CopyWith$Query$GetDownloadStatus<TRes> {
  _CopyWithImpl$Query$GetDownloadStatus(
    this._instance,
    this._then,
  );

  final Query$GetDownloadStatus _instance;

  final TRes Function(Query$GetDownloadStatus) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? downloadStatus = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetDownloadStatus(
        downloadStatus: downloadStatus == _undefined || downloadStatus == null
            ? _instance.downloadStatus
            : (downloadStatus as Fragment$DownloadStatusDto),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Fragment$DownloadStatusDto<TRes> get downloadStatus {
    final local$downloadStatus = _instance.downloadStatus;
    return CopyWith$Fragment$DownloadStatusDto(
        local$downloadStatus, (e) => call(downloadStatus: e));
  }
}

class _CopyWithStubImpl$Query$GetDownloadStatus<TRes>
    implements CopyWith$Query$GetDownloadStatus<TRes> {
  _CopyWithStubImpl$Query$GetDownloadStatus(this._res);

  TRes _res;

  call({
    Fragment$DownloadStatusDto? downloadStatus,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$DownloadStatusDto<TRes> get downloadStatus =>
      CopyWith$Fragment$DownloadStatusDto.stub(_res);
}

const documentNodeQueryGetDownloadStatus = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.query,
    name: NameNode(value: 'GetDownloadStatus'),
    variableDefinitions: [],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'downloadStatus'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: SelectionSetNode(selections: [
          FragmentSpreadNode(
            name: NameNode(value: 'DownloadStatusDto'),
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
  fragmentDefinitionDownloadStatusDto,
  fragmentDefinitionDownloadDto,
]);
Query$GetDownloadStatus _parserFn$Query$GetDownloadStatus(
        Map<String, dynamic> data) =>
    Query$GetDownloadStatus.fromJson(data);
typedef OnQueryComplete$Query$GetDownloadStatus = FutureOr<void> Function(
  Map<String, dynamic>?,
  Query$GetDownloadStatus?,
);

class Options$Query$GetDownloadStatus
    extends graphql.QueryOptions<Query$GetDownloadStatus> {
  Options$Query$GetDownloadStatus({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetDownloadStatus? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$GetDownloadStatus? onComplete,
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
                    data == null
                        ? null
                        : _parserFn$Query$GetDownloadStatus(data),
                  ),
          onError: onError,
          document: documentNodeQueryGetDownloadStatus,
          parserFn: _parserFn$Query$GetDownloadStatus,
        );

  final OnQueryComplete$Query$GetDownloadStatus? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onComplete == null
            ? super.properties
            : super.properties.where((property) => property != onComplete),
        onCompleteWithParsed,
      ];
}

class WatchOptions$Query$GetDownloadStatus
    extends graphql.WatchQueryOptions<Query$GetDownloadStatus> {
  WatchOptions$Query$GetDownloadStatus({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetDownloadStatus? typedOptimisticResult,
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
          document: documentNodeQueryGetDownloadStatus,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Query$GetDownloadStatus,
        );
}

class FetchMoreOptions$Query$GetDownloadStatus
    extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$GetDownloadStatus(
      {required graphql.UpdateQuery updateQuery})
      : super(
          updateQuery: updateQuery,
          document: documentNodeQueryGetDownloadStatus,
        );
}

extension ClientExtension$Query$GetDownloadStatus on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$GetDownloadStatus>> query$GetDownloadStatus(
          [Options$Query$GetDownloadStatus? options]) async =>
      await this.query(options ?? Options$Query$GetDownloadStatus());

  graphql.ObservableQuery<Query$GetDownloadStatus> watchQuery$GetDownloadStatus(
          [WatchOptions$Query$GetDownloadStatus? options]) =>
      this.watchQuery(options ?? WatchOptions$Query$GetDownloadStatus());

  void writeQuery$GetDownloadStatus({
    required Query$GetDownloadStatus data,
    bool broadcast = true,
  }) =>
      this.writeQuery(
        graphql.Request(
            operation: graphql.Operation(
                document: documentNodeQueryGetDownloadStatus)),
        data: data.toJson(),
        broadcast: broadcast,
      );

  Query$GetDownloadStatus? readQuery$GetDownloadStatus(
      {bool optimistic = true}) {
    final result = this.readQuery(
      graphql.Request(
          operation:
              graphql.Operation(document: documentNodeQueryGetDownloadStatus)),
      optimistic: optimistic,
    );
    return result == null ? null : Query$GetDownloadStatus.fromJson(result);
  }
}

graphql_flutter.QueryHookResult<Query$GetDownloadStatus>
    useQuery$GetDownloadStatus([Options$Query$GetDownloadStatus? options]) =>
        graphql_flutter.useQuery(options ?? Options$Query$GetDownloadStatus());
graphql.ObservableQuery<Query$GetDownloadStatus>
    useWatchQuery$GetDownloadStatus(
            [WatchOptions$Query$GetDownloadStatus? options]) =>
        graphql_flutter
            .useWatchQuery(options ?? WatchOptions$Query$GetDownloadStatus());

class Query$GetDownloadStatus$Widget
    extends graphql_flutter.Query<Query$GetDownloadStatus> {
  Query$GetDownloadStatus$Widget({
    widgets.Key? key,
    Options$Query$GetDownloadStatus? options,
    required graphql_flutter.QueryBuilder<Query$GetDownloadStatus> builder,
  }) : super(
          key: key,
          options: options ?? Options$Query$GetDownloadStatus(),
          builder: builder,
        );
}
