// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get about => 'Giới thiệu';

  @override
  String get addCategory => 'Thêm danh mục';

  @override
  String get addToLibrary => 'Thêm vào thư viện';

  @override
  String get advanced => 'Nâng cao';

  @override
  String get allScanlators => 'Tất cả nhóm dịch';

  @override
  String get appLanguage => 'Ngôn ngữ';

  @override
  String get appTheme => 'Chủ đề';

  @override
  String get appTitle => 'Catalyst';

  @override
  String get appearance => 'Giao diện';

  @override
  String get authType => 'Xác thực';

  @override
  String get authTypeBasic => 'Xác thực cơ bản';

  @override
  String get authTypeNone => 'Không';

  @override
  String get authentication => 'Xác thực';

  @override
  String get autoDownload => 'Tự động tải xuống';

  @override
  String get autoDownloadNewChapters => 'Tải xuống chương mới';

  @override
  String get automaticBackup => 'Tự động sao lưu';

  @override
  String get automaticUpdate => 'Tự động cập nhật';

  @override
  String get automaticallyRefreshMetadata => 'Tự động làm mới siêu dữ liệu';

  @override
  String get automaticallyRefreshMetadataSubtitle =>
      'Kiểm tra bìa và thông tin chi tiết mới khi cập nhật thư viện';

  @override
  String get backup => 'Sao lưu & Khôi phục';

  @override
  String get backupAndRestore => 'Sao lưu và khôi phục';

  @override
  String get backupCleanup => 'Dọn dẹp sao lưu';

  @override
  String backupCleanupDescription(String count) {
    String _temp0 = intl.Intl.selectLogic(
      count,
      {
        '0': 'Never',
        '01': 'Xóa các bản sao lưu cũ 1 ngày',
        'other': 'Xóa các bản sao lưu cũ hơn $count ngày',
      },
    );
    return '$_temp0';
  }

  @override
  String get backupInterval => 'Thời gian sao lưu';

  @override
  String get backupLocation => 'Vị trí sao lưu';

  @override
  String get backupLocationDescription =>
      'Đường dẫn đến thư mục trên máy chủ nơi các bản sao lưu sẽ được lưu vào';

  @override
  String get backupTime => 'Thời gian sao lưu';

  @override
  String get badges => 'Nhãn';

  @override
  String get bookmarked => 'Đã đánh dấu';

  @override
  String get browse => 'Duyệt';

  @override
  String get buildTime => 'Phát hành';

  @override
  String get cacheCleared => 'Đã xóa bộ nhớ đệm';

  @override
  String get cancel => 'Hủy bỏ';

  @override
  String get categories => 'Danh mục';

  @override
  String get categoryUpdate => 'Cập nhật danh mục';

  @override
  String get channel => 'Kênh';

  @override
  String get chapterDownloadLimit => 'Giới hạn tải chương';

  @override
  String get chapterDownloadLimitDesc =>
      'Giới hạn số lượng chương mới sẽ được tải xuống.';

  @override
  String chapterNumber(double number) {
    return 'Chương $number';
  }

  @override
  String get chapterSortFetchedDate => 'Theo ngày tìm nạp';

  @override
  String get chapterSortSource => 'Theo nguồn truyện';

  @override
  String get chapterSortUploadDate => 'Theo ngày đăng';

  @override
  String get checkForServerUpdates => 'Kiểm tra cập nhật máy chủ';

  @override
  String get checkForUpdates => 'Kiểm tra bản cập nhật';

  @override
  String get clearCache => 'Xóa bộ nhớ đệm';

  @override
  String get client => 'Khách';

  @override
  String get clientVersion => 'Phiên bản máy khách';

  @override
  String get close => 'Đóng';

  @override
  String get cloudflareBypass => 'Bỏ qua Cloudflare';

  @override
  String get completed => 'Hoàn thành';

  @override
  String get copied => 'Đã sao chép!';

  @override
  String copyMsg(String msg) {
    return '\'$msg\' Đã sao chép!';
  }

  @override
  String get createBackupDescription =>
      'Sao lưu thư viện bằng định dạng Tachiyomi';

  @override
  String get createBackupTitle => 'Tạo bản sao lưu';

  @override
  String get credentials => 'Thông tin xác thực';

  @override
  String get current => 'Hiện hành';

  @override
  String daysAgo(Object days) {
    return '$days ngày trước';
  }

  @override
  String get debugLogs => 'Nhật ký gỡ lỗi';

  @override
  String get defaultCategory =>
      'Danh mục mặc định khi thêm manga mới vào thư viện';

  @override
  String get delete => 'Xóa bỏ';

  @override
  String get deleteCategoryDescription =>
      'Điều này sẽ hợp nhất tất cả Manga trong Danh mục này thành Mặc định!';

  @override
  String get deleteCategoryTitle => 'Bạn có chắc không?';

  @override
  String get discord => 'Discord';

  @override
  String get display => 'Hiển thị';

  @override
  String get displayMode => 'Chế độ hiển thị';

  @override
  String get displayModeDescriptiveList => 'Danh sách chi tiết';

  @override
  String get displayModeGrid => 'Lưới';

  @override
  String get displayModeList => 'Danh sách';

  @override
  String get downloadLocation => 'Vị trí tải xuống';

  @override
  String get downloadLocationHint =>
      'Đường dẫn đến thư mục trên máy chủ nơi các tập tin đã tải xuống sẽ được lưu vào';

  @override
  String get downloaded => 'Đã tải xuống';

  @override
  String get downloading => 'Đang tải xuống';

  @override
  String get downloads => 'Tải xuống';

  @override
  String get edit => 'Chỉnh sửa';

  @override
  String get editCategory => 'Chỉnh sửa danh mục';

  @override
  String get emptyCategory => 'Tên danh mục không được để trống';

  @override
  String get enableSocksProxy => 'Sử dụng SOCKS Proxy';

  @override
  String enterProp(Object prop) {
    return 'Nhập $prop';
  }

  @override
  String get error => 'Lỗi';

  @override
  String get errorBackupCreate => 'Không tạo được bản sao lưu';

  @override
  String get errorBackupRestore => 'Khôi phục sao lưu thất bại!';

  @override
  String get errorExtension => 'Không thể tìm thấy phần mở rộng đã chọn';

  @override
  String get errorFilePick => 'Tệp không được chọn!';

  @override
  String errorFilePickUnknownExtension(Object extensionName) {
    return 'Vui lòng chọn tệp có phần mở rộng $extensionName';
  }

  @override
  String errorLaunchURL(String url) {
    return 'Không thể mở được!\nĐang sao chép \"$url\" vào bảng nhớ tạm';
  }

  @override
  String get errorPassword => 'Mật khẩu không thể trống';

  @override
  String get errorSomethingWentWrong => 'Đã xảy ra lỗi!';

  @override
  String get errorUserName => 'Tên người dùng không được để trống';

  @override
  String get excludeEntryWithUnreadChapters =>
      'Không tự động tải chương các truyện đang có chương chưa đọc';

  @override
  String get extensionInstalled => 'Đã cài đặt phần mở rộng!';

  @override
  String get extensionListEmpty => 'Danh sách phần mở rộng trống';

  @override
  String get extensionRepository => 'Kho lưu trữ mở rộng';

  @override
  String get extensionRepositoryDescription =>
      'Thêm kho lưu trữ mà phần mở rộng có thể được cài đặt';

  @override
  String get extensions => 'Phần mở rộng';

  @override
  String get failed => 'Thất bại';

  @override
  String get filter => 'Bộ lọc';

  @override
  String get findServer => 'Tìm';

  @override
  String get finished => 'Hoàn thành';

  @override
  String get flareSolverr => 'FlareSolverr';

  @override
  String get flareSolverrRequestTimeout =>
      'Thời gian chờ yêu cầu của FlareSolverr';

  @override
  String get flareSolverrServerUrl => 'Url máy chủ FlareSolverr';

  @override
  String get flareSolverrSessionName => 'Tên phiên FlareSolverr';

  @override
  String get flareSolverrSessionTTL => 'Phiên FlareSolverr TTL';

  @override
  String get general => 'Tổng quan';

  @override
  String get gitHub => 'GitHub';

  @override
  String get globalSearch => 'Tìm kiếm toàn cầu';

  @override
  String get globalUpdate => 'Cập nhật thư viện';

  @override
  String get gqlDebugLogs => 'Nhật ký gỡ lỗi Graphql';

  @override
  String get gqlDebugLogsHint =>
      'Điều này bao gồm các bản ghi có thông tin không an toàn về quyền riêng tư';

  @override
  String get help => 'Trợ giúp';

  @override
  String get hideEmptyCategory => 'Ẩn danh mục trống';

  @override
  String get inLibrary => 'Trong thư viện';

  @override
  String get includeCategories => 'Thể loại';

  @override
  String get includeChapters => 'Chương';

  @override
  String get install => 'Cài đặt';

  @override
  String get installing => 'Đang cài đặt';

  @override
  String get installingExtension => 'Cài đặt phần mở rộng';

  @override
  String get invalidPort => 'Cổng không hợp lệ';

  @override
  String invalidProp(Object property) {
    return 'Không hợp lệ $property';
  }

  @override
  String get ip => 'Địa chỉ IP';

  @override
  String get ipHintText => 'Nhập địa chỉ IP liên kết máy chủ';

  @override
  String get isTrueBlack => 'Đen tuyền';

  @override
  String get languages => 'Ngôn ngữ';

  @override
  String get latest => 'Mới nhất';

  @override
  String get library => 'Thư viện';

  @override
  String get localSourceLocation => 'Vị trí nguồn cục bộ';

  @override
  String get localSourceLocationDescription =>
      'Đường dẫn đến thư mục trên máy chủ nơi các tệp nguồn cục bộ được lưu trong';

  @override
  String get manga => 'Truyện';

  @override
  String get mangaGridSize => 'Kích thước lưới';

  @override
  String get mangaMissingSources => 'Truyện thiếu nguồn';

  @override
  String get mangaSortAlphabetical => 'Theo bảng chữ cái';

  @override
  String get mangaSortDateAdded => 'Ngày thêm';

  @override
  String get mangaSortLastRead => 'Đã đọc gần nhất';

  @override
  String get mangaSortLastUpdated => 'Lần cuối cập nhật';

  @override
  String get mangaSortUnread => 'Chưa đọc';

  @override
  String get mangaStatusCancelled => 'Đã hủy';

  @override
  String get mangaStatusCompleted => 'Hoàn thành';

  @override
  String get mangaStatusLicensed => 'Được cấp phép';

  @override
  String get mangaStatusOnHiatus => 'Tạm ngưng';

  @override
  String get mangaStatusOngoing => 'Đang tiến hành';

  @override
  String get mangaStatusPublishingFinished => 'Đã hoàn thành xuất bản';

  @override
  String get mangaStatusUnknown => 'Không rõ';

  @override
  String get misc => 'Khác';

  @override
  String get missingExtension => 'Thiếu phần mở rộng';

  @override
  String get missingTrackers => 'Thiếu trình theo dõi';

  @override
  String get more => 'Thêm';

  @override
  String get moveToBottom => 'Di chuyển xuống dưới cùng';

  @override
  String get moveToTop => 'Di chuyển lên trên cùng';

  @override
  String nChapters(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Chương',
      one: '1 Chương',
      zero: 'None',
    );
    return '$_temp0';
  }

  @override
  String nDays(String count) {
    String _temp0 = intl.Intl.selectLogic(
      count,
      {
        '01': '01 Ngày',
        'other': '$count Ngày',
      },
    );
    return '$_temp0';
  }

  @override
  String nHours(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n giờ',
      one: '1 giờ',
    );
    return '$_temp0';
  }

  @override
  String nMinutes(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Phút',
      one: '1 Phút',
    );
    return '$_temp0';
  }

  @override
  String nRepo(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Kho lưu trữ',
      one: '1 Kho lưu trữ',
    );
    return '$_temp0';
  }

  @override
  String nSeconds(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n giây',
      one: '1 giây',
    );
    return '$_temp0';
  }

  @override
  String nSources(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Nguồn',
      one: '1 Nguồn',
    );
    return '$_temp0';
  }

  @override
  String nameCountDisplay(int count, String name) {
    return '$name: $count';
  }

  @override
  String get newUpdateAvailable => 'Đã có bản cập nhật mới';

  @override
  String nextChapter(Object chapterTitle) {
    return 'Chương kế tiếp:$chapterTitle';
  }

  @override
  String get noCategoriesFound =>
      'Bạn không có bất kỳ Danh mục nào. \n(Mẹo: Nhấn vào nút Dấu cộng để tạo một nút để sắp xếp thư viện của bạn)';

  @override
  String get noCategoriesFoundAlt =>
      'Bạn không có bất kỳ Danh mục nào.\nTạo một cái trong cài đặt để tổ chức thư viện của bạn';

  @override
  String get noCategoryMangaFound =>
      'Không tìm thấy manga nào trong danh mục này.\n(Mẹo: Kiểm tra tìm kiếm và bộ lọc của bạn!)';

  @override
  String get noChaptersFound => 'Không tìm thấy chương nào';

  @override
  String get noDownloads => 'Không có';

  @override
  String get noMangaFound => 'Không tìm thấy Manga nào';

  @override
  String noOfChapters(int count) {
    return '$count Chương';
  }

  @override
  String noPropFound(Object prop) {
    return 'Không tìm thấy $prop';
  }

  @override
  String get noResultFound => 'Không tìm thấy kết quả nào';

  @override
  String get noServerFound =>
      'Không tìm thấy máy chủ nào trong mạng cục bộ của bạn';

  @override
  String get noSourcesFound => 'Không tìm thấy nguồn nào';

  @override
  String get noUpdatesAvailable => 'Bạn đang sử dụng phiên bản mới nhất';

  @override
  String get noUpdatesFound => 'Không tìm thấy bản cập nhật nào';

  @override
  String get none => 'Không có';

  @override
  String get nsfw => 'Hiển thị các phần mở rộng và nguồn NSFW';

  @override
  String get nsfw18 => '18+';

  @override
  String get nsfwInfo =>
      'Điều này không ngăn các phần mở rộng không chính thức hoặc có khả năng gắn cờ không chính xác hiển thị nội dung NSFW(18+) trong ứng dụng';

  @override
  String numSelected(int num) {
    return '$num Đã chọn';
  }

  @override
  String get obsolete => 'Lỗi thời';

  @override
  String get openFlareSolverr =>
      'Kiểm tra FlareSolverr để biết thông tin về cách thiết lập';

  @override
  String get openInWeb => 'Mở Trong Web';

  @override
  String get or => 'hoặc';

  @override
  String page(int number) {
    return 'Trang: $number';
  }

  @override
  String get parallelSourceRequest => 'Số lượng kết nối';

  @override
  String get password => 'Mật khẩu';

  @override
  String get pause => 'Tạm dừng';

  @override
  String get pending => 'Chờ xử lý';

  @override
  String get pinchToZoom => 'Chụm để thu phóng';

  @override
  String previousChapter(Object chapterTitle) {
    return 'Chương trước đó: $chapterTitle';
  }

  @override
  String get queued => 'Đã xếp hàng';

  @override
  String get quickSearch => 'Tìm kiếm nhanh';

  @override
  String get quickSearchCategory => 'Chuyển đến Danh mục \'C\'';

  @override
  String get quickSearchCategoryManga =>
      'Đi đến Manga \'M\' trong Danh mục \'C\'';

  @override
  String get quickSearchCategoryMangaChapter =>
      'Chuyển đến Tên chương \'CN\' từ Manga \'M\' trong Danh mục \'C\'';

  @override
  String get quickSearchContext =>
      'Tìm kiếm truy vấn X (Kết quả dựa trên ngữ cảnh màn hình)';

  @override
  String get quickSearchShowAllCommandTip =>
      'Mẹo: Nhập \'?\' để xem tất cả các lệnh';

  @override
  String get quickSearchSource => 'Đi tới Nguồn \'S\'';

  @override
  String get quickSearchSourceManga => 'Tìm kiếm Manga \'M\' trong Nguồn \'S\'';

  @override
  String get reader => 'Trình đọc';

  @override
  String get readerMagnifierSize => 'Kích thước kính lúp';

  @override
  String get readerMode => 'Kiểu đọc';

  @override
  String get readerModeContinuousHorizontalLTR => 'Ngang liên tục (LTR)';

  @override
  String get readerModeContinuousHorizontalRTL => 'Ngang liên tục (RTL)';

  @override
  String get readerModeContinuousVertical => 'Cuộc dọc có khoảng cách';

  @override
  String get readerModeDefaultReader => 'Mặc định';

  @override
  String get readerModeSingleHorizontalLTR => 'Đơn ngang (LTR)';

  @override
  String get readerModeSingleHorizontalRTL => 'Ngang đơn (RTL)';

  @override
  String get readerModeSingleVertical => 'Dọc đơn';

  @override
  String get readerModeWebtoon => 'Cuộn dọc';

  @override
  String get readerNavigationLayout => 'Bố cục điều hướng';

  @override
  String get readerNavigationLayoutDefault => 'Mặc định';

  @override
  String get readerNavigationLayoutDisabled => 'Tắt';

  @override
  String get readerNavigationLayoutEdge => 'Dạng góc cạnh';

  @override
  String get readerNavigationLayoutInvert => 'Đảo ngược khu vực nhấn';

  @override
  String get readerNavigationLayoutKindlish => 'Dạng Kindle';

  @override
  String get readerNavigationLayoutLShaped => 'Dạng chữ L';

  @override
  String get readerNavigationLayoutRightAndLeft => 'Phải và trái';

  @override
  String get readerOverlay => 'Lớp phủ ban đầu của trình đọc';

  @override
  String get readerOverlaySubtitle =>
      'Hiển thị tiêu đề và cài đặt nhanh khi mở một chương';

  @override
  String get readerPadding => 'Phần đệm đầu đọc';

  @override
  String get readerScrollAnimation => 'Hoạt ảnh cuộn';

  @override
  String get readerSwipeChapterToggle => 'Vuốt chuyển đổi';

  @override
  String get readerSwipeChapterToggleDescription =>
      'Vuốt để thay đổi chương trong trình đọc';

  @override
  String get readerLastPageSwipeToggle => 'Vuốt trang cuối cùng';

  @override
  String get readerLastPageSwipeToggleDescription =>
      'Vuốt sang chương tiếp theo chỉ ở trang cuối cùng';

  @override
  String get readerVolumeTap => 'Phím âm lượng';

  @override
  String get readerVolumeTapInvert => 'Đảo ngược phím âm lượng';

  @override
  String get readerVolumeTapSubtitle => 'Điều hướng bằng phím âm lượng';

  @override
  String get readerIgnoreSafeAreaToggle => 'Ignore Safe Area';

  @override
  String get readerIgnoreSafeAreaToggleDescription =>
      'Allow content to extend into notch and home indicator areas';

  @override
  String get reddit => 'Reddit';

  @override
  String get refresh => 'Làm mới';

  @override
  String get migrate => 'Di chuyển';

  @override
  String get migrationSelectTargetSource => 'Chọn nguồn đích';

  @override
  String migrationSearchInSource(Object sourceName) {
    return 'Tìm kiếm trong $sourceName';
  }

  @override
  String get migrationPreview => 'Xem trước di chuyển';

  @override
  String get migrationInProgress => 'Đang tiến hành di chuyển';

  @override
  String get migrationComplete => 'Di chuyển đã hoàn tất';

  @override
  String get migrationFailed => 'Di chuyển không thành công';

  @override
  String get migrationCancelled => 'Di chuyển đã bị hủy bỏ';

  @override
  String get migrateChapters => 'Di chuyển chương';

  @override
  String get migrateChaptersDescription =>
      'Sao chép trạng thái đã đọc chương sang nguồn mới';

  @override
  String get migrateCategories => 'Di chuyển danh mục';

  @override
  String get migrateCategoriesDescription =>
      'Sao chép danh mục Manga vào nguồn mới';

  @override
  String get migrateDownloads => 'Di chuyển tải xuống';

  @override
  String get migrateDownloadsDescription =>
      'Di chuyển các chương được tải xuống sang nguồn mới';

  @override
  String get migrateTracking => 'Di chuyển theo dõi';

  @override
  String get migrateTrackingDescription =>
      'Sao chép thông tin theo dõi vào nguồn mới';

  @override
  String get migrationOptions => 'Tùy chọn di chuyển';

  @override
  String get migrationSettings => 'Cài đặt di chuyển';

  @override
  String get selectTargetSource => 'Chọn Nguồn Đích';

  @override
  String get noSourcesAvailable => 'Không có nguồn nào có sẵn để di chuyển';

  @override
  String get checkSourceConfiguration =>
      'Vui lòng kiểm tra cấu hình nguồn của bạn';

  @override
  String get noAlternativeSources => 'Không có nguồn thay thế nào có sẵn';

  @override
  String get installMoreSources =>
      'Cài đặt nhiều nguồn hơn để cho phép di chuyển';

  @override
  String get errorLoadingSources => 'Lỗi tải nguồn';

  @override
  String get errorGettingMigrationSources => 'Không nhận được nguồn di chuyển';

  @override
  String get errorSearchingMangaInSource =>
      'Không thể tìm kiếm manga trong nguồn';

  @override
  String get errorFetchingSourceManga => 'Không lấy được manga nguồn';

  @override
  String get errorSourceMangaNotFound => 'Nguồn manga không tìm thấy';

  @override
  String get errorFetchingTargetManga => 'Không lấy được manga đích';

  @override
  String get errorTargetMangaNotFound => 'Không tìm thấy manga đích';

  @override
  String get searchManga => 'Tìm kiếm manga...';

  @override
  String get searchForManga => 'Tìm kiếm manga trong nguồn đích';

  @override
  String get enterSearchTerm => 'Nhập để tìm kiếm để tìm manga';

  @override
  String get noResultsFound => 'Không tìm thấy kết quả nào';

  @override
  String get tryDifferentSearch => 'Hãy thử từ khóa tìm kiếm khác';

  @override
  String get searchError => 'Lỗi tìm kiếm';

  @override
  String get importantNotice => 'Thông báo quan trọng';

  @override
  String get migrationWarning =>
      'Thao tác này sẽ di chuyển vĩnh viễn dữ liệu manga của bạn. Không thể hoàn tác hành động này.';

  @override
  String get deleteSourceWarning =>
      'Manga gốc sẽ bị xóa khỏi thư viện của bạn sau khi di chuyển.';

  @override
  String get confirmMigration => 'Xác nhận di chuyển';

  @override
  String get migrationConfirmationMessage =>
      'Bạn có chắc chắn muốn di chuyển manga này không? Hành động này không thể hoàn tác.';

  @override
  String get startMigration => 'Bắt đầu di chuyển';

  @override
  String get preparingMigration => 'Đang chuẩn bị di chuyển...';

  @override
  String get migrationCompleted => 'Quá trình di chuyển đã hoàn tất!';

  @override
  String get migrationSuccessMessage =>
      'Manga của bạn đã được di chuyển thành công sang nguồn mới.';

  @override
  String get migrationCancelledMessage =>
      'Quá trình di chuyển đã bị hủy. Không có thay đổi nào được thực hiện.';

  @override
  String get cancelMigration => 'Hủy bỏ di chuyển';

  @override
  String get cancelMigrationConfirmation =>
      'Bạn có chắc chắn muốn hủy quá trình di chuyển không? Hành động này không thể hoàn tác.';

  @override
  String get quickPresets => 'Cài đặt nhanh';

  @override
  String get quickMigration => 'Nhanh';

  @override
  String get fullMigration => 'Đầy đủ';

  @override
  String get customMigration => 'Tùy chỉnh';

  @override
  String get deleteSourceManga => 'Xóa Nguồn Manga';

  @override
  String get deleteSourceMangaDescription =>
      'Xóa manga gốc khỏi thư viện sau khi di chuyển';

  @override
  String get done => 'Xong';

  @override
  String get yes => 'Có';

  @override
  String get no => 'Không';

  @override
  String get from => 'Từ';

  @override
  String get to => 'Đến';

  @override
  String get source => 'Nguồn';

  @override
  String get migrationDetails => 'Chi tiết di chuyển';

  @override
  String get searchAllSources => 'Tìm kiếm tất cả các nguồn';

  @override
  String get searchingAllSources =>
      'Đang tìm kiếm trên tất cả các nguồn có sẵn...';

  @override
  String get noMatchingMangaFound =>
      'Không tìm thấy manga phù hợp trong bất kỳ nguồn nào';

  @override
  String get deleteSourceAfterMigration => 'Xóa manga nguồn sau khi di chuyển';

  @override
  String get reload => 'Tải lại';

  @override
  String get remove => 'Xóa';

  @override
  String get removeFromLibrary => 'Xóa khỏi Thư viện?';

  @override
  String get reset => 'Đặt lại';

  @override
  String get restore => 'Khôi phục';

  @override
  String get restoreBackupDescription => 'Khôi phục Suwayomi từ bản sao lưu';

  @override
  String get restoreBackupTitle => 'Khôi phục bản sao lưu';

  @override
  String get restored => 'Đã khôi phục bản sao lưu!';

  @override
  String get restoring => 'Khôi phục bản sao lưu';

  @override
  String get resume => 'Tiếp tục';

  @override
  String get retry => 'Thử lại';

  @override
  String get running => 'Đang chạy';

  @override
  String get save => 'Lưu';

  @override
  String get saveAsCBZArchive => 'Lưu bằng định dạng nén CBZ';

  @override
  String get scanlators => 'Nhóm dịch';

  @override
  String get search => 'Tìm kiếm';

  @override
  String get searchingForUpdates => 'Tìm kiếm thông tin cập nhật';

  @override
  String get selectInBetween => 'Chọn ở giữa';

  @override
  String get selectNext10 => 'Chọn 10 chương tiếp theo';

  @override
  String get selectUnread => 'Chọn Chưa đọc';

  @override
  String get server => 'Máy chủ';

  @override
  String get serverBindings => 'Ràng buộc máy chủ';

  @override
  String get serverPort => 'Cổng máy chủ';

  @override
  String get serverPortHintText => 'Cổng máy chủ';

  @override
  String get serverUrl => 'URL máy chủ';

  @override
  String get serverUrlHintText => 'URL máy chủ';

  @override
  String get serverVersion => 'Phiên bản máy chủ';

  @override
  String get settings => 'Cài đặt';

  @override
  String get skipUpdatingEntries => 'Bỏ qua cập nhật các mục';

  @override
  String get socksHost => 'Địa chỉ SOCKS';

  @override
  String get socksPassword => 'Mật khẩu SOCKS';

  @override
  String get socksPort => 'Cổng SOCKS';

  @override
  String get socksProxy => 'SOCKS Proxy';

  @override
  String get socksUserName => 'Tên người dùng SOCKS';

  @override
  String get socksVersion => 'Phiên bản SOCKS';

  @override
  String get sort => 'Sắp xếp';

  @override
  String get sourceTypeFilter => 'Bộ lọc';

  @override
  String get sourceTypeLatest => 'Mới nhất';

  @override
  String get sourceTypePopular => 'Phổ biến';

  @override
  String get sources => 'Nguồn';

  @override
  String get start => 'Bắt đầu';

  @override
  String get systemTrayIcon => 'Hiển thị biểu tượng trong khay hệ thống';

  @override
  String get thatHaventBeenStarted => 'Chưa bắt đầu đọc';

  @override
  String get themeModeDark => 'Tối';

  @override
  String get themeModeLight => 'Sáng';

  @override
  String get themeModeSystem => 'Hệ thống';

  @override
  String get today => 'Hôm nay';

  @override
  String get uninstall => 'Gỡ cài đặt';

  @override
  String get uninstalling => 'Gỡ cài đặt';

  @override
  String get unknownAuthor => 'Tác giả không xác định';

  @override
  String get unknownManga => 'Truyện tranh không xác định';

  @override
  String get unknownSource => 'Nguồn không xác định';

  @override
  String get unread => 'Chưa đọc';

  @override
  String get update => 'Cập nhật';

  @override
  String get updateCompleted => 'Cập nhật đã hoàn tất';

  @override
  String updateFailed(Object property) {
    return 'Không cập nhật được $property';
  }

  @override
  String get updates => 'Cập nhật';

  @override
  String get updatesSummary => 'Tóm tắt cập nhật';

  @override
  String get updating => 'Đang cập nhật';

  @override
  String get userName => 'Tên người dùng';

  @override
  String get validating => 'Xác thực';

  @override
  String versionAvailable(String app, String version) {
    return 'Đã có phiên bản $version cho $app!!';
  }

  @override
  String get webUI => 'Mở trong WEB';

  @override
  String get webView => 'Xem trên web';

  @override
  String get whatsNew => 'Có gì mới?';

  @override
  String get withCompletedStatus => 'Với trạng thái Đã hoàn thành';

  @override
  String get withUnreadChapter => 'Với chương chưa đọc';

  @override
  String get yesterday => 'Hôm qua';

  @override
  String get recentlyRead => 'Đọc gần đây';

  @override
  String get history => 'Lịch sử';

  @override
  String get searchHistory => 'Tìm kiếm lịch sử...';

  @override
  String get noHistoryFound => 'Không tìm thấy lịch sử đọc';

  @override
  String get startReadingToSeeHistory =>
      'Bắt đầu đọc truyện để xem lịch sử của bạn tại đây';

  @override
  String get noSearchResults => 'Không có kết quả tìm kiếm';

  @override
  String get tryDifferentSearchTerm => 'Hãy thử một từ khóa tìm kiếm khác';

  @override
  String get errorOccurred => 'Đã xảy ra lỗi';

  @override
  String get viewManga => 'Xem truyện';

  @override
  String get removeFromHistory => 'Xóa khỏi Lịch sử';

  @override
  String get removeFromHistoryConfirmation =>
      'Bạn có chắc chắn muốn xóa chương này khỏi lịch sử đọc của mình không?';

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
