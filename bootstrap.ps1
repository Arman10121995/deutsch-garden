# Generate and patch the native wrapper for one platform, then resolve deps.
#
#   .\bootstrap.ps1 windows    .exe desktop bundle
#   .\bootstrap.ps1 android    APK
#   .\bootstrap.ps1 all        windows + android
param([string]$Target = "all")

$ErrorActionPreference = "Stop"

switch ($Target) {
    "windows" { $Platforms = "windows" }
    "android" { $Platforms = "android" }
    "all"     { $Platforms = "windows,android" }
    default {
        Write-Error "Unknown target: $Target. Use one of: windows android all"
        exit 2
    }
}

Write-Host "Generating wrapper for: $Platforms"
flutter create . --platforms=$Platforms --org com.deutschgarden

# `flutter create` scaffolds a counter-app widget test that does not compile
# against this project. The real widget test is test/app_smoke_test.dart.
Remove-Item -Force -ErrorAction SilentlyContinue test/widget_test.dart

python tool/patch_platforms.py
flutter pub get

# Writes the launcher icons into whichever native projects were generated
# above. Without this every platform ships Flutter's default icon. Linux is
# absent because flutter_launcher_icons does not support it.
foreach ($target in @('android','ios','windows','macos')) {
  if (Test-Path $target) {
    dart run flutter_launcher_icons -f "tool/icons/$target.yaml"
  }
}

Write-Host ""
Write-Host "Ready. Build with:"
Write-Host "  flutter build windows --release   # .exe bundle in build\windows\x64\runner\Release"
Write-Host "  flutter build apk --release       # Android APK"
