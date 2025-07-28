#!/bin/bash

# Sürüm numarasını oku
current_version=$(cat version.txt)
new_version=$((current_version + 1))

# Sürüm numarasını güncelle
echo $new_version > version.txt

# build.gradle.kts dosyasını güncelle
sed -i '' "s/versionCode = $current_version/versionCode = $new_version/" android/app/build.gradle.kts

# Minor version'ı da artır (1.0.1 -> 1.0.2)
current_minor=$(echo "1.0.$((current_version - 1))")
new_minor=$(echo "1.0.$((new_version - 1))")
sed -i '' "s/versionName = \"$current_minor\"/versionName = \"$new_minor\"/" android/app/build.gradle.kts

echo "✅ Sürüm güncellendi: $current_version -> $new_version"
echo "📱 Version Name: $new_minor" 