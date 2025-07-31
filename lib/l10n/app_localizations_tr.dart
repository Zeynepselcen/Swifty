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
  String get mainScreenTitle => 'Galeriyi Temizlemek İçin Kaydır';

  @override
  String get mainScreenSubtitle => 'Fotoğraflarınızı kolayca yönetin!';

  @override
  String get start => 'Başla';

  @override
  String get welcome => 'Hoş Geldiniz!';

  @override
  String get languageSelect => 'Dil';

  @override
  String get selectLanguage => 'Dil Seçin';

  @override
  String get noAlbumsFound => 'Albüm bulunamadı.';

  @override
  String get noVideosFound => 'Video bulunamadı.';

  @override
  String get ok => 'Tamam';

  @override
  String get cancel => 'İptal';

  @override
  String get cancelTitle => 'İptal';

  @override
  String cancelDesc(Object count) {
    return 'Tüm fotoğraflar incelendi. Ayrılırsanız $count fotoğraf kaybolacak. Baştan başlamanız gerekecek. Ayrılmak istiyor musunuz?';
  }

  @override
  String get cancelSimpleDesc =>
      'Henüz tüm fotoğrafları incelemediniz. Çıkmak istiyor musunuz?';

  @override
  String get pleaseSelectLanguage => 'Lütfen tercih ettiğiniz dili seçin.';

  @override
  String get languageChangedTo => 'Dil değiştirildi:';

  @override
  String get allVideosReviewed => 'Tüm videolar incelendi';

  @override
  String get allPhotosReviewed => 'Tüm fotoğraflar incelendi';

  @override
  String get searchPhotos => 'Fotoğraf ara';

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
  String get recent => 'Son';

  @override
  String get download => 'İndir';

  @override
  String remainingPhotos(Object count) {
    return 'Kalan fotoğraflar: $count';
  }

  @override
  String get next => 'İleri';

  @override
  String get onboardingTitle1 => 'Hoş Geldiniz!';

  @override
  String get onboardingDesc1 =>
      'Galeri Temizleyici ile fotoğraflarınızı kolayca yönetin, gereksiz olanları silin ve galerinizi yenileyin.';

  @override
  String get onboardingTitle2 => 'Kullanımı Kolay';

  @override
  String get onboardingDesc2 =>
      'Fotoğrafları kaydetmek için sağa, silmek için sola kaydırın. Bu kadar!';

  @override
  String get onboardingTitle3 => 'Gizlilik Önceliğimiz';

  @override
  String get onboardingDesc3 =>
      'Uygulama sadece izninizle galerinize erişir ve hiçbir veri paylaşmaz.';

  @override
  String get duplicatePhotos => 'Kopya Fotoğraflar';

  @override
  String get previewOfDuplicatePhotos => 'Kopya fotoğrafların önizlemesi';

  @override
  String get deleteAllDuplicates => 'Tüm kopyaları sil';

  @override
  String get confirmDeletion => 'Silme Onayı';

  @override
  String get confirmDeleteAllDuplicates =>
      'Tüm kopya fotoğrafları silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.';

  @override
  String get deleteAll => 'Tümünü Sil';

  @override
  String get allDuplicatesDeleted => 'Tüm kopyalar silindi.';

  @override
  String get skipThisStep => 'Bu adımı atla';

  @override
  String get skip => 'Atla';

  @override
  String get duplicatePreviewInfo =>
      'Her gruptaki ilk fotoğraf saklanacak. Diğerleri silinecek.';

  @override
  String get analyzeGallery => 'Galeriyi Analiz Et';

  @override
  String get galleryAnalysisCompleted => 'Galeri analizi tamamlandı';

  @override
  String get gallerySlogan => 'Swifty: Galerinizi Temizleyin';

  @override
  String get darkTheme => 'Koyu Tema';

  @override
  String get lightTheme => 'Açık Tema';

  @override
  String exitReviewDialog(Object label, Object remaining) {
    return 'Tüm $label incelemeden çıkmak üzeresiniz. Kalan: $remaining $label. Geri dönerseniz baştan başlamanız gerekecek. Çıkmak istiyor musunuz?';
  }

  @override
  String get duplicateCheckQuestion =>
      'Bu klasörde kopya kontrolü yapmak ister misiniz?';

  @override
  String get duplicateCheckDescription =>
      'Kopya fotoğraflar bulunursa, hangilerini sileceğinizi seçebilirsiniz.';

  @override
  String get yesCheckDuplicates => 'Evet, Kontrol Et';

  @override
  String get noDuplicatesFound => 'Bu klasörde kopya fotoğraf bulunamadı.';

  @override
  String get recentlyDeletedTitle => 'Son Silinenler';

  @override
  String recentlyDeletedMessage(Object count) {
    return '$count öğe silindi ve \"Son Silinenler\" albümüne taşındı. Bu öğeler 30 gün boyunca orada kalacak ve sonra otomatik olarak kalıcı olarak silinecek.';
  }

  @override
  String get zoomHint => 'Yakınlaştırmak için sıkıştırın';

  @override
  String get zoomHintDescription =>
      'Fotoğrafları daha iyi görmek için iki parmakla yakınlaştırıp uzaklaştırabilirsiniz';
}
