# Swifty

Swifty, Android ve iOS için geliştirilmiş modern bir **galeri temizleyici ve fotoğraf yöneticisi** uygulamasıdır. Fotoğraflarınızı kolayca yönetmenizi, gereksizleri silmenizi ve galerinizde yer açmanızı sağlar.

## Özellikler
- Galerideki fotoğrafları hızlıca görüntüleme
- Sürükle-bırak ile kolay silme veya saklama
- Çift fotoğraf (duplicate) tespiti
- Tüm dosya yönetimi izni desteği (Android 11+)
- Çoklu dil desteği (Türkçe, İngilizce, İspanyolca, Korece)

## Kurulum

1. Depoyu klonlayın:
   ```sh
   git clone https://github.com/Zeynepselcen/Swifty.git
   cd Swifty
   ```
2. Bağımlılıkları yükleyin:
   ```sh
   flutter pub get
   ```
3. Uygulamayı başlatın:
   ```sh
   flutter run
   ```

### APK veya AAB Oluşturma
- Sadece kendi cihazınız için küçük boyutlu APK:
  ```sh
  flutter build apk --split-per-abi
  ```
- Google Play için AAB dosyası:
  ```sh
  flutter build appbundle --release
  ```

## Katkı Sağlama
Katkıda bulunmak isterseniz, lütfen bir fork oluşturun ve pull request gönderin. Hataları veya önerileri [issue](https://github.com/Zeynepselcen/Swifty/issues) olarak bildirebilirsiniz.

## Lisans
MIT
