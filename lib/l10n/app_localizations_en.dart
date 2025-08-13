// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Swifty';

  @override
  String get mainScreenTitle => 'Swipe to Clean Gallery';

  @override
  String get mainScreenSubtitle => 'Manage your photos easily!';

  @override
  String get start => 'Start';

  @override
  String get welcome => 'Welcome!';

  @override
  String get languageSelect => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get noAlbumsFound => 'No albums found.';

  @override
  String get noVideosFound => 'No videos found.';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get cancelTitle => 'Cancel';

  @override
  String cancelDesc(Object count) {
    return 'All photos reviewed. Leaving will lose $count photo(s). You will have to start over. Do you want to leave?';
  }

  @override
  String get cancelSimpleDesc =>
      'You haven\'t reviewed all photos yet. Do you want to exit?';

  @override
  String get pleaseSelectLanguage => 'Please select your preferred language.';

  @override
  String get languageChangedTo => 'Language changed to';

  @override
  String get allVideosReviewed => 'All videos reviewed';

  @override
  String get allPhotosReviewed => 'All photos reviewed';

  @override
  String get searchPhotos => 'Search photos';

  @override
  String get videos => 'Video';

  @override
  String get photos => 'Photo';

  @override
  String get size => 'size';

  @override
  String get date => 'Date';

  @override
  String get name => 'name';

  @override
  String photoCount(Object count) {
    return '$count photos';
  }

  @override
  String get largestSize => 'largest size';

  @override
  String get refresh => 'Refresh';

  @override
  String get folder => 'Folder';

  @override
  String get recent => 'Recent';

  @override
  String get download => 'Download';

  @override
  String remainingPhotos(Object count) {
    return 'Remaining photos: $count';
  }

  @override
  String get next => 'Next';

  @override
  String get onboardingTitle1 => 'Welcome!';

  @override
  String get onboardingDesc1 =>
      'Manage your photos easily with Gallery Cleaner, delete unnecessary ones and freshen up your gallery.';

  @override
  String get onboardingTitle2 => 'Easy to Use';

  @override
  String get onboardingDesc2 =>
      'Swipe right to save photos, swipe left to mark for deletion. That\'s all!';

  @override
  String get onboardingTitle3 => 'Privacy is Our Priority';

  @override
  String get onboardingDesc3 =>
      'The app only accesses your gallery with your permission and does not share any data.';

  @override
  String get duplicatePhotos => 'Duplicate Photos';

  @override
  String get previewOfDuplicatePhotos => 'Preview of duplicate photos';

  @override
  String get deleteAllDuplicates => 'Delete all duplicates';

  @override
  String get confirmDeletion => 'Confirm Deletion';

  @override
  String get confirmDeleteAllDuplicates =>
      'Are you sure you want to delete all duplicate photos? This action cannot be undone.';

  @override
  String get deleteAll => 'Delete All';

  @override
  String get allDuplicatesDeleted => 'All duplicates deleted.';

  @override
  String get skipThisStep => 'Skip this step';

  @override
  String get skip => 'Skip';

  @override
  String get duplicatePreviewInfo =>
      'The first photo in each group will be kept. All others will be deleted.';

  @override
  String get analyzeGallery => 'Analyze Gallery';

  @override
  String get galleryAnalysisCompleted => 'Gallery analysis completed';

  @override
  String get gallerySlogan => 'Gallery Cleaner';

  @override
  String get darkTheme => 'Dark Theme';

  @override
  String get lightTheme => 'Light Theme';

  @override
  String exitReviewDialog(Object label, Object remaining) {
    return 'You are about to exit without reviewing all $label. Remaining: $remaining $label. If you go back, you\'ll have to start over. Do you want to exit?';
  }

  @override
  String get duplicateCheckQuestion =>
      'Would you like to check for duplicates in this folder?';

  @override
  String get duplicateCheckDescription =>
      'If duplicate photos are found, you can choose which ones to delete.';

  @override
  String get yesCheckDuplicates => 'Yes, Check';

  @override
  String get noDuplicatesFound => 'No duplicate photos found in this folder.';

  @override
  String get recentlyDeletedTitle => 'Recently Deleted';

  @override
  String recentlyDeletedMessage(Object count) {
    return '$count items have been deleted and moved to the \"Recently Deleted\" album. These items will remain there for 30 days and then be permanently deleted automatically.';
  }

  @override
  String get zoomHint => 'Pinch to zoom';

  @override
  String get zoomHintDescription =>
      'Use two fingers to zoom in and out on photos for better viewing';

  @override
  String get photoDetail => 'Photo Detail';

  @override
  String get undoTitle => 'Undo';

  @override
  String undoMessage(Object count) {
    return 'Do you want to undo $count photo(s)?';
  }

  @override
  String get undoCancel => 'Cancel';

  @override
  String get undoConfirm => 'Undo';

  @override
  String get filePermanentlyDeleted =>
      'File is permanently deleted, cannot be undone';

  @override
  String get lastPhotoUndone => 'Last deleted photo undone';

  @override
  String get undoFeatureComingSoon => 'Undo feature coming soon';

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

  @override
  String get onboardingTitleDetail => 'Detailed Review';

  @override
  String get onboardingDescDetail =>
      'Tap on photos to zoom in and examine details. Easy access with the zoom icon!';

  @override
  String get aboutTitle => 'About the App';

  @override
  String get aboutDescription =>
      'Manage your photos easily with Swifty Gallery Cleaner!';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get themeDescription => 'Change appearance';

  @override
  String get aboutTakeTour =>
      'Take a tour to learn more about the app features';

  @override
  String get aboutTakeTourButton => 'Start Tour';

  @override
  String get videoGallery => 'Video Gallery';

  @override
  String get photoGallery => 'Photo Gallery';

  @override
  String get swipeToDelete => 'Swipe to delete';

  @override
  String get deleteConfirmation => 'Delete Confirmation';

  @override
  String get delete => 'Delete';

  @override
  String get allDeletedFilesCleared => 'All deleted files cleared';

  @override
  String get clearError => 'Clear error';

  @override
  String get fileRestoring => 'is being restored';

  @override
  String get fileRestoredToFolder => 'restored to folder';

  @override
  String get folderSuffix => '';

  @override
  String get fileRestoredToDcim => 'restored to DCIM';

  @override
  String get clearAll => 'Clear All';

  @override
  String get january => 'January';

  @override
  String get february => 'February';

  @override
  String get march => 'March';

  @override
  String get april => 'April';

  @override
  String get may => 'May';

  @override
  String get june => 'June';

  @override
  String get july => 'July';

  @override
  String get august => 'August';

  @override
  String get september => 'September';

  @override
  String get october => 'October';

  @override
  String get november => 'November';

  @override
  String get december => 'December';

  @override
  String filesMovedToRecentlyDeleted(Object count) {
    return '$count files moved to \"Recently Deleted\" folder. You can restore them within 30 days.';
  }

  @override
  String filesSuccessfullyDeleted(Object count) {
    return '$count files successfully deleted';
  }

  @override
  String markedForDeletion(Object count) {
    return '$count files marked for deletion!';
  }

  @override
  String notAllPhotosReviewed(Object type) {
    return 'You haven\'t reviewed all $type yet.';
  }

  @override
  String noPhotosFoundDescription(Object type) {
    return 'Gallery access permission granted but no $type found.';
  }

  @override
  String get pleaseWaitThisMayTakeTime =>
      'Please wait, this process may take some time';

  @override
  String get remaining => 'REMAINING';

  @override
  String get spaceSaved => 'SPACE SAVED';

  @override
  String get deleteAllButton => 'Delete All';

  @override
  String get completed => 'Completed!';
}
