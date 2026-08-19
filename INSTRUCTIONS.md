# Quick Instructions

## 1. Validate content without Flutter

```bash
python3 tool/validate_content.py
```

## 2. Prepare Android project

Windows:

```powershell
.\bootstrap_android.ps1
```

Linux/macOS:

```bash
./bootstrap_android.sh
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

## 5. Build release APK

```bash
flutter build apk --release
```

Output:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## 6. Cloud build alternative

Push the repository to GitHub. The **CI** workflow
(`.github/workflows/ci.yml`) runs on every push and pull request, and can also
be started manually from the Actions tab. Download the artifact named
`DeutschGarden-APK` from the completed run.

## 7. Using the microphone

Speaking practice needs the platform speech recogniser:

- Grant the microphone permission when the app first asks.
- On Android, install a **German offline language pack** in the system speech
  settings if you want recognition to stay on the device. Without it the system
  recogniser may use a network service — see `docs/PRIVACY.md`.
- If no recogniser is available, nothing breaks: every speaking screen accepts
  typed answers and scores them identically.
