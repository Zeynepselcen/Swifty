// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Gallery Cleaner';

  @override
  String get mainScreenTitle => 'Gallery Cleaner';

  @override
  String get mainScreenSubtitle => 'Manage your photos easily!';

  @override
  String get onboardingTitle1 => 'Welcome!';

  @override
  String get onboardingDesc1 => 'With Gallery Cleaner, easily manage your photos, delete unnecessary ones, and refresh your gallery.';

  @override
  String get onboardingTitle2 => 'Easy to Use';

  @override
  String get onboardingDesc2 => 'Swipe right to keep, swipe left to mark for deletion. That\'s it!';

  @override
  String get onboardingTitle3 => 'Privacy First';

  @override
  String get onboardingDesc3 => 'The app only accesses your gallery with your permission and never shares your data.';

  @override
  String get selectAlbum => 'Select Album';

  @override
  String get selectAlbumDesc => 'Puedes empezar a limpiar seleccionando una carpeta.';

  @override
  String get sortBy => 'Sort by:';

  @override
  String get sortBySize => 'By size';

  @override
  String get sortByDate => 'By date';

  @override
  String get sortByName => 'By name';

  @override
  String get random15Folders => 'Random 15 Folders';

  @override
  String get random15FoldersDesc => 'Random photos from 15 different folders';

  @override
  String get noAlbumsFound => 'No photo albums found.';

  @override
  String remainingPhotos(Object count) {
    return 'Remaining photos: $count';
  }

  @override
  String get allPhotosReviewed => 'All photos reviewed!';

  @override
  String get allVideosReviewed => 'All videos reviewed!';

  @override
  String get deletePhotosDialogTitle => 'Delete Photos';

  @override
  String deletePhotosDialogContent(Object count) {
    return 'Do you want to delete $count photos?';
  }

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String deleteCompleted(Object count) {
    return '$count photos deleted.';
  }

  @override
  String get ok => 'OK';

  @override
  String get languageSelect => 'Select Language';

  @override
  String get permissionRequiredTitle => 'Permission Required';

  @override
  String get permissionRequiredContent => 'You must grant gallery access permission to view albums.';

  @override
  String get photo => 'photo';

  @override
  String get video => 'video';

  @override
  String get analysisInProgress => 'Analyzing gallery...';

  @override
  String get searchHint => 'Search in photos (flower, tree, man, woman)';

  @override
  String get photosTab => 'Photos';

  @override
  String get videosTab => 'Videos';

  @override
  String get byMonth => 'By Month';

  @override
  String get sortByFilesize => 'By largest size';

  @override
  String get deleteCompletedTitle => 'Delete Completed';

  @override
  String get start => 'Start';

  @override
  String get next => 'Next';

  @override
  String get languageChangeDesc => 'The app language will be changed.';

  @override
  String get languageChangedSnackBar => 'Language changed.';

  @override
  String get analysisStarting => 'Gallery analysis starting...';

  @override
  String get analysisStartingTitle => 'Gallery Analysis';

  @override
  String get analysisStartingContent => 'Analysis starting...';

  @override
  String get analysisInProgressLong => 'Photos are being analyzed, please wait...';

  @override
  String get analysisCompleted => 'Gallery analysis completed';

  @override
  String get refreshAnalysis => 'Refresh Analysis';
}
