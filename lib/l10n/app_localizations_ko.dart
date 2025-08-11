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
  String get date => '날짜';

  @override
  String get name => '이름';

  @override
  String photoCount(Object count) {
    return '$count장 사진';
  }

  @override
  String get largestSize => '가장 큰 크기';

  @override
  String get refresh => '새로고침';

  @override
  String get folder => '폴더';

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
  String get recentlyDeletedFilesNotFound => '삭제된 파일을 찾을 수 없습니다';

  @override
  String get restoreFile => '복원';

  @override
  String get fileDetails => '파일 세부사항';

  @override
  String get deletedAt => '삭제됨';

  @override
  String get timeRemaining => '남은 시간';

  @override
  String get close => '닫기';

  @override
  String get fileRestored => '파일이 복원되었습니다';

  @override
  String get fileNotFound => '파일을 찾을 수 없습니다';

  @override
  String get restoreError => '복원 오류';

  @override
  String get galleryOptions => '갤러리 옵션';

  @override
  String get androidGallery => 'Android 갤러리';

  @override
  String get androidGalleryDesc => '휴대폰의 자체 갤러리 앱 열기';

  @override
  String get recentlyDeleted => '최근 삭제됨';

  @override
  String get recentlyDeletedDesc => 'Android의 자체 휴지통 열기';

  @override
  String get galleryAppNotFound => '갤러리 앱을 열 수 없습니다. 수동으로 갤러리 앱을 열 수 있습니다.';

  @override
  String get trashNotFound =>
      '휴지통을 열 수 없습니다. 파일 관리자에서 DCIM/.trash 폴더로 수동으로 이동할 수 있습니다.';

  @override
  String get restoreFiles => '파일 복원';

  @override
  String get restoreFilesQuestion => '삭제된 파일을 복원하시겠습니까?';

  @override
  String get restoreAll => '모두 복원';

  @override
  String get noFilesToRestore => '복원할 파일이 없습니다';

  @override
  String get filesRestoredSuccessfully => '파일이 성공적으로 복원되었습니다';

  @override
  String get exitConfirmation => '종료 확인';

  @override
  String exitWithoutReviewing(Object label, Object remaining) {
    return '모든 $label을(를) 확인하지 않고 종료하려고 합니다. 남은: $remaining $label. 돌아가면 처음부터 다시 시작해야 합니다. 종료하시겠습니까?';
  }

  @override
  String get deleteAndExit => '삭제하고 종료';

  @override
  String get exitWithoutDeleting => '삭제하지 않고 종료';

  @override
  String filesMovedToTrash(Object count) {
    return '$count개 파일이 \"최근 삭제됨\" 폴더로 이동되었습니다. 30일 동안 \"최근 삭제됨\" 화면에서 복원할 수 있습니다.';
  }

  @override
  String get restore => '복원';

  @override
  String get details => '세부사항';

  @override
  String get originalPath => '원본 경로';

  @override
  String get trashPath => '휴지통 경로';

  @override
  String get expiresAt => '만료됨';

  @override
  String daysRemaining(Object days, Object hours) {
    return '$days일 $hours시간 남음';
  }

  @override
  String hoursRemaining(Object hours) {
    return '$hours시간 남음';
  }

  @override
  String get expiringSoon => '곧 만료됨';

  @override
  String get androidTrashFolder => 'Android 휴지통';

  @override
  String get androidTrashFolderDesc => '파일이 Android의 자체 휴지통으로 이동됨';

  @override
  String get appTrashFolder => '앱 휴지통';

  @override
  String get appTrashFolderDesc => '파일이 앱의 내부 휴지통으로 이동됨';

  @override
  String get loading => '로딩 중...';

  @override
  String get loadingPhotos => '사진 로딩 중...';

  @override
  String get loadingVideos => '비디오 로딩 중...';

  @override
  String get loadingAlbums => '앨범 로딩 중...';

  @override
  String get pleaseWait => '잠시 기다려주세요';

  @override
  String get analyzingGallery => '갤러리 분석 중...';

  @override
  String get processingFiles => '파일 처리 중...';

  @override
  String get preparingFiles => '파일 준비 중...';

  @override
  String get photoDeleted => '사진이 삭제되었습니다';

  @override
  String get filesRestored => '파일이 성공적으로 복원되었습니다';

  @override
  String get videoLoading => '비디오 로딩 중...';

  @override
  String get exitReviewDialogTitle => '검토 화면 종료';

  @override
  String get manageAllFilesPermissionTitle => '모든 파일 관리 권한';

  @override
  String get manageAllFilesPermissionDescription => '모든 파일에 대한 접근이 필요합니다.';

  @override
  String get goToSettings => '설정으로 이동';

  @override
  String get back => '뒤로';

  @override
  String get undo => '실행 취소';

  @override
  String get noPhotosFound => '이 폴더에서 사진을 찾을 수 없습니다';

  @override
  String get permissionRequired => '권한 필요';

  @override
  String get permissionRequiredDescription =>
      '갤러리에 접근하려면 권한이 필요합니다. 기기 설정에서 활성화해주세요.';

  @override
  String get noAlbumsFoundDescription =>
      '갤러리 접근 권한이 허용되었지만 사진이나 비디오를 찾을 수 없습니다.';

  @override
  String get onboardingTitleDetail => '상세 검토';

  @override
  String get onboardingDescDetail =>
      '사진을 눌러 확대하고 세부 정보를 확인하세요. 확대 아이콘으로 쉽게 접근할 수 있습니다!';

  @override
  String get aboutTitle => '앱 정보';

  @override
  String get aboutDescription => 'Swifty 갤러리 클리너로 사진을 쉽게 관리하세요!';

  @override
  String get settings => '설정';

  @override
  String get language => '언어';

  @override
  String get theme => '테마';

  @override
  String get themeDescription => '외관 변경';

  @override
  String get aboutTakeTour => '앱 기능에 대해 더 자세히 알아보려면 투어를 시작하세요';

  @override
  String get aboutTakeTourButton => '투어 시작';

  @override
  String get videoGallery => '비디오 갤러리';

  @override
  String get photoGallery => '사진 갤러리';

  @override
  String get swipeToDelete => '스와이프해서 삭제';
}
