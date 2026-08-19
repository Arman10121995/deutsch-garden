# Platforms

One codebase, five targets. Everything under `lib/` is identical on every
platform — the same 881 words, 96 grammar lessons, 12 stories, 16 role-plays,
SM-2 scheduler and exam bank. Only the generated native wrapper differs, and it
is generated from your installed Flutter rather than committed.

| Target | Artifact | Branch | Speech synthesis | Speech recognition |
| --- | --- | --- | --- | --- |
| Android | `DeutschGarden.apk` | `android` | OS engine | OS recogniser |
| Windows | `DeutschGarden-windows-x64.zip` (`.exe` inside) | `windows` | SAPI via flutter_tts | `speech_to_text_windows` |
| macOS | `DeutschGarden-macos.zip` (`.app`) | `apple` | OS engine | Speech framework |
| iOS | `DeutschGarden-ios-unsigned.zip` | `apple` | OS engine | Speech framework |
| Linux | `DeutschGarden-linux-x64.tar.gz` | `linux` | `spd-say` / `espeak-ng` | **none** |

`main` carries the full cross-platform source and builds all five. The
per-platform branches exist so each platform has an obvious home and its own
green build; they are branches of the same code, not divergent forks.

## Is it really all offline?

Yes, with one honest caveat.

**Baked into the binary:** every vocabulary card, grammar lesson, listening
script, reading text, writing prompt, speaking lesson, story chapter, role-play
turn, practice sentence, placement item and exam mock. They are Dart constants
compiled into the executable. There is no asset download, no first-run sync, no
CDN, no API, and no DeutschGarden server anywhere.

**Provided by your operating system:** speech synthesis and speech recognition.
The app cannot bundle these — a German neural voice plus an acoustic model is
hundreds of megabytes and is exactly what the OS already ships.

**The caveat:** on Android and iOS, the *system* speech recogniser may route
audio through the vendor's servers unless you install an offline language pack.
That is the platform's behaviour, not this app's, and this app cannot override
it. If that matters to you, install the German offline pack — or use typed
input, which every speaking exercise accepts and scores identically.

## Linux specifics

Neither `flutter_tts` nor `speech_to_text` implements Linux; both declare
android, iOS, macOS, Windows and web only. So on Linux:

* **Speech synthesis** falls back to the synthesiser your distribution already
  has. `lib/system_tts_io.dart` probes `spd-say` (speech-dispatcher), then
  `espeak-ng`, then `espeak`, and drives whichever answers. If you hear nothing:

  ```bash
  sudo apt install speech-dispatcher espeak-ng     # Debian/Ubuntu
  sudo dnf install speech-dispatcher espeak-ng     # Fedora
  ```

  This is fully local — nothing is streamed.

* **Speech recognition is unavailable.** There is no offline Linux recogniser
  this app could ship without bundling an acoustic model of its own. Every
  speaking screen therefore accepts typed answers, scored by exactly the same
  evaluator. The app says this on screen rather than offering a dead button.

## Desktop behaviour

The interface adapts to window width, not to platform: at 900 px and above the
bottom bar becomes a side rail and content is capped at a readable line length;
below that it behaves like a phone. A Windows build in a narrow window gets the
phone layout, which is the correct outcome.

The review queue is fully keyboard-driven on desktop — space reveals, `1`–`4`
grade, space repeats "Good" — because reviewing a long queue with a mouse is
the surest way to make someone stop reviewing.

## Moving your progress between platforms

There is no account and no cloud sync, which is what keeps the app offline —
but it also means your Android profile and your desktop profile are unrelated.

**Settings → Export progress** turns the entire profile into text you can carry
across by any means you like: clipboard, a text file, a chat message, a USB
stick. **Settings → Import progress** on the other device reads it back. The
importer validates the payload and shows you what it contains before it
overwrites anything, and restore replaces rather than merges — see
`test/backup_test.dart`.

## Building locally

```bash
./bootstrap.sh android     # or linux, macos, ios, all
flutter build apk --release
```

```powershell
.\bootstrap.ps1 windows
flutter build windows --release
```

`bootstrap` generates the native wrapper, removes the counter-app test
`flutter create` scaffolds, and runs `tool/patch_platforms.py`, which:

* sets the app label and window title to **DeutschGarden** and the default
  desktop window to 1180×820;
* adds `RECORD_AUDIO`, `INTERNET` and the TTS/speech-recognition
  package-visibility queries on Android, merging into Flutter's own `<queries>`
  block rather than replacing it;
* adds `NSMicrophoneUsageDescription` and `NSSpeechRecognitionUsageDescription`
  to the iOS and macOS `Info.plist` — **without these the OS terminates the app
  the moment it asks for the microphone**;
* adds the `com.apple.security.device.audio-input` entitlement to both macOS
  entitlement files, without which the sandbox denies the microphone silently.

Every edit is idempotent.

## iOS signing

CI builds iOS with `--no-codesign`, because GitHub-hosted runners have no
signing identity. That produces a `Runner.app`, not an installable `.ipa`.
To put it on a device you need your own Apple Developer account: open
`ios/Runner.xcworkspace` in Xcode, set your team under Signing & Capabilities,
and run it from there. Nothing about the app itself has to change.
