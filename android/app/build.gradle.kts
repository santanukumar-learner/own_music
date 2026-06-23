plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.helprevx.music_recommender"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.helprevx.music_recommender"
        minSdk = 26 // API 26+ per spec (overrides the Flutter default floor)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Keep the APK lean: ship only arm64 native libs (onnxruntime, isar,
        // just_audio). The target device (Motorola Edge 50 Fusion) is arm64-v8a.
        // Add "armeabi-v7a"/"x86_64" here for 32-bit devices or the emulator.
        ndk {
            abiFilters += "arm64-v8a"
        }
    }

    buildTypes {
        release {
            // Personal app: sign release with the debug key so
            // `flutter run --release` / `flutter build apk` work without a keystore.
            // Swap in a real keystore before distributing.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
