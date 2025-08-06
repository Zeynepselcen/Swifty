// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'Swifty';

  @override
  String get mainScreenTitle => '갤러리 스와이프 정리';

  @override
  String get mainScreenSubtitle => '사진을 쉽게 관리하세요!';

  @override
  String get start => '시작';

  @override
  String get welcome => '환영합니다!';

  @override
  String get languageSelect => '언어';

  @override
  String get selectLanguage => '언어 선택';

  @override
  String get noAlbumsFound => '앨범을 찾을 수 없습니다.';

  @override
  String get noVideosFound => '비디오를 찾을 수 없습니다.';

  @override
  String get ok => '확인';

  @override
  String get cancel => '취소';

  @override
  String get cancelTitle => '취소';

  @override
  String cancelDesc(Object count) {
    return '모든 사진이 검토되었습니다. 나가면 $count장의 사진이 사라집니다. 처음부터 다시 시작해야 합니다. 나가시겠습니까?';
  }

  @override
  String get cancelSimpleDesc => '아직 모든 사진을 확인하지 않았습니다. 종료하시겠습니까?';

  @override
  String get pleaseSelectLanguage => '선호하는 언어를 선택하세요.';

  @override
  String get languageChangedTo => '언어가 변경되었습니다:';

  @override
  String get allVideosReviewed => '모든 비디오가 검토되었습니다';

  @override
  String get allPhotosReviewed => '모든 사진이 검토되었습니다';

  @override
  String get searchPhotos => '사진 검색';

  @override
  String get videos => '비디오';

  @override
  String get photos => '사진';

  @override
  String get size => '크기';

  @override
  String get date => 'date';

  @override
  String get name => 'name';

  @override
  String get largestSize => 'largest size';

  @override
  String get refresh => 'Refresh';

  @override
  String get recent => '최근';

  @override
  String get download => '다운로드';

  @override
  String remainingPhotos(Object count) {
    return '남은 사진: $count';
  }

  @override
  String get next => '다음';

  @override
  String get onboardingTitle1 => '환영합니다!';

  @override
  String get onboardingDesc1 =>
      '갤러리 클리너로 사진을 쉽게 관리하고, 불필요한 사진을 삭제하여 갤러리를 새롭게 하세요.';

  @override
  String get onboardingTitle2 => '간편한 사용법';

  @override
  String get onboardingDesc2 =>
      '오른쪽으로 스와이프하면 사진이 저장되고, 왼쪽으로 스와이프하면 삭제할 수 있습니다. 끝!';

  @override
  String get onboardingTitle3 => '개인정보 보호가 최우선';

  @override
  String get onboardingDesc3 =>
      '앱은 오직 사용자의 허락으로만 갤러리에 접근하며, 어떤 데이터도 공유하지 않습니다.';

  @override
  String get duplicatePhotos => '중복 사진';

  @override
  String get previewOfDuplicatePhotos => '중복 사진 미리보기';

  @override
  String get deleteAllDuplicates => '모든 중복 삭제';

  @override
  String get confirmDeletion => '삭제 확인';

  @override
  String get confirmDeleteAllDuplicates =>
      '모든 중복 사진을 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.';

  @override
  String get deleteAll => '모두 삭제';

  @override
  String get allDuplicatesDeleted => '모든 중복이 삭제되었습니다.';

  @override
  String get skipThisStep => '이 단계 건너뛰기';

  @override
  String get skip => '건너뛰기';

  @override
  String get duplicatePreviewInfo => '각 그룹의 첫 번째 사진만 남고, 나머지는 삭제됩니다.';

  @override
  String get analyzeGallery => '갤러리 분석';

  @override
  String get galleryAnalysisCompleted => '갤러리 분석 완료';

  @override
  String get gallerySlogan => '갤러리 클리너';

  @override
  String get darkTheme => '다크 테마';

  @override
  String get lightTheme => '라이트 테마';

  @override
  String exitReviewDialog(Object label, Object remaining) {
    return '모든 $label을(를) 확인하지 않고 나가려고 합니다. 남은: $remaining $label. 돌아가면 처음부터 다시 시작해야 합니다. 나가시겠습니까?';
  }

  @override
  String get duplicateCheckQuestion => '이 폴더에서 중복을 확인하시겠습니까?';

  @override
  String get duplicateCheckDescription => '중복 사진이 발견되면 삭제할 사진을 선택할 수 있습니다.';

  @override
  String get yesCheckDuplicates => '예, 확인';

  @override
  String get noDuplicatesFound => '이 폴더에서 중복 사진을 찾을 수 없습니다.';

  @override
  String get recentlyDeletedTitle => '최근 삭제됨';

  @override
  String recentlyDeletedMessage(Object count) {
    return '$count개 항목이 삭제되어 \"최근 삭제됨\" 앨범으로 이동되었습니다. 이 항목들은 30일 동안 거기에 유지되며 그 후 자동으로 영구 삭제됩니다.';
  }

  @override
  String get zoomHint => '확대하려면 핀치하세요';

  @override
  String get zoomHintDescription => '더 나은 보기를 위해 두 손가락으로 사진을 확대하고 축소할 수 있습니다';

  @override
  String get photoDetail => '사진 상세';

  @override
  String get undoTitle => '실행 취소';

  @override
  String undoMessage(Object count) {
    return '$count장의 사진을 실행 취소하시겠습니까?';
  }

  @override
  String get undoCancel => '취소';

  @override
  String get undoConfirm => '실행 취소';

  @override
  String get filePermanentlyDeleted => '파일이 영구적으로 삭제되어 실행 취소할 수 없습니다';

  @override
  String get lastPhotoUndone => '마지막 삭제된 사진이 실행 취소되었습니다';

  @override
  String get undoFeatureComingSoon => '실행 취소 기능이 곧 추가됩니다';

  @override
  String get recentlyDeletedFilesNotFound => 'No deleted files found';

  @override
  String get restoreFile => 'Restore';

  @override
  String get fileDetails => 'File Details';

  @override
  String get deletedAt => 'Deleted at';

  @override
  String get timeRemaining => 'Time remaining';

  @override
  String get close => 'Close';

  @override
  String get fileRestored => 'File restored';

  @override
  String get fileNotFound => 'File not found';

  @override
  String get restoreError => 'Restore error';

  @override
  String get galleryOptions => 'Gallery Options';

  @override
  String get androidGallery => 'Android Gallery';

  @override
  String get androidGalleryDesc => 'Open your phone\'s own gallery app';

  @override
  String get recentlyDeleted => 'Recently Deleted';

  @override
  String get recentlyDeletedDesc => 'Open Android\'s own trash';

  @override
  String get galleryAppNotFound =>
      'Gallery app could not be opened. You can open the gallery app manually.';

  @override
  String get trashNotFound =>
      'Trash could not be opened. You can go to DCIM/.trash folder from file manager manually.';

  @override
  String get restoreFiles => 'Restore Files';

  @override
  String get restoreFilesQuestion => 'Do you want to restore deleted files?';

  @override
  String get restoreAll => 'Restore All';

  @override
  String get noFilesToRestore => 'No files to restore';

  @override
  String get filesRestoredSuccessfully => 'Files restored successfully';

  @override
  String get exitConfirmation => 'Exit Confirmation';

  @override
  String exitWithoutReviewing(Object label, Object remaining) {
    return 'You are about to exit without reviewing all $label. Remaining: $remaining $label. If you go back, you\'ll have to start over. Do you want to exit?';
  }

  @override
  String get deleteAndExit => 'Delete and Exit';

  @override
  String get exitWithoutDeleting => 'Exit Without Deleting';

  @override
  String filesMovedToTrash(Object count) {
    return '$count files moved to \"Recently Deleted\" folder. You can restore them within 30 days from the \"Recently Deleted\" screen.';
  }

  @override
  String get restore => 'Restore';

  @override
  String get details => 'Details';

  @override
  String get originalPath => 'Original Path';

  @override
  String get trashPath => 'Trash Path';

  @override
  String get expiresAt => 'Expires at';

  @override
  String daysRemaining(Object days, Object hours) {
    return '$days days $hours hours remaining';
  }

  @override
  String hoursRemaining(Object hours) {
    return '$hours hours remaining';
  }

  @override
  String get expiringSoon => 'Expiring soon';

  @override
  String get androidTrashFolder => 'Android Trash Folder';

  @override
  String get androidTrashFolderDesc =>
      'Files moved to Android\'s own trash folder';

  @override
  String get appTrashFolder => 'App Trash Folder';

  @override
  String get appTrashFolderDesc =>
      'Files moved to app\'s internal trash folder';

  @override
  String get loading => 'Loading...';

  @override
  String get loadingPhotos => 'Loading photos...';

  @override
  String get loadingVideos => 'Loading videos...';

  @override
  String get loadingAlbums => 'Loading albums...';

  @override
  String get pleaseWait => 'Please wait';

  @override
  String get analyzingGallery => 'Analyzing gallery...';

  @override
  String get processingFiles => 'Processing files...';

  @override
  String get preparingFiles => 'Preparing files...';

  @override
  String get photoDeleted => 'Photo deleted';

  @override
  String get filesRestored => 'Files restored successfully';

  @override
  String get videoLoading => 'Loading video...';

  @override
  String get exitReviewDialogTitle => 'Exit Review Screen';

  @override
  String get manageAllFilesPermissionTitle => 'Manage All Files Permission';

  @override
  String get manageAllFilesPermissionDescription =>
      'Access to all your files is required.';

  @override
  String get goToSettings => 'Go to Settings';

  @override
  String get back => 'Back';

  @override
  String get undo => 'Undo';

  @override
  String get noPhotosFound => 'No photos found in this folder';

  @override
  String get permissionRequired => 'Permission Required';

  @override
  String get permissionRequiredDescription =>
      'Permission is required to access your gallery. Please enable it in your device settings.';

  @override
  String get noAlbumsFoundDescription =>
      'Gallery access permission granted but no photos or videos found.';
}
