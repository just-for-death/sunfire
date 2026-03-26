// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get about => 'À propos';

  @override
  String get addCategory => 'Ajouter une catégorie';

  @override
  String get addToLibrary => 'Ajouter à la bibliothèque';

  @override
  String get advanced => 'Advanced';

  @override
  String get allScanlators => 'Tous les Scanlators';

  @override
  String get appLanguage => 'Langue de l\'application';

  @override
  String get appTheme => 'Thème de l\'application';

  @override
  String get appTitle => 'Catalyst';

  @override
  String get appearance => 'Apparence';

  @override
  String get authType => 'Type d\'authentification';

  @override
  String get authTypeBasic => 'Authentification simple';

  @override
  String get authTypeNone => 'Aucune';

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
  String get backup => 'Sauvegarde et restauration';

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
  String get badges => 'Badges';

  @override
  String get bookmarked => 'Marque-pages';

  @override
  String get browse => 'Parcourir';

  @override
  String get buildTime => 'Temps d\'exécution';

  @override
  String get cacheCleared => 'Cache effacé';

  @override
  String get cancel => 'Annuler';

  @override
  String get categories => 'Catégories';

  @override
  String get categoryUpdate => 'Mise à jour de la catégorie';

  @override
  String get channel => 'Canal';

  @override
  String get chapterDownloadLimit => 'Chapter download limit';

  @override
  String get chapterDownloadLimitDesc =>
      'Limit the amount of new chapters that are going to get downloaded.';

  @override
  String chapterNumber(double number) {
    return 'Chapitre $number';
  }

  @override
  String get chapterSortFetchedDate => 'Par date de récupération';

  @override
  String get chapterSortSource => 'Par source';

  @override
  String get chapterSortUploadDate => 'Par date d\'import';

  @override
  String get checkForServerUpdates => 'Vérifier les mises à jour du serveur';

  @override
  String get checkForUpdates => 'Vérifier les mises à jour';

  @override
  String get clearCache => 'Effacer le cache';

  @override
  String get client => 'Client';

  @override
  String get clientVersion => 'Version du client';

  @override
  String get close => 'Fermer';

  @override
  String get cloudflareBypass => 'Cloudflare Bypass';

  @override
  String get completed => 'Terminé';

  @override
  String get copied => 'Copied!';

  @override
  String copyMsg(String msg) {
    return '« $msg » copié !';
  }

  @override
  String get createBackupDescription =>
      'Sauvegarder la bibliothèque en tant que sauvegarde Tachidesk';

  @override
  String get createBackupTitle => 'Créer une sauvegarde';

  @override
  String get credentials => 'Identifiants';

  @override
  String get current => 'En cours';

  @override
  String daysAgo(Object days) {
    return 'Il y a $days jours';
  }

  @override
  String get debugLogs => 'Debug logs';

  @override
  String get defaultCategory =>
      'Catégorie par défaut lors de l\'ajout d\'un nouveau manga à la bibliothèque';

  @override
  String get delete => 'Supprimer';

  @override
  String get deleteCategoryDescription =>
      'Tous les mangas de cette catégorie seront ainsi ramenés à leur valeur par défaut !';

  @override
  String get deleteCategoryTitle => 'Voulez-vous continuer ?';

  @override
  String get discord => 'Discord';

  @override
  String get display => 'Affichage';

  @override
  String get displayMode => 'Mode d\'affichage';

  @override
  String get displayModeDescriptiveList => 'Liste descriptive';

  @override
  String get displayModeGrid => 'Grille';

  @override
  String get displayModeList => 'Liste';

  @override
  String get downloadLocation => 'Download location';

  @override
  String get downloadLocationHint =>
      'The path to the directory on the server where downloaded files should get saved in';

  @override
  String get downloaded => 'Téléchargé';

  @override
  String get downloading => 'Downloading';

  @override
  String get downloads => 'Téléchargements';

  @override
  String get edit => 'Modifier';

  @override
  String get editCategory => 'Modifier la catégorie';

  @override
  String get emptyCategory => 'Le nom de la catégorie ne peut pas être vide';

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
  String get errorExtension =>
      'Impossible de trouver l\'extension sélectionnée';

  @override
  String get errorFilePick => 'Aucun fichier sélectionné !';

  @override
  String errorFilePickUnknownExtension(Object extensionName) {
    return 'Veuillez sélectionner un fichier avec l\'extension $extensionName';
  }

  @override
  String errorLaunchURL(String url) {
    return 'Échec de l\'ouverture !\nCopie de « $url » dans le presse-papier';
  }

  @override
  String get errorPassword => 'Le mot de passe ne peut pas être vide';

  @override
  String get errorSomethingWentWrong => 'Une erreur s\'est produite !';

  @override
  String get errorUserName => 'Le nom d\'utilisateur ne peut pas être vide';

  @override
  String get excludeEntryWithUnreadChapters =>
      'Ignore automatic chapter downloads for entries with unread chapters';

  @override
  String get extensionInstalled => 'Extension installée !';

  @override
  String get extensionListEmpty => 'La liste des extensions est vide';

  @override
  String get extensionRepository => 'Extension Repository';

  @override
  String get extensionRepositoryDescription =>
      'Add repositories from which extensions can be installed';

  @override
  String get extensions => 'Extensions';

  @override
  String get failed => 'Échec';

  @override
  String get filter => 'Filtrer';

  @override
  String get findServer => 'Trouver';

  @override
  String get finished => 'Terminé';

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
  String get general => 'Général';

  @override
  String get gitHub => 'GitHub';

  @override
  String get globalSearch => 'Recherche globale';

  @override
  String get globalUpdate => 'Mise à jour globale';

  @override
  String get gqlDebugLogs => 'Graphql debug logs';

  @override
  String get gqlDebugLogsHint =>
      'This includes logs with non privacy safe information';

  @override
  String get help => 'Aide';

  @override
  String get hideEmptyCategory => 'Hide Empty Category';

  @override
  String get inLibrary => 'Dans la bibliothèque';

  @override
  String get includeCategories => 'Categories';

  @override
  String get includeChapters => 'Chapters';

  @override
  String get install => 'Installer';

  @override
  String get installing => 'Installation';

  @override
  String get installingExtension => 'Installation de l\'extension';

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
  String get isTrueBlack => 'Noir véritable';

  @override
  String get languages => 'Langues';

  @override
  String get latest => 'Le plus récent';

  @override
  String get library => 'Bibliothèque';

  @override
  String get localSourceLocation => 'Local source location';

  @override
  String get localSourceLocationDescription =>
      'The path to the directory on the server where local source files are saved in';

  @override
  String get manga => 'Manga';

  @override
  String get mangaGridSize => 'Taille de la grille des mangas';

  @override
  String get mangaMissingSources => 'Sources manquantes des mangas';

  @override
  String get mangaSortAlphabetical => 'Ordre alphabétique';

  @override
  String get mangaSortDateAdded => 'Date d\'ajout';

  @override
  String get mangaSortLastRead => 'Date de lecture';

  @override
  String get mangaSortLastUpdated => 'Last Updated';

  @override
  String get mangaSortUnread => 'Non lu';

  @override
  String get mangaStatusCancelled => 'Annulé';

  @override
  String get mangaStatusCompleted => 'Terminé';

  @override
  String get mangaStatusLicensed => 'Sous licence';

  @override
  String get mangaStatusOnHiatus => 'En suspens';

  @override
  String get mangaStatusOngoing => 'En cours';

  @override
  String get mangaStatusPublishingFinished => 'Publication terminée';

  @override
  String get mangaStatusUnknown => 'Inconnu';

  @override
  String get misc => 'Misc';

  @override
  String get missingExtension => 'Extensions manquantes';

  @override
  String get missingTrackers => 'Pisteurs manquants';

  @override
  String get more => 'Plus';

  @override
  String get moveToBottom => 'Déplacer vers le bas';

  @override
  String get moveToTop => 'Déplacer vers le haut';

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
    return '$name : $count';
  }

  @override
  String get newUpdateAvailable => 'Nouvelle mise à jour disponible';

  @override
  String nextChapter(Object chapterTitle) {
    return 'Suivant : $chapterTitle';
  }

  @override
  String get noCategoriesFound =>
      'Vous n\'avez aucune catégorie. \n(Conseil : Appuyez sur le bouton Plus pour en créer une et organiser votre bibliothèque)';

  @override
  String get noCategoriesFoundAlt =>
      'Vous n\'avez aucune catégorie. \nCréez-en une dans les paramètres pour organiser votre bibliothèque';

  @override
  String get noCategoryMangaFound =>
      'Aucun manga trouvé dans cette catégorie. \n(Conseil : Vérifiez votre recherche et vos filtres !)';

  @override
  String get noChaptersFound => 'Aucun chapitre trouvé';

  @override
  String get noDownloads => 'Aucun téléchargement';

  @override
  String get noMangaFound => 'Aucun manga trouvé';

  @override
  String noOfChapters(int count) {
    return '$count chapitres';
  }

  @override
  String noPropFound(Object prop) {
    return 'No $prop Found';
  }

  @override
  String get noResultFound => 'Aucun résultat trouvé';

  @override
  String get noServerFound => 'Aucun serveur trouvé sur votre réseau local';

  @override
  String get noSourcesFound => 'Aucune source trouvée';

  @override
  String get noUpdatesAvailable => 'Vous utilisez la dernière version';

  @override
  String get noUpdatesFound => 'Aucune mise à jour disponible';

  @override
  String get none => 'None';

  @override
  String get nsfw =>
      'Afficher les extensions et les sources comportant du contenu explicite';

  @override
  String get nsfw18 => '18+';

  @override
  String get nsfwInfo =>
      'Cela n\'empêche pas les extensions non officielles ou potentiellement signalées de manière incorrecte de faire apparaître du contenu explicite (18+) dans l\'application';

  @override
  String numSelected(int num) {
    return '$num sélectionné';
  }

  @override
  String get obsolete => 'Obsolète';

  @override
  String get openFlareSolverr =>
      'Checkout FlareSolverr for information on how to set it up';

  @override
  String get openInWeb => 'Open In Web';

  @override
  String get or => 'or';

  @override
  String page(int number) {
    return 'Page : $number';
  }

  @override
  String get parallelSourceRequest => 'Parallel source requests';

  @override
  String get password => 'Mot de passe';

  @override
  String get pause => 'Mettre en pause';

  @override
  String get pending => 'En attente';

  @override
  String get pinchToZoom => 'Pincer pour zoomer';

  @override
  String previousChapter(Object chapterTitle) {
    return 'Précédent : $chapterTitle';
  }

  @override
  String get queued => 'Queued';

  @override
  String get quickSearch => 'Recherche rapide';

  @override
  String get quickSearchCategory => 'Aller à la catégorie \'C\'';

  @override
  String get quickSearchCategoryManga =>
      'Aller au Manga \'M\' dans la catégorie \'C\'';

  @override
  String get quickSearchCategoryMangaChapter =>
      'Aller au chapitre \'CN\' du manga \'M\' dans la catégorie \'C\'';

  @override
  String get quickSearchContext =>
      'Rechercher la requête X (Les résultats sont basés sur le contexte de l\'écran)';

  @override
  String get quickSearchShowAllCommandTip =>
      'Astuce : Entrez \'?\' pour voir toutes les commandes';

  @override
  String get quickSearchSource => 'Aller à la source \'S\'';

  @override
  String get quickSearchSourceManga =>
      'Rechercher le manga \'M\' dans la source \'S\'';

  @override
  String get reader => 'Lecteur';

  @override
  String get readerMagnifierSize => 'Taille de la loupe';

  @override
  String get readerMode => 'Mode de lecture';

  @override
  String get readerModeContinuousHorizontalLTR =>
      'Horizontal en continu (De gauche à droite)';

  @override
  String get readerModeContinuousHorizontalRTL =>
      'Horizontal en continu (De droite à gauche)';

  @override
  String get readerModeContinuousVertical => 'Vertical en continu';

  @override
  String get readerModeDefaultReader => 'Par défaut';

  @override
  String get readerModeSingleHorizontalLTR =>
      'Horizontal simple (De gauche à droite)';

  @override
  String get readerModeSingleHorizontalRTL =>
      'Horizontal simple (De droite à gauche)';

  @override
  String get readerModeSingleVertical => 'Vertical simple';

  @override
  String get readerModeWebtoon => 'Webtoon';

  @override
  String get readerNavigationLayout => 'Disposition de la navigation';

  @override
  String get readerNavigationLayoutDefault => 'Par défaut';

  @override
  String get readerNavigationLayoutDisabled => 'Désactivée';

  @override
  String get readerNavigationLayoutEdge => 'Bord';

  @override
  String get readerNavigationLayoutInvert => 'Inverser le toucher';

  @override
  String get readerNavigationLayoutKindlish => 'Façon Kindle';

  @override
  String get readerNavigationLayoutLShaped => 'En forme de L';

  @override
  String get readerNavigationLayoutRightAndLeft => 'À droite et à gauche';

  @override
  String get readerOverlay => 'Superposition initiale du lecteur';

  @override
  String get readerOverlaySubtitle =>
      'Affiche le titre et les paramètres rapides lors de l\'ouverture d\'un chapitre';

  @override
  String get readerPadding => 'Marges du lecteur';

  @override
  String get readerScrollAnimation => 'Animation de défilement';

  @override
  String get readerSwipeChapterToggle =>
      'Activer/désactiver le défilement par balayage';

  @override
  String get readerSwipeChapterToggleDescription =>
      'Activer/désactiver le changement de chapitre par balayage';

  @override
  String get readerLastPageSwipeToggle => 'Last page swipe';

  @override
  String get readerLastPageSwipeToggleDescription =>
      'Swipe to next chapter only at last page';

  @override
  String get readerVolumeTap => 'Touches des boutons de volume';

  @override
  String get readerVolumeTapInvert => 'Inverser les touches de volume';

  @override
  String get readerVolumeTapSubtitle => 'Naviguer avec les touches de volume';

  @override
  String get readerIgnoreSafeAreaToggle => 'Ignore Safe Area';

  @override
  String get readerIgnoreSafeAreaToggleDescription =>
      'Allow content to extend into notch and home indicator areas';

  @override
  String get reddit => 'Reddit';

  @override
  String get refresh => 'Actualiser';

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
  String get reload => 'Recharger';

  @override
  String get remove => 'Supprimer';

  @override
  String get removeFromLibrary => 'Supprimer de la bibliothèque ?';

  @override
  String get reset => 'Réinitialiser';

  @override
  String get restore => 'Restore';

  @override
  String get restoreBackupDescription =>
      'Restaurer Tachidesk à partir d\'une sauvegarde';

  @override
  String get restoreBackupTitle => 'Restaurer la sauvegarde';

  @override
  String get restored => 'La sauvegarde a été restaurée !';

  @override
  String get restoring => 'Restauration de la sauvegarde';

  @override
  String get resume => 'Reprendre';

  @override
  String get retry => 'Réessayer';

  @override
  String get running => 'En cours';

  @override
  String get save => 'Enregistrer';

  @override
  String get saveAsCBZArchive => 'Save as CBZ archive';

  @override
  String get scanlators => 'Scanlators';

  @override
  String get search => 'Rechercher';

  @override
  String get searchingForUpdates => 'Recherche de mises à jour';

  @override
  String get selectInBetween => 'Sélectionner entre les deux';

  @override
  String get selectNext10 => 'Sélectionner les 10 suivants';

  @override
  String get selectUnread => 'Sélectionner les non lus';

  @override
  String get server => 'Serveur';

  @override
  String get serverBindings => 'Server Bindings';

  @override
  String get serverPort => 'Port du serveur';

  @override
  String get serverPortHintText => 'Port du serveur';

  @override
  String get serverUrl => 'URL du serveur';

  @override
  String get serverUrlHintText => 'URL du serveur';

  @override
  String get serverVersion => 'Version du serveur';

  @override
  String get settings => 'Paramètres';

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
  String get sort => 'Trier';

  @override
  String get sourceTypeFilter => 'Filtrer';

  @override
  String get sourceTypeLatest => 'Le plus récent';

  @override
  String get sourceTypePopular => 'Populaire';

  @override
  String get sources => 'Sources';

  @override
  String get start => 'Commencer';

  @override
  String get systemTrayIcon => 'Show icon in system tray';

  @override
  String get thatHaventBeenStarted => 'That haven\'t been started';

  @override
  String get themeModeDark => 'Sombre';

  @override
  String get themeModeLight => 'Clair';

  @override
  String get themeModeSystem => 'Système';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get uninstall => 'Désinstaller';

  @override
  String get uninstalling => 'Désinstallation';

  @override
  String get unknownAuthor => 'Auteur inconnu';

  @override
  String get unknownManga => 'Manga inconnu';

  @override
  String get unknownSource => 'Source inconnue';

  @override
  String get unread => 'Non lu';

  @override
  String get update => 'Mettre à jour';

  @override
  String get updateCompleted => 'Mise à jour terminée';

  @override
  String updateFailed(Object property) {
    return 'Failed to update $property';
  }

  @override
  String get updates => 'Mises à jour';

  @override
  String get updatesSummary => 'Récapitulatif des mises à jour';

  @override
  String get updating => 'Mise à jour en cours';

  @override
  String get userName => 'Nom d\'utilisateur';

  @override
  String get validating => 'Validating';

  @override
  String versionAvailable(String app, String version) {
    return 'Version $version disponible pour l\'application $app !';
  }

  @override
  String get webUI => 'Ouvrir sur le Web';

  @override
  String get webView => 'Vue Web';

  @override
  String get whatsNew => 'Quoi de neuf ?';

  @override
  String get withCompletedStatus => 'With Completed status';

  @override
  String get withUnreadChapter => 'With unread chapter(s)';

  @override
  String get yesterday => 'Hier';

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

  @override
  String get mangaComparison => 'Manga Comparison';

  @override
  String get migrationFromLabel => 'From (Current)';

  @override
  String get migrationToLabel => 'To (Target)';

  @override
  String get comparisonSummary => 'Comparison Summary';

  @override
  String byAuthor(String author) {
    return 'by $author';
  }

  @override
  String get migrationSummaryTitle => 'Migration Summary';

  @override
  String migratedFromManga(String title) {
    return 'Migrated from: $title';
  }

  @override
  String migratedToManga(String title) {
    return 'Migrated to: $title';
  }

  @override
  String migrationSourceLabel(String name) {
    return 'Source: $name';
  }

  @override
  String get selectSource => 'Select Source';

  @override
  String get selectManga => 'Select Manga';
}
