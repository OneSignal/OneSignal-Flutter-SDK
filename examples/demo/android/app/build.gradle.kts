plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val hasGoogleServices = file("google-services.json").exists()

// E2E builds pass `-PFIREBASE_INSTALLATION_ID_ENABLED=true` (`flutter build apk -P...`).
// The flag does nothing without the default FirebaseApp from google-services.json.
val firebaseInstallationIdEnabled =
    (findProperty("FIREBASE_INSTALLATION_ID_ENABLED") as? String)?.trim()?.toBoolean() ?: false
if (firebaseInstallationIdEnabled && !hasGoogleServices) {
    throw GradleException("FIREBASE_INSTALLATION_ID_ENABLED requires examples/demo/android/app/google-services.json")
}

android {
    namespace = "com.onesignal.sdkdemo"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.onesignal.sdkdemo"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["firebaseInstallationIdEnabled"] = firebaseInstallationIdEnabled.toString()
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
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

dependencies {
    // OneSignal resolves firebase-messaging 24.x; Installation ID registration needs 25.1.2+.
    implementation("com.google.firebase:firebase-messaging:25.1.3")
}

if (hasGoogleServices) {
    apply(plugin = "com.google.gms.google-services")
}
