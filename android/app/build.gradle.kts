import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.helpoohelp.helpflutter"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.helpoohelp.helpflutter"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Falls back to debug signing until key.properties (see key.properties.example)
            // is created with a real release keystore — required before Play Store upload.
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }

            // Code + resource shrinking — the debug build intentionally skips
            // both (for fast iteration/debuggability), which is why debug
            // APKs are much larger than a properly configured release build.
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }

    // NOTE on ABI splitting: this Flutter version's own Gradle plugin
    // already wires up `splits { abi { ... } }` automatically — but only
    // when the `split-per-abi` Gradle property is set, which is exactly
    // what `flutter build apk --split-per-abi` passes (see flutter_tools'
    // FlutterPlugin.kt: shouldProjectSplitPerAbi). A manually-added,
    // unconditional `splits {}` block here would collide with Flutter's
    // *own* fallback `ndk.abiFilters` configuration (applied to every
    // build type, including debug, whenever splits-per-abi is NOT
    // requested) — that combination is rejected by AGP with "Conflicting
    // configuration ... ndk abiFilters cannot be present when splits abi
    // filters are set". So: no manual splits config is needed here at
    // all; just build with `flutter build apk --release --split-per-abi`
    // to get per-ABI release APKs, and a plain `flutter build apk` (debug
    // or release) still produces one universal APK as before.
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation(platform("com.google.firebase:firebase-bom:34.18.0"))
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-crashlytics")
}