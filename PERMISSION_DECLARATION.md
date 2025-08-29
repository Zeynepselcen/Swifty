# Google Play Store - MANAGE_EXTERNAL_STORAGE İzin Beyanı

## Uygulama Adı
Swifty - Akıllı Galeri Temizleyici

## İzin
MANAGE_EXTERNAL_STORAGE (Tüm dosyalara erişim)

## Temel İşlev
Swifty, kullanıcıların fotoğraf ve videolarını yönetmek, düzenlemek ve temizlemek için geliştirilmiş bir galeri uygulamasıdır.

## İzin Kullanım Amacı
Bu izin aşağıdaki temel özellikler için gereklidir:

### 1. Gelişmiş Dosya Yönetimi
- Kullanıcıların farklı klasörlerdeki fotoğraf ve videoları tek yerden yönetebilmesi
- Sistem klasörlerindeki medya dosyalarına erişim
- Harici depolama cihazlarındaki (SD kart, USB) medya dosyalarına erişim

### 2. Duplicate Fotoğraf Tespiti
- Tüm depolama alanında aynı fotoğrafları bulma
- Farklı klasörlerdeki benzer dosyaları karşılaştırma
- Hash tabanlı duplicate detection için dosya sistemine tam erişim

### 3. Toplu İşlemler
- Birden fazla klasördeki dosyaları aynı anda işleme
- Sistem genelinde fotoğraf organizasyonu
- Backup ve restore işlemleri

### 4. Gelişmiş Analiz
- Depolama alanı analizi
- Dosya boyutu optimizasyonu
- Kullanılmayan dosyaların tespiti

## Teknik Gerekçe
- `photo_manager` paketi sadece belirli medya klasörlerine erişim sağlar
- Duplicate detection için dosya hash'lerine ihtiyaç var
- Kullanıcıların farklı klasörlerdeki dosyaları yönetebilmesi gerekiyor
- Android 11+ scoped storage kısıtlamalarını aşmak için gerekli

## Kullanıcı Deneyimi
- Kullanıcılar tüm fotoğraflarını tek yerden görebilir
- Duplicate fotoğraflar tüm depolama alanında tespit edilir
- Gelişmiş dosya organizasyonu sağlanır
- Backup ve restore işlemleri kolaylaştırılır

## Veri Güvenliği
- Sadece medya dosyalarına erişim
- Kişisel veri toplanmaz
- Tüm işlemler cihazda yerel olarak gerçekleşir
- Üçüncü taraf servislerle veri paylaşımı yok

## Alternatif Çözümler
- `READ_EXTERNAL_STORAGE` ve `READ_MEDIA_*` izinleri yeterli değil
- Scoped storage API'leri kısıtlı erişim sağlıyor
- Duplicate detection için tam dosya sistemi erişimi gerekli

## Sonuç
Bu izin, uygulamanın temel işlevselliği için kritik öneme sahiptir ve kullanıcı deneyimini önemli ölçüde iyileştirmektedir.
