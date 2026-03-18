// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get about => 'حول';

  @override
  String get addCategory => 'إضافة فئة';

  @override
  String get addToLibrary => 'إضافة إلى المكتبة';

  @override
  String get advanced => 'متقدم';

  @override
  String get allScanlators => 'كل فرق الترجمة';

  @override
  String get appLanguage => 'لغة التطبيق';

  @override
  String get appTheme => 'نمط سمة التطبيق';

  @override
  String get appTitle => 'تاشيديسك سورايومي';

  @override
  String get appearance => 'المظهر';

  @override
  String get authType => 'نوع المصادقة';

  @override
  String get authTypeBasic => 'مصادقة أساسية';

  @override
  String get authTypeNone => 'بلا';

  @override
  String get authentication => 'المصادقة';

  @override
  String get autoDownload => 'التحميل التلقائي';

  @override
  String get autoDownloadNewChapters => 'تحميل الفصول الجديدة';

  @override
  String get automaticBackup => 'عمل نسخة احتياطية تلقائيا';

  @override
  String get automaticUpdate => 'التحديث التلقائي';

  @override
  String get automaticallyRefreshMetadata => 'تحديث البيانات تلقائيًا';

  @override
  String get automaticallyRefreshMetadataSubtitle =>
      'تحقق من وجود غلاف وتفاصيل للفصل جديدة عند تحديث المكتبة';

  @override
  String get backup => 'النسخ الاحتياطي و الاستعادة';

  @override
  String get backupAndRestore => 'النسخ الاحتياطي والاستعادة';

  @override
  String get backupCleanup => 'إدارة النسخ الاحتياطي';

  @override
  String backupCleanupDescription(String count) {
    String _temp0 = intl.Intl.selectLogic(
      count,
      {
        '0': 'أبدًا',
        '01': 'حذف النسخ الاحتياطية التي مر عليها يوم واحد',
        'other': 'حذف النسخ الاحتياطية التي مر عليها $count أيام',
      },
    );
    return '$_temp0';
  }

  @override
  String get backupInterval => 'فترة النسخ الاحتياطي';

  @override
  String get backupLocation => 'مكان النسخ الاحتياطي';

  @override
  String get backupLocationDescription =>
      'مسار المجلد على الخادم حيث يجب حفظ النسخ الاحتياطية التلقائية';

  @override
  String get backupTime => 'وقت النسخ الاحتياطي';

  @override
  String get badges => 'الشارات';

  @override
  String get bookmarked => 'لديها إشارات مرجعية';

  @override
  String get browse => 'تصفح';

  @override
  String get buildTime => 'تاريخ بناء الخادم';

  @override
  String get cacheCleared => 'تم تنظيف الملفات المؤقتة';

  @override
  String get cancel => 'إلغاء';

  @override
  String get categories => 'الفئات';

  @override
  String get categoryUpdate => 'تحديث الفئة';

  @override
  String get channel => 'النوع';

  @override
  String get chapterDownloadLimit => 'حد تحميل الفصول';

  @override
  String get chapterDownloadLimitDesc =>
      'ضع حدا لكمية الفصول التي سيتم تحميلها.';

  @override
  String chapterNumber(double number) {
    return 'الفصل $number';
  }

  @override
  String get chapterSortFetchedDate => 'حسب تاريخ جلبه';

  @override
  String get chapterSortSource => 'حسب المصدر';

  @override
  String get chapterSortUploadDate => 'حسب تاريخ الإضافة';

  @override
  String get checkForServerUpdates => 'تحقق من وجود تحديثات الخادم';

  @override
  String get checkForUpdates => 'تحقق من وجود تحديثات';

  @override
  String get clearCache => 'تنظيف الملفات المؤقتة';

  @override
  String get client => 'الوكيل';

  @override
  String get clientVersion => 'إصدار الوكيل';

  @override
  String get close => 'إغلاق';

  @override
  String get cloudflareBypass => 'تجاوز خدمة Cloudflare';

  @override
  String get completed => 'مكتملة';

  @override
  String get copied => 'تم النسخ!';

  @override
  String copyMsg(String msg) {
    return '\'$msg\' تم نسخ!';
  }

  @override
  String get createBackupDescription => 'النسخ الاحتياطي لمكتبة Tachidesk';

  @override
  String get createBackupTitle => 'إنشاء نسخة احتياطية';

  @override
  String get credentials => 'الشهادات';

  @override
  String get current => 'الحالي';

  @override
  String daysAgo(Object days) {
    return 'منذ $days أيام';
  }

  @override
  String get debugLogs => 'سجلات التصحيح';

  @override
  String get defaultCategory =>
      'الفئة الافتراضية عند إضافة مانجا جديدة إلى المكتبة';

  @override
  String get delete => 'حذف';

  @override
  String get deleteCategoryDescription =>
      'سيؤدي إلى دمج جميع المانجا في هذه الفئة إلى الافتراضية!';

  @override
  String get deleteCategoryTitle => 'هل أنت متأكد؟';

  @override
  String get discord => 'ديسكورد';

  @override
  String get display => 'العرض';

  @override
  String get displayMode => 'وضع العرض';

  @override
  String get displayModeDescriptiveList => 'قائمة وصفية';

  @override
  String get displayModeGrid => 'شبكة مدمجة';

  @override
  String get displayModeList => 'قائمة';

  @override
  String get downloadLocation => 'موقع التحميل';

  @override
  String get downloadLocationHint =>
      'مسار المجلد على الخادم حيث يجب حفظ الملفات المحملة';

  @override
  String get downloaded => 'منزلة';

  @override
  String get downloading => 'جاري التحميل';

  @override
  String get downloads => 'التنزيلات';

  @override
  String get edit => 'تعديل';

  @override
  String get editCategory => 'تعديل الفئة';

  @override
  String get emptyCategory => 'لا يمكن أن يكون اسم الفئة فارغًا';

  @override
  String get enableSocksProxy => 'استخدام بروكسي SOCKS';

  @override
  String enterProp(Object prop) {
    return 'أدخل $prop';
  }

  @override
  String get error => 'خطأ';

  @override
  String get errorBackupCreate => 'فشل في إنشاء النسخ الاحتياطي';

  @override
  String get errorBackupRestore => 'فشل في استعادة النسخة الاحتياطية!';

  @override
  String get errorExtension => 'تعذر العثور على الإضافة المحددة';

  @override
  String get errorFilePick => 'لم يتم اختيار الملف!';

  @override
  String errorFilePickUnknownExtension(Object extensionName) {
    return 'الرجاء تحديد ملف بالامتداد $extensionName';
  }

  @override
  String errorLaunchURL(String url) {
    return 'فشل في الفتح!\nنسخ \"$url\" الى الحافظة';
  }

  @override
  String get errorPassword => 'كلمة السر فارغة';

  @override
  String get errorSomethingWentWrong => 'هناك خطأ ما!';

  @override
  String get errorUserName => 'اسم المستخدم فارغ';

  @override
  String get excludeEntryWithUnreadChapters =>
      'تجاهل التحميل التلقائي للتنزيلات التي تحتوي على فصول غير مقروءة';

  @override
  String get extensionInstalled => 'تم تحميل الإضافة!';

  @override
  String get extensionListEmpty => 'قائمة الإضافات فارغة';

  @override
  String get extensionRepository => 'مستودع الإضافات';

  @override
  String get extensionRepositoryDescription =>
      'أضف المستودعات التي يمكن تثبيت الإضافات منها';

  @override
  String get extensions => 'الإضافات';

  @override
  String get failed => 'فشل';

  @override
  String get filter => 'فرز';

  @override
  String get findServer => 'ابحث';

  @override
  String get finished => 'النهاية';

  @override
  String get flareSolverr => 'فلير سولفر';

  @override
  String get flareSolverrRequestTimeout => 'انتهاء مهلة طلب FlareSolverr';

  @override
  String get flareSolverrServerUrl => 'FlareSolverr Server Url';

  @override
  String get flareSolverrSessionName => 'FlareSolverr session name';

  @override
  String get flareSolverrSessionTTL => 'FlareSolverr session TTL';

  @override
  String get general => 'عام';

  @override
  String get gitHub => 'GitHub';

  @override
  String get globalSearch => 'البحث العام';

  @override
  String get globalUpdate => 'تحديث الكل';

  @override
  String get gqlDebugLogs => 'Graphql debug logs';

  @override
  String get gqlDebugLogsHint =>
      'This includes logs with non privacy safe information';

  @override
  String get help => 'مساعدة';

  @override
  String get hideEmptyCategory => 'Hide Empty Category';

  @override
  String get inLibrary => 'في المكتبة';

  @override
  String get includeCategories => 'Categories';

  @override
  String get includeChapters => 'الفصول';

  @override
  String get install => 'تحميل';

  @override
  String get installing => 'جار التحميل';

  @override
  String get installingExtension => 'جاري تحميل الاضافة';

  @override
  String get invalidPort => 'Invalid Port';

  @override
  String invalidProp(Object property) {
    return 'Invalid $property';
  }

  @override
  String get ip => 'IP Address';

  @override
  String get ipHintText => 'Enter server binding IP address';

  @override
  String get isTrueBlack => 'أسود حقيقي';

  @override
  String get languages => 'اللغات';

  @override
  String get latest => 'الأخير';

  @override
  String get library => 'المكتبة';

  @override
  String get localSourceLocation => 'Local source location';

  @override
  String get localSourceLocationDescription =>
      'The path to the directory on the server where local source files are saved in';

  @override
  String get manga => 'مانجا';

  @override
  String get mangaGridSize => 'حجم شبكة المانجا';

  @override
  String get mangaMissingSources => 'مصادر المانجا المفقودة';

  @override
  String get mangaSortAlphabetical => 'أبجدي';

  @override
  String get mangaSortDateAdded => 'تاريخ الإضافة';

  @override
  String get mangaSortLastRead => 'آخر قراءة';

  @override
  String get mangaSortLastUpdated => 'Last Updated';

  @override
  String get mangaSortUnread => 'غير مقروء';

  @override
  String get mangaStatusCancelled => 'ألغيت';

  @override
  String get mangaStatusCompleted => 'مكتملة';

  @override
  String get mangaStatusLicensed => 'مرخصة';

  @override
  String get mangaStatusOnHiatus => 'في فترة توقف';

  @override
  String get mangaStatusOngoing => 'مستمرة';

  @override
  String get mangaStatusPublishingFinished => 'انتهى النشر';

  @override
  String get mangaStatusUnknown => 'غير معروف';

  @override
  String get misc => 'Misc';

  @override
  String get missingExtension => 'إضافات مفقودة';

  @override
  String get missingTrackers => 'التتبعات مفقودة';

  @override
  String get more => 'أكثر';

  @override
  String get moveToBottom => 'الانتقال إلى أسفل';

  @override
  String get moveToTop => 'الانتقال إلى الأعلى';

  @override
  String nChapters(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Chapters',
      one: '1 Chapter',
      zero: 'None',
    );
    return '$_temp0';
  }

  @override
  String nDays(String count) {
    String _temp0 = intl.Intl.selectLogic(
      count,
      {
        '01': '01 Day',
        'other': '$count Days',
      },
    );
    return '$_temp0';
  }

  @override
  String nHours(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n hours',
      one: '1 hour',
    );
    return '$_temp0';
  }

  @override
  String nMinutes(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Minutes',
      one: '1 Minute',
    );
    return '$_temp0';
  }

  @override
  String nRepo(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Repos',
      one: '1 Repo',
    );
    return '$_temp0';
  }

  @override
  String nSeconds(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n seconds',
      one: '1 second',
    );
    return '$_temp0';
  }

  @override
  String nSources(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Sources',
      one: '1 Source',
    );
    return '$_temp0';
  }

  @override
  String nameCountDisplay(int count, String name) {
    return '$name: $count';
  }

  @override
  String get newUpdateAvailable => 'تحديث جديد متاح';

  @override
  String nextChapter(Object chapterTitle) {
    return 'التالي: $chapterTitle';
  }

  @override
  String get noCategoriesFound =>
      'ليس لديك أي فئات. \n(نصيحة: اضغط على زر علامة الزائد لإنشاء فئة لتنظيم مكتبتك)';

  @override
  String get noCategoriesFoundAlt =>
      'ليس لديك أي فئات.\nقم بإنشاء فئة في الإعدادات لتنظيم مكتبتك';

  @override
  String get noCategoryMangaFound =>
      'لم يتم العثور على مانجا في هذه الفئة. \n(نصيحة: تحقق من البحث والفلاتر!)';

  @override
  String get noChaptersFound => 'لا يوجد فصول';

  @override
  String get noDownloads => 'لا يوجد تنزيلات';

  @override
  String get noMangaFound => 'لم يتم العثور على مانغا';

  @override
  String noOfChapters(int count) {
    return '$count فصل';
  }

  @override
  String noPropFound(Object prop) {
    return 'No $prop Found';
  }

  @override
  String get noResultFound => 'لم يتم العثور على نتائج';

  @override
  String get noServerFound => 'لا يوجد خادم في شبكتك المحلية';

  @override
  String get noSourcesFound => 'لم يتم العثور على مصادر';

  @override
  String get noUpdatesAvailable => 'أنت تستخدم أحدث إصدار';

  @override
  String get noUpdatesFound => 'لم يتم العثور على تحديثات';

  @override
  String get none => 'None';

  @override
  String get nsfw => 'إظهار إضافات ومصادر NSFW';

  @override
  String get nsfw18 => '18+';

  @override
  String get nsfwInfo =>
      'هذا لا يمنع الإضافات غير الرسمية أو التي يحتمل أن يتم وضع علامة عليها بشكل غير صحيح من الظهور على محتوى NSFW (18+) داخل التطبيق';

  @override
  String numSelected(int num) {
    return 'المحددة $num';
  }

  @override
  String get obsolete => 'قديمة';

  @override
  String get openFlareSolverr =>
      'Checkout FlareSolverr for information on how to set it up';

  @override
  String get openInWeb => 'Open In Web';

  @override
  String get or => 'or';

  @override
  String page(int number) {
    return 'الصفحة: $number';
  }

  @override
  String get parallelSourceRequest => 'Parallel source requests';

  @override
  String get password => 'كلمة المرور';

  @override
  String get pause => 'إيقاف';

  @override
  String get pending => 'في الانتظار';

  @override
  String get pinchToZoom => 'قرص للتكبير';

  @override
  String previousChapter(Object chapterTitle) {
    return 'السابق: $chapterTitle';
  }

  @override
  String get queued => 'Queued';

  @override
  String get quickSearch => 'بحث سريع';

  @override
  String get quickSearchCategory => 'اذهب إلى الفئة \'C\'';

  @override
  String get quickSearchCategoryManga =>
      'اذهب إلى المانجا \'M\' في الفئة \'C\'';

  @override
  String get quickSearchCategoryMangaChapter =>
      'انتقل إلى اسم الفصل \'CN\' من المانجا \'M\' في الفئة \'C\'';

  @override
  String get quickSearchContext =>
      'للبحث عن استعلام (النتائج مبنية على معلومات الشاشة)';

  @override
  String get quickSearchShowAllCommandTip =>
      'نصيحة: أدخل علامة الاستفهام \"؟\" لرؤية كافة الأوامر';

  @override
  String get quickSearchSource => 'اذهب إلى المصدر \'S\'';

  @override
  String get quickSearchSourceManga => 'ابحث عن المانجا \'M\' في المصدر \'S\'';

  @override
  String get reader => 'القارئ';

  @override
  String get readerMagnifierSize => 'حجم التكبير';

  @override
  String get readerMode => 'وضع القراءة';

  @override
  String get readerModeContinuousHorizontalLTR =>
      'افقي مستمر (من اليسار لليمين)';

  @override
  String get readerModeContinuousHorizontalRTL =>
      'افقي مستمر (من اليمين لليسار)';

  @override
  String get readerModeContinuousVertical => 'عمودي مستمر';

  @override
  String get readerModeDefaultReader => 'الافتراضي';

  @override
  String get readerModeSingleHorizontalLTR => 'من اليسار لليمين';

  @override
  String get readerModeSingleHorizontalRTL => 'من اليمين لليسار';

  @override
  String get readerModeSingleVertical => 'عموديا';

  @override
  String get readerModeWebtoon => 'ويبتون';

  @override
  String get readerNavigationLayout => 'نوع الانتقال';

  @override
  String get readerNavigationLayoutDefault => 'الافتراضي';

  @override
  String get readerNavigationLayoutDisabled => 'تعطيل';

  @override
  String get readerNavigationLayoutEdge => 'في الحافة';

  @override
  String get readerNavigationLayoutInvert => 'بالنقر';

  @override
  String get readerNavigationLayoutKindlish => 'وضع الكيندل';

  @override
  String get readerNavigationLayoutLShaped => 'شكل حرف L';

  @override
  String get readerNavigationLayoutRightAndLeft => 'يمينا و يسارا';

  @override
  String get readerOverlay => 'تراكب القارئ الأولي';

  @override
  String get readerOverlaySubtitle =>
      'يعرض العنوان والإعدادات السريعة عند فتح الفصل';

  @override
  String get readerPadding => 'ملاءمة القارىء';

  @override
  String get readerScrollAnimation => 'مؤثرات الانتقال بين الصفحات';

  @override
  String get readerSwipeChapterToggle => 'اسحب للانتقال';

  @override
  String get readerSwipeChapterToggleDescription =>
      'اسحب لتغير الفصل في القارئ';

  @override
  String get readerLastPageSwipeToggle => 'Last page swipe';

  @override
  String get readerLastPageSwipeToggleDescription =>
      'Swipe to next chapter only at last page';

  @override
  String get readerVolumeTap => 'مفاتيح التحكم في مستوى الصوت';

  @override
  String get readerVolumeTapInvert => 'عكس مفاتيح مستوى الصوت';

  @override
  String get readerVolumeTapSubtitle => 'التنقل باستخدام مفاتيح مستوى الصوت';

  @override
  String get readerIgnoreSafeAreaToggle => 'Ignore Safe Area';

  @override
  String get readerIgnoreSafeAreaToggleDescription =>
      'Allow content to extend into notch and home indicator areas';

  @override
  String get reddit => 'Reddit';

  @override
  String get refresh => 'تحديث';

  @override
  String get migrate => 'Migrate';

  @override
  String get migrationSelectTargetSource => 'Select Target Source';

  @override
  String migrationSearchInSource(Object sourceName) {
    return 'Search in $sourceName';
  }

  @override
  String get migrationPreview => 'Migration Preview';

  @override
  String get migrationInProgress => 'Migration in Progress';

  @override
  String get migrationComplete => 'Migration completed successfully';

  @override
  String get migrationFailed => 'Migration Failed';

  @override
  String get migrationCancelled => 'Migration Cancelled';

  @override
  String get migrateChapters => 'Migrate Chapters';

  @override
  String get migrateChaptersDescription =>
      'Copy chapter read status to new source';

  @override
  String get migrateCategories => 'Migrate Categories';

  @override
  String get migrateCategoriesDescription =>
      'Copy manga categories to new source';

  @override
  String get migrateDownloads => 'Migrate Downloads';

  @override
  String get migrateDownloadsDescription =>
      'Move downloaded chapters to new source';

  @override
  String get migrateTracking => 'Migrate Tracking';

  @override
  String get migrateTrackingDescription =>
      'Copy tracking information to new source';

  @override
  String get migrationOptions => 'Migration Options';

  @override
  String get migrationSettings => 'Migration Settings';

  @override
  String get selectTargetSource => 'Select Target Source';

  @override
  String get noSourcesAvailable => 'No sources available for migration';

  @override
  String get checkSourceConfiguration =>
      'Please check your source configuration';

  @override
  String get noAlternativeSources => 'No alternative sources available';

  @override
  String get installMoreSources => 'Install more sources to enable migration';

  @override
  String get errorLoadingSources => 'Error loading sources';

  @override
  String get errorGettingMigrationSources => 'Failed to get migration sources';

  @override
  String get errorSearchingMangaInSource => 'Failed to search manga in source';

  @override
  String get errorFetchingSourceManga => 'Failed to fetch source manga';

  @override
  String get errorSourceMangaNotFound => 'Source manga not found';

  @override
  String get errorFetchingTargetManga => 'Failed to fetch target manga';

  @override
  String get errorTargetMangaNotFound => 'Target manga not found';

  @override
  String get searchManga => 'Search manga...';

  @override
  String get searchForManga => 'Search for manga in the target source';

  @override
  String get enterSearchTerm => 'Enter a search term to find manga';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get tryDifferentSearch => 'Try a different search term';

  @override
  String get searchError => 'Search error';

  @override
  String get importantNotice => 'Important Notice';

  @override
  String get migrationWarning =>
      'This will permanently move your manga data. This action cannot be undone.';

  @override
  String get deleteSourceWarning =>
      'The original manga will be removed from your library after migration.';

  @override
  String get confirmMigration => 'Confirm Migration';

  @override
  String get migrationConfirmationMessage =>
      'Are you sure you want to migrate this manga? This action cannot be undone.';

  @override
  String get startMigration => 'Start Migration';

  @override
  String get preparingMigration => 'Preparing migration...';

  @override
  String get migrationCompleted => 'Migration Completed!';

  @override
  String get migrationSuccessMessage =>
      'Your manga has been successfully migrated to the new source.';

  @override
  String get migrationCancelledMessage =>
      'The migration process has been cancelled. No changes were made.';

  @override
  String get cancelMigration => 'Cancel Migration';

  @override
  String get cancelMigrationConfirmation =>
      'Are you sure you want to cancel the migration? This action cannot be undone.';

  @override
  String get quickPresets => 'Quick Presets';

  @override
  String get quickMigration => 'Quick';

  @override
  String get fullMigration => 'Full';

  @override
  String get customMigration => 'Custom';

  @override
  String get deleteSourceManga => 'Delete Source Manga';

  @override
  String get deleteSourceMangaDescription =>
      'Remove the original manga from library after migration';

  @override
  String get done => 'Done';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get from => 'From';

  @override
  String get to => 'To';

  @override
  String get source => 'المصدر';

  @override
  String get migrationDetails => 'Migration Details';

  @override
  String get searchAllSources => 'Search All Sources';

  @override
  String get searchingAllSources => 'Searching across all available sources...';

  @override
  String get noMatchingMangaFound => 'No matching manga found in any source';

  @override
  String get deleteSourceAfterMigration =>
      'Delete source manga after migration';

  @override
  String get reload => 'إعادة تحميل';

  @override
  String get remove => 'أزل';

  @override
  String get removeFromLibrary => 'إزالة من المكتبة؟';

  @override
  String get reset => 'إعادة ضبط';

  @override
  String get restore => 'Restore';

  @override
  String get restoreBackupDescription =>
      'استعادة Tachidesk من النسخة الاحتياطية';

  @override
  String get restoreBackupTitle => 'استعادة النسخة الاحتياطية';

  @override
  String get restored => 'تمت استعادة النسخة الاحتياطية!';

  @override
  String get restoring => 'جاري استعادة النسخة الاحتياطية';

  @override
  String get resume => 'استأنف';

  @override
  String get retry => 'أعد المحاولة';

  @override
  String get running => 'جاري';

  @override
  String get save => 'حفظ';

  @override
  String get saveAsCBZArchive => 'Save as CBZ archive';

  @override
  String get scanlators => 'فرق الترجمة';

  @override
  String get search => 'البحث';

  @override
  String get searchingForUpdates => 'البحث عن التحديثات';

  @override
  String get selectInBetween => 'اختر ما بين';

  @override
  String get selectNext10 => 'حدد الـ 10 التالية';

  @override
  String get selectUnread => 'حدد غير المقروءة';

  @override
  String get server => 'سيرفر';

  @override
  String get serverBindings => 'Server Bindings';

  @override
  String get serverPort => 'منفذ السيرفر';

  @override
  String get serverPortHintText => 'أدخل منفذ السيرفر';

  @override
  String get serverUrl => 'عنوان السيرفر';

  @override
  String get serverUrlHintText => 'أدخل عنوان السيرفر';

  @override
  String get serverVersion => 'إصدار السيرفر';

  @override
  String get settings => 'الإعدادات';

  @override
  String get skipUpdatingEntries => 'Skip updating entries';

  @override
  String get socksHost => 'SOCKS Host';

  @override
  String get socksPassword => 'SOCKS Password';

  @override
  String get socksPort => 'SOCKS Port';

  @override
  String get socksProxy => 'SOCKS Proxy';

  @override
  String get socksUserName => 'SOCKS UserName';

  @override
  String get socksVersion => 'SOCKS Version';

  @override
  String get sort => 'ترتيب';

  @override
  String get sourceTypeFilter => 'فرز';

  @override
  String get sourceTypeLatest => 'الحديثة';

  @override
  String get sourceTypePopular => 'الشائعة';

  @override
  String get sources => 'المصادر';

  @override
  String get start => 'ابدأ';

  @override
  String get systemTrayIcon => 'Show icon in system tray';

  @override
  String get thatHaventBeenStarted => 'That haven\'t been started';

  @override
  String get themeModeDark => 'داكن';

  @override
  String get themeModeLight => 'فاتح';

  @override
  String get themeModeSystem => 'النظام';

  @override
  String get today => 'اليوم';

  @override
  String get uninstall => 'إلغاء التثبيت';

  @override
  String get uninstalling => 'جاري إلغاء التثبيت';

  @override
  String get unknownAuthor => 'مؤلف مجهول';

  @override
  String get unknownManga => 'مانجا غير معروفة';

  @override
  String get unknownSource => 'المصدر مجهول';

  @override
  String get unread => 'غير مقروء';

  @override
  String get update => 'تحديث';

  @override
  String get updateCompleted => 'اكتمل التحديث';

  @override
  String updateFailed(Object property) {
    return 'Failed to update $property';
  }

  @override
  String get updates => 'التحديثات';

  @override
  String get updatesSummary => 'ملخص التحديثات';

  @override
  String get updating => 'جاري التحديث';

  @override
  String get userName => 'اسم المستخدم';

  @override
  String get validating => 'Validating';

  @override
  String versionAvailable(String app, String version) {
    return 'الإصدار $version متاح لـ $app!!';
  }

  @override
  String get webUI => 'فتح في المتصفح';

  @override
  String get webView => 'عرض الويب';

  @override
  String get whatsNew => 'ما الجديد؟';

  @override
  String get withCompletedStatus => 'With Completed status';

  @override
  String get withUnreadChapter => 'With unread chapter(s)';

  @override
  String get yesterday => 'أمس';

  @override
  String get recentlyRead => 'Recently Read';

  @override
  String get history => 'History';

  @override
  String get searchHistory => 'Search history...';

  @override
  String get noHistoryFound => 'No reading history found';

  @override
  String get startReadingToSeeHistory =>
      'Start reading manga to see your history here';

  @override
  String get noSearchResults => 'No search results';

  @override
  String get tryDifferentSearchTerm => 'Try a different search term';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get viewManga => 'View Manga';

  @override
  String get removeFromHistory => 'Remove from History';

  @override
  String get removeFromHistoryConfirmation =>
      'Are you sure you want to remove this chapter from your reading history?';

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
