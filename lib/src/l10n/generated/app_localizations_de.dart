// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get about => 'Über';

  @override
  String get addCategory => 'Kategorie hinzufügen';

  @override
  String get addToLibrary => 'Zur Bibliothek hinzufügen';

  @override
  String get advanced => 'Advanced';

  @override
  String get allScanlators => '';

  @override
  String get appLanguage => 'App Sprache';

  @override
  String get appTheme => 'App Design';

  @override
  String get appTitle => 'Catalyst';

  @override
  String get appearance => 'Aussehen';

  @override
  String get authType => 'Authentifizierungsart';

  @override
  String get authTypeBasic => 'Basic Auth';

  @override
  String get authTypeNone => 'Keine';

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
  String get backup => 'Sichern und wiederherstellen';

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
  String get badges => 'Indikatoren';

  @override
  String get bookmarked => 'Hat Lesezeichen';

  @override
  String get browse => 'Suchen';

  @override
  String get buildTime => 'Build time';

  @override
  String get cacheCleared => 'Zwischenspeicher geleert';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get categories => 'Kategorien';

  @override
  String get categoryUpdate => 'Kategorie aktualisierung';

  @override
  String get channel => 'Kanal';

  @override
  String get chapterDownloadLimit => 'Chapter download limit';

  @override
  String get chapterDownloadLimitDesc =>
      'Limit the amount of new chapters that are going to get downloaded.';

  @override
  String chapterNumber(double number) {
    return 'Kapitel $number';
  }

  @override
  String get chapterSortFetchedDate => 'Nach Abrufdatum';

  @override
  String get chapterSortSource => 'Nach Quelle';

  @override
  String get chapterSortUploadDate => 'Nach Hochladedatum';

  @override
  String get checkForServerUpdates => 'Nach Serveraktualisierungen suchen';

  @override
  String get checkForUpdates => 'Nach Aktualisierungen suchen';

  @override
  String get clearCache => 'Zwischenspeicher leeren';

  @override
  String get client => 'Endgerät';

  @override
  String get clientVersion => 'Endgerät Version';

  @override
  String get close => 'Schließen';

  @override
  String get cloudflareBypass => 'Cloudflare Bypass';

  @override
  String get completed => 'Abgeschlossen';

  @override
  String get copied => 'Copied!';

  @override
  String copyMsg(String msg) {
    return '\'$msg\' kopiert!';
  }

  @override
  String get createBackupDescription =>
      'Bibliothek als Tachidesk backup sichern';

  @override
  String get createBackupTitle => 'Sicherung erstellen';

  @override
  String get credentials => 'Anmeldedaten';

  @override
  String get current => 'Aktuell';

  @override
  String daysAgo(Object days) {
    return '$days days ago';
  }

  @override
  String get debugLogs => 'Debug logs';

  @override
  String get defaultCategory =>
      'Standard Kategorie, wenn neue Manga zur Bibliothek hinzugefügt werden';

  @override
  String get delete => 'Löschen';

  @override
  String get deleteCategoryDescription => '';

  @override
  String get deleteCategoryTitle => '';

  @override
  String get discord => '';

  @override
  String get display => '';

  @override
  String get displayMode => '';

  @override
  String get displayModeDescriptiveList => '';

  @override
  String get displayModeGrid => '';

  @override
  String get displayModeList => '';

  @override
  String get downloadLocation => 'Download location';

  @override
  String get downloadLocationHint =>
      'The path to the directory on the server where downloaded files should get saved in';

  @override
  String get downloaded => '';

  @override
  String get downloading => 'Downloading';

  @override
  String get downloads => '';

  @override
  String get edit => '';

  @override
  String get editCategory => '';

  @override
  String get emptyCategory => '';

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
  String get errorExtension => '';

  @override
  String get errorFilePick => '';

  @override
  String errorFilePickUnknownExtension(Object extensionName) {
    return '';
  }

  @override
  String errorLaunchURL(String url) {
    return '';
  }

  @override
  String get errorPassword => '';

  @override
  String get errorSomethingWentWrong => '';

  @override
  String get errorUserName => '';

  @override
  String get excludeEntryWithUnreadChapters =>
      'Ignore automatic chapter downloads for entries with unread chapters';

  @override
  String get extensionInstalled => '';

  @override
  String get extensionListEmpty => '';

  @override
  String get extensionRepository => 'Extension Repository';

  @override
  String get extensionRepositoryDescription =>
      'Add repositories from which extensions can be installed';

  @override
  String get extensions => '';

  @override
  String get failed => '';

  @override
  String get filter => '';

  @override
  String get findServer => '';

  @override
  String get finished => '';

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
  String get general => '';

  @override
  String get gitHub => '';

  @override
  String get globalSearch => '';

  @override
  String get globalUpdate => '';

  @override
  String get gqlDebugLogs => 'Graphql debug logs';

  @override
  String get gqlDebugLogsHint =>
      'This includes logs with non privacy safe information';

  @override
  String get help => '';

  @override
  String get hideEmptyCategory => 'Hide Empty Category';

  @override
  String get inLibrary => '';

  @override
  String get includeCategories => 'Categories';

  @override
  String get includeChapters => 'Chapters';

  @override
  String get install => '';

  @override
  String get installing => '';

  @override
  String get installingExtension => '';

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
  String get isTrueBlack => 'True Black';

  @override
  String get languages => '';

  @override
  String get latest => '';

  @override
  String get library => 'Bibltiotek';

  @override
  String get localSourceLocation => 'Local source location';

  @override
  String get localSourceLocationDescription =>
      'The path to the directory on the server where local source files are saved in';

  @override
  String get manga => '';

  @override
  String get mangaGridSize => '';

  @override
  String get mangaMissingSources => '';

  @override
  String get mangaSortAlphabetical => '';

  @override
  String get mangaSortDateAdded => '';

  @override
  String get mangaSortLastRead => '';

  @override
  String get mangaSortLastUpdated => 'Last Updated';

  @override
  String get mangaSortUnread => '';

  @override
  String get mangaStatusCancelled => '';

  @override
  String get mangaStatusCompleted => '';

  @override
  String get mangaStatusLicensed => '';

  @override
  String get mangaStatusOnHiatus => '';

  @override
  String get mangaStatusOngoing => '';

  @override
  String get mangaStatusPublishingFinished => '';

  @override
  String get mangaStatusUnknown => '';

  @override
  String get misc => 'Misc';

  @override
  String get missingExtension => '';

  @override
  String get missingTrackers => '';

  @override
  String get more => '';

  @override
  String get moveToBottom => '';

  @override
  String get moveToTop => '';

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
    return '';
  }

  @override
  String get newUpdateAvailable => '';

  @override
  String nextChapter(Object chapterTitle) {
    return 'Next: $chapterTitle';
  }

  @override
  String get noCategoriesFound => '';

  @override
  String get noCategoriesFoundAlt => '';

  @override
  String get noCategoryMangaFound => '';

  @override
  String get noChaptersFound => '';

  @override
  String get noDownloads => '';

  @override
  String get noMangaFound => '';

  @override
  String noOfChapters(int count) {
    return '';
  }

  @override
  String noPropFound(Object prop) {
    return 'No $prop Found';
  }

  @override
  String get noResultFound => '';

  @override
  String get noServerFound => '';

  @override
  String get noSourcesFound => '';

  @override
  String get noUpdatesAvailable => '';

  @override
  String get noUpdatesFound => '';

  @override
  String get none => 'None';

  @override
  String get nsfw => '';

  @override
  String get nsfw18 => '';

  @override
  String get nsfwInfo => '';

  @override
  String numSelected(int num) {
    return '';
  }

  @override
  String get obsolete => '';

  @override
  String get openFlareSolverr =>
      'Checkout FlareSolverr for information on how to set it up';

  @override
  String get openInWeb => 'Open In Web';

  @override
  String get or => 'or';

  @override
  String page(int number) {
    return '';
  }

  @override
  String get parallelSourceRequest => 'Parallel source requests';

  @override
  String get password => '';

  @override
  String get pause => '';

  @override
  String get pending => '';

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
  String get quickSearchCategory => '';

  @override
  String get quickSearchCategoryManga => '';

  @override
  String get quickSearchCategoryMangaChapter => '';

  @override
  String get quickSearchContext => '';

  @override
  String get quickSearchShowAllCommandTip =>
      'Tip: Enter \'?\' to see all commands';

  @override
  String get quickSearchSource => '';

  @override
  String get quickSearchSourceManga => '';

  @override
  String get reader => '';

  @override
  String get readerMagnifierSize => '';

  @override
  String get readerMode => '';

  @override
  String get readerModeContinuousHorizontalLTR => '';

  @override
  String get readerModeContinuousHorizontalRTL => '';

  @override
  String get readerModeContinuousVertical => '';

  @override
  String get readerModeDefaultReader => '';

  @override
  String get readerModeSingleHorizontalLTR => '';

  @override
  String get readerModeSingleHorizontalRTL => '';

  @override
  String get readerModeSingleVertical => '';

  @override
  String get readerModeWebtoon => '';

  @override
  String get readerNavigationLayout => '';

  @override
  String get readerNavigationLayoutDefault => '';

  @override
  String get readerNavigationLayoutDisabled => '';

  @override
  String get readerNavigationLayoutEdge => '';

  @override
  String get readerNavigationLayoutInvert => '';

  @override
  String get readerNavigationLayoutKindlish => '';

  @override
  String get readerNavigationLayoutLShaped => '';

  @override
  String get readerNavigationLayoutRightAndLeft => '';

  @override
  String get readerOverlay => 'Reader initial overlay';

  @override
  String get readerOverlaySubtitle =>
      'Shows title and quick settings when opening a chapter';

  @override
  String get readerPadding => '';

  @override
  String get readerScrollAnimation => '';

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
  String get reddit => '';

  @override
  String get refresh => '';

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
  String get source => '';

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
  String get reset => '';

  @override
  String get restore => 'Restore';

  @override
  String get restoreBackupDescription => '';

  @override
  String get restoreBackupTitle => '';

  @override
  String get restored => '';

  @override
  String get restoring => '';

  @override
  String get resume => '';

  @override
  String get retry => '';

  @override
  String get running => '';

  @override
  String get save => '';

  @override
  String get saveAsCBZArchive => 'Save as CBZ archive';

  @override
  String get scanlators => '';

  @override
  String get search => '';

  @override
  String get searchingForUpdates => '';

  @override
  String get selectInBetween => 'Select in between';

  @override
  String get selectNext10 => 'Select next 10';

  @override
  String get selectUnread => 'Select Unread';

  @override
  String get server => '';

  @override
  String get serverBindings => 'Server Bindings';

  @override
  String get serverPort => '';

  @override
  String get serverPortHintText => '';

  @override
  String get serverUrl => '';

  @override
  String get serverUrlHintText => '';

  @override
  String get serverVersion => '';

  @override
  String get settings => '';

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
  String get sort => '';

  @override
  String get sourceTypeFilter => '';

  @override
  String get sourceTypeLatest => '';

  @override
  String get sourceTypePopular => '';

  @override
  String get sources => '';

  @override
  String get start => '';

  @override
  String get systemTrayIcon => 'Show icon in system tray';

  @override
  String get thatHaventBeenStarted => 'That haven\'t been started';

  @override
  String get themeModeDark => '';

  @override
  String get themeModeLight => '';

  @override
  String get themeModeSystem => '';

  @override
  String get today => 'Today';

  @override
  String get uninstall => '';

  @override
  String get uninstalling => '';

  @override
  String get unknownAuthor => '';

  @override
  String get unknownManga => '';

  @override
  String get unknownSource => '';

  @override
  String get unread => '';

  @override
  String get update => '';

  @override
  String get updateCompleted => '';

  @override
  String updateFailed(Object property) {
    return 'Failed to update $property';
  }

  @override
  String get updates => '';

  @override
  String get updatesSummary => '';

  @override
  String get updating => '';

  @override
  String get userName => '';

  @override
  String get validating => 'Validating';

  @override
  String versionAvailable(String app, String version) {
    return '';
  }

  @override
  String get webUI => '';

  @override
  String get webView => '';

  @override
  String get whatsNew => '';

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
