// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get about => 'Info';

  @override
  String get addCategory => 'Aggiungi Categoria';

  @override
  String get addToLibrary => 'Aggiungi alla libreria';

  @override
  String get advanced => 'Advanced';

  @override
  String get allScanlators => 'Tutti gli scanner';

  @override
  String get appLanguage => 'Lingua dell\'app';

  @override
  String get appTheme => 'Aspetto';

  @override
  String get appTitle => 'Catalyst';

  @override
  String get appearance => 'Aspetto';

  @override
  String get authType => 'Tipo di autenticazione';

  @override
  String get authTypeBasic => 'Autorizzazione di base';

  @override
  String get authTypeNone => 'Nessuno';

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
  String get backup => 'Backup e ripristino';

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
  String get badges => 'Distintivi';

  @override
  String get bookmarked => 'Segnato';

  @override
  String get browse => 'Navigare';

  @override
  String get buildTime => 'Data della build';

  @override
  String get cacheCleared => 'Cache cancellata';

  @override
  String get cancel => 'Annulla';

  @override
  String get categories => 'Categorie';

  @override
  String get categoryUpdate => 'Aggiornamento della categoria';

  @override
  String get channel => 'Canale';

  @override
  String get chapterDownloadLimit => 'Chapter download limit';

  @override
  String get chapterDownloadLimitDesc =>
      'Limit the amount of new chapters that are going to get downloaded.';

  @override
  String chapterNumber(double number) {
    return 'Capitolo$number';
  }

  @override
  String get chapterSortFetchedDate => 'Per data di acquisizione';

  @override
  String get chapterSortSource => 'Per Sorgente';

  @override
  String get chapterSortUploadDate => 'Per data di caricamento';

  @override
  String get checkForServerUpdates => 'Verifica aggiornamenti del server';

  @override
  String get checkForUpdates => 'Controlla aggiornamenti';

  @override
  String get clearCache => 'Cancella la cache';

  @override
  String get client => 'Client';

  @override
  String get clientVersion => 'Versione Client';

  @override
  String get close => 'Chiudi';

  @override
  String get cloudflareBypass => 'Cloudflare Bypass';

  @override
  String get completed => 'Completato';

  @override
  String get copied => 'Copied!';

  @override
  String copyMsg(String msg) {
    return '\'$msg\' Copiati!';
  }

  @override
  String get createBackupDescription =>
      'Backup della libreria come backup Tachidesk';

  @override
  String get createBackupTitle => 'Crea backup';

  @override
  String get credentials => 'Credenziali';

  @override
  String get current => 'Attuale';

  @override
  String daysAgo(Object days) {
    return '$days giorni fa';
  }

  @override
  String get debugLogs => 'Debug logs';

  @override
  String get defaultCategory =>
      'Categoria predefinita quando si aggiungono nuovi manga alla libreria';

  @override
  String get delete => 'Cancella';

  @override
  String get deleteCategoryDescription =>
      'Questo unirà tutti i Manga di questa categoria per impostazione predefinita!';

  @override
  String get deleteCategoryTitle => 'Sei sicuro?';

  @override
  String get discord => 'Discord';

  @override
  String get display => 'Display';

  @override
  String get displayMode => 'Modalità di visualizzazione';

  @override
  String get displayModeDescriptiveList => 'Elenco descrittivo';

  @override
  String get displayModeGrid => 'Griglia';

  @override
  String get displayModeList => 'Lista';

  @override
  String get downloadLocation => 'Download location';

  @override
  String get downloadLocationHint =>
      'The path to the directory on the server where downloaded files should get saved in';

  @override
  String get downloaded => 'Scaricati';

  @override
  String get downloading => 'Downloading';

  @override
  String get downloads => 'Downloads';

  @override
  String get edit => 'Modifica';

  @override
  String get editCategory => 'Modifica Categoria';

  @override
  String get emptyCategory => 'Il nome della categoria non può essere vuoto';

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
  String get errorExtension => 'Impossibile trovare l\'estensione selezionata';

  @override
  String get errorFilePick => 'File non selezionato!';

  @override
  String errorFilePickUnknownExtension(Object extensionName) {
    return 'Selezionare un file con estensione $extensionName';
  }

  @override
  String errorLaunchURL(String url) {
    return 'Apertura fallita!\nCopia di \"$url\" negli appunti';
  }

  @override
  String get errorPassword => 'La password non può essere vuota';

  @override
  String get errorSomethingWentWrong => 'Qualcosa è andato storto!';

  @override
  String get errorUserName => 'Il nome utente non può essere vuoto';

  @override
  String get excludeEntryWithUnreadChapters =>
      'Ignore automatic chapter downloads for entries with unread chapters';

  @override
  String get extensionInstalled => 'Estensione installata!';

  @override
  String get extensionListEmpty => 'L\'elenco delle estensioni è vuoto';

  @override
  String get extensionRepository => 'Extension Repository';

  @override
  String get extensionRepositoryDescription =>
      'Add repositories from which extensions can be installed';

  @override
  String get extensions => 'Estensioni';

  @override
  String get failed => 'Fallito';

  @override
  String get filter => 'Filtro';

  @override
  String get findServer => 'Trova';

  @override
  String get finished => 'Finito';

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
  String get general => 'Generale';

  @override
  String get gitHub => 'GitHub';

  @override
  String get globalSearch => 'Ricerca globale';

  @override
  String get globalUpdate => 'Aggiornamento globale';

  @override
  String get gqlDebugLogs => 'Graphql debug logs';

  @override
  String get gqlDebugLogsHint =>
      'This includes logs with non privacy safe information';

  @override
  String get help => 'Aiuto';

  @override
  String get hideEmptyCategory => 'Hide Empty Category';

  @override
  String get inLibrary => 'In biblioteca';

  @override
  String get includeCategories => 'Categories';

  @override
  String get includeChapters => 'Chapters';

  @override
  String get install => 'Installare';

  @override
  String get installing => 'Installazione';

  @override
  String get installingExtension => 'Installazione dell\'estensione';

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
  String get isTrueBlack => 'Nero vero';

  @override
  String get languages => 'Lingue';

  @override
  String get latest => 'Ultime novità';

  @override
  String get library => 'Biblioteca';

  @override
  String get localSourceLocation => 'Local source location';

  @override
  String get localSourceLocationDescription =>
      'The path to the directory on the server where local source files are saved in';

  @override
  String get manga => 'Manga';

  @override
  String get mangaGridSize => 'Dimensione della griglia Manga';

  @override
  String get mangaMissingSources => 'Fonti Manga mancanti';

  @override
  String get mangaSortAlphabetical => 'In ordine alfabetico';

  @override
  String get mangaSortDateAdded => 'Data aggiunta';

  @override
  String get mangaSortLastRead => 'Ultima lettura';

  @override
  String get mangaSortLastUpdated => 'Last Updated';

  @override
  String get mangaSortUnread => 'Non letto';

  @override
  String get mangaStatusCancelled => 'Annullato';

  @override
  String get mangaStatusCompleted => 'Completato';

  @override
  String get mangaStatusLicensed => 'Licenza';

  @override
  String get mangaStatusOnHiatus => 'In pausa';

  @override
  String get mangaStatusOngoing => 'In corso';

  @override
  String get mangaStatusPublishingFinished => 'Pubblicazione finita';

  @override
  String get mangaStatusUnknown => 'Sconosciuto';

  @override
  String get misc => 'Misc';

  @override
  String get missingExtension => 'Estensioni mancanti';

  @override
  String get missingTrackers => 'Tracciatori mancanti';

  @override
  String get more => 'Di più';

  @override
  String get moveToBottom => 'Vai in basso';

  @override
  String get moveToTop => 'Vai all\'inizio';

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
  String get newUpdateAvailable => 'Nuovo aggiornamento disponibile';

  @override
  String nextChapter(Object chapterTitle) {
    return 'Prossimo: $chapterTitle';
  }

  @override
  String get noCategoriesFound =>
      'Non ci sono categorie. \n(Suggerimento: toccare il pulsante Più per crearne una per organizzare la libreria)';

  @override
  String get noCategoriesFoundAlt =>
      'Non ci sono categorie. \nCreatene una nelle impostazioni per organizzare la tua libreria';

  @override
  String get noCategoryMangaFound =>
      'Nessun manga trovato in questa categoria. \n(Suggerimento: controllare la ricerca e i filtri!)';

  @override
  String get noChaptersFound => 'Nessun capitolo trovato';

  @override
  String get noDownloads => 'Nessun download';

  @override
  String get noMangaFound => 'Nessun Manga trovato';

  @override
  String noOfChapters(int count) {
    return '$count Capitoli';
  }

  @override
  String noPropFound(Object prop) {
    return 'No $prop Found';
  }

  @override
  String get noResultFound => 'Nessun risultato trovato';

  @override
  String get noServerFound => 'Nessun server trovato nella rete locale';

  @override
  String get noSourcesFound => 'Nessuna fonte trovata';

  @override
  String get noUpdatesAvailable => 'Stai utilizzando l\'ultima versione';

  @override
  String get noUpdatesFound => 'Nessun aggiornamento trovato';

  @override
  String get none => 'None';

  @override
  String get nsfw => 'Mostra estensioni e fonti NSFW';

  @override
  String get nsfw18 => '18+';

  @override
  String get nsfwInfo =>
      'Questo non impedisce alle estensioni non ufficiali o potenzialmente contrassegnate in modo errato di visualizzare contenuti NSFW (18+) all\'interno dell\'applicazione';

  @override
  String numSelected(int num) {
    return '$num Selezionati';
  }

  @override
  String get obsolete => 'Obsoleto';

  @override
  String get openFlareSolverr =>
      'Checkout FlareSolverr for information on how to set it up';

  @override
  String get openInWeb => 'Open In Web';

  @override
  String get or => 'or';

  @override
  String page(int number) {
    return 'Pagina: $number';
  }

  @override
  String get parallelSourceRequest => 'Parallel source requests';

  @override
  String get password => 'Password';

  @override
  String get pause => 'Pausa';

  @override
  String get pending => 'In attesa';

  @override
  String get pinchToZoom => 'Pizzica per ingrandire';

  @override
  String previousChapter(Object chapterTitle) {
    return 'Precedente: $chapterTitle';
  }

  @override
  String get queued => 'Queued';

  @override
  String get quickSearch => 'Ricerca rapida';

  @override
  String get quickSearchCategory => 'Vai alla categoria \'C\'';

  @override
  String get quickSearchCategoryManga =>
      'Vai a Manga \'M\' nella Categoria \'C\'';

  @override
  String get quickSearchCategoryMangaChapter =>
      'Vai al nome del capitolo \"CN\" dal manga \"M\" nella categoria \"C\"';

  @override
  String get quickSearchContext =>
      'Ricerca della query X (i risultati sono basati sul contesto dello schermo)';

  @override
  String get quickSearchShowAllCommandTip =>
      'Suggerimento: immettere \'?\' per visualizzare tutti i comandi';

  @override
  String get quickSearchSource => 'Vai alla sorgente \'S\'';

  @override
  String get quickSearchSourceManga => 'Ricerca del Manga \'M\' in Fonte \'S\'';

  @override
  String get reader => 'Lettore';

  @override
  String get readerMagnifierSize => 'Dimensioni della lente d\'ingrandimento';

  @override
  String get readerMode => 'Modalità di lettura';

  @override
  String get readerModeContinuousHorizontalLTR => 'Orizzontale continuo (LTR)';

  @override
  String get readerModeContinuousHorizontalRTL => 'Orizzontale continuo (RTL)';

  @override
  String get readerModeContinuousVertical => 'Verticale continuo';

  @override
  String get readerModeDefaultReader => 'Predefinito';

  @override
  String get readerModeSingleHorizontalLTR => 'Singolo orizzontale (LTR)';

  @override
  String get readerModeSingleHorizontalRTL => 'Singolo orizzontale (RTL)';

  @override
  String get readerModeSingleVertical => 'Singolo verticale';

  @override
  String get readerModeWebtoon => 'Webtoon';

  @override
  String get readerNavigationLayout => 'Layout di navigazione';

  @override
  String get readerNavigationLayoutDefault => 'Predefinito';

  @override
  String get readerNavigationLayoutDisabled => 'Disabilitato';

  @override
  String get readerNavigationLayoutEdge => 'Bordo';

  @override
  String get readerNavigationLayoutInvert => 'Invertire il tapping';

  @override
  String get readerNavigationLayoutKindlish => 'tipo Kindle';

  @override
  String get readerNavigationLayoutLShaped => 'A forma di L';

  @override
  String get readerNavigationLayoutRightAndLeft => 'Destra e sinistra';

  @override
  String get readerOverlay => 'Sovrapposizione iniziale del lettore';

  @override
  String get readerOverlaySubtitle =>
      'Mostra il titolo e le impostazioni rapide quando si apre un capitolo';

  @override
  String get readerPadding => 'Padding del lettore';

  @override
  String get readerScrollAnimation => 'Animazione di scorrimento';

  @override
  String get readerSwipeChapterToggle => 'Swipe per attivare/disattivare';

  @override
  String get readerSwipeChapterToggleDescription =>
      'Swipe per cambiare capitolo nel lettore';

  @override
  String get readerLastPageSwipeToggle => 'Last page swipe';

  @override
  String get readerLastPageSwipeToggleDescription =>
      'Swipe to next chapter only at last page';

  @override
  String get readerVolumeTap => 'Tasti del volume';

  @override
  String get readerVolumeTapInvert => 'Invertire i tasti del volume';

  @override
  String get readerVolumeTapSubtitle => 'Navigazione con i tasti del volume';

  @override
  String get readerIgnoreSafeAreaToggle => 'Ignore Safe Area';

  @override
  String get readerIgnoreSafeAreaToggleDescription =>
      'Allow content to extend into notch and home indicator areas';

  @override
  String get reddit => 'Reddit';

  @override
  String get refresh => 'Aggiorna';

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
  String get source => 'Fonte';

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
  String get reload => 'Ricarica';

  @override
  String get remove => 'Rimuovi';

  @override
  String get removeFromLibrary => 'Rimuovere dalla biblioteca?';

  @override
  String get reset => 'Reset';

  @override
  String get restore => 'Restore';

  @override
  String get restoreBackupDescription => 'Ripristina Tachidesk dal backup';

  @override
  String get restoreBackupTitle => 'Ripristina backup';

  @override
  String get restored => 'Backup ripristinato!';

  @override
  String get restoring => 'Ripristino del backup';

  @override
  String get resume => 'Riprendere';

  @override
  String get retry => 'Riprova';

  @override
  String get running => 'In esecuzione';

  @override
  String get save => 'Salva';

  @override
  String get saveAsCBZArchive => 'Save as CBZ archive';

  @override
  String get scanlators => 'scanner';

  @override
  String get search => 'Cerca';

  @override
  String get searchingForUpdates => 'Ricerca degli aggiornamenti';

  @override
  String get selectInBetween => 'Selezionare tra';

  @override
  String get selectNext10 => 'Seleziona i prossimi 10';

  @override
  String get selectUnread => 'Seleziona non letti';

  @override
  String get server => 'Server';

  @override
  String get serverBindings => 'Server Bindings';

  @override
  String get serverPort => 'Porta del Server';

  @override
  String get serverPortHintText => 'Porta del server';

  @override
  String get serverUrl => 'URL del Server';

  @override
  String get serverUrlHintText => 'URL del server';

  @override
  String get serverVersion => 'Versione del server';

  @override
  String get settings => 'Impostazioni';

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
  String get sort => 'Ordinamento';

  @override
  String get sourceTypeFilter => 'Filtro';

  @override
  String get sourceTypeLatest => 'Ultimo';

  @override
  String get sourceTypePopular => 'Popolare';

  @override
  String get sources => 'Fonti';

  @override
  String get start => 'Inizio';

  @override
  String get systemTrayIcon => 'Show icon in system tray';

  @override
  String get thatHaventBeenStarted => 'That haven\'t been started';

  @override
  String get themeModeDark => 'Scuro';

  @override
  String get themeModeLight => 'Chiaro';

  @override
  String get themeModeSystem => 'Sistema';

  @override
  String get today => 'Oggi';

  @override
  String get uninstall => 'Disinstalla';

  @override
  String get uninstalling => 'Disinstallazione';

  @override
  String get unknownAuthor => 'Autore sconosciuto';

  @override
  String get unknownManga => 'Manga sconosciuto';

  @override
  String get unknownSource => 'Fonte sconosciuta';

  @override
  String get unread => 'Non letto';

  @override
  String get update => 'Aggiornamento';

  @override
  String get updateCompleted => 'Aggiornamento completato';

  @override
  String updateFailed(Object property) {
    return 'Failed to update $property';
  }

  @override
  String get updates => 'Aggiornamenti';

  @override
  String get updatesSummary => 'Sintesi degli aggiornamenti';

  @override
  String get updating => 'Aggiornando';

  @override
  String get userName => 'Nome utente';

  @override
  String get validating => 'Validating';

  @override
  String versionAvailable(String app, String version) {
    return 'Versione $version disponibile per $app!!';
  }

  @override
  String get webUI => 'Apri nel WEB';

  @override
  String get webView => 'Vista Web';

  @override
  String get whatsNew => 'Cosa c\'è di nuovo?';

  @override
  String get withCompletedStatus => 'With Completed status';

  @override
  String get withUnreadChapter => 'With unread chapter(s)';

  @override
  String get yesterday => 'Ieri';

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
