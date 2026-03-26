import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fil.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_gan.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_nb.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_th.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_uk.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fil'),
    Locale('fr'),
    Locale('gan'),
    Locale.fromSubtags(languageCode: 'gan', scriptCode: 'Hant'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('nb'),
    Locale('nb', 'NO'),
    Locale('nl'),
    Locale('pt'),
    Locale('pt', 'BR'),
    Locale('pt', 'PT'),
    Locale('ru'),
    Locale('ta'),
    Locale('th'),
    Locale('tr'),
    Locale('uk'),
    Locale('vi'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')
  ];

  /// Screen title and Button text of About screen
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Popup title and Button text to add new category in Edit Category Screen
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get addCategory;

  /// Button text to add Manga to Library in Manga Details Screen
  ///
  /// In en, this message translates to:
  /// **'Add to Library'**
  String get addToLibrary;

  /// Section title Text for Advanced Section
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advanced;

  /// Text for all Scanlators in manga description screen chapter filter
  ///
  /// In en, this message translates to:
  /// **'All Scanlators'**
  String get allScanlators;

  /// Popup title and Button text to change App Language
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// Popup title and Button text to change App Theme Mode
  ///
  /// In en, this message translates to:
  /// **'App Theme Mode'**
  String get appTheme;

  /// Name of the app (Catalyst in native script)
  ///
  /// In en, this message translates to:
  /// **'Catalyst'**
  String get appTitle;

  /// Screen title and Button text of Appearance screen
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// Popup title and Button text to change App Authentication
  ///
  /// In en, this message translates to:
  /// **'Authentication Type'**
  String get authType;

  /// Radio button text for the Basic Authentication type
  ///
  /// In en, this message translates to:
  /// **'Basic Auth'**
  String get authTypeBasic;

  /// Radio button text for no Authentication
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get authTypeNone;

  /// Section title for server authentication
  ///
  /// In en, this message translates to:
  /// **'Authentication'**
  String get authentication;

  /// Title for Auto-download Section in downloads settings
  ///
  /// In en, this message translates to:
  /// **'Auto-download'**
  String get autoDownload;

  /// Toggle's title to change Auto Download New Chapters settings
  ///
  /// In en, this message translates to:
  /// **'Download new chapters'**
  String get autoDownloadNewChapters;

  /// Settings group title for automatic backup settings
  ///
  /// In en, this message translates to:
  /// **'Automatic Backup'**
  String get automaticBackup;

  /// Popup title and Settings text to update Automatic Global Update interval
  ///
  /// In en, this message translates to:
  /// **'Automatic Update'**
  String get automaticUpdate;

  /// Settings text to update Automatically refresh metadata
  ///
  /// In en, this message translates to:
  /// **'Automatically refresh metadata'**
  String get automaticallyRefreshMetadata;

  /// Settings sub title text to update Automatically refresh metadata
  ///
  /// In en, this message translates to:
  /// **'Check for new cover and details when updating library'**
  String get automaticallyRefreshMetadataSubtitle;

  /// Screen title and Button text of Backup & Restore screen
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get backup;

  /// Title for Backup and Restore section in settings
  ///
  /// In en, this message translates to:
  /// **'Backup and Restore'**
  String get backupAndRestore;

  /// Title for file backup cleanup edit tile
  ///
  /// In en, this message translates to:
  /// **'Backup Cleanup'**
  String get backupCleanup;

  /// No description provided for @backupCleanupDescription.
  ///
  /// In en, this message translates to:
  /// **'{count, select, 0{Never} 01{Delete Backups that are older 1 day} other{Delete Backups that are older {count} days}}'**
  String backupCleanupDescription(String count);

  /// Title for file backup interval edit tile
  ///
  /// In en, this message translates to:
  /// **'Backup Interval'**
  String get backupInterval;

  /// Title for backup file storage location edit tile
  ///
  /// In en, this message translates to:
  /// **'Backup Location'**
  String get backupLocation;

  /// description for editing backup location
  ///
  /// In en, this message translates to:
  /// **'The path to the directory on the server where automated backups should get saved in'**
  String get backupLocationDescription;

  /// Title for file backup time edit tile
  ///
  /// In en, this message translates to:
  /// **'Backup Time'**
  String get backupTime;

  /// Checkbox Group title to enable Badges on manga Cover in Library Screen
  ///
  /// In en, this message translates to:
  /// **'Badges'**
  String get badges;

  /// Checkbox text to filter bookmarked manga chapters in Manga Details screen
  ///
  /// In en, this message translates to:
  /// **'Bookmarked'**
  String get bookmarked;

  /// Screen title, Navigation Bar text and Button text of both Browse screen and Browse Settings Screen
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get browse;

  /// Text title to show build time of Server in About Screen
  ///
  /// In en, this message translates to:
  /// **'Build time'**
  String get buildTime;

  /// Toast Text to show after clearing cache
  ///
  /// In en, this message translates to:
  /// **'Cache Cleared'**
  String get cacheCleared;

  /// Text for Cancel button in a Popup
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Button text of edit Categories screen in Library settings screen
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// Button text to update the mangas in the Category
  ///
  /// In en, this message translates to:
  /// **'Category Update'**
  String get categoryUpdate;

  /// Text title to show Channel of the Server (Stable, preview) in About Screen
  ///
  /// In en, this message translates to:
  /// **'Channel'**
  String get channel;

  /// Title Text for changing Chapter download limit settings
  ///
  /// In en, this message translates to:
  /// **'Chapter download limit'**
  String get chapterDownloadLimit;

  /// Sub Title Text for changing Chapter download limit settings
  ///
  /// In en, this message translates to:
  /// **'Limit the amount of new chapters that are going to get downloaded.'**
  String get chapterDownloadLimitDesc;

  /// Text title for Chapter name in chapter list
  ///
  /// In en, this message translates to:
  /// **'Chapter {number}'**
  String chapterNumber(double number);

  /// Radio button text for sort by Fetched Date
  ///
  /// In en, this message translates to:
  /// **'By Fetched Date'**
  String get chapterSortFetchedDate;

  /// Radio button text for sort by Source
  ///
  /// In en, this message translates to:
  /// **'By Source'**
  String get chapterSortSource;

  /// Radio button text for sort by Upload Date
  ///
  /// In en, this message translates to:
  /// **'By Upload Date'**
  String get chapterSortUploadDate;

  /// Button text to check for Server updates
  ///
  /// In en, this message translates to:
  /// **'Check for Server updates'**
  String get checkForServerUpdates;

  /// Button text to check for App Updates
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get checkForUpdates;

  /// Button text for clear cache in General Settings screen
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get clearCache;

  /// Text title for the name of the client in About screen
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get client;

  /// Text title for the current version of the client in About screen
  ///
  /// In en, this message translates to:
  /// **'Client version'**
  String get clientVersion;

  /// Text for close button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Section title for Cloudflare Bypass
  ///
  /// In en, this message translates to:
  /// **'Cloudflare Bypass'**
  String get cloudflareBypass;

  /// Checkbox text to filter Completed mangas in Library screen and Manga Grouping text in Update Summary screen
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// Copied Text
  ///
  /// In en, this message translates to:
  /// **'Copied!'**
  String get copied;

  /// Toast text to show that the message has been copied
  ///
  /// In en, this message translates to:
  /// **'\'{msg}\' Copied!'**
  String copyMsg(String msg);

  /// Button text description to create backup
  ///
  /// In en, this message translates to:
  /// **'Backup library as a Tachidesk backup'**
  String get createBackupDescription;

  /// Button text to create backup
  ///
  /// In en, this message translates to:
  /// **'Create Backup'**
  String get createBackupTitle;

  /// Popup title and Button text to enter Authentication credentials
  ///
  /// In en, this message translates to:
  /// **'Credentials'**
  String get credentials;

  /// Text to show the currently reading chapter in Reader Screen
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// Days ago text to show the release date of manga
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String daysAgo(Object days);

  /// Switch title for Debug logs in settings
  ///
  /// In en, this message translates to:
  /// **'Debug logs'**
  String get debugLogs;

  /// Checkbox description when creating a Category to add manga to the Category by Default
  ///
  /// In en, this message translates to:
  /// **'Default category when adding new manga to library'**
  String get defaultCategory;

  /// Text for delete button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Popup description when deleting Category
  ///
  /// In en, this message translates to:
  /// **'This will merge all Mangas in this Category to Default!'**
  String get deleteCategoryDescription;

  /// Popup title when deleting Category
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get deleteCategoryTitle;

  /// Discord app title
  ///
  /// In en, this message translates to:
  /// **'Discord'**
  String get discord;

  /// Text for Display tab in Library screen drawer
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get display;

  /// Radio Group title to change manga Cover display in Library and Source Screens
  ///
  /// In en, this message translates to:
  /// **'Display Mode'**
  String get displayMode;

  /// Radio button text for Manga Cover display mode - Descriptive List
  ///
  /// In en, this message translates to:
  /// **'Descriptive List'**
  String get displayModeDescriptiveList;

  /// Radio button text for Manga Cover display mode - Grid
  ///
  /// In en, this message translates to:
  /// **'Grid'**
  String get displayModeGrid;

  /// Radio button text for Manga Cover display mode - List
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get displayModeList;

  /// Settings label Text to update Download location
  ///
  /// In en, this message translates to:
  /// **'Download location'**
  String get downloadLocation;

  /// Hint text for updating downloads location
  ///
  /// In en, this message translates to:
  /// **'The path to the directory on the server where downloaded files should get saved in'**
  String get downloadLocationHint;

  /// Text to show downloaded chapters status in Filters
  ///
  /// In en, this message translates to:
  /// **'Downloaded'**
  String get downloaded;

  /// Text to show chapters downloading
  ///
  /// In en, this message translates to:
  /// **'Downloading'**
  String get downloading;

  /// Screen title and Navigation text of Downloads screen
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get downloads;

  /// Popup button text to edit Category in Edit category screen
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Screen title, Button text and  of Downloads screen
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get editCategory;

  /// Description to show that category list is empty in Edit Category screen
  ///
  /// In en, this message translates to:
  /// **'Category name can\'t be Empty'**
  String get emptyCategory;

  /// Switch title to enable SOCKS Proxy
  ///
  /// In en, this message translates to:
  /// **'Use SOCKS Proxy'**
  String get enableSocksProxy;

  /// Hint text for text field to enter value of Property
  ///
  /// In en, this message translates to:
  /// **'Enter {prop}'**
  String enterProp(Object prop);

  /// Text to show error downloading chapters
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Error Text to show that backup creating failed
  ///
  /// In en, this message translates to:
  /// **'Failed to create Backup'**
  String get errorBackupCreate;

  /// toast to show that backup restoration failed
  ///
  /// In en, this message translates to:
  /// **'Failed to restore backup!'**
  String get errorBackupRestore;

  /// Error Description to show when user selected unknown extension from list
  ///
  /// In en, this message translates to:
  /// **'Can\'t find the selected extension'**
  String get errorExtension;

  /// Error Description to show when user does not selected an file
  ///
  /// In en, this message translates to:
  /// **'File not selected!'**
  String get errorFilePick;

  /// Error Description to show when user selected unknown extension file
  ///
  /// In en, this message translates to:
  /// **'Please select a file with {extensionName} extension'**
  String errorFilePickUnknownExtension(Object extensionName);

  /// Error Description to show when App failed to launch an URL and copied the URL to clipboard
  ///
  /// In en, this message translates to:
  /// **'Failed to open!\nCopying \"{url}\" to clipboard'**
  String errorLaunchURL(String url);

  /// Error Description to show that password cannot be empty
  ///
  /// In en, this message translates to:
  /// **'Password can\'t be empty'**
  String get errorPassword;

  /// Error Description to show that Something went wrong!
  ///
  /// In en, this message translates to:
  /// **'Something went wrong!'**
  String get errorSomethingWentWrong;

  /// Error Description to show that UserName cannot be empty
  ///
  /// In en, this message translates to:
  /// **'UserName can\'t be empty'**
  String get errorUserName;

  /// Toggle's title to change Toggle Exclude Entry With Unread Chapters setting
  ///
  /// In en, this message translates to:
  /// **'Ignore automatic chapter downloads for entries with unread chapters'**
  String get excludeEntryWithUnreadChapters;

  /// Toast text to show that the Extension Installed successfully
  ///
  /// In en, this message translates to:
  /// **'Extension Installed!'**
  String get extensionInstalled;

  /// Description to show that Extension list is empty in Extension list tab of Browse screen
  ///
  /// In en, this message translates to:
  /// **'Extension list is Empty'**
  String get extensionListEmpty;

  /// Screen title text for Extension repository settings screen
  ///
  /// In en, this message translates to:
  /// **'Extension Repository'**
  String get extensionRepository;

  /// Subtitle text for Extension repository settings property
  ///
  /// In en, this message translates to:
  /// **'Add repositories from which extensions can be installed'**
  String get extensionRepositoryDescription;

  /// Extension list Tab title in Browse Screen
  ///
  /// In en, this message translates to:
  /// **'Extensions'**
  String get extensions;

  /// Failed status Manga Group title in Update Summary Screen
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// title of filter Tab across the app
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// Button text of Find Server
  ///
  /// In en, this message translates to:
  /// **'Find'**
  String get findServer;

  /// Text to show the Currently Finished reading chapter in Reader Screen
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get finished;

  /// Toggle title to enable FlareSolverr
  ///
  /// In en, this message translates to:
  /// **'FlareSolverr'**
  String get flareSolverr;

  /// Title text for FlareSolverr Request Timeout property
  ///
  /// In en, this message translates to:
  /// **'FlareSolverr Request Timeout'**
  String get flareSolverrRequestTimeout;

  /// Title text for FlareSolverr Server Url property
  ///
  /// In en, this message translates to:
  /// **'FlareSolverr Server Url'**
  String get flareSolverrServerUrl;

  /// Title text for FlareSolverr Session Name property
  ///
  /// In en, this message translates to:
  /// **'FlareSolverr session name'**
  String get flareSolverrSessionName;

  /// Title text for FlareSolverr Session TTL property
  ///
  /// In en, this message translates to:
  /// **'FlareSolverr session TTL'**
  String get flareSolverrSessionTTL;

  /// Screen title and Button text of General setting screen
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// GitHub app title
  ///
  /// In en, this message translates to:
  /// **'GitHub'**
  String get gitHub;

  /// Screen title of Global Search screen
  ///
  /// In en, this message translates to:
  /// **'Global Search'**
  String get globalSearch;

  /// Button text of Global Manga Update
  ///
  /// In en, this message translates to:
  /// **'Global Update'**
  String get globalUpdate;

  /// Switch title for Graphql Debug logs in settings
  ///
  /// In en, this message translates to:
  /// **'Graphql debug logs'**
  String get gqlDebugLogs;

  /// Switch subTitle for Graphql Debug logs in settings
  ///
  /// In en, this message translates to:
  /// **'This includes logs with non privacy safe information'**
  String get gqlDebugLogsHint;

  /// Button text of help in about screen
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// Switch button text to Hide empty category in library
  ///
  /// In en, this message translates to:
  /// **'Hide Empty Category'**
  String get hideEmptyCategory;

  /// Button and Chip text to show that the manga is in Library
  ///
  /// In en, this message translates to:
  /// **'In library'**
  String get inLibrary;

  /// Check box text to include categories during create backup
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get includeCategories;

  /// Check box text to include chapters during create backup
  ///
  /// In en, this message translates to:
  /// **'Chapters'**
  String get includeChapters;

  /// Button text to install the extension
  ///
  /// In en, this message translates to:
  /// **'Install'**
  String get install;

  /// Button text to show that the extension is installing
  ///
  /// In en, this message translates to:
  /// **'Installing'**
  String get installing;

  /// Toast text to show that the extension is installing
  ///
  /// In en, this message translates to:
  /// **'Installing Extension'**
  String get installingExtension;

  /// Error when Submitted invalid Port Number
  ///
  /// In en, this message translates to:
  /// **'Invalid Port'**
  String get invalidPort;

  /// Toast text for select invalid property value
  ///
  /// In en, this message translates to:
  /// **'Invalid {property}'**
  String invalidProp(Object property);

  /// Option title for Server IP Address in Server settings
  ///
  /// In en, this message translates to:
  /// **'IP Address'**
  String get ip;

  /// No description provided for @ipHintText.
  ///
  /// In en, this message translates to:
  /// **'Enter server binding IP address'**
  String get ipHintText;

  /// Switch title to enable {} black theme
  ///
  /// In en, this message translates to:
  /// **'True Black'**
  String get isTrueBlack;

  /// Popup title to filter extensions based on language
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get languages;

  /// Button text to take user to the latest tab of Source manga screen
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get latest;

  /// Screen title and Button text of Library and Library Settings screen
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get library;

  /// Text for Local Source Location settings property
  ///
  /// In en, this message translates to:
  /// **'Local source location'**
  String get localSourceLocation;

  /// Description text for Local Source Location property
  ///
  /// In en, this message translates to:
  /// **'The path to the directory on the server where local source files are saved in'**
  String get localSourceLocationDescription;

  /// Screen title and Button text of Manga details screen
  ///
  /// In en, this message translates to:
  /// **'Manga'**
  String get manga;

  /// Popup title and Button text to change Manga Grid size
  ///
  /// In en, this message translates to:
  /// **'Manga Grid Size'**
  String get mangaGridSize;

  /// Group title to show the Manga Missing Sources when restoring Backup
  ///
  /// In en, this message translates to:
  /// **'Manga Missing Sources'**
  String get mangaMissingSources;

  /// Radio button text for Manga sort Type - Alphabetical
  ///
  /// In en, this message translates to:
  /// **'Alphabetical'**
  String get mangaSortAlphabetical;

  /// Radio button text for Manga sort Type - Date Added
  ///
  /// In en, this message translates to:
  /// **'Date Added'**
  String get mangaSortDateAdded;

  /// Radio button text for Manga sort Type - Last Read
  ///
  /// In en, this message translates to:
  /// **'Last Read'**
  String get mangaSortLastRead;

  /// Radio button text for Manga sort Type - Last Updated
  ///
  /// In en, this message translates to:
  /// **'Last Updated'**
  String get mangaSortLastUpdated;

  /// Radio button text for Manga sort Type - Unread
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get mangaSortUnread;

  /// Text to show Manga Status Cancelled in Manga details screen
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get mangaStatusCancelled;

  /// Text to show Manga Status Completed in Manga details screen
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get mangaStatusCompleted;

  /// Text to show Manga Status Licensed in Manga details screen
  ///
  /// In en, this message translates to:
  /// **'Licensed'**
  String get mangaStatusLicensed;

  /// Text to show Manga Status On Hiatus in Manga details screen
  ///
  /// In en, this message translates to:
  /// **'On Hiatus'**
  String get mangaStatusOnHiatus;

  /// Text to show Manga Status Ongoing in Manga details screen
  ///
  /// In en, this message translates to:
  /// **'Ongoing'**
  String get mangaStatusOngoing;

  /// Text to show Manga Status Publishing Finished in Manga details screen
  ///
  /// In en, this message translates to:
  /// **'Publishing Finished'**
  String get mangaStatusPublishingFinished;

  /// Text to show Manga Status Unknown in Manga details screen
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get mangaStatusUnknown;

  /// Section title for misc settings
  ///
  /// In en, this message translates to:
  /// **'Misc'**
  String get misc;

  /// Group title to show the Missing Extensions when restoring Backup
  ///
  /// In en, this message translates to:
  /// **'Missing Extensions'**
  String get missingExtension;

  /// Group title to show the Missing Trackers when restoring Backup
  ///
  /// In en, this message translates to:
  /// **'Missing Trackers'**
  String get missingTrackers;

  /// Screen title and Navigation text of More screen
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// Button text to move download/category to the bottom of list
  ///
  /// In en, this message translates to:
  /// **'Move to Bottom'**
  String get moveToBottom;

  /// Button text to move download/category to the top of list
  ///
  /// In en, this message translates to:
  /// **'Move to top'**
  String get moveToTop;

  /// Text for showing N chapters
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =0{None} =1{1 Chapter} other{{n} Chapters}}'**
  String nChapters(num n);

  /// to show Number of days with plural
  ///
  /// In en, this message translates to:
  /// **'{count, select, 01{01 Day} other{{count} Days}}'**
  String nDays(String count);

  /// Text to represent 'n' hours
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 hour} other{{n} hours}}'**
  String nHours(num n);

  /// Text to represent 'n' Minutes
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 Minute} other{{n} Minutes}}'**
  String nMinutes(num n);

  /// Text to show n repo as subtitle
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 Repo} other{{n} Repos}}'**
  String nRepo(num n);

  /// Text to represent 'n' seconds
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 second} other{{n} seconds}}'**
  String nSeconds(num n);

  /// Text to represent n number Parallel source requests
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 Source} other{{n} Sources}}'**
  String nSources(num n);

  /// Text pattern to display an name and count in a string
  ///
  /// In en, this message translates to:
  /// **'{name}: {count}'**
  String nameCountDisplay(int count, String name);

  /// Popup title to show that the App/Server has and update
  ///
  /// In en, this message translates to:
  /// **'New update available'**
  String get newUpdateAvailable;

  /// Text for Next Chapter button in Manga Reader Screen
  ///
  /// In en, this message translates to:
  /// **'Next: {chapterTitle}'**
  String nextChapter(Object chapterTitle);

  /// Hint text to add new Category when category list is empty
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any Categories. \n(Tip: Tap the Plus button to create one for organizing your library)'**
  String get noCategoriesFound;

  /// Hint text to add new Category in Settings when category list is empty
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any Categories. \nCreate one in settings for organizing your library'**
  String get noCategoriesFoundAlt;

  /// Hint text to check filter when manga list is empty in Category tab in Library
  ///
  /// In en, this message translates to:
  /// **'No manga found in this Category. \n(Tip: Check your search & filters!)'**
  String get noCategoryMangaFound;

  /// Text to show that the Chapter list is empty in Manga details Screen
  ///
  /// In en, this message translates to:
  /// **'No Chapters found'**
  String get noChaptersFound;

  /// Text to show that there is no active downloads in Downloads Screen
  ///
  /// In en, this message translates to:
  /// **'No Downloads'**
  String get noDownloads;

  /// Text to show that the Manga list is empty
  ///
  /// In en, this message translates to:
  /// **'No Mangas Found'**
  String get noMangaFound;

  /// Title text to show the number of chapters in the Manga details screen
  ///
  /// In en, this message translates to:
  /// **'{count} Chapters'**
  String noOfChapters(int count);

  /// Template text to say No value for property found
  ///
  /// In en, this message translates to:
  /// **'No {prop} Found'**
  String noPropFound(Object prop);

  /// Text to show that no results found for the given search query
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultFound;

  /// Text to show that no Server found in locale network
  ///
  /// In en, this message translates to:
  /// **'No Server found in your local network'**
  String get noServerFound;

  /// Text to show that the Source list is empty
  ///
  /// In en, this message translates to:
  /// **'No sources found'**
  String get noSourcesFound;

  /// Text to show that the user is using the latest version of the app
  ///
  /// In en, this message translates to:
  /// **'You\'re using the latest version'**
  String get noUpdatesAvailable;

  /// Toast Text to show that there are no Updates available
  ///
  /// In en, this message translates to:
  /// **'No updates found'**
  String get noUpdatesFound;

  /// Text for None
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// Switch text to show/hide the nsfw extensions
  ///
  /// In en, this message translates to:
  /// **'Show NSFW extensions and sources'**
  String get nsfw;

  /// 18+ tag Text to show in extensions list
  ///
  /// In en, this message translates to:
  /// **'18+'**
  String get nsfw18;

  /// Hint text to show that the nsfw switch cannot prevent incorrectly flagged extensions from surfacing
  ///
  /// In en, this message translates to:
  /// **'This does not prevent unofficial or potentially incorrectly flagged extensions from surfacing NSFW(18+) content within app'**
  String get nsfwInfo;

  /// Title text to show the number of chapters selected in the Manga details screen and Updates screen
  ///
  /// In en, this message translates to:
  /// **'{num} Selected'**
  String numSelected(int num);

  /// Text to show that the extension has become Obsolete
  ///
  /// In en, this message translates to:
  /// **'Obsolete'**
  String get obsolete;

  /// Text for link to Open Flare Solverr setup documentation
  ///
  /// In en, this message translates to:
  /// **'Checkout FlareSolverr for information on how to set it up'**
  String get openFlareSolverr;

  /// Button title text for open the url in web
  ///
  /// In en, this message translates to:
  /// **'Open In Web'**
  String get openInWeb;

  /// text literal for word or
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// Text to show the last read Page number of the chapter in Manga details screen
  ///
  /// In en, this message translates to:
  /// **'Page: {number}'**
  String page(int number);

  /// Text for Parallel source requests property
  ///
  /// In en, this message translates to:
  /// **'Parallel source requests'**
  String get parallelSourceRequest;

  /// Title text for password field
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Button text to pause downloads
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// Pending status Manga Group title in Update Summary Screen
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// Switch title to enable pinch to zoom in reader screen
  ///
  /// In en, this message translates to:
  /// **'Pinch to Zoom'**
  String get pinchToZoom;

  /// Text for Previous Chapter button in Manga Reader Screen
  ///
  /// In en, this message translates to:
  /// **'Previous: {chapterTitle}'**
  String previousChapter(Object chapterTitle);

  /// Text to show chapters are queued for downloading
  ///
  /// In en, this message translates to:
  /// **'Queued'**
  String get queued;

  /// Screen title and Button text of Quick Search screen
  ///
  /// In en, this message translates to:
  /// **'Quick Search'**
  String get quickSearch;

  /// Quick Open Hint text for Category C with prefill '#C'
  ///
  /// In en, this message translates to:
  /// **'Go to Category \'C\''**
  String get quickSearchCategory;

  /// Quick Open Hint text for searching Manga M in Category C with prefill '#C/M'
  ///
  /// In en, this message translates to:
  /// **'Go to Manga \'M\' in Category \'C\''**
  String get quickSearchCategoryManga;

  /// Quick Open Hint text for searching Chapter name CN from Manga M in Source S with prefill '#C/M:CN'
  ///
  /// In en, this message translates to:
  /// **'Go to Chapter Name \'CN\' from Manga \'M\' in Category \'C\''**
  String get quickSearchCategoryMangaChapter;

  /// Quick Open Hint text for query X
  ///
  /// In en, this message translates to:
  /// **'Search for query X (Results are based on screen context)'**
  String get quickSearchContext;

  /// Quick Open Tip text for showing all commands by entering '?'
  ///
  /// In en, this message translates to:
  /// **'Tip: Enter \'?\' to see all commands'**
  String get quickSearchShowAllCommandTip;

  /// Quick Open Hint text for Source S with prefill '@S'
  ///
  /// In en, this message translates to:
  /// **'Go to Source \'S\''**
  String get quickSearchSource;

  /// Quick Open Hint text for searching Manga M in Source S with prefill '@S/M'
  ///
  /// In en, this message translates to:
  /// **'Search for Manga \'M\' in Source \'S\''**
  String get quickSearchSourceManga;

  /// Screen title and Button text of Reader screen
  ///
  /// In en, this message translates to:
  /// **'Reader'**
  String get reader;

  /// Slider title text for Reader Magnifier Size
  ///
  /// In en, this message translates to:
  /// **'Magnifier Size'**
  String get readerMagnifierSize;

  /// Popup title and Button text of Reader Mode popup
  ///
  /// In en, this message translates to:
  /// **'Reading Mode'**
  String get readerMode;

  /// Radio button text for Reader Mode Type - Continuous Horizontal (LTR)
  ///
  /// In en, this message translates to:
  /// **'Continuous Horizontal (LTR)'**
  String get readerModeContinuousHorizontalLTR;

  /// Radio button text for Reader Mode Type - Continuous Horizontal (RTL)
  ///
  /// In en, this message translates to:
  /// **'Continuous Horizontal (RTL)'**
  String get readerModeContinuousHorizontalRTL;

  /// Radio button text for Reader Mode Type - Continuous Vertical
  ///
  /// In en, this message translates to:
  /// **'Continuous Vertical'**
  String get readerModeContinuousVertical;

  /// Radio button text for Reader Mode Type - Default
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get readerModeDefaultReader;

  /// Radio button text for Reader Mode Type - Single Horizontal (LTR)
  ///
  /// In en, this message translates to:
  /// **'Single Horizontal (LTR)'**
  String get readerModeSingleHorizontalLTR;

  /// Radio button text for Reader Mode Type - Single Horizontal (RTL)
  ///
  /// In en, this message translates to:
  /// **'Single Horizontal (RTL)'**
  String get readerModeSingleHorizontalRTL;

  /// Radio button text for Reader Mode Type - Single Vertical
  ///
  /// In en, this message translates to:
  /// **'Single Vertical'**
  String get readerModeSingleVertical;

  /// Radio button text for Reader Mode Type - Webtoon
  ///
  /// In en, this message translates to:
  /// **'Webtoon'**
  String get readerModeWebtoon;

  /// Popup title and Button text of Reader Navigation Layout popup
  ///
  /// In en, this message translates to:
  /// **'Navigation layout'**
  String get readerNavigationLayout;

  /// Radio button text for Reader Navigation Layout - Default
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get readerNavigationLayoutDefault;

  /// Radio button text for Reader Navigation Layout - Disabled
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get readerNavigationLayoutDisabled;

  /// Radio button text for Reader Navigation Layout - Edge
  ///
  /// In en, this message translates to:
  /// **'Edge'**
  String get readerNavigationLayoutEdge;

  /// Switch title to invert Tap to scroll in reader screen
  ///
  /// In en, this message translates to:
  /// **'Invert tapping'**
  String get readerNavigationLayoutInvert;

  /// Radio button text for Reader Navigation Layout - Kindle-ish
  ///
  /// In en, this message translates to:
  /// **'Kindle-ish'**
  String get readerNavigationLayoutKindlish;

  /// Radio button text for Reader Navigation Layout - L Shaped
  ///
  /// In en, this message translates to:
  /// **'L Shaped'**
  String get readerNavigationLayoutLShaped;

  /// Radio button text for Reader Navigation Layout - Right And Left
  ///
  /// In en, this message translates to:
  /// **'Right And Left'**
  String get readerNavigationLayoutRightAndLeft;

  /// Toggle subtile text for Initial Reader Overlay
  ///
  /// In en, this message translates to:
  /// **'Reader initial overlay'**
  String get readerOverlay;

  /// Shows title and quick settings when opening a chapter
  ///
  /// In en, this message translates to:
  /// **'Shows title and quick settings when opening a chapter'**
  String get readerOverlaySubtitle;

  /// Slider title text for Reader Padding
  ///
  /// In en, this message translates to:
  /// **'Reader Padding'**
  String get readerPadding;

  /// Switch title to Disable scroll animation in reader screen
  ///
  /// In en, this message translates to:
  /// **'Scroll animation'**
  String get readerScrollAnimation;

  /// Switch title to toggle `swipe to change chapter` in reader screen
  ///
  /// In en, this message translates to:
  /// **'Swipe toggle'**
  String get readerSwipeChapterToggle;

  /// Switch tile description for, toggle `swipe to change chapter` in reader screen
  ///
  /// In en, this message translates to:
  /// **'Swipe to change chapter in reader'**
  String get readerSwipeChapterToggleDescription;

  /// Last page swipe
  ///
  /// In en, this message translates to:
  /// **'Last page swipe'**
  String get readerLastPageSwipeToggle;

  /// Swipe to next chapter only at last page
  ///
  /// In en, this message translates to:
  /// **'Swipe to next chapter only at last page'**
  String get readerLastPageSwipeToggleDescription;

  /// Switch button text for Reader Page Navigation with Volume Tap
  ///
  /// In en, this message translates to:
  /// **'Volume Keys'**
  String get readerVolumeTap;

  /// Switch button text to invert Volume Tap
  ///
  /// In en, this message translates to:
  /// **'Invert Volume Keys'**
  String get readerVolumeTapInvert;

  /// Switch button Subtitle text for Reader Page Navigation with Volume Tap
  ///
  /// In en, this message translates to:
  /// **'Navigate with Volume Keys'**
  String get readerVolumeTapSubtitle;

  /// Toggle text to ignore safe area in reader
  ///
  /// In en, this message translates to:
  /// **'Ignore Safe Area'**
  String get readerIgnoreSafeAreaToggle;

  /// Description for ignore safe area toggle in reader settings
  ///
  /// In en, this message translates to:
  /// **'Allow content to extend into notch and home indicator areas'**
  String get readerIgnoreSafeAreaToggleDescription;

  /// Reddit app title
  ///
  /// In en, this message translates to:
  /// **'Reddit'**
  String get reddit;

  /// Refresh button text
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @migrate.
  ///
  /// In en, this message translates to:
  /// **'Migrate'**
  String get migrate;

  /// No description provided for @migrationSelectTargetSource.
  ///
  /// In en, this message translates to:
  /// **'Select Target Source'**
  String get migrationSelectTargetSource;

  /// No description provided for @migrationSearchInSource.
  ///
  /// In en, this message translates to:
  /// **'Search in {sourceName}'**
  String migrationSearchInSource(Object sourceName);

  /// No description provided for @migrationPreview.
  ///
  /// In en, this message translates to:
  /// **'Migration Preview'**
  String get migrationPreview;

  /// No description provided for @migrationInProgress.
  ///
  /// In en, this message translates to:
  /// **'Migration in Progress'**
  String get migrationInProgress;

  /// No description provided for @migrationComplete.
  ///
  /// In en, this message translates to:
  /// **'Migration completed successfully'**
  String get migrationComplete;

  /// No description provided for @migrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Migration Failed'**
  String get migrationFailed;

  /// No description provided for @migrationCancelled.
  ///
  /// In en, this message translates to:
  /// **'Migration Cancelled'**
  String get migrationCancelled;

  /// No description provided for @migrateChapters.
  ///
  /// In en, this message translates to:
  /// **'Migrate Chapters'**
  String get migrateChapters;

  /// No description provided for @migrateChaptersDescription.
  ///
  /// In en, this message translates to:
  /// **'Copy chapter read status to new source'**
  String get migrateChaptersDescription;

  /// No description provided for @migrateCategories.
  ///
  /// In en, this message translates to:
  /// **'Migrate Categories'**
  String get migrateCategories;

  /// No description provided for @migrateCategoriesDescription.
  ///
  /// In en, this message translates to:
  /// **'Copy manga categories to new source'**
  String get migrateCategoriesDescription;

  /// No description provided for @migrateDownloads.
  ///
  /// In en, this message translates to:
  /// **'Migrate Downloads'**
  String get migrateDownloads;

  /// No description provided for @migrateDownloadsDescription.
  ///
  /// In en, this message translates to:
  /// **'Move downloaded chapters to new source'**
  String get migrateDownloadsDescription;

  /// No description provided for @migrateTracking.
  ///
  /// In en, this message translates to:
  /// **'Migrate Tracking'**
  String get migrateTracking;

  /// No description provided for @migrateTrackingDescription.
  ///
  /// In en, this message translates to:
  /// **'Copy tracking information to new source'**
  String get migrateTrackingDescription;

  /// No description provided for @migrationOptions.
  ///
  /// In en, this message translates to:
  /// **'Migration Options'**
  String get migrationOptions;

  /// No description provided for @migrationSettings.
  ///
  /// In en, this message translates to:
  /// **'Migration Settings'**
  String get migrationSettings;

  /// No description provided for @selectTargetSource.
  ///
  /// In en, this message translates to:
  /// **'Select Target Source'**
  String get selectTargetSource;

  /// No description provided for @noSourcesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No sources available for migration'**
  String get noSourcesAvailable;

  /// No description provided for @checkSourceConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Please check your source configuration'**
  String get checkSourceConfiguration;

  /// No description provided for @noAlternativeSources.
  ///
  /// In en, this message translates to:
  /// **'No alternative sources available'**
  String get noAlternativeSources;

  /// No description provided for @installMoreSources.
  ///
  /// In en, this message translates to:
  /// **'Install more sources to enable migration'**
  String get installMoreSources;

  /// No description provided for @errorLoadingSources.
  ///
  /// In en, this message translates to:
  /// **'Error loading sources'**
  String get errorLoadingSources;

  /// No description provided for @errorGettingMigrationSources.
  ///
  /// In en, this message translates to:
  /// **'Failed to get migration sources'**
  String get errorGettingMigrationSources;

  /// No description provided for @errorSearchingMangaInSource.
  ///
  /// In en, this message translates to:
  /// **'Failed to search manga in source'**
  String get errorSearchingMangaInSource;

  /// No description provided for @errorFetchingSourceManga.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch source manga'**
  String get errorFetchingSourceManga;

  /// No description provided for @errorSourceMangaNotFound.
  ///
  /// In en, this message translates to:
  /// **'Source manga not found'**
  String get errorSourceMangaNotFound;

  /// No description provided for @errorFetchingTargetManga.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch target manga'**
  String get errorFetchingTargetManga;

  /// No description provided for @errorTargetMangaNotFound.
  ///
  /// In en, this message translates to:
  /// **'Target manga not found'**
  String get errorTargetMangaNotFound;

  /// No description provided for @searchManga.
  ///
  /// In en, this message translates to:
  /// **'Search manga...'**
  String get searchManga;

  /// No description provided for @searchForManga.
  ///
  /// In en, this message translates to:
  /// **'Search for manga in the target source'**
  String get searchForManga;

  /// No description provided for @enterSearchTerm.
  ///
  /// In en, this message translates to:
  /// **'Enter a search term to find manga'**
  String get enterSearchTerm;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @tryDifferentSearch.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term'**
  String get tryDifferentSearch;

  /// No description provided for @searchError.
  ///
  /// In en, this message translates to:
  /// **'Search error'**
  String get searchError;

  /// No description provided for @importantNotice.
  ///
  /// In en, this message translates to:
  /// **'Important Notice'**
  String get importantNotice;

  /// No description provided for @migrationWarning.
  ///
  /// In en, this message translates to:
  /// **'This will permanently move your manga data. This action cannot be undone.'**
  String get migrationWarning;

  /// No description provided for @deleteSourceWarning.
  ///
  /// In en, this message translates to:
  /// **'The original manga will be removed from your library after migration.'**
  String get deleteSourceWarning;

  /// No description provided for @confirmMigration.
  ///
  /// In en, this message translates to:
  /// **'Confirm Migration'**
  String get confirmMigration;

  /// No description provided for @migrationConfirmationMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to migrate this manga? This action cannot be undone.'**
  String get migrationConfirmationMessage;

  /// No description provided for @startMigration.
  ///
  /// In en, this message translates to:
  /// **'Start Migration'**
  String get startMigration;

  /// No description provided for @preparingMigration.
  ///
  /// In en, this message translates to:
  /// **'Preparing migration...'**
  String get preparingMigration;

  /// No description provided for @migrationCompleted.
  ///
  /// In en, this message translates to:
  /// **'Migration Completed!'**
  String get migrationCompleted;

  /// No description provided for @migrationSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Your manga has been successfully migrated to the new source.'**
  String get migrationSuccessMessage;

  /// No description provided for @migrationCancelledMessage.
  ///
  /// In en, this message translates to:
  /// **'The migration process has been cancelled. No changes were made.'**
  String get migrationCancelledMessage;

  /// No description provided for @cancelMigration.
  ///
  /// In en, this message translates to:
  /// **'Cancel Migration'**
  String get cancelMigration;

  /// No description provided for @cancelMigrationConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel the migration? This action cannot be undone.'**
  String get cancelMigrationConfirmation;

  /// No description provided for @quickPresets.
  ///
  /// In en, this message translates to:
  /// **'Quick Presets'**
  String get quickPresets;

  /// No description provided for @quickMigration.
  ///
  /// In en, this message translates to:
  /// **'Quick'**
  String get quickMigration;

  /// No description provided for @fullMigration.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get fullMigration;

  /// No description provided for @customMigration.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get customMigration;

  /// No description provided for @deleteSourceManga.
  ///
  /// In en, this message translates to:
  /// **'Delete Source Manga'**
  String get deleteSourceManga;

  /// No description provided for @deleteSourceMangaDescription.
  ///
  /// In en, this message translates to:
  /// **'Remove the original manga from library after migration'**
  String get deleteSourceMangaDescription;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// Screen title and Button text of source screen
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get source;

  /// No description provided for @migrationDetails.
  ///
  /// In en, this message translates to:
  /// **'Migration Details'**
  String get migrationDetails;

  /// No description provided for @searchAllSources.
  ///
  /// In en, this message translates to:
  /// **'Search All Sources'**
  String get searchAllSources;

  /// No description provided for @searchingAllSources.
  ///
  /// In en, this message translates to:
  /// **'Searching across all available sources...'**
  String get searchingAllSources;

  /// No description provided for @noMatchingMangaFound.
  ///
  /// In en, this message translates to:
  /// **'No matching manga found in any source'**
  String get noMatchingMangaFound;

  /// No description provided for @deleteSourceAfterMigration.
  ///
  /// In en, this message translates to:
  /// **'Delete source manga after migration'**
  String get deleteSourceAfterMigration;

  /// Reload button text
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get reload;

  /// Remove Button text
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// Remove From Library Popup text
  ///
  /// In en, this message translates to:
  /// **'Remove from Library?'**
  String get removeFromLibrary;

  /// Button text of reset button in source filters
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// Button Text to create backup
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// Button text description to create backup
  ///
  /// In en, this message translates to:
  /// **'Restore Tachidesk from backup'**
  String get restoreBackupDescription;

  /// Button text to create backup
  ///
  /// In en, this message translates to:
  /// **'Restore Backup'**
  String get restoreBackupTitle;

  /// Toast Text to show that the backup has been restored
  ///
  /// In en, this message translates to:
  /// **'Backup restored!'**
  String get restored;

  /// Toast Text to show that the backup is restoring
  ///
  /// In en, this message translates to:
  /// **'Restoring backup'**
  String get restoring;

  /// Button Text to resume Chapter reading/downloading
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// Retry Button Text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Running status Manga Group title in Update Summary Screen
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get running;

  /// Save Button Text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Settings toggle label for Save as CBZ archive
  ///
  /// In en, this message translates to:
  /// **'Save as CBZ archive'**
  String get saveAsCBZArchive;

  /// Title text for Scanlators
  ///
  /// In en, this message translates to:
  /// **'Scanlators'**
  String get scanlators;

  /// Search field hint Text
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Toast Text for searching for updates of the App/Server
  ///
  /// In en, this message translates to:
  /// **'Searching for updates'**
  String get searchingForUpdates;

  /// Toast Text for selecting chapters in between first and last Chapters
  ///
  /// In en, this message translates to:
  /// **'Select in between'**
  String get selectInBetween;

  /// Toast Text for selecting next 10 chapters
  ///
  /// In en, this message translates to:
  /// **'Select next 10'**
  String get selectNext10;

  /// Popup Text for selecting unread chapters
  ///
  /// In en, this message translates to:
  /// **'Select Unread'**
  String get selectUnread;

  /// Text title for the server in About screen
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get server;

  /// Title for server bindings settings
  ///
  /// In en, this message translates to:
  /// **'Server Bindings'**
  String get serverBindings;

  /// Popup title and Button text to update Server Port
  ///
  /// In en, this message translates to:
  /// **'Server Port'**
  String get serverPort;

  /// Text Filed hint text to update Server Port
  ///
  /// In en, this message translates to:
  /// **'Server port'**
  String get serverPortHintText;

  /// Popup title and Button text to update Server Url
  ///
  /// In en, this message translates to:
  /// **'Server URL'**
  String get serverUrl;

  /// Text Filed hint text to update Server Url
  ///
  /// In en, this message translates to:
  /// **'Server url'**
  String get serverUrlHintText;

  /// Text title for the current version of the Server in About screen
  ///
  /// In en, this message translates to:
  /// **'Server version'**
  String get serverVersion;

  /// Screen title and Button text of Settings screen
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Settings Text to update skip Updating Entries
  ///
  /// In en, this message translates to:
  /// **'Skip updating entries'**
  String get skipUpdatingEntries;

  /// No description provided for @socksHost.
  ///
  /// In en, this message translates to:
  /// **'SOCKS Host'**
  String get socksHost;

  /// No description provided for @socksPassword.
  ///
  /// In en, this message translates to:
  /// **'SOCKS Password'**
  String get socksPassword;

  /// No description provided for @socksPort.
  ///
  /// In en, this message translates to:
  /// **'SOCKS Port'**
  String get socksPort;

  /// Section title for SOCKS Proxy settings
  ///
  /// In en, this message translates to:
  /// **'SOCKS Proxy'**
  String get socksProxy;

  /// No description provided for @socksUserName.
  ///
  /// In en, this message translates to:
  /// **'SOCKS UserName'**
  String get socksUserName;

  /// Title for Socks version picker
  ///
  /// In en, this message translates to:
  /// **'SOCKS Version'**
  String get socksVersion;

  /// title of sort Tab across the app
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// Tab text Filter for source screen type
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get sourceTypeFilter;

  /// Tab text Latest for source screen type
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get sourceTypeLatest;

  /// Tab text Popular for source screen type
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get sourceTypePopular;

  /// title of Sources Tab in Browse Screen
  ///
  /// In en, this message translates to:
  /// **'Sources'**
  String get sources;

  /// Button text start reading the manga
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// Switch title to Show icon in system tray in settings
  ///
  /// In en, this message translates to:
  /// **'Show icon in system tray'**
  String get systemTrayIcon;

  /// Setting option Text for Skip updating entries to toggle That haven't been started
  ///
  /// In en, this message translates to:
  /// **'That haven\'t been started'**
  String get thatHaventBeenStarted;

  /// Radio button text for App theme - Dark
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeModeDark;

  /// Radio button text for App theme - Light
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeModeLight;

  /// Radio button text for App theme - System
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeModeSystem;

  /// Today Text to show the release date of manga
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Button text to Uninstall the extension
  ///
  /// In en, this message translates to:
  /// **'Uninstall'**
  String get uninstall;

  /// Button text to show that the extension is uninstalling
  ///
  /// In en, this message translates to:
  /// **'Uninstalling'**
  String get uninstalling;

  /// Text to show unknown author in Manga details screen
  ///
  /// In en, this message translates to:
  /// **'Unknown Author'**
  String get unknownAuthor;

  /// Text to show unknown manga in Manga details screen
  ///
  /// In en, this message translates to:
  /// **'Unknown Manga'**
  String get unknownManga;

  /// Text to show unknown Source in Manga details screen
  ///
  /// In en, this message translates to:
  /// **'Unknown Source'**
  String get unknownSource;

  /// Checkbox text to unread bookmarked manga/chapters across app
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get unread;

  /// Button text to update the extension
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// Button text to show that extension update is completed
  ///
  /// In en, this message translates to:
  /// **'Update Completed'**
  String get updateCompleted;

  /// Failed to update Text
  ///
  /// In en, this message translates to:
  /// **'Failed to update {property}'**
  String updateFailed(Object property);

  /// Screen title and Button text of Updates screen
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get updates;

  /// Screen title and Button text of Updates Summary screen
  ///
  /// In en, this message translates to:
  /// **'Updates Summary'**
  String get updatesSummary;

  /// Button text to show that the extension is updating
  ///
  /// In en, this message translates to:
  /// **'Updating'**
  String get updating;

  /// Title text for User Name field
  ///
  /// In en, this message translates to:
  /// **'User Name'**
  String get userName;

  /// toast to show backup validation is in progress
  ///
  /// In en, this message translates to:
  /// **'Validating'**
  String get validating;

  /// Text to show that there is an update to App/Server
  ///
  /// In en, this message translates to:
  /// **'Version {version} available for {app}!!'**
  String versionAvailable(String app, String version);

  /// Button text to open in web UI
  ///
  /// In en, this message translates to:
  /// **'Open in WEB'**
  String get webUI;

  /// Button text to open manga website
  ///
  /// In en, this message translates to:
  /// **'Web View'**
  String get webView;

  /// Button text to open whats new page of app in web
  ///
  /// In en, this message translates to:
  /// **'What\'s New?'**
  String get whatsNew;

  /// Setting option Text for Skip updating entries to toggle With Completed status
  ///
  /// In en, this message translates to:
  /// **'With Completed status'**
  String get withCompletedStatus;

  /// Setting option Text for Skip updating entries to toggle With unread chapter(s)
  ///
  /// In en, this message translates to:
  /// **'With unread chapter(s)'**
  String get withUnreadChapter;

  /// Yesterday Text to show the release date of manga
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// Recently Read Text to show reading history grouping
  ///
  /// In en, this message translates to:
  /// **'Recently Read'**
  String get recentlyRead;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @searchHistory.
  ///
  /// In en, this message translates to:
  /// **'Search history...'**
  String get searchHistory;

  /// No description provided for @noHistoryFound.
  ///
  /// In en, this message translates to:
  /// **'No reading history found'**
  String get noHistoryFound;

  /// No description provided for @startReadingToSeeHistory.
  ///
  /// In en, this message translates to:
  /// **'Start reading manga to see your history here'**
  String get startReadingToSeeHistory;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No search results'**
  String get noSearchResults;

  /// No description provided for @tryDifferentSearchTerm.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term'**
  String get tryDifferentSearchTerm;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// No description provided for @viewManga.
  ///
  /// In en, this message translates to:
  /// **'View Manga'**
  String get viewManga;

  /// No description provided for @removeFromHistory.
  ///
  /// In en, this message translates to:
  /// **'Remove from History'**
  String get removeFromHistory;

  /// No description provided for @removeFromHistoryConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this chapter from your reading history?'**
  String get removeFromHistoryConfirmation;

  /// No description provided for @timeoutSettings.
  ///
  /// In en, this message translates to:
  /// **'Timeout Settings'**
  String get timeoutSettings;

  /// Controls how long to wait for server responses
  ///
  /// In en, this message translates to:
  /// **'Server Request Timeout'**
  String get serverRequestTimeout;

  /// No description provided for @serverRequestTimeoutDescription.
  ///
  /// In en, this message translates to:
  /// **'Time to wait for server responses (in seconds)'**
  String get serverRequestTimeoutDescription;

  /// Toggle automatic retry on timeout
  ///
  /// In en, this message translates to:
  /// **'Auto-refresh on Timeout'**
  String get autoRefreshOnTimeout;

  /// No description provided for @autoRefreshOnTimeoutDescription.
  ///
  /// In en, this message translates to:
  /// **'Automatically retries requests that timeout'**
  String get autoRefreshOnTimeoutDescription;

  /// Delay between auto retry attempts in seconds
  ///
  /// In en, this message translates to:
  /// **'Auto-refresh Retry Delay'**
  String get autoRefreshRetryDelay;

  /// No description provided for @autoRefreshRetryDelayDescription.
  ///
  /// In en, this message translates to:
  /// **'Delay between auto retry attempts (in seconds)'**
  String get autoRefreshRetryDelayDescription;

  /// Trackers settings section title
  ///
  /// In en, this message translates to:
  /// **'Trackers'**
  String get trackers;

  /// Tracking button on manga page
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get tracking;

  /// Button to add a new tracker binding
  ///
  /// In en, this message translates to:
  /// **'Add Tracking'**
  String get addTracking;

  /// Hint text for tracker search field
  ///
  /// In en, this message translates to:
  /// **'Search on tracker...'**
  String get trackingSearch;

  /// Label for tracking status field
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get trackingStatus;

  /// Label for tracking score field
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get trackingScore;

  /// Label for last chapter read field
  ///
  /// In en, this message translates to:
  /// **'Last Chapter Read'**
  String get trackingLastChapter;

  /// Label for start date field
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get trackingStartDate;

  /// Label for finish date field
  ///
  /// In en, this message translates to:
  /// **'Finish Date'**
  String get trackingFinishDate;

  /// Confirm remove tracking dialog title
  ///
  /// In en, this message translates to:
  /// **'Remove tracking?'**
  String get trackingRemoveConfirm;

  /// Confirm remove tracking dialog body
  ///
  /// In en, this message translates to:
  /// **'This will remove the tracking entry from Catalyst. The entry on the tracker service will not be deleted.'**
  String get trackingRemoveDescription;

  /// Checkbox to also delete remote tracker entry
  ///
  /// In en, this message translates to:
  /// **'Also delete from tracker service'**
  String get trackingRemoveAlsoRemote;

  /// Log in button label
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get logIn;

  /// Log out button label
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// Status label for logged-in tracker
  ///
  /// In en, this message translates to:
  /// **'Logged in'**
  String get loggedIn;

  /// Status label for not-logged-in tracker
  ///
  /// In en, this message translates to:
  /// **'Not logged in'**
  String get notLoggedIn;

  /// Empty state for manga tracker sheet
  ///
  /// In en, this message translates to:
  /// **'No tracking entries yet'**
  String get noTrackingFound;

  /// Empty state for tracker search
  ///
  /// In en, this message translates to:
  /// **'No results found on tracker'**
  String get trackerNoResults;

  /// Sync tracker button label
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get syncNow;

  /// Header for manga comparison section
  ///
  /// In en, this message translates to:
  /// **'Manga Comparison'**
  String get mangaComparison;

  /// Label for source manga in comparison
  ///
  /// In en, this message translates to:
  /// **'From (Current)'**
  String get migrationFromLabel;

  /// Label for target manga in comparison
  ///
  /// In en, this message translates to:
  /// **'To (Target)'**
  String get migrationToLabel;

  /// Header for comparison summary section
  ///
  /// In en, this message translates to:
  /// **'Comparison Summary'**
  String get comparisonSummary;

  /// Author prefix label
  ///
  /// In en, this message translates to:
  /// **'by {author}'**
  String byAuthor(String author);

  /// Header for migration summary section
  ///
  /// In en, this message translates to:
  /// **'Migration Summary'**
  String get migrationSummaryTitle;

  /// Bullet point showing source manga
  ///
  /// In en, this message translates to:
  /// **'Migrated from: {title}'**
  String migratedFromManga(String title);

  /// Bullet point showing target manga
  ///
  /// In en, this message translates to:
  /// **'Migrated to: {title}'**
  String migratedToManga(String title);

  /// Bullet point showing target source
  ///
  /// In en, this message translates to:
  /// **'Source: {name}'**
  String migrationSourceLabel(String name);

  /// App bar title for selecting migration source
  ///
  /// In en, this message translates to:
  /// **'Select Source'**
  String get selectSource;

  /// App bar title for selecting manga to migrate
  ///
  /// In en, this message translates to:
  /// **'Select Manga'**
  String get selectManga;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'ar',
        'de',
        'en',
        'es',
        'fil',
        'fr',
        'gan',
        'id',
        'it',
        'ja',
        'ko',
        'nb',
        'nl',
        'pt',
        'ru',
        'ta',
        'th',
        'tr',
        'uk',
        'vi',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'gan':
      {
        switch (locale.scriptCode) {
          case 'Hant':
            return AppLocalizationsGanHant();
        }
        break;
      }
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hans':
            return AppLocalizationsZhHans();
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'nb':
      {
        switch (locale.countryCode) {
          case 'NO':
            return AppLocalizationsNbNo();
        }
        break;
      }
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppLocalizationsPtBr();
          case 'PT':
            return AppLocalizationsPtPt();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fil':
      return AppLocalizationsFil();
    case 'fr':
      return AppLocalizationsFr();
    case 'gan':
      return AppLocalizationsGan();
    case 'id':
      return AppLocalizationsId();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'nb':
      return AppLocalizationsNb();
    case 'nl':
      return AppLocalizationsNl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'ta':
      return AppLocalizationsTa();
    case 'th':
      return AppLocalizationsTh();
    case 'tr':
      return AppLocalizationsTr();
    case 'uk':
      return AppLocalizationsUk();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
