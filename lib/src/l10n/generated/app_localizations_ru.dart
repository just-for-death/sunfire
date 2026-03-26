// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get about => 'О программе';

  @override
  String get addCategory => 'Добавить категорию';

  @override
  String get addToLibrary => 'Добавить в библиотеку';

  @override
  String get advanced => 'Advanced';

  @override
  String get allScanlators => 'Все сканлейты';

  @override
  String get appLanguage => 'Язык приложения';

  @override
  String get appTheme => 'Тема приложения';

  @override
  String get appTitle => 'Catalyst';

  @override
  String get appearance => 'Оформление';

  @override
  String get authType => 'Тип аутентификации';

  @override
  String get authTypeBasic => 'Базовая аутентификация';

  @override
  String get authTypeNone => 'Без аутентификации';

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
  String get backup => 'Бэкап и восстановление';

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
  String get bookmarked => 'Добавлено в закладки';

  @override
  String get browse => 'Поисковики';

  @override
  String get buildTime => 'Дата сборки';

  @override
  String get cacheCleared => 'Кэш очищен';

  @override
  String get cancel => 'Отменить';

  @override
  String get categories => 'Категории';

  @override
  String get categoryUpdate => 'Обновление категорий';

  @override
  String get channel => 'Канал';

  @override
  String get chapterDownloadLimit => 'Chapter download limit';

  @override
  String get chapterDownloadLimitDesc =>
      'Limit the amount of new chapters that are going to get downloaded.';

  @override
  String chapterNumber(double number) {
    return 'Глава $number';
  }

  @override
  String get chapterSortFetchedDate => 'По дате получения';

  @override
  String get chapterSortSource => 'По источнику';

  @override
  String get chapterSortUploadDate => 'По дате загрузки';

  @override
  String get checkForServerUpdates => 'Проверка обновлений сервера';

  @override
  String get checkForUpdates => 'Проверка обновлений';

  @override
  String get clearCache => 'Очистить кэш';

  @override
  String get client => 'Программа';

  @override
  String get clientVersion => 'Версия программы';

  @override
  String get close => 'Закрыть';

  @override
  String get cloudflareBypass => 'Cloudflare Bypass';

  @override
  String get completed => 'Завершено';

  @override
  String get copied => 'Copied!';

  @override
  String copyMsg(String msg) {
    return '\'$msg\' Скопировано!';
  }

  @override
  String get createBackupDescription =>
      'Резервная копия библиотеки как резервная копия Tachidesk';

  @override
  String get createBackupTitle => 'Создать резервную копию';

  @override
  String get credentials => 'Учетные данные';

  @override
  String get current => 'Текущий';

  @override
  String daysAgo(Object days) {
    return '$days дней назад';
  }

  @override
  String get debugLogs => 'Debug logs';

  @override
  String get defaultCategory =>
      'Категория по умолчанию при добавлении новой манги в библиотеку';

  @override
  String get delete => 'Удалить';

  @override
  String get deleteCategoryDescription =>
      'Вся манга из этой Категории будет перемещена в По умолчанию!';

  @override
  String get deleteCategoryTitle => 'Вы уверены?';

  @override
  String get discord => 'Discord';

  @override
  String get display => 'Отображение';

  @override
  String get displayMode => 'Режим отображения';

  @override
  String get displayModeDescriptiveList => 'Информативный список';

  @override
  String get displayModeGrid => 'Сетка';

  @override
  String get displayModeList => 'Список';

  @override
  String get downloadLocation => 'Download location';

  @override
  String get downloadLocationHint =>
      'The path to the directory on the server where downloaded files should get saved in';

  @override
  String get downloaded => 'Загружено';

  @override
  String get downloading => 'Downloading';

  @override
  String get downloads => 'Загрузка';

  @override
  String get edit => 'Редактировать';

  @override
  String get editCategory => 'Отредактировать категорию';

  @override
  String get emptyCategory => 'Название категории не может быть пустым';

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
  String get errorExtension => 'Не удается найти выбранное расширение';

  @override
  String get errorFilePick => 'Файл не выбран!';

  @override
  String errorFilePickUnknownExtension(Object extensionName) {
    return 'Выберите файл с расширением $extensionName';
  }

  @override
  String errorLaunchURL(String url) {
    return 'Не удалось открыть!\nКопирование \"$url\" в буфер обмена';
  }

  @override
  String get errorPassword => 'Пароль не может быть пустым';

  @override
  String get errorSomethingWentWrong => 'Что-то пошло не так!';

  @override
  String get errorUserName => 'Имя пользователя не может быть пустым';

  @override
  String get excludeEntryWithUnreadChapters =>
      'Ignore automatic chapter downloads for entries with unread chapters';

  @override
  String get extensionInstalled => 'Расширение установлено!';

  @override
  String get extensionListEmpty => 'Список расширений пуст';

  @override
  String get extensionRepository => 'Extension Repository';

  @override
  String get extensionRepositoryDescription =>
      'Add repositories from which extensions can be installed';

  @override
  String get extensions => 'Расширения';

  @override
  String get failed => 'Не удалось';

  @override
  String get filter => 'Фильтр';

  @override
  String get findServer => 'Найти';

  @override
  String get finished => 'Завершенная';

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
  String get general => 'Общий';

  @override
  String get gitHub => 'GitHub';

  @override
  String get globalSearch => 'Глобальный поиск';

  @override
  String get globalUpdate => 'Глобальное обновление';

  @override
  String get gqlDebugLogs => 'Graphql debug logs';

  @override
  String get gqlDebugLogsHint =>
      'This includes logs with non privacy safe information';

  @override
  String get help => 'Помощь';

  @override
  String get hideEmptyCategory => 'Hide Empty Category';

  @override
  String get inLibrary => 'В библиотеке';

  @override
  String get includeCategories => 'Categories';

  @override
  String get includeChapters => 'Chapters';

  @override
  String get install => 'Установить';

  @override
  String get installing => 'Установка';

  @override
  String get installingExtension => 'Установка расширения';

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
  String get isTrueBlack => 'Истинно черный';

  @override
  String get languages => 'Языки';

  @override
  String get latest => 'Последний';

  @override
  String get library => 'Библиотека';

  @override
  String get localSourceLocation => 'Local source location';

  @override
  String get localSourceLocationDescription =>
      'The path to the directory on the server where local source files are saved in';

  @override
  String get manga => 'Манга';

  @override
  String get mangaGridSize => 'Размер сетки манги';

  @override
  String get mangaMissingSources => 'Пропавшие источники манги';

  @override
  String get mangaSortAlphabetical => 'По алфавиту';

  @override
  String get mangaSortDateAdded => 'По дате добавления';

  @override
  String get mangaSortLastRead => 'По последнему прочтению';

  @override
  String get mangaSortLastUpdated => 'Last Updated';

  @override
  String get mangaSortUnread => 'Непрочитанная';

  @override
  String get mangaStatusCancelled => 'Отменено';

  @override
  String get mangaStatusCompleted => 'Завершено';

  @override
  String get mangaStatusLicensed => 'Лицензировано';

  @override
  String get mangaStatusOnHiatus => 'Приостановлено';

  @override
  String get mangaStatusOngoing => 'Выходит';

  @override
  String get mangaStatusPublishingFinished => 'Публикация завершена';

  @override
  String get mangaStatusUnknown => 'Неизвестно';

  @override
  String get misc => 'Misc';

  @override
  String get missingExtension => 'Пропавшие расширения';

  @override
  String get missingTrackers => 'Пропавшие трекеры';

  @override
  String get more => 'Ещё';

  @override
  String get moveToBottom => 'Переместить вниз';

  @override
  String get moveToTop => 'Переместить вверх';

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
  String get newUpdateAvailable => 'Доступно новое обновление';

  @override
  String nextChapter(Object chapterTitle) {
    return 'Далее: $chapterTitle';
  }

  @override
  String get noCategoriesFound =>
      'У вас нет никаких категорий. \n(Совет: Нажмите кнопку \"Плюс\", чтобы создать категорию для организации библиотеки)';

  @override
  String get noCategoriesFoundAlt =>
      'У вас нет ни одной категории. \nСоздайте их в настройках для организации вашей библиотеки';

  @override
  String get noCategoryMangaFound =>
      'В этой категории манга не найдена. \n(Совет: проверьте свой поиск и фильтры!)';

  @override
  String get noChaptersFound => 'Не найдено ни одной главы';

  @override
  String get noDownloads => 'Нет загрузок';

  @override
  String get noMangaFound => 'Манга не найдена';

  @override
  String noOfChapters(int count) {
    return '$count Глав';
  }

  @override
  String noPropFound(Object prop) {
    return 'No $prop Found';
  }

  @override
  String get noResultFound => 'Подходящих результатов не найдено';

  @override
  String get noServerFound => 'В вашей локальной сети сервер не найден';

  @override
  String get noSourcesFound => 'Источники не найдены';

  @override
  String get noUpdatesAvailable => 'Вы используете последнюю версию';

  @override
  String get noUpdatesFound => 'Обновлений не найдено';

  @override
  String get none => 'None';

  @override
  String get nsfw => 'Показать NSFW расширения и источники';

  @override
  String get nsfw18 => '18+';

  @override
  String get nsfwInfo =>
      'Это не мешает неофициальным или потенциально неверно отмеченным расширениям показывать NSFW(18+) контент в приложении';

  @override
  String numSelected(int num) {
    return '$num Выбрано';
  }

  @override
  String get obsolete => 'Устаревшее';

  @override
  String get openFlareSolverr =>
      'Checkout FlareSolverr for information on how to set it up';

  @override
  String get openInWeb => 'Open In Web';

  @override
  String get or => 'or';

  @override
  String page(int number) {
    return 'Страница: $number';
  }

  @override
  String get parallelSourceRequest => 'Parallel source requests';

  @override
  String get password => 'Пароль';

  @override
  String get pause => 'Пауза';

  @override
  String get pending => 'В ожидании';

  @override
  String get pinchToZoom => 'Зажмите для увеличения';

  @override
  String previousChapter(Object chapterTitle) {
    return 'Предыдущая: $chapterTitle';
  }

  @override
  String get queued => 'Queued';

  @override
  String get quickSearch => 'Быстрый поиск';

  @override
  String get quickSearchCategory => 'Перейти к категории \'C\'';

  @override
  String get quickSearchCategoryManga =>
      'Перейти к манге \'M\' в категории \'C\'';

  @override
  String get quickSearchCategoryMangaChapter =>
      'Перейти к названию главы \'CN\' из манги \'M\' в категории \'C\'';

  @override
  String get quickSearchContext =>
      'Поиск по запросу X (результаты основаны на контексте экрана)';

  @override
  String get quickSearchShowAllCommandTip =>
      'Совет: Введите \'?\' чтобы увидеть все команды';

  @override
  String get quickSearchSource => 'Перейти к источнику \'S\'';

  @override
  String get quickSearchSourceManga => 'Поиск манги \'M\' в источнике \'S\'';

  @override
  String get reader => 'Читалка';

  @override
  String get readerMagnifierSize => 'Размер лупы';

  @override
  String get readerMode => 'Метод чтения';

  @override
  String get readerModeContinuousHorizontalLTR =>
      'Непрерывный горизонтальный (LTR)';

  @override
  String get readerModeContinuousHorizontalRTL =>
      'Непрерывный горизонтальный (RTL)';

  @override
  String get readerModeContinuousVertical => 'Непрерывный вертикальный';

  @override
  String get readerModeDefaultReader => 'По умолчанию';

  @override
  String get readerModeSingleHorizontalLTR => 'Одиночный горизонтальный (LTR)';

  @override
  String get readerModeSingleHorizontalRTL => 'Одиночный горизонтальный (RTL)';

  @override
  String get readerModeSingleVertical => 'Одиночный вертикальный';

  @override
  String get readerModeWebtoon => 'Вебтун';

  @override
  String get readerNavigationLayout => 'Схема системы жестов';

  @override
  String get readerNavigationLayoutDefault => 'По умолчанию';

  @override
  String get readerNavigationLayoutDisabled => 'Отключено';

  @override
  String get readerNavigationLayoutEdge => 'Край';

  @override
  String get readerNavigationLayoutInvert => 'Инвертированное касание';

  @override
  String get readerNavigationLayoutKindlish => 'Kindle-ish';

  @override
  String get readerNavigationLayoutLShaped => 'L-формы';

  @override
  String get readerNavigationLayoutRightAndLeft => 'Справа и Слева';

  @override
  String get readerOverlay => 'Оверлей';

  @override
  String get readerOverlaySubtitle =>
      'Отображение заголовка и быстрых настроек при открытии главы';

  @override
  String get readerPadding => 'Вместить изображения';

  @override
  String get readerScrollAnimation => 'Анимация прокрутки';

  @override
  String get readerSwipeChapterToggle => 'Пролистывание с помощью свайпа';

  @override
  String get readerSwipeChapterToggleDescription =>
      'Зажмите ЛКМ и проведите по экрану, чтобы переключить главу в читалке';

  @override
  String get readerLastPageSwipeToggle => 'Last page swipe';

  @override
  String get readerLastPageSwipeToggleDescription =>
      'Swipe to next chapter only at last page';

  @override
  String get readerVolumeTap => 'Клавиши громкости';

  @override
  String get readerVolumeTapInvert => 'Инвертировать клавиши громкости';

  @override
  String get readerVolumeTapSubtitle => 'Навигация при помощи клавиш громкости';

  @override
  String get readerIgnoreSafeAreaToggle => 'Ignore Safe Area';

  @override
  String get readerIgnoreSafeAreaToggleDescription =>
      'Allow content to extend into notch and home indicator areas';

  @override
  String get reddit => 'Reddit';

  @override
  String get refresh => 'Обновить';

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
  String get source => 'Источник';

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
  String get reload => 'Перезагрузить';

  @override
  String get remove => 'Удалить';

  @override
  String get removeFromLibrary => 'Удалить из библиотеки?';

  @override
  String get reset => 'Сброс';

  @override
  String get restore => 'Restore';

  @override
  String get restoreBackupDescription =>
      'Восстановить Tachidesk из резервной копии';

  @override
  String get restoreBackupTitle => 'Восстановить';

  @override
  String get restored => 'Восстановлено!';

  @override
  String get restoring => 'Восстановлено';

  @override
  String get resume => 'Возобновить';

  @override
  String get retry => 'Повторить';

  @override
  String get running => 'Начато';

  @override
  String get save => 'Сохранить';

  @override
  String get saveAsCBZArchive => 'Save as CBZ archive';

  @override
  String get scanlators => 'Сканлейт';

  @override
  String get search => 'Поиск';

  @override
  String get searchingForUpdates => 'Поиск обновлений';

  @override
  String get selectInBetween => 'Выбрать между';

  @override
  String get selectNext10 => 'Выберите следующий 10';

  @override
  String get selectUnread => 'Выберите Непрочитанное';

  @override
  String get server => 'Сервер';

  @override
  String get serverBindings => 'Server Bindings';

  @override
  String get serverPort => 'Порт сервера';

  @override
  String get serverPortHintText => 'Введите порт сервера';

  @override
  String get serverUrl => 'URL-адрес сервера';

  @override
  String get serverUrlHintText => 'Введите адрес сервера';

  @override
  String get serverVersion => 'Версия сервера';

  @override
  String get settings => 'Настройки';

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
  String get sort => 'Сортировать';

  @override
  String get sourceTypeFilter => 'Фильтр';

  @override
  String get sourceTypeLatest => 'Последний';

  @override
  String get sourceTypePopular => 'Популярное';

  @override
  String get sources => 'Источники';

  @override
  String get start => 'Начать';

  @override
  String get systemTrayIcon => 'Show icon in system tray';

  @override
  String get thatHaventBeenStarted => 'That haven\'t been started';

  @override
  String get themeModeDark => 'Темный';

  @override
  String get themeModeLight => 'Светлый';

  @override
  String get themeModeSystem => 'Системный';

  @override
  String get today => 'Сегодня';

  @override
  String get uninstall => 'Удалить';

  @override
  String get uninstalling => 'Удаление';

  @override
  String get unknownAuthor => 'Неизвестный автор';

  @override
  String get unknownManga => 'Неизвестная манга';

  @override
  String get unknownSource => 'Неизвестный источник';

  @override
  String get unread => 'Не прочитано';

  @override
  String get update => 'Обновить';

  @override
  String get updateCompleted => 'Обновление завершено';

  @override
  String updateFailed(Object property) {
    return 'Failed to update $property';
  }

  @override
  String get updates => 'Обновления';

  @override
  String get updatesSummary => 'Сводка обновлений';

  @override
  String get updating => 'Обновляется';

  @override
  String get userName => 'Имя пользователя';

  @override
  String get validating => 'Validating';

  @override
  String versionAvailable(String app, String version) {
    return 'Версия $version доступна для $app!!';
  }

  @override
  String get webUI => 'Открыть в Веб';

  @override
  String get webView => 'Веб-просмотр';

  @override
  String get whatsNew => 'Что нового?';

  @override
  String get withCompletedStatus => 'With Completed status';

  @override
  String get withUnreadChapter => 'With unread chapter(s)';

  @override
  String get yesterday => 'Вчера';

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
