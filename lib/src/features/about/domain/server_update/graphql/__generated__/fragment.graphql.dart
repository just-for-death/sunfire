import 'package:gql/ast.dart';
import 'package:graphql/client.dart' as graphql;

class Fragment$ServerUpdateDto {
  Fragment$ServerUpdateDto({
    required this.channel,
    required this.tag,
    required this.url,
    this.$__typename = 'CheckForServerUpdatesPayload',
  });

  factory Fragment$ServerUpdateDto.fromJson(Map<String, dynamic> json) {
    final l$channel = json['channel'];
    final l$tag = json['tag'];
    final l$url = json['url'];
    final l$$__typename = json['__typename'];
    return Fragment$ServerUpdateDto(
      channel: (l$channel as String),
      tag: (l$tag as String),
      url: (l$url as String),
      $__typename: (l$$__typename as String),
    );
  }

  final String channel;

  final String tag;

  final String url;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$channel = channel;
    _resultData['channel'] = l$channel;
    final l$tag = tag;
    _resultData['tag'] = l$tag;
    final l$url = url;
    _resultData['url'] = l$url;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$channel = channel;
    final l$tag = tag;
    final l$url = url;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$channel,
      l$tag,
      l$url,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$ServerUpdateDto ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$channel = channel;
    final lOther$channel = other.channel;
    if (l$channel != lOther$channel) {
      return false;
    }
    final l$tag = tag;
    final lOther$tag = other.tag;
    if (l$tag != lOther$tag) {
      return false;
    }
    final l$url = url;
    final lOther$url = other.url;
    if (l$url != lOther$url) {
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

extension UtilityExtension$Fragment$ServerUpdateDto
    on Fragment$ServerUpdateDto {
  CopyWith$Fragment$ServerUpdateDto<Fragment$ServerUpdateDto> get copyWith =>
      CopyWith$Fragment$ServerUpdateDto(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Fragment$ServerUpdateDto<TRes> {
  factory CopyWith$Fragment$ServerUpdateDto(
    Fragment$ServerUpdateDto instance,
    TRes Function(Fragment$ServerUpdateDto) then,
  ) = _CopyWithImpl$Fragment$ServerUpdateDto;

  factory CopyWith$Fragment$ServerUpdateDto.stub(TRes res) =
      _CopyWithStubImpl$Fragment$ServerUpdateDto;

  TRes call({
    String? channel,
    String? tag,
    String? url,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$ServerUpdateDto<TRes>
    implements CopyWith$Fragment$ServerUpdateDto<TRes> {
  _CopyWithImpl$Fragment$ServerUpdateDto(
    this._instance,
    this._then,
  );

  final Fragment$ServerUpdateDto _instance;

  final TRes Function(Fragment$ServerUpdateDto) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? channel = _undefined,
    Object? tag = _undefined,
    Object? url = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$ServerUpdateDto(
        channel: channel == _undefined || channel == null
            ? _instance.channel
            : (channel as String),
        tag: tag == _undefined || tag == null ? _instance.tag : (tag as String),
        url: url == _undefined || url == null ? _instance.url : (url as String),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Fragment$ServerUpdateDto<TRes>
    implements CopyWith$Fragment$ServerUpdateDto<TRes> {
  _CopyWithStubImpl$Fragment$ServerUpdateDto(this._res);

  TRes _res;

  call({
    String? channel,
    String? tag,
    String? url,
    String? $__typename,
  }) =>
      _res;
}

const fragmentDefinitionServerUpdateDto = FragmentDefinitionNode(
  name: NameNode(value: 'ServerUpdateDto'),
  typeCondition: TypeConditionNode(
      on: NamedTypeNode(
    name: NameNode(value: 'CheckForServerUpdatesPayload'),
    isNonNull: false,
  )),
  directives: [],
  selectionSet: SelectionSetNode(selections: [
    FieldNode(
      name: NameNode(value: 'channel'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'tag'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'url'),
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
const documentNodeFragmentServerUpdateDto = DocumentNode(definitions: [
  fragmentDefinitionServerUpdateDto,
]);

extension ClientExtension$Fragment$ServerUpdateDto on graphql.GraphQLClient {
  void writeFragment$ServerUpdateDto({
    required Fragment$ServerUpdateDto data,
    required Map<String, dynamic> idFields,
    bool broadcast = true,
  }) =>
      this.writeFragment(
        graphql.FragmentRequest(
          idFields: idFields,
          fragment: const graphql.Fragment(
            fragmentName: 'ServerUpdateDto',
            document: documentNodeFragmentServerUpdateDto,
          ),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );

  Fragment$ServerUpdateDto? readFragment$ServerUpdateDto({
    required Map<String, dynamic> idFields,
    bool optimistic = true,
  }) {
    final result = this.readFragment(
      graphql.FragmentRequest(
        idFields: idFields,
        fragment: const graphql.Fragment(
          fragmentName: 'ServerUpdateDto',
          document: documentNodeFragmentServerUpdateDto,
        ),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Fragment$ServerUpdateDto.fromJson(result);
  }
}
