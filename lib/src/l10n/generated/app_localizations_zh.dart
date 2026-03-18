// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get about => '关于';

  @override
  String get addCategory => '添加分类';

  @override
  String get addToLibrary => '添加到书架';

  @override
  String get advanced => '高级';

  @override
  String get allScanlators => '所有过滤器';

  @override
  String get appLanguage => '应用语言';

  @override
  String get appTheme => '应用主题';

  @override
  String get appTitle => 'Catalyst';

  @override
  String get appearance => '外观';

  @override
  String get authType => '验证方式';

  @override
  String get authTypeBasic => '基本认证';

  @override
  String get authTypeNone => '无';

  @override
  String get authentication => '认证';

  @override
  String get autoDownload => '自动下载';

  @override
  String get autoDownloadNewChapters => '下载新章节';

  @override
  String get automaticBackup => '自动备份';

  @override
  String get automaticUpdate => '自动更新';

  @override
  String get automaticallyRefreshMetadata => '自动刷新元数据';

  @override
  String get automaticallyRefreshMetadataSubtitle => '更新书架时检查新的封面和简介';

  @override
  String get backup => '备份和恢复';

  @override
  String get backupAndRestore => '备份和恢复';

  @override
  String get backupCleanup => '清理备份';

  @override
  String backupCleanupDescription(String count) {
    String _temp0 = intl.Intl.selectLogic(
      count,
      {
        '0': '从未',
        'other': '删除早于 $count 日的备份',
      },
    );
    return '$_temp0';
  }

  @override
  String get backupInterval => '备份间隔';

  @override
  String get backupLocation => '备份位置';

  @override
  String get backupLocationDescription => '服务器上保存自动备份的目录路径';

  @override
  String get backupTime => '备份时间';

  @override
  String get badges => '徽标';

  @override
  String get bookmarked => '已添加书签';

  @override
  String get browse => '浏览';

  @override
  String get buildTime => '构建时间';

  @override
  String get cacheCleared => '已清除缓存';

  @override
  String get cancel => '取消';

  @override
  String get categories => '分类';

  @override
  String get categoryUpdate => '更新分类';

  @override
  String get channel => '通道';

  @override
  String get chapterDownloadLimit => '章节下载限制';

  @override
  String get chapterDownloadLimitDesc => '限制将要下载的新章节数量。';

  @override
  String chapterNumber(double number) {
    return '第 $number 章';
  }

  @override
  String get chapterSortFetchedDate => '按添加日期';

  @override
  String get chapterSortSource => '按来源';

  @override
  String get chapterSortUploadDate => '按上传日期';

  @override
  String get checkForServerUpdates => '检查服务端更新';

  @override
  String get checkForUpdates => '检查更新';

  @override
  String get clearCache => '清除缓存';

  @override
  String get client => '客户端';

  @override
  String get clientVersion => '客户端版本';

  @override
  String get close => '关闭';

  @override
  String get cloudflareBypass => '绕过 Cloudflare';

  @override
  String get completed => '阅读过';

  @override
  String get copied => '已复制！';

  @override
  String copyMsg(String msg) {
    return '\'$msg\'已复制！';
  }

  @override
  String get createBackupDescription => '可用于还原当前书架数据';

  @override
  String get createBackupTitle => '创建备份';

  @override
  String get credentials => '认证';

  @override
  String get current => '最近阅读';

  @override
  String daysAgo(Object days) {
    return '$days 天前';
  }

  @override
  String get debugLogs => '调试日志';

  @override
  String get defaultCategory => '默认添加到此库';

  @override
  String get delete => '删除';

  @override
  String get deleteCategoryDescription => '此分类下的漫画将迁移至默认分类！';

  @override
  String get deleteCategoryTitle => '确定？';

  @override
  String get discord => 'DIscord';

  @override
  String get display => '显示';

  @override
  String get displayMode => '显示模式';

  @override
  String get displayModeDescriptiveList => '详细列表';

  @override
  String get displayModeGrid => '网格';

  @override
  String get displayModeList => '简单列表';

  @override
  String get downloadLocation => '下载位置';

  @override
  String get downloadLocationHint => '服务器上保存自动备份的目录路径';

  @override
  String get downloaded => '已下载';

  @override
  String get downloading => '正在下载';

  @override
  String get downloads => '下载';

  @override
  String get edit => '编辑';

  @override
  String get editCategory => '编辑分类';

  @override
  String get emptyCategory => '分类名不能为空';

  @override
  String get enableSocksProxy => '使用 SOCKS 代理';

  @override
  String enterProp(Object prop) {
    return '请输入 $prop';
  }

  @override
  String get error => '出错';

  @override
  String get errorBackupCreate => '创建备份出错';

  @override
  String get errorBackupRestore => '还原备份出错！';

  @override
  String get errorExtension => '所选插件不存在';

  @override
  String get errorFilePick => '未选择任何文件！';

  @override
  String errorFilePickUnknownExtension(Object extensionName) {
    return '请选择插件 $extensionName';
  }

  @override
  String errorLaunchURL(String url) {
    return '打开失败\n详细记录$url已经复制到剪贴板';
  }

  @override
  String get errorPassword => '密码不能为空';

  @override
  String get errorSomethingWentWrong => '发生错误！';

  @override
  String get errorUserName => '用户名不能为空';

  @override
  String get excludeEntryWithUnreadChapters => '忽略带有未读章节的作品的自动下载';

  @override
  String get extensionInstalled => '插件安装完成！';

  @override
  String get extensionListEmpty => '插件列表为空';

  @override
  String get extensionRepository => '扩展库';

  @override
  String get extensionRepositoryDescription => '添加可以安装扩展的存储库';

  @override
  String get extensions => '插件';

  @override
  String get failed => '更新失败';

  @override
  String get filter => '筛选';

  @override
  String get findServer => '查找';

  @override
  String get finished => '阅读过';

  @override
  String get flareSolverr => '已启用 FlareSolverr';

  @override
  String get flareSolverrRequestTimeout => 'FlareSolverr 请求超时';

  @override
  String get flareSolverrServerUrl => 'FlareSolverr 服务器网址';

  @override
  String get flareSolverrSessionName => 'FlareSolverr 会话名称';

  @override
  String get flareSolverrSessionTTL => 'FlareSolverr 会话 TTL';

  @override
  String get general => '通用';

  @override
  String get gitHub => 'GitHub';

  @override
  String get globalSearch => '全局搜索';

  @override
  String get globalUpdate => '全局更新';

  @override
  String get gqlDebugLogs => 'Graphql 调试日志';

  @override
  String get gqlDebugLogsHint => '日志里包含不安全的隐私信息';

  @override
  String get help => '帮助';

  @override
  String get hideEmptyCategory => '隐藏空分类';

  @override
  String get inLibrary => '在书架中';

  @override
  String get includeCategories => '分类';

  @override
  String get includeChapters => '章节';

  @override
  String get install => '安装';

  @override
  String get installing => '安装中';

  @override
  String get installingExtension => '正在安装';

  @override
  String get invalidPort => '无效的端口';

  @override
  String invalidProp(Object property) {
    return '无效的$property';
  }

  @override
  String get ip => 'IP地址';

  @override
  String get ipHintText => '请输入服务器绑定的IP地址';

  @override
  String get isTrueBlack => '纯黑';

  @override
  String get languages => '语言';

  @override
  String get latest => '最新';

  @override
  String get library => '书架';

  @override
  String get localSourceLocation => '本地源位置';

  @override
  String get localSourceLocationDescription => '服务器上保存本地源文件的目录路径';

  @override
  String get manga => '漫画';

  @override
  String get mangaGridSize => '网格大小';

  @override
  String get mangaMissingSources => '来源未安装';

  @override
  String get mangaSortAlphabetical => '名称';

  @override
  String get mangaSortDateAdded => '添加日期';

  @override
  String get mangaSortLastRead => '最近阅读';

  @override
  String get mangaSortLastUpdated => '最后更新';

  @override
  String get mangaSortUnread => '未阅读';

  @override
  String get mangaStatusCancelled => '已取消';

  @override
  String get mangaStatusCompleted => '已完成';

  @override
  String get mangaStatusLicensed => '已认证';

  @override
  String get mangaStatusOnHiatus => '断更';

  @override
  String get mangaStatusOngoing => '连载中';

  @override
  String get mangaStatusPublishingFinished => '完结';

  @override
  String get mangaStatusUnknown => '未知';

  @override
  String get misc => '杂项';

  @override
  String get missingExtension => '插件缺失';

  @override
  String get missingTrackers => '跟踪器缺失';

  @override
  String get more => '更多';

  @override
  String get moveToBottom => '移至底部';

  @override
  String get moveToTop => '移至顶部';

  @override
  String nChapters(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n 个章节',
      zero: '无章节',
    );
    return '$_temp0';
  }

  @override
  String nDays(String count) {
    String _temp0 = intl.Intl.selectLogic(
      count,
      {
        '01': '01 天',
        'other': '$count 天',
      },
    );
    return '$_temp0';
  }

  @override
  String nHours(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n 小时',
      one: '1 小时',
    );
    return '$_temp0';
  }

  @override
  String nMinutes(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n 分钟',
      one: '1 分钟',
    );
    return '$_temp0';
  }

  @override
  String nRepo(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n 个仓库',
      one: '1 个仓库',
    );
    return '$_temp0';
  }

  @override
  String nSeconds(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n 秒钟',
      one: '1 秒钟',
    );
    return '$_temp0';
  }

  @override
  String nSources(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n 个来源',
      one: '1 个来源',
    );
    return '$_temp0';
  }

  @override
  String nameCountDisplay(int count, String name) {
    return '$name：$count';
  }

  @override
  String get newUpdateAvailable => '有可用更新';

  @override
  String nextChapter(Object chapterTitle) {
    return '下章：$chapterTitle';
  }

  @override
  String get noCategoriesFound => '尚无任何分类。\n（提示：轻触加号按钮创建一个分类来管理你的书架）';

  @override
  String get noCategoriesFoundAlt => '尚无任何分类。\n提示：轻触加号按钮创建一个分类来管理你的书架';

  @override
  String get noCategoryMangaFound => '未找到匹配项\n提示：检查搜索或更改筛选条件';

  @override
  String get noChaptersFound => '未找到章节';

  @override
  String get noDownloads => '没有下载中的任务';

  @override
  String get noMangaFound => '未找到漫画';

  @override
  String noOfChapters(int count) {
    return '共 $count 章';
  }

  @override
  String noPropFound(Object prop) {
    return '未找到 $prop';
  }

  @override
  String get noResultFound => '未找到结果';

  @override
  String get noServerFound => '在本地网络中找不到服务器';

  @override
  String get noSourcesFound => '结果为空';

  @override
  String get noUpdatesAvailable => '正在使用最新版';

  @override
  String get noUpdatesFound => '最近没有更新';

  @override
  String get none => '无';

  @override
  String get nsfw => '在图源和插件中显示';

  @override
  String get nsfw18 => '18+';

  @override
  String get nsfwInfo => '这并不能防止非官方或可能被错误标记的插件在应用中显示 NSFW(18+) 内容';

  @override
  String numSelected(int num) {
    return '已选择 $num 章';
  }

  @override
  String get obsolete => '废弃';

  @override
  String get openFlareSolverr => '查看 FlareSolverr 以了解如何进行设置的信息';

  @override
  String get openInWeb => '在浏览器中打开';

  @override
  String get or => '或';

  @override
  String page(int number) {
    return '第 $number 页';
  }

  @override
  String get parallelSourceRequest => '并行请求图源数';

  @override
  String get password => '密码';

  @override
  String get pause => '暂停';

  @override
  String get pending => '等待中';

  @override
  String get pinchToZoom => '捏拉缩放';

  @override
  String previousChapter(Object chapterTitle) {
    return '上章：$chapterTitle';
  }

  @override
  String get queued => '排队中';

  @override
  String get quickSearch => '快速搜索';

  @override
  String get quickSearchCategory => '搜索类别 \'C\'';

  @override
  String get quickSearchCategoryManga => '在类别 \'C\' 中搜索漫画 \'M\'';

  @override
  String get quickSearchCategoryMangaChapter =>
      '在类别 \'C\' 中搜索漫画 \'M\' 的章节 \'CN\'';

  @override
  String get quickSearchContext => '搜索查询 X';

  @override
  String get quickSearchShowAllCommandTip => '提示：输入 \'?\' 查看所有指令';

  @override
  String get quickSearchSource => '搜索源 \'S\'';

  @override
  String get quickSearchSourceManga => '在 \'S\' 源中搜索漫画 \'M\'';

  @override
  String get reader => '阅读器';

  @override
  String get readerMagnifierSize => '放大大小';

  @override
  String get readerMode => '阅读模式';

  @override
  String get readerModeContinuousHorizontalLTR => '从左到右（不分页）';

  @override
  String get readerModeContinuousHorizontalRTL => '从右到左（不分页）';

  @override
  String get readerModeContinuousVertical => '从上到下（不分页）';

  @override
  String get readerModeDefaultReader => '默认';

  @override
  String get readerModeSingleHorizontalLTR => '从左到右（分页）';

  @override
  String get readerModeSingleHorizontalRTL => '从右到左（分页）';

  @override
  String get readerModeSingleVertical => '从上到下（分页）';

  @override
  String get readerModeWebtoon => '条漫';

  @override
  String get readerNavigationLayout => '点按布局';

  @override
  String get readerNavigationLayoutDefault => '默认布局';

  @override
  String get readerNavigationLayoutDisabled => '关闭';

  @override
  String get readerNavigationLayoutEdge => '边缘模式';

  @override
  String get readerNavigationLayoutInvert => '反转点按区域';

  @override
  String get readerNavigationLayoutKindlish => 'Kindle 模式';

  @override
  String get readerNavigationLayoutLShaped => 'L 样式';

  @override
  String get readerNavigationLayoutRightAndLeft => '左右样式';

  @override
  String get readerOverlay => '阅读器初始覆盖层';

  @override
  String get readerOverlaySubtitle => '打开章节时显示标题和设置';

  @override
  String get readerPadding => '填充';

  @override
  String get readerScrollAnimation => '滚动动画';

  @override
  String get readerSwipeChapterToggle => '滑动切换';

  @override
  String get readerSwipeChapterToggleDescription => '滑动切换章节';

  @override
  String get readerLastPageSwipeToggle => 'Last page swipe';

  @override
  String get readerLastPageSwipeToggleDescription =>
      'Swipe to next chapter only at last page';

  @override
  String get readerVolumeTap => '音量键';

  @override
  String get readerVolumeTapInvert => '反转音量键';

  @override
  String get readerVolumeTapSubtitle => '使用音量键操作';

  @override
  String get readerIgnoreSafeAreaToggle => 'Ignore Safe Area';

  @override
  String get readerIgnoreSafeAreaToggleDescription =>
      'Allow content to extend into notch and home indicator areas';

  @override
  String get reddit => 'Reddit';

  @override
  String get refresh => '刷新';

  @override
  String get migrate => '迁移';

  @override
  String get migrationSelectTargetSource => '选择目标来源';

  @override
  String migrationSearchInSource(Object sourceName) {
    return '在 $sourceName 中搜索';
  }

  @override
  String get migrationPreview => '迁移预览';

  @override
  String get migrationInProgress => '迁移进行中';

  @override
  String get migrationComplete => '迁移成功完成';

  @override
  String get migrationFailed => '迁移失败';

  @override
  String get migrationCancelled => '迁移已取消';

  @override
  String get migrateChapters => '迁移章节';

  @override
  String get migrateChaptersDescription => '将章节阅读状态复制到新来源';

  @override
  String get migrateCategories => '迁移类别';

  @override
  String get migrateCategoriesDescription => '将漫画类别复制到新来源';

  @override
  String get migrateDownloads => '迁移下载';

  @override
  String get migrateDownloadsDescription => '将下载的章节移动到新来源';

  @override
  String get migrateTracking => '迁移追踪';

  @override
  String get migrateTrackingDescription => '将追踪信息复制到新来源';

  @override
  String get migrationOptions => '迁移选项';

  @override
  String get migrationSettings => '迁移设置';

  @override
  String get selectTargetSource => '选择目标来源';

  @override
  String get noSourcesAvailable => '没有可迁移的来源';

  @override
  String get checkSourceConfiguration => '请检查您的来源配置';

  @override
  String get noAlternativeSources => '没有可用的替代来源';

  @override
  String get installMoreSources => '安装更多来源以启用迁移';

  @override
  String get errorLoadingSources => '加载来源时出错';

  @override
  String get errorGettingMigrationSources => '获取迁移来源失败';

  @override
  String get errorSearchingMangaInSource => '在来源中搜索漫画失败';

  @override
  String get errorFetchingSourceManga => '获取来源漫画失败';

  @override
  String get errorSourceMangaNotFound => '未找到来源漫画';

  @override
  String get errorFetchingTargetManga => '获取目标漫画失败';

  @override
  String get errorTargetMangaNotFound => '未找到目标漫画';

  @override
  String get searchManga => '搜索漫画...';

  @override
  String get searchForManga => '在目标来源中搜索漫画';

  @override
  String get enterSearchTerm => '输入搜索词以查找漫画';

  @override
  String get noResultsFound => '未找到结果';

  @override
  String get tryDifferentSearch => '尝试不同的搜索词';

  @override
  String get searchError => '搜索错误';

  @override
  String get importantNotice => '重要通知';

  @override
  String get migrationWarning => '这将永久移动您的漫画数据。此操作无法撤销。';

  @override
  String get deleteSourceWarning => '迁移后，原始漫画将从您的库中删除。';

  @override
  String get confirmMigration => '确认迁移';

  @override
  String get migrationConfirmationMessage => '您确定要迁移此漫画吗？此操作无法撤销。';

  @override
  String get startMigration => '开始迁移';

  @override
  String get preparingMigration => '正在准备迁移...';

  @override
  String get migrationCompleted => '迁移完成！';

  @override
  String get migrationSuccessMessage => '您的漫画已成功迁移到新来源。';

  @override
  String get migrationCancelledMessage => '迁移过程已取消。未进行任何更改。';

  @override
  String get cancelMigration => '取消迁移';

  @override
  String get cancelMigrationConfirmation => '您确定要取消迁移吗？此操作无法撤销。';

  @override
  String get quickPresets => '快速预设';

  @override
  String get quickMigration => '快速';

  @override
  String get fullMigration => '完整';

  @override
  String get customMigration => '自定义';

  @override
  String get deleteSourceManga => '删除来源漫画';

  @override
  String get deleteSourceMangaDescription => '迁移后从库中移除原始漫画';

  @override
  String get done => '完成';

  @override
  String get yes => '是';

  @override
  String get no => '否';

  @override
  String get from => '来自';

  @override
  String get to => '到';

  @override
  String get source => '图源';

  @override
  String get migrationDetails => '迁移详情';

  @override
  String get searchAllSources => '搜索所有来源';

  @override
  String get searchingAllSources => '正在搜索所有可用来源...';

  @override
  String get noMatchingMangaFound => '在任何来源中未找到匹配的漫画';

  @override
  String get deleteSourceAfterMigration => '迁移后删除来源漫画';

  @override
  String get reload => '刷新';

  @override
  String get remove => '删除';

  @override
  String get removeFromLibrary => '从书架中删除?';

  @override
  String get reset => '重置';

  @override
  String get restore => '恢复';

  @override
  String get restoreBackupDescription => '从备份文件中还原';

  @override
  String get restoreBackupTitle => '还原备份';

  @override
  String get restored => '完成备份恢复！';

  @override
  String get restoring => '正在还原';

  @override
  String get resume => '继续';

  @override
  String get retry => '重试';

  @override
  String get running => '运行中';

  @override
  String get save => '保存';

  @override
  String get saveAsCBZArchive => '保存为CBZ文件';

  @override
  String get scanlators => '扫描';

  @override
  String get search => '搜索';

  @override
  String get searchingForUpdates => '搜索更新中';

  @override
  String get selectInBetween => '选取区间';

  @override
  String get selectNext10 => '选取下 10 个';

  @override
  String get selectUnread => '选取未读';

  @override
  String get server => '服务器';

  @override
  String get serverBindings => '服务器绑定';

  @override
  String get serverPort => '服务器端口';

  @override
  String get serverPortHintText => '服务器端口';

  @override
  String get serverUrl => '服务器地址';

  @override
  String get serverUrlHintText => '服务器地址';

  @override
  String get serverVersion => '服务器版本';

  @override
  String get settings => '设置';

  @override
  String get skipUpdatingEntries => '忽略正在更新的条目';

  @override
  String get socksHost => 'SOCKS 主机';

  @override
  String get socksPassword => 'SOCKS 密码';

  @override
  String get socksPort => 'SOCKS 端口';

  @override
  String get socksProxy => 'SOCKS 代理';

  @override
  String get socksUserName => 'SOCKS 用户名';

  @override
  String get socksVersion => 'SOCKS 版本';

  @override
  String get sort => '排序';

  @override
  String get sourceTypeFilter => '筛选';

  @override
  String get sourceTypeLatest => '最近更新';

  @override
  String get sourceTypePopular => '常用';

  @override
  String get sources => '图源';

  @override
  String get start => '开始阅读';

  @override
  String get systemTrayIcon => '在系统托盘中显示图标';

  @override
  String get thatHaventBeenStarted => '未开始';

  @override
  String get themeModeDark => '深色模式';

  @override
  String get themeModeLight => '浅色模式';

  @override
  String get themeModeSystem => '跟随系统';

  @override
  String get today => '今天';

  @override
  String get uninstall => '卸载';

  @override
  String get uninstalling => '正在卸载';

  @override
  String get unknownAuthor => '未知作者';

  @override
  String get unknownManga => '未知漫画';

  @override
  String get unknownSource => '未知图源';

  @override
  String get unread => '未阅读';

  @override
  String get update => '更新';

  @override
  String get updateCompleted => '更新完成';

  @override
  String updateFailed(Object property) {
    return '$property 更新失败';
  }

  @override
  String get updates => '更新';

  @override
  String get updatesSummary => '更新摘要';

  @override
  String get updating => '更新中';

  @override
  String get userName => '用户名';

  @override
  String get validating => '验证';

  @override
  String versionAvailable(String app, String version) {
    return '$app 有更新可用 $version ！';
  }

  @override
  String get webUI => '在浏览器中打开';

  @override
  String get webView => 'Web View';

  @override
  String get whatsNew => '更新了什么？';

  @override
  String get withCompletedStatus => '状态已完成';

  @override
  String get withUnreadChapter => '有未读章节';

  @override
  String get yesterday => '昨天';

  @override
  String get recentlyRead => '最近阅读';

  @override
  String get history => '历史';

  @override
  String get searchHistory => '搜索历史...';

  @override
  String get noHistoryFound => '未找到阅读历史';

  @override
  String get startReadingToSeeHistory => '开始阅读漫画以查看您的历史记录';

  @override
  String get noSearchResults => '没有搜索结果';

  @override
  String get tryDifferentSearchTerm => '尝试不同的搜索词';

  @override
  String get errorOccurred => '发生错误';

  @override
  String get viewManga => '查看漫画';

  @override
  String get removeFromHistory => '从历史中移除';

  @override
  String get removeFromHistoryConfirmation => '您确定要从阅读历史中移除此章节吗？';

  @override
  String get timeoutSettings => 'Timeout Settings';

  @override
  String get serverRequestTimeout => 'Server Request Timeout';

  @override
  String get serverRequestTimeoutDescription =>
      'Time to wait for server responses (in seconds)';

  @override
  String get autoRefreshOnTimeout => 'Auto-refresh on Timeout';

  @override
  String get autoRefreshOnTimeoutDescription =>
      'Automatically retries requests that timeout';

  @override
  String get autoRefreshRetryDelay => 'Auto-refresh Retry Delay';

  @override
  String get autoRefreshRetryDelayDescription =>
      'Delay between auto retry attempts (in seconds)';

  @override
  String get trackers => 'Trackers';

  @override
  String get tracking => 'Tracking';

  @override
  String get addTracking => 'Add Tracking';

  @override
  String get trackingSearch => 'Search on tracker...';

  @override
  String get trackingStatus => 'Status';

  @override
  String get trackingScore => 'Score';

  @override
  String get trackingLastChapter => 'Last Chapter Read';

  @override
  String get trackingStartDate => 'Start Date';

  @override
  String get trackingFinishDate => 'Finish Date';

  @override
  String get trackingRemoveConfirm => 'Remove tracking?';

  @override
  String get trackingRemoveDescription =>
      'This will remove the tracking entry from Catalyst. The entry on the tracker service will not be deleted.';

  @override
  String get trackingRemoveAlsoRemote => 'Also delete from tracker service';

  @override
  String get logIn => 'Log In';

  @override
  String get logOut => 'Log Out';

  @override
  String get loggedIn => 'Logged in';

  @override
  String get notLoggedIn => 'Not logged in';

  @override
  String get noTrackingFound => 'No tracking entries yet';

  @override
  String get trackerNoResults => 'No results found on tracker';

  @override
  String get syncNow => 'Sync now';
}

/// The translations for Chinese, using the Han script (`zh_Hans`).
class AppLocalizationsZhHans extends AppLocalizationsZh {
  AppLocalizationsZhHans() : super('zh_Hans');

  @override
  String get about => '关于';

  @override
  String get addCategory => '添加分类';

  @override
  String get addToLibrary => '添加到书架';

  @override
  String get allScanlators => '所有过滤器';

  @override
  String get appLanguage => '应用语言';

  @override
  String get appTheme => '应用主题';

  @override
  String get appTitle => 'Catalyst';

  @override
  String get appearance => '外观';

  @override
  String get authType => '验证方式';

  @override
  String get authTypeBasic => '基本认证';

  @override
  String get authTypeNone => '无';

  @override
  String get backup => '备份和恢复';

  @override
  String get badges => '徽标';

  @override
  String get bookmarked => '已添加书签';

  @override
  String get browse => '浏览';

  @override
  String get buildTime => '构建时间';

  @override
  String get cacheCleared => '已清除缓存';

  @override
  String get cancel => '取消';

  @override
  String get categories => '分类';

  @override
  String get categoryUpdate => '更新分类';

  @override
  String get channel => '通道';

  @override
  String chapterNumber(double number) {
    return '第 $number 章';
  }

  @override
  String get chapterSortFetchedDate => '按添加日期';

  @override
  String get chapterSortSource => '按来源';

  @override
  String get chapterSortUploadDate => '按上传日期';

  @override
  String get checkForServerUpdates => '检查服务端更新';

  @override
  String get checkForUpdates => '检查更新';

  @override
  String get clearCache => '清除缓存';

  @override
  String get client => '客户端';

  @override
  String get clientVersion => '客户端版本';

  @override
  String get close => '关闭';

  @override
  String get completed => '阅读过';

  @override
  String copyMsg(String msg) {
    return '\'$msg\'已复制！';
  }

  @override
  String get createBackupDescription => '可用于还原当前书架数据';

  @override
  String get createBackupTitle => '创建备份';

  @override
  String get credentials => '认证';

  @override
  String get current => '最近阅读';

  @override
  String daysAgo(Object days) {
    return '$days 天前';
  }

  @override
  String get defaultCategory => '默认添加到此库';

  @override
  String get delete => '删除';

  @override
  String get deleteCategoryDescription => '此分类下的漫画将迁移至默认分类！';

  @override
  String get deleteCategoryTitle => '确定？';

  @override
  String get discord => 'DIscord';

  @override
  String get display => '显示';

  @override
  String get displayMode => '显示模式';

  @override
  String get displayModeDescriptiveList => '详细列表';

  @override
  String get displayModeGrid => '网格';

  @override
  String get displayModeList => '简单列表';

  @override
  String get downloaded => '已下载';

  @override
  String get downloads => '下载';

  @override
  String get edit => '编辑';

  @override
  String get editCategory => '编辑分类';

  @override
  String get emptyCategory => '分类名不能为空';

  @override
  String get errorExtension => '所选插件不存在';

  @override
  String get errorFilePick => '未选择任何文件！';

  @override
  String errorFilePickUnknownExtension(Object extensionName) {
    return '请选择插件 $extensionName';
  }

  @override
  String errorLaunchURL(String url) {
    return '打开失败\n详细记录$url已经复制到剪贴板';
  }

  @override
  String get errorPassword => '密码不能为空';

  @override
  String get errorSomethingWentWrong => '发生错误！';

  @override
  String get errorUserName => '用户名不能为空';

  @override
  String get extensionInstalled => '插件安装完成！';

  @override
  String get extensionListEmpty => '插件列表为空';

  @override
  String get extensions => '插件';

  @override
  String get failed => '更新失败';

  @override
  String get filter => '筛选';

  @override
  String get findServer => '查找';

  @override
  String get finished => '阅读过';

  @override
  String get general => '通用';

  @override
  String get gitHub => 'GitHub';

  @override
  String get globalSearch => '全局搜索';

  @override
  String get globalUpdate => '全局更新';

  @override
  String get help => '帮助';

  @override
  String get inLibrary => '在书架中';

  @override
  String get install => '安装';

  @override
  String get installing => '安装中';

  @override
  String get installingExtension => '正在安装';

  @override
  String get languages => '语言';

  @override
  String get latest => '最新';

  @override
  String get library => '书架';

  @override
  String get manga => '漫画';

  @override
  String get mangaGridSize => '网格大小';

  @override
  String get mangaMissingSources => '来源未安装';

  @override
  String get mangaSortAlphabetical => '名称';

  @override
  String get mangaSortDateAdded => '添加日期';

  @override
  String get mangaSortLastRead => '最近阅读';

  @override
  String get mangaSortUnread => '未阅读';

  @override
  String get mangaStatusCancelled => '已取消';

  @override
  String get mangaStatusCompleted => '已完成';

  @override
  String get mangaStatusLicensed => '已认证';

  @override
  String get mangaStatusOnHiatus => '断更';

  @override
  String get mangaStatusOngoing => '连载中';

  @override
  String get mangaStatusPublishingFinished => '完结';

  @override
  String get mangaStatusUnknown => '未知';

  @override
  String get missingExtension => '插件缺失';

  @override
  String get missingTrackers => '跟踪器缺失';

  @override
  String get more => '更多';

  @override
  String get moveToBottom => '移至底部';

  @override
  String get moveToTop => '移至顶部';

  @override
  String nameCountDisplay(int count, String name) {
    return '$name：$count';
  }

  @override
  String get newUpdateAvailable => '有可用更新';

  @override
  String get noCategoriesFound => '尚无任何分类。\n（提示：轻触加号按钮创建一个分类来管理你的书架）';

  @override
  String get noCategoriesFoundAlt => '尚无任何分类。\n提示：轻触加号按钮创建一个分类来管理你的书架';

  @override
  String get noCategoryMangaFound => '未找到匹配项\n提示：检查搜索或更改筛选条件';

  @override
  String get noChaptersFound => '未找到章节';

  @override
  String get noDownloads => '没有下载中的任务';

  @override
  String get noMangaFound => '未找到漫画';

  @override
  String noOfChapters(int count) {
    return '共 $count 章';
  }

  @override
  String get noResultFound => '未找到结果';

  @override
  String get noServerFound => '在本地网络中找不到服务器';

  @override
  String get noSourcesFound => '结果为空';

  @override
  String get noUpdatesAvailable => '正在使用最新版';

  @override
  String get noUpdatesFound => '最近没有更新';

  @override
  String get nsfw => '在图源和插件中显示';

  @override
  String get nsfw18 => '18+';

  @override
  String get nsfwInfo => '这并不能防止非官方或可能被错误标记的插件在应用中显示 NSFW(18+) 内容';

  @override
  String numSelected(int num) {
    return '已选择 $num 章';
  }

  @override
  String get obsolete => '废弃';

  @override
  String page(int number) {
    return '第 $number 页';
  }

  @override
  String get password => '密码';

  @override
  String get pause => '暂停';

  @override
  String get pending => '等待中';

  @override
  String get quickSearchCategory => '搜索类别 \'C\'';

  @override
  String get quickSearchCategoryManga => '在类别 \'C\' 中搜索漫画 \'M\'';

  @override
  String get quickSearchCategoryMangaChapter =>
      '在类别 \'C\' 中搜索漫画 \'M\' 的章节 \'CN\'';

  @override
  String get quickSearchContext => '搜索查询 X';

  @override
  String get quickSearchSource => '搜索源 \'S\'';

  @override
  String get quickSearchSourceManga => '在 \'S\' 源中搜索漫画 \'M\'';

  @override
  String get reader => '阅读器';

  @override
  String get readerMagnifierSize => '放大大小';

  @override
  String get readerMode => '阅读模式';

  @override
  String get readerModeContinuousHorizontalLTR => '从左到右（不分页）';

  @override
  String get readerModeContinuousHorizontalRTL => '从右到左（不分页）';

  @override
  String get readerModeContinuousVertical => '从上到下（不分页）';

  @override
  String get readerModeDefaultReader => '默认';

  @override
  String get readerModeSingleHorizontalLTR => '从左到右（分页）';

  @override
  String get readerModeSingleHorizontalRTL => '从右到左（分页）';

  @override
  String get readerModeSingleVertical => '从上到下（分页）';

  @override
  String get readerModeWebtoon => '条漫';

  @override
  String get readerNavigationLayout => '点按布局';

  @override
  String get readerNavigationLayoutDefault => '默认布局';

  @override
  String get readerNavigationLayoutDisabled => '关闭';

  @override
  String get readerNavigationLayoutEdge => '边缘模式';

  @override
  String get readerNavigationLayoutInvert => '反转点按区域';

  @override
  String get readerNavigationLayoutKindlish => 'Kindle 模式';

  @override
  String get readerNavigationLayoutLShaped => 'L 样式';

  @override
  String get readerNavigationLayoutRightAndLeft => '左右样式';

  @override
  String get readerPadding => '填充';

  @override
  String get readerScrollAnimation => '滚动动画';

  @override
  String get readerSwipeChapterToggle => '滑动切换';

  @override
  String get readerSwipeChapterToggleDescription => '滑动切换章节';

  @override
  String get reddit => 'Reddit';

  @override
  String get refresh => '刷新';

  @override
  String get source => '图源';

  @override
  String get reset => '重置';

  @override
  String get restoreBackupDescription => '从备份文件中还原';

  @override
  String get restoreBackupTitle => '还原备份';

  @override
  String get restored => '完成备份恢复！';

  @override
  String get restoring => '正在还原';

  @override
  String get resume => '继续';

  @override
  String get retry => '重试';

  @override
  String get running => '运行中';

  @override
  String get save => '保存';

  @override
  String get scanlators => '扫描';

  @override
  String get search => '搜索';

  @override
  String get searchingForUpdates => '搜索更新中';

  @override
  String get server => '服务器';

  @override
  String get serverPort => '服务器端口';

  @override
  String get serverPortHintText => '服务器端口';

  @override
  String get serverUrl => '服务器地址';

  @override
  String get serverUrlHintText => '服务器地址';

  @override
  String get serverVersion => '服务器版本';

  @override
  String get settings => '设置';

  @override
  String get sort => '排序';

  @override
  String get sourceTypeFilter => '筛选';

  @override
  String get sourceTypeLatest => '最近更新';

  @override
  String get sourceTypePopular => '常用';

  @override
  String get sources => '图源';

  @override
  String get start => '开始阅读';

  @override
  String get themeModeDark => '深色模式';

  @override
  String get themeModeLight => '浅色模式';

  @override
  String get themeModeSystem => '跟随系统';

  @override
  String get today => '今天';

  @override
  String get uninstall => '卸载';

  @override
  String get uninstalling => '正在卸载';

  @override
  String get unknownAuthor => '未知作者';

  @override
  String get unknownManga => '未知漫画';

  @override
  String get unknownSource => '未知图源';

  @override
  String get unread => '未阅读';

  @override
  String get update => '更新';

  @override
  String get updateCompleted => '更新完成';

  @override
  String get updates => '更新';

  @override
  String get updatesSummary => '更新摘要';

  @override
  String get updating => '更新中';

  @override
  String get userName => '用户名';

  @override
  String versionAvailable(String app, String version) {
    return '$app 有更新可用 $version ！';
  }

  @override
  String get webUI => '在浏览器中打开';

  @override
  String get webView => 'Web View';

  @override
  String get whatsNew => '更新了什么？';

  @override
  String get yesterday => '昨天';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get about => '關於';

  @override
  String get addCategory => '新增分類';

  @override
  String get addToLibrary => '新增至書架';

  @override
  String get advanced => '進階';

  @override
  String get allScanlators => '所有過濾器';

  @override
  String get appLanguage => '應用程式語言';

  @override
  String get appTheme => '應用主題';

  @override
  String get appTitle => 'Catalyst';

  @override
  String get appearance => '外觀';

  @override
  String get authType => '驗證方式';

  @override
  String get authTypeBasic => '基本驗證';

  @override
  String get authTypeNone => '無';

  @override
  String get authentication => '驗證';

  @override
  String get autoDownload => '自動下載';

  @override
  String get autoDownloadNewChapters => '下載新章節';

  @override
  String get automaticBackup => '自動備份';

  @override
  String get automaticUpdate => '自動更新';

  @override
  String get automaticallyRefreshMetadata => '自動刷新詮釋資料';

  @override
  String get automaticallyRefreshMetadataSubtitle => '更新書櫃時檢查新封面與詳細資料';

  @override
  String get backup => '備份＆還原';

  @override
  String get backupAndRestore => '備份與還原';

  @override
  String get backupCleanup => '備份清理';

  @override
  String backupCleanupDescription(String count) {
    String _temp0 = intl.Intl.selectLogic(
      count,
      {
        '0': 'Never',
        '01': '刪除 1 日以前的備份',
        'other': '刪除 $count 日以前的備份',
      },
    );
    return '$_temp0';
  }

  @override
  String get backupInterval => '備份間隔';

  @override
  String get backupLocation => '備份位置';

  @override
  String get backupLocationDescription => '伺服器上用於自動備份的儲存位置的目錄路徑';

  @override
  String get backupTime => '備份時間';

  @override
  String get badges => '徽章';

  @override
  String get bookmarked => '已新增書籤';

  @override
  String get browse => '瀏覽';

  @override
  String get buildTime => '建置時間';

  @override
  String get cacheCleared => '已清除快取';

  @override
  String get cancel => '取消';

  @override
  String get categories => '分類';

  @override
  String get categoryUpdate => '更新分類';

  @override
  String get channel => '通道';

  @override
  String get chapterDownloadLimit => '章節下載限制';

  @override
  String get chapterDownloadLimitDesc => '限制要下載的新章節的數量。';

  @override
  String chapterNumber(double number) {
    return '第 $number 章';
  }

  @override
  String get chapterSortFetchedDate => '按新增日期';

  @override
  String get chapterSortSource => '按來源';

  @override
  String get chapterSortUploadDate => '按上傳日期';

  @override
  String get checkForServerUpdates => '檢查伺服器更新';

  @override
  String get checkForUpdates => '檢查更新';

  @override
  String get clearCache => '清除快取';

  @override
  String get client => '客戶端';

  @override
  String get clientVersion => '客戶端版本';

  @override
  String get close => '關閉';

  @override
  String get cloudflareBypass => '略過 Cloudflare';

  @override
  String get completed => '已閱';

  @override
  String get copied => '已複製！';

  @override
  String copyMsg(String msg) {
    return '\'$msg\' 已複製！';
  }

  @override
  String get createBackupDescription => '以 Tachidesk 備份檔備份書架';

  @override
  String get createBackupTitle => '建立備份';

  @override
  String get credentials => '認證';

  @override
  String get current => '最近閱讀';

  @override
  String daysAgo(Object days) {
    return '$days 天前';
  }

  @override
  String get debugLogs => '除錯日誌';

  @override
  String get defaultCategory => '預設新增至此分類';

  @override
  String get delete => '移除';

  @override
  String get deleteCategoryDescription => '此分類下的漫畫將合併至預設分類！';

  @override
  String get deleteCategoryTitle => '確定？';

  @override
  String get discord => 'Discord';

  @override
  String get display => '顯示';

  @override
  String get displayMode => '顯示模式';

  @override
  String get displayModeDescriptiveList => '詳細列表';

  @override
  String get displayModeGrid => '網格';

  @override
  String get displayModeList => '列表';

  @override
  String get downloadLocation => '下載位置';

  @override
  String get downloadLocationHint => '伺服器上用於下載檔案的儲存位置的目錄路徑';

  @override
  String get downloaded => '已下載';

  @override
  String get downloading => '下載中';

  @override
  String get downloads => '下載';

  @override
  String get edit => '編輯';

  @override
  String get editCategory => '編輯分類';

  @override
  String get emptyCategory => '分類名不能為空';

  @override
  String get enableSocksProxy => '使用 SOCKS Proxy';

  @override
  String enterProp(Object prop) {
    return '輸入 $prop';
  }

  @override
  String get error => '錯誤';

  @override
  String get errorBackupCreate => '建立備份失敗';

  @override
  String get errorBackupRestore => '還原備份失敗！';

  @override
  String get errorExtension => '選擇的擴充套件不存在';

  @override
  String get errorFilePick => '未選取任何文件！';

  @override
  String errorFilePickUnknownExtension(Object extensionName) {
    return '請選擇含 $extensionName 的擴充套件';
  }

  @override
  String errorLaunchURL(String url) {
    return '開啟失敗\n已複製 \"$url\" 至剪貼簿';
  }

  @override
  String get errorPassword => '密碼不能為空';

  @override
  String get errorSomethingWentWrong => '發生錯誤！';

  @override
  String get errorUserName => '用戶名不能為空';

  @override
  String get excludeEntryWithUnreadChapters => '對於帶有未讀章節的作品忽略自動章節下載';

  @override
  String get extensionInstalled => '擴充套件安裝完成！';

  @override
  String get extensionListEmpty => '擴充套件清單為空';

  @override
  String get extensionRepository => '擴充套件儲存庫';

  @override
  String get extensionRepositoryDescription => '新增儲存庫以從中安裝擴充套件';

  @override
  String get extensions => '擴充套件';

  @override
  String get failed => '更新失敗';

  @override
  String get filter => '篩選';

  @override
  String get findServer => '搜尋';

  @override
  String get finished => '已閱';

  @override
  String get flareSolverr => '啓用FlareSolverr';

  @override
  String get flareSolverrRequestTimeout => 'FlareSolverr 請求逾時';

  @override
  String get flareSolverrServerUrl => 'FlareSolverr 伺服器 URL';

  @override
  String get flareSolverrSessionName => 'FlareSolverr 會話名稱';

  @override
  String get flareSolverrSessionTTL => 'FlareSolverr 會話 TTL';

  @override
  String get general => '一般';

  @override
  String get gitHub => 'GitHub';

  @override
  String get globalSearch => '全域搜尋';

  @override
  String get globalUpdate => '全域更新';

  @override
  String get gqlDebugLogs => 'Graphql 除錯日誌';

  @override
  String get gqlDebugLogsHint => '這包括包含使用非隱私安全資訊的日誌';

  @override
  String get help => '幫助';

  @override
  String get hideEmptyCategory => '隱藏空分類';

  @override
  String get inLibrary => '在書架中';

  @override
  String get includeCategories => '分類';

  @override
  String get includeChapters => '章節';

  @override
  String get install => '安裝';

  @override
  String get installing => '安裝中';

  @override
  String get installingExtension => '正在安裝';

  @override
  String get invalidPort => '無效的通訊埠';

  @override
  String invalidProp(Object property) {
    return '無效的 $property';
  }

  @override
  String get ip => 'IP 位址';

  @override
  String get ipHintText => '輸入伺服器綁定 IP 位址';

  @override
  String get isTrueBlack => '純黑';

  @override
  String get languages => '語言';

  @override
  String get latest => '最新';

  @override
  String get library => '書架';

  @override
  String get localSourceLocation => '本機來源位置';

  @override
  String get localSourceLocationDescription => '在伺服器上儲存本機來源檔案的目錄路徑';

  @override
  String get manga => '漫畫';

  @override
  String get mangaGridSize => '網格大小';

  @override
  String get mangaMissingSources => '漫畫來源缺失';

  @override
  String get mangaSortAlphabetical => '名稱';

  @override
  String get mangaSortDateAdded => '新增日期';

  @override
  String get mangaSortLastRead => '最近閱讀';

  @override
  String get mangaSortUnread => '未閱讀';

  @override
  String get mangaStatusCancelled => '已取消';

  @override
  String get mangaStatusCompleted => '已完成';

  @override
  String get mangaStatusLicensed => '已認證';

  @override
  String get mangaStatusOnHiatus => '斷更';

  @override
  String get mangaStatusOngoing => '連載中';

  @override
  String get mangaStatusPublishingFinished => '完結';

  @override
  String get mangaStatusUnknown => '未知';

  @override
  String get misc => '雜項';

  @override
  String get missingExtension => '遺失擴充套件';

  @override
  String get missingTrackers => '跟踪器缺失';

  @override
  String get more => '更多';

  @override
  String get moveToBottom => '移至底部';

  @override
  String get moveToTop => '移至頂部';

  @override
  String nChapters(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n 章節',
      one: '1 章節',
      zero: 'None',
    );
    return '$_temp0';
  }

  @override
  String nDays(String count) {
    String _temp0 = intl.Intl.selectLogic(
      count,
      {
        '01': '01 日',
        'other': '$count 日',
      },
    );
    return '$_temp0';
  }

  @override
  String nHours(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n 小時',
      one: '1 小時',
    );
    return '$_temp0';
  }

  @override
  String nMinutes(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n 分鐘',
      one: '1 分鐘',
    );
    return '$_temp0';
  }

  @override
  String nRepo(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n 儲存庫',
      one: '1 儲存庫',
    );
    return '$_temp0';
  }

  @override
  String nSeconds(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n 秒',
      one: '1 秒',
    );
    return '$_temp0';
  }

  @override
  String nSources(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n 來源',
      one: '1 來源',
    );
    return '$_temp0';
  }

  @override
  String nameCountDisplay(int count, String name) {
    return '$name：$count';
  }

  @override
  String get newUpdateAvailable => '有可用更新';

  @override
  String nextChapter(Object chapterTitle) {
    return '下章：$chapterTitle';
  }

  @override
  String get noCategoriesFound => '尚未有任何分類。\n（提示：輕觸加號按鍵建立一個分類以管理你的書架）';

  @override
  String get noCategoriesFoundAlt => '尚未有任何分類。\n在設定內建立一個以管理你的書架';

  @override
  String get noCategoryMangaFound => '未在此分類找到漫畫\n（提示：檢查你的搜尋及篩選器！）';

  @override
  String get noChaptersFound => '未找到章節';

  @override
  String get noDownloads => '無下載';

  @override
  String get noMangaFound => '未找到漫畫';

  @override
  String noOfChapters(int count) {
    return '共 $count 章';
  }

  @override
  String noPropFound(Object prop) {
    return '找不到 $prop';
  }

  @override
  String get noResultFound => '未找到結果';

  @override
  String get noServerFound => '未在局域網內找到伺服器';

  @override
  String get noSourcesFound => '未找到來源';

  @override
  String get noUpdatesAvailable => '正在使用最新版本';

  @override
  String get noUpdatesFound => '無可用更新';

  @override
  String get none => '無';

  @override
  String get nsfw => '在擴充套件和來源中顯示 NSFW 內容';

  @override
  String get nsfw18 => '18+';

  @override
  String get nsfwInfo => '這不能防止非官方或可能被錯誤標記的擴充套件在應用程式中顯示 NSFW(18+) 內容';

  @override
  String numSelected(int num) {
    return '已選擇 $num 章';
  }

  @override
  String get obsolete => '廢棄';

  @override
  String get openFlareSolverr => '檢查 Flaresolverr 以獲取有關如何設定的資訊';

  @override
  String get openInWeb => '在瀏覽器中開啟';

  @override
  String get or => '或';

  @override
  String page(int number) {
    return '第 $number 頁';
  }

  @override
  String get parallelSourceRequest => '並行來源請求數量';

  @override
  String get password => '密碼';

  @override
  String get pause => '暫停';

  @override
  String get pending => '等待中';

  @override
  String get pinchToZoom => '收縮以縮放';

  @override
  String previousChapter(Object chapterTitle) {
    return '上章：$chapterTitle';
  }

  @override
  String get queued => '排隊';

  @override
  String get quickSearch => '快速搜索';

  @override
  String get quickSearchCategory => '搜尋分類 \'C\'';

  @override
  String get quickSearchCategoryManga => '在分類 \'C\' 中搜尋漫畫 \'M\'';

  @override
  String get quickSearchCategoryMangaChapter =>
      '在分類 \'C\' 中搜索漫畫 \'M\' 的章節名 \'CN\'';

  @override
  String get quickSearchContext => '搜尋查詢 X （結果基於顯示中內容）';

  @override
  String get quickSearchShowAllCommandTip => '提示：輸入 \'?\' 以查看所有指令';

  @override
  String get quickSearchSource => '搜尋來源 \'S\'';

  @override
  String get quickSearchSourceManga => '在來源 \'S\' 中搜尋漫畫 \'M\'';

  @override
  String get reader => '閱讀器';

  @override
  String get readerMagnifierSize => '放大大小';

  @override
  String get readerMode => '閱讀模式';

  @override
  String get readerModeContinuousHorizontalLTR => '連續左至右';

  @override
  String get readerModeContinuousHorizontalRTL => '連續右至左';

  @override
  String get readerModeContinuousVertical => '連續上至下';

  @override
  String get readerModeDefaultReader => '預設';

  @override
  String get readerModeSingleHorizontalLTR => '分頁左至右';

  @override
  String get readerModeSingleHorizontalRTL => '分頁右至左';

  @override
  String get readerModeSingleVertical => '分頁上至下';

  @override
  String get readerModeWebtoon => '條漫';

  @override
  String get readerNavigationLayout => '手勢佈局';

  @override
  String get readerNavigationLayoutDefault => '預設';

  @override
  String get readerNavigationLayoutDisabled => '停用';

  @override
  String get readerNavigationLayoutEdge => '邊緣';

  @override
  String get readerNavigationLayoutInvert => '反轉手勢區域';

  @override
  String get readerNavigationLayoutKindlish => 'Kindle 模式';

  @override
  String get readerNavigationLayoutLShaped => 'L 形';

  @override
  String get readerNavigationLayoutRightAndLeft => '左右';

  @override
  String get readerOverlay => '閱讀器起始覆蓋層';

  @override
  String get readerOverlaySubtitle => '開啟章節時顯示標題和設定';

  @override
  String get readerPadding => '填充';

  @override
  String get readerScrollAnimation => '滑動動畫';

  @override
  String get readerSwipeChapterToggle => '滑動切換';

  @override
  String get readerSwipeChapterToggleDescription => '滑動切換章節';

  @override
  String get readerVolumeTap => '音量按鈕';

  @override
  String get readerVolumeTapInvert => '反轉音量按鈕';

  @override
  String get readerVolumeTapSubtitle => '使用音量按鈕操作';

  @override
  String get reddit => 'Reddit';

  @override
  String get refresh => '重新整理';

  @override
  String get source => '來源';

  @override
  String get reload => '重新整理';

  @override
  String get remove => '移除';

  @override
  String get removeFromLibrary => '從書架中移除？';

  @override
  String get reset => '重設';

  @override
  String get restore => '還原';

  @override
  String get restoreBackupDescription => '從 Tachidesk 備份中還原';

  @override
  String get restoreBackupTitle => '還原備份';

  @override
  String get restored => '備份還原已完成！';

  @override
  String get restoring => '正在還原';

  @override
  String get resume => '繼續';

  @override
  String get retry => '重試';

  @override
  String get running => '運作中';

  @override
  String get save => '儲存';

  @override
  String get saveAsCBZArchive => '儲存為 CBZ 壓縮檔';

  @override
  String get scanlators => '掃瞄';

  @override
  String get search => '搜尋';

  @override
  String get searchingForUpdates => '搜尋更新中';

  @override
  String get selectInBetween => '選取區間';

  @override
  String get selectNext10 => '選取下 10 個';

  @override
  String get selectUnread => '選取未讀';

  @override
  String get server => '伺服器';

  @override
  String get serverBindings => '伺服器綁定';

  @override
  String get serverPort => '伺服器埠';

  @override
  String get serverPortHintText => '伺服器埠';

  @override
  String get serverUrl => '伺服器網址';

  @override
  String get serverUrlHintText => '伺服器網址';

  @override
  String get serverVersion => '伺服器版本';

  @override
  String get settings => '設定';

  @override
  String get skipUpdatingEntries => '略過更新項';

  @override
  String get socksHost => 'SOCKS 主機';

  @override
  String get socksPassword => 'SOCKS 密碼';

  @override
  String get socksPort => 'SOCKS 通訊埠';

  @override
  String get socksProxy => 'SOCKS 代理';

  @override
  String get socksUserName => 'SOCKS 使用者名稱';

  @override
  String get socksVersion => 'SOCKS 版本';

  @override
  String get sort => '排序';

  @override
  String get sourceTypeFilter => '篩選';

  @override
  String get sourceTypeLatest => '最新';

  @override
  String get sourceTypePopular => '熱門';

  @override
  String get sources => '來源';

  @override
  String get start => '開始閱讀';

  @override
  String get systemTrayIcon => '在系統匣顯示圖示';

  @override
  String get thatHaventBeenStarted => '尚未開始';

  @override
  String get themeModeDark => '深色';

  @override
  String get themeModeLight => '亮色';

  @override
  String get themeModeSystem => '系統';

  @override
  String get today => '今天';

  @override
  String get uninstall => '解除安裝';

  @override
  String get uninstalling => '正在解除安裝';

  @override
  String get unknownAuthor => '未知作者';

  @override
  String get unknownManga => '未知漫畫';

  @override
  String get unknownSource => '未知來源';

  @override
  String get unread => '未閱讀';

  @override
  String get update => '更新';

  @override
  String get updateCompleted => '更新已完成';

  @override
  String updateFailed(Object property) {
    return '更新 $property 失敗';
  }

  @override
  String get updates => '更新';

  @override
  String get updatesSummary => '更新概要';

  @override
  String get updating => '更新中';

  @override
  String get userName => '使用者名稱';

  @override
  String get validating => '驗證';

  @override
  String versionAvailable(String app, String version) {
    return '$app 有更新可用 $version！';
  }

  @override
  String get webUI => '在瀏覽器中開啟';

  @override
  String get webView => 'Web View';

  @override
  String get whatsNew => '更新了什麼？';

  @override
  String get withCompletedStatus => '具有已完成狀態';

  @override
  String get withUnreadChapter => '具有未讀的章節';

  @override
  String get yesterday => '昨天';
}
