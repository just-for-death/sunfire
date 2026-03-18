import '../../../../../../graphql/__generated__/fragments.graphql.dart';
import '../../../chapter/graphql/__generated__/fragment.graphql.dart';
import '../../../manga/graphql/__generated__/fragment.graphql.dart';
import 'package:gql/ast.dart';
import 'package:graphql/client.dart' as graphql;

class Fragment$ChapterPageDto {
  Fragment$ChapterPageDto({
    required this.nodes,
    required this.pageInfo,
    required this.totalCount,
    this.$__typename = 'ChapterNodeList',
  });

  factory Fragment$ChapterPageDto.fromJson(Map<String, dynamic> json) {
    final l$nodes = json['nodes'];
    final l$pageInfo = json['pageInfo'];
    final l$totalCount = json['totalCount'];
    final l$$__typename = json['__typename'];
    return Fragment$ChapterPageDto(
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
    if (other is! Fragment$ChapterPageDto || runtimeType != other.runtimeType) {
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

extension UtilityExtension$Fragment$ChapterPageDto on Fragment$ChapterPageDto {
  CopyWith$Fragment$ChapterPageDto<Fragment$ChapterPageDto> get copyWith =>
      CopyWith$Fragment$ChapterPageDto(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Fragment$ChapterPageDto<TRes> {
  factory CopyWith$Fragment$ChapterPageDto(
    Fragment$ChapterPageDto instance,
    TRes Function(Fragment$ChapterPageDto) then,
  ) = _CopyWithImpl$Fragment$ChapterPageDto;

  factory CopyWith$Fragment$ChapterPageDto.stub(TRes res) =
      _CopyWithStubImpl$Fragment$ChapterPageDto;

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

class _CopyWithImpl$Fragment$ChapterPageDto<TRes>
    implements CopyWith$Fragment$ChapterPageDto<TRes> {
  _CopyWithImpl$Fragment$ChapterPageDto(
    this._instance,
    this._then,
  );

  final Fragment$ChapterPageDto _instance;

  final TRes Function(Fragment$ChapterPageDto) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? nodes = _undefined,
    Object? pageInfo = _undefined,
    Object? totalCount = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$ChapterPageDto(
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

class _CopyWithStubImpl$Fragment$ChapterPageDto<TRes>
    implements CopyWith$Fragment$ChapterPageDto<TRes> {
  _CopyWithStubImpl$Fragment$ChapterPageDto(this._res);

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

const fragmentDefinitionChapterPageDto = FragmentDefinitionNode(
  name: NameNode(value: 'ChapterPageDto'),
  typeCondition: TypeConditionNode(
      on: NamedTypeNode(
    name: NameNode(value: 'ChapterNodeList'),
    isNonNull: false,
  )),
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
);
const documentNodeFragmentChapterPageDto = DocumentNode(definitions: [
  fragmentDefinitionChapterPageDto,
  fragmentDefinitionChapterDto,
  fragmentDefinitionPageInfoDto,
]);

extension ClientExtension$Fragment$ChapterPageDto on graphql.GraphQLClient {
  void writeFragment$ChapterPageDto({
    required Fragment$ChapterPageDto data,
    required Map<String, dynamic> idFields,
    bool broadcast = true,
  }) =>
      this.writeFragment(
        graphql.FragmentRequest(
          idFields: idFields,
          fragment: const graphql.Fragment(
            fragmentName: 'ChapterPageDto',
            document: documentNodeFragmentChapterPageDto,
          ),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );

  Fragment$ChapterPageDto? readFragment$ChapterPageDto({
    required Map<String, dynamic> idFields,
    bool optimistic = true,
  }) {
    final result = this.readFragment(
      graphql.FragmentRequest(
        idFields: idFields,
        fragment: const graphql.Fragment(
          fragmentName: 'ChapterPageDto',
          document: documentNodeFragmentChapterPageDto,
        ),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Fragment$ChapterPageDto.fromJson(result);
  }
}

class Fragment$ChapterPageWithMangaDto {
  Fragment$ChapterPageWithMangaDto({
    required this.nodes,
    required this.pageInfo,
    required this.totalCount,
    this.$__typename = 'ChapterNodeList',
  });

  factory Fragment$ChapterPageWithMangaDto.fromJson(Map<String, dynamic> json) {
    final l$nodes = json['nodes'];
    final l$pageInfo = json['pageInfo'];
    final l$totalCount = json['totalCount'];
    final l$$__typename = json['__typename'];
    return Fragment$ChapterPageWithMangaDto(
      nodes: (l$nodes as List<dynamic>)
          .map((e) => Fragment$ChapterWithMangaDto.fromJson(
              (e as Map<String, dynamic>)))
          .toList(),
      pageInfo:
          Fragment$PageInfoDto.fromJson((l$pageInfo as Map<String, dynamic>)),
      totalCount: (l$totalCount as int),
      $__typename: (l$$__typename as String),
    );
  }

  final List<Fragment$ChapterWithMangaDto> nodes;

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
    if (other is! Fragment$ChapterPageWithMangaDto ||
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

extension UtilityExtension$Fragment$ChapterPageWithMangaDto
    on Fragment$ChapterPageWithMangaDto {
  CopyWith$Fragment$ChapterPageWithMangaDto<Fragment$ChapterPageWithMangaDto>
      get copyWith => CopyWith$Fragment$ChapterPageWithMangaDto(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Fragment$ChapterPageWithMangaDto<TRes> {
  factory CopyWith$Fragment$ChapterPageWithMangaDto(
    Fragment$ChapterPageWithMangaDto instance,
    TRes Function(Fragment$ChapterPageWithMangaDto) then,
  ) = _CopyWithImpl$Fragment$ChapterPageWithMangaDto;

  factory CopyWith$Fragment$ChapterPageWithMangaDto.stub(TRes res) =
      _CopyWithStubImpl$Fragment$ChapterPageWithMangaDto;

  TRes call({
    List<Fragment$ChapterWithMangaDto>? nodes,
    Fragment$PageInfoDto? pageInfo,
    int? totalCount,
    String? $__typename,
  });
  TRes nodes(
      Iterable<Fragment$ChapterWithMangaDto> Function(
              Iterable<
                  CopyWith$Fragment$ChapterWithMangaDto<
                      Fragment$ChapterWithMangaDto>>)
          _fn);
  CopyWith$Fragment$PageInfoDto<TRes> get pageInfo;
}

class _CopyWithImpl$Fragment$ChapterPageWithMangaDto<TRes>
    implements CopyWith$Fragment$ChapterPageWithMangaDto<TRes> {
  _CopyWithImpl$Fragment$ChapterPageWithMangaDto(
    this._instance,
    this._then,
  );

  final Fragment$ChapterPageWithMangaDto _instance;

  final TRes Function(Fragment$ChapterPageWithMangaDto) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? nodes = _undefined,
    Object? pageInfo = _undefined,
    Object? totalCount = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$ChapterPageWithMangaDto(
        nodes: nodes == _undefined || nodes == null
            ? _instance.nodes
            : (nodes as List<Fragment$ChapterWithMangaDto>),
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
          Iterable<Fragment$ChapterWithMangaDto> Function(
                  Iterable<
                      CopyWith$Fragment$ChapterWithMangaDto<
                          Fragment$ChapterWithMangaDto>>)
              _fn) =>
      call(
          nodes: _fn(
              _instance.nodes.map((e) => CopyWith$Fragment$ChapterWithMangaDto(
                    e,
                    (i) => i,
                  ))).toList());

  CopyWith$Fragment$PageInfoDto<TRes> get pageInfo {
    final local$pageInfo = _instance.pageInfo;
    return CopyWith$Fragment$PageInfoDto(
        local$pageInfo, (e) => call(pageInfo: e));
  }
}

class _CopyWithStubImpl$Fragment$ChapterPageWithMangaDto<TRes>
    implements CopyWith$Fragment$ChapterPageWithMangaDto<TRes> {
  _CopyWithStubImpl$Fragment$ChapterPageWithMangaDto(this._res);

  TRes _res;

  call({
    List<Fragment$ChapterWithMangaDto>? nodes,
    Fragment$PageInfoDto? pageInfo,
    int? totalCount,
    String? $__typename,
  }) =>
      _res;

  nodes(_fn) => _res;

  CopyWith$Fragment$PageInfoDto<TRes> get pageInfo =>
      CopyWith$Fragment$PageInfoDto.stub(_res);
}

const fragmentDefinitionChapterPageWithMangaDto = FragmentDefinitionNode(
  name: NameNode(value: 'ChapterPageWithMangaDto'),
  typeCondition: TypeConditionNode(
      on: NamedTypeNode(
    name: NameNode(value: 'ChapterNodeList'),
    isNonNull: false,
  )),
  directives: [],
  selectionSet: SelectionSetNode(selections: [
    FieldNode(
      name: NameNode(value: 'nodes'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: SelectionSetNode(selections: [
        FragmentSpreadNode(
          name: NameNode(value: 'ChapterWithMangaDto'),
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
);
const documentNodeFragmentChapterPageWithMangaDto = DocumentNode(definitions: [
  fragmentDefinitionChapterPageWithMangaDto,
  fragmentDefinitionChapterWithMangaDto,
  fragmentDefinitionChapterDto,
  fragmentDefinitionMangaBaseDto,
  fragmentDefinitionPageInfoDto,
]);

extension ClientExtension$Fragment$ChapterPageWithMangaDto
    on graphql.GraphQLClient {
  void writeFragment$ChapterPageWithMangaDto({
    required Fragment$ChapterPageWithMangaDto data,
    required Map<String, dynamic> idFields,
    bool broadcast = true,
  }) =>
      this.writeFragment(
        graphql.FragmentRequest(
          idFields: idFields,
          fragment: const graphql.Fragment(
            fragmentName: 'ChapterPageWithMangaDto',
            document: documentNodeFragmentChapterPageWithMangaDto,
          ),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );

  Fragment$ChapterPageWithMangaDto? readFragment$ChapterPageWithMangaDto({
    required Map<String, dynamic> idFields,
    bool optimistic = true,
  }) {
    final result = this.readFragment(
      graphql.FragmentRequest(
        idFields: idFields,
        fragment: const graphql.Fragment(
          fragmentName: 'ChapterPageWithMangaDto',
          document: documentNodeFragmentChapterPageWithMangaDto,
        ),
      ),
      optimistic: optimistic,
    );
    return result == null
        ? null
        : Fragment$ChapterPageWithMangaDto.fromJson(result);
  }
}

class Fragment$ChapterPagesDto {
  Fragment$ChapterPagesDto({
    required this.chapter,
    required this.pages,
    this.$__typename = 'FetchChapterPagesPayload',
  });

  factory Fragment$ChapterPagesDto.fromJson(Map<String, dynamic> json) {
    final l$chapter = json['chapter'];
    final l$pages = json['pages'];
    final l$$__typename = json['__typename'];
    return Fragment$ChapterPagesDto(
      chapter: Fragment$ChapterPagesDto$chapter.fromJson(
          (l$chapter as Map<String, dynamic>)),
      pages: (l$pages as List<dynamic>).map((e) => (e as String)).toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final Fragment$ChapterPagesDto$chapter chapter;

  final List<String> pages;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$chapter = chapter;
    _resultData['chapter'] = l$chapter.toJson();
    final l$pages = pages;
    _resultData['pages'] = l$pages.map((e) => e).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$chapter = chapter;
    final l$pages = pages;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$chapter,
      Object.hashAll(l$pages.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$ChapterPagesDto ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$chapter = chapter;
    final lOther$chapter = other.chapter;
    if (l$chapter != lOther$chapter) {
      return false;
    }
    final l$pages = pages;
    final lOther$pages = other.pages;
    if (l$pages.length != lOther$pages.length) {
      return false;
    }
    for (int i = 0; i < l$pages.length; i++) {
      final l$pages$entry = l$pages[i];
      final lOther$pages$entry = lOther$pages[i];
      if (l$pages$entry != lOther$pages$entry) {
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

extension UtilityExtension$Fragment$ChapterPagesDto
    on Fragment$ChapterPagesDto {
  CopyWith$Fragment$ChapterPagesDto<Fragment$ChapterPagesDto> get copyWith =>
      CopyWith$Fragment$ChapterPagesDto(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Fragment$ChapterPagesDto<TRes> {
  factory CopyWith$Fragment$ChapterPagesDto(
    Fragment$ChapterPagesDto instance,
    TRes Function(Fragment$ChapterPagesDto) then,
  ) = _CopyWithImpl$Fragment$ChapterPagesDto;

  factory CopyWith$Fragment$ChapterPagesDto.stub(TRes res) =
      _CopyWithStubImpl$Fragment$ChapterPagesDto;

  TRes call({
    Fragment$ChapterPagesDto$chapter? chapter,
    List<String>? pages,
    String? $__typename,
  });
  CopyWith$Fragment$ChapterPagesDto$chapter<TRes> get chapter;
}

class _CopyWithImpl$Fragment$ChapterPagesDto<TRes>
    implements CopyWith$Fragment$ChapterPagesDto<TRes> {
  _CopyWithImpl$Fragment$ChapterPagesDto(
    this._instance,
    this._then,
  );

  final Fragment$ChapterPagesDto _instance;

  final TRes Function(Fragment$ChapterPagesDto) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? chapter = _undefined,
    Object? pages = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$ChapterPagesDto(
        chapter: chapter == _undefined || chapter == null
            ? _instance.chapter
            : (chapter as Fragment$ChapterPagesDto$chapter),
        pages: pages == _undefined || pages == null
            ? _instance.pages
            : (pages as List<String>),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Fragment$ChapterPagesDto$chapter<TRes> get chapter {
    final local$chapter = _instance.chapter;
    return CopyWith$Fragment$ChapterPagesDto$chapter(
        local$chapter, (e) => call(chapter: e));
  }
}

class _CopyWithStubImpl$Fragment$ChapterPagesDto<TRes>
    implements CopyWith$Fragment$ChapterPagesDto<TRes> {
  _CopyWithStubImpl$Fragment$ChapterPagesDto(this._res);

  TRes _res;

  call({
    Fragment$ChapterPagesDto$chapter? chapter,
    List<String>? pages,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$ChapterPagesDto$chapter<TRes> get chapter =>
      CopyWith$Fragment$ChapterPagesDto$chapter.stub(_res);
}

const fragmentDefinitionChapterPagesDto = FragmentDefinitionNode(
  name: NameNode(value: 'ChapterPagesDto'),
  typeCondition: TypeConditionNode(
      on: NamedTypeNode(
    name: NameNode(value: 'FetchChapterPagesPayload'),
    isNonNull: false,
  )),
  directives: [],
  selectionSet: SelectionSetNode(selections: [
    FieldNode(
      name: NameNode(value: 'chapter'),
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
          name: NameNode(value: 'pageCount'),
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
      name: NameNode(value: 'pages'),
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
const documentNodeFragmentChapterPagesDto = DocumentNode(definitions: [
  fragmentDefinitionChapterPagesDto,
]);

extension ClientExtension$Fragment$ChapterPagesDto on graphql.GraphQLClient {
  void writeFragment$ChapterPagesDto({
    required Fragment$ChapterPagesDto data,
    required Map<String, dynamic> idFields,
    bool broadcast = true,
  }) =>
      this.writeFragment(
        graphql.FragmentRequest(
          idFields: idFields,
          fragment: const graphql.Fragment(
            fragmentName: 'ChapterPagesDto',
            document: documentNodeFragmentChapterPagesDto,
          ),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );

  Fragment$ChapterPagesDto? readFragment$ChapterPagesDto({
    required Map<String, dynamic> idFields,
    bool optimistic = true,
  }) {
    final result = this.readFragment(
      graphql.FragmentRequest(
        idFields: idFields,
        fragment: const graphql.Fragment(
          fragmentName: 'ChapterPagesDto',
          document: documentNodeFragmentChapterPagesDto,
        ),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Fragment$ChapterPagesDto.fromJson(result);
  }
}

class Fragment$ChapterPagesDto$chapter {
  Fragment$ChapterPagesDto$chapter({
    required this.id,
    required this.pageCount,
    this.$__typename = 'ChapterType',
  });

  factory Fragment$ChapterPagesDto$chapter.fromJson(Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$pageCount = json['pageCount'];
    final l$$__typename = json['__typename'];
    return Fragment$ChapterPagesDto$chapter(
      id: (l$id as int),
      pageCount: (l$pageCount as int),
      $__typename: (l$$__typename as String),
    );
  }

  final int id;

  final int pageCount;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$pageCount = pageCount;
    _resultData['pageCount'] = l$pageCount;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$pageCount = pageCount;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$pageCount,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$ChapterPagesDto$chapter ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$pageCount = pageCount;
    final lOther$pageCount = other.pageCount;
    if (l$pageCount != lOther$pageCount) {
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

extension UtilityExtension$Fragment$ChapterPagesDto$chapter
    on Fragment$ChapterPagesDto$chapter {
  CopyWith$Fragment$ChapterPagesDto$chapter<Fragment$ChapterPagesDto$chapter>
      get copyWith => CopyWith$Fragment$ChapterPagesDto$chapter(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Fragment$ChapterPagesDto$chapter<TRes> {
  factory CopyWith$Fragment$ChapterPagesDto$chapter(
    Fragment$ChapterPagesDto$chapter instance,
    TRes Function(Fragment$ChapterPagesDto$chapter) then,
  ) = _CopyWithImpl$Fragment$ChapterPagesDto$chapter;

  factory CopyWith$Fragment$ChapterPagesDto$chapter.stub(TRes res) =
      _CopyWithStubImpl$Fragment$ChapterPagesDto$chapter;

  TRes call({
    int? id,
    int? pageCount,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$ChapterPagesDto$chapter<TRes>
    implements CopyWith$Fragment$ChapterPagesDto$chapter<TRes> {
  _CopyWithImpl$Fragment$ChapterPagesDto$chapter(
    this._instance,
    this._then,
  );

  final Fragment$ChapterPagesDto$chapter _instance;

  final TRes Function(Fragment$ChapterPagesDto$chapter) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? pageCount = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$ChapterPagesDto$chapter(
        id: id == _undefined || id == null ? _instance.id : (id as int),
        pageCount: pageCount == _undefined || pageCount == null
            ? _instance.pageCount
            : (pageCount as int),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Fragment$ChapterPagesDto$chapter<TRes>
    implements CopyWith$Fragment$ChapterPagesDto$chapter<TRes> {
  _CopyWithStubImpl$Fragment$ChapterPagesDto$chapter(this._res);

  TRes _res;

  call({
    int? id,
    int? pageCount,
    String? $__typename,
  }) =>
      _res;
}
