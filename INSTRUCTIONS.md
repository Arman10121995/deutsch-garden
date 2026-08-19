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

Push the folder to GitHub and run `.github/workflows/android-apk.yml` from GitHub Actions. Download the artifact named `DeutschGarden-APK`.
