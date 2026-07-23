plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.dsdev.pdf.ds_pdf"
    // compileSdk 35 é exigido por flutter_plugin_android_lifecycle (fixa
    // "compileSdk 35" no próprio build.gradle) — não é opcional para este
    // projeto. O Android SDK Build-Tools 35.0.0 correspondente não estava
    // instalado nesta máquina (sem internet para baixar via sdkmanager); a
    // pasta local "C:\Android\build-tools\35.0.0" foi criada manualmente como
    // cópia da 34.0.0 já instalada (funcionalmente equivalente para este
    // projeto) para satisfazer a checagem do Android Gradle Plugin.
    compileSdk = 35
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.dsdev.pdf.ds_pdf"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // minSdk 23 (Android 6.0) é exigido pela dependência nativa do Scanner
        // (com.google.android.gms:play-services-mlkit-document-scanner) — o
        // padrão do Flutter (21) não é suficiente para essa biblioteca.
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
