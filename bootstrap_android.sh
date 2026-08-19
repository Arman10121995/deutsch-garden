#!/usr/bin/env bash
set -euo pipefail

flutter create . --platforms=android --org com.deutschgarden
python3 tool/patch_android_manifest.py
flutter pub get

echo
echo "Android project is ready."
echo "Run: flutter run"
echo "APK: flutter build apk --release"
