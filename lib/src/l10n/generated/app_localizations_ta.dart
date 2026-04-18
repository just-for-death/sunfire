// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get about => 'பற்றி';

  @override
  String get addCategory => 'வகையைச் சேர்க்கவும்';

  @override
  String get addToLibrary => 'நூலகத்தில் சேர்க்கவும்';

  @override
  String get advanced => 'மேம்பட்ட';

  @override
  String get allScanlators => 'அனைத்து ச்கேன்லேட்டர்களும்';

  @override
  String get appLanguage => 'பயன்பாட்டு மொழி';

  @override
  String get appTheme => 'பயன்பாட்டு கருப்பொருள் பயன்முறை';

  @override
  String get appTitle => 'சோரயோமி';

  @override
  String get appearance => 'தோற்றம்';

  @override
  String get authType => 'அங்கீகார வகை';

  @override
  String get authTypeBasic => 'அடிப்படை ஏற்பு';

  @override
  String get authTypeNone => 'எதுவுமில்லை';

  @override
  String get authentication => 'ஏற்பு';

  @override
  String get autoDownload => 'ஆட்டோ-டவுன்லோட்';

  @override
  String get autoDownloadNewChapters => 'புதிய அத்தியாயங்களைப் பதிவிறக்கவும்';

  @override
  String get automaticBackup => 'தானியங்கி காப்புப்பிரதி';

  @override
  String get automaticUpdate => 'தானியங்கி புதுப்பிப்பு';

  @override
  String get automaticallyRefreshMetadata =>
      'மெட்டாடேட்டாவை தானாக புதுப்பிக்கவும்';

  @override
  String get automaticallyRefreshMetadataSubtitle =>
      'நூலகத்தைப் புதுப்பிக்கும்போது புதிய கவர் மற்றும் விவரங்களைச் சரிபார்க்கவும்';

  @override
  String get backup => 'காப்புப்பிரதி மற்றும் மீட்டமை';

  @override
  String get backupAndRestore => 'காப்புப்பிரதி மற்றும் மீட்டமை';

  @override
  String get backupCleanup => 'காப்புப்பிரதி தூய்மைப்படுத்துதல்';

  @override
  String backupCleanupDescription(String count) {
    String _temp0 = intl.Intl.selectLogic(
      count,
      {
        '0': 'Never',
        '01': 'Delete Backups that are older 1 day',
        'other': 'பழைய காப்புப்பிரதிகளை நீக்கு $count நாட்கள்',
      },
    );
    return '$_temp0';
  }

  @override
  String get backupInterval => 'காப்பு இடைவெளி';

  @override
  String get backupLocation => 'காப்புப்பிரதி இருப்பிடம்';

  @override
  String get backupLocationDescription =>
      'தானியங்கி காப்புப்பிரதிகள் சேமிக்கப்பட வேண்டிய சேவையகத்தில் கோப்பகத்திற்கான பாதை';

  @override
  String get backupTime => 'காப்புப்பிரதி நேரம்';

  @override
  String get badges => 'பேட்ச்கள்';

  @override
  String get bookmarked => 'புக்மார்க்கு செய்யப்பட்டது';

  @override
  String get browse => 'உலாவு';

  @override
  String get buildTime => 'நேரத்தை உருவாக்குங்கள்';

  @override
  String get cacheCleared => 'கேச் அழிக்கப்பட்டது';

  @override
  String get cancel => 'ரத்துசெய்';

  @override
  String get categories => 'வகைகள்';

  @override
  String get categoryUpdate => 'வகை புதுப்பிப்பு';

  @override
  String get channel => 'வாய்க்கால்';

  @override
  String get chapterDownloadLimit => 'அத்தியாயம் பதிவிறக்க வரம்பு';

  @override
  String get chapterDownloadLimitDesc =>
      'பதிவிறக்கம் செய்யப் போகும் புதிய அத்தியாயங்களின் அளவைக் கட்டுப்படுத்துங்கள்.';

  @override
  String chapterNumber(double number) {
    return 'அத்தியாயம் $number';
  }

  @override
  String get chapterSortFetchedDate => 'தேதியைப் பெற்றதன் மூலம்';

  @override
  String get chapterSortSource => 'மூலத்தால்';

  @override
  String get chapterSortUploadDate => 'பதிவேற்றுவதன் மூலம்';

  @override
  String get checkForServerUpdates => 'சேவையக புதுப்பிப்புகளை சரிபார்க்கவும்';

  @override
  String get checkForUpdates => 'புதுப்பிப்புகளை சரிபார்க்கவும்';

  @override
  String get clearCache => 'தெளிவான தற்காலிக சேமிப்பு';

  @override
  String get client => 'கிளீன்';

  @override
  String get clientVersion => 'கிளீன் பதிப்பு';

  @override
  String get close => 'மூடு';

  @override
  String get cloudflareBypass => 'கிளவுட்ஃப்ளேர் பைபாச்';

  @override
  String get completed => 'முடிந்தது';

  @override
  String get copied => 'நகலெடுக்கப்பட்டது!';

  @override
  String copyMsg(String msg) {
    return '\'$msg\' நகலெடுக்கப்பட்டது!';
  }

  @override
  String get createBackupDescription =>
      'டச்சிடெச்க் காப்புப்பிரதியாக காப்பு நூலகம்';

  @override
  String get createBackupTitle => 'காப்புப்பிரதியை உருவாக்கவும்';

  @override
  String get credentials => 'நற்சான்றிதழ்கள்';

  @override
  String get current => 'மின்னோட்ட்ம், ஓட்டம்';

  @override
  String daysAgo(Object days) {
    return '$days சில நாட்களுக்கு முன்பு';
  }

  @override
  String get debugLogs => 'பிழைத்திருத்த பதிவுகள்';

  @override
  String get defaultCategory =>
      'புதிய மங்காவை நூலகத்தில் சேர்க்கும்போது இயல்புநிலை வகை';

  @override
  String get delete => 'நீக்கு';

  @override
  String get deleteCategoryDescription =>
      'இது இந்த பிரிவில் உள்ள அனைத்து மங்காவையும் இயல்புநிலைக்கு இணைக்கும்!';

  @override
  String get deleteCategoryTitle => 'நீங்கள் உறுதியாக இருக்கிறீர்களா?';

  @override
  String get discord => 'முரண்பாடு';

  @override
  String get display => 'காட்சி';

  @override
  String get displayMode => 'காட்சி முறை';

  @override
  String get displayModeDescriptiveList => 'விளக்க பட்டியல்';

  @override
  String get displayModeGrid => 'வலைவாய்';

  @override
  String get displayModeList => 'பட்டியல்';

  @override
  String get downloadLocation => 'இருப்பிடத்தைப் பதிவிறக்கவும்';

  @override
  String get downloadLocationHint =>
      'பதிவிறக்கம் செய்யப்பட்ட கோப்புகள் சேமிக்கப்பட வேண்டிய சேவையகத்தில் கோப்பகத்திற்கான பாதை';

  @override
  String get downloaded => 'பதிவிறக்கம்';

  @override
  String get downloading => 'பதிவிறக்குகிறது';

  @override
  String get downloads => 'பதிவிறக்கங்கள்';

  @override
  String get edit => 'தொகு';

  @override
  String get editCategory => 'வகையைத் திருத்து';

  @override
  String get emptyCategory => 'வகை பெயர் காலியாக இருக்க முடியாது';

  @override
  String get enableSocksProxy => 'சாக்ச் ப்ராக்சியைப் பயன்படுத்தவும்';

  @override
  String enterProp(Object prop) {
    return '$prop உள்ளிடவும்';
  }

  @override
  String get error => 'பிழை';

  @override
  String get errorBackupCreate => 'காப்புப்பிரதியை உருவாக்கத் தவறிவிட்டது';

  @override
  String get errorBackupRestore => 'காப்புப்பிரதியை மீட்டெடுப்பதில் தோல்வி!';

  @override
  String get errorExtension =>
      'தேர்ந்தெடுக்கப்பட்ட நீட்டிப்பைக் கண்டுபிடிக்க முடியவில்லை';

  @override
  String get errorFilePick => 'கோப்பு தேர்ந்தெடுக்கப்படவில்லை!';

  @override
  String errorFilePickUnknownExtension(Object extensionName) {
    return '$extensionName நீட்டிப்புடன் ஒரு கோப்பைத் தேர்ந்தெடுக்கவும்';
  }

  @override
  String errorLaunchURL(String url) {
    return 'திறக்கத் தவறிவிட்டது!\n இடைநிலைப்பலகைக்கு \"$url\" ஐ நகலெடுக்கிறது';
  }

  @override
  String get errorPassword => 'கடவுச்சொல் காலியாக இருக்க முடியாது';

  @override
  String get errorSomethingWentWrong => 'ஏதோ தவறு நடந்தது!';

  @override
  String get errorUserName => 'பயனர்பெயர் காலியாக இருக்க முடியாது';

  @override
  String get excludeEntryWithUnreadChapters =>
      'படிக்காத அத்தியாயங்களுடன் உள்ளீடுகளுக்கான தானியங்கி அத்தியாய பதிவிறக்கங்களை புறக்கணிக்கவும்';

  @override
  String get extensionInstalled => 'நீட்டிப்பு நிறுவப்பட்டது!';

  @override
  String get extensionListEmpty => 'நீட்டிப்பு பட்டியல் காலியாக உள்ளது';

  @override
  String get extensionRepository => 'நீட்டிப்பு களஞ்சியம்';

  @override
  String get extensionRepositoryDescription =>
      'நீட்டிப்புகளை நிறுவக்கூடிய களஞ்சியங்களைச் சேர்க்கவும்';

  @override
  String get extensions => 'நீட்டிப்புகள்';

  @override
  String get failed => 'தோல்வியுற்றது';

  @override
  String get filter => 'வடிப்பி';

  @override
  String get findServer => 'கண்டுபிடி';

  @override
  String get finished => 'முடிந்தது';

  @override
  String get flareSolverr => 'FLARESOLVERR';

  @override
  String get flareSolverrRequestTimeout =>
      'Felaresolverr கோரிக்கை நேரம் முடிந்தது';

  @override
  String get flareSolverrServerUrl => 'FLARESOLVERR சேவையகம் முகவரி';

  @override
  String get flareSolverrSessionName => 'FLARESOLVERR அமர்வு பெயர்';

  @override
  String get flareSolverrSessionTTL => 'FLARESOLVERR அமர்வு ttl';

  @override
  String get general => 'பொது';

  @override
  String get gitHub => 'கிரப்';

  @override
  String get globalSearch => 'உலக தேடல்';

  @override
  String get globalUpdate => 'உலகளாவிய புதுப்பிப்பு';

  @override
  String get gqlDebugLogs => 'கிராஃபிக்யூஎல் பிழைத்திருத்த பதிவுகள்';

  @override
  String get gqlDebugLogsHint =>
      'தனியுரிமை அல்லாத பாதுகாப்பான தகவல்களுடன் பதிவுகள் இதில் அடங்கும்';

  @override
  String get help => 'உதவி';

  @override
  String get hideEmptyCategory => 'வெற்று வகையை மறைக்கவும்';

  @override
  String get inLibrary => 'நூலகத்தில்';

  @override
  String get includeCategories => 'வகைகள்';

  @override
  String get includeChapters => 'பாடங்கள்';

  @override
  String get install => 'நிறுவவும்';

  @override
  String get installing => 'நிறுவுகிறது';

  @override
  String get installingExtension => 'நீட்டிப்பை நிறுவுதல்';

  @override
  String get invalidPort => 'தவறான துறைமுகம்';

  @override
  String invalidProp(Object property) {
    return 'தவறான $property';
  }

  @override
  String get ip => 'ஐபி முகவரி';

  @override
  String get ipHintText => 'சேவையக பிணைப்பு ஐபி முகவரியை உள்ளிடவும்';

  @override
  String get isTrueBlack => 'உண்மையான கருப்பு';

  @override
  String get languages => 'மொழிகள்';

  @override
  String get latest => 'அண்மைக் கால';

  @override
  String get library => 'நூலகம்';

  @override
  String get localSourceLocation => 'உள்ளக மூல இடம்';

  @override
  String get localSourceLocationDescription =>
      'உள்ளக மூல கோப்புகள் சேமிக்கப்படும் சேவையகத்தில் கோப்பகத்திற்கான பாதை';

  @override
  String get manga => 'மங்கா';

  @override
  String get mangaGridSize => 'மங்கா கட்டம் அளவு';

  @override
  String get mangaMissingSources => 'மங்கா காணாமல் போன ஆதாரங்கள்';

  @override
  String get mangaSortAlphabetical => 'அகரவரிசை';

  @override
  String get mangaSortDateAdded => 'தேதி சேர்க்கப்பட்டது';

  @override
  String get mangaSortLastRead => 'கடைசியாக படியுங்கள்';

  @override
  String get mangaSortLastUpdated => 'கடைசியாக புதுப்பிக்கப்பட்டது';

  @override
  String get mangaSortUnread => 'படிக்காதது';

  @override
  String get mangaStatusCancelled => 'ரத்து செய்யப்பட்டது';

  @override
  String get mangaStatusCompleted => 'முடிந்தது';

  @override
  String get mangaStatusLicensed => 'உரிமம்';

  @override
  String get mangaStatusOnHiatus => 'இடைவெளியில்';

  @override
  String get mangaStatusOngoing => 'நடந்து கொண்டிருக்கிறது';

  @override
  String get mangaStatusPublishingFinished => 'வெளியீடு முடிந்தது';

  @override
  String get mangaStatusUnknown => 'தெரியவில்லை';

  @override
  String get misc => 'இதர';

  @override
  String get missingExtension => 'நீட்டிப்புகளைக் காணவில்லை';

  @override
  String get missingTrackers => 'காணாமல் போன டிராக்கர்கள்';

  @override
  String get more => 'மேலும்';

  @override
  String get moveToBottom => 'கீழே செல்லுங்கள்';

  @override
  String get moveToTop => 'மேலே செல்லுங்கள்';

  @override
  String nChapters(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n அத்தியாயங்கள்',
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
        '01': '1 Day',
        'other': '$count நாட்கள்',
      },
    );
    return '$_temp0';
  }

  @override
  String nHours(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n மணிநேரம்',
      one: '1 hour',
    );
    return '$_temp0';
  }

  @override
  String nMinutes(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n நிமிடங்கள்',
      one: '1 Minute',
    );
    return '$_temp0';
  }

  @override
  String nRepo(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n repos',
      one: '1 Repo',
    );
    return '$_temp0';
  }

  @override
  String nSeconds(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n விநாடிகள்',
      one: '1 second',
    );
    return '$_temp0';
  }

  @override
  String nSources(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n மூலங்கள்',
      one: '1 Source',
    );
    return '$_temp0';
  }

  @override
  String nameCountDisplay(int count, String name) {
    return '$name: $count';
  }

  @override
  String get newUpdateAvailable => 'புதிய புதுப்பிப்பு கிடைக்கிறது';

  @override
  String get navHome => 'Home';

  @override
  String get navMenu => 'Menu';

  @override
  String get navOverflowSheetTitle => 'Go to';

  @override
  String nextChapter(Object chapterTitle) {
    return 'அடுத்து: $chapterTitle';
  }

  @override
  String get noCategoriesFound =>
      'உங்களிடம் எந்த வகைகளும் இல்லை.\n (உதவிக்குறிப்பு: உங்கள் நூலகத்தை ஒழுங்கமைக்க ஒன்றை உருவாக்க பிளச் பொத்தானைத் தட்டவும்)';

  @override
  String get noCategoriesFoundAlt =>
      'உங்களிடம் எந்த வகைகளும் இல்லை.\n உங்கள் நூலகத்தை ஒழுங்கமைக்க அமைப்புகளில் ஒன்றை உருவாக்கவும்';

  @override
  String get noCategoryMangaFound =>
      'இந்த வகையில் எந்த மங்காவும் காணப்படவில்லை.\n (உதவிக்குறிப்பு: உங்கள் தேடல் மற்றும் வடிப்பான்களை சரிபார்க்கவும்!)';

  @override
  String get noChaptersFound => 'அத்தியாயங்கள் எதுவும் கிடைக்கவில்லை';

  @override
  String get noDownloads => 'பதிவிறக்கங்கள் இல்லை';

  @override
  String get noMangaFound => 'மங்காக்கள் எதுவும் கிடைக்கவில்லை';

  @override
  String noOfChapters(int count) {
    return '$count அத்தியாயங்கள்';
  }

  @override
  String noPropFound(Object prop) {
    return 'இல்லை $prop காணப்படுகிறது';
  }

  @override
  String get noResultFound => 'முடிவுகள் எதுவும் கிடைக்கவில்லை';

  @override
  String get noServerFound =>
      'உங்கள் உள்ளக நெட்வொர்க்கில் சேவையகம் எதுவும் காணப்படவில்லை';

  @override
  String get noSourcesFound => 'ஆதாரங்கள் எதுவும் கிடைக்கவில்லை';

  @override
  String get noUpdatesAvailable =>
      'நீங்கள் அண்மைக் கால பதிப்பைப் பயன்படுத்துகிறீர்கள்';

  @override
  String get noUpdatesFound => 'புதுப்பிப்புகள் எதுவும் கிடைக்கவில்லை';

  @override
  String get none => 'எதுவுமில்லை';

  @override
  String get nsfw => 'NSFW நீட்டிப்புகள் மற்றும் ஆதாரங்களைக் காட்டு';

  @override
  String get nsfw18 => '18+';

  @override
  String get nsfwInfo =>
      'இது பயன்பாட்டில் NSFW (18+) உள்ளடக்கத்தை வெளிப்படுத்துவதிலிருந்து அதிகாரப்பூர்வமற்ற அல்லது தவறான கொடிய நீட்டிப்புகளைத் தடுக்காது';

  @override
  String numSelected(int num) {
    return '$num தேர்ந்தெடுக்கப்பட்டது';
  }

  @override
  String get obsolete => 'வழக்கற்றுப்போன';

  @override
  String get openFlareSolverr =>
      'அதை எவ்வாறு அமைப்பது என்பது குறித்த தகவலுக்கு Fectout Flaresolverr';

  @override
  String get openInWeb => 'வலையில் திறந்திருக்கும்';

  @override
  String get or => 'அல்லது';

  @override
  String page(int number) {
    return 'பக்கம்: $number';
  }

  @override
  String get parallelSourceRequest => 'இணை மூல கோரிக்கைகள்';

  @override
  String get password => 'கடவுச்சொல்';

  @override
  String get pause => 'இடைநிறுத்தம்';

  @override
  String get pending => 'நிலுவையில் உள்ளது';

  @override
  String get pinchToZoom => 'பெரிதாக்க கிள்ளுதல்';

  @override
  String previousChapter(Object chapterTitle) {
    return 'முந்தைய: $chapterTitle';
  }

  @override
  String get queued => 'வரிசையில்';

  @override
  String get quickSearch => 'விரைவான தேடல்';

  @override
  String get quickSearchCategory => '\'சி\' வகைக்குச் செல்லுங்கள்';

  @override
  String get quickSearchCategoryManga =>
      '\'சி\' பிரிவில் மங்கா \'எம்\' க்குச் செல்லுங்கள்';

  @override
  String get quickSearchCategoryMangaChapter =>
      '\'சி\' பிரிவில் மங்கா \'எம்\' இலிருந்து \'சிஎன்\' என்ற அத்தியாயத்தின் பெயருக்குச் செல்லுங்கள்';

  @override
  String get quickSearchContext =>
      'வினவல் ஃச் ஐத் தேடுங்கள் (முடிவுகள் திரை சூழலை அடிப்படையாகக் கொண்டவை)';

  @override
  String get quickSearchShowAllCommandTip =>
      'உதவிக்குறிப்பு: உள்ளிடவும் \'?\' எல்லா கட்டளைகளையும் காண';

  @override
  String get quickSearchSource => 'மூலத்திற்குச் செல்லுங்கள் \'கள்\'';

  @override
  String get quickSearchSourceManga =>
      'மூலத்தில் மங்கா \'எம்\' ஐத் தேடுங்கள் \'எச்\'';

  @override
  String get reader => 'வாசகர்';

  @override
  String get readerMagnifierSize => 'உருப்பெருக்கி அளவு';

  @override
  String get readerMode => 'படித்தல் பயன்முறை';

  @override
  String get readerModeContinuousHorizontalLTR =>
      'தொடர்ச்சியான கிடைமட்ட (எல்.டி.ஆர்)';

  @override
  String get readerModeContinuousHorizontalRTL =>
      'தொடர்ச்சியான கிடைமட்ட (ஆர்.டி.எல்)';

  @override
  String get readerModeContinuousVertical => 'தொடர்ச்சியான செங்குத்து';

  @override
  String get readerModeDefaultReader => 'இயல்புநிலை';

  @override
  String get readerModeSingleHorizontalLTR => 'ஒற்றை கிடைமட்ட (எல்.டி.ஆர்)';

  @override
  String get readerModeSingleHorizontalRTL => 'ஒற்றை கிடைமட்ட (ஆர்.டி.எல்)';

  @override
  String get readerModeSingleVertical => 'ஒற்றை செங்குத்து';

  @override
  String get readerModeWebtoon => 'வெப்டூன்';

  @override
  String get readerNavigationLayout => 'வழிசெலுத்தல் தளவமைப்பு';

  @override
  String get readerNavigationLayoutDefault => 'இயல்புநிலை';

  @override
  String get readerNavigationLayoutDisabled => 'முடக்கப்பட்டது';

  @override
  String get readerNavigationLayoutEdge => 'விளிம்பு';

  @override
  String get readerNavigationLayoutInvert => 'தலைகீழ் தட்டுதல்';

  @override
  String get readerNavigationLayoutKindlish => 'கின்டெல்-இச்';

  @override
  String get readerNavigationLayoutLShaped => 'எல் வடிவ';

  @override
  String get readerNavigationLayoutRightAndLeft => 'வலது மற்றும் இடது';

  @override
  String get readerOverlay => 'வாசகர் ஆரம்ப மேலடுக்கு';

  @override
  String get readerOverlaySubtitle =>
      'ஒரு அத்தியாயத்தைத் திறக்கும்போது தலைப்பு மற்றும் விரைவான அமைப்புகளைக் காட்டுகிறது';

  @override
  String get readerPadding => 'வாசகர் திணிப்பு';

  @override
  String get readerScrollAnimation => 'உருள் அனிமேசன்';

  @override
  String get readerSwipeChapterToggle => 'மாற்றுவதை ச்வைப் செய்யுங்கள்';

  @override
  String get readerSwipeChapterToggleDescription =>
      'வாசகரில் அத்தியாயத்தை மாற்ற ச்வைப் செய்யவும்';

  @override
  String get readerLastPageSwipeToggle => 'Last page swipe';

  @override
  String get readerLastPageSwipeToggleDescription =>
      'Swipe to next chapter only at last page';

  @override
  String get readerVolumeTap => 'தொகுதி விசைகள்';

  @override
  String get readerVolumeTapInvert => 'தொகுதி விசைகள் தலைகீழ்';

  @override
  String get readerVolumeTapSubtitle => 'தொகுதி விசைகளுடன் செல்லவும்';

  @override
  String get readerIgnoreSafeAreaToggle => 'Ignore Safe Area';

  @override
  String get readerIgnoreSafeAreaToggleDescription =>
      'Allow content to extend into notch and home indicator areas';

  @override
  String get reddit => 'ரெடிட்';

  @override
  String get refresh => 'புதுப்பிப்பு';

  @override
  String get migrate => 'இடம்பெயர்வு';

  @override
  String get migrationSelectTargetSource =>
      'இலக்கு மூலத்தைத் தேர்ந்தெடுக்கவும்';

  @override
  String migrationSearchInSource(Object sourceName) {
    return '$sourceName இல் தேடு';
  }

  @override
  String get migrationPreview => 'இடம்பெயர்வு முன்னோட்டம்';

  @override
  String get migrationInProgress => 'இடம்பெயர்வு முன்னேற்றம்';

  @override
  String get migrationComplete => 'இடம்பெயர்வு வெற்றிகரமாக முடிந்தது';

  @override
  String get migrationFailed => 'இடம்பெயர்வு தோல்வியடைந்தது';

  @override
  String get migrationCancelled => 'இடம்பெயர்வு ரத்து செய்யப்பட்டது';

  @override
  String get migrateChapters => 'அத்தியாயங்கள் இடம்பெயர்';

  @override
  String get migrateChaptersDescription =>
      'புதிய மூலத்திற்கு அத்தியாயத்தை படிக்கவும்';

  @override
  String get migrateCategories => 'இடம்பெயர் வகைகள்';

  @override
  String get migrateCategoriesDescription =>
      'மங்கா வகைகளை புதிய மூலத்திற்கு நகலெடுக்கவும்';

  @override
  String get migrateDownloads => 'பதிவிறக்கங்களை மாற்றவும்';

  @override
  String get migrateDownloadsDescription =>
      'பதிவிறக்கம் செய்யப்பட்ட அத்தியாயங்களை புதிய மூலத்திற்கு நகர்த்தவும்';

  @override
  String get migrateTracking => 'கண்காணிப்பு இடம்பெயர்';

  @override
  String get migrateTrackingDescription =>
      'கண்காணிப்பு தகவல்களை புதிய மூலத்திற்கு நகலெடுக்கவும்';

  @override
  String get migrationOptions => 'இடம்பெயர்வு விருப்பங்கள்';

  @override
  String get migrationSettings => 'இடம்பெயர்வு அமைப்புகள்';

  @override
  String get selectTargetSource => 'இலக்கு மூலத்தைத் தேர்ந்தெடுக்கவும்';

  @override
  String get noSourcesAvailable =>
      'இடம்பெயர்வுக்கு ஆதாரங்கள் எதுவும் கிடைக்கவில்லை';

  @override
  String get checkSourceConfiguration => 'உங்கள் மூல உள்ளமைவை சரிபார்க்கவும்';

  @override
  String get noAlternativeSources => 'மாற்று ஆதாரங்கள் எதுவும் கிடைக்கவில்லை';

  @override
  String get installMoreSources =>
      'இடம்பெயர்வு செயல்படுத்த கூடுதல் ஆதாரங்களை நிறுவவும்';

  @override
  String get errorLoadingSources => 'ஆதாரங்களை ஏற்றுவதில் பிழை';

  @override
  String get errorGettingMigrationSources =>
      'Failed பெறுநர் get குடிபெயர்வு மூலங்கள்';

  @override
  String get errorSearchingMangaInSource =>
      'மங்காவை மூலத்தில் தேடத் தவறிவிட்டது';

  @override
  String get errorFetchingSourceManga => 'மூல மங்காவைப் பெறுவதில் தோல்வி';

  @override
  String get errorSourceMangaNotFound => 'மூல மங்கா கண்டுபிடிக்கப்படவில்லை';

  @override
  String get errorFetchingTargetManga => 'இலக்கு மங்காவைப் பெறுவதில் தோல்வி';

  @override
  String get errorTargetMangaNotFound => 'இலக்கு மங்கா கிடைக்கவில்லை';

  @override
  String get searchManga => 'மங்காவைத் தேடுங்கள் ...';

  @override
  String get searchForManga => 'இலக்கு மூலத்தில் மங்காவைத் தேடுங்கள்';

  @override
  String get enterSearchTerm =>
      'மங்காவைக் கண்டுபிடிக்க ஒரு தேடல் காலத்தை உள்ளிடவும்';

  @override
  String get noResultsFound => 'முடிவுகள் எதுவும் கிடைக்கவில்லை';

  @override
  String get tryDifferentSearch => 'வேறு தேடல் காலத்தை முயற்சிக்கவும்';

  @override
  String get searchError => 'தேடல் பிழை';

  @override
  String get importantNotice => 'முக்கியமான அறிவிப்பு';

  @override
  String get migrationWarning =>
      'இது உங்கள் மங்கா தரவை நிரந்தரமாக நகர்த்தும். இந்த செயலை செயல்தவிர்க்க முடியாது.';

  @override
  String get deleteSourceWarning =>
      'இடம்பெயர்வுக்குப் பிறகு அசல் மங்கா உங்கள் நூலகத்திலிருந்து அகற்றப்படும்.';

  @override
  String get confirmMigration => 'இடம்பெயர்வு உறுதிப்படுத்தவும்';

  @override
  String get migrationConfirmationMessage =>
      'இந்த மங்காவை நீங்கள் நிச்சயமாக மாற்ற விரும்புகிறீர்களா? இந்த செயலை செயல்தவிர்க்க முடியாது.';

  @override
  String get startMigration => 'இடம்பெயர்வு தொடங்கவும்';

  @override
  String get preparingMigration => 'இடம்பெயர்வு தயாரித்தல் ...';

  @override
  String get migrationCompleted => 'இடம்பெயர்வு முடிந்தது!';

  @override
  String get migrationSuccessMessage =>
      'உங்கள் மங்கா வெற்றிகரமாக புதிய மூலத்திற்கு இடம்பெயர்ந்துள்ளது.';

  @override
  String get migrationCancelledMessage =>
      'இடம்பெயர்வு செயல்முறை ரத்து செய்யப்பட்டுள்ளது. எந்த மாற்றங்களும் செய்யப்படவில்லை.';

  @override
  String get cancelMigration => 'இடம்பெயர்வு நீக்கறல்';

  @override
  String get cancelMigrationConfirmation =>
      'இடம்பெயர்வுகளை ரத்து செய்ய விரும்புகிறீர்களா? இந்த செயலை செயல்தவிர்க்க முடியாது.';

  @override
  String get quickPresets => 'விரைவான முன்னமைவுகள்';

  @override
  String get quickMigration => 'விரைவான';

  @override
  String get fullMigration => 'முழு';

  @override
  String get customMigration => 'தனிப்பயன்';

  @override
  String get deleteSourceManga => 'மூல மங்காவை நீக்கு';

  @override
  String get deleteSourceMangaDescription =>
      'இடம்பெயர்வுக்குப் பிறகு நூலகத்திலிருந்து அசல் மங்காவை அகற்றவும்';

  @override
  String get done => 'முடிந்தது';

  @override
  String get yes => 'ஆம்';

  @override
  String get no => 'இல்லை';

  @override
  String get from => 'இருந்து';

  @override
  String get to => 'பெறுநர்';

  @override
  String get source => 'மூலம்';

  @override
  String get migrationDetails => 'இடம்பெயர்வு விவரங்கள்';

  @override
  String get searchAllSources => 'அனைத்து ஆதாரங்களையும் தேடுங்கள்';

  @override
  String get searchingAllSources =>
      'கிடைக்கக்கூடிய அனைத்து ஆதாரங்களிலும் தேடுகிறது ...';

  @override
  String get noMatchingMangaFound =>
      'எந்தவொரு மூலத்திலும் பொருந்தக்கூடிய மங்கா இல்லை';

  @override
  String get deleteSourceAfterMigration =>
      'இடம்பெயர்வுக்குப் பிறகு மூல மங்காவை நீக்கு';

  @override
  String get reload => 'ஏற்றவும்';

  @override
  String get remove => 'அகற்று';

  @override
  String get removeFromLibrary => 'நூலகத்திலிருந்து அகற்றவா?';

  @override
  String get reset => 'மீட்டமை';

  @override
  String get restore => 'மீட்டமை';

  @override
  String get restoreBackupDescription =>
      'காப்புப்பிரதியிலிருந்து டச்சிடெச்கை மீட்டெடுக்கவும்';

  @override
  String get restoreBackupTitle => 'காப்புப்பிரதியை மீட்டமைக்கவும்';

  @override
  String get restored => 'காப்புப்பிரதி மீட்டெடுக்கப்பட்டது!';

  @override
  String get restoring => 'காப்புப்பிரதியை மீட்டமைத்தல்';

  @override
  String get resume => 'மீண்டும் தொடங்குங்கள்';

  @override
  String get retry => 'மீண்டும் முயற்சிக்கவும்';

  @override
  String get running => 'இயங்கும்';

  @override
  String get save => 'சேமி';

  @override
  String get saveAsCBZArchive => 'சிபிஇசட் காப்பகமாக சேமிக்கவும்';

  @override
  String get scanlators => 'ச்கேன்லேட்டர்கள்';

  @override
  String get search => 'தேடல்';

  @override
  String get searchingForUpdates => 'புதுப்பிப்புகளைத் தேடுகிறது';

  @override
  String get selectInBetween => 'இடையில் தேர்ந்தெடுக்கவும்';

  @override
  String get selectNext10 => 'அடுத்த 10 ஐத் தேர்ந்தெடுக்கவும்';

  @override
  String get selectUnread => 'படிக்கத் தேர்ந்தெடுக்கவும்';

  @override
  String get server => 'சேவையகம்';

  @override
  String get serverBindings => 'சேவையக பிணைப்புகள்';

  @override
  String get serverPort => 'சேவையகம் துறைமுகம்';

  @override
  String get serverPortHintText => 'சேவையக துறைமுகம்';

  @override
  String get serverUrl => 'சேவையக முகவரி';

  @override
  String get serverUrlHintText => 'சேவையக முகவரி';

  @override
  String get serverVersion => 'சேவையக பதிப்பு';

  @override
  String get serverUnreachableTitle => 'Server unreachable';

  @override
  String get serverUnreachableBody =>
      'Make sure Suwayomi Server is running and the URL is correct in Settings.';

  @override
  String get serverRetryButton => 'Retry';

  @override
  String get serverOpenSettingsButton => 'Server settings';

  @override
  String get serverOfflineBanner => 'Server offline — tap retry';

  @override
  String get serverOfflineRetryA11y => 'Retry connection';

  @override
  String get serverOfflineDismissA11y => 'Dismiss offline notice';

  @override
  String get settings => 'அமைப்புகள்';

  @override
  String get skipUpdatingEntries => 'உள்ளீடுகளைப் புதுப்பிப்பதைத் தவிர்க்கவும்';

  @override
  String get socksHost => 'சாக்ச் புரவலன்';

  @override
  String get socksPassword => 'சாக்ச் கடவுச்சொல்';

  @override
  String get socksPort => 'சாக்ச் துறைமுகம்';

  @override
  String get socksProxy => 'சாக்ச் பதிலாள்';

  @override
  String get socksUserName => 'சாக்ச் பயனர்பெயர்';

  @override
  String get socksVersion => 'சாக்ச் பதிப்பு';

  @override
  String get sort => 'வரிசைப்படுத்து';

  @override
  String get sourceTypeFilter => 'வடிப்பி';

  @override
  String get sourceTypeLatest => 'அண்மைக் கால';

  @override
  String get sourceTypePopular => 'மக்கள்';

  @override
  String get sources => 'மூலங்கள்';

  @override
  String get start => 'தொடங்கு';

  @override
  String get systemTrayIcon => 'கணினி தட்டில் ஐகானைக் காட்டு';

  @override
  String get thatHaventBeenStarted => 'அது தொடங்கப்படவில்லை';

  @override
  String get themeModeDark => 'இருண்ட';

  @override
  String get themeModeLight => 'ஒளி';

  @override
  String get themeModeSystem => 'மண்டலம்';

  @override
  String get today => 'இன்று';

  @override
  String get uninstall => 'நிறுவல் நீக்க';

  @override
  String get uninstalling => 'நிறுவல் நீக்குதல்';

  @override
  String get unknownAuthor => 'தெரியாத ஆசிரியர்';

  @override
  String get unknownManga => 'தெரியாத மங்கா';

  @override
  String get unknownSource => 'தெரியாத சான்று';

  @override
  String get unread => 'படிக்காதது';

  @override
  String get update => 'புதுப்பிப்பு';

  @override
  String get updateCompleted => 'புதுப்பிப்பு முடிந்தது';

  @override
  String updateFailed(Object property) {
    return '$property புதுப்பிக்கத் தவறிவிட்டது';
  }

  @override
  String get updates => 'புதுப்பிப்புகள்';

  @override
  String get updatesSummary => 'புதுப்பிப்புகள் சுருக்கம்';

  @override
  String get updating => 'புதுப்பித்தல்';

  @override
  String get userName => 'பயனர் பெயர்';

  @override
  String get validating => 'சரிபார்ப்பு';

  @override
  String versionAvailable(String app, String version) {
    return 'பதிப்பு $version $appற்கு கிடைக்கிறது !!';
  }

  @override
  String get webUI => 'வலையில் திறந்திருக்கும்';

  @override
  String get webView => 'வலை பார்வை';

  @override
  String get whatsNew => 'புதியது என்ன?';

  @override
  String get withCompletedStatus => 'நிறைவு செய்யப்பட்ட நிலையுடன்';

  @override
  String get withUnreadChapter => 'படிக்காத அத்தியாயங்களுடன்)';

  @override
  String get yesterday => 'நேற்று';

  @override
  String get recentlyRead => 'அண்மைக் காலத்தில் படியுங்கள்';

  @override
  String get history => 'வரலாறு';

  @override
  String get searchHistory => 'தேடல் வரலாறு ...';

  @override
  String get noHistoryFound => 'வாசிப்பு வரலாறு எதுவும் கிடைக்கவில்லை';

  @override
  String get startReadingToSeeHistory =>
      'உங்கள் வரலாற்றை இங்கே காண மங்காவைப் படிக்கத் தொடங்குங்கள்';

  @override
  String get noSearchResults => 'தேடல் முடிவுகள் இல்லை';

  @override
  String get tryDifferentSearchTerm => 'வேறு தேடல் காலத்தை முயற்சிக்கவும்';

  @override
  String get errorOccurred => 'பிழை ஏற்பட்டது';

  @override
  String get viewManga => 'மங்காவைக் காண்க';

  @override
  String get removeFromHistory => 'வரலாற்றிலிருந்து அகற்று';

  @override
  String get removeFromHistoryConfirmation =>
      'உங்கள் வாசிப்பு வரலாற்றிலிருந்து இந்த அத்தியாயத்தை அகற்ற விரும்புகிறீர்களா?';

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
