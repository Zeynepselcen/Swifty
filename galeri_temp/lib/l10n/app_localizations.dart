import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In en, this message translates to:
  /// **'With Gallery Cleaner, easily manage your photos, delete unnecessary ones, and refresh your gallery.'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Easy to Use'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In en, this message translates to:
  /// **'Swipe right to keep, swipe left to mark for deletion. That\'s it!'**
  String get onboardingDesc2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Privacy First'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDesc3.
  ///
  /// In en, this message translates to:
  /// **'The app only accesses your gallery with your permission and never shares your data.'**
  String get onboardingDesc3;

  /// No description provided for @selectAlbum.
  ///
  /// In en, this message translates to:
  /// **'Select Album'**
  String get selectAlbum;

  /// No description provided for @selectAlbumDesc.
  ///
  /// In en, this message translates to:
  /// **'You can start cleaning by selecting a folder.'**
  String get selectAlbumDesc;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by:'**
  String get sortBy;

  /// No description provided for @sortBySize.
  ///
  /// In en, this message translates to:
  /// **'By size'**
  String get sortBySize;

  /// No description provided for @sortByDate.
  ///
  /// In en, this message translates to:
  /// **'By date'**
  String get sortByDate;

  /// No description provided for @sortByName.
  ///
  /// In en, this message translates to:
  /// **'By name'**
  String get sortByName;

  /// No description provided for @random15Folders.
  ///
  /// In en, this message translates to:
  /// **'Random 15 Folders'**
  String get random15Folders;

  /// No description provided for @random15FoldersDesc.
  ///
  /// In en, this message translates to:
  /// **'Random photos from 15 different folders'**
  String get random15FoldersDesc;

  /// No description provided for @noAlbumsFound.
  ///
  /// In en, this message translates to:
  /// **'No photo albums found.'**
  String get noAlbumsFound;

  /// No description provided for @remainingPhotos.
  ///
  /// In en, this message translates to:
  /// **'Remaining photos: {count}'**
  String remainingPhotos(Object count);

  /// No description provided for @allPhotosReviewed.
  ///
  /// In en, this message translates to:
  /// **'All photos reviewed!'**
  String get allPhotosReviewed;

  /// No description provided for @allVideosReviewed.
  ///
  /// In en, this message translates to:
  /// **'All videos reviewed!'**
  String get allVideosReviewed;

  /// No description provided for @deletePhotosDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Photos'**
  String get deletePhotosDialogTitle;

  /// No description provided for @deletePhotosDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete {count} photos?'**
  String deletePhotosDialogContent(Object count);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @deleteCompleted.
  ///
  /// In en, this message translates to:
  /// **'{count} photos deleted.'**
  String deleteCompleted(Object count);

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @languageSelect.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get languageSelect;

  /// No description provided for @permissionRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Permission Required'**
  String get permissionRequiredTitle;

  /// No description provided for @permissionRequiredContent.
  ///
  /// In en, this message translates to:
  /// **'You must grant gallery access permission to view albums.'**
  String get permissionRequiredContent;

  /// No description provided for @photo.
  ///
  /// In en, this message translates to:
  /// **'photo'**
  String get photo;

  /// No description provided for @video.
  ///
  /// In en, this message translates to:
  /// **'video'**
  String get video;

  /// No description provided for @analysisInProgress.
  ///
  /// In en, this message translates to:
  /// **'Analyzing gallery...'**
  String get analysisInProgress;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search in photos (flower, tree, man, woman)'**
  String get searchHint;

  /// No description provided for @photosTab.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photosTab;

  /// No description provided for @videosTab.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get videosTab;

  /// No description provided for @byMonth.
  ///
  /// In en, this message translates to:
  /// **'By Month'**
  String get byMonth;

  /// No description provided for @sortByFilesize.
  ///
  /// In en, this message translates to:
  /// **'By largest size'**
  String get sortByFilesize;

  /// No description provided for @deleteCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Completed'**
  String get deleteCompletedTitle;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @languageChangeDesc.
  ///
  /// In en, this message translates to:
  /// **'The app language will be changed.'**
  String get languageChangeDesc;

  /// No description provided for @languageChangedSnackBar.
  ///
  /// In en, this message translates to:
  /// **'Language changed.'**
  String get languageChangedSnackBar;

  /// No description provided for @analysisStarting.
  ///
  /// In en, this message translates to:
  /// **'Gallery analysis starting...'**
  String get analysisStarting;

  /// No description provided for @analysisStartingTitle.
  ///
  /// In en, this message translates to:
  /// **'Gallery Analysis'**
  String get analysisStartingTitle;

  /// No description provided for @analysisStartingContent.
  ///
  /// In en, this message translates to:
  /// **'Analysis starting...'**
  String get analysisStartingContent;

  /// No description provided for @analysisInProgressLong.
  ///
  /// In en, this message translates to:
  /// **'Photos are being analyzed, please wait...'**
  String get analysisInProgressLong;

  /// No description provided for @analysisCompleted.
  ///
  /// In en, this message translates to:
  /// **'Gallery analysis completed'**
  String get analysisCompleted;

  /// No description provided for @refreshAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Refresh Analysis'**
  String get refreshAnalysis;
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
      <String>['en', 'es', 'tr'].contains(locale.languageCode);

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
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
