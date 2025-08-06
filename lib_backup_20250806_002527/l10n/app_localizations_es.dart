// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Swifty';

  @override
  String get mainScreenTitle => 'Desliza para Limpiar Galería';

  @override
  String get mainScreenSubtitle => '¡Gestiona tus fotos fácilmente!';

  @override
  String get start => 'Comenzar';

  @override
  String get welcome => '¡Bienvenido!';

  @override
  String get languageSelect => 'Idioma';

  @override
  String get selectLanguage => 'Seleccionar Idioma';

  @override
  String get noAlbumsFound => 'No se encontraron álbumes.';

  @override
  String get noVideosFound => 'No se encontraron videos.';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancelar';

  @override
  String get cancelTitle => 'Cancelar';

  @override
  String cancelDesc(Object count) {
    return 'Todas las fotos revisadas. Salir hará perder $count foto(s). Tendrás que empezar de nuevo. ¿Quieres salir?';
  }

  @override
  String get cancelSimpleDesc =>
      'Aún no has revisado todas las fotos. ¿Quieres salir?';

  @override
  String get pleaseSelectLanguage =>
      'Por favor selecciona tu idioma preferido.';

  @override
  String get languageChangedTo => 'Idioma cambiado a';

  @override
  String get allVideosReviewed => 'Todos los videos revisados';

  @override
  String get allPhotosReviewed => 'Todas las fotos revisadas';

  @override
  String get searchPhotos => 'Buscar fotos';

  @override
  String get videos => 'Videos';

  @override
  String get photos => 'Fotos';

  @override
  String get size => 'tamaño';

  @override
  String get date => 'fecha';

  @override
  String get name => 'nombre';

  @override
  String get largestSize => 'tamaño más grande';

  @override
  String get refresh => 'Actualizar';

  @override
  String get recent => 'Reciente';

  @override
  String get download => 'Descargar';

  @override
  String remainingPhotos(Object count) {
    return 'Fotos restantes: $count';
  }

  @override
  String get next => 'Siguiente';

  @override
  String get onboardingTitle1 => '¡Bienvenido!';

  @override
  String get onboardingDesc1 =>
      'Gestiona tus fotos fácilmente con Limpiador de Galería, elimina las innecesarias y refresca tu galería.';

  @override
  String get onboardingTitle2 => 'Fácil de Usar';

  @override
  String get onboardingDesc2 =>
      'Desliza a la derecha para guardar fotos, desliza a la izquierda para marcar para eliminar. ¡Eso es todo!';

  @override
  String get onboardingTitle3 => 'La Privacidad es Nuestra Prioridad';

  @override
  String get onboardingDesc3 =>
      'La aplicación solo accede a tu galería con tu permiso y no comparte ningún dato.';

  @override
  String get duplicatePhotos => 'Fotos Duplicadas';

  @override
  String get previewOfDuplicatePhotos => 'Vista previa de fotos duplicadas';

  @override
  String get deleteAllDuplicates => 'Eliminar todos los duplicados';

  @override
  String get confirmDeletion => 'Confirmar Eliminación';

  @override
  String get confirmDeleteAllDuplicates =>
      '¿Estás seguro de que quieres eliminar todas las fotos duplicadas? Esta acción no se puede deshacer.';

  @override
  String get deleteAll => 'Eliminar Todo';

  @override
  String get allDuplicatesDeleted => 'Todos los duplicados eliminados.';

  @override
  String get skipThisStep => 'Saltar este paso';

  @override
  String get skip => 'Saltar';

  @override
  String get duplicatePreviewInfo =>
      'La primera foto en cada grupo se mantendrá. Todas las demás serán eliminadas.';

  @override
  String get analyzeGallery => 'Analizar Galería';

  @override
  String get galleryAnalysisCompleted => 'Análisis de galería completado';

  @override
  String get gallerySlogan => 'Limpiador de Galería';

  @override
  String get darkTheme => 'Tema Oscuro';

  @override
  String get lightTheme => 'Tema Claro';

  @override
  String exitReviewDialog(Object label, Object remaining) {
    return 'Estás a punto de salir sin revisar todos los $label. Restantes: $remaining $label. Si regresas, tendrás que empezar de nuevo. ¿Quieres salir?';
  }

  @override
  String get duplicateCheckQuestion =>
      '¿Te gustaría verificar duplicados en esta carpeta?';

  @override
  String get duplicateCheckDescription =>
      'Si se encuentran fotos duplicadas, puedes elegir cuáles eliminar.';

  @override
  String get yesCheckDuplicates => 'Sí, Verificar';

  @override
  String get noDuplicatesFound =>
      'No se encontraron fotos duplicadas en esta carpeta.';

  @override
  String get recentlyDeletedTitle => 'Eliminados Recientemente';

  @override
  String recentlyDeletedMessage(Object count) {
    return '$count elementos han sido eliminados y movidos al álbum \"Eliminados Recientemente\". Estos elementos permanecerán allí durante 30 días y luego serán eliminados permanentemente de forma automática.';
  }

  @override
  String get zoomHint => 'Pellizcar para hacer zoom';

  @override
  String get zoomHintDescription =>
      'Usa dos dedos para hacer zoom en las fotos para una mejor visualización';

  @override
  String get photoDetail => 'Detalle de Foto';

  @override
  String get undoTitle => 'Deshacer';

  @override
  String undoMessage(Object count) {
    return '¿Quieres deshacer $count foto(s)?';
  }

  @override
  String get undoCancel => 'Cancelar';

  @override
  String get undoConfirm => 'Deshacer';

  @override
  String get filePermanentlyDeleted =>
      'El archivo se eliminó permanentemente, no se puede deshacer';

  @override
  String get lastPhotoUndone => 'Última foto eliminada deshecha';

  @override
  String get undoFeatureComingSoon => 'Función de deshacer próximamente';

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
}
