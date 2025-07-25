pluginManagement {
    def flutterSdkPath = {
        def properties = new Properties()
        file("local.properties").withReader("UTF-8") { reader ->
            properties.load(reader)
        }
        def flutterSdk = properties.getProperty("flutter.sdk")
        assert flutterSdk != null, "flutter.sdk not set in local.properties"
        return flutterSdk
    }()

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id "dev.flutter.flutter-gradle-plugin" version "1.0.0" apply false
    id "com.android.application" version "8.2.1" apply false
    id "org.jetbrains.kotlin.android" version "1.9.22" apply false
}

include ":app"
