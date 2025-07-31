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
  String get videos => 'Videos';

  @override
  String get photos => 'Photos';

  @override
  String get size => 'size';

  @override
  String get date => 'date';

  @override
  String get name => 'name';

  @override
  String get largestSize => 'largest size';

  @override
  String get refresh => 'Refresh';

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
  String get gallerySlogan => 'Swifty: Clean Your Gallery';

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
}
