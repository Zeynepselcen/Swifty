#!/bin/bash

echo "🚀 Swifty Gallery Cleaner - AAB Oluşturma"
echo "=========================================="

# Sürüm numarasını otomatik artır
echo "📱 Sürüm numarası güncelleniyor..."
./update_version.sh

# Yeni sürüm bilgilerini oku
new_version=$(cat version.txt)
new_minor=$(echo "1.0.$((new_version - 1))")

echo "✅ Yeni sürüm: $new_minor (Code: $new_version)"

# AAB oluştur
echo "🔨 AAB dosyası oluşturuluyor..."
flutter build appbundle --release

if [ $? -eq 0 ]; then
    echo "✅ AAB başarıyla oluşturuldu!"
    echo "📁 Dosya: build/app/outputs/bundle/release/app-release.aab"
    echo "📱 Sürüm: $new_minor"
    echo ""
    echo "🎯 Google Play Console'a yüklemeye hazır!"
    echo "💡 Sürüm notları:"
    echo "   TR: 'Video sorunu düzeltildi, performans iyileştirildi'"
    echo "   EN: 'Fixed video issue, improved performance'"
else
    echo "❌ AAB oluşturma başarısız!"
    exit 1
fi 