# DeutschGarden - local development on Windows.
#
#   .\dev.ps1              list the commands
#   .\dev.ps1 setup        one-time: generate the native wrapper, fetch packages
#   .\dev.ps1 verify       what CI runs: content check, analyze, tests
#   .\dev.ps1 run          launch the app with hot reload
param([string]$Command = "help")

$ErrorActionPreference = "Stop"

function Show-Help {
    Write-Host "DeutschGarden - local development"
    Write-Host ""
    Write-Host "  setup          Generate the Windows wrapper and fetch packages"
    Write-Host "  doctor         Check that your Flutter toolchain is complete"
    Write-Host "  deps           Fetch Dart packages only"
    Write-Host "  content        Validate the bundled curriculum (no Flutter needed)"
    Write-Host "  analyze        Static analysis - must be clean before committing"
    Write-Host "  test           Run the test suite"
    Write-Host "  verify         content + analyze + test, in one command"
    Write-Host "  fmt            Format all Dart sources"
    Write-Host "  run            Run on Windows desktop with hot reload"
    Write-Host "  run-android    Run on a connected Android device or emulator"
    Write-Host "  devices        List devices Flutter can run on right now"
    Write-Host "  build-windows  Release .exe bundle"
    Write-Host "  build-android  Release APK"
    Write-Host "  report         Regenerate CONTENT_MANIFEST.json and VALIDATION_REPORT.txt"
    Write-Host "  clean          Remove build output and generated wrappers"
}

switch ($Command) {
    "help"    { Show-Help }
    "setup"   { .\bootstrap.ps1 all }
    "doctor"  { flutter doctor -v }
    "deps"    { flutter pub get }
    "content" { python tool/validate_content.py }
    "analyze" { flutter analyze }
    "test"    { flutter test }
    "verify"  {
        python tool/validate_content.py
        flutter analyze
        flutter test
        Write-Host ""
        Write-Host "All checks passed."
    }
    "fmt"     { dart format lib test }
    "run"     { flutter run -d windows }
    "run-android" { flutter run -d android }
    "devices" { flutter devices }
    "build-windows" {
        flutter build windows --release
        Write-Host "-> build\windows\x64\runner\Release\"
    }
    "build-android" {
        flutter build apk --release
        Write-Host "-> build\app\outputs\flutter-apk\app-release.apk"
    }
    "report" {
        python tool/generate_content_report.py | Out-Null
        python tool/validate_content.py | Set-Content VALIDATION_REPORT.txt
        Get-Content VALIDATION_REPORT.txt -Tail 8
    }
    "clean" {
        flutter clean
        foreach ($d in @("android","ios","linux","macos","windows","web",".dart_tool","build")) {
            Remove-Item -Recurse -Force -ErrorAction SilentlyContinue $d
        }
        Write-Host "Generated wrappers removed. Run '.\dev.ps1 setup' to recreate them."
    }
    default {
        Write-Host "Unknown command: $Command"
        Write-Host ""
        Show-Help
        exit 2
    }
}
