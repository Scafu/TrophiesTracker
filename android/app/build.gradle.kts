import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

dependencies{
    implementation("com.google.android.material:material:1.13.0")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}


android {
    signingConfigs {
        create("release") {
            val isCI = System.getenv()["CI"] == "true"
            if (isCI) {
                val storeFilePath = System.getenv()["CM_KEYSTORE_PATH"]
                val storePasswordEnv = System.getenv()["CM_KEYSTORE_PASSWORD"]
                val keyAliasEnv = System.getenv()["CM_KEY_ALIAS"]
                val keyPasswordEnv = System.getenv()["CM_KEY_PASSWORD"]
                if (storeFilePath.isNullOrBlank() || storePasswordEnv.isNullOrBlank() || keyAliasEnv.isNullOrBlank() || keyPasswordEnv.isNullOrBlank()) {
                    throw GradleException("Codemagic signing environment variables are missing!")
                }
                storeFile = file(storeFilePath)
                storePassword = storePasswordEnv
                keyAlias = keyAliasEnv
                keyPassword = keyPasswordEnv
            } else {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = keystoreProperties["storeFile"]?.let { file(it) }
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }


    namespace = "com.alessandromazzariol.trophiestracker"
    compileSdk = flutter.compileSdkVersion
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
        applicationId = "com.alessandromazzariol.trophiestracker"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}