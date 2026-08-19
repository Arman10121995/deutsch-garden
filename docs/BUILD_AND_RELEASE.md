# Build and Release

## Local Android build

1. Install current stable Flutter and Android SDK.
2. Run the platform bootstrap script. It uses `flutter create . --platforms=android` to generate native scaffolding compatible with the installed Flutter version.
3. The manifest patcher adds the Android TTS query configuration.
4. Resolve dependencies, analyze, test and build.

Windows:

```powershell
.\bootstrap_android.ps1
flutter analyze
flutter test
flutter build apk --release
```

Linux/macOS:

```bash
./bootstrap_android.sh
flutter analyze
flutter test
flutter build apk --release
```

## CI build

`.github/workflows/android-apk.yml` repeats the same steps on GitHub Actions and uploads the release APK as an artifact.

## Why native Android scaffolding is generated

Flutter’s Android Gradle templates evolve. Generating the platform wrapper from the installed stable SDK avoids pinning stale native boilerplate in this source bundle.
