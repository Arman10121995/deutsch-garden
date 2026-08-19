#!/usr/bin/env bash
# Generate and patch the native wrapper for one platform, then resolve deps.
#
#   ./bootstrap.sh android     APK
#   ./bootstrap.sh linux       GTK desktop bundle
#   ./bootstrap.sh macos       .app
#   ./bootstrap.sh ios         .app (needs your own signing identity to install)
#   ./bootstrap.sh all         everything this machine can build
#
# Windows users: use bootstrap.ps1.
set -euo pipefail

TARGET="${1:-all}"
case "$TARGET" in
  android|linux|macos|ios|windows) PLATFORMS="$TARGET" ;;
  all)
    case "$(uname -s)" in
      Darwin) PLATFORMS="android,ios,macos" ;;
      *)      PLATFORMS="android,linux" ;;
    esac
    ;;
  *)
    echo "Unknown target: $TARGET" >&2
    echo "Use one of: android linux macos ios windows all" >&2
    exit 2
    ;;
esac

echo "Generating wrapper for: $PLATFORMS"
flutter create . --platforms="$PLATFORMS" --org com.deutschgarden

# `flutter create` scaffolds a counter-app widget test that does not compile
# against this project. The real widget test is test/app_smoke_test.dart.
rm -f test/widget_test.dart

python3 tool/patch_platforms.py
flutter pub get

cat <<'EOF'

Ready. Build with:
  flutter build apk --release        # Android
  flutter build linux --release      # Linux
  flutter build macos --release      # macOS
  flutter build ios --release        # iOS (signing required)
EOF
