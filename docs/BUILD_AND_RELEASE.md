# Build and Release

## Requirements

- Current stable Flutter SDK compatible with Dart 3.9+
- Android SDK and build tools
- A JDK supported by your Flutter/Android toolchain
- Python 3 (for the manifest patcher and the content tools)

## Local Android build

1. Run the platform bootstrap script. It uses `flutter create . --platforms=android`
   to generate native scaffolding matching the installed Flutter version, removes
   the counter-app widget test that command scaffolds, and patches the manifest.
2. Resolve dependencies, analyze, test and build.

Windows:

```powershell
.\bootstrap_android.ps1
flutter analyze
flutter test
flutter build apk --release
```

Linux/macOS:

```bash
./bootstrap_android.sh
flutter analyze
flutter test
flutter build apk --release
```

APK output: `build/app/outputs/flutter-apk/app-release.apk`

## What the manifest patcher does

`tool/patch_android_manifest.py` is additive and idempotent. It:

- renames the application label to `DeutschGarden`,
- adds `RECORD_AUDIO` (microphone practice) and `INTERNET` (the platform speech
  recogniser falls back to a network service when no offline German pack is
  installed),
- adds Android 11+ package-visibility `<intent>` entries for
  `android.intent.action.TTS_SERVICE` and `android.speech.RecognitionService`,
  **merging into the `<queries>` block Flutter already wrote** rather than
  replacing it. Replacing it would drop the engine's `ACTION_PROCESS_TEXT`
  entry, which is what the 3.0 patcher did.

## Content tooling

```bash
python3 tool/validate_content.py        # integrity gate; exits non-zero on failure
python3 tool/generate_content_report.py # regenerates CONTENT_MANIFEST.json from source
```

The validator checks ID uniqueness, CEFR distribution, per-level minimums for
every content type including role-plays, free-talk prompts, stories and curated
sentences, that every chapter has a parent story, and delimiter balance across
`lib/*.dart` after stripping strings and comments.

## CI

`.github/workflows/deutsch-garden.yml` **at the repository root** (not inside
`deutsch_garden/`, where GitHub would never read it) runs the same steps on
GitHub Actions: validate content, generate the Android wrapper, resolve, analyze,
test, build the release APK and upload it as an artifact.

## Why native Android scaffolding is generated

Flutter's Android Gradle templates evolve. Generating the platform wrapper from
the installed stable SDK avoids pinning stale native boilerplate in this source
bundle. `android/`, `web/` and the other platform directories are gitignored for
the same reason.
