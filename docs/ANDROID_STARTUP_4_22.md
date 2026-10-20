# Android startup acceptance for 4.22

## Reproduction

The published `v4.21.0` APK (version code 82) was downloaded from this repository's
GitHub release and installed without changing its binary. On an Android 16/API
36.1 x86_64 emulator, the first `SharedPreferencesAsync.getString` call threw
`java.lang.NoSuchMethodError` for
`SharedPreferencesAsyncApiRegistrar.getString(...Continuation...)`. The Dart stack
ended at `AppController.load` and `main`'s pre-`runApp` wait. No app frame could
be drawn. This independently reproduces the reported black-screen symptom.

The binary uses `SharedPreferencesAsyncApiForNativeInterop`; this is consistent
with the Android plugin's [2.5.0 JNI migration](https://pub.dev/packages/shared_preferences_android/changelog).
The locally tested lockfile still resolved 2.4.27, whose generated interface uses
platform messages. The application had ignored its lockfile, so a release could
resolve a different backend than local verification. The exact upstream
code-generation/optimizer defect causing the missing JNI method is not established
here; the observed exception and dependency mismatch are sufficient to select a
verified implementation without guessing at blanket shrinker rules.

## Correction

- Pin `shared_preferences_android` to 2.4.27, retain the existing asynchronous
  DataStore API and profile keys, and commit the tested `pubspec.lock`.
- Generate native wrappers without a fresh dependency resolution, then enforce
  the lockfile in both verification and platform-build CI jobs.
- Draw a localized startup screen before opening storage. Failed reads display
  a recovery screen and a non-sensitive exception type, without exposing profile
  contents or opening a writable empty profile. Retry begins only when the
  previous load has finished. Long-running loads keep a visible status and do
  not start a second concurrent migration. Optional illustration indexing has a
  bounded wait. Android still avoids bundled neural voice initialization.
- Emit `DeutschGarden startup ready (version)` after the loaded app's first
  frame, and require it on two launches of the actual release APK.

No profile keys, permissions, account settings or learner data are reset by this
fix. Install the new signed APK over the existing app; keep its data.

## Repeatable acceptance

`tool/android_release_smoke.py` is emulator-only. It installs with `adb install
-r`, launches twice without clearing application data, checks the expected
version's post-load first-frame marker and fails on an unhandled exception or
90-second timeout. Release CI executes it against the same signed/shrunk APK
that is packaged for publication, rather than a debug or integration-test build.

```powershell
python tool/android_release_smoke.py --apk build/app/outputs/flutter-apk/app-release.apk --device emulator-5582 --adb C:/Users/arkhan/AppData/Local/Android/Sdk/platform-tools/adb.exe
```

Widget regressions independently cover pending storage, a failed read followed
by retry with the stored profile preserved, and a stalled optional asset index.
The APK signing-certificate SHA-256 digest is checked against the previous
release before update testing. Tests on an emulator do not establish acceptance
on every physical phone; keep phone-specific logs if a problem persists.
