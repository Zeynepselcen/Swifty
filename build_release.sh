#!/bin/bash

# Swifty Gallery Cleaner - AAB Build Script
# Bu script otomatik olarak versiyon kontrolü yapar ve imzalı AAB oluşturur

echo "🚀 Swifty Gallery Cleaner - AAB Build Script"
echo "=============================================="

# 1. Versiyon kontrolü
echo "📋 Versiyon kontrolü yapılıyor..."
CURRENT_VERSION=$(grep "version:" pubspec.yaml | awk '{print $2}')
echo "Mevcut versiyon: $CURRENT_VERSION"

# Kullanıcıdan yeni versiyon iste
read -p "Yeni versiyon (örn: 1.1.1+4): " NEW_VERSION

if [ -z "$NEW_VERSION" ]; then
    echo "❌ Versiyon belirtilmedi. İşlem iptal edildi."
    exit 1
fi

# 2. Versiyonları güncelle
echo "🔄 Versiyonlar güncelleniyor..."

# pubspec.yaml güncelle
sed -i '' "s/version: .*/version: $NEW_VERSION/" pubspec.yaml

# build.gradle.kts güncelle
VERSION_NAME=$(echo $NEW_VERSION | cut -d'+' -f1)
VERSION_CODE=$(echo $NEW_VERSION | cut -d'+' -f2)
sed -i '' "s/versionName = \".*\"/versionName = \"$VERSION_NAME\"/" android/app/build.gradle.kts
sed -i '' "s/versionCode = .*/versionCode = $VERSION_CODE/" android/app/build.gradle.kts

echo "✅ Versiyonlar güncellendi: $NEW_VERSION"

# 3. Keystore kontrolü
echo "🔐 Keystore kontrolü yapılıyor..."
if [ ! -f "android/app/upload-keystore.jks" ]; then
    echo "❌ Keystore dosyası bulunamadı!"
    echo "Keystore oluşturuluyor..."
    keytool -genkey -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload -storepass swifty123 -keypass swifty123 -dname "CN=Swifty Gallery Cleaner, OU=Development, O=Swifty, L=Istanbul, S=Istanbul, C=TR"
fi

if [ ! -f "android/key.properties" ]; then
    echo "key.properties dosyası oluşturuluyor..."
    echo -e "storePassword=swifty123\nkeyPassword=swifty123\nkeyAlias=upload\nstoreFile=upload-keystore.jks" > android/key.properties
fi

# 4. Clean ve build
echo "🧹 Clean işlemi yapılıyor..."
flutter clean

echo "🔨 AAB oluşturuluyor..."
flutter build appbundle

# 5. Sonuç kontrolü
if [ -f "build/app/outputs/bundle/release/app-release.aab" ]; then
    echo "✅ İmzalı AAB başarıyla oluşturuldu!"
    echo "📁 Dosya: build/app/outputs/bundle/release/app-release.aab"
    echo "📊 Boyut: $(ls -lh build/app/outputs/bundle/release/app-release.aab | awk '{print $5}')"
    echo "🔢 Versiyon: $NEW_VERSION"
    
    # Git commit
    echo "📝 Git commit yapılıyor..."
    git add .
    git commit -m "v$VERSION_NAME: Yeni sürüm oluşturuldu - $NEW_VERSION"
    
    echo "🎉 İşlem tamamlandı! AAB dosyası hazır."
else
    echo "❌ AAB oluşturulamadı!"
    exit 1
fi 