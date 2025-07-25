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
  String get mainScreenTitle => 'Desliza para limpiar la galería';

  @override
  String get mainScreenSubtitle => '¡Administra tus fotos fácilmente!';

  @override
  String get start => 'Comenzar';

  @override
  String get welcome => '¡Bienvenido!';

  @override
  String get languageSelect => 'Idioma';

  @override
  String get selectLanguage => 'Seleccionar idioma';

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
    return 'Todas las fotos revisadas. Si sales perderás $count foto(s). Tendrás que empezar de nuevo. ¿Quieres salir?';
  }

  @override
  String get cancelSimpleDesc =>
      'Aún no has revisado todas las fotos. ¿Quieres salir?';

  @override
  String get pleaseSelectLanguage =>
      'Por favor, selecciona tu idioma preferido.';

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
  String get date => 'date';

  @override
  String get name => 'name';

  @override
  String get largestSize => 'largest size';

  @override
  String get refresh => 'Refresh';

  @override
  String get recent => 'Recientes';

  @override
  String get download => 'Descargas';

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
      'Administra tus fotos fácilmente con Gallery Cleaner, elimina las innecesarias y refresca tu galería.';

  @override
  String get onboardingTitle2 => 'Fácil de usar';

  @override
  String get onboardingDesc2 =>
      'Desliza a la derecha para guardar fotos, a la izquierda para marcar para eliminar. ¡Eso es todo!';

  @override
  String get onboardingTitle3 => 'La privacidad es nuestra prioridad';

  @override
  String get onboardingDesc3 =>
      'La aplicación solo accede a tu galería con tu permiso y no comparte ningún dato.';

  @override
  String get duplicatePhotos => 'Fotos duplicadas';

  @override
  String get previewOfDuplicatePhotos => 'Vista previa de fotos duplicadas';

  @override
  String get deleteAllDuplicates => 'Eliminar todos los duplicados';

  @override
  String get confirmDeletion => 'Confirmar eliminación';

  @override
  String get confirmDeleteAllDuplicates =>
      '¿Estás seguro de que deseas eliminar todas las fotos duplicadas? Esta acción no se puede deshacer.';

  @override
  String get deleteAll => 'Eliminar todo';

  @override
  String get allDuplicatesDeleted => 'Todos los duplicados eliminados.';

  @override
  String get skipThisStep => 'Omitir este paso';

  @override
  String get skip => 'Omitir';

  @override
  String get duplicatePreviewInfo =>
      'La primera foto de cada grupo se mantendrá. Todas las demás serán eliminadas.';

  @override
  String get analyzeGallery => 'Analizar galería';

  @override
  String get galleryAnalysisCompleted => 'Análisis de galería completado';

  @override
  String get gallerySlogan => 'Aligera tu galería de fotos';

  @override
  String get darkTheme => 'Tema Oscuro';

  @override
  String get lightTheme => 'Tema Claro';

  @override
  String exitReviewDialog(Object label, Object label2, Object remaining) {
    return 'Estás a punto de salir sin revisar todas las $label. Restantes: $remaining $label2. Si regresas, tendrás que empezar de nuevo. ¿Quieres salir?';
  }
}
