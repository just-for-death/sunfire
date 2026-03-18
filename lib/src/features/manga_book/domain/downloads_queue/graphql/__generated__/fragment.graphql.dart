import '../../../../../../graphql/__generated__/schema.graphql.dart';
import '../../../downloads/graphql/__generated__/fragment.graphql.dart';
import 'package:gql/ast.dart';
import 'package:graphql/client.dart' as graphql;

class Fragment$DownloadStatusDto {
  Fragment$DownloadStatusDto({
    required this.state,
    required this.queue,
    this.$__typename = 'DownloadStatus',
  });

  factory Fragment$DownloadStatusDto.fromJson(Map<String, dynamic> json) {
    final l$state = json['state'];
    final l$queue = json['queue'];
    final l$$__typename = json['__typename'];
    return Fragment$DownloadStatusDto(
      state: fromJson$Enum$DownloaderState((l$state as String)),
      queue: (l$queue as List<dynamic>)
          .map(
              (e) => Fragment$DownloadDto.fromJson((e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final Enum$DownloaderState state;

  final List<Fragment$DownloadDto> queue;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$state = state;
    _resultData['state'] = toJson$Enum$DownloaderState(l$state);
    final l$queue = queue;
    _resultData['queue'] = l$queue.map((e) => e.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$state = state;
    final l$queue = queue;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$state,
      Object.hashAll(l$queue.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$DownloadStatusDto ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$state = state;
    final lOther$state = other.state;
    if (l$state != lOther$state) {
      return false;
    }
    final l$queue = queue;
    final lOther$queue = other.queue;
    if (l$queue.length != lOther$queue.length) {
      return false;
    }
    for (int i = 0; i < l$queue.length; i++) {
      final l$queue$entry = l$queue[i];
      final lOther$queue$entry = lOther$queue[i];
      if (l$queue$entry != lOther$queue$entry) {
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

extension UtilityExtension$Fragment$DownloadStatusDto
    on Fragment$DownloadStatusDto {
  CopyWith$Fragment$DownloadStatusDto<Fragment$DownloadStatusDto>
      get copyWith => CopyWith$Fragment$DownloadStatusDto(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Fragment$DownloadStatusDto<TRes> {
  factory CopyWith$Fragment$DownloadStatusDto(
    Fragment$DownloadStatusDto instance,
    TRes Function(Fragment$DownloadStatusDto) then,
  ) = _CopyWithImpl$Fragment$DownloadStatusDto;

  factory CopyWith$Fragment$DownloadStatusDto.stub(TRes res) =
      _CopyWithStubImpl$Fragment$DownloadStatusDto;

  TRes call({
    Enum$DownloaderState? state,
    List<Fragment$DownloadDto>? queue,
    String? $__typename,
  });
  TRes queue(
      Iterable<Fragment$DownloadDto> Function(
              Iterable<CopyWith$Fragment$DownloadDto<Fragment$DownloadDto>>)
          _fn);
}

class _CopyWithImpl$Fragment$DownloadStatusDto<TRes>
    implements CopyWith$Fragment$DownloadStatusDto<TRes> {
  _CopyWithImpl$Fragment$DownloadStatusDto(
    this._instance,
    this._then,
  );

  final Fragment$DownloadStatusDto _instance;

  final TRes Function(Fragment$DownloadStatusDto) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? state = _undefined,
    Object? queue = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$DownloadStatusDto(
        state: state == _undefined || state == null
            ? _instance.state
            : (state as Enum$DownloaderState),
        queue: queue == _undefined || queue == null
            ? _instance.queue
            : (queue as List<Fragment$DownloadDto>),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  TRes queue(
          Iterable<Fragment$DownloadDto> Function(
                  Iterable<CopyWith$Fragment$DownloadDto<Fragment$DownloadDto>>)
              _fn) =>
      call(
          queue: _fn(_instance.queue.map((e) => CopyWith$Fragment$DownloadDto(
                e,
                (i) => i,
              ))).toList());
}

class _CopyWithStubImpl$Fragment$DownloadStatusDto<TRes>
    implements CopyWith$Fragment$DownloadStatusDto<TRes> {
  _CopyWithStubImpl$Fragment$DownloadStatusDto(this._res);

  TRes _res;

  call({
    Enum$DownloaderState? state,
    List<Fragment$DownloadDto>? queue,
    String? $__typename,
  }) =>
      _res;

  queue(_fn) => _res;
}

const fragmentDefinitionDownloadStatusDto = FragmentDefinitionNode(
  name: NameNode(value: 'DownloadStatusDto'),
  typeCondition: TypeConditionNode(
      on: NamedTypeNode(
    name: NameNode(value: 'DownloadStatus'),
    isNonNull: false,
  )),
  directives: [],
  selectionSet: SelectionSetNode(selections: [
    FieldNode(
      name: NameNode(value: 'state'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'queue'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: SelectionSetNode(selections: [
        FragmentSpreadNode(
          name: NameNode(value: 'DownloadDto'),
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
);
const documentNodeFragmentDownloadStatusDto = DocumentNode(definitions: [
  fragmentDefinitionDownloadStatusDto,
  fragmentDefinitionDownloadDto,
]);

extension ClientExtension$Fragment$DownloadStatusDto on graphql.GraphQLClient {
  void writeFragment$DownloadStatusDto({
    required Fragment$DownloadStatusDto data,
    required Map<String, dynamic> idFields,
    bool broadcast = true,
  }) =>
      this.writeFragment(
        graphql.FragmentRequest(
          idFields: idFields,
          fragment: const graphql.Fragment(
            fragmentName: 'DownloadStatusDto',
            document: documentNodeFragmentDownloadStatusDto,
          ),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );

  Fragment$DownloadStatusDto? readFragment$DownloadStatusDto({
    required Map<String, dynamic> idFields,
    bool optimistic = true,
  }) {
    final result = this.readFragment(
      graphql.FragmentRequest(
        idFields: idFields,
        fragment: const graphql.Fragment(
          fragmentName: 'DownloadStatusDto',
          document: documentNodeFragmentDownloadStatusDto,
        ),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Fragment$DownloadStatusDto.fromJson(result);
  }
}
