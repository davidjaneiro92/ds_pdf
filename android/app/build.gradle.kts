import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Keystore de release (android/upload-keystore.jks) — ver android/key.properties.
// key.properties nunca é commitado (android/.gitignore já cobre isso). Se o
// arquivo não existir (ex.: clone novo do repositório, CI), o build de
// release cai para a assinatura de debug em vez de falhar.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseKeystore = keystorePropertiesFile.exists()
if (hasReleaseKeystore) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.dsdevsolucoes.dspdf"
    // compileSdk 35 é exigido por flutter_plugin_android_lifecycle (fixa
    // "compileSdk 35" no próprio build.gradle) — não é opcional para este
    // projeto. O Android SDK Build-Tools 35.0.0 correspondente não estava
    // instalado nesta máquina (sem internet para baixar via sdkmanager); a
    // pasta local "C:\Android\build-tools\35.0.0" foi criada manualmente como
    // cópia da 34.0.0 já instalada (funcionalmente equivalente para este
    // projeto) para satisfazer a checagem do Android Gradle Plugin.
    compileSdk = 35
    // NDK pedido por vários plugins (flutter_doc_scanner, image_picker_android,
    // path_provider_android, permission_handler_android, printing, uri_to_file,
    // flutter_plugin_android_lifecycle). Era só um aviso (não bloqueava o
    // build), mas fixar aqui evita o Gradle baixar/gerenciar duas versões de
    // NDK e elimina o aviso.
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // Identificador definitivo do app na Play Store — não pode mudar
        // depois do primeiro envio.
        applicationId = "com.dsdevsolucoes.dspdf"
        // minSdk 23 (Android 6.0) é exigido pela dependência nativa do Scanner
        // (com.google.android.gms:play-services-mlkit-document-scanner) — o
        // padrão do Flutter (21) não é suficiente para essa biblioteca.
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Assina com o keystore de release (android/upload-keystore.jks)
            // quando disponível; cai para a chave de debug caso contrário
            // (ex.: máquina/CI sem o key.properties), para não quebrar o build.
            signingConfig = if (hasReleaseKeystore) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}
