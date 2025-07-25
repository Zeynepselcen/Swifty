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
  String get onboardingTitle1 => 'Hoş Geldin!';

  @override
  String get onboardingDesc1 => 'Galeri Temizleyici ile fotoğraflarını kolayca yönet, gereksizleri sil ve galerini ferahlat.';

  @override
  String get onboardingTitle2 => 'Kolay Kullanım';

  @override
  String get onboardingDesc2 => 'Fotoğrafları sağa kaydırarak sakla, sola kaydırarak silmek için işaretle. Hepsi bu kadar!';

  @override
  String get onboardingTitle3 => 'Gizliliğin Önceliğimiz';

  @override
  String get onboardingDesc3 => 'Uygulama sadece senin izninle galeriye erişir ve hiçbir verini paylaşmaz.';

  @override
  String get selectAlbum => 'Klasör Seç';

  @override
  String get selectAlbumDesc => 'Klasör seçerek temizlemeye başlayabilirsin.';

  @override
  String get sortBy => 'Sırala:';

  @override
  String get sortBySize => 'Boyuta göre';

  @override
  String get sortByDate => 'Son eklenme';

  @override
  String get sortByName => 'Ada göre';

  @override
  String get random15Folders => 'Rastgele 15 Klasör';

  @override
  String get random15FoldersDesc => '15 farklı klasörden rastgele fotoğraflar';

  @override
  String get noAlbumsFound => 'Hiç fotoğraf klasörü bulunamadı.';

  @override
  String remainingPhotos(Object count) {
    return 'Kalan fotoğraf: $count';
  }

  @override
  String get allPhotosReviewed => 'Tüm fotoğraflar incelendi!';

  @override
  String get allVideosReviewed => 'Tüm videolar incelendi!';

  @override
  String get deletePhotosDialogTitle => 'Fotoğrafları Sil';

  @override
  String deletePhotosDialogContent(Object count) {
    return '$count fotoğrafı silmek istiyor musun?';
  }

  @override
  String get delete => 'Sil';

  @override
  String get cancel => 'Vazgeç';

  @override
  String deleteCompleted(Object count) {
    return '$count fotoğraf silindi.';
  }

  @override
  String get ok => 'Tamam';

  @override
  String get languageSelect => 'Dil Seç';

  @override
  String get permissionRequiredTitle => 'İzin Gerekli';

  @override
  String get permissionRequiredContent => 'Klasörleri görüntülemek için galeri erişim izni vermelisiniz.';

  @override
  String get photo => 'fotoğraf';

  @override
  String get video => 'video';

  @override
  String get analysisInProgress => 'Galeri analiz ediliyor...';

  @override
  String get searchHint => 'Fotoğraflarda ara (çiçek, ağaç, erkek, kadın)';

  @override
  String get photosTab => 'Fotoğraflar';

  @override
  String get videosTab => 'Videolar';

  @override
  String get byMonth => 'Aylara Göre';

  @override
  String get sortByFilesize => 'En Yüksek Boyut';

  @override
  String get deleteCompletedTitle => 'Silme Tamamlandı';

  @override
  String get start => 'Başla';

  @override
  String get next => 'Devam';

  @override
  String get languageChangeDesc => 'Uygulama dili değiştirilecek.';

  @override
  String get languageChangedSnackBar => 'Dil değiştirildi.';

  @override
  String get analysisStarting => 'Galeri Analizi başlatılıyor...';

  @override
  String get analysisStartingTitle => 'Galeri Analizi';

  @override
  String get analysisStartingContent => 'Analiz başlatılıyor...';

  @override
  String get analysisInProgressLong => 'Fotoğraflar analiz ediliyor, lütfen bekleyin...';

  @override
  String get analysisCompleted => 'Galeri Analizi tamamlandı';

  @override
  String get refreshAnalysis => 'Analizi Yenile';
}
