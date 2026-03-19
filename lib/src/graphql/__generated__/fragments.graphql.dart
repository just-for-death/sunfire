import 'package:catalyst/src/utils/misc/scalars.dart';
import 'package:gql/ast.dart';
import 'package:graphql/client.dart' as graphql;

class Fragment$PageInfoDto {
  Fragment$PageInfoDto({
    this.endCursor,
    required this.hasNextPage,
    required this.hasPreviousPage,
    this.startCursor,
    this.$__typename = 'PageInfo',
  });

  factory Fragment$PageInfoDto.fromJson(Map<String, dynamic> json) {
    final l$endCursor = json['endCursor'];
    final l$hasNextPage = json['hasNextPage'];
    final l$hasPreviousPage = json['hasPreviousPage'];
    final l$startCursor = json['startCursor'];
    final l$$__typename = json['__typename'];
    return Fragment$PageInfoDto(
      endCursor: l$endCursor == null ? null : cursorFromJson(l$endCursor),
      hasNextPage: (l$hasNextPage as bool),
      hasPreviousPage: (l$hasPreviousPage as bool),
      startCursor: l$startCursor == null ? null : cursorFromJson(l$startCursor),
      $__typename: (l$$__typename as String),
    );
  }

  final int? endCursor;

  final bool hasNextPage;

  final bool hasPreviousPage;

  final int? startCursor;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$endCursor = endCursor;
    _resultData['endCursor'] =
        l$endCursor == null ? null : cursorToJson(l$endCursor);
    final l$hasNextPage = hasNextPage;
    _resultData['hasNextPage'] = l$hasNextPage;
    final l$hasPreviousPage = hasPreviousPage;
    _resultData['hasPreviousPage'] = l$hasPreviousPage;
    final l$startCursor = startCursor;
    _resultData['startCursor'] =
        l$startCursor == null ? null : cursorToJson(l$startCursor);
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$endCursor = endCursor;
    final l$hasNextPage = hasNextPage;
    final l$hasPreviousPage = hasPreviousPage;
    final l$startCursor = startCursor;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$endCursor,
      l$hasNextPage,
      l$hasPreviousPage,
      l$startCursor,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$PageInfoDto || runtimeType != other.runtimeType) {
      return false;
    }
    final l$endCursor = endCursor;
    final lOther$endCursor = other.endCursor;
    if (l$endCursor != lOther$endCursor) {
      return false;
    }
    final l$hasNextPage = hasNextPage;
    final lOther$hasNextPage = other.hasNextPage;
    if (l$hasNextPage != lOther$hasNextPage) {
      return false;
    }
    final l$hasPreviousPage = hasPreviousPage;
    final lOther$hasPreviousPage = other.hasPreviousPage;
    if (l$hasPreviousPage != lOther$hasPreviousPage) {
      return false;
    }
    final l$startCursor = startCursor;
    final lOther$startCursor = other.startCursor;
    if (l$startCursor != lOther$startCursor) {
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

extension UtilityExtension$Fragment$PageInfoDto on Fragment$PageInfoDto {
  CopyWith$Fragment$PageInfoDto<Fragment$PageInfoDto> get copyWith =>
      CopyWith$Fragment$PageInfoDto(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Fragment$PageInfoDto<TRes> {
  factory CopyWith$Fragment$PageInfoDto(
    Fragment$PageInfoDto instance,
    TRes Function(Fragment$PageInfoDto) then,
  ) = _CopyWithImpl$Fragment$PageInfoDto;

  factory CopyWith$Fragment$PageInfoDto.stub(TRes res) =
      _CopyWithStubImpl$Fragment$PageInfoDto;

  TRes call({
    int? endCursor,
    bool? hasNextPage,
    bool? hasPreviousPage,
    int? startCursor,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$PageInfoDto<TRes>
    implements CopyWith$Fragment$PageInfoDto<TRes> {
  _CopyWithImpl$Fragment$PageInfoDto(
    this._instance,
    this._then,
  );

  final Fragment$PageInfoDto _instance;

  final TRes Function(Fragment$PageInfoDto) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? endCursor = _undefined,
    Object? hasNextPage = _undefined,
    Object? hasPreviousPage = _undefined,
    Object? startCursor = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$PageInfoDto(
        endCursor:
            endCursor == _undefined ? _instance.endCursor : (endCursor as int?),
        hasNextPage: hasNextPage == _undefined || hasNextPage == null
            ? _instance.hasNextPage
            : (hasNextPage as bool),
        hasPreviousPage:
            hasPreviousPage == _undefined || hasPreviousPage == null
                ? _instance.hasPreviousPage
                : (hasPreviousPage as bool),
        startCursor: startCursor == _undefined
            ? _instance.startCursor
            : (startCursor as int?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Fragment$PageInfoDto<TRes>
    implements CopyWith$Fragment$PageInfoDto<TRes> {
  _CopyWithStubImpl$Fragment$PageInfoDto(this._res);

  TRes _res;

  call({
    int? endCursor,
    bool? hasNextPage,
    bool? hasPreviousPage,
    int? startCursor,
    String? $__typename,
  }) =>
      _res;
}

const fragmentDefinitionPageInfoDto = FragmentDefinitionNode(
  name: NameNode(value: 'PageInfoDto'),
  typeCondition: TypeConditionNode(
      on: NamedTypeNode(
    name: NameNode(value: 'PageInfo'),
    isNonNull: false,
  )),
  directives: [],
  selectionSet: SelectionSetNode(selections: [
    FieldNode(
      name: NameNode(value: 'endCursor'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'hasNextPage'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'hasPreviousPage'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'startCursor'),
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
);
const documentNodeFragmentPageInfoDto = DocumentNode(definitions: [
  fragmentDefinitionPageInfoDto,
]);

extension ClientExtension$Fragment$PageInfoDto on graphql.GraphQLClient {
  void writeFragment$PageInfoDto({
    required Fragment$PageInfoDto data,
    required Map<String, dynamic> idFields,
    bool broadcast = true,
  }) =>
      this.writeFragment(
        graphql.FragmentRequest(
          idFields: idFields,
          fragment: const graphql.Fragment(
            fragmentName: 'PageInfoDto',
            document: documentNodeFragmentPageInfoDto,
          ),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );

  Fragment$PageInfoDto? readFragment$PageInfoDto({
    required Map<String, dynamic> idFields,
    bool optimistic = true,
  }) {
    final result = this.readFragment(
      graphql.FragmentRequest(
        idFields: idFields,
        fragment: const graphql.Fragment(
          fragmentName: 'PageInfoDto',
          document: documentNodeFragmentPageInfoDto,
        ),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Fragment$PageInfoDto.fromJson(result);
  }
}
