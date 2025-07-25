// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Swifty';

  @override
  String get mainScreenTitle => 'Kaydırarak Galeri Temizliği';

  @override
  String get mainScreenSubtitle => 'Fotoğraflarınızı kolayca yönetin!';

  @override
  String get start => 'Başla';

  @override
  String get welcome => 'Hoş geldin!';

  @override
  String get languageSelect => 'Dil';

  @override
  String get selectLanguage => 'Dil Seç';

  @override
  String get noAlbumsFound => 'Albüm bulunmadı.';

  @override
  String get noVideosFound => 'Video bulunmadı.';

  @override
  String get ok => 'Tamam';

  @override
  String get cancel => 'Vazgeç';

  @override
  String get cancelTitle => 'Vazgeç';

  @override
  String cancelDesc(Object count) {
    return 'Tüm fotoğraflar incelendi. Ayrılırsan $count fotoğraf kaybolacak. Baştan başlamak zorunda kalacaksın. Çıkmak istiyor musun?';
  }

  @override
  String get cancelSimpleDesc =>
      'Henüz tüm fotoğrafları incelemedin. Çıkmak istiyor musun?';

  @override
  String get pleaseSelectLanguage => 'Lütfen tercih ettiğiniz dili seçin.';

  @override
  String get languageChangedTo => 'Dil değiştirildi:';

  @override
  String get allVideosReviewed => 'Tüm videolar incelendi';

  @override
  String get allPhotosReviewed => 'Tüm fotoğraflar incelendi';

  @override
  String get searchPhotos => 'Fotoğraflarda ara';

  @override
  String get videos => 'Videolar';

  @override
  String get photos => 'Fotoğraflar';

  @override
  String get size => 'boyut';

  @override
  String get date => 'tarih';

  @override
  String get name => 'isim';

  @override
  String get largestSize => 'en büyük boyut';

  @override
  String get refresh => 'Yenile';

  @override
  String get recent => 'Son Eklenenler';

  @override
  String get download => 'İndirilenler';

  @override
  String remainingPhotos(Object count) {
    return 'Kalan fotoğraf: $count';
  }

  @override
  String get next => 'Devam';

  @override
  String get onboardingTitle1 => 'Hoş Geldin!';

  @override
  String get onboardingDesc1 =>
      'Galeri Temizleyici ile fotoğraflarını kolayca yönet, gereksizleri sil ve galerini ferahlat.';

  @override
  String get onboardingTitle2 => 'Kolay Kullanım';

  @override
  String get onboardingDesc2 =>
      'Fotoğrafları sağa kaydırarak sakla, sola kaydırarak silmek için işaretle. Hepsi bu kadar!';

  @override
  String get onboardingTitle3 => 'Gizliliğin Önceliğimiz';

  @override
  String get onboardingDesc3 =>
      'Uygulama sadece senin izninle galeriye erişir ve hiçbir verini paylaşmaz.';

  @override
  String get duplicatePhotos => 'Çift Fotoğraflar';

  @override
  String get previewOfDuplicatePhotos => 'Çift fotoğrafların önizlemesi';

  @override
  String get deleteAllDuplicates => 'Tüm çiftleri sil';

  @override
  String get confirmDeletion => 'Silme Onayı';

  @override
  String get confirmDeleteAllDuplicates =>
      'Tüm çift fotoğrafları silmek istediğinize emin misiniz? Bu işlem geri alınamaz.';

  @override
  String get deleteAll => 'Tümünü Sil';

  @override
  String get allDuplicatesDeleted => 'Tüm çiftler silindi.';

  @override
  String get skipThisStep => 'Bu adımı atla';

  @override
  String get skip => 'Atla';

  @override
  String get duplicatePreviewInfo =>
      'Her gruptaki ilk fotoğraf kalacak. Diğer tekrar edenler silinecek.';

  @override
  String get analyzeGallery => 'Galeriyi Analiz Et';

  @override
  String get galleryAnalysisCompleted => 'Galeri analizi tamamlandı';

  @override
  String get gallerySlogan => 'Galerini Hafiflet';

  @override
  String get darkTheme => 'Koyu Tema';

  @override
  String get lightTheme => 'Açık Tema';

  @override
  String exitReviewDialog(Object label, Object label2, Object remaining) {
    return 'Tüm $label incelemeden çıkmak üzeresin. Kalan: $remaining $label2. Geri dönersen baştan başlamak zorunda kalırsın. Çıkmak istiyor musun?';
  }
}
