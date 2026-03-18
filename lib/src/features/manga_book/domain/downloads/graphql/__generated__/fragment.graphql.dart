import '../../../../../../graphql/__generated__/schema.graphql.dart';
import 'package:gql/ast.dart';
import 'package:graphql/client.dart' as graphql;

class Fragment$DownloadDto {
  Fragment$DownloadDto({
    required this.chapter,
    required this.manga,
    required this.progress,
    required this.state,
    required this.tries,
    required this.position,
    this.$__typename = 'DownloadType',
  });

  factory Fragment$DownloadDto.fromJson(Map<String, dynamic> json) {
    final l$chapter = json['chapter'];
    final l$manga = json['manga'];
    final l$progress = json['progress'];
    final l$state = json['state'];
    final l$tries = json['tries'];
    final l$position = json['position'];
    final l$$__typename = json['__typename'];
    return Fragment$DownloadDto(
      chapter: Fragment$DownloadDto$chapter.fromJson(
          (l$chapter as Map<String, dynamic>)),
      manga: Fragment$DownloadDto$manga.fromJson(
          (l$manga as Map<String, dynamic>)),
      progress: (l$progress as num).toDouble(),
      state: fromJson$Enum$DownloadState((l$state as String)),
      tries: (l$tries as int),
      position: (l$position as int),
      $__typename: (l$$__typename as String),
    );
  }

  final Fragment$DownloadDto$chapter chapter;

  final Fragment$DownloadDto$manga manga;

  final double progress;

  final Enum$DownloadState state;

  final int tries;

  final int position;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$chapter = chapter;
    _resultData['chapter'] = l$chapter.toJson();
    final l$manga = manga;
    _resultData['manga'] = l$manga.toJson();
    final l$progress = progress;
    _resultData['progress'] = l$progress;
    final l$state = state;
    _resultData['state'] = toJson$Enum$DownloadState(l$state);
    final l$tries = tries;
    _resultData['tries'] = l$tries;
    final l$position = position;
    _resultData['position'] = l$position;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$chapter = chapter;
    final l$manga = manga;
    final l$progress = progress;
    final l$state = state;
    final l$tries = tries;
    final l$position = position;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$chapter,
      l$manga,
      l$progress,
      l$state,
      l$tries,
      l$position,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$DownloadDto || runtimeType != other.runtimeType) {
      return false;
    }
    final l$chapter = chapter;
    final lOther$chapter = other.chapter;
    if (l$chapter != lOther$chapter) {
      return false;
    }
    final l$manga = manga;
    final lOther$manga = other.manga;
    if (l$manga != lOther$manga) {
      return false;
    }
    final l$progress = progress;
    final lOther$progress = other.progress;
    if (l$progress != lOther$progress) {
      return false;
    }
    final l$state = state;
    final lOther$state = other.state;
    if (l$state != lOther$state) {
      return false;
    }
    final l$tries = tries;
    final lOther$tries = other.tries;
    if (l$tries != lOther$tries) {
      return false;
    }
    final l$position = position;
    final lOther$position = other.position;
    if (l$position != lOther$position) {
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

extension UtilityExtension$Fragment$DownloadDto on Fragment$DownloadDto {
  CopyWith$Fragment$DownloadDto<Fragment$DownloadDto> get copyWith =>
      CopyWith$Fragment$DownloadDto(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Fragment$DownloadDto<TRes> {
  factory CopyWith$Fragment$DownloadDto(
    Fragment$DownloadDto instance,
    TRes Function(Fragment$DownloadDto) then,
  ) = _CopyWithImpl$Fragment$DownloadDto;

  factory CopyWith$Fragment$DownloadDto.stub(TRes res) =
      _CopyWithStubImpl$Fragment$DownloadDto;

  TRes call({
    Fragment$DownloadDto$chapter? chapter,
    Fragment$DownloadDto$manga? manga,
    double? progress,
    Enum$DownloadState? state,
    int? tries,
    int? position,
    String? $__typename,
  });
  CopyWith$Fragment$DownloadDto$chapter<TRes> get chapter;
  CopyWith$Fragment$DownloadDto$manga<TRes> get manga;
}

class _CopyWithImpl$Fragment$DownloadDto<TRes>
    implements CopyWith$Fragment$DownloadDto<TRes> {
  _CopyWithImpl$Fragment$DownloadDto(
    this._instance,
    this._then,
  );

  final Fragment$DownloadDto _instance;

  final TRes Function(Fragment$DownloadDto) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? chapter = _undefined,
    Object? manga = _undefined,
    Object? progress = _undefined,
    Object? state = _undefined,
    Object? tries = _undefined,
    Object? position = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$DownloadDto(
        chapter: chapter == _undefined || chapter == null
            ? _instance.chapter
            : (chapter as Fragment$DownloadDto$chapter),
        manga: manga == _undefined || manga == null
            ? _instance.manga
            : (manga as Fragment$DownloadDto$manga),
        progress: progress == _undefined || progress == null
            ? _instance.progress
            : (progress as double),
        state: state == _undefined || state == null
            ? _instance.state
            : (state as Enum$DownloadState),
        tries: tries == _undefined || tries == null
            ? _instance.tries
            : (tries as int),
        position: position == _undefined || position == null
            ? _instance.position
            : (position as int),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Fragment$DownloadDto$chapter<TRes> get chapter {
    final local$chapter = _instance.chapter;
    return CopyWith$Fragment$DownloadDto$chapter(
        local$chapter, (e) => call(chapter: e));
  }

  CopyWith$Fragment$DownloadDto$manga<TRes> get manga {
    final local$manga = _instance.manga;
    return CopyWith$Fragment$DownloadDto$manga(
        local$manga, (e) => call(manga: e));
  }
}

class _CopyWithStubImpl$Fragment$DownloadDto<TRes>
    implements CopyWith$Fragment$DownloadDto<TRes> {
  _CopyWithStubImpl$Fragment$DownloadDto(this._res);

  TRes _res;

  call({
    Fragment$DownloadDto$chapter? chapter,
    Fragment$DownloadDto$manga? manga,
    double? progress,
    Enum$DownloadState? state,
    int? tries,
    int? position,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$DownloadDto$chapter<TRes> get chapter =>
      CopyWith$Fragment$DownloadDto$chapter.stub(_res);

  CopyWith$Fragment$DownloadDto$manga<TRes> get manga =>
      CopyWith$Fragment$DownloadDto$manga.stub(_res);
}

const fragmentDefinitionDownloadDto = FragmentDefinitionNode(
  name: NameNode(value: 'DownloadDto'),
  typeCondition: TypeConditionNode(
      on: NamedTypeNode(
    name: NameNode(value: 'DownloadType'),
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
          name: NameNode(value: 'name'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'sourceOrder'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'isDownloaded'),
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
          name: NameNode(value: 'title'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'downloadCount'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'thumbnailUrl'),
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
      name: NameNode(value: 'progress'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'state'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'tries'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'position'),
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
const documentNodeFragmentDownloadDto = DocumentNode(definitions: [
  fragmentDefinitionDownloadDto,
]);

extension ClientExtension$Fragment$DownloadDto on graphql.GraphQLClient {
  void writeFragment$DownloadDto({
    required Fragment$DownloadDto data,
    required Map<String, dynamic> idFields,
    bool broadcast = true,
  }) =>
      this.writeFragment(
        graphql.FragmentRequest(
          idFields: idFields,
          fragment: const graphql.Fragment(
            fragmentName: 'DownloadDto',
            document: documentNodeFragmentDownloadDto,
          ),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );

  Fragment$DownloadDto? readFragment$DownloadDto({
    required Map<String, dynamic> idFields,
    bool optimistic = true,
  }) {
    final result = this.readFragment(
      graphql.FragmentRequest(
        idFields: idFields,
        fragment: const graphql.Fragment(
          fragmentName: 'DownloadDto',
          document: documentNodeFragmentDownloadDto,
        ),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Fragment$DownloadDto.fromJson(result);
  }
}

class Fragment$DownloadDto$chapter {
  Fragment$DownloadDto$chapter({
    required this.id,
    required this.name,
    required this.sourceOrder,
    required this.isDownloaded,
    this.$__typename = 'ChapterType',
  });

  factory Fragment$DownloadDto$chapter.fromJson(Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$name = json['name'];
    final l$sourceOrder = json['sourceOrder'];
    final l$isDownloaded = json['isDownloaded'];
    final l$$__typename = json['__typename'];
    return Fragment$DownloadDto$chapter(
      id: (l$id as int),
      name: (l$name as String),
      sourceOrder: (l$sourceOrder as int),
      isDownloaded: (l$isDownloaded as bool),
      $__typename: (l$$__typename as String),
    );
  }

  final int id;

  final String name;

  final int sourceOrder;

  final bool isDownloaded;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$name = name;
    _resultData['name'] = l$name;
    final l$sourceOrder = sourceOrder;
    _resultData['sourceOrder'] = l$sourceOrder;
    final l$isDownloaded = isDownloaded;
    _resultData['isDownloaded'] = l$isDownloaded;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$name = name;
    final l$sourceOrder = sourceOrder;
    final l$isDownloaded = isDownloaded;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$name,
      l$sourceOrder,
      l$isDownloaded,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$DownloadDto$chapter ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (l$name != lOther$name) {
      return false;
    }
    final l$sourceOrder = sourceOrder;
    final lOther$sourceOrder = other.sourceOrder;
    if (l$sourceOrder != lOther$sourceOrder) {
      return false;
    }
    final l$isDownloaded = isDownloaded;
    final lOther$isDownloaded = other.isDownloaded;
    if (l$isDownloaded != lOther$isDownloaded) {
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

extension UtilityExtension$Fragment$DownloadDto$chapter
    on Fragment$DownloadDto$chapter {
  CopyWith$Fragment$DownloadDto$chapter<Fragment$DownloadDto$chapter>
      get copyWith => CopyWith$Fragment$DownloadDto$chapter(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Fragment$DownloadDto$chapter<TRes> {
  factory CopyWith$Fragment$DownloadDto$chapter(
    Fragment$DownloadDto$chapter instance,
    TRes Function(Fragment$DownloadDto$chapter) then,
  ) = _CopyWithImpl$Fragment$DownloadDto$chapter;

  factory CopyWith$Fragment$DownloadDto$chapter.stub(TRes res) =
      _CopyWithStubImpl$Fragment$DownloadDto$chapter;

  TRes call({
    int? id,
    String? name,
    int? sourceOrder,
    bool? isDownloaded,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$DownloadDto$chapter<TRes>
    implements CopyWith$Fragment$DownloadDto$chapter<TRes> {
  _CopyWithImpl$Fragment$DownloadDto$chapter(
    this._instance,
    this._then,
  );

  final Fragment$DownloadDto$chapter _instance;

  final TRes Function(Fragment$DownloadDto$chapter) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? name = _undefined,
    Object? sourceOrder = _undefined,
    Object? isDownloaded = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$DownloadDto$chapter(
        id: id == _undefined || id == null ? _instance.id : (id as int),
        name: name == _undefined || name == null
            ? _instance.name
            : (name as String),
        sourceOrder: sourceOrder == _undefined || sourceOrder == null
            ? _instance.sourceOrder
            : (sourceOrder as int),
        isDownloaded: isDownloaded == _undefined || isDownloaded == null
            ? _instance.isDownloaded
            : (isDownloaded as bool),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Fragment$DownloadDto$chapter<TRes>
    implements CopyWith$Fragment$DownloadDto$chapter<TRes> {
  _CopyWithStubImpl$Fragment$DownloadDto$chapter(this._res);

  TRes _res;

  call({
    int? id,
    String? name,
    int? sourceOrder,
    bool? isDownloaded,
    String? $__typename,
  }) =>
      _res;
}

class Fragment$DownloadDto$manga {
  Fragment$DownloadDto$manga({
    required this.id,
    required this.title,
    required this.downloadCount,
    this.thumbnailUrl,
    this.$__typename = 'MangaType',
  });

  factory Fragment$DownloadDto$manga.fromJson(Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$title = json['title'];
    final l$downloadCount = json['downloadCount'];
    final l$thumbnailUrl = json['thumbnailUrl'];
    final l$$__typename = json['__typename'];
    return Fragment$DownloadDto$manga(
      id: (l$id as int),
      title: (l$title as String),
      downloadCount: (l$downloadCount as int),
      thumbnailUrl: (l$thumbnailUrl as String?),
      $__typename: (l$$__typename as String),
    );
  }

  final int id;

  final String title;

  final int downloadCount;

  final String? thumbnailUrl;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$title = title;
    _resultData['title'] = l$title;
    final l$downloadCount = downloadCount;
    _resultData['downloadCount'] = l$downloadCount;
    final l$thumbnailUrl = thumbnailUrl;
    _resultData['thumbnailUrl'] = l$thumbnailUrl;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$title = title;
    final l$downloadCount = downloadCount;
    final l$thumbnailUrl = thumbnailUrl;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$title,
      l$downloadCount,
      l$thumbnailUrl,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$DownloadDto$manga ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$title = title;
    final lOther$title = other.title;
    if (l$title != lOther$title) {
      return false;
    }
    final l$downloadCount = downloadCount;
    final lOther$downloadCount = other.downloadCount;
    if (l$downloadCount != lOther$downloadCount) {
      return false;
    }
    final l$thumbnailUrl = thumbnailUrl;
    final lOther$thumbnailUrl = other.thumbnailUrl;
    if (l$thumbnailUrl != lOther$thumbnailUrl) {
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

extension UtilityExtension$Fragment$DownloadDto$manga
    on Fragment$DownloadDto$manga {
  CopyWith$Fragment$DownloadDto$manga<Fragment$DownloadDto$manga>
      get copyWith => CopyWith$Fragment$DownloadDto$manga(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Fragment$DownloadDto$manga<TRes> {
  factory CopyWith$Fragment$DownloadDto$manga(
    Fragment$DownloadDto$manga instance,
    TRes Function(Fragment$DownloadDto$manga) then,
  ) = _CopyWithImpl$Fragment$DownloadDto$manga;

  factory CopyWith$Fragment$DownloadDto$manga.stub(TRes res) =
      _CopyWithStubImpl$Fragment$DownloadDto$manga;

  TRes call({
    int? id,
    String? title,
    int? downloadCount,
    String? thumbnailUrl,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$DownloadDto$manga<TRes>
    implements CopyWith$Fragment$DownloadDto$manga<TRes> {
  _CopyWithImpl$Fragment$DownloadDto$manga(
    this._instance,
    this._then,
  );

  final Fragment$DownloadDto$manga _instance;

  final TRes Function(Fragment$DownloadDto$manga) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? title = _undefined,
    Object? downloadCount = _undefined,
    Object? thumbnailUrl = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$DownloadDto$manga(
        id: id == _undefined || id == null ? _instance.id : (id as int),
        title: title == _undefined || title == null
            ? _instance.title
            : (title as String),
        downloadCount: downloadCount == _undefined || downloadCount == null
            ? _instance.downloadCount
            : (downloadCount as int),
        thumbnailUrl: thumbnailUrl == _undefined
            ? _instance.thumbnailUrl
            : (thumbnailUrl as String?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Fragment$DownloadDto$manga<TRes>
    implements CopyWith$Fragment$DownloadDto$manga<TRes> {
  _CopyWithStubImpl$Fragment$DownloadDto$manga(this._res);

  TRes _res;

  call({
    int? id,
    String? title,
    int? downloadCount,
    String? thumbnailUrl,
    String? $__typename,
  }) =>
      _res;
}

class Fragment$DownloadUpdateDto {
  Fragment$DownloadUpdateDto({
    required this.type,
    required this.download,
    this.$__typename = 'DownloadUpdate',
  });

  factory Fragment$DownloadUpdateDto.fromJson(Map<String, dynamic> json) {
    final l$type = json['type'];
    final l$download = json['download'];
    final l$$__typename = json['__typename'];
    return Fragment$DownloadUpdateDto(
      type: fromJson$Enum$DownloadUpdateType((l$type as String)),
      download:
          Fragment$DownloadDto.fromJson((l$download as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Enum$DownloadUpdateType type;

  final Fragment$DownloadDto download;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$type = type;
    _resultData['type'] = toJson$Enum$DownloadUpdateType(l$type);
    final l$download = download;
    _resultData['download'] = l$download.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$type = type;
    final l$download = download;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$type,
      l$download,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$DownloadUpdateDto ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$type = type;
    final lOther$type = other.type;
    if (l$type != lOther$type) {
      return false;
    }
    final l$download = download;
    final lOther$download = other.download;
    if (l$download != lOther$download) {
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

extension UtilityExtension$Fragment$DownloadUpdateDto
    on Fragment$DownloadUpdateDto {
  CopyWith$Fragment$DownloadUpdateDto<Fragment$DownloadUpdateDto>
      get copyWith => CopyWith$Fragment$DownloadUpdateDto(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Fragment$DownloadUpdateDto<TRes> {
  factory CopyWith$Fragment$DownloadUpdateDto(
    Fragment$DownloadUpdateDto instance,
    TRes Function(Fragment$DownloadUpdateDto) then,
  ) = _CopyWithImpl$Fragment$DownloadUpdateDto;

  factory CopyWith$Fragment$DownloadUpdateDto.stub(TRes res) =
      _CopyWithStubImpl$Fragment$DownloadUpdateDto;

  TRes call({
    Enum$DownloadUpdateType? type,
    Fragment$DownloadDto? download,
    String? $__typename,
  });
  CopyWith$Fragment$DownloadDto<TRes> get download;
}

class _CopyWithImpl$Fragment$DownloadUpdateDto<TRes>
    implements CopyWith$Fragment$DownloadUpdateDto<TRes> {
  _CopyWithImpl$Fragment$DownloadUpdateDto(
    this._instance,
    this._then,
  );

  final Fragment$DownloadUpdateDto _instance;

  final TRes Function(Fragment$DownloadUpdateDto) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? type = _undefined,
    Object? download = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$DownloadUpdateDto(
        type: type == _undefined || type == null
            ? _instance.type
            : (type as Enum$DownloadUpdateType),
        download: download == _undefined || download == null
            ? _instance.download
            : (download as Fragment$DownloadDto),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Fragment$DownloadDto<TRes> get download {
    final local$download = _instance.download;
    return CopyWith$Fragment$DownloadDto(
        local$download, (e) => call(download: e));
  }
}

class _CopyWithStubImpl$Fragment$DownloadUpdateDto<TRes>
    implements CopyWith$Fragment$DownloadUpdateDto<TRes> {
  _CopyWithStubImpl$Fragment$DownloadUpdateDto(this._res);

  TRes _res;

  call({
    Enum$DownloadUpdateType? type,
    Fragment$DownloadDto? download,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$DownloadDto<TRes> get download =>
      CopyWith$Fragment$DownloadDto.stub(_res);
}

const fragmentDefinitionDownloadUpdateDto = FragmentDefinitionNode(
  name: NameNode(value: 'DownloadUpdateDto'),
  typeCondition: TypeConditionNode(
      on: NamedTypeNode(
    name: NameNode(value: 'DownloadUpdate'),
    isNonNull: false,
  )),
  directives: [],
  selectionSet: SelectionSetNode(selections: [
    FieldNode(
      name: NameNode(value: 'type'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'download'),
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
const documentNodeFragmentDownloadUpdateDto = DocumentNode(definitions: [
  fragmentDefinitionDownloadUpdateDto,
  fragmentDefinitionDownloadDto,
]);

extension ClientExtension$Fragment$DownloadUpdateDto on graphql.GraphQLClient {
  void writeFragment$DownloadUpdateDto({
    required Fragment$DownloadUpdateDto data,
    required Map<String, dynamic> idFields,
    bool broadcast = true,
  }) =>
      this.writeFragment(
        graphql.FragmentRequest(
          idFields: idFields,
          fragment: const graphql.Fragment(
            fragmentName: 'DownloadUpdateDto',
            document: documentNodeFragmentDownloadUpdateDto,
          ),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );

  Fragment$DownloadUpdateDto? readFragment$DownloadUpdateDto({
    required Map<String, dynamic> idFields,
    bool optimistic = true,
  }) {
    final result = this.readFragment(
      graphql.FragmentRequest(
        idFields: idFields,
        fragment: const graphql.Fragment(
          fragmentName: 'DownloadUpdateDto',
          document: documentNodeFragmentDownloadUpdateDto,
        ),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Fragment$DownloadUpdateDto.fromJson(result);
  }
}

class Fragment$DownloadUpdatesDto {
  Fragment$DownloadUpdatesDto({
    required this.state,
    required this.omittedUpdates,
    required this.updates,
    this.initial,
    this.$__typename = 'DownloadUpdates',
  });

  factory Fragment$DownloadUpdatesDto.fromJson(Map<String, dynamic> json) {
    final l$state = json['state'];
    final l$omittedUpdates = json['omittedUpdates'];
    final l$updates = json['updates'];
    final l$initial = json['initial'];
    final l$$__typename = json['__typename'];
    return Fragment$DownloadUpdatesDto(
      state: fromJson$Enum$DownloaderState((l$state as String)),
      omittedUpdates: (l$omittedUpdates as bool),
      updates: (l$updates as List<dynamic>)
          .map((e) =>
              Fragment$DownloadUpdateDto.fromJson((e as Map<String, dynamic>)))
          .toList(),
      initial: (l$initial as List<dynamic>?)
          ?.map(
              (e) => Fragment$DownloadDto.fromJson((e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final Enum$DownloaderState state;

  final bool omittedUpdates;

  final List<Fragment$DownloadUpdateDto> updates;

  final List<Fragment$DownloadDto>? initial;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$state = state;
    _resultData['state'] = toJson$Enum$DownloaderState(l$state);
    final l$omittedUpdates = omittedUpdates;
    _resultData['omittedUpdates'] = l$omittedUpdates;
    final l$updates = updates;
    _resultData['updates'] = l$updates.map((e) => e.toJson()).toList();
    final l$initial = initial;
    _resultData['initial'] = l$initial?.map((e) => e.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$state = state;
    final l$omittedUpdates = omittedUpdates;
    final l$updates = updates;
    final l$initial = initial;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$state,
      l$omittedUpdates,
      Object.hashAll(l$updates.map((v) => v)),
      l$initial == null ? null : Object.hashAll(l$initial.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$DownloadUpdatesDto ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$state = state;
    final lOther$state = other.state;
    if (l$state != lOther$state) {
      return false;
    }
    final l$omittedUpdates = omittedUpdates;
    final lOther$omittedUpdates = other.omittedUpdates;
    if (l$omittedUpdates != lOther$omittedUpdates) {
      return false;
    }
    final l$updates = updates;
    final lOther$updates = other.updates;
    if (l$updates.length != lOther$updates.length) {
      return false;
    }
    for (int i = 0; i < l$updates.length; i++) {
      final l$updates$entry = l$updates[i];
      final lOther$updates$entry = lOther$updates[i];
      if (l$updates$entry != lOther$updates$entry) {
        return false;
      }
    }
    final l$initial = initial;
    final lOther$initial = other.initial;
    if (l$initial != null && lOther$initial != null) {
      if (l$initial.length != lOther$initial.length) {
        return false;
      }
      for (int i = 0; i < l$initial.length; i++) {
        final l$initial$entry = l$initial[i];
        final lOther$initial$entry = lOther$initial[i];
        if (l$initial$entry != lOther$initial$entry) {
          return false;
        }
      }
    } else if (l$initial != lOther$initial) {
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

extension UtilityExtension$Fragment$DownloadUpdatesDto
    on Fragment$DownloadUpdatesDto {
  CopyWith$Fragment$DownloadUpdatesDto<Fragment$DownloadUpdatesDto>
      get copyWith => CopyWith$Fragment$DownloadUpdatesDto(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Fragment$DownloadUpdatesDto<TRes> {
  factory CopyWith$Fragment$DownloadUpdatesDto(
    Fragment$DownloadUpdatesDto instance,
    TRes Function(Fragment$DownloadUpdatesDto) then,
  ) = _CopyWithImpl$Fragment$DownloadUpdatesDto;

  factory CopyWith$Fragment$DownloadUpdatesDto.stub(TRes res) =
      _CopyWithStubImpl$Fragment$DownloadUpdatesDto;

  TRes call({
    Enum$DownloaderState? state,
    bool? omittedUpdates,
    List<Fragment$DownloadUpdateDto>? updates,
    List<Fragment$DownloadDto>? initial,
    String? $__typename,
  });
  TRes updates(
      Iterable<Fragment$DownloadUpdateDto> Function(
              Iterable<
                  CopyWith$Fragment$DownloadUpdateDto<
                      Fragment$DownloadUpdateDto>>)
          _fn);
  TRes initial(
      Iterable<Fragment$DownloadDto>? Function(
              Iterable<CopyWith$Fragment$DownloadDto<Fragment$DownloadDto>>?)
          _fn);
}

class _CopyWithImpl$Fragment$DownloadUpdatesDto<TRes>
    implements CopyWith$Fragment$DownloadUpdatesDto<TRes> {
  _CopyWithImpl$Fragment$DownloadUpdatesDto(
    this._instance,
    this._then,
  );

  final Fragment$DownloadUpdatesDto _instance;

  final TRes Function(Fragment$DownloadUpdatesDto) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? state = _undefined,
    Object? omittedUpdates = _undefined,
    Object? updates = _undefined,
    Object? initial = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$DownloadUpdatesDto(
        state: state == _undefined || state == null
            ? _instance.state
            : (state as Enum$DownloaderState),
        omittedUpdates: omittedUpdates == _undefined || omittedUpdates == null
            ? _instance.omittedUpdates
            : (omittedUpdates as bool),
        updates: updates == _undefined || updates == null
            ? _instance.updates
            : (updates as List<Fragment$DownloadUpdateDto>),
        initial: initial == _undefined
            ? _instance.initial
            : (initial as List<Fragment$DownloadDto>?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  TRes updates(
          Iterable<Fragment$DownloadUpdateDto> Function(
                  Iterable<
                      CopyWith$Fragment$DownloadUpdateDto<
                          Fragment$DownloadUpdateDto>>)
              _fn) =>
      call(
          updates: _fn(
              _instance.updates.map((e) => CopyWith$Fragment$DownloadUpdateDto(
                    e,
                    (i) => i,
                  ))).toList());

  TRes initial(
          Iterable<Fragment$DownloadDto>? Function(
                  Iterable<
                      CopyWith$Fragment$DownloadDto<Fragment$DownloadDto>>?)
              _fn) =>
      call(
          initial:
              _fn(_instance.initial?.map((e) => CopyWith$Fragment$DownloadDto(
                    e,
                    (i) => i,
                  )))?.toList());
}

class _CopyWithStubImpl$Fragment$DownloadUpdatesDto<TRes>
    implements CopyWith$Fragment$DownloadUpdatesDto<TRes> {
  _CopyWithStubImpl$Fragment$DownloadUpdatesDto(this._res);

  TRes _res;

  call({
    Enum$DownloaderState? state,
    bool? omittedUpdates,
    List<Fragment$DownloadUpdateDto>? updates,
    List<Fragment$DownloadDto>? initial,
    String? $__typename,
  }) =>
      _res;

  updates(_fn) => _res;

  initial(_fn) => _res;
}

const fragmentDefinitionDownloadUpdatesDto = FragmentDefinitionNode(
  name: NameNode(value: 'DownloadUpdatesDto'),
  typeCondition: TypeConditionNode(
      on: NamedTypeNode(
    name: NameNode(value: 'DownloadUpdates'),
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
      name: NameNode(value: 'omittedUpdates'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'updates'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: SelectionSetNode(selections: [
        FragmentSpreadNode(
          name: NameNode(value: 'DownloadUpdateDto'),
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
      name: NameNode(value: 'initial'),
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
const documentNodeFragmentDownloadUpdatesDto = DocumentNode(definitions: [
  fragmentDefinitionDownloadUpdatesDto,
  fragmentDefinitionDownloadUpdateDto,
  fragmentDefinitionDownloadDto,
]);

extension ClientExtension$Fragment$DownloadUpdatesDto on graphql.GraphQLClient {
  void writeFragment$DownloadUpdatesDto({
    required Fragment$DownloadUpdatesDto data,
    required Map<String, dynamic> idFields,
    bool broadcast = true,
  }) =>
      this.writeFragment(
        graphql.FragmentRequest(
          idFields: idFields,
          fragment: const graphql.Fragment(
            fragmentName: 'DownloadUpdatesDto',
            document: documentNodeFragmentDownloadUpdatesDto,
          ),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );

  Fragment$DownloadUpdatesDto? readFragment$DownloadUpdatesDto({
    required Map<String, dynamic> idFields,
    bool optimistic = true,
  }) {
    final result = this.readFragment(
      graphql.FragmentRequest(
        idFields: idFields,
        fragment: const graphql.Fragment(
          fragmentName: 'DownloadUpdatesDto',
          document: documentNodeFragmentDownloadUpdatesDto,
        ),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Fragment$DownloadUpdatesDto.fromJson(result);
  }
}
