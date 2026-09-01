# Build and Release

## Requirements

- Current stable Flutter SDK compatible with Dart 3.9+
- Android SDK and build tools
- A JDK supported by your Flutter/Android toolchain
- Python 3 (for the manifest patcher and the content tools)

## Local build, any platform

1. Run the bootstrap script with your target. It runs `flutter create` for that
   platform against the installed Flutter version, removes the counter-app
   widget test that command scaffolds, and runs `tool/patch_platforms.py`.
2. Resolve dependencies, analyze, test and build.

Targets: `android`, `windows`, `linux`, `macos`, `ios`, `all`. See
`docs/PLATFORMS.md` for what each one produces and which speech capabilities it
has.

Windows:

```powershell
.\bootstrap.ps1 windows
flutter analyze
flutter test
flutter build windows --release
```

Linux/macOS:

```bash
./bootstrap.sh android
flutter analyze
flutter test
flutter build apk --release
```

APK output: `build/app/outputs/flutter-apk/app-release.apk`

## What the platform patcher does

`tool/patch_platforms.py` patches every generated wrapper and is idempotent
throughout. On Apple targets it adds the microphone and speech-recognition
usage strings and the macOS audio-input entitlement — without those the OS
terminates the app on first microphone use, or denies it in silence. On desktop
it sets the window title and default size.

For Android it delegates to `tool/patch_android_manifest.py`, which is
idempotent and preserves Flutter's generated declarations. That script:

- renames the application label to `DeutschGarden`,
- adds optional `RECORD_AUDIO`, opt-in `POST_NOTIFICATIONS` and
  `RECEIVE_BOOT_COMPLETED` for restoring local reminders,
- strips `INTERNET` from the release manifest; Android's external speech
  service owns its own connectivity and DeutschGarden itself has no reason to
  open a socket,
- adds the two local-notification receivers, but deliberately no exact-alarm
  permission,
- adds Android 11+ package-visibility `<intent>` entries for
  `android.intent.action.TTS_SERVICE` and `android.speech.RecognitionService`,
  **merging into the `<queries>` block Flutter already wrote** rather than
  replacing it. Replacing it would drop the engine's `ACTION_PROCESS_TEXT`
  entry, which is what the 3.0 patcher did.

## Content tooling

```bash
python3 tool/validate_content.py        # integrity gate; exits non-zero on failure
python3 tool/validate_content.py --write # regenerates all derived inventories
```

The validator checks ID uniqueness, CEFR distribution, per-level minimums for
every content type including role-plays, free-talk prompts, stories and curated
sentences, that every chapter has a parent story, and delimiter balance across
`lib/*.dart` after stripping strings and comments.

## CI

`.github/workflows/ci.yml` runs the same steps on GitHub Actions.

The `verify` job — content validation, `flutter analyze`, `flutter test` — runs
on every push and pull request. The six-way `build` matrix does **not**: it
runs only on **workflow_dispatch** (Actions → CI → Run workflow, with *Build
artifacts* ticked) or when a `v*` tag is pushed.

That split is now a matter of speed rather than cost. The repository is
public, so standard GitHub-hosted runners are free and unmetered on every
platform including macOS — the old private-repo arithmetic in
`docs/LOCAL_DEVELOPMENT.md` §7 no longer applies. A full matrix still takes
tens of minutes of wall-clock, and most pushes do not need an artifact, so the
gate stays. Day-to-day builds happen locally via `make` / `.\dev.ps1`.

Note that the workflow must live in `.github/workflows/` at the **repository
root**. GitHub does not read workflow files from subdirectories — a workflow
nested one level down is silently never run.

## Why native Android scaffolding is generated

Flutter's Android Gradle templates evolve. Generating the platform wrapper from
the installed stable SDK avoids pinning stale native boilerplate in this source
bundle. `android/`, `web/` and the other platform directories are gitignored for
the same reason.
