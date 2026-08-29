# Firebase setup — remaining manual steps

The Dart/Flutter side of push notifications (`firebase_core`, `firebase_messaging`,
`lib/core/services/push_service.dart`) is already wired up and ships safely with
**no** Firebase project configured — `PushService.initialize()` catches the failure,
logs it, and the rest of the app (including the Titbit inbox itself, which only
needs the REST API) works normally.

Once you have a real Firebase project and have downloaded its config files, do the
following to turn push notifications on for real:

## 1. Android

1. Download `google-services.json` from the Firebase console (Project settings →
   your Android app, package name `com.helpoohelp.helpflutter`) and drop it into:
   ```
   android/app/google-services.json
   ```
2. Add the Google Services Gradle plugin. This project uses the modern Kotlin DSL
   `plugins {}` block style (not the old `buildscript`/`apply plugin` style), so:

   In `android/settings.gradle.kts`, add the plugin to the existing `plugins {}`
   block (alongside `com.android.application` and `org.jetbrains.kotlin.android`):
   ```kotlin
   plugins {
       id("dev.flutter.flutter-plugin-loader") version "1.0.0"
       id("com.android.application") version "8.11.1" apply false
       id("org.jetbrains.kotlin.android") version "2.2.20" apply false
       id("com.google.gms.google-services") version "4.4.2" apply false
   }
   ```
3. In `android/app/build.gradle.kts`, add the plugin id to the existing `plugins {}`
   block at the top of the file:
   ```kotlin
   plugins {
       id("com.android.application")
       id("kotlin-android")
       id("dev.flutter.flutter-gradle-plugin")
       id("com.google.gms.google-services")
   }
   ```

   **Do this only after `google-services.json` is actually present** — the plugin
   fails the build otherwise. That's exactly why neither of these files was touched
   automatically.
4. Run `flutter pub get` then `flutter build apk --debug` to confirm it still builds.

## 2. iOS

1. In Xcode (needs a Mac — can't be scripted from this environment), download
   `GoogleService-Info.plist` from the Firebase console (Project settings → your
   iOS app, bundle id should match `ios/Runner.xcodeproj`'s `PRODUCT_BUNDLE_IDENTIFIER`).
2. Drag it into `ios/Runner/` in Xcode's project navigator, making sure "Copy items
   if needed" is checked and it's added to the **Runner** target.
3. No further Podfile/Xcode changes should be needed — `firebase_core` and
   `firebase_messaging` are already Flutter dependencies (see `pubspec.yaml`) and
   will pick up the plist automatically once it's present in the target.

## 3. After both are done

- `PushService.isAvailable` will become `true` at the next app start.
- Push permission is requested, and the device's FCM token is registered with the
  backend (`POST /notifications/register-device/`) automatically after login.
- Foreground pushes show via `flutter_local_notifications` (channel id
  `titbits_channel`); tapping a push (foreground, background, or cold start) opens
  the Titbit inbox (`TitbitsScreen`).

Nothing else in the Dart codebase needs to change.
