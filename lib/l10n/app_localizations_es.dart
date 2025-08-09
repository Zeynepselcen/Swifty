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
  String get date => 'Fecha';

  @override
  String get name => 'nombre';

  @override
  String photoCount(Object count) {
    return '$count photos';
  }

  @override
  String get largestSize => 'tamaño más grande';

  @override
  String get refresh => 'Actualizar';

  @override
  String get folder => 'Carpeta';

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
  String get recentlyDeletedFilesNotFound =>
      'No se encontraron archivos eliminados';

  @override
  String get restoreFile => 'Restaurar';

  @override
  String get fileDetails => 'Detalles del Archivo';

  @override
  String get deletedAt => 'Eliminado en';

  @override
  String get timeRemaining => 'Tiempo restante';

  @override
  String get close => 'Cerrar';

  @override
  String get fileRestored => 'Archivo restaurado';

  @override
  String get fileNotFound => 'Archivo no encontrado';

  @override
  String get restoreError => 'Error de restauración';

  @override
  String get galleryOptions => 'Opciones de Galería';

  @override
  String get androidGallery => 'Galería de Android';

  @override
  String get androidGalleryDesc =>
      'Abrir la aplicación de galería propia del teléfono';

  @override
  String get recentlyDeleted => 'Eliminados Recientemente';

  @override
  String get recentlyDeletedDesc => 'Abrir la papelera propia de Android';

  @override
  String get galleryAppNotFound =>
      'No se pudo abrir la aplicación de galería. Puedes abrir la aplicación de galería manualmente.';

  @override
  String get trashNotFound =>
      'No se pudo abrir la papelera. Puedes ir a la carpeta DCIM/.trash desde el administrador de archivos manualmente.';

  @override
  String get restoreFiles => 'Restaurar Archivos';

  @override
  String get restoreFilesQuestion => '¿Quieres restaurar archivos eliminados?';

  @override
  String get restoreAll => 'Restaurar Todo';

  @override
  String get noFilesToRestore => 'No hay archivos para restaurar';

  @override
  String get filesRestoredSuccessfully => 'Archivos restaurados exitosamente';

  @override
  String get exitConfirmation => 'Confirmación de Salida';

  @override
  String exitWithoutReviewing(Object label, Object remaining) {
    return 'Estás a punto de salir sin revisar todos los $label. Restantes: $remaining $label. Si regresas, tendrás que empezar de nuevo. ¿Quieres salir?';
  }

  @override
  String get deleteAndExit => 'Eliminar y Salir';

  @override
  String get exitWithoutDeleting => 'Salir Sin Eliminar';

  @override
  String filesMovedToTrash(Object count) {
    return '$count archivos movidos a la carpeta \"Eliminados Recientemente\". Puedes restaurarlos dentro de 30 días desde la pantalla \"Eliminados Recientemente\".';
  }

  @override
  String get restore => 'Restaurar';

  @override
  String get details => 'Detalles';

  @override
  String get originalPath => 'Ruta Original';

  @override
  String get trashPath => 'Ruta de Papelera';

  @override
  String get expiresAt => 'Expira en';

  @override
  String daysRemaining(Object days, Object hours) {
    return '$days días $hours horas restantes';
  }

  @override
  String hoursRemaining(Object hours) {
    return '$hours horas restantes';
  }

  @override
  String get expiringSoon => 'Expirando pronto';

  @override
  String get androidTrashFolder => 'Papelera de Android';

  @override
  String get androidTrashFolderDesc =>
      'Archivos movidos a la papelera propia de Android';

  @override
  String get appTrashFolder => 'Papelera de la Aplicación';

  @override
  String get appTrashFolderDesc =>
      'Archivos movidos a la papelera interna de la aplicación';

  @override
  String get loading => 'Cargando...';

  @override
  String get loadingPhotos => 'Cargando fotos...';

  @override
  String get loadingVideos => 'Cargando videos...';

  @override
  String get loadingAlbums => 'Cargando álbumes...';

  @override
  String get pleaseWait => 'Por favor espera';

  @override
  String get analyzingGallery => 'Analizando galería...';

  @override
  String get processingFiles => 'Procesando archivos...';

  @override
  String get preparingFiles => 'Preparando archivos...';

  @override
  String get photoDeleted => 'Foto eliminada';

  @override
  String get filesRestored => 'Archivos restaurados exitosamente';

  @override
  String get videoLoading => 'Cargando video...';

  @override
  String get exitReviewDialogTitle => 'Salir de la Pantalla de Revisión';

  @override
  String get manageAllFilesPermissionTitle =>
      'Permiso de Gestión de Todos los Archivos';

  @override
  String get manageAllFilesPermissionDescription =>
      'Se requiere acceso a todos tus archivos.';

  @override
  String get goToSettings => 'Ir a Configuración';

  @override
  String get back => 'Atrás';

  @override
  String get undo => 'Deshacer';

  @override
  String get noPhotosFound => 'No se encontraron fotos en esta carpeta';

  @override
  String get permissionRequired => 'Permiso Requerido';

  @override
  String get permissionRequiredDescription =>
      'Se requiere permiso para acceder a tu galería. Por favor habilítalo en la configuración de tu dispositivo.';

  @override
  String get noAlbumsFoundDescription =>
      'Se otorgó permiso de acceso a la galería pero no se encontraron fotos o videos.';

  @override
  String get onboardingTitleDetail => 'Revisión Detallada';

  @override
  String get onboardingDescDetail =>
      'Toca las fotos para acercar y examinar los detalles. ¡Acceso fácil con el icono de zoom!';

  @override
  String get aboutTitle => 'Acerca de la aplicación';

  @override
  String get aboutDescription =>
      '¡Administra tus fotos fácilmente con Swifty Gallery Cleaner!';

  @override
  String get settings => 'Configuración';

  @override
  String get language => 'Idioma';

  @override
  String get theme => 'Tema';

  @override
  String get themeDescription => 'Cambiar apariencia';

  @override
  String get aboutTakeTour =>
      'Toma un tour para aprender más sobre las características de la aplicación';

  @override
  String get aboutTakeTourButton => 'Iniciar Tour';

  @override
  String get videoGallery => 'Video Gallery';

  @override
  String get photoGallery => 'Photo Gallery';

  @override
  String get swipeToDelete => 'Swipe to delete';
}
