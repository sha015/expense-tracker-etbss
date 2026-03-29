plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.etbss"
    compileSdk = 35 // ✅ Set a fixed compileSdk version

    ndkVersion = "27.0.12077973" // ✅ Manually set the required NDK version

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.example.etbss"
        minSdk = 21 // ✅ Ensure minSdk is at least 21 for multiDex support
        targetSdk = 34 // ✅ Set a fixed targetSdk version
        versionCode = 1
        versionName = "1.0"
        multiDexEnabled = true // ✅ Enable MultiDex support
    }

    buildTypes {
        release {
            isMinifyEnabled = true // ✅ Correct Kotlin DSL syntax
            isShrinkResources = true // ✅ Correct Kotlin DSL syntax
            signingConfig = signingConfigs.getByName("debug")
        }
    }
} // ✅ Added missing closing brace for android block

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1") // ✅ Add MultiDex dependency
}
