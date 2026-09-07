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
    // compileSdk precisa ser >= targetSdk, então subiu junto para 36 quando
    // a Play passou a exigir API 36 (ver targetSdk abaixo). A plataforma
    // "android-36" já está instalada em C:\Android\platforms.
    compileSdk = 36
    // Fixado porque o Build-Tools 36.0.0 não está instalado nesta máquina
    // (sem internet para o sdkmanager) e, sem esta linha, o AGP tenta usar
    // a versão que casa com o compileSdk e falha. O 35.0.0 compila contra a
    // API 36 sem problema — o Build-Tools é o empacotador (aapt2/d8), não a
    // plataforma alvo.
    //
    // Nota histórica: a pasta "C:\Android\build-tools\35.0.0" foi criada
    // manualmente como cópia da 34.0.0, pelo mesmo motivo de rede.
    buildToolsVersion = "35.0.0"
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
        // targetSdk 36 (Android 16). A exigência mínima da Play sobe todo
        // ano e é verificada no **envio**, não no build: em 2026-07-23 o
        // envio com 34 foi rejeitado pedindo 35; em 2026-09-06 o envio com
        // 35 foi rejeitado pedindo 36. Revisar a cada release.
        targetSdk = 36
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
            // Inclui os símbolos de depuração do código nativo (motor do
            // Flutter + libs nativas dos plugins) direto no .aab, evitando o
            // aviso do Play Console pedindo upload manual desses símbolos.
            ndk {
                debugSymbolLevel = "FULL"
            }
        }
    }
}

flutter {
    source = "../.."
}
