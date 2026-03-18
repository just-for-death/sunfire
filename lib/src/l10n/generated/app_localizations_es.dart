// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get about => 'Acerca de';

  @override
  String get addCategory => 'Añadir categoría';

  @override
  String get addToLibrary => 'Añadir a la biblioteca';

  @override
  String get advanced => 'Advanced';

  @override
  String get allScanlators => 'Todos los escáneres';

  @override
  String get appLanguage => 'Idioma de la aplicación';

  @override
  String get appTheme => 'Modo tema de la aplicación';

  @override
  String get appTitle => 'Catalyst';

  @override
  String get appearance => 'Apariencia';

  @override
  String get authType => 'Tipo de autenticación';

  @override
  String get authTypeBasic => 'Autenticación normal';

  @override
  String get authTypeNone => 'Ninguna';

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
  String get backup => 'Copia de seguridad y restauración';

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
  String get badges => 'Insignias';

  @override
  String get bookmarked => 'Favoritos';

  @override
  String get browse => 'Explorar';

  @override
  String get buildTime => 'Fecha de creación';

  @override
  String get cacheCleared => 'Caché borrada';

  @override
  String get cancel => 'Cancelar';

  @override
  String get categories => 'Categorías';

  @override
  String get categoryUpdate => 'Actualizar categoría';

  @override
  String get channel => 'Canal';

  @override
  String get chapterDownloadLimit => 'Chapter download limit';

  @override
  String get chapterDownloadLimitDesc =>
      'Limit the amount of new chapters that are going to get downloaded.';

  @override
  String chapterNumber(double number) {
    return 'Capítulo $number';
  }

  @override
  String get chapterSortFetchedDate => 'Por fecha de búsqueda';

  @override
  String get chapterSortSource => 'Por fuente';

  @override
  String get chapterSortUploadDate => 'Por fecha de subida';

  @override
  String get checkForServerUpdates => 'Buscar actualización del servidor';

  @override
  String get checkForUpdates => 'Buscar actualizaciones';

  @override
  String get clearCache => 'Borrar la caché';

  @override
  String get client => 'Cliente';

  @override
  String get clientVersion => 'Versión del cliente';

  @override
  String get close => 'Cerrar';

  @override
  String get cloudflareBypass => 'Cloudflare Bypass';

  @override
  String get completed => 'Completado';

  @override
  String get copied => 'Copied!';

  @override
  String copyMsg(String msg) {
    return '\'$msg\' ¡Copiado!';
  }

  @override
  String get createBackupDescription =>
      'Copia de seguridad de biblioteca como copia de seguridad de Tachidesk';

  @override
  String get createBackupTitle => 'Crear copia de seguridad';

  @override
  String get credentials => 'Credenciales';

  @override
  String get current => 'Actual';

  @override
  String daysAgo(Object days) {
    return 'Hace $days días';
  }

  @override
  String get debugLogs => 'Debug logs';

  @override
  String get defaultCategory =>
      'Categoría predeterminada al añadir un nuevo manga a la biblioteca';

  @override
  String get delete => 'Eliminar';

  @override
  String get deleteCategoryDescription =>
      '¡Esto quitará todos los mangas de esta categoría y los añadirá en predeterminado!';

  @override
  String get deleteCategoryTitle => '¿Estás seguro?';

  @override
  String get discord => 'Discord';

  @override
  String get display => 'Vista';

  @override
  String get displayMode => 'Modo de visualización';

  @override
  String get displayModeDescriptiveList => 'Lista descriptiva';

  @override
  String get displayModeGrid => 'Cuadrícula';

  @override
  String get displayModeList => 'Lista';

  @override
  String get downloadLocation => 'Download location';

  @override
  String get downloadLocationHint =>
      'The path to the directory on the server where downloaded files should get saved in';

  @override
  String get downloaded => 'Descargados';

  @override
  String get downloading => 'Downloading';

  @override
  String get downloads => 'Descargas';

  @override
  String get edit => 'Editar';

  @override
  String get editCategory => 'Editar categoría';

  @override
  String get emptyCategory => 'El nombre de la categoría no puede estar vacío';

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
  String get errorExtension => 'No se encontró la extensión seleccionada';

  @override
  String get errorFilePick => '¡Archivo no seleccionado!';

  @override
  String errorFilePickUnknownExtension(Object extensionName) {
    return '¡Por favor, selecciona un archivo con la extensión $extensionName';
  }

  @override
  String errorLaunchURL(String url) {
    return '¡Error al abrir!\nCopiando \"$url\" al portapapeles';
  }

  @override
  String get errorPassword => 'La contraseña no puede estar en blanco';

  @override
  String get errorSomethingWentWrong => '¡Algo salió mal!';

  @override
  String get errorUserName => 'El nombre de usuario no puede estar en blanco';

  @override
  String get excludeEntryWithUnreadChapters =>
      'Ignore automatic chapter downloads for entries with unread chapters';

  @override
  String get extensionInstalled => '¡La extensión ha sido instalada!';

  @override
  String get extensionListEmpty => 'La lista de extensiones está vacía';

  @override
  String get extensionRepository => 'Extension Repository';

  @override
  String get extensionRepositoryDescription =>
      'Add repositories from which extensions can be installed';

  @override
  String get extensions => 'Extensiones';

  @override
  String get failed => 'Fallido';

  @override
  String get filter => 'Filtro';

  @override
  String get findServer => 'Encontrar';

  @override
  String get finished => 'Finalizado';

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
  String get general => 'General';

  @override
  String get gitHub => 'GitHub';

  @override
  String get globalSearch => 'Búsqueda global';

  @override
  String get globalUpdate => 'Actualización global';

  @override
  String get gqlDebugLogs => 'Graphql debug logs';

  @override
  String get gqlDebugLogsHint =>
      'This includes logs with non privacy safe information';

  @override
  String get help => 'Ayuda';

  @override
  String get hideEmptyCategory => 'Hide Empty Category';

  @override
  String get inLibrary => 'En biblioteca';

  @override
  String get includeCategories => 'Categories';

  @override
  String get includeChapters => 'Chapters';

  @override
  String get install => 'Instalar';

  @override
  String get installing => 'Instalando';

  @override
  String get installingExtension => 'Instalando la extensión';

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
  String get isTrueBlack => 'Negro verdadero';

  @override
  String get languages => 'Idioma';

  @override
  String get latest => 'Reciente';

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
  String get mangaGridSize => 'Tamaño de la cuadrícula del manga';

  @override
  String get mangaMissingSources => 'Fuentes del manga faltantes';

  @override
  String get mangaSortAlphabetical => 'Alfabético';

  @override
  String get mangaSortDateAdded => 'Fecha añadida';

  @override
  String get mangaSortLastRead => 'Última lectura';

  @override
  String get mangaSortLastUpdated => 'Last Updated';

  @override
  String get mangaSortUnread => 'No leído';

  @override
  String get mangaStatusCancelled => 'Cancelado';

  @override
  String get mangaStatusCompleted => 'Completado';

  @override
  String get mangaStatusLicensed => 'Con licencia';

  @override
  String get mangaStatusOnHiatus => 'Pausado';

  @override
  String get mangaStatusOngoing => 'En publicación';

  @override
  String get mangaStatusPublishingFinished => 'Serie terminada';

  @override
  String get mangaStatusUnknown => 'Desconocido';

  @override
  String get misc => 'Misc';

  @override
  String get missingExtension => 'Extensiones faltantes';

  @override
  String get missingTrackers => 'Rastreadores faltantes';

  @override
  String get more => 'Más';

  @override
  String get moveToBottom => 'Mover al fondo';

  @override
  String get moveToTop => 'Mover al principio';

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
  String get newUpdateAvailable => 'Nueva actualización disponible';

  @override
  String nextChapter(Object chapterTitle) {
    return 'Siguiente: $chapterTitle';
  }

  @override
  String get noCategoriesFound =>
      'No tienes ninguna categoría.\n(Tip: Pulsa el botón Más para crear uno y organizar tu biblioteca)';

  @override
  String get noCategoriesFoundAlt =>
      'No tienes ninguna categoría.\nCrea uno en ajustes para organizar tu biblioteca';

  @override
  String get noCategoryMangaFound =>
      'No hay ningún manga en esta categoría.\n(Tip: ¡Comprueba tus búsquedas y filtros!)';

  @override
  String get noChaptersFound => 'No se encontraron capítulos';

  @override
  String get noDownloads => 'No hay descargas';

  @override
  String get noMangaFound => 'No se encontraron mangas';

  @override
  String noOfChapters(int count) {
    return '$count capítulos';
  }

  @override
  String noPropFound(Object prop) {
    return 'No $prop Found';
  }

  @override
  String get noResultFound => 'Sin resultados';

  @override
  String get noServerFound =>
      'No se ha encontrado ningún servidor en tu red local';

  @override
  String get noSourcesFound => 'No se encontraron fuentes';

  @override
  String get noUpdatesAvailable => 'Estás usando la última versión';

  @override
  String get noUpdatesFound => 'Sin actualizaciones';

  @override
  String get none => 'None';

  @override
  String get nsfw => 'Mostrar fuentes y extensiones NSFW';

  @override
  String get nsfw18 => '18+';

  @override
  String get nsfwInfo =>
      'Esto no evita que extensiones no oficiales o marcadas potencialmente de forma incorrecta muestren contenido para adultos (18+) en la aplicación';

  @override
  String numSelected(int num) {
    return '$num seleccionado';
  }

  @override
  String get obsolete => 'Obsoleta';

  @override
  String get openFlareSolverr =>
      'Checkout FlareSolverr for information on how to set it up';

  @override
  String get openInWeb => 'Open In Web';

  @override
  String get or => 'or';

  @override
  String page(int number) {
    return 'Página: $number';
  }

  @override
  String get parallelSourceRequest => 'Parallel source requests';

  @override
  String get password => 'Contraseña';

  @override
  String get pause => 'Pausar';

  @override
  String get pending => 'Pendiente';

  @override
  String get pinchToZoom => 'Pellizcar para hacer zoom';

  @override
  String previousChapter(Object chapterTitle) {
    return 'Anterior: $chapterTitle';
  }

  @override
  String get queued => 'Queued';

  @override
  String get quickSearch => 'Búsqueda rápida';

  @override
  String get quickSearchCategory => 'Ir a la categoría \'C\'';

  @override
  String get quickSearchCategoryManga =>
      'Ir al manga \'M\' en la categoría \'C\'';

  @override
  String get quickSearchCategoryMangaChapter =>
      'Ir al capítulo \"CN\" del manga \"M\" en la categoría \"C\"';

  @override
  String get quickSearchContext =>
      'Busca la consulta X (los resultados se basan en el contexto en pantalla)';

  @override
  String get quickSearchShowAllCommandTip =>
      'Consejo: Introduce \'?\' para ver todos los comandos';

  @override
  String get quickSearchSource => 'Ir a la fuente \'S\'';

  @override
  String get quickSearchSourceManga =>
      'Buscar el manga \'M\' en la fuente \'S\'';

  @override
  String get reader => 'Lector';

  @override
  String get readerMagnifierSize => 'Tamaño de la lupa';

  @override
  String get readerMode => 'Modo de lectura';

  @override
  String get readerModeContinuousHorizontalLTR =>
      'Horizontal continuo (IZQ-DER)';

  @override
  String get readerModeContinuousHorizontalRTL =>
      'Horizontal continuo (DER-IZQ)';

  @override
  String get readerModeContinuousVertical => 'Vertical continuo';

  @override
  String get readerModeDefaultReader => 'Predeterminado';

  @override
  String get readerModeSingleHorizontalLTR => 'Horizontal individual (IZQ-DER)';

  @override
  String get readerModeSingleHorizontalRTL => 'Horizontal individual (DER-IZQ)';

  @override
  String get readerModeSingleVertical => 'Horizontal individual';

  @override
  String get readerModeWebtoon => 'Webtoon';

  @override
  String get readerNavigationLayout => 'Tipo de navegación';

  @override
  String get readerNavigationLayoutDefault => 'Predeterminado';

  @override
  String get readerNavigationLayoutDisabled => 'Deshabilitado';

  @override
  String get readerNavigationLayoutEdge => 'Borde';

  @override
  String get readerNavigationLayoutInvert => 'Invertir el toque';

  @override
  String get readerNavigationLayoutKindlish => 'Estilo Kindle';

  @override
  String get readerNavigationLayoutLShaped => 'En forma de L';

  @override
  String get readerNavigationLayoutRightAndLeft => 'Derecha e Izquierda';

  @override
  String get readerOverlay => 'Superposición inicial del lector';

  @override
  String get readerOverlaySubtitle =>
      'Muestra el título y los ajustes rápidos al abrir un capítulo';

  @override
  String get readerPadding => 'Anotaciones del lector';

  @override
  String get readerScrollAnimation => 'Animación del desplazamiento';

  @override
  String get readerSwipeChapterToggle => 'Deslizar el dedo';

  @override
  String get readerSwipeChapterToggleDescription =>
      'Deslizar para cambiar de capítulo en el lector';

  @override
  String get readerLastPageSwipeToggle => 'Last page swipe';

  @override
  String get readerLastPageSwipeToggleDescription =>
      'Swipe to next chapter only at last page';

  @override
  String get readerVolumeTap => 'Botones de volumen';

  @override
  String get readerVolumeTapInvert => 'Invertir los botones de volumen';

  @override
  String get readerVolumeTapSubtitle => 'Navegar con los botones de volumen';

  @override
  String get readerIgnoreSafeAreaToggle => 'Ignore Safe Area';

  @override
  String get readerIgnoreSafeAreaToggleDescription =>
      'Allow content to extend into notch and home indicator areas';

  @override
  String get reddit => 'Reddit';

  @override
  String get refresh => 'Refrescar';

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
  String get source => 'Fuente';

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
  String get reload => 'Recargar';

  @override
  String get remove => 'Quitar';

  @override
  String get removeFromLibrary => '¿Quitar de la biblioteca?';

  @override
  String get reset => 'Restablecer';

  @override
  String get restore => 'Restore';

  @override
  String get restoreBackupDescription =>
      'Restaurar Tachidesk desde copia de seguridad';

  @override
  String get restoreBackupTitle => 'Restaurar copia de seguridad';

  @override
  String get restored => '¡Copia de seguridad restaurada!';

  @override
  String get restoring => 'Restaurando la copia de seguridad';

  @override
  String get resume => 'Reanudar';

  @override
  String get retry => 'Reintentar';

  @override
  String get running => 'Ejecutando';

  @override
  String get save => 'Guardar';

  @override
  String get saveAsCBZArchive => 'Save as CBZ archive';

  @override
  String get scanlators => 'Scans';

  @override
  String get search => 'Buscar';

  @override
  String get searchingForUpdates => 'Buscando actualizaciones';

  @override
  String get selectInBetween => 'Seleccionar entre';

  @override
  String get selectNext10 => 'Seleccionar los 10 siguientes';

  @override
  String get selectUnread => 'Seleccionar los no leídos';

  @override
  String get server => 'Servidor';

  @override
  String get serverBindings => 'Server Bindings';

  @override
  String get serverPort => 'Puerto del servidor';

  @override
  String get serverPortHintText => 'Puerto del servidor';

  @override
  String get serverUrl => 'Enlace del servidor';

  @override
  String get serverUrlHintText => 'Dirección Url del servidor';

  @override
  String get serverVersion => 'Versión del servidor';

  @override
  String get settings => 'Ajustes';

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
  String get sort => 'Ordenar';

  @override
  String get sourceTypeFilter => 'Filtro';

  @override
  String get sourceTypeLatest => 'Reciente';

  @override
  String get sourceTypePopular => 'Popular';

  @override
  String get sources => 'Fuentes';

  @override
  String get start => 'Empezar';

  @override
  String get systemTrayIcon => 'Show icon in system tray';

  @override
  String get thatHaventBeenStarted => 'That haven\'t been started';

  @override
  String get themeModeDark => 'Oscuro';

  @override
  String get themeModeLight => 'Claro';

  @override
  String get themeModeSystem => 'Sistema';

  @override
  String get today => 'Hoy';

  @override
  String get uninstall => 'Desinstalar';

  @override
  String get uninstalling => 'Desinstalando';

  @override
  String get unknownAuthor => 'Autor desconocido';

  @override
  String get unknownManga => 'Manga desconocido';

  @override
  String get unknownSource => 'Fuente desconocida';

  @override
  String get unread => 'Sin leer';

  @override
  String get update => 'Actualizar';

  @override
  String get updateCompleted => 'Actualización completa';

  @override
  String updateFailed(Object property) {
    return 'Failed to update $property';
  }

  @override
  String get updates => 'Actualizaciones';

  @override
  String get updatesSummary => 'Resumen de actualizaciones';

  @override
  String get updating => 'Actualizando';

  @override
  String get userName => 'Nombre de usuario';

  @override
  String get validating => 'Validating';

  @override
  String versionAvailable(String app, String version) {
    return '¡¡La versión $version está disponible para $app!!';
  }

  @override
  String get webUI => 'Abrir en Internet';

  @override
  String get webView => 'WebView';

  @override
  String get whatsNew => '¿Qué hay de nuevo?';

  @override
  String get withCompletedStatus => 'With Completed status';

  @override
  String get withUnreadChapter => 'With unread chapter(s)';

  @override
  String get yesterday => 'Ayer';

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
