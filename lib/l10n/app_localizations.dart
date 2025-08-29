import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
    Locale('en'),
    Locale('es'),
    Locale('ko'),
    Locale('tr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Swifty'**
  String get appTitle;

  /// No description provided for @mainScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Swipe to Clean Gallery'**
  String get mainScreenTitle;

  /// No description provided for @mainScreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your photos easily!'**
  String get mainScreenSubtitle;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get welcome;

  /// No description provided for @languageSelect.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSelect;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @noAlbumsFound.
  ///
  /// In en, this message translates to:
  /// **'No albums found.'**
  String get noAlbumsFound;

  /// No description provided for @noVideosFound.
  ///
  /// In en, this message translates to:
  /// **'No videos found.'**
  String get noVideosFound;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @cancelTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelTitle;

  /// No description provided for @cancelDesc.
  ///
  /// In en, this message translates to:
  /// **'All photos reviewed. Leaving will lose {count} photo(s). You will have to start over. Do you want to leave?'**
  String cancelDesc(Object count);

  /// No description provided for @cancelSimpleDesc.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t reviewed all photos yet. Do you want to exit?'**
  String get cancelSimpleDesc;

  /// No description provided for @pleaseSelectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Please select your preferred language.'**
  String get pleaseSelectLanguage;

  /// No description provided for @languageChangedTo.
  ///
  /// In en, this message translates to:
  /// **'Language changed to'**
  String get languageChangedTo;

  /// No description provided for @allVideosReviewed.
  ///
  /// In en, this message translates to:
  /// **'All videos reviewed'**
  String get allVideosReviewed;

  /// No description provided for @allPhotosReviewed.
  ///
  /// In en, this message translates to:
  /// **'All photos reviewed'**
  String get allPhotosReviewed;

  /// No description provided for @searchPhotos.
  ///
  /// In en, this message translates to:
  /// **'Search photos'**
  String get searchPhotos;

  /// No description provided for @videos.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get videos;

  /// No description provided for @photos.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photos;

  /// No description provided for @size.
  ///
  /// In en, this message translates to:
  /// **'size'**
  String get size;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'name'**
  String get name;

  /// No description provided for @photoCount.
  ///
  /// In en, this message translates to:
  /// **'{count} photos'**
  String photoCount(Object count);

  /// No description provided for @largestSize.
  ///
  /// In en, this message translates to:
  /// **'largest size'**
  String get largestSize;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @folder.
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get folder;

  /// No description provided for @recent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recent;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @remainingPhotos.
  ///
  /// In en, this message translates to:
  /// **'Remaining photos: {count}'**
  String remainingPhotos(Object count);

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In en, this message translates to:
  /// **'Manage your photos easily with Gallery Cleaner, delete unnecessary ones and freshen up your gallery.'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Easy to Use'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In en, this message translates to:
  /// **'Swipe right to save photos, swipe left to mark for deletion. That\'s all!'**
  String get onboardingDesc2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Privacy is Our Priority'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDesc3.
  ///
  /// In en, this message translates to:
  /// **'The app only accesses your gallery with your permission and does not share any data.'**
  String get onboardingDesc3;

  /// No description provided for @duplicatePhotos.
  ///
  /// In en, this message translates to:
  /// **'Duplicate Photos'**
  String get duplicatePhotos;

  /// No description provided for @previewOfDuplicatePhotos.
  ///
  /// In en, this message translates to:
  /// **'Preview of duplicate photos'**
  String get previewOfDuplicatePhotos;

  /// No description provided for @deleteAllDuplicates.
  ///
  /// In en, this message translates to:
  /// **'Delete all duplicates'**
  String get deleteAllDuplicates;

  /// No description provided for @confirmDeletion.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get confirmDeletion;

  /// No description provided for @confirmDeleteAllDuplicates.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all duplicate photos? This action cannot be undone.'**
  String get confirmDeleteAllDuplicates;

  /// No description provided for @deleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete All'**
  String get deleteAll;

  /// No description provided for @allDuplicatesDeleted.
  ///
  /// In en, this message translates to:
  /// **'All duplicates deleted.'**
  String get allDuplicatesDeleted;

  /// No description provided for @skipThisStep.
  ///
  /// In en, this message translates to:
  /// **'Skip this step'**
  String get skipThisStep;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @duplicatePreviewInfo.
  ///
  /// In en, this message translates to:
  /// **'The first photo in each group will be kept. All others will be deleted.'**
  String get duplicatePreviewInfo;

  /// No description provided for @analyzeGallery.
  ///
  /// In en, this message translates to:
  /// **'Analyze Gallery'**
  String get analyzeGallery;

  /// No description provided for @galleryAnalysisCompleted.
  ///
  /// In en, this message translates to:
  /// **'Gallery analysis completed'**
  String get galleryAnalysisCompleted;

  /// No description provided for @gallerySlogan.
  ///
  /// In en, this message translates to:
  /// **'Gallery Cleaner'**
  String get gallerySlogan;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get darkTheme;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light Theme'**
  String get lightTheme;

  /// No description provided for @exitReviewDialog.
  ///
  /// In en, this message translates to:
  /// **'You are about to exit without reviewing all {label}. Remaining: {remaining} {label}. If you go back, you\'ll have to start over. Do you want to exit?'**
  String exitReviewDialog(Object label, Object remaining);

  /// No description provided for @duplicateCheckQuestion.
  ///
  /// In en, this message translates to:
  /// **'Would you like to check for duplicates in this folder?'**
  String get duplicateCheckQuestion;

  /// No description provided for @duplicateCheckDescription.
  ///
  /// In en, this message translates to:
  /// **'If duplicate photos are found, you can choose which ones to delete.'**
  String get duplicateCheckDescription;

  /// No description provided for @yesCheckDuplicates.
  ///
  /// In en, this message translates to:
  /// **'Yes, Check'**
  String get yesCheckDuplicates;

  /// No description provided for @noDuplicatesFound.
  ///
  /// In en, this message translates to:
  /// **'No duplicate photos found in this folder.'**
  String get noDuplicatesFound;

  /// No description provided for @recentlyDeletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Recently Deleted'**
  String get recentlyDeletedTitle;

  /// No description provided for @recentlyDeletedMessage.
  ///
  /// In en, this message translates to:
  /// **'{count} items have been deleted and moved to the \"Recently Deleted\" album. These items will remain there for 30 days and then be permanently deleted automatically.'**
  String recentlyDeletedMessage(Object count);

  /// No description provided for @zoomHint.
  ///
  /// In en, this message translates to:
  /// **'Pinch to zoom'**
  String get zoomHint;

  /// No description provided for @zoomHintDescription.
  ///
  /// In en, this message translates to:
  /// **'Use two fingers to zoom in and out on photos for better viewing'**
  String get zoomHintDescription;

  /// No description provided for @photoDetail.
  ///
  /// In en, this message translates to:
  /// **'Photo Detail'**
  String get photoDetail;

  /// No description provided for @undoTitle.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undoTitle;

  /// No description provided for @undoMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you want to undo {count} photo(s)?'**
  String undoMessage(Object count);

  /// No description provided for @undoCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get undoCancel;

  /// No description provided for @undoConfirm.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undoConfirm;

  /// No description provided for @filePermanentlyDeleted.
  ///
  /// In en, this message translates to:
  /// **'File is permanently deleted, cannot be undone'**
  String get filePermanentlyDeleted;

  /// No description provided for @lastPhotoUndone.
  ///
  /// In en, this message translates to:
  /// **'Last deleted photo undone'**
  String get lastPhotoUndone;

  /// No description provided for @undoFeatureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Undo feature coming soon'**
  String get undoFeatureComingSoon;

  /// No description provided for @recentlyDeletedFilesNotFound.
  ///
  /// In en, this message translates to:
  /// **'No deleted files found'**
  String get recentlyDeletedFilesNotFound;

  /// No description provided for @restoreFile.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restoreFile;

  /// No description provided for @fileDetails.
  ///
  /// In en, this message translates to:
  /// **'File Details'**
  String get fileDetails;

  /// No description provided for @deletedAt.
  ///
  /// In en, this message translates to:
  /// **'Deleted at'**
  String get deletedAt;

  /// No description provided for @timeRemaining.
  ///
  /// In en, this message translates to:
  /// **'Time remaining'**
  String get timeRemaining;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @fileRestored.
  ///
  /// In en, this message translates to:
  /// **'File restored'**
  String get fileRestored;

  /// No description provided for @fileNotFound.
  ///
  /// In en, this message translates to:
  /// **'File not found'**
  String get fileNotFound;

  /// No description provided for @restoreError.
  ///
  /// In en, this message translates to:
  /// **'Restore error'**
  String get restoreError;

  /// No description provided for @galleryOptions.
  ///
  /// In en, this message translates to:
  /// **'Gallery Options'**
  String get galleryOptions;

  /// No description provided for @androidGallery.
  ///
  /// In en, this message translates to:
  /// **'Android Gallery'**
  String get androidGallery;

  /// No description provided for @androidGalleryDesc.
  ///
  /// In en, this message translates to:
  /// **'Open your phone\'s own gallery app'**
  String get androidGalleryDesc;

  /// No description provided for @recentlyDeleted.
  ///
  /// In en, this message translates to:
  /// **'Recently Deleted'**
  String get recentlyDeleted;

  /// No description provided for @recentlyDeletedDesc.
  ///
  /// In en, this message translates to:
  /// **'Open Android\'s own trash'**
  String get recentlyDeletedDesc;

  /// No description provided for @galleryAppNotFound.
  ///
  /// In en, this message translates to:
  /// **'Gallery app could not be opened. You can open the gallery app manually.'**
  String get galleryAppNotFound;

  /// No description provided for @trashNotFound.
  ///
  /// In en, this message translates to:
  /// **'Trash could not be opened. You can go to DCIM/.trash folder from file manager manually.'**
  String get trashNotFound;

  /// No description provided for @restoreFiles.
  ///
  /// In en, this message translates to:
  /// **'Restore Files'**
  String get restoreFiles;

  /// No description provided for @restoreFilesQuestion.
  ///
  /// In en, this message translates to:
  /// **'Do you want to restore deleted files?'**
  String get restoreFilesQuestion;

  /// No description provided for @restoreAll.
  ///
  /// In en, this message translates to:
  /// **'Restore All'**
  String get restoreAll;

  /// No description provided for @noFilesToRestore.
  ///
  /// In en, this message translates to:
  /// **'No files to restore'**
  String get noFilesToRestore;

  /// No description provided for @filesRestoredSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Files restored successfully'**
  String get filesRestoredSuccessfully;

  /// No description provided for @exitConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Exit Confirmation'**
  String get exitConfirmation;

  /// No description provided for @exitWithoutReviewing.
  ///
  /// In en, this message translates to:
  /// **'You are about to exit without reviewing all {label}. Remaining: {remaining} {label}. If you go back, you\'ll have to start over. Do you want to exit?'**
  String exitWithoutReviewing(Object label, Object remaining);

  /// No description provided for @deleteAndExit.
  ///
  /// In en, this message translates to:
  /// **'Delete and Exit'**
  String get deleteAndExit;

  /// No description provided for @exitWithoutDeleting.
  ///
  /// In en, this message translates to:
  /// **'Exit Without Deleting'**
  String get exitWithoutDeleting;

  /// No description provided for @filesMovedToTrash.
  ///
  /// In en, this message translates to:
  /// **'{count} files moved to \"Recently Deleted\" folder. You can restore them within 30 days from the \"Recently Deleted\" screen.'**
  String filesMovedToTrash(Object count);

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @originalPath.
  ///
  /// In en, this message translates to:
  /// **'Original Path'**
  String get originalPath;

  /// No description provided for @trashPath.
  ///
  /// In en, this message translates to:
  /// **'Trash Path'**
  String get trashPath;

  /// No description provided for @expiresAt.
  ///
  /// In en, this message translates to:
  /// **'Expires at'**
  String get expiresAt;

  /// No description provided for @daysRemaining.
  ///
  /// In en, this message translates to:
  /// **'{days} days {hours} hours remaining'**
  String daysRemaining(Object days, Object hours);

  /// No description provided for @hoursRemaining.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours remaining'**
  String hoursRemaining(Object hours);

  /// No description provided for @expiringSoon.
  ///
  /// In en, this message translates to:
  /// **'Expiring soon'**
  String get expiringSoon;

  /// No description provided for @androidTrashFolder.
  ///
  /// In en, this message translates to:
  /// **'Android Trash Folder'**
  String get androidTrashFolder;

  /// No description provided for @androidTrashFolderDesc.
  ///
  /// In en, this message translates to:
  /// **'Files moved to Android\'s own trash folder'**
  String get androidTrashFolderDesc;

  /// No description provided for @appTrashFolder.
  ///
  /// In en, this message translates to:
  /// **'App Trash Folder'**
  String get appTrashFolder;

  /// No description provided for @appTrashFolderDesc.
  ///
  /// In en, this message translates to:
  /// **'Files moved to app\'s internal trash folder'**
  String get appTrashFolderDesc;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @loadingPhotos.
  ///
  /// In en, this message translates to:
  /// **'Loading photos...'**
  String get loadingPhotos;

  /// No description provided for @loadingVideos.
  ///
  /// In en, this message translates to:
  /// **'Loading videos...'**
  String get loadingVideos;

  /// No description provided for @loadingAlbums.
  ///
  /// In en, this message translates to:
  /// **'Loading albums...'**
  String get loadingAlbums;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait'**
  String get pleaseWait;

  /// No description provided for @analyzingGallery.
  ///
  /// In en, this message translates to:
  /// **'Analyzing gallery...'**
  String get analyzingGallery;

  /// No description provided for @processingFiles.
  ///
  /// In en, this message translates to:
  /// **'Processing files...'**
  String get processingFiles;

  /// No description provided for @preparingFiles.
  ///
  /// In en, this message translates to:
  /// **'Preparing files...'**
  String get preparingFiles;

  /// No description provided for @photoDeleted.
  ///
  /// In en, this message translates to:
  /// **'Photo deleted'**
  String get photoDeleted;

  /// No description provided for @filesRestored.
  ///
  /// In en, this message translates to:
  /// **'Files restored successfully'**
  String get filesRestored;

  /// No description provided for @videoLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading video...'**
  String get videoLoading;

  /// No description provided for @exitReviewDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Exit Review Screen'**
  String get exitReviewDialogTitle;

  /// No description provided for @manageAllFilesPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage All Files Permission'**
  String get manageAllFilesPermissionTitle;

  /// No description provided for @manageAllFilesPermissionDescription.
  ///
  /// In en, this message translates to:
  /// **'Access to all your files is required.'**
  String get manageAllFilesPermissionDescription;

  /// No description provided for @goToSettings.
  ///
  /// In en, this message translates to:
  /// **'Go to Settings'**
  String get goToSettings;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @noPhotosFound.
  ///
  /// In en, this message translates to:
  /// **'No photos found in this folder'**
  String get noPhotosFound;

  /// No description provided for @permissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Permission Required'**
  String get permissionRequired;

  /// No description provided for @permissionRequiredDescription.
  ///
  /// In en, this message translates to:
  /// **'Permission is required to access your gallery. Please enable it in your device settings.'**
  String get permissionRequiredDescription;

  /// No description provided for @noAlbumsFoundDescription.
  ///
  /// In en, this message translates to:
  /// **'Gallery access permission granted but no photos or videos found.'**
  String get noAlbumsFoundDescription;

  /// No description provided for @onboardingTitleDetail.
  ///
  /// In en, this message translates to:
  /// **'Detailed Review'**
  String get onboardingTitleDetail;

  /// No description provided for @onboardingDescDetail.
  ///
  /// In en, this message translates to:
  /// **'Tap on photos to zoom in and examine details. Easy access with the zoom icon!'**
  String get onboardingDescDetail;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About the App'**
  String get aboutTitle;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage your photos easily with Swifty Gallery Cleaner!'**
  String get aboutDescription;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeDescription.
  ///
  /// In en, this message translates to:
  /// **'Change appearance'**
  String get themeDescription;

  /// No description provided for @aboutTakeTour.
  ///
  /// In en, this message translates to:
  /// **'Start the tour to learn app features in detail'**
  String get aboutTakeTour;

  /// No description provided for @aboutTakeTourButton.
  ///
  /// In en, this message translates to:
  /// **'Features Tour'**
  String get aboutTakeTourButton;

  /// No description provided for @videoGallery.
  ///
  /// In en, this message translates to:
  /// **'Video Gallery'**
  String get videoGallery;

  /// No description provided for @photoGallery.
  ///
  /// In en, this message translates to:
  /// **'Photo Gallery'**
  String get photoGallery;

  /// No description provided for @swipeToDelete.
  ///
  /// In en, this message translates to:
  /// **'Swipe to delete'**
  String get swipeToDelete;

  /// No description provided for @deleteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Delete Confirmation'**
  String get deleteConfirmation;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @allDeletedFilesCleared.
  ///
  /// In en, this message translates to:
  /// **'All deleted files cleared'**
  String get allDeletedFilesCleared;

  /// No description provided for @clearError.
  ///
  /// In en, this message translates to:
  /// **'Clear error'**
  String get clearError;

  /// No description provided for @fileRestoring.
  ///
  /// In en, this message translates to:
  /// **'is being restored'**
  String get fileRestoring;

  /// No description provided for @fileRestoredToFolder.
  ///
  /// In en, this message translates to:
  /// **'restored to folder'**
  String get fileRestoredToFolder;

  /// No description provided for @folderSuffix.
  ///
  /// In en, this message translates to:
  /// **''**
  String get folderSuffix;

  /// No description provided for @fileRestoredToDcim.
  ///
  /// In en, this message translates to:
  /// **'restored to DCIM'**
  String get fileRestoredToDcim;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @january.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get january;

  /// No description provided for @february.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get february;

  /// No description provided for @march.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get march;

  /// No description provided for @april.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get april;

  /// No description provided for @may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// No description provided for @june.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get june;

  /// No description provided for @july.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get july;

  /// No description provided for @august.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get august;

  /// No description provided for @september.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get september;

  /// No description provided for @october.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get october;

  /// No description provided for @november.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get november;

  /// No description provided for @december.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get december;

  /// No description provided for @filesMovedToRecentlyDeleted.
  ///
  /// In en, this message translates to:
  /// **'{count} files moved to \"Recently Deleted\" folder. You can restore them within 30 days.'**
  String filesMovedToRecentlyDeleted(Object count);

  /// No description provided for @filesSuccessfullyDeleted.
  ///
  /// In en, this message translates to:
  /// **'{count} files successfully deleted'**
  String filesSuccessfullyDeleted(Object count);

  /// No description provided for @markedForDeletion.
  ///
  /// In en, this message translates to:
  /// **'{count} files marked for deletion!'**
  String markedForDeletion(Object count);

  /// No description provided for @notAllPhotosReviewed.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t reviewed all {type} yet.'**
  String notAllPhotosReviewed(Object type);

  /// No description provided for @noPhotosFoundDescription.
  ///
  /// In en, this message translates to:
  /// **'Gallery access permission granted but no {type} found.'**
  String noPhotosFoundDescription(Object type);

  /// No description provided for @pleaseWaitThisMayTakeTime.
  ///
  /// In en, this message translates to:
  /// **'Please wait, this process may take some time'**
  String get pleaseWaitThisMayTakeTime;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'REMAINING'**
  String get remaining;

  /// No description provided for @spaceSaved.
  ///
  /// In en, this message translates to:
  /// **'SPACE SAVED'**
  String get spaceSaved;

  /// No description provided for @deleteAllButton.
  ///
  /// In en, this message translates to:
  /// **'Delete All'**
  String get deleteAllButton;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed!'**
  String get completed;

  /// No description provided for @loadingFolder.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingFolder;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'ko', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'ko':
      return AppLocalizationsKo();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
