$ErrorActionPreference = "Stop"

flutter create . --platforms=android --org com.deutschgarden
python tool/patch_android_manifest.py
flutter pub get

Write-Host ""
Write-Host "Android project is ready."
Write-Host "Run: flutter run"
Write-Host "APK: flutter build apk --release"
