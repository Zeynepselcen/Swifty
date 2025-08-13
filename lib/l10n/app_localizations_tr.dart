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
  String get date => 'Tarih';

  @override
  String get name => 'isim';

  @override
  String photoCount(Object count) {
    return '$count fotoğraf';
  }

  @override
  String get largestSize => 'en büyük boyut';

  @override
  String get refresh => 'Yenile';

  @override
  String get folder => 'Klasör';

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
  String get gallerySlogan => 'Galeri Temizliği';

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

  @override
  String get photoDetail => 'Fotoğraf Detayı';

  @override
  String get undoTitle => 'Geri Alma';

  @override
  String undoMessage(Object count) {
    return '$count fotoğrafı geri almak istiyor musunuz?';
  }

  @override
  String get undoCancel => 'İptal';

  @override
  String get undoConfirm => 'Geri Al';

  @override
  String get filePermanentlyDeleted => 'Dosya gerçekten silindi, geri alınamaz';

  @override
  String get lastPhotoUndone => 'Son silinen fotoğraf geri alındı';

  @override
  String get undoFeatureComingSoon => 'Geri alma özelliği yakında eklenecek';

  @override
  String get recentlyDeletedFilesNotFound => 'Silinen dosya bulunamadı';

  @override
  String get restoreFile => 'Geri Al';

  @override
  String get fileDetails => 'Dosya Bilgileri';

  @override
  String get deletedAt => 'Silinme';

  @override
  String get timeRemaining => 'Kalan süre';

  @override
  String get close => 'Kapat';

  @override
  String get fileRestored => 'Dosya geri alındı';

  @override
  String get fileNotFound => 'Dosya bulunamadı';

  @override
  String get restoreError => 'Geri alma hatası';

  @override
  String get galleryOptions => 'Galeri Seçenekleri';

  @override
  String get androidGallery => 'Android Galerisi';

  @override
  String get androidGalleryDesc => 'Telefonun kendi galeri uygulamasını aç';

  @override
  String get recentlyDeleted => 'Son Silinenler';

  @override
  String get recentlyDeletedDesc => 'Android\'in kendi çöp kutusunu aç';

  @override
  String get galleryAppNotFound =>
      'Galeri uygulaması açılamadı. Manuel olarak galeri uygulamasını açabilirsiniz.';

  @override
  String get trashNotFound =>
      'Çöp kutusu açılamadı. Manuel olarak dosya yöneticisinden DCIM/.trash klasörüne gidebilirsiniz.';

  @override
  String get restoreFiles => 'Dosyaları Geri Al';

  @override
  String get restoreFilesQuestion =>
      'Silinen dosyaları geri almak istiyor musunuz?';

  @override
  String get restoreAll => 'Tümünü Geri Al';

  @override
  String get noFilesToRestore => 'Geri alınacak dosya bulunamadı';

  @override
  String get filesRestoredSuccessfully => 'Dosyalar başarıyla geri alındı';

  @override
  String get exitConfirmation => 'Çıkış Onayı';

  @override
  String exitWithoutReviewing(Object label, Object remaining) {
    return 'Tüm $label incelemeden çıkmak üzeresiniz. Kalan: $remaining $label. Geri dönerseniz baştan başlamanız gerekecek. Çıkmak istiyor musunuz?';
  }

  @override
  String get deleteAndExit => 'Sil ve Çık';

  @override
  String get exitWithoutDeleting => 'Silmeden Çık';

  @override
  String filesMovedToTrash(Object count) {
    return '$count dosya \"Son Silinenler\" klasörüne taşındı. 30 gün boyunca \"Son Silinenler\" ekranından geri alabilirsiniz.';
  }

  @override
  String get restore => 'Geri Al';

  @override
  String get details => 'Detaylar';

  @override
  String get originalPath => 'Orijinal Yol';

  @override
  String get trashPath => 'Çöp Kutusu Yolu';

  @override
  String get expiresAt => 'Süre';

  @override
  String daysRemaining(Object days, Object hours) {
    return '$days gün $hours saat kaldı';
  }

  @override
  String hoursRemaining(Object hours) {
    return '$hours saat kaldı';
  }

  @override
  String get expiringSoon => 'Süre dolmak üzere';

  @override
  String get androidTrashFolder => 'Android Çöp Kutusu';

  @override
  String get androidTrashFolderDesc =>
      'Dosyalar Android\'in kendi çöp kutusuna taşındı';

  @override
  String get appTrashFolder => 'Uygulama Çöp Kutusu';

  @override
  String get appTrashFolderDesc =>
      'Dosyalar uygulamanın iç çöp kutusuna taşındı';

  @override
  String get loading => 'Yükleniyor...';

  @override
  String get loadingPhotos => 'Fotoğraflar yükleniyor...';

  @override
  String get loadingVideos => 'Videolar yükleniyor...';

  @override
  String get loadingAlbums => 'Albümler yükleniyor...';

  @override
  String get pleaseWait => 'Lütfen bekleyin';

  @override
  String get analyzingGallery => 'Galeri analiz ediliyor...';

  @override
  String get processingFiles => 'Dosyalar işleniyor...';

  @override
  String get preparingFiles => 'Dosyalar hazırlanıyor...';

  @override
  String get photoDeleted => 'Fotoğraf silindi';

  @override
  String get filesRestored => 'Dosyalar başarıyla geri alındı';

  @override
  String get videoLoading => 'Video yükleniyor...';

  @override
  String get exitReviewDialogTitle => 'İnceleme Ekranından Çık';

  @override
  String get manageAllFilesPermissionTitle => 'Tüm Dosyalar İzni';

  @override
  String get manageAllFilesPermissionDescription =>
      'Tüm dosyalarınıza erişim izni gereklidir.';

  @override
  String get goToSettings => 'Ayarlar\'a Git';

  @override
  String get back => 'Geri';

  @override
  String get undo => 'Geri Al';

  @override
  String get noPhotosFound => 'Bu klasörde fotoğraf bulunamadı';

  @override
  String get permissionRequired => 'İzin Gerekli';

  @override
  String get permissionRequiredDescription =>
      'Galerinize erişim için izin gereklidir. Lütfen cihaz ayarlarınızda etkinleştirin.';

  @override
  String get noAlbumsFoundDescription =>
      'Galeriye erişim izni verildi ancak hiç fotoğraf veya video bulunamadı.';

  @override
  String get onboardingTitleDetail => 'Detaylı İnceleme';

  @override
  String get onboardingDescDetail =>
      'Fotoğraflara tıklayarak yakınlaştır ve detayları incele. Zoom ikonu ile kolay erişim!';

  @override
  String get aboutTitle => 'Uygulama Hakkında';

  @override
  String get aboutDescription =>
      'Swifty Galeri Temizliği ile fotoğraflarınızı kolayca yönetin!';

  @override
  String get settings => 'Ayarlar';

  @override
  String get language => 'Dil';

  @override
  String get theme => 'Tema';

  @override
  String get themeDescription => 'Görünümü değiştir';

  @override
  String get aboutTakeTour =>
      'Uygulama özelliklerini öğrenmek için turu başlatın';

  @override
  String get aboutTakeTourButton => 'Turu Başlat';

  @override
  String get videoGallery => 'Video Galerisi';

  @override
  String get photoGallery => 'Fotoğraf Galerisi';

  @override
  String get swipeToDelete => 'Silmek için kaydır';

  @override
  String get deleteConfirmation => 'Silme Onayı';

  @override
  String get delete => 'Sil';

  @override
  String get allDeletedFilesCleared => 'Tüm silinen dosyalar temizlendi';

  @override
  String get clearError => 'Temizleme hatası';

  @override
  String get fileRestoring => 'geri alınıyor';

  @override
  String get fileRestoredToFolder => 'klasörüne geri alındı';

  @override
  String get folderSuffix => '';

  @override
  String get fileRestoredToDcim => 'DCIM\'e geri alındı';

  @override
  String get clearAll => 'Tümünü Temizle';

  @override
  String get january => 'Ocak';

  @override
  String get february => 'Şubat';

  @override
  String get march => 'Mart';

  @override
  String get april => 'Nisan';

  @override
  String get may => 'Mayıs';

  @override
  String get june => 'Haziran';

  @override
  String get july => 'Temmuz';

  @override
  String get august => 'Ağustos';

  @override
  String get september => 'Eylül';

  @override
  String get october => 'Ekim';

  @override
  String get november => 'Kasım';

  @override
  String get december => 'Aralık';

  @override
  String filesMovedToRecentlyDeleted(Object count) {
    return '$count dosya \"Son Silinenler\" klasörüne taşındı. 30 gün boyunca geri alabilirsiniz.';
  }

  @override
  String filesSuccessfullyDeleted(Object count) {
    return '$count dosya başarıyla silindi';
  }

  @override
  String markedForDeletion(Object count) {
    return '$count dosya silmek için işaretlendi!';
  }

  @override
  String notAllPhotosReviewed(Object type) {
    return 'Henüz tüm $type gözden geçirmediniz.';
  }

  @override
  String noPhotosFoundDescription(Object type) {
    return 'Galeriye erişim izni verildi ancak hiç $type bulunamadı.';
  }

  @override
  String get pleaseWaitThisMayTakeTime =>
      'Lütfen bekleyin, bu işlem biraz zaman alabilir';

  @override
  String get remaining => 'KALAN';

  @override
  String get spaceSaved => 'KAZANILAN';

  @override
  String get deleteAllButton => 'Tümünü Sil';

  @override
  String get completed => 'Bitti!';
}
