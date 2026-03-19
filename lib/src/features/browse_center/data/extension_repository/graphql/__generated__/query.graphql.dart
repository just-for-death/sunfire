import '../../../../domain/extension/graphql/__generated__/fragment.graphql.dart';
import 'dart:async';
import 'package:catalyst/src/utils/misc/scalars.dart';
import 'package:flutter/widgets.dart' as widgets;
import 'package:gql/ast.dart';
import 'package:graphql/client.dart' as graphql;
import 'package:graphql_flutter/graphql_flutter.dart' as graphql_flutter;

class Variables$Mutation$UpdateExtension {
  factory Variables$Mutation$UpdateExtension({
    required String id,
    bool? install,
    bool? uninstall,
    bool? update,
  }) =>
      Variables$Mutation$UpdateExtension._({
        r'id': id,
        if (install != null) r'install': install,
        if (uninstall != null) r'uninstall': uninstall,
        if (update != null) r'update': update,
      });

  Variables$Mutation$UpdateExtension._(this._$data);

  factory Variables$Mutation$UpdateExtension.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$id = data['id'];
    result$data['id'] = (l$id as String);
    if (data.containsKey('install')) {
      final l$install = data['install'];
      result$data['install'] = (l$install as bool?);
    }
    if (data.containsKey('uninstall')) {
      final l$uninstall = data['uninstall'];
      result$data['uninstall'] = (l$uninstall as bool?);
    }
    if (data.containsKey('update')) {
      final l$update = data['update'];
      result$data['update'] = (l$update as bool?);
    }
    return Variables$Mutation$UpdateExtension._(result$data);
  }

  Map<String, dynamic> _$data;

  String get id => (_$data['id'] as String);

  bool? get install => (_$data['install'] as bool?);

  bool? get uninstall => (_$data['uninstall'] as bool?);

  bool? get update => (_$data['update'] as bool?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$id = id;
    result$data['id'] = l$id;
    if (_$data.containsKey('install')) {
      final l$install = install;
      result$data['install'] = l$install;
    }
    if (_$data.containsKey('uninstall')) {
      final l$uninstall = uninstall;
      result$data['uninstall'] = l$uninstall;
    }
    if (_$data.containsKey('update')) {
      final l$update = update;
      result$data['update'] = l$update;
    }
    return result$data;
  }

  CopyWith$Variables$Mutation$UpdateExtension<
          Variables$Mutation$UpdateExtension>
      get copyWith => CopyWith$Variables$Mutation$UpdateExtension(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$UpdateExtension ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$install = install;
    final lOther$install = other.install;
    if (_$data.containsKey('install') != other._$data.containsKey('install')) {
      return false;
    }
    if (l$install != lOther$install) {
      return false;
    }
    final l$uninstall = uninstall;
    final lOther$uninstall = other.uninstall;
    if (_$data.containsKey('uninstall') !=
        other._$data.containsKey('uninstall')) {
      return false;
    }
    if (l$uninstall != lOther$uninstall) {
      return false;
    }
    final l$update = update;
    final lOther$update = other.update;
    if (_$data.containsKey('update') != other._$data.containsKey('update')) {
      return false;
    }
    if (l$update != lOther$update) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$install = install;
    final l$uninstall = uninstall;
    final l$update = update;
    return Object.hashAll([
      l$id,
      _$data.containsKey('install') ? l$install : const {},
      _$data.containsKey('uninstall') ? l$uninstall : const {},
      _$data.containsKey('update') ? l$update : const {},
    ]);
  }
}

abstract class CopyWith$Variables$Mutation$UpdateExtension<TRes> {
  factory CopyWith$Variables$Mutation$UpdateExtension(
    Variables$Mutation$UpdateExtension instance,
    TRes Function(Variables$Mutation$UpdateExtension) then,
  ) = _CopyWithImpl$Variables$Mutation$UpdateExtension;

  factory CopyWith$Variables$Mutation$UpdateExtension.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$UpdateExtension;

  TRes call({
    String? id,
    bool? install,
    bool? uninstall,
    bool? update,
  });
}

class _CopyWithImpl$Variables$Mutation$UpdateExtension<TRes>
    implements CopyWith$Variables$Mutation$UpdateExtension<TRes> {
  _CopyWithImpl$Variables$Mutation$UpdateExtension(
    this._instance,
    this._then,
  );

  final Variables$Mutation$UpdateExtension _instance;

  final TRes Function(Variables$Mutation$UpdateExtension) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? install = _undefined,
    Object? uninstall = _undefined,
    Object? update = _undefined,
  }) =>
      _then(Variables$Mutation$UpdateExtension._({
        ..._instance._$data,
        if (id != _undefined && id != null) 'id': (id as String),
        if (install != _undefined) 'install': (install as bool?),
        if (uninstall != _undefined) 'uninstall': (uninstall as bool?),
        if (update != _undefined) 'update': (update as bool?),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$UpdateExtension<TRes>
    implements CopyWith$Variables$Mutation$UpdateExtension<TRes> {
  _CopyWithStubImpl$Variables$Mutation$UpdateExtension(this._res);

  TRes _res;

  call({
    String? id,
    bool? install,
    bool? uninstall,
    bool? update,
  }) =>
      _res;
}

class Mutation$UpdateExtension {
  Mutation$UpdateExtension({
    this.updateExtension,
    this.$__typename = 'Mutation',
  });

  factory Mutation$UpdateExtension.fromJson(Map<String, dynamic> json) {
    final l$updateExtension = json['updateExtension'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateExtension(
      updateExtension: l$updateExtension == null
          ? null
          : Mutation$UpdateExtension$updateExtension.fromJson(
              (l$updateExtension as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$UpdateExtension$updateExtension? updateExtension;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$updateExtension = updateExtension;
    _resultData['updateExtension'] = l$updateExtension?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$updateExtension = updateExtension;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$updateExtension,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$UpdateExtension ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$updateExtension = updateExtension;
    final lOther$updateExtension = other.updateExtension;
    if (l$updateExtension != lOther$updateExtension) {
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

extension UtilityExtension$Mutation$UpdateExtension
    on Mutation$UpdateExtension {
  CopyWith$Mutation$UpdateExtension<Mutation$UpdateExtension> get copyWith =>
      CopyWith$Mutation$UpdateExtension(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Mutation$UpdateExtension<TRes> {
  factory CopyWith$Mutation$UpdateExtension(
    Mutation$UpdateExtension instance,
    TRes Function(Mutation$UpdateExtension) then,
  ) = _CopyWithImpl$Mutation$UpdateExtension;

  factory CopyWith$Mutation$UpdateExtension.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateExtension;

  TRes call({
    Mutation$UpdateExtension$updateExtension? updateExtension,
    String? $__typename,
  });
  CopyWith$Mutation$UpdateExtension$updateExtension<TRes> get updateExtension;
}

class _CopyWithImpl$Mutation$UpdateExtension<TRes>
    implements CopyWith$Mutation$UpdateExtension<TRes> {
  _CopyWithImpl$Mutation$UpdateExtension(
    this._instance,
    this._then,
  );

  final Mutation$UpdateExtension _instance;

  final TRes Function(Mutation$UpdateExtension) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? updateExtension = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateExtension(
        updateExtension: updateExtension == _undefined
            ? _instance.updateExtension
            : (updateExtension as Mutation$UpdateExtension$updateExtension?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$UpdateExtension$updateExtension<TRes> get updateExtension {
    final local$updateExtension = _instance.updateExtension;
    return local$updateExtension == null
        ? CopyWith$Mutation$UpdateExtension$updateExtension.stub(
            _then(_instance))
        : CopyWith$Mutation$UpdateExtension$updateExtension(
            local$updateExtension, (e) => call(updateExtension: e));
  }
}

class _CopyWithStubImpl$Mutation$UpdateExtension<TRes>
    implements CopyWith$Mutation$UpdateExtension<TRes> {
  _CopyWithStubImpl$Mutation$UpdateExtension(this._res);

  TRes _res;

  call({
    Mutation$UpdateExtension$updateExtension? updateExtension,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$UpdateExtension$updateExtension<TRes> get updateExtension =>
      CopyWith$Mutation$UpdateExtension$updateExtension.stub(_res);
}

const documentNodeMutationUpdateExtension = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'UpdateExtension'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'id')),
        type: NamedTypeNode(
          name: NameNode(value: 'String'),
          isNonNull: true,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'install')),
        type: NamedTypeNode(
          name: NameNode(value: 'Boolean'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: BooleanValueNode(value: false)),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'uninstall')),
        type: NamedTypeNode(
          name: NameNode(value: 'Boolean'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: BooleanValueNode(value: false)),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'update')),
        type: NamedTypeNode(
          name: NameNode(value: 'Boolean'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: BooleanValueNode(value: false)),
        directives: [],
      ),
    ],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'updateExtension'),
        alias: null,
        arguments: [
          ArgumentNode(
            name: NameNode(value: 'input'),
            value: ObjectValueNode(fields: [
              ObjectFieldNode(
                name: NameNode(value: 'id'),
                value: VariableNode(name: NameNode(value: 'id')),
              ),
              ObjectFieldNode(
                name: NameNode(value: 'patch'),
                value: ObjectValueNode(fields: [
                  ObjectFieldNode(
                    name: NameNode(value: 'install'),
                    value: VariableNode(name: NameNode(value: 'install')),
                  ),
                  ObjectFieldNode(
                    name: NameNode(value: 'uninstall'),
                    value: VariableNode(name: NameNode(value: 'uninstall')),
                  ),
                  ObjectFieldNode(
                    name: NameNode(value: 'update'),
                    value: VariableNode(name: NameNode(value: 'update')),
                  ),
                ]),
              ),
            ]),
          )
        ],
        directives: [],
        selectionSet: SelectionSetNode(selections: [
          FieldNode(
            name: NameNode(value: 'clientMutationId'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null,
          ),
          FieldNode(
            name: NameNode(value: 'extension'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: SelectionSetNode(selections: [
              FragmentSpreadNode(
                name: NameNode(value: 'ExtensionDto'),
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
  fragmentDefinitionExtensionDto,
]);
Mutation$UpdateExtension _parserFn$Mutation$UpdateExtension(
        Map<String, dynamic> data) =>
    Mutation$UpdateExtension.fromJson(data);
typedef OnMutationCompleted$Mutation$UpdateExtension = FutureOr<void> Function(
  Map<String, dynamic>?,
  Mutation$UpdateExtension?,
);

class Options$Mutation$UpdateExtension
    extends graphql.MutationOptions<Mutation$UpdateExtension> {
  Options$Mutation$UpdateExtension({
    String? operationName,
    required Variables$Mutation$UpdateExtension variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateExtension? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateExtension? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateExtension>? update,
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
                        : _parserFn$Mutation$UpdateExtension(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateExtension,
          parserFn: _parserFn$Mutation$UpdateExtension,
        );

  final OnMutationCompleted$Mutation$UpdateExtension? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$UpdateExtension
    extends graphql.WatchQueryOptions<Mutation$UpdateExtension> {
  WatchOptions$Mutation$UpdateExtension({
    String? operationName,
    required Variables$Mutation$UpdateExtension variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateExtension? typedOptimisticResult,
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
          document: documentNodeMutationUpdateExtension,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$UpdateExtension,
        );
}

extension ClientExtension$Mutation$UpdateExtension on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$UpdateExtension>> mutate$UpdateExtension(
          Options$Mutation$UpdateExtension options) async =>
      await this.mutate(options);

  graphql.ObservableQuery<Mutation$UpdateExtension>
      watchMutation$UpdateExtension(
              WatchOptions$Mutation$UpdateExtension options) =>
          this.watchMutation(options);
}

class Mutation$UpdateExtension$HookResult {
  Mutation$UpdateExtension$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$UpdateExtension runMutation;

  final graphql.QueryResult<Mutation$UpdateExtension> result;
}

Mutation$UpdateExtension$HookResult useMutation$UpdateExtension(
    [WidgetOptions$Mutation$UpdateExtension? options]) {
  final result = graphql_flutter
      .useMutation(options ?? WidgetOptions$Mutation$UpdateExtension());
  return Mutation$UpdateExtension$HookResult(
    (variables, {optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables.toJson(),
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$UpdateExtension>
    useWatchMutation$UpdateExtension(
            WatchOptions$Mutation$UpdateExtension options) =>
        graphql_flutter.useWatchMutation(options);

class WidgetOptions$Mutation$UpdateExtension
    extends graphql.MutationOptions<Mutation$UpdateExtension> {
  WidgetOptions$Mutation$UpdateExtension({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateExtension? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateExtension? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateExtension>? update,
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
                        : _parserFn$Mutation$UpdateExtension(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateExtension,
          parserFn: _parserFn$Mutation$UpdateExtension,
        );

  final OnMutationCompleted$Mutation$UpdateExtension? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$UpdateExtension
    = graphql.MultiSourceResult<Mutation$UpdateExtension> Function(
  Variables$Mutation$UpdateExtension, {
  Object? optimisticResult,
  Mutation$UpdateExtension? typedOptimisticResult,
});
typedef Builder$Mutation$UpdateExtension = widgets.Widget Function(
  RunMutation$Mutation$UpdateExtension,
  graphql.QueryResult<Mutation$UpdateExtension>?,
);

class Mutation$UpdateExtension$Widget
    extends graphql_flutter.Mutation<Mutation$UpdateExtension> {
  Mutation$UpdateExtension$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$UpdateExtension? options,
    required Builder$Mutation$UpdateExtension builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$UpdateExtension(),
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

class Mutation$UpdateExtension$updateExtension {
  Mutation$UpdateExtension$updateExtension({
    this.clientMutationId,
    this.$extension,
    this.$__typename = 'UpdateExtensionPayload',
  });

  factory Mutation$UpdateExtension$updateExtension.fromJson(
      Map<String, dynamic> json) {
    final l$clientMutationId = json['clientMutationId'];
    final l$$extension = json['extension'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateExtension$updateExtension(
      clientMutationId: (l$clientMutationId as String?),
      $extension: l$$extension == null
          ? null
          : Fragment$ExtensionDto.fromJson(
              (l$$extension as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final String? clientMutationId;

  final Fragment$ExtensionDto? $extension;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$clientMutationId = clientMutationId;
    _resultData['clientMutationId'] = l$clientMutationId;
    final l$$extension = $extension;
    _resultData['extension'] = l$$extension?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$clientMutationId = clientMutationId;
    final l$$extension = $extension;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$clientMutationId,
      l$$extension,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$UpdateExtension$updateExtension ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    final l$$extension = $extension;
    final lOther$$extension = other.$extension;
    if (l$$extension != lOther$$extension) {
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

extension UtilityExtension$Mutation$UpdateExtension$updateExtension
    on Mutation$UpdateExtension$updateExtension {
  CopyWith$Mutation$UpdateExtension$updateExtension<
          Mutation$UpdateExtension$updateExtension>
      get copyWith => CopyWith$Mutation$UpdateExtension$updateExtension(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdateExtension$updateExtension<TRes> {
  factory CopyWith$Mutation$UpdateExtension$updateExtension(
    Mutation$UpdateExtension$updateExtension instance,
    TRes Function(Mutation$UpdateExtension$updateExtension) then,
  ) = _CopyWithImpl$Mutation$UpdateExtension$updateExtension;

  factory CopyWith$Mutation$UpdateExtension$updateExtension.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateExtension$updateExtension;

  TRes call({
    String? clientMutationId,
    Fragment$ExtensionDto? $extension,
    String? $__typename,
  });
  CopyWith$Fragment$ExtensionDto<TRes> get $extension;
}

class _CopyWithImpl$Mutation$UpdateExtension$updateExtension<TRes>
    implements CopyWith$Mutation$UpdateExtension$updateExtension<TRes> {
  _CopyWithImpl$Mutation$UpdateExtension$updateExtension(
    this._instance,
    this._then,
  );

  final Mutation$UpdateExtension$updateExtension _instance;

  final TRes Function(Mutation$UpdateExtension$updateExtension) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? clientMutationId = _undefined,
    Object? $extension = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateExtension$updateExtension(
        clientMutationId: clientMutationId == _undefined
            ? _instance.clientMutationId
            : (clientMutationId as String?),
        $extension: $extension == _undefined
            ? _instance.$extension
            : ($extension as Fragment$ExtensionDto?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Fragment$ExtensionDto<TRes> get $extension {
    final local$$extension = _instance.$extension;
    return local$$extension == null
        ? CopyWith$Fragment$ExtensionDto.stub(_then(_instance))
        : CopyWith$Fragment$ExtensionDto(
            local$$extension, (e) => call($extension: e));
  }
}

class _CopyWithStubImpl$Mutation$UpdateExtension$updateExtension<TRes>
    implements CopyWith$Mutation$UpdateExtension$updateExtension<TRes> {
  _CopyWithStubImpl$Mutation$UpdateExtension$updateExtension(this._res);

  TRes _res;

  call({
    String? clientMutationId,
    Fragment$ExtensionDto? $extension,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$ExtensionDto<TRes> get $extension =>
      CopyWith$Fragment$ExtensionDto.stub(_res);
}

class Variables$Mutation$InstallExternalExtension {
  factory Variables$Mutation$InstallExternalExtension(
          {required MultipartFile extensionFile}) =>
      Variables$Mutation$InstallExternalExtension._({
        r'extensionFile': extensionFile,
      });

  Variables$Mutation$InstallExternalExtension._(this._$data);

  factory Variables$Mutation$InstallExternalExtension.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$extensionFile = data['extensionFile'];
    result$data['extensionFile'] = fileFromJson(l$extensionFile);
    return Variables$Mutation$InstallExternalExtension._(result$data);
  }

  Map<String, dynamic> _$data;

  MultipartFile get extensionFile => (_$data['extensionFile'] as MultipartFile);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$extensionFile = extensionFile;
    result$data['extensionFile'] = fileToJson(l$extensionFile);
    return result$data;
  }

  CopyWith$Variables$Mutation$InstallExternalExtension<
          Variables$Mutation$InstallExternalExtension>
      get copyWith => CopyWith$Variables$Mutation$InstallExternalExtension(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$InstallExternalExtension ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$extensionFile = extensionFile;
    final lOther$extensionFile = other.extensionFile;
    if (l$extensionFile != lOther$extensionFile) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$extensionFile = extensionFile;
    return Object.hashAll([l$extensionFile]);
  }
}

abstract class CopyWith$Variables$Mutation$InstallExternalExtension<TRes> {
  factory CopyWith$Variables$Mutation$InstallExternalExtension(
    Variables$Mutation$InstallExternalExtension instance,
    TRes Function(Variables$Mutation$InstallExternalExtension) then,
  ) = _CopyWithImpl$Variables$Mutation$InstallExternalExtension;

  factory CopyWith$Variables$Mutation$InstallExternalExtension.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$InstallExternalExtension;

  TRes call({MultipartFile? extensionFile});
}

class _CopyWithImpl$Variables$Mutation$InstallExternalExtension<TRes>
    implements CopyWith$Variables$Mutation$InstallExternalExtension<TRes> {
  _CopyWithImpl$Variables$Mutation$InstallExternalExtension(
    this._instance,
    this._then,
  );

  final Variables$Mutation$InstallExternalExtension _instance;

  final TRes Function(Variables$Mutation$InstallExternalExtension) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? extensionFile = _undefined}) =>
      _then(Variables$Mutation$InstallExternalExtension._({
        ..._instance._$data,
        if (extensionFile != _undefined && extensionFile != null)
          'extensionFile': (extensionFile as MultipartFile),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$InstallExternalExtension<TRes>
    implements CopyWith$Variables$Mutation$InstallExternalExtension<TRes> {
  _CopyWithStubImpl$Variables$Mutation$InstallExternalExtension(this._res);

  TRes _res;

  call({MultipartFile? extensionFile}) => _res;
}

class Mutation$InstallExternalExtension {
  Mutation$InstallExternalExtension({
    this.installExternalExtension,
    this.$__typename = 'Mutation',
  });

  factory Mutation$InstallExternalExtension.fromJson(
      Map<String, dynamic> json) {
    final l$installExternalExtension = json['installExternalExtension'];
    final l$$__typename = json['__typename'];
    return Mutation$InstallExternalExtension(
      installExternalExtension: l$installExternalExtension == null
          ? null
          : Mutation$InstallExternalExtension$installExternalExtension.fromJson(
              (l$installExternalExtension as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$InstallExternalExtension$installExternalExtension?
      installExternalExtension;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$installExternalExtension = installExternalExtension;
    _resultData['installExternalExtension'] =
        l$installExternalExtension?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$installExternalExtension = installExternalExtension;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$installExternalExtension,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$InstallExternalExtension ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$installExternalExtension = installExternalExtension;
    final lOther$installExternalExtension = other.installExternalExtension;
    if (l$installExternalExtension != lOther$installExternalExtension) {
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

extension UtilityExtension$Mutation$InstallExternalExtension
    on Mutation$InstallExternalExtension {
  CopyWith$Mutation$InstallExternalExtension<Mutation$InstallExternalExtension>
      get copyWith => CopyWith$Mutation$InstallExternalExtension(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$InstallExternalExtension<TRes> {
  factory CopyWith$Mutation$InstallExternalExtension(
    Mutation$InstallExternalExtension instance,
    TRes Function(Mutation$InstallExternalExtension) then,
  ) = _CopyWithImpl$Mutation$InstallExternalExtension;

  factory CopyWith$Mutation$InstallExternalExtension.stub(TRes res) =
      _CopyWithStubImpl$Mutation$InstallExternalExtension;

  TRes call({
    Mutation$InstallExternalExtension$installExternalExtension?
        installExternalExtension,
    String? $__typename,
  });
  CopyWith$Mutation$InstallExternalExtension$installExternalExtension<TRes>
      get installExternalExtension;
}

class _CopyWithImpl$Mutation$InstallExternalExtension<TRes>
    implements CopyWith$Mutation$InstallExternalExtension<TRes> {
  _CopyWithImpl$Mutation$InstallExternalExtension(
    this._instance,
    this._then,
  );

  final Mutation$InstallExternalExtension _instance;

  final TRes Function(Mutation$InstallExternalExtension) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? installExternalExtension = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$InstallExternalExtension(
        installExternalExtension: installExternalExtension == _undefined
            ? _instance.installExternalExtension
            : (installExternalExtension
                as Mutation$InstallExternalExtension$installExternalExtension?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$InstallExternalExtension$installExternalExtension<TRes>
      get installExternalExtension {
    final local$installExternalExtension = _instance.installExternalExtension;
    return local$installExternalExtension == null
        ? CopyWith$Mutation$InstallExternalExtension$installExternalExtension
            .stub(_then(_instance))
        : CopyWith$Mutation$InstallExternalExtension$installExternalExtension(
            local$installExternalExtension,
            (e) => call(installExternalExtension: e));
  }
}

class _CopyWithStubImpl$Mutation$InstallExternalExtension<TRes>
    implements CopyWith$Mutation$InstallExternalExtension<TRes> {
  _CopyWithStubImpl$Mutation$InstallExternalExtension(this._res);

  TRes _res;

  call({
    Mutation$InstallExternalExtension$installExternalExtension?
        installExternalExtension,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$InstallExternalExtension$installExternalExtension<TRes>
      get installExternalExtension =>
          CopyWith$Mutation$InstallExternalExtension$installExternalExtension
              .stub(_res);
}

const documentNodeMutationInstallExternalExtension = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'InstallExternalExtension'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'extensionFile')),
        type: NamedTypeNode(
          name: NameNode(value: 'Upload'),
          isNonNull: true,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      )
    ],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'installExternalExtension'),
        alias: null,
        arguments: [
          ArgumentNode(
            name: NameNode(value: 'input'),
            value: ObjectValueNode(fields: [
              ObjectFieldNode(
                name: NameNode(value: 'extensionFile'),
                value: VariableNode(name: NameNode(value: 'extensionFile')),
              )
            ]),
          )
        ],
        directives: [],
        selectionSet: SelectionSetNode(selections: [
          FieldNode(
            name: NameNode(value: 'clientMutationId'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null,
          ),
          FieldNode(
            name: NameNode(value: 'extension'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: SelectionSetNode(selections: [
              FragmentSpreadNode(
                name: NameNode(value: 'ExtensionDto'),
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
  fragmentDefinitionExtensionDto,
]);
Mutation$InstallExternalExtension _parserFn$Mutation$InstallExternalExtension(
        Map<String, dynamic> data) =>
    Mutation$InstallExternalExtension.fromJson(data);
typedef OnMutationCompleted$Mutation$InstallExternalExtension = FutureOr<void>
    Function(
  Map<String, dynamic>?,
  Mutation$InstallExternalExtension?,
);

class Options$Mutation$InstallExternalExtension
    extends graphql.MutationOptions<Mutation$InstallExternalExtension> {
  Options$Mutation$InstallExternalExtension({
    String? operationName,
    required Variables$Mutation$InstallExternalExtension variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$InstallExternalExtension? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$InstallExternalExtension? onCompleted,
    graphql.OnMutationUpdate<Mutation$InstallExternalExtension>? update,
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
                        : _parserFn$Mutation$InstallExternalExtension(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationInstallExternalExtension,
          parserFn: _parserFn$Mutation$InstallExternalExtension,
        );

  final OnMutationCompleted$Mutation$InstallExternalExtension?
      onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$InstallExternalExtension
    extends graphql.WatchQueryOptions<Mutation$InstallExternalExtension> {
  WatchOptions$Mutation$InstallExternalExtension({
    String? operationName,
    required Variables$Mutation$InstallExternalExtension variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$InstallExternalExtension? typedOptimisticResult,
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
          document: documentNodeMutationInstallExternalExtension,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$InstallExternalExtension,
        );
}

extension ClientExtension$Mutation$InstallExternalExtension
    on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$InstallExternalExtension>>
      mutate$InstallExternalExtension(
              Options$Mutation$InstallExternalExtension options) async =>
          await this.mutate(options);

  graphql.ObservableQuery<Mutation$InstallExternalExtension>
      watchMutation$InstallExternalExtension(
              WatchOptions$Mutation$InstallExternalExtension options) =>
          this.watchMutation(options);
}

class Mutation$InstallExternalExtension$HookResult {
  Mutation$InstallExternalExtension$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$InstallExternalExtension runMutation;

  final graphql.QueryResult<Mutation$InstallExternalExtension> result;
}

Mutation$InstallExternalExtension$HookResult
    useMutation$InstallExternalExtension(
        [WidgetOptions$Mutation$InstallExternalExtension? options]) {
  final result = graphql_flutter.useMutation(
      options ?? WidgetOptions$Mutation$InstallExternalExtension());
  return Mutation$InstallExternalExtension$HookResult(
    (variables, {optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables.toJson(),
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$InstallExternalExtension>
    useWatchMutation$InstallExternalExtension(
            WatchOptions$Mutation$InstallExternalExtension options) =>
        graphql_flutter.useWatchMutation(options);

class WidgetOptions$Mutation$InstallExternalExtension
    extends graphql.MutationOptions<Mutation$InstallExternalExtension> {
  WidgetOptions$Mutation$InstallExternalExtension({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$InstallExternalExtension? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$InstallExternalExtension? onCompleted,
    graphql.OnMutationUpdate<Mutation$InstallExternalExtension>? update,
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
                        : _parserFn$Mutation$InstallExternalExtension(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationInstallExternalExtension,
          parserFn: _parserFn$Mutation$InstallExternalExtension,
        );

  final OnMutationCompleted$Mutation$InstallExternalExtension?
      onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$InstallExternalExtension
    = graphql.MultiSourceResult<Mutation$InstallExternalExtension> Function(
  Variables$Mutation$InstallExternalExtension, {
  Object? optimisticResult,
  Mutation$InstallExternalExtension? typedOptimisticResult,
});
typedef Builder$Mutation$InstallExternalExtension = widgets.Widget Function(
  RunMutation$Mutation$InstallExternalExtension,
  graphql.QueryResult<Mutation$InstallExternalExtension>?,
);

class Mutation$InstallExternalExtension$Widget
    extends graphql_flutter.Mutation<Mutation$InstallExternalExtension> {
  Mutation$InstallExternalExtension$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$InstallExternalExtension? options,
    required Builder$Mutation$InstallExternalExtension builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$InstallExternalExtension(),
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

class Mutation$InstallExternalExtension$installExternalExtension {
  Mutation$InstallExternalExtension$installExternalExtension({
    this.clientMutationId,
    required this.$extension,
    this.$__typename = 'InstallExternalExtensionPayload',
  });

  factory Mutation$InstallExternalExtension$installExternalExtension.fromJson(
      Map<String, dynamic> json) {
    final l$clientMutationId = json['clientMutationId'];
    final l$$extension = json['extension'];
    final l$$__typename = json['__typename'];
    return Mutation$InstallExternalExtension$installExternalExtension(
      clientMutationId: (l$clientMutationId as String?),
      $extension: Fragment$ExtensionDto.fromJson(
          (l$$extension as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final String? clientMutationId;

  final Fragment$ExtensionDto $extension;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$clientMutationId = clientMutationId;
    _resultData['clientMutationId'] = l$clientMutationId;
    final l$$extension = $extension;
    _resultData['extension'] = l$$extension.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$clientMutationId = clientMutationId;
    final l$$extension = $extension;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$clientMutationId,
      l$$extension,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$InstallExternalExtension$installExternalExtension ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    final l$$extension = $extension;
    final lOther$$extension = other.$extension;
    if (l$$extension != lOther$$extension) {
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

extension UtilityExtension$Mutation$InstallExternalExtension$installExternalExtension
    on Mutation$InstallExternalExtension$installExternalExtension {
  CopyWith$Mutation$InstallExternalExtension$installExternalExtension<
          Mutation$InstallExternalExtension$installExternalExtension>
      get copyWith =>
          CopyWith$Mutation$InstallExternalExtension$installExternalExtension(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$InstallExternalExtension$installExternalExtension<
    TRes> {
  factory CopyWith$Mutation$InstallExternalExtension$installExternalExtension(
    Mutation$InstallExternalExtension$installExternalExtension instance,
    TRes Function(Mutation$InstallExternalExtension$installExternalExtension)
        then,
  ) = _CopyWithImpl$Mutation$InstallExternalExtension$installExternalExtension;

  factory CopyWith$Mutation$InstallExternalExtension$installExternalExtension.stub(
          TRes res) =
      _CopyWithStubImpl$Mutation$InstallExternalExtension$installExternalExtension;

  TRes call({
    String? clientMutationId,
    Fragment$ExtensionDto? $extension,
    String? $__typename,
  });
  CopyWith$Fragment$ExtensionDto<TRes> get $extension;
}

class _CopyWithImpl$Mutation$InstallExternalExtension$installExternalExtension<
        TRes>
    implements
        CopyWith$Mutation$InstallExternalExtension$installExternalExtension<
            TRes> {
  _CopyWithImpl$Mutation$InstallExternalExtension$installExternalExtension(
    this._instance,
    this._then,
  );

  final Mutation$InstallExternalExtension$installExternalExtension _instance;

  final TRes Function(
      Mutation$InstallExternalExtension$installExternalExtension) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? clientMutationId = _undefined,
    Object? $extension = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$InstallExternalExtension$installExternalExtension(
        clientMutationId: clientMutationId == _undefined
            ? _instance.clientMutationId
            : (clientMutationId as String?),
        $extension: $extension == _undefined || $extension == null
            ? _instance.$extension
            : ($extension as Fragment$ExtensionDto),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Fragment$ExtensionDto<TRes> get $extension {
    final local$$extension = _instance.$extension;
    return CopyWith$Fragment$ExtensionDto(
        local$$extension, (e) => call($extension: e));
  }
}

class _CopyWithStubImpl$Mutation$InstallExternalExtension$installExternalExtension<
        TRes>
    implements
        CopyWith$Mutation$InstallExternalExtension$installExternalExtension<
            TRes> {
  _CopyWithStubImpl$Mutation$InstallExternalExtension$installExternalExtension(
      this._res);

  TRes _res;

  call({
    String? clientMutationId,
    Fragment$ExtensionDto? $extension,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$ExtensionDto<TRes> get $extension =>
      CopyWith$Fragment$ExtensionDto.stub(_res);
}

class Mutation$FetchExtensionList {
  Mutation$FetchExtensionList({
    this.fetchExtensions,
    this.$__typename = 'Mutation',
  });

  factory Mutation$FetchExtensionList.fromJson(Map<String, dynamic> json) {
    final l$fetchExtensions = json['fetchExtensions'];
    final l$$__typename = json['__typename'];
    return Mutation$FetchExtensionList(
      fetchExtensions: l$fetchExtensions == null
          ? null
          : Mutation$FetchExtensionList$fetchExtensions.fromJson(
              (l$fetchExtensions as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$FetchExtensionList$fetchExtensions? fetchExtensions;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$fetchExtensions = fetchExtensions;
    _resultData['fetchExtensions'] = l$fetchExtensions?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$fetchExtensions = fetchExtensions;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$fetchExtensions,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$FetchExtensionList ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$fetchExtensions = fetchExtensions;
    final lOther$fetchExtensions = other.fetchExtensions;
    if (l$fetchExtensions != lOther$fetchExtensions) {
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

extension UtilityExtension$Mutation$FetchExtensionList
    on Mutation$FetchExtensionList {
  CopyWith$Mutation$FetchExtensionList<Mutation$FetchExtensionList>
      get copyWith => CopyWith$Mutation$FetchExtensionList(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$FetchExtensionList<TRes> {
  factory CopyWith$Mutation$FetchExtensionList(
    Mutation$FetchExtensionList instance,
    TRes Function(Mutation$FetchExtensionList) then,
  ) = _CopyWithImpl$Mutation$FetchExtensionList;

  factory CopyWith$Mutation$FetchExtensionList.stub(TRes res) =
      _CopyWithStubImpl$Mutation$FetchExtensionList;

  TRes call({
    Mutation$FetchExtensionList$fetchExtensions? fetchExtensions,
    String? $__typename,
  });
  CopyWith$Mutation$FetchExtensionList$fetchExtensions<TRes>
      get fetchExtensions;
}

class _CopyWithImpl$Mutation$FetchExtensionList<TRes>
    implements CopyWith$Mutation$FetchExtensionList<TRes> {
  _CopyWithImpl$Mutation$FetchExtensionList(
    this._instance,
    this._then,
  );

  final Mutation$FetchExtensionList _instance;

  final TRes Function(Mutation$FetchExtensionList) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? fetchExtensions = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$FetchExtensionList(
        fetchExtensions: fetchExtensions == _undefined
            ? _instance.fetchExtensions
            : (fetchExtensions as Mutation$FetchExtensionList$fetchExtensions?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$FetchExtensionList$fetchExtensions<TRes>
      get fetchExtensions {
    final local$fetchExtensions = _instance.fetchExtensions;
    return local$fetchExtensions == null
        ? CopyWith$Mutation$FetchExtensionList$fetchExtensions.stub(
            _then(_instance))
        : CopyWith$Mutation$FetchExtensionList$fetchExtensions(
            local$fetchExtensions, (e) => call(fetchExtensions: e));
  }
}

class _CopyWithStubImpl$Mutation$FetchExtensionList<TRes>
    implements CopyWith$Mutation$FetchExtensionList<TRes> {
  _CopyWithStubImpl$Mutation$FetchExtensionList(this._res);

  TRes _res;

  call({
    Mutation$FetchExtensionList$fetchExtensions? fetchExtensions,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$FetchExtensionList$fetchExtensions<TRes>
      get fetchExtensions =>
          CopyWith$Mutation$FetchExtensionList$fetchExtensions.stub(_res);
}

const documentNodeMutationFetchExtensionList = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'FetchExtensionList'),
    variableDefinitions: [],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'fetchExtensions'),
        alias: null,
        arguments: [
          ArgumentNode(
            name: NameNode(value: 'input'),
            value: ObjectValueNode(fields: []),
          )
        ],
        directives: [],
        selectionSet: SelectionSetNode(selections: [
          FieldNode(
            name: NameNode(value: 'clientMutationId'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null,
          ),
          FieldNode(
            name: NameNode(value: 'extensions'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: SelectionSetNode(selections: [
              FragmentSpreadNode(
                name: NameNode(value: 'ExtensionDto'),
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
  fragmentDefinitionExtensionDto,
]);
Mutation$FetchExtensionList _parserFn$Mutation$FetchExtensionList(
        Map<String, dynamic> data) =>
    Mutation$FetchExtensionList.fromJson(data);
typedef OnMutationCompleted$Mutation$FetchExtensionList = FutureOr<void>
    Function(
  Map<String, dynamic>?,
  Mutation$FetchExtensionList?,
);

class Options$Mutation$FetchExtensionList
    extends graphql.MutationOptions<Mutation$FetchExtensionList> {
  Options$Mutation$FetchExtensionList({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$FetchExtensionList? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$FetchExtensionList? onCompleted,
    graphql.OnMutationUpdate<Mutation$FetchExtensionList>? update,
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
                        : _parserFn$Mutation$FetchExtensionList(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationFetchExtensionList,
          parserFn: _parserFn$Mutation$FetchExtensionList,
        );

  final OnMutationCompleted$Mutation$FetchExtensionList? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$FetchExtensionList
    extends graphql.WatchQueryOptions<Mutation$FetchExtensionList> {
  WatchOptions$Mutation$FetchExtensionList({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$FetchExtensionList? typedOptimisticResult,
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
          document: documentNodeMutationFetchExtensionList,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$FetchExtensionList,
        );
}

extension ClientExtension$Mutation$FetchExtensionList on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$FetchExtensionList>>
      mutate$FetchExtensionList(
              [Options$Mutation$FetchExtensionList? options]) async =>
          await this.mutate(options ?? Options$Mutation$FetchExtensionList());

  graphql.ObservableQuery<
      Mutation$FetchExtensionList> watchMutation$FetchExtensionList(
          [WatchOptions$Mutation$FetchExtensionList? options]) =>
      this.watchMutation(options ?? WatchOptions$Mutation$FetchExtensionList());
}

class Mutation$FetchExtensionList$HookResult {
  Mutation$FetchExtensionList$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$FetchExtensionList runMutation;

  final graphql.QueryResult<Mutation$FetchExtensionList> result;
}

Mutation$FetchExtensionList$HookResult useMutation$FetchExtensionList(
    [WidgetOptions$Mutation$FetchExtensionList? options]) {
  final result = graphql_flutter
      .useMutation(options ?? WidgetOptions$Mutation$FetchExtensionList());
  return Mutation$FetchExtensionList$HookResult(
    ({optimisticResult, typedOptimisticResult}) => result.runMutation(
      const {},
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$FetchExtensionList>
    useWatchMutation$FetchExtensionList(
            [WatchOptions$Mutation$FetchExtensionList? options]) =>
        graphql_flutter.useWatchMutation(
            options ?? WatchOptions$Mutation$FetchExtensionList());

class WidgetOptions$Mutation$FetchExtensionList
    extends graphql.MutationOptions<Mutation$FetchExtensionList> {
  WidgetOptions$Mutation$FetchExtensionList({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$FetchExtensionList? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$FetchExtensionList? onCompleted,
    graphql.OnMutationUpdate<Mutation$FetchExtensionList>? update,
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
                        : _parserFn$Mutation$FetchExtensionList(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationFetchExtensionList,
          parserFn: _parserFn$Mutation$FetchExtensionList,
        );

  final OnMutationCompleted$Mutation$FetchExtensionList? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$FetchExtensionList
    = graphql.MultiSourceResult<Mutation$FetchExtensionList> Function({
  Object? optimisticResult,
  Mutation$FetchExtensionList? typedOptimisticResult,
});
typedef Builder$Mutation$FetchExtensionList = widgets.Widget Function(
  RunMutation$Mutation$FetchExtensionList,
  graphql.QueryResult<Mutation$FetchExtensionList>?,
);

class Mutation$FetchExtensionList$Widget
    extends graphql_flutter.Mutation<Mutation$FetchExtensionList> {
  Mutation$FetchExtensionList$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$FetchExtensionList? options,
    required Builder$Mutation$FetchExtensionList builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$FetchExtensionList(),
          builder: (
            run,
            result,
          ) =>
              builder(
            ({
              optimisticResult,
              typedOptimisticResult,
            }) =>
                run(
              const {},
              optimisticResult:
                  optimisticResult ?? typedOptimisticResult?.toJson(),
            ),
            result,
          ),
        );
}

class Mutation$FetchExtensionList$fetchExtensions {
  Mutation$FetchExtensionList$fetchExtensions({
    this.clientMutationId,
    required this.extensions,
    this.$__typename = 'FetchExtensionsPayload',
  });

  factory Mutation$FetchExtensionList$fetchExtensions.fromJson(
      Map<String, dynamic> json) {
    final l$clientMutationId = json['clientMutationId'];
    final l$extensions = json['extensions'];
    final l$$__typename = json['__typename'];
    return Mutation$FetchExtensionList$fetchExtensions(
      clientMutationId: (l$clientMutationId as String?),
      extensions: (l$extensions as List<dynamic>)
          .map((e) =>
              Fragment$ExtensionDto.fromJson((e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final String? clientMutationId;

  final List<Fragment$ExtensionDto> extensions;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$clientMutationId = clientMutationId;
    _resultData['clientMutationId'] = l$clientMutationId;
    final l$extensions = extensions;
    _resultData['extensions'] = l$extensions.map((e) => e.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$clientMutationId = clientMutationId;
    final l$extensions = extensions;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$clientMutationId,
      Object.hashAll(l$extensions.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$FetchExtensionList$fetchExtensions ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$clientMutationId = clientMutationId;
    final lOther$clientMutationId = other.clientMutationId;
    if (l$clientMutationId != lOther$clientMutationId) {
      return false;
    }
    final l$extensions = extensions;
    final lOther$extensions = other.extensions;
    if (l$extensions.length != lOther$extensions.length) {
      return false;
    }
    for (int i = 0; i < l$extensions.length; i++) {
      final l$extensions$entry = l$extensions[i];
      final lOther$extensions$entry = lOther$extensions[i];
      if (l$extensions$entry != lOther$extensions$entry) {
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

extension UtilityExtension$Mutation$FetchExtensionList$fetchExtensions
    on Mutation$FetchExtensionList$fetchExtensions {
  CopyWith$Mutation$FetchExtensionList$fetchExtensions<
          Mutation$FetchExtensionList$fetchExtensions>
      get copyWith => CopyWith$Mutation$FetchExtensionList$fetchExtensions(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$FetchExtensionList$fetchExtensions<TRes> {
  factory CopyWith$Mutation$FetchExtensionList$fetchExtensions(
    Mutation$FetchExtensionList$fetchExtensions instance,
    TRes Function(Mutation$FetchExtensionList$fetchExtensions) then,
  ) = _CopyWithImpl$Mutation$FetchExtensionList$fetchExtensions;

  factory CopyWith$Mutation$FetchExtensionList$fetchExtensions.stub(TRes res) =
      _CopyWithStubImpl$Mutation$FetchExtensionList$fetchExtensions;

  TRes call({
    String? clientMutationId,
    List<Fragment$ExtensionDto>? extensions,
    String? $__typename,
  });
  TRes extensions(
      Iterable<Fragment$ExtensionDto> Function(
              Iterable<CopyWith$Fragment$ExtensionDto<Fragment$ExtensionDto>>)
          _fn);
}

class _CopyWithImpl$Mutation$FetchExtensionList$fetchExtensions<TRes>
    implements CopyWith$Mutation$FetchExtensionList$fetchExtensions<TRes> {
  _CopyWithImpl$Mutation$FetchExtensionList$fetchExtensions(
    this._instance,
    this._then,
  );

  final Mutation$FetchExtensionList$fetchExtensions _instance;

  final TRes Function(Mutation$FetchExtensionList$fetchExtensions) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? clientMutationId = _undefined,
    Object? extensions = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$FetchExtensionList$fetchExtensions(
        clientMutationId: clientMutationId == _undefined
            ? _instance.clientMutationId
            : (clientMutationId as String?),
        extensions: extensions == _undefined || extensions == null
            ? _instance.extensions
            : (extensions as List<Fragment$ExtensionDto>),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  TRes extensions(
          Iterable<Fragment$ExtensionDto> Function(
                  Iterable<
                      CopyWith$Fragment$ExtensionDto<Fragment$ExtensionDto>>)
              _fn) =>
      call(
          extensions: _fn(
              _instance.extensions.map((e) => CopyWith$Fragment$ExtensionDto(
                    e,
                    (i) => i,
                  ))).toList());
}

class _CopyWithStubImpl$Mutation$FetchExtensionList$fetchExtensions<TRes>
    implements CopyWith$Mutation$FetchExtensionList$fetchExtensions<TRes> {
  _CopyWithStubImpl$Mutation$FetchExtensionList$fetchExtensions(this._res);

  TRes _res;

  call({
    String? clientMutationId,
    List<Fragment$ExtensionDto>? extensions,
    String? $__typename,
  }) =>
      _res;

  extensions(_fn) => _res;
}
