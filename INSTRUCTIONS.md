# Quick Instructions

## 1. Validate content without Flutter

```bash
python3 tool/validate_content.py
```

## 2. Prepare the native wrapper for your target

Windows:

```powershell
.\bootstrap.ps1 windows      # or: android, all
```

Linux/macOS:

```bash
./bootstrap.sh linux         # or: android, macos, ios, all
```

## 3. Run checks

```bash
flutter analyze
flutter test
```

## 4. Run app

```bash
flutter run
```

## 5. Build a release artifact

```bash
flutter build apk --release       # Android  -> build/app/outputs/flutter-apk/app-release.apk
flutter build windows --release   # Windows  -> build/windows/x64/runner/Release/
flutter build linux --release     # Linux    -> build/linux/x64/release/bundle/
flutter build macos --release     # macOS    -> build/macos/Build/Products/Release/
flutter build ios --release       # iOS      -> needs your own signing identity
```

## 6. Cloud build alternative

Push the repository to GitHub. The **CI** workflow
(`.github/workflows/ci.yml`) runs on every push and pull request, and can also
be started manually from the Actions tab. Download the artifact for your
platform (`DeutschGarden-Android-APK`, `-Windows`, `-macOS`, `-Linux`,
`-iOS-unsigned`) from the completed run.

## 7. Using the microphone

Speaking practice needs the platform speech recogniser:

- Grant the microphone permission when the app first asks.
- On Android, install a **German offline language pack** in the system speech
  settings if you want recognition to stay on the device. Without it the system
  recogniser may use a network service — see `docs/PRIVACY.md`.
- If no recogniser is available, nothing breaks: every speaking screen accepts
  typed answers and scores them identically.
