// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get about => 'Hakkında';

  @override
  String get addCategory => 'Kategori ekle';

  @override
  String get addToLibrary => 'Kütüphaneye ekle';

  @override
  String get advanced => 'Advanced';

  @override
  String get allScanlators => 'Tüm Scanlatorlar';

  @override
  String get appLanguage => 'Uygulama dili';

  @override
  String get appTheme => 'Uygulama teması';

  @override
  String get appTitle => 'Catalyst';

  @override
  String get appearance => 'Görünüş';

  @override
  String get authType => 'Kimlik Doğrulama Tipi';

  @override
  String get authTypeBasic => 'Basit yetki';

  @override
  String get authTypeNone => 'Hiçbiri';

  @override
  String get authentication => 'Authentication';

  @override
  String get autoDownload => 'Auto-download';

  @override
  String get autoDownloadNewChapters => 'Download new chapters';

  @override
  String get automaticBackup => 'Automatic Backup';

  @override
  String get automaticUpdate => 'Automatic Update';

  @override
  String get automaticallyRefreshMetadata => 'Automatically refresh metadata';

  @override
  String get automaticallyRefreshMetadataSubtitle =>
      'Check for new cover and details when updating library';

  @override
  String get backup => 'Yedekle & Yeniden yükle';

  @override
  String get backupAndRestore => 'Backup and Restore';

  @override
  String get backupCleanup => 'Backup Cleanup';

  @override
  String backupCleanupDescription(String count) {
    String _temp0 = intl.Intl.selectLogic(
      count,
      {
        '0': 'Never',
        '01': 'Delete Backups that are older 1 day',
        'other': 'Delete Backups that are older $count days',
      },
    );
    return '$_temp0';
  }

  @override
  String get backupInterval => 'Backup Interval';

  @override
  String get backupLocation => 'Backup Location';

  @override
  String get backupLocationDescription =>
      'The path to the directory on the server where automated backups should get saved in';

  @override
  String get backupTime => 'Backup Time';

  @override
  String get badges => 'Rozetler';

  @override
  String get bookmarked => 'Yer imi eklendi';

  @override
  String get browse => 'Araştır';

  @override
  String get buildTime => 'Derleme zamanı';

  @override
  String get cacheCleared => 'Önbellek temizlendi';

  @override
  String get cancel => 'İptal';

  @override
  String get categories => 'Kategoriler';

  @override
  String get categoryUpdate => 'Kategori güncellemesi';

  @override
  String get channel => 'Kanal';

  @override
  String get chapterDownloadLimit => 'Chapter download limit';

  @override
  String get chapterDownloadLimitDesc =>
      'Limit the amount of new chapters that are going to get downloaded.';

  @override
  String chapterNumber(double number) {
    return 'Bölüm $number';
  }

  @override
  String get chapterSortFetchedDate => 'Şu tarihte çekildi';

  @override
  String get chapterSortSource => 'Kaynağa göre';

  @override
  String get chapterSortUploadDate => 'Yüklenme tarihine göre';

  @override
  String get checkForServerUpdates => 'Sunucu güncellemelerini kontrol edin';

  @override
  String get checkForUpdates => 'Güncellemeleri kontrol edin';

  @override
  String get clearCache => 'Önbelleği temizle';

  @override
  String get client => 'Client';

  @override
  String get clientVersion => 'Client sürümü';

  @override
  String get close => 'Kapat';

  @override
  String get cloudflareBypass => 'Cloudflare Bypass';

  @override
  String get completed => 'Tamamlandı';

  @override
  String get copied => 'Copied!';

  @override
  String copyMsg(String msg) {
    return '\'$msg\' kopyalandı!';
  }

  @override
  String get createBackupDescription =>
      'Kütüphaneyi Tachidesk yedeği olarak yedekle';

  @override
  String get createBackupTitle => 'Yedek oluştur';

  @override
  String get credentials => 'Referanslar';

  @override
  String get current => 'Güncel';

  @override
  String daysAgo(Object days) {
    return '$days gün önce';
  }

  @override
  String get debugLogs => 'Debug logs';

  @override
  String get defaultCategory =>
      'Yeni mangayı kütüphaneye eklerken kullanılacak olan varsayılan kategori';

  @override
  String get delete => 'Sil';

  @override
  String get deleteCategoryDescription =>
      'Bu kategorideki bütün mangaları varsayılan haline getirilecek';

  @override
  String get deleteCategoryTitle => 'Emin misin?';

  @override
  String get discord => 'Discord';

  @override
  String get display => 'Görüntü';

  @override
  String get displayMode => 'Görüntü modu';

  @override
  String get displayModeDescriptiveList => 'Açıklayıcı liste';

  @override
  String get displayModeGrid => 'Izgara';

  @override
  String get displayModeList => 'Liste';

  @override
  String get downloadLocation => 'Download location';

  @override
  String get downloadLocationHint =>
      'The path to the directory on the server where downloaded files should get saved in';

  @override
  String get downloaded => 'İndirildi';

  @override
  String get downloading => 'Downloading';

  @override
  String get downloads => 'İndirmeler';

  @override
  String get edit => 'Düzenleme';

  @override
  String get editCategory => 'Kategoriyi düzenle';

  @override
  String get emptyCategory => 'Kategori ismi boş olamaz';

  @override
  String get enableSocksProxy => 'Use SOCKS Proxy';

  @override
  String enterProp(Object prop) {
    return 'Enter $prop';
  }

  @override
  String get error => 'Error';

  @override
  String get errorBackupCreate => 'Failed to create Backup';

  @override
  String get errorBackupRestore => 'Failed to restore backup!';

  @override
  String get errorExtension => 'Seçilen eklenti bulunamıyor';

  @override
  String get errorFilePick => 'Dosya seçilmedi!';

  @override
  String errorFilePickUnknownExtension(Object extensionName) {
    return 'Lütfen dosyayı $extensionName eklentisiyle seçin';
  }

  @override
  String errorLaunchURL(String url) {
    return 'Açılamadı\n\"$url\" panoya kopyalanıyor';
  }

  @override
  String get errorPassword => 'Şifre alanı boş olamaz';

  @override
  String get errorSomethingWentWrong => 'Bir şeyler ters gitti!';

  @override
  String get errorUserName => 'Kullanıcı ismi boş olamaz';

  @override
  String get excludeEntryWithUnreadChapters =>
      'Ignore automatic chapter downloads for entries with unread chapters';

  @override
  String get extensionInstalled => 'Eklenti indirildi!';

  @override
  String get extensionListEmpty => 'Eklenti listesi boş';

  @override
  String get extensionRepository => 'Extension Repository';

  @override
  String get extensionRepositoryDescription =>
      'Add repositories from which extensions can be installed';

  @override
  String get extensions => 'Eklentiler';

  @override
  String get failed => 'Hata oluştu';

  @override
  String get filter => 'Filtrele';

  @override
  String get findServer => 'Bul';

  @override
  String get finished => 'Bitti';

  @override
  String get flareSolverr => 'FlareSolverr';

  @override
  String get flareSolverrRequestTimeout => 'FlareSolverr Request Timeout';

  @override
  String get flareSolverrServerUrl => 'FlareSolverr Server Url';

  @override
  String get flareSolverrSessionName => 'FlareSolverr session name';

  @override
  String get flareSolverrSessionTTL => 'FlareSolverr session TTL';

  @override
  String get general => 'Genel';

  @override
  String get gitHub => 'GitHub';

  @override
  String get globalSearch => 'Global arama';

  @override
  String get globalUpdate => 'Global güncelleme';

  @override
  String get gqlDebugLogs => 'Graphql debug logs';

  @override
  String get gqlDebugLogsHint =>
      'This includes logs with non privacy safe information';

  @override
  String get help => 'Yardım';

  @override
  String get hideEmptyCategory => 'Hide Empty Category';

  @override
  String get inLibrary => 'Kütüphanede';

  @override
  String get includeCategories => 'Categories';

  @override
  String get includeChapters => 'Chapters';

  @override
  String get install => 'İndir';

  @override
  String get installing => 'İndiriliyor';

  @override
  String get installingExtension => 'Eklenti indiriliyor';

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
  String get isTrueBlack => 'Gerçek siyah';

  @override
  String get languages => 'Diller';

  @override
  String get latest => 'Sonuncu';

  @override
  String get library => 'Kütüphane';

  @override
  String get localSourceLocation => 'Local source location';

  @override
  String get localSourceLocationDescription =>
      'The path to the directory on the server where local source files are saved in';

  @override
  String get manga => 'Manga';

  @override
  String get mangaGridSize => 'Manga ızgara boyutu';

  @override
  String get mangaMissingSources => 'Manga kayıp kaynaklar';

  @override
  String get mangaSortAlphabetical => 'Alfabetik';

  @override
  String get mangaSortDateAdded => 'Tarihte eklendi';

  @override
  String get mangaSortLastRead => 'Son okunan';

  @override
  String get mangaSortLastUpdated => 'Last Updated';

  @override
  String get mangaSortUnread => 'Okunmamış';

  @override
  String get mangaStatusCancelled => 'İptal edildi';

  @override
  String get mangaStatusCompleted => 'Tamamlandı';

  @override
  String get mangaStatusLicensed => 'Lisanslı';

  @override
  String get mangaStatusOnHiatus => 'Hiatus\'ta';

  @override
  String get mangaStatusOngoing => 'Devam ediyor';

  @override
  String get mangaStatusPublishingFinished => 'Yayımlama tamamlandı';

  @override
  String get mangaStatusUnknown => 'Bilinmiyor';

  @override
  String get misc => 'Misc';

  @override
  String get missingExtension => 'Kayıp eklentiler';

  @override
  String get missingTrackers => 'Kayıp';

  @override
  String get more => 'Daha fazla';

  @override
  String get moveToBottom => 'Aşağıya git';

  @override
  String get moveToTop => 'Yukarıya çık';

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
  String get newUpdateAvailable => 'Yeni güncelleme mevcut';

  @override
  String nextChapter(Object chapterTitle) {
    return 'Sonraki: $chapterTitle';
  }

  @override
  String get noCategoriesFound =>
      'Kategorin yok\n(Tüyo: Kütüphaneyi organize etmek için artıya basarsanız yeni bir tane yaratabilirsiniz)';

  @override
  String get noCategoriesFoundAlt =>
      'Kategorin yok\nKütüphanenizi organize etmek için ayarlardan bir tane yaratınız';

  @override
  String get noCategoryMangaFound =>
      'Bu kategoride herhangi bir manga bulunamadı\n(Tüyo: Arama & Filtreleri kontrol et!)';

  @override
  String get noChaptersFound => 'Bir bölüm bulunamadı';

  @override
  String get noDownloads => 'İndirilen bir şey yok';

  @override
  String get noMangaFound => 'Mangalar bulunamadı';

  @override
  String noOfChapters(int count) {
    return '$count bölüm';
  }

  @override
  String noPropFound(Object prop) {
    return 'No $prop Found';
  }

  @override
  String get noResultFound => 'Bir sonuç bulunamadı';

  @override
  String get noServerFound => 'Yerel internet ağında sunucu bulunamadı';

  @override
  String get noSourcesFound => 'Kaynaklar bulunamadı';

  @override
  String get noUpdatesAvailable => 'En güncel versiyonu kullanıyorsunuz';

  @override
  String get noUpdatesFound => 'Güncelleme bulunamadı';

  @override
  String get none => 'None';

  @override
  String get nsfw => 'NSFW eklentilerini ve kaynaklarını göster';

  @override
  String get nsfw18 => '18+';

  @override
  String get nsfwInfo =>
      'Bu, resmi olmayan veya muhtemelen yanlış işaretlenmiş uzantıların uygulama içinde NSFW(18+) içerik sunmasını engellemez';

  @override
  String numSelected(int num) {
    return '$num seçildi';
  }

  @override
  String get obsolete => 'Kullanım dışı';

  @override
  String get openFlareSolverr =>
      'Checkout FlareSolverr for information on how to set it up';

  @override
  String get openInWeb => 'Open In Web';

  @override
  String get or => 'or';

  @override
  String page(int number) {
    return 'Sayfa: $number';
  }

  @override
  String get parallelSourceRequest => 'Parallel source requests';

  @override
  String get password => 'Şifre';

  @override
  String get pause => 'Duraklat';

  @override
  String get pending => 'Askıda';

  @override
  String get pinchToZoom => 'Zoomlamak için kıstırın';

  @override
  String previousChapter(Object chapterTitle) {
    return 'Önceki: $chapterTitle';
  }

  @override
  String get queued => 'Queued';

  @override
  String get quickSearch => 'Hızlı Arama';

  @override
  String get quickSearchCategory => '\'C\' Kategorisine Git';

  @override
  String get quickSearchCategoryManga => 'Go to Manga \'M\' in Category \'C\'';

  @override
  String get quickSearchCategoryMangaChapter =>
      'Go to Chapter Name \'CN\' from Manga \'M\' in Category \'C\'';

  @override
  String get quickSearchContext =>
      'X sorgusunu ara (Sonuçlar ekran bağlamına göre belirlenir)';

  @override
  String get quickSearchShowAllCommandTip =>
      'İpucu: Tüm komutları görmek için \'?\' tuşuna basın';

  @override
  String get quickSearchSource => 'Kaynağa git \'S\'';

  @override
  String get quickSearchSourceManga => 'Search for Manga \'M\' in Source \'S\'';

  @override
  String get reader => 'Reader';

  @override
  String get readerMagnifierSize => 'Büyüteç Boyutu';

  @override
  String get readerMode => 'Okuma Modu';

  @override
  String get readerModeContinuousHorizontalLTR => 'Continuous Horizontal (LTR)';

  @override
  String get readerModeContinuousHorizontalRTL => 'Continuous Horizontal (RTL)';

  @override
  String get readerModeContinuousVertical => 'Continuous Vertical';

  @override
  String get readerModeDefaultReader => 'Varsayılan';

  @override
  String get readerModeSingleHorizontalLTR => 'Single Horizontal (LTR)';

  @override
  String get readerModeSingleHorizontalRTL => 'Single Horizontal (RTL)';

  @override
  String get readerModeSingleVertical => 'Single Vertical';

  @override
  String get readerModeWebtoon => 'Webtoon';

  @override
  String get readerNavigationLayout => 'Navigation layout';

  @override
  String get readerNavigationLayoutDefault => 'Varsayılan';

  @override
  String get readerNavigationLayoutDisabled => 'Devre Dışı';

  @override
  String get readerNavigationLayoutEdge => 'Edge';

  @override
  String get readerNavigationLayoutInvert => 'Invert tapping';

  @override
  String get readerNavigationLayoutKindlish => 'Kindle-ish';

  @override
  String get readerNavigationLayoutLShaped => 'L Shaped';

  @override
  String get readerNavigationLayoutRightAndLeft => 'Right And Left';

  @override
  String get readerOverlay => 'Reader initial overlay';

  @override
  String get readerOverlaySubtitle =>
      'Shows title and quick settings when opening a chapter';

  @override
  String get readerPadding => 'Reader Padding';

  @override
  String get readerScrollAnimation => 'Scroll animation';

  @override
  String get readerSwipeChapterToggle => 'Swipe toggle';

  @override
  String get readerSwipeChapterToggleDescription =>
      'Swipe to change chapter in reader';

  @override
  String get readerLastPageSwipeToggle => 'Last page swipe';

  @override
  String get readerLastPageSwipeToggleDescription =>
      'Swipe to next chapter only at last page';

  @override
  String get readerVolumeTap => 'Volume Keys';

  @override
  String get readerVolumeTapInvert => 'Invert Volume Keys';

  @override
  String get readerVolumeTapSubtitle => 'Navigate with Volume Keys';

  @override
  String get readerIgnoreSafeAreaToggle => 'Ignore Safe Area';

  @override
  String get readerIgnoreSafeAreaToggleDescription =>
      'Allow content to extend into notch and home indicator areas';

  @override
  String get reddit => 'Reddit';

  @override
  String get refresh => 'Refresh';

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
  String get source => 'Source';

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
  String get reload => 'Reload';

  @override
  String get remove => 'Remove';

  @override
  String get removeFromLibrary => 'Remove from Library?';

  @override
  String get reset => 'Reset';

  @override
  String get restore => 'Restore';

  @override
  String get restoreBackupDescription => 'Restore Tachidesk from backup';

  @override
  String get restoreBackupTitle => 'Restore Backup';

  @override
  String get restored => 'Backup restored!';

  @override
  String get restoring => 'Restoring backup';

  @override
  String get resume => 'Resume';

  @override
  String get retry => 'Retry';

  @override
  String get running => 'Running';

  @override
  String get save => 'Save';

  @override
  String get saveAsCBZArchive => 'Save as CBZ archive';

  @override
  String get scanlators => 'Scanlators';

  @override
  String get search => 'Search';

  @override
  String get searchingForUpdates => 'Searching for updates';

  @override
  String get selectInBetween => 'Select in between';

  @override
  String get selectNext10 => 'Select next 10';

  @override
  String get selectUnread => 'Select Unread';

  @override
  String get server => 'Server';

  @override
  String get serverBindings => 'Server Bindings';

  @override
  String get serverPort => 'Server Port';

  @override
  String get serverPortHintText => 'Server port';

  @override
  String get serverUrl => 'Server URL';

  @override
  String get serverUrlHintText => 'Server url';

  @override
  String get serverVersion => 'Server version';

  @override
  String get settings => 'Settings';

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
  String get sort => 'Sort';

  @override
  String get sourceTypeFilter => 'Filter';

  @override
  String get sourceTypeLatest => 'Latest';

  @override
  String get sourceTypePopular => 'Popular';

  @override
  String get sources => 'Sources';

  @override
  String get start => 'Start';

  @override
  String get systemTrayIcon => 'Show icon in system tray';

  @override
  String get thatHaventBeenStarted => 'That haven\'t been started';

  @override
  String get themeModeDark => 'Dark';

  @override
  String get themeModeLight => 'Light';

  @override
  String get themeModeSystem => 'System';

  @override
  String get today => 'Today';

  @override
  String get uninstall => 'Uninstall';

  @override
  String get uninstalling => 'Uninstalling';

  @override
  String get unknownAuthor => 'Unknown Author';

  @override
  String get unknownManga => 'Unknown Manga';

  @override
  String get unknownSource => 'Unknown Source';

  @override
  String get unread => 'Unread';

  @override
  String get update => 'Update';

  @override
  String get updateCompleted => 'Update Completed';

  @override
  String updateFailed(Object property) {
    return 'Failed to update $property';
  }

  @override
  String get updates => 'Updates';

  @override
  String get updatesSummary => 'Updates Summary';

  @override
  String get updating => 'Updating';

  @override
  String get userName => 'User Name';

  @override
  String get validating => 'Validating';

  @override
  String versionAvailable(String app, String version) {
    return 'Version $version available for $app!!';
  }

  @override
  String get webUI => 'Open in WEB';

  @override
  String get webView => 'Web View';

  @override
  String get whatsNew => 'What\'s New?';

  @override
  String get withCompletedStatus => 'With Completed status';

  @override
  String get withUnreadChapter => 'With unread chapter(s)';

  @override
  String get yesterday => 'Yesterday';

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
