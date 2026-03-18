// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get about => 'Tentang';

  @override
  String get addCategory => 'Tambah Kategori';

  @override
  String get addToLibrary => 'Tambahkan ke Pustaka';

  @override
  String get advanced => 'Advanced';

  @override
  String get allScanlators => 'Semua Pemindai';

  @override
  String get appLanguage => 'Bahasa Aplikasi';

  @override
  String get appTheme => 'Mode Tema Aplikasi';

  @override
  String get appTitle => 'Catalyst';

  @override
  String get appearance => 'Tampilan';

  @override
  String get authType => 'Tipe Autentikasi';

  @override
  String get authTypeBasic => 'Autentikasi Dasar';

  @override
  String get authTypeNone => 'Tidak Ada';

  @override
  String get authentication => 'Authentication';

  @override
  String get autoDownload => 'Auto-download';

  @override
  String get autoDownloadNewChapters => 'Download new chapters';

  @override
  String get automaticBackup => 'Automatic Backup';

  @override
  String get automaticUpdate => 'Perbarui Otomatis';

  @override
  String get automaticallyRefreshMetadata => 'Otomatis perbarui metadata';

  @override
  String get automaticallyRefreshMetadataSubtitle =>
      'Periksa sampul dan detail baru saat memperbarui pustaka';

  @override
  String get backup => 'Cadangkan & Pulihkan';

  @override
  String get backupAndRestore => 'Cadangkan dan Pulihkan';

  @override
  String get backupCleanup => 'Pembersihan Cadangan';

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
  String get badges => 'Lencana';

  @override
  String get bookmarked => 'Ditandai';

  @override
  String get browse => 'Jelajahi';

  @override
  String get buildTime => 'Waktu build';

  @override
  String get cacheCleared => 'Cache Dibershikan';

  @override
  String get cancel => 'Batal';

  @override
  String get categories => 'Kategori';

  @override
  String get categoryUpdate => 'Perbarui Kategori';

  @override
  String get channel => 'Saluran';

  @override
  String get chapterDownloadLimit => 'Chapter download limit';

  @override
  String get chapterDownloadLimitDesc =>
      'Limit the amount of new chapters that are going to get downloaded.';

  @override
  String chapterNumber(double number) {
    return 'Chapter$number';
  }

  @override
  String get chapterSortFetchedDate => 'Berdasarkan Tanggal Diambil';

  @override
  String get chapterSortSource => 'Berdasarkan Sumber';

  @override
  String get chapterSortUploadDate => 'Berdasarkan Tanggal Diunggah';

  @override
  String get checkForServerUpdates => 'Periksa Update Server';

  @override
  String get checkForUpdates => 'Periksa Update';

  @override
  String get clearCache => 'Bersihkan Cache';

  @override
  String get client => 'Client';

  @override
  String get clientVersion => 'Versi Client';

  @override
  String get close => 'Tutup';

  @override
  String get cloudflareBypass => 'Cloudflare Bypass';

  @override
  String get completed => 'Tamat';

  @override
  String get copied => 'Copied!';

  @override
  String copyMsg(String msg) {
    return '\'$msg\' Disalin!';
  }

  @override
  String get createBackupDescription =>
      'Cadangkan pustaka sebagai cadangan Tachidesk';

  @override
  String get createBackupTitle => 'Buat Cadangan';

  @override
  String get credentials => 'Kredensial';

  @override
  String get current => 'Saat ini';

  @override
  String daysAgo(Object days) {
    return '$days hari yang lalu';
  }

  @override
  String get debugLogs => 'Debug logs';

  @override
  String get defaultCategory =>
      'Kategori default ketika menambahkan manga baru ke pustaka';

  @override
  String get delete => 'Hapus';

  @override
  String get deleteCategoryDescription =>
      'Ini akan menggabungkan semua Manga di kategori ini ke Default!';

  @override
  String get deleteCategoryTitle => 'Apakah kamu yakin?';

  @override
  String get discord => 'Discord';

  @override
  String get display => 'Tampilan';

  @override
  String get displayMode => 'Mode Tampilan';

  @override
  String get displayModeDescriptiveList => 'List Descriptive';

  @override
  String get displayModeGrid => 'Grid';

  @override
  String get displayModeList => 'List';

  @override
  String get downloadLocation => 'Download location';

  @override
  String get downloadLocationHint =>
      'The path to the directory on the server where downloaded files should get saved in';

  @override
  String get downloaded => 'Diunduh';

  @override
  String get downloading => 'Downloading';

  @override
  String get downloads => 'Unduhan';

  @override
  String get edit => 'Login';

  @override
  String get editCategory => 'Ubah kategori';

  @override
  String get emptyCategory => 'Nama kategori tidak bisa kosong';

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
  String get errorExtension => 'Tidak dapat menemukan ekstensi yang dipilih';

  @override
  String get errorFilePick => 'Tidak dipilih!';

  @override
  String errorFilePickUnknownExtension(Object extensionName) {
    return 'Silahkan pilih file dengan ekstensi $extensionName';
  }

  @override
  String errorLaunchURL(String url) {
    return 'Kegagalan untuk membuka!\nMenyalin \"$url\" ke clipboard';
  }

  @override
  String get errorPassword => 'Sandi tidak bisa kosong';

  @override
  String get errorSomethingWentWrong => 'Sesuatu yang salah!';

  @override
  String get errorUserName => 'UserName tidak bisa kosong';

  @override
  String get excludeEntryWithUnreadChapters =>
      'Ignore automatic chapter downloads for entries with unread chapters';

  @override
  String get extensionInstalled => 'Ekstensi Diinstal!';

  @override
  String get extensionListEmpty => 'Daftar ekstensi kosong';

  @override
  String get extensionRepository => 'Extension Repository';

  @override
  String get extensionRepositoryDescription =>
      'Add repositories from which extensions can be installed';

  @override
  String get extensions => 'Login';

  @override
  String get failed => 'Gagal';

  @override
  String get filter => 'Filter';

  @override
  String get findServer => 'Cari';

  @override
  String get finished => 'Selesai';

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
  String get general => 'Umum';

  @override
  String get gitHub => 'Github';

  @override
  String get globalSearch => 'Pencarian Global';

  @override
  String get globalUpdate => 'Pembaruan Global';

  @override
  String get gqlDebugLogs => 'Graphql debug logs';

  @override
  String get gqlDebugLogsHint =>
      'This includes logs with non privacy safe information';

  @override
  String get help => 'Bantuan';

  @override
  String get hideEmptyCategory => 'Hide Empty Category';

  @override
  String get inLibrary => 'di Perpustakaan';

  @override
  String get includeCategories => 'Categories';

  @override
  String get includeChapters => 'Chapters';

  @override
  String get install => 'Pasang';

  @override
  String get installing => 'Sedang Memasang';

  @override
  String get installingExtension => 'Menginstal Ekstensi';

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
  String get isTrueBlack => 'Benar Hitam';

  @override
  String get languages => 'Bahasa';

  @override
  String get latest => 'Terakhir';

  @override
  String get library => 'Perpustakaan';

  @override
  String get localSourceLocation => 'Local source location';

  @override
  String get localSourceLocationDescription =>
      'The path to the directory on the server where local source files are saved in';

  @override
  String get manga => 'Manga';

  @override
  String get mangaGridSize => 'Manga Grid Size';

  @override
  String get mangaMissingSources => 'Manga Missing Sources';

  @override
  String get mangaSortAlphabetical => 'Alphabetical';

  @override
  String get mangaSortDateAdded => 'Date Added';

  @override
  String get mangaSortLastRead => 'Last Read';

  @override
  String get mangaSortLastUpdated => 'Last Updated';

  @override
  String get mangaSortUnread => 'Unread';

  @override
  String get mangaStatusCancelled => 'Cancelled';

  @override
  String get mangaStatusCompleted => 'Selesai';

  @override
  String get mangaStatusLicensed => 'Berlisensi';

  @override
  String get mangaStatusOnHiatus => 'Sedang Hiatus';

  @override
  String get mangaStatusOngoing => 'Berjalan';

  @override
  String get mangaStatusPublishingFinished => 'Selesai Diterbitkan';

  @override
  String get mangaStatusUnknown => 'Tidak diketahui';

  @override
  String get misc => 'Misc';

  @override
  String get missingExtension => 'Ekstensi Hilang';

  @override
  String get missingTrackers => 'Trackers Hilang';

  @override
  String get more => 'More';

  @override
  String get moveToBottom => 'Move to Bottom';

  @override
  String get moveToTop => 'Move to top';

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
  String get newUpdateAvailable => 'New update available';

  @override
  String nextChapter(Object chapterTitle) {
    return 'Next: $chapterTitle';
  }

  @override
  String get noCategoriesFound =>
      'You don\'t have any Categories. \n(Tip: Tap the Plus button to create one for organizing your library)';

  @override
  String get noCategoriesFoundAlt =>
      'You don\'t have any Categories. \nCreate one in settings for organizing your library';

  @override
  String get noCategoryMangaFound =>
      'No manga found in this Category. \n(Tip: Check your search & filters!)';

  @override
  String get noChaptersFound => 'No Chapters found';

  @override
  String get noDownloads => 'No Downloads';

  @override
  String get noMangaFound => 'No Mangas Found';

  @override
  String noOfChapters(int count) {
    return '$count Chapters';
  }

  @override
  String noPropFound(Object prop) {
    return 'No $prop Found';
  }

  @override
  String get noResultFound => 'No results found';

  @override
  String get noServerFound => 'No Server found in your local network';

  @override
  String get noSourcesFound => 'No sources found';

  @override
  String get noUpdatesAvailable => 'You\'re using the latest version';

  @override
  String get noUpdatesFound => 'No updates found';

  @override
  String get none => 'None';

  @override
  String get nsfw => 'Show NSFW extensions and sources';

  @override
  String get nsfw18 => '18+';

  @override
  String get nsfwInfo =>
      'This does not prevent unofficial or potentially incorrectly flagged extensions from surfacing NSFW(18+) content within app';

  @override
  String numSelected(int num) {
    return '$num Selected';
  }

  @override
  String get obsolete => 'Obsolete';

  @override
  String get openFlareSolverr =>
      'Checkout FlareSolverr for information on how to set it up';

  @override
  String get openInWeb => 'Open In Web';

  @override
  String get or => 'or';

  @override
  String page(int number) {
    return 'Page: $number';
  }

  @override
  String get parallelSourceRequest => 'Parallel source requests';

  @override
  String get password => 'Password';

  @override
  String get pause => 'Pause';

  @override
  String get pending => 'Pending';

  @override
  String get pinchToZoom => 'Pinch to Zoom';

  @override
  String previousChapter(Object chapterTitle) {
    return 'Previous: $chapterTitle';
  }

  @override
  String get queued => 'Queued';

  @override
  String get quickSearch => 'Quick Search';

  @override
  String get quickSearchCategory => 'Go to Category \'C\'';

  @override
  String get quickSearchCategoryManga => 'Go to Manga \'M\' in Category \'C\'';

  @override
  String get quickSearchCategoryMangaChapter =>
      'Go to Chapter Name \'CN\' from Manga \'M\' in Category \'C\'';

  @override
  String get quickSearchContext =>
      'Search for query X (Results are based on screen context)';

  @override
  String get quickSearchShowAllCommandTip =>
      'Tip: Enter \'?\' to see all commands';

  @override
  String get quickSearchSource => 'Go to Source \'S\'';

  @override
  String get quickSearchSourceManga => 'Search for Manga \'M\' in Source \'S\'';

  @override
  String get reader => 'Reader';

  @override
  String get readerMagnifierSize => 'Magnifier Size';

  @override
  String get readerMode => 'Reading Mode';

  @override
  String get readerModeContinuousHorizontalLTR => 'Continuous Horizontal (LTR)';

  @override
  String get readerModeContinuousHorizontalRTL => 'Continuous Horizontal (RTL)';

  @override
  String get readerModeContinuousVertical => 'Continuous Vertical';

  @override
  String get readerModeDefaultReader => 'Default';

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
  String get readerNavigationLayoutDefault => 'Default';

  @override
  String get readerNavigationLayoutDisabled => 'Disabled';

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
