# App-specific ProGuard/R8 additions on top of Flutter's own default rules
# (proguard-android-optimize.txt) and each plugin's bundled consumer rules
# (flutter_local_notifications 22.x, geolocator, firebase_* etc. all ship
# their own consumer-rules.pro inside their AARs, which R8 picks up
# automatically — no manual keep rules were found to be required for any of
# them as of the versions pinned in pubspec.yaml/pubspec.lock).

# Keep source file + line number info so Crashlytics can produce readable,
# de-obfuscated stack traces instead of just class/method names.
-keepattributes SourceFile,LineNumberTable

# Standard companion to the rule above: hides the original file name so
# stack traces show "SourceFile" instead of leaking the real Kotlin/Java
# file name, without losing line numbers.
-renamesourcefileattribute SourceFile
