// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get about => '情報';

  @override
  String get addCategory => 'カテゴリーを追加';

  @override
  String get addToLibrary => 'ライブラリに追加';

  @override
  String get advanced => '高度';

  @override
  String get allScanlators => '全てのScanlator';

  @override
  String get appLanguage => 'アプリの言語';

  @override
  String get appTheme => 'アプリテーマモード';

  @override
  String get appTitle => 'Catalyst';

  @override
  String get appearance => '外観';

  @override
  String get authType => '認証タイプ';

  @override
  String get authTypeBasic => 'BASIC認証';

  @override
  String get authTypeNone => 'なし';

  @override
  String get authentication => '認証';

  @override
  String get autoDownload => '自動ダウンロード';

  @override
  String get autoDownloadNewChapters => '新しい章をダウンロード';

  @override
  String get automaticBackup => '自動バックアップ';

  @override
  String get automaticUpdate => '自動更新';

  @override
  String get automaticallyRefreshMetadata => 'メタデータを自動更新';

  @override
  String get automaticallyRefreshMetadataSubtitle => 'ライブラリの更新時に新しいカバーと詳細をチェック';

  @override
  String get backup => 'バックアップと復元';

  @override
  String get backupAndRestore => 'バックアップと復元';

  @override
  String get backupCleanup => 'バックアップのクリーンアップ';

  @override
  String backupCleanupDescription(String count) {
    String _temp0 = intl.Intl.selectLogic(
      count,
      {
        '0': 'Never',
        '01': '1日以上前のバックアップを削除する',
        'other': '$count日以上前のバックアップを削除する',
      },
    );
    return '$_temp0';
  }

  @override
  String get backupInterval => 'バックアップ間隔';

  @override
  String get backupLocation => 'バックアップ場所';

  @override
  String get backupLocationDescription => '自動バックアップが保存されるサーバーのディレクトリへのパス';

  @override
  String get backupTime => 'バックアップ時刻';

  @override
  String get badges => 'バッジ';

  @override
  String get bookmarked => 'ブックマーク済';

  @override
  String get browse => '閲覧';

  @override
  String get buildTime => 'ビルドタイム';

  @override
  String get cacheCleared => 'キャッシュがクリアされました';

  @override
  String get cancel => 'キャンセル';

  @override
  String get categories => 'カテゴリー';

  @override
  String get categoryUpdate => 'カテゴリーの更新';

  @override
  String get channel => 'チャンネル';

  @override
  String get chapterDownloadLimit => '章ダウンロード制限';

  @override
  String get chapterDownloadLimitDesc => 'ダウンロードする新しい章の量を制限します。';

  @override
  String chapterNumber(double number) {
    return '章$number';
  }

  @override
  String get chapterSortFetchedDate => '取得日';

  @override
  String get chapterSortSource => 'ソース';

  @override
  String get chapterSortUploadDate => 'アップロード日';

  @override
  String get checkForServerUpdates => 'サーバーの更新の確認';

  @override
  String get checkForUpdates => 'アップデートの確認';

  @override
  String get clearCache => 'キャッシュをクリア';

  @override
  String get client => 'クライアント';

  @override
  String get clientVersion => 'クライアントバージョン';

  @override
  String get close => '閉じる';

  @override
  String get cloudflareBypass => 'Cloudflare バイパス';

  @override
  String get completed => '完結済';

  @override
  String get copied => 'コピー済！';

  @override
  String copyMsg(String msg) {
    return '\'$msg\' をコピーしました!';
  }

  @override
  String get createBackupDescription => 'Tachideskのバックアップとしてライブラリをバックアップ';

  @override
  String get createBackupTitle => 'バックアップの作成';

  @override
  String get credentials => '資格情報';

  @override
  String get current => '現在の位置';

  @override
  String daysAgo(Object days) {
    return '$days 日前';
  }

  @override
  String get debugLogs => 'デバッグログ';

  @override
  String get defaultCategory => '新しいマンガをライブラリに追加するときのデフォルトカテゴリ';

  @override
  String get delete => '削除';

  @override
  String get deleteCategoryDescription => 'これにより、このカテゴリのすべてのマンガがデフォルトにマージされます！';

  @override
  String get deleteCategoryTitle => 'よろしいですか？';

  @override
  String get discord => 'Discord';

  @override
  String get display => '表示';

  @override
  String get displayMode => '表示モード';

  @override
  String get displayModeDescriptiveList => '説明付きリスト';

  @override
  String get displayModeGrid => 'グリッド';

  @override
  String get displayModeList => 'リスト';

  @override
  String get downloadLocation => 'ダウンロード場所';

  @override
  String get downloadLocationHint => 'ダウンロードしたファイルが保存されるサーバーのディレクトリへのパス';

  @override
  String get downloaded => 'ダウンロード済';

  @override
  String get downloading => 'ダウンロード中';

  @override
  String get downloads => 'ダウンロード';

  @override
  String get edit => '編集';

  @override
  String get editCategory => 'カテゴリーを編集';

  @override
  String get emptyCategory => 'カテゴリー名は空にすることはできません';

  @override
  String get enableSocksProxy => 'SOCKSプロキシを使用する';

  @override
  String enterProp(Object prop) {
    return '$propを入力してください';
  }

  @override
  String get error => 'エラー';

  @override
  String get errorBackupCreate => 'バックアップの作成に失敗しました';

  @override
  String get errorBackupRestore => 'バックアップの復元に失敗しました！';

  @override
  String get errorExtension => '選択した拡張機能が見つかりません';

  @override
  String get errorFilePick => 'ファイルが選択されていません!';

  @override
  String errorFilePickUnknownExtension(Object extensionName) {
    return '拡張機能 $extensionName のファイルを選択してください';
  }

  @override
  String errorLaunchURL(String url) {
    return '開けませんでした！\n「$url」をクリップボードにコピーしています';
  }

  @override
  String get errorPassword => 'パスワードは空にすることはできません';

  @override
  String get errorSomethingWentWrong => '何らかの問題が発生しました!';

  @override
  String get errorUserName => 'ユーザー名は空にすることはできません';

  @override
  String get excludeEntryWithUnreadChapters => '未読の章があるエントリで章の自動ダウンロードを無視する';

  @override
  String get extensionInstalled => '拡張機能インストール完了！';

  @override
  String get extensionListEmpty => '拡張機能のリストは空です';

  @override
  String get extensionRepository => '拡張機能リポジトリ';

  @override
  String get extensionRepositoryDescription => '拡張機能をインストールできるリポジトリを追加する';

  @override
  String get extensions => '拡張機能';

  @override
  String get failed => '失敗しました';

  @override
  String get filter => 'フィルター';

  @override
  String get findServer => '見つける';

  @override
  String get finished => '読了';

  @override
  String get flareSolverr => 'FlareSolverr';

  @override
  String get flareSolverrRequestTimeout => 'FlareSolverrリクエストタイムアウト';

  @override
  String get flareSolverrServerUrl => 'FlareSolverrサーバーURL';

  @override
  String get flareSolverrSessionName => 'FlareSolverrセッション名';

  @override
  String get flareSolverrSessionTTL => 'FlareSolverrセッションTTL';

  @override
  String get general => '一般';

  @override
  String get gitHub => 'GitHub';

  @override
  String get globalSearch => 'グローバル検索';

  @override
  String get globalUpdate => 'グローバルアップデート';

  @override
  String get gqlDebugLogs => 'Graphql デバッグログ';

  @override
  String get gqlDebugLogsHint => 'このログはプライバシーにかかわる情報を含みます';

  @override
  String get help => 'ヘルプ';

  @override
  String get hideEmptyCategory => '空のカテゴリを隠す';

  @override
  String get inLibrary => 'ライブラリ内';

  @override
  String get includeCategories => 'カテゴリー';

  @override
  String get includeChapters => '章';

  @override
  String get install => 'インストール';

  @override
  String get installing => 'インストール中';

  @override
  String get installingExtension => '拡張機能のインストール中';

  @override
  String get invalidPort => '無効なポート';

  @override
  String invalidProp(Object property) {
    return '無効： $property';
  }

  @override
  String get ip => 'IPアドレス';

  @override
  String get ipHintText => 'サーバーのバインドIPアドレスを入力してください';

  @override
  String get isTrueBlack => '漆黒';

  @override
  String get languages => '言語';

  @override
  String get latest => '最新';

  @override
  String get library => 'ライブラリ';

  @override
  String get localSourceLocation => 'ローカルソースの場所';

  @override
  String get localSourceLocationDescription =>
      'ローカルソースファイルが保存されるサーバーのディレクトリへのパス';

  @override
  String get manga => 'マンガ';

  @override
  String get mangaGridSize => 'マンガグリッドサイズ';

  @override
  String get mangaMissingSources => 'ソースを失ったマンガ';

  @override
  String get mangaSortAlphabetical => 'アルファベット順';

  @override
  String get mangaSortDateAdded => '追加された日付';

  @override
  String get mangaSortLastRead => '最後に読んだ';

  @override
  String get mangaSortLastUpdated => '最後に更新された';

  @override
  String get mangaSortUnread => '未読';

  @override
  String get mangaStatusCancelled => 'キャンセルされた';

  @override
  String get mangaStatusCompleted => '完結済';

  @override
  String get mangaStatusLicensed => 'ライセンスされた';

  @override
  String get mangaStatusOnHiatus => '休止中';

  @override
  String get mangaStatusOngoing => '進行中';

  @override
  String get mangaStatusPublishingFinished => '完結済';

  @override
  String get mangaStatusUnknown => '不明';

  @override
  String get misc => 'その他';

  @override
  String get missingExtension => '拡張機能が見つからない';

  @override
  String get missingTrackers => 'トラッカーが見つからない';

  @override
  String get more => 'もっと';

  @override
  String get moveToBottom => '下部に移動';

  @override
  String get moveToTop => '上部へ移動';

  @override
  String nChapters(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n 章',
      one: '1章',
      zero: 'なし',
    );
    return '$_temp0';
  }

  @override
  String nDays(String count) {
    String _temp0 = intl.Intl.selectLogic(
      count,
      {
        '01': '1日',
        'other': '$count日',
      },
    );
    return '$_temp0';
  }

  @override
  String nHours(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n時間',
      one: '1時間',
    );
    return '$_temp0';
  }

  @override
  String nMinutes(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n分',
      one: '1分',
    );
    return '$_temp0';
  }

  @override
  String nRepo(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nリポジトリ',
      one: '1リポジトリ',
    );
    return '$_temp0';
  }

  @override
  String nSeconds(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n秒',
      one: '1秒',
    );
    return '$_temp0';
  }

  @override
  String nSources(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nソース',
      one: '1ソース',
    );
    return '$_temp0';
  }

  @override
  String nameCountDisplay(int count, String name) {
    return '$name: $count';
  }

  @override
  String get newUpdateAvailable => '新しいアップデートが利用可能';

  @override
  String nextChapter(Object chapterTitle) {
    return '次へ: $chapterTitle';
  }

  @override
  String get noCategoriesFound =>
      'カテゴリーがありません。\n(ヒント:プラスボタンをタップするとカテゴリーを作成できます)';

  @override
  String get noCategoriesFoundAlt => 'カテゴリーがありません。\n設定でカテゴリを作成できます';

  @override
  String get noCategoryMangaFound =>
      'このカテゴリーにはマンガが見つかりませんでした。\n(ヒント: 検索とフィルターを確認してください!)';

  @override
  String get noChaptersFound => '章が見つかりません';

  @override
  String get noDownloads => 'ダウンロードがありません';

  @override
  String get noMangaFound => 'マンガが見つかりません';

  @override
  String noOfChapters(int count) {
    return '$count 章';
  }

  @override
  String noPropFound(Object prop) {
    return '$propが見つかりませんでした';
  }

  @override
  String get noResultFound => '結果が見つかりません';

  @override
  String get noServerFound => 'ローカルネットワークにサーバーが見つかりません';

  @override
  String get noSourcesFound => 'ソースが見つかりません';

  @override
  String get noUpdatesAvailable => '最新バージョンを使用しています';

  @override
  String get noUpdatesFound => 'アップデートが見つかりませんでした';

  @override
  String get none => 'なし';

  @override
  String get nsfw => 'NSFWな拡張機能とソースを表示する';

  @override
  String get nsfw18 => '18禁';

  @override
  String get nsfwInfo =>
      'これは非公式の拡張機能、または誤ってフラグが立てられた可能性のある拡張機能がアプリ内で NSFW(18+) コンテンツを表示することを防ぐものではありません';

  @override
  String numSelected(int num) {
    return '$num 選択済み';
  }

  @override
  String get obsolete => '廃止済';

  @override
  String get openFlareSolverr => '設定方法に関する情報は、FlareSolverrを確認してください';

  @override
  String get openInWeb => 'Webで開く';

  @override
  String get or => 'または';

  @override
  String page(int number) {
    return 'ページ: $number';
  }

  @override
  String get parallelSourceRequest => 'ソースリクエストの並列化';

  @override
  String get password => 'パスワード';

  @override
  String get pause => '一時停止';

  @override
  String get pending => '保留中';

  @override
  String get pinchToZoom => 'ピンチでズーム';

  @override
  String previousChapter(Object chapterTitle) {
    return '前: $chapterTitle';
  }

  @override
  String get queued => 'キューに追加済';

  @override
  String get quickSearch => 'クイック検索';

  @override
  String get quickSearchCategory => 'カテゴリ「C」に移動';

  @override
  String get quickSearchCategoryManga => 'カテゴリ「C」のマンガ「M」に移動';

  @override
  String get quickSearchCategoryMangaChapter => 'カテゴリ「C」のマンガ「M」から章名「CN」に移動します';

  @override
  String get quickSearchContext => 'クエリ X を検索します (結果は画面のコンテキストに基づきます)';

  @override
  String get quickSearchShowAllCommandTip =>
      'ヒント: \'?\' を入力すると、すべてのコマンドが表示されます';

  @override
  String get quickSearchSource => 'ソース「S」に移動';

  @override
  String get quickSearchSourceManga => 'ソース「S」でマンガ「M」を検索';

  @override
  String get reader => 'リーダー';

  @override
  String get readerMagnifierSize => '拡大鏡のサイズ';

  @override
  String get readerMode => '読書モード';

  @override
  String get readerModeContinuousHorizontalLTR => '横方向に連続（左から右）';

  @override
  String get readerModeContinuousHorizontalRTL => '横方向に連続（右から左）';

  @override
  String get readerModeContinuousVertical => '縦方向に連続';

  @override
  String get readerModeDefaultReader => '標準';

  @override
  String get readerModeSingleHorizontalLTR => '横方向（1ページ、左から右）';

  @override
  String get readerModeSingleHorizontalRTL => '横方向（1ページ、右から左）';

  @override
  String get readerModeSingleVertical => '縦（１ページ）';

  @override
  String get readerModeWebtoon => 'ウェブトゥーン';

  @override
  String get readerNavigationLayout => 'ナビゲーションレイアウト';

  @override
  String get readerNavigationLayoutDefault => '標準';

  @override
  String get readerNavigationLayoutDisabled => '無効';

  @override
  String get readerNavigationLayoutEdge => 'エッジ';

  @override
  String get readerNavigationLayoutInvert => 'タップを反転';

  @override
  String get readerNavigationLayoutKindlish => 'Kindle風';

  @override
  String get readerNavigationLayoutLShaped => 'L形';

  @override
  String get readerNavigationLayoutRightAndLeft => '右と左';

  @override
  String get readerOverlay => 'リーダー初期オーバーレイ';

  @override
  String get readerOverlaySubtitle => 'チャプターを開くときにタイトルとクイック設定を表示';

  @override
  String get readerPadding => 'リーダーのパディング';

  @override
  String get readerScrollAnimation => 'スクロールアニメーション';

  @override
  String get readerSwipeChapterToggle => 'スワイプの切り替え';

  @override
  String get readerSwipeChapterToggleDescription => 'スワイプしてリーダーの章を変更します';

  @override
  String get readerLastPageSwipeToggle => '最終ページでのスワイプ';

  @override
  String get readerLastPageSwipeToggleDescription => '最終ページでのみスワイプして次の章へ移動';

  @override
  String get readerVolumeTap => 'ボリュームキー';

  @override
  String get readerVolumeTapInvert => '反転ボリュームキー';

  @override
  String get readerVolumeTapSubtitle => 'ボリュームキーでナビゲート';

  @override
  String get readerIgnoreSafeAreaToggle => 'セーフエリアを無視';

  @override
  String get readerIgnoreSafeAreaToggleDescription =>
      'コンテンツをノッチやホームインジケーター領域まで表示可能にする';

  @override
  String get reddit => 'Reddit';

  @override
  String get refresh => '更新';

  @override
  String get migrate => '移行';

  @override
  String get migrationSelectTargetSource => '移行先ソースを選択';

  @override
  String migrationSearchInSource(Object sourceName) {
    return '$sourceName内を検索';
  }

  @override
  String get migrationPreview => '移行プレビュー';

  @override
  String get migrationInProgress => '移行中';

  @override
  String get migrationComplete => '移行が正常に完了しました';

  @override
  String get migrationFailed => '移行に失敗しました';

  @override
  String get migrationCancelled => '移行がキャンセルされました';

  @override
  String get migrateChapters => '章の移行';

  @override
  String get migrateChaptersDescription => '章の読書状況を新しいソースにコピーする';

  @override
  String get migrateCategories => 'カテゴリの移行';

  @override
  String get migrateCategoriesDescription => '漫画のカテゴリを新しいソースにコピーする';

  @override
  String get migrateDownloads => 'ダウンロードの移行';

  @override
  String get migrateDownloadsDescription => 'ダウンロード済みの章を新しいソースに移動する';

  @override
  String get migrateTracking => 'トラッキングの移行';

  @override
  String get migrateTrackingDescription => 'トラッキング情報を新しいソースにコピーする';

  @override
  String get migrationOptions => '移行オプション';

  @override
  String get migrationSettings => '移行設定';

  @override
  String get selectTargetSource => '移行先ソースを選択';

  @override
  String get noSourcesAvailable => '移行可能なソースがありません';

  @override
  String get checkSourceConfiguration => 'ソースの設定を確認してください';

  @override
  String get noAlternativeSources => '代替のソースがありません';

  @override
  String get installMoreSources => '移行を有効にするには、ソースを追加してください';

  @override
  String get errorLoadingSources => 'ソースの読み込みエラー';

  @override
  String get errorGettingMigrationSources => '移行用ソースの取得に失敗しました';

  @override
  String get errorSearchingMangaInSource => 'ソース内の漫画検索に失敗しました';

  @override
  String get errorFetchingSourceManga => 'ソースの漫画取得に失敗しました';

  @override
  String get errorSourceMangaNotFound => 'ソースの漫画が見つかりません';

  @override
  String get errorFetchingTargetManga => '移行先の漫画取得に失敗しました';

  @override
  String get errorTargetMangaNotFound => '移行先の漫画が見つかりません';

  @override
  String get searchManga => '漫画を検索…';

  @override
  String get searchForManga => '移行先ソースで漫画を検索';

  @override
  String get enterSearchTerm => '漫画を探すための検索語を入力してください';

  @override
  String get noResultsFound => '検索結果が見つかりません';

  @override
  String get tryDifferentSearch => '別の検索語を試してください';

  @override
  String get searchError => '検索エラー';

  @override
  String get importantNotice => '重要なお知らせ';

  @override
  String get migrationWarning => 'これにより漫画データが完全に移動されます。この操作は取り消せません。';

  @override
  String get deleteSourceWarning => '移行後、元の漫画はライブラリから削除されます。';

  @override
  String get confirmMigration => '移行の確認';

  @override
  String get migrationConfirmationMessage => 'この漫画を移行してもよろしいですか？この操作は取り消せません。';

  @override
  String get startMigration => '移行を開始';

  @override
  String get preparingMigration => '移行を準備しています…';

  @override
  String get migrationCompleted => '移行が完了しました！';

  @override
  String get migrationSuccessMessage => '漫画が新しいソースへ正常に移行されました。';

  @override
  String get migrationCancelledMessage => '移行処理はキャンセルされました。変更は行われていません。';

  @override
  String get cancelMigration => '移行をキャンセル';

  @override
  String get cancelMigrationConfirmation => '移行をキャンセルしてもよろしいですか？この操作は取り消せません。';

  @override
  String get quickPresets => 'クイックプリセット';

  @override
  String get quickMigration => 'クイック';

  @override
  String get fullMigration => 'フル';

  @override
  String get customMigration => 'カスタム';

  @override
  String get deleteSourceManga => '元の漫画を削除';

  @override
  String get deleteSourceMangaDescription => '移行後、元の漫画をライブラリから削除します';

  @override
  String get done => '完了';

  @override
  String get yes => 'はい';

  @override
  String get no => 'いいえ';

  @override
  String get from => 'から';

  @override
  String get to => 'へ';

  @override
  String get source => 'ソース';

  @override
  String get migrationDetails => '移行の詳細';

  @override
  String get searchAllSources => '全てのソースを検索';

  @override
  String get searchingAllSources => '利用可能なすべてのソースを検索しています…';

  @override
  String get noMatchingMangaFound => 'どのソースにも該当する漫画が見つかりません';

  @override
  String get deleteSourceAfterMigration => '移行後に元の漫画を削除する';

  @override
  String get reload => 'リロード';

  @override
  String get remove => '削除';

  @override
  String get removeFromLibrary => 'ライブラリから削除しますか?';

  @override
  String get reset => 'リセット';

  @override
  String get restore => '復元';

  @override
  String get restoreBackupDescription => 'バックアップからTachideskを復元する';

  @override
  String get restoreBackupTitle => 'バックアップから復元する';

  @override
  String get restored => 'バックアップから復元されました！';

  @override
  String get restoring => 'バックアップから復元しています';

  @override
  String get resume => '再開';

  @override
  String get retry => '再試行';

  @override
  String get running => '実行中';

  @override
  String get save => '保存';

  @override
  String get saveAsCBZArchive => 'CBZアーカイブとして保存';

  @override
  String get scanlators => 'スキャンレーター';

  @override
  String get search => '検索';

  @override
  String get searchingForUpdates => '更新を確認中';

  @override
  String get selectInBetween => '間を選択';

  @override
  String get selectNext10 => '次の10章を選択';

  @override
  String get selectUnread => '未読を選択';

  @override
  String get server => 'サーバー';

  @override
  String get serverBindings => 'サーバーバインディング';

  @override
  String get serverPort => 'サーバーポート';

  @override
  String get serverPortHintText => 'サーバーポート';

  @override
  String get serverUrl => 'サーバー URL';

  @override
  String get serverUrlHintText => 'サーバーURL';

  @override
  String get serverVersion => 'サーバーバージョン';

  @override
  String get settings => '設定';

  @override
  String get skipUpdatingEntries => 'アップデートをスキップするエントリ';

  @override
  String get socksHost => 'SOCKSホスト';

  @override
  String get socksPassword => 'SOCKSパスワード';

  @override
  String get socksPort => 'SOCKSポート';

  @override
  String get socksProxy => 'SOCKSプロキシ';

  @override
  String get socksUserName => 'SOCKSユーザー名';

  @override
  String get socksVersion => 'SOCKSバージョン';

  @override
  String get sort => '並び替え';

  @override
  String get sourceTypeFilter => 'フィルター';

  @override
  String get sourceTypeLatest => '最新';

  @override
  String get sourceTypePopular => '人気';

  @override
  String get sources => 'ソース';

  @override
  String get start => '開始';

  @override
  String get systemTrayIcon => 'システムトレイにアイコンを表示する';

  @override
  String get thatHaventBeenStarted => 'まだ始まっていない';

  @override
  String get themeModeDark => 'ダーク';

  @override
  String get themeModeLight => 'ライト';

  @override
  String get themeModeSystem => 'システム';

  @override
  String get today => '今日';

  @override
  String get uninstall => 'アンインストール';

  @override
  String get uninstalling => 'アンインストール中';

  @override
  String get unknownAuthor => '未知の著者';

  @override
  String get unknownManga => '未知のマンガ';

  @override
  String get unknownSource => '未知のソース';

  @override
  String get unread => '未読';

  @override
  String get update => '更新';

  @override
  String get updateCompleted => '更新完了';

  @override
  String updateFailed(Object property) {
    return '$property の更新に失敗しました';
  }

  @override
  String get updates => 'アップデート';

  @override
  String get updatesSummary => 'アップデートの概要';

  @override
  String get updating => 'アップデート中';

  @override
  String get userName => 'ユーザー名';

  @override
  String get validating => '検証中';

  @override
  String versionAvailable(String app, String version) {
    return 'バージョン $version が $app で利用可能になりました!';
  }

  @override
  String get webUI => 'WEB UIで開く';

  @override
  String get webView => 'ウェブビュー';

  @override
  String get whatsNew => '新着情報';

  @override
  String get withCompletedStatus => '「完結済」ステータス';

  @override
  String get withUnreadChapter => '未読の章';

  @override
  String get yesterday => '昨日';

  @override
  String get recentlyRead => '最近読んだ';

  @override
  String get history => '履歴';

  @override
  String get searchHistory => '履歴を検索…';

  @override
  String get noHistoryFound => '読書履歴が見つかりません';

  @override
  String get startReadingToSeeHistory => '読書を始めるとここに履歴が表示されます';

  @override
  String get noSearchResults => '検索結果がありません';

  @override
  String get tryDifferentSearchTerm => '別の検索語を試してください';

  @override
  String get errorOccurred => 'エラーが発生しました';

  @override
  String get viewManga => '漫画を見る';

  @override
  String get removeFromHistory => '履歴から削除';

  @override
  String get removeFromHistoryConfirmation => 'この章を読書履歴から削除してもよろしいですか？';

  @override
  String get timeoutSettings => 'タイムアウト設定';

  @override
  String get serverRequestTimeout => 'サーバーリクエストのタイムアウト';

  @override
  String get serverRequestTimeoutDescription => 'サーバー応答を待つ時間（秒）';

  @override
  String get autoRefreshOnTimeout => 'タイムアウト時の自動再試行';

  @override
  String get autoRefreshOnTimeoutDescription => 'タイムアウトしたリクエストを自動的に再試行します';

  @override
  String get autoRefreshRetryDelay => '自動再試行の待機時間';

  @override
  String get autoRefreshRetryDelayDescription => '自動再試行の間隔（秒）';

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
