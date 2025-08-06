#!/bin/bash

echo "🚀 Swifty Gallery Cleaner AAB Oluşturma Başlıyor..."

# Proje dizinine geç
cd "$(dirname "$0")"

# Flutter dependencies'leri güncelle
echo "📦 Flutter dependencies güncelleniyor..."
flutter pub get

# Clean build
echo "🧹 Build temizleniyor..."
flutter clean

# AAB oluştur
echo "🔨 AAB oluşturuluyor..."
flutter build appbundle --release

# AAB dosyasının konumunu kontrol et
AAB_PATH="build/app/outputs/bundle/release/app-release.aab"

if [ -f "$AAB_PATH" ]; then
    echo "✅ AAB başarıyla oluşturuldu!"
    echo "📁 Dosya konumu: $AAB_PATH"
    echo "📊 Dosya boyutu: $(du -h "$AAB_PATH" | cut -f1)"
    
    # Dosya bilgilerini göster
    echo ""
    echo "📋 AAB Dosya Bilgileri:"
    echo "   - Uygulama: Swifty Gallery Cleaner"
    echo "   - Versiyon: 1.3.3+20"
    echo "   - Package: com.swifty.gallerycleaner"
    echo "   - Minimum SDK: 21"
    echo "   - Target SDK: 35"
else
    echo "❌ AAB oluşturulamadı!"
    exit 1
fi

echo ""
echo "🎉 AAB oluşturma tamamlandı!"
echo "📤 Google Play Console'a yüklemek için hazır." 