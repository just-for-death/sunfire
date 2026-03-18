import '../../../manga/graphql/__generated__/fragment.graphql.dart';
import 'package:gql/ast.dart';
import 'package:graphql/client.dart' as graphql;
import 'package:catalyst/src/utils/misc/scalars.dart';

class Fragment$ChapterDto {
  Fragment$ChapterDto({
    required this.chapterNumber,
    required this.fetchedAt,
    required this.id,
    required this.isBookmarked,
    required this.isDownloaded,
    required this.isRead,
    required this.lastPageRead,
    required this.lastReadAt,
    required this.mangaId,
    required this.name,
    required this.pageCount,
    this.realUrl,
    this.scanlator,
    required this.sourceOrder,
    required this.uploadDate,
    required this.url,
    required this.meta,
    this.$__typename = 'ChapterType',
  });

  factory Fragment$ChapterDto.fromJson(Map<String, dynamic> json) {
    final l$chapterNumber = json['chapterNumber'];
    final l$fetchedAt = json['fetchedAt'];
    final l$id = json['id'];
    final l$isBookmarked = json['isBookmarked'];
    final l$isDownloaded = json['isDownloaded'];
    final l$isRead = json['isRead'];
    final l$lastPageRead = json['lastPageRead'];
    final l$lastReadAt = json['lastReadAt'];
    final l$mangaId = json['mangaId'];
    final l$name = json['name'];
    final l$pageCount = json['pageCount'];
    final l$realUrl = json['realUrl'];
    final l$scanlator = json['scanlator'];
    final l$sourceOrder = json['sourceOrder'];
    final l$uploadDate = json['uploadDate'];
    final l$url = json['url'];
    final l$meta = json['meta'];
    final l$$__typename = json['__typename'];
    return Fragment$ChapterDto(
      chapterNumber: (l$chapterNumber as num).toDouble(),
      fetchedAt: longStringFromJson(l$fetchedAt),
      id: (l$id as int),
      isBookmarked: (l$isBookmarked as bool),
      isDownloaded: (l$isDownloaded as bool),
      isRead: (l$isRead as bool),
      lastPageRead: (l$lastPageRead as int),
      lastReadAt: longStringFromJson(l$lastReadAt),
      mangaId: (l$mangaId as int),
      name: (l$name as String),
      pageCount: (l$pageCount as int),
      realUrl: (l$realUrl as String?),
      scanlator: (l$scanlator as String?),
      sourceOrder: (l$sourceOrder as int),
      uploadDate: longStringFromJson(l$uploadDate),
      url: (l$url as String),
      meta: (l$meta as List<dynamic>)
          .map((e) =>
              Fragment$ChapterDto$meta.fromJson((e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final double chapterNumber;

  final String fetchedAt;

  final int id;

  final bool isBookmarked;

  final bool isDownloaded;

  final bool isRead;

  final int lastPageRead;

  final String lastReadAt;

  final int mangaId;

  final String name;

  final int pageCount;

  final String? realUrl;

  final String? scanlator;

  final int sourceOrder;

  final String uploadDate;

  final String url;

  final List<Fragment$ChapterDto$meta> meta;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$chapterNumber = chapterNumber;
    _resultData['chapterNumber'] = l$chapterNumber;
    final l$fetchedAt = fetchedAt;
    _resultData['fetchedAt'] = longStringToJson(l$fetchedAt);
    final l$id = id;
    _resultData['id'] = l$id;
    final l$isBookmarked = isBookmarked;
    _resultData['isBookmarked'] = l$isBookmarked;
    final l$isDownloaded = isDownloaded;
    _resultData['isDownloaded'] = l$isDownloaded;
    final l$isRead = isRead;
    _resultData['isRead'] = l$isRead;
    final l$lastPageRead = lastPageRead;
    _resultData['lastPageRead'] = l$lastPageRead;
    final l$lastReadAt = lastReadAt;
    _resultData['lastReadAt'] = longStringToJson(l$lastReadAt);
    final l$mangaId = mangaId;
    _resultData['mangaId'] = l$mangaId;
    final l$name = name;
    _resultData['name'] = l$name;
    final l$pageCount = pageCount;
    _resultData['pageCount'] = l$pageCount;
    final l$realUrl = realUrl;
    _resultData['realUrl'] = l$realUrl;
    final l$scanlator = scanlator;
    _resultData['scanlator'] = l$scanlator;
    final l$sourceOrder = sourceOrder;
    _resultData['sourceOrder'] = l$sourceOrder;
    final l$uploadDate = uploadDate;
    _resultData['uploadDate'] = longStringToJson(l$uploadDate);
    final l$url = url;
    _resultData['url'] = l$url;
    final l$meta = meta;
    _resultData['meta'] = l$meta.map((e) => e.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$chapterNumber = chapterNumber;
    final l$fetchedAt = fetchedAt;
    final l$id = id;
    final l$isBookmarked = isBookmarked;
    final l$isDownloaded = isDownloaded;
    final l$isRead = isRead;
    final l$lastPageRead = lastPageRead;
    final l$lastReadAt = lastReadAt;
    final l$mangaId = mangaId;
    final l$name = name;
    final l$pageCount = pageCount;
    final l$realUrl = realUrl;
    final l$scanlator = scanlator;
    final l$sourceOrder = sourceOrder;
    final l$uploadDate = uploadDate;
    final l$url = url;
    final l$meta = meta;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$chapterNumber,
      l$fetchedAt,
      l$id,
      l$isBookmarked,
      l$isDownloaded,
      l$isRead,
      l$lastPageRead,
      l$lastReadAt,
      l$mangaId,
      l$name,
      l$pageCount,
      l$realUrl,
      l$scanlator,
      l$sourceOrder,
      l$uploadDate,
      l$url,
      Object.hashAll(l$meta.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$ChapterDto || runtimeType != other.runtimeType) {
      return false;
    }
    final l$chapterNumber = chapterNumber;
    final lOther$chapterNumber = other.chapterNumber;
    if (l$chapterNumber != lOther$chapterNumber) {
      return false;
    }
    final l$fetchedAt = fetchedAt;
    final lOther$fetchedAt = other.fetchedAt;
    if (l$fetchedAt != lOther$fetchedAt) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$isBookmarked = isBookmarked;
    final lOther$isBookmarked = other.isBookmarked;
    if (l$isBookmarked != lOther$isBookmarked) {
      return false;
    }
    final l$isDownloaded = isDownloaded;
    final lOther$isDownloaded = other.isDownloaded;
    if (l$isDownloaded != lOther$isDownloaded) {
      return false;
    }
    final l$isRead = isRead;
    final lOther$isRead = other.isRead;
    if (l$isRead != lOther$isRead) {
      return false;
    }
    final l$lastPageRead = lastPageRead;
    final lOther$lastPageRead = other.lastPageRead;
    if (l$lastPageRead != lOther$lastPageRead) {
      return false;
    }
    final l$lastReadAt = lastReadAt;
    final lOther$lastReadAt = other.lastReadAt;
    if (l$lastReadAt != lOther$lastReadAt) {
      return false;
    }
    final l$mangaId = mangaId;
    final lOther$mangaId = other.mangaId;
    if (l$mangaId != lOther$mangaId) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (l$name != lOther$name) {
      return false;
    }
    final l$pageCount = pageCount;
    final lOther$pageCount = other.pageCount;
    if (l$pageCount != lOther$pageCount) {
      return false;
    }
    final l$realUrl = realUrl;
    final lOther$realUrl = other.realUrl;
    if (l$realUrl != lOther$realUrl) {
      return false;
    }
    final l$scanlator = scanlator;
    final lOther$scanlator = other.scanlator;
    if (l$scanlator != lOther$scanlator) {
      return false;
    }
    final l$sourceOrder = sourceOrder;
    final lOther$sourceOrder = other.sourceOrder;
    if (l$sourceOrder != lOther$sourceOrder) {
      return false;
    }
    final l$uploadDate = uploadDate;
    final lOther$uploadDate = other.uploadDate;
    if (l$uploadDate != lOther$uploadDate) {
      return false;
    }
    final l$url = url;
    final lOther$url = other.url;
    if (l$url != lOther$url) {
      return false;
    }
    final l$meta = meta;
    final lOther$meta = other.meta;
    if (l$meta.length != lOther$meta.length) {
      return false;
    }
    for (int i = 0; i < l$meta.length; i++) {
      final l$meta$entry = l$meta[i];
      final lOther$meta$entry = lOther$meta[i];
      if (l$meta$entry != lOther$meta$entry) {
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

extension UtilityExtension$Fragment$ChapterDto on Fragment$ChapterDto {
  CopyWith$Fragment$ChapterDto<Fragment$ChapterDto> get copyWith =>
      CopyWith$Fragment$ChapterDto(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Fragment$ChapterDto<TRes> {
  factory CopyWith$Fragment$ChapterDto(
    Fragment$ChapterDto instance,
    TRes Function(Fragment$ChapterDto) then,
  ) = _CopyWithImpl$Fragment$ChapterDto;

  factory CopyWith$Fragment$ChapterDto.stub(TRes res) =
      _CopyWithStubImpl$Fragment$ChapterDto;

  TRes call({
    double? chapterNumber,
    String? fetchedAt,
    int? id,
    bool? isBookmarked,
    bool? isDownloaded,
    bool? isRead,
    int? lastPageRead,
    String? lastReadAt,
    int? mangaId,
    String? name,
    int? pageCount,
    String? realUrl,
    String? scanlator,
    int? sourceOrder,
    String? uploadDate,
    String? url,
    List<Fragment$ChapterDto$meta>? meta,
    String? $__typename,
  });
  TRes meta(
      Iterable<Fragment$ChapterDto$meta> Function(
              Iterable<
                  CopyWith$Fragment$ChapterDto$meta<Fragment$ChapterDto$meta>>)
          _fn);
}

class _CopyWithImpl$Fragment$ChapterDto<TRes>
    implements CopyWith$Fragment$ChapterDto<TRes> {
  _CopyWithImpl$Fragment$ChapterDto(
    this._instance,
    this._then,
  );

  final Fragment$ChapterDto _instance;

  final TRes Function(Fragment$ChapterDto) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? chapterNumber = _undefined,
    Object? fetchedAt = _undefined,
    Object? id = _undefined,
    Object? isBookmarked = _undefined,
    Object? isDownloaded = _undefined,
    Object? isRead = _undefined,
    Object? lastPageRead = _undefined,
    Object? lastReadAt = _undefined,
    Object? mangaId = _undefined,
    Object? name = _undefined,
    Object? pageCount = _undefined,
    Object? realUrl = _undefined,
    Object? scanlator = _undefined,
    Object? sourceOrder = _undefined,
    Object? uploadDate = _undefined,
    Object? url = _undefined,
    Object? meta = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$ChapterDto(
        chapterNumber: chapterNumber == _undefined || chapterNumber == null
            ? _instance.chapterNumber
            : (chapterNumber as double),
        fetchedAt: fetchedAt == _undefined || fetchedAt == null
            ? _instance.fetchedAt
            : (fetchedAt as String),
        id: id == _undefined || id == null ? _instance.id : (id as int),
        isBookmarked: isBookmarked == _undefined || isBookmarked == null
            ? _instance.isBookmarked
            : (isBookmarked as bool),
        isDownloaded: isDownloaded == _undefined || isDownloaded == null
            ? _instance.isDownloaded
            : (isDownloaded as bool),
        isRead: isRead == _undefined || isRead == null
            ? _instance.isRead
            : (isRead as bool),
        lastPageRead: lastPageRead == _undefined || lastPageRead == null
            ? _instance.lastPageRead
            : (lastPageRead as int),
        lastReadAt: lastReadAt == _undefined || lastReadAt == null
            ? _instance.lastReadAt
            : (lastReadAt as String),
        mangaId: mangaId == _undefined || mangaId == null
            ? _instance.mangaId
            : (mangaId as int),
        name: name == _undefined || name == null
            ? _instance.name
            : (name as String),
        pageCount: pageCount == _undefined || pageCount == null
            ? _instance.pageCount
            : (pageCount as int),
        realUrl:
            realUrl == _undefined ? _instance.realUrl : (realUrl as String?),
        scanlator: scanlator == _undefined
            ? _instance.scanlator
            : (scanlator as String?),
        sourceOrder: sourceOrder == _undefined || sourceOrder == null
            ? _instance.sourceOrder
            : (sourceOrder as int),
        uploadDate: uploadDate == _undefined || uploadDate == null
            ? _instance.uploadDate
            : (uploadDate as String),
        url: url == _undefined || url == null ? _instance.url : (url as String),
        meta: meta == _undefined || meta == null
            ? _instance.meta
            : (meta as List<Fragment$ChapterDto$meta>),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  TRes meta(
          Iterable<Fragment$ChapterDto$meta> Function(
                  Iterable<
                      CopyWith$Fragment$ChapterDto$meta<
                          Fragment$ChapterDto$meta>>)
              _fn) =>
      call(
          meta: _fn(_instance.meta.map((e) => CopyWith$Fragment$ChapterDto$meta(
                e,
                (i) => i,
              ))).toList());
}

class _CopyWithStubImpl$Fragment$ChapterDto<TRes>
    implements CopyWith$Fragment$ChapterDto<TRes> {
  _CopyWithStubImpl$Fragment$ChapterDto(this._res);

  TRes _res;

  call({
    double? chapterNumber,
    String? fetchedAt,
    int? id,
    bool? isBookmarked,
    bool? isDownloaded,
    bool? isRead,
    int? lastPageRead,
    String? lastReadAt,
    int? mangaId,
    String? name,
    int? pageCount,
    String? realUrl,
    String? scanlator,
    int? sourceOrder,
    String? uploadDate,
    String? url,
    List<Fragment$ChapterDto$meta>? meta,
    String? $__typename,
  }) =>
      _res;

  meta(_fn) => _res;
}

const fragmentDefinitionChapterDto = FragmentDefinitionNode(
  name: NameNode(value: 'ChapterDto'),
  typeCondition: TypeConditionNode(
      on: NamedTypeNode(
    name: NameNode(value: 'ChapterType'),
    isNonNull: false,
  )),
  directives: [],
  selectionSet: SelectionSetNode(selections: [
    FieldNode(
      name: NameNode(value: 'chapterNumber'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'fetchedAt'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'id'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'isBookmarked'),
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
      name: NameNode(value: 'isRead'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'lastPageRead'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'lastReadAt'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'mangaId'),
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
      name: NameNode(value: 'pageCount'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'realUrl'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'scanlator'),
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
      name: NameNode(value: 'uploadDate'),
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
      name: NameNode(value: 'meta'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: SelectionSetNode(selections: [
        FieldNode(
          name: NameNode(value: 'key'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'value'),
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
);
const documentNodeFragmentChapterDto = DocumentNode(definitions: [
  fragmentDefinitionChapterDto,
]);

extension ClientExtension$Fragment$ChapterDto on graphql.GraphQLClient {
  void writeFragment$ChapterDto({
    required Fragment$ChapterDto data,
    required Map<String, dynamic> idFields,
    bool broadcast = true,
  }) =>
      this.writeFragment(
        graphql.FragmentRequest(
          idFields: idFields,
          fragment: const graphql.Fragment(
            fragmentName: 'ChapterDto',
            document: documentNodeFragmentChapterDto,
          ),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );

  Fragment$ChapterDto? readFragment$ChapterDto({
    required Map<String, dynamic> idFields,
    bool optimistic = true,
  }) {
    final result = this.readFragment(
      graphql.FragmentRequest(
        idFields: idFields,
        fragment: const graphql.Fragment(
          fragmentName: 'ChapterDto',
          document: documentNodeFragmentChapterDto,
        ),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Fragment$ChapterDto.fromJson(result);
  }
}

class Fragment$ChapterDto$meta {
  Fragment$ChapterDto$meta({
    required this.key,
    required this.value,
    this.$__typename = 'ChapterMetaType',
  });

  factory Fragment$ChapterDto$meta.fromJson(Map<String, dynamic> json) {
    final l$key = json['key'];
    final l$value = json['value'];
    final l$$__typename = json['__typename'];
    return Fragment$ChapterDto$meta(
      key: (l$key as String),
      value: (l$value as String),
      $__typename: (l$$__typename as String),
    );
  }

  final String key;

  final String value;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$key = key;
    _resultData['key'] = l$key;
    final l$value = value;
    _resultData['value'] = l$value;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$key = key;
    final l$value = value;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$key,
      l$value,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$ChapterDto$meta ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$key = key;
    final lOther$key = other.key;
    if (l$key != lOther$key) {
      return false;
    }
    final l$value = value;
    final lOther$value = other.value;
    if (l$value != lOther$value) {
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

extension UtilityExtension$Fragment$ChapterDto$meta
    on Fragment$ChapterDto$meta {
  CopyWith$Fragment$ChapterDto$meta<Fragment$ChapterDto$meta> get copyWith =>
      CopyWith$Fragment$ChapterDto$meta(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Fragment$ChapterDto$meta<TRes> {
  factory CopyWith$Fragment$ChapterDto$meta(
    Fragment$ChapterDto$meta instance,
    TRes Function(Fragment$ChapterDto$meta) then,
  ) = _CopyWithImpl$Fragment$ChapterDto$meta;

  factory CopyWith$Fragment$ChapterDto$meta.stub(TRes res) =
      _CopyWithStubImpl$Fragment$ChapterDto$meta;

  TRes call({
    String? key,
    String? value,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$ChapterDto$meta<TRes>
    implements CopyWith$Fragment$ChapterDto$meta<TRes> {
  _CopyWithImpl$Fragment$ChapterDto$meta(
    this._instance,
    this._then,
  );

  final Fragment$ChapterDto$meta _instance;

  final TRes Function(Fragment$ChapterDto$meta) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? key = _undefined,
    Object? value = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$ChapterDto$meta(
        key: key == _undefined || key == null ? _instance.key : (key as String),
        value: value == _undefined || value == null
            ? _instance.value
            : (value as String),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Fragment$ChapterDto$meta<TRes>
    implements CopyWith$Fragment$ChapterDto$meta<TRes> {
  _CopyWithStubImpl$Fragment$ChapterDto$meta(this._res);

  TRes _res;

  call({
    String? key,
    String? value,
    String? $__typename,
  }) =>
      _res;
}

class Fragment$ChapterWithMangaDto implements Fragment$ChapterDto {
  Fragment$ChapterWithMangaDto({
    required this.chapterNumber,
    required this.fetchedAt,
    required this.id,
    required this.isBookmarked,
    required this.isDownloaded,
    required this.isRead,
    required this.lastPageRead,
    required this.lastReadAt,
    required this.mangaId,
    required this.name,
    required this.pageCount,
    this.realUrl,
    this.scanlator,
    required this.sourceOrder,
    required this.uploadDate,
    required this.url,
    required this.meta,
    this.$__typename = 'ChapterType',
    required this.manga,
  });

  factory Fragment$ChapterWithMangaDto.fromJson(Map<String, dynamic> json) {
    final l$chapterNumber = json['chapterNumber'];
    final l$fetchedAt = json['fetchedAt'];
    final l$id = json['id'];
    final l$isBookmarked = json['isBookmarked'];
    final l$isDownloaded = json['isDownloaded'];
    final l$isRead = json['isRead'];
    final l$lastPageRead = json['lastPageRead'];
    final l$lastReadAt = json['lastReadAt'];
    final l$mangaId = json['mangaId'];
    final l$name = json['name'];
    final l$pageCount = json['pageCount'];
    final l$realUrl = json['realUrl'];
    final l$scanlator = json['scanlator'];
    final l$sourceOrder = json['sourceOrder'];
    final l$uploadDate = json['uploadDate'];
    final l$url = json['url'];
    final l$meta = json['meta'];
    final l$$__typename = json['__typename'];
    final l$manga = json['manga'];
    return Fragment$ChapterWithMangaDto(
      chapterNumber: (l$chapterNumber as num).toDouble(),
      fetchedAt: longStringFromJson(l$fetchedAt),
      id: (l$id as int),
      isBookmarked: (l$isBookmarked as bool),
      isDownloaded: (l$isDownloaded as bool),
      isRead: (l$isRead as bool),
      lastPageRead: (l$lastPageRead as int),
      lastReadAt: longStringFromJson(l$lastReadAt),
      mangaId: (l$mangaId as int),
      name: (l$name as String),
      pageCount: (l$pageCount as int),
      realUrl: (l$realUrl as String?),
      scanlator: (l$scanlator as String?),
      sourceOrder: (l$sourceOrder as int),
      uploadDate: longStringFromJson(l$uploadDate),
      url: (l$url as String),
      meta: (l$meta as List<dynamic>)
          .map((e) => Fragment$ChapterWithMangaDto$meta.fromJson(
              (e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
      manga: Fragment$MangaBaseDto.fromJson((l$manga as Map<String, dynamic>)),
    );
  }

  final double chapterNumber;

  final String fetchedAt;

  final int id;

  final bool isBookmarked;

  final bool isDownloaded;

  final bool isRead;

  final int lastPageRead;

  final String lastReadAt;

  final int mangaId;

  final String name;

  final int pageCount;

  final String? realUrl;

  final String? scanlator;

  final int sourceOrder;

  final String uploadDate;

  final String url;

  final List<Fragment$ChapterWithMangaDto$meta> meta;

  final String $__typename;

  final Fragment$MangaBaseDto manga;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$chapterNumber = chapterNumber;
    _resultData['chapterNumber'] = l$chapterNumber;
    final l$fetchedAt = fetchedAt;
    _resultData['fetchedAt'] = longStringToJson(l$fetchedAt);
    final l$id = id;
    _resultData['id'] = l$id;
    final l$isBookmarked = isBookmarked;
    _resultData['isBookmarked'] = l$isBookmarked;
    final l$isDownloaded = isDownloaded;
    _resultData['isDownloaded'] = l$isDownloaded;
    final l$isRead = isRead;
    _resultData['isRead'] = l$isRead;
    final l$lastPageRead = lastPageRead;
    _resultData['lastPageRead'] = l$lastPageRead;
    final l$lastReadAt = lastReadAt;
    _resultData['lastReadAt'] = longStringToJson(l$lastReadAt);
    final l$mangaId = mangaId;
    _resultData['mangaId'] = l$mangaId;
    final l$name = name;
    _resultData['name'] = l$name;
    final l$pageCount = pageCount;
    _resultData['pageCount'] = l$pageCount;
    final l$realUrl = realUrl;
    _resultData['realUrl'] = l$realUrl;
    final l$scanlator = scanlator;
    _resultData['scanlator'] = l$scanlator;
    final l$sourceOrder = sourceOrder;
    _resultData['sourceOrder'] = l$sourceOrder;
    final l$uploadDate = uploadDate;
    _resultData['uploadDate'] = longStringToJson(l$uploadDate);
    final l$url = url;
    _resultData['url'] = l$url;
    final l$meta = meta;
    _resultData['meta'] = l$meta.map((e) => e.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    final l$manga = manga;
    _resultData['manga'] = l$manga.toJson();
    return _resultData;
  }

  @override
  int get hashCode {
    final l$chapterNumber = chapterNumber;
    final l$fetchedAt = fetchedAt;
    final l$id = id;
    final l$isBookmarked = isBookmarked;
    final l$isDownloaded = isDownloaded;
    final l$isRead = isRead;
    final l$lastPageRead = lastPageRead;
    final l$lastReadAt = lastReadAt;
    final l$mangaId = mangaId;
    final l$name = name;
    final l$pageCount = pageCount;
    final l$realUrl = realUrl;
    final l$scanlator = scanlator;
    final l$sourceOrder = sourceOrder;
    final l$uploadDate = uploadDate;
    final l$url = url;
    final l$meta = meta;
    final l$$__typename = $__typename;
    final l$manga = manga;
    return Object.hashAll([
      l$chapterNumber,
      l$fetchedAt,
      l$id,
      l$isBookmarked,
      l$isDownloaded,
      l$isRead,
      l$lastPageRead,
      l$lastReadAt,
      l$mangaId,
      l$name,
      l$pageCount,
      l$realUrl,
      l$scanlator,
      l$sourceOrder,
      l$uploadDate,
      l$url,
      Object.hashAll(l$meta.map((v) => v)),
      l$$__typename,
      l$manga,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$ChapterWithMangaDto ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$chapterNumber = chapterNumber;
    final lOther$chapterNumber = other.chapterNumber;
    if (l$chapterNumber != lOther$chapterNumber) {
      return false;
    }
    final l$fetchedAt = fetchedAt;
    final lOther$fetchedAt = other.fetchedAt;
    if (l$fetchedAt != lOther$fetchedAt) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$isBookmarked = isBookmarked;
    final lOther$isBookmarked = other.isBookmarked;
    if (l$isBookmarked != lOther$isBookmarked) {
      return false;
    }
    final l$isDownloaded = isDownloaded;
    final lOther$isDownloaded = other.isDownloaded;
    if (l$isDownloaded != lOther$isDownloaded) {
      return false;
    }
    final l$isRead = isRead;
    final lOther$isRead = other.isRead;
    if (l$isRead != lOther$isRead) {
      return false;
    }
    final l$lastPageRead = lastPageRead;
    final lOther$lastPageRead = other.lastPageRead;
    if (l$lastPageRead != lOther$lastPageRead) {
      return false;
    }
    final l$lastReadAt = lastReadAt;
    final lOther$lastReadAt = other.lastReadAt;
    if (l$lastReadAt != lOther$lastReadAt) {
      return false;
    }
    final l$mangaId = mangaId;
    final lOther$mangaId = other.mangaId;
    if (l$mangaId != lOther$mangaId) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (l$name != lOther$name) {
      return false;
    }
    final l$pageCount = pageCount;
    final lOther$pageCount = other.pageCount;
    if (l$pageCount != lOther$pageCount) {
      return false;
    }
    final l$realUrl = realUrl;
    final lOther$realUrl = other.realUrl;
    if (l$realUrl != lOther$realUrl) {
      return false;
    }
    final l$scanlator = scanlator;
    final lOther$scanlator = other.scanlator;
    if (l$scanlator != lOther$scanlator) {
      return false;
    }
    final l$sourceOrder = sourceOrder;
    final lOther$sourceOrder = other.sourceOrder;
    if (l$sourceOrder != lOther$sourceOrder) {
      return false;
    }
    final l$uploadDate = uploadDate;
    final lOther$uploadDate = other.uploadDate;
    if (l$uploadDate != lOther$uploadDate) {
      return false;
    }
    final l$url = url;
    final lOther$url = other.url;
    if (l$url != lOther$url) {
      return false;
    }
    final l$meta = meta;
    final lOther$meta = other.meta;
    if (l$meta.length != lOther$meta.length) {
      return false;
    }
    for (int i = 0; i < l$meta.length; i++) {
      final l$meta$entry = l$meta[i];
      final lOther$meta$entry = lOther$meta[i];
      if (l$meta$entry != lOther$meta$entry) {
        return false;
      }
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    final l$manga = manga;
    final lOther$manga = other.manga;
    if (l$manga != lOther$manga) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Fragment$ChapterWithMangaDto
    on Fragment$ChapterWithMangaDto {
  CopyWith$Fragment$ChapterWithMangaDto<Fragment$ChapterWithMangaDto>
      get copyWith => CopyWith$Fragment$ChapterWithMangaDto(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Fragment$ChapterWithMangaDto<TRes> {
  factory CopyWith$Fragment$ChapterWithMangaDto(
    Fragment$ChapterWithMangaDto instance,
    TRes Function(Fragment$ChapterWithMangaDto) then,
  ) = _CopyWithImpl$Fragment$ChapterWithMangaDto;

  factory CopyWith$Fragment$ChapterWithMangaDto.stub(TRes res) =
      _CopyWithStubImpl$Fragment$ChapterWithMangaDto;

  TRes call({
    double? chapterNumber,
    String? fetchedAt,
    int? id,
    bool? isBookmarked,
    bool? isDownloaded,
    bool? isRead,
    int? lastPageRead,
    String? lastReadAt,
    int? mangaId,
    String? name,
    int? pageCount,
    String? realUrl,
    String? scanlator,
    int? sourceOrder,
    String? uploadDate,
    String? url,
    List<Fragment$ChapterWithMangaDto$meta>? meta,
    String? $__typename,
    Fragment$MangaBaseDto? manga,
  });
  TRes meta(
      Iterable<Fragment$ChapterWithMangaDto$meta> Function(
              Iterable<
                  CopyWith$Fragment$ChapterWithMangaDto$meta<
                      Fragment$ChapterWithMangaDto$meta>>)
          _fn);
  CopyWith$Fragment$MangaBaseDto<TRes> get manga;
}

class _CopyWithImpl$Fragment$ChapterWithMangaDto<TRes>
    implements CopyWith$Fragment$ChapterWithMangaDto<TRes> {
  _CopyWithImpl$Fragment$ChapterWithMangaDto(
    this._instance,
    this._then,
  );

  final Fragment$ChapterWithMangaDto _instance;

  final TRes Function(Fragment$ChapterWithMangaDto) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? chapterNumber = _undefined,
    Object? fetchedAt = _undefined,
    Object? id = _undefined,
    Object? isBookmarked = _undefined,
    Object? isDownloaded = _undefined,
    Object? isRead = _undefined,
    Object? lastPageRead = _undefined,
    Object? lastReadAt = _undefined,
    Object? mangaId = _undefined,
    Object? name = _undefined,
    Object? pageCount = _undefined,
    Object? realUrl = _undefined,
    Object? scanlator = _undefined,
    Object? sourceOrder = _undefined,
    Object? uploadDate = _undefined,
    Object? url = _undefined,
    Object? meta = _undefined,
    Object? $__typename = _undefined,
    Object? manga = _undefined,
  }) =>
      _then(Fragment$ChapterWithMangaDto(
        chapterNumber: chapterNumber == _undefined || chapterNumber == null
            ? _instance.chapterNumber
            : (chapterNumber as double),
        fetchedAt: fetchedAt == _undefined || fetchedAt == null
            ? _instance.fetchedAt
            : (fetchedAt as String),
        id: id == _undefined || id == null ? _instance.id : (id as int),
        isBookmarked: isBookmarked == _undefined || isBookmarked == null
            ? _instance.isBookmarked
            : (isBookmarked as bool),
        isDownloaded: isDownloaded == _undefined || isDownloaded == null
            ? _instance.isDownloaded
            : (isDownloaded as bool),
        isRead: isRead == _undefined || isRead == null
            ? _instance.isRead
            : (isRead as bool),
        lastPageRead: lastPageRead == _undefined || lastPageRead == null
            ? _instance.lastPageRead
            : (lastPageRead as int),
        lastReadAt: lastReadAt == _undefined || lastReadAt == null
            ? _instance.lastReadAt
            : (lastReadAt as String),
        mangaId: mangaId == _undefined || mangaId == null
            ? _instance.mangaId
            : (mangaId as int),
        name: name == _undefined || name == null
            ? _instance.name
            : (name as String),
        pageCount: pageCount == _undefined || pageCount == null
            ? _instance.pageCount
            : (pageCount as int),
        realUrl:
            realUrl == _undefined ? _instance.realUrl : (realUrl as String?),
        scanlator: scanlator == _undefined
            ? _instance.scanlator
            : (scanlator as String?),
        sourceOrder: sourceOrder == _undefined || sourceOrder == null
            ? _instance.sourceOrder
            : (sourceOrder as int),
        uploadDate: uploadDate == _undefined || uploadDate == null
            ? _instance.uploadDate
            : (uploadDate as String),
        url: url == _undefined || url == null ? _instance.url : (url as String),
        meta: meta == _undefined || meta == null
            ? _instance.meta
            : (meta as List<Fragment$ChapterWithMangaDto$meta>),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
        manga: manga == _undefined || manga == null
            ? _instance.manga
            : (manga as Fragment$MangaBaseDto),
      ));

  TRes meta(
          Iterable<Fragment$ChapterWithMangaDto$meta> Function(
                  Iterable<
                      CopyWith$Fragment$ChapterWithMangaDto$meta<
                          Fragment$ChapterWithMangaDto$meta>>)
              _fn) =>
      call(
          meta: _fn(_instance.meta
              .map((e) => CopyWith$Fragment$ChapterWithMangaDto$meta(
                    e,
                    (i) => i,
                  ))).toList());

  CopyWith$Fragment$MangaBaseDto<TRes> get manga {
    final local$manga = _instance.manga;
    return CopyWith$Fragment$MangaBaseDto(local$manga, (e) => call(manga: e));
  }
}

class _CopyWithStubImpl$Fragment$ChapterWithMangaDto<TRes>
    implements CopyWith$Fragment$ChapterWithMangaDto<TRes> {
  _CopyWithStubImpl$Fragment$ChapterWithMangaDto(this._res);

  TRes _res;

  call({
    double? chapterNumber,
    String? fetchedAt,
    int? id,
    bool? isBookmarked,
    bool? isDownloaded,
    bool? isRead,
    int? lastPageRead,
    String? lastReadAt,
    int? mangaId,
    String? name,
    int? pageCount,
    String? realUrl,
    String? scanlator,
    int? sourceOrder,
    String? uploadDate,
    String? url,
    List<Fragment$ChapterWithMangaDto$meta>? meta,
    String? $__typename,
    Fragment$MangaBaseDto? manga,
  }) =>
      _res;

  meta(_fn) => _res;

  CopyWith$Fragment$MangaBaseDto<TRes> get manga =>
      CopyWith$Fragment$MangaBaseDto.stub(_res);
}

const fragmentDefinitionChapterWithMangaDto = FragmentDefinitionNode(
  name: NameNode(value: 'ChapterWithMangaDto'),
  typeCondition: TypeConditionNode(
      on: NamedTypeNode(
    name: NameNode(value: 'ChapterType'),
    isNonNull: false,
  )),
  directives: [],
  selectionSet: SelectionSetNode(selections: [
    FragmentSpreadNode(
      name: NameNode(value: 'ChapterDto'),
      directives: [],
    ),
    FieldNode(
      name: NameNode(value: 'manga'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: SelectionSetNode(selections: [
        FragmentSpreadNode(
          name: NameNode(value: 'MangaBaseDto'),
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
const documentNodeFragmentChapterWithMangaDto = DocumentNode(definitions: [
  fragmentDefinitionChapterWithMangaDto,
  fragmentDefinitionChapterDto,
  fragmentDefinitionMangaBaseDto,
]);

extension ClientExtension$Fragment$ChapterWithMangaDto
    on graphql.GraphQLClient {
  void writeFragment$ChapterWithMangaDto({
    required Fragment$ChapterWithMangaDto data,
    required Map<String, dynamic> idFields,
    bool broadcast = true,
  }) =>
      this.writeFragment(
        graphql.FragmentRequest(
          idFields: idFields,
          fragment: const graphql.Fragment(
            fragmentName: 'ChapterWithMangaDto',
            document: documentNodeFragmentChapterWithMangaDto,
          ),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );

  Fragment$ChapterWithMangaDto? readFragment$ChapterWithMangaDto({
    required Map<String, dynamic> idFields,
    bool optimistic = true,
  }) {
    final result = this.readFragment(
      graphql.FragmentRequest(
        idFields: idFields,
        fragment: const graphql.Fragment(
          fragmentName: 'ChapterWithMangaDto',
          document: documentNodeFragmentChapterWithMangaDto,
        ),
      ),
      optimistic: optimistic,
    );
    return result == null
        ? null
        : Fragment$ChapterWithMangaDto.fromJson(result);
  }
}

class Fragment$ChapterWithMangaDto$meta implements Fragment$ChapterDto$meta {
  Fragment$ChapterWithMangaDto$meta({
    required this.key,
    required this.value,
    this.$__typename = 'ChapterMetaType',
  });

  factory Fragment$ChapterWithMangaDto$meta.fromJson(
      Map<String, dynamic> json) {
    final l$key = json['key'];
    final l$value = json['value'];
    final l$$__typename = json['__typename'];
    return Fragment$ChapterWithMangaDto$meta(
      key: (l$key as String),
      value: (l$value as String),
      $__typename: (l$$__typename as String),
    );
  }

  final String key;

  final String value;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$key = key;
    _resultData['key'] = l$key;
    final l$value = value;
    _resultData['value'] = l$value;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$key = key;
    final l$value = value;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$key,
      l$value,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$ChapterWithMangaDto$meta ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$key = key;
    final lOther$key = other.key;
    if (l$key != lOther$key) {
      return false;
    }
    final l$value = value;
    final lOther$value = other.value;
    if (l$value != lOther$value) {
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

extension UtilityExtension$Fragment$ChapterWithMangaDto$meta
    on Fragment$ChapterWithMangaDto$meta {
  CopyWith$Fragment$ChapterWithMangaDto$meta<Fragment$ChapterWithMangaDto$meta>
      get copyWith => CopyWith$Fragment$ChapterWithMangaDto$meta(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Fragment$ChapterWithMangaDto$meta<TRes> {
  factory CopyWith$Fragment$ChapterWithMangaDto$meta(
    Fragment$ChapterWithMangaDto$meta instance,
    TRes Function(Fragment$ChapterWithMangaDto$meta) then,
  ) = _CopyWithImpl$Fragment$ChapterWithMangaDto$meta;

  factory CopyWith$Fragment$ChapterWithMangaDto$meta.stub(TRes res) =
      _CopyWithStubImpl$Fragment$ChapterWithMangaDto$meta;

  TRes call({
    String? key,
    String? value,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$ChapterWithMangaDto$meta<TRes>
    implements CopyWith$Fragment$ChapterWithMangaDto$meta<TRes> {
  _CopyWithImpl$Fragment$ChapterWithMangaDto$meta(
    this._instance,
    this._then,
  );

  final Fragment$ChapterWithMangaDto$meta _instance;

  final TRes Function(Fragment$ChapterWithMangaDto$meta) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? key = _undefined,
    Object? value = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$ChapterWithMangaDto$meta(
        key: key == _undefined || key == null ? _instance.key : (key as String),
        value: value == _undefined || value == null
            ? _instance.value
            : (value as String),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Fragment$ChapterWithMangaDto$meta<TRes>
    implements CopyWith$Fragment$ChapterWithMangaDto$meta<TRes> {
  _CopyWithStubImpl$Fragment$ChapterWithMangaDto$meta(this._res);

  TRes _res;

  call({
    String? key,
    String? value,
    String? $__typename,
  }) =>
      _res;
}
