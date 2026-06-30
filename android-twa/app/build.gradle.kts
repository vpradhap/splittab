plugins {
    id("com.android.application") version "8.5.2"
}

android {
    namespace = "com.vpradhap.splittab"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.vpradhap.splittab"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    // Signing values are supplied entirely by Gradle's own official
    // non-interactive override properties (-Pandroid.injected.signing.*),
    // passed in by the CI workflow. No prompts, no bubblewrap, no inquirer.
    signingConfigs {
        create("release") {
            // Left intentionally blank — Android Gradle Plugin auto-fills
            // these from -Pandroid.injected.signing.* properties at build time.
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
}

dependencies {
    // Google's official Trusted Web Activity library — wraps your PWA URL
    // as a native Android app. This IS what bubblewrap generates under the
    // hood; we're just authoring the project by hand instead of through
    // bubblewrap's broken interactive CLI.
    implementation("com.google.androidbrowserhelper:androidbrowserhelper:2.5.0")
}
