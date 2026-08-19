#!/usr/bin/env bash
set -euo pipefail

flutter create . --platforms=android --org com.deutschgarden

# `flutter create` scaffolds a counter-app widget test that does not compile
# against this project. The real widget test is test/app_smoke_test.dart.
rm -f test/widget_test.dart

python3 tool/patch_android_manifest.py
flutter pub get

echo
echo "Android project is ready."
echo "Run: flutter run"
echo "APK: flutter build apk --release"
