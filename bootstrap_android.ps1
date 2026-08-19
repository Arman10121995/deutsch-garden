$ErrorActionPreference = "Stop"

flutter create . --platforms=android --org com.deutschgarden

# `flutter create` scaffolds a counter-app widget test that does not compile
# against this project. The real widget test is test/app_smoke_test.dart.
Remove-Item -Force -ErrorAction SilentlyContinue test/widget_test.dart

python tool/patch_android_manifest.py
flutter pub get

Write-Host ""
Write-Host "Android project is ready."
Write-Host "Run: flutter run"
Write-Host "APK: flutter build apk --release"
