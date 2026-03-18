// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get about => 'Про застосунок';

  @override
  String get addCategory => 'Додати категорію';

  @override
  String get addToLibrary => 'Додати до бібліотеки';

  @override
  String get advanced => 'Advanced';

  @override
  String get allScanlators => 'Всі Сканлейтори';

  @override
  String get appLanguage => 'Мова застосунку';

  @override
  String get appTheme => 'Тема застосунку';

  @override
  String get appTitle => 'Catalyst';

  @override
  String get appearance => 'Зовнішній вигляд';

  @override
  String get authType => 'Тип автентифікації';

  @override
  String get authTypeBasic => 'Основна авторизація';

  @override
  String get authTypeNone => 'Немає';

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
  String get backup => 'Резервне копіювання та відновлення';

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
  String get badges => 'Значки';

  @override
  String get bookmarked => 'Додано в закладки';

  @override
  String get browse => 'Перегляд';

  @override
  String get buildTime => 'Час збірки';

  @override
  String get cacheCleared => 'Кеш очищено';

  @override
  String get cancel => 'Скасувати';

  @override
  String get categories => 'Категорії';

  @override
  String get categoryUpdate => 'Оновлення категорії';

  @override
  String get channel => 'Канал';

  @override
  String get chapterDownloadLimit => 'Chapter download limit';

  @override
  String get chapterDownloadLimitDesc =>
      'Limit the amount of new chapters that are going to get downloaded.';

  @override
  String chapterNumber(double number) {
    return 'Розділ $number';
  }

  @override
  String get chapterSortFetchedDate => 'За датою отримання';

  @override
  String get chapterSortSource => 'За джерелом';

  @override
  String get chapterSortUploadDate => 'За датою завантаження';

  @override
  String get checkForServerUpdates => 'Перевірити наявність оновлень сервера';

  @override
  String get checkForUpdates => 'Перевірити наявність оновлень';

  @override
  String get clearCache => 'Очистити кеш';

  @override
  String get client => 'Клієнт';

  @override
  String get clientVersion => 'Версія клієнту';

  @override
  String get close => 'Закрити';

  @override
  String get cloudflareBypass => 'Cloudflare Bypass';

  @override
  String get completed => 'Завершено';

  @override
  String get copied => 'Copied!';

  @override
  String copyMsg(String msg) {
    return '\'$msg\' Скопійовано!';
  }

  @override
  String get createBackupDescription =>
      'Резервна копія бібліотеки як резервна копія Tachidesk';

  @override
  String get createBackupTitle => 'Створити резервну копію';

  @override
  String get credentials => 'Облікові дані';

  @override
  String get current => 'Поточний';

  @override
  String daysAgo(Object days) {
    return '$days днів тому';
  }

  @override
  String get debugLogs => 'Debug logs';

  @override
  String get defaultCategory =>
      'Категорія за замовчуванням при додаванні нової манґи до бібліотеки';

  @override
  String get delete => 'Видалити';

  @override
  String get deleteCategoryDescription =>
      'Це об\'єднає всі манґи в цій категорії за замовчуванням!';

  @override
  String get deleteCategoryTitle => 'Ви впевнені?';

  @override
  String get discord => 'Discord';

  @override
  String get display => 'Відображення';

  @override
  String get displayMode => 'Режим відображення';

  @override
  String get displayModeDescriptiveList => 'Описовий список';

  @override
  String get displayModeGrid => 'Сітка';

  @override
  String get displayModeList => 'Список';

  @override
  String get downloadLocation => 'Download location';

  @override
  String get downloadLocationHint =>
      'The path to the directory on the server where downloaded files should get saved in';

  @override
  String get downloaded => 'Завантажено';

  @override
  String get downloading => 'Downloading';

  @override
  String get downloads => 'Зааантаження';

  @override
  String get edit => 'Редагувати';

  @override
  String get editCategory => 'Редагувати категорію';

  @override
  String get emptyCategory => 'Назва категорії не може бути порожньою';

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
  String get errorExtension => 'Не вдається знайти вибране розширення';

  @override
  String get errorFilePick => 'Файл не вибрано!';

  @override
  String errorFilePickUnknownExtension(Object extensionName) {
    return 'Будь ласка, виберіть файл з розширенням $extensionName';
  }

  @override
  String errorLaunchURL(String url) {
    return 'Не вдалося відкрити!\nКопіювання \"$url\" в буфер обміну';
  }

  @override
  String get errorPassword => 'Пароль не може бути порожнім';

  @override
  String get errorSomethingWentWrong => 'Щось пішло не так!';

  @override
  String get errorUserName => 'Ім’я користувача не може бути порожнім';

  @override
  String get excludeEntryWithUnreadChapters =>
      'Ignore automatic chapter downloads for entries with unread chapters';

  @override
  String get extensionInstalled => 'Розширення встановлено!';

  @override
  String get extensionListEmpty => 'Список розширень порожній';

  @override
  String get extensionRepository => 'Extension Repository';

  @override
  String get extensionRepositoryDescription =>
      'Add repositories from which extensions can be installed';

  @override
  String get extensions => 'Розширення';

  @override
  String get failed => 'Не вдалося';

  @override
  String get filter => 'Фільтр';

  @override
  String get findServer => 'Знайти';

  @override
  String get finished => 'Завершено';

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
  String get general => 'Загальні';

  @override
  String get gitHub => 'GitHub';

  @override
  String get globalSearch => 'Глобальний пошук';

  @override
  String get globalUpdate => 'Глобальне оновлення';

  @override
  String get gqlDebugLogs => 'Graphql debug logs';

  @override
  String get gqlDebugLogsHint =>
      'This includes logs with non privacy safe information';

  @override
  String get help => 'Допомога';

  @override
  String get hideEmptyCategory => 'Hide Empty Category';

  @override
  String get inLibrary => 'У бібліотеці';

  @override
  String get includeCategories => 'Categories';

  @override
  String get includeChapters => 'Chapters';

  @override
  String get install => 'Встановити';

  @override
  String get installing => 'Встановлення';

  @override
  String get installingExtension => 'Встановлення розширення';

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
  String get isTrueBlack => 'Справжній чорний';

  @override
  String get languages => 'Мови';

  @override
  String get latest => 'Останні';

  @override
  String get library => 'Бібліотека';

  @override
  String get localSourceLocation => 'Local source location';

  @override
  String get localSourceLocationDescription =>
      'The path to the directory on the server where local source files are saved in';

  @override
  String get manga => 'Манґа';

  @override
  String get mangaGridSize => 'Розмір сітки манґи';

  @override
  String get mangaMissingSources => 'Відсутні джерела манґи';

  @override
  String get mangaSortAlphabetical => 'За алфавітом';

  @override
  String get mangaSortDateAdded => 'Дата додавання';

  @override
  String get mangaSortLastRead => 'Останнє прочитане';

  @override
  String get mangaSortLastUpdated => 'Last Updated';

  @override
  String get mangaSortUnread => 'Не прочитано';

  @override
  String get mangaStatusCancelled => 'Скасовано';

  @override
  String get mangaStatusCompleted => 'Завершено';

  @override
  String get mangaStatusLicensed => 'Ліцензовано';

  @override
  String get mangaStatusOnHiatus => 'На перерві';

  @override
  String get mangaStatusOngoing => 'Виходить';

  @override
  String get mangaStatusPublishingFinished => 'Публікацію завершено';

  @override
  String get mangaStatusUnknown => 'Невідомо';

  @override
  String get misc => 'Misc';

  @override
  String get missingExtension => 'Відсутні розширення';

  @override
  String get missingTrackers => 'Відсутні трекери';

  @override
  String get more => 'Більше';

  @override
  String get moveToBottom => 'Перемістити вниз';

  @override
  String get moveToTop => 'Перемістити вгору';

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
  String get newUpdateAvailable => 'Доступне нове оновлення';

  @override
  String nextChapter(Object chapterTitle) {
    return 'Далі: $chapterTitle';
  }

  @override
  String get noCategoriesFound =>
      'У вас немає жодної категорії. \n(Порада: натисніть кнопку \"Плюс\", щоб створити категорію для впорядкування бібліотеки)';

  @override
  String get noCategoriesFoundAlt =>
      'У вас немає категорій. \nСтворіть їх у налаштуваннях для організації бібліотеки';

  @override
  String get noCategoryMangaFound =>
      'У цій категорії не знайдено жодної манґи. \n(Порада: перевірте пошук та фільтри!)';

  @override
  String get noChaptersFound => 'Не знайдено жодного розділу';

  @override
  String get noDownloads => 'Немає завантажень';

  @override
  String get noMangaFound => 'Манґи не знайдено';

  @override
  String noOfChapters(int count) {
    return '$count Розділів';
  }

  @override
  String noPropFound(Object prop) {
    return 'No $prop Found';
  }

  @override
  String get noResultFound => 'Нічого не знайдено';

  @override
  String get noServerFound => 'У вашій локальній мережі не знайдено сервер';

  @override
  String get noSourcesFound => 'Джерел не знайдено';

  @override
  String get noUpdatesAvailable => 'Ви використовуєте останню версію';

  @override
  String get noUpdatesFound => 'Оновлень не знайдено';

  @override
  String get none => 'None';

  @override
  String get nsfw => 'Показати NSFW розширення та джерела';

  @override
  String get nsfw18 => '18+';

  @override
  String get nsfwInfo =>
      'Це не запобігає появі неофіційних або потенційно неправильно позначених розширень, які можуть містити NSFW(18+) вміст в застосунку';

  @override
  String numSelected(int num) {
    return '$num Вибрано';
  }

  @override
  String get obsolete => 'Застаріле';

  @override
  String get openFlareSolverr =>
      'Checkout FlareSolverr for information on how to set it up';

  @override
  String get openInWeb => 'Open In Web';

  @override
  String get or => 'or';

  @override
  String page(int number) {
    return 'Сторінка: $number';
  }

  @override
  String get parallelSourceRequest => 'Parallel source requests';

  @override
  String get password => 'Пароль';

  @override
  String get pause => 'Пауза';

  @override
  String get pending => 'В очікуванні';

  @override
  String get pinchToZoom => 'Збільшення стисканням';

  @override
  String previousChapter(Object chapterTitle) {
    return 'Попередній: $chapterTitle';
  }

  @override
  String get queued => 'Queued';

  @override
  String get quickSearch => 'Швидкий пошук';

  @override
  String get quickSearchCategory => 'Перейти до категорії \"C\"';

  @override
  String get quickSearchCategoryManga =>
      'Перейти до манґи \"M\" у категорію \"C\"';

  @override
  String get quickSearchCategoryMangaChapter =>
      'Перейти до назви розділу \"CN\" з манґи \"M\" в категорію \"C\"';

  @override
  String get quickSearchContext =>
      'Пошук за запитом X (результати базуються на контексті екрана)';

  @override
  String get quickSearchShowAllCommandTip =>
      'Підказка: Введіть \'?\', щоб побачити всі команди';

  @override
  String get quickSearchSource => 'Перейти до джерела \"S\"';

  @override
  String get quickSearchSourceManga => 'Пошук манґи \"M\" у джерелі \"S\"';

  @override
  String get reader => 'Читач';

  @override
  String get readerMagnifierSize => 'Розмір екранної лупи';

  @override
  String get readerMode => 'Режим читання';

  @override
  String get readerModeContinuousHorizontalLTR =>
      'Горизонтальний безперервний (зліва направо)';

  @override
  String get readerModeContinuousHorizontalRTL =>
      'Горизонтальний безперервний (справа наліво)';

  @override
  String get readerModeContinuousVertical => 'Вертикальний безперервний';

  @override
  String get readerModeDefaultReader => 'За замовчуванням';

  @override
  String get readerModeSingleHorizontalLTR =>
      'Одиночний горизонтальний (зліва направо)';

  @override
  String get readerModeSingleHorizontalRTL =>
      'Одиночний горизонтальний (справо наліво)';

  @override
  String get readerModeSingleVertical => 'Одиночний вертикальний';

  @override
  String get readerModeWebtoon => 'Webtoon';

  @override
  String get readerNavigationLayout => 'Макет навігації';

  @override
  String get readerNavigationLayoutDefault => 'За замовчуванням';

  @override
  String get readerNavigationLayoutDisabled => 'Вимкнено';

  @override
  String get readerNavigationLayoutEdge => 'Край';

  @override
  String get readerNavigationLayoutInvert => 'Інвертувати дотик';

  @override
  String get readerNavigationLayoutKindlish => 'Kindle-ish';

  @override
  String get readerNavigationLayoutLShaped => 'Форма L';

  @override
  String get readerNavigationLayoutRightAndLeft => 'Праворуч і ліворуч';

  @override
  String get readerOverlay => 'Оверлей';

  @override
  String get readerOverlaySubtitle =>
      'Відображати назву та швидкі налаштування при відкритті розділу';

  @override
  String get readerPadding => 'Заповнення читача';

  @override
  String get readerScrollAnimation => 'Анімація прокрутки';

  @override
  String get readerSwipeChapterToggle => 'Проведіть пальцем, щоб перегорнути';

  @override
  String get readerSwipeChapterToggleDescription =>
      'Проведіть пальцем, щоб змінити розділ в читачу';

  @override
  String get readerLastPageSwipeToggle => 'Last page swipe';

  @override
  String get readerLastPageSwipeToggleDescription =>
      'Swipe to next chapter only at last page';

  @override
  String get readerVolumeTap => 'Клавіші гучності';

  @override
  String get readerVolumeTapInvert => 'Інвертувати клавіші гучності';

  @override
  String get readerVolumeTapSubtitle =>
      'Навігація за допомогою клавіш гучності';

  @override
  String get readerIgnoreSafeAreaToggle => 'Ignore Safe Area';

  @override
  String get readerIgnoreSafeAreaToggleDescription =>
      'Allow content to extend into notch and home indicator areas';

  @override
  String get reddit => 'Reddit';

  @override
  String get refresh => 'Оновити';

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
  String get source => 'Джерело';

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
  String get reload => 'Перезавантажити';

  @override
  String get remove => 'Видалити';

  @override
  String get removeFromLibrary => 'Видалити з бібліотеки?';

  @override
  String get reset => 'Скинути';

  @override
  String get restore => 'Restore';

  @override
  String get restoreBackupDescription =>
      'Відновити Tachidesk з резервної копії';

  @override
  String get restoreBackupTitle => 'Відновити резервну копію';

  @override
  String get restored => 'Резервну копію відновлено!';

  @override
  String get restoring => 'Відновлення резервної копії';

  @override
  String get resume => 'Відновити';

  @override
  String get retry => 'Повторити';

  @override
  String get running => 'Запущено';

  @override
  String get save => 'Зберегти';

  @override
  String get saveAsCBZArchive => 'Save as CBZ archive';

  @override
  String get scanlators => 'Перекладачі';

  @override
  String get search => 'Пошук';

  @override
  String get searchingForUpdates => 'Пошук оновлень';

  @override
  String get selectInBetween => 'Виберіть між';

  @override
  String get selectNext10 => 'Обрати наступні 10';

  @override
  String get selectUnread => 'Обрати Непрочитане';

  @override
  String get server => 'Сервер';

  @override
  String get serverBindings => 'Server Bindings';

  @override
  String get serverPort => 'Порт сервера';

  @override
  String get serverPortHintText => 'Порт сервера';

  @override
  String get serverUrl => 'URL сервера';

  @override
  String get serverUrlHintText => 'URL-адреса сервера';

  @override
  String get serverVersion => 'Версія сервера';

  @override
  String get settings => 'Налаштування';

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
  String get sort => 'Сортувати';

  @override
  String get sourceTypeFilter => 'Фільтр';

  @override
  String get sourceTypeLatest => 'Останні';

  @override
  String get sourceTypePopular => 'Популярне';

  @override
  String get sources => 'Джерела';

  @override
  String get start => 'Почати';

  @override
  String get systemTrayIcon => 'Show icon in system tray';

  @override
  String get thatHaventBeenStarted => 'That haven\'t been started';

  @override
  String get themeModeDark => 'Темна';

  @override
  String get themeModeLight => 'Світла';

  @override
  String get themeModeSystem => 'Системна';

  @override
  String get today => 'Сьогодні';

  @override
  String get uninstall => 'Видалити';

  @override
  String get uninstalling => 'Видалення';

  @override
  String get unknownAuthor => 'Невідомий автор';

  @override
  String get unknownManga => 'Невідома манґа';

  @override
  String get unknownSource => 'Невідоме джерело';

  @override
  String get unread => 'Не прочитано';

  @override
  String get update => 'Oновити';

  @override
  String get updateCompleted => 'Оновлення завершено';

  @override
  String updateFailed(Object property) {
    return 'Failed to update $property';
  }

  @override
  String get updates => 'Оновлення';

  @override
  String get updatesSummary => 'Підсумок оновлень';

  @override
  String get updating => 'Оновлення';

  @override
  String get userName => 'Ім\'я користувача';

  @override
  String get validating => 'Validating';

  @override
  String versionAvailable(String app, String version) {
    return 'Версія $version доступна для $app!!!';
  }

  @override
  String get webUI => 'Відкрити у Веб';

  @override
  String get webView => 'Web View';

  @override
  String get whatsNew => 'Що нового?';

  @override
  String get withCompletedStatus => 'With Completed status';

  @override
  String get withUnreadChapter => 'With unread chapter(s)';

  @override
  String get yesterday => 'Вчора';

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
